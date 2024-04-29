--------------------------------------------------------
--  DDL for Package Body WMS_RULE_GEN_PKGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_RULE_GEN_PKGS" AS
/* $Header: WMSGNPKB.pls 120.1 2006/10/24 23:56:36 grao noship $ */
--
g_build_package_row   number;
g_build_package_tbl  DBMS_SQL.VARCHAR2S;

g_tbl_pkg_body tbl_long_type;
g_tbl_pkg_body_f tbl_long_type;
g_tbl_pkg_body_c tbl_long_type;
g_tbl_pkg_body_f_avail tbl_long_type;

g_owner VARCHAR2(30);
-- ============================================================
-- InitBuildPackage
-- Called from GenerateRulePackage. Initializes
-- the global variables needed to dynamically build the
-- rule package.
-- ============================================================
PROCEDURE InitBuildPackage IS

BEGIN
   g_build_package_row := 0;
   g_build_package_tbl.delete;
END InitBuildPackage;
-- ================================
-- Bug # 2729877 / grao
-- This function  is to be used for getting the number of rules for the given type
-- -- bug # 3407019 -- Added enable_flag = 'Y'

Function get_rule_count( p_type_code in NUMBER ) return number is
l_rule_count number := 0;
begin
 select count(rule_id) into l_rule_count
 from wms_rules_b
 where type_code = p_type_code
  and  enabled_flag = 'Y';

 return l_rule_count;
end get_rule_count;



-- ==========================================================
-- Build Package
-- This API takes a VARCHAR of undetermined length
-- and breaks it up into varchars of length 255.  These
-- smaller strings are stored in the g_build_package_tbl,
-- and compose the sql statement to create the
-- Rules package.
-- ==========================================================
PROCEDURE BuildPackage(
        p_package_string IN LONG)

IS
   l_cur_start  NUMBER;
   l_package_length NUMBER;
   l_num_chars NUMBER := 255;
   l_row NUMBER;

BEGIN
   --debug
   if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('Build_Package(). '||  p_package_string);
   end if;

l_cur_start := 1;
   -- get last filled row of table
   l_row := g_build_package_row;
   l_package_length := length(p_package_string);
   -- return if string is null
   IF l_package_length IS NULL or l_package_length = 0 THEN
        return;
   END IF;

   --Loop through string, reading off l_num_chars bytes at a time
   LOOP
      --When at end of varchar, exit loop;
      EXIT WHEN l_cur_start > l_package_length;
      l_row := l_row + 1;

      --Get substring from package_string
      g_build_package_tbl(l_row) := substr(p_package_string,
                                l_cur_start,
                                l_num_chars);
      --Call buil package to add row
      -- We may need to call this API for AOL standards.
      --ad_ddl.build_package(l_cur_string, l_row);

      --increment pointers
      l_cur_start := l_cur_start + l_num_chars;
      IF l_cur_start + l_num_chars > l_package_length THEN
         l_num_chars := l_package_length - l_cur_start + 1;
      END IF;
   END LOOP;

   g_build_package_row := l_row;

END BuildPackage;
--=================================================================
--CreatePackage
-- This API calls dynamic SQL to build the package
-- currently sitting in the g_build_package_tbl.
--   p_package_body = TRUE if the package to be created is a body
--=================================================================
PROCEDURE CreatePackage(
         x_return_status OUT NOCOPY VARCHAR2
        ,p_package_name IN VARCHAR2
        ,p_package_body IN BOOLEAN
    ) IS
  l_schema     VARCHAR2(30);
   l_status     VARCHAR2(1);
   l_industry   VARCHAR2(1);
   l_comp_error VARCHAR2(40);
   l_return BOOLEAN;
   l_cursor INTEGER;
   l_error NUMBER;
   l_dummy NUMBER;
   CURSOR c_package_status IS
      SELECT 1
        FROM dual
        WHERE exists(
        SELECT status
        FROM all_objects
       WHERE object_name = p_package_name
         AND object_type = 'PACKAGE'
         AND status <> 'VALID'
         AND owner = g_owner);

   CURSOR c_package_body_status IS
      SELECT 1
        FROM dual
        WHERE exists(
        SELECT status
        FROM all_objects
      WHERE object_name = p_package_name
         AND object_type = 'PACKAGE BODY'
         AND status <> 'VALID'
         AND owner = g_owner);
BEGIN

   x_return_status := fnd_api.g_ret_sts_unexp_error;

   --open cursor
   l_cursor := dbms_sql.open_cursor;
   --parse cursor
   dbms_sql.parse(l_cursor,
                  g_build_package_tbl,
                  1,
                  g_build_package_row,
                  FALSE,
                  dbms_sql.native);

   --l_dummy := dbms_sql.execute(l_cursor);
   --close cursor
   dbms_sql.close_cursor(l_cursor);

   --Check status, return error if package that was created
   --  is invalid



   IF p_package_body THEN
      OPEN c_package_body_status;
      FETCH c_package_body_status INTO l_error;
      IF c_package_body_status%FOUND THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      ELSE
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
      CLOSE c_package_body_status;
   ELSE
      OPEN c_package_status;
      FETCH c_package_status INTO l_error;
      IF c_package_status%FOUND THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
      ELSE
        x_return_status := fnd_api.g_ret_sts_success;
      END IF;
      CLOSE c_package_status;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
END CreatePackage;


PROCEDURE GenerateSQL
  (p_api_version      IN   NUMBER                                 ,
   p_init_msg_list    IN   VARCHAR2 	                          ,
   p_validation_level IN   NUMBER                                 ,
   x_return_status    OUT  NOCOPY VARCHAR2 				  ,
   x_msg_count        OUT  NOCOPY NUMBER 				  ,
   x_msg_data         OUT  NOCOPY VARCHAR2 				  ,
   p_type_code        IN   NUMBER                                 ,
   p_type_name        IN   VARCHAR2                               ,
   p_counter          IN   NUMBER                                 ,
   p_counter_str      IN   VARCHAR2                               ,
   p_pkg_type         IN   VARCHAR2
   ) IS

   PRAGMA AUTONOMOUS_TRANSACTION;

-- API standard variables
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_api_name            CONSTANT VARCHAR2(30) := 'GenerateRuleExecPkgs';
  --
