--------------------------------------------------------
--  DDL for Package Body BIS_BUCKET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BUCKET_PVT" AS
/* $Header: BISVBKTB.pls 120.1 2006/07/26 07:58:21 ankgoel noship $ */

--=============================================================================
FUNCTION CHECK_RANGE_NAME (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
) RETURN BOOLEAN;
--=============================================================================
FUNCTION CHECK_RANGE_VAL_LOW (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
) RETURN BOOLEAN;
--=============================================================================
FUNCTION CHECK_RANGE_VAL_HIGH (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
) RETURN BOOLEAN;
--=============================================================================
PROCEDURE sync_bucket_ranges (
  p_id              IN  NUMBER
, p_deleted_ranges  IN  VARCHAR2
, p_new_ranges      IN  VARCHAR2);
--=============================================================================
--Called by Java API
--It should take all the data passed to it and builds a record of type BIS_BUCKET_REC_TYPE
--and call BIS_BUCKET_PVT. CREATE_BIS_BUCKET with it.
PROCEDURE CREATE_BIS_BUCKET_WRAPPER (
  p_short_name		IN BIS_BUCKET.short_name%TYPE
 ,p_name		IN BIS_BUCKET_TL.name%TYPE
 ,p_type		IN BIS_BUCKET.type%TYPE
 ,p_application_id	IN BIS_BUCKET.application_id%TYPE
 ,p_range1_name		IN BIS_BUCKET_TL.range1_name%TYPE
 ,p_range1_low		IN BIS_BUCKET.range1_low%TYPE
 ,p_range1_high    	IN BIS_BUCKET.range1_high%TYPE
 ,p_range2_name		IN BIS_BUCKET_TL.range2_name%TYPE
 ,p_range2_low		IN BIS_BUCKET.range2_low%TYPE
 ,p_range2_high    	IN BIS_BUCKET.range2_high%TYPE
 ,p_range3_name		IN BIS_BUCKET_TL.range3_name%TYPE
 ,p_range3_low		IN BIS_BUCKET.range3_low%TYPE
 ,p_range3_high    	IN BIS_BUCKET.range3_high%TYPE
 ,p_range4_name		IN BIS_BUCKET_TL.range4_name%TYPE
 ,p_range4_low		IN BIS_BUCKET.range4_low%TYPE
 ,p_range4_high    	IN BIS_BUCKET.range4_high%TYPE
 ,p_range5_name		IN BIS_BUCKET_TL.range5_name%TYPE
 ,p_range5_low		IN BIS_BUCKET.range5_low%TYPE
 ,p_range5_high    	IN BIS_BUCKET.range5_high%TYPE
 ,p_range6_name		IN BIS_BUCKET_TL.range6_name%TYPE
 ,p_range6_low		IN BIS_BUCKET.range6_low%TYPE
 ,p_range6_high    	IN BIS_BUCKET.range6_high%TYPE
 ,p_range7_name		IN BIS_BUCKET_TL.range7_name%TYPE
 ,p_range7_low		IN BIS_BUCKET.range7_low%TYPE
 ,p_range7_high    	IN BIS_BUCKET.range7_high%TYPE
 ,p_range8_name		IN BIS_BUCKET_TL.range8_name%TYPE
 ,p_range8_low		IN BIS_BUCKET.range8_low%TYPE
 ,p_range8_high    	IN BIS_BUCKET.range8_high%TYPE
 ,p_range9_name		IN BIS_BUCKET_TL.range9_name%TYPE
 ,p_range9_low		IN BIS_BUCKET.range9_low%TYPE
 ,p_range9_high    	IN BIS_BUCKET.range9_high%TYPE
 ,p_range10_name	IN BIS_BUCKET_TL.range10_name%TYPE
 ,p_range10_low		IN BIS_BUCKET.range10_low%TYPE
 ,p_range10_high    	IN BIS_BUCKET.range10_high%TYPE
 ,p_description		IN BIS_BUCKET_TL.description%TYPE
 ,p_updatable		IN BIS_BUCKET.updatable%TYPE := 'F'
 ,p_expandable		IN BIS_BUCKET.expandable%TYPE := 'F'
 ,p_discontinuous	IN BIS_BUCKET.discontinuous%TYPE := 'F'
 ,p_overlapping		IN BIS_BUCKET.overlapping%TYPE := 'F'
 ,p_uom		        IN BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
)
IS

l_bis_bucket_rec  BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status   VARCHAR2(10);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_bis_bucket_rec.short_name := p_short_name;
  l_bis_bucket_rec.name := p_name;
  l_bis_bucket_rec.type := p_type;
  l_bis_bucket_rec.application_id := p_application_id;
  l_bis_bucket_rec.range1_name := p_range1_name;
  l_bis_bucket_rec.range1_low := p_range1_low;
  l_bis_bucket_rec.range1_high := p_range1_high;
  l_bis_bucket_rec.range2_name := p_range2_name;
  l_bis_bucket_rec.range2_low := p_range2_low;
  l_bis_bucket_rec.range2_high := p_range2_high;
  l_bis_bucket_rec.range3_name := p_range3_name;
  l_bis_bucket_rec.range3_low := p_range3_low;
  l_bis_bucket_rec.range3_high := p_range3_high;
  l_bis_bucket_rec.range4_name := p_range4_name;
  l_bis_bucket_rec.range4_low := p_range4_low;
  l_bis_bucket_rec.range4_high := p_range4_high;
  l_bis_bucket_rec.range5_name := p_range5_name;
  l_bis_bucket_rec.range5_low := p_range5_low;
  l_bis_bucket_rec.range5_high := p_range5_high;
  l_bis_bucket_rec.range6_name := p_range6_name;
  l_bis_bucket_rec.range6_low := p_range6_low;
  l_bis_bucket_rec.range6_high := p_range6_high;
  l_bis_bucket_rec.range7_name := p_range7_name;
  l_bis_bucket_rec.range7_low := p_range7_low;
  l_bis_bucket_rec.range7_high := p_range7_high;
  l_bis_bucket_rec.range8_name := p_range8_name;
  l_bis_bucket_rec.range8_low := p_range8_low;
  l_bis_bucket_rec.range8_high := p_range8_high;
  l_bis_bucket_rec.range9_name := p_range9_name;
  l_bis_bucket_rec.range9_low := p_range9_low;
  l_bis_bucket_rec.range9_high := p_range9_high;
  l_bis_bucket_rec.range10_name := p_range10_name;
  l_bis_bucket_rec.range10_low := p_range10_low;
  l_bis_bucket_rec.range10_high := p_range10_high;
  l_bis_bucket_rec.description := p_description;
  l_bis_bucket_rec.updatable := p_updatable;
  l_bis_bucket_rec.expandable := p_expandable;
  l_bis_bucket_rec.discontinuous := p_discontinuous;
  l_bis_bucket_rec.overlapping := p_overlapping;
  l_bis_bucket_rec.uom := p_uom;

  BIS_BUCKET_PVT.CREATE_BIS_BUCKET (
    p_bis_bucket_rec	=> l_bis_bucket_rec
   ,x_return_status     => l_return_status
   ,x_error_tbl         => l_error_tbl
  );

  x_return_status := l_return_status;

  IF (l_error_tbl.EXISTS(1)) THEN
    x_error_msg := l_error_tbl(1).Error_Msg_Name;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;

END CREATE_BIS_BUCKET_WRAPPER;



--Called by Java API
--It should take all the data passed to it and builds a record of type BIS_BUCKET_REC_TYPE
--and call BIS_BUCKET_PVT.UPDATE_BIS_BUCKET with it.
PROCEDURE UPDATE_BIS_BUCKET_WRAPPER (
  p_bucket_id           IN BIS_BUCKET.bucket_id%TYPE
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE
 ,p_name		IN BIS_BUCKET_TL.name%TYPE
 ,p_type		IN BIS_BUCKET.type%TYPE
 ,p_application_id	IN BIS_BUCKET.application_id%TYPE
 ,p_range1_name		IN BIS_BUCKET_TL.range1_name%TYPE
 ,p_range1_low		IN BIS_BUCKET.range1_low%TYPE
 ,p_range1_high    	IN BIS_BUCKET.range1_high%TYPE
 ,p_range2_name		IN BIS_BUCKET_TL.range2_name%TYPE
 ,p_range2_low		IN BIS_BUCKET.range2_low%TYPE
 ,p_range2_high    	IN BIS_BUCKET.range2_high%TYPE
 ,p_range3_name		IN BIS_BUCKET_TL.range3_name%TYPE
 ,p_range3_low		IN BIS_BUCKET.range3_low%TYPE
 ,p_range3_high    	IN BIS_BUCKET.range3_high%TYPE
 ,p_range4_name		IN BIS_BUCKET_TL.range4_name%TYPE
 ,p_range4_low		IN BIS_BUCKET.range4_low%TYPE
 ,p_range4_high    	IN BIS_BUCKET.range4_high%TYPE
 ,p_range5_name		IN BIS_BUCKET_TL.range5_name%TYPE
 ,p_range5_low		IN BIS_BUCKET.range5_low%TYPE
 ,p_range5_high    	IN BIS_BUCKET.range5_high%TYPE
 ,p_range6_name		IN BIS_BUCKET_TL.range6_name%TYPE
 ,p_range6_low		IN BIS_BUCKET.range6_low%TYPE
 ,p_range6_high    	IN BIS_BUCKET.range6_high%TYPE
 ,p_range7_name		IN BIS_BUCKET_TL.range7_name%TYPE
 ,p_range7_low		IN BIS_BUCKET.range7_low%TYPE
 ,p_range7_high    	IN BIS_BUCKET.range7_high%TYPE
 ,p_range8_name		IN BIS_BUCKET_TL.range8_name%TYPE
 ,p_range8_low		IN BIS_BUCKET.range8_low%TYPE
 ,p_range8_high    	IN BIS_BUCKET.range8_high%TYPE
 ,p_range9_name		IN BIS_BUCKET_TL.range9_name%TYPE
 ,p_range9_low		IN BIS_BUCKET.range9_low%TYPE
 ,p_range9_high    	IN BIS_BUCKET.range9_high%TYPE
 ,p_range10_name	IN BIS_BUCKET_TL.range10_name%TYPE
 ,p_range10_low		IN BIS_BUCKET.range10_low%TYPE
 ,p_range10_high    	IN BIS_BUCKET.range10_high%TYPE
 ,p_description		IN BIS_BUCKET_TL.description%TYPE
 ,p_updatable		IN BIS_BUCKET.updatable%TYPE := 'F'
 ,p_expandable		IN BIS_BUCKET.expandable%TYPE := 'F'
 ,p_discontinuous	IN BIS_BUCKET.discontinuous%TYPE := 'F'
 ,p_overlapping		IN BIS_BUCKET.overlapping%TYPE := 'F'
 ,p_uom		        IN BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
)
IS

l_bis_bucket_rec  BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status   VARCHAR2(10);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;
l_ret             VARCHAR2(10);

BEGIN

  l_bis_bucket_rec.short_name := p_short_name;
  l_bis_bucket_rec.name := p_name;
  l_bis_bucket_rec.type := p_type;
  l_bis_bucket_rec.application_id := p_application_id;
  l_bis_bucket_rec.range1_name := p_range1_name;
  l_bis_bucket_rec.range1_low := p_range1_low;
  l_bis_bucket_rec.range1_high := p_range1_high;
  l_bis_bucket_rec.range2_name := p_range2_name;
  l_bis_bucket_rec.range2_low := p_range2_low;
  l_bis_bucket_rec.range2_high := p_range2_high;
  l_bis_bucket_rec.range3_name := p_range3_name;
  l_bis_bucket_rec.range3_low := p_range3_low;
  l_bis_bucket_rec.range3_high := p_range3_high;
  l_bis_bucket_rec.range4_name := p_range4_name;
  l_bis_bucket_rec.range4_low := p_range4_low;
  l_bis_bucket_rec.range4_high := p_range4_high;
  l_bis_bucket_rec.range5_name := p_range5_name;
  l_bis_bucket_rec.range5_low := p_range5_low;
  l_bis_bucket_rec.range5_high := p_range5_high;
  l_bis_bucket_rec.range6_name := p_range6_name;
  l_bis_bucket_rec.range6_low := p_range6_low;
  l_bis_bucket_rec.range6_high := p_range6_high;
  l_bis_bucket_rec.range7_name := p_range7_name;
  l_bis_bucket_rec.range7_low := p_range7_low;
  l_bis_bucket_rec.range7_high := p_range7_high;
  l_bis_bucket_rec.range8_name := p_range8_name;
  l_bis_bucket_rec.range8_low := p_range8_low;
  l_bis_bucket_rec.range8_high := p_range8_high;
  l_bis_bucket_rec.range9_name := p_range9_name;
  l_bis_bucket_rec.range9_low := p_range9_low;
  l_bis_bucket_rec.range9_high := p_range9_high;
  l_bis_bucket_rec.range10_name := p_range10_name;
  l_bis_bucket_rec.range10_low := p_range10_low;
  l_bis_bucket_rec.range10_high := p_range10_high;
  l_bis_bucket_rec.description := p_description;
  l_bis_bucket_rec.updatable := p_updatable;
  l_bis_bucket_rec.expandable := p_expandable;
  l_bis_bucket_rec.discontinuous := p_discontinuous;
  l_bis_bucket_rec.overlapping := p_overlapping;
  l_bis_bucket_rec.uom := p_uom;

  BIS_BUCKET_PVT.UPDATE_BIS_BUCKET (
    p_bis_bucket_rec	=> l_bis_bucket_rec
   ,x_return_status     => l_return_status
   ,x_error_tbl         => l_error_tbl
  );

  x_return_status := l_return_status;
  IF (l_error_tbl.EXISTS(1)) THEN
    x_error_msg := l_error_tbl(1).Error_Msg_Name;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
