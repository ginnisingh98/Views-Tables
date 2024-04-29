--------------------------------------------------------
--  DDL for Package Body IEM_OUTBOX_PROC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_OUTBOX_PROC_PUB" as
/* $Header: iemobprb.pls 120.6 2006/01/25 07:55:33 txliu noship $*/

-- PACKAGE CONSTANTS NO LITERALS USED.
G_PKG_NAME CONSTANT varchar2(30) :='IEM_OUTBOX_PROC_PUB';
G_INBOUND          VARCHAR2(1)   := 'I';
G_OUTBOUND         VARCHAR2(1)   := 'O';
G_WORK_IN_PROGRESS VARCHAR2(1)   := 'P';
G_ACTIVE           VARCHAR2(1)   := 'N';
G_EXPIRE           VARCHAR2(1)   := 'Y';
G_MASTER_ACCOUNT   VARCHAR2(1)   := 'M';
G_AGENT_ACCOUNT    VARCHAR2(1)   := 'A';
G_CHAR_NOP         VARCHAR2(1)   := ' ';
G_NEWOUTB_FOLDER   VARCHAR2(8)   := '__NoNe';
G_NUM_NOP2         NUMBER        := -1;
G_NUM_NOP          NUMBER        := -99;
--G_AUTOR_MSG_ID     NUMBER        := -999;
G_AUTOR_MC_PARA_ID NUMBER        := -123;

G_TRANSFER         VARCHAR2(1)   := 'R';
G_WRAP_UP          VARCHAR2(1)   := 'W';
G_DORMANT          VARCHAR2(1)   := 'D';
G_QUEUEOUT         VARCHAR2(1)   := 'Q';
G_PROCESSING       VARCHAR2(1)   := 'G';
G_UNREAD           VARCHAR2(1)   := 'U';
G_UNMOVED           VARCHAR2(1)   := 'M';
G_PRETRANSFER      VARCHAR2(1)   := 'F';
G_O_DIRECTION      VARCHAR2(10)  := 'OUTBOUND';
G_I_DIRECTION      VARCHAR2(10)  := 'INBOUND';
G_MEDIA_TYPE       VARCHAR2(10)  := 'EMAIL';
G_DEFAULT_ROUTE    VARCHAR2(100) := 'Unclassified';
G_REDIRECT         VARCHAR2(1)   := 'R';
G_AUTOFORWAD_ACT   VARCHAR2(1)   := 'F';


PROCEDURE createOutboxMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_resource_id           IN   NUMBER,
    p_application_id        IN   NUMBER,
    p_responsibility_id     IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_sr_id                 IN   NUMBER,
    p_customer_id           IN   NUMBER,
    p_contact_id            IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_message_type          IN   VARCHAR2,
    p_encoding		          IN   VARCHAR2,
    p_character_set         IN   VARCHAR2,
    p_option                IN   VARCHAR2,  -- 'A' for auto-ack
    p_relationship_id       IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='createOutboxMessage';
  l_api_version_number     NUMBER:=1.0;
  l_created_by             NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_mc_parameter_id        NUMBER;
  l_i_sequence             NUMBER;
  l_version                NUMBER;
  l_rt_interaction_id      NUMBER;
  l_rt_media_item_id       NUMBER;
  l_qualifiers             IEM_MC_PUB.QualifierRecordList;
  IEM_BAD_RECIPIENT        EXCEPTION;
  l_parent_ih_id           NUMBER;
  l_action_id              NUMBER;

BEGIN


-- Standard Start of API savepoint
   SAVEPOINT createOutboxMessage_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
-- insanity check
   IF (p_to_address_list is null and p_cc_address_list is null) THEN
     RAISE IEM_BAD_RECIPIENT;
   END IF;

-- create iem_mc_parameter record
  IF (p_qualifiers.count > 0)  THEN
    BEGIN
      FOR i IN p_qualifiers.first .. p_qualifiers.Last
      LOOP
        l_qualifiers(i).QUALIFIER_NAME := p_qualifiers(i).QUALIFIER_NAME;
        l_qualifiers(i).QUALIFIER_VALUE := p_qualifiers(i).QUALIFIER_VALUE;
      END LOOP;
    END;
  END IF;

  IEM_MC_PUB.prepareMessageComponentII
  (p_api_version_number    => 1.0,
   p_init_msg_list         =>fnd_api.g_false,
   p_commit                =>fnd_api.g_false,
   p_action                => 'automsg',
   p_master_account_id     => p_master_account_id,
   p_activity_id           =>fnd_api.g_miss_num,
   p_to_address_list       => p_to_address_list,
   p_cc_address_list       => p_cc_address_list,
   p_bcc_address_list      => p_bcc_address_list,
   p_subject               => p_subject,
   p_sr_id                 => p_sr_id,
   p_customer_id           => p_customer_id,
   p_contact_id            => p_contact_id,
   p_mes_document_id       =>fnd_api.g_miss_num,
   p_mes_category_id       =>fnd_api.g_miss_num,
   p_interaction_id        => p_interaction_id,
   p_qualifiers            => l_qualifiers,
   p_message_type          => p_message_type,
   p_encoding		           => p_encoding,
   p_character_set         => p_character_set,
   p_relationship_id       => p_relationship_id,
   x_mc_parameters_id      => l_mc_parameter_id,
   x_return_status         => l_return_status,
   x_msg_count             => l_msg_count,
   x_msg_data              => l_msg_data
  );


