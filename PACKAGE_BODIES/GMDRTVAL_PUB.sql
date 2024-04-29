--------------------------------------------------------
--  DDL for Package Body GMDRTVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDRTVAL_PUB" AS
/* $Header: GMDPRTVB.pls 120.2.12010000.2 2008/11/12 18:49:15 rnalla ship $ */

--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

/* ==================================================================== */
/*  FUNCTION: */
/*    get_theoretical_process_loss */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    retrieving the process loss for the routing class. */
/* */
/*  REQUIREMENTS */
/*    routing_class should be a non null value. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.get_theoretical_process_loss(prouting_class, pquantity); */
/* */
/*  RETURNS: */
/*      Theoretical Process loss value. */
/* ==================================================================== */
FUNCTION get_theoretical_process_loss(prouting_class IN VARCHAR2, pquantity IN NUMBER) RETURN NUMBER IS
  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_get_process_loss IS
     SELECT process_loss
     FROM   gmd_process_loss
     WHERE  routing_class = prouting_class
            AND NVL(max_quantity, 2147484647) >= NVL(pquantity,2147484647)
     ORDER BY max_quantity;

  l_process_loss NUMBER;
BEGIN
  IF (prouting_class IS NULL) THEN
     l_process_loss := 0;
  ELSE
    OPEN Cur_get_process_loss;
    FETCH Cur_get_process_loss INTO l_process_loss;
    IF (Cur_get_process_loss%NOTFOUND) THEN
       l_process_loss := NULL;
    END IF;
    CLOSE Cur_get_process_loss;
  END IF;
  RETURN l_process_loss;
END get_theoretical_process_loss;

/* ==================================================================== */
/*  FUNCTION: */
/*    check_duplicate_routing */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    checking the duplication of routings. */
/* */
/*  REQUIREMENTS */
/*    routing_no and routing_vers should be non null values. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_duplicate_routing(prouting_no, prouting_vers, */
/*                                                  pcalledby_form); */
/* */
/*  RETURNS: */
/*       0  Success */
/*      -1  Some required fields for the procedure are missing. */
/*      -50 GMD_ROUTING_EXISTS  Duplicate Routing. */
/* ==================================================================== */
FUNCTION check_duplicate_routing(prouting_no IN VARCHAR2,
                                 prouting_vers IN NUMBER,
                                 pcalledby_form IN VARCHAR2) RETURN NUMBER IS
  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_check_dup IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   fm_rout_hdr
                 WHERE  routing_no = prouting_no
                        AND routing_vers = prouting_vers);
  /* Local variables. */
  /* ================ */
  l_ret                   NUMBER;
  duplicate_routing EXCEPTION;

  /* ================================================ */
BEGIN
  OPEN Cur_check_dup;
  FETCH Cur_check_dup INTO l_ret;
  IF (Cur_check_dup%FOUND) THEN
    CLOSE Cur_check_dup;
    RAISE duplicate_routing;
  END IF;
  CLOSE Cur_check_dup;
  RETURN 0;
EXCEPTION
  WHEN duplicate_routing THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_DUP_ROUTING');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_ROUTING_EXISTS;
    END IF;
  END check_duplicate_routing;

/* ==================================================================== */
/*  FUNCTION: */
/*    check_routing_class */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    checking the validity of the routing class. */
/* */
/*  REQUIREMENTS */
/*    routing_class should be non null value. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_routing_class(prouting_class, pcalledby_form); */
/* */
/*  RETURNS: */
/*       0  Success */
/*      -1  Some required fields for the procedure are missing. */
/*      -51 GMD_INV_ROUTING_CLASS  Routing class is not valid. */
/* ==================================================================== */
FUNCTION check_routing_class(prouting_class IN VARCHAR2,
                             pcalledby_form IN VARCHAR2) RETURN NUMBER IS
  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_routing_class IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   fm_rout_cls
                 WHERE  routing_class = prouting_class
                        AND delete_mark = 0);
  /* Local variables. */
  /* ================ */
  l_ret                    NUMBER;
  inv_routing_class  EXCEPTION;
BEGIN
  OPEN Cur_routing_class;
  FETCH Cur_routing_class INTO l_ret;
  IF (Cur_routing_class%NOTFOUND) THEN
    CLOSE Cur_routing_class;
    RAISE inv_routing_class;
  END IF;
  CLOSE Cur_routing_class;
  RETURN 0;
EXCEPTION
  WHEN inv_routing_class THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD', 'FM_INVROUTCLASS');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_INV_ROUTING_CLASS;
    END IF;
END check_routing_class;

