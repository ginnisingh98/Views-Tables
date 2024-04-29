--------------------------------------------------------
--  DDL for Package Body PA_RES_LIST_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_LIST_UPGRADE_PKG" as
/* $Header: PARTPLRB.pls 120.3.12010000.2 2008/11/28 09:01:24 vgovvala ship $ */

PROCEDURE RES_LIST_PLAN_LIST_WHEN_NULL( x_return_status  OUT NOCOPY VARCHAR2,			-- Added for 6710419
                                        x_msg_count      OUT NOCOPY NUMBER,
                                        x_msg_data       OUT NOCOPY VARCHAR2)

			IS

			cursor get_res_list_csr is
		    	select RESOURCE_LIST_ID from pa_resource_lists where migration_code is null
			and resource_list_id <> nvl(FND_PROFILE.VALUE('PA_FORECAST_RESOURCE_LIST'), -99);

	                tbl_res_id_list_tbl PA_PLSQL_DATATYPES.IdTabTyp;

	        	l_count 	     NUMBER;
			    l_debug_mode         VARCHAR2(1);
        		l_module_name        VARCHAR2(300) := 'PA_RES_LIST_UPGRADE_PKG' || 'RES_LIST_PLAN_LIST_WHEN_NULL';
	        	l_debug_level5       CONSTANT NUMBER := 5;
	        	l_data			 VARCHAR2(2000);
	        	l_msg_index_out  NUMBER;



BEGIN

            x_msg_count     := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            l_debug_mode    := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

            IF l_debug_mode = 'Y' THEN
                  pa_debug.set_curr_function( p_function   => 'RES_LIST_PLAN_LIST_WHEN_NULL',
                                              p_debug_mode => l_debug_mode );

            END IF;

	    OPEN get_res_list_csr;
            FETCH get_res_list_csr BULK COLLECT INTO tbl_res_id_list_tbl;
            CLOSE get_res_list_csr;

            IF (tbl_res_id_list_tbl.count > 0)
            THEN
            	FOR l_count in tbl_res_id_list_tbl.first..tbl_res_id_list_tbl.last
              	  LOOP

                    	pa_res_list_upgrade_pkg.res_list_to_plan_res_list(
                    						      P_Resource_List_Id   =>	tbl_res_id_list_tbl(l_count),
                                                                      p_commit             =>   'T',
                                                                      p_init_msg_list      =>   'T',
                                                                      x_return_status      =>    x_return_status,
                                                                      x_msg_count          =>    x_msg_count,
                                                                      x_msg_data           =>    x_msg_data );

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   		IF l_debug_mode = 'Y' THEN
                 			 pa_debug.g_err_stage:='Error occured when processing the Resource List  '||tbl_res_id_list_tbl(l_count);
                 	 		 pa_debug.write('Res_list_plan_list_when_null: ' || l_module_name,pa_debug.g_err_stage,5);
	                   	END IF;
		        	RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
              		END IF;

                   END LOOP;
            ELSE
                   RETURN;

            END IF;



EXCEPTION

       WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc  THEN
	       ROLLBACK;

               x_msg_count := FND_MSG_PUB.count_msg;
               IF x_msg_count = 1 THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                     (p_encoded        => FND_API.G_TRUE
                      ,p_msg_index      => 1
                      ,p_msg_count      => x_msg_count
                      ,p_msg_data       => x_msg_data
                      ,p_data           => l_data
                      ,p_msg_index_out  => l_msg_index_out);

                      x_msg_data := l_data;
                      x_msg_count := x_msg_count;

               ELSE

                 x_msg_count := x_msg_count;
               END IF;
                 x_return_status := FND_API.G_RET_STS_ERROR;
	       IF l_debug_mode = 'Y' THEN
                 pa_debug.reset_curr_function;
               END IF;


       WHEN OTHERS THEN

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := SQLERRM;
          FND_MSG_PUB.add_exc_msg( p_pkg_name        => 'PA_RES_LIST_UPGRADE_PKG'
                                  ,p_procedure_name  => 'RES_LIST_PLAN_LIST_WHEN_NULL');

          IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Error occured when processing the Resource List  '||tbl_res_id_list_tbl(l_count);
             pa_debug.write('Res_list_plan_list_when_null: ' || l_module_name,pa_debug.g_err_stage,5);
             pa_debug.reset_curr_function;
          END IF;
          ROLLBACK;
          RAISE;

END RES_LIST_PLAN_LIST_WHEN_NULL;

