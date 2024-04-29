--------------------------------------------------------
--  DDL for Package Body JTF_RS_TABLE_ATTRIBUTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_TABLE_ATTRIBUTES_PUB" AS
/* $Header: jtfrspwb.pls 120.0 2005/05/11 08:21:27 appldev ship $ */

  /*****************************************************************************************
   Its main procedures are as following:
   Create table attributes
   Update table attributes
   Delete table attributes
   Calls to these procedures will invoke procedures of jtf_rs_table_attributes_pvt
   to do inserts, updates and deletes into tables.
   ******************************************************************************************/
 /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_TABLE_ATTRIBUTES_PUB';
  G_NAME             VARCHAR2(240);

  /* Procedure to create table attributes
	based on input values passed by calling routines. */
  PROCEDURE  create_table_attribute
    (P_API_VERSION          IN   NUMBER,
     P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
     P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
     P_ATTRIBUTE_NAME       IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE,
     P_ATTRIBUTE_ACCESS_LEVEL IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE,
     P_ATTRIBUTE1           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE2           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE3           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE4           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE5           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE6           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE7           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE8           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE9           IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE10          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE11          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE12          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE13          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE14          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE15          IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE   DEFAULT  NULL,
     P_ATTRIBUTE_CATEGORY   IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
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
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

                JTF_RS_TABLE_ATTRIBUTES_PVT.CREATE_TABLE_ATTRIBUTE(
                             P_API_VERSION            => l_api_version,
                             P_INIT_MSG_LIST          => p_init_msg_list,
                             P_COMMIT                 => p_commit,
                             P_ATTRIBUTE_NAME         => l_attribute_name,
                             P_ATTRIBUTE_ACCESS_LEVEL => l_attribute_access_level,
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
                             P_USER_ATTRIBUTE_NAME    => l_user_attribute_name,
                             X_RETURN_STATUS          => l_return_status,
                             X_MSG_COUNT              => l_msg_count ,
                             X_MSG_DATA               => l_msg_data,
                             X_ATTRIBUTE_ID           => l_attribute_id
                          );

			  X_ATTRIBUTE_ID  := l_attribute_id;
			  X_RETURN_STATUS := l_return_status;
			  X_MSG_COUNT     := l_msg_count;
			  X_MSG_DATA      := l_msg_data;


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
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO TABLE_ATTRIBUTE_SP;
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
   P_INIT_MSG_LIST       IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT              IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ATTRIBUTE_ID        IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE,
   P_ATTRIBUTE_NAME      IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_ACCESS_LEVEL IN  JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_USER_ATTRIBUTE_NAME IN     JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUM  IN OUT NOCOPY JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY   VARCHAR2
  )IS
  l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_TABLE_ATTRIBUTE';
  l_api_version CONSTANT NUMBER	   :=  1.0;
  l_bind_data_id            number;

  l_return_code        VARCHAR2(100);
  l_count              NUMBER;
  l_data           VARCHAR2(200);

  l_attribute_name       JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_NAME%TYPE := p_attribute_name;
  l_attribute_id         JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE := p_attribute_id;
  l_attribute_access_level JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ACCESS_LEVEL%TYPE := p_attribute_access_level;
  l_user_attribute_name  JTF_RS_TABLE_ATTRIBUTES_TL.USER_ATTRIBUTE_NAME%TYPE := p_user_attribute_name;

  l_object_version_number JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE := P_OBJECT_VERSION_NUM;

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
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

		 JTF_RS_TABLE_ATTRIBUTES_PVT.UPDATE_TABLE_ATTRIBUTE(
                               P_API_VERSION            => l_api_version,
                               P_INIT_MSG_LIST          => p_init_msg_list,
                               P_COMMIT                 => p_commit,
                               P_ATTRIBUTE_ID           => p_attribute_id,
                               P_ATTRIBUTE_NAME         => p_attribute_name,
                               P_ATTRIBUTE_ACCESS_LEVEL => p_attribute_access_level,
                               P_USER_ATTRIBUTE_NAME    => p_user_attribute_name,
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
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_ATTRIBUTE_ID         IN     JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_TABLE_ATTRIBUTES_B.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  )IS


  l_attribute_id  JTF_RS_TABLE_ATTRIBUTES_B.ATTRIBUTE_ID%TYPE := p_attribute_id;

  l_api_name CONSTANT VARCHAR2(30) := 'DELETE_TABLE_ATTRIBUTE';
  l_api_version CONSTANT NUMBER	 :=1.0;
  l_bind_data_id            number;

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


    JTF_RS_TABLE_ATTRIBUTES_PVT.DELETE_TABLE_ATTRIBUTE
  (P_API_VERSION         => l_api_version,
   P_INIT_MSG_LIST       => p_init_msg_list,
   P_COMMIT              => p_commit,
   P_ATTRIBUTE_ID        => p_attribute_id,
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

END jtf_rs_table_attributes_pub;

/
