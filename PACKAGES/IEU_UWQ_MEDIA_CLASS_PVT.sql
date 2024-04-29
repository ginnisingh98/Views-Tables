--------------------------------------------------------
--  DDL for Package IEU_UWQ_MEDIA_CLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_UWQ_MEDIA_CLASS_PVT" AUTHID CURRENT_USER AS
-- $Header: IEUMCLS.pls 120.0 2005/06/02 15:59:31 appldev noship $

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_UWQ_MEDIA_CLASS_PVT
-- Purpose
--    To provide easy to use apis for UQW Admin.
-- History
--    24-Oct-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           GET_MEDIA_CLASS_LIST
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_media_type_id    IN   NUMBER    Required
--  p_language    IN   VARCHAR2    Required
--
--
--  OUT
--  x_media_class_list  OUT  SYSTEM.IEU_CLASS_NST
--
--   End of Comments
-- ===============================================================


PROCEDURE GET_MEDIA_CLASS_LIST (p_media_type_id IN number,
                                p_language IN varchar2,
                                x_media_class_list  OUT NOCOPY SYSTEM.IEU_CLASS_NST
                                );
END IEU_UWQ_MEDIA_CLASS_PVT;


 

/
