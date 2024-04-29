--------------------------------------------------------
--  DDL for Package IMC_BOOKMARK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IMC_BOOKMARK_PUB" AUTHID CURRENT_USER AS
/* $Header: imcbmas.pls 120.0 2004/01/24 03:03:59 appldev noship $ */

TYPE ref_cursor_bookmarks IS REF CURSOR;
G_MODLUE CONSTANT VARCHAR2(15) := 'IMC_BOOKMARKS';
G_CATEGORY_ORG CONSTANT VARCHAR2(30) := 'BOOKMARKED_ORGANIZATION';
G_CATEGORY_PERSON CONSTANT VARCHAR2(30) := 'BOOKMARKED_PERSON';
G_CATEGORY_REL CONSTANT VARCHAR2(30) := 'BOOKMARKED_PARTY_RELATIONSHIP';
G_PREFERENCE_CODE CONSTANT VARCHAR2(10) := 'PARTY_ID';
G_OBJECT_VERSION_NUMBER CONSTANT NUMBER := 1; /* Default to value used by TCA API */
G_MAX_REACHED_ERROR CONSTANT VARCHAR2(1) := 'M';
G_FND_USER_TYPE CONSTANT VARCHAR2(10) := 'FND';
G_PARTY_USER_TYPE CONSTANT VARCHAR2(10) := 'PARTY';

----------------------------------------------------------------
-- API name  : Add_Bookmark
-- TYPE      : Public
-- FUNCTION  : Add a bookmark for a party. The bookmark can be an
--             organization, a person, or a contact relationship.
--             Before adding a bookmark, the profile option for max
--             number of bookmarks will be checked to ensure it is
--             enforced. Returns error code if adding bookmark will
--			 make it over the limit.
--			 Do nothing if bookmark already exists.
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the bookmark will be added
--
--             p_bookmarked_party_id IN NUMBER(required)
--             Party that is going to be added as a bookmark
--
--     OUT  :
--             x_return_status 1 byte result code:
--                'S'  Success
--			    'L'  Over max number of bookmark limit
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE Add_Bookmark(
  p_party_id IN NUMBER,
  p_bookmarked_party_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
);

----------------------------------------------------------------
-- API name  : Add_Bookmark
-- TYPE      : Public
--	 FUNCTION  : Add a bookmark for a FND user. This is an overloaded
--			 function. It will find out the party_id of the FND user
--			 and assign the bookmark to the party because we cannot
--			 add bookmark to a FND user directly. If no party exists
--			 for the FND user, a party will be created and the
--			 party_id will be returned as well. The bookmark can be
--             an organization, a person, or a contact relationship.
--             Before adding a bookmark, the profile option for max
--             number of bookmarks will be checked to ensure it is
--             enforced. Returns error code if adding bookmark will
--			 make it over the limit or FND user does not exist.
--			 Do nothing if bookmark already exists.
-- Parameters:
--     IN    : p_fnd_user_id IN NUMBER (required)
--             FND user on which the bookmark will be added
--
--             p_bookmarked_party_id IN NUMBER(required)
--             Party that is going to be added as a bookmark
--
--     OUT  :
--             x_party_id
--             Party ID of the FND user
--             x_return_status 1 byte result code:
--                'S'  Success
--			    'L'  Over max number of bookmark limit
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE Add_Bookmark(
  p_fnd_user_id IN NUMBER,
  p_bookmarked_party_id IN NUMBER,
  x_party_id OUT NOCOPY NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
);

----------------------------------------------------------------
-- API name  : Remove_Bookmark
-- TYPE      : Public
-- FUNCTION  : Remove bookmark for a party. Do nothing if neither
--             party nor bookmark exists.
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the bookmark will be removed
--
--             p_bookmarked_party_id IN NUMBER(required)
--             Bookmark that is going to be removed
--
--     OUT  :
--             x_return_status 1 byte result code:
--                'S'  Success
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE Remove_Bookmark(
  p_party_id IN NUMBER,
  p_user_type IN VARCHAR2,
  p_bookmarked_party_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
);

----------------------------------------------------------------
-- API name  : Get_Bookmarked_Parties
-- TYPE      : Public
-- FUNCTION  : Retrieve bookmark Ids for a party. The values will
--			 be retrieved as a reference cursor.
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the bookmarks will be returned
--
--             p_bookmarked_party_type IN VARCHAR2(optional)
--             Valid values are ORGANIZATION, PARTY_RELATIONSHIP,
--             PERSON and NULL. For non-null value, bookmarks of
--			 that type will be returned. For null, all bookmarks
--             are returned.
--
--     OUT  :  x_bookmarked_party_ids
--             A reference cursor returns party Ids of bookmarks
--             for a party. Returns NULL if no bookmark exists for
--			 the party or p_party_id does not exist.
--
--             x_return_status 1 byte result code:
--                'S'  Success
--                'E'  Error
--                'U'  Unexpected Error
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Version: Current Version 1.0
-- Previous Version :  None
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE Get_Bookmarked_Parties(
  p_party_id IN NUMBER,
  p_bookmarked_party_type IN VARCHAR2 DEFAULT NULL, -- Default to return all types
  x_bookmarked_party_ids OUT NOCOPY ref_cursor_bookmarks,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY VARCHAR2,
  x_msg_data  OUT NOCOPY VARCHAR2
);

----------------------------------------------------------------
-- API name  : Bookmark_Exists
-- TYPE      : Public
-- FUNCTION  : Check if a party has been bookmarked for a user.
--			 Returns TRUE if the bookmark exist, else returns FALSE.
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party to check if the bookmark exists
--
--             p_bookmarked_party_id IN VARCHAR2(required)
--             Party id of the bookmark you want to check.
--
-- Version: Current Version 1.0
-- Previous Version :  None
-- Notes  :
--
--
---------------------------------------------------------------
FUNCTION Bookmark_Exists(
  p_party_id IN NUMBER,
  p_user_type IN VARCHAR2,
  p_bookmarked_party_id IN NUMBER
) RETURN VARCHAR2;

----------------------------------------------------------------
-- API name  : Disable_Bookmark
-- TYPE      : Public
-- FUNCTION  : Check if bookmark is allowed for a party (e.g.
--               relationship party between 2 orgs
--		Returns Y if bookmark is not allowed, else returns N.
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--
-- Version: Current Version 1.0
-- Previous Version :  None
-- Notes  :
--
--
---------------------------------------------------------------
FUNCTION Disable_Bookmark(
  p_party_id IN NUMBER
) RETURN VARCHAR2;

END IMC_BOOKMARK_PUB;

 

/