-- Static value
  PUT_TYPE             NUMBER := 1;
  PICK_TYPE            NUMBER := 2;
  TASK_TYPE            NUMBER := 3;
  LABEL_TYPE           NUMBER := 4;
  CG_TYPE              NUMBER := 5;
  OP_TYPE              NUMBER := 7;
  PICK_PKG_NAME        VARCHAR2(255) := 'WMS_RULE_PICK_PKG';
  PUT_PKG_NAME         VARCHAR2(255) := 'WMS_RULE_PUT_PKG';
  TASK_PKG_NAME        VARCHAR2(255) := 'WMS_RULE_TASK_PKG';
  LABEL_PKG_NAME       VARCHAR2(255) := 'WMS_RULE_LABEL_PKG';
  CG_PKG_NAME          VARCHAR2(255) := 'WMS_RULE_CG_PKG';
  OP_PKG_NAME          VARCHAR2(255) := 'WMS_RULE_OP_PKG';
  -- variables needed for dynamic SQL
  l_cursor              INTEGER;
  l_rows                INTEGER;
  l_rule_id             wms_rules_b.rule_id%TYPE := NULL;
  l_type_code           wms_rules_b.TYPE_CODE%TYPE := p_type_code;
  l_package_name        VARCHAR2(255);
  l_if_cl               VARCHAR2(10);
  l_endif_cl            VARCHAR2(255);
  l_cur_ocl              VARCHAR2(10) := '''' ||'OPEN' || '''';
  l_cur_fcl              VARCHAR2(10) := '''' ||'FETCH' || '''';
  l_cur_ccl              VARCHAR2(10) := '''' ||'CLOSE' || '''';
  l_pkg_stmt_o            long;
  l_pkg_stmt_f            long;
  l_pkg_stmt_c            long;
  l_pkg_stmt_f_avail      long;
  l_pkg_body_o            long;
  l_pkg_body_f            long;
  l_pkg_body_f_avail      long;
  l_pkg_body_c            long;
  l_pkg_hdr_B            long;
  l_pkg_hdr_S            long;
  l_pkg_body             long;
  l_pkg_end              long;
  l_pkg_fetch_hdr        long;
  l_pkg_close_hdr        long;
  l_pkg_open_end         long;
  l_pkg_fetch_end        long;
  l_pkg_close_end        long;
  l_pkg_fetch_avail_hdr  long;
  l_pkg_fetch_avail_end  long;
  l_counter              NUMBER  := p_counter;
  l_type_name            VARCHAR2(40) := p_type_name;
  l_counter_str          VARCHAR2(40) := p_counter_str;

  l_new_ctr NUMBER;

  TYPE Rule_TabTyp  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  i                    NUMBER := 0;
  j                    NUMBER := 0;
  rule_cnt             NUMBER := 0;

  RuleTab     Rule_TabTyp;
  -- bug # 3407019 not required
  -- l_rule_count Number;

-- cursor for validation of input parameters and pre-requisites
  CURSOR rule_curs IS
  /*SELECT rule_id
    FROM WMS_RULES_B
   WHERE enabled_flag  = 'Y'
   AND   type_code = p_type_code
   ORDER BY rule_weight DESC, creation_date;*/
   -- modified by grao to exclude the invalid rules but status enabled
  SELECT  rl.rule_id
       FROM WMS_RULES_B rl  , all_objects obj
      WHERE rl.enabled_flag  = 'Y'
      AND   rl.type_code = p_type_code
      AND (obj.object_name  =  'WMS_RULE_'|| to_char(rl.rule_id)
      AND  obj.object_type = 'PACKAGE BODY'
      AND  obj.owner = g_owner AND obj.status = 'VALID' )
   ORDER BY  rl.rule_weight DESC, rl.creation_date;
-- -----------------------------
-- Defined SQL text
-- -----------------------------
--
-- ------------------------------
-- LABEL section
-- ------------------------------
l_label_hdr_S long := 'CREATE OR REPLACE PACKAGE WMS_RULE_LABEL_PKG'||l_counter_str||' AS

 ---- For Opening the Label CURSOR ----
 ----
PROCEDURE EXECUTE_LABEL_RULE(
          p_rule_id                    IN NUMBER,
          p_label_request_id           IN NUMBER,
          x_return_status              OUT NOCOPY NUMBER);


END WMS_RULE_LABEL_PKG'||l_counter_str||';
--COMMIT;
--EXIT;


';

l_label_hdr_B long := 'CREATE OR REPLACE PACKAGE BODY WMS_RULE_LABEL_PKG'||l_counter_str||' AS

 ---- For Opening the Label CURSOR ----
 ----
PROCEDURE EXECUTE_LABEL_RULE(
          p_rule_id                    IN NUMBER,
          p_label_request_id           IN NUMBER,
          x_return_status              OUT NOCOPY NUMBER) is

  BEGIN
';

l_label_open_end long :='
END EXECUTE_LABEL_RULE;';

l_label_fetch_hdr long := '';

l_label_fetch_end long :='';


l_label_close_hdr long :='';

l_label_close_end long :='
END WMS_RULE_LABEL_PKG'||l_counter_str||';
--COMMIT;
--EXIT;
';

-- ----------------------
-- Task Section
-- ----------------------
l_task_hdr_S long := 'CREATE OR REPLACE PACKAGE WMS_RULE_TASK_PKG'||l_counter_str||' AS


 ---- For Opening the Task CURSOR ----
 ----
PROCEDURE EXECUTE_TASK_RULE(
          p_rule_id                    IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          x_return_status              OUT NOCOPY NUMBER);

END WMS_RULE_TASK_PKG'||l_counter_str||';
--COMMIT;
--EXIT;


';

l_task_hdr_B long := 'CREATE OR REPLACE PACKAGE BODY WMS_RULE_TASK_PKG'||l_counter_str||' AS

 ---- For Opening the Task CURSOR ----
 ----
PROCEDURE EXECUTE_TASK_RULE(
          p_rule_id                    IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          x_return_status              OUT NOCOPY NUMBER) is

  BEGIN
';

l_task_open_end long :='
END EXECUTE_TASK_RULE;';

l_task_fetch_hdr long := '';

l_task_fetch_end long :='';

l_task_close_hdr long :='';

l_task_close_end long :='
END WMS_RULE_TASK_PKG'||l_counter_str||';
--COMMIT;
--EXIT;
';


-- ----------------------
-- CG Section
-- ----------------------

l_CG_hdr_S long := 'CREATE OR REPLACE PACKAGE WMS_RULE_CG_PKG'||l_counter_str||' AS


 ---- For Calling the Cost Group  rule ----
 ----

PROCEDURE EXECUTE_CG_RULE(
          p_rule_id                    IN NUMBER,
          p_line_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER);

END WMS_RULE_CG_PKG'||l_counter_str||';
--COMMIT;
--EXIT;


';


l_CG_hdr_B long := 'CREATE OR REPLACE PACKAGE BODY WMS_RULE_CG_PKG'||l_counter_str||' AS

 ---- Calling the CostGroup rule----
 ----

 PROCEDURE EXECUTE_CG_RULE(
           p_rule_id                    IN NUMBER,
           p_line_id                    IN NUMBER,
           x_result                     OUT NOCOPY NUMBER) is

   BEGIN
';
l_CG_open_end long :='
END EXECUTE_CG_RULE;';

l_CG_fetch_hdr long := '';

l_CG_fetch_end long :='';

l_CG_close_hdr long :='';

l_CG_close_end long :='
END WMS_RULE_CG_PKG'||l_counter_str||';
--COMMIT;
--EXIT;
';

-- ----------------------
-- Put Section
-- ----------------------

