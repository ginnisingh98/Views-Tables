--------------------------------------------------------
--  DDL for Package AMS_LIST_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_MAINT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvlmgs.pls 115.23 2002/11/14 19:27:25 jieli ship $ */


--
-- choang - 04-Apr-2000
-- bug 1259226 - can't compile package body.
TYPE ListEntryType_Rec_Type IS RECORD (
   list_entry_id                      NUMBER,
   list_header_id                     NUMBER,
   source_code                        VARCHAR2(30),
   arc_list_used_by_source            VARCHAR2(30),
   source_code_for_id                 NUMBER(30),
   pin_code                           VARCHAR2(30),
   list_entry_source_system_id        NUMBER(30),
   list_entry_source_system_type      VARCHAR2(30),
   view_application_id                NUMBER,
   cell_code                          VARCHAR2(30),
   campaign_id                        NUMBER,
   channel_schedule_id                NUMBER,
   event_offer_id                     NUMBER,
   suffix                             VARCHAR2(20),
   first_name                         VARCHAR2(150),
   last_name                          VARCHAR2(150),
   customer_name                      VARCHAR2(150),
   title                              VARCHAR2(150),
   address_line1                      VARCHAR2(150),
   address_line2                      VARCHAR2(150),
   city                               VARCHAR2(50),
   state                              VARCHAR2(50),
   zipcode                            VARCHAR2(50),
   country                            VARCHAR2(100),
   fax                                VARCHAR2(50),
   phone                              VARCHAR2(50),
   email_address                      VARCHAR2(100)

);

---------------------------------------------------------------------
-- Procedure
--   Create_Source_View
--
-- PURPOSE
--  1. Creates a view based on the mapping information specified in the AMS_LIST_SRC_TYPES
--     and AMS_LIST_SRC_FIELDS tables.

--  2. The view will select only the columns which have been mapped to in the FIELD_TABLE_NAME
--     column in the AMS_LIST_SRC_FIELDS table.

--  3. Each column in the view will be given an alias which corresponds to
--     the SOURCE_COLUMN_MEANING column in the AMS_LIST_SRC_FIELDS table.

-- PARAMETERS
--  1. p_list_source_type specifies the type of mapping which the view is being created for.
--     IMPORT or TARGET.

--  2. p_source_type_code specifies the mapping code which the view is being created for.
--

-- NOTES
--
---------------------------------------------------------------------
Procedure Create_Source_View(p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
                             p_commit            IN  VARCHAR2  := FND_API.g_false,
                             p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,

                             p_user_id           IN  NUMBER,
                             p_resp_id           IN  NUMBER,
                             p_resp_appl_id      IN  NUMBER,

                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,

                             p_list_source_type VARCHAR2,
                             p_source_type_code VARCHAR2);

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Copy_List
--
-- PURPOSE
--   Copies a List Header and optionally its actions or existing entries.

-- PARAMETERS
--   P_List_Id           The List_Header_Id of The List to be Copied.
--   P_List_Used_By_ID   The Foreign Key to the Entity using the list.
--   p_arc_list_used_by  The Qualifier code which identifies the type of entity which is using the list.
--   P_Copy_Option       'A' Create New List Header and Copy Actions.
--                       'E' Create New List Header and create one INCLUDE action of the copied list name.
--   P_Repeat_Option     If this is a repeating list then this option specifies how to copy the list.
--                       'R' create a new list with a generation type of 'REPEAT'.
--                       'I' create a new list with a generation type of 'INCREMENTAL', additionally
--                        create 'EXCLUDE' actions for all previously generated children lists of the
--                        parent list.

-- NOTES
-- created tdonohoe 10/27/99
---------------------------------------------------------------------------------------------------------
Procedure Copy_List         (p_api_version       IN  NUMBER,
                             p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
                             p_commit            IN  VARCHAR2  := FND_API.g_false,
                             p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,



                             x_return_status     OUT NOCOPY VARCHAR2,
                             x_msg_count         OUT NOCOPY NUMBER,
                             x_msg_data          OUT NOCOPY VARCHAR2,

                             p_list_id           IN  NUMBER,
                             p_list_used_by_id   IN  number   := NULL,
                             p_arc_list_used_by  IN  VARCHAR2 := NULL,
                             p_list_type         IN  VARCHAR2 := NULL,
                             p_copy_option       IN  VARCHAR2 :='A',
                             p_repeat_option     IN  VARCHAR2 :='R',
                             x_list_id           OUT NOCOPY NUMBER,
                             x_listheader_rec    OUT NOCOPY AMS_LISTHEADER_PVT.list_header_rec_type);


