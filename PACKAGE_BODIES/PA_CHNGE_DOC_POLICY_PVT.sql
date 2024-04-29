--------------------------------------------------------
--  DDL for Package Body PA_CHNGE_DOC_POLICY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CHNGE_DOC_POLICY_PVT" AS
--$Header: PACIPOLB.pls 120.2.12010000.2 2009/10/06 13:17:38 jravisha noship $

  G_CHNGE_DOC_VERS_YN    VARCHAR2(1) := 'Y';
  G_SUPP_AUDT_FLAG_YN    VARCHAR2(1) := 'Y';

-- Start of comments
--
-- Procedure Name       : SUPP_AUDT_POLICY
-- Description          : Creates predicate for Change doc versioning
-- Business Rules       :
-- Parameters           : p_owner and p_obj_name
-- Version              : 1.0
-- History              : smereddy -- Created
-- End of comments

    FUNCTION SUPP_AUDT_POLICY (
                          p_owner         IN          VARCHAR2,
                          p_obj_name      IN          VARCHAR2)
    RETURN VARCHAR2 AS
      l_predicate VARCHAR2 (200);
    BEGIN
      IF G_SUPP_AUDT_FLAG_YN = 'Y' THEN
         l_predicate := 'CURRENT_AUDIT_FLAG = ''Y''';
      ELSE
         l_predicate := 'CURRENT_AUDIT_FLAG = ''N''';
      END IF;
      RETURN (l_predicate);
    END SUPP_AUDT_POLICY;

-- Start of comments
--
-- Procedure Name       : SET_CHNGE_DOC_VERS
-- Description          : Sets policy context for cd versioning
-- Business Rules       :
-- Version              : 1.0
-- History              : smereddy -- Created
-- End of comments

    PROCEDURE SET_SUPP_AUDT AS
    BEGIN
       G_SUPP_AUDT_FLAG_YN := 'N';
    END;


-- Start of comments
--
-- Procedure Name       : RESET_SUPP_AUDT
-- Description          : Resets the policy context for cd versioning
-- Business Rules       :
-- Version              : 1.0
-- History              : smereddy -- Created
-- End of comments

    PROCEDURE RESET_SUPP_AUDT AS
    BEGIN
       G_SUPP_AUDT_FLAG_YN := 'Y';
    END;

    FUNCTION GET_SUPP_AUDT_POLICY RETURN VARCHAR2 IS
    BEGIN
      IF G_SUPP_AUDT_FLAG_YN = 'Y' THEN
        return 'Y';
      ELSE
        return 'N';
      END IF;
    END;


    FUNCTION CHNGE_DOC_VERS_POLICY (
                          p_owner         IN          VARCHAR2,
                          p_obj_name      IN          VARCHAR2)
    RETURN VARCHAR2 AS
      l_predicate VARCHAR2 (200);
    BEGIN
      IF G_CHNGE_DOC_VERS_YN = 'Y' THEN
         l_predicate := 'CURRENT_VERSION_FLAG = ''Y''';
      ELSE
       IF G_CHNGE_DOC_VERS_YN = 'N' THEN
         l_predicate := 'CURRENT_VERSION_FLAG = ''N''';
         ELSE
         l_predicate := 'CURRENT_VERSION_FLAG in (''N'',''Y'')';
       END IF;
      END IF;
      RETURN (l_predicate);
    END CHNGE_DOC_VERS_POLICY;

-- Start of comments
--
-- Procedure Name       : SET_CHNGE_DOC_VERS
-- Description          : Sets policy context for cd versioning
-- Business Rules       :
-- Version              : 1.0
-- History              : smereddy -- Created
-- End of comments

    PROCEDURE SET_CHNGE_DOC_VERS AS
    BEGIN
       G_CHNGE_DOC_VERS_YN := 'N';
    END;


-- Start of comments
--
-- Procedure Name       : RESET_CHNGE_DOC_VERS
-- Description          : Resets the policy context for cd versioning
-- Business Rules       :
-- Version              : 1.0
-- History              : smereddy -- Created
-- End of comments

    PROCEDURE RESET_CHNGE_DOC_VERS AS
    BEGIN
       G_CHNGE_DOC_VERS_YN := 'Y';
    END;

-- Start of comments
--
-- Procedure Name       : ALL_CHNGE_DOC_VERS
-- Description          : Resets the policy context for cd versioning
-- Business Rules       :
-- Version              : 1.0
-- History              : jravisha  -- Created
-- End of comments

    PROCEDURE ALL_CHNGE_DOC_VERS AS
    BEGIN
       G_CHNGE_DOC_VERS_YN := 'A';
    END;


    FUNCTION GET_CHNGE_DOC_VERS_POLICY RETURN VARCHAR2 IS
    BEGIN
      IF G_CHNGE_DOC_VERS_YN = 'Y' THEN
        return 'Y';
      ELSE
        return 'N';
      END IF;
    END;

END PA_CHNGE_DOC_POLICY_PVT;

/