l_put_hdr_S long := 'CREATE OR REPLACE PACKAGE WMS_RULE_PUT_PKG'||l_counter_str||' AS


 ---- For Opening the Putaway CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                  IN OUT NOCOPY WMS_RULE_PVT.cv_put_type,
          p_rule_id                    IN NUMBER,
          p_organization_id            IN NUMBER,
          p_inventory_item_id          IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          p_subinventory_code          IN VARCHAR2,
          p_locator_id                 IN NUMBER,
          p_pp_transaction_temp_id     IN NUMBER,
          p_restrict_subs_code         IN NUMBER,
          p_restrict_locs_code         IN NUMBER,
          p_project_id                 IN NUMBER,
          p_task_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER);

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor               IN WMS_RULE_PVT.cv_put_type,
          p_rule_id              IN NUMBER,
          x_subinventory_code   OUT NOCOPY VARCHAR2,
          x_locator_id          OUT NOCOPY NUMBER,
          x_project_id          OUT NOCOPY NUMBER,
          x_task_id             OUT NOCOPY NUMBER,
          x_return_status       OUT NOCOPY NUMBER);

PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER,
                              p_cursor  IN  WMS_RULE_PVT.cv_put_type) ;

END WMS_RULE_PUT_PKG'||l_counter_str||';
--COMMIT;
--EXIT;


';

l_put_hdr_B long := 'CREATE OR REPLACE PACKAGE BODY WMS_RULE_PUT_PKG'||l_counter_str||' AS

 ---- For Opening the Putaway  CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.cv_put_type,
          p_rule_id                    IN NUMBER,
          p_organization_id            IN NUMBER,
          p_inventory_item_id          IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          p_subinventory_code          IN VARCHAR2,
          p_locator_id                 IN NUMBER,
          p_pp_transaction_temp_id     IN NUMBER,
          p_restrict_subs_code         IN NUMBER,
          p_restrict_locs_code         IN NUMBER,
          p_project_id                 IN NUMBER,
          p_task_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER) is

  BEGIN
';

l_put_open_end long :='
END EXECUTE_OPEN_RULE;';

l_put_fetch_hdr long := '

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor               IN WMS_RULE_PVT.cv_put_type,
          p_rule_id              IN NUMBER,
          x_subinventory_code    OUT NOCOPY VARCHAR2,
          x_locator_id           OUT NOCOPY NUMBER,
          x_project_id           OUT NOCOPY NUMBER,
          x_task_id              OUT NOCOPY NUMBER,
          x_return_status        OUT NOCOPY NUMBER) is

 BEGIN
';

l_put_fetch_end long :='

END EXECUTE_FETCH_RULE;';


l_put_close_hdr long :='

 PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER,
                               p_cursor  IN WMS_RULE_PVT.cv_put_type) is
   BEGIN
';

l_put_close_end long :='
 END EXECUTE_CLOSE_RULE;
END WMS_RULE_PUT_PKG'||l_counter_str||';
--COMMIT;
--EXIT;
';

-- ----------------------
-- Pick Section
-- ----------------------
l_pick_hdr_S long := 'CREATE OR REPLACE PACKAGE WMS_RULE_PICK_PKG'||l_counter_str||' AS


 ---- For Opening the PICK  CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.Cv_pick_type,
          p_rule_id                    IN NUMBER,
          p_organization_id            IN NUMBER,
          p_inventory_item_id          IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          p_revision                   IN VARCHAR2,
          p_lot_number                 IN VARCHAR2,
          p_subinventory_code          IN VARCHAR2,
          p_locator_id                 IN NUMBER,
          p_cost_group_id              IN NUMBER,
          p_pp_transaction_temp_id     IN NUMBER,
          p_serial_controlled          IN NUMBER,
          p_detail_serial              IN NUMBER,
          p_detail_any_serial          IN NUMBER,
          p_from_serial_number         IN VARCHAR2,
          p_to_serial_number           IN VARCHAR2,
          p_unit_number                IN VARCHAR2,
          p_lpn_id                     IN NUMBER,
          p_project_id                 IN NUMBER,
          p_task_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER);

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor                IN WMS_RULE_PVT.Cv_pick_type,
          p_rule_id               IN NUMBER,
          x_revision              OUT NOCOPY VARCHAR2,
          x_lot_number            OUT NOCOPY VARCHAR2,
          x_lot_expiration_date   OUT NOCOPY DATE,
          x_subinventory_code     OUT NOCOPY VARCHAR2,
          x_locator_id            OUT NOCOPY NUMBER,
          x_cost_group_id         OUT NOCOPY NUMBER,
          x_uom_code              OUT NOCOPY VARCHAR2,
          x_lpn_id                OUT NOCOPY NUMBER,
          x_serial_number         OUT NOCOPY VARCHAR2,
          x_possible_quantity     OUT NOCOPY NUMBER,
          x_sec_possible_quantity OUT NOCOPY NUMBER,
          x_grade_code            OUT NOCOPY VARCHAR2,
          x_consist_string        OUT NOCOPY VARCHAR2,
          x_order_by_string       OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY NUMBER);

PROCEDURE EXECUTE_FETCH_AVAILABLE_INV (
          p_cursor                IN WMS_RULE_PVT.Cv_pick_type,
          p_rule_id               IN NUMBER,
          x_return_status         OUT NOCOPY NUMBER
          );

PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER ,
                               p_cursor IN  WMS_RULE_PVT.Cv_pick_type) ;

END WMS_RULE_PICK_PKG'||l_counter_str||';
--COMMIT;
--EXIT;


';

l_pick_hdr_B long := 'CREATE OR REPLACE PACKAGE BODY WMS_RULE_PICK_PKG'||l_counter_str||' AS

 ---- For Opening the Pick CURSOR ----
 ----
PROCEDURE EXECUTE_OPEN_RULE(
          p_cursor                     IN OUT NOCOPY WMS_RULE_PVT.Cv_pick_type,
          p_rule_id                    IN NUMBER,
          p_organization_id            IN NUMBER,
          p_inventory_item_id          IN NUMBER,
          p_transaction_type_id        IN NUMBER,
          p_revision                   IN VARCHAR2,
          p_lot_number                 IN VARCHAR2,
          p_subinventory_code          IN VARCHAR2,
          p_locator_id                 IN NUMBER,
          p_cost_group_id              IN NUMBER,
          p_pp_transaction_temp_id     IN NUMBER,
          p_serial_controlled          IN NUMBER,
          p_detail_serial              IN NUMBER,
          p_detail_any_serial          IN NUMBER,
          p_from_serial_number         IN VARCHAR2,
          p_to_serial_number           IN VARCHAR2,
          p_unit_number                IN VARCHAR2,
          p_lpn_id                     IN NUMBER,
          p_project_id                 IN NUMBER,
          p_task_id                    IN NUMBER,
          x_result                     OUT NOCOPY NUMBER) is

  BEGIN
';

l_pick_open_end long := '
END EXECUTE_OPEN_RULE;';

l_pick_fetch_hdr long := '

PROCEDURE EXECUTE_FETCH_RULE (
          p_cursor               IN  WMS_RULE_PVT.Cv_pick_type,
          p_rule_id              IN NUMBER,
          x_revision              OUT NOCOPY VARCHAR2,
          x_lot_number            OUT NOCOPY VARCHAR2,
          x_lot_expiration_date   OUT NOCOPY DATE,
          x_subinventory_code     OUT NOCOPY VARCHAR2,
          x_locator_id            OUT NOCOPY NUMBER,
          x_cost_group_id         OUT NOCOPY NUMBER,
          x_uom_code              OUT NOCOPY VARCHAR2,
          x_lpn_id                OUT NOCOPY NUMBER,
          x_serial_number         OUT NOCOPY VARCHAR2,
          x_possible_quantity     OUT NOCOPY NUMBER,
          x_sec_possible_quantity OUT NOCOPY NUMBER,
          x_grade_code            OUT NOCOPY VARCHAR2,
          x_consist_string        OUT NOCOPY VARCHAR2,
          x_order_by_string       OUT NOCOPY VARCHAR2,
          x_return_status         OUT NOCOPY NUMBER) is

 BEGIN
