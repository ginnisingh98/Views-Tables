--------------------------------------------------------
--  DDL for Package Body JTF_RS_RES_AVAILABILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RES_AVAILABILITY_PUB" AS
/* $Header: jtfrspzb.pls 120.2 2005/07/26 20:59:58 repuri ship $ */

  /*****************************************************************************************
   This is a public API that user API will invoke.
   It provides procedures for managing seed data of jtf_rs_res_availability tables
   create, update and delete rows
   Its main procedures are as following:
   Create res_availability
   Update res_availability
   Delete res_availability
   Calls to these procedures will call procedures of jtf_rs_res_availability_pvt
   to do inserts, updates and deletes into tables.
   ******************************************************************************************/

 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_RES_AVAILABILITY_PUB';
  G_NAME             VARCHAR2(240);

  /* Procedure to create table attributes
	based on input values passed by calling routines. */
  PROCEDURE  create_res_availability
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE,
   P_AVAILABLE_FLAG       IN   JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE,
   P_REASON_CODE          IN   JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE  DEFAULT  NULL,
   P_START_DATE           IN   JTF_RS_RES_AVAILABILITY.START_DATE%TYPE   DEFAULT  NULL,
   P_END_DATE             IN   JTF_RS_RES_AVAILABILITY.END_DATE%TYPE     DEFAULT  NULL,
   P_MODE_OF_AVAILABILITY IN   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_AVAILABILITY_ID      OUT NOCOPY  JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE
  )IS

  l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_RES_AVAILABILITY';
  l_api_version           CONSTANT NUMBER	:= 1.0;
  l_object_version_number NUMBER;
  l_availability_id       NUMBER;
  l_resource_id           NUMBER                := p_resource_id;
  l_return_status         VARCHAR2(200);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(200);
  l_num                   NUMBER;

  -- Cursor to check if a valid resource_id is being passed.
  CURSOR c_resource_id_valid (l_resource_id NUMBER) IS
    SELECT 1
    FROM jtf_rs_resource_extns
    WHERE resource_id = l_resource_id;

  BEGIN
     --Standard Start of API SAVEPOINT
     SAVEPOINT CREATE_RES_AVAILABILITY_SP;

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

   --Check if the passed resource_id is valid.
   OPEN c_resource_id_valid (l_resource_id);
   FETCH c_resource_id_valid INTO l_num;
   IF c_resource_id_valid%NOTFOUND THEN
     IF c_resource_id_valid%ISOPEN THEN
       CLOSE c_resource_id_valid;
     END IF;
     fnd_message.set_name ('JTF', 'JTF_RS_RES_ID_INVALID');
     FND_MSG_PUB.add;
     raise fnd_api.g_exc_error;
   END IF;
   IF c_resource_id_valid%ISOPEN THEN
     CLOSE c_resource_id_valid;
   END IF;

                JTF_RS_RES_AVAILABILITY_PVT.CREATE_RES_AVAILABILITY(
                             P_API_VERSION            => l_api_version,
                             P_INIT_MSG_LIST          => p_init_msg_list,
                             P_COMMIT                 => p_commit,
                             P_RESOURCE_ID            => p_resource_id,
                             P_AVAILABLE_FLAG         => p_available_flag,
                             P_REASON_CODE            => p_reason_code,
                             P_START_DATE             => p_start_date,
                             P_END_DATE               => p_end_date,
                             P_MODE_OF_AVAILABILITY   => p_mode_of_availability,
                             P_ATTRIBUTE1             => p_attribute1,
                             P_ATTRIBUTE2             => p_attribute2,
                             P_ATTRIBUTE3             => p_attribute3,
                             P_ATTRIBUTE4             => p_attribute4,
                             P_ATTRIBUTE5             => p_attribute5,
                             P_ATTRIBUTE6             => p_attribute6,
                             P_ATTRIBUTE7             => p_attribute7,
                             P_ATTRIBUTE8             => p_attribute8,
                             P_ATTRIBUTE9             => p_attribute9,
                             P_ATTRIBUTE10            => p_attribute10,
                             P_ATTRIBUTE11            => p_attribute11,
                             P_ATTRIBUTE12            => p_attribute12,
                             P_ATTRIBUTE13            => p_attribute13,
                             P_ATTRIBUTE14            => p_attribute14,
                             P_ATTRIBUTE15            => p_attribute15,
                             P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                             X_RETURN_STATUS          => l_return_status,
                             X_MSG_COUNT              => l_msg_count ,
                             X_MSG_DATA               => l_msg_data,
                             X_AVAILABILITY_ID        => l_availability_id
                          );

			  X_AVAILABILITY_ID := l_availability_id;
			  X_RETURN_STATUS   := l_return_status;
			  X_MSG_COUNT       := l_msg_count;
			  X_MSG_DATA        := l_msg_data;


  --standard commit
  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO CREATE_RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO CREATE_RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO CREATE_RES_AVAILABILITY_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  END  CREATE_RES_AVAILABILITY;


  /* Procedure to update resource availability
	based on input values passed by calling routines. */

  PROCEDURE  update_res_availability
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_AVAILABILITY_ID      IN   JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_AVAILABLE_FLAG       IN   JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_REASON_CODE          IN   JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_START_DATE           IN   JTF_RS_RES_AVAILABILITY.START_DATE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE             IN   JTF_RS_RES_AVAILABILITY.END_DATE%TYPE     DEFAULT  FND_API.G_MISS_DATE,
   P_MODE_OF_AVAILABILITY IN   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  )IS

  l_api_name              CONSTANT VARCHAR2(30)                              := 'UPDATE_RES_AVAILABILITY';
  l_api_version           CONSTANT NUMBER	                             :=  1.0;
  l_object_version_number JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;
  l_resource_id           NUMBER                                             := p_resource_id;
  l_availability_id       NUMBER                                             := p_availability_id;
  l_return_status         VARCHAR2(200);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(200);
  l_num                   NUMBER;

  -- Cursor to check if a valid resource_id is being passed.
  CURSOR c_resource_id_valid (l_resource_id NUMBER) IS
    SELECT 1
    FROM jtf_rs_resource_extns
    WHERE resource_id = l_resource_id;

  -- Cursor to check if a valid availability_id is being passed.
  CURSOR c_availability_id_valid (l_availability_id NUMBER) IS
    SELECT 1
    FROM jtf_rs_res_availability
    WHERE availability_id = l_availability_id;

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT UPDATE_RES_AVAILABILITY_SP;

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

   --Check if the passed availability_id is valid.
   OPEN c_availability_id_valid (l_availability_id);
   FETCH c_availability_id_valid INTO l_num;
   IF c_availability_id_valid%NOTFOUND THEN
     IF c_availability_id_valid%ISOPEN THEN
       CLOSE c_availability_id_valid;
     END IF;
     fnd_message.set_name ('JTF', 'JTF_RS_AVAIL_ID_INVALID');
     FND_MSG_PUB.add;
     raise fnd_api.g_exc_error;
   END IF;
   IF c_availability_id_valid%ISOPEN THEN
     CLOSE c_availability_id_valid;
   END IF;

   --Check if the passed resource_id is valid.
   OPEN c_resource_id_valid (l_resource_id);
   FETCH c_resource_id_valid INTO l_num;
   IF c_resource_id_valid%NOTFOUND THEN
     IF c_resource_id_valid%ISOPEN THEN
       CLOSE c_resource_id_valid;
     END IF;
     fnd_message.set_name ('JTF', 'JTF_RS_RES_ID_INVALID');
     FND_MSG_PUB.add;
     raise fnd_api.g_exc_error;
   END IF;
   IF c_resource_id_valid%ISOPEN THEN
     CLOSE c_resource_id_valid;
   END IF;


		 JTF_RS_RES_AVAILABILITY_PVT.UPDATE_RES_AVAILABILITY(
                               P_API_VERSION            => l_api_version,
                               P_INIT_MSG_LIST          => p_init_msg_list,
                               P_COMMIT                 => p_commit,
                               P_AVAILABILITY_ID        => p_availability_id,
                               P_RESOURCE_ID            => p_resource_id,
                               P_AVAILABLE_FLAG         => p_available_flag,
                               P_REASON_CODE            => p_reason_code,
                               P_START_DATE             => p_start_date,
                               P_END_DATE               => p_end_date,
                               P_MODE_OF_AVAILABILITY   => p_mode_of_availability,
                               P_OBJECT_VERSION_NUM     => l_object_version_number,
                               P_ATTRIBUTE1		=> p_attribute1,
                               P_ATTRIBUTE2		=> P_attribute2,
                               P_ATTRIBUTE3		=> p_attribute3,
                               P_ATTRIBUTE4		=> p_attribute4,
                               P_ATTRIBUTE5		=> p_attribute5,
                               P_ATTRIBUTE6		=> p_attribute6,
                               P_ATTRIBUTE7		=> p_attribute7,
                               P_ATTRIBUTE8		=> p_attribute8,
                               P_ATTRIBUTE9		=> p_attribute9,
                               P_ATTRIBUTE10	        => p_attribute10,
                               P_ATTRIBUTE11	        => p_attribute11,
                               P_ATTRIBUTE12	        => p_attribute12,
                               P_ATTRIBUTE13	        => p_attribute13,
                               P_ATTRIBUTE14	        => p_attribute14,
                               P_ATTRIBUTE15	        => p_attribute15,
                               P_ATTRIBUTE_CATEGORY     => p_attribute_category,
                               X_RETURN_STATUS          => l_return_status,
                               X_MSG_COUNT              => l_msg_count,
                               X_MSG_DATA               => l_msg_data
                              );

			 X_RETURN_STATUS  := l_return_status;
			 X_MSG_COUNT      := l_msg_count;
			 X_MSG_DATA       := l_msg_data;
			 P_OBJECT_VERSION_NUM := l_object_version_number;


  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO UPDATE_RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO UPDATE_RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO UPDATE_RES_AVAILABILITY_SP;
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
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_AVAILABILITY_ID      IN     JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  )IS

  l_api_name           CONSTANT VARCHAR2(30) := 'DELETE_RES_AVAILABILITY';
  l_api_version        CONSTANT NUMBER	     := 1.0;
  l_availability_id    NUMBER                := p_availability_id;
  l_return_status      VARCHAR2(200);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(200);
  l_num                NUMBER;

  -- Cursor to check if a valid availability_id is being passed.
  CURSOR c_availability_id_valid (l_availability_id NUMBER) IS
    SELECT 1
    FROM jtf_rs_res_availability
    WHERE availability_id = l_availability_id;

   BEGIN
      --Standard Start of API SAVEPOINT
     SAVEPOINT DELETE_RES_AVAILABILITY_SP;

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

   --Check if the passed availability_id is valid.
   OPEN c_availability_id_valid (l_availability_id);
   FETCH c_availability_id_valid INTO l_num;
   IF c_availability_id_valid%NOTFOUND THEN
     IF c_availability_id_valid%ISOPEN THEN
       CLOSE c_availability_id_valid;
     END IF;
     fnd_message.set_name ('JTF', 'JTF_RS_AVAIL_ID_INVALID');
     FND_MSG_PUB.add;
     raise fnd_api.g_exc_error;
   END IF;
   IF c_availability_id_valid%ISOPEN THEN
     CLOSE c_availability_id_valid;
   END IF;


    JTF_RS_RES_AVAILABILITY_PVT.DELETE_RES_AVAILABILITY
  (P_API_VERSION         => l_api_version,
   P_INIT_MSG_LIST       => p_init_msg_list,
   P_COMMIT              => p_commit,
   P_AVAILABILITY_ID     => p_availability_id,
   P_OBJECT_VERSION_NUM  => p_object_version_num,
   X_RETURN_STATUS       => l_return_status,
   X_MSG_COUNT           => l_msg_count,
   X_MSG_DATA            => l_msg_data
  );

   X_RETURN_STATUS       := l_return_status;
   X_MSG_COUNT           := l_msg_count;
   X_MSG_DATA            := l_msg_data;

  IF fnd_api.to_boolean (p_commit)
  THEN
     COMMIT WORK;
  END IF;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO DELETE_RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO DELETE_RES_AVAILABILITY_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS
    THEN
      ROLLBACK TO DELETE_RES_AVAILABILITY_SP;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

 END delete_res_availability;

END jtf_rs_res_availability_pub;

/
