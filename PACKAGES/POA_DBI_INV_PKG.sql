--------------------------------------------------------
--  DDL for Package POA_DBI_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_INV_PKG" AUTHID CURRENT_USER
/* $Header: poadbiinvs.pls 115.0 2003/10/06 09:47:31 bthammin noship $ */
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
-- ------------------------------- ---- -----    -----------------------------
-- p_param                           Y  TABLE    The TABLE type in which all
--                                               the parameters are passed
-- x_custom_sql                      Y  VARCHAR2 SQL Statement is build
--                                               with this variable based on
--                                               the options the user selects
--                                               on the Reports
-- x_custom_output                   Y  TABLE
--
-- Post Success:
--
-- Out Parameters:
-- Name                            In/Out Type     Description
-- ------------------------------- ------ -------- --------------------------
-- x_custom_sql                    OUT    VARCHAR2 SQL Statement is built and
--                                                 passed back with the
--                                                 parameters passed from the
--                                                 Reports page.
-- x_custom_outupt                 OUT    TABLE
--
-- Post Failure:
--
-- {End of Comments}
--
PROCEDURE status_sql(p_param            IN          BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql       OUT NOCOPY  VARCHAR2
                    ,x_custom_output    OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
--
-- -----------------------------------------------------------------------
-- |-----------------------------< trend_sql >---------------------------|
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
-- p_param                           Y  TABLE    The TABLE type in which all
--                                               the parameters are passed
-- x_custom_sql                      Y  VARCHAR2 SQL Statement is build
--                                               with this variable based on
--                                               the options the user selects
--                                               on the Reports
-- x_custom_output                   Y  TABLE
--
-- Post Success:
--
-- Out Parameters:
-- Name                            In/Out Type     Description
-- ------------------------------- ------ -------- -------------------------
-- x_xustom_sql                    OUT    VARCHAR2 SQL Statement is built and
--                                                 passed back with the
--                                                 parameters passed from the
--                                                 Reports page.
-- x_custom_output                 OUT    TABLE
-- Post Failure:
--
-- {End of Comments}
--
PROCEDURE trend_sql(p_param         in          BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql    OUT NOCOPY  VARCHAR2
                   ,x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL);
--
END poa_dbi_inv_pkg;

 

/
