--------------------------------------------------------
--  DDL for Package Body OCM_ADD_DATA_POINTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_ADD_DATA_POINTS" AS
/*  $Header: OCMGTDPB.pls 120.9.12010000.2 2008/12/18 21:30:03 mraymond ship $ */

pg_wf_debug VARCHAR2(1) := ar_cmgt_util.get_wf_debug_flag;

PROCEDURE GenarateCaseFolderDetails (
		p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_sequence_number               IN      NUMBER,
        p_parent_data_point_id          IN      NUMBER,
        p_parent_cf_detail_id           IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_mode							IN		VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_included_in_checklist         IN      VARCHAR2 default NULL,
        p_data_point_value_id			IN		NUMBER  default NULL,
        p_case_folder_detail_id         IN OUT NOCOPY      NUMBER,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2) IS
BEGIN
		p_resultout := 0;
	-- Run always in create mode.
	-- Ignore the mode. because we are always deleting the additional data records
		AR_CMGT_CONTROLS.POPULATE_CF_ADP_DETAILS  (
       		p_case_folder_id		=> p_case_folder_id,
        	p_data_point_id     	=> p_data_point_id,
        	p_sequence_number   	=> p_sequence_number,
        	p_parent_data_point_id  => p_parent_data_point_id,
        	p_parent_cf_detail_id   => p_parent_cf_detail_id,
        	p_data_point_value      => p_data_point_value,
        	p_score                 => p_score,
        	p_included_in_checklist => p_included_in_checklist,
			p_data_point_value_id	=> p_data_point_value_id,
        	p_case_folder_detail_id => p_case_folder_detail_id,
        	p_errmsg                => p_errmsg,
        	p_resultout             => p_resultout );

		IF p_resultout <> 0
		THEN
			p_errmsg := 'Error while calling AR_CMGT_CONTROLS.POPULATE_CF_ADP_DETAILS for Data Point Id: '||
			            p_data_point_id ||'Error :'|| p_errmsg;
			return;
		END IF;
    /*ELSIF p_mode = 'REFRESH'
    THEN
    	AR_CMGT_CONTROLS.UPDATE_CF_ADP_DETAILS (
    		p_case_folder_id		=> p_case_folder_id,
        	p_data_point_id     	=> p_data_point_id,
        	p_sequence_number   	=> p_sequence_number,
        	p_parent_data_point_id  => p_parent_data_point_id,
        	p_parent_cf_detail_id   => p_parent_cf_detail_id,
        	p_data_point_value      => p_data_point_value,
        	p_score                 => p_score,
        	p_included_in_checklist => p_included_in_checklist,
        	p_case_folder_detail_id => p_case_folder_detail_id,
        	x_errmsg                => p_errmsg,
        	x_resultout             => p_resultout );

	END IF; */
END;

PROCEDURE BuildExecuteSql (
	p_package_name			IN		VARCHAR2,
	p_function_name			IN		VARCHAR2,
	p_result_value			OUT NOCOPY	VARCHAR2,
	p_error_msg				OUT NOCOPY  VARCHAR2,
	p_resultout				OUT NOCOPY  VARCHAR2 ) IS

	l_sql_statement			VARCHAR2(2000);

    x_resultout             VARCHAR2(1);
    x_errormsg              VARCHAR2(2000);
    l_result_date_value     DATE;


