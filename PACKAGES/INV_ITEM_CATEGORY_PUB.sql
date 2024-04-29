--------------------------------------------------------
--  DDL for Package INV_ITEM_CATEGORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_CATEGORY_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPCATS.pls 120.4.12010000.2 2009/06/02 02:48:09 geguo ship $ */
/*#
 * This package provides functionality for maintaining categories, category
 * assignments etc.<BR>
 *
 * <B>Constants:</B> All constants that are unqualified belong to
 * INV_ITEM_CATEGORY_PUB.<BR>
 *
 * <B>Standard parameters:</B> Several standard parameters are
 * used throughout the APIs below. Those parameters are:
 * <ul>
 * <li>p_api_version: A decimal number indicating major and minor
 * revisions to the API.  Pass 1.0 unless otherwise indicated in
 * the API parameter list.</li>
 * <li>p_init_msg_list: A one-character flag indicating whether
 * to initialize the FND_MSG_PUB package's message stack at the
 * beginning of API processing (and thus remove any messages that
 * may exist on the stack from prior processing in the same session).
 * Valid values are FND_API.G_TRUE and FND_API.G_FALSE.</li>
 * <li>p_commit: A one-character flag indicating whether to commit
 * work at the end of API processing.  Valid values are
 * FND_API.G_TRUE and FND_API.G_FALSE.</li>
 * <li>x_return_status: A one-character code indicating whether
 * any errors occurred during processing (in which case error
 * messages will be present on the FND_MSG_PUB package's message
 * stack).  Valid values are FND_API.G_RET_STS_SUCCESS,
 * FND_API.G_RET_STS_ERROR, and FND_API.G_RET_STS_UNEXP_ERROR.</li>
 * <li>x_msg_count: An integer indicating the number of messages
 * on the FND_MSG_PUB package's message stack at the end of API
 * processing.  Refer to FND_MSG_PUB documentation for more
 * information about how to retrieve messages from the message
 * stack.</li>
 * <li>x_msg_data: A character string containing message text;
 * will be nonempty only when x_msg_count is exactly 1.  This is
 * a convenience feature so that callers need not interact with
 * the  message stack when there is only one error message (as is
 * commonly the case).</li>
 * </ul>
 * <BR>
 * <B>G_MISS_* values:</B> In addition, four standard default values
 * (i.e., INV_ITEM_CATEGORY_PUB.G_MISS_NUM, INV_ITEM_CATEGORY_PUB.G_MISS_CHAR,
 * INV_ITEM_CATEGORY_PUB.G_MISS_DATE)
 * are used throughout the APIs below.  These default values are used to
 * differentiate between a value not being passed at all (represented
 * by the G_MISS_* default value) and a value being explicitly
 * passed as NULL; this convention avoids unintentional nulling
 * out of values during update processing (because G_MISS_* values
 * are never applied to the database; only explicit NULL values are).
 *
 * @rep:scope public
 * @rep:product INV
 * @rep:displayname Category Maintainence
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY EGO_ITEM
 */

  --  Global variables and constants
  ----------------------------------------------------------------------------
  g_MISS_CHAR     VARCHAR2(1)  :=  fnd_api.g_MISS_CHAR;
  g_MISS_NUM      NUMBER       :=  fnd_api.g_MISS_NUM;
  g_MISS_DATE     DATE         :=  fnd_api.g_MISS_DATE;
  g_YES     VARCHAR2(1)        :=  'Y';
  g_NO      VARCHAR2(1)        :=  'N';
  g_eni_upgarde_flag VARCHAR2(1) := 'N'; -- This is set by PVT pkg ONLY for ENI 11.5.10
  -----------------------------------------------------------------------------

  --  Category Record Type
  -----------------------------------------------------------------------------
  TYPE CATEGORY_REC_TYPE IS RECORD
  (
      CATEGORY_ID                       MTL_CATEGORIES_B.CATEGORY_ID%TYPE       :=  g_MISS_NUM
     ,STRUCTURE_ID                      MTL_CATEGORIES_B.STRUCTURE_ID%TYPE      :=  g_MISS_NUM
     ,STRUCTURE_CODE                    FND_ID_FLEX_STRUCTURES.ID_FLEX_STRUCTURE_CODE%TYPE      :=  g_MISS_CHAR
     ,SEGMENT1                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT2                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT3                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT4                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT5                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT6                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT7                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT8                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT9                          MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT10                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT11                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT12                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT13                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT14                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT15                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT16                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT17                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT18                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT19                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
     ,SEGMENT20                         MTL_CATEGORIES_B.SEGMENT1%TYPE  :=  g_MISS_CHAR
    -- Changing the default value as per CRM requirements.
    -- Since these are NOT NULL columns.
    ,SUMMARY_FLAG                       MTL_CATEGORIES_B.SUMMARY_FLAG%TYPE      := g_MISS_CHAR
     ,ENABLED_FLAG                      MTL_CATEGORIES_B.ENABLED_FLAG%TYPE      := g_MISS_CHAR
     ,START_DATE_ACTIVE                 MTL_CATEGORIES_B.START_DATE_ACTIVE%TYPE         :=  g_MISS_DATE
     ,END_DATE_ACTIVE                   MTL_CATEGORIES_B.END_DATE_ACTIVE%TYPE           :=  g_MISS_DATE
     ,DISABLE_DATE                      MTL_CATEGORIES_B.DISABLE_DATE%TYPE              :=  g_MISS_DATE
     ,DESCRIPTION                       MTL_CATEGORIES_TL.DESCRIPTION%TYPE              :=  g_MISS_CHAR
     ,ATTRIBUTE_CATEGORY                MTL_CATEGORIES_B.ATTRIBUTE_CATEGORY%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE1                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE2                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE3                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE4                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE5                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE6                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE7                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE8                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE9                        MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE10                       MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE11                       MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE12                       MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE13                       MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE14                       MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
     ,ATTRIBUTE15                       MTL_CATEGORIES_B.ATTRIBUTE1%TYPE        :=  g_MISS_CHAR
--Bug: 2430879
     ,WEB_STATUS                        MTL_CATEGORIES_B.WEB_STATUS%TYPE        :=  g_MISS_CHAR
--Bug: 2645153
     ,SUPPLIER_ENABLED_FLAG             MTL_CATEGORIES_B.SUPPLIER_ENABLED_FLAG%TYPE     :=  g_MISS_CHAR
   );
  -----------------------------------------------------------------------------

  -- 1. Create_Category
  ----------------------------------------------------------------------------

