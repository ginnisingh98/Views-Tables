--------------------------------------------------------
--  DDL for Package Body WMS_XDOCK_EXCEPTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_XDOCK_EXCEPTION" AS
/* $Header: WMSXDEXB.pls 120.4 2005/10/21 14:37:19 gayu noship $*/

PROCEDURE print_debug(p_err_msg VARCHAR2,
		      p_level NUMBER := 4)
  IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_err_msg,
      p_module => 'WMS_XDOCK_EXCPT',
      p_level => p_level);

END;

PROCEDURE find_exception
  (  x_errbuf            OUT nocopy VARCHAR2
    ,x_retcode           OUT nocopy NUMBER
    ,p_org_id            IN         NUMBER
    ,p_look_ahead_time   IN         NUMBER )
  IS
     l_debug    NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
     l_progress VARCHAR2(10) := '10';
     l_module_name VARCHAR2(30) := 'FIND_EXCEPTION';
     l_return_status             VARCHAR2(30);
     l_msg_count                 NUMBER;
     l_msg_data                  VARCHAR2(10000);

     l_now                   DATE;
     l_dock_start_time       DATE;
     l_dock_mean_time        DATE;
     l_dock_end_time         DATE;
     l_expected_supply_time  DATE;
     l_expected_demand_time  DATE;
     l_buffer_interval           INTERVAL DAY TO SECOND;
     l_op_interval               INTERVAL DAY TO SECOND;
     l_xdock_window_interval     INTERVAL DAY TO SECOND;
     l_exception_code        VARCHAR2(150);
     l_update_flag           VARCHAR2(1);
     l_dummy_sn              inv_reservation_global.serial_number_tbl_type;

     l_new_reservation  inv_reservation_global.mtl_reservation_rec_type;
     l_xdock_criteria_rec wms_crossdock_criteria%ROWTYPE;
     l_num_exception_thrown NUMBER;
     l_status BOOLEAN;
