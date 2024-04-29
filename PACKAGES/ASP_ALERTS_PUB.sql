--------------------------------------------------------
--  DDL for Package ASP_ALERTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASP_ALERTS_PUB" AUTHID CURRENT_USER as
/* $Header: asppalts.pls 120.2 2005/09/13 17:20 axavier noship $ */
---------------------------------------------------------------------------
-- Package Name:   ASP_ALERTS_PUB
---------------------------------------------------------------------------
-- Description:
--      Public package for Sales Alerts Related Business logic.
--
-- Procedures:
--   (see below for specification)
--
-- History:
--   08-Aug-2005  axavier created.
---------------------------------------------------------------------------

/*-------------------------------------------------------------------------*
 |                             PUBLIC CONSTANTS
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC DATATYPES
 *-------------------------------------------------------------------------*/
  TYPE SUBSCRIBER_REC_TYPE IS RECORD
  (
    SUBSCRIPTION_ID NUMBER default null,
    SUBSCRIBER_NAME VARCHAR2(320) default null,
    DELIVERY_CHANNEL  VARCHAR2(30) default null,
    USER_ID NUMBER default null
  );
  TYPE  subscriber_tbl_type IS TABLE OF subscriber_rec_type
                                    INDEX BY BINARY_INTEGER;

/*-------------------------------------------------------------------------*
 |                             PUBLIC VARIABLES
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |                             PUBLIC ROUTINES
 *-------------------------------------------------------------------------*/

--------------------------------------------------------------------------------
--
--  Procedure: Get_Matching_Subscriptions
--   This method returns all the subscribers of a given Alert.
--
--  Arguments IN/OUT:
--   l_api_version  - 1.0
--   p_init_msg_list   - Message Stack to be initialized or not.
--   p_alert_code     - Alert code corresponding to the asp_alert_subscriptions.alert_code
--   x_subscriber_list  - table of record of subscribers.
--   x_return_status -   S Success; U Un Expected; E Error
--   x_msg_count -   Number of messages in the Message Stack.
--   x_msg_data -   First Message in the Message Stack.
--
--------------------------------------------------------------------------------

PROCEDURE Get_Matching_Subscriptions (
  p_api_version_number  IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2   DEFAULT  FND_API.G_FALSE,
  p_alert_code          IN  VARCHAR2,
  p_customer_id         IN  NUMBER,
  x_subscriber_list     OUT NOCOPY  SUBSCRIBER_TBL_TYPE,
  x_return_status       OUT NOCOPY  VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY  VARCHAR2);


END ASP_ALERTS_PUB;

 

/
