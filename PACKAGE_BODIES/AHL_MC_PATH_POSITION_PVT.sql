--------------------------------------------------------
--  DDL for Package Body AHL_MC_PATH_POSITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_MC_PATH_POSITION_PVT" AS
/* $Header: AHLVPOSB.pls 120.5 2008/01/29 14:12:16 sathapli ship $ */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'Ahl_MC_Path_Position_Pvt';

--Generic separators for the fields.
G_ID_SEPARATOR      CONSTANT VARCHAR2(1) := ':';
G_NODE_SEPARATOR    CONSTANT VARCHAR2(1) := '/';



--------------------------------
-- Start of Comments --
--  Procedure name    : Create_Position_ID
--  Type        : Private
--  Function    : API to create the new path position or if matches
--    existing one, return the existing path_position_id
--  Pre-reqs    :
--  Parameters  :
--
--  Create_Position_ID Parameters:
--   p_path_position_tbl IN   AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type Required
--   p_pos_ref_meaning      IN VARCHAR2 Optional. Position ref for the path
--
--  End of Comments.

PROCEDURE Create_Position_ID (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_path_position_tbl   IN       AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type,
    p_position_ref_meaning  IN      VARCHAR2,
    p_position_ref_code  IN         VARCHAR2,
   x_position_id      OUT  NOCOPY    NUMBER)
IS
--
--Check that all 3 ids are valid.
CURSOR check_mc_ids_csr (p_mc_id  IN  NUMBER,
              p_ver_num IN NUMBER,
              p_pos_key IN NUMBER) IS
   SELECT  'X'
     FROM    ahl_mc_headers_b hd, ahl_mc_relationships rel
     WHERE  hd.mc_header_id = rel.mc_header_id
     AND    hd.mc_id = p_mc_id
     AND    hd.version_number = nvl(p_ver_num, hd.version_number)
     AND    rel.position_key = p_pos_key;
--
--Check that the config/subconfig mapping is valid.
CURSOR check_mc_relationships_csr (p_mc_id  IN  NUMBER,
                       p_ver_num IN NUMBER,
                       p_pos_key IN NUMBER,
                   p_child_mc_id IN NUMBER,
                   p_child_ver_num IN NUMBER) IS
   SELECT  'X'
     FROM   ahl_mc_config_relations rel, ahl_mc_headers_b hd
     WHERE  rel.mc_header_id = hd.mc_header_id
     AND    hd.mc_id = p_child_mc_id
     AND    hd.version_number = nvl(p_child_ver_num, hd.version_number)
     AND    rel.relationship_id IN
      (SELECT r.relationship_id
         FROM ahl_mc_relationships r, ahl_mc_headers_b h
        WHERE h.mc_header_id = r.mc_header_id
          AND    h.mc_id = p_mc_id
          AND    h.version_number = nvl(p_ver_num, h.version_number)
          AND    r.position_key = p_pos_key);
--
--Check the encoded path position csr
CURSOR get_position_id_csr (p_encoded_path IN VARCHAR2) IS
SELECT pos.path_position_id
  FROM ahl_mc_path_positions pos
 WHERE pos.encoded_path_position = p_encoded_path;
