--------------------------------------------------------
--  DDL for Package Body FTE_TRIP_RATING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_TRIP_RATING_GRP" AS
/* $Header: FTEGTRRB.pls 120.11 2005/08/22 14:47:10 susurend ship $ */

   G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_TRIP_RATING_GRP';


SORT_TYPE_RL CONSTANT NUMBER :=1;
SORT_TYPE_UI CONSTANT NUMBER :=2;

DELIVERY_TYPE_STANDARD CONSTANT NUMBER :=1;
DELIVERY_TYPE_CONSOL CONSTANT NUMBER :=2;
DELIVERY_TYPE_CHILD CONSTANT NUMBER :=3;

   TYPE trip_info_rec IS RECORD
   (
          trip_id                         NUMBER,
          name                            VARCHAR2(30),
          planned_flag                    VARCHAR2(1),
          status_code                     VARCHAR2(2),
          carrier_id                      NUMBER,
          ship_method_code                VARCHAR2(30),
          service_level                   VARCHAR2(30),
          mode_of_transport               VARCHAR2(30),
          lane_id                         NUMBER,
          schedule_id                     NUMBER,
          load_tender_status              wsh_trips.load_tender_status%TYPE,
          tp_plan_name                    wsh_trips.tp_plan_name%TYPE,
          move_id                         NUMBER
    );

   TYPE trip_info_tab IS TABLE OF trip_info_rec INDEX BY BINARY_INTEGER;

   CURSOR c_trip_info(c_trip_id NUMBER)
   IS
   SELECT wt.trip_id,
          wt.name,
          wt.planned_flag,
          wt.status_code,
          wt.carrier_id,
          wt.ship_method_code,
          wt.service_level,
          wt.mode_of_transport,
          wt.lane_id,
          wt.schedule_id,
          wt.load_tender_status,
          wt.tp_plan_name,
          ftm.move_id
   FROM   wsh_trips wt, fte_trip_moves ftm
   WHERE  wt.trip_id = c_trip_id
   AND    wt.trip_id = ftm.trip_id (+) ;


   g_finished_success  EXCEPTION;

PROCEDURE Compare_Sort_Value(
	p_value1 IN Sort_Value_Rec_Type,
	p_value2 IN Sort_Value_Rec_Type,
	x_result OUT NOCOPY VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2)
IS

i NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

l_warning_count 	NUMBER:=0;

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Compare_Sort_Value','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	x_result:='=';
	i:=p_value1.value.FIRST;

	-- p_value1, p_value2 should have the same fields existing

	WHILE((i IS NOT NULL) AND (x_result='='))
	LOOP
		IF (p_value1.value.EXISTS(i) AND p_value2.value.EXISTS(i))
		THEN
			IF((p_value1.value(i) IS NULL ) AND (p_value2.value(i) IS NULL))
			THEN
				NULL;

			ELSIF((p_value1.value(i) IS NOT NULL ) AND (p_value2.value(i) IS NULL))
			THEN
				--not null < null

				x_result:='<';

			ELSIF((p_value1.value(i) IS NULL ) AND (p_value2.value(i) IS NOT NULL))
			THEN

				--null > not  null

				x_result:='>';

			ELSIF(p_value1.value(i) <p_value2.value(i))
			THEN
				x_result:='<';

			ELSIF(p_value1.value(i) > p_value2.value(i))
			THEN
				x_result:='>';

			ELSIF(p_value1.value(i) = p_value2.value(i))
			THEN
				NULL;

			END IF;


		END IF;

		i:=p_value1.value.NEXT(i);

	END LOOP;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Compare_Sort_Value');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION



   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Compare_Sort_Value',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Compare_Sort_Value');




END Compare_Sort_Value;



PROCEDURE Partition(
	p_values_tab IN Sort_Value_Tab_Type,
	p_low_index IN NUMBER,
	p_hi_index IN NUMBER,
	p_sort_type IN VARCHAR2,--To support variations in the future
	x_sorted_index  IN OUT NOCOPY dbms_utility.number_array,
	x_partition_index OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2)
IS

i NUMBER;
j NUMBER;
l_pivot Sort_Value_Rec_Type;
l_result VARCHAR2(1);
l_temp NUMBER;

l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

l_warning_count 	NUMBER:=0;

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Partition','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	j:=p_hi_index+1;
	i:=p_low_index-1;
	x_partition_index:=p_low_index;
	l_pivot:=p_values_tab(x_sorted_index(x_partition_index));
	WHILE(i<j)
	LOOP

		l_result:='>';
		WHILE((l_result='>') AND (j>=i))
		LOOP
			j:=j-1;

			Compare_Sort_Value(
				p_value1=>p_values_tab(x_sorted_index(j)),
				p_value2=>l_pivot ,
				x_result=> l_result,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			  THEN
			       raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_compare_fail;

			  END IF;
			END IF;




		END LOOP;

		l_result:='<';
		WHILE((l_result='<') AND (i<=j))
		LOOP
			i:=i+1;

			Compare_Sort_Value(
				p_value1=>p_values_tab(x_sorted_index(i)),
				p_value2=>l_pivot ,
				x_result=> l_result,
				x_return_status=>l_return_status);


			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
			  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			  THEN
			       raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_compare_fail;

			  END IF;
			END IF;




		END LOOP;


		IF (i < j)
		THEN

			l_temp:=x_sorted_index(j);
			x_sorted_index(j):=x_sorted_index(i);
			x_sorted_index(i):=l_temp;


		END IF;




	END LOOP;


	x_partition_index:=j;



        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Partition');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_quicksort_compare_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Partition',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_quicksort_compare_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Partition');



   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Partition',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Partition');




END Partition;



PROCEDURE Quick_Sort(
	p_values_tab IN Sort_Value_Tab_Type,
	p_low_index IN NUMBER,
	p_hi_index IN NUMBER,
	p_sort_type IN VARCHAR2,--To support variations in the future
	x_sorted_index  IN OUT NOCOPY dbms_utility.number_array,
	x_return_status OUT NOCOPY VARCHAR2)
IS

l_partition_index NUMBER;



l_return_status VARCHAR2(1);

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

l_warning_count 	NUMBER:=0;

BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Quick_Sort','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	IF(p_low_index < p_hi_index)
	THEN

		Partition(
			p_values_tab=>p_values_tab,
			p_low_index=>p_low_index,
			p_hi_index=>p_hi_index,
			p_sort_type=>p_sort_type,
			x_sorted_index=>x_sorted_index,
			x_partition_index=>l_partition_index,
			x_return_status=>l_return_status);

	      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      	THEN
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		  THEN
		       raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_partition_fail;

		  END IF;
	      	END IF;

		Quick_Sort(
			p_values_tab=>p_values_tab,
			p_low_index=>p_low_index,
			p_hi_index=>l_partition_index,
			p_sort_type=>p_sort_type,
			x_sorted_index=>x_sorted_index,
			x_return_status=>l_return_status);
	      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      	THEN
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		  THEN
		       raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_fail;

		  END IF;
	      	END IF;


		Quick_Sort(
			p_values_tab=>p_values_tab,
			p_low_index=>l_partition_index+1,
			p_hi_index=>p_hi_index,
			p_sort_type=>p_sort_type,
			x_sorted_index=>x_sorted_index,
			x_return_status=>l_return_status);
	      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      	THEN
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		  THEN
		       raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_fail;

		  END IF;
	      	END IF;



	END IF;


        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Quick_Sort');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_quicksort_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Quick_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_quicksort_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Quick_Sort');


   WHEN FTE_FREIGHT_PRICING_UTIL.g_quicksort_partition_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Quick_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_quicksort_partition_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Quick_Sort');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Quick_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Quick_Sort');



END Quick_Sort;


PROCEDURE Sort(
	p_values_tab IN Sort_Value_Tab_Type,
	p_sort_type IN VARCHAR2,--To support variations in the future
	x_sorted_index  OUT NOCOPY dbms_utility.number_array,
	x_return_status OUT NOCOPY VARCHAR2)

IS
l_return_status VARCHAR2(1);

i NUMBER;

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

l_warning_count 	NUMBER:=0;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Sort','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	i:=p_values_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		x_sorted_index(i):=i;
		i:=p_values_tab.NEXT(i);
	END LOOP;


	IF (p_values_tab.COUNT > 1)
	THEN


		Quick_Sort(
			p_values_tab=>p_values_tab,
			p_low_index=>p_values_tab.FIRST,
			p_hi_index=>p_values_tab.LAST,
			p_sort_type=>NULL,--To support variations in the future
			x_sorted_index=>x_sorted_index,
			x_return_status=>l_return_status);

	      	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      	THEN
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		  THEN
		       raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_fail;

		  END IF;
	      	END IF;



	END IF;

        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Sort');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

EXCEPTION


   WHEN FTE_FREIGHT_PRICING_UTIL.g_quicksort_fail THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_quicksort_fail');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Sort');


   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exception('Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Sort');


END Sort;




