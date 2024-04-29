--------------------------------------------------------
--  DDL for Package OKC_REP_CONTRACT_TEXT_IDX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_REP_CONTRACT_TEXT_IDX_PVT" AUTHID DEFINER AS
/* $Header: OKCVREPSRMDS.pls 120.1 2005/08/22 10:02:51 dzima noship $ */

-- Start of comments
--API name      : okc_rep_ver_md
--Type          : Private.
--Function      : Procedure to collect metadata for Repository contract
--Pre-reqs      : None.
--Parameters    :
--IN            : r_id         IN ROWID           Required
--              : md_lob       IN OUT NOCOPY CLOB Required
--Note          :
-- End of comments

PROCEDURE okc_rep_con_md(
  r_id IN ROWID,
  md_lob IN OUT NOCOPY CLOB);

-- Start of comments
--API name      : okc_rep_ver_md
--Type          : Private.
--Function      : Procedure to collect metadata for Repository contract versions
--Pre-reqs      : None.
--Parameters    :
--IN            : r_id         IN ROWID           Required
--              : md_lob       IN OUT NOCOPY CLOB Required
--Note          :
-- End of comments
PROCEDURE okc_rep_ver_md(
  r_id IN ROWID,
  md_lob IN OUT NOCOPY CLOB);

END;

 

/

  GRANT EXECUTE ON "APPS"."OKC_REP_CONTRACT_TEXT_IDX_PVT" TO "CTXSYS";
