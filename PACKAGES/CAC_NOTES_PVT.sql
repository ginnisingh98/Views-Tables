--------------------------------------------------------
--  DDL for Package CAC_NOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_NOTES_PVT" AUTHID CURRENT_USER AS
/* $Header: cacvnts.pls 115.2 2003/10/21 23:47:28 akaran noship $ */

PROCEDURE create_note
------------------------------------------------------------------------------
-- Create_note
--   Inserts a note record in the JTF_NOTES_B, JTF_NOTES_TL tables
------------------------------------------------------------------------------
( p_jtf_note_id        IN            NUMBER   := NULL
, p_source_object_id   IN            NUMBER
, p_source_object_code IN            VARCHAR2
, p_notes              IN            VARCHAR2
, p_notes_detail       IN            CLOB     := NULL
, p_note_status        IN            VARCHAR2 := NULL
, p_note_type          IN            VARCHAR2 := NULL
, p_attribute1         IN            VARCHAR2 := NULL
, p_attribute2         IN            VARCHAR2 := NULL
, p_attribute3         IN            VARCHAR2 := NULL
, p_attribute4         IN            VARCHAR2 := NULL
, p_attribute5         IN            VARCHAR2 := NULL
, p_attribute6         IN            VARCHAR2 := NULL
, p_attribute7         IN            VARCHAR2 := NULL
, p_attribute8         IN            VARCHAR2 := NULL
, p_attribute9         IN            VARCHAR2 := NULL
, p_attribute10        IN            VARCHAR2 := NULL
, p_attribute11        IN            VARCHAR2 := NULL
, p_attribute12        IN            VARCHAR2 := NULL
, p_attribute13        IN            VARCHAR2 := NULL
, p_attribute14        IN            VARCHAR2 := NULL
, p_attribute15        IN            VARCHAR2 := NULL
, p_parent_note_id     IN            NUMBER   := NULL
, p_entered_date       IN            DATE     := NULL
, p_entered_by         IN            NUMBER   := NULL
, p_creation_date      IN            DATE     := NULL
, p_created_by         IN            NUMBER   := NULL
, p_last_update_date   IN            DATE     := NULL
, p_last_updated_by    IN            NUMBER   := NULL
, p_last_update_login  IN            NUMBER   := NULL
, x_jtf_note_id           OUT NOCOPY NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
);


PROCEDURE update_note
------------------------------------------------------------------------------
-- Update_note
--   Updates a note record in the JTF_NOTES_B, JTF_NOTES_TL tables
------------------------------------------------------------------------------
( p_jtf_note_id           IN            NUMBER
, p_notes                 IN            VARCHAR2 := NULL
, p_notes_detail          IN            CLOB     := NULL
, p_note_status           IN            VARCHAR2 := NULL
, p_note_type             IN            VARCHAR2 := NULL
, p_attribute1            IN            VARCHAR2 := NULL
, p_attribute2            IN            VARCHAR2 := NULL
, p_attribute3            IN            VARCHAR2 := NULL
, p_attribute4            IN            VARCHAR2 := NULL
, p_attribute5            IN            VARCHAR2 := NULL
, p_attribute6            IN            VARCHAR2 := NULL
, p_attribute7            IN            VARCHAR2 := NULL
, p_attribute8            IN            VARCHAR2 := NULL
, p_attribute9            IN            VARCHAR2 := NULL
, p_attribute10           IN            VARCHAR2 := NULL
, p_attribute11           IN            VARCHAR2 := NULL
, p_attribute12           IN            VARCHAR2 := NULL
, p_attribute13           IN            VARCHAR2 := NULL
, p_attribute14           IN            VARCHAR2 := NULL
, p_attribute15           IN            VARCHAR2 := NULL
, p_parent_note_id        IN            NUMBER   := NULL
, p_last_update_date      IN            DATE     := NULL
, p_last_updated_by       IN            NUMBER   := NULL
, p_last_update_login     IN            NUMBER   := NULL
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE delete_note
------------------------------------------------------------------------------
-- delete_note
--   deletes a note record in the JTF_NOTES_B, JTF_NOTES_TL tables
------------------------------------------------------------------------------
( p_jtf_note_id           IN            NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE create_note_context
------------------------------------------------------------------------------
-- create_note_context
--   creates a record in the JTF_NOTE_CONTEXTS table.
------------------------------------------------------------------------------
( p_note_context_id      IN            NUMBER
, p_jtf_note_id          IN            NUMBER
, p_note_context_type    IN            VARCHAR2
, p_note_context_type_id IN            NUMBER
, p_creation_date        IN            DATE     := NULL
, p_created_by           IN            NUMBER   := NULL
, p_last_update_date     IN            DATE     := NULL
, p_last_updated_by      IN            NUMBER   := NULL
, p_last_update_login    IN            NUMBER   := NULL
, x_note_context_id         OUT NOCOPY NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
);

PROCEDURE update_note_context
------------------------------------------------------------------------------
-- update_note_context
--   updates a record in the JTF_NOTE_CONTEXTS table.
------------------------------------------------------------------------------
( p_note_context_id       IN            NUMBER
, p_jtf_note_id           IN            NUMBER   := NULL
, p_note_context_type     IN            VARCHAR2 := NULL
, p_note_context_type_id  IN            NUMBER   := NULL
, p_last_update_date      IN            DATE     := NULL
, p_last_updated_by       IN            NUMBER   := NULL
, p_last_update_login     IN            NUMBER   := NULL
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

PROCEDURE delete_note_context
------------------------------------------------------------------------------
-- delete_note_context
--   deletes a record in the JTF_NOTE_CONTEXTS table.
------------------------------------------------------------------------------
( p_note_context_id       IN            NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);

FUNCTION GET_ENTERED_BY_NAME
/*******************************************************************************
** Given a USER_ID the function will return the username/partyname. This
** Function is used to display the CREATED_BY who column information on JTF
** transaction pages.
*******************************************************************************/
(p_user_id IN NUMBER
)RETURN VARCHAR2;

END CAC_NOTES_PVT;

 

/
