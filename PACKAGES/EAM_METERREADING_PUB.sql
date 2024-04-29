--------------------------------------------------------
--  DDL for Package EAM_METERREADING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METERREADING_PUB" AUTHID CURRENT_USER as
/* $Header: EAMPMTRS.pls 120.3 2005/06/23 07:47:47 appldev ship $ */
/*#
 * This package is used for creating and disabling the meter readings.
 * It defines 2 key procedures create_meter_reading, disable_meter_reading
 * which first validates and massages the IN parameters
 * and then carries out the respective operations.
 * @rep:scope public
 * @rep:product EAM
 * @rep:lifecycle active
 * @rep:displayname Meter Reading package
 * @rep:category BUSINESS_ENTITY EAM_METER_READING
 */


TYPE Meter_Reading_Rec_Type is RECORD
(
meter_id                number := NULL,
meter_reading_id        number,
current_reading         number,
current_reading_date    date,
reset_flag              varchar2(1),
description             varchar2(100),
wip_entity_id           number,
check_in_out_type       number,
check_in_out_txn_id     number,
instance_id             number,
source_line_id          number,
source_code             varchar2(30),
wo_entry_fake_flag      varchar2(1),
adjustment_type         varchar2(30),
adjustment_reading      number,
net_reading             number,
reset_reason            VARCHAR2(255),
attribute_category      varchar2(30),
attribute1              varchar2(150),
attribute2              varchar2(150),
attribute3              varchar2(150),
attribute4              varchar2(150),
attribute5              varchar2(150),
attribute6              varchar2(150),
attribute7              varchar2(150),
attribute8              varchar2(150),
attribute9              varchar2(150),
attribute10             varchar2(150),
attribute11             varchar2(150),
attribute12             varchar2(150),
attribute13             varchar2(150),
attribute14             varchar2(150),
attribute15             varchar2(150),
attribute16             varchar2(150),
attribute17             varchar2(150),
attribute18             varchar2(150),
attribute19             varchar2(150),
attribute20             varchar2(150),
attribute21             varchar2(150),
attribute22             varchar2(150),
attribute23             varchar2(150),
attribute24             varchar2(150),
attribute25             varchar2(150),
attribute26             varchar2(150),
attribute27             varchar2(150),
attribute28             varchar2(150),
attribute29             varchar2(150),
attribute30             varchar2(150)
);

TYPE Ctr_Property_Readings_Rec IS RECORD
(
counter_property_id     number,
property_value          varchar2(240),
value_timestamp         date,
attribute_category      varchar2(30),
attribute1              varchar2(150),
attribute2              varchar2(150),
attribute3              varchar2(150),
attribute4              varchar2(150),
attribute5              varchar2(150),
attribute6              varchar2(150),
attribute7              varchar2(150),
attribute8              varchar2(150),
attribute9              varchar2(150),
attribute10             varchar2(150),
attribute11             varchar2(150),
attribute12             varchar2(150),
attribute13             varchar2(150),
attribute14             varchar2(150),
attribute15             varchar2(150),
migrated_flag           VARCHAR2(1)
);

TYPE Ctr_Property_readings_Tbl IS TABLE OF Ctr_Property_Readings_Rec
          INDEX BY BINARY_INTEGER;



/*#
 * This procedure creates the meter reading. It creates one row of record at a time.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_meter_reading_rec This is a PL SQL record type, it consists of all the columns of the EAM_METER_READINGS table except LIFE_TO_DATE_READING, DISABLE_FLAG and WHO columns
 * @param p_ctr_property_readings_tbl This is a PL SQL table type, it consists of all the columns for the Counter properties
 * @param p_value_before_reset This is the meter reading (life _to_date) value before the reset. This is mandatory if the current reading is reset reading
 * @param p_ignore_warnings Indicates whether any violation of Meter Direction should be ignored or not
 * @param x_meter_reading_id This is the unique identifier of the newly created record. It is the meter reading identifier
 * @return Returns the unique identifier of newly created record and status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Create meter reading
 */

procedure create_meter_reading
(
   p_api_version                IN             number,
   p_init_msg_list              IN             varchar2 := FND_API.G_FALSE,
   p_commit                     IN             varchar2 := FND_API.G_FALSE,
   x_msg_count                  OUT  NOCOPY    number,
   x_msg_data                   OUT  NOCOPY    varchar2,
   x_return_status              OUT  NOCOPY    varchar2,
   p_meter_reading_rec          IN             EAM_MeterReading_PUB.Meter_Reading_Rec_Type,
   p_ctr_property_readings_tbl  IN             EAM_MeterReading_PUB.Ctr_Property_readings_Tbl,
   p_value_before_reset         IN             number := NULL,
   p_ignore_warnings            IN             varchar2 := 'Y',
   x_meter_reading_id           OUT  NOCOPY    number
);


/*#
 * This procedure creates the meter reading. It creates one row of record at a time. Thsi is an overloaded API retained for backward compatibility.
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_meter_reading_rec This is a PL SQL record type, it consists of all the columns of the EAM_METER_READINGS table except LIFE_TO_DATE_READING, DISABLE_FLAG and WHO columns
 * @param p_value_before_reset This is the meter reading (life _to_date) value before the reset. This is mandatory if the current reading is reset reading
 * @param p_ignore_warnings Indicates whether any violation of Meter Direction should be ignored or not
 * @param x_meter_reading_id This is the unique identifier of the newly created record. It is the meter reading identifier
 * @return Returns the unique identifier of newly created record and status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Create meter reading
 */

procedure create_meter_reading
(
   p_api_version                IN             number,
   p_init_msg_list              IN             varchar2 := FND_API.G_FALSE,
   p_commit                     IN             varchar2 := FND_API.G_FALSE,
   x_msg_count                  OUT  NOCOPY    number,
   x_msg_data                   OUT  NOCOPY    varchar2,
   x_return_status              OUT  NOCOPY    varchar2,
   p_meter_reading_rec          IN             EAM_MeterReading_PUB.Meter_Reading_Rec_Type,
   p_value_before_reset         IN             number := NULL,
   p_ignore_warnings            IN             varchar2 := 'Y',
   x_meter_reading_id           OUT  NOCOPY    number
);


/*#
 * This procedure updates the meter reading. It updates one row of record at a time
 * @param p_api_version  Version of the API
 * @param p_init_msg_list Flag to indicate initialization of message list
 * @param p_commit Flag to indicate whether API should commit changes
 * @param x_return_status Return status of the procedure call
 * @param x_msg_count Count of the return messages that API returns
 * @param x_msg_data The collection of the messages.
 * @param p_meter_reading_id The unique identifier of the meter reading record
* @param p_meter_id The unique identifier for the meter
* @param p_meter_reading_date The meter reading date
 * @return Returns the status of the procedure call as well as the return messages
 * @rep:scope public
 * @rep:displayname Disable meter reading
 */

procedure disable_meter_reading
(
        p_api_version         IN    NUMBER,
        p_init_msg_list       IN    VARCHAR2:=FND_API.G_FALSE,
        p_commit              IN    VARCHAR2:=FND_API.G_FALSE,
        x_msg_count           OUT NOCOPY   NUMBER,
        x_msg_data            OUT NOCOPY   VARCHAR2,
        x_return_status       OUT NOCOPY   VARCHAR2,
        p_meter_reading_id    IN    NUMBER:=null,
        p_meter_id            IN    NUMBER:=null,
        p_meter_reading_date  IN    DATE :=NULL
);


end EAM_MeterReading_PUB;

 

/