';


l_pick_fetch_end long :='

END EXECUTE_FETCH_RULE;';

l_pick_fetch_avail_hdr long := '

PROCEDURE EXECUTE_FETCH_AVAILABLE_INV (
          p_cursor               IN  WMS_RULE_PVT.Cv_pick_type,
          p_rule_id              IN NUMBER,
          x_return_status         OUT NOCOPY NUMBER) is

 BEGIN
';


l_pick_fetch_avail_end long :='

END EXECUTE_FETCH_AVAILABLE_INV;';


l_pick_close_hdr long :='

 PROCEDURE EXECUTE_CLOSE_RULE (p_rule_id IN NUMBER,
                               p_cursor  IN WMS_RULE_PVT.Cv_pick_type) is
   BEGIN
';

l_pick_close_end long :='
 END EXECUTE_CLOSE_RULE;
END WMS_RULE_PICK_PKG'||l_counter_str||';
--COMMIT;
--EXIT;
';

 -- ----------------------
 -- Operation Plan  Section
 -- ----------------------
 l_op_hdr_S long := 'CREATE OR REPLACE PACKAGE WMS_RULE_OP_PKG'||l_counter_str||' AS


  ---- For Opening the Operartion Plan CURSOR ----
  ----
 PROCEDURE EXECUTE_OP_RULE(
           p_rule_id                    IN NUMBER,
           p_transaction_type_id        IN NUMBER,
           x_return_status              OUT NOCOPY NUMBER);

 END WMS_RULE_OP_PKG'||l_counter_str||';
 --COMMIT;
 --EXIT;


 ';

 l_OP_hdr_B long := 'CREATE OR REPLACE PACKAGE BODY WMS_RULE_OP_PKG'||l_counter_str||' AS

  ---- For Opening the Operartion Plan CURSOR ----
  ----
 PROCEDURE EXECUTE_OP_RULE(
           p_rule_id                    IN NUMBER,
           p_transaction_type_id        IN NUMBER,
           x_return_status              OUT NOCOPY NUMBER) is

   BEGIN
 ';

 l_op_open_end long :='
 END EXECUTE_OP_RULE;';

 l_op_fetch_hdr long := '';

 l_op_fetch_end long :='';

 l_op_close_hdr long :='';

 l_op_close_end long :='
 END WMS_RULE_op_PKG'||l_counter_str||';
 --COMMIT;
 --EXIT;
 ';
---------------------------------
BEGIN

   --debug
   if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('Begin GenerateSQL()...p_type_code: ' ||
             p_type_code);
      inv_pp_debug.send_long_to_pipe('Begin GenerateSQL : Package Code Type ' || p_pkg_type);
   end if;

   l_pkg_stmt_o := NULL;
   l_pkg_stmt_f := NULL;
   l_pkg_stmt_c := NULL;
   l_pkg_body_o :=' ';
   l_pkg_body_f :=' ';
   l_pkg_body_c :=' ';
   l_pkg_stmt_f_avail := NULL;
   l_pkg_body_f_avail :=' ';
   -- bug #3407019
   --l_rule_count := 0;


   OPEN rule_curs;
   FETCH rule_curs BULK COLLECT INTO ruletab;
   CLOSE rule_curs;

      gmi_reservation_util.println('GENPK , l_counter_str '||l_counter_str);
-- LG convergence add my package here
   IF (l_type_code = PICK_TYPE) THEN
      gmi_reservation_util.println('GENPK , picking gen');
      l_package_name := 'WMS_RULE_PICK_PKG';
      l_pkg_hdr_S      := l_pick_hdr_S;
      l_pkg_hdr_B      := l_pick_hdr_B;
      l_pkg_open_end   := l_pick_open_end;
      l_pkg_fetch_hdr  := l_pick_fetch_hdr;
      l_pkg_close_hdr  := l_pick_close_hdr;
      l_pkg_fetch_end  := l_pick_fetch_end;
      l_pkg_close_end  := l_pick_close_end;


         l_package_name :=  l_package_name  || l_counter_str;

        if inv_pp_debug.is_debug_mode then
	        inv_pp_debug.send_long_to_pipe(' Package Name + counter ' ||
	             l_package_name);
         end if;


      FOR i in 1..ruletab.count loop
        IF (i  > 1) THEN
           l_if_cl := '    ELSIF ';
        ELSE l_if_cl := '    IF ';
        END IF;
        l_rule_id := ruletab(i) ;

        IF ( rule_cnt > 48) THEN
           j := j + 1;
           g_tbl_pkg_body(j) := l_pkg_body_o;
           g_tbl_pkg_body_f(j) := l_pkg_body_f;
           g_tbl_pkg_body_f_avail(j) := l_pkg_body_f_avail;
           g_tbl_pkg_body_c(j) := l_pkg_body_c;
           l_pkg_body_o := ' ';
           l_pkg_body_f := ' ';
           l_pkg_body_f_avail := ' ';
           l_pkg_body_c := ' ';
           rule_cnt := 0;

        END IF;

        rule_cnt := rule_cnt + 1;
        l_pkg_body_o := l_pkg_body_o || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.open_curs(
             p_cursor,
             p_organization_id,
             p_inventory_item_id,
             p_transaction_type_id,
             p_revision,
             p_lot_number,
             p_subinventory_code,
             p_locator_id,
             p_cost_group_id,
             p_pp_transaction_temp_id,
             p_serial_controlled,
             p_detail_serial,
             p_detail_any_serial,
             p_from_serial_number,
             p_to_serial_number,
             p_unit_number,
             p_lpn_id,
             p_project_id,
             p_task_id,
    	 x_result );
 ';

        l_pkg_body_f := l_pkg_body_f || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.fetch_one_row(
         p_cursor,
         x_revision,
         x_lot_number,
         x_lot_expiration_date,
         x_subinventory_code,
         x_locator_id,
         x_cost_group_id,
         x_uom_code,
         x_lpn_id,
         x_serial_number,
         x_possible_quantity,
         x_sec_possible_quantity,
         x_grade_code,
         x_consist_string,
         x_order_by_string,
         x_return_status );
 ';
        gmi_reservation_util.println('GENPK , f_avail gen '||l_rule_id);
        l_pkg_body_f_avail := l_pkg_body_f_avail || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.fetch_available_rows(
         p_cursor,
         x_return_status );
 ';
      --  end if;
      -- gmi_reservation_util.println('GENPK , l_body_f_avail '||l_pkg_body_f_avail);


        l_pkg_body_c := l_pkg_body_c || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
          WMS_RULE_' || l_rule_id || '.close_curs(p_cursor);
 ';

   END LOOP;