-- Check return status; Proceed on success Or report back in case of error.
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
  -- Success.
  --create outbound here

    -- if auto-ack, update the parent_ih_id
    if ( p_option = 'A' ) then
        l_parent_ih_id := p_interaction_id;
        l_action_id := 83;
    else
        l_parent_ih_id := null;
        l_action_id := G_NUM_NOP;
    end if;

    IEM_CLIENT_PUB.createMediaDetails (
             p_api_version_number => 1.0,
             p_init_msg_list      => fnd_api.g_false,
             p_commit             => fnd_api.g_false,
             p_resource_id        => p_resource_id,
             p_rfc822_message_id  => null,
             p_folder_name      => G_NEWOUTB_FOLDER,
             p_folder_uid       => G_NUM_NOP2,
             p_account_id       => p_master_account_id,
             p_account_type     => G_MASTER_ACCOUNT,
             p_status           => G_CHAR_NOP,
             p_customer_id      => p_customer_id,
             p_rt_media_item_id => FND_API.G_MISS_NUM,
             p_subject          => p_subject,
             p_interaction_id   => null,
             p_service_request_id => p_sr_id,
             p_mc_parameter_id    => l_mc_parameter_id,
             p_service_request_action  => null,
             p_contact_id       => p_contact_id,
             p_lead_id          => null,
             p_parent_ih_id     => l_parent_ih_id,
             p_action_id        => l_action_id,
             p_relationship_id  => p_relationship_id,
             x_return_status    => l_return_status,
             x_msg_count        => l_msg_count,
             x_msg_data         => l_msg_data,
             x_version          => l_version,
             x_rt_media_item_id => l_rt_media_item_id,
             x_rt_interaction_id=> l_rt_interaction_id
             );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      UPDATE iem_rt_interactions SET status = 'S'   -- send
      WHERE rt_interaction_id = l_rt_interaction_id;

      x_outbox_item_id := l_rt_media_item_id;

    ELSE
      -- return the error returned by IEM_CLIENT_PUB.createMediaDetails
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

    END IF;


  ELSE
  -- Return the error returned by MC_PARA_PUB API
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

  END IF;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                          p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN IEM_BAD_RECIPIENT  THEN
          ROLLBACK TO createOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_RECIPIENT');
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_TRUE,
          p_count => x_msg_count,
          p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO createOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END createOutboxMessage;



PROCEDURE cancelOutboxMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outbox_item_id        IN   NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY  NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='cancelOutboxMessage';
  l_api_version_number     NUMBER:=1.0;
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);
  l_rt_interaction_id      NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT cancelOutboxMessage_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
-- Expire rt_interactions and rt_media_items
SELECT rt_interaction_id INTO l_rt_interaction_id
FROM iem_rt_media_items WHERE rt_media_item_id = p_outbox_item_id;

UPDATE iem_rt_media_items SET
  expire = G_EXPIRE,
  last_updated_by = l_last_updated_by,
  last_update_login = l_last_update_login
WHERE rt_interaction_id = l_rt_interaction_id;

UPDATE iem_rt_interactions SET
  expire = G_EXPIRE,
  last_updated_by = l_last_updated_by,
  last_update_login = l_last_update_login
WHERE rt_interaction_id = l_rt_interaction_id;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO cancelOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO cancelOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO cancelOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END cancelOutboxMessage;

-- Queue this to outbox
PROCEDURE submitOutboxMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_outbox_item_id        IN   NUMBER,
    p_preview_bool          IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='submitOutboxMessage';
  l_api_version_number     NUMBER:=1.0;
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_status                 VARCHAR2(1);
  l_rt_interaction_id      NUMBER;

  l_action_id              NUMBER;
  l_outcome_id             NUMBER;
  l_result_id              NUMBER;
  l_activity_type_id       NUMBER;
  l_reason_id              NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT submitOutboxMessage_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------

SELECT rt_interaction_id INTO l_rt_interaction_id
FROM iem_rt_media_items WHERE rt_media_item_id = p_outbox_item_id;

SELECT status, decode(action_id, NULL, -1, action_id),
       action_item_id, outcome_id, result_id, reason_id
INTO l_status, l_action_id, l_activity_type_id, l_outcome_id,  l_result_id,
     l_reason_id
FROM iem_rt_interactions
WHERE rt_interaction_id = l_rt_interaction_id;

IEM_CLIENT_PUB.queueToOutbox  (p_api_version_number    => 1.0,
                   p_init_msg_list         => fnd_api.g_false,
                   p_commit                => fnd_api.g_false,
                   p_action                => l_status,
                   p_action_id             => l_action_id,
                   p_rt_media_item_id      => p_outbox_item_id,
                   p_version               => 0,
                   p_customer_id           => G_NUM_NOP,
                   p_activity_type_id      => l_activity_type_id,
                   p_outcome_id            => l_outcome_id,
                   p_result_id             => l_result_id,
                   p_reason_id             => l_reason_id,
                   p_to_resource_id        => null,
                   p_status                => l_status,
                   x_return_status         => l_return_status,
                   x_msg_count             => l_msg_count,
                   x_msg_data              => l_msg_data );

x_return_status := l_return_status;
x_msg_count := l_msg_count;
x_msg_data := l_msg_data;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO submitOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
          FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO submitOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
          FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;

   WHEN OTHERS THEN
          ROLLBACK TO submitOutboxMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);
          FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
            FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
            x_msg_data := x_msg_data || ',' || l_msg_data;
          END LOOP;

END submitOutboxMessage;


