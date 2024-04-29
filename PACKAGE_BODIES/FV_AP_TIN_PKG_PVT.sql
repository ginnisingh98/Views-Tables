--------------------------------------------------------
--  DDL for Package Body FV_AP_TIN_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_AP_TIN_PKG_PVT" AS
-- $Header: FVXAPTNB.pls 120.4 2003/12/17 21:21:31 ksriniva noship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_AP_TIN_PKG_PVT.';

PROCEDURE TIN_VALIDATE(FIELD_NAME     IN varchar2,
                       PROC_RESULT    OUT NOCOPY varchar2,
                       RESULT_MESSAGE OUT NOCOPY varchar2) AS
  l_module_name VARCHAR2(200) := g_module_name || 'TIN_VALIDATE';
  l_errbuf      VARCHAR2(1024);
BEGIN

    IF (instr(to_char(to_number(FIELD_NAME)),'.')=0) and (length(FIELD_NAME)=9)
       and (to_number(FIELD_NAME)>0) and (instr(FIELD_NAME,'.') = 0) THEN

       -- Value can only be a nonzero nine digit value between 000000001 and
       -- 999999999

       PROC_RESULT := 'P';
       RESULT_MESSAGE := null;
    ELSE

       PROC_RESULT := 'F';
       RESULT_MESSAGE := 'AP_FV_TIN_VALIDATE';

    END IF;

EXCEPTION
    WHEN OTHERS then
       l_errbuf := SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
       PROC_RESULT := 'F';
       RESULT_MESSAGE := 'AP_FV_TIN_VALIDATE';

END TIN_VALIDATE;
END FV_AP_TIN_PKG_PVT;

/
