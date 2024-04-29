--------------------------------------------------------
--  DDL for Package AD_CONC_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_CONC_UTILS_PKG" AUTHID CURRENT_USER AS
-- $Header: adcmutls.pls 115.0 2004/06/24 23:28:36 athies noship $


    CONC_SUCCESS   CONSTANT NUMBER := 0;
    CONC_WARNING   CONSTANT NUMBER := 1;
    CONC_FAIL      CONSTANT NUMBER := 2;

    --
    -- do not change the CHR(0) as FND_SUBMIT requires it.
    --
    PROCEDURE submit_subrequests(
        X_errbuf                   out nocopy varchar2,
        X_retcode                  out nocopy varchar2,
        X_WorkerConc_app_shortname  in varchar2,
        X_WorkerConc_progname       in varchar2,
        X_Batch_Size                in number,
        X_Num_Workers               in number,
        X_Argument4                 in varchar2 default null,
        X_Argument5                 in varchar2 default null,
        X_Argument6                 in varchar2 default null,
        X_Argument7                 in varchar2 default null,
        X_Argument8                 in varchar2 default null,
        X_Argument9                 in varchar2 default null,
        X_Argument10                in varchar2 default null);

END;

 

/
