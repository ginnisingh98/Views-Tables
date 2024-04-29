--------------------------------------------------------
--  DDL for Package Body PA_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MAPPING_PVT" as
/* $Header: PAYMPVTB.pls 120.2 2005/08/19 17:23:27 mwasowic noship $ */

--
-- Procedure     : Save_value_maps
-- Purpose       : Save value map records to PA_VALUE_MAPS.
--
--
PROCEDURE save_value_maps
(       p_value_map_def_id                 IN NUMBER                               ,
        p_record_version_number            IN NUMBER                               ,
        p_source_value_arr                 IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_arr                   IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk1_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk2_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk3_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk4_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk5_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk1_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk2_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk3_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk4_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk5_arr               IN system.pa_varchar2_240_tbl_type      ,
        p_probability_list_id              IN NUMBER := NULL                       ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  v_1 NUMBER;

  l_source_value_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_dest_value_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_source_value_pk1_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_source_value_pk2_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_source_value_pk3_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_source_value_pk4_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_source_value_pk5_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_dest_value_pk1_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_dest_value_pk2_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_dest_value_pk3_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_dest_value_pk4_arr PA_PLSQL_DATATYPES.Char240TabTyp;
  l_dest_value_pk5_arr PA_PLSQL_DATATYPES.Char240TabTyp;

  l_value_map_def_type VARCHAR2(30);
  l_id NUMBER;
  l_msg_index_out NUMBER;
  -- added for bug: 4537865
  l_new_msg_data VARCHAR2(2000);
  -- added for bug: 4537865

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Get value map definition type.
  SELECT value_map_def_type
  INTO l_value_map_def_type
  FROM PA_VALUE_MAP_DEFS
  WHERE value_map_def_id = p_value_map_def_id;

  -- Name and Id validation.
  v_1:= 1;
  FOR j IN p_source_value_arr.FIRST .. p_source_value_arr.LAST LOOP
    debug('j = '|| j);
    debug('dest_value = '||p_dest_value_arr(j));
    IF p_dest_value_arr(j) IS NOT NULL THEN
      debug('v_1 = '||v_1);

      IF l_value_map_def_type = 'PERSON_ROLE_OPP_PROJ'
        OR l_value_map_def_type = 'ORG_ROLE_OPP_PROJ' THEN
        PA_ROLE_UTILS.check_role_name_or_id (p_role_id => p_dest_value_pk1_arr(j),
            p_role_name     => p_dest_value_arr(j),
            p_check_id_flag => 'Y',
            x_role_id       => l_id,
            x_return_status => x_return_status,
            x_error_message_code => x_msg_data);
      ELSIF l_value_map_def_type = 'PROBABILITY_OPP_PROJ' THEN
        PA_PROJECTS_MAINT_UTILS.check_probability_code_or_id(
            p_probability_member_id  => p_dest_value_pk1_arr(j),
            p_probability_percentage => p_dest_value_arr(j),
            p_project_type           => NULL,
            p_probability_list_id    => p_probability_list_id,
            p_check_id_flag          => 'Y',
            x_probability_member_id  => l_id,
            x_return_status          => x_return_status,
            x_error_msg_code         => x_msg_data);
      END IF;
      debug('After name id validation');
      debug('l_id = '|| l_id);
      debug('x_return_status = '|| x_return_status);

      -- Raise the error if the id/name validation is failed.
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => x_msg_data);
         RAISE FND_API.G_EXC_ERROR;
      -- Put the validated mapping data in a local pl/sql table.
      ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          l_source_value_arr(v_1) := p_source_value_arr(j);
          l_dest_value_arr(v_1) := p_dest_value_arr(j);
          l_source_value_pk1_arr(v_1) := p_source_value_pk1_arr(j);
          l_source_value_pk2_arr(v_1) := p_source_value_pk2_arr(j);
          l_source_value_pk3_arr(v_1) := p_source_value_pk3_arr(j);
          l_source_value_pk4_arr(v_1) := p_source_value_pk4_arr(j);
          l_source_value_pk5_arr(v_1) := p_source_value_pk5_arr(j);
          l_dest_value_pk1_arr(v_1) := TO_CHAR(l_id);
          l_dest_value_pk2_arr(v_1) := p_dest_value_pk2_arr(j);
          l_dest_value_pk3_arr(v_1) := p_dest_value_pk3_arr(j);
          l_dest_value_pk4_arr(v_1) := p_dest_value_pk4_arr(j);
          l_dest_value_pk5_arr(v_1) := p_dest_value_pk5_arr(j);
          v_1 := v_1 +1;
      END IF;
    END IF;
  END LOOP;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- Update record version number in header table PA_VALUE_MAP_DEFS.
    PA_VALUE_MAP_DEF_PKG.update_row(p_value_map_def_id => p_value_map_def_id,
      p_record_version_number => p_record_version_number,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);
    debug('After update_row');
  END IF;

  -- Delete all the value map records identified by p_value_map_def_id.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    debug('Before delete_rows');
    PA_VALUE_MAPS_PKG.delete_rows(p_value_map_def_id => p_value_map_def_id,
      p_value_map_def_type => l_value_map_def_type,
      p_probability_list_id => p_probability_list_id,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);
    debug('After delete_rows');
  END IF;

  -- Insert the new value map records.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    debug('l_dest_value_arr.COUNT = '||l_dest_value_arr.COUNT);
    IF l_dest_value_arr.COUNT > 0 THEN
      debug('Before insert_rows');
      PA_VALUE_MAPS_PKG.insert_rows (
        p_value_map_def_id => p_value_map_def_id     ,
        p_source_value_arr => l_source_value_arr     ,
				p_dest_value_arr   => l_dest_value_arr       ,
				p_source_value_pk1_arr  => l_source_value_pk1_arr      ,
				p_source_value_pk2_arr  => l_source_value_pk2_arr      ,
				p_source_value_pk3_arr  => l_source_value_pk3_arr      ,
				p_source_value_pk4_arr  => l_source_value_pk4_arr      ,
				p_source_value_pk5_arr  => l_source_value_pk5_arr      ,
				p_dest_value_pk1_arr    => l_dest_value_pk1_arr      ,
				p_dest_value_pk2_arr    => l_dest_value_pk2_arr      ,
				p_dest_value_pk3_arr    => l_dest_value_pk3_arr      ,
				p_dest_value_pk4_arr    => l_dest_value_pk4_arr      ,
				p_dest_value_pk5_arr    => l_dest_value_pk5_arr      ,
        x_return_status         => x_return_status           ,
        x_msg_count             => x_msg_count               ,
        x_msg_data              => x_msg_data );
    END IF;
    debug('After insert_rows');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;
       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
	        	(p_encoded       => FND_API.G_TRUE,
		         p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
       	  -- p_data           => x_msg_data,		* Commented for Bug: 4537865
	     p_data	      => l_new_msg_data,	-- added for bug: 4537865
		         p_msg_index_out  => l_msg_index_out );
	  -- added for bug: 4537865
             x_msg_data := l_new_msg_data;
          -- added for bug: 4537865
       END IF;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_MAPPING_PVT',
                          p_procedure_name   => 'save_value_maps');
   raise;

