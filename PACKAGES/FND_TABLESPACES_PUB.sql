--------------------------------------------------------
--  DDL for Package FND_TABLESPACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_TABLESPACES_PUB" AUTHID CURRENT_USER AS
/* $Header: fndptbls.pls 120.1 2005/07/02 03:36:59 appldev noship $ */
/*#
 * This package contains procedures for customizing the tablespace model by
 * registering custom tablespace types that are not available by default with
 * OATM and modifying tablespace names for any default OATM tablespaces or
 * registered custom tablespaces. All necessary validation should be performed
 * before propagating changes to FND_TABLESPACES.
 *
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Customize Tablespace Model
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY FND_TABLESPACE
 */


/*#
 * Use this procedure to register any custom tablespace types that are not
 * available by default with OATM.
 *
 * @param P_Api_Version_Number API version number.
 * @param P_Init_Msg_List Set to TRUE to initialize message list.
 * @param P_Commit Should we commit at the end?
 * @param P_TABLESPACE_TYPE New tablespace type.
 * @param P_TABLESPACE New tablespace name.
 * @param X_Return_Status Return status.
 * @param X_Msg_Count Number of the messages returned.
 * @param X_Msg_Data Message data returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Custom Tablespace
 */

PROCEDURE CREATE_TABLESPACES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_TABLESPACE_TYPE            IN   VARCHAR2,
    P_TABLESPACE                 IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2);


/*#
 * Use this procedure to modify tablespace names for any default OATM
 * tablespaces or registered custom tablespaces.
 *
 * @param P_Api_Version_Number API version number.
 * @param P_Init_Msg_List Set to TRUE to initialize message list.
 * @param P_Commit Should we commit changes at the end?
 * @param P_TABLESPACE_TYPE New tablespace type .
 * @param P_TABLESPACE New tablespace name.
 * @param X_Return_Status Return status.
 * @param X_Msg_Count Number of the messages returned.
 * @param X_Msg_Data Message data returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Tablespace Name
 */
PROCEDURE UPDATE_TABLESPACES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_TABLESPACE_TYPE            IN   VARCHAR2,
    P_TABLESPACE                 IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2);

/*#
 * Use this procedure to perform all necessary validation before propagating
 * changes to FND_TABLESPACE.
 *
 * @param P_Init_Msg_List Set to TRUE to initialize message list (not used).
 * @param P_Validation_mode Validation mode. Can be either AS_UTILITY_PVT.G_CREATE or AS_UTILITY_PVT.G_UPDATE.
 * @param P_TABLESPACE_TYPE New tablespace type.
 * @param P_TABLESPACE New tablespace name.
 * @param X_Return_Status Return status.
 * @param X_Msg_Count Number of the messages returned.
 * @param X_Msg_Data Message data returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Tablespace Validation
 */
PROCEDURE VALIDATE_TABLESPACES (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_TABLESPACE_TYPE            IN   VARCHAR2,
    P_TABLESPACE                 IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2);

END FND_TABLESPACES_PUB;

 

/
