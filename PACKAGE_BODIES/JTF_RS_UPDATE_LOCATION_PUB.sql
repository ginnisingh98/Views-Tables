--------------------------------------------------------
--  DDL for Package Body JTF_RS_UPDATE_LOCATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_UPDATE_LOCATION_PUB" AS
/* $Header: jtfrsugb.pls 120.0 2005/05/11 08:22:45 appldev ship $ */
   G_PKG_NAME         VARCHAR2(30) := 'JTF_RS_UPDATE_LOCATION_PUB';

  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_LOCATION                IN   MDSYS.SDO_GEOMETRY  ,
   P_OBJECT_VERSION_NUM      IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  )
  IS
   l_api_version         CONSTANT NUMBER := 1.0;
   l_api_name            CONSTANT VARCHAR2(30) := 'UPDATE_RESOURCE';
   l_date  Date;
   l_user_id  Number;
   l_login_id  Number;

   cursor res_cur
      is
   select resource_id,
          object_version_number
    from  jtf_rs_resource_extns
   where  resource_id = p_resource_id;

   res_rec res_cur%rowtype;

  BEGIN
    SAVEPOINT update_sp;
    IF NOT FND_API.Compatible_API_CALL(L_API_VERSION,P_API_VERSION,L_API_NAME,G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --Initialize the message List   if P_INIT_MSG_LIST is set to TRUE
   IF FND_API.To_boolean(P_INIT_MSG_LIST)
   THEN
      FND_MSG_PUB.Initialize;
   END IF;

   l_date  := sysdate;
   l_user_id := NVL(FND_PROFILE.Value('USER_ID'), -1);
   l_login_id := NVL(FND_PROFILE.Value('LOGIN_ID'), -1);


   if(p_resource_id is null)
   then
      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;

   end if;

   open res_cur;
   fetch res_cur into res_rec;
   if(res_cur%notfound)
   then
      fnd_message.set_name('JTF', 'JTF_RS_RESOURCE_NULL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      close res_cur;
      RAISE fnd_api.g_exc_error;
   else

        BEGIN
           jtf_rs_resource_extns_pkg.lock_row(
                 x_resource_id => p_resource_id,
                 x_object_version_number => p_object_version_num
            );

           EXCEPTION
           WHEN OTHERS THEN
               x_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_message.set_name('JTF', 'JTF_RS_ROW_LOCK_ERROR');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_unexpected_error;
         END;
         update jtf_rs_resource_extns
         set location = p_location,
             object_version_number = object_version_number + 1
         where resource_id = p_resource_id;

   end if; -- end of res_cur check
   close res_cur;
   p_object_version_num := p_object_version_num + 1;

   FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      ROLLBACK TO update_sp;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  WHEN fnd_api.g_exc_error
    THEN
      ROLLBACK TO update_sp;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS
    THEN
      ROLLBACK TO update_sp;
      fnd_message.set_name ('JTF', 'JTF_RS_UNEXP_ERROR');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME',l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MSG_PUB.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   END;


END jtf_rs_update_location_pub;

/
