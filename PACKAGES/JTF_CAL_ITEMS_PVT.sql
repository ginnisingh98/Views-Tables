--------------------------------------------------------
--  DDL for Package JTF_CAL_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_ITEMS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvcis.pls 120.1 2005/06/24 02:01:49 sanandan ship $ */
/*#
 * Private APIs for the HTML Calendar module
 * Access is restricted to Oracle Foundation internal development
 * @rep:scope private
 * @rep:product CAC
 * @rep:displayname JTF Calendar Items Private API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

TYPE cal_item_rec_type IS RECORD
( CAL_ITEM_ID           NUMBER
, RESOURCE_ID           NUMBER
, RESOURCE_TYPE         VARCHAR2(30)
, ITEM_TYPE             VARCHAR2(30)
, ITEM_TYPE_CODE        VARCHAR2(30)
, ITEM_NAME             VARCHAR2(80)
, ITEM_DESCRIPTION      VARCHAR2(2000)
, SOURCE_CODE           VARCHAR2(30)
, SOURCE_ID             NUMBER
, START_DATE            DATE
, END_DATE              DATE
, TIMEZONE_ID           NUMBER
, URL                   VARCHAR2(4000)
, CREATED_BY            NUMBER
, CREATION_DATE         DATE
, LAST_UPDATED_BY       NUMBER
, LAST_UPDATE_DATE      DATE
, LAST_UPDATE_LOGIN     NUMBER
, OBJECT_VERSION_NUMBER NUMBER
, APPLICATION_ID        NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Insert_Row
--  Type        : Private
--  Function    : Create record in JTF_CAL_ITEMS table.
--  Pre-reqs    : None.
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      p_api_version        IN         NUMBER   required
--      p_init_msg_list      IN         VARCHAR2 optional
--      p_commit             IN         VARCHAR2 optional
--      p_validation_level   IN         NUMBER   optional
--      x_return_status         OUT     VARCHAR2 required
--      x_msg_count             OUT     NUMBER   required
--      x_msg_data              OUT     VARCHAR2 required
--      p_itm_rec            IN         cal_item_rec_type   required
--      x_item_id               OUT     NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: The object_version_number of a new entry is always 1.
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Insert Row, inserts a calendar item into JTF_CAL_ITEMS_B table
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_itm_rec Required take input record type object "cal_item_rec_type"
 * @param x_cal_item_id Required
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Insert Row
 */
PROCEDURE Insert_Row
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level  IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status     OUT    NOCOPY   VARCHAR2
, x_msg_count         OUT    NOCOPY   NUMBER
, x_msg_data          OUT    NOCOPY   VARCHAR2
, p_itm_rec           IN     cal_item_rec_type
, x_cal_item_id       OUT    NOCOPY   NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : Update_Row
--  Type       : Private
--  Function   : Update record in JTF_CAL_ITEMS table.
--  Pre-reqs   : None.
--  Parameters :
--      name                    direction  type       required?
--      ----                    ---------  --------   ---------
--      p_api_version           IN         NUMBER     required
--      p_init_msg_list         IN         VARCHAR2   optional
--      p_commit                IN         VARCHAR2   optional
--      p_validation_level      IN         NUMBER     optional
--      x_return_status            OUT     VARCHAR2   required
--      x_msg_count                OUT     NUMBER     required
--      x_msg_data                 OUT     VARCHAR2   required
--      p_itm_rec               IN         cal_item_rec_type required
--      x_object_version_number    OUT     NUMBER     required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An item can only be updated if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Update Item row, updates a calendar item into JTF_CAL_ITEMS_B table
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_itm_rec Required take input record type object "cal_item_rec_type"
 * @param x_object_version_number Object Version Number
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Update Row
 */
PROCEDURE Update_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 :=  fnd_api.g_false
, p_commit                IN     VARCHAR2 :=  fnd_api.g_false
, p_validation_level      IN     NUMBER   :=  fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY	VARCHAR2
, x_msg_count             OUT    NOCOPY	NUMBER
, x_msg_data              OUT    NOCOPY	VARCHAR2
, p_itm_rec               IN     cal_item_rec_type
, x_object_version_number OUT    NOCOPY	NUMBER
);
--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Delete_Row
--  Type        : Private
--  Description : Delete record in JTF_CAL_ITEMS_B and
--                JTF_CAL_ITEMS_TL table
--  Pre-reqs    : None
--  Parameters  :
--      name                    direction  type     required?
--      ----                    ---------  ----     ---------
--      p_api_version           IN         NUMBER   required
--      p_init_msg_list         IN         VARCHAR2 optional
--      p_commit                IN         VARCHAR2 optional
--      p_validation_level      IN         NUMBER   optional
--      x_return_status            OUT     VARCHAR2 required
--      x_msg_count                OUT     NUMBER   required
--      x_msg_data                 OUT     VARCHAR2 required
--      p_cal_item_id           IN         NUMBER   required
--      p_object_version_number IN         NUMBER   required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: An item can only be deleted if the object_version_number
--         is an exact match.
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Delete Item row, deletes a calendar item from JTF_CAL_ITEMS_B table
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_cal_item_id Required
 * @param p_object_version_number Object Version Number
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Delete Row
 */
