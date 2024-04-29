--------------------------------------------------------
--  DDL for Package Body FTE_TL_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TL_CORE" AS
/* $Header: FTEVTLOB.pls 120.2 2005/07/25 13:26:29 susurend noship $ */


-- package global declarations
   G_PKG_NAME VARCHAR2(100) := 'FTE_TL_CORE';

   -- following constants used to identify purpose of request lines

   G_LOADED_DIST_BASE_LINE    NUMBER := 1;
   G_UNLOADED_DIST_BASE_LINE  NUMBER := 2;
   G_CONT_DIST_BASE_LINE      NUMBER := 3;
   G_UNITS_BASE_LINE          NUMBER := 4;
   G_TIME_BASE_LINE           NUMBER := 5;
   G_FLAT_BASE_LINE           NUMBER := 6;
   G_LOAD_CHARGE_LINE         NUMBER := 7;
   G_STOP_CHARGE_LINE         NUMBER := 8;
   G_FACILITY_CHARGE_LINE     NUMBER := 9;
   G_CONT_DH_BASE_LINE        NUMBER := 10;

   TYPE req_line_info_rec_type IS RECORD (
                 line_index   NUMBER,  -- index of qp request line
                 line_type    NUMBER,  -- identifies purpose of request line
                 trip_index   NUMBER,  -- index into the trip cache (for multiple)
                 stop_index   NUMBER,   -- index into stop cache
                 line_qty     NUMBER,
                 line_uom     VARCHAR2(30),
                 currency     VARCHAR2(30),   -- lines can have diff. currency
                 lane_id      NUMBER,
                 pricelist_id NUMBER,
                 carrier_id   NUMBER
   );

   TYPE req_line_info_tab_type IS TABLE OF req_line_info_rec_type INDEX BY BINARY_INTEGER;

   g_req_line_info_tab  req_line_info_tab_type;

    CURSOR get_uom_for_each
    IS
    SELECT uom_for_num_of_units
    FROM wsh_global_parameters;

-- Procedure declarations

  PROCEDURE create_input_line (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE create_control_rec ( x_return_status     OUT NOCOPY VARCHAR2);


  PROCEDURE create_engine_inputs (
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   p_trip_index	       IN NUMBER DEFAULT NULL,
                   x_implicit_non_dummy_cnt OUT NOCOPY NUMBER,
                   x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE create_line_attributes (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_return_status     OUT NOCOPY VARCHAR2);


  PROCEDURE create_charge_line_attributes (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_pricing_attr_tab  IN OUT NOCOPY fte_freight_pricing.pricing_attribute_tab_type,
                   x_return_status     OUT NOCOPY VARCHAR2);


  PROCEDURE create_line_qualifiers (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE retrieve_qp_output (
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   p_qp_output_line_rows    IN QP_PREQ_GRP.LINE_TBL_TYPE,
                   p_qp_output_detail_rows  IN QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
                   x_trip_charges_rec  OUT NOCOPY FTE_TL_CACHE.TL_trip_output_rec_type,
                   x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
                   x_return_status     OUT NOCOPY VARCHAR2);

  PROCEDURE print_output(
                   p_trip_charges_rec  IN FTE_TL_CACHE.TL_trip_output_rec_type,
                   p_stop_charges_tab  IN FTE_TL_CACHE.TL_trip_stop_output_tab_type
  );

-- This procedure throws a not on pricelist excpetion if
-- all the non-dummy(not dummy stop,trip charge lines) qp output lines have an IPL status
--

PROCEDURE check_qp_ipl(p_qp_output_line_rows   IN QP_PREQ_GRP.LINE_TBL_TYPE,
                       p_implicit_non_dummy_cnt IN NUMBER,
			x_return_status     OUT NOCOPY VARCHAR2)
IS
      i NUMBER;
      l_non_dummy_row_count NUMBER;
      l_dummy_row_count NUMBER;
      l_dummy_ipl_count NUMBER;
      l_non_dummy_ipl_count NUMBER;
      l_line_type NUMBER;
      l_line_index NUMBER;
      l_ipl_flag VARCHAR2(1);

      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'check_qp_ipl';

BEGIN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);

	-- l_non_dummy_row_count:=0;
	-- bug 3610889
	l_non_dummy_row_count:= p_implicit_non_dummy_cnt;
	l_dummy_row_count:=0;
	l_dummy_ipl_count:=0;
	l_non_dummy_ipl_count:=0;
	i:=p_qp_output_line_rows.FIRST;
	WHILE (i IS NOT NULL)
	LOOP
		IF ((p_qp_output_line_rows(i).status_code IS NOT NULL) AND (p_qp_output_line_rows(i).status_code='IPL'))
		THEN
			l_ipl_flag:='Y';
		ELSE
			l_ipl_flag:='N';
		END IF;
		l_line_index:=p_qp_output_line_rows(i).line_index;
		IF ((l_line_index IS NOT NULL) AND (g_req_line_info_tab.EXISTS(l_line_index)))
		THEN
			l_line_type:=g_req_line_info_tab(l_line_index).line_type;
			--SUSUREND :classiffy a line as dummy if it is a trip level charge line,stop level charge line
			--or facility line
			IF ((l_line_type IS NOT NULL) AND (l_line_type <> G_LOAD_CHARGE_LINE)
				AND (l_line_type <>G_STOP_CHARGE_LINE ) AND (l_line_type <>G_FACILITY_CHARGE_LINE))
			THEN
				l_non_dummy_row_count:=l_non_dummy_row_count+1;
				IF (l_ipl_flag='Y')
				THEN
					l_non_dummy_ipl_count:=l_non_dummy_ipl_count+1;
				END IF;
			ELSE
				l_dummy_row_count:=l_dummy_row_count+1;
				IF (l_ipl_flag='Y')
				THEN
					l_dummy_ipl_count:=l_dummy_ipl_count+1;
				END IF;


			END IF;

		ELSE
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Index not found:'||i);

		END IF;


		i:=p_qp_output_line_rows.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Number of dummy lines:'||l_dummy_row_count
		||' Number of non dummy lines:'||l_non_dummy_row_count||' Dummy IPLs:'||l_dummy_ipl_count||
		' Non Dummy IPLs :'||l_non_dummy_ipl_count);
	IF (l_non_dummy_ipl_count >= l_non_dummy_row_count)
	THEN
		raise fte_freight_pricing_util.g_not_on_pricelist;
	END IF;

       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

EXCEPTION
WHEN fte_freight_pricing_util.g_not_on_pricelist THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- can use tokens here
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_on_pricelist');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Item quantity not found on pricelist ');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

END check_qp_ipl;



  PROCEDURE print_req_line_tab;

