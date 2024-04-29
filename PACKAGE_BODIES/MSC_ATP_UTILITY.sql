--------------------------------------------------------
--  DDL for Package Body MSC_ATP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_UTILITY" AS
/* $Header: MSCASDUB.pls 120.1 2007/12/12 10:19:22 sbnaik ship $ */

PROCEDURE Close_DbLink(p_DbLink varchar2) IS
  lv_sql_stmt          VARCHAR2(2000);
  DBLINK_NOT_OPEN      EXCEPTION;
  PRAGMA               EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
BEGIN
  IF p_DbLink <> ' ' then
    -- mark distributed transaction boundary
    -- will need to do a manual clean up (commit) of the distributed
    -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
    commit;

    lv_sql_stmt := 'alter session close database link ' ||p_DbLink;

    EXECUTE IMMEDIATE lv_sql_stmt;

  END IF;
EXCEPTION
  WHEN DBLINK_NOT_OPEN THEN
    NULL;
END Close_DbLink;


PROCEDURE Derive_Profile_Values_Frm_Dest (p_SqlErrM OUT NOCOPY VARCHAR2
                               , p_Profile_Values   OUT NOCOPY VARCHAR2
                               , p_Profile_Names     IN VARCHAR2
                               , p_Delimiter         IN VARCHAR2)
IS
  l_Start_Location PLS_INTEGER    := 1;
  l_Length         PLS_INTEGER    := 1;
  l_Profile_Names  VARCHAR2(1000) := LTRIM(p_Profile_Names||p_Delimiter,p_Delimiter);
  l_Profile_values VARCHAR2(1000) := NULL;
  l_Delimiter      VARCHAR2(10)   := NVL(p_Delimiter,',');
BEGIN
  LOOP
    l_Length := INSTR(l_Profile_Names,l_Delimiter,l_Start_Location,1) - l_Start_Location;
    EXIT WHEN l_Length < 1;
    l_Profile_Values := l_Profile_Values||FND_PROFILE.VALUE(SUBSTR(l_Profile_Names,l_Start_Location,l_Length))||l_Delimiter;
    l_Start_Location := l_Start_Location + l_Length + 1;
  END LOOP;
  p_Profile_Values := l_Profile_Values;
EXCEPTION
  WHEN OTHERS THEN
    p_SqlErrM := sqlerrm||' (Problem at destination)';
END Derive_Profile_Values_Frm_Dest;


PROCEDURE Derive_Profile_Values_Frm_Sour (p_SqlErrM OUT NOCOPY VARCHAR2
                                 , p_Profile_Values OUT NOCOPY VARCHAR2
                                   , p_Profile_Names IN VARCHAR2
                                       , p_Delimiter IN VARCHAR2
                                          , p_DbLink IN VARCHAR2)
IS
  l_SqlStmt VARCHAR2(2000);
BEGIN
  p_SqlErrM := NULL;

  l_SqlStmt :=
 'BEGIN MSC_ATP_UTILITY.Derive_Profile_Values_Frm_Dest'||p_DbLink||' (:p_sqlerrm, :l_Profile_Values, :l_Profile_Names, :l_Delimiter); END;';

  EXECUTE IMMEDIATE l_SqlStmt
  USING out p_SqlErrM, out p_Profile_Values, p_Profile_Names, p_Delimiter;

  Close_DbLink(p_DbLink);
EXCEPTION
  WHEN OTHERS THEN
    p_SqlErrM := sqlerrm||' (Problem at source)';
    Close_DbLink(p_DbLink);
END Derive_Profile_Values_Frm_Sour;

END MSC_ATP_UTILITY;

/
