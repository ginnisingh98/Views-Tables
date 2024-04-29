--------------------------------------------------------
--  DDL for Package Body GMS_PA_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PA_API" AS
/* $Header: gmspax1b.pls 120.10 2007/02/06 09:51:09 rshaik ship $ */


-- Assing value "NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N') " to L_DEBUG
-- variable in all the procedures where debug messages are to be displayed
-- this value cannot be defaulted here as this package is having a procedure
-- OVERRIDE_RATE_REV_ID which has a pragma restriction of WNPS.

-- To check on, whether to print debug messages in log file or not
 L_DEBUG varchar2(1) ;

-- The following 2 global variables are for caching the org and gms_enabled status.
-- Bug 3002305.

 G_ORG_ID_CHECKED	NUMBER := NULL;
 G_GMS_ENABLED	VARCHAR2(1) := NULL;

	-- ------------------------------------------
	-- declare package variables
	-- ------------------------------------------
	G_trx_source		pa_transaction_sources.transaction_source%TYPE ;
	G_GL_accted_flag	varchar2(1) ;

        -- ----------------------------------------------------------------------------
        -- This function returns the error x_error set by the GMS_PA_API.VERT_TRANSFER
        -- ----------------------------------------------------------------------------

  G_EXPENDITURE_ITEM_ID PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE := NULL; /* 5490120 */
  G_AWARD_NUMBER GMS_AWARDS_ALL.AWARD_NUMBER%TYPE := NULL; /* 5490120 */

	FUNCTION return_error return VARCHAR2 IS
	begin
		return x_error ;
	end ;

	--=================================================================================
        -- Bug 3221039 : The following function is introduced to fetch valid award_id from
	--               Award Number if present else from award Id .
        --=================================================================================

	FUNCTION get_award_id (p_award_id NUMBER,
                               p_award_number VARCHAR2) return NUMBER is

          X_award_id  NUMBER ;

          CURSOR C_get_award_id IS
          SELECT ga.award_id
            FROM gms_awards_all ga
           WHERE ((p_award_number IS NULL AND ga.award_id = NVL(p_award_id,0)) OR
                  (ga.award_number = p_award_number) );
        BEGIN

         OPEN  C_get_award_id  ;
         FETCH C_get_award_id  into x_award_id ;
         IF C_get_award_id %NOTFOUND THEN
             x_award_id := 0 ;
         END IF ;
         CLOSE C_get_award_id  ;
         RETURN x_award_id ;

        EXCEPTION
        WHEN OTHERS THEN
          IF C_get_award_id%ISOPEN THEN
              close C_get_award_id ;
          END IF ;
    	  pa_cc_utils.log_message('GMS_PA_API.get_award_id : Unexpected error : '||SQLERRM,1);
          return 0;
        END get_award_id ;

	-- ========================================================================================================
	-- This procedure  will be called from PAXTRAPE (Expenditure Inquiry ) form when an expenditure_item is SPLIT.
	-- This will insert a reversed expendtiure_item record and two new expenditure_items records into ADL table.
	-- =========================================================================================================
	 PROCEDURE  GMS_SPLIT (x_expenditure_item_id IN NUMBER ) IS

	  adl_rec    gms_award_distributions%ROWTYPE;
	   x_flag    varchar2(1);
           x_billable_flag varchar2(1);   -- Bug 1756179
	 CURSOR rev_item(x_expenditure_item_id NUMBER ) IS
	 SELECT * from pa_expenditure_items_all
	 WHERE adjusted_expenditure_item_id = x_expenditure_item_id ;

	 CURSOR new_item(x_expenditure_item_id NUMBER ) IS
	 SELECT * from pa_expenditure_items_all
	 WHERE transferred_from_exp_item_id = x_expenditure_item_id ;

	 BEGIN

	    FOR rev_rec IN  rev_item(x_expenditure_item_id) LOOP

		  begin
		  select DISTINCT award_id   -- Fix for bug : 1786003
		--  , bill_hold_flag         -- Don't need to get bill_hold_flag
		  into source_award_id
		-- ,x_flag
		  from gms_award_distributions adl
		  where adl.expenditure_item_id = x_expenditure_item_id
		  and adl.document_type = 'EXP'
                  and adl_status = 'A' ;

		  exception
		  when too_many_rows then
		   Raise ;
		 end ;

       		adl_rec.expenditure_item_id	 := rev_rec.expenditure_item_id;
       		adl_rec.cost_distributed_flag	 := 'N';
       		adl_rec.project_id 		 := SOURCE_PROJECT_ID;
       		adl_rec.task_id   		 := rev_rec.task_id;
       		adl_rec.cdl_line_num              := NULL; -- Bug 1906331
       		adl_rec.adl_line_num              := 1;
       		adl_rec.distribution_value        := 100;
       		adl_rec.line_type                 :='R';
       		adl_rec.adl_status                := 'A';
       		adl_rec.document_type             := 'EXP';
       		adl_rec.billed_flag               := 'N';
       		adl_rec.bill_hold_flag            := x_flag ;
       		adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       		adl_rec.award_id                  := source_award_id ;
       		adl_rec.raw_cost			 := rev_rec.raw_cost;
       		adl_rec.last_update_date    	 := rev_rec.last_update_date;
       		adl_rec.creation_date      	 := rev_rec.creation_date;
       		adl_rec.last_updated_by        	 := rev_rec.last_updated_by;
       		adl_rec.created_by         	 := rev_rec.created_by;
       		adl_rec.last_update_login   	 := rev_rec.last_update_login;
       		 gms_awards_dist_pkg.create_adls(adl_rec);
                x_billable_flag                  := rev_rec.billable_flag;  -- Bug 1756179
   		END LOOP;

    		FOR new_rec IN  new_item (x_expenditure_item_id) LOOP
       		adl_rec.expenditure_item_id	 := new_rec.expenditure_item_id;
       		adl_rec.project_id 		 := SOURCE_PROJECT_ID;
       		adl_rec.task_id   		 := new_rec.task_id;
       		adl_rec.cost_distributed_flag	 := 'N';
       		adl_rec.cdl_line_num              := NULL; -- Bug 1906331
       		adl_rec.adl_line_num              := 1;
       		adl_rec.distribution_value        := 100 ;
       		adl_rec.line_type                 :='R';
       		adl_rec.adl_status                := 'A';
       		adl_rec.document_type             := 'EXP';
       		adl_rec.billed_flag               := 'N';
       		adl_rec.bill_hold_flag            := x_flag ;
       		adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       		adl_rec.award_id                  := source_award_id;
       		adl_rec.raw_cost			 := new_rec.raw_cost;
       		adl_rec.last_update_date    	 := new_rec.last_update_date;
       		adl_rec.creation_date      	 := new_rec.creation_date;
       		adl_rec.last_updated_by        	 := new_rec.last_updated_by;
       		adl_rec.created_by         	 := new_rec.created_by;
       		adl_rec.last_update_login   	 := new_rec.last_update_login;
       		 gms_awards_dist_pkg.create_adls(adl_rec);
-- Start, Bug 1756179
                update pa_expenditure_items_all
                set billable_flag = x_billable_flag
                where expenditure_item_id = new_rec.expenditure_item_id
		and exists (select 1 from pa_project_types t, pa_projects pa
                                where pa.project_id = SOURCE_PROJECT_ID
                                and pa.project_type=t.project_type
                                and t.Project_type_class_code= 'INDIRECT');
-- End, Bug 1756179
   		END LOOP;

    		EXCEPTION

   		when others then
 		 raise ;
	END GMS_SPLIT;

        -- ==============================================================================

	FUNCTION GMS_COMP_AWARDS(X_ADJUST_ACTION IN VARCHAR2 ) RETURN VARCHAR2 IS

	BEGIN

	-- Bug 2318298 : Removed Sponsored Project check as it is possible that
	--		 dest project id is sponsored , check only for source_award_id and dest_award_id.
	--		 also added NVL clause

 	If NVL(SOURCE_AWARD_ID,-1) = NVL(DEST_AWARD_ID,-2)  THEN
