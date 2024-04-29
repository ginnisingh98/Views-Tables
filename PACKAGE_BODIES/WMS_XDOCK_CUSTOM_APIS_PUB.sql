--------------------------------------------------------
--  DDL for Package Body WMS_XDOCK_CUSTOM_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_XDOCK_CUSTOM_APIS_PUB" AS
/* $Header: WMSXDCAB.pls 120.1 2005/06/24 14:20:22 appldev noship $ */


-- Global constants holding the package name and package version
g_pkg_name    CONSTANT VARCHAR2(30)  := 'WMS_XDOCK_CUSTOM_APIS_PUB';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSXDCAB.pls 120.1 2005/06/24 14:20:22 appldev noship $';


-- Procedure to print debug messages.
-- We will rely on the caller to this procedure to determine if debug logging
-- should be done or not instead of querying for the profile value every time.
PROCEDURE print_debug(p_debug_msg IN VARCHAR2)
  IS
BEGIN
   inv_mobile_helper_functions.tracelog
     (p_err_msg => p_debug_msg,
      p_module  => 'WMS_XDOCK_CUSTOM_APIS_PUB',
      p_level   => 4);
END;


PROCEDURE Get_Crossdock_Criteria
  (p_wdd_release_record         IN      WSH_PR_CRITERIA.relRecTyp,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_crossdock_criteria_id      OUT     NOCOPY NUMBER)
  IS
     l_api_name                 CONSTANT VARCHAR2(30) := 'Get_Crossdock_Criteria';
     l_progress                 VARCHAR2(10);
     l_debug                    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Get_Crossdock_Criteria with the following parameters***');
      print_debug('Package Version: => ' || g_pkg_version);
   END IF;

   -- Set the savepoint
   SAVEPOINT Get_Crossdock_Criteria_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- If the custom API is not implemented, return a value of FALSE for the output
   -- variable 'x_api_is_implemented'.  When custom logic is implemented, the line below
   -- should be modified to return a TRUE value instead.
   x_api_is_implemented := FALSE;

   -- <Insert custom logic here>


   IF (l_debug = 1) THEN
      print_debug('***End of Get_Crossdock_Criteria***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Crossdock_Criteria_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Crossdock_Criteria - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Crossdock_Criteria_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Crossdock_Criteria - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Get_Crossdock_Criteria_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Crossdock_Criteria - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Get_Crossdock_Criteria;


PROCEDURE Get_Expected_Time
  (p_source_type_id             IN      NUMBER,
   p_source_header_id           IN      NUMBER,
   p_source_line_id             IN      NUMBER,
   p_source_line_detail_id      IN      NUMBER,
   p_supply_or_demand           IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   p_dock_schedule_method       IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_mean_time             OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Expected_Time';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Custom Get_Expected_Time with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
   END IF;

   -- Set the savepoint
   SAVEPOINT Get_Expected_Time_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- If the custom API is not implemented, return a value of FALSE for the output
   -- variable 'x_api_is_implemented'.  When custom logic is implemented, the line below
   -- should be modified to return a TRUE value instead.
   x_api_is_implemented := FALSE;

   -- <Insert custom logic here>


   IF (l_debug = 1) THEN
      print_debug('***End of Get_Expected_Time***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Expected_Time_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Time - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Expected_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Time - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Get_Expected_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Time - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Get_Expected_Time;


PROCEDURE Get_Expected_Delivery_Time
  (p_delivery_id                IN      NUMBER,
   p_crossdock_criterion_id     IN      NUMBER,
   p_dock_schedule_method       IN      NUMBER,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_dock_appointment_id        OUT     NOCOPY NUMBER,
   x_dock_start_time            OUT     NOCOPY DATE,
   x_dock_end_time              OUT     NOCOPY DATE,
   x_expected_time              OUT     NOCOPY DATE)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Get_Expected_Delivery_Time';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Get_Expected_Delivery_Time with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
   END IF;

   -- Set the savepoint
   SAVEPOINT Get_Expected_Delivery_Time_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- If the custom API is not implemented, return a value of FALSE for the output
   -- variable 'x_api_is_implemented'.  When custom logic is implemented, the line below
   -- should be modified to return a TRUE value instead.
   x_api_is_implemented := FALSE;

   -- <Insert custom logic here>


   IF (l_debug = 1) THEN
      print_debug('***End of Get_Expected_Delivery_Time***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_Expected_Delivery_Time_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Delivery_Time - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_Expected_Delivery_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Delivery_Time - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Get_Expected_Delivery_Time_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_Expected_Delivery_Time - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Get_Expected_Delivery_Time;


PROCEDURE Sort_Supply_Lines
  (p_wdd_release_record         IN      WSH_PR_CRITERIA.relRecTyp,
   p_prioritize_documents       IN      NUMBER,
   p_shopping_basket_tb         IN      WMS_XDock_Pegging_Pub.shopping_basket_tb,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_sorted_order_tb            OUT     NOCOPY WMS_XDock_Pegging_Pub.sorted_order_tb)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Sort_Supply_Lines';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Sort_Supply_Lines with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
   END IF;

   -- Set the savepoint
   SAVEPOINT Sort_Supply_Lines_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- If the custom API is not implemented, return a value of FALSE for the output
   -- variable 'x_api_is_implemented'.  When custom logic is implemented, the line below
   -- should be modified to return a TRUE value instead.
   x_api_is_implemented := FALSE;

   -- <Insert custom logic here>


   IF (l_debug = 1) THEN
      print_debug('***End of Sort_Supply_Lines***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Sort_Supply_Lines_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Sort_Supply_Lines - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Sort_Supply_Lines_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Sort_Supply_Lines - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Sort_Supply_Lines_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Sort_Supply_Lines - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Sort_Supply_Lines;


PROCEDURE Sort_Demand_Lines
  (p_move_order_line_id         IN      NUMBER,
   p_prioritize_documents       IN      NUMBER,
   p_shopping_basket_tb         IN      WMS_XDock_Pegging_Pub.shopping_basket_tb,
   x_return_status              OUT 	NOCOPY VARCHAR2,
   x_msg_count                  OUT 	NOCOPY NUMBER,
   x_msg_data                   OUT 	NOCOPY VARCHAR2,
   x_api_is_implemented         OUT     NOCOPY BOOLEAN,
   x_sorted_order_tb            OUT     NOCOPY WMS_XDock_Pegging_Pub.sorted_order_tb)
  IS
     l_api_name           CONSTANT VARCHAR2(30) := 'Sort_Demand_Lines';
     l_progress           VARCHAR2(10);
     l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling Sort_Demand_Lines with the following parameters***');
      print_debug('Package Version: ==========> ' || g_pkg_version);
   END IF;

   -- Set the savepoint
   SAVEPOINT Sort_Demand_Lines_sp;
   l_progress := '10';

   -- Initialize message list to clear any existing messages
   fnd_msg_pub.initialize;
   l_progress := '20';

   -- Initialize API return status to success
   x_return_status := fnd_api.g_ret_sts_success;
   l_progress := '30';

   -- If the custom API is not implemented, return a value of FALSE for the output
   -- variable 'x_api_is_implemented'.  When custom logic is implemented, the line below
   -- should be modified to return a TRUE value instead.
   x_api_is_implemented := FALSE;

   -- <Insert custom logic here>


   IF (l_debug = 1) THEN
      print_debug('***End of Sort_Demand_Lines***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Sort_Demand_Lines_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Sort_Demand_Lines - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Sort_Demand_Lines_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Sort_Demand_Lines - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Sort_Demand_Lines_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Sort_Demand_Lines - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Sort_Demand_Lines;


END WMS_XDOCK_CUSTOM_APIS_PUB;


/
