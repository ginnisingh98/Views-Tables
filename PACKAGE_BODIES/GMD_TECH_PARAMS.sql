--------------------------------------------------------
--  DDL for Package Body GMD_TECH_PARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_TECH_PARAMS" AS
/* $Header: GMDTECHB.pls 115.7 2003/05/06 18:28:34 ssitaram noship $ */

G_PKG_NAME VARCHAR2(32);

/*======================================================================
--  PROCEDURE :
--   load_ingred_tp
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for returning the
--    Ingredient technical parameters.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    load_ingred_tp(X_lab_type, X_formula_id, X_item_id, X_line_no,
--                   X_tech_tbl, X_return_status, X_msg_count, X_msg_data);
--
--
--===================================================================== */
PROCEDURE load_ingred_tp(p_lab_type          IN  VARCHAR2,
                         p_formula_id        IN  NUMBER,
                         p_item_id           IN  NUMBER,
                         p_line_no           IN  NUMBER,
                         x_tech_table        OUT NOCOPY tech_param_tab,
                         x_return_status     OUT NOCOPY VARCHAR2,
                         x_msg_count         OUT NOCOPY NUMBER,
                         x_msg_data          OUT NOCOPY VARCHAR2) IS

  X_row          NUMBER := 0;
  X_data_type    NUMBER;
  l_tech_table   tech_param_tab;

  NO_LAB_TYPE    EXCEPTION;
  NO_ATTRIB_DATA EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_lab_type IS NULL) THEN
    RAISE NO_LAB_TYPE;
  END IF;
  gmd_tech_params.load_lab_arrays(p_formula_id     => p_formula_id,
                                  p_lab_type       => p_lab_type,
                                  p_prod_tech_parm => 0);
  IF (attrib_master_tbl.count = 0) THEN
    RAISE NO_ATTRIB_DATA;
  END IF;
  FOR i IN 1..tp_master_tbl.count LOOP
    X_row       := X_row + 1;
    X_data_type := tp_master_tbl(i).data_type;
    x_tech_table(X_row).tech_parm_name := tp_master_tbl(i).tech_parm_name;
    x_tech_table(X_row).uom            := tp_master_tbl(i).tp_uom;
    x_tech_table(X_row).data_type      := X_data_type;
    x_tech_table(X_row).expression     := tp_master_tbl(i).expression;
    FOR j IN 1..attrib_master_tbl.count LOOP
      IF ((attrib_master_tbl(j).tech_parm_name = tp_master_tbl(i).tech_parm_name) AND
          (attrib_master_tbl(j).item_id = p_item_id) AND
          (attrib_master_tbl(j).line_type = -1) AND
          (attrib_master_tbl(j).line_no = p_line_no)) THEN
        IF (X_data_type IN (0,2)) THEN
          x_tech_table(X_row).value := attrib_master_tbl(j).char_value;
        ELSIF (X_data_type = 3) THEN
          x_tech_table(X_row).value := attrib_master_tbl(j).boolean_value;
        ELSIF (X_data_type IN (1,5,6,7,8,9,10)) THEN
          x_tech_table(X_row).value := attrib_master_tbl(j).num_value;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  calculate_expr(p_tech_table => x_tech_table,
                 calc_table   => l_tech_table);

  x_tech_table := l_tech_table;

  item_master_tbl.delete;
  tp_master_tbl.delete;
  attrib_master_tbl.delete;
EXCEPTION
  WHEN NO_LAB_TYPE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_LAB_TYPE_PARM');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET(P_count => x_msg_count,
                               P_data  => x_msg_data);
  WHEN NO_ATTRIB_DATA THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'LM_NO_ATTRIB_DATA');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET(P_count => x_msg_count,
                               P_data  => x_msg_data);
END load_ingred_tp;

