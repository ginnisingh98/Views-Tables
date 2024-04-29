--------------------------------------------------------
--  DDL for Package JTF_NOTES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_CUHK" AUTHID CURRENT_USER AS
/* $Header: jtfntscs.pls 115.10 2002/11/16 00:27:48 hbouten ship $ */

/*****************************************************************************************
 This is the Customer User Hook API.
 The Customers can add customization procedures here for Pre and Post Processing.
******************************************************************************************/

/* Customer Procedure for pre processing in case of create note */

  PROCEDURE create_note_pre
  ( p_parent_note_id        IN            NUMBER   DEFAULT NULL
  , p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_commit                IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_validation_level      IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , p_org_id                IN            NUMBER   DEFAULT NULL
  , p_source_object_id      IN            NUMBER
  , p_source_object_code    IN            VARCHAR2
  , p_notes                 IN            VARCHAR2
  , p_notes_detail          IN            VARCHAR2 DEFAULT NULL
  , p_note_status           IN            VARCHAR2 DEFAULT 'I'
  , p_entered_by            IN            NUMBER
  , p_entered_date          IN            DATE
  , x_jtf_note_id              OUT NOCOPY NUMBER
  , p_last_update_date      IN            DATE
  , p_last_updated_by       IN            NUMBER
  , p_creation_date         IN            DATE
  , p_created_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
  , p_last_update_login     IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
  , p_attribute1            IN            VARCHAR2 DEFAULT NULL
  , p_attribute2            IN            VARCHAR2 DEFAULT NULL
  , p_attribute3            IN            VARCHAR2 DEFAULT NULL
  , p_attribute4            IN            VARCHAR2 DEFAULT NULL
  , p_attribute5            IN            VARCHAR2 DEFAULT NULL
  , p_attribute6            IN            VARCHAR2 DEFAULT NULL
  , p_attribute7            IN            VARCHAR2 DEFAULT NULL
  , p_attribute8   	        IN            VARCHAR2 DEFAULT NULL
  , p_attribute9            IN            VARCHAR2 DEFAULT NULL
  , p_attribute10           IN            VARCHAR2 DEFAULT NULL
  , p_attribute11           IN            VARCHAR2 DEFAULT NULL
  , p_attribute12           IN            VARCHAR2 DEFAULT NULL
  , p_attribute13           IN            VARCHAR2 DEFAULT NULL
  , p_attribute14           IN            VARCHAR2 DEFAULT NULL
  , p_attribute15           IN            VARCHAR2 DEFAULT NULL
  , p_context               IN            VARCHAR2 DEFAULT NULL
  , p_note_type             IN            VARCHAR2 DEFAULT NULL
  , p_jtf_note_contexts_tab IN            jtf_notes_pub.jtf_note_contexts_tbl_type
                                            DEFAULT  jtf_notes_pub.jtf_note_contexts_tab_dflt
  , x_return_status            OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
   create note */

  PROCEDURE  create_note_post
  ( p_parent_note_id        IN            NUMBER   DEFAULT NULL
  , p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_commit                IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_validation_level      IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , p_org_id                IN            NUMBER   DEFAULT NULL
  , p_source_object_id      IN            NUMBER
  , p_source_object_code    IN            VARCHAR2
  , p_notes                 IN            VARCHAR2
  , p_notes_detail          IN            VARCHAR2 DEFAULT NULL
  , p_note_status           IN            VARCHAR2 DEFAULT 'I'
  , p_entered_by            IN            NUMBER
  , p_entered_date          IN            DATE
  , x_jtf_note_id              OUT NOCOPY NUMBER
  , p_last_update_date      IN            DATE
  , p_last_updated_by       IN            NUMBER
  , p_creation_date         IN            DATE
  , p_created_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
  , p_last_update_login     IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
  , p_attribute1            IN            VARCHAR2 DEFAULT NULL
  , p_attribute2            IN            VARCHAR2 DEFAULT NULL
  , p_attribute3            IN            VARCHAR2 DEFAULT NULL
  , p_attribute4            IN            VARCHAR2 DEFAULT NULL
  , p_attribute5            IN            VARCHAR2 DEFAULT NULL
  , p_attribute6            IN            VARCHAR2 DEFAULT NULL
  , p_attribute7            IN            VARCHAR2 DEFAULT NULL
  , p_attribute8            IN            VARCHAR2 DEFAULT NULL
  , p_attribute9            IN            VARCHAR2 DEFAULT NULL
  , p_attribute10           IN            VARCHAR2 DEFAULT NULL
  , p_attribute11           IN            VARCHAR2 DEFAULT NULL
  , p_attribute12           IN            VARCHAR2 DEFAULT NULL
  , p_attribute13           IN            VARCHAR2 DEFAULT NULL
  , p_attribute14           IN            VARCHAR2 DEFAULT NULL
  , p_attribute15           IN            VARCHAR2 DEFAULT NULL
  , p_context               IN            VARCHAR2 DEFAULT NULL
  , p_note_type             IN            VARCHAR2 DEFAULT NULL
  , p_jtf_note_contexts_tab IN            jtf_notes_pub.jtf_note_contexts_tbl_type
                                            DEFAULT jtf_notes_pub.jtf_note_contexts_tab_dflt
  , x_return_status            OUT NOCOPY VARCHAR2
  , p_jtf_note_id           IN            NUMBER   DEFAULT NULL
   );


  /* Customer Procedure for pre processing in case of
   update note */

  PROCEDURE  update_note_pre
  ( p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_commit                IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_validation_level      IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , p_jtf_note_id           IN            NUMBER
  , p_entered_by            IN            NUMBER
  , p_last_updated_by       IN            NUMBER
  , p_last_update_date      IN            DATE     DEFAULT SYSDATE
  , p_last_update_login     IN            NUMBER   DEFAULT NULL
  , p_notes                 IN            VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  , p_notes_detail          IN            VARCHAR2 DEFAULT NULL
  , p_append_flag           IN            VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  , p_note_status           IN            VARCHAR2 DEFAULT 'I'
  , p_note_type             IN            VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  , p_jtf_note_contexts_tab IN            jtf_notes_pub.jtf_note_contexts_tbl_type
                                            DEFAULT jtf_notes_pub.jtf_note_contexts_tab_dflt
  , x_return_status            OUT NOCOPY VARCHAR2
  );


  /* Customer Procedure for post processing in case of
    update note */

  PROCEDURE update_note_post
  ( p_api_version           IN            NUMBER
  , p_init_msg_list         IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_commit                IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_validation_level      IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
  , p_jtf_note_id           IN            NUMBER
  , p_entered_by            IN            NUMBER
  , p_last_updated_by       IN            NUMBER
  , p_last_update_date      IN            DATE     DEFAULT SYSDATE
  , p_last_update_login     IN            NUMBER   DEFAULT NULL
  , p_notes                 IN            VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  , p_notes_detail          IN            VARCHAR2 DEFAULT NULL
  , p_append_flag           IN            VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  , p_note_status           IN            VARCHAR2 DEFAULT 'I'
  , p_note_type             IN            VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  , p_jtf_note_contexts_tab IN            jtf_notes_pub.jtf_note_contexts_tbl_type
                                            DEFAULT jtf_notes_pub.jtf_note_contexts_tab_dflt
  , x_return_status            OUT NOCOPY VARCHAR2
  );

  FUNCTION  Ok_to_generate_msg
  ( p_parent_note_id          IN            NUMBER   DEFAULT NULL
  , p_api_version             IN            NUMBER
  , p_init_msg_list           IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_commit                  IN            VARCHAR2 DEFAULT FND_API.G_FALSE
  , p_validation_level        IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2
  , p_org_id                  IN            NUMBER   DEFAULT NULL
  , p_source_object_id        IN            NUMBER
  , p_source_object_code      IN            VARCHAR2
  , p_notes                   IN            VARCHAR2
  , p_notes_detail            IN            VARCHAR2 DEFAULT NULL
  , p_note_status             IN            VARCHAR2 DEFAULT 'I'
  , p_entered_by              IN            NUMBER
  , p_entered_date            IN            DATE
  , x_jtf_note_id                OUT NOCOPY NUMBER
  , p_last_update_date        IN            DATE
  , p_last_updated_by         IN            NUMBER
  , p_creation_date           IN            DATE
  , p_created_by              IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
  , p_last_update_login       IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
  , p_attribute1              IN            VARCHAR2 DEFAULT NULL
  , p_attribute2              IN            VARCHAR2 DEFAULT NULL
  , p_attribute3              IN            VARCHAR2 DEFAULT NULL
  , p_attribute4              IN            VARCHAR2 DEFAULT NULL
  , p_attribute5              IN            VARCHAR2 DEFAULT NULL
  , p_attribute6              IN            VARCHAR2 DEFAULT NULL
  , p_attribute7              IN            VARCHAR2 DEFAULT NULL
  , p_attribute8              IN            VARCHAR2 DEFAULT NULL
  , p_attribute9              IN            VARCHAR2 DEFAULT NULL
  , p_attribute10             IN            VARCHAR2 DEFAULT NULL
  , p_attribute11             IN            VARCHAR2 DEFAULT NULL
  , p_attribute12             IN            VARCHAR2 DEFAULT NULL
  , p_attribute13             IN            VARCHAR2 DEFAULT NULL
  , p_attribute14             IN            VARCHAR2 DEFAULT NULL
  , p_attribute15             IN            VARCHAR2 DEFAULT NULL
  , p_context                 IN            VARCHAR2 DEFAULT NULL
  , p_note_type               IN            VARCHAR2 DEFAULT NULL
  , p_jtf_note_contexts_tab   IN            jtf_notes_pub.jtf_note_contexts_tbl_type
                                              DEFAULT jtf_notes_pub.jtf_note_contexts_tab_dflt
 ) RETURN BOOLEAN;


  --
  -- The following versions are maintained for backward compatibility purposes only
  -- please use the above for new development
  --

  -- DO NOT USE THIS VERSION OF CREATE_NOTE_POST
  PROCEDURE  create_note_post(
                p_parent_note_id          IN NUMBER DEFAULT NULL,
                p_api_version             IN NUMBER  ,
                p_init_msg_list           IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_commit                  IN VARCHAR2  DEFAULT FND_API.G_FALSE,
                p_validation_level        IN NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
                x_msg_count              OUT NOCOPY NUMBER   ,
                x_msg_data               OUT NOCOPY VARCHAR2 ,
                      p_org_id            IN NUMBER    DEFAULT NULL,
                p_source_object_id        IN NUMBER   ,
                p_source_object_code      IN VARCHAR2 ,
                p_notes                IN VARCHAR2 ,
                p_notes_detail                IN VARCHAR2 DEFAULT NULL,
                p_note_status     IN VARCHAR2 DEFAULT 'I',
                p_entered_by              IN NUMBER   ,
                p_entered_date            IN DATE     ,
                      x_jtf_note_id              OUT NOCOPY NUMBER   ,
                      p_last_update_date        IN DATE     ,
                 p_last_updated_by         IN NUMBER   ,
                 p_creation_date           IN DATE     ,
                 p_created_by              IN NUMBER  DEFAULT FND_GLOBAL.USER_ID,
                 p_last_update_login       IN NUMBER  DEFAULT FND_GLOBAL.LOGIN_ID,
                      p_attribute1                IN VARCHAR2  DEFAULT NULL,
                      p_attribute2                IN VARCHAR2  DEFAULT NULL,
                      p_attribute3                IN VARCHAR2  DEFAULT NULL,
                      p_attribute4                IN VARCHAR2  DEFAULT NULL,
                      p_attribute5                IN VARCHAR2  DEFAULT NULL,
                      p_attribute6                IN VARCHAR2  DEFAULT NULL,
                      p_attribute7                IN VARCHAR2  DEFAULT NULL,
                      p_attribute8                IN VARCHAR2  DEFAULT NULL,
                      p_attribute9                IN VARCHAR2  DEFAULT NULL,
                      p_attribute10               IN VARCHAR2  DEFAULT NULL,
                      p_attribute11               IN VARCHAR2  DEFAULT NULL,
                      p_attribute12               IN VARCHAR2  DEFAULT NULL,
                      p_attribute13               IN VARCHAR2  DEFAULT NULL,
                      p_attribute14               IN VARCHAR2  DEFAULT NULL,
                      p_attribute15               IN VARCHAR2  DEFAULT NULL,
                      p_context           IN VARCHAR2  DEFAULT NULL,
                      p_note_type  IN VARCHAR2  DEFAULT NULL,
                      p_jtf_note_contexts_tab IN jtf_notes_pub.jtf_note_contexts_tbl_type DEFAULT  jtf_notes_pub.jtf_note_contexts_tab_dflt,
   x_return_status        OUT NOCOPY VARCHAR2
        );

  -- DO NOT USE THIS VERSION OF OK_TO_GENERATE_MSG
  FUNCTION  Ok_to_generate_msg
  ( p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit                    IN      VARCHAR2 DEFAULT fnd_api.g_false,
    p_validation_level          IN      NUMBER   DEFAULT fnd_api.g_valid_level_full,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    p_jtf_note_id               IN      NUMBER,
    p_entered_by              IN NUMBER   ,
    p_last_updated_by           IN      NUMBER,
    p_last_update_date          IN      DATE     DEFAULT Sysdate,
    p_last_update_login         IN      NUMBER   DEFAULT NULL,
    p_notes                     IN      VARCHAR2 DEFAULT fnd_api.g_miss_char,
    p_notes_detail                      IN      VARCHAR2 DEFAULT NULL,
    p_append_flag             IN VARCHAR2 DEFAULT fnd_api.g_miss_char,
    p_note_status       IN      VARCHAR2 DEFAULT 'I',
    p_note_type           IN   VARCHAR2 DEFAULT fnd_api.g_miss_char,
    p_jtf_note_contexts_tab IN jtf_notes_pub.jtf_note_contexts_tbl_type
                                                 DEFAULT  jtf_notes_pub.jtf_note_contexts_tab_dflt ,
          x_return_status        OUT NOCOPY VARCHAR2
                )  RETURN BOOLEAN;
END  jtf_notes_cuhk;

 

/
