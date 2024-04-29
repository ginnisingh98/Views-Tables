--------------------------------------------------------
--  DDL for Package Body FTE_LANE_SEARCH_QUERY_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_LANE_SEARCH_QUERY_GEN" AS
/* $Header: FTELNQYB.pls 120.4 2006/01/23 22:44:22 pkaliyam ship $ */

  -- global variables
  g_type1       CONSTANT        VARCHAR2(1) := '1';
  g_type2       CONSTANT        VARCHAR2(1) := '2';
  g_type3       CONSTANT        VARCHAR2(1) := '3'; -- common
  g_type4       CONSTANT        VARCHAR2(1) := '4'; -- order by for first query

  g_bind_counter1               NUMBER; -- relax up
  g_bind_counter2               NUMBER; -- relax down
  g_bind_counter_common         NUMBER;
  g_bind_counter_orderby        NUMBER;

  g_bind_counter_global         NUMBER;

  --
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'FTE_LANE_SEARCH_QUERY_GEN';
  --

  -- ----------------------------------------------------------------
  -- Name:              Process_Bind_Var
  -- Type:              Procedure
  --
  -- Description:       This procedure takes in bind variables and the
  --                    type of bind variable and puts it in the
  --                    appropriate bind variable array, increments
  --                    the corresponding bind variable counter
  --
  -- -----------------------------------------------------------------
  PROCEDURE Process_Bind_Var(p_bindvars                 IN OUT  NOCOPY FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                             p_bindvar                  IN      VARCHAR2,
                             p_bindtype                 IN      VARCHAR2,
                             p_bind_counter_type        IN      VARCHAR2) IS

  l_bindvar_type        FTE_LANE_SEARCH_QUERY_GEN.bindvar_type;

        --
        l_debug_on BOOLEAN;
        --
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PROCESS_BIND_VAR';
        --
  BEGIN

        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_BINDVAR',P_BINDVAR);
            WSH_DEBUG_SV.log(l_module_name,'P_BINDTYPE',P_BINDTYPE);
            WSH_DEBUG_SV.log(l_module_name,'P_BIND_COUNTER_TYPE',P_BIND_COUNTER_TYPE);
        END IF;
        --
        l_bindvar_type.bindvar := p_bindvar;
        l_bindvar_type.bindtype := p_bindtype;
        l_bindvar_type.bindvarindex := g_bind_counter_global;

        IF (p_bind_counter_type = g_type1) THEN
            p_bindvars(g_bind_counter1) := l_bindvar_type;
            g_bind_counter1 := g_bind_counter1 + 1;
        ELSIF (p_bind_counter_type = g_type2) THEN
            p_bindvars(g_bind_counter2) := l_bindvar_type;
            g_bind_counter2 := g_bind_counter2 + 1;
        ELSIF (p_bind_counter_type = g_type3) THEN
            p_bindvars(g_bind_counter_common) := l_bindvar_type;
            g_bind_counter_common := g_bind_counter_common + 1;
        ELSE
            p_bindvars(g_bind_counter_orderby) := l_bindvar_type;
            g_bind_counter_orderby := g_bind_counter_orderby + 1;
        END IF;

        g_bind_counter_global := g_bind_counter_global + 1;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Process_Bind_Var;

  -- -----------------------------------------------------------
  -- forward declaration for procedure Create_Regions_Clause
  -- -----------------------------------------------------------
  PROCEDURE Create_Regions_Clause(p_parent_origins      IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_parent_destinations IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_origin_zip_request  IN      VARCHAR2,
                                  p_dest_zip_request    IN      VARCHAR2,
                                  x_query               OUT NOCOPY      VARCHAR2,
                                  x_bindvars            IN OUT NOCOPY   FTE_LANE_SEARCH_QUERY_GEN.bindvars);

  -- ----------------------------------------------------------------
  -- Name:              Create_Lane_Query
  -- Type:              Procedure
  --
  -- Description:       This procedure takes in search criteria and
  --                    origin, destination ids, and creates the
  --                    dynamic sql statement for searching lanes.
  --                    Returns the relax up and relax down queries,
  --                    and also returns the bind variable arrays.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Create_Lane_Query(p_search_criteria         IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_criteria_rec,
                              p_origins                 IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                              p_destinations            IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                              p_parent_origins          IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab, -- includes origins
                              p_parent_destinations     IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab, -- includes dests
                              p_source_type             IN      VARCHAR2,
                              x_query1                  OUT NOCOPY      VARCHAR2,
                              x_query2                  OUT NOCOPY      VARCHAR2,
                              x_bindvars1               OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                              x_bindvars2               OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                              x_bindvars_common         OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                              x_bindvars_orderby        OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                              x_return_message          OUT NOCOPY      VARCHAR2,
                              x_return_status           OUT NOCOPY      VARCHAR2) IS

  -- declare local variables
  l_relax_flag          VARCHAR2(1);
  l_origins             FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_destinations        FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_origins      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_parent_destinations FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab;
  l_origin_zip_request  VARCHAR2(30);
  l_dest_zip_request    VARCHAR2(30);
  l_mode                VARCHAR2(30);
  l_lane_number         VARCHAR2(30);
  l_carrier_id          NUMBER;
  l_carrier_name        VARCHAR2(360);
  l_commodity_catg_id   NUMBER;
  l_commodity           VARCHAR2(240);
  l_service_code        VARCHAR2(30);
  l_service             VARCHAR2(80);
  --l_equipment_code      VARCHAR2(30);
 -- l_equipment           VARCHAR2(80);
  l_schedule_only_flag  VARCHAR2(1);
  l_lane_ids_list       VARCHAR2(2000);
  l_lane_eff_date       VARCHAR2(30);
  l_date_clause         VARCHAR2(1300);
  l_tariff_name         VARCHAR2(80);
  l_lane_number_search  VARCHAR2(1) := 'N';
  l_lane_id_search      VARCHAR2(1) := 'N';
  l_counter             NUMBER;

  -- local variables to hold query
  l_query_select                VARCHAR2(2000);
  l_query_from                  VARCHAR2(1000);
  l_query_from_regions          VARCHAR2(2000);
  l_query_from_lane_num         VARCHAR2(2000);
  l_query_common_join           VARCHAR2(2000);
  l_query_common_criteria       VARCHAR2(4000);
  l_query_schedule              VARCHAR2(8000);
  l_query_relax_up              VARCHAR2(2000);
  l_query_relax_down            VARCHAR2(2000);
  l_query_order_by              VARCHAR2(2000);
  l_query1                      VARCHAR2(32000);
  l_query2                      VARCHAR2(32000);



  l_bindvars1                   FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars2                   FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars_common             FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars_orderby            FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvars_schedule           FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_bindvar_type                FTE_LANE_SEARCH_QUERY_GEN.bindvar_type;

  l_message                     VARCHAR2(200);
  l_status                      VARCHAR2(1);
  x_status                      NUMBER;

  -- cursor definitions
  CURSOR c_get_carrier_id(p_carrier_name VARCHAR2) IS
  select party_id
  from hz_parties, wsh_carriers
  where party_name = p_carrier_name and party_id = carrier_id;

  CURSOR c_get_lookup_code(p_lookup_type VARCHAR2, p_meaning VARCHAR2) IS
  select lookup_code from fnd_lookup_values_vl
  where lookup_type = p_lookup_type
        and upper(meaning) like upper(p_meaning)||'%';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_LANE_QUERY';
--

