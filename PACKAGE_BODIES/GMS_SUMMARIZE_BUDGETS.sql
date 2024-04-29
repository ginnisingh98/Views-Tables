--------------------------------------------------------
--  DDL for Package Body GMS_SUMMARIZE_BUDGETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_SUMMARIZE_BUDGETS" AS
-- $Header: gmsbusub.pls 120.2.12010000.2 2009/05/11 17:48:28 apaul ship $

 -- To check on, whether to print debug messages in log file or not
 L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');
 x_mixed_budgeting	varchar2(1);

 -- Bug 2587078 : Modified parameter name from x_err_code to x_return_status
 --               to bring the code in consistency with existing grants code
 --               which uses x_err_code for tracking errors.

-- Added for GMS enhancement for R12: 5583170
-- ==============================================================================
  Procedure validate_profile_bem (p_project_bem varchar2,
                                  p_res_categorized VARCHAR2,
                                  p_err_msg_code OUT NOCOPY VARCHAR2 ) is
   x_err_code     NUMBER(15);
   x_err_stage    VARCHAR2(2000);
   l_start_date_active  DATE ;
   l_end_date_active   DATE ;
   l_entry_level_code pa_budget_entry_methods.entry_level_code%TYPE ;
   l_categorization_code pa_budget_entry_methods.categorization_code%TYPE ;
   l_time_phased_type_code pa_budget_entry_methods.time_phased_type_code%TYPE ;
   l_burdened_cost_flag pa_budget_entry_methods.burdened_cost_flag%TYPE ;
   l_bem_valid  VARCHAR2(1);

   begin
     p_err_msg_code := 'S' ;
     l_bem_valid := 'Y' ;

      If  p_project_bem IS NOT NULL THEN
         select start_date_active ,
                NVL(end_date_active, SYSDATE) ,
                entry_level_code,categorization_code,
                time_phased_type_code,
                burdened_cost_flag
          into l_start_date_active,
               l_end_date_active,
               l_entry_level_code,
               l_categorization_code,
               l_time_phased_type_code,
               l_burdened_cost_flag
          from  pa_budget_entry_methods
         where  BUDGET_ENTRY_METHOD = p_project_bem ;
      End if ;



       IF p_project_bem IS NULL then
          l_bem_valid := 'N' ;
       END IF ;

       If  l_start_date_active > SYSDATE and l_end_date_active <  SYSDATE then
               l_bem_valid := 'N' ;
       end if ;

       If l_entry_level_code <> 'P' OR l_burdened_cost_flag <> 'Y'  then
              l_bem_valid := 'N' ;
       end if ;

       IF  l_categorization_code <>  'N'   and p_res_categorized = 'N' Then
           l_bem_valid := 'N' ;
       END IF ;

       IF  NVL(l_categorization_code,'N') =  'N'   and p_res_categorized = 'Y' Then
           l_bem_valid := 'N' ;
       END IF ;

     If p_res_categorized = 'Y' and l_bem_valid = 'N' then
          x_err_stage := 'GMS_SUMMARIZE_BUDGETS.validate_profile_bem - Caterozied and Invlid BEM ';
                gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_BUDGET_SUM_CHANGE_CAT',
                                        x_exec_type => 'C', -- for concurrent process
                                        x_err_code => x_err_code,
                                        x_err_buff => x_err_stage);

            gms_error_pkg.gms_output(x_output => x_err_stage);

               p_err_msg_code := 'F' ;
     end if ;

     If p_res_categorized = 'N' and l_bem_valid = 'N' then
          x_err_stage := 'GMS_SUMMARIZE_BUDGETS.validate_profile_bem - Uncaterozied and Invlid BEM ';
                gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_BUDGET_SUM_CHAN_UNCAT',
                                        x_exec_type => 'C', -- for concurrent process
                                        x_err_code => x_err_code,
                                        x_err_buff => x_err_stage);
            gms_error_pkg.gms_output(x_output => x_err_stage);

               p_err_msg_code := 'F' ;
     end if ;


   end ;

-- ------------------------------------------------------------
 PROCEDURE GMS_SUMMARIZE_BUDGETS  (x_project_id NUMBER
                                  ,x_return_status      OUT NOCOPY VARCHAR2
                                  ,x_err_stage          OUT NOCOPY VARCHAR2) IS

  l_bem_count number ;
  l_res_list_count number ;
  l_award_count number ;
  l_res_categorized  VARCHAR2(1) ;
  l_validate_profile VARCHAR2(1) := 'N' ;
  l_time_phased_type_code VARCHAR2(1) ;
  l_res_list_name         pa_resource_lists.name%type ;
  x_err_code     varchar2(1);

  BEGIN
   x_return_status := 'S';
   G_pa_res_list_id_none := NULL ;
   G_pa_res_list_id      := NULL ;

    select count(distinct budget_entry_method_code) ,
           count(distinct resource_list_id ), count(distinct award_id)
      into l_bem_count, l_res_list_count, l_award_count
      from GMS_BUDGET_VERSIONS
     where budget_status_code = 'B'
      and current_flag = 'Y'
      and project_id = x_project_id ;