END save_value_maps;


--
-- Procedure     : Get_dest_values
-- Purpose       : Get the corresponding destination values given source
--                 values and a value map definition.
--
--
PROCEDURE get_dest_values
(       p_value_map_def_type           IN VARCHAR2     ,
        p_def_subtype                  IN VARCHAR2     ,
        p_source_value                 IN VARCHAR2     ,
				p_source_value_pk1             IN VARCHAR2     ,
				p_source_value_pk2             IN VARCHAR2     ,
				p_source_value_pk3             IN VARCHAR2     ,
				p_source_value_pk4             IN VARCHAR2     ,
				p_source_value_pk5             IN VARCHAR2     ,
        p_probability_list_id          IN NUMBER  := NULL,
				x_dest_value                   OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
        x_dest_value_pk1               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk2               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk3               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk4               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk5               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  CURSOR c1 IS
    SELECT dest_value, dest_value_pk1, dest_value_pk2, dest_value_pk3, dest_value_pk4, dest_value_pk5
    FROM pa_value_maps map, pa_value_map_defs def
    WHERE map.value_map_def_id = def.value_map_def_id
    AND def.value_map_def_type = p_value_map_def_type
    AND def.def_subtype = p_def_subtype
    AND map.source_value = p_source_value
    AND (map.source_value_pk1 = NVL(p_source_value_pk1, map.source_value_pk1)
         OR map.source_value_pk1 IS NULL)
    AND (map.source_value_pk2 = NVL(p_source_value_pk2, map.source_value_pk2)
         OR map.source_value_pk2 IS NULL)
    AND (map.source_value_pk3 = NVL(p_source_value_pk3, map.source_value_pk3)
         OR map.source_value_pk3 IS NULL)
    AND (map.source_value_pk4 = NVL(p_source_value_pk4, map.source_value_pk4)
         OR map.source_value_pk4 IS NULL)
    AND (map.source_value_pk5 = NVL(p_source_value_pk5, map.source_value_pk5)
         OR map.source_value_pk5 IS NULL);


BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   x_dest_value        := NULL;
   x_dest_value_pk1    := NULL;
   x_dest_value_pk2    := NULL;
   x_dest_value_pk3    := NULL;
   x_dest_value_pk4    := NULL;
	 x_dest_value_pk5    := NULL;

   FOR v_c1 IN c1 LOOP
     IF p_value_map_def_type = 'PROBABILITY_OPP_PROJ' THEN
       IF v_c1.dest_value_pk2 = p_probability_list_id THEN
         x_dest_value        := v_c1.dest_value;
         x_dest_value_pk1    := v_c1.dest_value_pk1;
         x_dest_value_pk2    := v_c1.dest_value_pk2;
         x_dest_value_pk3    := v_c1.dest_value_pk3;
         x_dest_value_pk4    := v_c1.dest_value_pk4;
	       x_dest_value_pk5    := v_c1.dest_value_pk5;
         RETURN;
       END IF;
     ELSE
       x_dest_value        := v_c1.dest_value;
       x_dest_value_pk1    := v_c1.dest_value_pk1;
       x_dest_value_pk2    := v_c1.dest_value_pk2;
       x_dest_value_pk3    := v_c1.dest_value_pk3;
       x_dest_value_pk4    := v_c1.dest_value_pk4;
	     x_dest_value_pk5    := v_c1.dest_value_pk5;
       RETURN;
     END IF;

   END LOOP;


EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_MAPPING_PVT',
                          p_procedure_name   => 'get_dest_values');
   raise;

END get_dest_values;


PROCEDURE debug(p_msg IN VARCHAR2) IS
BEGIN
     --dbms_output.put_line('pa_mapping_pvt'|| ' : ' || p_msg);
     PA_DEBUG.WRITE_LOG(
       x_module => 'pa.plsql.pa_mapping_pvt',
       x_msg => p_msg,
       x_log_level => 6);
END debug;


END PA_MAPPING_PVT;

/