PROCEDURE writeOutboxError(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_rt_media_item_id      IN   NUMBER,
    p_error_summary         IN   VARCHAR2,
    p_error_msg             IN   VARCHAR2,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='writeOutboxError';
  l_api_version_number     NUMBER:=1.0;
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_error_id               NUMBER;
  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT writeOutboxError_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------

select iem_outbox_errors_s1.nextval into l_error_id from dual;

INSERT INTO iem_outbox_errors
( OUTBOX_ERROR_ID,  RT_MEDIA_ITEM_ID,  ERROR_SUMMARY,
  ERROR_MESSAGE,  CREATE_DATE,  EXPIRE  )
VALUES ( l_error_id, p_rt_media_item_id, p_error_summary,
 p_error_msg, SYSDATE, G_ACTIVE );

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO writeOutboxError_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO writeOutboxError_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO writeOutboxError_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END writeOutboxError;



PROCEDURE createAutoReply(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_media_id              IN   NUMBER,
    p_rfc822_message_id     IN   VARCHAR2,
    p_folder_name           IN   VARCHAR2,
    p_message_uid           IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_tag_key_value_tbl     IN   keyVals_tbl_type,
    p_customer_id           IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_resource_id           IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_contact_id            IN   NUMBER,
    p_relationship_id       IN   NUMBER,
    p_mdt_message_id        IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS
  l_api_name               VARCHAR2(255):='createAutoReply';
  l_api_version_number     NUMBER:=1.0;
  l_created_by             NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_version                NUMBER;
  l_rt_interaction_id      NUMBER;
  l_rt_media_item_id       NUMBER;
  l_tag_key_value          keyVals_tbl_type;
  l_sr_id                  NUMBER := null;
  l_customer_id            NUMBER := null;
  l_contact_id             NUMBER := null;
  l_parent_ih_id           NUMBER := null;
  l_interaction_id         NUMBER;
  l_ih_creator             VARCHAR2(1);
  l_resource_id            NUMBER;
  l_mc_parameter_id        NUMBER;
  l_qualifiers             IEM_MC_PUB.QualifierRecordList;
  l_relationship_id        NUMBER;

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT createAutoReply_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
    -- Extract tag key value from key value table
    -- Currently valid system key names:
    -- IEMNBZTSRVSRID for sr id
    -- IEMNINTERACTIONID for interaction id
    -- IEMNAGENTID for agent id
    -- IEMNCUSTOMERID for customer id
    -- IEMNCONTACTID for contact id
    -- IEMNRELATIONSHIPID for relationship id

    IF (p_tag_key_value_tbl.count > 0 ) THEN
      FOR i IN p_tag_key_value_tbl.FIRST..p_tag_key_value_tbl.LAST LOOP
       BEGIN
        IF (p_tag_key_value_tbl(i).key = 'IEMNBZTSRVSRID' ) THEN
           l_sr_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNINTERACTIONID' ) THEN
           l_parent_ih_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNCUSTOMERID' ) THEN
           l_customer_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNCONTACTID' ) THEN
           l_contact_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNRELATIONSHIPID' ) THEN
           l_relationship_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        END IF;
       END;
      END LOOP;
    END IF;


-- customer id and contact id from tagging supersede the result from
-- email search i.e. what are from inputs
    IF (l_customer_id is NULL) THEN
      BEGIN
        l_customer_id := p_customer_id;
        l_contact_id := p_contact_id;
        l_relationship_id := p_relationship_id;
      END;
    END IF;

-- Find resource_id by searching outbox_processing_agent.
   l_resource_id := p_resource_id;

-- Record details into the RT tables.
   IF ( p_interaction_id = fnd_api.g_miss_num) THEN
     l_interaction_id := null;
     l_ih_creator := null;
   ELSE
     l_interaction_id := p_interaction_id;
     l_ih_creator := 'Y';
   END IF;

-- create iem_mc_parameter record
  IF (p_qualifiers.count > 0)  THEN
    BEGIN
      FOR i IN p_qualifiers.first .. p_qualifiers.Last
      LOOP
        l_qualifiers(i).QUALIFIER_NAME := p_qualifiers(i).QUALIFIER_NAME;
        l_qualifiers(i).QUALIFIER_VALUE := p_qualifiers(i).QUALIFIER_VALUE;
      END LOOP;
    END;
  END IF;

  IEM_MC_PUB.prepareMessageComponentII
  (p_api_version_number    => 1.0,
   p_init_msg_list         =>fnd_api.g_false,
   p_commit                =>fnd_api.g_false,
   p_action                => 'autoreply',
   p_master_account_id     => p_master_account_id,
   p_activity_id           => fnd_api.g_miss_num,
   p_to_address_list       => p_to_address_list,
   p_cc_address_list       => p_cc_address_list,
   p_bcc_address_list      => p_bcc_address_list,
   p_subject               => p_subject,
   p_sr_id                 => null,
   p_customer_id           => l_customer_id,
   p_contact_id            => l_contact_id,
   p_mes_document_id       => fnd_api.g_miss_num,
   p_mes_category_id       => fnd_api.g_miss_num,
   p_interaction_id        => null,
   p_qualifiers            => l_qualifiers,
   p_message_type          => null, --p_message_type,
   p_encoding		           => null, --p_encoding,
   p_character_set         => null, --p_character_set,
   p_relationship_id       => l_relationship_id,
   x_mc_parameters_id      => l_mc_parameter_id,
   x_return_status         => l_return_status,
   x_msg_count             => l_msg_count,
   x_msg_data              => l_msg_data
  );


-- Check return status; Proceed on success Or report back in case of error.
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
  -- Success.


   select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
   INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, contact_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, parent_interaction_id,
                   service_request_id, inb_tag_id, interaction_id,
                   mc_parameter_id, ih_creator, action_id, action_item_id,
                   outcome_id, relationship_id)
         VALUES (
                   l_i_sequence, l_resource_id, l_customer_id, l_contact_id,
                   G_INBOUND, 'S', G_ACTIVE, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   l_parent_ih_id, l_sr_id, null, l_interaction_id,
                   l_mc_parameter_id, l_ih_creator, 74, 45, 53, l_relationship_id);


   select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
   INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login )
          VALUES (
                   l_i_sequence, l_m_sequence, l_resource_id,
                   p_media_id,
                   p_mdt_message_id,
                   p_rfc822_message_id,
                   p_folder_name,
                   p_message_uid,
                   p_master_account_id,
                   null,
                   G_INBOUND, G_UNMOVED, G_ACTIVE,0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login );

  --create outbound here
  IEM_CLIENT_PUB.createMediaDetails (p_api_version_number    => 1.0,
                              p_init_msg_list         => fnd_api.g_false,
                              p_commit                => fnd_api.g_false,
                              p_resource_id           => l_resource_id,
                              p_rfc822_message_id     => null,
                              p_folder_name           => G_NEWOUTB_FOLDER,
                              p_folder_uid            => G_NUM_NOP2,
                              p_account_id            => p_master_account_id,
                              p_account_type          => G_MASTER_ACCOUNT,
                              p_status                => G_CHAR_NOP,
                              p_customer_id           => l_customer_id,
                              p_rt_media_item_id      => l_m_sequence,
                              p_subject               => null,
                              p_interaction_id        => p_interaction_id,
                              p_service_request_id    => l_sr_id,
                              p_mc_parameter_id       => G_AUTOR_MC_PARA_ID,
                              p_service_request_action   => null,
                              p_contact_id            => l_contact_id,
                              p_lead_id               => null,
                              p_parent_ih_id          => null,
                              p_action_id             => G_NUM_NOP,
                              p_relationship_id       => l_relationship_id,
                              x_return_status         => l_return_status,
                              x_msg_count             => l_msg_count,
                              x_msg_data              => l_msg_data,
                              x_version               => l_version,
                              x_rt_media_item_id      => l_rt_media_item_id,
                              x_rt_interaction_id     => l_rt_interaction_id
                              );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      x_outbox_item_id := l_rt_media_item_id;

    ELSE
      -- return the error returned by IEM_CLIENT_PUB.createMediaDetails
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

    END IF;

  ELSE
      -- return the error returned by IEM_MC_PUB.prepareMessageComponentII
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

  END IF;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
        p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createAutoReply_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createAutoReply_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO createAutoReply_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END createAutoReply;



