--------------------------------------------------------
--  DDL for Package Body JTF_RS_SKILL_LEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_SKILL_LEVELS_PVT" AS
/* $Header: jtfrsesb.pls 120.0 2005/05/11 08:19:57 appldev ship $ */

  /*****************************************************************************************
   Its main procedures are as following:
   Create skill levels
   Update skill levels
   Delete skill levels
   Calls to these procedures will invoke procedures from JTF_RS_SKILL_LEVELS_PUB
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/
 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_SKILL_LEVELS_PVT';
  G_NAME             VARCHAR2(240);

  PROCEDURE chk_dup_skill_level(P_SKILL_LEVEL IN NUMBER,
                                X_SKILL_LEVEL_ID IN OUT NOCOPY NUMBER,
                                X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT OUT NOCOPY NUMBER,
                                X_MSG_DATA OUT NOCOPY VARCHAR2) is
    cursor chk_dup_skill(ll_skill_level jtf_rs_skill_levels_b.skill_level%type,
                         ll_skill_level_id jtf_rs_skill_levels_b.skill_level_id%type)
    is
      select * from
      jtf_rs_skill_levels_b where
      skill_level = ll_skill_level and
      skill_level_id <> ll_skill_level_id;

    skill_levels_rec chk_dup_skill%rowtype;
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    open chk_dup_skill(p_skill_level, x_skill_level_id);
    fetch chk_dup_skill into skill_levels_rec;
    if (chk_dup_skill%NOTFOUND) then
      close chk_dup_skill;
    ELSIF chk_dup_skill%FOUND THEN
        close chk_dup_skill;
	x_return_status := fnd_api.g_ret_sts_error;
        x_skill_level_id := skill_levels_rec.skill_level_id;
        fnd_message.set_name ('JTF', 'JTF_RS_DUP_SKILL_LEVEL');
        FND_MSG_PUB.add;
        FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
	raise fnd_api.g_exc_error;
    END IF;
  END;

  PROCEDURE chk_dup_level_name(P_LEVEL_NAME IN VARCHAR2,
                               X_SKILL_LEVEL_ID IN OUT NOCOPY NUMBER,
                               X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                                X_MSG_COUNT OUT NOCOPY NUMBER,
                                X_MSG_DATA OUT NOCOPY VARCHAR2)
  is
    cursor chk_dup_name
         (ll_level_name jtf_rs_skill_levels_tl.level_name%type,
          ll_skill_level_id jtf_rs_skill_levels_b.skill_level_id%type)
    is
      select * from
      jtf_rs_skill_levels_tl where
      upper(level_name) = upper(ll_level_name) and
      skill_level_id <> ll_skill_level_id;

    levels_vl_rec  chk_dup_name%rowtype;
  BEGIN
     x_return_status := fnd_api.g_ret_sts_success;
     open chk_dup_name(p_level_name, x_skill_level_id);
     fetch chk_dup_name INTO levels_vl_rec;

     if chk_dup_name%NOTFOUND then
        CLOSE chk_dup_name;
     ELSIF chk_dup_name%FOUND THEN
         CLOSE chk_dup_name;
   	 x_return_status := fnd_api.g_ret_sts_error;
	 x_skill_level_id := levels_vl_rec.skill_level_id;
	 fnd_message.set_name ('JTF', 'JTF_RS_DUP_SKILL_LEVEL_NAME');
	 FND_MSG_PUB.add;
	 FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
	 raise fnd_api.g_exc_error;
     END IF;

  END chk_dup_level_name;

/* Procedure to create the skill levels
   based on input values passed by calling routines. */

  PROCEDURE  create_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_SKILL_LEVEL       IN   JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL%TYPE,
   P_LEVEL_NAME          IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_NAME%TYPE,
   P_LEVEL_DESC           IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_DESC%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_SKILL_LEVEL_ID      OUT NOCOPY JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE
  )IS
  l_api_name CONSTANT VARCHAR2(30) := 'CREATE_SKILLS';
  l_api_version CONSTANT NUMBER	   :=1.0;
  l_bind_data_id            number;

  l_object_version_number  number := 1;

  l_skill_level_id      JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid             VARCHAR2(200);

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  BEGIN
   --Standard Start of API SAVEPOINT
   SAVEPOINT SKILL_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);
   x_skill_level_id := -1;

   chk_dup_skill_level(P_SKILL_LEVEL => p_skill_level,
                       X_SKILL_LEVEL_ID => x_skill_level_id,
                       X_RETURN_STATUS => x_return_status,
                       X_MSG_COUNT => x_msg_count,
                       X_MSG_DATA => x_msg_data);
   if (p_level_name is not null) then
        chk_dup_level_name(P_LEVEL_NAME => p_level_name,
                           X_SKILL_LEVEL_ID => X_SKILL_LEVEL_ID,
                       X_RETURN_STATUS => x_return_status,
                       X_MSG_COUNT => x_msg_count,
                       X_MSG_DATA => x_msg_data);
   end if;

   SELECT  jtf_rs_skill_levels_s.nextval
   INTO  l_skill_level_id
   FROM  dual;

   JTF_RS_SKILL_LEVELS_PKG.INSERT_ROW(
                            X_ROWID                  => l_rowid,
                            X_SKILL_LEVEL_ID        => l_skill_level_id,
                            X_SKILL_LEVEL  => p_skill_level,
                            X_LEVEL_NAME   => p_level_name,
                            X_LEVEL_DESC   => p_level_desc,
                            X_OBJECT_VERSION_NUMBER  => l_object_version_number,
                            X_ATTRIBUTE1             => p_attribute1,
                            X_ATTRIBUTE2             => p_attribute2,
                            X_ATTRIBUTE3             => p_attribute3,
                            X_ATTRIBUTE4             => p_attribute4,
                            X_ATTRIBUTE5             => p_attribute5,
                            X_ATTRIBUTE6             => p_attribute6,
                            X_ATTRIBUTE7             => p_attribute7,
                            X_ATTRIBUTE8             => p_attribute8,
                            X_ATTRIBUTE9             => p_attribute9,
                            X_ATTRIBUTE10            => p_attribute10,
                            X_ATTRIBUTE11            => p_attribute11,
                            X_ATTRIBUTE12            => p_attribute12,
                            X_ATTRIBUTE13            => p_attribute13,
                            X_ATTRIBUTE14            => p_attribute14,
                            X_ATTRIBUTE15            => p_attribute15,
                            X_ATTRIBUTE_CATEGORY     => p_attribute_category,
                            X_CREATION_DATE          => sysdate,
                            X_CREATED_BY             => l_user_id,
                            X_LAST_UPDATE_DATE       => sysdate,
                            X_LAST_UPDATED_BY        => l_user_id,
                            X_LAST_UPDATE_LOGIN      => 0);

  x_skill_level_id := l_skill_level_id;
  --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO SKILL_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO SKILL_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO SKILL_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  create_skills;


  /* Procedure to update skill levels
	based on input values passed by calling routines. */

  PROCEDURE  update_skills
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_SKILL_LEVEL_ID      IN   JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE,
   P_SKILL_LEVEL          IN   JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL%TYPE,
   P_LEVEL_NAME       IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_NAME%TYPE,
   P_LEVEL_DESC          IN   JTF_RS_SKILL_LEVELS_TL.LEVEL_DESC%TYPE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_SKILL_LEVELS_B.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_SKILL_LEVELS_B.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY   VARCHAR2
  )IS
  l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_SKILLS';
  l_api_version CONSTANT NUMBER	      := 1.0;
  l_bind_data_id         number;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);


  L_ATTRIBUTE1		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_SKILL_LEVELS_B.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_SKILL_LEVELS_B.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_SKILL_LEVELS_B.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_SKILL_LEVELS_B.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_SKILL_LEVELS_B.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_SKILL_LEVELS_B.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_SKILL_LEVELS_B.ATTRIBUTE_CATEGORY%TYPE;


  CURSOR chk_skill_cur(ll_skill_level_id JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE)
      IS
   SELECT *
   FROM   jtf_rs_skill_levels_vl
  WHERE   skill_level_id = ll_skill_level_id;

  skill_levels_rec chk_skill_cur%rowtype;

  l_skill_level_id        JTF_RS_SKILL_LEVELS_B.skill_level_id%TYPE := p_skill_level_id;
  l_skill_level            JTF_RS_SKILL_LEVELS_B.skill_level%TYPE := p_skill_level;
  l_level_name         JTF_RS_SKILL_LEVELS_TL.level_name%TYPE := p_level_name;
  l_level_desc            JTF_RS_SKILL_LEVELS_TL.level_desc%type := p_level_desc;
  l_object_version_number  JTF_RS_SKILL_LEVELS_B.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);

  l_date     Date;
  l_user_id  Number;
  l_login_id Number;
  x_skill_level_id number;

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT SKILL_LEVELS_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;


   --GET USER ID AND SYSDATE
   l_date     := sysdate;
   l_user_id  := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);

  OPEN chk_skill_cur(l_skill_level_id);
  FETCH  chk_skill_cur INTO skill_levels_rec;

  IF  (chk_skill_cur%found) THEN
    CLOSE chk_skill_cur;


    IF (p_skill_level = FND_API.G_MISS_NUM)
    THEN
       l_skill_level := skill_levels_rec.skill_level;
    ELSE
       chk_dup_skill_level(P_SKILL_LEVEL => p_skill_level,
                           X_SKILL_LEVEL_ID => l_skill_level_id,
                       X_RETURN_STATUS => x_return_status,
                       X_MSG_COUNT => x_msg_count,
                       X_MSG_DATA => x_msg_data);
       l_skill_level := p_skill_level;
    END IF;

    IF (p_level_name = FND_API.G_MISS_CHAR)
    THEN
       l_level_name := skill_levels_rec.level_name;
    ELSE
       chk_dup_level_name(P_LEVEL_NAME => p_level_name,
                          X_SKILL_LEVEL_ID => l_SKILL_LEVEL_ID,
                       X_RETURN_STATUS => x_return_status,
                       X_MSG_COUNT => x_msg_count,
                       X_MSG_DATA => x_msg_data);
       l_level_name := p_level_name;
    END IF;

    IF (p_level_desc = FND_API.G_MISS_CHAR)
    THEN
       l_level_desc := skill_levels_rec.level_desc;
    ELSE
       l_level_desc := p_level_desc;
    END IF;

    IF(p_attribute1 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute1 := skill_levels_rec.attribute1;
    ELSE
      l_attribute1 := p_attribute1;
    END IF;

    IF(p_attribute2 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute2 := skill_levels_rec.attribute2;
    ELSE
      l_attribute2 := p_attribute2;
    END IF;

    IF(p_attribute3 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute3 := skill_levels_rec.attribute3;
    ELSE
      l_attribute3 := p_attribute3;
    END IF;

    IF(p_attribute4 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute4 := skill_levels_rec.attribute4;
    ELSE
      l_attribute4 := p_attribute4;
    END IF;

    IF(p_attribute5 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute5 := skill_levels_rec.attribute5;
    ELSE
      l_attribute5 := p_attribute5;
    END IF;

    IF(p_attribute6 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute6 := skill_levels_rec.attribute6;
    ELSE
      l_attribute6 := p_attribute6;
    END IF;

    IF(p_attribute7 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute7 := skill_levels_rec.attribute7;
    ELSE
      l_attribute7 := p_attribute7;
    END IF;

    IF(p_attribute8 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute8 := skill_levels_rec.attribute8;
    ELSE
      l_attribute8 := p_attribute8;
    END IF;

    IF(p_attribute9 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute9 := skill_levels_rec.attribute9;
    ELSE
      l_attribute9 := p_attribute9;
    END IF;

    IF(p_attribute10 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute10 := skill_levels_rec.attribute10;
    ELSE
      l_attribute10 := p_attribute10;
    END IF;

    IF(p_attribute11 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute11 := skill_levels_rec.attribute11;
    ELSE
      l_attribute11 := p_attribute11;
    END IF;

    IF(p_attribute12 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute12 := skill_levels_rec.attribute12;
    ELSE
      l_attribute12 := p_attribute12;
    END IF;

    IF(p_attribute13 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute13 := skill_levels_rec.attribute13;
    ELSE
      l_attribute13 := p_attribute13;
    END IF;

    IF(p_attribute14 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute14 := skill_levels_rec.attribute14;
    ELSE
      l_attribute14 := p_attribute14;
    END IF;

    IF(p_attribute15 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute15 := skill_levels_rec.attribute15;
    ELSE
      l_attribute15 := p_attribute15;
    END IF;

    IF(p_attribute_category = FND_API.G_MISS_CHAR)
    THEN
     l_attribute_category := skill_levels_rec.attribute_category;
    ELSE
      l_attribute_category := p_attribute_category;
    END IF;


   BEGIN

      jtf_rs_skill_levels_pkg.lock_row(
             X_SKILL_LEVEL_ID => l_skill_level_id,
             X_OBJECT_VERSION_NUMBER => l_object_version_number
      );

    EXCEPTION

	 WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;

    END;


  l_object_version_number := l_object_version_number +1;

   jtf_rs_skill_levels_pkg.update_row(
                            X_SKILL_LEVEL_ID        => l_skill_level_id,
                            X_SKILL_LEVEL         => l_skill_level,
                            X_LEVEL_NAME            => l_level_name,
                            X_LEVEL_DESC             => l_level_desc,
                            X_OBJECT_VERSION_NUMBER  => l_object_version_number,
                            X_ATTRIBUTE1             => l_attribute1,
                            X_ATTRIBUTE2             => l_attribute2,
                            X_ATTRIBUTE3             => l_attribute3,
                            X_ATTRIBUTE4             => l_attribute4,
                            X_ATTRIBUTE5             => l_attribute5,
                            X_ATTRIBUTE6             => l_attribute6,
                            X_ATTRIBUTE7             => l_attribute7,
                            X_ATTRIBUTE8             => l_attribute8,
                            X_ATTRIBUTE9             => l_attribute9,
                            X_ATTRIBUTE10            => l_attribute10,
                            X_ATTRIBUTE11            => l_attribute11,
                            X_ATTRIBUTE12            => l_attribute12,
                            X_ATTRIBUTE13            => l_attribute13,
                            X_ATTRIBUTE14            => l_attribute14,
                            X_ATTRIBUTE15            => l_attribute15,
                            X_ATTRIBUTE_CATEGORY     => l_attribute_category,
                            X_LAST_UPDATE_DATE       => l_date,
                            X_LAST_UPDATED_BY        => l_user_id,
                            X_LAST_UPDATE_LOGIN      => l_login_id);

          P_OBJECT_VERSION_NUM := l_object_version_number;

   ELSIF  (chk_skill_cur%notfound) THEN
      CLOSE chk_skill_cur;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name ('JTF', 'JTF_RS_SKILL_LEVEL_ID_INVALID');
      FND_MSG_PUB.add;
      RAISE fnd_api.g_exc_error;

  END IF;


  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO SKILL_LEVELS_SP;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      x_return_status := fnd_api.g_ret_sts_error;

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO SKILL_LEVELS_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO SKILL_LEVELS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END  update_skills;


  /* Procedure to delete the skill levels */

  PROCEDURE  delete_skills
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2,
   P_COMMIT               IN     VARCHAR2,
   P_SKILL_LEVEL_ID             IN     JTF_RS_SKILL_LEVELS_B.skill_level_id%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_SKILL_LEVELS_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2
  )IS


  CURSOR  chk_skill_exist_cur(ll_skill_level_id  JTF_RS_SKILL_LEVELS_B.skill_level_id%TYPE)
      IS
   SELECT skill_level_id
     FROM JTF_RS_SKILL_LEVELS_B
    WHERE skill_level_id = ll_skill_level_id;

  chk_skill_exist_rec chk_skill_exist_cur%rowtype;

  l_skill_level_id  JTF_RS_SKILL_LEVELS_B.SKILL_LEVEL_ID%TYPE := p_skill_level_id;

  l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_SKILLS';
  l_api_version CONSTANT NUMBER	      := 1.0;
  l_bind_data_id         number;

  l_date     Date;
  l_user_id  Number;
  l_login_id Number;


  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT SKILL_LEVELS_SP;

   x_return_status := fnd_api.g_ret_sts_success;

   --Standard Call to check  API compatibility
   IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

  OPEN chk_skill_exist_cur(l_skill_level_id);
  FETCH chk_skill_exist_cur INTO chk_skill_exist_rec;

  IF (chk_skill_exist_cur%FOUND)
  THEN
    CLOSE chk_skill_exist_cur;

       BEGIN

	  jtf_rs_skill_levels_pkg.lock_row(
		 X_SKILL_LEVEL_ID => l_skill_level_id,
		 X_OBJECT_VERSION_NUMBER => p_object_version_num
	  );

	EXCEPTION

	     WHEN OTHERS THEN
	     x_return_status := fnd_api.g_ret_sts_error;
	     fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	     fnd_msg_pub.add;
	     RAISE fnd_api.g_exc_error;

	END;

        JTF_RS_SKILL_LEVELS_PKG.DELETE_ROW(
                       X_SKILL_LEVEL_ID  =>  l_skill_level_id);

  ELSIF  (chk_skill_exist_cur%notfound) THEN
    CLOSE chk_skill_exist_cur;
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_SKILL_LEVEL_ID_INVALID');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

  END IF;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO SKILL_LEVELS_SP;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO SKILL_LEVELS_SP;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO SKILL_LEVELS_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END delete_skills;

END JTF_RS_SKILL_LEVELS_PVT;

/