-- [11/11] Add query type for Lane Group and Commitment -> 'T'
l_query_group_by              VARCHAR2(2000);


  BEGIN

        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
        END IF;
        --
        g_bind_counter1 := 1;
        g_bind_counter2 := 1;
        g_bind_counter_common := 1;
        g_bind_counter_orderby := 1;

        g_bind_counter_global := 1;

        -- obtain serach criteria variables
        l_relax_flag            := p_search_criteria.relax_flag;
        l_origins               := p_origins;
        l_destinations          := p_destinations;
        l_parent_origins        := p_parent_origins; -- includes origins
        l_parent_destinations   := p_parent_destinations; -- includes dests
        l_origin_zip_request    := p_search_criteria.origin_zip_request;
        l_dest_zip_request      := p_search_criteria.dest_zip_request;
        l_mode                  := p_search_criteria.mode_of_transport;
        l_lane_number           := p_search_criteria.lane_number;
        l_carrier_id            := p_search_criteria.carrier_id;
        l_carrier_name          := p_search_criteria.carrier_name;
        l_commodity_catg_id     := p_search_criteria.commodity_catg_id;
        l_commodity             := p_search_criteria.commodity;
        l_service_code          := p_search_criteria.service_code;
        l_service               := p_search_criteria.service;
       -- l_equipment_code        := p_search_criteria.equipment_code;
       -- l_equipment             := p_search_criteria.equipment;
        l_schedule_only_flag    := p_search_criteria.schedule_only_flag;
        l_lane_ids_list         := p_search_criteria.lane_ids_list;
        l_tariff_name           := p_search_criteria.tariff_name;
        WSH_DEBUG_SV.log(l_module_name,'p_search_criteria.tariff_name',p_search_criteria.tariff_name);
        WSH_DEBUG_SV.log(l_module_name,'l_tariff_name',l_tariff_name);

        -- [11/11] Add query type for Lane Group and Commitment -> 'T'
        IF (p_source_type ='T') THEN

          l_query_select := 'select  wc.carrier_name, l.carrier_id, l.origin_id, l.destination_id, lv2.meaning, l.mode_of_transportation_code, r.region_type, min(l.lane_id) lane_id ';

          l_query_from_regions :=' from fte_lanes l, wsh_carriers_v wc, wsh_zone_regions zr,' ||
                                 ' wsh_zone_regions pd, fnd_lookup_values_vl lv2, wsh_regions r';

          l_query_common_join := ' where l.carrier_id  = wc.carrier_id and' ||
                                 ' wc.active           = ''A'' AND' ||
                                 ' lv2.lookup_type     = ''WSH_MODE_OF_TRANSPORT'' AND' ||
                                 ' lv2.lookup_code     = l.mode_of_transportation_code AND' ||
				 ' l.origin_id	       = r.region_id AND' ||
                                 ' nvl(l.editable_flag, ''Y'')    <> ''D'' AND' ||  -- only for non-edit
                                 ' nvl(l.effective_date, sysdate) <= sysdate AND' || -- only for non-edit
                                 ' nvl(l.expiry_date, sysdate)    >= sysdate '; -- only for non-edit
       ELSE

        -- select statement
        l_query_select  := 'select l.lane_id, l.lane_number, wc.carrier_name, ' ||
                           'l.origin_id, l.destination_id, lv2.meaning, ' ||
                           'lv3.meaning ,' ||
                           'decode(l.commodity_detail_flag, ''Y'', ' ||
                           'decode(l.commodity_catg_id, null, ''multiple'', m.description), null), ' ||
                           'lv1.meaning, l.distance, l.port_of_loading, ' ||
                           'l.port_of_discharge, l.transit_time, lh.name, ' ||
                           'l.basis, l.owner_id, l.carrier_id, l.mode_of_transportation_code, ' ||
                           'l.transit_time_uom, l.special_handling, l.additional_instructions, ' ||
                           'l.commodity_detail_flag,' ||
			   'l.service_detail_flag, ' ||
                           'l.commodity_catg_id,'||
			   ' ls.service_code, ' ||
                           'l.distance_uom, l.pricelist_id, l.pricelist_view_flag, l.effective_date, ' ||
                           'l.expiry_date, ro.region_type, rd.region_type, l.comm_fc_class_code, ' ||
                           'l.schedules_flag, ls.lane_service_id, l.tariff_name, l.lane_type';

        -- from clauses
        l_query_from_regions := ' from fte_lanes l, wsh_carriers_v wc, wsh_zone_regions zr,' ||
                                ' wsh_zone_regions pd, fnd_lookup_values_vl lv1,' ||
                                ' qp_list_headers_tl lh, fnd_lookup_values_vl lv2,' ||
                                ' fnd_lookup_values_vl lv3, mtl_categories m,' ||
                                ' wsh_regions ro, wsh_regions rd,' ||
                                ' fte_lane_services ls ';

        l_query_from_lane_num := ' from fte_lanes l, wsh_carriers_v wc, fnd_lookup_values_vl lv1,' ||
                                 ' qp_list_headers_tl lh, fnd_lookup_values_vl lv2,' ||
                                 ' fnd_lookup_values_vl lv3, mtl_categories m,' ||
                                 ' wsh_regions ro, wsh_regions rd, ' ||
                                 ' fte_lane_services ls ';

        -- common join clauses
        l_query_common_join := ' where l.carrier_id    = wc.carrier_id and' ||
                               ' wc.active = ''A'' AND' ||
                               ' l.schedules_flag = lv1.lookup_code AND' ||
                               ' lv1.lookup_type = ''FTE_YES_NO'' AND' ||
                               ' lv1.view_application_id = 716 AND' ||
                               ' lh.list_header_id (+) = l.pricelist_id AND' ||
                               ' lh.language(+) = userenv(''LANG'') AND' ||
                               ' lv2.lookup_type = ''WSH_MODE_OF_TRANSPORT'' AND' ||
                               ' lv2.lookup_code = l.mode_of_transportation_code AND' ||
                               ' lv3.lookup_type = ''WSH_SERVICE_LEVELS'' AND' ||
                               ' lv3.lookup_code = ls.service_code AND' ||
                               ' lv3.enabled_flag = ''Y'' AND' ||
                               ' nvl(lv3.start_date_active, sysdate) <= sysdate AND' ||
                               ' nvl(lv3.end_date_active, sysdate) >= sysdate AND' ||
                               ' l.lane_id = ls.lane_id(+) AND' ||
                               ' m.category_id(+) = l.commodity_catg_id AND' ||
                               ' l.origin_id = ro.region_id AND' ||
                               ' l.destination_id = rd.region_id AND' ||
                               ' nvl(l.editable_flag, ''Y'') <> ''D'' ';

        -- [02/18] Bug # 3401165
        -- Effective Date field has been added to Lane Search UI
        --
        --We return only currently effective dates unless we are doing
        --freight rating, in which case we want to return the lanes
        --that are effective on the departure date.
        IF (p_search_criteria.effective_date IS NOT NULL) THEN
           l_lane_eff_date := to_char(p_search_criteria.effective_date, 'mm-dd-yyyy hh24:mi');

           -- Effective date for Lane
           IF (p_search_criteria.effective_date_type IS NULL OR
               p_search_criteria.effective_date_type = '='  OR
               p_search_criteria.effective_date_type = '<')  THEN

             l_date_clause := ' AND nvl(l.effective_date, :' || g_bind_counter_global || ') <= :';
             Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);
             l_date_clause := l_date_clause || g_bind_counter_global;
             Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);

           END IF;


           -- Expiry date for Lane
           IF (p_search_criteria.effective_date_type IS NULL OR
               p_search_criteria.effective_date_type = '='  OR
               p_search_criteria.effective_date_type = '>')  THEN

             l_date_clause := l_date_clause || ' AND nvl(l.expiry_date, :' || g_bind_counter_global ||  ') >= :';
             Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);

             l_date_clause := l_date_clause || g_bind_counter_global;
             Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);

           END IF;

        ELSE
           l_date_clause := ' AND nvl(l.expiry_date, sysdate) >= sysdate ';
		--' AND nvl(l.effective_date, sysdate) <= sysdate ' ||
        END IF;