Procedure Res_List_To_Plan_Res_List(
  P_Resource_List_Id IN         pa_resource_lists_all_bg.resource_list_id%type,
  p_commit                    IN    VARCHAR2,
  p_init_msg_list             IN    VARCHAR2,
  X_Return_Status    OUT NOCOPY Varchar2,
  X_Msg_Count        OUT NOCOPY Number,
  X_Msg_Data         OUT NOCOPY Varchar2) IS

        cursor get_res_format_table_csr is
        SELECT f.res_format_id,f.resource_class_id,
        decode(f.group_res_type_code,'None',0,'REVENUE_CATEGORY',300,'EXPENDITURE_CATEGORY',
        100, 'ORGANIZATION',200, -1 ) + decode(f.res_type_code , 'EMPLOYEE',1,
        'EXPENDITURE_CATEGORY', 2, 'EXPENDITURE_TYPE', 3, 'JOB',4,'ORGANIZATION',
        5, 'REVENUE_CATEGORY',6,'EVENT_TYPE',7,'VENDOR', 8, 'UNCATEGORIZED',9,-1 )  +
        decode(nvl(f.labor_flag,'N'),'Y',0,15) map_seq
        FROM pa_restype_map_to_resformat f
        ORDER BY map_seq;

        cursor res_class_csr is
        SELECT fmt.resource_class_id,cls.resource_class_code,fmt.res_format_id,
        def.spread_curve_id, def.etc_method_code, def.mfc_cost_type_id,
        def.object_id,def.object_type,b.res_type_code
        FROM pa_res_formats_b fmt, pa_resource_classes_b cls,pa_plan_res_defaults def,
        pa_res_types_b b
        WHERE fmt.resource_class_flag = 'Y'
        AND fmt.resource_class_id = cls.resource_class_id
        AND def.resource_class_id = cls.resource_class_id
        AND fmt.res_type_id = b.res_type_id
        AND fmt.res_type_enabled_flag = 'Y'
        AND def.object_type       = 'CLASS';

        cursor get_res_list_id_csr(c_res_list_id pa_resource_lists_all_bg.resource_list_id%type) is
        SELECT b.resource_list_id,b.group_resource_type_id,b.uncategorized_flag,
   	b.last_update_login, b.creation_date, b.created_by, b.last_update_date,
   	b.last_updated_by, b.name,t.resource_type_code,
        decode(nvl(t.resource_type_code,'None'),'None',0, 'REVENUE_CATEGORY',300,
        'EXPENDITURE_CATEGORY',100, 'ORGANIZATION',200, 0 ) grp_seq
        FROM pa_resource_lists_all_bg b, pa_resource_types t
        WHERE t.resource_type_id(+) = b.group_resource_type_id and
        b.resource_list_id = c_res_list_id and
        EXISTS ( select 'X' from pa_resource_list_members m
        WHERE m.res_format_id is null and m.resource_list_id = b.resource_list_id
        OR b.uncategorized_flag = 'Y');

        cursor get_res_list_mem_id_csr(l_res_list_id pa_resource_lists_all_bg.resource_list_id%type) is
        SELECT m.resource_list_member_id,m.resource_type_id,m.parent_member_id,
        m.organization_id,m.revenue_category, m.expenditure_category,m.expenditure_type,
        decode(rl.uncategorized_flag,'Y',9,decode(nvl(t.resource_type_code,'None'),'None',0 , 'EMPLOYEE',1, 'EXPENDITURE_CATEGORY',
        2, 'EXPENDITURE_TYPE', 3, 'JOB',4,'ORGANIZATION',5, 'REVENUE_CATEGORY',6,'EVENT_TYPE',
        7,'VENDOR', 8, 'UNCATEGORIZED',9,-1 ))  + decode(nvl(track_as_labor_flag,'N'),'Y',0,15) res_seq,t.resource_type_code
        FROM pa_resource_list_members m,pa_resource_types t,
        pa_resource_lists_all_bg rl
        WHERE m.resource_list_id = l_res_list_id
        AND m.resource_type_id = t.resource_type_id(+)
        AND m.res_format_id is null
        AND NVL(t.resource_type_code,-99) not in ('UNCLASSIFIED', 'PROJECT_ROLE', 'HZ_PARTY')
        AND rl.resource_list_id = m.resource_list_id
        ORDER BY m.parent_member_id desc;

        cursor get_alias_csr is
        SELECT t.name,t.resource_class_id
        FROM pa_resource_classes_tl t,pa_resource_classes_b c
        WHERE t.resource_class_id = c.resource_class_id
        AND language = userenv('LANG');

        cursor res_list_form_exists_csr(c_res_list_id pa_resource_lists_all_bg.resource_list_id%type,c_res_for_id pa_res_formats_b.res_format_id%type) is
        SELECT 'Y'
        FROM pa_plan_rl_formats
        WHERE resource_list_id = c_res_list_id
        AND res_format_id = c_res_for_id;

        cursor res_list_exists_csr(c_res_list_id pa_resource_lists_all_bg.resource_list_id%type) is
        SELECT 'Y'
        FROM pa_resource_lists_all_bg
        WHERE resource_list_id = c_res_list_id
        AND migration_code = 'M';

        cursor chk_res_for_exists_csr(c_res_list_id pa_resource_lists_all_bg.resource_list_id%type) is
        SELECT 'Y'
        FROM pa_resource_lists_all_bg b
        WHERE resource_list_id = c_res_list_id
        AND exists ( select 'Y' from pa_resource_list_members m
        WHERE m.resource_list_id = b.resource_list_id and
        m.res_format_id is not null);

        TYPE res_class_csr_tbl is table of res_class_csr%ROWTYPE
        index by binary_integer;
        l_res_class_csr_tbl res_class_csr_tbl;

        TYPE res_alias_tbl is table of pa_resource_classes_tl.name%type
        index by binary_integer;
        l_res_alias_tbl res_alias_tbl;

        TYPE res_class_id_tbl is table of pa_resource_classes_b.resource_class_id%TYPE
        index by binary_integer;
        l_res_class_id_tbl res_class_id_tbl;

        TYPE res_class_flag_tbl is table of pa_res_formats_b.resource_class_flag%TYPE
        index by binary_integer;
        l_res_class_flag_tbl res_class_flag_tbl;

        TYPE res_for_id_tbl is TABLE of pa_res_formats_b.res_format_id%type
        index by binary_integer;
        l_res_for_id_tbl res_for_id_tbl;

        TYPE rev_cat_tbl is table of pa_resource_list_members.revenue_category%type
        index by binary_integer;
        l_rev_cat_tbl rev_cat_tbl;

        TYPE exp_cat_tbl is table of pa_resource_list_members.expenditure_category%type
        index by binary_integer;
        l_exp_cat_tbl exp_cat_tbl;

        TYPE org_id_tbl is table of pa_resource_list_members.organization_id%type
        index by binary_integer;
        l_org_id_tbl org_id_tbl;

        TYPE res_format_tbl is table of pa_resource_list_members.res_format_id%type
        index by binary_integer;
        l_res_format_tbl res_format_tbl;

        l_res_format_id_exists varchar2(1) := 'N';
        l_stage              VARCHAR2(240) :='';
        l_res_format_id      pa_res_formats_b.res_format_id%type;
        l_org_id             pa_resource_list_members.organization_id%type;
        l_rev_cat            pa_resource_list_members.revenue_category%type;
        l_exp_cat            pa_resource_list_members.expenditure_category%type;
        l_res_class_id       pa_resource_list_members.resource_class_id%type;
        l_res_class_flag     pa_resource_list_members.resource_class_flag%type;
        l_res_class_code     pa_resource_list_members.resource_class_code%type;
        l_etc_method_code    pa_resource_list_members.etc_method_code%TYPE;
        l_spread_curve_id    pa_resource_list_members.spread_curve_id%TYPE;
        l_object_id          pa_resource_list_members.object_id%TYPE;
        l_object_type        pa_resource_list_members.object_type%TYPE;
        --l_mfc_cost_type_id   pa_resource_list_members.mfc_cost_type_id%TYPE;
        l_fc_res_type_code   pa_resource_list_members.fc_res_type_code%type;
        l_inventory_item_id  pa_resource_list_members.inventory_item_id%TYPE :=  NULL;
        l_item_category_id   pa_resource_list_members.item_category_id%TYPE := NULL;
        l_migration_code     pa_resource_list_members.migration_code%TYPE := NULL;
        g_last_updated_by    pa_resource_list_members.last_updated_by%TYPE:= FND_GLOBAL.USER_ID;
        g_last_update_date   pa_resource_list_members.last_update_date%TYPE  := SYSDATE;
        g_creation_date      pa_resource_list_members.creation_date%TYPE     := SYSDATE;
        g_created_by         pa_resource_list_members.last_update_login%TYPE := FND_GLOBAL.USER_ID;
        g_last_update_login  pa_resource_list_members.last_update_login%TYPE := FND_GLOBAL.USER_ID;
        l_resource_id        pa_resource_list_members.resource_id%TYPE :=-99;
        l_incur_by_res_flag  pa_resource_list_members.incurred_by_res_flag%TYPE := 'N';
        l_incur_by_res_code  pa_resource_list_members.incur_by_res_class_code%TYPE := NULL;
        l_incur_by_role_id   pa_resource_list_members.incur_by_role_id%TYPE := NULL;
        l_track_as_labor_flag pa_resource_list_members.track_as_labor_flag%TYPE :=  NULL;
        l_alias               pa_resource_list_members.alias%TYPE :=  NULL;
        l_indx               NUMBER;
        l_indx_count         NUMBER;
        l_res_list_exists_flag varchar2(1) :='N';
        l_res_list_form_exists varchar2(1) :='N';
        l_wp_eligible_flag     varchar2(1) ;
        l_uom                 varchar2(30);
        res_list_upgraded EXCEPTION;
        null_res_list     EXCEPTION;
        null_res_class_id    EXCEPTION;
        null_res_class_code  EXCEPTION;
        null_res_format_id  EXCEPTION;
        null_alias          EXCEPTION;
        PRAGMA EXCEPTION_INIT(null_res_class_id,-20103);
        PRAGMA EXCEPTION_INIT(null_res_class_code,-20104);
        PRAGMA EXCEPTION_INIT(null_res_format_id,-20105);
        PRAGMA EXCEPTION_INIT(null_alias,-20106);
        PRAGMA EXCEPTION_INIT(res_list_upgraded,-20101);
        PRAGMA EXCEPTION_INIT(null_res_list,-20102);
        l_debug_mode varchar2(30);
        l_module_name VARCHAR2(100):= 'pa.plsql.pa_res_list_upgrade_pkg';
        l_msg_index_out                 NUMBER;
        l_data                          VARCHAR2(2000);
        l_msg_data                          VARCHAR2(2000);
        l_msg_count number;
        l_return_status varchar2(1);

        l_res_alias        varchar2(80);
        l_unique_alias     varchar2(1);
        l_exists_alias_id  number := Null;
        l_first_alias_id   number := Null;
        l_concat_no        number := 0;
        l_alias_concat     varchar2(30):= Null;
        l_updated_alias    pa_resource_list_members.alias%TYPE :=  NULL;
        l_res_parent_alias varchar2(80);
        l_parent_member_id number := Null;

        l_enabled_flag      varchar2(1); -- bug 3682103

