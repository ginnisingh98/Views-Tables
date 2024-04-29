--------------------------------------------------------
--  DDL for Package Body CN_SCA_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_WF_PKG" AS
/* $Header: cnpscawb.pls 120.2 2005/09/23 15:22:32 rchenna noship $ */

-- PRIVATE PROCEDURES
-- ==================

-- Start of comments
--    API name        : BATCH_POST_DIST_UPDATE
--    Description     : Update revenue allocation if rounding occured.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : BATCH_EVEN_REV_DIST or BATCH_WTD_REV_DIST completed.
--    Parameters      :
--    IN              : p_start_header_id     IN NUMBER       Required
--                    : p_end_header_id       IN NUMBER       Required
--                    : p_user_id             IN NUMBER       Required
--                    : p_login_id            IN NUMBER       Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           :
-- End of comments
PROCEDURE BATCH_POST_DIST_UPDATE (
    p_start_header_id  IN  number,
    p_end_header_id    IN  number,
    p_user_id          IN  number,
    p_login_id         IN  number)
IS
BEGIN

    UPDATE cn_sca_lines_output lines
    SET allocation_percentage =
            (SELECT ROUND(lines.allocation_percentage +
                          (100 - SUM(g_lines.allocation_percentage)),4)
             FROM cn_sca_headers_interface g_headers,
                  cn_sca_lines_output g_lines
             WHERE g_headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id
             AND   g_headers.sca_headers_interface_id =
                        g_lines.sca_headers_interface_id
             AND   g_lines.revenue_type = G_REVENUE
             AND   g_headers.process_status = G_REV_NOT_100
             GROUP BY g_headers.sca_headers_interface_id),
        last_updated_by   = p_user_id,
        last_update_date  = SYSDATE,
        last_update_login = p_login_id
    WHERE lines.revenue_type = G_REVENUE
    AND lines.sca_headers_interface_id
            BETWEEN p_start_header_id AND p_end_header_id
    AND EXISTS (SELECT 1
                FROM cn_sca_headers_interface headers
                WHERE headers.process_status = G_REV_NOT_100
                AND   headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id)
    AND lines.sca_lines_output_id = (SELECT MIN(sca_lines_output_id)
                                     FROM cn_sca_lines_output g_lines
                                     WHERE lines.sca_headers_interface_id =
                                        g_lines.sca_headers_interface_id
                                     AND g_lines.revenue_type = G_REVENUE);

END BATCH_POST_DIST_UPDATE;

-- Start of comments
--    API name        : ONLINE_POST_DIST_UPDATE
--    Description     : Update revenue allocation if rounding occured.
--    Type            : Private.
--    Function        :
--    Pre-reqs        : ONLINE_EVEN_REV_DIST or ONLINE_WTD_REV_DIST completed.
--    Parameters      :
--    IN              : p_sca_batch_id        IN NUMBER       Required
--                    : p_user_id             IN NUMBER       Required
--                    : p_login_id            IN NUMBER       Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           :
-- End of comments
PROCEDURE ONLINE_POST_DIST_UPDATE (
    p_sca_batch_id     IN  number)
IS
BEGIN

    UPDATE cn_sca_lines_output_gtt lines
    SET allocation_percentage =
            (SELECT ROUND(lines.allocation_percentage +
                          (100 - SUM(g_lines.allocation_percentage)),4)
             FROM cn_sca_headers_interface_gtt g_headers,
                  cn_sca_lines_output_gtt g_lines
             WHERE g_headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id
             AND   g_headers.sca_headers_interface_id =
                        g_lines.sca_headers_interface_id
             AND   g_lines.revenue_type = G_REVENUE
             AND   g_headers.process_status = G_REV_NOT_100
             GROUP BY g_headers.sca_headers_interface_id)
    WHERE lines.revenue_type = G_REVENUE
    AND   lines.sca_batch_id = p_sca_batch_id
    AND   EXISTS (SELECT 1
                  FROM cn_sca_headers_interface_gtt headers
                  WHERE headers.process_status = G_REV_NOT_100
                  AND   headers.sca_headers_interface_id =
                            lines.sca_headers_interface_id)
    AND   lines.sca_lines_output_id = (SELECT MIN(sca_lines_output_id)
                                       FROM cn_sca_lines_output_gtt g_lines
                                       WHERE lines.sca_headers_interface_id =
                                        g_lines.sca_headers_interface_id
                                       AND g_lines.revenue_type = G_REVENUE);

END ONLINE_POST_DIST_UPDATE;

-- Start of comments
--    API name        : ONLINE_EVEN_REV_DIST
--    Description     : Online Even Revenue Distribution
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_sca_batch_id        IN NUMBER       Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           :
-- End of comments
PROCEDURE ONLINE_EVEN_REV_DIST (
    p_sca_batch_id  IN  number,
    x_return_status OUT NOCOPY varchar2)