/* ==================================================================== */
/*  FUNCTION: */
/*    check_routingstep_no */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    checking the duplication of routing step numbers. */
/* */
/*  REQUIREMENTS */
/*    routing_id and routingstep_no should be non null values. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_routingstep_no(proutingstep_no,  */
/*                                               prouting_id,  */
/*                                               pcalledby_form); */
/* */
/*  RETURNS: */
/*       0  Success */
/*      -1  Some required fields for the procedure are missing. */
/*      -52 GMD_DUP_ROUTINGSTEP_NO  Duplicate routing step number. */
/* ==================================================================== */
FUNCTION check_routingstep_no(proutingstep_no IN NUMBER, prouting_id IN NUMBER,
                              pcalledby_form IN VARCHAR2) RETURN NUMBER IS
  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_dup_routingstep IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   fm_rout_dtl
                 WHERE  routing_id = prouting_id
                        AND routingstep_no = proutingstep_no);
  /* Local variables. */
  /* ================ */
  l_ret                     NUMBER;
  dup_routingstep_no  EXCEPTION;
BEGIN
  OPEN Cur_dup_routingstep;
  FETCH Cur_dup_routingstep INTO l_ret;
  IF (Cur_dup_routingstep%FOUND) THEN
    CLOSE Cur_dup_routingstep;
    RAISE dup_routingstep_no;
  END IF;
  CLOSE Cur_dup_routingstep;
  RETURN 0;
EXCEPTION
  WHEN dup_routingstep_no THEN
    IF (pcalledby_form = 'T') THEN
      FND_MESSAGE.SET_NAME('GMD', 'FM_RTSTEPERR');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      RETURN GMD_DUP_ROUTINGSTEP_NO;
    END IF;
END check_routingstep_no;


/*- =========================================================== */
/*  Procedure Check_Routing in GMDRTVAL_PUB package             */
/*                                                              */
/*  Decription                                                  */
/*      Check if the routing header exists in the database.               */
/*      If all 3 parameters are sent in, validates no/vers rather than id */
/*  HISTORY                                                           */
/*  L.R.Jackson  19Apr2001  Fixed references to routing_id_cur        */
/*    Bug 1745549    (There were 2 typo's).  Added exception section  */
/*                   Removed x_return_status variable (unnecessary).  */
/*  ==========================================================        */
PROCEDURE check_routing(pRouting_no     IN      VARCHAR2,
                        pRouting_vers   IN      NUMBER,
                        xRouting_id     IN OUT NOCOPY   NUMBER,
                        xReturn_status  OUT NOCOPY      VARCHAR2) IS
CURSOR Routing_No_Cur IS
        select routing_id
        from fm_rout_hdr
        where routing_no = pRouting_no AND
              routing_vers = pRouting_vers;

Cursor Routing_id_cur IS
        select routing_id
        from fm_rout_hdr
        where routing_id = xRouting_id;

l_return_val NUMBER;

BEGIN
  xReturn_status := 'S';
  IF (xRouting_id IS NULL) THEN
     OPEN Routing_No_Cur;
     Fetch Routing_No_Cur into l_return_val;
     IF Routing_No_Cur%NOTFOUND then
        xReturn_status := 'E';
     END IF;
     CLOSE Routing_No_Cur;
  ELSE
     OPEN Routing_Id_Cur;
     Fetch Routing_Id_Cur into l_return_val;
     IF Routing_ID_Cur%NOTFOUND then
        xReturn_status := 'E';
     END IF;
     CLOSE Routing_Id_Cur;

  END IF;
  xrouting_id := l_return_val;

EXCEPTION
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     xReturn_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_routing;



/* ==================================================================== */
/*  FUNCTION: */
/*    check_oprn */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    checking the validity of the operation. */
/* */
/*  REQUIREMENTS */
/*    oprn_no and oprn_vers should be non null values. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_oprn(poprn_no, poprn_vers,  */
/*                                     pcalledby_form); */
/* */
/*  RETURNS: */
/*       0  Success */
/*      -1  Some required fields for the procedure are missing. */
/*      -53 GMD_INV_OPRN  Invalid operation. */
/* ==================================================================== */
FUNCTION check_oprn(poprn_no IN VARCHAR2, poprn_vers IN NUMBER,
                    prouting_start_date IN DATE,
                    pcalledby_form IN VARCHAR2,
                    poprn_id IN NUMBER,
                    prouting_end_date IN DATE) RETURN NUMBER IS
  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_get_oprn IS
    SELECT oprn_no, oprn_vers, effective_start_date, effective_end_date
    FROM   gmd_operations_b
    WHERE  ((poprn_id IS NOT NULL AND oprn_id = poprn_id)
            OR (poprn_id IS NULL AND (oprn_no = poprn_no
                                      AND oprn_vers = poprn_vers)
                )
            )
    AND    delete_mark = 0;

  /* Local variables. */
  /* ================ */
  l_rec     Cur_get_oprn%ROWTYPE;
  l_ret     NUMBER;
  inv_oprn  EXCEPTION;