begin

--dbms_output.put_line('R1');
--hr_utility.trace_on(NULL, 'RMUPG');
--hr_utility.trace('begin');

 IF (P_Resource_List_Id IS NULL)
  	THEN
  	    PA_RES_LIST_UPGRADE_PKG.RES_LIST_PLAN_LIST_WHEN_NULL(x_return_status  => X_Return_Status,
  	                                                         x_msg_count	  => X_Msg_Count,
  	                                                         x_msg_data       => X_Msg_Data);

 ELSE


       savepoint pa_res_list_upgrade_pkg;

       -- Bug 3802762, 30-JUN-2004, jwhite ------------------------------------
       -- Added if/then test for p_init_msg_list


       IF FND_API.TO_BOOLEAN( p_init_msg_list )
          THEN

             FND_MSG_PUB.initialize;

       END IF;

       -- End Bug 3802762 -----------------------------------------------------

       x_msg_count := 0;
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       pa_debug.init_err_stack('PA_RES_LIST_UPGRADE_PKG.RES_LIST_TO_PLAN_RES_LIST');
       fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
       l_debug_mode := NVL(l_debug_mode, 'Y');
       pa_debug.set_process('PLSQL','LOG',l_debug_mode);
--dbms_output.put_line('R2');
       IF l_debug_mode = 'Y' THEN
         pa_debug.g_err_stage := 'Entered Resource List to Plan Resource List Upgrade';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);

         pa_debug.g_err_stage := 'Checking for valid parameters';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
       END IF;
       -- Table for storing mapping code for each Resource Format Id
          if l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Mapping code for res format id into PL/SQL Table';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          end if;
       for l_get_res_format_table_csr in get_res_format_table_csr
       loop
           l_res_for_id_tbl(l_get_res_format_table_csr.map_seq) := l_get_res_format_table_csr.res_format_id;
           l_res_class_id_tbl(l_get_res_format_table_csr.res_format_id) := l_get_res_format_table_csr.resource_class_id;
       end loop;