/*======================================================================
--  PROCEDURE :
--   load_prod_tp
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for returning the
--    Product technical parameters.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    load_prod_tp(X_lab_type, X_formula_id, X_item_id, X_line_no,
--                   X_tech_tbl, X_return_status, X_msg_count, X_msg_data);
--  HISTORY
--   23-May-2002  N.Vikranth  BUG 2360400 - Modified the condition to consider
--                            the By-Products while retrieving the Technical
--                            Parameter values in Technical Parameters form.
--===================================================================== */
PROCEDURE load_prod_tp(p_lab_type          IN  VARCHAR2,
                       p_formula_id        IN  NUMBER,
                       p_item_id           IN  NUMBER,
                       p_line_no           IN  NUMBER,
                       x_tech_table        OUT NOCOPY tech_param_tab,
                       x_return_status     OUT NOCOPY VARCHAR2,
                       x_msg_count         OUT NOCOPY NUMBER,
                       x_msg_data          OUT NOCOPY VARCHAR2) IS

  X_conv_qty     NUMBER := 0;
  X_prim_qty     NUMBER := 0;
  X_prim_uom     VARCHAR2(4);
  X_data_type    NUMBER;
  X_result       NUMBER;
  l_tech_table   tech_param_tab;

  NO_LAB_TYPE    EXCEPTION;
  NO_ATTRIB_DATA EXCEPTION;
  UOM_CONV_ERR   EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (p_lab_type IS NULL) THEN
    RAISE NO_LAB_TYPE;
  END IF;
  gmd_tech_params.load_lab_arrays(p_formula_id     => p_formula_id,
                                  p_lab_type       => p_lab_type,
                                  p_prod_tech_parm => 1);
  convert_uoms(p_lab_type      => p_lab_type,
               x_return_status => x_return_status);
  IF (x_return_status <> 'S') THEN
    RAISE UOM_CONV_ERR;
  END IF;
  FOR k IN 1..item_master_tbl.count LOOP
    IF ((item_master_tbl(k).item_id = p_item_id) AND
      --BEGIN BUG 2360400 Nayini Vikranth
      --Modified the condition to consider the By-Product
      --when the line_type is 2
      (item_master_tbl(k).line_type >= 1) AND
      --END BUG 2360400
      (item_master_tbl(k).line_no = p_line_no)) THEN
      X_prim_qty := item_master_tbl(k).primary_uom_qty;
      X_prim_uom := item_master_tbl(k).item_primary_uom;
      EXIT;
    END IF;
  END LOOP;
  FOR i IN 1..tp_master_tbl.count LOOP
    X_data_type := tp_master_tbl(i).data_type;
    x_tech_table(i).tech_parm_name := tp_master_tbl(i).tech_parm_name;
    x_tech_table(i).uom            := tp_master_tbl(i).tp_uom;
    x_tech_table(i).data_type      := X_data_type;
    x_tech_table(i).expression     := tp_master_tbl(i).expression;
    FOR j IN 1..attrib_master_tbl.count LOOP
      IF ((attrib_master_tbl(j).tech_parm_name = tp_master_tbl(i).tech_parm_name) AND
          (attrib_master_tbl(j).item_id = p_item_id) AND
          --BEGIN BUG 2360400 Nayini Vikranth
          --Modified the condition to consider the By-Product
          --when the line_type is 2
          (attrib_master_tbl(j).line_type >= 1) AND
          --END BUG 2360400
          (attrib_master_tbl(j).line_no = p_line_no)) THEN
        IF (X_data_type IN (0,2)) THEN
          x_tech_table(i).value := attrib_master_tbl(j).char_value;
        ELSIF (X_data_type = 3) THEN
          x_tech_table(i).value := attrib_master_tbl(j).boolean_value;
        ELSIF (X_data_type = 1) THEN
          x_tech_table(i).value := attrib_master_tbl(j).num_value;
        ELSIF (X_data_type IN (5, 6, 7, 8, 9, 10)) THEN
          IF (X_data_type = 5) THEN
            rollup_wt_pct(p_tech_parm_name => attrib_master_tbl(j).tech_parm_name,
                          p_result         => X_result);
          ELSIF (X_data_type IN (6,7)) THEN
            rollup_vol_pct_and_spec_gr(p_tech_parm_name => attrib_master_tbl(j).tech_parm_name,
                                       p_data_type      => X_data_type,
                                       p_result         => X_result);
          ELSIF (X_data_type = 8) THEN
            rollup_cost_and_units(p_tech_parm_name => attrib_master_tbl(j).tech_parm_name,
                                  p_prod_uom       => X_prim_uom,
                                  p_lab_type       => p_lab_type,
                                  p_result         => X_result,
                                  x_return_status  => x_return_status);
            IF (x_return_status <> 'S') THEN
              X_result := 0;
            END IF;
            IF (X_result <> 0) THEN
              X_result := X_result / X_prim_qty;
            END IF;
          ELSIF (X_data_type = 9) THEN
            rollup_equiv_wt(p_tech_parm_name => attrib_master_tbl(j).tech_parm_name,
                            p_prod_uom       => X_prim_uom,
                            p_lab_type       => p_lab_type,
                            p_result         => X_result,
                            x_return_status  => x_return_status);
            IF (x_return_status <> 'S') THEN
              X_result := 0;
            END IF;
          ELSIF (X_data_type = 10) THEN
            rollup_cost_and_units(p_tech_parm_name => attrib_master_tbl(j).tech_parm_name,
                                  p_prod_uom       => X_prim_uom,
                                  p_lab_type       => p_lab_type,
                                  p_result         => X_result,
                                  x_return_status  => x_return_status);
            IF (x_return_status <> 'S') THEN
              X_result := 0;
            END IF;
          END IF;
          x_tech_table(i).value := X_result;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  calculate_expr(p_tech_table => x_tech_table,
                 calc_table   => l_tech_table);

  x_tech_table := l_tech_table;

  item_master_tbl.delete;
  tp_master_tbl.delete;
  attrib_master_tbl.delete;
EXCEPTION
  WHEN NO_LAB_TYPE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_LAB_TYPE_PARM');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET(P_count => x_msg_count,
                               P_data  => x_msg_data);
  WHEN NO_ATTRIB_DATA THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'LM_NO_ATTRIB_DATA');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET(P_count => x_msg_count,
                               P_data  => x_msg_data);
  WHEN UOM_CONV_ERR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.COUNT_AND_GET(P_count => x_msg_count,
                               P_data  => x_msg_data);
END load_prod_tp;