/*
        --We return only currently effective dates unless we are doing
        --freight rating, in which case we want to return the lanes
        --that are effective on the departure date.
        IF (p_search_criteria.dep_date_from IS NOT NULL) THEN
           l_lane_eff_date := to_char(p_search_criteria.dep_date_from, 'mm-dd-yyyy hh24:mi');
           l_date_clause := ' AND nvl(l.effective_date, :' || g_bind_counter_global || ') <= :';

           Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);
           l_date_clause := l_date_clause || g_bind_counter_global;
           Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);

           l_date_clause := l_date_clause || ' AND nvl(l.expiry_date, :' || g_bind_counter_global ||  ') >= :';
           Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);
           l_date_clause := l_date_clause || g_bind_counter_global;
           Process_Bind_Var(l_bindvars_common, l_lane_eff_date, g_date, g_type3);
        ELSE
           l_date_clause := ' AND nvl(l.effective_date, sysdate) <= sysdate ' ||
                            ' AND nvl(l.expiry_date, sysdate) >= sysdate ';
        END IF;
*/
        l_query_common_join := l_query_common_join || l_date_clause;

      END IF;

        -- build query logic for plain lane id search (used with lane groups view lane details)
        IF (l_lane_ids_list is not null) THEN
            l_lane_id_search := 'Y';
            l_query_from := l_query_from_lane_num;
        END IF;

        -- build query logic for plain lane number search
        IF (l_lane_id_search = 'N' AND l_lane_number is not null AND
	    l_origins.count > 0 and l_destinations.count > 0 and
            l_origins(1).region_type is null AND l_origins(1).region_id is null AND
            l_destinations(1).region_type is null AND l_destinations(1).region_id is null) THEN
            l_lane_number_search := 'Y';
            l_query_from := l_query_from_lane_num;
        ELSIF (l_lane_id_search = 'N') THEN
            l_query_from := l_query_from_regions;
        END IF;

        -- figure out the regions query part or no regions
        IF (l_lane_number_search = 'N' AND l_lane_id_search = 'N') THEN

            -- add common join stuff for queries with regions
            l_query_common_join := l_query_common_join || ' AND l.owner_id = zr.party_id' ||
                                   ' AND l.owner_id    = pd.party_id' ||
                                   ' AND l.origin_id   = zr.parent_region_id' ||
                                   ' AND l.destination_id = pd.parent_region_id';

            -- first query
            Create_Regions_Clause(p_parent_origins              => l_parent_origins,
                                  p_parent_destinations         => l_parent_destinations,
                                  p_origin_zip_request          => l_origin_zip_request,
                                  p_dest_zip_request            => l_dest_zip_request,
                                  x_query                       => l_query_relax_up,
                                  x_bindvars                    => l_bindvars1);

            --Relax down only if the origin and the destination were found.
            IF (l_relax_flag = 'Y' AND l_origins.COUNT > 0 AND l_destinations.COUNT > 0) THEN

	      -- second query
              l_query_relax_down := ' AND zr.region_id in (select f1.region_id from wsh_regions f1 where f1.parent_region_id = :' || g_bind_counter_global;
              Process_Bind_Var(l_bindvars2, to_char(l_origins(1).region_id), g_number, g_type2);

              -- duplicating predicate for performance
              l_query_relax_down := l_query_relax_down || ' AND f1.parent_region_id = :' || g_bind_counter_global;
              Process_Bind_Var(l_bindvars2, to_char(l_origins(1).region_id), g_number, g_type2);

              l_query_relax_down := l_query_relax_down || ' UNION select :' || g_bind_counter_global ||
            			    ' from dual) ';
              Process_Bind_Var(l_bindvars2, to_char(l_origins(1).region_id), g_number, g_type2);


              l_query_relax_down := l_query_relax_down || ' AND pd.region_id in (select f1.region_id from wsh_regions f1 where f1.parent_region_id = :' || g_bind_counter_global;
              Process_Bind_Var(l_bindvars2, to_char(l_destinations(1).region_id), g_number, g_type2);

              -- duplicating predicate for performance
              l_query_relax_down := l_query_relax_down || ' AND f1.parent_region_id = :' || g_bind_counter_global;
              Process_Bind_Var(l_bindvars2, to_char(l_destinations(1).region_id), g_number, g_type2);

              l_query_relax_down := l_query_relax_down || ' UNION select :' || g_bind_counter_global ||
            			    ' from dual) ';
              Process_Bind_Var(l_bindvars2, to_char(l_destinations(1).region_id), g_number, g_type2);

              -- add postal code filter
              IF (l_origin_zip_request is not null) THEN
            	  l_query_relax_down := l_query_relax_down || ' AND :' || g_bind_counter_global;
            	  Process_Bind_Var(l_bindvars2, l_origin_zip_request, g_varchar2, g_type2);
            	  l_query_relax_down := l_query_relax_down || ' between rpad(nvl(zr.postal_code_from, ''0''), :' || g_bind_counter_global || ', '' '')';
            	  Process_Bind_Var(l_bindvars2, length(l_origin_zip_request), g_number, g_type2);
            	  l_query_relax_down := l_query_relax_down || ' AND rpad(nvl(zr.postal_code_to, ''zzzzzzz''), :' || g_bind_counter_global || ', ''z'')';
            	  Process_Bind_Var(l_bindvars2, length(l_origin_zip_request), g_number, g_type2);
              END IF;

              IF (l_dest_zip_request is not null) THEN
            	  l_query_relax_down := l_query_relax_down || ' AND :' || g_bind_counter_global;
            	  Process_Bind_Var(l_bindvars2, l_dest_zip_request, g_varchar2, g_type2);
            	  l_query_relax_down := l_query_relax_down || ' between rpad(nvl(pd.postal_code_from, ''0''), :' || g_bind_counter_global || ', '' '')';
            	  Process_Bind_Var(l_bindvars2, length(l_dest_zip_request), g_number, g_type2);
            	  l_query_relax_down := l_query_relax_down || ' AND rpad(nvl(pd.postal_code_to, ''zzzzzzz''), :' || g_bind_counter_global || ', ''z'')';
            	  Process_Bind_Var(l_bindvars2, length(l_dest_zip_request), g_number, g_type2);
              END IF;
            END IF;
        END IF;

        -- other search parameters
        l_query_common_criteria := '';

        -- append other query clauses if not lane id search
        IF (l_lane_id_search = 'N') THEN

            IF (l_mode is not null) THEN
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND l.mode_of_transportation_code = :' || g_bind_counter_global;
                Process_Bind_Var(l_bindvars_common, l_mode, g_varchar2, g_type3);
            END IF;

            IF (l_carrier_name is not null AND l_carrier_id is null) THEN
                OPEN c_get_carrier_id(l_carrier_name);
                FETCH c_get_carrier_id INTO l_carrier_id;
                CLOSE c_get_carrier_id;
            END IF;
            IF (l_tariff_name is not null) THEN
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND l.tariff_name like :' || g_bind_counter_global;
                Process_Bind_Var(l_bindvars_common, l_tariff_name, g_varchar2, g_type3);
            END IF;
            IF (l_carrier_id is not null) THEN
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND l.carrier_id = :' || g_bind_counter_global;
                Process_Bind_Var(l_bindvars_common, to_char(l_carrier_id), g_number, g_type3);
            END IF;

            IF (l_service is not null) THEN
                OPEN c_get_lookup_code('WSH_SERVICE_LEVELS', l_service);
                FETCH c_get_lookup_code INTO l_service_code;
                CLOSE c_get_lookup_code;
            END IF;

            IF (l_service_code is not null) THEN
                --l_query_from := l_query_from || ', fte_lane_services ls';
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND ls.lane_id = l.lane_id' ||
                                           ' AND ls.service_code = :' || g_bind_counter_global;
                Process_Bind_Var(l_bindvars_common, l_service_code, g_varchar2, g_type3);
            END IF;

            /*IF (l_equipment is not null) THEN
                OPEN c_get_lookup_code('CONTAINER_TYPE', l_equipment);
                FETCH c_get_lookup_code INTO l_equipment_code;
                CLOSE c_get_lookup_code;
            END IF;

            IF (l_equipment_code is not null) THEN
                l_query_from := l_query_from || ', fte_lane_equipments le';
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND le.lane_id = l.lane_id' ||
                                           ' AND le.equipment_code = :' || g_bind_counter_global;
                Process_Bind_Var(l_bindvars_common, l_equipment_code, g_varchar2, g_type3);
            END IF;*/

            IF (l_commodity is not null) THEN
                FTE_UTIL_PKG.Get_Category_Id(p_commodity_value => l_commodity,
                                                       x_catg_id         => l_commodity_catg_id,
                                                       x_status          => x_status,
                                                       x_error_msg       => x_return_message);


            END IF;

            IF (l_commodity_catg_id is not null AND x_status = -1) THEN
                l_query_from := l_query_from || ', fte_lane_commodities lc';
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND lc.lane_id = l.lane_id' ||
                                           ' AND lc.commodity_catg_id = :' || g_bind_counter_global;
                Process_Bind_Var(l_bindvars_common, to_char(l_commodity_catg_id), g_number, g_type3);
            END IF;

            IF (l_lane_number is not null) THEN
                l_query_common_criteria := l_query_common_criteria || ' AND l.lane_number ';
		IF (instr(l_lane_number, '%') > 0) THEN
		  l_query_common_criteria := l_query_common_criteria || 'like :';
		ELSE
		  l_query_common_criteria := l_query_common_criteria || '= :';
		END IF;
		l_query_common_criteria := l_query_common_criteria || g_bind_counter_global;

                Process_Bind_Var(l_bindvars_common, l_lane_number, g_varchar2, g_type3);
            END IF;

            IF (l_schedule_only_flag is not null AND l_schedule_only_flag = 'Y') THEN
                l_query_common_criteria := l_query_common_criteria ||
                                           ' AND nvl(l.schedules_flag, ''N'') = ''Y''';
            END IF;

            -- create schedule filter part of the query
            -- by concatenating to l_query_common_criteria and l_bindvars_common
            IF (p_search_criteria.dep_date_from is not null OR
                p_search_criteria.dep_date_to is not null OR
                p_search_criteria.arr_date_from is not null OR
                p_search_criteria.arr_date_to is not null) THEN

                l_query_from := l_query_from || ', fte_schedules s';
                l_query_common_criteria := l_query_common_criteria || ' AND l.lane_id = s.lane_id(+)' ||
                                           ' AND (( nvl(s.expiry_date, sysdate) >= sysdate' ||
                                           ' AND nvl(s.effective_date, sysdate) <= sysdate';

                Create_Schedule_Clause(p_dep_date_from  => p_search_criteria.dep_date_from,
                                       p_dep_date_to    => p_search_criteria.dep_date_to,
                                       p_arr_date_from  => p_search_criteria.arr_date_from,
                                       p_arr_date_to    => p_search_criteria.arr_date_to,
                                       x_query          => l_query_schedule,
                                       x_bindvars       => l_bindvars_common,  -- nocopy to procedure
                                       x_return_message => l_message,
                                       x_return_status  => l_status);

                l_query_common_criteria := l_query_common_criteria || l_query_schedule ||
                                           ' OR NVL(l.SCHEDULES_FLAG, ''N'') = ''N'' )';

            END IF;

            -- create order by clause for first query
            -- [11/11] Add query type for Lane Group and Commitment -> 'T'

            IF (l_lane_number_search = 'N' and p_source_type<>'T') THEN

                -- origins
                IF (l_parent_origins is not null) THEN
                    l_query_order_by := ' order by decode(l.origin_id, ';

                    l_counter := l_parent_origins.FIRST;
                    LOOP
                       IF (l_parent_origins(l_counter).region_id is not null) THEN
                          IF (l_counter = l_parent_origins.FIRST) THEN
                              l_query_order_by := l_query_order_by || ':' || g_bind_counter_global;
                          ELSE
                              l_query_order_by := l_query_order_by || ', :' || g_bind_counter_global;
                          END IF;

                          Process_Bind_Var(l_bindvars_orderby, to_char(l_parent_origins(l_counter).region_id), g_number, g_type4);

                          l_query_order_by := l_query_order_by || ', :' || g_bind_counter_global;
                          Process_Bind_Var(l_bindvars_orderby, to_char(l_parent_origins(l_counter).region_type), g_number, g_type4);

		       END IF;

		       EXIT WHEN l_counter = l_parent_origins.LAST;
		       l_counter := l_parent_origins.NEXT(l_counter);

                    END LOOP;

                    l_query_order_by := l_query_order_by || ') desc';

                END IF;

                -- destinations
                IF (l_parent_destinations is not null) THEN
                   l_query_order_by := l_query_order_by || ', decode(l.destination_id, ';

		   l_counter := l_parent_destinations.FIRST;
		   LOOP
                     IF (l_parent_destinations(l_counter).region_id is not null) THEN
                        IF (l_counter = l_parent_destinations.FIRST) THEN
                            l_query_order_by := l_query_order_by || ':' || g_bind_counter_global;
                        ELSE
                            l_query_order_by := l_query_order_by || ', :' || g_bind_counter_global;
                        END IF;

                        Process_Bind_Var(l_bindvars_orderby, to_char(l_parent_destinations(l_counter).region_id), g_number, g_type4);

                        l_query_order_by := l_query_order_by || ', :' || g_bind_counter_global;
                        Process_Bind_Var(l_bindvars_orderby, to_char(l_parent_destinations(l_counter).region_type), g_number, g_type4);

		      END IF;

		      EXIT WHEN l_counter = l_parent_destinations.LAST;
		      l_counter := l_parent_destinations.NEXT(l_counter);

                    END LOOP;

                    l_query_order_by := l_query_order_by || ') desc';

                END IF;

            END IF;


        ELSE -- lane id search

            l_query_common_criteria := ' AND l.lane_id = :' || g_bind_counter_global;
            Process_Bind_Var(l_bindvars_common, l_lane_ids_list, g_number, g_type3);

        END IF; -- end if l_lane_id_search = 'N'


        l_query_group_by :='';

        -- [11/11] Add query type for Lane Group and Commitment -> 'T'
        -- create a group by when p_source_type = 'T'
        IF (p_source_type ='T') THEN
          l_query_group_by := ' group by wc.carrier_name, l.carrier_id, l.origin_id, l.destination_id, lv2.meaning, l.mode_of_transportation_code, r.region_type ';
        END IF;

        IF l_debug_on THEN
            WSH_DEBUG_SV.log(l_module_name,l_query_group_by);
        END IF;

        -- return the query string and bind variables
        IF (l_lane_id_search = 'Y') THEN
            l_query1 := l_query_select || l_query_from ||
                        l_query_common_join ||
                        l_query_common_criteria;
        ELSIF (l_lane_number_search = 'Y') THEN
            l_query1 := l_query_select || l_query_from ||
                        l_query_common_join || l_query_relax_up ||
                        l_query_common_criteria;
        ELSE
            -- [11/11] Add query type for Lane Group and Commitment -> 'T'
            IF (p_source_type = 'T') THEN

              l_query1 := l_query_select || l_query_from ||
                          l_query_common_join || l_query_relax_up ||
                          l_query_common_criteria || l_query_group_by;
            ELSE

              l_query1 := l_query_select || l_query_from ||
                          l_query_common_join || l_query_relax_up ||
                          l_query_common_criteria ||l_query_order_by;

            END if;

            l_query2 := l_query_select || l_query_from ||
                        l_query_common_join || l_query_relax_down ||
                        l_query_common_criteria||l_query_group_by;
        END IF;

	IF l_debug_on THEN
           WSH_DEBUG_SV.log(l_module_name,l_query1);
        END IF;

	x_query1 := l_query1;
        x_query2 := l_query2;
        x_bindvars1 := l_bindvars1;
        x_bindvars2 := l_bindvars2;
        x_bindvars_common := l_bindvars_common;
        x_bindvars_orderby := l_bindvars_orderby;

        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
  END Create_Lane_Query;


  -- ----------------------------------------------------------------
  -- Name:              Create_Regions_Clause
  -- Type:              Procedure
  --
  -- Description:       This procedure takes in origin, destination
  --                    information, as well as postal codes entered
  --                    by the user, and creates the regions portion
  --                    of the relax up query.
  --                    Returns bind variable array.
  --
  -- This is also used by Rate Chart Search, which is why it is
  -- separated out from Create_Lane_Query.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Create_Regions_Clause(p_parent_origins      IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_parent_destinations IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_origin_zip_request  IN      VARCHAR2,
                                  p_dest_zip_request    IN      VARCHAR2,
                                  x_query               OUT NOCOPY      VARCHAR2,
                                  x_bindvars            IN OUT NOCOPY   FTE_LANE_SEARCH_QUERY_GEN.bindvars) IS

  l_query               VARCHAR2(4000);
  l_counter		NUMBER;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_REGIONS_CLAUSE';
