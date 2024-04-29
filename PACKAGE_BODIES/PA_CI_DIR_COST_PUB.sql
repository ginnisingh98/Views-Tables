--------------------------------------------------------
--  DDL for Package Body PA_CI_DIR_COST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CI_DIR_COST_PUB" AS
/* $Header: PAPCDCDB.pls 120.0.12010000.9 2010/06/04 06:32:00 racheruv noship $*/

--
-- Procedure insert_row():
-- Called from the direct cost region of the planning UI
-- Calls the process_planning_lines() to rollup the planning lines,
-- which calls the insert/update resource assignment API
-- Inserts data into pa_ci_direct_cost_details table at detail level
--
procedure insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bvid                         IN NUMBER,
    p_dc_line_id_tbl               IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_ci_id                        IN NUMBER,
    p_project_id                   IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_unit_of_measure_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_planning_resource_rate_tbl   IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_quantity_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_raw_cost_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_burdened_cost_tbl            IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_raw_cost_rate_tbl            IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_burden_cost_rate_tbl         IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_resource_assignment_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
    p_effective_from_tbl           IN SYSTEM.PA_DATE_TBL_TYPE DEFAULT SYSTEM.PA_DATE_TBL_TYPE(),
    p_effective_to_tbl             IN SYSTEM.PA_DATE_TBL_TYPE DEFAULT SYSTEM.PA_DATE_TBL_TYPE(),
    p_change_reason_code           IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(),
    p_change_description           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_2000_TBL_TYPE()) IS

 l_api_version	     number := 1;
 l_api_name          CONSTANT VARCHAR2(30) := 'PUB.insert_row';
 l_return_status     VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
 l_msg_count	     number;
 l_msg_data          varchar2(2000);

 l_dc_line_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

 l_PaCiDirCostDetTbl PaCiDirCostTblType;
 x_PaCiDirCostDetTbl PaCiDirCostTblType;

cursor get_budget_details(c_bvid number, c_task_id number,
                          c_rlmi number) IS
select prac.resource_assignment_id,
       planning_start_date,
       planning_end_date,
       prac.txn_average_raw_cost_rate planning_resource_rate,
       prac.txn_average_burden_cost_rate burden_cost_rate
  from pa_resource_assignments pra, pa_resource_asgn_curr prac
 where pra.budget_version_id = c_bvId
   and pra.task_id = c_task_id
   and pra.resource_list_member_id = c_rlmi
   and prac.resource_assignment_id = pra.resource_assignment_id;

