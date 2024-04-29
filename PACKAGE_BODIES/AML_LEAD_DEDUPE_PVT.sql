--------------------------------------------------------
--  DDL for Package Body AML_LEAD_DEDUPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AML_LEAD_DEDUPE_PVT" AS
/* $Header: amlvddpb.pls 115.12 2004/07/06 08:28:02 bmuthukr noship $ */

-- Start of Comments
-- Package name     : aml_lead_dedupe_pvt
-- Purpose          : To find duplicate lead
-- NOTE             :
-- History          :
--                    11-Aug-2003  AANJARIA  Created.
--
--                    06-Jul-2004  BMUTHUKR  Fixed bug # 3737789.
-- End of Comments

   l_product_interest        VARCHAR2 (1) := 'N';
   l_budget_status           VARCHAR2 (1) := 'N';
   l_purchase_amt            VARCHAR2 (1) := 'N';
   l_budget_amt              VARCHAR2 (1) := 'N';
   l_purchase_timeframe      VARCHAR2 (1) := 'N';
   l_project                 VARCHAR2 (1) := 'N';
   l_note_type               VARCHAR2 (1) := 'N';
   l_promotion_code          VARCHAR2 (1) := 'N';
   l_vehicle_response_code   VARCHAR2 (1) := 'N';
   l_contact                 VARCHAR2 (1) := 'N';
   l_address                 VARCHAR2 (1) := 'N';
   l_customer                VARCHAR2 (1) := 'N';

   --------------------------------------------------------------
   -- Procedure   : DebugMsg
   -- Description : Print debug msg
   --------------------------------------------------------------

   PROCEDURE DebugMsg (Msg IN VARCHAR2)
   IS
   BEGIN
      --DBMS_OUTPUT.put_line (Msg);