PROCEDURE Compare_Trip_Rates (
	             p_api_version              IN  NUMBER DEFAULT 1.0,
	             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	             p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
	             p_trip_id                  IN  NUMBER DEFAULT NULL,
	             p_lane_sched_id_tab        IN  FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	             p_lane_sched_tab           IN  FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	             p_mode_tab                 IN  FTE_CODE_TAB_TYPE,
	             p_service_type_tab         IN  FTE_CODE_TAB_TYPE,
	      	     p_vehicle_type_tab      	IN  FTE_ID_TAB_TYPE,
	             p_dep_date                 IN  DATE  DEFAULT sysdate,
	             p_arr_date                 IN  DATE  DEFAULT sysdate,
	             p_event                    IN  VARCHAR2 DEFAULT 'FTE_TRIP_COMP',
	             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	             x_request_id               OUT NOCOPY NUMBER,
	             x_lane_sched_id_tab        OUT  NOCOPY FTE_ID_TAB_TYPE, -- lane_ids or schedule_ids
	             x_lane_sched_tab           OUT  NOCOPY FTE_CODE_TAB_TYPE, -- 'L' or 'S'  (Lane or Schedule)
	             x_vehicle_type_tab    	OUT  NOCOPY FTE_ID_TAB_TYPE,--Vehicle Type Id
	             x_mode_tab                 OUT  NOCOPY FTE_CODE_TAB_TYPE,
	             x_service_type_tab         OUT NOCOPY FTE_CODE_TAB_TYPE,
	             x_sum_rate_tab             OUT NOCOPY FTE_ID_TAB_TYPE,
	             x_sum_rate_curr_tab        OUT NOCOPY FTE_CODE_TAB_TYPE,
	             x_return_status            OUT NOCOPY  VARCHAR2,
	             x_msg_count                OUT NOCOPY  NUMBER,
	             x_msg_data                 OUT NOCOPY  VARCHAR2) IS

      CURSOR c_get_req_id IS
      SELECT fte_pricing_comp_request_s.nextval
      FROM   sys.dual;

      i                    NUMBER :=0;
      L                    NUMBER :=0;
      S                    NUMBER :=0;
      j                    NUMBER :=0;
      l_request_id         NUMBER;

      -- variables for shipment_price_compare
      l_lane_id_tab        wsh_util_core.id_tab_type;
      l_sched_id_tab       wsh_util_core.id_tab_type;
      l_service_lane_tab   wsh_util_core.column_tab_type;
      l_service_sched_tab  wsh_util_core.column_tab_type;
      l_lane_price_tab     wsh_util_core.id_tab_type;
      l_lane_curr_tab      wsh_util_core.column_tab_type;
      l_sched_price_tab    wsh_util_core.id_tab_type;
      l_sched_curr_tab     wsh_util_core.column_tab_type;
      l_lane_xref          dbms_utility.number_array;
      l_sched_xref         dbms_utility.number_array;

      -- variables for tl_trip_price_compare
      l_lane_rows         dbms_utility.number_array;
      l_schedule_rows     dbms_utility.number_array;
      l_vehicle_rows      dbms_utility.number_array;
      l_lane_sched_sum_rows   dbms_utility.number_array;
      l_lane_sched_curr_rows  dbms_utility.name_array;
      l_tl_xref           dbms_utility.number_array;

      l_exploded_lane_rows         dbms_utility.number_array;
      l_exploded_schedule_rows     dbms_utility.number_array;
      l_exploded_vehicle_rows      dbms_utility.number_array;
      l_exploded_ref_rows      dbms_utility.number_array;

      l_output_count NUMBER;
      l_ref NUMBER;
      k	NUMBER;

      l_return_status VARCHAR2(1);
      l_warn_flag     VARCHAR2(1) := 'N';
      l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;

   PRAGMA AUTONOMOUS_TRANSACTION;

   BEGIN
      SAVEPOINT COMPARE_TRIP_RATES;
      x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      IF(p_init_prc_log='Y')
      THEN

	      FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
							    x_return_status  => l_return_status );

	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		       x_return_status  :=  l_return_status;
		       RETURN;
		  END IF;
	      ELSE
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
	      END IF;
       END IF;

      FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
      FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Compare_Trip_Rates','start');

          -- generate comp request id
          -- loop over the lane/schedules
          -- collect all LTL/PARCEL lanes together
          -- collect all TL lanes togehter
          -- accordingly call TL or LTL/Parcel api in batches
          -- return rate summary and currency
          -- return warning if only some lanes fail



      OPEN c_get_req_id;
      FETCH c_get_req_id INTO l_request_id;
      CLOSE c_get_req_id;
      x_request_id := l_request_id;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>2 l_request_id='||l_request_id);

      L := 0; S := 0; j :=0;
      IF (p_lane_sched_id_tab.COUNT > 0) THEN
      FOR i IN p_lane_sched_id_tab.FIRST .. p_lane_sched_id_tab.LAST
      LOOP
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,' '||i||' '||p_mode_tab(i)||' '||p_lane_sched_tab(i)||' '||p_lane_sched_id_tab(i));
         IF (p_mode_tab(i) <> 'TRUCK' ) THEN
           IF (p_lane_sched_tab(i) = 'L') THEN
               L := L + 1;
               l_lane_id_tab(L)       := p_lane_sched_id_tab(i);
               l_service_lane_tab(L)  := p_service_type_tab(i);
               l_lane_xref(L)         := i; -- xref to input index
           ELSIF (p_lane_sched_tab(i) = 'S') THEN
               S := S + 1;
               l_sched_id_tab(S)       := p_lane_sched_id_tab(i);
               l_service_sched_tab(S)  := p_service_type_tab(i);
               l_sched_xref(S)         := i; -- xref to input index
           END IF;

         ELSIF (p_mode_tab(i) = 'TRUCK' ) THEN
           j := j + 1;
           IF (p_lane_sched_tab(i) = 'L') THEN
               l_lane_rows(j)          := p_lane_sched_id_tab(i);
               l_schedule_rows(j)      := NULL;
           ELSIF (p_lane_sched_tab(i) = 'S') THEN
               l_lane_rows(j)          := NULL;
               l_schedule_rows(j)      := p_lane_sched_id_tab(i);
           END IF;


	   l_vehicle_rows(j):=p_vehicle_type_tab(i);


	   IF (l_vehicle_rows(j) = -1)
	   THEN
		l_vehicle_rows(j):=NULL;

	   END IF;


           l_tl_xref(j)      := i; -- xref to input index
         END IF;

      END LOOP;
      END IF;




      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_lane_id_tab.COUNT'||l_lane_id_tab.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_sched_id_tab.COUNT'||l_sched_id_tab.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_lane_rows.COUNT'||l_lane_rows.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_schedule_rows.COUNT'||l_schedule_rows.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_tl_xref.COUNT'||l_tl_xref.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>3');


      --FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'x_sum_rate_tab.COUNT='||x_sum_rate_tab.COUNT);
      --FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'x_sum_rate_curr_tab.COUNT='||x_sum_rate_curr_tab.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>4');
      -- Call LTL/PARCEL API

      L :=0; S:=0; j:=0;

      IF (l_lane_id_tab.COUNT >0 OR l_sched_id_tab.COUNT >0) THEN

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>5');
            FTE_FREIGHT_PRICING.shipment_price_compare_pvt (
              p_delivery_id             => NULL,
              p_trip_id                 => p_trip_id,
              p_lane_id_tab             => l_lane_id_tab,
              p_sched_id_tab            => l_sched_id_tab,
              p_service_lane_tab        => l_service_lane_tab,
              p_service_sched_tab       => l_service_sched_tab,
              p_dep_date                => p_dep_date,
              p_arr_date                => p_arr_date,
              x_sum_lane_price_tab      => l_lane_price_tab,
              x_sum_lane_price_curr_tab => l_lane_curr_tab,
              x_sum_sched_price_tab     => l_sched_price_tab,
              x_sum_sched_price_curr_tab =>l_sched_curr_tab,
              x_request_id              => l_request_id,
              x_return_status           => l_return_status );

              -- Error checking here
              -- For now only unexpected errors returned cause this procedure to fail
              -- However, we can go more granular, and fail even on certain
              -- errors caused in the child procedures

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_return_status='||l_return_status);
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
              THEN
                 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                 THEN
                    raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
                 ELSE
                    l_warn_flag := 'Y';
                 END IF;
              END IF;
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_lane_price_tab.COUNT='||l_lane_price_tab.COUNT);
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_sched_price_tab.COUNT='||l_sched_price_tab.COUNT);


      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>>');
      -- Call TL API



      IF (l_lane_rows.COUNT > 0) THEN



	FTE_TL_RATING.Get_Vehicles_For_LaneSchedules(
		p_trip_id	=>p_trip_id,
		p_lane_rows	=>l_lane_rows,
		p_schedule_rows =>l_schedule_rows,
		p_vehicle_rows	=>l_vehicle_rows,
		x_vehicle_rows  =>l_exploded_vehicle_rows,
		x_lane_rows 	=>l_exploded_lane_rows,
		x_schedule_rows =>l_exploded_schedule_rows,
		x_ref_rows	=>l_exploded_ref_rows,
		x_return_status =>l_return_status);

	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	      THEN
		 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
		 THEN
		    raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
		 ELSE
		    l_warn_flag := 'Y';
		 END IF;
	      END IF;





      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>6');
            FTE_TL_RATING.TL_TRIP_PRICE_COMPARE(
	      p_wsh_trip_id             => p_trip_id,
	      p_lane_rows               => l_exploded_lane_rows,
	      p_schedule_rows           => l_exploded_schedule_rows,
	      p_vehicle_rows            => l_exploded_vehicle_rows,
              x_request_id              => l_request_id,
              x_lane_sched_sum_rows     => l_lane_sched_sum_rows,
              x_lane_sched_curr_rows    => l_lane_sched_curr_rows,
	      x_return_status           => l_return_status );

              -- Error checking here
              -- For now only unexpected errors returned cause this procedure to fail
              -- However, we can go more granular, and fail even on certain
              -- errors caused in the child procedures

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_return_status='||l_return_status);
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
              THEN
                 IF l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR
                 THEN
                    raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
                 ELSE
                    l_warn_flag := 'Y';
                 END IF;
              END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>l_lane_sched_sum_rows.COUNT='||l_lane_sched_sum_rows.COUNT);

      END IF;

      --populate output from both TL and non-TL

      l_output_count:=p_lane_sched_id_tab.COUNT;
      IF (l_lane_rows.COUNT > 0)
      THEN
      	l_output_count:=l_output_count+ l_exploded_ref_rows.COUNT-l_lane_rows.COUNT;
      END IF;

      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Op count:'||l_output_count);

      -- initialize output nested tables
      IF (p_lane_sched_id_tab.COUNT > 0 )
      THEN

      	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Init op tables');

	      x_sum_rate_tab := FTE_ID_TAB_TYPE(0);
	      x_sum_rate_curr_tab := FTE_CODE_TAB_TYPE('NULL');
	      -- init all elements  the tables with 0 and 'NULL' resp.

	      x_lane_sched_id_tab:=FTE_ID_TAB_TYPE(0);
	      x_lane_sched_tab:=FTE_CODE_TAB_TYPE('NULL');
	      x_vehicle_type_tab:=FTE_ID_TAB_TYPE(0);
	      x_mode_tab:=FTE_CODE_TAB_TYPE('NULL');
	      x_service_type_tab:=FTE_CODE_TAB_TYPE('NULL');


	      x_sum_rate_tab.EXTEND(l_output_count-1,1);
	      x_sum_rate_curr_tab.EXTEND(l_output_count-1,1);

	      x_lane_sched_id_tab.EXTEND(l_output_count-1,1);
	      x_lane_sched_tab.EXTEND(l_output_count-1,1);
	      x_vehicle_type_tab.EXTEND(l_output_count-1,1);
	      x_mode_tab.EXTEND(l_output_count-1,1);
	      x_service_type_tab.EXTEND(l_output_count-1,1);

	      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Init op tables End');

      END IF;

      L :=l_lane_price_tab.FIRST;
      S:=l_sched_price_tab.FIRST;
      j:=l_lane_rows.FIRST;
      i:=p_lane_sched_id_tab.FIRST;
      k:=x_sum_rate_tab.FIRST;
      l_ref:=l_exploded_ref_rows.FIRST;

      WHILE(k<=l_output_count)
      LOOP
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Op index:'||k);

         IF (p_mode_tab(i) <> 'TRUCK' )
         THEN
           IF (p_lane_sched_tab(i) = 'L')
           THEN

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Lane:');

	       IF ((l_lane_price_tab.EXISTS(L)) AND (l_lane_curr_tab.EXISTS(L)))
	       THEN
		       x_sum_rate_tab(k)      := l_lane_price_tab(L);
		       x_sum_rate_curr_tab(k) := l_lane_curr_tab(L);
	       END IF;

	       x_lane_sched_id_tab(k):=p_lane_sched_id_tab(i);
	       x_lane_sched_tab(k):=p_lane_sched_tab(i);
	       x_vehicle_type_tab(k):=p_vehicle_type_tab(i);
	       x_mode_tab(k):=p_mode_tab(i);
	       x_service_type_tab(k):=p_service_type_tab(i);


               L := L + 1;
               k:=k+1;

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Lane ENd:');

           ELSIF (p_lane_sched_tab(i) = 'S')
           THEN

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Schedule:');

               IF((l_sched_price_tab.EXISTS(S)) AND (l_sched_curr_tab.EXISTS(S)))
	       THEN

		       x_sum_rate_tab(k)      := l_sched_price_tab(S);
		       x_sum_rate_curr_tab(k) := l_sched_curr_tab(S);
	       END IF;
	       x_lane_sched_id_tab(k):=p_lane_sched_id_tab(i);
	       x_lane_sched_tab(k):=p_lane_sched_tab(i);
	       x_vehicle_type_tab(k):=p_vehicle_type_tab(i);
	       x_mode_tab(k):=p_mode_tab(i);
	       x_service_type_tab(k):=p_service_type_tab(i);



               S := S + 1;
               k:=k+1;

               FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Non TL Schedule End:');

           END IF;

         ELSIF (p_mode_tab(i) = 'TRUCK' )
         THEN

              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL :');
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_ref'||l_ref);
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'j'||j);
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_exploded_ref_rows count'||l_exploded_ref_rows.COUNT);

	       WHILE(l_exploded_ref_rows.EXISTS(l_ref) AND l_exploded_ref_rows(l_ref)=j)
	       LOOP
		      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_exploded_ref_rows(l_ref)'||l_exploded_ref_rows(l_ref));

		      --FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'l_lane_sched_sum_rows(l_ref)'||l_lane_sched_sum_rows(l_ref));


	       	       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 1:');
	       	       x_sum_rate_tab(k):=-1;
		       IF (l_lane_sched_sum_rows.EXISTS(l_ref))
		       THEN
			x_sum_rate_tab(k)       := nvl(l_lane_sched_sum_rows(l_ref),-1);
		       END IF;

		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 2:');

		       x_sum_rate_curr_tab(k):='NULL';
		       IF (l_lane_sched_curr_rows.EXISTS(l_ref))
		       THEN
			x_sum_rate_curr_tab(k)  := nvl(l_lane_sched_curr_rows(l_ref),'NULL');
		       END IF;

		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 3:');

		       x_lane_sched_id_tab(k):=p_lane_sched_id_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 4:');
		       x_lane_sched_tab(k):=p_lane_sched_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 5:');
		       IF (l_exploded_vehicle_rows.EXISTS(l_ref))
		       THEN
			x_vehicle_type_tab(k):=l_exploded_vehicle_rows(l_ref);
		       END IF;
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 6:');
		       x_mode_tab(k):=p_mode_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 7:');
		       x_service_type_tab(k):=p_service_type_tab(i);
		       FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL 8:');

                  --FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                  --' '||l_ref||'-'||i||'-'||l_lane_sched_sum_rows(l_ref)||'-'||l_lane_sched_curr_rows(l_ref));


		       k:=k+1;

		       l_ref:=l_ref+1;
	       END LOOP;

	   j := j + 1;

	   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'TL End:');

	 END IF;


      	i:=i+1;
      END LOOP;


      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>7');
      IF (l_warn_flag = 'Y') THEN
              FTE_FREIGHT_PRICING_UTIL.set_trip_prc_comp_exit_warn;
	   --Added to ensure return status is warning if l_warn_flag=Y
	   x_return_status :=WSH_UTIL_CORE.G_RET_STS_WARNING;

      END IF;
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>8 l_warn_flag='||l_warn_flag);
      x_request_id := l_request_id;

      IF (x_sum_rate_tab.COUNT > 0) THEN
      FOR i IN x_sum_rate_tab.FIRST .. x_sum_rate_tab.LAST
      LOOP
      FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
       ' '||x_lane_sched_id_tab(i)||' '||x_lane_sched_tab(i)||' '||x_mode_tab(i)||' '||x_service_type_tab(i)||' '
     ||x_vehicle_type_tab(i)||' '||x_sum_rate_tab(i)||' '||x_sum_rate_curr_tab(i) );
      END LOOP;
      END IF;

FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.1');
   FND_MSG_PUB.Count_And_Get
   (
      p_count  => x_msg_count,
      p_data  =>  x_msg_data,
      p_encoded => FND_API.G_FALSE
   );

   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.2');
   FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Compare_Trip_Rates');
   FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.3');

   IF(p_init_prc_log='Y')
   THEN
   	FTE_FREIGHT_PRICING_UTIL.close_logs;
   END IF;



    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.4');

    COMMIT;  --  Commit Autonomous transaction

/*
   IF FND_API.to_Boolean( p_commit )
    THEN
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.5');
        COMMIT;  --  Commit Autonomous transaction
    ELSE
    FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.6');
    	ROLLBACK; --TO COMPARE_TRIP_RATES;

    END IF;
*/

FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'>>9.7');
   EXCEPTION

   WHEN FTE_FREIGHT_PRICING_UTIL.g_unexp_err THEN
        ROLLBACK;-- TO COMPARE_TRIP_RATES;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Compare_Trip_Rates','g_others');
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Compare_Trip_Rates');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


   WHEN others THEN
        ROLLBACK;-- TO COMPARE_TRIP_RATES;
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Compare_Trip_Rates','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Compare_Trip_Rates');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


END Compare_Trip_Rates;



   PROCEDURE Compare_Trip_Rates (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_trip_id                  IN  NUMBER DEFAULT NULL,
             p_lane_sched_id_tab        IN  FTE_ID_TAB_TYPE,
             p_lane_sched_tab           IN  FTE_CODE_TAB_TYPE,
             p_mode_tab                 IN  FTE_CODE_TAB_TYPE,
             p_service_type_tab         IN  FTE_CODE_TAB_TYPE,
             p_vehicle_id_tab           IN  FTE_ID_TAB_TYPE,
             p_dep_date                 IN  DATE  DEFAULT sysdate,
             p_arr_date                 IN  DATE  DEFAULT sysdate,
             p_event                    IN  VARCHAR2 DEFAULT 'FTE_TRIP_COMP',
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             x_request_id               OUT NOCOPY NUMBER,
             x_sum_rate_tab             OUT NOCOPY FTE_ID_TAB_TYPE,
             x_sum_rate_curr_tab        OUT NOCOPY FTE_CODE_TAB_TYPE,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2)
   IS

   BEGIN

	NULL;

   END Compare_Trip_Rates;

--
-- Procedure : Rate_Trip_Int
--             This is an internal procedure. It calls appropriate apis to rate the
--             trip based upon the parameters p_rate_mode and p_event
--             Assumes that most validations regarding the event have been done
--             by the calling procedure
--