begin

   savepoint pub_insert_row;

   if (p_task_id_tbl.count > 0) then
     for i in p_task_id_tbl.first..p_task_id_tbl.last loop

	   l_dc_line_id_tbl.extend(1);

	   select pa_ci_dir_cost_details_s.nextval
	     into l_dc_line_id_tbl(i)
		 from dual;

	   --l_dc_line_id_tbl(i)                             := pa_ci_dir_cost_details_s.nextval;
       l_PaCiDirCostDetTbl(i).dc_line_id               := l_dc_line_id_tbl(i);

       l_PaCiDirCostDetTbl(i).ci_id                    := p_ci_id;
       l_PaCiDirCostDetTbl(i).project_id               := p_project_id;
       l_PaCiDirCostDetTbl(i).task_id                  := p_task_id_tbl(i);
       l_PaCiDirCostDetTbl(i).expenditure_type         := p_expenditure_type_tbl(i);
       l_PaCiDirCostDetTbl(i).resource_list_member_id  := p_rlmi_id_tbl(i);
       l_PaCiDirCostDetTbl(i).unit_of_measure          := p_unit_of_measure_tbl(i);
       l_PaCiDirCostDetTbl(i).currency_code            := p_currency_code_tbl(i);

       if p_quantity_tbl.exists(i) then
          l_PaCiDirCostDetTbl(i).quantity              := p_quantity_tbl(i);
       else
          l_PaCiDirCostDetTbl(i).quantity              := NULL;
       end if;

	   if p_planning_resource_rate_tbl.exists(i) then
         l_PaCiDirCostDetTbl(i).planning_resource_rate   := p_planning_resource_rate_tbl(i);
	   else
         l_PaCiDirCostDetTbl(i).planning_resource_rate   := NULL;
	   end if;

       if p_raw_cost_tbl.exists(i) then
          l_PaCiDirCostDetTbl(i).raw_cost              := p_raw_cost_tbl(i);
       else
          l_PaCiDirCostDetTbl(i).raw_cost              := null;
       end if;

       /*
        p_burdened_cost_tbl, p_raw_cost_rate_tbl, p_burden_cost_rate_tbl,
        p_effective_from_tbl, p_effective_to_tbl and
        p_resource_assignment_id_tbl are not available during insert
       */

       l_PaCiDirCostDetTbl(i).burdened_cost            := NULL;
       l_PaCiDirCostDetTbl(i).raw_cost_rate            := NULL;
       l_PaCiDirCostDetTbl(i).burden_cost_rate         := NULL;

       l_PaCiDirCostDetTbl(i).resource_assignment_id   := NULL;

       l_PaCiDirCostDetTbl(i).effective_from           := NULL;
       l_PaCiDirCostDetTbl(i).effective_to             := NULL;

       if p_change_reason_code.exists(i) then
          l_PaCiDirCostDetTbl(i).change_reason_code       := p_change_reason_code(i);
       else
          l_PaCiDirCostDetTbl(i).change_reason_code       := NULL;
       end if;

       if p_change_description.exists(i)  then
          l_PaCiDirCostDetTbl(i).change_description       := p_change_description(i);
       else
          l_PaCiDirCostDetTbl(i).change_description       := NULL;
       end if;

       l_PaCiDirCostDetTbl(i).creation_date            := sysdate;
       l_PaCiDirCostDetTbl(i).created_by               := FND_GLOBAL.USER_ID;
       l_PaCiDirCostDetTbl(i).last_update_date         := sysdate;
       l_PaCiDirCostDetTbl(i).last_update_by           := FND_GLOBAL.USER_ID;
       l_PaCiDirCostDetTbl(i).last_update_login        := FND_GLOBAL.LOGIN_ID;
     end loop;

      pa_ci_dir_cost_pvt.insert_row(
        p_api_version                  => l_api_version,
        p_init_msg_list                => FND_API.G_FALSE,
        x_return_status                => l_return_status,
        x_msg_count                    => l_msg_count,
        x_msg_data                     => l_msg_data,
        PPaCiDirectCostDetailsTbl      => l_PaCiDirCostDetTbl,
        XPaCiDirectCostDetailsTbl      => x_PaCiDirCostDetTbl);

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

       pa_process_ci_lines_pkg.process_planning_lines(
	                       p_api_version        => l_api_version,
                           p_init_msg_list      => FND_API.G_FALSE,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           p_calling_context    => 'DIRECT_COST',
		                   p_action_type        => 'INSERT',
		                   p_bvid               => p_bvid,
		                   p_ci_id              => p_ci_id,
		                   p_line_id_tbl        => l_dc_line_id_tbl,
		                   p_project_id         => p_project_id,
		                   p_task_id_tbl        => p_task_id_tbl,
		                   p_currency_code_tbl  => p_currency_code_tbl,
		                   p_rlmi_id_tbl        => p_rlmi_id_tbl,
				           p_res_assgn_id_tbl   => p_resource_assignment_id_tbl,
				           p_quantity_tbl       => p_quantity_tbl,
				           p_raw_cost_tbl       => p_raw_cost_tbl
                           );

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

	   forall i in l_dc_line_id_tbl.first..l_dc_line_id_tbl.last
          update pa_ci_direct_cost_details pcdc
             set (resource_assignment_id, effective_from, effective_to,
                  planning_resource_rate, burden_cost_rate,
			      raw_cost, burdened_cost) =
                     (select prac.resource_assignment_id,
                             decode(pcdc.effective_from,
						            null,pra.planning_start_date, pcdc.effective_from),
                             decode(pcdc.effective_to,
						            null, pra.planning_end_date, pcdc.effective_to),
                             prac.txn_average_raw_cost_rate,
                             prac.txn_average_burden_cost_rate,
                             decode(pcdc.quantity, null, pcdc.raw_cost,
                                       pcdc.quantity * prac.txn_average_raw_cost_rate),
                             decode(pcdc.quantity, null,
                                       pcdc.raw_cost * prac.txn_average_burden_cost_rate,
                                       pcdc.quantity * prac.txn_average_burden_cost_rate)
                        from pa_resource_assignments pra, pa_resource_asgn_curr prac
                       where pra.budget_version_id = p_bvId
                         and pra.task_id = pcdc.task_id
                         and pra.resource_list_member_id = pcdc.resource_list_member_id
					     and prac.txn_currency_code = pcdc.currency_code
                         and prac.resource_assignment_id = pra.resource_assignment_id)
           where ci_id = p_ci_id
		     and dc_line_id = l_dc_line_id_tbl(i);

   end if;

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN PA_API.G_EXCEPTION_ERROR THEN
		ROLLBACK TO SAVEPOINT PUB_INSERT_ROW;

        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);
      x_return_status := l_return_status;

    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

		ROLLBACK TO SAVEPOINT PUB_INSERT_ROW;

        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);
      x_return_status := l_return_status;

    WHEN OTHERS THEN

		ROLLBACK TO SAVEPOINT PUB_INSERT_ROW;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (g_pkg_name,
             l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data
        );

