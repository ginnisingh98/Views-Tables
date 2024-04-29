--------------------------------------------------------
--  DDL for Package PA_CI_NUMBER_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_NUMBER_CLIENT_EXTN" AUTHID CURRENT_USER as
/* $Header: PACINRXS.pls 120.4 2006/07/05 09:17:28 vgottimu noship $ */
/*#
 * This extension enables you to create logic for numbering issues and change documents when automatic numbering is enabled
 * for a control item type.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Control Item Document Numbering Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure enables you to define numbering logic. When automatic numbering is enabled for a control item type, Oracle Projects calls
 * this procedure each time a number is assigned to an issue or a change document.
 * @param p_object1_type The business object type. For Oracle Projects, the value must be PA_PROJECTS.
 * @param p_object1_pk1_value  The project identifier
 * @param p_object2_type The class code of the control item type
 * @param p_object2_pk1_value The identifier of the control item type
 * @param p_next_number The generated control item number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status  API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count  API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data  API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Next Number
 * @rep:compatibility S
*/
procedure GET_NEXT_NUMBER (
         p_object1_type         IN  VARCHAR2   := FND_API.g_miss_char
        ,p_object1_pk1_value    IN  NUMBER     := FND_API.g_miss_num
        ,p_object2_type         IN  VARCHAR2   := FND_API.g_miss_char
        ,p_object2_pk1_value    IN  NUMBER     := FND_API.g_miss_num
        ,p_next_number          IN  OUT NOCOPY VARCHAR2
        ,x_return_status        OUT NOCOPY VARCHAR2
        ,x_msg_count            OUT NOCOPY NUMBER
        ,x_msg_data             OUT NOCOPY VARCHAR2);


end;


 

/
