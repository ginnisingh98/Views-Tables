--------------------------------------------------------
--  DDL for Package Body WMS_WP_CUSTOM_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WP_CUSTOM_APIS_PUB" AS
  /* $Header: WMSWPCAB.pls 120.2.12010000.1 2009/03/25 09:55:20 shrmitra noship $ */


PROCEDURE print_debug(p_err_msg VARCHAR2) IS
BEGIN
   inv_mobile_helper_functions.tracelog(p_err_msg => p_err_msg,
					p_module => 'WMS_REPL_CUSTOM_APIS_PUB',
					p_level => 4);
END print_debug;


PROCEDURE create_wave_lines_cust(p_wave_header_id                   NUMBER,
                                     x_api_is_implemented         OUT   NOCOPY BOOLEAN,
                                     x_custom_line_tbl            OUT   NOCOPY wms_wave_planning_pvt.line_tbl_typ,
                                     x_custom_line_action_tbl     OUT   NOCOPY wms_wave_planning_pvt.action_tbl_typ,
                                     x_return_status              OUT 	NOCOPY VARCHAR2,
                                     x_msg_count                  OUT 	NOCOPY NUMBER,
                                     x_msg_data                   OUT 	NOCOPY VARCHAR2) IS

l_api_name                 CONSTANT VARCHAR2(30) := 'Get_create_wave_lines_cust';
l_progress                 VARCHAR2(10);
l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
IF (l_debug = 1) THEN
      print_debug('***Entering create_wave_lines_cust***');