-- +======================================================================+
--   Procedure :
--           tl_core
--
--   Description:
--           Build the call structure for the pricing engine, invoke the
--           rating engine, analyze results, return results.
--   Inputs:
--           p_trip_rec    IN TL_trip_data_input_rec_type
--           p_stop_tab          IN TL_trip_stop_input_tab_type,
--           p_carrier_pref      IN TL_carrier_pref_rec_type,
--   Output:
--           x_trip_charges_rec  OUT NOCOPY  TL_trip_output_rec_type,
--           x_stop_charges_tab  OUT NOCOPY TL_trip_stop_output_tab_type,
--           x_return_status     OUT NOCOPY VARCHAR2
--
--   Global dependencies:
--           No direct
--
--   DB:
--           No direct
-- +======================================================================+

  PROCEDURE tl_core (
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_trip_charges_rec  OUT NOCOPY FTE_TL_CACHE.TL_trip_output_rec_type,
                   x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
                   x_return_status     OUT NOCOPY VARCHAR2)
  IS

     l_pricing_control_rec           fte_freight_pricing.pricing_control_input_rec_type;
     l_pricing_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
     l_curr_line_idx                 NUMBER := 0;
     l_req_line_info_rec             req_line_info_rec_type;
     l_qp_output_line_rows           QP_PREQ_GRP.LINE_TBL_TYPE;
     l_qp_output_detail_rows         QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
     l_implicit_non_dummy_cnt        NUMBER := 0;


     l_return_status                 VARCHAR2(1);

     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'tl_core';
  BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    fte_freight_pricing_util.reset_dbg_vars;
    fte_freight_pricing_util.set_method(l_log_level,l_method_name);

    -- create request lines
        -- distance, time, ..
        -- for each request line - build qualifiers
        -- for each base price request line - build attributes
        -- for each charge request line - build attributes
    -- call qp engine
    -- check qp errors
    -- analyze o/p
        -- analyze and extract charges

    -- First clear all global tables ***
    g_req_line_info_tab.DELETE;
    FTE_QP_ENGINE.clear_globals(x_return_status => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After clear_globals ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_clear_globals_fl');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- g_effectivity dates is the global variable which stores the dates passed to QP
    -- these dates are set to the trip departure dates. For price list selection, only the
    -- trip departure date is used (not arrival).
    --SUSUREND 11-Nov-2003

    fte_freight_pricing.g_effectivity_dates.date_from:=p_trip_rec.planned_departure_date;
    fte_freight_pricing.g_effectivity_dates.date_to:=p_trip_rec.planned_departure_date;

    -- bug 3610889 : added new parameter p_implicit_non_dummy_cnt
    create_engine_inputs (
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_implicit_non_dummy_cnt => l_implicit_non_dummy_cnt,
                   x_return_status     => l_return_status );

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_eng_inp_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_implicit_non_dummy_cnt = '||l_implicit_non_dummy_cnt);
    -- fte_qp_engine.print_qp_input;

       -- call qp engine

    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'g_req_line_info_tab.COUNT = '||g_req_line_info_tab.COUNT);

    print_req_line_tab;

    fte_qp_engine.call_qp_api  (
        x_qp_output_line_rows    => l_qp_output_line_rows,
        x_qp_output_detail_rows  => l_qp_output_detail_rows,
    x_return_status          => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After call_qp_api ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_call_qp_api_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- fte_qp_engine.check_qp_output_errors (x_return_status  => l_return_status);
    fte_qp_engine.check_tl_qp_output_errors (x_return_status  => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After check_qp_output_errors ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_chk_qp_output_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    check_qp_ipl(p_qp_output_line_rows=>l_qp_output_line_rows,
                p_implicit_non_dummy_cnt => l_implicit_non_dummy_cnt,
		x_return_status => l_return_status );

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After check_qp_ipl ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_check_qp_ipl_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;



       -- check qp engine output for errors
       -- handle errors if any

       -- process qp output
    retrieve_qp_output (
                   p_trip_rec              => p_trip_rec,
                   p_stop_tab              => p_stop_tab,
                   p_carrier_pref          => p_carrier_pref,
                   p_qp_output_line_rows   => l_qp_output_line_rows,
                   p_qp_output_detail_rows => l_qp_output_detail_rows,
                   x_trip_charges_rec      => x_trip_charges_rec,
                   x_stop_charges_tab      => x_stop_charges_tab,
                   x_return_status         => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After retrieve_qp_output ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_ret_qp_out_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

     print_output( p_trip_charges_rec  => x_trip_charges_rec,
                   p_stop_charges_tab  => x_stop_charges_tab);



     fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
  END tl_core;

  PROCEDURE create_engine_inputs (
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   p_trip_index	       IN NUMBER DEFAULT NULL,
                   x_implicit_non_dummy_cnt OUT NOCOPY NUMBER,
                   x_return_status     OUT NOCOPY VARCHAR2)
  IS

     l_uom_ea			     VARCHAR2(30);
     l_pricing_control_rec           fte_freight_pricing.pricing_control_input_rec_type;
     l_pricing_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
     l_curr_line_idx                 NUMBER := 0;
     l_req_line_info_rec             req_line_info_rec_type;
     i                               NUMBER := 0;
     l_return_status                 VARCHAR2(1);

     l_tmp_dist                      NUMBER;


     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'create_engine_inputs';

  BEGIN

          -- do we need to store which line index corresponds to which type of line?
       -- create distance lines
       -- create time line
       -- create unit line
       -- create flat line
       -- create load line
       -- create stop lines
       -- create control rec

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);

       x_implicit_non_dummy_cnt := 0;

       IF (p_trip_index IS NOT NULL)
       THEN
         l_req_line_info_rec.trip_index:=p_trip_index;
         l_curr_line_idx:=g_req_line_info_tab.COUNT;

       END IF;


       OPEN get_uom_for_each;
       FETCH get_uom_for_each INTO l_uom_ea;
       CLOSE get_uom_for_each;

	IF l_uom_ea is null THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After get_uom_for_each ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_get_uom_for_each_failed');
          raise FND_API.G_EXC_ERROR;
	END IF;

       -- VVP: 09/18/03
       -- Made a few changes to account for 'DIRECT_ROUTE' vs 'FULL_ROUTE'
       -- Basically, if distance method is direct route, we should be using direct route
       -- distance for base prices. This means we cannot account for loaded
       -- and unloaded distances. We still use loaded and unloaded distance fields
       -- to decide if the trip is non-empty or not.

       -- LineIndex=1 : Loaded (Generic) Distance Line
       IF ( p_trip_rec.loaded_distance > 0
          AND ( p_trip_rec.continuous_move = 'N'
                OR (p_trip_rec.continuous_move = 'Y'
                    AND p_carrier_pref.cm_rate_variant = 'DISCOUNT'))
          AND (
                (p_trip_rec.distance_method <> 'DIRECT_ROUTE')
                OR
                (p_trip_rec.distance_method = 'DIRECT_ROUTE'
                 AND p_trip_rec.total_direct_distance >0 )
              )
          ) THEN

         l_curr_line_idx := l_curr_line_idx + 1;


         l_req_line_info_rec.line_index := l_curr_line_idx;
         l_req_line_info_rec.line_type  := G_LOADED_DIST_BASE_LINE;
         l_req_line_info_rec.stop_index := null;
         IF (p_trip_rec.distance_method = 'DIRECT_ROUTE') THEN
            l_req_line_info_rec.line_qty   := p_trip_rec.total_direct_distance;
         ELSE
            l_req_line_info_rec.line_qty   := p_trip_rec.loaded_distance;
         END IF;
         l_req_line_info_rec.line_uom   := p_carrier_pref.distance_uom;
         l_req_line_info_rec.currency   := p_carrier_pref.currency;
         l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
         l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
         l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

         create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       END IF;


       -- Note For Unloaded line and DIRECT_ROUTE:
       -- If distance_method is DIRECT_ROUTE then normally we don't need to go here.
       -- This is because :
       --  a) non-continuous move - distance rate taken care of by generic (loaded) dist line
       --     [ there is no such thing as unloaded direct distance rate ]
       --  b) continuous move - and rate_var=DISCOUNT - same as above
       --  c) continuous move - and rate_var=RATE and not dead_head - taken care of by cont.
       --                       distance line
       --  d) continuous move - and rate_var=RATE and is dead_head - taken care of by cont.
       --                       distance deadhead line
       -- Exception :
       --  Empty trips: If non-continuous and continuous move with trip fully empty
       --  (empty trip or deadhead) then no point applying loaded distance rate
       --  even with direct_route.

       -- LineIndex=2 : Unloaded Distance Line
       -- Also for deadhead with discount variant
       IF (p_trip_rec.unloaded_distance > 0
          AND ( p_trip_rec.continuous_move = 'N'
                OR (p_trip_rec.continuous_move = 'Y'
                    AND p_carrier_pref.cm_rate_variant = 'DISCOUNT'))
          AND (
                (p_trip_rec.distance_method <> 'DIRECT_ROUTE')
                OR
                (p_trip_rec.distance_method = 'DIRECT_ROUTE'
                    AND p_trip_rec.total_direct_distance >0
                    AND p_trip_rec.loaded_distance = 0 ) -- see note above (empty trip)
              )
          )
       THEN

         l_curr_line_idx := l_curr_line_idx + 1;

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);
         fte_freight_pricing_util.print_msg(l_log_level,
                        'p_trip_rec.unloaded_distance = '||p_trip_rec.unloaded_distance);
         fte_freight_pricing_util.print_msg(l_log_level,
                        'p_trip_rec.continuous_move = '||p_trip_rec.continuous_move);
         fte_freight_pricing_util.print_msg(l_log_level,
                        'p_carrier_pref.cm_rate_variant = '||p_carrier_pref.cm_rate_variant);
         fte_freight_pricing_util.print_msg(l_log_level,
                        'p_trip_rec.dead_head = '||p_trip_rec.dead_head);
         fte_freight_pricing_util.print_msg(l_log_level,
                        'p_carrier_pref.cm_free_dh_mileage = '||p_carrier_pref.cm_free_dh_mileage);

         IF (p_trip_rec.distance_method = 'DIRECT_ROUTE') THEN
             l_tmp_dist := p_trip_rec.total_direct_distance;
         ELSE
             l_tmp_dist := p_trip_rec.unloaded_distance;
         END IF;

         -- subtract the free deadhead mileage from the deadhead distance
         -- if this is a deadhead
         IF (p_trip_rec.dead_head='Y' AND p_trip_rec.continuous_move='Y'
             AND p_carrier_pref.cm_free_dh_mileage >0) THEN
           IF l_tmp_dist > p_carrier_pref.cm_free_dh_mileage THEN
             l_req_line_info_rec.line_qty   := l_tmp_dist
                                               - p_carrier_pref.cm_free_dh_mileage;
	   ELSE
             l_req_line_info_rec.line_qty   := 0;
	   END IF;
         ELSE
             l_req_line_info_rec.line_qty   := l_tmp_dist;
         END IF;

         IF (l_req_line_info_rec.line_qty > 0) THEN

           l_req_line_info_rec.line_index := l_curr_line_idx;
           l_req_line_info_rec.line_type  := G_UNLOADED_DIST_BASE_LINE;
           l_req_line_info_rec.stop_index := null;
           --l_req_line_info_rec.line_qty   := p_trip_rec.unloaded_distance;
           l_req_line_info_rec.line_uom   := p_carrier_pref.distance_uom;
           l_req_line_info_rec.currency   := p_carrier_pref.currency;
           l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
           l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
           l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

           g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;

           create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

           IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                 FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
                 fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
                 raise FND_API.G_EXC_ERROR;
              END IF;
           END IF;

        END IF;

       END IF;

       -- Continuous Move Distance Line
       -- Is this required? What is the condition?
       IF ( p_trip_rec.loaded_distance > 0
            AND p_trip_rec.continuous_move = 'Y'
            AND p_carrier_pref.cm_rate_variant = 'RATE'
            AND (
                 (p_trip_rec.distance_method <> 'DIRECT_ROUTE')
                  OR
                 (p_trip_rec.distance_method = 'DIRECT_ROUTE'
                   AND p_trip_rec.total_direct_distance > 0)
                )
          ) THEN

         l_curr_line_idx := l_curr_line_idx + 1;

         l_req_line_info_rec.line_index := l_curr_line_idx;
         l_req_line_info_rec.line_type  := G_CONT_DIST_BASE_LINE;
         l_req_line_info_rec.stop_index := null;
         IF ( p_trip_rec.distance_method = 'DIRECT_ROUTE') THEN
             l_req_line_info_rec.line_qty   := p_trip_rec.total_direct_distance;
         ELSE
             l_req_line_info_rec.line_qty   := p_trip_rec.loaded_distance;
         END IF;
         l_req_line_info_rec.line_uom   := p_carrier_pref.distance_uom;
         l_req_line_info_rec.currency   := p_carrier_pref.currency;
         l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
         l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
         l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

         create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       END IF;

       -- Assumption here is that if a trip is in a continuous move
       -- then it will have any unloaded distance only if it is a dead head
       -- Need to verify this.

       -- Continuous Move Deadhead Line
       IF ( p_trip_rec.unloaded_distance > 0
	    AND ( (p_trip_rec.unloaded_distance > p_carrier_pref.cm_free_dh_mileage
                    AND p_trip_rec.distance_method <> 'DIRECT_ROUTE'
                  )
                  OR
                  (p_trip_rec.distance_method='DIRECT_ROUTE'
                    AND p_trip_rec.total_direct_distance > 0
                    AND p_trip_rec.total_direct_distance > p_carrier_pref.cm_free_dh_mileage
                  )
                 )
            AND p_trip_rec.continuous_move = 'Y'
            AND p_carrier_pref.cm_rate_variant = 'RATE') THEN

         l_curr_line_idx := l_curr_line_idx + 1;

         l_req_line_info_rec.line_index := l_curr_line_idx;
         l_req_line_info_rec.line_type  := G_CONT_DH_BASE_LINE;
         l_req_line_info_rec.stop_index := null;
         IF (p_trip_rec.distance_method = 'DIRECT_ROUTE') THEN
            l_req_line_info_rec.line_qty   :=
	       p_trip_rec.total_direct_distance - p_carrier_pref.cm_free_dh_mileage;
         ELSE
            l_req_line_info_rec.line_qty   :=
	       p_trip_rec.unloaded_distance - p_carrier_pref.cm_free_dh_mileage;
         END IF;

         l_req_line_info_rec.line_uom   := p_carrier_pref.distance_uom;
         l_req_line_info_rec.currency   := p_carrier_pref.currency;
         l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
         l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
         l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

         create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;
       ELSE
        -- bug 3610889
            -- Under following condn we assume success w/o creating engine line
            IF ( p_trip_rec.unloaded_distance > 0
	    AND ( (p_trip_rec.unloaded_distance <= p_carrier_pref.cm_free_dh_mileage
                    AND p_trip_rec.distance_method <> 'DIRECT_ROUTE'
                  )
                  OR
                  (p_trip_rec.distance_method='DIRECT_ROUTE'
                    AND p_trip_rec.total_direct_distance > 0
                    AND p_trip_rec.total_direct_distance <= p_carrier_pref.cm_free_dh_mileage
                  )
                 )
            AND p_trip_rec.continuous_move = 'Y'
            AND p_carrier_pref.cm_rate_variant = 'RATE')
           THEN
                x_implicit_non_dummy_cnt := x_implicit_non_dummy_cnt + 1;
           END IF;
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                'x_implicit_non_dummy_cnt = '||x_implicit_non_dummy_cnt);

       END IF;

       -- if trip is loaded. We can also check for weight,volume,piece,pallet.
       IF (p_trip_rec.loaded_distance > 0) THEN

         IF (p_carrier_pref.unit_basis = 'WEIGHT') THEN
           l_req_line_info_rec.line_qty   := p_trip_rec.total_weight;
           l_req_line_info_rec.line_uom   := p_carrier_pref.weight_uom;
         ELSIF (p_carrier_pref.unit_basis = 'VOLUME') THEN
           l_req_line_info_rec.line_qty   := p_trip_rec.total_volume;
           l_req_line_info_rec.line_uom   := p_carrier_pref.weight_uom;
         ELSIF (p_carrier_pref.unit_basis = 'CONTAINER') THEN
           l_req_line_info_rec.line_qty   := p_trip_rec.number_of_containers;
           l_req_line_info_rec.line_uom   := l_uom_ea;
         ELSIF (p_carrier_pref.unit_basis = 'PALLET') THEN
           l_req_line_info_rec.line_qty   := p_trip_rec.number_of_pallets;
           l_req_line_info_rec.line_uom   := l_uom_ea;
         END IF;

	 IF l_req_line_info_rec.line_qty > 0 THEN

         l_curr_line_idx := l_curr_line_idx + 1;

         l_req_line_info_rec.line_index := l_curr_line_idx;
         l_req_line_info_rec.line_type  := G_UNITS_BASE_LINE;
         l_req_line_info_rec.stop_index := null;

         l_req_line_info_rec.currency   := p_carrier_pref.currency;
         l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
         l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
         l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

         create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

	 END IF;
       END IF;

       -- Time base rate line

       IF (p_trip_rec.time > 0) THEN
         l_curr_line_idx := l_curr_line_idx + 1;

         l_req_line_info_rec.line_index := l_curr_line_idx;
         l_req_line_info_rec.line_type  := G_TIME_BASE_LINE;
         l_req_line_info_rec.stop_index := null;

         l_req_line_info_rec.line_qty   := p_trip_rec.time;
         l_req_line_info_rec.line_uom   := p_carrier_pref.time_uom;

         l_req_line_info_rec.currency   := p_carrier_pref.currency;
         l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
         l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
         l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

         create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;
       END IF;

       -- Flat base rate line

       l_curr_line_idx := l_curr_line_idx + 1;

       l_req_line_info_rec.line_index := l_curr_line_idx;
       l_req_line_info_rec.line_type  := G_FLAT_BASE_LINE;
       l_req_line_info_rec.stop_index := null;

       l_req_line_info_rec.line_qty   := 1;
       l_req_line_info_rec.line_uom   := l_uom_ea;

       l_req_line_info_rec.currency   := p_carrier_pref.currency;
       l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
       l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
       l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

         create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       -- LOAD CHARGE LINE

       l_curr_line_idx := l_curr_line_idx + 1;

       l_req_line_info_rec.line_index := l_curr_line_idx;
       l_req_line_info_rec.line_type  := G_LOAD_CHARGE_LINE;
       l_req_line_info_rec.stop_index := null;

       l_req_line_info_rec.line_qty   := 1;
       l_req_line_info_rec.line_uom   := l_uom_ea;

       l_req_line_info_rec.currency   := p_carrier_pref.currency;
       l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
       l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
       l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

       g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

       create_input_line (
                   p_req_line_rec      => l_req_line_info_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       -- create qp control record
       create_control_rec ( x_return_status => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_ctrl_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       -- STOP CHARGE LINES
       -- 1 line per stop

       IF (p_stop_tab.COUNT >0) THEN
       -- i := p_stop_tab.FIRST;
       i := p_trip_rec.stop_reference;
       LOOP

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'stop_ref='||p_trip_rec.stop_reference);
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'i='||i);
         --IF ( (p_stop_tab(i).trip_id <> p_trip_rec.trip_id)
         IF (i >= (p_trip_rec.stop_reference + p_trip_rec.number_of_stops ) )
         THEN
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Exit stop loop');
            EXIT;
         END IF;

         l_curr_line_idx := l_curr_line_idx + 1;

         l_req_line_info_rec.line_index := l_curr_line_idx;
         l_req_line_info_rec.line_type  := G_STOP_CHARGE_LINE;
         l_req_line_info_rec.stop_index := i; -- index into stop table

         l_req_line_info_rec.line_qty   := 1;
         l_req_line_info_rec.line_uom   := l_uom_ea;

         l_req_line_info_rec.currency   := p_carrier_pref.currency;
         l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
         l_req_line_info_rec.pricelist_id  := p_trip_rec.price_list_id;
         l_req_line_info_rec.carrier_id := p_trip_rec.carrier_id;

         g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);
         create_input_line (
                     p_req_line_rec      => l_req_line_info_rec,
                     p_trip_rec          => p_trip_rec,
                     p_stop_tab          => p_stop_tab,
                     p_carrier_pref      => p_carrier_pref,
                     x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         EXIT WHEN i = p_stop_tab.LAST ;
         i := p_stop_tab.NEXT(i);

       END LOOP;
       END IF; --stop_tab.count

       -- FACILITY CHARGE LINES

       IF (p_stop_tab.COUNT >0) THEN
       i := p_trip_rec.stop_reference;
       LOOP

         IF (i >= (p_trip_rec.stop_reference + p_trip_rec.number_of_stops ) )
         THEN
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Exit stop loop');
            EXIT;
         END IF;

         IF (p_stop_tab(i).fac_pricelist_id IS NOT NULL
             AND p_stop_tab(i).fac_pricelist_id > 0
	     AND p_stop_tab(i).stop_type <> 'NA'
	     --AND p_stop_tab(i).loading_protocol <> 'CARRIER'
             AND p_stop_tab(i).fac_currency IS NOT NULL ) THEN

            l_curr_line_idx := l_curr_line_idx + 1;

            l_req_line_info_rec.line_index := l_curr_line_idx;
            l_req_line_info_rec.line_type  := G_FACILITY_CHARGE_LINE;
            l_req_line_info_rec.stop_index := i;

            l_req_line_info_rec.line_qty   := 1;
            l_req_line_info_rec.line_uom   := l_uom_ea;

            l_req_line_info_rec.currency   := p_stop_tab(i).fac_currency;
            l_req_line_info_rec.lane_id    := p_trip_rec.lane_id;
            l_req_line_info_rec.pricelist_id  := p_stop_tab(i).fac_pricelist_id;
            l_req_line_info_rec.carrier_id := NULL;

            g_req_line_info_tab(l_curr_line_idx) := l_req_line_info_rec;
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                        'l_curr_line_idx = '||l_curr_line_idx);

            create_input_line (
                     p_req_line_rec      => l_req_line_info_rec,
                     p_trip_rec          => p_trip_rec,
                     p_stop_tab          => p_stop_tab,
                     p_carrier_pref      => p_carrier_pref,
                     x_return_status     => l_return_status);

            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                  FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
                  fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_inp_line_failed');
                  raise FND_API.G_EXC_ERROR;
               END IF;
            END IF;

         END IF;

         EXIT WHEN i = p_stop_tab.LAST;
         i := p_stop_tab.NEXT(i);

       END LOOP;
       END IF; --stop_tab.count

       -- create qp control record
       -- create_control_rec ( x_return_status => l_return_status);


       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END create_engine_inputs;


  --
  -- procedure : create_input_line
  --     Hides details of using fte_qp_engine.create_line_record
  --

  PROCEDURE create_input_line (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_return_status     OUT NOCOPY VARCHAR2)

  IS

     l_pricing_control_rec           fte_freight_pricing.pricing_control_input_rec_type;
     l_pricing_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
     l_return_status                 VARCHAR2(1);
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'create_input_line';

  BEGIN

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);

       l_pricing_control_rec.pricing_event_num := fte_freight_pricing.G_LINE_EVENT_NUM;
       l_pricing_control_rec.currency_code     := p_req_line_rec.currency;
       l_pricing_control_rec.lane_id           := p_req_line_rec.lane_id;
       l_pricing_control_rec.price_list_id     := p_req_line_rec.pricelist_id;
       l_pricing_control_rec.party_id          := p_req_line_rec.carrier_id;

       l_pricing_engine_input_rec.input_index   := p_req_line_rec.line_index;
       l_pricing_engine_input_rec.line_quantity := p_req_line_rec.line_qty;
       l_pricing_engine_input_rec.line_uom      := p_req_line_rec.line_uom;

       fte_qp_engine.create_line_record (
                p_pricing_control_rec      => l_pricing_control_rec,
                p_pricing_engine_input_rec => l_pricing_engine_input_rec,
                x_return_status            => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_line_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       create_line_attributes (
                   p_req_line_rec      => p_req_line_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_line_attr_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       create_line_qualifiers (
                   p_req_line_rec      => p_req_line_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_return_status     => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_line_qual_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END create_input_line;

  --
  -- procedure : create_line_attributes
  --     Hides details of creating attributes for a given input line
  --

  PROCEDURE create_line_attributes (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_return_status     OUT NOCOPY VARCHAR2)
  IS
      l_pricing_attr_rec  fte_freight_pricing.pricing_attribute_rec_type;
      l_pricing_attr_tab  fte_freight_pricing.pricing_attribute_tab_type;
      l_return_status     VARCHAR2(1);

      l_attr_idx          NUMBER :=0;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'create_line_attributes';
  BEGIN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);


     -- TODO : check if source value is not null / valid before creating the attribute

      IF (p_req_line_rec.line_type = G_LOADED_DIST_BASE_LINE) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';
          l_pricing_attr_rec.attribute_value := 'DISTANCE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      ELSIF (p_req_line_rec.line_type = G_UNLOADED_DIST_BASE_LINE) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';
          l_pricing_attr_rec.attribute_value := 'DISTANCE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_DISTANCE_TYPE';
          l_pricing_attr_rec.attribute_value := 'UNLOADED';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      ELSIF (p_req_line_rec.line_type = G_CONT_DIST_BASE_LINE) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';
          l_pricing_attr_rec.attribute_value := 'DISTANCE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_DISTANCE_TYPE';
          l_pricing_attr_rec.attribute_value := 'CONTINUOUS_MOVE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      ELSIF (p_req_line_rec.line_type = G_CONT_DH_BASE_LINE) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';
          l_pricing_attr_rec.attribute_value := 'DISTANCE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_DISTANCE_TYPE';
          l_pricing_attr_rec.attribute_value := 'CONTINUOUS_MOVE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          IF (p_trip_rec.dead_head='Y') THEN

            l_attr_idx := l_attr_idx + 1;
            l_pricing_attr_rec.attribute_index := l_attr_idx;
            l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
            l_pricing_attr_rec.attribute_name  := 'TL_DEADHEAD_RT_VAR';
            l_pricing_attr_rec.attribute_value := 'Y';

            l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          END IF;

      ELSIF (p_req_line_rec.line_type = G_UNITS_BASE_LINE ) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';

          IF (p_carrier_pref.unit_basis = 'WEIGHT') THEN
            l_pricing_attr_rec.attribute_value := 'WEIGHT';
          ELSIF (p_carrier_pref.unit_basis = 'VOLUME') THEN
            l_pricing_attr_rec.attribute_value := 'VOLUME';
          ELSIF (p_carrier_pref.unit_basis = 'CONTAINER') THEN
            l_pricing_attr_rec.attribute_value := 'CONTAINER';
          ELSIF (p_carrier_pref.unit_basis = 'PALLET') THEN
            l_pricing_attr_rec.attribute_value := 'PALLET';
          END IF;

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      ELSIF (p_req_line_rec.line_type = G_TIME_BASE_LINE ) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';

          l_pricing_attr_rec.attribute_value := 'TIME';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      ELSIF (p_req_line_rec.line_type = G_FLAT_BASE_LINE ) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_BASIS';

          l_pricing_attr_rec.attribute_value := 'FLAT';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'BASE_RATE';

          l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      ELSE

               -- create_charge_line_attributes (IN OUT l_pricing_attr_tab)
          create_charge_line_attributes (
                   p_req_line_rec      => p_req_line_rec,
                   p_trip_rec          => p_trip_rec,
                   p_stop_tab          => p_stop_tab,
                   p_carrier_pref      => p_carrier_pref,
                   x_pricing_attr_tab  => l_pricing_attr_tab,
                   x_return_status     => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_chrg_line_attr_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

          l_attr_idx := l_pricing_attr_tab.COUNT;

      END IF;

      l_attr_idx := l_attr_idx + 1;
      l_pricing_attr_rec.attribute_index := l_attr_idx;
      l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
      l_pricing_attr_rec.attribute_name  := 'SERVICE_TYPE';
      l_pricing_attr_rec.attribute_value := p_trip_rec.service_type;

      l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      l_attr_idx := l_attr_idx + 1;
      l_pricing_attr_rec.attribute_index := l_attr_idx;
      l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
      l_pricing_attr_rec.attribute_name  := 'VEHICLE';
      l_pricing_attr_rec.attribute_value := p_trip_rec.vehicle_type;

      l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

      IF ( p_trip_rec.continuous_move = 'Y'
           AND p_carrier_pref.cm_rate_variant = 'DISCOUNT') THEN

        l_attr_idx := l_attr_idx + 1;
        l_pricing_attr_rec.attribute_index := l_attr_idx;
        l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
        l_pricing_attr_rec.attribute_name  := 'TL_CM_DISCOUNT_FLG';
        l_pricing_attr_rec.attribute_value := 'Y';

        l_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
      END IF;

      fte_qp_engine.prepare_qp_line_attributes (
              p_event_num               => fte_qp_engine.G_LINE_EVENT_NUM,
              p_input_index             => p_req_line_rec.line_index,
              p_attr_rows               => l_pricing_attr_tab,
              x_return_status           => l_return_status );

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_prep_qp_line_attr_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END create_line_attributes;

  --
  -- procedure : create_line_attributes
  --     Contains details of creating attributes for a given charge input line
  --     Returns table of attributes. Does not actually call fte_qp_engine.
  --

  PROCEDURE create_charge_line_attributes (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_pricing_attr_tab  IN OUT NOCOPY fte_freight_pricing.pricing_attribute_tab_type,
                   x_return_status     OUT NOCOPY VARCHAR2)
  IS
      l_pricing_attr_rec  fte_freight_pricing.pricing_attribute_rec_type;
      l_return_status     VARCHAR2(1);
      l_attr_idx          NUMBER :=0;
      l_out_of_rt_dist    NUMBER :=0;
      l_fac_handling_wt   NUMBER :=0;
      l_fac_handling_vol  NUMBER :=0;
      l_stop_rec          FTE_TL_CACHE.tl_trip_stop_input_rec_type;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'create_charge_line_attributes';

  BEGIN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);

     -- note : validate attribute source values before using them

      l_attr_idx := x_pricing_attr_tab.COUNT;

     -- TODO : check if source value is not null / valid before creating the attribute

      IF (p_req_line_rec.line_type = G_LOAD_CHARGE_LINE) THEN

          l_attr_idx := l_attr_idx + 1;
          l_pricing_attr_rec.attribute_index := l_attr_idx;
          l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
          l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
          l_pricing_attr_rec.attribute_value := 'LOAD_CHARGE';

          x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

        -- For Stop Off Charges
          IF (p_trip_rec.number_of_stops IS NOT NULL
              AND p_trip_rec.number_of_stops >= 2 ) THEN

            l_attr_idx := l_attr_idx + 1;
            l_pricing_attr_rec.attribute_index := l_attr_idx;
            l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
            l_pricing_attr_rec.attribute_name  := 'TL_NUM_STOPS';
            -- bug 3394807 : TP expects that the first and last stops of the trip not be
            -- counted towards stop off charge. Free stops and other breaks apply only
            -- to intermediate stops
            -- l_pricing_attr_rec.attribute_value := to_char(p_trip_rec.number_of_stops);
            l_pricing_attr_rec.attribute_value := to_char(p_trip_rec.number_of_stops-2);
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'num stops for stop off charge='||to_char(p_trip_rec.number_of_stops-2));

            x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

          END IF;


          -- VVP:09/18/03
          -- Per Hema, out of route charges need to be calculated
          -- regardless of distance calc method, eventhough typicaly
          -- this charge is not needed for Full Route method
          -- Also, if max_out_of_route is NULL, this means that no charge to be applied
          -- - this is not the same as max_out_of_route=0

          -- For Out of Route Charges
          -- IF ( p_trip_rec.distance_method = 'DIRECT_ROUTE'
          --    AND p_trip_rec.total_direct_distance IS NOT NULL
          --    AND p_trip_rec.total_direct_distance > 0 ) THEN

          IF ( p_trip_rec.total_direct_distance IS NOT NULL
                 AND p_trip_rec.total_direct_distance > 0
                 AND p_carrier_pref.max_out_of_route IS NOT NULL) THEN

            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'total_direct_distance='||p_trip_rec.total_direct_distance);
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'total_trip_distance='||p_trip_rec.total_trip_distance);
            fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'max_out_of_route='||p_carrier_pref.max_out_of_route);

            l_out_of_rt_dist := p_trip_rec.total_trip_distance
                                - ( p_trip_rec.total_direct_distance
                                    * (1 + p_carrier_pref.max_out_of_route/100) );
            IF (l_out_of_rt_dist > 0) THEN

            l_attr_idx := l_attr_idx + 1;
            l_pricing_attr_rec.attribute_index := l_attr_idx;
            l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
            l_pricing_attr_rec.attribute_name  := 'TL_CHARGED_OUT_RT_DISTANCE';
            l_pricing_attr_rec.attribute_value := to_char(l_out_of_rt_dist);

            x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

            END IF;

          END IF;

        -- For Document Charges
           -- no special attributes needed
        -- For Handling Charges
           -- send both wt and volume

	 --Apply handling charge only if the trip is NOT a CM dead head
	 --bug 3635944
          IF (NOT (p_trip_rec.dead_head='Y' AND p_trip_rec.continuous_move='Y'))
          THEN

		  IF (p_carrier_pref.unit_basis = 'WEIGHT') THEN

		    l_attr_idx := l_attr_idx + 1;
		    l_pricing_attr_rec.attribute_index := l_attr_idx;
		    l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
		    l_pricing_attr_rec.attribute_name  := 'TL_HANDLING_WT';
		    l_pricing_attr_rec.attribute_value := to_char(nvl(p_trip_rec.total_weight,0));

		    x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

		  ELSIF (p_carrier_pref.unit_basis = 'VOLUME') THEN

		    l_attr_idx := l_attr_idx + 1;
		    l_pricing_attr_rec.attribute_index := l_attr_idx;
		    l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
		    l_pricing_attr_rec.attribute_name  := 'TL_HANDLING_VOL';
		    l_pricing_attr_rec.attribute_value := to_char(nvl(p_trip_rec.total_volume,0));

		    x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

		  END IF;

		    l_attr_idx := l_attr_idx + 1;
		    l_pricing_attr_rec.attribute_index := l_attr_idx;
		    l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
		    l_pricing_attr_rec.attribute_name  := 'TL_HANDLING_ACT';
		    l_pricing_attr_rec.attribute_value := 'Y';



		    x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
           END IF;

      ELSIF (p_req_line_rec.line_type = G_STOP_CHARGE_LINE) THEN

          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                     'line_index = '||p_req_line_rec.line_index);
          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                     'stop_index = '||p_req_line_rec.stop_index);
          IF ( p_stop_tab.COUNT > 0 AND p_stop_tab.EXISTS(p_req_line_rec.stop_index) ) THEN
            l_stop_rec := p_stop_tab(p_req_line_rec.stop_index);

          fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                  'l_stop_rec.stop_id = '||l_stop_rec.stop_id);

            l_attr_idx := l_attr_idx + 1;
            l_pricing_attr_rec.attribute_index := l_attr_idx;
            l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
            l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
            l_pricing_attr_rec.attribute_value := 'STOP_CHARGE';

            x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

            IF (l_stop_rec.loading_protocol = 'CARRIER'
                OR l_stop_rec.loading_protocol = 'JOINT')
	       AND (l_stop_rec.stop_type = 'PU'
		    OR l_stop_rec.stop_type = 'DO'
		    OR l_stop_rec.stop_type = 'PD') THEN

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'LOADING_PROTOCOL';
              l_pricing_attr_rec.attribute_value := l_stop_rec.loading_protocol;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     IF (l_stop_rec.stop_type = 'PU' or l_stop_rec.stop_type = 'PD') THEN

              -- For loading and assisted loading charges

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              IF (p_carrier_pref.unit_basis = 'WEIGHT') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_PICKUP_WT';
                l_pricing_attr_rec.attribute_value := l_stop_rec.pickup_weight;
              ELSIF (p_carrier_pref.unit_basis = 'VOLUME') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_PICKUP_VOL';
                l_pricing_attr_rec.attribute_value := l_stop_rec.pickup_volume;
              ELSIF (p_carrier_pref.unit_basis = 'CONTAINER') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_PICKUP_CONTAINER';
                l_pricing_attr_rec.attribute_value := l_stop_rec.pickup_containers;
              ELSIF (p_carrier_pref.unit_basis = 'PALLET') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_PICKUP_PALLET';
                l_pricing_attr_rec.attribute_value := l_stop_rec.pickup_pallets;
              END IF;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_LOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'Y';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     ELSE

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_LOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'N';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     END IF;

	     IF (l_stop_rec.stop_type = 'DO' or l_stop_rec.stop_type = 'PD') THEN

              -- For unloading and assisted unloading charges

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              IF (p_carrier_pref.unit_basis = 'WEIGHT') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_DROPOFF_WT';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_weight;
              ELSIF (p_carrier_pref.unit_basis = 'VOLUME') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_DROPOFF_VOL';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_volume;
              ELSIF (p_carrier_pref.unit_basis = 'CONTAINER') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_DROPOFF_CONTAINER';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_containers;
              ELSIF (p_carrier_pref.unit_basis = 'PALLET') THEN
                l_pricing_attr_rec.attribute_name  := 'TL_DROPOFF_PALLET';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_pallets;
              END IF;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_UNLOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'Y';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     ELSE

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_UNLOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'N';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     END IF;

            END IF; -- loading protocol

            -- For weekday layover charges
            IF (l_stop_rec.weekday_layovers > 0) THEN

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_NUM_WEEKDAY_LAYOVERS';
              IF (l_stop_rec.weekday_layovers > 0) THEN
                l_pricing_attr_rec.attribute_value := l_stop_rec.weekday_layovers;
              ELSE
                l_pricing_attr_rec.attribute_value := '0';
              END IF;
              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

            END IF;

            -- For weekend layover charges
            IF (l_stop_rec.weekend_layovers > 0) THEN

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_WEEKEND_LAYOVER_MILEAGE';
              l_pricing_attr_rec.attribute_value := l_stop_rec.distance_to_next_stop;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

              --l_attr_idx := l_attr_idx + 1;
              --l_pricing_attr_rec.attribute_index := l_attr_idx;
              --l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              --l_pricing_attr_rec.attribute_name  := 'TL_NUM_WEEKEND_LAYOVERS';
              --l_pricing_attr_rec.attribute_value := l_stop_rec.weekend_layovers;

              --x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
            END IF;

            IF (l_stop_rec.stop_region IS NOT NULL) THEN

	     IF l_stop_rec.stop_type = 'PU' or l_stop_rec.stop_type = 'PD' THEN
              -- For origin charges
              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_ORIGIN_ZONE';
              l_pricing_attr_rec.attribute_value := l_stop_rec.stop_region;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
	     END IF;

	     IF l_stop_rec.stop_type = 'DO' or l_stop_rec.stop_type = 'PD' THEN
              -- For destination charges
              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_DESTINATION_ZONE';
              l_pricing_attr_rec.attribute_value := l_stop_rec.stop_region;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
	     END IF;

            END IF;

          END IF; -- p_stop_tab.count

      ELSIF (p_req_line_rec.line_type = G_FACILITY_CHARGE_LINE) THEN

          IF (p_stop_tab.COUNT > 0 AND p_stop_tab.EXISTS(p_req_line_rec.stop_index) ) THEN
            l_stop_rec := p_stop_tab(p_req_line_rec.stop_index);

            l_attr_idx := l_attr_idx + 1;
            l_pricing_attr_rec.attribute_index := l_attr_idx;
            l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
            l_pricing_attr_rec.attribute_name  := 'TL_RATE_TYPE';
            l_pricing_attr_rec.attribute_value := 'FACILITY_CHARGE';

            x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

            --IF (l_stop_rec.loading_protocol = 'FACILITY'
              --  OR l_stop_rec.loading_protocol = 'JOINT')
	      -- AND (l_stop_rec.stop_type = 'PU'
		--    OR l_stop_rec.stop_type = 'DO'
		--    OR l_stop_rec.stop_type = 'PD') THEN

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'LOADING_PROTOCOL';
              l_pricing_attr_rec.attribute_value := l_stop_rec.loading_protocol;

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     IF (l_stop_rec.stop_type = 'PU' or l_stop_rec.stop_type = 'PD') THEN

              -- For loading and assisted loading charges

              IF (l_stop_rec.fac_charge_basis = 'WEIGHT') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_PICKUP_WT';
                l_pricing_attr_rec.attribute_value := l_stop_rec.fac_pickup_weight;
		l_fac_handling_wt := l_stop_rec.fac_pickup_weight;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'VOLUME') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_PICKUP_VOL';
                l_pricing_attr_rec.attribute_value := l_stop_rec.fac_pickup_volume;
		l_fac_handling_vol := l_stop_rec.fac_pickup_volume;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'CONTAINER') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_PICKUP_CONTAINER';
                l_pricing_attr_rec.attribute_value := l_stop_rec.pickup_containers;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'PALLET') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_PICKUP_PALLET';
                l_pricing_attr_rec.attribute_value := l_stop_rec.pickup_pallets;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              END IF;

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_LOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'Y';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     ELSE

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_LOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'N';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     END IF;

	     IF (l_stop_rec.stop_type = 'DO' or l_stop_rec.stop_type = 'PD') THEN
              -- For unloading and assisted unloading charges

              IF (l_stop_rec.fac_charge_basis = 'WEIGHT') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_DROPOFF_WT';
                l_pricing_attr_rec.attribute_value := l_stop_rec.fac_dropoff_weight;
		--IF l_fac_handling_wt <= 0 THEN
  		--  l_fac_handling_wt := l_stop_rec.fac_dropoff_weight;
  		--Facility handling is based on sum of pickup+dropoff
  		--END IF;
  		--4045314
  		l_fac_handling_wt := l_fac_handling_wt+l_stop_rec.fac_dropoff_weight;

                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'VOLUME') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_DROPOFF_VOL';
                l_pricing_attr_rec.attribute_value := l_stop_rec.fac_dropoff_volume;
		--IF l_fac_handling_vol <= 0 THEN
  		--  l_fac_handling_vol := l_stop_rec.fac_dropoff_volume;
		--END IF;
		--4045314
		l_fac_handling_vol := l_fac_handling_vol+l_stop_rec.fac_dropoff_volume;

                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'CONTAINER') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_DROPOFF_CONTAINER';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_containers;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'PALLET') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_DROPOFF_PALLET';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_pallets;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              END IF;

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_UNLOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'Y';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     ELSE

              l_attr_idx := l_attr_idx + 1;
              l_pricing_attr_rec.attribute_index := l_attr_idx;
              l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
              l_pricing_attr_rec.attribute_name  := 'TL_STOP_UNLOADING_ACT';
              l_pricing_attr_rec.attribute_value := 'N';

              x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

	     END IF;

              -- For handling charges
              --TODO : which weights (pickup/dropoff) are used for facility handling charges?

	      --This has now been clarified we take the sum of pickup + dropoff 4045314

              IF (l_stop_rec.fac_charge_basis = 'WEIGHT') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_HANDLING_WT';
                l_pricing_attr_rec.attribute_value := l_fac_handling_wt;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'VOLUME') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_HANDLING_VOL';
                l_pricing_attr_rec.attribute_value := l_fac_handling_vol;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'CONTAINER') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_HANDLING_CONTAINER';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_containers;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              ELSIF (l_stop_rec.fac_charge_basis = 'PALLET') THEN
                l_pricing_attr_rec.attribute_name  := 'FAC_HANDLING_PALLET';
                l_pricing_attr_rec.attribute_value := l_stop_rec.dropoff_pallets;
                l_attr_idx := l_attr_idx + 1;
                l_pricing_attr_rec.attribute_index := l_attr_idx;
                l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
                x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;
              END IF;

            l_attr_idx := l_attr_idx + 1;
            l_pricing_attr_rec.attribute_index := l_attr_idx;
            l_pricing_attr_rec.input_index     := p_req_line_rec.line_index;
            l_pricing_attr_rec.attribute_name  := 'TL_HANDLING_ACT';
            l_pricing_attr_rec.attribute_value := 'Y';

            x_pricing_attr_tab(l_attr_idx) := l_pricing_attr_rec;

            --END IF; -- loading protocol

          END IF; -- p_stop_tab.count

      END IF;

       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END create_charge_line_attributes;

  --
  -- procedure : create_line_qualifiers
  --     Hides details of creating qualifiers for a given input line
  --

  PROCEDURE create_line_qualifiers (
                   p_req_line_rec      IN req_line_info_rec_type,
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   x_return_status     OUT NOCOPY VARCHAR2)
  IS
      l_qual_rec       fte_qp_engine.qualifier_rec_type;
      l_return_status  VARCHAR2(1);
      l_qual_idx       NUMBER := 0;
      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'create_line_qualifiers';
  BEGIN

       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);


      IF (p_req_line_rec.line_type <> G_FACILITY_CHARGE_LINE ) THEN

        -- carrier related qualifiers

        l_qual_idx := l_qual_idx + 1;

        l_qual_rec.qualifier_index      := l_qual_idx;
        l_qual_rec.input_index          := p_req_line_rec.line_index;
        l_qual_rec.qualifier_name       :='PRICELIST';
        l_qual_rec.qualifier_value      := to_char(p_req_line_rec.pricelist_id);

        fte_qp_engine.create_qual_record (p_event_num     => fte_qp_engine.G_LINE_EVENT_NUM,
                                          p_qual_rec      => l_qual_rec,
                                          x_return_status => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After  create_qual_record ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_qual_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

        l_qual_idx := l_qual_idx + 1;

        l_qual_rec.qualifier_index      := l_qual_idx;
        l_qual_rec.input_index          := p_req_line_rec.line_index;
        l_qual_rec.qualifier_name       :='SUPPLIER';
        l_qual_rec.qualifier_value      := to_char(p_req_line_rec.carrier_id);

        fte_qp_engine.create_qual_record (p_event_num     => fte_qp_engine.G_LINE_EVENT_NUM,
                                          p_qual_rec      => l_qual_rec,
                                          x_return_status => l_return_status);

        l_qual_idx := l_qual_idx + 1;

        l_qual_rec.qualifier_index      := l_qual_idx;
        l_qual_rec.input_index          := p_req_line_rec.line_index;
        l_qual_rec.qualifier_name       :='MODE_OF_TRANSPORT';
        l_qual_rec.qualifier_value      := p_trip_rec.mode_of_transport;

        fte_qp_engine.create_qual_record (p_event_num     => fte_qp_engine.G_LINE_EVENT_NUM,
                                          p_qual_rec      => l_qual_rec,
                                          x_return_status => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After  create_qual_record ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_qual_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

        l_qual_idx := l_qual_idx + 1;

        l_qual_rec.qualifier_index      := l_qual_idx;
        l_qual_rec.input_index          := p_req_line_rec.line_index;
        l_qual_rec.qualifier_name       :='SERVICE_TYPE';
        l_qual_rec.qualifier_value      := p_trip_rec.service_type;

        fte_qp_engine.create_qual_record (p_event_num     => fte_qp_engine.G_LINE_EVENT_NUM,
                                          p_qual_rec      => l_qual_rec,
                                          x_return_status => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After  create_qual_record ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_qual_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

      ELSE

        -- Facility price list

        l_qual_idx := l_qual_idx + 1;

        l_qual_rec.qualifier_index      := l_qual_idx;
        l_qual_rec.input_index          := p_req_line_rec.line_index;
        l_qual_rec.qualifier_name       :='PRICELIST';
        l_qual_rec.qualifier_value      := to_char(p_req_line_rec.pricelist_id);

        fte_qp_engine.create_qual_record (p_event_num     => fte_qp_engine.G_LINE_EVENT_NUM,
                                          p_qual_rec      => l_qual_rec,
                                          x_return_status => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After  create_qual_record ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_qual_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

     END IF;

     fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);


  END create_line_qualifiers;

  PROCEDURE create_control_rec ( x_return_status     OUT NOCOPY VARCHAR2)
  IS
     l_return_status VARCHAR2(1);
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'create_control_rec';
  BEGIN
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
      fte_freight_pricing_util.reset_dbg_vars;
      fte_freight_pricing_util.set_method(l_log_level,l_method_name);

      fte_qp_engine.create_control_record (p_event_num      => fte_qp_engine.G_LINE_EVENT_NUM,
                                           x_return_status  => l_return_status);

         IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
            IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
               FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After  create_qual_record ');
               fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_control_rec_failed');
               raise FND_API.G_EXC_ERROR;
            END IF;
         END IF;

      x_return_status := l_return_status;

       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END create_control_rec;

  PROCEDURE init_stop_rec (x_stop_rec IN OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_rec_type )
  IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'init_stop_rec';
  BEGIN
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);
       x_stop_rec.stop_id := 0;
       x_stop_rec.trip_id := 0;
       x_stop_rec.weekday_layover_chrg := 0;
       x_stop_rec.weekend_layover_chrg := 0;
       x_stop_rec.loading_chrg := 0;
       x_stop_rec.loading_chrg_basis := null;
       x_stop_rec.ast_loading_chrg := 0;
       x_stop_rec.ast_loading_chrg_basis := null;
       x_stop_rec.unloading_chrg := 0;
       x_stop_rec.unloading_chrg_basis := 0;
       x_stop_rec.ast_unloading_chrg := 0;
       x_stop_rec.ast_unloading_chrg_basis := null;
       x_stop_rec.origin_surchrg := 0;
       x_stop_rec.destination_surchrg := 0;
       x_stop_rec.fac_loading_chrg := 0;
       x_stop_rec.fac_loading_chrg_basis := null;
       x_stop_rec.fac_ast_loading_chrg := 0;
       x_stop_rec.fac_ast_loading_chrg_basis := null;
       x_stop_rec.fac_unloading_chrg := 0;
       x_stop_rec.fac_unloading_chrg_basis := null;
       x_stop_rec.fac_ast_unloading_chrg := 0;
       x_stop_rec.fac_ast_unloading_chrg_basis := null;
       x_stop_rec.fac_handling_chrg := 0;
       x_stop_rec.fac_handling_chrg_basis := null;
       x_stop_rec.fac_currency := null;
       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN OTHERS THEN
        --x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END init_stop_rec;

  --
  -- Procedure : retrieve_qp_output
  --     Reads the qp output lines and details, extracts various base rates and charges
  --     and plugs in the values into the output data structures.These data structures
  --     can be utilized by cost allocation.
  --

  PROCEDURE retrieve_qp_output (
                   p_trip_rec          IN  FTE_TL_CACHE.TL_trip_data_input_rec_type,
                   p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
                   p_carrier_pref      IN  FTE_TL_CACHE.TL_carrier_pref_rec_type,
                   p_qp_output_line_rows    IN QP_PREQ_GRP.LINE_TBL_TYPE,
                   p_qp_output_detail_rows  IN QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
                   x_trip_charges_rec  OUT NOCOPY FTE_TL_CACHE.TL_trip_output_rec_type,
                   x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
                   x_return_status     OUT NOCOPY VARCHAR2)
  IS
     l_return_status     VARCHAR2(1);
     i                   NUMBER := 0;
     line_idx            NUMBER := 0;

     l_loaded_dist_price          NUMBER := 0;
     l_unit_loaded_dist_price     NUMBER := 0;
     l_unloaded_dist_price        NUMBER := 0;
     l_unit_unloaded_dist_price   NUMBER := 0;
     l_cm_dist_price              NUMBER := 0;
     l_unit_cm_dist_price         NUMBER := 0;
     l_unit_base_price            NUMBER := 0;
     l_unit_unit_base_price       NUMBER := 0;
     l_time_price                 NUMBER := 0;
     l_unit_time_price                 NUMBER := 0;
     l_flat_price                 NUMBER := 0;
     l_num_of_weekend_layover     NUMBER;
     l_stop_index                 NUMBER := 0;

     l_qp_out_det_rec             QP_PREQ_GRP.LINE_DETAIL_REC_TYPE;
     l_stop_rec                   FTE_TL_CACHE.TL_trip_stop_output_rec_type;
     l_stop_id                    NUMBER;
     l_req_line_info_rec          req_line_info_rec_type;
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'retrieve_qp_output';

  BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);

     -- Loop through the line table
        -- look for base rates returned (incl. continuous move rates if applicable)
     -- Loop through the detail table
        -- look for minimum charges on base prices (how will we process these?)
        -- look for accessorial charges
        -- look for continuous move discount **
     -- Apply minimum charges to base prices ?
     -- Apply continuous move discount if applicable (or will cost allocation deal with it?)
     -- uom conversion?

     ------------- BASE PRICES -----------------------------------

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
           'g_req_line_info_tab.COUNT = '||g_req_line_info_tab.COUNT);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
           'p_qp_output_line_rows.COUNT = '||p_qp_output_line_rows.COUNT);

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'Now looping on p_qp_output_line_rows ');

     i := p_qp_output_line_rows.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP
         -- get line index
         -- get req info for line index
          -- get base rate (if applicable)
         -- loop thru line details
            -- depending upon the type (purpose) of the line, filter out unwanted details
            -- analyze the charge sub type code, and extract the charge.

            line_idx := p_qp_output_line_rows(i).line_index;
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'line_idx = '||line_idx);

            --
            -- NOTE :   We use adjusted_unit_price instead on unit_price on most base rates
            --          to account for minimum charges that get applied. If there are no
            --          minimum charges, then unit_price will be equal to adjusted_unit_price.
            --          This is because currently we don't have any other modifiers that
            --          apply on these lines.

            IF ( g_req_line_info_tab(line_idx).line_type = G_LOADED_DIST_BASE_LINE ) THEN
              -- get loaded distance base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_loaded_dist_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_loaded_dist_price := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_UNLOADED_DIST_BASE_LINE ) THEN
              -- get unloaded distance base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_unloaded_dist_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_unloaded_dist_price := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;


            IF ( g_req_line_info_tab(line_idx).line_type = G_CONT_DIST_BASE_LINE ) THEN
              -- get continuous distance base rate (or cm deadhead rate)
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_cm_dist_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_cm_dist_price := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_CONT_DH_BASE_LINE ) THEN
              -- get continuous distance base rate (or cm deadhead rate)
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_unloaded_dist_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_unloaded_dist_price := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_UNITS_BASE_LINE ) THEN
              -- get unit base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_unit_base_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_unit_base_price := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_TIME_BASE_LINE ) THEN
              -- get time base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_time_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_time_price := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_FLAT_BASE_LINE ) THEN
              -- get loaded distance base rate
              IF (p_qp_output_line_rows(i).unit_price IS NOT NULL) THEN
                l_flat_price := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).unit_price;
              END IF;
            END IF;

       EXIT WHEN i = p_qp_output_line_rows.LAST;
       i := p_qp_output_line_rows.NEXT(i);
     END LOOP;
     END IF;

     -- Generate base price output --
     -- Assumption : both loaded/unloaded and cm dist price cannot be non-zero at the same time.
     -- Does not include continuous move discount
     x_trip_charges_rec.trip_id  := p_trip_rec.trip_id;
     x_trip_charges_rec.currency := p_carrier_pref.currency;
     -- x_trip_charges_rec.base_distance_chrg := l_loaded_dist_price + l_unloaded_dist_price + l_cm_dist_price ;
     IF (l_cm_dist_price <> 0) THEN
       x_trip_charges_rec.base_dist_load_chrg := l_cm_dist_price;
       x_trip_charges_rec.base_dist_load_unit_chrg := l_unit_cm_dist_price;
     ELSE
       x_trip_charges_rec.base_dist_load_chrg := l_loaded_dist_price;
       x_trip_charges_rec.base_dist_load_unit_chrg := l_unit_loaded_dist_price;
     END IF;
     x_trip_charges_rec.base_dist_unload_chrg := l_unloaded_dist_price;
     x_trip_charges_rec.base_dist_unload_unit_chrg := l_unit_unloaded_dist_price;

     x_trip_charges_rec.base_unit_chrg := l_unit_base_price;
     x_trip_charges_rec.base_unit_unit_chrg := l_unit_unit_base_price;
     x_trip_charges_rec.base_time_chrg := l_time_price;
     x_trip_charges_rec.base_time_unit_chrg := l_unit_time_price;
     x_trip_charges_rec.base_flat_chrg := l_flat_price;

     -- init the load charge
     x_trip_charges_rec.out_of_route_chrg := 0;
     x_trip_charges_rec.stop_off_chrg := 0;
     x_trip_charges_rec.document_chrg := 0;
     x_trip_charges_rec.handling_chrg := 0;
     x_trip_charges_rec.cm_discount_percent := 0;
     x_trip_charges_rec.fuel_chrg := 0;

     -- Generate dummy entries into x_stop_charges_tab --
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'Added dummy records to x_stop_charges_rec');
     IF (p_stop_tab.COUNT >0) THEN
     l_stop_index := p_trip_rec.stop_reference;
     LOOP
         init_stop_rec (x_stop_rec => l_stop_rec);
         IF (l_stop_index >= (p_trip_rec.stop_reference + p_trip_rec.number_of_stops ) )
         THEN
            EXIT;
         END IF;
         l_stop_rec.stop_id := p_stop_tab(l_stop_index).stop_id;
         l_stop_rec.trip_id := p_trip_rec.trip_id;
         l_stop_rec.fac_currency := p_stop_tab(l_stop_index).fac_currency;

         x_stop_charges_tab(l_stop_index) := l_stop_rec;

     EXIT WHEN l_stop_index >= p_stop_tab.LAST;
         l_stop_index := p_stop_tab.NEXT(l_stop_index);
     END LOOP;
     END IF;

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'x_stop_charges_tab.COUNT='||x_stop_charges_tab.COUNT);


     -----------  ACCESSORIAL CHARGES,DISCOUNTS AND BASE MIN CHARGES -----------------------

     -- Query line details --

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'Now looping on p_qp_output_detail_rows ');

     i  := p_qp_output_detail_rows.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP

       -- get load level charges
       -- get continuous move discount (if applicable)
       -- get stop level charges (for each stop)
       -- get facility charges (for each stop)

       l_qp_out_det_rec := p_qp_output_detail_rows(i);
       l_req_line_info_rec := g_req_line_info_tab(l_qp_out_det_rec.line_index);

       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
       'i = '||i);
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
       'l_qp_out_det_rec.line_index='||l_qp_out_det_rec.line_index);

       -------------------- MIN BASE CHARGES -------------------


       IF (l_req_line_info_rec.line_type = G_LOADED_DIST_BASE_LINE ) THEN

         -- Min charges for distance charges is across all dist types
         -- It is assumed that both continuous move line and loaded dist line
         -- do not exist in the same call

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_DISTANCE_CH
             AND nvl(l_qp_out_det_rec.adjustment_amount,0) >0 ) THEN
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to distance base rates');
         END IF;

       END IF;

       IF (l_req_line_info_rec.line_type = G_CONT_DIST_BASE_LINE
           AND l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_DISTANCE_CH
           AND nvl(l_qp_out_det_rec.adjustment_amount,0) >0 ) THEN

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to distance base rates (continuous move)');

       END IF;

       IF (l_req_line_info_rec.line_type = G_UNITS_BASE_LINE
          AND l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_UNIT_CH
          AND nvl(l_qp_out_det_rec.adjustment_amount,0) > 0) THEN

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to units base rates ');

       END IF;

       IF (l_req_line_info_rec.line_type = G_TIME_BASE_LINE
           AND l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_TIME_CH
           AND nvl(l_qp_out_det_rec.adjustment_amount,0) > 0) THEN

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to time base rates ');

       END IF;

       -------------------- LOAD (TRIP) CHARGES -------------------

       IF (l_req_line_info_rec.line_type = G_LOAD_CHARGE_LINE ) THEN

         -- dig up load (trip) level charges
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_STOP_OFF_CH) THEN
           x_trip_charges_rec.stop_off_chrg := l_qp_out_det_rec.adjustment_amount;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_OUT_OF_ROUTE_CH) THEN
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- x_trip_charges_rec.out_of_route_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             x_trip_charges_rec.out_of_route_chrg := l_qp_out_det_rec.adjustment_amount;
	   END IF;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_DOCUMENT_CH) THEN
           x_trip_charges_rec.document_chrg := l_qp_out_det_rec.adjustment_amount;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_HANDLING_WEIGHT_CH) THEN
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- x_trip_charges_rec.handling_chrg :=
	       -- l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             x_trip_charges_rec.handling_chrg := l_qp_out_det_rec.adjustment_amount;
             x_trip_charges_rec.handling_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_HANDLING_VOLUME_CH) THEN
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- x_trip_charges_rec.handling_chrg :=
	       -- l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             x_trip_charges_rec.handling_chrg := l_qp_out_det_rec.adjustment_amount;
             x_trip_charges_rec.handling_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_HANDLING_FLAT_CH) THEN
           x_trip_charges_rec.handling_chrg := l_qp_out_det_rec.adjustment_amount;
           x_trip_charges_rec.handling_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;
         END IF;

         -- TODO : Add other handling basis if we support them

         IF (l_qp_out_det_rec.charge_subtype_code
                    = fte_rtg_globals.G_C_CONTINUOUS_MOVE_DISCOUNT) THEN
           x_trip_charges_rec.cm_discount_percent := l_qp_out_det_rec.operand_value;
         END IF;

         -- Fuel Surcharge : bug: 3353264 (enhancement)
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_FUEL_CH) THEN
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
              'G_C_FUEL_CH : operand_value='||l_qp_out_det_rec.operand_value);
           IF (l_qp_out_det_rec.operand_value >0) THEN
              x_trip_charges_rec.fuel_chrg :=
               (  (x_trip_charges_rec.base_dist_load_chrg
               + x_trip_charges_rec.base_dist_unload_chrg
               + x_trip_charges_rec.base_unit_chrg
               + x_trip_charges_rec.base_time_chrg
               + x_trip_charges_rec.base_flat_chrg) * l_qp_out_det_rec.operand_value )/100;
           ELSE
               x_trip_charges_rec.fuel_chrg := 0;
           END IF;
         END IF;

       END IF; -- load charges

       -------------------- STOP CHARGES --------------------------
       -- Initialize l_stop_rec before each iteration. Otherwise nasty spillover effect
       l_stop_rec.stop_id := 0;
       l_stop_rec.trip_id := 0;
       l_stop_rec.weekday_layover_chrg := 0;
       l_stop_rec.weekend_layover_chrg := 0;
       l_stop_rec.loading_chrg := 0;
       l_stop_rec.loading_chrg_basis := null;
       l_stop_rec.ast_loading_chrg := 0;
       l_stop_rec.ast_loading_chrg_basis := null;
       l_stop_rec.unloading_chrg := 0;
       l_stop_rec.unloading_chrg_basis := 0;
       l_stop_rec.ast_unloading_chrg := 0;
       l_stop_rec.ast_unloading_chrg_basis := null;
       l_stop_rec.origin_surchrg := 0;
       l_stop_rec.destination_surchrg := 0;
       l_stop_rec.fac_loading_chrg := 0;
       l_stop_rec.fac_loading_chrg_basis := null;
       l_stop_rec.fac_ast_loading_chrg := 0;
       l_stop_rec.fac_ast_loading_chrg_basis := null;
       l_stop_rec.fac_unloading_chrg := 0;
       l_stop_rec.fac_unloading_chrg_basis := null;
       l_stop_rec.fac_ast_unloading_chrg := 0;
       l_stop_rec.fac_ast_unloading_chrg_basis := null;
       l_stop_rec.fac_handling_chrg := 0;
       l_stop_rec.fac_handling_chrg_basis := null;
       l_stop_rec.fac_currency := null;

       IF (l_req_line_info_rec.line_type = G_STOP_CHARGE_LINE
           OR l_req_line_info_rec.line_type = G_FACILITY_CHARGE_LINE ) THEN

         l_stop_index := g_req_line_info_tab(p_qp_output_detail_rows(i).line_index).stop_index;
         l_stop_id    := p_stop_tab(l_stop_index).stop_id;

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'l_stop_index='||l_stop_index||' l_stop_id='||l_stop_id);