/*
      fnd_file.put(1, substr(Msg,1,255));
      fnd_file.new_line(1,1);
*/
      null;
   END DebugMsg;

   --------------------------------------------------------------
   -- Procedure   : Remove_duplicate
   -- Description : Remove duplicate product interest type from
   --               category_id_tbl table
   --------------------------------------------------------------

   PROCEDURE Remove_duplicate (px_category_tbl IN OUT NOCOPY category_id_type)
   IS
      out_tbl category_id_type;
      idx NUMBER;
      fnd NUMBER;
   BEGIN
      idx := 1;

      --Browse table, identify duplicate and populate out_tbl
      FOR i IN 1 .. px_category_tbl.COUNT
      LOOP
        fnd := 0;

	FOR j IN 1..out_tbl.COUNT
        LOOP
          IF px_category_tbl(i) = out_tbl(j) THEN
             fnd := 1;
          END IF;
        END LOOP;

        IF fnd = 0 THEN
           out_tbl(idx) := px_category_tbl(i);
           idx := idx+1;
        END IF;
      END LOOP;

      FOR i IN 1..out_tbl.COUNT
      LOOP
         DebugMsg ('Fin -'||to_char(out_tbl(i)));
      END LOOP;

      px_category_tbl := out_tbl;

   END remove_duplicate;

   --------------------------------------------------------------
   -- Procedure   : Get_attributes
   -- Description : Get attributes from rule
   --------------------------------------------------------------

   PROCEDURE Get_attributes
   IS
      -- Query to get all matching attributes in dedupe rule
      CURSOR c_get_matching_attr
      IS
         SELECT ruleattr.attribute_id, attr.NAME
           FROM pv_enty_select_criteria ruleattr, pv_attributes_vl attr
          WHERE ruleattr.process_rule_id = 60
            AND ruleattr.attribute_id = attr.attribute_id
            AND ruleattr.selection_type_code = 'CRITERION';
   BEGIN
      -- Reset values
      l_product_interest := 'N';
      l_budget_status := 'N';
      l_purchase_amt := 'N';
      l_budget_amt := 'N';
      l_purchase_timeframe := 'N';
      l_project := 'N';
      l_note_type := 'N';
      l_promotion_code := 'N';
      l_vehicle_response_code := 'N';
      l_contact := 'N';
      l_address := 'N';
      l_customer := 'N';

      -- Get all matching attributes
      FOR attrs IN c_get_matching_attr
      LOOP
         IF attrs.attribute_id = 500
         THEN
            l_customer := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 501
         THEN
            l_address := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 576
         THEN
            l_contact := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 513
         THEN
            l_vehicle_response_code := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 16
         THEN
            l_promotion_code := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 572
         THEN
            l_note_type := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 514
         THEN
            l_project := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 505
         THEN
            l_purchase_timeframe := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 509
         THEN
            l_budget_amt := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 522
         THEN
            l_purchase_amt := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 506
         THEN
            l_budget_status := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         IF attrs.attribute_id = 510
         THEN
            l_product_interest := 'Y';
            --DebugMsg (TO_CHAR (attrs.attribute_id));
         END IF;

         --DebugMsg (attrs.NAME);
      END LOOP;
   END Get_attributes;

   --------------------------------------------------------------
   -- Procedure   : Check_contact_cp
   -- Description : Check for duplicate contact and contact point
   --------------------------------------------------------------

   PROCEDURE Check_contact_cp (
      p_dup_rec      IN              dedupe_rec_type,
      p_contact_id   OUT NOCOPY      NUMBER
   )
   IS

      CURSOR  c_contact_cp IS
                SELECT   hzpc.party_id
                    FROM hz_parties hzpc,
                         hz_parties hzpr,
                         hz_relationships hzr
                   WHERE hzpc.party_id = p_dup_rec.contact_id
                     AND hzpc.party_id = hzr.subject_id
                     AND hzr.party_id = hzpr.party_id
                     AND hzr.relationship_code IN ('CONTACT_OF', 'EMPLOYEE_OF')
                ORDER BY hzpc.party_id DESC;

   BEGIN

         OPEN c_contact_cp;
         FETCH c_contact_cp INTO p_contact_id;
         CLOSE c_contact_cp;
         --DebugMsg ('dup contact_id- ' || TO_CHAR (p_contact_id));

   END Check_contact_cp;

   --------------------------------------------------------------
   -- Procedure   : Check_address
   -- Description : To check duplicate address
   --------------------------------------------------------------

   PROCEDURE Check_address (
      p_dup_rec         IN              dedupe_rec_type,
      l_customer_id     OUT NOCOPY      NUMBER,
      l_party_site_id   OUT NOCOPY      NUMBER
   )
   IS
     CURSOR c_customer_location_chk
      IS
         SELECT   party_site_id, hzp.party_id
             FROM hz_locations hzl, hz_party_sites hzs, hz_parties hzp
            WHERE hzp.party_id = p_dup_rec.party_id
              AND hzp.party_id = hzs.party_id
              AND hzs.location_id = hzl.location_id
              AND hzs.party_site_id = p_dup_rec.party_site_id
         ORDER BY hzp.party_id DESC;
   BEGIN

     OPEN c_customer_location_chk;
     FETCH c_customer_location_chk INTO l_party_site_id, l_customer_id;
     CLOSE c_customer_location_chk;
     --DebugMsg (   'dup cust location- '|| TO_CHAR (l_customer_id)|| ' - '
     --              || TO_CHAR (l_party_site_id));

   END Check_address;

   --------------------------------------------------------------
   -- Procedure   : Check_dup_lead
   -- Description : To check duplicate lead
   --------------------------------------------------------------

   PROCEDURE Check_dup_lead (
      p_dup_rec         IN              dedupe_rec_type,
      p_customer_id     IN              NUMBER,
      p_party_site_id   IN              NUMBER,
      p_contact_id      IN              NUMBER,
      x_sales_lead_id   OUT NOCOPY      NUMBER
   )
   IS
      CURSOR C_get_created_within_days
      IS
         SELECT attrvals.attribute_value
           FROM pv_enty_select_criteria ruleattr,
                pv_selected_attr_values attrvals
          WHERE ruleattr.process_rule_id = 60
            AND ruleattr.selection_type_code = 'INPUT_FILTER'
            AND ruleattr.selection_criteria_id = attrvals.selection_criteria_id;

      TYPE c_find_dup_lead_type IS REF CURSOR;
      C_find_dup_lead         c_find_dup_lead_type;
      C_find_lead_lines       c_find_dup_lead_type;

      l_created_within_days   NUMBER;
      l_from_clause           VARCHAR2 (100);
      l_where_clause          VARCHAR2 (4000);
      l_sql_string            VARCHAR2 (4000);
      l_sql_lines             VARCHAR2 (4000);
      l_order_by_clause       VARCHAR2 (100);
      l_sales_lead_id         NUMBER;
      l_count                 NUMBER;
      l_def_vrc               VARCHAR2(30);
      l_def_budget_status     VARCHAR2(30);
      l_def_decision_timeframe VARCHAR2(30);
      category_tbl            category_id_type;

      l_cursor number;
      l_cur_exec number;

      l_line_cursor number;
      l_line_cur_exec number;

   BEGIN

      DebugMsg('Starting lead dup');
      -- Get value for created_within days attribute
      OPEN c_get_created_within_days;
      FETCH c_get_created_within_days INTO l_created_within_days;
      CLOSE c_get_created_within_days;

      l_def_vrc := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_VEHICLE_RESPONSE_CODE');
      l_def_budget_status := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_BUDGET_STATUS');
      l_def_decision_timeframe := FND_PROFILE.VALUE ('AS_DEFAULT_LEAD_DECISION_TIMEFRAME');

      -- Now form the FROM and WHERE clause depending on the selected attributes in rule

      -- First form mendatory select clause
      l_sql_string := 'SELECT sales_lead_id ';

      l_from_clause := 'FROM as_sales_leads asleads ';

      l_where_clause := ' WHERE asleads.customer_id = :party_id ';
      l_where_clause := l_where_clause ||' AND asleads.creation_date > trunc(sysdate - :l_created_within_days ) ';

      IF l_promotion_code = 'Y' THEN
        IF p_dup_rec.source_code IS NOT NULL THEN
	  l_from_clause := l_from_clause || ', ams_source_codes amc ';
          l_where_clause := l_where_clause ||' AND asleads.source_promotion_id = amc.source_code_id ';
          l_where_clause := l_where_clause ||' AND amc.source_code = UPPER(:source_code) ';
	ELSIF p_dup_rec.source_code IS NULL THEN
          l_where_clause := l_where_clause ||' AND asleads.source_promotion_id IS NULL ';
        END IF;
      END IF;

      IF l_vehicle_response_code = 'Y' THEN
        l_where_clause := l_where_clause ||' AND  nvl(asleads.vehicle_response_code,nvl(:l_def_vrc,''xx'')) ';
        l_where_clause := l_where_clause ||' = nvl(:vehicle_response_code ,nvl(:l_def_vrc,''xx'')) ';
      END IF;

      -- Add where clause based on attributes in rule
      IF l_contact = 'Y' THEN
        IF p_dup_rec.contact_id IS NOT NULL THEN
         l_where_clause := l_where_clause ||' AND asleads.primary_cnt_person_party_id = :contact_id ';
        ELSIF p_dup_rec.contact_id IS NULL  THEN
         l_where_clause := l_where_clause ||' AND asleads.primary_cnt_person_party_id IS NULL ';
        END IF;
      END IF;

      IF l_address = 'Y' THEN
        IF p_dup_rec.party_site_id IS NOT NULL THEN
         l_where_clause := l_where_clause ||' AND asleads.address_id = :party_site_id ';
	ELSIF p_dup_rec.party_site_id IS NULL THEN
         l_where_clause := l_where_clause ||' AND asleads.address_id IS NULL ';
	END IF;
      END IF;

      IF l_note_type = 'Y'
      THEN
          l_from_clause  := l_from_clause ||', jtf_notes_vl notes ';
          l_where_clause := l_where_clause||' AND asleads.sales_lead_id = notes.source_object_id(+)';
          l_where_clause := l_where_clause||' AND nvl(notes.source_object_code,''LEAD'') = ''LEAD''';
	IF p_dup_rec.lead_note IS NOT NULL THEN --bug 3436346
          l_where_clause := l_where_clause||' AND nvl(notes.note_type,''AS_USER'') = nvl(:note_type,''AS_USER'') ';
        END IF;
          l_where_clause := l_where_clause||' AND nvl(notes.notes,''xx'') = nvl(:lead_note,''xx'') ';
      END IF;

      IF l_budget_status = 'Y' THEN
         l_where_clause := l_where_clause ||' AND  nvl(asleads.budget_status_code,nvl(:l_def_budget_status,''xx'')) ';
         l_where_clause := l_where_clause ||' = nvl(:budget_status_code ,nvl(:l_def_budget_status,''xx'')) ';
      END IF;

      IF l_purchase_amt = 'Y' THEN
	 IF p_dup_rec.purchase_amount IS NULL THEN
	    l_where_clause := l_where_clause || ' AND nvl(asleads.total_amount,0) = 0 ';
	 ELSE
            l_where_clause := l_where_clause || ' AND nvl(asleads.total_amount,0) = :purchase_amount ';
	 END IF;
      END IF;

      IF l_budget_amt = 'Y' THEN
         IF p_dup_rec.budget_amount IS NULL THEN
	    l_where_clause := l_where_clause || ' AND nvl(asleads.budget_amount,0) = 0 ';
	 ELSE
	    l_where_clause := l_where_clause || ' AND nvl(asleads.budget_amount,0) = :budget_amount ';
	 END IF;
      END IF;

      IF l_purchase_timeframe = 'Y' THEN
         l_where_clause := l_where_clause ||' AND  nvl(asleads.decision_timeframe_code,nvl(:l_def_decision_timeframe,''xx'')) ';
         l_where_clause := l_where_clause ||' = nvl(:purchase_timeframe_code, nvl(:l_def_decision_timeframe,''xx'')) ';
      END IF;

      IF l_project = 'Y' THEN
         l_where_clause := l_where_clause || ' AND nvl(asleads.parent_project,''xx'') = nvl(:project_code,''xx'') ';
      END IF;

      l_order_by_clause := ' ORDER BY asleads.creation_date DESC ';

      l_sql_string := l_sql_string || l_from_clause || l_where_clause || l_order_by_clause;
      --DebugMsg (l_from_clause);

