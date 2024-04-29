--------------------------------------------------------
--  DDL for Package Body INV_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_UTIL" AS
/* $Header: INVVITUB.pls 120.6 2007/11/08 21:44:12 mantyaku ship $ */
-- ------------------------------------------------------------
-- -------------- Package variables and constants -------------
-- ------------------------------------------------------------

G_PKG_NAME       CONSTANT   VARCHAR2(30)  := 'INV_ITEM_UTIL';

l_installed   BOOLEAN;
l_status      VARCHAR2(10);
l_industry    VARCHAR2(10);
l_exist       NUMBER := 0;

-- -------------------------------------------------------
-- --------------------- Procedures ----------------------
-- -------------------------------------------------------

--
-- --------- Get record conaining application installation statuses --------
--

FUNCTION Appl_Install
RETURN  Appl_Inst_type  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst );
END Appl_Install;

--
-- --------------- Single application installation status ---------------
--

FUNCTION Appl_Inst_Status ( p_Appl_ID  IN  NUMBER )
RETURN  VARCHAR2
IS
BEGIN

  IF ( NVL( p_Appl_ID, 0 ) <> 0 )
     AND ( p_Appl_ID IN
       ( INV_Item_Util.g_Appl_Inst.inv
       , INV_Item_Util.g_Appl_Inst.po
       , INV_Item_Util.g_Appl_Inst.bom
       , INV_Item_Util.g_Appl_Inst.eng
       , INV_Item_Util.g_Appl_Inst.cs
       , INV_Item_Util.g_Appl_Inst.ar
       , INV_Item_Util.g_Appl_Inst.mrp
       , INV_Item_Util.g_Appl_Inst.oe
       , INV_Item_Util.g_Appl_Inst.ONT
       , INV_Item_Util.g_Appl_Inst.QP
       , INV_Item_Util.g_Appl_Inst.wip
       , INV_Item_Util.g_Appl_Inst.fa
       , INV_Item_Util.g_Appl_Inst.jl
       , INV_Item_Util.g_Appl_Inst.WMS
       , INV_Item_Util.g_Appl_Inst.CSP
       , INV_Item_Util.g_Appl_Inst.CSS
       , INV_Item_Util.g_Appl_Inst.OKS
       , INV_Item_Util.g_Appl_Inst.AMS
       , INV_Item_Util.g_Appl_Inst.IBA
       , INV_Item_Util.g_Appl_Inst.IBE
       , INV_Item_Util.g_Appl_Inst.CUI
       , INV_Item_Util.g_Appl_Inst.XNC
       , INV_Item_Util.g_Appl_Inst.CUN
       , INV_Item_Util.g_Appl_Inst.CUS
       , INV_Item_Util.g_Appl_Inst.WPS
       , INV_Item_Util.g_Appl_Inst.EAM
       , INV_Item_Util.g_Appl_Inst.ENI
       , INV_Item_Util.g_Appl_Inst.EGO
       , INV_Item_Util.g_Appl_Inst.CSI
       , INV_Item_Util.g_Appl_Inst.CZ
       , INV_Item_Util.g_Appl_Inst.FTE
       , INV_Item_Util.g_Appl_Inst.GMI
       /* Start Bug 3713912 */
       , INV_Item_Util.g_Appl_Inst.GMD
       , INV_Item_Util.g_Appl_Inst.GME
       , INV_Item_Util.g_Appl_Inst.GR
       /* End Bug 3713912 */
       /* Bug 5015595 */
       ,INV_Item_Util.g_Appl_Inst.XDP
       --6531763: Adding ICX install check.
       ,INV_Item_Util.g_Appl_Inst.ICX)
     )
  THEN
     RETURN ( 'I' );
  ELSE
     RETURN ( 'N' );
  END IF;

END Appl_Inst_Status;


/*fix for bug:6133992 */

