--------------------------------------------------------
--  DDL for Package Body HZ_GNR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GNR_PVT" AS
/* $Header: ARHGNRVB.pls 120.16.12010000.2 2009/02/16 07:04:24 rgokavar ship $ */

  -----------------------------------------------------------------------------+
  -- Package variables
  -----------------------------------------------------------------------------+
  l_module_prefix CONSTANT VARCHAR2(30) := 'HZ:ARHGNRVB:HZ_GNR_PVT';
  l_module        CONSTANT VARCHAR2(30) := 'SEARCH_GEOGRAPHIES';
  l_debug_prefix           VARCHAR2(30) ;

  -----------------------------------------------------------------------------+
  -- Private function to get geo type list based on postion of geo type.
  -- If for US structure, 2 is passed, it will give STATE, COUNTY, CITY, POSTAL_CODE
  -- Created By Nishant Singhai (for Bug 4600030 on 27-Sep-2005)
  -----------------------------------------------------------------------------+
   FUNCTION get_geo_type_list (l_geo_struct_tbl IN hz_gnr_pvt.geo_struct_tbl_type,
                               l_index IN NUMBER, l_for_map_or_usg IN VARCHAR2 DEFAULT 'USAGE' )  RETURN VARCHAR2 IS
     v_not_validated_geo_type VARCHAR(200);
   BEGIN
     FOR i IN l_geo_struct_tbl.FIRST..l_geo_struct_tbl.LAST LOOP
       -- if call is to return for full mapping, return
       IF (l_for_map_or_usg = 'MAPPING') THEN
	     IF (i >= l_index) THEN
  	         IF (v_not_validated_geo_type) IS NULL THEN
	           v_not_validated_geo_type := l_geo_struct_tbl(i).v_geo_type;
	         ELSE
	           v_not_validated_geo_type := v_not_validated_geo_type||', '||l_geo_struct_tbl(i).v_geo_type;
	         END IF;
  	     END IF;
	   ELSE -- return only components set for geo validation usage (which is most of the cases)
	     IF (i >= l_index) THEN
	       IF (l_geo_struct_tbl(i).v_valid_for_usage = 'Y') THEN
  	         IF (v_not_validated_geo_type) IS NULL THEN
	           v_not_validated_geo_type := l_geo_struct_tbl(i).v_geo_type;
	         ELSE
	           v_not_validated_geo_type := v_not_validated_geo_type||', '||l_geo_struct_tbl(i).v_geo_type;
	         END IF;
	       END IF;
  	     END IF;
	   END IF;

     END LOOP;

     RETURN   v_not_validated_geo_type;
   END get_geo_type_list;

  ----------------------------------------------------------------------------+
  -- Private Function to get list of geography types which are mandatory but
  -- user has not entered value
  -- Created By Nishant Singhai (for Bug 4600030 on 27-Sep-2005)
  ----------------------------------------------------------------------------+
   FUNCTION get_missing_input_fields (l_geo_struct_tbl IN hz_gnr_pvt.geo_struct_tbl_type
                               )  RETURN VARCHAR2 IS
     v_missing_fields VARCHAR(200);
   BEGIN
     FOR i IN l_geo_struct_tbl.FIRST..l_geo_struct_tbl.LAST LOOP
       IF ((l_geo_struct_tbl(i).v_valid_for_usage = 'Y') AND
	       (l_geo_struct_tbl(i).v_param_value IS NULL)) THEN
         IF (v_missing_fields IS NULL) THEN
           v_missing_fields := l_geo_struct_tbl(i).v_geo_type;
         ELSE
           v_missing_fields := v_missing_fields||', '||l_geo_struct_tbl(i).v_geo_type;
         END IF;
       END IF;
     END LOOP;

     RETURN   v_missing_fields;
   END get_missing_input_fields;

   --------------------------------------------------------------------------+
   -- FUNCTION TO CHECK IF user passed values for all components for which
   -- geo usage is checked for validation
   --------------------------------------------------------------------------+
   FUNCTION is_all_geo_usage_param_passed (ll_geo_struct_tbl IN hz_gnr_pvt.geo_struct_tbl_type)
     RETURN BOOLEAN IS
   BEGIN
     IF (ll_geo_struct_tbl.COUNT > 0) THEN
        FOR i IN ll_geo_struct_tbl.FIRST..ll_geo_struct_tbl.LAST LOOP
          IF (ll_geo_struct_tbl(i).v_valid_for_usage = 'Y') THEN
            IF (ll_geo_struct_tbl(i).v_param_value IS NULL) THEN
             RETURN FALSE;
             EXIT;
            END IF;
          END IF;
       END LOOP;
       RETURN TRUE;
    ELSE
      RETURN TRUE; -- if no structure, no issue. it is success
    END IF;
   END is_all_geo_usage_param_passed;

  -----------------------------------------------------------------------------+
  -- Procedure to return geography types in a string that could not be validated
  -- Created By Nishant Singhai (for Bug 4600030 on 27-Sep-2005)
  -----------------------------------------------------------------------------+
  PROCEDURE validate_input_values_proc (l_geo_struct_tbl IN hz_gnr_pvt.geo_struct_tbl_type,
                                   x_not_validated_geo_type OUT NOCOPY VARCHAR2,
                                   x_rec_count_flag OUT NOCOPY VARCHAR2,
								   x_success_geo_level OUT NOCOPY NUMBER) IS

   l_map_tbl        hz_gnr_util_pkg.maploc_rec_tbl_type;
   l_query_temp     VARCHAR2(10000);
   l_query          VARCHAR2(10000);
   l_status         VARCHAR2(10);
   l_success_geo_level  NUMBER;
   l_success_rec_count  NUMBER;

   l_not_validated_geo_type  VARCHAR2(200);
   lx_max_usage_element_col_value NUMBER;

   TYPE param_details_rec_type IS RECORD
   ( geo_type       VARCHAR2(100),
     geo_value      VARCHAR2(360),
     query_text     VARCHAR2(10000)
   );

   TYPE param_details_tbl_type IS TABLE OF param_details_rec_type INDEX BY BINARY_INTEGER;

   l_param_details_tbl param_details_tbl_type;

   l_country_code    VARCHAR2(10);
   l_country_geo_id  NUMBER;
   l_count           NUMBER;

   l_rec_count_flag VARCHAR2(10);
   l_level          NUMBER;
   l_temp_level     NUMBER;
   l_temp_usage     VARCHAR2(30);

   CURSOR c_geo_id (l_country_code IN VARCHAR2) IS
     SELECT geography_id
     FROM   hz_geography_identifiers
     WHERE  UPPER(identifier_value) = l_country_code
     AND    identifier_type = 'CODE'
     AND    identifier_subtype = 'ISO_COUNTRY_CODE'
     AND    geography_use = 'MASTER_REF'
     AND    geography_type = 'COUNTRY'
     ;

    TYPE cur_sql_type IS REF CURSOR;
    cv_sql cur_sql_type;

  BEGIN
	-- FND Logging for debug purpose
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Begin procedure validate_input_values_proc(+)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
    END IF;

    -- main code logic begins here
    lx_max_usage_element_col_value := 0;
	l_country_code := UPPER(REPLACE(l_geo_struct_tbl(1).v_param_value,'%',''));


    -- get geography_id for country_code
    OPEN c_geo_id (l_country_code);
    FETCH c_geo_id INTO l_country_geo_id;
    CLOSE c_geo_id;

    IF (l_country_geo_id IS NOT NULL) THEN

		-- FND Logging for debug purpose
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'Fetched country geography id. It is:'||l_country_geo_id,
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	    END IF;

      IF (l_geo_struct_tbl.COUNT > 0) THEN

        -- again get the max element column for which geo usage is required to be valid
        FOR i IN l_geo_struct_tbl.FIRST..l_geo_struct_tbl.LAST LOOP
          IF (l_geo_struct_tbl(i).v_valid_for_usage = 'Y') THEN
             lx_max_usage_element_col_value :=
		       GREATEST(NVL(lx_max_usage_element_col_value,0),TO_NUMBER(SUBSTR(l_geo_struct_tbl(i).v_element_col,18)));
		  END IF;
	    END LOOP;

        FOR i IN l_geo_struct_tbl.FIRST..l_geo_struct_tbl.LAST LOOP

          l_query_temp := NULL;
          l_query      := NULL;
          l_count      := NULL;

          IF (i = 1) THEN
            l_map_tbl(i).LOC_SEQ_NUM     := l_geo_struct_tbl(i).v_level;
            l_map_tbl(i).LOC_COMPONENT   := l_geo_struct_tbl(i).v_tab_col;
            l_map_tbl(i).GEOGRAPHY_TYPE  := l_geo_struct_tbl(i).v_geo_type;
            l_map_tbl(i).GEO_ELEMENT_COL := l_geo_struct_tbl(i).v_element_col;
            l_map_tbl(i).LOC_COMPVAL     := l_country_code;
            l_map_tbl(i).GEOGRAPHY_ID    := l_country_geo_id;

            l_param_details_tbl(i).geo_type  := l_geo_struct_tbl(i).v_geo_type;
   			l_param_details_tbl(i).geo_value := l_country_code;

            l_rec_count_flag := 1;
            l_level          := 1;
            l_success_geo_level := l_level;
            l_success_rec_count := 1;

          ELSE
            l_map_tbl(i).LOC_SEQ_NUM     := l_geo_struct_tbl(i).v_level;
            l_map_tbl(i).LOC_COMPONENT   := l_geo_struct_tbl(i).v_tab_col;
            l_map_tbl(i).GEOGRAPHY_TYPE  := l_geo_struct_tbl(i).v_geo_type;
            l_map_tbl(i).GEO_ELEMENT_COL := l_geo_struct_tbl(i).v_element_col;
            l_map_tbl(i).LOC_COMPVAL     := UPPER(REPLACE(l_geo_struct_tbl(i).v_param_value,'%',''));


            IF (l_geo_struct_tbl(i).v_param_value IS NOT NULL) THEN
              l_param_details_tbl(i).geo_type  := l_geo_struct_tbl(i).v_geo_type;
			  l_param_details_tbl(i).geo_value := UPPER(REPLACE(l_geo_struct_tbl(i).v_param_value,'%',''));
			  l_query_temp := HZ_GNR_UTIL_PKG.getQuery(l_map_tbl, l_map_tbl, l_status);
              l_query := 'SELECT COUNT(*) FROM ('||l_query_temp||')';
              l_param_details_tbl(i).query_text := l_query;

              -- ns_debug.put_line('----------------------------------------');
              -- ns_debug.put_line('Status: '||l_status);
              -- ns_debug.put_line(l_query);
            ELSE
              l_param_details_tbl(i).geo_type := 'X';
			  l_param_details_tbl(i).geo_value := 'X';
			  l_param_details_tbl(i).query_text := NULL;
              --ns_debug.put_line('----------------------------------------');
              --ns_debug.put_line('for level '||i||' no parameter is passed');
            END IF;

            IF (l_param_details_tbl(i).query_text IS NOT NULL) THEN
              CASE i
			    WHEN 2 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value, l_param_details_tbl(2).geo_type;
                  /*
				     ns_debug.put_line('----------------------------------------');
                     ns_debug.put_line('Bind For 2:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
									   l_param_details_tbl(2).geo_type
									   );
                  */
			    WHEN 3 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value, l_param_details_tbl(3).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 3:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
									   l_param_details_tbl(3).geo_type
									   );
                  */
			    WHEN 4 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value, l_param_details_tbl(4).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 4:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
									   l_param_details_tbl(4).geo_type
									   );
                  */
			    WHEN 5 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value,
				                  l_param_details_tbl(5).geo_type, l_param_details_tbl(5).geo_value, l_param_details_tbl(5).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 5:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
                                       l_param_details_tbl(5).geo_type||':'||l_param_details_tbl(5).geo_value||':'||
									   l_param_details_tbl(5).geo_type
									   );
                  */
			    WHEN 6 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value,
				                  l_param_details_tbl(5).geo_type, l_param_details_tbl(5).geo_value,
				                  l_param_details_tbl(6).geo_type, l_param_details_tbl(6).geo_value, l_param_details_tbl(6).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 6:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
                                       l_param_details_tbl(5).geo_type||':'||l_param_details_tbl(5).geo_value||':'||
                                       l_param_details_tbl(6).geo_type||':'||l_param_details_tbl(6).geo_value||':'||
									   l_param_details_tbl(6).geo_type
									   );
                  */
			    WHEN 7 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value,
				                  l_param_details_tbl(5).geo_type, l_param_details_tbl(5).geo_value,
				                  l_param_details_tbl(6).geo_type, l_param_details_tbl(6).geo_value,
				                  l_param_details_tbl(7).geo_type, l_param_details_tbl(7).geo_value, l_param_details_tbl(7).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 7:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
                                       l_param_details_tbl(5).geo_type||':'||l_param_details_tbl(5).geo_value||':'||
                                       l_param_details_tbl(6).geo_type||':'||l_param_details_tbl(6).geo_value||':'||
                                       l_param_details_tbl(7).geo_type||':'||l_param_details_tbl(7).geo_value||':'||
									   l_param_details_tbl(7).geo_type
									   );
                  */
			    WHEN 8 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value,
				                  l_param_details_tbl(5).geo_type, l_param_details_tbl(5).geo_value,
				                  l_param_details_tbl(6).geo_type, l_param_details_tbl(6).geo_value,
				                  l_param_details_tbl(7).geo_type, l_param_details_tbl(7).geo_value,
								  l_param_details_tbl(8).geo_type, l_param_details_tbl(8).geo_value, l_param_details_tbl(8).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 8:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
                                       l_param_details_tbl(5).geo_type||':'||l_param_details_tbl(5).geo_value||':'||
                                       l_param_details_tbl(6).geo_type||':'||l_param_details_tbl(6).geo_value||':'||
                                       l_param_details_tbl(7).geo_type||':'||l_param_details_tbl(7).geo_value||':'||
                                       l_param_details_tbl(8).geo_type||':'||l_param_details_tbl(8).geo_value||':'||
									   l_param_details_tbl(8).geo_type
									   );
                  */
			    WHEN 9 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value,
				                  l_param_details_tbl(5).geo_type, l_param_details_tbl(5).geo_value,
				                  l_param_details_tbl(6).geo_type, l_param_details_tbl(6).geo_value,
				                  l_param_details_tbl(7).geo_type, l_param_details_tbl(7).geo_value,
                                  l_param_details_tbl(8).geo_type, l_param_details_tbl(8).geo_value,
								  l_param_details_tbl(9).geo_type, l_param_details_tbl(9).geo_value, l_param_details_tbl(9).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 9:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
                                       l_param_details_tbl(5).geo_type||':'||l_param_details_tbl(5).geo_value||':'||
                                       l_param_details_tbl(6).geo_type||':'||l_param_details_tbl(6).geo_value||':'||
                                       l_param_details_tbl(7).geo_type||':'||l_param_details_tbl(7).geo_value||':'||
                                       l_param_details_tbl(8).geo_type||':'||l_param_details_tbl(8).geo_value||':'||
                                       l_param_details_tbl(9).geo_type||':'||l_param_details_tbl(9).geo_value||':'||
									   l_param_details_tbl(9).geo_type
									   );
                  */
			    WHEN 10 THEN
				  OPEN cv_sql FOR l_param_details_tbl(i).query_text USING l_country_code, l_country_geo_id,
				                  l_param_details_tbl(2).geo_type, l_param_details_tbl(2).geo_value,
				                  l_param_details_tbl(3).geo_type, l_param_details_tbl(3).geo_value,
				                  l_param_details_tbl(4).geo_type, l_param_details_tbl(4).geo_value,
				                  l_param_details_tbl(5).geo_type, l_param_details_tbl(5).geo_value,
				                  l_param_details_tbl(6).geo_type, l_param_details_tbl(6).geo_value,
				                  l_param_details_tbl(7).geo_type, l_param_details_tbl(7).geo_value,
                                  l_param_details_tbl(8).geo_type, l_param_details_tbl(8).geo_value,
								  l_param_details_tbl(9).geo_type, l_param_details_tbl(9).geo_value,
								  l_param_details_tbl(10).geo_type, l_param_details_tbl(10).geo_value, l_param_details_tbl(10).geo_type;
                  /*
                    ns_debug.put_line('----------------------------------------');
                    ns_debug.put_line('Bind For 10:'||l_country_code||':'||l_country_geo_id||':'||
                                       l_param_details_tbl(2).geo_type||':'||l_param_details_tbl(2).geo_value||':'||
                                       l_param_details_tbl(3).geo_type||':'||l_param_details_tbl(3).geo_value||':'||
                                       l_param_details_tbl(4).geo_type||':'||l_param_details_tbl(4).geo_value||':'||
                                       l_param_details_tbl(5).geo_type||':'||l_param_details_tbl(5).geo_value||':'||
                                       l_param_details_tbl(6).geo_type||':'||l_param_details_tbl(6).geo_value||':'||
                                       l_param_details_tbl(7).geo_type||':'||l_param_details_tbl(7).geo_value||':'||
                                       l_param_details_tbl(8).geo_type||':'||l_param_details_tbl(8).geo_value||':'||
                                       l_param_details_tbl(9).geo_type||':'||l_param_details_tbl(9).geo_value||':'||
                                       l_param_details_tbl(10).geo_type||':'||l_param_details_tbl(10).geo_value||':'||
									   l_param_details_tbl(10).geo_type
									   );
                  */

              END CASE;

              FETCH cv_sql INTO l_count;
              CLOSE cv_sql;

              -- do count logic here
              l_level := i;
              IF (l_count > 0) THEN
                IF (l_count =1) THEN
                  l_rec_count_flag := '1';
                  l_success_rec_count := '1';
                ELSE
                  l_rec_count_flag := '2';
                  l_success_rec_count := '2';
                END IF;
                l_success_geo_level := l_level; -- used to retain value of
		                                        -- level for which query can derive records
              ELSE
                l_rec_count_flag := '0';
                --ns_debug.put_line('----------------------------------------');
                --ns_debug.put_line('Data could not be validated for :'||l_param_details_tbl(i).geo_value||'('||l_param_details_tbl(i).geo_type||')');
                --l_not_validated_geo_type := l_param_details_tbl(i).geo_type;
                EXIT;
              END IF;

            END IF; -- query_text not null

          END IF; -- i=1

        END LOOP;

        ---------------------------------------------------------------------+
        -- Output processing
        ---------------------------------------------------------------------+
        --ns_debug.put_line('----------------------------------------');
        --ns_debug.put_line('Record Count Flag ='||l_rec_count_flag);
        --ns_debug.put_line('Level ='||l_level);
        --ns_debug.put_line('Success Level='||l_success_geo_level);

		-- FND Logging for debug purpose
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'Record Count Flag is:'||l_rec_count_flag||
				                       '. Level is:'||l_level||'. Success Geo Level is:'||l_success_geo_level,
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	    END IF;

        -- Atleast 1 user input param is wrong.
        IF (l_rec_count_flag = '0') THEN

          -- If we have unique record till user entered value, tell user values from next level
		  IF (l_success_rec_count = '1') THEN
            l_not_validated_geo_type := get_geo_type_list(l_geo_struct_tbl, l_success_geo_level+1, 'USAGE');

  		    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'For passed in values we have 1 record at level:'||l_success_geo_level,
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	        END IF;

          ELSIF
          -- If we have multiple records for user entered value, tell user values from that level
            (l_success_rec_count = '2') THEN

            -- Since last entered value did not fetch any record (i.e  is wrong)
            -- and just before that we have multiple values, get the required fields
            -- for usage that may be missing and causing multiple values.
            -- (Fix for Bug 5356895 by Nishant 27-Jun-2006)
            l_not_validated_geo_type := get_missing_input_fields(l_geo_struct_tbl);

            -- if all fields were entered, then tell user from the last valid value for
            -- which we got mulptiple records
            IF (l_not_validated_geo_type IS NULL) THEN
              l_not_validated_geo_type := get_geo_type_list(l_geo_struct_tbl, l_success_geo_level, 'USAGE');
            END IF;

  		    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'For passed in values we have multiple records at level:'||l_success_geo_level||
	                                   '. Geo Type not validated for msg:'||l_not_validated_geo_type,
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	        END IF;

          END IF;

  		  -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'For Record Count Flag = 0, l_success_rec_count='||l_success_rec_count
				                       ||', geo type not validated is :'||l_not_validated_geo_type,
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	      END IF;

          --ns_debug.put_line('----------------------------------------');
     	  --ns_debug.put_line('Following Geography Components Could Not Be Validated: '||INITCAP(REPLACE(l_not_validated_geo_type,'_',' ')));
        END IF;

        -- If everthing passed is valid, but not complete.
        -- i.e. 1. or more rec found but it is not complete for geo usage
        -- l_rec_count_flag > 0
        IF (l_not_validated_geo_type IS NULL AND l_level > 0) THEN

  		    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'Everthing passed is valid, but may not be complete, i.e. 1. rec found but it is not complete for geo usage',
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	        END IF;

            -- If level is greater than element column value set for geo usage,
            -- pass max element col value, so that we will get at least 1 element
            -- in message otherwise, missing element will be NULL.
            -- Corner case. Should not happen.
            IF (l_success_geo_level >= lx_max_usage_element_col_value) THEN
              l_not_validated_geo_type := get_missing_input_fields(l_geo_struct_tbl);
              --ns_debug.put_line('All geo elements passed are valid, use missing elements for geo');
	  		    -- FND Logging for debug purpose
			    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		          hz_utility_v2pub.debug
		               (p_message       => 'All geo elements passed are valid, try reporting missing elements for geo',
			            p_prefix        => l_debug_prefix,
			            p_msg_level     => fnd_log.level_statement,
			            p_module_prefix => l_module_prefix,
			            p_module        => l_module
			           );
		        END IF;

              -- Still it is null i.e. all values passed, very tough to figure out
              -- what exactly is wrong with address then show the component name for full mapping
              IF (l_not_validated_geo_type IS NULL) THEN
                IF (l_success_rec_count = '2') THEN  -- More than 1 rec found till last usage
                  l_temp_level := l_success_geo_level;
                  IF (l_success_geo_level = lx_max_usage_element_col_value) THEN
                    -- Multiple values found till usage requirement
                    l_temp_usage := 'USAGE';
                  ELSE -- multiple rec found for values beyond usage requirement
                    l_temp_usage := 'MAPPING';
                  END IF;

                ELSE
                  l_temp_level := l_success_geo_level + 1; -- Only 1 record till last usage
                  l_temp_usage := 'MAPPING';
                END IF;

                l_not_validated_geo_type := get_geo_type_list(l_geo_struct_tbl,l_temp_level,l_temp_usage);

	  		    -- FND Logging for debug purpose
			    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		          hz_utility_v2pub.debug
		               (p_message       => 'All required input fields were populated, '||
					                       'very tough to figure out wrong components. '||
										   'Report invalid comp for which multiple rec found for : '||
										   l_temp_usage||' : '||l_not_validated_geo_type,
			            p_prefix        => l_debug_prefix,
			            p_msg_level     => fnd_log.level_statement,
			            p_module_prefix => l_module_prefix,
			            p_module        => l_module
			           );
		        END IF;

              END IF;
            ELSE
              -- rec not valid till mapped usage
              IF (l_success_rec_count = '2') THEN  -- More than 1 rec found till last usage
                l_temp_level := l_success_geo_level;
              ELSE
                l_temp_level := l_success_geo_level + 1; -- Only 1 record till last usage
              END IF;

              l_not_validated_geo_type := get_geo_type_list(l_geo_struct_tbl,l_temp_level,'USAGE');

				-- FND Logging for debug purpose
			    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		          hz_utility_v2pub.debug
		               (p_message       => 'All required geo elements are not passed. Start the list from '||
										   'next level :'||l_not_validated_geo_type,
			            p_prefix        => l_debug_prefix,
			            p_msg_level     => fnd_log.level_statement,
			            p_module_prefix => l_module_prefix,
			            p_module        => l_module
			           );
		        END IF;

			END IF;

  		    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'Everthing passed is valid, but not complete. '||
				                       'Following geo type not validated :'||l_not_validated_geo_type,
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	        END IF;
          --ns_debug.put_line('----------------------------------------');
		  --ns_debug.put_line('Passed values are valid but need values for '||INITCAP(REPLACE(l_not_validated_geo_type,'_',' ')));
        END IF; -- Only country passed check

        x_not_validated_geo_type := l_not_validated_geo_type;
        x_rec_count_flag  := l_rec_count_flag;
        x_success_geo_level := l_success_geo_level;

      END IF; -- end of geo structure tbl > 0 count

    END IF; -- country found check

	-- FND Logging for debug purpose
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'End procedure validate_input_values_proc(-)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
    END IF;

  EXCEPTION WHEN OTHERS THEN
    --ns_debug.put_line('Exception occured in validate_input_values_proc:'||SQLERRM);
	-- FND Logging for debug purpose
	IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Error in validate_input_values_proc:'||
			                       SUBSTR(SQLERRM,1,200),
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_exception,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
    END IF;

  END validate_input_values_proc;

  -----------------------------------------------------------------------------+
  -- Procedure to do sorting based on suggetion list column in geo_suggest_tbl
  -- plsql table
  -- Created By Nishant Singhai (for Bug 4600030 on 28-Sep-2005)
  -----------------------------------------------------------------------------+
  PROCEDURE quick_sort_suggestion_list
    (
      p_left   INTEGER,
      p_right  INTEGER,
      p_list   IN OUT NOCOPY hz_gnr_pvt.geo_suggest_tbl_type
    )
  IS

    i       INTEGER;
    j       INTEGER;
    l_left  INTEGER := p_left;
    l_right INTEGER := p_right;
    l_current_node hz_gnr_pvt.geo_suggest_rec;
    l_dummy_node   hz_gnr_pvt.geo_suggest_rec;

  BEGIN

    IF (l_right > l_left) THEN
      l_current_node := p_list(l_right);
      i := l_left -1;
      j := l_right;
      LOOP
        LOOP
          i := i +1;
          IF (p_list(i).suggestion_list < l_current_node.suggestion_list) THEN
            null;
          ELSE
            exit;
          END IF;

          IF (i >= p_list.count) THEN
            exit;
          END IF;
        END LOOP;

        LOOP
          j := j -1;
          IF (j <= 0) THEN
            exit;
          END IF;

          IF (p_list(j).suggestion_list > l_current_node.suggestion_list) THEN
            null;
          ELSE
            exit;
          END IF;

        END LOOP;

        IF (i >= j) THEN
          exit;
        END IF;

        l_dummy_node  := p_list(i);
        p_list(i)     := p_list(j);
        p_list(j)     := l_dummy_node;
      END LOOP;

      l_dummy_node    := p_list(i);
      p_list(i)       := p_list(l_right);
      p_list(l_right) := l_dummy_node;

      quick_sort_suggestion_list(l_left, i-1,     p_list);
      quick_sort_suggestion_list(i+1,    l_right, p_list);

    END IF;

  END quick_sort_suggestion_list;

  ----------------------------------------------------------------------------+
  -- Procedure to get geography details for any passed in geography name or geo code
  ----------------------------------------------------------------------------+
  PROCEDURE get_geo_details_proc (p_geo_code IN VARCHAR2 DEFAULT NULL,
                                  p_geo_name IN VARCHAR2 DEFAULT NULL,
                                  p_geo_type IN VARCHAR2,
                                  p_country_code IN VARCHAR2,
                                  x_geo_name  OUT nocopy VARCHAR2,
                                  x_geo_id    OUT nocopy NUMBER,
                                  x_geo_code  OUT nocopy VARCHAR2
		                         ) IS
    lv_geo_name VARCHAR2(360);
    lv_geo_code VARCHAR2(100);
    lv_geo_id   NUMBER;

    CURSOR c_geo_name (v_geo_name VARCHAR2, v_geo_type VARCHAR2, v_country_code VARCHAR2) IS
		SELECT hg.geography_name, hg.geography_id, hg.geography_code
		FROM   hz_geography_identifiers hi
		      ,hz_geographies hg
		WHERE  hi.identifier_type = 'NAME'
		AND    UPPER(hi.identifier_value) = v_geo_name
		AND    hi.geography_type = v_geo_type
		AND    hi.geography_use = 'MASTER_REF'
		AND    hi.geography_id  = hg.geography_id
		AND    hg.geography_use = 'MASTER_REF'
		AND    UPPER(hg.country_code) = v_country_code
		AND    SYSDATE BETWEEN hg.START_DATE AND hg.END_DATE
		;

    CURSOR c_geo_code (v_geo_code VARCHAR2, v_geo_type VARCHAR2, v_country_code VARCHAR2) IS
		SELECT hg.geography_name, hg.geography_id, hg.geography_code
		FROM   hz_geography_identifiers hi
		      ,hz_geographies hg
		WHERE  hi.identifier_type = 'CODE'
		AND    UPPER(hi.identifier_value) = v_geo_code
		AND    hi.geography_type = v_geo_type
		AND    hi.geography_use = 'MASTER_REF'
		AND    hi.geography_id  = hg.geography_id
		AND    hg.geography_use = 'MASTER_REF'
		AND    UPPER(hg.country_code) = v_country_code
		AND    SYSDATE BETWEEN hg.START_DATE AND hg.END_DATE
		;

  BEGIN
    IF (p_geo_code IS NOT NULL) THEN
      OPEN c_geo_code(upper(p_geo_code), p_geo_type, upper(p_country_code));
      FETCH c_geo_code INTO lv_geo_name, lv_geo_id, lv_geo_code;
      CLOSE c_geo_code;
    END IF;

    IF ((lv_geo_id IS NULL) AND (p_geo_name IS NOT NULL)) THEN
      OPEN c_geo_name(upper(p_geo_name), p_geo_type, upper(p_country_code));
      FETCH c_geo_name INTO lv_geo_name, lv_geo_id, lv_geo_code;
      CLOSE c_geo_name;
    END IF;

    x_geo_name := lv_geo_name;
    x_geo_id   := lv_geo_id;
    x_geo_code := lv_geo_code;

  EXCEPTION WHEN OTHERS
    THEN NULL;
  END get_geo_details_proc;

  ----------------------------------------------------------------------------+
  -- Main procedure to do address search and provide with suggestions
  -- This procedure takes location components as input and provides suggested
  -- values in plsql table format
  ----------------------------------------------------------------------------+
  PROCEDURE  search_geographies
  (
    p_table_name      	  				IN  VARCHAR2,
    p_address_style   	  				IN  VARCHAR2,
	p_address_usage                     IN  VARCHAR2,
    p_country_code     	  				IN  HZ_LOCATIONS.COUNTRY%TYPE,
    p_state           	  				IN  HZ_LOCATIONS.STATE%TYPE,
    p_province        	  				IN  HZ_LOCATIONS.PROVINCE%TYPE,
    p_county          	  				IN  HZ_LOCATIONS.COUNTY%TYPE,
    p_city            	  				IN  HZ_LOCATIONS.CITY%TYPE,
    p_postal_code     	  				IN  HZ_LOCATIONS.POSTAL_CODE%TYPE,
    p_postal_plus4_code     	  		IN  HZ_LOCATIONS.POSTAL_PLUS4_CODE%TYPE,
    p_attribute1                        IN  HZ_LOCATIONS.ATTRIBUTE1%TYPE,
    p_attribute2                        IN  HZ_LOCATIONS.ATTRIBUTE2%TYPE,
    p_attribute3                        IN  HZ_LOCATIONS.ATTRIBUTE3%TYPE,
    p_attribute4                        IN  HZ_LOCATIONS.ATTRIBUTE4%TYPE,
    p_attribute5                        IN  HZ_LOCATIONS.ATTRIBUTE5%TYPE,
    p_attribute6                        IN  HZ_LOCATIONS.ATTRIBUTE6%TYPE,
    p_attribute7                        IN  HZ_LOCATIONS.ATTRIBUTE7%TYPE,
    p_attribute8                        IN  HZ_LOCATIONS.ATTRIBUTE8%TYPE,
    p_attribute9                        IN  HZ_LOCATIONS.ATTRIBUTE9%TYPE,
    p_attribute10                       IN  HZ_LOCATIONS.ATTRIBUTE10%TYPE,
    x_mapped_struct_count 			  	OUT NOCOPY  NUMBER,
    x_records_count   	  	  		  	OUT NOCOPY  NUMBER,
    x_return_code                       OUT NOCOPY  NUMBER,
    x_validation_level                  OUT NOCOPY  VARCHAR2,
    x_geo_suggest_tbl                   OUT NOCOPY  HZ_GNR_PVT.geo_suggest_tbl_type,
    x_geo_struct_tbl					OUT NOCOPY  HZ_GNR_PVT.geo_struct_tbl_type,
    x_geo_suggest_misc_rec              OUT NOCOPY  HZ_GNR_PVT.geo_suggest_misc_rec,
    x_return_status             	  	OUT NOCOPY  VARCHAR2,
    x_msg_count                 	  	OUT NOCOPY  NUMBER,
    x_msg_data                  	  	OUT NOCOPY  VARCHAR2
  ) IS

  l_select      VARCHAR2(2000);
  l_select_6    VARCHAR2(1000);
  l_from        VARCHAR2(1000);
  l_from_5      VARCHAR2(500);
  l_from_6      VARCHAR2(500);
  l_from_7      VARCHAR2(500);
  l_where       VARCHAR2(2800);
  l_where_1     VARCHAR2(2600);
  l_where_3     VARCHAR2(600);
  l_where_4     VARCHAR2(600);
  l_where_5     VARCHAR2(2600);
  l_where_6     VARCHAR2(2600);
  l_where_7     VARCHAR2(2600);
  l_order_by    VARCHAR2(200);
  l_sql_stmt    VARCHAR2(10000);
  l_sql_stmt_2  VARCHAR2(10000);
  l_sql_stmt_3  VARCHAR2(10000);

  l_priv_valid_index   NUMBER;
  l_priv_valid_index_6 NUMBER;
  l_priv_valid_index_7 NUMBER;
  l_count_for_where_clause_2 NUMBER;
  l_count_for_where_clause_3 NUMBER;

  l_max_fetch_count NUMBER;
  l_address_usage   VARCHAR2(100);

  l_error_location VARCHAR2(100);

  l_country_only_passed      VARCHAR2(1);
  l_country_only_mapped      VARCHAR2(1);
  l_country_only_name		 HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE;
  l_country_only_id			 HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE;
  l_country_only_code		 HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE;
  l_search_type              VARCHAR2(100);
  l_addr_val_level           VARCHAR2(100);

  l_max_passed_element_col_value NUMBER;
  l_max_mapped_element_col_value NUMBER;
  l_max_usage_element_col_value  NUMBER;
  l_lowest_usage_geo_type        hz_geographies.GEOGRAPHY_TYPE%TYPE;
  l_last_geo_type_usg_val_psd    hz_geographies.GEOGRAPHY_TYPE%TYPE;
  l_lowest_passed_geo_type       hz_geographies.GEOGRAPHY_TYPE%TYPE;
  l_lowest_mapped_geo_type       hz_geographies.GEOGRAPHY_TYPE%TYPE;
  l_lowest_passed_geo_value      hz_geographies.GEOGRAPHY_NAME%TYPE;
  l_geo_data_count          INTEGER;

  l_success                 VARCHAR2(10);
  l_geo_validation_passed   VARCHAR2(10);
  l_check_geo_type_not_passed VARCHAR2(255);
  LX_ADDR_VAL_LEVEL         VARCHAR2(30);
  LX_ADDR_WARN_MSG          VARCHAR2(1000);
  LX_ADDR_VAL_STATUS        VARCHAR2(10);
  LX_STATUS                 VARCHAR2(10);

  lx_not_validated_geo_type VARCHAR2(255);
  lx_rec_count_flag         VARCHAR2(10);
  lx_success_geo_level      NUMBER;

  TYPE GeoCurTyp IS REF CURSOR;
  geo_cv GeoCurTyp;

  ------ multi parent variables
  l_select_mp      VARCHAR2(1000);
  l_from_mp        VARCHAR2(1000);
  l_where_mp       VARCHAR2(6000);
  l_sql_stmt_mp    VARCHAR2(10000);
  l_struct_level_count_mp NUMBER;
  l_last_index_mp  NUMBER;
  l_total_null_cols_mp NUMBER;

  ------ multi parent record
  TYPE rec_type_mp IS RECORD
  (
    geo_id_1	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_1	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_1	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_1	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_2	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_2	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_2	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_2	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_3	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_3	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_3	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_3	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_4	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_4	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_4	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_4	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_5	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_5	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_5	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_5	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_6	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_6	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_6	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_6	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_7	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_7	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_7	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_7	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_8	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_8	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_8	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_8	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_9	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_9	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_9	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_9	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE,
    geo_id_10	   HZ_GEOGRAPHIES.GEOGRAPHY_ID%TYPE,
    geo_name_10	   HZ_GEOGRAPHIES.GEOGRAPHY_NAME%TYPE,
    geo_code_10	   HZ_GEOGRAPHIES.GEOGRAPHY_CODE%TYPE,
    geo_type_10	   HZ_GEOGRAPHIES.GEOGRAPHY_TYPE%TYPE
  );

  rec_mp  rec_type_mp;

  TYPE cur_type_mp IS REF CURSOR;
  cv_mp cur_type_mp;

  -----intermediate table record
  TYPE geo_rec_type IS RECORD
  (
    GEOGRAPHY_ID 	   		   	 hz_geographies.GEOGRAPHY_ID%TYPE,
	GEOGRAPHY_TYPE				 hz_geographies.GEOGRAPHY_TYPE%TYPE,
	GEOGRAPHY_NAME				 hz_geographies.GEOGRAPHY_NAME%TYPE,
	GEOGRAPHY_CODE				 hz_geographies.GEOGRAPHY_CODE%TYPE,
	MULTIPLE_PARENT_FLAG		 hz_geographies.MULTIPLE_PARENT_FLAG%TYPE,
	COUNTRY_CODE				 hz_geographies.COUNTRY_CODE%TYPE,
    GEOGRAPHY_ELEMENT1			 hz_geographies.GEOGRAPHY_ELEMENT1%TYPE,
	GEOGRAPHY_ELEMENT1_ID		 hz_geographies.GEOGRAPHY_ELEMENT1_ID%TYPE,
	GEOGRAPHY_ELEMENT1_CODE		 hz_geographies.GEOGRAPHY_ELEMENT1_CODE%TYPE,
	GEOGRAPHY_ELEMENT2			 hz_geographies.GEOGRAPHY_ELEMENT2%TYPE,
	GEOGRAPHY_ELEMENT2_ID		 hz_geographies.GEOGRAPHY_ELEMENT2_ID%TYPE,
	GEOGRAPHY_ELEMENT2_CODE		 hz_geographies.GEOGRAPHY_ELEMENT2_CODE%TYPE,
    GEOGRAPHY_ELEMENT3			 hz_geographies.GEOGRAPHY_ELEMENT3%TYPE,
	GEOGRAPHY_ELEMENT3_ID		 hz_geographies.GEOGRAPHY_ELEMENT3_ID%TYPE,
	GEOGRAPHY_ELEMENT3_CODE		 hz_geographies.GEOGRAPHY_ELEMENT3_CODE%TYPE,
    GEOGRAPHY_ELEMENT4			 hz_geographies.GEOGRAPHY_ELEMENT4%TYPE,
	GEOGRAPHY_ELEMENT4_ID		 hz_geographies.GEOGRAPHY_ELEMENT4_ID%TYPE,
	GEOGRAPHY_ELEMENT4_CODE		 hz_geographies.GEOGRAPHY_ELEMENT4_CODE%TYPE,
    GEOGRAPHY_ELEMENT5			 hz_geographies.GEOGRAPHY_ELEMENT5%TYPE,
	GEOGRAPHY_ELEMENT5_ID		 hz_geographies.GEOGRAPHY_ELEMENT5_ID%TYPE,
	GEOGRAPHY_ELEMENT5_CODE		 hz_geographies.GEOGRAPHY_ELEMENT5_CODE%TYPE,
    GEOGRAPHY_ELEMENT6			 hz_geographies.GEOGRAPHY_ELEMENT6%TYPE,
	GEOGRAPHY_ELEMENT6_ID		 hz_geographies.GEOGRAPHY_ELEMENT6_ID%TYPE,
    GEOGRAPHY_ELEMENT7			 hz_geographies.GEOGRAPHY_ELEMENT7%TYPE,
	GEOGRAPHY_ELEMENT7_ID		 hz_geographies.GEOGRAPHY_ELEMENT7_ID%TYPE,
	GEOGRAPHY_ELEMENT8			 hz_geographies.GEOGRAPHY_ELEMENT8%TYPE,
	GEOGRAPHY_ELEMENT8_ID		 hz_geographies.GEOGRAPHY_ELEMENT8_ID%TYPE,
    GEOGRAPHY_ELEMENT9			 hz_geographies.GEOGRAPHY_ELEMENT9%TYPE,
	GEOGRAPHY_ELEMENT9_ID		 hz_geographies.GEOGRAPHY_ELEMENT9_ID%TYPE,
    GEOGRAPHY_ELEMENT10			 hz_geographies.GEOGRAPHY_ELEMENT10%TYPE,
	GEOGRAPHY_ELEMENT10_ID		 hz_geographies.GEOGRAPHY_ELEMENT10_ID%TYPE
  );

  TYPE geo_rec_tbl_type IS TABLE OF geo_rec_type INDEX BY BINARY_INTEGER;

  geo_rec		   	  		   geo_rec_type;
  geo_rec_tbl 	   			   geo_rec_tbl_type;

  geo_struct_tbl   			   HZ_GNR_PVT.geo_struct_tbl_type;
  geo_suggest_tbl 			   HZ_GNR_PVT.geo_suggest_tbl_type;

  l_geo_rec_tab_col           hz_geo_struct_map_dtl.loc_component%TYPE;
  l_geo_rec_geo_type          hz_geo_struct_map_dtl.geography_type%TYPE;
  l_geo_rec_geo_name          hz_geographies.geography_name%TYPE;
  l_geo_rec_geo_id            hz_geographies.geography_id%TYPE;
  l_geo_rec_geo_code          hz_geographies.geography_code%TYPE;
  l_geo_rec_country_code      hz_geographies.country_code%TYPE;

  l_not_validated_geo_type    VARCHAR2(200);
  l_rec_count_flag            VARCHAR2(10);

  -- variables for dynamic bind to query
  TYPE bind_rec_type IS RECORD (bind_value VARCHAR2(2000));
  TYPE  bind_tbl_type IS TABLE OF bind_rec_type INDEX BY binary_integer;
  bind_table_1           bind_tbl_type;
  bind_table_2           bind_tbl_type;
  bind_table_3           bind_tbl_type;
  l_bind_counter         NUMBER := 0;

  ---------------------------------------------------------------------+
  -- function to get table column name of hz_locations
  -- input is element column name from hz_geographies stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_mapped_tab_col (pf_element_column_name IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_loc_col VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (upper(geo_struct_tbl(i).v_element_col) = UPPER(pf_element_column_name)) THEN
	         x_loc_col := geo_struct_tbl(i).v_tab_col;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_loc_col;
  END get_mapped_tab_col;

  ---------------------------------------------------------------------+
  -- function to get table column name of hz_locations
  -- input is geography type stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_tab_col_from_geo_type (pf_geo_type IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_loc_col VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (upper(geo_struct_tbl(i).v_geo_type) = UPPER(pf_geo_type)) THEN
	         x_loc_col := geo_struct_tbl(i).v_tab_col;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_loc_col;
  END get_tab_col_from_geo_type;

  ---------------------------------------------------------------------+
  -- function to get element column name of hz_geographies
  -- input is geography type from hz_geographies stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_element_col_for_geo_type (pf_geo_type IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_element_col VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (upper(geo_struct_tbl(i).v_geo_type) = UPPER(pf_geo_type)) THEN
	         x_element_col := geo_struct_tbl(i).v_element_col;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_element_col;
  END get_element_col_for_geo_type;

  ---------------------------------------------------------------------+
  -- function to get geo type
  -- input is table column name from hz_locations stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_mapped_geo_type (pf_loc_column_name IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_geo_type VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (upper(geo_struct_tbl(i).v_tab_col) = UPPER(pf_loc_column_name)) THEN
	         x_geo_type := geo_struct_tbl(i).v_geo_type;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_geo_type;
  END get_mapped_geo_type;

  ---------------------------------------------------------------------+
  -- function to get geography type for mapped column
  -- input is element column from hz_geographies stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_geo_type_from_element_col (pf_element_column IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_geo_type VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (UPPER(geo_struct_tbl(i).v_element_col) = UPPER(pf_element_column)) THEN
	         x_geo_type := geo_struct_tbl(i).v_geo_type;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_geo_type;
  END get_geo_type_from_element_col;

  ---------------------------------------------------------------------+
  -- function to get parameter value
  -- input is column name from hz_locations stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_mapped_param_value (pf_loc_column_name IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_param_value VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (upper(geo_struct_tbl(i).v_tab_col) = UPPER(pf_loc_column_name)) THEN
	         x_param_value := geo_struct_tbl(i).v_param_value;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_param_value;
  END get_mapped_param_value;

  ---------------------------------------------------------------------+
  -- function to get parameter value from element column
  -- input is element column name stored in mapping table
  ---------------------------------------------------------------------+
  FUNCTION get_map_param_val_for_element (pf_element_col IN  VARCHAR2) RETURN VARCHAR2
  IS
    x_param_value VARCHAR2(100);
  BEGIN
	IF (geo_struct_tbl IS NOT NULL) THEN
	  IF (geo_struct_tbl.COUNT > 0) THEN
 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	      IF (upper(geo_struct_tbl(i).v_element_col) = UPPER(pf_element_col)) THEN
	         x_param_value := geo_struct_tbl(i).v_param_value;
	      END IF;
	    END LOOP;
	  END IF;
	END IF;
	RETURN x_param_value;
  END get_map_param_val_for_element;


  ---------------------------------------------------------------------+
  -- Procedure to build l_where_5 (detailed search where clause) based on column
  -- names of HZ_LOCATIONS stored in mapping table
  -- and update geo_struct_tbl with passed in parameter value
  -- it also checks if lowest level parameter is passed
  -- Retaining the procedure as this logic is performing faster. Drawback in
  -- this procedure is that it does not fetch multiple parents records.
  ---------------------------------------------------------------------+
  PROCEDURE create_where_1_clause_pvt (ll_index NUMBER, ll_passed_param VARCHAR2, ll_search_type VARCHAR2)
  IS
  BEGIN
	IF (ll_passed_param IS NOT NULL) THEN

      -- get the max element coumn for which a parameter value is passed
      -- e.g. if max value of element col is geography_element4, get "4" out of it
      l_max_passed_element_col_value :=
        GREATEST(NVL(l_max_passed_element_col_value,0),TO_NUMBER(SUBSTR(geo_struct_tbl(ll_index).v_element_col,18)));

      l_lowest_passed_geo_type := geo_struct_tbl(ll_index).v_geo_type;
      l_lowest_passed_geo_value := geo_struct_tbl(ll_index).v_param_value;

  	  -- Build dynamic where clause for detailed search (search2)
        /* -- sample query
        AND    hg0.geography_element1_id = hgi1.geography_id
        AND    hgi1.geography_use = hg0.geography_use
        AND    hgi1.geography_type = 'COUNTRY'
        AND    UPPER(hgi1.identifier_value) LIKE UPPER('us%')
        --AND    hgi1.identifier_type = 'CODE' -- 'NAME'
        */

      l_from_5 := l_from_5 ||', hz_geography_identifiers hg'||ll_index;

      l_where_5 := l_where_5 ||' AND hg0.'||geo_struct_tbl(ll_index).v_element_col||'_id = hg'||ll_index||'.geography_id'
                   ||' AND hg'||ll_index||'.geography_use = hg'||to_char(l_priv_valid_index)||'.geography_use'
       	           ||' AND hg'||ll_index||'.geography_type = :x_'||ll_index||'_1 '
       	           ||' AND UPPER(hg'||ll_index||'.identifier_value) LIKE :x_'||ll_index||'_2 ';

      bind_table_1(bind_table_1.COUNT+1).bind_value :=  geo_struct_tbl(ll_index).v_geo_type;
      bind_table_1(bind_table_1.COUNT+1).bind_value :=  geo_struct_tbl(ll_index).v_param_value;

      -- default is search type = 'BOTH' so that identifier type is ignored.
      -- only for country it is 'CODE'
      IF (ll_search_type IN ('NAME','CODE')) THEN
        l_where_5 := l_where_5||' AND hg'||ll_index||'.identifier_type = :x_'||ll_index||'_3 ';
        bind_table_1(bind_table_1.COUNT+1).bind_value :=  ll_search_type;
      END IF;

      -- update previus valid index to use in building where clause
	  l_priv_valid_index := ll_index;

	END IF;

  END create_where_1_clause_pvt;

  ----------------------------------------------------------------------------+
  -- Procedure to create where clause for Search 3 (Union of 1+2+last passed
  -- element and 1+2+(last-1)passed element
  ----------------------------------------------------------------------------+
  PROCEDURE create_where_2_clause_pvt (ll_index NUMBER, ll_sql_id NUMBER) IS
  BEGIN
     -- 1st select stmt
     IF (ll_sql_id = 1) THEN
      l_from_6 := l_from_6 ||', hz_geography_identifiers hg'||ll_index;

      -- we are adding country_code in where clause. This has to be done only once
      -- so putting the check of index = 1
      IF (ll_index = 1) THEN
  	    l_where_6 := ' WHERE hg0.geography_use = ''MASTER_REF'' '||
	                 ' AND   SYSDATE between hg0.start_date and hg0.end_date '||
	                 ' AND   upper(hg0.country_code)  = :x_country_code_1 '||
					 ' AND   hg0.multiple_parent_flag = ''N'' ';
        bind_table_2(bind_table_2.COUNT+1).bind_value :=  UPPER(p_country_code);
      END IF;

      l_where_6 := l_where_6 ||' AND hg0.'||geo_struct_tbl(ll_index).v_element_col||'_id = hg'||ll_index||'.geography_id'
                   ||' AND hg'||ll_index||'.geography_use = hg'||to_char(l_priv_valid_index_6)||'.geography_use'
       	           ||' AND hg'||ll_index||'.geography_type = :x_'||ll_index||'_1 '
       	           ||' AND UPPER(hg'||ll_index||'.identifier_value) LIKE :x_'||ll_index||'_2 ';

      bind_table_2(bind_table_2.COUNT+1).bind_value :=  geo_struct_tbl(ll_index).v_geo_type;
      bind_table_2(bind_table_2.COUNT+1).bind_value :=  geo_struct_tbl(ll_index).v_param_value;

      -- update previus valid index to use in building where clause
	  l_priv_valid_index_6 := ll_index;
     END IF;

     -- 2nd select stmt
     IF (ll_sql_id = 2) THEN

	  l_from_7 := l_from_7 ||', hz_geography_identifiers hg'||ll_index;

      -- we are adding country_code in where clause. This has to be done only once
      -- so putting the check of index = 1
      IF (ll_index = 1) THEN
  	    l_where_7 := ' WHERE hg0.geography_use = ''MASTER_REF'' '||
	                 ' AND   SYSDATE between hg0.start_date and hg0.end_date '||
	                 ' AND   upper(hg0.country_code)  = :x_country_code_2 ' ||
	                 ' AND   hg0.multiple_parent_flag = ''N'' ' ;
        bind_table_2(bind_table_2.COUNT+1).bind_value :=  UPPER(p_country_code);
      END IF;

      l_where_7 := l_where_7 ||' AND hg0.'||geo_struct_tbl(ll_index).v_element_col||'_id = hg'||ll_index||'.geography_id'
                   ||' AND hg'||ll_index||'.geography_use = hg'||to_char(l_priv_valid_index_7)||'.geography_use'
       	           ||' AND hg'||ll_index||'.geography_type = :x_'||ll_index||'_11 '
       	           ||' AND UPPER(hg'||ll_index||'.identifier_value) LIKE :x_'||ll_index||'_12 ';

      bind_table_2(bind_table_2.COUNT+1).bind_value :=  geo_struct_tbl(ll_index).v_geo_type;
      bind_table_2(bind_table_2.COUNT+1).bind_value :=  geo_struct_tbl(ll_index).v_param_value;
      -- update previus valid index to use in building where clause
	  l_priv_valid_index_7 := ll_index;
     END IF;

  END create_where_2_clause_pvt;

  ---------------------------------------------------------------------+
  -- Main insert procedure which populates Final plsql table geo_suggest_tbl
  ---------------------------------------------------------------------+
  PROCEDURE  insert_in_geo_suggest_tbl (pv_geo_data_count   NUMBER,
                                         pv_geo_rec_tab_col  VARCHAR2,
                                         pv_geo_rec_geo_name VARCHAR2,
                                         pv_geo_rec_geo_id   NUMBER,
                                         pv_geo_rec_geo_code VARCHAR2)
  IS
   pv_geo_rec_geo_type VARCHAR2(100);
   lv_geo_rec_geo_name VARCHAR2(360);
  BEGIN
    IF (pv_geo_rec_tab_col IS NOT NULL
	   ) THEN

	  pv_geo_rec_geo_type := get_mapped_geo_type(pv_geo_rec_tab_col);
      IF (pv_geo_rec_geo_code IN ('MISSING','UNKNOWN')) THEN  -- if code is missing or unknown
	    lv_geo_rec_geo_name := NULL;
	  ELSE
	    lv_geo_rec_geo_name := pv_geo_rec_geo_name;
	  END IF;

	  CASE pv_geo_rec_tab_col
        WHEN 'COUNTRY' THEN
          geo_suggest_tbl(pv_geo_data_count).country    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).country_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).country_code := pv_geo_rec_geo_code;
          geo_suggest_tbl(pv_geo_data_count).country_geo_type := pv_geo_rec_geo_type;
        WHEN 'STATE' THEN
          geo_suggest_tbl(pv_geo_data_count).state    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).state_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).state_code := pv_geo_rec_geo_code;
          geo_suggest_tbl(pv_geo_data_count).state_geo_type := pv_geo_rec_geo_type;
        WHEN 'PROVINCE' THEN
          geo_suggest_tbl(pv_geo_data_count).province    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).province_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).province_code := pv_geo_rec_geo_code;
          geo_suggest_tbl(pv_geo_data_count).province_geo_type := pv_geo_rec_geo_type;
        WHEN 'COUNTY' THEN
          geo_suggest_tbl(pv_geo_data_count).county    := INITCAP(lv_geo_rec_geo_name);
          geo_suggest_tbl(pv_geo_data_count).county_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).county_geo_type := pv_geo_rec_geo_type;
        WHEN 'CITY' THEN
          geo_suggest_tbl(pv_geo_data_count).city    := INITCAP(lv_geo_rec_geo_name);
          geo_suggest_tbl(pv_geo_data_count).city_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).city_geo_type := pv_geo_rec_geo_type;
        WHEN 'POSTAL_CODE' THEN
          geo_suggest_tbl(pv_geo_data_count).postal_code    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).postal_code_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).postal_code_geo_type := pv_geo_rec_geo_type;
        WHEN 'POSTAL_PLUS4_CODE' THEN
          geo_suggest_tbl(pv_geo_data_count).postal_plus4_code    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).postal_plus4_code_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).postal_plus4_code_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE1' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute1    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute1_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute1_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE2' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute2    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute2_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute2_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE3' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute3    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute3_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute3_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE4' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute4    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute4_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute4_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE5' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute5    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute5_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute5_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE6' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute6    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute6_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute6_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE7' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute7    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute7_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute7_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE8' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute8    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute8_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute8_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE9' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute9    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute9_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute9_geo_type := pv_geo_rec_geo_type;
        WHEN 'ATTRIBUTE10' THEN
          geo_suggest_tbl(pv_geo_data_count).attribute10    := lv_geo_rec_geo_name;
          geo_suggest_tbl(pv_geo_data_count).attribute10_geo_id := pv_geo_rec_geo_id;
          geo_suggest_tbl(pv_geo_data_count).attribute10_geo_type := pv_geo_rec_geo_type;
        ELSE
          NULL;
      END CASE;
    END IF;
  END insert_in_geo_suggest_tbl;

  ---------------------------------------------------------------------+
  -- Insert procedure which populates intermediate plsql table geo_rec_tbl
  ---------------------------------------------------------------------+
  PROCEDURE  insert_in_geo_rec_tbl (pv_geo_data_count   NUMBER,
                                    pv_geo_rec_element_col  VARCHAR2,
                                    pv_geo_rec_geo_name VARCHAR2,
                                    pv_geo_rec_geo_id   NUMBER,
                                    pv_geo_rec_geo_code VARCHAR2)
  IS
   pv_geo_rec_geo_type VARCHAR2(100);
  BEGIN
    IF (pv_geo_rec_element_col IS NOT NULL) THEN

	  CASE pv_geo_rec_element_col
        WHEN 'GEOGRAPHY_ELEMENT1' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element1    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element1_id := pv_geo_rec_geo_id;
          geo_rec_tbl(pv_geo_data_count).geography_element1_code := pv_geo_rec_geo_code;
        WHEN 'GEOGRAPHY_ELEMENT2' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element2    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element2_id := pv_geo_rec_geo_id;
          geo_rec_tbl(pv_geo_data_count).geography_element2_code := pv_geo_rec_geo_code;
        WHEN 'GEOGRAPHY_ELEMENT3' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element3    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element3_id := pv_geo_rec_geo_id;
          geo_rec_tbl(pv_geo_data_count).geography_element3_code := pv_geo_rec_geo_code;
        WHEN 'GEOGRAPHY_ELEMENT4' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element4    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element4_id := pv_geo_rec_geo_id;
          geo_rec_tbl(pv_geo_data_count).geography_element4_code := pv_geo_rec_geo_code;
        WHEN 'GEOGRAPHY_ELEMENT5' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element5    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element5_id := pv_geo_rec_geo_id;
          geo_rec_tbl(pv_geo_data_count).geography_element5_code := pv_geo_rec_geo_code;
        WHEN 'GEOGRAPHY_ELEMENT6' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element6    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element6_id := pv_geo_rec_geo_id;
        WHEN 'GEOGRAPHY_ELEMENT7' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element7    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element7_id := pv_geo_rec_geo_id;
        WHEN 'GEOGRAPHY_ELEMENT8' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element8    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element8_id := pv_geo_rec_geo_id;
        WHEN 'GEOGRAPHY_ELEMENT9' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element9    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element9_id := pv_geo_rec_geo_id;
        WHEN 'GEOGRAPHY_ELEMENT10' THEN
          geo_rec_tbl(pv_geo_data_count).geography_element10    := pv_geo_rec_geo_name;
          geo_rec_tbl(pv_geo_data_count).geography_element10_id := pv_geo_rec_geo_id;
        ELSE NULL;
      END CASE;
    END IF;
  END insert_in_geo_rec_tbl;

  ----------------------------------------------------------------------+
  -- Procedure to move data from intermediate table geo_rec_tbl to Final table
  -- geo_suggest_tbl
  ----------------------------------------------------------------------+
  PROCEDURE move_from_geo_rec_to_suggest (ll_geo_rec_index IN INTEGER,
  										  ll_geo_suggest_index IN INTEGER) IS
    ll_geo_rec geo_rec_type;
  BEGIN
    ll_geo_rec := geo_rec_tbl(ll_geo_rec_index);

     -- fetch values and do processing
     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT1
     -----------------------------------------------------------------+
     -- assignments to suggest table
     IF (ll_geo_rec.geography_element1 IS NOT NULL) THEN
       -- look for mapping for this column
       l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT1');
	   l_geo_rec_geo_name := ll_geo_rec.geography_element1;
       l_geo_rec_geo_id   := ll_geo_rec.geography_element1_id;
       l_geo_rec_geo_code := ll_geo_rec.geography_element1_code;
       insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT2
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT2');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element2;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element2_id;
          l_geo_rec_geo_code := ll_geo_rec.geography_element2_code;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT3
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT3');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element3;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element3_id;
          l_geo_rec_geo_code := ll_geo_rec.geography_element3_code;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT4
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT4');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element4;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element4_id;
          l_geo_rec_geo_code := ll_geo_rec.geography_element4_code;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT5
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT5');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element5;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element5_id;
          l_geo_rec_geo_code := ll_geo_rec.geography_element5_code;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;
     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT6
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT6');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element6;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element6_id;
          l_geo_rec_geo_code := NULL;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT7
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT7');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element7;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element7_id;
          l_geo_rec_geo_code := NULL;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT8
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT8');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element8;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element8_id;
          l_geo_rec_geo_code := NULL;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT9
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT9');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element9;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element9_id;
          l_geo_rec_geo_code := NULL;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;

     -----------------------------------------------------------------+
     -- GEOGRAPHY_ELEMENT10
     -----------------------------------------------------------------+
     -- look for mapping for this column
     l_geo_rec_tab_col  := get_mapped_tab_col('GEOGRAPHY_ELEMENT10');

     IF (l_geo_rec_tab_col IS NOT NULL) THEN
	      l_geo_rec_geo_name := ll_geo_rec.geography_element10;
          l_geo_rec_geo_id   := ll_geo_rec.geography_element10_id;
          l_geo_rec_geo_code := NULL;

       IF (l_geo_rec_geo_name IS NOT NULL) THEN
         insert_in_geo_suggest_tbl(ll_geo_suggest_index,
	                              l_geo_rec_tab_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
       END IF;

	 END IF;
  END move_from_geo_rec_to_suggest;

  -----------------------------------------------------------------------------+
  -- Procedure to insert multiple parent records in geo_rec_tbl intermediate
  -- plsql table
  -----------------------------------------------------------------------------+
  PROCEDURE insert_mp_in_geo_rec_proc (ll_geo_data_count IN NUMBER,
			                           ll_geo_type       IN VARCHAR2,
                                       ll_geo_name  	  IN VARCHAR2,
                                       ll_geo_code 	  IN VARCHAR2,
                                       ll_geo_id   	  IN NUMBER,
									   x_insert_geo_suggest_rec OUT nocopy VARCHAR2) IS
   ll_mapped_param_value    VARCHAR2(100);
   ll_mapped_element_col    VARCHAR2(100);
  BEGIN
       -- look for mapping for this column
       ll_mapped_element_col := get_element_col_for_geo_type(ll_geo_type);
       -- for mapped table column, check if there is a parameter passed
       -- if it is passed, Insert only if the value matches that passed parameter.
       -- if not passed, insert it anyway.
       IF (ll_mapped_element_col IS NOT NULL) THEN
         ll_mapped_param_value := get_map_param_val_for_element(ll_mapped_element_col);
     	 l_geo_rec_geo_name := ll_geo_name;
       	 l_geo_rec_geo_id   := ll_geo_id;
       	 l_geo_rec_geo_code := ll_geo_code;
         IF ((ll_mapped_param_value IS NOT NULL) AND (l_search_type <> 'LEVEL4_UNION_LEVEL5_SEARCH')) THEN
            IF (
		      (ll_mapped_param_value = UPPER(SUBSTR(l_geo_rec_geo_name,1,LENGTH(ll_mapped_param_value)-1)||'%'))
              OR (ll_mapped_param_value = UPPER(SUBSTR(l_geo_rec_geo_code,1,LENGTH(ll_mapped_param_value)-1)||'%'))
              ) THEN
       		   insert_in_geo_rec_tbl(ll_geo_data_count,
	                              ll_mapped_element_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
            ELSE
              x_insert_geo_suggest_rec := 'N';
            END IF;
        ELSE -- if mapped parameter not passed, insert it
       		   insert_in_geo_rec_tbl(ll_geo_data_count,
	                              ll_mapped_element_col,
	                              l_geo_rec_geo_name,
	                              l_geo_rec_geo_id,
	                              l_geo_rec_geo_code
							      );
		END IF;
	  END IF;

  END insert_mp_in_geo_rec_proc;

  -----------------------------------------------------------------------------+
  -- Procedure to handle multiple parents case.
  -- Input is geography_id for which there are multiple parents
  -- It will call insert_mp_in_geo_rec_proc to insert data in
  -- geo_rec table (intermediate plsql table)
  -----------------------------------------------------------------------------+
  PROCEDURE multiple_parent_proc (ll_geo_id hz_geographies.geography_id%TYPE
                                 ,ll_geo_type hz_geographies.geography_type%TYPE) IS
   l_structure_level_count NUMBER;
   l_insert_geo_valid_rec_final VARCHAR2(1);
   l_insert_geo_suggest_rec VARCHAR2(1);

   -- this execption will occur if hierarchy node information does not
   -- match geography structure levels i.e. some level is missing in hierarchy node
   -- or for some reason we are not able to fetch data from hierarchy nodes
   -- for multi parents case.
   INCONSISTENT_DATATYPE EXCEPTION;
   PRAGMA EXCEPTION_INIT(INCONSISTENT_DATATYPE, -932);

  BEGIN

      -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Trying to fetch Parents for Multi Parent record for Geo id:'||
				                      ll_geo_id||' and geo type '||ll_geo_type ,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;


    -- get the structure levels for which we have to build the query
    -- result here will be 1 less since for country no structure level is defined.
    SELECT COUNT(*)
    INTO   l_structure_level_count
	FROM   hz_geo_structure_levels
	WHERE  country_code = upper(p_country_code)
	CONNECT BY geography_type = PRIOR parent_geography_type
	AND    country_code = upper(p_country_code)
	START WITH geography_type = ll_geo_type
	AND    country_code = upper(p_country_code);

	IF (l_structure_level_count > 0) THEN
	  -- build the select statement
	  l_select_mp :=  'SELECT  distinct p0.geography_id , p0.geography_name ,'
                    ||'p0.geography_code , p0.geography_type '
                    ||',p1.geography_id , p1.geography_name ,'
                    ||'p1.geography_code , p1.geography_type ';
      l_from_mp := ' FROM   hz_geographies p0 '
	                ||', hz_hierarchy_nodes hn1'
                    ||', hz_geographies p1 ';
      l_where_mp := ' WHERE  hn1.child_id = p0.geography_id '
            	 	||' AND  p0.geography_use = ''MASTER_REF'' '
            		||' AND  SYSDATE BETWEEN p0.start_date AND p0.end_date '
            		||' AND  hn1.child_id = :x_missing_geo_id '
            		||' AND  hn1.hierarchy_type = ''MASTER_REF'' '
            		||' AND  hn1.level_number = 1 '
            		||' AND  hn1.child_table_name = ''HZ_GEOGRAPHIES'' '
            		||' AND  SYSDATE BETWEEN hn1.effective_start_date AND hn1.effective_end_date '
            		||' AND  NVL(hn1.status,''A'') = ''A'' '
            		||' AND  hn1.parent_table_name = ''HZ_GEOGRAPHIES'' '
            		||' AND  hn1.parent_id = p1.geography_id '
            		||' AND  p1.geography_use = ''MASTER_REF'' '
            		||' AND  SYSDATE BETWEEN p1.start_date AND p1.end_date ';

       l_last_index_mp := 1;

       --build select from where cluase for other levels as well
       IF (l_structure_level_count > 1) THEN
         FOR i IN 2..l_structure_level_count LOOP
           l_select_mp := l_select_mp ||',p'||i||'.geography_id , p'||i||'.geography_name '
                                      ||',p'||i||'.geography_code, p'||i||'.geography_type ';

           l_from_mp := l_from_mp ||', hz_hierarchy_nodes hn'||i
                                  ||', hz_geographies p'||i ;

           l_where_mp := l_where_mp ||' AND hn'||i||'.child_id = hn'||l_last_index_mp||'.parent_id '
            		  	 			||' AND hn'||i||'.hierarchy_type = ''MASTER_REF'' '
            						||' AND hn'||i||'.level_number = 1 '
            						||' AND hn'||i||'.child_table_name = ''HZ_GEOGRAPHIES'' '
            						||' AND SYSDATE BETWEEN hn'||i||'.effective_start_date AND hn'||i||'.effective_end_date '
            		                ||' AND NVL(hn'||i||'.status,''A'') = ''A'' '
            						||' AND hn'||i||'.parent_table_name = ''HZ_GEOGRAPHIES'' '
            						||' AND hn'||i||'.parent_id = p'||i||'.geography_id '
            						||' AND p'||i||'.geography_use = ''MASTER_REF'' '
            						||' AND SYSDATE BETWEEN p'||i||'.start_date AND p'||i||'.end_date ';

           l_last_index_mp := i;

         END LOOP;

         -- pad rest of the columns in select stmt (to be fetched in rec_mp record) to null
         -- l_total_null_cols_mp := (10-(l_structure_level_count))*4;
         l_total_null_cols_mp := (40 - (4 * (l_structure_level_count+1)));

         IF (l_total_null_cols_mp > 0) THEN
	       FOR i IN 1..l_total_null_cols_mp LOOP
	         l_select_mp := l_select_mp ||', NULL ';
	       END LOOP;
	     END IF;

         l_sql_stmt_mp := l_select_mp||l_from_mp||l_where_mp;
         -- ns_debug.put_line(' Multiple Parent Query ');
         -- ns_debug.put_line(' ======================');
         -- ns_debug.put_line(l_sql_stmt_mp);
         -- ns_debug.put_line(' ======================');

         -----------------debug statements---------------+
         -- FND Logging for debug purpose
  	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             hz_utility_v2pub.debug
	               (p_message      => 'Total NULL cols appended:'||l_total_null_cols_mp,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
         END IF;

         -- FND Logging for debug purpose
   	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Multiparent Query :'||l_sql_stmt_mp ,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
         END IF;
         ----------------end debug statements------------+

         -- execute the query
         OPEN cv_mp FOR l_sql_stmt_mp USING ll_geo_id;
           LOOP
             FETCH cv_mp INTO rec_mp;
             EXIT WHEN cv_mp%NOTFOUND;
             -- l_geo_data_count is counter for row. It is same the one used
			 -- in main query
			 l_geo_data_count := geo_rec_tbl.COUNT+1;
             EXIT WHEN l_geo_data_count > l_max_fetch_count; -- no. of records retrieved
			 -- ns_debug.put_line('Multiple parent data');
			 -- ns_debug.put_line('====================');
			 -- ns_debug.put_line(l_geo_data_count||':1:'||rec_mp.geo_name_1||':'||rec_mp.geo_code_1
			/*						 ||':2:'||rec_mp.geo_name_2||':'||rec_mp.geo_code_2
									 ||':3:'||rec_mp.geo_name_3||':'||rec_mp.geo_code_3
									 ||':4:'||rec_mp.geo_name_4||':'||rec_mp.geo_code_4
									 ||':5:'||rec_mp.geo_name_5||':'||rec_mp.geo_code_5
									 ||':6:'||rec_mp.geo_name_6||':'||rec_mp.geo_code_6
									 ||':7:'||rec_mp.geo_name_7||':'||rec_mp.geo_code_7
									 ||':8:'||rec_mp.geo_name_8||':'||rec_mp.geo_code_8
									 ||':9:'||rec_mp.geo_name_9||':'||rec_mp.geo_code_9
									 ||':10:'||rec_mp.geo_name_10||':'||rec_mp.geo_code_10);
             */
		     -- fetch values and do processing
             -----------------------------------------------------------------+
             -- GEO_ID_1
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF (rec_mp.geo_id_1 IS NOT NULL) THEN
               -- insert this value in geo_rec_tbl for geo_id column
               geo_rec_tbl(l_geo_data_count).geography_id := rec_mp.geo_id_1;
               geo_rec_tbl(l_geo_data_count).geography_name := rec_mp.geo_name_1;
               geo_rec_tbl(l_geo_data_count).geography_code := rec_mp.geo_code_1;
               geo_rec_tbl(l_geo_data_count).geography_type := rec_mp.geo_type_1;
			   geo_rec_tbl(l_geo_data_count).multiple_parent_flag := 'Y';

               -- do regular insert
			   insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_1,
                                               ll_geo_name => rec_mp.geo_name_1,
                                               ll_geo_code => rec_mp.geo_code_1,
                                               ll_geo_id   => rec_mp.geo_id_1,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
             END IF;
             -----------------------------------------------------------------+
             -- GEO_ID_2
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_2 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_2,
                                               ll_geo_name => rec_mp.geo_name_2,
                                               ll_geo_code => rec_mp.geo_code_2,
                                               ll_geo_id   => rec_mp.geo_id_2,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_3
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_3 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_3,
                                               ll_geo_name => rec_mp.geo_name_3,
                                               ll_geo_code => rec_mp.geo_code_3,
                                               ll_geo_id   => rec_mp.geo_id_3,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_4
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_4 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_4,
                                               ll_geo_name => rec_mp.geo_name_4,
                                               ll_geo_code => rec_mp.geo_code_4,
                                               ll_geo_id   => rec_mp.geo_id_4,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_5
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_5 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_5,
                                               ll_geo_name => rec_mp.geo_name_5,
                                               ll_geo_code => rec_mp.geo_code_5,
                                               ll_geo_id   => rec_mp.geo_id_5,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
 			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_6
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_6 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_6,
                                               ll_geo_name => rec_mp.geo_name_6,
                                               ll_geo_code => rec_mp.geo_code_6,
                                               ll_geo_id   => rec_mp.geo_id_6,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_7
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_7 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_7,
                                               ll_geo_name => rec_mp.geo_name_7,
                                               ll_geo_code => rec_mp.geo_code_7,
                                               ll_geo_id   => rec_mp.geo_id_7,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_8
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_8 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_8,
                                               ll_geo_name => rec_mp.geo_name_8,
                                               ll_geo_code => rec_mp.geo_code_8,
                                               ll_geo_id   => rec_mp.geo_id_8,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_9
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_9 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_9,
                                               ll_geo_name => rec_mp.geo_name_9,
                                               ll_geo_code => rec_mp.geo_code_9,
                                               ll_geo_id   => rec_mp.geo_id_9,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
		 	 END IF;

             -----------------------------------------------------------------+
             -- GEO_ID_10
             -----------------------------------------------------------------+
             -- assignments to suggest table
             IF ((rec_mp.geo_id_10 IS NOT NULL) AND (NVL(l_insert_geo_valid_rec_final,'Y') <> 'N'))
			 THEN
               insert_mp_in_geo_rec_proc (ll_geo_data_count => l_geo_data_count,
			                                   ll_geo_type => rec_mp.geo_type_10,
                                               ll_geo_name => rec_mp.geo_name_10,
                                               ll_geo_code => rec_mp.geo_code_10,
                                               ll_geo_id   => rec_mp.geo_id_10,
											   x_insert_geo_suggest_rec => l_insert_geo_suggest_rec);
               IF (l_insert_geo_suggest_rec = 'N') THEN
                 l_insert_geo_valid_rec_final := 'N';
               END IF;
			 END IF;

             -- delete whole row if l_insert_geo_suggest_rec is set to N
             IF (l_insert_geo_valid_rec_final = 'N') THEN
               geo_rec_tbl.DELETE(l_geo_data_count);
               l_insert_geo_valid_rec_final := 'Y';
               l_insert_geo_suggest_rec := 'Y';
			 END IF;

           END LOOP;
         CLOSE cv_mp;

       END IF;
	END IF;

    -- FND Logging for debug purpose
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Done with Multi Parent Case...' ,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
    END IF;

  EXCEPTION
    WHEN INCONSISTENT_DATATYPE THEN
	  NULL;
      -- FND Logging for debug purpose
  	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'INCONSISTENT_DATATYPE Exception in multiple_parent_proc.'||
				                      'This has occured because HZ_HIERARCHY_NODES data is not '||
									  'correctly setup for geography id:'||ll_geo_id ,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;
	  -- ns_debug.put_line('hz_hierarchy_nodes data is not correctly setup for geography id:'||ll_geo_id);
	WHEN OTHERS THEN
	  NULL;
      -- FND Logging for debug purpose
  	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => SUBSTR('Exception OTHERS in multiple_parent_proc.'||
				                      'HZ_HIERARCHY_NODES data is not '||
									  'correctly setup for geography id:'||ll_geo_id||':'||SQLERRM,1,255),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;
 	  -- ns_debug.put_line('Error in fetching hz_hierarchy_nodes data for geography id:'||ll_geo_id);
  END multiple_parent_proc;

  ---------------------------------------------------------------------+
  -- Main Search procedure which builds sql stmt for Search 1 and Search 2
  -- and executes query
  ---------------------------------------------------------------------+
  PROCEDURE search_routine_pvt (pt_search_type       IN  VARCHAR2,
                                pt_bind_table        IN  bind_tbl_type,
								pt_success_geo_level IN NUMBER DEFAULT NULL)
  IS
    pp_search_type VARCHAR2 (100);
    pp_bind_table bind_tbl_type;
  BEGIN
      pp_search_type := pt_search_type;
 	  pp_bind_table := pt_bind_table;

	  -- Select clause
      -- NOTE : IF ANY element is added or deleted in select clause, modify geo_rec_type
      -- record type accordingly.
	  l_select := 'SELECT DISTINCT hg0.GEOGRAPHY_ID, hg0.GEOGRAPHY_TYPE, hg0.GEOGRAPHY_NAME,'||
       		   	  'hg0.GEOGRAPHY_CODE, hg0.MULTIPLE_PARENT_FLAG, hg0.COUNTRY_CODE,'||
       			  'hg0.GEOGRAPHY_ELEMENT1, hg0.GEOGRAPHY_ELEMENT1_ID, hg0.GEOGRAPHY_ELEMENT1_CODE,'||
				  'hg0.GEOGRAPHY_ELEMENT2, hg0.GEOGRAPHY_ELEMENT2_ID, hg0.GEOGRAPHY_ELEMENT2_CODE,'||
       			  'hg0.GEOGRAPHY_ELEMENT3, hg0.GEOGRAPHY_ELEMENT3_ID, hg0.GEOGRAPHY_ELEMENT3_CODE,'||
       			  'hg0.GEOGRAPHY_ELEMENT4, hg0.GEOGRAPHY_ELEMENT4_ID, hg0.GEOGRAPHY_ELEMENT4_CODE,'||
       			  'hg0.GEOGRAPHY_ELEMENT5, hg0.GEOGRAPHY_ELEMENT5_ID, hg0.GEOGRAPHY_ELEMENT5_CODE,'||
       			  'hg0.GEOGRAPHY_ELEMENT6, hg0.GEOGRAPHY_ELEMENT6_ID,'||
       			  'hg0.GEOGRAPHY_ELEMENT7, hg0.GEOGRAPHY_ELEMENT7_ID,'||
				  'hg0.GEOGRAPHY_ELEMENT8, hg0.GEOGRAPHY_ELEMENT8_ID,'||
       			  'hg0.GEOGRAPHY_ELEMENT9, hg0.GEOGRAPHY_ELEMENT9_ID,'||
       			  'hg0.GEOGRAPHY_ELEMENT10, hg0.GEOGRAPHY_ELEMENT10_ID ';

	  -- from clause
	  l_from := ' FROM hz_geographies hg0 ';

	  -- Mandatory where clause
	  l_where := ' WHERE hg0.geography_use = ''MASTER_REF'' '||
	             ' AND   SYSDATE between hg0.start_date and hg0.end_date '||
	             ' AND   hg0.country_code  = :x_country_code ' ||
	             ' AND   hg0.multiple_parent_flag = ''N'' ' ;

      l_order_by := NULL;

      -- we are making sure that we are fetching the leaf nodes for the passed parameters
      -- i.e. if only county is passed in above example, we want to fetch rows
      -- only for Country -> State -> County
      FOR k IN l_max_passed_element_col_value+1..l_max_passed_element_col_value+3 LOOP
        IF k < 11 THEN -- we have only 10 elements
		  l_where_3 := l_where_3||' AND hg0.geography_element'||k||' is NULL ';
		END IF;
  	  END LOOP;

      -- make sure when doing detailed child search we are fetching only
      -- those records which have value till the last mapped column
      -- this search we are doing after only making sure we have only 1
	  -- unique record identified for passed parameters
	  l_where_4 := 'AND hg0.geography_element'||l_max_mapped_element_col_value||' is NOT NULL ';

      ------------------
      -- select stmt to fetch the multiple parent records for passed value
      -- once record is fetched, seperate multiple parent procedure will get all
      -- corresponding data for that
      l_sql_stmt_2 := ' UNION ALL '||l_select ||l_from||' , hz_geography_identifiers hg1 '
      			   	  ||' WHERE hg0.geography_use = ''MASTER_REF'' '
	             	  ||' AND SYSDATE between hg0.start_date and hg0.end_date '
	             	  ||' AND upper(hg0.country_code)  = :x_country_code_101 '
                      ||' AND hg0.multiple_parent_flag = ''Y'' '
					  ||' AND hg0.geography_id = hg1.geography_id '
					  ||' AND hg1.geography_use = ''MASTER_REF'' '
					  ||' AND hg1.geography_type = :x_geo_type_101 '
					  ||' AND UPPER(hg1.identifier_value) LIKE :x_geo_name_101 '  ;

      ------------------
      -- select stmt to fetch the multiple parent records for passed value
      -- once record is fetched, seperate multiple parent procedure will get all
      -- corresponding data for that union case where we are doing max mapped element -1
      -- i.e. if Foster City + 94065 is passed then, check for Foster City for Multiple
      -- Parent case.
      l_sql_stmt_3 := ' UNION ALL '||l_select ||l_from||' , hz_geography_identifiers hg1 '
      			   	  ||' WHERE hg0.geography_use = ''MASTER_REF'' '
	             	  ||' AND SYSDATE between hg0.start_date and hg0.end_date '
	             	  ||' AND upper(hg0.country_code)  = :x_country_code_102 '
                      ||' AND hg0.multiple_parent_flag = ''Y'' '
					  ||' AND hg0.geography_id = hg1.geography_id '
					  ||' AND hg1.geography_use = ''MASTER_REF'' '
					  ||' AND hg1.geography_type = :x_geo_type_102 '
					  ||' AND UPPER(hg1.identifier_value) LIKE :x_geo_name_102 '  ;

	  ------------------

      -- 1. do search for all passed and mapped params if search type = ALL_PASSED_PARAM_SEARCH
      -- 2. if 0 record is found, then if more than 3 elements are mapped and last mapped element is passed
	  --    as parameter, then do search for combinations of element1 + element2 + Last Mapped(and passed) element
	  --    UNION element1 + element2 + (Last-1) Mapped (and passed) element
      --    search type = LEVEL4_UNION_LEVEL5_SEARCH
      IF (pp_search_type = 'ALL_PASSED_PARAM_SEARCH') THEN
	    -- dynamic where clause built before for all passed parameters
  	    IF (l_lowest_passed_geo_type IS NOT NULL) THEN
          l_where_3 := ' AND hg0.geography_type = :x_last_geo_type ';
          pp_bind_table(pp_bind_table.COUNT+1).bind_value := l_lowest_passed_geo_type;
          -- bind for sql stmt 2 also (for multiple parent flag check)
		  pp_bind_table(pp_bind_table.COUNT+1).bind_value := upper(p_country_code);
          pp_bind_table(pp_bind_table.COUNT+1).bind_value := l_lowest_passed_geo_type;
		  pp_bind_table(pp_bind_table.COUNT+1).bind_value := l_lowest_passed_geo_value;
	      l_where := l_where||l_where_5||l_where_3;
	      l_from  := l_from ||l_from_5;
          l_sql_stmt := l_select||l_from||l_where||l_sql_stmt_2||l_order_by;
        ELSE
          -- here we use old l_where_3 clause because new where3 could not be built
          -- ns_debug.put_line('Using Old where clause ');
	      l_where := l_where||l_where_5||l_where_3;
	      l_from  := l_from ||l_from_5;
          l_sql_stmt := l_select||l_from||l_where||l_order_by;
        END IF;
      ELSIF (pp_search_type = 'SEARCH_FROM_TOP') THEN
          l_where_3 := ' AND hg0.geography_type = :x_last_geo_type ';
          pp_bind_table(pp_bind_table.COUNT+1).bind_value := get_geo_type_from_element_col('GEOGRAPHY_ELEMENT'||pt_success_geo_level); --l_lowest_passed_geo_type;
          -- bind for sql stmt 2 also (for multiple parent flag check)
		  pp_bind_table(pp_bind_table.COUNT+1).bind_value := upper(p_country_code);
          pp_bind_table(pp_bind_table.COUNT+1).bind_value := get_geo_type_from_element_col('GEOGRAPHY_ELEMENT'||pt_success_geo_level); --l_lowest_passed_geo_type;
		  pp_bind_table(pp_bind_table.COUNT+1).bind_value := get_map_param_val_for_element('GEOGRAPHY_ELEMENT'||pt_success_geo_level); --l_lowest_passed_geo_value;
	      l_where := l_where||l_where_5||l_where_3;
	      l_from  := l_from ||l_from_5;
          l_sql_stmt := l_select||l_from||l_where||l_sql_stmt_2||l_order_by;
	  ELSIF (pp_search_type = 'LEVEL4_UNION_LEVEL5_SEARCH') THEN
  	    IF (l_lowest_mapped_geo_type IS NOT NULL) THEN
          -- bind for sql stmt 2 also (for multiple parent flag check)
		  pp_bind_table(pp_bind_table.COUNT+1).bind_value := upper(p_country_code);
          pp_bind_table(pp_bind_table.COUNT+1).bind_value := l_lowest_passed_geo_type;
		  pp_bind_table(pp_bind_table.COUNT+1).bind_value := l_lowest_passed_geo_value;
	    ELSE
	      l_sql_stmt_2 := NULL;
	    END IF;

	    IF (l_count_for_where_clause_3 = 2) THEN
           -- bind for sql stmt 3 also (for multiple parent flag check)
           -- at that time need to provide addditional where clause in l_where_7
           -- to not pick multi parent flag = Y record
		     pp_bind_table(pp_bind_table.COUNT+1).bind_value := upper(p_country_code);
          	 pp_bind_table(pp_bind_table.COUNT+1).bind_value := get_geo_type_from_element_col('GEOGRAPHY_ELEMENT'||to_char(l_max_mapped_element_col_value-1));
		  	 pp_bind_table(pp_bind_table.COUNT+1).bind_value := get_map_param_val_for_element('GEOGRAPHY_ELEMENT'||to_char(l_max_mapped_element_col_value-1));
	    ELSE
	       	 l_sql_stmt_3 := NULL;
	    END IF;

	    -- order of SQL stmt is very imp as valriables are bound in the same order
	    IF ((l_count_for_where_clause_2 = 2) AND (l_count_for_where_clause_3 <> 2)) THEN
          l_sql_stmt := l_select||l_from||l_from_6||l_where_6||l_sql_stmt_2||l_order_by;
        ELSIF
          ((l_count_for_where_clause_2 <> 2) AND (l_count_for_where_clause_3 = 2)) THEN
          l_sql_stmt := l_select||l_from||l_from_7||l_where_7||l_sql_stmt_2||l_sql_stmt_3||l_order_by;
        ELSIF
          ((l_count_for_where_clause_2 = 2) AND (l_count_for_where_clause_3 = 2)) THEN
          l_sql_stmt := l_select||l_from||l_from_6||l_where_6
                        ||' UNION '||
		                l_select||l_from||l_from_7||l_where_7||l_sql_stmt_2||l_sql_stmt_3||l_order_by;
        END IF;
	  END IF;

      l_bind_counter := TO_NUMBER(pp_bind_table.COUNT);

     -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Search Type:'||pp_search_type||
				                      ', No. of Bind Values:'||TO_CHAR(l_bind_counter),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

    /*
       ns_debug.put_line('Search Type :'||pp_search_type);
       ns_debug.put_line('Bind_counter:'||l_bind_counter);
       IF (l_bind_counter > 0) THEN
           ns_debug.put_line('BIND VALUES ');
           ns_debug.put_line('============');
 	      FOR i IN pp_bind_table.FIRST..pp_bind_table.LAST  LOOP
             ns_debug.put_line(i||'='||pp_bind_table(i).bind_value);
            NULL;
 	      END LOOP;
        END IF;
           ns_debug.put_line('Max Passed Column Value : '||l_max_passed_element_col_value);
           ns_debug.put_line('Max Mapped Column Value : '||l_max_mapped_element_col_value);
           ns_debug.put_line('Length of SELECT Clause : '||LENGTH(l_select));
           ns_debug.put_line('Length of FROM Clause   : '||LENGTH(l_from));
           ns_debug.put_line('Length of WHERE Clause  : '||LENGTH(l_where));
           ns_debug.put_line('Total Length of SQL Stmt: '||LENGTH(l_sql_stmt));
           ns_debug.put_line('SQL Statement ');
           ns_debug.put_line('============= ');
           ns_debug.put_line(l_sql_stmt);
    */

	--execute query for the resource based on bind variables to use
    IF (l_sql_stmt IS NOT NULL) THEN
	   IF(l_bind_counter = 1) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value;
	   ELSIF(l_bind_counter = 2) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value;
	   ELSIF(l_bind_counter = 3) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value;
	   ELSIF(l_bind_counter = 4) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value;
	   ELSIF(l_bind_counter = 5) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value;
	   ELSIF(l_bind_counter = 6) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value;
	   ELSIF(l_bind_counter = 7) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value;
	   ELSIF(l_bind_counter = 8) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value;
	   ELSIF(l_bind_counter = 9) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
	 									  pp_bind_table(9).bind_value;

	   ELSIF(l_bind_counter = 10) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value;
	   ELSIF(l_bind_counter = 11) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value;
	   ELSIF(l_bind_counter = 12) THEN
	     OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value;
	    ELSIF(l_bind_counter = 13) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value;
	    ELSIF(l_bind_counter = 14) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value;
	    ELSIF(l_bind_counter = 15) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value;
	    ELSIF(l_bind_counter = 16) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value;

	    ELSIF(l_bind_counter = 17) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value;
	    ELSIF(l_bind_counter = 18) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value;
	    ELSIF(l_bind_counter = 19) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value;

	    ELSIF(l_bind_counter = 20) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value;
	    ELSIF(l_bind_counter = 21) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value;
	    ELSIF(l_bind_counter = 22) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value;

	    ELSIF(l_bind_counter = 23) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value;
	    ELSIF(l_bind_counter = 24) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value;
	    ELSIF(l_bind_counter = 25) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value;
	    ELSIF(l_bind_counter = 26) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value;
	    ELSIF(l_bind_counter = 27) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value;
	    ELSIF(l_bind_counter = 28) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value;
	    ELSIF(l_bind_counter = 29) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value;
	    ELSIF(l_bind_counter = 30) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value;
	    ELSIF(l_bind_counter = 31) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value;
	    ELSIF(l_bind_counter = 32) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value;
	    ELSIF(l_bind_counter = 33) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value;
	    ELSIF(l_bind_counter = 34) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value;
	    ELSIF(l_bind_counter = 35) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value;
	    ELSIF(l_bind_counter = 36) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value;
	    ELSIF(l_bind_counter = 37) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value;
	    ELSIF(l_bind_counter = 38) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value;
	    ELSIF(l_bind_counter = 39) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value;
	    ELSIF(l_bind_counter = 40) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value;
	    ELSIF(l_bind_counter = 41) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value;
	    ELSIF(l_bind_counter = 42) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value;
	    ELSIF(l_bind_counter = 43) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value;
	    ELSIF(l_bind_counter = 44) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value;
	    ELSIF(l_bind_counter = 45) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value,
										  pp_bind_table(45).bind_value;
	    ELSIF(l_bind_counter = 46) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value,
										  pp_bind_table(45).bind_value,
										  pp_bind_table(46).bind_value;
	    ELSIF(l_bind_counter = 47) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value,
										  pp_bind_table(45).bind_value,
										  pp_bind_table(46).bind_value,
										  pp_bind_table(47).bind_value;
	    ELSIF(l_bind_counter = 48) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value,
										  pp_bind_table(45).bind_value,
										  pp_bind_table(46).bind_value,
										  pp_bind_table(47).bind_value,
										  pp_bind_table(48).bind_value;
	    ELSIF(l_bind_counter = 49) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value,
										  pp_bind_table(45).bind_value,
										  pp_bind_table(46).bind_value,
										  pp_bind_table(47).bind_value,
										  pp_bind_table(48).bind_value,
										  pp_bind_table(49).bind_value;
	    ELSIF(l_bind_counter = 50) THEN
	      OPEN geo_cv FOR l_sql_stmt USING pp_bind_table(1).bind_value,
	     	  		 	 				  pp_bind_table(2).bind_value,
										  pp_bind_table(3).bind_value,
	     	  		 	 				  pp_bind_table(4).bind_value,
										  pp_bind_table(5).bind_value,
	     	  		 	 				  pp_bind_table(6).bind_value,
										  pp_bind_table(7).bind_value,
	     	  		 	 				  pp_bind_table(8).bind_value,
										  pp_bind_table(9).bind_value,
	     	  		 	 				  pp_bind_table(10).bind_value,
										  pp_bind_table(11).bind_value,
	     	  		 	 				  pp_bind_table(12).bind_value,
										  pp_bind_table(13).bind_value,
										  pp_bind_table(14).bind_value,
	     	  		 	 				  pp_bind_table(15).bind_value,
										  pp_bind_table(16).bind_value,
										  pp_bind_table(17).bind_value,
										  pp_bind_table(18).bind_value,
										  pp_bind_table(19).bind_value,
										  pp_bind_table(20).bind_value,
										  pp_bind_table(21).bind_value,
										  pp_bind_table(22).bind_value,
										  pp_bind_table(23).bind_value,
										  pp_bind_table(24).bind_value,
										  pp_bind_table(25).bind_value,
										  pp_bind_table(26).bind_value,
										  pp_bind_table(27).bind_value,
										  pp_bind_table(28).bind_value,
										  pp_bind_table(29).bind_value,
										  pp_bind_table(30).bind_value,
										  pp_bind_table(31).bind_value,
										  pp_bind_table(32).bind_value,
										  pp_bind_table(33).bind_value,
										  pp_bind_table(34).bind_value,
										  pp_bind_table(35).bind_value,
										  pp_bind_table(36).bind_value,
										  pp_bind_table(37).bind_value,
										  pp_bind_table(38).bind_value,
										  pp_bind_table(39).bind_value,
										  pp_bind_table(40).bind_value,
										  pp_bind_table(41).bind_value,
										  pp_bind_table(42).bind_value,
										  pp_bind_table(43).bind_value,
										  pp_bind_table(44).bind_value,
										  pp_bind_table(45).bind_value,
										  pp_bind_table(46).bind_value,
										  pp_bind_table(47).bind_value,
										  pp_bind_table(48).bind_value,
										  pp_bind_table(49).bind_value,
										  pp_bind_table(50).bind_value;
	       END IF;

	     LOOP
	       FETCH geo_cv INTO geo_rec;
	         EXIT WHEN geo_cv%NOTFOUND;
	         l_geo_data_count := geo_rec_tbl.COUNT + 1;
	         EXIT WHEN l_geo_data_count > l_max_fetch_count; -- only suggest these many values
             -- Check if it is a multiple parent record.
             IF (geo_rec.multiple_parent_flag = 'Y') THEN
			   -- If so do a seperate processing
               multiple_parent_proc(geo_rec.geography_id, geo_rec.geography_type);
             ELSE
  		       -- If not multiple parents, fetch values and do processing
               geo_rec_tbl(l_geo_data_count) := geo_rec;
             END IF; -- multiple parent check
	     END LOOP;
	   CLOSE geo_cv;
     END IF; -- end of sql stmt not null check

  END search_routine_pvt;

  -----------------------------------------------------------------------------+
  -- Procedure to check if input and output values match in case of multiple
  -- records. If there is exact match (for complete mapping), then retain that
  -- record and delete other records as we have found what user wanted to enter.
  -- This check will be done before starting output processing.
  -- There is no use suggesting alternates.
  -- Created By Nishant Singhai (29-Sep-2005) for Bug 4633962
  -----------------------------------------------------------------------------+
  PROCEDURE check_exact_match_del_rest IS

	  l_element_matched        VARCHAR2(10);
	  l_check_next_row         VARCHAR2(10);
	  l_exact_row_match_found  VARCHAR2(10);

	  l_geo_suggest_tbl_temp   hz_gnr_pvt.geo_suggest_tbl_type;

	  PROCEDURE priv_match_proc(ll_index number, ll_tbl_value IN VARCHAR2) IS
	  BEGIN
	    IF ((REPLACE(geo_struct_tbl(ll_index).v_param_value,'%','') =
	         UPPER(ll_tbl_value)))
	    THEN
	  	   l_element_matched := 'Y'; -- match
		ELSE
		   l_element_matched := 'N'; -- no match
		END IF;
	  END priv_match_proc;

	  PROCEDURE do_match (p_tab_col IN VARCHAR2, p_suggest_tbl_index IN NUMBER, p_struct_tbl_index IN NUMBER) IS
	      i NUMBER;
	      j NUMBER;
      BEGIN
	      i := p_suggest_tbl_index;
	      j := p_struct_tbl_index;
	      CASE p_tab_col
	        WHEN  'COUNTRY' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).country_code);
		    WHEN  'STATE' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).state);
	        WHEN  'PROVINCE' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).province);
	        WHEN  'COUNTY' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).county);
	        WHEN  'CITY' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).city);
	        WHEN  'POSTAL_CODE' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).postal_code);
	        WHEN  'POSTAL_PLUS4_CODE' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).postal_plus4_code);
	        WHEN  'ATTRIBUTE1' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute1);
	        WHEN  'ATTRIBUTE2' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute2);
	        WHEN  'ATTRIBUTE3' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute3);
	        WHEN  'ATTRIBUTE4' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute4);
	        WHEN  'ATTRIBUTE5' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute5);
	        WHEN  'ATTRIBUTE6' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute6);
	        WHEN  'ATTRIBUTE7' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute7);
	        WHEN  'ATTRIBUTE8' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute8);
	        WHEN  'ATTRIBUTE9' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute9);
	        WHEN  'ATTRIBUTE10' THEN
	            priv_match_proc(j, geo_suggest_tbl(i).attribute10);
	        ELSE
	          NULL;
	      END CASE;

      END do_match;

  BEGIN
	  -- FND Logging for debug purpose
	  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Begin procedure check_exact_match_del_rest(+)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
      END IF;

	   l_element_matched        := 'Y';
	   l_check_next_row         := 'Y';
	   l_exact_row_match_found  := 'N';

	    -- check if user has entered all mapped columns.
		IF (geo_struct_tbl.COUNT > 0 AND geo_suggest_tbl.COUNT > 0) THEN

		  -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'Geo_struct_tbl and geo_suggest_tbl count greater than 0',
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	      END IF;

	 	  FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	 	    IF (geo_struct_tbl(i).v_param_value IS NULL) THEN

			  -- FND Logging for debug purpose
			  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		          hz_utility_v2pub.debug
		               (p_message       => 'Input value for '||geo_struct_tbl(i).v_tab_col||' is null '||
					                       'No use proceeding with input out put match. Exiting procedure.',
			            p_prefix        => l_debug_prefix,
			            p_msg_level     => fnd_log.level_statement,
			            p_module_prefix => l_module_prefix,
			            p_module        => l_module
			           );
		      END IF;

	 	      l_check_next_row := 'N'; -- no use doing match
	 	      EXIT;
	 	    END IF;
	      END LOOP;
	    ELSE
		  -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'Geo_struct_tbl and geo_suggest_tbl count is less than 0.'||
				                       'No use proceeding with input out put match. Exiting procedure.',
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	      END IF;

	      l_check_next_row := 'N';
		END IF;

	    -- all parameters are passed
        IF (l_check_next_row = 'Y') THEN

		  -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	               (p_message       => 'All params passed. Start matching input values with fetched data',
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );
	      END IF;

	      FOR i IN geo_suggest_tbl.FIRST..geo_suggest_tbl.LAST LOOP
	        IF (l_check_next_row = 'Y') THEN

	          FOR j IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
	            do_match(geo_struct_tbl(j).v_tab_col, i, j);
	            -- if not matched, go to next row of suggest table
	            IF (l_element_matched = 'Y') THEN
	                l_check_next_row := 'N';
	                l_exact_row_match_found := 'Y';
	            ELSE
	                l_check_next_row := 'Y';
	                l_exact_row_match_found := 'N';
	                EXIT;
	            END IF;
	          END LOOP; -- geo_struct_tbl loop

	          IF (l_exact_row_match_found = 'Y') THEN

	          	 -- FND Logging for debug purpose
				  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
			          hz_utility_v2pub.debug
			               (p_message       => 'Exact match found. Copying that row into '||
						                       'final suggest tbl and deleting rest of suggestions',
				            p_prefix        => l_debug_prefix,
				            p_msg_level     => fnd_log.level_statement,
				            p_module_prefix => l_module_prefix,
				            p_module        => l_module
				           );
			      END IF;

		          -- DELETE all other rows and keep only this row in address suggestion
	              l_geo_suggest_tbl_temp(1) := geo_suggest_tbl(i);
	              geo_suggest_tbl.DELETE;
	              geo_suggest_tbl := l_geo_suggest_tbl_temp;
	              -- set the counter in case of number of records is null (i.e. more than 55)
	              IF (l_geo_data_count > l_max_fetch_count) THEN
	                l_geo_data_count := geo_suggest_tbl.COUNT;
	              END IF;
	              EXIT;
	          END IF;

	        END IF;
	      END LOOP; 	  -- geo_suggest_tbl loop

        END IF;

	  -- FND Logging for debug purpose
	  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Completed procedure check_exact_match_del_rest(-)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
      END IF;

  END check_exact_match_del_rest;

  -----------------------------------------------------------------------------+
  -- Function to check if all input and output values match
  -- This is used in case of 1 record fetched
  -- For multiple records fetched, first check_exact_match_del_rest will be called
  -----------------------------------------------------------------------------+
  FUNCTION do_input_output_match_check RETURN BOOLEAN
  IS
    l_last_tab_col VARCHAR2(100);
    l_match NUMBER;

    PROCEDURE priv_match_proc(ll_index number, ll_tbl_value IN VARCHAR2,
	                          ll_tbl_value_code IN VARCHAR2, ll_tbl_value_id IN NUMBER) IS
    BEGIN
	  -- ns_debug.put_line('In Match Procedure..');
	  -- ns_debug.put_line('Left Side : '||REPLACE(geo_struct_tbl(ll_index).v_param_value,'%',''));
	  -- ns_debug.put_line('Right Side: '||UPPER(ll_tbl_value));
	  -- ns_debug.put_line('Right Side: '||UPPER(ll_tbl_value_code));
	  -- Handle NVL with some randon value. NULL = NULL is not success case
          -- Bug 5167520 (Nishant 17-APR-2006) When only country is passed but more geo usage fields
	  -- are to be validated, then if only country is fetched in search result, then it should not be
	  -- treated as exact match
	  IF ( (ll_tbl_value_id IS NOT NULL) AND -- Bug 5167520 (Nishant 17-APR-2006)
	      (
		   (NVL(REPLACE(geo_struct_tbl(ll_index).v_param_value,'%',''),'XdFj734') =
	        NVL(UPPER(ll_tbl_value),'PaXT36h'))
	       OR
	       (NVL(REPLACE(geo_struct_tbl(ll_index).v_param_value,'%',''),'XdFj734') =
	        NVL(UPPER(ll_tbl_value_code),'PaXT36h'))
	      )
		 )
	  THEN
		  l_match := 1; -- match
	  ELSE
	      l_match := 2; -- no match
	  END IF;
    END;

  BEGIN

    l_match := 0;

    -- get last mapped table column
	IF (geo_struct_tbl.COUNT > 0 AND geo_suggest_tbl.COUNT > 0) THEN
 	  FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP

	    -- match the input and output values for Geo usage columns
	    -- IF geo_struct_tbl(i).v_param_value IS NOT NULL THEN
	    IF geo_struct_tbl(i).v_valid_for_usage = 'Y' THEN
	      CASE geo_struct_tbl(i).v_tab_col
	        -- checking for geo_id not null because to handle 'MISSING' and 'UNKNOWN'
	        -- geo codes, we are making geo name NULL but retaing geo_id and geo_code
	        -- for them. So, even if geo name is NULL, it is possible to have
	        -- geo_id and geo_code populated.
	        WHEN  'COUNTRY' THEN
                priv_match_proc(i, geo_suggest_tbl(1).country,
				                geo_suggest_tbl(1).country_code, geo_suggest_tbl(1).country_geo_id);
		    WHEN  'STATE' THEN
                priv_match_proc(i, geo_suggest_tbl(1).state,
				                geo_suggest_tbl(1).state_code, geo_suggest_tbl(1).state_geo_id);
	        WHEN  'PROVINCE' THEN
                priv_match_proc(i, geo_suggest_tbl(1).province,
				                geo_suggest_tbl(1).province_code, geo_suggest_tbl(1).province_geo_id);
	        WHEN  'COUNTY' THEN
                priv_match_proc(i, geo_suggest_tbl(1).county,
				                   geo_suggest_tbl(1).county, geo_suggest_tbl(1).county_geo_id) ;
	        WHEN  'CITY' THEN
                priv_match_proc(i, geo_suggest_tbl(1).city,
				                geo_suggest_tbl(1).city, geo_suggest_tbl(1).city_geo_id);
	        WHEN  'POSTAL_CODE' THEN
                priv_match_proc(i, geo_suggest_tbl(1).postal_code,
				                   geo_suggest_tbl(1).postal_code, geo_suggest_tbl(1).postal_code_geo_id);
	        WHEN  'POSTAL_PLUS4_CODE' THEN
                priv_match_proc(i, geo_suggest_tbl(1).postal_plus4_code,
				                   geo_suggest_tbl(1).postal_plus4_code, geo_suggest_tbl(1).postal_plus4_code_geo_id);
	        WHEN  'ATTRIBUTE1' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute1, geo_suggest_tbl(1).attribute1,
				                geo_suggest_tbl(1).attribute1_geo_id);
	        WHEN  'ATTRIBUTE2' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute2, geo_suggest_tbl(1).attribute2,
				                geo_suggest_tbl(1).attribute2_geo_id);
	        WHEN  'ATTRIBUTE3' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute3, geo_suggest_tbl(1).attribute3,
				                geo_suggest_tbl(1).attribute3_geo_id);
	        WHEN  'ATTRIBUTE4' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute4, geo_suggest_tbl(1).attribute4,
				                geo_suggest_tbl(1).attribute4_geo_id);
	        WHEN  'ATTRIBUTE5' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute5, geo_suggest_tbl(1).attribute5,
				                geo_suggest_tbl(1).attribute5_geo_id);
	        WHEN  'ATTRIBUTE6' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute6, geo_suggest_tbl(1).attribute6,
				                geo_suggest_tbl(1).attribute6_geo_id);
	        WHEN  'ATTRIBUTE7' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute7, geo_suggest_tbl(1).attribute7,
				                geo_suggest_tbl(1).attribute7_geo_id);
	        WHEN  'ATTRIBUTE8' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute8, geo_suggest_tbl(1).attribute8,
				                geo_suggest_tbl(1).attribute8_geo_id);
	        WHEN  'ATTRIBUTE9' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute9, geo_suggest_tbl(1).attribute9,
				                geo_suggest_tbl(1).attribute9_geo_id);
	        WHEN  'ATTRIBUTE10' THEN
                priv_match_proc(i, geo_suggest_tbl(1).attribute10, geo_suggest_tbl(1).attribute10,
				                geo_suggest_tbl(1).attribute10_geo_id);
	        ELSE
	          NULL;
	      END CASE;

	      -- if does not match then exit loop
	      IF (l_match = 2) THEN
	        EXIT;
	      END IF;

		END IF; -- end of v_valid_for_usage = 'Y' check

	  END LOOP; -- end of geo struct loop
	END IF;     -- end of geo struct tbl count check

	IF (l_match = 2) THEN

      -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Input values not exactly same as fetched values for usage',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

	  RETURN FALSE;
	ELSE

      -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Input values matches fetched values',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

	  RETURN TRUE;
	END IF;

  END do_input_output_match_check;

  -----------------------------------------------------------------------------+
  -- Private procedure to build mapping table which can be used throughout the
  -- code.
  -----------------------------------------------------------------------------+
  PROCEDURE build_geo_struct_tbl_pvt (pv_country_code IN VARCHAR2, pv_address_style IN VARCHAR2,
                                   pv_table_name IN VARCHAR2, pv_address_usage IN VARCHAR2) IS

    i               INTEGER;
    l_temp          NUMBER;
    l_address_style VARCHAR2(255);
    l_mapped_column_list  VARCHAR2(255);
    l_mapped_geo_type_list VARCHAR2(255);
    l_passed_param_values  VARCHAR2(255);

    CURSOR c_full_struct_not_null (ll_country_code VARCHAR2, ll_address_style VARCHAR2,
                                   ll_table_name VARCHAR2)
    IS
    SELECT dmap.loc_component, dmap.geography_type, dmap.geo_element_col, dmap.loc_seq_num
    FROM   hz_geo_struct_map smap
          ,hz_geo_struct_map_dtl dmap
    WHERE  smap.address_style = ll_address_style
    AND    SMAP.country_code = ll_country_code
    AND    SMAP.loc_tbl_name = ll_table_name
    AND    smap.map_id = dmap.map_id
    ORDER BY dmap.loc_seq_num;

    CURSOR c_full_struct_for_null (ll_country_code VARCHAR2, ll_table_name VARCHAR2)
    IS
    SELECT dmap.loc_component, dmap.geography_type, dmap.geo_element_col, dmap.loc_seq_num
    FROM   hz_geo_struct_map smap
          ,hz_geo_struct_map_dtl dmap
    WHERE  smap.address_style IS NULL
    AND    SMAP.country_code = ll_country_code
    AND    SMAP.loc_tbl_name = ll_table_name
    AND    smap.map_id = dmap.map_id
    ORDER BY dmap.loc_seq_num;

    CURSOR c_usage_not_null (ll_country_code VARCHAR2, ll_address_style VARCHAR2,
                             ll_table_name VARCHAR2, ll_usage VARCHAR2)
    IS
    SELECT haud.geography_type
    FROM   hz_geo_struct_map smap
          ,hz_geo_struct_map_dtl dmap
          ,hz_address_usages hau
          ,hz_address_usage_dtls haud
    WHERE  smap.address_style = ll_address_style
    AND    SMAP.country_code = ll_country_code
    AND    SMAP.loc_tbl_name = ll_table_name
    AND    smap.map_id = dmap.map_id
    AND    smap.map_id = hau.map_id
    AND    hau.usage_code = ll_usage
    AND    hau.status_flag = 'A'
    AND    hau.usage_id = haud.usage_id
    AND    haud.geography_type = dmap.geography_type
    ORDER BY dmap.loc_seq_num;

    CURSOR c_usage_for_null (ll_country_code VARCHAR2,
                                   ll_table_name VARCHAR2, ll_usage VARCHAR2)
    IS
    SELECT haud.geography_type
    FROM   hz_geo_struct_map smap
          ,hz_geo_struct_map_dtl dmap
          ,hz_address_usages hau
          ,hz_address_usage_dtls haud
    WHERE  smap.address_style IS NULL
    AND    SMAP.country_code = ll_country_code
    AND    SMAP.loc_tbl_name = ll_table_name
    AND    smap.map_id = dmap.map_id
    AND    smap.map_id = hau.map_id
    AND    hau.usage_code = ll_usage
    AND    hau.status_flag = 'A'
    AND    hau.usage_id = haud.usage_id
    AND    haud.geography_type = dmap.geography_type
    ORDER BY dmap.loc_seq_num;
    l_postal_code  HZ_LOCATIONS.POSTAL_CODE%TYPE;

  BEGIN

