--------------------------------------------------------
--  DDL for Package CSC_SERVICE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_SERVICE_REQUEST_PVT" AUTHID CURRENT_USER AS
/* $Header: cscvcsrs.pls 115.3 2002/12/04 16:24:11 bhroy noship $ */

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:SR_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    customer_id --> object_id in contact center
--    customer_type
--    serial_number
--    type_id
--    summary
--    severity_id
--    urgency_id
--    note_type
--    note
--    problem_code   --> not required?
--	 contact_id	 --> subject_id from contact center
--    contact_point_id
--    contact_primary_flag
--    contact_point_type
--    contact_type	 --> party_type

/****
TYPE SR_Rec_Type IS RECORD(
       CUSTOMER_ID             NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
       CUSTOMER_TYPE         	 VARCHAR2(30) 	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
       TYPE_ID             	 NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
       SUMMARY         		 VARCHAR2(80) 	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
       SEVERITY_ID             NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
	  URGENCY_ID              NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
       NOTE_TYPE         	 VARCHAR2(240) := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
       NOTE         		 VARCHAR2(2000):= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
       CONTACT_ID              NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
       CONTACT_POINT_ID        NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
       PRIMARY_FLAG         	 VARCHAR2(1) 	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
       CONTACT_POINT_TYPE      VARCHAR2(30) 	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
       CONTACT_TYPE         	 VARCHAR2(30) 	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR
	);
G_MISS_SR_REC          SR_Rec_Type;

***/

-- ------------------------------------------------------------------
-- Create_Service_Request
-- -----------------------------------------------------------------
-- Start Of Comments

-- API name:   Create_Service_Request
-- Version :   Initial version	1.0
-- Type	 : 	Private
-- Function:   Calls the sr API to create a service request.
-- Pre-reqs:   None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version   IN NUMBER	 Required
-- p_init_msg_list IN VARCHAR2 Optional. Default = CSC_CORE_UTILS_PVT.G_FALSE
-- p_commit        IN VARCHAR2 Optional Default = CSC_CORE_UTILS_PVT.G_FALSE

-- Explanation of other in parameters ??
-- Standard OUT NOCOPY Parameters:

-- x_return_status		OUT NOCOPY	VARCHAR2(1)
-- x_msg_count			OUT NOCOPY	NUMBER
-- x_msg_data			OUT NOCOPY	VARCHAR2(2000)
-- End Of Comments
-- -----------------------------------------------------------------

FUNCTION Create_Service_Request(
    p_api_version_number   IN  NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_string           OUT NOCOPY VARCHAR2,
    CUSTOMER_ID            IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    CUST_ACCOUNT_ID        IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    CUSTOMER_TYPE          IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    SERIAL_NUMBER          IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    TYPE_ID                IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    SUMMARY         	  IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    SEVERITY_ID            IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    URGENCY_ID             IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    NOTE_TYPE         	  IN  VARCHAR2      := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    NOTE         		  IN  VARCHAR2      := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    CONTACT_ID             IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    CONTACT_POINT_ID       IN  NUMBER 		:= CSC_CORE_UTILS_PVT.G_MISS_NUM,
    PRIMARY_FLAG           IN  VARCHAR2     := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    CONTACT_POINT_TYPE     IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    CONTACT_TYPE           IN  VARCHAR2     	:= CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    x_service_request_number out NOCOPY VARCHAR2
    ) return varchar2;

END CSC_Service_Request_Pvt;

 

/
