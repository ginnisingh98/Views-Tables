--------------------------------------------------------
--  DDL for Package Body PA_WP_EXCEPTION_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WP_EXCEPTION_UTILS" as
/*$Header: PAWPXCUB.pls 120.1.12010000.2 2008/09/12 19:31:01 snizam ship $*/

-- API name                      : get_wp_exception_value
-- Type                          : Utils Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--
--  25-JUN-01   HSIU             -Created
--

  procedure get_wp_exception_value
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT  NOCOPY   NUMBER, -- 4537865
    x_period_name             OUT  NOCOPY   VARCHAR2, -- 4537865
    x_return_status           OUT  NOCOPY   VARCHAR2, -- 4537865
    x_msg_count               OUT  NOCOPY   NUMBER, -- 4537865
    x_msg_data                OUT  NOCOPY   VARCHAR2 -- 4537865
  )
  IS
  BEGIN
    --need to replace measure ids with correct values
    --once measure has been seeded
--    IF (p_measure_id = 11) THEN
    IF (p_measure_id = 427) THEN
      --get ITD workplan effort variance
      PA_WP_EXCEPTION_UTILS.get_ITD_workplan_effort_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 12) THEN
    ELSIF (p_measure_id = 428) THEN
      --get forecast workplan effor variance
      PA_WP_EXCEPTION_UTILS.get_forecast_wp_eff_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 13) THEN
    ELSIF (p_measure_id = 429) THEN
      --get current forecast to prior forecast workplan effor variance
      PA_WP_EXCEPTION_UTILS.get_cur_fc_to_pri_effort_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 14) THEN
    ELSIF (p_measure_id = 430) THEN
      --get schedule baseline finish variance
      PA_WP_EXCEPTION_UTILS.get_sch_bsln_fin_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 15) THEN
    ELSIF (p_measure_id = 431) THEN
      --get schedule baseline start variance
      PA_WP_EXCEPTION_UTILS.get_sch_bsln_st_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 16) THEN
    ELSIF (p_measure_id = 432) THEN
      --get schedule prior published version finish variance
      PA_WP_EXCEPTION_UTILS.get_sch_pri_pub_ver_fin_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 17) THEN
    ELSIF (p_measure_id = 433) THEN
      --get schedule prior published version start variance
      PA_WP_EXCEPTION_UTILS.get_sch_pri_pub_ver_st_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 18) THEN
    ELSIF (p_measure_id = 434) THEN
      --get schedule estimated finish variance
      PA_WP_EXCEPTION_UTILS.get_sch_est_fin_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
--    ELSIF (p_measure_id = 19) THEN
    ELSIF (p_measure_id = 435) THEN
      --get schedule estimated start variance
      PA_WP_EXCEPTION_UTILS.get_sch_est_st_var(
        p_object_type   => p_object_type,
        p_object_id     => p_object_id,
        p_measure_id    => p_measure_id,
        p_period_type   => p_period_type,
        x_measure_value => x_measure_value,
        x_period_name   => x_period_name,
        x_return_status => x_return_status,
        x_msg_count     => x_msg_count,
        x_msg_data      => x_msg_data
      );
    END IF;
  -- 4537865
  EXCEPTION
	WHEN OTHERS THEN
		x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
		x_period_name := NULL ;
	        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	        x_msg_count     := 1;
    		x_msg_data      := SQLERRM;

		Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_wp_exception_value'
                    , p_error_text      => x_msg_data);

		 RAISE;

  END get_wp_exception_value;

  PROCEDURE get_ITD_workplan_effort_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    l_wp_versioN_id NUMBER;
    CURSOR c1(c_wp_ver_id NUMBER) IS
      select (NVL(PPRU.ppl_act_effort_to_date,0) + NVL(ppru.eqpmt_act_effort_to_date,0)) -
--             (NVL(pfxat.labor_hours, 0) + NVL(pfxat.equipment_hours, 0))
             (NVL(pxpv.labor_effort,0) + NVL(pxpv.equipment_effort,0))
        from pji_xbs_plans_v       pxpv,
