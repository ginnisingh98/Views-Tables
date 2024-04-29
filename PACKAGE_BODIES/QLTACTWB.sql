--------------------------------------------------------
--  DDL for Package Body QLTACTWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTACTWB" as
/* $Header: qltactwb.plb 115.6 2004/02/18 14:57:47 suramasw ship $ */

-- 2/8/95 - CREATED
-- Kevin Wiggen

--  This is a wrapper for DO_ACTIONS.  It is needed for the concurrent
--  manager to run
--

  -- Added ARGUMENT2 in the signature of WRAPPER.
  -- ARGUMENT2 will get the value IMPORT when called from qlttrawb.plb
  -- Bug 3273447. suramasw

  PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                    RETCODE OUT NOCOPY NUMBER,
                    ARGUMENT1 IN NUMBER,
                    ARGUMENT2 IN VARCHAR2) IS

   X_RETURN BOOLEAN;

BEGIN

    -- Bug 1580498.  This concurrent program always passes
    -- TXN_HEADER_ID as argument to do_actions.  This is not correct
    -- in the api situation.  In order to make minimal impact to
    -- testing and release, api is now passing a negative collection ID
    -- to qltactwb to indicate COLLECTION_ID instead of TXN_HEADER_ID
    -- be passed to the do_actions function.
    -- bso Thu Jan 11 19:26:24 PST 2001

    IF ARGUMENT1 < 0 THEN
        X_RETURN  :=  QLTDACTB.DO_ACTIONS(
            x_txn_header_id => -ARGUMENT1,
            x_concurrent => 1,
            x_passed_id_name => 'COLLECTION_ID');
    ELSE
    -- Modified the call to do_actions by making the value of
    -- ARGUMENT2 to be passed to x_argument in do_actions.
    -- commented the existing call to do_actions.
    -- Bug 3273447. suramasw

        X_RETURN  :=  QLTDACTB.DO_ACTIONS(
            x_txn_header_id => ARGUMENT1,
            x_concurrent    => 1,
            x_argument      => ARGUMENT2);

        -- X_RETURN  :=  QLTDACTB.DO_ACTIONS(ARGUMENT1, 1);
    END IF;

        COMMIT;

        IF NOT X_RETURN THEN
           FND_MESSAGE.SET_NAME('QA','QA_ACTIONS_FAILED');
           APP_EXCEPTION.RAISE_EXCEPTION;
        ELSE
           RETCODE := 0;
           ERRBUF := '';
        END IF;
END WRAPPER;


END QLTACTWB;


/