BEGIN
	p_resultout := 0;

	IF p_package_name IS NOT NULL AND
	   p_function_name IS NOT NULL
	THEN
          IF pg_wf_debug = 'Y'
          THEN
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'before call:');
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value_id = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);
          END IF;

		-- first clear the global pl/sql table
		pg_ocm_dp_values_tbl.delete;

        -- first check whether the data point

		l_sql_statement := 'BEGIN :1 := '|| p_package_name ||'.'|| p_function_name ||
								'( :2 , :3 ); END;';

	IF pg_ocm_add_dp_param_rec.p_return_data_type = 'D' -- date format
        THEN
            EXECUTE IMMEDIATE l_sql_statement USING  OUT l_result_date_value, OUT x_resultout, OUT x_errormsg ;
            p_result_value := to_char(l_result_date_value); --,  pg_ocm_add_dp_param_rec.p_return_date_format);
        ELSE
            EXECUTE IMMEDIATE l_sql_statement USING  OUT p_result_value, OUT x_resultout, OUT x_errormsg ;
        END IF;


        IF x_resultout <> FND_API.G_RET_STS_SUCCESS
        THEN
            p_resultout := 1;
            p_error_msg	:= 'Package '||p_package_name|| ' Function '||p_function_name ||
									' Failed. Error '||  x_errormsg;
            ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id, p_error_msg);
            return;
        END IF;
    ELSE
    	p_result_value := NULL;
    END IF;

	EXCEPTION
		WHEN OTHERS THEN
			p_resultout := 1;
			p_error_msg := 'Sql Error While Calling Sql Function '||sqlerrm ||
							'Package Name:'
							|| p_package_name ||' Function Name:'|| p_function_name;
                        ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id, p_error_msg);
END;


