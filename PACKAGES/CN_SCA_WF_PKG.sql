--------------------------------------------------------
--  DDL for Package CN_SCA_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: cnpscaws.pls 120.1 2005/09/15 14:42:34 rchenna noship $ */
/*#
 * This package includes public APIs for Sales Credit Allocation standard Revenue
 * Distribution and Transaction Transfer.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Workflow processes for Revenue Distribution and Transaction Transfer
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CN_SCA_WF_PKG';

-- CONSTANTS
G_REVENUE       CONSTANT VARCHAR2(30) := 'REVENUE';     -- revenue_type
G_REV_NOT_100   CONSTANT VARCHAR2(30) := 'REV NOT 100'; -- process_status
G_ALLOCATED     CONSTANT VARCHAR2(30) := 'ALLOCATED';   -- process_status
G_PROFILE       CONSTANT VARCHAR2(30) := 'CN_SCA_REV_NOT_100';

-- Start of comments
--    API name        : START_PROCESS
--    Description     : Starts the WF process, for ONLINE Revenue Distribution.
--    Type            : Public.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_sca_batch_id        IN NUMBER       Required
--                      p_wf_process          IN VARCHAR2     Required
--                      p_wf_item_type        IN VARCHAR2     Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : p_sca_batch_id - sca_batch_id processed by SCA Engine
--                      p_wf_process   - 'CN_SCA_REV_DIST_PR'
--                      p_wf_item_type - 'CNSCARPR'
-- End of comments

/*#
 * This procedure creates a workflow process with the given specifications that distributes
 * revenue between transactions processed in Batch mode.
 * It also lets the user to create a plan element assignment.
 * @param p_sca_batch_id Sales Credit Allocation Batch identifier. Foreign key to CN_SCA_HEADERS_INTERFACE
 * @param p_wf_process Sales Credit Allocation Workflow Revenue Distribution process identifier ('CN_SCA_REV_DIST_PR).
 * @param p_wf_item_type Sales Credit Allocation Workflow item identifier ('CNSCARPR').
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start workflow process for Revenue Distribution (Batch Mode transactions)
 */
PROCEDURE START_PROCESS (
    p_sca_batch_id      IN number,
    p_wf_process        IN varchar2,
    p_wf_item_type      IN varchar2);

-- Start of comments
--    API name        : START_PROCESS
--    Description     : Starts the WF process, for BATCH Revenue Distribution.
--    Type            : Public.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_start_header_id     IN NUMBER       Required
--                      p_end_header_id       IN NUMBER       Required
--                      p_trx_source          IN VARCHAR2     Required
--                      p_wf_process          IN VARCHAR2     Required
--                      p_wf_item_type        IN VARCHAR2     Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : p_start_header_id - lowest sca_headers_interface_id
--                      p_end_header_id   - highest sca_header_interface_id
--                      p_trx_source      - lookup code of type SCA_TRX_SOURCES
--                      p_wf_process      - 'CN_SCA_REV_DIST_PR'
--                      p_wf_item_type    - 'CNSCARPR'
-- End of comments
/*#
 * This procedure creates a workflow process with the given specifications that distributes
 * revenue between transactions processed in Online mode.
 * @param p_start_header_id Minimum identifier of transaction headers that are processed.
 * Foreign key to CN_SCA_HEADERS_INTERFACE
 * @param p_end_header_id Maximum identifier of transaction headers that are processed.
 * Foreign key to CN_SCA_HEADERS_INTERFACE
 * @param p_trx_source Transaction source of transaction headers that are processed.
 * Foreign key to CN_SCA_HEADERS_INTERFACE
 * @param p_wf_process Sales Credit Allocation Workflow Revenue Distribution process
 * identifier ('CN_SCA_REV_DIST_PR)
 * @param p_wf_item_type Sales Credit Allocation Workflow item identifier ('CNSCARPR')
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start workflow process for Renenue Distribution (Online Mode)
 */

PROCEDURE START_PROCESS (
    p_start_header_id   IN number,
    p_end_header_id     IN number,
    p_trx_source        IN varchar2,
    p_wf_process        IN varchar2,
    p_wf_item_type      IN varchar2);

-- Start of comments
--    API name        : START_PROCESS
--    Description     : Starts the WF process, for BATCH Transaction Loading.
--    Type            : Public.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_start_date          IN DATE         Required
--                      p_end_date            IN DATE         Required
--                      p_trx_source          IN VARCHAR2     Required
--                      p_wf_process          IN VARCHAR2     Required
--                      p_wf_item_type        IN VARCHAR2     Required
--    OUT             : x_wf_item_key         OUT VARCHAR2
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : p_start_date   - lowest processed_date
--                      p_end_date     - highest processed_date
--                      p_trx_source   - lookup code of type SCA_TRX_SOURCES
--                      p_wf_process   - 'CN_SCA_TRX_LOAD_PR'
--                      p_wf_item_type - 'CNSCARPR'
--                      x_wf_item_key  - workflow item key
--                      Includes programmatic deferal of process to WF background
--                      process.
-- End of comments
/*#
 * This procedure creates a deferred workflow process with the given specifications that
 * transfers transactions from the Sales Credit Allocation batch interface tables to the
 * Oracle Incentive Compensation Transaction Interface table, or to custom table(s).
 * @param p_start_date Minimum date of transaction headers that are processed.
 * Foreign key to CN_SCA_HEADERS_INTERFACE_GTT
 * @param p_end_date Maximum date of transaction headers that are processed.
 * Foreign key to CN_SCA_HEADERS_INTERFACE_GTT
 * @param p_trx_source Transaction source of transaction headers that are processed.
 * Foreign key to CN_SCA_HEADERS_INTERFACE_GTT
 * @param p_wf_process Sales Credit Allocation Workflow Revenue Distribution process
 * identifier ('CN_SCA_REV_DIST_PR)
 * @param p_wf_item_type Sales Credit Allocation Workflow item identifier ('CNSCARPR')
 * @param x_wf_item_key Workflow item key of the Transaction Transfer process
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Workflow process to load the transactions.
 */