FUNCTION create_inv_mvlog (p_table_name varchar2)
RETURN NUMBER
IS
lv_dummy1            VARCHAR2(2000);
lv_dummy2            VARCHAR2(2000);
lv_inv_schema        VARCHAR2(40);
lv_retval            BOOLEAN;
v_applsys_schema     VARCHAR2(40);
lv_prod_short_name   VARCHAR2(30);
v_sql_stmt           VARCHAR2(6000);

begin
  lv_retval := FND_INSTALLATION.GET_APP_INFO('FND', lv_dummy1,lv_dummy2, v_applsys_schema);
  lv_prod_short_name := AD_TSPACE_UTIL.get_product_short_name(401);
  lv_retval := FND_INSTALLATION.GET_APP_INFO (lv_prod_short_name, lv_dummy1, lv_dummy2, lv_inv_schema);

  v_sql_stmt:= 'CREATE MATERIALIZED VIEW log ON '||lv_inv_schema ||'.'||p_table_name||'  WITH ROWID ' ;
  ad_ddl.do_ddl( applsys_schema => v_applsys_schema,
                 application_short_name => lv_prod_short_name ,
                 statement_type => AD_DDL.CREATE_TABLE,
                 statement => v_sql_stmt,
                 object_name => p_table_name);
  RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
	FND_FILE.PUT_LINE(FND_FILE.LOG, SQLERRM);
	RAISE;
end create_inv_mvlog;





FUNCTION Appl_Inst_inv
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.inv );
END Appl_Inst_inv;

FUNCTION Appl_Inst_po
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.po );
END;

FUNCTION Appl_Inst_bom
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.bom );
END;

FUNCTION Appl_Inst_eng
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.eng );
END;

FUNCTION Appl_Inst_cs
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.cs );
END;

FUNCTION Appl_Inst_ar
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.ar );
END;

FUNCTION Appl_Inst_mrp
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.mrp );
END;

FUNCTION Appl_Inst_oe
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.oe );
END;

FUNCTION Appl_Inst_ONT
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.ONT );
END;

FUNCTION Appl_Inst_QP
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.QP );
END;

FUNCTION Appl_Inst_wip
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.wip );
END;

FUNCTION Appl_Inst_fa
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.fa );
END;

FUNCTION Appl_Inst_jl
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.jl );
END;

FUNCTION Appl_Inst_WMS
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.WMS );
END;

FUNCTION Appl_Inst_CSP
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CSP );
END;

FUNCTION Appl_Inst_CSS
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CSS );
END;

FUNCTION Appl_Inst_OKS
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.OKS );
END;

FUNCTION Appl_Inst_AMS
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.AMS );
END;

FUNCTION Appl_Inst_IBA
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.IBA );
END;

FUNCTION Appl_Inst_IBE
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.IBE );
END;

FUNCTION Appl_Inst_CUI
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CUI );
END;

FUNCTION Appl_Inst_XNC
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.XNC );
END;

FUNCTION Appl_Inst_CUN
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CUN );
END;

FUNCTION Appl_Inst_CUS
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CUS );
END;

FUNCTION Appl_Inst_WPS
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.WPS );
END;

FUNCTION Appl_Inst_EAM
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.EAM );
END;

--Bug: 2718703
FUNCTION Appl_Inst_ENI
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.ENI );
END;

--Bug: 2728939
FUNCTION Appl_Inst_EGO
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.EGO );
END;

FUNCTION Appl_Inst_CSI
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CSI );
END;

FUNCTION Appl_Inst_CZ
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.CZ );
END;
--Bug: 2691174
FUNCTION Appl_Inst_FTE
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.FTE );
END;
FUNCTION Appl_Inst_GMI
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.GMI);
END;
  /* Start Bug 3713912 */ /* remove GMI function */

FUNCTION Appl_Inst_GMD
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.GMD);
END;
FUNCTION Appl_Inst_GME
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.GME);
END;
FUNCTION Appl_Inst_GR
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.GR);
END;

/* End Bug 3713912 */