IS
BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start of API body.

    -- calculate and set new revenue allocation
    -- *******************************************
    --                              complement_pct
    -- new rev pct = curr_rev_pct + --------------
    --                                num_of_res
    -- *******************************************
    UPDATE cn_sca_lines_output_gtt lines
    SET allocation_percentage =
            (SELECT ROUND(lines.allocation_percentage +
                          (100 - SUM(g_lines.allocation_percentage))
                          / COUNT(*),4)
             FROM cn_sca_headers_interface_gtt g_headers,
                  cn_sca_lines_output_gtt g_lines
             WHERE g_headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id
             AND   g_headers.sca_headers_interface_id =
                        g_lines.sca_headers_interface_id
             AND   g_lines.revenue_type = G_REVENUE
             AND   g_headers.process_status = G_REV_NOT_100
             GROUP BY g_headers.sca_headers_interface_id)
    WHERE lines.revenue_type = G_REVENUE
    AND   lines.sca_batch_id = p_sca_batch_id
    AND   EXISTS (SELECT 1
                  FROM cn_sca_headers_interface_gtt headers
                  WHERE headers.process_status = G_REV_NOT_100
                  AND   headers.sca_headers_interface_id =
                            lines.sca_headers_interface_id);

    -- second update to address possible rounding error
    ONLINE_POST_DIST_UPDATE(p_sca_batch_id => p_sca_batch_id);

    -- update header status to ALLOCATED
    UPDATE cn_sca_headers_interface_gtt headers
    SET process_status    = G_ALLOCATED
    WHERE headers.process_status = G_REV_NOT_100
    AND   headers.sca_batch_id   = p_sca_batch_id;

   -- End of API body.

EXCEPTION

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END ONLINE_EVEN_REV_DIST;

-- Start of comments
--    API name        : BATCH_EVEN_REV_DIST
--    Description     : Batch Even Revenue Distribution
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_start_header_id     IN NUMBER       Required
--                    : p_end_header_id       IN NUMBER       Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           :
-- End of comments
PROCEDURE BATCH_EVEN_REV_DIST (
    p_start_header_id  IN  number,
    p_end_header_id    IN  number,
    x_return_status    OUT NOCOPY varchar2)
IS
    l_user_id  NUMBER := fnd_global.user_id;
    l_login_id NUMBER := fnd_global.login_id;
BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start of API body.

    -- calculate and set new revenue allocation
    -- *******************************************
    --                              complement_pct
    -- new rev pct = curr_rev_pct + --------------
    --                                num_of_res
    -- *******************************************
    UPDATE cn_sca_lines_output lines
    SET allocation_percentage =
            (SELECT ROUND(lines.allocation_percentage +
                          (100 - SUM(g_lines.allocation_percentage))
                          / COUNT(*),4)
             FROM cn_sca_headers_interface g_headers,
                  cn_sca_lines_output g_lines
             WHERE g_headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id
             AND   g_headers.sca_headers_interface_id =
                        g_lines.sca_headers_interface_id
             AND   g_lines.revenue_type = G_REVENUE
             AND   g_headers.process_status = G_REV_NOT_100
             GROUP BY g_headers.sca_headers_interface_id),
        last_updated_by   = l_user_id,
        last_update_date  = SYSDATE,
        last_update_login = l_login_id
    WHERE lines.revenue_type = G_REVENUE
    AND   lines.sca_headers_interface_id
            BETWEEN p_start_header_id AND p_end_header_id
    AND   EXISTS (SELECT 1
                  FROM cn_sca_headers_interface headers
                  WHERE headers.process_status = G_REV_NOT_100
                  AND   headers.sca_headers_interface_id =
                            lines.sca_headers_interface_id);

    -- second update to address possible rounding error
    BATCH_POST_DIST_UPDATE(p_start_header_id => p_start_header_id,
                           p_end_header_id   => p_end_header_id,
                           p_user_id         => l_user_id,
                           p_login_id        => l_login_id);

    -- update header status to ALLOCATED
    UPDATE cn_sca_headers_interface headers
    SET process_status    = G_ALLOCATED,
        last_updated_by   = l_user_id,
        last_update_date  = SYSDATE,
        last_update_login = l_login_id
    WHERE headers.process_status = G_REV_NOT_100
    AND   headers.sca_headers_interface_id
    BETWEEN p_start_header_id AND p_end_header_id;

   -- End of API body.

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END BATCH_EVEN_REV_DIST;