PROCEDURE insertBodyText
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2,
   p_commit                IN   VARCHAR2,
   p_outbox_item_id        IN   NUMBER,
   p_text                  IN   BLOB,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS

  l_msg_count           NUMBER(2);
  l_msg_data            VARCHAR2(2000);
  l_sequence            NUMBER;

  l_api_name    CONSTANT VARCHAR2(30) := 'InsertBodyText';
  l_api_version CONSTANT NUMBER := 1.0;


BEGIN

  SAVEPOINT insertBodyText;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list)
  then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := fnd_api.g_ret_sts_success;

  select count(REF_KEY) into l_sequence from IEM_MSG_PARTS where REF_KEY = p_outbox_item_id and PART_TYPE = 'HTMLTEXT';
  l_sequence := l_sequence + 1;

  insert into IEM_MSG_PARTS
  (
    REF_KEY,
    PART_TYPE,
    PART_NAME,
    PART_DATA,
    DELETE_FLAG,
    LAST_UPDATE_DATE
  )
  values
  (
    p_outbox_item_id,
    'HTMLTEXT',
    l_sequence,
    empty_blob(),
    'N',
    SYSDATE
  );

  update IEM_MSG_PARTS set PART_DATA = p_text where REF_KEY = p_outbox_item_id and PART_TYPE = 'HTMLTEXT' and PART_NAME = l_sequence;

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
        ROLLBACK TO IEM_MSG_PARTS;

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
        ROLLBACK TO IEM_MSG_PARTS;
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
        ROLLBACK TO IEM_MSG_PARTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
          p_count        => x_msg_count,
          p_data         => x_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

END insertBodyText;


PROCEDURE insertDocument
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2,
   p_commit                IN   VARCHAR2,
   p_outbox_item_id        IN   NUMBER,
   p_document_source       IN   VARCHAR2,
   p_document_id           IN   NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS

  l_msg_count           NUMBER(2);
  l_msg_data            VARCHAR2(2000);
  l_part_info           VARCHAR2(128);
  l_sequence            NUMBER;

  l_api_name    CONSTANT VARCHAR2(30) := 'insertDocument';
  l_api_version CONSTANT NUMBER := 1.0;


BEGIN

  SAVEPOINT insertDocument;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list)
  then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := fnd_api.g_ret_sts_success;

  l_part_info := '__DOC__:'||p_document_id||'@'||p_document_source;

  select count(REF_KEY) into l_sequence from IEM_MSG_PARTS where REF_KEY = p_outbox_item_id and PART_TYPE = 'HTMLTEXT';
  l_sequence := l_sequence + 1;

  insert into IEM_MSG_PARTS
  (
    REF_KEY,
    PART_TYPE,
    PART_NAME,
    PART_INFO,
    PART_DATA,
    DELETE_FLAG,
    LAST_UPDATE_DATE
  )
  values
  (
    p_outbox_item_id,
    'HTMLTEXT',
    l_sequence,
    l_part_info,
    empty_Blob(),
    'N',
    SYSDATE
  );

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
        ROLLBACK TO IEM_MSG_PARTS;

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
        ROLLBACK TO IEM_MSG_PARTS;
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
        ROLLBACK TO IEM_MSG_PARTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
          p_count        => x_msg_count,
          p_data         => x_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

END insertDocument;


PROCEDURE attachDocument
  (p_api_version_number    IN   NUMBER,
   p_init_msg_list         IN   VARCHAR2,
   p_commit                IN   VARCHAR2,
   p_outbox_item_id        IN   NUMBER,
   p_document_source       IN   VARCHAR2,
   p_document_id           IN   NUMBER,
   p_binary_source         IN   BLOB,
   p_attachment_name       IN   VARCHAR2,
   x_return_status         OUT  NOCOPY VARCHAR2,
   x_msg_count             OUT  NOCOPY NUMBER,
   x_msg_data              OUT  NOCOPY VARCHAR2
  ) AS

  l_msg_count           NUMBER(2);
  l_msg_data            VARCHAR2(2000);
  l_part_info           VARCHAR2(128);

  l_api_name    CONSTANT VARCHAR2(30) := 'attachDocument';
  l_api_version CONSTANT NUMBER := 1.0;


