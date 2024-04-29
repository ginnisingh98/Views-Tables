--------------------------------------------------------
--  DDL for Package Body PA_VALUE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_VALUE_MAPS_PKG" as
/* $Header: PAYMPKGB.pls 120.1 2005/08/19 17:23:19 mwasowic noship $ */

--
-- Procedure     : Insert_rows
-- Purpose       : Create Rows in PA_VALUE_MAPS.
--
--
PROCEDURE insert_rows
      ( p_value_map_def_id                 IN NUMBER                               ,
        p_source_value_arr                 IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_arr                   IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk1_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk2_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk3_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk4_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk5_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk1_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk2_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk3_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk4_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk5_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FORALL j IN p_source_value_arr.FIRST .. p_source_value_arr.LAST
		INSERT INTO pa_value_maps
		(   value_map_id            ,
		    value_map_def_id        ,
        source_value            ,
				dest_value              ,
				source_value_pk1        ,
				source_value_pk2        ,
				source_value_pk3        ,
				source_value_pk4        ,
				source_value_pk5        ,
				dest_value_pk1          ,
				dest_value_pk2          ,
				dest_value_pk3          ,
				dest_value_pk4          ,
				dest_value_pk5          ,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_updated_by         ,
        last_update_login       )
     VALUES
	   (  pa_value_maps_s.nextval    ,
        p_value_map_def_id         ,
	    	p_source_value_arr(j)      ,
		    p_dest_value_arr(j)        ,
		    p_source_value_pk1_arr(j)  ,
		    p_source_value_pk2_arr(j)  ,
		    p_source_value_pk3_arr(j)  ,
		    p_source_value_pk4_arr(j)  ,
		    p_source_value_pk5_arr(j)  ,
		    p_dest_value_pk1_arr(j)    ,
		    p_dest_value_pk2_arr(j)    ,
		    p_dest_value_pk3_arr(j)    ,
		    p_dest_value_pk4_arr(j)    ,
		    p_dest_value_pk5_arr(j)    ,
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id          );

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_VALUE_MAPS_PKG',
                          p_procedure_name   => 'insert_rows');
 raise;

END insert_rows;


--
-- Procedure            : delete_rows
-- Purpose              : Delete rows in pa_value_maps.
--
--
PROCEDURE delete_rows
	    ( p_value_map_def_id                 IN NUMBER                        ,
        p_value_map_def_type               IN VARCHAR2                      ,
        p_probability_list_id              IN NUMBER := NULL                ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_value_map_def_type = 'PROBABILITY_OPP_PROJ' THEN
     DELETE FROM pa_value_maps
     WHERE value_map_def_id = p_value_map_def_id
     AND dest_value_pk2 = p_probability_list_id;

   ELSE
     DELETE FROM pa_value_maps
     WHERE value_map_def_id = p_value_map_def_id;

   END IF;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_VALUE_MAPS_PKG',
                          p_procedure_name   => 'delete_rows');
 raise;

END delete_rows;


END PA_VALUE_MAPS_PKG;

/
