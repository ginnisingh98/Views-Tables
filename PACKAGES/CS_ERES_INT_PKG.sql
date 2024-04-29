--------------------------------------------------------
--  DDL for Package CS_ERES_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_ERES_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: cseresps.pls 120.2 2006/03/22 14:03:05 spusegao noship $ */

--  Procedure Start Approval Process
------------------------------------
-- Description :
--      Start Approval Process procedure will be called from Update Service Request
--      and Update Status APIs to initiate the service request approval process if a
--      service request is being updated to a status that has an intermediate status defined.
--
-- Parameters
-- 1. P_Incident_ID      - Service Request Identifier to fetch the SR details that are required
--                         to generate the XML document essential for SR approval process.
-- 2. P_Incident_type_id - Service Request Type Identifier to check if the service request
--                    requires a detailed E-record to be generated.
-- 3. X_Approval_Status  - An OUT parameter that conveys the approval status of the process.
--      Possible Values
--           a. NOACTION - Indicating that the service request does not require an approval and
--                         the service request can be updated to the user request target status.
--           b. PENDING  - Indicating that the service request requires an approval and should
--                         be updated to the intermediate status.
--           c. ERROR    - Indicating that the SR Approval process is failed. The service request
--                         should be updated to the initial status.
--
-- 4. X_Return_status    - Standard API return status.
-- 5. X_Msg_count        - Standard API parameter. Count of error or warning messages.
-- 6. X_Msg_data         -  Standard API parameter. Concatenated string of error or warning messages.
--
PROCEDURE Start_Approval_Process
 ( P_Incident_id              IN        NUMBER,
   P_Incident_type_id         IN        NUMBER,
   P_Incident_Status_Id       IN        NUMBER,
   P_QA_Collection_Id         IN        NUMBER,
   X_Approval_status         OUT NOCOPY VARCHAR2,
   X_Return_status           OUT NOCOPY VARCHAR2,
   X_Msg_count               OUT NOCOPY NUMBER,
   X_Msg_data                OUT NOCOPY VARCHAR2 );


--  Function Generate XML Document
------------------------------------
-- Description :
--     Generate XML Document Procedure will be called by an ERES APIs to create an XML document for
--     a service request if there exist an AME rule that requires the approval process to be singed
--     and approved.

--
-- Parameters
-- 1. P_Incident_ID       - Service Request Identifier to fetch the SR details that are required
--                          to generate the XML document essential for SR approval process.
-- 2. P_Detailed_XML_Reqd - An Indicator whether to generate a detailed XML document or a lighter version
--                          XML document.
-- 3. X_Return_status     - Standard API return status.
-- 4. X_Msg_count         - Standard API parameter. Count of error or warning messages.
-- 5. X_Msg_data          - Standard API parameter. Concatenated string of error or warning messages.
--

FUNCTION Generate_XML_Document
 ( P_Incident_Id	      IN	NUMBER,
   P_Detailed_xml_reqd	  IN	VARCHAR2 ) RETURN CLOB;


--  Procedure Post Approval Process
------------------------------------
-- Description :
--
-- Parameters
-- 1. P_Incident_Id            -  Service Request Identifier to update service request doing post approval process.
-- 2. P_Intermediate_Status_Id - Intermediate Status identifier to derive the target status of the service request.
-- 3. X_Return_status          - Standard API return status.
-- 4. X_Msg_count              - Standard API parameter. Count of error or warning messages.
-- 5. X_Msg_data               -  Standard API parameter. Concatenated string of error or warning messages.
--
PROCEDURE Post_Approval_Process
 ( P_Incident_id              IN        NUMBER,
   P_Intermediate_Status_Id   IN        NUMBER ) ;
/*
PROCEDURE Post_Approval_Proccess
 ( P_Incident_id              IN        NUMBER,
   P_Intermediate_Status_Id   IN        NUMBER,
   X_Return_status           OUT NOCOPY VARCHAR2,
   X_Msg_count               OUT NOCOPY NUMBER,
   X_Msg_data                OUT NOCOPY NUMBER) ;
*/

--  Procedure Get Target SR Status
------------------------------------
-- Description :
--
-- Parameters
--
-- 4. X_Return_status - Standard API return status.
-- 5. X_Msg_count     - Standard API parameter. Count of error or warning messages.
-- 6. X_Msg_data      -  Standard API parameter. Concatenated string of error or warning messages.
--

PROCEDURE Get_Target_SR_Status
 ( P_Incident_Id              IN        NUMBER,
   P_Intermediate_Status_Id   IN        NUMBER,
   P_Action                   IN        VARCHAR2,
   X_Target_Status_Id        OUT NOCOPY NUMBER,
   X_Return_Status           OUT NOCOPY VARCHAR2,
   X_Msg_count               OUT NOCOPY NUMBER,
   X_Msg_data                OUT NOCOPY NUMBER) ;

-- Following functions are internally used by the Generate_XML_Document while generating the
-- XML Document.
---------------------------------------------------------------------------------------------

function Get_Related_Objs (x_incident_id number) return cs_sr_related_OBJ_list_t;

function Get_Related_SRs (x_incident_id number) return cs_sr_related_SR_list_t;

function Get_SR_Notes (x_incident_id number,
                                         l_source_timezone_id number,
                                         l_desc_timezone_id number,
                                         l_date_format varchar2) return cs_sr_note_list_t;

function Get_SR_Tasks (x_incident_id number,
                                         l_source_timezone_id number,
                                         l_desc_timezone_id number,
                                         l_date_format varchar2) return cs_sr_task_list_t;

END CS_ERES_INT_PKG;

 

/