-- END of LG convergence

   ELSIF (l_type_code = PUT_TYPE ) THEN
      l_package_name := 'WMS_RULE_PUT_PKG';
      l_pkg_hdr_S      := l_put_hdr_S;
      l_pkg_hdr_B      := l_put_hdr_B;
      l_pkg_open_end   := l_put_open_end;
      l_pkg_fetch_hdr  := l_put_fetch_hdr;
      l_pkg_close_hdr  := l_put_close_hdr;
      l_pkg_fetch_end  := l_put_fetch_end;
      l_pkg_close_end  := l_put_close_end;

       l_package_name :=  l_package_name  || l_counter_str;

      FOR i in 1..ruletab.count loop
        IF (i  > 1) THEN
           l_if_cl := '    ELSIF ';
        ELSE l_if_cl := '    IF ';
        END IF;
        l_rule_id := ruletab(i) ;

        IF ( rule_cnt > 50) THEN
           j := j + 1;
           g_tbl_pkg_body(j) := l_pkg_body_o;
           g_tbl_pkg_body_f(j) := l_pkg_body_f;
           g_tbl_pkg_body_c(j) := l_pkg_body_c;
           l_pkg_body_o := NULL;
           l_pkg_body_f := NULL;
           l_pkg_body_c := NULL;
           rule_cnt := 0;

        END IF;

        rule_cnt := rule_cnt + 1;

        l_pkg_body_o := l_pkg_body_o || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.open_curs(
         p_cursor,
         p_organization_id,
         p_inventory_item_id,
         p_transaction_type_id,
         p_subinventory_code,
         p_locator_id,
         p_pp_transaction_temp_id,
         p_restrict_subs_code,
         p_restrict_locs_code,
         p_project_id,
         p_task_id,
         x_result );
 ';

        l_pkg_body_f := l_pkg_body_f || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.fetch_one_row(
         p_cursor,
         x_subinventory_code,
         x_locator_id,
         x_project_id,
         x_task_id,
         x_return_status );
 ';

        l_pkg_body_c := l_pkg_body_c || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
          WMS_RULE_' || l_rule_id || '.close_curs(p_cursor);
 ';

   END LOOP;

   ELSIF (l_type_code = TASK_TYPE   ) THEN
      l_package_name := 'WMS_RULE_TASK_PKG';
      l_pkg_hdr_S      := l_task_hdr_S;
      l_pkg_hdr_B      := l_task_hdr_B;
      l_pkg_open_end   := l_task_open_end;
      l_pkg_fetch_hdr  := l_task_fetch_hdr;
      l_pkg_close_hdr  := l_task_close_hdr;
      l_pkg_fetch_end  := l_task_fetch_end;
      l_pkg_close_end  := l_task_close_end;

       l_package_name :=  l_package_name  || l_counter_str;


      FOR i in 1..ruletab.count loop
        IF (i  > 1) THEN
           l_if_cl := '    ELSIF ';
        ELSE l_if_cl := '    IF ';
        END IF;
        l_rule_id := ruletab(i) ;

        IF ( rule_cnt > 100) THEN
           j := j + 1;
           g_tbl_pkg_body(j) := l_pkg_body_o;
           l_pkg_body_o := NULL;
           rule_cnt := 0;

        END IF;

        rule_cnt := rule_cnt + 1;

        l_pkg_body_o := l_pkg_body_o || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.Get_Task(
    	 p_transaction_type_id,
    	 x_return_status );
 ';

     END LOOP;
   ELSIF (l_type_code = LABEL_TYPE    ) THEN
      l_package_name := 'WMS_RULE_LABEL_PKG';
      l_pkg_hdr_S      := l_label_hdr_S;
      l_pkg_hdr_B      := l_label_hdr_B;
      l_pkg_open_end   := l_label_open_end;
      l_pkg_fetch_hdr  := l_label_fetch_hdr;
      l_pkg_close_hdr  := l_label_close_hdr;
      l_pkg_fetch_end  := l_label_fetch_end;
      l_pkg_close_end  := l_label_close_end;

      l_package_name :=  l_package_name  || l_counter_str;



      FOR i in 1..ruletab.count loop
        IF (i  > 1) THEN
           l_if_cl := '    ELSIF ';
        ELSE l_if_cl := '    IF ';
        END IF;
        l_rule_id := ruletab(i) ;

        IF ( rule_cnt > 100) THEN
           j := j + 1;
           g_tbl_pkg_body(j) := l_pkg_body_o;
           l_pkg_body_o := NULL;
           rule_cnt := 0;

        END IF;
        rule_cnt := rule_cnt + 1;

        l_pkg_body_o := l_pkg_body_o || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.Get_Label_Format(
    	 p_label_request_id,
    	 x_return_status );
 ';

   END LOOP;

   ELSIF (l_type_code = CG_TYPE   ) THEN
      l_package_name := 'WMS_RULE_CG_PKG';
      l_pkg_hdr_S      := l_CG_hdr_S;
      l_pkg_hdr_B      := l_CG_hdr_B;
      l_pkg_open_end   := l_CG_open_end;
      l_pkg_fetch_hdr  := l_CG_fetch_hdr;
      l_pkg_close_hdr  := l_CG_close_hdr;
      l_pkg_fetch_end  := l_CG_fetch_end;
      l_pkg_close_end  := l_CG_close_end;


        l_package_name :=  l_package_name  || l_counter_str;

     --- Bug # 3812503
     if ruletab.count > 3000 then
        l_new_ctr := 3000;
        else
        l_new_ctr := ruletab.count;
     end if;

      FOR i in 1..l_new_ctr loop
        IF (i  > 1) THEN
           l_if_cl := '    ELSIF ';
        ELSE
           l_if_cl := '    IF ';
        END IF;
        l_rule_id := ruletab(i) ;

        IF ( rule_cnt > 100) THEN
           j := j + 1;
           g_tbl_pkg_body(j) := l_pkg_body_o;
           l_pkg_body_o := NULL;
           rule_cnt := 0;

        END IF;

        rule_cnt := rule_cnt + 1;

        l_pkg_body_o := l_pkg_body_o || l_if_cl ||
                     '   p_rule_id = ' || l_rule_id || ' THEN
         WMS_RULE_' || l_rule_id || '.Get_CostGroup(
    	 p_line_id,
    	 x_result );
 ';

   END LOOP;

   ELSIF (l_type_code = OP_TYPE   ) THEN
       l_package_name := 'WMS_RULE_OP_PKG';
       l_pkg_hdr_S      := l_op_hdr_S;
       l_pkg_hdr_B      := l_op_hdr_B;
       l_pkg_open_end   := l_op_open_end;
       l_pkg_fetch_hdr  := l_op_fetch_hdr;
       l_pkg_close_hdr  := l_op_close_hdr;
       l_pkg_fetch_end  := l_op_fetch_end;
       l_pkg_close_end  := l_op_close_end;

        l_package_name :=  l_package_name  || l_counter_str;


       FOR i in 1..ruletab.count loop
         IF (i  > 1) THEN
            l_if_cl := '    ELSIF ';
         ELSE l_if_cl := '    IF ';
         END IF;
         l_rule_id := ruletab(i) ;


         IF ( rule_cnt > 100) THEN
            j := j + 1;
            g_tbl_pkg_body(j) := l_pkg_body_o;
            l_pkg_body_o := NULL;
            rule_cnt := 0;

         END IF;

         rule_cnt := rule_cnt + 1;

         l_pkg_body_o := l_pkg_body_o || l_if_cl ||
                      '   p_rule_id = ' || l_rule_id || ' THEN
          WMS_RULE_' || l_rule_id || '.Get_OP(
     	 p_transaction_type_id,
     	 x_return_status );
  ';

    END LOOP;
   END IF ;


   if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('l_rule_id: ' ||
             l_rule_id);
   end if;

    IF (l_rule_id IS NOT NULL) THEN
        --inv_pp_debug.send_long_to_pipe('l_rule_id NOT NULL ');
       l_endif_cl := '
     END IF;';
    --- Bug #3812503 ----
       IF (l_type_code = CG_TYPE  and l_new_ctr = 3000 ) THEN
          l_endif_cl := '
      ELSE
        EXECUTE IMMEDIATE  ''BEGIN WMS_RULE_''||to_char(p_rule_id)||''.Get_CostGroup( :p_line_id,  :x_result ); END;'' using p_line_id , out x_result;

      END IF;' ;

       END IF;
    ELSE
       l_endif_cl := ' NULL;';
    END IF;

    l_pkg_body_o := l_pkg_body_o || l_endif_cl || l_pkg_open_end ;
      --inv_pp_debug.send_long_to_pipe('l_pkg_body_o' || l_pkg_body_o);

        --gmi_reservation_util.println('GENPK , rule_cnt '||rule_cnt);
   IF ( rule_cnt >= 1) THEN
     j := j + 1;
     g_tbl_pkg_body(j) := l_pkg_body_o;


     IF ( l_type_code = PICK_TYPE or l_type_code = PUT_TYPE ) then
        g_tbl_pkg_body_f(j) := l_pkg_body_f;
        g_tbl_pkg_body_c(j) := l_pkg_body_c;
        g_tbl_pkg_body_f_avail(j) := l_pkg_body_f_avail;
     ELSE
        g_tbl_pkg_body(j) := g_tbl_pkg_body(j) || l_pkg_close_end;
     END IF;
  END IF;

  --inv_pp_debug.send_long_to_pipe('l_pkg_stmt_c' || l_pkg_stmt_c);
   if inv_pp_debug.is_debug_mode then
      inv_pp_debug.send_long_to_pipe('BEFORE :Begin GenerateSQL : Package Code Type ' || p_pkg_type);
   end if;
