--------------------------------------------------------
--  DDL for Package AMS_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_STATUS_PVT" AUTHID CURRENT_USER as
/* $Header: amsvstss.pls 115.6 2002/11/22 23:39:08 dbiswas ship $ */

-- Start of Comments
--
-- NAME
--   AMS_STATUS_PVT
--
-- PURPOSE
--   This package is a Private API for Getting Next Valid statuses for
--   Marketing Activities
--   Tables and Record types :
--      type next_status_rec_type (see below for specification)
--      next_status_tbl_type  (see below for specification)
--
--   Procedures and Functions:
--     Get_Status_Lookup_Type (see below for specification)
--     Get_Lookup_Meaning (see below for specification)
--     Is_Approval_Needed (see below for specification)
--     Get_Next_Statuses (see below for specification)
--     Validate_Status_Change (see below for specification)
--
-- NOTES
--
--
-- HISTORY
--   06/29/1999        holiu            created
--   11/19/1999        ptendulk         Modified
-- End of Comments


TYPE next_status_rec_type IS RECORD(
   user_status_id       NUMBER,
   system_status_code   VARCHAR2(30),
   system_status_type   VARCHAR2(30),
   default_flag         VARCHAR2(1),
   user_status_name     VARCHAR2(120)
            );

TYPE next_status_tbl_type is TABLE OF next_status_rec_type
INDEX BY BINARY_INTEGER ;


--------------- start of comments --------------------------
-- NAME
--    Get_Status_Lookup_Type
--
-- USAGE
--    Given the arc qualifier for a certain area such as
--    'PROM', return the lookup type for the statuses
--    in that area, such as 'AMS_PROMOTION_STATUS'.
--
--    Return null if no corresponding lookup type.
--
-- PARAMETERS
-- 1. p_arc_status_for:  arc qualifier for a area, e.g. 'PROM'
--
--------------- end of comments ----------------------------

FUNCTION Get_Status_Lookup_Type (
   p_arc_status_for IN VARCHAR2
)
RETURN VARCHAR2;


--------------- start of comments --------------------------
-- NAME
--    get_lookup_meaning
--
-- USAGE
--    Given the lookup type and lookup code, get the meaning.
--    Return null if invalid type or code provided.
--
--------------- end of comments ----------------------------

FUNCTION Get_Lookup_Meaning(
   p_lookup_type  IN VARCHAR2,
   p_lookup_code  IN VARCHAR2
)
RETURN varchar2;


--------------- start of comments --------------------------
-- NAME
--    Is_Approval_Needed
--
-- USAGE
--    Check if a certain type of approval is needed for an
--    object area (and activity type). Return fnd_api.g_true
--    or fnd_api.g_false.
--
-- PARAMETERS
-- 1. p_arc_approval_for:  arc qualifier for a area, e.g. 'PROM'
-- 2. p_approval_type:  the lookup code of the approval type, e.g.
--       'BUDGET' or 'THEME'
-- 3. p_activity_type_code:  the type of the activity depending
--       on the object area, e.g. promotion type code for 'PROM'
--
------------------- end of comments ----------------------------

FUNCTION Is_Approval_Needed(
   p_arc_approval_for    IN  VARCHAR2,
   p_approval_type       IN  VARCHAR2,
   p_activity_type_code  IN  VARCHAR2 := NULL
)
RETURN VARCHAR2;


--------------- start of comments --------------------------
-- NAME
--    Get_Next_Statuses
--
-- USAGE
--    For a certain status in an object area, return all the
--    valid next statuses in a PL/SQL table.
--
--    The client side may use it to populate list items.
--
-- PARAMETERS
-- 1. p_arc_status_for:  arc qualifier for a area, e.g. 'PROM'
-- 2. p_current_status_code:
-- 3. p_activity_type_code:  the type of the activity depending
--       on the object area, e.g. promotion type code for 'PROM'
-- 4. x_next_status_tbl:  the PL/SQL table containing all valid
--       next statuses
--
--------------- end of comments ----------------------------
PROCEDURE Get_Next_Statuses(
   p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,

   p_arc_status_for       IN  VARCHAR2,
   p_current_status_id    IN  NUMBER,
   p_activity_type_code   IN  VARCHAR2 := NULL,
   x_next_status_tbl      OUT NOCOPY next_status_tbl_type,
   x_return_status        OUT NOCOPY VARCHAR2
);


--------------- start of comments --------------------------
-- NAME
--    Validate_Status_Change
--
-- USAGE
--    Check whether a status change is valid or not.
--    Server side API may use it for validate status changes.
--
-- PARAMETERS
-- 1. p_arc_status_for:  arc qualifier for a area, e.g. 'PROM'
-- 2. p_current_status_code:
-- 3. p_next_status_code:
-- 4. p_activity_type_code:  type code of the activity depending
--       on the object area, e.g. promotion type code for 'PROM'
-- 5. x_valid_flag:  indicate if the status change is valid
--
--------------- end of comments ----------------------------
PROCEDURE Validate_Status_Change(
   p_init_msg_list        IN  VARCHAR2 := FND_API.g_false,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,

   p_arc_status_for       IN  VARCHAR2,
   p_current_status_id    IN  VARCHAR2,
   p_next_status_id       IN  VARCHAR2,
   p_activity_type_code   IN  VARCHAR2 := NULL,
   x_valid_flag           OUT NOCOPY VARCHAR2,  -- fnd_api.g_true, fnd_api.g_false
   x_return_status        OUT NOCOPY VARCHAR2
);

END AMS_STATUS_PVT ;

 

/