/*======================================================================
--  PROCEDURE :
--   load_lab_arrays
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for loading
--    all the formula related and parameter related data.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    load_lab_arrays(X_formula_id, X_lab_type, X_prod_tech_parm);
--
--
--===================================================================== */
PROCEDURE load_lab_arrays(p_formula_id NUMBER, p_lab_type VARCHAR2, p_prod_tech_parm NUMBER) IS

  CURSOR Cur_ic_item IS
    SELECT i.item_no, i.item_id, i.item_um, d.line_type, d.qty,
           d.item_um line_um, d.line_no, d.formulaline_id, NVL(d.tpformula_id,0) tpformula_id
    FROM   ic_item_mst i, fm_matl_dtl d
    WHERE  formula_id = p_formula_id
           AND i.item_id = d.item_id
    ORDER BY d.line_type, d.line_no;

  CURSOR Cur_lm_attrib IS
    SELECT i.orgn_code, i.item_id, i.tech_parm_name, i.num_data,
           i.text_data, i.boolean_data, NVL(f.tpformula_id,0) tpformula_id,
           f.line_type, f.line_no
    FROM   lm_item_dat i, fm_matl_dtl f
    WHERE  orgn_code = p_lab_type
           AND i.item_id = f.item_id
           AND f.formula_id = p_formula_id
           AND NVL(i.formula_id,0) = NVL(f.tpformula_id,0)
           AND i.lot_id = 0
    ORDER BY f.line_type, f.line_no;

  CURSOR Cur_lm_tp IS
    SELECT t.orgn_code lab_type, t.tech_parm_name, p.sort_seq, t.expression_char,
           t.data_type, t.lm_unit_code, q.orgn_code, q.assay_code
    FROM   lm_tech_hdr t, lm_prlt_asc p, gmd_tests q
    WHERE  t.orgn_code = p_lab_type
           AND p.orgn_code = t.orgn_code
           AND t.tech_parm_name = p.tech_parm_name
           AND t.qcassy_typ_id = q.qcassy_typ_id(+)
    ORDER BY p.sort_seq;

  X_row	NUMBER := 0;
  X_set	NUMBER := 0;
  X_rec	Cur_lm_attrib%ROWTYPE;
BEGIN
  /* Fetch all item-related information into item_master_array.*/
  FOR get_item IN Cur_ic_item LOOP
    X_row := X_row + 1;
    item_master_tbl(X_row).item_no          := get_item.item_no;
    item_master_tbl(X_row).item_id          := get_item.item_id;
    item_master_tbl(X_row).item_primary_uom := get_item.item_um;
    item_master_tbl(X_row).line_type        := get_item.line_type;
    item_master_tbl(X_row).quantity         := get_item.qty;
    item_master_tbl(X_row).uom              := get_item.line_um;
    item_master_tbl(X_row).line_no          := get_item.line_no;
    item_master_tbl(X_row).line_id          := get_item.formulaline_id;
    item_master_tbl(X_row).formula_id       := get_item.tpformula_id;
    item_master_tbl(X_row).lot_no           := NULL;
    item_master_tbl(X_row).sublot_no        := NULL;
    item_master_tbl(X_row).lot_id           := NULL;
    item_master_tbl(X_row).primary_uom_qty  := 0;
    item_master_tbl(X_row).mass_uom_qty     := 0;
    item_master_tbl(X_row).vol_uom_qty      := 0;
  END LOOP;
  X_row := 0;
  /* Get technical parameter-related data */
  FOR get_tp IN Cur_lm_tp LOOP
    X_row := X_row + 1;
    tp_master_tbl(X_row).tech_parm_name := get_tp.tech_parm_name;
    tp_master_tbl(X_row).expression     := get_tp.expression_char;
    tp_master_tbl(X_row).data_type      := get_tp.data_type;
    tp_master_tbl(X_row).tp_uom         := get_tp.lm_unit_code;
    tp_master_tbl(X_row).qc_orgn_code   := get_tp.orgn_code;
    tp_master_tbl(X_row).qc_assay_name  := get_tp.assay_code;
  END LOOP;
  /*Get attribute-related data*/
  OPEN Cur_lm_attrib;
  LOOP
    FETCH Cur_lm_attrib INTO X_rec;
    EXIT WHEN Cur_lm_attrib%NOTFOUND;
    X_set := 0;
    FOR i IN 1..item_master_tbl.count LOOP
      IF ((item_master_tbl(i).item_id = X_rec.item_id) AND (item_master_tbl(i).formula_id = X_rec.tpformula_id)) THEN
        IF ((item_master_tbl(i).line_type = X_rec.line_type) AND (item_master_tbl(i).line_no = X_rec.line_no)) THEN
          X_set := 1;
        END IF;
      END IF;
    END LOOP;
    IF (X_set = 1) THEN
      FOR j IN 1..tp_master_tbl.count LOOP
        IF (tp_master_tbl(j).tech_parm_name = X_rec.tech_parm_name) THEN
          X_row := attrib_master_tbl.count + 1;
          attrib_master_tbl(X_row).item_id        := X_rec.item_id;
          attrib_master_tbl(X_row).line_type      := X_rec.line_type;
          attrib_master_tbl(X_row).line_no        := X_rec.line_no;
          attrib_master_tbl(X_row).tech_parm_name := X_rec.tech_parm_name;
          attrib_master_tbl(X_row).num_value      := X_rec.num_data;
          attrib_master_tbl(X_row).char_value     := X_rec.text_data;
          attrib_master_tbl(X_row).boolean_value  := X_rec.boolean_data;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
  CLOSE Cur_lm_attrib;
  IF (p_prod_tech_parm = 1) THEN
    get_qc_results;
  END IF;
END load_lab_arrays;

