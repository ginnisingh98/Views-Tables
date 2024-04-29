--------------------------------------------------------
--  DDL for Package IEC_CRITERIA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_CRITERIA_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: IECCRUTS.pls 115.1 2003/08/22 20:41:23 hhuang noship $ */

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Append_SubsetCriteriaClause
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Append a SQL representation of the subset criteria
--                to a collection of VARCHAR2S.  This query, represented
--                as DBMS_SQL.VARCHAR2S can be executed via DBMS_SQL.
--
--  Parameters  : p_source_id            IN     NUMBER                       Required
--                p_record_filter_id     IN     NUMBER                       Required
--                p_source_type_view     IN     VARCHAR2                     Required
--                x_criteria_sql         IN OUT DBMS_SQL.VARCHAR2S           Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Append_SubsetCriteriaClause
   ( p_source_id            IN            NUMBER
   , p_subset_id            IN            NUMBER
   , p_source_type_view     IN            VARCHAR2
   , x_criteria_sql         IN OUT NOCOPY DBMS_SQL.VARCHAR2S
   , x_return_code             OUT NOCOPY VARCHAR2
   );

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Append_RecFilterCriteriaClause
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Append a SQL representation of the record filter criteria
--                to a collection of VARCHAR2s.  This query, represented
--                as DBMS_SQL.VARCHAR2S can be executed via DBMS_SQL.
--
--  Parameters  : p_source_id            IN     NUMBER                       Required
--                p_record_filter_id     IN     NUMBER                       Required
--                p_source_type_view     IN     VARCHAR2                     Required
--                x_criteria_sql         IN OUT DBMS_SQL.VARCHAR2S           Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Append_RecFilterCriteriaClause
   ( p_source_id            IN            NUMBER
   , p_record_filter_id     IN            NUMBER
   , p_source_type_view     IN            VARCHAR2
   , x_criteria_sql         IN OUT NOCOPY DBMS_SQL.VARCHAR2S
   , x_return_code             OUT NOCOPY VARCHAR2
   );

END IEC_CRITERIA_UTIL_PVT;

 

/