PROCEDURE GetChildDataPoints (
	p_mode			IN		VARCHAR2,
	p_parent_data_point_id	IN		NUMBER,
	p_parent_cf_detail_id	IN		NUMBER,
	p_data_point_value      IN		VARCHAR2,
	p_error_msg		OUT NOCOPY	VARCHAR2,
	p_resultout		OUT NOCOPY	VARCHAR2 ) IS

    l_case_folder_id                NUMBER;
    l_data_point_id                 NUMBER;
    l_parent_data_point_id          NUMBER;


	CURSOR getChildDataPointsC IS
		SELECT data_point_id, package_name, function_name,
                       parent_data_point_id,
                       return_data_type, return_date_format
		FROM   ar_cmgt_data_points_vl
		where  enabled_flag = 'Y'
		start with    parent_data_point_id = p_parent_data_point_id
		connect by prior data_point_id = parent_data_point_id
		order by level;


    CURSOR getAllParentValues IS
		SELECT case_folder_detail_id, case_folder_id,
		       data_point_id, data_point_value, sequence_number,
                       data_point_value_id
		FROM   ar_cmgt_cf_dtls
		WHERE  case_folder_id = l_case_folder_id
		AND    data_point_id =  l_parent_data_point_id;

    l_return_value          ar_cmgt_cf_dtls.data_point_value%type;
    l_case_folder_detail_id	NUMBER;
    l_parent_cf_detail_id	NUMBER;
    l_mode					VARCHAR2(30) := p_mode;

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'ocm_add_data_points_pkg.getchilddatapoints()+');
    END IF;

	FOR getChildDataPointsRec IN getChildDataPointsC
	LOOP


		-- Now for all values in case folder table
		l_case_folder_id := pg_ocm_add_dp_param_rec.p_case_folder_id;
		l_parent_data_point_id := getChildDataPointsRec.parent_data_point_id;

		FOR getAllParentValuesRec IN getAllParentValues
		LOOP
		   pg_ocm_add_dp_param_rec.p_data_point_value :=
                             getAllParentValuesRec.data_point_value;
		   pg_ocm_add_dp_param_rec.p_data_point_id := getChildDataPointsRec.data_point_id;
       		   pg_ocm_add_dp_param_rec.p_parent_data_point_id :=
                             getChildDataPointsRec.parent_data_point_id;
                   pg_ocm_add_dp_param_rec.p_return_data_type :=
                             getChildDataPointsRec.return_data_type;
                   pg_ocm_add_dp_param_rec.p_return_date_format :=
                             getChildDataPointsRec.return_date_format;
       		   pg_ocm_add_dp_param_rec.p_data_point_value_id :=
                             getAllParentValuesRec.data_point_value_id;
       		   l_case_folder_detail_id := null;
                   IF pg_wf_debug = 'Y'
                   THEN
                       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                         'par_dp_id=' || getChildDataPointsRec.parent_data_point_id ||
                         ' dp_id=' || getChildDataPointsRec.data_point_id ||
                         ' pkg.fun()=' || getChildDataPointsRec.package_name ||
                         '.' || getChildDataPointsRec.function_name);
                       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'before call:');
                       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value = ' ||
                           OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value);
                       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value_id = ' ||
                           OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);
                   END IF;

       		   BuildExecuteSql (
            	      p_package_name  =>  getChildDataPointsRec.package_name,
            	      p_function_name =>  getChildDataPointsRec.function_name,
              	      p_result_value  =>  l_return_value,
		      p_error_msg     =>  p_error_msg,
		      p_resultout     =>  p_resultout )  ;

                IF pg_wf_debug = 'Y'
                THEN
                     ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                     '  return_value = ' || l_return_value || ' p_resultout = ' || p_resultout);
                END IF;

			IF p_resultout <> 0
			THEN
				return;
			END IF;

			pg_ocm_add_dp_param_rec.p_data_point_value := l_return_value;

			IF l_return_value IS NOT NULL
        	        THEN
        		    GenarateCaseFolderDetails (
				p_case_folder_id 	=>  pg_ocm_add_dp_param_rec.p_case_folder_id,
        			p_data_point_id         =>  getChildDataPointsRec.data_point_id,
        			p_sequence_number       =>  1,
        			p_parent_data_point_id  =>  getChildDataPointsRec.parent_data_point_id,
        			p_parent_cf_detail_id   =>  getAllParentValuesRec.case_folder_detail_id,
        			p_data_point_value      =>  l_return_value,
        			p_mode			=>  l_mode,
        			p_score                 =>  NULL,
        			p_included_in_checklist =>  'N',
        			p_data_point_value_id	=>  NULL,
        			p_case_folder_detail_id =>  l_case_folder_detail_id,
        			p_errmsg                =>  p_error_msg,
        			p_resultout             =>  p_resultout );

        		    IF p_resultout <> 0
			    THEN
  			      return;
			    END IF;

        	        ELSIF l_return_value IS NULL
		        THEN
		   	   -- check whether the global pl/sql table is populated or not
		   	   IF pg_ocm_dp_values_tbl.count = 0
		   	   THEN
		   		GenarateCaseFolderDetails (
				   p_case_folder_id   	   =>  pg_ocm_add_dp_param_rec.p_case_folder_id,
        			   p_data_point_id         =>  getChildDataPointsRec.data_point_id,
        			   p_sequence_number       =>  1,
        			   p_parent_data_point_id  =>  getChildDataPointsRec.parent_data_point_id,
        			   p_parent_cf_detail_id   =>  getAllParentValuesRec.case_folder_detail_id,
        			   p_data_point_value      =>  l_return_value,
        			   p_mode						=>  p_mode,
        			   p_score                 => 	NULL,
        			   p_included_in_checklist =>  'N',
        			   p_data_point_value_id   =>  NULL,
        			   p_case_folder_detail_id =>  l_case_folder_detail_id,
        			   p_errmsg                =>  p_error_msg,
        			   p_resultout             =>  p_resultout );

        			IF p_resultout <> 0
				THEN
				   return;
				END IF;

        		ELSIF pg_ocm_dp_values_tbl.count > 0
			THEN
					-- first insert all the values to table
        			FOR i in 1 .. pg_ocm_dp_values_tbl.count
				LOOP
                                   IF pg_wf_debug = 'Y'
                                   THEN
                                      ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                                      '  return_value(' || i || ') = ' ||
                                      pg_ocm_dp_values_tbl(i).p_data_point_value);
                                   END IF;

						GenarateCaseFolderDetails (
						p_case_folder_id            =>  pg_ocm_add_dp_param_rec.p_case_folder_id,
        					p_data_point_id             =>  getChildDataPointsRec.data_point_id,
        					p_sequence_number           =>  pg_ocm_dp_values_tbl(i).p_sequence_number,
        					p_parent_data_point_id      =>  getChildDataPointsRec.parent_data_point_id,
        					p_parent_cf_detail_id       =>  getAllParentValuesRec.case_folder_detail_id,
        					p_data_point_value          =>  pg_ocm_dp_values_tbl(i).p_data_point_value,
        					p_mode						=>  p_mode,
        					p_score                     => 	NULL,
        					p_included_in_checklist     =>  'N',
        					p_data_point_value_id		=>  pg_ocm_dp_values_tbl(i).p_data_point_value_id,
        					p_case_folder_detail_id     =>  l_case_folder_detail_id,
        					p_errmsg                    =>  p_error_msg,
        					p_resultout                 =>  p_resultout );
        				IF p_resultout <> 0
					THEN
					  return;
					END IF;
				END LOOP;
                        END IF;
			END IF;

                  IF pg_wf_debug = 'Y'
                  THEN
                     ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'after call:');
                     ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value = ' ||
                         OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value);
                     ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value_id = ' ||
                         OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);
                  END IF;

		END LOOP;  -- end of getAllParentValuesRec
	END LOOP;
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'ocm_add_data_points_pkg.getchilddatapoints()-');
    END IF;