--
CURSOR get_sibling_poskey_csr(p_mc_id IN NUMBER, p_poskey IN NUMBER) IS
SELECT distinct r2.position_key
FROM ahl_mc_relationships r1, ahl_mc_relationships r2, ahl_mc_headers_b hdr
WHERE r1.parent_relationship_id = r2.parent_relationship_id
AND r1.position_key <> r2.position_key
AND r1.position_key = p_poskey
AND r1.mc_header_id = hdr.mc_header_id
AND hdr.mc_id = p_mc_id;
--
CURSOR get_pos_common_id_csr (p_encoded_path IN VARCHAR2, p_size IN NUMBER) IS
SELECT pos.path_pos_common_id
FROM  AHL_MC_PATH_POSITIONS pos
WHERE pos.encoded_path_position like p_encoded_path
AND p_size = (select COUNT(path_position_node_id) from
AHL_MC_PATH_POSITION_NODES where path_position_id = pos.path_position_id);
--
CURSOR get_next_path_pos_id_csr IS
SELECT ahl_mc_path_positions_s.nextval
FROM dual;
--
l_junk         VARCHAR2(1);
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Create_Position_ID';
l_pos_rec          AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
l_position_id      NUMBER;
l_encoded_path     AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
l_position_ref_code     VARCHAR2(30);
l_path_tbl         AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_msg_count    NUMBER;
l_return_val       BOOLEAN;
l_index            NUMBER;
l_sib_pos_ref_code  VARCHAR2(30);
l_poskey           NUMBER;
l_no_ver_path_tbl  AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_common_id        NUMBER;
l_ver_spec_score   NUMBER;
l_count            NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Create_Position_ID_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --initialize ver spec score;
  l_ver_spec_score := 0;
  l_count :=0;

  --Do id validations
  FOR i IN p_path_position_tbl.FIRST..p_path_position_tbl.LAST  LOOP
   l_pos_rec := p_path_position_tbl(i);
   l_path_tbl(i) := l_pos_rec;
   l_no_ver_path_tbl(i) := l_pos_rec;
   l_no_ver_path_tbl(i).version_number := NULL;
   l_count := l_count +1;

   OPEN check_mc_ids_csr(l_pos_rec.mc_id, l_pos_rec.version_number,
             l_pos_rec.position_key);
   FETCH check_mc_ids_csr INTO l_junk;
   IF (check_mc_ids_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_PATH_NODE_INV');
       FND_MESSAGE.Set_Token('MC_ID',l_pos_rec.mc_id);
       FND_MESSAGE.Set_Token('VER',l_pos_rec.version_number);
       FND_MESSAGE.Set_Token('POS_KEY',l_pos_rec.position_key);
       FND_MSG_PUB.ADD;
   END IF;
   CLOSE check_mc_ids_csr;

   IF (l_pos_rec.version_number IS NOT NULL AND
       l_count <= p_path_position_tbl.COUNT ) THEN
     l_ver_spec_score := l_ver_spec_score + POWER(2,(p_path_position_tbl.COUNT-l_count));
   END IF;

   IF (i< p_path_position_tbl.LAST) THEN
     OPEN check_mc_relationships_csr(l_pos_rec.mc_id,
             l_pos_rec.version_number,
             l_pos_rec.position_key,
             p_path_position_tbl(i+1).mc_id,
             p_path_position_tbl(i+1).version_number);
     FETCH check_mc_relationships_csr INTO l_junk;
     IF (check_mc_relationships_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_PATH_RELNSHIP_INV');
       FND_MESSAGE.Set_Token('MC_ID',p_path_position_tbl(i+1).mc_id);
       FND_MESSAGE.Set_Token('VER',p_path_position_tbl(i+1).version_number);
       FND_MESSAGE.Set_Token('POS_KEY',l_pos_rec.position_key);
       FND_MSG_PUB.ADD;
     END IF;
     CLOSE check_mc_relationships_csr;
   END IF;

  END LOOP;

  --Convert the position ref meaning only if position ref code is undefined.
  IF (p_position_ref_code = FND_API.G_MISS_CHAR) THEN
    IF (p_position_ref_meaning = FND_API.G_MISS_CHAR) THEN
       l_position_ref_code := NULL;
    ELSIF (p_position_ref_meaning IS NULL) THEN
       l_position_ref_code := NULL;
    ELSIF (p_position_ref_meaning <> FND_API.G_MISS_CHAR) THEN
       AHL_UTIL_MC_PKG.Convert_To_LookupCode('AHL_POSITION_REFERENCE',
                                           p_position_ref_meaning,
                                           l_position_ref_code,
                                           l_return_val);
       IF NOT(l_return_val) THEN
         FND_MESSAGE.Set_Name('AHL','AHL_MC_POSREF_INVALID');
         FND_MESSAGE.Set_Token('POSREF',p_position_ref_meaning);
         FND_MSG_PUB.ADD;
       END IF;
     END IF;
   ELSE
    l_position_ref_code := p_position_ref_code;
   END IF;

   -- Check Error Message stack.
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   --Convert to find all same level paths
   IF (l_position_ref_code <> FND_API.G_MISS_CHAR AND
       l_position_ref_code IS NOT NULL) THEN
     l_poskey := l_path_tbl(l_path_tbl.LAST).position_key;
     OPEN get_sibling_poskey_csr(l_path_tbl(l_path_tbl.LAST).mc_id,
                l_poskey);
     LOOP
      FETCH get_sibling_poskey_csr INTO l_path_tbl(l_path_tbl.LAST).position_key;
      EXIT WHEN get_sibling_poskey_csr%NOTFOUND;
      l_sib_pos_ref_code := get_posref_by_path(l_path_tbl, FND_API.G_TRUE);
      IF (l_sib_pos_ref_code = l_position_ref_code) THEN
        FND_MESSAGE.Set_Name('AHL','AHL_MC_POSREF_DUPLICATE');
        FND_MESSAGE.Set_Token('POSREF',l_position_ref_code);
        FND_MSG_PUB.ADD;
      END IF;
     END LOOP;
     CLOSE get_sibling_poskey_csr;
   END IF;

   -- Check Error Message stack.
   l_msg_count := FND_MSG_PUB.count_msg;
   IF l_msg_count > 0 THEN
     RAISE  FND_API.G_EXC_ERROR;
   END IF;

   --Encode the path_position_tbl
   l_encoded_path := Encode(p_path_position_tbl);
   l_index :=0;


   --Compare and find matching path_position
   OPEN get_position_id_csr(l_encoded_path);
   FETCH get_position_id_csr INTO x_position_id;
   IF (get_position_id_csr%FOUND) THEN
      IF (l_position_ref_code <> FND_API.G_MISS_CHAR OR
          l_position_ref_code IS NULL) THEN
        UPDATE ahl_mc_path_positions SET
      OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER+1,
          LAST_UPDATE_DATE      = sysdate,
          LAST_UPDATED_BY       = fnd_global.USER_ID,
          LAST_UPDATE_LOGIN     = fnd_global.LOGIN_ID,
      POSITION_REF_CODE     = l_position_ref_code
         WHERE PATH_POSITION_ID = x_position_id;
       END IF;
   ELSE

     OPEN get_next_path_pos_id_csr;
     FETCH get_next_path_pos_id_csr INTO l_position_id;
     CLOSE get_next_path_pos_id_csr;

     --Determine the path_position_common_id
     OPEN get_pos_common_id_csr(Encode(l_no_ver_path_tbl),
                p_path_position_tbl.COUNT);
     FETCH get_pos_common_id_csr INTO l_common_id;
     --If not found, generate new common id
     IF (get_pos_common_id_csr%NOTFOUND OR l_common_id IS NULL) THEN
        l_common_id := l_position_id;
     END IF;
     CLOSE get_pos_common_id_csr;

    --Do inserts
    INSERT INTO ahl_mc_path_positions(
        PATH_POSITION_ID,
        PATH_POS_COMMON_ID,
    OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
    ENCODED_PATH_POSITION,
    POSITION_REF_CODE,
        VER_SPEC_SCORE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
        ) VALUES (
        l_position_id,
        l_common_id,
    1,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        l_encoded_path,
    l_position_ref_code,
        l_ver_spec_score,
    NULL,
    NULL,   NULL,   NULL,   NULL,   NULL,
    NULL,   NULL,   NULL,   NULL,   NULL,
    NULL,   NULL,   NULL,   NULL,   NULL
       )
      RETURNING path_position_id INTO x_position_id;

    --Insert the path position nodes
    FOR i IN p_path_position_tbl.FIRST..p_path_position_tbl.LAST LOOP
     INSERT INTO ahl_mc_path_position_nodes(
        PATH_POSITION_NODE_ID,
    OBJECT_VERSION_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
    PATH_POSITION_ID,
    SEQUENCE,
    MC_ID,
    VERSION_NUMBER,
    POSITION_KEY,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,            ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15
        ) VALUES (
        ahl_mc_path_position_nodes_s.nextval,
    1,
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
    x_position_id,
    l_index,
        p_path_position_tbl(i).mc_id,
    p_path_position_tbl(i).version_number,
    p_path_position_tbl(i).position_key,
    p_path_position_tbl(i).attribute_category ,
    p_path_position_tbl(i).attribute1 ,
    p_path_position_tbl(i).attribute2 ,
    p_path_position_tbl(i).attribute3 ,
    p_path_position_tbl(i).attribute4 ,
    p_path_position_tbl(i).attribute5 ,
    p_path_position_tbl(i).attribute6 ,
    p_path_position_tbl(i).attribute7 ,
    p_path_position_tbl(i).attribute8 ,
    p_path_position_tbl(i).attribute9 ,
    p_path_position_tbl(i).attribute10 ,
    p_path_position_tbl(i).attribute11 ,
    p_path_position_tbl(i).attribute12 ,
    p_path_position_tbl(i).attribute13 ,
    p_path_position_tbl(i).attribute14 ,
    p_path_position_tbl(i).attribute15 );
      l_index := l_index +1;
    END LOOP;
   END IF;
   CLOSE get_position_id_csr;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Create_Position_ID_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Create_Position_ID_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Create_Position_ID_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Create_Position_ID;

-----------------------------
-- Start of Comments --
--  Procedure name    : Map_Instance_To_Positions
--  Type        : Private
--  Function    : Writes a list of positions that maps to instance
--     into AHL_APPLICABLE_INSTANCES
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Instance_To_Positions Parameters:
--       p_csi_item_instance_id  IN NUMBER  Required. instance for the path
--
--  End of Comments.

PROCEDURE Map_Instance_To_Positions (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_csi_item_instance_id   IN         NUMBER)
IS
--
--Fetch the unit and unit header info for instance
CURSOR get_uc_headers_csr (p_csi_instance_id IN NUMBER) IS
SELECT up.parent_mc_id, up.parent_version_number, up.parent_position_key
FROM  ahl_uc_header_paths_v up
WHERE up.csi_instance_id = p_csi_instance_id;
--
CURSOR get_unit_instance_csr  (p_csi_instance_id IN NUMBER) IS
SELECT csi.object_id
  FROM csi_ii_relationships csi
WHERE csi.object_id IN
      ( SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
        WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
START WITH csi.subject_id = p_csi_instance_id
    AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
CONNECT BY csi.subject_id = PRIOR csi.object_id
    AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND CSI.POSITION_REFERENCE IS NOT NULL;
--
--Fetches lowest level info
CURSOR get_last_uc_rec_csr (p_csi_instance_id IN NUMBER) IS
SELECT hdr.mc_id, hdr.version_number, rel.position_key
FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel,
    csi_ii_relationships csi_ii
WHERE csi_ii.subject_id = p_csi_instance_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND TO_NUMBER(CSI_II.POSITION_REFERENCE) = REL.RELATIONSHIP_ID
    AND REL.mc_header_id = HDR.mc_header_id;
--
CURSOR get_top_unit_inst_csr (p_csi_instance_id IN NUMBER) IS
SELECT hdr.mc_id, hdr.version_number, rel.position_key
FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel,
  ahl_unit_config_headers uch, csi_unit_instances_v csi_u
WHERE uch.csi_item_instance_id = p_csi_instance_id
  AND TRUNC(nvl(uch.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
  AND TRUNC(nvl(uch.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  AND hdr.mc_header_id = uch.master_config_id
  AND rel.mc_header_id = hdr.mc_header_id
  AND rel.parent_relationship_id IS NULL
  AND uch.csi_item_instance_id = csi_u.instance_id;

--
--Fetch all encoded path positions like the generated path
CURSOR get_matching_pos_csr (p_encoded_path IN VARCHAR2, p_size IN NUMBER) IS
SELECT pos.path_position_id
FROM  AHL_MC_PATH_POSITIONS pos
WHERE p_encoded_path LIKE pos.encoded_path_position
AND p_size = (select COUNT(path_position_node_id) from
AHL_MC_PATH_POSITION_NODES where path_position_id = pos.path_position_id);
--
l_path_tbl        AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_path_rec        AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
l_index            NUMBER;
l_encoded_path     AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Map_Instance_To_Positions';
l_position_id      NUMBER;
l_unit_csi_id      NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Map_Instance_To_Positions_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --Fetch the position informations for the instance
  OPEN get_last_uc_rec_csr(p_csi_item_instance_id);
  FETCH get_last_uc_rec_csr INTO l_path_rec.mc_id,
                 l_path_rec.version_number,
                 l_path_rec.position_key;
  IF (get_last_uc_rec_csr%NOTFOUND) THEN

    --Fetch the position informations for the unit instance
    OPEN get_top_unit_inst_csr(p_csi_item_instance_id);
    FETCH get_top_unit_inst_csr INTO l_path_rec.mc_id,
                 l_path_rec.version_number,
                 l_path_rec.position_key;
    --Check top node only
    IF (get_top_unit_inst_csr%FOUND) THEN
        --Sunil found the following line was missing and was added on 12/08/2004
        l_path_tbl(1) := l_path_rec;
        --Encode the path_position_tbl
        l_encoded_path := Encode(l_path_tbl);

       OPEN get_matching_pos_csr(l_encoded_path, l_path_tbl.COUNT);
       LOOP
         FETCH get_matching_pos_csr INTO l_position_id;
         EXIT WHEN get_matching_pos_csr%NOTFOUND;
         INSERT INTO AHL_APPLICABLE_INSTANCES (csi_item_instance_id,
                    position_id)
        VALUES (p_csi_item_instance_id, l_position_id);
       END LOOP;
       CLOSE get_matching_pos_csr;

     END IF;
     CLOSE get_top_unit_inst_csr;

   ELSE
     l_path_tbl(1) := l_path_rec;

     --Add positions matching lowest level
     l_encoded_path := Encode(l_path_tbl);

     OPEN get_matching_pos_csr(l_encoded_path, l_path_tbl.COUNT);
     LOOP
         FETCH get_matching_pos_csr INTO l_position_id;
         EXIT WHEN get_matching_pos_csr%NOTFOUND;
         INSERT INTO AHL_APPLICABLE_INSTANCES (csi_item_instance_id,
                    position_id)
        VALUES (p_csi_item_instance_id, l_position_id);
     END LOOP;
     CLOSE get_matching_pos_csr;


    --Now fetch the position paths which match at higher levels.
    l_index := 0;
    --Fetch the header rec info for the instance
    OPEN get_unit_instance_csr(p_csi_item_instance_id);
    LOOP
      FETCH get_unit_instance_csr INTO l_unit_csi_id;
      EXIT WHEN get_unit_instance_csr%NOTFOUND;

      OPEN get_uc_headers_csr(l_unit_csi_id);
      FETCH get_uc_headers_csr INTO l_path_rec.mc_id,
                   l_path_rec.version_number,
                   l_path_rec.position_key;
      CLOSE get_uc_headers_csr;
      IF (l_path_rec.mc_id is not null AND
         l_path_rec.position_key is not null) THEN
       l_path_tbl(l_index) := l_path_rec;
       l_index := l_index - 1;

       --Encode the modified with new params path_position_tbl
       l_encoded_path := Encode(l_path_tbl);

       --dbms_output.put_line (l_encoded_path);

       OPEN get_matching_pos_csr(l_encoded_path, l_path_tbl.COUNT);
       LOOP
        FETCH get_matching_pos_csr INTO l_position_id;
        EXIT WHEN get_matching_pos_csr%NOTFOUND;
        INSERT INTO AHL_APPLICABLE_INSTANCES (csi_item_instance_id,
                    position_id)
        VALUES (p_csi_item_instance_id, l_position_id);
       END LOOP;
       CLOSE get_matching_pos_csr;

      END IF;
   END LOOP;
   CLOSE get_unit_instance_csr;

  END IF;
  CLOSE get_last_uc_rec_csr;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Map_Instance_To_Positions_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Map_Instance_To_Positions_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Map_Instance_To_Positions_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Map_Instance_To_Positions;


-----------------------------
-- Start of Comments --
--  Procedure name    : Map_Position_To_Instance
--  Type        : Private
--  Function    : Writes a list of instances that maps to position path
--into AHL_APPLICABLE_INSTANCES
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Position_To_Instances Parameters:
--       p_position_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Map_Position_To_Instances (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id         IN            NUMBER)
IS
--
--Fetch all the position path information for given position_id
CURSOR get_position_path_csr (p_position_id IN NUMBER) IS
SELECT path.sequence, path.mc_id, path.version_number, path.position_key
FROM  AHL_MC_PATH_POSITION_NODES path
WHERE path.path_position_id = p_position_id
order by sequence;
--
--Determine if position_key maps to top node of the configuration
CURSOR check_pos_key_top_csr(p_mc_id    IN NUMBER,
                 p_ver_num  IN NUMBER,
                 p_position_key IN NUMBER) IS
SELECT 'X'
FROM AHL_MC_RELATIONSHIPS rel, AHL_MC_HEADERS_B HDR
WHERE  HDR.mc_header_id = REL.mc_header_id
  AND REL.parent_relationship_id is NULL
  AND REL.position_key = p_position_key
  AND HDR.mc_id = p_mc_id
  AND HDR.version_number = nvl(p_ver_num, HDR.version_number);

--

l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'map_position_to_instances';
l_full_name        CONSTANT    VARCHAR2(60)    := 'ahl.plsql.' || g_pkg_name || '.' || l_api_name;
l_index            NUMBER;
l_dummy            VARCHAR2(1);
l_top_flag         BOOLEAN;
l_path_tbl         AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_path_rec         AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
v_CursorID         NUMBER;
v_Stmt             VARCHAR2(4000);
v_Select           VARCHAR2(4000);
v_From             VARCHAR2(4000);
v_Where            VARCHAR2(4000);
v_RowsInserted            INTEGER;

--
BEGIN

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.begin','At the start of PLSQL procedure');
  END IF;

  -- Standard start of API savepoint
  SAVEPOINT map_position_to_instances_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_statement,l_full_name,'-- p_position_id --'||p_position_id);
      fnd_log.string(fnd_log.level_statement,l_full_name,'--Populate position path info--');
  END IF;

  l_index :=0;
  --Populate position path info starting at index =0
  OPEN get_position_path_csr(p_position_id);
  LOOP
     FETCH get_position_path_csr INTO l_path_rec.sequence,
                       l_path_rec.mc_id,
                       l_path_rec.version_number,
                       l_path_rec.position_key;
      EXIT WHEN get_position_path_csr%NOTFOUND;
      l_path_tbl(l_index):= l_path_rec;
      l_index := l_index +1;
  END LOOP;
  CLOSE get_position_path_csr;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_statement,l_full_name,'-- Opening Cursor check_pos_key_top_csr --');
  END IF;

  OPEN check_pos_key_top_csr(l_path_tbl(l_path_tbl.LAST).mc_id,
                 l_path_tbl(l_path_tbl.LAST).version_number,
                 l_path_tbl(l_path_tbl.LAST).position_key);
  FETCH check_pos_key_top_csr INTO l_dummy;
  IF (check_pos_key_top_csr%FOUND) THEN
     l_top_flag := true;
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string(fnd_log.level_statement,l_full_name,'-- Set Top FLag to True --');
     END IF;
  ELSE
     l_top_flag := false;
     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
         fnd_log.string(fnd_log.level_statement,l_full_name,'-- Set Top FLag to False --');
     END IF;
  END IF;
  CLOSE check_pos_key_top_csr;


   v_Select := ' SELECT v'||l_path_tbl.LAST||'.csi_instance_id ';
   v_From  := ' FROM AHL_UC_HEADER_PATHS_V v0 ';
   v_Where := ' WHERE  v0.mc_id = :mc_id0 ' ||
          ' AND  v0.mc_version_number = nvl(:ver0,v0.mc_version_number) ';

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_Select --'||v_Select);
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_From -1-'||v_From);
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_Where -1-'||v_Where);
   END IF;

   --Build the dynamic sql statement
   FOR i IN l_path_tbl.FIRST+1..l_path_tbl.LAST  LOOP
       v_From := v_From || ', AHL_UC_HEADER_PATHS_V v'||TO_CHAR(i)||' ';

       -- R12 Dev changes : Modified Function Call to CHECK_POS_REF_PATH_CHAR and
       -- modified where clause join between uc_header_id and parent_uc_header_id

       v_Where := v_Where ||
          ' AND v'||TO_CHAR(i)||'.mc_id = :mc_id'||TO_CHAR(i)||' ' ||
          ' AND  v'||TO_CHAR(i)||'.mc_version_number = '||
          '  nvl(:ver'||TO_CHAR(i)||', v'||TO_CHAR(i)||'.mc_version_number) ' ||
          ' AND v'||TO_CHAR(i-1)||'.uc_header_id = v'||TO_CHAR(i)||'.parent_uc_header_id '
            ||' AND v'||TO_CHAR(i)||'.parent_position_key = :pos_key'||TO_CHAR(i-1)||'  '
            ||' AND AHL_MC_PATH_POSITION_PVT.CHECK_POS_REF_PATH_CHAR(v'||TO_CHAR(i)||'.csi_instance_id, v'||TO_CHAR(i)||'.parent_instance_id) = ''T''  ';

   END LOOP;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_From -2-'||v_From);
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_Where -2-'||v_Where);
   END IF;

  IF (l_top_flag) THEN
   v_Stmt := 'INSERT INTO AHL_APPLICABLE_INSTANCES '||
         ' SELECT uch.csi_instance_id ,'|| p_position_id ||
         ' FROM AHL_UC_HEADER_PATHS_V uch '||
         ' WHERE uch.position_key = :pos_key'||l_path_tbl.LAST
       ||' AND uch.csi_instance_id in ( '
           || v_Select || v_From || v_Where || ' ) ';

  ELSE
   v_Stmt := 'INSERT INTO AHL_APPLICABLE_INSTANCES '||
         ' SELECT csi_ii.subject_id ,'|| p_position_id ||
         ' FROM ahl_mc_relationships rel, csi_ii_relationships csi_ii '||
         ' WHERE TO_NUMBER(CSI_II.POSITION_REFERENCE)=REL.RELATIONSHIP_ID '
           ||' AND REL.position_key = :pos_key'||l_path_tbl.LAST
       ||' START WITH csi_ii.object_id IN ( '
           || v_Select || v_From || v_Where || ' ) '
           || ' CONNECT BY PRIOR csi_ii.subject_id = csi_ii.object_id '
           ||' AND CSI_II.RELATIONSHIP_TYPE_CODE  = ''COMPONENT-OF'' '
       ||' AND CSI_II.POSITION_REFERENCE IS NOT NULL '
           ||' AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate) '
           ||' AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate) ';

   END IF;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_Stmt --'||v_Stmt);
   END IF;

   /*for i in 0..(length(v_Stmt)/255) LOOP
     dbms_output.put_line(substr(v_Stmt,i*255,255));
   end loop;
   */
   ----------------------------------------
   --Due to performance considerations, doing dynamic sql
   --------------------------------------
   v_CursorID := DBMS_SQL.OPEN_CURSOR;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- Parsing Sql --');
   END IF;

   DBMS_SQL.PARSE(v_CursorID, v_Stmt, DBMS_SQL.V7);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- Binding Params Sql --');
   END IF;

   --Bind the dynamic sql statement
   FOR i IN l_path_tbl.FIRST..l_path_tbl.LAST  LOOP
       DBMS_SQL.BIND_VARIABLE (v_CursorID, ':mc_id'||i, l_path_tbl(i).mc_id);
       DBMS_SQL.BIND_VARIABLE (v_CursorID, ':ver'||i, l_path_tbl(i).version_number);
       DBMS_SQL.BIND_VARIABLE (v_CursorID, ':pos_key'||i, l_path_tbl(i).position_key);
   END LOOP;

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- After Binding - Before Executing Sql --');
   END IF;

   --Execute the dynamic sql
   v_RowsInserted := DBMS_SQL.EXECUTE(v_CursorID);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- After Executing Sql --');
       fnd_log.string(fnd_log.level_statement,l_full_name,'-- v_RowsInserted --'||v_RowsInserted);
   END IF;

   DBMS_SQL.CLOSE_CURSOR(v_CursorID);

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure,L_FULL_NAME||'.end','At the end of PLSQL procedure');
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to map_position_to_instances_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to map_position_to_instances_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to map_position_to_instances_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Map_Position_To_Instances;

-----------------------------
-- Start of Comments --
--  Procedure name    : Get_Pos_Instance
--  Type        : Private
--  Function    : Returns the instance that maps to position path
--  Pre-reqs    :
--  Parameters  :
--
--  Get_Pos_Instance Parameters:
--       p_position_id      IN  NUMBER  Required
--       p_csi_item_instance_id  IN NUMBER  Required starting instance
--
--     x_item_instance_id the instance that the position_id + instance maps to
--            Returns the parent instance_id if the position is empty
--     x_relationship_id  returns the position relationship id for empty positions
--     x_lowest_uc_csi_id returns the leaf level UC id
--      x_mapping_status OUT VARCHAR2 Returns either NA (Not applicable),
--         EMPTY (Empty position) or MATCH (if matching instance found)
--  End of Comments.

PROCEDURE Get_Pos_Instance (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id        IN            NUMBER,
    p_csi_item_instance_id   IN         NUMBER,
    x_parent_instance_id  OUT NOCOPY   NUMBER,
    x_item_instance_id   OUT  NOCOPY    NUMBER,
    x_relationship_id      OUT NOCOPY     NUMBER,
    x_lowest_uc_csi_id       OUT NOCOPY     NUMBER,
    x_mapping_status     OUT NOCOPY     VARCHAR2)
IS
--
--Step 0) Check instance is defined in uc headers
CURSOR check_instance_top_csr(p_instance_id IN NUMBER) IS
SELECT 'X'
FROM  AHL_UNIT_CONFIG_HEADERS uch
WHERE uch.csi_item_instance_id = p_instance_id;

--
--Step 1) Build the path Position table object
--Fetch all the position path information for given position_id
CURSOR get_position_path_csr (p_position_id IN NUMBER) IS
SELECT path.sequence, path.mc_id, path.version_number, path.position_key
FROM  AHL_MC_PATH_POSITION_NODES path
WHERE path.path_position_id = p_position_id
order by sequence;

--
--Step 2a) Validate if the top instance matches the
-- initial path position mc_id and version number (mc_header_id)
CURSOR check_top_mc_csr (p_csi_ii_id IN NUMBER, p_mc_id IN NUMBER,
            p_ver_num IN NUMBER) IS
SELECT 'X'
FROM AHL_MC_HEADERS_B hdr, AHL_UNIT_CONFIG_HEADERS uch
WHERE uch.csi_item_instance_id = p_csi_ii_id
  AND uch.master_config_id = hdr.mc_header_id
  AND HDR.mc_id = p_mc_id
  AND HDR.version_number = nvl(p_ver_num, HDR.version_number);

--Step 2b) Fetch the subunit tree for given unit.
CURSOR get_subunit_csi_id_csr (p_start_csi_ii_id IN NUMBER,
               p_parent_pos_key IN NUMBER,
               p_child_mc_id  IN NUMBER,
               p_child_mc_ver_num IN NUMBER) IS