BEGIN
  OPEN Cur_get_oprn;
  FETCH Cur_get_oprn INTO l_rec;
  IF (Cur_get_oprn%NOTFOUND) THEN
    CLOSE Cur_get_oprn;
    RAISE inv_oprn;
  END IF;
  CLOSE Cur_get_oprn;

  IF (l_rec.effective_start_date > prouting_start_date) THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_FROM_DATE');
    FND_MESSAGE.SET_TOKEN('OPRN_NO', l_rec.oprn_no);
    FND_MESSAGE.SET_TOKEN('VERSION_NO', l_rec.oprn_vers);
    FND_MESSAGE.SET_TOKEN('OPRN_DATE', l_rec.effective_start_date);
    IF pcalledby_form = 'T' THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      FND_MSG_PUB.ADD;
      RETURN GMD_INV_OPRN;
    END IF;
  END IF;

  IF (l_rec.effective_end_date IS NOT NULL) AND
     (l_rec.effective_end_date < NVL(prouting_end_date, l_rec.effective_end_date + 1)) THEN
    FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_TO_DATE');
    FND_MESSAGE.SET_TOKEN('OPRN_NO', l_rec.oprn_no);
    FND_MESSAGE.SET_TOKEN('VERSION_NO', l_rec.oprn_vers);
    FND_MESSAGE.SET_TOKEN('OPRN_DATE', l_rec.effective_end_date);
    IF pcalledby_form = 'T' THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      FND_MSG_PUB.ADD;
      RETURN GMD_INV_OPRN;
    END IF;
  END IF;

  RETURN 0;
EXCEPTION
  WHEN inv_oprn THEN
    FND_MESSAGE.SET_NAME('GMD', 'QC_INVOPRN');
    IF (pcalledby_form = 'T') THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      FND_MSG_PUB.ADD;
      RETURN GMD_INV_OPRN;
    END IF;
END check_oprn;