end insert_row;

--
-- Procedure update_row():
-- Called from the direct cost region of the planning UI
-- Calls the process_planning_lines() to rollup the planning lines,
-- which calls the update resource assignment API.
-- Updates the data in pa_ci_direct_cost_details table.
--
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bvid                         IN NUMBER,
    p_dc_line_id_tbl               IN SYSTEM.PA_NUM_TBL_TYPE,
    p_ci_id                        IN NUMBER,
    p_project_id                   IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_unit_of_measure_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_quantity_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE,
    p_planning_resource_rate_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
    p_raw_cost_tbl                 IN SYSTEM.PA_NUM_TBL_TYPE,
    p_burdened_cost_tbl            IN SYSTEM.PA_NUM_TBL_TYPE,
    p_raw_cost_rate_tbl            IN SYSTEM.PA_NUM_TBL_TYPE,
    p_burden_cost_rate_tbl         IN SYSTEM.PA_NUM_TBL_TYPE,
    p_resource_assignment_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
    p_effective_from_tbl           IN SYSTEM.PA_DATE_TBL_TYPE,
    p_effective_to_tbl             IN SYSTEM.PA_DATE_TBL_TYPE,
    p_change_reason_code           IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_change_description           IN SYSTEM.PA_VARCHAR2_2000_TBL_TYPE) IS

 l_api_version	     number := 1;
 l_api_name          CONSTANT VARCHAR2(30) := 'Pub.update_row';
 l_return_status     VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
 l_msg_count	     number;
 l_msg_data          varchar2(2000);
 l_PaCiDirCostDetTbl PaCiDirCostTblType;
 x_PaCiDirCostDetTbl PaCiDirCostTblType;

 cursor get_dc_line(c_dc_line_id number) is
 select task_id, resource_list_member_id,
        expenditure_type, nvl(quantity, -1) quantity,
		nvl(raw_cost, -1) raw_cost,
		effective_from, effective_to
   from pa_ci_direct_cost_details
  where ci_id = p_ci_id
    and dc_line_id = c_dc_line_id;

 dc_line_row         get_dc_line%ROWTYPE;

 k                   number;

 TYPE varchar1_tbl is table of varchar2(1) index by binary_integer;
 budget_impact_tbl   varchar1_tbl;

 b_task_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 b_dc_line_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 b_quantity_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 b_raw_cost_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 b_res_assgn_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 b_rlmi_id_tbl       SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 b_currency_code_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();

