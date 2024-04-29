--------------------------------------------------------
--  DDL for Package Body JTF_MINISITERUNTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MINISITERUNTIME_PVT" AS
/* $Header: JTFVMSRB.pls 115.12 2004/07/09 18:51:54 applrt ship $ */

  -- PACKAGE
  --    JTF_MinisiteRuntime_PVT
  --
  -- PROCEDURES
  --    get_minisite_details
  -- HISTORY
  --    11/19/99  drao  Created
  -- ************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_MINISITERUNTIME_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'JTFVMSRB.pls';

--+
-- Get master mini site id for the store
--+
PROCEDURE Get_Master_Mini_Site_Id
  (
   x_mini_site_id    OUT NUMBER,
   x_root_section_id OUT NUMBER
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Master_Mini_Site_Id';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  CURSOR c1 IS
    SELECT msite_id, msite_root_section_id FROM jtf_msites_b
      WHERE UPPER(master_msite_flag) = 'Y';
BEGIN

  OPEN c1;
  FETCH c1 INTO x_mini_site_id, x_root_section_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c1;

END Get_Master_Mini_Site_Id;

PROCEDURE Get_Msite_Details
  (
   p_api_version         IN NUMBER,
   p_msite_id            IN NUMBER,
   p_access_name         IN VARCHAR2,
   x_master_msite_id     OUT NUMBER,
   x_minisite_cur        OUT minisite_cur_type,
   x_lang_cur            OUT lang_cur_type,
   x_currency_cur        OUT currency_cur_type,
   x_sections_cur        OUT sections_cur_type,
   x_items_cur           OUT items_cur_type,
   x_name_cur            OUT name_cur_type ,
   x_msite_resps_cur     OUT msite_resp_cur_type ,
   x_party_access_cur    OUT msite_prty_access_cur_type,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT NUMBER,
   x_msg_data            OUT VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Msite_Details';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_root_section_id         NUMBER;
  l_application_id          NUMBER       := 671;
  l_exclude_flag            VARCHAR2(10);
  l_msite_id                NUMBER;
  l_master_root_section_id  NUMBER;
  l_msite_not_exists_excp   EXCEPTION;

  Cursor C_msite_Id(p_access_name Varchar2)
  Is Select msite_id,msite_root_section_id
    From   jtf_msites_b
    Where  access_name = p_access_name
--    And    store_id > 0
    And    master_msite_flag =  'N'
    And    sysdate BETWEEN start_date_active
    And    NVL(end_date_active,sysdate) ;

  -- This cursor is used for checking whether a given msite_id is+
  -- valid and enabled for store. Also it is used to fetch the+
  -- root section id for a given minisite.+

  Cursor C_msite_valid(l_c_msite_id Number)
  Is Select msite_root_section_id
    From    jtf_msites_b
      Where  msite_id = l_c_msite_id
--      And    store_id > 0
      And    master_msite_flag =  'N'
      And    sysdate BETWEEN start_date_active
      And    NVL(end_date_active,sysdate) ;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT get_msite_details;
  l_msite_id := p_msite_id ;
  If (l_msite_id IS NULL OR l_msite_id = FND_API.G_MISS_NUM) And
     (p_access_name IS NOT NULL) Then
    Open C_msite_Id(p_access_name);
    Fetch C_msite_Id INTO l_msite_id, l_root_section_id;
    If  C_msite_Id%NOTFOUND Then
      Close C_msite_Id;
      RAISE l_msite_not_exists_excp;
    End If;
    Close C_msite_Id;
  Else
    Open  C_msite_valid(l_msite_id);
    Fetch C_msite_valid INTO l_root_section_id;
    If C_msite_valid%NOTFOUND Then
      Close C_msite_valid;
      RAISE l_msite_not_exists_excp;
    End If;
    Close C_msite_valid;
  End If;

  --+
  -- Get the master mini-site ID
  --+
  Get_Master_Mini_Site_Id
    (
    x_mini_site_id    => x_master_msite_id,
    x_root_section_id => l_master_root_section_id
    );

  --added 3 new fields to the select stmt
  -- access_name, resp_access_flag, party_access_code
  OPEN x_minisite_cur FOR SELECT msite_id,default_language_code,
    default_currency_code,default_org_id,
    walkin_allowed_flag,msite_root_section_id,
    master_msite_flag,atp_check_flag ,
    default_date_format,profile_id,
    access_name, resp_access_flag, party_access_code,
    attribute1,attribute2,attribute3,attribute4,
    attribute5,attribute6,attribute7,attribute8,
    attribute9,attribute10,attribute11,attribute12,
    attribute13,attribute14,attribute15
    FROM jtf_msites_b
    WHERE msite_id = l_msite_id;

  OPEN x_name_cur FOR SELECT a.language_code,
    b.msite_name, b.msite_description
    FROM jtf_msite_languages a, jtf_msites_tl b
    WHERE  a.language_code = b.language
    AND    b.msite_id = a.msite_id
    AND    b.msite_id = l_msite_id;

  OPEN x_lang_cur FOR SELECT language_code from jtf_msite_languages l
    WHERE l.msite_id = l_msite_id;

  OPEN x_currency_cur FOR SELECT currency_code, bizpartner_prc_listid,
    registered_prc_listid, walkin_prc_listid, orderable_limit
    FROM jtf_msite_currencies c
    WHERE c.msite_id = l_msite_id;

  l_exclude_flag :=
    FND_PROFILE.Value_Specific('IBE_USE_CATALOG_EXCLUSIONS',null,null,
                               l_application_id);

  IF (l_exclude_flag IS NULL) THEN
    l_exclude_flag := 'N';
  END IF;

  IF (l_exclude_flag = 'Y')
  THEN

    OPEN x_sections_cur FOR 'SELECT child_section_id '
      || 'FROM jtf_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :master_mini_site_id AND '
      || 'sysdate BETWEEN start_date_active AND NVL(end_date_active,sysdate) '
      || 'AND child_section_id NOT IN '
      || '(SELECT child_section_id FROM jtf_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :msite_id) '
      || 'START WITH child_section_id = :root_section_id '
      || 'AND mini_site_id = :master_mini_site_id '
      || 'CONNECT BY PRIOR child_section_id = parent_section_id '
      || 'AND mini_site_id = :master_mini_site_id '
      || 'AND PRIOR mini_site_id = :master_mini_site_id '
      USING x_master_msite_id, l_msite_id, l_root_section_id,
      x_master_msite_id, x_master_msite_id, x_master_msite_id;

    OPEN x_items_cur FOR 'SELECT inventory_item_id '
      || 'FROM jtf_dsp_section_items '
      || 'WHERE section_item_id IN '
      || '(SELECT section_item_id FROM jtf_dsp_section_items '
      || 'WHERE section_id IN '
      || '(SELECT child_section_id FROM jtf_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :master_mini_site_id '
      || 'AND child_section_id NOT IN '
      || '(SELECT child_section_id FROM jtf_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :msite_id) '
      || 'START WITH child_section_id = :root_section_id '
      || 'AND mini_site_id = :master_mini_site_id '
      || 'CONNECT BY PRIOR child_section_id = parent_section_id '
      || 'AND PRIOR mini_site_id = :master_mini_site_id '
      || 'AND mini_site_id = :master_mini_site_id) '
      || 'OR (section_id IN '
      || '(SELECT child_section_id FROM jtf_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :msite_id) '
      || 'AND section_item_id NOT IN '
      || '(SELECT section_item_id FROM jtf_dsp_msite_sct_items '
      || 'WHERE mini_site_id = :msite_id))) '
      USING x_master_msite_id, l_msite_id, l_root_section_id,
      x_master_msite_id, x_master_msite_id, x_master_msite_id,
      l_msite_id, l_msite_id;

  ELSE

    OPEN x_items_cur FOR select 0 from dual where sysdate < sysdate - 1;
    OPEN x_sections_cur FOR select 0 from dual where sysdate < sysdate - 1;

  END IF; -- end of exclusion block

  -- added to cache the minisite responsibility association -- ssridhar
  OPEN  x_msite_resps_cur FOR Select respb.msite_resp_id,
               respb.responsibility_id ,
               respb.application_id,
               respt.language,
               respt.display_name
        From   jtf_msite_resps_b respb ,
               jtf_msite_resps_tl respt ,
               jtf_msite_languages lang
        Where  respb.msite_id       = l_msite_id
        And    respb.msite_resp_id  = respt.msite_resp_id
        And    lang.msite_id        = respb.msite_id
        And    lang.language_code   = respt.language
        And    sysdate Between respb.start_date_Active
        And    NVL(respb.end_date_active,sysdate)
        ORDER BY respb.msite_resp_id;

  -- added to cache the minisite party access information -- ssridhar
  Open  x_party_access_cur FOR Select Party_id
        From   jtf_msite_prty_accss accss
        Where  accss.msite_id       = l_msite_id
        And    sysdate Between accss.start_date_Active
        And    NVL(accss.end_date_active,sysdate);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_msite_details;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_msite_details;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN l_msite_not_exists_excp THEN
     ROLLBACK TO get_msite_details;
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('JTF','JTF_MSITE_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN OTHERS THEN
     ROLLBACK TO get_msite_details;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );

END Get_Msite_Details;

--+
-- This procedure assumes that the list of mini-site IDs passed in will be
-- the active ones, that is, with store_id > 0 and with valid start_date_active
-- and end_date_active.
-- If p_msite_ids is NULL, then load all the mini-sites which are enabled
-- for store, and put the IDs back in x_msite_ids. If p_msite_ids IS NOT NULL,
-- then don't put IDs back in the x_msite_ids
--+
PROCEDURE Load_Msite_List_Details
  (
   p_api_version         IN  NUMBER,
   p_msite_ids           IN  JTF_NUMBER_TABLE,
   x_msite_ids           OUT JTF_NUMBER_TABLE,
   x_master_msite_id     OUT NUMBER,
   x_minisite_cur        OUT MINISITE_CUR_TYPE,
   x_name_cur            OUT NAME_CUR_TYPE,
   x_lang_cur            OUT LANG_CUR_TYPE,
   x_currency_cur        OUT CURRENCY_CUR_TYPE,
   x_msite_resps_cur     OUT MSITE_RESP_CUR_TYPE,
   x_party_access_cur    OUT MSITE_PRTY_ACCESS_CUR_TYPE,
   x_section_msite_ids   OUT JTF_NUMBER_TABLE,
   x_section_ids         OUT JTF_NUMBER_TABLE,
   x_item_msite_ids      OUT JTF_NUMBER_TABLE,
   x_item_ids            OUT JTF_NUMBER_TABLE,
   x_return_status       OUT VARCHAR2,
   x_msg_count           OUT NUMBER,
   x_msg_data            OUT VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Load_Msite_List_Details';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_master_root_section_id         NUMBER;
  l_application_id                 NUMBER := 671;
  l_exclude_flag                   VARCHAR2(10);
  l_tmp_str                        VARCHAR2(4000);
  l_first_idx                      BINARY_INTEGER;
  l_index                          BINARY_INTEGER;

  CURSOR c1(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER)
  IS SELECT child_section_id
    FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_msite_id AND
    sysdate BETWEEN start_date_active AND NVL(end_date_active,sysdate)
    AND child_section_id NOT IN
    (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_msite_id)
    START WITH child_section_id =
    (SELECT msite_root_section_id FROM jtf_msites_b
    WHERE msite_id = l_c_msite_id)
    AND mini_site_id = l_c_master_msite_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND mini_site_id = l_c_master_msite_id
    AND PRIOR mini_site_id = l_c_master_msite_id;

  -- Description of the SQL
  -- IS SELECT inventory_item_id
  --   FROM jtf_dsp_section_items
  --   WHERE section_item_id IN
  ---- Get all the section items for the excluded sections for the mini-site
  ---- starting from mini-site's root section
  --   (SELECT section_item_id FROM jtf_dsp_section_items
  --   WHERE section_id IN
  --   (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
  --   WHERE mini_site_id = l_c_master_msite_id
  --   AND child_section_id NOT IN
  --   (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
  --   WHERE mini_site_id = l_c_msite_id)
  --   START WITH child_section_id =
  --   (SELECT msite_root_section_id FROM jtf_msites_b
  --   WHERE msite_id = l_c_msite_id)
  --   AND mini_site_id = l_c_master_msite_id
  --   CONNECT BY PRIOR child_section_id = parent_section_id
  --   AND PRIOR mini_site_id = l_c_master_msite_id
  --   AND mini_site_id = l_c_master_msite_id)
  ---- Get all the section items for the included sections for the mini-site
  ---- starting from mini-site's root section, but the section-items themselves
  ---- are excluded.
  --   OR (section_id IN
  --   (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
  --   WHERE mini_site_id = l_c_msite_id)
  --   AND section_item_id NOT IN
  --   (SELECT section_item_id FROM jtf_dsp_msite_sct_items
  --   WHERE mini_site_id = l_c_msite_id)));

  CURSOR c2(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER)
  IS SELECT inventory_item_id
    FROM jtf_dsp_section_items
    WHERE section_item_id IN
    (SELECT section_item_id FROM jtf_dsp_section_items
    WHERE section_id IN
    (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_msite_id
    AND child_section_id NOT IN
    (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_msite_id)
    START WITH child_section_id =
    (SELECT msite_root_section_id FROM jtf_msites_b
    WHERE msite_id = l_c_msite_id)
    AND mini_site_id = l_c_master_msite_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND PRIOR mini_site_id = l_c_master_msite_id
    AND mini_site_id = l_c_master_msite_id)
    OR (section_id IN
    (SELECT child_section_id FROM jtf_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_msite_id)
    AND section_item_id NOT IN
    (SELECT section_item_id FROM jtf_dsp_msite_sct_items
    WHERE mini_site_id = l_c_msite_id)));

  CURSOR c3
  IS SELECT msite_id FROM jtf_msites_b
    WHERE sysdate BETWEEN start_date_active AND NVL(end_date_active, sysdate)
    AND master_msite_flag = 'N';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --+
  -- If p_msite_ids is null, then load all the ids and put it in x_msite_ids
  --+
  x_msite_ids := JTF_NUMBER_TABLE();
  IF (p_msite_ids IS NULL) THEN
    l_index := 1;
    FOR r3 IN c3 LOOP
      x_msite_ids.EXTEND();
      x_msite_ids(l_index) := r3.msite_id;
      l_index := l_index + 1;
    END LOOP;
  ELSE
    x_msite_ids := p_msite_ids;
  END IF;

  l_tmp_str := ' ';
  l_first_idx := x_msite_ids.FIRST;

  IF (x_msite_ids.COUNT <= 0) THEN
    FND_MESSAGE.Set_Name('JTF', 'JTF_MSITE_NO_MSITES_SPECIFIED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Get_Master_Mini_Site_Id
  (
   x_mini_site_id    => x_master_msite_id,
   x_root_section_id => l_master_root_section_id
  );

  --+
  -- Prepare the part of the sql query which does selection based on the input
  --+
  l_tmp_str := 'MM.msite_id IN (' || x_msite_ids(l_first_idx);

  FOR i IN (l_first_idx+1)..x_msite_ids.LAST LOOP
    If x_msite_ids.EXISTS(i) Then
      l_tmp_str := l_tmp_str  || ',' || x_msite_ids(i);
    End If;
  END LOOP; -- end loop i
  l_tmp_str := l_tmp_str  || ') ';

  -- Basic information (from jtf_msites_b table)
  OPEN x_minisite_cur FOR 'SELECT msite_id, default_language_code, '
    || 'default_currency_code, default_org_id, walkin_allowed_flag, '
    || 'msite_root_section_id, master_msite_flag, atp_check_flag, '
    || 'default_date_format, profile_id, access_name, resp_access_flag, '
    || 'party_access_code, attribute1, attribute2, attribute3, attribute4, '
    || 'attribute5, attribute6, attribute7, attribute8, attribute9, '
    || 'attribute10, attribute11, attribute12, attribute13, attribute14, '
    || 'attribute15 '
    || 'FROM jtf_msites_b MM WHERE '
    || l_tmp_str
    || 'ORDER BY msite_id';

  -- Mini-site name and description for all languages
  OPEN x_name_cur FOR 'SELECT MM.msite_id, L.language_code, TL.msite_name, '
    || 'TL.msite_description '
    || 'FROM jtf_msite_languages L, jtf_msites_tl TL, jtf_msites_b MM  WHERE '
    || 'L.language_code = TL.language AND '
    || 'L.msite_id = MM.msite_id AND '
    || 'TL.msite_id = MM.msite_id AND '
    || l_tmp_str
    || 'ORDER BY MM.msite_id';

  -- Language assocation(from jtf_msite_languages table)
  OPEN x_lang_cur FOR 'SELECT MM.msite_id, L.language_code '
    || 'FROM jtf_msite_languages L, jtf_msites_b MM WHERE '
    || 'MM.msite_id = L.msite_id AND '
    || l_tmp_str
    || 'ORDER BY MM.msite_id';

  -- Currency assocation(from jtf_msite_currencies table)
  OPEN x_currency_cur FOR 'SELECT MM.msite_id, C.currency_code, '
    || 'C.bizpartner_prc_listid,C.registered_prc_listid, C.walkin_prc_listid, '
    || 'C.orderable_limit '
    || 'FROM jtf_msite_currencies C, jtf_msites_b MM WHERE '
    || 'MM.msite_id = C.msite_id AND '
    || l_tmp_str
    || 'ORDER BY MM.msite_id';

  -- Mini-site and responsibility association (from jtf_msite_resps_b, _tl)
  OPEN x_msite_resps_cur FOR 'SELECT MM.msite_id, MRB.msite_resp_id, '
    || 'MRB.responsibility_id, MRB.application_id, MRTL.language, '
    || 'MRTL.display_name '
    || 'FROM jtf_msite_resps_b MRB, jtf_msite_resps_tl MRTL, '
    || 'jtf_msites_b MM WHERE '
    || 'MM.msite_id = MRB.msite_id AND '
    || 'MRB.msite_resp_id = MRTL.msite_resp_id AND '
    || 'sysdate BETWEEN MRB.start_date_active AND NVL(MRB.end_date_active,sysdate) AND '
    || l_tmp_str
    || 'ORDER BY MM.msite_id, MRB.msite_resp_id';

  -- Mini-site and party association (from jtf_msite_prty_accss table)
  OPEN x_party_access_cur FOR 'SELECT MM.msite_id, party_id '
    || 'FROM jtf_msite_prty_accss MP, jtf_msites_b MM WHERE '
    || 'MM.msite_id = MP.msite_id AND '
    || 'sysdate BETWEEN MP.start_date_Active AND NVL(MP.end_date_active,sysdate) AND '
    || l_tmp_str
    || 'ORDER BY MM.msite_id';

  --+
  -- Get profile for catalog exclusions
  --+
  l_exclude_flag :=
    FND_PROFILE.Value_Specific('IBE_USE_CATALOG_EXCLUSIONS', null, null,
                               l_application_id);

  IF (l_exclude_flag IS NULL) THEN
    l_exclude_flag := 'N';
  END IF;

  -- Initialize the variables
  x_section_msite_ids := JTF_NUMBER_TABLE();
  x_section_ids       := JTF_NUMBER_TABLE();
  x_item_msite_ids    := JTF_NUMBER_TABLE();
  x_item_ids          := JTF_NUMBER_TABLE();

  IF (l_exclude_flag = 'Y') THEN

    -- For sections
    l_index := 1;
    FOR i IN 1..x_msite_ids.COUNT LOOP

      FOR r1 IN c1(x_master_msite_id, x_msite_ids(i)) LOOP
        x_section_msite_ids.EXTEND();
        x_section_ids.EXTEND();
        x_section_msite_ids(l_index) := x_msite_ids(i);
        x_section_ids(l_index)       := r1.child_section_id;
        l_index := l_index + 1;
      END LOOP; -- end loop r1

    END LOOP; -- end loop i

    -- For items
    l_index := 1;
    FOR i IN 1..x_msite_ids.COUNT LOOP

      FOR r2 IN c2(x_master_msite_id, x_msite_ids(i)) LOOP
        x_item_msite_ids.EXTEND();
        x_item_ids.EXTEND();
        x_item_msite_ids(l_index) := x_msite_ids(i);
        x_item_ids(l_index)       := r2.inventory_item_id;
        l_index := l_index + 1;
      END LOOP; -- end loop r2

    END LOOP; -- end loop i

  END IF; -- end of exclusion block

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count,
                               p_data    => x_msg_data);

End  Load_Msite_List_Details ;

END JTF_MinisiteRuntime_PVT;

/