--dbms_output.put_line('R3');
       -- Table for storing class realted information for each Resource Class Id
          if l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Resource Class Atrributes into PL/SQL Table';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
          end if;
       for l_res_class_csr in res_class_csr
       loop
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).resource_class_code := l_res_class_csr.resource_class_code;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).res_format_id := l_res_class_csr.res_format_id;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).spread_curve_id := l_res_class_csr.spread_curve_id;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).etc_method_code := l_res_class_csr.etc_method_code;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).mfc_cost_type_id :=l_res_class_csr.mfc_cost_type_id;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).object_id :=l_res_class_csr.object_id;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).object_type :=l_res_class_csr.object_type;
           l_res_class_csr_tbl(l_res_class_csr.resource_class_id).res_type_code :=l_res_class_csr.res_type_code;
       end loop;

--dbms_output.put_line('R4');

       -- Table for storing alias for each Resource Class Id
       for l_get_alias_csr in get_alias_csr
       loop
           l_res_alias_tbl(l_get_alias_csr.resource_class_id) := l_get_alias_csr.name;
       end loop;


       open chk_res_for_exists_csr(p_resource_list_id);
       fetch chk_res_for_exists_csr into l_res_format_id_exists;
       close chk_res_for_exists_csr;

       if (l_res_format_id_exists = 'Y') then
          return;
          --raise res_list_upgraded;
       end if;
       if (p_resource_list_id is null) then
            IF l_debug_mode = 'Y' THEN
               pa_debug.g_err_stage := 'Resource List='||to_char(p_resource_list_id);
               pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
            END IF;
          PA_UTILS.ADD_MESSAGE(p_app_short_name=> 'PA',
                               p_msg_name      => 'PA_FP_INV_PARAM_PASSED');
          RAISE PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
       end if;

       -- Check if the in parameter is not null
