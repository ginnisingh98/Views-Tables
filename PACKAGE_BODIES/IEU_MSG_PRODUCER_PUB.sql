--------------------------------------------------------
--  DDL for Package Body IEU_MSG_PRODUCER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_MSG_PRODUCER_PUB" AS
/* $Header: IEUPMSGB.pls 120.0 2005/06/02 15:56:07 appldev noship $ */
	G_PKG_NAME CONSTANT VARCHAR2(30) := 'IEU_MSG_PRODUCER_PUB';
PROCEDURE SEND_PLAIN_TEXT_MSG (
  p_api_version      IN NUMBER,
  p_init_msg_list    IN VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_commit           IN VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_application_id   IN NUMBER,
  p_resource_id      IN NUMBER,
  p_resource_type    IN VARCHAR2  DEFAULT 'RS_INDIVIDUAL',
  p_title            IN VARCHAR2,
  p_body             IN VARCHAR2,
  p_workitem_obj_code IN VARCHAR2,
  p_workitem_pk_id    IN NUMBER,
  x_message_id      OUT NOCOPY NUMBER,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
  )
AS
  -- done temporarily, once tables are in place we should use % directive
  -- to refer to table definition for the column size if possible.

  t_max NUMBER := 240;
  b_max NUMBER := 1990;

  l_api_name  CONSTANT VARCHAR2(30) := 'SEND_PLAIN_TEXT_MSG';
  l_api_version CONSTANT NUMBER := 1.0;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_msg_index              number;
  l_msg_param              varchar2(2000);
  l_param_max              varchar2(2000);

BEGIN
  --
  -- !!! WARNING !!!
  --
  -- This implementation is NOT STANDARDS compliant yet... just enough to
  -- get people using it and catching errors in their logic.  To be standards
  -- compliant, you must consider the exception handling further, and deal
  -- with X_RETURN_STATUS appropriately, etc.
  --
  -- Ray Cardillo (06-18-01)
  --
  -- !!! WARNING !!!
  --
  -- this implementation only does validation at this point, so the users
  -- can verify that the logic they intend to write will work correctly.
  -- it is strongly recommended to leave this validation in place, and
  -- make any appropriate updates as things change, because the users are
  -- very likely to attempt things that aren't valid or supported.
  -- Ray Cardillo (06-15-201)

  Savepoint SEND_PLAIN_TEXT_PUB;

  IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list)
  then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( (p_api_version IS NULL) OR
       (p_commit is NULL) OR
       (p_application_id is NULL) OR
       (p_resource_id is NULL) OR
       (p_title is NULL) OR
       (p_body is NULL) )
  THEN
       IF P_API_VERSION IS NULL THEN
--          l_msg_param := 'p_api_version = ' || p_api_version;
        l_msg_param := ' P_API_VERSION';
       END IF;
       If p_commit is null then
--          l_msg_param := l_msg_param||' p_commit = ' || p_commit;
          l_msg_param := l_msg_param||' P_COMMIT:';
       END IF;
       if p_application_id is null then
--          l_msg_param := l_msg_param||' p_application_id = ' || p_application_id;
          l_msg_param := l_msg_param||' P_APPLICATION_ID';
       END IF;
       if p_resource_id is null then
--          l_msg_param := l_msg_param||' p_resource_id = ' || p_resource_id;
          l_msg_param := l_msg_param||' P_RESOURCE_ID';
       END IF;
       if p_title is null then
--          l_msg_param := l_msg_param||' p_title = ' || p_title ;
          l_msg_param := l_msg_param||' P_TITLE';
       END IF;
       if p_body is null then
--          l_msg_param := l_msg_param||' p_body = ' || p_body ;
          l_msg_param := l_msg_param||' P_BODY';
       end if;
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name('IEU','IEU_UWQ_REQUIRED_PARAM_NULL');
       FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_MSG_PRODUCER_PUB.SEND_PLAIN_TEXT_MSG');
       FND_MESSAGE.SET_TOKEN('IEU_UWQ_REQ_PARAM',l_msg_param);
       fnd_msg_pub.add;
  END IF;

  IF ( (LENGTH(p_title) > t_max) OR (LENGTH(p_body) > b_max) )
  THEN

     if length(p_title) > t_max then
         l_param_max := 'LENGTH(P_TITLE) = ' || LENGTH(P_TITLE) || ' MAX for Title = ' || t_max ;
     end if;

     if length(p_body) > b_max then
         l_param_max := l_param_max||' LENGTH(P_BODY) = ' || LENGTH(P_BODY) || ' MAX for Body = ' || b_max ;
     end if;

      x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('IEU','IEU_UWQ_PARAM_EXCEED_MAX');
     FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_MSG_PRODUCER_PUB.SEND_PLAIN_TEXT_MSG');
     FND_MESSAGE.SET_TOKEN('IEU_UWQ_PARAM_MAX',l_param_max);
     fnd_msg_pub.add;
--     fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END IF;

  IF p_resource_TYPE = 'RS_GROUP' or p_resource_TYPE = 'RS_TEAM'
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    fnd_message.set_name('IEU','IEU_UWQ_INVALID_RESOURCE_TYPE');
    FND_MESSAGE.SET_TOKEN('IEU_UWQ_RESOURCE_TYPE',P_RESOURCE_TYPE);
    fnd_msg_pub.add;
--    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END IF;

  if x_return_status = FND_API.G_RET_STS_ERROR THEN
      raise FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  select IEU_MSG_MESSAGES_S1.NEXTVAL into x_message_id from dual;
  INSERT INTO
    IEU_MSG_MESSAGES
    (
      MESSAGE_ID,
      OBJECT_VERSION_NUMBER,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN,
      APPLICATION_ID,
      RESOURCE_TYPE,
      RESOURCE_ID,
      STATUS_ID,
      TITLE,
      BODY,
      WORKITEM_OBJ_CODE,
      WORKITEM_PK_ID
    )
    VALUES
    (
      x_message_id,
      1,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.LOGIN_ID,
      p_application_id,
      'RS_INDIVIDUAL',
      p_resource_id,
      1,   -- just assuming 1 for now...
      p_title,
      p_body,
      p_workitem_obj_code,
      p_workitem_pk_id
    );
  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
     COMMIT WORK;
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  -- Standard call to get message count and if count is 1, get message info
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO SEND_PLAIN_TEXT_PUB;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO SEND_PLAIN_TEXT_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
     WHEN OTHERS THEN
          ROLLBACK TO SEND_PLAIN_TEXT_PUB;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END SEND_PLAIN_TEXT_MSG;

END IEU_MSG_PRODUCER_PUB;

/
