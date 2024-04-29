--------------------------------------------------------
--  DDL for Package Body IPA_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IPA_APIS" AS
/* $Header: IPASRVB.pls 120.2.12010000.2 2010/02/23 19:17:19 djanaswa ship $ */

PROCEDURE summarize_dpis (
				errbug	IN OUT NOCOPY VARCHAR2 ,
				retcode	IN OUT NOCOPY varchar2 ) IS
     l_interface_asset_cost_code    pa_project_types.interface_asset_cost_code%TYPE ;
     l_xface_complete_asset_flag  	pa_project_types.interface_complete_asset_flag%TYPE;
     l_earliest_fa_dpis          	DATE ;
     l_project_id 			pa_projects.project_id%TYPE ;
     l_project_number			pa_projects.segment1%TYPE;
     l_project_name 			pa_projects.name%TYPE  ;
     l_project_type			pa_projects.project_type%TYPE  ;
     l_project_asset_id    		pa_project_assets.project_asset_id%TYPE ;
     l_asset_number			pa_project_assets.asset_number%TYPE;
     l_asset_name       		pa_project_assets.asset_name%TYPE;
     l_book_type_code   		pa_project_assets.book_type_code%TYPE;
     l_asset_units  	   		pa_project_assets.asset_units%TYPE;
     l_asset_category_id		pa_project_assets.asset_category_id%TYPE;
     l_asset_location_id      	pa_project_assets.location_id%TYPE;
     l_depreciate_flag  		pa_project_assets.depreciate_flag%TYPE;
     l_depreciation_expense_ccid 	pa_project_assets.depreciation_expense_ccid%TYPE;
     l_asset_flag				VARCHAR2(1) ;
     l_asset_info				VARCHAR2(1) ;
     l_count				NUMBER ;

     result 		number ;
     error_code  		number ;
     error_msg 		varchar2(500) ;
     x_error_msg		varchar2(500) ;
     incomplete_fail_flag varchar2(1) ;

     	CURSOR apis_intf IS
		SELECT * FROM ipa_apis_interface
		ORDER BY interface_id;

	CURSOR project_cur( grouping_method1   	VARCHAR2 ,
				  grouping_method2	VARCHAR2 ,
				  grouping_method3	VARCHAR2 )IS
	    	SELECT project_id ,
			project_asset_id  , asset_name , asset_number,
		 	book_type_code     , asset_units  ,
		 	asset_category_id  , location_id  ,
		 	depreciate_flag    , depreciation_expense_ccid
		FROM  pa_project_assets_all
                WHERE   (nvl(attribute8,'!@#')  = nvl(grouping_method1,nvl(attribute8,'!@#'))
                AND      nvl(attribute9,'!@#')  = nvl(grouping_method2,nvl(attribute9,'!@#'))
                AND      nvl(attribute10,'!@#') = nvl(grouping_method3,nvl(attribute10,'!@#')))
                AND    project_id = l_project_id
		AND   capitalized_flag <> 'Y' ;

      /* Bug#3018526 Split the project cursor into three cursors */
      /* The intention is that atleast one of the grouping menthod element (1,2, 3)
         has to be NOT NULL and use the query accordingly. The Function Based Indexes
	 (FBIs) are expected to be available, which are delivered in a Standalone.
	 See the Bug for more details
      */
	CURSOR project_cur1( grouping_method1   	VARCHAR2 ,
				  grouping_method2	VARCHAR2 ,
				  grouping_method3	VARCHAR2 )IS
	    	SELECT project_id ,
			project_asset_id  , asset_name , asset_number,
		 	book_type_code     , asset_units  ,
		 	asset_category_id  , location_id  ,
		 	depreciate_flag    , depreciation_expense_ccid
		FROM  pa_project_assets_all
                WHERE   (nvl(attribute8,'!@#')  = grouping_method1
                AND      nvl(attribute9,'!@#')  = nvl(grouping_method2,nvl(attribute9,'!@#'))
                AND      nvl(attribute10,'!@#') = nvl(grouping_method3,nvl(attribute10,'!@#')))
		AND   capitalized_flag <> 'Y' ;

	CURSOR project_cur2( grouping_method1   	VARCHAR2 ,
				  grouping_method2	VARCHAR2 ,
				  grouping_method3	VARCHAR2 )IS
	    	SELECT project_id ,
			project_asset_id  , asset_name , asset_number,
		 	book_type_code     , asset_units  ,
		 	asset_category_id  , location_id  ,
		 	depreciate_flag    , depreciation_expense_ccid
		FROM  pa_project_assets_all
                WHERE   (nvl(attribute8,'!@#')  = nvl(grouping_method1,nvl(attribute8,'!@#'))
                AND      nvl(attribute9,'!@#')  = grouping_method2
                AND      nvl(attribute10,'!@#') = nvl(grouping_method3,nvl(attribute10,'!@#')))
		AND   capitalized_flag <> 'Y' ;

	CURSOR project_cur3( grouping_method1   	VARCHAR2 ,
				  grouping_method2	VARCHAR2 ,
				  grouping_method3	VARCHAR2 )IS
	    	SELECT project_id ,
			project_asset_id  , asset_name , asset_number,
		 	book_type_code     , asset_units  ,
		 	asset_category_id  , location_id  ,
		 	depreciate_flag    , depreciation_expense_ccid
		FROM  pa_project_assets_all
                WHERE   (nvl(attribute8,'!@#')  = nvl(grouping_method1,nvl(attribute8,'!@#'))
                AND      nvl(attribute9,'!@#')  = nvl(grouping_method2,nvl(attribute9,'!@#'))
                AND      nvl(attribute10,'!@#') = grouping_method3)
		AND   capitalized_flag <> 'Y' ;

	CURSOR asset_cur ( i_project_id 		NUMBER) IS
		SELECT project_asset_id  , asset_name , asset_number ,
		 	book_type_code     , asset_units  ,
		 	asset_category_id  , location_id  ,
		 	depreciate_flag    , depreciation_expense_ccid
		FROM  pa_project_assets_all
	    	WHERE project_id        = i_project_id
		AND   capitalized_flag <> 'Y' ;
     apis_rec   		apis_intf%ROWTYPE  ;
     asset_rec		asset_cur%ROWTYPE ;
     project_rec		project_cur%ROWTYPE ;