/*====================================================================== */
/*  FUNCTION: */
/*   circular_dependencies_exist */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    checking the circular references in the routing step dependencies */
/* */
/*  REQUIREMENTS */
/*    parent_key routing_id or batch_id should be non null values. */
/*    called_from_batch could be null if checking at the routing level. */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.circular_dependencies_exist(prouting_id,  */
/*                                                      0); */
/* */
/*  RETURNS: */
/*       TRUE  Dependencies Exist */
/*       FALSE No Circular dependencies exist */
/*=====================================================================  */

FUNCTION circular_dependencies_exist (pparent_key IN NUMBER,
                                      pcalled_from_batch IN NUMBER)
         RETURN BOOLEAN IS

  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_get_routing_steps IS
    SELECT distinct routingstep_no
    FROM   fm_rout_dep
    WHERE  routing_id = pparent_key;
  X_rout_step_rec       Cur_get_routing_steps%ROWTYPE;

  CURSOR Cur_get_batch_steps IS
    SELECT distinct batchstep_id
    FROM   gme_batch_step_dependencies
    WHERE  batch_id = pparent_key;
  X_batch_step_rec      Cur_get_batch_steps%ROWTYPE;

  CURSOR Cur_check_rout_step_depen (V_routingstep_no NUMBER) IS
  SELECT max(routingstep_no)
  FROM (SELECT * FROM FM_ROUT_DEP  WHERE routing_id = pparent_key)
  START WITH routingstep_no = V_routingstep_no
  CONNECT BY (PRIOR dep_routingstep_no = routingstep_no)
             AND (PRIOR routing_id = routing_id);

  CURSOR Cur_check_batch_step_depen (V_batchstep_id NUMBER) IS
  SELECT max(batchstep_id)
  FROM   gme_batch_step_dependencies
  START WITH batch_id = pparent_key AND
             batchstep_id = V_batchstep_id
  CONNECT BY (PRIOR dep_step_id = batchstep_id)
             AND (PRIOR batch_id = batch_id);

  /* Local variables. */
  /* ================ */
  l_step        NUMBER;

  circular_reference    EXCEPTION;
  PRAGMA EXCEPTION_INIT(circular_reference, -01436);
BEGIN
  IF pcalled_from_batch = 0 THEN
    FOR X_rout_step_rec IN Cur_get_routing_steps
    LOOP
      OPEN Cur_check_rout_step_depen (X_rout_step_rec.routingstep_no);
      FETCH Cur_check_rout_step_depen INTO l_step;
      CLOSE Cur_check_rout_step_depen;
    END LOOP;
  ELSE
    FOR X_batch_step_rec IN Cur_get_batch_steps
    LOOP
      OPEN Cur_check_batch_step_depen (X_batch_step_rec.batchstep_id);
      FETCH Cur_check_batch_step_depen INTO l_step;
      CLOSE Cur_check_batch_step_depen;
    END LOOP;
  END IF;
  RETURN FALSE;
EXCEPTION
  WHEN circular_reference THEN
    RETURN TRUE;
END circular_dependencies_exist;

/*====================================================================== */
/*  PROCEDURE : */
/*   generate_step_dependencies */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL procedure  is responsible for generating step  */
/*    dependencies in sequential manner. */
/* */
/*  REQUIREMENTS */
/*    prouting_id  non null value. */
/*  SYNOPSIS: */
/*    gmdrtval_pub.generate_step_dependencies(prouting_id); */
/* */
/* */
/*=====================================================================  */

PROCEDURE generate_step_dependencies
  (  prouting_id        IN NUMBER,
     x_return_status   OUT NOCOPY  VARCHAR2) IS

  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_get_routing_steps IS
    SELECT routingstep_no
    FROM   fm_rout_dtl
    WHERE  routing_id = prouting_id
    ORDER BY routingstep_no desc;

  X_rout_step_rec       Cur_get_routing_steps%ROWTYPE;

  CURSOR Cur_get_oprn_uom (V_step_no NUMBER) IS
    SELECT process_qty_um
    FROM   gmd_operations o, fm_rout_dtl d
    WHERE  d.routing_id = prouting_id
    AND    d.routingstep_no = V_step_no
    AND    d.oprn_id = o.oprn_id;

  X_oprn_uom_rec        Cur_get_oprn_uom%ROWTYPE;

  /* Local variables. */
  /* ================ */
  l_rout_step_no        NUMBER;
  l_user_id             NUMBER;

  /* Record Buffers. */
  /*=================*/
  l_rout_dep    FM_ROUT_DEP%ROWTYPE;
  /* Exceptions. */
  /* ================       */
    missing_details     EXCEPTION;
    insert_failure      EXCEPTION;
BEGIN
  l_user_id := FND_PROFILE.VALUE('USER_ID');
  DELETE FROM fm_rout_dep
  WHERE  routing_id = prouting_id;
  OPEN Cur_get_routing_steps;
  FETCH Cur_get_routing_steps INTO X_rout_step_rec;
  IF Cur_get_routing_steps%FOUND THEN
    WHILE Cur_get_routing_steps%FOUND
    LOOP
      l_rout_step_no := X_rout_step_rec.routingstep_no;
      FETCH Cur_get_routing_steps INTO X_rout_step_rec;
      IF Cur_get_routing_steps%FOUND THEN

        /* Get the transfer uom from the operation associated with
           the dependent step */
        OPEN Cur_get_oprn_uom (X_rout_step_rec.routingstep_no);
        FETCH Cur_get_oprn_uom INTO X_oprn_uom_rec;
        CLOSE Cur_get_oprn_uom;

        l_rout_dep.routingstep_no := l_rout_step_no;
        l_rout_dep.dep_routingstep_no := X_rout_step_rec.routingstep_no;
        l_rout_dep.routing_id := prouting_id;
        l_rout_dep.dep_type := 0;
        l_rout_dep.standard_delay := 0;
        l_rout_dep.minimum_delay := 0;
        l_rout_dep.max_delay := 0;
        l_rout_dep.transfer_qty := 0;
        l_rout_dep.item_um := X_oprn_uom_rec.process_qty_um;
        l_rout_dep.last_updated_by := l_user_id;
        l_rout_dep.created_by := l_user_id;
        l_rout_dep.last_update_date := SYSDATE;
        l_rout_dep.creation_date := SYSDATE;
        l_rout_dep.transfer_pct := 100;

        IF NOT FM_ROUT_DEP_DBL.insert_row (l_rout_dep) THEN
          CLOSE Cur_get_routing_steps;
          RAISE INSERT_FAILURE;
        END IF;
      END IF;
    END LOOP;
  ELSE
    CLOSE Cur_get_routing_steps;
    RAISE missing_details;
  END IF;
  /* Bug 2454861 - Thomas Daniel */
  /* Added the closing of the open cursor */
  CLOSE Cur_get_routing_steps;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN missing_details THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_DETAILS_MISSING');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN INSERT_FAILURE THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END generate_step_dependencies;


/*====================================================================== */
/*  PROCEDURE : */
/*   generate_step_dependencies */
/* */
/*  DESCRIPTION: */
/*    This is a Overloaded PL/SQL procedure  is responsible for generating step  */
/*    dependencies in sequential manner. */
/* */
/*  REQUIREMENTS */
/*    prouting_id  non null value. */
/*    pDep_type   non null value  */
/*  SYNOPSIS: */
/*    gmdrtval_pub.generate_step_dependencies(prouting_id, pDep_type, x_return_status); */
/* */
/* */
/*=====================================================================  */

PROCEDURE generate_step_dependencies
  (  prouting_id        IN NUMBER,
     pDep_Type          IN NUMBER,
     x_return_status   OUT NOCOPY  VARCHAR2) IS

  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_get_routing_steps IS
    SELECT routingstep_no
    FROM   fm_rout_dtl
    WHERE  routing_id = prouting_id
    ORDER BY routingstep_no desc;

  X_rout_step_rec       Cur_get_routing_steps%ROWTYPE;

  CURSOR Cur_get_oprn_uom (V_step_no NUMBER) IS
    SELECT process_qty_um
    FROM   gmd_operations o, fm_rout_dtl d
    WHERE  d.routing_id = prouting_id
    AND    d.routingstep_no = V_step_no
    AND    d.oprn_id = o.oprn_id;

  X_oprn_uom_rec        Cur_get_oprn_uom%ROWTYPE;

  /* Local variables. */
  /* ================ */
  l_rout_step_no        NUMBER;
  l_user_id             NUMBER;

  /* Record Buffers. */
  /*=================*/
  l_rout_dep    FM_ROUT_DEP%ROWTYPE;
  /* Exceptions. */
  /* ================       */
    missing_details     EXCEPTION;
    insert_failure      EXCEPTION;
BEGIN
  l_user_id := FND_PROFILE.VALUE('USER_ID');
  DELETE FROM fm_rout_dep
  WHERE  routing_id = prouting_id;
  OPEN Cur_get_routing_steps;
  FETCH Cur_get_routing_steps INTO X_rout_step_rec;
  IF Cur_get_routing_steps%FOUND THEN
    WHILE Cur_get_routing_steps%FOUND
    LOOP
      l_rout_step_no := X_rout_step_rec.routingstep_no;
      FETCH Cur_get_routing_steps INTO X_rout_step_rec;
      IF Cur_get_routing_steps%FOUND THEN

        /* Get the transfer uom from the operation associated with
           the dependent step */
        OPEN Cur_get_oprn_uom (X_rout_step_rec.routingstep_no);
        FETCH Cur_get_oprn_uom INTO X_oprn_uom_rec;
        CLOSE Cur_get_oprn_uom;

        l_rout_dep.routingstep_no := l_rout_step_no;
        l_rout_dep.dep_routingstep_no := X_rout_step_rec.routingstep_no;
        l_rout_dep.routing_id := prouting_id;
        l_rout_dep.dep_type := pDep_Type;
        l_rout_dep.standard_delay := 0;
        l_rout_dep.minimum_delay := 0;
        l_rout_dep.max_delay := 0;
        l_rout_dep.transfer_qty := 0;
        l_rout_dep.item_um := X_oprn_uom_rec.process_qty_um;
        l_rout_dep.last_updated_by := l_user_id;
        l_rout_dep.created_by := l_user_id;
        l_rout_dep.last_update_date := SYSDATE;
        l_rout_dep.creation_date := SYSDATE;
        l_rout_dep.transfer_pct := 100;

        IF NOT FM_ROUT_DEP_DBL.insert_row (l_rout_dep) THEN
          CLOSE Cur_get_routing_steps;
          RAISE INSERT_FAILURE;
        END IF;
      END IF;
    END LOOP;
  ELSE
    CLOSE Cur_get_routing_steps;
    RAISE missing_details;
  END IF;
  /* Bug 2454861 - Thomas Daniel */
  /* Added the closing of the open cursor */
  CLOSE Cur_get_routing_steps;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN missing_details THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_DETAILS_MISSING');
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN INSERT_FAILURE THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END generate_step_dependencies;


 /* ================================================= */
 /* Chceks for overall in max qty's before  */
 /* updating the max qty values */
 /* ================================================= */
 PROCEDURE  Get_process_loss_max_qtys(  pRouting_class  IN      VARCHAR2,
                                        pFromMaxQty     IN      NUMBER,
                                        pToMaxQty       IN      NUMBER,
                                        max_quantity    OUT NOCOPY      max_qty_tbl ,
                                        x_return_status OUT NOCOPY      VARCHAR2) IS

 l_rows NUMBER  := 1;

 Cursor max_qty_cur(pRouting_class VARCHAR2, pFromMaxQty NUMBER, pToMaxQty NUMBER) IS
        SELECT  max_quantity
        FROM    gmd_process_loss
        WHERE   routing_class = pRouting_class AND
                max_quantity > pFromMaxQty AND
                max_quantity <= pToMaxQty;

 BEGIN

    /* Initialize the return status */
    x_return_status := 'S';

    /* Open the cursor and start fetching each row into the table */
    FOR max_qty_rec IN max_qty_cur(pRouting_class, pFromMaxQty, pToMaxQty) LOOP
       EXIT WHEN max_qty_cur%NOTFOUND;
        max_quantity(l_rows) := max_qty_rec.max_quantity;
        l_rows := l_rows + 1;
    END LOOP;

 EXCEPTION
   WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 END Get_process_loss_max_qtys;

 /* =================================================== */
 /* Checks if there is atleast one operation associated */
 /* for this routing                                    */
 /* =================================================== */
 PROCEDURE Validate_Routing_Details( pRouting_id     IN   NUMBER,
                                    x_msg_count      OUT NOCOPY   NUMBER,
                                    x_msg_stack      OUT NOCOPY   VARCHAR2,
                                    x_return_status  OUT NOCOPY   VARCHAR2)  IS

 l_oprn_count NUMBER := 0;

 CURSOR check_oprn_count IS
   SELECT count(*) FROM gmd_operations_b
   WHERE oprn_id IN (select oprn_id from fm_rout_dtl where routing_id = pRouting_id);

 BEGIN
   x_return_status := 'S';

   OPEN  check_oprn_count;
   FETCH check_oprn_count INTO l_oprn_count;
     IF (check_oprn_count%NOTFOUND) THEN
       x_return_status := 'E';
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_DTL_REQD');
       FND_MSG_PUB.ADD;
     END IF;
   CLOSE check_oprn_count;

   IF (l_oprn_count = 0) THEN
     x_return_status := 'E';
     FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_DTL_REQD');
     FND_MSG_PUB.ADD;
   END IF;

   FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                P_data  => x_msg_stack);
 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                P_data  => x_msg_stack);

 END Validate_Routing_Details;

  /* ==================================================================== */
  /* This procedure verifies that the routing effective dates falls       */
  /* within all recipe validity rules that are using the routing.         */
  /*  Basically, the routing must be valid during the entire life         */
  /*  of the recipes using this routing.                                  */
  /* ==================================================================== */
 PROCEDURE Validate_Routing_VR_Dates( pRouting_id     IN   NUMBER,
                                    x_msg_count      OUT NOCOPY   NUMBER,
                                    x_msg_stack      OUT NOCOPY   VARCHAR2,
                                    x_return_status  OUT NOCOPY   VARCHAR2)  IS

 l_vr_count NUMBER := 0;

 CURSOR check_VR_Rout_dates IS
   select count(*)
   from gmd_recipe_validity_rules v, gmd_recipes_b r, gmd_routings_b rt
   where v.recipe_id = r.recipe_id
   and r.routing_id = rt.routing_id
   and rt.routing_id = pRouting_id
   and rt.effective_start_date < v.start_date
   and (v.end_date IS NULL OR rt.effective_end_date > v.end_date);

 BEGIN
   x_return_status := 'S';

   OPEN  check_VR_Rout_dates;
   FETCH check_VR_Rout_dates INTO l_vr_count;
     IF (check_VR_Rout_dates%FOUND) THEN
       x_return_status := 'E';
       FND_MESSAGE.SET_NAME('GMD', 'GMD_UPD_RECP_VR');
       FND_MSG_PUB.ADD;
     END IF;
   CLOSE check_VR_Rout_dates;

   FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                              P_data  => x_msg_stack);
 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                P_data  => x_msg_stack);

 END Validate_Routing_VR_Dates;

 /* =================================================== */
 /* This procedure updates the start and end dates of
    the validity rules with the given start and end dates.
    This procedure is used when the routing effective
    dates falls outside the validity rules date range.  */
 /* =================================================== */
 PROCEDURE Update_VR_with_Rt_Dates( pRouting_id     IN   NUMBER,
                                    x_msg_count      OUT NOCOPY   NUMBER,
                                    x_msg_stack      OUT NOCOPY   VARCHAR2,
                                    x_return_status  OUT NOCOPY   VARCHAR2)  IS

 l_vr_id NUMBER := 0;

 CURSOR check_VR_Rout_dates IS
   select v.recipe_validity_rule_id vr_id , rt.effective_start_date start_date, rt.effective_end_date end_date
   from gmd_recipe_validity_rules v, gmd_recipes_b r, gmd_routings_b rt
   where v.recipe_id = r.recipe_id
   and r.routing_id = rt.routing_id
   and rt.routing_id = pRouting_id
   and rt.effective_start_date < v.start_date
   and (v.end_date IS NULL OR rt.effective_end_date > v.end_date);

 BEGIN
   x_return_status := 'S';

   FOR update_vr_rec IN check_VR_Rout_dates  LOOP
     UPDATE gmd_recipe_validity_rules
     SET    start_date = update_vr_rec.start_date ,
            end_date   = update_vr_rec.end_date
     WHERE  recipe_validity_rule_id = update_vr_rec.vr_id;
   END LOOP;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.COUNT_AND_GET (P_count => x_msg_count,
                                P_data  => x_msg_stack);

 END Update_VR_with_Rt_Dates;

 /* =================================================== */
 /* This procedure get the routingStep_id when the      */
 /* routingStep_no and routing_id is passed             */
 /* =================================================== */
 PROCEDURE  get_routingstep_info(pRouting_id      IN     gmd_routings.routing_id%TYPE    := NULL
                               ,pxRoutingStep_no  IN OUT NOCOPY  fm_rout_dtl.routingStep_no%TYPE
                               ,pxRoutingStep_id  IN OUT NOCOPY  fm_rout_dtl.routingStep_id%TYPE
                               ,x_return_status   OUT NOCOPY     VARCHAR2 ) IS

  CURSOR get_routingStep_id(vRouting_id      gmd_routings.routing_id%TYPE
                           ,vRoutingStep_no  fm_rout_dtl.routingStep_no%TYPE) IS
    Select routingStep_id
    From   fm_rout_dtl
    Where  routingStep_no = vRoutingStep_no  AND
           routing_id     = vRouting_id;

  CURSOR get_routingStep_no(vRoutingStep_id  fm_rout_dtl.routingStep_id%TYPE) IS
    Select routingStep_no
    From   fm_rout_dtl
    Where  routingStep_id = vRoutingStep_id;

 BEGIN

   x_return_status := 'S';
   IF pxRoutingStep_id IS NULL THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(' Rt step id is null and Rt step no = '||pxRoutingStep_no);
      END IF;
      /* User needs to pass the routing_id and step no */
      OPEN  get_routingStep_id(pRouting_id,pxRoutingStep_no);
      FETCH get_routingStep_id INTO  pxRoutingStep_id;
        IF get_routingStep_id%NOTFOUND THEN
           x_return_status := 'E';
        END IF;
      CLOSE get_routingStep_id;
   ELSE
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(' RT step id is not null = '||pxRoutingStep_id);
      END IF;

      OPEN  get_routingStep_no(pxRoutingStep_id);
      FETCH get_routingStep_no INTO  pxRoutingStep_no;
        IF get_routingStep_no%NOTFOUND THEN
           x_return_status := 'E';
        END IF;
      CLOSE get_routingStep_no;
   END IF;

 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 END get_routingstep_info;


 /* ****************************************************************
 *  Function Check_routing_overide_exists
 *
 *  Check if this routing step is overriden at Recipe level.
 *  Called by Routing detail API.
 *
 *  Returns - True  - if step exists at recipe level.
 *            False - if step does not exists at recipe level
 *
 *
 * *************************************************************** */
 FUNCTION Check_routing_override_exists(p_routingstep_id NUMBER)
             RETURN BOOLEAN IS

    X_temp   NUMBER;
    X_return BOOLEAN := FALSE;
    /* Define cursor */
    CURSOR Cur_check_step(v_routingstep_id NUMBER) IS
      SELECT 1
      FROM   SYS.DUAL
      WHERE  EXISTS (SELECT 1
                     FROM gmd_recipe_routing_steps
                     WHERE routingstep_id = v_routingstep_id);

    CURSOR Cur_check_step2(v_routingstep_id NUMBER) IS
      SELECT 1
        FROM gmd_recipe_step_materials
       WHERE routingstep_id = v_routingstep_id;

 BEGIN
    IF (p_routingstep_id IS NOT NULL) THEN
      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(' In Check_routing_override_exists() with Rt Step id = '||p_RoutingStep_id);
      END IF;

      OPEN Cur_check_step(p_routingstep_id);
      FETCH Cur_check_step INTO X_temp;
      IF (Cur_check_step%FOUND) THEN
        CLOSE Cur_check_step;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_STEP_USED_IN_RECIPE');
        RETURN TRUE;
      END IF;
      CLOSE Cur_check_step;

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(' In Check_routing_override_exists() '
                            ||' after check in Recipe Step level ');
      END IF;

      --    bug 1856832.  Check step/mat in addition to above check of rtg step
      OPEN Cur_check_step2(p_routingstep_id);
      FETCH Cur_check_step2 INTO X_temp;
      IF (Cur_check_step2%FOUND) THEN
        CLOSE Cur_check_step2;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_STEP_USED_IN_RECIPE');
        RETURN TRUE;
      END IF;
      CLOSE Cur_check_step2;

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line(' In Check_routing_override_exists() '
                          ||' after check in Recipe Mat level ');
      END IF;

    END IF;

    RETURN X_return;
 END Check_routing_override_exists;

 /* ==================================================================== */