END;

PROCEDURE GetParentDataPoints (
	p_mode			IN			VARCHAR2,
	p_error_msg		OUT NOCOPY	VARCHAR2,
	p_resultout		OUT NOCOPY	VARCHAR2 ) IS


    l_case_folder_id            NUMBER;
    l_data_point_id             NUMBER;
	CURSOR getParentDataPoints IS
		SELECT data_point_id,package_name, function_name, scorable_flag,
			   application_id, return_data_type, return_date_format
		FROM   ar_cmgt_data_points_vl
		where  enabled_flag = 'Y'
		and    data_point_category = 'ADDITIONAL'
		and    parent_data_point_id IS NULL
		and    ( application_id = pg_ocm_add_dp_param_rec.p_SOURCE_RESP_APPLN_ID
            OR   application_id = 222 );

	CURSOR getAllValues IS
		SELECT case_folder_detail_id, case_folder_id,
		       data_point_id,
		       data_point_value, sequence_number
		FROM   ar_cmgt_cf_dtls
		WHERE  case_folder_id = l_case_folder_id
		AND    data_point_id =  l_data_point_id;

	l_return_value			ar_cmgt_cf_dtls.data_point_value%type;
	l_sequence_num			NUMBER := 1;
	l_case_folder_detail_id	NUMBER;
        l_dp_exists VARCHAR2(1) := 'N';
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'ocm_add_data_points_pkg.getparentdatapoints()+');
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              '  p_mode = ' || p_mode);
    END IF;


	p_resultout := 0;

	FOR getParentDataPointsRec IN getParentDataPoints
	LOOP
         	pg_ocm_add_dp_param_rec.p_data_point_application_id :=
                   getParentDataPointsRec.application_id;
      		pg_ocm_add_dp_param_rec.p_data_point_id :=
                   getParentDataPointsRec.data_point_id;
                pg_ocm_add_dp_param_rec.p_return_data_type :=
                   getParentDataPointsRec.return_data_type;
                pg_ocm_add_dp_param_rec.p_return_date_format :=
                   getParentDataPointsRec.return_date_format;
      		pg_ocm_add_dp_param_rec.p_data_point_value := NULL;
      		l_case_folder_detail_id := null;
      		pg_ocm_dp_values_tbl.delete;

        IF pg_wf_debug = 'Y'
        THEN
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'app_id=' || getParentDataPointsRec.application_id ||
              ' dp_id=' || getParentDataPointsRec.data_point_id ||
              ' pkg.fun()=' || getParentDataPointsRec.package_name ||
              '.' || getParentDataPointsRec.function_name);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'before call:');
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_value_id = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);
        END IF;

      		BuildExecuteSql (
	  	   p_package_name  => getParentDataPointsRec.package_name,
		   p_function_name => getParentDataPointsRec.function_name,
		   p_result_value  => l_return_value,
		   p_error_msg     => p_error_msg,
		   p_resultout     => p_resultout   );

        IF pg_wf_debug = 'Y'
        THEN
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              '  return_value = ' || l_return_value || ' p_resultout = ' || p_resultout);
        END IF;

	IF p_resultout <> 0
        THEN
	   return;
        END IF;

	pg_ocm_add_dp_param_rec.p_data_point_value := l_return_value;

        IF l_return_value IS NOT NULL
        THEN
            GenarateCaseFolderDetails (
		p_case_folder_id => pg_ocm_add_dp_param_rec.p_case_folder_id,
        	p_data_point_id  => getParentDataPointsRec.data_point_id,
        	p_sequence_number           => 1,
        	p_parent_data_point_id      =>  NULL,
        	p_parent_cf_detail_id       =>  NULL,
        	p_data_point_value          =>  l_return_value,
        	p_mode                      =>  p_mode,
        	p_score                     => 	NULL,
        	p_included_in_checklist     =>  'N',
        	p_data_point_value_id	    =>  NULL,
        	p_case_folder_detail_id     =>  l_case_folder_detail_id,
        	p_errmsg                    =>  p_error_msg,
        	p_resultout                 =>  p_resultout );

       		IF p_resultout <> 0
		THEN
		   return;
		END IF;

        ELSIF l_return_value IS NULL
	THEN
	    -- check whether the global pl/sql table is populated or not
	    IF pg_ocm_dp_values_tbl.count = 0
	    THEN

               /* 7416921 - This point executes if buildexecsql returns ok,
                  but the return_value is NULL (either a function that returns
                  null intentionally, or a non-function ADP)

                  In the case of a non-function ADP, we should only create
                  this record if it does not already exist */

               IF p_mode = 'REFRESH'
               THEN
                  IF getParentDataPointsRec.function_name IS NULL
                  THEN
                     BEGIN

                        SELECT 'Y'
                        INTO   l_dp_exists
                        FROM   ar_cmgt_cf_dtls cfd
                        WHERE  cfd.case_folder_id =
                             pg_ocm_add_dp_param_rec.p_case_folder_id
                        AND    cfd.data_point_id =
                             getParentDataPointsRec.data_point_id;

                     EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                          l_dp_exists := 'N';
                     END;
                  END IF;
               ELSE
                  l_dp_exists := 'N';
               END IF;

               IF pg_wf_debug = 'Y'
               THEN
                  ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                     '  l_dp_exists = ' || l_dp_exists);
               END IF;

               IF l_dp_exists = 'N'
               THEN
	       GenarateCaseFolderDetails (
                  p_case_folder_id =>  pg_ocm_add_dp_param_rec.p_case_folder_id,
        	  p_data_point_id  =>  getParentDataPointsRec.data_point_id,
        	  p_sequence_number           =>  1,
        	  p_parent_data_point_id      =>  NULL,
          	  p_parent_cf_detail_id       =>  NULL,
        	  p_data_point_value          =>  l_return_value,
        	  p_mode		      =>  p_mode,
        	  p_score                     =>  NULL,
        	  p_included_in_checklist     =>  'N',
        	  p_data_point_value_id       =>  NULL,
        	  p_case_folder_detail_id     =>  l_case_folder_detail_id,
        	  p_errmsg                    =>  p_error_msg,
        	  p_resultout                 =>  p_resultout );

                  IF p_resultout <> 0
	          THEN
	             return;
	          END IF;
               END IF; -- l_dp_exists
	    ELSIF pg_ocm_dp_values_tbl.count > 0
 	    THEN
		-- first insert all the values to table
                FOR i in 1 .. pg_ocm_dp_values_tbl.count
		LOOP

                  IF pg_wf_debug = 'Y'
                  THEN
                    ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                                      '  return_value(' || i || ') = ' ||
                                pg_ocm_dp_values_tbl(i).p_data_point_value);
                  END IF;

                    GenarateCaseFolderDetails (
		        p_case_folder_id =>  pg_ocm_add_dp_param_rec.p_case_folder_id,
        	        p_data_point_id  =>  getParentDataPointsRec.data_point_id,
        	        p_sequence_number  =>  pg_ocm_dp_values_tbl(i).p_sequence_number,
        	        p_parent_data_point_id      =>  NULL,
        		p_parent_cf_detail_id       =>  NULL,
                        p_data_point_value          =>  pg_ocm_dp_values_tbl(i).p_data_point_value,
                        p_mode                      =>  p_mode,
        		p_score                     => 	NULL,
        		p_included_in_checklist     =>  'N',
        		p_data_point_value_id       =>  pg_ocm_dp_values_tbl(i).p_data_point_value_id,
        		p_case_folder_detail_id     =>  l_case_folder_detail_id,
        		p_errmsg                    =>  p_error_msg,
        		p_resultout                 =>  p_resultout );

                  IF p_resultout <> 0
		  THEN
		     return;
		  END IF;
                END LOOP;

                -- now for each value see any child record exists and
		-- keep continue
                l_case_folder_id := pg_ocm_add_dp_param_rec.p_case_folder_id;
                l_data_point_id := getParentDataPointsRec.data_point_id;

		END IF;

             END IF;

	     GetChildDataPoints (
		p_mode                  =>  p_mode,
		p_parent_data_point_id	=>  getParentDataPointsRec.data_point_id,
		p_parent_cf_detail_id   =>  NULL,
	        p_data_point_value	=>  NULL,
		p_error_msg             =>  p_error_msg,
		p_resultout             =>  p_resultout);

        IF p_resultout <> 0
        THEN
	   return;
        END IF;

        IF pg_wf_debug = 'Y'
        THEN
           ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'after call:');
           ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                 'p_data_point_value = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value);
           ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                 'p_data_point_value_id = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_value_id);
        END IF;

	END LOOP; /* get parents loop */

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'ocm_add_data_points_pkg.getparentdatapoints()-');
    END IF;