SELECT csi_instance_id
FROM  AHL_UC_HEADER_PATHS_V
WHERE parent_instance_id = p_start_csi_ii_id
AND parent_position_key = p_parent_pos_key
AND mc_id = p_child_mc_id
AND mc_version_number = nvl(p_child_mc_ver_num, mc_version_number);

--
--Step 3a) Derive the instance that maps to unit or subunit
--Fetch the final csi id given starting subunit. Could be subunit
-- top node or a subnode.
CURSOR get_last_csi_id_csr (p_lowest_uc_ii_id IN NUMBER,
                            p_position_key IN NUMBER) IS
SELECT csi_ii.subject_id, csi_ii.object_id, TO_NUMBER(csi_ii.position_reference)
FROM csi_ii_relationships csi_ii
WHERE  TO_NUMBER(CSI_II.POSITION_REFERENCE) in (select REL.RELATIONSHIP_ID
                                                  from ahl_mc_relationships rel
                                                 where REL.position_key = p_position_key)
START WITH csi_ii.object_id = p_lowest_uc_ii_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
--Jerry 03/03/2005 Added the following  condition for fixing bug 4090856
    AND CSI_II.POSITION_REFERENCE IS NOT NULL
CONNECT BY PRIOR csi_ii.subject_id = csi_ii.object_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND CSI_II.POSITION_REFERENCE IS NOT NULL
 UNION ALL
SELECT uch.csi_item_instance_id, csi_ii.object_id, TO_NUMBER(csi_ii.position_reference)
FROM AHL_MC_RELATIONSHIPS rel, AHL_UNIT_CONFIG_HEADERS UCH, CSI_II_RELATIONSHIPS csi_ii
WHERE  UCH.master_config_id = REL.mc_header_id
  AND REL.parent_relationship_id is NULL
  AND REL.position_key = p_position_key
  AND uch.csi_item_instance_id = p_lowest_uc_ii_id
  AND uch.csi_item_instance_id  = csi_ii.subject_id (+)
  AND CSI_II.RELATIONSHIP_TYPE_CODE (+) = 'COMPONENT-OF'
-- Changed by jaramana on July 13, 2006 to fix FP of bug 5368714
-- Make the active start date and active end date clauses also to be outer joins
--  AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
--  AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate);
  AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE(+), sysdate)) <= TRUNC(sysdate)
  AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE(+), sysdate+1)) > TRUNC(sysdate);

--Step 4)
--Get the parent relationship information for empty node search
CURSOR get_parent_poskey_csr (p_mc_id IN NUMBER,
                                       p_version_number IN NUMBER,
                                       p_position_key IN NUMBER)
IS
SELECT rel.relationship_id, prel.position_key
FROM AHL_MC_RELATIONSHIPS rel, AHL_MC_HEADERS_B hdr, AHL_MC_RELATIONSHIPS prel
WHERE prel.relationship_id = rel.parent_relationship_id
AND rel.position_key = p_position_key
AND hdr.mc_header_id = rel.mc_header_id
AND hdr.mc_id = p_mc_id
AND hdr.version_number = nvl(p_version_number, hdr.version_number)
ORDER BY hdr.version_number desc;

--
--Step 5) Check that the path from instance to top has position key each step
-- and that position key is not null for all relnships.
CURSOR check_pos_ref_csr (p_csi_instance_id IN NUMBER,
              p_to_csi_instance_id IN NUMBER) IS
SELECT 'X'
FROM csi_ii_relationships csi_ii
WHERE csi_ii.object_id = p_to_csi_instance_id
START WITH csi_ii.subject_id = p_csi_instance_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
--Jerry 03/03/2005 Added the following  condition for fixing bug 4090856
    AND CSI_II.POSITION_REFERENCE IS NOT NULL
CONNECT BY csi_ii.subject_id = PRIOR csi_ii.object_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND CSI_II.POSITION_REFERENCE IS NOT NULL;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Get_Pos_Instance';
l_csi_ii_id        NUMBER;
l_index            NUMBER;
l_path_tbl         AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_path_rec         AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
l_dummy            VARCHAR2(1);
l_dummy_id         NUMBER;
l_top_flag         BOOLEAN;
l_found_flag       BOOLEAN;
l_child_rel_id     NUMBER;
l_parent_pos_key    NUMBER;
l_full_name        CONSTANT    VARCHAR2(60)    := 'ahl.plsql.' || g_pkg_name || '.' || l_api_name;