begin

	-- Delete Old error records from error table
	DELETE FROM ipa_apis_interface_errors;
	COMMIT ;

	FOR apis_rec in apis_intf
	LOOP

	    x_error_msg := ' ' ;
	    error_msg   := 'Value missing for ' ;
	    error_code  := 0   ;
	    l_count     := 0 ;
	    l_asset_flag := '';
	    incomplete_fail_flag := ' ' ;
	    result := 1;


	    IF nvl(apis_rec.project_id,1)         = 1   AND
		 nvl(apis_rec.project_name,'X')     = 'X' AND
		 nvl(apis_rec.project_number,'X')   = 'X' AND
		 nvl(apis_rec.grouping_method1,'X') = 'X' AND
		 nvl(apis_rec.grouping_method2,'X') = 'X' AND
		 nvl(apis_rec.grouping_method3,'X') = 'X' AND
 		 nvl(apis_rec.project_asset_id,1)   = 1   AND
		 nvl(apis_rec.asset_number,'X')     = 'X' AND
		 nvl(apis_rec.asset_name,'X')       = 'X' THEN

		 	l_asset_info := 'E' ;

	    END IF;


	    	IF (	apis_rec.project_asset_id  is NOT NULL OR
			apis_rec.asset_number      is NOT NULL OR
			apis_rec.asset_name        is NOT NULL )THEN
			l_asset_info := 'A' ;

	    	ELSIF (	apis_rec.grouping_method1 is NOT NULL   OR
		 	apis_rec.grouping_method2 is NOT NULL   OR
		 	apis_rec.grouping_method3 is NOT NULL )  THEN
			l_asset_info := 'G' ;

	    	ELSIF   ( apis_rec.project_id  is  NOT NULL     OR
			apis_rec.project_name is NOT NULL     OR
			apis_rec.project_number is NOT NULL)    THEN
			l_asset_info := 'P' ;

	    	END IF;


	    IF l_asset_info = 'E' THEN
		x_error_msg := x_error_msg || 'Project , Asset , Grouping Method  ' ;
		error_code  := 1 ;
	    END IF;


	    IF  apis_rec.date_placed_in_service is NULL THEN

		x_error_msg := x_error_msg || ' Date placed in service' ;
		error_code  := 1 ;

	    END IF;


	    IF 	error_code = 1 THEN -- ( privious error )

		x_error_msg := x_error_msg || ' Values missing ' ;
		INSERT INTO ipa_apis_interface_errors
		(  INTERFACE_ID           ,
			   BATCH_NAME             ,
			   PROJECT_ID             ,
			   PROJECT_ASSET_ID       ,
			   ERROR_MESSAGE
		)
		VALUES
			( apis_rec.interface_id 	,
			  apis_rec.batch_name		,
			  apis_rec.project_id		,
			  apis_rec.project_asset_id	,
			  x_error_msg		) ;
	    ELSE

		IF l_interface_asset_cost_code = 'F' THEN

		   SELECT date_placed_in_service
		   INTO   l_earliest_fa_dpis
		   FROM	  fa_system_controls
		   WHERE  rownum < 2 ;

		END IF;

		IF apis_rec.date_placed_in_service < l_earliest_fa_dpis THEN

			INSERT INTO ipa_apis_interface_errors
			(  INTERFACE_ID           ,
			   BATCH_NAME             ,
			   PROJECT_ID             ,
			   PROJECT_ASSET_ID       ,
			   ERROR_MESSAGE
			)
			VALUES
			( apis_rec.interface_id 	,
			  apis_rec.batch_name		,
			  apis_rec.project_id		,
			  apis_rec.project_asset_id	,
			  'Date place in service is earlier than FA System Date Placed in service' );

		END IF;

		IF l_asset_info = 'A' THEN

		   BEGIN
	    		SELECT 	pp.project_id   , pp.name   ,
					pp.segment1     , pp.project_type,
					ppt.interface_asset_cost_code, ppt.interface_complete_asset_flag ,
					pa.project_asset_id  , pa.asset_name , pa.asset_number ,
		 			pa.book_type_code     , pa.asset_units  ,
		 			pa.asset_category_id  , pa.location_id  ,
		 			pa.depreciate_flag    , pa.depreciation_expense_ccid
	    		INTO   	l_project_id , l_project_name ,
					l_project_number, l_project_type,
					l_interface_asset_cost_code , l_xface_complete_asset_flag,
					l_project_asset_id   ,l_asset_name , l_asset_number ,
		 			l_book_type_code     ,l_asset_units  ,
		 			l_asset_category_id  ,l_asset_location_id  ,
		 			l_depreciate_flag    ,l_depreciation_expense_ccid
	    		FROM   	pa_project_assets_all pa,
					pa_projects_all  pp,
					pa_project_types ppt
	    		WHERE  (    pa.project_asset_id = apis_rec.project_asset_id
			OR		pa.asset_number 	  = apis_rec.asset_number
			OR		pa.asset_name 	  = apis_rec.asset_name )
			AND   	capitalized_flag <> 'Y'
			AND		pp.project_id   = pa.project_id
			AND 		pp.project_type = ppt.project_type
                        AND             PP.org_id = ppt.org_id  ; -- Fix for bug: 4960534
	         EXCEPTION
			WHEN no_data_found THEN
				INSERT INTO ipa_apis_interface_errors
				(  INTERFACE_ID           ,
				   PROJECT_ID             ,
				   PROJECT_ASSET_ID       ,
				   ERROR_MESSAGE
				)
				VALUES
				( apis_rec.interface_id ,
				  l_project_id		,
				  l_project_asset_id	,
				  'NO RECORDS FOUND' 	) ;
		   END ;

			Update_dpis(apis_rec.interface_id ,
					l_project_id ,
					l_project_asset_id	 ,
					apis_rec.date_placed_in_service ,
					l_xface_complete_asset_flag ,
					l_book_type_code   ,
					l_asset_units  ,
		   	 		l_asset_category_id,
					l_asset_location_id ,
		   	 		l_depreciate_flag  ,
					l_depreciation_expense_ccid,
					apis_rec.asset_status,
                                        apis_rec.asset_units); -- added bug 9339798

		ELSIF l_asset_info = 'P' THEN

		l_project_id := NULL;

		BEGIN
	    		SELECT 	pp.project_id   , pp.name   ,
					pp.segment1     , pp.project_type,
					ppt.interface_asset_cost_code, ppt.interface_complete_asset_flag
	    		INTO   	l_project_id , l_project_name ,
					l_project_number, l_project_type,
					l_interface_asset_cost_code , l_xface_complete_asset_flag
	    		FROM   	pa_projects_all  pp,
				pa_project_types ppt
	    		WHERE  	(pp.project_id  = apis_rec.project_id
	    		OR     	pp.name         = apis_rec.project_name
			OR 	      pp.segment1     = apis_rec.project_number)
			AND 		pp.project_type = ppt.project_type
                        AND             PP.org_id = ppt.org_id  ; -- Fix for bug: 4960534

		EXCEPTION

			WHEN no_data_found THEN
	  			INSERT INTO ipa_apis_interface_errors
				(  INTERFACE_ID           ,
				   ERROR_MESSAGE
				)
				VALUES
				( apis_rec.interface_id   ,
				  'NO RECORDS FOUND' 	) ;
		END ;

			FOR asset_rec IN asset_cur( l_project_id )
			LOOP

			-- Call update procedure

			Update_dpis(apis_rec.interface_id ,
					l_project_id ,
					asset_rec.project_asset_id	  ,
					apis_rec.date_placed_in_service ,
					l_xface_complete_asset_flag     ,
					asset_rec.book_type_code   	  ,
					asset_rec.asset_units           ,
		   	 		asset_rec.asset_category_id     ,
					asset_rec.location_id     ,
		   	 		asset_rec.depreciate_flag       ,
					asset_rec.depreciation_expense_ccid,
					apis_rec.asset_status,
                                        apis_rec.asset_units ); -- added bug 9339798

			END LOOP;

		ELSIF l_asset_info = 'G' THEN

		  BEGIN
			  SELECT 	pp.project_id   , pp.name   ,
					  pp.segment1     , pp.project_type,
					  ppt.interface_asset_cost_code, ppt.interface_complete_asset_flag
			  INTO   	l_project_id , l_project_name ,
					  l_project_number, l_project_type,
					  l_interface_asset_cost_code , l_xface_complete_asset_flag
			  FROM   	pa_projects_all  pp,
				  pa_project_types ppt
			  WHERE  	(pp.project_id  = apis_rec.project_id
			  OR     	pp.name         = apis_rec.project_name
			  OR 	      pp.segment1     = apis_rec.project_number)
			  AND 		pp.project_type = ppt.project_type
                          AND (apis_rec.project_id is not null OR
                               apis_rec.project_name is not null OR
                               apis_rec.project_number is not null)
                         AND             PP.org_id = ppt.org_id  ; -- Fix for bug: 4960534

		  EXCEPTION
			  WHEN no_data_found THEN
                              l_project_id := null;
		  END ;