END UPDATE_BIS_BUCKET_WRAPPER;

PROCEDURE UPDATE_CUST_BUCKET (
  p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_id                 IN  BIS_BUCKET_CUSTOMIZATIONS.id%TYPE
, p_bucket_id          IN  BIS_BUCKET_CUSTOMIZATIONS.bucket_id%TYPE
, p_user_id            IN  BIS_BUCKET_CUSTOMIZATIONS.user_id%TYPE
, p_responsibility_id  IN  BIS_BUCKET_CUSTOMIZATIONS.responsibility_id%TYPE
, p_application_id     IN  BIS_BUCKET_CUSTOMIZATIONS.application_id%TYPE
, p_org_id             IN  BIS_BUCKET_CUSTOMIZATIONS.org_id%TYPE
, p_site_id            IN  BIS_BUCKET_CUSTOMIZATIONS.site_id%TYPE
, p_page_id            IN  BIS_BUCKET_CUSTOMIZATIONS.page_id%TYPE
, p_function_id        IN  BIS_BUCKET_CUSTOMIZATIONS.function_id%TYPE
, p_range1_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range1_low%TYPE
, p_range1_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range1_high%TYPE
, p_range2_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range2_low%TYPE
, p_range2_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range2_high%TYPE
, p_range3_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range3_low%TYPE
, p_range3_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range3_high%TYPE
, p_range4_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range4_low%TYPE
, p_range4_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range4_high%TYPE
, p_range5_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range5_low%TYPE
, p_range5_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range5_high%TYPE
, p_range6_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range6_low%TYPE
, p_range6_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range6_high%TYPE
, p_range7_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range7_low%TYPE
, p_range7_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range7_high%TYPE
, p_range8_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range8_low%TYPE
, p_range8_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range8_high%TYPE
, p_range9_low         IN  BIS_BUCKET_CUSTOMIZATIONS.range9_low%TYPE
, p_range9_high        IN  BIS_BUCKET_CUSTOMIZATIONS.range9_high%TYPE
, p_range10_low        IN  BIS_BUCKET_CUSTOMIZATIONS.range10_low%TYPE
, p_range10_high       IN  BIS_BUCKET_CUSTOMIZATIONS.range10_high%TYPE
, p_range1_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range1_name%TYPE
, p_range2_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range2_name%TYPE
, p_range3_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range3_name%TYPE
, p_range4_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range4_name%TYPE
, p_range5_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range5_name%TYPE
, p_range6_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range6_name%TYPE
, p_range7_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range7_name%TYPE
, p_range8_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range8_name%TYPE
, p_range9_name        IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range9_name%TYPE
, p_range10_name       IN  BIS_BUCKET_CUSTOMIZATIONS_TL.range10_name%TYPE
, p_customized         IN  BIS_BUCKET_CUSTOMIZATIONS.customized%TYPE
, p_deleted_ranges     IN  VARCHAR2
, p_new_ranges         IN  VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
BEGIN

  SAVEPOINT SP_UPDATE_BUCKET_CUST;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.initialize;

  UPDATE bis_bucket_customizations SET
    bucket_id = p_bucket_id,
    user_id = p_user_id,
    responsibility_id = p_responsibility_id,
    application_id = p_application_id,
    org_id = p_org_id,
    site_id = p_site_id,
    page_id = p_page_id,
    function_id = p_function_id,
    range1_low = p_range1_low,
    range1_high = p_range1_high,
    range2_low = p_range2_low,
    range2_high = p_range2_high,
    range3_low = p_range3_low,
    range3_high = p_range3_high,
    range4_low = p_range4_low,
    range4_high = p_range4_high,
    range5_low = p_range5_low,
    range5_high = p_range5_high,
    range6_low = p_range6_low,
    range6_high = p_range6_high,
    range7_low = p_range7_low,
    range7_high = p_range7_high,
    range8_low = p_range8_low,
    range8_high = p_range8_high,
    range9_low = p_range9_low,
    range9_high = p_range9_high,
    range10_low = p_range10_low,
    range10_high = p_range10_high,
    CUSTOMIZED = p_customized,
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.USER_ID,
    last_update_login = FND_GLOBAL.LOGIN_ID
  WHERE id = p_id;

  UPDATE bis_bucket_customizations_tl SET
    range1_name = p_range1_name,
    range2_name = p_range2_name,
    range3_name = p_range3_name,
    range4_name = p_range4_name,
    range5_name = p_range5_name,
    range6_name = p_range6_name,
    range7_name = p_range7_name,
    range8_name = p_range8_name,
    range9_name = p_range9_name,
    range10_name = p_range10_name,
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.USER_ID,
    last_update_login = FND_GLOBAL.LOGIN_ID,
    source_lang = userenv('LANG')
  where id = p_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  sync_bucket_ranges (
    p_id             => p_id
  , p_deleted_ranges => p_deleted_ranges
  , p_new_ranges     => p_new_ranges
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPDATE_BUCKET_CUST;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    ROLLBACK TO SP_UPDATE_BUCKET_CUST;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_BUCKET_PVT.UPDATE_CUST_BUCKET ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_BUCKET_PVT.UPDATE_CUST_BUCKET ';
    END IF;
    ROLLBACK TO SP_UPDATE_BUCKET_CUST;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BIS_BUCKET_PVT.UPDATE_CUST_BUCKET ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BIS_BUCKET_PVT.UPDATE_CUST_BUCKET ';
    END IF;
    ROLLBACK TO SP_UPDATE_BUCKET_CUST;
END UPDATE_CUST_BUCKET;

PROCEDURE sync_bucket_ranges (
  p_id              IN  NUMBER
, p_deleted_ranges  IN  VARCHAR2
, p_new_ranges      IN  VARCHAR2
)
IS
  l_deleted_ranges  VARCHAR2(100);
  l_new_ranges      VARCHAR2(100);
  l_range_num       VARCHAR2(2);
  l_next_pos        NUMBER := 0;
  l_sql             VARCHAR2(100);
  l_pointer         NUMBER;

  CURSOR c_installed_lang IS
    SELECT L.language_code FROM fnd_languages L
    WHERE  L.installed_flag IN ('I', 'B')
    AND    L.language_code <> userenv('LANG');
  l_lang_rec  c_installed_lang%ROWTYPE;

  CURSOR c_bucket(p_lang_code  VARCHAR2) IS
    SELECT range1_name, range2_name, range3_name, range4_name,
           range5_name, range6_name, range7_name, range8_name, range9_name, range10_name
    FROM   bis_bucket_customizations_tl
    WHERE  id = p_id
    AND    language = source_lang
    AND    source_lang = p_lang_code;
  l_bucket_rec  c_bucket%ROWTYPE;

  l_range_labels   BIS_BUCKET_PVT.RangeLabels;
  c_delete_marker  VARCHAR2(10) := '@#!$';

BEGIN

  l_range_labels := RangeLabels(NULL);
  FOR i IN 1..19 LOOP
    l_range_labels.extend;
    l_range_labels(l_range_labels.LAST) := NULL;
  END LOOP;

  FOR l_lang_rec IN c_installed_lang LOOP

    IF (c_bucket%ISOPEN) THEN
      CLOSE c_bucket;
    END IF;
    OPEN c_bucket(l_lang_rec.language_code);
    FETCH c_bucket INTO l_bucket_rec;

    IF (c_bucket%FOUND) THEN
      l_range_labels(1) := l_bucket_rec.range1_name;
      l_range_labels(2) := l_bucket_rec.range2_name;
      l_range_labels(3) := l_bucket_rec.range3_name;
      l_range_labels(4) := l_bucket_rec.range4_name;
      l_range_labels(5) := l_bucket_rec.range5_name;
      l_range_labels(6) := l_bucket_rec.range6_name;
      l_range_labels(7) := l_bucket_rec.range7_name;
      l_range_labels(8) := l_bucket_rec.range8_name;
      l_range_labels(9) := l_bucket_rec.range9_name;
      l_range_labels(10) := l_bucket_rec.range10_name;
    END IF;

    CLOSE c_bucket;

    /*
      Handle deleted ranges first for non-US rows.
      Make the range name labels as NULL for the deleted range numbers.
    */
    IF (p_deleted_ranges IS NOT NULL) THEN

      l_deleted_ranges := p_deleted_ranges;

      WHILE (LENGTH(l_deleted_ranges) > 0) LOOP
        l_next_pos := INSTR(l_deleted_ranges, ',');
	IF (l_next_pos = 0) THEN
	  l_range_num := TO_NUMBER(l_deleted_ranges);
	  l_deleted_ranges := NULL;
	ELSE
          l_range_num := TO_NUMBER(SUBSTR(l_deleted_ranges, 1, l_next_pos - 1));
	  l_deleted_ranges := SUBSTR(l_deleted_ranges, l_next_pos + 1);
	END IF;

        l_range_labels(l_range_num) := c_delete_marker;
      END LOOP;

    END IF;

    /*
      Handle new ranges for non-US rows.
      Shift range names towards right after the new range numbers,
      and insert the range labels from US rows for newly created blank range columns.
    */
    IF (p_new_ranges IS NOT NULL) THEN

      l_new_ranges := p_new_ranges;

      WHILE (LENGTH(l_new_ranges) > 0) LOOP
        l_next_pos := INSTR(l_new_ranges, ',');

	IF (l_next_pos = 0) THEN
	  l_range_num := TO_NUMBER(l_new_ranges);
	  l_new_ranges := NULL;
        ELSE
          l_range_num := TO_NUMBER(SUBSTR(l_new_ranges, 1, l_next_pos - 1));
	  l_new_ranges := SUBSTR(l_new_ranges, l_next_pos + 1);
	END IF;

	FOR i IN REVERSE (l_range_num + 2)..l_range_labels.COUNT LOOP
	  l_range_labels(i) := l_range_labels(i - 1);
	END LOOP;
        l_range_labels(l_range_num + 1) := NULL;

      END LOOP;

    END IF;

    /*
      Arrange all the ranges one after the other by shifting left over the deleted ranges.
    */
    l_pointer := 1;
    WHILE (l_pointer < l_range_labels.COUNT) LOOP
      IF (l_range_labels(l_pointer) = c_delete_marker) THEN
        FOR j IN l_pointer..(l_range_labels.COUNT - 1) LOOP
	  l_range_labels(j) := l_range_labels(j + 1);
	END LOOP;
      ELSE
        l_pointer := l_pointer + 1;
      END IF;
    END LOOP;

    /*
      Insert new range labels from US rows.
    */

    IF (c_bucket%ISOPEN) THEN
      CLOSE c_bucket;
    END IF;
    OPEN c_bucket(userenv('LANG'));
    FETCH c_bucket INTO l_bucket_rec;

    IF (c_bucket%FOUND) THEN
      UPDATE bis_bucket_customizations_tl
        SET range1_name = NVL(l_range_labels(1), l_bucket_rec.range1_name),
            range2_name = NVL(l_range_labels(2), l_bucket_rec.range2_name),
	    range3_name = NVL(l_range_labels(3), l_bucket_rec.range3_name),
	    range4_name = NVL(l_range_labels(4), l_bucket_rec.range4_name),
	    range5_name = NVL(l_range_labels(5), l_bucket_rec.range5_name),
	    range6_name = NVL(l_range_labels(6), l_bucket_rec.range6_name),
	    range7_name = NVL(l_range_labels(7), l_bucket_rec.range7_name),
	    range8_name = NVL(l_range_labels(8), l_bucket_rec.range8_name),
	    range9_name = NVL(l_range_labels(9), l_bucket_rec.range9_name),
	    range10_name = NVL(l_range_labels(10), l_bucket_rec.range10_name)
	WHERE language = source_lang
	AND   language = l_lang_rec.language_code
	AND   id = p_id ;
    END IF;
    CLOSE c_bucket;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_bucket%ISOPEN) THEN
      CLOSE c_bucket;
    END IF;
    RAISE;
END sync_bucket_ranges;


PROCEDURE reset_bucket (
 p_bucket_id  IN  NUMBER
)
IS
  CURSOR c_base_bucket IS
    SELECT range1_low, range1_high,
           range2_low, range2_high,
	   range3_low, range3_high,
	   range4_low, range4_high,
	   range5_low, range5_high,
	   range6_low, range6_high,
	   range7_low, range7_high,
	   range8_low, range8_high,
	   range9_low, range9_high,
	   range10_low, range10_high
    FROM   bis_bucket
    WHERE  bucket_id = p_bucket_id;
  l_base_bucket_rec  c_base_bucket%ROWTYPE;

  CURSOR c_base_bucket_tl(p_lang  VARCHAR2) IS
    SELECT range1_name,
           range2_name,
	   range3_name,
	   range4_name,
	   range5_name,
	   range6_name,
	   range7_name,
	   range8_name,
	   range9_name,
	   range10_name
     FROM  bis_bucket_tl
     WHERE bucket_id = p_bucket_id
     AND   language = p_lang;
  l_base_bucket_tl_rec  c_base_bucket_tl%ROWTYPE;

  CURSOR c_installed_lang IS
    SELECT L.language_code FROM fnd_languages L
    WHERE  L.installed_flag IN ('I', 'B');
  l_lang_rec  c_installed_lang%ROWTYPE;

BEGIN

  SAVEPOINT SP_RESET_CUST_BUCKET;

  IF (c_base_bucket%ISOPEN) THEN
    CLOSE c_base_bucket;
  END IF;
  OPEN c_base_bucket;
  FETCH c_base_bucket INTO l_base_bucket_rec;
  IF(c_base_bucket%FOUND) THEN
    UPDATE bis_bucket_customizations SET
      user_id = NULL,
      responsibility_id = NULL,
      application_id = NULL,
      org_id = NULL,
      site_id = NULL,
      page_id = NULL,
      function_id = NULL,
      range1_low = l_base_bucket_rec.range1_low,
      range1_high = l_base_bucket_rec.range1_high,
      range2_low = l_base_bucket_rec.range2_low,
      range2_high = l_base_bucket_rec.range2_high,
      range3_low = l_base_bucket_rec.range3_low,
      range3_high = l_base_bucket_rec.range3_high,
      range4_low = l_base_bucket_rec.range4_low,
      range4_high = l_base_bucket_rec.range4_high,
      range5_low = l_base_bucket_rec.range5_low,
      range5_high = l_base_bucket_rec.range5_high,
      range6_low = l_base_bucket_rec.range6_low,
      range6_high = l_base_bucket_rec.range6_high,
      range7_low = l_base_bucket_rec.range7_low,
      range7_high = l_base_bucket_rec.range7_high,
      range8_low = l_base_bucket_rec.range8_low,
      range8_high = l_base_bucket_rec.range8_high,
      range9_low = l_base_bucket_rec.range9_low,
      range9_high = l_base_bucket_rec.range9_high,
      range10_low = l_base_bucket_rec.range10_low,
      range10_high = l_base_bucket_rec.range10_high,
      CUSTOMIZED = 'F',
      last_update_date = SYSDATE,
      last_updated_by = FND_GLOBAL.USER_ID,
      last_update_login = FND_GLOBAL.LOGIN_ID
    WHERE bucket_id = p_bucket_id;
  END IF;

  CLOSE c_base_bucket;

  FOR l_lang_rec IN c_installed_lang LOOP

    IF (c_base_bucket_tl%ISOPEN) THEN
      CLOSE c_base_bucket_tl;
    END IF;
    OPEN c_base_bucket_tl(l_lang_rec.language_code);
    FETCH c_base_bucket_tl INTO l_base_bucket_tl_rec;
    IF(c_base_bucket_tl%FOUND) THEN

      UPDATE bis_bucket_customizations_tl SET
        range1_name = l_base_bucket_tl_rec.range1_name,
        range2_name = l_base_bucket_tl_rec.range2_name,
        range3_name = l_base_bucket_tl_rec.range3_name,
        range4_name = l_base_bucket_tl_rec.range4_name,
        range5_name = l_base_bucket_tl_rec.range5_name,
        range6_name = l_base_bucket_tl_rec.range6_name,
        range7_name = l_base_bucket_tl_rec.range7_name,
        range8_name = l_base_bucket_tl_rec.range8_name,
        range9_name = l_base_bucket_tl_rec.range9_name,
        range10_name = l_base_bucket_tl_rec.range10_name,
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_login = FND_GLOBAL.LOGIN_ID
      WHERE id IN (SELECT id FROM bis_bucket_customizations WHERE bucket_id = p_bucket_id)
      AND   language = l_lang_rec.language_code;

    END IF;

    CLOSE c_base_bucket_tl;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_base_bucket%ISOPEN) THEN
      CLOSE c_base_bucket;
    END IF;
    IF (c_base_bucket_tl%ISOPEN) THEN
      CLOSE c_base_bucket_tl;
    END IF;
    ROLLBACK TO SP_RESET_CUST_BUCKET;
    RAISE;