/*======================================================================
--  PROCEDURE :
--   calculate_expr
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for calculating
--    the expression value.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--
--
--===================================================================== */
PROCEDURE calculate_expr(p_tech_table tech_param_tab,
                         calc_table OUT NOCOPY tech_param_tab) IS
  X_row        NUMBER;
  X_expr       VARCHAR2(500);
  X_sql_stmt   VARCHAR2(1000);
  X_value      VARCHAR2(100);
  X_cur        INTEGER;
  X_carrot     NUMBER;
  X_power      NUMBER;
  X_end_char   VARCHAR2(10);
  X_end_bracs  NUMBER;
  X_end_expr   VARCHAR2(100);
  X_start_expr VARCHAR2(100);
  X_using      Varchar2(1000);

  l_bind      VARCHAR2(100);

 BEGIN
   calc_table := p_tech_table;
   FOR i IN 1..calc_table.count LOOP
   BEGIN
     IF (calc_table(i).data_type = 4) THEN
       X_expr := UPPER(calc_table(i).expression);
       X_expr := REPLACE(X_expr, ' ', NULL);

       FOR j IN 1..calc_table.count LOOP
         l_bind := ':TPM'||j;

         IF (calc_table(j).tech_parm_name IS NOT NULL) THEN
            X_expr := REPLACE(X_expr, UPPER(calc_table(j).tech_parm_name) ,l_bind);
         END IF;
       END LOOP;

       WHILE (INSTR(X_expr,'^') > 0) LOOP
         X_carrot := INSTR(X_expr,'^');
         X_end_bracs := 0;
         LOOP
           X_carrot   := X_carrot + 1;
           X_end_char := SUBSTR(X_expr, X_carrot, 1);
           IF (X_end_char = '(') THEN
             X_end_bracs := X_end_bracs + 1;
           ELSIF (X_end_char = ')') THEN
             X_end_bracs := X_end_bracs - 1;
           END IF;
           IF (X_end_bracs = 0) THEN
             IF (X_end_char IN ('+', '-', '*', '/', '^')) THEN
               EXIT;
             ELSIF (X_end_char = ')') THEN
               X_end_expr := X_end_expr||X_end_char;
               EXIT;
             END IF;
           END IF;
           X_end_expr := X_end_expr||X_end_char;
         END LOOP;
         X_carrot := INSTR(X_expr,'^');
         X_end_bracs := 0;
         LOOP
           X_carrot   := X_carrot - 1;
           X_end_char := SUBSTR(X_expr, X_carrot, 1);
           IF (X_end_char = ')') THEN
             X_end_bracs := X_end_bracs + 1;
           ELSIF (X_end_char = '(') THEN
             X_end_bracs := X_end_bracs - 1;
           END IF;
           IF (X_end_bracs = 0) THEN
             IF (X_end_char IN ('+', '-', '*', '/', '^')) THEN
               EXIT;
             ELSIF (X_end_char = '(') THEN
               X_start_expr := X_end_char||X_start_expr;
               EXIT;
             END IF;
           END IF;
           X_start_expr := X_end_char||X_start_expr;
         END LOOP;
         X_expr := REPLACE(X_expr, X_start_expr||'^'||X_end_expr, 'POWER('||X_start_expr||','||X_end_expr||')');
       END LOOP;
       X_expr     := 'ROUND('||X_expr||',6)';
       X_sql_stmt := 'select '||X_expr||' from dual';

       IF (dbms_sql.is_open(X_cur)) THEN
         dbms_sql.close_cursor(X_cur);
       END IF;

       X_cur := dbms_sql.open_cursor;
       dbms_sql.parse(X_cur, X_sql_stmt, 0);

       FOR j IN 1..calc_table.count LOOP
         IF (calc_table(j).tech_parm_name IS NOT NULL) AND
            (INSTR(X_sql_stmt, ':TPM'||j) <> 0) THEN
           DBMS_SQL.BIND_VARIABLE(X_cur,':TPM'||j, calc_table(j).value);
         END IF;
       END LOOP;

       dbms_sql.define_column(X_cur, 1, X_expr, 100);
       X_row := dbms_sql.execute(X_cur);
       IF (dbms_sql.fetch_rows(X_cur) > 0) THEN
         dbms_sql.column_value(X_cur, 1, X_value);
         calc_table(i).value := X_value;
       END IF;

       dbms_sql.close_cursor(X_cur);

     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       IF (dbms_sql.is_open(X_cur)) THEN
         dbms_sql.close_cursor(X_cur);
       END IF;
       fnd_msg_pub.add_exc_msg ('GMD_TECH_PARAMS', 'CALCULATE_EXPR');
   END;
   END LOOP;
 END calculate_expr;

