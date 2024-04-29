--------------------------------------------------------
--  DDL for Package EAM_METER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METER_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPMETS.pls 120.5 2006/06/21 17:59:12 hkarmach noship $ */
/*#
 * This package is used for the INSERT / UPDATE of meters.
 * It defines 2 key procedures create_meter, update_meter
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname EAM Meters
 * @rep:category BUSINESS_ENTITY EAM_METER
 */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='EAM_Meter_Pub';


TYPE Meter_Rec_Type is RECORD
(
 METER_ID                        NUMBER,
 METER_NAME                      VARCHAR2(50),
 METER_TYPE                      NUMBER,
 METER_UOM                       VARCHAR2(3),
 VALUE_CHANGE_DIR                Number,
 USED_IN_SCHEDULING              VARCHAR2(1),
 USER_DEFINED_RATE               Number,
 USE_PAST_READING                Number,
 DESCRIPTION                     VARCHAR2(240),
 FROM_EFFECTIVE_DATE             DATE,
 TO_EFFECTIVE_DATE               DATE,
 ATTRIBUTE_CATEGORY              VARCHAR2(30),
 ATTRIBUTE1                      VARCHAR2(150),
 ATTRIBUTE2                      VARCHAR2(150),
 ATTRIBUTE3                      VARCHAR2(150),
 ATTRIBUTE4                      VARCHAR2(150),
 ATTRIBUTE5                      VARCHAR2(150),
 ATTRIBUTE6                      VARCHAR2(150),
 ATTRIBUTE7                      VARCHAR2(150),
 ATTRIBUTE8                      VARCHAR2(150),
 ATTRIBUTE9                      VARCHAR2(150),
 ATTRIBUTE10                     VARCHAR2(150),
 ATTRIBUTE11                     VARCHAR2(150),
 ATTRIBUTE12                     VARCHAR2(150),
 ATTRIBUTE13                     VARCHAR2(150),
 ATTRIBUTE14                     VARCHAR2(150),
 ATTRIBUTE15                     VARCHAR2(150),
 ATTRIBUTE16                     VARCHAR2(150),
 ATTRIBUTE17                     VARCHAR2(150),
 ATTRIBUTE18                     VARCHAR2(150),
 ATTRIBUTE19                     VARCHAR2(150),
 ATTRIBUTE20                     VARCHAR2(150),
 ATTRIBUTE21                     VARCHAR2(150),
 ATTRIBUTE22                     VARCHAR2(150),
 ATTRIBUTE23                     VARCHAR2(150),
 ATTRIBUTE24                     VARCHAR2(150),
 ATTRIBUTE25                     VARCHAR2(150),
 ATTRIBUTE26                     VARCHAR2(150),
 ATTRIBUTE27                     VARCHAR2(150),
 ATTRIBUTE28                     VARCHAR2(150),
 ATTRIBUTE29                     VARCHAR2(150),
 ATTRIBUTE30                     VARCHAR2(150),
 TMPL_FLAG                       VARCHAR2(1),
 SOURCE_TMPL_ID                  NUMBER,
 INITIAL_READING                 NUMBER,
 EAM_REQUIRED_FLAG		 VARCHAR2(1)
);


