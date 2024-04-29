--------------------------------------------------------
--  DDL for Package IEU_NONMEDIA_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_NONMEDIA_ACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUNMAS.pls 115.0 2003/08/25 16:17:38 gpagadal noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_NonMedia_Action_PVT
-- Purpose
--    To provide easy to use apis for Non madia action admin.
-- History
--    22-Aug-2003     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Create_NMediaAction(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_docname IN VARCHAR2,
                       p_resp_id IN NUMBER,
                       p_tflag IN VARCHAR2,
                       p_mdef_id IN NUMBER
                       );


PROCEDURE Update_NMediaAction(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       p_nmedia_id IN NUMBER,
                       p_docname IN VARCHAR2,
                       p_resp_id IN NUMBER,
                       p_tflag IN VARCHAR2,
                       p_mdef_id IN NUMBER
                       );



PROCEDURE Delete_NMediaAction(    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                       x_msg_data  OUT  NOCOPY VARCHAR2,
                       x_nmedia_id IN NUMBER
                       );








END IEU_NonMedia_Action_PVT;


 

/
