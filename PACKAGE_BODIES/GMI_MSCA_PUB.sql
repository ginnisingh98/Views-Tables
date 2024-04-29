--------------------------------------------------------
--  DDL for Package Body GMI_MSCA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_MSCA_PUB" AS
/*  $Header: GMIPMSCB.pls 120.0 2005/05/25 16:12:20 appldev noship $     */


--- For GTIN support
g_gtin_cross_ref_type VARCHAR2(25) := fnd_profile.value('INV:GTIN_CROSS_REFERENCE_TYPE');
g_gtin_code_length NUMBER := 14;


-- PL/SQL package to support Java MSCA for GMI
PROCEDURE print_debug( p_message IN VARCHAR2)
IS
l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_log_util.TRACE(p_message, 'Mobile GMI', 9);
--   dbms_output.put_line(p_message);
END print_debug;


   FUNCTION get_opm_uom_code(x_apps_unit_meas_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS
     v_um_code SY_UOMS_MST.UM_CODE%TYPE;
   BEGIN

     Select um_code
     Into   v_um_code
     From   sy_uoms_mst
     Where  unit_of_measure = x_apps_unit_meas_lookup_code;

     RETURN(v_um_code);

    EXCEPTION
      WHEN OTHERS THEN
      raise;

    END get_opm_uom_code;

-- LOV procedures :

PROCEDURE item_no_lov
( x_itemNo_cursor    OUT NOCOPY t_genref
, p_item_no          IN  VARCHAR2
, p_item_desc        IN  VARCHAR2
)
IS

   l_cross_ref varchar2(204);


BEGIN

    l_cross_ref := lpad(Rtrim(p_item_no, '%'), g_gtin_code_length,'00000000000000');


print_debug('in item LOV... item_no='||p_item_no||', desc='||p_item_desc||'.');

IF (length(NVL(p_item_no, '')) > 0)
THEN

  OPEN x_itemNo_cursor FOR
  SELECT item_no, item_desc1, item_id
  , loct_ctl, lot_ctl, sublot_ctl, grade_ctl, status_ctl, dualum_ind
  , qc_grade, lot_status, lot_indivisible, item_um, item_um2, noninv_ind
  FROM   ic_item_mst
  WHERE  UPPER(item_no) like UPPER(p_item_no)
  AND    delete_mark = 0

      --- For GTIN support
  UNION

  SELECT item_no, item_desc1, item_id
  , loct_ctl, lot_ctl, sublot_ctl, grade_ctl, status_ctl, dualum_ind
  , qc_grade, lot_status, lot_indivisible,
  Get_Opm_Uom_Code(mcr.uom_code) item_um,
  item_um2, noninv_ind
  FROM
      mtl_cross_references mcr,
      mtl_system_items mti,
      ic_item_mst opi
  WHERE
      opi.item_no = mti.segment1
      AND mti.inventory_item_id = mcr.inventory_item_id
      AND    mcr.cross_reference_type = g_gtin_cross_ref_type
      AND    mcr.cross_reference      LIKE l_cross_ref
---      AND    (mcr.organization_id = mti.organization_id
           ---OR
---      AND    mcr.org_independent_flag = 'Y'

  ORDER BY item_no;

ELSE
  -- Force to raise "NO Result Found".
  OPEN x_itemNo_cursor FOR
  SELECT item_no, item_desc1, item_id
  , loct_ctl, lot_ctl, sublot_ctl, grade_ctl, status_ctl, dualum_ind
  , qc_grade, lot_status, lot_indivisible, item_um, item_um2, noninv_ind
  FROM   ic_item_mst
  WHERE  1=2;
END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END item_no_lov;

PROCEDURE loct_lov
( x_loct_cursor      OUT NOCOPY t_genref
, p_loct             IN  VARCHAR2
, p_whse_code        IN  VARCHAR2
)
IS

/*
select location, loct_desc
from ic_loct_mst
where whse_code = :ic_adjs_jnl_vw.to_whse_code
and delete_mark = 0 and location <> :parameter.default_loct
UNION
select distinct l.location, '' loct_desc
from ic_loct_inv l
where   whse_code = :ic_adjs_jnl_vw.to_whse_code
and not exists (select location from ic_loct_mst where location =  l.location)
and  (:ic_adjs_jnl_vw.item_loct_ctl = 2 OR :ic_adjs_jnl_vw.to_whse_loct_ctl = 2) order by 1
*/

BEGIN

  OPEN x_loct_cursor FOR
  SELECT location, loct_desc, whse_code
  FROM ic_loct_mst
  WHERE whse_code LIKE p_whse_code
  AND   location <> FND_PROFILE.VALUE('IC$DEFAULT_LOCT')
  AND   location LIKE p_loct
  AND   delete_mark = 0
  UNION
  SELECT l.location, null, l.whse_code
  FROM ic_loct_inv l
  WHERE l.whse_code LIKE p_whse_code
  AND   l.location LIKE p_loct
  AND   NOT EXISTS(select location from ic_loct_mst where location =  l.location)
  ORDER BY 1;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END loct_lov;

PROCEDURE lot_lov
( x_lot_cursor    OUT NOCOPY t_genref
, p_lot           IN  VARCHAR2
, p_sublot        IN  VARCHAR2
, p_item_no       IN  VARCHAR2
, p_whse_code     IN  VARCHAR2
, p_location      IN  VARCHAR2
)
IS


/* OPM Note : LOT statement in form ICQTYED:
SELECT DISTINCT A.lot_no, A.sublot_no
FROM ic_lots_mst A, ic_loct_inv B
WHERE  A.lot_id = B.lot_id AND A.delete_mark = 0 AND B.delete_mark = 0
AND B.item_id = :PARAMETER.item_id and a.item_id = b.item_id
AND lot_no <> :parameter.default_lot
UNION
select lot_no, sublot_no
from ic_lots_mst
where item_id = :parameter.item_id
and (substr(:ic_jrnl_mst.trans_type,1,3) in ('CRE','ADJ')) and delete_mark = 0
and lot_no <> :parameter.default_lot
ORDER BY 1, 2
*/
BEGIN

    OPEN x_lot_cursor FOR
    SELECT DISTINCT A.lot_no, NVL(A.sublot_no, ' '), NVL(A.lot_desc, ' ')
    , A.lot_id, A.item_id, NVL(A.qc_grade, ' '), B.lot_status
    FROM ic_lots_mst A, ic_loct_inv B
    WHERE  A.lot_id = B.lot_id
    AND A.lot_no LIKE p_lot
    AND A.delete_mark = 0
    AND B.delete_mark = 0
    AND B.item_id IN (SELECT item_id FROM ic_item_mst WHERE item_no = p_item_no)
    AND A.item_id = B.item_id
    AND NVL(p_whse_code, B.whse_code) = B.whse_code
    AND NVL(p_location, B.location) = B.location
   UNION
    SELECT DISTINCT A.lot_no, NVL(A.sublot_no, ' '), NVL(A.lot_desc, ' ')
    , A.lot_id, A.item_id, NVL(A.qc_grade, ' '), null
    FROM ic_lots_mst A
    WHERE A.lot_no LIKE p_lot
    AND A.delete_mark = 0
    AND A.item_id IN (SELECT item_id FROM ic_item_mst WHERE item_no = p_item_no)
    AND A.lot_id > 0
    ORDER BY 1, 2;


EXCEPTION
WHEN OTHERS
THEN
print_debug('in lot LOV unexp error');
      NULL;

END lot_lov;

PROCEDURE orgn_lov
( x_orgn_cursor    OUT NOCOPY t_genref
, p_orgn           IN  VARCHAR2
, p_user_id        IN  NUMBER
)
IS
BEGIN

OPEN x_orgn_cursor FOR
SELECT m.orgn_code, m.orgn_name, m.co_code
FROM   sy_orgn_mst m, sy_orgn_usr u
WHERE  u.user_id = p_user_id
AND    u.orgn_code = m.orgn_code
AND    m.orgn_code like p_orgn
AND    m.delete_mark = 0
ORDER BY m.orgn_code;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END orgn_lov;

PROCEDURE reason_lov
( x_reason_cursor  OUT NOCOPY t_genref
, p_reason         IN  VARCHAR2
, p_doc_type       IN  VARCHAR2
)
IS
BEGIN

-- in TDD closed issues :
-- The reason code LOV must be the same in Forms UI and Mobile
-- Restriction on increase/decrease are only for ADJI.

-- NEED TO REALLY CHECK THE LOV IN DESKTOP
-- 11.5.9
-- 11.5.10

OPEN x_reason_cursor FOR
SELECT reason_code, reason_desc1, reason_type
FROM sy_reas_cds
WHERE delete_mark = 0
AND ((NVL(FND_PROFILE.VALUE('GMA_REASON_CODE_SECURITY'), 'N') = 'N'
   OR reason_code IN (SELECT reason_code FROM gma_reason_code_security
                   WHERE (doc_type = p_doc_type or doc_type IS NULL)
                     AND (responsibility_id = FND_GLOBAL.RESP_id OR responsibility_id IS NULL)) ) )
AND reason_code LIKE UPPER(p_reason)
ORDER BY 1 ;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END reason_lov;

PROCEDURE sublot_lov
( x_sublot_cursor OUT NOCOPY t_genref
, p_sublot        IN  VARCHAR2
, p_lot           IN  VARCHAR2
, p_item_no       IN  VARCHAR2
)
IS
BEGIN

print_debug('in sublot item='||p_item_no||', lot='||p_lot||', sublot='||p_sublot||'.');
    OPEN x_sublot_cursor FOR
    SELECT DISTINCT A.lot_no, NVL(A.sublot_no, ' '), NVL(A.lot_desc, ' ')
    , A.lot_id, A.item_id, NVL(A.qc_grade, ' '), B.lot_status
    FROM   ic_lots_mst A
    , ic_loct_inv B
    WHERE  B.lot_id = A.lot_id
    AND    B.item_id = A.item_id
    AND    A.sublot_no like p_sublot
    AND    A.lot_no = p_lot
    AND    A.item_id IN (SELECT item_id FROM ic_item_mst WHERE item_no = p_item_no)
    AND    B.delete_mark = 0
    AND    A.delete_mark = 0
    ORDER BY 1, 2;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END sublot_lov;

PROCEDURE uom_lov
( x_uom_cursor      OUT NOCOPY t_genref
, p_uom             IN  VARCHAR2
, p_item_no         IN  VARCHAR2)
IS

BEGIN

print_debug('in uom_lov item_no='||p_item_no||'...');
OPEN x_uom_cursor FOR
SELECT u.uom_code
FROM   sy_uoms_mst u
, ic_item_cnv i
WHERE  i.um_type = u.um_type
AND    u.uom_code like p_uom
AND    i.item_id IN (SELECT item_id FROM ic_item_mst WHERE item_no = p_item_no)
AND    i.delete_mark = 0
AND    u.delete_mark = 0
UNION ALL
SELECT item_um
FROM ic_item_mst
WHERE item_no = p_item_no
AND   item_um like p_uom
ORDER BY 1;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END uom_lov;

PROCEDURE whse_lov
( x_subInv_cursor    OUT NOCOPY t_genref
, p_whse_code        IN  VARCHAR2
, p_orgn_code        IN  VARCHAR2
, p_user_id          IN  NUMBER
)
IS
BEGIN

-- In Item Inquery the organization is not displayed (null value)
IF ( NVL(p_orgn_code, ' ') = ' ' )
THEN
 IF  (length( NVL(p_whse_code, '')) > 0)
 THEN
   OPEN x_subInv_cursor FOR
   SELECT w.whse_code, w.whse_name, w.orgn_code, w.mtl_organization_id, loct_ctl
   FROM   ic_whse_mst w, sy_orgn_usr u
   WHERE  u.orgn_code = w.orgn_code
   AND    u.user_id = p_user_id
   AND    w.whse_code like p_whse_code
   AND    w.delete_mark = 0
   ORDER BY whse_code;
 ELSE
   -- This query forces the return of No Result Found.
   OPEN x_subInv_cursor FOR
   SELECT w.whse_code, w.whse_name, w.orgn_code, w.mtl_organization_id, loct_ctl
   FROM   ic_whse_mst w
   WHERE  1=2;
 END IF;
ELSE
 IF  (length( NVL(p_whse_code, '')) > 0)
 THEN
   OPEN x_subInv_cursor FOR
   SELECT w.whse_code, w.whse_name, w.orgn_code, w.mtl_organization_id, loct_ctl
   FROM   ic_whse_mst w, sy_orgn_usr u
   WHERE  u.orgn_code = w.orgn_code
   AND    u.orgn_code = p_orgn_code
   AND    u.user_id = p_user_id
   AND    w.whse_code like p_whse_code
   AND    w.delete_mark = 0
   ORDER BY whse_code;
 ELSE
   -- This query forces the return of No Result Found.
   OPEN x_subInv_cursor FOR
   SELECT w.whse_code, w.whse_name, w.orgn_code, w.mtl_organization_id, loct_ctl
   FROM   ic_whse_mst w
   WHERE  1=2;
 END IF;
END IF;
EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END whse_lov;

PROCEDURE to_whse_lov
( x_subInv_cursor    OUT NOCOPY t_genref
, p_whse_code        IN  VARCHAR2
, p_from_whse_code   IN  VARCHAR2
, p_orgn_code        IN  VARCHAR2
, p_user_id          IN  NUMBER
)
IS
BEGIN

-- It is possible to transfer into the same whse :
--    AND    w.whse_code <> p_from_whse_code
-- bug 4033866 : replaced sy_orgn_usr
--               and removed the user_id restriction.
--   WHERE  u.orgn_code = w.orgn_code
--   AND    u.orgn_code = p_orgn_code
--   AND    u.user_id = p_user_id
 IF  (length( NVL(p_whse_code, '')) > 0)
 THEN
   OPEN x_subInv_cursor FOR
   SELECT w.whse_code, w.whse_name, w.orgn_code, w.mtl_organization_id, loct_ctl
   FROM   ic_whse_mst w
   WHERE  w.whse_code like p_whse_code
   AND    w.delete_mark = 0
   ORDER BY whse_code;
 ELSE
   -- This query forces the return of No Result Found.
   OPEN x_subInv_cursor FOR
   SELECT w.whse_code, w.whse_name, w.orgn_code, w.mtl_organization_id, loct_ctl
   FROM   ic_whse_mst w
   WHERE  1=2;
 END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END to_whse_lov;

PROCEDURE to_loct_lov
( x_loct_cursor      OUT NOCOPY t_genref
, p_loct             IN  VARCHAR2
, p_whse_code        IN  VARCHAR2
, p_from_whse        IN  VARCHAR2
, p_from_loct        IN  VARCHAR2
)
IS

/*
select location, loct_desc
from ic_loct_mst
where whse_code = :ic_adjs_jnl_vw.to_whse_code
and delete_mark = 0 and location <> :parameter.default_loct UNION
select distinct l.location, '' loct_desc
from ic_loct_inv l
where   whse_code = :ic_adjs_jnl_vw.to_whse_code
and not exists (select location from ic_loct_mst where location =  l.location)
and  (:ic_adjs_jnl_vw.item_loct_ctl = 2 OR :ic_adjs_jnl_vw.to_whse_loct_ctl = 2) order by 1
*/

BEGIN

  OPEN x_loct_cursor FOR
  SELECT location, loct_desc, whse_code
  FROM ic_loct_mst
  WHERE whse_code LIKE p_whse_code
  AND   location <> FND_PROFILE.VALUE('IC$DEFAULT_LOCT')
  AND   location LIKE p_loct
  AND   ( (location <> p_from_loct AND whse_code = p_from_whse)
        OR (whse_code <> p_from_whse) )
  AND   delete_mark = 0
  UNION
  SELECT l.location, null, l.whse_code
  FROM ic_loct_inv l
  WHERE l.whse_code LIKE p_whse_code
  AND   l.location LIKE p_loct
  AND   ( (l.location <> p_from_loct AND l.whse_code = p_from_whse)
        OR (l.whse_code <> p_from_whse) )
  AND   NOT EXISTS(select location from ic_loct_mst where location =  l.location)
  ORDER BY 1;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      NULL;

END to_loct_lov;

-- End of LOV Procedures

-- Begin of other procedures
PROCEDURE create_transaction
( p_user_name     IN VARCHAR2
, p_doc_type      IN VARCHAR2
, p_item_no       IN VARCHAR2
, p_whse_code     IN VARCHAR2
, p_orgn_code     IN VARCHAR2
, p_co_code       IN VARCHAR2
, p_location      IN VARCHAR2
, p_lot_no        IN VARCHAR2
, p_sublot_no     IN VARCHAR2
, p_qc_grade      IN VARCHAR2
, p_lot_status    IN VARCHAR2
, p_reason_code   IN VARCHAR2
, p_trans_qty1    IN NUMBER
, p_trans_UOM1    IN VARCHAR2
, p_trans_qty2    IN NUMBER
, p_trans_UOM2    IN VARCHAR2
, p_to_whse_code  IN VARCHAR2
, p_to_location   IN VARCHAR2
, x_return_value  OUT NOCOPY NUMBER
, x_message       OUT NOCOPY VARCHAR2)

IS

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(240);
l_message       VARCHAR2(300);
l_count         NUMBER;
l_bool          BOOLEAN;
l_trans_type    NUMBER;
l_lot_no        VARCHAR2(150);
l_sublot_no     VARCHAR2(150);
l_location      VARCHAR2(150);
l_qc_grade      VARCHAR2(5);
l_lot_status    VARCHAR2(5);

l_qty_rec          GMIGAPI.qty_rec_typ;

l_ic_jrnl_mst_row  ic_jrnl_mst%ROWTYPE;
l_ic_adjs_jnl_row1 ic_adjs_jnl%ROWTYPE;
l_ic_adjs_jnl_row2 ic_adjs_jnl%ROWTYPE;

BEGIN
print_debug('in Create_Transaction doc_type='||p_doc_type||'...');
print_debug('in Create_Transaction item='||p_item_no||', whse='||p_whse_code||', orgn='||p_orgn_code||', co='||p_co_code);
print_debug('in Create_Transaction lot='||p_lot_no||', status='||p_lot_status||', qty='||p_trans_qty1||', qty2='||p_trans_qty2);
print_debug('in Create_Transaction sublot='||p_sublot_no||', location='||p_location||', grade='||p_qc_grade);

l_bool := GMIGUTL.setup(p_user_name);

IF (p_doc_type = 'ADJI')
THEN
   l_trans_type := 2;
ELSIF (p_doc_type = 'TRNI')
THEN
   l_trans_type := 3;
END IF;

IF ( NVL(p_lot_no, '') IN ('NULL', '') )
THEN
  l_lot_no := NULL;
ELSE
  l_lot_no := p_lot_no;
END IF;

IF ( NVL(p_sublot_no, '') IN ('NULL', '') )
THEN
  l_sublot_no := NULL;
ELSE
  l_sublot_no := p_sublot_no;
END IF;

IF ( NVL(p_location, '') IN ('NULL', '') )
THEN
  l_location := NULL;
ELSE
  l_location := p_location;
END IF;

IF ( NVL(p_qc_grade, '') IN ('NULL', '') )
THEN
  l_qc_grade := NULL;
ELSE
  l_qc_grade := p_qc_grade;
END IF;

IF ( NVL(p_lot_status, '') IN ('NULL', '') )
THEN
  l_lot_status := NULL;
ELSE
  l_lot_status := p_lot_status;
END IF;

print_debug('in Create_Transaction local lot='||l_lot_no||', status='||l_lot_status||'.');
print_debug('in Create_Transaction local sublot='||l_sublot_no||', location='||l_location||', grade='||l_qc_grade);

l_qty_rec.trans_type      := l_trans_type;
l_qty_rec.item_no         := p_item_no;
--l_qty_rec.journal_no      ic_jrnl_mst.journal_no%TYPE
l_qty_rec.from_whse_code  := p_whse_code;
IF (p_doc_type = 'TRNI')
THEN
  l_qty_rec.to_whse_code  := p_to_whse_code;
  l_qty_rec.to_location   := p_to_location;
END IF;
l_qty_rec.item_um         := p_trans_UOM1;
l_qty_rec.item_um2        := p_trans_UOM2;
l_qty_rec.lot_no          := l_lot_no;
l_qty_rec.sublot_no       := l_sublot_no;
l_qty_rec.from_location   := l_location;
l_qty_rec.trans_qty       := p_trans_qty1;
l_qty_rec.trans_qty2      := p_trans_qty2;
l_qty_rec.qc_grade        := l_qc_grade;
l_qty_rec.lot_status      := l_lot_status;
l_qty_rec.co_code         := p_co_code;
l_qty_rec.orgn_code       := p_orgn_code;
--l_qty_rec.trans_date      ic_tran_cmp.trans_date%TYPE DEFAULT SYSDATE
l_qty_rec.reason_code     := p_reason_code;
l_qty_rec.user_name       := p_user_name;
l_qty_rec.journal_comment := p_doc_type||' PLSQL';
--l_qty_rec.attribute1          ic_jrnl_mst.attribute1%TYPE          DEFAULT NULL
--l_qty_rec.attribute2          ic_jrnl_mst.attribute2%TYPE          DEFAULT NULL
--l_qty_rec.attribute30         ic_jrnl_mst.attribute30%TYPE         DEFAULT NULL
--l_qty_rec.attribute_category  ic_jrnl_mst.attribute_category%TYPE  DEFAULT NULL
--l_qty_rec.acctg_unit_no       VARCHAR2(240)                        DEFAULT NULL
--l_qty_rec.acct_no             VARCHAR2(240)                        DEFAULT NULL
--l_qty_rec.txn_type            VARCHAR2(3)                          DEFAULT NULL
--l_qty_rec.journal_ind         VARCHAR2(1)                          DEFAULT NULL
--l_qty_rec.move_entire_qty     VARCHAR2(2)                          DEFAULT 'Y'  --BUG#2861715 Sastry


print_debug('in Create_Transaction calling GMIPAPI.Inventory_Posting');

GMIPAPI.Inventory_Posting
        ( p_api_version      => 3.0
        , p_init_msg_list    => FND_API.G_TRUE
        , p_commit           => FND_API.G_FALSE
        , p_validation_level => FND_API.G_VALID_LEVEL_FULL
        , p_qty_rec          => l_qty_rec
        , x_ic_jrnl_mst_row  => l_ic_jrnl_mst_row
        , x_ic_adjs_jnl_row1 => l_ic_adjs_jnl_row1
        , x_ic_adjs_jnl_row2 => l_ic_adjs_jnl_row2
        , x_return_status    => l_return_status
        , x_msg_count        => l_msg_count
        , x_msg_data         => l_msg_data);

print_debug('in Create_Transaction after GMIPAPI.Inventory_Posting');

IF l_return_status = fnd_api.g_ret_sts_success
THEN
   print_debug('SUCCESS....');
   x_return_value := 0;
   COMMIT;
ELSE
   print_debug('ERROR  count='|| l_msg_count);
   IF l_msg_count > 0
   THEN
     FOR i IN 1..l_msg_count
     LOOP
         FND_MSG_PUB.get
         ( p_msg_index    => i
         , p_data          => l_message
         , p_encoded       => fnd_api.g_false
         , p_msg_index_out => l_count
         );

         IF i = 1
         THEN
           x_message := l_message;
         END IF;

     END LOOP;
   END IF;

   -- bug 4125917 : replaced CASE by IF (compatibility with 8i RDBMS)
   --CASE l_return_status
   --    WHEN 'E'
   IF ( l_return_status = 'E')
   THEN
          x_return_value := -1;
   ELSIF ( l_return_status = 'U')
   THEN
          x_return_value := -2;
   ELSE
          x_return_value := -3;
   END IF;

   ROLLBACK;
END IF;

EXCEPTION
WHEN OTHERS THEN
  print_debug('in Create_Transaction OTHERS='||SQLERRM);
END create_transaction;

PROCEDURE get_lot_status
( p_item_id          IN  NUMBER
, p_whse_code        IN  VARCHAR2
, p_location         IN  VARCHAR2
, p_lot_id           IN  NUMBER
, p_lot_status       IN  VARCHAR2
, x_lot_status       OUT NOCOPY VARCHAR2
)
IS

CURSOR get_lot_stat( item IN NUMBER, whse IN VARCHAR2, loct IN VARCHAR2, lot IN NUMBER, stat IN VARCHAR2) IS
  SELECT ili.lot_status
  FROM ic_lots_sts sts
  , ic_loct_inv ili
  WHERE ili.lot_status = sts.lot_status
  AND   sts.lot_status LIKE stat
  AND   ili.location = loct
  AND   ili.item_id = item
  AND   NVL(lot, ili.lot_id) = ili.lot_id
  AND   ili.delete_mark = 0
  AND   sts.delete_mark = 0
  ORDER BY ili.lot_status;

BEGIN
OPEN get_lot_stat( p_item_id, p_whse_code, p_location, p_lot_id, p_lot_status);
FETCH get_lot_stat
 INTO x_lot_status;

IF (get_lot_stat%NOTFOUND)
THEN
  CLOSE get_lot_stat;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

CLOSE get_lot_stat;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
      x_lot_status := NULL;

END get_lot_status;

END gmi_msca_pub;

/