--
  BEGIN

        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
        END IF;
        --

        -- origins and origin parents
        IF (p_parent_origins is not null AND p_parent_origins.COUNT > 0) THEN
            l_query := ' AND zr.region_id in (';

	    l_counter := p_parent_origins.FIRST;
	    LOOP
              IF (p_parent_origins(l_counter).region_id is not null) THEN
                IF (l_counter = 1) THEN
                    l_query := l_query || ':' || g_bind_counter_global;
                ELSE
                    l_query := l_query || ', :' || g_bind_counter_global;
                END IF;
                Process_Bind_Var(x_bindvars, to_char(p_parent_origins(l_counter).region_id), g_number, g_type1);

	      END IF;

	      EXIT WHEN l_counter = p_parent_origins.LAST;
	      l_counter := p_parent_origins.NEXT(l_counter);

            END LOOP;
            l_query := l_query || ')';
        END IF;

        -- destinations and destination parents
        IF (p_parent_destinations is not null AND p_parent_destinations.COUNT > 0 ) THEN
            l_query := l_query || ' AND pd.region_id in (';

	    l_counter := p_parent_destinations.FIRST;
	    LOOP
              IF (p_parent_destinations(l_counter).region_id is NOT null) THEN
                IF (l_counter = p_parent_destinations.FIRST) THEN
                    l_query := l_query || ':' || g_bind_counter_global;
                ELSE
                    l_query := l_query || ', :' || g_bind_counter_global;
                END IF;
                Process_Bind_Var(x_bindvars, to_char(p_parent_destinations(l_counter).region_id), g_number, g_type1);

	      END IF;

	      EXIT WHEN l_counter = p_parent_destinations.LAST;
	      l_counter := p_parent_destinations.NEXT(l_counter);

            END LOOP;
            l_query := l_query || ')';
        END IF;

        -- add postal code filter
        IF (p_origin_zip_request is not null) THEN
            l_query := l_query || ' AND :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, p_origin_zip_request, g_varchar2, g_type1);
            l_query := l_query || ' between rpad(nvl(zr.postal_code_from, ''0''), :' || g_bind_counter_global || ', '' '')';
            Process_Bind_Var(x_bindvars, length(p_origin_zip_request), g_number, g_type1);
            l_query := l_query || ' AND rpad(nvl(zr.postal_code_to, ''zzzzzzz''), :' || g_bind_counter_global || ', ''z'')';
            Process_Bind_Var(x_bindvars, length(p_origin_zip_request), g_number, g_type1);
        ELSIF (p_dest_zip_request IS NULL) THEN
            l_query := l_query || ' AND zr.postal_code_from IS NULL AND zr.postal_code_to IS NULL ';
        END IF;

        IF (p_dest_zip_request is not null) THEN
            l_query := l_query || ' AND :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, p_dest_zip_request, g_varchar2, g_type1);
            l_query := l_query || ' between rpad(nvl(pd.postal_code_from, ''0''), :' || g_bind_counter_global || ', '' '')';
            Process_Bind_Var(x_bindvars, length(p_dest_zip_request), g_number, g_type1);
            l_query := l_query || ' AND rpad(nvl(pd.postal_code_to, ''zzzzzzz''), :' || g_bind_counter_global || ', ''z'')';
            Process_Bind_Var(x_bindvars, length(p_dest_zip_request), g_number, g_type1);
        ELSIF (p_origin_zip_request IS NULL) THEN
            l_query := l_query || ' AND pd.postal_code_from IS NULL AND pd.postal_code_to IS NULL';
        END IF;
        x_query := l_query;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Create_Regions_Clause;

  -- ----------------------------------------------------------------
  -- Name:              Create_Schedule_Query
  -- Type:              Procedure
  --
  -- Description:       This procedure takes in search criteria and
  --                    origin, destination ids, and creates the
  --                    dynamic sql statement for searching schedules.
  --                    This procedure relies on the lane_id's of the
  --                    lanes whose schedules are sought for to be
  --                    passed in via p_search_criteria.lane_ids_list.
  --                    Returns bind variable array and query string.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Create_Schedule_Query(p_search_criteria     IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_criteria_rec,
                                  p_origins             IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_destinations        IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_parent_origins      IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  p_parent_destinations IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                  x_query               OUT NOCOPY      VARCHAR2,
                                  x_bindvars            OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                                  x_return_message      OUT NOCOPY      VARCHAR2,
                                  x_return_status       OUT NOCOPY      VARCHAR2) IS

  l_query       VARCHAR2(8000);
  l_query_dates VARCHAR2(8000);

  l_bindvars            FTE_LANE_SEARCH_QUERY_GEN.bindvars;
  l_message     VARCHAR2(200);
  l_status      VARCHAR2(1);

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_SCHEDULE_QUERY';
--
  BEGIN

        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
        END IF;
        --
        g_bind_counter_common := 1;
        g_bind_counter_global := 1;

        l_query := 'SELECT S.SCHEDULES_ID, ' ||
                           'S.LANE_ID, ' ||
                           'L.LANE_NUMBER, ' ||
                           'S.DEPARTURE_DATE, ' ||
                           'S.ARRIVAL_DATE, ' ||
                           'S.TRANSIT_TIME, ' ||
                           'S.FREQUENCY, ' ||
                           'S.EFFECTIVE_DATE, ' ||
                           'S.PORT_OF_LOADING, ' ||
                           'S.PORT_OF_DISCHARGE, ' ||
                           'S.EXPIRY_DATE, ' ||
                           'S.ARRIVAL_DATE_INDICATOR, ' ||
                           'S.FREQUENCY_ARRIVAL, ' ||
                           'L.ORIGIN_ID, ' ||
                           'L.DESTINATION_ID, ' ||
                           'LV2.MEANING AS MODE_OF_TRANSPORTATION, ' ||
                           'L.CARRIER_ID, ' ||
                           'H.PARTY_NAME AS CARRIER_NAME, ' ||
                           'S.DEPARTURE_TIME, ' ||
                           'S.ARRIVAL_TIME, ' ||
                           'LV1.MEANING AS FREQUENCY_TYPE_MEANING, ' ||
                           'S.TRANSIT_TIME_UOM, ' ||
                           'S.VESSEL_TYPE, ' ||
                           'S.VESSEL_NAME, ' ||
                           'S.VOYAGE_NUMBER, ' ||
                           'S.ARRIVAL_TIME || decode(S.ARRIVAL_DATE_INDICATOR, null, '''', '' ('' || decode(substr(S.ARRIVAL_DATE_INDICATOR, 1, 1), ''-'',' ||
                           ' TO_CHAR(S.ARRIVAL_DATE_INDICATOR), ''+'' || S.ARRIVAL_DATE_INDICATOR)  || '')'') AS ARRIVAL_TIME_WITH_INDICATOR, ' ||
                           'L.MODE_OF_TRANSPORTATION_CODE, ' ||
                           'L.SERVICE_TYPE_CODE, ' ||
                           'DECODE(L.SERVICE_DETAIL_FLAG, ''Y'', DECODE(L.SERVICE_TYPE_CODE, null, ''multiple'', LV3.MEANING), null) AS SERVICE_TYPE_MEANING, ' ||
                           'S.FREQUENCY_TYPE AS FREQUENCY_TYPE, ' ||
                           --'S.FREQUENCY AS ORIG_FREQUENCY, ' ||
                           'NVL((SELECT ''Y'' FROM FTE_SCHEDULES S1 WHERE S1.SCHEDULES_ID = S.SCHEDULES_ID AND SYSDATE BETWEEN NVL(S.EFFECTIVE_DATE, SYSDATE) AND NVL(S.EXPIRY_DATE, SYSDATE)), ''N'') AS ACTIVE_FLAG ' ||
                    'FROM FTE_SCHEDULES S, FTE_LANES L, FND_LOOKUP_VALUES_VL LV1, ' ||
                          'FND_LOOKUP_VALUES_VL LV2, HZ_PARTIES H, FND_LOOKUP_VALUES_VL LV3 ' ||
                    'WHERE S.LANE_ID = L.LANE_ID ' ||
                           'AND NVL(S.EDITABLE_FLAG, ''Y'') = ''Y'' ' ||
                           'AND NVL(S.FREQUENCY_TYPE, ''NULL'') = LV1.LOOKUP_CODE ' ||
                           'AND LV1.LOOKUP_TYPE = ''FTE_FREQUENCY_TYPE'' ' ||
                           'AND LV2.LOOKUP_TYPE = ''WSH_MODE_OF_TRANSPORT'' ' ||
                           'AND LV2.LOOKUP_CODE = L.MODE_OF_TRANSPORTATION_CODE ' ||
                           'AND L.CARRIER_ID = H.PARTY_ID ' ||
                           'AND LV3.LOOKUP_TYPE(+) = ''WSH_SERVICE_LEVELS'' ' ||
                           'AND LV3.LOOKUP_CODE(+) = L.SERVICE_TYPE_CODE ' ||
                           'AND L.LANE_ID IN (' || p_search_criteria.lane_ids_list || ')';

            IF (p_search_criteria.dep_date_from is not null OR
                p_search_criteria.dep_date_to is not null OR
                p_search_criteria.arr_date_from is not null OR
                p_search_criteria.arr_date_to is not null) THEN

                Create_Schedule_Clause(p_dep_date_from          => p_search_criteria.dep_date_from,
                                       p_dep_date_to            => p_search_criteria.dep_date_to,
                                       p_arr_date_from          => p_search_criteria.arr_date_from,
                                       p_arr_date_to            => p_search_criteria.arr_date_to,
                                       x_query                  => l_query_dates,
                                       x_bindvars               => l_bindvars,
                                       x_return_message         => l_message,
                                       x_return_status          => l_status);

                l_query := l_query || 'AND ((NVL(S.EXPIRY_DATE, sysdate) >= sysdate ' ||
                           'AND NVL(S.EFFECTIVE_DATE, sysdate) <= sysdate ' || l_query_dates || ')';

            END IF;

            x_query := l_query;
            x_bindvars := l_bindvars;
            x_return_message := l_message;
            x_return_status := l_status;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Create_Schedule_Query;


  -- ----------------------------------------------------------------
  -- Name:              Create_Schedule_Clause
  -- Type:              Procedure
  --
  -- Description:       This procedure takes in 4 dates and creates
  --                    the dynamic sql statement for the schedules
  --                    filter.
  --                    Returns bind variables and query string.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Create_Schedule_Clause(p_dep_date_from      IN      DATE,
                                  p_dep_date_to         IN      DATE,
                                  p_arr_date_from       IN      DATE,
                                  p_arr_date_to         IN      DATE,
                                  x_query               OUT NOCOPY      VARCHAR2,
                                  x_bindvars            IN OUT  NOCOPY  FTE_LANE_SEARCH_QUERY_GEN.bindvars,
                                  x_return_message      OUT NOCOPY      VARCHAR2,
                                  x_return_status       OUT NOCOPY      VARCHAR2) IS

  l_query               VARCHAR2(8000);

  -- used by frequency-based schedules in case any are missing
  l_dep_date_from       DATE;
  l_dep_date_to         DATE;
  l_arr_date_from       DATE;
  l_arr_date_to         DATE;

  l_dep_date_from_time  VARCHAR2(10);
  l_dep_date_to_time    VARCHAR2(10);
  l_arr_date_from_time  VARCHAR2(10);
  l_arr_date_to_time    VARCHAR2(10);

  l_dep_from_day_of_week        NUMBER; -- Sunday = 1, Monday = 2, etc.
  l_dep_to_day_of_week          NUMBER;
  l_arr_from_day_of_week        NUMBER;
  l_arr_to_day_of_week          NUMBER;

  TYPE t_days_of_week_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_dep_date_array      t_days_of_week_array;
  l_arr_date_array      t_days_of_week_array;

  l_diff_dep            NUMBER;
  l_diff_arr            NUMBER;
  l_date_range_from     NUMBER;
  l_date_range_to       NUMBER;
  l_counter             NUMBER;
  l_counter2            NUMBER;
  l_mod_var             NUMBER;
  l_tag                 VARCHAR2(1) := 'N';
  l_condition_one       VARCHAR2(1) := 'N';

  l_date_format         VARCHAR2(20) := 'MM-dd-yyyy HH24:mi';

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_SCHEDULE_CLAUSE';
--
  BEGIN

        -- date-based schedules
        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
            --
            WSH_DEBUG_SV.log(l_module_name,'P_DEP_DATE_FROM',P_DEP_DATE_FROM);
            WSH_DEBUG_SV.log(l_module_name,'P_DEP_DATE_TO',P_DEP_DATE_TO);
            WSH_DEBUG_SV.log(l_module_name,'P_ARR_DATE_FROM',P_ARR_DATE_FROM);
            WSH_DEBUG_SV.log(l_module_name,'P_ARR_DATE_TO',P_ARR_DATE_TO);
        END IF;
        --
        l_query := ' AND (s.frequency_type is null AND ';

        -- departure date
        IF (p_dep_date_from is not null AND p_dep_date_to is not null) THEN

            l_query := l_query || ' trunc(s.departure_date, ''mi'') >= :' || g_bind_counter_global || ' AND';
            Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

            l_query := l_query || ' trunc(s.departure_date, ''mi'') <= :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_dep_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        END IF;

        IF (p_dep_date_from is not null AND p_dep_date_to is null) THEN

            l_query := l_query || ' trunc(s.departure_date, ''mi'') >= :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        END IF;

        IF (p_dep_date_from is null AND p_dep_date_to is not null) THEN

            l_query := l_query || ' trunc(s.departure_date, ''mi'') >= :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_dep_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        END IF;

        -- check if AND condition needed
        IF ( (p_dep_date_from is not null OR p_dep_date_to is not null) AND
             (p_arr_date_from is not null OR p_arr_date_to is not null) ) THEN

           l_query := l_query || ' AND ';

        END IF;

        -- arrival date
        IF (p_arr_date_from is not null AND p_arr_date_to is not null) THEN

            l_query := l_query || ' trunc(s.arrival_date, ''mi'') >= :' || g_bind_counter_global || ' AND';
            Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

            l_query := l_query || ' trunc(s.arrival_date, ''mi'') <= :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_arr_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        END IF;

        IF (p_arr_date_from is not null AND p_arr_date_to is null) THEN

            l_query := l_query || ' trunc(s.arrival_date, ''mi'') >= :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        END IF;

        IF (p_arr_date_from is null AND p_arr_date_to is not null) THEN

            l_query := l_query || ' trunc(s.arrival_date, ''mi'') >= :' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_arr_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        END IF;

        l_query := l_query || ')'; -- closes frequency_type is null
        -- end of date-based schedules
--      dbms_output.put_line('end of date based schedules');
        -- frequency-based schedules
        l_dep_date_from := p_dep_date_from;
        l_dep_date_to   := p_dep_date_to;
        l_arr_date_from := p_arr_date_from;
        l_arr_date_to   := p_arr_date_to;

        -- daily schedules
        l_query := l_query || ' OR ( ( s.frequency_type = ''DAILY'''; -- added another open ( 11/15/02 11:30am

        IF (p_dep_date_from is not null AND p_dep_date_to is null AND
            p_arr_date_from is not null AND p_arr_date_to is null) THEN

            l_query := l_query || ' AND to_number(nvl(s.arrival_date_indicator, 0)) >= ceil(:' || g_bind_counter_global;
            Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

            l_query := l_query || ' - :' || g_bind_counter_global || ')';
            Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

        ELSE
            IF (p_dep_date_from is not null AND p_dep_date_to is not null) THEN
                l_diff_dep := floor(p_dep_date_to - p_dep_date_from);
            END IF;
            IF (p_dep_date_from is not null AND p_dep_date_to is not null AND
                p_arr_date_from is not null AND p_arr_date_to is not null) THEN
                IF (l_diff_dep >= 0 AND l_diff_dep <= 7) THEN
                    l_query := l_query || ' AND (';
                    FOR l_counter IN 0..l_diff_dep LOOP
                        l_query := l_query || ' ( to_date(to_char(trunc(:' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || '), ''MM-dd-yyyy'') || '' '' || s.departure_time, :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, l_date_format, g_varchar2, g_type3);

                        l_query := l_query || ') + :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(l_counter), g_number, g_type3);

                        l_query := l_query || ' between :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || ' and :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || ' AND to_date(to_char(trunc(:' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || '), ''MM-dd-yyyy'') || '' '' || s.arrival_time, :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, l_date_format, g_varchar2, g_type3);

                        l_query := l_query || ') + nvl(s.arrival_date_indicator, 0) + :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(l_counter), g_number, g_type3);

                        l_query := l_query || ' between :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || ' and :' || g_bind_counter_global || ')';
                        Process_Bind_Var(x_bindvars, to_char(p_arr_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        IF (l_counter < l_diff_dep) THEN
                            l_query := l_query || ' OR ';
                        END IF;

                    END LOOP;

                    l_query := l_query || ' ) ';

                END IF;  -- end if l_diff_dep >= 0 AND l_diff_dep <= 7

            ELSIF (p_dep_date_from is not null AND p_dep_date_to is not null) THEN -- only departure dates

                IF (l_diff_dep >= 0 AND l_diff_dep <= 7) THEN
                    l_query := l_query || ' AND (';
                    FOR l_counter IN 0..l_diff_dep LOOP
                        l_query := l_query || ' ( to_date(to_char(trunc(:' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || '), ''MM-dd-yyyy'') || '' '' || s.departure_time, :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, l_date_format, g_varchar2, g_type3);

                        l_query := l_query || ') + :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(l_counter), g_number, g_type3);

                        l_query := l_query || ' between :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || ' and :' || g_bind_counter_global || ' )';
                        Process_Bind_Var(x_bindvars, to_char(p_dep_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        IF (l_counter < l_diff_dep) THEN
                            l_query := l_query || ' OR ';
                        END IF;

                    END LOOP;

                    l_query := l_query || ' ) ';

                END IF;  -- end if l_diff_dep >= 0 AND l_diff_dep <= 7


            ELSIF (p_arr_date_from is not null AND p_arr_date_to is not null) THEN -- only arrival dates

                l_diff_arr := floor(p_arr_date_to - p_arr_date_from);

                IF (l_diff_arr >= 0 AND l_diff_arr <= 7) THEN
                    l_query := l_query || ' AND (';
                    FOR l_counter IN 0..l_diff_arr LOOP
                        l_query := l_query || ' ( to_date(to_char(trunc(:' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || '), ''MM-dd-yyyy'') || '' '' || s.arrival_time, :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, l_date_format, g_varchar2, g_type3);

                        l_query := l_query || ') + :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(l_counter), g_number, g_type3);

                        l_query := l_query || ' between :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        l_query := l_query || ' and :' || g_bind_counter_global || ' )';
                        Process_Bind_Var(x_bindvars, to_char(p_arr_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                        IF (l_counter < l_diff_arr) THEN
                            l_query := l_query || ' OR ';
                        END IF;

                    END LOOP;

                    l_query := l_query || ' ) ';

                END IF;  -- end if l_diff_arr >= 0 AND l_diff_arr <= 7

            END IF;  -- end if all 4 dates are not null
        END IF;

        l_query := l_query || ' ) '; -- closes  OR ( s.frequency_type = 'DAILY'
--      dbms_output.put_line('end of daily frequency schedules');

        -- weekly schedules
        -- there are 3 conditions needed in AND
        -- 1) departure day is in frequency range values
        -- 2) arrival day is in frequency arrival range values
        -- 3) departure day - arrival day = arrival time indicator

        IF (p_dep_date_from is not null AND p_dep_date_to is not null) THEN
            l_diff_dep := floor(p_dep_date_to - p_dep_date_from);
        END IF;

        IF ( p_dep_date_from is not null OR p_dep_date_to is not null OR
             p_arr_date_from is not null OR p_arr_date_to is not null ) THEN

            l_query := l_query || ' OR (';

            -- condition 1
            IF (p_dep_date_from is not null AND p_dep_date_to is null) THEN
                l_dep_from_day_of_week := to_number(to_char(l_dep_date_from, 'D'));

            ELSIF (p_dep_date_from is null AND p_dep_date_to is not null) THEN
                l_dep_to_day_of_week := to_number(to_char(l_dep_date_to, 'D'));

            ELSIF (p_dep_date_from is not null AND p_dep_date_to is not null) THEN

                l_condition_one := 'Y';

                l_dep_from_day_of_week := to_number(to_char(l_dep_date_from, 'D'));
                l_dep_to_day_of_week := to_number(to_char(l_dep_date_to, 'D'));

--      dbms_output.put_line('CONDITION 1: l_diff_dep = ' || l_diff_dep);
--      dbms_output.put_line('CONDITION 1: l_dep_from_day_of_week = ' || l_dep_from_day_of_week);
--      dbms_output.put_line('CONDITION 1: l_dep_to_day_of_week = ' || l_dep_to_day_of_week);

                IF (l_diff_dep >= 7) THEN
                    l_query := l_query || ' (s.frequency_type = ''WEEKLY'')';
                ELSE
                    l_dep_date_from_time := to_char(l_dep_date_from, 'HH24:MI');
                    l_dep_date_to_time := to_char(l_dep_date_to, 'HH24:MI');

                    IF (l_dep_to_day_of_week >= l_dep_from_day_of_week) THEN

                        l_counter2 := 1;
                        FOR l_counter IN l_dep_from_day_of_week..l_dep_to_day_of_week LOOP
                            l_dep_date_array(l_counter2) := l_counter;
                            l_counter2 := l_counter2 + 1;
                        END LOOP;

                    ELSE

                        l_counter2 := 1;
                        FOR l_counter IN l_dep_from_day_of_week..l_dep_to_day_of_week + 7 LOOP
                            l_mod_var := mod(l_counter, 7);
                            IF (l_mod_var = 0) THEN
                                l_mod_var := 7;
                            END IF;
                            l_dep_date_array(l_counter2) := l_mod_var;
                            l_counter2 := l_counter2 + 1;
                        END LOOP;

                    END IF;

                    IF (l_dep_date_array.COUNT > 0) THEN
                        l_query := l_query || ' ( ';
                    END IF;

                    IF (l_dep_date_array.COUNT = 1) THEN

                        l_query := l_query || ' s.frequency like :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, '%' || l_dep_date_array(1) || '%', g_varchar2, g_type3);

                        l_query := l_query || ' and to_date(departure_time, ''hh24:mi'') >= to_date(:' ||
                                   g_bind_counter_global || ', ''hh24:mi'')';
                        Process_Bind_Var(x_bindvars, l_dep_date_from_time, g_varchar2, g_type3);

                        l_query := l_query || ' and to_date(departure_time, ''hh24:mi'') <= to_date(:' ||
                                   g_bind_counter_global || ', ''hh24:mi'')';
                        Process_Bind_Var(x_bindvars, l_dep_date_to_time, g_varchar2, g_type3);

                    ELSE

                        FOR l_counter IN 1..l_dep_date_array.COUNT LOOP

                            l_query := l_query || ' ( s.frequency like :' || g_bind_counter_global;
                            Process_Bind_Var(x_bindvars, '%' || l_dep_date_array(l_counter) || '%', g_varchar2, g_type3);

                            IF (l_counter = 1) THEN  -- first frequency
                                l_query := l_query || ' and to_date(departure_time, ''hh24:mi'') >= to_date(:' ||
                                           g_bind_counter_global || ', ''hh24:mi'')';
                                Process_Bind_Var(x_bindvars, l_dep_date_from_time, g_varchar2, g_type3);
                            END IF;

                            IF (l_counter = l_dep_date_array.COUNT) THEN  -- last frequency
                                l_query := l_query || ' and to_date(departure_time, ''hh24:mi'') <= to_date(:' ||
                                           g_bind_counter_global || ', ''hh24:mi'')';
                                Process_Bind_Var(x_bindvars, l_dep_date_to_time, g_varchar2, g_type3);
                            END IF;

                            IF (l_counter <> 1 AND l_counter <> l_dep_date_array.COUNT) THEN
                                l_query := l_query || ')';
                            END IF;

                            IF (l_counter < l_dep_date_array.COUNT) THEN
                                l_query := l_query || ' OR ';
                            END IF;

                        END LOOP;


                        l_query := l_query || ' ) ) '; -- ends if l_dep_date_array.COUNT > 0  --EXTRA )?

                    END IF;

                    IF (l_dep_date_array.COUNT > 0) THEN
                        l_query := l_query || ' ) '; -- ends OR ( in beginning of weekly schedules
                    END IF;

                END IF;

            END IF; -- end condition 1
--      dbms_output.put_line('end condition 1');

            -- added 11/18/02 11:30am
            IF (l_condition_one = 'N') THEN
--              dbms_output.put_line('adding clause for weekly');
                l_query := l_query || ' (s.frequency_type = ''WEEKLY'' ';
            END IF;
            -- end added

            -- condition 2
            IF (p_arr_date_from is not null AND p_arr_date_to is null) THEN
                l_arr_from_day_of_week := to_number(to_char(l_arr_date_from, 'D'));

                l_query := l_query || ' ) '; -- added 11/15/02 11:11am

            ELSIF (p_arr_date_from is null AND p_arr_date_to is not null) THEN
                l_arr_to_day_of_week := to_number(to_char(l_arr_date_to, 'D'));

                l_query := l_query || ' ) '; -- added 11/15/02 11:11am

            ELSIF (p_arr_date_from is not null AND p_arr_date_to is not null) THEN

                -- if condition 1 is true
                IF (l_condition_one = 'Y') THEN
                    l_query := l_query || ' AND ';
                ELSE
                    l_query := l_query || ' ) AND ';
                END IF;

                l_arr_from_day_of_week := to_number(to_char(l_arr_date_from, 'D'));
                l_arr_to_day_of_week := to_number(to_char(l_arr_date_to, 'D'));

                l_diff_arr := floor(p_arr_date_to - p_arr_date_from);
--      dbms_output.put_line('CONDITION 2: l_diff_arr = ' || l_diff_arr);
--      dbms_output.put_line('CONDITION 2: l_arr_from_day_of_week = ' || l_arr_from_day_of_week);
--      dbms_output.put_line('CONDITION 2: l_arr_to_day_of_week = ' || l_arr_to_day_of_week);

                IF (l_diff_arr >= 7) THEN
                    l_query := l_query || ' (s.frequency_type = ''WEEKLY'')';
                ELSE
                    l_arr_date_from_time := to_char(l_arr_date_from, 'HH24:MI');
                    l_arr_date_to_time := to_char(l_arr_date_to, 'HH24:MI');

                    IF (l_arr_to_day_of_week >= l_arr_from_day_of_week) THEN

                        l_counter2 := 1;
                        FOR l_counter IN l_arr_from_day_of_week..l_arr_to_day_of_week LOOP
                            l_arr_date_array(l_counter2) := l_counter;
                            l_counter2 := l_counter2 + 1;
                        END LOOP;

                    ELSE

                        l_counter2 := 1;
                        FOR l_counter IN l_arr_from_day_of_week..l_arr_to_day_of_week + 7 LOOP
                            l_mod_var := mod(l_counter, 7);
                            IF (l_mod_var = 0) THEN
                                l_mod_var := 7;
                            END IF;
                            l_arr_date_array(l_counter2) := l_mod_var;
                            l_counter2 := l_counter2 + 1;
                        END LOOP;

                    END IF;

                    IF (l_arr_date_array.COUNT > 0) THEN
                        l_query := l_query || ' ( ';
                    END IF;

                    IF (l_arr_date_array.COUNT = 1) THEN
                        l_query := l_query || ' s.frequency_arrival like :' || g_bind_counter_global;
                        Process_Bind_Var(x_bindvars, '%' || l_arr_date_array(1) || '%', g_varchar2, g_type3);

                        l_query := l_query || ' and to_date(arrival_time, ''hh24:mi'') >= to_date(:' ||
                                   g_bind_counter_global || ', ''hh24:mi'')';
                        Process_Bind_Var(x_bindvars, l_arr_date_from_time, g_varchar2, g_type3);

                        l_query := l_query || ' and to_date(arrival_time, ''hh24:mi'') <= to_date(:' ||
                                   g_bind_counter_global || ', ''hh24:mi'')';
                        Process_Bind_Var(x_bindvars, l_arr_date_to_time, g_varchar2, g_type3);

                    ELSE

                        FOR l_counter IN 1..l_arr_date_array.COUNT LOOP

                            l_query := l_query || ' ( s.frequency_arrival like :' || g_bind_counter_global;
                            Process_Bind_Var(x_bindvars, '%' || l_arr_date_array(l_counter) || '%', g_varchar2, g_type3);

                            IF (l_counter = 1) THEN  -- first frequency
                                l_query := l_query || ' and to_date(arrival_time, ''hh24:mi'') >= to_date(:' ||
                                           g_bind_counter_global || ', ''hh24:mi'')';
                                Process_Bind_Var(x_bindvars, l_arr_date_from_time, g_varchar2, g_type3);
                            END IF;

                            IF (l_counter = l_arr_date_array.COUNT) THEN  -- last frequency
                                l_query := l_query || ' and to_date(arrival_time, ''hh24:mi'') <= to_date(:' ||
                                           g_bind_counter_global || ', ''hh24:mi'')';
                                Process_Bind_Var(x_bindvars, l_arr_date_to_time, g_varchar2, g_type3);
                            END IF;

                            IF (l_counter <> 1 AND l_counter <> l_arr_date_array.COUNT) THEN
                                l_query := l_query || ')';
                            END IF;

                            IF (l_counter < l_arr_date_array.COUNT) THEN
                                l_query := l_query || ' OR ';
                            END IF;

                        END LOOP;

                        l_query := l_query || ' ) ) ';

                    END IF;

                    IF (l_arr_date_array.COUNT > 0) THEN
                        l_query := l_query || ' ) ';
                    END IF;

                END IF;

            ELSE -- both arrival dates are null

                l_query := l_query || ' ) '; -- added 11/15/02 12:35am

            END IF;
            -- end condition 2
--      dbms_output.put_line('end condition 2');

            IF (l_condition_one = 'N') THEN -- if not condition 1
                l_query := l_query || ' ) ';
            END IF;

            l_query := l_query || ' ) '; -- added 11/15/02 11:30am to close the entire clause starting with daily schedules and before figuring out the arrival date indicator stuff

            -- condition 3
            -- case A] from dep, to dep, from arr, to arr are all specified (full range)
            IF (p_dep_date_from is not null AND p_dep_date_to is not null AND
                p_arr_date_from is not null AND p_arr_date_to is not null) THEN

                IF (l_dep_from_day_of_week > l_dep_to_day_of_week) THEN

                    l_dep_to_day_of_week := l_dep_to_day_of_week + 7;
                    l_arr_from_day_of_week := l_arr_from_day_of_week + 7;
                    l_arr_to_day_of_week := l_arr_to_day_of_week + 7;
                    l_tag := 'Y';

                END IF;

                IF (l_arr_from_day_of_week > l_dep_to_day_of_week) THEN

                    IF (l_arr_to_day_of_week < l_arr_from_day_of_week) THEN
                        l_arr_to_day_of_week := l_arr_to_day_of_week + 7;
                    END IF;

                ELSE

                    IF (l_arr_from_day_of_week <> l_dep_to_day_of_week OR
                        l_tag = 'Y') THEN

                        l_arr_from_day_of_week := l_arr_from_day_of_week + 7;
                        l_arr_to_day_of_week := l_arr_to_day_of_week + 7;

                    END IF;

                END IF;

                IF (l_arr_from_day_of_week > l_arr_to_day_of_week) THEN

                    l_arr_to_day_of_week := l_arr_to_day_of_week + 7;

                END IF;

                l_date_range_from := l_arr_from_day_of_week - l_dep_to_day_of_week;
                l_date_range_to := l_arr_to_day_of_week - l_dep_from_day_of_week;

                l_query := l_query || ' AND to_number(nvl(s.arrival_date_indicator, 0)) <= ceil(:' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, to_char(p_arr_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);
                l_query := l_query || ' - :' || g_bind_counter_global || ')';
                Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                IF (p_dep_date_from <> p_dep_date_to OR
                    p_arr_date_from <> p_arr_date_to) THEN

                    l_query := l_query || ' AND to_number(nvl(s.arrival_date_indicator, 0)) >= ceil(:' || g_bind_counter_global;
                    Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);
                    l_query := l_query || ' - :' || g_bind_counter_global || ')';
                    Process_Bind_Var(x_bindvars, to_char(p_dep_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

                END IF;
--      dbms_output.put_line('end condition 3A');
                l_query := l_query || ')'; -- maybe should comment out? 11/15/02

            END IF; -- end condition 3 case A]
            -- case B] from dep, to dep, from arr are specified, to arr is null
            IF (p_dep_date_from is not null AND p_dep_date_to is not null AND
                p_arr_date_from is not null AND p_arr_date_to is null) THEN

                IF (p_arr_date_from > p_dep_date_from AND
                    l_arr_from_day_of_week < l_dep_from_day_of_week) THEN
                    l_date_range_from := l_arr_from_day_of_week - l_dep_from_day_of_week + 7;
                ELSE
                    l_date_range_from := l_arr_from_day_of_week - l_dep_from_day_of_week;
                END IF;

                l_query := l_query || ' AND mod(to_number(nvl(s.arrival_date_indicator, :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ')), 7) >= :' || g_bind_counter_global || ' ';
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
--      dbms_output.put_line('end condition 3B');

            END IF; -- end condition 3 case B]
            -- condition 3 case C] from dep, from arr, to arr are specified, to dep is null
            IF (p_dep_date_from is not null AND p_dep_date_to is null AND
                p_arr_date_from is not null AND p_arr_date_to is not null) THEN
