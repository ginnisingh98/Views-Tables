--------------------------------------------------------
--  DDL for Package QA_DEVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_DEVICE_PUB" AUTHID CURRENT_USER AS
/* $Header: qadvpubs.pls 120.1.12010000.1 2008/07/25 09:19:19 appldev ship $ */
/*#
 * This package is the public interface for Device info setup and saving
 * of device data values. It allows for creation/removal of devices from Oracle Quality.
 * This is handled as a bulk operation. The package also has APIs to capture device data
 * values which can be later read from the Quality Collection Results UI.
 * The device data values can be set for a single device or for multiple devices in bulk.
 * @rep:scope public
 * @rep:product QA
 * @rep:displayname Device Integration Public APIs
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_PLAN
 */

--
-- Global type definitions
--

TYPE VARCHAR2000_TABLE IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE VARCHAR2_TABLE    IS TABLE OF VARCHAR2(256)  INDEX BY BINARY_INTEGER;
TYPE NUMBER_TABLE      IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;
TYPE DATE_TABLE        IS TABLE OF DATE           INDEX BY BINARY_INTEGER;

--
-- API name        : set_device_data
-- Type            : Public
-- Pre-reqs        : None
--
-- API to set device data value for a single device.
-- Version 1.0
--
-- This API is used to set the data value from a single device.
-- It updates the corresponding row for the device and inserts
-- a new row in case a row for the device doesn't exist in qa_device_data_values.
--
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_device_source                                         VARCHAR2(256)
--     The device source as defined during device setup.
--
--  p_device_name                                           VARCHAR2(256)
--     Unique device name.
--
--  p_device_data                                           VARCHAR2(256)
--     Data read from the device.
--
--  p_device_event_time                                     DATE
--     The time of generation of data from the device.
--
--  p_quality_code                                          NUMBER
--     The Quality of data. Only data with quality
--     192(0xC0) or 216(0xD8) will be accepted
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * API to set device data value for a single device.
 * @param p_api_version Current version is 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_device_source An identifier indicating the source, generally use 'OPC'
 * @param p_device_name Full qualifying identifier of a device I/O, max 256
 * @param p_device_data Device data, max 256
 * @param p_device_event_time The timestamp when value was generated by device
 * @param p_quality_code A numeric code indicating the quality of the reading
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned if any
 * @param x_return_status API return status
 * @rep:displayname Set device value
 */
PROCEDURE set_device_data(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN  NUMBER   := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2 := NULL,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2,
    p_device_data               IN  VARCHAR2,
    p_device_event_time         IN  DATE,
    p_quality_code              IN  NUMBER,
    p_commit                    IN  VARCHAR2 := fnd_api.g_true,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);


--
-- API name        : set_device_data_bulk
-- Type            : Public
-- Pre-reqs        : None
--
-- API to set device data values for multiple devices.
-- Version 1.0
--
-- This API is used to set the data values from multiple devices.
-- It updates the corresponding rows for each device and inserts
-- a new row in case a row for the device doesn't exist in qa_device_data_values.
--
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_device_source                                         VARCHAR2(256)
--     The device source as defined during device setup.
--
--  p_device_name                                           VARCHAR2_TABLE
--     Unique device name.
--
--  p_device_data                                           VARCHAR2_TABLE
--     Data read from the device.
--
--  p_device_event_time                                     DATE_TABLE
--     The time of generation of data from the device.
--
--  p_quality_code                                          NUMBER_TABLE
--     The Quality of data. Only data with quality
--     192(0xC0) or 216(0xD8) will be accepted.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * API to set device data values for multiple devices.
 * @param p_api_version Current version is 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_device_source An identifier indicating the source, generally use 'OPC'
 * @param p_device_name An array of full qualifying identifiers, each max 256
 * @param p_device_data An array of device data, each max 256
 * @param p_device_event_time An array of timestamp when values were generated by devices
 * @param p_quality_code An array of numeric codes indicating the quality of the readings
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned if any
 * @param x_return_status API return status
 * @rep:displayname Set multiple device values by bulk operation
 */
PROCEDURE set_device_data_bulk(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN  NUMBER   := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2 := NULL,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2_TABLE,
    p_device_data               IN  VARCHAR2_TABLE,
    p_device_event_time         IN  DATE_TABLE,
    p_quality_code              IN  NUMBER_TABLE,
    p_commit                    IN  VARCHAR2 := fnd_api.g_true,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);

--
-- API name        : add_device_info_bulk
-- Type            : Public
-- Pre-reqs        : None
--
-- API to add device setup info in bulk in Oracle Quality.
-- Version 1.0
--
-- This API is used to add one or more new devices to Oracle.
-- It adds rows to the qa_device_info internal table that stores
-- device meta data, one row per device name.  It also adds rows to
-- the qa_device_data_values internal table to prepare for updates by
-- the set_device_data APIs used during actual data pushing
--
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_device_source                                         VARCHAR2(256)
--     The device source.  Always pass in 'OPC'
--
--  p_device_name                                           VARCHAR2_TABLE
--     Unique device name.
--
--  p_device_desc                                           VARCHAR2000_TABLE
--     Meaningful description for the device
--
--  p_expiration                                            NUMBER_TABLE
--     The maximum time in ms to check the validity
--     of data from the device. Data older than this
--     will be rejected.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * API to add device setup info in bulk to Oracle Quality internal table.
 * @param p_api_version Current version is 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_device_source An identifier indicating the source, generally use 'OPC'
 * @param p_device_name An array of full qualifying identifiers, each max 256
 * @param p_device_desc An array of device description, any one element be null, each max 2000
 * @param p_expiration An array of numbers, each in milliseconds; if data in device data table is older than this, it will be considered expired
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned if any
 * @param x_return_status API return status
 * @rep:displayname Add multiple devices by bulk operation
 */
PROCEDURE add_device_info_bulk(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN  NUMBER   := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2 := NULL,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2_TABLE,
    p_device_desc               IN  VARCHAR2000_TABLE,
    p_expiration                IN  NUMBER_TABLE,
    p_commit                    IN  VARCHAR2 := fnd_api.g_true,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);


--
-- API name        : delete_device_info_bulk
-- Type            : Public
-- Pre-reqs        : None
--
-- API to delete device setup info in bulk from Oracle Quality.
-- Version 1.0
--
-- This API is used to delete one or more devices from Oracle Quality's
-- internal table - qa_device_info. Changes will be Committed by default.
--
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_device_source                                         VARCHAR2(256)
--     The device source as setup for the
--     corresponding device name.
--
--  p_device_name                                           VARCHAR2_TABLE
--     Name of device to be deleted.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * API to delete one or more devices from Oracle Quality's
 * internal table - qa_device_info.
 * @param p_api_version Current version is 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_device_source An identifier indicating the source, generally use 'OPC'
 * @param p_device_name An array of full qualifying identifiers to be deleted, each max 256
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned if any
 * @param x_return_status API return status
 * @rep:displayname Delete multiple devices by bulk operation
 */
PROCEDURE delete_device_info_bulk(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN  NUMBER   := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2 := NULL,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2_TABLE,
    p_commit                    IN  VARCHAR2 := fnd_api.g_true,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);

END qa_device_pub;

/