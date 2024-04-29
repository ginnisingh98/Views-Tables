--------------------------------------------------------
--  DDL for Package Body EGO_PARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_PARTY_PUB" AS
/*$Header: EGOPRTYB.pls 120.10.12010000.2 2010/03/25 09:27:26 shsahu ship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------
  G_PKG_NAME                CONSTANT  VARCHAR2(30) := 'EGO_PARTY_PUB';

   -- refer to bug 2465636
--   G_OWNER_GROUP_REL_TYPE    CONSTANT  VARCHAR2(30) := 'EGO_GROUP_OWNERSHIP';
--   G_OWNER_GROUP_REL_CODE    CONSTANT  VARCHAR2(30) := 'OWNER_OF';

  G_MEMBER_GROUP_REL_TYPE   CONSTANT  VARCHAR2(30) := 'MEMBERSHIP';
  G_MEMBER_GROUP_REL_CODE   CONSTANT  VARCHAR2(30) := 'MEMBER_OF';

  G_DEBUG_LEVEL_UNEXPECTED     NUMBER;
  G_DEBUG_LEVEL_ERROR          NUMBER;
  G_DEBUG_LEVEL_EXCEPTION      NUMBER;
  G_DEBUG_LEVEL_EVENT          NUMBER;
  G_DEBUG_LEVEL_PROCEDURE      NUMBER;
  G_DEBUG_LEVEL_STATEMENT      NUMBER;
  G_CURR_LOG_LEVEL             NUMBER;
  G_DEBUG_LOG_HEAD             VARCHAR2(30);
-- ---------------------------------------------------------------------

--
-- write to debug into concurrent log
--
PROCEDURE code_debug (p_log_level  IN NUMBER
                     ,p_module     IN VARCHAR2
                     ,p_message    IN VARCHAR2
                     ) IS
BEGIN
  IF (p_log_level >= G_CURR_LOG_LEVEL) THEN
    fnd_log.string(log_level => p_log_level
                  ,module    => G_DEBUG_LOG_HEAD||p_module
                  ,message   => p_message
                  );
  END IF;
--  sri_debug(G_DEBUG_LOG_HEAD||p_module||' - '||p_message);
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END code_debug;

   -- For debugging purposes.
   PROCEDURE mdebug (msg IN varchar2) IS
     BEGIN
--       dbms_output.put_line(msg);
   null;
     END mdebug;
-- ---------------------------------------------------------------------

----------------------------------------------------------------------------
-- A. Create_Relationship
----------------------------------------------------------------------------

procedure Create_Relationship (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2,
   p_commit             IN  VARCHAR2,
   p_subject_id         IN  NUMBER,
   p_subject_type       IN  VARCHAR2,
   p_subject_table_name IN  VARCHAR2,
   p_object_id          IN  NUMBER,
   p_object_type        IN  VARCHAR2,
   p_object_table_name  IN  VARCHAR2,
   p_relationship_code  IN  VARCHAR2,
   p_relationship_type  IN  VARCHAR2,
   p_program_name       IN  VARCHAR2,
   p_start_date         IN  DATE,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_relationship_id   OUT NOCOPY NUMBER
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : Create_Relationship
    -- TYPE      : Private
    -- Pre-reqs  : None
    -- FUNCTION  : Create a Relationship between 2 Party Ids.
    --             This will be used for Relationship creation in IPD
    --
    -- Parameters:
    --     IN    : p_api_version    IN  NUMBER  (required)
    --      API Version of this procedure
    --             p_init_msg_level IN  VARCHAR2  (optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the message stack needs to be cleared
    --             p_commit   IN  VARCHAR2  (optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the data should be committed
    --             p_subject_id   IN  NUMBER  (required)
    --      Subject on which the relationship needs to be created
    --      Eg., A person
    --             p_subject_type IN  VARCHAR2  (required)
    --      Type of the subject
    --      Eg., PERSON
    --             p_subject_table_name IN  VARCHAR2  (required)
    --      Table in which the subject is available
    --      Eg., HZ_PARTIES
    --             p_object_id    IN  NUMBER  (required)
    --      Object on which the relationship needs to be created
    --      Eg., A group
    --             p_object_type    IN  VARCHAR2  (required)
    --      Type of the object
    --      Eg., GROUP
    --             p_object_table_name  IN  VARCHAR2  (required)
    --      Table in which the object is available
    --      Eg., HZ_PARTIES
    --             p_relationship_code  IN  VARCHAR2  (required)
    --      Current values are MEMBER_OF wrt subject
    --             p_relationship_type  IN  VARCHAR2 :=  fnd_api.g_MISS_CHAR
    --      Forward OR Backward.  Default is Bi-directional
    --             p_program_name IN  VARCHAR2  (required)
    --      Program name to identify the creator of the record
    --             p_start_date   IN  DATE  (required)
    --      Record is valid from..
    --
    --     OUT   : x_return_status  OUT  NUMBER
    --      Result of all the operations
    --                    FND_API.G_RET_STS_SUCCESS if success
    --                    FND_API.G_RET_STS_ERROR if error
    --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --             x_msg_count    OUT  NUMBER
    --      number of messages in the message list
    --             x_msg_data   OUT  VARCHAR2
    --        if number of messages is 1, then this parameter
    --      contains the message itself
    --             x_relationship_id  OUT  NUMBER
    --      Relationship_Id created between Group AND member
    --      These valuee is stored at
    --      hz_relationships.PARTY_RELATIONSHIP_ID
    --
    -- Called From:
    --    ego_party_pub.create_group
    --    ego_party_pub.add_group_member
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

     l_Sysdate                 DATE   := Sysdate;

     l_api_name     CONSTANT   VARCHAR2(30) := 'CREATE_RELATIONSHIP';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version   CONSTANT  NUMBER  := 1.0;

     -- General variables
     l_revision_id             NUMBER;
     l_success                 BOOLEAN; --boolean for descr. flex valiation
     l_row_id                  VARCHAR2(50);

     l_relationship_id         NUMBER;
     l_member_already_exists   BOOLEAN := FALSE;

     l_party_rel_rec           HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

     l_party_id                NUMBER;
     l_party_number            VARCHAR2(500); --my wild assumed length

    CURSOR member_already_exists (cp_subject_id         IN  NUMBER
                                 ,cp_subject_table_name IN  VARCHAR2
                                 ,cp_object_id          IN  NUMBER
                                 ,cp_object_table_name  IN  VARCHAR2
                                 ,cp_relationship_code  IN  VARCHAR2) IS
    SELECT relationship_id
    FROM   hz_relationships
    WHERE  subject_id        = cp_subject_id
      AND  subject_type      = cp_subject_table_name
      AND  object_id         = cp_object_id
      AND  object_type       = cp_object_table_name
      AND  relationship_code = cp_relationship_code
      AND  status            = 'A'
      AND  SYSDATE  BETWEEN  start_date AND NVL(end_date, SYSDATE);

  BEGIN
    --
    -- Check if the relation already exists
    --
    OPEN member_already_exists (cp_subject_id         => p_subject_id
                               ,cp_subject_table_name => p_subject_table_name
                               ,cp_object_id          => p_object_id
                               ,cp_object_table_name  => p_object_table_name
                               ,cp_relationship_code  => p_relationship_code
                               );
    FETCH member_already_exists INTO l_relationship_id;
    IF member_already_exists%FOUND THEN
      l_member_already_exists := TRUE;
    END IF;
    CLOSE member_already_exists;

    --
    IF l_member_already_exists THEN
      x_relationship_id := l_relationship_id;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_message.set_name('EGO','EGO_RELATION_EXISTS');
      fnd_msg_pub.add;
    ELSE
      -- Standard Start of API savepoint
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        SAVEPOINT EGO_CREATE_RELATIONSHIP;
      END IF;
      mdebug('.  CREATE_RELATIONSHIP:  Creating Relationship .....1...... ');
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
            l_api_name,
            G_PKG_NAME)
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize API message list if necessary.
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
      END IF;

      l_party_rel_rec.subject_id          := p_subject_id;
      l_party_rel_rec.subject_type        := p_subject_type;
      l_party_rel_rec.subject_table_name  := p_subject_table_name;
      l_party_rel_rec.object_id           := p_object_id;
      l_party_rel_rec.object_type         := p_object_type;
      l_party_rel_rec.object_table_name   := p_object_table_name;
      l_party_rel_rec.relationship_code   := p_relationship_code;
      l_party_rel_rec.relationship_type   := nvl(p_relationship_type,chr(0));
      l_party_rel_rec.created_by_module   := p_program_name;
      l_party_rel_rec.start_date          := NVL(p_start_date, SYSDATE);

--      mdebug('.  CREATE_RELATIONSHIP:  Before calling  HZ_RELATIONSHIP_V2PUB.create_relationship');
--      mdebug('.  CREATE_RELATIONSHIP:  params  p_subject_id ' || to_char(p_subject_id) );
--      mdebug('.  CREATE_RELATIONSHIP:  p_subject_type ' || p_subject_type );
--      mdebug('.  CREATE_RELATIONSHIP:  p_subject_table_name ' || p_subject_table_name );
--      mdebug('.  CREATE_RELATIONSHIP:  p_object_id ' || to_char(p_object_id) );
--      mdebug('.  CREATE_RELATIONSHIP:  p_object_type ' || p_object_type );
--      mdebug('.  CREATE_RELATIONSHIP:  p_object_table_name ' || p_object_table_name );
--      mdebug('.  CREATE_RELATIONSHIP:  p_relationship_code ' || p_relationship_code );
--      mdebug('.  CREATE_RELATIONSHIP:  p_relationship_type ' || p_relationship_type );

      HZ_RELATIONSHIP_V2PUB.create_relationship(
                p_init_msg_list        => NVL(p_init_msg_list, 'F'),
                p_relationship_rec     => l_party_rel_rec,
                x_relationship_id      => x_relationship_id,
                x_party_id             => l_party_id,
                x_party_number         => l_party_number,
                x_return_status        => x_return_status,
                x_msg_count            => x_msg_count,
                x_msg_data             => x_msg_data
                );

--      mdebug('.  CREATE_RELATIONSHIP:  Exited from HZ_RELATIONSHIP_V2PUB.create_relationship');
--      mdebug('.  CREATE_RELATIONSHIP:  party_rel_id  '|| to_char(x_relationship_id));
--      mdebug('.  CREATE_RELATIONSHIP:  party_id  '|| to_char(l_party_id));
--      mdebug('.  CREATE_RELATIONSHIP:  x_party_number  '|| l_party_number);
--      mdebug('.  CREATE_RELATIONSHIP:  return_status  '|| x_return_status);
--      mdebug('.  CREATE_RELATIONSHIP:  x_msg_data  ' || x_msg_data);
--      mdebug('.  CREATE_RELATIONSHIP:  x_msg_count  ' || x_msg_count);

    END IF;    -- member already exists
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('.  CREATE_RELATIONSHIP:  Tracing....');
    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data
    );
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_CREATE_RELATIONSHIP;
       END IF;
       mdebug('.  CREATE_RELATIONSHIP:  Ending : Returning ''FND_API.G_EXC_ERROR''');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_CREATE_RELATIONSHIP;
       END IF;
       mdebug('.  CREATE_RELATIONSHIP:  Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR''');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN OTHERS THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_CREATE_RELATIONSHIP;
       END IF;
       mdebug('.  CREATE_RELATIONSHIP:  Ending : Returning UNEXPECTED ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
END Create_Relationship;

----------------------------------------------------------------------------
-- B. Update_Relationship
----------------------------------------------------------------------------
procedure Update_Relationship (
   p_api_version            IN     NUMBER,
   p_init_msg_list          IN     VARCHAR2,
   p_commit                 IN     VARCHAR2,
   p_party_rel_rec          IN     HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE,
   p_object_version_no_rel  IN OUT NOCOPY NUMBER,
   x_return_status          OUT    NOCOPY VARCHAR2,
   x_msg_count              OUT    NOCOPY NUMBER,
   x_msg_data               OUT    NOCOPY VARCHAR2
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : Update_Relationship
    -- TYPE      : Private
    -- Pre-reqs  : An existing Relationship
    -- FUNCTION  : Update a Relationship between 2 Party Ids.
    --
    -- Parameters:
    --     IN    : p_api_version    IN  NUMBER  (required)
    --      API Version of this procedure
    --             p_init_msg_level IN  VARCHAR2  (optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the message stack needs to be cleared
    --             p_commit   IN  VARCHAR2  (optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the data should be committed
    --             p_party_rel_rec  IN  NUMBER  (required)
    --      The party relation record that needs to be updated
    --      Record type -> HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE
    --
    --    IN/OUT : p_object_version_no_rel   IN OUT  NUMBER (required)
    --      Takes in the version of the record to be updated
    --      Returns the version of the record after updation
    --
    --     OUT   : x_return_status  OUT  NUMBER
    --      Result of all the operations
    --                    FND_API.G_RET_STS_SUCCESS if success
    --                    FND_API.G_RET_STS_ERROR if error
    --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --             x_msg_count    OUT  NUMBER
    --      number of messages in the message list
    --             x_msg_data   OUT  VARCHAR2
    --        if number of messages is 1, then this parameter
    --      contains the message itself
    --
    -- Called From:
    --    ego_party_pub.update_group
    --    ego_party_pub.remove_group_member
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

   l_api_name   CONSTANT   VARCHAR2(30) := 'UPDATE_RELATIONSHIP';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
   l_api_version CONSTANT   NUMBER := 1.0;

   l_number         NUMBER ; -- Fix For Bug 2835026

BEGIN
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_UPDATE_RELATIONSHIP;
    END IF;
    l_number  := FND_API.G_MISS_NUM ; -- Fix For Bug 2835026

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API message list if necessary.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    HZ_RELATIONSHIP_V2PUB.update_relationship
        (p_init_msg_list               => NVL(p_init_msg_list, 'F')
        ,p_relationship_rec            => p_party_rel_rec
        ,p_object_version_number       => p_object_version_no_rel
        ,p_party_object_version_number => l_number
        ,x_return_status               => x_return_status
        ,x_msg_count                   => x_msg_count
        ,x_msg_data                    => x_msg_data
        );

    mdebug('.    UPDATE_RELATIONSHIP:  Succesfully updated the relationship ');
    mdebug('.    UPDATE_RELATIONSHIP:  return_status  '|| x_return_status);
    mdebug('.    UPDATE_RELATIONSHIP:  x_msg_data  ' || x_msg_data);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('.    UPDATE_RELATIONSHIP:  Tracing....');

    FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO EGO_UPDATE_RELATIONSHIP;
    END IF;
    mdebug('.    UPDATE_RELATIONSHIP:  Ending : Returning ''FND_API.G_EXC_ERROR''');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
       (p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
       );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO EGO_UPDATE_RELATIONSHIP;
    END IF;
    mdebug('.    UPDATE_RELATIONSHIP:  Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR''');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
       (p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
       );
  WHEN OTHERS THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO EGO_UPDATE_RELATIONSHIP;
    END IF;
    mdebug('.    UPDATE_RELATIONSHIP:  Ending : Returning UNEXPECTED ERROR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
       (p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
       );
END Update_Relationship;


PROCEDURE SetGlobals IS
BEGIN
  --
  -- debug parameter constants
  --
  G_DEBUG_LEVEL_UNEXPECTED := FND_LOG.LEVEL_UNEXPECTED;
  G_DEBUG_LEVEL_ERROR      := FND_LOG.LEVEL_ERROR;
  G_DEBUG_LEVEL_EXCEPTION  := FND_LOG.LEVEL_EXCEPTION;
  G_DEBUG_LEVEL_EVENT      := FND_LOG.LEVEL_EVENT;
  G_DEBUG_LEVEL_PROCEDURE  := FND_LOG.LEVEL_PROCEDURE;
  G_DEBUG_LEVEL_STATEMENT  := FND_LOG.LEVEL_STATEMENT;
  G_DEBUG_LOG_HEAD         := 'fnd.plsql.ego.'||G_PKG_NAME||'.';
  G_CURR_LOG_LEVEL         := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

EXCEPTION
  WHEN OTHERS THEN
    code_debug (p_log_level => G_DEBUG_LEVEL_UNEXPECTED
               ,p_module    => 'SetGlobals'
               ,p_message   => 'Unable to intialize Globals'
               );
END SetGlobals;

--


----------------------------------------------------------------------------
-- 0. Get_Application_id
----------------------------------------------------------------------------
FUNCTION get_application_id  RETURN NUMBER IS
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Create_Group
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Gets the application id of Engineering Groups
   --             Appliation short name = 'EGO'
   --
   -- Parameters:
   --     IN    :  NONE
   --
   --     OUT   :  NONE
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

   l_application_id   fnd_application.application_id%TYPE;

   CURSOR get_ego_application_id IS
      SELECT application_id
      FROM   fnd_application
      WHERE  application_short_name = 'EGO';

   BEGIN

     OPEN get_ego_application_id;
     FETCH get_ego_application_id INTO l_application_id;
     IF get_ego_application_id%NOTFOUND THEN
       l_application_id := -1;
     END IF;
     CLOSE get_ego_application_id;
     RETURN l_application_id;

   EXCEPTION
     WHEN OTHERS THEN
       IF get_ego_application_id%ISOPEN THEN
         CLOSE get_ego_application_id;
       END IF;

   END get_application_id;


----------------------------------------------------------------------------
-- 1. Create_Group
----------------------------------------------------------------------------
procedure Create_Group (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2,
   p_commit             IN  VARCHAR2,
   p_group_name         IN  VARCHAR2,
   p_group_type         IN  VARCHAR2,
   p_description        IN  VARCHAR2,
   p_email_address      IN  VARCHAR2,
   p_creator_person_id  IN  NUMBER,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_group_id          OUT NOCOPY NUMBER
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : CREATE_GROUP
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create a Group.
    --               Creates a record into HZ_PARTIES with party_type = 'GROUP'
    --               Creates the requestor as a member of the GROUP
    --                 (two way relationship -- MEMBER_OF and CONTAINS_MEMBER)
    --
    --           x_group_id   OUT NUMBER
    --             new Group_Id that has been created.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

   --local variables
     l_api_name         CONSTANT   VARCHAR2(30)   := 'CREATE_GROUP';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version      CONSTANT   NUMBER         := 1.0;

     l_group_id             NUMBER;
     l_group_number         VARCHAR2(500); --my wild assumed length

     l_group_rec            HZ_PARTY_V2PUB.GROUP_REC_TYPE;
     l_party_rec            HZ_PARTY_V2PUB.PARTY_REC_TYPE;

     l_contact_point_rec    HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
     l_edi_rec              HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
     l_email_rec            HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
     l_phone_rec            HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
     l_telex_rec            HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
     l_web_rec              HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
     l_contact_point_id     NUMBER;

     l_group_owner_rel_id   NUMBER;
     l_group_member_rel_id  NUMBER;

BEGIN
    -- check if all required parameters are passed to the procedure
    IF (p_api_version IS NULL
        OR  p_group_name IS NULL
        OR  p_group_name IS NULL
        OR  p_group_type IS NULL
        OR  p_creator_person_id IS NULL
        ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
         (p_count        =>      x_msg_count
         ,p_data         =>      x_msg_data
         );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_CREATE_GROUP;
    END IF;

    mdebug('CREATE_GROUP: ....1....');
    --
    -- checking if the caller is calling with correct name and version
    --
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API message list if necessary.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_group_rec.group_name := p_group_name;

    IF ( p_group_type IS NULL  OR  p_group_type = fnd_api.g_MISS_CHAR ) THEN
      l_group_rec.group_type := 'GROUP';
    ELSE
      l_group_rec.group_type := p_group_type;
    END IF;
    ---------------------------------------------------------------------
    --  INFORMATION REGARDING USING FND_API.G_MISS_CHAR
    --  while inserting data the following code is used by API
    --        DECODE( X_LOCATION, FND_API.G_MISS_CHAR, NULL, X_LOCATION)
    ---------------------------------------------------------------------
    --
    -- getting the application id
    --
    l_group_rec.application_id := EGO_PARTY_PUB.get_application_id;
    l_group_rec.created_by_module := CREATED_BY_MODULE;

    l_group_rec.party_rec := l_party_rec;
    fnd_profile.put('HZ_GENERATE_PARTY_NUMBER','Y');
    mdebug('CREATE_GROUP  Before calling HZ_PARTY_V2PUB.create_group');
    HZ_PARTY_V2PUB.create_group
        (p_init_msg_list  =>  NVL(p_init_msg_list, 'F')
        ,p_group_rec      =>  l_group_rec
        ,x_party_id       =>  l_group_id
        ,x_party_number   =>  l_group_number
        ,x_return_status  =>  x_return_status
        ,x_msg_count      =>  x_msg_count
        ,x_msg_data       =>  x_msg_data
        );
    mdebug('CREATE_GROUP: HZ_PARTY_V2PUB.create_group call complete : groupId => '||l_group_id);
    mdebug('CREATE_GROUP: return_status  '|| x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO EGO_CREATE_GROUP;
      END IF;
      RETURN;
    ELSE
      --
      -- l_group_rec doesnt have mission_statement as its attribute.
      -- Refer to BUG 2467872
      --
      UPDATE hz_parties
        SET mission_statement = p_description
       WHERE party_id = l_group_id;
    END IF;
    --
    -- inserting the email address for the group
    --
    IF p_email_address IS NOT NULL  THEN
      l_contact_point_rec.contact_point_type := 'EMAIL';
      l_contact_point_rec.owner_table_name   := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id     := l_group_id;
      l_contact_point_rec.created_by_module  := CREATED_BY_MODULE;
      l_contact_point_rec.application_id     := EGO_PARTY_PUB.get_application_id;
      l_email_rec.email_address              := p_email_address;

      mdebug(' Before calling  HZ_CONTACT_POINT_V2PUB.create_contact_point');
      HZ_CONTACT_POINT_V2PUB.create_contact_point
         (p_init_msg_list       => NVL(p_init_msg_list, 'F')
         ,p_contact_point_rec   => l_contact_point_rec
         ,p_edi_rec             => l_edi_rec
         ,p_email_rec           => l_email_rec
         ,p_phone_rec           => l_phone_rec
         ,p_telex_rec           => l_telex_rec
         ,p_web_rec             => l_web_rec
         ,x_contact_point_id    => l_contact_point_id
         ,x_return_status       => x_return_status
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
         );
      mdebug('CREATE_GROUP: Returning after call to create_contact_point => '|| to_char(l_contact_point_id));
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.TO_BOOLEAN(p_commit) THEN
          ROLLBACK TO EGO_CREATE_GROUP;
        END IF;
        RETURN;
      END IF;
    ELSE
      mdebug('CREATE_GROUP: No need to call HZ_CONTACT_POINT_V2PUB.create_contact_point');
    END IF;
-- The concept of creating an owner no more exists
-- we are having the concept of Administrator
-- which are done using specific grants
--    --
--    -- A group has an Owner.
--    -- This relation should be created in hz_party_relationships
--    --
--    mdebug('CREATE_GROUP: Before calling  create_relationship for Owner ');
--    l_group_owner_rel_id  := NULL;
--    create_relationship(
--          p_api_version           => 1.0,
--          p_init_msg_list         => NVL(p_init_msg_list, 'F'),
--          p_commit                => NVL(p_commit, 'F'),
--          p_subject_id            => p_owner_person_id,
--          p_subject_type          => 'PERSON',
--          p_subject_table_name    => 'HZ_PARTIES',
--          p_object_id             => l_group_id,
--          p_object_type           => 'GROUP',
--          p_object_table_name     => 'HZ_PARTIES',
--          p_relationship_code     => G_OWNER_GROUP_REL_CODE,
--          p_relationship_type     => G_OWNER_GROUP_REL_TYPE,
--          p_program_name          => G_PKG_NAME,
--          p_start_date            => SYSDATE,
--          x_return_status         => x_return_status,
--          x_msg_count             => x_msg_count,
--          x_msg_data              => x_msg_data,
--          x_relationship_id       => l_group_owner_rel_id
--          );
--
--    -- Output commands to test if Group successfully created.
--    mdebug('CREATE_GROUP: created owner for the group');
--    mdebug('CREATE_GROUP: group_owner_rel_id  '|| to_char(l_group_owner_rel_id));
    mdebug('CREATE_GROUP: return_status  '|| x_return_status);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO EGO_CREATE_GROUP;
      END IF;
      RETURN;
    END IF;
    --
    -- Owner is a default member of the group he created, hence create
    -- a MEMBER_OF relationship between the owner and group.
    --
    -- All the members for Group are created with start_date as Sysdate
    -- and end_date as NULL (i.e. do not expire membership)
    --
    mdebug('CREATE_GROUP: Before calling Add_Group_Member');

    Add_Group_Member(
        p_api_version          => 1.0,
        p_init_msg_list        => NVL(p_init_msg_list, 'F'),
        p_commit               => NVL(p_commit, 'F'),
        p_member_id            => p_creator_person_id,
        p_group_id             => l_group_id,
        p_start_date           => SYSDATE,
        p_end_date             => NULL,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        x_relationship_id      => l_group_member_rel_id
        );

    mdebug('CREATE_GROUP: Successfully exited from Add_Group_Member');
    mdebug('CREATE_GROUP: group_member_rel_id '|| to_char(l_group_member_rel_id));
    mdebug('CREATE_GROUP:  return status  '|| x_return_status );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO EGO_CREATE_GROUP;
      END IF;
      RETURN;
    END IF;
    -- before returning to the caller, set appropriate OUT values
    x_group_id := l_group_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('CREATE_GROUP: Tracing....');

    FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_CREATE_GROUP;
       END IF;
       mdebug('CREATE_GROUP:  Ending - Returning ''FND_API.G_EXC_ERROR''');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_CREATE_GROUP;
       END IF;
       mdebug('CREATE_GROUP: Ending - Returning ''FND_API.G_EXC_UNEXPECTED_ERROR''');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
     WHEN OTHERS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO EGO_CREATE_GROUP;
      END IF;
      mdebug('CREATE_GROUP: Ending - Returning UNEXPECTED ERROR');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
        );

END Create_Group;

----------------------------------------------------------------------------
-- 2. Update_Group
----------------------------------------------------------------------------
procedure Update_Group (
   p_api_version                   IN  NUMBER,
   p_init_msg_list                 IN  VARCHAR2,
   p_commit                        IN  VARCHAR2,
   p_group_id                      IN  NUMBER,
   p_group_name                    IN  VARCHAR2,
   p_description                   IN  VARCHAR2,
   p_email_address                 IN  VARCHAR2,
  -- p_owner_person_id       IN      NUMBER,
   p_object_version_no_group       IN OUT  NOCOPY NUMBER,
   --p_object_version_no_owner_rel   IN OUT  NOCOPY NUMBER,
   x_return_status                OUT  NOCOPY VARCHAR2,
   x_msg_count                    OUT  NOCOPY NUMBER,
   x_msg_data                     OUT  NOCOPY VARCHAR2
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : Update_Group
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update a Group.
    --               p_object_version_number is a mandatory field used to check
    --             whether the record is updated after query
    --             Looks for the following relationships
    --                 If the Group Owner has changed
    --               update the owner relationship record
    --                 If the new Group Owner is not a member
    --               create a new member record
    --             If this operation fails then the category is not
    --              created and error code is returned.
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

    l_api_name    CONSTANT  VARCHAR2(30)  := 'UPDATE_GROUP';
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version CONSTANT  NUMBER    := 1.0;

    -- General variables
    l_group_rec   HZ_PARTY_V2PUB.GROUP_REC_TYPE;
    l_party_rec   HZ_PARTY_V2PUB.PARTY_REC_TYPE;
    l_party_rel_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

    l_contact_point_rec HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_edi_rec   HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
    l_email_rec   HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    l_phone_rec   HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_telex_rec   HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    l_web_rec   HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;

    l_curr_owner_id              NUMBER;
    l_curr_member_id             NUMBER;
    l_update_owner               BOOLEAN;
    l_create_member              BOOLEAN;
    l_group_member_rel_id        NUMBER;
    l_group_owner_rel_id         NUMBER;
    l_object_version_no_owner    NUMBER;
    l_contact_point_id           NUMBER;
    l_email_address              VARCHAR2(2000);
    l_object_version_no_contact  NUMBER;

    l_status         hz_contact_points.status%TYPE;
    l_email_format   hz_contact_points.email_format%TYPE;

     -- To store last Modified Date
     l_Sysdate             DATE         := Sysdate;
     l_last_update_date    DATE;
     l_return_status       VARCHAR2(1);
     l_msg_count           NUMBER;
     l_msg_data            VARCHAR2(2000);
     l_relationship_id     NUMBER;
     l_member_found        BOOLEAN := FALSE;
     l_grp_member_id       NUMBER;

--    CURSOR  c_get_owner_details (cp_group_id  IN NUMBER) IS
--        SELECT subject_id, relationship_id, object_version_number
--  FROM   hz_relationships
--  WHERE  object_id = cp_group_id
--    AND  object_type = 'GROUP'
--    AND  subject_type = 'PERSON'
--    AND  relationship_type = G_OWNER_GROUP_REL_TYPE
--    AND  status = 'A'
--    AND  SYSDATE between start_date and NVL(end_date,SYSDATE);

    CURSOR c_is_group_member(cp_group_id  IN  NUMBER
                            ,cp_member_id  IN  NUMBER)  IS
        SELECT subject_id
        FROM   hz_relationships
        WHERE  object_id  = cp_group_id
          AND  object_type = 'GROUP'
          AND  subject_id = cp_member_id
          AND  subject_type = 'PERSON'
          AND  relationship_type = G_MEMBER_GROUP_REL_TYPE
          AND  status = 'A'
          AND  SYSDATE between start_date and NVL(end_date,SYSDATE);

    CURSOR c_get_contact_details (cp_group_id  IN  NUMBER)  IS
        SELECT contact_point_id, object_version_number, email_address, status, email_format
        FROM   hz_contact_points
        WHERE  owner_table_id = cp_group_id
          AND  owner_table_name = 'HZ_PARTIES'
          AND  status = 'A';

BEGIN
    -- check if all required parameters are passed to the procedure
    mdebug('UPDATE_GROUP: ....1.......  ');
    IF (p_api_version IS NULL
        OR  p_group_id   IS NULL
--        OR  p_owner_person_id IS NULL
        OR  p_object_version_no_group IS NULL
--        OR  p_object_version_no_owner_rel IS NULL
       ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    mdebug('UPDATE_GROUP: All required params are passed ');
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT  EGO_UPDATE_GROUP;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API message list if necessary.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    l_group_rec.party_rec.party_id  := p_group_id;
    l_group_rec.group_name          := nvl(p_group_name,chr(0));

    mdebug('UPDATE_GROUP: Before calling HZ_PARTY_V2PUB.update_group');
    -- update the basic information in the group
    HZ_PARTY_V2PUB.update_group
      (p_init_msg_list                => NVL(p_init_msg_list, 'F')
      ,p_group_rec                    => l_group_rec
      ,p_party_object_version_number  => p_object_version_no_group
      ,x_return_status                => l_return_status
      ,x_msg_count                    => l_msg_count
      ,x_msg_data                     => l_msg_data
      );
    mdebug('UPDATE_GROUP: Existed out of HZ_PARTY_V2PUB.update_group with status '''|| l_return_status||'''');
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF FND_API.TO_BOOLEAN(p_commit) THEN
        ROLLBACK TO EGO_UPDATE_GROUP;
      END IF;
      RETURN;
    ELSE
      -- in TCA the update description not done,
      -- Refer to BUG 2467872
      UPDATE hz_parties
        SET mission_statement = p_description
  WHERE party_id = p_group_id;
    END IF;

    OPEN c_get_contact_details (cp_group_id  => p_group_id);
    FETCH c_get_contact_details
      INTO l_contact_point_id, l_object_version_no_contact, l_email_address,
           l_status, l_email_format;
    IF c_get_contact_details%NOTFOUND THEN
      l_email_address := NULL;
    END IF;
    CLOSE c_get_contact_details;

    IF l_email_address IS NULL THEN
      -- no record created earlier
      IF p_email_address IS NULL THEN
        -- do not create any records into HZ_CONTACT_POINTS
        mdebug('UPDATE_GROUP: No need to create Contact Point during update of Group');
      ELSE
        -- contact point required.  Need to create one.
        l_contact_point_rec.contact_point_type := 'EMAIL';
        l_contact_point_rec.owner_table_name   := 'HZ_PARTIES';
        l_contact_point_rec.owner_table_id     := p_group_id;
        l_contact_point_rec.created_by_module  := CREATED_BY_MODULE;
        l_contact_point_rec.application_id     := EGO_PARTY_PUB.get_application_id;
        l_email_rec.email_address              := p_email_address;
        mdebug(' UPDATE_GROUP: Creating Contact point now !!! ');
        HZ_CONTACT_POINT_V2PUB.create_contact_point
           (p_init_msg_list       => NVL(p_init_msg_list, 'F')
           ,p_contact_point_rec   => l_contact_point_rec
           ,p_edi_rec             => l_edi_rec
           ,p_email_rec           => l_email_rec
           ,p_phone_rec           => l_phone_rec
           ,p_telex_rec           => l_telex_rec
           ,p_web_rec             => l_web_rec
           ,x_contact_point_id    => l_contact_point_id
           ,x_return_status       => x_return_status
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_API.TO_BOOLEAN(p_commit) THEN
            ROLLBACK TO EGO_UPDATE_GROUP;
          END IF;
          RETURN;
        END IF;
      END IF;
    ELSE
      IF p_email_address IS NULL THEN
        -- the existing contact point needs to be removed.
        mdebug('UPDATE_GROUP: Deleted the existing contact point');
        l_contact_point_rec.primary_flag       := 'N';
        l_email_rec.email_address              := l_email_address;
        l_contact_point_rec.status             := 'I';
      ELSE
  -- update email address in contact_points
        mdebug('UPDATE_GROUP: before calling HZ_CONTACT_POINT_V2PUB.update_contact_point');
        l_email_rec.email_address              := p_email_address;
        l_contact_point_rec.status             := l_status;
      END IF;
      l_email_rec.email_format               := l_email_format;
      l_contact_point_rec.contact_point_id   := l_contact_point_id;
      l_contact_point_rec.contact_point_type := 'EMAIL';
      HZ_CONTACT_POINT_V2PUB.update_contact_point
          (p_init_msg_list           => NVL(p_init_msg_list, 'F')
          ,p_contact_point_rec       => l_contact_point_rec
          ,p_edi_rec                 => l_edi_rec
          ,p_email_rec               => l_email_rec
          ,p_phone_rec               => l_phone_rec
          ,p_telex_rec               => l_telex_rec
          ,p_web_rec                 => l_web_rec
          ,p_object_version_number   => l_object_version_no_contact
          ,x_return_status           => l_return_status
          ,x_msg_count               => l_msg_count
          ,x_msg_data                => l_msg_data
          );
      mdebug('UPDATE_GROUP: Exited from HZ_CONTACT_POINT_V2PUB.update_contact_point with status '''||l_return_status||'''');
      IF l_return_status <> 'S' THEN
        IF FND_API.TO_BOOLEAN(p_commit) THEN
          ROLLBACK TO EGO_UPDATE_GROUP;
        END IF;
        RETURN;
      END IF;
    END IF;
  -- Commented out for 11.5.9 enh
       -- collect all relavent information regarding owner change
   -- OPEN c_get_owner_details (cp_group_id => p_group_id);
    --FETCH c_get_owner_details
   --   INTO l_curr_owner_id, l_group_owner_rel_id, l_object_version_no_owner;
   -- IF c_get_owner_details%NOTFOUND THEN
    --  l_curr_owner_id := NULL;
    --END IF;
    --CLOSE c_get_owner_details;

    --IF l_curr_owner_id IS NOT NULL THEN
     -- IF l_curr_owner_id <> p_owner_person_id THEN
        -- the owner has changed
    --  l_update_owner := TRUE;
  -- check if the new person is already a member in the group
    --  OPEN c_is_group_member (cp_group_id  => p_group_id
    --                         ,cp_member_id => p_owner_person_id);
    --  FETCH c_is_group_member INTO l_curr_member_id;
    --  IF c_is_group_member%FOUND THEN
    --    l_create_member := FALSE;
    --  ELSE
    --    l_create_member := TRUE;
    --  END IF;
   -- CLOSE c_is_group_member;
    --   ELSE
    --     l_update_owner  := FALSE;
   --     l_create_member := FALSE;
  --    END IF;
  --  ELSE
      -- should never occur if Create Group is Successful
   --   mdebug('UPDATE_GROUP:   NO Owner for the Group !!  ');
   --   l_update_owner  := FALSE;
  --    l_create_member := FALSE;
   -- END IF;

    --IF l_update_owner THEN
      --
      -- changing the owner of the group is done in two steps
      --
      -- Step - 1:  make the current owner inactive
      --
     -- l_party_rel_rec.status          := 'I';
     -- l_party_rel_rec.end_date        := SYSDATE;
     -- l_party_rel_rec.relationship_id := l_group_owner_rel_id;

   --   mdebug('UPDATE_GROUP: before deactivating the current owner');
   --  update_relationship
   -- (p_api_version           => 1.0
   -- ,p_init_msg_list   => NVL(p_init_msg_list, 'F')
   -- ,p_commit    => NVL(p_commit, 'F')
   -- ,p_party_rel_rec         => l_party_rel_rec
   -- ,p_object_version_no_rel => p_object_version_no_owner_rel
   -- ,x_return_status   => x_return_status
   -- ,x_msg_count     => x_msg_count
   -- ,x_msg_data    => x_msg_data
  --  );
   --   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   --     ROLLBACK TO EGO_UPDATE_GROUP;
   --     RETURN;
   --   END IF;
   --   mdebug('UPDATE_GROUP: Deactivated the current relationship for owner with status '''||x_return_status||'''');
      --
      -- Step - 2: create the new owner
      --
   --   mdebug('UPDATE_GROUP: before creating the new owner');
   --   create_relationship(
   --       p_api_version           => 1.0,
   --       p_init_msg_list         => NVL(p_init_msg_list, 'F'),
   --       p_commit                => NVL(p_commit, 'F'),
   --       p_subject_id            => p_owner_person_id,
   --       p_subject_type          => 'PERSON',
   --       p_subject_table_name    => 'HZ_PARTIES',
   --       p_object_id             => p_group_id,
   --       p_object_type           => 'GROUP',
   --       p_object_table_name     => 'HZ_PARTIES',
   --       p_relationship_code     => G_OWNER_GROUP_REL_CODE,
   --       p_relationship_type     => G_OWNER_GROUP_REL_TYPE,
   --       p_program_name          => G_PKG_NAME,
   --       p_start_date            => SYSDATE,
   --       x_return_status         => x_return_status,
   --       x_msg_count             => x_msg_count,
   --       x_msg_data              => x_msg_data,
   --       x_relationship_id       => l_group_owner_rel_id
   --       );
 --     mdebug('UPDATE_GROUP: New owner relationship created with status '''||x_return_status||'''');
 --     mdebug('UPDATE_GROUP: New owner relationship id '||to_char(l_group_owner_rel_id));
 --     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  --      ROLLBACK TO EGO_UPDATE_GROUP;
  --      RETURN;
 --     END IF;
 --     IF l_create_member THEN
        -- owner not a member so, create the new member
 --       mdebug('UPDATE_GROUP: before adding the new owner as member to the group ');
 --       mdebug('UPDATE_GROUP: group_id ' || to_char(p_group_id) || ' member_id ' || to_char(p_owner_person_id));
 -- Add_Group_Member(
--          p_api_version          => 1.0,
--          p_init_msg_list        => NVL(p_init_msg_list, 'F'),
--          p_commit               => NVL(p_commit, 'F'),
--    p_member_id            => p_owner_person_id,
--    p_group_id             => p_group_id,
--          p_start_date           => SYSDATE,
--          p_end_date             => NULL,
--          x_return_status        => x_return_status,
--          x_msg_count            => x_msg_count,
--          x_msg_data             => x_msg_data,
--          x_relationship_id      => l_group_member_rel_id
--    );
--       mdebug('UPDATE_GROUP: new owner added as member to the group with status ' ||x_return_status);
--        mdebug('UPDATE_GROUP: new owner''s membership id ' ||to_char(l_group_member_rel_id));
--        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--          ROLLBACK TO EGO_UPDATE_GROUP;
--          RETURN;
--        END IF;
--      END IF;
--    END IF;
  -- End Of Commented Code
    -- Output commands to test if Group successfully created.
    mdebug('UPDATE_GROUP updated group '|| to_char(p_group_id));

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('UPDATE_GROUP Tracing....');

    FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_UPDATE_GROUP;
       END IF;
       mdebug('UPDATE_GROUP Ending : Returning ''FND_API.G_EXC_ERROR'' ERROR');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_UPDATE_GROUP;
       END IF;
       mdebug('UPDATE_GROUP Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR'' ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN OTHERS THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_UPDATE_GROUP;
       END IF;
--       IF c_get_owner_details%ISOPEN THEN
--         CLOSE c_get_owner_details;
--       END IF;
       IF c_is_group_member%ISOPEN THEN
         CLOSE c_is_group_member;
       END IF;
       IF c_get_contact_details%ISOPEN THEN
         CLOSE c_get_contact_details;
       END IF;
       mdebug('UPDATE_GROUP Ending : Returning UNEXPECTED ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
  END update_group;


----------------------------------------------------------------------------
-- 3. Delete_Group
----------------------------------------------------------------------------
procedure Delete_Group (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2,
   p_commit                   IN  VARCHAR2,
   p_group_id                 IN  NUMBER,
   p_object_version_no_group  IN OUT  NOCOPY NUMBER,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : Delete_Group
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete a Group.
    --               p_object_version_no_group is a mandatory field used to check
    --             whether the record is updated after query
    --             Delete the Group, owner and all members of the Group
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

    l_api_name    CONSTANT  VARCHAR2(30)  := 'DELETE_GROUP';
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.
    l_api_version CONSTANT  NUMBER    := 1.0;

    -- General variables
    l_group_rec   HZ_PARTY_V2PUB.GROUP_REC_TYPE;
    l_party_rec   HZ_PARTY_V2PUB.PARTY_REC_TYPE;
    l_party_rel_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

    l_contact_point_rec HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    l_edi_rec   HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
    l_email_rec   HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    l_phone_rec   HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    l_telex_rec   HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    l_web_rec   HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;

    l_curr_owner_id           NUMBER;
    l_curr_member_id          NUMBER;
    l_group_member_rel_id     NUMBER;
    l_group_owner_rel_id      NUMBER;
    l_contact_point_id        NUMBER;
    l_object_version_number   NUMBER;


    CURSOR c_get_group_members(cp_group_id  IN  NUMBER)  IS
       SELECT relationship_id, object_version_number
       FROM   hz_relationships
       WHERE  object_id  = cp_group_id
         AND  relationship_type = G_MEMBER_GROUP_REL_TYPE
         AND  status = 'A'
         AND  SYSDATE between start_date and NVL(end_date,SYSDATE);

--    CURSOR  c_get_group_owner (cp_group_id  IN NUMBER) IS
--       SELECT relationship_id, object_version_number
--       FROM   hz_relationships
--       WHERE  object_id = cp_group_id
--   AND  relationship_type = G_OWNER_GROUP_REL_TYPE
--   AND  status = 'A'
--   AND  SYSDATE between start_date and NVL(end_date,SYSDATE);

    CURSOR  c_get_contact_point (cp_group_id  IN NUMBER) IS
       SELECT contact_point_id, object_version_number
        FROM  hz_contact_points
       WHERE  owner_table_id = cp_group_id
         AND  owner_table_name = 'HZ_PARTIES'
         AND  status = 'A';

  BEGIN
    -- check if all required parameters are passed to the procedure
    IF (p_api_version IS NULL
        OR  p_group_id   IS NULL
        OR  p_object_version_no_group IS NULL
       ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_DELETE_GROUP;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --
    -- delete all the members of the Group
    --
    OPEN c_get_group_members (cp_group_id => p_group_id);
    LOOP
      FETCH c_get_group_members
          INTO l_group_member_rel_id, l_object_version_number;
      EXIT WHEN c_get_group_members%NOTFOUND;
      l_party_rel_rec.status          := 'I';
      l_party_rel_rec.end_date        := SYSDATE;
      l_party_rel_rec.relationship_id := l_group_member_rel_id;
      update_relationship
          (p_api_version           => 1.0
          ,p_init_msg_list         => NVL(p_init_msg_list, 'F')
          ,p_commit                => NVL(p_commit, 'F')
          ,p_party_rel_rec         => l_party_rel_rec
          ,p_object_version_no_rel => l_object_version_number
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.TO_BOOLEAN(p_commit) THEN
          ROLLBACK TO EGO_DELETE_GROUP;
        END IF;
        EXIT;
      END IF;
    END LOOP;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
--
-- The Owner relatioships does not exist any more
--
--    --
--    -- delete the owner(s) of the Group
--    --
--    OPEN c_get_group_owner (cp_group_id => p_group_id);
--    LOOP
--      FETCH c_get_group_owner
--          INTO l_group_owner_rel_id, l_object_version_number;
--      EXIT WHEN c_get_group_owner%NOTFOUND;
--      l_party_rel_rec.status          := 'I';
--      l_party_rel_rec.end_date        := SYSDATE;
--      l_party_rel_rec.relationship_id := l_group_owner_rel_id;
--      update_relationship
--  (p_api_version           => 1.0
--  ,p_init_msg_list   => NVL(p_init_msg_list, 'F')
--  ,p_commit    => NVL(p_commit, 'F')
--  ,p_party_rel_rec         => l_party_rel_rec
--  ,p_object_version_no_rel => l_object_version_number
--  ,x_return_status   => x_return_status
--  ,x_msg_count     => x_msg_count
--  ,x_msg_data    => x_msg_data
--  );
--      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--        ROLLBACK TO EGO_DELETE_GROUP;
--        EXIT;
--      END IF;
--    END LOOP;
--    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--      RETURN;
--    END IF;
    --
    -- remove the contact point(s)
    --
    OPEN c_get_contact_point (cp_group_id => p_group_id);
    LOOP
      FETCH c_get_contact_point
          INTO l_contact_point_id, l_object_version_number;
      EXIT WHEN c_get_contact_point%NOTFOUND;
      l_contact_point_rec.status           := 'I';
      l_contact_point_rec.contact_point_id := l_contact_point_id;
      HZ_CONTACT_POINT_V2PUB.update_contact_point
        (p_init_msg_list          => NVL(p_init_msg_list, 'F')
        ,p_contact_point_rec      => l_contact_point_rec
        ,p_edi_rec                => l_edi_rec
        ,p_email_rec              => l_email_rec
        ,p_phone_rec              => l_phone_rec
        ,p_telex_rec              => l_telex_rec
        ,p_web_rec                => l_web_rec
        ,p_object_version_number  => l_object_version_number
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
        );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.TO_BOOLEAN(p_commit) THEN
          ROLLBACK TO EGO_DELETE_GROUP;
        END IF;
        EXIT;
      END IF;
    END LOOP;
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RETURN;
    END IF;
    --
    -- delete the Group
    -- setting Party status to 'I'
    --
    l_group_rec.party_rec.party_id  := p_group_id;
    l_group_rec.party_rec.status    := 'I';
    HZ_PARTY_V2PUB.update_group
      (p_init_msg_list                => NVL(p_init_msg_list, 'F')
      ,p_group_rec                    => l_group_rec
      ,p_party_object_version_number  => p_object_version_no_group
      ,x_return_status                => x_return_status
      ,x_msg_count                    => x_msg_count
      ,x_msg_data                     => x_msg_data
      );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.TO_BOOLEAN(p_commit) THEN
          ROLLBACK TO EGO_DELETE_GROUP;
        END IF;
        RETURN;
      END IF;


    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('Tracing....');

    FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );


   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_DELETE_GROUP;
       END IF;
       mdebug('DELETE_GROUP Ending : Returning ''FND_API.G_EXC_ERROR'' ERROR');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_DELETE_GROUP;
       END IF;
       mdebug('DELETE_GROUP Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR'' ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
    WHEN OTHERS THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_DELETE_GROUP;
       END IF;
       mdebug('DELETE_GROPU Ending : Returning UNEXPECTED ERROR');
       IF c_get_group_members%ISOPEN THEN
         CLOSE c_get_group_members;
       END IF;
--       IF c_get_group_owner%ISOPEN THEN
--         CLOSE c_get_group_owner;
--       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
        );

  END delete_group;


----------------------------------------------------------------------------
-- 4. Add_Group_Member
----------------------------------------------------------------------------
procedure Add_Group_Member (
   p_api_version        IN  NUMBER,
   p_init_msg_list      IN  VARCHAR2,
   p_commit             IN  VARCHAR2,
   p_member_id          IN  NUMBER,
   p_group_id           IN  NUMBER,
   p_start_date         IN  DATE,
   p_end_date           IN  DATE,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   x_relationship_id   OUT NOCOPY NUMBER
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : Add_Group_Member
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Add a member to a Group.
    --             Creates two way relationship between  Member and Group
    --             Forward relation  person -> MEMBER_OF       -> group
    --             Reverse relation  group  <- CONTAINS_MEMBER <- person
    --
    --             If this operation fails then the category is not
    --              created and error code is returned.
    --
    --           x_relationship_id    OUT NUMBER
    --             Relationship_Id that has been created between Group_id.
    --             and the Member_Id, which is finally stored in
    --             hz_relationships.PARTY_RELATIONSHIP_ID
    --
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

   l_Sysdate         DATE     := Sysdate;
   l_api_name   CONSTANT   VARCHAR2(30)   := 'ADD_GROUP_MEMBER';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
   l_api_version  CONSTANT   NUMBER        := 1.0;

   -- General variables
   l_return_status      VARCHAR2(50);
   l_error_code         NUMBER;

  BEGIN
    -- check if all required parameters are passed to the procedure
    IF (p_api_version  IS NULL
        OR  p_group_id   IS NULL
        OR  p_member_id  IS NULL) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_ADD_GROUP_MEMBER;
    END IF;

    mdebug('ADD_GROUP_MEMBER: ........1........ ');
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    mdebug('ADD_GROUP_MEMBER: Setting local values ');

    create_relationship(
          p_api_version         => 1.0,
          p_init_msg_list       => NVL(p_init_msg_list, 'F'),
          p_commit              => NVL(p_commit, 'F'),
          p_subject_id          => p_member_id,
          p_subject_type        => 'PERSON',
          p_subject_table_name  => 'HZ_PARTIES',
          p_object_id           => p_group_id,
          p_object_type         => 'GROUP',
          p_object_table_name   => 'HZ_PARTIES',
          p_relationship_code   => G_MEMBER_GROUP_REL_CODE,
          p_relationship_type   => G_MEMBER_GROUP_REL_TYPE,
          p_program_name        => CREATED_BY_MODULE,
          p_start_date          => NVL(p_start_date, SYSDATE),
          x_return_status       => x_return_status,
          x_msg_count           => x_msg_count,
          x_msg_data            => x_msg_data,
          x_relationship_id     => x_relationship_id
          );

--  mdebug('ADD_GROUP_MEMBER: created party_relationship');
--        mdebug('ADD_GROUP_MEMBER: party_rel_id  '|| to_char(x_relationship_id)||' return_status  '|| x_return_status);
--        mdebug('ADD_GROUP_MEMBER: party_id  '|| to_char(p_member_id)||' group_id  '|| to_char(p_group_id));
--        mdebug('ADD_GROUP_MEMBER: x_msg_data  ' || x_msg_data);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF FND_API.TO_BOOLEAN(p_commit) THEN
            ROLLBACK TO EGO_ADD_GROUP_MEMBER;
          END IF;
          RETURN;
        END IF;

     -- confirmed from Deb that this will never return error
  EGO_DOM_WS_INTERFACE_PUB.Add_OFO_Group_Member
      (p_api_version    => 1.0
      ,p_init_msg_list  => NVL(p_init_msg_list, 'F')
      ,p_commit         => NVL(p_commit, 'F')
      ,p_group_id       => p_group_id
      ,p_member_id      => p_member_id
      ,x_return_status  => x_return_status
      ,x_msg_count      => x_msg_count
      ,x_msg_data       => x_msg_data
      );

-- commented out for not giving a grant to the member
--    mdebug('ADD_GROUP_MEMBER:  Before calling EGO_SECURITY_PUB.GRANT_ROLE ');
--    mdebug('ADD_GROUP_MEMBER:  p_api_version => 1.0,  p_role_name = ''EGO_VIEW_GROUP_MEMBERS'', ');
--    mdebug('ADD_GROUP_MEMBER:  p_object_name => ''EGO_GROUP'',  p_instance_type => ''INSTANCE'', ');
--    mdebug('ADD_GROUP_MEMBER:  p_object_key => ' ||to_char(p_group_id) ||',  p_party_id => ' || to_char(p_member_id)||', ');
--    mdebug('ADD_GROUP_MEMBER:  p_start_date => ' ||TO_CHAR(NVL(p_start_date, SYSDATE),'DD-MON-YYYY')||',  p_end_date =>  NULL');

--    EGO_SECURITY_PUB.grant_role
--        (p_api_version       => 1.0
--  ,p_role_name         => 'EGO_VIEW_GROUP_MEMBERS'
--  ,p_object_name       => 'EGO_GROUP'
--  ,p_instance_type     => 'INSTANCE'
--  ,p_object_key        => p_group_id
--  ,p_party_id          => p_member_id
--  ,p_start_date        => NVL(p_start_date,SYSDATE)
--  ,p_end_date          => NULL
--  ,x_return_status     => l_return_status
--  ,x_errorcode         => l_error_code
--  );
--    mdebug('ADD_GROUP_MEMBER:  Successfully exited from EGO_SECURITY_PUB.grant_role ');
--    mdebug('ADD_GROUP_MEMBER:  return status '|| l_return_status );
--    mdebug('ADD_GROUP_MEMBER:  error_code '|| l_error_code );
--    --
--    -- EGO Security pub returns T if the action is success
--    -- and  F on failure
--    --
--    IF l_return_status <> 'T' THEN
--      x_return_status := FND_API.G_RET_STS_ERROR;
--      ROLLBACK TO EGO_ADD_GROUP_MEMBER;
--      RETURN;
--    ELSE
--      x_return_status := FND_API.G_RET_STS_SUCCESS;
--    END IF;
--    -- Standard check of p_commit.
-- Commenting by Sridhar ends here (conf call with Wasi on 12-feb-2003)

    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('ADD_GROUP_MEMBER Tracing....');

    FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );


   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_ADD_GROUP_MEMBER;
       END IF;
       mdebug('ADD_GROUP_MEMBER Ending : Returning ''FND_API.G_EXC_ERROR''');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_ADD_GROUP_MEMBER;
       END IF;
       mdebug('ADD_GROUP_MEMBER Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR''');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN OTHERS THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_ADD_GROUP_MEMBER;
       END IF;
       mdebug('ADD_GROUP_MEMBER Ending : Returning UNEXPECTED ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME,
                l_api_name
          );
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
END Add_Group_Member;


----------------------------------------------------------------------------
-- 5. Remove_Group_Member
----------------------------------------------------------------------------
procedure Remove_Group_Member (
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2,
   p_commit                 IN  VARCHAR2,
   p_relationship_id        IN  NUMBER,
   p_object_version_no_rel  IN OUT  NOCOPY NUMBER,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
   ) IS
    ------------------------------------------------------------------------
    -- Start of comments
    -- API name  : Remove_Group_Member
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Remove a Member from Group.
    --
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------
    l_api_name    CONSTANT  VARCHAR2(30)   := 'REMOVE_GROUP_MEMBER';
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.

    l_api_version CONSTANT  NUMBER  := 1.0;
    l_return_status     VARCHAR2(10);

    l_party_rel_rec HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;

    l_member_id   NUMBER;
    L_GRANT_GUID                   VARCHAR2(100);
    x_ret_status                   VARCHAR2(1);
    l_group_id                     HZ_PARTIES.PARTY_ID%TYPE;
    x_errorcode                    NUMBER;

  CURSOR get_grant_guid_cur (cp_party_id    NUMBER,
                             cp_instance_id NUMBER)
  IS
    SELECT grants.grant_guid
    FROM fnd_grants grants,
      fnd_menus menus,
      fnd_objects obj
    WHERE menus.menu_name='EGO_VIEW_GROUP_MEMBERS'
    AND menus.menu_id=grants.menu_id
    AND obj.object_id=grants.object_id
    AND obj.obj_name='EGO_GROUP'
    AND grants.instance_pk1_value=cp_instance_id
    AND grantee_key='HZ_PARTY:'||cp_party_id;


  BEGIN
    -- check if all required parameters are passed to the procedure
    IF (p_api_version IS NULL
        OR  p_relationship_id   IS NULL
        OR  p_object_version_no_rel IS NULL
  ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_REMOVE_GROUP_MEMBER;
    END IF;

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;
    IF (p_relationship_id IS NOT NULL) THEN
    -- added Directional flag in where clause since two records are getting returned for each relationship one forward and one backward
      SELECT subject_id, object_id
        INTO l_member_id, l_group_id
        FROM hz_relationships
       WHERE RELATIONSHIP_ID = p_relationship_id
         AND directional_flag = 'F';

      l_party_rel_rec.status          := 'I';
      l_party_rel_rec.end_date        := SYSDATE;
      l_party_rel_rec.relationship_id := p_relationship_id;

      update_relationship
         (p_api_version           => 1.0
         ,p_init_msg_list         => NVL(p_init_msg_list, 'F')
         ,p_commit                => NVL(p_commit, 'F')
         ,p_party_rel_rec         => l_party_rel_rec
         ,p_object_version_no_rel => p_object_version_no_rel
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF FND_API.TO_BOOLEAN(p_commit) THEN
          ROLLBACK TO EGO_REMOVE_GROUP_MEMBER;
        END IF;
        RETURN;
      END IF;
    ELSE
       mdebug('No member id provided!');
       FND_MESSAGE.Set_Name('EGO', 'EGO_GRP_MEMB_CANNOT_DELETE');
       FND_MSG_PUB.Add;
       RAISE fnd_api.g_EXC_ERROR;
    END IF;
    OPEN get_grant_guid_cur (cp_party_id    => l_member_id,
                             cp_instance_id => l_group_id);
    FETCH get_grant_guid_cur INTO l_grant_guid;
    IF(get_grant_guid_cur%FOUND) THEN
      CLOSE get_grant_guid_cur;
      EGO_SECURITY_PUB.revoke_grant
      (
         p_api_version       =>p_api_version
         ,p_grant_guid       =>l_grant_guid
         ,x_return_status    =>x_ret_status
         ,x_errorcode        =>x_errorcode
      );
    ELSE
      CLOSE get_grant_guid_cur;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    mdebug('Tracing....');

    FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );


   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_REMOVE_GROUP_MEMBER;
       END IF;
       mdebug('Ending : Returning ERROR');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_REMOVE_GROUP_MEMBER;
       END IF;
       mdebug('Ending : Returning UNEXPECTED ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
        );
     WHEN OTHERS THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_REMOVE_GROUP_MEMBER;
       END IF;
       mdebug('Ending : Returning UNEXPECTED ERROR');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME,
                l_api_name
          );
    END IF;
      FND_MSG_PUB.Count_And_Get
        (p_count        =>      x_msg_count,
         p_data         =>      x_msg_data
        );
END Remove_Group_Member;

----------------------------------------------------------------------------
-- 6. Get_Email_Address (party_id can be person / group Id)
----------------------------------------------------------------------------
procedure Get_Email_Address (
  p_api_version          IN NUMBER,
  p_init_msg_list        IN VARCHAR2,
  p_commit               IN VARCHAR2,
  p_party_id             IN NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_email_address       OUT NOCOPY VARCHAR2
  ) IS
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : Get_Email_Address
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Get Email Address.
   --             Then intention is to Get all e-mail addresses of the
   --             persons in the collapsed list of members for the Group
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

   l_api_name    CONSTANT VARCHAR2(30)   := 'GET_EMAIL_ADDRESS';
   -- On addition of any Required parameters the major version needs
   -- to change i.e. for eg. 1.X to 2.X.
   -- On addition of any Optional parameters the minor version needs
   -- to change i.e. for eg. X.6 to X.7.

   l_api_version           CONSTANT NUMBER  := 1.0;

   -- General variables
   l_party_type     VARCHAR2(20); -- PERSON / GROUP
   l_email_address      VARCHAR2(500);
   l_concat_email_addresses   VARCHAR2(32767);



     l_revision_id NUMBER;
     l_success     BOOLEAN; --boolean for descr. flex valiation
     l_row_id      VARCHAR2(20);

-- 4574359 this record type is not required
--     l_person_rec  HZ_PARTY_PUB.PERSON_REC_TYPE;

     l_last_update_date DATE;
     l_party_rel_id     NUMBER;
     l_party_id     NUMBER;
     l_group_id     NUMBER;
     l_party_number     VARCHAR2(500); --my wild assumed length
     l_relationship_id  NUMBER;

     --output variables for the HZ_PARTY_PUB.Create_Person call, which
     --need not be passed back to the Calling procedure.
     x_main_id          NUMBER;
     x_profile_id       NUMBER;
     x_party_number     HZ_PARTIES.party_number%TYPE;

   CURSOR c_grp_member_emailaddr (cp_group_id IN NUMBER) IS
    SELECT  member.email_address
    FROM    hz_relationships grp_rel,
            EGO_PEOPLE_V member
    WHERE grp_rel.object_id = cp_group_id
      AND grp_rel.object_type = 'GROUP'
      AND grp_rel.relationship_type = 'MEMBERSHIP'
      AND grp_rel.status = 'A'
      AND grp_rel.start_date <= SYSDATE
      AND NVL(grp_rel.end_date, SYSDATE) >= SYSDATE
      AND grp_rel.subject_type = 'PERSON'
      AND grp_rel.subject_id = member.person_id;

  BEGIN
    -- check if all required parameters are passed to the procedure
    IF (p_api_version IS NULL
        OR  p_party_id  IS NULL
       ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_GET_EMAIL_ADDRESS;
    END IF;

    mdebug('GET_EMAIL_ADDRESSES:  ....1......');

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    mdebug('GET_EMAIL_ADDRESSES:  selecting party type ');
    SELECT party_type
      INTO l_party_type
    FROM hz_parties
    WHERE party_id = p_party_id;

    mdebug('GET_EMAIL_ADDRESSES:  party type selected as ' || l_party_type );
    IF (l_party_type = 'PERSON') THEN

      SELECT email_address
        INTO l_concat_email_addresses
      FROM ego_people_v
      WHERE person_id = p_party_id;
    mdebug('GET_EMAIL_ADDRESSES:  person email address is ' || l_concat_email_addresses);

    ELSIF (l_party_type = 'GROUP') THEN

       --Gathering the Groupmember Persons email addresses.
       OPEN c_grp_member_emailaddr ( cp_group_id  =>  p_party_id );
       LOOP FETCH c_grp_member_emailaddr INTO l_email_address;
         EXIT WHEN c_grp_member_emailaddr%NOTFOUND;
         l_concat_email_addresses := l_concat_email_addresses || l_email_address||', ';
         mdebug('GET_EMAIL_ADDRESSES:  inside loop --  email address is ' || l_email_address);
       END LOOP;
       CLOSE c_grp_member_emailaddr;

       -- Removing the final ','
       l_concat_email_addresses := Substr(l_concat_email_addresses,
            1,
            Length(l_concat_email_addresses)-2
            );
    ELSE -- neither PERSON nor GROUP
      FND_MESSAGE.Set_Name('EGO', 'EGO_INVALID_PARTY_TYPE');
      FND_MSG_PUB.Add;
      RAISE fnd_api.g_EXC_ERROR;
    END IF;

    --finally assign prepared e-mail list to the OUT parameter.
    x_email_address := l_concat_email_addresses;
    mdebug('GET_EMAIL_ADDRESSES:  ' || l_party_type||'''s  Email address : '|| l_concat_email_addresses);
    mdebug('GET_EMAIL_ADDRESSES:  x_return_status  '|| x_return_status);
    mdebug('GET_EMAIL_ADDRESSES:  x_msg_data  ' || x_msg_data);

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( NVL(p_commit, 'F') ) THEN
      COMMIT WORK;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1,
    -- get message info.
    -- The client will directly display the x_msg_data (which is already
    -- translated) if the x_msg_count = 1;
    -- Else i.e if  x_msg_count > 1, client will call the FND_MSG_PUB.Get
    -- Server-side procedure to access the messages, and consolidate them
    -- and display (or) to display one message after another.
    FND_MSG_PUB.Count_And_Get
      (   p_count        =>      x_msg_count,
        p_data         =>      x_msg_data
      );

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_GET_EMAIL_ADDRESS;
       END IF;
       mdebug('GET_EMAIL_ADDRESSES:  Ending : Returning FND_API.G_EXC_ERROR ');
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
         (p_count        =>      x_msg_count,
          p_data         =>      x_msg_data
         );
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_GET_EMAIL_ADDRESS;
       END IF;
       mdebug('GET_EMAIL_ADDRESSES:  Ending : FND_API.G_EXC_UNEXPECTED_ERROR ');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
     WHEN OTHERS THEN
       IF FND_API.TO_BOOLEAN(p_commit) THEN
         ROLLBACK TO EGO_GET_EMAIL_ADDRESS;
       END IF;
       mdebug('GET_EMAIL_ADDRESSES:  Ending : Returning UNEXPECTED ERROR');
       IF c_grp_member_emailaddr%ISOPEN THEN
         CLOSE c_grp_member_emailaddr;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF  FND_MSG_PUB.Check_Msg_Level
      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
            FND_MSG_PUB.Add_Exc_Msg
              ( G_PKG_NAME,
                l_api_name
          );
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );
END Get_Email_Address;


PROCEDURE create_code_assignment (
        p_api_version         IN NUMBER,
        p_init_msg_list       IN VARCHAR2,
        p_commit              IN VARCHAR2,
        p_party_id            IN NUMBER,
        p_category            IN VARCHAR2,
        p_code                IN VARCHAR2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_return_status      OUT NOCOPY VARCHAR2,
        x_msg_data           OUT NOCOPY VARCHAR2,
        x_assignment_id      OUT NOCOPY NUMBER
) IS
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : create_code_assignment
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Get Email Address.
   --             Then intention is to Get all e-mail addresses of the
   --             persons in the collapsed list of members for the Group
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------

    l_class_count NUMBER;
    l_code_assignment_rec HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;
    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.

    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_CODE_ASSIGNMENT';
BEGIN

    -- check if all required parameters are passed to the procedure
    IF (p_api_version IS NULL
        OR  p_party_id  IS NULL
  ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      SAVEPOINT EGO_CREATE_CODE_ASSIGNMENT;
    END IF;

    mdebug('CREATE_CODE_ASSIGNMENT:  ....1......');

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    SELECT COUNT(*)
    INTO l_class_count
    FROM hz_code_assignments
    WHERE owner_table_name = 'HZ_PARTIES'
    AND owner_table_id = p_party_id
    AND class_category = p_category;

    IF ( l_class_count > 0 ) THEN
        x_return_status := 'S';
        RETURN;
    END IF;

    l_code_assignment_rec.owner_table_name := OWNER_TABLE_NAME;
    l_code_assignment_rec.owner_table_id := p_party_id;
    l_code_assignment_rec.class_category := p_category;
    l_code_assignment_rec.class_code := p_code;
    l_code_assignment_rec.primary_flag := PRIMARY_FLAG;
    l_code_assignment_rec.content_source_type := CONTENT_SOURCE_TYPE;
    l_code_assignment_rec.start_date_active := SYSDATE;
    l_code_assignment_rec.status := ACTIVE_STATUS;
    l_code_assignment_rec.created_by_module := CREATED_BY_MODULE;
    l_code_assignment_rec.application_id := APPLICATION_ID;

    HZ_CLASSIFICATION_V2PUB.create_code_assignment
    (
        FND_API.G_FALSE,
        l_code_assignment_rec,
        x_return_status,
        x_msg_count,
        x_msg_data,
        x_assignment_id
    );

EXCEPTION
  WHEN OTHERS THEN
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO EGO_CREATE_CODE_ASSIGNMENT;
    END IF;
    x_return_status := 'F';
END create_code_assignment;


PROCEDURE update_code_assignment (
        p_api_version         IN NUMBER,
        p_init_msg_list       IN VARCHAR2,
        p_commit              IN VARCHAR2,
        p_party_id            IN NUMBER,
        p_category            IN VARCHAR2,
        p_code                IN VARCHAR2,
        x_return_status      OUT NOCOPY VARCHAR2,
        x_msg_count          OUT NOCOPY NUMBER,
        x_msg_data           OUT NOCOPY VARCHAR2
) IS
   ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : create_code_assignment
   -- TYPE      : Public
   -- Pre-reqs  : None
   -- FUNCTION  : Get Email Address.
   --             Then intention is to Get all e-mail addresses of the
   --             persons in the collapsed list of members for the Group
   --
   --
   -- Version: Current Version 1.0
   -- Previous Version :  None
   -- Notes  :
   --
   -- END OF comments
   ------------------------------------------------------------------------
    l_class_count    NUMBER;
    l_assignment_id  NUMBER;
    l_version_number NUMBER;
    l_code_assignment_rec HZ_CLASSIFICATION_V2PUB.CODE_ASSIGNMENT_REC_TYPE;

    -- On addition of any Required parameters the major version needs
    -- to change i.e. for eg. 1.X to 2.X.
    -- On addition of any Optional parameters the minor version needs
    -- to change i.e. for eg. X.6 to X.7.

    l_api_version  CONSTANT NUMBER       := 1.0;
    l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_CODE_ASSIGNMENT';

BEGIN

    -- check if all required parameters are passed to the procedure
    IF (p_api_version IS NULL
        OR  p_party_id  IS NULL
  ) THEN
      fnd_message.set_name('EGO','EGO_MAND_PARAM_MISSING');
      fnd_message.set_token('PROGRAM', G_PKG_NAME || l_api_name);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := 1;
      fnd_msg_pub.Count_And_Get
      (p_count        =>      x_msg_count
      ,p_data         =>      x_msg_data
      );
      RETURN;
    END IF;
    -- Standard Start of API savepoint
    IF FND_API.TO_BOOLEAN(p_commit) THEN
      ROLLBACK TO EGO_UPDATE_CODE_ASSIGNMENT;
    END IF;

    mdebug('UPDATE_CODE_ASSIGNMENT:  ....1......');

    IF NOT FND_API.Compatible_API_Call (l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
      FND_MSG_PUB.initialize;
    END IF;


    SELECT code_assignment_id, object_version_number
    INTO l_assignment_id, l_version_number
    FROM hz_code_assignments
    WHERE owner_table_name = 'HZ_PARTIES'
    AND owner_table_id = p_party_id
    AND class_category = p_category;

    l_code_assignment_rec.owner_table_name := OWNER_TABLE_NAME;
    l_code_assignment_rec.owner_table_id := p_party_id;
    l_code_assignment_rec.class_category := p_category;
    l_code_assignment_rec.class_code := p_code;
    l_code_assignment_rec.code_assignment_id := l_assignment_id;
    l_code_assignment_rec.primary_flag := PRIMARY_FLAG;
    l_code_assignment_rec.content_source_type := CONTENT_SOURCE_TYPE;
    l_code_assignment_rec.start_date_active := SYSDATE;
    l_code_assignment_rec.status := ACTIVE_STATUS;
    l_code_assignment_rec.created_by_module := CREATED_BY_MODULE;
    l_code_assignment_rec.application_id := APPLICATION_ID;

    HZ_CLASSIFICATION_V2PUB.update_code_assignment
    (
        FND_API.G_FALSE,
        l_code_assignment_rec,
        l_version_number,
        x_return_status,
        x_msg_count,
        x_msg_data
    );

EXCEPTION
  WHEN OTHERS THEN
  x_return_status := 'F';
END update_code_assignment
;

PROCEDURE setup_enterprise_user(p_company_id     IN NUMBER
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_msg_count     OUT NOCOPY NUMBER
                               ,x_msg_data      OUT NOCOPY VARCHAR2
                               ) IS
------------------------------------------------------------------------
   -- Start of comments
   -- API name  : setup_enterprise_user
   -- TYPE      : Public
   -- Previous Version :  None
   -- END OF comments
 ------------------------------------------------------------------------
  l_party_id      NUMBER;
  l_request_id    NUMBER;
  l_api_name      VARCHAR2(30) := 'SETUP_ENTERPRISE_USER';
  l_run_cp        BOOLEAN := FALSE;
BEGIN
  setGlobals();
  code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
             ,p_module    => l_api_name
             ,p_message   => 'Started with 4 params: company_id: '||p_company_id
             );
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count     := 0;
  x_msg_data      := NULL;
  SELECT hca.owner_table_id
    INTO l_party_id
    FROM hz_code_assignments hca
   WHERE hca.owner_table_id = p_company_id
     AND hca.owner_table_name = 'HZ_PARTIES'
     AND hca.class_category = 'POS_PARTICIPANT_TYPE'
     AND hca.class_code = 'ENTERPRISE';

  BEGIN

    SELECT hr_employee.party_id person_id
    INTO l_party_id
    FROM fnd_user fnd_user, per_all_people_f hr_employee
    WHERE fnd_user.EMPLOYEE_ID = hr_employee.PERSON_ID
      AND fnd_user.person_party_id = hr_employee.party_id
      AND fnd_user.start_date <= SYSDATE
      AND NVL(fnd_user.end_date, SYSDATE) >= SYSDATE
      AND hr_employee.CURRENT_EMPLOYEE_FLAG = 'Y'
      AND hr_employee.EFFECTIVE_START_DATE <= SYSDATE
      AND NVL(hr_employee.EFFECTIVE_END_DATE,SYSDATE) >= SYSDATE
      AND NOT EXISTS
        (SELECT null
         FROM hz_relationships emp_cmpy
         WHERE emp_cmpy.relationship_code = 'EMPLOYEE_OF'
           AND emp_cmpy.subject_type  = 'PERSON'
           AND emp_cmpy.subject_id = hr_employee.PARTY_ID
           AND emp_cmpy.object_type = 'ORGANIZATION'
           AND NVL(emp_cmpy.start_date,SYSDATE) <= SYSDATE
           AND NVL(emp_cmpy.end_date,SYSDATE) >= SYSDATE
        );
    l_run_cp := TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
                 ,p_module    => l_api_name
                 ,p_message   => 'No Users to process '
                 );
      RETURN;
    WHEN OTHERS THEN
      -- users exist
      l_run_cp := TRUE;
  END;
  IF l_run_cp THEN
    l_request_id := FND_REQUEST.Submit_Request
                       (application => 'EGO'
                       ,program     => 'EGOPRTYSTUP'
                       );
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'Submitted concurrent request: '||l_request_id
               );
  END IF;
  code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
             ,p_module    => l_api_name
             ,p_message   => 'Completed'
             );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    code_debug (p_log_level => G_DEBUG_LEVEL_PROCEDURE
               ,p_module    => l_api_name
               ,p_message   => 'The organization is not Enterprise organization '
               );
    RETURN;
  WHEN OTHERS THEN
    code_debug (p_log_level => G_DEBUG_LEVEL_EXCEPTION
               ,p_module    => l_api_name
               ,p_message   => 'EXCEPTION '||SQLERRM
               );
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count     := 1;
    x_msg_data      := 'Executing - '||G_PKG_NAME||'.'||l_api_name||' '||SQLERRM;
END setup_enterprise_user;


PROCEDURE setup_enterprise_user_cp
       (x_errbuff     OUT NOCOPY VARCHAR2
       ,x_retcode     OUT NOCOPY VARCHAR2
       ) IS
 ------------------------------------------------------------------------
   -- Start of comments
   -- API name  : setup_enterprise_user_cp
   -- TYPE      : Public
   -- Previous Version :  None
   -- END OF comments
 ------------------------------------------------------------------------
  l_api_name          VARCHAR2(30) := 'SETUP_ENTERPRISE_USER_CP';
  l_api_version       NUMBER       := 1.0;
  l_return_status     VARCHAR2(1);
  l_msg_data          VARCHAR2(1000);
  l_party_id          NUMBER;
  l_relationship_id   NUMBER;
  l_org_id            NUMBER;
  l_msg_count         NUMBER;

  --changed query to remove full table scan. Bug#4429524
  --modified the query to reduce the cost bug 4895705
  CURSOR internal_users_wc IS
  SELECT hr_employee.party_id person_id
  FROM fnd_user fnd_user, per_all_people_f hr_employee
  WHERE fnd_user.employee_id = hr_employee.person_id
    AND fnd_user.person_party_id = hr_employee.party_id
    AND fnd_user.start_date <= SYSDATE
    AND NVL(fnd_user.end_date, SYSDATE) >= SYSDATE
    AND hr_employee.current_employee_flag = 'Y'
    AND hr_employee.effective_start_date <= SYSDATE
    AND NVL(hr_employee.effective_end_date,SYSDATE) >= SYSDATE
    AND NOT EXISTS
      (SELECT NULL
       FROM hz_relationships emp_cmpy
       WHERE emp_cmpy.relationship_code = 'EMPLOYEE_OF'
         AND emp_cmpy.subject_type  = 'PERSON'
         AND emp_cmpy.subject_id = hr_employee.party_id
         AND emp_cmpy.object_type = 'ORGANIZATION'
         AND NVL(emp_cmpy.start_date,SYSDATE) <= SYSDATE
         AND NVL(emp_cmpy.end_date,SYSDATE) >= SYSDATE
      );

BEGIN

  SELECT hp.party_id
    INTO l_org_id
    FROM hz_parties hp, hz_code_assignments hca
   WHERE hca.owner_table_id = hp.party_id
     AND hca.owner_table_name = 'HZ_PARTIES'
     AND hca.class_category = 'POS_PARTICIPANT_TYPE'
     AND hca.class_code = 'ENTERPRISE'
     AND hp.status = 'A';

  FND_FILE.put_line(which => fnd_file.log
                   ,buff  => '['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
                               ||'] Default Enterprise id '||l_org_id);

  FOR user_rec IN INTERNAL_USERS_WC  LOOP
    BEGIN
      Create_Relationship (
          p_api_version        => l_api_version,
          p_init_msg_list      => FND_API.G_FALSE,
          p_commit             => FND_API.G_FALSE,
          p_subject_id         => user_rec.PERSON_ID,
          p_subject_type       => 'PERSON',
          p_subject_table_name => 'HZ_PARTIES',
          p_object_id          => l_org_id,
          p_object_type        => 'ORGANIZATION',
          p_object_table_name  => 'HZ_PARTIES',
          p_relationship_code  => 'EMPLOYEE_OF',
          p_relationship_type  => 'POS_EMPLOYMENT',
          p_program_name       => CREATED_BY_MODULE,
          p_start_date         => SYSDATE,
          x_return_status      => l_return_status,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data,
          x_relationship_id    => l_relationship_id);
      FND_FILE.put_line(which => fnd_file.log
                       ,buff  => '['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
                               ||'] Relationship created for '||user_rec.PERSON_ID
                               ||' with status '||l_return_status
                               ||' message '||l_msg_data
                       );
      EXCEPTION
        WHEN OTHERS THEN
      FND_FILE.put_line(which => fnd_file.log
                       ,buff  => '['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
                               ||'] EXCEPTION in creating Relationship for '||user_rec.PERSON_ID
                               ||' with error '||SQLERRM
                       );
          NULL;
    END;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    -- this will come only if there is not default enterprise org setup
      FND_FILE.put_line(which => fnd_file.log
                       ,buff  => '['||To_Char(SYSDATE,'DD-MON-RRRR HH24:MI:SS')
                               ||'] EXCEPTION in getting default enterprise '
                               ||' with error '||SQLERRM
                       );
    NULL;
END setup_enterprise_user_cp;


END EGO_PARTY_PUB;

/
