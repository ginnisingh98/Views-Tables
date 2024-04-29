--------------------------------------------------------
--  DDL for Package Body AP_NOTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_NOTES_PUB" AS
/* $Header: apwnotpb.pls 120.2.12010000.2 2008/08/06 07:51:20 rveliche ship $ */


G_PKG_NAME      CONSTANT VARCHAR2(30):='AP_NOTES_PUB';
G_MODULE_PREFIX CONSTANT VARCHAR2(30):='ap.plsql.AP_NOTES_PUB.';
G_ENTER         CONSTANT VARCHAR2(30):='ENTER';
G_EXIT          CONSTANT VARCHAR2(30):='EXIT';


--
PROCEDURE writeDatatoLob
------------------------------------------------------------------------------
--  Procedure    : writeDatatoLob
------------------------------------------------------------------------------
( p_note_id                     IN         NUMBER                            ,
  p_buffer                      IN         VARCHAR2
)
IS

  Position   INTEGER := 1;

  CURSOR c1
  IS SELECT notes_detail
     FROM  ap_notes
     WHERE note_id = p_note_id
     FOR UPDATE;

BEGIN
  FOR i IN c1
  LOOP
    DBMS_LOB.WRITE(i.notes_detail,LENGTH(p_buffer),position,p_buffer);
  END LOOP;
END WriteDataToLob;
--

/*===========================================================================*/
-- Start of comments
--
--  API NAME             : Create_Note
--  TYPE                 : Public
--  PURPOSE              : This creates a note
--  PRE_REQS             : None
--
--  PARAMETERS           :
--  IN -
--    p_api_version            NUMBER    Required
--    p_init_msg_list          VARCHAR2  Optional default = FND_API.G_FALSE
--    p_commit                 VARCHAR2  Optional default = FND_API.G_FALSE
--    p_source_object_code     VARCHAR2  Required
--    p_source_object_id       NUMBER    Required
--    p_note_type              VARCHAR2  Required
--    p_notes_detail           VARCHAR2  Required
--    p_entered_by             NUMBER    Optional default = fnd_global.user_id
--    p_entered_date           DATE      Optional default = sysdate
--    p_source_lang            VARCHAR2  Optional default = userenv('LANG')
--    p_creation_date          DATE      Optional default = sysdate
--    p_created_by             NUMBER    Optional default = fnd_global.user_id
--    p_last_update_date       DATE      Optional default = sysdate
--    p_last_updated_by        NUMBER    Optional default = fnd_global.user_id
--    p_last_update_login      NUMBER    Optional default = fnd_global.login_id
--  OUT -
--    x_return_status          VARCHAR2(1)
--    x_msg_count              NUMBER
--    x_return_status          VARCHAR2(2000)
--  IN OUT NO COPY -
--
--  VERSION              :
--    Initial version      1.0
--
--  MODIFICATION HISTORY :
--   Date         Author          Description of Changes
--   11-Nov-2003  V Nama          Created
--
--  NOTES                :
--
-- End of comments
/*===========================================================================*/
procedure Create_Note (
  p_api_version                 IN         NUMBER                            ,
  p_init_msg_list               IN         VARCHAR2 := FND_API.G_FALSE       ,
  p_commit                      IN         VARCHAR2 := FND_API.G_FALSE       ,
  x_return_status               OUT NOCOPY VARCHAR2                          ,
  x_msg_count                   OUT NOCOPY NUMBER                            ,
  x_msg_data                    OUT NOCOPY VARCHAR2                          ,
  p_source_object_code          IN         VARCHAR2                          ,
  p_source_object_id            IN         NUMBER                            ,
  p_note_type                   IN         VARCHAR2                          ,
  p_notes_detail                IN         VARCHAR2                          ,
  p_entered_by                  IN         NUMBER   := fnd_global.user_id    ,
  p_entered_date                IN         DATE     := sysdate               ,
  p_source_lang                 IN         VARCHAR2 := userenv('LANG')       ,
  p_creation_date               IN         DATE     := sysdate               ,
  p_created_by                  IN         NUMBER   := fnd_global.user_id    ,
  p_last_update_date            IN         DATE     := sysdate               ,
  p_last_updated_by             IN         NUMBER   := fnd_global.user_id    ,
  p_last_update_login           IN         NUMBER   := fnd_global.login_id
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)  := 'Create_Note';
  l_api_version                 CONSTANT NUMBER        := 1.0;

  l_note_id                              NUMBER;

BEGIN
if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_procedure,G_MODULE_PREFIX||l_api_name,G_ENTER);
end if;

  -- Standard Start of API savepoint
  SAVEPOINT	Create_Note_PUB;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.
    Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Start of API body
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Start of API body');
end if;

  select ap_notes_s.nextval into l_note_id from dual;
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'l_note_id='||l_note_id);
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Calling insert into AP_NOTES');
end if;
  insert into AP_NOTES (
    NOTE_ID,
    SOURCE_OBJECT_CODE,
    SOURCE_OBJECT_ID,
    ENTERED_BY,
    ENTERED_DATE,
    NOTE_TYPE,
    NOTES_DETAIL,
    SOURCE_LANG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    l_note_id,
    p_source_object_code,
    p_source_object_id,
    p_entered_by,
    p_entered_date,
    p_note_type,
    EMPTY_CLOB(), --p_notes_detail
    p_source_lang,
    p_creation_date,
    nvl(p_entered_by,-1),--Bug#6768560
    p_last_update_date,
    nvl(p_entered_by,-1),--Bug#6768560
    nvl(p_last_update_login,-1)
  );