END;

PROCEDURE GetAdditionalDataPoints (
	p_credit_request_id IN		NUMBER,
	p_case_folder_id    IN		NUMBER,
	p_mode		    IN		VARCHAR2 DEFAULT 'CREATE',
	p_error_msg	    OUT NOCOPY  VARCHAR2,
	p_resultout	    OUT	NOCOPY  VARCHAR2 ) IS

	CURSOR creditRequestC IS
		SELECT *
		FROM   ar_cmgt_credit_requests
		WHERE  credit_request_id = p_credit_request_id;

	l_exchange_rate_type 			ar_cmgt_setup_options.default_exchange_rate_type%type;

BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'ocm_add_data_points_pkg.getadditionaldatapoints()+');
    END IF;

	p_resultout := 0;

	FOR creditRequestRec IN creditRequestC
	LOOP
	pg_ocm_add_dp_param_rec.p_CASE_FOLDER_ID := p_case_folder_id;
        pg_ocm_add_dp_param_rec.p_CREDIT_REQUEST_ID := p_CREDIT_REQUEST_ID;
        pg_ocm_add_dp_param_rec.p_APPLICATION_NUMBER := creditRequestRec.APPLICATION_NUMBER;
        pg_ocm_add_dp_param_rec.p_TRX_CURRENCY := creditRequestRec.TRX_CURRENCY;
        pg_ocm_add_dp_param_rec.p_LIMIT_CURRENCY := creditRequestRec.LIMIT_CURRENCY;
        pg_ocm_add_dp_param_rec.p_PARTY_ID := creditRequestRec.PARTY_ID;
        pg_ocm_add_dp_param_rec.p_CUST_ACCOUNT_ID := creditRequestRec.CUST_ACCOUNT_ID;
        pg_ocm_add_dp_param_rec.p_SITE_USE_ID    := creditRequestRec.SITE_USE_ID;
        pg_ocm_add_dp_param_rec.p_REQUESTOR_ID := creditRequestRec.REQUESTOR_ID;
        pg_ocm_add_dp_param_rec.p_CREDIT_ANALYST_ID := creditRequestRec.CREDIT_ANALYST_ID;
        pg_ocm_add_dp_param_rec.p_CHECK_LIST_ID := creditRequestRec.CHECK_LIST_ID;
        pg_ocm_add_dp_param_rec.p_SCORE_MODEL_ID := creditRequestRec.SCORE_MODEL_ID;
        pg_ocm_add_dp_param_rec.p_REVIEW_TYPE  := creditRequestRec.REVIEW_TYPE;
        pg_ocm_add_dp_param_rec.p_CREDIT_CLASSIFICATION := creditRequestRec.CREDIT_CLASSIFICATION;
        pg_ocm_add_dp_param_rec.p_CREDIT_TYPE := creditRequestRec.CREDIT_TYPE;
        pg_ocm_add_dp_param_rec.p_SOURCE_NAME := creditRequestRec.SOURCE_NAME;
        pg_ocm_add_dp_param_rec.p_SOURCE_USER_ID := creditRequestRec.SOURCE_USER_ID;
        pg_ocm_add_dp_param_rec.p_SOURCE_RESP_ID  := creditRequestRec.SOURCE_RESP_ID;
        pg_ocm_add_dp_param_rec.p_SOURCE_RESP_APPLN_ID := creditRequestRec.SOURCE_RESP_APPLN_ID;
        pg_ocm_add_dp_param_rec.p_SOURCE_SECURITY_GROUP_ID := creditRequestRec.SOURCE_SECURITY_GROUP_ID;
        pg_ocm_add_dp_param_rec.p_SOURCE_ORG_ID := creditRequestRec.SOURCE_ORG_ID;
        pg_ocm_add_dp_param_rec.p_SOURCE_COLUMN1 := creditRequestRec.SOURCE_COLUMN1;
        pg_ocm_add_dp_param_rec.p_SOURCE_COLUMN2 := creditRequestRec.SOURCE_COLUMN2;
        pg_ocm_add_dp_param_rec.p_SOURCE_COLUMN3 := creditRequestRec.SOURCE_COLUMN3;
	END LOOP;

        IF pg_wf_debug = 'Y'
        THEN
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
                        'content of pg_ocm_add_dp_param_rec');
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_credit_request_id = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_credit_request_id);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_case_folder_id = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_case_folder_id);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_application_number = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_application_number);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_source_column1 = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column1);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_source_column2 = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column2);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_source_column3 = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_source_column3);
             ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,'p_data_point_application_id = ' ||
                 OCM_ADD_DATA_POINTS.pg_ocm_add_dp_param_rec.p_data_point_application_id);
        END IF;

	BEGIN
		SELECT default_exchange_rate_type
		INTO   l_exchange_rate_type
		FROM   ar_cmgt_setup_options;

		pg_ocm_add_dp_param_rec.p_exchange_rate_type := l_exchange_rate_type;

	EXCEPTION
		WHEN OTHERS THEN
			p_resultout	 := 1;
			p_error_msg	:= 'Error while getting Exchange Rate '|| sqlerrm;
	END;

	-- First check the mode. If the program runs on Refresh mode
	-- then first delete all the muliple records in case_folder details
	-- table. This logic is required because there is no way we will identify a
	-- unique record for updation.
	IF p_mode = 'REFRESH' OR p_mode = 'CREATE'
	THEN
		BEGIN
                  /* 7416921 - preserve non-function ADPs if
                      then are already visible from the checklist */
                        DELETE FROM ar_cmgt_cf_dtls cfd
			WHERE  cfd.case_folder_id = p_case_folder_id
			AND    cfd.data_point_id >= 20000
                        AND   (cfd.included_in_checklist = 'N' OR
                              (cfd.included_in_checklist = 'Y' AND
                               NOT EXISTS
                                 (SELECT 'populated NF/ADP'
                                  FROM   AR_CMGT_DATA_POINTS_B dp
                                  WHERE  dp.data_point_id = cfd.data_point_id
                                  AND    dp.function_name IS NULL)));
		EXCEPTION
		   WHEN OTHERS THEN
		      p_resultout := 1;
		      p_error_msg :=
       'SQL Error while deleting in OCM_ADD_DATA_POINTS '|| sqlerrm;
		END;
	END IF;

	IF p_resultout <> 0
	THEN
		return;
	END IF;

	GetParentDataPoints (
		p_mode		=>	p_mode,
		p_error_msg	=>	p_error_msg,
		p_resultout	=> 	p_resultout);

	IF p_resultout <> 0
	THEN
		return;
	END IF;

    IF pg_wf_debug = 'Y'
    THEN
       ar_cmgt_util.wf_debug(pg_ocm_add_dp_param_rec.p_case_folder_id,
              'ocm_add_data_points_pkg.getadditionaldatapoints()-');
    END IF;

    EXCEPTION
		WHEN OTHERS THEN
			p_resultout	 := 1;
			p_error_msg	:= 'SQL Error in OCM_ADD_DATA_POINTS '|| sqlerrm;

END;

END OCM_ADD_DATA_POINTS;

/
