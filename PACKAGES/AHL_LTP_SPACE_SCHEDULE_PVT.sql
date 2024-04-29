--------------------------------------------------------
--  DDL for Package AHL_LTP_SPACE_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_LTP_SPACE_SCHEDULE_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVSPSS.pls 115.16 2004/01/06 00:57:34 ssurapan noship $ */
--
---------------------------------------------------------------------
-- Define Record Types for record structures needed by the APIs --
---------------------------------------------------------------------
TYPE Search_Visits_Rec_Type IS RECORD (
     ORG_NAME            VARCHAR2(240),
     ORG_ID              NUMBER,
     DEPARTMENT_NAME     VARCHAR2(80),
     DEPARTMENT_ID       NUMBER,
     DEPARTMENT_CODE     VARCHAR2(30),
     SPACE_NAME          VARCHAR2(30),
     SPACE_ID            NUMBER,
     SPACE_CATEGORY      VARCHAR2(30),
     SPACE_CATEGORY_MEAN VARCHAR2(80),
     VISIT_TYPE_CODE     VARCHAR2(30),
     VISIT_TYPE_MEAN     VARCHAR2(80),
     ITEM_ID             NUMBER      ,
     ITEM_DESCRIPTION    VARCHAR2(40),
     PLAN_ID             NUMBER,
     PLAN_NAME           VARCHAR2(30),
     DISPLAY_PERIOD_CODE VARCHAR2(30),
     DISPLAY_PERIOD_MEAN VARCHAR2(80),
     START_DATE          DATE,
     START_PERIOD        DATE,
     END_PERIOD          DATE
     );

-- Scheduled vists record
TYPE Scheduled_Visits_Rec_Type IS RECORD (
     ORG_NAME             VARCHAR2(240),
     DEPARTMENT_NAME      VARCHAR2(80),
     DEPARTMENT_ID        NUMBER,
     DEPARTMENT_CODE      VARCHAR2(30),
     SPACE_NAME           VARCHAR2(30),
     SPACE_ID             NUMBER,
     SPACE_CATEGORY       VARCHAR2(30),
     SPACE_CATEGORY_MEAN  VARCHAR2(80),
     VALUE_1              VARCHAR2(10),
     VALUE_2              VARCHAR2(10),
     VALUE_3              VARCHAR2(10),
     VALUE_4              VARCHAR2(10),
     VALUE_5              VARCHAR2(10),
     VALUE_6              VARCHAR2(10),
     VALUE_7              VARCHAR2(10),
     VALUE_8              VARCHAR2(10),
     VALUE_9              VARCHAR2(10),
     VALUE_10             VARCHAR2(10),
     VALUE_11             VARCHAR2(10),
     VALUE_12             VARCHAR2(10),
     VALUE_13             VARCHAR2(10),
     VALUE_14             VARCHAR2(10)
     );
-- Display Record
TYPE Display_Rec_Type IS RECORD (
     FIELD_1              VARCHAR2(10),
     START_PERIOD_1       DATE,
     END_PERIOD_1         DATE,
     FIELD_2              VARCHAR2(10),
     START_PERIOD_2       DATE,
     END_PERIOD_2         DATE,
     FIELD_3              VARCHAR2(10),
     START_PERIOD_3       DATE,
     END_PERIOD_3         DATE,
     FIELD_4              VARCHAR2(10),
     START_PERIOD_4       DATE,
     END_PERIOD_4         DATE,
     FIELD_5              VARCHAR2(10),
     START_PERIOD_5       DATE,
     END_PERIOD_5         DATE,
     FIELD_6              VARCHAR2(10),
     START_PERIOD_6       DATE,
     END_PERIOD_6         DATE,
     FIELD_7              VARCHAR2(10),
     START_PERIOD_7       DATE,
     END_PERIOD_7         DATE,
     FIELD_8              VARCHAR2(10),
     START_PERIOD_8       DATE,
     END_PERIOD_8         DATE,
     FIELD_9              VARCHAR2(10),
     START_PERIOD_9       DATE,
     END_PERIOD_9         DATE,
     FIELD_10             VARCHAR2(10),
     START_PERIOD_10      DATE,
     END_PERIOD_10        DATE,
     FIELD_11             VARCHAR2(10),
     START_PERIOD_11      DATE,
     END_PERIOD_11        DATE,
     FIELD_12             VARCHAR2(10),
     START_PERIOD_12      DATE,
     END_PERIOD_12        DATE,
     FIELD_13             VARCHAR2(10),
     START_PERIOD_13      DATE,
     END_PERIOD_13        DATE,
     FIELD_14             VARCHAR2(10),
     START_PERIOD_14      DATE,
     END_PERIOD_14        DATE,
     START_PERIOD         DATE,
     END_PERIOD           DATE
     );
-- Define visit end date rec
TYPE Visits_End_Date_Rec_Type IS RECORD (
     VISIT_ID          NUMBER,
     VISIT_END_DATE    DATE
     );

