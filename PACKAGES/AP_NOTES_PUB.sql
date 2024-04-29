--------------------------------------------------------
--  DDL for Package AP_NOTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_NOTES_PUB" AUTHID CURRENT_USER AS
/* $Header: apwnotps.pls 115.0 2003/11/11 19:26:35 vnama noship $ */

G_ALL_NOTE_TYPES      CONSTANT VARCHAR2(30):='ALL_NOTE_TYPES';

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
);



/*===========================================================================*/
-- Start of comments
--
--  API NAME             : Delete_Notes
--  TYPE                 : Public
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
);



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
);



END AP_NOTES_PUB;

 

/
