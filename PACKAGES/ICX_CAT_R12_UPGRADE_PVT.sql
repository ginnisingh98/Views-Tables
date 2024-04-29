--------------------------------------------------------
--  DDL for Package ICX_CAT_R12_UPGRADE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_R12_UPGRADE_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXV12US.pls 120.3 2006/06/21 19:12:28 sbgeorge noship $*/

-- Start of comments
--      API name        : getPOAttrValuesTLPAction
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : Checks if the line exists in PO_ATTRIBUTE_VALUES_TLP
--                        for the given po_line_id, req_template_name, req_template_line_num,
--                        org_id and language.
--                        Depending upon the existance of the line the function
--                        will return ADD/UPDATE
-- *    Parameters      :
--      IN              :       p_po_line_id                    IN              NUMBER
--                                                                              Required
--                                      Corresponds to the po_line_id of the line.
--                              p_req_template_name             IN              VARCHAR2
--                                                                              Required
--                                      Corresponds to the req_template_name of the line.
--                              p_req_template_line_num         IN              NUMBER
--                                                                              Required
--                                      Corresponds to the req_template_line_num of the line.
--                              p_org_id                        IN              NUMBER
--                                                                              Required
--                                      Corresponds to the org_id of the line.
--                              p_language                      IN              VARCHAR2
--                                                                              Required
--                                      Corresponds to the language of the line.
--      OUT             :       l_action                OUT NOCOPY      VARCHAR2
--                                      Corresponds to the ACTION in PO_ATTR_VALUES_TLP_INTERFACE
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
FUNCTION getPOAttrValuesTLPAction
(       p_po_line_id            IN      NUMBER          ,
        p_req_template_name     IN      VARCHAR2        ,
        p_req_template_line_num IN      NUMBER          ,
        p_org_id                IN      NUMBER          ,
        p_language              IN      VARCHAR2
)
  RETURN VARCHAR2;

-- Start of comments
--      API name        : updatePOHeaderId
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of populating the header id in
--                        icx_cat_r12_upgrade.  This procedure is
--                        called by purchasing when a po_header_id is stamped
--                        in PO_HEADERS_INTERFACE
-- *    Parameters      :
--      IN              :       p_interface_header_id           IN DBMS_SQL.NUMBER_TABLE
--                                                                              Required
--                                      Corresponds to the column INTERFACE_HEADER_ID in
--                                      the table PO_HEADERS_INTERFACE, and identifies the
--                                      interface_header_ids which has been updated with
--                                      a po_header_id.
--      OUT             :       None
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updatePOHeaderId
(       p_interface_header_id   IN      DBMS_SQL.NUMBER_TABLE
);

-- Start of comments
--      API name        : updatePOLineId
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : Takes care of populating the line id in
--                        icx_cat_r12_upgrade.  This procedure is
--                        called by purchasing when a po_line_id is stamped
--                        in PO_LINES_INTERFACE
-- *    Parameters      :
--      IN              :       p_interface_line_id             IN DBMS_SQL.NUMBER_TABLE
--                                                                              Required
--                                      Corresponds to the column INTERFACE_LINE_ID in
--                                      the table PO_LINES_INTERFACE, and identifies the
--                                      interface_line_ids which has been updated with
--                                      a po_line_id.
--      OUT             :       None
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updatePOLineId
(       p_interface_line_id     IN      DBMS_SQL.NUMBER_TABLE
);

-- Start of comments
--      API name        : upgradeDefaultSortProfiles
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : The api upgrades the default sort profiles:
--                        1. POR_DEFAULT_SHOPPING_SORT
--                        2. POR_DEFAULT_SHOPPING_SORT_ORDER
-- *    Parameters      :
--      IN              :       None
--      OUT             :       None
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE upgradeDefaultSortProfiles;

-- Start of comments
--      API name        : runR12Upgrade
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : The r12 Upgrade api is run on a R12 instance
--                        The api will upgrade the ip data to R12 data model
--                        In addition it will also upgrade the favorite list lines
--                        and make all the GBPAs created during pre-upgrade/upgrade
--                        approved.
-- *    Parameters      :
--      IN              :       None
--      OUT             :       x_errbuf                OUT NOCOPY      VARCHAR2
--                              x_retcode               OUT NOCOPY      NUMBER
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE runR12Upgrade
(       x_errbuf        OUT NOCOPY      VARCHAR2                                ,
        x_retcode       OUT NOCOPY      NUMBER
);

