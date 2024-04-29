--------------------------------------------------------
--  DDL for Package Body JA_CN_GSSM_EXP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_GSSM_EXP_PKG" AS
--$Header: JACNGSEB.pls 120.1.12000000.1 2007/08/13 14:09:39 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JACNGSEB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     This package is used for GSSM Export, for Enterprise and          |
--|     Public Sector in the CNAO Project.                                |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|      PROCEDURE GSSM_Export                      PUBLIC                |
--|                                                                       |
--| HISTORY                                                               |
--	    05/17/2006     Andrew Liu          Created                       |
--+======================================================================*/

  l_module_prefix                VARCHAR2(100) :='JA_CN_GSSM_EXP_PKG';

  --==========================================================================
  --  PROCEDURE NAME:
  --    GSSM_Export                   PUBLIC
  --
  --  DESCRIPTION:
  --      This procedure calls GSSM Export program to export GSSM for
  --      Enterprise.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_GSSM_TYPE             VARCHAR2            Type of ENT/PUB
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --	    05/17/2006     Andrew Liu          Created
  --===========================================================================
  PROCEDURE GSSM_Export( errbuf          OUT NOCOPY VARCHAR2
                        ,retcode         OUT NOCOPY VARCHAR2
                        ,P_GSSM_TYPE     IN VARCHAR2
  ) IS
    l_dbg_level                         NUMBER        :=FND_LOG.G_Current_Runtime_Level;
    l_proc_level                        NUMBER        :=FND_LOG.Level_Procedure;
    l_proc_name                         VARCHAR2(100) :='GSSM_Export';

    JA_CN_NO_DATA_FOUND                 exception;
    l_msg_no_data_found                 varchar2(2000); --'*****No data found*****';

    l_lookup                            varchar2(100);
    l_line                              FND_FLEX_VALUES_TL.DESCRIPTION%TYPE;
    l_row_count                         NUMBER;  --count of rows

    --Cursor to get all GSSM.
    CURSOR c_gssm IS
    SELECT DECODE(SUBSTR(B.LOOKUP_CODE,LENGTH(B.LOOKUP_CODE)-2,3)
             , '999', ''   --For the blank lines
             ,B.DESCRIPTION
           )
      FROM FND_LOOKUP_VALUES B
     WHERE B.LANGUAGE = userenv('LANG')
       AND b.lookup_type = l_lookup     --using variable l_lookup
     ORDER BY B.LOOKUP_CODE
          ;

    /*SELECT T.DESCRIPTION                       line
      FROM FND_FLEX_VALUES_TL                  T
          ,FND_FLEX_VALUES                     B
     WHERE B.FLEX_VALUE_ID = T.FLEX_VALUE_ID
       AND T.LANGUAGE = userenv('LANG')
       AND B.FLEX_VALUE_SET_ID=
          (SELECT V.FLEX_VALUE_SET_ID
             FROM FND_FLEX_VALUE_SETS V
            WHERE V.FLEX_VALUE_SET_NAME LIKE l_lookup --using variable l_lookup
          )
     ORDER BY B.FLEX_VALUE
          ;*/
  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.begin'
                     ,'Enter procedure'
                    );
      FND_LOG.String( l_proc_level
                     ,l_module_prefix||'.'||l_proc_name||'.parameters'
                     ,'P_GSSM_TYPE '||P_GSSM_TYPE
                    );
    END IF;  --(l_proc_level >= l_dbg_level)

    --Check Profile
    IF NOT(JA_CN_UTILITY.Check_Profile)
    THEN
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF;

    IF P_GSSM_TYPE = 'ENT'
    THEN
      l_lookup := 'JA_CN_GSSM_ENT';
    ELSIF P_GSSM_TYPE = 'PUB'
    THEN
      l_lookup := 'JA_CN_GSSM_PUB';
    END IF;

  	--Export all lines into the format predefined flat file
  	l_row_count := 0;
  	OPEN c_gssm;
  	LOOP
  	  FETCH c_gssm INTO l_line;
  	  EXIT WHEN c_gssm%NOTFOUND;
	    l_row_count := l_row_count+1;

      FND_FILE.put_line( FND_FILE.output
                        ,l_line
                       );
  	END LOOP;
  	CLOSE c_gssm;

  	IF l_row_count = 0 --No data found
    THEN
  	  raise JA_CN_NO_DATA_FOUND;
  	END IF;

    retcode := 0;
    errbuf  := '';
  	EXCEPTION
      WHEN JA_CN_NO_DATA_FOUND THEN
        FND_MESSAGE.Set_Name( APPLICATION => 'JA'
                             ,NAME => 'JA_CN_NO_DATA_FOUND'
                            );
        l_msg_no_data_found := FND_MESSAGE.Get;

        --FND_FILE.put_line(FND_FILE.output, l_msg_no_data_found);
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.JA_CN_NO_DATA_FOUND '
                         ,l_msg_no_data_found);
        END IF;
        retcode := 1;
        errbuf  := l_msg_no_data_found;
      WHEN OTHERS THEN
        IF (l_proc_level >= l_dbg_level)
        THEN
          FND_LOG.String( l_proc_level
                         ,l_module_prefix||'.'||l_proc_name||'.Other_Exception '
                         ,SQLCODE||':'||SQLERRM
                        );
        END IF;  --(l_proc_level >= l_dbg_level)
        retcode := 2;
        errbuf  := SQLCODE||':'||SQLERRM;

  END GSSM_Export;
BEGIN
  -- Initialization
  null;
END JA_CN_GSSM_EXP_PKG;

/