/*
insert into  aaa_log
values(sysdate, l_sql_string);
*/

      --PARSE
      l_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_cursor, l_sql_string, DBMS_SQL.native);

      --DEFINE_COLUMN
      DBMS_SQL.define_column(l_cursor, 1, l_sales_lead_id);

      --BIND VARIABLES
      DBMS_SQL.bind_variable(l_cursor, 'party_id', p_dup_rec.party_id);
      DBMS_SQL.bind_variable(l_cursor, 'l_created_within_days', l_created_within_days);

      IF l_promotion_code = 'Y' AND p_dup_rec.source_code IS NOT NULL THEN
	 DBMS_SQL.bind_variable(l_cursor, 'source_code', p_dup_rec.source_code);
      END IF;

      IF l_vehicle_response_code = 'Y' THEN
         DBMS_SQL.bind_variable(l_cursor, 'l_def_vrc', l_def_vrc);
         DBMS_SQL.bind_variable(l_cursor, 'vehicle_response_code', p_dup_rec.vehicle_response_code);
      END IF;

      IF l_contact = 'Y' AND p_dup_rec.contact_id IS NOT NULL THEN
         DBMS_SQL.bind_variable(l_cursor, 'contact_id', p_dup_rec.contact_id);
      END IF;

      IF l_address = 'Y' AND p_dup_rec.party_site_id IS NOT NULL THEN
         DBMS_SQL.bind_variable(l_cursor, 'party_site_id', p_dup_rec.party_site_id);
      END IF;

      IF l_note_type = 'Y' THEN
        IF p_dup_rec.lead_note IS NOT NULL THEN
  	   DBMS_SQL.bind_variable(l_cursor, 'note_type', p_dup_rec.note_type);
	END IF;
        DBMS_SQL.bind_variable(l_cursor, 'lead_note', p_dup_rec.lead_note);
      END IF;

      IF l_budget_status = 'Y' THEN
         DBMS_SQL.bind_variable(l_cursor, 'l_def_budget_status', l_def_budget_status);
         DBMS_SQL.bind_variable(l_cursor, 'budget_status_code', p_dup_rec.budget_status_code);
      END IF;

      IF l_purchase_amt = 'Y' AND p_dup_rec.purchase_amount IS NOT NULL THEN
         DBMS_SQL.bind_variable(l_cursor, 'purchase_amount', p_dup_rec.purchase_amount);
      END IF;

      IF l_budget_amt = 'Y' AND p_dup_rec.budget_amount IS NOT NULL THEN
         DBMS_SQL.bind_variable(l_cursor, 'budget_amount', p_dup_rec.budget_amount);
      END IF;

      IF l_purchase_timeframe = 'Y' THEN
         DBMS_SQL.bind_variable(l_cursor, 'l_def_decision_timeframe', l_def_decision_timeframe);
	 DBMS_SQL.bind_variable(l_cursor, 'purchase_timeframe_code', p_dup_rec.purchase_timeframe_code);
      END IF;

      IF l_project = 'Y' THEN
         DBMS_SQL.bind_variable(l_cursor, 'project_code', p_dup_rec.project_code);
      END IF;

      --EXECUTE CURSOR
      l_cur_exec := DBMS_SQL.execute(l_cursor);

      l_sales_lead_id := null;

      IF l_product_interest = 'Y' AND p_dup_rec.category_id_tbl.COUNT > 0 THEN

	  LOOP
	     IF DBMS_SQL.fetch_rows(l_cursor)>0 THEN

		-- get column values of the row
                DBMS_SQL.column_value(l_cursor, 1, l_sales_lead_id);

                category_tbl := p_dup_rec.category_id_tbl;
                remove_duplicate (category_tbl);

                l_sql_string   := 'SELECT count(distinct category_id) l_count ';
                l_from_clause  := 'FROM as_sales_lead_lines ';
                l_where_clause := 'WHERE sales_lead_id = :p_sales_lead_id ';
                l_where_clause := l_where_clause ||' AND category_id IN (';

                FOR i IN 1..category_tbl.COUNT LOOP
                   IF i <> 1 THEN
                      l_where_clause := l_where_clause || ',';
                   END IF;
                   l_where_clause := l_where_clause || to_char(category_tbl(i));
                END LOOP;
                l_where_clause := l_where_clause || ') ';

                l_sql_lines := l_sql_string || l_from_clause || l_where_clause;

                --PARSE
                l_line_cursor := DBMS_SQL.open_cursor;
                DBMS_SQL.parse(l_line_cursor, l_sql_lines, DBMS_SQL.native);

                --DEFINE_COLUMN
                DBMS_SQL.define_column(l_line_cursor, 1, l_count);

                --BIND VARIABLES
                DBMS_SQL.bind_variable(l_line_cursor, 'p_sales_lead_id', l_sales_lead_id);

                --EXECUTE CURSOR
                l_line_cur_exec := DBMS_SQL.execute(l_line_cursor);
                IF DBMS_SQL.fetch_rows(l_line_cursor)>0 THEN
                   -- get column values of the row
                   DBMS_SQL.column_value(l_line_cursor, 1, l_count);
		END IF;

                DebugMsg(to_char(l_sales_lead_id)||'-'||to_char(l_count)||'-'||to_char(category_tbl.COUNT));

		DBMS_SQL.close_cursor(l_line_cursor); -- Added by bmuthukr to fix bug# 3737789.

                IF l_count = category_tbl.COUNT THEN
	           x_sales_lead_id := l_sales_lead_id;
	           EXIT;
                END IF;

	     ELSE --fetch_rows = 0
	        EXIT;
	     END IF;

          END LOOP;
          --CLOSE C_find_dup_lead;
          --DBMS_SQL.close_cursor(l_line_cursor);--The cursor should be closed inside its scope.
      ELSE --product interest

	IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
           -- get column values of the row
           DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_sales_lead_id);
	END IF;
        x_sales_lead_id := l_sales_lead_id;

      END IF;
      DBMS_SQL.close_cursor(l_cursor);

   END Check_dup_lead;

   --------------------------------------------------------------
   -- Procedure   : Main
   -- Description : This is the main procedure which will be
   --               called by the integrating application
   --------------------------------------------------------------

   PROCEDURE Main (
      p_init_msg_list    IN              VARCHAR2 := fnd_api.g_false,
      p_dedupe_rec       IN              dedupe_rec_type, -- Input Lead Record
      x_duplicate_flag   OUT NOCOPY      VARCHAR2,                      -- D/U
      x_sales_lead_id    OUT NOCOPY      NUMBER,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2
   )
   IS
      l_duplicate_flag   VARCHAR2 (1) := 'U';
      l_contact_id       hz_parties.party_id%TYPE;
      l_party_id         hz_parties.party_id%TYPE;
      l_party_site_id    hz_party_sites.party_site_id%TYPE;
      l_sales_lead_id    as_sales_leads.sales_lead_id%TYPE;

   BEGIN
      SAVEPOINT MAIN_PVT;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF fnd_profile.VALUE ('PV_RUN_LEAD_DUPLICATION_RULE') = 'N'
      THEN
         DebugMsg ('Profile value is NO..exiting');
         x_duplicate_flag := l_duplicate_flag;
         return;
      END IF;

      --First get all the attributes selected in dedupe rule
      Get_attributes;

      IF l_contact = 'Y' AND p_dedupe_rec.contact_id IS NOT NULL
      THEN
         DebugMsg ('in contact ddupe check');
         --Check for contact and contact point existence
         Check_contact_cp (p_dedupe_rec, l_contact_id);
         --DebugMsg ('contact_id frm check_con_cp: '|| TO_CHAR (l_contact_id));

         IF l_contact_id IS NULL
         THEN
            x_duplicate_flag := l_duplicate_flag;
            DebugMsg ('Dup contact cp failed..exiting');
            RETURN;
         END IF;
      END IF;

      IF l_address = 'Y' AND p_dedupe_rec.party_site_id IS NOT NULL
      THEN
         DebugMsg ('in address ddupe check');
         --Check for customer address existence
         Check_address (p_dedupe_rec, l_party_id, l_party_site_id);

         IF l_party_site_id IS NULL
         THEN
            x_duplicate_flag := l_duplicate_flag;
            DebugMsg ('Dup address failed..exiting');
            RETURN;
         END IF;
      END IF;

      Check_dup_lead (p_dedupe_rec,
                      l_party_id,
                      l_party_site_id,
                      l_contact_id,
                      l_sales_lead_id
                     );
      DebugMsg ('Dup lead- ' || l_sales_lead_id);

      IF l_sales_lead_id IS NULL
      THEN
         x_duplicate_flag := l_duplicate_flag;
	 x_sales_lead_id := NULL;
      ELSE
         x_duplicate_flag := 'D';
	 x_sales_lead_id := l_sales_lead_id;
      END IF;

   EXCEPTION
      WHEN others THEN
            DebugMsg('aml_lead_dedupe_pvt failed');

	    AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                    P_API_NAME => 'MAIN'
                   ,P_PKG_NAME => 'AML_LEAD_DEDUPE_PVT'
                   ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                   ,P_SQLCODE => SQLCODE
                   ,P_SQLERRM => SQLERRM
                   ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
                   ,X_MSG_COUNT => X_MSG_COUNT
                   ,X_MSG_DATA => X_MSG_DATA
                   ,X_RETURN_STATUS => X_RETURN_STATUS);

   END Main;

END aml_lead_dedupe_pvt;

/