--dbms_output.put_line('R5');

       -- Loop for Resource List Header
       for l_get_res_list_id_csr in  get_res_list_id_csr(p_resource_list_id)
       loop

            -- Loop for Resource List Member
            for l_get_res_list_mem_id_csr in get_res_list_mem_id_csr(l_get_res_list_id_csr.resource_list_id)
            loop
               --dbms_output.put_line ('L1');

                l_res_format_id     := NULL;
                l_res_class_id      := NULL;
                l_res_class_code    := NULL;
                l_etc_method_code   :=NULL;
                l_spread_curve_id   :=NULL;
                l_object_id         :=NULL;
                l_object_type       :=NULL;
                --l_mfc_cost_type_id  :=NULL;
                l_migration_code    :=NULL;
                l_org_id            := NULL;
                l_rev_cat           := NULL;
                l_exp_cat           := NULL;
                l_alias             := NULL;
                l_wp_eligible_flag  := NULL;
                l_uom               := NULL;
                l_enabled_flag      := Null; -- bug 3682103


                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 1';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                -- ITEM NO 1
                if (l_get_res_list_mem_id_csr.parent_member_id  is null) then
                     if(l_res_for_id_tbl.exists(l_get_res_list_mem_id_csr.res_seq)) then
                         l_res_format_id := l_res_for_id_tbl(l_get_res_list_mem_id_csr.res_seq);
                     end if;
                else
                         if(l_res_for_id_tbl.exists(l_get_res_list_id_csr.grp_seq + l_get_res_list_mem_id_csr.res_seq)) then
                             l_res_format_id := l_res_for_id_tbl(l_get_res_list_id_csr.grp_seq +
                                                l_get_res_list_mem_id_csr.res_seq );
                         end if;
                end if;


                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 2';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                -- ITEM NO 2
                -- Get expenditure,revenue,organization of the parent and copy to its children
                if (l_get_res_list_mem_id_csr.parent_member_id is null) then
                     l_rev_cat := l_get_res_list_mem_id_csr.revenue_category;
                     l_exp_cat := l_get_res_list_mem_id_csr.expenditure_category;
                     l_org_id  := l_get_res_list_mem_id_csr.organization_id;
                     l_rev_cat_tbl(l_get_res_list_mem_id_csr.resource_list_member_id) :=  l_get_res_list_mem_id_csr.revenue_category;
                     l_exp_cat_tbl(l_get_res_list_mem_id_csr.resource_list_member_id) :=  l_get_res_list_mem_id_csr.expenditure_category;
                     l_org_id_tbl(l_get_res_list_mem_id_csr.resource_list_member_id)  :=  l_get_res_list_mem_id_csr.organization_id;
                else
                     if ( l_rev_cat_tbl.exists(l_get_res_list_mem_id_csr.parent_member_id)) then
                     	l_rev_cat := l_rev_cat_tbl(l_get_res_list_mem_id_csr.parent_member_id);
                     end if;
                     if ( l_exp_cat_tbl.exists(l_get_res_list_mem_id_csr.parent_member_id)) then
                     	l_exp_cat := l_exp_cat_tbl(l_get_res_list_mem_id_csr.parent_member_id);
                     end if;
                     if ( l_org_id_tbl.exists(l_get_res_list_mem_id_csr.parent_member_id)) then
                     	l_org_id  := l_org_id_tbl(l_get_res_list_mem_id_csr.parent_member_id);
                     end if;
                end if;



                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 3';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                   -- ITEM NO 3
                   -- Store resource format id into a table to get all distinct resource format Id's
                   if (l_res_format_id is not null) then
                        l_res_format_tbl(l_res_format_id) := l_res_format_id;
                   end if;

                   -- Get resource class id and resource class code for each resource format id
                   if(l_res_class_id_tbl.exists(l_res_format_id)) then
                       l_res_class_id := l_res_class_id_tbl(l_res_format_id);
                   end if;

                   --dbms_output.put_line('l_res_class_id :' || l_res_class_id);
                   --dbms_output.put_line('l_res_format_id :' || l_res_format_id);

                   if (l_res_class_csr_tbl.exists(l_res_class_id)) then
                       l_res_class_code := l_res_class_csr_tbl(l_res_class_id).resource_class_code;
                   end if;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 5';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                -- ITEM NO 5
                   -- Get Resource class related Information for each Resource Class Id
                   if(l_res_class_csr_tbl.exists(l_res_class_id)) then
                         l_object_id          :=  l_res_class_csr_tbl(l_res_class_id).object_id;
                         l_object_type        :=  l_res_class_csr_tbl(l_res_class_id).object_type;
                         l_spread_curve_id    :=  l_res_class_csr_tbl(l_res_class_id).spread_curve_id;
                         l_etc_method_code    :=  l_res_class_csr_tbl(l_res_class_id).etc_method_code;
                         -- l_mfc_cost_type_id   :=  l_res_class_csr_tbl(l_res_class_id).mfc_cost_type_id;
                   end if;

                   if(l_get_res_list_id_csr.uncategorized_flag = 'Y') then
                      l_res_class_id := 4;
                      l_res_class_code := 'FINANCIAL_ELEMENTS';
                   end if;

                   if(l_get_res_list_id_csr.resource_type_code in ('REVENUE_CATEGORY', 'EXPENDITURE_CATEGORY')) then

                      -- Begin bug 3682103
                      if (l_get_res_list_mem_id_csr.resource_type_code in ('EVENT_TYPE',
                                                                           'EXPENDITURE_CATEGORY',
                                                                           'EXPENDITURE_TYPE',
                                                                           'REVENUE_CATEGORY') And
                          l_get_res_list_mem_id_csr.parent_member_id IS NOT NULL ) then
                            l_fc_res_type_code := l_get_res_list_mem_id_csr.resource_type_code;

                            If ((l_get_res_list_id_csr.resource_type_code = 'REVENUE_CATEGORY' AND
                                 l_get_res_list_mem_id_csr.resource_type_code = 'EXPENDITURE_CATEGORY') OR
                                (l_get_res_list_id_csr.resource_type_code = 'EXPENDITURE_CATEGORY' AND
                                 l_get_res_list_mem_id_csr.resource_type_code = 'REVENUE_CATEGORY') OR
                                (l_get_res_list_id_csr.resource_type_code = 'EXPENDITURE_CATEGORY' AND
                                 l_get_res_list_mem_id_csr.resource_type_code = 'EVENT_TYPE')) THEN
                                    l_enabled_flag := 'N';
                            End If;
                            l_exp_cat      := Null;
                            l_rev_cat      := Null;
                      -- end bug 3682103
                      else
                            l_fc_res_type_code := l_get_res_list_id_csr.resource_type_code;
                      end if;

                   else

                      if (l_get_res_list_mem_id_csr.resource_type_code in ('EVENT_TYPE',
                                                                           'EXPENDITURE_CATEGORY',
                                                                           'EXPENDITURE_TYPE',
                                                                           'REVENUE_CATEGORY')) Then
                            l_fc_res_type_code := l_get_res_list_mem_id_csr.resource_type_code;
                      else
                            l_fc_res_type_code := null;
                      end if;

                   end if;
                    if(nvl(l_fc_res_type_code,'') = 'REVENUE_CATEGORY' or nvl(l_fc_res_type_code,'') = 'EVENT_TYPE') then
                       l_wp_eligible_flag := 'N';
                   else
                       l_wp_eligible_flag := 'Y';
                   end if;

                   if (l_res_format_id is null) then
                      l_stage := 'Resource Format Id is null for the resource list' || l_get_res_list_id_csr.resource_list_id;
                      RAISE null_res_format_id;
                   end if;
                   if (l_res_class_id is null) then
                      l_stage := 'Resource Class Id is null';
                      RAISE null_res_class_id;
                   end if;
                   if (l_res_class_code is null) then
                      l_stage := 'Resource Class Code is null';
                      RAISE null_res_class_code;
                   end if;

                   if l_res_class_code = 'PEOPLE' THEN
                      l_uom := 'HOURS';
                   elsif l_res_class_code = 'FINANCIAL_ELEMENTS' THEN
                   IF l_get_res_list_mem_id_csr.expenditure_type IS NOT NULL THEN
                       SELECT unit_of_measure
                       INTO l_uom
                       FROM pa_expenditure_types et
                       WHERE et.expenditure_type = l_get_res_list_mem_id_csr.expenditure_type
                       AND ROWNUM = 1;
                  else
                      l_uom := 'DOLLARS';
                  end if;
                  end if;

                 SELECT nvl(incurred_by_enabled_flag, 'N')
                 INTO   l_incur_by_res_flag
                 FROM   pa_res_formats_b
                 WHERE  res_format_id = l_res_format_id;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Updating pa_resource_list_members table';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                -- Update each resource list member with the info obtained above
                update pa_resource_list_members
                set res_format_id              = l_res_format_id,
                    revenue_category           = nvl(l_rev_cat,l_get_res_list_mem_id_csr.revenue_category),
                    expenditure_category       = nvl(l_exp_cat,l_get_res_list_mem_id_csr.expenditure_category),
                    organization_id            = nvl(l_org_id,l_get_res_list_mem_id_csr.organization_id),
                    resource_class_id          = l_res_class_id,
                    resource_class_code        = l_res_class_code,
                    spread_curve_id            = l_spread_curve_id,
                    mfc_cost_type_id           = NULL,
                    etc_method_code            = l_etc_method_code,
                    resource_class_flag        = decode(l_get_res_list_id_csr.uncategorized_flag,'Y','Y','N'),
                    object_id                  = l_get_res_list_id_csr.resource_list_id,
                    object_type                = 'RESOURCE_LIST',
                    inventory_item_id          = null,
                    item_category_id           = null,
                    migration_code             = 'M',
                    fc_res_type_code           = l_fc_res_type_code,
                    wp_eligible_flag           = l_wp_eligible_flag,
                    unit_of_measure            = l_uom,
                    incurred_by_res_flag       = l_incur_by_res_flag,
                    record_version_number      = 1,
                    enabled_flag                = nvl(l_enabled_flag, enabled_flag)
                where resource_list_member_id = l_get_res_list_mem_id_csr.resource_list_member_id;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Get alias and parent_member_id from pa_resource_list_members';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;

                Select
                       alias,
                       parent_member_id
                Into
                       l_res_alias,
                       l_parent_member_id
                from
                       pa_resource_list_members
                where
                       resource_list_member_id = l_get_res_list_mem_id_csr.resource_list_member_id;

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Check if alias is unique by calling Pa_Planning_Resource_Pvt.Check_pl_alias_unique()';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                l_unique_alias := Pa_Planning_Resource_Pvt.Check_pl_alias_unique(
                                          p_resource_list_id        => l_get_res_list_id_csr.resource_list_id,
                                          p_resource_alias          => l_res_alias,
                                          p_resource_list_member_id => l_get_res_list_mem_id_csr.resource_list_member_id,
                                          p_object_type             => 'RESOURCE_LIST',
                                          p_object_id               => l_get_res_list_id_csr.resource_list_id);

                IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Alias is unique ' || l_unique_alias ;
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                If l_unique_alias = 'N' Then

                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Get parent alias';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     end if;
                     select
                           alias
                     Into
                           l_res_parent_alias
                     from
                           pa_resource_list_members
                     where
                           resource_list_member_id = l_parent_member_id;

                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Concatenate the parent and child alias and substr to 80 characters.';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     end if;
                     l_res_alias := substr(l_res_parent_alias || ' - ' || l_res_alias,1,80);

                     IF l_debug_mode = 'Y' THEN
                          pa_debug.g_err_stage := 'Update the pa_resource_list_members record with the combined alias';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                     end if;
                     update pa_resource_list_members
                     set alias = l_res_alias
                     where resource_list_member_id = l_get_res_list_mem_id_csr.resource_list_member_id;

                End If;

            end loop;
            -- Resource List Member Loop ends here