/*  PROCEDURE: */
/*    check_delete_mark */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL procedure is responsible for  */
/*    checking the validity of the delete_mark. */
/* */
/*  REQUIREMENTS */
/*    delete_mark should be non null value. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_delete_mark(pdelete_mark, pcalledby_form); */
/* ==================================================================== */

PROCEDURE check_delete_mark(pdelete_mark IN NUMBER,
                            x_return_status OUT NOCOPY  VARCHAR2) IS
  inv_delete_mark          EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF (pdelete_mark NOT IN (0,1)) THEN
    RAISE inv_delete_mark;
  END IF;
EXCEPTION
  WHEN inv_delete_mark THEN
    x_return_status := 'E';
    FND_MESSAGE.SET_NAME('GMA', 'SY_BADDELETEMARK');
    FND_MSG_PUB.ADD;
END check_delete_mark;

/* ==================================================================== */
/*  PROCEDURE: */
/*    check_ownerorgn_code */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL procedure is responsible for  */
/*    checking the validity of the ownerorgn_code. */
/* */
/*  REQUIREMENTS */
/*    validate ownerorgn_code. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_ownerorgn_code(pownerorgn_code, pcalledby_form); */
/* ==================================================================== */

PROCEDURE check_ownerorgn_code(powner_id IN NUMBER,powner_orgn IN VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2) IS

  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_ownerorgn_code IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   sy_orgn_usr
                 WHERE  user_id = powner_id
                        AND orgn_code = powner_orgn);

  /* Local variables. */
  /* ================ */
  l_ret                    NUMBER;
  inv_owner_orgn_code      EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN Cur_ownerorgn_code;
  FETCH Cur_ownerorgn_code INTO l_ret;
  IF (Cur_ownerorgn_code%NOTFOUND) THEN
    CLOSE Cur_ownerorgn_code;
    RAISE inv_owner_orgn_code;
  END IF;
  CLOSE Cur_ownerorgn_code;