/*#
 * This procedure is used to create EAM Meters.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_meter_name Name of the meter
 * @param p_meter_uom Unit Of Measure used to track usage
 * @param p_meter_type Meter type. 1 indicates absolute meter, 2 indicates change meter
 * @param p_VALUE_CHANGE_DIR Value Change Direction. 1 indicates ascending, 2 indicates descending, null indicates fluctuating
 * @param p_USED_IN_SCHEDULING Used in Scheduling Flag
 * @param p_USER_DEFINED_RATE Usage Rate
 * @param p_USE_PAST_READING  Indicator of how many past reading should be used to compute rate
 * @param p_DESCRIPTION   Meter description
 * @param p_FROM_EFFECTIVE_DATE  Effective start date
 * @param p_TO_EFFECTIVE_DATE  Effective end date
 * @param p_source_meter_id  Source Meter Id
 * @param p_factor  Factor by which source meter reading will be trickeled down to this meter
 * @param p_relationship_start_date  Start date of meter hierarchy
 * @param p_attribute_category Attribute Category
 * @param p_attribute1 Descriptive flexfield column
 * @param p_attribute2 Descriptive flexfield column
 * @param p_attribute3 Descriptive flexfield column
 * @param p_attribute4 Descriptive flexfield column
 * @param p_attribute5 Descriptive flexfield column
 * @param p_attribute6 Descriptive flexfield column
 * @param p_attribute7 Descriptive flexfield column
 * @param p_attribute8 Descriptive flexfield column
 * @param p_attribute9 Descriptive flexfield column
 * @param p_attribute10 Descriptive flexfield column
 * @param p_attribute11 Descriptive flexfield column
 * @param p_attribute12 Descriptive flexfield column
 * @param p_attribute13 Descriptive flexfield column
 * @param p_attribute14 Descriptive flexfield column
 * @param p_attribute15 Descriptive flexfield column
 * @param p_attribute16 Descriptive flexfield column
 * @param p_attribute17 Descriptive flexfield column
 * @param p_attribute18 Descriptive flexfield column
 * @param p_attribute19 Descriptive flexfield column
 * @param p_attribute20 Descriptive flexfield column
 * @param p_attribute21 Descriptive flexfield column
 * @param p_attribute22 Descriptive flexfield column
 * @param p_attribute23 Descriptive flexfield column
 * @param p_attribute24 Descriptive flexfield column
 * @param p_attribute25 Descriptive flexfield column
 * @param p_attribute26 Descriptive flexfield column
 * @param p_attribute27 Descriptive flexfield column
 * @param p_attribute28 Descriptive flexfield column
 * @param p_attribute29 Descriptive flexfield column
 * @param p_attribute30 Descriptive flexfield column
 * @param p_TMPL_FLAG Flag indicating if this is a template meter
 * @param p_SOURCE_TMPL_ID The meter template identifier from which this meter is created
 * @param p_INITIAL_READING The first meter reading upon meter creation
 * @param p_INITIAL_READING_DATE Date of Initial Reading
 * @param x_new_meter_id Meter Identifier
 * @return Returns the Primary Key of newly created record and status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Create EAM Meters
*/

procedure create_meter(
  p_api_version           IN            Number,
  p_init_msg_list         IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN            NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT nocopy    VARCHAR2,
  x_msg_count             OUT nocopy    NUMBER,
  x_msg_data              OUT nocopy    VARCHAR2,
  p_meter_name            IN            VARCHAR2,
  p_meter_uom             IN            VARCHAR2,
  p_METER_TYPE			      IN		        Number default 1,
  p_VALUE_CHANGE_DIR      IN            Number DEFAULT 1,
  p_USED_IN_SCHEDULING    IN            VARCHAR2 default 'N',
  p_USER_DEFINED_RATE     IN            Number default null,
  p_USE_PAST_READING      IN            Number default null,
  p_DESCRIPTION           IN            VARCHAR2 default null,
  p_FROM_EFFECTIVE_DATE   IN            DATE default null,
  p_TO_EFFECTIVE_DATE     IN            DATE default null,
  p_source_meter_id       IN            Number DEFAULT NULL,
  p_factor                IN            NUMBER DEFAULT 1,
  p_relationship_start_date IN         DATE default null,
  p_ATTRIBUTE_CATEGORY    IN            VARCHAR2 default null,
  p_ATTRIBUTE1            IN            VARCHAR2 default null,
  p_ATTRIBUTE2            IN            VARCHAR2 default null,
  p_ATTRIBUTE3            IN            VARCHAR2 default null,
  p_ATTRIBUTE4            IN            VARCHAR2 default null,
  p_ATTRIBUTE5            IN            VARCHAR2 default null,
  p_ATTRIBUTE6            IN            VARCHAR2 default null,
  p_ATTRIBUTE7            IN            VARCHAR2 default null,
  p_ATTRIBUTE8            IN            VARCHAR2 default null,
  p_ATTRIBUTE9            IN            VARCHAR2 default null,
  p_ATTRIBUTE10           IN            VARCHAR2 default null,
  p_ATTRIBUTE11           IN            VARCHAR2 default null,
  p_ATTRIBUTE12           IN            VARCHAR2 default null,
  p_ATTRIBUTE13           IN            VARCHAR2 default null,
  p_ATTRIBUTE14           IN            VARCHAR2 default null,
  p_ATTRIBUTE15           IN            VARCHAR2 default null,
  p_ATTRIBUTE16           IN            VARCHAR2 default null,
  p_ATTRIBUTE17           IN            VARCHAR2 default null,
  p_ATTRIBUTE18           IN            VARCHAR2 default null,
  p_ATTRIBUTE19           IN            VARCHAR2 default null,
  p_ATTRIBUTE20           IN            VARCHAR2 default null,
  p_ATTRIBUTE21           IN            VARCHAR2 default null,
  p_ATTRIBUTE22           IN            VARCHAR2 default null,
  p_ATTRIBUTE23           IN            VARCHAR2 default null,
  p_ATTRIBUTE24           IN            VARCHAR2 default null,
  p_ATTRIBUTE25           IN            VARCHAR2 default null,
  p_ATTRIBUTE26           IN            VARCHAR2 default null,
  p_ATTRIBUTE27           IN            VARCHAR2 default null,
  p_ATTRIBUTE28           IN            VARCHAR2 default null,
  p_ATTRIBUTE29           IN            VARCHAR2 default null,
  p_ATTRIBUTE30           IN            VARCHAR2 default null,
  p_TMPL_FLAG             IN            VARCHAR2 default 'N',
  p_SOURCE_TMPL_ID        IN            Number default null,
  p_INITIAL_READING       IN            Number default 0,
  P_INITIAL_READING_DATE  IN				    DATE default SYSDATE,
  P_EAM_REQUIRED_FLAG	  IN		VARCHAR2 default 'N',
  x_new_meter_id          OUT nocopy    Number);