----------------------------------------------------------------------------------------------------------
-- Procedure
--   Check_List_Association
-- PURPOSE
--   A List may optionally be associated with a valid marketing activity.
--   This Procedure checks that the specified activity and type exist.

-- PARAMETERS
--   P_ARC_LIST_USED_BY , valid values are CAMP,CSCH,EVEH,EVEO.
--   P_LIST_USED_BY_ID  , the foreign key to the marketing entity table.
-- NOTES
-- created tdonohoe 11/16/99
---------------------------------------------------------------------------------------------------------
Function Check_List_Association(p_arc_list_used_by varchar2,
                                p_list_used_by_id number)
Return Varchar2;



----------------------------------------------------------------------------------------------------------
-- Procedure
--   Update_List_Entry_Source_Code

-- PURPOSE
--  A list may be generated without having an association with a valid marketing activity.
--  When at a later date a list is associated then the set of list entries must be updated
--  to reflect this association.

--
-- PARAMETERS
--   P_ARC_LIST_USED_BY , valid values are CAMP,CSCH,EVEH,EVEO.
--   P_LIST_USED_BY_ID  , the foreign key to the marketing entity table.
-- NOTES
-- created tdonohoe 11/22/99
---------------------------------------------------------------------------------------------------------
--Function Update_List_Entry_Source_Code(p_list_header_id in number) Return Varchar2;


----------------------------------------------------------------------------------------------------------
-- Procedure
--   Schedule_List

-- PURPOSE
--   Called by Concurrent Manager to Schedule The AMS_LISTGENERATION_PKG.GENERATE_LIST procedure.
--
--
-- PARAMETERS

-- NOTES
-- created tdonohoe 11/23/99
---------------------------------------------------------------------------------------------------------
Procedure SCHEDULE_LIST(errbuf                                 OUT NOCOPY    varchar2,
                        retcode                                OUT NOCOPY    number,
                        p_api_version                          IN     NUMBER,
                        p_init_msg_list                        IN     VARCHAR2   := FND_API.G_TRUE,
                        p_commit                               IN     VARCHAR2   := FND_API.G_FALSE,
                        p_validation_level                     IN     NUMBER     := FND_API.G_VALID_LEVEL_FULL,
                        p_list_header_id                       IN     NUMBER,
                        p_list_used_by_id                      IN     VARCHAR2   := NULL,
                        p_arc_list_used_by                     IN     VARCHAR2   := NULL,
                        p_new_list_name                        IN     VARCHAR2   := NULL,
                        p_copy_entries                         IN     VARCHAR2   := 'Y');

----------------------------------------------------------------------------------------------------------
-- Procedure
--   Submit_List_For_Generation

-- PURPOSE
--   Submit List for Generation to Concurrent Manager at the specified_time.
--
-- PARAMETERS

-- NOTES
-- created tdonohoe 11/22/99
--  modified sugupta 04/24/2000 added timezone id
---------------------------------------------------------------------------------------------------------
Procedure  Submit_List_For_Generation(p_list_header_id   in number,
                                      p_user_id          IN NUMBER,
                                      p_resp_id          IN NUMBER,
                                      p_list_used_by_id  in number    := NULL,
                                      p_arc_list_used_by in varchar2  := NULL,
									  p_timezone_id	     in NUMBER := NULL,
                                      p_time             in DATE  := NULL,
                                      p_name             in varchar2  := NULL,
                                      p_copy_entries     in varchar2  := 'Y',
                                      x_schedule_id  OUT NOCOPY number );


----------------------------------------------------------------------------------------------------------
-- Procedure
--   Create_Discoverer_Url

-- PURPOSE
--   Creates a URL which will launch Web Discoverer.
--
-- PARAMETERS

-- NOTES
-- created tdonohoe 09-May-2000
---------------------------------------------------------------------------------------------------------
Procedure Create_Discoverer_Url(p_text              IN VARCHAR2,
                                p_application_id    IN NUMBER,
				p_responsibility_id IN NUMBER,
                                p_security_group_id IN NUMBER,
				p_function_id       IN NUMBER,
				p_target            IN VARCHAR2,
				p_session_id        IN NUMBER,
                                x_discoverer_url    OUT NOCOPY VARCHAR2
			       );


END; -- Package spec

 

/