/*======================================================================
--  PROCEDURE :
--   convert_uoms
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for calculating
--    the mass uom qty and vol uom qty.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    load_lab_arrays(X_tech_table, X_calc_table);
--
--
--===================================================================== */
PROCEDURE convert_uoms(p_lab_type      IN  VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2) IS
  X_mass_ind	NUMBER := 0;
  X_vol_ind       NUMBER := 0;
  X_conv_qty      NUMBER := 0;
  X_item_no       VARCHAR2(32);
  X_mass_type     VARCHAR2(4);
  X_mass_um       VARCHAR2(4);
  X_vol_type      VARCHAR2(4);
  X_vol_um        VARCHAR2(4);
  NO_UOM_CONV	EXCEPTION;
  BAD_SYS_UOM	EXCEPTION;
  CURSOR Cur_get_um(V_um_type VARCHAR2) IS
    SELECT std_um
    FROM   sy_uoms_typ
    WHERE  um_type = V_um_type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1..tp_master_tbl.count LOOP
    IF (tp_master_tbl(i).data_type IN (5,9)) THEN
      X_mass_ind := 1;
    ELSIF (tp_master_tbl(i).data_type IN (6,7)) THEN
      X_vol_ind := 1;
    END IF;
  END LOOP;
  IF (X_mass_ind = 1) THEN
    X_mass_type := FND_PROFILE.VALUE('LM$UOM_MASS_TYPE');
    OPEN Cur_get_um(X_mass_type);
    FETCH Cur_get_um INTO X_mass_um;
    IF (Cur_get_um%NOTFOUND) THEN
      CLOSE Cur_get_um;
      RAISE BAD_SYS_UOM;
    END IF;
    CLOSE Cur_get_um;
  END IF;
  IF (X_vol_ind = 1) THEN
    X_vol_type := FND_PROFILE.VALUE('LM$UOM_VOLUME_TYPE');
    OPEN Cur_get_um(X_vol_type);
    FETCH Cur_get_um INTO X_vol_um;
    IF (Cur_get_um%NOTFOUND) THEN
      CLOSE Cur_get_um;
      RAISE BAD_SYS_UOM;
    END IF;
    CLOSE Cur_get_um;
  END IF;
  FOR i IN 1..item_master_tbl.count LOOP
    IF (item_master_tbl(i).item_primary_uom <> item_master_tbl(i).uom) THEN
      X_conv_qty := gmicuom.uom_conversion(item_master_tbl(i).item_id, item_master_tbl(i).formula_id,
                                           item_master_tbl(i).quantity, item_master_tbl(i).uom,
                                           item_master_tbl(i).item_primary_uom, 0, p_lab_type);
      IF (X_conv_qty < 0) THEN
        X_item_no := item_master_tbl(i).item_no;
        RAISE NO_UOM_CONV;
      END IF;
      item_master_tbl(i).primary_uom_qty := X_conv_qty;
    ELSE
      item_master_tbl(i).primary_uom_qty := item_master_tbl(i).quantity;
    END IF;
    X_conv_qty := 0;
    IF (X_mass_ind = 1) THEN
      IF (item_master_tbl(i).uom <> X_mass_um) THEN
        X_conv_qty := gmicuom.uom_conversion(item_master_tbl(i).item_id, item_master_tbl(i).formula_id,
                                             item_master_tbl(i).quantity, item_master_tbl(i).uom,
                                             X_mass_um, 0, p_lab_type);
        IF (X_conv_qty < 0) THEN
          X_item_no := item_master_tbl(i).item_no;
          RAISE NO_UOM_CONV;
        END IF;
        item_master_tbl(i).mass_uom_qty := X_conv_qty;
      ELSE
        item_master_tbl(i).mass_uom_qty := item_master_tbl(i).quantity;
      END IF;
    END IF;
    X_conv_qty := 0;
    IF (X_vol_ind = 1) THEN
      IF (item_master_tbl(i).uom <> X_vol_um) THEN
        X_conv_qty := gmicuom.uom_conversion(item_master_tbl(i).item_id, item_master_tbl(i).formula_id,
                                             item_master_tbl(i).quantity, item_master_tbl(i).uom,
                                             X_vol_um, 0, p_lab_type);
        IF (X_conv_qty < 0) THEN
          X_item_no := item_master_tbl(i).item_no;
          RAISE NO_UOM_CONV;
        END IF;
        item_master_tbl(i).vol_uom_qty := X_conv_qty;
      ELSE
        item_master_tbl(i).vol_uom_qty := item_master_tbl(i).quantity;
      END IF;
    END IF;
  END LOOP;
EXCEPTION
  WHEN NO_UOM_CONV THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_UOMCV');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
    FND_MSG_PUB.ADD;
  WHEN BAD_SYS_UOM THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_SYSTEM_UOMS');
    FND_MSG_PUB.ADD;
END convert_uoms;

/*======================================================================
--  PROCEDURE :
--   get_qc_results
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for retrieving
--    the qc results.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    get_qc_results;
--
--  HISTORY
--    27-Nov-2001 M. Grosser - Removed lot_id,whse_code and location IS NULL
--                             from where clause of cursor Cur_get_qcvalue because
--                             they were preventing the retrieval of any records.
--===================================================================== */
PROCEDURE get_qc_results IS

  CURSOR Cur_get_qcvalue (V_orgn_code VARCHAR2, V_item_id NUMBER, V_assay_code VARCHAR2) IS
    SELECT a.text_result, a.num_result
    FROM   qc_rslt_mst a, gmd_tests b
    WHERE  a.item_id = V_item_id
           AND a.formula_id IS NULL
           AND a.routing_id IS NULL
           AND a.oprn_id IS NULL
           AND a.cust_id IS NULL
           AND a.vendor_id IS NULL
           AND a.batch_id IS NULL
           AND a.final_mark = 1
           AND a.delete_mark = 0
           AND a.orgn_code = V_orgn_code
           AND a.assay_code = V_assay_code
           AND a.orgn_code = b.orgn_code
           AND a.assay_code = b.assay_code
    ORDER BY result_date DESC;
  X_rec  Cur_get_qcvalue%ROWTYPE;
  X_row  NUMBER;
BEGIN
  FOR i IN 1..item_master_tbl.count LOOP
    FOR j IN 1..tp_master_tbl.count LOOP
      IF (tp_master_tbl(j).qc_orgn_code IS NOT NULL AND tp_master_tbl(j).qc_assay_name IS NOT NULL) THEN
        OPEN Cur_get_qcvalue(tp_master_tbl(j).qc_orgn_code, item_master_tbl(i).item_id, tp_master_tbl(j).qc_assay_name);
        FETCH Cur_get_qcvalue INTO X_rec;
        IF (Cur_get_qcvalue%FOUND) THEN
          X_row := attrib_master_tbl.count + 1;
          attrib_master_tbl(X_row).item_id        := item_master_tbl(i).item_id;
          attrib_master_tbl(X_row).line_type      := item_master_tbl(i).line_type;
          attrib_master_tbl(X_row).line_no        := item_master_tbl(i).line_no;
          attrib_master_tbl(X_row).tech_parm_name := tp_master_tbl(j).tech_parm_name;
          attrib_master_tbl(X_row).num_value      := X_rec.num_result;
          attrib_master_tbl(X_row).char_value     := X_rec.text_result;
        END IF;
        CLOSE Cur_get_qcvalue;
      END IF;
    END LOOP;
  END LOOP;