END reset_bucket;


--Called by Java API
--It should call BIS_BUCKET_PVT. RETRIEVE _BIS_BUCKET with the short name
--and using the record of type BIS_BUCKET_REC_TYPE data obtained from that procedure,
--it should populates the out parameters
PROCEDURE RETRIEVE_BIS_BUCKET_WRAPPER (
  p_short_name		IN BIS_BUCKET.short_name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_bucket_id           OUT NOCOPY BIS_BUCKET.bucket_id%TYPE
 ,x_name		OUT NOCOPY BIS_BUCKET_TL.name%TYPE
 ,x_type		OUT NOCOPY BIS_BUCKET.type%TYPE
 ,x_application_id	OUT NOCOPY BIS_BUCKET.application_id%TYPE
 ,x_range1_name		OUT NOCOPY BIS_BUCKET_TL.range1_name%TYPE
 ,x_range1_low		OUT NOCOPY BIS_BUCKET.range1_low%TYPE
 ,x_range1_high    	OUT NOCOPY BIS_BUCKET.range1_high%TYPE
 ,x_range2_name		OUT NOCOPY BIS_BUCKET_TL.range2_name%TYPE
 ,x_range2_low		OUT NOCOPY BIS_BUCKET.range2_low%TYPE
 ,x_range2_high    	OUT NOCOPY BIS_BUCKET.range2_high%TYPE
 ,x_range3_name		OUT NOCOPY BIS_BUCKET_TL.range3_name%TYPE
 ,x_range3_low		OUT NOCOPY BIS_BUCKET.range3_low%TYPE
 ,x_range3_high    	OUT NOCOPY BIS_BUCKET.range3_high%TYPE
 ,x_range4_name		OUT NOCOPY BIS_BUCKET_TL.range4_name%TYPE
 ,x_range4_low		OUT NOCOPY BIS_BUCKET.range4_low%TYPE
 ,x_range4_high    	OUT NOCOPY BIS_BUCKET.range4_high%TYPE
 ,x_range5_name		OUT NOCOPY BIS_BUCKET_TL.range5_name%TYPE
 ,x_range5_low		OUT NOCOPY BIS_BUCKET.range5_low%TYPE
 ,x_range5_high    	OUT NOCOPY BIS_BUCKET.range5_high%TYPE
 ,x_range6_name		OUT NOCOPY BIS_BUCKET_TL.range6_name%TYPE
 ,x_range6_low		OUT NOCOPY BIS_BUCKET.range6_low%TYPE
 ,x_range6_high    	OUT NOCOPY BIS_BUCKET.range6_high%TYPE
 ,x_range7_name		OUT NOCOPY BIS_BUCKET_TL.range7_name%TYPE
 ,x_range7_low		OUT NOCOPY BIS_BUCKET.range7_low%TYPE
 ,x_range7_high    	OUT NOCOPY BIS_BUCKET.range7_high%TYPE
 ,x_range8_name		OUT NOCOPY BIS_BUCKET_TL.range8_name%TYPE
 ,x_range8_low		OUT NOCOPY BIS_BUCKET.range8_low%TYPE
 ,x_range8_high    	OUT NOCOPY BIS_BUCKET.range8_high%TYPE
 ,x_range9_name		OUT NOCOPY BIS_BUCKET_TL.range9_name%TYPE
 ,x_range9_low		OUT NOCOPY BIS_BUCKET.range9_low%TYPE
 ,x_range9_high    	OUT NOCOPY BIS_BUCKET.range9_high%TYPE
 ,x_range10_name	OUT NOCOPY BIS_BUCKET_TL.range10_name%TYPE
 ,x_range10_low		OUT NOCOPY BIS_BUCKET.range10_low%TYPE
 ,x_range10_high    	OUT NOCOPY BIS_BUCKET.range10_high%TYPE
 ,x_description		OUT NOCOPY BIS_BUCKET_TL.description%TYPE
 ,x_updatable		OUT NOCOPY BIS_BUCKET.updatable%TYPE
 ,x_expandable		OUT NOCOPY BIS_BUCKET.expandable%TYPE
 ,x_discontinuous	OUT NOCOPY BIS_BUCKET.discontinuous%TYPE
 ,x_overlapping		OUT NOCOPY BIS_BUCKET.overlapping%TYPE
 ,x_uom		        OUT NOCOPY BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
)
IS

l_bis_bucket_rec  BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status   VARCHAR2(10);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  BIS_BUCKET_PVT.RETRIEVE_BIS_BUCKET (
    p_short_name	=> p_short_name
   ,x_bis_bucket_rec	=> l_bis_bucket_rec
   ,x_return_status     => l_return_status
   ,x_error_tbl         => l_error_tbl
  );

  x_bucket_id		:= l_bis_bucket_rec.bucket_id;
  x_name		:= l_bis_bucket_rec.name;
  x_type		:= l_bis_bucket_rec.type;
  x_application_id	:= l_bis_bucket_rec.application_id;
  x_range1_name		:= l_bis_bucket_rec.range1_name;
  x_range1_low		:= l_bis_bucket_rec.range1_low;
  x_range1_high		:= l_bis_bucket_rec.range1_high;
  x_range2_name		:= l_bis_bucket_rec.range2_name;
  x_range2_low		:= l_bis_bucket_rec.range2_low;
  x_range2_high		:= l_bis_bucket_rec.range2_high;
  x_range3_name		:= l_bis_bucket_rec.range3_name;
  x_range3_low		:= l_bis_bucket_rec.range3_low;
  x_range3_high		:= l_bis_bucket_rec.range3_high;
  x_range4_name		:= l_bis_bucket_rec.range4_name;
  x_range4_low		:= l_bis_bucket_rec.range4_low;
  x_range4_high		:= l_bis_bucket_rec.range4_high;
  x_range5_name		:= l_bis_bucket_rec.range5_name;
  x_range5_low		:= l_bis_bucket_rec.range5_low;
  x_range5_high		:= l_bis_bucket_rec.range5_high;
  x_range6_name		:= l_bis_bucket_rec.range6_name;
  x_range6_low		:= l_bis_bucket_rec.range6_low;
  x_range6_high		:= l_bis_bucket_rec.range6_high;
  x_range7_name		:= l_bis_bucket_rec.range7_name;
  x_range7_low		:= l_bis_bucket_rec.range7_low;
  x_range7_high		:= l_bis_bucket_rec.range7_high;
  x_range8_name		:= l_bis_bucket_rec.range8_name;
  x_range8_low		:= l_bis_bucket_rec.range8_low;
  x_range8_high		:= l_bis_bucket_rec.range8_high;
  x_range9_name		:= l_bis_bucket_rec.range9_name;
  x_range9_low		:= l_bis_bucket_rec.range9_low;
  x_range9_high		:= l_bis_bucket_rec.range9_high;
  x_range10_name	:= l_bis_bucket_rec.range10_name;
  x_range10_low		:= l_bis_bucket_rec.range10_low;
  x_range10_high	:= l_bis_bucket_rec.range10_high;
  x_description		:= l_bis_bucket_rec.description;
  x_updatable		:= l_bis_bucket_rec.updatable;
  x_expandable		:= l_bis_bucket_rec.expandable;
  x_discontinuous   := l_bis_bucket_rec.discontinuous;
  x_overlapping		:= l_bis_bucket_rec.overlapping;
  x_uom		        := l_bis_bucket_rec.uom;

  x_return_status := l_return_status;
  IF (l_error_tbl.EXISTS(1)) THEN
    x_error_msg := l_error_tbl(1).Error_Msg_Name;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;

END RETRIEVE_BIS_BUCKET_WRAPPER;


--This API should call BIS_BUCKET_PVT.DELETE_BIS_BUCKET
PROCEDURE DELETE_BIS_BUCKET_WRAPPER (
  p_bucket_id   	IN BIS_BUCKET.bucket_id%TYPE	:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE  	:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_return_status      	OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
)
IS

l_return_status   VARCHAR2(10);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  BIS_BUCKET_PVT.DELETE_BIS_BUCKET(
    p_bucket_id	     => p_bucket_id
   ,p_short_name     => p_short_name
   ,x_return_status  => l_return_status
   ,x_error_tbl      => l_error_tbl
  );
  x_return_status := l_return_status;
  IF (l_error_tbl.EXISTS(1)) THEN
    x_error_msg := l_error_tbl(1).Error_Msg_Name;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;

END DELETE_BIS_BUCKET_WRAPPER;


--This API should generate the bucket_id in sequence and insert the data passed to it,
--into the tables BIS_BUCKET, BIS_BUCKET_TL
PROCEDURE CREATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_bucket_id		NUMBER;
l_id			NUMBER;
l_user_id		NUMBER;
l_login_id		NUMBER;
l_short_count		NUMBER;
l_fnd_type_count	NUMBER;
l_bis_type_count	NUMBER;
l_bis_bucket_rec	BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status		VARCHAR2(10);
l_error_tbl		BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  SAVEPOINT SP_CREATE_BUCKET;

  l_user_id  := fnd_global.user_id;
  l_login_id := fnd_global.LOGIN_ID;
  l_bis_bucket_rec := p_bis_bucket_rec;

  BIS_BUCKET_PVT.Validate_Bucket (
     p_bis_bucket_rec => l_bis_bucket_rec
    ,x_return_status => x_return_status
    ,x_error_Tbl => x_error_tbl
  );