-- PJM_Unit_Eff_Enabled
--
FUNCTION PJM_Unit_Eff_Enabled
RETURN  VARCHAR2  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.PJM_Unit_Eff_flag );
END;

-- 6531763: Adding ICX install check
FUNCTION Appl_Inst_ICX
RETURN  NUMBER  IS
BEGIN
  RETURN( INV_Item_Util.g_Appl_Inst.ICX);
END;


FUNCTION Object_Exists(p_object_type VARCHAR2,p_object_name VARCHAR2)
RETURN  VARCHAR2 IS
  l_exists VARCHAR2(1) := 'N';
   --*Modified by dikrishn,Added for bug:3872140
   --*To support GSCC Test removing hard coded shema name APPS
   schema_name VARCHAR2(30):='APPS';
   --Schema Names can be 30 char wide Bug:5026190
 CURSOR c_check_object(cp_object_type VARCHAR2, cp_object_name VARCHAR2)IS
    SELECT 'Y'
    FROM   all_objects
    WHERE  owner        = schema_name
    AND    object_type  = cp_object_type
    AND    object_name  = cp_object_name
    AND    status       = 'VALID';
BEGIN
  OPEN  c_check_object(cp_object_type => p_object_type
                      ,cp_object_name => p_object_name);

  FETCH c_check_object INTO l_exists;
  CLOSE c_check_object;

  RETURN l_exists;
END Object_Exists;
/*-----------------------------------------------------------*/
/* Package initialization block (runs only once per session) */
/*-----------------------------------------------------------*/

BEGIN
  l_installed := fnd_installation.get( appl_id => 401, dep_appl_id => 401,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.inv := 401;
  else  g_Appl_Inst.inv := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 201, dep_appl_id => 201,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.po := 201;
  else  g_Appl_Inst.po := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 702, dep_appl_id => 702,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.bom := 702;
  else  g_Appl_Inst.bom := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 703, dep_appl_id => 703,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.eng := 703;
  else  g_Appl_Inst.eng := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 170, dep_appl_id => 170,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.cs := 170;
  else  g_Appl_Inst.cs := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 222, dep_appl_id => 222,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.ar := 222;
  else  g_Appl_Inst.ar := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 704, dep_appl_id => 704,
                                       status => l_status, industry => l_industry );
  if (l_status in ('I', 'S'))
  then  g_Appl_Inst.mrp := 704;
  else  g_Appl_Inst.mrp := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 300, dep_appl_id => 300,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.oe := 300;
  else  g_Appl_Inst.oe := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 660, dep_appl_id => 660,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.ONT := 660;
  else  g_Appl_Inst.ONT := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 661, dep_appl_id => 661,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.QP := 661;
  else  g_Appl_Inst.QP := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 706, dep_appl_id => 706,
                                       status => l_status, industry => l_industry );
  if (l_status in ('I', 'S'))
  then  g_Appl_Inst.wip := 706;
  else  g_Appl_Inst.wip := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 140, dep_appl_id => 140,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.fa := 140;
  else  g_Appl_Inst.fa := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 7004, dep_appl_id => 7004,
                                       status => l_status, industry => l_industry );
  -- Depends on Latin America Localizations profile value
  --
  --Bug: 4880971 The profile option JGZZ_PRODUCT_CODE is getting obsoleted
  if (l_status = 'I')
  then  g_Appl_Inst.jl := 7004;
  else  g_Appl_Inst.jl := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 385, dep_appl_id => 385,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.WMS := 385;
  else  g_Appl_Inst.WMS := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 523, dep_appl_id => 523,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CSP := 523;
  else  g_Appl_Inst.CSP := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 514, dep_appl_id => 514,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CSS := 514;
  else  g_Appl_Inst.CSS := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 515, dep_appl_id => 515,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.OKS := 515;
  else  g_Appl_Inst.OKS := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 530, dep_appl_id => 530,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.AMS := 530;
  else  g_Appl_Inst.AMS := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 670, dep_appl_id => 670,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.IBA := 670;
  else  g_Appl_Inst.IBA := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 671, dep_appl_id => 671,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.IBE := 671;
  else  g_Appl_Inst.IBE := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 8722, dep_appl_id => 8722,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CUI := 8722;
  else  g_Appl_Inst.CUI := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 532, dep_appl_id => 532,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.XNC := 532;
  else  g_Appl_Inst.XNC := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 8729, dep_appl_id => 8729,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CUN := 8729;
  else  g_Appl_Inst.CUN := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 8727, dep_appl_id => 8727,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CUS := 8727;
  else  g_Appl_Inst.CUS := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 388, dep_appl_id => 388,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.WPS := 388;
  else  g_Appl_Inst.WPS := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 426, dep_appl_id => 426,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.EAM := 426;
  else  g_Appl_Inst.EAM := 0;
  end if;

 /*Bug 3013937: Eni application installed check not required.
  l_installed := fnd_installation.get( appl_id => 455, dep_appl_id => 455,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')  then
  */
  --Bug: 2858117 Checking for ENI package
  SELECT count(1)  INTO l_exist
  FROM user_objects
  WHERE objecT_name= 'ENI_ITEMS_STAR_PKG'
  AND object_type = 'PACKAGE';
  if (l_exist <> 0 ) then
    g_Appl_Inst.ENI := 455;
  else
    g_Appl_Inst.ENI := 0;
  end if;