/*   Bug# 3018526. Commented this as this is not required. While fetching from the cursor
     which makes use of the same statement, check if there are any records, thereby
     avoiding the query.

		  SELECT count(*)
                  INTO     l_count
                  FROM  pa_project_assets_all
                  WHERE   (
                       nvl(attribute8,'!@#')  = nvl(apis_rec.grouping_method1,nvl(attribute8,'!@#'))
                  AND       nvl(attribute9,'!@#')  = nvl(apis_rec.grouping_method2,nvl(attribute9,'!@#'))
                  AND       nvl(attribute10,'!@#') = nvl(apis_rec.grouping_method3,nvl(attribute10,'!@#'))
                         )
                 AND   capitalized_flag <> 'Y'
                 AND   project_id = nvl(l_project_id,project_id);
*/
			l_count := 0;

                        IF l_project_id is not null then
			FOR project_rec in project_cur (
						apis_rec.grouping_method1,
						apis_rec.grouping_method2,
						apis_rec.grouping_method3)
			LOOP

			-- Call update procedure.

                             l_count := l_count + 1;
				Update_dpis(apis_rec.interface_id 		  ,
						project_rec.project_id          ,
						project_rec.project_asset_id    ,
						apis_rec.date_placed_in_service ,
						l_xface_complete_asset_flag 	  ,
						project_rec.book_type_code      ,
						project_rec.asset_units         ,
		   	 			project_rec.asset_category_id   ,
						project_rec.location_id   	  ,
		   	 			project_rec.depreciate_flag     ,
						project_rec.depreciation_expense_ccid,
						apis_rec.asset_status,
                                                apis_rec.asset_units);  -- added bug 9339798

			END LOOP ;
			/* Bug# 3018526. Based on which grouping method is not null,
			   open that corresponding cursor */

                        elsif apis_rec.grouping_method1 is not null then
			FOR project_rec in project_cur1 (
						apis_rec.grouping_method1,
						apis_rec.grouping_method2,
						apis_rec.grouping_method3)
			LOOP

			-- Call update procedure.

                             l_count := l_count + 1;
				Update_dpis(apis_rec.interface_id 		  ,
						project_rec.project_id          ,
						project_rec.project_asset_id    ,
						apis_rec.date_placed_in_service ,
						l_xface_complete_asset_flag 	  ,
						project_rec.book_type_code      ,
						project_rec.asset_units         ,
		   	 			project_rec.asset_category_id   ,
						project_rec.location_id   	  ,
		   	 			project_rec.depreciate_flag     ,
						project_rec.depreciation_expense_ccid,
						apis_rec.asset_status,
                                                apis_rec.asset_units);  -- added bug 9339798

			END LOOP ;
                        elsif  apis_rec.grouping_method2 is not null then
			FOR project_rec in project_cur2 (
						apis_rec.grouping_method1,
						apis_rec.grouping_method2,
						apis_rec.grouping_method3)
			LOOP

			-- Call update procedure.

                             l_count := l_count + 1;
				Update_dpis(apis_rec.interface_id 		  ,
						project_rec.project_id          ,
						project_rec.project_asset_id    ,
						apis_rec.date_placed_in_service ,
						l_xface_complete_asset_flag 	  ,
						project_rec.book_type_code      ,
						project_rec.asset_units         ,
		   	 			project_rec.asset_category_id   ,
						project_rec.location_id   	  ,
		   	 			project_rec.depreciate_flag     ,
						project_rec.depreciation_expense_ccid,
						apis_rec.asset_status,
                                                apis_rec.asset_units);  -- added bug 9339798

			END LOOP ;
                        elsif apis_rec.grouping_method3 is not null then
			FOR project_rec in project_cur3 (
						apis_rec.grouping_method1,
						apis_rec.grouping_method2,
						apis_rec.grouping_method3)
			LOOP

			-- Call update procedure.

                             l_count := l_count + 1;
				Update_dpis(apis_rec.interface_id 		  ,
						project_rec.project_id          ,
						project_rec.project_asset_id    ,
						apis_rec.date_placed_in_service ,
						l_xface_complete_asset_flag 	  ,
						project_rec.book_type_code      ,
						project_rec.asset_units         ,
		   	 			project_rec.asset_category_id   ,
						project_rec.location_id   	  ,
		   	 			project_rec.depreciate_flag     ,
						project_rec.depreciation_expense_ccid,
						apis_rec.asset_status,
                                                apis_rec.asset_units);  -- added bug 9339798

			END LOOP ;
                        end if;

			IF l_count = 0 THEN
	  			INSERT INTO ipa_apis_interface_errors
				(  INTERFACE_ID           ,
				   ERROR_MESSAGE
				)
				VALUES
				( apis_rec.interface_id 	,
				  'NO RECORDS FOUND' 	) ;
			END IF;

		END IF;
	  END IF;
         COMMIT;
	END LOOP;