-- Start of comments
--    API name        : ONLINE_WTD_REV_DIST
--    Description     : Online Weighted Average Revenue Distribution
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_sca_batch_id        IN NUMBER       Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           :
-- End of comments
PROCEDURE ONLINE_WTD_REV_DIST (
    p_sca_batch_id  IN  number,
    x_return_status OUT NOCOPY varchar2)
IS
BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start of API body.

    -- calculate and set new revenue allocation
    -- **********************************************************
    --                              curr_rev_pct * complement_pct
    -- new rev pct = curr_rev_pct + -----------------------------
    --                                  curr_total_rev_pct
    -- **********************************************************
    UPDATE cn_sca_lines_output_gtt lines
    SET allocation_percentage =
              (SELECT ROUND(
                lines.allocation_percentage + lines.allocation_percentage *
                    (100 - SUM(g_lines.allocation_percentage)) /
                    SUM(g_lines.allocation_percentage),4)
               FROM cn_sca_headers_interface_gtt g_headers,
                    cn_sca_lines_output_gtt g_lines
               WHERE g_headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id
               AND   g_headers.sca_headers_interface_id =
                        g_lines.sca_headers_interface_id
               AND   g_lines.revenue_type = G_REVENUE
               AND   g_headers.process_status = G_REV_NOT_100
               GROUP BY g_headers.sca_headers_interface_id)
    WHERE lines.revenue_type = G_REVENUE
    AND   lines.sca_batch_id = p_sca_batch_id
    AND   EXISTS (SELECT 1
                  FROM cn_sca_headers_interface_gtt headers
                  WHERE headers.process_status = G_REV_NOT_100
                  AND   headers.sca_headers_interface_id =
                            lines.sca_headers_interface_id);

    -- second update to address possible rounding error
    ONLINE_POST_DIST_UPDATE(p_sca_batch_id => p_sca_batch_id);

    -- update header status to ALLOCATED
    UPDATE cn_sca_headers_interface_gtt headers
    SET process_status    = G_ALLOCATED
    WHERE headers.process_status = G_REV_NOT_100
    AND   headers.sca_batch_id   = p_sca_batch_id;

   -- End of API body.

EXCEPTION

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END ONLINE_WTD_REV_DIST;

-- Start of comments
--    API name        : BATCH_WTD_REV_DIST
--    Description     : Batch Weighted Average Revenue Distribution
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_sca_batch_id        IN NUMBER       Required
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           :
-- End of comments
PROCEDURE BATCH_WTD_REV_DIST (
    p_start_header_id  IN  number,
    p_end_header_id    IN  number,
    x_return_status    OUT NOCOPY varchar2)
IS
    l_user_id  NUMBER := fnd_global.user_id;
    l_login_id NUMBER := fnd_global.login_id;
BEGIN

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start of API body.

    -- calculate and set new revenue allocation
    -- **********************************************************
    --                              curr_rev_pct * complement_pct
    -- new rev pct = curr_rev_pct + -----------------------------
    --                                  curr_total_rev_pct
    -- **********************************************************
    UPDATE cn_sca_lines_output lines
    SET allocation_percentage =
              (SELECT ROUND(
                lines.allocation_percentage + lines.allocation_percentage *
                    (100 - SUM(g_lines.allocation_percentage)) /
                    SUM(g_lines.allocation_percentage),4)
               FROM cn_sca_headers_interface g_headers,
                    cn_sca_lines_output g_lines
               WHERE g_headers.sca_headers_interface_id =
                        lines.sca_headers_interface_id
               AND   g_headers.sca_headers_interface_id =
                        g_lines.sca_headers_interface_id
               AND   g_lines.revenue_type = G_REVENUE
               AND   g_headers.process_status = G_REV_NOT_100
               GROUP BY g_headers.sca_headers_interface_id),
        last_updated_by   = l_user_id,
        last_update_date  = SYSDATE,
        last_update_login = l_login_id
    WHERE lines.revenue_type = G_REVENUE
    AND   lines.sca_headers_interface_id
            BETWEEN p_start_header_id AND p_end_header_id
    AND   EXISTS (SELECT 1
                  FROM cn_sca_headers_interface headers
                  WHERE headers.process_status = G_REV_NOT_100
                  AND   headers.sca_headers_interface_id =
                            lines.sca_headers_interface_id);

    -- second update to address possible rounding error
    BATCH_POST_DIST_UPDATE(p_start_header_id => p_start_header_id,
                           p_end_header_id   => p_end_header_id,
                           p_user_id         => l_user_id,
                           p_login_id        => l_login_id);

    -- update header status to ALLOCATED
    UPDATE cn_sca_headers_interface headers
    SET process_status    = G_ALLOCATED,
        last_updated_by   = l_user_id,
        last_update_date  = SYSDATE,
        last_update_login = l_login_id
    WHERE headers.process_status = G_REV_NOT_100
    AND   headers.sca_headers_interface_id
            BETWEEN p_start_header_id AND p_end_header_id;

   -- End of API body.