if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'p_notes_detail='||p_notes_detail);
end if;
  IF p_notes_detail is not null THEN
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Calling writedatatolob()');
end if;
    writeDatatoLob(l_note_id,p_notes_detail);
  END IF;

if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'End of API body');
end if;
  -- End of API body.


  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_procedure,G_MODULE_PREFIX||l_api_name,G_EXIT);
end if;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
if ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_exception,G_MODULE_PREFIX||l_api_name,'error - FND_API.G_EXC_ERROR');
end if;
  ROLLBACK TO Create_Note_PUB;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_unexpected,G_MODULE_PREFIX||l_api_name,'error - FND_API.G_EXC_UNEXPECTED_ERROR');
end if;
  ROLLBACK TO Create_Note_PUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

WHEN OTHERS THEN
if ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_exception,G_MODULE_PREFIX||l_api_name,'error - OTHERS:sqlerrm'||sqlerrm);
end if;
  ROLLBACK TO Create_Note_PUB;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

END Create_Note;



/*===========================================================================*/
-- Start of comments
--
--  API NAME             : Delete_Notes
--  PURPOSE              : This deletes all notes associated to a particular
--                         source object and note type. If the note type value
--                         isnt passed the default action is to delete all
--                         notes irrespective of their note types.
--  PRE_REQS             : None
--
--  PARAMETERS           :
--  IN -
--    p_api_version            NUMBER    Required
--    p_init_msg_list          VARCHAR2  Optional default = FND_API.G_FALSE
--    p_commit                 VARCHAR2  Optional default = FND_API.G_FALSE
--    p_source_object_code     VARCHAR2  Required
--    p_source_object_id       NUMBER    Required
--    p_note_type              VARCHAR2  Optional default = G_ALL_NOTE_TYPES
--  OUT -
--    x_return_status          VARCHAR2(1)
--    x_msg_count              NUMBER
--    x_return_status          VARCHAR2(2000)
--  IN OUT NO COPY -
--
--  VERSION              :
--    Initial version      1.0
--
--  MODIFICATION HISTORY :
--   Date         Author          Description of Changes
--   11-Nov-2003  V Nama          Created
--
--  NOTES                :
--
-- End of comments
/*===========================================================================*/
procedure Delete_Notes (
  p_api_version                 IN         NUMBER                            ,
  p_init_msg_list               IN         VARCHAR2 := FND_API.G_FALSE       ,
  p_commit                      IN         VARCHAR2 := FND_API.G_FALSE       ,
  x_return_status               OUT NOCOPY VARCHAR2                          ,
  x_msg_count                   OUT NOCOPY NUMBER                            ,
  x_msg_data                    OUT NOCOPY VARCHAR2                          ,
  p_source_object_code          IN         VARCHAR2                          ,
  p_source_object_id            IN         NUMBER                            ,
  p_note_type                   IN         VARCHAR2 := G_ALL_NOTE_TYPES
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)  := 'Delete_Notes';
  l_api_version                 CONSTANT NUMBER        := 1.0;

BEGIN
if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_procedure,G_MODULE_PREFIX||l_api_name,G_ENTER);
end if;


  -- Standard Start of API savepoint
  SAVEPOINT	Delete_Notes;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.
    Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Start of API body
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Start of API body');
end if;


  IF p_note_type is null THEN
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'p_note_type is null');
end if;
    delete from AP_NOTES
     where SOURCE_OBJECT_CODE = p_source_object_code
       and SOURCE_OBJECT_ID = p_source_object_id
       and NOTE_TYPE is null;
  ELSIF p_note_type = G_ALL_NOTE_TYPES THEN
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'p_note_type='||p_note_type||':deleting all notes');
end if;
    delete from AP_NOTES
     where SOURCE_OBJECT_CODE = p_source_object_code
       and SOURCE_OBJECT_ID = p_source_object_id;
  ELSE
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'p_note_type='||p_note_type||':deleting specific notes');
end if;
    delete from AP_NOTES
     where SOURCE_OBJECT_CODE = p_source_object_code
       and SOURCE_OBJECT_ID = p_source_object_id
       and NOTE_TYPE = p_note_type;
  END IF;

if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'End of API body');
end if;
  -- End of API body.


  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_procedure,G_MODULE_PREFIX||l_api_name,G_EXIT);
end if;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
if ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_exception,G_MODULE_PREFIX||l_api_name,'error - FND_API.G_EXC_ERROR');
end if;
  ROLLBACK TO Delete_Notes;
  x_return_status := FND_API.G_RET_STS_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_unexpected,G_MODULE_PREFIX||l_api_name,'error - FND_API.G_EXC_UNEXPECTED_ERROR');
