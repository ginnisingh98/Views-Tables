--------------------------------------------------------
--  DDL for Package IBE_DSP_HIERARCHY_SETUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DSP_HIERARCHY_SETUP_PUB" AUTHID CURRENT_USER AS
/* $Header: IBEPCHSS.pls 120.10 2006/04/18 16:12:37 abhandar ship $ */
/*#
 * This is the public package for the creation of the catalog.
 * @rep:scope public
 * @rep:product IBE
 * @rep:lifecycle active
 * @rep:displayname Catalog Setup API
 * @rep:category BUSINESS_ENTITY IBE_SECTION
 */

--  section record type
TYPE   SECTION_REC_TYPE    IS   RECORD (
   parent_section_id           	    NUMBER       := FND_API.G_MISS_NUM,
   parent_section_access_name      	VARCHAR2(240):= FND_API.G_MISS_CHAR,
   access_name                    	VARCHAR2(240):= FND_API.G_MISS_CHAR,
   start_date_active              	DATE,
   end_date_active                	DATE         := FND_API.G_MISS_DATE,
   section_type_code           	    VARCHAR2(30),
   status_code                 	    VARCHAR2(30),
   display_name                   	VARCHAR2(120),
   description                    	VARCHAR2(240) := FND_API.G_MISS_CHAR,
   long_description            	    VARCHAR2(4000):= FND_API.G_MISS_CHAR,
   keywords                       	VARCHAR2(1000):= FND_API.G_MISS_CHAR,
   attribute_category             	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute1                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute2                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute3                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute4                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute5                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute6                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute7                  		VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute8                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute9                     	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute10                    	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute11                    	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute12                    	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute13                    	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute14                    	VARCHAR2(150) := FND_API.G_MISS_CHAR,
   attribute15                    	VARCHAR2(150) := FND_API.G_MISS_CHAR
   );

/*#
 * Creates a section with Configurable Layout
 *
 * Description of the record SECTION_REC_TYPE
 * SECTION_REC_TYPE.parent_section_id - unique identifier of the parent section.
 * SECTION_REC_TYPE.parent_section_access_name - unique access name of the parent section.
 * SECTION_REC_TYPE.access_name - unique access name of the section.
 * SECTION_REC_TYPE.start_date_active - start date of the section.
 * SECTION_REC_TYPE.end_date_active  - end date of the section
 * SECTION_REC_TYPE.section_type_code  - type of section Navigational(N) or Featured(F).
 * SECTION_REC_TYPE.status_code  -  status of the section.
 * SECTION_REC_TYPE.display_name  -  name of the section.
 * SECTION_REC_TYPE.description    - description of the section.
 * SECTION_REC_TYPE.long_description - long description of  the sections.
 * SECTION_REC_TYPE.keywords - keywords.
 *
 * @param p_api_version     Stores the version number of the API. This is the local constant set by the API code.
 * @param p_init_msg_list   Initializes the API message list.
 * @param p_commit          Commits the transaction.
 * @param p_hierachy_section_rec Inputs the record structure containing information of the section to be created.
 * @param x_return_status   Return the status of the API operation
 * @param x_msg_count       Stores the number of messages in the API message list.
 * @param x_msg_data        Stores the message data in an encoded format if the message count is 1.
 * @param x_section_id      Stores the  unique identifier of the newly created section.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Section
 */
PROCEDURE Create_Section(
   p_api_version                   	IN NUMBER,
   p_init_msg_list                 	IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                        	IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status 	                OUT NOCOPY VARCHAR2,
   x_msg_count                     	OUT NOCOPY NUMBER,
   x_msg_data                       OUT NOCOPY VARCHAR2,
   p_hierachy_section_rec           IN  SECTION_REC_TYPE,
   x_section_id                     OUT NOCOPY NUMBER);


-- Section Item  record type
TYPE   SECTION_ITEM_REC_TYPE   IS   RECORD (
   section_item_id		 	NUMBER 		    :=FND_API.G_MISS_NUM,
   section_id             	NUMBER 		    :=FND_API.G_MISS_NUM,
   inventory_item_id        NUMBER,
   organization_id          NUMBER,
   start_date_active        DATE,
   end_date_active          DATE 		    := FND_API.G_MISS_DATE,
   sort_order               NUMBER		    := FND_API.G_MISS_NUM,
   association_reason_code  VARCHAR2(300)	:= FND_API.G_MISS_CHAR
  );


TYPE SECTION_ITEM_TBL_TYPE  IS TABLE OF SECTION_ITEM_REC_TYPE
INDEX BY BINARY_INTEGER;

