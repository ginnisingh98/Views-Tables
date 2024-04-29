--------------------------------------------------------
--  DDL for Package Body OKL_STREAMS_SEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STREAMS_SEC_PVT" AS
/* $Header: OKLSSECB.pls 120.0.12010000.1 2008/08/06 05:06:47 sshinde noship $ */

  G_REQUIRED_VALUE       CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_COL_NAME_TOKEN       CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_REPORT_STREAMS_YN    VARCHAR2(1) := 'N';

-- Start of comments
--
-- Procedure Name       : STREAMS_REPO_POLICY
-- Description          : Creates predicate for multi GAAP reporting policy
-- Business Rules       :
-- Parameters           : p_owner and p_obj_name
-- Version              : 1.0
-- History              : APAUL -- Created
-- End of comments

    FUNCTION STREAMS_REPO_POLICY (
                          p_owner         IN          VARCHAR2,
                          p_obj_name      IN          VARCHAR2)
    RETURN VARCHAR2 AS
      l_predicate VARCHAR2 (200);
    BEGIN
      IF G_REPORT_STREAMS_YN = 'Y' THEN
         l_predicate := 'REPO_FLAG = ''Y''';
      ELSE
         l_predicate := 'REPO_FLAG = ''N''';
      END IF;
      RETURN (l_predicate);
    END STREAMS_REPO_POLICY;


-- Start of comments
--
-- Procedure Name       : SET_REPO_STREAMS
-- Description          : Sets the reporting strram indicator
-- Business Rules       :
-- Version              : 1.0
-- History              : APAUL -- Created
-- End of comments

    PROCEDURE SET_REPO_STREAMS AS
    BEGIN
       G_REPORT_STREAMS_YN := 'Y';
    END;


-- Start of comments
--
-- Procedure Name       : RESET_REPO_STREAMS
-- Description          : Resets the reporting strram indicator
-- Business Rules       :
-- Version              : 1.0
-- History              : APAUL -- Created
-- End of comments

    PROCEDURE RESET_REPO_STREAMS AS
    BEGIN
       G_REPORT_STREAMS_YN := 'N';
    END;

    FUNCTION GET_STREAMS_POLICY RETURN VARCHAR2 IS
    BEGIN
      IF G_REPORT_STREAMS_YN = 'Y' THEN
        return('REPORT');
      ELSE
        return('PRIMARY');
      END IF;
    END;

END;

/
