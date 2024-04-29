--------------------------------------------------------
--  DDL for Package Body IEM_CLIENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CLIENT_PUB" as
/* $Header: iempcltb.pls 120.14.12010000.4 2010/01/08 06:39:19 sanjrao ship $*/

-- PACKAGE CONSTANTS NO LITERALS USED.
G_PKG_NAME CONSTANT varchar2(30) :='IEM_CLIENT_PUB';
G_WORK_IN_PROGRESS CONSTANT VARCHAR2(1)   := 'P';
G_TRANSFER         CONSTANT VARCHAR2(1)   := 'R';
G_WRAP_UP          CONSTANT VARCHAR2(1)   := 'W';
G_INBOUND          CONSTANT VARCHAR2(1)   := 'I';
G_OUTBOUND         CONSTANT VARCHAR2(1)   := 'O';
G_EXPIRE           CONSTANT VARCHAR2(1)   := 'Y';
G_ACTIVE           CONSTANT VARCHAR2(1)   := 'N';
G_DORMANT          CONSTANT VARCHAR2(1)   := 'D';
G_QUEUEOUT         CONSTANT VARCHAR2(1)   := 'Q';
G_PROCESSING       CONSTANT VARCHAR2(1)   := 'G';
G_NUM_NOP          CONSTANT NUMBER        := -99;
G_NUM_NOP2         CONSTANT NUMBER        := -1;
G_CHAR_NOP         CONSTANT VARCHAR2(1)   := ' ';
G_UNREAD           CONSTANT VARCHAR2(1)   := 'U';
G_UNMOVED          CONSTANT VARCHAR2(1)   := 'M';
G_MASTER_ACCOUNT   CONSTANT VARCHAR2(1)   := 'M';
G_AGENT_ACCOUNT    CONSTANT VARCHAR2(1)   := 'A';
G_O_DIRECTION      CONSTANT VARCHAR2(10)  := 'OUTBOUND';
G_I_DIRECTION      CONSTANT VARCHAR2(10)  := 'INBOUND';
G_MEDIA_TYPE       CONSTANT VARCHAR2(10)  := 'EMAIL';
G_NEWREROUTE       CONSTANT VARCHAR2(1)   := 'H';
G_REDIRECT         CONSTANT VARCHAR2(1)   := 'R';

PROCEDURE getWork (p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_resource_id           IN   NUMBER,
                   p_email_account_id      IN   NUMBER,
                   p_classification_id     IN   NUMBER,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_rt_media_item_id      OUT NOCOPY  NUMBER,
                   x_email_account_id      OUT NOCOPY  NUMBER,
                   x_oes_id                OUT NOCOPY  NUMBER,
                   x_folder_name           OUT NOCOPY  VARCHAR2,
                   x_folder_uid            OUT NOCOPY  NUMBER,
                   x_rt_interaction_id     OUT NOCOPY  NUMBER,
                   x_customer_id           OUT NOCOPY  NUMBER,
                   x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                   x_route_classification  OUT NOCOPY  VARCHAR2,
                   x_mdt_message_id        OUT NOCOPY  NUMBER,
                   x_service_request_id    OUT NOCOPY  NUMBER,
                   x_contact_id            OUT NOCOPY  NUMBER,
                   x_classification_id     OUT NOCOPY  NUMBER,
                   x_lead_id               OUT NOCOPY  NUMBER,
                   x_relationship_id       OUT NOCOPY  NUMBER
                  )  IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_email_data_rec         IEM_RT_PROC_EMAILS%ROWTYPE;
  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_db_server_id           NUMBER;
  l_classification_id      NUMBER;
  l_tag_key_value_tbl      IEM_MAILITEM_PUB.keyVals_tbl_type;
  l_tag_id                 VARCHAR2(30);
  l_sr_id                  NUMBER;
  l_parent_ih_id           NUMBER;
  l_customer_id            NUMBER;
  l_contact_id             NUMBER;
  l_lead_id                NUMBER;
  l_ih_creator             VARCHAR2(1);
  l_t_number_tbl           IEM_MAILITEM_PUB.t_number_table;
  l_relationship_id        NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT getWork_pvt;

-- Initialize variables
  l_api_name           :='getWork';
  l_api_version_number :=1.0;
  l_created_by         :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by    :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login  := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_sr_id              :=null;
  l_parent_ih_id       :=null;
  l_customer_id        :=null;
  l_contact_id         :=null;
  l_lead_id            :=null;


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
/*  dbms_output.put_line('In getWork ');
    dbms_output.put_line('In getWork : Email Account ID '||p_email_account_id);
*/

--Future: Call Media Check [check if max interactions reached]

    --Set the l_classification_id to null if it is a NOP per 9i standard
    select decode(p_classification_id,G_NUM_NOP2, null,
			   p_classification_id) into l_classification_id from DUAL;

    --Call MailItem to get the next available message.
    IEM_MAILITEM_PUB.GetMailItem( p_api_version_number=> 1.0,
                                  p_init_msg_list  => 'F',
                                  p_commit         => 'F',
                                  p_resource_id       => p_resource_id ,
                                  p_tbl            => l_t_number_tbl,
                                  p_rt_classification => l_classification_id,
                                  p_account_id        => p_email_account_id,
                                  x_email_data        => l_email_data_rec,
                                  x_tag_key_value     => l_tag_key_value_tbl,
                                  x_encrypted_id      => l_tag_id,
                                  x_return_status     => l_status,
                                  x_msg_count         => l_msg_count,
                                  x_msg_data          => l_msg_data);

-- Check return status; Proceed on success Or report back in case of error.
    IF (l_status = FND_API.G_RET_STS_SUCCESS) THEN
    -- Success.
    -- Get the name of the route classification from the ID returned above.
    -- This is the name of the folder where the inbound message exists on the
    -- master account.
        SELECT name INTO x_route_classification
        FROM   iem_route_classifications
        WHERE  ROUTE_CLASSIFICATION_ID = l_email_data_rec.RT_CLASSIFICATION_ID;

    -- Set the folder name
        x_folder_name := x_route_classification;

    -- Extract tag key value from key value table
    -- Currently valid system key names:
    -- IEMNBZTSRVSRID for sr id
    -- IEMNINTERACTIONID for interaction id
    -- IEMNAGENTID for agent id
    -- IEMNCUSTOMERID for customer id
    -- IEMNCONTACTID for contact id
    -- IEMNBZSALELEADID for lead id

    FOR i IN 1..l_tag_key_value_tbl.count LOOP
       BEGIN
        IF (l_tag_key_value_tbl(i).key = 'IEMNBZTSRVSRID' ) THEN
           l_sr_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNINTERACTIONID' ) THEN
           l_parent_ih_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNCUSTOMERID' ) THEN
           l_customer_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNCONTACTID' ) THEN
           l_contact_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNRELATIONSHIPID' ) THEN
           l_relationship_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNBZSALELEADID' ) THEN
           l_lead_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        END IF;
       END;
    END LOOP;

-- customer id and contact id from tagging supersede the result from
-- email search (i.e. what are in l_email_date_rec)
    IF (l_customer_id is NULL) THEN
      BEGIN
        l_customer_id := l_email_data_rec.CUSTOMER_ID;
        l_contact_id := null;
        l_relationship_id := null;
      END;
    END IF;

-- Record details into the RT tables.
       l_ih_creator := null;
       if ( l_email_data_rec.IH_INTERACTION_ID is not null ) then
         l_ih_creator := 'S';  -- server created
       end if;

       select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
       INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, contact_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, parent_interaction_id,
                   service_request_id, inb_tag_id, interaction_id, ih_creator,
                   lead_id )
              VALUES (
                   l_i_sequence, p_resource_id, l_customer_id, l_contact_id,
                   G_INBOUND, G_WORK_IN_PROGRESS, G_ACTIVE, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   l_parent_ih_id, l_sr_id, l_tag_id,
                   l_email_data_rec.IH_INTERACTION_ID, l_ih_creator,
                   l_lead_id
              );
       -- db_server id used by mid-tier to locate accounts
       l_db_server_id := -1;

       select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
       INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login )
              VALUES (
                   l_i_sequence, l_m_sequence, p_resource_id,
                   l_email_data_rec.IH_MEDIA_ITEM_ID,
                   l_email_data_rec.MESSAGE_ID,
                   null,
                   x_folder_name,
                   -1,
                   l_email_data_rec.EMAIL_ACCOUNT_ID,
                   l_db_server_id,
                   G_INBOUND, G_UNMOVED, G_ACTIVE,0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login
              );

-- open the row at IEM_RT_PROC_EMAILS
       UPDATE IEM_RT_PROC_EMAILS SET queue_status = NULL
         WHERE message_id = l_email_data_rec.MESSAGE_ID;

-- Return Media Values to the JSPs.
       x_rt_media_item_id  := l_m_sequence;
       x_email_account_id  := l_email_data_rec.EMAIL_ACCOUNT_ID;
       x_oes_id            := l_db_server_id;
       x_folder_uid        := -1;
       x_customer_id       := l_customer_id;
       x_rfc822_message_id := null;
       x_rt_interaction_id := l_i_sequence;
       x_mdt_message_id    := l_email_data_rec.MESSAGE_ID;
       x_service_request_id := l_sr_id;
       x_contact_id        := l_contact_id;
       x_classification_id := l_email_data_rec.RT_CLASSIFICATION_ID;
       x_lead_id           := l_lead_id;
       x_relationship_id   := l_relationship_id;

    ELSE