end summarize_dpis ;

-- This procedure finds expenditures related to given asset and updates
-- the Date placed in service.
 /** Commented for CRL Rel 11.5.1 as it is obsoleted
procedure Update_expenditure_item
		(i_project_id 	IN 	NUMBER )
IS

CURSOR asset_cur (  i_project_id 	      NUMBER   )
IS
    	SELECT project_asset_id , date_placed_in_service
	FROM  pa_project_assets_all
    	WHERE project_id        = i_project_id
        and date_placed_in_service is not null;

asset_rec				asset_cur%ROWTYPE ;
l_project_id     			number ;
l_project_asset_id 		number ;
l_date_placed_in_service    	date ;

BEGIN

	l_project_id := i_project_id ;

	-- Get date placed in service from Asset table

	FOR asset_rec IN asset_cur( l_project_id )
	LOOP

		UPDATE 	pa_expenditure_items_all
		SET    	date_placed_in_service = asset_rec.date_placed_in_service
		WHERE  	expenditure_item_id  in (
			SELECT 	det.expenditure_item_id
			FROM	pa_project_asset_lines_all line,
				pa_project_asset_line_details det
			WHERE  	line.project_asset_id = asset_rec.project_asset_id
			AND 	line.project_asset_line_detail_id = det.project_asset_line_detail_id ) ;
	END LOOP;

END update_expenditure_item ;
  ******/