IF L_DEBUG = 'Y' THEN
                 gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - l_bem_count   : '||l_bem_count  ,'C');
                 gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - l_res_list_count   : '||l_res_list_count  ,'C');
                 gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - l_award_count   : '||l_award_count  ,'C');
              END IF;

    G_multi_funding := 'N' ;
      IF l_award_count > 1 THEN
        G_multi_funding := 'Y';
      END IF ;


        -- ===================================================================================
        -- When multiple award budgets are using the DIFFERENT BUDGET ENTRY METHODS and --
        -- DIFFERENT RESOURCE LIST then the project budget would be summarized at the
        -- Project entry level and none resource.
        -- ===================================================================================
      l_validate_profile  := 'N' ;
      L_res_categorized   := 'N' ;

      IF l_bem_count >= 1 and l_res_list_count > 1 then
	     G_project_bem :=  fnd_profile.value('GMS_PROJECT_BEM_UNCATEGORIZED');
           if G_project_bem IS NOT NULL then
	     l_res_categorized  := 'N' ;
	     l_validate_profile  := 'Y' ;
            else
               x_err_stage := 'GMS_SUMMARIZE_BUDGETS.GMS_SUMMARIZE_BUDGETS - UnCategorized Profile not Defined';
                gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_BUDGET_SUM_CHAN_UNCAT',
                                        x_exec_type => 'C', -- for concurrent process
                                        x_err_code => x_err_code,
                                        x_err_buff => x_err_stage);

                 gms_error_pkg.gms_output(x_output => x_err_stage);

             /*  gms_error_pkg.gms_message( x_err_name => 'GMS_PROJ_BUDGET_SUM_CHAN_UNCAT',
                                  x_err_code => x_err_code,
                                  x_err_buff => x_err_stage); */
                x_return_status := 'F' ;
           end if ;

      End if ;

      If l_bem_count >= 1 and l_res_list_count  = 1 then

         select distinct rl.name
           into l_res_list_name
           from GMS_BUDGET_VERSIONS gb ,  pa_resource_lists  rl
          where gb.resource_list_id = rl.resource_list_id
            and budget_status_code = 'B'
            and current_flag = 'Y'
            and project_id = x_project_id ;

       end if;

    IF l_bem_count > 1 and l_res_list_count = 1  and l_res_list_name =  'None' then
       G_project_bem       :=  fnd_profile.value('GMS_PROJECT_BEM_UNCATEGORIZED');
       l_res_categorized   := 'N' ;
       l_validate_profile  := 'Y' ;
    END IF ;

    IF l_bem_count > 1 and l_res_list_count = 1 and l_res_list_name <>  'None' then
       G_project_bem       := fnd_profile.value('GMS_PROJECT_BEM_CATEGORIZED');
       L_res_categorized   := 'Y' ;
       l_validate_profile  := 'Y' ;
    END IF ;


       -- ===================================================================================
       -- When multiple award budgets are using the SAME BUDGET ENTRY METHODS and --
       -- SAME RESOURCE LIST then the project budget would be summarized using the
       -- same budget entry method and same resource list provided that date range DO NOT overlap.
       -- ===================================================================================

    IF l_bem_count = 1 and l_res_list_count = 1 and l_award_count > 1 THEN
        select distinct time_phased_type_code  -- Added distinct for bug : 5750106
          into l_time_phased_type_code
          from GMS_BUDGET_VERSIONS bv,  pa_budget_entry_methods bem
         where bv.budget_entry_method_code = bem.budget_entry_method_code
           and bv.project_id = x_project_id ;

         IF l_time_phased_type_code = 'R'   and l_res_list_name =  'None' then
            G_project_bem :=  fnd_profile.value('GMS_PROJECT_BEM_UNCATEGORIZED');
            l_res_categorized  := 'N' ;
	    l_validate_profile  := 'Y' ;
         END IF ;

        If l_time_phased_type_code = 'R' and l_res_list_name <>  'None' then

IF L_DEBUG = 'Y' THEN
                 gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Setting CAT profile  : ','C');
end if ;
           G_project_bem := fnd_profile.value('GMS_PROJECT_BEM_CATEGORIZED');
           l_res_categorized  := 'Y' ;
           l_validate_profile  := 'Y' ;

        END IF ;

        If NVL(l_time_phased_type_code,'N') <> 'R' THEN
           G_project_bem := NULL ;
        end if ;
    End if ; -- end if for IF l_bem_count = 1 and l_res_list_count = 1 and l_award_count > 1 THEN


    IF l_res_categorized = 'N' and l_validate_profile = 'Y' and G_project_bem is NULL THEN

               x_err_stage := 'GMS_SUMMARIZE_BUDGETS.GMS_SUMMARIZE_BUDGETS - UnCategorized Profile not Defined';
                gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_BUDGET_SUM_CHAN_UNCAT',
                                        x_exec_type => 'C', -- for concurrent process
                                        x_err_code => x_err_code,
                                        x_err_buff => x_err_stage);

                 gms_error_pkg.gms_output(x_output => x_err_stage);

                x_return_status := 'F' ;
    End if ;

    IF l_res_categorized = 'Y' and l_validate_profile = 'Y' and G_project_bem is NULL THEN

          x_err_stage := 'GMS_SUMMARIZE_BUDGETS.GMS_SUMMARIZE_BUDGETS - Categorized Profile not Defined';
                gms_error_pkg.gms_message(x_err_name => 'GMS_PROJ_BUDGET_SUM_CHANGE_CAT',
                                        x_exec_type => 'C', -- for concurrent process
                                        x_err_code => x_err_code,
                                        x_err_buff => x_err_stage);

                 gms_error_pkg.gms_output(x_output => x_err_stage);

            x_return_status := 'F' ;
    END IF ;

    If l_validate_profile = 'Y' then
        Validate_Profile_Bem (G_project_bem , l_res_categorized , x_err_code  );
           If x_err_code = 'F' then
               x_return_status := 'F' ;
           end if ;
     End if ;

     IF x_return_status = 'F' THEN
        return ;
     END IF ;

      IF l_res_categorized = 'Y' THEN
        select distinct resource_list_id
          into  G_pa_res_list_id
          from GMS_BUDGET_VERSIONS
         where budget_status_code = 'B'
           and current_flag = 'Y'
           and project_id = x_project_id ;
IF L_DEBUG = 'Y' THEN
                 gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - G_pa_res_list_id : '|| G_pa_res_list_id,'C');
end if ;
      END IF ;

    -- Get the resource_list_id from pa_resource_list defined for a BG
    -- if resource lists are different in BEMs.

     If l_res_categorized = 'N'  then
        select resource_list_id
          into G_pa_res_list_id_none
          from pa_resource_lists prl , pa_implementations pai
         where prl.business_group_id = pai.business_group_id
           and prl.uncategorized_flag = 'Y'
           and NVL(prl.migration_code ,'M') = 'M' ;
     END if ;


 end GMS_SUMMARIZE_BUDGETS;