/** Item Assoc  out Record Type */
TYPE   SECTION_ITEM_OUT_REC_TYPE   IS   RECORD (
      section_item_id		NUMBER,
      inventory_item_id     NUMBER,
      organization_id       NUMBER,
      x_return_status		VARCHAR2(1)
  );

TYPE  SECTION_ITEM_OUT_TBL_TYPE  IS TABLE OF SECTION_ITEM_OUT_REC_TYPE
INDEX BY BINARY_INTEGER;


/*#
 * Associate Inventory items to the section
 * Description of the SECTION_ITEM_REC_TYPE
 * SECTION_ITEM_REC_TYPE.section_item_id - unique identifier of the section_item association.
 * SECTION_ITEM_REC_TYPE.section_id      - unique identifier of the section.
 * SECTION_ITEM_REC_TYPE.inventory_item_id  - unique identifier of the inventory item.
 * SECTION_ITEM_REC_TYPE.organization_id  - unique identifier of the inventory organization.
 * SECTION_ITEM_REC_TYPE.start_date_active - start date of the section item association.
 * SECTION_ITEM_REC_TYPE.end_date_active  - end date of the section item association.
 * SECTION_ITEM_REC_TYPE.sort_order    - the order in which the items will be displayed under a section.
 * SECTION_ITEM_REC_TYPE.association_reason_code- reason why/how the item was related to the section.
 *
 * @param p_api_version     Stores the version number of the API. This is the local constant set by the API code.
 * @param p_init_msg_list   Initializes the API message list.
 * @param p_commit          Commits the transaction.
 * @param p_section_id      Stores the ID of the section to which  Inventory items are to be associated.
 * @param p_section_item_tbl  This is the input table for the Inventory items to be associated with the section.
                            The table should  mandatory  have values for the Inventory item ID and organization ID and start date.
                            The value of section id in the input table is not referenced for this API, hence need not be populated.
 * @param x_return_status   Return the status of the API operation.
 * @param x_msg_count       Stores the number of messages in the API message list.
 * @param x_msg_data        Stores the message data in an encoded format if the message count is 1.
 * @param x_section_item_out_tbl  This is an output table containing  return status for every instance of section-item association.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Section Item Association
 */
PROCEDURE Create_Section_Items(
   p_api_version                    	IN NUMBER,
   p_init_msg_list                    	IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                         	IN VARCHAR2 := FND_API.G_FALSE,
   x_return_status                  	OUT NOCOPY VARCHAR2,
   x_msg_count                      	OUT NOCOPY NUMBER,
   x_msg_data                       	OUT NOCOPY VARCHAR2,
   p_section_id                        	IN NUMBER,
   p_section_item_tbl               	IN SECTION_ITEM_TBL_TYPE,
   x_section_item_out_tbl            	OUT NOCOPY SECTION_ITEM_OUT_TBL_TYPE);


/* Record to hold object (item/section) , context ID and the deliverable_id(template) */
TYPE OBJ_LGL_CTNT_REC_TYPE  IS RECORD (
  object_id		          	    NUMBER,
  context_id              		NUMBER,
  deliverable_id 	      		NUMBER );

/* hold the records of above type */
TYPE obj_lgl_ctnt_tbl_type  IS TABLE OF
  obj_lgl_ctnt_rec_type INDEX BY BINARY_INTEGER;

/*  object lgl content out Record Type to store the results of API execution */
TYPE OBJ_LGL_CTNT_OUT_REC_TYPE  IS RECORD (
  object_id		          	    NUMBER,
  context_id              		NUMBER,
  deliverable_id 	      		NUMBER,
  x_return_status               VARCHAR2(1) );

/* table structure to hold the above types */
TYPE  OBJ_LGL_CTNT_OUT_TBL_TYPE  IS TABLE OF OBJ_LGL_CTNT_OUT_REC_TYPE
INDEX BY BINARY_INTEGER;