--      dbms_output.put_line('IN CONDITION 3C');

                IF (p_dep_date_from <= p_arr_date_to) THEN
                    l_date_range_from := -1;
                    l_date_range_to := mod(l_arr_to_day_of_week - l_dep_from_day_of_week + 7, 7);
                ELSE
                    l_date_range_from := -2;
                    l_date_range_to := l_date_range_from;
                END IF;

                l_query := l_query || ' AND mod(to_number(nvl(s.arrival_date_indicator, :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ')), 7) between :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ' and :' || g_bind_counter_global || ' ';
                Process_Bind_Var(x_bindvars, l_date_range_to, g_number, g_type3);
--      dbms_output.put_line('end condition 3C');

            END IF; -- end condition 3 case C]

            -- condition 3 case D] from dep, from arr are not null, to dep and to arr are null (no ranges)
            IF (p_dep_date_from is not null AND p_dep_date_to is null AND
                p_arr_date_from is not null AND p_arr_date_to is null) THEN
--      dbms_output.put_line('IN CONDITION 3D');

                IF (l_arr_from_day_of_week < l_dep_from_day_of_week) THEN
                    l_date_range_from := -2;
                ELSE
                    l_date_range_from := mod(l_arr_from_day_of_week - l_dep_from_day_of_week + 7, 7);
                END IF;

                l_query := l_query || ' AND to_number(nvl(s.arrival_date_indicator, 0)) >= ceil(:' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);
                l_query := l_query || ' - :' || g_bind_counter_global || ')';
                Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);