/*
         -- check if this stop_id is already in the stop output table
         -- *** Assumes that x_stop_charges_tab is indexed by stop_id
         IF ( x_stop_charges_tab.EXISTS(l_stop_id) ) THEN
           l_stop_rec := x_stop_charges_tab(l_stop_id);
         ELSE
           l_stop_rec.stop_id := l_stop_id;
           l_stop_rec.trip_id := p_trip_rec.trip_id;
           l_stop_rec.fac_currency := p_stop_tab(l_stop_index).fac_currency;
         END IF;
*/
         IF ( x_stop_charges_tab.EXISTS(l_stop_index) ) THEN
           l_stop_rec := x_stop_charges_tab(l_stop_index);
         ELSE
           l_stop_rec.stop_id := l_stop_id;
           l_stop_rec.trip_id := p_stop_tab(l_stop_index).trip_id;
           l_stop_rec.fac_currency := p_stop_tab(l_stop_index).fac_currency;
         END IF;


       END IF;


       -------------------- CARRIER STOP CHARGES -------------------

       IF (l_req_line_info_rec.line_type = G_STOP_CHARGE_LINE ) THEN
         -- dig up stop level charges

         -- Look for Loading and Assisted Loading Charges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.loading_chrg :=
	       -- l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             --l_stop_rec.loading_chrg :=
	     --  l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_LOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_FLAT_CH ) THEN

           l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_AST_LOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_FLAT_CH ) THEN

           l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF;  -- Loading and Assisted Loading

         -- Look for Unloading and Assisted Unloading Charges
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_UNLOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_AST_UNLOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF; -- Unloading and Assisted Unloading


         -- Look for Origin and Destination Surcharges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_ORIGIN_SURCHRG ) THEN

           l_stop_rec.origin_surchrg := l_qp_out_det_rec.adjustment_amount;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_DESTINATION_SURCHRG ) THEN

           l_stop_rec.destination_surchrg := l_qp_out_det_rec.adjustment_amount;

         END IF;

         -- Look for Weekday and Weekend Layover Charges

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_WEEKDAY_LAYOVER_CH ) THEN

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'G_C_WEEKDAY_LAYOVER_CH : adjustment_amount='||l_qp_out_det_rec.adjustment_amount);
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.weekday_layover_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.weekday_layover_chrg := l_qp_out_det_rec.adjustment_amount;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_WEEKEND_LAYOVER_CH ) THEN

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'G_C_WEEKEND_LAYOVER_CH : adjustment_amount='||l_qp_out_det_rec.adjustment_amount);

	   l_num_of_weekend_layover := p_stop_tab(l_stop_index).weekend_layovers;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'l_num_of_weekend_layover='||l_num_of_weekend_layover);

           l_stop_rec.weekend_layover_chrg :=
	     l_qp_out_det_rec.adjustment_amount * l_num_of_weekend_layover;

         END IF;

         -- Assign the l_stop_rec back to the stop output table
         --x_stop_charges_tab(l_stop_id) := l_stop_rec ;
	 x_stop_charges_tab(l_stop_index) := l_stop_rec ;


       END IF;  -- stop charge line

       -------------------- FACILITY STOP CHARGES -------------------

       IF (l_req_line_info_rec.line_type = G_FACILITY_CHARGE_LINE ) THEN
         -- dig up facility level charges

         -- Look for Facility Loading and Assisted Loading Charges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_LOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --      := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_PALLET_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --      := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_FLAT_CH ) THEN

           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_ast_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_ast_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_AST_LOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_ast_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_PALLET_CH ) THEN

           l_stop_rec.fac_ast_loading_chrg
                 := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_FLAT_CH ) THEN

           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF;  -- Facility Loading and Assisted Loading

         -- Look for Facility Unloading and Assisted Unloading Charges
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_UNLOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_PALLET_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_AST_UNLOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_PALLET_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF; -- Facility Unloading and Assisted Unloading

         -- Look for Facility Handling Charges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_HANDLING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_PALLET_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_FLAT_CH ) THEN

           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF;  -- facility handling charges

         -----------------------------------------------------------------

         -- Assign the l_stop_rec back to the stop output table
         --x_stop_charges_tab(l_stop_id) := l_stop_rec ;
         x_stop_charges_tab(l_stop_index) := l_stop_rec ;

       END IF;  -- facility charge line

       EXIT WHEN i = p_qp_output_detail_rows.LAST;
       i := p_qp_output_detail_rows.NEXT(i);
     END LOOP;
     END IF;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

  END retrieve_qp_output;

  PROCEDURE print_req_line_tab
  IS
     i NUMBER;
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'print_req_line_tab';
  BEGIN
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);

     i := g_req_line_info_tab.FIRST;
     IF ( g_req_line_info_tab.COUNT >0) THEN
     LOOP
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '------------------- g_req_line_info_tab-----------------------');
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'line_index                  :'||g_req_line_info_tab(i).line_index);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'line_type                   :'||g_req_line_info_tab(i).line_type);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'trip_index                  :'||g_req_line_info_tab(i).trip_index);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'stop_index                  :'||g_req_line_info_tab(i).stop_index);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'line_qty                    :'||g_req_line_info_tab(i).line_qty);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'line_uom                    :'||g_req_line_info_tab(i).line_uom);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'currency                    :'||g_req_line_info_tab(i).currency);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'lane_id                     :'||g_req_line_info_tab(i).lane_id);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'pricelist_id                :'||g_req_line_info_tab(i).pricelist_id);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'carrier_id                  :'||g_req_line_info_tab(i).carrier_id);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------------------------------------------------');
       EXIT WHEN (i >= g_req_line_info_tab.LAST );
       i := g_req_line_info_tab.NEXT(i);
     END LOOP;
     END IF;

                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
  EXCEPTION
        WHEN OTHERS THEN
          null;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
  END print_req_line_tab;

  PROCEDURE print_output(
                   p_trip_charges_rec  IN FTE_TL_CACHE.TL_trip_output_rec_type,
                   p_stop_charges_tab  IN FTE_TL_CACHE.TL_trip_stop_output_tab_type
  ) IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'print_output';
    i NUMBER;
  BEGIN
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);

    -- print trip rec
    -- print stop tab
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------- Trip Output----------------------------');
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'trip_id                     :'||p_trip_charges_rec.trip_id );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_load_chrg         :'||p_trip_charges_rec.base_dist_load_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_load_unit_chrg    :'||p_trip_charges_rec.base_dist_load_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_unload_chrg       :'||p_trip_charges_rec.base_dist_unload_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_unload_unit_chrg  :'||p_trip_charges_rec.base_dist_unload_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_unit_chrg              :'||p_trip_charges_rec.base_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_unit_unit_chrg         :'||p_trip_charges_rec.base_unit_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_time_chrg              :'||p_trip_charges_rec.base_time_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_time_unit_chrg         :'||p_trip_charges_rec.base_time_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_flat_chrg              :'||p_trip_charges_rec.base_flat_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'stop_off_chrg               :'||p_trip_charges_rec.stop_off_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'out_of_route_chrg           :'||p_trip_charges_rec.out_of_route_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'document_chrg               :'||p_trip_charges_rec.document_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'handling_chrg               :'||p_trip_charges_rec.handling_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'handling_chrg_basis         :'||p_trip_charges_rec.handling_chrg_basis );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'cm_discount_percent         :'||p_trip_charges_rec.cm_discount_percent );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'cm_discount_value           :'||p_trip_charges_rec.cm_discount_value );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'currency                    :'||p_trip_charges_rec.currency );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'fuel_chrg                   :'||p_trip_charges_rec.fuel_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------------------------------------------------');


     i := p_stop_charges_tab.FIRST;
     IF ( p_stop_charges_tab.COUNT >0) THEN
     LOOP

        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------- Stop Output----------------------------');
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'stop_id                      :'||p_stop_charges_tab(i).stop_id);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'trip_id                      :'||p_stop_charges_tab(i).trip_id);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'weekday_layover_chrg         :'||p_stop_charges_tab(i).weekday_layover_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'weekend_layover_chrg         :'||p_stop_charges_tab(i).weekend_layover_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'loading_chrg                 :'||p_stop_charges_tab(i).loading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'loading_chrg_basis           :'||p_stop_charges_tab(i).loading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'ast_loading_chrg             :'||p_stop_charges_tab(i).ast_loading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'ast_loading_chrg_basis       :'||p_stop_charges_tab(i).ast_loading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'unloading_chrg               :'||p_stop_charges_tab(i).unloading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'unloading_chrg_basis         :'||p_stop_charges_tab(i).unloading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'ast_unloading_chrg           :'||p_stop_charges_tab(i).ast_unloading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'ast_unloading_chrg_basis     :'||p_stop_charges_tab(i).ast_unloading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'origin_surchrg               :'||p_stop_charges_tab(i).origin_surchrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'destination_surchrg          :'||p_stop_charges_tab(i).destination_surchrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_loading_chrg             :'||p_stop_charges_tab(i).fac_loading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_loading_chrg_basis       :'||p_stop_charges_tab(i).fac_loading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_ast_loading_chrg         :'||p_stop_charges_tab(i).fac_ast_loading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_ast_loading_chrg_basis   :'||p_stop_charges_tab(i).fac_ast_loading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_unloading_chrg           :'||p_stop_charges_tab(i).fac_unloading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_unloading_chrg_basis     :'||p_stop_charges_tab(i).fac_unloading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_ast_unloading_chrg       :'||p_stop_charges_tab(i).fac_ast_unloading_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_ast_unloading_chrg_basis :'||p_stop_charges_tab(i).fac_ast_unloading_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_handling_chrg            :'||p_stop_charges_tab(i).fac_handling_chrg);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_handling_chrg_basis      :'||p_stop_charges_tab(i).fac_handling_chrg_basis);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
      'fac_currency                 :'||p_stop_charges_tab(i).fac_currency);
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------------------------------------------------');

       EXIT WHEN (i >= p_stop_charges_tab.LAST );
       i := p_stop_charges_tab.NEXT(i);
     END LOOP;
     END IF;

                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
  END print_output;



  PROCEDURE print_output_multiple(
		p_start_trip_index IN NUMBER,
		p_end_trip_index IN NUMBER,
                p_trip_charges_tab  IN FTE_TL_CACHE.TL_TRIP_OUTPUT_TAB_TYPE,
                p_stop_charges_tab  IN FTE_TL_CACHE.TL_trip_stop_output_tab_type
  ) IS
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'print_output_multiple';
    i NUMBER;
    j NUMBER;
  BEGIN
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);



     i := p_start_trip_index;
     WHILE(i <= p_end_trip_index)
     LOOP

