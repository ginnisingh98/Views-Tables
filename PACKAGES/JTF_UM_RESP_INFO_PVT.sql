--------------------------------------------------------
--  DDL for Package JTF_UM_RESP_INFO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_UM_RESP_INFO_PVT" AUTHID CURRENT_USER as
/*$Header: JTFVRESS.pls 115.3 2002/11/21 22:57:58 kching ship $*/


TYPE RESP_INFO_SOURCE IS RECORD
(
  RESP_ID        NUMBER                                         := FND_API.G_MISS_NUM,
  APP_ID         NUMBER                                         := FND_API.G_MISS_NUM,
  RESP_NAME      FND_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%TYPE := FND_API.G_MISS_CHAR,
  RESP_KEY      FND_RESPONSIBILITY_VL.RESPONSIBILITY_KEY%TYPE  := FND_API.G_MISS_CHAR,
  RESP_SOURCE    VARCHAR2(4000)                                 := FND_API.G_MISS_CHAR
);

TYPE RESP_INFO_TABLE_TYPE IS TABLE OF RESP_INFO_SOURCE INDEX BY BINARY_INTEGER;

/**
  * Procedure   :  GET_RESP_INFO_SOURCE
  * Type        :  Private
  * Pre_reqs    :  None
  * Description :  Returns the responsibility details and source for a user
  * Parameters  :
  * input parameters
  * @param     p_user_name
  *     description:  The user_name of a user
  *     required   :  Y
  *     validation :  Must be a valid user name
  * output parameters
  *   x_result: RESP_INFO_TABLE_TYPE
 */
procedure GET_RESP_INFO_SOURCE(
                       p_user_id      in number,
                       x_result       out NOCOPY RESP_INFO_TABLE_TYPE
                       );

end JTF_UM_RESP_INFO_PVT;

 

/