PROCEDURE update_dpis ( i_interface_id 		IN   	NUMBER  ,
				i_project_id 	   		IN   	NUMBER  ,
				i_project_asset_id   		IN   	NUMBER  ,
				i_date_placed_in_service 	IN	DATE 	  ,
				i_xface_complete_asset_flag 	IN	VARCHAR2,
				i_book_type_code     		IN	VARCHAR2,
				i_asset_units        		IN	NUMBER, -- datatype changed bug 9339798
		   	 	i_asset_category_id  		IN	NUMBER,
				i_asset_location_id  		IN	NUMBER  ,
		   	 	i_depreciate_flag    		IN	VARCHAR2,
				i_depreciation_expense_ccid	IN	NUMBER,
				i_asset_status			IN	VARCHAR2,
                                i_xface_asset_units             IN      NUMBER  -- added bug 9339798
			     )
IS

	error_msg   			VARCHAR2(200);
	warning_msg   			VARCHAR2(200);
	l_incomplete_fail_flag 		VARCHAR2(2) ;
	result				NUMBER ;

       /* Bug#3018526. Added variables to get the who column values */
        l_request_id      NUMBER := nvl(fnd_global.conc_request_id(), -1);
        l_program_id      NUMBER := nvl(fnd_global.conc_program_id(), -1);
        l_update_login    NUMBER := nvl(FND_GLOBAL.login_id, -1);

       -- bug 9339798 start
        CURSOR est_asset_units_cur (  i_project_asset_id  NUMBER)
        IS
             SELECT estimated_asset_units
             FROM  pa_project_assets_all
             WHERE project_asset_id        = i_project_asset_id;

       l_est_asset_units              pa_project_assets.ESTIMATED_ASSET_UNITS%TYPE;
        -- bug 9339798 end


