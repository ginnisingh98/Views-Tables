--------------------------------------------------------
--  DDL for Package INV_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_UTIL" AUTHID CURRENT_USER AS
/* $Header: INVVITUS.pls 120.3 2007/11/08 21:43:34 mantyaku ship $ */

-- ------------------------------------------------------
-- -------------------- Global types --------------------
-- ------------------------------------------------------

TYPE Appl_Inst_type IS RECORD
(
   inv   NUMBER,  po    NUMBER
,  bom   NUMBER,  eng   NUMBER
,  cs    NUMBER,  ar    NUMBER
,  mrp   NUMBER,  oe    NUMBER
,  ONT   NUMBER,  QP    NUMBER
,  wip   NUMBER,  fa    NUMBER
,  jl    NUMBER,  WMS   NUMBER
,  CSP   NUMBER,  CSS   NUMBER
,  OKS   NUMBER,  AMS   NUMBER
,  IBA   NUMBER,  IBE   NUMBER
,  CUI   NUMBER,  XNC   NUMBER
,  CUN   NUMBER,  CUS   NUMBER
,  WPS   NUMBER,  EAM   NUMBER
,  ENI   NUMBER,  EGO   NUMBER
,  CSI   NUMBER,  CZ    NUMBER
,  FTE   NUMBER,  GMI   NUMBER
,  PJM_Unit_Eff_flag   VARCHAR(1)
/* Start Bug 3713912 */ /* remove GMI */
,  GMD NUMBER
,  GME NUMBER
,  GR  NUMBER
/* End Bug 3713912 */
/* Bug 5015595 */
,  XDP NUMBER
,  ICX NUMBER --6531763
);

-- ----------------------------------------------------------
-- -------------------- Global variables --------------------
-- ----------------------------------------------------------

-- Variable assigned application installation statuses
-- upon package initialization.
--
g_Appl_Inst     Appl_Inst_type;


-- --------------------------------------------------------
-- ------------------- Procedure specs --------------------
-- --------------------------------------------------------

--
-- --------- Get record conaining application installation statuses --------
--

FUNCTION Appl_Install
RETURN  Appl_Inst_type;

--
-- --------------- Single application installation status ---------------
--

FUNCTION Appl_Inst_Status ( p_Appl_ID  IN  NUMBER )
RETURN  VARCHAR2;

FUNCTION Appl_Inst_inv
RETURN  NUMBER;

FUNCTION Appl_Inst_po
RETURN  NUMBER;

FUNCTION Appl_Inst_bom
RETURN  NUMBER;

FUNCTION Appl_Inst_eng
RETURN  NUMBER;

FUNCTION Appl_Inst_cs
RETURN  NUMBER;

FUNCTION Appl_Inst_ar
RETURN  NUMBER;

FUNCTION Appl_Inst_mrp
RETURN  NUMBER;

FUNCTION Appl_Inst_oe
RETURN  NUMBER;

FUNCTION Appl_Inst_ONT
RETURN  NUMBER;

FUNCTION Appl_Inst_QP
RETURN  NUMBER;

FUNCTION Appl_Inst_wip
RETURN  NUMBER;

FUNCTION Appl_Inst_fa
RETURN  NUMBER;

FUNCTION Appl_Inst_jl
RETURN  NUMBER;

FUNCTION Appl_Inst_WMS
RETURN  NUMBER;

FUNCTION Appl_Inst_CSP
RETURN  NUMBER;

FUNCTION Appl_Inst_CSS
RETURN  NUMBER;

FUNCTION Appl_Inst_OKS
RETURN  NUMBER;

FUNCTION Appl_Inst_AMS
RETURN  NUMBER;

FUNCTION Appl_Inst_IBA
RETURN  NUMBER;

FUNCTION Appl_Inst_IBE
RETURN  NUMBER;

FUNCTION Appl_Inst_CUI
RETURN  NUMBER;

FUNCTION Appl_Inst_XNC
RETURN  NUMBER;

FUNCTION Appl_Inst_CUN
RETURN  NUMBER;

FUNCTION Appl_Inst_CUS
RETURN  NUMBER;

FUNCTION Appl_Inst_WPS
RETURN  NUMBER;

FUNCTION Appl_Inst_EAM
RETURN  NUMBER;

--Bug: 2718703
FUNCTION Appl_Inst_ENI
RETURN  NUMBER;

--Bug: 2728939
FUNCTION Appl_Inst_EGO
RETURN  NUMBER;

FUNCTION Appl_Inst_CSI
RETURN  NUMBER;

FUNCTION Appl_Inst_CZ
RETURN  NUMBER;

--Bug:2691174
FUNCTION Appl_Inst_FTE
RETURN  NUMBER;
FUNCTION Appl_Inst_GMI
RETURN  NUMBER;
/* Start Bug 3713912 */ /* remove GMI function */
FUNCTION Appl_Inst_GMD
RETURN  NUMBER;
FUNCTION Appl_Inst_GME
RETURN  NUMBER;
FUNCTION Appl_Inst_GR
RETURN  NUMBER;


/* End Bug 3713912 */
--
-- PJM_Unit_Eff_Enabled
--

FUNCTION PJM_Unit_Eff_Enabled
RETURN  VARCHAR2;

FUNCTION Appl_Inst_ICX
RETURN  NUMBER;


FUNCTION Object_Exists(p_object_type VARCHAR2,p_object_name VARCHAR2)
RETURN  VARCHAR2;

FUNCTION create_inv_mvlog(p_table_name varchar2)    /*fix for bug:6133992  */
RETURN NUMBER;

END INV_ITEM_UTIL;

/
