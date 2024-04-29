--------------------------------------------------------
--  DDL for Package Body IBE_DSP_SECTION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DSP_SECTION_GRP" AS
/* $Header: IBEGCSCB.pls 120.5 2006/06/30 21:14:16 abhandar noship $ */

  --
  --
  -- Start of Comments
  --
  -- NAME
  --   IBE_DSP_SECTION_GRP
  --
  -- PURPOSE
  --   Private API for saving, retrieving and updating sections.
  --
  -- NOTES
  --   This is a pulicly accessible pacakge.  It should be used by all
  --   sources for saving, retrieving and updating personalized queries
  -- within the personalization framework.
  --

  -- HISTORY
  --   11/28/99           VPALAIYA      Created
  --   12/12/02           SCHAK         Modified for NOCOPY (Bug # 2691704) Changes.
  -- **************************************************************************

G_PKG_NAME  CONSTANT VARCHAR2(30):='IBE_DSP_SECTION_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12):='IBEGCSCB.pls';


-- ****************************************************************************
-- ****************************************************************************
--    TABLE HANDLERS
--      1. insert_row
--      2. update_row
--      3. delete_row
-- ****************************************************************************
-- ****************************************************************************


-- ****************************************************************************
-- insert row into sections
-- ****************************************************************************

--
-- Valid the SQL in p_sql_stmt
--
PROCEDURE Is_SQL_Valid
  (
   p_sql_stmt      IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'Is_SQL_Valid';
  l_cursor   NUMBER;
BEGIN

  l_cursor := DBMS_SQL.open_cursor;
  BEGIN
    DBMS_SQL.parse(l_cursor, p_sql_stmt, DBMS_SQL.NATIVE);
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    DBMS_SQL.close_cursor(l_cursor);
  EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       x_return_status := FND_API.G_RET_STS_ERROR;
       DBMS_SQL.close_cursor(l_cursor);
  END;

END Is_SQL_Valid;

PROCEDURE insert_row
  (
   p_section_id                         IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_access_name                        IN VARCHAR2,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_section_type_code                  IN VARCHAR2,
   p_status_code                        IN VARCHAR2,
   p_display_context_id                 IN NUMBER,
   p_deliverable_id                     IN NUMBER,
   p_available_in_all_sites_flag        IN VARCHAR2,
   p_auto_placement_rule                IN VARCHAR2,
   p_order_by_clause                    IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_display_name                       IN VARCHAR2,
   p_description                        IN VARCHAR2,
   p_long_description                   IN VARCHAR2,
   p_keywords                           IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_section_id                         OUT NOCOPY NUMBER
  )
IS
  l_display_context_id   NUMBER;
  l_deliverable_id       NUMBER;

  CURSOR c IS SELECT rowid FROM ibe_dsp_sections_b
    WHERE section_id = x_section_id;
  CURSOR c2 IS SELECT ibe_dsp_sections_b_s1.nextval FROM dual;

BEGIN

  -- Primary key validation check
  x_section_id := p_section_id;
  IF ((x_section_id IS NULL) OR
      (x_section_id = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO x_section_id;
    CLOSE c2;
  END IF;

  -- insert base
  INSERT INTO ibe_dsp_sections_b
  (
  section_id,
  object_version_number,
  access_name,
  start_date_active,
  end_date_active,
  section_type_code,
  status_code,
  display_context_id,
  deliverable_id,
  available_in_all_sites_flag,
  auto_placement_rule,
  order_by_clause,
  attribute_category,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  creation_date,
  created_by,
  last_update_date,
  last_updated_by,
  last_update_login
  )
  VALUES
  (
  x_section_id,
  p_object_version_number,
  decode(p_access_name, FND_API.G_MISS_CHAR, NULL, p_access_name),
  p_start_date_active,
  decode(p_end_date_active, FND_API.G_MISS_DATE, NULL, p_end_date_active),
  p_section_type_code,
  p_status_code,
  decode(p_display_context_id, FND_API.G_MISS_NUM,NULL,p_display_context_id),
  decode(p_deliverable_id, FND_API.G_MISS_NUM, NULL, p_deliverable_id),
  decode(p_available_in_all_sites_flag, FND_API.G_MISS_CHAR, 'Y', NULL, 'Y',
         p_available_in_all_sites_flag),
  decode(p_auto_placement_rule, FND_API.G_MISS_CHAR, NULL,
         p_auto_placement_rule),
  decode(p_order_by_clause, FND_API.G_MISS_CHAR, NULL, p_order_by_clause),
  decode(p_attribute_category, FND_API.G_MISS_CHAR, NULL,p_attribute_category),
  decode(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
  decode(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
  decode(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
  decode(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
  decode(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
  decode(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
  decode(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
  decode(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
  decode(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
  decode(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
  decode(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
  decode(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
  decode(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
  decode(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
  decode(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
  decode(p_creation_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
         p_creation_date),
  decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
         NULL, FND_GLOBAL.user_id, p_created_by),
  decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate, NULL, sysdate,
         p_last_update_date),
  decode(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
         NULL, FND_GLOBAL.user_id, p_last_updated_by),
  decode(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
         NULL, FND_GLOBAL.login_id, p_last_update_login)
  );

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

  -- insert tl
  INSERT INTO ibe_dsp_sections_tl
  (
  last_update_login,
  display_name,
  description,
  long_description,
  keywords,
  last_updated_by,
  last_update_date,
  creation_date,
  section_id,
  object_version_number,
  created_by,
  language,
  source_lang
  )
  SELECT
    decode(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login),
    p_display_name,
    decode(p_description,FND_API.G_MISS_CHAR, NULL, p_description),
    decode(p_long_description, FND_API.G_MISS_CHAR, NULL, p_long_description),
    decode(p_keywords, FND_API.G_MISS_CHAR, NULL, p_keywords),
    decode(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
           NULL, sysdate, p_last_update_date),
    decode(p_creation_date, FND_API.G_MISS_DATE, sysdate,
           NULL, sysdate, p_creation_date),
    x_section_id,
    p_object_version_number,
    decode(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    L.language_code,
    USERENV('LANG')
    FROM fnd_languages L
    WHERE L.installed_flag IN ('I', 'B')
    AND NOT EXISTS
    (SELECT NULL
    FROM ibe_dsp_sections_tl T
    WHERE T.section_id = x_section_id
    AND T.language = L.language_code);

  OPEN c;
  FETCH c INTO x_rowid;
  IF (c%NOTFOUND)
  THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END insert_row;

-- ****************************************************************************
-- update row into sections
-- ****************************************************************************

PROCEDURE update_row
  (
  p_section_id                          IN NUMBER,
  p_object_version_number               IN NUMBER   := FND_API.G_MISS_NUM,
  p_access_name                         IN VARCHAR2,
  p_start_date_active                   IN DATE,
  p_end_date_active                     IN DATE,
  p_section_type_code                   IN VARCHAR2,
  p_status_code                         IN VARCHAR2,
  p_display_context_id                  IN NUMBER,
  p_deliverable_id                      IN NUMBER,
  p_available_in_all_sites_flag         IN VARCHAR2,
  p_auto_placement_rule                 IN VARCHAR2,
  p_order_by_clause                     IN VARCHAR2,
  p_attribute_category                  IN VARCHAR2,
  p_attribute1                          IN VARCHAR2,
  p_attribute2                          IN VARCHAR2,
  p_attribute3                          IN VARCHAR2,
  p_attribute4                          IN VARCHAR2,
  p_attribute5                          IN VARCHAR2,
  p_attribute6                          IN VARCHAR2,
  p_attribute7                          IN VARCHAR2,
  p_attribute8                          IN VARCHAR2,
  p_attribute9                          IN VARCHAR2,
  p_attribute10                         IN VARCHAR2,
  p_attribute11                         IN VARCHAR2,
  p_attribute12                         IN VARCHAR2,
  p_attribute13                         IN VARCHAR2,
  p_attribute14                         IN VARCHAR2,
  p_attribute15                         IN VARCHAR2,
  p_display_name                        IN VARCHAR2,
  p_description                         IN VARCHAR2,
  p_long_description                    IN VARCHAR2,
  p_keywords                            IN VARCHAR2,
  p_last_update_date                    IN DATE,
  p_last_updated_by                     IN NUMBER,
  p_last_update_login                   IN NUMBER
  )
IS
BEGIN

  -- update base
  UPDATE ibe_dsp_sections_b SET
  object_version_number = object_version_number + 1,
  access_name = decode(p_access_name, FND_API.G_MISS_CHAR,
                       access_name, p_access_name),
  start_date_active = decode(p_start_date_active, FND_API.G_MISS_DATE,
                             start_date_active, p_start_date_active),
  end_date_active = decode(p_end_date_active, FND_API.G_MISS_DATE,
                           end_date_active, p_end_date_active),
  section_type_code = decode(p_section_type_code, FND_API.G_MISS_CHAR,
                             section_type_code, p_section_type_code),
  status_code = decode(p_status_code, FND_API.G_MISS_CHAR,
                       status_code, p_status_code),
  display_context_id = decode(p_display_context_id, FND_API.G_MISS_NUM,
                              display_context_id, p_display_context_id),
  deliverable_id = decode(p_deliverable_id, FND_API.G_MISS_NUM,
                          deliverable_id, p_deliverable_id),
  available_in_all_sites_flag =
    decode(p_available_in_all_sites_flag, FND_API.G_MISS_CHAR,
           available_in_all_sites_flag, p_available_in_all_sites_flag),
  auto_placement_rule = decode(p_auto_placement_rule, FND_API.G_MISS_CHAR,
                               auto_placement_rule, p_auto_placement_rule),
  order_by_clause = decode(p_order_by_clause, FND_API.G_MISS_CHAR,
                           order_by_clause, p_order_by_clause),
  attribute_category = decode(p_attribute_category, FND_API.G_MISS_CHAR,
                              attribute_category, p_attribute_category),
  attribute1 = decode(p_attribute1, FND_API.G_MISS_CHAR,
                      attribute1, p_attribute1),
  attribute2 = decode(p_attribute2, FND_API.G_MISS_CHAR,
                      attribute2, p_attribute2),
  attribute3 = decode(p_attribute3, FND_API.G_MISS_CHAR,
                      attribute3, p_attribute3),
  attribute4 = decode(p_attribute4, FND_API.G_MISS_CHAR,
                      attribute4, p_attribute4),
  attribute5 = decode(p_attribute5, FND_API.G_MISS_CHAR,
                      attribute5, p_attribute5),
  attribute6 = decode(p_attribute6, FND_API.G_MISS_CHAR,
                      attribute6, p_attribute6),
  attribute7 = decode(p_attribute7, FND_API.G_MISS_CHAR,
                      attribute7, p_attribute7),
  attribute8 = decode(p_attribute8, FND_API.G_MISS_CHAR,
                      attribute8, p_attribute8),
  attribute9 = decode(p_attribute9, FND_API.G_MISS_CHAR,
                      attribute9, p_attribute9),
  attribute10 = decode(p_attribute10, FND_API.G_MISS_CHAR,
                      attribute10, p_attribute10),
  attribute11 = decode(p_attribute11, FND_API.G_MISS_CHAR,
                      attribute11, p_attribute11),
  attribute12 = decode(p_attribute12, FND_API.G_MISS_CHAR,
                      attribute12, p_attribute12),
  attribute13 = decode(p_attribute13, FND_API.G_MISS_CHAR,
                      attribute13, p_attribute13),
  attribute14 = decode(p_attribute14, FND_API.G_MISS_CHAR,
                      attribute14, p_attribute14),
  attribute15 = decode(p_attribute15, FND_API.G_MISS_CHAR,
                      attribute15, p_attribute15),
  last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                            NULL, sysdate, p_last_update_date),
  last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                           FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                           p_last_updated_by),
  last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE section_id = p_section_id
    AND object_version_number = decode(p_object_version_number,
                                       FND_API.G_MISS_NUM,
                                       object_version_number,
                                       p_object_version_number);


  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  UPDATE ibe_dsp_sections_tl SET
    object_version_number = object_version_number + 1,
    display_name = decode(p_display_name, FND_API.G_MISS_CHAR,
                          display_name, p_display_name),
    description = decode(p_description, FND_API.G_MISS_CHAR,
                         description, p_description),
    long_description = decode(p_long_description, FND_API.G_MISS_CHAR,
                              long_description, p_long_description),
    keywords = decode(p_keywords, FND_API.G_MISS_CHAR, keywords, p_keywords),
    last_update_date = decode(p_last_update_date, FND_API.G_MISS_DATE, sysdate,
                              NULL, sysdate, p_last_update_date),
    last_updated_by = decode(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
    last_update_login = decode(p_last_update_login, FND_API.G_MISS_NUM,
                               FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                               p_last_update_login),
    source_lang = USERENV('LANG')
    WHERE section_id = p_section_id
    --    AND object_version_number = decode(p_object_version_number,
    --                                 FND_API.G_MISS_NUM,
    --                                 object_version_number,
    --                                 p_object_version_number)
    AND USERENV('LANG') IN (language, source_lang);

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END update_row;

-- ****************************************************************************
-- delete row from sections
-- ****************************************************************************

PROCEDURE delete_row
  (
   p_section_id IN NUMBER
  )
IS
BEGIN

  DELETE FROM ibe_dsp_sections_tl
  WHERE section_id = p_section_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  DELETE FROM ibe_dsp_sections_b
  WHERE section_id = p_section_id;

  IF (sql%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END delete_row;

--
-- To be called from ibemste.lct only
--
PROCEDURE load_row
  (
   p_owner                              IN VARCHAR2,
   p_section_id                         IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_access_name                        IN VARCHAR2,
   p_start_date_active                  IN DATE,
   p_end_date_active                    IN DATE,
   p_section_type_code                  IN VARCHAR2,
   p_status_code                        IN VARCHAR2,
   p_display_context_id                 IN NUMBER,
   p_deliverable_id                     IN NUMBER,
   p_available_in_all_sites_flag        IN VARCHAR2,
   p_auto_placement_rule                IN VARCHAR2,
   p_order_by_clause                    IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_display_name                       IN VARCHAR2,
   p_description                        IN VARCHAR2,
   p_long_description                   IN VARCHAR2,
   p_keywords                           IN VARCHAR2,
   P_LAST_UPDATE_DATE                   IN varchar2,
   P_CUSTOM_MODE                        IN Varchar2
  )
IS
  l_user_id           NUMBER := 0;
  l_rowid             VARCHAR2(256);
  l_section_id        NUMBER;
  l_object_version_number          NUMBER := 1;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db

BEGIN
  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(P_OWNER);
  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
  -- get the value of the db_luby and db_ludate from the database
  select LAST_UPDATED_BY, LAST_UPDATE_DATE
   	into db_luby, db_ludate
  	from ibe_dsp_sections_b
   	where SECTION_ID = p_section_id;

  IF ((p_object_version_number IS NOT NULL) AND
      (p_object_version_number <> FND_API.G_MISS_NUM))
  THEN
    l_object_version_number := p_object_version_number;
  END IF;


    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, P_CUSTOM_MODE)) then
     update_row
      (
      p_section_id                          => p_section_id,
      p_object_version_number               => p_object_version_number,
      p_access_name                         => p_access_name,
      p_start_date_active                   => p_start_date_active,
      p_end_date_active                     => p_end_date_active,
      p_section_type_code                   => p_section_type_code,
      p_status_code                         => p_status_code,
      p_display_context_id                  => p_display_context_id,
      p_deliverable_id                      => p_deliverable_id,
      p_available_in_all_sites_flag         => p_available_in_all_sites_flag,
      p_auto_placement_rule                 => p_auto_placement_rule,
      p_order_by_clause                     => p_order_by_clause,
      p_attribute_category                  => p_attribute_category,
      p_attribute1                          => p_attribute1,
      p_attribute2                          => p_attribute2,
      p_attribute3                          => p_attribute3,
      p_attribute4                          => p_attribute4,
      p_attribute5                          => p_attribute5,
      p_attribute6                          => p_attribute6,
      p_attribute7                          => p_attribute7,
      p_attribute8                          => p_attribute8,
      p_attribute9                          => p_attribute9,
      p_attribute10                         => p_attribute10,
      p_attribute11                         => p_attribute11,
      p_attribute12                         => p_attribute12,
      p_attribute13                         => p_attribute13,
      p_attribute14                         => p_attribute14,
      p_attribute15                         => p_attribute15,
      p_display_name                        => p_display_name,
      p_description                         => p_description,
      p_long_description                    => p_long_description,
      p_keywords                            => p_keywords,
      p_last_update_date                    => f_ludate, --sysdate,
      p_last_updated_by                     => f_luby,--l_user_id,
      p_last_update_login                   => 0
      );
  END IF;
  EXCEPTION

     WHEN NO_DATA_FOUND THEN

       insert_row
       (
       p_section_id                         => p_section_id,
       p_object_version_number              => l_object_version_number,
       p_access_name                        => p_access_name,
       p_start_date_active                  => p_start_date_active,
       p_end_date_active                    => p_end_date_active,
       p_section_type_code                  => p_section_type_code,
       p_status_code                        => p_status_code,
       p_display_context_id                 => p_display_context_id,
       p_deliverable_id                     => p_deliverable_id,
       p_available_in_all_sites_flag        => p_available_in_all_sites_flag,
       p_auto_placement_rule                => p_auto_placement_rule,
       p_order_by_clause                    => p_order_by_clause,
       p_attribute_category                 => p_attribute_category,
       p_attribute1                         => p_attribute1,
       p_attribute2                         => p_attribute2,
       p_attribute3                         => p_attribute3,
       p_attribute4                         => p_attribute4,
       p_attribute5                         => p_attribute5,
       p_attribute6                         => p_attribute6,
       p_attribute7                         => p_attribute7,
       p_attribute8                         => p_attribute8,
       p_attribute9                         => p_attribute9,
       p_attribute10                        => p_attribute10,
       p_attribute11                        => p_attribute11,
       p_attribute12                        => p_attribute12,
       p_attribute13                        => p_attribute13,
       p_attribute14                        => p_attribute14,
       p_attribute15                        => p_attribute15,
       p_display_name                       => p_display_name,
       p_description                        => p_description,
       p_long_description                   => p_long_description,
       p_keywords                           => p_keywords,
       p_creation_date                      => f_ludate, --sysdate,
       p_created_by                         => f_luby,--l_user_id,
       p_last_update_date                   => f_ludate, --sysdate,
       p_last_updated_by                    => f_luby,--l_user_id,
       p_last_update_login                  => 0,
       x_rowid                              => l_rowid,
       x_section_id                         => l_section_id
       );


END load_row;


-- ****************************************************************************
--*****************************************************************************
--
--APIs
--
-- 1.Create_Section
-- 2.Update_Section
-- 3.Delete_Section
-- 4.Save_Section
-- 5.Get_Section
-- 6.check_section_duplicates
--
--*****************************************************************************
--*****************************************************************************


--*****************************************************************************
-- PROCEDURE Check_Duplicate_Entry()
--*****************************************************************************

--
-- x_return_status = FND_API.G_RET_STS_SUCCESS, if the section is duplicate
-- x_return_status = FND_API.G_RET_STS_ERROR, if the section is not duplicate
--
-- p_section_id is set to NULL by default for create section
--
--
-- This procedure is used by both when creating and updating sections
-- When creating sections, the p_section_id should be FND_API.G_MISS_NUM, and
-- when updating sections, the p_section_id should be not FND_API.G_MISS_NUM
--
PROCEDURE Check_Duplicate_Entry
  (
   p_init_msg_list         IN VARCHAR2 := FND_API.G_FALSE,
   p_section_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_access_name           IN VARCHAR2,
   p_display_name          IN VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Check_Duplicate_Entry';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_in_section_id     NUMBER;
  l_tmp_section_id    NUMBER;
  l_tmp_sql_str       VARCHAR2(240)         := NULL;

  CURSOR c1(l_c_access_name IN VARCHAR2)
  IS SELECT section_id
    FROM ibe_dsp_sections_b
    WHERE access_name = l_c_access_name;

  -- comment out (bug 2699543, since the code using the cursor is
  -- already commented out)
  --CURSOR c2(l_c_display_name IN VARCHAR2, l_c_tmp_sql_str IN VARCHAR2)
  --IS SELECT section_id
  --  FROM ibe_dsp_sections_tl
  --  WHERE display_name = l_c_display_name || l_c_tmp_sql_str;


BEGIN

  l_in_section_id := p_section_id;

  -- To prevent comparison condition disasters with NULL
  IF(l_in_section_id IS NULL) THEN
    -- l_in_section_id will be NULL only if Creating Section
    l_in_section_id := FND_API.G_MISS_NUM;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to error, i.e, its not duplicate
  x_return_status := FND_API.G_RET_STS_ERROR;

  -- Check duplicate access_name
  IF ((p_access_name IS NOT NULL) AND
      (p_access_name <> FND_API.G_MISS_CHAR))
  THEN

    OPEN c1(p_access_name);
    FETCH c1 INTO l_tmp_section_id;
    IF (c1%FOUND) THEN

      CLOSE c1;
      IF (l_in_section_id = FND_API.G_MISS_NUM) THEN
        -- For Create Section
        IF (l_tmp_section_id IS NOT NULL) THEN
          -- found duplicate
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        -- For Update Section
        IF (l_tmp_section_id <> l_in_section_id) THEN
          -- found duplicate
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    ELSE
      -- not duplicate
      -- do nothing
      CLOSE c1;
    END IF;

  END IF;

  -- Check duplicate display_name
  -- Commented out as we can have sections with duplicate section names
--  IF ((p_display_name IS NOT NULL) AND
--      (p_display_name <> FND_API.G_MISS_CHAR))
--  THEN
--
--    -- If Update Section, add the following string to WHERE clause
--    IF(l_in_section_id <> FND_API.G_MISS_NUM) THEN
--      l_tmp_sql_str := ' AND language = USERENV(''LANG''))';
--    END IF;
--
--    OPEN c2(p_display_name, l_tmp_sql_str);
--    FETCH c2 INTO l_tmp_section_id;
--    IF (c2%FOUND) THEN
--
--      CLOSE c2;
--      IF (l_in_section_id = FND_API.G_MISS_NUM) THEN
--        -- For Create Section
--        IF (l_tmp_section_id IS NOT NULL) THEN
--          -- found duplicate
--          RAISE FND_API.G_EXC_ERROR;
--        END IF;
--      ELSE
--        -- For Update Section
--        IF (l_tmp_section_id <> l_in_section_id) THEN
--          -- found duplicate
--          RAISE FND_API.G_EXC_ERROR;
--        END IF;
--      END IF;
--    ELSE
--      -- not duplicate
--      -- do nothing
--      CLOSE c2;
--    END IF;
--
--  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS; -- found duplicate
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Check_Duplicate_Entry;


--*****************************************************************************
-- PROCEDURE Validate_Create()
--*****************************************************************************
-- IF  x_return_status := FND_API.G_RET_STS_ERROR, then invalid
-- IF  x_return_status := FND_API.G_RET_STS_SUCCESS, then valid

PROCEDURE Validate_Create
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_access_name                    IN VARCHAR2,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_section_type_code              IN VARCHAR2,
   p_status_code                    IN VARCHAR2,
   p_display_context_id             IN NUMBER,
   p_deliverable_id                 IN NUMBER,
   p_available_in_all_sites_flag    IN VARCHAR2,
   p_auto_placement_rule            IN VARCHAR2,
   p_order_by_clause                IN VARCHAR2,
   p_display_name                   IN VARCHAR2,
   p_description                    IN VARCHAR2,
   p_long_description               IN VARCHAR2,
   p_keywords                       IN VARCHAR2,
   p_attribute_category             IN VARCHAR2,
   p_attribute1                     IN VARCHAR2,
   p_attribute2                     IN VARCHAR2,
   p_attribute3                     IN VARCHAR2,
   p_attribute4                     IN VARCHAR2,
   p_attribute5                     IN VARCHAR2,
   p_attribute6                     IN VARCHAR2,
   p_attribute7                     IN VARCHAR2,
   p_attribute8                     IN VARCHAR2,
   p_attribute9                     IN VARCHAR2,
   p_attribute10                    IN VARCHAR2,
   p_attribute11                    IN VARCHAR2,
   p_attribute12                    IN VARCHAR2,
   p_attribute13                    IN VARCHAR2,
   p_attribute14                    IN VARCHAR2,
   p_attribute15                    IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name                CONSTANT VARCHAR2(30) := 'Validate_Create';
  l_api_version             CONSTANT NUMBER       := 1.0;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_section_id              NUMBER;
  l_display_context_id      NUMBER;
  l_deliverable_id          NUMBER;
  l_return_status           VARCHAR2(1);
  l_tmp_str                 VARCHAR2(30);

  CURSOR c3(l_c_status_code IN VARCHAR2)
  IS SELECT lookup_code FROM fnd_lookup_values
    WHERE lookup_type = 'IBE_SECTION_STATUS' AND
    lookup_code = l_c_status_code AND
    language = USERENV('LANG');

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Check null values for required fields
  --
  -- display_name
  IF ((p_display_name IS NULL) OR
      (p_display_name = FND_API.G_MISS_CHAR))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_DSP_NAME');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- section_type_code
  IF ((p_section_type_code IS NULL) OR
      (p_section_type_code = FND_API.G_MISS_CHAR))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_SCT_TYPE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- status_code
  IF ((p_status_code IS NULL) OR
      (p_status_code = FND_API.G_MISS_CHAR))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_STATUS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF ((p_start_date_active IS NULL) OR
      (p_start_date_active = FND_API.G_MISS_DATE))
  THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_START_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- non-null field validation
  --
  -- p_available_in_all_sites_flag
  IF ((p_available_in_all_sites_flag IS NOT NULL) AND
      (p_available_in_all_sites_flag <> FND_API.G_MISS_CHAR))
  THEN
    IF(p_available_in_all_sites_flag <> 'Y' AND
       p_available_in_all_sites_flag <> 'N')
    THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_AVL_FLAG');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- p_auto_placement_rule
  IF ((p_auto_placement_rule IS NOT NULL) AND
      (p_auto_placement_rule <> FND_API.G_MISS_CHAR))
  THEN
    Is_SQL_Valid
      (
      p_auto_placement_rule,
      x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_AUTO_PLACE');
      FND_MESSAGE.Set_Token('AUTO_PLACEMENT_RULE', p_auto_placement_rule);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- p_order_by_clause
  IF ((p_order_by_clause IS NOT NULL) AND
      (p_order_by_clause <> FND_API.G_MISS_CHAR))
  THEN
    Is_SQL_Valid
      (
      'SELECT rowid FROM mtl_system_items_vl WHERE rownum < 1 '
      || ' ORDER BY ' || p_order_by_clause,
      x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_ORDER_BY');
      FND_MESSAGE.Set_Token('ORDER_BY_CLAUSE', p_order_by_clause);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- Validate if the section is duplicate
  Check_Duplicate_Entry(p_init_msg_list      => FND_API.G_FALSE,
                        p_section_id         => FND_API.G_MISS_NUM,
                        p_access_name        => p_access_name,
                        p_display_name       => p_display_name,
                        x_return_status      => l_return_status,
                        x_msg_count          => l_msg_count,
                        x_msg_data           => l_msg_data);

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_DUPLICATE_SECT');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;            -- duplicate section
  END IF;

  --
  -- Foreign key integrity constraint check
  --
  -- display context id
  IF ((p_display_context_id IS NOT NULL) AND
      (p_display_context_id <> FND_API.G_MISS_NUM))
  THEN
    BEGIN
      SELECT context_id INTO l_display_context_id FROM ibe_dsp_context_b
        WHERE context_id = p_display_context_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_DSP_CTX');
         FND_MESSAGE.Set_Token('DISPLAY_CONTEXT', p_display_context_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_DSP_CTX');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  -- deliverable id
  IF ((p_deliverable_id IS NOT NULL) AND
      (p_deliverable_id <> FND_API.G_MISS_NUM))
  THEN
    BEGIN
      SELECT item_id INTO l_deliverable_id FROM jtf_amv_items_b
        WHERE item_id = p_deliverable_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_DLVRBL');
         FND_MESSAGE.Set_Token('DELIVERABLE', p_deliverable_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_DLVRBL');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  -- section type code
  -- note that p_section_type_code won't be NULL due to previous checks
  BEGIN
    SELECT lookup_code INTO l_tmp_str FROM fnd_lookup_values
      WHERE lookup_type = 'IBE_SECTION_TYPE' AND
            lookup_code = p_section_type_code AND
            language = USERENV('LANG');
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_TYPE');
       FND_MESSAGE.Set_Token('SECTION_TYPE', p_section_type_code);
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_SCT_TYPE');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  -- status code
  -- note that p_status_code won't be NULL due to previous checks
  OPEN c3(p_status_code);
  FETCH c3 INTO l_tmp_str;
  IF (c3%NOTFOUND) THEN
    CLOSE c3;
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_STATUS');
    FND_MESSAGE.Set_Token('STATUS', p_status_code);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c3;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Validate_Create;


--*****************************************************************************
-- PROCEDURE Validate_Update()
--*****************************************************************************
-- IF  x_return_status := FND_API.G_RET_STS_ERROR, then invalid
-- IF  x_return_status := FND_API.G_RET_STS_SUCCESS, then valid

PROCEDURE Validate_Update
  (
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER,
   p_object_version_number          IN NUMBER,
   p_access_name                    IN VARCHAR2,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE,
   p_section_type_code              IN VARCHAR2,
   p_status_code                    IN VARCHAR2,
   p_display_context_id             IN NUMBER,
   p_deliverable_id                 IN NUMBER,
   p_available_in_all_sites_flag    IN VARCHAR2,
   p_auto_placement_rule            IN VARCHAR2,
   p_order_by_clause                IN VARCHAR2,
   p_display_name                   IN VARCHAR2,
   p_description                    IN VARCHAR2,
   p_long_description               IN VARCHAR2,
   p_keywords                       IN VARCHAR2,
   p_attribute_category             IN VARCHAR2,
   p_attribute1                     IN VARCHAR2,
   p_attribute2                     IN VARCHAR2,
   p_attribute3                     IN VARCHAR2,
   p_attribute4                     IN VARCHAR2,
   p_attribute5                     IN VARCHAR2,
   p_attribute6                     IN VARCHAR2,
   p_attribute7                     IN VARCHAR2,
   p_attribute8                     IN VARCHAR2,
   p_attribute9                     IN VARCHAR2,
   p_attribute10                    IN VARCHAR2,
   p_attribute11                    IN VARCHAR2,
   p_attribute12                    IN VARCHAR2,
   p_attribute13                    IN VARCHAR2,
   p_attribute14                    IN VARCHAR2,
   p_attribute15                    IN VARCHAR2,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Update';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_section_id            NUMBER;
  l_display_context_id    NUMBER;
  l_deliverable_id        NUMBER;
  l_tmp_str               VARCHAR2(30);
  l_return_status         VARCHAR2(1);

  CURSOR c3(l_c_status_code IN VARCHAR2)
  IS SELECT lookup_code FROM fnd_lookup_values
    WHERE lookup_type = 'IBE_SECTION_STATUS' AND
    lookup_code = l_c_status_code AND
    language = USERENV('LANG');

BEGIN

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Check null values for required fields
  --
  -- section_id
  IF (p_section_id IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NULL_SCT_ID');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- display_name
  IF (p_display_name IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NULL_DSP_NAME');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- section_type_code
  IF (p_section_type_code IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NULL_SCT_TYPE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- status_code
  IF (p_status_code IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NULL_STATUS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- start_date_active
  IF (p_start_date_active IS NULL) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NULL_START_DATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- non-null field validation
  IF ((p_available_in_all_sites_flag IS NOT NULL) AND
      (p_available_in_all_sites_flag <> FND_API.G_MISS_CHAR))
  THEN
    IF(p_available_in_all_sites_flag <> 'Y' AND
       p_available_in_all_sites_flag <> 'N')
    THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_AVL_FLAG');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  -- p_auto_placement_rule
  IF ((p_auto_placement_rule IS NOT NULL) AND
      (p_auto_placement_rule <> FND_API.G_MISS_CHAR))
  THEN
    Is_SQL_Valid
      (
      p_auto_placement_rule,
      x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_AUTO_PLACE');
      FND_MESSAGE.Set_Token('AUTO_PLACEMENT_RULE', p_auto_placement_rule);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- p_order_by_clause
  IF ((p_order_by_clause IS NOT NULL) AND
      (p_order_by_clause <> FND_API.G_MISS_CHAR))
  THEN
    Is_SQL_Valid
      (
      'SELECT rowid FROM mtl_system_items_vl WHERE rownum < 1 '
      || ' ORDER BY ' || p_order_by_clause,
      x_return_status
      );

    IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_ORDER_BY');
      FND_MESSAGE.Set_Token('ORDER_BY_CLAUSE', p_order_by_clause);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  -- Validate if the (unique) fields to be updated doesn't already exist
  -- for some other section
  Check_Duplicate_Entry(p_init_msg_list      => FND_API.G_FALSE,
                        p_section_id         => p_section_id,
                        p_access_name        => p_access_name,
                        p_display_name       => p_display_name,
                        x_return_status      => l_return_status,
                        x_msg_count          => l_msg_count,
                        x_msg_data           => l_msg_data);

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_DUPLICATE_SECT');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- duplicate fields
  END IF;

  --
  -- Foreign key integrity constraint check
  --
  -- display context id
  IF ((p_display_context_id IS NOT NULL) AND
      (p_display_context_id <> FND_API.G_MISS_NUM))
  THEN
    BEGIN
      SELECT context_id INTO l_display_context_id FROM ibe_dsp_context_b
        WHERE context_id = p_display_context_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_DSP_CTX');
         FND_MESSAGE.Set_Token('DISPLAY_CONTEXT', p_display_context_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_DSP_CTX');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  -- deliverable id
  IF ((p_deliverable_id IS NOT NULL) AND
      (p_deliverable_id <> FND_API.G_MISS_NUM))
  THEN
    BEGIN
      SELECT item_id INTO l_deliverable_id FROM jtf_amv_items_b
        WHERE item_id = p_deliverable_id;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_DLVRBL');
         FND_MESSAGE.Set_Token('DELIVERABLE', p_deliverable_id);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_DLVRBL');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  -- section type code
  -- note that p_section_type_code won't be NULL due to previous checks
  IF (p_section_type_code <> FND_API.G_MISS_CHAR) THEN
    BEGIN
      SELECT lookup_code INTO l_tmp_str FROM fnd_lookup_values
        WHERE lookup_type = 'IBE_SECTION_TYPE' AND
              lookup_code = p_section_type_code AND
              language = USERENV('LANG');
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_TYPE');
         FND_MESSAGE.Set_Token('SECTION_TYPE', p_section_type_code);
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
         FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
         FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
         FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
         FND_MESSAGE.Set_Token('REASON', SQLERRM);
         FND_MSG_PUB.Add;

         FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_SCT_TYPE');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  END IF;

  -- status code
  -- note that p_status_code won't be NULL due to previous checks
  IF (p_status_code <> FND_API.G_MISS_CHAR) THEN
    OPEN c3(p_status_code);
    FETCH c3 INTO l_tmp_str;
    IF (c3%NOTFOUND) THEN
      CLOSE c3;
      FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_STATUS');
      FND_MESSAGE.Set_Token('STATUS', p_status_code);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c3;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Validate_Update;


-- ****************************************************************************
--*****************************************************************************

PROCEDURE Create_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_access_name                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_start_date_active              IN DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_section_type_code              IN VARCHAR2,
   p_status_code                    IN VARCHAR2,
   p_display_context_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_deliverable_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_available_in_all_sites_flag    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_auto_placement_rule            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_order_by_clause                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_display_name                   IN VARCHAR2,
   p_description                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_long_description               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_keywords                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_section_id                     OUT NOCOPY NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Section';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);

  l_object_version_number  CONSTANT NUMBER       := 1;
  l_rowid                  VARCHAR2(30);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  CREATE_SECTION_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  --  CALL FLOW :
  -- 1. Check if section is valid
  -- 2. Insert row with section data into section table
  --

  --
  -- 1. Check if section is valid
  --
  Validate_Create
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_access_name                    => p_access_name,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_section_type_code              => p_section_type_code,
    p_status_code                    => p_status_code,
    p_display_context_id             => p_display_context_id,
    p_deliverable_id                 => p_deliverable_id,
    p_available_in_all_sites_flag    => p_available_in_all_sites_flag,
    p_auto_placement_rule            => p_auto_placement_rule,
    p_order_by_clause                => p_order_by_clause,
    p_display_name                   => p_display_name,
    p_description                    => p_description,
    p_long_description               => p_long_description,
    p_keywords                       => p_keywords,
    p_attribute_category             => p_attribute_category,
    p_attribute1                     => p_attribute1,
    p_attribute2                     => p_attribute2,
    p_attribute3                     => p_attribute3,
    p_attribute4                     => p_attribute4,
    p_attribute5                     => p_attribute5,
    p_attribute6                     => p_attribute6,
    p_attribute7                     => p_attribute7,
    p_attribute8                     => p_attribute8,
    p_attribute9                     => p_attribute9,
    p_attribute10                    => p_attribute10,
    p_attribute11                    => p_attribute11,
    p_attribute12                    => p_attribute12,
    p_attribute13                    => p_attribute13,
    p_attribute14                    => p_attribute14,
    p_attribute15                    => p_attribute15,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid section
  END IF;

  --
  -- 2. Insert row with query data into query table
  --
  BEGIN
    insert_row
      (
      FND_API.G_MISS_NUM,
      l_object_version_number,
      p_access_name,
      p_start_date_active,
      p_end_date_active,
      p_section_type_code,
      p_status_code,
      p_display_context_id,
      p_deliverable_id,
      p_available_in_all_sites_flag,
      p_auto_placement_rule,
      p_order_by_clause,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_display_name,
      p_description,
      p_long_description,
      p_keywords,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id,
      l_rowid,
      x_section_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INSERT_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INSERT_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  --
  -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_SECTION_GRP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_SECTION_GRP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_SECTION_GRP;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Section;

PROCEDURE Update_Section
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_section_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_object_version_number          IN NUMBER,
   p_access_name                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_start_date_active              IN DATE     := FND_API.G_MISS_DATE,
   p_end_date_active                IN DATE     := FND_API.G_MISS_DATE,
   p_section_type_code              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_status_code                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_display_context_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_deliverable_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_available_in_all_sites_flag    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_auto_placement_rule            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_order_by_clause                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_display_name                   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_description                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_long_description               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_keywords                       IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute1                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'Update_Section';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

  l_section_id        NUMBER;
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_SECTION_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  --  CALL FLOW :
  -- 1. Check if either section_id or access_name is specified
  -- 2. Update row with section data into section table

  -- 1. Check if either section_id or access_name is specified
  IF ((p_section_id IS NOT NULL) AND
      (p_section_id <> FND_API.G_MISS_NUM))
  THEN
    l_section_id := p_section_id; -- section_id specified, continue
  ELSIF ((p_access_name IS NOT NULL) AND
         (p_access_name <> FND_API.G_MISS_CHAR))
  THEN
    -- If access_name specified and section_id is not specified, then
    -- query for section id
      BEGIN
        SELECT section_id INTO l_section_id FROM ibe_dsp_sections_b
          WHERE access_name = p_access_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ACSS_NAME');
           FND_MESSAGE.Set_Token('ACCESS_NAME', p_access_name);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         WHEN OTHERS THEN
           FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
           FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
           FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
           FND_MESSAGE.Set_Token('REASON', SQLERRM);
           FND_MSG_PUB.Add;

           FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_GET_SCT_ACSS_NAME');
           FND_MESSAGE.Set_Token('ACCESS_NAME', p_access_name);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
  ELSE
    -- neither section_id nor access_name is specified
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_ID_OR_ACSS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;


  --
  -- 1. Validate the input data
  --
  Validate_Update
    (
    p_init_msg_list                  => FND_API.G_FALSE,
    p_validation_level               => p_validation_level,
    p_section_id                     => l_section_id,
    p_object_version_number          => p_object_version_number,
    p_access_name                    => p_access_name,
    p_start_date_active              => p_start_date_active,
    p_end_date_active                => p_end_date_active,
    p_section_type_code              => p_section_type_code,
    p_status_code                    => p_status_code,
    p_display_context_id             => p_display_context_id,
    p_deliverable_id                 => p_deliverable_id,
    p_available_in_all_sites_flag    => p_available_in_all_sites_flag,
    p_auto_placement_rule            => p_auto_placement_rule,
    p_order_by_clause                => p_order_by_clause,
    p_attribute_category             => p_attribute_category,
    p_attribute1                     => p_attribute1,
    p_attribute2                     => p_attribute2,
    p_attribute3                     => p_attribute3,
    p_attribute4                     => p_attribute4,
    p_attribute5                     => p_attribute5,
    p_attribute6                     => p_attribute6,
    p_attribute7                     => p_attribute7,
    p_attribute8                     => p_attribute8,
    p_attribute9                     => p_attribute9,
    p_attribute10                    => p_attribute10,
    p_attribute11                    => p_attribute11,
    p_attribute12                    => p_attribute12,
    p_attribute13                    => p_attribute13,
    p_attribute14                    => p_attribute14,
    p_attribute15                    => p_attribute15,
    p_display_name                   => p_display_name,
    p_description                    => p_description,
    p_long_description               => p_long_description,
    p_keywords                       => p_keywords,
    x_return_status                  => l_return_status,
    x_msg_count                      => l_msg_count,
    x_msg_data                       => l_msg_data
    );

  IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_INVALID_CREATE');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;            -- invalid section
  END IF;

  -- 2. update row with section data into section table
  BEGIN
    update_row
      (
      l_section_id,
      p_object_version_number,
      p_access_name,
      p_start_date_active,
      p_end_date_active,
      p_section_type_code,
      p_status_code,
      p_display_context_id,
      p_deliverable_id,
      p_available_in_all_sites_flag,
      p_auto_placement_rule,
      p_order_by_clause,
      p_attribute_category,
      p_attribute1,
      p_attribute2,
      p_attribute3,
      p_attribute4,
      p_attribute5,
      p_attribute6,
      p_attribute7,
      p_attribute8,
      p_attribute9,
      p_attribute10,
      p_attribute11,
      p_attribute12,
      p_attribute13,
      p_attribute14,
      p_attribute15,
      p_display_name,
      p_description,
      p_long_description,
      p_keywords,
      SYSDATE,
      FND_GLOBAL.user_id,
      FND_GLOBAL.login_id
      );
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_UPDATE_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
     WHEN OTHERS THEN
       FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
       FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
       FND_MESSAGE.Set_Token('REASON', SQLERRM);
       FND_MSG_PUB.Add;

       FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_UPDATE_FAIL');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END;

  --
  -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_SECTION_GRP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_SECTION_GRP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_SECTION_GRP;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Section;

PROCEDURE Delete_Section
  (
   p_api_version         IN NUMBER,
   p_init_msg_list       IN VARCHAR2    := FND_API.G_FALSE,
   p_commit              IN VARCHAR2    := FND_API.G_FALSE,
   p_validation_level    IN NUMBER      := FND_API.G_VALID_LEVEL_FULL,
   p_section_id          IN NUMBER      := FND_API.G_MISS_NUM,
   p_access_name         IN VARCHAR2    := FND_API.G_MISS_CHAR,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_msg_data            OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30)  := 'Delete_Section';
  l_api_version       CONSTANT NUMBER        := 1.0;

  l_section_id        NUMBER;
  l_mini_site_id      NUMBER;

  CURSOR c1(l_c_child_section_id IN NUMBER) IS
    SELECT mini_site_section_section_id FROM ibe_dsp_msite_sct_sects
      WHERE child_section_id = l_c_child_section_id;

  CURSOR c2(l_c_section_id IN NUMBER) IS
    SELECT section_item_id FROM ibe_dsp_section_items
      WHERE section_id = l_c_section_id;

    CURSOR c3(l_c_section_id IN NUMBER) IS
      SELECT msite_id FROM ibe_msites_b
        WHERE msite_root_section_id = l_c_section_id and site_type = 'I';

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT  DELETE_SECTION_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- CALL FLOW
  -- 1. If section_id specified, delete all references for section id
  -- 2. If access_name specified and section_id is not specified, then
  --    query for section id and delete all references

  -- 1. If section_id specified, delete all references for section id
  IF ((p_section_id IS NOT NULL) AND
      (p_section_id <> FND_API.G_MISS_NUM))
  THEN
    l_section_id := p_section_id; -- section_id specified, continue
  ELSIF ((p_access_name IS NOT NULL) AND
         (p_access_name <> FND_API.G_MISS_CHAR))
  THEN
    -- 2. If access_name specified and section_id is not specified, then
    --    query for section id and delete all references
      BEGIN
        SELECT section_id INTO l_section_id FROM ibe_dsp_sections_b
          WHERE access_name = p_access_name;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ACSS_NAME');
           FND_MESSAGE.Set_Token('ACCESS_NAME', p_access_name);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
         WHEN OTHERS THEN
           FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
           FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
           FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
           FND_MESSAGE.Set_Token('REASON', SQLERRM);
           FND_MSG_PUB.Add;

           FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_SCT_ACSS_NAME');
           FND_MESSAGE.Set_Token('ACCESS_NAME', p_access_name);
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;
  ELSE
    -- neither section_id nor access_name is specified, therefore cannot delete
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_NO_ID_OR_ACSS');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Delete references from other tables
  --

  -- Check if this section id is a root section for any mini-site id.
  -- If yes, then cannot delete this section
  OPEN c3(l_section_id);
  FETCH c3 INTO l_mini_site_id;
  IF (c3%FOUND) THEN
    FND_MESSAGE.Set_Name('IBE', 'IBE_DSP_SCT_MSITE_REF');
    FND_MESSAGE.Set_Token('SECTION_ID', l_section_id);
    FND_MESSAGE.Set_Token('MINI_SITE_ID', l_mini_site_id);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- delete from ibe_dsp_msite_sct_sects table
  FOR r1 in c1(l_section_id) LOOP

    IBE_DSP_MSITE_SCT_SECT_PVT.Delete_MSite_Section_Section
      (
      p_api_version                  => p_api_version,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => p_validation_level,
      p_mini_site_section_section_id => r1.mini_site_section_section_id,
      p_mini_site_id                 => FND_API.G_MISS_NUM,
      p_parent_section_id            => FND_API.G_MISS_NUM,
      p_child_section_id             => FND_API.G_MISS_NUM,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

  -- delete for ibe_dsp_section_items table
  FOR r2 in c2(l_section_id) LOOP

    IBE_DSP_SECTION_ITEM_PVT.Delete_Section_Item
      (
      p_api_version                  => p_api_version,
      p_init_msg_list                => FND_API.G_FALSE,
      p_commit                       => FND_API.G_FALSE,
      p_validation_level             => p_validation_level,
      p_call_from_trigger            => FALSE,
      p_section_item_id              => r2.section_item_id,
      p_section_id                   => FND_API.G_MISS_NUM,
      p_inventory_item_id            => FND_API.G_MISS_NUM,
      p_organization_id              => FND_API.G_MISS_NUM,
      x_return_status                => x_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data
      );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END LOOP;

  -- delete for relation ship tables
  IBE_PROD_RELATION_PVT.Section_Deleted
    (
    p_section_id => l_section_id
    );

  -- delete for other tables (Templates, Media, etc)
  IBE_LOGICALCONTENT_GRP.Delete_Section(l_section_id);

  -- delete for ibe_dsp_sections_b and _tl tables
  delete_row(l_section_id);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_SECTION_GRP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_SECTION_GRP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_SECTION_GRP;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Delete_Section;

PROCEDURE Update_Dsp_Context_To_Null
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_display_context_id             IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) :='Update_Dsp_Context_To_Null';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_DSP_CONTEXT_TO_NULL_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  --  CALL FLOW :
  -- 1. Update all rows with display_context_id set to null and
  --    object version number set to +1

  -- 1. update all rows
  UPDATE ibe_dsp_sections_b
    SET display_context_id = NULL,
    object_version_number = object_version_number + 1
    WHERE display_context_id = p_display_context_id;

  --
  -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_DSP_CONTEXT_TO_NULL_GRP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_DSP_CONTEXT_TO_NULL_GRP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_DSP_CONTEXT_TO_NULL_GRP;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Dsp_Context_To_Null;

PROCEDURE Update_Deliverable_To_Null
  (
   p_api_version                    IN NUMBER,
   p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_deliverable_id                 IN NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2,
   x_msg_count                      OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2
  )
IS
  l_api_name          CONSTANT VARCHAR2(30) :='Update_Deliverable_To_Null';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  UPDATE_DELIVERABLE_TO_NULL_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  --  CALL FLOW :
  -- 1. Update all rows with deliverable_id set to null and
  --    object version number set to +1

  -- 1. update all rows
  UPDATE ibe_dsp_sections_b
    SET deliverable_id = NULL,
    object_version_number = object_version_number + 1
    WHERE deliverable_id = p_deliverable_id;

  --
  -- End of main API body.

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_DELIVERABLE_TO_NULL_GRP;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_DELIVERABLE_TO_NULL_GRP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_DELIVERABLE_TO_NULL_GRP;

     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Update_Deliverable_To_Null;

--
-- procedure to add the languages to the section table
-- included from generated code
--
procedure ADD_LANGUAGE
is
begin
  delete from IBE_DSP_SECTIONS_TL T
  where not exists
    (select NULL
    from IBE_DSP_SECTIONS_B B
    where B.SECTION_ID = T.SECTION_ID
    );

  update IBE_DSP_SECTIONS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION,
      LONG_DESCRIPTION,
      KEYWORDS
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION,
      B.LONG_DESCRIPTION,
      B.KEYWORDS
    from IBE_DSP_SECTIONS_TL B
    where B.SECTION_ID = T.SECTION_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SECTION_ID,
      T.LANGUAGE
  ) in (select
      SUBT.SECTION_ID,
      SUBT.LANGUAGE
    from IBE_DSP_SECTIONS_TL SUBB, IBE_DSP_SECTIONS_TL SUBT
    where SUBB.SECTION_ID = SUBT.SECTION_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.LONG_DESCRIPTION <> SUBT.LONG_DESCRIPTION
      or (SUBB.LONG_DESCRIPTION is null and SUBT.LONG_DESCRIPTION is not null)
      or (SUBB.LONG_DESCRIPTION is not null and SUBT.LONG_DESCRIPTION is null)
      or SUBB.KEYWORDS <> SUBT.KEYWORDS
      or (SUBB.KEYWORDS is null and SUBT.KEYWORDS is not null)
      or (SUBB.KEYWORDS is not null and SUBT.KEYWORDS is null)
  ));

  insert into IBE_DSP_SECTIONS_TL (
    SECTION_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    DISPLAY_NAME,
    DESCRIPTION,
    LONG_DESCRIPTION,
    KEYWORDS,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SECTION_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.LONG_DESCRIPTION,
    B.KEYWORDS,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IBE_DSP_SECTIONS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IBE_DSP_SECTIONS_TL T
    where T.SECTION_ID = B.SECTION_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE translate_row
  (
   p_section_id                         IN NUMBER,
   p_display_name                       IN VARCHAR2,
   p_description                        IN VARCHAR2,
   p_long_description                   IN VARCHAR2,
   p_keywords                           IN VARCHAR2,
   x_owner                              IN VARCHAR2,
   P_LAST_UPDATE_DATE                   IN varchar2,
   P_CUSTOM_MODE                        IN Varchar2
  )
IS
 f_luby    number;  -- entity owner in file
 f_ludate  date;    -- entity update date in file
 db_luby   number;  -- entity owner in db
 db_ludate date;    -- entity update date in db

BEGIN
  f_luby := fnd_load_util.owner_id(x_owner);
  f_ludate := nvl(to_date(P_LAST_UPDATE_DATE, 'YYYY/MM/DD'), sysdate);
  select LAST_UPDATED_BY, LAST_UPDATE_DATE
   	into db_luby, db_ludate
  	from ibe_dsp_sections_tl
   	where SECTION_ID = p_section_id
	and language=userenv('LANG'); -- bug #5089259

  IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, P_CUSTOM_MODE)) then
   UPDATE ibe_dsp_sections_tl SET
    section_id = p_section_id,
    display_name = p_display_name,
    description = p_description,
    long_description = p_long_description,
    keywords = p_keywords,
    last_update_date = f_ludate,--sysdate,
    last_updated_by = f_luby, --decode(X_OWNER, 'SEED', 1, 0),
    last_update_login = 0,
    source_lang = userenv('LANG')
    WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
    section_id = p_section_id;
  END IF;

END translate_row;

PROCEDURE LOAD_SEED_ROW
  (
			P_SECTION_ID    	IN NUMBER,
			P_DISPLAY_NAME  	IN VARCHAR2,
			P_DESCRIPTION   	IN VARCHAR2,
			P_LONG_DESCRIPTION 	IN VARCHAR2,
			P_KEYWORDS   		IN VARCHAR2,
			P_OWNER      		IN VARCHAR2,
			P_OBJECT_VERSION_NUMBER 	IN NUMBER   := FND_API.G_MISS_NUM,
			P_ACCESS_NAME 			IN VARCHAR2,
			P_START_DATE_ACTIVE 	IN VARCHAR2,--IN DATE,
			P_END_DATE_ACTIVE 	IN VARCHAR2,--	IN DATE,
			P_SECTION_TYPE_CODE 	IN VARCHAR2,
			P_STATUS_CODE			IN VARCHAR2,
			P_DISPLAY_CONTEXT_ID 	IN NUMBER,
			P_DELIVERABLE_ID 		IN NUMBER,
			P_AVAILABLE_IN_ALL_SITES_FLAG 	IN VARCHAR2,
			P_AUTO_PLACEMENT_RULE 	IN VARCHAR2,
			P_ORDER_BY_CLAUSE 		IN VARCHAR2,
			P_ATTRIBUTE_CATEGORY 	IN VARCHAR2,
			P_ATTRIBUTE1  			IN VARCHAR2,
			P_ATTRIBUTE2  			IN VARCHAR2,
			P_ATTRIBUTE3  			IN VARCHAR2,
			P_ATTRIBUTE4  			IN VARCHAR2,
			P_ATTRIBUTE5  			IN VARCHAR2,
			P_ATTRIBUTE6  			IN VARCHAR2,
			P_ATTRIBUTE7  			IN VARCHAR2,
			P_ATTRIBUTE8  			IN VARCHAR2,
       		P_ATTRIBUTE9  			IN VARCHAR2,
			P_ATTRIBUTE10 			IN VARCHAR2,
			P_ATTRIBUTE11 			IN VARCHAR2,
			P_ATTRIBUTE12 			IN VARCHAR2,
			P_ATTRIBUTE13 			IN VARCHAR2,
			P_ATTRIBUTE14 			IN VARCHAR2,
			P_ATTRIBUTE15 			IN VARCHAR2,
			P_LAST_UPDATE_DATE		IN VARCHAR2,
            P_CUSTOM_MODE           IN VARCHAR2,
   			P_UPLOAD_MODE           IN VARCHAR2
  )
IS
BEGIN
		IF (P_UPLOAD_MODE = 'NLS') then
		   TRANSLATE_ROW(
					P_SECTION_ID,
 					P_DISPLAY_NAME,
 					P_DESCRIPTION,
					P_LONG_DESCRIPTION,
					P_KEYWORDS,
 					p_OWNER,
 					P_LAST_UPDATE_DATE,
 					P_CUSTOM_MODE
					);
		ELSE
			LOAD_ROW(
					P_OWNER,
					P_SECTION_ID,
					P_OBJECT_VERSION_NUMBER,
					P_ACCESS_NAME,
					to_date(P_START_DATE_ACTIVE,'YYYY/MM/DD'),
  					to_date(P_END_DATE_ACTIVE,'YYYY/MM/DD'),
					P_SECTION_TYPE_CODE,
					P_STATUS_CODE,
					P_DISPLAY_CONTEXT_ID,
					P_DELIVERABLE_ID,
					P_AVAILABLE_IN_ALL_SITES_FLAG,
					P_AUTO_PLACEMENT_RULE,
					P_ORDER_BY_CLAUSE,
					P_ATTRIBUTE_CATEGORY,
					P_ATTRIBUTE1,
					P_ATTRIBUTE2,
					P_ATTRIBUTE3,
					P_ATTRIBUTE4,
					P_ATTRIBUTE5,
					P_ATTRIBUTE6,
					P_ATTRIBUTE7,
					P_ATTRIBUTE8,
               		P_ATTRIBUTE9,
					P_ATTRIBUTE10,
					P_ATTRIBUTE11,
					P_ATTRIBUTE12,
					P_ATTRIBUTE13,
					P_ATTRIBUTE14,
					P_ATTRIBUTE15,
					P_DISPLAY_NAME,
					P_DESCRIPTION,
					P_LONG_DESCRIPTION,
					P_KEYWORDS,
                    P_LAST_UPDATE_DATE,
                    P_CUSTOM_MODE);

		End IF;

END LOAD_SEED_ROW;



END IBE_DSP_SECTION_GRP;

/