PROCEDURE START_PROCESS (
    p_start_date        IN date,
    p_end_date          IN date,
    p_trx_source        IN varchar2,
    p_org_id		IN number,
    p_wf_process        IN varchar2,
    p_wf_item_type      IN varchar2,
    x_wf_item_key       OUT NOCOPY varchar2);

-- Start of comments
--    API name        : SELECTOR
--    Description     : Determines which WF process to run by default.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : itemType              IN VARCHAR2     Required
--                      itemKey               IN VARCHAR2     Required
--                      actId                 IN NUMBER       Required
--                      funcMode              IN VARCHAR2     Required
--    OUT             : resoultOut            OUT VARCHAR2(30)
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : itemType  - A valid item type from WF_ITEM_TYPES table.
--                      itemKey   - A string generated from application object's
--                                  PRIMARY key.
--                      actId     - The function activity (instance ID)
--                      funcMode  - Run/Cancel.
--                      resultOut - Name of default workflow process to run,
--                                  'CN_SCA_REV_DIST_PR' (Revenue Distribution)
-- End of comments
PROCEDURE SELECTOR (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY VARCHAR2);

-- Start of comments
--    API name        : TRX_LOAD_SELECT
--    Description     : Determines which Revenue Distribution function to run.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : itemType              IN VARCHAR2     Required
--                      itemKey               IN VARCHAR2     Required
--                      actId                 IN NUMBER       Required
--                      funcMode              IN VARCHAR2     Required
--    OUT             : resoultOut            OUT VARCHAR2(30)
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : itemType  - A valid item type from WF_ITEM_TYPES table
--                      itemKey   - A string generated from application object's
--                                  PRIMARY key
--                      actId     - The function activity (instance ID)
--                      funcMode  - Run/Cancel
--                      resultOut - CN_SCA_REV_FUNC lookup code:
--                                  'COMPLETE:EVEN'
--                                  'COMPLETE:WTD'
--                                  'COMPLETE:CUSTOM'
-- End of comments
PROCEDURE REV_DIST_SELECT (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2);

-- Start of comments
--    API name        : TRX_LOAD_SELECT
--    Description     : Determines which Transaction Load function to run.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : itemType              IN VARCHAR2     Required
--                      itemKey               IN VARCHAR2     Required
--                      actId                 IN NUMBER       Required
--                      funcMode              IN VARCHAR2     Required
--    OUT             : resoultOut            OUT VARCHAR2(30)
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : itemType  - A valid item type from WF_ITEM_TYPES table
--                      itemKey   - A string generated from application object's
--                                  PRIMARY key.
--                      actId     - The function activity (instance ID)
--                      funcMode  - Run/Cancel
--                      resultOut - CN_SCA_TRX_LOAD_FUNC lookup code:
--                                  'COMPLETE:CN'
--                                  'COMPLETE:CUSTOM'
-- End of comments
PROCEDURE TRX_LOAD_SELECT (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2);

-- Start of comments
--    API name        : EVEN_REV_DIST
--    Description     : Executes EVEN revenue distribution.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : itemType              IN VARCHAR2     Required
--                      itemKey               IN VARCHAR2     Required
--                      actId                 IN NUMBER       Required
--                      funcMode              IN VARCHAR2     Required
--    OUT             : resoultOut            OUT VARCHAR2(30)
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : itemType  - A valid item type from WF_ITEM_TYPES table
--                      itemKey   - A string generated from application object's
--                                  PRIMARY key
--                      actId     - The function activity (instance ID)
--                      funcMode  - Run/Cancel
--                      resultOut - 'COMPLETE:'
-- End of comments
PROCEDURE EVEN_REV_DIST (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2);

-- Start of comments
--    API name        : WTD_REV_DIST
--    Description     : Executes WEIGHTED AVERAGE revenue distribution.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : itemType              IN VARCHAR2     Required
--                      itemKey               IN VARCHAR2     Required
--                      actId                 IN NUMBER       Required
--                      funcMode              IN VARCHAR2     Required
--    OUT             : resoultOut            OUT VARCHAR2(30)
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : itemType  - A valid item type from WF_ITEM_TYPES table
--                      itemKey   - A string generated from application object's
--                                  PRIMARY key
--                      actId     - The function activity (instance ID)
--                      funcMode  - Run/Cancel
--                      resultOut - 'COMPLETE:'
-- End of comments
PROCEDURE WTD_REV_DIST (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2);

-- Start of comments
--    API name        : CN_TRX_LOAD
--    Description     : Executes Oracle Incentive Compensation Transaction Load.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : itemType              IN VARCHAR2     Required
--                      itemKey               IN VARCHAR2     Required
--                      actId                 IN NUMBER       Required
--                      funcMode              IN VARCHAR2     Required
--    OUT             : resoultOut            OUT VARCHAR2(30)
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : itemType  - A valid item type from WF_ITEM_TYPES table
--                      itemKey   - A string generated from application object's
--                      PRIMARY key
--                      actId     - The function activity (instance ID)
--                      funcMode  - Run/Cancel
--                      resultOut - 'COMPLETE:'
-- End of comments
PROCEDURE CN_TRX_LOAD (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2);

END CN_SCA_WF_PKG;
 

/