--Check if the bucket short name is unique
  SELECT COUNT(short_name) INTO l_short_count
    FROM BIS_BUCKET
    WHERE short_name = l_bis_bucket_rec.short_name;

  IF (l_short_count > 0) THEN

    l_error_tbl := x_error_tbl ;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_INVALID_SHORT_NAME'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT bis_bucket_s.nextval INTO l_bucket_id FROM dual;

  INSERT into BIS_BUCKET (
    BUCKET_ID,
    SHORT_NAME,
    TYPE,
    APPLICATION_ID,
    RANGE1_LOW,
    RANGE1_HIGH,
    RANGE2_LOW,
    RANGE2_HIGH,
    RANGE3_LOW,
    RANGE3_HIGH,
    RANGE4_LOW,
    RANGE4_HIGH,
    RANGE5_LOW,
    RANGE5_HIGH,
    RANGE6_LOW,
    RANGE6_HIGH,
    RANGE7_LOW,
    RANGE7_HIGH,
    RANGE8_LOW,
    RANGE8_HIGH,
    RANGE9_LOW,
    RANGE9_HIGH,
    RANGE10_LOW,
    RANGE10_HIGH,
    UPDATABLE,
    EXPANDABLE,
    DISCONTINUOUS,
    OVERLAPPING,
    UOM,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  VALUES (
    l_bucket_id,
    l_bis_bucket_rec.short_name,
    l_bis_bucket_rec.type,
    l_bis_bucket_rec.application_id,
    l_bis_bucket_rec.range1_low,
    l_bis_bucket_rec.range1_high,
    l_bis_bucket_rec.range2_low,
    l_bis_bucket_rec.range2_high,
    l_bis_bucket_rec.range3_low,
    l_bis_bucket_rec.range3_high,
    l_bis_bucket_rec.range4_low,
    l_bis_bucket_rec.range4_high,
    l_bis_bucket_rec.range5_low,
    l_bis_bucket_rec.range5_high,
    l_bis_bucket_rec.range6_low,
    l_bis_bucket_rec.range6_high,
    l_bis_bucket_rec.range7_low,
    l_bis_bucket_rec.range7_high,
    l_bis_bucket_rec.range8_low,
    l_bis_bucket_rec.range8_high,
    l_bis_bucket_rec.range9_low,
    l_bis_bucket_rec.range9_high,
    l_bis_bucket_rec.range10_low,
    l_bis_bucket_rec.range10_high,
    NVL(l_bis_bucket_rec.updatable,'F'),
    NVL(l_bis_bucket_rec.expandable,'F'),
    NVL(l_bis_bucket_rec.discontinuous,'F'),
    NVL(l_bis_bucket_rec.overlapping,'F'),
    l_bis_bucket_rec.uom,
    SYSDATE,
    l_user_id,
    SYSDATE,
    l_user_id,
    l_login_id
  );

  INSERT into BIS_BUCKET_TL (
    BUCKET_ID,
    LANGUAGE,
    NAME,
    RANGE1_NAME,
    RANGE2_NAME,
    RANGE3_NAME,
    RANGE4_NAME,
    RANGE5_NAME,
    RANGE6_NAME,
    RANGE7_NAME,
    RANGE8_NAME,
    RANGE9_NAME,
    RANGE10_NAME,
    DESCRIPTION,
    TRANSLATED,
    SOURCE_LANG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  SELECT
    l_bucket_id,
    L.LANGUAGE_CODE,
    l_bis_bucket_rec.name,
    l_bis_bucket_rec.range1_name,
    l_bis_bucket_rec.range2_name,
    l_bis_bucket_rec.range3_name,
    l_bis_bucket_rec.range4_name,
    l_bis_bucket_rec.range5_name,
    l_bis_bucket_rec.range6_name,
    l_bis_bucket_rec.range7_name,
    l_bis_bucket_rec.range8_name,
    l_bis_bucket_rec.range9_name,
    l_bis_bucket_rec.range10_name,
    l_bis_bucket_rec.description,
    'Y',
    userenv('LANG'),
    SYSDATE,
    l_user_id,
    SYSDATE,
    l_user_id,
    l_login_id
    FROM FND_LANGUAGES L
    WHERE L.INSTALLED_FLAG in ('I', 'B')
    AND NOT exists (
      SELECT NULL
      FROM BIS_BUCKET_TL B
      WHERE B.BUCKET_ID = l_bucket_id
      AND B.LANGUAGE = L.LANGUAGE_CODE
   );

  SELECT bis_bucket_customizations_s.nextval
    INTO l_id
    FROM DUAL;

  INSERT INTO bis_bucket_customizations
	(ID,
	BUCKET_ID,
	RANGE1_LOW,
	RANGE1_HIGH,
	RANGE2_LOW,
	RANGE2_HIGH,
	RANGE3_LOW,
	RANGE3_HIGH,
	RANGE4_LOW,
	RANGE4_HIGH,
	RANGE5_LOW,
	RANGE5_HIGH,
	RANGE6_LOW,
	RANGE6_HIGH,
	RANGE7_LOW,
	RANGE7_HIGH,
	RANGE8_LOW,
	RANGE8_HIGH,
	RANGE9_LOW,
	RANGE9_HIGH,
	RANGE10_LOW,
	RANGE10_HIGH,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	CUSTOMIZED)
    VALUES
	( l_id,
	l_bucket_id,
	l_bis_bucket_rec.RANGE1_LOW,
	l_bis_bucket_rec.RANGE1_HIGH,
	l_bis_bucket_rec.RANGE2_LOW,
	l_bis_bucket_rec.RANGE2_HIGH,
	l_bis_bucket_rec.RANGE3_LOW,
	l_bis_bucket_rec.RANGE3_HIGH,
	l_bis_bucket_rec.RANGE4_LOW,
	l_bis_bucket_rec.RANGE4_HIGH,
	l_bis_bucket_rec.RANGE5_LOW,
	l_bis_bucket_rec.RANGE5_HIGH,
	l_bis_bucket_rec.RANGE6_LOW,
	l_bis_bucket_rec.RANGE6_HIGH,
	l_bis_bucket_rec.RANGE7_LOW,
	l_bis_bucket_rec.RANGE7_HIGH,
	l_bis_bucket_rec.RANGE8_LOW,
	l_bis_bucket_rec.RANGE8_HIGH,
	l_bis_bucket_rec.RANGE9_LOW,
	l_bis_bucket_rec.RANGE9_HIGH,
	l_bis_bucket_rec.RANGE10_LOW,
	l_bis_bucket_rec.RANGE10_HIGH,
	l_user_id,
	SYSDATE,
	l_user_id,
	SYSDATE,
	l_login_id,
	'F');

  INSERT INTO bis_bucket_customizations_tl
	(ID,
	RANGE1_NAME,
	RANGE2_NAME,
	RANGE3_NAME,
	RANGE4_NAME,
	RANGE5_NAME,
	RANGE6_NAME,
	RANGE7_NAME,
	RANGE8_NAME,
	RANGE9_NAME,
	RANGE10_NAME,
	LANGUAGE,
	TRANSLATED,
	SOURCE_LANG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN)
      SELECT
	l_id,
	l_bis_bucket_rec.range1_name,
	l_bis_bucket_rec.range2_name,
	l_bis_bucket_rec.range3_name,
	l_bis_bucket_rec.range4_name,
	l_bis_bucket_rec.range5_name,
	l_bis_bucket_rec.range6_name,
	l_bis_bucket_rec.range7_name,
	l_bis_bucket_rec.range8_name,
	l_bis_bucket_rec.range9_name,
	l_bis_bucket_rec.range10_name,
	L.LANGUAGE_CODE,
	'Y',
	userenv('LANG'),
	l_user_id,
	SYSDATE,
	l_user_id,
	SYSDATE,
	l_login_id
	from FND_LANGUAGES L
	where L.INSTALLED_FLAG in ('I', 'B')
	and not exists
	(select NULL
	from BIS_BUCKET_CUSTOMIZATIONS_TL T
	where T.ID = l_id
	and T.LANGUAGE = L.LANGUAGE_CODE);

  COMMIT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    ROLLBACK TO SAVEPOINT SP_CREATE_BUCKET; -- can flow here when CREATE_BIS_BUCKET_TYPE() throws error
    RAISE FND_API.G_EXC_ERROR;

  WHEN others THEN
    ROLLBACK TO SAVEPOINT SP_CREATE_BUCKET;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CREATE_BIS_BUCKET;




--This API should update the tables BIS_BUCKET, BIS_BUCKET_TL
--using the short name or the bucket id as the where clause value
PROCEDURE UPDATE_BIS_BUCKET (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

--l_bis_bucket_rec_orig	BIS_BUCKET_PUB.bis_bucket_rec_type;
l_bis_bucket_rec	BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status		VARCHAR2(10);
l_error_tbl		BIS_UTILITIES_PUB.Error_Tbl_Type;
l_user_id		NUMBER;
l_login_id		NUMBER;
l_ret_name		VARCHAR2(200);
l_ret_id		VARCHAR2(200);
l_short_name		VARCHAR2(200);
l_bis_type_count	NUMBER;
l_bucket_id             NUMBER;
l_id			NUMBER;
l_custom		VARCHAR2(1);
l_err                   VARCHAR2(32000);

BEGIN
  SAVEPOINT SP_UPDATE_BUCKET;

  l_user_id := fnd_global.USER_ID;
  l_login_id := fnd_global.LOGIN_ID;

  l_short_name := p_bis_bucket_rec.short_name;

  l_ret_name := BIS_UTILITIES_PUB.Value_Missing(p_bis_bucket_rec.short_name);
  l_ret_id   := BIS_UTILITIES_PUB.Value_Missing(p_bis_bucket_rec.bucket_id);
  IF (l_ret_name = FND_API.G_FALSE) THEN
    SELECT bucket_id, short_name INTO l_bucket_id, l_short_name
      FROM BIS_BUCKET
      WHERE SHORT_NAME = p_bis_bucket_rec.short_name;
  ELSIF (l_ret_id = FND_API.G_FALSE) THEN
    SELECT bucket_id, short_name INTO l_bucket_id, l_short_name
      FROM BIS_BUCKET
      WHERE BUCKET_ID = p_bis_bucket_rec.bucket_id;
  ELSE
    l_error_tbl := x_error_tbl ;
    BIS_UTILITIES_PVT.Add_Error_Message (
        p_error_msg_name    => 'BIS_INVALID_SHORT_NAME'
       ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
       ,p_error_proc_name   => G_PKG_NAME||'.UPDATE_BIS_BUCKET'
       ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       ,p_error_table       => l_error_tbl
       ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BIS_BUCKET_PVT.Validate_Bucket (
     p_bis_bucket_rec => p_bis_bucket_rec
    ,x_return_status => x_return_status
    ,x_error_Tbl => x_error_tbl
  );

    l_bis_bucket_rec.name := p_bis_bucket_rec.name;
    l_bis_bucket_rec.type := p_bis_bucket_rec.type;
    l_bis_bucket_rec.application_id := p_bis_bucket_rec.application_id;
    l_bis_bucket_rec.range1_name := p_bis_bucket_rec.range1_name;
    l_bis_bucket_rec.range1_low := p_bis_bucket_rec.range1_low;
    l_bis_bucket_rec.range1_high := p_bis_bucket_rec.range1_high;
    l_bis_bucket_rec.range2_name := p_bis_bucket_rec.range2_name;
    l_bis_bucket_rec.range2_low := p_bis_bucket_rec.range2_low;
    l_bis_bucket_rec.range2_high := p_bis_bucket_rec.range2_high;
    l_bis_bucket_rec.range3_name := p_bis_bucket_rec.range3_name;
    l_bis_bucket_rec.range3_low := p_bis_bucket_rec.range3_low;
    l_bis_bucket_rec.range3_high := p_bis_bucket_rec.range3_high;
    l_bis_bucket_rec.range4_name := p_bis_bucket_rec.range4_name;
    l_bis_bucket_rec.range4_low := p_bis_bucket_rec.range4_low;
    l_bis_bucket_rec.range4_high := p_bis_bucket_rec.range4_high;
    l_bis_bucket_rec.range5_name := p_bis_bucket_rec.range5_name;
    l_bis_bucket_rec.range5_low := p_bis_bucket_rec.range5_low;
    l_bis_bucket_rec.range5_high := p_bis_bucket_rec.range5_high;
    l_bis_bucket_rec.range6_name := p_bis_bucket_rec.range6_name;
    l_bis_bucket_rec.range6_low := p_bis_bucket_rec.range6_low;
    l_bis_bucket_rec.range6_high := p_bis_bucket_rec.range6_high;
    l_bis_bucket_rec.range7_name := p_bis_bucket_rec.range7_name;
    l_bis_bucket_rec.range7_low := p_bis_bucket_rec.range7_low;
    l_bis_bucket_rec.range7_high := p_bis_bucket_rec.range7_high;
    l_bis_bucket_rec.range8_name := p_bis_bucket_rec.range8_name;
    l_bis_bucket_rec.range8_low := p_bis_bucket_rec.range8_low;
    l_bis_bucket_rec.range8_high := p_bis_bucket_rec.range8_high;
    l_bis_bucket_rec.range9_name := p_bis_bucket_rec.range9_name;
    l_bis_bucket_rec.range9_low := p_bis_bucket_rec.range9_low;
    l_bis_bucket_rec.range9_high := p_bis_bucket_rec.range9_high;
    l_bis_bucket_rec.range10_name := p_bis_bucket_rec.range10_name;
    l_bis_bucket_rec.range10_low := p_bis_bucket_rec.range10_low;
    l_bis_bucket_rec.range10_high := p_bis_bucket_rec.range10_high;
    l_bis_bucket_rec.description := p_bis_bucket_rec.description;
    l_bis_bucket_rec.updatable := p_bis_bucket_rec.updatable;
    l_bis_bucket_rec.expandable := p_bis_bucket_rec.expandable;
    l_bis_bucket_rec.discontinuous := p_bis_bucket_rec.discontinuous;
    l_bis_bucket_rec.overlapping := p_bis_bucket_rec.overlapping;
    l_bis_bucket_rec.uom := p_bis_bucket_rec.uom;


  UPDATE BIS_BUCKET SET
    TYPE		= l_bis_bucket_rec.type
   ,APPLICATION_ID	= l_bis_bucket_rec.application_id
   ,RANGE1_LOW		= l_bis_bucket_rec.range1_low
   ,RANGE1_HIGH		= l_bis_bucket_rec.range1_high
   ,RANGE2_LOW  	= l_bis_bucket_rec.range2_low
   ,RANGE2_HIGH		= l_bis_bucket_rec.range2_high
   ,RANGE3_LOW  	= l_bis_bucket_rec.range3_low
   ,RANGE3_HIGH		= l_bis_bucket_rec.range3_high
   ,RANGE4_LOW  	= l_bis_bucket_rec.range4_low
   ,RANGE4_HIGH		= l_bis_bucket_rec.range4_high
   ,RANGE5_LOW  	= l_bis_bucket_rec.range5_low
   ,RANGE5_HIGH		= l_bis_bucket_rec.range5_high
   ,RANGE6_LOW  	= l_bis_bucket_rec.range6_low
   ,RANGE6_HIGH		= l_bis_bucket_rec.range6_high
   ,RANGE7_LOW  	= l_bis_bucket_rec.range7_low
   ,RANGE7_HIGH		= l_bis_bucket_rec.range7_high
   ,RANGE8_LOW  	= l_bis_bucket_rec.range8_low
   ,RANGE8_HIGH		= l_bis_bucket_rec.range8_high
   ,RANGE9_LOW  	= l_bis_bucket_rec.range9_low
   ,RANGE9_HIGH		= l_bis_bucket_rec.range9_high
   ,RANGE10_LOW  	= l_bis_bucket_rec.range10_low
   ,RANGE10_HIGH 	= l_bis_bucket_rec.range10_high
   ,UPDATABLE 		= NVL(l_bis_bucket_rec.updatable,'F')
   ,EXPANDABLE 		= NVL(l_bis_bucket_rec.expandable,'F')
   ,DISCONTINUOUS 	= NVL(l_bis_bucket_rec.discontinuous,'F')
   ,OVERLAPPING 	= NVL(l_bis_bucket_rec.overlapping,'F')
   ,UOM 	        = l_bis_bucket_rec.uom
   ,LAST_UPDATE_DATE	= SYSDATE
   ,LAST_UPDATED_BY	= l_user_id
   ,LAST_UPDATE_LOGIN	= l_login_id
    WHERE SHORT_NAME = l_short_name;

  UPDATE BIS_BUCKET_TL SET
    NAME		= l_bis_bucket_rec.name
   ,RANGE1_NAME		= l_bis_bucket_rec.range1_name
   ,RANGE2_NAME		= l_bis_bucket_rec.range2_name
   ,RANGE3_NAME		= l_bis_bucket_rec.range3_name
   ,RANGE4_NAME		= l_bis_bucket_rec.range4_name
   ,RANGE5_NAME		= l_bis_bucket_rec.range5_name
   ,RANGE6_NAME		= l_bis_bucket_rec.range6_name
   ,RANGE7_NAME		= l_bis_bucket_rec.range7_name
   ,RANGE8_NAME		= l_bis_bucket_rec.range8_name
   ,RANGE9_NAME		= l_bis_bucket_rec.range9_name
   ,RANGE10_NAME	= l_bis_bucket_rec.range10_name
   ,DESCRIPTION		= l_bis_bucket_rec.description
   ,LAST_UPDATE_DATE	= SYSDATE
   ,LAST_UPDATED_BY	= l_user_id
   ,LAST_UPDATE_LOGIN	= l_login_id
   ,SOURCE_LANG		= userenv('LANG')
    WHERE BUCKET_ID = l_bucket_Id
    AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  SELECT ID, CUSTOMIZED INTO l_id, l_custom
      FROM bis_bucket_customizations
      WHERE bucket_id = l_bucket_Id AND rownum < 2;

  IF (l_custom = 'F') THEN  --update cust tables

    update BIS_BUCKET_CUSTOMIZATIONS set
    RANGE1_LOW		= l_bis_bucket_rec.range1_low
   ,RANGE1_HIGH		= l_bis_bucket_rec.range1_high
   ,RANGE2_LOW  	= l_bis_bucket_rec.range2_low
   ,RANGE2_HIGH		= l_bis_bucket_rec.range2_high
   ,RANGE3_LOW  	= l_bis_bucket_rec.range3_low
   ,RANGE3_HIGH		= l_bis_bucket_rec.range3_high
   ,RANGE4_LOW  	= l_bis_bucket_rec.range4_low
   ,RANGE4_HIGH		= l_bis_bucket_rec.range4_high
   ,RANGE5_LOW  	= l_bis_bucket_rec.range5_low
   ,RANGE5_HIGH		= l_bis_bucket_rec.range5_high
   ,RANGE6_LOW  	= l_bis_bucket_rec.range6_low
   ,RANGE6_HIGH		= l_bis_bucket_rec.range6_high
   ,RANGE7_LOW  	= l_bis_bucket_rec.range7_low
   ,RANGE7_HIGH		= l_bis_bucket_rec.range7_high
   ,RANGE8_LOW  	= l_bis_bucket_rec.range8_low
   ,RANGE8_HIGH		= l_bis_bucket_rec.range8_high
   ,RANGE9_LOW  	= l_bis_bucket_rec.range9_low
   ,RANGE9_HIGH		= l_bis_bucket_rec.range9_high
   ,RANGE10_LOW  	= l_bis_bucket_rec.range10_low
   ,RANGE10_HIGH 	= l_bis_bucket_rec.range10_high
   ,LAST_UPDATE_DATE	= SYSDATE
   ,LAST_UPDATED_BY	= l_user_id
   ,LAST_UPDATE_LOGIN	= l_login_id
    where BUCKET_ID = l_bucket_Id;

    update BIS_BUCKET_CUSTOMIZATIONS_TL set
     RANGE1_NAME		= l_bis_bucket_rec.range1_name
    ,RANGE2_NAME		= l_bis_bucket_rec.range2_name
    ,RANGE3_NAME		= l_bis_bucket_rec.range3_name
    ,RANGE4_NAME		= l_bis_bucket_rec.range4_name
    ,RANGE5_NAME		= l_bis_bucket_rec.range5_name
    ,RANGE6_NAME		= l_bis_bucket_rec.range6_name
    ,RANGE7_NAME		= l_bis_bucket_rec.range7_name
    ,RANGE8_NAME		= l_bis_bucket_rec.range8_name
    ,RANGE9_NAME		= l_bis_bucket_rec.range9_name
    ,RANGE10_NAME		= l_bis_bucket_rec.range10_name
    ,LAST_UPDATE_DATE = SYSDATE
    ,LAST_UPDATED_BY = l_user_id
    ,LAST_UPDATE_LOGIN = l_login_id
    ,SOURCE_LANG = userenv('LANG')
    where ID = l_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  END IF;

   COMMIT;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO SAVEPOINT SP_UPDATE_BUCKET;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
        p_error_msg_name    => 'BIS_INVALID_BUCKET_ID_NAME'
       ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
       ,p_error_proc_name   => G_PKG_NAME||'.UPDATE_BIS_BUCKET'
       ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       ,p_error_table       => l_error_tbl
       ,x_error_table       => x_error_tbl
    );
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO SAVEPOINT SP_UPDATE_BUCKET;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RAISE FND_API.G_EXC_ERROR;
  WHEN others THEN
    ROLLBACK TO SAVEPOINT SP_UPDATE_BUCKET;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.UPDATE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_BIS_BUCKET;


--This API should delete a row from the tables BIS_BUCKET and BIS_BUCKET_TL
--using the short name or the bucket id as the where clause value
--It should also delete the rows from BIS_BUCKET_CUSTOMIZATIONS and
--BIS_BUCKET_CUSTOMIZATIONS_TL tables.
PROCEDURE DELETE_BIS_BUCKET (
  p_bucket_id   	IN BIS_BUCKET.bucket_id%TYPE		:= BIS_UTILITIES_PUB.G_NULL_NUM
 ,p_short_name		IN BIS_BUCKET.short_name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_dcount	NUMBER;
l_ret_id	VARCHAR2(200);
l_ret_name	VARCHAR2(200);
l_bucket_id	NUMBER;
l_return_status	VARCHAR2(10);
l_error_tbl	BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_ret_name := BIS_UTILITIES_PUB.Value_Missing(p_short_name);
  l_ret_id   := BIS_UTILITIES_PUB.Value_Missing(p_bucket_id);

  IF (l_ret_name = FND_API.G_FALSE) THEN
    SELECT bucket_id INTO l_bucket_id FROM BIS_BUCKET
      WHERE SHORT_NAME = p_short_name;

    DELETE from BIS_BUCKET_CUSTOMIZATIONS_TL
    WHERE id in (
        SELECT id
        FROM BIS_BUCKET_CUSTOMIZATIONS
        WHERE bucket_id = l_bucket_id);

    DELETE from BIS_BUCKET_CUSTOMIZATIONS
    WHERE bucket_id = l_bucket_id;

    DELETE from BIS_BUCKET_TL
    WHERE bucket_id = l_bucket_id;

    DELETE from BIS_BUCKET
    WHERE short_name = p_short_name;

  ELSIF (l_ret_id = FND_API.G_FALSE) THEN
    SELECT count(BUCKET_ID) INTO l_dcount FROM BIS_BUCKET
      WHERE BUCKET_ID = p_bucket_id;

    IF (l_dcount = 0) THEN
      l_error_tbl := x_error_tbl ;
      BIS_UTILITIES_PVT.Add_Error_Message (
        p_error_msg_name    => 'BIS_INVALID_BUCKET_ID'
       ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
       ,p_error_proc_name   => G_PKG_NAME||'.DELETE_BUCKET'
       ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
       ,p_error_table       => l_error_tbl
       ,x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      DELETE from BIS_BUCKET_CUSTOMIZATIONS_TL
      WHERE id in (
        SELECT id
        FROM BIS_BUCKET_CUSTOMIZATIONS
        WHERE bucket_id = p_bucket_id);

      DELETE from BIS_BUCKET_CUSTOMIZATIONS
      WHERE bucket_id = p_bucket_id;

      DELETE from BIS_BUCKET_TL
      WHERE bucket_id = p_bucket_id;

      DELETE from BIS_BUCKET
        WHERE bucket_id = p_bucket_id;

    END IF;
  ELSE
    l_error_tbl := x_error_tbl ;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_INVALID_BUCKET_ID_NAME'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.DELETE_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  COMMIT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    l_error_tbl := x_error_tbl ;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_INVALID_SHORT_NAME'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.DELETE_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    RAISE FND_API.G_EXC_ERROR;

  WHEN others THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.DELETE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DELETE_BIS_BUCKET;


--This API should populate a record of type bis_bucket_rec_type based on the bucket short name
-- Modified for bug #3394457 , ankgoel
-- Retrieve the record always from the customization table
PROCEDURE RETRIEVE_BIS_BUCKET (
  p_short_name		IN BIS_BUCKET.short_name%TYPE  		:= BIS_UTILITIES_PUB.G_NULL_CHAR
 ,x_bis_bucket_rec	OUT NOCOPY BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_ret_name		VARCHAR2(200);
l_dcount		NUMBER;
l_return_status		VARCHAR2(10);
l_error_tbl		BIS_UTILITIES_PUB.Error_Tbl_Type;


 CURSOR c_bucket_cust (p_short_name VARCHAR2) IS
   SELECT
     BC.BUCKET_ID,
     B.NAME,
     B.TYPE,
     BC.APPLICATION_ID,
     BC.RANGE1_NAME,
     BC.RANGE1_LOW,
     BC.RANGE1_HIGH,
     BC.RANGE2_NAME,
     BC.RANGE2_LOW,
     BC.RANGE2_HIGH,
     BC.RANGE3_NAME,
     BC.RANGE3_LOW,
     BC.RANGE3_HIGH,
     BC.RANGE4_NAME,
     BC.RANGE4_LOW,
     BC.RANGE4_HIGH,
     BC.RANGE5_NAME,
     BC.RANGE5_LOW,
     BC.RANGE5_HIGH,
     BC.RANGE6_NAME,
     BC.RANGE6_LOW,
     BC.RANGE6_HIGH,
     BC.RANGE7_NAME,
     BC.RANGE7_LOW,
     BC.RANGE7_HIGH,
     BC.RANGE8_NAME,
     BC.RANGE8_LOW,
     BC.RANGE8_HIGH,
     BC.RANGE9_NAME,
     BC.RANGE9_LOW,
     BC.RANGE9_HIGH,
     BC.RANGE10_NAME,
     BC.RANGE10_LOW,
     BC.RANGE10_HIGH,
     B.DESCRIPTION,
     B.UPDATABLE,
     B.EXPANDABLE,
     B.DISCONTINUOUS,
     B.OVERLAPPING,
     B.UOM
   FROM BIS_BUCKET_CUSTOMIZATIONS_VL BC,BIS_BUCKET_VL B
        WHERE B.SHORT_NAME = p_short_name
        AND B.BUCKET_ID=BC.BUCKET_ID;


BEGIN

  l_ret_name := BIS_UTILITIES_PUB.Value_Missing(p_short_name);

  SELECT count(SHORT_NAME) INTO l_dcount FROM BIS_BUCKET
    WHERE SHORT_NAME = p_short_name;

  IF ((l_ret_name = FND_API.G_TRUE) OR (l_dcount = 0)) THEN
    l_error_tbl := x_error_tbl ;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_INVALID_SHORT_NAME'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.DELETE_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 -- Fix for bug #3339143

   OPEN  c_bucket_cust (p_short_name => p_short_name) ;

    FETCH c_bucket_cust INTO
           x_bis_bucket_rec.bucket_id
          ,x_bis_bucket_rec.name
          ,x_bis_bucket_rec.type
          ,x_bis_bucket_rec.application_id
          ,x_bis_bucket_rec.range1_name
          ,x_bis_bucket_rec.range1_low
          ,x_bis_bucket_rec.range1_high
          ,x_bis_bucket_rec.range2_name
          ,x_bis_bucket_rec.range2_low
          ,x_bis_bucket_rec.range2_high
          ,x_bis_bucket_rec.range3_name
          ,x_bis_bucket_rec.range3_low
          ,x_bis_bucket_rec.range3_high
          ,x_bis_bucket_rec.range4_name
          ,x_bis_bucket_rec.range4_low
          ,x_bis_bucket_rec.range4_high
          ,x_bis_bucket_rec.range5_name
          ,x_bis_bucket_rec.range5_low
          ,x_bis_bucket_rec.range5_high
          ,x_bis_bucket_rec.range6_name
          ,x_bis_bucket_rec.range6_low
          ,x_bis_bucket_rec.range6_high
          ,x_bis_bucket_rec.range7_name
          ,x_bis_bucket_rec.range7_low
          ,x_bis_bucket_rec.range7_high
          ,x_bis_bucket_rec.range8_name
          ,x_bis_bucket_rec.range8_low
          ,x_bis_bucket_rec.range8_high
          ,x_bis_bucket_rec.range9_name
          ,x_bis_bucket_rec.range9_low
          ,x_bis_bucket_rec.range9_high
          ,x_bis_bucket_rec.range10_name
          ,x_bis_bucket_rec.range10_low
          ,x_bis_bucket_rec.range10_high
          ,x_bis_bucket_rec.description
          ,x_bis_bucket_rec.updatable
          ,x_bis_bucket_rec.expandable
          ,x_bis_bucket_rec.discontinuous
          ,x_bis_bucket_rec.overlapping
      	  ,x_bis_bucket_rec.uom;


     IF (c_bucket_cust%ISOPEN) THEN
        CLOSE c_bucket_cust;
     END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_bucket_cust%ISOPEN) THEN
      CLOSE c_bucket_cust;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR ;
    RAISE FND_API.G_EXC_ERROR;
  WHEN others THEN
    IF (c_bucket_cust%ISOPEN) THEN
      CLOSE c_bucket_cust;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.RETRIEVE_BIS_BUCKET'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );

END RETRIEVE_BIS_BUCKET;

PROCEDURE TRANSLATE_BUCKET (
  p_bis_bucket_rec	IN  BIS_BUCKET_PUB.bis_bucket_rec_type
 ,p_owner		IN  VARCHAR2
 ,x_return_status	OUT NOCOPY VARCHAR2
 ,x_error_Tbl		OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

l_user_id		NUMBER;
l_login_id		NUMBER;
l_bis_bucket_rec	BIS_BUCKET_PUB.bis_bucket_rec_type;
l_bis_bucket_rec_orig	BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status		VARCHAR2(10);
l_error_tbl		BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_bis_bucket_rec  := p_bis_bucket_rec;

  BIS_BUCKET_PVT.RETRIEVE_BIS_BUCKET (
    p_short_name	=> l_bis_bucket_rec.short_name
   ,x_bis_bucket_rec	=> l_bis_bucket_rec_orig
   ,x_return_status     => l_return_status
   ,x_error_tbl         => l_error_tbl
  );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    x_error_tbl := l_error_tbl;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_bis_bucket_rec.bucket_id := l_bis_bucket_rec_orig.bucket_id;

  IF (p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER) THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.user_id;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;

  UPDATE BIS_BUCKET_TL
    SET
      NAME              = l_bis_bucket_rec.name
     ,RANGE1_NAME	= l_bis_bucket_rec.range1_name
     ,RANGE2_NAME	= l_bis_bucket_rec.range2_name
     ,RANGE3_NAME	= l_bis_bucket_rec.range3_name
     ,RANGE4_NAME	= l_bis_bucket_rec.range4_name
     ,RANGE5_NAME	= l_bis_bucket_rec.range5_name
     ,RANGE6_NAME	= l_bis_bucket_rec.range6_name
     ,RANGE7_NAME	= l_bis_bucket_rec.range7_name
     ,RANGE8_NAME	= l_bis_bucket_rec.range8_name
     ,RANGE9_NAME	= l_bis_bucket_rec.range9_name
     ,RANGE10_NAME	= l_bis_bucket_rec.range10_name
     ,DESCRIPTION	= l_bis_bucket_rec.description
     ,LAST_UPDATE_DATE  = SYSDATE
     ,LAST_UPDATED_BY   = l_user_id
     ,LAST_UPDATE_LOGIN = l_login_id
     ,SOURCE_LANG       = userenv('LANG')
      WHERE BUCKET_ID  = l_bis_bucket_rec.bucket_id
      AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  UPDATE BIS_BUCKET_CUSTOMIZATIONS_TL
    SET
      RANGE1_NAME = l_bis_bucket_rec.range1_name
     ,RANGE2_NAME = l_bis_bucket_rec.range2_name
     ,RANGE3_NAME = l_bis_bucket_rec.range3_name
     ,RANGE4_NAME = l_bis_bucket_rec.range4_name
     ,RANGE5_NAME = l_bis_bucket_rec.range5_name
     ,RANGE6_NAME = l_bis_bucket_rec.range6_name
     ,RANGE7_NAME = l_bis_bucket_rec.range7_name
     ,RANGE8_NAME = l_bis_bucket_rec.range8_name
     ,RANGE9_NAME = l_bis_bucket_rec.range9_name
     ,RANGE10_NAME = l_bis_bucket_rec.range10_name
     ,LAST_UPDATE_DATE  = SYSDATE
     ,LAST_UPDATED_BY   = l_user_id
     ,LAST_UPDATE_LOGIN = l_login_id
     ,SOURCE_LANG       = userenv('LANG')
     WHERE id in (
        SELECT id
        FROM BIS_BUCKET_CUSTOMIZATIONS
        WHERE bucket_id = l_bis_bucket_rec.bucket_id)
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  COMMIT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message(
        p_error_msg_id      => SQLCODE
       ,p_error_description => SQLERRM
       ,p_error_proc_name   => G_PKG_NAME||'.Translate_bucket'
       ,p_error_table       => l_error_tbl
       ,x_error_table       => x_error_tbl
      );

END TRANSLATE_BUCKET;


FUNCTION CHECK_RANGE_NAME (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
) RETURN BOOLEAN
IS

  TYPE range_name_t IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  l_range_name range_name_t;
  l_hash_value binary_integer;

BEGIN

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range1_name)= FND_API.G_TRUE) THEN
    l_hash_value :=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range1_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    l_range_name(l_hash_value) := p_bis_bucket_rec.range1_name;
  END IF;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range2_name)= FND_API.G_TRUE) THEN
    l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range2_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range2_name;
    END IF;
  END IF;

  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range3_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range3_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range3_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range4_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range4_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range4_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range5_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range5_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range5_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range6_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range6_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range6_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range7_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range7_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range7_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range8_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range8_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range8_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range9_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range9_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range9_name;
    END IF;
  END IF;


  IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range10_name)= FND_API.G_TRUE) THEN
   l_hash_value:=Dbms_Utility.Get_Hash_Value (
		   name      => p_bis_bucket_rec.range10_name
	          ,base      => 2
	          ,hash_size => 1048576
		 );

    IF (l_range_name.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_name(l_hash_value) := p_bis_bucket_rec.range10_name;
    END IF;
  END IF;


  RETURN TRUE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;

  WHEN others THEN
    RETURN FALSE;

END CHECK_RANGE_NAME;

--=============================================================================
FUNCTION CHECK_RANGE_VAL_LOW (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
) RETURN BOOLEAN
IS

  TYPE range_low_t IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  l_range_low  range_low_t;
  l_hash_value binary_integer;

BEGIN
  	IF((p_bis_bucket_rec.overlapping ='T') OR (p_bis_bucket_rec.discontinuous='T')) THEN
  	  RETURN TRUE;
  	END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range1_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range1_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range1_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range2_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range2_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range2_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range3_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range3_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range3_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range4_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range4_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range4_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range5_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range5_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range5_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range6_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range6_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range6_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range7_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range7_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range7_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range8_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range8_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range8_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range9_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range9_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range9_low;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range10_low)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range10_low
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_low.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_low(l_hash_value) := p_bis_bucket_rec.range10_low;
    END IF;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;

  WHEN others THEN
    RETURN FALSE;