/*#
 * Use this API to create a category.  The
 * record type passed in p_category_rec is as follows:
 *<code><pre>
  TYPE CATEGORY_REC_TYPE IS RECORD
  (
      CATEGORY_ID               MTL_CATEGORIES_B.CATEGORY_ID%TYPE                       :=  g_MISS_NUM
     ,STRUCTURE_ID              MTL_CATEGORIES_B.STRUCTURE_ID%TYPE                      :=  g_MISS_NUM
     ,STRUCTURE_CODE            FND_ID_FLEX_STRUCTURES.ID_FLEX_STRUCTURE_CODE%TYPE      :=  g_MISS_CHAR
     ,Columns SEGMENT1 to SEGMENT20               MTL_CATEGORIES_B.SEGMENT(n)%TYPE      :=  g_MISS_CHAR
     ,SUMMARY_FLAG              MTL_CATEGORIES_B.SUMMARY_FLAG%TYPE                      :=  g_MISS_CHAR
     ,ENABLED_FLAG              MTL_CATEGORIES_B.ENABLED_FLAG%TYPE                      :=  g_MISS_CHAR
     ,START_DATE_ACTIVE         MTL_CATEGORIES_B.START_DATE_ACTIVE%TYPE                 :=  g_MISS_DATE
     ,END_DATE_ACTIVE           MTL_CATEGORIES_B.END_DATE_ACTIVE%TYPE                   :=  g_MISS_DATE
     ,DISABLE_DATE              MTL_CATEGORIES_B.DISABLE_DATE%TYPE                      :=  g_MISS_DATE
     ,DESCRIPTION               MTL_CATEGORIES_TL.DESCRIPTION%TYPE                      :=  g_MISS_CHAR
     ,ATTRIBUTE_CATEGORY        MTL_CATEGORIES_B.ATTRIBUTE_CATEGORY%TYPE                :=  g_MISS_CHAR
     ,Columns ATTRIBUTE1 to ATTRIBUTE15         MTL_CATEGORIES_B.ATTRIBUTE(n)%TYPE      :=  g_MISS_CHAR
     ,WEB_STATUS                MTL_CATEGORIES_B.WEB_STATUS%TYPE                        :=  g_MISS_CHAR
     ,SUPPLIER_ENABLED_FLAG     MTL_CATEGORIES_B.SUPPLIER_ENABLED_FLAG%TYPE             :=  g_MISS_CHAR
   );
 *</pre></code>
 * <PRE>
 * PARAMETERS
 * ------------------------------------------------------------------------------------------------------
 * CATEGORY_ID                   : Not Required.
 * STRUCTURE_ID                  : The structure id of the category.
 * STRUCTURE_CODE                : The structure code of the category.
 * SEGMENT1 to SEGMENT20         : Defines the category.
 * SUMMARY_FLAG                  : Not required.
 * ENABLED_FLAG                  : Not required.
 * START_DATE_ACTIVE             : Not required.
 * END_DATE_ACTIVE               : Not required.
 * DISABLE_DATE                  : Disbale date of the category.
 * DESCRIPTION                   : Category Description.
 * ATTRIBUTE_CATEGORY            : Descriptive attributes category.
 * ATTRIBUTE1 to ATTRIBUTE15     : These are descriptive attributes.
 * WEB_STATUS                    : Indicates weather the category is enabled for iProcurement or not.
 * SUPPLIER_ENABLED_FLAG         : Indicates weather the category should be viewable by supplier or not.
 * ------------------------------------------------------------------------------------------------------
 *
 * NOTE :
 * <LI> Either STRUCTURE_ID or STRUCTURE_CODE can be populated to identify the structure. </LI>
 * </PRE>
 * @param p_category_rec Each record contains the complete interface record
 * containg 47 fields representing attribute values for the category to be created .
 * For more information about the record fields, see the parameter
 * documentation for the full parameter-list version of Create Category.
 * @rep:displayname Create Category
 * @rep:scope public
 */


  PROCEDURE Create_Category
  (
    p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER,
    x_msg_data         OUT  NOCOPY VARCHAR2,
    p_category_rec     IN   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE,
    x_category_id      OUT  NOCOPY NUMBER
  );
    -- Start OF comments
    -- API name  : Create_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create a category.
    --             If this operation fails then the category is not
    --              created and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_rec    IN  MTL_CATEGORIES (required)
    --             complete interface RECORD
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             x_category_id     OUT NUMBER
    --             returns category id of record processed
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------


  -- 2. Update_Category
  ----------------------------------------------------------------------------