--Define visit detail record type
TYPE Visit_Details_Rec_Type IS RECORD (
     VISIT_NUMBER      NUMBER,
     VISIT_TYPE        VARCHAR2(80),
     VISIT_NAME        VARCHAR2(80),
     VISIT_ID          NUMBER,
     VISIT_STATUS      VARCHAR2(30),
     ITEM_DESCRIPTION  VARCHAR2(40),
     SERIAL_NUMBER     VARCHAR2(30),
     UNIT_NAME         VARCHAR2(240),
     YES_NO_TYPE       VARCHAR2(80),
	 PLAN_FLAG         VARCHAR2(1),
     START_DATE        DATE,
     END_DATE          DATE,
     DUE_BY            DATE
     );

----------------------------------------------
-- Define Table Type for records structures --
----------------------------------------------
 TYPE Search_Visits_tbl IS TABLE OF Search_Visits_Rec_Type
          INDEX BY BINARY_INTEGER;

 TYPE Scheduled_Visits_tbl IS TABLE OF Scheduled_Visits_Rec_Type
          INDEX BY BINARY_INTEGER;
 TYPE Visits_End_Date_tbl IS TABLE OF Visits_End_Date_Rec_Type
          INDEX BY BINARY_INTEGER;
 TYPE Visit_Details_tbl IS TABLE OF Visit_Details_Rec_Type
          INDEX BY BINARY_INTEGER;
-- Function to get visit duration
PROCEDURE Get_Visit_Duration
         (p_visit_id                IN  NUMBER,
          x_visit_duration          OUT NOCOPY NUMBER,
          x_return_status	    OUT NOCOPY VARCHAR2,
          x_msg_count		    OUT NOCOPY NUMBER,
          x_msg_data		    OUT NOCOPY VARCHAR2 );
-- To get visit end date
PROCEDURE Get_Visit_End_Date
         (p_visit_id                IN  NUMBER,
          x_visit_end_date          OUT NOCOPY DATE,
          x_return_status           OUT NOCOPY VARCHAR2,
          x_msg_count	            OUT NOCOPY NUMBER,
          x_msg_data	            OUT NOCOPY VARCHAR2 );
-- To get visit due by date
PROCEDURE Get_Visit_Due_by_Date(
          p_visit_id                IN   NUMBER,
          x_due_by_date             OUT NOCOPY  DATE,
          x_return_status	    OUT NOCOPY  VARCHAR2,
          x_msg_count		    OUT NOCOPY  NUMBER,
          x_msg_data		    OUT NOCOPY  VARCHAR2 );
-- To get derieve visit end date
PROCEDURE Derive_Visit_End_Date
         (p_visits_end_date_tbl      IN OUT NOCOPY visits_end_date_tbl,
          x_return_status	        OUT NOCOPY VARCHAR2,
          x_msg_count		        OUT NOCOPY NUMBER,
          x_msg_data		        OUT NOCOPY VARCHAR2 );
-- Function to get derieved end date

FUNCTION Get_Derived_end_date
         (p_visit_id   NUMBER)

RETURN DATE;

------------------------
-- Declare Procedures --
------------------------
-- Start of Comments --
--  Procedure name    : Search_Scheduled_Visits
--  Type        : Private
--  Function    : This procedure calculates number of visits scheduled at department or space level
--                based on start date, and various combinations of search criteria UOM (Days,Weeks, Months).
--                Restricted to 14 days, 14 weeks , 14 months due to technical reasons.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Search Scheduled vists Parameters :
--           p_search_visits_rec       IN  Search_visits_rec_type      Required
--           X_Scheduled_visits_tbl    OUT Scheduled_visits_tbl
--
--
PROCEDURE Search_Scheduled_Visits (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2   := FND_API.g_false,
   p_validation_level        IN      NUMBER     := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2   := 'JSP',
   p_search_visits_Rec       IN      search_visits_rec_type,
   x_scheduled_visit_tbl       OUT NOCOPY scheduled_visits_tbl,
   x_display_rec               OUT NOCOPY  display_rec_type,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
);
--  Procedure name    : Get_Visit_Details
--  Type        : Private
--  Function    : This procedure shows all the visits scheduled at department or space level
--                based on start date, and various combinations of search criteria UOM (Days,Weeks, Months).
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Search Scheduled vists Parameters :
--           p_search_visits_rec       IN  Search_visits_rec_type      Required
--           X_Visit_details_tbl      OUT visit_details_tbl
--
--
--
PROCEDURE Get_Visit_Details (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2   := FND_API.g_false,
   p_validation_level        IN      NUMBER     := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2   := 'JSP',
   p_search_visits_Rec       IN      search_visits_rec_type,
   x_visit_details_tbl       OUT NOCOPY visit_details_tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
);

--
END AHL_LTP_SPACE_SCHEDULE_PVT;

 

/