END CHECK_RANGE_VAL_LOW;
--=============================================================================
FUNCTION CHECK_RANGE_VAL_HIGH (
  p_bis_bucket_rec	IN BIS_BUCKET_PUB.bis_bucket_rec_type
) RETURN BOOLEAN
IS

  TYPE range_high_t IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  l_range_high  range_high_t;
  l_hash_value binary_integer;

BEGIN
	IF((p_bis_bucket_rec.overlapping ='T') OR (p_bis_bucket_rec.discontinuous='T')) THEN
	    RETURN TRUE;
	  END IF;
	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range1_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range1_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range1_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range2_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range2_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range2_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range3_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range3_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range3_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range4_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range4_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range4_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range5_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range5_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range5_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range6_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range6_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range6_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range7_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range7_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range7_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range8_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range8_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range8_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range9_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range9_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range9_high;
    END IF;
  END IF;

	IF (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range10_high)= FND_API.G_TRUE) THEN
    l_hash_value :=DBMS_UTILITY.GET_HASH_VALUE (
                      name      => p_bis_bucket_rec.range10_high
                     ,base      => 2
                     ,hash_size => 1048576
                   );

    IF (l_range_high.exists(l_hash_value)) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      l_range_high(l_hash_value) := p_bis_bucket_rec.range10_high;
    END IF;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RETURN FALSE;

  WHEN others THEN
    RETURN FALSE;

