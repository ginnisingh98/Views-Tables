--------------------------------------------------------
--  DDL for Package Body MSC_PQ_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PQ_UTILS" AS
/* $Header: MSCPQUTB.pls 120.14.12010000.4 2009/09/07 12:37:34 skakani ship $ */

  G_PQ_ERROR_MESSAGE VARCHAR2(2000);

  g_among_values among_values_tab;
  g_CATEGORY_SET_ID NUMBER;
  g_query_id        NUMBER;
  g_obj_sequence_id NUMBER;
  g_sequence_id     NUMBER;

  g_items_list_exists NUMBER;

     FUNCTION validate_index_use(p_query_id IN NUMBER,
                                p_query_type IN NUMBER) RETURN NUMBER;

     PROCEDURE set_top_action(p_plan_id IN NUMBER, p_query_id IN NUMBER);

     CURSOR detailQCur(p_query_id IN NUMBER) IS
       SELECT pqt.DETAIL_QUERY_ID query_id,mpq.query_type
       FROM MSC_PQ_TYPES pqt,
            msc_personal_queries mpq
       WHERE pqt.query_id = p_query_id
       AND   mpq.query_id = pqt.DETAIL_QUERY_ID;

    CURSOR WlExcepCur(p_query_id IN NUMBER) IS
       SELECT 1
       FROM MSC_PQ_TYPES pqt
       WHERE pqt.query_id = p_query_id
       AND   pqt.DETAIL_QUERY_ID IS NULL;

    FUNCTION Get_Pref(p_plan_id NUMBER, p_preference in varchar2) RETURN NUMBER is
        l_pref_value number;
        l_def_pref_id number;
        l_plan_type number;

        CURSOR c_plan_type(v_plan_id NUMBER) IS
        SELECT curr_plan_type
        FROM msc_plans
        WHERE plan_id = v_plan_id;
     BEGIN
         OPEN c_plan_type(p_plan_id);
         FETCH c_plan_type INTO l_plan_type;
         CLOSE c_plan_type;
         --l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
         l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id,l_plan_type);
         --l_pref_value:= msc_get_name.get_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);
         l_pref_value:= msc_get_name.get_preference(p_preference,l_def_pref_id, l_plan_type);
         RETURN l_pref_value;

     END Get_Pref;

     PROCEDURE Parse_exceptions(p_plan_id         IN NUMBER,
                                p_where_clause    IN VARCHAR2) IS

        TYPE excepTyp IS REF CURSOR;
        c_exceptions excepTyp;

        TYPE excepRecTyp IS RECORD ( exception_id           msc_exception_details_v.exception_id%type,
                                     sr_instance_Id         msc_exception_details_v.sr_instance_Id%type,
                                     organization_id        msc_exception_details_v.organization_id%type,
                                     inventory_item_id      msc_exception_details_v.inventory_item_id%type,
                                     supplier_id            msc_exception_details_v.supplier_id%type,
                                     supplier_site_id       msc_exception_details_v.supplier_site_id%type,
                                     transaction_id         msc_exception_details_v.transaction_id%type,
                                     demand_id              msc_exception_details_v.demand_id%type,
                                     exception_type         msc_exception_details_v.exception_type%type,
                                     from_date              msc_exception_details_v.from_date%type,
                                     to_date                msc_exception_details_v.to_date%type,
                                     budget_violation_date  msc_exception_details_v.budget_violation_date%type,
                                     department_id          msc_exception_details_v.department_id%type,
                                     resource_id            msc_exception_details_v.resource_id%type,
                                     end_pegging_id         msc_exception_details_v.end_pegging_id%type,
                                     operation_seq_num      msc_exception_details_v.operation_seq_num%type,
                                     resource_seq_num       msc_exception_details_v.resource_seq_num%type);
        rec_exceptions excepRecTyp;
        TYPE numList IS TABLE Of NUMBER Index By BINARY_INTEGER;
        l_list numList;
        l_item_list numList;

        /*CURSOR C_supply_demand(p_plan_id            IN NUMBER,
                               p_instance_id        IN NUMBER,
                               p_organization_id    IN NUMBER,
                               p_inventory_item_id  IN NUMBER,
                               p_from_date          IN DATE,
                               p_to_date            IN DATE    ) IS
        SELECT transaction_id
        FROM   msc_orders_v
        WHERE  plan_id = p_plan_id
        AND    sr_instance_id = p_instance_id
        AND    organization_id = p_organization_id
        AND    inventory_item_id = p_inventory_item_id
        AND    trunc(new_due_date) >= trunc(p_from_date)
        AND    trunc(new_due_date) < trunc(p_to_date);*/

        CURSOR C_supply_demand1(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT sup.transaction_id
               --,sup.new_schedule_date new_due_date
        FROM msc_supplies sup,
             msc_system_items msi ,
             msc_item_categories mic
        WHERE mic.sr_instance_id    = sup.sr_instance_id
        AND   mic.organization_id   = sup.organization_id
        AND   mic.inventory_item_id = sup.inventory_item_id
        AND
              sup.plan_id           = msi.plan_id
        AND   sup.sr_instance_id    = msi.sr_instance_id
        AND   sup.organization_id   = msi.organization_id
        AND   sup.inventory_item_id = msi.inventory_item_id
        AND
              sup.plan_id           = p_plan_id
        AND   sup.sr_instance_id    = p_instance_id
        AND   sup.organization_id   = p_organization_id
        AND   sup.inventory_item_id = p_inventory_item_id
        AND   sup.new_schedule_date >= p_from_date
        AND   sup.new_schedule_date < p_to_date;
        --AND   trunc(sup.new_schedule_date) >= p_from_date
        --AND   trunc(sup.new_schedule_date) < p_to_date;

        CURSOR C_supply_demand2(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT dem.demand_id transaction_id
               --,dem.using_assembly_demand_date new_due_date
        FROM msc_demands         dem,
             msc_system_items    msi,
             msc_item_categories mic
        WHERE mic.sr_instance_id    = dem.sr_instance_id
        AND   mic.organization_id   = dem.organization_id
        AND   mic.inventory_item_id = dem.inventory_item_id
        AND
              dem.plan_id           = msi.plan_id
        AND   dem.sr_instance_id    = msi.sr_instance_id
        AND   dem.organization_id   = msi.organization_id
        AND   dem.inventory_item_id = msi.inventory_item_id
        AND   dem.origination_type <> 52
        AND
              dem.plan_id           = p_plan_id
        AND   dem.sr_instance_id    = p_instance_id
        AND   dem.organization_id   = p_organization_id
        AND   dem.inventory_item_id = p_inventory_item_id
        AND   dem.using_assembly_demand_date >= p_from_date
        AND   dem.using_assembly_demand_date < p_to_date;
        --AND   trunc(dem.using_assembly_demand_date) >= p_from_date
        --AND   trunc(dem.using_assembly_demand_date) < p_to_date;

        CURSOR C_supply_demand3(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT mso.demand_id transaction_id
               --,mso.requirement_date new_due_date
        FROM msc_sales_orders mso,
             msc_system_items msi ,
             msc_item_categories mic
        WHERE mso.sr_instance_id    = mic.sr_instance_id
        AND   mso.inventory_item_id = mic.inventory_item_id
        AND   mso.organization_id   = mic.organization_id
        AND
              mso.sr_instance_id    = msi.sr_instance_id
        AND   mso.inventory_item_id = msi.inventory_item_id
        AND   mso.organization_id   = msi.organization_id
        AND   mso.reservation_type  = 1
        --AND   msi.plan_id = -1
        AND
              msi.plan_id = p_plan_id
        AND   mso.sr_instance_id    = p_instance_id
        AND   mso.organization_id   = p_organization_id
        AND   mso.inventory_item_id = p_inventory_item_id
        AND   mso.requirement_date >= p_from_date
        AND   mso.requirement_date < p_to_date;
        --AND   trunc(mso.requirement_date) >= p_from_date
        --AND   trunc(mso.requirement_date) < p_to_date;

        CURSOR C_supply_demand4(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT jro.transaction_id
               --,jro.reco_date_required new_due_date
        FROM msc_job_requirement_ops jro,
             msc_system_items msi ,
             msc_item_categories mic
        WHERE mic.sr_instance_id    = jro.sr_instance_id
        AND   mic.organization_id   = jro.organization_id
        AND   mic.inventory_item_id = jro.component_item_id
        --AND   jro.plan_id = -1
        AND   jro.plan_id = msi.plan_id
        AND   jro.sr_instance_id = msi.sr_instance_id
        AND   jro.organization_id = msi.organization_id
        AND   jro.component_item_id = msi.inventory_item_id
        AND
              jro.plan_id           = p_plan_id
        AND   jro.sr_instance_id    = p_instance_id
        AND   jro.organization_id   = p_organization_id
        AND   jro.component_item_id = p_inventory_item_id
        AND   jro.reco_date_required >= p_from_date
        AND   jro.reco_date_required < p_to_date;
        --AND   trunc(jro.reco_date_required) >= p_from_date
        --AND   trunc(jro.reco_date_required) < p_to_date;

        CURSOR C_supply_demand5(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT sup.transaction_id
               --,nvl(sup.new_ship_date,sup.new_schedule_date) new_due_date
        FROM msc_supplies sup,
             msc_system_items msi ,
             msc_item_categories mic,
             msc_plans mp
        WHERE mic.sr_instance_id    = sup.sr_instance_id
        AND   mic.organization_id   = sup.organization_id
        AND   mic.inventory_item_id = sup.inventory_item_id
        AND
              sup.plan_id           = msi.plan_id
        AND   sup.sr_instance_id    = msi.sr_instance_id
        AND   sup.organization_id   = msi.organization_id
        AND   sup.inventory_item_id = msi.inventory_item_id
        AND   mp.plan_id     = sup.plan_id
        AND   mp.plan_type   = 5
        AND   sup.order_type = 51
        AND
              sup.plan_id           = p_plan_id
        AND   sup.sr_instance_id    = p_instance_id
        AND   sup.organization_id   = p_organization_id
        AND   sup.inventory_item_id = p_inventory_item_id
        AND   nvl(sup.new_ship_date,sup.new_schedule_date) >= p_from_date
        AND   nvl(sup.new_ship_date,sup.new_schedule_date) < p_to_date;
        --AND   trunc(nvl(sup.new_ship_date,sup.new_schedule_date)) >= p_from_date
        --AND   trunc(nvl(sup.new_ship_date,sup.new_schedule_date)) < p_to_date;

        CURSOR C_supply_demand6(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT dem.demand_id transaction_id
               --,nvl(dem.planned_inbound_due_date , dem.using_assembly_demand_date) new_due_date
        FROM msc_demands dem,
             msc_plans mp,
             msc_system_items msi ,
             msc_item_categories mic
        WHERE mic.sr_instance_id    = dem.sr_instance_id
        AND   mic.organization_id   = dem.organization_id
        AND   mic.inventory_item_id = dem.inventory_item_id
        AND
              dem.plan_id           = msi.plan_id
        AND   dem.sr_instance_id    = msi.sr_instance_id
        AND   dem.organization_id   = msi.organization_id
        AND   dem.inventory_item_id = msi.inventory_item_id
        AND   mp.plan_id   = dem.plan_id
        AND   mp.plan_type = 5
        AND ((     dem.origination_type = 1
               AND dem.source_organization_id <> dem.organization_id )
              OR
             (     dem.origination_type   = 30
               AND dem.demand_source_type = 8 ))
        AND
              dem.plan_id           = p_plan_id
        AND   dem.sr_instance_id    = p_instance_id
        AND   dem.organization_id   = p_organization_id
        AND   dem.inventory_item_id = p_inventory_item_id
        AND   nvl(dem.planned_inbound_due_date , dem.using_assembly_demand_date) >= p_from_date
        AND   nvl(dem.planned_inbound_due_date , dem.using_assembly_demand_date) < p_to_date;
        --AND   trunc(nvl(dem.planned_inbound_due_date , dem.using_assembly_demand_date)) >= p_from_date
        --AND   trunc(nvl(dem.planned_inbound_due_date , dem.using_assembly_demand_date)) < p_to_date;

        CURSOR C_supply_demand7(p_plan_id            IN NUMBER,
                                p_instance_id        IN NUMBER,
                                p_organization_id    IN NUMBER,
                                p_inventory_item_id  IN NUMBER,
                                p_from_date          IN DATE,
                                p_to_date            IN DATE    ) IS
        SELECT dem.demand_id transaction_id
               --,nvl(dem.old_using_assembly_demand_date , dem.using_assembly_demand_date) new_due_date
        FROM msc_demands dem,
             msc_plans mp,
             msc_system_items msi ,
             msc_item_categories mic
        WHERE mic.sr_instance_id = dem.sr_instance_id
        AND   mic.organization_id = dem.organization_id
        AND   mic.inventory_item_id = dem.inventory_item_id
        AND
              dem.plan_id           = msi.plan_id
        AND   dem.sr_instance_id    = msi.sr_instance_id
        AND   dem.organization_id   = msi.organization_id
        AND   dem.inventory_item_id = msi.inventory_item_id
        AND   mp.plan_id   = dem.plan_id
        AND   mp.plan_type = 5
        AND   dem.origination_type   = 30
        AND   dem.demand_source_type = 8
        AND
              dem.plan_id           = p_plan_id
        AND   dem.sr_instance_id    = p_instance_id
        AND   dem.organization_id   = p_organization_id
        AND   dem.inventory_item_id = p_inventory_item_id
        AND   nvl(dem.old_using_assembly_demand_date , dem.using_assembly_demand_date) >= p_from_date
        AND   nvl(dem.old_using_assembly_demand_date , dem.using_assembly_demand_date) < p_to_date;
        --AND   trunc(nvl(dem.old_using_assembly_demand_date , dem.using_assembly_demand_date)) >= p_from_date
        --AND   trunc(nvl(dem.old_using_assembly_demand_date , dem.using_assembly_demand_date)) < p_to_date;

        CURSOR c_supp_cap_overload_exception(p_plan_id           NUMBER ,
                                             p_sr_instance_id    NUMBER,
                                             p_supplier_id       NUMBER,
                                             p_supplier_site_id  NUMBER,
                                             p_inventory_item_id NUMBER,
                                             p_consumption_date  DATE) is
        SELECT distinct supply_id
        FROM msc_supplier_requirements
        WHERE plan_id           = p_plan_id
        AND sr_instance_id      = p_sr_instance_id
        AND supplier_id         = p_supplier_id
        AND supplier_site_id        = p_supplier_site_id
        AND inventory_item_id       = p_inventory_item_id
        AND trunc(consumption_date) = trunc(p_consumption_date);
        l_sql_stmt VARCHAR2(32000);

        CURSOR c_sd_49(p_plan_id        NUMBER,
                       p_sr_instance_id NUMBER,
                       p_demand_id      NUMBER) IS
        SELECT demand_id
        FROM msc_demands
        WHERE plan_id = p_plan_id
        AND sr_instance_id = p_sr_instance_id
        AND group_id IN (SELECT group_id
                         FROM msc_demands
                         WHERE plan_id = p_plan_id
                         AND sr_instance_id = p_sr_instance_id
                         AND demand_id = p_demand_id);

        CURSOR c_demand_84 (p_plan_id NUMBER,
                            p_excp_id NUMBER) IS
        SELECT md.demand_id
        FROM msc_exception_details med,
             msc_demands md
        WHERE med.plan_id = md.plan_id
        AND med.exception_type = 84
        AND med.exception_detail_id = p_excp_id
        AND med.plan_id = p_plan_id
        AND (   med.number1= md.demand_id
             OR med.number1 = md.original_demand_id);

        CURSOR RES_TRANS_C(p_plan_id NUMBER,
                           p_inst_id NUMBER,
                           p_org_id NUMBER,
                           p_dept_id NUMBER,
                           p_res_id NUMBER) IS
        SELECT supply_id
        FROM msc_resource_requirements
        WHERE plan_id = p_plan_id
        AND sr_instance_id = p_inst_id
        AND organization_id = p_org_id
        AND department_id = p_dept_id
        AND resource_id = p_res_id;

        CURSOR RES_TRANS_C1(p_plan_id   NUMBER,
                            p_inst_id   NUMBER,
                            p_org_id    NUMBER,
                            p_dept_id   NUMBER,
                            p_res_id    NUMBER,
                            p_supply_id NUMBER,
                            p_op_seq    NUMBER,
                            p_res_seq   NUMBER) IS
        SELECT supply_id,transaction_id
        FROM msc_resource_requirements
        WHERE plan_id       = p_plan_id
        AND sr_instance_id  = p_inst_id
        AND organization_id = p_org_id
        AND department_id   = p_dept_id
        AND resource_id     = p_res_id
        AND supply_id       = p_supply_id
        AND nvl(operation_seq_num,-1) = nvl(p_op_seq, nvl(operation_seq_num,-1))
        AND nvl(resource_seq_num,-1)  = nvl(p_res_seq, nvl(resource_seq_num,-1))
        AND parent_id = 2;

        CURSOR RES_TRANS_C2(p_plan_id NUMBER,
                            p_inst_id NUMBER,
                            p_org_id  NUMBER,
                            p_dept_id NUMBER,
                            p_res_id  NUMBER,
                            p_from_date DATE,
                            p_to_date   DATE) IS
        SELECT supply_id
        FROM msc_resource_requirements
        WHERE plan_id = p_plan_id
        AND sr_instance_id = p_inst_id
        AND organization_id = p_org_id
        AND department_id = p_dept_id
        AND resource_id = p_res_id
        AND (   (    trunc(start_date) >= p_from_date
                 AND NVL(trunc(end_date),p_to_date) <= p_to_date)
             OR (    p_from_date BETWEEN trunc(start_date)
                 AND NVL(trunc(end_date),p_to_date))
             OR (    p_to_date BETWEEN trunc(start_date) AND NVL(trunc(end_date),p_to_date))
             OR (    trunc(start_date) <= p_from_date
                 AND NVL(trunc(end_date),p_to_date) >= p_to_date) );

        CURSOR RES_TRANS_C3(p_plan_id NUMBER,
                            p_inst_id NUMBER,
                            p_org_id  NUMBER,
                            p_dept_id NUMBER,
                            p_res_id  NUMBER,
                            p_from_date DATE,
                            p_to_date   DATE) IS
        SELECT supply_id
        FROM msc_resource_requirements r,
             msc_supplies s,
             msc_system_items i
        WHERE r.plan_id = p_plan_id
        AND r.sr_instance_id = p_inst_id
        AND r.organization_id = p_org_id
        AND r.department_id = p_dept_id
        AND r.resource_id = p_res_id
        AND s.plan_id = r.plan_id
        AND s.transaction_id = r.supply_id
        AND s.plan_id = i.plan_id
        AND s.sr_instance_id = i.sr_instance_id
        AND s.organization_id = i.organization_id
        AND s.inventory_item_id = i.inventory_item_id
        AND trunc(s.need_by_date - (i.fixed_lead_time + (i.variable_lead_time*s.new_order_quantity)))
        BETWEEN p_from_date AND p_to_date;

        CURSOR PEG_TRANS_C(p_plan_id NUMBER,
                           p_end_peg_id NUMBER) IS
        SELECT transaction_id
        FROM msc_full_pegging
        WHERE plan_id = p_plan_id
        AND end_pegging_id = p_end_peg_id;

        CURSOR get_bucket_dates(p_plan_id NUMBER,
                                p_date DATE) IS
        SELECT trunc(bkt_start_date), trunc(bkt_end_date)
        FROM msc_plan_buckets
        WHERE plan_id = p_plan_id
        AND   p_date between bkt_start_date and bkt_end_date;

        l_transaction_id NUMBER;

    BEGIN
        l_sql_stmt := ' SELECT exception_id     , sr_instance_Id, organization_id, '||
                      ' inventory_item_id, supplier_id   , supplier_site_id,       '||
                      ' transaction_id   , demand_id     , exception_type,          '||
                      ' from_date        , to_date, budget_violation_date,         '||
                      ' department_id    , resource_id, end_pegging_id,            '||
                      ' operation_seq_num, resource_seq_num                        '||
                      ' FROM msc_exception_details_v med                           '||
                      ' WHERE med.plan_id = :plan_id                               '||
                      ' AND   nvl(med.category_set_id,2) = :category_set_id        ';

        l_sql_stmt := l_sql_stmt ||' AND '|| p_where_clause;
        --KSA_DEBUG(SYSDATE,'l_sql_stmt ...'||l_sql_stmt,'Parse_exceptions');
        IF g_category_set_id IS NULL THEN
            g_category_set_id := Get_Pref(p_plan_id, 'CATEGORY_SET_ID');
        END IF;
        --KSA_DEBUG(SYSDATE,'p_plan_id ...'||p_plan_id||'and g_category_set_id...'||g_category_set_id,'Parse_exceptions');
        OPEN c_exceptions for l_sql_stmt using p_plan_id, g_category_set_id;
        LOOP
            FETCH c_exceptions INTO rec_exceptions;
            EXIT WHEN c_exceptions%NOTFOUND;
            IF rec_exceptions.exception_type =20 THEN
                l_item_list(l_item_list.count()+1) := rec_exceptions.inventory_item_id;
            END IF;
            IF rec_exceptions.exception_type =28 THEN
                FOR rec_supp_cap_overload_excp IN c_supp_cap_overload_exception
                               (p_plan_id ,
                                rec_exceptions.sr_instance_id,
                                rec_exceptions.supplier_id,
                                rec_exceptions.supplier_site_id,
                                rec_exceptions.inventory_item_id,
                                rec_exceptions.from_date) LOOP
                    --populate_temp_table(rec_supp_cap_overload_excp.supply_id);
                    l_list(l_list.count()+1) := rec_supp_cap_overload_excp.supply_id;
                END LOOP;
            /*ELSIF rec_exceptions.exception_type in (52,49,84,85,86,87,88,89,90,92,93) THEN
                NULL;
            ELSIF (rec_exceptions.exception_type <> 48) AND
                (rec_exceptions.transaction_id IS NOT NULL
                OR (rec_exceptions.department_id IS NOT NULL
                AND rec_exceptions.resource_id IS NOT NULL)) THEN
                mrp_exception_details.g_resource_req_rows_selected := mrp_exception_details.g_resource_req_rows_selected + 1;
            */
            END IF;

            IF rec_exceptions.exception_type = 49 THEN
                OPEN c_sd_49(p_plan_id,
                         rec_exceptions.sr_instance_id,
                        rec_exceptions.demand_id);
                LOOP
                    FETCH c_sd_49 into l_transaction_id;
                    EXIT WHEN C_sd_49%NOTFOUND;
                    --supply/demand
                    --populate_temp_table(l_transaction_id);
                    l_list(l_list.count()+1) := l_transaction_id;
                END LOOP;
                CLOSE c_sd_49;
            ELSIF rec_exceptions.exception_type = 84 then
                DECLARE
                    l_temp number;
                BEGIN
                    OPEN c_demand_84(p_plan_id,
                                rec_exceptions.exception_id );
                    FETCH c_demand_84 into l_temp;
                    CLOSE c_demand_84;

                    --populate_temp_table(l_temp);
                    l_list(l_list.count()+1) := l_temp;
                END;
            ELSIF rec_exceptions.exception_type = 85 then
                DECLARE
                    l_from_date DATE;
                    l_to_date DATE;
                BEGIN
                    OPEN get_bucket_dates(p_plan_id,
                                          rec_exceptions.budget_violation_date);
                    FETCH get_bucket_dates INTO l_from_date, l_to_date;
                    CLOSE get_bucket_dates;

                    OPEN C_supply_demand1(p_plan_id,
                                          rec_exceptions.sr_instance_id,
                                          rec_exceptions.organization_id,
                                          rec_exceptions.inventory_item_id,
                                          l_from_date,
                                          l_to_date                       );

                    LOOP
                        FETCH C_supply_demand1 into l_transaction_id;
                        EXIT WHEN C_supply_demand1%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                    END LOOP;
                    CLOSE C_supply_demand1;

                    OPEN C_supply_demand2(p_plan_id,
                                          rec_exceptions.sr_instance_id,
                                          rec_exceptions.organization_id,
                                          rec_exceptions.inventory_item_id,
                                          l_from_date,
                                          l_to_date                       );

                    LOOP
                        FETCH C_supply_demand2 into l_transaction_id;
                        EXIT WHEN C_supply_demand2%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                    END LOOP;
                    CLOSE C_supply_demand2;

                    IF p_plan_id = -1 THEN
                        OPEN C_supply_demand3(p_plan_id,
                                              rec_exceptions.sr_instance_id,
                                              rec_exceptions.organization_id,
                                              rec_exceptions.inventory_item_id,
                                              l_from_date,
                                              l_to_date                       );

                        LOOP
                            FETCH C_supply_demand3 into l_transaction_id;
                            EXIT WHEN C_supply_demand3%NOTFOUND;
                            --populate_temp_table(l_transaction_id);
                            l_list(l_list.count()+1) := l_transaction_id;
                        END LOOP;
                        CLOSE C_supply_demand3;

                        OPEN C_supply_demand4(p_plan_id,
                                              rec_exceptions.sr_instance_id,
                                              rec_exceptions.organization_id,
                                              rec_exceptions.inventory_item_id,
                                              l_from_date,
                                              l_to_date                       );

                        LOOP
                            FETCH C_supply_demand4 into l_transaction_id;
                            EXIT WHEN C_supply_demand4%NOTFOUND;
                            --populate_temp_table(l_transaction_id);
                            l_list(l_list.count()+1) := l_transaction_id;
                        END LOOP;
                        CLOSE C_supply_demand4;
                    END IF;

                    OPEN C_supply_demand5(p_plan_id,
                                          rec_exceptions.sr_instance_id,
                                          rec_exceptions.organization_id,
                                          rec_exceptions.inventory_item_id,
                                          l_from_date,
                                          l_to_date                       );

                    LOOP
                        FETCH C_supply_demand5 into l_transaction_id;
                        EXIT WHEN C_supply_demand5%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                    END LOOP;
                    CLOSE C_supply_demand5;

                    OPEN C_supply_demand6(p_plan_id,
                                          rec_exceptions.sr_instance_id,
                                          rec_exceptions.organization_id,
                                          rec_exceptions.inventory_item_id,
                                          l_from_date,
                                          l_to_date                       );

                    LOOP
                        FETCH C_supply_demand6 into l_transaction_id;
                        EXIT WHEN C_supply_demand6%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                    END LOOP;
                    CLOSE C_supply_demand6;

                    OPEN C_supply_demand7(p_plan_id,
                                          rec_exceptions.sr_instance_id,
                                          rec_exceptions.organization_id,
                                          rec_exceptions.inventory_item_id,
                                          l_from_date,
                                          l_to_date                       );

                    LOOP
                        FETCH C_supply_demand7 into l_transaction_id;
                        EXIT WHEN C_supply_demand7%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                    END LOOP;
                    CLOSE C_supply_demand7;

                END;
            ELSIF rec_exceptions.demand_id IS NOT NULL
            AND rec_exceptions.end_pegging_id IS NOT NULL THEN
                OPEN PEG_TRANS_C(p_plan_id,
                            rec_exceptions.end_pegging_id);
                LOOP
                    FETCH PEG_TRANS_C INTO l_transaction_id;
                    EXIT WHEN PEG_TRANS_C%NOTFOUND;
                    --populate_temp_table(l_transaction_id);
                    l_list(l_list.count()+1) := l_transaction_id;
                END LOOP;
                CLOSE PEG_TRANS_C;
                --populate_temp_table(rec_exceptions.demand_id);
                l_list(l_list.count()+1) := rec_exceptions.demand_id;
                --KSA_DEBUG(SYSDATE,'demand_id and end_pegging_id are not null...2','Parse_exceptions');
            ELSIF rec_exceptions.resource_id IS NOT NULL THEN
                IF rec_exceptions.exception_type = 36 THEN
                    OPEN RES_TRANS_C3(p_plan_id,
                        rec_exceptions.sr_instance_id,
                        rec_exceptions.organization_id,
                        rec_exceptions.department_id,
                        rec_exceptions.resource_id,
                        rec_exceptions.from_date,
                        rec_exceptions.to_date);
                    LOOP
                        FETCH RES_TRANS_C3 INTO l_transaction_id;
                        EXIT WHEN RES_TRANS_C3%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                        --KSA_DEBUG(SYSDATE,'resource_idis not nulland ex typ 36...','Parse_exceptions');
                    END LOOP;
                    CLOSE RES_TRANS_C3;
                ELSIF rec_exceptions.transaction_id IS NOT NULL THEN
                    DECLARE
                        l_res_transaction_id NUMBER;
                    BEGIN
                        OPEN RES_TRANS_C1(p_plan_id,
                                    rec_exceptions.sr_instance_id,
                                    rec_exceptions.organization_id,
                                    rec_exceptions.department_id,
                                    rec_exceptions.resource_id,
                                    rec_exceptions.transaction_id,
                                    rec_exceptions.operation_seq_num,
                                    rec_exceptions.resource_seq_num);
                        LOOP
                            FETCH RES_TRANS_C1 INTO l_transaction_id, l_res_transaction_id;
                            EXIT WHEN RES_TRANS_C1%NOTFOUND;

                            --populate_temp_table(l_transaction_id);
                            l_list(l_list.count()+1) := l_transaction_id;
                            --populate_temp_table(l_res_transaction_id);
                            l_list(l_list.count()+1) := l_res_transaction_id;
                            --KSA_DEBUG(SYSDATE,'resource_idis not null and tr_id is not null...','Parse_exceptions');
                        END LOOP;
                        CLOSE RES_TRANS_C1;
                    END;
                ELSIF rec_exceptions.from_date IS NOT NULL
                AND rec_exceptions.to_date IS NOT NULL THEN

                    OPEN RES_TRANS_C2(p_plan_id,
                                rec_exceptions.sr_instance_id,
                                rec_exceptions.organization_id,
                                rec_exceptions.department_id,
                                rec_exceptions.resource_id,
                                rec_exceptions.from_date,
                                rec_exceptions.to_date);
                    LOOP
                        FETCH RES_TRANS_C2 INTO l_transaction_id;
                        EXIT WHEN RES_TRANS_C2%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                        --KSA_DEBUG(SYSDATE,'resource_idis not null and from and to dates are not null...','Parse_exceptions');
                    END LOOP;
                    CLOSE RES_TRANS_C2;
                ELSE
                    OPEN RES_TRANS_C(p_plan_id,
                                     rec_exceptions.sr_instance_id,
                                    rec_exceptions.organization_id,
                                    rec_exceptions.department_id,
                                    rec_exceptions.resource_id);

                    LOOP
                        FETCH RES_TRANS_C INTO l_transaction_id;
                        EXIT WHEN RES_TRANS_C%NOTFOUND;
                        --populate_temp_table(l_transaction_id);
                        l_list(l_list.count()+1) := l_transaction_id;
                    END LOOP;
                    CLOSE RES_TRANS_C;
                END IF;
            END IF;

            IF rec_exceptions.transaction_id IS NOT NULL THEN
                --populate_temp_table(rec_exceptions.transaction_id);
                l_list(l_list.count()+1) := rec_exceptions.transaction_id;
            ELSIF rec_exceptions.demand_id IS NOT NULL THEN
                --populate_temp_table(rec_exceptions.demand_id);
                l_list(l_list.count()+1) := rec_exceptions.demand_id;
            END IF;
        END LOOP;
        DECLARE
            v_insert_stmt VARCHAR2(2000);
        BEGIN

            FORALL i IN 1..l_list.count()
                INSERT INTO MSC_FORM_QUERY
                    (QUERY_ID, NUMBER1, NUMBER2, NUMBER3,
                     LAST_UPDATE_DATE, LAST_UPDATED_BY ,
                     CREATION_DATE, CREATED_BY,
                     LAST_UPDATE_LOGIN )
                VALUES (g_query_id, g_obj_sequence_id, g_sequence_id, l_list(i),
                        SYSDATE, fnd_global.user_id,
                        SYSDATE, fnd_global.user_id,
                        fnd_global.login_id);

            IF l_item_list.count() > 0 THEN
                g_items_list_exists := l_item_list.count();
                FORALL i IN 1..l_item_list.count()
                    INSERT INTO MSC_FORM_QUERY
                        (QUERY_ID, NUMBER1, NUMBER2, NUMBER4,
                         LAST_UPDATE_DATE, LAST_UPDATED_BY ,
                         CREATION_DATE, CREATED_BY,
                         LAST_UPDATE_LOGIN )
                    VALUES (g_query_id, g_obj_sequence_id, g_sequence_id, l_item_list(i),
                            SYSDATE, fnd_global.user_id,
                            SYSDATE, fnd_global.user_id,
                            fnd_global.login_id);
            ELSE
                g_items_list_exists := 0;
            END IF;
        END;
    EXCEPTION
        WHEN OTHERS THEN
            --KSA_DEBUG(SYSDATE,'Error: '||sqlerrm(sqlcode),'Parse_exceptions');
            RAISE;
    END Parse_exceptions;

  -- for criticality matrix , this function returns where clause
  -- for a specific category_id ( msc_pq_types.object_type)
  FUNCTION build_where_clause_new(p_query_id    IN NUMBER DEFAULT NULL,
                              p_source_type IN NUMBER DEFAULT NULL,
                              P_object_type IN NUMBER DEFAULT NULL)
                              RETURN VARCHAR2 IS
  CURSOR c_excp_criteria (p_object_type NUMBER) IS
    SELECT field_name,
           field_type,
           condition,
           low_value,
           high_value,
           hidden_from_field,
           data_set,
           source_type,
           object_type,
           lov_type,
           sequence,
           object_sequence_id
    FROM msc_selection_criteria_v
    WHERE folder_id = p_query_id
    AND   active_flag = 1
    AND   condition IS NOT NULL
    AND   source_type = p_source_type
    AND   object_type = p_object_type;

    CURSOR c_and_or (p_object_type NUMBER) IS
    SELECT COUNT(*)
    FROM msc_pq_types
    WHERE query_id = p_query_id
    AND   source_type = p_source_type
    AND   object_type = p_object_type
    AND   NVL(and_or_flag,1) = 1;


    l_row_count      NUMBER ;
    l_criticality_where     VARCHAR2(100);

    l_where_clause_segment  VARCHAR2(2000);
    l_where2_clause_segment VARCHAR2(2000);
    where_clause_segment    VARCHAR2(32000);

    l_field_name VARCHAR2(50);
    l_data_set   VARCHAR2(50);
    l_data_type  VARCHAR2(50);
    l_temp_match_str VARCHAR2(10);
    l_and_or number;
    l_match_str      VARCHAR2(10);

  begin
   l_row_count := 0;
   OPEN c_and_or(p_object_type);
   FETCH c_and_or INTO l_and_or;
   CLOSE c_and_or;

   IF l_and_or = 0 THEN
     l_match_str := ' OR ';
   ELSE
     l_match_str := ' AND ';
   END IF;

   FOR c_criteria_row IN c_excp_criteria(p_object_type) LOOP
      l_row_count := l_row_count + 1;
                IF (l_row_count = 1) THEN
                    l_temp_match_str := '';
                ELSE
                    l_temp_match_str :=  l_match_str;
                END IF;

                l_field_name := c_criteria_row.field_name ;
                l_data_set := c_criteria_row.data_set;
                l_data_type := c_criteria_row.field_type;
                l_where_clause_segment := get_where_clause
                                            (c_criteria_row.sequence,
                                             c_criteria_row.object_sequence_id,
                                             l_field_name,
                                             c_criteria_row.condition,
                                             c_criteria_row.low_value,
                                             c_criteria_row.high_value,
                                             c_criteria_row.hidden_from_field,
                                             l_data_set,
                                             l_data_type,
                                             c_criteria_row.lov_type,
                                             l_temp_match_str,
                                             NULL);
              IF l_where2_clause_segment IS NULL THEN
                    l_where2_clause_segment := '( '||l_where_clause_segment||' ) ';
              ELSE
                   l_where2_clause_segment := l_where2_clause_segment ||
                                               l_temp_match_str||' ( ' ||
                                               l_where_clause_segment  ||' ) ';

              END IF;
       END LOOP;
       IF where_clause_segment IS NULL THEN
                    where_clause_segment :=l_where2_clause_segment ;
       ELSE
                    where_clause_segment :=   where_clause_segment    ||
                                             '  OR ( '               ||
                                             l_where2_clause_segment ||' ) ';
       END if;
       l_where_clause_segment := NULL;
       l_where2_clause_segment := NULL;
       RETURN where_clause_segment;
  END build_where_clause_new;

  FUNCTION build_where_clause(p_query_id    IN NUMBER DEFAULT NULL,
                              P_source_type IN NUMBER DEFAULT NULL)
                              RETURN VARCHAR2 IS

    CURSOR c_criteria IS
    SELECT field_name,
           field_type,
           condition,
           DECODE(field_name       , 'PLANNING_MAKE_BUY_CODE',
                  hidden_from_field, low_value                ) low_value,
           high_value,
           hidden_from_field,
           data_set,
           source_type,
           object_type,
           lov_type,
           sequence,
           object_sequence_id
    FROM msc_selection_criteria_v
    WHERE folder_id = p_query_id
    AND   active_flag = 1
    AND   condition IS NOT NULL
    ORDER BY source_type, object_type, field_name;

    CURSOR c_excp_criteria (p_object_type NUMBER) IS
    SELECT field_name,
           field_type,
           condition,
           low_value,
           high_value,
           hidden_from_field,
           data_set,
           source_type,
           object_type,
           lov_type,
           sequence,
           object_sequence_id
    FROM msc_selection_criteria_v
    WHERE folder_id = p_query_id
    AND   active_flag = 1
    AND   condition IS NOT NULL
    AND   source_type = p_source_type
    AND   object_type = p_object_type;

    CURSOR c_excp_type IS
    SELECT DISTINCT object_type
    FROM msc_selection_criteria_v
    WHERE folder_id = p_query_id
    AND   active_flag = 1
    AND   source_type = p_source_type;

    CURSOR c_and_or IS
    SELECT count(*)
    FROM msc_personal_queries
    WHERE query_id = p_query_id
    AND NVL(and_or_flag,1) = 1;

    CURSOR c_excp_and_or (p_object_type NUMBER) IS
    SELECT COUNT(*)
    FROM msc_pq_types
    WHERE query_id = p_query_id
    AND   source_type = p_source_type
    AND   object_type = p_object_type
    AND   NVL(and_or_flag,1) = 1;

    l_and_or         NUMBER;
    l_match_str      VARCHAR2(10);
    l_temp_match_str VARCHAR2(10);
    l_row_count      NUMBER ;
    l_excp_where     VARCHAR2(100);

    l_where_clause_segment  VARCHAR2(2000);
    l_where2_clause_segment VARCHAR2(2000);
    where_clause_segment    VARCHAR2(32000);

    l_field_name VARCHAR2(50);
    l_data_set   VARCHAR2(50);
    l_data_type  VARCHAR2(50);

  begin
    l_row_count := 0;
    IF p_source_type =  0 THEN
        OPEN c_and_or;
        FETCH c_and_or INTO l_and_or;
        CLOSE c_and_or;
        IF l_and_or = 0 THEN
            l_match_str := ' OR ';
        ELSE
            l_match_str := ' AND ';
        END if;

        FOR c_criteria_row IN c_criteria LOOP
            l_row_count := l_row_count + 1;
            IF (l_row_count = 1) THEN
                l_temp_match_str := '';
            ELSE
                l_temp_match_str := l_match_str;
            END IF;
            l_excp_where := '';
            l_field_name := c_criteria_row.field_name ;
            l_data_set   := c_criteria_row.data_set;
            l_data_type  := c_criteria_row.field_type;
            l_where_clause_segment := get_where_clause
                                        (c_criteria_row.sequence,
                                         c_criteria_row.object_sequence_id,
                                         l_field_name,
                                         c_criteria_row.condition,
                                         c_criteria_row.low_value,
                                         c_criteria_row.high_value,
                                         c_criteria_row.hidden_from_field,
                                         l_data_set,
                                         l_data_type,
                                         c_criteria_row.lov_type,
                                         l_temp_match_str,
                                         l_excp_where);
            IF where_clause_segment IS NULL THEN
                where_clause_segment := ' ( '||l_where_clause_segment||' ) ';
            ELSE
                where_clause_segment := where_clause_segment||
                                        l_match_str         ||
                                        ' ( '||l_where_clause_segment||' ) ';
            END IF;
        END LOOP;
    ELSE
        FOR c_excp_type_row IN c_excp_type LOOP
            OPEN c_excp_and_or(c_excp_type_row.object_type);
            FETCH c_excp_and_or INTO l_and_or;
            CLOSE c_excp_and_or;

            IF l_and_or = 0 THEN
              l_match_str := ' OR ';
            ELSE
              l_match_str := ' AND ';
            END IF;

            l_excp_where := ' ( exception_type = '      ||
                            c_excp_type_row.object_type ||
                            ' AND source_type = '       ||
                            p_source_type               ||
                            ' ) AND ';
            FOR c_criteria_row IN c_excp_criteria(c_excp_type_row.object_type) LOOP
                l_row_count := l_row_count + 1;
                IF (l_row_count = 1) THEN
                    l_temp_match_str := '';
                ELSE
                    l_temp_match_str :=  l_match_str;
                END IF;

                l_field_name := c_criteria_row.field_name ;
                l_data_set := c_criteria_row.data_set;
                l_data_type := c_criteria_row.field_type;
                l_where_clause_segment := get_where_clause
                                            (c_criteria_row.sequence,
                                             c_criteria_row.object_sequence_id,
                                             l_field_name,
                                             c_criteria_row.condition,
                                             c_criteria_row.low_value,
                                             c_criteria_row.high_value,
                                             c_criteria_row.hidden_from_field,
                                             l_data_set,
                                             l_data_type,
                                             c_criteria_row.lov_type,
                                             l_temp_match_str,
                                             NULL);

                IF l_where2_clause_segment IS NULL THEN
                    l_where2_clause_segment := '( '||l_where_clause_segment||' ) ';
                ELSE
                    l_where2_clause_segment := l_where2_clause_segment ||
                                               l_temp_match_str||' ( ' ||
                                               l_where_clause_segment  ||' ) ';

                END IF;
            END LOOP;

            IF where_clause_segment IS NULL THEN
                where_clause_segment := ' (  '||l_excp_where||' (  ' ||
                                        l_where2_clause_segment      ||' )) ';
            ELSE
                    where_clause_segment := where_clause_segment    ||
                                        '  OR ( '               ||
                                        l_excp_where            ||
                                        l_where2_clause_segment ||' ) ';
            END IF;

            l_where_clause_segment := NULL;
            l_where2_clause_segment := NULL;
        END LOOP;
    END IF;
    RETURN where_clause_segment;
  END build_where_clause;

  FUNCTION build_order_where_clause(p_query_id IN NUMBER,
                                    p_plan_id  IN NUMBER)
                       RETURN VARCHAR2 IS

  CURSOR c_Ord_criteria(p_query_id    IN NUMBER,
                        p_object_type IN NUMBER,
                        p_source_type IN NUMBER,
                        p_sequence_id IN NUMBER) IS
    SELECT  field_name,
            field_type,
            condition,
            low_value,
            high_value,
            hidden_from_field,
            data_set,
            source_type,
            object_type,
            lov_type,
            sequence,
            object_sequence_id
    FROM msc_selection_criteria_v
    WHERE folder_id = p_query_id
    AND active_flag = 1
    AND condition IS NOT NULL
    AND source_type = p_source_type
    AND object_type = p_object_type
    AND object_sequence_id = p_sequence_id;

    CURSOR c_ord_type(p_query_id IN NUMBER) IS
    SELECT object_type,
           source_type,
           sequence_id,
           and_or_flag
    FROM msc_pq_types
    WHERE query_id = p_query_id
    AND active_flag = 1
    ORDER BY sequence_id;

    l_match_str      VARCHAR2(10);
    l_temp_match_str VARCHAR2(10);
    l_row_count      NUMBER ;
    l_p_row_count      NUMBER ;

    l_where_clause_segment  VARCHAR2(2000);
    l_where2_clause_segment VARCHAR2(2000);

    where_clause_segment    VARCHAR2(32000);
    l_excp_where_clause_segment    VARCHAR2(32000);

    l_field_name VARCHAR2(50);
    l_data_set   VARCHAR2(50);
    l_data_type  VARCHAR2(50);
    l_merge_criteria NUMBER;
    l_build_Excp_where NUMBER;
    l_criteria_row_seq NUMBER;

  BEGIN
--KSA_DEBUG(SYSDATE,'inside...','build_order_where_clause');

    l_p_row_count := 0;
    FOR c_ord_type_row IN c_ord_type(p_query_id) LOOP
        l_p_row_count := l_p_row_count + 1;

        l_match_str := ' OR ';
        l_build_Excp_where := 0;
        l_excp_where_clause_segment := NULL;

        --KSA_DEBUG(SYSDATE,'Object type is '||c_ord_type_row.object_type,'build_order_where_clause');
        l_row_count := 0;
        FOR c_criteria_row IN c_Ord_criteria(p_query_id,
                                             c_ord_type_row.object_type,
                                             c_ord_type_row.source_type,
                                             c_ord_type_row.sequence_id)
        LOOP
            l_row_count := l_row_count + 1;
            l_merge_criteria := 1;
            IF l_row_count = 1 AND l_p_row_count = 1 THEN
                l_temp_match_str := '';
            ELSIF l_row_count = 1 AND l_p_row_count > 1 THEN
                l_temp_match_str :=  ' OR ';
                l_merge_criteria := 0;
            ELSE
                IF c_ord_type_row.and_or_flag = 2 THEN
                    l_temp_match_str :=  ' OR ';
                    l_merge_criteria := 0;
                ELSE
                    l_temp_match_str :=  ' AND ';
                    l_merge_criteria := 1;
                END IF;
            END IF;

            l_field_name := c_criteria_row.field_name ;
            l_data_set   := c_criteria_row.data_set;
            l_data_type  := c_criteria_row.field_type;
--KSA_DEBUG(SYSDATE,'l_field_name...'||l_field_name,'MSC_PQ_UTILS.build_order_where_clause');
            l_where_clause_segment := MSC_PQ_UTILS.get_where_clause(c_criteria_row.sequence,
                                                       c_criteria_row.object_sequence_id,
                                                       l_field_name,
                                                       c_criteria_row.condition,
                                                       c_criteria_row.low_value,
                                                       c_criteria_row.high_value,
                                                       c_criteria_row.hidden_from_field,
                                                       l_data_set,
                                                       l_data_type,
                                                       c_criteria_row.lov_type,
                                                       l_temp_match_str, NULL);
--KSA_DEBUG(SYSDATE,'l_where_clause_segment...'||l_where_clause_segment,'MSC_PQ_UTILS.build_order_where_clause');
            IF l_field_name = 'EXCEPTION_TYPE' THEN
                IF l_merge_criteria = 1 THEN
                    l_build_Excp_where := 1;
                    l_criteria_row_seq := c_criteria_row.sequence;
                    IF l_excp_where_clause_segment IS NULL THEN
                        l_excp_where_clause_segment := '( '||l_where_clause_segment||' ) ';
                    ELSE
                        l_excp_where_clause_segment := l_excp_where_clause_segment||
                                                       l_temp_match_str||' ( '||
                                                       l_where_clause_segment||' ) ';
                    END IF;
                ELSE
                    MSC_PQ_UTILS.build_Excp_where(p_query_id,
                                                  c_ord_type_row.sequence_id,
                                                  c_criteria_row.sequence,
                                                  p_plan_id,
                                                  l_where_clause_segment,
                                                  l_where_clause_segment);
                END IF;
            END IF;
            IF l_field_name = 'EXCEPTION_TYPE' AND l_merge_criteria = 1 THEN
                NULL; -- Do not merge Exceptions where clause at this point.
            ELSE
                IF l_where2_clause_segment IS NULL THEN
                    l_where2_clause_segment := '( '||l_where_clause_segment||' ) ';
                ELSE
                    l_where2_clause_segment := l_where2_clause_segment||
                                               l_temp_match_str||' ( '||
                                               l_where_clause_segment||' ) ';
                END IF;
            END IF;
            IF l_field_name like '%ITEM_SEGMENTS%'
               OR l_field_name like '%SUPPLIER%'
               OR l_field_name like '%CUSTOMER%' THEN
               --OR l_field_name like '%ORGANIZATION%' THEN
                IF l_excp_where_clause_segment IS NULL THEN
                    l_excp_where_clause_segment := '( '||l_where_clause_segment||' ) ';
                ELSE
                    l_excp_where_clause_segment := l_excp_where_clause_segment||
                                                   l_temp_match_str||' ( '||
                                                   l_where_clause_segment||' ) ';
                END IF;
            END IF;
        END LOOP;
        IF l_build_Excp_where = 1 THEN
            MSC_PQ_UTILS.build_Excp_where(p_query_id,
                                          c_ord_type_row.sequence_id,
                                          l_criteria_row_seq,
                                          p_plan_id,
                                          l_excp_where_clause_segment,
                                          l_where_clause_segment);
            l_where2_clause_segment := l_where2_clause_segment||
                                       l_temp_match_str||' ( '||
                                       l_where_clause_segment||' ) ';
        END IF;
        IF where_clause_segment IS NULL THEN
            where_clause_segment := ' (  '||l_where2_clause_segment||' ) ';
        ELSE
            where_clause_segment := where_clause_segment||'  OR ( '||
                                    l_where2_clause_segment||' ) ';
        END IF;

        l_where_clause_segment := NULL;
        l_where2_clause_segment := NULL;
    END LOOP;
    --KSA_DEBUG(SYSDATE,'Exiting...','build_order_where_clause');
    RETURN where_clause_segment;
  EXCEPTION
    WHEN OTHERS THEN
        --KSA_DEBUG(SYSDATE,'Error...'||sqlerrm(sqlcode),'MSC_PQ_UTILS.build_order_where_clause');
        RETURN (NULL);
  END build_order_where_clause;

  FUNCTION get_where_clause (sequence            NUMBER,
                             obj_sequence        NUMBER,
                             field_name   IN OUT NOCOPY VARCHAR2,
                             operator            NUMBER,
                             low                 VARCHAR2,
                             high                VARCHAR2,
                             hidden_from         VARCHAR2,
                             data_set     IN OUT NOCOPY varchar2,
                             data_type    IN OUT NOCOPY VARCHAR2,
                             lov_type     IN     NUMBER,
                             p_match_str  IN     VARCHAR2,
                             p_excp_where IN     VARCHAR2)
                             RETURN VARCHAR2 IS
    low_value     VARCHAR2(200);
    high_value    VARCHAR2(200);
    translated_op VARCHAR2(30);
    where_clause_segment VARCHAR2(32000);
  BEGIN
    --KSA_DEBUG(SYSDATE,'inside...','get_where_clause');
    IF operator IN (11, 14) THEN
        IF data_type IN ('MULTI','ORG') THEN
            IF data_type = 'ORG' THEN
                data_set := '('||REPLACE(data_set,':',',')||')';
            END IF;
        END IF;

        IF p_excp_where IS NULL
         and data_type IN ('CHAR','DATE','NUMBER')
         and data_set IS NOT NULL THEN
            IF data_type IN ('DATE') THEN
                field_name := ' trunc( '||data_set||') ' ;
            ELSE
                field_name := data_set;
            END IF;
        ELSIF data_type IN ('DATE') THEN
            field_name := ' trunc( '||field_name||') ' ;
        END IF;
        low_value := '';
    ELSE
        --little trick to get correct field_name for exceptons
        IF p_excp_where IS NULL THEN
            if data_type IN ('CHAR','DATE','NUMBER') AND data_set IS NOT NULL THEN
                field_name := data_set;
            ELSIF data_type IN ('MULTI') THEN
                IF ( field_name  LIKE 'DEMAND%ITEM_SEGMENTS' ) THEN
                    field_name := 'ITEM_SEGMENTS';
                ELSIF ( field_name LIKE 'DEMAND%PRODUCT_FAMILY' ) THEN
                    field_name := 'PRODUCT_FAMILY';
                ELSIF ( INSTR(field_name,'~') > 0 ) THEN
                    field_name := SUBSTR(field_name, instr(field_name,'~')+1);
                END IF;
            END IF;
        END IF;

        IF operator = 13 THEN
            low_value := RTRIM(LTRIM(low));
            IF ( SUBSTR(low_value, LENGTH(low_value),1) <> '%') THEN
                low_value := low_value||'%';
            END IF;
            low_value := ''''||REPLACE(low_value, '''', '''''') ||'''';
        ELSIF data_type = 'CHAR' THEN
            low_value := ''''||REPLACE(low, '''', '''''') ||'''';
            IF (operator = 9) OR (operator = 10) THEN
                high_value := ''''||REPLACE(high, '''', '''''') ||'''';
            ELSE
                high_value := REPLACE(high, '''', '''''');
            END IF;
        ELSIF data_type = 'DATE' THEN
            IF operator = 12 THEN
                low_value := low;
                high_value := high;
            ELSE
                low_value := 'fnd_date.displaydate_to_date('||''''||low||''''||')';
                IF (operator = 9) OR (operator = 10) THEN
                    high_value := 'fnd_date.displaydate_to_date('||''''||high||''''||')';
                ELSE
                    high_value := high;
                END IF;
            END IF;
            field_name := ' trunc( '||field_name||') ' ;
        ELSIF data_type = 'NUMBER' THEN
            low_value := NVL(hidden_from, low);
            low_value := ''''||low_value||'''';

            high_value :=''''||high||'''';
        ELSIF data_type IN ('ORG','MULTI') THEN
            low_value := ''''||low||'''';
            high_value :=''''||high||'''';
            IF data_type IN ('MULTI')  THEN
                IF (field_name LIKE '%PRODUCT_FAMILY') THEN
                    field_name := 'PRODUCT_FAMILY';
                ELSIF (field_name LIKE '%ITEM_SEGMENTS') THEN
                    field_name := 'ITEM_SEGMENTS';
                ELSIF (field_name LIKE '%ORDER_TYPE') THEN
                    field_name := 'ORDER_TYPE';
                ELSIF (field_name LIKE '%EXCEPTION_TYPE') THEN
                    field_name := 'EXCEPTION_TYPE';
                END IF;
            END IF;
        END IF;
    END IF;
    IF operator = 1 THEN translated_op := ' = ';
    ELSIF operator = 2 THEN translated_op := ' <> ';
    ELSIF operator = 3 THEN translated_op := ' >= ';
    ELSIF operator = 4 THEN translated_op := ' <= ';
    ELSIF operator = 5 THEN translated_op := ' > ';
    ELSIF operator = 6 THEN translated_op := ' < ';
    ELSIF operator = 7 THEN translated_op := ' IS NOT NULL ';
    ELSIF operator = 8 THEN translated_op := ' IS NULL ';
    ELSIF operator = 9 THEN translated_op := ' BETWEEN ';
    ELSIF operator = 10 THEN translated_op := ' NOT BETWEEN ';
    ELSIF operator = 11 THEN translated_op := ' IN ';
    ELSIF operator = 12 THEN translated_op := ' BETWEEN ';
    ELSIF operator = 13 THEN translated_op := ' LIKE ';
    ELSIF operator = 14 THEN translated_op := ' NOT IN ';-- FOR Orders query
    END IF;
    IF operator IN (12) THEN -- rolling dates
        IF (high_value IS NULL) THEN
            where_clause_segment := where_clause_segment ||
                                    field_name           ||
                                    translated_op        ||
                                    ' trunc(sysdate)  AND  trunc(sysdate) + '||
                                    low_value ;
        ELSE
            where_clause_segment := where_clause_segment ||
                                    field_name           ||
                                    translated_op        ||
                                    ' trunc(sysdate) + '        ||
                                    low_value            ||
                                    ' AND '              ||
                                    ' trunc(sysdate) + '        ||
                                    high_value ;
        END IF;
    ELSIF operator IN (9,10) THEN -- operator is BETWEEN or OUTSIDE
        where_clause_segment := where_clause_segment ||
                                field_name           ||
                                translated_op        ||
                                low_value            ||
                                ' AND '              ||
                                high_value ;
    ELSIF operator IN (8,7) THEN -- operator is IS NOT NULL or IS NULL
        where_clause_segment := where_clause_segment ||
                                field_name           ||
                                translated_op ;
    ELSIF operator IN (1,2) AND data_type IN ('ORG')  THEN
        if operator = 2 then
            where_clause_segment := where_clause_segment ||
                                field_name           ||
                                translated_op ||
                                low_value;
        else
            where_clause_segment := where_clause_segment              ||
                                SUBSTR(data_set,
                                       1, INSTR(data_set,':')-1)  ||
                                translated_op                     ||
                                SUBSTR(hidden_from,
                                       1,INSTR(hidden_from,':')-1)||
                                ' AND '                           ||
                                SUBSTR(data_set, INSTR(data_set,':')+1)
              ||translated_op||SUBSTR(hidden_from,INSTR(hidden_from,':')+1);
        end if;
    ELSIF operator IN (1,2) AND data_type IN ('MULTI')  THEN
        --KSA_DEBUG(SYSDATE,'operation...'||operator,'get_where_clause');
        where_clause_segment := where_clause_segment||
                                data_set            ||
                                translated_op       ||
                                hidden_from ;
   ELSIF operator IN (11,14) THEN -- operator is AMONG
    --KSA_DEBUG(SYSDATE,'where_clause_segment...'||where_clause_segment,'MSC_PQ_UTILS.get_where_clause');
    where_clause_segment := where_clause_segment ||
      get_among_where_clause (sequence, obj_sequence,translated_op, field_name,
      operator, low, high, hidden_from, data_set, data_type)||' ';

  ELSIF operator = 13 THEN
    where_clause_segment := where_clause_segment || ' upper('||field_name||') '
        || translated_op|| UPPER(low_value);
   ELSE
    where_clause_segment := where_clause_segment ||
      field_name || translated_op||low_value ;
   END IF;
   --KSA_DEBUG(SYSDATE,'where_clause_segment...'||where_clause_segment,'get_where_clause');
  RETURN where_clause_segment;
 EXCEPTION
    WHEN OTHERS THEN
        --KSA_DEBUG(SYSDATE,'Error...'||sqlerrm(sqlcode),'MSC_PQ_UTILS.get_where_clause');
        RAISE;
 END get_where_clause;

 PROCEDURE retrieve_values (p_folder_id number) IS
    --or_rg_name VARCHAR2(30) := 'SCOPE1_RG';
    --or_rg_id RecordGroup;
    --gc_id GroupColumn;

    current_row NUMBER;

    CURSOR among_values IS
    SELECT msc.folder_object,
           mav.sequence,
           mav.object_sequence,
           mav.field_name,
           DECODE(msc.field_type,
                          'DATE', fnd_date.date_to_displaydate(
                                    fnd_date.canonical_to_date(mav.or_values)),
                        'NUMBER', DECODE(mc.lov_type,
                                                   1, TO_CHAR(
                                                       fnd_number.canonical_to_number(mav.or_values)),
                                                       mav.or_values),
                                  mav.or_values) or_values,
           mav.hidden_values
    FROM msc_among_values mav,
       msc_selection_criteria msc,
       msc_criteria mc
    WHERE mav.folder_id = p_folder_id
    AND msc.folder_id=mav.folder_id
    AND mc.folder_object =msc.folder_object
    AND mc.field_name = msc.field_name
    AND msc.sequence = mav.sequence
    AND nvl(msc.object_sequence_id,-1) = nvl(mav.object_sequence,-1);

    among_values_rec among_values%ROWTYPE;

    CURSOR c_delete IS
    SELECT distinct field_name
    FROM msc_among_values
    WHERE folder_id = p_folder_id;

    l_name varchar2(50);

  BEGIN
    --KSA_DEBUG(SYSDATE,'inside...p_folder_id'||p_folder_id,'MSC_PQ_UTILS.retrieve_values');

    /*OPEN c_delete;
    LOOP
      FETCH c_delete into l_name;
      EXIT WHEN c_delete%notfound;
      delete_rows(l_name);
    end loop;
    CLOSE c_delete;*/
    clear_values;

   OPEN among_values;
   Loop
        FETCH among_values INTO among_values_rec;
        EXIT WHEN among_values%NOTFOUND;
        store_values(among_values_rec.sequence,
                     among_values_rec.object_sequence,
                     among_values_rec.field_name,
                     among_values_rec.or_values,
                     among_values_rec.hidden_values);
   END LOOP;
   CLOSE among_values;
   --KSA_DEBUG(SYSDATE,'exiting...','MSC_PQ_UTILS.retrieve_values');
  END retrieve_values;

 FUNCTION get_among_where_clause (sequence          NUMBER,
                                  obj_sequence     NUMBER,
                                  t_operator        VARCHAR2,
                                  field_name IN OUT NOCOPY VARCHAR2,
                                  operator          NUMBER,
                                  low               VARCHAR2,
                                  high              VARCHAR2,
                                  hidden_from       VARCHAR2,
                                  data_set IN OUT NOCOPY VARCHAR2,
                                  datatype IN OUT NOCOPY VARCHAR2)
                                  RETURN VARCHAR2 IS

    --p_or_rg_name CONSTANT VARCHAR2(30) := 'SCOPE1_RG';
    --or_rg_name            VARCHAR2(30) := p_or_rg_name;
    tmp_str               VARCHAR2(5);
    total_rows            NUMBER;
    value_list            VARCHAR2(1000);
    current_value         VARCHAR2(155);
    v_one_record          VARCHAR2(100);
  BEGIN
   IF operator NOT IN (11,14) THEN -- operator is not AMONG
     RETURN '11=11';
   END IF;
   --KSA_DEBUG(SYSDATE,'inside...field_name is '||field_name,'get_among_where_clause');
   value_list :=NULL;
   total_rows := g_among_values.count; --Get_Group_Row_Count(or_rg_name);
   IF total_rows <= 0 THEN
      RETURN '11=11';
   END IF;

   FOR counter IN 1..total_rows LOOP
    IF NOT g_among_values.exists(counter) THEN
        NULL;
    ELSIF sequence =  g_among_values(counter).SEQUENCE AND
        nvl(obj_sequence,-99) =  nvl(g_among_values(counter).OBJECT_SEQUENCE,-99) AND -- W/L testing for items query
        field_name =  g_among_values(counter).FIELD_NAME AND
        g_among_values(counter).OR_VALUES IS NOT NULL THEN
        --Get_Group_Number_Cell(or_rg_name||'.SEQUENCE', counter) AND
        --Get_Group_Char_Cell(or_rg_name||'.OR_VALUES', counter) IS NOT NULL  THEN
        IF datatype <> 'ORG' THEN
            IF datatype = 'MULTI' THEN
                current_value := g_among_values(counter).HIDDEN_VALUES; --Get_Group_Char_Cell(or_rg_name||'.HIDDEN_VALUES', counter);
            ELSE
                current_value := NVL(g_among_values(counter).HIDDEN_VALUES,
                                     g_among_values(counter).OR_VALUES);
                    --NVL(Get_Group_Char_Cell(or_rg_name||'.HIDDEN_VALUES', counter),
                      -- Get_Group_Char_Cell(or_rg_name||'.OR_VALUES', counter));
                IF datatype='DATE' THEN
                    current_value :=
                        'fnd_date.displaydate_to_date('||''''||current_value||''''||')';
                ELSIF datatype ='CHAR' THEN
                    current_value :=''''||REPLACE(current_value, '''', '''''')||'''';
                ELSIF datatype = 'NUMBER' THEN
                    current_value :=''''||current_value||'''';
                END IF;
            END IF;
        ELSE -- datatype = 'ORG'
            v_one_record := g_among_values(counter).HIDDEN_VALUES; --Get_Group_Char_Cell(or_rg_name||'.HIDDEN_VALUES', counter);
            current_value := '('||
                             SUBSTR(v_one_record,1,INSTR(v_one_record,':')-1) ||','||
                             SUBSTR(v_one_record,INSTR(v_one_record,':')+1)||')';
        END IF;
        value_list :=value_list || tmp_str ||current_value;
        tmp_str :=', ';
    END IF;
   END LOOP;
   --KSA_DEBUG(SYSDATE,'Exiting, value_list is '||value_list,'MSC_PQ_UTILS.get_among_where_clause');
    IF datatype IN ('ORG','MULTI') THEN
        RETURN ' (1=1 AND (' ||data_set || t_operator ||' ( '||value_list||'))) ';
    ELSE
        RETURN ' (1=1 AND (' ||field_name || t_operator ||' ( '||value_list||'))) ';
    END IF;
   END get_among_where_clause;

   PROCEDURE build_Excp_where(p_query_id        IN NUMBER,
                              p_obj_sequence_id IN NUMBER,
                              p_sequence_id     IN NUMBER,
                              p_plan_id         IN NUMBER,
                              p_where_clause    IN VARCHAR2,
                              p_excp_where_clause IN OUT NOCOPY VARCHAR2,
                              p_match_str IN VARCHAR2 DEFAULT ' AND ') IS
      --v_excp_str VARCHAR2(1000);
      --v_excp_where VARCHAR2(1000);
      --v_insert_stmt VARCHAR2(2000);
      v_delete_stmt VARCHAR2(2000);
      l_where_clause VARCHAR2(32000);
      --v_sysdate := SYSDATE;
   BEGIN

    p_excp_where_clause := NULL;

    g_query_id        := p_query_id;
    g_obj_sequence_id := p_obj_sequence_id;
    g_sequence_id     := p_sequence_id;

    l_where_clause := REPLACE(REPLACE(p_where_clause,'SOURCE_SR_INSTANCE_ID','SOURCE_ORG_INSTANCE_ID'),'VENDOR_ID','SUPPLIER_ID');
    /*v_excp_str := ' SELECT DISTINCT '||p_query_id||', '||p_obj_sequence_id||', '||p_sequence_id  ||
                  ', med.TRANSACTION_ID, med.INVENTORY_ITEM_ID '                                   ||
                  ', med.SR_INSTANCE_ID,med.ORGANIZATION_ID  '                                   ||
                  ', SYSDATE, fnd_global.user_id,SYSDATE, fnd_global.user_id, fnd_global.login_id'||
                  ' FROM  MSC_EXCEPTION_DETAILS_V med ';*/
    /*v_excp_str := ' SELECT DISTINCT '||p_query_id||', '||p_obj_sequence_id||', '||p_sequence_id  ||
                  ', med.TRANSACTION_ID, med.INVENTORY_ITEM_ID '                                   ||
                  ', SYSDATE, fnd_global.user_id,SYSDATE, fnd_global.user_id, fnd_global.login_id'||
                  ' FROM  MSC_EXCEPTION_DETAILS_V med ';*/
    /*v_excp_where := ' WHERE med.plan_id = '||p_plan_id      ||
                    ' AND NVL(med.category_set_id,2) = 2'   ||
                    ' AND (   med.ORDER_NUMBER IS NOT NULL '||
                    '      OR med.INVENTORY_ITEM_ID IS NOT NULL)';*/
    /*v_excp_where := ' WHERE med.plan_id = '||p_plan_id      ||
                    ' AND NVL(med.category_set_id,2) = 2'   ||
                    ' AND (   med.TRANSACTION_ID IS NOT NULL '||
                    '      OR med.INVENTORY_ITEM_ID IS NOT NULL)';*/
    /*v_insert_stmt := ' INSERT INTO MSC_FORM_QUERY (QUERY_ID,'||
                     ' NUMBER1,NUMBER2,CHAR1,NUMBER3,'       ||
                     ' NUMBER4,NUMBER5,'                     ||
                     ' LAST_UPDATE_DATE, LAST_UPDATED_BY , ' ||
                     ' CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN )';*/
    /*v_insert_stmt := ' INSERT INTO MSC_FORM_QUERY (QUERY_ID,'||
                     ' NUMBER1,NUMBER2,NUMBER3,NUMBER4,'       ||
                     ' LAST_UPDATE_DATE, LAST_UPDATED_BY , ' ||
                     ' CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN )';*/
    --KSA_DEBUG(SYSDATE,'STMT IS '||v_insert_stmt||' '||v_excp_str||' '||v_excp_where||' '||p_where_clause,'build_Excp_where');
    v_delete_stmt := 'DELETE MSC_FORM_QUERY WHERE QUERY_ID = :p_query_id'
                     ||' AND NUMBER1 = :p_obj_sequence_id AND NUMBER2 = :p_sequence_id';
    --KSA_DEBUG(SYSDATE,'del STMT IS '||v_delete_stmt,'build_Excp_where');
    execute immediate v_delete_stmt using p_query_id, p_obj_sequence_id, p_sequence_id;
    --msc_get_name.execute_dsql(v_delete_stmt);
    --KSA_DEBUG(SYSDATE,'ex where is '||v_insert_stmt||v_excp_str||v_excp_where||' AND '||l_where_clause,'build_Excp_where');
    --msc_get_name.execute_dsql(v_insert_stmt||v_excp_str||v_excp_where||' AND '||l_where_clause);
    --KSA_DEBUG(SYSDATE,'where is '||l_where_clause,'build_Excp_where');
    Parse_exceptions(p_plan_id, l_where_clause);
    IF g_items_list_exists > 0 THEN
        p_excp_where_clause := '('||
                               ' TRANSACTION_ID IN (SELECT NUMBER3 FROM MSC_FORM_QUERY '||
                               ' WHERE QUERY_ID = '||p_query_id    ||
                               ' AND NUMBER1 = '||p_obj_sequence_id||
                               ' AND NUMBER2 = '|| p_sequence_id   ||
                               ' AND NUMBER3 IS NOT NULL' ||')'      ||
                               ' OR '||
                               ' INVENTORY_ITEM_ID '||
                               ' IN (SELECT NUMBER4 FROM MSC_FORM_QUERY '||
                               ' WHERE QUERY_ID = '||p_query_id||
                               ' AND NUMBER1 = '||p_obj_sequence_id||
                               ' AND NUMBER2 = '|| p_sequence_id||
                               ' AND NUMBER4 IS NOT NULL)'||
                               ')';
    ELSE
        p_excp_where_clause := '('||
                           ' TRANSACTION_ID IN (SELECT NUMBER3 FROM MSC_FORM_QUERY '||
                           ' WHERE QUERY_ID = '||p_query_id    ||
                           ' AND NUMBER1 = '||p_obj_sequence_id||
                           ' AND NUMBER2 = '|| p_sequence_id   ||
                           ' AND NUMBER3 IS NOT NULL' ||')'      ||
                           ')';
    END IF;
   END build_Excp_where;

   PROCEDURE store_values(p_sequence      IN NUMBER,
                          p_obj_sequence  IN NUMBER,
                          p_field_name    IN VARCHAR2,
                          p_or_values     IN VARCHAR2,
                          p_hidden_values IN VARCHAR2) IS
    l_count NUMBER;
   BEGIN
    --KSA_DEBUG(SYSDATE,'inside...p_field_name'||p_field_name,'MSC_PQ_UTILS.store_values');
    l_count := g_among_values.count;
    g_among_values(l_count+1).sequence := p_sequence;
    g_among_values(l_count+1).object_sequence := p_obj_sequence;
    g_among_values(l_count+1).field_name := p_field_name;
    g_among_values(l_count+1).or_values := p_or_values;
    g_among_values(l_count+1).hidden_values := p_hidden_values;
    --KSA_DEBUG(SYSDATE,'exiting...','MSC_PQ_UTILS.store_values');
   END store_values;

   PROCEDURE clear_values IS
   BEGIN
    g_among_values.delete;
   END clear_values;

   PROCEDURE delete_rows(p_field_name in varchar2) IS
    total_rows NUMBER;
    deleted_rows NUMBER:=0;
    l_cur_field_name varchar2(100);
   BEGIN
    --KSA_DEBUG(SYSDATE,'inside...p_field_name'||p_field_name,'delete_rows');
    total_rows :=g_among_values.count;
    IF total_rows > 0 THEN
        FOR counter IN 1 .. total_rows LOOP
            --KSA_DEBUG(SYSDATE,'total_rows...'||total_rows,'delete_rows');
            IF g_among_values.exists(counter - deleted_rows) THEN
                l_cur_field_name := g_among_values(counter - deleted_rows).FIELD_NAME;
                IF p_field_name = l_cur_field_name then
                    g_among_values.delete(counter - deleted_rows);
                    deleted_rows :=deleted_rows+1;
                    total_rows :=total_rows-1;
                END if;
            END IF;
        END Loop;
    END IF;
    --KSA_DEBUG(SYSDATE,'exiting...','delete_rows');
   END delete_rows;



   FUNCTION validate_index_use(p_query_id IN NUMBER,
                                p_query_type IN NUMBER) RETURN NUMBER IS

    	CURSOR c_validate IS
    	SELECT count(*)
    	FROM msc_selection_criteria msc,
       	     msc_personal_queries mpq
        WHERE (mpq.query_id = msc.folder_id
     	AND mpq.query_id = p_query_id and msc.active_flag=1)
        AND ( (     mpq.query_type = 1
         	    AND field_name in ('BUYER_NAME', 'ITEM_SEGMENTS',
         	                       'ABC_CLASS_NAME','CATEGORY',
         	                       'ORGANIZATION_CODE', 'PLANNER_CODE') ) --item
            OR(     mpq.query_type = 2
      	        AND field_name in ('RESOURCE_CODE',	'ORGANIZATION_CODE', 'DEPARTMENT_LINE_CODE') ) --res
            OR(     (mpq.query_type = 4 and source_type = 1)
    	        AND (   field_name like  '%ORGANIZATION_CODE%'
    	        	 OR field_name like '%PLANNER_CODE%'
    	        	 OR field_name like '%RESOURCE_CODE%'
    	        	 OR field_name like '%DEPARTMENT_CODE%'
    	        	 OR field_name like '%ITEM_SEGMENTS%'
    	        	 OR field_name like '%CATEGORY_NAME%'
    	        	 OR field_name like '%ITEM_NAME%') ) --excp
            OR ( (mpq.query_type = 4 and source_type = 2))
            OR (     mpq.query_type = 5
       	         AND field_name in ('ORGANIZATION_CODE', 'ITEM_NAME',
       	                            'CATEGORY_NAME', 'SUPPLIER_NAME',
       	                            'BUYER_NAME', 'PLANNER_CODE') ) --supplier
            OR (mpq.query_type = 6));  --loads

        CURSOR c_ord_qry(p_query_id IN NUMBER) IS
        SELECT mpt.source_type, mpt.object_type, mpt.sequence_id
        FROM msc_pq_types mpt
        WHERE mpt.query_id = p_query_id
        AND   mpt.active_flag = 1;

        CURSOR c_validate_ord(p_query_id    IN NUMBER,
                              P_source_type IN NUMBER,
                              P_object_type IN NUMBER,
                              P_sequence_id IN NUMBER) IS
        SELECT COUNT(*)
        FROM msc_selection_criteria msc,
             msc_pq_types mpt,
             msc_personal_queries mpq
        WHERE (mpq.query_id = mpt.query_id
        AND   mpq.query_id = p_query_id
        AND   mpt.active_flag = 1
        AND   msc.folder_id = mpt.query_id
        AND   msc.source_type = mpt.source_type
        AND   msc.object_type = mpt.object_type
        AND   msc.object_sequence_id = mpt.sequence_id
        AND   msc.active_flag=1
        AND   mpt.source_type = P_source_type
        AND   mpt.object_type = P_object_type
        AND   mpt.sequence_id = P_sequence_id)
        AND  (   msc.field_name like  '%ORGANIZATION_CODE%'
              OR msc.field_name like '%PLANNER_CODE%'
              OR msc.field_name like '%ITEM_SEGMENTS%'
              OR msc.field_name like '%CATEGORY_NAME%'
              OR msc.field_name like '%ITEM_NAME%');--orders

       CURSOR c_validate_wl IS
    	SELECT count(*)
    	FROM msc_selection_criteria msc,
       	     msc_personal_queries mpq
        WHERE mpq.query_id = msc.folder_id
     	AND mpq.query_id = p_query_id
     	AND msc.active_flag = 1
        AND mpq.query_type = 10
        AND ((        source_type = 1
    	     AND (   field_name like  '%ORGANIZATION_CODE%'
    	  	      OR field_name like '%PLANNER_CODE%'
    	   	      OR field_name like '%RESOURCE_CODE%'
    	   	      OR field_name like '%DEPARTMENT_CODE%'
    	   	      OR field_name like '%ITEM_SEGMENTS%'
    	   	      OR field_name like '%CATEGORY_NAME%'
    	   	      OR field_name like '%ITEM_NAME%') ) --excp
            OR source_type = 2);

       l_temp number;

       CURSOR c_groupby is
       SELECT distinct field_name
       FROM msc_selection_criteria
       WHERE folder_id = p_query_id
       AND NVL(count_by,2) = 1;

        l_dummy_field varchar2(100);
        l_profile varchar2(10);
        l_msg     VARCHAR2(2000);
        l_warnning NUMBER;
        l_query_exists NUMBER;

        index_validation_error EXCEPTION;
        PRAGMA EXCEPTION_INIT(index_validation_error, -20009);
    BEGIN
--KSA_DEBUG(SYSDATE,'VI p_query_id <> '||p_query_id||' p_query_Type '||p_query_type,'validate_index_use');
        l_query_exists := 0;
        l_warnning := 1;
        IF p_query_type = 10 THEN
            FOR detailQrec IN detailQCur(p_query_id) LOOP
                l_warnning := validate_index_use(detailQrec.query_id, detailQrec.query_type);
                IF l_warnning < 1 THEN
                    raise index_validation_error;
                END IF;
                l_query_exists := 1; -- at least one query exists
            END LOOP;
            -- ----------------------------------------
            -- Now check for index usage for exceptions
            -- ----------------------------------------
            --p_query_type := 4;
        --ELSE
            --p_query_type := p_query_type;
        END IF;
        IF p_query_type = 9 THEN
            FOR rec_ord_qry IN c_ord_qry(p_query_id) LOOP
                l_temp := 0;
                OPEN c_validate_ord(p_query_id             ,
                                    rec_ord_qry.source_type,
                                    rec_ord_qry.object_type,
                                    rec_ord_qry.sequence_id);
                FETCH c_validate_ord into l_temp;
                IF l_temp = 0 THEN
                    CLOSE c_validate_ord;
                    EXIT;
                END IF;
                CLOSE c_validate_ord;
            END LOOP;
        ELSIF p_query_type = 10 THEN
            open c_validate_wl;
            fetch c_validate_wl into l_temp;
            close c_validate_wl;
        ELSE
            open c_validate;
            fetch c_validate into l_temp;
            close c_validate;
        END IF;
        l_profile := nvl(FND_PROFILE.VALUE('MSC_PQUERY_EXEC_WITH_CRITERIA'), 'Y');
        l_temp := nvl(l_temp,0);
        if (l_temp = 0 and l_profile = 'Y' ) then
	        if (p_query_type = 1) then
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_ITEM_YES');
	        elsif (p_query_type = 2) then
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_RES_YES');
	        elsif (p_query_type = 4) THEN
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_EXCP_YES');
	        elsif (p_query_type = 5) then
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_SUPP_YES');
            elsif (p_query_type = 9) THEN -- orders
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_ORD_YES');
            elsif (p_query_type = 9) THEN -- orders
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_ORD_YES');
            elsif (p_query_type = 10) THEN -- Wlist
                NULL;
                --fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_ORD_YES');
            else
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK');
            end if;
	        l_msg:= fnd_message.get;
	        l_warnning := -1;
	        raise index_validation_error;
        end if;

        if (l_temp = 0 and l_profile = 'N' ) then
	        if (p_query_type = 1) then
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_ITEM_NO');
	        elsif (p_query_type = 2) then
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_RES_NO');
	        elsif (p_query_type = 4) THEN
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_EXCP_NO');
	        elsif (p_query_type = 5) then
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_SUPP_NO');
            elsif (p_query_type = 9) THEN -- orders
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK_ORD_NO');
            elsif (p_query_type = 10) THEN -- Wlist
                NULL;
            else
                fnd_message.set_name('MSC', 'MSC_PQ_INDEX_CHECK');
            end if;
	        --fnd_message.hint;
	        l_warnning := 0;
	        l_msg:= fnd_message.get;
	        raise index_validation_error;
        end if;

        if (p_query_type = 4) then
            l_temp := 0;
            open c_groupby;
            loop
                fetch c_groupby into l_dummy_field;
                exit when c_groupby%notfound;
    	        l_temp := l_temp + 1;
            end loop;
            close c_groupby;

            if (l_temp > 5) then
                fnd_message.set_name('MSC', 'MSC_PQ_GROUPBY_CHECK');
	            --fnd_message.error;
	            l_msg := FND_MESSAGE.get;
	            l_warnning := -1;
	            raise index_validation_error;
            end if;
        end if;

        RETURN l_warnning; -- 1, successful validation
  EXCEPTION
    WHEN index_validation_error THEN
        G_PQ_ERROR_MESSAGE := l_msg;
        RETURN l_warnning;
    WHEN OTHERS THEN
        G_PQ_ERROR_MESSAGE := sqlerrm(sqlcode);
        RETURN -2;
  end validate_index_use;

  PROCEDURE delete_from_results_table(p_query_id IN NUMBER,
                                      p_plan_id  IN NUMBER) IS
  BEGIN
    --KSA_DEBUG(SYSDATE,' p_query_id <> '||p_query_id,'delete_from_results_table');
    DELETE msc_pq_results
	WHERE query_id = p_query_id
	AND plan_id = p_plan_id ;
  END delete_from_results_table;

  PROCEDURE execute_one(p_plan_id IN NUMBER,
                        p_calledFromUI IN NUMBER,
                        p_partOfWorklist IN NUMBER,
                        p_query_id IN NUMBER,
                        p_query_type IN NUMBER,
                        p_execute_flag BOOLEAN DEFAULT TRUE,
                        p_master_query_id IN NUMBER DEFAULT NULL) IS

        where_clause_segment VARCHAR2(32000);
        where_clause_segment2 VARCHAR2(32000);

        CURSOR c_query_name (p_query NUMBER) IS
        SELECT query_name
        FROM msc_personal_queries
        WHERE query_id = p_query;

        l_query_name VARCHAR2(80);
        test BOOLEAN;

        CURSOR c_plans IS
        SELECT compile_designator
        FROM msc_plans
        WHERE plan_id = -1;

       l_plan VARCHAR2(30);
       l_query_type_temp NUMBER;
       l_master_query_id NUMBER;
       l_response NUMBER;
       l_category_id NUMBER;
       l_dummy NUMBER;
    BEGIN
      -- for criticality matrix , we are using p_master_query_id
      -- to pass category_id to the build_where_clause function
       if p_query_type  <> 12  then
        l_master_query_id := p_master_query_id;
       else
        l_category_id := p_master_query_id;
       end if;

        IF NOT p_execute_flag THEN
	        RETURN;
        END IF;
--KSA_DEBUG(SYSDATE,'q p_query_id <> '||p_query_id||' p_query_Type '||p_query_type,'execute_one');
        IF p_query_type <> 10 AND p_partOfWorklist = 1 THEN
            NULL;
        ELSE
            l_response := validate_index_use(p_query_id, p_query_type);
/*            IF l_response < 0 THEN
                Raise_Application_Error(-20001,G_PQ_ERROR_MESSAGE);
                RETURN; -- need to show some error
            END IF;*/
        END IF;

--KSA_DEBUG(SYSDATE,'before execute query, '||p_query_id||' p_query_Type '||p_query_type,'execute_one');
        IF g_category_set_id IS NULL THEN
            g_category_set_id := Get_Pref(p_plan_id, 'CATEGORY_SET_ID');
        END IF;
        IF p_query_type = 10 THEN
            delete_from_results_table(p_query_id,
                                      p_plan_id);
            FOR detailQrec IN detailQCur(p_query_id) LOOP
                 execute_one(p_plan_id,
                             0, -- not called from UI
                             1, -- p_partOfWorklist
                             detailQrec.query_id,
                             detailQrec.query_type,
                             TRUE, --p_execute_flag
                             p_query_id); -- master query_id
                --l_query_exists := 1; -- at least one query exists
            END LOOP;
            -- ----------------------------------------
            -- Now check for index usage for exceptions
            -- ----------------------------------------
            l_query_type_temp := 4;
        ELSE
            l_query_type_temp := p_query_type;
        END IF;
        IF p_query_type IN (1,2,5,6) THEN
            retrieve_values(p_query_id);
            where_clause_segment := build_where_clause(p_query_id, 0);
            IF (where_clause_segment is null) THEN
                where_clause_segment := ' ( -99 = -99 ) ';
            END IF;
			where_clause_segment := where_clause_segment|| 'AND CATEGORY_SET_ID = '||g_category_set_id;
            where_clause_segment := ' ( '||where_clause_segment||' ) ';
--	        KSA_DEBUG(SYSDATE,'w clause <> '||where_clause_segment,'execute_one');
	        msc_pers_queries.populate_result_table(p_query_id,
	                                               p_query_type,
	                                               p_plan_id,
	                                               where_clause_segment,
	                                               p_execute_flag,
	                                               l_master_query_id);
        ELSIF p_query_type = 9 then
            msc_pq_utils.retrieve_values(p_query_id);
            where_clause_segment := msc_pq_utils.build_order_where_clause
                                                    (p_query_id,
                                                     p_plan_id);
            IF (where_clause_segment IS NULL) THEN
                where_clause_segment := ' ( -99 = -99 ) ';
            END IF;
            where_clause_segment := ' ( '||where_clause_segment||' ) ';
            -- -----------------------------------
            -- This need to be set in the UI code.
            -- -----------------------------------
            --msc_popup_pvt.g_order_where_clause := ' AND '||where_clause_segment;
            /* Not required to populate results table if executed from UI.*/
            --KSA_DEBUG(SYSDATE,'*2* w clause <> '||where_clause_segment,'execute_one');
            IF p_calledFromUI <> 1 THEN
				where_clause_segment := where_clause_segment|| 'AND CATEGORY_SET_ID = '||g_category_set_id;
                msc_pers_queries.populate_result_table
                                    (p_query_id,
                                     p_query_type,
                                     p_plan_id,
                                     where_clause_segment,
                                     p_execute_flag,
                                     l_master_query_id);
            END IF;

        ELSIF p_query_type = 12 THEN
            retrieve_values(p_query_id);
            where_clause_segment := build_where_clause_new(p_query_id, 100, l_category_id);
            msc_pers_queries.populate_result_table(p_query_id,
              p_query_type, -1,where_clause_segment,
              p_execute_flag, p_master_query_id, p_partOfWorklist);


        ELSIF p_query_type IN (4,10) THEN
            IF P_QUERY_TYPE = 10 THEN
                -- --------------------------
                -- Check if worklist also contains
                -- Exceptions. If yes, continue to process them
                -- Else, do nothing.
                -- -------------------------------
                l_dummy := 0;
                OPEN WlExcepCur(p_query_id);
                FETCH WlExcepCur INTO l_dummy;
                IF WlExcepCur%NOTFOUND THEN
                    l_dummy :=-99; -- Just to flag no process
                END IF;
                CLOSE WlExcepCur;
            END IF;
            IF p_query_type = 4 OR
               (p_query_type = 10 AND l_dummy <> -99) THEN
                retrieve_values(p_query_id);
                where_clause_segment := build_where_clause(p_query_id, 1);
                where_clause_segment2 := build_where_clause(p_query_id, 2);
                IF (where_clause_segment IS NULL) THEN
                    where_clause_segment := ' ( -99 = -99 ) ';
                END IF;
                IF (where_clause_segment2 IS NULL) THEN
                    where_clause_segment2 := ' ( -99 = -99 ) ';
                END IF;
                IF where_clause_segment IS NOT NULL THEN
                    where_clause_segment := ' ( '||where_clause_segment||' ) ';
    --                KSA_DEBUG(SYSDATE,'*3* w clause <> '||where_clause_segment,'execute_one');
                    msc_pers_queries.populate_result_table(p_query_id,
                                                           p_query_type,
    		                                               p_plan_id,
    		                                               where_clause_segment,
    		                                               p_execute_flag,
    		                                               l_master_query_id);
                END IF;
    	        IF where_clause_segment2 IS NOT NULL THEN
    	            where_clause_segment2 := ' ( '||where_clause_segment2||' ) ';
                    msc_pers_queries.populate_result_table(p_query_id,
    		            p_query_type, -1,where_clause_segment2,
    		            p_execute_flag,l_master_query_id);
    	        END IF;
    	    END IF;
			IF P_QUERY_TYPE = 10 THEN
                -- --------------------------
                --Run worklist Summarization
                -- pass -99
                -- -------------------------------
                --KSA_DEBUG(SYSDATE,'before execute populate_result_table, '||p_query_id||' l_master_query_id '||l_master_query_id,'execute_one');
                msc_pers_queries.populate_result_table(p_query_id,
                                                       -99,
    		                                           p_plan_id,
    		                                           '',
    		                                            p_execute_flag,
    		                                            l_master_query_id);
				set_top_action(p_plan_id, p_query_id);
			END IF;
        END IF;

      /*OPEN c_query_name(p_query_id);
      FETCH c_query_name into l_query_name;
      CLOSE c_query_name;*/


      COMMIT;  --test := APP_FORM.QUIETCOMMIT;
      --do_key('commit_form'); --quietcommit is there..

      --copy(p_query_id, 'viewby_control.query_id');
      --copy(l_query_name, 'viewby_control.query_name');
     --set_item_property('viewby_control.query_name', item_is_valid, property_on);


    EXCEPTION
        WHEN OTHERS THEN
            DECLARE
                l_error VARCHAR2(255);
            BEGIN
                l_error := substr(sqlerrm(sqlcode),1,250);
                G_PQ_ERROR_MESSAGE:= l_error;
                --COPY(l_error,'GLOBAL.PQ_ERROR_MESSAGE');
            END;
            RAISE;
  END execute_one;

FUNCTION get_error RETURN VARCHAR2 IS
BEGIN
    RETURN G_PQ_ERROR_MESSAGE;
END get_error;

PROCEDURE set_impl IS

BEGIN
    NULL;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END set_impl;

PROCEDURE plans_release IS

BEGIN
    set_impl;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END plans_release;

FUNCTION get_release_status(p_sr_instance_id IN NUMBER,
                            P_instance_code IN OUT NOCOPY VARCHAR2)
                            RETURN NUMBER IS
    l_allow_release_flag NUMBER;

    CURSOR cur_release_flag(p_instance_id NUMBER) IS
    SELECT DECODE(apps_ver,3,NVL(allow_release_flag ,2),
                           4,NVL(allow_release_flag ,2),1) allow_release_flag,
                           instance_code
    FROM msc_apps_instances
    WHERE instance_id = nvl(p_sr_instance_id,-1);
BEGIN
    OPEN cur_release_flag(p_sr_instance_id);
    FETCH cur_release_flag into l_allow_release_flag,p_instance_code;
    IF cur_release_flag%NOTFOUND THEN
        l_allow_release_flag := 2;
    END IF;
    CLOSE cur_release_flag;
    RETURN( l_allow_release_flag) ;
END get_release_status;

PROCEDURE release_status(errbuf    OUT NOCOPY VARCHAR2,
                         retcode   OUT NOCOPY NUMBER,
                         p_plan_id IN NUMBER,
                         p_transaction_Id IN NUMBER,
                         p_sr_Instance_Id NUMBER) IS

   v_err_msg varchar2(80);
   l_instance_code varchar2(30);
BEGIN
    If get_release_status(p_sr_Instance_Id,l_instance_code) = 2 then
        fnd_message.set_name('MSC','MSC_ALLOW_RELEASE_INSTANCE');
        fnd_message.set_token('INSTANCE',l_instance_code);
        errbuf := fnd_message.get;
        retcode := 1;
    end if;
END release_status;

-- ---------------------------------------------
-- This program will be called from
-- MSC_GET_BIS_VALUES.ui_post_plan (MSCBISUB.PLS)
-- ----------------------------------------------

PROCEDURE execute_plan_queries(errbuf    OUT NOCOPY VARCHAR2,
                               retcode   OUT NOCOPY NUMBER,
                               p_plan_id IN NUMBER) IS
    CURSOR cur_queries IS
    SELECT plq.query_Id
    FROM msc_plan_queries plq,
         msc_personal_queries pq
    WHERE plq.plan_id = p_plan_Id
    AND   plq.query_id = pq.query_id
    AND   pq.query_type = 9;

    CURSOR cur_orders(p_transaction_Id IN NUMBER) IS
    SELECT sr_instance_id,organization_id, organization_code
    FROM msc_orders_v
    WHERE plan_id = p_plan_Id
    AND p_transaction_Id = p_transaction_Id;
    -- and <order type restrictions>

    CURSOR check_release_method IS
    SELECT AUTO_RELEASE_METHOD
    FROM msc_plans
    WHERE plan_id = p_plan_Id;

    TYPE r_cursor is REF CURSOR;
    t_cur r_cursor;
    rec_orders cur_orders%ROWTYPE;

    l_stmt VARCHAR2(2000);
    l_list VARCHAR2(500);

    l_transaction_id NUMBER;
    l_auto_release   NUMBER;
    l_user_id		 NUMBER :=FND_PROFILE.VALUE('USER_ID');
    l_errbuf VARCHAR2(2000);
    l_retcode NUMBER;
BEGIN
    -- ---------------------------------
    -- Check for release method.
    -- If auto release is not based on
    -- 'Orders' query, do nothing.
    -- ---------------------------------
    OPEN check_release_method;
    FETCH check_release_method INTO l_auto_release;
    CLOSE check_release_method;
    IF NVL(l_auto_release,0) <> 3 THEN
        RETURN;
    END IF;
    FOR rec_queries IN cur_queries LOOP
        execute_one(p_plan_id,
                    2,
                    2,
                    rec_queries.query_id,
                    9);
        IF l_list IS NULL THEN
            l_list:= rec_queries.query_id;
        ELSE
            l_list:= l_list||','||rec_queries.query_id;
        END IF;
    END LOOP;
    IF l_List IS NOT NULL THEN
        l_list := '('||l_list||')';
        l_stmt := 'SELECT DISTINCT TRANSACTION_ID FROM MSC_PQ_RESULTS '||
                  'WHERE QUERy_ID IN '||l_lIST;
        OPEN t_cur FOR l_stmt;
        LOOP
            FETCH t_cur INTO l_transaction_id;
            EXIT WHEN t_cur%NOTFOUND;
            OPEN cur_orders(l_transaction_id);
            FETCH cur_orders INTO rec_orders;
            IF cur_orders%FOUND THEN
                release_status(l_errbuf,l_retcode,
                               p_plan_id, rec_orders.sr_instance_id,
                               rec_orders.organization_id);
                IF l_retcode < 0 THEN
                    plans_release;
                END IF;
            END IF;
            CLOSE cur_orders;
        END LOOP;
        CLOSE t_cur;
    END IF;
    retcode := 0;
EXCEPTION
    WHEN OTHERS THEN
        errbuf := 'unknown error'||sqlerrm(sqlcode);
        retcode := 1;
END execute_plan_queries;

-- ---------------------------------------------
-- This program will be called from
-- MSC_GET_BIS_VALUES.ui_post_plan (MSCBISUB.PLS)
-- ----------------------------------------------

PROCEDURE execute_plan_worklists(errbuf    OUT NOCOPY VARCHAR2,
                                 retcode   OUT NOCOPY NUMBER,
                                 p_plan_id IN NUMBER) IS
    CURSOR cur_worklists IS
    SELECT plq.query_Id,QUERY_TYPE
    FROM msc_plan_queries plq,
         msc_personal_queries pq
    WHERE plq.plan_id = p_plan_Id
    AND plq.query_id = pq.query_id
    AND pq.query_type = 10;

    l_errbuf VARCHAR2(2000);
    l_retcode NUMBER;
BEGIN

    FOR rec_worklists IN cur_worklists LOOP
        execute_one(p_plan_id,
                    0,
                    0,
                    rec_worklists.query_id,
                    rec_worklists.query_type,
                    TRUE,
                    rec_worklists.query_id);
    END LOOP;

    retcode := 0;
EXCEPTION
    WHEN OTHERS THEN
        errbuf := 'unknown error'||sqlerrm(sqlcode);
        retcode := 1;
END execute_plan_worklists;

PROCEDURE set_top_action(p_plan_id IN NUMBER, p_query_id IN NUMBER) IS
		cursor c_top_priority(p_PRIORITY in number) is
		SELECT nvl(pqt.DETAIL_QUERY_ID, pqt.query_id) query_id
        FROM MSC_PQ_TYPES pqt
        WHERE pqt.query_id = p_query_id
		and pqt.PRIORITY = p_priority;
        --AND   pqt.DETAIL_QUERY_ID is not null;

		cursor c_top_actions is
		select distinct priority
		from msc_pq_results
		where plan_id = p_plan_id
		and query_id = p_query_id
		and SUMMARY_DATA = 1;
	l_query_id number;
begin
	for rec_top_actions in c_top_actions loop
		l_query_id := 0;
		open c_top_priority(rec_top_actions.priority);
		fetch c_top_priority into l_query_id;
		close c_top_priority;
		if nvl(l_query_id,0) <> 0 then
			update msc_pq_results
			set DETAIL_QUERY_ID = l_query_id
			where plan_id = p_plan_id
			and query_id = p_query_id
			and SUMMARY_DATA = 1
			and priority = rec_top_actions.priority;
		end if;
	end loop;
end set_top_action;

END MSC_PQ_UTILS;

/