BEGIN

  SAVEPOINT attachDocument;

  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version_number, l_api_name, G_PKG_NAME)
  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF fnd_api.to_boolean(p_init_msg_list)
  then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := fnd_api.g_ret_sts_success;

  IF (p_document_source = 'BINARY')
  THEN
    insert into IEM_MSG_PARTS
    (
      REF_KEY,
      PART_TYPE,
      PART_NAME,
      PART_INFO,
      PART_DATA,
      DELETE_FLAG,
      LAST_UPDATE_DATE
    )
    values
    (
      p_outbox_item_id,
      'ATTACHMENT',
      p_attachment_name,
      NULL,
      empty_Blob(),
      'N',
      SYSDATE
    );

    update IEM_MSG_PARTS set PART_DATA = p_binary_source where REF_KEY = p_outbox_item_id and PART_TYPE = 'ATTACHMENT' and  PART_NAME = p_attachment_name;

  ELSE
    l_part_info := '__DOC__:'||p_document_id||'@'||p_document_source;

    insert into IEM_MSG_PARTS
    (
      REF_KEY,
      PART_TYPE,
      PART_NAME,
      PART_INFO,
      PART_DATA,
      DELETE_FLAG,
      LAST_UPDATE_DATE
    )
    values
    (
      p_outbox_item_id,
      'ATTACHMENT',
      p_attachment_name,
      l_part_info,
      empty_Blob(),
      'N',
      SYSDATE
    );
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
        ROLLBACK TO IEM_MSG_PARTS;

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
        ROLLBACK TO IEM_MSG_PARTS;
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
        ROLLBACK TO IEM_MSG_PARTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get (
          p_count        => x_msg_count,
          p_data         => x_msg_data
        );

        FOR i in 1..fnd_msg_pub.COUNT_MSG() LOOP
          FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
          x_msg_data := x_msg_data || ',' || l_msg_data;
        END LOOP;

END attachDocument;



PROCEDURE getAccountList(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_resource_id           IN   NUMBER,
    x_account_list          OUT  NOCOPY AcctRecList,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='getAccountList';
  l_api_version_number     NUMBER:=1.0;
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);
  l_rt_interaction_id      NUMBER;
  l_account_list           IEM_EMAILACCOUNT_PUB.EMACNT_tbl_type;
  l_index                  NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT getAccountList_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------

  IEM_EMAILACCOUNT_PUB.Get_EmailAccount_List (p_api_version_number =>1.0,
                     p_init_msg_list  => FND_API.G_FALSE,
                     p_commit         => FND_API.G_FALSE,
                     p_RESOURCE_ID    => p_resource_id,
                     x_return_status  => l_return_status,
                     x_msg_count      => l_msg_count,
                     x_msg_data       => l_msg_data,
                     x_Email_Acnt_tbl => l_account_list
                );
  IF ( l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    if (l_account_list.count > 0) then
      l_index := 1;
      FOR i in l_account_list.first..l_account_list.last LOOP
          x_account_list(l_index).account_id := l_account_list(i).account_id;
          x_account_list(l_index).account_name := l_account_list(i).account_name;
          l_index:=l_index+1;
      END LOOP;
    end if;
  ELSE
    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;
  END IF;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getAccountList_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getAccountList_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getAccountList_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END getAccountList;

PROCEDURE redirectMessage(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_mdt_msg_id            IN   NUMBER,
    p_to_account_id         IN   NUMBER,
    p_resource_id           IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS

  l_api_name               VARCHAR2(255):='redirectMessage';
  l_api_version_number     NUMBER:=1.0;
  l_created_by             NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  IEM_NO_DATA              EXCEPTION;
  l_email_acct_id          NUMBER;
  l_classification_id      NUMBER;
  l_media_id               NUMBER;
  l_folder_name            VARCHAR2(255);
  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_db_server_id           NUMBER;


BEGIN

-- Standard Start of API savepoint
        SAVEPOINT redirectMessage_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
   begin
     select EMAIL_ACCOUNT_ID, RT_CLASSIFICATION_ID,
          IH_MEDIA_ITEM_ID
          into l_email_acct_id, l_classification_id,
          l_media_id
          from iem_rt_proc_emails where message_id = p_mdt_msg_id;
   exception
     when others then
       null;
   end;

   if ( l_email_acct_id is null ) then
     raise IEM_NO_DATA;
   end if;

   SELECT name INTO l_folder_name
   FROM   iem_route_classifications
   WHERE  ROUTE_CLASSIFICATION_ID = l_classification_id;

   select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
   INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, to_resource_id
                   )
              VALUES (
                   l_i_sequence, p_resource_id, G_INBOUND,
                   G_REDIRECT, G_QUEUEOUT, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   p_to_account_id
              );

       select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
       INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login )
              VALUES (
                   l_i_sequence, l_m_sequence, p_resource_id,
                   l_media_id, p_mdt_msg_id, null,
                   l_folder_name, null, l_email_acct_id,
                   null, G_INBOUND, G_UNMOVED, G_ACTIVE,
                   0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login
              );

      x_outbox_item_id := l_m_sequence;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
	( p_encoded => FND_API.G_TRUE,
    p_count =>  x_msg_count,
    p_data  =>    x_msg_data
	);

EXCEPTION
   WHEN IEM_NO_DATA THEN
          ROLLBACK TO redirectMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_TRUE,
            p_count => x_msg_count,
            p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO redirectMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO redirectMessage_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO redirectMessage_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END redirectMessage;