-- Return the error returned by MDT API
       x_return_status := l_status;
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
			( p_encoded => FND_API.G_TRUE,
        p_count =>  x_msg_count,
        p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getWork_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getWork_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getWork_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END getWork;

/* Use cases. Get details of the specified rt_media_item
              OR
	      Get details of the rt_media_item related by
	      the interaction_id. The p_email_type is used
	      to specify the inbound or outbound media item
	      thats related to the one specified. If the
	      relational details are missing then the parent
	      details are returned enabling the JSPs to
	      create new rt_data.
*/
PROCEDURE getMediaDetails (p_api_version_number    IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_rt_media_item_id      IN   NUMBER,
                           p_version               IN   NUMBER,
                           p_email_type            IN   VARCHAR2,
                           x_return_status         OUT NOCOPY  VARCHAR2,
                           x_msg_count             OUT NOCOPY  NUMBER,
                           x_msg_data              OUT NOCOPY  VARCHAR2,
                           x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                           x_account_id            OUT NOCOPY  NUMBER,
                           x_account_type          OUT NOCOPY  VARCHAR2,
                           x_email_type            OUT NOCOPY  VARCHAR2,
                           x_status                OUT NOCOPY  VARCHAR2,
                           x_version               OUT NOCOPY  NUMBER,
                           x_rt_media_item_id      OUT NOCOPY  NUMBER,
                           x_rt_interaction_id     OUT NOCOPY  NUMBER,
                           x_oes_id                OUT NOCOPY  NUMBER,
                           x_folder_name           OUT NOCOPY  VARCHAR2,
                           x_message_id            OUT NOCOPY  NUMBER, -- change to iem_rt_proc_emails.message_id since 11.5.11
                           x_customer_id           OUT NOCOPY  NUMBER,
                           x_interaction_id        OUT NOCOPY   NUMBER,
                           x_service_request_id    OUT NOCOPY  NUMBER,
                           x_mc_parameter_id       OUT NOCOPY   NUMBER,
                           x_service_request_action   OUT NOCOPY   VARCHAR2,
                           x_contact_id            OUT NOCOPY   NUMBER,
                           x_parent_ih_id          OUT NOCOPY   NUMBER,
                           x_tag_id                OUT NOCOPY   VARCHAR2,
                           x_edit_mode             OUT NOCOPY   VARCHAR2,
                           x_lead_id               OUT NOCOPY   NUMBER,
                           x_resource_id           OUT NOCOPY   NUMBER,
                           x_relationship_id       OUT NOCOPY   NUMBER,
                           x_ih_media_id           OUT NOCOPY   NUMBER
                           ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;

  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;
  l_email_account_id1      NUMBER;
  l_agent_account_id1      NUMBER;
  l_account_id             NUMBER;
  l_account_type           VARCHAR2(3);
  l_email_type             VARCHAR2(3);
  l_status                 VARCHAR2(3);
  l_rfc822_message_id      VARCHAR2(300);
  l_version                NUMBER;
  l_rt_media_item_id       NUMBER;
  l_rt_interaction_id      NUMBER;
  l_oes_id                 NUMBER;
  l_message_id             NUMBER;
  l_customer_id            NUMBER;
  l_folder_name            VARCHAR2(300);
  l_inpEmail_type          VARCHAR2(2);
  l_expire                 VARCHAR2(1);
  l_edit_mode              VARCHAR2(1);

  InteractnComplt          EXCEPTION;
  badAccountType           EXCEPTION;
  IEM_NO_DATA              EXCEPTION;
  l_found                  NUMBER;
  l_ih_media_id            NUMBER;

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT getMediaDetails_pvt;

-- Init vars
  l_api_name               :='getMediaDetails';
  l_api_version_number     :=1.0;

  l_email_account_id       := 0;
  l_agent_account_id       := 0;
  l_email_account_id1      := 0;
  l_agent_account_id1      := 0;
  l_account_id             := 0;
  l_version                := 0;
  l_rt_media_item_id       := 0;
  l_rt_interaction_id      := 0;
  l_oes_id                 := 0;
  l_message_id             := 0;
  l_customer_id            := 0;
  l_found                  := 0;

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
 -- Do a query anyway to get media details of the specified rt_media_item.
 BEGIN
   SELECT rt_interaction_id, rt_media_item_id, rfc822_message_id,
          folder_name, message_id, email_account_id, agent_account_id,
          db_server_id, email_type, status, version, expire, edit_mode,
          media_id
   INTO   l_rt_interaction_id, l_rt_media_item_id, l_rfc822_message_id,
          l_folder_name, l_message_id, l_email_account_id, l_agent_account_id,
          l_oes_id, l_email_type, l_status, l_version, l_expire, l_edit_mode,
          l_ih_media_id
   FROM   iem_rt_media_items
   WHERE  rt_media_item_id = p_rt_media_item_id;

   -- Collect the data thats needed at a later stage.
   l_inpEmail_type := l_email_type;

   SELECT customer_id, contact_id, interaction_id, parent_interaction_id,
          service_request_id, service_request_action, mc_parameter_id,
          inb_tag_id, lead_id, resource_id, relationship_id
   INTO   x_customer_id, x_contact_id, x_interaction_id, x_parent_ih_id,
          x_service_request_id, x_service_request_action, x_mc_parameter_id, x_tag_id,
          x_lead_id, x_resource_id, x_relationship_id
   FROM   iem_rt_interactions
   WHERE  rt_interaction_id = l_rt_interaction_id;

 EXCEPTION
   WHEN OTHERS THEN
	   raise IEM_NO_DATA;
 END;


 -- Check if the email type matches,
 IF (UPPER(p_email_type) <> UPPER (l_email_type)) THEN

      -- if not, get details of the correct media type.
      BEGIN
           x_rt_media_item_id := null;
           SELECT rt_interaction_id, rt_media_item_id, rfc822_message_id,
                  folder_name, message_id, email_account_id, agent_account_id,
                  db_server_id, email_type, status, version, edit_mode, media_id
           INTO   x_rt_interaction_id, x_rt_media_item_id, x_rfc822_message_id,
                  x_folder_name, x_message_id, l_email_account_id1, l_agent_account_id1,
                  x_oes_id, x_email_type, x_status, x_version, x_edit_mode, x_ih_media_id
           FROM iem_rt_media_items
           WHERE rt_interaction_id = l_rt_interaction_id
           AND   email_type = p_email_type
 	         AND   expire in (G_ACTIVE, G_QUEUEOUT);
      EXCEPTION
          WHEN OTHERS THEN
               -- dbms_output.put_line(SQLERRM);
               NULL;
      END;

     -- The requested media type exists.
     if (x_rt_media_item_id IS NOT NULL) then
        l_email_account_id := l_email_account_id1;
        l_agent_account_id := l_agent_account_id1;
        l_found := 1;
     end if;
  END IF;

  IF ( l_found = 0 ) THEN
    -- Type matches. Populate return values from the data obtained in the initial query.
    -- Or the requested media type does not exist, return "parent's" details.
    if (l_expire <> G_EXPIRE) then
        x_rt_interaction_id := l_rt_interaction_id;
        x_rt_media_item_id  := l_rt_media_item_id;
        x_rfc822_message_id := l_rfc822_message_id;
        x_folder_name       := l_folder_name;
        x_message_id        := l_message_id;
        x_oes_id            := l_oes_id;
        x_email_type        := l_email_type;
        x_status            := l_status;
        x_version           := l_version;
        x_edit_mode         := l_edit_mode;
        x_ih_media_Id       := l_ih_media_id;
    else
    -- only un-expired data is displayed.
       raise IEM_NO_DATA;
    end if;
  END IF;

  -- dbms_output.put_line('p_version = ' || p_version ||' x_version = ' || x_version);
--Check for version mismatch. This is important only when requesting an outbound and
-- getting an outbound email.
  IF ((p_version <> x_version)           AND
      (UPPER(p_email_type) = G_OUTBOUND) AND
      (UPPER(l_inpEmail_type) = G_OUTBOUND))  THEN
         x_return_status := 'M';
  END IF;

-- set account type
  IF ((l_email_account_id IS NULL) AND (l_agent_account_id IS NOT NULL)) THEN
      x_account_id := l_agent_account_id;
      x_account_type := G_AGENT_ACCOUNT;
  ELSIF ((l_agent_account_id IS NULL) AND (l_email_account_id IS NOT NULL)) THEN
      x_account_id := l_email_account_id;
      x_account_type := G_MASTER_ACCOUNT;
  ELSIF ((l_agent_account_id IS NOT NULL) AND (l_email_account_id IS NOT NULL)) THEN
      x_account_id := l_agent_account_id;
      x_account_type := G_AGENT_ACCOUNT;
  ELSE
      raise badAccountType;
  END IF;

-------------------End Code------------------------
EXCEPTION
   WHEN IEM_NO_DATA THEN
      ROLLBACK TO getMediaDetails_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_TRUE,
          p_count => x_msg_count,
          p_data => x_msg_data);
   WHEN badAccountType THEN
      ROLLBACK TO getMediaDetails_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_ACCOUNT_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END getMediaDetails;

/* Provide rt details for emails found by searching OES through JMA
*/
PROCEDURE getSearchDetails (p_api_version_number    IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_agentAccount_id       IN   NUMBER,
                           p_message_id            IN   NUMBER,
                           p_folder_name           IN   VARCHAR2,
                           p_email_type            IN   VARCHAR2,
                           x_return_status         OUT NOCOPY  VARCHAR2,
                           x_msg_count             OUT NOCOPY  NUMBER,
                           x_msg_data              OUT NOCOPY  VARCHAR2,
                           x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                           x_account_id            OUT NOCOPY  NUMBER,
                           x_account_type          OUT NOCOPY  VARCHAR2,
                           x_email_type            OUT NOCOPY  VARCHAR2,
                           x_status                OUT NOCOPY  VARCHAR2,
                           x_version               OUT NOCOPY  NUMBER,
                           x_rt_media_item_id      OUT NOCOPY  NUMBER,
                           x_rt_interaction_id     OUT NOCOPY  NUMBER,
                           x_oes_id                OUT NOCOPY  NUMBER,
                           x_folder_name           OUT NOCOPY  VARCHAR2,
                           x_folder_uid            OUT NOCOPY  NUMBER,
                           x_customer_id           OUT NOCOPY  NUMBER,
                           x_route_classification  OUT NOCOPY  VARCHAR2,
                           x_route_classification_id  OUT NOCOPY  NUMBER,
                           x_mdt_message_id        OUT NOCOPY  NUMBER,
                           x_interaction_id        OUT NOCOPY   NUMBER,
                           x_service_request_id    OUT NOCOPY  NUMBER,
                           x_mc_parameter_id       OUT NOCOPY   NUMBER,
                           x_service_request_action   OUT NOCOPY   VARCHAR,
                           x_contact_id            OUT NOCOPY   NUMBER,
                           x_parent_interaction_id          OUT NOCOPY   NUMBER,
                           x_tag_id                OUT NOCOPY   VARCHAR,
                           x_lead_id               OUT NOCOPY  NUMBER
                           ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;

  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;
  l_rfc822_message_id      VARCHAR2(300);
  l_account_id             NUMBER;
  l_account_type           VARCHAR2(3);
  l_email_type             VARCHAR2(3);
  l_status                 VARCHAR2(3);
  l_version                NUMBER;
  l_rt_media_item_id       NUMBER;
  l_rt_interaction_id      NUMBER;
  l_oes_id                 NUMBER;
  l_customer_id            NUMBER;
  l_inpEmail_type          VARCHAR2(2);
  l_expire                 VARCHAR2(2);
  InteractnNotFnd          EXCEPTION;
  ExQ                      EXCEPTION;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT getSearchDetails_pvt;

-- Init vars
  l_api_name                :='getSearchDetails';
  l_api_version_number      :=1.0;
  l_email_account_id        := 0;
  l_agent_account_id        := 0;
  l_account_id              := 0;
  l_version                 := 0;
  l_rt_media_item_id        := 0;
  l_rt_interaction_id       := 0;
  l_oes_id                  := 0;
  l_customer_id             := 0;

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
 BEGIN
 -- Account id is always agent_account_id. Do not pass email_account_ids
    SELECT rt_interaction_id, rt_media_item_id, rfc822_message_id,
          folder_name, message_id, email_account_id, agent_account_id,
          db_server_id, email_type, status, version, expire
   INTO   x_rt_interaction_id, x_rt_media_item_id, x_rfc822_message_id,
          x_folder_name, x_mdt_message_id, l_email_account_id, l_agent_account_id,
          x_oes_id, x_email_type, x_status, x_version, l_expire
   FROM iem_rt_media_items
   WHERE agent_account_id = p_agentAccount_id
   AND   message_id  = p_message_id
   AND   email_type  = p_email_type
   AND   expire IN (G_ACTIVE, G_DORMANT, G_QUEUEOUT);

   x_folder_uid := -1;

   SELECT customer_id, contact_id, interaction_id, parent_interaction_id,
          service_request_id, service_request_action, inb_tag_id, lead_id
   INTO   x_customer_id, x_contact_id, x_interaction_id,
          x_parent_interaction_id, x_service_request_id,
          x_service_request_action, x_tag_id, x_lead_id
   FROM   iem_rt_interactions
   WHERE  rt_interaction_id = x_rt_interaction_id;

   SELECT rt_classification_id into x_route_classification_id
   FROM   IEM_RT_PROC_EMAILS
   WHERE  message_id = x_mdt_message_id;

   SELECT name into x_route_classification
   FROM   iem_route_classifications
   WHERE  ROUTE_CLASSIFICATION_ID = x_route_classification_id;

 EXCEPTION
   WHEN OTHERS THEN
      -- Couldn't find the email rt records.
        raise InteractnNotFnd;
 END;

 IF (l_expire = G_QUEUEOUT) THEN
    raise ExQ;
 END IF;


 x_account_id   := l_agent_account_id;
 x_account_type := G_AGENT_ACCOUNT;

-------------------End Code------------------------
EXCEPTION
   WHEN InteractnNotFnd THEN
        ROLLBACK TO getSearchDetails_pvt;
	-- Please keep this special status. Do not change it.
	-- This is all thats required to inform JSPs that the email
	-- does not exist.
        x_return_status := 'N';
        FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);

   WHEN ExQ THEN
        ROLLBACK TO getSearchDetails_pvt;
	-- Please keep this special status. Do not change it.
	-- This is all thats required to inform JSPs that the email
	-- is in pre-transfer condition.
        x_return_status := 'Q';
        FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getSearchDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getSearchDetails_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getSearchDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

END getSearchDetails;

/* Create RT, MDT and IH data for an email that arrives in the agents inbox
   and is discovered during a search.
*/
/*
PROCEDURE createUnprocMediaItm (p_api_version_number    IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_agentAccount_id       IN   NUMBER,
                           p_folder_uid            IN   NUMBER,
                           p_folder_name           IN   VARCHAR2,
                           p_email_type            IN   VARCHAR2,
                           p_sender_name           IN   VARCHAR2,
                           p_priority              IN   VARCHAR2,
                           p_msg_status            IN   VARCHAR2,
                           p_subject               IN   VARCHAR2,
                           p_sent_date             IN   DATE,
                           p_rfc822_message_id     IN   VARCHAR2,
                           p_language              IN   VARCHAR2,
                           p_content_type          IN   VARCHAR2,
                           p_mailer                IN   VARCHAR2,
                           p_organization          IN   VARCHAR2,
                           p_message_type          IN   VARCHAR2,
                           p_received_date         IN   DATE,
                           p_message_size          IN   NUMBER,
                           x_return_status         OUT NOCOPY  VARCHAR2,
                           x_msg_count             OUT NOCOPY  NUMBER,
                           x_msg_data              OUT NOCOPY  VARCHAR2,
                           x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                           x_account_id            OUT NOCOPY  NUMBER,
                           x_account_type          OUT NOCOPY  VARCHAR2,
                           x_email_type            OUT NOCOPY  VARCHAR2,
                           x_status                OUT NOCOPY  VARCHAR2,
                           x_version               OUT NOCOPY  NUMBER,
                           x_rt_media_item_id      OUT NOCOPY  NUMBER,
                           x_rt_interaction_id     OUT NOCOPY  NUMBER,
                           x_oes_id                OUT NOCOPY  NUMBER,
                           x_folder_name           OUT NOCOPY  VARCHAR2,
                           x_folder_uid            OUT NOCOPY  NUMBER,
                           x_customer_id           OUT NOCOPY  NUMBER,
                           x_route_classification  OUT NOCOPY  VARCHAR2,
                           x_route_classification_id  OUT NOCOPY  NUMBER,
                           x_mdt_message_id        OUT NOCOPY  NUMBER
					  ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;
  l_rt_classification_id   NUMBER;
  l_post_mdts_id           NUMBER;
  l_rfc822_message_id      VARCHAR2(300);
  l_account_id             NUMBER;
  l_account_type           VARCHAR2(3);
  l_email_type             VARCHAR2(3);
  l_email_user             VARCHAR2(100);
  l_domain                 VARCHAR2(100);
  l_status                 VARCHAR2(3);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(500);
  l_version                NUMBER;
  l_rt_media_item_id       NUMBER;
  l_rt_interaction_id      NUMBER;
  l_oes_id                 NUMBER;
  l_folder_name            VARCHAR2(300);
  l_folder_uid             NUMBER;
  l_customer_id            NUMBER;
  l_inpEmail_type          VARCHAR2(2);
  InteractnNotFnd          EXCEPTION;
  IHError                  EXCEPTION;

  l_media_rec              JTF_IH_PUB.MEDIA_REC_TYPE;
  l_media_id               NUMBER;
  l_media_lc_rec           JTF_IH_PUB.media_lc_rec_type;
  l_resource_id            NUMBER;
  x_milcs_id               NUMBER;
  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_db_server_id           NUMBER;
  l_classification_id      NUMBER;
  l_rt_classification_name IEM_ROUTE_CLASSIFICATIONS.NAME%TYPE;
  l_ih_subject             VARCHAR2(80);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT createUnprocMediaItm_pvt;

-- Init vars
  l_api_name               :='createUnprocMediaItm';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      :=NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

  l_email_account_id        := 0;
  l_agent_account_id        := 0;
  l_rt_classification_id    := 0;
  l_post_mdts_id            := 0;
  l_account_id              := 0;
  l_version                 := 0;
  l_rt_media_item_id        := 0;
  l_rt_interaction_id       := 0;
  l_oes_id                  := 0;
  l_folder_uid              := 0;
  l_customer_id             := 0;


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

-------------------End Code------------------------
EXCEPTION
   WHEN IHError THEN
        ROLLBACK TO createUnprocMediaItm_pvt;
        x_return_status := l_status;
        FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                   p_count => x_msg_count,
                                   p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createUnprocMediaItm_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createUnprocMediaItm_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO createUnprocMediaItm_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END createUnprocMediaItm;
*/

/* Can create an outbound email media item only
*/
PROCEDURE createMediaDetails (p_api_version_number    IN   NUMBER,
                              p_init_msg_list         IN   VARCHAR2,
                              p_commit                IN   VARCHAR2,
                              p_resource_id           IN   NUMBER,
                              p_rfc822_message_id     IN   VARCHAR2,
                              p_folder_name           IN   VARCHAR2,
                              p_folder_uid            IN   NUMBER,
                              p_account_id            IN   NUMBER,
                              p_account_type          IN   VARCHAR2,
                              p_status                IN   VARCHAR2,
                              p_customer_id           IN   NUMBER,
                              p_rt_media_item_id      IN   NUMBER,
                              p_subject               IN   VARCHAR2,
                              p_interaction_id        IN   NUMBER,
                              p_service_request_id    IN   NUMBER,
                              p_mc_parameter_id       IN   NUMBER,
                              p_service_request_action   IN   VARCHAR,
                              p_contact_id            IN   NUMBER,
                              p_lead_id               IN   NUMBER,
                              p_parent_ih_id          IN  NUMBER,
                              p_action_id             IN  NUMBER,
                              p_relationship_id       IN  NUMBER,
                              x_return_status         OUT NOCOPY  VARCHAR2,
                              x_msg_count             OUT NOCOPY  NUMBER,
                              x_msg_data              OUT NOCOPY  VARCHAR2,
                              x_version               OUT NOCOPY  NUMBER,
                              x_rt_media_item_id      OUT NOCOPY  NUMBER,
                              x_rt_interaction_id     OUT NOCOPY  NUMBER
                              ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_db_server_id           NUMBER;
  l_email_account_id       NUMBER;
  l_email_account_id_ih    NUMBER;
  l_agent_account_id       NUMBER;
  l_folder_name            VARCHAR2(300);
  l_rt_interaction_id      NUMBER;
  l_email_type             VARCHAR2(2);

  l_status                 VARCHAR2(255);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);
  l_media_rec              JTF_IH_PUB.MEDIA_REC_TYPE;
  l_media_id               NUMBER;
  badAccountType           EXCEPTION;
  badAccount               EXCEPTION;
  l_ob_media_id            NUMBER;
  l_ib_media_id            NUMBER;
  l_ih_subject             VARCHAR2(80);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT createMediaDetails_pvt;
-- Init vars
  l_api_name               :='createMediaDetails';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      :=NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_email_account_id        := 0;
  l_email_account_id_ih     := 0;
  l_agent_account_id        := 0;
  l_rt_interaction_id       := 0;
  l_email_type              := '';
  l_ib_media_id             := -1;

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
       l_db_server_id := -1;
-- Detemine the type of email account, master or agent
   if (UPPER(p_account_type) = G_MASTER_ACCOUNT) then
       l_email_account_id := p_account_id;
       l_email_account_id_ih := p_account_id;
       l_agent_account_id := null;

   elsif (UPPER(p_account_type) = G_AGENT_ACCOUNT) then

       l_agent_account_id := p_account_id;
       l_email_account_id := null;

       begin
       SELECT A.EMAIL_ACCOUNT_ID
       INTO   l_email_account_id_ih
       FROM   IEM_AGENTS A
       WHERE  A.agent_id = p_account_id;

       exception
         when others then
           raise badAccount;
       end;

   else
       raise badAccountType;
   end if;


-- Create an outbound media_item; errors, if any, from IH are
-- ignored as a second attempt will be made to create an
-- outbound media id in wrapUp
   l_media_rec.direction           := G_O_DIRECTION;
   l_media_rec.source_id           := l_email_account_id_ih;
   l_media_rec.start_date_time     := SYSDATE;
   l_media_rec.media_item_type     := G_MEDIA_TYPE;
   l_media_rec.media_item_ref      := p_rfc822_message_id;  -- what should we fill in here for 11.5.11?

-- Truncate to 80 characters
   IF lengthb(p_subject)>80 then
    l_ih_subject:=substrb(p_subject,1,80);
   ELSE
    l_ih_subject:=p_subject;
   END IF;
   l_media_rec.media_data          := l_ih_subject;

   JTF_IH_PUB.Open_MediaItem(p_api_version   => 1.0,
                             p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                             p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                             p_user_id       => l_created_by,
                             p_login_id      => l_last_update_login,
                             x_return_status => l_status,
                             x_msg_count     => l_msg_count,
                             x_msg_data      => l_msg_data,
                             p_media_rec     => l_media_rec,
                             x_media_id      => l_media_id
                            );
   IF ( l_status = FND_API.G_RET_STS_SUCCESS ) THEN
     l_ob_media_id := l_media_id;
   ELSE
     l_ob_media_id := null;
   END IF;

   IF (p_rt_media_item_id = G_NUM_NOP2 OR p_rt_media_item_id = fnd_api.g_miss_num
       OR p_rt_media_item_id is null) THEN

-- Pure outbound message as there is no associated rt_media_item_id.
-- Insert into rt tables.
      SELECT IEM_RT_INTERACTIONS_S1.nextval INTO l_i_sequence FROM DUAL;
      INSERT INTO iem_rt_interactions (
                  rt_interaction_id, resource_id, customer_id, type,
                  status, expire, created_by, creation_date, last_updated_by,
                  last_update_date, last_update_login, interaction_id,
                  service_request_id, mc_parameter_id, service_request_action,
                  contact_id, lead_id, parent_interaction_id,
                  action_id, relationship_id)
              VALUES (
                  l_i_sequence, p_resource_id,
                  decode(p_customer_id,-1, null, p_customer_id),
                  G_OUTBOUND, p_status, G_ACTIVE, l_created_by,
                  SYSDATE,l_last_updated_by, SYSDATE, l_last_update_login,
                  decode(p_interaction_id, G_NUM_NOP, null, p_interaction_id),
                  decode(p_service_request_id, G_NUM_NOP, null, p_service_request_id),
                  decode(p_mc_parameter_id, G_NUM_NOP, null, p_mc_parameter_id),
                  decode(p_service_request_action, G_CHAR_NOP, null, p_service_request_action),
                  decode(p_contact_id, G_NUM_NOP, null, p_contact_id),
                  decode(p_lead_id, G_NUM_NOP, null, p_lead_id),
                  decode(p_parent_ih_id, G_NUM_NOP, null, p_parent_ih_id),
                  decode(p_action_id, G_NUM_NOP, null, p_action_id),
                  decode(p_relationship_id, G_NUM_NOP, null, p_relationship_id)
              );

      select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
      INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id,agent_account_id,
                   db_server_id, email_type, status, expire,
                   version, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login
                   )
              VALUES (
                   l_i_sequence, l_m_sequence, p_resource_id, l_ob_media_id, null,
                   p_rfc822_message_id, p_folder_name,p_folder_uid,
                   l_email_account_id, l_agent_account_id, l_db_server_id,
                   G_OUTBOUND, p_status, G_ACTIVE, '0', l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login
              );

       x_version := 0;
       x_rt_media_item_id  := l_m_sequence;
       x_rt_interaction_id := l_i_sequence;

   ELSE

   -- reply to an inbound?, checking..
     SELECT rt_interaction_id, email_type, media_id
     INTO   l_rt_interaction_id, l_email_type, l_ib_media_id
     FROM   iem_rt_media_items
     WHERE  rt_media_item_id = p_rt_media_item_id
     AND    expire = G_ACTIVE
     FOR    UPDATE NOWAIT;

     IF (UPPER(l_email_type) = G_INBOUND) THEN

-- Draft/Reply to an existing Inbound.
        select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
        INSERT INTO iem_rt_media_items (
                      rt_interaction_id, rt_media_item_id, resource_id,
                      media_id, message_id, rfc822_message_id, folder_name,
                      folder_uid, email_account_id,agent_account_id,
                      db_server_id, email_type, status, expire,
                      version, created_by, creation_date, last_updated_by,
                      last_update_date, last_update_login
                      )
               VALUES (
                      l_rt_interaction_id, l_m_sequence, p_resource_id, l_ob_media_id,
                      null, p_rfc822_message_id, p_folder_name,p_folder_uid,
                      l_email_account_id, l_agent_account_id, l_db_server_id,
                      G_OUTBOUND, p_status, G_ACTIVE, '0', l_created_by, SYSDATE,
                      l_last_updated_by, SYSDATE, l_last_update_login
                 );

          x_version := 0;
          x_rt_media_item_id := l_m_sequence;
          x_rt_interaction_id := l_rt_interaction_id;
     ELSE
     -- Outbound Media Item. Cannot create a reply.
         x_return_status := FND_API.G_RET_STS_ERROR ;
         l_ib_media_id := -1;
     END IF;
   END IF;

   -- Write statistics data
   if ( l_ob_media_id is not null AND x_return_status = FND_API.G_RET_STS_SUCCESS) then
    IEM_MSG_STAT_PUB.createMSGStat(
    p_api_version_number    => 1.0,
    p_init_msg_list         => fnd_api.g_false,
    p_commit                => fnd_api.g_false,
    p_outBoundMediaID       => l_ob_media_id,
    p_inBoundMediaID        => l_ib_media_id,
    x_return_status         => l_status,
    x_msg_count             => l_msg_count,
    x_msg_data              => l_msg_data
    );
   end if;
-------------------End Code------------------------
EXCEPTION
   WHEN badAccount THEN
      ROLLBACK TO createMediaDetails_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_ACCOUNT');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

   WHEN badAccountType THEN
      ROLLBACK TO createMediaDetails_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_ACCOUNT_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO createMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END createMediaDetails;


