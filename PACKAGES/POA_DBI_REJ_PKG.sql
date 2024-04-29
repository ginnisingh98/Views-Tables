--------------------------------------------------------
--  DDL for Package POA_DBI_REJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_REJ_PKG" AUTHID CURRENT_USER
/* $Header: poadbirejs.pls 115.0 2003/10/06 09:45:17 bthammin noship $ */
AS
--
-- -----------------------------------------------------------------------
-- |----------------------------< status_sql >---------------------------|
-- -----------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--
--
-- Prerequisites:
--
-- Parameters:
-- Name                            Reqd Type     Description
-- ------------------------------- ---- ----     -----------------------------
-- P_PARAM                          Y   TABLE    All the parameters are passed
--                                               using this table.
-- X_CUSTOM_SQL                     Y   VARCHAR2 The SQL Statement is built and
--                                               passed back using this variable
-- X_CUSTOM_OUTPUT                  Y   TABLE
--
-- Post Success:
--
-- Out Parameters:
-- Name                            In/Out Type     Description
-- ------------------------------- ------ -------- -------------------------------
-- X_CUSTOM_SQL                    OUT    VARCHAR2 The SQL Statement is built and
--                                                 passed back using this variable
-- X_CUSTOM_OUTPUT                 OUT    TABLE
--
-- Post Failure:
--
-- {End of Comments}
--
PROCEDURE status_sql(p_param            IN         BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql       OUT NOCOPY VARCHAR2
                    ,x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
-- -----------------------------------------------------------------------
-- |----------------------------< rej_rsn_sql >--------------------------|
-- -----------------------------------------------------------------------
-- {Start of Comments}
-- Description:
--
--
-- Prerequisites:
--
-- Parameters:
-- Name                            Reqd Type Description
-- ------------------------------- ---- ---- -----------------------------
-- P_PARAM                          Y   IN   BIS_PMV_PAGE_PARAMETER_TBL
--                                           type
-- X_CUSTOM_SQL                     Y   OUT
-- X_CUSTOM_OUTPUT                  Y   OUT
--
-- Post Success:
--
-- Out Parameters:
-- Name                            In/Out Type     Description
-- ------------------------------- ------ -------- -------------------------
-- X_CUSTOM_SQL                    OUT    VARCHAR2 Returns the SQL Statement
-- X_CUSTOM_OUTPUT                 OUT    TABLE    Returns the
--
-- Post Failure:
--
-- {End of Comments}
--
PROCEDURE rej_rsn_sql(p_param           IN         BIS_PMV_PAGE_PARAMETER_TBL
                     ,x_custom_sql      OUT NOCOPY VARCHAR2
                     ,x_custom_output   OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL);
--
END poa_dbi_rej_pkg;

 

/
