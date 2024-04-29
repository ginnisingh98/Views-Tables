--------------------------------------------------------
--  DDL for Package JTF_NOTES_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_NOTES_SECURITY_PVT" AUTHID CURRENT_USER as
/* $Header: jtfvnss.pls 115.4 2003/08/15 21:57:33 akaran ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_NOTES_SECURITY_PVT';

G_FUNCTION_CREATE CONSTANT VARCHAR2(30) := 'JTF_NOTE_CREATE';
G_FUNCTION_SELECT CONSTANT VARCHAR2(30) := 'JTF_NOTE_SELECT';
G_FUNCTION_DELETE CONSTANT VARCHAR2(30) := 'JTF_NOTE_DELETE';
G_FUNCTION_UPDATE_NOTE CONSTANT VARCHAR2(30) := 'JTF_NOTE_UPDATE_NOTES';
G_FUNCTION_UPDATE_NOTE_DTLS CONSTANT VARCHAR2(30) := 'JTF_NOTE_UPDATE_NOTE_DETAILS';
G_FUNCTION_UPDATE_SEC CONSTANT VARCHAR2(30) := 'JTF_NOTE_UPDATE_SECONDARY';
G_FUNCTION_TYPE_SELECT CONSTANT VARCHAR2(30) := 'JTF_NOTE_TYPE_SELECT';
G_OBJECT_NOTE CONSTANT VARCHAR2(30) := 'JTF_NOTES';
G_OBJECT_NOTE_TYPE CONSTANT VARCHAR2(30) := 'JTF_NOTE_TYPES';


PROCEDURE check_notes_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_notes_access
--  Type      : Private
--  Usage     : Check notes access using AOL security
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version                 IN            NUMBER
, p_init_msg_list               IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_note_id                     IN            NUMBER
, x_select_predicate            IN OUT NOCOPY VARCHAR2
, x_note_type_predicate         IN OUT NOCOPY VARCHAR2
, x_select_access               IN OUT NOCOPY NUMBER
, x_create_access               IN OUT NOCOPY NUMBER
, x_update_note_access          IN OUT NOCOPY NUMBER
, x_update_note_details_access  IN OUT NOCOPY NUMBER
, x_update_secondary_access     IN OUT NOCOPY NUMBER
, x_delete_access               IN OUT NOCOPY NUMBER
, x_return_status                  OUT NOCOPY VARCHAR2
, x_msg_count                      OUT NOCOPY NUMBER
, x_msg_data                       OUT NOCOPY VARCHAR2
);


PROCEDURE get_security_predicate
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : get_security_predicate
--  Type      : Private
--  Usage     : Get Security Predicate for a given function
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version         IN            NUMBER
, p_init_msg_list       IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_object_name         IN            VARCHAR2 DEFAULT NULL
, p_function            IN            VARCHAR2 DEFAULT NULL
, p_grant_instance_type IN            VARCHAR2 DEFAULT 'UNIVERSAL'
, p_user_name           IN            VARCHAR2 DEFAULT NULL
, p_statement_type      IN            VARCHAR2 DEFAULT 'OTHER'
, p_table_alias         IN            VARCHAR2 DEFAULT NULL
, x_predicate              OUT NOCOPY VARCHAR2
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);


PROCEDURE get_functions
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : get_functions
--  Type      : Private
--  Usage     : Get All security functions on which the logged in user has access
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version         IN            NUMBER
, p_init_msg_list       IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_object_name         IN            VARCHAR2
, p_instance_pk1_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk2_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk3_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk4_value  IN            VARCHAR2 DEFAULT NULL
, p_instance_pk5_value  IN            VARCHAR2 DEFAULT NULL
, p_user_name           IN            VARCHAR2 DEFAULT NULL
, x_return_status          OUT NOCOPY VARCHAR2
, x_privilege_tbl          OUT NOCOPY FND_DATA_SECURITY.FND_PRIVILEGE_NAME_TABLE_TYPE
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);


PROCEDURE check_function
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_function
--  Type      : Private
--  Usage     : Check if the logged in user has access on a given Security function
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version          IN            NUMBER
, p_init_msg_list        IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_function             IN            VARCHAR2
, p_object_name          IN            VARCHAR2
, p_instance_pk1_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk2_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk3_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk4_value   IN            VARCHAR2 DEFAULT NULL
, p_instance_pk5_value   IN            VARCHAR2 DEFAULT NULL
, p_user_name            IN            VARCHAR2 DEFAULT NULL
, x_return_status           OUT NOCOPY VARCHAR2
, x_grant                   OUT NOCOPY NUMBER -- 1 yes, 0 no
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
);


PROCEDURE check_note_type
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_note_type
--  Type      : Private
--  Usage     : Check if the logged in user has access on the given note type
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version          IN            NUMBER
, p_init_msg_list        IN            VARCHAR2 DEFAULT FND_API.G_FALSE
, p_note_type            IN            VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_grant                   OUT NOCOPY NUMBER -- 1 yes, 0 no
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
);

FUNCTION check_update_sec_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_update_sec_access
--  Type      : Private
--  Usage     : Check notes access using AOL security
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_note_id                     IN            NUMBER
) RETURN INTEGER;

FUNCTION check_update_prim_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_update_prim_access
--  Type      : Private
--  Usage     : Check notes access using AOL security
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_note_id                     IN            NUMBER
) RETURN INTEGER;

FUNCTION check_delete_access
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : check_udelete_access
--  Type      : Private
--  Usage     : Check delete notes access using AOL security
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_note_id                     IN            NUMBER
) RETURN INTEGER;

END JTF_NOTES_SECURITY_PVT;

 

/