PROCEDURE updateMediaDetails (p_api_version_number    IN   NUMBER,
                              p_init_msg_list         IN   VARCHAR2,
                              p_commit                IN   VARCHAR2,
                              p_rfc822_message_id     IN   VARCHAR2,
                              p_folder_name           IN   VARCHAR2,
                              p_folder_uid            IN   NUMBER,
                              p_account_id            IN   NUMBER,
                              p_account_type          IN   VARCHAR2,
                              p_status                IN   VARCHAR2,
                              p_customer_id           IN   NUMBER,
                              p_rt_media_item_id      IN   NUMBER,
                              p_version               IN   NUMBER,
                              p_interaction_id        IN   NUMBER,
                              p_service_request_id    IN   NUMBER,
                              p_mc_parameter_id       IN   NUMBER,
                              p_service_request_action   IN   VARCHAR2,
                              p_contact_id            IN   NUMBER,
                              p_parent_interaction_id IN   NUMBER,
                              p_tag_id                IN   VARCHAR2,
                              p_edit_mode             IN   VARCHAR2,
                              p_lead_id               IN   NUMBER,
                              p_relationship_id       IN   NUMBER,
                              x_return_status         OUT NOCOPY  VARCHAR2,
                              x_msg_count             OUT NOCOPY  NUMBER,
                              x_msg_data              OUT NOCOPY  VARCHAR2,
                              x_version               OUT NOCOPY  NUMBER
                              ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;

  l_email_account_id_old   NUMBER;
  l_agent_account_id_old   NUMBER;

  l_version                NUMBER;
  l_email_type             VARCHAR2(300);
  l_rt_interaction_id      NUMBER;

  l_media_lc_rec           JTF_IH_PUB.media_lc_rec_type;
  l_media_id               NUMBER;
  l_resource_id            NUMBER;
  x_milcs_id               NUMBER;
  badAccountType           EXCEPTION;
  illegalMesgMove          EXCEPTION;
  l_session_id             NUMBER;
  l_activity_id            NUMBER;
  l_count                  NUMBER;
  l_data                   VARCHAR2(300);
  l_ret_status             VARCHAR2(300);
  l_rt_status              VARCHAR2(10);
  l_msg_id                 NUMBER;
  l_edit_mode              VARCHAR2(1);
  l_uwq_act_code           VARCHAR2(32);
  l_ib_media_id            number;
  l_ob_media_id            number;
  l_rt_media_item_id_ib    number;
  l_type                   VARCHAR2(2);

  CURSOR sel_csr IS
    SELECT session_id from IEU_SH_SESSIONS
        WHERE BEGIN_DATE_TIME = (SELECT MAX(BEGIN_DATE_TIME)
                                 FROM IEU_SH_SESSIONS
                                 WHERE RESOURCE_ID = l_resource_id
                                 AND   ACTIVE_FLAG = 'T'
                                 AND   APPLICATION_ID = 680);
BEGIN

-- Standard Start of API savepoint
        SAVEPOINT updateMediaDetails_pvt;

-- Init vars
  l_api_name               :='updateMediaDetails';
  l_api_version_number      :=1.0;
  l_created_by              :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by         :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login       := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_email_account_id_old     := 0;
  l_agent_account_id_old     := 0;
  l_uwq_act_code           := null;
  l_ib_media_id              := -1;
  l_ob_media_id              := null;

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
/*  dbms_output.put_line('In getWork ');
  dbms_output.put_line('In getWork : Resource ID  '||p_resource_id);
*/

  SELECT rt_interaction_id, version, email_type, email_account_id,
	    agent_account_id, media_id, resource_id, status, message_id
  INTO   l_rt_interaction_id, l_version, l_email_type, l_email_account_id_old,
	    l_agent_account_id_old, l_media_id, l_resource_id, l_rt_status, l_msg_id
  FROM   iem_rt_media_items
  WHERE  rt_media_item_id = p_rt_media_item_id
  AND    expire in (G_ACTIVE, G_DORMANT, G_QUEUEOUT)
  FOR    update nowait;


  IF ((l_version = p_version) OR (UPPER(l_email_type) = G_INBOUND) ) THEN
     if (p_account_type = G_CHAR_NOP) then
        l_email_account_id := l_email_account_id_old;
        l_agent_account_id := l_agent_account_id_old;
     elsif (p_account_type = G_AGENT_ACCOUNT) then
        l_email_account_id := null;
        l_agent_account_id := p_account_id;
     elsif (p_account_type = G_MASTER_ACCOUNT) then
        l_agent_account_id := null;
        l_email_account_id := p_account_id;
     else
        raise badAccountType;
     end if;


-- Update IEM_RT_PROC_EMAILS mail_item_status to 'S' for 'Saved' inbound
     if (p_status = 'V') then

       if ( l_email_type = G_OUTBOUND ) then
         SELECT message_id
         INTO l_msg_id
         FROM iem_rt_media_items
         WHERE rt_interaction_id = l_rt_interaction_id
         AND email_type = G_INBOUND;
       end if;

      UPDATE IEM_RT_PROC_EMAILS SET mail_item_status = 'S' where message_id = l_msg_id;
     end if;

  -- Add email_open mlcs if it is an 'assign' or 'transfer' or 'autoroute'
    if (((l_rt_status = 'R') OR (l_rt_status = 'G') OR (l_rt_status = 'O')) AND
	   (p_status is not null) AND
	   (p_status <> 'R') AND
	   (UPPER(l_email_type) <> G_OUTBOUND)) then
-- Add MLCS.
	   l_media_lc_rec.start_date_time := SYSDATE;
     l_media_lc_rec.end_date_time := SYSDATE;
	   l_media_lc_rec.media_id        := l_media_id;
	   l_media_lc_rec.milcs_type_id   := 24; -- EMAIL_OPEN
	   l_media_lc_rec.resource_id     := l_resource_id;
	   l_media_lc_rec.handler_id      := 680;
	   JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
	          p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
					  p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
					  p_user_id       => l_created_by,
					  p_login_id      => l_last_update_login,
					  x_return_status => l_status,
					  x_msg_count     => l_msg_count,
					  x_msg_data      => l_msg_data,
					  x_milcs_id      => x_milcs_id,
					  p_media_lc_rec  => l_media_lc_rec);

-- Update IEM_RT_PROC_EMAILS mail_item_status to 'R' for 'Read'
      UPDATE IEM_RT_PROC_EMAILS SET mail_item_status = 'R' where message_id = l_msg_id;

      l_uwq_act_code := 'EMAIL_OPENED';

   else
     begin

	-- Add MLCS after move from master account to agent account
  -- Not add email_fetch mlcs if it is an 'assign' or 'transfer' or 'autoroute'
	-- Not add email_Transfer from agent1 - agent2 not allowed in this API.
	-- Check if new master account == null and new agent account is valid
	-- Err if move from master to master
	-- NOP if move from agent to master.

     if ((l_email_account_id_old IS NOT NULL ) AND
	    (l_email_account_id IS NULL) AND
      (p_status <> 'G') AND
	    (UPPER(l_email_type) <> G_OUTBOUND)) then
-- Add MLCS.
	   l_media_lc_rec.start_date_time := SYSDATE;
     l_media_lc_rec.end_date_time := SYSDATE;
	   l_media_lc_rec.media_id        := l_media_id;
	   l_media_lc_rec.milcs_type_id   := 18; -- EMAIL_FETCH
	   l_media_lc_rec.resource_id     := l_resource_id;
	   l_media_lc_rec.handler_id      := 680;
	   JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
	          p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
					  p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
					  p_user_id       => l_created_by,
					  p_login_id      => l_last_update_login,
					  x_return_status => l_status,
					  x_msg_count     => l_msg_count,
					  x_msg_data      => l_msg_data,
					  x_milcs_id      => x_milcs_id,
					  p_media_lc_rec  => l_media_lc_rec);

-- Update IEM_RT_PROC_EMAILS mail_item_status to 'R' for 'Read'
      UPDATE IEM_RT_PROC_EMAILS SET mail_item_status = 'R' where message_id = l_msg_id;

      l_uwq_act_code := 'EMAIL_FETCHED';

    end if;
    end; -- email_fetch
   end if;


-- Update version.
     if (UPPER(l_email_type) = G_INBOUND) then
	    l_version := 0;
     else
         l_version := p_version + 1;
     end if;

  --  BEGIN
     if ( p_edit_mode is null OR p_edit_mode = fnd_api.g_miss_char ) then
       l_edit_mode := G_CHAR_NOP;
     else
       l_edit_mode := p_edit_mode;
     end if;

     UPDATE iem_rt_media_items SET
       RFC822_MESSAGE_ID = decode(p_rfc822_message_id, G_CHAR_NOP, RFC822_MESSAGE_ID, p_rfc822_message_id),
       FOLDER_NAME       = decode(p_folder_name, G_CHAR_NOP, FOLDER_NAME, p_folder_name),
       FOLDER_UID        = decode(p_folder_uid, G_NUM_NOP, FOLDER_UID, p_folder_uid),
       EMAIL_ACCOUNT_ID  = decode(l_email_account_id,  G_NUM_NOP, EMAIL_ACCOUNT_ID, l_email_account_id),
       AGENT_ACCOUNT_ID  = decode(l_agent_account_id, G_NUM_NOP, AGENT_ACCOUNT_ID, l_agent_account_id),
       STATUS            = decode(p_status, G_CHAR_NOP, STATUS, p_status),
       VERSION           = l_version,
       LAST_UPDATED_BY   = l_last_updated_by,
       LAST_UPDATE_DATE  = SYSDATE,
       LAST_UPDATE_LOGIN = l_last_update_login,
       EDIT_MODE         = decode(l_edit_mode, G_CHAR_NOP, EDIT_MODE, l_edit_mode)
     WHERE rt_media_item_id = p_rt_media_item_id;
    -- EXCEPTION
      -- when others then
         -- dbms_output.put_line('In  UPDATE ' || SQLERRM);
    -- END;

 --   BEGIN
     UPDATE iem_rt_interactions SET
       CUSTOMER_ID = decode(p_customer_id, G_NUM_NOP, CUSTOMER_ID, p_customer_id),
       CONTACT_ID = decode(p_contact_id, G_NUM_NOP, contact_id, p_contact_id),
       RELATIONSHIP_ID = decode(p_relationship_id, G_NUM_NOP, relationship_id, p_relationship_id),
       INTERACTION_ID = decode(p_interaction_id, G_NUM_NOP, interaction_id, p_interaction_id),
       SERVICE_REQUEST_ID = decode(p_service_request_id, G_NUM_NOP, service_request_id, p_service_request_id),
       MC_PARAMETER_ID = decode(p_mc_parameter_id, G_NUM_NOP, mc_parameter_id, p_mc_parameter_id),
       SERVICE_REQUEST_ACTION = decode(p_service_request_action, G_CHAR_NOP, service_request_action, p_service_request_action),
       PARENT_INTERACTION_ID = decode(p_parent_interaction_id, G_NUM_NOP, parent_interaction_id, p_parent_interaction_id),
       INB_TAG_ID = decode(p_tag_id, G_CHAR_NOP, inb_tag_id, p_tag_id),
       LAST_UPDATED_BY   = l_last_updated_by,
       LAST_UPDATE_DATE  = SYSDATE,
       LAST_UPDATE_LOGIN = l_last_update_login,
       LEAD_ID = decode(p_lead_id, G_NUM_NOP, lead_id, p_lead_id)
     WHERE rt_interaction_id = l_rt_interaction_id;
    -- EXCEPTION
      -- when others then
         -- dbms_output.put_line('In  UPDATE ' || SQLERRM);
    -- END;

     x_version := l_version;

     -- Record UWQ interaction.
     if ( l_uwq_act_code is not null ) then

       BEGIN
        FOR sel_rec in sel_csr LOOP
            l_session_id := sel_rec.session_id;
            exit;
        END LOOP;

	      IEU_SH_PUB.UWQ_BEGIN_ACTIVITY(
                                      p_api_version        => 1.0,
                                      P_INIT_MSG_LIST      => 'F',
                                      P_COMMIT             => 'F',
                                      p_session_id         => l_session_id,
                                      p_activity_type_code => l_uwq_act_code,
                                      P_MEDIA_TYPE_ID      => null,
                                      P_MEDIA_ID           => null,
                                      p_user_id            => l_created_by,
                                      p_login_id           => l_last_update_login,
                                      P_REASON_CODE        => null,
                                      P_REQUEST_METHOD     => null,
                                      P_REQUESTED_MEDIA_TYPE_ID  => null,
                                      P_WORK_ITEM_TYPE_CODE      => null,
                                      P_WORK_ITEM_PK_ID    => null,
							                        p_end_activity_flag  => 'Y',
                                      x_activity_id        => l_activity_id,
                                      x_msg_count          => l_count,
                                      x_msg_data           => l_data,
                                      x_return_status      => l_ret_status
                                      );

        EXCEPTION
           WHEN OTHERS THEN
                 NULL;
        END;
      end if; -- check l_uwq_act_code
  ELSE
-- Version mismatch. Cannot update.
      x_return_status := 'M';
  END IF;

  -- write statistics data
  begin
      select media_id into l_ob_media_id
      from iem_rt_media_items
      where rt_interaction_id = l_rt_interaction_id and email_type = G_OUTBOUND;
  exception
      when others then
          null;
  end;
  if (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_ob_media_id is not null) then

    if ( p_status = 'V' OR p_status = 'C') then
      l_rt_media_item_id_ib := null;
      begin
        select rt_media_item_id, media_id into l_rt_media_item_id_ib, l_ib_media_id
        from iem_rt_media_items
        where rt_interaction_id = l_rt_interaction_id and email_type = G_INBOUND;
      exception
        when others then
          null;
      end;
    end if;
    if ( p_status = 'V') then
      IEM_MSG_STAT_PUB.saveMSGStat(
      p_api_version_number    => 1.0,
      p_init_msg_list         => fnd_api.g_false,
      p_commit                => fnd_api.g_false,
      p_outBoundMediaID       => l_ob_media_id,
      p_inBoundMediaID        => nvl(l_ib_media_id, -1),
      x_return_status         => l_ret_status,
      x_msg_count             => l_count,
      x_msg_data              => l_data
      );
    end if;
    if ( p_status = 'C') then
      if ( l_rt_media_item_id_ib is null ) then  -- pure outbound
        IEM_MSG_STAT_PUB.deleteMSGStat(
        p_api_version_number    => 1.0,
        p_init_msg_list         => fnd_api.g_false,
        p_commit                => fnd_api.g_false,
        p_outBoundMediaID       => l_ob_media_id,
        p_inBoundMediaID        => -1,
        x_return_status         => l_ret_status,
        x_msg_count             => l_count,
        x_msg_data              => l_data
        );
      else
        IEM_MSG_STAT_PUB.cancelMSGStat(
        p_api_version_number    => 1.0,
        p_init_msg_list         => fnd_api.g_false,
        p_commit                => fnd_api.g_false,
        p_outBoundMediaID       => l_ob_media_id,
        p_inBoundMediaID        => nvl(l_ib_media_id, -1),
        x_return_status         => l_ret_status,
        x_msg_count             => l_count,
        x_msg_data              => l_data
        );

      end if;
    end if; -- 'Cancel'
  end if;

-- Expire iem_rt_media_items and iem_rt_interactions if status is 'Cancel'
-- for pure outbound items.
   if (p_status = 'C') then

     SELECT type INTO l_type FROM iem_rt_interactions
     WHERE rt_interaction_id = l_rt_interaction_id;

     if ( l_type = G_OUTBOUND ) then

       UPDATE iem_rt_media_items SET expire = G_EXPIRE
       WHERE rt_media_item_id = p_rt_media_item_id;

       UPDATE iem_rt_interactions SET expire = G_EXPIRE
       WHERE rt_interaction_id = l_rt_interaction_id;

     end if;
   end if;

-------------------End Code------------------------

EXCEPTION
   WHEN badAccountType THEN
      ROLLBACK TO updateMediaDetails_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_ACCOUNT_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO updateMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO updateMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO updateMediaDetails_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END updateMediaDetails;

PROCEDURE getIHID  (p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_action                IN   VARCHAR2,
                   p_action_id             IN   NUMBER,
                   p_rt_media_item_id      IN   NUMBER,
                   p_version               IN   NUMBER,
                   p_customer_id           IN   NUMBER,
                   p_activity_type_id      IN   NUMBER,
                   p_outcome_id            IN   NUMBER,
                   p_result_id             IN   NUMBER,
                   p_reason_id             IN   NUMBER,
                   p_resource_id           IN   NUMBER,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_interaction_id        OUT NOCOPY  NUMBER,
                   x_sr_id                 OUT NOCOPY  NUMBER,
                   x_lead_id               OUT NOCOPY  NUMBER
                   ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_result_id              NUMBER;
  l_reason_id              NUMBER;

  IHError                  EXCEPTION;

  l_rt_interaction_id      NUMBER;
  l_interaction_id         NUMBER;
  l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
  l_customer_id            NUMBER;
  l_contact_id             NUMBER;
  l_resource_id            NUMBER;
  l_start_date             DATE;
  l_creation_date          DATE;
  l_session_id             NUMBER;
  l_count                  NUMBER;
  l_data                   VARCHAR2(300);
  l_ret_status             VARCHAR2(300);
  l_parent_ih_id           NUMBER;
  l_relationship_id        NUMBER;
  l_party_type             VARCHAR2(32);
  l_ih_customer_id         NUMBER;
  l_primary_customer_id    NUMBER;

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT getIHID_pvt;

-- Init vars
  l_api_name               :='getIHID';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      :=NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

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
-- Check if we already have an Interaction opened, if so return it
  SELECT a.rt_interaction_id, decode(a.interaction_id, -1, NULL, a.interaction_id),
         a.resource_id, a.creation_date,
         decode(a.parent_interaction_id, NULL, fnd_api.g_miss_num, a.parent_interaction_id),
         a.service_request_id, a.lead_id, a.contact_id, a.relationship_id
  INTO   l_rt_interaction_id, l_interaction_id, l_resource_id, l_start_date,
         l_parent_ih_id, x_sr_id, x_lead_id, l_contact_id, l_relationship_id
  FROM   iem_rt_interactions a, iem_rt_media_items b
  WHERE  b.rt_media_item_id = p_rt_media_item_id
  AND    a.rt_interaction_id = b.rt_interaction_id
  AND    a.expire <> G_EXPIRE;

  l_ih_customer_id := p_customer_id;

  select PARTY_TYPE into l_party_type from HZ_PARTIES
  where party_id = p_customer_id;

  if ( l_party_type = 'PERSON' ) then
    l_primary_customer_id := l_ih_customer_id;
    l_contact_id := l_ih_customer_id;
    l_relationship_id := null;

  elsif ( l_party_type = 'ORGANIZATION') then
    l_primary_customer_id := l_ih_customer_id;

    if ( l_contact_id > 0 ) then
      if ( (l_relationship_id < 0)  OR (l_relationship_id is null)) then
	 -- donot make contact id as null  ranjan 11/21/08
       -- l_contact_id := null;
        l_relationship_id := null;
      end if;
    else
      l_contact_id := null;
      l_relationship_id := null;
    end if;

  else       -- use old method  PARTY_RELATIONSHIP
    l_primary_customer_id := null;
    l_contact_id := null;
    l_relationship_id := null;
  end if;
-- end of ih customer info


-- Open IH
  IF (l_interaction_id IS NULL) THEN

     select decode(p_result_id,-1, NULL, p_result_id) into l_result_id from DUAL;
     select decode(p_reason_id,-1, NULL, p_reason_id) into l_reason_id from DUAL;
     if (l_parent_ih_id < 0) then
	  l_parent_ih_id := null;
     end if;

     l_interaction_rec.start_date_time   := l_start_date;
     l_interaction_rec.end_date_time     := SYSDATE;
     l_interaction_rec.resource_id       := l_resource_id;
     l_interaction_rec.party_id          := l_ih_customer_id;
     l_interaction_rec.primary_party_id  := l_primary_customer_id;
     l_interaction_rec.contact_party_id  := l_contact_id;
     l_interaction_rec.contact_rel_party_id := l_relationship_id;
     l_interaction_rec.outcome_id        := p_outcome_id;
     l_interaction_rec.result_id         := l_result_id;
     l_interaction_rec.handler_id        := 680; -- IEM APPL_ID
     l_interaction_rec.reason_id         := l_reason_id;
     l_interaction_rec.parent_id         := l_parent_ih_id;

     JTF_IH_PUB.Open_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                  p_user_id         => l_created_by,
                                  p_login_id        => l_last_update_login,
                                  x_return_status   => l_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  x_interaction_id  => l_interaction_id,
                                  p_interaction_rec => l_interaction_rec
                                 );

     if(l_status <> FND_API.G_RET_STS_SUCCESS) then
	     raise IHError;
     end if;

    UPDATE iem_rt_interactions set interaction_id = l_interaction_id,
           ih_creator = 'Y'
    WHERE rt_interaction_id = l_rt_interaction_id;
   END IF;

   x_interaction_id := l_interaction_id;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN IHError THEN
        ROLLBACK TO getIHID_pvt;
	   x_return_status := l_status;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
               p_count => x_msg_count,
							p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getIHID_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getIHID_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO getIHID_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END getIHID;


