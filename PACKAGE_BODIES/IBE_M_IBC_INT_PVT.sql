--------------------------------------------------------
--  DDL for Package Body IBE_M_IBC_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_M_IBC_INT_PVT" AS
/* $Header: IBEVIBCB.pls 120.0 2005/05/30 02:19:14 appldev noship $ */

g_label_code CONSTANT VARCHAR2(30) := 'IBE';
g_association_type_code CONSTANT VARCHAR2(30) := 'IBE_MEDIA_OBJECT';

FUNCTION getTransLang(p_citem_version_id IN NUMBER,
				  p_base_language IN VARCHAR2)
RETURN VARCHAR2
IS
  CURSOR c_get_langs_csr(c_citem_version_id NUMBER,
    c_base_lang VARCHAR2) IS
    SELECT b.description
	 FROM ibc_citem_versions_tl a, fnd_languages_vl b
     WHERE a.language = b.language_code
	  AND a.source_lang <> c_base_lang
	  AND a.source_lang = a.language
	  AND a.citem_version_id = c_citem_version_id;
  l_langs VARCHAR2(2600) := NULL;
  l_lang VARCHAR2(255) := NULL;
BEGIN
  OPEN c_get_langs_csr(p_citem_version_id, p_base_language);
  LOOP
    FETCH c_get_langs_csr INTO l_lang;
    EXIT WHEN c_get_langs_csr%NOTFOUND;
    l_langs := l_langs || l_lang || ',';
  END LOOP;
  CLOSE c_get_langs_csr;
  IF (l_langs IS NOT NULL) THEN
    RETURN substr(l_langs,1,length(l_langs)-1);
  END IF;
  RETURN NULL;
END getTransLang;