PROCEDURE autoForward(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_media_id              IN   NUMBER,
    p_rfc822_message_id     IN   VARCHAR2,
    p_folder_name           IN   VARCHAR2,
    p_message_uid           IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_tag_key_value_tbl     IN   keyVals_tbl_type,
    p_customer_id           IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_resource_id           IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_contact_id            IN   NUMBER,
    p_relationship_id       IN   NUMBER,
    p_attach_inb            IN   VARCHAR2,  -- if 'A' attach original inbound, if 'I' inbound is inlined
    p_mdt_message_id        IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    )
IS
  l_api_name               VARCHAR2(255):='autoForward';
  l_api_version_number     NUMBER:=1.0;
  l_created_by             NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_version                NUMBER;
  l_rt_interaction_id      NUMBER;
  l_rt_media_item_id       NUMBER;
  l_tag_key_value          keyVals_tbl_type;
  l_sr_id                  NUMBER := null;
  l_customer_id            NUMBER := null;
  l_contact_id             NUMBER := null;
  l_parent_ih_id           NUMBER := null;
  l_interaction_id         NUMBER;
  l_ih_creator             VARCHAR2(1);
  l_db_server_id           NUMBER;
  l_resource_id            NUMBER;
  l_mc_parameter_id        NUMBER;
  l_qualifiers             IEM_MC_PUB.QualifierRecordList;
  l_relationship_id        NUMBER;
  IEM_BAD_RECIPIENT        EXCEPTION;

BEGIN


-- Standard Start of API savepoint
   SAVEPOINT autoForward_pvt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
-- insanity check
   IF (p_to_address_list is null and p_cc_address_list is null) THEN
     RAISE IEM_BAD_RECIPIENT;
   END IF;

    -- Extract tag key value from key value table
    -- Currently valid system key names:
    -- IEMNBZTSRVSRID for sr id
    -- IEMNINTERACTIONID for interaction id
    -- IEMNAGENTID for agent id
    -- IEMNCUSTOMERID for customer id
    -- IEMNCONTACTID for contact id
    -- IEMNRELATIONSHIPID for relationship id

    IF (p_tag_key_value_tbl.count > 0 ) THEN
      FOR i IN p_tag_key_value_tbl.FIRST..p_tag_key_value_tbl.LAST LOOP
       BEGIN
        IF (p_tag_key_value_tbl(i).key = 'IEMNBZTSRVSRID' ) THEN
           l_sr_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNINTERACTIONID' ) THEN
           l_parent_ih_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNCUSTOMERID' ) THEN
           l_customer_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNCONTACTID' ) THEN
           l_contact_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNRELATIONSHIPID' ) THEN
           l_relationship_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        END IF;
       END;
      END LOOP;
    END IF;


-- customer id and contact id from tagging supersede the result from
-- email search i.e. what are from inputs
    IF (l_customer_id is NULL) THEN
      BEGIN
        l_customer_id := p_customer_id;
        l_contact_id := p_contact_id;
        l_relationship_id := p_relationship_id;
      END;
    END IF;

-- Find resource_id by searching outbox_processing_agent.
   l_resource_id := p_resource_id;

-- Record details into the RT tables.
   IF ( p_interaction_id = fnd_api.g_miss_num) THEN
     l_interaction_id := null;
     l_ih_creator := null;
   ELSE
     l_interaction_id := p_interaction_id;
     l_ih_creator := 'Y';
   END IF;


-- create iem_mc_parameter record
  IF (p_qualifiers.count > 0)  THEN
    BEGIN
      FOR i IN p_qualifiers.first .. p_qualifiers.Last
      LOOP
        l_qualifiers(i).QUALIFIER_NAME := p_qualifiers(i).QUALIFIER_NAME;
        l_qualifiers(i).QUALIFIER_VALUE := p_qualifiers(i).QUALIFIER_VALUE;
      END LOOP;
    END;
  END IF;

  IEM_MC_PUB.prepareMessageComponentII
  (p_api_version_number    => 1.0,
   p_init_msg_list         => fnd_api.g_false,
   p_commit                => fnd_api.g_false,
   p_action                => 'autoforward',
   p_master_account_id     => p_master_account_id,
   p_activity_id           => fnd_api.g_miss_num,
   p_to_address_list       => p_to_address_list,
   p_cc_address_list       => p_cc_address_list,
   p_bcc_address_list      => p_bcc_address_list,
   p_subject               => p_subject,
   p_sr_id                 => null,
   p_customer_id           => l_customer_id,
   p_contact_id            => l_contact_id,
   p_mes_document_id       => fnd_api.g_miss_num,
   p_mes_category_id       => fnd_api.g_miss_num,
   p_interaction_id        => l_interaction_id,
   p_qualifiers            => l_qualifiers,
   p_message_type          => null, --p_message_type, use the same as inb
   p_encoding		           => null, --p_encoding,
   p_character_set         => null, --p_character_set,
   p_relationship_id       => l_relationship_id,
   x_mc_parameters_id      => l_mc_parameter_id,
   x_return_status         => l_return_status,
   x_msg_count             => l_msg_count,
   x_msg_data              => l_msg_data
  );


