--------------------------------------------------------
--  DDL for Package Body JTF_RS_RES_AVAILABILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RES_AVAILABILITY_PVT" AS
/* $Header: jtfrsvzb.pls 120.2 2005/07/26 21:01:45 repuri ship $ */

  /*****************************************************************************************
   Its main procedures are as following:
   Create resource availability
   Update resource availability
   Delete resource availability
   Calls to these procedures will invoke procedures from JTF_RS_RES_AVAILABILITY_PUB
   to do business validations and to do actual inserts, updates and deletes into tables.
   ******************************************************************************************/
 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_RES_AVAILABILITY_PVT';
  G_NAME             VARCHAR2(240);

/* Procedure to create the resource availability
	based on input values passed by calling routines. */

  PROCEDURE  create_res_availability
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_RESOURCE_ID          IN   JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE,
   P_AVAILABLE_FLAG       IN   JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE,
   P_REASON_CODE          IN   JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE,
   P_START_DATE           IN   JTF_RS_RES_AVAILABILITY.START_DATE%TYPE,
   P_END_DATE             IN   JTF_RS_RES_AVAILABILITY.END_DATE%TYPE,
   P_MODE_OF_AVAILABILITY IN   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_AVAILABILITY_ID      OUT NOCOPY JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE
  )IS

  l_api_name               CONSTANT VARCHAR2(30)                             := 'CREATE_RES_AVAILABILITY';
  l_api_version            CONSTANT NUMBER	                             := 1.0;
  l_resource_id            JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE          := p_resource_id;
  l_mode_of_availability   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE := P_MODE_OF_AVAILABILITY;
  l_object_version_number  NUMBER;
  l_availability_id        JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE;
  l_return_status          VARCHAR2(200);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(200);
  l_rowid                  VARCHAR2(200);
  l_num                    NUMBER;

  -- uncommenting and modifying the cursor and the related code for fixing bug 4309007.
  CURSOR  c_dup_res_avail (l_resource_id IN NUMBER, l_mode_of_availability IN VARCHAR2)
      IS
   SELECT 1
    FROM  JTF_RS_RES_AVAILABILITY
    WHERE resource_id = l_resource_id
    AND   mode_of_availability = l_mode_of_availability;

  l_date  Date;
  l_user_id  Number;
  l_login_id  Number;

  BEGIN
   --Standard Start of API SAVEPOINT
   SAVEPOINT RESOURCE_AVAILABILITY_SP;

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

    OPEN c_dup_res_avail (l_resource_id, l_mode_of_availability);
    FETCH c_dup_res_avail into l_availability_id;
    IF (c_dup_res_avail%NOTFOUND) THEN

      SELECT  jtf_rs_res_availability_s.nextval
      INTO  l_availability_id
      FROM  dual;

      JTF_RS_RES_AVAILABILITY_PKG.INSERT_ROW(
        X_ROWID                  => l_rowid,
        X_AVAILABILITY_ID        => l_availability_id,
        X_RESOURCE_ID            => l_resource_id,
        X_AVAILABLE_FLAG         => P_AVAILABLE_FLAG,
        X_REASON_CODE            => P_REASON_CODE,
        X_START_DATE             => P_START_DATE,
        X_END_DATE               => P_END_DATE,
        X_MODE_OF_AVAILABILITY   => P_MODE_OF_AVAILABILITY,
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

    ELSE
      IF c_dup_res_avail%ISOPEN THEN
        CLOSE c_dup_res_avail;
      END IF;
      fnd_message.set_name ('JTF', 'JTF_RS_DUP_RES_AVAIL');
      FND_MSG_PUB.add;
      raise fnd_api.g_exc_error;
    END IF;
    IF c_dup_res_avail%ISOPEN THEN
      CLOSE c_dup_res_avail;
    END IF;

    -- Return Availability ID
    x_availability_id := l_availability_id;

    --standard commit
    IF fnd_api.to_boolean (p_commit)
    THEN
      COMMIT WORK;
    END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO RESOURCE_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO RESOURCE_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO RESOURCE_AVAILABILITY_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  create_res_availability;


  /* Procedure to update resource availability
	based on input values passed by calling routines. */

  PROCEDURE  update_res_availability
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2,
   P_COMMIT               IN   VARCHAR2,
   P_AVAILABILITY_ID      IN   JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE,
   P_AVAILABLE_FLAG       IN   JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE,
   P_REASON_CODE          IN   JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE,
   P_START_DATE           IN   JTF_RS_RES_AVAILABILITY.START_DATE%TYPE,
   P_END_DATE             IN   JTF_RS_RES_AVAILABILITY.END_DATE%TYPE,
   P_MODE_OF_AVAILABILITY IN   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE,
   P_ATTRIBUTE2		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE,
   P_ATTRIBUTE3		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE,
   P_ATTRIBUTE4		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE,
   P_ATTRIBUTE5		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE,
   P_ATTRIBUTE6		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE,
   P_ATTRIBUTE7		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE,
   P_ATTRIBUTE8		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE,
   P_ATTRIBUTE9		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE,
   P_ATTRIBUTE10	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE,
   P_ATTRIBUTE11	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE,
   P_ATTRIBUTE12	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE,
   P_ATTRIBUTE13	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE,
   P_ATTRIBUTE14	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE,
   P_ATTRIBUTE15	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY   VARCHAR2
  )IS
  l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_RES_AVAILABILITY';
  l_api_version CONSTANT NUMBER	      := 1.0;

  L_ATTRIBUTE1		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE;
  L_ATTRIBUTE2		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE;
  L_ATTRIBUTE3		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE;
  L_ATTRIBUTE4		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE;
  L_ATTRIBUTE5		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE;
  L_ATTRIBUTE6		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE;
  L_ATTRIBUTE7		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE;
  L_ATTRIBUTE8		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE;
  L_ATTRIBUTE9		     JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE;
  L_ATTRIBUTE10	             JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE;
  L_ATTRIBUTE11	             JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE;
  L_ATTRIBUTE12	             JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE;
  L_ATTRIBUTE13	             JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE;
  L_ATTRIBUTE14	             JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE;
  L_ATTRIBUTE15	             JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE;
  L_ATTRIBUTE_CATEGORY	     JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE;


  CURSOR resource_cur(ll_availability_id JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE)
      IS
   SELECT AVAILABILITY_ID,
	  RESOURCE_ID,
	  AVAILABLE_FLAG,
	  REASON_CODE,
	  START_DATE,
	  END_DATE ,
	  MODE_OF_AVAILABILITY,
	  OBJECT_VERSION_NUMBER,
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
	  ATTRIBUTE15,
	  ATTRIBUTE_CATEGORY,
	  CREATED_BY,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN
   FROM   jtf_rs_res_availability
  WHERE   availability_id = ll_availability_id;

  resource_rec resource_cur%rowtype;

  -- Cursor to check duplicates.
  CURSOR c_dup_res_avail (l_resource_id IN NUMBER, l_mode_of_availability IN VARCHAR2) IS
    SELECT 1
    FROM jtf_rs_res_availability
    WHERE resource_id          = l_resource_id
    AND   mode_of_availability = l_mode_of_availability;

  l_availability_id        JTF_RS_RES_AVAILABILITY.availability_ID%TYPE := p_availability_id;
  l_resource_id            JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE := p_resource_id;
  l_available_flag         JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE := p_available_flag;
  l_reason_code            JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE := p_reason_code;
  l_start_date             JTF_RS_RES_AVAILABILITY.START_DATE%TYPE := p_start_date;
  l_end_date               JTF_RS_RES_AVAILABILITY.END_DATE%TYPE := p_end_date;
  l_mode_of_availability   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE := p_mode_of_availability;
  l_object_version_number  JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_rowid              VARCHAR2(200);
  l_num                NUMBER;

  l_date     Date;
  l_user_id  Number;
  l_login_id Number;

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT RES_AVAILABILITY_SP;

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

  OPEN resource_cur(l_availability_id);
  FETCH  resource_cur INTO resource_rec;

  IF  (resource_cur%found) THEN

    IF (p_resource_id = FND_API.G_MISS_NUM)
    THEN
       l_resource_id := resource_rec.resource_id;
    ELSE
       l_resource_id := p_resource_id;
    END IF;

    IF (p_available_flag = FND_API.G_MISS_CHAR)
    THEN
       l_available_flag := resource_rec.available_flag;
    ELSE
       l_available_flag := p_available_flag;
    END IF;

    IF (p_reason_code = FND_API.G_MISS_CHAR)
    THEN
       l_reason_code := resource_rec.reason_code;
    ELSE
       l_reason_code := p_reason_code;
    END IF;

    IF (p_start_date = FND_API.G_MISS_DATE)
    THEN
       l_start_date := resource_rec.start_date;
    ELSE
       l_start_date := p_start_date;
    END IF;

    IF (p_end_date = FND_API.G_MISS_DATE)
    THEN
       l_end_date := resource_rec.end_date;
    ELSE
       l_end_date := p_end_date;
    END IF;

    IF (p_mode_of_availability = FND_API.G_MISS_CHAR)
    THEN
       l_mode_of_availability := resource_rec.mode_of_availability;
    ELSE
       l_mode_of_availability := p_mode_of_availability;
    END IF;

    IF(p_attribute1 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute1 := resource_rec.attribute1;
    ELSE
      l_attribute1 := p_attribute1;
    END IF;

    IF(p_attribute2 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute2 := resource_rec.attribute2;
    ELSE
      l_attribute2 := p_attribute2;
    END IF;

    IF(p_attribute3 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute3 := resource_rec.attribute3;
    ELSE
      l_attribute3 := p_attribute3;
    END IF;

    IF(p_attribute4 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute4 := resource_rec.attribute4;
    ELSE
      l_attribute4 := p_attribute4;
    END IF;

    IF(p_attribute5 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute5 := resource_rec.attribute5;
    ELSE
      l_attribute5 := p_attribute5;
    END IF;

    IF(p_attribute6 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute6 := resource_rec.attribute6;
    ELSE
      l_attribute6 := p_attribute6;
    END IF;

    IF(p_attribute7 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute7 := resource_rec.attribute7;
    ELSE
      l_attribute7 := p_attribute7;
    END IF;

    IF(p_attribute8 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute8 := resource_rec.attribute8;
    ELSE
      l_attribute8 := p_attribute8;
    END IF;

    IF(p_attribute9 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute9 := resource_rec.attribute9;
    ELSE
      l_attribute9 := p_attribute9;
    END IF;

    IF(p_attribute10 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute10 := resource_rec.attribute10;
    ELSE
      l_attribute10 := p_attribute10;
    END IF;

    IF(p_attribute11 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute11 := resource_rec.attribute11;
    ELSE
      l_attribute11 := p_attribute11;
    END IF;

    IF(p_attribute12 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute12 := resource_rec.attribute12;
    ELSE
      l_attribute12 := p_attribute12;
    END IF;

    IF(p_attribute13 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute13 := resource_rec.attribute13;
    ELSE
      l_attribute13 := p_attribute13;
    END IF;

    IF(p_attribute14 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute14 := resource_rec.attribute14;
    ELSE
      l_attribute14 := p_attribute14;
    END IF;

    IF(p_attribute15 = FND_API.G_MISS_CHAR)
    THEN
     l_attribute15 := resource_rec.attribute15;
    ELSE
      l_attribute15 := p_attribute15;
    END IF;

    IF(p_attribute_category = FND_API.G_MISS_CHAR)
    THEN
     l_attribute_category := resource_rec.attribute_category;
    ELSE
      l_attribute_category := p_attribute_category;
    END IF;

    OPEN c_dup_res_avail (l_resource_id, l_mode_of_availability);
    FETCH c_dup_res_avail INTO l_num;
    IF c_dup_res_avail%FOUND THEN
      IF c_dup_res_avail%ISOPEN THEN
        CLOSE c_dup_res_avail;
      END IF;
      fnd_message.set_name ('JTF', 'JTF_RS_DUP_RES_AVAIL');
      FND_MSG_PUB.add;
      raise fnd_api.g_exc_error;
    END IF;
    IF c_dup_res_avail%ISOPEN THEN
      CLOSE c_dup_res_avail;
    END IF;

   BEGIN

      jtf_rs_res_availability_pkg.lock_row(
        x_availability_id => l_availability_id,
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

   jtf_rs_res_availability_pkg.update_row(
                            X_AVAILABILITY_ID        => l_availability_id,
                            X_RESOURCE_ID            => l_resource_id,
                            X_AVAILABLE_FLAG         => l_AVAILABLE_FLAG,
                            X_REASON_CODE            => l_REASON_CODE,
                            X_START_DATE             => l_START_DATE,
                            X_END_DATE               => l_END_DATE,
                            X_MODE_OF_AVAILABILITY   => l_MODE_OF_AVAILABILITY,
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

	  ELSIF  (resource_cur%notfound) THEN
               x_return_status := fnd_api.g_ret_sts_error;
               fnd_message.set_name ('JTF', 'JTF_RS_AVAILABILITY_ID_INVALID');
               FND_MSG_PUB.add;
               RAISE fnd_api.g_exc_error;

          END IF;

      CLOSE resource_cur;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO RES_AVAILABILITY_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END  update_res_availability;


  /* Procedure to delete the resource availability */

  PROCEDURE  delete_res_availability
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2,
   P_COMMIT               IN     VARCHAR2,
   P_AVAILABILITY_ID      IN     JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY   VARCHAR2
  )IS


  CURSOR  chk_res_exist_cur(ll_availability_id  JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE)
      IS
   SELECT resource_id
     FROM JTF_RS_RES_AVAILABILITY
    WHERE availability_id = ll_availability_id;

  chk_res_exist_rec chk_res_exist_cur%rowtype;

  l_availability_id  JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE := p_availability_id;

  l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_RES_AVAILABILITY';
  l_api_version CONSTANT NUMBER	      := 1.0;

  l_date     Date;
  l_user_id  Number;
  l_login_id Number;

  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT RES_AVAILABILITY_SP;

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

  OPEN chk_res_exist_cur(l_availability_id);
  FETCH chk_res_exist_cur INTO chk_res_exist_rec;
  IF (chk_res_exist_cur%FOUND)
  THEN

        JTF_RS_RES_AVAILABILITY_PKG.DELETE_ROW(
                       X_AVAILABILITY_ID  =>  l_availability_id);

  ELSIF  (chk_res_exist_cur%notfound) THEN
          x_return_status := fnd_api.g_ret_sts_error;
          fnd_message.set_name ('JTF', 'JTF_RS_AVAILABILITY_ID_INVALID');
          FND_MSG_PUB.add;
          RAISE fnd_api.g_exc_error;

  END IF;

  CLOSE chk_res_exist_cur;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO RES_AVAILABILITY_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END delete_res_availability;

END JTF_RS_RES_AVAILABILITY_PVT;

/
