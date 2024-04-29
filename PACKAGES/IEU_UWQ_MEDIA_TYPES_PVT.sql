--------------------------------------------------------
--  DDL for Package IEU_UWQ_MEDIA_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_MEDIA_TYPES_PVT" AUTHID CURRENT_USER AS
-- $Header: IEUMEDS.pls 120.1 2005/06/28 08:20:16 appldev ship $

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_UWQ_MEDIA_TYPES_PVT
-- Purpose
--    To provide easy to use apis for UQW Admin.
-- History
--    11-Feb-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           GET_MEDIA_TYPE_LIST
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_language    IN   VARCHAR2    Required
--  p_order_by    IN   VARCHAR2    Required
--  p_asc         IN   VARCHAR2    Required
--
--
--  OUT
--  x_media_type_list  OUT  SYSTEM.IEU_MEDIA_TYPE_NST
--  x_return_status    OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE GET_MEDIA_TYPE_LIST (    p_language IN varchar2,
                                   p_order_by IN varchar2,
                                   p_asc      IN varchar2,
                                   x_media_type_list  OUT NOCOPY SYSTEM.IEU_MEDIA_TYPE_NST,
                                   x_return_status  OUT NOCOPY VARCHAR2);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           VALIDATE
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_MEDIA_TYPE_OBJ    Required
--  is_create   IN   boolean   Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE VALIDATE (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        rec_obj IN SYSTEM.IEU_MEDIA_TYPE_OBJ, is_create IN boolean);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           CREATE_MEDIA_TYPE
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_MEDIA_TYPE_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE CREATE_MEDIA_TYPE (    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 rec_obj IN SYSTEM.IEU_MEDIA_TYPE_OBJ);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           UPDATE_MEDIA_TYPE
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_MEDIA_TYPE_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE UPDATE_MEDIA_TYPE (    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 rec_obj IN SYSTEM.IEU_MEDIA_TYPE_OBJ);

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           DELETE_MEDIA_TYPE
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_media_type_id     IN   NUMBER    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE DELETE_MEDIA_TYPE (x_media_type_id IN NUMBER);

END IEU_UWQ_MEDIA_TYPES_PVT;


 

/