-- ------------------------------------------------------------
  Function budget_dates_overlap(x_project_id NUMBER) RETURN BOOLEAN is

  cursor get_curr_date_range_csr (p_project_id in NUMBER, p_resource_list_member_id IN NUMBER )
  is
  select distinct   gbl.start_date
  ,      gbl.end_date
  from   gms_budget_versions            gbv
  ,      gms_resource_assignments       gra
  ,      gms_budget_lines               gbl
  where  gbv.budget_version_id = gra.budget_version_id
  and    gra.resource_assignment_id = gbl.resource_assignment_id
  and    gbv.project_id = p_project_id
  and    gra.resource_list_member_id = p_resource_list_member_id;

 cursor get_other_date_range_csr ( p_project_id in NUMBER)
  is
  select distinct gra.resource_list_member_id , gbl.start_date
  ,      gbl.end_date
  from   gms_budget_versions            gbv
  ,      gms_resource_assignments       gra
  ,      gms_budget_lines               gbl
  where  gbv.budget_version_id = gra.budget_version_id
  and    gra.resource_assignment_id = gbl.resource_assignment_id
  and    gbv.project_id = p_project_id
  and    gbv.current_flag = 'Y'
  order by gra.resource_list_member_id ;-- , award_id ;

  l_award_count number ;
   l_resource_list_member_id NUMBER ;
   Begin
       IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....'|| 'Begin of get_other_date_range_csr','C');
        END IF;

     select count(award_id)
        into l_award_count
      from GMS_BUDGET_VERSIONS
     where budget_status_code = 'B'
      and current_flag = 'Y'
      and project_id = x_project_id;

     if l_award_count = 1 then

       IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....'||'Project is NOT Multi Funded','C');
        END IF;
       return FALSE ;

     end if;

       IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....'||'Project is Multi Funded','C');
        END IF;

      FOR other_date_range_rec IN get_other_date_range_csr  ( p_project_id => x_project_id )
      LOOP
               IF L_DEBUG = 'Y' THEN
                   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....11','C');
                END IF;

               l_resource_list_member_id :=  other_date_range_rec.resource_list_member_id ;

          FOR curr_date_range_rec IN get_curr_date_range_csr (p_project_id => x_project_id ,
                                                             p_resource_list_member_id => l_resource_list_member_id)
          LOOP
               IF L_DEBUG = 'Y' THEN
                   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....22','C');
                END IF;


             if (curr_date_range_rec.start_date < other_date_range_rec.start_date
                                and curr_date_range_rec.end_date < other_date_range_rec.start_date) OR
                (curr_date_range_rec.start_date > other_date_range_rec.end_date
                                and curr_date_range_rec.end_date > other_date_range_rec.end_date) OR
                (curr_date_range_rec.start_date = other_date_range_rec.start_date
                                and curr_date_range_rec.end_date = other_date_range_rec.end_date) then

                IF L_DEBUG = 'Y' THEN
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....'||'NO overlapping budget periods','C');
                   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..curr_date_range_rec.start_date  '||curr_date_range_rec.start_date,'C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..curr_date_range_rec.end_date  '||curr_date_range_rec.end_date,'C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..other_date_range_rec.start_date  '||other_date_range_rec.start_date,'C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..other_date_range_rec.end_date  '||other_date_range_rec.end_date,'C') ;
                END IF;

                NULL;  --i.e Continue with next record.


            ELSE -- Dates overlap
                IF L_DEBUG = 'Y' THEN
                   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..curr_date_range_rec.start_date  '||curr_date_range_rec.start_date,'C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..curr_date_range_rec.end_date  '||curr_date_range_rec.end_date,'C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..other_date_range_rec.start_date  '||other_date_range_rec.start_date,'C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap..other_date_range_rec.end_date  '||other_date_range_rec.end_date,'C') ;
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....'||'Budget periods  overlap...','C');
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....Overlap RLMI is'|| to_char(other_date_range_rec.resource_list_member_id),'C');
                END IF;

            RETURN TRUE;
         end if ;

          END LOOP ;
      END LOOP ;

             RETURN FALSE ; -- It means there is no overlapping period for any budgetlines for this project.

                IF L_DEBUG = 'Y' THEN
                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap.....'||' OUTSIDE THE LOOP','C');
                end if;
exception

when others then

                     gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.exception ' || SQLCODE, 'C');
raise;

    End ;
-- ------------------------------------------------------------

 PROCEDURE get_resource_list_id ( x_project_id        		NUMBER
				  ,x_budget_entry_method_code 	OUT NOCOPY VARCHAR2
				  ,x_resource_list_id  	 	OUT NOCOPY  NUMBER
				  ,x_return_status     		OUT NOCOPY VARCHAR2 -- Bug 2587078
 				  ,x_err_stage	      		OUT NOCOPY VARCHAR2)
 IS
 x_err_code     NUMBER(15); -- Bug 2587078
 l_time_phased_type_code VARCHAR2(1);
   BEGIN

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('*** Start of GMS_SUMMARIZE_BUDGETS.GET_RESOURCE_LIST_ID ***','C');
	END IF;

    	select  distinct gbv.resource_list_id -- Added distinct for Bug:2254944
    	, 	gbv.budget_entry_method_code , bem.time_phased_type_code  -- Added time_phase_type_code for bug: 5750106
	into	x_resource_list_id
	, 	x_budget_entry_method_code,l_time_phased_type_code
      	from 	gms_budget_versions gbv, pa_budget_entry_methods bem
 	where 	gbv.project_id = x_project_id
          and gbv.budget_entry_method_code = bem.budget_entry_method_code -- Added for bug 5750106
	and	gbv.current_flag = 'Y';
--	and	rownum < 2; -- Commented out NOCOPY for Bug:2254944

     -- Added if condition for bug : 5750106
      If l_time_phased_type_code = 'R' then
          IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap... Time Phase code  '|| l_time_phased_type_code,'C');
           END IF;
         if budget_dates_overlap(x_project_id) then
          IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap... DAtes overlap TRUE','C');
           END IF;
            x_return_status := 'U'; -- Retrieve the BEM from profiles
         else
           IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap... DAtes overlap FALSE','C');
           END IF;
            x_return_status := 'S'; -- If dates don't overlap follow the old code line
         end if;
      else
       IF L_DEBUG = 'Y' THEN
           gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.Budget_dates_overlap... DAtes overlap FALSE..FASLSE','C');
        END IF;
          x_return_status := 'S'; -- Bug 2587078

      end if ;


	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('*** End of GMS_SUMMARIZE_BUDGETS.GET_RESOURCE_LIST_ID ***','C');
	END IF;

   EXCEPTION
     -- Modified below code for bug 2587078
     WHEN NO_DATA_FOUND THEN
       x_return_status := 'E';
       x_err_stage := 'GMS_SUMMARIZE_BUDGETS.GET_RESOURCE_LIST_ID- In NO_DATA_FOUND exception';
       gms_error_pkg.gms_message( x_err_name => 'GMS_RESOURCE_LIST_ID_NOT_FOUND',
 	 			  x_err_code => x_err_code,
  			          x_err_buff => x_err_stage);
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;

      WHEN TOO_MANY_ROWS then
          x_return_status := 'U';

     WHEN others THEN
       x_return_status := 'U';
       x_err_stage := 'GMS_SUMMARIZE_BUDGETS.GET_RESOURCE_LIST_ID- In others exception';
       gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
       	 		          x_token_name1 => 'SQLCODE',
	 			  x_token_val1 => sqlcode,
	 			  x_token_name2 => 'SQLERRM',
 			          x_token_val2 => sqlerrm,
	 		          x_err_code => x_err_code,
			          x_err_buff => x_err_stage);
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_ERROR;
       -- End of changes for bug 2587078
   END get_resource_list_id;