/*#
 * This procedure is used to update EAM Meters.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param p_validation_level Validation Level of the API
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_meter_id Meter Identifier
 * @param p_meter_name Name of the meter
 * @param p_meter_uom Unit Of Measure used to track usage
 * @param p_meter_type Meter type. 1 indicates absolute meter, 2 indicates change meter
 * @param p_VALUE_CHANGE_DIR Value Change Direction. 1 indicates ascending, 2 indicates descending, null indicates fluctuating
 * @param p_USED_IN_SCHEDULING Used in Scheduling Flag
 * @param p_USER_DEFINED_RATE Usage Rate
 * @param p_USE_PAST_READING  Indicator of how many past reading should be used to compute rate
 * @param p_DESCRIPTION   Meter description
 * @param p_FROM_EFFECTIVE_DATE  Effective start date
 * @param p_TO_EFFECTIVE_DATE  Effective end date
 * @param p_source_meter_id  Source Meter Id
 * @param p_factor  Factor by which source meter reading will be trickeled down to this meter
 * @param p_relationship_start_date  Start date of meter hierarchy
 * @param p_attribute_category Attribute Category
 * @param p_attribute1 Descriptive flexfield column
 * @param p_attribute2 Descriptive flexfield column
 * @param p_attribute3 Descriptive flexfield column
 * @param p_attribute4 Descriptive flexfield column
 * @param p_attribute5 Descriptive flexfield column
 * @param p_attribute6 Descriptive flexfield column
 * @param p_attribute7 Descriptive flexfield column
 * @param p_attribute8 Descriptive flexfield column
 * @param p_attribute9 Descriptive flexfield column
 * @param p_attribute10 Descriptive flexfield column
 * @param p_attribute11 Descriptive flexfield column
 * @param p_attribute12 Descriptive flexfield column
 * @param p_attribute13 Descriptive flexfield column
 * @param p_attribute14 Descriptive flexfield column
 * @param p_attribute15 Descriptive flexfield column
 * @param p_attribute16 Descriptive flexfield column
 * @param p_attribute17 Descriptive flexfield column
 * @param p_attribute18 Descriptive flexfield column
 * @param p_attribute19 Descriptive flexfield column
 * @param p_attribute20 Descriptive flexfield column
 * @param p_attribute21 Descriptive flexfield column
 * @param p_attribute22 Descriptive flexfield column
 * @param p_attribute23 Descriptive flexfield column
 * @param p_attribute24 Descriptive flexfield column
 * @param p_attribute25 Descriptive flexfield column
 * @param p_attribute26 Descriptive flexfield column
 * @param p_attribute27 Descriptive flexfield column
 * @param p_attribute28 Descriptive flexfield column
 * @param p_attribute29 Descriptive flexfield column
 * @param p_attribute30 Descriptive flexfield column
 * @param p_TMPL_FLAG Flag indicating if this meter is a template or not
 * @param p_SOURCE_TMPL_ID The meter template identifier from which this meter has been created
 * @param p_from_eam Call is from EAM or not
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Update EAM Meters
 */

