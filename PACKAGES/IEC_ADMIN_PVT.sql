--------------------------------------------------------
--  DDL for Package IEC_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_ADMIN_PVT" AUTHID CURRENT_USER AS
/* $Header: IECADMS.pls 120.1 2005/06/16 09:10:45 appldev  $ */





TYPE TG_ENTRY_CURSOR 	is REF CURSOR;





-- ===============================================================

-- Start of Comments

-- Package name

--          IEC_ADMIN_PVT

-- Purpose

--    To provide easy to use apis for IEC Admin.

-- History

--    30-Apr-2001     msista      Created.

--    09-Jul-2001     gpagadal    Modified.

--    02-Jul-2001     gpagadal    Fields added.

--    03-Jul-2001     gpagadal    Procedure added

-- NOTE

--

-- End of Comments

-- ===============================================================



-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           Update_Camp_Schedule

--   Type

--           Private

--   Pre-Req

--

--   Parameters

--

--  IN

--

--  p_campaign_schedule_id       IN   NUMBER      Required

--  p_dialing_method             IN   VARCHAR2    Required (CTI disabled)

--  p_calendar_id                IN   NUMBER      Required

--  p_abandon_limit              IN   NUMBER      Required

--  p_user_id                    IN   NUMBER      Required

--  p_predictive_timeout         IN   NUMBER,     Required

--  p_user_status_id             IN   NUMBER,   Required



--

--  OUT

--  x_msg_data                   OUT  VARCHAR2

--  x_return_value               OUT  NUMBER 1 for success, 0 otherwise.

--

--   End of Comments

-- ===============================================================

--

PROCEDURE Update_Camp_Schedule(



    p_campaign_schedule_id   IN  NUMBER,

    p_dialing_method         IN  VARCHAR2,

    p_calendar_id            IN  NUMBER,

    p_abandon_limit          IN  NUMBER,



    p_predictive_timeout     IN  NUMBER,

    p_user_status_id         IN  NUMBER,





    p_user_id                IN  NUMBER,



    x_msg_data               OUT NOCOPY VARCHAR2,

    x_return_value           OUT NOCOPY NUMBER



    );









-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           Update_List_DialingMethod

--   Type

--           Private

--   Pre-Req

--

--   Parameters

--

--  IN

--

--  p_campaign_schedule_id       IN   NUMBER      Required

--  p_dialing_method             IN   VARCHAR2    Required (CTI disabled)

--  p_user_id                    IN   NUMBER      Required

--

--  OUT

--  x_msg_data                   OUT  VARCHAR2

--  x_return_value               OUT  NUMBER 1 for success, 0 otherwise.

--

--   End of Comments

-- ===============================================================

--

PROCEDURE Update_List_DialingMethod(



    p_campaign_schedule_id   IN  NUMBER,



    p_dialing_method         IN  VARCHAR2,



    p_user_id                IN  NUMBER,



    x_msg_data               OUT NOCOPY VARCHAR2,

    x_return_value           OUT NOCOPY NUMBER



    );



-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           Update_List_Header

--   Type

--           Private

--   Pre-Req

--

--   Parameters

--

--  IN

--

--  p_list_header_id          IN   NUMBER      Required

--  p_dialing_method          IN   VARCHAR2    Required

--  p_list_priority           IN   NUMBER      Required

--  p_recycling_alg_id        IN   NUMBER      Required

--  p_release_control_alg_id  IN   NUMBER      Required

--  p_calendar_id             IN   NUMBER      Required

--  p_release_strategy        IN   VARCHAR2    Required

--  p_quantum                 IN   NUMBER      Required

--  p_quota                   IN   NUMBER      Optional Default = null

--  p_quota_reset             IN   NUMBER      Optional Default = null

--  p_user_id                 IN   NUMBER      Required

--

--  OUT

--  x_msg_data                OUT  VARCHAR2

--  x_return_value            OUT  NUMBER 1 for success, 0 otherwise.

--

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

--

PROCEDURE Update_List_Header(

   p_list_header_id             IN   NUMBER,

   p_dialing_method             IN   VARCHAR2,

   p_list_priority              IN   NUMBER,

   p_recycling_alg_id           IN   NUMBER,

   p_release_control_alg_id     IN   NUMBER,

   p_calendar_id                IN   NUMBER,

   p_release_strategy           IN   VARCHAR2,

   p_quantum                    IN   NUMBER,

   p_quota                      IN   NUMBER       := null,

   p_quota_reset                IN   NUMBER       := null,



   p_user_id                    IN   NUMBER,



   x_msg_data                   OUT  NOCOPY VARCHAR2,

   x_return_value               OUT  NOCOPY NUMBER

    );



-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           Delete_List_Subset

--   Type

--           Private

--   Pre-Req

--

--   Parameters

--

--  IN

--  p_list_subset_id       IN   NUMBER      Required

--  p_user_id              IN   NUMBER      Required

--

--  OUT