PROCEDURE Rate_Trip_Int (
             p_trip_info_rec            trip_info_rec,
             p_rate_mode                IN VARCHAR2 DEFAULT 'REGULAR',
             p_event                    IN VARCHAR2,
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2)
IS

      l_api_version	        CONSTANT NUMBER := 1.0;
      l_api_name                CONSTANT VARCHAR2(30)   := 'RATE_TRIP_INT';
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_return_status           VARCHAR2(1);
      l_return_status_1         VARCHAR2(1);

      l_dummy_fc_tab            FTE_FREIGHT_PRICING.Freight_Cost_Temp_Tab_Type;

      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);

      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_commit                 VARCHAR2(100) := FND_API.G_FALSE;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_TRIP_INT';
BEGIN

    SAVEPOINT  RATE_TRIP_INT;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
--
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;
--
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_trip_id'|| p_trip_info_rec.trip_id,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_event'|| p_event,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_rate_mode'|| p_rate_mode,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'trip_id='||p_trip_info_rec.trip_id);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_event='||p_event);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_rate_mode='||p_rate_mode);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'mode_of_trans='||p_trip_info_rec.mode_of_transport);

   IF ( p_rate_mode = 'TP-REL') THEN
      -- irrespective of event, the same apis can be called to rate tp released trips
      -- when they are rated the first time
      -- that is why we did not check for the p_event in this case

      -- redirect based upon mode of transport
      -- lane_id is assumed to be present

      IF (p_trip_info_rec.mode_of_transport='TRUCK') THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling tl_rate_trip ');
         -- call TL rating

         -- TO DO: No reprice flag checking

            FTE_TL_RATING.tl_rate_trip (
                   p_trip_id           => p_trip_info_rec.trip_id,
                   p_output_type       => 'M',
                   x_output_cost_tab   => l_dummy_fc_tab,
                   x_return_status     => l_return_status);

           -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;

      ELSE -- non TL
         -- call shipment_price_consolidate
         -- No reprice flag checking

           FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling shipment_price_consolidate ');
           FTE_FREIGHT_PRICING.shipment_price_consolidate (
                       p_segment_id              => p_trip_info_rec.trip_id,
                       p_check_reprice_flag      => 'N',
                       x_return_status           => l_return_status);

           -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;

      END IF;


   END IF;


   IF (p_event = 'SHIP-CONFIRM' AND
            p_rate_mode = 'REGULAR') THEN

     -- call Rate_Delivery
     -- it does reprice flag checking by default
     -- it can handle both TL and non-TL
     -- can also do LCSS where eligible

      IF (p_trip_info_rec.lane_id IS NOT NULL) THEN

         IF (p_trip_info_rec.mode_of_transport='TRUCK') THEN
            -- call TL rate trip with reprice checking
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling tl_rate_trip ');

            FTE_TL_RATING.tl_rate_trip (
                   p_trip_id           => p_trip_info_rec.trip_id,
                   p_output_type       => 'M',
                   p_check_reprice_flag => 'Y',
                   x_output_cost_tab   => l_dummy_fc_tab,
                   x_return_status     => l_return_status);

           -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;


         ELSE
            -- call shipment_price_consolidate with reprice checking

           FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling shipment_price_consolidate ');
           FTE_FREIGHT_PRICING.shipment_price_consolidate (
                       p_segment_id              => p_trip_info_rec.trip_id,
                       p_check_reprice_flag      => 'Y',
                       x_return_status           => l_return_status);

           -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;


         END IF;

      ELSE
         -- lane_id is null
         -- route this request through LCSS

        FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling Rate_Delivery ');
        FTE_FREIGHT_RATING_DLVY_GRP.Rate_Delivery  (
			     p_api_version		=> 1,
			     p_init_msg_list		=> FND_API.G_FALSE,
			     p_delivery_id              => null,
			     p_trip_id			=> p_trip_info_rec.trip_id,
                             p_action                   => 'RATE',
                             p_commit                  	=> FND_API.G_FALSE,
                             p_init_prc_log             => 'N',
                             x_return_status            => l_return_status,
		       	     x_msg_count	        => x_msg_count,
			     x_msg_data	                => x_msg_data );

        -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;
      END IF;

   END IF;

   IF (p_event = 'RE-RATING' AND p_rate_mode = 'RE-RATE') THEN

      IF (p_trip_info_rec.mode_of_transport='TRUCK') THEN
         -- call TL rating

            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling tl_rate_trip ');
         --  No reprice flag checking

            FTE_TL_RATING.tl_rate_trip (
                   p_trip_id           => p_trip_info_rec.trip_id,
                   p_output_type       => 'M',
                   -- p_check_reprice_flag =>'N',
                   x_output_cost_tab   => l_dummy_fc_tab,
                   x_return_status     => l_return_status);

           -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;

      ELSE -- non TL
         -- call shipment_price_consolidate
         -- No reprice flag checking

           FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'calling shipment_price_consolidate ');
           FTE_FREIGHT_PRICING.shipment_price_consolidate (
                       p_segment_id              => p_trip_info_rec.trip_id,
                       p_check_reprice_flag      => 'N',
                       x_return_status           => l_return_status);

           -- error checking
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_ERROR)
             THEN
                   RAISE FND_API.G_EXC_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING )
             THEN
                   x_return_status := l_return_status;
             END IF;

      END IF;

   END IF;

    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
  EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
	WHEN OTHERS THEN
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.Rate_Trip_Int');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
--
END Rate_Trip_Int;



-- +======================================================================+
--   Procedure :
--           Rate_Trip
--
--   Description:
--           Rate Trip from various event points
--   Inputs:
--           p_action_params            => parameters identifying the
--                                         action to be performed
--                    -> caller -> 'FTE','WSH'
--                    -> event  -> 'TP-RELEASE','SHIP-CONFIRM','RE-RATING'
--                    -> action -> 'RATE'
--                    -> trip_id_list -> valid list of wsh trip_id
--           p_commit                   => FND_API.G_FALSE / G_TRUE
--   Output:
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--
--
--   DB:
--
-- +======================================================================+


PROCEDURE Rate_Trip (
             p_api_version              IN  NUMBER DEFAULT 1.0,
             p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
             p_action_params            IN  FTE_TRIP_RATING_GRP.action_param_rec,
             p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
	     p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
             x_return_status            OUT NOCOPY  VARCHAR2,
             x_msg_count                OUT NOCOPY  NUMBER,
             x_msg_data                 OUT NOCOPY  VARCHAR2)
IS

      CURSOR tp_rel_param IS
      SELECT auto_rate_tp_rel_trips
      FROM  wsh_global_parameters;


      l_api_version	        CONSTANT NUMBER := 1.0;
      l_api_name                CONSTANT VARCHAR2(30)   := 'RATE_TRIP';
      l_log_level               NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
      l_return_status           VARCHAR2(1);
      l_return_status_1         VARCHAR2(1);

      l_trip_info_rec           trip_info_rec;
      l_tp_rel_rate_event       VARCHAR2(30);
      -- internal flag
      l_rate_mode               VARCHAR2(30) := null;
      i                         NUMBER;
      j                         NUMBER;
      l_rated_move_ids          WSH_UTIL_CORE.id_tab_type;

      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(32767);

      l_number_of_errors          NUMBER;
      l_number_of_warnings	    NUMBER;
      l_commit                 VARCHAR2(100) := FND_API.G_FALSE;
      l_debug_on CONSTANT BOOLEAN := WSH_DEBUG_SV.is_debug_enabled;
      l_module_name CONSTANT VARCHAR2(100) := 'fte.plsql.' || G_PKG_NAME || '.' || 'RATE_TRIP';

      l_warn_count NUMBER :=0;
BEGIN

    SAVEPOINT  RATE_TRIP;
--
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call
                         (
                           l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME
                          )
    THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
      		FND_MSG_PUB.initialize;
    END IF;

    x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;
--
    IF l_debug_on THEN
      wsh_debug_sv.push(l_module_name);
    END IF;
--
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_action_params.trip_id_list.COUNT '|| p_action_params.trip_id_list.COUNT,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_action_params.caller '|| p_action_params.caller,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_action_params.event '|| p_action_params.event,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_action_params.action '|| p_action_params.action,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name,
	  'p_commit '|| p_commit,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;

  IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.initialize_logging( x_return_status  => l_return_status );

    IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) and
       (l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_INIT_LOG_FAIL',
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
    ELSE
      FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Initialize Logging successful ');
    END IF;
  END IF;

    FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
    FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_action_params->');
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'  trip_id_list.COUNT='||p_action_params.trip_id_list.COUNT);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'  event='||p_action_params.event);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'  caller='||p_action_params.caller);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'  action='||p_action_params.action);
    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'p_commit='||p_commit);

    IF (p_action_params.trip_id_list.COUNT = 0
        OR p_action_params.event IS NULL
        OR p_action_params.caller IS NULL
        OR p_action_params.action IS NULL ) THEN

               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_TRIP_RATING_INV_PARAMS',
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--

	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
    END IF;

    -- check global parameters to see if rating should be done for tp released
    -- trips at this event

    OPEN tp_rel_param;
    FETCH tp_rel_param INTO l_tp_rel_rate_event;
    CLOSE tp_rel_param;

    IF (l_tp_rel_rate_event = 'S') THEN
      l_tp_rel_rate_event := 'SHIP-CONFIRM';
    ELSIF (l_tp_rel_rate_event = 'R') THEN
      l_tp_rel_rate_event := 'TP-RELEASE';
    ELSE
      l_tp_rel_rate_event := 'NONE';
    END IF;

     IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(
	  l_module_name, 'l_tp_rel_rate_event = '||l_tp_rel_rate_event,
	  WSH_DEBUG_SV.C_PROC_LEVEL);
     END IF;
     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'l_tp_rel_rate_event = '||l_tp_rel_rate_event);

    -- if calling event is TP-RELEASE, rating needs to be done only if
    -- global parameter is set to TP-RELEASE

    IF (p_action_params.event = 'TP-RELEASE'
        AND l_tp_rel_rate_event <> 'TP-RELEASE') THEN
            -- raise warning : rating is not required at this event
            -- exit
            l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Warning =FTE_TRP_RATING_RATE_NOT_REQ');
            FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
            (
             p_api_name           =>     l_module_name,
             p_api_return_status  =>     l_return_status,
             p_message_name       =>     'FTE_TRP_RATING_RATE_NOT_REQ',
             p_trip_id            =>     null,
             p_delivery_id        =>     null,
             p_delivery_leg_id    =>     null,
             x_number_of_errors   =>     l_number_of_errors,
             x_number_of_warnings =>     l_number_of_warnings,
             x_return_status      =>     l_return_status_1
            );
            --
            IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
            THEN
                RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
            THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
            THEN
                x_return_status := l_return_status_1;
                RAISE g_finished_success;
            END IF;
    END IF;

    -- Now loop over all trips in the input

    i := p_action_params.trip_id_list.FIRST;
    LOOP
         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'>>>trip_id='||p_action_params.trip_id_list(i));

       -- Get trip information from db
      OPEN c_trip_info(p_action_params.trip_id_list(i));
      FETCH c_trip_info INTO l_trip_info_rec;
      IF (c_trip_info%NOTFOUND) THEN
        -- raise exception
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_TRIP_RATING_INV_TRIP',
		  p_trip_id            =>     p_action_params.trip_id_list(i),
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;

      END IF;
      CLOSE c_trip_info;

      -- Check if this trip is part of a continuous move
      -- If it was already rated in an earlier iteration, don't rate

      IF (l_trip_info_rec.move_id IS NOT NULL) THEN
         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'move_id='||l_trip_info_rec.move_id);
         IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg( l_module_name, 'move_id = '||l_trip_info_rec.move_id,
	      WSH_DEBUG_SV.C_PROC_LEVEL);
         END IF;
         IF l_rated_move_ids.EXISTS(l_trip_info_rec.move_id)  THEN
            FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'move already rated -  next pass');
            IF l_debug_on THEN
               WSH_DEBUG_SV.logmsg( l_module_name, 'move already rated -  next pass',
	         WSH_DEBUG_SV.C_PROC_LEVEL);
            END IF;
            GOTO nextpass;
         END IF;
      END IF;


      -- Shipmethod is always required on trip

      IF ( l_trip_info_rec.carrier_id IS NULL
	  --OR l_trip_info_rec.ship_method_code IS NULL
          OR l_trip_info_rec.mode_of_transport IS NULL
          OR l_trip_info_rec.service_level IS NULL ) THEN

          -- raise error:  carrier info missing
               l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
               FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
		(
		  p_api_name           =>     l_module_name,
		  p_api_return_status  =>     l_return_status,
		  p_message_name       =>     'FTE_TRIP_RATING_MISS_CARR',
		  p_trip_id            =>     l_trip_info_rec.trip_id,
		  p_delivery_id        =>     null,
		  p_delivery_leg_id    =>     null,
		  x_number_of_errors   =>     l_number_of_errors,
		  x_number_of_warnings =>     l_number_of_warnings,
		  x_return_status      =>     l_return_status_1
		);
