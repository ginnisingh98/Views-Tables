--------------------------------------------------------
--  DDL for Package IEU_WORK_PROVIDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WORK_PROVIDER_PUB" AUTHID CURRENT_USER AS
/* $Header: ieuwpds.pls 115.3 2003/07/07 21:26:50 dolee noship $ */

--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteNode
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_action_key     IN   VARCHAR2(32)    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE DeleteNode(x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              x_msg_data  OUT NOCOPY  VARCHAR2,
                              r_enumId IN ieu_uwq_sel_enumerators.sel_enum_id%type);



END IEU_WORK_PROVIDER_PUB;

 

/