--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_Pos_Empty_Instance_pvt;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
    fnd_log.string(fnd_log.level_procedure, l_full_name||'.begin', 'At the start of PLSQL procedure. p_csi_item_instance_id = ' || p_csi_item_instance_id ||
                                                                   ', p_position_id = ' || p_position_id);
  END IF;
  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_mapping_status := 'NULL';

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --Step 0) Validate that p_csi_item_instance is not null and valid
  IF (p_csi_item_instance_id IS NULL) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_POS_INSTANCE_ID_NULL');
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  --Validate that the input instance is a unit
  OPEN check_instance_top_csr (p_csi_item_instance_id);
  FETCH check_instance_top_csr INTO l_dummy;
  IF (check_instance_top_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_POS_INSTANCE_ID_INV');
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_instance_top_csr;

  --Step 1) Build the path position table object based on path position id
  l_index :=0;
  OPEN get_position_path_csr(p_position_id);
  LOOP
      FETCH get_position_path_csr INTO l_path_rec.sequence,
                       l_path_rec.mc_id,
                       l_path_rec.version_number,
                       l_path_rec.position_key;
      EXIT WHEN get_position_path_csr%NOTFOUND;
      l_path_tbl(l_index):= l_path_rec;
      l_index := l_index +1;
  END LOOP;
  CLOSE get_position_path_csr;

  --Step 2) Traverse the table if there are multiple levels.
  -- Populate the lowest level instance id based on this query.
  --If table is less than 1 in size, this is invalid path
  IF (l_path_tbl.COUNT<1) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_POS_PATH_ID_INV');
       FND_MSG_PUB.ADD;
       RAISE  FND_API.G_EXC_ERROR;

  --If there is only 1 row, then lowest level UC = p_csi_instance_id
  ELSIF (l_path_tbl.COUNT =1) THEN
    OPEN check_top_mc_csr ( p_csi_item_instance_id,
               l_path_tbl(l_path_tbl.FIRST).mc_id,
               l_path_tbl(l_path_tbl.FIRST).version_number);
    FETCH check_top_mc_csr INTO l_dummy;
    IF (check_top_mc_csr%FOUND) THEN
       x_lowest_uc_csi_id := p_csi_item_instance_id;
    ELSE
       x_mapping_status := 'NA';
    END IF;
    CLOSE check_top_mc_csr;

  --If there are multiple rows, then need to verify multiple levels.
  ELSE
    l_csi_ii_id := p_csi_item_instance_id;
    OPEN check_top_mc_csr (l_csi_ii_id,
               l_path_tbl(l_path_tbl.FIRST).mc_id,
               l_path_tbl(l_path_tbl.FIRST).version_number);
    FETCH check_top_mc_csr INTO l_dummy;

    --If the top mc and top instance are valid match
    IF (check_top_mc_csr%FOUND) THEN
      l_found_flag := true;
      --Traverse down the path tree.Starting with the 1st subconfig. since
      -- top config is not relevant for traversal..
      FOR i IN l_path_tbl.FIRST+1..l_path_tbl.LAST  LOOP
         OPEN get_subunit_csi_id_csr(l_csi_ii_id,
                   l_path_tbl(i-1).position_key,
                   l_path_tbl(i).mc_id,
                   l_path_tbl(i).version_number);
         FETCH get_subunit_csi_id_csr INTO l_csi_ii_id;
         IF (get_subunit_csi_id_csr%NOTFOUND) THEN
             l_found_flag := false;
             CLOSE get_subunit_csi_id_csr;
             EXIT;
         END IF;
         CLOSE get_subunit_csi_id_csr;
      END LOOP;

      --If l_found_flag Meaning all MCs  are correct in traversal down MC path.
      IF (l_found_flag ) THEN
         x_lowest_uc_csi_id := l_csi_ii_id;
      ELSE
         x_mapping_status := 'NA';
      END IF;
    ELSE
      l_found_flag := false;
      x_mapping_status := 'NA';
    END IF;
    CLOSE check_top_mc_csr;
   END IF;

  --Step 3) If we are able to derive the lowest Unit
  IF (x_lowest_uc_csi_id IS NOT NULL
    AND nvl(x_mapping_status,'NULL') <>'NA') THEN
     --Fetch the child instance that matches
     OPEN get_last_csi_id_csr (x_lowest_uc_csi_id,
                               l_path_tbl(l_path_tbl.LAST).position_key);
     FETCH get_last_csi_id_csr INTO x_item_instance_id,
                                    x_parent_instance_id,
                                    x_relationship_id;
     IF (get_last_csi_id_csr%FOUND) THEN
         x_mapping_status := 'MATCH';
     ELSE
         x_mapping_status := 'EMPTY';
     END IF;
     CLOSE get_last_csi_id_csr;

     IF (x_mapping_status ='EMPTY') THEN
         --Step 4) Do the empty position parent instance + relationship_id search
         --For empty position try to find parent instance's position key
         OPEN get_parent_poskey_csr (l_path_tbl(l_path_tbl.LAST).mc_id,
                                             l_path_tbl(l_path_tbl.LAST).version_number,
                                             l_path_tbl(l_path_tbl.LAST).position_key);
         FETCH get_parent_poskey_csr INTO l_child_rel_id, l_parent_pos_key;

         --If parent instance is found, try to map it to an instance.
         IF (get_parent_poskey_csr%FOUND) THEN
            --map the parent position key to an instance in the lowest unit
            OPEN get_last_csi_id_csr (x_lowest_uc_csi_id, l_parent_pos_key);
            FETCH get_last_csi_id_csr INTO x_parent_instance_id,
                                           l_dummy_id,
                                           l_dummy_id;

            --Check if parent instance is found or not.
            IF (get_last_csi_id_csr%FOUND) THEN
                   x_mapping_status := 'EMPTY';
                   x_item_instance_id := null;
                   x_relationship_id := l_child_rel_id;
            ELSE
                    --Parent position has no matching instance. Position not considered empty
                    x_mapping_status := 'PARENT_EMPTY';
            END IF;
            CLOSE get_last_csi_id_csr;

         ELSE
               --parent position is not defined. This is not correct.
               x_mapping_status := 'NA';
         END IF;
         CLOSE get_parent_poskey_csr;
        END IF;
      END IF;  --If empty

      --Step 5) Check the position reference is valid for entire path
      IF (x_item_instance_id <> p_csi_item_instance_id) THEN
        OPEN check_pos_ref_csr (x_item_instance_id,
            p_csi_item_instance_id);
        FETCH check_pos_ref_csr INTO l_dummy;
        IF (check_pos_ref_csr%NOTFOUND) THEN
              x_item_instance_id:= null;
              x_mapping_status := 'NA';
        END IF;
        CLOSE check_pos_ref_csr;
      END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name||'.end', 'At the end of PLSQL procedure. About to count and get error messages.');
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Get_Pos_Empty_Instance_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Get_Pos_Empty_Instance_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Get_Pos_Empty_Instance_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Get_Pos_Instance;

----------------------------
-- Start of Comments --
--  Procedure name    : Get_Pos_Instance
--  Type        : Private
--  Function    : Returns the instance that maps to position path
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Position_To_Instances Parameters:
--       p_position_id      IN  NUMBER  Required
--       p_csi_item_instance_id  IN NUMBER  Required starting instance
--
--     x_item_instance_id the instance that the position_id + instance maps to
--     x_lowest_uc_csi_id returns the leaf level UC id
--      x_mapping_status OUT VARCHAR2 Returns either NA (Not applicable),
--         EMPTY (Empty position) or MATCH (if matching instance found)
--  End of Comments.

PROCEDURE Get_Pos_Instance (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id        IN            NUMBER,
    p_csi_item_instance_id   IN         NUMBER,
    x_item_instance_id   OUT  NOCOPY    NUMBER,
    x_lowest_uc_csi_id       OUT NOCOPY     NUMBER,
    x_mapping_status     OUT  NOCOPY     VARCHAR2)
IS
--
l_instance_id NUMBER;
l_relationship_id NUMBER;
l_parent_instance_id   NUMBER;
--
BEGIN

 Get_Pos_Instance (
        p_api_version       => 1.0,
        p_position_id          => p_position_id,
        p_csi_item_instance_id  => p_csi_item_instance_id,
        x_parent_instance_id   => l_parent_instance_id,
        x_item_instance_id     => l_instance_id,
        x_relationship_id     => l_relationship_id,
        x_lowest_uc_csi_id    => x_lowest_uc_csi_id,
        x_mapping_status      => x_mapping_status,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);

  --Remaps the instance to null or no match
  IF (x_mapping_status <> 'MATCH') THEN
    x_item_instance_id := null;

    --Remap the PARENT_EMPTY status to NA. Bad code due to need of extra type in
    --overloaded Get_Pos_Instance method
    IF (x_mapping_status = 'PARENT_EMPTY') THEN
      x_mapping_status := 'NA';
    END IF;
  ELSE
    x_item_instance_id := l_instance_id;
  END IF;

END Get_Pos_Instance;



-----------------------------
-- Start of Comments --
--  Procedure name    : Copy_Positions_For_MC
--  Type        : Private
--  Function    : Copies all path positions for 1 MC to another MC
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Positions_For_MC Parameters:
--       p_from_mc_header_id      IN  NUMBER  Required
--   p_to_mc_header_id    IN NUMBER   Required
--
--  End of Comments.

PROCEDURE Copy_Positions_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_from_mc_header_id       IN           NUMBER,
    p_to_mc_header_id         IN           NUMBER)
IS
--
CURSOR check_mc_status_csr (p_header_id  IN  NUMBER) IS
   SELECT  header.config_status_code, header.config_status_meaning
     FROM    ahl_mc_headers_v header
     WHERE  header.mc_header_id = p_header_id;
--
CURSOR get_mc_id_csr (p_mc_header_id  IN  NUMBER) IS
   SELECT  mc_id
     FROM    ahl_mc_headers_b
     WHERE  mc_header_id = p_mc_header_id;
--
CURSOR get_ver_position_ids_csr (p_header_id  IN  NUMBER) IS
   SELECT  pnodes.path_position_id
     FROM   ahl_mc_path_position_nodes pnodes, ahl_mc_headers_b hdr
     WHERE  pnodes.sequence = 0
     AND    pnodes.mc_id = hdr.mc_id
     AND    pnodes.version_number = hdr.version_number
     AND    hdr.mc_header_id = p_header_id;
--
CURSOR get_nover_position_ids_csr(p_header_id IN NUMBER) IS
   SELECT  pnodes.path_position_id
     FROM   ahl_mc_path_position_nodes pnodes, ahl_mc_headers_b hdr
     WHERE  pnodes.sequence = 0
     AND    pnodes.mc_id = hdr.mc_id
     AND    pnodes.version_number IS NULL
     AND    hdr.mc_header_id = p_header_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Copy_Positions_For_Mc';