--
	        IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_ERROR;
	        ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
	        THEN
	        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                THEN
                       x_return_status := l_return_status_1;
	        END IF;
      END IF;

      IF (p_action_params.event = 'TP-RELEASE') THEN

         IF (l_trip_info_rec.tp_plan_name IS NOT NULL ) THEN
             -- OK to rate
             -- global parameter has already been validated earlier
             l_rate_mode := 'TP-REL';
         ELSE
            -- for now raise error : trip is not a tp released trip
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
                    (
                    p_api_name           =>     l_module_name,
                    p_api_return_status  =>     l_return_status,
                    p_message_name       =>     'FTE_TRIP_RATING_NOT_TP_REL',
                    p_trip_id            =>     l_trip_info_rec.trip_id,
                    p_delivery_id        =>     null,
                    p_delivery_leg_id    =>     null,
                    x_number_of_errors   =>     l_number_of_errors,
                    x_number_of_warnings =>     l_number_of_warnings,
                    x_return_status      =>     l_return_status_1
                    );
                    --
                    IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                       x_return_status := l_return_status_1;
                    END IF;
         END IF;

      END IF; -- event = TP-RELEASE


      IF (p_action_params.event = 'SHIP-CONFIRM') THEN

         -- check if this is a tp released trip
         -- and needs to be rated

         IF ( l_trip_info_rec.tp_plan_name IS NOT NULL  ) THEN

            IF (l_tp_rel_rate_event = 'SHIP-CONFIRM') THEN
                  -- OK to rate without reprice flag checking
                   l_rate_mode := 'TP-REL';
            ELSIF (l_tp_rel_rate_event = 'TP-RELEASE') THEN
                   -- Rate as a standard trip with reprice flag checking
                   -- We still don't allow LCSS on this trip
                   -- So lane_id cannot be null
                   l_rate_mode := 'REGULAR';
            ELSE
                   l_rate_mode := 'NONE';
                   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level, 'rate_mode='||l_rate_mode);
                   -- We can't rate this trip anytime
                   -- raise warning : rating not required for this trip
                   -- exit
                   FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,
                    'Warning =FTE_TRP_RATING_RATE_NOT_REQ');
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_WARNING;
                    FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
                    (
                    p_api_name           =>     l_module_name,
                    p_api_return_status  =>     l_return_status,
                    p_message_name       =>     'FTE_TRP_RATING_RATE_NOT_REQ',
                    p_trip_id            =>     l_trip_info_rec.trip_id,
                    p_delivery_id        =>     null,
                    p_delivery_leg_id    =>     null,
                    x_number_of_errors   =>     l_number_of_errors,
                    x_number_of_warnings =>     l_number_of_warnings,
                    x_return_status      =>     l_return_status_1
                    );
                    --
                    IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                       x_return_status := l_return_status_1;
                       l_warn_count := l_warn_count + 1;
                       -- RAISE g_finished_success;
                    END IF;
            END IF;

         ELSE  -- tp_plan_name IS NULL

             -- If this is a standard trip, rate it normally
             -- redirect to the existing api which does rating
             -- at ship confirm

             l_rate_mode := 'REGULAR';

         END IF;

      END IF; -- event = SHIP-CONFIRM

      -- Allow re-rating to be done with caller WSH this is for inbound
      IF ((p_action_params.event = 'RE-RATING'
          AND p_action_params.caller = 'FTE')
          OR
          (p_action_params.event = 'RE-RATING'
          AND p_action_params.caller = 'WSH'))
     THEN
             l_rate_mode := 'RE-RATE';
      END IF;

      -- Note :
      -- It is possible for a trip to not have lane information for SHIP-CONFIRM
      -- (Trip stop closing). The LCSS functionality can search for services
      -- in this case.
      -- However, for TP Released trips for any event we should have lane_id.
      -- Also, for RE-RATING event, we need lane_id.

      IF (l_trip_info_rec.lane_id IS NULL) THEN
          IF (p_action_params.event = 'SHIP-CONFIRM'
                  AND l_rate_mode = 'REGULAR'
                  AND l_trip_info_rec.tp_plan_name IS NULL)
          THEN
              -- ok to rate
              null;
          ELSE
                   -- lane_id is null
                   -- raise error : lane_id is missing on tp released trip
                    l_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
                    FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
                    (
                    p_api_name           =>     l_module_name,
                    p_api_return_status  =>     l_return_status,
                    p_message_name       =>     'FTE_TRIP_RATING_MISS_LANE',
                    p_trip_id            =>     l_trip_info_rec.trip_id,
                    p_delivery_id        =>     null,
                    p_delivery_leg_id    =>     null,
                    x_number_of_errors   =>     l_number_of_errors,
                    x_number_of_warnings =>     l_number_of_warnings,
                    x_return_status      =>     l_return_status_1
                    );
                    --
                    IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                       x_return_status := l_return_status_1;
                    END IF;

          END IF;
      END IF;


      IF l_debug_on THEN
            WSH_DEBUG_SV.logmsg( l_module_name,'tripId:'||l_trip_info_rec.trip_id||' mode: '||l_rate_mode
            ||' plan:'||l_trip_info_rec.tp_plan_name||' laneId:'||l_trip_info_rec.lane_id
            ||' modeTrans:'||l_trip_info_rec.mode_of_transport,
	      WSH_DEBUG_SV.C_PROC_LEVEL);
      END IF;
         -- call rate trip API
      IF (l_rate_mode IS NOT NULL AND l_rate_mode <> 'NONE') THEN

            -- rate trip accordingly
             Rate_Trip_Int (
                p_trip_info_rec            => l_trip_info_rec,
                p_rate_mode                => l_rate_mode,
                p_event                    => p_action_params.event,
                x_return_status            => l_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                 => l_msg_data );

             -- error checking
                -- any trip that reports and error
                -- causes the entire action to terminate with errors
             -- bug 3278059 : Don't set this message if we get warning
             -- e.g. reprice not required is generally a warning
             IF (l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING) THEN
                    l_warn_count := l_warn_count + 1;
             ELSE

               FTE_FREIGHT_RATING_DLVY_GRP.api_post_call
                    (
                    p_api_name           =>     l_module_name,
                    p_api_return_status  =>     l_return_status,
                    p_message_name       =>     'FTE_TRP_RATING_TRP_RATE_FAIL',
                    p_trip_id            =>     l_trip_info_rec.trip_id,
                    p_delivery_id        =>     null,
                    p_delivery_leg_id    =>     null,
                    x_number_of_errors   =>     l_number_of_errors,
                    x_number_of_warnings =>     l_number_of_warnings,
                    x_return_status      =>     l_return_status_1
                    );
                    --
                    IF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
                    THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    ELSIF (l_return_status_1 = WSH_UTIL_CORE.G_RET_STS_WARNING )
                    THEN
                       x_return_status := l_return_status_1;
                    END IF;
             END IF;

      END IF;



      -- If reached this point, then the current trip was rated successfully
      -- If the trip is part of a continuous move, add the cm to the list
      IF (l_trip_info_rec.move_id IS NOT NULL) THEN
         IF NOT l_rated_move_ids.EXISTS(l_trip_info_rec.move_id)  THEN
             l_rated_move_ids(l_trip_info_rec.move_id) := l_trip_info_rec.move_id;
         END IF;
      END IF;

      <<nextpass>>

    EXIT WHEN i = p_action_params.trip_id_list.LAST;
      i := p_action_params.trip_id_list.NEXT(i);
    END LOOP;

--
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
    IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
    END IF;
--
--
    IF (l_warn_count > 0)
    THEN
       x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
    END IF;


    FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

    FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  IF p_init_prc_log = 'Y' THEN
    FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;

  EXCEPTION
       WHEN g_finished_success THEN

        IF FND_API.To_Boolean( p_commit ) THEN
           COMMIT WORK;
        END IF;

	FND_MSG_PUB.Count_And_Get
	  (
	     p_count  => x_msg_count,
	     p_data  =>  x_msg_data,
	     p_encoded => FND_API.G_FALSE
	  );
--
         IF l_debug_on THEN
           WSH_DEBUG_SV.pop(l_module_name);
         END IF;
--
--
         FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'x_return_status='||x_return_status);

         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  IF p_init_prc_log = 'Y' THEN
         FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;
--
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO RATE_TRIP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_module_name,'FND_API.G_EXC_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;
--
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO RATE_TRIP;
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_module_name,'FND_API.G_EXC_UNEXPECTED_ERROR');
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;
--
	WHEN OTHERS THEN
		ROLLBACK TO RATE_TRIP;
		WSH_UTIL_CORE.DEFAULT_HANDLER(G_PKG_NAME||'.Rate_Trip');
		x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
		  (
		     p_count  => x_msg_count,
		     p_data  =>  x_msg_data,
		     p_encoded => FND_API.G_FALSE
		  );
		IF l_debug_on THEN
			WSH_DEBUG_SV.pop(l_module_name);
		END IF;
          FTE_FREIGHT_PRICING_UTIL.set_exit_exception(l_module_name,'OTHERS');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
          FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  IF p_init_prc_log = 'Y' THEN
          FTE_FREIGHT_PRICING_UTIL.close_logs;
  END IF;

END Rate_Trip;


--      This API is called directly from the trip re-rating concurrent program
--      The input to it should be either wsh trip id or wsh trip name

PROCEDURE Rate_Trip_conc (
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
        p_trip_id             IN     NUMBER   DEFAULT NULL,
        p_trip_name           IN     VARCHAR2 DEFAULT NULL )
IS

  l_return_status	VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(32767);
  l_status              VARCHAR2(10);
  l_temp                BOOLEAN;
  l_params 		action_param_rec;
  l_trip_id           	NUMBER;

  l_log_level     	NUMBER := FTE_FREIGHT_PRICING_UTIL.G_LOG;
  l_api_name            CONSTANT VARCHAR2(30)   := 'Rate_Trip_conc';

  CURSOR c_get_trip_id(c_trip_name VARCHAR2) IS
  SELECT trip_id
  FROM wsh_trips
  WHERE name = c_trip_name;

BEGIN
   FTE_FREIGHT_PRICING_UTIL.initialize_logging(p_debug_mode  => 'CONC',
                                               x_return_status => l_return_status );

   FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
   FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,l_api_name,'start');

   IF p_trip_id is null AND p_trip_name is null THEN
     FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'both trip id and trip name are null');
     raise FND_API.G_EXC_ERROR;
   END IF;

   l_trip_id := null;
   IF p_trip_id is not null THEN
     l_trip_id := p_trip_id;
   ELSE
      OPEN c_get_trip_id(p_trip_name);
      FETCH c_get_trip_id INTO l_trip_id;
      CLOSE c_get_trip_id;
      IF l_trip_id is null THEN
       	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'cannot get trip id from trip name');
     	raise FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   l_params.caller := 'FTE';
   l_params.event  := 'RE-RATING';
   l_params.action := 'RATE';
   l_params.trip_id_list(1) := l_trip_id;

   Rate_Trip (
	p_action_params		=> l_params,
	p_commit		=> FND_API.G_TRUE,
 	p_init_prc_log		=> 'N',
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
        x_return_status         => l_return_status );

  IF l_return_status = WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
        l_status := 'NORMAL';
        errbuf := 'Trip Rerating is completed successfully';
        retcode := '0';
  ELSIF l_return_status = WSH_UTIL_CORE.G_RET_STS_WARNING THEN
        l_status := 'WARNING';
        errbuf := 'Trip Rerating is completed with warning';
        retcode := '1';
  ELSE
        l_status := 'ERROR';
        errbuf := 'Trip Rerating is completed with error';
        retcode := '2';
  END IF;

  l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS(l_status,'');
  FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
  FTE_FREIGHT_PRICING_UTIL.close_logs;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'Trip Rerating is completed with error';
        retcode := '2';
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;
  WHEN OTHERS THEN
        l_temp := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR','');
        errbuf := 'Trip Rerating is completed with an Unexpected error';
        retcode := '2';
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,l_api_name);
        FTE_FREIGHT_PRICING_UTIL.close_logs;

END Rate_Trip_conc;

-- +======================================================================+
--   Procedure :
--           Move_Records_To_Main
--
--   Description:
--           Move rates from temp table to main table
--   Inputs:
--           p_trip_id          => trip_id (required)
--           p_lane_id          => lane_id  (either lane_id or schedule_id
--                                           required)
--           p_schedule_id      => schedule_id
--           p_service_type_code  => service_type_code
--           p_comparison_request_id => comparison_request_id (required)
--   Output:
--           x_return_status OUT NOCOPY VARCHAR2 => Return status
--
--   Global dependencies:
--
--
--   DB:
--
-- +======================================================================+

PROCEDURE Move_Records_To_Main(
	p_trip_id           IN NUMBER,
	p_lane_id           IN NUMBER,
	p_schedule_id       IN NUMBER,
        p_service_type_code IN VARCHAR2 DEFAULT NULL,
	p_comparison_request_id IN NUMBER,
	p_init_prc_log	        IN  VARCHAR2 DEFAULT 'Y',
	x_return_status OUT NOCOPY VARCHAR2) IS


CURSOR c_get_lane_info(c_lane_id NUMBER)
IS
SELECT  mode_of_transportation_code
FROM    fte_lanes
WHERE   lane_id = c_lane_id;


CURSOR c_get_sched_info(c_schedule_id NUMBER)
IS
SELECT  mode_of_transportation_code
FROM    fte_lanes l, fte_schedules s
WHERE   l.lane_id = s.lane_id
AND     s.schedules_id = c_schedule_id;

CURSOR c_get_dlegs_from_trip(c_trip_id IN NUMBER) IS
        SELECT  dl.delivery_leg_id
        FROM    wsh_delivery_legs dl ,
                wsh_trip_stops s
        WHERE   dl.pick_up_stop_id = s.stop_id
                and s.trip_id=c_trip_id;

l_mode VARCHAR2(30);
l_return_status VARCHAR2(1);
l_rowid VARCHAR2(30);
l_init_msg_list            VARCHAR2(30) :=FND_API.G_FALSE;
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_warning_count 	NUMBER:=0;
BEGIN


 	IF(p_init_prc_log='Y')
 	THEN
        	FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => l_init_msg_list,
                                                    x_return_status  => l_return_status );

 	END IF;



 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Move_Records_To_Main','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

 	SAVEPOINT  Move_Records_To_Main_2;
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                           'p_trip_id=>'||p_trip_id||' p_lane_id=>'||p_lane_id
       ||' p_schedule_id=>'||p_schedule_id||' p_service_type_code='||p_service_type_code
       ||'p_comparison_request_id=>'||p_comparison_request_id);

 	IF (NOT ((p_lane_id IS NULL AND p_schedule_id IS NOT NULL)
 		OR (p_lane_id IS NOT NULL AND p_schedule_id IS NULL)))
 	THEN
 		raise FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_lane_sched_null;

 	END IF;

        IF (p_lane_id IS NOT NULL) THEN

          OPEN c_get_lane_info(p_lane_id);
          FETCH c_get_lane_info INTO l_mode;
          CLOSE c_get_lane_info;

        ELSIF (p_schedule_id IS NOT NULL) THEN

          OPEN c_get_sched_info(p_schedule_id);
          FETCH c_get_sched_info INTO l_mode;
          CLOSE c_get_sched_info;

        END IF;

        IF (l_mode = 'TRUCK') THEN

          FTE_TL_RATING.Move_Records_To_Main(
	      p_trip_id => p_trip_id,
	      p_lane_id => p_lane_id,
	      p_schedule_id => p_schedule_id,
	      p_comparison_request_id => p_comparison_request_id,
	      x_return_status => l_return_status);

          IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
              IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                   x_return_status  :=  l_return_status;
                   raise FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_to_main_fail;
              END IF;
          ELSE
              FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
                           'Moved TL rates successfully');
          END IF;

        ELSE

              FTE_FREIGHT_PRICING.Move_fc_temp_to_main (
                 p_init_msg_list           => fnd_api.g_false,
	         p_init_prc_log            => 'N',
                 p_request_id              => p_comparison_request_id,
                 p_trip_id         	   => p_trip_id,
                 p_lane_id                 => p_lane_id,
                 p_schedule_id             => p_schedule_id,
                 p_service_type_code       => p_service_type_code,
                 x_return_status           => l_return_status);

               IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
                   IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
                        x_return_status  :=  l_return_status;
                        raise FTE_FREIGHT_PRICING_UTIL.g_nontl_move_rec_to_main_fail;
                   END IF;
               END IF;



        END IF;


	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_nontl_move_rec_to_main_fail THEN
 	 ROLLBACK TO  Move_Records_To_Main_2;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_nontl_move_rec_to_main_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');
         FTE_FREIGHT_PRICING_UTIL.close_logs;

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_move_rec_to_main_fail THEN
 	 ROLLBACK TO  Move_Records_To_Main_2;
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_move_rec_to_main_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