END CHECK_RANGE_VAL_HIGH;
--=============================================================================
-- Each bucket type is a lookup code
-- All lookup codes are under 'BIS_BUCKET_TYPE' lookup type

FUNCTION IS_BUCKET_TYPE_EXISTS (
  p_bucket_type IN VARCHAR2
) RETURN BOOLEAN IS

l_dummy NUMBER;

CURSOR c_fnd_lookups (cp_lookup_code VARCHAR2) IS
  SELECT 1
  FROM   fnd_lookup_types a, fnd_lookup_values b
  WHERE  UPPER(b.lookup_code) = UPPER(cp_lookup_code)
  AND    b.lookup_type = a.lookup_type
  AND    a.lookup_type = 'BIS_BUCKET_TYPE';

BEGIN

  IF (c_fnd_lookups%ISOPEN) THEN
    CLOSE c_fnd_lookups;
  END IF;

  OPEN c_fnd_lookups(cp_lookup_code => p_bucket_type);
  FETCH c_fnd_lookups INTO l_dummy;
  IF (c_fnd_lookups%NOTFOUND) THEN
    CLOSE c_fnd_lookups;
    RETURN FALSE;
  ELSE
    CLOSE c_fnd_lookups;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_fnd_lookups%ISOPEN) THEN
      CLOSE c_fnd_lookups;
    END IF;
    RETURN FALSE;

END IS_BUCKET_TYPE_EXISTS;
--=============================================================================
PROCEDURE Validate_Bucket (
   p_bis_bucket_rec IN BIS_BUCKET_PUB.bis_bucket_rec_type
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) IS

  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_bis_bucket_rec BIS_BUCKET_PUB.bis_bucket_rec_type;

  l_bucket_ranges_tbl  	BIS_BUCKET_PVT.BIS_BUCKET_RANGES_TBL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_bis_bucket_rec := p_bis_bucket_rec;

  IF NOT (IS_VALID_APPLICATION_ID(p_application_id => l_bis_bucket_rec.application_id)) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_INVALID_APPLICATION_ID'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET_APPLICATION_ID'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BIS_BUCKET_PVT.Validate_Bucket_Common (
     p_bis_bucket_rec => l_bis_bucket_rec
    ,x_return_status => x_return_status
    ,x_error_Tbl => x_error_tbl
  );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --dbms_output.put_line( 'x_return_status (Not wrapper) is ' || x_return_status);
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Bucket;
--=============================================================================

