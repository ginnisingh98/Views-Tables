--------------------------------------------------------
--  DDL for Package PA_PROJ_REQ_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_REQ_ASSOCIATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PAYRASSS.pls 120.1 2005/08/19 17:24:04 mwasowic noship $ */

--
-- Procedure     : Insert_rows
-- Purpose       : Create Rows in PA_PROJ_REQ_ASSOCIATIONS_TEMP.
--
--
PROCEDURE insert_rows
      ( p_object_type_tbl            IN PA_PLSQL_DATATYPES.Char30TabTyp      ,
				p_object_id1_tbl             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_object_id2_tbl             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_object_id3_tbl             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_object_id4_tbl             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_object_id5_tbl             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_object_name_tbl            IN PA_PLSQL_DATATYPES.Char80TabTyp      ,
				p_object_number_tbl          IN PA_PLSQL_DATATYPES.Char80TabTyp      ,
				p_object_type_name_tbl       IN PA_PLSQL_DATATYPES.Char80TabTyp      ,
				p_object_subtype_tbl         IN PA_PLSQL_DATATYPES.Char80TabTyp      ,
				p_status_name_tbl            IN PA_PLSQL_DATATYPES.Char80TabTyp      ,
				p_description_tbl            IN PA_PLSQL_DATATYPES.Char250TabTyp      ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


END PA_PROJ_REQ_ASSOCIATIONS_PKG;

 

/
