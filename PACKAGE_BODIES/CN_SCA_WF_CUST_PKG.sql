--------------------------------------------------------
--  DDL for Package Body CN_SCA_WF_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_WF_CUST_PKG" AS
/* $Header: cnpscacb.pls 115.2 2003/10/09 21:39:16 mnativ noship $ */

-- Start of comments
--    API name          : CUST_REV_DIST
--    Type              : Public.
--    Function          :
--    Pre-reqs          : None.
--    Parameters        :
--    IN                : itemType      IN  VARCHAR2    Required
--                        itemKey       IN  VARCHAR2    Required
--                        actId         IN  NUMBER      Required
--                        funcMode      IN  VARCHAR2    Required
--    OUT               : resultOut     OUT VARCHAR2
--    Version           : Current version   1.0
--                        Previous version
--                        Initial version   1.0
--    Notes             : Executes CUSTOM Revenue Distribution Function. Called
--                        by the WF Engine.
--                        itemType  - A valid item type from WF_ITEM_TYPES table.
--                        itemKey   - A string generated from application object's
--                                    PRIMARY key.
--                        actId     - The function activity (instance ID).
--                        funcMode  - Run/Cancel.
--                        resultOut - 'COMPLETE:'.
-- End of comments
PROCEDURE CUST_REV_DIST (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2)
IS
BEGIN

    -- RUN mode
    IF (funcMode = 'RUN') THEN

        -- =======================
        -- INSERT CUSTOM CODE HERE
        -- =======================

        -- return resultOut, and return control to WF
        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF; -- funcMode = 'RUN'

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        -- return resultOut, and return control to WF
        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_CUST_PKG',
                        'CN_SCA_REV_DIST_PR',
                        'CUST_REV_DIST',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END CUST_REV_DIST;

-- Start of comments
--    API name          : CUST_TRX_LOAD
--    Type              : Public.
--    Function          :
--    Pre-reqs          : None.
--    Parameters        :
--    IN                : itemType      IN  VARCHAR2    Required
--                        itemKey       IN  VARCHAR2    Required
--                        actId         IN  NUMBER      Required
--                        funcMode      IN  VARCHAR2    Required
--    OUT               : resultOut     OUT VARCHAR2
--    Version           : Current version   1.0
--                        Previous version
--                        Initial version   1.0
--    Notes             : Executes CUSTOM Transaction Loading Function. Called
--                        by the WF Engine.
--                        itemType  - A valid item type from WF_ITEM_TYPES table.
--                        itemKey   - A string generated from application object's
--                                    PRIMARY key.
--                        actId     - The function activity (instance ID).
--                        funcMode  - Run/Cancel.
--                        resultOut - 'COMPLETE:'.
-- End of comments
PROCEDURE CUST_TRX_LOAD (
    itemType    IN  varchar2,
    itemKey     IN  varchar2,
    actId       IN  number,
    funcMode    IN  varchar2,
    resultOut   OUT NOCOPY varchar2)
IS
BEGIN

    -- RUN mode
    IF (funcMode = 'RUN') THEN

        -- =======================
        -- INSERT CUSTOM CODE HERE
        -- =======================

        -- return resultOut, and return control to WF
        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF; -- funcMode = 'RUN'

    -- CANCEL mode
    IF (funcMode = 'CANCEL') THEN

        -- return resultOut, and return control to WF
        resultOut := wf_engine.eng_completed || ':' || wf_engine.eng_null;
        RETURN;

    END IF;

    -- ANY OTHER mode (NOT implemented)
    resultOut := wf_engine.eng_null;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        wf_core.context('CN_SCA_WF_CUST_PKG',
                        'CN_SCA_TRX_LOAD_PR',
                        'CUST_TRX_LOAD',
                        itemType,
                        itemKey,
                        TO_CHAR(actId),
                        funcMode);
        RAISE;

END CUST_TRX_LOAD;

END CN_SCA_WF_CUST_PKG;

/