WHEN others THEN
 	ROLLBACK TO Move_Records_To_Main_2;
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Move_Records_To_Main',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Move_Records_To_Main');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


END Move_Records_To_Main;



PROCEDURE Delete_Main_Records(
	p_trip_id IN NUMBER,
	p_init_prc_log IN VARCHAR2 DEFAULT 'Y',
	x_return_status OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1);

l_init_msg_list            VARCHAR2(30) :=FND_API.G_FALSE;
l_mode  VARCHAR2(30);
l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

l_warning_count 	NUMBER:=0;

CURSOR c_trip_mode(c_trip_id NUMBER)
   IS
   SELECT t.mode_of_transport
   FROM   wsh_trips t
   WHERE t.trip_id=c_trip_id;


BEGIN

	IF (p_init_prc_log='Y')
	THEN

        	FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => l_init_msg_list,
                                                    x_return_status  => l_return_status );
	END IF;

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Delete_Main_Records','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_mode:=NULL;

	OPEN c_trip_mode(p_trip_id);
	FETCH c_trip_mode INTO l_mode;
	CLOSE c_trip_mode;

	IF ((l_mode is not NULL) AND (l_mode='TRUCK'))
	THEN
		FTE_TL_RATING.Delete_Main_Records(
			p_trip_id=>p_trip_id,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
		       IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		       THEN
			  raise FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail;
		       END IF;
		END IF;



	ELSE

	      FTE_FREIGHT_PRICING.delete_invalid_fc_recs (
		     p_segment_id      =>  p_trip_id,
		     x_return_status   =>  l_return_status ) ;

	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		 IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		     raise FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed;
		 END IF;
	      END IF;

	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Main_Records');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

	IF (p_init_prc_log='Y')
	THEN

		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;

EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_delete_main_rec_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Delete_Main_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_delete_main_rec_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Main_Records');
	IF (p_init_prc_log='Y')
	THEN

		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;

WHEN FTE_FREIGHT_PRICING_UTIL.g_delete_invalid_fc_failed THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Delete_Main_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_delete_invalid_fc_failed');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Main_Records');
	IF (p_init_prc_log='Y')
	THEN

		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Delete_Main_Records',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Delete_Main_Records');
	IF (p_init_prc_log='Y')
	THEN

		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


END Delete_Main_Records;


PROCEDURE Copy_LaneSched_To_Rank(
		p_lane_rec IN fte_lane_rec,
		p_sched_rec IN fte_schedule_rec,
		x_rank_rec IN OUT NOCOPY FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec,
		x_return_status	OUT NOCOPY  VARCHAR2)
IS

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Copy_LaneSched_To_Rank','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	IF(p_lane_rec IS NOT NULL)
	THEN


		x_rank_rec.lane_id:=p_lane_rec.lane_id;
		--x_rank_rec.schedule_id:=NULL;
		x_rank_rec.carrier_id:=p_lane_rec.carrier_id;
		x_rank_rec.mode_of_transport:=p_lane_rec.mode_of_transport_code;
		x_rank_rec.service_level:=p_lane_rec.service_code;
		x_rank_rec.estimated_transit_time:=p_lane_rec.transit_time;
		x_rank_rec.transit_time_uom:=p_lane_rec.transit_time_uom;
		--x_rank_rec.schedule_from:=p_lane_rec.schedule_from;
		--x_rank_rec.schedule_to:=p_lane_rec.schedule_to;


	ELSE

		x_rank_rec.lane_id:=p_sched_rec.lane_id;
		x_rank_rec.schedule_id:=NULL;
		x_rank_rec.carrier_id:=p_sched_rec.carrier_id;
		x_rank_rec.mode_of_transport:=p_sched_rec.mode_of_transport_code;
		x_rank_rec.service_level:=p_sched_rec.service_code;
		x_rank_rec.estimated_transit_time:=p_sched_rec.transit_time;
		x_rank_rec.transit_time_uom:=p_sched_rec.transit_time_uom;
		--x_rank_rec.schedule_from:=p_sched_rec.schedule_from;
		--x_rank_rec.schedule_to:=p_sched_rec.schedule_to;

	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Copy_LaneSched_To_Rank');

EXCEPTION
WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Copy_LaneSched_To_Rank',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Copy_LaneSched_To_Rank');


END Copy_LaneSched_To_Rank;


PROCEDURE LaneSched_Matches_Rank(
		p_lane_rec IN fte_lane_rec,
		p_schedule_rec IN fte_schedule_rec,
		p_rank_rec IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec,
		x_match_result OUT NOCOPY VARCHAR2,--'Y' or 'N'
		x_return_status	OUT NOCOPY  VARCHAR2)
IS

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;


BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'LaneSched_Matches_Rank','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_match_result:='Y';

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Rank rec:Lane id:'||p_rank_rec.lane_id||
	' Carrier:'||p_rank_rec.carrier_id||' Service level:'||p_rank_rec.service_level||' Mode:'||p_rank_rec.mode_of_transport);


	IF(p_lane_rec IS NOT NULL)
	THEN

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Lane rec:Lane id:'||p_lane_rec.lane_id||
		' Carrier:'||p_lane_rec.carrier_id||' Service level:'||p_lane_rec.service_code||' Mode:'||p_lane_rec.mode_of_transport_code);

		IF(p_rank_rec.carrier_id IS NOT NULL)
		THEN
			IF((p_lane_rec.carrier_id IS NOT NULL) AND (p_lane_rec.carrier_id <> p_rank_rec.carrier_id))
			THEN
				x_match_result:='N';
			END IF;

		END IF;

		IF(p_rank_rec.service_level IS NOT NULL)
		THEN
			IF((p_lane_rec.service_code IS NOT NULL) AND (p_lane_rec.service_code <> p_rank_rec.service_level))
			THEN
				x_match_result:='N';
			END IF;

		END IF;


		IF(p_rank_rec.mode_of_transport IS NOT NULL)
		THEN
			IF((p_lane_rec.mode_of_transport_code IS NOT NULL) AND (p_lane_rec.mode_of_transport_code <> p_rank_rec.mode_of_transport))
			THEN
				x_match_result:='N';
			END IF;

		END IF;


	ELSE

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Schedule rec:Schedule ID'||p_schedule_rec.schedule_id||' Lane id:'||p_schedule_rec.lane_id||
		' Carrier:'||p_schedule_rec.carrier_id||' Service level:'||p_schedule_rec.service_code||' Mode:'||p_schedule_rec.mode_of_transport_code);


		IF(p_rank_rec.carrier_id IS NOT NULL)
		THEN
			IF((p_schedule_rec.carrier_id IS NOT NULL) AND (p_schedule_rec.carrier_id <> p_rank_rec.carrier_id))
			THEN
				x_match_result:='N';
			END IF;

		END IF;

		IF(p_rank_rec.service_level IS NOT NULL)
		THEN
			IF((p_schedule_rec.service_code IS NOT NULL) AND (p_schedule_rec.service_code <> p_rank_rec.service_level))
			THEN
				x_match_result:='N';
			END IF;

		END IF;


		IF(p_rank_rec.mode_of_transport IS NOT NULL)
		THEN
			IF((p_schedule_rec.mode_of_transport_code IS NOT NULL) AND (p_schedule_rec.mode_of_transport_code <> p_rank_rec.mode_of_transport))
			THEN
				x_match_result:='N';
			END IF;

		END IF;



	END IF;






	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Match result:'||x_match_result);

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'LaneSched_Matches_Rank');

EXCEPTION

WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('LaneSched_Matches_Rank',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'LaneSched_Matches_Rank');


END LaneSched_Matches_Rank;

PROCEDURE Search_Multi_ShipMethods(
	p_ss_attr_rec	IN FTE_SS_ATTR_REC,
	p_ss_rate_sort_tab	   IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	x_ss_rate_sort_tab	OUT NOCOPY FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	x_ref		OUT NOCOPY dbms_utility.number_array,
	x_return_status	OUT NOCOPY  VARCHAR2)
IS
	l_match_result VARCHAR2(1);
	i NUMBER;
	j NUMBER;
	k NUMBER;
	l_search_criteria_tab fte_search_criteria_tab;
	l_search_criteria_rec fte_search_criteria_rec;
	l_lanes_tab  fte_lane_tab;
	l_schedules_tab fte_schedule_tab;
	l_lane_rec   fte_lane_rec;
	l_msg_data      VARCHAR2(32767);
	l_warning_count 	NUMBER:=0;
	l_return_status VARCHAR2(1);
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Search_Multi_ShipMethods','start');

	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;

	l_search_criteria_tab:=fte_search_criteria_tab();
	j:=1;

	i:=p_ss_rate_sort_tab.FIRST;
	WHILE ( i IS NOT NULL)
	LOOP
		IF (p_ss_rate_sort_tab(i).lane_id IS NULL)
		THEN

			l_search_criteria_rec := fte_search_criteria_rec(
			relax_flag             => 'Y',
			origin_loc_id          => p_ss_attr_rec.origin_location_id,
			destination_loc_id     => p_ss_attr_rec.destination_location_id,
			origin_country         => null,
			origin_state           => null,
			origin_city            => null,
			origin_zip             => null,
			destination_country    => null,
			destination_state      => null,
			destination_city       => null,
			destination_zip        => null,
			mode_of_transport      => p_ss_rate_sort_tab(i).mode_of_transport,
			lane_number            => null,
			carrier_id             => p_ss_rate_sort_tab(i).carrier_id,
			carrier_name           => null,
			commodity_catg_id      => null,
			commodity              => null,
			service_code           => p_ss_rate_sort_tab(i).service_level,
			service                => null,
			--equipment_code         => null, -- removed J+
			--equipment              => null, -- removed J+
			schedule_only_flag     => null,
			dep_date_from          => p_ss_attr_rec.dep_date_from,
			dep_date_to            => p_ss_attr_rec.dep_date_to,
			arr_date_from          => p_ss_attr_rec.arr_date_from,
			arr_date_to            => p_ss_attr_rec.arr_date_to,
			lane_ids_string        => null,
			delivery_leg_id        => null,
			exists_in_database     => null,
			delivery_id            => null,
			sequence_number        => null,
			pick_up_stop_id        => p_ss_attr_rec.pick_up_stop_id,
			drop_off_stop_id       => p_ss_attr_rec.drop_off_stop_id,
			pickupstop_location_id => p_ss_attr_rec.pick_up_stop_location_id,
			dropoffstop_location_id => p_ss_attr_rec.drop_off_stop_location_id,
			ship_to_site_id 	 => null,
			vehicle_id		 => null,
			--Changes made to fte_search_criteria_rec 19-FEB-2004
			effective_date         => p_ss_attr_rec.dep_date_from,
			effective_date_type    => '=',
			tariff_name		 => null -- Added J+
			);

			l_search_criteria_tab.EXTEND(1);
			l_search_criteria_tab(j):=l_search_criteria_rec;
			j:=j+1;


		END IF;

		i:=p_ss_rate_sort_tab.NEXT(i);
	END LOOP;


	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Calling FTE_LANE_SEARCH.Search_Lanes:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));

	FTE_LANE_SEARCH.Search_Lanes(
		p_search_criteria=>l_search_criteria_tab,
                p_num_results=>999,
		p_search_type=> 'L',
                x_lane_results=>l_lanes_tab,
		x_schedule_results=>l_schedules_tab,
                x_return_message=>l_msg_data,
                x_return_status=>l_return_status);

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'After FTE_LANE_SEARCH.Search_Lanes:'||TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Status:'||l_return_status||':Message:'||l_msg_data);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_lane_search_failed;
		ELSE
			l_warning_count:=l_warning_count+1;

		END IF;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-1');
	k:=1;
	j:=p_ss_rate_sort_tab.FIRST;
	i:=l_lanes_tab.FIRST;
	WHILE((j IS NOT NULL) OR (i IS NOT NULL))
	LOOP
		IF ( (i IS NOT NULL) AND l_lanes_tab.EXISTS(i))
		THEN
			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Lane id:'||l_lanes_tab(i).lane_id||'transit time:'||l_lanes_tab(i).transit_time||' UOM:'||l_lanes_tab(i).transit_time_uom);
		ELSE
			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'No lane tab for i:'||i);
		END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-2 i:'||i||' j:'||j);
		IF((j IS NOT NULL) AND (i IS NOT NULL) AND (p_ss_rate_sort_tab.EXISTS(j)) AND (p_ss_rate_sort_tab(j).lane_id IS NULL))
		THEN
			--This rank was used for lane search
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-3 i:'||i||' j:'||j);
			l_match_result:='N';
			WHILE((l_match_result='N') AND (j IS NOT NULL))
			LOOP

				LaneSched_Matches_Rank(
					p_lane_rec	=>l_lanes_tab(i),
					p_schedule_rec	=>NULL,
					p_rank_rec	=>p_ss_rate_sort_tab(j),
					x_match_result	=>l_match_result,
					x_return_status	=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_lane_matches_rank_fail;
					END IF;
				END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-4 i:'||i||' j:'||j);
				IF(l_match_result='N')
				THEN
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-5 i:'||i||' j:'||j);
					j:=p_ss_rate_sort_tab.NEXT(j);

				END IF;

			END LOOP;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-6 i:'||i||' j:'||j);
			IF (l_match_result='N')
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Lane did not match with any rank');

			ELSE
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-7 i:'||i||' j:'||j);
				x_ss_rate_sort_tab(k):=p_ss_rate_sort_tab(j);

				Copy_LaneSched_To_Rank(
					p_lane_rec	=>l_lanes_tab(i),
					p_sched_rec	=>NULL,
					x_rank_rec	=>x_ss_rate_sort_tab(k),
					x_return_status	=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_copy_lane_rank_fail;
					END IF;
				END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-8 i:'||i||' j:'||j);

				x_ref(k):=j;
				k:=k+1;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-9 i:'||i||' j:'||j);

			END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-10 i:'||i||' j:'||j);
			IF (i IS NOT NULL)
			THEN
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-11 i:'||i||' j:'||j);
				i:=l_lanes_tab.NEXT(i);
			ELSIF(j IS NOT NULL)
			THEN
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-12 i:'||i||' j:'||j);
				j:=p_ss_rate_sort_tab.NEXT(j);
			END IF;



		ELSIF ((j IS NOT NULL) AND (p_ss_rate_sort_tab.EXISTS(j)) AND (p_ss_rate_sort_tab(j).lane_id IS NOT NULL))
		THEN
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-13 i:'||i||' j:'||j);
			--This rank was not used for lane search
			--Copy to output

			x_ss_rate_sort_tab(k):=p_ss_rate_sort_tab(j);
			x_ref(k):=j;
			k:=k+1;
			j:=p_ss_rate_sort_tab.NEXT(j);

		ELSIF( i IS NULL AND j IS NOT NULL)
		THEN
			j:=p_ss_rate_sort_tab.NEXT(j);

		END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-14 i:'||i||' j:'||j);

	END LOOP;



	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-15 i:'||i||' j:'||j);

	j:=p_ss_rate_sort_tab.FIRST;
	i:=l_schedules_tab.FIRST;
	WHILE((j IS NOT NULL) OR (i IS NOT NULL))
	LOOP
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-16 i:'||i||' j:'||j);
		IF((j IS NOT NULL) AND (i IS NOT NULL) AND (p_ss_rate_sort_tab.EXISTS(j)) AND (p_ss_rate_sort_tab(j).schedule_id IS NULL))
		THEN
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-17 i:'||i||' j:'||j);
			--This rank was used for lane search

			l_match_result:='N';
			WHILE((l_match_result='N') AND (j IS NOT NULL))
			LOOP
				LaneSched_Matches_Rank(
					p_lane_rec	=>NULL,
					p_schedule_rec	=>l_schedules_tab(i),
					p_rank_rec	=>p_ss_rate_sort_tab(j),
					x_match_result	=>l_match_result,
					x_return_status	=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_lane_matches_rank_fail;
					END IF;
				END IF;

				IF(l_match_result='N')
				THEN
					j:=p_ss_rate_sort_tab.NEXT(j);

				END IF;

			END LOOP;

			IF (l_match_result='N')
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Lane did not match with any rank');

			ELSE
				x_ss_rate_sort_tab(k):=p_ss_rate_sort_tab(j);

				Copy_LaneSched_To_Rank(
					p_lane_rec	=>NULL,
					p_sched_rec	=>l_schedules_tab(i),
					x_rank_rec	=>x_ss_rate_sort_tab(k),
					x_return_status	=>l_return_status);

				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
				THEN
					IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
					THEN
						raise FTE_FREIGHT_PRICING_UTIL.g_copy_lane_rank_fail;
					END IF;
				END IF;


				x_ref(k):=j;
				k:=k+1;


			END IF;

			IF (i IS NOT NULL)
			THEN
				i:=l_lanes_tab.NEXT(i);
			ELSIF(j IS NOT NULL)
			THEN
				j:=p_ss_rate_sort_tab.NEXT(j);
			END IF;



		ELSIF ((j IS NOT NULL) AND (p_ss_rate_sort_tab.EXISTS(j)) AND (p_ss_rate_sort_tab(j).schedule_id IS NOT NULL))
		THEN
			--This rank was not used for lane search
			--Copy to output

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-18 i:'||i||' j:'||j);
			x_ss_rate_sort_tab(k):=p_ss_rate_sort_tab(j);
			x_ref(k):=j;
			k:=k+1;
			j:=p_ss_rate_sort_tab.NEXT(j);

		ELSIF( i IS NULL AND j IS NOT NULL)
		THEN
			j:=p_ss_rate_sort_tab.NEXT(j);



		END IF;
	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-19 i:'||i||' j:'||j);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'DBG-20 i:'||i||' j:'||j);

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Multi_ShipMethods');

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;


EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_lane_search_failed THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Search_Multi_ShipMethods',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_lane_search_failed');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Multi_ShipMethods');



WHEN FTE_FREIGHT_PRICING_UTIL.g_lane_matches_rank_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Search_Multi_ShipMethods',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_lane_matches_rank_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Multi_ShipMethods');


WHEN FTE_FREIGHT_PRICING_UTIL.g_copy_lane_rank_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Search_Multi_ShipMethods',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_copy_lane_rank_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Multi_ShipMethods');

WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Search_Multi_ShipMethods',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Multi_ShipMethods');


END Search_Multi_ShipMethods;


PROCEDURE Display_Attr_Rec(p_attr_rec IN FTE_SS_ATTR_REC)
IS

	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN


	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Display_Attr_Rec','start');


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	' ');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'START ATTR REC');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DELIVERY_ID        :'||p_attr_rec.delivery_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DELIVERY_LEG_ID    :'||p_attr_rec.delivery_leg_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  TRIP_ID      :'||p_attr_rec.trip_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  ARR_DATE_TO        :'||p_attr_rec.arr_date_to);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  ARR_DATE_FROM      :'||p_attr_rec.arr_date_from);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DEP_DATE_TO        :'||p_attr_rec.dep_date_to);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DEP_DATE_FROM      :'||p_attr_rec.dep_date_from);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  ORIGIN_LOCATION_ID :'||p_attr_rec.origin_location_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DESTI_LOCATION_ID  :'||p_attr_rec.destination_location_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  PICK_UP_STOP_ID    :'||p_attr_rec.pick_up_stop_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DROP_OFF_STOP_ID   :'||p_attr_rec.drop_off_stop_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  PICK_UP_STOP_LOC_ID:'||p_attr_rec.pick_up_stop_location_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  DROP_OFF_STOP_LC_ID:'||p_attr_rec.drop_off_stop_location_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  LANE_ID            :'||p_attr_rec.lane_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SCHEDULE_ID        :'||p_attr_rec.schedule_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  CARRIER_ID         :'||p_attr_rec.carrier_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  MODE_OF_TRANSPORT  :'||p_attr_rec.mode_of_transport);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SERVICE_LEVEL      :'||p_attr_rec.service_level);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  VEHICLE_ITEM_ID    :'||p_attr_rec.vehicle_item_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  VEHICLE_ORG_ID     :'||p_attr_rec.vehicle_org_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  RULE_ID            :'||p_attr_rec.rule_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  RANK_ID            :'||p_attr_rec.rank_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  APPEND_LIST_FLAG   :'||p_attr_rec.append_list_flag);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'END ATTR REC');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	' ');

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Display_Attr_Rec');

END Display_Attr_Rec;



PROCEDURE Display_Rank_Rec(p_rank_rec IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_rec)
IS
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN


	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Display_Rank_Rec','start');


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	' ');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'START RANK REC');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  RANK_ID            :'||p_rank_rec.rank_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  TRIP_ID            :'||p_rank_rec.trip_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  RANK_SEQUENCE      :'||p_rank_rec.rank_sequence);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  CARRIER_ID         :'||p_rank_rec.carrier_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SERVICE_LEVEL      :'||p_rank_rec.service_level);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  MODE_OF_TRANSPORT  :'||p_rank_rec.mode_of_transport);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  LANE_ID            :'||p_rank_rec.lane_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SOURCE             :'||p_rank_rec.source);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  ENABLED            :'||p_rank_rec.enabled);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  ESTIMATED_RATE     :'||p_rank_rec.estimated_rate);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  CURRENCY_CODE      :'||p_rank_rec.currency_code);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  VEHICLE_ITEM_ID    :'||p_rank_rec.vehicle_item_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  ESTIMATED_TRANSIT_T:'||p_rank_rec.estimated_transit_time);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  TRANSIT_TIME_UOM   :'||p_rank_rec.transit_time_uom);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  VERSION            :'||p_rank_rec.version);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  CONSIGNEE_CR_AC_NO :'||p_rank_rec.consignee_carrier_ac_no);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  FREIGHT_TERMS_CODE :'||p_rank_rec.freight_terms_code);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  INITSMCONFIG       :'||p_rank_rec.initsmconfig);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  CREATION_DATE      :'||p_rank_rec.creation_date);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  CREATED_BY         :'||p_rank_rec.created_by);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  LAST_UPDATE_DATE   :'||p_rank_rec.last_update_date);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  LAST_UPDATE_BY     :'||p_rank_rec.last_updated_by);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  LAST_UPDATE_LOGIN  :'||p_rank_rec.last_update_login);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  IS_CURRENT         :'||p_rank_rec.is_current);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SINGLE_CURR_RATE   :'||p_rank_rec.single_curr_rate);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SORT               :'||p_rank_rec.sort);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SCHEDULE_FROM      :'||p_rank_rec.schedule_from);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SCHEDULE_TO        :'||p_rank_rec.schedule_to);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  SCHEDULE_ID        :'||p_rank_rec.schedule_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'  VEHICLE_ORG_ID     :'||p_rank_rec.vehicle_org_id);
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	'END RANK REC');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,
	' ');

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Display_Rank_Rec');

END Display_Rank_Rec;

PROCEDURE Display_Rank_Tab(
	p_rank_tab IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	p_input_ref	IN dbms_utility.number_array)
IS
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
	i NUMBER;
BEGIN

	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Display_Rank_Tab','start');

	IF (p_rank_tab IS NOT NULL)
	THEN
		FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Number of Rank recs:'||p_rank_tab.COUNT );

		i:=p_rank_tab.FIRST;
		WHILE ( i IS NOT NULL)
		LOOP

			FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Rank rec:'||i );

			IF(p_input_ref IS NOT NULL AND p_input_ref.EXISTS(i))
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(l_log_level,'Input ref:'|| p_input_ref(i));
			END IF;

			Display_Rank_Rec(p_rank_tab(i));
			i:=p_rank_tab.NEXT(i);
		END LOOP;

	END IF;


	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Display_Rank_Tab');

END Display_Rank_Tab;

PROCEDURE Get_Vehicle_Item_Org(
	p_vehicle_type IN NUMBER,
	x_vehicle_item_id OUT NOCOPY NUMBER,
	x_vehicle_item_org OUT NOCOPY NUMBER,
	x_return_status            OUT NOCOPY  VARCHAR2)
IS

CURSOR c_get_veh_item_org(c_vehicle_type IN NUMBER)
IS
SELECT	v.inventory_item_id,
	v.organization_id
FROM	FTE_VEHICLE_TYPES v
WHERE	v.vehicle_type_id=c_vehicle_type;


	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

BEGIN

 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_Vehicle_Item_Org','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	x_vehicle_item_id:=NULL;
	x_vehicle_item_org:=NULL;

	OPEN c_get_veh_item_org(p_vehicle_type);
	FETCH c_get_veh_item_org INTO x_vehicle_item_id,x_vehicle_item_org;
	CLOSE c_get_veh_item_org;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicle_Item_Org');

EXCEPTION

WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_Vehicle_Item_Org',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_Vehicle_Item_Org');


END Get_Vehicle_Item_Org;


PROCEDURE	Seq_Tender_Sort(
	p_ss_rate_sort_tab IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	p_input_ref	IN dbms_utility.number_array ,-- Reference of p_ss_rate_sort_tab to input ranks
	x_ss_rate_sort_tab OUT NOCOPY FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
	x_input_ref	OUT NOCOPY dbms_utility.number_array ,-- Reference of p_ss_rate_sort_tab to input ranks
	x_return_status OUT NOCOPY VARCHAR2)