--      from pji_fm_xbs_accum_tmp1 pfxat,
           pa_progress_rollup ppru,
           pa_proj_element_versions ppev
     where ppev.element_version_id = c_wp_ver_id
       and ppev.project_id = ppru.project_id
       and ppev.proj_element_id = ppru.object_id
       and ppev.object_type = ppru.object_type
       and ppru.structure_type = 'WORKPLAN'
       and ppev.project_id = pxpv.project_id
       and ppev.proj_element_id = pxpv.proj_element_id
       and ppev.element_version_id = pxpv.structure_version_id
       and pxpv.structure_type(+) = 'WORKPLAN'
--       and ppev.project_id = pfxat.project_id
--       and ppev.proj_element_id = pfxat.project_element_id
--       and ppev.element_version_id = pfxat.struct_version_id
--       and pfxat.calendar_type (+) = 'A'
     order by ppru.as_of_date desc;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_wp_versioN_id := pa_project_structure_utils.GET_LATEST_WP_VERSION(p_object_id);
    IF l_wp_version_id IS NULL THEN
      --no publish version; return 0;
      x_measure_value := 0;
    ELSE
      OPEN c1(l_wp_version_id);
      FETCH c1 into x_measure_value;
      CLOSE c1;
    END IF;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_ITD_workplan_effort_var'
                    , p_error_text      => x_msg_data);

                 RAISE;

  END get_ITD_workplan_effort_var;

  PROCEDURE get_forecast_wp_eff_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    l_wp_versioN_id NUMBER;
    CURSOR c1(c_wp_ver_id NUMBER) IS
      select (NVL(ppru.estimated_remaining_effort,0) +
              NVL(ppru.eqpmt_etc_effort,0) +
              NVL(ppru.PPL_ACT_EFFORT_TO_DATE, 0) +
              NVL(ppru.EQPMT_ACT_EFFORT_TO_DATE, 0) ) -
--             (NVL(pfxat.labor_hours, 0) + NVL(pfxat.equipment_hours, 0))
             (NVL(pxpv.labor_effort,0) + NVL(pxpv.equipment_effort,0))
        from pji_xbs_plans_v       pxpv,
--      from pji_fm_xbs_accum_tmp1 pfxat,
           pa_progress_rollup ppru,
           pa_proj_element_versions ppev
     where ppev.element_version_id = c_wp_ver_id
       and ppev.project_id = ppru.project_id
       and ppev.proj_element_id = ppru.object_id
       and ppev.object_type = ppru.object_type
       and ppru.structure_version_id is null -- Added for bug 6337529
       and ppru.structure_type = 'WORKPLAN'
       and ppev.project_id = pxpv.project_id
       and ppev.proj_element_id = pxpv.proj_element_id
       and ppev.element_version_id = pxpv.structure_version_id
       and pxpv.structure_type(+) = 'WORKPLAN'