BEGIN
	error_msg := ' ';
	error_msg := 'Error in ' ;

    	IF i_xface_complete_asset_flag = 'Y' THEN

		   if i_asset_category_id is NULL THEN

			l_incomplete_fail_flag := 'Y' ;
			error_msg := error_msg || 'Asset category id, '  ;

		   end if;

		   if i_asset_units is NULL THEN

			l_incomplete_fail_flag := 'Y' ;
			error_msg := error_msg || 'Asset unit, '  ;

		   end if;

		   if i_asset_location_id is NULL THEN

			l_incomplete_fail_flag := 'Y' ;
			error_msg := error_msg || 'Asset Location id, '  ;

		   end if;

		   if i_depreciate_flag is NULL THEN

			l_incomplete_fail_flag := 'Y' ;
			error_msg := error_msg || 'Depreceate_flag, '  ;

		   end if;

		   if i_depreciation_expense_ccid is NULL THEN

			l_incomplete_fail_flag := 'Y' ;
			error_msg := error_msg || 'Depreciate Expense account '  ;

		   end if;

	END IF;

	IF nvl( l_incomplete_fail_flag,'N' ) <> 'Y' THEN

		   result := 0 ;
		   result := fa_mass_add_validate.valid_date_in_service
				( i_date_placed_in_service ,
				  i_book_type_code ) ;

		   if result < 0 then  -- warning invalid dpis

			INSERT INTO ipa_apis_interface_errors
			(  INTERFACE_ID           ,
			   PROJECT_ID             ,
			   PROJECT_ASSET_ID       ,
			   ERROR_MESSAGE
			)
			VALUES
			( i_interface_id 	,
			  i_project_id		,
			  i_project_asset_id	,
			  'ORA-'||to_char(result)	) ;

		   elsif result = 0 then
				warning_msg := '';
				fnd_message.set_name ('PA','PA_CP_WRN_INVALID_DPIS' );
				warning_msg := 'Error:'|| fnd_message.get;

			   INSERT INTO ipa_apis_interface_errors
			   (  INTERFACE_ID           ,
			      PROJECT_ID             ,
			      PROJECT_ASSET_ID       ,
			      DATE_PLACED_IN_SERVICE ,
			      ASSET_STATUS		  ,
			      ERROR_MESSAGE
			   )
			   VALUES
			   ( i_interface_id 		,
			     i_project_id		,
			     i_project_asset_id	,
			     i_date_placed_in_service,
			     i_asset_status       ,
			     warning_msg) ;

            elsif result = 1 then
 -- bug 9339798 start
                   IF (i_asset_units is NULL and i_xface_asset_units is NULL) THEN
                        OPEN  est_asset_units_cur (i_project_asset_id);
                        FETCH est_asset_units_cur INTO l_est_asset_units;
                        CLOSE est_asset_units_cur;
                   END IF;
 -- bug 9339798 end

			  UPDATE pa_project_assets_all
			  SET 	 date_placed_in_service = i_date_placed_in_service,
				   attribute6    = i_asset_status
                                 --Bug 3068204
                                 ,project_asset_type = 'AS-BUILT'
		                 ,asset_units = NVL(i_xface_asset_units,NVL(i_asset_units,l_est_asset_units)) -- added bug 9339798
                        	 /* Bug#3018526 Updating Who columns */
				 ,last_update_date   = SYSDATE
				 ,last_updated_by    = l_update_login
				 ,last_update_login  = l_update_login
				 ,request_id         = l_request_id
				 ,program_id         = l_program_id
				 ,program_update_date= SYSDATE
			  WHERE  project_id    = i_project_id
			  AND	 project_asset_id = i_project_asset_id ;


			  IF ( SQL%ROWCOUNT = 0 ) THEN
				  INSERT INTO ipa_apis_interface_errors
				  (  INTERFACE_ID           ,
				     PROJECT_ID             ,
				     PROJECT_ASSET_ID       ,
				     ERROR_MESSAGE
				  )
				  VALUES
				  ( i_interface_id ,
				    i_project_id		,
				    i_project_asset_id	,
				    'NO RECORDS FOUND' 	) ;
			  END IF;
          end if;

	ELSE

			INSERT INTO ipa_apis_interface_errors
			(  INTERFACE_ID           ,
			   PROJECT_ID             ,
			   PROJECT_ASSET_ID       ,
			   ERROR_MESSAGE
			)
			VALUES
			( i_interface_id 	,
			  i_project_id		,
			  i_project_asset_id	,
			  error_msg  		) ;

	END IF;

	update ipa_apis_interface
	set    record_status = 'PROCESSED'
	where  interface_id = i_interface_id ;

 /* 	COMMIT;   */

END update_dpis ;



END ipa_apis ;

/