begin

   budget_impact_tbl.delete;

   SAVEPOINT PUB_UPDATE_ROW;

   if (p_task_id_tbl.count > 0) then
     for i in p_task_id_tbl.first..p_task_id_tbl.last loop

	   open get_dc_line(p_dc_line_id_tbl(i));
	   fetch get_dc_line into dc_line_row;
	   close get_dc_line;

	   budget_impact_tbl(i) := 'N';

	   if p_quantity_tbl.exists(i) and p_quantity_tbl(i) <> FND_API.G_MISS_NUM
	      and p_quantity_tbl(i) is not null then
	     if dc_line_row.quantity <> p_quantity_tbl(i) then
		    budget_impact_tbl(i) := 'Y';
		 end if;
	   end if;

	   if p_raw_cost_tbl.exists(i) and p_raw_cost_tbl(i) <> FND_API.G_MISS_NUM and
	      p_raw_cost_tbl(i) is not null then
	     if dc_line_row.raw_cost <> p_raw_cost_tbl(i) then
		    budget_impact_tbl(i) := 'Y';
		 end if;
	   end if;

	   if dc_line_row.effective_from <> p_effective_from_tbl(i) then
          budget_impact_tbl(i) := 'Y';
	   end if;

	   if dc_line_row.effective_to <> p_effective_to_tbl(i) then
         budget_impact_tbl(i) := 'Y';
	   end if;


       l_PaCiDirCostDetTbl(i).dc_line_id               := p_dc_line_id_tbl(i);
       l_PaCiDirCostDetTbl(i).ci_id                    := p_ci_id;
       l_PaCiDirCostDetTbl(i).project_id               := p_project_id;
       l_PaCiDirCostDetTbl(i).task_id                  := p_task_id_tbl(i);
       l_PaCiDirCostDetTbl(i).expenditure_type         := p_expenditure_type_tbl(i);
       l_PaCiDirCostDetTbl(i).resource_list_member_id  := p_rlmi_id_tbl(i);
       l_PaCiDirCostDetTbl(i).unit_of_measure          := p_unit_of_measure_tbl(i);
       l_PaCiDirCostDetTbl(i).currency_code            := p_currency_code_tbl(i);

       if p_quantity_tbl.exists(i) then
          l_PaCiDirCostDetTbl(i).quantity                 := p_quantity_tbl(i);
       else
          l_PaCiDirCostDetTbl(i).quantity                 := PA_API.G_MISS_NUM;
       end if;

       if p_planning_resource_rate_tbl.exists(i) then
          l_PaCiDirCostDetTbl(i).planning_resource_rate   := p_planning_resource_rate_tbl(i);
       else
          l_PaCiDirCostDetTbl(i).planning_resource_rate   := PA_API.G_MISS_NUM;
       end if;

       if p_raw_cost_tbl.exists(i) then
          l_PaCiDirCostDetTbl(i).raw_cost                 := p_raw_cost_tbl(i);
       else
          l_PaCiDirCostDetTbl(i).raw_cost                 := PA_API.G_MISS_NUM;
       end if;

       l_PaCiDirCostDetTbl(i).burdened_cost            := PA_API.G_MISS_NUM;
       l_PaCiDirCostDetTbl(i).raw_cost_rate            := PA_API.G_MISS_NUM;
       l_PaCiDirCostDetTbl(i).burden_cost_rate         := PA_API.G_MISS_NUM;
       l_PaCiDirCostDetTbl(i).resource_assignment_id   := PA_API.G_MISS_NUM;
       l_PaCiDirCostDetTbl(i).effective_from           := p_effective_from_tbl(i);
       l_PaCiDirCostDetTbl(i).effective_to             := p_effective_to_tbl(i);

       if p_change_reason_code.exists(i) then
         l_PaCiDirCostDetTbl(i).change_reason_code       := p_change_reason_code(i);
       else
         l_PaCiDirCostDetTbl(i).change_reason_code       := NULL;
       end if;

       if p_change_description.exists(i) then
          l_PaCiDirCostDetTbl(i).change_description       := p_change_description(i);
       else
          l_PaCiDirCostDetTbl(i).change_description       := NULL;
       end if;

     end loop;

      pa_ci_dir_cost_pvt.update_row(
      	   p_api_version                  => l_api_version,
     	   p_init_msg_list                => FND_API.G_FALSE,
    	   x_return_status                => l_return_status,
    	   x_msg_count                    => l_msg_count,
    	   x_msg_data                     => l_msg_data,
    	   PPaCiDirectCostDetailsTbl      => l_PaCiDirCostDetTbl,
    	   XPaCiDirectCostDetailsTbl      => x_PaCiDirCostDetTbl);

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

	  k := 0;
      for i in budget_impact_tbl.first..budget_impact_tbl.last loop
        if budget_impact_tbl(i) = 'Y' then

          k := k + 1;

		  b_dc_line_id_tbl.extend(1);
		  b_task_id_tbl.extend(1);
		  b_currency_code_tbl.extend(1);
		  b_rlmi_id_tbl.extend(1);
		  b_res_assgn_id_tbl.extend(1);
		  b_quantity_tbl.extend(1);
		  b_raw_cost_tbl.extend(1);

		  b_dc_line_id_tbl(k) := p_dc_line_id_tbl(i);
		  b_task_id_tbl(k)    := p_task_id_tbl(i);
		  b_currency_code_tbl(k) := p_currency_code_tbl(i);
		  b_rlmi_id_tbl(k)    := p_rlmi_id_tbl(i);
		  b_res_assgn_id_tbl(k) := p_resource_assignment_id_tbl(i);

		  if p_quantity_tbl.exists(i) then
             b_quantity_tbl(k) := p_quantity_tbl(i);
		  end if;

		  if p_raw_cost_tbl.exists(i) then
             b_raw_cost_tbl(k) := p_raw_cost_tbl(i);
		  end if;

		end if;
	  end loop;

	   if b_task_id_tbl.count > 0 then
          pa_process_ci_lines_pkg.process_planning_lines(
	                          p_api_version        => l_api_version,
                              p_init_msg_list      => FND_API.G_FALSE,
                              x_return_status      => l_return_status,
                              x_msg_count          => l_msg_count,
                              x_msg_data           => l_msg_data,
                              p_calling_context    => 'DIRECT_COST',
				              p_action_type        => 'UPDATE',
				              p_bvid               => p_bvid,
				              p_ci_id              => p_ci_id,
				              p_line_id_tbl        => b_dc_line_id_tbl,
				              p_project_id         => p_project_id,
				              p_task_id_tbl        => b_task_id_tbl,
				              p_currency_code_tbl  => b_currency_code_tbl,
				              p_rlmi_id_tbl        => b_rlmi_id_tbl,
				              p_res_assgn_id_tbl   => b_res_assgn_id_tbl,
				              p_quantity_tbl       => b_quantity_tbl,
				              p_raw_cost_tbl       => b_raw_cost_tbl
                              );

         IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
           RAISE PA_API.G_EXCEPTION_ERROR;
         END IF;