EXCEPTION
  WHEN inv_owner_orgn_code THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_USER_ORGANIZATION');
      FND_MSG_PUB.ADD;
END check_ownerorgn_code;

/* ==================================================================== */
/*  PROCEDURE: */
/*    check_deprouting */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL procedure is responsible for  */
/*    checking the validity of the dep_routingsteps. */
/* */
/*  REQUIREMENTS */
/*    validate dep_routingsteps. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.check_deprouting(pownerorgn_code,proutingStep_no,pdeproutingStep_no); */
/* ==================================================================== */

PROCEDURE check_deprouting (prouting_id          IN     gmd_routings.routing_id%TYPE
                           ,proutingStep_no      IN     fm_rout_dtl.routingStep_no%TYPE
                           ,pdeproutingStep_no   IN     fm_rout_dep.dep_routingStep_no%TYPE
                           ,x_return_status      OUT NOCOPY VARCHAR2) IS

  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_step_no IS
  SELECT 1
  FROM   SYS.DUAL
  WHERE  EXISTS (SELECT 1
                 FROM   fm_rout_dep
                 WHERE  routing_id = prouting_id
                        AND routingstep_no = proutingStep_no
                        AND dep_routingstep_no = pdeproutingStep_no);

  /* Local variables. */
  /* ================ */
  l_ret                    NUMBER;
  inv_dep_step             EXCEPTION;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN Cur_step_no;
  FETCH Cur_step_no INTO l_ret;
  IF (Cur_step_no%FOUND) THEN
    CLOSE Cur_step_no;
    RAISE inv_dep_step;
  END IF;
  CLOSE Cur_step_no;
