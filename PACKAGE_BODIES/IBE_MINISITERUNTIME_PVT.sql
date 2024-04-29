--------------------------------------------------------
--  DDL for Package Body IBE_MINISITERUNTIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_MINISITERUNTIME_PVT" AS
/* $Header: IBEVMSRB.pls 120.6.12010000.3 2014/07/14 10:55:12 kdosapat ship $ */

  -- PACKAGE
  --    IBE_MinisiteRuntime_PVT
  --
  -- PROCEDURES
  --    get_minisite_details
  -- HISTORY
  --    11/19/99  drao  Created
  --    01/02/02  ssridhar modified to support bind variables in
  --                       load_msite_list_details.
  --    06/10/02 add payment threshold
  --    08/06/02 remove the validation of start_date and end_date for minisite and resp
  --             instea, add the start_date and end_date into the cursor
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.
  --   01/16/09  Bug 7676477 scnagara Removed loading of excluded items, excluded sections from Get_Msite_Details
  --                         procedure,Added Get_Msite_Excluded_Items and Get_Msite_Excluded_Sections procedures
  --   07/14/14  Bug 19064720 - UPGRADED ITEMS ARE SHOWN AS EXCLUDED FROM THE MINISITE IN LOGGING DETAIL
  -- ************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IBE_MINISITERUNTIME_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVMSRB.pls';

--+
-- Get master mini site id for the store
--+
PROCEDURE Get_Master_Mini_Site_Id
  (
   x_mini_site_id    OUT NOCOPY NUMBER,
   x_root_section_id OUT NOCOPY NUMBER
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Master_Mini_Site_Id';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  CURSOR c1 IS
    SELECT msite_id, msite_root_section_id FROM ibe_msites_b
      WHERE UPPER(master_msite_flag) = 'Y' and site_type = 'I';
BEGIN

  OPEN c1;
  FETCH c1 INTO x_mini_site_id, x_root_section_id;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c1;

END Get_Master_Mini_Site_Id;


-- Bug 7676477, scnagara
 PROCEDURE Get_Msite_Excluded_Items
  (
 	    p_api_version         IN NUMBER,
 	    p_msite_id            IN NUMBER,
 	    p_access_name         IN VARCHAR2,
 	    x_item_ids            OUT NOCOPY JTF_NUMBER_TABLE,
 	    x_return_status       OUT NOCOPY VARCHAR2,
 	    x_msg_count           OUT NOCOPY NUMBER,
 	    x_msg_data            OUT NOCOPY VARCHAR2
  )
 	  IS
 	  Cursor C_msite_valid(l_c_msite_id Number)
		  Is Select msite_root_section_id
		     From    ibe_msites_b
		     Where  msite_id = l_c_msite_id
		     And    master_msite_flag =  'N' and site_type = 'I';

 	 Cursor C_msite_Id(p_access_name Varchar2)
		Is Select msite_id,msite_root_section_id
		From   ibe_msites_b
		Where  access_name = p_access_name
		And    master_msite_flag =  'N' and site_type = 'I';

	 CURSOR c2(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER,
		l_root_section_id IN NUMBER) IS
	SELECT  /*+ first_rows */ inventory_item_id
	FROM    (
          SELECT  section_item_id, inventory_item_id
          FROM    ibe_dsp_section_items idsi
          WHERE   section_id IN
                  (
                  SELECT  child_section_id
                  FROM    ibe_dsp_msite_sct_sects s1
                  WHERE   mini_site_id = l_c_master_msite_id
                  AND     NOT EXISTS
                          (
                          SELECT  child_section_id
                          FROM    ibe_dsp_msite_sct_sects s2
                          WHERE   mini_site_id = l_c_msite_id
                          AND     s2.child_section_id = s1.child_section_id
                          )
                  CONNECT BY PRIOR child_section_id = parent_section_id
                  AND     PRIOR mini_site_id = l_c_master_msite_id
                  AND     mini_site_id = l_c_master_msite_id
                  START WITH child_section_id = l_root_section_id
                  AND     mini_site_id = l_c_master_msite_id
                  )
          AND NOT EXISTS
          (
             SELECT inventory_item_id
             FROM   ibe_dsp_section_items i1, ibe_dsp_msite_sct_items i2
             WHERE  i1.section_item_id  = i2.section_item_id
             AND    i2.mini_site_id = l_c_msite_id
		   AND    i1.inventory_item_id = idsi.inventory_item_id
          )
          UNION
          SELECT  section_item_id, inventory_item_id
          FROM    ibe_dsp_msite_sct_sects s3,
                  ibe_dsp_section_items i2
          WHERE   i2.section_id = s3.child_section_id
		AND     s3.mini_site_id = l_c_msite_id
          AND     NOT EXISTS
                  (
                  SELECT  null
                  FROM    ibe_dsp_msite_sct_items i3
                  WHERE   mini_site_id = l_c_msite_id
                  AND     i3.section_item_id = i2.section_item_id
                  )
          );

 	    l_root_section_id         NUMBER;
 	    l_master_root_section_id  NUMBER;
 	    l_master_msite_id         NUMBER;
 	    l_msite_id                NUMBER;
	    l_index                   BINARY_INTEGER;
 	    l_msite_not_exists_excp   EXCEPTION;
 	    l_api_name                CONSTANT VARCHAR2(30) := 'Get_Msite_Excluded_Items';
 	   BEGIN
 	    x_return_status := FND_API.G_RET_STS_SUCCESS;

 	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
 	      IBE_Util.Debug('IBE_MinisiteRuntime_PVT.Get_Msite_Excluded_Items start');
 	   END IF;

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
 	     End If;

 	   --+
 	   -- Get the master mini-site ID
 	   --+
 	   Get_Master_Mini_Site_Id
 	     (
 	     x_mini_site_id    => l_master_msite_id,
 	     x_root_section_id => l_master_root_section_id
 	     );

 	   l_index := 1;
	   x_item_ids          := JTF_NUMBER_TABLE();
	   OPEN C_msite_valid(l_msite_id);
	   FETCH C_msite_valid INTO l_root_section_id;
	   CLOSE C_msite_valid;
           FOR r2 IN c2(l_master_msite_id, l_msite_id,l_root_section_id) LOOP
	        x_item_ids.EXTEND();
	        x_item_ids(l_index)       := r2.inventory_item_id;
	        l_index := l_index + 1;
	    END LOOP; -- end loop r2

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

     WHEN l_msite_not_exists_excp THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );

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
 END Get_Msite_Excluded_Items;