--dbms_output.put_line('R10');

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 4';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
              --ITEM N0 4
              -- For each resource list header create new four class resource list members
                        l_indx_count := l_res_class_csr_tbl.count;
                        l_indx       := l_res_class_csr_tbl.first;
                        l_res_list_exists_flag := 'N';
                        open res_list_exists_csr(l_get_res_list_id_csr.resource_list_id);
                        fetch res_list_exists_csr into l_res_list_exists_flag;
                        close res_list_exists_csr;

                        --dbms_output.put_line('R10.1');

                        if (l_res_list_exists_flag = 'N') then
                        while(l_indx_count > 0)
                        loop
                        if not((upper(l_get_res_list_id_csr.uncategorized_flag) like 'Y' and
                        (l_res_class_csr_tbl(l_indx).resource_class_code like 'FINANCIAL_ELEMENTS'))) then
                           if(l_res_class_csr_tbl(l_indx).resource_class_code like 'PEOPLE') then
                              l_track_as_labor_flag := 'Y';
                           else
                              l_track_as_labor_flag := 'N';
                           end if;
                        --dbms_output.put_line('R10.2: l_res_class_id: ' || l_res_class_id);
                        --dbms_output.put_line('R10.2: l_indx: ' || l_indx);
                                        if (l_res_alias_tbl.exists(l_indx)) then
                                            l_alias := l_res_alias_tbl(l_indx);
                                        end if;
                        --dbms_output.put_line('R10.3');
                                        if (l_alias is null) then
                                           --dbms_output.put_line('R10.4');
                                           l_stage := 'ALIAS IS NULL';
                                           RAISE null_alias;
                                        end if;
                           IF l_debug_mode = 'Y' THEN
                              pa_debug.g_err_stage := 'Inserting into pa_resource_list_members table';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                           end if;


                           -- Bug 4766426 - check for duplicate alias
                           -- of these resources.
                           -- Added a loop to avoid duplicate of alias
                           -- if already existing in the database.
                           l_first_alias_id  := NULL;
                           l_exists_alias_id := NULL;
                           l_concat_no       := 0;
                           l_alias_concat    := NULL;
                           l_updated_alias   := l_alias;

                           LOOP

                               BEGIN
                               SELECT resource_list_member_id
                               INTO   l_exists_alias_id
                               FROM   pa_resource_list_members
                               WHERE  alias = l_updated_alias||l_alias_concat
                               AND    resource_list_id =
                                      l_get_res_list_id_csr.resource_list_id
                               AND    object_type = 'RESOURCE_LIST'
                               AND    object_id =
                                      l_get_res_list_id_csr.resource_list_id;

                               EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                 l_updated_alias := l_updated_alias||l_alias_concat;
                                 EXIT;
                               END;

                               IF l_exists_alias_id IS NOT NULL THEN
                                  IF l_first_alias_id IS NULL THEN
                                     l_first_alias_id := l_exists_alias_id;
                                  END IF;
                                  l_concat_no := l_concat_no + 1;
                                  l_alias_concat := '-'||l_concat_no;
                               END IF;

                           END LOOP;


                           IF l_exists_alias_id IS NOT NULL THEN
                              UPDATE pa_resource_list_members
                              SET    alias = l_updated_alias
                              WHERE  resource_list_member_id =
                                            l_first_alias_id;
                           END IF;
                           /* End of fix for bug 4766426 */
                           --dbms_output.put_line('R10.5');

            		   insert into pa_resource_list_members(
             			RESOURCE_LIST_MEMBER_ID,
	             		RESOURCE_LIST_ID,
             			RESOURCE_ID,
             			ALIAS,
             			PARENT_MEMBER_ID,
             			SORT_ORDER,
             			MEMBER_LEVEL,
             			DISPLAY_FLAG,
             			ENABLED_FLAG,
             			TRACK_AS_LABOR_FLAG,
             			LAST_UPDATED_BY,
             			LAST_UPDATE_DATE,
             			CREATION_DATE,
             			CREATED_BY,
             			LAST_UPDATE_LOGIN,
             			OBJECT_TYPE,
             			OBJECT_ID,
             			RESOURCE_CLASS_ID,
             			RESOURCE_CLASS_CODE,
             			RES_FORMAT_ID,
             			SPREAD_CURVE_ID,
             			ETC_METHOD_CODE,
             			MFC_COST_TYPE_ID,
                        	RESOURCE_CLASS_FLAG,
             			INVENTORY_ITEM_ID,
             			ITEM_CATEGORY_ID,
             			MIGRATION_CODE ,
             			INCURRED_BY_RES_FLAG,
             			INCUR_BY_RES_CLASS_CODE,
             			INCUR_BY_ROLE_ID,
             			RES_TYPE_CODE,
                        	PERSON_ID ,
 				JOB_ID    ,
				ORGANIZATION_ID,
				VENDOR_ID      ,
 				EXPENDITURE_TYPE    ,
 				EVENT_TYPE          ,
 				NON_LABOR_RESOURCE  ,
 				EXPENDITURE_CATEGORY,
 				REVENUE_CATEGORY    ,
 				NON_LABOR_RESOURCE_ORG_ID ,
 				EVENT_TYPE_CLASSIFICATION ,
 				SYSTEM_LINKAGE_FUNCTION  ,
                                WP_ELIGIBLE_FLAG,
                                UNIT_OF_MEASURE,
 				PROJECT_ROLE_ID,
                                RECORD_VERSION_NUMBER)
           		        (select  pa_resource_list_members_s.NEXTVAL,
             		        l_get_res_list_id_csr.resource_list_id,
             			l_resource_id,
             			l_alias,
            	 		null,
      		                1,
             			1,
             			'Y',
             			'Y',
             			l_track_as_labor_flag,
            			g_last_updated_by,
            			g_last_update_date,
            			g_creation_date,
            			g_created_by,
            			g_last_update_login,
            			'RESOURCE_LIST',
            			l_get_res_list_id_csr.resource_list_id,
         			l_indx,
         			l_res_class_csr_tbl(l_indx).resource_class_code,
         			l_res_class_csr_tbl(l_indx).res_format_id,
         			l_res_class_csr_tbl(l_indx).spread_curve_id ,
         			l_res_class_csr_tbl(l_indx).etc_method_code ,
         			NULL, --l_res_class_csr_tbl(l_indx).mfc_cost_type_id,
                    	    	'Y',
         			l_inventory_item_id,
         			l_item_category_id ,
         			'N',
                        	'N', --l_incur_by_res_flag,
                        	l_incur_by_res_code,
                        	l_incur_by_role_id,
         			l_res_class_csr_tbl(l_indx).res_type_code ,
                        	null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
				null,
                                 'Y',
                                decode(l_res_class_csr_tbl(l_indx).resource_class_code,
                                     'PEOPLE','HOURS',
                                     'FINANCIAL_ELEMENTS','DOLLARS',
                                     'MATERIAL_ITEMS','DOLLARS',
                                     'EQUIPMENT','HOURS'),
				null,
                                1
                        	from dual);

                                --dbms_output.put_line('R10.6');
                        end if;
                         if ( l_res_class_csr_tbl(l_indx).res_format_id is not null) then
         	        	l_res_format_tbl(l_res_class_csr_tbl(l_indx).res_format_id) := l_res_class_csr_tbl(l_indx).res_format_id;
                        end if;
                        l_indx_count := l_indx_count - 1;
                        l_indx := l_res_class_csr_tbl.next(l_indx);
                        end loop;
                        end if;
                        -- Item No 4 Loop ends here