/*#
* Associate logical content (media object/ display template) to objects(Inventory item/section)
*
* This API is used for following purposes: Item-media object association,item-display template association ,section-media object association,
* section-layout component template association(for Configurable Layout) and  section-display template association(for Configurable Layout).
*
*  (1) Item-media object association : The required input parameters are
*  object_type - 'I'
*  OBJ_LGL_CTNT_REC_TYPE.object_id -  value of inventory_item_id from mtl_system_items_b
*  OBJ_LGL_CTNT_REC_TYPE.context_id -  value of  context_id from from ibe_dsp_context_vl where  context_type_code= 'MEDIA' and component_type_code in ('PRODUCT','GENERIC').
*  OBJ_LGL_CTNT_REC_TYPE.deliverable_id - value of item_id from  jtf_amv_items_vl where  deliverable_type_code='TEMPLATE' and applicable_to_code='PRODUCT_SECTION').
*
* (2) Item-display template association : The required input parameters are
*  object_type - 'I'.
*  OBJ_LGL_CTNT_REC_TYPE.object_id -  value of inventory_item_id from mtl_system_items_b.
*  OBJ_LGL_CTNT_REC_TYPE.context_id -  value of  context_id from from ibe_dsp_context_vl where  where  context_type_code='TEMPLATE'.
*  OBJ_LGL_CTNT_REC_TYPE.deliverable_id - value of item_id from jtf_amv_items_vl where deliverable_type_code='TEMPLATE'  and  applicable_to_code='PRODUCT_SECTION'.
*
* (3) Section-media object association: The required input parameters are
*  object_type - 'S'
*  OBJ_LGL_CTNT_REC_TYPE.object_id -  value of section_id  from  ibe_dsp_sections_b.
*  OBJ_LGL_CTNT_REC_TYPE.context_id -  value of context_id from ibe_dsp_context_vl where context_type_code='MEDIA' and component_type_code in  ('SECTION','GENERIC').
*  OBJ_LGL_CTNT_REC_TYPE.deliverable_id - value of item_id from  jtf_amv_items_vl where  deliverable_type_code='MEDIA' and applicable_to_code='SECTION'.
*
*  (4) Section-layout component template association(for Configurable Layout)- The required input parameters are
*  object_type - 'S'
*  OBJ_LGL_CTNT_REC_TYPE.object_id -  value of section_id  from  ibe_dsp_sections_b.
*  OBJ_LGL_CTNT_REC_TYPE.context_id -  value of context_id from ibe_dsp_context_vl where  context_type_code='LAYOUT_COMPONENT' and component_type_code='SECTION'  and access_name not in ('CENTER').
*  OBJ_LGL_CTNT_REC_TYPE.deliverable_id - value of item_id from  jtf_amv_items_vl where deliverable_type_code='TEMPLATE' and applicable_to_code='COMPONENT_SECTION'.
*
* (5) Section-display template association(for Configurable Layout) : The required input parameters are
*  object_type - 'S'
*  OBJ_LGL_CTNT_REC_TYPE.object_id -  value of section_id  from  ibe_dsp_sections_b.
*  OBJ_LGL_CTNT_REC_TYPE.context_id -  value of context_id from ibe_dsp_context_vl where  context_type_code='LAYOUT_COMPONENT' and component_type_code='SECTION'  and access_name='CENTER'.
*  OBJ_LGL_CTNT_REC_TYPE.deliverable_id - value of item_id from jtf_amv_items_vl where deliverable_type_code='TEMPLATE' and applicable_to_code like 'COMPONENT_SECT_%') and applicable_to_code not in ('COMPONENT_SECTION').
*
* @param p_api_version      Stores the version number of the API. This is the local constant set by the API code.
* @param p_init_msg_list    Initializes the API message list.
* @param p_commit           Commits the transaction.
* @param p_object_type      Stores the object type, valid values are namely 'S' (section) and 'I'(item).
* @param p_obj_lgl_ctnt_tbl This is the input table for the object, deliverable and context to be associated.
* @param x_return_status    Return the status of the API operation.
* @param x_msg_count        Stores the number of messages in the API message list.
* @param x_msg_data         Stores the message data in an encoded format if the message count is 1.
* @param x_obj_lgl_ctnt_out_tbl  This is the ouput table containing the return status for every instance of object and logical content association.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create Object Logical Content
 */
PROCEDURE Create_Object_Logical_Content (
  p_api_version        		    IN  NUMBER,
  p_init_msg_list       		IN  VARCHAR2 := FND_API.g_false,
  p_commit              		IN  VARCHAR2 := FND_API.g_false,
  p_object_type			        IN  VARCHAR2,
  p_obj_lgl_ctnt_tbl		    IN  OBJ_LGL_CTNT_TBL_TYPE,
  x_return_status       		OUT NOCOPY VARCHAR2,
  x_msg_count           		OUT NOCOPY  NUMBER,
  x_msg_data            		OUT NOCOPY  VARCHAR2,
  x_obj_lgl_ctnt_out_tbl        OUT NOCOPY OBJ_LGL_CTNT_OUT_TBL_TYPE
  );

END IBE_DSP_HIERARCHY_SETUP_PUB;

 

/