BEGIN

   l_progress := '001';
   l_now := Sysdate;
   l_num_exception_thrown := 0;
   x_retcode := 0;

   IF (l_debug = 1) THEN
      print_debug('Entering find_exception...');
      print_debug('Current time is ' || l_now);
      print_debug(' p_org_id          => '||p_org_id);
      print_debug(' p_look_ahead_time =>'||p_look_ahead_time);
   END IF;


   --Query 1: All unstaged crossdock peggins whose corresponding
   --         expected_supply_date<= l_now + p_look_ahead_time window AND
   --      2: All crossdock peggings with exceptions

   l_progress := '002';
   FOR l_xdock_pegging_rec IN (SELECT  reservation_id
			        ,      crossdock_criteria_id
				,      supply_source_type_id
				,      supply_source_header_id
				,      supply_source_line_id
				,      supply_source_line_detail
				,      demand_source_type_id
				,      demand_source_header_id
				,      demand_source_line_id
				,      demand_source_line_detail
				,      supply_receipt_date
				,      exception_code
			        ,      demand_ship_date
			        FROM mtl_reservations
				WHERE Nvl(crossdock_flag,'N') = 'Y'
				AND Nvl(staged_flag, 'N') = 'N' --???
				AND supply_source_type_id <> 13 --??? not inventory
				AND (supply_receipt_date <= l_now + p_look_ahead_time
				     OR
				     exception_code IS NOT NULL)
			        AND organization_id = p_org_id) LOOP

      l_update_flag := 'N';
      l_exception_code := NULL;
      l_new_reservation.demand_ship_date := fnd_api.g_miss_date;
      l_new_reservation.supply_receipt_date := fnd_api.g_miss_date;

      l_progress := '003';
      BEGIN
	 IF (l_debug = 1) THEN
	    print_debug('Looking at rsv:'||l_xdock_pegging_rec.reservation_id);
	    print_debug(' crossdock_criteria_id:'||l_xdock_pegging_rec.crossdock_criteria_id);
	    print_debug(' supply_source_type_id:'||l_xdock_pegging_rec.supply_source_type_id);
	    print_debug(' supply_source_header_id:'||l_xdock_pegging_rec.supply_source_header_id);
	    print_debug(' supply_source_line_id:'||l_xdock_pegging_rec.supply_source_line_id);
	    print_debug(' supply_source_line_detail:'||l_xdock_pegging_rec.supply_source_line_detail);
	    print_debug(' demand_source_type_id:'||l_xdock_pegging_rec.demand_source_type_id);
	    print_debug(' demand_source_header_id:'||l_xdock_pegging_rec.demand_source_header_id);
	    print_debug(' demand_source_line_id:'||l_xdock_pegging_rec.demand_source_line_id);
	    print_debug(' demand_source_line_detail:'||l_xdock_pegging_rec.demand_source_line_detail);
	    print_debug(' supply_receipt_date:'||l_xdock_pegging_rec.supply_receipt_date);
	    print_debug(' demand_ship_date:'||l_xdock_pegging_rec.demand_ship_date);
	    print_debug(' exception_code:'||l_xdock_pegging_rec.exception_code);
	 END IF;

	 l_progress := '004';
	 -- Get BT, OPT, CW by crossdock criteria ???
	 l_xdock_criteria_rec := wms_xdock_pegging_pub.get_crossdock_criteria(l_xdock_pegging_rec.crossdock_criteria_id);

	 l_buffer_interval := numtodsinterval(Nvl(l_xdock_criteria_rec.buffer_interval,0),
					      Nvl(l_xdock_criteria_rec.buffer_uom,'HOUR'));
	 l_op_interval := numtodsinterval(Nvl(l_xdock_criteria_rec.processing_interval ,0),
					  Nvl(l_xdock_criteria_rec.processing_uom,'HOUR'));
	 l_xdock_window_interval := numtodsinterval(Nvl(l_xdock_criteria_rec.window_interval ,0),
						    Nvl(l_xdock_criteria_rec.window_uom,'HOUR'));

	 IF (l_debug = 1) THEN
	    print_debug('l_buffer_interval           => '||l_buffer_interval);
	    print_debug('l_op_interval               => ' || l_op_interval);
	    print_debug('l_xdock_window_interval     => ' || l_xdock_window_interval);
	 END IF;

	 -- Call get_expected_time to get the actual expected_supply_date
	 l_progress := '007';
	 IF (l_xdock_pegging_rec.supply_source_type_id = 27) THEN
	    --For reservations in RCV, the expected supply time will
	    --always be now
	    l_expected_supply_time := l_now;
	  ELSE
	    wms_xdock_pegging_pub.get_expected_time
	      ( p_source_type_id         => l_xdock_pegging_rec.supply_source_type_id
		,p_source_header_id       => l_xdock_pegging_rec.supply_source_header_id
		,p_source_line_id         => l_xdock_pegging_rec.supply_source_line_id
		,p_source_line_detail_id  => l_xdock_pegging_rec.supply_source_line_detail
		,p_supply_or_demand       => 1 --SUPPLY
		,p_crossdock_criterion_id => l_xdock_pegging_rec.crossdock_criteria_id --???
		,x_return_status          => l_return_status
		,x_msg_count              => l_msg_count
		,x_msg_data               => l_msg_data
		,x_dock_start_time        => l_dock_start_time
		,x_dock_mean_time         => l_dock_mean_time
		,x_dock_end_time          => l_dock_end_time
		,x_expected_time          => l_expected_supply_time);
	 END IF;
	 l_progress := '008';

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Error getting expected supply time!');
	    END IF;
	    l_progress := '009';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 -- Call get_expected_time to get the actual expected_demand_date
	 l_progress := '010';
	 wms_xdock_pegging_pub.get_expected_time
	   ( p_source_type_id         => l_xdock_pegging_rec.demand_source_type_id
	     ,p_source_header_id       => l_xdock_pegging_rec.demand_source_header_id
	     ,p_source_line_id         => l_xdock_pegging_rec.demand_source_line_id
	     ,p_source_line_detail_id  => l_xdock_pegging_rec.demand_source_line_detail
	     ,p_supply_or_demand       => 2 --demand
	     ,p_crossdock_criterion_id => l_xdock_pegging_rec.crossdock_criteria_id --???
	     ,x_return_status          => l_return_status
	     ,x_msg_count              => l_msg_count
	     ,x_msg_data               => l_msg_data
	     ,x_dock_start_time        => l_dock_start_time
	     ,x_dock_mean_time         => l_dock_mean_time
	     ,x_dock_end_time          => l_dock_end_time
	     ,x_expected_time          => l_expected_demand_time);
	 l_progress := '011';

	 IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
	    IF (l_debug = 1) THEN
	       print_debug('Error getting expected demand time!');
	    END IF;
	    l_progress := '012';
	    RAISE fnd_api.g_exc_unexpected_error;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('l_xdock_pegging_rec.supply_receipt_date:'||
			To_char(l_xdock_pegging_rec.supply_receipt_date,'yyyy/mm/dd hh:mi:ss'));
	    print_debug('l_expected_supply_time:'||To_char(l_expected_supply_time,'yyyy/mm/dd hh:mi:ss'));
	    print_debug('l_xdock_pegging_rec.demand_ship_date:'||To_char(l_xdock_pegging_rec.demand_ship_date,'yyyy/mm/dd hh:mi:ss'));
	    print_debug('l_expected_demand_time:'||To_char(l_expected_demand_time,'yyyy/mm/dd hh:mi:ss'));
	 END IF;

	 --{{
	 --Create a peg, manuipulate document so that actual expected
	 --receipt time is different from the supply_receipt_date of the peg.
	 --After exception program is run, make sure that the
	 --supply_receipt_date is updated }}
	 IF (l_expected_supply_time <> l_xdock_pegging_rec.supply_receipt_date) THEN
	    -- needs to update supply_date on reservation
	    -- ??? Need to update demand time also ???
	    l_new_reservation.supply_receipt_date := l_expected_supply_time;
	    l_update_flag := 'Y';
	 END IF;

	 IF (l_expected_demand_time <> l_xdock_pegging_rec.demand_ship_date) THEN
	    -- needs to update demand on reservation
	    l_new_reservation.demand_ship_date := l_expected_demand_time;
	    l_update_flag := 'Y';
	 END IF;

	 --Start checking for exceptions

	 -- Exception happens under following situations:
	 -- l_expected_supply_time - EST
	 -- l_expected_demand_time - EDT
	 -- l_now - NOW
	 -- exception_code - EC
	 --
	 -- if EST < NOW then
	 --   if EDT < NOW then

	 --     if EDT > EST then
	 --       if EDT <= EST + BT then EC = LE
	 --       elsif EDT <= EST + BT + OPT then EC = LW
	 --       elsif EDT > EST + BT + OPT + XDW then EC = LW
	 --      else -- this means that demand was scheduled to be shipped anytime today.
	 --       if NOW > EST + XDW then EC = LW

	 --   elsif EDT <= NOW + BT then EC = LE
	 --   elsif EDT <= NOW + BT + OPT then EC = LW
	 --   elsif EDT > EST + BT + OPT + XDW then EC = LW
	 -- else
	 --   if EDT < EST then
	 --     null
	 --   elsif EDT <= EST + BT then EC = SE
	 --   elsif EDT <= EST + BT + OPT then EC = SW
	 --   elsif EDT > EST + BT + OPT + XDW then EC = SW

	 IF (l_expected_supply_time < l_now) THEN
	    IF (l_expected_demand_time < l_now) THEN
	       IF (l_expected_demand_time > l_expected_supply_time) THEN
		  IF (l_expected_demand_time<=l_expected_supply_time+l_buffer_interval) THEN
		     l_exception_code := 'LE';
		   ELSIF (l_expected_demand_time<=l_expected_supply_time+l_buffer_interval+l_op_interval) THEN
		     l_exception_code := 'LW';
		   ELSIF (l_expected_demand_time>l_expected_supply_time+l_buffer_interval+l_op_interval+l_xdock_window_interval) THEN
		     l_exception_code := 'LW';
		   ELSE
		     l_exception_code := NULL;
		  END IF;
		ELSE
		  IF (l_now >l_expected_supply_time + l_xdock_window_interval )THEN
		     l_exception_code := 'LW';
		  END IF;
	       END IF;
	     --For the following three cases, treat EST as NOW
	     ELSIF l_expected_demand_time <= (l_now + l_buffer_interval) THEN
	       l_exception_code := 'LE';
	     ELSIF l_expected_demand_time <= (l_now + l_buffer_interval + l_op_interval) THEN
	       l_exception_code := 'LW';
	     ELSIF l_expected_demand_time > (l_expected_supply_time + l_buffer_interval + l_op_interval + l_xdock_window_interval) THEN
	       l_exception_code := 'LW';
	     ELSE
	       l_exception_code := NULL;
	    END IF;
	  ELSE
	    IF (l_expected_demand_time < l_expected_supply_time) THEN
	       l_exception_code := NULL;
	     ELSIF (l_expected_demand_time <= l_expected_supply_time + l_buffer_interval) THEN
	       --Zone 1: EDT <= EST + BT.  Xdock not feasible
	       l_exception_code := 'SE';
	     ELSIF (l_expected_demand_time <= l_expected_supply_time + l_buffer_interval + l_op_interval) THEN
	       --Zone 2: EDT <= EST + BT + OPT.  Manual expedite needed
	       l_exception_code := 'SW';
	     ELSIF (l_expected_demand_time > l_buffer_interval + l_op_interval + l_xdock_window_interval) THEN
	       --Zone 4: EDT > EST + BT + OPT + Xdock Window.  Unnecessary wait
	       l_exception_code := 'SW';
	     ELSE
	       --Zone 4: No exception
	       l_exception_code := NULL;
	    END IF;
	 END IF;

	 IF (l_debug = 1) THEN
	    print_debug('l_update_flag: '||l_update_flag);
	    print_debug('l_exception_code: '||l_exception_code);
	 END IF;

	 IF (Nvl(l_xdock_pegging_rec.exception_code,'@@@') <> Nvl(l_exception_code,'@@@')) THEN
	    l_update_flag := 'Y';
	 END IF;

	 IF (l_update_flag = 'Y') THEN

	    BEGIN
	       UPDATE mtl_reservations
		 SET  exception_code = l_exception_code
		 ,    supply_receipt_date = Decode(l_new_reservation.supply_receipt_date,
						   fnd_api.g_miss_date,
						   supply_receipt_date,
						   l_new_reservation.supply_receipt_date)
		 ,    demand_ship_date = Decode(l_new_reservation.demand_ship_date,
						fnd_api.g_miss_date,
						demand_ship_date,
						l_new_reservation.demand_ship_date)
		 WHERE reservation_id = l_xdock_pegging_rec.reservation_id;
	    EXCEPTION
	       WHEN OTHERS THEN
		  IF (l_debug = 1) THEN
		     print_debug('Exception occurred at progress: '||l_progress);
		     print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM);
		  END IF;
		  RAISE fnd_api.g_exc_unexpected_error;
	    END ;

	    l_progress := '015';

	 END IF;
	 l_progress := '016';
      EXCEPTION
	 WHEN OTHERS THEN
	    IF (l_debug = 1) THEN
	       print_debug('Exception occurred at progress: '||l_progress);
	       print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM);
	    END IF;
	    l_num_exception_thrown := l_num_exception_thrown + 1;
      END;
   END LOOP;

   l_status := wms_xdock_pegging_pub.clear_crossdock_cache;

   IF (l_num_exception_thrown > 0) THEN
      x_retcode := 1; --Return a warning
   END IF;

   IF (l_debug = 1) THEN
      print_debug('Number of exception thrown:'||l_num_exception_thrown);
      print_debug('x_retcode: '||x_retcode);
      print_debug('Successfully exiting find_exceptions!');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF (l_debug = 1) THEN
	 print_debug('Exception occurred at progress: '||l_progress);
	 print_debug('SQLCODE:'||SQLCODE||' SQLERRM:'||SQLERRM);
      END IF;
      l_status := wms_xdock_pegging_pub.clear_crossdock_cache;
      x_errbuf := 'U';--????
      x_retcode := 2; --Return an error
END find_exception;
END wms_xdock_exception;

/