-- Bug 7676477, scnagara
-- bug 19064720 - overloaded Get_Msite_Excluded_Items method with extra input parameter p_org_id for bug 19064720 fix
 PROCEDURE Get_Msite_Excluded_Items
  (
 	    p_api_version         IN NUMBER,
 	    p_msite_id            IN NUMBER,
 	    p_access_name         IN VARCHAR2,
      p_org_id              IN NUMBER, -- bug 19064720
 	    x_item_ids            OUT NOCOPY JTF_NUMBER_TABLE,
 	    x_return_status       OUT NOCOPY VARCHAR2,
 	    x_msg_count           OUT NOCOPY NUMBER,
 	    x_msg_data            OUT NOCOPY VARCHAR2
  )
 	  IS
 	  Cursor C_msite_valid(l_c_msite_id Number)
		  Is Select msite_root_section_id
		     From    ibe_msites_b
		     Where  msite_id = l_c_msite_id
		     And    master_msite_flag =  'N' and site_type = 'I';
 	 Cursor C_msite_Id(p_access_name Varchar2)
		Is Select msite_id,msite_root_section_id
		From   ibe_msites_b
		Where  access_name = p_access_name
		And    master_msite_flag =  'N' and site_type = 'I';
	 CURSOR c2(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER,
		l_root_section_id IN NUMBER,l_c_org_id IN NUMBER) IS -- bug 19064720
	SELECT  /*+ first_rows */ inventory_item_id
	FROM    (
          SELECT  section_item_id, inventory_item_id
          FROM    ibe_dsp_section_items idsi
          WHERE   section_id IN
                  (
                  SELECT  child_section_id
                  FROM    ibe_dsp_msite_sct_sects s1
                  WHERE   mini_site_id = l_c_master_msite_id
                  AND     NOT EXISTS
                          (
                          SELECT  child_section_id
                          FROM    ibe_dsp_msite_sct_sects s2
                          WHERE   mini_site_id = l_c_msite_id
                          AND     s2.child_section_id = s1.child_section_id
                          )
                  CONNECT BY PRIOR child_section_id = parent_section_id
                  AND     PRIOR mini_site_id = l_c_master_msite_id
                  AND     mini_site_id = l_c_master_msite_id
                  START WITH child_section_id = l_root_section_id
                  AND     mini_site_id = l_c_master_msite_id
                  )
          AND idsi.organization_id = l_c_org_id -- bug 19064720
          AND NOT EXISTS
          (
             SELECT inventory_item_id
             FROM   ibe_dsp_section_items i1, ibe_dsp_msite_sct_items i2
             WHERE  i1.section_item_id  = i2.section_item_id
             AND    i2.mini_site_id = l_c_msite_id
		   AND    i1.inventory_item_id = idsi.inventory_item_id
          )
          UNION
          SELECT  section_item_id, inventory_item_id
          FROM    ibe_dsp_msite_sct_sects s3,
                  ibe_dsp_section_items i2
          WHERE   i2.section_id = s3.child_section_id
          AND     i2.organization_id = l_c_org_id -- bug 19064720
		      AND     s3.mini_site_id = l_c_msite_id
          AND     NOT EXISTS
                  (
                  SELECT  null
                  FROM    ibe_dsp_msite_sct_items i3
                  WHERE   mini_site_id = l_c_msite_id
                  AND     i3.section_item_id = i2.section_item_id
                  )
          );
 	    l_root_section_id         NUMBER;
 	    l_master_root_section_id  NUMBER;
 	    l_master_msite_id         NUMBER;
 	    l_msite_id                NUMBER;
      l_org_id                  NUMBER; -- bug 19064720
	    l_index                   BINARY_INTEGER;
 	    l_msite_not_exists_excp   EXCEPTION;
 	    l_api_name                CONSTANT VARCHAR2(30) := 'Get_Msite_Excluded_Items';
 	   BEGIN
 	    x_return_status := FND_API.G_RET_STS_SUCCESS;
 	   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
 	      IBE_Util.Debug('19064720 - IBE_MinisiteRuntime_PVT.Get_Msite_Excluded_Items start');
        IBE_Util.Debug('19064720 - IBE_MinisiteRuntime_PVT.Get_Msite_Excluded_Items : p_access_name input value = ' || p_access_name);
        IBE_Util.Debug('19064720 - IBE_MinisiteRuntime_PVT.Get_Msite_Excluded_Items : p_msite_id input value = ' || p_msite_id);
 	   END IF;
 	    l_msite_id := p_msite_id ;
      l_org_id := p_org_id; -- bug 19064720
 	    If (l_msite_id IS NULL OR l_msite_id = FND_API.G_MISS_NUM) And
 	      (p_access_name IS NOT NULL) Then
 	             Open C_msite_Id(p_access_name);
 	             Fetch C_msite_Id INTO l_msite_id, l_root_section_id;
 	             If  C_msite_Id%NOTFOUND Then
 	               Close C_msite_Id;
 	               RAISE l_msite_not_exists_excp;
 	             End If;
 	             Close C_msite_Id;
 	     End If;

      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_Util.Debug('19064720 - l_msite_id ==' || l_msite_id);
      IBE_Util.Debug('19064720 - l_root_section_id ==' || l_root_section_id);
       END IF;
 	   --+
 	   -- Get the master mini-site ID
 	   --+
 	   Get_Master_Mini_Site_Id
 	     (
 	     x_mini_site_id    => l_master_msite_id,
 	     x_root_section_id => l_master_root_section_id
 	     );

    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_Util.Debug('19064720 - l_master_msite_id ==' || l_master_msite_id);
      IBE_Util.Debug('19064720 - l_master_root_section_id ==' || l_master_root_section_id);
       END IF;
 	   l_index := 1;
	   x_item_ids          := JTF_NUMBER_TABLE();
	   OPEN C_msite_valid(l_msite_id);
	   FETCH C_msite_valid INTO l_root_section_id;
	   CLOSE C_msite_valid;
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_Util.Debug('19064720 - l_root_section_id ==' || l_root_section_id);
       END IF;
           FOR r2 IN c2(l_master_msite_id, l_msite_id,l_root_section_id,l_org_id) LOOP -- bug 19064720
	        x_item_ids.EXTEND();
	        x_item_ids(l_index)       := r2.inventory_item_id;
	        l_index := l_index + 1;
	    END LOOP; -- end loop r2
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
     WHEN l_msite_not_exists_excp THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
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
 END Get_Msite_Excluded_Items;
 -- Bug 7676477, scnagara
 PROCEDURE Get_Msite_Excluded_Sections
   (
 	    p_api_version         IN NUMBER,
 	    p_msite_id            IN NUMBER,
 	    p_access_name         IN VARCHAR2,
 	    x_section_ids         OUT NOCOPY JTF_NUMBER_TABLE,
 	    x_return_status       OUT NOCOPY VARCHAR2,
 	    x_msg_count           OUT NOCOPY NUMBER,
 	    x_msg_data            OUT NOCOPY VARCHAR2
   )
   IS
	l_index                   BINARY_INTEGER;
	l_master_msite_id         NUMBER;
	l_master_root_section_id  NUMBER;
	l_msite_id                NUMBER;
	l_root_section_id         NUMBER;
        l_msite_not_exists_excp   EXCEPTION;
	l_api_name                CONSTANT VARCHAR2(30) :=
					'Get_Msite_Excluded_Sections';

	CURSOR c1(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER)
	IS SELECT child_section_id
	FROM ibe_dsp_msite_sct_sects
	WHERE mini_site_id = l_c_master_msite_id AND
	    sysdate BETWEEN start_date_active AND NVL(end_date_active,sysdate)
	    AND child_section_id NOT IN
	    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
	    WHERE mini_site_id = l_c_msite_id)
	    START WITH child_section_id =
	    (SELECT msite_root_section_id FROM ibe_msites_b
	    WHERE msite_id = l_c_msite_id)
	    AND mini_site_id = l_c_master_msite_id
	    CONNECT BY PRIOR child_section_id = parent_section_id
	    AND mini_site_id = l_c_master_msite_id
	    AND PRIOR mini_site_id = l_c_master_msite_id;

	Cursor C_msite_Id(p_access_name Varchar2)
	Is Select msite_id,msite_root_section_id
	    From   ibe_msites_b
	    Where  access_name = p_access_name
	    And    master_msite_flag =  'N' and site_type = 'I';

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

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
  End If;

