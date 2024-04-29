--------------------------------------------------------
--  DDL for Package Body PN_EXP_TO_EAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_EXP_TO_EAM_PVT" as
/* $Header: PNXPEAMB.pls 120.3.12010000.4 2010/02/12 12:30:38 vgovvala ship $ */

PROCEDURE export_location_to_eam (
            errbuf                  OUT NOCOPY VARCHAR2,
            retcode                 OUT NOCOPY VARCHAR2,
            p_batch_name            IN VARCHAR2,
            p_locn_code_from        IN pn_locations_all.location_code%TYPE,
            p_locn_code_to          IN pn_locations_all.location_code%TYPE,
            p_locn_type             IN pn_locations_all.location_type_lookup_code%TYPE,
            p_organization_id       IN mtl_serial_numbers.current_organization_id%TYPE,
            p_inventory_item_id     IN mtl_serial_numbers.inventory_item_id%TYPE,
            p_owning_department_id  IN mtl_serial_numbers.owning_department_id%TYPE,
            p_maintainable_flag     IN mtl_serial_numbers.maintainable_flag%TYPE)
IS

   location_rec                 pn_locations_all%ROWTYPE;
   l_serial_num                 mtl_eam_asset_num_interface.serial_number%TYPE;
   l_query                      VARCHAR2(4000);
   l_where_clause               VARCHAR2(1000);
   l_industry                   VARCHAR2(30);
   l_installation_status        VARCHAR2(5);
   l_insert                     NUMBER;
   l_insert_mode                NUMBER;
   l_insert_status              NUMBER;
   l_msg_count                  NUMBER;
   l_count_lines                NUMBER;
   l_count_success              NUMBER;
   l_count_failure              NUMBER;
   l_process_flag               BOOLEAN;
   l_return_status              VARCHAR2(250);
   l_msg_data                   VARCHAR2(250);
   l_info                       VARCHAR2(300);
   l_message                    VARCHAR2(300);
   l_cursor                     INTEGER;
   l_rows                       INTEGER;
   l_count                      INTEGER;
   l_locn_type                  VARCHAR2(30);
   l_locn_code_from             VARCHAR2(90);
   l_locn_code_to               VARCHAR2(90);
   l_parent_instance_number     mtl_eam_asset_num_interface.parent_instance_number%TYPE;
   l_parent_inv_id              mtl_eam_asset_num_interface.parent_inventory_item_id%TYPE; /* 8607381 */

   -- Bug 9347599
   CURSOR get_inv_item_id(c_parent_instance_number mtl_eam_asset_num_interface.parent_instance_number%TYPE)
   IS
   SELECT inventory_item_id
   FROM mtl_eam_asset_num_interface
   WHERE instance_number = c_parent_instance_number;