PROCEDURE wrapUp  (p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_action                IN   VARCHAR2,
                   p_action_id             IN   NUMBER,
                   p_rt_media_item_id      IN   NUMBER,
                   p_version               IN   NUMBER,
                   p_customer_id           IN   NUMBER,
                   p_activity_type_id      IN   NUMBER,
                   p_outcome_id            IN   NUMBER,
                   p_result_id             IN   NUMBER,
                   p_reason_id             IN   NUMBER,
                   p_to_resource_id        IN   NUMBER,
                   p_subject               IN   VARCHAR2,
                   p_to_address            IN   VARCHAR2,
                   p_transfer_msg_flag     IN   VARCHAR2,
                   p_to_account_id         IN   NUMBER,
                   p_to_classi_id          IN   NUMBER,
                   p_reroute_type          IN   NUMBER,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2
                   ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_activity_type_id       NUMBER;
  l_result_id              NUMBER;
  l_reason_id              NUMBER;

  unrecognizedAction       EXCEPTION;
  IHError                  EXCEPTION;
  MDTError                 EXCEPTION;
  badResourceId            EXCEPTION;
  RTError                  EXCEPTION;

  l_action_id_i            NUMBER;
  l_action_id_o            NUMBER;

  l_rt_interaction_id      NUMBER;
  l_interaction_id         NUMBER;
  l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
  l_customer_id            NUMBER;
  l_resource_id            NUMBER;
  l_start_date             DATE;
  l_ob_media_id            NUMBER;
  l_ib_media_id            NUMBER;
  l_rfc822_message_id      VARCHAR2(300);
  l_creation_date          DATE;
  l_media_lc_rec           JTF_IH_PUB.media_lc_rec_type;
  l_media_rec              JTF_IH_PUB.media_rec_type;
  x_milcs_id               NUMBER;
  x_activity_id_i          NUMBER;
  x_activity_id_o          NUMBER;
  l_activity_rec           JTF_IH_PUB.activity_rec_type;
  l_mdt_message_id         NUMBER;
  l_session_id             NUMBER;
  l_activity_id            NUMBER;
  l_count                  NUMBER;
  l_data                   VARCHAR2(300);
  l_ret_status             VARCHAR2(300);
  l_activity_type          VARCHAR2(200);
  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;
  l_pureOb                 NUMBER;  -- 0 pure ob; 1 relpy to an ib.

  l_sr_id                  NUMBER;
  l_lead_id                NUMBER;
  l_sr_action              VARCHAR2(8);
  l_action_item_id         NUMBER;
  l_action_id              NUMBER;
  l_action_id_sr           NUMBER;
  l_ih_creator             VARCHAR2(1);
  l_ob_action_id           NUMBER;
  l_parent_ih_id           NUMBER;

  l_email_type             VARCHAR2(1);
  l_the_rt_media_item_id   NUMBER;

  m_rt_media_item_id   number;
  l_reroute_to_acct    number;
  l_reroute_to_classi  number;
  l_reroute_to_folder  varchar2(255);
  m_uid                number;
  m_reroute_type       number;
  IEM_BAD_REROUTE_CLASSI exception;
  IEM_BAD_REROUTE_TYPE exception;
  RerouteError         exception;
  l_message_flag       varchar2(1);
  l_contact_id         number;
  l_autoReplied        varchar2(1);
  l_outb_method        number;
  l_to_resource_id     number;
  l_uid                number;
  IEM_REDIRECT_EX      EXCEPTION;
  l_spv_resource_id    number;
  l_to_group_id        number;
  l_ih_contact_id      number;
  l_party_type         varchar2(20);
  l_relationship_id    number;
  l_primary_customer_id number;
  l_ih_customer_id     number;
  l_rt_ih_status       varchar2(2);
  l_use_suggested      number;
  l_ih_subject         varchar2(80);
  l_reroute_resource_id number;
  l_outb_message_id    number;
  l_mc_param_action    varchar2(20);
  l_mc_parameter_id    number;
  l_i_sequence         number;
  l_m_sequence         number;
  l_tran_lead_id       number;
  l_tran_to_acct_id    number;

  CURSOR sel_csr IS
    SELECT session_id from IEU_SH_SESSIONS
        WHERE BEGIN_DATE_TIME = (SELECT MAX(BEGIN_DATE_TIME)
                                 FROM IEU_SH_SESSIONS
                                 WHERE RESOURCE_ID = l_resource_id
                                 AND   ACTIVE_FLAG = 'T'
                                 AND   APPLICATION_ID = 680);

BEGIN
-- Standard Start of API savepoint
        SAVEPOINT wrapUp_pvt;
-- Init vars
  l_api_name                :='wrapUp';
  l_api_version_number      :=1.0;
  l_created_by              :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by         :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login       := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_ob_action_id            := 0;
  l_reroute_to_classi       := null;
  l_mc_param_action         := ' ';

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

--- truncate to 80 characters
         IF lengthb(p_subject)>80 then
           l_ih_subject:=substrb(p_subject,1,80);
         ELSE
           l_ih_subject:=p_subject;
         END IF;


-- Get the values that are needed later.
  SELECT rt_interaction_id, agent_account_id, email_account_id
  INTO   l_rt_interaction_id, l_agent_account_id, l_email_account_id
  FROM   iem_rt_media_items
  WHERE  rt_media_item_id = p_rt_media_item_id
  AND    expire in (G_ACTIVE, G_QUEUEOUT)
  FOR UPDATE;

  l_ib_media_id := null;
  l_mdt_message_id := null;
  BEGIN
    SELECT media_id, message_id, folder_uid
    INTO   l_ib_media_id, l_mdt_message_id, l_uid
    FROM   iem_rt_media_items
    WHERE  rt_interaction_id = l_rt_interaction_id
    AND    expire in (G_ACTIVE, G_QUEUEOUT)
    AND    email_type = G_INBOUND;
  EXCEPTION
    WHEN OTHERS THEN
        NULL;
  END;

-- for redirect wrapup is just to call redirect API then expire the rt items.
   if (p_action = G_REDIRECT) then
     IEM_REROUTE_PUB.IEM_MAIL_REDIRECT_ACCOUNT(
                     p_api_version_number =>1.0,
                     p_init_msg_list  => FND_API.G_FALSE,
                     p_commit         => FND_API.G_FALSE,
                     p_msgid          => l_mdt_message_id,
                     p_email_account_id => l_email_account_id,
                     p_uid            => l_uid,
                     x_msg_count      => l_msg_count,
                     x_return_status  => l_status,
                     x_msg_data       => l_msg_data
                     );
     if ( l_status = FND_API.G_RET_STS_ERROR ) then
       raise IEM_REDIRECT_EX;
     end if;

     UPDATE iem_outbox_errors SET expire = G_EXPIRE
     WHERE rt_media_item_id = p_rt_media_item_id;

     update iem_rt_interactions set expire = G_EXPIRE
     where rt_interaction_id = l_rt_interaction_id;

     update iem_rt_media_items set expire = G_EXPIRE
     where rt_media_item_id =  p_rt_media_item_id;

     goto end_of_wrapup;

   end if;


  BEGIN
  SELECT decode(interaction_id, -1, null, interaction_id),
         ih_creator, service_request_id, service_request_action,
         decode(parent_interaction_id, NULL, fnd_api.g_miss_num, parent_interaction_id),
         lead_id, nvl(action_id, -1), nvl(contact_id, -1), nvl(to_resource_id, -1),
         relationship_id, status, mc_parameter_id
  INTO   l_interaction_id, l_ih_creator, l_sr_id, l_sr_action, l_parent_ih_id,
         l_lead_id, l_action_id, l_contact_id, l_to_resource_id, l_relationship_id,
         l_rt_ih_status, l_mc_parameter_id
  FROM   iem_rt_interactions
  WHERE  rt_interaction_id = l_rt_interaction_id
  AND    expire in (G_ACTIVE, G_QUEUEOUT, G_PROCESSING);
  EXCEPTION
    WHEN OTHERS THEN
        NULL;
  END;

  if (l_mc_parameter_id > 0) then
    select action into l_mc_param_action
    from iem_mc_parameters where mc_parameter_id = l_mc_parameter_id;
  end if;

  -- set contact id for IH recording.
  l_ih_customer_id := p_customer_id;

  select PARTY_TYPE into l_party_type from HZ_PARTIES
  where party_id = p_customer_id;

  if ( l_party_type = 'PERSON' ) then
    l_primary_customer_id := l_ih_customer_id;
    l_ih_contact_id := l_ih_customer_id;
    l_relationship_id := null;

  elsif ( l_party_type = 'ORGANIZATION') then
    l_primary_customer_id := l_ih_customer_id;

    if ( l_contact_id > 0 ) then
      if ( l_relationship_id > 0 ) then
        l_ih_contact_id := l_contact_id;
      else
        l_ih_contact_id := null;
        l_relationship_id := null;
      end if;
    else
      l_ih_contact_id := null;
      l_relationship_id := null;
    end if;

  else -- use old method  PARTY_RELATIONSHIP
    l_primary_customer_id := null;
    l_ih_contact_id := null;
    l_relationship_id := null;
  end if;
  -- end of ih customer info

  if(l_ib_media_id > 0) then
    l_pureOb := 1;  -- reply to a message
  else
    l_pureOb := 0; -- a pure ob message
  end if;

  l_ob_media_id := null;
  BEGIN
     SELECT media_id, message_id, creation_date
     INTO   l_ob_media_id, l_outb_message_id, l_creation_date
     FROM   iem_rt_media_items
     WHERE  rt_interaction_id = l_rt_interaction_id
     AND    expire in (G_ACTIVE, G_QUEUEOUT)
     AND    email_type = G_OUTBOUND;
  EXCEPTION
     WHEN OTHERS THEN
       NULL;
  END;

  if (l_agent_account_id IS NOT NULL) then
      SELECT email_account_id
      INTO   l_email_account_id
      FROM   IEM_AGENTS
      WHERE  agent_id = l_agent_account_id;
  end if;

  SELECT customer_id, resource_id, creation_date, nvl(spv_resource_id, -1)
  INTO   l_customer_id, l_resource_id, l_start_date, l_spv_resource_id
  FROM   iem_rt_interactions
  WHERE  rt_interaction_id = l_rt_interaction_id;

  -- use supervisor resource id if exists
  l_reroute_resource_id := l_resource_id;
  if ( l_spv_resource_id > 0 ) then
    l_resource_id := l_spv_resource_id;
  end if;

  select decode(p_activity_type_id,-1, NULL, p_activity_type_id) into l_activity_type_id from DUAL;
  select decode(p_result_id,-1, NULL, p_result_id) into l_result_id from DUAL;
  select decode(p_reason_id,-1, NULL, p_reason_id) into l_reason_id from DUAL;

  IF (l_action_id < 0) THEN
    l_action_id := p_action_id;
  END IF;

  IF (UPPER(p_action) = 'S') THEN
     if (l_pureOb = 0) then
         -- EMAIL_AUTO_ACK 83, EMAIL_FORWARD 84, EMAIL_FORWARD 85, EMAIL_RESEND 86
         if ( l_action_id = 83 ) then
           l_action_id_o := 29; -- EMAIL_ACKNOWLEDGED
         elsif ( l_action_id = 84 OR l_action_id = 85 OR l_action_id = 86) then
           l_action_id_o := 2; -- EMAIL_SENT (media life cycle segment)
         else
           l_action_id_o := 26; -- EMAIL_COMPOSE
         end if;

         l_activity_type := 'EMAIL_COMPOSED';
     else
         begin
           if (l_action_id = 74) then
             l_action_id_i := 41;   --EMAIL_AUTO_REPLY (media life cycle segment)
           else
             l_action_id_i := 19; -- EMAIL_REPLY
           end if;
         end;

         l_action_id_o := 2; -- EMAIL_SENT (media life cycle segment)
         l_activity_type := 'EMAIL_RESPONDED';
	       l_ob_action_id := 22;
     end if;
  ELSIF (UPPER(p_action) = 'D') THEN
     l_action_id_i := 6;
     l_action_id_o := 6;
     l_activity_type := 'EMAIL_DELETED';
  ELSIF (UPPER(p_action) = 'T') THEN

     if (p_transfer_msg_flag = 'E') then
       l_action_id_i := 44; -- EMAIL_ESCALATED
       l_action_id_o := 44;
     else
       l_action_id_i := 7;  -- EMAIL_TRANFERRED
       l_action_id_o := 7;
     end if;

     l_activity_type := 'EMAIL_TRANSFERRED';
  --
  -- Reroute: action_id: new "Email Rerouted Diff Acct"
  -- action_id: new "Email Rerouted Diff Class"
  -- action_id: new "Email Requeued"
  -- Re-direct: action_id: new "Email Auto Redirected"
  -- Note: l_activity_type is for IEU activity.
  ELSIF (UPPER(p_action) = 'X') THEN
    BEGIN
     -- determine which type of reroute it is here:
     -- find the record with reroute info (to account id and to classification id)

       l_reroute_to_acct := p_to_account_id;
       l_reroute_to_classi := p_to_classi_id;
       m_reroute_type := p_reroute_type;

       -- Set action id based on reroute type
       if ( m_reroute_type = 78) then
           l_action_id_i := 37; --EMAIL_REROUTED_DIFF_ACCT
           l_action_id_o := 37;
           l_activity_type := 'EMAIL_REROUTED';
       elsif ( m_reroute_type = 77 ) then
           l_action_id_i := 38; --EMAIL_REROUTED_DIFF_CLASS
           l_action_id_o := 38;
           l_activity_type := 'EMAIL_REROUTED';
       elsif ( m_reroute_type = 76 ) then
           l_action_id_i := 39; --EMAIL_REQUEUED
           l_action_id_o := 39;
           l_activity_type := 'EMAIL_REROUTED';
           l_reroute_to_classi := null;
       else
            raise IEM_BAD_REROUTE_TYPE;
       end if;
    END;
  ELSIF (UPPER(p_action) = 'V') THEN  -- For Email Resolve
         l_activity_type := 'EMAIL_RESPONDED';
  ELSE
     raise unrecognizedAction;
  END IF;

  IF (l_interaction_id IS NULL) THEN
     l_ih_creator := 'Y';

     l_interaction_rec.start_date_time   := l_start_date;
     l_interaction_rec.end_date_time     := SYSDATE;
     l_interaction_rec.resource_id       := l_resource_id;
     l_interaction_rec.party_id          := l_ih_customer_id;
     l_interaction_rec.primary_party_id  := l_primary_customer_id;
     l_interaction_rec.contact_party_id  := l_ih_contact_id;
     l_interaction_rec.contact_rel_party_id := l_relationship_id;
     l_interaction_rec.outcome_id        := p_outcome_id;
     l_interaction_rec.result_id         := l_result_id;
     l_interaction_rec.handler_id        := 680; -- IEM APPL_ID
     l_interaction_rec.reason_id         := l_reason_id;
     l_interaction_rec.parent_id         := l_parent_ih_id;

     JTF_IH_PUB.Open_Interaction( p_api_version     => 1.1,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                  p_user_id         => l_created_by,
                                  p_login_id        => l_last_update_login,
                                  x_return_status   => l_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  x_interaction_id  => l_interaction_id,
                                  p_interaction_rec => l_interaction_rec
                                 );

     UPDATE iem_rt_interactions set IH_CREATOR = 'Y', interaction_id = l_interaction_id
     WHERE rt_interaction_id = l_rt_interaction_id;

     if(l_status <> FND_API.G_RET_STS_SUCCESS) then
	  raise IHError;
     end if;
   END IF;

/* Ranjan
--set doc_id and doc_type

   IF NOT (l_sr_id IS NULL) THEN
     l_activity_rec.doc_id := l_sr_id;
     l_activity_rec.doc_ref := 'SR';
   END IF;

   IF ( l_action_id = 84 OR l_action_id =85 OR l_action_id =86) THEN
     -- resend/forward/re-reply need to copy doc_id and doc_ref from parent
     begin
       SELECT doc_id, doc_ref into l_activity_rec.doc_id, l_activity_rec.doc_ref
       FROM JTF_IH_ACTIVITIES WHERE INTERACTION_ID = l_parent_ih_id
       AND ACTION_ID in (22,30,31,33,65,72,74);
     exception
       when others then
         null;
     end;
   END IF;

   end of comment Ranjan*/

-- creat o/b media item if one does not exist.
     if (l_ob_media_id IS NULL) then
         l_media_rec.direction           := G_O_DIRECTION;
         l_media_rec.source_id           := l_email_account_id;
         l_media_rec.start_date_time     := l_creation_date;
         l_media_rec.media_item_type     := G_MEDIA_TYPE;
         l_media_rec.media_item_ref      := l_outb_message_id;
         l_media_rec.media_data          := l_ih_subject;

         JTF_IH_PUB.Open_MediaItem(p_api_version   => 1.0,
                                  p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                  p_user_id       => l_created_by,
                                  p_login_id      => l_last_update_login,
                                  x_return_status => l_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data,
                                  p_media_rec     => l_media_rec,
                                  x_media_id      => l_ob_media_id
                                  );
               if(l_status <> FND_API.G_RET_STS_SUCCESS) then
                  raise IHError;
               end if;

     end if;

  -- Add MLCS o/b
-- Add MLCS only for action not equals to 'Resolve ' p_action!='V'  Ranjan 10/31/2007
if p_action<>'V' then		-- It is not a resolve
     l_media_lc_rec.start_date_time := SYSDATE;
     l_media_lc_rec.end_date_time := SYSDATE;
     l_media_lc_rec.media_id        := l_ob_media_id;
     l_media_lc_rec.milcs_type_id   := l_action_id_o;
     l_media_lc_rec.resource_id     := l_resource_id;
     l_media_lc_rec.handler_id      := 680;
     JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
                                    p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                    p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                    p_user_id       => l_created_by,
                                    p_login_id      => l_last_update_login,
                                    x_return_status => l_status,
                                    x_msg_count     => l_msg_count,
                                    x_msg_data      => l_msg_data,
                                    x_milcs_id      => x_milcs_id,
                                    p_media_lc_rec  => l_media_lc_rec);

     if(l_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IHError;
     end if;
end if;
  -- close o/b
    l_media_rec.media_id            := l_ob_media_id;
    l_media_rec.direction           := G_O_DIRECTION;
    l_media_rec.media_item_type     := G_MEDIA_TYPE;
    l_media_rec.media_item_ref      := l_outb_message_id;
    l_media_rec.media_data          := l_ih_subject;
    l_media_rec.address             := p_to_address;

    JTF_IH_PUB.Close_MediaItem(p_api_version   => 1.0,
                               p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                               p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                               p_user_id       => l_created_by,
                               p_login_id      => l_last_update_login,
                               x_return_status => l_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data,
                               p_media_rec     => l_media_rec
                               );

     if(l_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IHError;
     end if;

-- Add MLCS only for action not equals to 'Resolve ' p_action!='V'  Ranjan 10/31/2007
if p_action<>'V' then		-- It is not a resolve
  -- Add MLCS i/b inbound may not exist (pure o/b)
     if(l_ib_media_id > 0 AND l_mc_param_action <> 'srautonotification') then
        l_media_lc_rec.start_date_time := SYSDATE;
        l_media_lc_rec.end_date_time := SYSDATE;
        l_media_lc_rec.media_id        := l_ib_media_id;
        l_media_lc_rec.milcs_type_id   := l_action_id_i;
        l_media_lc_rec.resource_id     := l_resource_id;
        l_media_lc_rec.handler_id      := 680;
        JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
                                       p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                       p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                       p_user_id       => l_created_by,
                                       p_login_id      => l_last_update_login,
                                       x_return_status => l_status,
                                       x_msg_count     => l_msg_count,
                                       x_msg_data      => l_msg_data,
                                       x_milcs_id      => x_milcs_id,
                                       p_media_lc_rec  => l_media_lc_rec);
         if(l_status <> FND_API.G_RET_STS_SUCCESS) then
         raise IHError;
       end if;
     end if;
 END IF ;  -- End if for p_action<>'V'   Ranjan 10/31/07
--set doc_id and doc_type

   IF NOT (l_sr_id IS NULL) THEN
     l_activity_rec.doc_id := l_sr_id;
     l_activity_rec.doc_ref := 'SR';
   END IF;

   IF ( l_action_id = 84 OR l_action_id =85 OR l_action_id =86) THEN
     -- resend/forward/re-reply need to copy doc_id and doc_ref from parent
     begin
       SELECT doc_id, doc_ref into l_activity_rec.doc_id, l_activity_rec.doc_ref
       FROM JTF_IH_ACTIVITIES WHERE INTERACTION_ID = l_parent_ih_id
       AND ACTION_ID in (22,30,31,33,65,72,74);
     exception
       when others then
         null;
     end;
   END IF;
  -- Create Activity against primary media_id
     l_activity_rec.start_date_time   := SYSDATE;
     l_activity_rec.end_date_time   := SYSDATE;
     if (l_ib_media_id > 0 AND l_mc_param_action <> 'srautonotification') then
	       l_activity_rec.media_id          := l_ib_media_id;
         l_activity_rec.action_id         := l_action_id;
         l_activity_rec.interaction_id    := l_interaction_id;
         l_activity_rec.outcome_id        := p_outcome_id;
         l_activity_rec.result_id         := l_result_id;
         l_activity_rec.reason_id         := l_reason_id;
         l_activity_rec.action_item_id    := l_activity_type_id;


         JTF_IH_PUB.Add_Activity(p_api_version     => 1.0,
                                 p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                 p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                 p_user_id       => l_created_by,
                                 p_login_id      => l_last_update_login,
                                 x_return_status => l_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data,
                                 p_activity_rec  => l_activity_rec,
                                 x_activity_id   => x_activity_id_i
                                 );

         if(l_status <> FND_API.G_RET_STS_SUCCESS) then
             raise IHError;
         end if;
     end if;

     if ((l_ob_media_id IS NOT NULL) AND (p_action = 'S')) then
  -- Create Activity against outbound media_id, reply or a pure outbound, only if it is sent.
  -- Transfer and Deletes of OutBounds are not recorded.
	       l_activity_rec.media_id          := l_ob_media_id;
         l_activity_rec.interaction_id    := l_interaction_id;
         l_activity_rec.outcome_id        := p_outcome_id;
         l_activity_rec.result_id         := l_result_id;
         l_activity_rec.reason_id         := l_reason_id;
         l_activity_rec.action_item_id    := l_activity_type_id;

	    IF (l_ob_action_id <> 0) THEN
           l_activity_rec.action_id         := l_ob_action_id;
         ELSE
		       l_activity_rec.action_id         := l_action_id;
         END IF;

         JTF_IH_PUB.Add_Activity(p_api_version     => 1.0,
                                 p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                 p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                 p_user_id       => l_created_by,
                                 p_login_id      => l_last_update_login,
                                 x_return_status => l_status,
                                 x_msg_count     => l_msg_count,
                                 x_msg_data      => l_msg_data,
                                 p_activity_rec  => l_activity_rec,
                                 x_activity_id   => x_activity_id_o
                                 );

         if(l_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IHError;
         end if;
     end if;


  --create Activity for SR
     IF NOT (l_sr_action IS NULL) THEN
	  l_action_item_id := 17;
	 -- Added l_activity_rec.doc_source_object_name for bug 9169782
	 -- Changed by Sanjana Rao on 08-Jan-2010
	  select incident_number into l_activity_rec.doc_source_object_name
          from cs_incidents_all_b where incident_id=l_sr_id;

       IF (UPPER(l_sr_action) = 'CREATE') THEN
	    l_action_id_sr := 13;
       END IF;

       IF (UPPER(l_sr_action) = 'UPDATE') THEN
	    l_action_id_sr := 14;
       END IF;

       l_activity_rec.start_date_time   := SYSDATE;
       l_activity_rec.end_date_time   := SYSDATE;
       l_activity_rec.action_id         := l_action_id_sr;
       l_activity_rec.interaction_id    := l_interaction_id;
       l_activity_rec.outcome_id        := p_outcome_id;
       l_activity_rec.result_id         := l_result_id;
       l_activity_rec.reason_id         := l_reason_id;
       l_activity_rec.action_item_id    := l_action_item_id;

       JTF_IH_PUB.Add_Activity(p_api_version     => 1.0,
                               p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                               p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                               p_user_id       => l_created_by,
                               p_login_id      => l_last_update_login,
                               x_return_status => l_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data,
                               p_activity_rec  => l_activity_rec,
                               x_activity_id   => x_activity_id_o
                                 );

       if(l_status <> FND_API.G_RET_STS_SUCCESS) then
         raise IHError;
       end if;
     END IF;

  --create Activity for Lead
     IF (l_lead_id IS NOT NULL AND l_lead_id >= 0 AND l_lead_id <> 9999) THEN

       -- Note: l_activity_rec.doc_id, if once SR, is changed to Lead
       -- So make sure activity for Lead is the last activity to add
       if ( l_lead_id = 0 ) then
          l_activity_rec.doc_id := null;
          l_activity_rec.doc_ref := null;
	  l_activity_rec.doc_source_object_name := null;
       else
         l_activity_rec.doc_id := l_lead_id;
         l_activity_rec.doc_ref := 'LEAD';
       end if;


       l_activity_rec.start_date_time   := SYSDATE;
       l_activity_rec.end_date_time   := SYSDATE;
       l_activity_rec.action_id         := 71; -- Request
       l_activity_rec.interaction_id    := l_interaction_id;
       l_activity_rec.outcome_id        := p_outcome_id;
       l_activity_rec.result_id         := l_result_id;
       l_activity_rec.reason_id         := l_reason_id;
       l_activity_rec.action_item_id    := 8; -- lead;

       JTF_IH_PUB.Add_Activity(p_api_version     => 1.0,
                               p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                               p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                               p_user_id       => l_created_by,
                               p_login_id      => l_last_update_login,
                               x_return_status => l_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data,
                               p_activity_rec  => l_activity_rec,
                               x_activity_id   => x_activity_id_o
                                 );

       if(l_status <> FND_API.G_RET_STS_SUCCESS) then
         raise IHError;
       end if;
     END IF;



  -- Close IH
     l_interaction_rec.interaction_id    := l_interaction_id;
     l_interaction_rec.end_date_time     := SYSDATE;
     l_interaction_rec.resource_id       := l_resource_id;
     l_interaction_rec.party_id          := l_ih_customer_id;
     l_interaction_rec.primary_party_id  := l_primary_customer_id;
    -- l_interaction_rec.contact_party_id  := l_ih_contact_id;
   --  l_interaction_rec.contact_rel_party_id := l_relationship_id;
     l_interaction_rec.outcome_id        := p_outcome_id;
     l_interaction_rec.result_id         := l_result_id;
     l_interaction_rec.handler_id        := 680; -- IEM APPL_ID
     l_interaction_rec.reason_id         := l_reason_id;
     -- done at creation l_interaction_rec.parent_id         := l_parent_ih_id;

     IF (l_ih_creator = 'Y' OR l_ih_creator = 'S' ) THEN
       JTF_IH_PUB.Close_Interaction(p_api_version     => 1.1,
                                    p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                    p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                    p_user_id         => l_created_by,
                                    p_login_id        => l_last_update_login,
                                    x_return_status   => l_status,
                                    x_msg_count       => l_msg_count,
                                    x_msg_data        => l_msg_data,
                                    p_interaction_rec => l_interaction_rec
                                   );

       if(l_status <> FND_API.G_RET_STS_SUCCESS) then
          raise IHError;
       end if;
     END IF;

-- call server side reroute api

  IF (UPPER(p_action) = 'X') THEN
    begin
      if ( m_reroute_type = 78 ) then
        IEM_REROUTE_PUB.IEM_MAIL_REROUTE_ACCOUNT( P_API_VERSION_NUMBER => 1.0,
                            P_INIT_MSG_LIST => 'F',
                            P_COMMIT => 'F',
                            P_MSGID => l_mdt_message_id,
                            P_AGENT_ID => l_reroute_resource_id,
                            P_EMAIL_ACCOUNT_ID => p_to_account_id,
                            P_INTERACTION_ID => l_interaction_id,
                            P_UID  => m_uid,
                            X_MSG_COUNT  => l_msg_count,
                            X_RETURN_STATUS => l_status,
                            X_MSG_DATA => l_msg_data);
      else
        if (m_reroute_type = 76) AND (l_to_resource_id > 0) then
           l_to_group_id := l_to_resource_id;
        else
           l_to_group_id := null;
        end if;
        IEM_REROUTE_PUB.IEM_MAIL_REROUTE_CLASS( P_API_VERSION_NUMBER => 1.0,
                            P_INIT_MSG_LIST => 'F',
                            P_COMMIT => 'F',
                            P_MSGID => l_mdt_message_id,
                            P_AGENT_ID => l_reroute_resource_id,
                            P_CLASS_ID => l_reroute_to_classi,
                            P_CUSTOMER_ID  => p_customer_id,
                            P_UID => m_uid,
                            P_INTERACTION_ID => l_interaction_id,
                            p_GROUP_ID  => l_to_group_id,
                            X_MSG_COUNT  => l_msg_count,
                            X_RETURN_STATUS => l_status,
                            X_MSG_DATA => l_msg_data);
      end if;

      if(l_status <> FND_API.G_RET_STS_SUCCESS) then
          raise RerouteError;
      end if;
    end;
  END IF;

-- update RTI: send, delete, reroute
  IF ((UPPER(p_action) = 'S') OR (UPPER(p_action) = 'D') OR (UPPER(p_action)='V') -- Add resolve
       OR (UPPER(p_action) = 'X')) THEN
    begin
      UPDATE iem_rt_interactions SET expire = G_EXPIRE
      WHERE rt_interaction_id = l_rt_interaction_id;

      UPDATE iem_rt_media_items SET expire = G_EXPIRE
      WHERE rt_interaction_id = l_rt_interaction_id;

      if ( (UPPER(p_action) <> 'X') AND l_mdt_message_id IS NOT NULL) then
        begin
          IEM_MAILITEM_PUB.DisposeMailItem (p_api_version_number  => 1.0,
                                            p_init_msg_list =>'F' ,
                                            p_commit => 'F',
                                            p_message_id          => l_mdt_message_id,
                                            x_return_status       => l_status,
                                            x_msg_count           => l_msg_count,
                                            x_msg_data            => l_msg_data);
	   exception
	     when others then
		  null;
	   end;
      end if;

      -- Reset queue_status to null is not really needed for once its
      -- agent id set to 0, queue_status is disregarded. But just play safe.
     if ( (UPPER(p_action) = 'X') AND (m_reroute_type = 76) ) then
           update IEM_RT_PROC_EMAILS set queue_status = null
           where message_id = l_mdt_message_id;
      end if;
    end;
  ELSIF (UPPER(p_action) = 'T') THEN
   begin

-- Need to create new transferee record here:
-- Lead id to 9999 to prevent lead request activity being created every time transferred
  if (l_lead_id >= 0) then
    l_tran_lead_id := 9999;
  else
    l_tran_lead_id := -1;
  end if;

  select agent_id into l_tran_to_acct_id from iem_agents
    where resource_id = p_to_resource_id
    and email_account_id = l_email_account_id;

  select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
  INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, contact_id, inb_tag_id,
                   lead_id, parent_interaction_id, service_request_id,
                   relationship_id )
         SELECT    l_i_sequence, p_to_resource_id, l_ih_customer_id, TYPE,
                   G_WORK_IN_PROGRESS, G_ACTIVE, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login,
                   l_contact_id, inb_tag_id, l_tran_lead_id,
                   l_interaction_id, l_sr_id,
                   l_relationship_id
         FROM      iem_rt_interactions
	       WHERE     rt_interaction_id = l_rt_interaction_id;

  select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
  INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   db_server_id, agent_account_id, email_type, status, expire, version,
		               created_by, creation_date, last_updated_by, last_update_date,
		               last_update_login, edit_mode )
         SELECT    l_i_sequence, l_m_sequence, p_to_resource_id,
                   MEDIA_ID, MESSAGE_ID, RFC822_MESSAGE_ID,
                   folder_name, db_server_id, l_tran_to_acct_id, EMAIL_TYPE, 'R',  G_ACTIVE,
                   0, l_created_by, SYSDATE, l_last_updated_by, SYSDATE,
                   l_last_update_login, decode(p_transfer_msg_flag, 'T', null, p_transfer_msg_flag)
        FROM      iem_rt_media_items
	      WHERE     rt_media_item_id = p_rt_media_item_id;