----------------------------------------------------------------------------------------------
 -- Bug 2587078 : Modified parameter name from x_err_code to x_return_status
 --               to bring the code in consistency with existing grants code
 --               which uses x_err_code for tracking errors.

 FUNCTION draft_budget_exists(	x_project_id	NUMBER
				,x_return_status  OUT NOCOPY VARCHAR2 -- Bug 2587078
				,x_err_stage OUT NOCOPY VARCHAR2)  RETURN BOOLEAN
 IS
   x_err_code         NUMBER(15); -- Bug 2587078
   draft_budget_check NUMBER(15) := 0;

   BEGIN
     IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('*** Start of GMS_SUMMARIZE_BUDGETS.DRAFT_BUDGET_EXISTS ***','C');
     END IF;

     Select 	1
     into	draft_budget_check
     from	pa_budget_versions
     where	project_id = x_project_id
     and	budget_type_code = 'AC'
     and 	budget_status_code in ('W', 'S');

		x_return_status := 'S'; -- Bug 2587078
		RETURN TRUE;

     IF L_DEBUG = 'Y' THEN
        gms_error_pkg.gms_debug('*** End of GMS_SUMMARIZE_BUDGETS.DRAFT_BUDGET_EXISTS ***','C');
     END IF;

   EXCEPTION
        -- Modified below code for bug 2587078
	WHEN NO_DATA_FOUND THEN
	  x_return_status := 'S';
	  RETURN FALSE;
	WHEN TOO_MANY_ROWS THEN
	  x_return_status := 'E';
	  x_err_stage := 'GMS_SUMMARIZE_BUDGETS.DRAFT_BUDGET_EXISTS- In TOO_MANY_ROWS exception';
          gms_error_pkg.gms_message( x_err_name => 'GMS_DUP_DRAFT_SUB_BUDGET',
 	    			     x_err_code => x_err_code,
  			             x_err_buff => x_err_stage);
          fnd_msg_pub.add;
	  RETURN FALSE;
	WHEN OTHERS THEN
	  x_return_status := 'U';
	  x_err_stage := 'GMS_SUMMARIZE_BUDGETS.DRAFT_BUDGET_EXISTS- In others exception';
          gms_error_pkg.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
        	 		     x_token_name1 => 'SQLCODE',
	 			     x_token_val1 => sqlcode,
	 			     x_token_name2 => 'SQLERRM',
 			             x_token_val2 => sqlerrm,
	 		             x_err_code => x_err_code,
			             x_err_buff => x_err_stage);
          fnd_msg_pub.add;
	  RETURN FALSE;
        -- End of changes for bug 2587078
   END draft_budget_exists;
-----------------------------------------------------------------------------------------------------------
-- Bug 2386041
PROCEDURE set_global_info
 IS
 x_msg_count NUMBER;
 x_msg_data  VARCHAR2(2000);
 x_return_status VARCHAR2(2000);
 message_temp VARCHAR2(2000);
 BEGIN
--For Bug 4654211 :Operating unit Parameter added
 pa_interface_utils_pub.set_global_info(p_api_version_number => 1.0,
                                        p_responsibility_id => FND_GLOBAL.resp_id,
                                        p_user_id =>  FND_GLOBAL.user_id,
                                        p_resp_appl_id => FND_GLOBAL.resp_appl_id,
					p_operating_unit_id => PA_MOAC_UTILS.get_current_org_id,
                                        p_msg_count  => x_msg_count,
                                        p_msg_data  => x_msg_data,
                                        p_return_status   => x_return_status);
 IF x_return_status <>'S' THEN
   FOR i IN 1.. x_msg_count LOOP
     message_temp := gms_messages.get_message(X_Index => i, X_encoded=> 'T');
     fnd_message.set_encoded(message_temp);
     fnd_message.raise_error;
   END LOOP;
   fnd_message.set_name('GMS','GMS_PA_ENV_NOT_SET');
   fnd_message.raise_error;
  END IF;
 END set_global_info;
 -- Bug 2386041
------------------------------------------------------------------------------------------------


 PROCEDURE summarize_baselined_versions(x_project_id  		  NUMBER
					,x_time_phased_type_code  VARCHAR2
					,x_app_short_name 	  OUT NOCOPY VARCHAR2
					,RETCODE 		  OUT NOCOPY VARCHAR2
					,ERRBUF  		  OUT NOCOPY VARCHAR2)
 IS
   -- cursor changed to receive task_id and flag to rollup to resource group.
   -- Bug 3532920.
   cursor C1(p_task_id number, p_res_grp varchar2) IS
   select	gbl.period_name
   ,            decode(p_res_grp,
                       'Y', nvl(prl.parent_member_id, gra.resource_list_member_id),
                       gra.resource_list_member_id) resource_list_member_id
   ,	 	gra.task_id
   ,	 	sum(gbl.raw_cost) raw_cost
   ,	 	sum(gbl.burdened_cost) burdened_cost
   ,	 	sum(gbl.quantity) quantity
   from 	gms_budget_versions 	gbv
   , 	 	gms_resource_assignments gra
   ,	 	gms_budget_lines 	gbl
   ,		pa_resource_list_members prl --> Bug 2935048
   where 	gbv.project_id = x_project_id
   and	 	gbv.budget_version_id = gra.budget_version_id
   and	 	gra.resource_assignment_id = gbl.resource_assignment_id
   and	 	gbv.current_flag = 'Y'
   and          gbv.resource_list_id = prl.resource_list_id
   and          gra.resource_list_member_id = prl.resource_list_member_id
   and          gra.task_id = p_task_id
   group  by 	gbl.period_name,
                decode(p_res_grp,
                       'Y', nvl(prl.parent_member_id, gra.resource_list_member_id),
                       gra.resource_list_member_id),
                 gra.task_id;


   -- cursor changed to receive task_id and flag to rollup to resource group.
   -- Bug 3532920.
   cursor C2(p_task_id number, p_res_grp varchar2) IS
   select	gbl.start_date
   , 		gbl.end_date
   ,            decode(p_res_grp,
                       'Y', nvl(prl.parent_member_id, gra.resource_list_member_id),
                       gra.resource_list_member_id) resource_list_member_id
   ,	 	gra.task_id
   ,	 	sum(gbl.raw_cost) raw_cost
   ,	 	sum(gbl.burdened_cost) burdened_cost
   ,	 	sum(gbl.quantity) quantity
   from 	gms_budget_versions 	gbv
   , 	 	gms_resource_assignments gra
   ,	 	gms_budget_lines 	gbl
   ,            pa_resource_list_members prl --> Bug 2935048
   where 	gbv.project_id = x_project_id
   and	 	gbv.budget_version_id = gra.budget_version_id
   and	 	gra.resource_assignment_id = gbl.resource_assignment_id
   and	 	gbv.current_flag = 'Y'
   and          gbv.resource_list_id = prl.resource_list_id
   and          gra.resource_list_member_id = prl.resource_list_member_id
   and          gra.task_id = p_task_id
   group  by 	gbl.start_date, gbl.end_date,
                decode(p_res_grp,
                       'Y', nvl(prl.parent_member_id, gra.resource_list_member_id),
                       gra.resource_list_member_id),
                gra.task_id;


   -- cursor changed to receive task_id and flag to rollup to resource group.
   -- Bug 3532920.
   cursor C3(p_task_id number, p_res_grp varchar2) IS
   select       decode(p_res_grp,
		       'Y', nvl(prl.parent_member_id, gra.resource_list_member_id),
                       gra.resource_list_member_id) resource_list_member_id
   ,            gra.task_id
   ,            sum(gbl.raw_cost) raw_cost
   ,            sum(gbl.burdened_cost) burdened_cost
   ,            sum(gbl.quantity) quantity
   from         gms_budget_versions     gbv
   ,            gms_resource_assignments gra
   ,            gms_budget_lines        gbl
   ,            pa_resource_list_members prl --> Bug 2935048
   where        gbv.project_id = x_project_id
   and          gbv.budget_version_id = gra.budget_version_id
   and          gra.resource_assignment_id = gbl.resource_assignment_id
   and          gbv.current_flag = 'Y'
   and          gbv.resource_list_id = prl.resource_list_id
   and          gra.resource_list_member_id = prl.resource_list_member_id
   and          gra.task_id = p_task_id
   group  by    decode(p_res_grp,
                       'Y', nvl(prl.parent_member_id, gra.resource_list_member_id),
                       gra.resource_list_member_id),
                gra.task_id;

   cursor task_cur is
    select distinct gra.task_id
      from gms_resource_assignments gra,
           gms_budget_versions gbv
     where gra.project_id = x_project_id
       and gra.project_id = gbv.project_id
       and gbv.current_flag = 'Y'
       and gbv.budget_status_code = 'B';