BEGIN

   pnp_debug_pkg.log('PN_EXP_TO_EAM_PVT.EXPORT_LOCATION_TO_EAM (+)');

   l_info := 'Initializing counters ';
   pnp_debug_pkg.log(l_info);

   l_count_lines   := 0;
   l_count_success := 0;
   l_count_failure := 0;

   l_info := 'Checking for EAM installation ';
   pnp_debug_pkg.log(l_info);

   IF fnd_installation.get (
         appl_id     => 426,
         dep_appl_id => 426,
         status      => l_installation_status,
         industry    => l_industry)
   THEN
      null;
   END IF;

   IF (l_installation_status not in ('I','S')) THEN
      pnp_debug_pkg.log('EAM is not installed ...');
      RETURN;
   END IF;

   l_cursor := dbms_sql.open_cursor;
   l_query :=
      'SELECT location_id,'
               || 'parent_location_id,'
               || 'location_code,'
	       || '(select CASE WHEN LENGTH(location_code) > 30 THEN SUBSTR(location_code, 1, 20) || SUBSTR(TO_CHAR(location_id),1,10)  ELSE  location_code  END CASE from pn_locations where location_id = pl.parent_location_id) parent_instance_number,'
               || 'active_start_date,'
               || 'active_end_date'
	       || ' FROM pn_locations pl'
               || ' WHERE SYSDATE BETWEEN active_start_date AND NVL(active_end_date,'
               || ''''||TO_DATE('31/12/4712','DD/MM/YYYY') || ''''
               ||')';

   l_info := 'Figuring location type lookup code ';
   pnp_debug_pkg.log(l_info);

   IF p_locn_type IS NOT NULL THEN
      l_locn_type := p_locn_type;
      l_query :=
      l_query || ' AND location_type_lookup_code =  :l_locn_type';

   END IF;

   l_info := 'Figuring location code ';
   pnp_debug_pkg.log(l_info);

   IF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NOT NULL THEN
      l_locn_code_from := p_locn_code_from;
      l_locn_code_to := p_locn_code_to;
      l_where_clause :=
      l_where_clause || ' AND location_code between :l_locn_code_from AND :l_locn_code_to ';

   ELSIF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NULL THEN
      l_locn_code_from := p_locn_code_from;
      l_where_clause :=
      l_where_clause || ' AND location_code >=  :l_locn_code_from ';

   ELSIF p_locn_code_from IS NULL AND p_locn_code_to IS NOT NULL THEN
      l_locn_code_to := p_locn_code_to;
      l_where_clause :=
      l_where_clause || ' AND location_code <=  :l_locn_code_to ';

   END IF;

   /** Note: If a location_code_to is specified then all its descendants will be extracted **/

   IF p_locn_code_to IS NOT NULL THEN
      l_locn_code_to := p_locn_code_to;
      l_query := l_query || l_where_clause ||' UNION '|| l_query ||
                 ' START WITH location_code = :l_locn_code_to
                   CONNECT BY parent_location_id = PRIOR location_id';
   ELSE
      l_query := l_query || l_where_clause;
   END IF;

   l_query := l_query || ' ORDER BY location_id ';
   l_info := 'Figuring out the max id number in the mtl_eam_asset_num_interface ';
   pnp_debug_pkg.log(l_info);

   dbms_sql.parse(l_cursor, l_query, dbms_sql.native);

   IF p_locn_type IS NOT NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_locn_type',l_locn_type );
   END IF;

   IF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NOT NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
      dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
   ELSIF p_locn_code_from IS NOT NULL AND p_locn_code_to IS NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_locn_code_from',l_locn_code_from );
   ELSIF p_locn_code_from IS NULL AND p_locn_code_to IS NOT NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
   END IF;

   IF p_locn_code_to IS NOT NULL THEN
      dbms_sql.bind_variable
            (l_cursor,'l_locn_code_to',l_locn_code_to );
   END IF;

   dbms_sql.define_column (l_cursor, 1,location_rec.location_id);
   dbms_sql.define_column (l_cursor, 2,location_rec.parent_location_id);
   dbms_sql.define_column (l_cursor, 3,location_rec.location_code,90);
   dbms_sql.define_column (l_cursor, 4,l_parent_instance_number,30);
   dbms_sql.define_column (l_cursor, 5,location_rec.active_start_date);
   dbms_sql.define_column (l_cursor, 6,location_rec.active_end_date);

   l_rows   := dbms_sql.execute(l_cursor);

   LOOP
      l_count := dbms_sql.fetch_rows( l_cursor );
      EXIT WHEN l_count <> 1;

      dbms_sql.column_value (l_cursor, 1,location_rec.location_id);
      dbms_sql.column_value (l_cursor, 2,location_rec.parent_location_id);
      dbms_sql.column_value (l_cursor, 3,location_rec.location_code);
      dbms_sql.column_value (l_cursor, 4,l_parent_instance_number);
      dbms_sql.column_value (l_cursor, 5,location_rec.active_start_date);
      dbms_sql.column_value (l_cursor, 6,location_rec.active_end_date);

      l_process_flag := TRUE;
      l_count_lines  := l_count_lines + 1;

      pnp_debug_pkg.put_log_msg('*******************************************************************************');

      fnd_message.set_name ('PN','PN_XPEAM_SLNO');
      fnd_message.set_token ('SL_NO', to_char(l_count_lines));
      l_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_message);

      fnd_message.set_name ('PN','PN_XPEAM_PROC');
      fnd_message.set_token ('LOC_CODE',location_rec.location_code);
      fnd_message.set_token ('ST_DATE',location_rec.active_start_date);
      fnd_message.set_token ('END_DATE',NVL(location_rec.active_end_date,TO_DATE('31/12/4712','DD/MM/YYYY')));
      l_message := fnd_message.get;
      pnp_debug_pkg.put_log_msg(l_message);

      l_info := 'Calling EAM API to validate data ';
      pnp_debug_pkg.log(l_info);

      BEGIN
         pnp_debug_pkg.log('EAM_PN_EXTRACTION_PUB.PN_EAM_EXPORT_MODE (+)');

         eam_pn_extraction_pub.pn_eam_export_mode(
            p_api_version        => 1.0,
            p_pn_location_id     => location_rec.location_id,
            p_parent_location_id => location_rec.parent_location_id,
            p_active_start_date  => location_rec.active_start_date,
            p_active_end_date    => location_rec.active_end_date,
            x_insert             => l_insert,
            x_insert_mode        => l_insert_mode,
            x_insert_status      => l_insert_status,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);
        pnp_debug_pkg.log('EAM_PN_EXTRACTION_PUB.PN_EAM_EXPORT_MODE (-)');
      EXCEPTION
         WHEN OTHERS THEN
            l_process_flag := FALSE;
            l_count_failure := l_count_failure + 1;
            pnp_debug_pkg.put_log_msg('Failure Number: ('||to_char(l_count_failure) ||')'||
                                      'Error while calling EAM API for location :'||location_rec.location_code);
      END;

      IF l_insert = 1 AND l_process_flag THEN

         l_info := 'Figuring out how location code maps to serial number ';
         pnp_debug_pkg.log(l_info);

         IF LENGTH(location_rec.location_code) > 30 THEN
            l_serial_num := SUBSTR(location_rec.location_code, 1, 20) ||
                               SUBSTR(TO_CHAR(location_rec.location_id),1,10);
         ELSE
            l_serial_num := location_rec.location_code;
         END IF;


         l_info := 'Inserting data into mtl_eam_asset_num_interface table ';

         fnd_message.set_name ('PN','PN_XPEAM_INS');
         fnd_message.set_token ('TBL', 'MTL_EAM_ASSET_NUM_INTERFACE');
         l_message := fnd_message.get;
         pnp_debug_pkg.put_log_msg(l_message);


         BEGIN

            fnd_message.set_name ('PN','PN_XPEAM_INSERTING');
            l_message := '*** '||fnd_message.get||' ...';
            pnp_debug_pkg.put_log_msg(l_message);

