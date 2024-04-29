--------------------------------------------------------
--  DDL for Package JTF_CAL_ITEMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_ITEMS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpcis.pls 120.2 2006/06/30 10:42:44 sbarat ship $ */
/*#
 * Public APIs for the HTML Calendar module.
 * This API facilitates create, update and delete of calendar items like 'CALENDAR', 'MEMO', 'TASK'
 * @rep:scope internal
 * @rep:product CAC
 * @rep:displayname JTF Calendar Items Public API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

TYPE calItemRec IS RECORD
( CAL_RESOURCE_ID       NUMBER             := FND_API.g_miss_num  -- JTF Resource ID of calendar on which Item
                                                                  -- should be displayed
, CAL_RESOURCE_TYPE     VARCHAR2(30)       := FND_API.g_miss_char -- JTF Resource Type of resource on which
                                                                  -- item should be displayed values:
                                                                  -- RS_EMPLOYEE and RS_GROUP
, CAL_ITEM_ID           NUMBER             := FND_API.g_miss_num -- Calendar Item key only used for update
                                                                  -- and delete
, ITEM_TYPE_CODE        VARCHAR2(30)       := FND_API.g_miss_char -- 'CALENDAR', 'MEMO', 'TASK' determines
                                                                  -- where the item will be displayed
, ITEM_NAME             VARCHAR2(80)       := FND_API.g_miss_char -- Short Name/description that will be
                                                                  -- (partly)displayed
, ITEM_DESCRIPTION      VARCHAR2(2000)     := FND_API.g_miss_char  -- Description of the item, for future use
                                                                  -- think balloon text
, SOURCE_CODE           VARCHAR2(30)       := FND_API.g_miss_char  -- JTF_OBJECTS source code of the parent
                                                                   -- object, may be used in future for drill
                                                                   -- down
, SOURCE_ID             NUMBER            := FND_API.g_miss_num  -- Primary key for the parent object as
                                                                 -- defined in JTF_OBJECTS, may be used in
                                                                 -- future for drill down
, START_DATE            DATE              := FND_API.g_miss_date  -- Start date and time for the item
, END_DATE              DATE              := FND_API.g_miss_date  -- End date and time for the item
, TIMEZONE_ID           NUMBER            := FND_API.g_miss_num   -- Timezone ID from HZ_TIMEZONES
, URL                   VARCHAR2(4000)    := FND_API.g_miss_char  -- URL to drill down to parent object
, CREATED_BY            NUMBER            := FND_API.g_miss_num   -- Standard Who Column (only used by CreateItem)
, CREATION_DATE         DATE              := FND_API.g_miss_date  -- Standard Who Column (only used by CreateItem)
, LAST_UPDATED_BY       NUMBER            := FND_API.g_miss_num   -- Standard Who Column
, LAST_UPDATE_DATE      DATE              := FND_API.g_miss_date  -- Standard Who Column
, LAST_UPDATE_LOGIN     NUMBER            := FND_API.g_miss_num   -- Standard Who Column
, OBJECT_VERSION_NUMBER NUMBER            := FND_API.g_miss_num   -- Object version number for the Calendar Item
                                                                  -- can be obtained with GetObjectVerion
, APPLICATION_ID        NUMBER            := FND_API.g_miss_num   -- Application ID of parent object
);

--------------------------------------------------------------------------
-- Start of comments
--  API name    : CreateItem
--  Type        : Public
--  Function    : Create Calendar Item in JTF_CAL_ITEMS table.
--  Pre-reqs    : None.
--  Parameters  :
--      name                 direction  type       required?
--      ----                 ---------  ----       ---------
--      p_api_version        IN         NUMBER     required
--      p_init_msg_list      IN         VARCHAR2   optional
--      p_commit             IN         VARCHAR2   optional
--      p_validation_level   IN         NUMBER     optional
--      x_return_status         OUT     VARCHAR2   required
--      x_msg_count             OUT     NUMBER     required
--      x_msg_data              OUT     VARCHAR2   required
--      p_itm_rec            IN         CALItemRec required
--      x_item_id               OUT     NUMBER     required
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
 * Create Item, inserts a calendar item into JTF_CAL_ITEMS_B table
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_itm_rec Required take input record type object "CALItemRec"
 * @param x_cal_item_id Required
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Item
 */
PROCEDURE CreateItem
( p_api_version       IN     NUMBER
, p_init_msg_list     IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit            IN     VARCHAR2 DEFAULT fnd_api.g_false
, x_return_status     OUT    NOCOPY	VARCHAR2
, x_msg_count         OUT    NOCOPY     NUMBER
, x_msg_data          OUT    NOCOPY     VARCHAR2
, p_itm_rec           IN     CalItemRec
, x_cal_item_id       OUT    NOCOPY     NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name   : UpdateItem
--  Type       : Public
--  Function   : Update a Calendar Item in the JTF_CAL_ITEMS tables.
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
--      p_itm_rec               IN         CalItemRec required
--      x_object_version_number    OUT     NUMBER     required
--
--  Version : Current  version 1.0
--            Previous version 1.0
--            Initial  version 1.0
--
--  Notes: - An item can only be updated if the object_version_number
--           is an exact match.
--         - When an update was successful the the new object_version_number
--           will be returned.
--
-- End of comments
--------------------------------------------------------------------------
/*#
 * Update Item, updates a calendar item into JTF_CAL_ITEMS_B table
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_itm_rec Required take input record type object "CALItemRec"
 * @param x_object_version_number Object Version Number
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Item
 */
PROCEDURE UpdateItem
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY	  VARCHAR2
, x_msg_count             OUT    NOCOPY   NUMBER
, x_msg_data              OUT    NOCOPY   VARCHAR2
, p_itm_rec               IN     CalItemRec
, x_object_version_number OUT    NOCOPY   NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API Name    : DeleteItem
--  Type        : Public
--  Description : Delete a Calendar Item from the JTF_CAL_ITEMS_B and
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
 * Delete Item, deletes a calendar item from JTF_CAL_ITEMS_B table
 * @param p_api_version API Version Required
 * @param p_init_msg_list Initialize message list flag, Optional Default = FND_API.G_FALSE
 * @param p_commit Optional Default = FND_API.G_FALSE
 * @param p_validation_level Optional DEFAULT fnd_api.g_valid_level_full
 * @param x_return_status Required Length  = 1
 * @param x_msg_count API Error message count, Required
 * @param x_msg_data API Error message data, Required Length  = 2000
 * @param p_cal_item_id Required
 * @param p_object_version_number Object Version number
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Item
 */
PROCEDURE DeleteItem
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit                IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY	  VARCHAR2
, x_msg_count             OUT    NOCOPY   NUMBER
, x_msg_data              OUT    NOCOPY   VARCHAR2
, p_cal_item_id           IN     NUMBER
, p_object_version_number IN     NUMBER
);

--------------------------------------------------------------------------
-- Start of comments
--  API name    : GetObjectVersion
--  Type        : Public
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
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Get Object Version
 */
PROCEDURE GetObjectVersion
( p_api_version           IN     NUMBER
, p_init_msg_list         IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_validation_level      IN     NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status         OUT    NOCOPY   VARCHAR2
, x_msg_count             OUT    NOCOPY   NUMBER
, x_msg_data              OUT    NOCOPY   VARCHAR2
, p_cal_item_id           IN     NUMBER
, x_object_version_number OUT    NOCOPY   NUMBER
);

END JTF_CAL_Items_PUB;

 

/