END IF;

   -- Set the savepoint
   SAVEPOINT create_wave_lines_cust_sp;
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
   /* To insert lines into lines table, identify all wave lines need to be inserted and populate it into PLSQL table x_custom_line_tbl.
      In corresponding record of PLSQL table x_custom_line_action_tbl populate value 'ADD'. For example:
             x_custom_line_tbl(i).WAVE_HEADER_ID := p_wave_header_id;
             x_custom_line_tbl(i).WAVE_LINE_ID := WMS_WP_WAVE_LINES_S.NEXTVAL;
             x_custom_line_tbl(i).WAVE_LINE_SOURCE := 'OE';
             x_custom_line_tbl(i).WAVE_LINE_STATUS := 'Created';
             x_custom_line_tbl(i).CREATED_BY := fnd_global.user_id;
             x_custom_line_tbl(i).CREATION_DATE := sysdate;
             x_custom_line_tbl(i).LAST_UPDATED_BY := fnd_global.user_id;
             x_custom_line_tbl(i).LAST_UPDATE_DATE := sysdate;
             x_custom_line_tbl(i).LAST_UPDATE_LOGIN := fnd_global.login_id;
             x_custom_line_tbl(i).SOURCE_CODE := l_SOURCE_CODE;
             x_custom_line_tbl(i).SOURCE_HEADER_ID := l_SOURCE_HEADER_ID;
             x_custom_line_tbl(i).SOURCE_LINE_ID := l_SOURCE_LINE_ID;
             x_custom_line_tbl(i).SOURCE_HEADER_NUMBER := l_SOURCE_HEADER_NUMBER;
             x_custom_line_tbl(i).SOURCE_LINE_NUMBER := l_SOURCE_LINE_NUMBER;
             x_custom_line_tbl(i).SOURCE_HEADER_TYPE_ID := l_SOURCE_HEADER_TYPE_ID;
             x_custom_line_tbl(i).SOURCE_DOCUMENT_TYPE_ID := l_SOURCE_DOCUMENT_TYPE_ID;
             x_custom_line_tbl(i).DELIVERY_DETAIL_ID := l_DELIVERY_DETAIL_ID;
             x_custom_line_tbl(i).delivery_id := l_delivery_id;
             x_custom_line_tbl(i).ORGANIZATION_ID := l_ORGANIZATION_ID;
             x_custom_line_tbl(i).INVENTORY_ITEM_ID := l_INVENTORY_ITEM_ID;
             x_custom_line_tbl(i).REQUESTED_QUANTITY := l_REQUESTED_QUANTITY;
             x_custom_line_tbl(i).REQUESTED_QUANTITY_UOM := l_REQUESTED_QUANTITY_UOM;
             x_custom_line_tbl(i).REQUESTED_QUANTITY2 := l_REQUESTED_QUANTITY2;
             x_custom_line_tbl(i).REQUESTED_QUANTITY_UOM2 := l_REQUESTED_QUANTITY_UOM2;
             x_custom_line_tbl(i).DEMAND_SOURCE_HEADER_ID := l_DEMAND_SOURCE_HEADER_ID;
             x_custom_line_tbl(i).NET_WEIGHT := l_NET_WEIGHT;
             x_custom_line_tbl(i).VOLUME := l_VOLUME;
             x_custom_line_tbl(i).NET_VALUE := l_NET_VALUE;
             x_custom_line_tbl(i).REMOVE_FROM_WAVE_FLAG := null;
             x_custom_line_tbl(i).ATTRIBUTE_CATEGORY := null;
             x_custom_line_tbl(i).ATTRIBUTE1 := null;
             x_custom_line_tbl(i).ATTRIBUTE2 := null;
             x_custom_line_tbl(i).ATTRIBUTE3 := null;
             x_custom_line_tbl(i).ATTRIBUTE4 := null;
             x_custom_line_tbl(i).ATTRIBUTE5 := null;
             x_custom_line_tbl(i).ATTRIBUTE6 := null;
             x_custom_line_tbl(i).ATTRIBUTE7 := null;
             x_custom_line_tbl(i).ATTRIBUTE8 := null;
             x_custom_line_tbl(i).ATTRIBUTE9 := null;
             x_custom_line_tbl(i).ATTRIBUTE10 := null;
             x_custom_line_tbl(i).ATTRIBUTE11 := null;
             x_custom_line_tbl(i).ATTRIBUTE12 := null;
             x_custom_line_tbl(i).ATTRIBUTE13 := null;
             x_custom_line_tbl(i).ATTRIBUTE14 := null;
             x_custom_line_tbl(i).ATTRIBUTE15 := null;

             x_custom_line_action_tbl(i) := 'ADD';

       To delete lines already added to the lines tables, pupolate PLSQL table x_custom_line_tbl with line's delivery detail id
       and in corresponding record of PLSQL table x_custom_line_action_tbl populate value 'REMOVE'. For example:
             x_custom_line_tbl(j).DELIVERY_DETAIL_ID := l_DELIVERY_DETAIL_ID;
             x_custom_line_action_tbl(j) := 'REMOVE';

   */
   -- <Custom logic ends here>

   IF (l_debug = 1) THEN
      print_debug('***Exiting create_wave_lines_cust***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_wave_lines_cust_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting create_wave_lines_cust - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_create_wave_lines_cust_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting create_wave_lines_cust - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO create_wave_lines_cust_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        --fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        fnd_msg_pub.add_exc_msg('wms_wp_custom_apis_pub','create_wave_lines_cust');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting create_wave_lines_cust - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;
 END create_wave_lines_cust;



PROCEDURE Get_wave_exceptions_cust(x_api_is_implemented           OUT   NOCOPY BOOLEAN,
                                   p_exception_name               IN VARCHAR2,
                                   p_organization_id              IN NUMBER,
                                   p_wave                         IN NUMBER,
                                   p_exception_entity             IN VARCHAR2,
                                   p_progress_stage               IN VARCHAR2,
                                   p_completion_threshold         IN NUMBER,
                                   p_high_sev_exception_threshold IN NUMBER,
                                   p_low_sev_exception_threshold  IN NUMBER,
                                   p_take_corrective_measures     IN VARCHAR2,
                                   p_release_back_ordered_lines   IN VARCHAR2,
                                   p_action_name                  IN VARCHAR2,
                                   x_return_status              OUT 	NOCOPY VARCHAR2,
                                   x_msg_count                  OUT 	NOCOPY NUMBER,
                                   x_msg_data                   OUT 	NOCOPY VARCHAR2) IS

l_exception_id           NUMBER;
l_progress                 VARCHAR2(10);
l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
IF (l_debug = 1) THEN
      print_debug('***Entering Get_wave_exceptions_cust***');
END IF;

   -- Set the savepoint
   SAVEPOINT Get_wave_exceptions_cust_sp;
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
   /* Determine if particular entity should raise an exception.
   Either upadte table wms_wp_wave_exceptions if exception for a particular entity is already there or insert new exception record. For example:
          INSERT INTO wms_wp_wave_exceptions
              (exception_id,
              exception_name,
              exception_entity,
              exception_stage,
              exception_level,
              exception_msg,
              wave_header_id,
              trip_id,
              delivery_id,
              order_number,
              order_line_id,
              status,
              concurrent_request_id,
              program_id,
              created_by,
              creation_date,
              last_update_date,
              last_updated_by,
              last_update_login)
            VALUES
              (wms_WP_WAVE_exceptions_s.nextval,
              p_exception_name,
              p_exception_entity,
              p_progress_stage,
              p_exception_level,
              l_msg,
              p_wave_id,
              p_trip_id,
              p_delivery_id,
              p_order_number,
              p_order_line_id,
              'Active',
              fnd_global.conc_request_id,
              fnd_global.conc_program_id,
              fnd_global.user_id,
              sysdate,
              sysdate,
              fnd_global.user_id,
            fnd_global.conc_login_id);
   */

   -- For each entity in a wave for which an exception is updated or new exception is logged
   -- call procedure wms_wave_planning_pvt.take_corrective_measures to take any correction action
   /*
    IF (l_debug = 1) THEN
      print_debug('take_corrective_measure is ' || p_take_corrective_measures, l_debug);
    end if;

    IF (p_take_corrective_measures = 'Yes') THEN
            -- call api to take corrective measures
            wms_wave_planning_pvt.take_corrective_measures(l_exception_id,
                                                           p_wave,
                                                           p_entity,
                                                           p_entity_value,
                                                           p_release_back_ordered_lines,
                                                           p_action_name,
                                                           p_organization_id);

   */
   -- <Custom logic ends here>

   IF (l_debug = 1) THEN
      print_debug('***Exiting Get_wave_exceptions_cust***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Get_wave_exceptions_cust_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_wave_exceptions_cust - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Get_wave_exceptions_cust_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_wave_exceptions_cust - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO Get_wave_exceptions_cust_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        --fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        fnd_msg_pub.add_exc_msg('wms_wp_custom_apis_pub','Get_wave_exceptions_cust');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting Get_wave_exceptions_cust - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END Get_wave_exceptions_cust;


PROCEDURE task_release_cust(p_organization_id            IN NUMBER,
                            p_custom_plan_tolerance      IN NUMBER,
                            p_final_mmtt_table           IN OUT nocopy wms_wave_planning_pvt.number_table_type,
                            x_return_status              OUT 	NOCOPY VARCHAR2,
                            x_msg_count                  OUT 	NOCOPY NUMBER,
                            x_msg_data                   OUT 	NOCOPY VARCHAR2
                           ) IS

l_progress                 VARCHAR2(10);
l_debug              NUMBER      := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

BEGIN
IF (l_debug = 1) THEN
      print_debug('***Entering task_release_cust***');
END IF;

   -- Set the savepoint
   SAVEPOINT task_release_cust_sp;
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
   -- x_api_is_implemented := FALSE;

   -- p_custom_plan_tolerance is tolerance value given in task release set up form
   -- p_final_mmtt_table stores transaction_temp_id of all tasks, in any status, fetched from the saved query criteria given in the concurrent program

   -- <Insert custom logic here>
   /* Using custom logic identify taks which needs to be released and update the pl/sql table with the mmtt's that needs to be released
   and pass it back to the task release concurrent program
   */

   -- <Custom logic ends here>

   IF (l_debug = 1) THEN
      print_debug('***Exiting task_release_cust***');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO task_release_cust_sp;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting task_release_cust - Execution error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO task_release_cust_ap;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting task_release_cust - Unexpected error: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO task_release_cust_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        --fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
        fnd_msg_pub.add_exc_msg('wms_wp_custom_apis_pub','task_release_cust');
      END IF;
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
				p_data  => x_msg_data);
      IF (l_debug = 1) THEN
   	 print_debug('Exiting task_release_cust - Others exception: ' ||
		     l_progress ||' '|| TO_CHAR(SYSDATE, 'YYYY-MM-DD HH:DD:SS'));
      END IF;

END task_release_cust;

END wms_wp_custom_apis_pub;


/
