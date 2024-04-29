--------------------------------------------------------
--  DDL for Package IEX_STRATEGY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_STRATEGY_PUB" AUTHID CURRENT_USER AS
/* $Header: iexpstps.pls 120.13.12010000.3 2008/12/22 12:59:19 schekuri ship $ */
/*#
 * Creates or closes Collections strategies.
 * @rep:scope internal
 * @rep:product IEX
 * @rep:displayname Create/Close Collections Strategy
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IEX_STRATEGY
 */

/*#
 * Creates a strategy for an object.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param p_DelinquencyID Delinquency identifier
 * @param p_ObjectType Object Type Possible values are DELINQUENT, BANKRUPTCY, WRITEOFF', REPOSSESSION, LITIGATION, BANKRUPTCY.
 * @param p_ObjectID   Object identifier. Possible values are DelinquencyID, BankRuptcyID, WriteoffID, RepossessionID, Litigation ID, Bankruptcy ID
 * @param p_Strategy_temp_id Strategy template Identifier
 * @rep:scope internal
 * @rep:displayname Create Collections Strategy
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE create_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Commit                     IN   VARCHAR2   ,
    p_validation_level           IN   NUMBER     ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number,
    p_strategy_temp_id           IN   number default 0
) ;

/*#
 * Sets strategy status to Onhold or Open.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param p_DelinquencyID Delinquency identifier
 * @param p_ObjectType Object Type Possible values are DELINQUENT, BANKRUPTCY, WRITEOFF', REPOSSESSION, LITIGATION, BANKRUPTCY.
 * @param p_ObjectID   Object identifier. Possible values are DelinquencyID, BankRuptcyID, WriteoffID, RepossessionID, Litigation ID, Bankruptcy ID
 * @param p_Status Strategy status to be set
 * @rep:scope internal
 * @rep:displayname Set Collections Strategy Status
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE set_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Commit                     IN   VARCHAR2   ,
    p_validation_level           IN   NUMBER     ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number,
    p_Status                     IN   varchar2
) ;


/*#
 * Retrieves current work item for strategy.
 * @param p_DelinquencyID Delinquency identifier
 * @param p_ObjectType Object Type Possible values are DELINQUENT, BANKRUPTCY, WRITEOFF', REPOSSESSION, LITIGATION, BANKRUPTCY.
 * @param p_ObjectID   Object identifier. Possible values are DelinquencyID, BankRuptcyID, WriteoffID, RepossessionID, Litigation ID, Bankruptcy ID
 * @param x_StrategyID Strategy IDentifier
 * @param x_StrategyName Strategy Name
 * @param x_WorkItemID Work Item IDentifier
 * @param x_WorkItemName Work Item Name
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope internal
 * @rep:displayname Get Strategy Current Work Item
 * @rep:lifecycle active
 * @rep:compatibility S
 */

PROCEDURE GetStrategyCurrentWorkItem
(
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number,
    x_StrategyID                 OUT NOCOPY  number,
    x_StrategyName               OUT NOCOPY  varchar2,
    x_WorkItemID                 OUT NOCOPY  number,
    x_WorkItemName               OUT NOCOPY  varchar2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2

) ;

/*#
 * Retrieves a Strategy Template ID.
 * @param p_stry_cnt_rec Strategy current record
 * @param x_return_status API return status
 * @param x_strategy_template_id Strategy template Identifier
 * @rep:scope internal
 * @rep:displayname Get Strategy Template ID
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE GetStrategyTempID(
		p_stry_cnt_rec in	IEX_STRATEGY_TYPE_PUB.STRY_CNT_REC_TYPE,
		x_return_status out NOCOPY varchar2,
		x_strategy_template_id out NOCOPY number);

/*#
 * Closes a strategy.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @param p_DelinquencyID Delinquency identifier
 * @param p_ObjectType Object Type Possible values are DELINQUENT, BANKRUPTCY, WRITEOFF', REPOSSESSION, LITIGATION, BANKRUPTCY.
 * @param p_ObjectID   Object identifier. Possible values are DelinquencyID, BankRuptcyID, WriteoffID, RepossessionID, Litigation ID, Bankruptcy ID
 * @rep:scope internal
 * @rep:displayname Close Collections Strategy
 * @rep:lifecycle active
 * @rep:compatibility S
 */
PROCEDURE close_strategy
(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Commit                     IN   VARCHAR2   ,
    p_validation_level           IN   NUMBER     ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2,
    p_DelinquencyID              IN   number,
    p_ObjectType                 IN   varchar2,
    p_ObjectID                   IN   number
) ;





l_MsgLevel  NUMBER;
l_DefaultTempID NUMBER;
l_DefaultStrategyLevel NUMBER;

END IEX_STRATEGY_PUB;

/