EXCEPTION
  WHEN inv_dep_step THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GME', 'PC_RECORD_EXISTS');
      FND_MSG_PUB.ADD;
END check_deprouting;

/* ==================================================================== */
/*  FUNCTION: */
/*    get_fixed_process_loss */
/* */
/*  DESCRIPTION: */
/*    This PL/SQL function is responsible for  */
/*    retrieving the FIXED process loss for the routing class. */
/* */
/*  REQUIREMENTS */
/*    routing_class should be a non null value. */
/*    */
/*  SYNOPSIS: */
/*    l_ret := gmdrtval_pub.get_theoretical_process_loss(prouting_class ); */
/* */
/*  RETURNS: */
/*      Fixed Process loss value. */
/* ==================================================================== */
FUNCTION get_fixed_process_loss(prouting_class IN VARCHAR2) RETURN NUMBER IS
  /* Cursor Definitions. */
  /* =================== */
  CURSOR Cur_get_fixed_process_loss IS
     SELECT fixed_process_loss
     FROM   fm_rout_cls
     WHERE  routing_class = prouting_class ;

  l_process_loss NUMBER;
BEGIN
  IF (prouting_class IS NULL) THEN
     l_process_loss := 0;
  ELSE
    OPEN Cur_get_fixed_process_loss;
    FETCH Cur_get_fixed_process_loss INTO l_process_loss;
    IF (Cur_get_fixed_process_loss%NOTFOUND) THEN
       l_process_loss := NULL;
    END IF;
    CLOSE Cur_get_fixed_process_loss;
  END IF;
  RETURN l_process_loss;
END get_fixed_process_loss;


END GMDRTVAL_PUB;

/