-- Start of comments
--      API name        : runDataExcptnRptChildProcess
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : Data Exceptions report tells the user the ip data that
--                        was not upgraded to R12 due to errors.  Also user can
--                        find out the reasons the data was not upgraded, and the user
--                        can download the file for the errored data.  If the user
--                        chooses, he can correct the data and reload.
--                        When preUpgrade is run on a 11.5.9/11.5.10 instance
--                        The api runDataExcptnRptChildProcess is run as a child process
--                        so that this can be run parallel to other process
-- *    Parameters      :
--      IN              :       p_parent_int_req_id             IN              NUMBER
--                                                                              Required
--                                      Corresponds to the column INTERNAL_REQUEST_ID,
--                                      and identifies the rows that have been
--                                      created/updated in a particular run.
--                              p_batch_size                    IN              NUMBER
--                                                                              Required
--                                      Corresponds to the batch_size used for DMLs.
--                              p_commit                        IN              VARCHAR2
--                                                                              Required
--                                      Deciding factor whether to commit in the API
--                              p_pdoi_batch_id                 IN              NUMBER
--                                                                              Required
--                                      Corresponds to the column BATCH_ID in
--                                      PO_HEADERS_INTERFACE, the data exceptions report
--                                      is run for the data available in the batch
--      OUT             :       x_errbuf                OUT NOCOPY      VARCHAR2
--                              x_retcode               OUT NOCOPY      NUMBER
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE runDataExcptnRptChildProcess
(       x_errbuf                OUT NOCOPY      VARCHAR2        ,
        x_retcode               OUT NOCOPY      NUMBER          ,
        p_parent_int_req_id     IN              NUMBER          ,
        p_batch_size            IN              NUMBER          ,
        p_commit                IN              VARCHAR2        ,
        p_pdoi_batch_id         IN              NUMBER
);

-- Start of comments
--      API name        : createR12UpgradeJob
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : The api creates the current job row with all the
--                        details in icx_cat_r12_upgrade_jobs
-- *    Parameters      :
--      IN              :       p_audsid                        IN              NUMBER
--                                                                              Required
--                                      Corresponds to the USERENV('SESSIONID')
--                              p_pdoi_batch_id                 IN              NUMBER
--                                                                              Optional
--                                      Corresponds to the column BATCH_ID in
--                                      PO_HEADERS_INTERFACE for the current job
--      OUT             :       None
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE createR12UpgradeJob
(       p_audsid                IN      NUMBER                  ,
        p_pdoi_batch_id         IN      NUMBER DEFAULT NULL
);

-- Start of comments
--      API name        : updateR12UpgradeJob
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : The api updates the current job status
--                        in icx_cat_r12_upgrade_jobs.
-- *    Parameters      :
--      IN              :       p_job_status                    IN              VARCHAR2
--                                                                              Required
--                                      Corresponds to the column JOB_STATUS in
--                                      ICX_CAT_R12_UPGRADE_JOBS for the current job
--                              p_audsid2                       IN              NUMBER
--                                                                              Optional
--                                      Corresponds to the USERENV('SESSIONID')
--
--      OUT             :       None
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE updateR12UpgradeJob
(       p_job_status    IN      VARCHAR2                ,
        p_audsid2       IN      NUMBER DEFAULT NULL
);

-- Start of comments
--      API name        : callICXFinalSteps
-- *    Type            : Private
-- *    Pre-reqs        : None.
-- *    Function        : This API is called during upgrade.
--                        It calls the final purge to remove the invalid blanket lines
--                        that might have been not approved during po final upgrade
-- *    Parameters      :
--      IN              :       None
--      OUT             :       None
-- *    Version         : Current version       1.0
--                        Previous version      1.0
--                        Initial version       1.0
--
--      Notes           : None.
--
-- End of comments
PROCEDURE callICXFinalSteps;

END ICX_CAT_R12_UPGRADE_PVT;

 

/