-- Add MLCS i/b inbound for the second agent
     if(l_ib_media_id > 0 AND l_mc_param_action <> 'srautonotification') then
        l_media_lc_rec.start_date_time := SYSDATE;
        l_media_lc_rec.end_date_time := SYSDATE;
        l_media_lc_rec.media_id        := l_ib_media_id;
        l_media_lc_rec.milcs_type_id   := 21; -- EMAIL_TRANSFER (should be transfer_to, but not seeded)
        l_media_lc_rec.resource_id     := p_to_resource_id;
        l_media_lc_rec.handler_id      := 680;
        JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
                                       p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                       p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                       p_user_id       => l_created_by,
                                       p_login_id      => l_last_update_login,
                                       x_return_status => l_status,
                                       x_msg_count     => l_msg_count,
                                       x_msg_data      => l_msg_data,
                                       x_milcs_id      => x_milcs_id,
                                       p_media_lc_rec  => l_media_lc_rec);
         if(l_status <> FND_API.G_RET_STS_SUCCESS) then
         raise IHError;
       end if;
     end if; -- MLCS second agent

-- Transferrers RT Interaction and RT media are expired
    UPDATE iem_rt_interactions SET expire = G_EXPIRE
    WHERE rt_interaction_id = l_rt_interaction_id;

    -- This expires both the inbound and any outbounds
    -- associated with the original message. Change
    -- this for co-operate

    UPDATE iem_rt_media_items SET expire = G_EXPIRE
    WHERE  rt_interaction_id = l_rt_interaction_id;

-- Update mdt. Set the new owner of mailItem and from_agent_id and status
-- and open queue_status.
    UPDATE IEM_RT_PROC_EMAILS
    SET resource_id = p_to_resource_id,
        from_resource_id = l_reroute_resource_id,
        mail_item_status = 'T',
        queue_status = null,
        message_flag = p_transfer_msg_flag
    WHERE  message_id = l_mdt_message_id;

    end;
  END IF;

-- Record UWQ interaction.
      BEGIN
        FOR sel_rec in sel_csr LOOP
            l_session_id := sel_rec.session_id;
            exit;
        END LOOP;
        IEU_SH_PUB.UWQ_BEGIN_ACTIVITY(
                                      p_api_version        => 1.0,
                                      P_INIT_MSG_LIST      => 'F',
                                      P_COMMIT             => 'F',
                                      p_session_id         => l_session_id,
                                      p_activity_type_code => l_activity_type,
                                      P_MEDIA_TYPE_ID      => null,
                                      P_MEDIA_ID           => null,
                                      p_user_id            => l_created_by,
                                      p_login_id           => l_last_update_login,
                                      P_REASON_CODE        => null,
                                      P_REQUEST_METHOD     => null,
                                      P_REQUESTED_MEDIA_TYPE_ID  => null,
                                      P_WORK_ITEM_TYPE_CODE      => null,
                                      P_WORK_ITEM_PK_ID    => null,
                                      p_end_activity_flag  => 'Y',
                                      x_activity_id        => l_activity_id,
                                      x_msg_count          => l_count,
                                      x_msg_data           => l_data,
                                      x_return_status      => l_ret_status
                                      );
      EXCEPTION
           WHEN OTHERS THEN
                 NULL;
      END;

