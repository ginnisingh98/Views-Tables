--------------------------------------------------------
--  DDL for Package FND_OBJECT_TABLESPACES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OBJECT_TABLESPACES_PUB" AUTHID CURRENT_USER AS
/* $Header: fndpobjs.pls 120.1 2005/07/02 03:35:51 appldev noship $ */
/*#
 * This package contains procedures for registering or customizing object
 * classifications. It is relevant only for objects that require explicit
 * tablespace classification. All necessary validations are performed before
 * propagating changes to FND_OBJECT_TABLESPACES.
 *
 * @rep:scope public
 * @rep:product FND
 * @rep:displayname Customize Object Classification
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY FND_OBJECT_CLASSIFICATION
 */

/*#
 * Use this API to create rows in the FND_OBJECT_TABLESPACES table.
 *
 * @param P_Api_Version_Number API version number.
 * @param P_Init_Msg_List Set to TRUE to initialize message list.
 * @param P_Commit Should we commit at the end?
 * @param P_application_short_name Application short name.
 * @param P_object_name Object name.
 * @param P_tablespace_type New tablespace type.
 * @param P_object_type Object type.
 * @param X_Return_Status Return status.
 * @param X_Msg_Count Number of message returned.
 * @param X_Msg_Data Message data returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Object Tablespaces Classification
 */

PROCEDURE CREATE_OBJECT_TABLESPACES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_application_short_name     in   varchar2,
    P_object_name                in   varchar2,
    P_tablespace_type            in   varchar2,
    P_object_type                in   varchar2 := 'TABLE',
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2);

/*#
 * Use this API to update rows in the FND_OBJECT_TABLESPACES table.
 *
 * @param P_Api_Version_Number API version number.
 * @param P_Init_Msg_List Set to TRUE to initialize message list.
 * @param P_Commit Should we commit at the end?
 * @param P_application_short_name Application short name.
 * @param P_object_name Object name.
 * @param P_tablespace_type New tablespace type.
 * @param P_object_type Object type.
 * @param X_Return_Status Return status.
 * @param X_Msg_Count Number of the messages returned.
 * @param X_Msg_Data Message data returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Object Tablespaces Classification
 */
PROCEDURE UPDATE_OBJECT_TABLESPACES(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_application_short_name     in   varchar2,
    P_object_name                in   varchar2,
    P_tablespace_type            in   varchar2,
    P_object_type                in   varchar2 := 'TABLE',
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2);


/*#
 * This API validates changes before the changes are propagated to the
 * FND_OBJECT_TABLESPACES table.
 *
 * @param P_Init_Msg_List Set to TRUE to initialize message list.
 * @param P_Validation_mode Can be either AS_UTILITY_PVT.G_CREATE or AS_UTILITY_PVT.G_UPDATE.
 * @param P_application_short_name application short name.
 * @param P_object_name Object name.
 * @param P_tablespace_type New tablespace type.
 * @param P_object_type Object type.
 * @param x_application_id Application id returned.
 * @param x_oracle_username Oracle username returned.
 * @param X_Return_Status Return status.
 * @param X_Msg_Count Number of message returned.
 * @param X_Msg_Data Message data returned.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Validate Object Tablespace Classification
 *
 */

PROCEDURE VALIDATE_OBJECT_TABLESPACES (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_application_short_name     in   varchar2,
    P_object_name                in   varchar2,
    P_tablespace_type            in   varchar2,
    P_object_type                in   varchar2,
    x_application_id             OUT  NOCOPY NUMBER,
    x_oracle_username            OUT  NOCOPY VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2);

END FND_OBJECT_TABLESPACES_PUB;

 

/