--      dbms_output.put_line('end condition 3D');

            END IF; -- end condition 3 case D]

            -- condition 3 case E]
            IF (p_dep_date_from is null AND p_dep_date_to is not null AND
                p_arr_date_from is not null AND p_arr_date_to is not null) THEN -- dep from is null

                IF (p_dep_date_to <= p_arr_date_from AND
                    p_dep_date_to <= p_arr_date_to) THEN
                    l_date_range_from := mod(l_arr_from_day_of_week - l_dep_to_day_of_week + 7, 7);
                    l_date_range_to := 200; -- doesn't matter, as long as it is big
                ELSIF (p_dep_date_to >= p_arr_date_from AND
                       p_dep_date_to <= p_arr_date_to) THEN
                    l_date_range_from := -1;
                    l_date_range_to := mod(l_arr_to_day_of_week - l_dep_to_day_of_week + 7, 7);
                ELSE
                    l_date_range_from := -2;
                    l_date_range_to := l_date_range_from;
                END IF;

                l_query := l_query || ' AND mod(to_number(nvl(s.arrival_date_indicator, :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ')), 7) between :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ' and :' || g_bind_counter_global || ' ';
                Process_Bind_Var(x_bindvars, l_date_range_to, g_number, g_type3);
--      dbms_output.put_line('end condition 3E');
            END IF; -- end condition 3 case E]

            -- condition 3 case F]
            IF (p_dep_date_from is not null AND p_dep_date_to is not null AND
                p_arr_date_from is null AND p_arr_date_to is not null) THEN

                IF (p_arr_date_to >= p_dep_date_from AND
                    p_arr_date_to >= p_dep_date_to) THEN
                    l_date_range_from := mod(l_arr_to_day_of_week - l_dep_to_day_of_week + 7, 7);
                    l_date_range_to := mod(l_arr_to_day_of_week - l_dep_from_day_of_week + 7, 7);
                ELSIF (p_arr_date_to >= p_dep_date_from AND
                       p_arr_date_to <= p_dep_date_to) THEN
                    l_date_range_from := -1;
                    l_date_range_to := mod(l_arr_to_day_of_week - l_dep_from_day_of_week + 7, 7);
                ELSE
                    l_date_range_from := -2;
                    l_date_range_to := l_date_range_from;
                END IF;

                l_query := l_query || ' AND mod(to_number(nvl(s.arrival_date_indicator, :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ')), 7) between :' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, l_date_range_from, g_number, g_type3);
                l_query := l_query || ' and :' || g_bind_counter_global || ' ';
                Process_Bind_Var(x_bindvars, l_date_range_to, g_number, g_type3);

