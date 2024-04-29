--------------------------------------------------------
--  DDL for Package Body PRP_IH_EMAIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_IH_EMAIL_PVT" AS
/* $Header: PRPVIHEB.pls 120.8 2005/12/05 16:08:11 hekkiral ship $ */

  --
  -- Start of Comments
  --
  -- NAME
  --   PRP_IH_EMAIL_PVT
  --
  -- PURPOSE
  --   Private API for interfacing with interaction history APIs.
  --
  -- NOTES
  --
  --+

G_PKG_NAME  CONSTANT VARCHAR2(30):='PRP_IH_EMAIL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12):='PRPVIHEB.pls';


PROCEDURE Create_Email_IH
(
  p_api_version                    IN NUMBER,
  p_init_msg_list                  IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                         IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level               IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_application_id                 IN NUMBER,
  p_party_id                       IN NUMBER,
  p_resource_id                    IN NUMBER,
  p_object_id                      IN NUMBER,
  p_object_type                    IN VARCHAR2,
  p_email_history_id               IN NUMBER,
  p_direction                      IN VARCHAR2,
  p_contact_points_tbl             IN JTF_NUMBER_TABLE,
  p_email_sent_date		   IN DATE,
  x_return_status                  OUT NOCOPY VARCHAR2,
  x_msg_count                      OUT NOCOPY NUMBER,
  x_msg_data                       OUT NOCOPY VARCHAR2
)
IS
  l_api_name                     CONSTANT VARCHAR2(30) := 'Create_Email_IH';
  l_api_version                  CONSTANT NUMBER       := 1.0;

  l_outcome_id                   CONSTANT NUMBER       := 7;   -- Contact
  l_result_id                    CONSTANT NUMBER       := 15;  -- Email Sent
  l_media_item_type              CONSTANT VARCHAR2(30) := 'EMAIL';
  l_module			 CONSTANT VARCHAR2(80) := 'PRP_IH_EMAIL_PVT.Create_Email_IH';

  l_action_id                    NUMBER;
  l_action_item_id               NUMBER;
  l_party_type                   VARCHAR2(30);
  l_contact_party_id             NUMBER;
  l_contact_party_type           VARCHAR2(30);
  l_media_id                     NUMBER;
  l_media_rec                    JTF_IH_PUB.media_rec_type;
  l_mlcs_rec_tbl                 JTF_IH_PUB.mlcs_tbl_type;
  l_interaction_rec              JTF_IH_PUB.interaction_rec_type;
  l_activity_rec_tbl             JTF_IH_PUB.activity_tbl_type;

  CURSOR c1 IS SELECT jtf_ih_media_items_s1.nextval FROM dual;

  CURSOR c_party_type(l_party_id NUMBER) IS
  SELECT HZP.PARTY_TYPE
    FROM HZ_PARTIES        HZP
   WHERE HZP.PARTY_ID = l_party_id;

  CURSOR c_contact_party(l_contact_point_id NUMBER) IS
  SELECT HZP.PARTY_ID,
         HZP.PARTY_TYPE
    FROM HZ_CONTACT_POINTS HCP,
         HZ_PARTIES        HZP
   WHERE HCP.OWNER_TABLE_NAME = 'HZ_PARTIES'
     AND HZP.PARTY_ID = HCP.OWNER_TABLE_ID
     AND HCP.CONTACT_POINT_TYPE = 'EMAIL'
     AND HCP.CONTACT_POINT_ID = l_contact_point_id;

  CURSOR c_party_person(l_party_id NUMBER) IS
  SELECT HPR.PARTY_ID
    FROM HZ_PARTIES             HZP,
         HZ_RELATIONSHIPS HPR
   WHERE HZP.PARTY_ID = HPR.PARTY_ID
     AND HPR.SUBJECT_ID = l_party_id;

  CURSOR c_party_rel(l_party_id NUMBER, l_object_id NUMBER) IS
  SELECT HPR.SUBJECT_ID
    FROM HZ_PARTIES             HZP,
         HZ_RELATIONSHIPS HPR
   WHERE HZP.PARTY_ID = HPR.SUBJECT_ID
     AND HPR.PARTY_ID = l_party_id
     AND HPR.OBJECT_ID = l_object_id;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT CREATE_EMAIL_IH_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

   -- Log Debug Messages.
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_PROCEDURE,
                   MODULE    => l_module,
                   MESSAGE   => 'In Create_Email_IH... Parameters: ' ||'P_Application_id: ' || p_application_id ||
  				' p_party_id: ' || p_party_id || ' p_resource_id: ' || p_resource_id ||
  	       		        ' p_object_type: ' || p_object_type || ' p_object_id: ' || p_object_id ||
  				' p_direction: ' || p_direction );
   END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Collect required variables
  IF (p_application_id = 694) THEN    -- Proposals
    l_action_item_id := 86;           -- Proposal
  ELSIF (p_application_id = 280) THEN -- Sales
    l_action_item_id := 3;            -- Collateral
  ELSIF (p_application_id = 880) THEN -- Quoting
    l_action_item_id := 14;           -- Quote
  ELSIF (p_application_id = 869) THEN -- Sales for Handhelds
    l_action_item_id := 45;           -- Email
  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_direction = 'OUTBOUND') THEN
    l_action_id := 5;                 -- Sent
  ELSIF (p_direction = 'INBOUND') THEN
    l_action_id := 87;                -- Recieved
  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_contact_points_tbl.count = 0) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Get the value of media id from the cursor
  --
  OPEN c1;
  FETCH c1 INTO l_media_id;
  CLOSE c1;

  --
  -- Initialize media record
  --
  l_media_rec.media_id        := l_media_id;
  l_media_rec.start_date_time := sysdate;
  l_media_rec.media_item_type := l_media_item_type;
  l_media_rec.direction       := p_direction;
  l_media_rec.source_item_id  := p_email_history_id;
  l_media_rec.media_item_ref  := 'PRP_DOC';


  -- Log Debug Messages Before Calling Create_MediaItem Method.
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                   MODULE    => l_module,
                   MESSAGE   => 'Before Calling JTF_IH_PUB.Create_MediaItem... Parameters: ' ||'p_resp_appl_id: ' || FND_GLOBAL.resp_appl_id ||
  				' p_resp_id: ' || FND_GLOBAL.resp_id || ' p_user_id: ' || FND_GLOBAL.user_id ||
  				' p_object_type: ' || p_object_type || ' p_object_id: ' || p_object_id ||
  				' p_login_id: ' || FND_GLOBAL.login_id || ' l_media_id: ' || l_media_id ||
  				' l_media_item_type: ' || l_media_item_type);
   END IF;

  --
  -- Call JTF_IH_PUB.Create_MediaItem API
  --
  JTF_IH_PUB.Create_MediaItem
  (
    p_api_version       => 1.0,
    p_init_msg_list     => FND_API.G_FALSE,
    p_commit            => FND_API.G_FALSE,
    p_resp_appl_id      => FND_GLOBAL.resp_appl_id,
    p_resp_id           => FND_GLOBAL.resp_id,
    p_user_id           => FND_GLOBAL.user_id,
    p_login_id          => FND_GLOBAL.login_id,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_media             => l_media_rec,
    p_mlcs              => l_mlcs_rec_tbl
  );


  -- Log Debug Messages After Calling Create_MediaItem Method.
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                      MODULE    => l_module,
                      MESSAGE   => 'After Calling JTF_IH_PUB.Create_MediaItem...Out Parameters: ' ||'x_return_status: ' || x_return_status ||
  				' x_msg_count: ' || x_msg_count || ' x_msg_data: ' || x_msg_data);
   END IF;

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize interaction and activity records
  --

  -- Interaction record
  l_interaction_rec.party_id           := p_party_id;
  l_interaction_rec.resource_id        := p_resource_id;
  l_interaction_rec.outcome_id         := l_outcome_id;
  l_interaction_rec.result_id          := l_result_id;
  l_interaction_rec.handler_id         := p_application_id;
  l_interaction_rec.primary_party_id   := p_party_id;
  l_interaction_rec.object_id	         := p_object_id;
  l_interaction_rec.object_type	    := p_object_type;
  l_interaction_rec.start_date_time    := p_email_sent_date;
  l_interaction_rec.end_date_time      := p_email_sent_date;

  -- Activity record
  l_activity_rec_tbl(1).action_id      := l_action_id;
  l_activity_rec_tbl(1).action_item_id := l_action_item_id;
  l_activity_rec_tbl(1).outcome_id     := l_outcome_id;
  l_activity_rec_tbl(1).result_id      := l_result_id;
  l_activity_rec_tbl(1).media_id       := l_media_id;
  l_activity_rec_tbl(1).doc_id         := p_object_id;
  l_activity_rec_tbl(1).doc_ref        := p_object_type;

  --
  -- Call JTF_IH_PUB.Create_Interaction API
  --

  OPEN c_party_type(p_party_id);
  FETCH c_party_type INTO l_party_type;
  CLOSE c_party_type;

  -- Log Debug Messages.
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	   FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                     MODULE    => l_module,
                     MESSAGE   => 'l_party_type: ' || l_party_type);
   END IF;

  IF (l_party_type = 'ORGANIZATION') THEN

    FOR i IN 1..p_contact_points_tbl.count LOOP

      FOR l_contact_party_rec IN c_contact_party(p_contact_points_tbl(i)) LOOP
        l_contact_party_id   := l_contact_party_rec.party_id;
        l_contact_party_type := l_contact_party_rec.party_type;
      END LOOP;

      IF (l_contact_party_type = 'PERSON') THEN
        l_interaction_rec.contact_party_id     := l_contact_party_id;

        FOR l_party_person_rec IN c_party_person(l_contact_party_id) LOOP
          l_interaction_rec.contact_rel_party_id := l_party_person_rec.party_id;
        END LOOP;

      ELSIF (l_contact_party_type = 'PARTY_RELATIONSHIP') THEN
        l_interaction_rec.contact_rel_party_id := l_contact_party_id;

        FOR l_party_rel_rec IN c_party_rel(l_contact_party_id, p_party_id) LOOP
          l_interaction_rec.contact_party_id := l_party_rel_rec.subject_id;
        END LOOP;
      END IF;


      -- Log Debug Messages Before Calling Create_Interaction Method.
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			   FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                               MODULE    => l_module,
                               MESSAGE   => 'Before Calling JTF_IH_PUB.Create_Interaction...');
      END IF;

      JTF_IH_PUB.Create_Interaction
      (
        p_api_version       => 1.0,
        p_init_msg_list     => FND_API.G_FALSE,
        p_commit            => FND_API.G_FALSE,
        p_resp_appl_id      => FND_GLOBAL.resp_appl_id,
        p_resp_id           => FND_GLOBAL.resp_id,
        p_user_id           => FND_GLOBAL.user_id,
        p_login_id          => FND_GLOBAL.login_id,
        x_return_status     => x_return_status,
        x_msg_count         => x_msg_count,
        x_msg_data          => x_msg_data,
        p_interaction_rec   => l_interaction_rec,
        p_activities        => l_activity_rec_tbl
      );

      -- Log Debug Messages After Calling Create_Interaction Method.
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
		  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                         MODULE    => l_module,
                         MESSAGE   => 'After Calling JTF_IH_PUB.Create_Interaction...Out Parameters: ' ||'x_return_status: ' || x_return_status ||
        				' x_msg_count: ' || x_msg_count || ' x_msg_data: ' || x_msg_data);
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END LOOP;

  ELSIF (l_party_type = 'PERSON') THEN

      -- Log Debug Messages Before Calling Create_Interaction Method.
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
				  FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                                   MODULE    => l_module,
                                   MESSAGE   => 'Before Calling JTF_IH_PUB.Create_Interaction...');
      END IF;

    l_interaction_rec.contact_party_id := p_party_id;
    JTF_IH_PUB.Create_Interaction
    (
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.G_FALSE,
      p_commit            => FND_API.G_FALSE,
      p_resp_appl_id      => FND_GLOBAL.resp_appl_id,
      p_resp_id           => FND_GLOBAL.resp_id,
      p_user_id           => FND_GLOBAL.user_id,
      p_login_id          => FND_GLOBAL.login_id,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      p_interaction_rec   => l_interaction_rec,
      p_activities        => l_activity_rec_tbl
    );

     -- Log Debug Messages After Calling Create_Interaction Method.
     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
			 FND_LOG.STRING(LOG_LEVEL => FND_LOG.LEVEL_STATEMENT,
                             MODULE    => l_module,
                             MESSAGE   => 'After Calling JTF_IH_PUB.Create_Interaction...Out Parameters: ' ||'x_return_status: ' || x_return_status ||
            				' x_msg_count: ' || x_msg_count || ' x_msg_data: ' || x_msg_data);
      END IF;

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Standard check of p_commit.
  IF (FND_API.To_Boolean(p_commit)) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count   =>      x_msg_count,
                            p_data    =>      x_msg_data,
                            p_encoded =>      'F');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_EMAIL_IH_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_EMAIL_IH_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_EMAIL_IH_PVT;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

END Create_Email_IH;


END PRP_IH_EMAIL_PVT;

/