procedure update_meter (
  p_api_version           IN           Number,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN           NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status         OUT nocopy   VARCHAR2,
  x_msg_count             OUT nocopy   Number,
  x_msg_data              OUT nocopy   VARCHAR2,
  p_meter_id              IN           number,
  p_meter_name            IN           varchar default null,
  p_meter_uom             IN           varchar default null,
  p_METER_TYPE 			      IN 		       number default NULL,
  p_VALUE_CHANGE_DIR      IN           Number default NULL,
  p_USED_IN_SCHEDULING    IN           VARCHAR2 default NULL,
  p_USER_DEFINED_RATE     IN           Number default null,
  p_USE_PAST_READING      IN           Number default null,
  p_DESCRIPTION           IN           VARCHAR2 default null,
  p_FROM_EFFECTIVE_DATE   IN           DATE default null,
  p_TO_EFFECTIVE_DATE     IN           DATE default null,
  p_source_meter_id       IN           Number DEFAULT NULL,
  p_factor                IN           NUMBER DEFAULT NULL,
  p_relationship_start_date IN         DATE default null,
  p_ATTRIBUTE_CATEGORY    IN           VARCHAR2 default null,
  p_ATTRIBUTE1            IN           VARCHAR2 default null,
  p_ATTRIBUTE2            IN           VARCHAR2 default null,
  p_ATTRIBUTE3            IN           VARCHAR2 default null,
  p_ATTRIBUTE4            IN           VARCHAR2 default null,
  p_ATTRIBUTE5            IN           VARCHAR2 default null,
  p_ATTRIBUTE6            IN           VARCHAR2 default null,
  p_ATTRIBUTE7            IN           VARCHAR2 default null,
  p_ATTRIBUTE8            IN           VARCHAR2 default null,
  p_ATTRIBUTE9            IN           VARCHAR2 default null,
  p_ATTRIBUTE10           IN           VARCHAR2 default null,
  p_ATTRIBUTE11           IN           VARCHAR2 default null,
  p_ATTRIBUTE12           IN           VARCHAR2 default null,
  p_ATTRIBUTE13           IN           VARCHAR2 default null,
  p_ATTRIBUTE14           IN           VARCHAR2 default null,
  p_ATTRIBUTE15           IN           VARCHAR2 default null,
  p_ATTRIBUTE16           IN           VARCHAR2 default null,
  p_ATTRIBUTE17           IN           VARCHAR2 default null,
  p_ATTRIBUTE18           IN           VARCHAR2 default null,
  p_ATTRIBUTE19           IN           VARCHAR2 default null,
  p_ATTRIBUTE20           IN           VARCHAR2 default null,
  p_ATTRIBUTE21           IN           VARCHAR2 default null,
  p_ATTRIBUTE22           IN           VARCHAR2 default null,
  p_ATTRIBUTE23           IN           VARCHAR2 default null,
  p_ATTRIBUTE24           IN           VARCHAR2 default null,
  p_ATTRIBUTE25           IN           VARCHAR2 default null,
  p_ATTRIBUTE26           IN           VARCHAR2 default null,
  p_ATTRIBUTE27           IN           VARCHAR2 default null,
  p_ATTRIBUTE28           IN           VARCHAR2 default null,
  p_ATTRIBUTE29           IN           VARCHAR2 default null,
  p_ATTRIBUTE30           IN           VARCHAR2 default null,
  p_TMPL_FLAG             IN           VARCHAR2 default 'N',
  p_SOURCE_TMPL_ID        IN           Number default NULL,
  p_EAM_REQUIRED_FLAG     IN           VARCHAR2 default 'N',
  p_from_eam		  IN		varchar2 default null
  );


END EAM_METER_PUB;


 

/