EXCEPTION

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END BATCH_WTD_REV_DIST;

-- Start of comments
--    API name        : CONC_CN_TRX_LOAD
--    Description     : Online Even Revenue Distribution
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              :
--    OUT             :
--    Version         : Current version   1.0
--                      Previous version
--                      Initial version   1.0
--    Notes           : Autonomous Transaction.
-- End of comments
PROCEDURE CONC_CN_TRX_LOAD (
    p_org_id           IN varchar2,
    p_start_date       IN date,
    p_end_date         IN date,
	x_return_status    OUT NOCOPY varchar2,
    x_msg_count        OUT NOCOPY number,
 	x_msg_data         OUT NOCOPY varchar2,
 	x_process_audit_id OUT NOCOPY number)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

        -- Start of API body.

        -- set org context
        fnd_client_info.set_org_context(p_org_id);

        -- call procedure cn_sca_trx_proc_pvt.call_populate_results
        cn_sca_trx_proc_pvt.call_populate_results(
          p_api_version      => 1.0,
          p_start_date       => p_start_date,
          p_end_date         => p_end_date,
	  p_org_id           => p_org_id,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data,
          x_process_audit_id => x_process_audit_id);

        -- End of API body.

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count,
           p_data    =>  x_msg_data,
           p_encoded => FND_API.G_FALSE);

END CONC_CN_TRX_LOAD;

-- PUBLIC PROCEDURES
-- =================

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
--    Exception Msgs. : CN_SCA_WF_INVLD_BATCH_ID - Invalid batch identifier.
--                      CN_SCA_WF_INVLD_PR_NAME - Invalid process name sqlplus apps/apps@cnxd1r11 @cnvscaps.pls
--                      CN_SCA_WF_INVLD_ITEM_TYPE - Invalid item type sqlplus apps/apps@cnxd1r11 @cnvscapb.pls
--                      CN_SCA_WF_NO_TRX_SRC - Incomplete transaction data.
--                      CN_SCA_WF_NO_PROFILE_VAL - Profile value is undefined.
--
-- End of comments
PROCEDURE START_PROCESS (
    p_sca_batch_id      IN number,
    p_wf_process        IN varchar2,
    p_wf_item_type      IN varchar2
    )
AS
    -- Local Variables
    l_process varchar2(30);
    l_itemType varchar2(8);
    l_itemKey varchar2(240);

    l_trxSrc varchar2(30);
    l_appId number;
    l_orgId varchar2(30);
    l_revFunc varchar2(30);

BEGIN

    -- Start of API body

    -- Validate input
    -- ==============

    -- 1. p_sca_batch_id
    IF (p_sca_batch_id = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_BATCH_ID'));
    END IF;

    l_itemKey := p_sca_batch_id || '.' || wf_core.random;

    -- 2. p_wf_process
    IF UPPER(p_wf_process) <> 'CN_SCA_REV_DIST_PR' THEN
        wf_core.token('NAME',p_wf_process);
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_PR_NAME'));
    END IF;

    l_process := p_wf_process;

    -- 3. p_wf_item_type
    IF UPPER(p_wf_item_type) <> 'CNSCARPR' THEN
        wf_core.token('NAME',p_wf_item_type);
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_ITEM_TYPE'));
    END IF;

    l_itemType := p_wf_item_type;

    -- Create WF Process
    -- =================
    wf_engine.createprocess(itemtype    =>  l_itemType,
                            itemkey     =>  l_itemKey,
                            process     =>  l_process);

    -- Set Item Attributes
    -- ===================

    -- 1. sca_batch_id (NUMBER)
    -- ------------------------
    wf_engine.setitemattrnumber(itemtype    => l_itemType,
                                itemkey     => l_itemKey,
                                aname       => 'SCA_BATCH_ID',
                                avalue      => p_sca_batch_id);

    -- 2. org_id (TEXT)
    -- ----------------
    -- get org_id
    l_orgId := fnd_profile.value('ORG_ID');

    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'ORG_ID',
                              avalue      => l_orgId);

    -- 3. trx_source (TEXT)
    -- --------------------
    BEGIN
        -- get trx_source
        SELECT shig.transaction_source
        INTO   l_trxSrc
        FROM   cn_sca_headers_interface_gtt shig
        WHERE  shig.sca_batch_id = p_sca_batch_id
        AND    ROWNUM = 1;

    -- if not found, raise exception
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_NO_TRX_SRC'));
    END;

    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'TRX_SOURCE',
                              avalue      => l_trxSrc);

    -- 4. rev_dist_func (TEXT)
    -- -----------------------
    BEGIN
        -- get application_id based on transaction source
        SELECT fa.application_id
        INTO l_appId
        FROM   fnd_application fa
        WHERE  fa.application_short_name = l_trxSrc;

        -- if not found, then set to -1 (custom/noop)
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_appId := -1;
    END;

    -- get profile CN_SCA_REV_NOT_100 value (app/site level only)
    l_revFunc := fnd_profile.value_specific
        (name               =>  G_PROFILE,
         application_id     =>  l_appId,
         org_id             =>  l_orgId,
         server_id          =>  fnd_global.server_id);

    -- if not found, raise exception
    IF (l_revFunc = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_NO_PROFILE_VAL'));
    END IF;

    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'REV_DIST_FUNC',
                              avalue      => l_revFunc);

    -- 5. online_flag (TEXT)
    -- ---------------------
    -- defauls to 'Y', so no need to set

    -- Start WF Process
    -- ================
    wf_engine.startprocess(itemtype =>  l_itemType,
                           itemkey  =>  l_itemKey);

    -- End of API body

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_REV_DIST_PR',
                        l_itemKey);
        RAISE;