IS
	i	NUMBER;
	l_single_currency VARCHAR2(3);
	l_single_curr_rate NUMBER;
	l_time_uom	VARCHAR2(3);
	l_transit_time NUMBER;
	l_values_tab Sort_Value_Tab_Type;
	l_values_rec Sort_Value_Rec_Type;
	l_sorted_index dbms_utility.number_array;
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;
	l_return_status VARCHAR2(1);
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Seq_Tender_Sort','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	l_single_currency:=NULL;
	l_time_uom:=NULL;
	i:=p_ss_rate_sort_tab.FIRST;
	WHILE( i IS NOT NULL)
	LOOP
		--Calculate transit time in a single uom
		--Used for sorting

		l_transit_time:=NULL;
		IF((p_ss_rate_sort_tab(i).estimated_transit_time IS NOT NULL ) AND
		(p_ss_rate_sort_tab(i).transit_time_uom IS NOT NULL ))
		THEN
			IF(l_time_uom IS NOT NULL)
			THEN
				l_time_uom:=p_ss_rate_sort_tab(i).transit_time_uom;
			END IF;

			l_transit_time:=FTE_FREIGHT_PRICING_UTIL.convert_uom(
				p_ss_rate_sort_tab(i).transit_time_uom,
				l_time_uom,
				p_ss_rate_sort_tab(i).estimated_transit_time,
				0);

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'index:'||i||'Transit time:'||l_transit_time);


		END IF;


		--Populate Sort input structures

		l_values_tab(i):=l_values_rec;

		--RL <  UI
		IF (p_ss_rate_sort_tab(i).sort IS NOT NULL)
		THEN
			IF (p_ss_rate_sort_tab(i).sort='RL')
			THEN
				l_values_tab(i).value(1):=SORT_TYPE_RL;

			ELSIF (p_ss_rate_sort_tab(i).sort='UI')
			THEN
				l_values_tab(i).value(1):=SORT_TYPE_UI;
			END IF;

		END IF;

		--Input reference
		l_values_tab(i).value(2):=p_input_ref(i);

		--Rates

		l_values_tab(i).value(3):=p_ss_rate_sort_tab(i).single_curr_rate;

		--Transit time
		l_values_tab(i).value(4):=l_transit_time;

		--Lane
		l_values_tab(i).value(5):=p_ss_rate_sort_tab(i).lane_id;

		--Vehicle
		l_values_tab(i).value(6):=p_ss_rate_sort_tab(i).vehicle_item_id;

		i:=p_ss_rate_sort_tab.NEXT(i);
	END LOOP;



	Sort(
		p_values_tab=>l_values_tab,
		p_sort_type=>'SEQ_TENDER',
		x_sorted_index=>l_sorted_index,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_sort_fail;
		END IF;
	END IF;


	i:=l_sorted_index.FIRST;
	WHILE( i IS NOT NULL)
	LOOP
		IF(p_ss_rate_sort_tab.EXISTS(l_sorted_index(i)))
		THEN
			x_ss_rate_sort_tab(i):=p_ss_rate_sort_tab(l_sorted_index(i));
			x_input_ref(i):=p_input_ref(l_sorted_index(i));
		ELSE

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Sorted value index:'||i||' Does not exist in input at:'||l_sorted_index(i));
		END IF;

		i:=l_sorted_index.NEXT(i);
	END LOOP;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Seq_Tender_Sort');

EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_tl_conv_currency_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Seq_Tender_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_tl_conv_currency_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Seq_Tender_Sort');


WHEN FTE_FREIGHT_PRICING_UTIL.g_sort_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Seq_Tender_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_sort_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Seq_Tender_Sort');

WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Seq_Tender_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Seq_Tender_Sort');


END Seq_Tender_Sort;

PROCEDURE Remove_Duplicate_Lanes(
		p_ss_rate_sort_tab	   IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
		p_input_ref	IN dbms_utility.number_array ,-- Reference of p_ss_rate_sort_tab to input ranks
		x_ss_rate_sort_tab OUT NOCOPY FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
		x_input_ref	OUT NOCOPY dbms_utility.number_array ,-- Reference of p_ss_rate_sort_tab to input ranks
		x_return_status            OUT NOCOPY  VARCHAR2)
IS
	i	NUMBER;
	j	NUMBER;
	l_prev_index	NUMBER;
	l_values_tab Sort_Value_Tab_Type;
	l_values_rec Sort_Value_Rec_Type;
	l_sorted_index dbms_utility.number_array;
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_eliminated_index dbms_utility.number_array;

	l_index NUMBER;
	l_result VARCHAR2(1);
	l_return_status VARCHAR2(1);
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Remove_Duplicate_Lanes','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	--Sort based on on  schedule,lane,vehicle,rank reference
	--This will result in a list where the entries having the same
	--schedule/lane/vehicle will be contigous, and in order of rank reference
	--For all contigous entries having the same schedule/lane/vehicle,all except the first can be
	--eliminated

	i:=p_ss_rate_sort_tab.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		l_values_tab(i):=l_values_rec;

		l_values_tab(i).value(1):=p_ss_rate_sort_tab(i).schedule_id;
		l_values_tab(i).value(2):=p_ss_rate_sort_tab(i).lane_id;
		l_values_tab(i).value(3):=p_ss_rate_sort_tab(i).vehicle_item_id;
		l_values_tab(i).value(4):=i;-- To ensure that higher ranks

		i:=p_ss_rate_sort_tab.NEXT(i);
	END LOOP;

	Sort(
		p_values_tab=>l_values_tab,
		p_sort_type=>'ELIM_DUPLICATES',
		x_sorted_index=>l_sorted_index,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			raise FTE_FREIGHT_PRICING_UTIL.g_sort_fail;
		END IF;
	END IF;

	--Mark duplicates for removal

	l_prev_index:=NULL;
	i:=l_sorted_index.FIRST;
	WHILE( i IS NOT NULL)
	LOOP
		IF(l_prev_index IS NOT NULL)
		THEN



			l_index:=l_values_tab(l_sorted_index(i)).value(4);

			l_eliminated_index(l_index):=1;

			--Ignore rank reference for equality test;
			l_values_tab(l_sorted_index(i)).value(4):=NULL;
			l_values_tab(l_sorted_index(l_prev_index)).value(4):=NULL;

			Compare_Sort_Value(
				p_value1=>l_values_tab(l_sorted_index(i)),
				p_value2=>l_values_tab(l_sorted_index(l_prev_index)) ,
				x_result=> l_result,
				x_return_status=>l_return_status);


			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					raise FTE_FREIGHT_PRICING_UTIL.g_quicksort_compare_fail;
				END IF;
			END IF;


			IF(l_result = '=')
			THEN
				--Equality this rank entry is a duplicate,mark for removal

				l_eliminated_index(l_index):=0;

			END IF;

		ELSE


			l_index:=l_values_tab(l_sorted_index(i)).value(4);

			l_eliminated_index(l_index):=1;

		END IF;

		l_prev_index:=i;
		i:=l_sorted_index.NEXT(i);
	END LOOP;


	--Copy over unique lanes to output

	j:=1;
	i:=l_eliminated_index.FIRST;
	WHILE(i IS NOT NULL)
	LOOP

		IF(l_eliminated_index(i)=1)
		THEN

			x_ss_rate_sort_tab(j):=p_ss_rate_sort_tab(i);
			x_input_ref(j):=p_input_ref(i);
			j:=j+1;

		END IF;


		i:=l_eliminated_index.NEXT(i);
	END LOOP;



	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Remove_Duplicate_Lanes');

EXCEPTION

WHEN FTE_FREIGHT_PRICING_UTIL.g_quicksort_compare_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Remove_Duplicate_Lanes',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_quicksort_compare_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Remove_Duplicate_Lanes');


WHEN FTE_FREIGHT_PRICING_UTIL.g_sort_fail THEN
         x_return_status := WSH_UTIL_CORE.G_RET_STS_ERROR;
         FTE_FREIGHT_PRICING_UTIL.set_exception('Remove_Duplicate_Lanes',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_sort_fail');
         FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Remove_Duplicate_Lanes');

WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Seq_Tender_Sort',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Seq_Tender_Sort');




END Remove_Duplicate_Lanes;




PROCEDURE Get_MDC_Delivery_Type(
	p_delivery_id IN NUMBER,
	p_trip_id IN NUMBER,
	x_delivery_type OUT NOCOPY NUMBER,
	x_return_status OUT NOCOPY VARCHAR2) IS


CURSOR c_delivery_type(c_delivery_id IN Number) IS
SELECT delivery_type
FROM wsh_new_deliveries
WHERE delivery_id=c_delivery_id;

CURSOR c_check_parent_exists(c_delivery_id IN Number,c_trip_id IN NUMBER) IS
select dl.parent_delivery_leg_id
FROM wsh_delivery_legs dl,
     wsh_trip_stops s
WHERE dl.delivery_id=c_delivery_id
AND dl.parent_delivery_leg_id is not null
AND dl.pick_up_stop_id = s.stop_id
AND s.trip_id=c_trip_id;


l_delivery_type VARCHAR2(30);
l_parent_dleg_id NUMBER;

l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

l_return_status VARCHAR2(1);
BEGIN


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Get_MDC_Delivery_Type','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;



	x_delivery_type:=DELIVERY_TYPE_STANDARD;

	l_delivery_type:=NULL;
	OPEN c_delivery_type(p_delivery_id);
	FETCH c_delivery_type into l_delivery_type;
	CLOSE c_delivery_type;

	IF ((l_delivery_type IS NOT NULL) AND (l_delivery_type='CONSOLIDATION'))
	THEN

		x_delivery_type:=DELIVERY_TYPE_CONSOL;

	ELSE

		l_parent_dleg_id:=NULL;

		OPEN c_check_parent_exists(p_delivery_id,p_trip_id);
		FETCH c_check_parent_exists into l_parent_dleg_id;
		CLOSE c_check_parent_exists;


		IF(l_parent_dleg_id IS NOT NULL)
		THEN
			x_delivery_type:=DELIVERY_TYPE_CHILD;

		ELSE
			x_delivery_type:=DELIVERY_TYPE_STANDARD;
		END IF;


	END IF;

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_MDC_Delivery_Type');

EXCEPTION

WHEN others THEN
	x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
	FTE_FREIGHT_PRICING_UTIL.set_exception('Get_MDC_Delivery_Type',FTE_FREIGHT_PRICING_UTIL.G_ERR,'g_others');
	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Get_MDC_Delivery_Type');


END Get_MDC_Delivery_Type;


PROCEDURE	Search_Rate_Sort(
		p_api_version	IN  NUMBER DEFAULT 1.0,
		p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_event                    IN  VARCHAR2 DEFAULT 'FTE_TRIP_COMP',
		p_commit                   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
		p_init_prc_log		   IN     VARCHAR2 DEFAULT 'Y',
		p_ss_rate_sort_tab	   IN FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
		p_ss_rate_sort_atr_rec IN  FTE_SS_ATTR_REC,
		x_ss_rate_sort_tab OUT NOCOPY FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type,
		x_rating_request_id               OUT NOCOPY NUMBER,
		x_return_status            OUT NOCOPY  VARCHAR2,
		x_msg_count                OUT NOCOPY  NUMBER,
		x_msg_data                 OUT NOCOPY  VARCHAR2)
IS

	i	NUMBER;
	j	NUMBER;
	k	NUMBER;

	l_sort_rank_tab	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
	l_rate_rank_tab	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
	l_lane_rank_tab	FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
	l_elim_rank_tab FTE_CARRIER_RANK_LIST_PVT.carrier_rank_list_tbl_type;
	l_lane_rank_ref 	DBMS_UTILITY.NUMBER_ARRAY;
	l_rate_rank_ref 	DBMS_UTILITY.NUMBER_ARRAY;
	l_sort_rank_ref 	DBMS_UTILITY.NUMBER_ARRAY;

	l_elim_rank_ref 	DBMS_UTILITY.NUMBER_ARRAY;

	l_lane_sched_id_tab	FTE_ID_TAB_TYPE; -- lane_ids or schedule_ids
	l_lane_sched_tab	FTE_CODE_TAB_TYPE; -- 'L' or 'S'  (Lane or Schedule)
	l_mode_tab	FTE_CODE_TAB_TYPE;
	l_service_type_tab	FTE_CODE_TAB_TYPE;
	l_vehicle_type_tab	FTE_ID_TAB_TYPE;

	l_out_lane_sched_id_tab	FTE_ID_TAB_TYPE; -- lane_ids or schedule_ids
	l_out_lane_sched_tab	FTE_CODE_TAB_TYPE; -- 'L' or 'S'  (Lane or Schedule)
	l_out_mode_tab	FTE_CODE_TAB_TYPE;
	l_out_service_type_tab	FTE_CODE_TAB_TYPE;
	l_out_vehicle_type_tab	FTE_ID_TAB_TYPE;

	l_sum_rate_tab	FTE_ID_TAB_TYPE;
	l_sum_rate_curr_tab	FTE_CODE_TAB_TYPE;
	l_request_id	NUMBER;
	l_return_status	VARCHAR2(1);
	l_rating_API_fail VARCHAR2(1);
	l_log_level     NUMBER := FTE_FREIGHT_PRICING_UTIL.G_DBG;

	l_api_version	        CONSTANT NUMBER := 1.0;
	l_api_name                CONSTANT VARCHAR2(30)   := 'Search_Rate_Sort';
	l_msg_count           NUMBER;
	l_msg_data            VARCHAR2(32767);

	l_laneSched_count	NUMBER;
	l_single_currency VARCHAR2(30);
	l_single_curr_rate NUMBER;
	l_warning_count 	NUMBER:=0;

	l_delivery_type NUMBER;

BEGIN


	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call
			 (
			   l_api_version,
			   p_api_version,
			   l_api_name,
			   G_PKG_NAME
			  )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	IF(p_init_prc_log='Y')
	THEN

	      FTE_FREIGHT_PRICING_UTIL.initialize_logging( p_init_msg_list  => p_init_msg_list,
							    x_return_status  => l_return_status );

	      IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS THEN
		  IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING THEN
		       x_return_status  :=  l_return_status;
		       RETURN;
		  END IF;
	      ELSE
		  FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Initialize Logging successful ');
	      END IF;
	END IF;


 	FTE_FREIGHT_PRICING_UTIL.reset_dbg_vars;
 	FTE_FREIGHT_PRICING_UTIL.set_method(l_log_level,'Search_Rate_Sort','start');

 	x_return_status := WSH_UTIL_CORE.G_RET_STS_SUCCESS;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Input ranks');
	Display_Rank_Tab(p_rank_tab=>p_ss_rate_sort_tab,
			p_input_ref=>l_lane_rank_ref);

	Display_Attr_Rec(p_attr_rec=>p_ss_rate_sort_atr_rec);


	--Lane Search

	Search_Multi_ShipMethods(
		p_ss_attr_rec=>p_ss_rate_sort_atr_rec,
		p_ss_rate_sort_tab=>p_ss_rate_sort_tab,
		x_ss_rate_sort_tab=>l_lane_rank_tab,
		x_ref=>l_lane_rank_ref,
		x_return_status=>l_return_status);

	IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
	THEN
		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
		THEN
			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Search_Multi_ShipMethods FAILED');
			raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
		ELSE
			l_warning_count:=l_warning_count+1;
		END IF;
	END IF;


	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ranks after lane search');
	Display_Rank_Tab(p_rank_tab=>l_lane_rank_tab,
			p_input_ref=>l_lane_rank_ref);





	IF (l_lane_rank_tab.COUNT > 0)
	THEN


		Remove_Duplicate_Lanes(
			p_ss_rate_sort_tab=>l_lane_rank_tab,
			p_input_ref=>l_lane_rank_ref,
			x_ss_rate_sort_tab=>l_elim_rank_tab,
			x_input_ref=>l_elim_rank_ref,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_elim_dup_rank_fail');
				raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
			END IF;
		END IF;


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ranks after  Eliminating duplicates');
		Display_Rank_Tab(p_rank_tab=>l_elim_rank_tab,
			p_input_ref=>l_elim_rank_ref);


		l_lane_rank_tab.DELETE;
		l_lane_rank_ref.DELETE;


		--Prepare inputs for rating

		l_lane_sched_id_tab:=FTE_ID_TAB_TYPE();
		l_lane_sched_tab:=FTE_CODE_TAB_TYPE();
		l_mode_tab:=FTE_CODE_TAB_TYPE();
		l_service_type_tab:=FTE_CODE_TAB_TYPE();
		l_vehicle_type_tab:=FTE_ID_TAB_TYPE();

		l_laneSched_count:=l_elim_rank_tab.COUNT;

		l_lane_sched_id_tab.EXTEND(l_laneSched_count);
		l_lane_sched_tab.EXTEND(l_laneSched_count);
		l_mode_tab.EXTEND(l_laneSched_count);
		l_service_type_tab.EXTEND(l_laneSched_count);
		l_vehicle_type_tab.EXTEND(l_laneSched_count);


		j:=1;
		i:=l_elim_rank_tab.FIRST;
		WHILE(i IS NOT NULL)
		LOOP
			--Always clear old rates in rank rec
			l_elim_rank_tab(i).estimated_rate:=NULL;
			l_elim_rank_tab(i).currency_code:=NULL;
			l_elim_rank_tab(i).single_curr_rate:=NULL;

			IF(l_elim_rank_tab(i).schedule_id IS NOT NULL)
			THEN
				l_lane_sched_id_tab(j):=l_elim_rank_tab(i).schedule_id;
				l_lane_sched_tab(j):='S';
			ELSE

				l_lane_sched_id_tab(j):=l_elim_rank_tab(i).lane_id;
				l_lane_sched_tab(j):='L';


			END IF;
			l_mode_tab(j):=l_elim_rank_tab(i).mode_of_transport;
			l_service_type_tab(j):=l_elim_rank_tab(i).service_level;



			l_vehicle_type_tab(j):=NULL;

			IF (l_elim_rank_tab(i).vehicle_item_id IS NOT NULL)
			THEN

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Calling vehicle API inventory item:'||l_elim_rank_tab(i).vehicle_item_id);
				l_vehicle_type_tab(j):=FTE_VEHICLE_PKG.GET_VEHICLE_TYPE_ID(
					p_inventory_item_id=> l_elim_rank_tab(i).vehicle_item_id);

				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Vehicle API returned:'||l_vehicle_type_tab(j));

				IF(l_vehicle_type_tab(j)=-1)
				THEN

					l_vehicle_type_tab(j):=NULL;

				END IF;



			END IF;

			j:=j+1;
			i:=l_elim_rank_tab.NEXT(i);
		END LOOP;

		--Rating

		l_delivery_type:= NULL;

		IF ((p_ss_rate_sort_atr_rec.delivery_id IS NOT NULL) AND (p_ss_rate_sort_atr_rec.trip_id IS NOT NULL))
		THEN

			Get_MDC_Delivery_Type(
				p_delivery_id=>p_ss_rate_sort_atr_rec.delivery_id,
				p_trip_id=>p_ss_rate_sort_atr_rec.trip_id,
				x_delivery_type=>l_delivery_type,
				x_return_status=>l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Get_MDC_Delivery_Type FAILED');
					raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
				END IF;
			END IF;

			IF(l_delivery_type=DELIVERY_TYPE_CHILD)
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Attempt to rate a child delivery..error');
				raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;

			END IF;



		END IF;

		l_rating_API_fail:='N';

		IF(p_ss_rate_sort_atr_rec.trip_id IS NOT NULL)
		THEN
			--Trip Centric

			FTE_TRIP_RATING_GRP.Compare_Trip_Rates (
			p_api_version		=>1.0,
			p_init_msg_list         =>FND_API.G_FALSE,
			p_init_prc_log		=>'N',
			p_trip_id               =>p_ss_rate_sort_atr_rec.trip_id,
			p_lane_sched_id_tab     =>l_lane_sched_id_tab,
			p_lane_sched_tab        =>l_lane_sched_tab,
			p_mode_tab              =>l_mode_tab,
			p_service_type_tab      =>l_service_type_tab,
			p_vehicle_type_tab      =>l_vehicle_type_tab,
			p_dep_date              =>p_ss_rate_sort_atr_rec.dep_date_from,
			p_arr_date              =>p_ss_rate_sort_atr_rec.arr_date_to,
			x_lane_sched_id_tab     =>l_out_lane_sched_id_tab,
			x_lane_sched_tab        =>l_out_lane_sched_tab,
			x_mode_tab              =>l_out_mode_tab,
			x_service_type_tab      =>l_out_service_type_tab,
			x_vehicle_type_tab      =>l_out_vehicle_type_tab,
			x_sum_rate_tab          =>l_sum_rate_tab,
			x_sum_rate_curr_tab     =>l_sum_rate_curr_tab,
			x_request_id            =>x_rating_request_id,
			x_msg_count		=>l_msg_count,
			x_msg_data		=>l_msg_data,
			x_return_status         =>l_return_status) ;

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Compare_Trip_Rates status:'||l_return_status);
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
					THEN

						FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Compare_Trip_Rates FAILED');
						--Convert E to W as WB did in 10+
						--ServicePriceCompareVOImpl.java 115.29.11510.1
						--raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
						l_warning_count:=l_warning_count+1;
						l_rating_API_fail:='Y';
					ELSE
						--If there is an unexpeted error it is propogated
						raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;

					END IF;
				ELSE
					l_warning_count:=l_warning_count+1;

				END IF;
			END IF;



		ELSIF (((l_delivery_type IS NULL) OR (l_delivery_type <> DELIVERY_TYPE_CONSOL)) AND ((p_ss_rate_sort_atr_rec.delivery_id IS NOT NULL) OR (p_ss_rate_sort_atr_rec.delivery_leg_id IS NOT NULL)))
		THEN
			--Delivery/Leg Centric


			FTE_FREIGHT_PRICING.shipment_price_compare (
			p_init_msg_list		=>fnd_api.g_false,
			p_init_prc_log	        =>'N',
			p_delivery_id           =>p_ss_rate_sort_atr_rec.delivery_id,
			p_trip_id		=>p_ss_rate_sort_atr_rec.trip_id,
			p_lane_sched_id_tab     =>l_lane_sched_id_tab,
			p_lane_sched_tab        =>l_lane_sched_tab,
			p_mode_tab              =>l_mode_tab,
			p_service_type_tab      =>l_service_type_tab,
			p_vehicle_type_tab      =>l_vehicle_type_tab,
			p_dep_date              =>p_ss_rate_sort_atr_rec.dep_date_from,
			p_arr_date              =>p_ss_rate_sort_atr_rec.arr_date_to,
			p_pickup_location_id	=>p_ss_rate_sort_atr_rec.origin_location_id,
			p_dropoff_location_id	=>p_ss_rate_sort_atr_rec.destination_location_id,
			x_lane_sched_id_tab     =>l_out_lane_sched_id_tab,
			x_lane_sched_tab        =>l_out_lane_sched_tab,
			x_mode_tab              =>l_out_mode_tab,
			x_service_type_tab      =>l_out_service_type_tab,
			x_vehicle_type_tab      =>l_out_vehicle_type_tab,
			x_sum_rate_tab          =>l_sum_rate_tab,
			x_sum_rate_curr_tab     =>l_sum_rate_curr_tab,
			x_request_id            =>x_rating_request_id,
			x_return_status         =>l_return_status) ;

			FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'shipment_price_compare status:'||l_return_status);

			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
			THEN
				IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
				THEN
					IF (l_return_status <> WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR)
					THEN
						FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'shipment_price_compare FAILED');
						--Convert E to W as WB did in 10+
						--ServicePriceCompareVOImpl.java 115.29.11510.1
						--raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
						l_warning_count:=l_warning_count+1;
						l_rating_API_fail:='Y';
					ELSE
						--If there is an unexpeted error it is propogated
						raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;

					END IF;

				ELSE
					l_warning_count:=l_warning_count+1;
				END IF;
			END IF;


		END IF;

		IF(l_rating_API_fail='Y')
		THEN
			l_rate_rank_tab:=l_elim_rank_tab;
			l_rate_rank_ref:=l_elim_rank_ref;

		ELSE

			--Populate rating output into the rank structures

			k:=1;
			j:=l_elim_rank_tab.FIRST;
			i:=l_out_lane_sched_id_tab.FIRST;
			l_single_currency:=NULL;
			WHILE(i IS NOT NULL)
			LOOP

				--If the lane id of the rank tab is the same as the output lane id it could be the case that a
				--TL lane with multiple vehicles.
				--Only increment the lane index if we are through with all the outputs which have the same lane id
				IF((j IS NOT NULL) AND (l_elim_rank_tab(j).mode_of_transport='TRUCK') AND  (((l_out_lane_sched_tab(i)='L') AND (l_out_lane_sched_id_tab(i)<>l_elim_rank_tab(j).lane_id))
					OR((l_out_lane_sched_tab(i)='S') AND (l_out_lane_sched_id_tab(i)<>l_elim_rank_tab(j).schedule_id))))
				THEN
					j:=l_elim_rank_tab.NEXT(j);

				END IF;



				IF((j IS NOT NULL ) AND (((l_out_lane_sched_tab(i)='L') AND (l_out_lane_sched_id_tab(i)=l_elim_rank_tab(j).lane_id))
					OR((l_out_lane_sched_tab(i)='S') AND (l_out_lane_sched_id_tab(i)=l_elim_rank_tab(j).schedule_id))))
				THEN

					l_rate_rank_tab(k):=l_elim_rank_tab(j);
					IF(l_out_vehicle_type_tab(i) IS NOT NULL)
					THEN

						Get_Vehicle_Item_Org(
							p_vehicle_type=>l_out_vehicle_type_tab(i),
							x_vehicle_item_id=>l_rate_rank_tab(k).vehicle_item_id,
							x_vehicle_item_org=>l_rate_rank_tab(k).vehicle_org_id,
							x_return_status=>l_return_status);


						IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
						THEN
							IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
							THEN
								raise FTE_FREIGHT_PRICING_UTIL.g_get_veh_item_org_fail;
							END IF;
						END IF;

					END IF;

					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-1');

					IF ((l_sum_rate_tab(i) IS NOT NULL) AND (l_sum_rate_curr_tab(i) IS NOT NULL)
					AND (l_sum_rate_tab(i)> 0) AND (l_sum_rate_curr_tab(i)<>'NULL'))
					THEN

					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-2');
						l_rate_rank_tab(k).estimated_rate:=l_sum_rate_tab(i);
						l_rate_rank_tab(k).currency_code:=l_sum_rate_curr_tab(i);


					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-3');
						IF (l_single_currency IS NULL)
						THEN
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-4');
							l_single_currency:=l_rate_rank_tab(k).currency_code;
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-5');
						END IF;

						IF(l_single_currency = l_rate_rank_tab(k).currency_code)
						THEN
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-6');
							l_single_curr_rate:=l_rate_rank_tab(k).estimated_rate;

						ELSE
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-7');
							l_single_curr_rate:=NULL;
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-7.1');
							l_single_curr_rate:=GL_CURRENCY_API.convert_amount(
								     l_rate_rank_tab(k).currency_code,
								     l_single_currency,
								     SYSDATE,
								     'Corporate',
								     l_rate_rank_tab(k).estimated_rate
								     );
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-7.2');

							IF (l_single_curr_rate IS NULL)
							THEN
								FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_tl_conv_currency_fail');
								raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;

							END IF;

						END IF;
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-8');
						l_rate_rank_tab(k).single_curr_rate:=l_single_curr_rate;
					FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'DBG-9');

					END IF;
					--Mantain reference to original rank input
					l_rate_rank_ref(k):=l_elim_rank_ref(j);

					k:=k+1;


				END IF;

				--Increment lane_rank_tab index only if mode is not truck
				-- If the mode is truck the same lane may have multiple vehicles
				--In which case the increment is done only if the lane is different
				IF((j IS NOT NULL) AND (l_elim_rank_tab(j).mode_of_transport<>'TRUCK'))
				THEN
					j:=l_elim_rank_tab.NEXT(j);
				END IF;

				i:=l_out_lane_sched_id_tab.NEXT(i);
			END LOOP;

		END IF;

		l_elim_rank_tab.DELETE;
		l_elim_rank_ref.DELETE;



		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ranks after  Rating');
		Display_Rank_Tab(p_rank_tab=>l_rate_rank_tab,
				p_input_ref=>l_rate_rank_ref);


		Seq_Tender_Sort(
			p_ss_rate_sort_tab=>l_rate_rank_tab,
			p_input_ref=>l_rate_rank_ref,
			x_ss_rate_sort_tab=>l_sort_rank_tab,
			x_input_ref=>l_sort_rank_ref,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_seq_tender_sort_fail');
				raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
			END IF;
		END IF;

		l_rate_rank_tab.DELETE;
		l_rate_rank_ref.DELETE;

		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ranks after  Sorting');
		Display_Rank_Tab(p_rank_tab=>l_sort_rank_tab,
			p_input_ref=>l_sort_rank_ref);


		Remove_Duplicate_Lanes(
			p_ss_rate_sort_tab=>l_sort_rank_tab,
			p_input_ref=>l_sort_rank_ref,
			x_ss_rate_sort_tab=>x_ss_rate_sort_tab,
			x_input_ref=>l_elim_rank_ref,
			x_return_status=>l_return_status);

		IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS
		THEN
			IF l_return_status <> WSH_UTIL_CORE.G_RET_STS_WARNING
			THEN
				FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'g_elim_dup_rank_fail');
				raise FTE_FREIGHT_PRICING_UTIL.g_unexp_err;
			END IF;
		END IF;


		l_sort_rank_tab.DELETE;
		l_sort_rank_ref.DELETE;


		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Ranks after  Eliminating duplicates');
		Display_Rank_Tab(p_rank_tab=>x_ss_rate_sort_tab,
			p_input_ref=>l_elim_rank_ref);

	ELSE
		--Lane search returned no results
		FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'No lanes from lane search');
		x_rating_request_id:=NULL;
		x_ss_rate_sort_tab:=p_ss_rate_sort_tab;

	END IF;

	IF (l_warning_count > 0)
	THEN
		x_return_status:=WSH_UTIL_CORE.G_RET_STS_WARNING;
	END IF;

	FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_DBG,'Search_Rate_Sort return status:'||x_return_status);

	FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Rate_Sort');

	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;



   EXCEPTION

   WHEN others THEN
        x_return_status := WSH_UTIL_CORE.G_RET_STS_UNEXP_ERROR;
        FTE_FREIGHT_PRICING_UTIL.set_exit_exception('Search_Rate_Sort','g_others');
        FTE_FREIGHT_PRICING_UTIL.print_msg(FTE_FREIGHT_PRICING_UTIL.G_ERR,'Unexpected Error : '||SQLCODE||' : '||SQLERRM);
        FTE_FREIGHT_PRICING_UTIL.unset_method(l_log_level,'Search_Rate_Sort');
	IF(p_init_prc_log='Y')
	THEN
		FTE_FREIGHT_PRICING_UTIL.close_logs;
	END IF;


END Search_Rate_Sort;



END FTE_TRIP_RATING_GRP;

/
