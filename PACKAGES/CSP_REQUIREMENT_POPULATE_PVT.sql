--------------------------------------------------------
--  DDL for Package CSP_REQUIREMENT_POPULATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQUIREMENT_POPULATE_PVT" AUTHID CURRENT_USER AS
/* $Header: cspgrqps.pls 120.0 2005/05/25 11:43:49 appldev noship $ */
-- Start of Comments
-- Package name     : CSP_SCH_INT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

    G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSP_REQUIREMENT_POPULATE_PVT';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'cspgrqps.pls';

PROCEDURE POPULATE_REQUIREMENTS(p_task_id        IN NUMBER
                                ,p_api_version   IN NUMBER
                                ,p_Init_Msg_List IN VARCHAR2     := FND_API.G_FALSE
                                ,p_commit        IN VARCHAR2     := FND_API.G_FALSE
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_msg_data      OUT NOCOPY NUMBER
                                ,x_msg_count     OUT NOCOPY NUMBER
                                ,px_header_id IN OUT NOCOPY NUMBER
                                ,p_called_by     IN  NUMBER);
END CSP_REQUIREMENT_POPULATE_PVT;

 

/