/* Commented for bug 9347599
	 IF  l_parent_instance_number is not null then
		select inventory_item_id
		into l_parent_inv_id
		from mtl_eam_asset_num_interface
	        where instance_number = l_parent_instance_number;
	 else
	        l_parent_inv_id := NULL;
	 END IF;
*/
            -- Bug 9347599
            l_parent_inv_id := NULL;
            IF l_parent_instance_number IS NOT NULL THEN
               OPEN get_inv_item_id(l_parent_instance_number);
               FETCH get_inv_item_id INTO l_parent_inv_id;
               CLOSE get_inv_item_id;
            END IF;

            INSERT INTO mtl_eam_asset_num_interface(
               inventory_item_id,
               serial_number,
               interface_header_id,
               import_mode,
               import_scope,
               current_status,
               batch_id,
               batch_name,
               current_organization_id,
               owning_department_id,
               pn_location_id,
               process_flag,
               maintainable_flag,
               creation_date,
               last_update_date,
               created_by,
               last_updated_by,
               last_update_login,
               instance_number,
               active_start_date,
               active_end_date,
	       parent_instance_number,
	       parent_serial_number,
	       parent_inventory_item_id /* 8607381 */
            ) VALUES (
               p_inventory_item_id,
               l_serial_num,
               mtl_eam_asset_int_header_s.nextval,
               l_insert_mode,
               1,
               l_insert_status,
               p_inventory_item_id,
               p_batch_name,
               p_organization_id,
               p_owning_department_id,
               location_rec.location_id,
               'P',
               p_maintainable_flag,
               SYSDATE,
               SYSDATE,
               fnd_global.user_id,
               fnd_global.user_id,
               fnd_global.login_id,
               l_serial_num,
               location_rec.active_start_date,
               location_rec.active_end_date,
               l_parent_instance_number,
	       l_parent_instance_number,
	       l_parent_inv_id  /* 8607381 */
            );

            fnd_message.set_name ('PN','PN_XPEAM_LOC');
            fnd_message.set_token ('LOC_CODE', TO_CHAR(l_serial_num));
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_message);

            fnd_message.set_name ('PN','PN_XPEAM_INV_ID');
            fnd_message.set_token ('INV_ID', TO_CHAR(p_inventory_item_id));
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_message);

            fnd_message.set_name ('PN','PN_XPEAM_IMP_MODE');
            fnd_message.set_token ('IMP_MODE', TO_CHAR(l_insert_mode));
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_message);

            fnd_message.set_name ('PN','PN_XPEAM_CUR_STATUS');
            fnd_message.set_token ('CUR_STATUS', TO_CHAR(l_insert_status));
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_message);

            pnp_debug_pkg.log( 'Batch ID: ' || to_char(p_inventory_item_id));

            fnd_message.set_name ('PN','PN_XPEAM_BNAME');
            fnd_message.set_token ('BNAME', TO_CHAR(p_batch_name));
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_message);

            pnp_debug_pkg.log( 'Current Organization ID: ' || to_char(p_organization_id));
            pnp_debug_pkg.log( 'Owning Department ID: ' || to_char(p_owning_department_id));
            pnp_debug_pkg.log( 'PN Location ID: ' || to_char(location_rec.location_id));
            pnp_debug_pkg.log( 'Process Flag: ' || to_char('P'));
            pnp_debug_pkg.log( 'Maintainable Flag: ' || to_char('Y'));
            l_count_success := l_count_success + 1;

            fnd_message.set_name ('PN','PN_XPEAM_PROC_LINE');
            fnd_message.set_token ('LNO', TO_CHAR(l_count_success));
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_message);

            fnd_message.set_name ('PN','PN_XPEAM_INSERTED');
            l_message := fnd_message.get;
            pnp_debug_pkg.put_log_msg('*** '||l_message||' ...');

            l_info := 'Doing batch commit after every 100 INSERT ';
            IF MOD(l_count_success, 100) = 0 THEN
               commit;
               pnp_debug_pkg.log(l_info);
            END IF;

         EXCEPTION
            WHEN OTHERS THEN
               l_count_failure := l_count_failure + 1;
               fnd_message.set_name ('PN','PN_XPEAM_ERR_LINES');
               fnd_message.set_token ('ER_LNO', TO_CHAR(l_count_failure));
               l_message := fnd_message.get;
               pnp_debug_pkg.put_log_msg(l_message);
         END;

      ELSE
         l_count_failure := l_count_failure + 1;
         fnd_message.set_name ('PN','PN_XPEAM_ERR_LINES');
         fnd_message.set_token ('PRO_LNO', TO_CHAR(l_count_failure));
         l_message := fnd_message.get;
         pnp_debug_pkg.put_log_msg(l_message);
      END IF;

   END LOOP;

   IF dbms_sql.is_open (l_cursor) THEN
      dbms_sql.close_cursor (l_cursor);
   END IF;


   pnp_debug_pkg.put_log_msg('===========================================================================');
   fnd_message.set_name ('PN','PN_XPEAM_PROC_LN');
   fnd_message.set_token ('PR_LNO', TO_CHAR(l_count_lines));
   l_message := fnd_message.get;
   pnp_debug_pkg.put_log_msg(l_message);

   fnd_message.set_name ('PN','PN_XPEAM_SUCS_LN');
   fnd_message.set_token ('SUC_LNO', TO_CHAR(l_count_success));
   l_message := fnd_message.get;
   pnp_debug_pkg.put_log_msg(l_message);

   fnd_message.set_name ('PN','PN_XPEAM_FAIL_LN');
   fnd_message.set_token ('FAIL_LNO', TO_CHAR(l_count_failure));
   l_message := fnd_message.get;
   pnp_debug_pkg.put_log_msg(l_message);
   pnp_debug_pkg.put_log_msg('===========================================================================');

   pnp_debug_pkg.log('PN_EXP_TO_EAM_PVT.EXPORT_LOCATION_TO_EAM (-)');

EXCEPTION
   WHEN OTHERS THEN

      pnp_debug_pkg.put_log_msg('PN_EXP_TO_EAM_PVT.EXPORT_LOCATION_TO_EAM : Error while ' || l_info);
      raise;

END export_location_to_eam;

END pn_exp_to_eam_pvt;

/