END START_PROCESS;

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
--    Exception Msgs. : CN_SCA_WF_INVLD_ST_HEADER_ID - Invalid start header identifier.
--                      CN_SCA_WF_INVLD_END_HEADER_ID - Invalid end header identifier.
--                      CN_SCA_WF_INVLD_TRX_SRC - Invalid transaction source.
--                      CN_SCA_WF_INVLD_PR_NAME - Invalid process name sqlplus apps/apps@cnxd1r11 @cnvscads.pls
--                      CN_SCA_WF_INVLD_ITEM_TYPE - Invalid item type sqlplus apps/apps@cnxd1r11 @cnvscadb.pls
--                      CN_SCA_WF_NO_PROFILE_VAL - Profile value is undefined.
-- End of comments
PROCEDURE START_PROCESS (
    p_start_header_id   IN number,
    p_end_header_id     IN number,
    p_trx_source        IN varchar2,
    p_wf_process        IN varchar2,
    p_wf_item_type      IN varchar2
    )
AS
    -- Local Variables
    l_process varchar2(30);
    l_itemType varchar2(8);
    l_itemKey varchar2(240);

    l_appId number;
    l_orgId varchar2(30);
    l_revFunc varchar2(30);

BEGIN

    -- Start of API body

    -- Validate input
    -- ==============

    -- 1. p_start_header_id
    IF (p_start_header_id = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_ST_HEADER_ID'));
    END IF;

    -- 2. p_end_header_id
     IF (p_end_header_id = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_END_HEADER_ID'));
    END IF;

    -- 3. p_trx_source
    IF (p_trx_source = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_TRX_SRC'));
    END IF;

    -- 4. p_wf_process
    IF (UPPER(p_wf_process) <> 'CN_SCA_REV_DIST_PR') THEN
        wf_core.token('NAME',p_wf_process);
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_PR_NAME'));
    END IF;

    l_process := p_wf_process;

    -- 5. p_wf_item_type
    IF UPPER(p_wf_item_type) <> 'CNSCARPR' THEN
        wf_core.token('NAME',p_wf_item_type);
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_ITEM_TYPE'));
    END IF;

    l_itemType := p_wf_item_type;

    -- Create WF Process
    -- =================
    l_itemKey := p_start_header_id || '-' || p_end_header_id || '.' ||
                 wf_core.random;

    wf_engine.createprocess(itemtype    =>  p_wf_item_type,
                            itemkey     =>  l_itemKey,
                            process     =>  p_wf_process);

    -- Set Item Attributes
    -- ===================

    -- 1. start_header_id (NUMBER)
    -- ---------------------------
    wf_engine.setitemattrnumber(itemtype    => l_itemType,
                                itemkey     => l_itemKey,
                                aname       => 'START_HEADER_ID',
                                avalue      => p_start_header_id);

    -- 2. end_header_id (NUMBER)
    -- -------------------------
    wf_engine.setitemattrnumber(itemtype    => l_itemType,
                                itemkey     => l_itemKey,
                                aname       => 'END_HEADER_ID',
                                avalue      => p_end_header_id);

    -- 3. org_id (TEXT)
    -- ----------------
    -- get org_id
    l_orgId := fnd_profile.value('ORG_ID');

    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'ORG_ID',
                              avalue      => l_orgId);

    -- 4. trx_source (TEXT)
    -- --------------------
    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'TRX_SOURCE',
                              avalue      => p_trx_source);

    -- 5. rev_dist_func (TEXT)
    -- -----------------------
    BEGIN
        -- get application_id based on transaction source
        SELECT fa.application_id
        INTO   l_appId
        FROM   fnd_application fa
        WHERE  fa.application_short_name = UPPER(TRIM(p_trx_source));

        -- if not found, then set to -1 (custom/noop)
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_appId := -1;
    END;

    -- get profile CN_SCA_REV_NOT_100 value (app/site level only)
    l_revFunc := fnd_profile.value_specific
        (name               =>  G_PROFILE,
         application_id     =>  l_appId,
         org_id             =>  l_orgId,
         server_id          =>  fnd_global.server_id);

    -- if not found, raise exception
    IF (l_revFunc = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_NO_PROFILE_VAL'));
    END IF;

    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'REV_DIST_FUNC',
                              avalue      => l_revFunc);

    -- 6. online_flag (TEXT)
    -- ---------------------
    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'ONLINE_FLAG',
                              avalue      => 'N');

    -- Start WF Process
    -- ================
    wf_engine.startprocess(itemtype =>  l_itemType,
                           itemkey  =>  l_itemKey);

    -- End of API body

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_REV_DIST_PR',
                        l_itemKey);
        RAISE;