--    x_err_code		VARCHAR2(1)   := NULL;
    x_err_code		NUMBER;
    x_err_stage 	VARCHAR2(200) := NULL;
    x_return_status	VARCHAR2(1);

    i			BINARY_INTEGER:=0;

    x_budget_lines_in_rec 		pa_budget_pub.budget_line_in_rec_type;
    x_budget_lines_in_tbl 		pa_budget_pub.budget_line_in_tbl_type;
    x_budget_lines_out_tbl		pa_budget_pub.budget_line_out_tbl_type;

    x_msg_data 		VARCHAR2(2000);
    x_msg_count		VARCHAR2(2000);
    x_text		VARCHAR2(2000);

    x_resource_list_id 	NUMBER(15)  := NULL;
    x_entry_method_code VARCHAR2(30) := NULL;
    x_entry_level_code  VARCHAR2(30); -- Added for Bug:2592747
    x_workflow_started VARCHAR2(1); -- required for baselining

    x_project_start_date   DATE;
    x_project_end_date     DATE;
    x_task_start_date   DATE; -- Added for bug 3372853
    x_task_end_date     DATE; -- Added for bug 3372853

    v_task_id		NUMBER;
    v_res_grp		varchar2(1);

    l_set_profile_success1 BOOLEAN; -- bug 3770971
    l_set_profile_success2 BOOLEAN; -- bug 3770971
	l_user_profile_value1           VARCHAR2(30);  -- bug 8214030
	l_user_profile_value2           VARCHAR2(30);  -- bug 8214030

-- This function returns 'Y' if the budget has both resource and resource group level budgeting.
-- Value returned is 'Y' if :
--       1. Budgeting is at resource group level only OR
--       2. Budgeting is at both resource and resource group level.
-- otherwise returns 'N', budgeting is at resource level only.
-- Bug 2935048.
--
-- Validation needs to happen at the task level if budget entry level
-- is task. Incase the budgeting level is Project, then task_id = 0.
-- Bug 3532920.

    function check_resource_budget_levels(x_task_id in number) return varchar2 is
    v_mixed_level_budget varchar2(1);
    begin
    select 'Y'
      into v_mixed_level_budget
      from dual
     where exists (select '1'
                     from pa_resource_list_members prl,
                          gms_resource_assignments gra,
                          gms_budget_versions gbv
                    where prl.resource_list_id = x_resource_list_id
                      and prl.resource_list_member_id = gra.resource_list_member_id
                      and gbv.budget_version_id = gra.budget_version_id
                      and gbv.current_flag = 'Y'
                      and prl.parent_member_id is null
                      and gra.project_id = x_project_id
                      and gra.task_id = x_task_id);

    return 'Y';
    exception
      when no_data_found then
        return 'N';
    end check_resource_budget_levels;

-- =================================================================================
  -- New procedure introduced for GMS enhancements
-- =================================================================================
Procedure Project_sum_high_level ( x_project_id NUMBER ) IS
 cursor C3_none_res IS
   select        prl.resource_list_member_id ,
                gbv.project_id ,
                sum(gbl.raw_cost) raw_cost
   ,            sum(gbl.burdened_cost) burdened_cost
   ,            sum(gbl.quantity) quantity
   from         gms_budget_versions     gbv
   ,            gms_resource_assignments gra
   ,            gms_budget_lines        gbl
   ,            pa_resource_list_members prl
   where        gbv.project_id = x_project_id
   and          gbv.budget_version_id = gra.budget_version_id
   and          gra.resource_assignment_id = gbl.resource_assignment_id
   and          gbv.current_flag = 'Y'
   and          G_pa_res_list_id_none = prl.resource_list_id
   and          gra.resource_list_member_id = prl.resource_list_member_id
   group by     prl.resource_list_member_id , gbv.project_id;
--   group by    gbv.project_id ;

cursor C3_res (p_pa_res_list_id  VARCHAR2 )  IS
   select
                gra.resource_list_member_id ,
            gbv.project_id
   ,            sum(gbl.raw_cost) raw_cost
   ,            sum(gbl.burdened_cost) burdened_cost
   ,            sum(gbl.quantity) quantity
   from         gms_budget_versions     gbv
   ,            gms_resource_assignments gra
   ,            gms_budget_lines        gbl
   ,            pa_resource_list_members prl
   where        gbv.project_id = x_project_id
   and          gbv.budget_version_id = gra.budget_version_id
   and          gra.resource_assignment_id = gbl.resource_assignment_id
   and          gbv.current_flag = 'Y'
   and          gbv.resource_list_id = prl.resource_list_id
   and          gra.resource_list_member_id = prl.resource_list_member_id
   group by    gra.resource_list_member_id, gbv.project_id ;

x_project_end_date     DATE ;

