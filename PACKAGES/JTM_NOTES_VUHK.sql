--------------------------------------------------------
--  DDL for Package JTM_NOTES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_NOTES_VUHK" AUTHID CURRENT_USER AS
/* $Header: jtmhknts.pls 120.1 2005/08/24 02:13:47 saradhak noship $ */

/*****************************************************************************************
 This is the Vertical User Hook API.
 The verticals can add customization procedures here for Pre and Post Processing.
 ******************************************************************************************/

/* Verticals Procedure for pre processing in case of create note */

PROCEDURE create_note_pre
( p_parent_note_id          IN     NUMBER
, p_api_version             IN     NUMBER
, p_init_msg_list           IN     VARCHAR2
, p_commit                  IN     VARCHAR2
, p_validation_level        IN     NUMBER
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_org_id                  IN     NUMBER
, p_source_object_id        IN     NUMBER
, p_source_object_code      IN     VARCHAR2
, p_notes                   IN     VARCHAR2
, p_notes_detail            IN     VARCHAR2
, p_note_status             IN     VARCHAR2
, p_entered_by              IN     NUMBER
, p_entered_date            IN     DATE
, x_jtf_note_id                OUT NOCOPY NUMBER
, p_last_update_date        IN     DATE
, p_last_updated_by         IN     NUMBER
, p_creation_date           IN     DATE
, p_created_by              IN     NUMBER
, p_last_update_login       IN     NUMBER
, p_attribute1              IN     VARCHAR2
, p_attribute2              IN     VARCHAR2
, p_attribute3              IN     VARCHAR2
, p_attribute4              IN     VARCHAR2
, p_attribute5              IN     VARCHAR2
, p_attribute6              IN     VARCHAR2
, p_attribute7              IN     VARCHAR2
, p_attribute8              IN     VARCHAR2
, p_attribute9              IN     VARCHAR2
, p_attribute10             IN     VARCHAR2
, p_attribute11             IN     VARCHAR2
, p_attribute12             IN     VARCHAR2
, p_attribute13             IN     VARCHAR2
, p_attribute14             IN     VARCHAR2
, p_attribute15             IN     VARCHAR2
, p_context                 IN     VARCHAR2
, p_note_type               IN     VARCHAR2
, p_jtf_note_contexts_tab   IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status              OUT NOCOPY VARCHAR2
);

/* Verticals Procedure for post processing in case of create note */

PROCEDURE create_note_post
( p_parent_note_id          IN     NUMBER
, p_api_version             IN     NUMBER
, p_init_msg_list           IN     VARCHAR2
, p_commit                  IN     VARCHAR2
, p_validation_level        IN     NUMBER
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
, p_org_id                  IN     NUMBER
, p_source_object_id        IN     NUMBER
, p_source_object_code      IN     VARCHAR2
, p_notes                   IN     VARCHAR2
, p_notes_detail            IN     VARCHAR2
, p_note_status             IN     VARCHAR2
, p_entered_by              IN     NUMBER
, p_entered_date            IN     DATE
, x_jtf_note_id                OUT NOCOPY NUMBER
, p_last_update_date        IN     DATE
, p_last_updated_by         IN     NUMBER
, p_creation_date           IN     DATE
, p_created_by              IN     NUMBER
, p_last_update_login       IN     NUMBER
, p_attribute1              IN     VARCHAR2
, p_attribute2              IN     VARCHAR2
, p_attribute3              IN     VARCHAR2
, p_attribute4              IN     VARCHAR2
, p_attribute5              IN     VARCHAR2
, p_attribute6              IN     VARCHAR2
, p_attribute7              IN     VARCHAR2
, p_attribute8              IN     VARCHAR2
, p_attribute9              IN     VARCHAR2
, p_attribute10             IN     VARCHAR2
, p_attribute11             IN     VARCHAR2
, p_attribute12             IN     VARCHAR2
, p_attribute13             IN     VARCHAR2
, p_attribute14             IN     VARCHAR2
, p_attribute15             IN     VARCHAR2
, p_context                 IN     VARCHAR2
, p_note_type               IN     VARCHAR2
--, p_jtf_note_contexts_tab   IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status              OUT NOCOPY VARCHAR2
, p_jtf_note_id             IN     NUMBER
);

/* Verticals Procedure for pre processing in case of update note */

PROCEDURE update_note_pre
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN     NUMBER
, p_entered_by            IN     NUMBER
, p_last_updated_by       IN     NUMBER
, p_last_update_date      IN     DATE
, p_last_update_login     IN     NUMBER
, p_notes                 IN     VARCHAR2
, p_notes_detail          IN     VARCHAR2
, p_append_flag           IN     VARCHAR2
, p_note_status           IN     VARCHAR2
, p_note_type             IN     VARCHAR2
--, p_jtf_note_contexts_tab IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
);


/* Vertical Procedure for post processing in case of update note */

PROCEDURE update_note_post
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN     NUMBER
, p_entered_by            IN     NUMBER
, p_last_updated_by       IN     NUMBER
, p_last_update_date      IN     DATE
, p_last_update_login     IN     NUMBER
, p_notes                 IN     VARCHAR2
, p_notes_detail          IN     VARCHAR2
, p_append_flag           IN     VARCHAR2
, p_note_status           IN     VARCHAR2
, p_note_type             IN     VARCHAR2
--, p_jtf_note_contexts_tab IN     jtf_notes_pub.jtf_note_contexts_tbl_type
, x_return_status            OUT NOCOPY VARCHAR2
);

FUNCTION Ok_to_generate_msg
( p_parent_note_id        IN     NUMBER
, p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2
, p_commit                IN     VARCHAR2
, p_validation_level      IN     NUMBER
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_org_id                IN     NUMBER
, p_source_object_id      IN     NUMBER
, p_source_object_code    IN     VARCHAR2
, p_notes                 IN     VARCHAR2
, p_notes_detail          IN     VARCHAR2
, p_note_status           IN     VARCHAR2
, p_entered_by            IN     NUMBER
, p_entered_date          IN     DATE
, x_jtf_note_id              OUT NOCOPY NUMBER
, p_last_update_date      IN     DATE
, p_last_updated_by       IN     NUMBER
, p_creation_date         IN     DATE
, p_created_by            IN     NUMBER
, p_last_update_login     IN     NUMBER
, p_attribute1            IN     VARCHAR2
, p_attribute2            IN     VARCHAR2
, p_attribute3            IN     VARCHAR2
, p_attribute4            IN     VARCHAR2
, p_attribute5            IN     VARCHAR2
, p_attribute6            IN     VARCHAR2
, p_attribute7            IN     VARCHAR2
, p_attribute8            IN     VARCHAR2
, p_attribute9            IN     VARCHAR2
, p_attribute10           IN     VARCHAR2
, p_attribute11           IN     VARCHAR2
, p_attribute12           IN     VARCHAR2
, p_attribute13           IN     VARCHAR2
, p_attribute14           IN     VARCHAR2
, p_attribute15           IN     VARCHAR2
, p_context               IN     VARCHAR2
, p_note_type             IN     VARCHAR2
, p_jtf_note_contexts_tab IN     jtf_notes_pub.jtf_note_contexts_tbl_type
)RETURN BOOLEAN;

END jtm_notes_vuhk;

 

/