--------------------------

 if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('Begin GenerateSQL()...p_type_code: ' ||
             p_type_code);
      inv_pp_debug.send_long_to_pipe('Begin GenerateSQL : Package Code Type ' || p_pkg_type);
   end if;

 IF  (p_pkg_type is null or p_pkg_type = 'S') then
        gmi_reservation_util.println('GENPK , building spec');

       if inv_pp_debug.is_debug_mode then
              inv_pp_debug.send_long_to_pipe('Inside ... Spec for creating specs');
              inv_pp_debug.send_long_to_pipe('INSIDE' || p_pkg_type);

      end if;

       -- Initialize the global variables needed to build package
       InitBuildPackage;

       -- Calls buildpackage
       BuildPackage(l_pkg_hdr_S);
      --debug
      if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('Calls CreatePackage() ...');
      end if;
     --create the package spec
       CreatePackage(x_return_status, l_package_name, FALSE);
       if inv_pp_debug.is_debug_mode then
          inv_pp_debug.send_long_to_pipe('x_return_status : '|| x_return_status);
       end if;

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF;
 END IF ;
--------
---------

      if inv_pp_debug.is_debug_mode then
                inv_pp_debug.send_long_to_pipe('BEFORE ... Body for creating Body');
                inv_pp_debug.send_long_to_pipe('BEFORE' || p_pkg_type);
      end if;

IF  (p_pkg_type is null or p_pkg_type = 'B') then

        gmi_reservation_util.println('GENPK , building body');

      if inv_pp_debug.is_debug_mode then
                inv_pp_debug.send_long_to_pipe('Inside ... Body for creating Body');
                inv_pp_debug.send_long_to_pipe('INSIDE' || p_pkg_type);
      end if;

     -- ---------------------------------
     -- Create Package Body
     -- ---------------------------------
      --re initialize global variables
        InitBuildPackage;

     if inv_pp_debug.is_debug_mode then
         inv_pp_debug.send_long_to_pipe('Call Build_Package() : ' ||
             l_pkg_hdr_B);
         inv_pp_debug.send_long_to_pipe('l_pkg_stmt_o : ' || l_pkg_stmt_o);
         inv_pp_debug.send_long_to_pipe('l_pkg_stmt_f : ' || l_pkg_stmt_f);
         inv_pp_debug.send_long_to_pipe('l_pkg_stmt_c : ' || l_pkg_stmt_c);
     end if;
     BuildPackage(l_pkg_hdr_B);
     FOR i in 1..g_tbl_pkg_body.count loop
         IF (g_tbl_pkg_body.EXISTS(i)) THEN
           BuildPackage(g_tbl_pkg_body(i));
           g_tbl_pkg_body(i) := NULL;
        END IF;
     END LOOP;

     gmi_reservation_util.println('GENPK , f_count '||g_tbl_pkg_body_f.count);
     IF (g_tbl_pkg_body_f.count >=1 ) THEN
        BuildPackage(l_pkg_fetch_hdr);
        FOR i in 1..g_tbl_pkg_body_f.count loop
           IF (g_tbl_pkg_body_f.EXISTS(i)) THEN
              BuildPackage(g_tbl_pkg_body_f(i));
              g_tbl_pkg_body_f(i) := NULL;
           END IF;

        END LOOP;
        BuildPackage(l_endif_cl || l_pkg_fetch_end);
     END IF;

-- LG convergence ADD
     IF (l_type_code = PICK_TYPE) THEN
        gmi_reservation_util.println('GENPK , f_count '||g_tbl_pkg_body_f_avail.count);
        IF (g_tbl_pkg_body_f_avail.count >=1 ) THEN
           BuildPackage(l_pick_fetch_avail_hdr);
           FOR i in 1..g_tbl_pkg_body_f_avail.count loop
              IF (g_tbl_pkg_body_f_avail.EXISTS(i)) THEN
                 BuildPackage(g_tbl_pkg_body_f_avail(i));
                 g_tbl_pkg_body_f_avail(i) := NULL;
              END IF;

           END LOOP;
           BuildPackage(l_endif_cl || l_pick_fetch_avail_end);
        END IF;
     END IF;
-- END LG convergence

     IF (g_tbl_pkg_body_c.count >=1 ) THEN
        BuildPackage(l_pkg_close_hdr);
        FOR i in 1..g_tbl_pkg_body_c.count loop
            IF (g_tbl_pkg_body_c.EXISTS(i)) THEN
               BuildPackage(g_tbl_pkg_body_c(i));
               g_tbl_pkg_body_c(i) := NULL;
            END IF;
        END LOOP;
        BuildPackage(l_endif_cl || l_pkg_close_end);
     END IF;
     /*====================================================================
      * Deallocate the table space memory by deleting all rows from tables.
      *====================================================================
      */

      IF (g_tbl_pkg_body.count >= 1) THEN
         g_tbl_pkg_body.DELETE;
      END IF;
      IF (g_tbl_pkg_body_f.count >= 1) THEN
         g_tbl_pkg_body_f.DELETE;
      END IF;
      IF (g_tbl_pkg_body_f_avail.count >= 1) THEN
         g_tbl_pkg_body_f_avail.DELETE;
      END IF;
      IF (g_tbl_pkg_body_c.count >= 1) THEN
         g_tbl_pkg_body_c.DELETE;
      END IF;
