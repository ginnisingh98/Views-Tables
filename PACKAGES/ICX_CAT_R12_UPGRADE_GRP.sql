--------------------------------------------------------
--  DDL for Package ICX_CAT_R12_UPGRADE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_R12_UPGRADE_GRP" AUTHID CURRENT_USER AS
/* $Header: ICXG12US.pls 120.2 2006/08/24 00:36:04 sudsubra noship $*/

g_job_running_status            CONSTANT VARCHAR2(1) := ICX_CAT_UTIL_PVT.g_job_running_status;
g_job_complete_status           CONSTANT VARCHAR2(1) := ICX_CAT_UTIL_PVT.g_job_complete_status;
g_job_failed_status             CONSTANT VARCHAR2(1) := ICX_CAT_UTIL_PVT.g_job_failed_status;
g_job_paused_status             CONSTANT VARCHAR2(1) := ICX_CAT_UTIL_PVT.g_job_paused_status;

-- Start of comments
--      API name        : updatePOHeaderId
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of populating the header id in
--                        icx_cat_r12_upgrade.  This procedure is
--                        called by purchasing when a po_header_id is stamped
--                        in PO_HEADERS_INTERFACE
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_interface_header_id           IN DBMS_SQL.NUMBER_TABLE
--                                                                              Required
--                                      Corresponds to the column INTERFACE_HEADER_ID in
--                                      the table PO_HEADERS_INTERFACE, and identifies the
--                                      interface_header_ids which has been updated with
--                                      a po_header_id.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updatePOHeaderId
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_interface_header_id   IN              DBMS_SQL.NUMBER_TABLE
);

-- Start of comments
--      API name        : updatePOLineId
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of populating the line id in
--                        icx_cat_r12_upgrade.  This procedure is
--                        called by purchasing when a po_line_id is stamped
--                        in PO_LINES_INTERFACE
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_interface_line_id             IN DBMS_SQL.NUMBER_TABLE
--                                                                              Required
--                                      Corresponds to the column INTERFACE_LINE_ID in
--                                      the table PO_LINES_INTERFACE, and identifies the
--                                      interface_line_ids which has been updated with
--                                      a po_line_id.
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updatePOLineId
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_interface_line_id     IN              DBMS_SQL.NUMBER_TABLE
);

-- Start of comments
--      API name        : createR12UpgradeJob
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : inserts a job in icx_cat_r12_upgrade_jobs
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_job_type                      IN VARCHAR2     Required
--                                      Type of job to be created
--                              p_audsid                        IN NUMBER       Required
--                                      audsid for the job to be created
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE createR12UpgradeJob
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_job_type              IN              VARCHAR2,
        p_audsid                IN              NUMBER
);

-- Start of comments
--      API name        : updateR12UpgradeJob
-- *    Type            : Group
-- *    Pre-reqs        : None.
-- *    Function        : updates a job in icx_cat_r12_upgrade_jobs
-- *    Parameters      :
--      IN              :       p_api_version                   IN NUMBER       Required
--                              p_commit                        IN VARCHAR2     Optional
--                                      Default = FND_API.G_TRUE
--                              p_init_msg_list                 IN VARCHAR2     Optional
--                                      Default = FND_API.G_FALSE
--                              p_validation_level              IN NUMBER       Optional
--                                      Default = FND_API.G_VALID_LEVEL_FULL
--                              p_job_status                      IN VARCHAR2     Required
--                                      New status of the job
--      OUT             :       x_return_status         OUT NOCOPY      VARCHAR2(1)
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updateR12UpgradeJob
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_job_status            IN              VARCHAR2
);






END ICX_CAT_R12_UPGRADE_GRP;

 

/