Begin
            SELECT start_date,
                   completion_date
            INTO   x_project_start_date,
                   x_project_end_date
            FROM   pa_projects_all
            WHERE  project_id = x_project_id;

            IF G_pa_res_list_id_none is not NULL then
            FOR  rec_c3_none_res in C3_none_res LOOP
                   EXIT when C3_none_res%NOTFOUND;
                   i := i + 1;
              x_budget_lines_in_rec.raw_cost := rec_c3_none_res.raw_cost;
              x_budget_lines_in_rec.quantity := rec_c3_none_res.quantity;
              x_budget_lines_in_rec.burdened_cost := rec_c3_none_res.burdened_cost;
              x_budget_lines_in_rec.budget_start_date := x_project_start_date;
              x_budget_lines_in_rec.budget_end_date := x_project_end_date;
              x_budget_lines_in_rec.resource_list_member_id := rec_c3_none_res.resource_list_member_id ; -- PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ;
              x_budget_lines_in_rec.pm_product_code := 'GMS';
              x_budget_lines_in_tbl(i) := x_budget_lines_in_rec;
            END LOOP;
            END IF ;
            -- Ajay Review comments
         IF G_pa_res_list_id is not NULL THEN
            FOR  rec_c3_res in C3_res(G_pa_res_list_id)  LOOP
                   EXIT when C3_res%NOTFOUND;
                   i := i + 1;
              x_budget_lines_in_rec.raw_cost := rec_c3_res.raw_cost;
              x_budget_lines_in_rec.quantity := rec_c3_res.quantity;
              x_budget_lines_in_rec.burdened_cost := rec_c3_res.burdened_cost;
              x_budget_lines_in_rec.budget_start_date := x_project_start_date;
              x_budget_lines_in_rec.budget_end_date := x_project_end_date;
              x_budget_lines_in_rec.resource_list_member_id :=  rec_c3_res.resource_list_member_id ; --PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ;
              x_budget_lines_in_rec.pm_product_code := 'GMS';
              x_budget_lines_in_tbl(i) := x_budget_lines_in_rec;
            END LOOP;
         END IF ;

End ;
-- ---------------------------------------------------------------------------------
    BEGIN

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('*** Start of GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS ***','C');
	END IF;
	x_return_status := 'S'; -- Initializing return status as Success.

      -- Bug 2386041
	 -- Since we are calling the PA_BUDGET_PUB utilities need to initialize some global variables
         set_global_info;
      -- Bug 2386041

      -- Bug 3770971..need to set the profile values for "PA: Cross Project User - Update" and
      -- "PA: Cross Project User - View". These values are lost after calling set_global_info
      -- which calls fnd_global.apps_initialize.

/* bug 8214030 changes start*/
                l_user_profile_value1 := fnd_profile.value_specific(
                						    NAME		=>	'PA_SUPER_PROJECT',
                						    USER_ID		=>	fnd_global.user_id,
                						    RESPONSIBILITY_ID	=>	fnd_global.resp_id,
                						    APPLICATION_ID	=>	fnd_global.resp_appl_id);

                if ((l_user_profile_value1 = 'N') OR  (l_user_profile_value1 is null)) then

                   BEGIN
                      SELECT profile_option_value
                      INTO   l_user_profile_value1
                      FROM   fnd_profile_options       p,
                             fnd_profile_option_values v
                      WHERE  p.profile_option_name = 'PA_SUPER_PROJECT'
                      AND    v.profile_option_id = p.profile_option_id
                      AND    v.level_id = 10004
                      AND    v.level_value = fnd_global.user_id;
                   EXCEPTION
                      WHEN no_data_found THEN
                         l_user_profile_value1 := null;
                      WHEN others THEN
                         l_user_profile_value1 := null;
                   END;
				   l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', 'Y', 'USER', fnd_global.user_id);
                end if;

                l_user_profile_value2 := fnd_profile.value_specific(
                						    NAME		=>	'PA_SUPER_PROJECT_VIEW',
                						    USER_ID		=>	fnd_global.user_id,
                						    RESPONSIBILITY_ID	=>	fnd_global.resp_id,
                						    APPLICATION_ID	=>	fnd_global.resp_appl_id);

                if ((l_user_profile_value2 = 'N') OR  (l_user_profile_value2 is null)) then
                   BEGIN
                      SELECT profile_option_value
                      INTO   l_user_profile_value2
                      FROM   fnd_profile_options       p,
                             fnd_profile_option_values v
                      WHERE  p.profile_option_name = 'PA_SUPER_PROJECT_VIEW'
                      AND    v.profile_option_id = p.profile_option_id
                      AND    v.level_id = 10004
                      AND    v.level_value = fnd_global.user_id;
                   EXCEPTION
                      WHEN no_data_found THEN
                         l_user_profile_value2 := null;
                      WHEN others THEN
                         l_user_profile_value2 := null;
                   END;
                   l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', 'Y', 'USER', fnd_global.user_id);
                end if;