FUNCTION getLang(p_citem_version_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_get_langs_csr(c_citem_version_id NUMBER) IS
    SELECT b.description
	 FROM ibc_citem_versions_tl a, fnd_languages_vl b
     WHERE a.language = b.language_code
	  AND a.source_lang = a.language
	  AND a.citem_version_id = c_citem_version_id;
  l_langs VARCHAR2(2600) := NULL;
  l_lang VARCHAR2(255) := NULL;
BEGIN
  OPEN c_get_langs_csr(p_citem_version_id);
  LOOP
    FETCH c_get_langs_csr INTO l_lang;
    EXIT WHEN c_get_langs_csr%NOTFOUND;
    l_langs := l_langs || l_lang || ',';
  END LOOP;
  CLOSE c_get_langs_csr;
  IF (l_langs IS NOT NULL) THEN
    RETURN substr(l_langs,1,length(l_langs)-1);
  END IF;
  RETURN NULL;
END getLang;

FUNCTION getLiveStatus(p_citem_id NUMBER, p_citem_version_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_get_live(c_citem_id NUMBER, c_item_version_id NUMBER) IS
    SELECT 1
	 FROM ibc_citem_version_labels
     WHERE citem_version_id = c_item_version_id
	  AND content_item_id = c_citem_id
	  AND label_code = 'IBE';
  l_temp NUMBER;
BEGIN
  OPEN c_get_live(p_citem_id, p_citem_version_id);
  FETCH c_get_live INTO l_temp;
  IF c_get_live%FOUND THEN
    CLOSE c_get_live;
    RETURN 'Y';
  END IF;
  CLOSE c_get_live;
  RETURN 'N';
END getLiveStatus;

FUNCTION getLiveVersion(p_citem_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_get_live_version(c_citem_id NUMBER) IS
    SELECT b.version_number
	 FROM ibc_citem_version_labels a, ibc_citem_versions_b b
     WHERE a.citem_version_id = b.citem_version_id
	  AND a.content_item_id = c_citem_id
	  AND a.label_code = 'IBE';

  l_version_number NUMBER := NULL;
BEGIN
  OPEN c_get_live_version(p_citem_id);
  FETCH c_get_live_version INTO l_version_number;
  IF c_get_live_version%FOUND THEN
    CLOSE c_get_live_version;
    RETURN l_version_number;
  END IF;
  CLOSE c_get_live_version;
  RETURN -1;
END getLiveVersion;

FUNCTION getStore(p_citem_id IN NUMBER)
RETURN VARCHAR2
IS
  CURSOR c_get_store(c_item_key VARCHAR2) IS
    SELECT decode(b.msite_id, 1, 'All', b.msite_name)
	 FROM ibe_dsp_lgl_phys_map a, ibe_msites_vl b
     WHERE a.msite_id = b.msite_id and b.site_type = 'I'
	  AND a.content_item_key = c_item_key
 	  AND a.attachment_id = -1;
  -- Need to reconsider the length of the l_stores
  -- as the length of the store name in ibe_msites_vl
  -- is 4000. but the pl/sql package is only allow
  -- 240 for now.
  l_stores VARCHAR2(4000) := NULL;
  l_store VARCHAR2(4000) := NULL;
BEGIN
  OPEN c_get_store(to_char(p_citem_id));
  LOOP
    FETCH c_get_store INTO l_store;
    EXIT WHEN c_get_store%NOTFOUND;
    l_stores := l_stores || l_store || ',';
  END LOOP;
  CLOSE c_get_store;
  IF (l_stores IS NOT NULL) THEN
    RETURN substr(l_stores,1,length(l_stores)-1);
  END IF;
  RETURN NULL;
END getStore;

FUNCTION getAvalVersion(p_citem_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_get_aval_status(c_citem_id NUMBER) IS
    SELECT MAX(a.version_number)
	 FROM ibc_citem_versions_b a
     WHERE a.citem_version_status = 'APPROVED'
	  AND a.content_item_id = c_citem_id;
  l_version_number NUMBER;
BEGIN
  OPEN c_get_aval_status(p_citem_id);
  FETCH c_get_aval_status INTO l_version_number;
  IF (c_get_aval_status%FOUND) THEN
    CLOSE c_get_aval_status;
    RETURN l_version_number;
  END IF;
  CLOSE c_get_aval_status;
  RETURN -1;
END getAvalVersion;

FUNCTION getAvalVersionId(p_citem_id IN NUMBER)
RETURN NUMBER
IS
  CURSOR c_get_aval_status(c_citem_id NUMBER) IS
    SELECT MAX(a.citem_version_id)
	 FROM ibc_citem_versions_b a
     WHERE a.citem_version_status = 'APPROVED'
	  AND a.content_item_id = c_citem_id;
  l_citem_version_id NUMBER;
BEGIN
  OPEN c_get_aval_status(p_citem_id);
  FETCH c_get_aval_status INTO l_citem_version_id;
  IF (c_get_aval_status%FOUND) THEN
    CLOSE c_get_aval_status;
    RETURN l_citem_version_id;
  END IF;
  CLOSE c_get_aval_status;
  RETURN -1;
END getAvalVersionId;

-- This procedure is used to move IBE label to the latest
-- version of the content items.
-- All content items must be labeled before calling this procedure.
PROCEDURE Batch_Update_Labels(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_commit IN VARCHAR2,
  p_content_item_id_tbl IN JTF_NUMBER_TABLE,
  p_version_number_tbl IN JTF_NUMBER_TABLE,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Batch_Update_Labels';
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_label_code VARCHAR2(30) := g_label_code;

  l_debug VARCHAR2(1);
BEGIN
  SAVEPOINT BATCH_UPDATE_LABELS_SAVE;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('IBE_M_IBC_INT_PVT.Batch_Update_Labels Starts +');
  IBE_UTIL.debug('p_api_version = '||p_api_version);
  IBE_UTIL.debug('p_init_msg_list = '||p_init_msg_list);
  IBE_UTIL.debug('p_commit = '||p_commit);
  IBE_UTIL.debug('p_content_item_id_tbl number:'||p_content_item_id_tbl.Count);
  IBE_UTIL.debug('p_version_number_tbl:'||p_version_number_tbl.Count);
  END IF;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Calling Ibc_Cv_Label_Grp.Upsert_Cv_Labels starts');
  IBE_UTIL.debug('p_label_code = '||l_label_code);
  IBE_UTIL.debug('p_content_item_id_tbl.COUNT = '||p_content_item_id_tbl.COUNT);
  IF (p_content_item_id_tbl.COUNT > 0) THEN
    FOR i IN p_content_item_id_tbl.FIRST..p_content_item_id_tbl.LAST LOOP
      IBE_UTIL.debug('p_content_item_id_tbl '||i||' = '||p_content_item_id_tbl(i));
    END LOOP;
  END IF;
  IBE_UTIL.debug('p_version_number_tbl.COUNT = '||p_version_number_tbl.COUNT);
  IF (p_version_number_tbl.COUNT > 0) THEN
    FOR i IN p_version_number_tbl.FIRST..p_version_number_tbl.LAST LOOP
      IBE_UTIL.debug('p_version_number_tbl '||i||' = '||p_version_number_tbl(i));
    END LOOP;
  END IF;
  END IF;
  Ibc_Cv_Label_Grp.Upsert_Cv_Labels(
    p_label_code => l_label_code,
    p_content_item_ids => p_content_item_id_tbl,
    p_version_number => p_version_number_tbl,
    p_commit => FND_API.G_FALSE,
    p_api_version_number => 1.0,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('After calling Ibc_Cv_Label_Grp.Upsert_Cv_Labels:'||x_return_status);
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Upsert_Cv_Labels');
    for i in 1..x_msg_count loop
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 IBE_UTIL.debug(l_msg_data);
    end loop;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Upsert_Cv_Labels');
    for i in 1..x_msg_count loop
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 IBE_UTIL.debug(l_msg_data);
    end loop;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Before committing the work:'||p_commit);
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('IBE_M_IBC_INT_PVT.Batch_Update_Labels Ends +');
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BATCH_UPDATE_LABELS_SAVE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BATCH_UPDATE_LABELS_SAVE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO BATCH_UPDATE_LABELS_SAVE;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('SQLCODE:'||SQLCODE);
    IBE_UTIL.debug('SQLERRM:'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END Batch_Update_Labels;

PROCEDURE Update_Label_Association(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_commit IN VARCHAR2,
  p_old_content_item_id IN NUMBER,
  p_old_version_number IN NUMBER,
  p_new_content_item_id IN NUMBER,
  p_new_version_number IN NUMBER,
  p_media_object_id IN NUMBER,
  p_association_type_code IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Update_Label_Association';
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_old_item_ids JTF_NUMBER_TABLE;
  l_new_item_ids JTF_NUMBER_TABLE;
  l_assoc_type_codes JTF_VARCHAR2_TABLE_100;
  l_assoc_objects JTF_VARCHAR2_TABLE_300;
  l_assoc_objects1 JTF_VARCHAR2_TABLE_300;
  l_move_flag VARCHAR2(1) := 'N';

  l_i NUMBER;
  l_old_item_id NUMBER;
  l_content_item_id NUMBER;
  l_item_version_id NUMBER;
  l_version_number NUMBER;
  l_association_type_code VARCHAR2(30);
  l_label_code VARCHAR2(30) := g_label_code;
  l_cv_label_rec Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
  r_cv_label_rec Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
  CURSOR c_get_version_id(c_content_item_id NUMBER,
    c_version_number NUMBER) IS
    SELECT citem_version_id
	 FROM ibc_citem_versions_b
     WHERE content_item_id = c_content_item_id
	  AND version_number = c_version_number;

  l_assoc_val1 VARCHAR2(254);
  l_temp NUMBER;
  CURSOR c_get_assoc_objects(c_content_item_id NUMBER,
    c_label_code VARCHAR2) IS
    SELECT ASSOCIATED_OBJECT_VAL1
	 FROM ibc_associations
     WHERE content_item_id = c_content_item_id
	  AND association_type_code = c_label_code;

  CURSOR c_label_flag(c_content_item_id NUMBER,
    c_label_code VARCHAR2) IS
    SELECT object_version_number
	 FROM IBC_CITEM_VERSION_LABELS
     WHERE content_item_id = c_content_item_id
	  AND label_code = c_label_code;

  CURSOR c_associations_flag(c_content_item_id NUMBER,
    c_association_type_code VARCHAR2) IS
    SELECT 1
	 FROM IBC_ASSOCIATIONS
     WHERE content_item_id = c_content_item_id
	  AND association_type_code = c_association_type_code;

  CURSOR c_association_flag(c_content_item_id NUMBER,
    c_association_type_code VARCHAR2, c_assoc_object VARCHAR2) IS
    SELECT 1
	 FROM IBC_ASSOCIATIONS
     WHERE content_item_id = c_content_item_id
	  AND association_type_code = c_association_type_code
	  AND associated_object_val1 = c_assoc_object;

  l_debug VARCHAR2(1);
BEGIN
  SAVEPOINT UPDATE_LABEL_ASSOCIATION_SAVE;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('IBE_M_IBC_INT_PVT.Update_Label_Association starts +');
  END IF;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  x_return_status := FND_API.g_ret_sts_success;
  l_content_item_id := p_new_content_item_id;
  l_version_number := p_new_version_number;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Before getting version id');
  IBE_UTIL.debug('l_content_item_id = '||l_content_item_id);
  IBE_UTIL.debug('l_version_number = '||l_version_number);
  END IF;
  OPEN c_get_version_id(l_content_item_id, l_version_number);
  FETCH c_get_version_id INTO l_item_version_id;
  IF (c_get_version_id%NOTFOUND) THEN
    CLOSE c_get_version_id;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('version id is not found');
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_get_version_id;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('After getting version id: '||l_item_version_id);
  END IF;
  l_association_type_code := NVL(p_association_type_code,
    g_association_type_code);
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('l_association_type_code = '||l_association_type_code);
  END IF;
  -- Process association
  IF (p_old_content_item_id IS NULL) THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('p_old_content_item_id IS NULL');
    END IF;
    IF (p_media_object_id IS NULL) THEN
	 IF (l_debug = 'Y') THEN
	 IBE_UTIL.debug('p_media_object_id IS NULL, RAISE ERROR');
	 END IF;
	 raise FND_API.G_EXC_ERROR;
    END IF;
    l_old_item_ids := JTF_NUMBER_TABLE();
    l_old_item_ids.extend(1);
    l_old_item_ids(1) := NULL;
    l_new_item_ids := JTF_NUMBER_TABLE();
    l_new_item_ids.extend(1);
    l_new_item_ids(1) := p_new_content_item_id;
    l_assoc_type_codes := JTF_VARCHAR2_TABLE_100();
    l_assoc_type_codes.extend(1);
    l_assoc_type_codes(1) := g_association_type_code;
    l_assoc_objects := JTF_VARCHAR2_TABLE_300();
    l_assoc_objects.extend(1);
    l_assoc_objects(1) := TO_CHAR(p_media_object_id);
    l_assoc_objects1 := JTF_VARCHAR2_TABLE_300();
    l_assoc_objects1.extend(1);
    l_assoc_objects1(1) := NULL;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('l_old_item_ids(1) is NULL');
    IBE_UTIL.debug('l_new_item_ids(1) = '||l_new_item_ids(1));
    IBE_UTIL.debug('l_assoc_type_codes(1) = '||l_assoc_type_codes(1));
    IBE_UTIL.debug('l_assoc_objects(1) = '||l_assoc_objects(1));
    IBE_UTIL.debug('l_assoc_objects1(1) IS NULL');
    END IF;
    l_move_flag := 'Y';
  ELSE
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('p_old_content_item_id = '||p_old_content_item_id);
    IBE_UTIL.debug('p_new_content_item_id = '||p_new_content_item_id);
    END IF;
    IF (p_old_content_item_id <> p_new_content_item_id) THEN
	 IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('Need to move the label');
	 END IF;
      l_old_item_ids := JTF_NUMBER_TABLE();
      l_old_item_ids.extend(1);
      l_old_item_ids(1) := p_old_content_item_id;
      l_new_item_ids := JTF_NUMBER_TABLE();
      l_new_item_ids.extend(1);
      l_new_item_ids(1) := p_new_content_item_id;
	 l_assoc_type_codes := JTF_VARCHAR2_TABLE_100();
      l_assoc_type_codes.extend(1);
      l_assoc_type_codes(1) := g_association_type_code;
	 IF (l_debug = 'Y') THEN
        IBE_UTIL.debug('l_old_item_ids(1) = '||l_old_item_ids(1));
        IBE_UTIL.debug('l_new_item_ids(1) = '||l_new_item_ids(1));
	   IBE_UTIL.debug('l_assoc_type_codes(1) = '||l_assoc_type_codes(1));
	 END IF;
	 IF (p_media_object_id IS NULL) THEN
	   IF (l_debug = 'Y') THEN
	     IBE_UTIL.debug('p_media_object_id IS NULL, move all for content item');
	   END IF;
	   --
        l_assoc_objects := JTF_VARCHAR2_TABLE_300();
        l_assoc_objects.extend(1);
	   l_assoc_objects(1) := NULL;
        l_assoc_objects1 := JTF_VARCHAR2_TABLE_300();
        l_assoc_objects1.extend(1);
        l_assoc_objects1(1) := NULL;
        l_move_flag := 'Y';
	 ELSE
	   IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('p_media_object_id is NOT NULL, move specific for content item');
	   END IF;
        l_assoc_objects := JTF_VARCHAR2_TABLE_300();
        l_assoc_objects.extend(1);
	   l_assoc_objects(1) := TO_CHAR(p_media_object_id);
	   IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('l_assoc_objects(1) = '||l_assoc_objects(1));
	   END IF;
        l_assoc_objects1 := JTF_VARCHAR2_TABLE_300();
        l_assoc_objects1.extend(1);
        l_assoc_objects1(1) := NULL;
        l_move_flag := 'Y';
	 END IF;
    END IF;
  END IF;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('l_move_flag = '||l_move_flag);
  END IF;
  IF (l_move_flag = 'Y') THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Calling Ibc_Associations_Grp.Move_Associations');
    END IF;
    Ibc_Associations_Grp.Move_Associations (
	 p_api_version => 1.0,
	 p_init_msg_list => FND_API.G_FALSE,
	 p_commit => FND_API.G_FALSE,
	 p_old_content_item_ids => l_old_item_ids,
	 p_new_content_item_ids => l_new_item_ids,
	 p_assoc_type_codes => l_assoc_type_codes,
	 p_assoc_objects1 => l_assoc_objects,
	 p_assoc_objects2 => l_assoc_objects1,
	 p_assoc_objects3 => l_assoc_objects1,
	 p_assoc_objects4 => l_assoc_objects1,
	 p_assoc_objects5 => l_assoc_objects1,
	 x_return_status => x_return_status,
	 x_msg_count => x_msg_count,
	 x_msg_data => x_msg_data);
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('After calling Ibc_Associations_Grp.Move_Associations:'
	 ||x_return_status);
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Associations_Grp.Move_Associations');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Associations_Grp.Move_Associations');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Process label
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Process label starts');
  END IF;
  IF (p_old_content_item_id IS NOT NULL) AND
    (p_old_content_item_id = p_new_content_item_id) THEN
    -- Change iStore label to the new version of
    -- the same content item
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Find label version, p_old_content_item_id = p_new_content_item_id');
    IBE_UTIL.debug('p_old_content_item_id = '||p_old_content_item_id);
    IBE_UTIL.debug('p_new_content_item_id = '||p_new_content_item_id);
    IBE_UTIL.debug('l_content_item_id = '||l_content_item_id);
    IBE_UTIL.debug('l_label_code = '||l_label_code);
    END IF;
    OPEN c_label_flag(l_content_item_id,l_label_code);
    FETCH c_label_flag INTO l_temp;
    IF (c_label_flag%NOTFOUND) THEN
      CLOSE c_label_flag;
	 IF (l_debug = 'Y') THEN
	 IBE_UTIL.debug('Cannot find label item, exception');
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE c_label_flag;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('After finding label version');
    END IF;
    l_cv_label_rec.content_item_id := l_content_item_id;
    l_cv_label_rec.citem_version_id := l_item_version_id;
    l_cv_label_rec.label_code := l_label_code;
    l_cv_label_rec.last_updated_by := FND_GLOBAL.user_id;
    l_cv_label_rec.last_update_date := SYSDATE;
    l_cv_label_rec.object_version_number := l_temp;
    l_cv_label_rec.last_update_login := FND_GLOBAL.login_id;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Before calling Ibc_Cv_Label_Grp.Update_CV_Label');
    IBE_UTIL.debug('l_cv_label_rec.content_item_id = '||l_cv_label_rec.content_item_id);
    IBE_UTIL.debug('l_cv_label_rec.citem_version_id  = '||l_cv_label_rec.citem_version_id);
    IBE_UTIL.debug('l_cv_label_rec.label_code = '||l_cv_label_rec.label_code);
    IBE_UTIL.debug('l_cv_label_rec.last_updated_by = '||l_cv_label_rec.last_updated_by);
    IBE_UTIL.debug('l_cv_label_rec.object_version_number = '
	 ||l_cv_label_rec.object_version_number);
    END IF;
    Ibc_Cv_Label_Grp.Update_CV_Label(
      p_api_version_number => 1.0,
      P_Init_Msg_List => FND_API.G_FALSE,
      P_Commit => FND_API.G_FALSE,
      P_CV_Label_Rec => l_cv_label_rec,
      x_CV_Label_Rec => r_cv_label_rec,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('After calling Ibc_Cv_Label_Grp.Update_CV_Label:'||x_return_status);
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Update_CV_Label');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Update_CV_Label');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSE
    IF (p_old_content_item_id IS NOT NULL) THEN
    -- Check the old content item has association or not
    -- If not, remove the label
	 IF (l_debug = 'Y') THEN
	 IBE_UTIL.debug('Check the old content item has association or not');
	 END IF;
	 l_temp := 0;
	 l_old_item_id := p_old_content_item_id;
	 IF (l_debug = 'Y') THEN
	 IBE_UTIL.debug('Check association');
	 IBE_UTIL.debug('l_old_item_id = '||l_old_item_id);
	 IBE_UTIL.debug('l_association_type_code = '||l_association_type_code);
	 END IF;
      OPEN c_associations_flag(l_old_item_id,
	   l_association_type_code);
      FETCH c_associations_flag INTO l_temp;
	 IF c_associations_flag%NOTFOUND THEN
	   l_temp := 0;
	 END IF;
	 CLOSE c_associations_flag;
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('After checking old association:'||l_temp);
	 END IF;
	 IF (l_temp <> 1) THEN
	   IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('Calling Ibc_Cv_Label_Grp.Delete_CV_Label');
	   IBE_UTIL.debug('p_label_code = '||l_label_code);
	   IBE_UTIL.debug('p_content_item_id = '||l_old_item_id);
	   END IF;
        Ibc_Cv_Label_Grp.Delete_CV_Label(
	     P_Api_Version_Number => 1.0,
	     P_Init_Msg_List => FND_API.G_FALSE,
	     P_Commit => FND_API.G_FALSE,
	     p_label_code => l_label_code,
	     p_content_item_id => l_old_item_id,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data);
        IF (l_debug = 'Y') THEN
	   IBE_UTIL.debug('After calling Ibc_Cv_Label_Grp.Delete_CV_Label:'||x_return_status);
	   END IF;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		IF (l_debug = 'Y') THEN
          IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Delete_CV_Label');
          for i in 1..x_msg_count loop
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	       IBE_UTIL.debug(l_msg_data);
          end loop;
		END IF;
	     RAISE FND_API.G_EXC_ERROR;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
		IF (l_debug = 'Y') THEN
          IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Delete_CV_Label');
          for i in 1..x_msg_count loop
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	       IBE_UTIL.debug(l_msg_data);
          end loop;
		END IF;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
	 END IF;
    END IF;
    l_temp := 0;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Before checking label');
    IBE_UTIL.debug('l_content_item_id = '||l_content_item_id);
    IBE_UTIL.debug('l_label_code = '||l_label_code);
    END IF;
    OPEN c_label_flag(l_content_item_id,l_label_code);
    FETCH c_label_flag INTO l_temp;
    IF (c_label_flag%NOTFOUND) THEN
	 l_temp := -1;
    END IF;
    CLOSE c_label_flag;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('After checking label:'||l_temp);
    END IF;
    l_cv_label_rec.content_item_id := l_content_item_id;
    l_cv_label_rec.citem_version_id := l_item_version_id;
    l_cv_label_rec.label_code := l_label_code;
    l_cv_label_rec.last_updated_by := FND_GLOBAL.user_id;
    l_cv_label_rec.last_update_date := SYSDATE;
    l_cv_label_rec.object_version_number := l_temp;
    l_cv_label_rec.last_update_login := FND_GLOBAL.login_id;
    IF (l_temp >= 0) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Calling Ibc_Cv_Label_Grp.Update_CV_Label');
	 IBE_UTIL.debug('P_CV_Label_Rec.content_item_id = '||l_cv_label_rec.content_item_id);
	 IBE_UTIL.debug('P_CV_Label_Rec.citem_version_id = '||l_cv_label_rec.citem_version_id);
	 IBE_UTIL.debug('P_CV_Label_Rec.label_code = '||l_cv_label_rec.label_code);
	 IBE_UTIL.debug('P_CV_Label_Rec.last_updated_by = '
	   ||l_cv_label_rec.last_updated_by);
	 IBE_UTIL.debug('P_CV_Label_Rec.last_update_date = '
	   ||to_char(l_cv_label_rec.last_update_date,'MM-DD-RRRR HH24:MI:SS'));
	 IBE_UTIL.debug('P_CV_Label_Rec.object_version_number = '
	   ||l_cv_label_rec.object_version_number);
	 IBE_UTIL.debug('P_CV_Label_Rec.last_update_login = '
	   ||l_cv_label_rec.last_update_login);
	 END IF;
      Ibc_Cv_Label_Grp.Update_CV_Label(
        p_api_version_number => 1.0,
        P_Init_Msg_List => FND_API.G_FALSE,
        P_Commit => FND_API.G_FALSE,
        P_CV_Label_Rec => l_cv_label_rec,
        x_CV_Label_Rec => r_cv_label_rec,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('After calling Ibc_Cv_Label_Grp.Update_CV_Label:'||x_return_status);
      END IF;
    ELSE
      l_cv_label_rec.object_version_number := 1;
      l_cv_label_rec.created_by := FND_GLOBAL.user_id;
      l_cv_label_rec.creation_date := SYSDATE;
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Calling Ibc_Cv_Label_Grp.Update_CV_Label');
	 IBE_UTIL.debug('P_CV_Label_Rec.content_item_id = '||l_cv_label_rec.content_item_id);
	 IBE_UTIL.debug('P_CV_Label_Rec.citem_version_id = '||l_cv_label_rec.citem_version_id);
	 IBE_UTIL.debug('P_CV_Label_Rec.label_code = '||l_cv_label_rec.label_code);
	 IBE_UTIL.debug('P_CV_Label_Rec.last_updated_by = '
	   ||l_cv_label_rec.last_updated_by);
	 IBE_UTIL.debug('P_CV_Label_Rec.last_update_date = '
	   ||to_char(l_cv_label_rec.last_update_date,'MM-DD-RRRR HH24:MI:SS'));
	 IBE_UTIL.debug('P_CV_Label_Rec.object_version_number = '
	   ||l_cv_label_rec.object_version_number);
	 IBE_UTIL.debug('P_CV_Label_Rec.last_update_login = '
	   ||l_cv_label_rec.last_update_login);
	 IBE_UTIL.debug('P_CV_Label_Rec.creation_date = '
	   ||to_char(l_cv_label_rec.creation_date,'MM-DD-RRRR HH24:MI:SS'));
	 IBE_UTIL.debug('P_CV_Label_Rec.created_by = '||l_cv_label_rec.created_by);
      IBE_UTIL.debug('Calling Ibc_Cv_Label_Grp.Create_CV_Label');
	 END IF;
      Ibc_Cv_Label_Grp.Create_CV_Label(
        p_api_version_number => 1.0,
        P_Init_Msg_List => FND_API.G_FALSE,
        P_Commit => FND_API.G_FALSE,
        P_CV_Label_Rec => l_cv_label_rec,
        x_CV_Label_Rec => r_cv_label_rec,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('After calling Ibc_Cv_Label_Grp.Create_CV_Label:'||x_return_status);
	 END IF;
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Update_CV_Label/Create_CV_Label');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
	 RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Update_CV_Label/Create_CV_Label');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Before committing work:'||p_commit);
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('IBE_M_IBC_INT_PVT.Update_Label_Association ends +');
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_LABEL_ASSOCIATION_SAVE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_LABEL_ASSOCIATION_SAVE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_LABEL_ASSOCIATION_SAVE;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('SQLCODE:'||SQLCODE);
    IBE_UTIL.debug('SQLERRM:'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END Update_Label_Association;

PROCEDURE Delete_Label_Association(
  p_api_version IN NUMBER,
  p_init_msg_list IN VARCHAR2,
  p_commit IN VARCHAR2,
  p_content_item_id IN NUMBER,
  p_version_number IN NUMBER,
  p_media_object_id IN NUMBER,
  p_association_type_code IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_version NUMBER := 1.0;
  l_api_name VARCHAR2(50) := 'Delete_Label_Association';
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_content_item_id NUMBER;
  l_association_type_code VARCHAR2(30);
  l_label_code VARCHAR2(30) := g_label_code;
  l_temp NUMBER;
  CURSOR c_associations_flag(c_content_item_id NUMBER,
    c_association_type_code VARCHAR2) IS
    SELECT 1
	 FROM IBC_ASSOCIATIONS
     WHERE content_item_id = c_content_item_id
	  AND association_type_code = c_association_type_code;

  l_debug VARCHAR2(1);
BEGIN
  SAVEPOINT DELETE_LABEL_ASSOCIATION_SAVE;
  l_debug  := NVL(FND_PROFILE.VALUE('IBE_DEBUG'),'N');
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('IBE_M_IBC_INT_PVT.Delete_Label_Association Starts +');
  IBE_UTIL.debug('p_api_version = '||p_api_version);
  IBE_UTIL.debug('p_init_msg_list = '||p_init_msg_list);
  IBE_UTIL.debug('p_commit = '||p_commit);
  IBE_UTIL.debug('p_content_item_id = '||p_content_item_id);
  IBE_UTIL.debug('p_version_number = '||p_version_number);
  IBE_UTIL.debug('p_media_object_id = '||p_media_object_id);
  IBE_UTIL.debug('p_association_type_code = '||p_association_type_code);
  END IF;
  IF NOT FND_API.Compatible_API_Call(l_api_version,
    p_api_version,
    l_api_name,
    G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;
  l_content_item_id := p_content_item_id;
  l_association_type_code := NVL(p_association_type_code,
    g_association_type_code);
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Calling IBC_CITEM_ADMIN_GRP.delete_association starts');
  IBE_UTIL.debug('p_content_item_id = '||l_content_item_id);
  IBE_UTIL.debug('p_association_type_code = '||l_association_type_code);
  IBE_UTIL.debug('p_associated_object_val1 = '||TO_CHAR(p_media_object_id));
  END IF;
  IBC_CITEM_ADMIN_GRP.delete_association(
    p_content_item_id => l_content_item_id,
    p_association_type_code => l_association_type_code,
    p_associated_object_val1 => TO_CHAR(p_media_object_id),
    p_commit => FND_API.g_false,
    p_api_version_number => 1.0,
    p_init_msg_list => FND_API.g_false,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data);
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Calling IBC_CITEM_ADMIN_GRP.delete_association ends:'||x_return_status);
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Error in IBC_CITEM_ADMIN_GRP.delete_association');
    for i in 1..x_msg_count loop
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 IBE_UTIL.debug(l_msg_data);
    end loop;
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Error in IBC_CITEM_ADMIN_GRP.delete_association');
    for i in 1..x_msg_count loop
	 l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	 IBE_UTIL.debug(l_msg_data);
    end loop;
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_temp := 0;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Check the association for the content item');
  IBE_UTIL.debug('l_content_item_id = '||l_content_item_id);
  IBE_UTIL.debug('l_association_type_code = '||l_association_type_code);
  END IF;
  OPEN c_associations_flag(l_content_item_id,
    l_association_type_code);
  FETCH c_associations_flag INTO l_temp;
  IF (c_associations_flag%NOTFOUND) THEN
    l_temp := 0;
  END IF;
  CLOSE c_associations_flag;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('After checking association for the content item:'||l_temp);
  END IF;
  IF (l_temp <> 1) THEN
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('Calling Ibc_Cv_Label_Grp.Delete_CV_Label');
    IBE_UTIL.debug('p_label_code = '||l_label_code);
    IBE_UTIL.debug('p_content_item_id = '||l_content_item_id);
    END IF;
    Ibc_Cv_Label_Grp.Delete_CV_Label(
      P_Api_Version_Number => 1.0,
      P_Init_Msg_List => FND_API.G_FALSE,
      P_Commit => FND_API.G_FALSE,
      p_label_code => l_label_code,
      p_content_item_id => l_content_item_id,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data);
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('After calling Ibc_Cv_Label_Grp.Delete_CV_Label:'||x_return_status);
    END IF;
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Delete_CV_Label');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	 IF (l_debug = 'Y') THEN
      IBE_UTIL.debug('Error in Ibc_Cv_Label_Grp.Delete_CV_Label');
      for i in 1..x_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
	   IBE_UTIL.debug(l_msg_data);
      end loop;
	 END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('Before committing the result:'||p_commit);
  END IF;
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;
  IF (l_debug = 'Y') THEN
  IBE_UTIL.debug('IBE_M_IBC_INT_PVT.Delete_Label_Association ends +');
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
    p_data    => x_msg_data,
    p_encoded => 'F');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DELETE_LABEL_ASSOCIATION_SAVE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DELETE_LABEL_ASSOCIATION_SAVE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
  WHEN OTHERS THEN
    ROLLBACK TO DELETE_LABEL_ASSOCIATION_SAVE;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
    FND_MESSAGE.Set_Token('REASON', SQLERRM);
    FND_MSG_PUB.Add;
    IF (l_debug = 'Y') THEN
    IBE_UTIL.debug('SQLCODE:'||SQLCODE);
    IBE_UTIL.debug('SQLERRM:'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	 p_data    => x_msg_data,
	 p_encoded => 'F');
END Delete_Label_Association;

PROCEDURE Get_Object_Name(
  p_association_type_code IN VARCHAR2,
  p_associated_object_val1 IN VARCHAR2,
  p_associated_object_val2 IN VARCHAR2,
  p_associated_object_val3 IN VARCHAR2,
  p_associated_object_val4 IN VARCHAR2,
  p_associated_object_val5 IN VARCHAR2,
  x_object_name OUT NOCOPY VARCHAR2,
  x_object_code OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Get_Object_Name';
  CURSOR c_get_media_obj_csr(c_media_obj_id IN NUMBER) IS
    SELECT item_name, access_name
      FROM JTF_AMV_ITEMS_VL
     WHERE item_id = c_media_obj_id;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_association_type_code = g_association_type_code THEN
    OPEN c_get_media_obj_csr(p_associated_object_val1);
    FETCH c_get_media_obj_csr INTO x_object_name, x_object_code;
    CLOSE c_get_media_obj_csr;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				  p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				  p_data  => x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
				  p_data  => x_msg_data);
END Get_Object_Name;

END IBE_M_IBC_INT_PVT;

/