/*#
 * Use this API to update a category.  The
 * record type passed in p_category_rec is as follows:
 *<code><pre>
  TYPE CATEGORY_REC_TYPE IS RECORD
  (
      CATEGORY_ID               MTL_CATEGORIES_B.CATEGORY_ID%TYPE                       :=  g_MISS_NUM
     ,STRUCTURE_ID              MTL_CATEGORIES_B.STRUCTURE_ID%TYPE                      :=  g_MISS_NUM
     ,STRUCTURE_CODE            FND_ID_FLEX_STRUCTURES.ID_FLEX_STRUCTURE_CODE%TYPE      :=  g_MISS_CHAR
     ,Columns SEGMENT1 to SEGMENT20               MTL_CATEGORIES_B.SEGMENT(n)%TYPE      :=  g_MISS_CHAR
     ,SUMMARY_FLAG              MTL_CATEGORIES_B.SUMMARY_FLAG%TYPE                      :=  g_MISS_CHAR
     ,ENABLED_FLAG              MTL_CATEGORIES_B.ENABLED_FLAG%TYPE                      :=  g_MISS_CHAR
     ,START_DATE_ACTIVE         MTL_CATEGORIES_B.START_DATE_ACTIVE%TYPE                 :=  g_MISS_DATE
     ,END_DATE_ACTIVE           MTL_CATEGORIES_B.END_DATE_ACTIVE%TYPE                   :=  g_MISS_DATE
     ,DISABLE_DATE              MTL_CATEGORIES_B.DISABLE_DATE%TYPE                      :=  g_MISS_DATE
     ,DESCRIPTION               MTL_CATEGORIES_TL.DESCRIPTION%TYPE                      :=  g_MISS_CHAR
     ,ATTRIBUTE_CATEGORY        MTL_CATEGORIES_B.ATTRIBUTE_CATEGORY%TYPE                :=  g_MISS_CHAR
     ,Columns ATTRIBUTE1 to ATTRIBUTE15         MTL_CATEGORIES_B.ATTRIBUTE(n)%TYPE      :=  g_MISS_CHAR
     ,WEB_STATUS                MTL_CATEGORIES_B.WEB_STATUS%TYPE                        :=  g_MISS_CHAR
     ,SUPPLIER_ENABLED_FLAG     MTL_CATEGORIES_B.SUPPLIER_ENABLED_FLAG%TYPE             :=  g_MISS_CHAR
   );
 *</pre></code>
 * <PRE>
 * PARAMETERS
 * ------------------------------------------------------------------------------------------------------
 * CATEGORY_ID                   : The Category ID of the category to be updated.
 * STRUCTURE_ID                  : The structure id of the category.
 * STRUCTURE_CODE                : The structure code of the category.
 * SEGMENT1 to SEGMENT20         : Defines the category.
 * SUMMARY_FLAG                  : Not required.
 * ENABLED_FLAG                  : Not required.
 * START_DATE_ACTIVE             : Not required.
 * END_DATE_ACTIVE               : Not required.
 * DISABLE_DATE                  : Disbale date of the category.
 * DESCRIPTION                   : Category Description.
 * ATTRIBUTE_CATEGORY            : Descriptive attributes category.
 * ATTRIBUTE1 to ATTRIBUTE15     : These are descriptive attributes.
 * WEB_STATUS                    : Indicates weather the category is enabled for iProcurement or not.
 * SUPPLIER_ENABLED_FLAG         : Indicates weather the category should be viewable by supplier or not.
 * ------------------------------------------------------------------------------------------------------
 *
 * NOTE :
 * <LI> Either CATEGORY_ID or SEGMENT1 to SEGMENT20 can be populated to identify the category.</LI>
 * <LI> Either STRUCTURE_ID or STRUCTURE_CODE can be populated to identify the structure. </LI>
 * </PRE>
 * @param p_category_rec This record contains 47
 * fields representing the new attribute values for the category
 * to be updated.
 * For more information about the record fields, see the parameter
 * documentation for the full parameter-list version of Update Category.
 * @rep:displayname Update Category
 * @rep:scope public
 */

  PROCEDURE Update_Category
  (
    p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER,
    x_msg_data         OUT  NOCOPY VARCHAR2,
    p_category_rec     IN   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE
   );
    -- Start OF comments
    -- API name  : Update_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update a category.
    --             If this operation fails then the category is not
    --             updated and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_rec    IN  MTL_CATEGORIES (required)
    --             new category attribute values
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------


  -- 3. Update_Category_Description
  ----------------------------------------------------------------------------