/* bug 8214030 changes end*/
      -- Bug 3770971 end. Values will be set back in gms_budget_pub after summarize_budgets is done.

     -- Added for GMS enhancement 5583170
      SELECT start_date,
             completion_date
      INTO   x_project_start_date,
             x_project_end_date
      FROM   pa_projects_all
      WHERE  project_id = x_project_id;


      IF draft_budget_exists (x_project_id
			      ,x_return_status
			      ,x_err_stage) THEN

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Calling pa_budget_pub.delete_draft_budget','C');
	END IF;

        pa_budget_pub.delete_draft_budget(p_api_version_number => 1.0
				         ,p_init_msg_list => 'T'
					 ,p_msg_count => x_msg_count
					 ,p_msg_data => x_err_stage
					 ,p_return_status => x_return_status
					 ,p_pm_product_code => 'GMS' -- bug 3175909
					 ,p_pa_project_id => x_project_id
					 ,p_budget_type_code => 'AC');

          IF x_return_status <> 'S' THEN

	    x_err_code := 2;

	    FND_MESSAGE.PARSE_ENCODED (encoded_message => x_err_stage
			               ,app_short_name => x_app_short_name
			               ,message_name => x_text);
	    x_err_stage := x_text;

	    IF L_DEBUG = 'Y' THEN
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after delete draft; **************************','C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after delete draft; x_return_status = '||x_return_status,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after delete draft; x_err_stage = '||x_err_stage,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after delete draft; x_msg_count = '||x_msg_count,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after delete draft; **************************','C');
	    END IF;

            RAISE FND_API.G_EXC_ERROR;

          END IF;

      ELSE
          IF x_return_status <> 'S' THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;

      IF L_DEBUG = 'Y' THEN
	 gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Calling get_resource_list_id','C');
      END IF;

      get_resource_list_id (x_project_id
			   ,x_entry_method_code
			   ,x_resource_list_id
			   ,x_return_status
			   ,x_err_stage);


         -- ------------------------------------
         -- Added for GMS enhancements : 5583170
         -- ------------------------------------
     If x_return_status = 'U' then
        IF L_DEBUG = 'Y' THEN
         gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS-x_return_status  is  U', 'C');
        END IF;

     GMS_SUMMARIZE_BUDGETS  (x_project_id
                                  ,x_return_status
                                  ,x_err_stage  ) ;
        x_resource_list_id := NVL(G_pa_res_list_id,G_pa_res_list_id_none) ;


             IF L_DEBUG = 'Y' THEN
	         gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - G_project_bem  : '||G_project_bem ,'C');
              END IF;

             IF L_DEBUG = 'Y' THEN
	         gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - x_return_status   : '||x_return_status  ,'C');
              END IF;
     end if ;

  -- We should not proceed further as G_project_bem IS NULL ( when profiles are unset and different BEM are used )

  If G_project_bem IS NULL and x_resource_list_id IS NULL then

     x_return_status  := 'X' ;  -- We pass 'X' for the return status instead of 'S' as the award summarization has not happened. We will display
                                -- different message saying that only Budget baseline has happened.
     x_err_code := 2;
     RAISE FND_API.G_EXC_ERROR;
   RETURN ;
  end if ;

 If G_project_bem  IS NULL and x_resource_list_id IS NOT NULL  then -- Added for GMS enhancements
       IF L_DEBUG = 'Y' THEN
	  gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - x_time_phased_type_code : '||x_time_phased_type_code,'C');
	  gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Start of date calculation logic','C');
       END IF;

        i := 0;

        OPEN task_cur;
        LOOP
        FETCH task_cur INTO v_task_id;
        EXIT WHEN task_cur%NOTFOUND;

       -- GMS enhanceemnt for R12 : 5583170
	x_task_start_date := NULL ;
	x_task_end_date   := NULL ;
        IF v_task_id <> 0 THEN
	   SELECT 	nvl(start_date,x_project_start_date),
        	        nvl(completion_date,x_project_end_date)
             INTO  x_task_start_date,
                   x_task_end_date  /* Changed for bug 3372853 */
             FROM  pa_tasks
            WHERE  task_id = v_task_id;
	END IF ;

          v_res_grp := check_resource_budget_levels(v_task_id);

         if x_time_phased_type_code IN ('G', 'P') then

            FOR rec_c1 in C1(v_task_id, v_res_grp)
            LOOP
       	      EXIT when C1%NOTFOUND;
       	      i := i + 1;
       	      x_budget_lines_in_rec.resource_list_member_id := rec_c1.resource_list_member_id;
       	      x_budget_lines_in_rec.raw_cost := rec_c1.raw_cost;
	      x_budget_lines_in_rec.quantity := rec_c1.quantity;
	      x_budget_lines_in_rec.burdened_cost := rec_c1.burdened_cost;
	      x_budget_lines_in_rec.period_name := rec_c1.period_name;
	      x_budget_lines_in_rec.pa_task_id  := rec_c1.task_id;
	      x_budget_lines_in_rec.resource_list_member_id := rec_c1.resource_list_member_id;
	      x_budget_lines_in_rec.pm_product_code := 'GMS'; -- bug 3175909
       	      x_budget_lines_in_tbl(i) := x_budget_lines_in_rec;
            END LOOP;

       -- elsif x_time_phased_type_code IN ('R', 'N') then -- Bug 2466716
         elsif x_time_phased_type_code = 'R' then

            FOR rec_c2 in C2(v_task_id, v_res_grp)
            LOOP
       	      EXIT when C2%NOTFOUND;
       	      i := i + 1;
       	      x_budget_lines_in_rec.resource_list_member_id := rec_c2.resource_list_member_id;
       	      x_budget_lines_in_rec.raw_cost := rec_c2.raw_cost;
	      x_budget_lines_in_rec.quantity := rec_c2.quantity;
	      x_budget_lines_in_rec.burdened_cost := rec_c2.burdened_cost;
               -- GMS enahancement : 5583170
	      IF nvl(x_task_start_date, x_project_start_date) > rec_c2.start_date THEN
	    	 x_budget_lines_in_rec.budget_start_date := nvl(x_task_start_date, x_project_start_date);
	      ELSE
	         x_budget_lines_in_rec.budget_start_date := rec_c2.start_date;
	      end IF ;

	      IF nvl(x_task_end_date, x_project_end_date) < rec_c2.end_date THEN
	 	 x_budget_lines_in_rec.budget_end_date := nvl(x_task_end_date, x_project_end_date);
	      ELSE
	         x_budget_lines_in_rec.budget_end_date := rec_c2.end_date;
	      end IF ;

	     -- x_budget_lines_in_rec.budget_start_date := rec_c2.start_date;
	     -- x_budget_lines_in_rec.budget_end_date := rec_c2.end_date;

	      x_budget_lines_in_rec.pa_task_id  := rec_c2.task_id;
	      x_budget_lines_in_rec.resource_list_member_id := rec_c2.resource_list_member_id;
	      x_budget_lines_in_rec.pm_product_code := 'GMS'; -- bug 3175909
       	      x_budget_lines_in_tbl(i) := x_budget_lines_in_rec;
            END LOOP;

         elsif x_time_phased_type_code = 'N' then -- Bug 2466716

            SELECT start_date,
                   completion_date
            INTO   x_project_start_date,
                   x_project_end_date
            FROM   pa_projects_all
            WHERE  project_id = x_project_id;

            FOR rec_c3 in C3(v_task_id, v_res_grp)
            LOOP
       	      EXIT when C3%NOTFOUND;
       	      i := i + 1;

            -- Added the following SELECT and the IF block for Bug:2592747

	      SELECT distinct entry_level_code -- Added DISTINCT for Bug:2907692
	        INTO x_entry_level_code
	        FROM pa_budget_entry_methods pbem,
		     gms_budget_versions gbv
	       WHERE gbv.budget_entry_method_code = pbem.budget_entry_method_code
	         AND gbv.project_id = x_project_id
	         AND gbv.budget_status_code = 'B'
	         AND gbv.current_flag = 'Y';

	      if x_entry_level_code in ('L','M','T') then

	        SELECT 	nvl(start_date,x_project_start_date),
               		nvl(completion_date,x_project_end_date)
         	  INTO  x_task_start_date,
                	x_task_end_date  /* Changed for bug 3372853 */
         	  --INTO x_project_start_date,
                  --     x_project_end_date
         	  FROM  pa_tasks
         	 WHERE 	task_id = rec_c3.task_id;

		   /* if x_project_start_date is NULL or x_project_end_date is NULL then Changed for bug 3372853 */
		   if 	x_task_start_date is NULL or x_task_end_date is NULL then
                           x_err_stage := 'GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Error occurred while fetching dates';
		           gms_error_pkg.gms_message( x_err_name => 'GMS_BU_NO_TASK_PROJ_DATE',
 	 		 		  	      x_err_code => x_err_code,
	    			                      x_err_buff => x_err_stage);
                           fnd_msg_pub.add; -- Bug 2587078
			   RAISE FND_API.G_EXC_ERROR;

		   end if;

	      end if;

       	      x_budget_lines_in_rec.resource_list_member_id := rec_c3.resource_list_member_id;
       	      x_budget_lines_in_rec.raw_cost := rec_c3.raw_cost;
	      x_budget_lines_in_rec.quantity := rec_c3.quantity;
	      x_budget_lines_in_rec.burdened_cost := rec_c3.burdened_cost;
             --Bug 5489263
              if x_entry_level_code in ('L','M','T') then
                x_budget_lines_in_rec.budget_start_date := x_task_start_date;
                x_budget_lines_in_rec.budget_end_date := x_task_end_date;
              else
                x_budget_lines_in_rec.budget_start_date := x_project_start_date;
                x_budget_lines_in_rec.budget_end_date := x_project_end_date;
              end if;
              --Bug 5489263

	      /*x_budget_lines_in_rec.budget_start_date := x_project_start_date;
	      x_budget_lines_in_rec.budget_end_date := x_project_end_date; Changed for bug 3372853 */
	     /* x_budget_lines_in_rec.budget_start_date := x_task_start_date;
	      x_budget_lines_in_rec.budget_end_date := x_task_end_date; Commented for bug 5489263*/

	      x_budget_lines_in_rec.pa_task_id  := rec_c3.task_id;
	      x_budget_lines_in_rec.resource_list_member_id := rec_c3.resource_list_member_id;
	      x_budget_lines_in_rec.pm_product_code := 'GMS'; -- bug 3175909
       	      x_budget_lines_in_tbl(i) := x_budget_lines_in_rec;
            END LOOP;

        end if; -- time_phased_type_code if

        END LOOP; -- task_cur;

        CLOSE task_cur;

  ELSIF G_project_bem IS NOT NULL and x_return_status = 'S' THEN  -- ELSE for If G_project_bem is N NULL THEN

    Project_sum_high_level (x_project_id ) ;

  End if ;

       IF L_DEBUG = 'Y' THEN
	  gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - End of date calculation logic','C');
	  gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Calling pa_budget_pub.create_draft_budget','C');
       END IF;

         --Call budget API to create draft budget

 -- GMS enhancements  for R12 : 5583170
    If G_project_bem IS NOT NULL then

      select budget_entry_method_code
        into x_entry_method_code
        from pa_budget_entry_methods
    where budget_entry_method = G_project_bem ;
   end if ;

         pa_budget_pub.create_draft_budget(p_api_version_number  => 1.0
					   ,p_init_msg_list      => 'T'
					   ,p_msg_count          => x_msg_count
					   ,p_msg_data           => x_err_stage
					   ,p_return_status      => x_return_status
					   ,p_pm_product_code    => 'GMS'
					   ,p_pa_project_id      => x_project_id
					   ,p_budget_type_code   => 'AC'
					   ,p_entry_method_code  =>  x_entry_method_code
					   ,p_resource_list_id   => x_resource_list_id
					   ,p_budget_lines_in    => x_budget_lines_in_tbl
                                           ,p_budget_lines_out   => x_budget_lines_out_tbl
					   ,p_change_reason_code => null
					   ,p_pm_budget_reference=> null);


          IF x_return_status <>'S' THEN
		x_err_code := 2;


	    FND_MESSAGE.PARSE_ENCODED (	encoded_message => x_err_stage
					,app_short_name => x_app_short_name
					,message_name	=> x_text);
	    x_err_stage := x_text;

	    IF L_DEBUG = 'Y' THEN
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after create draft; ************************','C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after create draft; x_return_status = '||x_return_status,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after create draft; x_msg_count = '||x_msg_count,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after create draft; x_err_stage = '||x_err_stage,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after create draft; ************************','C');
	    END IF;

	    RAISE FND_API.G_EXC_ERROR;

          END IF;