--      dbms_output.put_line('end condition 3F');
            END IF; -- end condition 3 case F]

            -- condition 3 case G]
            IF (p_dep_date_from is not null AND p_dep_date_to is null AND
                p_arr_date_from is null AND p_arr_date_to is not null) THEN

                IF (l_arr_to_day_of_week < l_dep_from_day_of_week) THEN
                    l_date_range_from := -2;
                ELSE
                    l_date_range_from := mod(l_arr_to_day_of_week - l_dep_from_day_of_week + 7, 7);
                END IF;

                l_query := l_query || ' AND to_number(nvl(s.arrival_date_indicator, 0)) <= ceil(:' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, to_char(p_arr_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);
                l_query := l_query || ' - :' || g_bind_counter_global || ')';
                Process_Bind_Var(x_bindvars, to_char(p_dep_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

            END IF;

            -- condition 3 case H]
            IF (p_dep_date_from is null AND p_dep_date_to is not null AND
                p_arr_date_from is not null AND p_arr_date_to is null) THEN

                IF (l_arr_from_day_of_week < l_dep_to_day_of_week) THEN
                    l_date_range_from := -2;
                ELSE
                    l_date_range_from := mod(l_arr_from_day_of_week - l_dep_to_day_of_week + 7, 7);
                END IF;

                l_query := l_query || ' AND to_number(nvl(s.arrival_date_indicator, 0)) >= ceil(:' || g_bind_counter_global;
                Process_Bind_Var(x_bindvars, to_char(p_arr_date_from, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);
                l_query := l_query || ' - :' || g_bind_counter_global || ')';
                Process_Bind_Var(x_bindvars, to_char(p_dep_date_to, 'mm-dd-yyyy hh24:mi'), g_date, g_type3);

            END IF;

        ELSE
--          dbms_output.put_line('putting frequency_type = weekly');
            l_query := l_query || ' OR s.frequency_type = ''WEEKLY''';

        END IF;


        l_query := l_query || ')';

        x_query := l_query;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Create_Schedule_Clause;


  -- ----------------------------------------------------------------
  -- Name:              Create_Rate_Chart_Query
  -- Type:              Procedure
  --
  -- Description:       This procedure takes origin, destination info
  --                    and the carrier name, and creates the query
  --                    that will obtain a list of rate chart ids
  --                    which match the criteria.
  --                    Returns the bind variable array and query.
  --
  -- -----------------------------------------------------------------
  PROCEDURE Create_Rate_Chart_Query(p_parent_origins            IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                    p_parent_destinations       IN      FTE_LANE_SEARCH_QUERY_GEN.fte_lane_search_regions_tab,
                                    p_origin_zip_request        IN      VARCHAR2,
                                    p_dest_zip_request          IN      VARCHAR2,
                                    p_carrier_name              IN      VARCHAR2,
                                    p_tariff_name               IN      VARCHAR2,
                                    x_query                     OUT NOCOPY      VARCHAR2,
                                    x_bindvars                  OUT NOCOPY      FTE_LANE_SEARCH_QUERY_GEN.bindvars) IS

  l_query       VARCHAR2(5000);
  l_reg_query   VARCHAR2(4000);

  l_bindvars    FTE_LANE_SEARCH_QUERY_GEN.bindvars;

        --
        l_debug_on BOOLEAN;
        --
        l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'CREATE_RATE_CHART_QUERY';
        --

  BEGIN

        --
        l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
        --
        IF l_debug_on IS NULL
        THEN
            l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
        END IF;
        --
        --
        -- Debug Statements
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.push(l_module_name);
        END IF;
        --

        g_bind_counter_global := 1;
        --g_bind_counter_common := 1;
        g_bind_counter1 := 1;

        -- Changes for J:Multiple Rate Charts
        --l_query := 'select distinct l.pricelist_id ';
        l_query := 'select distinct lrc.list_header_id ';

        WSH_DEBUG_SV.log(l_module_name,'p_parent_origins Coiunt',p_parent_origins.COUNT);
        WSH_DEBUG_SV.log(l_module_name,'p_parent_destinations Count', p_parent_destinations.COUNT);
        WSH_DEBUG_SV.log(l_module_name,'p_tariff_name', p_tariff_name);
        IF (p_parent_origins is not null OR p_parent_destinations is not null)
          AND (p_parent_origins.COUNT > 0 OR p_parent_destinations.COUNT > 0) THEN

           -- Changes for J:Multiple Rate Charts
           /*
           l_query := l_query || 'from fte_lanes l, hz_parties hz, wsh_zone_regions zr, ' ||
                       'wsh_zone_regions pd where l.pricelist_id is not null ' ||
                       'AND l.origin_id = zr.parent_region_id ' ||
                       'AND l.destination_id = pd.parent_region_id ' ||
                       'AND l.carrier_id = hz.party_id ' ||
                       'and upper(hz.party_name) like upper(:' || g_bind_counter_global || ')';
            */
            l_query := l_query || 'from fte_lanes l, hz_parties hz, wsh_zone_regions zr, ' ||
                       'wsh_zone_regions pd, fte_lane_rate_charts lrc where l.lane_id = lrc.lane_id ' ||
                       'AND l.origin_id = zr.parent_region_id ' ||
                       'AND l.destination_id = pd.parent_region_id ' ||
                       'AND l.carrier_id = hz.party_id ' ||
                       'and upper(hz.party_name) like upper(:' || g_bind_counter_global || ')';

            Process_Bind_Var(l_bindvars, p_carrier_name || '%', g_varchar2, g_type1);
            /*IF (p_tariff_name is not null) THEN
              l_query := l_query ||' AND l.tariff_name like :' || g_bind_counter_global;
              Process_Bind_Var(l_bindvars, p_tariff_name || '%', g_varchar2, g_type1);
            END IF;*/
            Create_Regions_Clause(p_parent_origins              => p_parent_origins,
                                  p_parent_destinations         => p_parent_destinations,
                                  p_origin_zip_request          => p_origin_zip_request,
                                  p_dest_zip_request            => p_dest_zip_request,
                                  x_query                       => l_reg_query,
                                  x_bindvars                    => l_bindvars);

            l_query := l_query || l_reg_query;

        ELSE -- only have carrier
            -- Changes for J:Multiple Rate Charts
            /*
            l_query := l_query || 'from fte_lanes l, hz_parties hz ' ||
                       'where pricelist_id is not null and upper(party_name) ' ||
                       'like upper(:' || g_bind_counter_global || ')';
            */
            l_query := l_query || 'from fte_lanes l, hz_parties hz, fte_lane_rate_charts lrc ' ||
                       'where l.lane_id = lrc.lane_id and upper(hz.party_name) ' ||
                       'like upper(:' || g_bind_counter_global || ')';

            Process_Bind_Var(l_bindvars, p_carrier_name || '%', g_varchar2, g_type1);
            /*IF (p_tariff_name is not null) THEN
              l_query := l_query ||' AND l.tariff_name like :' || g_bind_counter_global;
              Process_Bind_Var(l_bindvars, p_tariff_name || '%', g_varchar2, g_type1);
            END IF;*/
        END IF;



        x_query := l_query;
        x_bindvars := l_bindvars;

--
-- Debug Statements
--
IF l_debug_on THEN
    WSH_DEBUG_SV.pop(l_module_name);
END IF;
--
  END Create_Rate_Chart_Query;


END FTE_LANE_SEARCH_QUERY_GEN;

/