-- Expire iem_outbox_errors records if any
  UPDATE iem_outbox_errors SET expire = G_EXPIRE
  WHERE rt_media_item_id in (SELECT rt_media_item_id
  FROM iem_rt_media_items WHERE rt_interaction_id = l_rt_interaction_id);

  -- write statistics data
  -- IEM_OUTBOUND_METHODS values:
  -- 1001 AUTO_REPLY
  -- 1002 AUTO_SUGGEST used when a reply uses at least one suggested response
  -- 1003 MANUAL_REPLY used when a reply does NOT use any suggested responses
  -- 1004 NEW_COMPOSE used for "pure outbound" messages

  if ( UPPER(p_action) = 'S') then
    if ( l_action_id = 74 ) then
      l_autoReplied := 'Y';
      l_outb_method := 1001;
    else
      l_autoReplied := 'N';
      if ( l_action_id = 33 ) then
        l_outb_method := 1004;
      else
        begin
          l_use_suggested := 0;
          select count(OUTBOUND_MSG_STATS_ID) into l_use_suggested
            from iem_outbound_msg_stats
                 where media_id = l_ob_media_id
                 and USES_SUGGESTIONS_Y_N = 'Y';

          if ( l_use_suggested > 0 ) then
            l_outb_method := 1002;
          else
            l_outb_method := 1003;
          end if;

        end;
      end if;
    end if;

    if ( l_contact_id < 0 ) then
      l_contact_id := -1;
    end if;


    IEM_MSG_STAT_PUB.sendMSGStat(
    p_api_version_number    => 1.0,
    p_init_msg_list         => fnd_api.g_false,
    p_commit                => fnd_api.g_false,
    p_outBoundMediaID       => l_ob_media_id,
    p_inBoundMediaID        => nvl(l_ib_media_id, -1),
    p_autoReplied           => l_autoReplied,
    p_agentID               => l_resource_id,
    p_outBoundMethod        => l_outb_method,
    p_accountID             => l_email_account_id,
    p_customerID            => p_customer_id,
    p_contactID             => l_contact_id,
    x_return_status         => l_ret_status,
    x_msg_count             => l_count,
    x_msg_data              => l_data
    );
  end if;

  if (UPPER(p_action) = 'D') then
    IEM_MSG_STAT_PUB.deleteMSGStat(
    p_api_version_number    => 1.0,
    p_init_msg_list         => fnd_api.g_false,
    p_commit                => fnd_api.g_false,
    p_outBoundMediaID       => l_ob_media_id,
    p_inBoundMediaID        => nvl(l_ib_media_id, -1),
    x_return_status         => l_ret_status,
    x_msg_count             => l_count,
    x_msg_data              => l_data
    );
  end if;

-------------------End Code------------------------
<<end_of_wrapup>>
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

EXCEPTION
   WHEN RerouteError THEN
     ROLLBACK TO wrapUp_pvt;
     x_return_status := l_status;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

   WHEN IEM_REDIRECT_EX THEN
     ROLLBACK TO wrapUp_pvt;
     x_return_status := l_status;
     x_msg_count := l_msg_count;
     x_msg_data := l_msg_data;

   WHEN badResourceId THEN
	   ROLLBACK TO wrapUp_pvt;
	   x_return_status := l_status;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_RESOURCE_ID');
        FND_MSG_PUB.ADD;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                 p_count => x_msg_count,
						     p_data => x_msg_data);
   WHEN IHError THEN
        ROLLBACK TO wrapUp_pvt;
	   x_return_status := l_status;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
              p_count => x_msg_count,
							p_data => x_msg_data);
   WHEN RTError THEN
        ROLLBACK TO wrapUp_pvt;
	   x_return_status := l_status;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
              p_count => x_msg_count,
							p_data => x_msg_data);
   WHEN MDTError THEN
        ROLLBACK TO wrapUp_pvt;
	      x_return_status := l_status;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
              p_count => x_msg_count,
							p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO wrapUp_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO wrapUp_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO wrapUp_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END wrapUp;

PROCEDURE recoverCompose  (p_api_version_number    IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_resource_id           IN   NUMBER,
                           x_return_status         OUT NOCOPY  VARCHAR2,
                           x_msg_count             OUT NOCOPY  NUMBER,
                           x_msg_data              OUT NOCOPY  VARCHAR2,
                           x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                           x_account_id            OUT NOCOPY  NUMBER,
                           x_account_type          OUT NOCOPY  VARCHAR2,
                           x_email_type            OUT NOCOPY  VARCHAR2,
                           x_status                OUT NOCOPY  VARCHAR2,
                           x_version               OUT NOCOPY  NUMBER,
                           x_rt_media_item_id      OUT NOCOPY  NUMBER,
                           x_rt_interaction_id     OUT NOCOPY  NUMBER,
                           x_oes_id                OUT NOCOPY  NUMBER,
                           x_folder_name           OUT NOCOPY  VARCHAR2,
                           x_folder_uid            OUT NOCOPY  NUMBER,
                           x_customer_id           OUT NOCOPY  NUMBER
                           ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;

  badAccountType           EXCEPTION;

  CURSOR compose_recover_csr IS
    SELECT   m.rfc822_message_id,m.email_account_id, m.agent_account_id,
             m.email_type, m.status, m.version, m.rt_interaction_id,
             m.db_server_id, m.rt_media_item_id, m.folder_name, m.folder_uid,
             i.customer_id
    FROM     iem_rt_media_items m, iem_rt_interactions i
    WHERE    i.TYPE = G_OUTBOUND
    AND      i.RT_INTERACTION_ID = m.RT_INTERACTION_ID
    AND      m.RESOURCE_ID = p_resource_id
    AND      m.EMAIL_TYPE = G_OUTBOUND
    AND      m.expire = G_ACTIVE
    ORDER BY m.rt_interaction_id;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT recoverCompose_pvt;

-- Init vars
  l_api_name               :='recoverCompose';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

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
/*  dbms_output.put_line('In getWork ');
  dbms_output.put_line('In getWork : Resource ID  '||p_resource_id);
*/

-- No Message Found.
  x_return_status := 'N';

  FOR cr_rec in compose_recover_csr LOOP
    if ((cr_rec.email_account_id IS NULL) AND (cr_rec.agent_account_id IS NOT NULL)) then
        x_account_id := cr_rec.agent_account_id;
        x_account_type := G_AGENT_ACCOUNT;
    elsif ((cr_rec.agent_account_id IS NULL) AND (cr_rec.email_account_id IS NOT NULL)) then
        x_account_id := cr_rec.email_account_id;
        x_account_type := G_MASTER_ACCOUNT;
    elsif ((cr_rec.agent_account_id IS NOT NULL) AND (cr_rec.email_account_id IS NOT NULL)) then
        x_account_id := cr_rec.agent_account_id;
        x_account_type := G_AGENT_ACCOUNT;
    else
        raise badAccountType;
    end if;

    x_rfc822_message_id := cr_rec.RFC822_MESSAGE_ID;
    x_email_type        := cr_rec.EMAIL_TYPE;
    x_status            := cr_rec.STATUS;
    x_version           := cr_rec.VERSION;
    x_rt_media_item_id  := cr_rec.rt_media_item_id;
    x_rt_interaction_id := cr_rec.rt_interaction_id;
    x_oes_id            := cr_rec.DB_SERVER_ID;
    x_folder_name       := cr_rec.FOLDER_NAME;
    x_folder_uid        := cr_rec.FOLDER_UID;
    x_customer_id       := cr_rec.CUSTOMER_ID;
    x_return_status     := FND_API.G_RET_STS_SUCCESS;

    exit; -- get the first record.

   END LOOP;
-------------------End Code------------------------

EXCEPTION
   WHEN badAccountType THEN
      ROLLBACK TO recoverCompose_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_ACCOUNT_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO recoverCompose_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO recoverCompose_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO recoverCompose_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END recoverCompose;

/*
PROCEDURE getAccountDelStatus(p_api_version_number    IN   NUMBER,
                              p_init_msg_list         IN   VARCHAR2,
                              p_commit                IN   VARCHAR2,
                              p_account_id IN NUMBER,
                              p_account_type IN VARCHAR2,
                              x_status OUT NOCOPY NUMBER,
                              x_return_status         OUT NOCOPY  VARCHAR2,
                              x_msg_count             OUT NOCOPY  NUMBER,
                              x_msg_data              OUT NOCOPY  VARCHAR2      ) IS

	l_api_name        		VARCHAR2(255);
	l_api_version_number 	NUMBER;
	l_data                NUMBER;

     CURSOR del_status_csr IS
      SELECT agent_id
      FROM   iem_agents
      WHERE  email_account_id = p_account_id
      ORDER BY agent_id;
BEGIN

-- Standard Start of API savepoint
	SAVEPOINT		getAccountDelStatus_pvt;

-- Init vars
	l_api_name        		:='getAccountDelStatus';
	l_api_version_number 	:=1.0;

-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
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

----------------------------------------CODE-----------------------------------
   l_data   := 0;
   x_status := 0;

   IF (UPPER(p_account_type) = G_AGENT_ACCOUNT) THEN
      SELECT count(*) into l_data FROM  iem_rt_media_items
	 WHERE  agent_account_id = p_account_id
	 AND    expire = G_ACTIVE;

	 if (l_data = 0) then
	   x_status := 0;
      else
        x_status := 1;
      end if;
   ELSE
       x_status := 0;
       FOR cr_rec in del_status_csr LOOP
        SELECT count(*) into l_data FROM  iem_rt_media_items
        WHERE  agent_account_id = cr_rec.agent_account_id
	   AND    expire = G_ACTIVE;

         if (l_data = 0) then
            x_status := 0;
          else
            x_status := 1;
            exit;
          end if;
       END LOOP;
   END IF;
----------------------------------------CODE-----------------------------------
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
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO getAccountDelStatus_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_encoded => FND_API.G_TRUE,
        p_count => x_msg_count,
        p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO getAccountDelStatus_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_encoded => FND_API.G_TRUE,
        p_count => x_msg_count,
        p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO getAccountDelStatus_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_encoded => FND_API.G_TRUE,
          p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    		);

end getAccountDelStatus;
*/


PROCEDURE purgeOutbound (p_api_version_number    IN   NUMBER,
                         p_init_msg_list         IN   VARCHAR2,
                         p_commit                IN   VARCHAR2,
                         x_return_status         OUT NOCOPY  VARCHAR2,
                         x_msg_count             OUT NOCOPY  NUMBER,
                         x_msg_data              OUT NOCOPY  VARCHAR2
                        ) IS

 l_api_name             VARCHAR2(255);
 l_api_version_number 	NUMBER;
 l_created_by           NUMBER;
 l_last_update_login    NUMBER;

 l_status               VARCHAR2(300);
 l_msg_count            NUMBER;
 l_msg_data             VARCHAR2(300);

 l_rt_interaction_id    NUMBER;
 l_media_id             NUMBER;
 l_mc_parameter_id      NUMBER;
 l_customer_id          NUMBER;
 l_resource_id          NUMBER;
 l_RT_MEDIA_ITEM_ID     NUMBER;

 l_tmp_ref_key          varchar2(200);
 l_tmp_ref_name         varchar2(200);

 l_profile_value        varchar2(200);
 l_rfc822_message_id    VARCHAR2(255);
 l_email_type           VARCHAR2(1);
 l_version              NUMBER;
 l_media_rec            JTF_IH_PUB.MEDIA_REC_TYPE;
 i                      NUMBER;
 l_message_id           NUMBER;

 CURSOR del_rt_csr IS
   SELECT iem_rt_interactions.RT_INTERACTION_ID
   FROM   iem_rt_interactions, iem_rt_media_items
   WHERE  iem_rt_interactions.expire='N' and iem_rt_interactions.type = 'O'
   AND SYSDATE - iem_rt_interactions.LAST_UPDATE_DATE > 30
   AND iem_rt_media_items.RT_INTERACTION_ID = iem_rt_interactions.RT_INTERACTION_ID;

 CURSOR del_rt_expire_csr IS
   SELECT RT_MEDIA_ITEM_ID FROM iem_rt_media_items WHERE expire= 'Y';

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT purgeOutbound_pvt;

-- Init vars
  l_api_name             :='purgeOutbound';
  l_api_version_number 	 :=1.0;
  l_created_by           :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login    := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

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
  BEGIN

-- Clean Iem_msg_parts table
   FOR rt_expire_csr_rec in del_rt_expire_csr LOOP
	/* Commented due to perf issue  bug 6875851  03/13/2008 Ranjan
     l_tmp_ref_key := rt_expire_csr_rec.RT_MEDIA_ITEM_ID;

     LOOP
       l_tmp_ref_name := NULL;

       BEGIN
         select PART_NAME into l_tmp_ref_name from iem_msg_parts where to_char(ref_key) = l_tmp_ref_key
         and PART_TYPE = 'ATTACHMAIL' and rownum < 2;
       EXCEPTION WHEN NO_DATA_FOUND THEN
         EXIT;
       END;


       if (l_tmp_ref_name IS NOT NULL) THEN
         l_tmp_ref_key := l_tmp_ref_name;
         update iem_msg_parts set DELETE_FLAG = 'Y' where to_char(REF_KEY) = l_tmp_ref_key;
       END IF;

     END LOOP;
	  modifed the query as below after the comment section
	*/
	update iem_msg_parts
	set delete_flag='Y'
	where ref_key in (select part_name from iem_msg_parts where
	ref_key=rt_expire_csr_rec.RT_MEDIA_ITEM_ID and part_type='ATTACHMAIL');

   END LOOP;

   -- delete outbox errors
   delete from iem_outbox_errors where expire = 'Y';

   delete from iem_msg_parts where REF_KEY in
    (select rt_media_item_id from iem_rt_media_items WHERE expire='Y');

   delete from iem_msg_parts where DELETE_FLAG = 'Y';

-- Delete IEM_MC_PARAMETERS, and IEM_MC_CUSTOM_PARAM
   delete from IEM_MC_CUSTOM_PARAMS where MC_PARAMETER_ID in
   (select IEM_MC_CUSTOM_PARAMS.MC_PARAMETER_ID
    from IEM_MC_CUSTOM_PARAMS, iem_rt_interactions
    where IEM_MC_CUSTOM_PARAMS.MC_PARAMETER_ID = iem_rt_interactions.MC_PARAMETER_ID
    and iem_rt_interactions.expire = 'Y');

   delete from IEM_MC_PARAMETERS where MC_PARAMETER_ID in
   (select IEM_MC_PARAMETERS.MC_PARAMETER_ID
    from IEM_MC_PARAMETERS, iem_rt_interactions
    where IEM_MC_PARAMETERS.MC_PARAMETER_ID = iem_rt_interactions.MC_PARAMETER_ID
    and iem_rt_interactions.expire = 'Y');

-- Delete each record from iem_rt_interactions where expire = 'Y'
   delete from iem_rt_interactions where expire = 'Y';

-- Delete each record from iem_msg_datas where its reference at iem_rt_media_items has expire ='Y'.
   delete from iem_msg_datas where msg_key in
   (select msg_key from iem_rt_media_items, iem_msg_datas
    where iem_rt_media_items.rt_media_item_id = iem_msg_datas.msg_key
    and iem_rt_media_items.expire = 'Y');

-- Delete each record from iem_rt_media_items where expire = 'Y'.
   delete from iem_rt_media_items where expire = 'Y';

-- Delete each record from iem_agent_sessions where last_update_date is older than 30 days
   delete from iem_agent_sessions where SYSDATE - LAST_UPDATE_DATE > 30;


-- Delete each record from IEM_MC_CUSTOM_PARAMS and IEM_MC_PARAMETERS where last_update_date is older than 30 days

   delete from IEM_MC_CUSTOM_PARAMS where MC_PARAMETER_ID in
      (select IEM_MC_CUSTOM_PARAMS.MC_PARAMETER_ID
       from IEM_MC_CUSTOM_PARAMS, iem_rt_interactions
       where IEM_MC_CUSTOM_PARAMS.MC_PARAMETER_ID = iem_rt_interactions.MC_PARAMETER_ID
       and iem_rt_interactions.expire='N' and iem_rt_interactions.type='O' and
       SYSDATE - iem_rt_interactions.LAST_UPDATE_DATE > 30);

   delete from IEM_MC_PARAMETERS where MC_PARAMETER_ID in
      (select IEM_MC_PARAMETERS.MC_PARAMETER_ID
       from IEM_MC_PARAMETERS, iem_rt_interactions
       where IEM_MC_PARAMETERS.MC_PARAMETER_ID = iem_rt_interactions.MC_PARAMETER_ID
       and iem_rt_interactions.expire='N' and iem_rt_interactions.type='O' and
       SYSDATE - iem_rt_interactions.LAST_UPDATE_DATE > 30);

   FOR cr_rec in del_rt_csr LOOP
     l_rt_interaction_id := cr_rec.RT_INTERACTION_ID;

     select RT_MEDIA_ITEM_ID, media_id, email_type, message_id
     into l_RT_MEDIA_ITEM_ID, l_media_id, l_email_type, l_message_id
     from iem_rt_media_items
     where rt_interaction_id = l_rt_interaction_id;


     l_media_rec.media_id            := l_media_id;
     l_media_rec.direction           := G_O_DIRECTION;
     l_media_rec.media_item_type     := G_MEDIA_TYPE;
     l_media_rec.media_item_ref      := l_message_id;

     IF (l_email_type = 'I') THEN
       l_media_rec.direction         := G_I_DIRECTION;
     END IF;

     JTF_IH_PUB.Close_MediaItem(p_api_version   => 1.0,
                                p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                                p_user_id       => l_created_by,
                                p_login_id      => l_last_update_login,
                                x_return_status => l_status,
                                x_msg_count     => l_msg_count,
                                x_msg_data      => l_msg_data,
                                p_media_rec     => l_media_rec
                               );


-- Clean Iem_msg_parts table

   l_tmp_ref_key := l_RT_MEDIA_ITEM_ID;

/* Commented for perf issue as per bug 6875851
   FOR i in 1..50 LOOP
     BEGIN
       select PART_NAME into l_tmp_ref_name from iem_msg_parts where to_char(ref_key) = l_tmp_ref_key
       and PART_TYPE = 'ATTACHMAIL' and rownum < 2;
     EXCEPTION WHEN NO_DATA_FOUND THEN
       EXIT;
     END;


     if (l_tmp_ref_name IS NOT NULL) THEN
       l_tmp_ref_key := l_tmp_ref_name;
       update iem_msg_parts set DELETE_FLAG = 'Y' where to_char(REF_KEY) = l_tmp_ref_key;
     END IF;

   END LOOP;
   modify the part as below.
*/
	update iem_msg_parts
	set delete_flag='Y'
	where ref_key in (select part_name from iem_msg_parts where
	ref_key=l_RT_MEDIA_ITEM_ID and part_type='ATTACHMAIL');

   delete from iem_msg_parts where REF_KEY = l_RT_MEDIA_ITEM_ID;
   delete from iem_rt_media_items where RT_MEDIA_ITEM_ID = l_RT_MEDIA_ITEM_ID;
   delete from iem_rt_interactions where rt_interaction_id = l_rt_interaction_id;

   END LOOP;

-- Clean anything left
   delete from iem_msg_parts where DELETE_FLAG = 'Y';
   delete from iem_rt_interactions WHERE expire='N' and type = 'O'
   AND SYSDATE - LAST_UPDATE_DATE > 30;


 EXCEPTION
   WHEN OTHERS THEN
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
 END;

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
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO purgeOutbound_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO purgeOutbound_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO purgeOutbound_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END purgeOutbound;



PROCEDURE assignMsg (p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_message_id            IN   NUMBER,
                   p_to_resource_id        IN   NUMBER,
                   p_from_resource_id      IN   NUMBER,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2,
                   x_rt_media_item_id      OUT NOCOPY  NUMBER,
                   x_email_account_id      OUT NOCOPY  NUMBER,
                   x_oes_id                OUT NOCOPY  NUMBER,
                   x_folder_name           OUT NOCOPY  VARCHAR2,
                   x_folder_uid            OUT NOCOPY  NUMBER,
                   x_rt_interaction_id     OUT NOCOPY  NUMBER,
                   x_customer_id           OUT NOCOPY  NUMBER,
                   x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                   x_route_classification  OUT NOCOPY  VARCHAR2,
                   x_mdt_message_id        OUT NOCOPY  NUMBER,
                   x_service_request_id    OUT NOCOPY  NUMBER,
                   x_contact_id            OUT NOCOPY  NUMBER,
                   x_lead_id               OUT NOCOPY  NUMBER,
                   x_relationship_id       OUT NOCOPY  NUMBER
                  )  IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_email_data_rec         IEM_RT_PROC_EMAILS%ROWTYPE;
  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_db_server_id           NUMBER;
  l_classification_id      NUMBER;
  l_tag_key_value_tbl      IEM_MAILITEM_PUB.keyVals_tbl_type;
  l_tag_id                 VARCHAR2(30);
  l_sr_id                  NUMBER;
  l_parent_ih_id           NUMBER;
  l_customer_id            NUMBER;
  l_contact_id             NUMBER;
  l_relationship_id        NUMBER;
  l_lead_id                NUMBER;
  l_media_lc_rec           JTF_IH_PUB.media_lc_rec_type;
  l_milcs_id               NUMBER;
  l_ih_creator             VARCHAR2(1);
  l_mail_item_status       VARCHAR2(1);


BEGIN

-- Standard Start of API savepoint
        SAVEPOINT assignMsg_pvt;

-- Init vars
  l_api_name               :='assignMsg';
  l_api_version_number      :=1.0;
  l_created_by              :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by         :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login       := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_sr_id                    :=null;
  l_parent_ih_id             :=null;
  l_customer_id              :=null;
  l_contact_id               :=null;
  l_relationship_id          :=null;
  l_lead_id                  :=null;
  l_milcs_id                 :=null;


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

-- if assign to herself, this will be recorded as a 'fetch'
  if ( p_from_resource_id = p_to_resource_id ) then
    l_mail_item_status := 'N';  -- new
  else
    l_mail_item_status := 'A';
  end if;

--Update IEM_RT_PROC_EMAILS with to_agent_id, from_agent_id and status 'A'
  IEM_MAILITEM_PUB.GetQueueItemData (p_api_version_number => 1.0,
                    p_init_msg_list  => 'F',
                    p_commit  => 'F',
                    p_message_id => p_message_id,
                    p_from_agent_id => p_from_resource_id,
                    p_to_agent_id => p_to_resource_id,
                    p_mail_item_status => l_mail_item_status,
                    x_email_data   => l_email_data_rec,
                    x_tag_key_value  => l_tag_key_value_tbl,
                    x_encrypted_id   => l_tag_id,
                    x_return_status  => l_status,
                    x_msg_count  => l_msg_count,
                    x_msg_data  => l_msg_data);

-- Check return status; Proceed on success Or report back in case of error.
    IF (l_status = FND_API.G_RET_STS_SUCCESS) THEN
    -- Success.
    -- Get the name of the route classification from the ID returned above.
    -- This is the name of the folder where the inbound message exists on the
    -- master account.
        SELECT name INTO x_route_classification
        FROM   iem_route_classifications
        WHERE  ROUTE_CLASSIFICATION_ID = l_email_data_rec.RT_CLASSIFICATION_ID;

    -- Set the folder name
        x_folder_name := x_route_classification;

    -- Extract tag key value from key value table
    -- Currently valid system key names:
    -- IEMNBZTSRVSRID for sr id
    -- IEMNINTERACTIONID for interaction id
    -- IEMNAGENTID for agent id
    -- IEMNCUSTOMERID for customer id
    -- IEMNCONTACTID for contact id
    -- IEMNBZSALELEADID for lead id

    FOR i IN 1..l_tag_key_value_tbl.count LOOP
       BEGIN
        IF (l_tag_key_value_tbl(i).key = 'IEMNBZTSRVSRID' ) THEN
           l_sr_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNINTERACTIONID' ) THEN
           l_parent_ih_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNCUSTOMERID' ) THEN
           l_customer_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNCONTACTID' ) THEN
           l_contact_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNRELATIONSHIPID' ) THEN
           l_relationship_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNBZSALELEADID' ) THEN
           l_lead_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        END IF;
       END;
    END LOOP;

-- customer id and contact id from tagging supersede the result from
-- email search (i.e. what are in l_email_date_rec)
    IF (l_customer_id is NULL) THEN
      BEGIN
        l_customer_id := l_email_data_rec.CUSTOMER_ID;
        l_contact_id := null;
        l_relationship_id := null;
      END;
    END IF;

-- Record details into the RT tables.
       l_ih_creator := null;
       if (l_email_data_rec.IH_INTERACTION_ID is not null) then
         l_ih_creator := 'Y';
       end if;

       select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
       INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, contact_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, parent_interaction_id,
                   service_request_id, inb_tag_id, interaction_id, ih_creator,
                   lead_id, relationship_id )
              VALUES (
                   l_i_sequence, p_to_resource_id, l_customer_id, l_contact_id,
                   G_INBOUND, G_WORK_IN_PROGRESS, G_ACTIVE, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   l_parent_ih_id, l_sr_id, l_tag_id,
                   l_email_data_rec.IH_INTERACTION_ID, l_ih_creator,
                   l_lead_id, l_relationship_id

              );
       -- db_server id used by mid-tier to locate accounts
       l_db_server_id := -1;

       select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
       INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login )
              VALUES (
                   l_i_sequence, l_m_sequence, p_to_resource_id,
                   l_email_data_rec.IH_MEDIA_ITEM_ID,
                   l_email_data_rec.MESSAGE_ID,
                   null,
                   x_folder_name,
                   -1,
                   l_email_data_rec.EMAIL_ACCOUNT_ID,
                   l_db_server_id,
                   G_INBOUND, G_UNMOVED, G_ACTIVE,0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login
              );

        -- update post_mdts to set queue_status to null in case it is not clear
        UPDATE IEM_RT_PROC_EMAILS SET queue_status = NULL WHERE message_id = p_message_id;