-- Check return status; Proceed on success Or report back in case of error.
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
  -- Success.
  --create outbound here

   select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
   INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, contact_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, parent_interaction_id,
                   service_request_id, inb_tag_id, interaction_id,
                   mc_parameter_id, ih_creator, action_id, action_item_id,
                   outcome_id, result_id, relationship_id)
         VALUES (
                   l_i_sequence, l_resource_id, l_customer_id, l_contact_id,
                   G_INBOUND, G_AUTOFORWAD_ACT, G_ACTIVE, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   l_parent_ih_id, l_sr_id, null, l_interaction_id,
                   l_mc_parameter_id, l_ih_creator, 73, 45, -1, -1, l_relationship_id);


   select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
   INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login,
                   edit_mode )
          VALUES (
                   l_i_sequence, l_m_sequence, l_resource_id,
                   p_media_id,
                   p_mdt_message_id,
                   p_rfc822_message_id,
                   p_folder_name,
                   p_message_uid,
                   p_master_account_id,
                   null,
                   G_INBOUND, G_UNMOVED, G_ACTIVE,0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login, p_attach_inb);

  --create outbound here
  IEM_CLIENT_PUB.createMediaDetails (p_api_version_number    => 1.0,
                              p_init_msg_list         => fnd_api.g_false,
                              p_commit                => fnd_api.g_false,
                              p_resource_id           => l_resource_id,
                              p_rfc822_message_id     => null,
                              p_folder_name           => G_NEWOUTB_FOLDER,
                              p_folder_uid            => G_NUM_NOP2,
                              p_account_id            => p_master_account_id,
                              p_account_type          => G_MASTER_ACCOUNT,
                              p_status                => G_CHAR_NOP,
                              p_customer_id           => l_customer_id,
                              p_rt_media_item_id      => l_m_sequence,
                              p_subject               => null,
                              p_interaction_id        => p_interaction_id,
                              p_service_request_id    => l_sr_id,
                              p_mc_parameter_id       => G_AUTOR_MC_PARA_ID,
                              p_service_request_action   => null,
                              p_contact_id            => l_contact_id,
                              p_lead_id               => null,
                              p_parent_ih_id          => l_parent_ih_id,
                              p_action_id             => G_NUM_NOP,
                              p_relationship_id       => l_relationship_id,
                              x_return_status         => l_return_status,
                              x_msg_count             => l_msg_count,
                              x_msg_data              => l_msg_data,
                              x_version               => l_version,
                              x_rt_media_item_id      => l_rt_media_item_id,
                              x_rt_interaction_id     => l_rt_interaction_id
                              );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      x_outbox_item_id := l_rt_media_item_id;

    ELSE
      -- return the error returned by IEM_CLIENT_PUB.createMediaDetails
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

    END IF;


  ELSE
  -- Return the error returned by MC_PARA_PUB API
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

  END IF;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                          p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO autoForward_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO autoForward_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN IEM_BAD_RECIPIENT  THEN
          ROLLBACK TO autoForward_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_RECIPIENT');
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_TRUE,
          p_count => x_msg_count,
          p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO autoForward_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);

END autoForward;

PROCEDURE createSRAutoNotification(
    p_api_version_number    IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_commit                IN   VARCHAR2,
    p_media_id              IN   NUMBER,
    p_master_account_id     IN   NUMBER,
    p_to_address_list       IN   VARCHAR2,
    p_cc_address_list       IN   VARCHAR2,
    p_bcc_address_list      IN   VARCHAR2,
    p_subject               IN   VARCHAR2,
    p_tag_key_value_tbl     IN   keyVals_tbl_type,
    p_customer_id           IN   NUMBER,
    p_interaction_id        IN   NUMBER,
    p_resource_id           IN   NUMBER,
    p_qualifiers            IN   QualifierRecordList,
    p_contact_id            IN   NUMBER,
    p_relationship_id       IN   NUMBER,
    p_message_id            IN   NUMBER,
    p_sr_id                 IN   NUMBER,
    x_outbox_item_id        OUT  NOCOPY NUMBER,
    x_return_status         OUT  NOCOPY VARCHAR2,
    x_msg_count             OUT  NOCOPY NUMBER,
    x_msg_data              OUT  NOCOPY VARCHAR2
    ) IS
  l_api_name               VARCHAR2(255):='createSRAutoNotification';
  l_api_version_number     NUMBER:=1.0;
  l_created_by             NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        NUMBER:=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      NUMBER:= NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_return_status          VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_version                NUMBER;
  l_rt_interaction_id      NUMBER;
  l_rt_media_item_id       NUMBER;
  l_tag_key_value          keyVals_tbl_type;
  l_customer_id            NUMBER := null;
  l_contact_id             NUMBER := null;
  l_parent_ih_id           NUMBER := null;
  l_interaction_id         NUMBER;
  l_ih_creator             VARCHAR2(1);
  l_resource_id            NUMBER;
  l_mc_parameter_id        NUMBER;
  l_qualifiers             IEM_MC_PUB.QualifierRecordList;
  l_relationship_id        NUMBER;
  l_outcome_id             NUMBER;
  l_result_id              NUMBER;
  l_reason_id              NUMBER;
  IEM_BAD_IH_ID            EXCEPTION;
BEGIN

-- Standard Start of API savepoint
   SAVEPOINT createSRAutoNotification_spt;

-- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       1.0,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
        FND_MSG_PUB.initialize;
   END IF;

-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-----------------------Code------------------------
    -- Extract tag key value from key value table
    -- Currently valid system key names:
    -- IEMNBZTSRVSRID for sr id ignore for auto sr cases
    -- IEMNINTERACTIONID for interaction id
    -- IEMNAGENTID for agent id
    -- IEMNCUSTOMERID for customer id
    -- IEMNCONTACTID for contact id
    -- IEMNRELATIONSHIPID for relationship id

    IF (p_tag_key_value_tbl.count > 0 ) THEN
      FOR i IN p_tag_key_value_tbl.FIRST..p_tag_key_value_tbl.LAST LOOP
       BEGIN
        IF (p_tag_key_value_tbl(i).key = 'IEMNINTERACTIONID' ) THEN
           l_parent_ih_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNCUSTOMERID' ) THEN
           l_customer_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNCONTACTID' ) THEN
           l_contact_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        ELSIF (p_tag_key_value_tbl(i).key = 'IEMNRELATIONSHIPID' ) THEN
           l_relationship_id := TO_NUMBER(p_tag_key_value_tbl(i).value);
        END IF;
       END;
      END LOOP;
    END IF;


