--------------------------------------------------------
--  DDL for Package Body JTF_RS_TABLE_ATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TABLE_ATTRIBUTES_PVT" AS
/* $Header: jtfrsvwb.pls 120.0 2005/05/11 08:23:21 appldev ship $ */

  /*****************************************************************************************
   Its main procedures are as following:
   Create table attributes
   Update table attributes
   Delete table attributes
   Calls to these procedures will invoke procedures from jtf_rs_table_attributes_pub
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/
 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TABLE_ATTRIBUTES_PVT';
  G_NAME             VARCHAR2(240);

  /* Procedure to create table attributes
	based on input values passed by calling routines. */
  PROCEDURE  create_table_attribute
    (P_API_VERSION          IN   NUMBER,
     P_INIT_MSG_LIST        IN   VARCHAR2,
     P_COMMIT               IN   VARCHAR2,
     P_ATTRIBUTE_NAME       IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE,
     P_ATTRIBUTE_ACCESS_LEVEL IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE,
     P_ATTRIBUTE1           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE,
     P_ATTRIBUTE2           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE,
     P_ATTRIBUTE3           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE,
     P_ATTRIBUTE4           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE,
     P_ATTRIBUTE5           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE,
     P_ATTRIBUTE6           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE,
     P_ATTRIBUTE7           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE,
     P_ATTRIBUTE8           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE,
     P_ATTRIBUTE9           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE,
     P_ATTRIBUTE10          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE,
     P_ATTRIBUTE11          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE,
     P_ATTRIBUTE12          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE,
     P_ATTRIBUTE13          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE,
     P_ATTRIBUTE14          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE,
     P_ATTRIBUTE15          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE,
     P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE,
     P_USER_ATTRIBUTE_NAME  IN   JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE,
     X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
     X_MSG_COUNT            OUT NOCOPY  NUMBER,
     X_MSG_DATA             OUT NOCOPY  VARCHAR2,
     X_ATTRIBUTE_ID       OUT NOCOPY JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE
  )IS
  l_api_name CONSTANT VARCHAR2(30) := 'CREATE_TABLE_ATTRIBUTE';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_attribute_name       JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE           := p_attribute_name;
  l_attribute_access_level JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE := p_attribute_access_level;
  l_user_attribute_name  JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE     := p_user_attribute_name;
  l_object_version_number  number;

  l_attribute_id         JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE;

  l_go_ahead           VARCHAR2(5);
  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid             VARCHAR2(200);


  CURSOR  attribute_dup_cur(ll_attribute_name JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE)
      IS
   SELECT attribute_access_level,
          attribute_id
     FROM jtf_rs_table_attributes_b
    WHERE attribute_name = ll_attribute_name;

  attribute_dup_rec attribute_dup_cur%rowtype;

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT TABLE_ATTRIBUTE_SP;

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

          -- Check that attribute access levels are valid
          IF l_attribute_access_level IN ('U','NU','UWN','UWA') THEN
             l_go_ahead := 'YES';
          ELSE l_go_ahead := 'NO';
          END IF;

  IF (l_go_ahead = 'YES') THEN
   OPEN attribute_dup_cur(l_attribute_name);
   FETCH attribute_dup_cur into attribute_dup_rec;
	  IF (attribute_dup_cur%NOTFOUND) THEN

	     SELECT  jtf_rs_table_attributes_s.nextval
	       INTO  l_attribute_id
               FROM  dual;

                JTF_RS_TABLE_ATTRIBUTES_PKG.INSERT_ROW(
                            X_ROWID                  => l_rowid,
                            X_ATTRIBUTE_ID           => l_attribute_id,
                            X_ATTRIBUTE_NAME         => l_attribute_name,
                            X_ATTRIBUTE_ACCESS_LEVEL => l_attribute_access_level,
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
                            X_OBJECT_VERSION_NUMBER  => l_object_version_number,
                            X_USER_ATTRIBUTE_NAME    => p_user_attribute_name,
                            X_CREATION_DATE          => sysdate,
                            X_CREATED_BY             => l_user_id,
                            X_LAST_UPDATE_DATE       => sysdate,
                            X_LAST_UPDATED_BY        => l_user_id,
                            X_LAST_UPDATE_LOGIN      => 0);

	      -- return attribute_id
	      x_attribute_id := l_attribute_id;

              ELSIF attribute_dup_cur%FOUND THEN
		    x_attribute_id := attribute_dup_rec.attribute_id;
                    fnd_message.set_name ('JTF', 'JTF_RS_ATT_DUP');
                    FND_MSG_PUB.add;
                    FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
		    raise fnd_api.g_exc_error;
              END IF;
         CLOSE attribute_dup_cur;

      ELSIF (l_go_ahead = 'NO') THEN
             x_attribute_id := null;
             fnd_message.set_name ('JTF', 'JTF_RS_ATT_CREATE_ERR');
             FND_MSG_PUB.add;
             FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
             raise fnd_api.g_exc_error;
      END IF;


  --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO ROLE_RELATE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  create_table_attribute;


  /* Procedure to update the table attributes
	based on input values passed by calling routines. */

  PROCEDURE  update_table_attribute
   (P_API_VERSION        IN     NUMBER,
   P_INIT_MSG_LIST       IN     VARCHAR2,
   P_COMMIT              IN     VARCHAR2,
   P_ATTRIBUTE_ID        IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE,
   P_ATTRIBUTE_NAME      IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE,
   P_ATTRIBUTE_ACCESS_LEVEL IN  JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE,
   P_USER_ATTRIBUTE_NAME IN     JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE,
   P_OBJECT_VERSION_NUM  IN OUT NOCOPY JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY   VARCHAR2
  )IS
  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_TABLE_ATTRIBUTE';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data           VARCHAR2(200);


  L_ATTRIBUTE1		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE;


  CURSOR table_attribute_cur(ll_attribute_id JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE)
      IS
   SELECT attribute_id,
	  attribute_name,
	  attribute_access_level,
	  user_attribute_name,
          object_version_number,
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
          attribute_category
   FROM   jtf_rs_table_attributes_vl
  WHERE   attribute_id = ll_attribute_id;

  table_attribute_rec table_attribute_cur%rowtype;

  l_attribute_name       JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE := p_attribute_name;
  l_attribute_id         JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE := p_attribute_id;
  l_attribute_access_level JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE := p_attribute_access_level;
  l_user_attribute_name  JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE := p_user_attribute_name;

  l_object_version_number JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid             VARCHAR2(200);

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT TABLE_ATTRIBUTE_SP;

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

  OPEN table_attribute_cur(l_attribute_id);
  FETCH  table_attribute_cur INTO table_attribute_rec;

  IF  (table_attribute_cur%found) THEN

    IF (p_attribute_name = FND_API.G_MISS_CHAR)
    THEN
       l_attribute_name := table_attribute_rec.attribute_name;
    ELSE
       l_attribute_name := p_attribute_name;
    END IF;
    IF (p_attribute_access_level = FND_API.G_MISS_CHAR)
    THEN
       l_attribute_access_level := table_attribute_rec.attribute_access_level;
    ELSE
       l_attribute_access_level := p_attribute_access_level;
    END IF;
    IF (p_user_attribute_name = FND_API.G_MISS_CHAR)
    THEN
       l_user_attribute_name := table_attribute_rec.user_attribute_name;
    ELSE
       l_user_attribute_name := p_user_attribute_name;
    END IF;
    IF(p_attribute1 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute1 := table_attribute_rec.attribute1;
    ELSE
      l_attribute1 := p_attribute1;
    END IF;
    IF(p_attribute2 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute2 := table_attribute_rec.attribute2;
    ELSE
      l_attribute2 := p_attribute2;
    END IF;
    IF(p_attribute3 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute3 := table_attribute_rec.attribute3;
    ELSE
      l_attribute3 := p_attribute3;
    END IF;
    IF(p_attribute4 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute4 := table_attribute_rec.attribute4;
    ELSE
      l_attribute4 := p_attribute4;
    END IF;
    IF(p_attribute5 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute5 := table_attribute_rec.attribute5;
    ELSE
      l_attribute5 := p_attribute5;
    END IF;
    IF(p_attribute6 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute6 := table_attribute_rec.attribute6;
    ELSE
      l_attribute6 := p_attribute6;
    END IF;
    IF(p_attribute7 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute7 := table_attribute_rec.attribute7;
    ELSE
      l_attribute7 := p_attribute7;
    END IF;
    IF(p_attribute8 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute8 := table_attribute_rec.attribute8;
    ELSE
      l_attribute8 := p_attribute8;
    END IF;
    IF(p_attribute9 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute9 := table_attribute_rec.attribute9;
    ELSE
      l_attribute9 := p_attribute9;
    END IF;
    IF(p_attribute10 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute10 := table_attribute_rec.attribute10;
    ELSE
      l_attribute10 := p_attribute10;
    END IF;
    IF(p_attribute11 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute11 := table_attribute_rec.attribute11;
    ELSE
      l_attribute11 := p_attribute11;
    END IF;
    IF(p_attribute12 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute12 := table_attribute_rec.attribute12;
    ELSE
      l_attribute12 := p_attribute12;
    END IF;
    IF(p_attribute13 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute13 := table_attribute_rec.attribute13;
    ELSE
      l_attribute13 := p_attribute13;
    END IF;
    IF(p_attribute14 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute14 := table_attribute_rec.attribute14;
    ELSE
      l_attribute14 := p_attribute14;
    END IF;
    IF(p_attribute15 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute15 := table_attribute_rec.attribute15;
    ELSE
      l_attribute15 := p_attribute15;
    END IF;
    IF(p_attribute_category = FND_API.G_MISS_CHAR)
    THEN
     l_attribute_category := table_attribute_rec.attribute_category;
    ELSE
      l_attribute_category := p_attribute_category;
    END IF;

   BEGIN

      jtf_rs_table_attributes_pkg.lock_row(
        x_attribute_id => l_attribute_id,
	x_object_version_number => p_object_version_num
      );

    EXCEPTION

	 WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_error;
	 fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
	 fnd_msg_pub.add;
	 RAISE fnd_api.g_exc_error;

    END;


  l_object_version_number := l_object_version_number +1;

   jtf_rs_table_attributes_pkg.update_row(X_ATTRIBUTE_ID          => l_attribute_id,
                                        X_ATTRIBUTE_NAME          =>  l_attribute_name,
                                        X_ATTRIBUTE_ACCESS_LEVEL  =>  l_attribute_access_level,
                                        X_USER_ATTRIBUTE_NAME     =>  l_user_attribute_name,
                                        X_OBJECT_VERSION_NUMBER   =>  l_object_version_number ,
                                        X_ATTRIBUTE1              =>  l_attribute1,
                                        X_ATTRIBUTE2              =>  l_attribute2,
                                        X_ATTRIBUTE3              =>  l_attribute3,
                                        X_ATTRIBUTE4              =>  l_attribute4,
                                        X_ATTRIBUTE5              =>  l_attribute5,
                                        X_ATTRIBUTE6              =>  l_attribute6,
                                        X_ATTRIBUTE7              =>  l_attribute7,
                                        X_ATTRIBUTE8              =>  l_attribute8,
                                        X_ATTRIBUTE9              =>  l_attribute9,
                                        X_ATTRIBUTE10             =>  l_attribute10,
                                        X_ATTRIBUTE11             =>  l_attribute11,
                                        X_ATTRIBUTE12             =>  l_attribute12,
                                        X_ATTRIBUTE13             =>  l_attribute13,
                                        X_ATTRIBUTE14             =>  l_attribute14,
                                        X_ATTRIBUTE15             =>  l_attribute15,
                                        X_ATTRIBUTE_CATEGORY      =>  l_attribute_category,
                                        X_LAST_UPDATE_DATE        =>  l_date,
                                        X_LAST_UPDATED_BY         =>  l_user_id,
                                        X_LAST_UPDATE_LOGIN       =>  l_login_id )  ;

          P_OBJECT_VERSION_NUM := l_object_version_number;

	  ELSIF  (table_attribute_cur%notfound) THEN
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name ('JTF', 'JTF_RS_INVALID_ID');
               FND_MSG_PUB.add;
               RAISE fnd_api.g_exc_error;

          END IF;

      CLOSE table_attribute_cur;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END  update_table_attribute;


  /* Procedure to delete the table attributes. */

  PROCEDURE  delete_table_attribute
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2,
   P_COMMIT               IN     VARCHAR2,
   P_ATTRIBUTE_ID         IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2
  )IS


  CURSOR  chk_att_exist_cur(ll_attribute_id  JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE)
      IS
   SELECT attribute_name
     FROM jtf_rs_table_attributes_b
    WHERE attribute_id = ll_attribute_id;

  chk_att_exist_rec chk_att_exist_cur%rowtype;

  l_attribute_id  JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE := p_attribute_id;

  l_api_name CONSTANT VARCHAR2(30) := 'DELETE_TABLE_ATTRIBUTE';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;


  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data               VARCHAR2(200);

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT TABLE_ATTRIBUTE_SP;

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

  OPEN chk_att_exist_cur(l_attribute_id);
  FETCH chk_att_exist_cur INTO chk_att_exist_rec;
  IF (chk_att_exist_cur%FOUND)
  THEN

        JTF_RS_TABLE_ATTRIBUTES_PKG.DELETE_ROW(
                       X_ATTRIBUTE_ID  =>  l_attribute_id);

  ELSIF  (chk_att_exist_cur%notfound) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_INVALID_ID');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

  END IF;

  CLOSE chk_att_exist_cur;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END delete_table_attribute;

END jtf_rs_table_attributes_pvt;

/