--     	print_output(p_trip_charges_rec=>p_trip_charges_tab(i),
--     		     p_stop_charges_tab=>p_stop_charges_tab);


        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------- Trip Output----------------------------');
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'trip_id                     :'||p_trip_charges_tab(i).trip_id );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_load_chrg         :'||p_trip_charges_tab(i).base_dist_load_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_load_unit_chrg    :'||p_trip_charges_tab(i).base_dist_load_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_unload_chrg       :'||p_trip_charges_tab(i).base_dist_unload_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_dist_unload_unit_chrg  :'||p_trip_charges_tab(i).base_dist_unload_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_unit_chrg              :'||p_trip_charges_tab(i).base_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_unit_unit_chrg         :'||p_trip_charges_tab(i).base_unit_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_time_chrg              :'||p_trip_charges_tab(i).base_time_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_time_unit_chrg         :'||p_trip_charges_tab(i).base_time_unit_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'base_flat_chrg              :'||p_trip_charges_tab(i).base_flat_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'stop_off_chrg               :'||p_trip_charges_tab(i).stop_off_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'out_of_route_chrg           :'||p_trip_charges_tab(i).out_of_route_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'document_chrg               :'||p_trip_charges_tab(i).document_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'handling_chrg               :'||p_trip_charges_tab(i).handling_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'handling_chrg_basis         :'||p_trip_charges_tab(i).handling_chrg_basis );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'cm_discount_percent         :'||p_trip_charges_tab(i).cm_discount_percent );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'cm_discount_value           :'||p_trip_charges_tab(i).cm_discount_value );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'currency                    :'||p_trip_charges_tab(i).currency );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        'fuel_chrg                   :'||p_trip_charges_tab(i).fuel_chrg );
        fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
        '----------------------------------------------------------------');


     	j := p_trip_charges_tab(i).stop_charge_reference;
     	WHILE((FTE_TL_CACHE.g_tl_trip_rows(i).number_of_stops > 0) AND
     	(j<(FTE_TL_CACHE.g_tl_trip_rows(i).number_of_stops+p_trip_charges_tab(i).stop_charge_reference)))
     	LOOP

		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
		'----------------------- Stop Output----------------------------');
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'stop_id                      :'||p_stop_charges_tab(j).stop_id);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'trip_id                      :'||p_stop_charges_tab(j).trip_id);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'weekday_layover_chrg         :'||p_stop_charges_tab(j).weekday_layover_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'weekend_layover_chrg         :'||p_stop_charges_tab(j).weekend_layover_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'loading_chrg                 :'||p_stop_charges_tab(j).loading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'loading_chrg_basis           :'||p_stop_charges_tab(j).loading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'ast_loading_chrg             :'||p_stop_charges_tab(j).ast_loading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'ast_loading_chrg_basis       :'||p_stop_charges_tab(j).ast_loading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'unloading_chrg               :'||p_stop_charges_tab(j).unloading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'unloading_chrg_basis         :'||p_stop_charges_tab(j).unloading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'ast_unloading_chrg           :'||p_stop_charges_tab(j).ast_unloading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'ast_unloading_chrg_basis     :'||p_stop_charges_tab(j).ast_unloading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'origin_surchrg               :'||p_stop_charges_tab(j).origin_surchrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'destination_surchrg          :'||p_stop_charges_tab(j).destination_surchrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_loading_chrg             :'||p_stop_charges_tab(j).fac_loading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_loading_chrg_basis       :'||p_stop_charges_tab(j).fac_loading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_ast_loading_chrg         :'||p_stop_charges_tab(j).fac_ast_loading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_ast_loading_chrg_basis   :'||p_stop_charges_tab(j).fac_ast_loading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_unloading_chrg           :'||p_stop_charges_tab(j).fac_unloading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_unloading_chrg_basis     :'||p_stop_charges_tab(j).fac_unloading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_ast_unloading_chrg       :'||p_stop_charges_tab(j).fac_ast_unloading_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_ast_unloading_chrg_basis :'||p_stop_charges_tab(j).fac_ast_unloading_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_handling_chrg            :'||p_stop_charges_tab(j).fac_handling_chrg);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_handling_chrg_basis      :'||p_stop_charges_tab(j).fac_handling_chrg_basis);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
	      'fac_currency                 :'||p_stop_charges_tab(j).fac_currency);
		fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
		'----------------------------------------------------------------');


	       j := p_stop_charges_tab.NEXT(j);
	END LOOP;





     	i:=i+1;
     END LOOP;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
  END print_output_multiple;




  PROCEDURE api_post_call
        (
          p_api_name           IN     VARCHAR2,
          p_api_return_status  IN     VARCHAR2,
          p_message_name       IN     VARCHAR2,
          p_trip_id            IN     VARCHAR2 DEFAULT NULL,
          p_delivery_id        IN     VARCHAR2 DEFAULT NULL,
          p_delivery_leg_id    IN     VARCHAR2 DEFAULT NULL,
          x_number_of_errors   IN OUT NOCOPY  NUMBER,
          x_number_of_warnings IN OUT NOCOPY  NUMBER,
          x_return_status      OUT NOCOPY     VARCHAR2
        )
    IS
    BEGIN
      x_return_status := p_api_return_status;  -- default
      IF p_api_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
      THEN
            IF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING
            THEN
               x_number_of_warnings := x_number_of_warnings + 1;
            ELSE
                IF p_api_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                      OR p_api_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR
                THEN
                   FND_MESSAGE.SET_NAME('FTE', p_message_name );
                   FND_MESSAGE.SET_TOKEN('PROGRAM_UNIT_NAME', p_api_name);
                   IF p_trip_id IS NOT NULL
                   THEN
                           FND_MESSAGE.SET_TOKEN('TRIP_ID', p_trip_id);
                   END IF;
                   IF p_delivery_id IS NOT NULL
                   THEN
                           FND_MESSAGE.SET_TOKEN('DELIVERY_ID', p_delivery_id);
                   END IF;
                   IF p_delivery_leg_id IS NOT NULL
                   THEN
                           FND_MESSAGE.SET_TOKEN('DELIVERY_LEG_ID', p_delivery_leg_id);
                   END IF;
                   IF (p_api_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
                   THEN
                      WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
                      x_return_status := p_api_return_status;
                   ELSE
                      WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR);
                      x_return_status := p_api_return_status;
                   END IF;
                   RETURN;
                ELSE
                     x_number_of_errors := x_number_of_errors + 1;
                END IF;

            END IF;
      END IF;

    EXCEPTION
    WHEN OTHERS THEN
            wsh_util_core.default_handler(G_PKG_NAME||'.API_POST_CALL');
            WSH_UTIL_CORE.ADD_MESSAGE(WSH_UTIL_CORE.G_RET_STS_ERROR);
            x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
    END api_post_call;



 PROCEDURE retrieve_qp_output_multiple (
	p_start_trip_index IN NUMBER,
	p_end_trip_index IN NUMBER,
	p_trip_tab    IN FTE_TL_CACHE.TL_trip_data_input_tab_type,
	p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
	p_carrier_pref_tab      IN  FTE_TL_CACHE.TL_CARRIER_PREF_TAB_TYPE,
	p_qp_output_line_rows    IN QP_PREQ_GRP.LINE_TBL_TYPE,
	p_qp_output_detail_rows  IN QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE,
	x_trip_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_TRIP_OUTPUT_TAB_TYPE,
	x_stop_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_trip_stop_output_tab_type,
	x_return_status     OUT NOCOPY VARCHAR2)