END get_qc_results;

/*======================================================================
--  PROCEDURE :
--   rollup_wt_pct
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for retrieving
--    the rollup weight percent.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    rollup_wt_pct(X_tech_parm_name, X_result);
--
--
--===================================================================== */
PROCEDURE rollup_wt_pct(p_tech_parm_name VARCHAR2, p_result OUT NOCOPY NUMBER) IS
  X_total_ingred_wt 	NUMBER := 0;
  X_total_ingred_pct 	NUMBER := 0;
  X_total_byprod_wt 	NUMBER := 0;
  X_total_byprod_pct 	NUMBER := 0;
  X_total_wt 	      NUMBER := 0;
  X_total_pct 	      NUMBER := 0;
BEGIN
  FOR i IN 1..item_master_tbl.count LOOP
    FOR j IN 1..attrib_master_tbl.count LOOP
      IF ((item_master_tbl(i).item_id = attrib_master_tbl(j).item_id) AND
          (item_master_tbl(i).line_type = attrib_master_tbl(j).line_type) AND
          (item_master_tbl(i).line_no = attrib_master_tbl(j).line_no) AND
          (attrib_master_tbl(j).tech_parm_name = p_tech_parm_name)) THEN
        IF (item_master_tbl(i).line_type = -1) THEN
          X_total_ingred_wt  := NVL(item_master_tbl(i).mass_uom_qty,0) + X_total_ingred_wt;
          X_total_ingred_pct := NVL(attrib_master_tbl(j).num_value,0) * NVL(item_master_tbl(i).mass_uom_qty,0) + X_total_ingred_pct;
        ELSIF (item_master_tbl(i).line_type = 2) THEN
          X_total_byprod_wt  := NVL(item_master_tbl(i).mass_uom_qty,0) + X_total_byprod_wt;
          X_total_byprod_pct := NVL(attrib_master_tbl(j).num_value,0) * NVL(item_master_tbl(i).mass_uom_qty,0) + X_total_byprod_pct;
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  X_total_pct := X_total_ingred_pct - X_total_byprod_pct;
  X_total_wt  := X_total_ingred_wt - X_total_byprod_wt;
  IF (X_total_wt <> 0) THEN
    p_result := X_total_pct / X_total_wt;
  ELSE
    p_result := 0;
  END IF;
END rollup_wt_pct;

/*======================================================================
--  PROCEDURE :
--   rollup_vol_pct_and_spec_gr
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for retrieving
--    the rollup volume percent and specific gravity.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    rollup_vol_pct_and_spec_gr(X_tech_parm_name, X_data_type, X_result);
--
--
--===================================================================== */
PROCEDURE rollup_vol_pct_and_spec_gr(p_tech_parm_name VARCHAR2, p_data_type NUMBER, p_result OUT NOCOPY NUMBER) IS
  X_total_ingred_vol 	NUMBER := 0;
  X_total_ingred_pct 	NUMBER := 0;
  X_total_ingred_spgr 	NUMBER := 0;
  X_total_byprod_vol 	NUMBER := 0;
  X_total_byprod_pct 	NUMBER := 0;
  X_total_byprod_spgr 	NUMBER := 0;
  X_total_vol 	      NUMBER := 0;
  X_total_pct 	      NUMBER := 0;
  X_total_spgr 	      NUMBER := 0;
BEGIN
  FOR i IN 1..item_master_tbl.count LOOP
    FOR j IN 1..attrib_master_tbl.count LOOP
      IF ((item_master_tbl(i).item_id = attrib_master_tbl(j).item_id) AND
          (item_master_tbl(i).line_type = attrib_master_tbl(j).line_type) AND
          (item_master_tbl(i).line_no = attrib_master_tbl(j).line_no) AND
          (attrib_master_tbl(j).tech_parm_name = p_tech_parm_name)) THEN
        IF (item_master_tbl(i).line_type = -1) THEN
          X_total_ingred_vol  := X_total_ingred_vol + NVL(item_master_tbl(i).vol_uom_qty,0);
          X_total_ingred_pct  := X_total_ingred_pct + (NVL(item_master_tbl(i).vol_uom_qty,0) * NVL(attrib_master_tbl(j).num_value,0));
          X_total_ingred_spgr := X_total_ingred_spgr + (NVL(item_master_tbl(i).vol_uom_qty,0) * NVL(attrib_master_tbl(j).num_value,0));
        ELSIF (item_master_tbl(i).line_type = -1) THEN
          X_total_byprod_vol  := X_total_byprod_vol + NVL(item_master_tbl(i).vol_uom_qty,0);
          X_total_byprod_pct  := X_total_byprod_pct + (NVL(item_master_tbl(i).vol_uom_qty,0) * NVL(attrib_master_tbl(j).num_value,0));
          X_total_byprod_spgr := X_total_byprod_spgr + (NVL(item_master_tbl(i).vol_uom_qty,0) * NVL(attrib_master_tbl(j).num_value,0));
        END IF;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
  X_total_vol := X_total_ingred_vol - X_total_byprod_vol;
  IF (X_total_vol <> 0) THEN
    IF (p_data_type = 6) THEN
      X_total_pct := X_total_ingred_pct - X_total_byprod_pct;
      IF (X_total_pct <= 0) THEN
        p_result := 0;
      ELSE
        p_result := X_total_pct / X_total_vol;
      END IF;
    ELSE
      X_total_spgr := X_total_ingred_spgr - X_total_byprod_spgr;
      IF (X_total_spgr <= 0) THEN
        p_result := 0;
      ELSE
        p_result := X_total_spgr / X_total_vol;
      END IF;
    END IF;
  ELSE
    p_result := 0;
  END IF;