l_from_mc_id       NUMBER;
l_to_mc_id         NUMBER;
l_status_code      VARCHAR2(30);
l_status           VARCHAR2(80);
l_position_id      NUMBER;
l_new_position_id  NUMBER;
l_msg_count        NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Copy_Positions_For_Mc_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --Check Status of MC allows for editing
  OPEN check_mc_status_csr(p_to_mc_header_id);
  FETCH check_mc_status_csr INTO l_status_code, l_status;
  IF (check_mc_status_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_UC_MC_HEADER_ID_INVALID');
       FND_MESSAGE.Set_Token('MC_HEADER_ID',p_to_mc_header_id);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  ELSIF ( l_status_code <> 'DRAFT' AND
      l_status_code <> 'APPROVAL_REJECTED') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_EDIT_INV_MC');
       FND_MESSAGE.Set_Token('STATUS', l_status);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mc_status_csr;

  --Copy all version specific paths
  OPEN get_ver_position_ids_csr(p_from_mc_header_id);
  LOOP
     FETCH get_ver_position_ids_csr INTO l_position_id;
     EXIT WHEN get_ver_position_ids_csr%NOTFOUND;

     Copy_Position (
            p_api_version       => 1.0,
        p_commit            => FND_API.G_FALSE,
            p_position_id       =>   l_position_id,
            p_to_mc_header_id   => p_to_mc_header_id,
            x_position_id       => l_new_position_id,
        x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);
    -- Check return status.
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;
  CLOSE get_ver_position_ids_csr;

  OPEN get_mc_id_csr(p_to_mc_header_id);
  FETCH get_mc_id_csr INTO l_to_mc_id;
  CLOSE get_mc_id_csr;

  OPEN get_mc_id_csr(p_from_mc_header_id);
  FETCH get_mc_id_csr INTO l_from_mc_id;
  CLOSE get_mc_id_csr;

  IF (l_to_mc_id <> l_from_mc_id) THEN
    --Copy the non version specific paths as well
    OPEN get_nover_position_ids_csr(p_from_mc_header_id);
    LOOP
       FETCH get_nover_position_ids_csr INTO l_position_id;
       EXIT WHEN get_nover_position_ids_csr%NOTFOUND;

       Copy_Position (
            p_api_version       => 1.0,
        p_commit            => FND_API.G_FALSE,
            p_position_id       =>   l_position_id,
            p_to_mc_header_id   => p_to_mc_header_id,
            x_position_id       => l_new_position_id,
        x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);
     -- Check return status.
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END LOOP;
   CLOSE get_nover_position_ids_csr;
  END IF;

   -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Copy_Positions_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Copy_Positions_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Copy_Positions_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Copy_Positions_For_MC;

-----------------------------
-- Start of Comments --
--  Procedure name    : Copy_Position
--  Type        : Private
--  Function    : Copies 1 path positions to 1 MC
--  Pre-reqs    :
--  Parameters  :
--
--  Copy_Position
--       p_position_id      IN  NUMBER  Required
--   p_to_mc_header_id    IN NUMBER   Required
--   x_positioN_id       OUT NUMBER
--
--  End of Comments.

PROCEDURE Copy_Position (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_position_id         IN           NUMBER,
    p_to_mc_header_id         IN           NUMBER,
    x_position_id         OUT  NOCOPY    NUMBER)
IS
--
CURSOR get_mc_id_ver_csr (p_mc_header_id  IN  NUMBER) IS
   SELECT  mc_id, version_number
     FROM    ahl_mc_headers_b
     WHERE  mc_header_id = p_mc_header_id;
--
CURSOR get_mc_path_position_nodes_csr (p_position_id  IN  NUMBER) IS
   SELECT  *
     FROM   ahl_mc_path_position_nodes
    WHERE  path_position_id = p_position_id
     order by sequence;
--
CURSOR get_path_position_ref_csr (p_position_id  IN  NUMBER) IS
   SELECT  position_ref_code
     FROM   ahl_mc_path_positions
    WHERE  path_position_id = p_position_id;
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Copy_Position';
l_position_node    get_mc_path_position_nodes_csr%ROWTYPE;
l_pos_tbl          AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_pos_rec          AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
l_mc_id            NUMBER;
l_version_number   NUMBER;
l_pos_ref_code     VARCHAR2(30);
l_index       NUMBER;
l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       varchar2(2000);
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Copy_Position_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --Fetch the to mc_header_id information
  OPEN get_mc_id_ver_csr(p_to_mc_header_id);
  FETCH get_mc_id_ver_csr INTO l_mc_id, l_version_number;
  IF (get_mc_id_ver_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_HEADER_ID_INVALID');
       FND_MESSAGE.Set_Token('NAME','');
       FND_MESSAGE.Set_Token('MC_HEADER_ID',p_to_mc_header_id);
       FND_MSG_PUB.ADD;
       CLOSE get_mc_id_ver_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE get_mc_id_ver_csr;

  --Fetch the position path information
  l_index:=0;
  OPEN get_mc_path_position_nodes_csr(p_position_id);
  LOOP
     FETCH get_mc_path_position_nodes_csr INTO l_position_node;
     EXIT WHEN get_mc_path_position_nodes_csr%NOTFOUND;

     --Copy to our table record
     IF (l_position_node.sequence = 0) THEN
    l_pos_rec.mc_id := l_mc_id;
        IF (l_position_node.version_number IS NOT NULL) THEN
          l_pos_rec.version_number := l_version_number;
    ELSE
          l_pos_rec.version_number := NULL;
        END IF;
     ELSE
        l_pos_rec.mc_id := l_position_node.mc_id;
        l_pos_rec.version_number := l_position_node.version_number  ;
     END IF;

     l_pos_rec.position_key := l_position_node.position_key  ;
     l_pos_rec.attribute_category  := l_position_node.attribute_category  ;
     l_pos_rec.attribute1  := l_position_node.attribute1  ;
     l_pos_rec.attribute2  := l_position_node.attribute2  ;
     l_pos_rec.attribute3  := l_position_node.attribute3  ;
     l_pos_rec.attribute4  := l_position_node.attribute4  ;
     l_pos_rec.attribute5  := l_position_node.attribute5  ;
     l_pos_rec.attribute6  := l_position_node.attribute6  ;
     l_pos_rec.attribute7  := l_position_node.attribute7  ;
     l_pos_rec.attribute8  := l_position_node.attribute8  ;
     l_pos_rec.attribute9  := l_position_node.attribute9  ;
     l_pos_rec.attribute10  := l_position_node.attribute10  ;
     l_pos_rec.attribute11  := l_position_node.attribute11  ;
     l_pos_rec.attribute12  := l_position_node.attribute12  ;
     l_pos_rec.attribute13  := l_position_node.attribute13  ;
     l_pos_rec.attribute14  := l_position_node.attribute14  ;
     l_pos_rec.attribute15 := l_position_node.attribute15  ;
     l_pos_tbl(l_index) := l_pos_rec;
     l_index:= l_index+1;

  END LOOP;
  CLOSE get_mc_path_position_nodes_csr;

  OPEN get_path_position_ref_csr(p_position_id);
  FETCH get_path_position_ref_csr INTO l_pos_ref_code;
  CLOSE get_path_position_ref_csr;

  -- Check Error Message stack.
  x_msg_count := FND_MSG_PUB.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  --Create position with new error message stack.
  --This stack will not be useful
  Create_Position_ID (
            p_api_version       => 1.0,
                p_init_msg_list     => FND_API.G_TRUE,
        p_commit            => FND_API.G_FALSE,
            p_path_position_tbl     =>   l_pos_tbl,
            p_position_ref_meaning  => FND_API.G_MISS_CHAR,
            p_position_ref_code    => l_pos_ref_code,
        x_position_id         => x_position_id,
        x_return_status       => l_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data);

  -- Suppress the validation errors from Create API.
  IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    --Suppress the expected errors
    --Clean out the messages
    FND_MSG_PUB.Initialize;
    x_position_id := null;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := 0;
    x_msg_data := null;
  ELSE
   --Use normal error handling
   x_return_status := l_return_status;
   x_msg_count := l_msg_count;
   x_msg_data := l_msg_data;
  END IF;

  -- Check return status.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Copy_Position_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Copy_Position_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Copy_Position_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Copy_Position;

-----------------------------
-- Start of Comments --
--  Procedure name    : Delete_Positions_For_MC
--  Type        : Private
--  Function    : Deletes the Positions corresponding to 1 MC
--  Pre-reqs    :
--  Parameters  :
--
--  Delete_Positions_For_MC Parameters:
--       p_mc_header_id      IN  NUMBER  Required
--
--  End of Comments.

PROCEDURE Delete_Positions_For_MC (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
  p_mc_header_id      IN           NUMBER)
IS
--
CURSOR check_mc_status_csr (p_header_id  IN  NUMBER) IS
   SELECT  config_status_code, config_status_meaning
     FROM    ahl_mc_headers_v header
     WHERE  header.mc_header_id = p_header_id;
--
CURSOR get_num_of_version_csr (p_header_id  IN  NUMBER) IS
   SELECT  count(*)
     FROM    ahl_mc_headers_b header
     WHERE  header.mc_id = (select mc_id FROM ahl_mc_headers_b
    where mc_header_id = p_header_id);
--
--Fetch all version specific path positions
CURSOR get_ver_position_ids_csr (p_mc_header_id IN NUMBER) IS
SELECT path.path_position_id
FROM  AHL_MC_PATH_POSITION_NODES path, AHL_MC_HEADERS_B headers
WHERE path.MC_ID = headers.mc_id
AND  path.sequence = 0
AND  path.version_number = headers.version_number
AND  headers.mc_header_id = p_mc_header_id;
--
--Fetch all non-version specific path positions
CURSOR get_nover_position_ids_csr (p_mc_header_id IN NUMBER) IS
SELECT path.path_position_id
FROM  AHL_MC_PATH_POSITION_NODES path, AHL_MC_HEADERS_B headers
WHERE path.MC_ID = headers.mc_id
AND  path.sequence = 0
AND  path.version_number IS NULL
AND  headers.mc_header_id = p_mc_header_id;
--
--Fetch all version specific path positions
CURSOR check_posid_in_rstmts_csr (p_position_id IN NUMBER) IS
SELECT 'X'
FROM  AHL_MC_RULE_STATEMENTS
WHERE (subject_ID = p_position_id
AND  subject_type = 'POSITION')
OR (object_id = p_position_id
 AND (object_type = 'ITEM_AS_POSITION'
    OR object_type = 'CONFIG_AS_POSITION'));
--
--
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Delete_Positions_For_Mc';
l_position_id      NUMBER;
l_junk         VARCHAR2(1);
l_status_code      VARCHAR2(30);
l_status           VARCHAR2(80);
l_num_of_version  NUMBER;
--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Delete_Positions_For_Mc_pvt;

  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

   --Check Status of MC allows for editing
  OPEN check_mc_status_csr(p_mc_header_id);
  FETCH check_mc_status_csr INTO l_status_code, l_status;
  IF (check_mc_status_csr%NOTFOUND) THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_HEADER_ID_INVALID');
       FND_MESSAGE.Set_Token('NAME','');
       FND_MESSAGE.Set_Token('MC_HEADER_ID',p_mc_header_id);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  ELSIF ( l_status_code <> 'DRAFT' AND
      l_status_code <> 'APPROVAL_REJECTED') THEN
       FND_MESSAGE.Set_Name('AHL','AHL_MC_EDIT_INV_MC');
       FND_MESSAGE.Set_Token('STATUS', l_status);
       FND_MSG_PUB.ADD;
       CLOSE check_mc_status_csr;
       RAISE  FND_API.G_EXC_ERROR;
  END IF;
  CLOSE check_mc_status_csr;

  --Delete version specific positions
  OPEN get_ver_position_ids_csr(p_mc_header_id);
  LOOP
     FETCH get_ver_position_ids_csr INTO l_position_id;
     EXIT WHEN get_ver_position_ids_csr%NOTFOUND;

     --Validate position_id is not used in other tables.
     --Only need to validate MC rules since other paths are only in
     -- complete MCs, which can not delete position paths or rules.
     OPEN check_posid_in_rstmts_csr(l_position_id);
     FETCH check_posid_in_rstmts_csr INTO l_junk;
     IF (check_posid_in_rstmts_csr%NOTFOUND) THEN

      --Delete the position_id
      DELETE FROM AHL_MC_PATH_POSITION_NODES
       WHERE path_position_id = l_position_id;

      DELETE FROM AHL_MC_PATH_POSITIONS
       WHERE path_position_id = l_position_id;
     END IF;
     CLOSE check_posid_in_rstmts_csr;

  END LOOP;
  CLOSE get_ver_position_ids_csr;

  --Delete non-version specific positions
  OPEN get_num_of_version_csr(p_mc_header_id);
  FETCH get_num_of_version_csr INTO l_num_of_version;
  CLOSE get_num_of_version_csr;

  IF (l_num_of_version = 1) THEN
   OPEN get_nover_position_ids_csr(p_mc_header_id);
   LOOP
     FETCH get_nover_position_ids_csr INTO l_position_id;
     EXIT WHEN get_nover_position_ids_csr%NOTFOUND;

     --Validate position_id is not used in other tables.
     --Only need to validate MC rules since other paths are only in
     -- complete MCs, which can not delete position paths or rules.
     OPEN check_posid_in_rstmts_csr(l_position_id);
     FETCH check_posid_in_rstmts_csr INTO l_junk;
     IF (check_posid_in_rstmts_csr%NOTFOUND) THEN

       --Delete the position_id
       DELETE FROM AHL_MC_PATH_POSITION_NODES
        WHERE path_position_id = l_position_id;

       DELETE FROM AHL_MC_PATH_POSITIONS
        WHERE path_position_id = l_position_id;

     END IF;
     CLOSE check_posid_in_rstmts_csr;

   END LOOP;
   CLOSE get_nover_position_ids_csr;
  END IF;

  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Delete_Positions_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Delete_Positions_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Delete_Positions_For_Mc_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
END Delete_Positions_For_MC;


---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_posref_by_id
--  Type        : Private
--  Function    : Fetches the position path position ref code
--  Pre-reqs    :
--  Parameters  :
--
--  get_position_ref_code Parameters:
--       p_position_id IN NUMBER the path position id
--       p_code_flag IN VARHCAR2 If Equal to FND_API.G_TRUE, then return
-- pos ref code, else return pos ref meaning. Default to False.
--
FUNCTION get_posref_by_id(
   p_path_position_ID    IN  NUMBER,
   p_code_flag           IN  VARCHAR2 := FND_API.G_FALSE)
RETURN VARCHAR2  -- Position Ref Code or Meaning
IS
--
CURSOR get_pos_ref_csr (p_position_id IN NUMBER) IS
SELECT position_ref_code
FROM  AHL_MC_PATH_POSITIONS
WHERE path_position_id = p_position_id;
--
--Select the default position reference.
CURSOR get_def_pos_ref_csr (p_position_id IN NUMBER) IS
SELECT rel.position_ref_code
FROM  AHL_MC_HEADERS_B hd, AHL_MC_RELATIONSHIPS rel,
      AHL_MC_PATH_POSITION_NODES pnodes
WHERE hd.mc_header_id = rel.mc_header_id
AND  rel.position_key = pnodes.position_key
AND  hd.mc_id = pnodes.mc_id
AND pnodes.sequence = (SELECT MAX(sequence) FROM AHL_MC_PATH_POSITION_NODES
WHERE path_position_id = p_position_id)
AND pnodes.path_position_id = p_position_id
order by hd.version_number desc;
--
l_pos_ref_code    VARCHAR2(30);
l_pos_ref_meaning VARCHAR2(80);
l_return_val      BOOLEAN;
--
BEGIN

   OPEN get_pos_ref_csr(p_path_position_ID);
   FETCH get_pos_ref_csr INTO l_pos_ref_code;

   --If there are no pos ref defined for path
   IF (l_pos_ref_code IS NULL) OR
      (l_pos_ref_code = FND_API.G_MISS_CHAR)  THEN
      OPEN get_def_pos_ref_csr(p_path_position_ID);
      FETCH get_def_pos_ref_csr INTO l_pos_ref_code;
      CLOSE get_def_pos_ref_csr;
   END IF;
   CLOSE get_pos_ref_csr;

   IF (p_code_flag = FND_API.G_TRUE) THEN
       RETURN l_pos_ref_code;
   ELSE
     --Convert to meaning.
     AHL_UTIL_MC_PKG.Convert_To_LookupMeaning('AHL_POSITION_REFERENCE',
                                           l_pos_ref_code,
                                           l_pos_ref_meaning,
                                           l_return_val);

     Return l_pos_ref_meaning;
   END IF;
END Get_Posref_By_ID;

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_posref_by_path
--  Type        : Private
--  Function    : Fetches the position path position ref code
--  Pre-reqs    :
--  Parameters  :
--
--  get_position_ref_code Parameters:
--       p_position_path_tbl IN AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type Required
--       p_code_flag IN VARHCAR2 If Equal to FND_API.G_TRUE, then return
-- pos ref code, else return pos ref meaning. Default to False.
--
FUNCTION get_posref_by_path(
   p_path_position_tbl   IN AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type,
   p_code_flag           IN VARCHAR2 := FND_API.G_FALSE
)
RETURN VARCHAR2  -- Position Ref Meaning/Code
IS
--
CURSOR get_path_pos_ref_csr (p_encoded_path IN VARCHAR2) IS
SELECT position_ref_code
FROM  AHL_MC_PATH_POSITIONS
WHERE encoded_path_position = p_encoded_path;
--
--Select the default position reference.
CURSOR get_def_path_pos_ref_csr (p_mc_id IN NUMBER,
            p_version_number IN NUMBER,
            p_position_key IN NUMBER) IS
SELECT rel.position_ref_code
FROM  AHL_MC_HEADERS_B hd, AHL_MC_RELATIONSHIPS rel
WHERE rel.position_key = p_position_key
AND   hd.mc_header_id = rel.mc_header_id
AND  hd.mc_id = p_mc_id
AND  hd.version_number = nvl(p_version_number, hd.version_number)
order by hd.version_number desc;
--
l_pos_ref_code    VARCHAR2(30);
l_pos_ref_meaning VARCHAR2(80);
l_pos_tbl         AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_encoded_path     AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
l_return_val      BOOLEAN;
--
BEGIN
   --Remove the version numbers if any.
   FOR i IN p_path_position_tbl.FIRST..p_path_position_tbl.LAST  LOOP
      l_pos_tbl(i) := p_path_position_tbl(i);
      l_pos_tbl(i).version_number := NULL;
   END LOOP;

    --Encode the path_position_tbl
   l_encoded_path := Encode(l_pos_tbl);

   OPEN get_path_pos_ref_csr(l_encoded_path);
   FETCH get_path_pos_ref_csr INTO l_pos_ref_code;

   --If there are no pos ref defined for path
   IF (l_pos_ref_code IS NULL) THEN
      OPEN get_def_path_pos_ref_csr(
    p_path_position_tbl(p_path_position_tbl.LAST).mc_id,
    p_path_position_tbl(p_path_position_tbl.LAST).version_number,
    p_path_position_tbl(p_path_position_tbl.LAST).position_key);
      FETCH get_def_path_pos_ref_csr INTO l_pos_ref_code;
      CLOSE get_def_path_pos_ref_csr;
   END IF;
   CLOSE get_path_pos_ref_csr;

   IF (p_code_flag = FND_API.G_TRUE) THEN
       RETURN l_pos_ref_code;
   ELSE
     --Convert to meaning.
     AHL_UTIL_MC_PKG.Convert_To_LookupMeaning('AHL_POSITION_REFERENCE',
                                           l_pos_ref_code,
                                           l_pos_ref_meaning,
                                           l_return_val);

     Return l_pos_ref_meaning;
   END IF;

END Get_Posref_By_Path;


---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_posref_for_uc
--  Type        : Private
--  Function    : Fetches the position path position ref code
--  Pre-reqs    :
--  Parameters  :
--
--  get_position_ref_code Parameters:
--       p_uc_header_id IN NUMBER UNIT CONFIG header id
--       p_relationship_id IN NUMBER position of subunit
--
FUNCTION get_posref_for_uc(
   p_uc_header_id        IN NUMBER,
   p_relationship_id     IN NUMBER
)
RETURN VARCHAR2  -- Position Ref Meaning
IS
--
--Fetch the unit and unit header info for instance
CURSOR get_uc_headers_csr (p_uc_header_id IN NUMBER) IS
SELECT unit_config_header_id
FROM  ahl_unit_config_headers
START WITH unit_config_header_id = p_uc_header_id
CONNECT BY PRIOR parent_uc_header_id = unit_config_header_id;
--
CURSOR get_header_details_csr (p_uc_header_id IN NUMBER) IS
SELECT parent_mc_id, parent_position_key
FROM  ahl_uc_header_paths_v
WHERE uc_header_id = p_uc_header_id;
--
CURSOR get_rel_info_csr (p_rel_id IN VARCHAR2) IS
SELECT a.mc_id, b.position_key
FROM  AHL_MC_HEADERS_B a, AHL_MC_RELATIONSHIPS b
WHERE a.mc_header_id = b.mc_header_id
AND b.relationship_id = p_rel_id;
--
CURSOR get_path_pos_ref_csr (p_encoded_path IN VARCHAR2) IS
SELECT position_ref_code
FROM  AHL_MC_PATH_POSITIONS
WHERE encoded_path_position = p_encoded_path;
--
--Select the default position reference.
CURSOR get_def_path_pos_ref_csr (p_relationship_id IN NUMBER) IS
SELECT rel.position_ref_code
FROM  AHL_MC_RELATIONSHIPS rel
WHERE rel.relationship_id = p_relationship_id;
--
l_pos_ref_code    VARCHAR2(30);
l_pos_ref_meaning VARCHAR2(80);
l_path_tbl        AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_path_rec        AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
l_index           NUMBER;
l_encoded_path     AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
l_return_val      BOOLEAN;
l_uc_header     NUMBER;
--
BEGIN

  l_index := 0;

  -- Construct the position path table
  OPEN get_uc_headers_csr(p_uc_header_id);
  LOOP
     FETCH get_uc_headers_csr INTO l_uc_header;
     EXIT WHEN get_uc_headers_csr%NOTFOUND;

     OPEN get_header_details_csr(l_uc_header);
     FETCH get_header_details_csr INTO  l_path_rec.mc_id,
                        l_path_rec.position_key;
     CLOSE get_header_details_csr;

     --Make it nonversion specific
     l_path_rec.version_number := null;

     IF (l_path_rec.mc_id is not null AND
         l_path_rec.position_key is not null) THEN
        l_path_tbl(l_index) := l_path_rec;
        l_index := l_index - 1;
     END IF;

  END LOOP;
  CLOSE get_uc_headers_csr;
  --If subunit definition
  IF (l_path_tbl.COUNT>0) THEN

   OPEN get_rel_info_csr(p_relationship_id);
   FETCH get_rel_info_csr INTO l_path_rec.mc_id, l_path_rec.position_key;
   IF (get_rel_info_csr%FOUND) THEN
      l_path_tbl(l_path_tbl.LAST+1) := l_path_rec;
   END IF;
   CLOSE get_rel_info_csr;

    --Encode the modified with new params path_position_tbl
    l_encoded_path := Encode(l_path_tbl);

    OPEN get_path_pos_ref_csr(l_encoded_path);
    FETCH get_path_pos_ref_csr INTO l_pos_ref_code;
    CLOSE get_path_pos_ref_csr;

    --If there are no pos ref defined for path
    IF (l_pos_ref_code IS NULL) THEN
       OPEN get_def_path_pos_ref_csr(p_relationship_id);
       FETCH get_def_path_pos_ref_csr INTO l_pos_ref_code;
       CLOSE get_def_path_pos_ref_csr;
    END IF;

  ELSE
       OPEN get_def_path_pos_ref_csr(p_relationship_id);
       FETCH get_def_path_pos_ref_csr INTO l_pos_ref_code;
       CLOSE get_def_path_pos_ref_csr;
  END IF;

    --Convert to meaning.
    AHL_UTIL_MC_PKG.Convert_To_LookupMeaning('AHL_POSITION_REFERENCE',
                                           l_pos_ref_code,
                                           l_pos_ref_meaning,
                                           l_return_val);
    Return l_pos_ref_meaning;

END Get_Posref_For_UC;

----------------
----------------
FUNCTION Encode(
     p_path_position_tbl   IN  AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type
)
RETURN VARCHAR2
IS
--
l_path      AHL_MC_PATH_POSITIONS.ENCODED_PATH_POSITION%TYPE;
l_path_pos_rec  AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
--
BEGIN
  l_path := '';

  FOR i IN p_path_position_tbl.FIRST..p_path_position_tbl.LAST  LOOP
     l_path_pos_rec := p_path_position_tbl(i);

     --Append the ids.
     l_path := l_path || to_char(l_path_pos_rec.mc_id) || G_ID_SEPARATOR;
     IF (l_path_pos_rec.version_number IS NULL) THEN
        l_path := l_path || '%';
     ELSE
        l_path := l_path || to_char(l_path_pos_rec.version_number);
     END IF;
     l_path :=l_path ||G_ID_SEPARATOR ||to_char(l_path_pos_rec.position_key);

     --Append the node separators.
     IF (i < p_path_position_tbl.LAST) THEN
       l_path := l_path || G_NODE_SEPARATOR;
     END IF;
  END LOOP;

  RETURN l_path;

END Encode;

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: get_encoded_path
--  Type        : Private
--  Function    : Fetches the position path encoding based on input
--  Pre-reqs    :
--  Parameters  :
--
--  get_encoded_path Parameters:
--       p_parent_path IN VARCHAR2. encoded parent position path
--       p_mc_id       IN NUMBER.
--       p_ver_num     IN NUMBER.
--       p_position_key IN NUMBER.
--       p_subconfig_flag IN BOOLEAN indicates whether this is new subconfig
--
FUNCTION get_encoded_path(
   p_parent_path    IN VARCHAR2,
   p_mc_id          IN NUMBER,
   p_ver_num        IN NUMBER,
   p_position_key   IN NUMBER,
   p_subconfig_flag IN VARCHAR2
)
RETURN VARCHAR2
IS
BEGIN

  IF (p_subconfig_flag IS NOT NULL AND
      p_subconfig_flag = 'T') THEN
    RETURN p_parent_path||G_NODE_SEPARATOR||TO_CHAR(p_mc_id) ||G_ID_SEPARATOR||NVL(TO_CHAR(p_ver_num), '%')||G_ID_SEPARATOR|| TO_CHAR(p_position_key);
  ELSE
    RETURN SUBSTR(p_parent_path,0,INSTR(p_parent_path,G_ID_SEPARATOR,-1)) || p_position_key;
  END IF;

END get_encoded_path;


---------------------------------------------------------------------
-- Start of Comments --
--  Function name: check_pos_ref_path
--  Type        : Private
--  Function    :
-- Check that the path from instance to to instance has position ref each step
-- and that position ref is not null for all relnships.
--  Pre-reqs    :
--  Parameters  : p_from_csi_id NUMBER the from instance id
--                p_to_csi_id NUMBER the instance id that it reaches
--
FUNCTION check_pos_ref_path(
   p_from_csi_id    IN NUMBER,
   p_to_csi_id      IN NUMBER)
RETURN BOOLEAN
IS
--
CURSOR check_pos_ref_csr (p_csi_instance_id IN NUMBER,
              p_to_csi_instance_id IN NUMBER) IS
SELECT 'X'
FROM csi_ii_relationships csi_ii
WHERE csi_ii.object_id = p_to_csi_instance_id
START WITH csi_ii.subject_id = p_csi_instance_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
CONNECT BY csi_ii.subject_id = PRIOR csi_ii.object_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND CSI_II.POSITION_REFERENCE IS NOT NULL;
--
l_dummy VARCHAR2(1);
BEGIN
     --Check the position reference is valid for entire path
     OPEN check_pos_ref_csr (p_from_csi_id,
                 p_to_csi_id);
     FETCH check_pos_ref_csr INTO l_dummy;
     IF (check_pos_ref_csr%NOTFOUND) THEN
        CLOSE check_pos_ref_csr;
    RETURN false;
     ELSE
        CLOSE check_pos_ref_csr;
    RETURN true;
     END IF;

END Check_pos_ref_path;

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: check_pos_ref_path_char
--  Type        : Private
--  Function    : Calls private function Check_pos_ref_path and returns
--                value as FND_API.G_TRUE for Boolean TRUE and
--                FND_API.G_FALSE for Boolean False.
--  Pre-reqs    :
--  Parameters  : p_from_csi_id NUMBER the from instance id
--                p_to_csi_id NUMBER the instance id that it reaches
--
FUNCTION check_pos_ref_path_char(
   p_from_csi_id    IN NUMBER,
   p_to_csi_id      IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
     IF (AHL_MC_PATH_POSITION_PVT.CHECK_POS_REF_PATH(p_from_csi_id,p_to_csi_id)) THEN
        RETURN 'T';
     ELSE
        RETURN 'F';
     END IF;
END check_pos_ref_path_char;

-----------------------------
-- Start of Comments --
--  Procedure name    : Map_Instance_To_Pos_id
--  Type        : Private
--  Function    : For an instance map the position path and return
--     version specific path_pos_id. Reverse of the Get_Pos_Instance function
--  Pre-reqs    :
--  Parameters  :
--
--  Map_Instance_To_Pos_id Parameters:
--       p_csi_item_instance_id  IN NUMBER  Required. instance for the pos
--       p_relationship_id IN NUMBER Optional. Used for empty position
--       x_path_position_id   OUT NUMBER  the existing or new path pos id
--
--  End of Comments.

PROCEDURE Map_Instance_To_Pos_ID (
    p_api_version         IN           NUMBER,
    p_init_msg_list       IN           VARCHAR2  := FND_API.G_FALSE,
    p_commit              IN           VARCHAR2  := FND_API.G_FALSE,
    p_validation_level    IN           NUMBER    := FND_API.G_VALID_LEVEL_FULL,
    x_return_status       OUT  NOCOPY    VARCHAR2,
    x_msg_count           OUT  NOCOPY    NUMBER,
    x_msg_data            OUT  NOCOPY    VARCHAR2,
    p_csi_item_instance_id   IN         NUMBER,
    p_relationship_id        IN   NUMBER := FND_API.G_MISS_NUM,
    x_path_position_id    OUT NOCOPY  NUMBER)
IS
--
--Fetch the unit and unit header info for each instance
CURSOR get_uc_headers_csr (p_csi_instance_id IN NUMBER) IS
SELECT up.parent_mc_id, up.parent_version_number, up.parent_position_key
FROM  ahl_uc_header_paths_v up
WHERE up.csi_instance_id = p_csi_instance_id;
--
--Traverse up and fetch all unit instance ids
CURSOR get_unit_instance_csr  (p_csi_instance_id IN NUMBER) IS
SELECT csi.object_id
  FROM csi_ii_relationships csi
WHERE csi.object_id IN
      ( SELECT csi_item_instance_id
     FROM ahl_unit_config_headers
        WHERE trunc(nvl(active_start_date,sysdate)) <= trunc(sysdate)
          AND trunc(sysdate) < trunc(nvl(active_end_date, sysdate+1)))
START WITH csi.subject_id = p_csi_instance_id
    AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
CONNECT BY csi.subject_id = PRIOR csi.object_id
    AND CSI.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND CSI.POSITION_REFERENCE IS NOT NULL;
--
--Fetches lowest level info
CURSOR get_last_uc_rec_csr (p_csi_instance_id IN NUMBER) IS
SELECT hdr.mc_id, hdr.version_number, rel.position_key
FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel,
    csi_ii_relationships csi_ii
WHERE csi_ii.subject_id = p_csi_instance_id
    AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
    AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
    AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
    AND TO_NUMBER(CSI_II.POSITION_REFERENCE) = REL.RELATIONSHIP_ID
    AND REL.mc_header_id = HDR.mc_header_id;
--
-- Changed by jaramana on July 13, 2006 to fix FP of bug 5368714
-- Do not join with csi_unit_instances_v for filtering out non top level nodes
-- since it does not take dates into consideration
/*
CURSOR get_top_unit_inst_csr (p_csi_instance_id IN NUMBER) IS
SELECT hdr.mc_id, hdr.version_number, rel.position_key
FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel,
  ahl_unit_config_headers uch, csi_unit_instances_v csi_u
WHERE uch.csi_item_instance_id = p_csi_instance_id
  AND TRUNC(nvl(uch.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
  AND TRUNC(nvl(uch.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  AND hdr.mc_header_id = uch.master_config_id
  AND rel.mc_header_id = hdr.mc_header_id
  AND rel.parent_relationship_id IS NULL
  AND uch.csi_item_instance_id = csi_u.instance_id;
*/
CURSOR get_top_unit_inst_csr (p_csi_instance_id IN NUMBER) IS
SELECT hdr.mc_id, hdr.version_number, rel.position_key
FROM ahl_mc_headers_b hdr, ahl_mc_relationships rel,
  ahl_unit_config_headers uch
WHERE uch.csi_item_instance_id = p_csi_instance_id
  AND TRUNC(nvl(uch.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
  AND TRUNC(nvl(uch.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
  AND hdr.mc_header_id = uch.master_config_id
  AND rel.mc_header_id = hdr.mc_header_id
  AND rel.parent_relationship_id IS NULL
  AND NOT EXISTS (SELECT 'X' FROM CSI_II_RELATIONSHIPS CIR
                  WHERE CIR.SUBJECT_ID = uch.csi_item_instance_id AND
                        CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF' AND
                        TRUNC(nvl(CIR.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate) AND
                        TRUNC(nvl(CIR.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate));

--
--Fetch relationship_id's params
--Making sure that the relationship_id is direct child of the parent instance
-- position.
CURSOR get_mc_relationship_csr (p_relationships_id IN NUMBER,
                                p_parent_instance_id IN NUMBER) IS
SELECT hdr.mc_id, hdr.version_number, rel.position_key
FROM  ahl_mc_headers_b hdr, ahl_mc_relationships rel
WHERE hdr.mc_header_id = rel.mc_header_id
 AND rel.relationship_id = p_relationship_id
--Jerry rewrite the following condition on 03/03/2005 in order to fix bug 4090856
--after verifying the bug fix on scmtsb2
 AND rel.relationship_id IN (SELECT relationship_id
                             FROM ahl_mc_relationships
                             WHERE mc_header_id = (SELECT mc_header_id
                                                   FROM ahl_mc_relationships
                                                   WHERE relationship_id = (SELECT to_number(position_reference)
                                                                             FROM csi_ii_relationships
                                                                             WHERE subject_id = p_parent_instance_id
                                                                             AND RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
                                                                             AND TRUNC(nvl(ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
                                                                             AND TRUNC(nvl(ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)))
                               OR mc_header_id = (SELECT master_config_id
                                                    FROM ahl_unit_config_headers
                                                   WHERE csi_item_instance_id = p_parent_instance_id
                                                     AND TRUNC(nvl(ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)));

/*
 AND rel.parent_relationship_id IN
 ( SELECT r.relationship_id
   FROM AHL_MC_RELATIONSHIPS r, AHL_UNIT_CONFIG_HEADERS uch
   WHERE uch.csi_item_instance_id = p_parent_instance_id
     AND uch.master_config_id = r.mc_header_id
     --AND r.parent_relationship_id IS NULL
     --Jerry commented out the above condition on 01/14/2005 to fix bug 4090856
     AND TRUNC(nvl(uch.active_end_date, sysdate+1)) > TRUNC(sysdate)
     UNION ALL
   SELECT TO_NUMBER(CSI_II.POSITION_REFERENCE)
   FROM csi_ii_relationships csi_ii
   WHERE csi_ii.subject_id = p_parent_instance_id
   AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
   AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
   AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
     UNION ALL
   SELECT subrel.relationship_id
   FROM ahl_mc_config_relations crel, ahl_mc_relationships subrel,
   csi_ii_relationships csi_ii
   WHERE csi_ii.subject_id = p_parent_instance_id
   AND CSI_II.RELATIONSHIP_TYPE_CODE  = 'COMPONENT-OF'
   AND TRUNC(nvl(CSI_II.ACTIVE_START_DATE, sysdate)) <= TRUNC(sysdate)
   AND TRUNC(nvl(CSI_II.ACTIVE_END_DATE, sysdate+1)) > TRUNC(sysdate)
   AND crel.relationship_id = TO_NUMBER(CSI_II.POSITION_REFERENCE)
   AND crel.mc_header_id = subrel.mc_header_id
   AND subrel.parent_relationship_id IS NULL);
*/

l_path_tbl        AHL_MC_PATH_POSITION_PVT.Path_Position_Tbl_Type;
l_path_rec        AHL_MC_PATH_POSITION_PVT.Path_Position_Rec_Type;
l_index            NUMBER;
l_api_version      CONSTANT NUMBER       := 1.0;
l_api_name         CONSTANT VARCHAR2(30) := 'Map_Instance_To_Pos_Id';
l_unit_csi_id      NUMBER;
l_full_name        CONSTANT    VARCHAR2(60)    := 'ahl.plsql.' || g_pkg_name || '.' || l_api_name;

--
BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Map_Instance_To_Pos_ID_pvt;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name||'.begin', 'At the start of PLSQL procedure. p_csi_item_instance_id = ' || p_csi_item_instance_id ||
                                                                   ', p_relationship_id = ' || p_relationship_id);
  END IF;
  -- Initialize Procedure return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_path_position_id := null;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --Fetch the position informations for the instance
  OPEN get_last_uc_rec_csr(p_csi_item_instance_id);
  FETCH get_last_uc_rec_csr INTO l_path_rec.mc_id,
                 l_path_rec.version_number,
                 l_path_rec.position_key;
  IF (get_last_uc_rec_csr%FOUND) THEN
    l_path_tbl(1) := l_path_rec;

    --Now fetch the position paths which match at higher levels.
    l_index := 0;
    --Fetch the header rec info for the instance
    OPEN get_unit_instance_csr(p_csi_item_instance_id);
    LOOP
      FETCH get_unit_instance_csr INTO l_unit_csi_id;
      EXIT WHEN get_unit_instance_csr%NOTFOUND;

      OPEN get_uc_headers_csr(l_unit_csi_id);
      FETCH get_uc_headers_csr INTO l_path_rec.mc_id,
                   l_path_rec.version_number,
                   l_path_rec.position_key;
      CLOSE get_uc_headers_csr;

      --Add the path up the tree, decrementing index for each node.
      IF (l_path_rec.mc_id is not null AND
         l_path_rec.position_key is not null) THEN
         l_path_tbl(l_index) := l_path_rec;
         l_index := l_index - 1;
      END IF;
   END LOOP;
   CLOSE get_unit_instance_csr;

  --if not position node then check if instance is the top unit node
  ELSE
    --Fetch the position informations for the unit instance
    OPEN get_top_unit_inst_csr(p_csi_item_instance_id);
    FETCH get_top_unit_inst_csr INTO l_path_rec.mc_id,
                 l_path_rec.version_number,
                 l_path_rec.position_key;
    IF (get_top_unit_inst_csr%FOUND) THEN
      l_path_tbl(1) := l_path_rec;
    END IF;
    CLOSE get_top_unit_inst_csr;
  END IF;
  CLOSE get_last_uc_rec_csr;


  --For the empty position, build path information for last node of path.
  IF (p_relationship_id <> FND_API.G_MISS_NUM AND
      p_relationship_id IS NOT NULL) THEN
      OPEN get_mc_relationship_csr (p_relationship_id,  p_csi_item_instance_id);
      FETCH get_mc_relationship_csr INTO l_path_rec.mc_id,
                   l_path_rec.version_number,
                   l_path_rec.position_key;
      IF (get_mc_relationship_csr%FOUND) THEN

        --Either add a new row or replace position key of last row.
        IF (l_path_rec.mc_id = l_path_tbl(l_path_tbl.LAST).mc_id AND
            l_path_rec.version_number =
        NVL(l_path_tbl(l_path_tbl.LAST).version_number,
            l_path_rec.version_number)) THEN
            l_path_tbl(l_path_tbl.LAST) := l_path_rec;
        ELSE
            l_path_tbl(l_path_tbl.LAST+1) := l_path_rec;
        END IF;
      END IF;
      CLOSE get_mc_relationship_csr;
  END IF;

  IF (l_path_tbl.COUNT > 0) THEN
   --Create position with generated instance path position id
    IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_event, l_full_name, 'About to call Create_Position_ID API. l_path_tbl.COUNT = ' || l_path_tbl.COUNT);
    end if;

    -- SATHAPLI::FP OGMA Issue# 105 - Non-Serialized Item Maintenance, 21-Dec-2007
    -- There is no need to call the API Create_Position_ID, if there are pending validation errors.
    x_msg_count := FND_MSG_PUB.count_msg;
    IF x_msg_count > 0 THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

   Create_Position_ID (
            p_api_version       => 1.0,
                p_init_msg_list     => FND_API.G_TRUE,
        p_commit            => FND_API.G_FALSE,
            p_path_position_tbl     =>   l_path_tbl,
            p_position_ref_meaning  => FND_API.G_MISS_CHAR,
            p_position_ref_code    => FND_API.G_MISS_CHAR,
        x_position_id         => x_path_position_id,
        x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);
    IF (fnd_log.level_event >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_event, l_full_name, 'Returned from call to Create_Position_ID API. x_return_status = ' || x_return_status ||
                                                       ', x_position_id = ' || x_path_position_id);
    end if;
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string(fnd_log.level_procedure, l_full_name||'.end', 'At the end of PLSQL procedure. About to commit work.');
  END IF;
  -- Standard check of p_commit
  IF FND_API.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => fnd_api.g_false
    );
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   Rollback to Map_Instance_To_Pos_ID_pvt;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   Rollback to Map_Instance_To_Pos_ID_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);
 WHEN OTHERS THEN
   Rollback to Map_Instance_To_Pos_ID_pvt;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                             p_procedure_name => l_api_name,
                             p_error_text     => SQLERRM);
    FND_MSG_PUB.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => fnd_api.g_false);

END Map_Instance_To_Pos_Id;

---------------------------------------------------------------------
-- Start of Comments --
--  Function name: Is_Position_Serial_Controlled
--  Type         : Private
--  Function     : Cretaed for FP OGMA Issue# 105 - Non-Serialized Item Maintenance.
--                 Checks whether a position accepts a serialized item instance or not.
--                 Returns 'Y' if item group attached to the position has first associated item as serialized.
--                 Returns 'N' otherwise.
--  Pre-reqs     :
--  Parameters   : p_relationship_id  NUMBER relationship id
--                 p_path_position_id NUMBER path posiiton id
--
--                 If relationship id is passed, it will be taken to determine the result.
--                 Position id will be used only when relationship id is NULL.
--

FUNCTION Is_Position_Serial_Controlled(
    p_relationship_id    IN    NUMBER,
    p_path_position_id   IN    NUMBER
) RETURN VARCHAR2 IS
--
    -- for a given path position id, get the mc id and version no from ahl_mc_path_position_nodes
    -- from the mc id and version no, get the mc header id from ahl_mc_headers_b
    -- from the mc header id and position key (from ahl_mc_path_position_nodes), get the relationship id from ahl_mc_relationships
    CURSOR get_rel_id_csr (p_path_position_id NUMBER) IS
        SELECT mcr.relationship_id
        FROM   ahl_mc_path_position_nodes mpn, ahl_mc_headers_b mch,
               ahl_mc_relationships mcr
        WHERE  mpn.path_position_id = p_path_position_id
        AND    mpn.sequence         = (
                                       SELECT MAX(sequence)
                                       FROM   ahl_mc_path_position_nodes
                                       WHERE  path_position_id = mpn.path_position_id
                                      )
        AND    mpn.mc_id            = mch.mc_id
        AND    mch.version_number   = NVL(mpn.version_number, mch.version_number)
        AND    mcr.mc_header_id     = mch.mc_header_id
        AND    mcr.position_key     = mpn.position_key;

    -- for a given relationship id, get the item group id from ahl_mc_relationships
    CURSOR get_item_group_id_csr (p_relationship_id NUMBER) IS
        SELECT item_group_id
        FROM   ahl_mc_relationships
        WHERE  relationship_id = p_relationship_id;

    -- for a given item group id, get the serial control code of the associated items
    CURSOR get_serial_cntrl_code_csr (p_item_group_id NUMBER) IS
        SELECT mtl.serial_number_control_code
        FROM   ahl_item_associations_b aia, mtl_system_items_b mtl
        WHERE  aia.item_group_id         = p_item_group_id
        AND    aia.inventory_item_id     = mtl.inventory_item_id
        AND    aia.inventory_org_id      = mtl.organization_id
        AND    aia.interchange_type_code IN ('1-WAY INTERCHANGEABLE', '2-WAY INTERCHANGEABLE')
        ORDER BY aia.item_association_id;

--
    l_api_name       CONSTANT    VARCHAR2(30) := 'Is_Position_Serial_Controlled';
    l_full_name      CONSTANT    VARCHAR2(70) := 'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name;

    l_ret_val                    VARCHAR2(1)  := 'Y';
    l_relationship_id            NUMBER       := p_relationship_id;
    l_item_group_id              NUMBER;
    l_serial_number_control_code NUMBER;
--
BEGIN
    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name||'.begin','Start of the API.'||
                       ' Input parameters p_relationship_id => '||p_relationship_id||
                       ', p_path_position_id => '||p_path_position_id);
    END IF;

    IF (l_relationship_id IS NULL) THEN
        -- get the relationship id from the given path position id
        OPEN get_rel_id_csr(p_path_position_id);
        FETCH get_rel_id_csr INTO l_relationship_id;
        CLOSE get_rel_id_csr;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                           ' After cursor call l_relationship_id => '||l_relationship_id);
        END IF;
    END IF;

    -- do the rest only if relationship id is not NULL
    IF (l_relationship_id IS NOT NULL) THEN
        -- get the item group id
        OPEN get_item_group_id_csr(l_relationship_id);
        FETCH get_item_group_id_csr INTO l_item_group_id;

        IF (get_item_group_id_csr%NOTFOUND) THEN
            -- relationship id is invalid
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                               ' Relationship id is invalid.');
            END IF;
        END IF;

        CLOSE get_item_group_id_csr;

        -- check for the fetched item group id
        IF (l_item_group_id IS NOT NULL) THEN
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_full_name,
                               ' Fetched item group id => '||l_item_group_id);
            END IF;

            -- the MC position doesn't have subconfigurations attached
            -- get the serial control code for the first associated item
            OPEN get_serial_cntrl_code_csr(l_item_group_id);
            FETCH get_serial_cntrl_code_csr INTO l_serial_number_control_code;
            CLOSE get_serial_cntrl_code_csr;

            -- check for the fetched serial control_code
            IF (l_serial_number_control_code IS NOT NULL) THEN
                -- if 1, then it is non-serialized; else serialized
                IF (l_serial_number_control_code = 1) THEN
                    l_ret_val := 'N';
                END IF;
            END IF;
        END IF;
    END IF; -- relationship id check

    IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(FND_LOG.level_procedure,l_full_name||'.end','End of the API with return value => '||l_ret_val);
    END IF;

    RETURN l_ret_val;
END Is_Position_Serial_Controlled;

End AHL_MC_PATH_POSITION_PVT;

/
