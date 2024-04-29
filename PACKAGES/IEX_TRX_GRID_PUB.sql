--------------------------------------------------------
--  DDL for Package IEX_TRX_GRID_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_TRX_GRID_PUB" AUTHID CURRENT_USER AS
/* $Header: iexptrcs.pls 120.0.12010000.1 2009/12/30 17:05:16 ehuh noship $ */
/*#
 * Set UNPAID_REASON_CODE to table IEX_DELINQUENCIES_ALL.
 * @rep:scope internal
 * @rep:product IEX
 * @rep:displayname Set_Unpaid_Reason
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IEX_DELINQUENCIES_ALL
 */

/*#
 * Set UNPAID_REASON_CODE to table IEX_DELINQUENCIES_ALL.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param p_validation_level Validation level
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param p_del_ids       Delinquency identifier
 * @param p_unpaid_reason Unpaid_reason_code Possible values should comes from iex_lookups_v with lookup_type 'IEX_UNPAID_REASON'.
 * @param x_rows_processed Number of rows updated
 * @rep:scope internal
 * @rep:displayname Set_Unpaid_Reason
 * @rep:lifecycle active
 * @rep:compatibility S
 */

  PROCEDURE Set_Unpaid_Reason
  (p_api_version      IN  NUMBER := 1.0,
   p_init_msg_list    IN  VARCHAR2 := 'T',
   p_commit           IN  VARCHAR2,
   p_validation_level IN  NUMBER :=100,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_del_ids          IN  VARCHAR2,
   p_unpaid_reason    IN  VARCHAR2,
   x_rows_processed   OUT NOCOPY NUMBER);

END;

/