--dbms_output.put_line('R11');

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 7';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                --ITEM NO 7
                -- Insert into this table with distinct resource_list_id and resource_format_id's
                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Inserting into pa_plan_rl_formats table';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                if (l_res_format_tbl.count > 0) then
                for i in l_res_format_tbl.first..l_res_format_tbl.last
                loop
                	if (l_res_format_tbl.exists(i)) then
                            l_res_list_form_exists := 'N';
                           open res_list_form_exists_csr(l_get_res_list_id_csr.resource_list_id,l_res_format_tbl(i));
                           fetch res_list_form_exists_csr into l_res_list_form_exists;
                           close res_list_form_exists_csr;
                           if (l_res_list_form_exists = 'N' ) then
                		insert into pa_plan_rl_formats (
        			PLAN_RL_FORMAT_ID,
        			RESOURCE_LIST_ID,
        			RES_FORMAT_ID   ,
        			LAST_UPDATE_DATE,
        			LAST_UPDATED_BY ,
        			CREATION_DATE   ,
        			CREATED_BY      ,
        			LAST_UPDATE_LOGIN,
        			RECORD_VERSION_NUMBER
  			      	)
        			select
        			pa_plan_rl_formats_s.nextval,
        			l_get_res_list_id_csr.resource_list_id,
        			l_res_format_tbl(i)   ,
        			g_last_update_date,
        			g_last_updated_by ,
        			g_creation_date   ,
        			g_created_by      ,
        			g_last_update_login,
        			1
        			from dual;
                           end if;
                	end if;
                end loop;
                -- Item No 7 loop ends here.
                l_res_format_tbl.delete;
                end if;

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Entering Item No 8';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
            --ITEM NO 9

                 IF l_debug_mode = 'Y' THEN
                    pa_debug.g_err_stage := 'Updating pa_resource_lists_all_bg table';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL3);
                end if;
                   -- Update migration code for each resource list header
                   update pa_resource_lists_all_bg
                   set control_flag     = 'Y',
                       use_for_wp_flag  = 'Y',
                       migration_code   =  'M',
                       record_version_number = 1
                       where resource_list_id = l_get_res_list_id_csr.resource_list_id;

      PA_PLANNING_RESOURCE_UTILS.POPULATE_LIST_INTO_TL(
                        p_resource_list_id => l_get_res_list_id_csr.resource_list_id,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data
                        );
                        if (x_return_status <> 'S') then
                           raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        end if;
      PA_RBS_UTILS.UPGRADE_LIST_TO_RBS(
                        p_resource_list_id => l_get_res_list_id_csr.resource_list_id,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data
                        );
                        if (x_return_status <> 'S') then
                           raise PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc;
                        end if;


       -- Bug 3802762, 30-JUN-2004, jwhite ------------------------------------
       -- Added if/then test for p_commit.

          IF FND_API.TO_BOOLEAN( p_commit )
             THEN
                  COMMIT;
          END IF;


       -- End Bug 3802762, 30-JUN-2004, jwhite --------------------------------




       end loop;
