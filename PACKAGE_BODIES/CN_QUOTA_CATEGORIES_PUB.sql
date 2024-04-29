--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_CATEGORIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_CATEGORIES_PUB" AS
-- $Header: cnpqcatb.pls 115.10 2003/01/25 00:09:12 fmburu ship $

G_PKG_NAME                CONSTANT VARCHAR2(30) := 'CN_QUOTA_CATEGORIES_PUB';
G_FILE_NAME               CONSTANT VARCHAR2(12) := 'cnpqcatb.pls';

PROCEDURE Create_Quota_Category(
  p_api_version                IN      NUMBER,
  p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_rec                        IN      quota_category_rec_type,
  x_return_status              OUT NOCOPY     VARCHAR2,
  x_msg_count                  OUT NOCOPY     NUMBER,
  x_msg_data                   OUT NOCOPY     VARCHAR2,
  x_quota_category_id          OUT NOCOPY     NUMBER) IS

   l_api_name          CONSTANT VARCHAR2(30) := 'Create_Quota_Category';
   l_api_version         CONSTANT NUMBER       := 1.0;
   l_newrec              CN_QUOTA_CATEGORIES_PKG.quota_categories_rec_type;
   l_count               NUMBER;

   G_LAST_UPDATE_DATE        DATE    := sysdate;
   G_LAST_UPDATED_BY         NUMBER  := fnd_global.user_id;
   G_CREATION_DATE           DATE    := sysdate;
   G_CREATED_BY              NUMBER  := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN       NUMBER  := fnd_global.login_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Create_Quota_Category;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
      (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_newrec.name := p_rec.name;
   l_newrec.description := p_rec.description;
   l_newrec.type := p_rec.type;
   l_newrec.compute_flag := p_rec.compute_flag;
   l_newrec.interval_type_id := p_rec.interval_type_id;
   l_newrec.quota_unit_code := p_rec.quota_unit_code;

   --  make sure that same name is not existing.
   SELECT count(quota_category_id)
  INTO l_count
  FROM cn_quota_categories
    WHERE UPPER(name) = UPPER(l_newrec.name);
   IF l_count > 0 THEN
      FND_MESSAGE.SET_NAME ('CN','CN_QUOTA_CATEGORY_DUP');
      FND_MSG_PUB.Add;
   RAISE FND_API.G_EXC_ERROR;
   END IF;

   cn_quota_categories_pkg.insert_row(l_newrec);
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
    p_data    => x_msg_data,
       p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Quota_Category;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
       p_data    => x_msg_data,
       p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Quota_Category;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Create_Quota_Category;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
   END IF;
   FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
      p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
END Create_Quota_Category;
--

PROCEDURE Update_Quota_Category(
  p_api_version                IN      NUMBER,
  p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_rec                        IN      quota_category_rec_type,
  x_return_status              OUT NOCOPY     VARCHAR2,
  x_msg_count                  OUT NOCOPY     NUMBER,
  x_msg_data                   OUT NOCOPY     VARCHAR2) IS

   l_api_name          CONSTANT VARCHAR2(30) := 'Update_Quota_Category';
   l_api_version         CONSTANT NUMBER       := 1.0;
   l_newrec              CN_QUOTA_CATEGORIES_PKG.quota_categories_rec_type;
   l_count               NUMBER;
   l_old_name            cn_quota_categories.name%type ;

   G_LAST_UPDATE_DATE        DATE    := sysdate;
   G_LAST_UPDATED_BY         NUMBER  := fnd_global.user_id;
   G_LAST_UPDATE_LOGIN       NUMBER  := fnd_global.login_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT   Update_Quota_Category;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
      (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- make sure record to be updated exists.
   SELECT count(quota_category_id)
     INTO l_count
     FROM cn_quota_categories
    WHERE quota_category_id = p_rec.quota_category_id;
   IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_UPDATE_REC');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --  check whether this quota_category_id is already assigned
   --  cn_role_quota_cates table
   SELECT count(quota_category_id)
     INTO l_count
     FROM cn_role_quota_cates
    WHERE quota_category_id = p_rec.quota_category_id;

   IF (l_count > 0) THEN
     SELECT NAME
      INTO l_old_name
     FROM cn_quota_categories
     WHERE quota_category_id = p_rec.quota_category_id;

     FND_MESSAGE.SET_NAME('CN', 'CN_RECORD_EXISTS_ERR');
     FND_MESSAGE.SET_TOKEN('QUOTA_CAT_NAME', l_old_name);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_newrec.quota_category_id := p_rec.quota_category_id;
   l_newrec.name := p_rec.name;
   l_newrec.description := p_rec.description;
   l_newrec.type := p_rec.type;
   l_newrec.compute_flag := p_rec.compute_flag;
   l_newrec.interval_type_id := p_rec.interval_type_id;
   l_newrec.quota_unit_code := p_rec.quota_unit_code;
   l_newrec.object_version_number := p_rec.object_version_number;

   -- make sure the object version number hasn't changed in the meantime
   cn_quota_categories_pkg.lock_update_row(l_newrec);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(
    p_count   => x_msg_count,
  p_data    => x_msg_data,
  p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Update_Quota_Category;
   x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
        p_data    => x_msg_data,
        p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Quota_Category;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Update_Quota_Category;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
    p_count   => x_msg_count,
        p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
END Update_Quota_Category;

PROCEDURE Delete_Quota_Category(
  p_api_version                IN      NUMBER,
  p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_quota_category_id          IN      NUMBER,
  p_object_version_number      IN      NUMBER,
  x_return_status              OUT NOCOPY     VARCHAR2,
  x_msg_count                  OUT NOCOPY     NUMBER,
  x_msg_data                   OUT NOCOPY     VARCHAR2) IS

  l_api_name                   CONSTANT VARCHAR2(30) := 'Delete_Quota_Category';
  l_api_version                CONSTANT NUMBER       := 1.0;
  l_count                      NUMBER;
  qc_name                      CN_QUOTA_CATEGORIES.NAME%TYPE ;
BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT Delete_Quota_Category;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
      (l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- make sure record to be deleted exists.
   SELECT count(quota_category_id)
     INTO l_count
     FROM cn_quota_categories
    WHERE quota_category_id = p_quota_category_id;
   IF (l_count = 0) THEN
      FND_MESSAGE.SET_NAME('CN', 'CN_INVALID_DELETE_REC');
   FND_MSG_PUB.ADD;
   RAISE FND_API.G_EXC_ERROR;
   END IF;
   --  check whether this quota_category_id is already assigned
   --  cn_role_quota_cates table
   SELECT count(quota_category_id)
     INTO l_count
     FROM cn_role_quota_cates
    WHERE quota_category_id = p_quota_category_id;

   IF (l_count > 0) THEN
       SELECT NAME
       INTO qc_name
       FROM CN_QUOTA_CATEGORIES
       WHERE quota_category_id = p_quota_category_id;

       FND_MESSAGE.SET_NAME('CN', 'CN_RECORD_EXISTS_ERR');
       FND_MESSAGE.SET_TOKEN('QUOTA_CAT_NAME', qc_name);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- make sure the object version number hasn't changed in the meantime
   cn_quota_categories_pkg.delete_row(p_quota_category_id);

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_And_Get(
    p_count   => x_msg_count,
  p_data    => x_msg_data,
  p_encoded => FND_API.G_FALSE);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Delete_Quota_Category;
   x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
        p_data    => x_msg_data,
        p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Delete_Quota_Category;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(
        p_count   => x_msg_count,
        p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO Delete_Quota_Category;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
    p_count   => x_msg_count,
        p_data    => x_msg_data,
      p_encoded => FND_API.G_FALSE);
END Delete_Quota_Category;

PROCEDURE get_quota_category_details
  ( p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,

    p_start_record          IN  NUMBER,
    p_increment_count       IN  NUMBER,

    p_search_name           IN  VARCHAR2,
    p_search_type           IN  VARCHAR2,
    p_search_unit           IN  VARCHAR2,

    x_quota_categories_tbl OUT NOCOPY quota_categories_tbl_type,

    x_total_records           OUT NOCOPY NUMBER
    ) IS

       l_api_name CONSTANT VARCHAR2(30) := 'get_quota_category_details';
       l_api_version    CONSTANT NUMBER := 1.0;

       l_counter NUMBER;
       l_quota_description VARCHAR2(30);

       CURSOR c_quota_categories IS
    SELECT cn_cat.quota_CATEGORY_ID,
      cn_cat.name ,
      cn_cat.description ,
      cn_cat.type ,
      Nvl(cn_cat.compute_flag,'N') compute_flag,
      cn_cat.object_version_number,
            cn_cat.interval_type_id,
            cn_cat.quota_unit_code
      FROM cn_quota_categories cn_cat
           WHERE upper(name) like upper(p_search_name)
             AND type = p_search_type
             AND quota_unit_code = p_search_unit
      ORDER BY name;

BEGIN
   --
   -- Standard call to check for call compatibility.
   --
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --
   --  Initialize API return status to success
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --
   l_counter := 0;
   x_total_records := 0;

   FOR quota_categories_rec IN  c_quota_categories LOOP
      x_total_records := x_total_records + 1;
      IF l_counter + 1 BETWEEN p_start_record
  AND (p_start_record + Nvl(p_increment_count,
          9999999999999999999999) - 1) THEN
   x_quota_categories_tbl(l_counter).quota_category_id :=
     quota_categories_rec.quota_category_id;
   x_quota_categories_tbl(l_counter).name :=
     quota_categories_rec.name;
   x_quota_categories_tbl(l_counter).description :=
     quota_categories_rec.description;
   x_quota_categories_tbl(l_counter).type :=
     quota_categories_rec.type;
   x_quota_categories_tbl(l_counter).interval_type_id :=
     quota_categories_rec.interval_type_id;
   x_quota_categories_tbl(l_counter).quota_unit_code :=
     quota_categories_rec.quota_unit_code;
   x_quota_categories_tbl(l_counter).compute_flag :=
     quota_categories_rec.compute_flag;
   x_quota_categories_tbl(l_counter).object_version_number :=
     quota_categories_rec.object_version_number;

   IF quota_categories_rec.quota_category_id = -1000 THEN
      x_quota_categories_tbl(l_counter).name :=
        cn_api.get_lkup_meaning
        (p_lkup_code => quota_categories_rec.name,
         p_lkup_type => 'QUOTA_CATEGORY');
   END IF;

   IF quota_categories_rec.TYPE IS NOT NULL THEN
      x_quota_categories_tbl(l_counter).type_meaning :=
        cn_api.get_lkup_meaning
        (p_lkup_code => quota_categories_rec.TYPE,
         p_lkup_type => 'QUOTA_CATEGORY');
   END IF;

   SELECT meaning INTO x_quota_categories_tbl(l_counter).computed
     FROM fnd_lookups
     WHERE lookup_code = quota_categories_rec.compute_flag
     AND lookup_type = 'YES_NO';

      END IF;
      l_counter := l_counter + 1;
   END LOOP;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data   ,
   p_encoded => FND_API.G_FALSE
   );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
  (
   p_count   =>  x_msg_count ,
   p_data    =>  x_msg_data  ,
   p_encoded => FND_API.G_FALSE
   );
END;

END cn_quota_categories_pub;


/