PROCEDURE Delete_Row
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY	  VARCHAR2
, x_msg_count             OUT    NOCOPY	  NUMBER
, x_msg_data              OUT    NOCOPY	  VARCHAR2
, p_cal_item_id           IN     NUMBER
, p_object_version_number IN     NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name    : Get_Object_Version
--  Type        : Private
--  Function    : Returns the current object version number for the given
--                Calendar Item.
--  Pre-reqs    : None.
--  Parameters  :
--      name                    direction  type       required?
--      ----                    ---------  ----       ---------
--      p_api_version           IN         NUMBER     required
--      p_init_msg_list         IN         VARCHAR2   optional
--      p_commit                IN         VARCHAR2   optional
--      p_validation_level      IN         NUMBER     optional
--      x_return_status            OUT     VARCHAR2   required
--      x_msg_count                OUT     NUMBER     required
--      x_msg_data                 OUT     VARCHAR2   required
--      p_Calendar_Item         IN         NUMBER     required
--      x_object_version_number    OUT     NUMBER     required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Get Object Version, Returns the current object version number for the given
 * Calendar Item.
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_cal_item_id Required
 * @param x_object_version_number Out parameter
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Get Object Version
 */
PROCEDURE Get_Object_Version
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY   VARCHAR2
, x_msg_count             OUT    NOCOPY	  NUMBER
, x_msg_data              OUT    NOCOPY	  VARCHAR2
, p_cal_item_id           IN     NUMBER
, x_object_version_number OUT    NOCOPY	  NUMBER
);


--------------------------------------------------------------------------
-- Start of comments
--  API name    : GetUrl
--  Type        : Private
--  Function    : Returns the URL for given object/item. Used in JTF_CAL_PUB
--                API to populate url column in jtf_cal_items table
--  Pre-reqs    : None.
--  Parameters  :
--      name                    direction  type       required?
--      ----                    ---------  ----       ---------
--      p_source_code                IN         VARCHAR2   optional
--      p_source_id                  IN         NUMBER     optional
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------

FUNCTION GetUrl(p_source_code IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION GetUrlParams(p_source_code IN VARCHAR2,
                p_source_id   IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Start of comments
--  API name    : GetName
--  Type        : Private
--  Function    : Returns name for given object/item. Used in JTF_CAL_PVT
--                to collect calendar view data
--  Pre-reqs    : None.
--  Parameters  :
--      name                    direction  type       required?
--      ----                    ---------  ----       ---------
--      p_source_code                IN         VARCHAR2   optional
--      p_source_id                  IN         NUMBER     optional
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------

FUNCTION GetName(p_source_code IN VARCHAR2,
                 p_source_id   IN NUMBER)
RETURN VARCHAR2;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Add_Language
--  Type        : Private
--  Description : Additional Language processing for JTF_CAL_ITEMS_B and
--                _TL tables.
--  Pre-reqs    : None
--  Parameters  : None
--  Version     : Current  version 1.0
--                Previous version none
--                Initial  version 1.0
--
--  Notes:
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Language;

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Translate_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_CAL_ITEMS_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Translate_Row
( p_cal_item_id      IN NUMBER
, p_item_name        IN VARCHAR2
, p_item_description IN VARCHAR2
, p_owner            IN VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : Load_Row
--  Type        : Private
--  Description : Additional Language processing for JTF_CAL_ITEMS_B and
--                _TL tables. Used in the FNDLOAD definition file (.lct)
--  Pre-reqs    : None
--  Parameters  : None
--  Version : Current  version 1.0
--            Previous version none
--            Initial  version 1.0
--
--  Notes: :
--
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Load_Row
( p_cal_item_id  IN NUMBER
, p_itm_rec      IN Cal_Item_rec_type
, p_owner        IN VARCHAR2
);



END JTF_CAL_Items_PVT;

 

/
