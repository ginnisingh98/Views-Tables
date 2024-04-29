--------------------------------------------------------
--  DDL for Package Body AMS_LST_RULE_USAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LST_RULE_USAGES" AS
/* $Header: amsvlmpb.pls 115.5 2002/11/22 08:55:42 jieli ship $ */


PROCEDURE create_list_rule_usages(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_list_header_id        in  NUMBER,
   p_list_rule_id          in  NUMBER,
   x_list_rule_usage_id    OUT NOCOPY number
) IS
l_api_name constant varchar2(30) := 'create_list_rule_usages';
l_api_version       CONSTANT NUMBER := 1.0;
l_list_rule_usage_id   number;
   CURSOR c_get_id is
      SELECT ams_list_rule_usages_s.NEXTVAL
      FROM DUAL;

BEGIN

   SAVEPOINT create_list_rule_usages;

   IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
	RAISE FND_API.g_exc_unexpected_error;
   END IF;
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

       OPEN c_get_id;
       FETCH c_get_id INTO l_list_rule_usage_Id;
       CLOSE c_get_id;

       x_list_rule_usage_id   := l_list_rule_usage_Id;
      delete from ams_list_rule_usages
      where list_header_id = p_list_header_id;

   INSERT INTO ams_list_rule_usages (
    list_rule_usage_id              ,
    list_header_id                  ,
    list_rule_id                    ,
    last_update_date                ,
    last_updated_by                 ,
    creation_date                   ,
    created_by                      ,
    last_update_login               ,
    object_version_number           ,
    active_from_date                ,
    active_to_date                  ,
    priority                        ,
    security_group_id
  )
  values (
    l_list_rule_usage_id,
    p_list_header_id,
    p_list_rule_id,
    sysdate,
    fnd_global.user_id,
    sysdate,
    fnd_global.user_id,
    fnd_global.conc_login_id,
    1,
    sysdate ,
    '',
    '',
    ''
  );

   IF x_return_status =  fnd_api.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;
   IF p_commit = FND_API.g_true then
      COMMIT WORK;
   END IF;

   FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded	   =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
     ROLLBACK TO create_list_rule_usages;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded	=>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   	x_return_status := FND_API.g_ret_sts_unexp_error ;
	ROLLBACK TO create_list_rule_usages;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded	    =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
   	x_return_status := FND_API.g_ret_sts_unexp_error ;
	ROLLBACK TO create_list_rule_usages;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded	   =>      FND_API.G_FALSE
        );

END;
END ams_lst_rule_usages ;

/