--Add MLCS 'email assigned' using to_resource_id and 'email_assign' using resource_id
  if ( l_mail_item_status = 'A' ) then

	   l_media_lc_rec.start_date_time := SYSDATE;
     l_media_lc_rec.end_date_time := SYSDATE;
	   l_media_lc_rec.media_id        := l_email_data_rec.IH_MEDIA_ITEM_ID;
	   l_media_lc_rec.milcs_type_id   := 35;  -- EMAIL_ASSIGNED
	   l_media_lc_rec.resource_id     := p_to_resource_id;
	   l_media_lc_rec.handler_id      := 680;
	   JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
				    p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
					  p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
					  p_user_id       => l_created_by,
					  p_login_id      => l_last_update_login,
					  x_return_status => l_status,
					  x_msg_count     => l_msg_count,
					  x_msg_data      => l_msg_data,
					  x_milcs_id      => l_milcs_id,
					  p_media_lc_rec  => l_media_lc_rec);

	   l_media_lc_rec.start_date_time := SYSDATE;
     l_media_lc_rec.end_date_time := SYSDATE;
	   l_media_lc_rec.media_id        := l_email_data_rec.IH_MEDIA_ITEM_ID;
	   l_media_lc_rec.milcs_type_id   := 45;  -- EMAIL_ASSIGN
	   l_media_lc_rec.resource_id     := p_from_resource_id;
	   l_media_lc_rec.handler_id      := 680;
	   JTF_IH_PUB.Add_MediaLifecycle( p_api_version   => 1.0,
				    p_resp_appl_id  => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
					  p_resp_id       => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
					  p_user_id       => l_created_by,
					  p_login_id      => l_last_update_login,
					  x_return_status => l_status,
					  x_msg_count     => l_msg_count,
					  x_msg_data      => l_msg_data,
					  x_milcs_id      => l_milcs_id,
					  p_media_lc_rec  => l_media_lc_rec);

   end if;

-- Return Media Values to the JSPs.
       x_rt_media_item_id  := l_m_sequence;
       x_email_account_id  := l_email_data_rec.EMAIL_ACCOUNT_ID;
       x_oes_id            := l_db_server_id;
       x_folder_uid        := -1;
       x_customer_id       := l_customer_id;
       x_rfc822_message_id := null;
       x_rt_interaction_id := l_i_sequence;
       x_mdt_message_id    := l_email_data_rec.MESSAGE_ID;
       x_service_request_id := l_sr_id;
       x_contact_id        := l_contact_id;
       x_lead_id        := l_lead_id;
       x_relationship_id   := l_relationship_id;
    ELSE
-- Return the error returned by MDT API
       x_return_status := l_status;
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
			( p_encoded => FND_API.G_TRUE,
        p_count =>  x_msg_count,
        p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO assignMsg_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(
                  p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO assignMsg_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO assignMsg_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END assignMsg;



PROCEDURE queueToOutbox  (p_api_version_number    IN   NUMBER,
                   p_init_msg_list         IN   VARCHAR2,
                   p_commit                IN   VARCHAR2,
                   p_action                IN   VARCHAR2,
                   p_action_id             IN   NUMBER,
                   p_rt_media_item_id      IN   NUMBER,
                   p_version               IN   NUMBER,
                   p_customer_id           IN   NUMBER,
                   p_activity_type_id      IN   NUMBER,
                   p_outcome_id            IN   NUMBER,
                   p_result_id             IN   NUMBER,
                   p_reason_id             IN   NUMBER,
                   p_to_resource_id        IN   NUMBER,
                   p_status                IN   VARCHAR2,
                   x_return_status         OUT NOCOPY  VARCHAR2,
                   x_msg_count             OUT NOCOPY  NUMBER,
                   x_msg_data              OUT NOCOPY  VARCHAR2
                   ) IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_activity_type_id       NUMBER;
  l_result_id              NUMBER;
  l_reason_id              NUMBER;

  badResourceId            EXCEPTION;
  RTError                  EXCEPTION;

  l_message_id             NUMBER;
  l_rt_interaction_id      NUMBER;
  l_version                NUMBER;
  l_email_type             VARCHAR2(1);
  l_customer_id            NUMBER;
  l_count                  NUMBER;
  l_data                   VARCHAR2(300);
  l_ret_status             VARCHAR2(300);
  l_action_id              NUMBER;

  IEM_NO_DATA              EXCEPTION;
  l_resource_id            NUMBER;
  l_noop                   NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT queueToOutbox_pvt;
-- Init vars
  l_api_name               :='queueToOutbox';
  l_api_version_number      :=1.0;
  l_created_by              :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by         :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login       := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_noop                    := 0;

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

-- Get the values that are needed later.
  BEGIN
  l_rt_interaction_id := null;
  SELECT rt_interaction_id, version, email_type, resource_id
  INTO   l_rt_interaction_id, l_version, l_email_type, l_resource_id
  FROM   iem_rt_media_items
  WHERE  rt_media_item_id = p_rt_media_item_id
  AND    expire = G_ACTIVE
  FOR UPDATE NOWAIT;

  IF ((l_version <> p_version) AND (UPPER(l_email_type) = G_OUTBOUND) ) THEN
    x_return_status := 'M';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        NULL;
  END;

  IF ( l_rt_interaction_id is null ) THEN
    raise IEM_NO_DATA;
  END IF;

  IF ( (l_resource_id = p_to_resource_id) AND
       (p_action = 'T' OR p_action = 'H' OR p_action = 'E') ) THEN
     l_noop := 1;
  END IF;

  IF ( x_return_status = FND_API.G_RET_STS_SUCCESS AND l_noop = 0) THEN

  BEGIN
    l_message_id := null;
    SELECT message_id INTO l_message_id FROM iem_rt_media_items
    WHERE rt_interaction_id = l_rt_interaction_id
    AND email_type = G_INBOUND;
  EXCEPTION
    WHEN OTHERS THEN
        NULL;
  END;

  UPDATE iem_rt_media_items
  SET expire = G_QUEUEOUT
  WHERE rt_interaction_id = l_rt_interaction_id and expire <> G_DORMANT;

  if ( p_action_id > 0 ) then
    l_action_id := p_action_id;
  else
    l_action_id := null;
  end if;

  UPDATE iem_rt_interactions
  SET expire = G_QUEUEOUT,
  status = p_status,
  customer_id = decode(p_customer_id, G_NUM_NOP, customer_id, p_customer_id),
  action_id = decode(l_action_id, null, action_id, l_action_id),
  action_item_id = decode(p_activity_type_id,-1, NULL, p_activity_type_id),
  result_id = decode(p_result_id,-1, NULL, p_result_id),
  outcome_id = decode(p_outcome_id,-1, NULL, p_outcome_id),
  reason_id = decode(p_reason_id,-1, NULL, p_reason_id),
  to_resource_id = decode(p_to_resource_id, G_NUM_NOP, to_resource_id, p_to_resource_id)
  WHERE  rt_interaction_id = l_rt_interaction_id
  AND    expire = G_ACTIVE;

  -- mark the post_mdts to 'Q' to prevent this from considered by getmailitemcount().
  if ( l_message_id is not null ) then
    UPDATE IEM_RT_PROC_EMAILS SET queue_status = 'Q'
    WHERE message_id = l_message_id;
  end if;

  END IF;

-------------------End Code------------------------
-- Standard Check Of p_commit.
   IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
   END IF;

EXCEPTION
   WHEN IEM_NO_DATA THEN
      ROLLBACK TO queueToOutbox_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_MSG_INTERCEPTED');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);

   WHEN RTError THEN
        ROLLBACK TO queueToOutbox_pvt;
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
              p_count => x_msg_count,
							p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO queueToOutbox_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO queueToOutbox_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);
   WHEN OTHERS THEN
          ROLLBACK TO queueToOutbox_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END queueToOutbox;


PROCEDURE getNextOutboxItem (p_api_version_number    IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_failed                IN   VARCHAR2,
                           x_return_status         OUT NOCOPY  VARCHAR2,
                           x_msg_count             OUT NOCOPY  NUMBER,
                           x_msg_data              OUT NOCOPY  VARCHAR2,
                           x_rfc822_message_id     OUT NOCOPY  VARCHAR2,
                           x_account_id            OUT NOCOPY  NUMBER,
                           x_account_type          OUT NOCOPY  VARCHAR2,
                           x_email_type            OUT NOCOPY  VARCHAR2,
                           x_status                OUT NOCOPY  VARCHAR2,
                           x_version               OUT NOCOPY  NUMBER,
                           x_rt_media_item_id      OUT NOCOPY  NUMBER,
                           x_rt_interaction_id     OUT NOCOPY  NUMBER,
                           x_oes_id                OUT NOCOPY  NUMBER,
                           x_folder_name           OUT NOCOPY  VARCHAR2,
                           x_folder_uid            OUT NOCOPY  NUMBER,
                           x_customer_id           OUT NOCOPY  NUMBER,
                           x_interaction_id        OUT NOCOPY   NUMBER,
                           x_service_request_id    OUT NOCOPY  NUMBER,
                           x_mc_parameter_id       OUT NOCOPY   NUMBER,
                           x_service_request_action   OUT NOCOPY   VARCHAR,
                           x_contact_id            OUT NOCOPY   NUMBER,
                           x_parent_ih_id          OUT NOCOPY   NUMBER,
                           x_tag_id                OUT NOCOPY   VARCHAR,
                           x_rt_ih_status          OUT NOCOPY   VARCHAR,
                           x_action_id             OUT NOCOPY   NUMBER,
                           x_action_item_id        OUT NOCOPY   NUMBER,
                           x_result_id             OUT NOCOPY   NUMBER,
                           x_reason_id             OUT NOCOPY   NUMBER,
                           x_outcome_id            OUT NOCOPY   NUMBER,
                           x_to_resource_id        OUT NOCOPY   NUMBER,
                           x_resource_id           OUT NOCOPY   NUMBER,
                           x_lead_id               OUT NOCOPY  NUMBER
                           ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;

  l_email_account_id       NUMBER;
  l_agent_account_id       NUMBER;
  l_expire                 VARCHAR2(1);
  l_email_type             VARCHAR2(1);
  l_max_try                NUMBER;
  l_max_try_val            VARCHAR2(20);
  l_try                    NUMBER;
  l_rt_media_item_id       NUMBER;

  InteractnComplt          EXCEPTION;
  badAccountType           EXCEPTION;
  IEM_NO_DATA              EXCEPTION;

  Type get_next is REF CURSOR;
  rt_cur                  get_next;
  l_rt_ih_data            IEM_RT_INTERACTIONS%ROWTYPE;
  e_nowait                EXCEPTION;
  PRAGMA    EXCEPTION_INIT(e_nowait, -54);

  str                     VARCHAR2(500);


BEGIN

-- Standard Start of API savepoint
        SAVEPOINT getNextOutboxItem_pvt;
-- Init vars
  l_api_name               :='getNextOutboxItem';
  l_api_version_number     :=1.0;
  l_email_account_id       := 0;
  l_agent_account_id       := 0;

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
  IF ( p_failed = 'T' ) THEN
    -- Get the item that is failed at last attempt to process
    str := 'SELECT * FROM iem_rt_interactions
            WHERE expire = :1 AND last_update_date < sysdate - 0.007 ORDER BY creation_date FOR UPDATE SKIP LOCKED';
    OPEN rt_cur FOR str USING G_PROCESSING;
  ELSE
    -- Get the item that need to be process.
    str := 'SELECT * FROM iem_rt_interactions
            WHERE expire = :1 ORDER BY creation_date FOR UPDATE SKIP LOCKED';
    OPEN rt_cur FOR str USING G_QUEUEOUT;
  END IF;

  -- find max_try
  IF ( p_failed = 'T' ) THEN

    IEM_PARAMETERS_PVT.select_profile(p_api_version_number  =>1.0,
                 P_INIT_MSG_LIST        => 'F',
                 P_COMMIT               => 'F',
                 p_profile_name         => 'IEM_OP_MAX_FAIL_RETRIES',
                 x_profile_value        => l_max_try_val,
                 x_return_status        => x_return_status,
                 x_msg_count            => x_msg_count,
                 x_msg_data             => x_msg_data );

    IF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
      l_max_try := 3;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      l_max_try := TO_NUMBER(l_max_try_val);
    END IF;

  END IF;

  LOOP
    BEGIN
          l_rt_ih_data := null;
          FETCH rt_cur into l_rt_ih_data;
          IF ( l_rt_ih_data.rt_interaction_id is null ) THEN
            EXIT;
          END IF;
          IF ( p_failed = 'T' ) THEN

            -- check max_try
            if ( l_rt_ih_data.status = 'S' OR l_rt_ih_data.status = 'F') then -- is 'send' or 'autoforward'
              l_email_type := G_OUTBOUND;
            else
              l_email_type := G_INBOUND;
            end if;
            begin
              l_rt_media_item_id := null;
              SELECT rt_media_item_id into l_rt_media_item_id
              FROM iem_rt_media_items
              WHERE rt_interaction_id = l_rt_ih_data.rt_interaction_id
              AND email_type = l_email_type
              AND status <> G_NEWREROUTE
              AND expire <> G_DORMANT;
            exception
              WHEN OTHERS then
                null;
            end;

            if ( l_rt_media_item_id is not null ) then
              begin
                  l_try := 0;
                  SELECT count(outbox_error_id) INTO l_try
                  FROM iem_outbox_errors
                  WHERE rt_media_item_id = l_rt_media_item_id;
              exception
                  WHEN OTHERS then
                    null;
              end;
              if ( l_try < l_max_try ) then
                  EXIT;
              end if;
            end if;

          ELSE -- failed is false
            EXIT;
          END IF;
    EXCEPTION when e_nowait then
          null;
    WHEN OTHERS then
          null;
    END;
  END LOOP;
  close rt_cur;

  IF l_rt_ih_data.rt_interaction_id IS NULL THEN
    x_return_status := 'N';

  ELSE

    -- Mark the item to 'under processing'
    BEGIN
      UPDATE iem_rt_interactions SET expire = G_PROCESSING, last_update_date = SYSDATE
      WHERE rt_interaction_id = l_rt_ih_data.rt_interaction_id;
      commit;
    END;

    x_rt_interaction_id := l_rt_ih_data.rt_interaction_id;
    x_action_id := l_rt_ih_data.action_id;
    x_action_item_id := l_rt_ih_data.action_item_id;
    x_result_id := l_rt_ih_data.result_id;
    x_reason_id := l_rt_ih_data.reason_id;
    x_outcome_id := l_rt_ih_data.outcome_id;
    x_rt_ih_status := l_rt_ih_data.status;
    x_customer_id := l_rt_ih_data.customer_id;
    x_contact_id := l_rt_ih_data.contact_id;



    x_interaction_id := l_rt_ih_data.interaction_id;
    x_parent_ih_id := l_rt_ih_data.parent_interaction_id;
    x_service_request_id := l_rt_ih_data.service_request_id;
    x_service_request_action := l_rt_ih_data.service_request_action;
    x_mc_parameter_id := l_rt_ih_data.mc_parameter_id;
    x_tag_id := l_rt_ih_data.inb_tag_id;
    x_to_resource_id := l_rt_ih_data.to_resource_id;
    x_resource_id := l_rt_ih_data.resource_id;
    x_lead_id := l_rt_ih_data.lead_id;


    -- Do a query to get inbound or outbound media details of the specified rt_interaction_id.
    BEGIN
     x_rt_media_item_id := null;

     if ( l_rt_ih_data.status = 'S' OR l_rt_ih_data.status = 'F' ) then -- is 'send' or 'autoforward'
       l_email_type := G_OUTBOUND;
     else
       l_email_type := G_INBOUND;
     end if;

     SELECT rt_media_item_id, rfc822_message_id,
          folder_name, folder_uid, email_account_id, agent_account_id,
          db_server_id, email_type, status, version, expire
     INTO   x_rt_media_item_id, x_rfc822_message_id,
          x_folder_name, x_folder_uid, l_email_account_id, l_agent_account_id,
          x_oes_id, x_email_type, x_status, x_version, l_expire
     FROM   iem_rt_media_items
     WHERE  rt_interaction_id = l_rt_ih_data.rt_interaction_id
          AND email_type = l_email_type
          AND status <> G_NEWREROUTE
          AND expire <> G_DORMANT;

     EXCEPTION
       WHEN OTHERS THEN
	     raise InteractnComplt;
     END;

    -- The requested media type exists.
    if (x_rt_media_item_id IS NULL ) then
      x_return_status := 'N';
    else


      -- set account type
      IF ((l_email_account_id IS NULL) AND (l_agent_account_id IS NOT NULL)) THEN
        x_account_id := l_agent_account_id;
        x_account_type := G_AGENT_ACCOUNT;
      ELSIF ((l_agent_account_id IS NULL) AND (l_email_account_id IS NOT NULL)) THEN
        x_account_id := l_email_account_id;
        x_account_type := G_MASTER_ACCOUNT;
      ELSIF ((l_agent_account_id IS NOT NULL) AND (l_email_account_id IS NOT NULL)) THEN
        x_account_id := l_agent_account_id;
        x_account_type := G_AGENT_ACCOUNT;
      ELSE
        raise badAccountType;
      END IF;
    end if;
  END IF;

-------------------End Code------------------------
EXCEPTION
   --WHEN IEM_NO_DATA THEN
      --ROLLBACK TO getNextOutboxItem_pvt;
      --x_return_status := FND_API.G_RET_STS_ERROR ;
      --FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
      --FND_MSG_PUB.ADD;
      --FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
      --                            p_count => x_msg_count,
      --                            p_data => x_msg_data);
   WHEN InteractnComplt THEN
      ROLLBACK TO getNextOutboxItem_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_RT_REC');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
   WHEN badAccountType THEN
      ROLLBACK TO getNextOutboxItem_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MESSAGE.SET_NAME('IEM', 'IEM_BAD_ACCOUNT_TYPE');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                                p_count => x_msg_count,
                                p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO getNextOutboxItem_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO getNextOutboxItem_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO getNextOutboxItem_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);
