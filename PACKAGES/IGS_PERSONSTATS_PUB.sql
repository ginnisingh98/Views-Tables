--------------------------------------------------------
--  DDL for Package IGS_PERSONSTATS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PERSONSTATS_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSPAPSS.pls 120.0 2006/05/02 05:36:33 apadegal noship $ */

-- Start of comments
--	API name 	: REDERIVE_PERSONSTATS
--	Type		: Public.
--	Function	: To rederive the Person Statistics ( Inital and Most recent admittance terms, Catalog) for a person.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version   :
--                                     It is Required parameter. Its data type is Number
--				p_init_msg_list :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_commit        :
--				       It is an optional parameter.Default value is FND_API.G_FALSE
--				p_validation_level :
--				       It is an optional parameter.Default value is FND_API.G_VALID_LEVEL_FULL
--                              p_person_id      :
--                                     It is a Required/Optional parameter. Its data type is Number.
--                                     Maximum length is 15.Unique identifier assigned to the Applicant
--		                p_group_id :
--                                     It is a Required/Optional parameter. Its data type is Number.
--                                     maximum length is 6. Unique identifier assigned to the Person Group
--
--
--	OUT		:	x_return_status	:
--                                    It is out parameter that will contain the return status at the time of exiting the API.
--                                    and calling program can look into this variable to check whether API run was succesful or Not
--                                    It can have three values given below(with definition) :
--                                    G_RET_STS_SUCCESS			CONSTANT VARCHAR2 (1):='S';
--                                    G_RET_STS_ERROR 			CONSTANT VARCHAR2 (1):='E';
--                                    G_RET_STS_UNEXP_ERROR 		CONSTANT VARCHAR2 (1):='U';
--                                    This variable is of type varchar2, and length should be 1
--
--                                    If the API is invoked with P_GROUP_ID, then this parameter would return SUCCESS only if all
--                                    the individual return statuses are SUCCESS [ Please refer parameter X_RETURN_STATUS_TBL for more details]
--                                    If
--				x_msg_count     :
--                                    It is also a out variable which will hold total no of messages issued by API
--                                    This variable is of type number.
--				x_msg_data
--                                    if x_msg_count = 1 then this variable will hold the top message on message stack
--                                    else it will be null. Api will expect it as varchar2 type and length of 2000
--
--                              x_return_status_tbl
--                                    It is an out parameter and should be used only if the API is invoked with P_GROUP_ID as parameter
--                                    Its data type is Return_Status_Tbl_Type, which is a Table of Record type Return_Status_Rec_Type.
--
--                                    Record type Return_Status_Rec_Type has got the following fields
--
--                                       Person_id
--                                       sub_return_status	(like x_return_status)
--					 sub_msg_count	        (like x_msg_count)
--					 sub_msg_data	        (like x_msg_data)

--                                    The data type of the above fields would be same as their corresponding API parameters
--                                    The usage is also same, except that these values will be set for each of the person id in the person id group
--
--				      The counter of table x_return_status_tbl would start with 1.
--                                    This table can be looped through 1 to x_return_status_tbl.count to get result of individual person ids
--
--
--	Note:           1.  Atleast on parameter among p_person_id or p_group_id MUST BE passed
--                      2.  If both parameters (P_PERSON_ID, P_GROUP_ID) are passed,
--                           x_return_status will return
--                                2.1  G_RET_STS_UNEXP_ERROR --- if      ATLEAST one of the individual person id's sub_return_status is  G_RET_STS_UNEXP_ERROR
--                                2.2  G_RET_STS_ERROR       --- if      NONE    one of the individual person id's sub_return_status is  G_RET_STS_UNEXP_ERROR
--                                                               and     ALTEAST one of tHE individual person id's sub_return_status is  G_RET_STS_ERROR
--				  2.3  G_RET_STS_SUCCESS     --- ONLY if ALL         of the individual person id's sub_return_status are G_RET_STS_SUCCESS
--

--	Version	: Current version	1.0
--				Changed....
--			  previous version	N.A.
--			  Initial version 	1.0
--	Notes		: Please note that atleast one parameter among P_PERSON_ID and P_GROUP_ID is mandatory.
-- End of comments



TYPE Return_Status_Rec_Type IS RECORD
(	Person_id              NUMBER ,
	sub_return_status      VARCHAR2(1),
	sub_msg_count	       NUMBER,
	sub_msg_data           VARCHAR2(32767)
);

TYPE Return_Status_Tbl_Type IS TABLE OF Return_Status_Rec_Type
	INDEX BY BINARY_INTEGER;


 PROCEDURE REDERIVE_PERSON_STATS(
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
                    p_person_id            IN      NUMBER,
		    p_group_id             IN      NUMBER,
                    x_return_status_tbl	   OUT     NOCOPY Return_Status_Tbl_Type

);
 END IGS_PERSONSTATS_PUB;

 

/