/*
     BuildPackage(l_pkg_hdr_B);
     BuildPackage(l_pkg_stmt_o);
     BuildPackage(l_pkg_stmt_f);
     BuildPackage(l_pkg_stmt_c);
*/
     --debug
      if inv_pp_debug.is_debug_mode then
         inv_pp_debug.send_long_to_pipe('Call CreatePackage() for BODY ..');
         inv_pp_debug.send_long_to_pipe(l_package_name);
      end if;
      --create the package body
      CreatePackage(x_return_status, l_package_name, FALSE);

      IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
        ELSIF x_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
      END IF;

   END IF;
   COMMIT;

END GenerateSQL;


PROCEDURE GenerateRuleExecPkgs
  (p_api_version      IN   NUMBER                                 ,
   p_init_msg_list    IN   VARCHAR2 	                          ,
   p_validation_level IN   NUMBER                                 ,
   x_return_status    OUT  NOCOPY VARCHAR2 				  ,
   x_msg_count        OUT  NOCOPY NUMBER 				  ,
   x_msg_data         OUT  NOCOPY VARCHAR2 				  ,
   p_pick_code        IN   NUMBER                                 ,
   p_put_code         IN   NUMBER                                 ,
   p_task_code        IN   NUMBER                                 ,
   p_label_code       IN   NUMBER                                 ,
   p_CG_code          IN   NUMBER                                 ,
   p_OP_code          IN   NUMBER                                 ,
   p_pkg_type         IN   VARCHAR2
   ) IS

-- API standard variables
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_api_name            CONSTANT VARCHAR2(30) := 'GenerateRuleExecPkgs';

  --
-- Static value
  PUT_TYPE             NUMBER := 1;
  PICK_TYPE            NUMBER := 2;
  TASK_TYPE            NUMBER := 3;
  LABEL_TYPE           NUMBER := 4;
  CG_TYPE              NUMBER := 5;
  op_type              NUMBER := 7;
  -- variables needed for dynamic SQL
  l_cursor              INTEGER;
  l_rows                INTEGER;
  l_rule_id             wms_rules_b.rule_id%TYPE;
  l_type_code           wms_rules_b.TYPE_CODE%TYPE;
  l_package_name        VARCHAR2(255);
  l_pkg_stmt            long;
  l_pkg_hdr             long;
  l_type_name           VARCHAR2(40);
  l_counter             NUMBER := 1;
  l_counter_str         VARCHAR2(40) :='';

  ------
   l_no_pick_rules      NUMBER := 0;
   l_no_put_rules       NUMBER := 0;
   l_no_cg_rules        NUMBER := 0;
   l_no_task_rules      NUMBER := 0;
   l_no_label_rules     NUMBER := 0;
   l_no_op_rules        NUMBER := 0;