end if;
  ROLLBACK TO Delete_Notes;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

WHEN OTHERS THEN
if ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_exception,G_MODULE_PREFIX||l_api_name,'error - OTHERS:sqlerrm'||sqlerrm);
end if;
  ROLLBACK TO Delete_Notes;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

END Delete_Notes;



/*===========================================================================*/
-- Start of comments
--
--  API NAME             : Copy_Notes
--  TYPE                 : Public
--  PURPOSE              : This copies all notes associated to a particular
--                         source object into new notes associated to another
--                         source object.
--  PRE_REQS             : None
--
--  PARAMETERS           :
--  IN -
--    p_api_version            NUMBER    Required
--    p_init_msg_list          VARCHAR2  Optional default = FND_API.G_FALSE
--    p_commit                 VARCHAR2  Optional default = FND_API.G_FALSE
--    p_old_source_object_code VARCHAR2  Required
--    p_old_source_object_id   NUMBER    Required
--    p_new_source_object_code VARCHAR2  Required
--    p_new_source_object_id   NUMBER    Required
--  OUT -
--    x_return_status          VARCHAR2(1)
--    x_msg_count              NUMBER
--    x_return_status          VARCHAR2(2000)
--  IN OUT NO COPY -
--
--  VERSION              :
--    Initial version      1.0
--
--  MODIFICATION HISTORY :
--   Date         Author          Description of Changes
--   11-Nov-2003  V Nama          Created
--
--  NOTES                : If the source and destination source objects are
--                         same, API returns after adding error message
--                         OIE_NOTES_COPY_ON_ITSELF_ERR to the message list.
--
-- End of comments
/*===========================================================================*/
procedure Copy_Notes (
  p_api_version                 IN         NUMBER                            ,
  p_init_msg_list               IN         VARCHAR2 := FND_API.G_FALSE       ,
  p_commit                      IN         VARCHAR2 := FND_API.G_FALSE       ,
  x_return_status               OUT NOCOPY VARCHAR2                          ,
  x_msg_count                   OUT NOCOPY NUMBER                            ,
  x_msg_data                    OUT NOCOPY VARCHAR2                          ,
  p_old_source_object_code      IN         VARCHAR2                          ,
  p_old_source_object_id        IN         NUMBER                            ,
  p_new_source_object_code      IN         VARCHAR2                          ,
  p_new_source_object_id        IN         NUMBER
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)  := 'Copy_Notes';
  l_api_version                 CONSTANT NUMBER        := 1.0;

BEGIN
if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_procedure,G_MODULE_PREFIX||l_api_name,G_ENTER);
end if;


  -- Standard Start of API savepoint
  SAVEPOINT	Copy_Notes;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.
    Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Start of API body
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Start of API body');
end if;

if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,
  ' p_old_source_object_code='||p_old_source_object_code||
  ':p_old_source_object_id='||p_old_source_object_id||
  ':p_new_source_object_code='||p_new_source_object_code||
  ':p_new_source_object_id='||p_new_source_object_id);
end if;

  --verify old and new source objects are not same
  IF p_old_source_object_code = p_new_source_object_code AND
     p_old_source_object_id = p_new_source_object_id
  THEN
if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'old and new source objects are same!');
end if;
    FND_MESSAGE.SET_NAME('SQLAP','OIE_NOTES_COPY_ON_ITSELF_ERR');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Calling insert into AP_NOTES');
end if;
  insert into AP_NOTES (
    NOTE_ID,
    SOURCE_OBJECT_CODE,
    SOURCE_OBJECT_ID,
    ENTERED_BY,
    ENTERED_DATE,
    NOTE_TYPE,
    NOTES_DETAIL,
    SOURCE_LANG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  )
  select
    AP_NOTES_S.nextval,
    p_new_source_object_code,
    p_new_source_object_id,
    ENTERED_BY,
    ENTERED_DATE,
    NOTE_TYPE,
    NOTES_DETAIL,
    SOURCE_LANG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  from AP_NOTES
  where source_object_code = p_old_source_object_code
    and source_object_id = p_old_source_object_id;

if ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_statement,G_MODULE_PREFIX||l_api_name,'Start of API body');
end if;
  -- End of API body.


  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

if ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_procedure,G_MODULE_PREFIX||l_api_name,G_EXIT);
end if;
EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
if ( FND_LOG.LEVEL_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_exception,G_MODULE_PREFIX||l_api_name,'error - FND_API.G_EXC_ERROR');
end if;
  ROLLBACK TO Copy_Notes;
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
if ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_unexpected,G_MODULE_PREFIX||l_api_name,'error - FND_API.G_EXC_UNEXPECTED_ERROR');
end if;
  ROLLBACK TO Copy_Notes;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

WHEN OTHERS THEN
if ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
fnd_log.string(fnd_log.level_exception,G_MODULE_PREFIX||l_api_name,'error - OTHERS:sqlerrm'||sqlerrm);
end if;
  ROLLBACK TO Copy_Notes;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data);

END Copy_Notes;



END AP_NOTES_PUB;

/