-- customer id and contact id from tagging supersede the result from
-- email search i.e. what are from inputs
    IF (l_customer_id is NULL) THEN
      BEGIN
        l_customer_id := p_customer_id;
        l_contact_id := p_contact_id;
        l_relationship_id := p_relationship_id;
      END;
    END IF;

-- Find resource_id by searching outbox_processing_agent.
   l_resource_id := p_resource_id;

-- Record details into the RT tables.
   IF ( p_interaction_id = fnd_api.g_miss_num) THEN
     l_interaction_id := null;
     l_ih_creator := null;
   ELSE
     l_interaction_id := p_interaction_id;
     l_ih_creator := 'Y';
     begin
       select result_id, reason_id, outcome_id
       into l_result_id, l_reason_id, l_outcome_id
       from jtf_ih_interactions
       where interaction_id = p_interaction_id;
     exception
       when others then
         --dbms_output.put_line(SQLERRM);
         raise IEM_BAD_IH_ID;
     end;
   END IF;

-- create iem_mc_parameter record
  IF (p_qualifiers.count > 0)  THEN
    BEGIN
      FOR i IN p_qualifiers.first .. p_qualifiers.Last
      LOOP
        l_qualifiers(i).QUALIFIER_NAME := p_qualifiers(i).QUALIFIER_NAME;
        l_qualifiers(i).QUALIFIER_VALUE := p_qualifiers(i).QUALIFIER_VALUE;
      END LOOP;
    END;
  END IF;

  IEM_MC_PUB.prepareMessageComponentII
  (p_api_version_number    => 1.0,
   p_init_msg_list         =>fnd_api.g_false,
   p_commit                =>fnd_api.g_false,
   p_action                => 'srautonotification',
   p_master_account_id     => p_master_account_id,
   p_activity_id           => fnd_api.g_miss_num,
   p_to_address_list       => p_to_address_list,
   p_cc_address_list       => p_cc_address_list,
   p_bcc_address_list      => p_bcc_address_list,
   p_subject               => p_subject,
   p_sr_id                 => p_sr_id,
   p_customer_id           => l_customer_id,
   p_contact_id            => l_contact_id,
   p_mes_document_id       => fnd_api.g_miss_num,
   p_mes_category_id       => fnd_api.g_miss_num,
   p_interaction_id        => null,
   p_qualifiers            => l_qualifiers,
   p_message_type          => null, --p_message_type,
   p_encoding		           => null, --p_encoding,
   p_character_set         => null, --p_character_set,
   p_relationship_id       => l_relationship_id,
   x_mc_parameters_id      => l_mc_parameter_id,
   x_return_status         => l_return_status,
   x_msg_count             => l_msg_count,
   x_msg_data              => l_msg_data
  );


-- Check return status; Proceed on success Or report back in case of error.
  IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
  -- Success.


   select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
   INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, contact_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, parent_interaction_id,
                   service_request_id, inb_tag_id, interaction_id,
                   mc_parameter_id, ih_creator, action_id, action_item_id,
                   relationship_id, result_id, reason_id, outcome_id)
         VALUES (
                   l_i_sequence, l_resource_id, l_customer_id, l_contact_id,
                   G_INBOUND, 'S', G_ACTIVE, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   l_parent_ih_id, p_sr_id, null, l_interaction_id,
                   l_mc_parameter_id, l_ih_creator, 22, 45, l_relationship_id,
                   l_result_id, l_reason_id, l_outcome_id);

   select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
   INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login )
          VALUES (
                   l_i_sequence, l_m_sequence, l_resource_id,
                   p_media_id,
                   p_message_id,
                   null,
                   null,
                   null,
                   p_master_account_id,
                   null,
                   G_INBOUND, G_UNMOVED, G_ACTIVE,0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login );

  --create outbound here
  IEM_CLIENT_PUB.createMediaDetails (p_api_version_number    => 1.0,
                              p_init_msg_list         => fnd_api.g_false,
                              p_commit                => fnd_api.g_false,
                              p_resource_id           => l_resource_id,
                              p_rfc822_message_id     => null,
                              p_folder_name           => G_NEWOUTB_FOLDER,
                              p_folder_uid            => null,
                              p_account_id            => p_master_account_id,
                              p_account_type          => G_MASTER_ACCOUNT,
                              p_status                => G_CHAR_NOP,
                              p_customer_id           => l_customer_id,
                              p_rt_media_item_id      => l_m_sequence,
                              p_subject               => null,
                              p_interaction_id        => p_interaction_id,
                              p_service_request_id    => p_sr_id,
                              p_mc_parameter_id       => G_AUTOR_MC_PARA_ID,
                              p_service_request_action   => null,
                              p_contact_id            => l_contact_id,
                              p_lead_id               => null,
                              p_parent_ih_id          => null,
                              p_action_id             => G_NUM_NOP,
                              p_relationship_id       => l_relationship_id,
                              x_return_status         => l_return_status,
                              x_msg_count             => l_msg_count,
                              x_msg_data              => l_msg_data,
                              x_version               => l_version,
                              x_rt_media_item_id      => l_rt_media_item_id,
                              x_rt_interaction_id     => l_rt_interaction_id
                              );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      x_outbox_item_id := l_rt_media_item_id;

    ELSE
      -- return the error returned by IEM_CLIENT_PUB.createMediaDetails
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

    END IF;

  ELSE
      -- return the error returned by IEM_MC_PUB.prepareMessageComponentII
       x_return_status := l_return_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

  END IF;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
        p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_BAD_IH_ID THEN
          ROLLBACK TO createSRAutoNotification_spt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_IH_ID');
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createSRAutoNotification_spt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createSRAutoNotification_spt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO createSRAutoNotification_spt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_count => x_msg_count,
                                     p_data   => x_msg_data);
END createSRAutoNotification;


END IEM_OUTBOX_PROC_PUB;

/