IS
     l_return_status     VARCHAR2(1);
     i                   NUMBER := 0;
     line_idx            NUMBER := 0;

     l_num_of_weekend_layover     NUMBER;
     l_stop_index                 NUMBER := 0;



     l_loaded_dist_price_tab          DBMS_UTILITY.NUMBER_ARRAY;
     l_unit_loaded_dist_price_tab     DBMS_UTILITY.NUMBER_ARRAY;
     l_unloaded_dist_price_tab        DBMS_UTILITY.NUMBER_ARRAY;
     l_unit_unloaded_dist_price_tab   DBMS_UTILITY.NUMBER_ARRAY;
     l_cm_dist_price_tab              DBMS_UTILITY.NUMBER_ARRAY;
     l_unit_cm_dist_price_tab         DBMS_UTILITY.NUMBER_ARRAY;
     l_unit_base_price_tab            DBMS_UTILITY.NUMBER_ARRAY;
     l_unit_unit_base_price_tab       DBMS_UTILITY.NUMBER_ARRAY;
     l_time_price_tab                 DBMS_UTILITY.NUMBER_ARRAY;
     l_unit_time_price_tab            DBMS_UTILITY.NUMBER_ARRAY;
     l_flat_price_tab                 DBMS_UTILITY.NUMBER_ARRAY;


     j				  NUMBER;
     l_trip_index		  NUMBER;
     l_qp_out_det_rec             QP_PREQ_GRP.LINE_DETAIL_REC_TYPE;
     l_trip_rec 		  FTE_TL_CACHE.TL_trip_output_rec_type;
     l_stop_rec                   FTE_TL_CACHE.TL_trip_stop_output_rec_type;
     l_stop_id                    NUMBER;
     l_req_line_info_rec          req_line_info_rec_type;
     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'retrieve_qp_output_multiple';

  BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);


     --Initialize to 0
     i:=p_start_trip_index;
     WHILE (i<=p_end_trip_index)
     LOOP
     	l_loaded_dist_price_tab(i):=0;
     	l_unit_loaded_dist_price_tab(i):=0;
     	l_unloaded_dist_price_tab(i):=0;
     	l_unit_unloaded_dist_price_tab(i):=0;
     	l_cm_dist_price_tab(i):=0;
     	l_unit_cm_dist_price_tab(i):=0;
     	l_unit_base_price_tab(i):=0;
     	l_unit_unit_base_price_tab(i):=0;
     	l_time_price_tab(i):=0;
     	l_unit_time_price_tab(i):=0;
     	l_flat_price_tab(i):=0;


    	x_trip_charges_tab(i):=l_trip_rec;
    	x_trip_charges_tab(i).trip_id:=p_trip_tab(i).trip_id;
    	x_trip_charges_tab(i).currency:=p_carrier_pref_tab(i).currency;
    	x_trip_charges_tab(i).stop_charge_reference:=p_trip_tab(i).stop_reference;

     	i:=i+1;
     END LOOP;


     -- Loop through the line table
        -- look for base rates returned (incl. continuous move rates if applicable)
     -- Loop through the detail table
        -- look for minimum charges on base prices (how will we process these?)
        -- look for accessorial charges
        -- look for continuous move discount **
     -- Apply minimum charges to base prices ?
     -- Apply continuous move discount if applicable (or will cost allocation deal with it?)
     -- uom conversion?

     ------------- BASE PRICES -----------------------------------

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
           'g_req_line_info_tab.COUNT = '||g_req_line_info_tab.COUNT);
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
           'p_qp_output_line_rows.COUNT = '||p_qp_output_line_rows.COUNT);

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'Now looping on p_qp_output_line_rows ');

     i := p_qp_output_line_rows.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP
         -- get line index
         -- get req info for line index
          -- get base rate (if applicable)
         -- loop thru line details
            -- depending upon the type (purpose) of the line, filter out unwanted details
            -- analyze the charge sub type code, and extract the charge.

            line_idx := p_qp_output_line_rows(i).line_index;
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'line_idx = '||line_idx);

	    l_trip_index:=g_req_line_info_tab(line_idx).trip_index;
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'trip_index = '||l_trip_index);



            --
            -- NOTE :   We use adjusted_unit_price instead on unit_price on most base rates
            --          to account for minimum charges that get applied. If there are no
            --          minimum charges, then unit_price will be equal to adjusted_unit_price.
            --          This is because currently we don't have any other modifiers that
            --          apply on these lines.

            IF ( g_req_line_info_tab(line_idx).line_type = G_LOADED_DIST_BASE_LINE ) THEN
              -- get loaded distance base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_loaded_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_loaded_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_UNLOADED_DIST_BASE_LINE ) THEN
              -- get unloaded distance base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_unloaded_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_unloaded_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;


            IF ( g_req_line_info_tab(line_idx).line_type = G_CONT_DIST_BASE_LINE ) THEN
              -- get continuous distance base rate (or cm deadhead rate)
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_cm_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_cm_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_CONT_DH_BASE_LINE ) THEN
              -- get continuous distance base rate (or cm deadhead rate)
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_unloaded_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_unloaded_dist_price_tab(l_trip_index) := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_UNITS_BASE_LINE ) THEN
              -- get unit base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_unit_base_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_unit_base_price_tab(l_trip_index) := p_qp_output_line_rows(i).adjusted_unit_price;


                fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
		     'trip_index = '||l_trip_index||'base price '||l_unit_base_price_tab(l_trip_index)||
		     ' lin_idx:'||line_idx||' output line idx:'||i||' Quantity:'||p_qp_output_line_rows(i).line_quantity||' Adj unit price'||p_qp_output_line_rows(i).adjusted_unit_price );

              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_TIME_BASE_LINE ) THEN
              -- get time base rate
              IF (p_qp_output_line_rows(i).adjusted_unit_price IS NOT NULL) THEN
                l_time_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).adjusted_unit_price;
                l_unit_time_price_tab(l_trip_index) := p_qp_output_line_rows(i).adjusted_unit_price;
              END IF;
            END IF;

            IF ( g_req_line_info_tab(line_idx).line_type = G_FLAT_BASE_LINE ) THEN
              -- get loaded distance base rate
              IF (p_qp_output_line_rows(i).unit_price IS NOT NULL) THEN
                l_flat_price_tab(l_trip_index) := p_qp_output_line_rows(i).line_quantity
                                        * p_qp_output_line_rows(i).unit_price;
              END IF;
            END IF;

       EXIT WHEN i = p_qp_output_line_rows.LAST;
       i := p_qp_output_line_rows.NEXT(i);
     END LOOP;
     END IF;

     -- Generate base price output --


     i:=p_start_trip_index;
     WHILE (i<=p_end_trip_index)
     LOOP

     -- Assumption : both loaded/unloaded and cm dist price cannot be non-zero at the same time.
     -- Does not include continuous move discount
     -- x_trip_charges_rec.base_distance_chrg := l_loaded_dist_price_tab(i) + l_unloaded_dist_price_tab(i) + l_cm_dist_price_tab(i) ;
	     IF (l_cm_dist_price_tab(i) <> 0) THEN
	       x_trip_charges_tab(i).base_dist_load_chrg := l_cm_dist_price_tab(i);
	       x_trip_charges_tab(i).base_dist_load_unit_chrg := l_unit_cm_dist_price_tab(i);
	     ELSE
	       x_trip_charges_tab(i).base_dist_load_chrg := l_loaded_dist_price_tab(i);
	       x_trip_charges_tab(i).base_dist_load_unit_chrg := l_unit_loaded_dist_price_tab(i);
	     END IF;
	     x_trip_charges_tab(i).base_dist_unload_chrg := l_unloaded_dist_price_tab(i);
	     x_trip_charges_tab(i).base_dist_unload_unit_chrg := l_unit_unloaded_dist_price_tab(i);

	     x_trip_charges_tab(i).base_unit_chrg := l_unit_base_price_tab(i);
	     x_trip_charges_tab(i).base_unit_unit_chrg := l_unit_unit_base_price_tab(i);

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'trip unit charge trip_index = '||i||' charge:'||x_trip_charges_tab(i).base_unit_chrg );


	     x_trip_charges_tab(i).base_time_chrg := l_time_price_tab(i);
	     x_trip_charges_tab(i).base_time_unit_chrg := l_unit_time_price_tab(i);
	     x_trip_charges_tab(i).base_flat_chrg := l_flat_price_tab(i);

	     -- init the load charge
	     x_trip_charges_tab(i).out_of_route_chrg := 0;
	     x_trip_charges_tab(i).stop_off_chrg := 0;
	     x_trip_charges_tab(i).document_chrg := 0;
	     x_trip_charges_tab(i).handling_chrg := 0;
	     x_trip_charges_tab(i).cm_discount_percent := 0;
	     x_trip_charges_tab(i).fuel_chrg := 0;


     	     i:=i+1;
     END LOOP;

     -- Generate dummy entries into x_stop_charges_tab --
     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'Added dummy records to x_stop_charges_rec');

     j:=p_start_trip_index;
     WHILE (j<=p_end_trip_index)
     LOOP


	     IF (p_trip_tab(j).number_of_stops > 0)
	     THEN
		     l_stop_index := p_trip_tab(j).stop_reference;
		     WHILE(l_stop_index <= p_trip_tab(j).number_of_stops+p_trip_tab(j).stop_reference)
		     LOOP
			 init_stop_rec (x_stop_rec => l_stop_rec);

			 l_stop_rec.stop_id := p_stop_tab(l_stop_index).stop_id;
			 l_stop_rec.trip_id := p_stop_tab(l_stop_index).trip_id;
			 l_stop_rec.fac_currency := p_stop_tab(l_stop_index).fac_currency;
			 x_stop_charges_tab(l_stop_index) := l_stop_rec;
			 l_stop_index := p_stop_tab.NEXT(l_stop_index);
		     END LOOP;
	     END IF;


     	j:=j+1;
     END LOOP;


     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'x_stop_charges_tab.COUNT='||x_stop_charges_tab.COUNT);


     -----------  ACCESSORIAL CHARGES,DISCOUNTS AND BASE MIN CHARGES -----------------------

     -- Query line details --

     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
     'Now looping on p_qp_output_detail_rows ');

     i  := p_qp_output_detail_rows.FIRST;
     IF (i IS NOT NULL) THEN
     LOOP

       -- get load level charges
       -- get continuous move discount (if applicable)
       -- get stop level charges (for each stop)
       -- get facility charges (for each stop)

       l_qp_out_det_rec := p_qp_output_detail_rows(i);
       l_req_line_info_rec := g_req_line_info_tab(l_qp_out_det_rec.line_index);

       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
       'i = '||i);
       fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
       'l_qp_out_det_rec.line_index='||l_qp_out_det_rec.line_index);

       l_trip_index:=l_req_line_info_rec.trip_index;

       -------------------- MIN BASE CHARGES -------------------




       IF (l_req_line_info_rec.line_type = G_LOADED_DIST_BASE_LINE ) THEN

         -- Min charges for distance charges is across all dist types
         -- It is assumed that both continuous move line and loaded dist line
         -- do not exist in the same call

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_DISTANCE_CH
             AND nvl(l_qp_out_det_rec.adjustment_amount,0) >0 ) THEN
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to distance base rates');
         END IF;

       END IF;

       IF (l_req_line_info_rec.line_type = G_CONT_DIST_BASE_LINE
           AND l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_DISTANCE_CH
           AND nvl(l_qp_out_det_rec.adjustment_amount,0) >0 ) THEN

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to distance base rates (continuous move)');

       END IF;

       IF (l_req_line_info_rec.line_type = G_UNITS_BASE_LINE
          AND l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_UNIT_CH
          AND nvl(l_qp_out_det_rec.adjustment_amount,0) > 0) THEN

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to units base rates ');

       END IF;

       IF (l_req_line_info_rec.line_type = G_TIME_BASE_LINE
           AND l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_MIN_TIME_CH
           AND nvl(l_qp_out_det_rec.adjustment_amount,0) > 0) THEN

             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
                 'MIN_CHARGE: Minimum charge applied to time base rates ');

       END IF;

       -------------------- LOAD (TRIP) CHARGES -------------------

       IF (l_req_line_info_rec.line_type = G_LOAD_CHARGE_LINE ) THEN

         -- dig up load (trip) level charges
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_STOP_OFF_CH) THEN
           x_trip_charges_tab(l_trip_index).stop_off_chrg := l_qp_out_det_rec.adjustment_amount;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_OUT_OF_ROUTE_CH) THEN
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- x_trip_charges_rec.out_of_route_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             x_trip_charges_tab(l_trip_index).out_of_route_chrg := l_qp_out_det_rec.adjustment_amount;
	   END IF;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_DOCUMENT_CH) THEN
           x_trip_charges_tab(l_trip_index).document_chrg := l_qp_out_det_rec.adjustment_amount;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_HANDLING_WEIGHT_CH) THEN
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- x_trip_charges_rec.handling_chrg :=
	       -- l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             x_trip_charges_tab(l_trip_index).handling_chrg := l_qp_out_det_rec.adjustment_amount;
             x_trip_charges_tab(l_trip_index).handling_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_HANDLING_VOLUME_CH) THEN
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- x_trip_charges_rec.handling_chrg :=
	       -- l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             x_trip_charges_tab(l_trip_index).handling_chrg := l_qp_out_det_rec.adjustment_amount;
             x_trip_charges_tab(l_trip_index).handling_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;
         END IF;

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_HANDLING_FLAT_CH) THEN
           x_trip_charges_tab(l_trip_index).handling_chrg := l_qp_out_det_rec.adjustment_amount;
           x_trip_charges_tab(l_trip_index).handling_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;
         END IF;

         -- TODO : Add other handling basis if we support them

         IF (l_qp_out_det_rec.charge_subtype_code
                    = fte_rtg_globals.G_C_CONTINUOUS_MOVE_DISCOUNT) THEN
           x_trip_charges_tab(l_trip_index).cm_discount_percent := l_qp_out_det_rec.operand_value;
         END IF;

         -- Fuel Surcharge : bug: 3353264 (enhancement)
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_FUEL_CH) THEN
             fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
              'G_C_FUEL_CH : operand_value='||l_qp_out_det_rec.operand_value);
           IF (l_qp_out_det_rec.operand_value >0) THEN
              x_trip_charges_tab(l_trip_index).fuel_chrg :=
               (  (x_trip_charges_tab(l_trip_index).base_dist_load_chrg
               + x_trip_charges_tab(l_trip_index).base_dist_unload_chrg
               + x_trip_charges_tab(l_trip_index).base_unit_chrg
               + x_trip_charges_tab(l_trip_index).base_time_chrg
               + x_trip_charges_tab(l_trip_index).base_flat_chrg) * l_qp_out_det_rec.operand_value )/100;
           ELSE
               x_trip_charges_tab(l_trip_index).fuel_chrg := 0;
           END IF;
         END IF;

       END IF; -- load charges

       -------------------- STOP CHARGES --------------------------
       -- Initialize l_stop_rec before each iteration. Otherwise nasty spillover effect
       l_stop_rec.stop_id := 0;
       l_stop_rec.trip_id := 0;
       l_stop_rec.weekday_layover_chrg := 0;
       l_stop_rec.weekend_layover_chrg := 0;
       l_stop_rec.loading_chrg := 0;
       l_stop_rec.loading_chrg_basis := null;
       l_stop_rec.ast_loading_chrg := 0;
       l_stop_rec.ast_loading_chrg_basis := null;
       l_stop_rec.unloading_chrg := 0;
       l_stop_rec.unloading_chrg_basis := 0;
       l_stop_rec.ast_unloading_chrg := 0;
       l_stop_rec.ast_unloading_chrg_basis := null;
       l_stop_rec.origin_surchrg := 0;
       l_stop_rec.destination_surchrg := 0;
       l_stop_rec.fac_loading_chrg := 0;
       l_stop_rec.fac_loading_chrg_basis := null;
       l_stop_rec.fac_ast_loading_chrg := 0;
       l_stop_rec.fac_ast_loading_chrg_basis := null;
       l_stop_rec.fac_unloading_chrg := 0;
       l_stop_rec.fac_unloading_chrg_basis := null;
       l_stop_rec.fac_ast_unloading_chrg := 0;
       l_stop_rec.fac_ast_unloading_chrg_basis := null;
       l_stop_rec.fac_handling_chrg := 0;
       l_stop_rec.fac_handling_chrg_basis := null;
       l_stop_rec.fac_currency := null;

       IF (l_req_line_info_rec.line_type = G_STOP_CHARGE_LINE
           OR l_req_line_info_rec.line_type = G_FACILITY_CHARGE_LINE ) THEN

         l_stop_index := g_req_line_info_tab(p_qp_output_detail_rows(i).line_index).stop_index;
         l_stop_id    := p_stop_tab(l_stop_index).stop_id;

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'l_stop_index='||l_stop_index||' l_stop_id='||l_stop_id);
/*
         -- check if this stop_id is already in the stop output table
         -- *** Assumes that x_stop_charges_tab is indexed by stop_id
         IF ( x_stop_charges_tab.EXISTS(l_stop_id) ) THEN
           l_stop_rec := x_stop_charges_tab(l_stop_id);
         ELSE
           l_stop_rec.stop_id := l_stop_id;
           l_stop_rec.trip_id := p_stop_tab(l_stop_index).trip_id;
           l_stop_rec.fac_currency := p_stop_tab(l_stop_index).fac_currency;
         END IF;
*/
         IF ( x_stop_charges_tab.EXISTS(l_stop_index) ) THEN
           l_stop_rec := x_stop_charges_tab(l_stop_index);
         ELSE
           l_stop_rec.stop_id := l_stop_id;
           l_stop_rec.trip_id := p_stop_tab(l_stop_index).trip_id;
           l_stop_rec.fac_currency := p_stop_tab(l_stop_index).fac_currency;
         END IF;


       END IF;


       -------------------- CARRIER STOP CHARGES -------------------

       IF (l_req_line_info_rec.line_type = G_STOP_CHARGE_LINE ) THEN
         -- dig up stop level charges

         -- Look for Loading and Assisted Loading Charges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.loading_chrg :=
	       -- l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             --l_stop_rec.loading_chrg :=
	     --  l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_LOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_LOADING_FLAT_CH ) THEN

           l_stop_rec.loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_AST_LOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_loading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_LOADING_FLAT_CH ) THEN

           l_stop_rec.ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.ast_loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF;  -- Loading and Assisted Loading

         -- Look for Unloading and Assisted Unloading Charges
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_UNLOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_WEIGHT_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_VOLUME_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_C_AST_UNLOADING_CONTAINER_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_PALLET_CH ) THEN

	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.ast_unloading_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
             l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_AST_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.ast_unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF; -- Unloading and Assisted Unloading


         -- Look for Origin and Destination Surcharges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_ORIGIN_SURCHRG ) THEN

           l_stop_rec.origin_surchrg := l_qp_out_det_rec.adjustment_amount;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_DESTINATION_SURCHRG ) THEN

           l_stop_rec.destination_surchrg := l_qp_out_det_rec.adjustment_amount;

         END IF;

         -- Look for Weekday and Weekend Layover Charges

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_WEEKDAY_LAYOVER_CH ) THEN

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'G_C_WEEKDAY_LAYOVER_CH : adjustment_amount='||l_qp_out_det_rec.adjustment_amount);
	   IF (l_qp_out_det_rec.adjustment_amount is not null
	       AND l_qp_out_det_rec.line_quantity is not null) THEN
             -- l_stop_rec.weekday_layover_chrg :=
	     --   l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
             l_stop_rec.weekday_layover_chrg := l_qp_out_det_rec.adjustment_amount;
	   END IF;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_C_WEEKEND_LAYOVER_CH ) THEN

         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'G_C_WEEKEND_LAYOVER_CH : adjustment_amount='||l_qp_out_det_rec.adjustment_amount);

	   l_num_of_weekend_layover := p_stop_tab(l_stop_index).weekend_layovers;
         fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,
         'l_num_of_weekend_layover='||l_num_of_weekend_layover);

           l_stop_rec.weekend_layover_chrg :=
	     l_qp_out_det_rec.adjustment_amount * l_num_of_weekend_layover;

         END IF;

         -- Assign the l_stop_rec back to the stop output table
         -- For multiple the stop_charges_tab is indexed by the stop_index and
         -- not stop id
         x_stop_charges_tab(l_stop_index) := l_stop_rec ;

       END IF;  -- stop charge line

       -------------------- FACILITY STOP CHARGES -------------------

       IF (l_req_line_info_rec.line_type = G_FACILITY_CHARGE_LINE ) THEN
         -- dig up facility level charges

         -- Look for Facility Loading and Assisted Loading Charges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_LOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --      := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_PALLET_CH ) THEN

           -- l_stop_rec.fac_loading_chrg
           --      := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_LOADING_FLAT_CH ) THEN

           l_stop_rec.fac_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_ast_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_ast_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_AST_LOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_ast_loading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_PALLET_CH ) THEN

           l_stop_rec.fac_ast_loading_chrg
                 := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_LOADING_FLAT_CH ) THEN

           l_stop_rec.fac_ast_loading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_loading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF;  -- Facility Loading and Assisted Loading

         -- Look for Facility Unloading and Assisted Unloading Charges
         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_UNLOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_PALLET_CH ) THEN

           -- l_stop_rec.fac_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.fac_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_AST_UNLOADING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_PALLET_CH ) THEN

           -- l_stop_rec.fac_ast_unloading_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_AST_UNLOADING_FLAT_CH ) THEN

           l_stop_rec.fac_ast_unloading_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_ast_unloading_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF; -- Facility Unloading and Assisted Unloading

         -- Look for Facility Handling Charges --

         IF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_WEIGHT_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_WEIGHT_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_VOLUME_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_VOLUME_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code
                                     = fte_rtg_globals.G_F_HANDLING_CONTAINER_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_CONTAINER_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_PALLET_CH ) THEN

           -- l_stop_rec.fac_handling_chrg
           --       := l_qp_out_det_rec.adjustment_amount * l_qp_out_det_rec.line_quantity;
             -- bug 3474455
           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_PALLET_BASIS;

         ELSIF (l_qp_out_det_rec.charge_subtype_code = fte_rtg_globals.G_F_HANDLING_FLAT_CH ) THEN

           l_stop_rec.fac_handling_chrg := l_qp_out_det_rec.adjustment_amount;
           l_stop_rec.fac_handling_chrg_basis := fte_rtg_globals.G_FLAT_BASIS;

         END IF;  -- facility handling charges

         -----------------------------------------------------------------

         -- Assign the l_stop_rec back to the stop output table
         -- For multiple the stop_charges_tab is indexed by the stop_index and
         -- not stop id

         x_stop_charges_tab(l_stop_index) := l_stop_rec ;

       END IF;  -- facility charge line

       EXIT WHEN i = p_qp_output_detail_rows.LAST;
       i := p_qp_output_detail_rows.NEXT(i);
     END LOOP;
     END IF;

  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);


