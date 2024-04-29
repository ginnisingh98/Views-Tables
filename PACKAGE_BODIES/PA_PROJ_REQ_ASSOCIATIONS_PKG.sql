--------------------------------------------------------
--  DDL for Package Body PA_PROJ_REQ_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_REQ_ASSOCIATIONS_PKG" as
/* $Header: PAYRASSB.pls 120.1 2005/08/19 17:23:58 mwasowic noship $ */

--
-- Procedure     : Insert_rows
-- Purpose       : Create Rows in PA_REQUEST_ASSOC_TEMP.
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
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  FORALL j IN p_object_type_tbl.FIRST .. p_object_type_tbl.LAST
		INSERT INTO PA_REQUEST_ASSOC_TEMP
		(
        object_name             ,
        object_number           ,
        object_type             ,
        object_type_name        ,
        object_subtype          ,
        object_id1              ,
        object_id2              ,
        object_id3              ,
        object_id4              ,
        object_id5              ,
        status_name             ,
        description             )
     VALUES
	   (
       p_object_name_tbl(j)     ,
       p_object_number_tbl(j)   ,
       p_object_type_tbl(j)             ,
       p_object_type_name_tbl(j)        ,
       p_object_subtype_tbl(j)          ,
       p_object_id1_tbl(j)              ,
       p_object_id2_tbl(j)              ,
       p_object_id3_tbl(j)              ,
       p_object_id4_tbl(j)              ,
       p_object_id5_tbl(j)              ,
       p_status_name_tbl(j)             ,
       p_description_tbl(j)
       );

   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_PROJ_REQ_ASSOCIATIONS_PKG',
                          p_procedure_name   => 'insert_rows');
 raise;

END insert_rows;


END PA_PROJ_REQ_ASSOCIATIONS_PKG;

/