-- R11i Change
-- Call PA's Budget API to Baseline this budget since the Project Budget should
-- automatically be baselined when the Award Budget is baselined.

       IF L_DEBUG = 'Y' THEN
	  gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - Calling pa_budget_pub.baseline_budget','C');
       END IF;

	pa_budget_pub.baseline_budget(	p_api_version_number => 1.0,
					p_init_msg_list => 'T',
					p_msg_count => x_msg_count,
					p_msg_data => x_err_stage,
					p_return_status => x_return_status,
					p_workflow_started => x_workflow_started,
					p_pm_product_code => 'GMS',
					p_pa_project_id => x_project_id,
					p_pm_project_reference => NULL,
					p_budget_type_code => 'AC');

	IF L_DEBUG = 'Y' THEN
		gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; ************************','C');
		gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; x_return_status = '||x_return_status,'C');
		gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; x_msg_count = '||x_msg_count,'C');
		gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; x_err_stage = '||x_err_stage,'C');
		gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; ************************','C');
	END IF;
         RETCODE := x_return_status ;  -- Added for GMS enhancement for R12 : 5583170

          IF x_return_status <>'S' THEN

          	x_err_code := 2;

	    FND_MESSAGE.PARSE_ENCODED (	encoded_message => x_err_stage
					,app_short_name => x_app_short_name
					,message_name	=> x_text);
	    x_err_stage := x_text;

	    IF L_DEBUG = 'Y' THEN
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; ************************','C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; x_return_status = '||x_return_status,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; x_msg_count = '||x_msg_count,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; x_err_stage = '||x_err_stage,'C');
	    	gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - after baseline budget; ************************','C');
	    END IF;

	    RAISE FND_API.G_EXC_ERROR;

          END IF;

	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('*** End of GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSION ***','C');
	END IF;

/* bug 8214030: resetting the profile values back */
                 if (l_set_profile_success1 = TRUE) then
                     l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', l_user_profile_value1, 'USER', fnd_global.user_id);
                 end if;
                 if (l_set_profile_success2 = TRUE) then
                     l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', l_user_profile_value2, 'USER', fnd_global.user_id);
                 end if;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	IF L_DEBUG = 'Y' THEN
	   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSION - In FND_API.G_EXC_ERROR exception','C');
	END IF;
        RETCODE := x_return_status;
      gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSIONS - x_return_status ----- : '|| x_return_status,'C');
	ERRBUF  := x_err_stage;
    /* bug 8214030: resetting the profile values back */
                 if (l_set_profile_success1 = TRUE) then
                     l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', l_user_profile_value1, 'USER', fnd_global.user_id);
                 end if;
                 if (l_set_profile_success2 = TRUE) then
                     l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', l_user_profile_value2, 'USER', fnd_global.user_id);
                 end if;
      when OTHERS THEN
	IF L_DEBUG = 'Y' THEN
   	   gms_error_pkg.gms_debug('GMS_SUMMARIZE_BUDGETS.SUMMARIZE_BASELINED_VERSION - In when Others exception','C');
	END IF;
        RETCODE := 'U';
        ERRBUF := (SQLERRM||' '||SQLCODE);
    /* bug 8214030: resetting the profile values back */
                 if (l_set_profile_success1 = TRUE) then
                     l_set_profile_success1 :=  fnd_profile.save('PA_SUPER_PROJECT', l_user_profile_value1, 'USER', fnd_global.user_id);
                 end if;
                 if (l_set_profile_success2 = TRUE) then
                     l_set_profile_success2 :=  fnd_profile.save('PA_SUPER_PROJECT_VIEW', l_user_profile_value2, 'USER', fnd_global.user_id);
                 end if;
    END summarize_baselined_versions;

END GMS_SUMMARIZE_BUDGETS;

/