END START_PROCESS;

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
--   Exception Msgs.  : CN_SCA_WF_INVLD_TRX_SRC - Invalid transaction source.
--                      CN_SCA_WF_INVLD_PR_NAME - Invalid process name sqlplus apps/apps@cnxd1r11 @cnvscabs.pls
--                      CN_SCA_WF_INVLD_ITEM_TYPE - Invalid item type sqlplus apps/apps@cnxd1r11 @cnvscabb.plsname
-- End of comments
PROCEDURE START_PROCESS (
    p_start_date        IN date,
    p_end_date          IN date,
    p_trx_source        IN varchar2,
    p_org_id		IN number,
    p_wf_process        IN varchar2,
    p_wf_item_type      IN varchar2,
    x_wf_item_key       OUT NOCOPY varchar2
    )
IS
    -- Local Variables
    l_process varchar2(30);
    l_itemType varchar2(8);
    l_itemKey varchar2(240);
    l_save_threshold number;

    --l_orgId varchar2(30);

BEGIN

    -- Start of API body

    -- Validate input
    -- ==============

    -- Start/End Date validation is handled by caller

    -- 1. p_trx_source
    IF (p_trx_source = NULL) THEN
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_TRX_SRC'));
    END IF;

    -- 2. p_wf_process
    IF (UPPER(p_wf_process) <> 'CN_SCA_TRX_LOAD_PR') THEN
        wf_core.token('NAME',p_wf_process);
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_PR_NAME'));
    END IF;

    l_process := p_wf_process;

    -- 3. p_wf_item_type
    IF UPPER(p_wf_item_type) <> 'CNSCARPR' THEN
        wf_core.token('NAME',p_wf_item_type);
        wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_ITEM_TYPE'));
    END IF;

    l_itemType := p_wf_item_type;

    -- Modify WF Engine threshold to force deferal of process
    -- ======================================================
    l_save_threshold := wf_engine.threshold;
    wf_engine.threshold := -1;

    -- Create WF Process
    -- =================
    l_itemKey := TO_CHAR(p_start_date,'YYYY/MM/DD') || '-' ||
                 TO_CHAR(p_end_date,'YYYY/MM/DD') || '.' ||
                 wf_core.random;

    wf_engine.createprocess(itemtype    =>  p_wf_item_type,
                            itemkey     =>  l_itemKey,
                            process     =>  p_wf_process);

    -- Set Item Attributes
    -- ===================

    -- 1. start_date (DATE)
    -- --------------------
    wf_engine.setitemattrdate(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'START_DATE',
                              avalue      => p_start_date);

    -- 2. end_date (DATE)
    -- ------------------
    wf_engine.setitemattrdate(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'END_DATE',
                              avalue      => p_end_date);

    -- 3. org_id (TEXT)
    -- ----------------
    -- get org_id
    -- l_orgId := fnd_profile.value('ORG_ID');
    --l_orgId := p_org_id;

    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'ORG_ID',
                              avalue      => p_org_id);

    -- 4. trx_source (TEXT)
    -- --------------------
    -- set item attribute
    wf_engine.setitemattrtext(itemtype    => l_itemType,
                              itemkey     => l_itemKey,
                              aname       => 'TRX_SOURCE',
                              avalue      => p_trx_source);

    -- Start WF Process
    -- ================
    wf_engine.startprocess(itemtype =>  l_itemType,
                           itemkey  =>  l_itemKey);

    -- Restore WF Engine threshold
    -- ===========================
    wf_engine.threshold := l_save_threshold;

    -- Populate out param
    -- ==================
    x_wf_item_key := l_itemKey;

    -- End of API body