/* Bug 3013937: Eni application installed check not required.
  else
      g_Appl_Inst.ENI := 0;
  end if;
*/
  l_installed := fnd_installation.get( appl_id => 431, dep_appl_id => 431,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.EGO := 431;
  else  g_Appl_Inst.EGO := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 542, dep_appl_id => 542,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CSI := 542;
  else  g_Appl_Inst.CSI := 0;
  end if;

  l_installed := fnd_installation.get( appl_id => 708, dep_appl_id => 708,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.CZ := 708;
  else  g_Appl_Inst.CZ := 0;
  end if;

--Bug: 2691174
  l_installed := fnd_installation.get( appl_id => 716, dep_appl_id => 716,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.FTE := 716;
  else  g_Appl_Inst.FTE := 0;
  end if;
  l_installed := fnd_installation.get( appl_id => 716, dep_appl_id => 551,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.GMI := 551;
  else  g_Appl_Inst.GMI := 0;
  end if;
/* Start Bug 3713912 */
  l_installed := fnd_installation.get( appl_id => 716, dep_appl_id => 552,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.GMD := 552;
  else  g_Appl_Inst.GMD := 0;
  end if;
  l_installed := fnd_installation.get( appl_id => 716, dep_appl_id => 553,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.GME := 553;
  else  g_Appl_Inst.GME := 0;
  end if;
  l_installed := fnd_installation.get( appl_id => 716, dep_appl_id => 557,
                                       status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.GR := 557;
  else  g_Appl_Inst.GR := 0;
  end if;

/* End Bug 3713912 */

/* Start Bug 5015595 */
  l_installed := fnd_installation.get( appl_id => 535, dep_appl_id => 535,
                                        status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.XDP := 535;
  else  g_Appl_Inst.XDP := 0;
  end if;
/* End Bug 5015595 */

  -- Parameter gets value Y/N depending on whether Model/Unit Effectivity
  -- has been enabled or not.
  --
  g_Appl_Inst.PJM_Unit_Eff_flag := PJM_UNIT_EFF.Enabled();

  -- 6531763: Adding ICX install check
  l_installed := fnd_installation.get( appl_id => 178, dep_appl_id => 178,
                                        status => l_status, industry => l_industry );
  if (l_status = 'I')
  then  g_Appl_Inst.ICX := 178;
  else  g_Appl_Inst.ICX := 0;
  end if;

END INV_ITEM_UTIL;

/