/*
	     forall i in b_task_id_tbl.first..b_task_id_tbl.last
            update pa_ci_direct_cost_details pcdc
               set ( raw_cost, burdened_cost) =
                       (select decode(pcdc.quantity, null, pcdc.raw_cost,
						                 pcdc.quantity * prac.txn_average_raw_cost_rate),
						         decode(pcdc.quantity, null,
						                 pcdc.raw_cost * prac.txn_average_burden_cost_rate,
									     pcdc.quantity * prac.txn_average_burden_cost_rate)
                          from pa_resource_assignments pra, pa_resource_asgn_curr prac
                         where pra.budget_version_id = p_bvId
                           and pra.resource_assignment_id = pcdc.resource_assignment_id
                           and prac.resource_assignment_id = pra.resource_assignment_id
					       and prac.txn_currency_code = pcdc.currency_code)
             where ci_id = p_ci_id
		       and dc_line_id = b_dc_line_id_tbl(i);
*/
	     forall i in b_task_id_tbl.first..b_task_id_tbl.last
            update pa_ci_direct_cost_details pcdc
               set raw_cost = decode(pcdc.quantity, null, pcdc.raw_cost,
			                         pcdc.quantity * pcdc.planning_resource_rate),
                   burdened_cost = decode(pcdc.quantity, null,
						                 pcdc.raw_cost * pcdc.burden_cost_rate,
									     pcdc.quantity * pcdc.burden_cost_rate)
             where ci_id = p_ci_id
		       and dc_line_id = b_dc_line_id_tbl(i);

       end if;

  end if;

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN PA_API.G_EXCEPTION_ERROR THEN

     ROLLBACK TO SAVEPOINT PUB_UPDATE_ROW;

        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);
      x_return_status := l_return_status;

    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

     ROLLBACK TO SAVEPOINT PUB_UPDATE_ROW;

        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);
      x_return_status := l_return_status;

    WHEN OTHERS THEN

      ROLLBACK TO SAVEPOINT PUB_UPDATE_ROW;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (g_pkg_name,
             l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data
        );

end update_row;