END retrieve_qp_output_multiple;




PROCEDURE check_qp_ipl_multiple(
	p_start_index IN NUMBER,
	p_end_index IN NUMBER,
	p_qp_output_line_rows   IN QP_PREQ_GRP.LINE_TBL_TYPE,
	x_exceptions IN OUT NOCOPY FTE_TL_CORE.tl_exceptions_tab_type,
	x_return_status     OUT NOCOPY VARCHAR2)

IS
    i NUMBER;
      l_non_dummy_row_count NUMBER;
      l_dummy_row_count NUMBER;
      l_dummy_ipl_count NUMBER;
      l_non_dummy_ipl_count NUMBER;
      l_line_type NUMBER;
      l_line_index NUMBER;
      l_ipl_flag VARCHAR2(1);


      l_trip_index NUMBER;
      l_non_dummy_row_count_tab DBMS_UTILITY.NUMBER_ARRAY;
      l_dummy_row_count_tab DBMS_UTILITY.NUMBER_ARRAY;
      l_dummy_ipl_count_tab DBMS_UTILITY.NUMBER_ARRAY;
      l_non_dummy_ipl_count_tab DBMS_UTILITY.NUMBER_ARRAY;


      l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
      l_method_name VARCHAR2(50) := 'check_qp_ipl';

