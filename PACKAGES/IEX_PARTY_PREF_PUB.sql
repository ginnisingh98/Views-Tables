--------------------------------------------------------
--  DDL for Package IEX_PARTY_PREF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_PARTY_PREF_PUB" AUTHID CURRENT_USER AS
/* $Header: iexphpps.pls 120.0.12010000.9 2009/07/31 15:32:33 ehuh ship $ */
/*#
   Store Collection level into hz_party_preferences Table
 * @rep:scope public
 * @rep:product IEX
 * @rep:lifecycle active
 * @rep:displayname IEX Store Collection level API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IEX_PARTY_PREF
 */


type level_rec_type is RECORD(party_id number,ObjectCode varchar2(240));
type level_tbl_type is TABLE of level_rec_type index by binary_integer;

type ulevel_rec is RECORD(party_id number,ObjectCode varchar2(240),version number);
type ulevel_tbl is TABLE of ulevel_rec index by binary_integer;

/*#
 * Creates/Updates collections level in hz_party_preferences table.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag('Y'/'N')
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param x_insert_count  Returns created rows count
 * @param x_update_count  Returns Updated rows count
 * @param p_level_tbl     Input Table (party_id number, ObjectCode varchar2 'PARTY'/'ACCOUNT'/'BILLTO')
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  assign collections level
 * @rep:compatibility S
 * @rep:businessevent Collection
 */

PROCEDURE assign_collection_level
(
    P_Api_Version_Number         IN   NUMBER DEFAULT 1.0,
    P_Init_Msg_List              IN   VARCHAR2 DEFAULT NULL,
    P_Commit                     IN   VARCHAR2 DEFAULT NULL,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    X_Insert_Count               OUT NOCOPY  NUMBER,
    X_Update_Count               OUT NOCOPY  NUMBER,
    p_level_tbl                  IN  level_tbl_type);


END IEX_PARTY_PREF_PUB;


/