--       and ppev.project_id = pfxat.project_id
--       and ppev.proj_element_id = pfxat.project_element_id
--       and ppev.element_version_id = pfxat.struct_version_id
--       and pfxat.calendar_type (+) = 'A'
     order by ppru.as_of_date desc;

  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_wp_versioN_id := pa_project_structure_utils.GET_LATEST_WP_VERSION(p_object_id);
    IF l_wp_version_id IS NULL THEN
      --no publish version; return 0;
      x_measure_value := 0;
    ELSE
      OPEN c1(l_wp_version_id);
      FETCH c1 into x_measure_value;
      CLOSE c1;
    END IF;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_forecast_wp_eff_var'
                    , p_error_text      => x_msg_data);

                 RAISE;

  END get_forecast_wp_eff_var;

  PROCEDURE get_cur_fc_to_pri_effort_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    l_wp_versioN_id NUMBER;
    CURSOR c1(c_wp_ver_id NUMBER) IS
      select (NVL(ppru.estimated_remaining_effort,0) + NVL(ppru.eqpmt_etc_effort,0))
      from pa_progress_rollup ppru,
           pa_proj_element_versions ppev
     where ppev.element_version_id = c_wp_ver_id
       and ppev.project_id = ppru.project_id
       and ppev.proj_element_id = ppru.object_id
       and ppev.object_type = ppru.object_type
       and ppru.structure_type = 'WORKPLAN'
     order by ppru.as_of_date desc;

    l_value1 NUMBER;
    l_value2 NUMBER;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_wp_versioN_id := pa_project_structure_utils.GET_LATEST_WP_VERSION(p_object_id);
    IF l_wp_version_id IS NULL THEN
      --no publish version; return 0;
      x_measure_value := 0;
    ELSE
      OPEN c1(l_wp_version_id);
      FETCH c1 into l_value1;
      IF c1%NOTFOUND THEN
        x_measure_value := 0;
        CLOSE C1;
      ELSE
        FETCH c1 into l_value2;
        IF c1%NOTFOUND THEN
          x_measure_value := 0;
          CLOSE c1;
        ELSE
          CLOSE c1;
        END IF;
      END IF;
    END IF;
    x_measure_value := l_value1 - l_value2;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_cur_fc_to_pri_effort_var'
                    , p_error_text      => x_msg_data);

                 RAISE;

  END get_cur_fc_to_pri_effort_var;

  PROCEDURE get_sch_bsln_fin_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select baseline_finish_date, scheduled_finish_date
        from pa_projects_all
       where project_id = p_object_id;
    l_b_fin  DATE;
    l_s_fin  DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c1;
    FETCH c1 into l_b_fin, l_s_fin;
    CLOSE c1;

    IF (l_b_fin IS NOT NULL) AND (l_s_fin IS NOT NULL) THEN
      x_measure_value := l_s_fin - l_b_fin;
    ELSE
      x_measure_value := 0;
    END IF;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_sch_bsln_fin_var'
                    , p_error_text      => x_msg_data);

                 RAISE;

  END get_sch_bsln_fin_var;

  PROCEDURE get_sch_bsln_st_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY     NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select baseline_start_date, scheduled_start_date
        from pa_projects_all
       where project_id = p_object_id;
    l_b_st  DATE;
    l_s_st  DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c1;
    FETCH c1 into l_b_st, l_s_st;
    CLOSE c1;

    IF (l_b_st IS NOT NULL) AND (l_s_st IS NOT NULL) THEN
      x_measure_value := l_s_st - l_b_st;
    ELSE
      x_measure_value := 0;
    END IF;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_sch_bsln_st_var'
                    , p_error_text      => x_msg_data);

                 RAISE;
  END get_sch_bsln_st_var;

  PROCEDURE get_sch_pri_pub_ver_fin_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT  NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT  NOCOPY   VARCHAR2, -- 4537865
    x_return_status           OUT  NOCOPY   VARCHAR2, -- 4537865
    x_msg_count               OUT  NOCOPY   NUMBER, -- 4537865
    x_msg_data                OUT  NOCOPY   VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select sch.scheduled_finish_date
        from pa_proj_elem_ver_schedule sch,
             pa_proj_elem_ver_structure str,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where pst.structure_type = 'WORKPLAN'
         and pst.structure_type_id = ppst.structure_type_id
         and ppst.proj_element_id = str.proj_element_id
         and str.project_id = p_object_id
         and str.project_id = sch.project_id
         and str.proj_element_id = sch.proj_element_id
         and str.element_version_id = sch.element_version_id
         and str.status_code = 'STRUCTURE_PUBLISHED'  --bug 3956895
    order by str.published_date desc;

    l_sch_date1 DATE;
    l_sch_date2 DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open C1;
    FETCH c1 into l_sch_date1;
    IF c1%NOTFOUND THEN
      x_measure_value := 0;
      CLOSE c1;
    ELSE
      fetch c1 into l_sch_date2;
      IF c1%NOTFOUND THEN
        x_measure_value := 0;
      ELSE
        x_measure_value := l_sch_date1 - l_sch_date2;
      END IF;
      close c1;
    END IF;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_sch_pri_pub_ver_fin_var'
                    , p_error_text      => x_msg_data);

                 RAISE;
  END get_sch_pri_pub_ver_fin_var;

  PROCEDURE get_sch_pri_pub_ver_st_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2,  -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select sch.scheduled_start_date
        from pa_proj_elem_ver_schedule sch,
             pa_proj_elem_ver_structure str,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where pst.structure_type = 'WORKPLAN'
         and pst.structure_type_id = ppst.structure_type_id
         and ppst.proj_element_id = str.proj_element_id
         and str.project_id = p_object_id
         and str.project_id = sch.project_id
         and str.proj_element_id = sch.proj_element_id
         and str.element_version_id = sch.element_version_id
         and str.status_code = 'STRUCTURE_PUBLISHED'  --bug 3956895
    order by str.published_date desc;

    l_sch_date1 DATE;
    l_sch_date2 DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open C1;
    FETCH c1 into l_sch_date1;
    IF c1%NOTFOUND THEN
      x_measure_value := 0;
      CLOSE c1;
    ELSE
      fetch c1 into l_sch_date2;
      IF c1%NOTFOUND THEN
        x_measure_value := 0;
      ELSE
        x_measure_value := l_sch_date1 - l_sch_date2;
      END IF;
      close c1;
    END IF;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_sch_pri_pub_ver_st_var'
                    , p_error_text      => x_msg_data);

                 RAISE;
  END get_sch_pri_pub_ver_st_var;

  PROCEDURE get_sch_est_fin_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select sch.scheduled_finish_date, nvl(sch.estimated_finish_date, sch.scheduled_finish_date)
        from pa_proj_elem_ver_schedule sch,
             pa_proj_elem_ver_structure str,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where pst.structure_type = 'WORKPLAN'
         and pst.structure_type_id = ppst.structure_type_id
         and ppst.proj_element_id = str.proj_element_id
         and str.project_id = p_object_id
         and str.project_id = sch.project_id
         and str.proj_element_id = sch.proj_element_id
         and str.element_version_id = sch.element_version_id
         and str.status_code = 'STRUCTURE_PUBLISHED'  --bug 3956895
    order by str.published_date desc;

    l_sch_date DATE;
    l_est_date DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open C1;
    FETCH c1 into l_sch_date, l_est_date;
    IF c1%NOTFOUND THEN
      x_measure_value := 0;
    ELSE
      x_measure_value := l_sch_date - l_est_date;
    END IF;
    close c1;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_sch_est_fin_var'
                    , p_error_text      => x_msg_data);

                 RAISE;
  END get_sch_est_fin_var;

  PROCEDURE get_sch_est_st_var
  (
    p_object_type             IN      VARCHAR2,
    p_object_id               IN      NUMBER,
    p_measure_id              IN      NUMBER,
    p_period_type             IN      VARCHAR2,
    x_measure_value           OUT NOCOPY    NUMBER, -- 4537865
    x_period_name             OUT NOCOPY    VARCHAR2, -- 4537865
    x_return_status           OUT NOCOPY    VARCHAR2, -- 4537865
    x_msg_count               OUT NOCOPY    NUMBER, -- 4537865
    x_msg_data                OUT NOCOPY    VARCHAR2 -- 4537865
  )
  IS
    CURSOR c1 IS
      select sch.scheduled_start_date, nvl(sch.estimated_start_date, sch.scheduled_start_date)
        from pa_proj_elem_ver_schedule sch,
             pa_proj_elem_ver_structure str,
             pa_proj_structure_types ppst,
             pa_structure_types pst
       where pst.structure_type = 'WORKPLAN'
         and pst.structure_type_id = ppst.structure_type_id
         and ppst.proj_element_id = str.proj_element_id
         and str.project_id = p_object_id
         and str.project_id = sch.project_id
         and str.proj_element_id = sch.proj_element_id
         and str.element_version_id = sch.element_version_id
         and str.status_code = 'STRUCTURE_PUBLISHED'  --bug 3956895
    order by str.published_date desc;

    l_sch_date DATE;
    l_est_date DATE;
  BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open C1;
    FETCH c1 into l_sch_date, l_est_date;
    IF c1%NOTFOUND THEN
      x_measure_value := 0;
    ELSE
      x_measure_value := l_sch_date - l_est_date;
    END IF;
    close c1;
  -- 4537865
  EXCEPTION
        WHEN OTHERS THEN
                x_measure_value := 0 ; -- Setting this value to zero ,not NULL for issue mentioned in 3842408
                x_period_name := NULL ;
                x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
                x_msg_count     := 1;
                x_msg_data      := SQLERRM;

                Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_WP_EXCEPTION_UTILS'
                    , p_procedure_name  => 'get_sch_est_st_var'
                    , p_error_text      => x_msg_data);

                 RAISE;
  END get_sch_est_st_var;


end PA_WP_EXCEPTION_UTILS;

/