Get_Master_Mini_Site_Id
  (
   x_mini_site_id    => l_master_msite_id,
   x_root_section_id => l_master_root_section_id
  );

 x_section_ids       := JTF_NUMBER_TABLE();
 l_index := 1;
 FOR r1 IN c1(l_master_msite_id, l_msite_id) LOOP
        x_section_ids.EXTEND();
        x_section_ids(l_index)       := r1.child_section_id;
        l_index := l_index + 1;
  END LOOP; -- end loop r1

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

   WHEN l_msite_not_exists_excp THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );

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

END Get_Msite_Excluded_Sections;


PROCEDURE Get_Msite_Details
  (
   p_api_version         IN NUMBER,
   p_msite_id            IN NUMBER,
   p_access_name         IN VARCHAR2,
   x_master_msite_id     OUT NOCOPY NUMBER,
   x_minisite_cur        OUT NOCOPY minisite_cur_type,
   x_lang_cur            OUT NOCOPY lang_cur_type,
   x_currency_cur        OUT NOCOPY currency_cur_type,
   x_sections_cur        OUT NOCOPY sections_cur_type,
   x_items_cur           OUT NOCOPY items_cur_type,
   x_name_cur            OUT NOCOPY name_cur_type ,
   x_msite_resps_cur     OUT NOCOPY msite_resp_cur_type ,
   x_party_access_cur    OUT NOCOPY msite_prty_access_cur_type,
   x_pm_cc_sm_cur        OUT NOCOPY pm_cc_sm_cur_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
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
    From   ibe_msites_b
    Where  access_name = p_access_name
    And    master_msite_flag =  'N' and site_type = 'I';
    -- removed by YAXU on 08/06/02
    -- And    sysdate BETWEEN start_date_active
    -- And    NVL(end_date_active,sysdate) ;

  -- This cursor is used for checking whether a given msite_id is+
  -- valid and enabled for store. Also it is used to fetch the+
  -- root section id for a given minisite.+

  Cursor C_msite_valid(l_c_msite_id Number)
  Is Select msite_root_section_id
    From    ibe_msites_b
      Where  msite_id = l_c_msite_id
      And    master_msite_flag =  'N' and site_type = 'I';
      -- removed by YAXU on 08/06/02
      -- And    sysdate BETWEEN start_date_active
      -- And    NVL(end_date_active,sysdate) ;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

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
    attribute13,attribute14,attribute15,
    payment_threshold_enable_flag, --added by YAXU for payment threshold
    start_date_active, end_date_active -- added by YAXU on 08/06/02
    FROM ibe_msites_b
    WHERE msite_id = l_msite_id
      AND site_type = 'I';

  OPEN x_name_cur FOR SELECT a.language_code,
    b.msite_name, b.msite_description
    FROM ibe_msite_languages a, ibe_msites_tl b
    WHERE  a.language_code = b.language
    AND    b.msite_id = a.msite_id
    AND    b.msite_id = l_msite_id;

  OPEN x_lang_cur FOR SELECT language_code from ibe_msite_languages l
    WHERE l.msite_id = l_msite_id
    AND   l.enable_flag = 'Y';

  OPEN x_currency_cur FOR SELECT currency_code, bizpartner_prc_listid,
    registered_prc_listid, walkin_prc_listid, orderable_limit,
    payment_threshold, partner_prc_listid -- added by YAXU for payment threshold
    FROM ibe_msite_currencies c
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
      || 'FROM ibe_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :master_mini_site_id AND '
      || 'sysdate BETWEEN start_date_active AND NVL(end_date_active,sysdate) '
      || 'AND child_section_id NOT IN '
      || '(SELECT child_section_id FROM ibe_dsp_msite_sct_sects '
      || 'WHERE mini_site_id = :msite_id) '
      || 'START WITH child_section_id = :root_section_id '
      || 'AND mini_site_id = :master_mini_site_id '
      || 'CONNECT BY PRIOR child_section_id = parent_section_id '
      || 'AND mini_site_id = :master_mini_site_id '
      || 'AND PRIOR mini_site_id = :master_mini_site_id '
      USING x_master_msite_id, l_msite_id, l_root_section_id,
      x_master_msite_id, x_master_msite_id, x_master_msite_id;

  OPEN x_items_cur FOR 'SELECT  /*+ first_rows */ inventory_item_id '
    || 'FROM    ( '
    || '        SELECT  section_item_id '
    || '        FROM    ibe_dsp_section_items '
    || '        WHERE   section_id IN '
    || '                ( '
    || '                SELECT  child_section_id '
    || '                FROM    ibe_dsp_msite_sct_sects s1 '
    || '                WHERE   mini_site_id = :l_c_master_msite_id '
    || '                AND     NOT EXISTS '
    || '                        ( '
    || '                        SELECT  child_section_id '
    || '                        FROM    ibe_dsp_msite_sct_sects s2 '
    || '                        WHERE   mini_site_id = :l_c_msite_id '
    || '                        AND     s2.child_section_id = s1.child_section_id '
    || '                        ) '
    || '                CONNECT BY PRIOR child_section_id = parent_section_id '
    || '                AND     PRIOR mini_site_id = :l_c_master_msite_id '
    || '                AND     mini_site_id = :l_c_master_msite_id '
    || '                START WITH child_section_id = '
    || '                                ( '
    || '                                SELECT  msite_root_section_id '
    || '                                FROM    ibe_msites_b '
    || '                                WHERE   msite_id = :l_c_msite_id '
    || '                                ) '
    || '                AND     mini_site_id = :l_c_master_msite_id '
    || '                ) '
    || '        AND inventory_item_id NOT IN '
    || '        ( '
    || '          SELECT inventory_item_id '
    || '          FROM   ibe_dsp_section_items i1, ibe_dsp_msite_sct_items i2 '
    || '          WHERE  i1.section_item_id  = i2.section_item_id '
    || '          AND    i2.mini_site_id = :l_c_msite_id '
    || '        ) '
    || '        UNION '
    || '        SELECT  /*+ ordered use_nl(s3,i2) */ section_item_id '
    || '        FROM    ( '
    || '                SELECT  child_section_id '
    || '                FROM    ibe_dsp_msite_sct_sects '
    || '                WHERE   mini_site_id = :l_c_msite_id '
    || '                ) s3, '
    || '                ibe_dsp_section_items i2 '
    || '        WHERE   i2.section_id = s3.child_section_id '
    || '        AND     NOT EXISTS '
    || '                ( '
    || '                SELECT  null '
    || '                FROM    ibe_dsp_msite_sct_items i3 '
    || '                WHERE   mini_site_id = :l_c_msite_id '
    || '                AND     i3.section_item_id = i2.section_item_id '
    || '                ) '
    || '        ) v1, '
    || '        ibe_dsp_section_items i0 '
    || 'WHERE   i0.section_item_id = v1.section_item_id'
    USING x_master_msite_id, l_msite_id, x_master_msite_id, x_master_msite_id,
    l_msite_id, x_master_msite_id, l_msite_id, l_msite_id, l_msite_id;

  -- OPEN x_items_cur FOR 'SELECT inventory_item_id '
  -- || 'FROM ibe_dsp_section_items '
  -- || 'WHERE section_item_id IN '
  -- || '(SELECT section_item_id FROM ibe_dsp_section_items '
  -- || 'WHERE section_id IN '
  -- || '(SELECT child_section_id FROM ibe_dsp_msite_sct_sects '
  -- || 'WHERE mini_site_id = :master_mini_site_id '
  -- || 'AND child_section_id NOT IN '
  -- || '(SELECT child_section_id FROM ibe_dsp_msite_sct_sects '
  -- || 'WHERE mini_site_id = :msite_id) '
  -- || 'START WITH child_section_id = :root_section_id '
  -- || 'AND mini_site_id = :master_mini_site_id '
  -- || 'CONNECT BY PRIOR child_section_id = parent_section_id '
  -- || 'AND PRIOR mini_site_id = :master_mini_site_id '
  -- || 'AND mini_site_id = :master_mini_site_id) '
  -- || 'OR (section_id IN '
  -- || '(SELECT child_section_id FROM ibe_dsp_msite_sct_sects '
  -- || 'WHERE mini_site_id = :msite_id) '
  -- || 'AND section_item_id NOT IN '
  -- || '(SELECT section_item_id FROM ibe_dsp_msite_sct_items '
  -- || 'WHERE mini_site_id = :msite_id))) '
  -- USING x_master_msite_id, l_msite_id, l_root_section_id,
  -- x_master_msite_id, x_master_msite_id, x_master_msite_id,
  -- l_msite_id, l_msite_id;

  ELSE

    OPEN x_items_cur FOR select 0 from dual where sysdate < sysdate - 1;
    OPEN x_sections_cur FOR select 0 from dual where sysdate < sysdate - 1;

  END IF; -- end of exclusion block

  -- added to cache the minisite responsibility association -- ssridhar
  OPEN  x_msite_resps_cur FOR Select respb.msite_resp_id,
               respb.responsibility_id ,
               respb.application_id,
               respt.language,
               respt.display_name,
               respb.start_date_active, respb.end_date_active -- added by YAXU on 08/06/02
        From   ibe_msite_resps_b respb ,
               ibe_msite_resps_tl respt ,
               ibe_msite_languages lang
        Where  respb.msite_id       = l_msite_id
        And    respb.msite_resp_id  = respt.msite_resp_id
        And    lang.msite_id        = respb.msite_id
        And    lang.language_code   = respt.language
        -- And    sysdate Between respb.start_date_Active
        -- And    NVL(respb.end_date_active,sysdate)  -- removed by YAXU on 08/06/02
        ORDER BY respb.msite_resp_id;

  -- added to cache the minisite party access information -- ssridhar
  Open  x_party_access_cur FOR Select Party_id
        From   ibe_msite_prty_accss accss
        Where  accss.msite_id       = l_msite_id
        And    sysdate Between accss.start_date_Active
        And    NVL(accss.end_date_active,sysdate);

  -- For payment method, credit card type, and shipment method
  OPEN x_pm_cc_sm_cur FOR SELECT msite_information_context, msite_information1,
    msite_information2 -- added by YAXU for payment threshold
    FROM ibe_msite_information
    WHERE msite_id = l_msite_id
    AND msite_information_context = 'SHPMT_MTHD'
    UNION  -- added by JQU for validating the TAG.
    SELECT msite_information_context, msite_information1,
    msite_information2 -- added by YAXU for payment threshold
    FROM ibe_msite_information a, fnd_lookup_values b
    WHERE a.msite_id = l_msite_id
    AND a.msite_information1 = b.lookup_code
    AND ((b.LOOKUP_TYPE= 'CREDIT_CARD' and b.VIEW_APPLICATION_ID='660' )
    OR  (b.LOOKUP_TYPE = 'IBE_PAYMENT_TYPE'))
    AND b.ENABLED_FLAG='Y' AND (b.TAG='Y' or b.TAG is null)
    AND b.language=userenv('lang')
    UNION
    SELECT msite_information_context, msite_information1,
    msite_information2
    FROM ibe_msite_information a, iby_creditcard_issuers_b cc
    WHERE a.msite_id = l_msite_id
    AND a.msite_information1 = cc.card_issuer_code
    ORDER BY msite_information_context;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN l_msite_not_exists_excp THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MESSAGE.set_name('IBE','IBE_MSITE_NOT_EXISTS');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN OTHERS THEN
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

PROCEDURE Get_Quote_Details
  (
   p_api_version         IN NUMBER,
   p_quote_id            IN NUMBER,
   x_ship_method_cur     OUT NOCOPY ship_method_cur_type,
   x_payment_method_cur  OUT NOCOPY payment_method_cur_type,
   x_quote_detail_cur    OUT NOCOPY quote_detail_cur_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) :=
    'Get_Quote_Details';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_quote_id                NUMBER;

BEGIN

  l_quote_id := p_quote_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN x_ship_method_cur FOR SELECT SHIP_METHOD_CODE
    FROM aso_shipments where quote_header_id = l_quote_id;

  OPEN x_payment_method_cur FOR SELECT payment_type_code, credit_card_code
    FROM aso_payments where quote_header_id = l_quote_id;

  OPEN x_quote_detail_cur FOR SELECT currency_code, user_name,
    total_quote_price
    FROM aso_quote_headers_all A, fnd_user F
    WHERE A.quote_header_id = l_quote_id
    AND A.party_id = F.customer_id;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.count_and_get(
                 p_encoded => FND_API.g_false,
                 p_count   => x_msg_count,
                 p_data    => x_msg_data );
   WHEN OTHERS THEN
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

END Get_Quote_Details;

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
   x_msite_ids           OUT NOCOPY JTF_NUMBER_TABLE,
   x_master_msite_id     OUT NOCOPY NUMBER,
   x_minisite_cur        OUT NOCOPY minisite_cur_type,
   x_name_cur            OUT NOCOPY name_cur_type,
   x_lang_cur            OUT NOCOPY lang_cur_type,
   x_currency_cur        OUT NOCOPY currency_cur_type,
   x_msite_resps_cur     OUT NOCOPY msite_resp_cur_type,
   x_party_access_cur    OUT NOCOPY msite_prty_access_cur_type,
   x_section_msite_ids   OUT NOCOPY JTF_NUMBER_TABLE,
   x_section_ids         OUT NOCOPY JTF_NUMBER_TABLE,
   x_item_msite_ids      OUT NOCOPY JTF_NUMBER_TABLE,
   x_item_ids            OUT NOCOPY JTF_NUMBER_TABLE,
   x_pm_cc_sm_cur        OUT NOCOPY pm_cc_sm_cur_type,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
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
  l_root_section_id                NUMBER;

  CURSOR c1(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER)
  IS SELECT child_section_id
    FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_master_msite_id AND
    sysdate BETWEEN start_date_active AND NVL(end_date_active,sysdate)
    AND child_section_id NOT IN
    (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
    WHERE mini_site_id = l_c_msite_id)
    START WITH child_section_id =
    (SELECT msite_root_section_id FROM ibe_msites_b
    WHERE msite_id = l_c_msite_id)
    AND mini_site_id = l_c_master_msite_id
    CONNECT BY PRIOR child_section_id = parent_section_id
    AND mini_site_id = l_c_master_msite_id
    AND PRIOR mini_site_id = l_c_master_msite_id;

  -- Description of the SQL
  -- IS SELECT inventory_item_id
  --   FROM ibe_dsp_section_items
  --   WHERE section_item_id IN
  ---- Get all the section items for the excluded sections for the mini-site
  ---- starting from mini-site's root section
  --   (SELECT section_item_id FROM ibe_dsp_section_items
  --   WHERE section_id IN
  --   (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
  --   WHERE mini_site_id = l_c_master_msite_id
  --   AND child_section_id NOT IN
  --   (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
  --   WHERE mini_site_id = l_c_msite_id)
  --   START WITH child_section_id =
  --   (SELECT msite_root_section_id FROM ibe_msites_b
  --   WHERE msite_id = l_c_msite_id)
  --   AND mini_site_id = l_c_master_msite_id
  --   CONNECT BY PRIOR child_section_id = parent_section_id
  --   AND PRIOR mini_site_id = l_c_master_msite_id
  --   AND mini_site_id = l_c_master_msite_id)
  ---- Get all the section items for the included sections for the mini-site
  ---- starting from mini-site's root section, but the section-items themselves
  ---- are excluded.
  --   OR (section_id IN
  --   (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
  --   WHERE mini_site_id = l_c_msite_id)
  --   AND section_item_id NOT IN
  --   (SELECT section_item_id FROM ibe_dsp_msite_sct_items
  --   WHERE mini_site_id = l_c_msite_id)));

  --
  -- Changing the cursor to new cursor based on new performance query
  --
  -- CURSOR c2(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER)
  -- IS SELECT inventory_item_id
  -- FROM ibe_dsp_section_items
  -- WHERE section_item_id IN
  -- (SELECT section_item_id FROM ibe_dsp_section_items
  -- WHERE section_id IN
  -- (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
  -- WHERE mini_site_id = l_c_master_msite_id
  -- AND child_section_id NOT IN
  -- (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
  -- WHERE mini_site_id = l_c_msite_id)
  -- START WITH child_section_id =
  -- (SELECT msite_root_section_id FROM ibe_msites_b
  -- WHERE msite_id = l_c_msite_id)
  -- AND mini_site_id = l_c_master_msite_id
  -- CONNECT BY PRIOR child_section_id = parent_section_id
  -- AND PRIOR mini_site_id = l_c_master_msite_id
  -- AND mini_site_id = l_c_master_msite_id)
  -- OR (section_id IN
  -- (SELECT child_section_id FROM ibe_dsp_msite_sct_sects
  -- WHERE mini_site_id = l_c_msite_id)
  -- AND section_item_id NOT IN
  -- (SELECT section_item_id FROM ibe_dsp_msite_sct_items
  -- WHERE mini_site_id = l_c_msite_id)));

  CURSOR c2(l_c_master_msite_id IN NUMBER, l_c_msite_id IN NUMBER,
    l_root_section_id IN NUMBER) IS
  SELECT  /*+ first_rows */ inventory_item_id
  FROM    (
          SELECT  section_item_id, inventory_item_id
          FROM    ibe_dsp_section_items idsi
          WHERE   section_id IN
                  (
                  SELECT  child_section_id
                  FROM    ibe_dsp_msite_sct_sects s1
                  WHERE   mini_site_id = l_c_master_msite_id
                  AND     NOT EXISTS
                          (
                          SELECT  child_section_id
                          FROM    ibe_dsp_msite_sct_sects s2
                          WHERE   mini_site_id = l_c_msite_id
                          AND     s2.child_section_id = s1.child_section_id
                          )
                  CONNECT BY PRIOR child_section_id = parent_section_id
                  AND     PRIOR mini_site_id = l_c_master_msite_id
                  AND     mini_site_id = l_c_master_msite_id
                  START WITH child_section_id = l_root_section_id
                  AND     mini_site_id = l_c_master_msite_id
                  )
          AND NOT EXISTS
          (
             SELECT inventory_item_id
             FROM   ibe_dsp_section_items i1, ibe_dsp_msite_sct_items i2
             WHERE  i1.section_item_id  = i2.section_item_id
             AND    i2.mini_site_id = l_c_msite_id
		   AND    i1.inventory_item_id = idsi.inventory_item_id
          )
          UNION
          SELECT  section_item_id, inventory_item_id
          FROM    ibe_dsp_msite_sct_sects s3,
                  ibe_dsp_section_items i2
          WHERE   i2.section_id = s3.child_section_id
		AND     s3.mini_site_id = l_c_msite_id
          AND     NOT EXISTS
                  (
                  SELECT  null
                  FROM    ibe_dsp_msite_sct_items i3
                  WHERE   mini_site_id = l_c_msite_id
                  AND     i3.section_item_id = i2.section_item_id
                  )
          );

--  SELECT  /*+ first_rows */ inventory_item_id
--  FROM    (
--          SELECT  section_item_id
--          FROM    ibe_dsp_section_items
--          WHERE   section_id IN
--                  (
--                  SELECT  child_section_id
--                  FROM    ibe_dsp_msite_sct_sects s1
--                  WHERE   mini_site_id = l_c_master_msite_id
--                  AND     NOT EXISTS
--                          (
--                          SELECT  child_section_id
--                          FROM    ibe_dsp_msite_sct_sects s2
--                          WHERE   mini_site_id = l_c_msite_id
--                          AND     s2.child_section_id = s1.child_section_id
--                          )
--                  CONNECT BY PRIOR child_section_id = parent_section_id
--                  AND     PRIOR mini_site_id = l_c_master_msite_id
--                  AND     mini_site_id = l_c_master_msite_id
--                  START WITH child_section_id =
--                                  (
--                                  SELECT  msite_root_section_id
--                                  FROM    ibe_msites_b
--                                  WHERE   msite_id = l_c_msite_id
--                                  )
--                  AND     mini_site_id = l_c_master_msite_id
--                  )
--          AND inventory_item_id NOT IN
--          (
--             SELECT inventory_item_id
--             FROM   ibe_dsp_section_items i1, ibe_dsp_msite_sct_items i2
--             WHERE  i1.section_item_id  = i2.section_item_id
--             AND    i2.mini_site_id = l_c_msite_id
--          )
--          UNION
--          SELECT  /*+ ordered use_nl(s3,i2) */ section_item_id
--          FROM    (
--                  SELECT  child_section_id
--                  FROM    ibe_dsp_msite_sct_sects
--                  WHERE   mini_site_id = l_c_msite_id
--                  ) s3,
--                  ibe_dsp_section_items i2
--          WHERE   i2.section_id = s3.child_section_id
--          AND     NOT EXISTS
--                  (
--                  SELECT  null
--                  FROM    ibe_dsp_msite_sct_items i3
--                  WHERE   mini_site_id = l_c_msite_id
--                  AND     i3.section_item_id = i2.section_item_id
--                  )
--          ) v1,
--          ibe_dsp_section_items i0
--  WHERE   i0.section_item_id = v1.section_item_id;

  CURSOR c3
  IS SELECT msite_id FROM ibe_msites_b
    -- removed by YAXU on 08/06/02
    -- WHERE sysdate BETWEEN start_date_active AND NVL(end_date_active, sysdate)
    --AND
    WHERE master_msite_flag = 'N' and site_type = 'I';

 Cursor C_msite_valid(l_c_msite_id Number)
  Is Select msite_root_section_id
    From    ibe_msites_b
      Where  msite_id = l_c_msite_id
      And    master_msite_flag =  'N' and site_type = 'I';
      -- removed by YAXU on 08/06/02
      -- And    sysdate BETWEEN start_date_active
      -- And    NVL(end_date_active,sysdate) ;


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
   -- x_msite_ids := p_msite_ids;
   -- check the validation of the each msite_id
    l_index := 1;
    FOR i IN 1..p_msite_ids.COUNT LOOP
      Open  C_msite_valid(p_msite_ids(i));
      Fetch C_msite_valid INTO l_root_section_id;
      IF C_msite_valid%FOUND Then
        x_msite_ids.EXTEND();
        x_msite_ids(l_index) := p_msite_ids(i);
        l_index := l_index + 1;
      END IF;
      Close C_msite_valid;
    END LOOP;
  END IF;


  l_tmp_str := ' ';
  l_first_idx := x_msite_ids.FIRST;

  IF (x_msite_ids.COUNT <= 0) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_MSITE_NO_MSITES_SPECIFIED');
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
--  l_tmp_str := 'MM.msite_id IN (' || x_msite_ids(l_first_idx);

--  FOR i IN (l_first_idx+1)..x_msite_ids.LAST LOOP
--    If x_msite_ids.EXISTS(i) Then
--      l_tmp_str := l_tmp_str  || ',' || x_msite_ids(i);
--    End If;
--  END LOOP; -- end loop i
--  l_tmp_str := l_tmp_str  || ') ';

  -- Basic information (from ibe_msites_b table)
--  OPEN x_minisite_cur FOR 'SELECT msite_id, default_language_code, '
--    || 'default_currency_code, default_org_id, walkin_allowed_flag, '
--    || 'msite_root_section_id, master_msite_flag, atp_check_flag, '
--    || 'default_date_format, profile_id, access_name, resp_access_flag, '
--    || 'party_access_code, attribute1, attribute2, attribute3, attribute4, '
--    || 'attribute5, attribute6, attribute7, attribute8, attribute9, '
--    || 'attribute10, attribute11, attribute12, attribute13, attribute14, '
--    || 'attribute15 '
--    || 'FROM ibe_msites_b MM WHERE '
--    || l_tmp_str
--    || 'ORDER BY msite_id';


  -- Basic information (from ibe_msites_b table)
  OPEN x_minisite_cur FOR SELECT msite_id, default_language_code,
       default_currency_code, default_org_id, walkin_allowed_flag,
       msite_root_section_id, master_msite_flag, atp_check_flag,
       default_date_format, profile_id, access_name, resp_access_flag,
       party_access_code, attribute1, attribute2, attribute3, attribute4,
       attribute5, attribute6, attribute7, attribute8, attribute9,
       attribute10, attribute11, attribute12, attribute13, attribute14,
       attribute15,
       payment_threshold_enable_flag, --added by YAXU for payment threshold
       start_date_active, end_date_active -- added by YAXU on 08/06/02
       FROM ibe_msites_b MM
      WHERE MM.msite_id IN
           (SELECT t.COLUMN_VALUE
    	      FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
             WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125)
      ORDER BY msite_id ;

  -- Mini-site name and description for all languages
  OPEN x_name_cur FOR SELECT /*+ ORDERED USE_NL (V MM TL L) INDEX (MM,IBE_MSITES_B_U1) */
       MM.msite_id, L.language_code, TL.msite_name,TL.msite_description
  FROM(select distinct to_number(t.column_value) as msite_id
                   FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
                     WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
       ibe_msites_b MM, ibe_msites_tl TL, ibe_msite_languages L
  WHERE L.language_code = TL.language
  AND L.msite_id = MM.msite_id
  AND TL.msite_id = MM.msite_id
  AND MM.msite_id = v.msite_id
  AND MM.site_type = 'I'
  ORDER BY MM.msite_id;

  -- Language assocation(from ibe_msite_languages table)
  OPEN x_lang_cur FOR SELECT /*+ ORDERED
           USE_NL (V MM L)
           INDEX (MM,IBE_MSITES_B_U1) */
      MM.msite_id, L.language_code
	FROM
	     (select distinct to_number(t.column_value) as msite_id
		   FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
		     WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
     ibe_msites_b MM,
     ibe_msite_languages L
	WHERE MM.msite_id = L.msite_id
        AND MM.msite_id = v.msite_id
		AND MM.site_type = 'I'
	        AND   L.enable_flag = 'Y'
        ORDER BY MM.msite_id;

  -- Currency assocation(from ibe_msite_currencies table)
  OPEN x_currency_cur FOR SELECT /*+ ORDERED USE_NL (V MM C) INDEX (MM,IBE_MSITES_B_U1) */
       MM.msite_id, C.currency_code,
       C.bizpartner_prc_listid,C.registered_prc_listid, C.walkin_prc_listid,
       C.orderable_limit,
       C.payment_threshold,C.partner_prc_listid
  FROM (select distinct to_number(t.column_value) as msite_id
                   FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
                     WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
       ibe_msites_b MM, ibe_msite_currencies C
  WHERE MM.msite_id = C.msite_id
  AND MM.msite_id = v.msite_id
  AND MM.site_type = 'I'
  ORDER BY MM.msite_id;

  -- Mini-site and responsibility association (from ibe_msite_resps_b, _tl)
  OPEN x_msite_resps_cur FOR SELECT /*+ ORDERED USE_NL (V MM MRB MRTL) INDEX (MM,IBE_MSITES_B_U1)*/
       MM.msite_id, MRB.msite_resp_id, MRB.responsibility_id, MRB.application_id, MRTL.language,
       MRTL.display_name, MRB.start_date_active, MRB.end_date_active
    FROM  (select distinct to_number(t.column_value) as msite_id
                   FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
                     WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
           ibe_msites_b MM, ibe_msite_resps_b MRB, ibe_msite_resps_tl MRTL
    WHERE MM.msite_id = MRB.msite_id
    AND MRB.msite_resp_id = MRTL.msite_resp_id
    AND MM.msite_id = v.msite_id
	AND MM.site_type = 'I'
    ORDER BY MM.msite_id, MRB.msite_resp_id;

  -- Mini-site and party association (from ibe_msite_prty_accss table)
  OPEN x_party_access_cur FOR SELECT /*+ ORDERED USE_NL (V MM MP) INDEX (MM,IBE_MSITES_B_U1) */
       MM.msite_id, party_id
   FROM (select distinct to_number(t.column_value) as msite_id
                   FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
                     WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
      ibe_msites_b MM, ibe_msite_prty_accss MP
   WHERE MM.msite_id = MP.msite_id
   AND sysdate BETWEEN MP.start_date_Active AND NVL(MP.end_date_active,sysdate)
   AND MM.msite_id = v.msite_id
   AND MM.site_type = 'I'
   ORDER BY MM.msite_id;

  -- Payment method, credit card type and shipment method assocation
  -- (from ibe_msite_information table)
  OPEN x_pm_cc_sm_cur FOR SELECT /*+ ORDERED USE_NL(V MM MI) INDEX(MM,IBE_MSITES_B_U1) */
    MM.msite_id, MI.msite_information_context, MI.msite_information1,MI.msite_information2
  FROM(select distinct to_number(t.column_value) as msite_id
            FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
             WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
      ibe_msites_b MM, ibe_msite_information MI
  WHERE MM.msite_id = MI.msite_id
  AND MM.msite_id = v.msite_id
  AND MM.site_type = 'I'
  AND MI.msite_information_context = 'SHPMT_MTHD'
UNION
  SELECT /*+ ORDERED USE_NL(V MM MI) INDEX(MM,IBE_MSITES_B_U1) */
    MM.msite_id, MI.msite_information_context,MI.msite_information1,MI.msite_information2
    FROM(select distinct to_number(t.column_value) as msite_id
                   FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
                     WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
            ibe_msites_b MM, ibe_msite_information MI,  fnd_lookup_values FLV
    WHERE MM.msite_id = MI.msite_id
    AND MM.msite_id = v.msite_id
	AND MM.site_type = 'I'
    AND MI.msite_information1 = FLV.lookup_code
    AND FLV.lookup_type = 'IBE_PAYMENT_TYPE'
    AND FLV.enabled_flag = 'Y' AND (FLV.TAG='Y' or FLV.TAG is null)
    AND FLV.language=userenv('lang')

UNION --ssekar bug 5064210 query split to handle multiple sources of payment/credit card info.
  SELECT /*+ ORDERED USE_NL(V MM MI) INDEX(MM,IBE_MSITES_B_U1) */
    MM.msite_id, MI.msite_information_context,MI.msite_information1,MI.msite_information2
    FROM(select distinct to_number(t.column_value) as msite_id
                  FROM TABLE(CAST(x_msite_ids AS JTF_NUMBER_TABLE)) t
                  WHERE t.COLUMN_VALUE > 0 AND t.COLUMN_VALUE < 9.99E125) v,
            ibe_msites_b MM, ibe_msite_information MI, iby_creditcard_issuers_b cci
    WHERE MM.msite_id = MI.msite_id
    AND MM.msite_id = v.msite_id
	AND MM.site_type = 'I'
 	AND (MI.msite_information1 = cci.CARD_ISSUER_CODE)
    ORDER BY 1, 2;


  --+
  -- Get profile for catalog exclusions
  --+
  l_exclude_flag :=
    FND_PROFILE.Value_Specific('IBE_USE_CATALOG_EXCLUSIONS', null, null,
                               l_application_id);

  IF (l_exclude_flag IS NULL) THEN
    l_exclude_flag := 'N';
  END IF;

  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_Util.Debug('Get_Msite_Details - Set l_exclude_flag to N to prevent loading excluded items and excluded sections now');
  END IF;
  l_exclude_flag := 'N';   -- Bug 7676477, scnagara
  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_Util.Debug('Get_Msite_Details - l_exclude_flag = ' || l_exclude_flag);
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
	 OPEN C_msite_valid(x_msite_ids(i));
      FETCH C_msite_valid INTO l_root_section_id;
	 CLOSE C_msite_valid;
      FOR r2 IN c2(x_master_msite_id, x_msite_ids(i),l_root_section_id) LOOP
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

END IBE_MinisiteRuntime_PVT;

/