EXCEPTION

    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_TRX_LOAD_PR',
                        l_itemKey);
        RAISE;

END START_PROCESS;

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
    resultOut   OUT NOCOPY varchar2)
IS
BEGIN

    -- RUN mode: Normal process execution
    IF (funcMode = 'RUN') THEN
        IF UPPER(itemType) = 'CNSCARPR' THEN
            resultOut := 'CN_SCA_REV_DIST_PR';
            RETURN;
        ELSE
            resultOut := wf_engine.eng_error || ':' || wf_engine.eng_null;
            -- we do NOT return control to WF, but rather propagate an exception
            wf_core.token('NAME',itemType);
            wf_core.raise(FND_MESSAGE.get_string('CN','CN_SCA_WF_INVLD_ITEM_TYPE'));
        END IF;
    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    -- Any other mode but RUN
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_REV_DIST_PR',
                        'SELECTOR',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END SELECTOR;

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
    resultOut   OUT NOCOPY varchar2)
IS
    -- Local Variables
    l_revFunc varchar2(30);

BEGIN

    -- RUN mode
    IF (funcMode = 'RUN') THEN

            -- get rev_dist_func from item
            l_revFunc := wf_engine.getitemattrtext(itemtype    =>  itemType,
                                                   itemkey     =>  itemKey,
                                                   aname       =>  'REV_DIST_FUNC');

            -- return resultOut
            resultOut := wf_engine.eng_completed || ':' || l_revFunc;
            RETURN;

    END IF; -- funcMode = 'RUN'

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_REV_DIST_PR',
                        'REV_DIST_SELECT',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END REV_DIST_SELECT;

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
    resultOut   OUT NOCOPY varchar2)
IS
    -- Local Variables
    l_orgId         varchar2(30);
    l_revFunc       varchar2(30);
    l_scaBatchId    number;
    l_startHeaderId number;
    l_endHeaderId   number;
    l_onlineFlag    varchar2(1);
    l_return_status varchar2(1);

BEGIN

    IF (funcMode = 'RUN') THEN

        -- get attr ORG_ID
        l_orgId := wf_engine.getitemattrtext(itemtype   =>  itemType,
                                             itemkey    =>  itemKey ,
                                             aname      =>  'ORG_ID');

        -- set org context
        fnd_client_info.set_org_context(l_orgId);

        -- get attr online_flag
        l_onlineFlag := wf_engine.getitemattrtext(itemtype   =>  itemType,
                                                  itemkey    =>  itemKey ,
                                                  aname      =>  'ONLINE_FLAG');

        -- get attr and execute even distribution process according to online flag
        IF (l_onlineFlag = 'Y') THEN
            -- get attr sca_batch_id
            l_scaBatchId := wf_engine.getitemattrnumber(itemtype    =>  itemType,
                                                        itemkey     =>  itemKey ,
                                                        aname       =>  'SCA_BATCH_ID');

            -- call private procedure
            ONLINE_EVEN_REV_DIST (
                p_sca_batch_id  => l_scaBatchId,
                x_return_status => l_return_status);

        ELSIF (l_onlineFlag = 'N') THEN
            -- get attr start_header_id
            l_startHeaderId := wf_engine.getitemattrnumber(itemtype    =>  itemType,
                                                           itemkey     =>  itemKey ,
                                                           aname       =>  'START_HEADER_ID');

            -- get attr end_header_id
            l_endHeaderId := wf_engine.getitemattrnumber(itemtype    =>  itemType,
                                                         itemkey     =>  itemKey ,
                                                         aname       =>  'END_HEADER_ID');

            -- call private procedure
            BATCH_EVEN_REV_DIST (
                p_start_header_id => l_startHeaderId,
                p_end_header_id   => l_endHeaderId,
                x_return_status   => l_return_status);

        END IF;

        -- if not successful, raise exception
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_REV_DIST_PR',
                        'EVEN_REV_DIST',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END EVEN_REV_DIST;

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
    resultOut   OUT NOCOPY varchar2)
IS
    -- Local Variables
    l_orgId         varchar2(30);
    l_revFunc       varchar2(30);
    l_scaBatchId    number;
    l_startHeaderId number;
    l_endHeaderId   number;
    l_onlineFlag    varchar2(1);
    l_return_status varchar2(1);