FUNCTION GET_REPORT_LISTS(
   p_bucket_short_name  IN VARCHAR2 DEFAULT NULL
   ,p_bucket_id IN NUMBER DEFAULT NULL
) return VARCHAR2
IS

l_bucket_short_name VARCHAR2(30);
l_reports_name VARCHAR2(32000);
l_count NUMBER;

cursor c_akregion (p1 varchar2, p2 varchar2) IS
   SELECT region_code
   FROM ak_region_items
   WHERE (attribute1 = p1
   OR attribute1 IS NULL)
   AND attribute2 = p2
   GROUP BY region_code;

-- Added filter critera type='WWW' for enh #3471325
cursor c_formfunction (p1 varchar2) IS
   SELECT user_function_name
   FROM fnd_form_functions_vl
   WHERE parameters like '%pRegionCode=%' -- For perf tuning.
   AND parameters like '%pRegionCode=' || p1 || '&%'
   AND type = 'WWW';

   --Fix for bug #3488336
-- Added filter critera type='WWW' for enh #3471325
cursor c_webfunction (p1 varchar2) IS
   SELECT user_function_name
   FROM fnd_form_functions_vl
   WHERE upper(web_html_call) like 'BISVIEWER.SHOWREPORT(''' || p1 || '''%'
   AND type = 'WWW';

BEGIN

l_reports_name := '';
l_count := 0;

IF ((p_bucket_short_name is NULL) AND (p_bucket_id is NULL)) THEN
  return '';
END IF;

IF (p_bucket_short_name is NULL) THEN
  select short_name into l_bucket_short_name
  FROM bis_bucket
  WHERE bucket_id = p_bucket_id;
ELSE
  l_bucket_short_name := p_bucket_short_name;
END IF;

FOR akr in c_akregion(c_bucket_att, l_bucket_short_name) LOOP

   FOR ffv in c_formfunction(akr.region_code)  LOOP

      IF (l_count = 0) THEN
         l_reports_name := l_reports_name || ffv.user_function_name;
      ELSE
         l_reports_name := l_reports_name || ', ' || ffv.user_function_name;
      END IF;

      l_count := l_count + 1;

   END LOOP;
   -- Fix #3488336
   FOR wbh in c_webfunction(akr.region_code)  LOOP

      IF (l_count = 0) THEN
         l_reports_name := l_reports_name || wbh.user_function_name;
      ELSE
         l_reports_name := l_reports_name || ', ' || wbh.user_function_name;
      END IF;

      l_count := l_count + 1;

   END LOOP;

END LOOP;
  RETURN l_reports_name;

EXCEPTION

  WHEN OTHERS THEN  -- if no such table exists
    RETURN '';
END GET_REPORT_LISTS;

--=============================================================================
--API for populating the table of records with low and high range values
--Needed for range validations -- overlappig and discontinous.
-- If the bucket has no label, it doesn't count as a valid bucket.
--=============================================================================
PROCEDURE Populate_Loc_Bucket_Range_Tbl
(
  p_bis_bucket_rec      IN BIS_BUCKET_PUB.bis_bucket_rec_type
 ,x_bucket_ranges_tbl   OUT NOCOPY BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_valid_bucket_count	   NUMBER 		:= 0;
  l_error_tbl 		       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  x_return_status	 := FND_API.G_RET_STS_SUCCESS;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range1_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range1_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range1_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range1_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range1_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range2_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range2_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range2_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range2_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range2_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range3_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range3_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range3_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range3_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range3_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range4_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range4_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range4_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range4_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range4_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range5_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range5_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range5_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range5_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range5_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range6_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range6_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range6_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range6_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range6_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range7_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range7_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range7_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range7_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range7_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range8_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range8_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range8_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range8_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range8_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range9_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range9_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range9_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range9_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range9_high;
      l_valid_bucket_count := l_valid_bucket_count + 1;
  END IF;

  IF ((BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range10_name)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range10_low)= FND_API.G_TRUE)
      OR (BIS_UTILITIES_PUB.Value_Not_Missing(p_bis_bucket_rec.range10_high)= FND_API.G_TRUE)) THEN
      x_bucket_ranges_tbl(l_valid_bucket_count).range_low  := p_bis_bucket_rec.range10_low;
      x_bucket_ranges_tbl(l_valid_bucket_count).range_high := p_bis_bucket_rec.range10_high;
  END IF;


EXCEPTION
WHEN OTHERS THEN
  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.Populate_Loc_Bucket_Range_Tbl'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
END Populate_Loc_Bucket_Range_Tbl;

--=============================================================================
--API for validating the overlapping feature of the bucket
-- If it allows overlapping, no validation is needed.
-- Validation is only needed if it doesn't allow overlapping.
--=============================================================================
PROCEDURE Validate_Bucket_Overlapping (
  p_overlapping    IN  VARCHAR2
 ,p_bucket_ranges_tbl   IN BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_bucket_count	NUMBER 		:= 0;
  l_error_code		VARCHAR2(1);
  l_error_tbl 		BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  l_bucket_count	:= p_bucket_ranges_tbl.COUNT();

  IF (p_overlapping = 'F') THEN
     FOR buckets IN 1 .. l_bucket_count - 1 LOOP
        --dbms_output.put_line( 'bucket number(overlapping) is ' || buckets);
        --dbms_output.put_line( 'bucket.range_low is ' || p_bucket_ranges_tbl(buckets).RANGE_LOW);
        --dbms_output.put_line( 'bucket-1.range_high is ' || p_bucket_ranges_tbl(buckets-1).RANGE_HIGH);
        IF (p_bucket_ranges_tbl(buckets).RANGE_LOW IS NULL) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (p_bucket_ranges_tbl(buckets - 1).RANGE_HIGH IS NULL) THEN
           RAISE FND_API.G_EXC_ERROR;
        --ELSIF ((p_bucket_ranges_tbl(buckets).RANGE_LOW IS NOT NULL) AND (p_bucket_ranges_tbl(buckets - 1).RANGE_HIGH IS NOT NULL)) THEN
        ELSIF (p_bucket_ranges_tbl(buckets).RANGE_LOW < p_bucket_ranges_tbl(buckets - 1).RANGE_HIGH) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END LOOP;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN -- overlapping occurs
  	x_return_status := FND_API.G_RET_STS_ERROR;
  	BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_BUCKET_SET_OVERLAPPING'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.Validate_Bucket_Overlapping'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.Validate_Bucket_Overlapping'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
END Validate_Bucket_Overlapping;


--=============================================================================
--API for validating the discontinuous feature of the bucket
-- If it allows discontinuous, no validation is needed.
-- Validation is only needed if it doesn't allow discontinuous.
--=============================================================================
PROCEDURE Validate_Bucket_Discontinuous (
  p_discontinuous    IN  VARCHAR2
 ,p_bucket_ranges_tbl   IN BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_bucket_count	NUMBER 		:= 0;
  l_error_code		VARCHAR2(1);
  l_error_tbl 		BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  l_bucket_count	:= p_bucket_ranges_tbl.COUNT();

  IF (p_discontinuous = 'F') THEN
     FOR buckets IN 1 .. l_bucket_count - 1 LOOP
        --dbms_output.put_line( 'bucket number(discontinuous) is ' || buckets);
        --dbms_output.put_line( 'bucket.range_low is ' || p_bucket_ranges_tbl(buckets).RANGE_LOW);
        --dbms_output.put_line( 'bucket-1.range_high is ' || p_bucket_ranges_tbl(buckets-1).RANGE_HIGH);
        IF (p_bucket_ranges_tbl(buckets).RANGE_LOW IS NULL) THEN
           RAISE FND_API.G_EXC_ERROR;
        ELSIF (p_bucket_ranges_tbl(buckets - 1).RANGE_HIGH IS NULL) THEN
           RAISE FND_API.G_EXC_ERROR;
	ELSIF (p_bucket_ranges_tbl(buckets).RANGE_LOW <> p_bucket_ranges_tbl(buckets-1).RANGE_HIGH) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN -- discontinuous occurs
  	x_return_status := FND_API.G_RET_STS_ERROR;
  	BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_BUCKET_SET_DISCONTINUOUS'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.Validate_Bucket_Discontinuous'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
  	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.Validate_Bucket_Discontinuous'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
END Validate_Bucket_Discontinuous;

--=============================================================================
--API for validating that the FROM is always less than or equal to TO
--=============================================================================
PROCEDURE Validate_From_To (
  p_bucket_ranges_tbl   IN BIS_BUCKET_PVT.bis_bucket_ranges_tbl
 ,x_return_status  OUT NOCOPY VARCHAR2
 ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_bucket_count	NUMBER 		:= 0;
  l_error_code		VARCHAR2(1);
  l_error_tbl 		BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error_message	VARCHAR2(50);

BEGIN

  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  l_bucket_count	:= p_bucket_ranges_tbl.COUNT();

     FOR buckets IN 0 .. l_bucket_count - 1 LOOP
       IF ((p_bucket_ranges_tbl(buckets).RANGE_LOW IS NULL) AND (p_bucket_ranges_tbl(buckets).RANGE_HIGH) IS NULL) THEN
          l_error_message := 'BIS_BUCKET_NULL';
	  RAISE FND_API.G_EXC_ERROR;
       ELSIF (p_bucket_ranges_tbl(buckets).RANGE_LOW > p_bucket_ranges_tbl(buckets).RANGE_HIGH) THEN
	  l_error_message := 'BIS_BUCKET_FROM_TO';
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN -- FROM > TO
     x_return_status := FND_API.G_RET_STS_ERROR;
     BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => l_error_message
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.Validate_From_To'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_id      => SQLCODE
     ,p_error_description => SQLERRM
     ,p_error_proc_name   => G_PKG_NAME||'.Validate_From_To'
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
END Validate_From_To;

--=============================================================================
--This is the java wrapper for bucket customization UI.
PROCEDURE VALIDATE_BUCKET_WRAPPER (
  p_short_name		IN BIS_BUCKET.short_name%TYPE
 ,p_name		IN BIS_BUCKET_TL.name%TYPE
 ,p_type		IN BIS_BUCKET.type%TYPE
 ,p_application_id	IN BIS_BUCKET.application_id%TYPE
 ,p_range1_name		IN BIS_BUCKET_TL.range1_name%TYPE
 ,p_range1_low		IN BIS_BUCKET.range1_low%TYPE
 ,p_range1_high    	IN BIS_BUCKET.range1_high%TYPE
 ,p_range2_name		IN BIS_BUCKET_TL.range2_name%TYPE
 ,p_range2_low		IN BIS_BUCKET.range2_low%TYPE
 ,p_range2_high    	IN BIS_BUCKET.range2_high%TYPE
 ,p_range3_name		IN BIS_BUCKET_TL.range3_name%TYPE
 ,p_range3_low		IN BIS_BUCKET.range3_low%TYPE
 ,p_range3_high    	IN BIS_BUCKET.range3_high%TYPE
 ,p_range4_name		IN BIS_BUCKET_TL.range4_name%TYPE
 ,p_range4_low		IN BIS_BUCKET.range4_low%TYPE
 ,p_range4_high    	IN BIS_BUCKET.range4_high%TYPE
 ,p_range5_name		IN BIS_BUCKET_TL.range5_name%TYPE
 ,p_range5_low		IN BIS_BUCKET.range5_low%TYPE
 ,p_range5_high    	IN BIS_BUCKET.range5_high%TYPE
 ,p_range6_name		IN BIS_BUCKET_TL.range6_name%TYPE
 ,p_range6_low		IN BIS_BUCKET.range6_low%TYPE
 ,p_range6_high    	IN BIS_BUCKET.range6_high%TYPE
 ,p_range7_name		IN BIS_BUCKET_TL.range7_name%TYPE
 ,p_range7_low		IN BIS_BUCKET.range7_low%TYPE
 ,p_range7_high    	IN BIS_BUCKET.range7_high%TYPE
 ,p_range8_name		IN BIS_BUCKET_TL.range8_name%TYPE
 ,p_range8_low		IN BIS_BUCKET.range8_low%TYPE
 ,p_range8_high    	IN BIS_BUCKET.range8_high%TYPE
 ,p_range9_name		IN BIS_BUCKET_TL.range9_name%TYPE
 ,p_range9_low		IN BIS_BUCKET.range9_low%TYPE
 ,p_range9_high    	IN BIS_BUCKET.range9_high%TYPE
 ,p_range10_name	IN BIS_BUCKET_TL.range10_name%TYPE
 ,p_range10_low		IN BIS_BUCKET.range10_low%TYPE
 ,p_range10_high    IN BIS_BUCKET.range10_high%TYPE
 ,p_description		IN BIS_BUCKET_TL.description%TYPE
 ,p_updatable		IN BIS_BUCKET.updatable%TYPE := 'F'
 ,p_expandable		IN BIS_BUCKET.expandable%TYPE := 'F'
 ,p_discontinuous	IN BIS_BUCKET.discontinuous%TYPE := 'F'
 ,p_overlapping		IN BIS_BUCKET.overlapping%TYPE := 'F'
 ,p_uom		        IN BIS_BUCKET.uom%TYPE
 ,x_return_status       OUT NOCOPY VARCHAR2
 ,x_error_msg           OUT NOCOPY VARCHAR2
)
IS

l_bis_bucket_rec  BIS_BUCKET_PUB.bis_bucket_rec_type;
l_return_status   VARCHAR2(10);
l_error_tbl       BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_bis_bucket_rec.short_name := p_short_name;
  l_bis_bucket_rec.name := p_name;
  l_bis_bucket_rec.type := p_type;
  l_bis_bucket_rec.application_id := p_application_id;
  l_bis_bucket_rec.range1_name := p_range1_name;
  l_bis_bucket_rec.range1_low := p_range1_low;
  l_bis_bucket_rec.range1_high := p_range1_high;
  l_bis_bucket_rec.range2_name := p_range2_name;
  l_bis_bucket_rec.range2_low := p_range2_low;
  l_bis_bucket_rec.range2_high := p_range2_high;
  l_bis_bucket_rec.range3_name := p_range3_name;
  l_bis_bucket_rec.range3_low := p_range3_low;
  l_bis_bucket_rec.range3_high := p_range3_high;
  l_bis_bucket_rec.range4_name := p_range4_name;
  l_bis_bucket_rec.range4_low := p_range4_low;
  l_bis_bucket_rec.range4_high := p_range4_high;
  l_bis_bucket_rec.range5_name := p_range5_name;
  l_bis_bucket_rec.range5_low := p_range5_low;
  l_bis_bucket_rec.range5_high := p_range5_high;
  l_bis_bucket_rec.range6_name := p_range6_name;
  l_bis_bucket_rec.range6_low := p_range6_low;
  l_bis_bucket_rec.range6_high := p_range6_high;
  l_bis_bucket_rec.range7_name := p_range7_name;
  l_bis_bucket_rec.range7_low := p_range7_low;
  l_bis_bucket_rec.range7_high := p_range7_high;
  l_bis_bucket_rec.range8_name := p_range8_name;
  l_bis_bucket_rec.range8_low := p_range8_low;
  l_bis_bucket_rec.range8_high := p_range8_high;
  l_bis_bucket_rec.range9_name := p_range9_name;
  l_bis_bucket_rec.range9_low := p_range9_low;
  l_bis_bucket_rec.range9_high := p_range9_high;
  l_bis_bucket_rec.range10_name := p_range10_name;
  l_bis_bucket_rec.range10_low := p_range10_low;
  l_bis_bucket_rec.range10_high := p_range10_high;
  l_bis_bucket_rec.description := p_description;
  l_bis_bucket_rec.updatable := p_updatable;
  l_bis_bucket_rec.expandable := p_expandable;
  l_bis_bucket_rec.discontinuous := p_discontinuous;
  l_bis_bucket_rec.overlapping := p_overlapping;
  l_bis_bucket_rec.uom := p_uom;

  BIS_BUCKET_PVT.Validate_Bucket_Common (
     p_bis_bucket_rec => l_bis_bucket_rec
    ,x_return_status => l_return_status
    ,x_error_Tbl => l_error_tbl
  );

  x_return_status := l_return_status;

  IF (l_error_tbl.EXISTS(1)) THEN
    x_error_msg := l_error_tbl(1).Error_Msg_Name;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF (l_error_tbl.EXISTS(1)) THEN
      x_error_msg := l_error_tbl(1).Error_Msg_Name;
    END IF;
END VALIDATE_BUCKET_WRAPPER;

FUNCTION IS_VALID_APPLICATION_ID (
  p_application_id      IN   NUMBER
) RETURN BOOLEAN
IS

  l_count    NUMBER;

BEGIN
  SELECT COUNT(application_id) into l_count
  FROM FND_APPLICATION
  WHERE APPLICATION_ID = p_application_id;

   IF (l_count = 0) THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;

END IS_VALID_APPLICATION_ID;

--=============================================================================
--The common validation that good for bucket. (Normal, Customized)
PROCEDURE Validate_Bucket_Common (
   p_bis_bucket_rec IN BIS_BUCKET_PUB.bis_bucket_rec_type
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_error_tbl      OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
) IS

  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_bis_bucket_rec BIS_BUCKET_PUB.bis_bucket_rec_type;

  l_bucket_ranges_tbl  	BIS_BUCKET_PVT.BIS_BUCKET_RANGES_TBL;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.Initialize;

  l_bis_bucket_rec := p_bis_bucket_rec;

  IF NOT (IS_BUCKET_TYPE_EXISTS(p_bucket_type=> l_bis_bucket_rec.type)) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_INVALID_BUCKET_TYPE'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET_TYPE'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF NOT ( CHECK_RANGE_NAME(p_bis_bucket_rec => l_bis_bucket_rec) ) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_DUPLICATE_RANGE_NAME'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF NOT ( CHECK_RANGE_VAL_HIGH(p_bis_bucket_rec => l_bis_bucket_rec) ) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_DUPLICATE_VAL_HIGH'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF NOT ( CHECK_RANGE_VAL_LOW(p_bis_bucket_rec => l_bis_bucket_rec) ) THEN
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message (
      p_error_msg_name    => 'BIS_DUPLICATE_VAL_LOW'
     ,p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
     ,p_error_proc_name   => G_PKG_NAME||'.CREATE_BIS_BUCKET'
     ,p_error_type        => BIS_UTILITIES_PUB.G_ERROR
     ,p_error_table       => l_error_tbl
     ,x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Populate_Loc_Bucket_Range_Tbl (
  	 p_bis_bucket_rec => l_bis_bucket_rec
  	,x_bucket_ranges_tbl => l_bucket_ranges_tbl
    ,x_return_status  => x_return_status
    ,x_error_tbl      => x_error_tbl
  );

  --dbms_output.put_line( 'x_return_status(Pop) is ' || x_return_status);

  Validate_From_To (
     p_bucket_ranges_tbl  => l_bucket_ranges_tbl
    ,x_return_status  => x_return_status
    ,x_error_tbl      => x_error_tbl
  );

  --dbms_output.put_line( 'x_return_status(From-To) is ' || x_return_status);

  Validate_Bucket_Overlapping (
     p_overlapping   => l_bis_bucket_rec.overlapping
    ,p_bucket_ranges_tbl  => l_bucket_ranges_tbl
    ,x_return_status  => x_return_status
    ,x_error_tbl      => x_error_tbl
  );

  --dbms_output.put_line( 'x_return_status(Overlapping) is ' || x_return_status);

  Validate_Bucket_Discontinuous (
     p_discontinuous   => l_bis_bucket_rec.discontinuous
    ,p_bucket_ranges_tbl  => l_bucket_ranges_tbl
    ,x_return_status  => x_return_status
    ,x_error_tbl      => x_error_tbl
  );

  --dbms_output.put_line( 'x_return_status(Disc) is ' || x_return_status);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    --dbms_output.put_line( 'x_return_status (Not wrapper) is ' || x_return_status);
    RAISE FND_API.G_EXC_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Validate_Bucket_Common;
--=============================================================================


PROCEDURE ADD_LANGUAGE
IS
BEGIN
  DELETE FROM BIS_BUCKET_TL T
  WHERE NOT EXISTS
    (SELECT NULL
    FROM BIS_BUCKET B
    WHERE B.BUCKET_ID = T.BUCKET_ID
    );

  UPDATE BIS_BUCKET_TL T SET (
      NAME,
      RANGE1_NAME,
      RANGE2_NAME,
      RANGE3_NAME,
      RANGE4_NAME,
      RANGE5_NAME,
      RANGE6_NAME,
      RANGE7_NAME,
      RANGE8_NAME,
      RANGE9_NAME,
      RANGE10_NAME,
      DESCRIPTION
    ) = (SELECT
      B.NAME,
      B.RANGE1_NAME,
      B.RANGE2_NAME,
      B.RANGE3_NAME,
      B.RANGE4_NAME,
      B.RANGE5_NAME,
      B.RANGE6_NAME,
      B.RANGE7_NAME,
      B.RANGE8_NAME,
      B.RANGE9_NAME,
      B.RANGE10_NAME,
      B.DESCRIPTION
    FROM BIS_BUCKET_TL B
    WHERE B.BUCKET_ID = T.BUCKET_ID
    AND B.LANGUAGE = T.SOURCE_LANG)
  WHERE (
      T.BUCKET_ID,
      T.LANGUAGE
  ) IN (SELECT
      SUBT.BUCKET_ID,
      SUBT.LANGUAGE
    FROM BIS_BUCKET_TL SUBB, BIS_BUCKET_TL SUBT
    WHERE SUBB.BUCKET_ID = SUBT.BUCKET_ID
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND (SUBB.NAME <> SUBT.NAME
      OR SUBB.RANGE1_NAME <> SUBT.RANGE1_NAME
      OR (SUBB.RANGE1_NAME IS NULL AND SUBT.RANGE1_NAME IS NOT NULL)
      OR (SUBB.RANGE1_NAME IS NOT NULL AND SUBT.RANGE1_NAME IS NULL)
      OR SUBB.RANGE2_NAME <> SUBT.RANGE2_NAME
      OR (SUBB.RANGE2_NAME IS NULL AND SUBT.RANGE2_NAME IS NOT NULL)
      OR (SUBB.RANGE2_NAME IS NOT NULL AND SUBT.RANGE2_NAME IS NULL)
      OR SUBB.RANGE3_NAME <> SUBT.RANGE3_NAME
      OR (SUBB.RANGE3_NAME IS NULL AND SUBT.RANGE3_NAME IS NOT NULL)
      OR (SUBB.RANGE3_NAME IS NOT NULL AND SUBT.RANGE3_NAME IS NULL)
      OR SUBB.RANGE4_NAME <> SUBT.RANGE4_NAME
      OR (SUBB.RANGE4_NAME IS NULL AND SUBT.RANGE4_NAME IS NOT NULL)
      OR (SUBB.RANGE4_NAME IS NOT NULL AND SUBT.RANGE4_NAME IS NULL)
      OR SUBB.RANGE5_NAME <> SUBT.RANGE5_NAME
      OR (SUBB.RANGE5_NAME IS NULL AND SUBT.RANGE5_NAME IS NOT NULL)
      OR (SUBB.RANGE5_NAME IS NOT NULL AND SUBT.RANGE5_NAME IS NULL)
      OR SUBB.RANGE6_NAME <> SUBT.RANGE6_NAME
      OR (SUBB.RANGE6_NAME IS NULL AND SUBT.RANGE6_NAME IS NOT NULL)
      OR (SUBB.RANGE6_NAME IS NOT NULL AND SUBT.RANGE6_NAME IS NULL)
      OR SUBB.RANGE7_NAME <> SUBT.RANGE7_NAME
      OR (SUBB.RANGE7_NAME IS NULL AND SUBT.RANGE7_NAME IS NOT NULL)
      OR (SUBB.RANGE7_NAME IS NOT NULL AND SUBT.RANGE7_NAME IS NULL)
      OR SUBB.RANGE8_NAME <> SUBT.RANGE8_NAME
      OR (SUBB.RANGE8_NAME IS NULL AND SUBT.RANGE8_NAME IS NOT NULL)
      OR (SUBB.RANGE8_NAME IS NOT NULL AND SUBT.RANGE8_NAME IS NULL)
      OR SUBB.RANGE9_NAME <> SUBT.RANGE9_NAME
      OR (SUBB.RANGE9_NAME IS NULL AND SUBT.RANGE9_NAME IS NOT NULL)
      OR (SUBB.RANGE9_NAME IS NOT NULL AND SUBT.RANGE9_NAME IS NULL)
      OR SUBB.RANGE10_NAME <> SUBT.RANGE10_NAME
      OR (SUBB.RANGE10_NAME IS NULL AND SUBT.RANGE10_NAME IS NOT NULL)
      OR (SUBB.RANGE10_NAME IS NOT NULL AND SUBT.RANGE10_NAME IS NULL)
      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
  ));

  INSERT INTO BIS_BUCKET_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    BUCKET_ID,
    NAME,
    RANGE1_NAME,
    RANGE2_NAME,
    RANGE3_NAME,
    RANGE4_NAME,
    RANGE5_NAME,
    RANGE6_NAME,
    RANGE7_NAME,
    RANGE8_NAME,
    RANGE9_NAME,
    RANGE10_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT /*+ ORDERED */
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.BUCKET_ID,
    B.NAME,
    B.RANGE1_NAME,
    B.RANGE2_NAME,
    B.RANGE3_NAME,
    B.RANGE4_NAME,
    B.RANGE5_NAME,
    B.RANGE6_NAME,
    B.RANGE7_NAME,
    B.RANGE8_NAME,
    B.RANGE9_NAME,
    B.RANGE10_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM BIS_BUCKET_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND B.LANGUAGE = userenv('LANG')
  AND NOT EXISTS
    (SELECT NULL
    FROM BIS_BUCKET_TL T
    WHERE T.BUCKET_ID = B.BUCKET_ID
    AND T.LANGUAGE = L.LANGUAGE_CODE);
END ADD_LANGUAGE;


END BIS_BUCKET_PVT;

/