--  ER#7240974: get Postal Code value from postal_code_to_validate Function.

    l_postal_code := hz_gnr_util_pkg.postal_code_to_validate(p_country_code,p_postal_code);

      -- FND Logging for debug purpose
  	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Postal Code at build_geo_struct_tbl_pvt  : '||l_postal_code,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

      i := 0;
      geo_struct_tbl.DELETE;
      l_max_usage_element_col_value := 0;

      IF ((LENGTH(pv_address_style) = 0) OR (pv_address_style IS NULL)) THEN
        l_address_style := NULL;
      ELSE
        l_address_style := pv_address_style;
      END IF;

      -- FND Logging for debug purpose
  	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Address Style passed is :'||l_address_style,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

      IF (l_address_style IS NOT NULL) THEN
	    FOR c_full_struct_rec IN c_full_struct_not_null (UPPER(pv_country_code), l_address_style,
		                                                 UPPER(pv_table_name))
	    LOOP
		  i := i+1;
		  geo_struct_tbl(i).v_tab_col := c_full_struct_rec.loc_component;
		  geo_struct_tbl(i).v_geo_type := c_full_struct_rec.geography_type;
		  geo_struct_tbl(i).v_element_col := c_full_struct_rec.geo_element_col;
		  geo_struct_tbl(i).v_level := c_full_struct_rec.loc_seq_num;
		  l_temp := 1;
		END LOOP;
      END IF;

      -- if no data found then, try with NULL address style (which is default address style)
	  IF (geo_struct_tbl.COUNT = 0) THEN

        -- FND Logging for debug purpose
  	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	              (p_message       => 'Either address style is NULL or mapping for passed address style not found.'||
				                      ' Trying with NULL address style.',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
        END IF;

	    -- try with NULL address style
	    FOR c_full_struct_rec IN c_full_struct_for_null (UPPER(pv_country_code), UPPER(pv_table_name))
	    LOOP
		  i := i+1;
		  geo_struct_tbl(i).v_tab_col := c_full_struct_rec.loc_component;
		  geo_struct_tbl(i).v_geo_type := c_full_struct_rec.geography_type;
		  geo_struct_tbl(i).v_element_col := c_full_struct_rec.geo_element_col;
		  geo_struct_tbl(i).v_level := c_full_struct_rec.loc_seq_num;
		  l_temp := 2;
		END LOOP;
      END IF;

      -- fill in usage column in case of not null address style
	  IF ((l_temp = 1) AND (geo_struct_tbl.COUNT > 0)) THEN
          FOR c_full_struct_rec IN c_usage_not_null (UPPER(pv_country_code),  l_address_style,
		                                             UPPER(pv_table_name), UPPER(pv_address_usage))
	      LOOP
	        FOR j IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP
	          IF (geo_struct_tbl(j).v_geo_type = c_full_struct_rec.geography_type) THEN
	            geo_struct_tbl(j).v_valid_for_usage := 'Y';
	          END IF;
	        END LOOP;
		  END LOOP;
      END IF;

      -- fill in usage column if null address style is used
	  IF ((l_temp = 2) AND (geo_struct_tbl.COUNT > 0)) THEN
          FOR c_full_struct_rec IN c_usage_for_null (UPPER(pv_country_code),
		                                             UPPER(pv_table_name), UPPER(pv_address_usage))
	      LOOP
	        FOR j IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP
	          IF (geo_struct_tbl(j).v_geo_type = c_full_struct_rec.geography_type) THEN
	            geo_struct_tbl(j).v_valid_for_usage := 'Y';
	          END IF;
	        END LOOP;
		  END LOOP;
      END IF;

      -- FND Logging for debug purpose
  	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Mapped structure count :'||TO_CHAR(geo_struct_tbl.COUNT),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

      -- Read the mapped structure and based on mapping of each table column
	  -- read the values of input parameters passed. If mapped table column
	  -- is STATE then read value of parameter p_state and so on.
	  IF (geo_struct_tbl.COUNT > 0) THEN
	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP

          l_mapped_column_list   := SUBSTR(l_mapped_column_list||' '||geo_struct_tbl(i).v_tab_col,1,255);
          l_mapped_geo_type_list := SUBSTR(l_mapped_geo_type_list||' '||geo_struct_tbl(i).v_geo_type,1,255);

          CASE geo_struct_tbl(i).v_tab_col
	        WHEN  'COUNTRY' THEN
	          IF (p_country_code IS NOT NULL) THEN
	            geo_struct_tbl(i).v_param_value :=  UPPER(p_country_code)||'%';
	          END IF;
		    WHEN  'STATE' THEN
	          IF (p_state IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_state)||'%';
	          END IF;
	        WHEN  'PROVINCE' THEN
	          IF (p_province IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_province)||'%';
	          END IF;
	        WHEN  'COUNTY' THEN
	          IF (p_county IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_county)||'%';
	          END IF;
	        WHEN  'CITY' THEN
	          IF (p_city IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_city)||'%';
	          END IF;
	        WHEN  'POSTAL_CODE' THEN
	          IF (p_postal_code IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(l_postal_code)||'%';
	          END IF;
	        WHEN  'POSTAL_PLUS4_CODE' THEN
	          IF (p_postal_plus4_code IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_postal_plus4_code)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE1' THEN
	          IF (p_attribute1 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute1)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE2' THEN
	          IF (p_attribute2 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute2)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE3' THEN
	          IF (p_attribute3 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute3)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE4' THEN
	          IF (p_attribute4 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute4)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE5' THEN
	          IF (p_attribute5 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute5)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE6' THEN
	          IF (p_attribute6 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute6)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE7' THEN
	          IF (p_attribute7 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute7)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE8' THEN
	          IF (p_attribute8 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute8)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE9' THEN
	          IF (p_attribute9 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute9)||'%';
	          END IF;
	        WHEN  'ATTRIBUTE10' THEN
	          IF (p_attribute10 IS NOT NULL) THEN
                geo_struct_tbl(i).v_param_value :=  UPPER(p_attribute10)||'%';
	          END IF;
	        ELSE
	          NULL;
	      END CASE;

	      -- Get the max element column which is mapped
	      -- e.g. if max value of element col is geography_element4, get "4" out of it
	      l_max_mapped_element_col_value :=
	        GREATEST(NVL(l_max_mapped_element_col_value,0),TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)));

          l_lowest_mapped_geo_type := geo_struct_tbl(i).v_geo_type;

          l_passed_param_values := SUBSTR(l_passed_param_values||':'||geo_struct_tbl(i).v_param_value,1,255);

          -- Get the max element for which for geo usage is to be valid
          IF (geo_struct_tbl(i).v_valid_for_usage = 'Y') THEN
            l_max_usage_element_col_value :=
		      GREATEST(NVL(l_max_usage_element_col_value,0),TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)));

		    l_lowest_usage_geo_type := geo_struct_tbl(i).v_geo_type;

		    -- also get the lowest geo type for which value is passed
		    IF (geo_struct_tbl(i).v_param_value IS NOT NULL) THEN
		      l_last_geo_type_usg_val_psd := geo_struct_tbl(i).v_geo_type;
		    END IF;
		  END IF;

       END LOOP;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => SUBSTR('Mapped Columns:'||l_mapped_column_list,1,255),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => SUBSTR('Mapped Geo Types:'||l_mapped_geo_type_list,1,255),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => SUBSTR('Passed Param Values'||l_passed_param_values,1,255),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Max Mapped Element Column Value:'||TO_CHAR(l_max_mapped_element_col_value),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Max Geo Usage Element Col Value:'||TO_CHAR(l_max_usage_element_col_value),
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Max Geo Type for which Geo usage is marked: '||l_lowest_usage_geo_type,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- FND Logging for debug purpose
  	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         hz_utility_v2pub.debug
	               (p_message       => 'Lowest Geo Type for which Geo usage is marked and value is passed: '||l_last_geo_type_usg_val_psd,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
       END IF;

       -- copy it to output table also
       IF (geo_struct_tbl IS NOT NULL) THEN
         x_geo_struct_tbl := geo_struct_tbl;
       END IF;

     END IF;

     x_mapped_struct_count := geo_struct_tbl.COUNT;

  END build_geo_struct_tbl_pvt;

  ---------------------------------------------------------------------+
  -- Build Suggestion List for consumer teams. This is done by concatnating
  -- all fetched and mapped values of FInal Table (geo_suggest_tbl).
  -- This will be based on the order of mapping fo components.
  -- ER # 4600030
  ---------------------------------------------------------------------+
  PROCEDURE build_suggestion_list IS
    l_suggest_list   VARCHAR2(4000);

    FUNCTION build_list (l_rec_number IN NUMBER, l_position IN NUMBER, l_tab_col IN VARCHAR2) RETURN VARCHAR2
    IS
      l_list VARCHAR2(4000);
      i      NUMBER := l_rec_number;
    BEGIN
      CASE l_tab_col
        WHEN  'COUNTRY' THEN
          IF (geo_suggest_tbl(i).country_geo_id IS NOT NULL) THEN
            IF (l_position = 2 ) THEN
              l_list :=  geo_suggest_tbl(i).country;
            ELSIF
               (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).country;
            END IF;
          END IF;
	    WHEN  'STATE' THEN
          IF (geo_suggest_tbl(i).STATE_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).STATE;
            ELSIF
               (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).STATE;
            END IF;
          END IF;
        WHEN  'PROVINCE' THEN
          IF (geo_suggest_tbl(i).PROVINCE_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).PROVINCE;
            ELSIF
               (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).PROVINCE;
            END IF;
          END IF;
        WHEN  'COUNTY' THEN
          IF (geo_suggest_tbl(i).COUNTY_GEO_ID IS NOT NULL) THEN
		    IF (l_position = 2) THEN
              l_list :=  INITCAP(geo_suggest_tbl(i).COUNTY);
            ELSIF
               (l_position > 2) THEN
              l_list :=  ', '||INITCAP(geo_suggest_tbl(i).COUNTY);
            END IF;
          END IF;
        WHEN  'CITY' THEN
          IF (geo_suggest_tbl(i).CITY_GEO_ID IS NOT NULL) THEN
  		    IF (l_position = 2) THEN
              l_list :=  INITCAP(geo_suggest_tbl(i).CITY);
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||INITCAP(geo_suggest_tbl(i).CITY);
            END IF;
          END IF;
        WHEN  'POSTAL_CODE' THEN
          IF (geo_suggest_tbl(i).POSTAL_CODE_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).POSTAL_CODE;
            ELSIF
              (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).POSTAL_CODE;
            END IF;
          END IF;
        WHEN  'POSTAL_PLUS4_CODE' THEN
          IF (geo_suggest_tbl(i).POSTAL_PLUS4_CODE_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).POSTAL_PLUS4_CODE;
            ELSIF
              (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).POSTAL_PLUS4_CODE;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE1' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE1_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE1;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE1;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE2' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE2_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE2;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE2;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE3' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE3_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE3;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE3;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE4' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE4_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE4;
            ELSIF
              (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE4;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE5' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE5_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE5;
            ELSIF
              (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE5;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE6' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE6_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE6;
            ELSIF
              (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE6;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE7' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE7_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE7;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE7;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE8' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE8_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE8;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE8;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE9' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE9_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE9;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE9;
            END IF;
          END IF;
        WHEN  'ATTRIBUTE10' THEN
          IF (geo_suggest_tbl(i).ATTRIBUTE10_GEO_ID IS NOT NULL) THEN
            IF (l_position = 2) THEN
              l_list :=  geo_suggest_tbl(i).ATTRIBUTE10;
            ELSIF
             (l_position > 2) THEN
              l_list :=  ', '||geo_suggest_tbl(i).ATTRIBUTE10;
            END IF;
          END IF;
        ELSE
          NULL;
       END CASE;

      RETURN l_list;
    END build_list;

  BEGIN
    ---------------------------------------------------------------------+
    -- Build Suggestion List for consumer teams. This is done by concatnating
    -- all fetched and mapped values of Final Table (geo_suggest_tbl).
    -- This will be based on the order of mapping fo components.
    ---------------------------------------------------------------------+
    -- FND Logging for debug purpose
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
             hz_utility_v2pub.debug
               (p_message       => 'Building Suggestion list for Java APIs: build_suggestion_list(+)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
    END IF;

    IF (geo_suggest_tbl.COUNT > 0) THEN
      FOR i IN geo_suggest_tbl.FIRST..geo_suggest_tbl.LAST LOOP
        l_suggest_list := NULL;
        IF (geo_struct_tbl.COUNT > 0) THEN
          FOR j IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP
            l_suggest_list := l_suggest_list || build_list(i, j, geo_struct_tbl(j).v_tab_col);
          END LOOP;
        END IF;
        geo_suggest_tbl(i).suggestion_list := l_suggest_list;
      END LOOP;

	  -- FND LOGGING FOR DEBUG PURPOSE
	  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		  HZ_UTILITY_V2PUB.DEBUG
		       (P_MESSAGE       => 'Begin procedure quick_sort_suggestion_list(+)',
			    P_PREFIX        => L_DEBUG_PREFIX,
			    P_MSG_LEVEL     => FND_LOG.LEVEL_PROCEDURE,
			    P_MODULE_PREFIX => L_MODULE_PREFIX,
			    P_MODULE        => L_MODULE
			   );
	   END IF;

      -- do sorting on geo_suggest_tbl based on suggestion_list column
	  quick_sort_suggestion_list(geo_suggest_tbl.FIRST, geo_suggest_tbl.LAST, geo_suggest_tbl);

 	  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	      hz_utility_v2pub.debug
		   (p_message       => 'End procedure quick_sort_suggestion_list(-)',
		    p_prefix        => l_debug_prefix,
		    p_msg_level     => fnd_log.level_procedure,
		    p_module_prefix => l_module_prefix,
		    p_module        => l_module
		   );
	  END IF;

    END IF;

    -- Implement check that if only country is fetched, and more has to be validated
    -- then suggestion list will be null. In that case delete that country row also.
    -- Bug 5391120 (Nishant 21-Jul-2006)
    IF (geo_suggest_tbl.COUNT = 1) THEN

	  -- FND Logging for debug purpose
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
           (p_message       => 'Only 1 row in Suggestion list. Its value is:'||geo_suggest_tbl(1).suggestion_list,
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_procedure,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
      END IF;

	  IF (geo_suggest_tbl(1).suggestion_list IS NULL OR
          LENGTH(LTRIM(RTRIM(geo_suggest_tbl(1).suggestion_list))) = 0) THEN
          geo_suggest_tbl.DELETE(1);

		  -- FND Logging for debug purpose
	      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
	           (p_message       => 'Since value in suggestion list is NULL or of 0 length,'||
			                       'deleting the row from geo_suggest_tbl',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
	      END IF;

      END IF;
    END IF;

    -- FND Logging for debug purpose
    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
           (p_message       => 'Completed building Suggestion list for Java APIs: build_suggestion_list(-)',
            p_prefix        => l_debug_prefix,
            p_msg_level     => fnd_log.level_procedure,
            p_module_prefix => l_module_prefix,
            p_module        => l_module
           );
    END IF;

  END build_suggestion_list;

   -----------------------------------------------------------------------------+
  -- Private procedure to setup return code, records count, suggestions
  -- and message strings to output variables
  -- Created by Nishant Singhai (27-Sep-2005) (Bug # 4600030)
  -----------------------------------------------------------------------------+
  PROCEDURE setup_msg_and_ret_code_proc (p_return_code IN NUMBER,
                                         p_msg_name IN VARCHAR2 DEFAULT NULL,
                                         p_msg_token_name IN VARCHAR2 DEFAULT NULL,
			  					  	     p_msg_token_value IN VARCHAR2 DEFAULT NULL) IS

    l_not_validated_geo_type VARCHAR2(200);
    l_rec_count_flag         VARCHAR2(10);
    ll_success_geo_level      NUMBER;
  BEGIN
     -- Set output values
     x_records_count   := geo_suggest_tbl.COUNT;
     x_return_code     := p_return_code;
     x_geo_suggest_tbl := geo_suggest_tbl;

     IF (p_msg_name IS NOT NULL) THEN
        -- get message string
	    FND_MESSAGE.SET_NAME('AR', p_msg_name );

	    IF (p_msg_token_name IS NOT NULL) THEN
	       IF (p_msg_token_value IS NULL) THEN
	         -- validate input values and get invalid geo types back
	         validate_input_values_proc (l_geo_struct_tbl => geo_struct_tbl,
	                                  x_not_validated_geo_type => l_not_validated_geo_type,
	                                  x_rec_count_flag => l_rec_count_flag,
									  x_success_geo_level => ll_success_geo_level);
	       ELSE -- use passed in token value in case of missing fields
	         l_not_validated_geo_type :=  p_msg_token_value;
	       END IF;

          FND_MESSAGE.SET_TOKEN(p_msg_token_name, l_not_validated_geo_type );
        END IF;
        x_geo_suggest_misc_rec.v_suggestion_msg_text := SUBSTR(FND_MESSAGE.GET,1,1000);
     END IF;

  END setup_msg_and_ret_code_proc;

  ----------------------------------------------------------------------------+
  -- Private procedure to process fetched data and populate output variables
  -- It will do processing for 'ERROR', 'WARNING', 'MINIMUM' and 'NONE' validation
  -- levels. It will set return codes, record count, suggestion table, return
  -- messages based on validation level
  -- Created By : Nishant Singhai (27-Sep-2005) for Bug # 4600030
  ----------------------------------------------------------------------------+
  PROCEDURE process_output_data_proc IS
	l_miss_min_geo_type VARCHAR2(200);
	l_msg_name          VARCHAR2(100);
	l_msg_token_name    VARCHAR2(100);
  BEGIN
   -- FND Logging for debug purpose
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'BEGIN: process_output_data_proc(+)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
   END IF;

   -- Build sorted suggestion List for fetching proper return codes.
   -- (Nishant 20-Jul-2006 for Bug 5391120)
   build_suggestion_list;

   IF (l_addr_val_level = 'ERROR') THEN

	 -- FND Logging for debug purpose
	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Validation Level : ERROR',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
     END IF;

     -- If it is 2nd pass and geo validation success, then return ADDRESS_COMPLETE
     IF ((HZ_GNR_PVT.G_USER_ATTEMPT_COUNT IS NOT NULL) AND  -- this is 2nd attempt
       (l_success = 'Y')) THEN
          -- FND Logging for debug purpose
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             hz_utility_v2pub.debug
               (p_message       => 'Geo Validated Address is complete, return code=0(ADDRESS_COMPLETE)',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
              );
          END IF;

          -- set return code and return message
          setup_msg_and_ret_code_proc(p_return_code => 0); /* ADDRESS_COMPLETE */
          -- reset the global variable (session) to null so that next time
          -- address suggestion kickes in initially
          HZ_GNR_PVT.G_USER_ATTEMPT_COUNT := NULL;

     ELSE -- do further processing  to verify if record is success

	     IF (geo_suggest_tbl.COUNT = 0) THEN

	  	    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN

	          hz_utility_v2pub.debug
	               (p_message       => 'Records count is 0, return code= -1(ADDRESS_INVALID)',
		            p_prefix        => l_debug_prefix,
		            p_msg_level     => fnd_log.level_statement,
		            p_module_prefix => l_module_prefix,
		            p_module        => l_module
		           );

	        END IF;

	        -- set return code and return message
	        /* -- checking if Geo validation was success, then given message that
	           -- user can click Apply and continue (equivalent to what we given in warning scenario)
	           -- Bug 5172103 (Nishant 11-May-2006)
	        */
	        IF (l_geo_validation_passed = 'Y') THEN
	          l_msg_name       := 'HZ_GEO_WARN_MIN_PASS';
	          l_msg_token_name := 'P_ALL_ELEMENTS';
	        ELSE
	          l_msg_name       := 'HZ_GEO_INVALID_ADDRESS';
	          l_msg_token_name := 'P_MISSING_ELEMENTS';
	        END IF;

	        setup_msg_and_ret_code_proc(p_return_code     => -1, /* ADDRESS_INVALID */
			                            p_msg_name        => l_msg_name,
	                                    p_msg_token_name  => l_msg_token_name);

	        -- set the global variable (session) to '1' (some value) to identify that
			-- next time we can directly go to geo validation i.e.
	        HZ_GNR_PVT.G_USER_ATTEMPT_COUNT := '1';

	     ELSE -- geo_suggest_tbl count is not 0

           -- set the global variable (session) to '1' (some value) to identify that
  		   -- next time we can directly go to geo validation i.e.
	       HZ_GNR_PVT.G_USER_ATTEMPT_COUNT := '1';

	       IF (geo_suggest_tbl.COUNT =1) THEN
	           -- check if all input values match all fetched values
	 		   IF (do_input_output_match_check) THEN

	   	         -- FND Logging for debug purpose
		         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	                 hz_utility_v2pub.debug
	                   (p_message       => 'Address is complete, return code=0(ADDRESS_COMPLETE)',
		                p_prefix        => l_debug_prefix,
		                p_msg_level     => fnd_log.level_statement,
		                p_module_prefix => l_module_prefix,
		                p_module        => l_module
		              );
	             END IF;

	             -- set return code and return message
 	             setup_msg_and_ret_code_proc(p_return_code => 0); /* ADDRESS_COMPLETE */
                 -- reset the global variable (session) to null so that next time
                 -- address suggestion kickes in initially
                 HZ_GNR_PVT.G_USER_ATTEMPT_COUNT := NULL;

	 		   ELSE
	   	         -- FND Logging for debug purpose
		         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	                 hz_utility_v2pub.debug
	                   (p_message       => 'input output match check failed, return code=1(ADDRESS_VALID)',
		                p_prefix        => l_debug_prefix,
		                p_msg_level     => fnd_log.level_statement,
		                p_module_prefix => l_module_prefix,
		                p_module        => l_module
		              );
	             END IF;

    	        -- set return code and return message
	            /* -- checking if Geo validation was success, then given message that
	               -- user can click Apply and continue (equivalent to what we given in warning scenario)
	               -- Bug 5172103 (Nishant 11-May-2006)
  	            */
	            IF (l_geo_validation_passed = 'Y') THEN
	              l_msg_name       := 'HZ_GEO_WARN_MIN_PASS';
	              l_msg_token_name := 'P_ALL_ELEMENTS';
	            ELSE
	              l_msg_name       := 'HZ_GEO_INVALID_ADDRESS';
	              l_msg_token_name := 'P_MISSING_ELEMENTS';
	            END IF;

	            setup_msg_and_ret_code_proc(p_return_code     => 1, /* ADDRESS_VALID */ --2, /* ADDRESS_UNIQUE */
			                                p_msg_name        => l_msg_name,
	                                        p_msg_token_name  => l_msg_token_name);

	   	     END IF; -- input output match check

	       ELSIF -- more than 55
	         ((geo_suggest_tbl.COUNT > 1) AND (l_geo_data_count > l_max_fetch_count)) THEN

	   	        -- FND Logging for debug purpose
		        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	                 hz_utility_v2pub.debug
	                   (p_message       => 'more than 55 records, return code=1000(TOO_MANY_ROWS)',
		                p_prefix        => l_debug_prefix,
		                p_msg_level     => fnd_log.level_statement,
		                p_module_prefix => l_module_prefix,
		                p_module        => l_module
		              );
	            END IF;

    	        -- set return code and return message
	            /* -- checking if Geo validation was success, then given message that
	               -- user can click Apply and continue (equivalent to what we given in warning scenario)
	               -- Bug 5172103 (Nishant 11-May-2006)
  	            */
	            IF (l_geo_validation_passed = 'Y') THEN
	              l_msg_name       := 'HZ_GEO_WARN_MORE_TO_FETCH';
	              l_msg_token_name := 'P_ALL_ELEMENTS';
	            ELSE
	              l_msg_name       := 'HZ_GEO_MORE_TO_FETCH';
	              l_msg_token_name := 'P_MISSING_ELEMENTS';
	            END IF;

	            setup_msg_and_ret_code_proc(p_return_code     => 1000, /* TOO_MANY_ROWS */
			                                p_msg_name        => l_msg_name,
	                                        p_msg_token_name  => l_msg_token_name);

	 	        -- SET x_records_count TO NULL so that calling UI does not get wrong picture
		  	    -- about number of records.
			    x_records_count := NULL;

	       ELSE -- between 2 and 55

	   	      -- FND Logging for debug purpose
		      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	                 hz_utility_v2pub.debug
	                   (p_message       => 'No. of records between 2 and 55, return code=1(ADDRESS_VALID)',
		                p_prefix        => l_debug_prefix,
		                p_msg_level     => fnd_log.level_statement,
		                p_module_prefix => l_module_prefix,
		                p_module        => l_module
		              );
	          END IF;

    	        -- set return code and return message
	            /* -- checking if Geo validation was success, then given message that
	               -- user can click Apply and continue (equivalent to what we given in warning scenario)
	               -- Bug 5172103 (Nishant 11-May-2006)
  	            */
	            IF (l_geo_validation_passed = 'Y') THEN
	              l_msg_name       := 'HZ_GEO_WARN_MIN_PASS';
	              l_msg_token_name := 'P_ALL_ELEMENTS';
	            ELSE
	              l_msg_name       := 'HZ_GEO_INVALID_ADDRESS';
	              l_msg_token_name := 'P_MISSING_ELEMENTS';
	            END IF;

	            setup_msg_and_ret_code_proc(p_return_code     => 1, /* ADDRESS_VALID */
			                                p_msg_name        => l_msg_name,
	                                        p_msg_token_name  => l_msg_token_name);

	        END IF; -- geo suggest tbl count > 0
	       END IF; -- geo suggest tbl count = 0
	     END IF; -- 2nd attempt success check
     END IF; -- validation level = ERROR

   IF (l_addr_val_level = 'WARNING') THEN

      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             hz_utility_v2pub.debug
               (p_message       => 'Validation Level : WARNING',
                p_prefix        => l_debug_prefix,
                p_msg_level     => fnd_log.level_statement,
                p_module_prefix => l_module_prefix,
                p_module        => l_module
              );
      END IF;

     IF (geo_suggest_tbl.COUNT = 0) THEN

   	      -- FND Logging for debug purpose
	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message       => 'No. of records 0, return code=1(ADDRESS_VALID)',
	                p_prefix        => l_debug_prefix,
	                p_msg_level     => fnd_log.level_statement,
	                p_module_prefix => l_module_prefix,
	                p_module        => l_module
	              );
          END IF;

          -- set return code and return message
          setup_msg_and_ret_code_proc(p_return_code => 1, /* ADDRESS_VALID */
                                      p_msg_name    => 'HZ_GEO_WARN_MIN_PASS',
                                      p_msg_token_name  => 'P_ALL_ELEMENTS');

     ELSE -- geo_suggest_tbl count is not 0

       IF (geo_suggest_tbl.COUNT =1) THEN

           -- check if all input values match all fetched values
 		   IF (do_input_output_match_check) THEN

     	      -- FND Logging for debug purpose
	          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message       => 'No. of records 1, exact match, return code=0(ADDRESS_COMPLETE)',
	                p_prefix        => l_debug_prefix,
	                p_msg_level     => fnd_log.level_statement,
	                p_module_prefix => l_module_prefix,
	                p_module        => l_module
	              );
              END IF;

             -- set return code and return message
             setup_msg_and_ret_code_proc(p_return_code => 0);/* ADDRESS_COMPLETE */

 		   ELSE -- input output match check failed

     	        -- FND Logging for debug purpose
	            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message       => 'No. of records 1, input output match check failed, '||
				                       'return code=1(ADDRESS_VALID)',
	                p_prefix        => l_debug_prefix,
	                p_msg_level     => fnd_log.level_statement,
	                p_module_prefix => l_module_prefix,
	                p_module        => l_module
	              );
                END IF;

	           -- set return code and return message
	           setup_msg_and_ret_code_proc(p_return_code => 1, /* ADDRESS_VALID */
	                                       p_msg_name    => 'HZ_GEO_WARN_MIN_PASS',
	                                       p_msg_token_name  => 'P_ALL_ELEMENTS');

 		   END IF; -- input output match check

       ELSIF -- more than 55
         ((geo_suggest_tbl.COUNT > 1) AND (l_geo_data_count > l_max_fetch_count)) THEN

        	    -- FND Logging for debug purpose
	            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message       => 'No. of records more than 55, '||
				                       'return code=1000(TOO_MANY_ROWS)',
	                p_prefix        => l_debug_prefix,
	                p_msg_level     => fnd_log.level_statement,
	                p_module_prefix => l_module_prefix,
	                p_module        => l_module
	              );
                END IF;

	           -- set return code and return message
	           setup_msg_and_ret_code_proc(p_return_code => 1000, /* TOO_MANY_ROWS */
	                                       p_msg_name    => 'HZ_GEO_WARN_MORE_TO_FETCH',
	                                       p_msg_token_name  => 'P_ALL_ELEMENTS');

 	         -- SET x_records_count TO NULL so that calling UI does not get wrong picture
		     -- about number of records.
		     x_records_count := NULL;

       ELSE -- between 2 and 55

     	        -- FND Logging for debug purpose
	            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                 hz_utility_v2pub.debug
                   (p_message       => 'No. of records between 2 and 55, '||
				                       'return code=1(ADDRESS_VALID)',
	                p_prefix        => l_debug_prefix,
	                p_msg_level     => fnd_log.level_statement,
	                p_module_prefix => l_module_prefix,
	                p_module        => l_module
	              );
                END IF;

	           -- set return code and return message
	           setup_msg_and_ret_code_proc(p_return_code => 1, /* ADDRESS_VALID */
	                                       p_msg_name    => 'HZ_GEO_WARN_MIN_PASS',
	                                       p_msg_token_name  => 'P_ALL_ELEMENTS');

       END IF; -- geo suggest tbl count > 0
     END IF; -- geo suggest tbl count = 0
   END IF; -- validation level = WARNING

   IF (l_addr_val_level = 'MINIMUM') THEN

	  -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     hz_utility_v2pub.debug
	       (p_message       => 'Validation Level : MINIMUM',
	        p_prefix        => l_debug_prefix,
	        p_msg_level     => fnd_log.level_statement,
	        p_module_prefix => l_module_prefix,
	        p_module        => l_module
	      );
	  END IF;

 	  l_miss_min_geo_type := NULL;
	  l_miss_min_geo_type := get_missing_input_fields (l_geo_struct_tbl => geo_struct_tbl);

	  IF (l_miss_min_geo_type IS NOT NULL) THEN -- minimum check failed

        -- FND Logging for debug purpose
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	         hz_utility_v2pub.debug
	           (p_message       => 'Minimum check failed, '||
			                       'return code=-1(ADDRESS_INVALID)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	          );
        END IF;

	    -- set return code and return message
	    setup_msg_and_ret_code_proc(p_return_code => -1, /* ADDRESS_INVALID */
		                            p_msg_name    => 'HZ_GEO_NULL_ADDRESS',
	                                p_msg_token_name => 'P_MISSING_ELEMENTS',
		 						    p_msg_token_value => l_miss_min_geo_type);
      ELSE -- minimum check passed

        -- FND Logging for debug purpose
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	         hz_utility_v2pub.debug
	           (p_message       => 'Minimum check passed, '||
			                       'return code=0(ADDRESS_COMPLETE)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	          );
        END IF;

	    -- set return code and return message
	    setup_msg_and_ret_code_proc(p_return_code => 0); /* ADDRESS_COMPLETE */

	  END IF; -- minimum check
   END IF; -- validation level = MINIMUM

   IF (l_addr_val_level = 'NONE') THEN
      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	         hz_utility_v2pub.debug
	           (p_message       => 'Validation Level : NONE, return code=0(ADDRESS_COMPLETE)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	          );
      END IF;

      -- set return code and return message
	  setup_msg_and_ret_code_proc(p_return_code => 0); /* ADDRESS_COMPLETE */
   END IF; -- validation level = MINIMUM

   -- FND Logging for debug purpose
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'End: process_output_data_proc(-)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
   END IF;

 END process_output_data_proc;

 /*---------------------------------------------------------------------------+
  Function is_geo_valid_in_geo_rec_tbl_f will validate if results in geo_rec_tbl
  (Intermediate table) meet the geo usage criteria
  ----------------------------------------------------------------------------*/

  FUNCTION is_geo_valid_in_geo_rec_tbl_f (l_max_usage_element_col_value IN NUMBER)
    RETURN BOOLEAN IS
  BEGIN
  IF (geo_rec_tbl.COUNT > 0) THEN
    CASE l_max_usage_element_col_value
      WHEN 1 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT1 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 2 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT2 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 3 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT3 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 4 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT4 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 5 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT5 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 6 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT6 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 7 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT7 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 8 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT8 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 9 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT9 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      WHEN 10 THEN
        IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT10 IS NOT NULL) THEN RETURN TRUE ;
        ELSE RETURN FALSE ;
        END IF;
      ELSE
        RETURN FALSE;
      END CASE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_geo_valid_in_geo_rec_tbl_f;

 /*---------------------------------------------------------------------------+
  Function to get max column for which value is fetched
  ----------------------------------------------------------------------------*/

  FUNCTION get_max_fetched_value
    RETURN NUMBER IS
    ll_max_fetched_value NUMBER;
  BEGIN
    ll_max_fetched_value := 0;

    IF (geo_rec_tbl.COUNT > 0) THEN

      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT1 IS NOT NULL) THEN
	    ll_max_fetched_value := 1;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT2 IS NOT NULL) THEN
	    ll_max_fetched_value := 2;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT3 IS NOT NULL) THEN
	    ll_max_fetched_value := 3;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT4 IS NOT NULL) THEN
	    ll_max_fetched_value := 4;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT5 IS NOT NULL) THEN
	    ll_max_fetched_value := 5;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT6 IS NOT NULL) THEN
	    ll_max_fetched_value := 6;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT7 IS NOT NULL) THEN
	    ll_max_fetched_value := 7;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT8 IS NOT NULL) THEN
	    ll_max_fetched_value := 8;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT9 IS NOT NULL) THEN
	    ll_max_fetched_value := 9;
      END IF;
      IF (geo_rec_tbl(1).GEOGRAPHY_ELEMENT10 IS NOT NULL) THEN
	    ll_max_fetched_value := 10;
      END IF;
    END IF;
    RETURN ll_max_fetched_value;
  END get_max_fetched_value;

  -----------------------------------------------------------------------------+
  -- Procedure get_next_level_children_proc is to get next level children
  -- record for data already avaliable in intermediate
  -- table geo_rec_tbl. Once child records are fetched, move fetched data and
  -- geo_rec_tbl data to final table geo_suggest_tbl.
  -----------------------------------------------------------------------------+
  PROCEDURE get_next_level_children_proc IS
   l_structure_level_count      NUMBER;
   l_insert_geo_valid_rec_final VARCHAR2(1);
   l_insert_geo_suggest_rec     VARCHAR2(1);
   l_max_fetched_value          NUMBER;

   l_child_map_count            NUMBER;
   l_select_child               VARCHAR2(2000);
   l_from_child                 VARCHAR2(2000);
   l_where_child                VARCHAR2(4000);
   l_sql_stmt_child             VARCHAR2(10000);
   l_last_index_child           NUMBER;
   l_total_null_cols_child      NUMBER;

   TYPE child_cur_type IS REF CURSOR;
   child_cursor child_cur_type;
   child_rec    rec_type_mp;

  BEGIN

    l_child_map_count := 0;
    IF (geo_struct_tbl.COUNT > 1) THEN

	  -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           hz_utility_v2pub.debug
	               (p_message      => 'Trying to fetch children for complete next level...',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

      -- get max column for which value is fetched
      l_max_fetched_value := get_max_fetched_value;
      -- ns_debug.put_line('MAX FETCH VALUE :'||l_max_fetched_value);

      -- FND Logging for debug purpose
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      hz_utility_v2pub.debug
	              (p_message       => 'l_max_fetched_value:'||l_max_fetched_value
				                     ||' l_max_mapped_element_col_value:'||l_max_mapped_element_col_value,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
      END IF;

      -- does not have to execute child query if l_max_fetched_value = max mapped value
      -- i.e. there is no more child level
      IF (l_max_fetched_value < l_max_mapped_element_col_value) THEN

 	      -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
		              (p_message       => 'Trying to get child data...',
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	      END IF;

	      -- build the sql stmt for child records
	      FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP
		   IF TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)) = (l_max_fetched_value+1) THEN
	         l_child_map_count := l_child_map_count+1;

	         IF (l_child_map_count = 1) THEN
	           l_select_child := 'SELECT  distinct p1.geography_id , p1.geography_name ,'
	                           ||'p1.geography_code , p1.geography_type ';
	           l_from_child := ' FROM  hz_hierarchy_nodes hn1'
	                         ||', hz_geographies p1 ';
	           l_where_child := ' WHERE  hn1.parent_id = :x_parent_geo_id '
	            		||' AND  hn1.HIERARCHY_TYPE = ''MASTER_REF'' '
	            		||' AND  hn1.level_number = 1 '
	            		||' AND  hn1.CHILD_TABLE_NAME = ''HZ_GEOGRAPHIES'' '
	            		||' AND  SYSDATE BETWEEN hn1.effective_start_date AND hn1.effective_end_date '
	        		    ||' AND  NVL(hn1.status,''A'') = ''A'' '
	            		||' AND  hn1.PARENT_TABLE_NAME = ''HZ_GEOGRAPHIES'' '
	            		||' AND  hn1.child_id = p1.geography_id '
	            		||' AND  p1.GEOGRAPHY_USE = ''MASTER_REF'' '
	            		||' AND  SYSDATE BETWEEN p1.start_date AND p1.end_date ';
	           l_last_index_child := 1;
	         ELSE
	           l_select_child := l_select_child ||',p'||l_child_map_count||'.geography_id , p'||l_child_map_count||'.geography_name '
	                                       ||',p'||l_child_map_count||'.geography_code, p'||l_child_map_count||'.geography_type ';

	           l_from_child := l_from_child ||', hz_hierarchy_nodes hn'||l_child_map_count
	                                  ||', hz_geographies p'||l_child_map_count ;

	           l_where_child := l_where_child ||' AND hn'||l_child_map_count||'.parent_id = hn'||l_last_index_child||'.child_id '
	            		  	 			||' AND hn'||l_child_map_count||'.HIERARCHY_TYPE = ''MASTER_REF'' '
	            						||' AND hn'||l_child_map_count||'.level_number = 1 '
	            						||' AND hn'||l_child_map_count||'.CHILD_TABLE_NAME = ''HZ_GEOGRAPHIES'' '
	            						||' AND SYSDATE BETWEEN hn'||l_child_map_count||'.effective_start_date AND hn'||l_child_map_count||'.effective_end_date '
	            						||' AND NVL(hn'||l_child_map_count||'.status,''A'') = ''A'' '
	            						||' AND hn'||l_child_map_count||'.PARENT_TABLE_NAME = ''HZ_GEOGRAPHIES'' '
	            						||' AND hn'||l_child_map_count||'.child_id = p'||l_child_map_count||'.geography_id '
	            						||' AND p'||l_child_map_count||'.GEOGRAPHY_USE = ''MASTER_REF'' '
	            						||' AND SYSDATE BETWEEN p'||l_child_map_count||'.start_date AND p'||l_child_map_count||'.end_date ';
				l_last_index_child := l_child_map_count;
	         END IF;
	       END IF;
	    END LOOP;

	     -- pad rest of the columns in select stmt (to be fetched in child_rec record) to null
	     -- for example, if geo_struct_tbl contains 3 mapping rows, then other 7 elements (since total is 10),
	     -- have to be made NULL in select statement
	     l_total_null_cols_child := (10-(l_child_map_count))*4;

	     IF (l_total_null_cols_child > 0) THEN
	       FOR i IN 1..l_total_null_cols_child LOOP
	         l_select_child := l_select_child ||', NULL ';
	       END LOOP;
	     END IF;

	     l_sql_stmt_child := l_select_child||l_from_child||l_where_child;

 	      -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
		              (p_message       => 'Total NULL columns appended in fetch child query :'||l_total_null_cols_child,
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	      END IF;

 	      -- FND Logging for debug purpose
		  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	          hz_utility_v2pub.debug
		              (p_message       => 'Child Query :'||l_sql_stmt_child,
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	      END IF;

	     --ns_debug.put_line(' Child Query ');
	     --ns_debug.put_line(' ======================');
	     --ns_debug.put_line(l_sql_stmt_child);
	     --ns_debug.put_line(' ======================');

	     -- for each record in geo_rec_tbl execute this query
	     -- (Only if sql stmt has been built properly) (Bug 5157824 : Nishant 17-APR-2006)
	     IF ((geo_rec_tbl.COUNT > 0) AND
		     (l_total_null_cols_child < 40)) THEN -- (Bug 5157824 (if less than 40, it means sql has been built))
	       FOR j IN geo_rec_tbl.FIRST..geo_rec_tbl.LAST LOOP
	         -- execute the query
	         -- ns_debug.put_line('Parent Geo id:'||geo_rec_tbl(j).geography_id);

	         OPEN child_cursor FOR l_sql_stmt_child USING geo_rec_tbl(j).geography_id;
	           LOOP
	             FETCH child_cursor INTO child_rec;
	             EXIT WHEN child_cursor%NOTFOUND;
	             -- l_geo_data_count is counter for row. It is same the one used
				 -- in main query
				 l_geo_data_count := geo_suggest_tbl.COUNT+1;
	             EXIT WHEN l_geo_data_count > l_max_fetch_count; -- no. of records retrieved

	             -- move existing data from geo_rec_tbl to geo_suggest_tbl
	             move_from_geo_rec_to_suggest(j,l_geo_data_count);

	             -- retrieve data for child records
	             -----------------------------------------------------------------+
	             -- GEO_ID_1
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_1 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_1);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_1;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_1;
	          		  l_geo_rec_geo_code := child_rec.geo_code_1;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;
	             -----------------------------------------------------------------+
	             -- GEO_ID_2
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_2 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_2);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_2;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_2;
	          		  l_geo_rec_geo_code := child_rec.geo_code_2;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_3
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_3 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_3);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_3;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_3;
	          		  l_geo_rec_geo_code := child_rec.geo_code_3;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_4
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_4 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_4);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_4;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_4;
	          		  l_geo_rec_geo_code := child_rec.geo_code_4;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_5
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_5 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_5);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_5;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_5;
	          		  l_geo_rec_geo_code := child_rec.geo_code_5;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_6
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_6 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_6);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_6;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_6;
	          		  l_geo_rec_geo_code := child_rec.geo_code_6;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_7
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_7 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_7);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_7;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_7;
	          		  l_geo_rec_geo_code := child_rec.geo_code_7;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_8
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_8 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_8);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_8;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_8;
	          		  l_geo_rec_geo_code := child_rec.geo_code_8;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_9
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_9 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_9);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_9;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_9;
	          		  l_geo_rec_geo_code := child_rec.geo_code_9;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------------------------------------+
	             -- GEO_ID_10
	             -----------------------------------------------------------------+
	             -- assignments to suggest table
	             IF (child_rec.geo_id_10 IS NOT NULL) THEN
	                l_geo_rec_tab_col  := get_tab_col_from_geo_type(child_rec.geo_type_10);

				    IF (l_geo_rec_tab_col IS NOT NULL) THEN
		      		  l_geo_rec_geo_name := child_rec.geo_name_10;
	          		  l_geo_rec_geo_id   := child_rec.geo_id_10;
	          		  l_geo_rec_geo_code := child_rec.geo_code_10;

	       			  IF (l_geo_rec_geo_name IS NOT NULL) THEN
	         		  insert_in_geo_suggest_tbl(l_geo_data_count,
		                              			 l_geo_rec_tab_col,
		                                         l_geo_rec_geo_name,
		                              			 l_geo_rec_geo_id,
		                              			 l_geo_rec_geo_code
								      			 );
	       			  END IF;
	               END IF;
	             END IF;

	             -----------------------------------
				 -- ns_debug.put_line('Child data');
				 -- ns_debug.put_line('====================');
				 -- ns_debug.put_line(l_geo_data_count||':1:'||child_rec.geo_name_1||':'||child_rec.geo_code_1
				/*						 ||':2:'||child_rec.geo_name_2||':'||child_rec.geo_code_2
										 ||':3:'||child_rec.geo_name_3||':'||child_rec.geo_code_3
										 ||':4:'||child_rec.geo_name_4||':'||child_rec.geo_code_4
										 ||':5:'||child_rec.geo_name_5||':'||child_rec.geo_code_5
										 ||':6:'||child_rec.geo_name_6||':'||child_rec.geo_code_6
										 ||':7:'||child_rec.geo_name_7||':'||child_rec.geo_code_7
										 ||':8:'||child_rec.geo_name_8||':'||child_rec.geo_code_8
										 ||':9:'||child_rec.geo_name_9||':'||child_rec.geo_code_9
										 ||':10:'||child_rec.geo_name_10||':'||child_rec.geo_code_10);
	            */
	             -----------------------------------

	           END LOOP; -- end of loop for child cursor
	         CLOSE child_cursor;
	       END LOOP; -- end of loop for geo_rec_tbl
	     END IF; -- geo rec tbl count > 0 check
	   END IF; -- max fetched value < max mapped value check
    END IF; -- geo struct tbl count > 0 check

  END get_next_level_children_proc;

  ---------------------------------------------------------------------+
  -- Main code for Search_geographies procedure
  ---------------------------------------------------------------------+
  BEGIN

	-- FND Logging for debug purpose
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'BEGIN: Address Suggestion API',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
    END IF;

    -- initialize the parameters
    x_records_count := 0;
    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    l_success       := 'N';
    l_geo_validation_passed := 'N';

    -- Maximum number of rows fetched from suggestion API. If more than this
    -- number, return code will be set to 1000 and x_records_count will be set to
    -- NULL value.
    -- Setting it to 55 because no. of US states is 51 and we do not want to get
    -- too many rows everytime user queries for Country 'US'. As per PM suggestion,
    -- putting it to 55.
    l_max_fetch_count := 55;

    -- Hard coding this usage because it is used for MINIMUM address validation level
    -- check. Address validation level is only for GEOGRAPHY usage. This means p_address_usage
    -- parameter is not being used anywhere in the code. For future enhancements,
    -- we are exposing this parameter. (This is based on TDD review on 27 July 2005).
    -- l_address_usage := p_address_usage;
	l_address_usage := 'GEOGRAPHY';

	-- FND Logging for debug purpose
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
	              (p_message       => 'Get mapping details. Call build_geo_struct_tbl_pvt(+)',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_procedure,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
    END IF;

    -- get full mapped structure for specific address_style and
	-- store it in plsql table
    build_geo_struct_tbl_pvt(p_country_code, p_address_style, p_table_name, l_address_usage);

    -- FND Logging for debug purpose
	IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
	              (p_message       => 'Finished calling build_geo_struct_tbl_pvt(-)',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_procedure,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
    END IF;

    -- get address validation level, if it is null i.e. not set at any level
    -- (which ideally should not happen), then we will assume it to be no validation,
	-- since we can not error out records for that country.
    l_addr_val_level := NVL(hz_gnr_pub.get_addr_val_level(UPPER(p_country_code)),'NONE');
    --l_addr_val_level := 'ERROR';
    x_validation_level := l_addr_val_level;

    -- FND Logging for debug purpose
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       hz_utility_v2pub.debug
	               (p_message       => 'Validation Level:'||l_addr_val_level,
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
    END IF;

	-- ns_debug.put_line('Address Validation Level:'||l_addr_val_level);
	-- ns_debug.put_line('Address Validation Level API value:'||hz_gnr_pub.get_addr_val_level(p_country_code));

    /*-----------BEGIN GEO Validation and 2nd PASS TEST-----------------------------------------+
       Put logic of 1st pass or 2nd pass so, that if it is 2nd pass and
       validation level is ERROR and all fields required for geo validation are
	   passed, call geo validation api to check if geo usage is success. If
	   success, return success else go in suggestion logic of deriving helpful
	   suggestions for user

       NOTE: In case of WARNING, we are not setting global varibale
	   HZ_GNR_PVT.G_USER_ATTEMPT_COUNT because CPUI bypasses suggestion API if
	   user decides to save the record without changing any value in any field.
	   In that case, there will not be any 2nd attempt. When user changes anything
	   in any field, the cpui treats it as field modification and will again
	   call address suggestion. For address suggestion, it is similar to 1st attempt
	   So, do the suggestion check to suggest values if any.
    ------------------------------------------------------------------------+*/

    IF (l_addr_val_level = 'ERROR') THEN

      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       hz_utility_v2pub.debug
		              (p_message       => 'Performing Geo Validation to see if it will pass or fail later with current data (+)',
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	  END IF;

      -- do the geo validation (from backend api)
      BEGIN
		  HZ_GNR_PKG.validateLoc(
		    P_LOCATION_ID               => NULL,
		    P_USAGE_CODE                => 'GEOGRAPHY',
		    P_ADDRESS_STYLE             => P_ADDRESS_STYLE,
		    P_COUNTRY                   => P_COUNTRY_CODE,
		    P_STATE                     => P_STATE,
		    P_PROVINCE                  => P_PROVINCE,
		    P_COUNTY                    => P_COUNTY,
		    P_CITY                      => P_CITY,
		    P_POSTAL_CODE               => P_POSTAL_CODE,
		    P_POSTAL_PLUS4_CODE         => P_POSTAL_PLUS4_CODE,
		    P_ATTRIBUTE1                => P_ATTRIBUTE1,
		    P_ATTRIBUTE2                => P_ATTRIBUTE2,
		    P_ATTRIBUTE3                => P_ATTRIBUTE3,
		    P_ATTRIBUTE4                => P_ATTRIBUTE4,
		    P_ATTRIBUTE5                => P_ATTRIBUTE5,
		    P_ATTRIBUTE6                => P_ATTRIBUTE6,
		    P_ATTRIBUTE7                => P_ATTRIBUTE7,
		    P_ATTRIBUTE8                => P_ATTRIBUTE8,
		    P_ATTRIBUTE9                => P_ATTRIBUTE9,
		    P_ATTRIBUTE10               => P_ATTRIBUTE10,
		    P_CALLED_FROM               => 'VALIDATE',
		    P_LOCK_FLAG                 => FND_API.G_TRUE,
		    X_ADDR_VAL_LEVEL            => LX_ADDR_VAL_LEVEL,
		    X_ADDR_WARN_MSG             => LX_ADDR_WARN_MSG,
		    X_ADDR_VAL_STATUS           => LX_ADDR_VAL_STATUS,
		    X_STATUS                    => LX_STATUS)
			;

	      IF (LX_STATUS <> FND_API.G_RET_STS_SUCCESS) THEN
	        l_success := 'N';

	        -- FND Logging for debug purpose
	        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		       hz_utility_v2pub.debug
	              (p_message       => 'Geo Validation Failed. Perform suggestion logic.',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
		     END IF;

	      ELSE
	        -- check if it is 1st attempt for ERROR condition.
	        IF (HZ_GNR_PVT.G_USER_ATTEMPT_COUNT IS NULL)  THEN
	          l_success := 'N'; -- so that we can suggest more if there is anything during 1st attempt
	          l_geo_validation_passed := 'Y'; -- This will be used while setting message for validation level ERROR

               -- FND Logging for debug purpose
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	                hz_utility_v2pub.debug
		              (p_message       => 'Even though Geo Validation Passed, it was users 1st attempt, so continue with suggestion..',
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
   	           END IF;

			ELSE
	          l_success := 'Y';

    	      -- FND Logging for debug purpose
	          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		       hz_utility_v2pub.debug
	              (p_message       => 'Geo Validation Successful. No need for suggestion.',
		           p_prefix        => l_debug_prefix,
		           p_msg_level     => fnd_log.level_statement,
		           p_module_prefix => l_module_prefix,
		           p_module        => l_module
		          );
		      END IF;

	        END IF; -- end of 1st attempt check for geo validation

         END IF; -- end of success check for geo validation

      -- if any exception happens in Geo Validation API, continue with suggestion logic.
      EXCEPTION WHEN OTHERS THEN
        l_success := 'N';

        -- FND Logging for debug purpose
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       hz_utility_v2pub.debug
              (p_message       => 'Exception happend in Geo Validation API. Perform suggestion logic. '||SQLERRM,
	           p_prefix        => l_debug_prefix,
	           p_msg_level     => fnd_log.level_statement,
	           p_module_prefix => l_module_prefix,
	           p_module        => l_module
	          );
	     END IF;

	  END;

      --ns_debug.put_line('Geo Validation X_STATUS          :'||LX_STATUS);
      --ns_debug.put_line('Geo Validation X_ADDR_VAL_STATUS :'||LX_ADDR_VAL_STATUS);
    ELSE
      --ns_debug.put_line('Second Pass Test Failed...');

        -- FND Logging for debug purpose
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       hz_utility_v2pub.debug
              (p_message       => 'Validation level is not ERROR...Did not go into Geo Validation check..',
	           p_prefix        => l_debug_prefix,
	           p_msg_level     => fnd_log.level_statement,
	           p_module_prefix => l_module_prefix,
	           p_module        => l_module
	          );
	     END IF;

    END IF;
    ------------END OF GEO Validation and 2nd PASS TEST------------------------------------------+

    -- get into address suggestion mode only if geo validation (2nd pass) did not
	-- succeed.
	IF (l_addr_val_level IN ('ERROR','WARNING') AND (l_success = 'N')) THEN

      -- FND Logging for debug purpose
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       hz_utility_v2pub.debug
		              (p_message       => 'Mapped Elements Table Count:'||NVL(geo_struct_tbl.COUNT,0),
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	  END IF;

      -- Do main processing only if mapping is found
      IF (NVL(geo_struct_tbl.COUNT,0) > 0) THEN

			  -- Delete bind tables that are used for search1,2,and3
			  bind_table_1.DELETE;
			  bind_table_2.DELETE;

			  IF (p_country_code IS NOT NULL) THEN
			    bind_table_1(bind_table_1.COUNT+1).bind_value :=  UPPER(p_country_code);
			    -- for bind_table_2 bind country code at the time of building where clause
			  END IF;

		      -- initialize previous valid index to 0
		      l_priv_valid_index   := 0;
		      l_priv_valid_index_6 := 0;
		      l_priv_valid_index_7 := 0;

	          -- build the dynamic SQL (Search 1) for fetching data
			  FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP
		        CASE geo_struct_tbl(i).v_tab_col
			       WHEN  'COUNTRY' THEN
		             create_where_1_clause_pvt(i, geo_struct_tbl(i).v_param_value, 'CODE');
	               ELSE create_where_1_clause_pvt(i, geo_struct_tbl(i).v_param_value, 'BOTH');
			    END CASE;
		      END LOOP;

	       --------------BEGIN Search ---------------------------------------+

	        -- we delete the results table before starting any new search routine
	        geo_suggest_tbl.DELETE;
	        geo_rec_tbl.DELETE;

	        -------------------------------------------------------------------+
	        -- SEARCH 1:  Here we query for all passed parameters for which mapping
	        --            exist in mapping table.
	        -------------------------------------------------------------------+
            -- FND Logging for debug purpose
	        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		       hz_utility_v2pub.debug
			              (p_message       => 'Begin search 1 for ALL_PASSED_PARAM_SEARCH (+)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		    END IF;

	        l_search_type := 'ALL_PASSED_PARAM_SEARCH';
	        search_routine_pvt (pt_search_type => l_search_type,
	                            pt_bind_table  => bind_table_1);

            -- FND Logging for debug purpose
	        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		       hz_utility_v2pub.debug
			              (p_message       => 'End of search 1 for ALL_PASSED_PARAM_SEARCH (-)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		    END IF;

	        -----------------END of SEARCH 1-----------------------------------+

			/*--------------------------------------------------------------+
			   LOGIC TO DO FURTHER SEARCH
			1. If 1 row is identified,
              1.1 Suggest 1 level down children.
			2. If >1 row identified, show suggestions
			3. If 0 row
			   3.1 Break the input in following parameters
			       (Level 1 + Level n) (Country + Zip) (Suggest till Level n)
			        UNION
			       (Level 1 + Level (n-1) (Country + City) (Suggest till Level n-1)
			4. If still 0 rows
			   4.1 Start querying combinations from top node (starting with US), to get
			       validity of input parameters
			   4.2 This query continue till the point we cannot identify any further record.
			   4.3 Then for uniquely identified record, get child records.
			----------------------------------------------------------------*/

            ------------------------------------------------
            -- 1. If 1 row is identified,
            IF (geo_rec_tbl.COUNT = 1) THEN
              --  1.1 Check if fetched row satisfies geo validation criteria.
              --     1.1.1. If Yes, No further processing required. Success.
         -- comment out this logic of checking if this unique row satisfies geo validation req.
         -- uncomment it if later required.
         -- If 1 row found, always show child rec, if available.
		 --     IF (is_geo_valid_in_geo_rec_tbl_f(l_max_usage_element_col_value)) THEN --
         --       NULL;
         --     ELSE
                --   1.1.2. If No, Suggest 1 level down children.
                --          This will put data in geo_suggest_tbl also

               -- FND Logging for debug purpose
	           IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		            hz_utility_v2pub.debug
			              (p_message       => '1 Rec found in ALL_PASSED_PARAM_SEARCH. Performing child search (+)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		        END IF;

				get_next_level_children_proc;

               -- FND Logging for debug purpose
	           IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		            hz_utility_v2pub.debug
			              (p_message       => 'Child search for ALL_PASSED_PARAM_SEARCH completed (-)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		        END IF;


         --     END IF;
            END IF;
            ------------------------------------------------+

	        -------------------------------------------------------------------+
	        -- SEARCH 2
	        -- if still no record is found, then if min 4 level value is passed
	        -- then do combination for 1+4 union 1+5 levels (for example)
	        -- this is to handle backward compatibility (US+94065 union US+San Francisco)
		    -- case. Also it will help in fetching multiple parents records as we are skipping
		    -- parent levels which can be null
		    -- This search is performed if :
		    -- 1. Previous serach did not fetch any result
		    -- 2. User has passed value for Country and
			--      a. either for last mapped parameter (like Postal_code)
			--      b. OR for second last parameter (like city)
			-- 3. Parameter passed above is for level 4 and higher in geo structure
			--    i.e. for US, value has been passed either for city or postal code
	        -------------------------------------------------------------------+
		    IF ((geo_rec_tbl.COUNT = 0) AND
		      ((l_max_mapped_element_col_value = l_max_passed_element_col_value) OR
			   (l_max_mapped_element_col_value-1 = l_max_passed_element_col_value)) AND
		      (l_max_passed_element_col_value > 3)
			  )THEN

               -- FND Logging for debug purpose
   	           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		         hz_utility_v2pub.debug
			              (p_message       => 'Begin search 2..l_max_passed_element_col_value='||
						                      l_max_passed_element_col_value||' l_max_mapped_element_col_value='||
											  l_max_mapped_element_col_value,
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_statement,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
                END IF;

			    l_count_for_where_clause_2 := 0;
			    -- check if we have to build the where clause
		 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
		 	      IF (TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)) IN (1,l_max_mapped_element_col_value)) THEN --1,2,5
		 	        IF (geo_struct_tbl(i).v_param_value IS NOT NULL) THEN
		 	          l_count_for_where_clause_2 := l_count_for_where_clause_2 +1;
		 	        END IF;
		 	      END IF;
      			END LOOP;
			    -- if l_count_for_where_clause_2 = 2 i.e. all required params passed,
			    -- build where clause
			    IF (l_count_for_where_clause_2 = 2) THEN

                   -- FND Logging for debug purpose
	   	           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
			         hz_utility_v2pub.debug
				              (p_message       => 'For Where Clause 2...required params are passed',
					           p_prefix        => l_debug_prefix,
					           p_msg_level     => fnd_log.level_statement,
					           p_module_prefix => l_module_prefix,
					           p_module        => l_module
					          );
	               END IF;

		 	       FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
		 	        IF (TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)) IN (1,l_max_mapped_element_col_value)) THEN --1,2,5
		 	          IF (geo_struct_tbl(i).v_param_value IS NOT NULL) THEN
		 	            create_where_2_clause_pvt(i, 1);
		 	          END IF;
		 	        END IF;
      			  END LOOP;
      			  IF (l_lowest_mapped_geo_type IS NOT NULL) THEN
      			    l_where_6 := l_where_6 ||' AND hg0.geography_type = :x_where_6_geo_type ';
      			    bind_table_2(bind_table_2.COUNT+1).bind_value := l_lowest_mapped_geo_type;
      			  END IF;
                END IF;

			    l_count_for_where_clause_3 := 0;
			    -- check if we have to build the where clause
		 	    FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
		 	      IF (TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)) IN (1,l_max_mapped_element_col_value-1)) THEN --1,2,4
		 	        -- build the where clause
		 	        IF (geo_struct_tbl(i).v_param_value IS NOT NULL) THEN
		 	          l_count_for_where_clause_3 := l_count_for_where_clause_3 +1;
		 	        END IF;
		 	      END IF;
      			END LOOP;
			    -- if l_count_for_where_clause_3 = 2 i.e. all required params passed,
			    -- build where clause
			    IF (l_count_for_where_clause_3 = 2) THEN
                   -- FND Logging for debug purpose
	   	           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
			         hz_utility_v2pub.debug
				              (p_message       => 'For Where Clause 3...required params are passed',
					           p_prefix        => l_debug_prefix,
					           p_msg_level     => fnd_log.level_statement,
					           p_module_prefix => l_module_prefix,
					           p_module        => l_module
					          );
	               END IF;

		 	      FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST  LOOP
		 	        IF (TO_NUMBER(SUBSTR(geo_struct_tbl(i).v_element_col,18)) IN (1,l_max_mapped_element_col_value-1)) THEN --1,2,4
		 	      	  IF (geo_struct_tbl(i).v_param_value IS NOT NULL) THEN
		 	            create_where_2_clause_pvt(i, 2);
		 	          END IF;
		 	        END IF;
      			  END LOOP;
                  -- use geography type that of l_lowest_mapped_geo_type (since we want data till last level)
     			  IF (l_lowest_mapped_geo_type IS NOT NULL) THEN
      			    l_where_7 := l_where_7 ||' AND hg0.geography_type = :x_where_7_geo_type ';
      			    bind_table_2(bind_table_2.COUNT+1).bind_value
					   := get_geo_type_from_element_col('GEOGRAPHY_ELEMENT'||to_char(l_max_mapped_element_col_value-1)); --l_lowest_mapped_geo_type;
      			  END IF;
      			END IF;

		        -- execute query only if any of these 2 sql queries are constructed completely
		        IF ((l_count_for_where_clause_2 = 2) OR (l_count_for_where_clause_3 = 2)) THEN

                  -- FND Logging for debug purpose
				  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
  		              hz_utility_v2pub.debug
			              (p_message       => 'Begin search 2 for LEVEL4_UNION_LEVEL5_SEARCH (+)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
                  END IF;

		          l_search_type := 'LEVEL4_UNION_LEVEL5_SEARCH';
		          search_routine_pvt (pt_search_type => l_search_type,
		                              pt_bind_table  => bind_table_2);

                  -- FND Logging for debug purpose
				  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
  		              hz_utility_v2pub.debug
			              (p_message       => 'End search 3 for LEVEL4_UNION_LEVEL5_SEARCH (-)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
                  END IF;

                ELSE -- ignored LEVEL4_UNION_LEVEL5_SEARCH search

				  -- FND Logging for debug purpose
				  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
  		              hz_utility_v2pub.debug
			              (p_message       => 'Ignored LEVEL4_UNION_LEVEL5_SEARCH because values for '||
						                      'neither Level1+Level(n) '||
						                      'nor Level1 + Level(n-1) are passed',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
                  END IF;

		        END IF;

			  -- Again check, if 1 row fetched, try to get child records
              IF (geo_rec_tbl.COUNT = 1) THEN

			    -- FND Logging for debug purpose
	            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		            hz_utility_v2pub.debug
			              (p_message       => '1 Rec found in LEVEL4_UNION_LEVEL5_SEARCH. Performing child search (+)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		        END IF;

                get_next_level_children_proc;

               -- FND Logging for debug purpose
	           IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		            hz_utility_v2pub.debug
			              (p_message       => 'Completed child search for LEVEL4_UNION_LEVEL5_SEARCH (-)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		        END IF;

              END IF;

		    END IF;   -- End of LEVEL4_UNION_LEVEL5_SEARCH search (search 3)
            ----------------END OF SEARCH 2 -----------------------------------+

         /*---------------- Search 3 -----------------------------------------+
          If still no suggestion could be derived, then check till what level
		  from top we have unique valid values from top. Then suggest 1 level
		  down from there. To handle case where full passed combination or partial
		  combination is wrong. In that case, at least suggest whatever is valid
		  down the country. It could mean suggesting all states if only country
		  is valid or suggesting County if Country and State are valid.
		 --------------------------------------------------------------------*/

           IF (geo_rec_tbl.COUNT = 0) AND (geo_struct_tbl.COUNT > 0) THEN
	          validate_input_values_proc (l_geo_struct_tbl     => geo_struct_tbl,
	                                  x_not_validated_geo_type => lx_not_validated_geo_type,
	                                  x_rec_count_flag         => lx_rec_count_flag,
									  x_success_geo_level      => lx_success_geo_level);

			  bind_table_1.DELETE;

			  IF (p_country_code IS NOT NULL) THEN
			    bind_table_1(bind_table_1.COUNT+1).bind_value :=  UPPER(p_country_code);
			    -- for bind_table_2 bind country code at the time of building where clause
			  END IF;

		      -- initialize previous valid index to 0
		      l_priv_valid_index   := 0;
              l_from_5 := NULL;
              l_where_5 := NULL;
			  l_max_passed_element_col_value := 0;	-- reset it as we want to query data only
			                                        -- till valid values

	          -- build the dynamic SQL (Search 1) for fetching data
			  FOR i IN geo_struct_tbl.FIRST..geo_struct_tbl.LAST LOOP
			    IF (geo_struct_tbl(i).v_level <= lx_success_geo_level) THEN
  		          CASE geo_struct_tbl(i).v_tab_col
			         WHEN  'COUNTRY' THEN
		               create_where_1_clause_pvt(i, geo_struct_tbl(i).v_param_value, 'CODE');
	                 ELSE create_where_1_clause_pvt(i, geo_struct_tbl(i).v_param_value, 'BOTH');
			      END CASE;
			    END IF;
		      END LOOP;

              l_search_type := 'SEARCH_FROM_TOP';
              search_routine_pvt (pt_search_type => l_search_type,
		                           pt_bind_table  => bind_table_1,
								   pt_success_geo_level => lx_success_geo_level);

              -- 1. If 1 row is identified,
              -- If more than 1 rows, then just suggest them.
              IF (geo_rec_tbl.COUNT = 1) THEN

               -- FND Logging for debug purpose
	           IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		            hz_utility_v2pub.debug
			              (p_message       => '1 record found for SEARCH_FROM_TOP search. Performing child search (+)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		        END IF;

                get_next_level_children_proc;

                -- FND Logging for debug purpose
	            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
		            hz_utility_v2pub.debug
			              (p_message       => 'Completed child search for SEARCH_FROM_TOP search.(-)',
				           p_prefix        => l_debug_prefix,
				           p_msg_level     => fnd_log.level_procedure,
				           p_module_prefix => l_module_prefix,
				           p_module        => l_module
				          );
		        END IF;

              END IF;

		   END IF;
         -------------------END OF SEARCH 3------------------------------------+

	     -- Nishant : commented out country only check (redundant check on 18-Apr-2006)
	     -- END IF; -- end of check that only COUNTRY is mapped.
	     --2------------------------------------------------------------------+

         -- if anything exists in intermediate table geo_rec_tbl but
         -- nothing is there in final table geo_suggest_tbl, then copy it to final
		 -- table, as that is the best that could be derived for suggestion.
		 -- One example is: If country is passed and there are no states setup
		 -- for that country.
         IF ((geo_suggest_tbl.COUNT = 0) AND (geo_rec_tbl.COUNT > 0)) THEN

  		    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	              hz_utility_v2pub.debug
		              (p_message       => 'Geo_suggest_tbl count is 0.. while geo_rec_tbl count is '
					                       ||TO_CHAR(geo_rec_tbl.COUNT),
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	        END IF;

            FOR i IN geo_rec_tbl.FIRST..geo_rec_tbl.LAST LOOP
              move_from_geo_rec_to_suggest(i,i);
            END LOOP;

		    -- FND Logging for debug purpose
		    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	              hz_utility_v2pub.debug
		              (p_message       => 'Moved records from geo_rec_tbl to geo_suggest_tbl',
			           p_prefix        => l_debug_prefix,
			           p_msg_level     => fnd_log.level_statement,
			           p_module_prefix => l_module_prefix,
			           p_module        => l_module
			          );
	        END IF;

         END IF;

		 -------------------------------------------------------------------------+
		 -- Check if exact match for the complete mapping is found i.e. whatever user
		 -- has enetered for complete mapping is fetched, then we do not need to
		 -- return suggestion. Delete other suggested values and just return the
		 -- fetched values. Bug 4633962 (Fixed by Nishant Singhai on 29-Sep-2005)
		 -------------------------------------------------------------------------+
		 check_exact_match_del_rest;

		 -------------------------------------------------------------------------+
		 -- Output data
		 -- Changed logic to process output data based on discussion with dev team,
		 -- and PMs. Bug 4600030 (28-Sep-2005)
		 -------------------------------------------------------------------------+
         process_output_data_proc;

	  --------------------no geo mapping exist --------------------------+
	  ELSIF  (geo_struct_tbl.COUNT = 0) THEN

	    -- FND Logging for debug purpose
		IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'No Mapping Exists for passed country code and '||
			                       'address style combination (return code = NO_MAPPING_EXISTS)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
        END IF;

        -- set return code and return message
        setup_msg_and_ret_code_proc(p_return_code => 50, /* NO_MAPPING_EXISTS */
		                            p_msg_name    => 'HZ_GEO_NO_MAP_FOR_COUNTRY');

     	-- ns_debug.put_line('NO MAPPING EXISTS ');

      END IF; -- end of geo_struct_tbl count check

    ----------------Validation level is miniumum or none -----------------+
    ELSE -- Validation level is MINIMUM or NONE

	  -- FND Logging for debug purpose
	  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Validation Level is :'||l_addr_val_level||
			                       '. Calling procedure process_output_data_proc(+)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
      END IF;

      process_output_data_proc;

	  -- FND Logging for debug purpose
	  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'Completed procedure process_output_data_proc(-)',
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_procedure,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
      END IF;

    END IF;

    -- FND Logging for debug purpose
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => 'END: Address Suggestion API.'||
			                       ' Value of x_return_code='||x_return_code||
								   ', x_records_count='||x_records_count ,
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_statement,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
    END IF;

	EXCEPTION
	WHEN OTHERS THEN

	  -- FND Logging for debug purpose
	  IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          hz_utility_v2pub.debug
               (p_message       => SUBSTR('SYSTEM ERROR occured in Address Suggestion API. '||
			                        SQLERRM, 1,255),
	            p_prefix        => l_debug_prefix,
	            p_msg_level     => fnd_log.level_exception,
	            p_module_prefix => l_module_prefix,
	            p_module        => l_module
	           );
      END IF;

      HZ_GNR_PVT.G_USER_ATTEMPT_COUNT := NULL; -- reset the global variable
	  x_return_status := FND_API.G_RET_STS_ERROR ;

      -- set return code and return message
      setup_msg_and_ret_code_proc(p_return_code => 200); /* SYSTEM_ERROR (System Error) */

      FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
      FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data );

	  -- ns_debug.put_line(SUBSTR('ERROR :'||SQLERRM,1,255));
	  -- ns_debug.put_line('location= '||l_error_location);
      -- ns_debug.put_line(l_sql_stmt);

  END search_geographies;

END HZ_GNR_PVT;

/