BEGIN

    IF (funcMode = 'RUN') THEN

        -- get attr ORG_ID
        l_orgId := wf_engine.getitemattrtext(itemtype   =>  itemType,
                                             itemkey    =>  itemKey ,
                                             aname      =>  'ORG_ID');

        -- set org context
        fnd_client_info.set_org_context(l_orgId);

        -- get attr online_flag
        l_onlineFlag := wf_engine.getitemattrtext(itemtype   =>  itemType,
                                                  itemkey    =>  itemKey ,
                                                  aname      =>  'ONLINE_FLAG');

        -- get attr and execute weighted average distribution process according to online flag
        IF (l_onlineFlag = 'Y') THEN
            -- get attr sca_batch_id
            l_scaBatchId := wf_engine.getitemattrnumber(itemtype    =>  itemType,
                                                        itemkey     =>  itemKey ,
                                                        aname       =>  'SCA_BATCH_ID');

            -- call private procedure
            ONLINE_WTD_REV_DIST (
               p_sca_batch_id  => l_scaBatchId,
               x_return_status => l_return_status);

        ELSIF (l_onlineFlag = 'N') THEN

            -- get attr start_header_id
            l_startHeaderId := wf_engine.getitemattrnumber(itemtype    =>  itemType,
                                                           itemkey     =>  itemKey ,
                                                           aname       =>  'START_HEADER_ID');

            -- get attr end_header_id
            l_endHeaderId := wf_engine.getitemattrnumber(itemtype    =>  itemType,
                                                         itemkey     =>  itemKey ,
                                                         aname       =>  'END_HEADER_ID');

            -- call private procedure
            BATCH_WTD_REV_DIST (
               p_start_header_id => l_startHeaderId,
               p_end_header_id   => l_endHeaderId,
               x_return_status   => l_return_status);

        END IF;

        -- if not successful, raise exception
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_REV_DIST_PR',
                        'WTD_REV_DIST',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END WTD_REV_DIST;

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
    resultOut   OUT NOCOPY varchar2)
IS
    -- Local Variables
    l_trxSrc varchar2(30);

BEGIN

    -- RUN mode
    IF (funcMode = 'RUN') THEN

            -- get rev_dist_func from item
            l_trxSrc := wf_engine.getitemattrtext(itemtype    =>  itemType,
                                                  itemkey     =>  itemKey,
                                                  aname       =>  'TRX_SOURCE');

            -- if l_trxSrc is NOT CN, then set to 'CUSTOM'
            IF (l_trxSrc <> 'CN') THEN
                l_trxSrc := 'CUSTOM';
            END IF;

            -- return resultOut
            resultOut := wf_engine.eng_completed || ':' || l_trxSrc;
            RETURN;

    END IF; -- funcMode = 'RUN'

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_TRX_LOAD_PR',
                        'TRX_LOAD_SELECT',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END TRX_LOAD_SELECT;

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
    resultOut   OUT NOCOPY varchar2)
IS
    -- Local Variables
    l_startDate date;
    l_endDate date;
    l_orgId varchar2(30);
    l_return_status varchar2(1);
    l_msg_count number;
    l_msg_data varchar2(2000);
    l_process_audit_id number;

BEGIN

    -- RUN mode
    IF (funcMode = 'RUN') THEN

        -- Get Item Attributes
        -- ===================

        -- get start_date
        l_startDate := wf_engine.getitemattrdate(itemtype   =>  itemType,
                                                 itemkey    =>  itemKey,
                                                 aname      =>  'START_DATE');

        -- get end_date
        l_endDate := wf_engine.getitemattrdate(itemtype   =>  itemType,
                                               itemkey    =>  itemKey,
                                               aname      =>  'END_DATE');

        -- get attr ORG_ID
        l_orgId := wf_engine.getitemattrtext(itemtype   =>  itemType,
                                             itemkey    =>  itemKey ,
                                             aname      =>  'ORG_ID');

        -- set org context
        fnd_client_info.set_org_context(l_orgId);

        -- call private autonomous procedure
        CONC_CN_TRX_LOAD(
            p_org_id           => l_orgId,
            p_start_date       => l_startDate,
            p_end_date         => l_endDate,
            x_return_status    => l_return_status,
            x_msg_count        => l_msg_count,
            x_msg_data         => l_msg_data,
            x_process_audit_id => l_process_audit_id);

        -- set attr PROCESS_AUDIT_ID (if not NULL, regardless of return status)
        IF (l_process_audit_id <> NULL) THEN
            wf_engine.setitemattrnumber(itemtype => itemType,
                                        itemkey  => itemKey,
                                        aname    => 'PROCESS_AUDIT_ID',
                                        avalue   => l_process_audit_id);
        END IF;

        -- if not successful, raise exception
        IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- return resultOut
        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF; -- funcMode = 'RUN'

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_PKG',
                        'CN_SCA_TRX_LOAD_PR',
                        'CN_TRX_LOAD',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode,
                        l_msg_data,
                        l_process_audit_id);
        RAISE;

END CN_TRX_LOAD;

END CN_SCA_WF_PKG;

/