BEGIN
       x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
       fte_freight_pricing_util.reset_dbg_vars;
       fte_freight_pricing_util.set_method(l_log_level,l_method_name);

	-- l_non_dummy_row_count:=0;
	-- bug 3610889
	i:=p_start_index;
	WHILE (i <= p_end_index)
	LOOP
		l_non_dummy_row_count_tab(i):=x_exceptions(i).implicit_non_dummy_cnt;
		l_dummy_row_count_tab(i):=0;
		l_dummy_ipl_count_tab(i):=0;
		l_non_dummy_ipl_count_tab(i):=0;

		i:=i+1;
	END LOOP;

	i:=p_qp_output_line_rows.FIRST;
	WHILE (i IS NOT NULL)
	LOOP
		IF ((p_qp_output_line_rows(i).status_code IS NOT NULL) AND (p_qp_output_line_rows(i).status_code='IPL'))
		THEN
			l_ipl_flag:='Y';
		ELSE
			l_ipl_flag:='N';
		END IF;
		l_line_index:=p_qp_output_line_rows(i).line_index;
		IF ((l_line_index IS NOT NULL) AND (g_req_line_info_tab.EXISTS(l_line_index)))
		THEN
			l_trip_index:=g_req_line_info_tab(l_line_index).trip_index;
			l_line_type:=g_req_line_info_tab(l_line_index).line_type;
			--SUSUREND :classiffy a line as dummy if it is a trip level charge line,stop level charge line
			--or facility line
			IF ((l_line_type IS NOT NULL) AND (l_line_type <> G_LOAD_CHARGE_LINE)
				AND (l_line_type <>G_STOP_CHARGE_LINE ) AND (l_line_type <>G_FACILITY_CHARGE_LINE))
			THEN
				l_non_dummy_row_count_tab(l_trip_index):=l_non_dummy_row_count_tab(l_trip_index)+1;
				IF (l_ipl_flag='Y')
				THEN
					l_non_dummy_ipl_count_tab(l_trip_index):=l_non_dummy_ipl_count_tab(l_trip_index)+1;
				END IF;
			ELSE
				l_dummy_row_count_tab(l_trip_index):=l_dummy_row_count_tab(l_trip_index)+1;
				IF (l_ipl_flag='Y')
				THEN
					l_dummy_ipl_count_tab(l_trip_index):=l_dummy_ipl_count_tab(l_trip_index)+1;
				END IF;


			END IF;

		ELSE
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Index not found:'||i);

		END IF;


		i:=p_qp_output_line_rows.NEXT(i);
	END LOOP;

	i:=p_start_index;
	WHILE (i <= p_end_index)
	LOOP

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' Number of dummy lines:'||l_dummy_row_count_tab(i)
			||' Number of non dummy lines:'||l_non_dummy_row_count_tab(i)||' Dummy IPLs:'||l_dummy_ipl_count_tab(i)||
			' Non Dummy IPLs :'||l_non_dummy_ipl_count_tab(i));
		IF (l_non_dummy_ipl_count_tab(i) >= l_non_dummy_row_count_tab(i))
		THEN
			x_exceptions(i).check_qp_ipl_fail:='Y';
			x_exceptions(i).not_on_pl_flag:='Y';
			--raise fte_freight_pricing_util.g_not_on_pricelist;
		END IF;

		i:=i+1;

	END LOOP;



       fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

EXCEPTION
WHEN fte_freight_pricing_util.g_not_on_pricelist THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- can use tokens here
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_on_pricelist');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Item quantity not found on pricelist ');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

WHEN OTHERS THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);


END check_qp_ipl_multiple;



PROCEDURE check_tl_qp_op_err_multiple (
	p_start_index IN NUMBER,
	p_end_index IN NUMBER,
	p_req_line_info_tab IN req_line_info_tab_type,
	x_exceptions IN OUT NOCOPY FTE_TL_CORE.tl_exceptions_tab_type,
	x_return_status  OUT NOCOPY  VARCHAR2)