END IF;     -- P_Resource_List_Id IS NULL
      -- Resource List Header Loop ends
--hr_utility.trace('end');
--hr_utility.trace('x_return_status is ' || x_return_status);
--dbms_output.put_line('R12');


      EXCEPTION
      WHEN null_res_format_id OR null_res_class_id OR null_res_class_code OR null_alias THEN
       l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded         => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:= l_stage;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
         x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.write_file('RES_LIST_TO_PLAN_RES_LIST: Upgrade has failed for the resource list '|| p_resource_list_id,5);
        pa_debug.write_file('RES_LIST_TO_PLAN_RES_LIST:: Failure Reason:'||x_msg_data,5);
        pa_debug.reset_err_stack;
        ROLLBACK to PA_RES_LIST_UPGRADE_PKG;
        RAISE;
      rollback;
      WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc or RES_LIST_UPGRADED THEN
       l_msg_count := FND_MSG_PUB.count_msg;
        IF l_msg_count = 1 THEN
             PA_INTERFACE_UTILS_PUB.get_messages
                   (p_encoded         => FND_API.G_TRUE
                    ,p_msg_index      => 1
                    ,p_msg_count      => l_msg_count
                    ,p_msg_data       => l_msg_data
                    ,p_data           => l_data
                    ,p_msg_index_out  => l_msg_index_out);
             x_msg_data := l_data;
             x_msg_count := l_msg_count;
        ELSE
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Invalid Arguments Passed';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;
         x_return_status:= FND_API.G_RET_STS_ERROR;
        pa_debug.write_file('RES_LIST_TO_PLAN_RES_LIST: Upgrade has failed for the resource list '|| p_resource_list_id,5);
        pa_debug.write_file('RES_LIST_TO_PLAN_RES_LIST:: Failure Reason:'||x_msg_data,5);
        pa_debug.reset_err_stack;
        ROLLBACK to PA_RES_LIST_UPGRADE_PKG;
        RAISE;
      WHEN OTHERS THEN
        if (get_res_format_table_csr%ISOPEN) then
            close get_res_format_table_csr;
        end if;

        if (res_class_csr%ISOPEN) then
            close res_class_csr;
        end if;

        if (get_res_list_id_csr%ISOPEN) then
            close get_res_list_id_csr;
        end if;

        if (get_res_list_mem_id_csr%ISOPEN) then
           close get_res_list_mem_id_csr;
        end if;

        if (get_alias_csr%ISOPEN) then
           close get_alias_csr;
        end if;

        if (res_list_form_exists_csr%ISOPEN) then
           close res_list_form_exists_csr;
        end if;

        if (res_list_exists_csr%ISOPEN) then
            close res_list_exists_csr;
         end if;

         if (chk_res_for_exists_csr%ISOPEN) then
             close chk_res_for_exists_csr;
         end if;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count     := 1;
        x_msg_data      := SQLERRM;

        FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_RES_LIST_UPGRADE_PKG',p_procedure_name  => 'RES_LIST_TO_PLAN_RES_LIST');
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage:='Unexpected Error'||SQLERRM;
             pa_debug.write(l_module_name,pa_debug.g_err_stage,PA_FP_CONSTANTS_PKG.G_DEBUG_LEVEL5);
        END IF;

        pa_debug.write_file('RES_LIST_TO_PLAN_RES_LIST: Upgrade has failed for the resource list '||p_resource_list_id,5);
        pa_debug.write_file('RES_LIST_TO_PLAN_RES_LIST: Failure Reason:'||pa_debug.G_Err_Stack,5);
        pa_debug.reset_err_stack;
        ROLLBACK to PA_RES_LIST_UPGRADE_PKG;
        RAISE;
end RES_LIST_TO_PLAN_RES_LIST;

END PA_RES_LIST_UPGRADE_PKG;

/