-- cursor for validation of input parameters and pre-requisites
BEGIN
   -- Bug #3432157
      select oracle_username into g_owner
       from  fnd_oracle_userid
      where  read_only_flag = 'U';

   --- get number of records for each rule_type Bug # 2729877
   if (p_pkg_type = 'B' ) then
	   l_no_pick_rules    := get_rule_count(PICK_TYPE);
	   l_no_put_rules     := get_rule_count(PUT_TYPE);
	   l_no_cg_rules      := get_rule_count(CG_TYPE);
	   l_no_task_rules    := get_rule_count(TASK_TYPE);
	   l_no_label_rules   := get_rule_count(LABEL_TYPE);
	   l_no_op_rules      := get_rule_count(OP_TYPE);
    end if;

   if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('p_pick_code : ' || p_pick_code);
        inv_pp_debug.send_long_to_pipe('p_put_code : '   || p_put_code);
        inv_pp_debug.send_long_to_pipe('p_task_code : ' || p_task_code);
        inv_pp_debug.send_long_to_pipe('p_label_code : ' || p_label_code);
        inv_pp_debug.send_long_to_pipe('p_CG_code : ' || p_CG_code);
        inv_pp_debug.send_long_to_pipe('p_OP_code : ' || p_OP_code);
        inv_pp_debug.send_long_to_pipe('Package Code Type ' || p_pkg_type);

   end if;
   --validate P parameters
   IF (p_pick_code IS NULL ) AND
      (p_put_code IS NULL ) AND
      (p_task_code IS NULL ) AND
      (p_label_code IS NULL ) AND
      (p_CG_code IS NULL ) AND
      (p_op_code IS NULL ) 	  THEN
      fnd_message.set_name('WMS', 'WMS_INVALID_TYPE');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;

   END IF;

    --- Pick
    ---

   IF (p_pick_code IS NOT NULL) THEN

         -- Set the counter and counter strings
         --
         l_type_name := 'PICK' ;
         l_counter := get_count_with_lock(l_type_name);

         if l_counter = 3 then
            l_counter := 0;
         end if;
         l_counter     := l_counter + 1;
         l_counter_str := to_char(l_counter);




     if (l_counter <> -1 ) then

       if (l_no_pick_rules > 0 and p_pkg_type = 'B' ) or (p_pkg_type = 'S' ) then
         GenerateSQL(p_api_version   => 1.0,
                  p_init_msg_list    => fnd_api.g_false       ,
                  p_validation_level => fnd_api.g_valid_level_full ,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data ,
                  p_type_code        => p_pick_code,
                  p_type_name        => l_type_name,
                  p_counter          => l_counter ,
                  p_counter_str      => l_counter_str,
                  p_pkg_type         => p_pkg_type);

            if (x_return_status = 'S')  then
                update_count(l_type_name, l_counter );
            end if;
        end if;

      end if;


   END IF;

 --- Putaway
 ---

   IF (p_put_code IS NOT NULL) THEN

      -- Set the counter and counter strings
            --
             l_type_name := 'PUTAWAY' ;
             l_counter := get_count_with_lock(l_type_name);

             if l_counter = 3 then
                l_counter  := 0;
             end if;
             l_counter     := l_counter + 1;
             l_counter_str := to_char(l_counter);

          if (l_counter <> -1 ) then

             if (l_no_put_rules > 0 and p_pkg_type = 'B' ) or (p_pkg_type = 'S' ) then

               GenerateSQL(p_api_version      => 1.0,
                  p_init_msg_list    => fnd_api.g_false       ,
                  p_validation_level => fnd_api.g_valid_level_full ,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  p_type_code        => p_put_code,
                  p_type_name        => l_type_name,
                  p_counter          => l_counter ,
                  p_counter_str      => l_counter_str,
                  p_pkg_type         => p_pkg_type);

             if (x_return_status = 'S')  then
                 update_count(l_type_name, l_counter );
             end if;
          end if;
       end if;

   END IF;
   --- Tasks
   ---
   IF (p_task_code IS NOT NULL) THEN

        -- Set the counter and counter strings
        --
               l_type_name := 'TASK' ;
               l_counter := get_count_with_lock(l_type_name);


              if l_counter = 3 then
                 l_counter  := 0;
              end if;
              l_counter     := l_counter + 1;
              l_counter_str  := to_char(l_counter);

           if (l_counter <> -1 ) then

            if (l_no_task_rules > 0 and p_pkg_type = 'B' ) or (p_pkg_type = 'S' ) then

                GenerateSQL(p_api_version         => 1.0,
                  p_init_msg_list    => fnd_api.g_false       ,
                  p_validation_level => fnd_api.g_valid_level_full ,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  p_type_code        => p_task_code,
                  p_type_name        => l_type_name,
                  p_counter          => l_counter,
                  p_counter_str      => l_counter_str,
                  p_pkg_type         => p_pkg_type);

               if (x_return_status = 'S')  then
                   update_count(l_type_name, l_counter );
               end if;

            end if;
        end if;
   END IF;

   --- Labels
   ---
   IF (p_label_code IS NOT NULL) THEN

        -- Set the counter and counter strings
        --
               l_type_name := 'LABEL' ;
               l_counter := get_count_with_lock(l_type_name);


             if l_counter = 3 then
                l_counter  := 0;
             end if;

             l_counter     := l_counter + 1;
             l_counter_str := to_char(l_counter);


            if (l_counter <> -1 ) then

                if (l_no_label_rules > 0 and p_pkg_type = 'B' ) or (p_pkg_type = 'S' ) then

                GenerateSQL(p_api_version         => 1.0,
                  p_init_msg_list    => fnd_api.g_false       ,
                  p_validation_level => fnd_api.g_valid_level_full ,
                  x_return_status    => x_return_status,
                  x_msg_count        => x_msg_count,
                  x_msg_data         => x_msg_data,
                  p_type_code        => p_label_code,
                  p_type_name        => l_type_name,
                  p_counter          => l_counter,
                  p_counter_str      => l_counter_str,
                  p_pkg_type         => p_pkg_type);

               if (x_return_status = 'S')  then
                  update_count(l_type_name, l_counter );
               end if;

            end if;
         end if;
   END IF;
   -- Cost Group
   ---

   IF (p_CG_code IS NOT NULL) THEN

        -- Set the counter and counter strings
        --
                l_type_name := 'COST_GROUP' ;
	        l_counter := get_count_with_lock(l_type_name);



             if l_counter = 3 then
                l_counter  := 0;
             end if;
             l_counter     := l_counter + 1;
             l_counter_str := to_char(l_counter);

            if (l_counter <> -1 ) then

               if (l_no_cg_rules > 0 and p_pkg_type = 'B' ) or (p_pkg_type = 'S' ) then

                GenerateSQL(p_api_version         => 1.0,
                  p_init_msg_list       => fnd_api.g_false       ,
                  p_validation_level    => fnd_api.g_valid_level_full ,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_type_code           => p_CG_code,
                  p_type_name           => l_type_name,
                  p_counter             => l_counter,
                  p_counter_str         => l_counter_str,
                  p_pkg_type         => p_pkg_type);

                if (x_return_status = 'S')  then
                   update_count(l_type_name, l_counter );
                end if;

            end if;
         end if;
   END IF;

   --- Operation plans
   ---
   IF (p_OP_code IS NOT NULL) THEN
      -- Set the counter and counter strings
      --
      l_type_name := 'OPERATION_PLAN' ;
      l_counter   := get_count_with_lock(l_type_name);


      if l_counter = 3 then
         l_counter  := 0;
      end if;
      l_counter     := l_counter + 1;
      l_counter_str := to_char(l_counter);

      if (l_counter <> -1 ) then

           if (l_no_op_rules > 0 and p_pkg_type = 'B' ) or (p_pkg_type = 'S' ) then

	 GenerateSQL(p_api_version         => 1.0,
		     p_init_msg_list    => fnd_api.g_false       ,
		     p_validation_level => fnd_api.g_valid_level_full ,
		     x_return_status    => x_return_status,
		     x_msg_count        => x_msg_count,
		     x_msg_data         => x_msg_data,
		     p_type_code        => p_OP_code,
		     p_type_name        => l_type_name,
		     p_counter          => l_counter,
		     p_counter_str      => l_counter_str,
		     p_pkg_type         => p_pkg_type);

	 if (x_return_status = 'S')  then
	    update_count(l_type_name, l_counter );
	 end if;

      end if;

     end if;

   END IF;
   COMMIT;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     fnd_msg_pub.count_and_get( p_count  => x_msg_count, p_data => x_msg_data );
END GenerateRuleExecPkgs;
----------------
FUNCTION  get_count_with_lock(P_RULE_TYPE IN VARCHAR2 )
RETURN NUMBER IS

 l_package_name_count  NUMBER := NULL;

 cursor c1 is
  SELECT package_name_count
    FROM WMS_RULE_LIST_PACKAGE
    WHERE rule_type = p_rule_type for update;

 BEGIN

   IF c1%ISOPEN THEN
     close c1;
    END IF;

    OPEN c1;
      fetch c1 into l_package_name_count;
      IF c1%NOTFOUND THEN

          if inv_pp_debug.is_debug_mode then
	  	        inv_pp_debug.send_long_to_pipe('Get count not found' || P_RULE_TYPE);
         end if;
         -- return error;
         return(-1);
      ELSIF c1%FOUND THEN
        if inv_pp_debug.is_debug_mode then
	        inv_pp_debug.send_long_to_pipe('Get count   '|| l_package_name_count);
         end if;
       RETURN (l_package_name_count);
      END IF;
    CLOSE c1;
  EXCEPTION
    WHEN OTHERS THEN
      IF c1%isopen THEN
         close c1;
      END IF;

      if inv_pp_debug.is_debug_mode then
        inv_pp_debug.send_long_to_pipe('Get count  Excepttion '|| SQLERRM);
      end if;
      RETURN(-1);
 END get_count_with_lock;
----
---
FUNCTION  get_count_no_lock(p_rule_type IN VARCHAR2)
RETURN NUMBER IS
l_package_name_count  NUMBER := NULL;

 cursor c1 is
  SELECT package_name_count
    FROM WMS_RULE_LIST_PACKAGE
    WHERE rule_type = p_rule_type;

 BEGIN

   IF c1%ISOPEN THEN
     close c1;
    END IF;

    OPEN c1;
      fetch c1 into l_package_name_count;
      IF c1%NOTFOUND THEN
         -- return error;
         return(-1);
      ELSIF c1%FOUND THEN
       RETURN (l_package_name_count);
      END IF;
    CLOSE c1;
  EXCEPTION
    WHEN OTHERS THEN
      IF c1%isopen THEN
         close c1;
      END IF;
      RETURN(-1);
END get_count_no_lock;

---
---
PROCEDURE  update_count(
                  p_rule_type IN VARCHAR2
                , p_count     IN  NUMBER ) IS
BEGIN
  UPDATE WMS_RULE_LIST_PACKAGE
     SET PACKAGE_NAME_COUNT = p_count
   WHERE RULE_TYPE = p_rule_type;
EXCEPTION
  WHEN OTHERS THEN
  null;
END update_count;

---------

END wms_rule_gen_pkgs;

/