END getNextOutboxItem;


PROCEDURE createRTItem (p_api_version_number    IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2,
  p_commit                IN   VARCHAR2,
  p_message_id            IN   NUMBER, -- IEM_RT_PROC_EMAILS.message_id
  p_to_resource_id        IN   NUMBER, -- agent id you want to stamp to IEM_RT_PROC_EMAILS.agent_id
  p_from_resource_id      IN   NUMBER, -- agent id you want to stamp to IEM_RT_PROC_EMAILS.from_agent_id
  p_status                IN   VARCHAR2, -- this will be stamp to IEM_RT_PROC_EMAILS.mail_item_status
  p_reason                IN   VARCHAR2, -- 'O' for auto-route
  p_interaction_id        IN   NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  x_rt_media_item_id      OUT NOCOPY  NUMBER,
  x_rt_interaction_id     OUT NOCOPY  NUMBER
  ) IS

  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_email_data_rec         IEM_RT_PROC_EMAILS%ROWTYPE;
  l_status                 VARCHAR2(300);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(300);

  l_i_sequence             NUMBER;
  l_m_sequence             NUMBER;
  l_db_server_id           NUMBER;
  l_classification_id      NUMBER;
  l_tag_key_value_tbl      IEM_MAILITEM_PUB.keyVals_tbl_type;
  l_tag_id                 VARCHAR2(30);
  l_sr_id                  NUMBER;
  l_parent_ih_id           NUMBER;
  l_customer_id            NUMBER;
  l_contact_id             NUMBER;
  l_lead_id                NUMBER;
  l_folder_name            VARCHAR2(255);
  l_ih_creator             VARCHAR2(1);

BEGIN

-- Standard Start of API savepoint
   SAVEPOINT createRTItem_pvt;

-- Init vars
  l_api_name               :='createRTItem';
  l_api_version_number      :=1.0;
  l_created_by              :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by         :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login       := NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);
  l_sr_id                    :=null;
  l_parent_ih_id             :=null;
  l_customer_id              :=null;
  l_contact_id               :=null;
  l_lead_id                  :=null;

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

-- Update IEM_RT_PROC_EMAILS with to_agent_id, from_agent_id and p_status
  IEM_MAILITEM_PUB.GetQueueItemData (p_api_version_number => 1.0,
                    p_init_msg_list => 'F',
                    p_commit => 'F',
                    p_message_id => p_message_id,
                    p_from_agent_id => p_from_resource_id,
                    p_to_agent_id => p_to_resource_id,
                    p_mail_item_status => p_status,
                    x_email_data   => l_email_data_rec,
                    x_tag_key_value  => l_tag_key_value_tbl,
                    x_encrypted_id   => l_tag_id,
                    x_return_status  => l_status,
                    x_msg_count  => l_msg_count,
                    x_msg_data  => l_msg_data);

-- Check return status; Proceed on success Or report back in case of error.
    IF (l_status = FND_API.G_RET_STS_SUCCESS) THEN
    -- Success.
    -- Get the name of the route classification from the ID returned above.
    -- This is the name of the folder where the inbound message exists on the
    -- master account.
    -- Changes for R12. Mark the folder as Inbox for autorouted case. bug
    -- 7428636  Ranjan 09/25/2008
  if p_reason='O' then
     l_folder_name:='Inbox';
  else
        SELECT name INTO l_folder_name
        FROM   iem_route_classifications
        WHERE  ROUTE_CLASSIFICATION_ID = l_email_data_rec.RT_CLASSIFICATION_ID;
 end if;

    -- Extract tag key value from key value table
    -- Currently valid system key names:
    -- IEMNBZTSRVSRID for sr id
    -- IEMNINTERACTIONID for interaction id
    -- IEMNAGENTID for agent id
    -- IEMNCUSTOMERID for customer id
    -- IEMNCONTACTID for contact id
    -- IEMNBZSALELEADID for lead id

    FOR i IN 1..l_tag_key_value_tbl.count LOOP
       BEGIN
        IF (l_tag_key_value_tbl(i).key = 'IEMNBZTSRVSRID' ) THEN
           l_sr_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNINTERACTIONID' ) THEN
           l_parent_ih_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNCUSTOMERID' ) THEN
           l_customer_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNCONTACTID' ) THEN
           l_contact_id := TO_NUMBER(l_tag_key_value_tbl(i).value);
        ELSIF (l_tag_key_value_tbl(i).key = 'IEMNBZSALELEADID' ) THEN
           l_lead_id := TO_NUMBER(l_tag_key_value_tbl(i).value);

        END IF;
       END;
    END LOOP;

-- customer id and contact id from tagging supersede the result from
-- email search (i.e. what are in l_email_date_rec)
    IF (l_customer_id is NULL) THEN
      BEGIN
        l_customer_id := l_email_data_rec.CUSTOMER_ID;
        l_contact_id := null;
      END;
    END IF;

-- Record details into the RT tables.
       l_ih_creator := null;
       if ( p_interaction_id is not null ) then
         l_ih_creator := 'Y';
       end if;
       select IEM_RT_INTERACTIONS_S1.nextval into l_i_sequence from DUAL;
       INSERT INTO iem_rt_interactions (
                   rt_interaction_id, resource_id, customer_id, contact_id, type,
                   status, expire, created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, parent_interaction_id,
                   service_request_id, inb_tag_id, interaction_id, ih_creator,
                   lead_id)
              VALUES (
                   l_i_sequence, p_to_resource_id, l_customer_id, l_contact_id,
                   G_INBOUND, G_WORK_IN_PROGRESS, G_ACTIVE, l_created_by,
                   SYSDATE, l_last_updated_by, SYSDATE, l_last_update_login,
                   l_parent_ih_id, l_sr_id, l_tag_id, p_interaction_id, l_ih_creator,
                   l_lead_id
              );
       -- db_server id used by mid-tier to locate accounts
       l_db_server_id := -1;

       select IEM_RT_MEDIA_ITEMS_S1.nextval into l_m_sequence from DUAL;
       INSERT INTO iem_rt_media_items (
                   rt_interaction_id, rt_media_item_id, resource_id,
                   media_id, message_id, rfc822_message_id, folder_name,
                   folder_uid, email_account_id, db_server_id, email_type,
                   status, expire, version, created_by, creation_date,
                   last_updated_by, last_update_date, last_update_login )
              VALUES (
                   l_i_sequence, l_m_sequence, p_to_resource_id,
                   l_email_data_rec.IH_MEDIA_ITEM_ID,
                   l_email_data_rec.MESSAGE_ID,
                   null,
                   l_folder_name,
                   -1,
                   l_email_data_rec.EMAIL_ACCOUNT_ID,
                   l_db_server_id,
                   G_INBOUND, UPPER(p_reason), G_ACTIVE,0, l_created_by, SYSDATE,
                   l_last_updated_by, SYSDATE, l_last_update_login
              );


-- Return Media Values to the JSPs.
       x_rt_media_item_id  := l_m_sequence;
       x_rt_interaction_id := l_i_sequence;

    ELSE
-- Return the error returned by MDT API
       x_return_status := l_status;
       x_msg_count     := l_msg_count;
       x_msg_data      := l_msg_data;

    END IF;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
--       FND_MSG_PUB.Count_And_Get
--			( p_encoded => FND_API.G_TRUE,
--        p_count =>  x_msg_count,
--        p_data  =>    x_msg_data
--			);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO createRTItem_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO createRTItem_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO createRTItem_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

END createRTItem;

PROCEDURE isAgentInboxClean(p_api_version_number    IN   NUMBER,
                           p_init_msg_list         IN   VARCHAR2,
                           p_commit                IN   VARCHAR2,
                           p_resource_id           IN   NUMBER,
                           p_email_account_id      IN   NUMBER,
                           x_is_clean              OUT NOCOPY  BOOLEAN,
                           x_return_status         OUT NOCOPY  VARCHAR2,
                           x_msg_count             OUT NOCOPY  NUMBER,
                           x_msg_data              OUT NOCOPY  VARCHAR2
) IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

  l_count1                 NUMBER;
  l_count2                 NUMBER;
  l_agent_account_id       NUMBER;
  IEM_NO_AGENT_ACCT        EXCEPTION;
  l_user_name              VARCHAR2(100);

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT isAgentInboxClean_pvt;

-- Init vars
  l_api_name               :='isAgentInboxClean';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      :=NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

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
  x_is_clean := false;

  begin
    select agent_id into l_agent_account_id
    from iem_agents where email_account_id = p_email_account_id
    and resource_id = p_resource_id;

  exception
    when others then
      -- find out the user_name
      begin
        select user_name into l_user_name from jtf_rs_resource_extns
        where resource_id = p_resource_id;
      exception
        when others then
          l_user_name := to_char(p_resource_id);
      end;
      raise IEM_NO_AGENT_ACCT;
  end;


    select count(rt_media_item_id) into l_count1 from iem_rt_media_items
    where agent_account_id=l_agent_account_id
    and rt_interaction_id
     in (select rt_interaction_id from iem_rt_interactions where expire <> G_EXPIRE);

    select count(rt_media_item_id) into l_count2 from iem_rt_media_items
    where resource_id= p_resource_id and email_account_id=p_email_account_id
    and rt_interaction_id
     in (select rt_interaction_id from iem_rt_interactions where expire <> G_EXPIRE
         and type = 'I');

  if ( (l_count1 + l_count2) = 0 ) then
    x_is_clean := true;
  end if;
-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
--       FND_MSG_PUB.Count_And_Get
--			( p_encoded => FND_API.G_TRUE,
--        p_count =>  x_msg_count,
--        p_data  =>    x_msg_data
--			);

EXCEPTION
   WHEN IEM_NO_AGENT_ACCT THEN
          ROLLBACK TO isAgentInboxClean_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_AGENT_ACCT');
          FND_MESSAGE.SET_TOKEN('ARG1', l_user_name);
          FND_MESSAGE.SET_TOKEN('ARG2', to_char(p_email_account_id));
          FND_MSG_PUB.ADD;
          FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_TRUE,
            p_count => x_msg_count,
            p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO isAgentInboxClean_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO isAgentInboxClean_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO isAgentInboxClean_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

END isAgentInboxClean;

PROCEDURE updateOutboundMessageID(p_api_version_number    IN   NUMBER,
                                  p_init_msg_list         IN   VARCHAR2,
                                  p_commit                IN   VARCHAR2,
                                  p_rt_media_item_id      IN   NUMBER,
                                  p_message_id            IN   NUMBER,
                                  x_return_status         OUT NOCOPY  VARCHAR2,
                                  x_msg_count             OUT NOCOPY  NUMBER,
                                  x_msg_data              OUT NOCOPY  VARCHAR2
) IS
  l_api_name               VARCHAR2(255);
  l_api_version_number     NUMBER;
  l_created_by             NUMBER;
  l_last_updated_by        NUMBER;
  l_last_update_login      NUMBER;

BEGIN

-- Standard Start of API savepoint
        SAVEPOINT updateOutboundMessageID_pvt;

-- Init vars
  l_api_name               :='updateOutboundMessageID';
  l_api_version_number     :=1.0;
  l_created_by             :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_updated_by        :=NVL(to_number(FND_PROFILE.VALUE('USER_ID')),-1);
  l_last_update_login      :=NVL(to_number(FND_PROFILE.VALUE('LOGIN_ID')), -1);

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

    update iem_rt_media_items
    set message_id = p_message_id
    where rt_media_item_id = p_rt_media_item_id;

  end;

-------------------End Code------------------------
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
--       FND_MSG_PUB.Count_And_Get
--			( p_encoded => FND_API.G_TRUE,
--        p_count =>  x_msg_count,
--        p_data  =>    x_msg_data
--			);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO updateOutboundMessageID_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO updateOutboundMessageID_pvt;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_TRUE,
                  p_count => x_msg_count,
                  p_data => x_msg_data);

   WHEN OTHERS THEN
          ROLLBACK TO updateOutboundMessageID_pvt;
          x_return_status := FND_API.G_RET_STS_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_TRUE,
                                     p_count => x_msg_count,
                                     p_data   => x_msg_data);

END updateOutboundMessageID;

END IEM_CLIENT_PUB;

/