--
-- Procedure delete_row():
-- Called from the direct cost region of the planning UI
-- Calls the process_planning_lines() to rollup the planning lines,
-- which determines if the resource assignment needs to deleted
-- or updated.
-- Deletes data from pa_ci_direct_cost_details table
--
PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dc_line_id_TBL               IN SYSTEM.PA_NUM_TBL_TYPE,
    p_ci_id                        IN NUMBER,
    p_project_id                   IN NUMBER,
    p_task_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_expenditure_type_tbl         IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
    p_rlmi_id_tbl                  IN SYSTEM.PA_NUM_TBL_TYPE,
    p_currency_code_tbl            IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE) IS

 l_api_version	     number := 1;
 l_api_name          CONSTANT VARCHAR2(30) := 'Pub.delete_row';
 l_return_status     VARCHAR2(1) := PA_API.G_RET_STS_SUCCESS;
 l_msg_count	     number;
 l_msg_data          varchar2(2000);
 l_PaCiDirCostDetTbl PaCiDirCostTblType;

 l_resource_assignment_id_tbl      SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

 l_bvid              NUMBER;

 cursor get_bvid(c_ci_id number) is
 select budget_version_id
   from pa_budget_versions
  where ci_id = c_ci_id
    and version_type in ('COST', 'ALL');

begin

   SAVEPOINT PUB_DELETE_ROW;

   open get_bvid(p_ci_id);
   fetch get_bvid into l_bvid;
   close get_bvid;

   if (p_task_id_tbl.count > 0) then
     for i in p_task_id_tbl.first..p_task_id_tbl.last loop
       l_PaCiDirCostDetTbl(i).dc_line_id               := p_dc_line_id_tbl(i);
       l_PaCiDirCostDetTbl(i).ci_id                    := p_ci_id;
       l_PaCiDirCostDetTbl(i).project_id               := p_project_id;
       l_PaCiDirCostDetTbl(i).task_id                  := p_task_id_tbl(i);
       l_PaCiDirCostDetTbl(i).expenditure_type         := p_expenditure_type_tbl(i);
       l_PaCiDirCostDetTbl(i).resource_list_member_id  := p_rlmi_id_tbl(i);
       l_PaCiDirCostDetTbl(i).currency_code            := p_currency_code_tbl(i);
       l_PaCiDirCostDetTbl(i).quantity                 := PA_API.G_MISS_NUM;
       l_PaCiDirCostDetTbl(i).raw_cost                 := PA_API.G_MISS_NUM;
       l_resource_assignment_id_tbl.extend(1);
       l_resource_assignment_id_tbl(i)                 := null;
     end loop;

      pa_ci_dir_cost_pvt.delete_row(
         p_api_version                  => l_api_version,
         p_init_msg_list                => FND_API.G_FALSE,
         x_return_status                => l_return_status,
         x_msg_count                    => l_msg_count,
         x_msg_data                     => l_msg_data,
         PPaCiDirectCostDetailsTbl      => l_PaCiDirCostDetTbl);

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

     pa_process_ci_lines_pkg.process_planning_lines(
	                       p_api_version        => l_api_version,
                           p_init_msg_list      => FND_API.G_FALSE,
                           x_return_status      => l_return_status,
                           x_msg_count          => l_msg_count,
                           x_msg_data           => l_msg_data,
                           p_calling_context    => 'DIRECT_COST',
				           p_action_type        => 'DELETE',
				           p_bvid               => l_bvid,
				           p_ci_id              => p_ci_id,
				           p_line_id_tbl        => p_dc_line_id_tbl,
				           p_project_id         => p_project_id,
				           p_task_id_tbl        => p_task_id_tbl,
				           p_currency_code_tbl  => p_currency_code_tbl,
				           p_rlmi_id_tbl        => p_rlmi_id_tbl,
				           p_res_assgn_id_tbl   => l_resource_assignment_id_tbl
                           );

      IF (l_return_status = PA_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = PA_API.G_RET_STS_ERROR) THEN
        RAISE PA_API.G_EXCEPTION_ERROR;
      END IF;

  end if;

  PA_API.END_ACTIVITY(l_msg_count, l_msg_data);
  x_return_status := PA_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN PA_API.G_EXCEPTION_ERROR THEN

      ROLLBACK TO SAVEPOINT PUB_DELETE_ROW;

        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);
      x_return_status := l_return_status;

    WHEN PA_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      ROLLBACK TO SAVEPOINT PUB_DELETE_ROW;

        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data);
      x_return_status := l_return_status;

    WHEN OTHERS THEN

      ROLLBACK TO SAVEPOINT PUB_DELETE_ROW;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (g_pkg_name,
             l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get
        (p_count =>  x_msg_count,
         p_data  =>  x_msg_data
        );

end delete_row;

end pa_ci_dir_cost_pub;

/
