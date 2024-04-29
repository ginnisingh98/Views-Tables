--------------------------------------------------------
--  DDL for Package XNP_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_CORE" AUTHID CURRENT_USER AS
/* $Header: XNPCORES.pls 120.2 2006/02/13 07:43:05 dputhiye ship $ */

-- Declare global_variables

g_ENABLE_NRC_FLAG         CHAR(1);
g_DEFAULT_PORTING_STATUS  VARCHAR2(20);

-- Gets PHASE corresponding to the given status
-- The Status to Phase mapping is done at
-- configuration time. This procedure looks up the
-- Phase conrresponding to status
--
-- Tables: XNP_SV_STATUS_TYPES_B
--
PROCEDURE GET_PHASE_FOR_STATUS
 (p_CUR_STATUS_TYPE_CODE VARCHAR2
 ,x_PHASE_INDICATOR OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Gets the Subscription version ID
-- corresponding to the given TN and phase.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE GET_SOA_SV_ID
 (p_PHASE_INDICATOR     VARCHAR2
 ,p_SUBSCRIPTION_TN     VARCHAR2
 ,p_LOCAL_SP_ID         NUMBER DEFAULT NULL
 ,x_SV_ID           OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 );

-- Gets the number range ID for the given TN range.
-- It is ensured that the number range is currently
-- Active and effective as of current date
--
-- TABLES: XNP_NUMBER_RANGES

PROCEDURE GET_NUMBER_RANGE_ID
 (p_STARTING_NUMBER     VARCHAR2
 ,p_ENDING_NUMBER       VARCHAR2
 ,x_NUMBER_RANGE_ID OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 );

-- Gets the Subscription Version ID for subscription TN
-- from the table maintaining the ported numbers
-- The entries in this table are created before
-- provisioning a number or a number range using
-- XNP_CORE.CREATE_PORTED_NUMBER
--
-- TABLES: XNP_SV_SMS

PROCEDURE GET_SMS_SV_ID
 (p_SUBSCRIPTION_TN     VARCHAR2
 ,x_SV_ID           OUT NOCOPY NUMBER
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 );

-- Creates record(s) of the ported numbers.
-- Called During the Provisioning phase of the order
-- when requested by the NRC
-- Inserts a record in the table XNP_SV_SMS to record
-- all the numbers to be provisioned. A record is created
-- for each number in the range.
--
-- TABLES: XNP_SV_SMS
--
PROCEDURE SMS_CREATE_PORTED_NUMBER
 (p_PORTING_ID           IN  VARCHAR2
 ,p_STARTING_NUMBER      IN  NUMBER
 ,p_ENDING_NUMBER        IN  NUMBER
 ,p_SUBSCRIPTION_TYPE    IN  VARCHAR2
 ,p_ROUTING_NUMBER_ID    IN  NUMBER
 ,p_PORTING_TIME         IN  DATE
 ,p_CNAM_ADDRESS             VARCHAR2
 ,p_CNAM_SUBSYSTEM           VARCHAR2
 ,p_ISVM_ADDRESS             VARCHAR2
 ,p_ISVM_SUBSYSTEM           VARCHAR2
 ,p_LIDB_ADDRESS             VARCHAR2
 ,p_LIDB_SUBSYSTEM           VARCHAR2
 ,p_CLASS_ADDRESS            VARCHAR2
 ,p_CLASS_SUBSYSTEM          VARCHAR2
 ,p_WSMSC_ADDRESS            VARCHAR2
 ,p_WSMSC_SUBSYSTEM          VARCHAR2
 ,p_RN_ADDRESS               VARCHAR2
 ,p_RN_SUBSYSTEM             VARCHAR2
 ,p_ORDER_ID             IN  NUMBER
 ,p_LINEITEM_ID          IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID IN  NUMBER
 ,p_FA_INSTANCE_ID       IN  NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

--
-- Updates Record(s) in Porting orders table
-- for each TN in the range with the old SPCUToff date
-- The SVs to update are got by getting the TN
-- records in the phase mapping to the current status
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_STATUS_TYPES_B, XNP_SV_SOA_JN
--
PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (p_STARTING_NUMBER            VARCHAR2
 ,p_ENDING_NUMBER              VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE       VARCHAR2
 ,p_LOCAL_SP_ID                NUMBER DEFAULT NULL
 ,p_OLD_SP_CUTOFF_DUE_DATE     DATE
 ,p_ORDER_ID               IN  NUMBER
 ,p_LINEITEM_ID            IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID   IN  NUMBER
 ,p_FA_INSTANCE_ID         IN  NUMBER
 ,x_ERROR_CODE             OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 );

-- Updates the OLD SP due date
-- in table containing porting orders for the given TN range and given phase.
--
-- The SVs to update are got by getting the TN
-- records in the phase mapping to the current status
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_STATUS_TYPES_B, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_OLD_SP_DUE_DATE
 (p_STARTING_NUMBER            VARCHAR2
 ,p_ENDING_NUMBER              VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE       VARCHAR2
 ,p_LOCAL_SP_ID                NUMBER DEFAULT NULL
 ,p_OLD_SP_DUE_DATE            DATE
 ,p_ORDER_ID               IN  NUMBER
 ,p_LINEITEM_ID            IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID   IN  NUMBER
 ,p_FA_INSTANCE_ID         IN  NUMBER
 ,x_ERROR_CODE             OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 );

-- Update the Status and Status Change
-- cause for one or more Porting Records
-- Description: Procedure to update the status of
-- the Porting Order Records to the new status
-- for the TN range, with the current status.
--
-- The SVs to update are found by getting the TN
-- records in the phase mapping to the current status
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_STATUS_TYPES_B, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_SV_STATUS
 (p_STARTING_NUMBER            VARCHAR2
 ,p_ENDING_NUMBER              VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE       VARCHAR2
 ,p_LOCAL_SP_ID                NUMBER DEFAULT NULL
 ,p_NEW_STATUS_TYPE_CODE       VARCHAR2
 ,p_STATUS_CHANGE_CAUSE_CODE   VARCHAR2
 ,p_ORDER_ID               IN  NUMBER
 ,p_LINEITEM_ID            IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID   IN  NUMBER
 ,p_FA_INSTANCE_ID         IN  NUMBER
 ,x_ERROR_CODE             OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 );

-- Update the status of the Porting Order Records to the new status
-- for the given PORTING_ID (a.k.a OBJECT_REFERENCE).
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
--
PROCEDURE SOA_UPDATE_SV_STATUS
 (p_PORTING_ID                 VARCHAR2
 ,p_LOCAL_SP_ID                NUMBER DEFAULT NULL
 ,p_NEW_STATUS_TYPE_CODE       VARCHAR2
 ,p_STATUS_CHANGE_CAUSE_CODE   VARCHAR2
 ,p_ORDER_ID               IN  NUMBER
 ,p_LINEITEM_ID            IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID   IN  NUMBER
 ,p_FA_INSTANCE_ID         IN  NUMBER
 ,x_ERROR_CODE             OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 );

-- Insert  rows in the table XNP_SV_SOA to record porting order
-- for each TN on the range.
-- The porting information, customer information and network
-- information including the routing number is inserted
--
-- Default: OLD_SP_DUE_DATE is set same as NEW_SP_DUE_DATE
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_CREATE_REC_PORT_ORDER
 (p_PORTING_ID                  VARCHAR2
 ,p_STARTING_NUMBER             NUMBER
 ,p_ENDING_NUMBER               NUMBER
 ,p_SUBSCRIPTION_TYPE           VARCHAR2
 ,p_DONOR_SP_ID                 NUMBER
 ,p_RECIPIENT_SP_ID             NUMBER
 ,p_ROUTING_NUMBER              VARCHAR2
 ,p_NEW_SP_DUE_DATE             DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE      DATE
 ,p_CUSTOMER_ID                 VARCHAR2
 ,p_CUSTOMER_NAME               VARCHAR2
 ,p_CUSTOMER_TYPE               VARCHAR2
 ,p_ADDRESS_LINE1               VARCHAR2
 ,p_ADDRESS_LINE2               VARCHAR2
 ,p_CITY                        VARCHAR2
 ,p_PHONE                       VARCHAR2
 ,p_FAX                         VARCHAR2
 ,p_EMAIL                       VARCHAR2
 ,p_PAGER                       VARCHAR2
 ,p_PAGER_PIN                   VARCHAR2
 ,p_INTERNET_ADDRESS            VARCHAR2
 ,p_ZIP_CODE                    VARCHAR2
 ,p_COUNTRY                     VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG   VARCHAR2
 ,p_CONTACT_NAME                VARCHAR2
 ,p_RETAIN_TN_FLAG              VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG        VARCHAR2
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE VARCHAR2
 ,p_ACTIVATION_DUE_DATE         DATE
 ,p_ORDER_PRIORITY              VARCHAR2
 ,p_SUBSEQUENT_PORT_FLAG        VARCHAR2
 ,p_COMMENTS                    VARCHAR2
 ,p_NOTES                       VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Inserts row in the table XNP_SV_SOA to record porting order
-- for each TN on the range.
-- The porting information, customer information and network
-- information without the routing number is inserted
--
-- Default: OLD_SP_DUE_DATE is set same as NEW_SP_DUE_DATE
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
PROCEDURE SOA_CREATE_DON_PORT_ORDER
 (p_PORTING_ID                  VARCHAR2
 ,p_STARTING_NUMBER             NUMBER
 ,p_ENDING_NUMBER               NUMBER
 ,p_SUBSCRIPTION_TYPE           VARCHAR2
 ,p_DONOR_SP_ID                 NUMBER
 ,p_RECIPIENT_SP_ID             NUMBER
 ,p_ROUTING_NUMBER              VARCHAR2
 ,p_NEW_SP_DUE_DATE             DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE      DATE
 ,p_CUSTOMER_ID                 VARCHAR2
 ,p_CUSTOMER_NAME               VARCHAR2
 ,p_CUSTOMER_TYPE               VARCHAR2
 ,p_ADDRESS_LINE1               VARCHAR2
 ,p_ADDRESS_LINE2               VARCHAR2
 ,p_CITY                        VARCHAR2
 ,p_PHONE                       VARCHAR2
 ,p_FAX                         VARCHAR2
 ,p_EMAIL                       VARCHAR2
 ,p_PAGER                       VARCHAR2
 ,p_PAGER_PIN                   VARCHAR2
 ,p_INTERNET_ADDRESS            VARCHAR2
 ,p_ZIP_CODE                    VARCHAR2
 ,p_COUNTRY                     VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG   VARCHAR2
 ,p_CONTACT_NAME                VARCHAR2
 ,p_RETAIN_TN_FLAG              VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG        VARCHAR2
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE VARCHAR2
 ,p_ACTIVATION_DUE_DATE         DATE
 ,p_ORDER_PRIORITY              VARCHAR2
 ,p_SUBSEQUENT_PORT_FLAG        VARCHAR2
 ,p_COMMENTS                    VARCHAR2
 ,p_NOTES                       VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Inserts row in the table XNP_SV_SOA to record porting order
-- for each TN on the range.
-- The porting information, customer information and network
-- information with the routing number is inserted
--
-- Default: OLD_SP_DUE_DATE is set same as NEW_SP_DUE_DATE
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_CREATE_NRC_PORT_ORDER
 (p_PORTING_ID                  VARCHAR2
 ,p_STARTING_NUMBER             NUMBER
 ,p_ENDING_NUMBER               NUMBER
 ,p_SUBSCRIPTION_TYPE           VARCHAR2
 ,p_DONOR_SP_ID                 NUMBER
 ,p_RECIPIENT_SP_ID             NUMBER
 ,p_ROUTING_NUMBER              VARCHAR2
 ,p_NEW_SP_DUE_DATE             DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE      DATE
 ,p_CUSTOMER_ID                 VARCHAR2
 ,p_CUSTOMER_NAME               VARCHAR2
 ,p_CUSTOMER_TYPE               VARCHAR2
 ,p_ADDRESS_LINE1               VARCHAR2
 ,p_ADDRESS_LINE2               VARCHAR2
 ,p_CITY                        VARCHAR2
 ,p_PHONE                       VARCHAR2
 ,p_FAX                         VARCHAR2
 ,p_EMAIL                       VARCHAR2
 ,p_PAGER                       VARCHAR2
 ,p_PAGER_PIN                   VARCHAR2
 ,p_INTERNET_ADDRESS            VARCHAR2
 ,p_ZIP_CODE                    VARCHAR2
 ,p_COUNTRY                     VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG   VARCHAR2
 ,p_CONTACT_NAME                VARCHAR2
 ,p_RETAIN_TN_FLAG              VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG        VARCHAR2
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE VARCHAR2
 ,p_ACTIVATION_DUE_DATE         DATE
 ,p_ORDER_PRIORITY              VARCHAR2
 ,p_SUBSEQUENT_PORT_FLAG        VARCHAR2
 ,p_COMMENTS                    VARCHAR2
 ,p_NOTES                       VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,p_VALIDATION_FLAG         IN  VARCHAR2
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Donor's XNP_STANDARD.SOA_CHECK_NOTIFY_DIR_SVS
--
-- Checks with the table XNP_SV_SOA for notification to the directory SVs
-- for the given porting ID (object reference)
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA
-- @return 'Y' if need to notify

PROCEDURE SOA_CHECK_NOTIFY_DIR_SVS
 (p_PORTING_ID         VARCHAR2
 ,p_LOCAL_SP_ID        NUMBER DEFAULT NULL
 ,x_CHECK_STATUS   OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 );

-- Checks if the given donor SP ID is the
-- assigned SP for the given number range
--
-- TABLES: XNP_NUMBER_RANGES
--
-- @return 'Y' if TRUE

PROCEDURE SOA_CHECK_IF_INITIAL_DONOR
 (p_DONOR_SP_ID         NUMBER
 ,p_STARTING_NUMBER     VARCHAR2
 ,p_ENDING_NUMBER       VARCHAR2
 ,x_CHECK_STATUS    OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 );

-- Updates the Charging information for the port
-- for the given range and records in the given status
--
-- The SVs to update are got by getting the TN
-- records in the phase mapping to the current status
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE SOA_UPDATE_CHARGING_INFO
 (p_STARTING_NUMBER             VARCHAR2
 ,p_ENDING_NUMBER               VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE        VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_INVOICE_DUE_DATE            DATE
 ,p_CHARGING_INFO               VARCHAR2
 ,p_BILLING_ID                  NUMBER
 ,p_USER_LOCTN_VALUE            VARCHAR2
 ,p_USER_LOCTN_TYPE             VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Creates a mapping row for the SMS sv ID and FE ID
-- for the feature type. Usually called by the callback procedure
-- Called by : package XNP_FA_CB.PROVISION_FE
--
-- TABLES: XNP_SV_SMS_FE_MAPS. Accesses XNP_SV_SMS

PROCEDURE SMS_INSERT_FE_MAP
 (p_STARTING_NUMBER          NUMBER
 ,p_ENDING_NUMBER            NUMBER
 ,p_FE_ID                    NUMBER
 ,p_FEATURE_TYPE             VARCHAR2
 ,p_ORDER_ID             IN  NUMBER
 ,p_LINEITEM_ID          IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID IN  NUMBER
 ,p_FA_INSTANCE_ID       IN  NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Checks if there exists a Porting record in the given status
-- for this TN range.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE CHECK_SOA_STATUS_EXISTS
   (p_STARTING_NUMBER   VARCHAR2
   ,p_ENDING_NUMBER     VARCHAR2
   ,p_STATUS_TYPE_CODE  VARCHAR2
   ,p_LOCAL_SP_ID       NUMBER DEFAULT NULL
   ,x_CHECK_STATUS  OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE    OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
   );

-- Deletes the FE maps for the given
-- for the given feature type, number range and FE ID
--
-- Usage Notes: This procedure is invoked
-- by a callback procedure when a FA_DONE is received
-- after a de-provisioning is done.
-- The FA_DONE message is a message sent by the SFM
-- after the completion of a provisioning activity
--
-- TABLES: XNP_SV_SMS_FE_MAP, references XNP_SV_SMS

PROCEDURE SMS_DELETE_FE_MAP
 (p_STARTING_NUMBER   VARCHAR2
 ,p_ENDING_NUMBER     VARCHAR2
 ,p_FE_ID             NUMBER
 ,p_FEATURE_TYPE      VARCHAR2
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Checks if there exists a SV for this TN range
-- in the given phase with the (local) SP performing
-- the donor role
--
-- Usage Notes: This procedure is used to check if
-- there already exists a porting going on for the
-- given TN range with the current SP performing as donor
--
-- The SP ID can be got in two steps.
-- First, get the SP code from the WI parameter
-- SP_NAME or RECIPIENT_NAME, whichever is set.
-- Next, use XNP_CORE.GET_SP_ID given the SP code.
--
-- @return 'Y' or 'N'
--
-- TABLES: XNP_SV_SOA, XNP_SV_STATUS_TYPES_B

PROCEDURE CHECK_DONOR_PHASE
 (p_STARTING_NUMBER  IN VARCHAR2
 ,p_ENDING_NUMBER    IN VARCHAR2
 ,p_SP_ID            IN NUMBER
 ,p_PHASE_INDICATOR  IN VARCHAR2
 ,x_CHECK_EXISTS    OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE      OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
 );

-- Checks if there exists a SV for this TN range
-- in the given phase with the (local) SP performing
-- the recipient role
--
-- Usage Notes: This procedure is used to check if
-- there already exists a porting going on for the
-- given TN range with the current SP preforming as recipient
--
-- The SP ID can be got in two steps.
-- First, get the SP code from the WI parameter
-- SP_NAME or RECIPIENT_NAME, whichever is set
-- Next, use XNP_CORE.GET_SP_ID given the SP code
--
-- @return 'Y' or 'N'
--
-- TABLES: XNP_SV_SOA, XNP_SV_STATUS_TYPES_B

PROCEDURE CHECK_RECIPIENT_PHASE
 (p_STARTING_NUMBER IN VARCHAR2
 ,p_ENDING_NUMBER   IN VARCHAR2
 ,p_SP_ID           IN NUMBER
 ,p_PHASE_INDICATOR IN VARCHAR2
 ,x_CHECK_EXISTS   OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 );

-- Resets porting records in current phase except the one in omit status
-- to the phase mentioned in p_reset_phase_indicator.
-- The records should also be in the given range
-- and created by the 'local SP ID'
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_RESET_SV_STATUS
 (p_STARTING_NUMBER             VARCHAR2
 ,p_ENDING_NUMBER               VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_CUR_PHASE_INDICATOR         VARCHAR2
 ,p_RESET_PHASE_INDICATOR       VARCHAR2
 ,p_OMIT_STATUS                 VARCHAR2
 ,p_STATUS_CHANGE_CAUSE_CODE    VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Deletes the number which was provisioned
-- provisioned numbers for all SVs belonging to the
-- given number range.
-- The corresponding records from order mappings table
-- are also deleted.
--
-- Usage Notes: Called during the deprovisioning
-- of a TN range by the callback procedure for a
-- Deprovision FA_DONE
-- The FA_DONE message is a message sent by the SFM
-- after the completion of a provisioning activity
--
-- TABLES: XNP_SV_SMS, XNP_SV_ORDER_MAPPINGS

PROCEDURE SMS_DELETE_PORTED_NUMBER
 (p_STARTING_NUMBER IN VARCHAR2
 ,p_ENDING_NUMBER   IN VARCHAR2
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 );

-- Updates the status of the provisioning FE map
-- with the given status for the given FE
--
-- Usage Notes: Called During the provisioning
-- of a TN range by the callback procedure for
-- FA_DONE with a provisioning response of ERROR, SUCCESS or ABORTED
--
-- The FA_DONE message is a message sent by the SFM
-- after the completion of a provisioning activity
--
-- TABLES: XNP_SV_SMS_FE_MAPS, XNP_SV_SMS

PROCEDURE SMS_UPDATE_FE_MAP_STATUS
 (p_STARTING_NUMBER             VARCHAR2
 ,p_ENDING_NUMBER               VARCHAR2
 ,p_FE_ID                       NUMBER
 ,p_FEATURE_TYPE                VARCHAR2
 ,p_PROV_STATUS                 VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE             OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE          OUT NOCOPY VARCHAR2
 );

-- Gets the NRC SP_ID for the given number range
-- It first recursively gets the root geo area ID for this
-- number range and checks the SPs covering it from xnp_service_areas
-- and gets ID of the NRC SP amoung them.
--
-- TABLES: XNP_SERVICE_PROVIDERS, XNP_SERVICE_AREAS,
-- XNP_GEO_HIERARCHY, XNP_NUMBER_RANGES

PROCEDURE GET_NRC_ID
 (p_STARTING_NUMBER IN VARCHAR2
 ,p_ENDING_NUMBER   IN VARCHAR2
 ,x_NRC_ID         OUT NOCOPY NUMBER
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 );

-- Gets the routing number ID for the given number ID if active
--
-- TABLE: XNP_ROUTING_NUMBERS

PROCEDURE GET_ROUTING_NUMBER_ID
 (p_ROUTING_NUMBER     IN VARCHAR2
 ,x_ROUTING_NUMBER_ID OUT NOCOPY NUMBER
 ,x_ERROR_CODE        OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE     OUT NOCOPY VARCHAR2
 );

-- Return the SP ID for the given SP code if SP is active
--
-- TABLE: XNP_SERVICE_PROVIDERS

PROCEDURE GET_SP_ID
 (p_SP_NAME        IN VARCHAR2
 ,x_SP_ID         OUT NOCOPY NUMBER
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Returns the Assigned SP ID
-- corresponding to the given number range if the status is active
--
-- TABLE: XNP_NUMBER_RANGES

PROCEDURE GET_ASSIGNED_SP_ID
 (p_STARTING_NUMBER IN VARCHAR2
 ,p_ENDING_NUMBER   IN VARCHAR2
 ,x_ASSIGNED_SP_ID OUT NOCOPY NUMBER
 ,x_ERROR_CODE     OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
 );

-- Returns the SP NAME
-- corresponding to the given SP ID
--
-- TABLE: XNP_SERVICE_PROVIDERS

PROCEDURE GET_SP_NAME
 (p_SP_ID          IN NUMBER
 ,x_SP_NAME       OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Updates the porting records for each number
-- in the TN range record corresponding to the given porting ID
-- (a.k.a object_reference)
--
-- The porting information, customer information and network
-- information including the routing number is updated
--
-- Usage Notes: Usage of parameter p_RECIPIENT_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
--
-- Comments: Use UPDATE_CUSTOMER_INFO, UPDATE_NOTES_INFO
-- and UPDATE_NETWORK_INFO instead

PROCEDURE SOA_UPDATE_REC_PORT_ORDER
 (p_PORTING_ID                  VARCHAR2
 ,p_STARTING_NUMBER             NUMBER
 ,p_ENDING_NUMBER               NUMBER
 ,p_DONOR_SP_ID                 NUMBER
 ,p_RECIPIENT_SP_ID             NUMBER DEFAULT NULL
 ,p_ROUTING_NUMBER_ID           NUMBER
 ,p_NEW_SP_DUE_DATE             DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE      DATE
 ,p_CUSTOMER_ID                 VARCHAR2
 ,p_CUSTOMER_NAME               VARCHAR2
 ,p_CUSTOMER_TYPE               VARCHAR2
 ,p_ADDRESS_LINE1               VARCHAR2
 ,p_ADDRESS_LINE2               VARCHAR2
 ,p_CITY                        VARCHAR2
 ,p_PHONE                       VARCHAR2
 ,p_FAX                         VARCHAR2
 ,p_EMAIL                       VARCHAR2
 ,p_PAGER                       VARCHAR2
 ,p_PAGER_PIN                   VARCHAR2
 ,p_INTERNET_ADDRESS            VARCHAR2
 ,p_ZIP_CODE                    VARCHAR2
 ,p_COUNTRY                     VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG   VARCHAR2
 ,p_CONTACT_NAME                VARCHAR2
 ,p_RETAIN_TN_FLAG              VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG        VARCHAR2
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE VARCHAR2
 ,p_ACTIVATION_DUE_DATE         DATE
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );


-- Updates the porting records for each number in the
-- TN range record corresponding to the given porting ID
-- (a.k.a object_reference)
--
-- The porting information, customer information and network
-- information including the routing number is updated
--
-- Usage Notes: Usage of parameter p_DONOR_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
--
-- Comments: Use UPDATE_CUSTOMER_INFO, UPDATE_NOTES_INFO
-- and UPDATE_NETWORK_INFO instead
--
PROCEDURE SOA_UPDATE_DON_PORT_ORDER
 (p_PORTING_ID                  VARCHAR2
 ,p_STARTING_NUMBER             NUMBER
 ,p_ENDING_NUMBER               NUMBER
 ,p_DONOR_SP_ID                 NUMBER DEFAULT NULL
 ,p_RECIPIENT_SP_ID             NUMBER
 ,p_OLD_SP_DUE_DATE             DATE
 ,p_OLD_SP_CUTOFF_DUE_DATE      DATE
 ,p_CUSTOMER_ID                 VARCHAR2
 ,p_CUSTOMER_NAME               VARCHAR2
 ,p_CUSTOMER_TYPE               VARCHAR2
 ,p_ADDRESS_LINE1               VARCHAR2
 ,p_ADDRESS_LINE2               VARCHAR2
 ,p_CITY                        VARCHAR2
 ,p_PHONE                       VARCHAR2
 ,p_FAX                         VARCHAR2
 ,p_EMAIL                       VARCHAR2
 ,p_PAGER                       VARCHAR2
 ,p_PAGER_PIN                   VARCHAR2
 ,p_INTERNET_ADDRESS            VARCHAR2
 ,p_ZIP_CODE                    VARCHAR2
 ,p_COUNTRY                     VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG   VARCHAR2
 ,p_CONTACT_NAME                VARCHAR2
 ,p_RETAIN_TN_FLAG              VARCHAR2
 ,p_RETAIN_DIR_INFO_FLAG        VARCHAR2
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE VARCHAR2
 ,p_ACTIVATION_DUE_DATE         DATE
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Modifies record(s)and  maintains a record of all the numbers provisioned
-- All the record correspondin to the range are modified with the new Network information
-- and Porting Time
--
-- TABLES: XNP_SV_SMS

PROCEDURE SMS_MODIFY_PORTED_NUMBER
 (p_PORTING_ID              IN  VARCHAR2
 ,p_STARTING_NUMBER         IN  NUMBER
 ,p_ENDING_NUMBER           IN  NUMBER
 ,p_ROUTING_NUMBER_ID       IN  NUMBER
 ,p_PORTING_TIME            IN  DATE
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Checks if the number range is portable.
-- Procedure checks if the PORTED_INDICATOR
-- corresponding to given TN range has the value set to
-- 'PORTED_IN_USE' or 'PORTED_UNUSED'
-- @return  'Y' if true
--
-- TABLES: XNP_NUMBER_RANGES

PROCEDURE CHECK_IF_PORTABLE_RANGE
 (p_STARTING_NUMBER   VARCHAR2
 ,p_ENDING_NUMBER     VARCHAR2
 ,x_CHECK_STATUS  OUT NOCOPY NUMBER
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

--  Updates the OLD_SP_DUE_DATE
--  for all the records with the given PORTING_ID.
--
--  Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA,XNP_SV_SOA_JN
PROCEDURE SOA_UPDATE_OLD_SP_DUE_DATE
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_OLD_SP_DUE_DATE             DATE
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Updates the NEW_SP_DUE_DATE for all records
-- with the given PORTING_ID
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA,XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_NEW_SP_DUE_DATE
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_NEW_SP_DUE_DATE             DATE
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Checks if a porting record exists
-- in the given status, where the given
-- p_DONOR_SP_ID is the donor SP ID in the
--
-- Tables: XNP_SV_SOA
--
-- Usage Notes: Can be used for validating
-- the porting request at the Donor End to
-- ensure that the requested number range is
-- in ACTIVE status (for e.g.)
-- So it is ensured that the number is
-- not already being ported to another recipient
-- @return 'Y or 'N'
--

PROCEDURE CHECK_DONOR_STATUS_EXISTS
   (p_STARTING_NUMBER     VARCHAR2
   ,p_ENDING_NUMBER       VARCHAR2
   ,p_STATUS_TYPE_CODE    VARCHAR2
   ,p_DONOR_SP_ID         NUMBER
   ,x_CHECK_STATUS    OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE      OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE   OUT NOCOPY VARCHAR2
   );

-- Checks if a porting record exists
-- in the given status, where the given
-- p_RECIPIENT_SP_ID is the Recipient SP ID in the
--
-- Tables: XNP_SV_SOA
--
-- Usage Notes: Can be used for validating
-- the Subsequent porting request at the
-- Recipient End to ensure that the requested
-- number range is in ACTIVE status (for e.g.)
-- This way it is ensured that the recipient
-- can do a subsequent port of the number
-- @return 'Y ' or 'N'
--
PROCEDURE CHECK_RECIPIENT_STATUS_EXISTS
   (p_STARTING_NUMBER    VARCHAR2
   ,p_ENDING_NUMBER      VARCHAR2
   ,p_STATUS_TYPE_CODE   VARCHAR2
   ,p_RECIPIENT_SP_ID    NUMBER
   ,x_CHECK_STATUS   OUT NOCOPY VARCHAR2
   ,x_ERROR_CODE     OUT NOCOPY NUMBER
   ,x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
   );


-- Updates the OLD_SP_CUTOFF_DUE_DATE for all records
-- with the given PORTING_ID.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA,XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_CUTOFF_DATE
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_OLD_SP_CUTOFF_DUE_DATE      DATE
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Updates the Billing and charging information
-- for this porting transaction
-- All records with the given Porting ID are
-- updated.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_CHARGING_INFO
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_INVOICE_DUE_DATE            DATE
 ,p_CHARGING_INFO               VARCHAR2
 ,p_BILLING_ID                  NUMBER
 ,p_USER_LOCTN_VALUE            VARCHAR2
 ,p_USER_LOCTN_TYPE             VARCHAR2
 ,p_PRICE_CODE                  VARCHAR2
 ,p_PRICE_PER_CALL              VARCHAR2
 ,p_PRICE_PER_MINUTE            VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Checks if there exists a Porting record
-- in the given status for this Porting ID.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE CHECK_SOA_STATUS_EXISTS
 (p_PORTING_ID           VARCHAR2
 ,p_STATUS_TYPE_CODE     VARCHAR2
 ,p_LOCAL_SP_ID          NUMBER DEFAULT NULL
 ,x_CHECK_STATUS     OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE       OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE    OUT NOCOPY VARCHAR2
 );

-- Updates OLD_SP_AUTHORIZATION_FLAG
-- in table for the rows with given porting ID.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_OLD_SP_AUTH_FLAG
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_OLD_SP_AUTHORIZATION_FLAG   VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Updates NEW_SP_AUTHORIZATION_FLAG
-- in table for the rows with given porting ID.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_NEW_SP_AUTH_FLAG
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_NEW_SP_AUTHORIZATION_FLAG   VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Identifies the Fulfillment Elements to provision number range and feature type
-- and creates a map in SMS FE map
-- table with status of 'NOT_PROVISIONED'
--
-- Usage Notes: Should be used only if provisioning
-- is done by a legacy system and not SFM.
--
-- TABLES: XNP_SV_SMS, XNP_SV_SMS_FE_MAPS
--
PROCEDURE SMS_MARK_FES_TO_PROVISION
 (p_STARTING_NUMBER          VARCHAR2
 ,p_ENDING_NUMBER            VARCHAR2
 ,p_FEATURE_TYPE             VARCHAR2
 ,p_ORDER_ID             IN  NUMBER
 ,p_LINEITEM_ID          IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID IN  NUMBER
 ,p_FA_INSTANCE_ID       IN  NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Identifies the Fulfillment Elements to deprovision number range and feature type
-- The FEs are identified from the
-- list of provisioned FEs for the given number range
-- and feature type
--
-- Usage Notes: Should be used only if deprovisioning
-- is done by a legacy system and not SFM.
--
-- TABLES: XNP_SV_SMS, XNP_SV_SMS_FE_MAPS

PROCEDURE SMS_MARK_FES_TO_DEPROVISION
 (p_STARTING_NUMBER          VARCHAR2
 ,p_ENDING_NUMBER            VARCHAR2
 ,p_FEATURE_TYPE             VARCHAR2
 ,p_DEPROVISION_STATUS       VARCHAR2
 ,p_ORDER_ID             IN  NUMBER
 ,p_LINEITEM_ID          IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID IN  NUMBER
 ,p_FA_INSTANCE_ID       IN  NUMBER
 ,x_ERROR_CODE           OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE        OUT NOCOPY VARCHAR2
 );

-- Sets the Locked flag to the given value
-- for the enties in XNP_SV_SOA with the given
-- object_reference.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
PROCEDURE SOA_SET_LOCKED_FLAG
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_LOCKED_FLAG                 VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );


-- Gets the Locked flag to the given value
-- from the entry in XNP_SV_SOA with the given
-- object_reference.
-- @return 'Y' or 'N'
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE SOA_GET_LOCKED_FLAG
 (p_porting_id        VARCHAR2
 ,p_local_sp_id       NUMBER DEFAULT NULL
 ,x_locked_flag   OUT NOCOPY VARCHAR2
 ,x_error_code    OUT NOCOPY NUMBER
 ,x_error_message OUT NOCOPY VARCHAR2
 );

-- Gets the STATUS_TYPE_CODE from XNP_SV_SOA
-- for the given PORTING_ID aka object_reference.
-- Returns: Status type code if available, NULL if error
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE SOA_GET_SV_STATUS
 (p_PORTING_ID        VARCHAR2
 ,p_LOCAL_SP_ID       NUMBER DEFAULT NULL
 ,x_SV_STATUS     OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE    OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Checks if the STATUS_TYPE_CODE from XNP_SV_SOA
-- for the given PORTING_ID aka object_reference is same as
-- p_status_type_code
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA
--
-- @return 'T' if statuses match, 'F' if they don't

PROCEDURE SOA_CHECK_SV_STATUS
 (p_PORTING_ID              VARCHAR2
 ,p_LOCAL_SP_ID             NUMBER DEFAULT NULL
 ,p_STATUS_TYPE_CODE        VARCHAR2
 ,x_STATUS_MATCHED_FLAG OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE          OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2
 );

-- Sets the Blocked flag to the given value
-- for the enties in XNP_SV_SOA with the given
-- object_reference.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
-- @return 'Y' or 'N'

PROCEDURE SOA_SET_BLOCKED_FLAG
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_BLOCKED_FLAG                VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Gets the Blocked flag to the given value
-- from the entry in XNP_SV_SOA with the given
-- object_reference.
-- @return 'Y' or 'N'
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA
-- @return 'Y' or 'N'

PROCEDURE SOA_GET_BLOCKED_FLAG
 (p_porting_id        varchar2
 ,p_local_sp_id       number DEFAULT NULL
 ,x_blocked_flag  OUT NOCOPY varchar2
 ,x_error_code    OUT NOCOPY number
 ,x_error_message OUT NOCOPY varchar2
 );

-- Gets the New SP Auth flag to the given value
-- from the entry in XNP_SV_SOA with the given
-- object_reference.
-- @return 'Y' or 'N'
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA
-- @return 'Y' or 'N'

PROCEDURE SOA_GET_NEW_SP_AUTH_FLAG
 (p_porting_id varchar2
 ,p_local_sp_id number DEFAULT NULL
 ,x_new_sp_auth_flag OUT NOCOPY varchar2
 ,x_error_code OUT NOCOPY number
 ,x_error_message OUT NOCOPY varchar2
 );

-- Gets the Old SP Auth flag to the given value
-- from the entry in XNP_SV_SOA with the given
-- object_reference.
-- @return 'Y' or 'N'
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA
-- @return 'Y' or 'N'

PROCEDURE SOA_GET_OLD_SP_AUTH_FLAG
 (p_PORTING_ID            VARCHAR2
 ,p_LOCAL_SP_ID           NUMBER DEFAULT NULL
 ,x_OLD_SP_AUTH_FLAG  OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE        OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE     OUT NOCOPY VARCHAR2
 );

-- Updates the ACTIVATION_DUE_DATE for all the records
-- with the given PORTING_ID
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN
-- @return 'Y' or 'N'

PROCEDURE SOA_UPDATE_ACTIVATION_DUE_DATE
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_ACTIVATION_DUE_DATE         DATE
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Checks if the given SP ID is the one which provisioned the entire number range
--
-- If the number range hasn't been provisioned
-- explicitly (after a porting transaction), then
-- checks if the SP is the assigned SP ID.
--
-- @return 'Y'if either is true
--
PROCEDURE CHECK_IF_SP_ASSIGNED
 (p_STARTING_NUMBER    IN VARCHAR2
 ,p_ENDING_NUMBER      IN VARCHAR2
 ,p_SP_ID              IN NUMBER
 ,x_CHECK_IF_ASSIGNED OUT NOCOPY VARCHAR2
 ,x_ERROR_CODE        OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE     OUT NOCOPY VARCHAR2
 );


-- Updates the Comments, Notes and Preorder Authorization code
-- for the given Porting id.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_NOTES_INFO
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_COMMENTS                    VARCHAR2
 ,p_NOTES                       VARCHAR2
 ,p_PREORDER_AUTHORIZATION_CODE VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Updates the Network information in XNP_SV_SOA
-- for the given Porting ID.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_NETWORK_INFO
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_ROUTING_NUMBER_ID           NUMBER
 ,p_CNAM_ADDRESS                VARCHAR2
 ,p_CNAM_SUBSYSTEM              VARCHAR2
 ,p_ISVM_ADDRESS                VARCHAR2
 ,p_ISVM_SUBSYSTEM              VARCHAR2
 ,p_LIDB_ADDRESS                VARCHAR2
 ,p_LIDB_SUBSYSTEM              VARCHAR2
 ,p_CLASS_ADDRESS               VARCHAR2
 ,p_CLASS_SUBSYSTEM             VARCHAR2
 ,p_WSMSC_ADDRESS               VARCHAR2
 ,p_WSMSC_SUBSYSTEM             VARCHAR2
 ,p_RN_ADDRESS                  VARCHAR2
 ,p_RN_SUBSYSTEM                VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Updates the customer information
-- for the given Porting ID.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_UPDATE_CUSTOMER_INFO
 (p_PORTING_ID                  VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_CUSTOMER_ID                 VARCHAR2
 ,p_CUSTOMER_NAME               VARCHAR2
 ,p_CUSTOMER_TYPE               VARCHAR2
 ,p_ADDRESS_LINE1                VARCHAR2
 ,p_ADDRESS_LINE2                VARCHAR2
 ,p_CITY                        VARCHAR2
 ,p_PHONE                       VARCHAR2
 ,p_FAX                         VARCHAR2
 ,p_EMAIL                       VARCHAR2
 ,p_PAGER                       VARCHAR2
 ,p_PAGER_PIN                   VARCHAR2
 ,p_INTERNET_ADDRESS            VARCHAR2
 ,p_ZIP_CODE                    VARCHAR2
 ,p_COUNTRY                     VARCHAR2
 ,p_CUSTOMER_CONTACT_REQ_FLAG   VARCHAR2
 ,p_CONTACT_NAME                VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Update the Porting ID
-- for one or more Porting Records and in order header
--
-- The records to update are Identified in the XNP_SV_SOA
-- using the number range and current status.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN, XDP_ORDER_HEADERS
--  Refers to XDP_FULFILLMENT_WORKLIST

PROCEDURE SOA_UPDATE_PORTING_ID
 (p_STARTING_NUMBER             VARCHAR2
 ,p_ENDING_NUMBER               VARCHAR2
 ,p_CUR_STATUS_TYPE_CODE        VARCHAR2
 ,p_LOCAL_SP_ID                 NUMBER DEFAULT NULL
 ,p_PORTING_ID                  VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE              OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE           OUT NOCOPY VARCHAR2
 );

-- Updates the PROVISIONING_DONE_DATE for the number range
-- to the SYSDATE
-- TABLES: XNP_SV_SMS

PROCEDURE SMS_UPDATE_PROV_DONE_DATE
 (p_STARTING_NUMBER             VARCHAR2
 ,p_ENDING_NUMBER               VARCHAR2
 ,p_ORDER_ID                IN  NUMBER
 ,p_LINEITEM_ID             IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID    IN  NUMBER
 ,p_FA_INSTANCE_ID          IN  NUMBER
 ,x_ERROR_CODE OUT NOCOPY              NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY           VARCHAR2
 );

-- Runtime Validation check for NP work item

PROCEDURE RUNTIME_VALIDATION
(p_ORDER_ID IN NUMBER
 ,p_LINE_ITEM_ID IN NUMBER
 ,p_WORKITEM_INSTANCE_ID IN NUMBER
 ,p_STARTING_NUMBER IN NUMBER
 ,p_ENDING_NUMBER IN NUMBER
 ,p_ROUTING_NUMBER IN VARCHAR2
 ,p_DONOR_SP_CODE IN VARCHAR2
 ,p_RECIPIENT_SP_CODE IN VARCHAR2
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Checks whether Routing Number belongs to Recipient SP

PROCEDURE CHECK_RN_FOR_RECIPIENT
 (p_RECIPIENT_SP_ID IN NUMBER
 ,p_ROUTING_NUMBER_ID IN NUMBER
 ,x_ERROR_CODE OUT NOCOPY NUMBER
 ,x_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

-- Creates Mapping record in XNP_SV_ORADER_MAPPINGS
--
Procedure CREATE_ORDER_MAPPING
( P_ORDER_ID              IN  NUMBER ,
 P_LINEITEM_ID           IN  NUMBER ,
 P_WORKITEM_INSTANCE_ID  iN  NUMBER ,
 P_FA_INSTANCE_ID        IN  NUMBER ,
 P_SV_SOA_ID             IN  NUMBER ,
 P_SV_SMS_ID             IN  NUMBER ,
 X_ERROR_CODE            OUT NOCOPY NUMBER ,
 X_ERROR_MESSAGE         OUT NOCOPY VARCHAR2
);


-- Updates the DISCONNECT_DUE_DATE for all records
-- with the given PORTING_ID
--
--
-- TABLES: XNP_SV_SOA,XNP_SV_SOA_JN

Procedure SOA_UPDATE_DISCONN_DUE_DATE
 (p_PORTING_ID                   VARCHAR2 ,
  p_DISCONNECT_DUE_DATE          DATE ,
  p_ORDER_ID                 IN  NUMBER ,
  p_LINEITEM_ID              IN  NUMBER ,
  p_WORKITEM_INSTANCE_ID     IN  NUMBER ,
  p_FA_INSTANCE_ID           IN  NUMBER ,
  x_ERROR_CODE               OUT NOCOPY NUMBER ,
  x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 );

-- Updates the EFFECTIVE_RELEASE_DUE_DATE for all records
-- with the given PORTING_ID
--
-- TABLES: XNP_SV_SOA,XNP_SV_SOA_JN
--

PROCEDURE SOA_UPDATE_EFFECT_REL_DUE_DATE
 (p_PORTING_ID                   VARCHAR2 ,
  p_EFFECTIVE_RELEASE_DUE_DATE   DATE ,
  p_ORDER_ID                 IN  NUMBER ,
  p_LINEITEM_ID              IN  NUMBER ,
  p_WORKITEM_INSTANCE_ID     IN  NUMBER ,
  p_FA_INSTANCE_ID           IN  NUMBER ,
  x_ERROR_CODE               OUT NOCOPY NUMBER ,
  x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 );

-- Updates the NUMBER_RETURNED_DUE_DATE for all records
-- with the given PORTING_ID
-- TABLES: XNP_SV_SOA,XNP_SV_SOA_JN
--

PROCEDURE SOA_UPDATE_NUM_RETURN_DUE_DATE
 (p_PORTING_ID                   VARCHAR2 ,
  p_NUMBER_RETURNED_DUE_DATE     DATE ,
  p_ORDER_ID                 IN  NUMBER ,
  p_LINEITEM_ID              IN  NUMBER ,
  p_WORKITEM_INSTANCE_ID     IN  NUMBER ,
  p_FA_INSTANCE_ID           IN  NUMBER ,
  x_ERROR_CODE               OUT NOCOPY NUMBER ,
  x_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 );


-- Sets the Concirrence flag to the given value
-- for the enties in XNP_SV_SOA with the given
-- object_reference.
--
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA, XNP_SV_SOA_JN

PROCEDURE SOA_SET_CONCURRENCE_FLAG
 (P_PORTING_ID                   VARCHAR2
 ,P_LOCAL_SP_ID                  NUMBER DEFAULT NULL
 ,P_CONCURRENCE_FLAG             VARCHAR2
 ,p_ORDER_ID                 IN  NUMBER
 ,p_LINEITEM_ID              IN  NUMBER
 ,p_WORKITEM_INSTANCE_ID     IN  NUMBER
 ,p_FA_INSTANCE_ID           IN  NUMBER
 ,X_ERROR_CODE               OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE            OUT NOCOPY VARCHAR2
 );

-- Gets the values of the Concurrence flag
-- from the entry in XNP_SV_SOA with the given
-- object_reference.
-- @return 'Y' or 'N'
-- Usage Notes: Usage of parameter p_LOCAL_SP_ID is deprecated.
--
-- TABLES: XNP_SV_SOA

PROCEDURE SOA_GET_CONCURRENCE_FLAG
 (P_PORTING_ID        VARCHAR2
 ,P_LOCAL_SP_ID       NUMBER DEFAUlT NULL
 ,X_CONCURRENCE_FLAG   OUT NOCOPY VARCHAR2
 ,X_ERROR_CODE    OUT NOCOPY NUMBER
 ,X_ERROR_MESSAGE OUT NOCOPY VARCHAR2
 );

END XNP_CORE;

 

/