IS

  i  NUMBER :=0;

  l_category   VARCHAR2(30);

  l_trip_index NUMBER;
  l_ipl_cnt_tab DBMS_UTILITY.NUMBER_ARRAY;
  l_error_flag_tab DBMS_UTILITY.NUMBER_ARRAY;
  l_line_cnt_tab DBMS_UTILITY.NUMBER_ARRAY;


     l_log_level  NUMBER := fte_freight_pricing_util.G_LOG;
  l_method_name VARCHAR2(50) := 'check_tl_qp_op_err_multiple';
 BEGIN
     x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
     fte_freight_pricing_util.reset_dbg_vars;
     fte_freight_pricing_util.set_method(l_log_level,l_method_name);

     --init tab variables
     i:=p_start_index;
     WHILE(i <=p_end_index)
     LOOP

     	l_ipl_cnt_tab(i):=0;
     	l_error_flag_tab(i):=0;
     	l_line_cnt_tab(i):=0;

     	i:=i+1;
     END LOOP;

         i := FTE_QP_ENGINE.g_O_line_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP

	     --get the trip index of this output line
             l_trip_index:=p_req_line_info_tab(FTE_QP_ENGINE.g_O_line_tbl(i).line_index).trip_index;

             l_line_cnt_tab(l_trip_index):=l_line_cnt_tab(l_trip_index)+1;


             IF (FTE_QP_ENGINE.g_O_line_tbl(i).status_code IN (
                  QP_PREQ_GRP.G_STATUS_INVALID_PRICE_LIST       ,
                  QP_PREQ_GRP.G_STATUS_GSA_VIOLATION            ,
                  QP_PREQ_GRP.G_STS_LHS_NOT_FOUND               ,
                  QP_PREQ_GRP.G_STATUS_FORMULA_ERROR            ,
                  QP_PREQ_GRP.G_STATUS_OTHER_ERRORS             ,
                  QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC             ,
                  QP_PREQ_GRP.G_STATUS_CALC_ERROR		  ,
                  QP_PREQ_GRP.G_STATUS_UOM_FAILURE              ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM              ,
                  QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST           ,
                  QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV         ,
                  QP_PREQ_GRP.G_STATUS_INVALID_INCOMP           ,
                  QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR    )) THEN
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,' LineIndex = '||i||' Status Code = '||FTE_QP_ENGINE.g_O_line_tbl(i).status_code||' Text = '||FTE_QP_ENGINE.g_O_line_tbl(i).status_text);
                 IF (FTE_QP_ENGINE.g_O_line_tbl(i).status_code = 'IPL') THEN


                     l_ipl_cnt_tab(l_trip_index):=l_ipl_cnt_tab(l_trip_index)+1;


                     FTE_QP_ENGINE.g_O_line_tbl(i).unit_price := 0;
                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,
                       'Following item quantity not found on pricelist :');
                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,
                       '      Quantity = '||FTE_QP_ENGINE.g_I_line_quantity(i)||' '||FTE_QP_ENGINE.g_I_line_uom_code(i));
                 ELSE
                     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Settng error flag Case 1 LineIndex = '||i||' trip index:'||l_trip_index);
                     l_error_flag_tab(l_trip_index):=1;

                 END IF;
             END IF;
             IF (FTE_QP_ENGINE.g_O_line_tbl(i).unit_price IS NULL) THEN

             	 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Settng error flag Case 2 LineIndex = '||i||' trip index:'||l_trip_index);

             	 l_error_flag_tab(l_trip_index):=1;

                 fte_freight_pricing_util.print_msg(l_log_level,'Unit price is null');
	     -- ELSIF (FTE_QP_ENGINE.g_O_line_tbl(i).unit_price <= 0) THEN
	     ELSIF (FTE_QP_ENGINE.g_O_line_tbl(i).unit_price < 0) THEN         -- TL
	     fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Settng error flag Case 3 LineIndex = '||i||' trip index:'||l_trip_index);
             	l_error_flag_tab(l_trip_index):=1;
                 -- fte_freight_pricing_util.print_msg(l_log_level,'Unit price non-positive');
                 fte_freight_pricing_util.print_msg(l_log_level,'Unit price negative');
             END IF;
         EXIT WHEN i >= FTE_QP_ENGINE.g_O_line_tbl.LAST;
             i := FTE_QP_ENGINE.g_O_line_tbl.NEXT(i);
         END LOOP;
        END IF;


         i := FTE_QP_ENGINE.g_O_line_detail_tbl.FIRST;
        IF (i IS NOT NULL) THEN
         LOOP
             IF (FTE_QP_ENGINE.g_O_line_detail_tbl(i).adjustment_amount IS NULL)
             THEN

             	l_trip_index:=p_req_line_info_tab(FTE_QP_ENGINE.g_O_line_detail_tbl(i).line_index).trip_index;
                 l_error_flag_tab(l_trip_index) := 1;
                 fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Settng error flag Case 4 LineIndex = '||i||' trip index:'||l_trip_index);
                 fte_freight_pricing_util.print_msg(l_log_level,'Adjustment amount is null');
             END IF;
         EXIT WHEN i >= FTE_QP_ENGINE.g_O_line_detail_tbl.LAST;
             i := FTE_QP_ENGINE.g_O_line_detail_tbl.NEXT(i);
         END LOOP;
        END IF;



	i:=p_start_index;
	WHILE ( i <= p_end_index)
	LOOP

		IF (l_ipl_cnt_tab(i) >= l_line_cnt_tab(i)) THEN
		    -- probably big failure - not good
		      fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Settng error flag Case 5 trip Index = '||i);
		    fte_freight_pricing_util.print_msg(l_log_level,'l_ipl_cnt >= l_line_cnt for trip_index:'||i);
		    x_exceptions(i).check_tlqp_ouputfail:='Y';
		    x_exceptions(i).not_on_pl_flag:='Y';

		    --raise fte_freight_pricing_util.g_not_on_pricelist;
		ELSIF (l_ipl_cnt_tab(i) > 0) THEN
		    -- probably ok
		    fte_freight_pricing_util.print_msg(l_log_level,'WARNING: SOME LINES HAD IPL !!! for trip_index:'||i);
		END IF;

		IF (l_error_flag_tab(i)=1)
		THEN
		  	fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_LOG,'Settng error flag Case 6 trip Index = '||i);
			x_exceptions(i).check_tlqp_ouputfail:='Y';
			x_exceptions(i).price_req_failed:='Y';
			--x_exceptions(i).exception_name:=fte_freight_pricing_util.g_qp_price_request_failed;
		END IF;

		i:=i+1;
	END LOOP;





     fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
    EXCEPTION
        WHEN fte_freight_pricing_util.g_not_on_pricelist THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           -- can use tokens here
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_not_on_pricelist');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Following item quantity not found on pricelist :');
           l_category := FTE_QP_ENGINE.g_I_line_extras_tbl(i).category_id;
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      Quantity = '||FTE_QP_ENGINE.g_I_line_quantity(i)||' '||FTE_QP_ENGINE.g_I_line_uom_code(i));
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'      CategoryId = '||nvl(l_category,'Consolidated'));
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
        WHEN fte_freight_pricing_util.g_qp_price_request_failed THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_qp_price_request_failed');
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);
        WHEN others THEN
           x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
           fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
           fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
           fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

END check_tl_qp_op_err_multiple;


--Identifies cache entries which have the same SM/Vehicle/Trip
--Avoid sending these in one call to QP as minimum charges wont apply correctly
--same SM/Vehicle/Trip results in same rate for TL

PROCEDURE Identify_Same_Rate_Inputs(
    p_start_trip_index IN NUMBER,
    p_end_trip_index IN NUMBER,
    p_trip_tab    IN FTE_TL_CACHE.TL_trip_data_input_tab_type,
    p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
    x_same_rate_map     OUT NOCOPY DBMS_UTILITY.NUMBER_ARRAY,
    x_return_status     OUT NOCOPY VARCHAR2) IS

  i NUMBER;
  l_original_trip_index NUMBER;
  l_carrier_hash DBMS_UTILITY.NUMBER_ARRAY;

  l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'Identify_Same_Rate_Inputs';

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  x_same_rate_map.delete;
  l_carrier_hash.delete;
  i:=p_start_trip_index;
  WHILE(i<=p_end_trip_index)
  LOOP
  	IF(NOT l_carrier_hash.EXISTS(p_trip_tab(i).carrier_id))
  	THEN
  		l_carrier_hash(p_trip_tab(i).carrier_id):=i;

  	ELSE
  		l_original_trip_index:=l_carrier_hash(p_trip_tab(i).carrier_id);
  		IF((p_trip_tab(l_original_trip_index).carrier_id = p_trip_tab(i).carrier_id)
  		AND (p_trip_tab(l_original_trip_index).service_type = p_trip_tab(i).service_type)
  		AND (p_trip_tab(l_original_trip_index).mode_of_transport = p_trip_tab(i).mode_of_transport)
  		AND (p_trip_tab(l_original_trip_index).vehicle_type = p_trip_tab(i).vehicle_type)
  		AND (p_trip_tab(l_original_trip_index).price_list_id = p_trip_tab(i).price_list_id)
  		AND (p_trip_tab(l_original_trip_index).trip_id = p_trip_tab(i).trip_id))
  		THEN
  			x_same_rate_map(i):=l_original_trip_index;
  			fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'trip Index :'||i||' same as trip Index:'||l_original_trip_index);

  		END IF;

  	END IF;

  	i:=i+1;
  END LOOP;



  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION

    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
END Identify_Same_Rate_Inputs;


PROCEDURE Copy_Same_Rates(
    p_start_trip_index IN NUMBER,
    p_end_trip_index IN NUMBER,
    p_trip_tab    IN FTE_TL_CACHE.TL_trip_data_input_tab_type,
    p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
    p_same_rate_map     IN DBMS_UTILITY.NUMBER_ARRAY,
    x_trip_charges_tab  IN OUT NOCOPY FTE_TL_CACHE.TL_TRIP_OUTPUT_TAB_TYPE,
    x_stop_charges_tab  IN OUT NOCOPY	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
    x_exceptions_tab IN OUT NOCOPY FTE_TL_CORE.tl_exceptions_tab_type,
    x_return_status     OUT NOCOPY VARCHAR2) IS

 i NUMBER;
 j NUMBER;
 k NUMBER;
 l_original_index NUMBER;
 l_stop_charge_reference NUMBER;
 l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
  l_method_name VARCHAR2(50) := 'Copy_Same_Rates';

BEGIN
  x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
  fte_freight_pricing_util.reset_dbg_vars;
  fte_freight_pricing_util.set_method(l_log_level,l_method_name);

  i:=p_same_rate_map.FIRST;
  WHILE(i IS NOT NULL)
  LOOP
  	l_original_index:=p_same_rate_map(i);
  	l_stop_charge_reference:=x_trip_charges_tab(i).stop_charge_reference;

  	x_trip_charges_tab(i):=x_trip_charges_tab(l_original_index);
  	x_trip_charges_tab(i).stop_charge_reference:=l_stop_charge_reference;
  	x_exceptions_tab(i):=x_exceptions_tab(l_original_index);

	j:=x_trip_charges_tab(i).stop_charge_reference;
	k:=x_trip_charges_tab(l_original_index).stop_charge_reference;
	WHILE((p_trip_tab(i).number_of_stops > 0) AND
	(j<(p_trip_tab(i).number_of_stops+x_trip_charges_tab(i).stop_charge_reference)))
	LOOP

		x_stop_charges_tab(j):=x_stop_charges_tab(k);
		k:=k+1;
		j:=j+1;
	END LOOP;


  	i:=p_same_rate_map.NEXT(i);

  END LOOP;




  fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION

  WHEN OTHERS THEN
  	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

END Copy_Same_Rates;



PROCEDURE TL_Core_Multiple (
		    p_start_trip_index IN NUMBER,
		    p_end_trip_index IN NUMBER,
	            p_trip_tab    IN FTE_TL_CACHE.TL_trip_data_input_tab_type,
	            p_stop_tab          IN  FTE_TL_CACHE.TL_trip_stop_input_tab_type,
	            p_carrier_pref_tab      IN  FTE_TL_CACHE.TL_CARRIER_PREF_TAB_TYPE,
	            x_trip_charges_tab  OUT NOCOPY FTE_TL_CACHE.TL_TRIP_OUTPUT_TAB_TYPE,
	            x_stop_charges_tab  OUT NOCOPY	FTE_TL_CACHE.TL_trip_stop_output_tab_type,
		    x_exceptions_tab OUT NOCOPY FTE_TL_CORE.tl_exceptions_tab_type,
	            x_return_status     OUT NOCOPY VARCHAR2) IS


     l_pricing_control_rec           fte_freight_pricing.pricing_control_input_rec_type;
     l_pricing_engine_input_rec      fte_freight_pricing.pricing_engine_input_rec_type;
     l_curr_line_idx                 NUMBER := 0;
     l_req_line_info_rec             req_line_info_rec_type;
     l_qp_output_line_rows           QP_PREQ_GRP.LINE_TBL_TYPE;
     l_qp_output_detail_rows         QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
     l_implicit_non_dummy_cnt        NUMBER := 0;

     l_same_rate_map DBMS_UTILITY.NUMBER_ARRAY;
     l_exception_rec tl_exceptions_type;
     l_trip_rec          FTE_TL_CACHE.TL_trip_data_input_rec_type;
     i		NUMBER;
     l_return_status                 VARCHAR2(1);

     l_log_level  NUMBER := fte_freight_pricing_util.G_DBG;
     l_method_name VARCHAR2(50) := 'TL_Core_Multiple';

  BEGIN

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
    fte_freight_pricing_util.reset_dbg_vars;
    fte_freight_pricing_util.set_method(l_log_level,l_method_name);

    -- create request lines
        -- distance, time, ..
        -- for each request line - build qualifiers
        -- for each base price request line - build attributes
        -- for each charge request line - build attributes
    -- call qp engine
    -- check qp errors
    -- analyze o/p
        -- analyze and extract charges

    -- First clear all global tables ***
    g_req_line_info_tab.DELETE;
    FTE_QP_ENGINE.clear_globals(x_return_status => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After clear_globals ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_clear_globals_fl');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --initialize exception counts

    l_exception_rec.implicit_non_dummy_cnt:=0;
    l_exception_rec.check_tlqp_ouputfail:='N';
    l_exception_rec.check_qp_ipl_fail:='N';
    l_exception_rec.not_on_pl_flag:='N';
    l_exception_rec.price_req_failed:='N';
    l_exception_rec.allocation_failed:='N';


    -- Identify cache entries which will result in same rates

    Identify_Same_Rate_Inputs(
	    p_start_trip_index =>p_start_trip_index,
	    p_end_trip_index => p_end_trip_index,
	    p_trip_tab =>p_trip_tab,
	    p_stop_tab =>p_stop_tab,
	    x_same_rate_map=> l_same_rate_map,
	    x_return_status=>l_return_status);

-- Add in exception handling for identify same rate inputs

    i:=p_start_trip_index;
    WHILE(i <= p_end_trip_index)
    LOOP

	    x_exceptions_tab(i):=l_exception_rec;
	    x_exceptions_tab(i).trip_index:=i;

	    IF (NOT l_same_rate_map.EXISTS(i))
	    THEN

		    -- g_effectivity dates is the global variable which stores the dates passed to QP
		    -- these dates are set to the trip departure dates. For price list selection, only the
		    -- trip departure date is used (not arrival).


		    fte_freight_pricing.g_effectivity_dates.date_from:=p_trip_tab(i).planned_departure_date;
		    fte_freight_pricing.g_effectivity_dates.date_to:=p_trip_tab(i).planned_departure_date;


		    -- bug 3610889 : added new parameter p_implicit_non_dummy_cnt
		    --pass in the trip_index so that a reference to it is stored
		    --in g_req_line_info_tab
		    create_engine_inputs(
				   p_trip_rec          => p_trip_tab(i),
				   p_stop_tab          => p_stop_tab,
				   p_carrier_pref      => p_carrier_pref_tab(i),
				   p_trip_index        =>i,
				   x_implicit_non_dummy_cnt => x_exceptions_tab(i).implicit_non_dummy_cnt,
				   x_return_status     => l_return_status );

		    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
			  FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After create_engine_inputs ');
			  fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_cr_eng_inp_failed');
		      raise FND_API.G_EXC_ERROR;
		       END IF;
		    END IF;

		    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'l_implicit_non_dummy_cnt = '||x_exceptions_tab(i).implicit_non_dummy_cnt);


    	    ELSE
    	    	fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'Not creating QP inputs for trip index i:'||i||' same rate as index'||l_same_rate_map(i));
    	    END IF;
    	i:=i+1;
    END LOOP;



    -- fte_qp_engine.print_qp_input;

       -- call qp engine

    fte_freight_pricing_util.print_msg(fte_freight_pricing_util.G_DBG,'g_req_line_info_tab.COUNT = '||g_req_line_info_tab.COUNT);

    print_req_line_tab;

    fte_qp_engine.call_qp_api  (
        x_qp_output_line_rows    => l_qp_output_line_rows,
        x_qp_output_detail_rows  => l_qp_output_detail_rows,
    x_return_status          => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After call_qp_api ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_call_qp_api_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;



    -- This will not usually fail, sets flag on x_exceptions if it fails for a particular
    --trip index

    check_tl_qp_op_err_multiple (
	p_start_index=>p_start_trip_index,
	p_end_index=>p_end_trip_index,
	p_req_line_info_tab =>g_req_line_info_tab,
	x_exceptions=>x_exceptions_tab,
	x_return_status=>l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After check_tl_qp_output_errors ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_chk_qp_output_failed');
      	  raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;


   -- This will not usually fail, sets flag on x_exceptions if it fails for a particular
   --trip index

    check_qp_ipl_multiple(
	p_start_index=>p_start_trip_index,
	p_end_index=>p_end_trip_index ,
	p_qp_output_line_rows=>l_qp_output_line_rows,
	x_exceptions=>x_exceptions_tab,
	x_return_status=> l_return_status );

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After check_qp_ipl_mulitple ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_check_qp_ipl_failed');
           raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;




     -- process qp output



    retrieve_qp_output_multiple (
	p_start_trip_index	=>p_start_trip_index,
	p_end_trip_index	=>p_end_trip_index,
	p_trip_tab		=>p_trip_tab,
        p_stop_tab              => p_stop_tab,
        p_carrier_pref_tab	=>p_carrier_pref_tab,
        p_qp_output_line_rows   => l_qp_output_line_rows,
        p_qp_output_detail_rows => l_qp_output_detail_rows,
        x_trip_charges_tab      => x_trip_charges_tab,
        x_stop_charges_tab      => x_stop_charges_tab,
        x_return_status         => l_return_status);

    IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
          FTE_FREIGHT_PRICING_UTIL.set_location(p_loc => 'After retrieve_qp_output_multiple ');
          fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_tl_ret_qp_out_failed');
      raise FND_API.G_EXC_ERROR;
       END IF;
    END IF;

     Copy_Same_Rates(
	p_start_trip_index	=>p_start_trip_index,
	p_end_trip_index	=>p_end_trip_index,
	p_trip_tab		=>p_trip_tab,
        p_stop_tab              => p_stop_tab,
        p_same_rate_map     	=>l_same_rate_map,
        x_trip_charges_tab      => x_trip_charges_tab,
        x_stop_charges_tab      => x_stop_charges_tab,
        x_exceptions_tab	=> x_exceptions_tab,
        x_return_status         => l_return_status);

     print_output_multiple(
     		   p_start_trip_index => p_start_trip_index,
     		   p_end_trip_index   => p_end_trip_index,
     		   p_trip_charges_tab  => x_trip_charges_tab,
                   p_stop_charges_tab  => x_stop_charges_tab);

     fte_freight_pricing_util.unset_method(l_log_level,l_method_name);

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);

    WHEN OTHERS THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
                fte_freight_pricing_util.set_exception(l_method_name,l_log_level,'g_others');
                FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
                FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_method_name);
  END TL_Core_Multiple;



END FTE_TL_CORE;

/