-- 	If IS_SPONSORED_PROJECT( source_project_id ) AND SOURCE_AWARD_ID = DEST_AWARD_ID  THEN
  	return 'Y';
 	end if;
  	RETURN 'N' ;
	END GMS_COMP_AWARDS;

	-- ==============================================================================================
	--  GMS_CHECK_EXP_TYPE() will return TRUE
	--  if the exp_type is allowed for the allowability_sechdule_id of the dest_award_id
	--  This function will be called from PAXTRPAE( Expenditure_Inquiry ) while trasnferring to check
	--   whether the expenditure_item is with in the award end_date.
	-- ===============================================================================================

  	FUNCTION GMS_CHECK_EXP_TYPE (x_expenditure_item_id IN NUMBER ) RETURN BOOLEAN IS

      		CURSOR exp_type IS
      		select expenditure_type
      		from gms_allowable_expenditures
      		where allowability_schedule_id = x_allowable_id
      		and expenditure_type = x_expenditure_type;

     		BEGIN


		 -- Bug 2318298 : If dest_award_id is NOT NULL then only perform this action
		 --		  Else return true.
		 --		  re-arranged the following If statement.

		 IF dest_award_id IS NOT NULL THEN
       		   OPEN exp_type ;
       		   FETCH exp_type INTO x_type ;
       		   IF exp_type%FOUND THEN
       		     CLOSE exp_type;
		     return TRUE ;
       		   END IF;
       		     CLOSE exp_type;
        	     return FALSE;
                 ELSE
       		   return TRUE;
                 END IF;

		EXCEPTION
		WHEN OTHERS THEN
		RAISE;
 	END GMS_CHECK_EXP_TYPE ;

	-- =======================================================================================================
	--    GMS_CHECK_AWARD_DATES
	--    will return TRUE if the expenditure_item_date is less than or equal to the End_date of the dest_award
	-- ========================================================================================================
   	FUNCTION GMS_CHECK_AWARD_DATES(x_expenditure_item_id IN NUMBER ,X_message_num IN OUT NOCOPY NUMBER ) RETURN BOOLEAN IS -- Bug 2458518

            -- ===================================================================
            -- Validationg the source_award_id for the status and closed_date.
            -- ===================================================================
            -- Fix start for bug : 2474576
      		CURSOR C_source_award(source_award_id IN NUMBER) IS
       		select status,allowable_schedule_id ,nvl(preaward_date, start_date_active) start_date_active ,
                       end_date_active,close_date
                from gms_awards_all
       		where award_id = source_award_id ;
           -- Fix start for bug : 2474576

      		CURSOR C_AWARDS(dest_award_id IN NUMBER) IS
       		select status,allowable_schedule_id ,nvl(preaward_date, start_date_active) start_date_active ,
                       end_date_active,close_date
                from gms_awards_all
       		where award_id = dest_award_id ;

      		CURSOR C_EXP(x_expenditure_item_id IN NUMBER ) IS
      		select expenditure_type,expenditure_item_date
      		from pa_expenditure_items_all
      		where expenditure_item_id = x_expenditure_item_id;

			x_start_date DATE; -- Bug 2458518
			x_close_date DATE; -- Bug 2458518
                        x_award_status VARCHAR2(30) ;

     		BEGIN


		 IF source_award_id IS NOT NULL THEN	-- Added for bug 2318298
                 -- Fix start for bug : 2474576
                 OPEN c_source_award(source_award_id )  ;
                 FETCH c_source_award INTO x_award_status ,x_allowable_id,x_start_date , x_end_date , x_close_date ;
                 CLOSE c_source_award ;

		          IF x_award_status NOT IN ('ACTIVE', 'AT_RISK' ) THEN
		             X_message_num := 5 ;
		             return FALSE;
                          ELSIF TRUNC (SYSDATE) > x_close_date THEN
                             X_message_num := 6 ;
           	             return FALSE;
			  END IF;
		 END IF;

                   x_award_status := NULL ;
                   x_allowable_id := NULL ;
                   x_start_date   := NULL ;
                   x_end_date     := NULL ;
                   x_close_date   := NULL ;
                 -- Fix start for bug : 2474576

                IF dest_award_id IS NOT NULL THEN	-- Added for bug 2318298

		 OPEN c_awards(dest_award_id )  ;
                 FETCH c_awards INTO x_award_status ,x_allowable_id,x_start_date , x_end_date , x_close_date ;
                 CLOSE c_awards ;


                 OPEN C_EXP (x_expenditure_item_id );
                 FETCH  c_exp INTO x_expenditure_type , x_item_date ;
                 CLOSE C_EXP ;


		 IF TRUNC(SYSDATE) > x_close_date THEN  -- Bug 2458518
		   X_message_num := 3 ;
           	   return FALSE;
    		 ELSIF x_item_date > x_end_date THEN
		   X_message_num := 2 ;
                   return FALSE;
    		 ELSIF x_item_date < x_start_date THEN -- Bug 2458518
		   X_message_num := 1 ;
                   return FALSE;
                 END IF;

		END IF;

        	return TRUE;

		EXCEPTION
		WHEN OTHERS THEN
		RAISE;
	   END GMS_CHECK_AWARD_DATES ;

	-- ==============================================================================

	PROCEDURE GMS_SET_AWARD (X_SOURCE_AWARD_ID    IN   NUMBER,
				     X_DEST_AWARD_ID      IN   NUMBER) IS

  	BEGIN

    	SOURCE_AWARD_ID := X_SOURCE_AWARD_ID;
    	DEST_AWARD_ID   := X_DEST_AWARD_ID;

	END GMS_SET_AWARD;

	-- ================================================================================
	PROCEDURE GMS_SET_PROJECT_ID (X_SOURCE_PROJECT_ID    IN   NUMBER,
		     X_DEST_PROJECT_ID      IN   NUMBER) IS

  	BEGIN

    	SOURCE_PROJECT_ID := X_SOURCE_PROJECT_ID;
    	DEST_PROJECT_ID   := X_DEST_PROJECT_ID;

	END GMS_SET_PROJECT_ID;

    -- ------------------------------------------------------------------------------------------------------
    -- The following function is used to exclude those  records  which don't belong to the source award_id.
    -- PA's query will be based on project_id and task_id. So it will get all the records that belong to P1,T1
    -- and different awards. This function will return TRUE if the record belong to the source_award_id otherwise
    -- if will return FALSE .
    -- -------------------------------------------------------------------------------------------------------
    	FUNCTION check_adjust_allowed(x_expenditure_item_id IN NUMBER ) return BOOLEAN IS

    	x_exp_item_id  NUMBER ;

    	CURSOR c1 is select ex.expenditure_item_id
    	from gms_award_distributions adl, pa_expenditure_items_all ex
    	where ex.expenditure_item_id = x_expenditure_item_id
    	and ex.expenditure_item_id = adl.expenditure_item_id
   	and ex.task_id = adl.task_id
  	and adl.award_id = source_award_id
    	and adl.document_type = 'EXP'
        and adl.adl_status = 'A'
	and adl.adl_line_num  = 1 ;
	--
	-- 3628872 NMV View Perf issue was fixed.
    	-- and adl.award_set_id in
        --      (select award_set_id
        --       from gms_award_distributions adl
	--       where award_id = source_award_id);
	--

    	BEGIN


	    -- Bug 2318298 : Check for source Award Id , if it is NOT NULL then
	    --		     only proceed else return TRUE.

	    IF source_award_id IS NOT NULL THEN
		OPEN c1 ;
		fetch c1 into x_exp_item_id ;
       		 IF c1%FOUND THEN
        	  CLOSE c1;
		  RETURN TRUE ;
       		 END IF;
       		 CLOSE c1;
		RETURN FALSE;
             ELSE
	        RETURN TRUE;
	     END IF;

		EXCEPTION
       		 WHEN NO_DATA_FOUND THEN
       		 RAISE ;
		WHEN OTHERS THEN
		RAISE;
    	END check_adjust_allowed ;

        --  ================================================================
        -- API for GMS to determine whether to allow adjustments or
        -- not. This is being called by PA_Adjustments pkg AND paxeiadj.pll
        -- ================================================================

        FUNCTION  vert_allow_adjustments ( x_expenditure_item_id IN  NUMBER ) return BOOLEAN IS
        BEGIN

	-- Bug 2318298 : In case of Transfer from non sponsored to sponsored Project we shouldn't return FALSE at this stage.
	--		 check for dest project Id.

                IF NOT IS_SPONSORED_PROJECT (SOURCE_PROJECT_ID )
		   AND (   DEST_PROJECT_ID IS NULL
			   OR
			 (
			   DEST_PROJECT_ID IS NOT NULL AND NOT IS_SPONSORED_PROJECT (DEST_PROJECT_ID )
		         )
                       )
		THEN
                        -- ========================================================
                        -- Since it is NOT a Sponsored project GMS will not interfere
                        -- and let PA continue its process. Fix for bug : 2236328
                        -- ========================================================
                    return FALSE  ;
                END IF ;

                        -- ========================================================
                        -- Fix for bug number : 1360895
                        -- Grants will process the records ONLY IF  the adjust_action
                        -- is 'PROJECT OR TASK CHANGE' i.e 'TRANSFER', otherwise PA will
                        -- continue its process. Fix for bug : 2236328
                        -- ========================================================
                If X_adj_action <> ('PROJECT OR TASK CHANGE') then
                    return FALSE  ;
                end if ;

                IF      CHECK_ADJUST_ALLOWED(x_expenditure_item_id)
                        AND GMS_CHECK_AWARD_DATES(x_expenditure_item_id,x_message_num) -- Bug 2458518
                        AND GMS_CHECK_EXP_TYPE(x_expenditure_item_id ) THEN

                        -- ========================================================
                        -- That means the expenditures are tranferable.
                        -- ========================================================

                        return FALSE  ;

                ELSE
                        -- =================================================================
                        -- That means the expenditures failed validation and NOT tranferable.
                        -- =================================================================
                                        return TRUE;
               END IF;

        END vert_allow_adjustments  ;




	-- -----------------------------------------------------------
        -- API for GMS to determine whether to allow Transfer or not
        -- -----------------------------------------------------------
	FUNCTION vert_transfer (x_exp_id	IN NUMBER ,
				 x_status 	IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN  IS
	  begin


		-- Bug 2318298 : If source or Destination Project is a sponsored project then proceed
		--		 verify this using source_award_id and dest_award_id

--		If    IS_SPONSORED_PROJECT (SOURCE_PROJECT_ID)
		If source_award_id IS NOT NULL OR dest_award_id IS NOT NULL then
/* Bug 5436420 - Removed call to GMS_COMP_AWARDS */
	            	If NOT  GMS_CHECK_AWARD_DATES(x_exp_id ,x_message_num) then
				  -- BUg 2458518
				  IF x_message_num = 1 THEN
			     	x_status := 'GMS_TR_EXP_DATE_AWARD_ST_DATE' ;
				    x_error := x_status ;
				  ELSIF x_message_num = 2 THEN
			     	x_status := 'GMS_TR_EXP_DATE_AWARD_DATE' ;
				    x_error := x_status ;
				  ELSIF x_message_num = 3 THEN
			     	x_status := 'GMS_TR_AWARD_IS_CLOSED' ;
				    x_error  := x_status ;
                  -- Fix start for bug : 2474576
				  ELSIF x_message_num = 5 THEN
			     	x_status := 'GMS_TR_SOURCE_AWD_NOT_ACTIVE' ;
				    x_error  := x_status ;
				  ELSIF x_message_num = 6 THEN
			     	x_status := 'GMS_TR_SOURCE_AWD_IS_CLOSED' ;
				    x_error  := x_status ;
                    -- Fix end  for bug : 2474576
	             END IF; -- end if for x_message_num = 1
   		      	    return FALSE ;

			  Elsif NOT GMS_CHECK_EXP_TYPE(x_exp_id) then
              			x_status := 'GMS_TR_DEST_EXP_TYPE_INVALID' ;
				x_error := x_status ;
        			return FALSE ;

		        ELSE
               		  	return TRUE ;
				x_error := x_status ;
       		     	end if ;   -- End if for second IF
       		 Else              -- Else for IS _SPONSORED_PROJECT
        		return FALSE ;
		End if;

         END vert_transfer ;


  FUNCTION IS_SPONSORED_PROJECT ( X_project_id  IN NUMBER ) return BOOLEAN IS

	x_dummy		varchar2(1) ;
	x_return	BOOLEAN ;

	CURSOR C_SPONSORED IS
	  select 'X'
		FROM pa_projects_all P,
			 gms_project_types gpt
	   WHERE p.project_id = X_project_id
		 AND p.project_type = gpt.project_type
		 and gpt.sponsored_flag	= 'Y' ;
  begin

	x_return := FALSE ;

	OPEN C_SPONSORED ;
	FETCH C_SPONSORED into x_dummy ;

	IF C_SPONSORED%FOUND THEN

		x_return := TRUE ;
	END IF ;

	CLOSE C_SPONSORED ;

	RETURN x_return  ;
  exception
        When others then
              Raise ;

  END IS_SPONSORED_PROJECT ;

	-- ======================================================================================================================
	-- This proceudre is called from PAXTRANB.pls while the expenditure_ites are transferred or MassAdjusted.
	-- For TRASFER x_rows will be 1 since expenditure_items are loaded into LaoadEi record by record and
	-- transferred one at a time. Where as while  MassAdjusting all the expenditures_items are loaded into LoadEi at one shot
	-- =======================================================================================================================
    PROCEDURE vert_ADJUST_ITEMS( X_CALLING_PROCESS 	IN   VARCHAR2 ,
                            	 X_ROWS                 IN   NUMBER,
				 X_status		IN OUT NOCOPY   NUMBER ) IS

  	adl_rec    gms_award_distributions%ROWTYPE;
  	x_exp_item_id  NUMBER;
  	x_new_item_id  NUMBER;
   	x_flag        varchar2(1) ;
 	CURSOR rev_item(x_exp_item_id NUMBER ) IS
 	SELECT * from pa_expenditure_items_all
 	WHERE adjusted_expenditure_item_id = x_exp_item_id ;

 	CURSOR new_item(x_exp_item_id NUMBER ) IS
 	SELECT * from pa_expenditure_items_all
	WHERE transferred_from_exp_item_id = x_exp_item_id ;


 	BEGIN
	IF X_STATUS is NOT NULL THEN

		-- Bug 2318298 : Modified the If statement, execute the code only
		--		 either the source or destination project is a sponsored project

 		IF X_CALLING_PROCESS  IN ( 'TRANSFER')
--		   AND IS_SPONSORED_PROJECT (SOURCE_PROJECT_ID ) THEN
		   AND (source_award_id IS NOT NULL OR dest_award_id IS NOT NULL)  THEN

  		FOR i IN 1..X_ROWS LOOP

   		x_exp_item_id := PA_TRANSACTIONS.TfrEiTab(i);

                -- Don't need to store bill_hold_flag in ADL table as Billing process will retrieve this
                -- value from pa_expenditure_items_all table.

    		/*begin
    		end ;*/

  	    -- Bug 2318298 : If source_award_id is NOT NULL then create ADL

	    IF source_award_id IS NOT NULL THEN
	       FOR rev_rec IN  rev_item(x_exp_item_id) LOOP
       		adl_rec.expenditure_item_id	 := rev_rec.expenditure_item_id;
       		adl_rec.cost_distributed_flag	 := 'N';
       		adl_rec.project_id 		 := SOURCE_PROJECT_ID;
       		adl_rec.task_id   		 := rev_rec.task_id;
       		adl_rec.cdl_line_num              := NULL;   -- Bug 1906331
       		adl_rec.adl_line_num              := 1;
       		adl_rec.distribution_value        := 100;
       		adl_rec.line_type                 :='R';
       		adl_rec.adl_status                := 'A';
       		adl_rec.document_type             := 'EXP';
       		adl_rec.billed_flag               := 'N';
       		adl_rec.bill_hold_flag            := x_flag ;
       		adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       		adl_rec.award_id                  := SOURCE_AWARD_ID;
       		adl_rec.raw_cost			 := rev_rec.raw_cost;
       		adl_rec.last_update_date    	 := rev_rec.last_update_date;
       		adl_rec.creation_date      	 := rev_rec.creation_date;
       		adl_rec.last_updated_by        	 := rev_rec.last_updated_by;
       		adl_rec.created_by         	 := rev_rec.created_by;
       		adl_rec.last_update_login   	 := rev_rec.last_update_login;
       		 gms_awards_dist_pkg.create_adls(adl_rec);
   	      END LOOP;
           END IF;


  	    -- Bug 2318298 : If dest_award_id is NOT NULL then create ADL

	    IF dest_award_id IS NOT NULL THEN

    	      FOR new_rec IN  new_item (x_exp_item_id) LOOP
       		adl_rec.expenditure_item_id	 := new_rec.expenditure_item_id;
       		adl_rec.project_id 		 := DEST_PROJECT_ID;
       		adl_rec.task_id   		 := new_rec.task_id;
       		adl_rec.cost_distributed_flag	 := 'N';
       		adl_rec.cdl_line_num              := NULL;   -- Bug 1906331
       		adl_rec.adl_line_num              := 1;
       		adl_rec.distribution_value        := 100;
       		adl_rec.line_type                 :='R';
       		adl_rec.adl_status                := 'A';
       		adl_rec.document_type             := 'EXP';
       		adl_rec.billed_flag               := 'N';
       		adl_rec.bill_hold_flag            := x_flag ;
       		adl_rec.award_set_id              := gms_awards_dist_pkg.get_award_set_id;
       		adl_rec.award_id                  := DEST_AWARD_ID;
       		adl_rec.raw_cost			 := new_rec.raw_cost;
       		adl_rec.last_update_date    	 := new_rec.last_update_date;
       		adl_rec.creation_date      	 := new_rec.creation_date;
       		adl_rec.last_updated_by        	 := new_rec.last_updated_by;
       		adl_rec.created_by         	 := new_rec.created_by;
       		adl_rec.last_update_login   	 := new_rec.last_update_login;
       		 gms_awards_dist_pkg.create_adls(adl_rec);
   		END LOOP;
            END IF;

  	END LOOP;

  	END IF;
        END IF ;
          -- These global variables are reset for every record by having the code hool before ON-UPDATE event in the pacage
	  -- paeia_transfer of PAXEIADJ.pll file

	  SOURCE_AWARD_ID := '';
	  DEST_AWARD_ID   := '';
	  SOURCE_PROJECT_ID := '';
	  DEST_PROJECT_ID   := '';

    	EXCEPTION

   	when others then
   	RAISE;


    END  vert_ADJUST_ITEMS ;

    -- ------------------------------------------------------
    -- API to allow vertical application to compare awards
    -- X_ADJUST_ACTION = 'MASADJUST'
    -- -------------------------------------------------------
   FUNCTION  VERT_ALLOW_ACTION(X_ADJUST_ACTION IN VARCHAR2) RETURN VARCHAR2 IS

    BEGIN
        --  ------------------------------------------------
        -- Vertical application will override the code here.
        -- -------------------------------------------------

        -- =====================================================================
        -- The control will come here only if the source and dest tasks ARE SAME.
        -- If they are DIFFERENT PA will NOT call this function.
        -- If the Source Project is not SPONSORED PROJECT GMS will not interfere.
        -- =====================================================================

	    -- Bug 2318298 : Added the check for dest_project_id , If source and destination
	    -- project both are non sponsored
	    -- don't use source_award_id and dest_award_id here as this procedure
	    -- is called in other adjustments also (apart from TRANSFER)

        If     NOT IS_SPONSORED_PROJECT(source_project_id )
	       AND NOT IS_SPONSORED_PROJECT(dest_project_id )
	    then
            return 'N' ;
        end if ;

        -- Fix for bug number : 1360895
        -- ======================================================================================
        -- If the adjust_action is NOT 'PROJECT OR TASK CHANGE', GMS will not process the records.
        -- ======================================================================================

        If X_adj_action <> ('PROJECT OR TASK CHANGE') then
          return 'Y';  -- Let PA Continue its Action
        end if ;

        -- ============================================================================
        -- If source and dest award ids are same , Grants will NOT transfer the records.
        -- ============================================================================

       If  source_award_id = dest_award_id then
         return 'N' ;
       End if ;

       return 'Y'; -- Let PA Continue its Action

    END VERT_ALLOW_ACTION ;

   -- ----------------------------------------------------------
   -- Supplier Invoice Interface logic of creating ADLS.
   -- LD PA Interface  logic of creating ADLS.
   -- trx_interface - Creates ADLS for the new expenditure items
   --               created for PA  Interface from payables/LD.
   --               This is called after PA_TRX_IMPORT.NEWexpend.
   -- -----------------------------------------------------------
  PROCEDURE  vert_trx_interface( X_user              IN NUMBER
                          , X_login             IN NUMBER
                          , X_module            IN VARCHAR2
                          , X_calling_process   IN VARCHAR2
                          , Rows                IN BINARY_INTEGER
                          , X_status            IN OUT NOCOPY NUMBER
                          , X_GL_FLAG           IN VARCHAR2 ) IS
    -- ---------------------
    -- Variable declaration.
    -- ---------------------
    temp_status                NUMBER DEFAULT NULL;
    x_request_id               NUMBER(15);
    x_program_application_id   NUMBER(15);
    x_program_id               NUMBER(15);
    x_invoice_id               NUMBER ;
    x_project_id               NUMBER ;
    X_CDL_NUM                  NUMBER ;
    x_task_id                  NUMBER ;
    X_raw_cost                 NUMBER ;
    X_dist_lno                 NUMBER ;
    x_award_set_id             NUMBER ;
    X_ei_id                    NUMBER ;
    x_exp_id                   NUMBER ;
    x_exp_item_date	       DATE   ;
    X_ind_cmpl_set_id          NUMBER ;
    X_org_id                   NUMBER ;
    X_burden_award_id	       NUMBER ;
    x_ind_compiled_set_id      NUMBER ;
    X_packet_id                NUMBER := 0;
    X_costed_flag              varchar2(1) ;
    x_revenued_flag            varchar2(1) ;
    x_bill_hold_flag           varchar2(1) ;
    X_trx_src                  varchar2(30) ;
    x_temp		       varchar2(30) ;
    x_billable_flag	       varchar2(1)  ;
    x_err_code		       NUMBER(7) DEFAULT 0 ;
    x_err_buff                 varchar2(2000) ;
    x_err_stage		       VARCHAR2(255) ;
    x_err_stack		       VARCHAR2(255) ;
    x_sob_id                   NUMBER ;
    x_exp_org_id	       NUMBER ;
    X_purgeable                VARCHAR2(1) ;

    x_adl_rec                 gms_award_distributions%ROWTYPE ;

-- New variables for performance :

   v_trx_src		varchar2(30) := 'DUMMY';
   v_gl_accounted	varchar2(1);

    -- ----------------------------
    -- CURSOR Declaration. AP-XFACE
    -- ----------------------------
/** AP Lines uptake: C_APREC is no longer needed because PROC_SI_INTERFACE is obsolete
    CURSOR C_APREC is
	-- -----------------------------------------------------------
	-- Bug 2143160. Joined ap_invoices_all to get vendor_id
	-- -----------------------------------------------------------
AP Lines uptake: C_APREC is no longer needed because PROC_SI_INTERFACE is obsolete **/
    -- -------------------------------
    -- CURSOR declaration. LD-XFACE.
    -- -------------------------------
    -- bug : 3684711 UNABLE TO ENTER A REVERSAL BATCH GMS_AWARD_REQD
    CURSOR C_GOLD IS
        SELECT gt.award_id                  award_id,
	       gt.award_number              award_number, -- Bug 3221039
               NULL                         invoice_distribution_id,
               ei.cost_distributed_flag     cost_distributed_flag,
               ei.revenue_distributed_flag  revenue_distributed_flag,
               pt.txn_interface_id          TXN_INTERFACE_ID,
	       pt.accrual_flag              period_end_accrual_flag,
	       pt.system_linkage            system_linkage
          FROM gms_transaction_interface_all gt,
               pa_transaction_interface_all  pt,
               pa_expenditure_items_all      ei
         WHERE ei.expenditure_item_id     = x_ei_id
           AND ei.expenditure_id          = x_exp_id
           AND ei.transaction_source      = x_trx_src
           and ei.transaction_source      = pt.transaction_source
           and ei.orig_transaction_reference = pt.orig_transaction_reference
           and ei.expenditure_id          = pt.expenditure_id
           and ei.expenditure_item_id     = pt.expenditure_item_id
           and pt.txn_interface_id        = gt.txn_interface_id;
    -- -----------------------------
    -- EXISTING ADL RECORD.
    -- -----------------------------
    CURSOR C_adlrec is
        SELECT * from  gms_award_distributions
         where award_set_id  =  x_award_set_id
           and adl_status    = 'A' ;
    -- ----------------------------------
    -- GET max CDL line NUM.
    -- ----------------------------------
    CURSOR C_CDL_NUM is
      SELECT cdl.line_num
       FROM pa_cost_distribution_lines cdl
      WHERE cdl.expenditure_item_id = X_ei_id
	and line_num_reversed is null
	and reversed_flag is NULL ;

    CURSOR C_TXN_SOURCE IS
        SELECT nvl(purgeable_flag, 'N'), nvl(gl_accounted_flag, 'N')
          FROM pa_transaction_sources
         WHERE transaction_source = x_trx_src ;

    -- ---------------------------------------
    -- PROCEDURE PROC_BURDEN_INTERFACE
    -- Local procedure to create ADLS for BURDEN
    -- Interface. This guy looks for award
    -- details from attribute1.
    -- ---------------------------------------
    PROCEDURE PROC_BURDEN_INTERFACE(P_award_id number) IS
        X_TXN_XFACE_ID     NUMBER ;
        X_award_id         NUMBER ;
	invalid_award	   EXCEPTION ;  -- Bug 2368907
    BEGIN
	IF nvl(p_award_id,0) = 0 THEN
	   RAISE invalid_award ;  -- Bug 2368907, Added
	   -- return ;		  -- Bug 2368907, Commented
	END IF ;

        x_award_set_id 			    := gms_awards_dist_pkg.get_award_set_id ;
        X_award_id                          := P_AWARD_ID ;
        x_adl_rec.award_set_id              := x_award_set_id ;
        X_adl_rec.adl_line_num              := 1 ;
        X_adl_rec.project_id                := X_project_id ;
	X_adl_rec.document_type		    := 'EXP' ;
        X_adl_rec.task_id                   := X_task_id ;
        X_adl_rec.award_id                  := X_award_id ;
        x_adl_rec.expenditure_item_id       := x_ei_id ;
        x_adl_rec.raw_cost                  := X_raw_cost ;
        x_adl_rec.request_id                := X_request_id ;
        x_adl_rec.CDL_line_num              := nvl(x_cdl_num,1) ;  -- Bug 2368907, Added nvl fn to default 1 for BTC lines
	x_adl_rec.billable_flag		    := x_billable_flag ;
        x_adl_rec.billed_flag               := 'N' ;
        X_adl_rec.Ind_compiled_set_id       := X_ind_cmpl_set_id ;
        X_adl_rec.bill_hold_flag            := X_bill_hold_flag ;
        X_adl_rec.cost_distributed_flag     := x_costed_flag ;
        X_adl_rec.revenue_distributed_flag  := X_revenued_flag ;
        x_adl_rec.invoice_id                := NULL ;
        x_adl_rec.invoice_distribution_id   := NULL ;
        x_adl_rec.distribution_line_number  := NULL ;
        X_adl_rec.adl_status                := 'A' ;
	X_adl_rec.line_type		    := 'B' ;

/* Commenting out NOCOPY the code below as it is not relevant here... bug 2596697
*/ -- Commented out NOCOPY the code above as it is irrelevant. Bug 2596697

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS: Before call to gms_awards_dist_pkg.create_adl', 'C');
	END IF;
        gms_awards_dist_pkg.create_adls(x_adl_rec) ;

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS: After call to gms_awards_dist_pkg.create_adl', 'C');
	END IF;

    EXCEPTION
	WHEN invalid_award THEN	  -- Bug 2368907, Added
	    IF L_DEBUG = 'Y' THEN
	    	gms_error_pkg.gms_debug('GMS:PROC_BURDEN_INTERFACE did not process. Parameter p_award_id was NULL or 0', 'C');
	    END IF;
        WHEN OTHERS THEN
            RAISE ;
    END PROC_BURDEN_INTERFACE ;
    -- =========== END OF PROC_BURDEN_INTERFACE ==============

    -- ---------------------------------------
    -- PROCEDURE PROC_LDPA_INTERFACE
    -- Local procedure to create ADLS for LD
    -- Interface. This guy looks for award
    -- details from GMS_interface.
    -- ---------------------------------------
    PROCEDURE PROC_LDPA_INTERFACE IS
        X_TXN_XFACE_ID     NUMBER ;
        X_award_id         NUMBER ;
    BEGIN
            FOR LD_REC IN C_GOLD LOOP
                x_award_set_id := gms_awards_dist_pkg.get_award_set_id ;
                x_txn_xface_id                      := LD_REC.TXN_INTERFACE_ID ;
                X_award_id                          := get_award_id( LD_REC.AWARD_ID, LD_REC.AWARD_NUMBER);
		--LD_REC.AWARD_ID ; -- Bug 3221039
                x_adl_rec.award_set_id              := x_award_set_id ;
                X_adl_rec.adl_line_num              := 1 ;
                X_adl_rec.project_id                := X_project_id ;
		X_adl_rec.document_type		    := 'EXP' ;
                X_adl_rec.task_id                   := X_task_id ;
                X_adl_rec.award_id                  := X_award_id ;
                x_adl_rec.expenditure_item_id       := x_ei_id ;
                x_adl_rec.raw_cost                  := X_raw_cost ;
                x_adl_rec.request_id                := X_request_id ;
                x_adl_rec.CDL_line_num              := x_cdl_num ;
		x_adl_rec.billable_flag		    := x_billable_flag ;
                x_adl_rec.billed_flag               := 'N' ;
                X_adl_rec.Ind_compiled_set_id       := X_ind_cmpl_set_id ;
                X_adl_rec.Ind_compiled_set_id       := X_ind_cmpl_set_id ;
                X_adl_rec.bill_hold_flag            := X_bill_hold_flag ;
                X_adl_rec.cost_distributed_flag     := x_costed_flag ;
                X_adl_rec.revenue_distributed_flag  := X_revenued_flag ;
                x_adl_rec.invoice_id                := NULL ;
                x_adl_rec.invoice_distribution_id   := NULL ;
                x_adl_rec.distribution_line_number  := NULL ;
                X_adl_rec.adl_status                := 'A' ;
		X_adl_rec.line_type		    := 'R' ;

		/* Commenting the whole code below as it is not relevant for txns coming from LD distributions
	         **/ -- Commented all the above code as it is irrelevant bug 2596697

                gms_awards_dist_pkg.create_adls(x_adl_rec) ;

                -- bug : 3684711 UNABLE TO ENTER A REVERSAL BATCH GMS_AWARD_REQD
		-- Create award distribution line for the reversal item.
		IF ld_rec.period_end_accrual_flag = 'Y' and
		   ld_rec.system_linkage          = 'PJ' then

		   select ei.expenditure_item_id
		     into x_adl_rec.expenditure_item_id
		     from pa_expenditure_items_all ei
		    where ei.adjusted_expenditure_item_id = x_ei_id ;
														                             IF SQL%FOUND THEN
		      x_adl_rec.raw_cost     := X_raw_cost * -1 ;
	              x_award_set_id         := gms_awards_dist_pkg.get_award_set_id ;
		      x_adl_rec.award_set_id := x_award_set_id ;
		      gms_awards_dist_pkg.create_adls(x_adl_rec) ;
		   END IF ;

		END IF ;
                -- end of bug : 3684711 Fix.

                IF NVL(x_purgeable,'N')  = 'Y' THEN
                    DELETE from gms_transaction_interface_all
                     WHERE txn_interface_id = x_txn_xface_id ;
                END IF ;


            END LOOP ;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE ;
    END PROC_LDPA_INTERFACE ;
    -- =========== END OF PROC_LDPA_INTERFACE ==============
    -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++

    -- -------------------------------------------------------
    -- PROCEDURE PROC_SI_INTERFACE
    -- This guy copy the adls for each invoice distribution
    -- lines generated into expenditure items and establish a
    -- link with expenditure item.
    -- -------------------------------------------------------
    -- Start of comments
    --	API name 	: PROC_SI_INTERFACE
    --  Bug             : 2569522
    --                    ENHANCE GRANTS ACCOUNTING TO WORK WITH PA I PAYABLES
    --                    DISCOUNTS FEATURE
    --	Type		: Private
    --	Pre-reqs	: None.
    --	Function	: Interface Supplier Invoices, discounts and
    --                    pre-payments to grants accounting.
    --  Logic           : Discounts and Pre Payments.
    --                    Interfaced to GA with cost distributed flag N
    --                    and line type F for CDLs.
    --                    Invoice Items not FC
    --                      Interfaced to GA with cost distributed flag N
    --                      and line type F for CDLs.
    --                      Invoice Items not FC
    -- End of comments

 /** AP Lines uptake: Obsoleted PROC_SI_INTERFACE
    PROCEDURE PROC_SI_INTERFACE IS
    END PROC_SI_INTERFACE ;
    -- ========= END OF PROC_SI_INTERFACE ===================
 AP Lines uptake: Obsoleted PROC_SI_INTERFACE **/

  BEGIN

    L_DEBUG := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

    IF L_DEBUG = 'Y' THEN
	gms_error_pkg.gms_debug('GMS: Vert_trx_interface  START TIME :'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 'C');
	gms_error_pkg.gms_debug('GMS: Number of Rows to process: '||Rows, 'C');
    END IF;

    IF x_status < 0 THEN
	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS: Input Parameter x_status: '||x_status, 'C');
	   gms_error_pkg.gms_debug('GMS: Vert_trx_interface  END TIME <==', 'C');
	END IF;
       return ;
    END IF ;

    X_request_id := FND_GLOBAL.CONC_REQUEST_ID ;
    X_program_id := FND_GLOBAL.CONC_PROGRAM_ID  ;
    X_program_application_id := FND_GLOBAL.PROG_APPL_ID ;

    SELECT  set_of_books_id
      INTO  x_sob_id
      FROM  PA_IMPLEMENTATIONS ;

-- Check whether gms is enabled, if gms is not enabled return
-- Remove references to this call inside the loops.

--   if not gms_install.enabled then -- Bug 3002305
   if not vert_install then
      return;
    end if;

   /* check the transaction source. If it is any of Supplier Costs related do not
      process. They'll be processed in gms_pa_costing_pkg now. Bug : 2750896     */

     if Rows > 0 then
        if PA_TRANSACTIONS.EiTrxSrcTab(1) in ('AP INVOICE', 'AP DISCOUNTS',
                                              'AP NRTAX', 'AP EXPENSE', 'AP ERV') then /* Bug 5284323 */
           return;
        end if;
     end if;

    -- --------------------------------------------------
    -- Read from LOAD EI pa array of  expenditure items.
    -- --------------------------------------------------
    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('GMS: Start of Loop on LoadEI pa array', 'C');
    END IF;
    FOR  i  IN 1..Rows  LOOP

        -- --------------------------
        -- LOAD VARIABLES.
        -- --------------------------
        x_invoice_id      :=  to_number(PA_TRANSACTIONS.Cdlsr2Tab(i)) ;
        X_dist_lno        :=  to_number(PA_TRANSACTIONS.Cdlsr3Tab(i));
        X_raw_cost        :=  PA_TRANSACTIONS.RawCostTab(i);
        X_ei_id           :=  PA_TRANSACTIONS.EiIdTab(i);
        X_exp_id          :=  PA_TRANSACTIONS.EIdTab(i) ;
        X_bill_hold_flag  :=  PA_TRANSACTIONS.BillHoldTab(i) ;
        X_project_id      :=  PA_TRANSACTIONS.ProjIdTab(i);
        X_task_id         :=  PA_TRANSACTIONS.TskidTab(i);
        X_raw_cost        :=  PA_TRANSACTIONS.RawCostTab(i);
        x_trx_src         :=  PA_TRANSACTIONS.EiTrxSrcTab(i) ;
	x_exp_item_date   :=  PA_TRANSACTIONS.EiDateTab(i) ;
	--x_burden_award_id :=  to_number(PA_TRANSACTIONS.Att1Tab(i)) ;  -- Bug 2775237, Moved it below
        X_ind_cmpl_set_id :=  PA_TRANSACTIONS.TpIndCompiledSetIdTab(i) ;
        X_Billable_flag   :=  PA_TRANSACTIONS.BillFlagTab(i);  -- Added, Bug 1756179
	x_exp_org_id      :=  NULL ;

	BEGIN
	    select ei.cost_distributed_flag, NVL( ei.override_to_organization_id, exp.incurred_by_organization_id )
	      into X_costed_flag, x_exp_org_id
	      from pa_expenditure_items_all ei,
                   pa_expenditures_all exp
	     where ei.expenditure_item_id = X_ei_id
               and ei.expenditure_id      = exp.expenditure_id ;
	EXCEPTION
		when no_data_found then
			X_costed_flag := 'N' ;
			x_exp_org_id  := NULL ;
		when others then
			X_costed_flag := 'N' ;
			x_exp_org_id  := NULL ;
	END ;

	IF nvl(X_project_id, 0) = 0 and NVL(X_task_id,0) <> 0 THEN
	BEGIN
		SELECT project_id
		  into X_project_id
		  from pa_tasks
		 where task_id = X_task_id
		   and rownum < 2 ;
	EXCEPTION
	  when no_data_found then
		NULL ;
	  when too_many_rows then
		NULL ;
	  when others then
		NULL ;
	END ;
	END IF ;

	-- ----------------------------------------
	-- Get the CDL line NUM only if they exist
	-- ----------------------------------------
	if v_trx_src <> x_trx_src then

	   open c_txn_source;
	   fetch c_txn_source into x_purgeable, v_gl_accounted;
	   close c_txn_source;

	   v_trx_src := x_trx_src;

	end if;

	if v_gl_accounted = 'Y' then
           open c_cdl_num ;
           fetch c_cdl_num into x_cdl_num ;
           close c_cdl_num ;
	end if;

	IF x_cdl_num = 0 THEN
	   x_cdl_num := NULL ;
	END IF ;

        -- ---------------------------------
        -- LD PA GRANTS INTERFACE.
	-- External system Interface.
        -- ---------------------------------
	x_temp := SUBSTR(X_TRX_SRC, 1,4) ;

        IF X_TRX_SRC = 'GOLD' OR x_temp in ( 'GOLD', 'GMSA' )  THEN

            PROC_LDPA_INTERFACE ;

        -- ======= END OF 'GOLD' INTERFACE. ========
	    ELSIF  X_module = 'PAXCBCAB' and X_calling_process = 'PA_BURDEN_COSTING' THEN
	        IF L_DEBUG = 'Y' THEN
	        	gms_error_pkg.gms_debug('GMS: Processing X_module = PAXCBCAB, X_calling_process = PA_BURDEN_COSTING', 'C');
	        	gms_error_pkg.gms_debug('GMS: Before PROC_BURDEN_INTERFACE', 'C');
	        END IF;
            x_burden_award_id :=  to_number(PA_TRANSACTIONS.Att1Tab(i)) ;  -- Bug 2775237
            PROC_BURDEN_INTERFACE( x_burden_award_id)  ;
	        IF L_DEBUG = 'Y' THEN
	        	gms_error_pkg.gms_debug('GMS: After PROC_BURDEN_INTERFACE', 'C');
	        END IF;

        END IF ;

        IF nvl( x_invoice_id, 0) = 0 THEN
            GOTO NEXTRECORD ;
        END IF ;

        -- ---------------------------
        -- SUPPLIER INVOICE INTERFACE
        -- ---------------------------

	-- --------------------------------------------------
	-- We know that in case of supplier invoice
	-- AcctRawCost stores the value for the raw cost.
	-- --------------------------------------------------
        X_raw_cost        :=  PA_TRANSACTIONS.AcctRawCost(i);

        /** AP Lines uptake: Obsoleted PROC_SI_INTERFACE
        AP Lines uptake: Obsoleted PROC_SI_INTERFACE **/

        <<NEXTRECORD>>
        NULL ;
    END LOOP ;          -- END OF EXP LOOP.

    IF L_DEBUG = 'Y' THEN
    	gms_error_pkg.gms_debug('GMS: End of Loop on LoadEI pa array', 'C');
    	gms_error_pkg.gms_debug('GMS: x_packet_id: '||x_packet_id, 'C');
    END IF;


    IF NVL(x_packet_id,0) = 0 THEN
        RETURN ;
    END IF ;

    -- ========================================================================================
    -- Bug : 1698738 - IDC RATE CHANGES CAUSE DISCREPENCIES IN S.I. INTERFACE TO PROJECTS.
    -- get_award_cmt_compiled_set_id was replaced by award_cmt_compiled_set_id
    -- ========================================================================================

    -- ---------------------------------------------------------------
    -- Bug 2143160 Insert vendor_id into gms_bc_packets for AP and EXP
    -- ---------------------------------------------------------------

    Insert into gms_bc_packets
 		( PACKET_ID,
   		PROJECT_ID,
   		AWARD_ID,
   		TASK_ID,
   		EXPENDITURE_TYPE,
   		EXPENDITURE_ITEM_DATE,
   		ACTUAL_FLAG,
   		STATUS_CODE,
   		LAST_UPDATE_DATE,
   		LAST_UPDATED_BY,
   		CREATED_BY,
   		CREATION_DATE,
   		LAST_UPDATE_LOGIN,
   		SET_OF_BOOKS_ID,
   		JE_CATEGORY_NAME,
   		JE_SOURCE_NAME,
   		TRANSFERED_FLAG,
   		DOCUMENT_TYPE,
   		EXPENDITURE_ORGANIZATION_ID,
   		PERIOD_NAME,
   		PERIOD_YEAR,
   		PERIOD_NUM,
   		DOCUMENT_HEADER_ID ,
   		DOCUMENT_DISTRIBUTION_ID,
   		TOP_TASK_ID,
   		BUDGET_VERSION_ID,
		BUD_TASK_ID,          -- Bug 3338999
   		RESOURCE_LIST_MEMBER_ID,
   		ACCOUNT_TYPE,
   		ENTERED_DR,
   		ENTERED_CR ,
   		TOLERANCE_AMOUNT,
   		TOLERANCE_PERCENTAGE,
   		OVERRIDE_AMOUNT,
   		EFFECT_ON_FUNDS_CODE ,
   		RESULT_CODE,
   		GL_BC_PACKETS_ROWID,
   		BC_PACKET_ID,
   		PARENT_BC_PACKET_ID,
		VENDOR_ID)
 		select
 			gbc.PACKET_ID,
 			gbc.PROJECT_ID,
 			gbc.AWARD_ID,
 			gbc.TASK_ID,
 			icc.EXPENDITURE_TYPE,
 			trunc(gbc.EXPENDITURE_ITEM_DATE),
 			gbc.ACTUAL_FLAG,
 			gbc.STATUS_CODE,
 			gbc.LAST_UPDATE_DATE,
 			gbc.LAST_UPDATED_BY,
 			gbc.CREATED_BY,
 			gbc.CREATION_DATE,
 			gbc.LAST_UPDATE_LOGIN,
 			gbc.SET_OF_BOOKS_ID,
 			gbc.JE_CATEGORY_NAME,
 			gbc.JE_SOURCE_NAME,
 			gbc.TRANSFERED_FLAG,
 			gbc.DOCUMENT_TYPE,
 			gbc.EXPENDITURE_ORGANIZATION_ID,
 			gbc.PERIOD_NAME,
 			gbc.PERIOD_YEAR,
 			gbc.PERIOD_NUM,
 			gbc.DOCUMENT_HEADER_ID ,
 			gbc.DOCUMENT_DISTRIBUTION_ID,
 			gbc.TOP_TASK_ID,
 			gbc.BUDGET_VERSION_ID,
			gbc.BUD_TASK_ID,	-- Bug 3338999
 			NULL, -- gbc.RESOURCE_LIST_MEMBER_ID
 			gbc.ACCOUNT_TYPE,
			-- Bug 1980810 PA Rounding function added
			pa_currency.round_currency_amt(sign(nvl(entered_dr,0)) * abs(nvl(gbc.BURDENABLE_RAW_COST ,0) * nvl(cm.compiled_multiplier,0))),
			pa_currency.round_currency_amt(sign(nvl(entered_cr,0)) * abs(nvl(gbc.BURDENABLE_RAW_COST ,0) * nvl(cm.compiled_multiplier,0))),
 			gbc.TOLERANCE_AMOUNT,
 			gbc.TOLERANCE_PERCENTAGE,
 			gbc.OVERRIDE_AMOUNT,
 			gbc.EFFECT_ON_FUNDS_CODE ,
 			gbc.RESULT_CODE,
 			gbc.gl_bc_packets_rowid,
 			gms_bc_packets_s.nextval,
 			gbc.BC_PACKET_ID,
			gbc.vendor_id
 		from	pa_ind_rate_sch_revisions irsr,
        		pa_cost_bases cb,
        		pa_expenditure_types et,
        		pa_ind_cost_codes icc,
        		pa_cost_base_exp_types cbet,
        		pa_ind_rate_schedules_all_bg irs,
        		pa_ind_compiled_sets ics,
        		pa_compiled_multipliers cm,
        		gms_bc_packets gbc
  		where 	irsr.cost_plus_structure     = cbet.cost_plus_structure
    		and 	cb.cost_base                 = cbet.cost_base
    		and 	cb.cost_base_type            = cbet.cost_base_type
                and     ics.cost_base                = cbet.cost_base --Bug 3003584
    		and 	et.expenditure_type          = icc.expenditure_type
    		and 	icc.ind_cost_code            = cm.ind_cost_code
    		and 	cbet.cost_base               = cm.cost_base
    		and 	cbet.cost_base_type          = 'INDIRECT COST'
    		and 	cbet.expenditure_type        = gbc.expenditure_type
    		and 	irs.ind_rate_sch_id          = irsr.ind_rate_sch_id
    		and 	ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
    		and 	ics.organization_id          = gbc.expenditure_organization_id
    		and ics.ind_compiled_set_id          = gms_cost_plus_extn.AWARD_CMT_COMPILED_SET_ID(	gbc.DOCUMENT_HEADER_ID ,
										gbc.DOCUMENT_DISTRIBUTION_ID,
										gbc.task_id,
							        		gbc.document_type,
							       			gbc.expenditure_item_date,
                                                                       gbc.expenditure_type, -- Bug 3003584
                                              			gbc.expenditure_organization_id,
                                             			'C',
							     			gbc.award_id	)
											--join with compiled setid of adl.
    		and 	cm.ind_compiled_set_id       = ics.ind_compiled_set_id
    		and 	cm.compiled_multiplier <> 0
    		and 	gbc.packet_id = x_packet_id
                and     gbc.document_type   = 'AP' ;

		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		-- BUG: 1418038 Supplier invoice not updated properly in ASI and FC results .
		-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     	Insert into gms_bc_packets
      			( PACKET_ID,
        		PROJECT_ID,
        		AWARD_ID,
        		TASK_ID,
        		EXPENDITURE_TYPE,
        		EXPENDITURE_ITEM_DATE,
        		ACTUAL_FLAG,
        		STATUS_CODE,
        		LAST_UPDATE_DATE,
        		LAST_UPDATED_BY,
        		CREATED_BY,
        		CREATION_DATE,
        		LAST_UPDATE_LOGIN,
        		SET_OF_BOOKS_ID,
        		JE_CATEGORY_NAME,
        		JE_SOURCE_NAME,
        		TRANSFERED_FLAG,
        		DOCUMENT_TYPE,
        		EXPENDITURE_ORGANIZATION_ID,
        		PERIOD_NAME,
        		PERIOD_YEAR,
        		PERIOD_NUM,
        		DOCUMENT_HEADER_ID ,
        		DOCUMENT_DISTRIBUTION_ID,
        		TOP_TASK_ID,
        		BUDGET_VERSION_ID,
			BUD_TASK_ID,
        		RESOURCE_LIST_MEMBER_ID,
        		ACCOUNT_TYPE,
        		ENTERED_DR,
        		ENTERED_CR ,
        		TOLERANCE_AMOUNT,
        		TOLERANCE_PERCENTAGE,
        		OVERRIDE_AMOUNT,
        		EFFECT_ON_FUNDS_CODE ,
        		RESULT_CODE,
        		GL_BC_PACKETS_ROWID,
        		BC_PACKET_ID,
        		PARENT_BC_PACKET_ID,
				VENDOR_ID)
      		select
      			gbc.PACKET_ID,
      			gbc.PROJECT_ID,
      			gbc.AWARD_ID,
      			gbc.TASK_ID,
      			icc.EXPENDITURE_TYPE,
      			trunc(gbc.EXPENDITURE_ITEM_DATE),
      			gbc.ACTUAL_FLAG,
      			gbc.STATUS_CODE,
      			gbc.LAST_UPDATE_DATE,
      			gbc.LAST_UPDATED_BY,
      			gbc.CREATED_BY,
      			gbc.CREATION_DATE,
      			gbc.LAST_UPDATE_LOGIN,
      			gbc.SET_OF_BOOKS_ID,
      			gbc.JE_CATEGORY_NAME,
      			gbc.JE_SOURCE_NAME,
      			gbc.TRANSFERED_FLAG,
      			gbc.DOCUMENT_TYPE,
      			gbc.EXPENDITURE_ORGANIZATION_ID,
      			gbc.PERIOD_NAME,
      			gbc.PERIOD_YEAR,
      			gbc.PERIOD_NUM,
      			gbc.DOCUMENT_HEADER_ID ,
      			gbc.DOCUMENT_DISTRIBUTION_ID,
      			gbc.TOP_TASK_ID,
      			gbc.BUDGET_VERSION_ID,
      			gbc.BUD_TASK_ID,	-- Bug 3338999
      			gbc.RESOURCE_LIST_MEMBER_ID,
      			gbc.ACCOUNT_TYPE,
			-- Bug 1980810 PA Rounding function added
		        pa_currency.round_currency_amt(decode(nvl(entered_dr,0),0,0,((nvl(gbc.BURDENABLE_RAW_COST ,0)) * nvl(cm.compiled_multiplier,0)))),
     			pa_currency.round_currency_amt(decode(nvl(entered_cr,0),0,0,((nvl(gbc.BURDENABLE_RAW_COST ,0)) * nvl(cm.compiled_multiplier,0)))),
      			gbc.TOLERANCE_AMOUNT,
      			gbc.TOLERANCE_PERCENTAGE,
      			gbc.OVERRIDE_AMOUNT,
      			gbc.EFFECT_ON_FUNDS_CODE ,
      			gbc.RESULT_CODE,
      			gbc.GL_BC_PACKETS_ROWID,
      			gms_bc_packets_s.nextval,
      			gbc.BC_PACKET_ID,
				gbc.vendor_id
      		from   	pa_ind_rate_sch_revisions irsr,
             		pa_cost_bases cb,
             		pa_expenditure_types et,
             		pa_ind_cost_codes icc,
             		pa_cost_base_exp_types cbet,
             		pa_ind_rate_schedules_all_bg irs,
             		pa_ind_compiled_sets ics,
             		pa_compiled_multipliers cm,
             		gms_bc_packets gbc
       		where 	irsr.cost_plus_structure     = cbet.cost_plus_structure
         	and 	cb.cost_base                 = cbet.cost_base
         	and 	cb.cost_base_type            = cbet.cost_base_type
                and     ics.cost_base                = cbet.cost_base --Bug 3003584
         	and 	et.expenditure_type          = icc.expenditure_type
         	and 	icc.ind_cost_code            = cm.ind_cost_code
         	and 	cbet.cost_base               = cm.cost_base
         	and 	cbet.cost_base_type          = 'INDIRECT COST'
         	and 	cbet.expenditure_type        = gbc.expenditure_type
         	and 	irs.ind_rate_sch_id          = irsr.ind_rate_sch_id
         	and 	ics.ind_rate_sch_revision_id = irsr.ind_rate_sch_revision_id
         	and 	ics.organization_id          = gbc.expenditure_organization_id
         	and 	gbc.document_type            = 'EXP'
    		and     ics.ind_compiled_set_id      = gms_cost_plus_extn.AWARD_CMT_COMPILED_SET_ID(	gbc.DOCUMENT_HEADER_ID ,
									gbc.DOCUMENT_DISTRIBUTION_ID,
						 			gbc.task_id,
									gbc.document_type,
	                                             			gbc.expenditure_item_date,
                                                                        gbc.expenditure_type, --Bug 3003584
						   		        gbc.expenditure_organization_id,
									'C',
									gbc.award_id	)
         	and 	cm.ind_compiled_set_id       = ics.ind_compiled_set_id
         	and 	cm.compiled_multiplier       <> 0  -- Fix for Bug 806481
         	and 	gbc.packet_id = x_packet_id ;

	  x_temp := 'SETUP_RLMI' ;

	  -- FYI ----------------------------
	  -- R-> MODE inicate RESERVED MODE.
	  -- --------------------------------

	  -- ------------
	  -- Bug  2143160
	  -- ------------
	  gms_cost_plus_extn.update_exp_rev_cat (x_packet_id);

	  IF L_DEBUG = 'Y' THEN
	  	gms_error_pkg.gms_debug('GMS :setup_rlmi  START TIME :'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 'C');
	  END IF;

          gms_funds_control_pkg.setup_rlmi(	x_packet_id, 'R', x_err_code, x_err_buff) ;

	  IF L_DEBUG = 'Y' THEN
	  	gms_error_pkg.gms_debug('GMS :setup_rlmi  END TIME :'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 'C');
	  END IF;

	  -- -----------------
	  -- Bug 2143160
	  -- -----------------
	  gms_cost_plus_extn.update_top_tsk_par_res (x_packet_id);

	  x_temp := NULL ;

      IF NVL(x_err_code, 0) <> 0 THEN
          pa_cc_utils.log_message('GMS: Resource mapping failed for packet :'||to_char(x_packet_id),1);
          raise_application_error( -20000, SQLERRM(X_ERR_CODE) ) ;
      END IF ;

      SELECT count(*)
        into x_err_code
        FROM DUAL
       WHERE exists ( select 'X' from gms_bc_packets
                                where packet_id = x_packet_id
                                  and substr(nvl(result_code, 'P'),1,1) = 'F' );

	  IF L_DEBUG = 'Y' THEN
	  	gms_error_pkg.gms_debug('GMS:vert_trx_interface  END TIME :'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 'C');
	  END IF;

      IF x_err_code > 0 THEN
          pa_cc_utils.log_message('GMS: Resource mapping failed for packet :'||to_char(x_packet_id),1);
          raise_application_error( -20000, 'GMS: Resource mapping failed for packet :'||to_char(x_packet_id) ) ;
      END IF ;

  EXCEPTION
  WHEN OTHERS THEN
     X_status := SQLCODE;
	 IF L_DEBUG = 'Y' THEN
	 	gms_error_pkg.gms_debug('GMS:EXCEPTION:vert_trx_interface  END TIME :'||to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'), 'C');
	 	gms_error_pkg.gms_debug('vert_trx_interface  :'||SQLERRM, 'C');
	 END IF;

	 IF NVL(x_temp,'NONE') = 'SETUP_RLMI' THEN
        raise_application_error( -20000, 'GMS: Resource mapping failed for packet :'||to_char(x_packet_id) ) ;
	 END IF ;

     RAISE;

  END vert_trx_interface ;

  -- ----------------------------------------------------------------
  -- API to allow vertical applications to take actions following the
  -- creation of AP distribution lines.
  -- This is called from PA_XFER_ADJ.
  -- -----------------------------------------------------------------
  PROCEDURE VERT_PAAP_SI_ADJUSTMENTS( x_expenditure_item_id      IN NUMBER,
							     x_invoice_id               IN NUMBER,
								 x_distribution_line_number IN NUMBER,
								 x_cdl_line_num				IN NUMBER,
								 x_project_id               IN NUMBER,
								 x_task_id                  IN NUMBER,
								 status                 IN OUT NOCOPY NUMBER ) IS

	x_rec	gms_award_distributions%ROWTYPE ;
	x_invoice_distribution_id 	NUMBER ;

  BEGIN

    L_DEBUG := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

    -- -------------------------------------------------
    -- Vertical application will override the code here.
    -- -------------------------------------------------
    NULL ;
  END VERT_PAAP_SI_ADJUSTMENTS ;

  -- ----------------------------------------------------------------
  -- API to allow vertical applications to validate transaction
  -- interface. This is called from PA_TRX_IMPORTS just after ValidateItem
  -- -----------------------------------------------------------------
  PROCEDURE VERT_APP_VALIDATE(  X_transaction_source    IN VARCHAR2,
                                X_CURRENT_BATCH         IN VARCHAR2,
                                X_txn_interface_id      IN NUMBER ,
								X_org_id				IN NUMBER,
                                X_status            	IN OUT NOCOPY Varchar2 ) IS

    x_invoice_id        varchar2(20) ;
    -- AP Lines uptake: use invoice_distribution_id instead of distribution_line_number
    x_inv_dist_id       NUMBER;
    --
    -- bug : 3617328 perf issue in gmspax1b.pls
    --
    l_project_id        number ;
    l_task_id           number ;
    l_project_number    pa_projects_all.segment1%TYPE ;
    l_task_number       pa_tasks.task_number%TYPE ;
    x_outcome		     VARCHAR2(2000) ;
    l_gl_accted_flag	     VARCHAR2(1) ;
    l_bud_ver_id		     NUMBER ;
    l_dummy			     NUMBER ;
    l_award_id                   NUMBER ;
    l_pre_processing_extension   VARCHAR2(60); -- Bug 3035863


	-- -----------------------------------------------------------------------------------
	-- BUG : 2484010 INTERFACE SUP INV FROM PAYABLES DOES NOT SHOW APPROPRIATE EXCEPTIONS
	-- -----------------------------------------------------------------------------------
	cursor C_gl_accted is
		select gl_accounted_flag ,
          	       pre_processing_extension -- Bug 3035863
		  from pa_transaction_sources
		 where transaction_source = X_transaction_source ;
	-- -----------------------------------------------------------------
	-- BUG: 1361739 - Supplier Invoice Interface cause validation
	-- failed. ERROR - GMS_VALIDATION_FAILED.
	-- Supplier Invoice Interface doesn't put records into
	-- gms_transaction_interface_all, So award_id wasn't found and result
	-- in GMS_VALIDATION_FAILED.
	-- We should be doing this validations only if we have records in
	-- gms_transaction_interface_all table .
	-- ------------------------------------------------------------------
	CURSOR C_BUDGET_CHECK ( x_project_id NUMBER, x_award_id NUMBER ) is
		SELECT budget_version_id
		  from gms_budget_versions
		 where project_id           = x_project_id
		   and award_id             = x_award_id
		   and budget_status_code   = 'B'
		   and current_flag         = 'Y' ;

	CURSOR C_AWD_EXP_TYPE_CHECK ( x_award_id number, x_exp_type varchar2) is
		   select 1
			 from gms_award_exp_type_act_cost
			where award_id 		   = x_award_id
			  and expenditure_type = x_exp_type ;

        cursor c_awd_exp_type_check2 (  x_award_id number, x_exp_type varchar2) is
               select 1
	         from gms_bc_packets
		where status_code = 'A'
		  and award_id         = x_award_id
		  and expenditure_type = x_exp_type ;

    -- =============================================================================
    -- BUG : 2540841 - Reject supplier invoice dist lines having incorrect ADLS.
    -- =============================================================================
    cursor c_get_award is
        select adl.award_id
          from gms_award_distributions adl,
               ap_invoice_distributions_all apd
         where apd.award_id = adl.award_set_id
           and adl.adl_line_num = 1
           and adl.adl_status   = 'A'
           and apd.invoice_id   = to_number(x_invoice_id)
           -- AP Lines uptake: use invoice_distribution_id instead of distribution_line_number
           and apd.invoice_distribution_id = x_inv_dist_id
	   and adl.document_type  = 'AP'
	   and apd.invoice_id     = NVL( adl.invoice_id, 0)
         -- AP Lines uptake: use invoice_distribution_id instead of distribution_line_number
	   and apd.invoice_distribution_id = NVL ( adl.invoice_distribution_id, 0) ;
   --
   -- Bug 5237650
   -- R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
   -- =====
   CURSOR GET_VALID_AWARDS IS
       Select   Allowable_Schedule_Id,
                nvl(Preaward_Date,START_DATE_ACTIVE) preaward_date,
                End_Date_Active                      end_date,
                Close_Date                           close_date,
                Status
        from    GMS_AWARDS
        where   award_id =  l_award_id;

   c_award_rec      GET_VALID_AWARDS%ROWTYPE ;
	-- =========================================================================
	-- 1646518 - GMS_VALIDATION_FAILED WHEN RUNNING TRANSACTION IMPORT PROCESS
	-- Date 	: 02/19/2001
	-- Fix		: additional Join  T.task_id  = P.project_id was added.
	-- =========================================================================

	--=========================================================================
	--bug 1651938 - Transaction Import Failed with TXN_NOT_FOUND.
	-- T.task_id	= P.project_id was bad join fixed.
	--=========================================================================
	-- --Fix bug 2355391 ( Modified for the bug )
	-- 2747838 ( SUPPLIER INVOICE DO NOT INTERFACE TO GRANTS. )
	-- Projects is using project_id column value for projects
	-- seeded transaction sources.
	-- PA.K Certification changes.
	-- ========================================================================
        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
	CURSOR C_txn_rec is
		SELECT txn.project_id		   project_id,
		       txn.task_id		   task_id,
		       txn.project_number          project_number,
		       txn.task_number             task_number,
		       txn.expenditure_type	   expenditure_type,
		       txn.expenditure_item_date   expenditure_item_date,
                       txn.cdl_system_reference2   invoice_id,
                       -- AP Lines uptake: use invoice_distribution_id instead of distribution_line_number
                       txn.cdl_system_reference5   invoice_distribution_id,
                       txn.system_linkage          system_linkage,
		       Gtxn.award_id		   award_id,
		       -- Bug 3221039 and 3035863 : Added below columns
		       gtxn.award_number            award_number,
		       txn.transaction_source	    transaction_source,
                       txn.batch_name               batch_name,
		       GTXN.txn_interface_id	    txn_interface_id
		  FROM gms_transaction_interface_all Gtxn,
		       pa_transaction_interface_all  txn
		 WHERE txn.txn_interface_id 	= X_txn_interface_id
		   AND txn.txn_interface_id     = Gtxn.txn_interface_id	(+) ;

	txn_rec			     c_txn_rec%ROWTYPE ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
        cursor c_get_project_id is
               select project_id
	         from pa_projects_all
                where segment1 = l_project_number ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
        cursor c_get_project_num is
               select segment1
	         from pa_projects_all
                where project_id = l_project_id ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
        cursor c_get_task_id is
               select task_id
	         from pa_tasks
                where task_number = l_task_number
		  and project_id  = l_project_id ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
        cursor c_get_task_num is
               select task_number
	         from pa_tasks
                where task_id = l_task_id ;

  BEGIN

    L_DEBUG := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');

    pa_cc_utils.log_message( 'GMS_PA_API.VERT_APP_VALIDATE - START' ,1);
    IF X_status is not NULL then
        RETURN ;
    END IF ;
    -- -------------------------------------------------
    -- Vertical application will override the code here.
    -- -------------------------------------------------
	IF not gms_install.enabled(X_org_id) THEN
		RETURN ;
	END IF ;

	OPEN C_txn_rec ;
	FETCH C_txn_rec into TXN_REC ;

	IF C_txn_rec%NOTFOUND THEN
		raise no_data_found ;
	END IF ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
	l_project_id     := txn_rec.project_id ;
	l_task_id        := txn_rec.task_id ;
	l_project_number := txn_rec.project_number ;
	l_task_number    := txn_rec.task_number ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
	if l_project_id is not null then
	   open c_get_project_num ;
	   fetch c_get_project_num into l_project_number ;
	   close c_get_project_num ;
	else
	   open c_get_project_id ;
	   fetch c_get_project_id into l_project_id ;
	   close c_get_project_id ;
	end if ;

        --
        -- bug : 3617328 perf issue in gmspax1b.pls
        --
	IF l_task_id is not NULL THEN
	   open c_get_task_num ;
	   fetch c_get_task_num into l_task_number ;
	   close c_get_task_num ;

	ELSE
	   open c_get_task_id ;
	   fetch c_get_task_id into l_task_id ;
	   close c_get_task_id ;
	END IF ;

	-- Bug: 3016256
	-- Stop INV transactions from being created for the operating unit having grants implemented.
	--
        IF txn_rec.system_linkage = 'INV' then
	   x_status  := 'GMS_INV_NOT_ALLOWED' ;
           IF  C_txn_rec%IsOpen THEN
               CLOSE C_txn_rec;
           END IF ;
           return ;
        END IF ;


	-- Bug 3035863: The following code is added to stop the further processing of
        -- encumbrance if proper pre processing extension is not defined .

        -- This validation will be also fired from Projects main import code if proper
        -- pre-processing extension is not defined and hence will be rejected.

        IF SUBSTR(txn_rec.transaction_source,1,4) ='GMSE'  THEN
     	   OPEN  c_gl_accted ;
 	   FETCH c_gl_accted into l_gl_accted_flag,l_pre_processing_extension ;
	   CLOSE c_gl_accted ;

           IF NVL(l_pre_processing_extension,'DUMMY') <> 'GMS_ENC_IMPORT_PKG.PRE_PROCESS' THEN

             x_status := 'GMS_IMP_ENC_INCORR_EXT';
             CLOSE C_txn_rec ;
      	     RETURN ;

           END IF;

        END IF;

	-- ------------------------------------------------------
	-- Proceed only if entered project is sponsored project.
	-- ------------------------------------------------------
    IF NOT is_sponsored_project( l_project_id ) THEN

	    If txn_rec.award_id IS NOT NULL THEN
              x_status := 'GMS_NOT_A_SPONSORED_PROJECT';   -- Fix for bug : 2439320
            end if ;

            -- Bug 3035863: Reject the transaction if Encumbrance imported from
            -- External system against a non sponsored project.

            If substr(txn_rec.transaction_source,1,4) ='GMSE' OR txn_rec.transaction_source ='GOLDE' THEN
              x_status := 'GMS_IMP_ENC_NONSPON';
            end if ;

 	    CLOSE C_txn_rec ;
	    RETURN ;
	END IF ;

	-- -----------------------------------------------------------------------------------
	-- BUG : 2484010 INTERFACE SUP INV FROM PAYABLES DOES NOT SHOW APPROPRIATE EXCEPTIONS
	-- -----------------------------------------------------------------------------------
	-- Add budget validations
	IF NVL( G_TRX_SOURCE,'X') <> NVL(x_transaction_source,'XX')  THEN

		open c_gl_accted ;
		fetch c_gl_accted into l_gl_accted_flag,l_pre_processing_extension ;
		close c_gl_accted ;
		g_gl_accted_flag := l_gl_accted_flag ;
		G_TRX_SOURCE	 := x_transaction_source ;

	ELSE
		l_gl_accted_flag := g_gl_accted_flag ;
	END IF ;

    X_invoice_id    :=     txn_rec.invoice_id ;
    -- AP Lines uptake:use document_distribution_id instead of distribution_line_number
    x_inv_dist_id :=     txn_rec.invoice_distribution_id;

	-- ---------------------------------------------------------------
	-- Supplier invoice interface transactions do not have records in
	-- gms_transaction_interface_all table. So we need to have award
	-- from the ap distribution table.
	-- ----------------------------------------------------------------
	--
	-- BUG:4164822 PJ.M:B11:P11:QA:GMS IMPORTED TRANSACTIONS REJECTED DUE TO INVALID REASON
	-- Resolution: We shouldn't be checking award details from ap dist lines for external
	-- transaction source.
	--
	-- Bug 4231758 : Added code to consider AP EXPENSE's having system linkage 'ER'
    IF txn_rec.system_linkage IN ('ER','VI')  and
       substr(X_transaction_source, 1,4)  NOT IN ('GMSA','GMSE')
    then
        open c_get_award ;
        fetch c_get_award into l_award_id ;

	IF c_get_award%NOTFOUND THEN
	   x_status  := 'GMS_AP_ADLS_MISSING' ;
	   -- Supplier invoice lines has incorrect award distribution lines, Pls
	   -- contact oracle support.
	   --
	END IF ;
        close c_get_award ;
	--
        -- Bug 5237650
        -- R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
	--
        IF l_award_id is not null then
           pa_cc_utils.log_message( 'GMS_PA_API.VERT_APP_VALIDATE - calling get_valid_awards') ;

           open get_valid_awards ;
           fetch get_valid_awards into c_award_rec ;
           close get_valid_awards ;

           pa_cc_utils.log_message( 'GMS_PA_API.VERT_APP_VALIDATE - EI Date validations') ;
           IF txn_rec.expenditure_item_date <  TRUNC(c_award_rec.preaward_date) THEN
              x_status := 'GMS_EXP_ITEM_DT_BEFORE_AWD_ST' ;
           ELSIF txn_rec.expenditure_item_date >  TRUNC(c_award_rec.end_date) THEN
              x_status := 'GMS_EXP_ITEM_DT_AFTER_AWD_END' ;
           ELSIF c_award_rec.close_date < TRUNC(SYSDATE) THEN
              x_status := 'GMS_AWARD_IS_CLOSED' ;
           END IF ;
           pa_cc_utils.log_message( 'GMS_PA_API.VERT_APP_VALIDATE - EI Date validations :'||x_status) ;
        END IF ;
	--
        -- Bug 5237650
        -- R12.PJ:XB4:DEV:APL:EXP ITEM DATE VALIDATIONS FOR SUPPLIER COST.
	-- End here
    ELSE
        -- Bug 3221039 : Added below code to populate and validate award id and
        -- award number for non VI transaction.

        IF  txn_rec.award_id IS NULL AND txn_rec.award_number IS NULL THEN
           x_status := 'GMS_AWARD_REQUIRED' ;
        ELSE
           txn_rec.award_id := get_award_id (txn_rec.award_id,txn_rec.award_number);
           l_award_id := txn_rec.award_id;
           pa_cc_utils.log_message( 'GMS_PA_API.VERT_APP_VALIDATE - After calling get_award_id , value of award_id'
				     ||txn_rec.award_id ,1);
           IF NVL(txn_rec.award_id,0) = 0  then
             x_status := 'GMS_INVALID_AWARD';
           END IF;
        END IF;

    end if ;

    IF x_status is not NULL then
       IF  C_txn_rec%IsOpen THEN
           CLOSE C_txn_rec;
       END IF ;
       return ;
    END IF ;

    -- ====================================
    -- End of bug fix 2484010 INTERFACE SUP
    -- ====================================

	-- ----------------------------------------------------------------
	-- GL accounted transactions are costed transactions. Costed trans
	-- must have baselined budget and records in burden summary
	-- table.
	-- ----------------------------------------------------------------
	IF NVL(l_gl_accted_flag,'N') = 'Y' and
           l_project_id is not NULL  and
           l_award_id   is not null  and
           txn_rec.expenditure_type is not null THEN

	   l_bud_ver_id := NULL ;
	   --
	   -- BUG:4164822 PJ.M:B11:P11:QA:GMS IMPORTED TRANSACTIONS REJECTED DUE TO INVALID REASON
	   -- Resolution: We shouldn't be checking award details from ap dist lines for external
	   -- transaction source.
	   --

	   open c_budget_check( l_project_id, l_award_id ) ;
	   fetch c_budget_check into l_bud_ver_id ;
	   close c_budget_check ;

	   IF l_bud_ver_id is NULL THEN
	      X_status := 'GMS_AWD_BUDGET_NOT_BASELINED' ;
	   ELSE
	      l_dummy := NULL ;
	      -- bug : 3777692
	      -- PJ.M:B6:P13:FC:SUPPLIER INVOICE INTERFACE FAILS WITH AWARD SUMMARY RECORD NOT FO
	      -- Resolution :
	      --    Check was removed.
	      --    X_status := 'GMS_AWD_EXP_SUMMARY_NOT_FOUND' ;
	   END IF ;
	END IF ;
	-- End of bug 2484010 ***
	-- --------------------------------


	-- -----------------------------------------------------------------
	-- BUG: 1361739 - Supplier Invoice Interface cause validation
	-- failed. ERROR - GMS_VALIDATION_FAILED.
	-- -----------------------------------------------------------------

	-- ---------------------------------------------------------------
	-- Continue processing only if transaction source is custom
	-- interface.
	-- ---------------------------------------------------------------
	IF ( ( txn_rec.TXN_INTERFACE_ID is NULL AND
           substr(X_transaction_source, 1,4) NOT IN ('GMSA','GMSE')) OR
           x_status is not null )     then

	   CLOSE C_txn_rec ;

           IF L_DEBUG = 'Y' THEN
        	gms_error_pkg.gms_DEBUG('GMS Validate X_status:'||X_status, 'C');
           END IF;
	    RETURN ;
	END IF ;

	-- ================================================================
	-- Transaction Import should fail if there are missing record in
	-- gms_transaction_interface_all table.
	-- ================================================================
        -- Bug 3221039 :Commented the following code as the validation is shifted to
        -- newly introduced function set_award_info

	-- --------------------------------------------------------------
	-- Data integrity checks between GMS and PA tables.
	-- --------------------------------------------------------------
        -- Bug 3221039 : Commented the below validations as the columns are obsolete

	-- -----------------------------------------------------------------
	-- Standard GMS validations
	-- -----------------------------------------------------------------
	GMS_TRANSACTIONS_PUB.VALIDATE_TRANSACTION( l_project_id,
						   l_task_id,
						   txn_rec.award_id,
						   txn_rec.expenditure_type,
						   txn_rec.expenditure_item_date,
						   'PAXTTRXB',
						   X_outcome ) ;
	IF X_outcome is not NULL THEN
	   IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_DEBUG(X_outcome, 'C');
	   END IF;
	   X_status := substr(x_outcome,1,30); --bug 2305262
	END IF ;

	CLOSE C_txn_rec ;

  EXCEPTION
	WHEN no_data_found then
		IF C_txn_rec%ISOPEN THEN
			CLOSE C_txn_rec ;
		END IF ;

	    -- -----------------------------------------------------------------------------------
	    -- BUG : 2484010 INTERFACE SUP INV FROM PAYABLES DOES NOT SHOW APPROPRIATE EXCEPTIONS
	    -- -----------------------------------------------------------------------------------
		IF c_budget_check%ISOPEN THEN
			close c_budget_check ;
		END IF ;

		IF c_awd_exp_type_check%ISOPEN THEN
			close c_awd_exp_type_check ;
		END IF ;

		IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_DEBUG('Transaction Record not found for TXN_interface_id :'||to_char(X_txn_interface_id), 'C');
		END IF;
		X_status := 'TXN_NOT_FOUND' ;

	WHEN OTHERS THEN
		IF C_txn_rec%ISOPEN THEN
			CLOSE C_txn_rec ;
		END IF ;

		IF c_budget_check%ISOPEN THEN
			close c_budget_check ;
		END IF ;

		IF c_awd_exp_type_check%ISOPEN THEN
			close c_awd_exp_type_check ;
		END IF ;

		X_status := 'GMS_UNEXPECTED_ERROR' ;
		IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_DEBUG('GMS_UNEXPECTED_ERROR for TXN_interface_id :'||to_char(X_txn_interface_id), 'C');
		END IF;
  END  VERT_APP_VALIDATE ;


  PROCEDURE VERT_SI_ADJ ( x_expenditure_item_id			IN 	NUMBER,
						  x_invoice_id					IN  NUMBER,
						  x_distribution_line_number	IN  NUMBER,
						  x_project_id					IN  NUMBER,
						  x_task_id						IN  NUMBER,
						  status				    IN OUT NOCOPY  NUMBER ) is
  BEGIN
    -- -------------------------------------------------
    -- Vertical application will override the code here.
    -- -------------------------------------------------
    NULL ;
  END VERT_SI_ADJ ;



  -- --------------------------------------------------------------------
  -- BUG: 1332945 - GMS not doing validations for award informations.
  -- called from GMS_TXN_INTERFACE_AIT1
  -- file : gmstxntr.sql
  -- Gms_validations may reject transaction import records.
  -- --------------------------------------------------------------------
  PROCEDURE VERT_REJECT_TXN(	x_txn_interface_id		IN NUMBER,
								x_batch_name			IN VARCHAR2,
								x_txn_source			IN VARCHAR2,
								x_status				IN VARCHAR2,
								x_calling_source		IN varchar2 ) is
  BEGIN
		IF NVL(x_calling_source,'X')  = 'GMS_TXN_INTERFACE_AIT1' OR
		   NVL(x_calling_source,'X')  = 'GMS_TXN_INTERFACE_AIT2' THEN  --bug 2305262

				UPDATE PA_TRANSACTION_INTERFACE_ALL
				   SET transaction_rejection_code = X_status ,
					   transaction_status_code	  = 'PR'
				 where TXN_INTERFACE_ID = x_txn_interface_id
				   and batch_name		= X_batch_name
				   and transaction_source=x_txn_source ;

		ELSE
				UPDATE PA_TRANSACTION_INTERFACE_ALL
				   SET transaction_rejection_code = X_status ,
					   transaction_status_code	  = 'R'
				 where TXN_INTERFACE_ID = x_txn_interface_id
				   and batch_name		= X_batch_name
				   and transaction_source=x_txn_source ;

		END IF ;
  EXCEPTION
	When others THEN
		RAISE ;
  END VERT_REJECT_TXN ;

  -- ---------------------------------------------------------------------
  -- BUG:1380464 - net zero invoice items having different awards are not
  --               picked up by supplier invoice interface process.
  -- Call to this function is added in package PAAPIMP_PKG.
  -- ----------------------------------------------------------------------
  FUNCTION VERT_GET_AWARD_ID( x_award_set_id IN NUMBER,
							  x_invoice_id	 IN NUMBER,
							  x_dist_lno	 IN NUMBER ) return NUMBER is
	l_award_id NUMBER ;

	-- ===========================================
	-- bug : 1765806 jackson lab issue ported here.
	-- ============================================

	-- BUG: 2319153 ( Stuck AP lines not interfaced to Grants.
	-- cursor changed and only criteria used is award_set_id
	-- and active adls.
	-- ----
	-- bug : 2305048 ( Unable to interface AP to OGA.
	-- This is due to multiple active ADLs.
	cursor C1 is
		SELECT award_id
          FROM gms_award_distributions
	     WHERE award_set_id 	=	x_award_set_id
		   AND adl_status		=	'A'
		   and adl_line_num		= 1 ;
		   --AND document_type	=	'AP'
		   --AND invoice_id		=	x_invoice_id
		   --AND distribution_line_number	<=	x_dist_lno ;

	-- ========================================================================
	-- BUG:1772926 - bug was created for situation as follows ..
	-- 1.	Create a PO, Approve it.
	-- 2. 	Create a matching AP.
	-- 3. 	reverse ap distribution line
	-- 4.	add a new line.
	-- 5.   approve AP.
	-- 6. cancelling lines doesn't go fundschecking and ADL will still point to
	--    po. Need a cursor to fix this issue.
	-- =========================================================================

	cursor C_PO is
		SELECT award_id
          FROM gms_award_distributions
	     WHERE award_set_id 	=	x_award_set_id
		   AND adl_status		=	'A'
		   AND document_type	=	'PO'
		   and adl_line_num		= 1 ;

  BEGIN
		IF NVL(x_award_set_id,0) = 0 THEN
			return 0 ;
		END IF ;

		open C1 ;
		fetch C1 into l_award_id ;

		IF C1%NOTFOUND THEN
			open C_po ;
			fetch C_po into l_award_id ;
			close c_po ;
		END IF ;

		close C1 ;

		return l_award_id ;
  EXCEPTION
	WHEN others THEN

		IF C1%ISOPEN THEN
			close C1 ;
		END IF ;

		IF c_po%ISOPEN THEN

			close c_po ;

		END IF ;

		RAISE ;
  END VERT_GET_AWARD_ID ;

 -- ----------------------------------------------------------------------------
 -- This function verifies whether GMS is installed or not
 -- This function is changed to cache the gms_install status and all references
 -- to gms_install.enabled in this package will use this function.
 -- Bug 3002305.
 -- ----------------------------------------------------------------------------

   FUNCTION VERT_INSTALL return BOOLEAN IS

   --l_profile_org	NUMBER := to_number(fnd_profile.value('ORG_ID'));
	l_profile_org NUMBER    :=    PA_MOAC_UTILS.get_current_org_id ;
   BEGIN

     IF ((G_ORG_ID_CHECKED is null AND G_GMS_ENABLED is null) OR
         (G_ORG_ID_CHECKED <> l_profile_org)) THEN

         G_ORG_ID_CHECKED := l_profile_org;

         IF gms_install.enabled then
            G_GMS_ENABLED := 'Y';
	    return TRUE ;
	 Else
            G_GMS_ENABLED := 'N';
	    return  FALSE ;
	 END IF ;

     ELSE

         IF G_GMS_ENABLED = 'Y' THEN
            return TRUE;
         ELSE
            return FALSE;
         END IF;

     END IF;

  END VERT_INSTALL ;


 -- -----------------------------------------------------------------------------
 -- Procedure to set the adjust_action
 -- -----------------------------------------------------------------------------
  PROCEDURE set_adjust_action(x_adjust_action IN VARCHAR2 ) is
    begin
        X_adj_action := '' ;
	X_adj_action := x_adjust_action ;
    end ;

  PROCEDURE OVERRIDE_RATE_REV_ID(
                           p_tran_item_id          IN  number ,
                           p_tran_type             IN  Varchar2 ,
                           p_task_id         	   IN  number ,
                           p_schedule_type         IN  Varchar2 ,
                           p_exp_item_date         IN  Date ,
                           x_sch_fixed_date        OUT NOCOPY Date,
                           x_rate_sch_rev_id 	   OUT NOCOPY number,
                           x_status                OUT NOCOPY number ) is

     l_sponsored_flag      varchar2(1);
     l_award_id            number;
     l_stage               varchar2(10);
     l_transaction_source  pa_transaction_sources.transaction_source%TYPE ;
     l_system_linkage      pa_transaction_interface_all.system_linkage%TYPE ;
     l_system_reference2   pa_transaction_interface_all.cdl_system_reference2%TYPE ;
     l_system_reference3   pa_transaction_interface_all.cdl_system_reference3%TYPE ;
     --
     --BUG 5620362 R12.PJ:XB13:ST3:QA:BC:SYSTEM SHOWS AN ERROR WHEN NR TAX IS INTERFACED TO GRANTS
     --
     l_system_reference5   pa_transaction_interface_all.cdl_system_reference5%TYPE ;

     l_predefined_flag     pa_transaction_sources.predefined_flag%TYPE ;
   BEGIN
           x_sch_fixed_date  := NULL;
           x_rate_sch_rev_id := NULL;
           x_status          := NULL;

           if p_tran_item_id is NULL then
		return;
           end if;

 	   select nvl(sponsored_flag,'N')
	   into  l_sponsored_flag
	   from  pa_tasks t,
	         pa_projects_all p,
	         gms_project_types gpt
	   where p.project_id = t.project_id
	   and   gpt.project_type = p.project_type
	   and   t.task_id = nvl(p_task_id,0);

	   if l_sponsored_flag = 'Y' then
	      --
	      -- BUG 3596533
	      -- Transaction Import process failed with no revesion. award not found due to
	      -- p_tran_type values 'TRANSACTION_IMPORT' was not considered before.
	      --
	      -- Resolution : Get award from invoice distribution table for supplier invoice
	      --              and get award from gms_transaction interface table for user
	      --              defined sources supported by GMS.
	      --
	      IF p_tran_type = 'TRANSACTION_IMPORT' THEN
		 --
		 -- Determine the transaction source details.
		 --
	         --
	         --BUG 5620362 R12.PJ:XB13:ST3:QA:BC:SYSTEM SHOWS AN ERROR WHEN NR TAX IS INTERFACED TO GRANTS
	         -- cdl_system_reference5 was added to the select for invoice distribution ID
		 --
		 select pti.transaction_source,
			pti.system_linkage,
			pti.cdl_system_reference2,
			pti.cdl_system_reference3,
			pti.cdl_system_reference5,
			pts.predefined_flag
                   into l_transaction_source,
			l_system_linkage,
			l_system_reference2,
			l_system_reference3,
			l_system_reference5,
			l_predefined_flag
		   from pa_transaction_interface_all  pti,
			pa_transaction_sources       pts
                  where pti.txn_interface_id   = p_tran_item_id
		    and pti.transaction_source = pts.transaction_source ;
		  --
		  -- Supplier invoice system linkage from pre defined source : get award from
		  -- invoice distributions and award distribution lines.
		  --
		  -- Bug 4231758 : Added code to consider AP EXPENSE's having system linkage 'ER'
		  IF l_system_linkage IN ('ER','VI') and l_predefined_flag = 'Y' THEN
	             --
	             --BUG 5620362 R12.PJ:XB13:ST3:QA:BC:SYSTEM SHOWS AN ERROR WHEN NR TAX IS INTERFACED TO GRANTS
		     --Query was based on invoice distribution ID stored in the l_system_reference5
		     --
     		     select adl.award_id
      		       into l_award_id
       		       from gms_Award_distributions adl,
			    ap_invoice_distributions_all apd
       		      where apd.invoice_id               = l_system_reference2
			and apd.invoice_distribution_id  = l_system_reference5
			and apd.invoice_id               = adl.invoice_id
			and apd.invoice_distribution_id  = adl.invoice_distribution_id
			and apd.award_id                 = adl.award_set_id
       		        and adl.adl_status               = 'A'
       		        and adl.document_type            = 'AP'
		        and adl.adl_line_num             = 1
                        and rownum                       = 1;
		  END IF ;
		  --
		  -- USER defined transaction source having gms supported transaction source
		  -- get award id from gms_transaction_interface_all table record.
		  --
		  IF l_predefined_flag = 'N' and
		     ( SUBSTR(l_transaction_source, 1,4) in ('GMSA', 'GMSE' ) )
                  THEN
		     select awd.award_id
		       into l_award_id
		       from gms_transaction_interface_all gti,
			    gms_awards_all                awd
                      where gti.txn_interface_id                     = p_tran_item_id
			and NVL(gti.award_id, awd.award_id)          = awd.award_id
			and NVL(gti.award_number, awd.award_number ) = awd.award_number
			and ( gti.award_id     is NOT NULL OR gti.award_number is NOT NULL
                            ) ;
		  END IF ;
	      ELSE
     		select adl.award_id
      		  into l_award_id
       		  from gms_Award_distributions adl
       		 where adl.expenditure_item_id = p_tran_item_id
       		   and adl.adl_status          = 'A'
       		   and adl.document_type       = 'EXP'
		   and adl.adl_line_num        = 1
                   and rownum                  = 1;

	      END IF ;
         	gms_cost_plus_extn.get_award_ind_rate_sch_rev_id(l_award_id  ,
							  --Added for Bug 2097676 :Multiple Indirect Cost Schedules build
                                                          p_task_id          ,
                                                          p_exp_item_date   ,
                                                          x_rate_sch_rev_id,
                                                          x_status          ,
                                                          l_stage);

                -- ==============================================================
		-- We need to return x_status 0 here.
		-- We don't want PA to process anything for award specific
		-- transactions.
		-- PA_COST_PLUS do not process task level overrides when GMS hooks
		-- returns 0.
		-- 2995239 gms_pa_api3 main line code related changes.
		-- =============================================================
		x_status := 0 ;
	     end if;

   END  Override_Rate_Rev_Id ;

-- ========================================================================================
--		30-APR-2001	aaggarwa	BUG		: 1751995
--								Description	: Multiple awards funding single projects causes
--		  						burdening problem.
--								Resolution	: PA_CLIENT_EXTN_BURDEN_SUMMARY.CLIENT_GROUPING
--		  						was modified for grants accounting to add award
--		  						parameter for grouping. This will allow to create
--		  						burden summarization lines for each award.
-- ========================================================================================
   FUNCTION CLIENT_GROUPING
	(
		p_src_expnd_type     IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
     		p_src_ind_expnd_type IN PA_EXPENDITURE_TYPES.expenditure_type%TYPE,
		p_src_attribute1     IN PA_EXPENDITURE_TYPES.attribute1%TYPE ,
		v_grouping_method    IN varchar2
	) return varchar2  is

	x_grouping_method	varchar2(2000) ;
   BEGIN

	x_grouping_method	:= v_grouping_method ;

--   if not gms_install.enabled then -- Bug 3002305
   if not vert_install then


		IF v_grouping_method is NOT NULL THEN
			x_grouping_method := x_grouping_method||p_src_attribute1 ;
		ELSE
			x_grouping_method := p_src_attribute1 ;
		END IF ;

	END IF ;

	return x_grouping_method ;


   END CLIENT_GROUPING;


      -- --------------------------------------------------------------------------
      -- Function to check the award status before doing any adjustments in
      -- Expenditure Inquiry form.
      -- --------------------------------------------------------------------------
       FUNCTION is_award_closed (x_expenditure_item_id IN NUMBER ,x_task_id IN NUMBER ,x_doc_type in varchar2 default 'EXP') return VARCHAR2 IS --Bug 5726575

         l_award_status gms_awards_all.status%TYPE ;
         l_close_date   gms_awards_all.close_date%TYPE ;
         l_project_id   pa_projects_all.project_id%TYPE ;

         Begin

          select aw.status, aw.close_date
            into l_award_status ,l_close_date
            from gms_award_distributions adl ,gms_awards_all aw
           where adl.expenditure_item_id = x_expenditure_item_id
             and adl.adl_status = 'A'
             and adl.document_type = nvl(x_doc_type, 'EXP') --Bug 5726575
             and adl.award_id = aw.award_id
             and rownum = 1 ;

        IF l_award_status = 'CLOSED' or l_close_date < trunc (sysdate ) then
               RETURN 'Y' ;
        Else
               RETURN 'N' ;
        END IF ;

        EXCEPTION
        when NO_DATA_FOUND then
	      --
	      -- 3134005
	      -- GMS.L: COMPILATION OF BURDEN SCHEDULE COMPLETES IN ERROR
	      -- SQL was wrong causing too many rows found
	      -- join with pa_expenditure_items_all was removed.
	      --
              select t.project_id into l_project_id
                from pa_tasks t
               where t.task_id = x_task_id ;

                If is_sponsored_project(l_project_id) THEN
                   RETURN 'Y' ;              -- adl is missing hence don't process that item.
                Else
                   RETURN 'N' ;              -- This is non-sponsored project , let PA continue its process
               End if ;
      END is_award_closed ;
      -- ------------------------------------------------------------

/* R12 Changes Start */
        -- -------------------------------------------------------------------------
        -- This function gets the award id for the specified expenditure item
        -- -------------------------------------------------------------------------
        FUNCTION VERT_GET_EI_AWARD_ID(p_expenditure_item_id NUMBER)
        RETURN NUMBER IS

      	  l_award_id  NUMBER := NULL; /* Bug 5194265 - Initialized to NULL */

          CURSOR C_AWARD_ID_CUR(p_expenditure_item_id NUMBER) IS
          SELECT AWARD_ID
            FROM GMS_AWARD_DISTRIBUTIONS
           WHERE EXPENDITURE_ITEM_ID = p_expenditure_item_id
             AND ADL_LINE_NUM = 1
             AND DOCUMENT_TYPE = 'EXP'
             AND ADL_STATUS = 'A';

    	BEGIN

          OPEN C_AWARD_ID_CUR(p_expenditure_item_id);
          FETCH C_AWARD_ID_CUR INTO l_award_id;
          CLOSE C_AWARD_ID_CUR;

          RETURN l_award_id; /* Bug 5194265 - Missed out the RETURN statement :-( */

    	END VERT_GET_EI_AWARD_ID;
        -- -------------------------------------------------------------------------
/* R12 Changes End */

/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input and returns the award associated with
   this expenditure item.
   The function raises an exception if no award is associated with the expenditure item.
*/
  FUNCTION VERT_GET_AWARD_NUMBER(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ) RETURN VARCHAR2 IS
    l_award_number GMS_AWARDS_ALL.AWARD_NUMBER%TYPE := NULL;
  BEGIN
    IF p_expenditure_item_id = G_EXPENDITURE_ITEM_ID THEN
      l_award_number := G_AWARD_NUMBER;
    ELSE
      SELECT a.award_number
        INTO l_award_number
        FROM gms_awards_all a
           , gms_award_distributions adl
       WHERE adl.award_id = a.award_id
         AND adl.expenditure_item_id = p_expenditure_item_id
         AND adl.adl_line_num = 1
         AND adl.adl_status = 'A'
         AND adl.document_type = 'EXP';
      G_AWARD_NUMBER := l_award_number;
      G_EXPENDITURE_ITEM_ID := p_expenditure_item_id;
    END IF;
    RETURN l_award_number;
  END VERT_GET_AWARD_NUMBER;

/* Added for Bug 5490120
   This function accepts the expenditure_item_id as the input.
   If the exenditure item belongs to a sponsored project:
     The function determines the Award Number and verifies if the Award Number falls in the specified range.
       If yes, then the function returns 'Y'.
       If no, then the funciton returns 'N'.
   If the expenditure item belongs to a non-sponsored project:
     If award range is not specified, then the function returns 'Y'.
     If award range is specified, then the function returns 'N'.
*/
  FUNCTION VERT_IS_AWARD_WITHIN_RANGE(
    p_expenditure_item_id IN PA_EXPENDITURE_ITEMS_ALL.EXPENDITURE_ITEM_ID%TYPE
   ,p_from_award_number IN GMS_AWARDS_ALL.AWARD_NUMBER%TYPE DEFAULT NULL
   ,p_to_award_number IN GMS_AWARDS_ALL.AWARD_NUMBER%TYPE DEFAULT NULL
   ) RETURN VARCHAR2 IS
    l_award_number GMS_AWARDS_ALL.AWARD_NUMBER%TYPE := NULL;
  BEGIN
    l_award_number := VERT_GET_AWARD_NUMBER(p_expenditure_item_id);
    IF l_award_number BETWEEN NVL(p_from_award_number,l_award_number) AND NVL(p_to_award_number,l_award_number) THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF p_from_award_number IS NULL
      AND p_to_award_number IS NULL THEN
        RETURN 'Y';
      ELSE
        RETURN 'N';
      END IF;
  END VERT_IS_AWARD_WITHIN_RANGE;

BEGIN
    SELECT default_dist_award_id
      into x_default_dist_award_id
      from gms_implementations ;
exception
    when no_data_found then
	x_default_dist_award_id := NULL;
--For Bug 4581880
when OTHERS then
	x_default_dist_award_id := NULL;

END GMS_PA_API;

/