END rollup_vol_pct_and_spec_gr;

/*======================================================================
--  PROCEDURE :
--   rollup_cost_and_units
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for retrieving
--    the rollup cost.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    rollup_cost_and_units(X_tech_parm_name, X_tp_uom,
--                          X_lab_type, X_result, X_return_status);
--
--
--===================================================================== */
PROCEDURE rollup_cost_and_units(p_tech_parm_name VARCHAR2, p_prod_uom VARCHAR2,
                                p_lab_type VARCHAR2, p_result OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
  X_total_ingred_rollup NUMBER := 0;
  X_total_byprod_rollup NUMBER := 0;
  X_conv_qty            NUMBER := 0;
  X_item_no            VARCHAR2(32);
  NO_UOM_CONV	     EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1..item_master_tbl.count LOOP
    FOR j IN 1..attrib_master_tbl.count LOOP
      IF ((item_master_tbl(i).item_id = attrib_master_tbl(j).item_id) AND
          (item_master_tbl(i).line_type = attrib_master_tbl(j).line_type) AND
          (item_master_tbl(i).line_no = attrib_master_tbl(j).line_no) AND
          (attrib_master_tbl(j).tech_parm_name = p_tech_parm_name)) THEN
        IF (item_master_tbl(i).item_primary_uom <> p_prod_uom) THEN
          X_conv_qty := gmicuom.uom_conversion(item_master_tbl(i).item_id, item_master_tbl(i).formula_id,
                                               item_master_tbl(i).primary_uom_qty, item_master_tbl(i).item_primary_uom,
                                               p_prod_uom, 0, p_lab_type);
          IF (X_conv_qty < 0) THEN
            X_item_no := item_master_tbl(i).item_no;
            RAISE NO_UOM_CONV;
          END IF;
        ELSE
          X_conv_qty := item_master_tbl(i).primary_uom_qty;
        END IF;
        IF (item_master_tbl(i).line_type = -1) THEN
          X_total_ingred_rollup := X_total_ingred_rollup + (NVL(X_conv_qty,0) * NVL(attrib_master_tbl(j).num_value,0));
        ELSIF (item_master_tbl(i).line_type = 2) THEN
          X_total_byprod_rollup := X_total_byprod_rollup + (NVL(X_conv_qty,0) * NVL(attrib_master_tbl(j).num_value,0));
        END IF;
      END IF;
    END LOOP;
  END LOOP;
  p_result := X_total_ingred_rollup - X_total_byprod_rollup;
EXCEPTION
  WHEN NO_UOM_CONV THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_UOMCV');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
    FND_MSG_PUB.ADD;
END rollup_cost_and_units;

/*======================================================================
--  PROCEDURE :
--   rollup_equiv_wt
--
--  DESCRIPTION:
--    This PL/SQL procedure is responsible for retrieving
--    the rollup equivalent weight.
--
--  REQUIREMENTS
--
--  SYNOPSIS:
--    rollup_equiv_wt(X_tech_parm_name, X_prod_uom, X_lab_type, X_result);
--
--
--===================================================================== */
PROCEDURE rollup_equiv_wt(p_tech_parm_name VARCHAR2, p_prod_uom VARCHAR2,
                          p_lab_type VARCHAR2, p_result OUT NOCOPY NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
  X_eq_wt_qty          NUMBER := 0;
  X_total_ingred_eqvts NUMBER := 0;
  X_total_ingred_mass  NUMBER := 0;
  X_total_byprod_eqvts NUMBER := 0;
  X_total_byprod_mass  NUMBER := 0;
  X_total_eqvts        NUMBER := 0;
  X_total_mass         NUMBER := 0;
  X_item_no            VARCHAR2(32);
  NO_UOM_CONV	     EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR i IN 1..item_master_tbl.count LOOP
    FOR j IN 1..attrib_master_tbl.count LOOP
      IF ((item_master_tbl(i).item_id = attrib_master_tbl(j).item_id) AND
          (item_master_tbl(i).line_type = attrib_master_tbl(j).line_type) AND
          (item_master_tbl(i).line_no = attrib_master_tbl(j).line_no) AND
          (attrib_master_tbl(j).tech_parm_name = p_tech_parm_name)) THEN
        IF (item_master_tbl(i).line_type <> 1) THEN
          X_eq_wt_qty := item_master_tbl(i).quantity;
          IF (item_master_tbl(i).uom <> p_prod_uom) THEN
            X_eq_wt_qty := gmicuom.uom_conversion(item_master_tbl(i).item_id, item_master_tbl(i).formula_id,
                                                  item_master_tbl(i).quantity, item_master_tbl(i).uom,
                                                  p_prod_uom, 0, p_lab_type);
            IF (X_eq_wt_qty < 0) THEN
              X_item_no := item_master_tbl(i).item_no;
              RAISE NO_UOM_CONV;
            END IF;
          END IF;
          IF (item_master_tbl(i).line_type = -1) THEN
            IF (NVL(attrib_master_tbl(j).num_value,0) <> 0) THEN
              X_total_ingred_eqvts := X_total_ingred_eqvts + (X_eq_wt_qty / attrib_master_tbl(j).num_value);
            END IF;
            X_total_ingred_mass := X_total_ingred_mass + X_eq_wt_qty;
          ELSIF (item_master_tbl(i).line_type = 2) THEN
            IF (NVL(attrib_master_tbl(j).num_value,0) <> 0) THEN
              X_total_byprod_eqvts := X_total_byprod_eqvts + (X_eq_wt_qty / attrib_master_tbl(j).num_value);
            END IF;
            X_total_byprod_mass := X_total_byprod_mass + X_eq_wt_qty;
          END IF;
        END IF;
      END IF;
    END LOOP;
  END LOOP;
  X_total_mass  := X_total_ingred_mass - X_total_byprod_mass;
  X_total_eqvts := X_total_ingred_eqvts - X_total_byprod_eqvts;
  IF (X_total_eqvts <> 0) THEN
    p_result := X_total_mass / X_total_eqvts;
  ELSE
    p_result := 0;
  END IF;
EXCEPTION
  WHEN NO_UOM_CONV THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_UOMCV');
    FND_MESSAGE.SET_TOKEN('ITEM_NO', X_item_no);
    FND_MSG_PUB.ADD;
END rollup_equiv_wt;


/*======================================================================
--  FUNCTION :
--    check_for_tech_data
--
--  DESCRIPTION:
--    This PL/SQL function is used to determine if there is any technical data
--    entered for this lab_type/item combination.  It will also check for results
--    for any technical parameter that is defined as a qc assay.
--
--  SYNOPSIS:
--    check_for_tech_data(p_lab_type VARCHAR2, pitem_id NUMBER, pformula_id NUMBER) RETURN NUMBER;
--
--  CALLED FROM:
--    GMDFRMED.fmb, GMDFMLED.fmb, GMDFRMLN.fmb
--
--  HISTORY
--    27-Nov-2001  M. Grosser  BUG 1915337 - Created procedure
--===================================================================== */
FUNCTION check_for_tech_data(plab_type VARCHAR2,
                             pitem_id NUMBER,
                             pformula_id NUMBER) RETURN NUMBER IS

  x_value NUMBER;
  x_lab_type VARCHAR2(4);

  CURSOR cur_lab_type IS
    SELECT 1
      FROM sy_orgn_mst
      WHERE  orgn_code = plab_type
             AND plant_ind = 2 ;

  CURSOR cur_check_item_data IS
    SELECT 1
      FROM lm_item_dat
      WHERE  orgn_code = x_lab_type
             AND lot_id = 0
             AND delete_mark = 0
             AND (NVL(formula_id,0) = NVL(pformula_id,0)
              OR formula_id = 0)
             AND item_id = pitem_id ;

  CURSOR cur_get_qcvalue IS
    SELECT 1
    FROM   qc_rslt_mst q, lm_prlt_asc s, lm_tech_hdr h
    WHERE  q.item_id = pitem_id
           AND q.formula_id IS NULL
           AND q.routing_id IS NULL
           AND q.oprn_id IS NULL
           AND q.cust_id IS NULL
           AND q.vendor_id IS NULL
           AND q.batch_id IS NULL
           AND q.final_mark = 1
           AND q.delete_mark = 0
           AND q.qcassy_typ_id = h.qcassy_typ_id
           AND s.orgn_code = x_lab_type
           AND h.tech_parm_name = s.tech_parm_name
           AND h.qcassy_typ_id IS NOT NULL
           AND q.orgn_code = NVL(plab_type,x_lab_type)
    ORDER BY result_date DESC;

  NO_LAB_TYPE    EXCEPTION;
  NO_ATTRIB_DATA EXCEPTION;

BEGIN
  /* If a value has been sent in for lab type, confirm it is a valid lab type */
  IF (plab_type IS NOT NULL) THEN
    OPEN cur_lab_type;
    FETCH cur_lab_type into x_value;
    IF cur_lab_type%FOUND THEN
      x_lab_type := plab_type;
    END IF;
    CLOSE cur_lab_type;
  END IF;

  /* If no value was been sent in or it was not a valid lab type, get the default lab type */
  IF (x_lab_type IS NULL) THEN
    IF FND_PROFILE.DEFINED('GEMMS_DEFAULT_LAB_TYPE') THEN
      x_lab_type :=  FND_PROFILE.VALUE('GEMMS_DEFAULT_LAB_TYPE');
    ELSE
      /* No default lab type, raise an error */
      RAISE NO_LAB_TYPE;
    END IF;
  END IF;

  /*  Check to see if there is any item tech data in lm_item_dat  */
  OPEN cur_check_item_data;
  FETCH cur_check_item_data into x_value;

  /* If there is no data in lm_item_dat, see if there are qc results for this item */
  IF cur_check_item_data%NOTFOUND THEN
    OPEN cur_get_qcvalue;
    FETCH cur_get_qcvalue into x_value;

    /* If there are no qc results either, return that there is no item tech data */
    IF cur_get_qcvalue%NOTFOUND THEN
      RAISE NO_ATTRIB_DATA;
    END IF;
    CLOSE cur_get_qcvalue;
  END IF;
  CLOSE cur_check_item_data;

  /* If you get here, you have found some data */
  RETURN 1;


EXCEPTION
  WHEN NO_LAB_TYPE THEN
     FND_MESSAGE.SET_NAME('GMD', 'LM_BAD_LAB_TYPE_PARM');
     FND_MSG_PUB.ADD;
     RETURN -1;

  WHEN NO_ATTRIB_DATA THEN
     FND_MESSAGE.SET_NAME('GMD', 'LM_NO_ATTRIB_DATA');
     FND_MSG_PUB.ADD;
     RETURN 0;

  WHEN OTHERS THEN
     RETURN -1;

END check_for_tech_data;


END gmd_tech_params;

/
