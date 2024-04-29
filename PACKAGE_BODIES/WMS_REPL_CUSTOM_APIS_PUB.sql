--------------------------------------------------------
--  DDL for Package Body WMS_REPL_CUSTOM_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_REPL_CUSTOM_APIS_PUB" AS
/* $Header: WMSREPCB.pls 120.0 2007/12/30 22:42:44 satkumar noship $  */


PROCEDURE print_debug(p_err_msg VARCHAR2) IS
BEGIN
   inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg,
					p_module => 'WMS_REPL_CUSTOM_APIS_PUB',
					p_level => 4);
END print_debug;


PROCEDURE get_consol_repl_demand_cust
  (x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER,
   x_msg_data             OUT NOCOPY VARCHAR2,
   x_consol_item_repl_tbl OUT NOCOPY WMS_REPLENISHMENT_PVT.consol_item_repl_tbl
   ) IS

      l_progress                 VARCHAR2(10);
      l_debug                    NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN
   IF (l_debug = 1) THEN
      print_debug('***Calling GET_CONSOL_REPL_DEMAND_CUST ***');
   END IF;

   -- Set the savepoint
   SAVEPOINT GET_CONSOL_REPL_DEMAND_CUST_SP;
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
   g_is_api_implemented := FALSE;


   --=======================================
   --<Insert custom logic STARTS here>
   --=======================================
   -- QUERY ALL DEMAND RECORDS INSERTED IN THE WMS_REPL_DEMAND_GTMP table
   -- This set of records in the temp table already has filtered records
   -- based ON criteria specified in the Push Replenishment Concurrent Program

   -- Apply any custom logic to add/remove demad lines from this table
   -- RETURN consolidated demand lines in the x_consol_item_repl_tbl PL/SQL table

   --Make sure that the records in x_consol_item_repl_tbl  has correct values filled for fields marked '??' below.
   --Those fields that have values assigned to 0 should always be assigned 0 to be calculated later in the program.

   -- PROVIDE THESE VALUES:
   --Organization_id = ??
   --Item_id = ??
   --total_demand_qty = ?? (in replenishment UOM)
   --Repl_to_subinventory_code = ??
   --Repl_UOM_code = ?? <<for the specified to_subinventory_code from subinventory set up>>
   --date_required := ??; -- date on original demand lines


   -- NO VALUE SHOULD BE CHANGED BELOW THIS LINE:
   --available_onhand_qty = 0
   --open_mo_qty = 0
   --final_replenishment_qty = 0




   --=======================================
   --<Insert custom logic ENDS here>
   --=======================================

   IF (l_debug = 1) THEN
      print_debug('***End of GET_CONSOL_REPL_DEMAND_CUST ***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_CONSOL_REPL_DEMAND_CUST_SP;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
	 print_debug('Exiting GET_CONSOL_REPL_DEMAND_CUST - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_CONSOL_REPL_DEMAND_CUST_SP;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
	 print_debug('Exiting GET_CONSOL_REPL_DEMAND_CUST - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
	      ROLLBACK TO GET_CONSOL_REPL_DEMAND_CUST_SP;
	      x_return_status := fnd_api.g_ret_sts_unexp_error;
	      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
		 -- fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
		 fnd_msg_pub.add_exc_msg('WMS_REPL_CUSTOM_APIS_PUB','GET_CONSOL_REPL_DEMAND_CUST');

	      END IF;
	      fnd_msg_pub.count_and_get(p_count => x_msg_count,
					p_data  => x_msg_data);
	      IF (l_debug = 1) THEN
	   	 print_debug('Exiting GET_CONSOL_REPL_DEMAND_CUST - Others exception: ' ||
			     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
	      END IF;


END GET_CONSOL_REPL_DEMAND_CUST;

END WMS_REPL_CUSTOM_APIS_PUB;

/