--  x_msg_data                   OUT  VARCHAR2

--  x_return_value               OUT  NUMBER 1 for success, 0 otherwise.

--

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

--

PROCEDURE Delete_List_Subset(

    p_list_subset_id         IN  NUMBER,

    p_user_id                IN  NUMBER,

    x_msg_data               OUT NOCOPY VARCHAR2,

    x_return_value           OUT NOCOPY NUMBER

    );







-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           GET_TG_ENTRY_LIST

--

-- Used by Target Group Entry List Page to show the list

-- of entries belonging to a certain target group.

-- This procedure also gathers data for the page header and footer.

--

--   Type: Private

--

--   Parameters

--  IN

--    P_LIST_HEADER_ID		IN  NUMBER

--  , P_SEARCH_COLUMN		IN  VARCHAR2

--  , P_SEARCH_OPERATOR		IN  VARCHAR2

--  , P_SEARCH_PARAM		IN  VARCHAR2

-- 	, P_ORDER_BY			IN  NUMBER

--  , P_NEXT_ROW			IN  NUMBER

--  , P_MAX_ROWS			IN  NUMBER

--  , P_ORDER				IN  VARCHAR2

--

--  OUT

--    X_HEADER_DATA 		OUT NOCOPY TG_ENTRY_CURSOR

--  , X_CONTACT_POINT_DATA 	OUT NOCOPY TG_ENTRY_CURSOR

--  , X_TOTAL_ENTRIES		OUT NUMBER

--

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

PROCEDURE GET_TG_ENTRY_LIST

  ( P_LIST_HEADER_ID		IN  NUMBER

  , P_SEARCH_COLUMN			IN  VARCHAR2

  , P_SEARCH_OPERATOR		IN  VARCHAR2

  , P_SEARCH_PARAM			IN  VARCHAR2

  , P_ORDER_BY				IN  NUMBER

  , P_NEXT_ROW				IN  NUMBER

  , P_MAX_ROWS				IN  NUMBER

  , P_ORDER					IN  VARCHAR2

  , X_HEADER_DATA 			OUT NOCOPY TG_ENTRY_CURSOR

  , X_ENTRY_DATA 			OUT NOCOPY TG_ENTRY_CURSOR

  , X_TOTAL_ENTRIES			OUT NOCOPY NUMBER );



-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           GET_TG_ENTRY_DETAILS

--

-- Used by Target Group Entry Details Page to show the details

-- (including contact points) belonging to a certain entry.

-- This procedure also gathers data for the page header.

-- A list of timezones is also displayed on the page; their

-- translations are fetched here.

--

--   Type: Private

--

--   Parameters

--  IN

--    P_LIST_HEADER_ID		IN  NUMBER

--  , P_LIST_ENTRY_ID		IN  NUMBER

--  , P_LANGUAGE			IN  VARCHAR2

--

--  OUT

--  , X_HEADER_DATA 		OUT NOCOPY TG_ENTRY_CURSOR

--  , X_CONTACT_POINT_DATA 	OUT NOCOPY TG_ENTRY_CURSOR

--  , X_TIME_ZONE_DATA		OUT NOCOPY TG_ENTRY_CURSOR

--

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

PROCEDURE GET_TG_ENTRY_DETAILS

  ( P_LIST_HEADER_ID		IN  NUMBER

  , P_LIST_ENTRY_ID			IN  NUMBER

  , P_LANGUAGE				IN  VARCHAR2

  , X_HEADER_DATA 			OUT NOCOPY TG_ENTRY_CURSOR

  , X_CONTACT_POINT_DATA 	OUT NOCOPY TG_ENTRY_CURSOR

  , X_TIME_ZONE_DATA		OUT NOCOPY TG_ENTRY_CURSOR );


-- ===============================================================

--    Start of Comments

-- ===============================================================

--   API Name

--           Copy_Calendar_Day

--   Type

--           Private

--   Pre-Req

--

--   Parameters

--

--  IN

--    p_calendar_id         IN  NUMBER,
--    p_day_id              IN  NUMBER,
--    p_copyto_code         IN VARCHAR2,
--    p_createdBy           IN NUMBER,
--    p_creationDate        IN DATE,
--    p_updatedBy           IN NUMBER,
--    p_updateDate          IN DATE,
--    p_updateLogin         IN NUMBER,
--    p_versionNumber       IN NUMBER

--   Version : Current version 1.0

--

--   End of Comments

-- ===============================================================

--

PROCEDURE Copy_Calendar_Day(

    p_calendar_id         IN  NUMBER,
    p_day_id              IN  NUMBER,
    p_copyto_code         IN VARCHAR2,
    p_createdBy           IN NUMBER,
    p_creationDate        IN DATE,
    p_updatedBy           IN NUMBER,
    p_updateDate          IN DATE,
    p_updateLogin         IN NUMBER,
    p_versionNumber       IN NUMBER
    );




END IEC_Admin_PVT;


 

/
