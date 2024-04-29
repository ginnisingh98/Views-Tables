--------------------------------------------------------
--  DDL for Package Body IEM_MC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MC_PUB" AS
/* $Header: iemmcpb.pls 115.12 2003/12/03 22:12:23 txliu noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IEM_MC_PUB';

PROCEDURE prepareMessageComponent
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_action                IN   VARCHAR2,
   p_master_account_id     IN   NUMBER,
   p_activity_id           IN   NUMBER,
   p_to_address_list       IN   VARCHAR2,
   p_cc_address_list       IN   VARCHAR2,
   p_bcc_address_list      IN   VARCHAR2,
   p_subject               IN   VARCHAR2,
   p_sr_id                 IN   NUMBER,
   p_customer_id           IN   NUMBER,
   p_contact_id            IN   NUMBER,
   p_mes_document_id       IN   NUMBER,
   p_mes_category_id       IN   NUMBER,
   p_interaction_id        IN   NUMBER,
   p_qualifiers            IN   QualifierRecordList,
   x_mc_parameters_id      OUT  NOCOPY NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS
BEGIN
   IEM_MC_PUB.prepareMessageComponent
  (p_api_version_number    => p_api_version_number,
   p_init_msg_list         => p_init_msg_list,
   p_commit                => p_commit,
   p_action                => p_action,
   p_master_account_id     => p_master_account_id,
   p_activity_id           => p_master_account_id,
   p_to_address_list       => p_to_address_list,
   p_cc_address_list       => p_cc_address_list,
   p_bcc_address_list      => p_bcc_address_list,
   p_subject               => p_subject,
   p_sr_id                 => p_sr_id,
   p_customer_id           => p_customer_id,
   p_contact_id            => p_contact_id,
   p_relationship_id       => null,
   p_mes_document_id       => p_mes_document_id,
   p_mes_category_id       => p_mes_category_id,
   p_interaction_id        => p_interaction_id,
   p_qualifiers            => p_qualifiers,
   x_mc_parameters_id      => x_mc_parameters_id,
   x_return_status         => x_return_status,
   x_msg_count             => x_msg_count,
   x_msg_data              => x_msg_data
  );

END prepareMessageComponent;

PROCEDURE prepareMessageComponent
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_commit                IN   VARCHAR2 DEFAULT fnd_api.g_false,
   p_action                IN   VARCHAR2,
   p_master_account_id     IN   NUMBER,
   p_activity_id           IN   NUMBER,
   p_to_address_list       IN   VARCHAR2,
   p_cc_address_list       IN   VARCHAR2,
   p_bcc_address_list      IN   VARCHAR2,
   p_subject               IN   VARCHAR2,
   p_sr_id                 IN   NUMBER,
   p_customer_id           IN   NUMBER,
   p_contact_id            IN   NUMBER,
   p_relationship_id       IN   NUMBER,
   p_mes_document_id       IN   NUMBER,
   p_mes_category_id       IN   NUMBER,
   p_interaction_id        IN   NUMBER,
   p_qualifiers            IN   QualifierRecordList,
   x_mc_parameters_id      OUT  NOCOPY NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS

  l_action              VARCHAR2(20);
  l_master_account_id   NUMBER;
  l_activity_id         NUMBER;
  l_to_address_list     VARCHAR2(1024);
  l_cc_address_list     VARCHAR2(1024);
  l_bcc_address_list    VARCHAR2(1024);
  l_subject             VARCHAR2(1024);
  l_sr_id               NUMBER;
  l_customer_id         NUMBER;
  l_contact_id          NUMBER;
  l_relationship_id     NUMBER;
  l_mes_document_id     NUMBER;
  l_mes_category_id     NUMBER;
  l_interaction_id      NUMBER;

  l_msg_count           NUMBER(2);
  l_msg_data            VARCHAR2(2000);

  l_api_name    CONSTANT VARCHAR2(30) := 'prepareMessageComponent';
  l_api_version CONSTANT NUMBER := 1.0;


BEGIN

  SAVEPOINT IEM_MC_PARAMETERS;


  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list)
  then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := fnd_api.g_ret_sts_success;
  x_mc_parameters_id := 0;

  l_action := p_action;
  IF (l_action is null)
  THEN
      l_action := 'reply';
  END IF;

  l_master_account_id   := p_master_account_id;
  l_activity_id         := p_activity_id;
  l_to_address_list     := p_to_address_list;
  l_cc_address_list     := p_cc_address_list;
  l_bcc_address_list    := p_bcc_address_list;
  l_subject             := p_subject;
  l_sr_id               := p_sr_id;
  l_customer_id         := p_customer_id;
  l_contact_id          := p_contact_id;
  l_relationship_id     := p_relationship_id;
  l_mes_document_id     := p_mes_document_id;
  l_mes_category_id     := p_mes_category_id;
  l_interaction_id      := p_interaction_id;

  select IEM_MC_PARAMETERS_S1.NEXTVAL into x_mc_parameters_id from sys.dual;

  insert into IEM_MC_PARAMETERS
  (
    MC_PARAMETER_ID,
    ACTION,
    MASTER_ACCOUNT_ID,
    ACTIVITY_ID,
    TO_ADDRESS_LIST,
    CC_ADDRESS_LIST,
    BCC_ADDRESS_LIST,
    SUBJECT,
    SR_ID,
    CUSTOMER_ID,
    CONTACT_ID,
    RELATIONSHIP_ID,
    MES_DOC_ID,
    MES_CATEGORY_ID,
    INTERACTION_ID,
    DELETE_FLAG_Y_N,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  )
  values
  (
    x_mc_parameters_id,
    l_action,
    l_master_account_id,
    l_activity_id,
    l_to_address_list,
    l_cc_address_list,
    l_bcc_address_list,
    l_subject,
    l_sr_id,
    l_customer_id,
    l_contact_id,
    l_relationship_id,
    l_mes_document_id,
    l_mes_category_id,
    l_interaction_id,
    'N',
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.LOGIN_ID
  );

  IF (p_qualifiers.count > 0)
  THEN
    BEGIN
      FOR i IN p_qualifiers.first .. p_qualifiers.Last
      LOOP
        insert into IEM_MC_CUSTOM_PARAMS
        (
          MC_PARAMETER_ID,
          NAME,
          VALUE
        )
        values
        (
          x_mc_parameters_id,
          p_qualifiers(i).QUALIFIER_NAME,
          p_qualifiers(i).QUALIFIER_VALUE
        );
      END LOOP;
    END;
  END IF;

  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count,
      p_data    => x_msg_data
  );


  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IEM_MC_PARAMETERS;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                p_count        => x_msg_count,
                p_data         => x_msg_data
            );


        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_MC_PARAMETERS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
           p_count        => x_msg_count,
           p_data         => x_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

      WHEN OTHERS THEN
        ROLLBACK TO IEM_MC_PARAMETERS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
          p_count        => x_msg_count,
          p_data         => x_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

END prepareMessageComponent;


PROCEDURE prepareMessageComponentII
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2,
   p_commit                IN   VARCHAR2,
   p_action                IN   VARCHAR2,
   p_master_account_id     IN   NUMBER,
   p_activity_id           IN   NUMBER,
   p_to_address_list       IN   VARCHAR2,
   p_cc_address_list       IN   VARCHAR2,
   p_bcc_address_list      IN   VARCHAR2,
   p_subject               IN   VARCHAR2,
   p_sr_id                 IN   NUMBER,
   p_customer_id           IN   NUMBER,
   p_contact_id            IN   NUMBER,
   p_mes_document_id       IN   NUMBER,
   p_mes_category_id       IN   NUMBER,
   p_interaction_id        IN   NUMBER,
   p_qualifiers            IN   QualifierRecordList,
   p_message_type          IN   VARCHAR2,
   p_encoding		           IN   VARCHAR2,
   p_character_set         IN   VARCHAR2,
   p_relationship_id       IN   NUMBER,
   x_mc_parameters_id      OUT  NOCOPY NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS

  l_created_by             NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_action              VARCHAR2(20);

  l_msg_count           NUMBER(2);
  l_msg_data            VARCHAR2(2000);

  l_api_name    CONSTANT VARCHAR2(30) := 'prepareMessageComponentII';
  l_api_version CONSTANT NUMBER := 1.0;


BEGIN

-- Standard Start of API savepoint
  SAVEPOINT prepareMessageComponentII_pvt;

-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_boolean(p_init_msg_list)
  then
    FND_MSG_PUB.initialize;
  end if;

-- Initialize API return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

-----------------------Code------------------------
  l_action := p_action;
  IF (l_action is null or l_action = fnd_api.g_miss_char)
  THEN
      l_action := 'reply';
  END IF;


  select IEM_MC_PARAMETERS_S1.NEXTVAL into x_mc_parameters_id from sys.dual;

  insert into IEM_MC_PARAMETERS
  (
    MC_PARAMETER_ID,
    ACTION,
    MASTER_ACCOUNT_ID,
    ACTIVITY_ID,
    TO_ADDRESS_LIST,
    CC_ADDRESS_LIST,
    BCC_ADDRESS_LIST,
    SUBJECT,
    SR_ID,
    CUSTOMER_ID,
    CONTACT_ID,
    MES_DOC_ID,
    MES_CATEGORY_ID,
    INTERACTION_ID,
    DELETE_FLAG_Y_N,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ENCODE,
    CHAR_SET,
    MSG_TYPE,
    RELATIONSHIP_ID
  )
  values
  (
    x_mc_parameters_id,
    l_action,
    p_master_account_id,
    decode(p_activity_id, fnd_api.g_miss_num, null, p_activity_id),
    p_to_address_list,
    p_cc_address_list,
    p_bcc_address_list,
    p_subject,
    p_sr_id,
    p_customer_id,
    p_contact_id,
    decode (p_mes_document_id, FND_API.G_MISS_NUM, NULL, p_mes_document_id),
    decode (p_mes_category_id, FND_API.G_MISS_NUM, NULL, p_mes_category_id),
    p_interaction_id,
    'N',
    l_created_by,
    SYSDATE,
    l_last_updated_by,
    SYSDATE,
    l_last_update_login,
    decode(p_encoding, fnd_api.g_miss_char, null, p_encoding),
    decode(p_character_set, fnd_api.g_miss_char, null, p_character_set),
    p_message_type, p_relationship_id );

  IF (p_qualifiers.count > 0)
  THEN
    BEGIN
      FOR i IN p_qualifiers.first .. p_qualifiers.Last
      LOOP
        insert into IEM_MC_CUSTOM_PARAMS
        (
          MC_PARAMETER_ID,
          NAME,
          VALUE
        )
        values
        (
          x_mc_parameters_id,
          p_qualifiers(i).QUALIFIER_NAME,
          p_qualifiers(i).QUALIFIER_VALUE
        );
      END LOOP;
    END;
  END IF;

--------- end of codes -------------------
  -- Standard check of p_commit
  IF FND_API.To_Boolean(p_commit) THEN
     COMMIT WORK;
  END IF;

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO prepareMessageComponentII_pvt;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                p_count        => x_msg_count,
                p_data         => x_msg_data
            );
        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_MC_PARAMETERS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
           p_count        => x_msg_count,
           p_data         => x_msg_data
        );
        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

      WHEN OTHERS THEN
        ROLLBACK TO prepareMessageComponentII_pvt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
          p_count        => x_msg_count,
          p_data         => x_msg_data
        );
        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

END prepareMessageComponentII;

END IEM_MC_PUB;

/