/*#
 * Use this API to update a category description.
 * @param p_category_id contains the category id for the record for
 * which the description needs to be updated. The language in which
 * the description is updated is the currently set language for the session.
 * @param p_description contains the new description to be set for the given
 * category.
 * @rep:displayname Update Category Description
 * @rep:scope public
 */


  PROCEDURE Update_Category_Description
  (
    p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER,
    x_msg_data         OUT  NOCOPY VARCHAR2,
    p_category_id      IN   NUMBER,
    p_description      IN   VARCHAR2
    -- deleted as this can be picked up from the environment.
    --p_language         IN   VARCHAR2
   );
    -- Start OF comments
    -- API name  : Update_Category_Description
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update a category description in the specified language.
    --             If this operation fails then the category description
    --             is not updated and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_description      IN  VARCHAR2 (required)
    --             new category description
    --
    --             p_language         IN  VARCHAR2 (required)
    --             language of description
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------

  -- 4. Delete_Category
  ----------------------------------------------------------------------------
/*#
 * Use this API to delete a category. If category is assigned to a category set or
 * has item assignments the category cannot be deleted.
 * @param p_category_id contains the category id of the category to be deleted.
 * @rep:displayname Delete Category
 * @rep:scope public
 */

  PROCEDURE Delete_Category
  (
    p_api_version      IN   NUMBER,
    p_init_msg_list    IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_errorcode        OUT  NOCOPY NUMBER,
    x_msg_count        OUT  NOCOPY NUMBER,
    x_msg_data         OUT  NOCOPY VARCHAR2,
    p_category_id      IN   NUMBER
   );
    -- Start OF comments
    -- API name  : Delete_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete a category.
    --             If this operation fails then the category is not
    --             deleted and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_id      IN  NUMBER (required)
    --             category to delete
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------

  -- 5. Create_Category_Assignment
  ----------------------------------------------------------------------------
  /*#
 * Use this API to create an item category assignment.
 * @param p_category_id contains the category id of the category to which the item
   has to be assigned.
 * @param p_category_set_id contains the category set for the assignment being created.
 * An item can be assigned to only one category within a category set.
 * @param p_inventory_item_id contains the item id of the atem to be assigned.
 * @param p_organization_id contains the organization id of the item to be assigned.
 * @rep:displayname Create Item Category Assignment
 * @rep:scope public
 */
  PROCEDURE Create_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_errorcode         OUT  NOCOPY NUMBER,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
   );
    -- Start OF comments
    -- API name  : Create_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create an item category assignment.
    --             If this operation fails then the item-category assignment
    --             is not created and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_id      IN  NUMBER (required)
    --             category for assigning item
    --
    --             p_category_set_id  IN  NUMBER (required)
    --             category set for assignment. An item can be assigned to
    --             only one category within a category set.
    --
    --             p_inventory_item_id IN  NUMBER (required)
    --             id of inventory item (item key)
    --
    --             p_organization_id  IN  NUMBER (required)
    --             id of item organization  (item key)

    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------

  -- 6. Delete_Category_Assignment
  ----------------------------------------------------------------------------
  /*#
 * Use this API to delete an item category assignment. User cannot delete a category
 * assignment if it is a defualt functional area item category assignment or if the category
 * set is master controlled and current organisation is not the master organisation.
 * @param p_category_id contains the category of the assignment to be deleted.
 * @param p_category_set_id contains the category set for the assignment being deleted.
 * @param p_inventory_item_id contains the item id of the assigned item.
 * @param p_organization_id contains the organization id of the assigned item.
 * @rep:displayname Delete Item Category Assignment.
 * @rep:scope public
 */
  PROCEDURE Delete_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_errorcode         OUT  NOCOPY NUMBER,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_category_id       IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER
   );
    -- Start OF comments
    -- API name  : Delete_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete an item category assignment.
    --             If this operation fails then the category is not
    --             deleted and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_id      IN  NUMBER (required)
    --             category of the assginement
    --
    --             p_category_set_id  IN  NUMBER (required)
    --             category set of the assignment.
    --
    --             p_inventory_item_id IN  NUMBER (required)
    --             assigned inventory item (item key)
    --
    --             p_organization_id  IN  NUMBER (required)
    --             item organization of the assigned item (item key)

    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------


  -- 7. Get_Category_Rec_Type
  ----------------------------------------------------------------------------
  FUNCTION Get_Category_Rec_Type
    RETURN INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE ;

 -----------------------------------------------------------------------------
  -- 8. Validate_iProcurements_flags
  --Bug: 2645153 validating structure and iProcurement flags
  -- Validate WEB_STATUS and SUPPLIER_ENABLED_FLAG
  ----------------------------------------------------------------------------
  PROCEDURE Validate_iProcurements_flags
  (
    x_category_rec  IN INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE
   );

  -- 9.  Create Valid Category
  -- Bug: 3093555
  -- API to create a valid Category in Category Sets
  -----------------------------------------------------------------------------
  /*#
 * Use this API to for assigning a category to a category set. A category will be available
 * in the list of valid categoies for a category set only if it is assigned to the category set.
 * @param p_category_id contains the category id of the category being created.
 * @param p_category_set_id identifies the category set in which the category is to be created.
 * @param p_parent_category_id  if NULL then this category becomes a first level child in the category set.
 * @rep:displayname Assign a Category to a Category Set.
 * @rep:scope public
 */
  PROCEDURE Create_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_parent_category_id  IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  );
    -- Start OF comments
    -- API name  : Create_Valid_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Create a record in mtl_category_set_valid_cats.
    --             If this operation fails then the category is not
    --              created and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version         IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level      IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit              IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_set_id     IN  NUMBER (required)
    --                                       category_set_id
    --
    --             p_category_id         IN  NUMBER (required)
    --                                       category_id
    --
    --             p_parent_category_id  IN  NUMBER (required)
    --                                       parent of current category id
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  -----------------------------------------------------------------------------

  -- 10. Update Valid Category
  -- Bug: 3093555
  -- API to update a valid Category in Category Sets
  -----------------------------------------------------------------------------
  /*#
 * Use this API to for reassigning the parent category of a category in a given category set.
 * @param p_category_id contains the category id of the category being updated.
 * @param p_category_set_id identifies the category set to which the category belongs.
 * @param p_parent_category_id contains the parent of the current category id.
 * @rep:displayname Update Parent Category of a given Category.
 * @rep:scope public
 */
  PROCEDURE Update_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_parent_category_id  IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  );
    -- Start OF comments
    -- API name  : Update_Valid_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update a record in mtl_category_set_valid_cats.
    --             If this operation fails then the category is not
    --              updated and error code is returned.
    --             The record to be updated is identified by the keys
    --              category_id and category_set_id
    --
    -- Parameters:
    --     IN    : p_api_version         IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level      IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit              IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_set_id     IN  NUMBER (required)
    --                                       category_set_id
    --
    --             p_category_id         IN  NUMBER (required)
    --                                       category_id
    --
    --             p_parent_category_id  IN  NUMBER (required)
    --                                       parent of current category id
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  -----------------------------------------------------------------------------

  -- 11. Delete Valid Category
  -- Bug: 3093555
  -- API to delete Category Sets
  -----------------------------------------------------------------------------
  /*#
 * Use this API to delete category assignment to its category set.
 * @param p_category_id contains the category id of the category being updated.
 * @param p_category_set_id identifies the category set to which the category belongs.
 * @rep:displayname Delete Category from a Category Set.
 * @rep:scope public
 */
  PROCEDURE Delete_Valid_Category(
    p_api_version         IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
  );
    -- Start OF comments
    -- API name  : Delete_Valid_Category
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Delete the record from mtl_category_set_valid_cats.
    --             If this operation fails then the category is not deleted
    --
    -- Parameters:
    --     IN    : p_api_version         IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level      IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit              IN  VARCHAR2 (optional)
    --                                       DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_set_id     IN  NUMBER (required)
    --                                       category_set_id
    --
    --             p_category_id         IN  NUMBER (required)
    --                                       category_id
    --
    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------
  --  12. Process_dml_on_row
  --  Bug: 5023883, Create/Update/Delete to the EGO tables
  ----------------------------------------------------------------------------
  PROCEDURE Process_Dml_On_Row
  (
    p_api_version         IN  NUMBER,
    p_category_set_id     IN  NUMBER,
    p_category_id         IN  NUMBER,
    p_mode                IN  VARCHAR2,
    x_return_status       OUT  NOCOPY VARCHAR2,
    x_errorcode           OUT  NOCOPY NUMBER,
    x_msg_count           OUT  NOCOPY NUMBER,
    x_msg_data            OUT  NOCOPY VARCHAR2
   );
  -----------------------------------------------------------------------------
  -----------------------------------------------------------------------------

  --* Code added for Bug #3991044
  -- 13. Update_Category_Assignment
  ----------------------------------------------------------------------------
  /*#
 * Use this API to for re-assigning an item to a new category in the given category set.
 * @param p_category_id contains the category id to which the item is to be assigned.
 * @param p_old_category_id contains the category to which the item is assigned
 * before updation.
 * @param p_category_set_id identifies the category set to which the old category belongs.
 * @param p_inventory_item_id contains the item id for which the assignment is to be updated.
 * @param p_organization_id contains the organization id of the organization to which the
 * item belongs.
 * @rep:displayname Update an Item Category Assignment.
 * @rep:scope public
 */
  PROCEDURE Update_Category_Assignment
  (
    p_api_version       IN   NUMBER,
    p_init_msg_list     IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit            IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_category_id       IN   NUMBER,
    p_old_category_id   IN   NUMBER,
    p_category_set_id   IN   NUMBER,
    p_inventory_item_id IN   NUMBER,
    p_organization_id   IN   NUMBER,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_errorcode         OUT  NOCOPY NUMBER,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2
   );
    -- Start OF comments
    -- API name  : Update_Category_Assignment
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Update an item category assignment.
    --             If this operation fails then the category is not
    --             updated and error code is returned.
    --
    -- Parameters:
    --     IN    : p_api_version      IN  NUMBER (required)
    --             API Version of this procedure
    --
    --             p_init_msg_level   IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_commit           IN  VARCHAR2 (optional)
    --                                    DEFAULT = FND_API.G_FALSE,
    --
    --             p_category_id      IN  NUMBER (required)
    --             new category to be updated
    --
    --             p_old_category_id  IN  NUMBER (required)
    --             existing category of the assginement
    --
    --             p_category_set_id  IN  NUMBER (required)
    --             category set of the assignment.
    --
    --             p_inventory_item_id IN  NUMBER (required)
    --             assigned inventory item (item key)
    --
    --             p_organization_id  IN  NUMBER (required)
    --             item organization of the assigned item (item key)

    --     OUT  :  x_msg_count        OUT NUMBER,
    --             number of messages in the message list
    --
    --             x_msg_data         OUT VARCHAR2,
    --             if number of messages is 1, then this parameter
    --             contains the message itself
    --
    --             X_return_status    OUT NUMBER
    --             Result of all the operations
    --                   FND_API.G_RET_STS_SUCCESS if success
    --                   FND_API.G_RET_STS_ERROR if error
    --                 FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --
    --             X_ErrorCode        OUT NUMBER
    --                RETURN value OF the x_errorcode
    --                check only if x_return_status <> fnd_api.g_ret_sts_success
    --                These errors are unrecoverable and the API failed as a result of this
    --                XXX - Error reason/message (will be updated after implementation)
    --                -1  - unexpected error - all operations have been rollbacked
    --
    --
    -- Version: Current Version 0.1
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
  ----------------------------------------------------------------------------
  --* End of Bug #3991044

  /* Add this procedure by geguo for bug 8547305 */
  ----------------------------------------------------------------------------------------------------------
  --when x_return_status return FND_API.G_RET_STS_SUCCESS,
  --  x_category_id return the category id if the segment combination existed.
  --  Or x_category_id return -1 if the combination doesn't exist.
  --when x_return_status return FND_API.G_RET_STS_UNEXP_ERROR Or G_RET_STS_ERROR
  --  indicating error happened, get the error message from x_msg_data
  ----------------------------------------------------------------------------------------------------------
  PROCEDURE Get_Category_Id_From_Cat_Rec(
    p_category_rec     IN   INV_ITEM_CATEGORY_PUB.CATEGORY_REC_TYPE,
    x_category_id      OUT  NOCOPY NUMBER,
    x_return_status    OUT  NOCOPY VARCHAR2,
    x_msg_data         OUT  NOCOPY VARCHAR2
  );

END INV_ITEM_CATEGORY_PUB;

/
