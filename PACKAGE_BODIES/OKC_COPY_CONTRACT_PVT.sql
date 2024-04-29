--------------------------------------------------------
--  DDL for Package Body OKC_COPY_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_COPY_CONTRACT_PVT" AS
/*$Header: OKCRCPYB.pls 120.20.12010000.2 2008/10/24 08:02:16 ssreekum ship $*/

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  SUBTYPE tavv_rec_type 	IS OKC_TIME_PUB.tavv_rec_type;
  SUBTYPE talv_evt_rec_type 	IS OKC_TIME_PUB.talv_evt_rec_type;
  SUBTYPE tgdv_ext_rec_type     IS OKC_TIME_PUB.tgdv_ext_rec_type;
  SUBTYPE tgnv_rec_type 	IS OKC_TIME_PUB.tgnv_rec_type;
  SUBTYPE isev_rec_type 	IS OKC_TIME_PUB.isev_rec_type;
  SUBTYPE isev_ext_rec_type 	IS OKC_TIME_PUB.isev_ext_rec_type;
  SUBTYPE isev_rel_rec_type 	IS OKC_TIME_PUB.isev_rel_rec_type;
  SUBTYPE igsv_ext_rec_type 	IS OKC_TIME_PUB.igsv_ext_rec_type;
  SUBTYPE cylv_ext_rec_type 	IS OKC_TIME_PUB.cylv_ext_rec_type;
  SUBTYPE spnv_rec_type 	IS OKC_TIME_PUB.spnv_rec_type;
  SUBTYPE tcuv_rec_type 	IS OKC_TIME_PUB.tcuv_rec_type;
  SUBTYPE rtvv_rec_type 	IS OKC_TIME_PUB.rtvv_rec_type;
  sUBTYPE ocev_rec_type 	IS OKC_OUTCOME_PUB.ocev_rec_type;
  SUBTYPE oatv_rec_type 	IS OKC_OUTCOME_PUB.oatv_rec_type;
  SUBTYPE pavv_rec_type 	IS OKC_PRICE_ADJUSTMENT_PUB.pavv_rec_type;
  SUBTYPE scnv_rec_type 	IS OKC_SECTIONS_PUB.scnv_rec_type;
  SUBTYPE sccv_rec_type 	IS OKC_SECTIONS_PUB.sccv_rec_type;
  SUBTYPE ctiv_rec_type  IS OKC_RULE_PUB.ctiv_rec_type;
  SUBTYPE rilv_rec_type  IS OKC_RULE_PUB.rilv_rec_type;
  SUBTYPE gvev_rec_type  IS OKC_CONTRACT_PUB.gvev_rec_type;
  SUBTYPE patv_rec_type         IS OKC_PRICE_ADJUSTMENT_PUB.patv_rec_type;
  SUBTYPE paav_rec_type         IS OKC_PRICE_ADJUSTMENT_PUB.paav_rec_type;
  SUBTYPE pacv_rec_type         IS OKC_PRICE_ADJUSTMENT_PUB.pacv_rec_type;
  g_chrv_rec chrv_rec_type;

  g_pricelist              varchar2(100) := NULL; /* For Euro Conversion - Bug 2155930 */
  g_conversion_type        varchar2(40) := NULL; /* For Euro Conversion - Bug 2155930 */
  g_conversion_rate        number := NULL; /* For Euro Conversion - Bug 2155930 */
  g_conversion_date        date := NULL; /* For Euro Conversion - Bug 2155930 */

  G_COPY_HISTORY_YN             VARCHAR2(3) := 'N';
  G_FROM_VERSION_NUMBER         NUMBER;
  -- keep actual G_COPY_HISTORY_YN in l_old_history_yn
  -- when need to read any record from base table while copying history
  -- This is required as the get_xxxv_rec is general -
  -- means used to read record from both base and history tables
  l_old_history_yn              VARCHAR2(3);

-- /striping/
p_rule_code   OKC_RULE_DEFS_B.rule_code%TYPE;
p_appl_id     OKC_RULE_DEFS_B.application_id%TYPE;
p_dff_name    OKC_RULE_DEFS_B.descriptive_flexfield_name%TYPE;

--/rules migration/
g_application_id number;
  ----------------------------------------------------------------------------
  --PL/SQL Table to check the sections has already copied.
  --If Yes give the new scn_id
  ----------------------------------------------------------------------------
  TYPE sections_rec_type IS RECORD (
    old_scn_id		NUMBER := OKC_API.G_MISS_NUM,
    new_scn_id		NUMBER := OKC_API.G_MISS_NUM);
  TYPE	sections_tbl_type IS TABLE OF sections_rec_type
  INDEX	BY BINARY_INTEGER;
  g_sections	sections_tbl_type;

  --PL/SQL Table to check time value id has already copied.
  --If Yes give the new tve_id ----Begins
-------------------------------------------------------------------------------
  TYPE price_adjustments_rec_type IS RECORD (
    old_pat_id          NUMBER := OKC_API.G_MISS_NUM,
    new_pat_id          NUMBER := OKC_API.G_MISS_NUM);
  TYPE price_adjustments_tbl_type IS TABLE OF price_adjustments_rec_type
  INDEX BY BINARY_INTEGER;
  g_price_adjustments    price_adjustments_tbl_type;
  ----------------------------------------------------------------------------
  TYPE timevalues_rec_type IS RECORD (
    old_tve_id		NUMBER := OKC_API.G_MISS_NUM,
    new_tve_id		NUMBER := OKC_API.G_MISS_NUM);
  TYPE	timevalues_tbl_type IS TABLE OF timevalues_rec_type
  INDEX	BY BINARY_INTEGER;
  g_timevalues	timevalues_tbl_type;

  ----------------------------------------------------------------------------
  --PL/SQL Table to check the rule has already copied.
  --If Yes give the new rul_id ----Begins
  ----------------------------------------------------------------------------
  TYPE ruls_rec_type IS RECORD (
    old_rul_id		NUMBER := OKC_API.G_MISS_NUM,
    new_rul_id		NUMBER := OKC_API.G_MISS_NUM);
  TYPE	ruls_tbl_type IS TABLE OF ruls_rec_type
  INDEX	BY BINARY_INTEGER;
  g_ruls	ruls_tbl_type;

  ----------------------------------------------------------------------------
  --PL/SQL Table to check the party has already copied.
  --If Yes give the new cpl_id ----Begins
  ----------------------------------------------------------------------------
  TYPE party_rec_type IS RECORD (
    old_cpl_id		NUMBER := OKC_API.G_MISS_NUM,
    new_cpl_id		NUMBER := OKC_API.G_MISS_NUM);
  TYPE	party_tbl_type IS TABLE OF party_rec_type
  INDEX	BY BINARY_INTEGER;
  g_party	party_tbl_type;

  ----------------------------------------------------------------------------
  --Logic to check the event has already copied.
  --If Yes give the new cnh_id ----Begins
  ----------------------------------------------------------------------------
  TYPE events_rec_type IS RECORD (
    old_cnh_id		NUMBER := OKC_API.G_MISS_NUM,
    new_cnh_id		NUMBER := OKC_API.G_MISS_NUM);
  TYPE	events_tbl_type IS TABLE OF events_rec_type
  INDEX	BY BINARY_INTEGER;
  g_events	events_tbl_type;
  -- Added for Bug 1917514
  -- This variable identifies whether COPY called for Header or Line
  -- If it is called from HEader it will call OKS copy procedure with chr id
  -- and cle id NULL it means COPY is done for Contract HEader
  -- If it is called from Line it will call OKS copy procedure with chr id
  -- and cle id  it means COPY is done for specific Contract Line
  l_oks_copy  VARCHAR2(1) := 'Y';

  ----------------------------------------------------------------------------
  -- PL/SQL table to keep line/header id and corresponding ole_id
  -- This table will store the following combinations
  --                 Header Id  - OLE_ID for Header
  --                 Line ID    - OLE_ID for the Line
  -- To get PARENT_OLE_ID for top line, search for ID = header_id
  --                      for sub line, search for ID = Parent Line Id
  ----------------------------------------------------------------------------
  TYPE line_op_rec_type IS RECORD (
    id                           NUMBER := OKC_API.G_MISS_NUM,
    ole_id                       NUMBER := OKC_API.G_MISS_NUM);

  TYPE line_op_tbl_type IS TABLE OF line_op_rec_type
    INDEX BY BINARY_INTEGER;

  g_op_lines line_op_tbl_type;

  FUNCTION Is_Number(p_string VARCHAR2) Return BOOLEAN IS
    n NUMBER;
  BEGIN
    n := to_number(p_string);
    return TRUE;
  EXCEPTION
    WHEN OTHERS THEN
         return FALSE;
  END;

  -- Added for Bug 1917514
  -- p_pdf id is for Process Defn id for OKS seeded procedure
  -- p_chr_id is Contract id (always required) for Contract Header Copy
  -- p_cle_id is Contract Line id (optional ) for Contract Header Copy it is
  -- NULL and for Contract Line Copy is is required

  -- Bugfix 2151523(1917514) - modified the name of the procedure from CREATE_PLSQL
  -- to OKC_CREATE_PLSQL
  PROCEDURE OKC_CREATE_PLSQL (p_pdf_id IN  NUMBER,
                          --  p_chr_id IN  NUMBER,  Bugfix 2151523(1917514) - variable not used
                          --  p_cle_id IN  NUMBER ,  Bugfix 2151523(1917514) - variable not used
                              x_string OUT NOCOPY VARCHAR2) IS

  l_string     VARCHAR2(2000);
--  l_chr_id     NUMBER;   Bugfix 2151523(1917514) - variable not used
--  l_cle_id     NUMBER;   Bugfix 2151523(1917514) - variable not used

   -- Cursor to get the package.procedure name from PDF
   CURSOR pdf_cur(l_pdf_id IN NUMBER) IS
   SELECT
   decode(pdf.pdf_type,'PPS',
          pdf.package_name||'.'||pdf.procedure_name,NULL) proc_name
   FROM okc_process_defs_v pdf
        -- bug 2112814 ,okc_process_def_parameters_v pdp
   WHERE pdf.id = l_pdf_id;

   pdf_rec pdf_cur%ROWTYPE;

/*  Bugfix 2151523(1917514) - Commented out nocopy as it is not being used
   -- Cursor to get the parameters defined for the package.procedure name from PDF
   CURSOR pdp_cur(l_pdf_id IN NUMBER) IS
   SELECT pdp.name param_name
   FROM okc_process_defs_v pdf,
        okc_process_def_parameters_v pdp
   WHERE pdf.id = l_pdf_id
   AND   pdf.id = pdp.pdf_id;

   pdp_rec pdp_cur%ROWTYPE;
*/
   BEGIN
      OPEN pdf_cur(p_pdf_id);
      FETCH pdf_cur INTO pdf_rec;
      CLOSE pdf_cur;

      l_string := l_string||pdf_rec.proc_name;
      x_string := l_string ;

  END OKC_CREATE_PLSQL;

  PROCEDURE add_events(	p_old_cnh_id IN NUMBER,
			p_new_cnh_id IN NUMBER) IS
    i 		NUMBER := 0;
  BEGIN
    IF g_events.COUNT > 0 THEN
      i := g_events.LAST;
    END IF;
    g_events(i+1).old_cnh_id	:= p_old_cnh_id;
    g_events(i+1).new_cnh_id	:= p_new_cnh_id;
  END add_events;

  FUNCTION get_new_cnh_id(	p_old_cnh_id IN NUMBER,
				p_new_cnh_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
  BEGIN
    IF g_events.COUNT > 0 THEN
      i := g_events.FIRST;
      LOOP
        IF g_events(i).old_cnh_id = p_old_cnh_id THEN
          p_new_cnh_id := g_events(i).new_cnh_id;
          RETURN TRUE;
        END IF;
        EXIT WHEN (i = g_events.LAST);
        i := g_events.NEXT(i);
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
  END get_new_cnh_id;
  ----------------------------------------------------------------------------
  --Logic to check the event has already copied.
  --If Yes give the new cnh_id ----Ends.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Logic to check the sections has already copied.
  --If Yes give the new scn_id ----Begins
  ----------------------------------------------------------------------------

  PROCEDURE add_sections(	p_old_scn_id IN NUMBER,
			p_new_scn_id IN NUMBER) IS
    i 		NUMBER := 0;
  BEGIN
    IF g_sections.COUNT > 0 THEN
      i := g_sections.LAST;
    END IF;
    g_sections(i+1).old_scn_id	:= p_old_scn_id;
    g_sections(i+1).new_scn_id	:= p_new_scn_id;
  END add_sections;

  FUNCTION get_new_scn_id(	p_old_scn_id IN NUMBER,
				p_new_scn_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
  BEGIN
    IF g_sections.COUNT > 0 THEN
      i := g_sections.FIRST;
      LOOP
        IF g_sections(i).old_scn_id = p_old_scn_id THEN
          p_new_scn_id := g_sections(i).new_scn_id;
          RETURN TRUE;
        END IF;
        EXIT WHEN (i = g_sections.LAST);
        i := g_sections.NEXT(i);
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
  END get_new_scn_id;

  PROCEDURE add_price_adjustments(       p_old_pat_id IN NUMBER,
                        p_new_pat_id IN NUMBER) IS
    i           NUMBER := 0;
  BEGIN
    IF g_price_adjustments.COUNT > 0 THEN
      i := g_price_adjustments.LAST;
    END IF;
    g_price_adjustments(i+1).old_pat_id  := p_old_pat_id;
    g_price_adjustments(i+1).new_pat_id  := p_new_pat_id;
  END add_price_adjustments;

  FUNCTION get_new_pat_id(      p_old_pat_id IN NUMBER,
                                p_new_pat_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i           NUMBER := 0;
  BEGIN
    IF g_price_adjustments.COUNT > 0 THEN
      i := g_price_adjustments.FIRST;
      LOOP
        IF g_price_adjustments(i).old_pat_id = p_old_pat_id THEN
          p_new_pat_id := g_price_adjustments(i).new_pat_id;
          RETURN TRUE;
        END IF;
        EXIT WHEN (i = g_price_adjustments.LAST);
        i := g_price_adjustments.NEXT(i);
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
  END get_new_pat_id;



  -----------------------------------------------------------------------------
  -- Logic to check the timevalues has already copied.
  -- If Yes give the new tve_id
  -----------------------------------------------------------------------------
  PROCEDURE add_timevalues(p_old_tve_id IN NUMBER,
			p_new_tve_id IN NUMBER) IS
    i 		NUMBER := 0;
  BEGIN
    IF g_timevalues.COUNT > 0 THEN
      i := g_timevalues.LAST;
    END IF;
    g_timevalues(i+1).old_tve_id	:= p_old_tve_id;
    g_timevalues(i+1).new_tve_id	:= p_new_tve_id;
  END add_timevalues;

  FUNCTION get_new_tve_id(p_old_tve_id IN NUMBER,
				      p_new_tve_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
  BEGIN

    IF g_timevalues.COUNT > 0 THEN
      i := g_timevalues.FIRST;
      LOOP
        IF g_timevalues(i).old_tve_id = p_old_tve_id THEN
          p_new_tve_id := g_timevalues(i).new_tve_id;
          RETURN TRUE;
        END IF;
        EXIT WHEN (i = g_timevalues.LAST);
        i := g_timevalues.NEXT(i);
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
  END get_new_tve_id;

  ----------------------------------------------------------------------------
  --Logic to check the rul has already copied.
  --If Yes give the new scn_id
  ----------------------------------------------------------------------------
  --Logic to check the rule has already copied.
  --If Yes give the new rul_id
  ----------------------------------------------------------------------------

  PROCEDURE add_ruls(	p_old_rul_id IN NUMBER,
			p_new_rul_id IN NUMBER) IS
    i 		NUMBER := 0;
  BEGIN
    IF g_ruls.COUNT > 0 THEN
      i := g_ruls.LAST;
    END IF;
    g_ruls(i+1).old_rul_id	:= p_old_rul_id;
    g_ruls(i+1).new_rul_id	:= p_new_rul_id;
  END add_ruls;

  FUNCTION get_new_rul_id(	p_old_rul_id IN NUMBER,
				p_new_rul_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
  BEGIN
    IF g_ruls.COUNT > 0 THEN
      i := g_ruls.FIRST;
      LOOP
        IF g_ruls(i).old_rul_id = p_old_rul_id THEN
          p_new_rul_id := g_ruls(i).new_rul_id;
          RETURN TRUE;
        END IF;
        EXIT WHEN (i = g_ruls.LAST);
        i := g_ruls.NEXT(i);
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
  END get_new_rul_id;
  ----------------------------------------------------------------------------
  --Logic to check the rul has already copied.
  --If Yes give the new rul_id ----Ends.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Logic to check the party has already copied.
  --If Yes give the new cpl_id ----Begins
  ----------------------------------------------------------------------------

  PROCEDURE add_party(	p_old_cpl_id IN NUMBER,
			p_new_cpl_id IN NUMBER) IS
    i 		NUMBER := 0;
  BEGIN
    IF g_party.COUNT > 0 THEN
      i := g_party.LAST;
    END IF;
    g_party(i+1).old_cpl_id	:= p_old_cpl_id;
    g_party(i+1).new_cpl_id	:= p_new_cpl_id;
  END add_party;

  FUNCTION get_new_cpl_id(	p_old_cpl_id IN NUMBER,
				p_new_cpl_id OUT NOCOPY NUMBER) RETURN BOOLEAN IS
    i 		NUMBER := 0;
  BEGIN
    IF g_party.COUNT > 0 THEN
      i := g_party.FIRST;
      LOOP
        IF g_party(i).old_cpl_id = p_old_cpl_id THEN
          p_new_cpl_id := g_party(i).new_cpl_id;
          RETURN TRUE;
        END IF;
        EXIT WHEN (i = g_party.LAST);
        i := g_party.NEXT(i);
      END LOOP;
      RETURN FALSE;
    END IF;
    RETURN FALSE;
  END get_new_cpl_id;
  ----------------------------------------------------------------------------
  --Logic to check the party has already copied.
  --If Yes give the new cpl_id ----Ends.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Function specs  to populate pl/sql record with database values begins
  ----------------------------------------------------------------------------
    FUNCTION    get_atnv_rec(p_atn_id IN NUMBER,
				x_atnv_rec OUT NOCOPY atnv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_catv_rec(p_cat_id IN NUMBER,
				x_catv_rec OUT NOCOPY catv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cimv_rec(p_cim_id IN NUMBER,
				x_cimv_rec OUT NOCOPY cimv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cacv_rec(p_cac_id IN NUMBER,
				x_cacv_rec OUT NOCOPY cacv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cplv_rec(p_cpl_id IN NUMBER,
				x_cplv_rec OUT NOCOPY cplv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cpsv_rec(p_cps_id IN NUMBER,
				x_cpsv_rec OUT NOCOPY cpsv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cgcv_rec(p_cgc_id IN NUMBER,
				x_cgcv_rec OUT NOCOPY cgcv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cnhv_rec(p_cnh_id IN NUMBER,
				x_cnhv_rec OUT NOCOPY cnhv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_cnlv_rec(p_cnl_id IN NUMBER,
				x_cnlv_rec OUT NOCOPY cnlv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_rgpv_rec(p_rgp_id IN NUMBER,
				x_rgpv_rec OUT NOCOPY rgpv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_rulv_rec(p_rul_id IN NUMBER,
				x_rulv_rec OUT NOCOPY rulv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_clev_rec(p_cle_id IN NUMBER,
                             p_renew_ref_yn IN VARCHAR2, -- Added for bugfix 2307197
				x_clev_rec OUT NOCOPY clev_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_chrv_rec(p_chr_id IN NUMBER,
				x_chrv_rec OUT NOCOPY chrv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_tvev_rec(p_tve_id IN NUMBER,
				x_tvev_rec OUT NOCOPY tvev_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_ctcv_rec(p_ctc_id IN NUMBER,
				x_ctcv_rec OUT NOCOPY ctcv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_ocev_rec(p_oce_id IN NUMBER,
				x_ocev_rec OUT NOCOPY ocev_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_oatv_rec(p_oat_id IN NUMBER,
				x_oatv_rec OUT NOCOPY oatv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_pavv_rec(p_pav_id IN NUMBER,
				x_pavv_rec OUT NOCOPY pavv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_patv_rec(p_pat_id IN NUMBER,
                                x_patv_rec OUT NOCOPY patv_rec_type) RETURN  VARCHAR2;

    FUNCTION    get_paav_rec(p_paa_id IN NUMBER,
                                x_paav_rec OUT NOCOPY paav_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_pacv_rec(p_pac_id IN NUMBER,
                                x_pacv_rec OUT NOCOPY pacv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_scnv_rec(p_scn_id IN NUMBER,
				x_scnv_rec OUT NOCOPY scnv_rec_type) RETURN  VARCHAR2;
    FUNCTION    get_sccv_rec(p_scc_id IN NUMBER,
				x_sccv_rec OUT NOCOPY sccv_rec_type) RETURN  VARCHAR2;
  ----------------------------------------------------------------------------
  --Function specs  to populate pl/sql record with database values ends
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Procedure  desides whether target contract is updateable or not
  ----------------------------------------------------------------------------

  FUNCTION is_copy_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2 ) RETURN BOOLEAN IS
    l_count		NUMBER;
    l_dummy         VARCHAR2(1) := '?';
    l_term_dummy         VARCHAR2(1) := '?';
    l_cancel_dummy         VARCHAR2(1) := '?';
    l_template_yn	VARCHAR2(3);

    CURSOR c_template IS
    SELECT template_yn
    FROM okc_k_headers_b
    WHERE id = p_chr_id;

    CURSOR invalid_template IS
    SELECT '1'
    FROM okc_k_headers_b
    WHERE template_yn = 'Y'
	AND nvl(end_date, sysdate+1) >= trunc(sysdate)
	AND id = p_chr_id;

	/*hkamdar 12-12-2005 Commented as this check is not required for source contract.
	-- Bug #4693415 28-Nov-2005 hkamdar
    CURSOR term_cntr IS
    SELECT '1'
    FROM  okc_k_headers_b
    WHERE id = p_chr_id
      AND date_terminated IS NOT NULL
	 AND date_terminated <= SYSDATE;

    CURSOR cancel_cntr IS
    SELECT '1'
    FROM   okc_k_headers_b hdr, okc_statuses_b status
    WHERE  hdr.id = p_chr_id
      AND  hdr.sts_code = status.code
      AND  status.ste_code = 'CANCELLED';
	 */
  BEGIN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' IS_Copy_Allowed ');
   OKC_DEBUG.log('1001 : Entering  IS_Copy_Allowed  ', 2);
END IF;

    OPEN c_template;
    FETCH c_template INTO l_template_yn;
    CLOSE c_template;

    If l_template_yn = 'Y' Then
      OPEN invalid_template;
      FETCH invalid_template INTO l_dummy;
      CLOSE invalid_template;

      If l_dummy = '1' Then
	   IF (l_debug = 'Y') THEN
   	   OKC_DEBUG.ReSet_Indentation;
	   END IF;
	   RETURN(TRUE);
      Else
	   OKC_API.SET_MESSAGE('OKC', 'OKC_INVALID_TEMPLATE');
	   IF (l_debug = 'Y') THEN
   	   OKC_DEBUG.ReSet_Indentation;
	   END IF;
        RETURN(FALSE);
      End If;
    Else

	 IF (l_debug = 'Y') THEN
   	 OKC_DEBUG.ReSet_Indentation;
	 END IF;
	 RETURN(TRUE);
    End If;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1001 : Exiting Function IS_Copy_Allowed ', 2);
   OKC_DEBUG.ReSet_Indentation;
END IF;

  END is_copy_allowed;


  FUNCTION is_subcontract_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS

    l_sts_code VARCHAR2(100);
    l_cls_code VARCHAR2(100);
    l_scs_code VARCHAR2(100);
    l_template_yn VARCHAR2(10);
    l_code VARCHAR2(100);

    CURSOR c_chr IS
    SELECT sts_code,template_yn,scs_code
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    CURSOR c_sts(p_code IN VARCHAR2) IS
    SELECT ste_code
    FROM   okc_statuses_b
    WHERE  code = p_code;

    CURSOR c_class(p_scs_code IN VARCHAR2) IS
    SELECT cls_code
    FROM   okc_subclasses_b
    WHERE  code = p_scs_code;

  BEGIN

    OPEN c_chr;
    FETCH c_chr INTO l_code,l_template_yn,l_scs_code;
    CLOSE c_chr;

    IF l_template_yn = 'Y' then
	 RETURN(FALSE);
    END IF;

    OPEN c_class(l_scs_code);
    FETCH c_class INTO l_cls_code;
    CLOSE c_class;

    If l_cls_code = 'SERVICE' THEN
      RETURN(FALSE);
    END IF;

    OPEN c_sts(l_code);
    FETCH c_sts INTO l_sts_code;
    CLOSE c_sts;

    IF l_sts_code in ('ENTERED','SIGNED','ACTIVE') THEN
      RETURN(TRUE);
    ELSE
      RETURN(FALSE);
    END IF;
  END is_subcontract_allowed;

  FUNCTION update_target_contract(p_chr_id IN NUMBER) RETURN BOOLEAN IS
    l_in_process_yn         VARCHAR2(1) := '?';
    l_user_id               NUMBER;
    l_current_user_id       NUMBER := FND_GLOBAL.USER_ID;

    CURSOR  c_locked_user(p_chr_id IN NUMBER) IS
    SELECT  cps.user_id,
            upper(substr(cps.in_process_yn,1,1)) in_process_yn
    FROM    okc_k_processes_v cps,
            okc_change_requests_b crt
    WHERE   crt.id = cps.crt_id
    AND     crt.chr_id = p_chr_id;

  BEGIN
    IF p_chr_id IS NOT NULL THEN

	 -- No update allowed if process is active for the contract
	 If (OKC_CONTRACT_PVT.Is_Process_Active(p_chr_id) = 'Y') Then
         RETURN(FALSE);
      End If;
      IF OKC_ASSENT_PUB.HEADER_OPERATION_ALLOWED(p_chr_id,'UPDATE') = 'T' THEN
        OPEN c_locked_user(p_chr_id);
        FETCH c_locked_user INTO l_user_id,l_in_process_yn;
        IF c_locked_user%NOTFOUND THEN --No change request
           RETURN(TRUE);
        END IF;
        LOOP
          IF l_user_id = l_current_user_id and l_in_process_yn = 'Y' THEN --locked by same user
             RETURN(TRUE);
          ELSIF l_user_id <> l_current_user_id and l_in_process_yn = 'Y' THEN -- locked be same user
             RETURN(FALSE);
          END IF;
          FETCH c_locked_user INTO l_user_id,l_in_process_yn;
          EXIT WHEN c_locked_user%NOTFOUND;
        END LOOP;
        -- If it comes out of the loop then "No Lock"
        RETURN(TRUE);
      ELSIF OKC_ASSENT_PUB.HEADER_OPERATION_ALLOWED(p_chr_id,'CHG_REQ') = 'T' THEN
        OPEN c_locked_user(p_chr_id);
        FETCH c_locked_user INTO l_user_id,l_in_process_yn;
        IF c_locked_user%NOTFOUND THEN --No change request
           RETURN(FALSE);
        END IF;
        LOOP
          IF l_user_id = l_current_user_id and l_in_process_yn = 'Y' THEN --locked by same user
             RETURN(TRUE);
          ELSIF l_user_id <> l_current_user_id and l_in_process_yn = 'Y' THEN -- locked be same user
             RETURN(FALSE);
          END IF;
          FETCH c_locked_user INTO l_user_id,l_in_process_yn;
          EXIT WHEN c_locked_user%NOTFOUND;
        END LOOP;
        -- If it comes out of the loop then "No Lock"
        RETURN(FALSE);
      END IF;
      RETURN(FALSE);
    END IF;
    RETURN(FALSE);
  END update_target_contract;
  ----------------------------------------------------------------------------
  --Procedure  to derive a compatible line style
  ----------------------------------------------------------------------------

  PROCEDURE derive_line_style(p_old_lse_id     IN  NUMBER,
                              p_old_jtot_code  IN  VARCHAR2,
                              p_new_subclass   IN  VARCHAR2,
                              p_new_parent_lse IN  NUMBER,
                              x_new_lse_count  OUT NOCOPY NUMBER,
                              x_new_lse_ids    OUT NOCOPY VARCHAR2) IS
    l_lty_code     VARCHAR2(30);
    l_lse_id 	   NUMBER;
    l_recursive_yn VARCHAR2(1);
    l_new_lse_ids  VARCHAR2(2000);
    l_new_lse_count NUMBER := 0;

-- Modified Cursor for Bug 1993566
-- Getting recursive flag for line styles

    CURSOR c_lty_code IS
    SELECT lty_code,recursive_yn
    FROM   okc_line_styles_b
    WHERE  id = p_old_lse_id;

--    Commented for Bug 1993566
--    CURSOR c_lty_code IS
--    SELECT lty_code,recursive_yn
--    FROM   okc_line_styles_b
--    WHERE  id = p_old_lse_id;

/*
    CURSOR c_top_lse_lty(p_lty_code IN VARCHAR2) IS
    SELECT lse.id
    FROM   okc_subclass_top_line_v stl,
           okc_line_styles_b lse
    WHERE  stl.lse_id = lse.id
    AND    lse.lty_code = p_lty_code
    AND    stl.scs_code = p_new_subclass;
*/

-- added Sanjay  for bug # 1923216

    CURSOR c_top_lse_lty(p_lty_code IN VARCHAR2) IS
    SELECT lse.id
    FROM   okc_subclass_top_line_v stl,
           okc_line_styles_b lse
    WHERE  stl.lse_id = lse.id
    AND    lse.id = p_old_lse_id  -- added
    AND    lse.lty_code = p_lty_code
    AND    stl.scs_code = p_new_subclass
    AND    sysdate BETWEEN stl.start_date and nvl(stl.end_date,sysdate);  -- added

-- end added by Sanjay for bug # 1923216

    CURSOR c_sub_lse_lty(p_lty_code IN VARCHAR2) IS
    SELECT lse.id
    FROM   okc_line_styles_b lse
    WHERE  lse.lty_code = p_lty_code
    AND    lse.lse_parent_id = p_new_parent_lse;

    FUNCTION get_source(p_lse_id IN NUMBER) RETURN VARCHAR2 IS

      l_source VARCHAR2(30);

      CURSOR c_source(p_lse_id IN NUMBER) IS
      SELECT jtot_object_code
      FROM   okc_line_style_sources_v
      WHERE  lse_id = p_lse_id
      AND    sysdate BETWEEN start_date and nvl(end_date,sysdate);

    BEGIN
      OPEN  c_source(p_lse_id);
      FETCH c_source INTO l_source;
      CLOSE c_source;
      RETURN(l_source);
    END get_source;

  BEGIN
    OPEN  c_lty_code;
    FETCH c_lty_code INTO l_lty_code,l_recursive_yn;
    CLOSE c_lty_code;

    -- Added for Bug 1993566
    -- Checking recursive flag , if it is 'Y' then
    -- it simply return same lse id as the parent lse id
    IF l_recursive_yn = 'Y' THEN
         OPEN c_top_lse_lty(l_lty_code);
         FETCH c_top_lse_lty INTO l_lse_id;
         CLOSE c_top_lse_lty;
         l_new_lse_count := l_new_lse_count + 1;
         l_new_lse_ids := '('||to_char(l_lse_id) ||')';
           x_new_lse_count := l_new_lse_count;
           x_new_lse_ids := l_new_lse_ids;
         RETURN;
    END IF;
    -- Added for Bug 1993566


    IF p_new_parent_lse IS NULL THEN
      OPEN c_top_lse_lty(l_lty_code);
      FETCH c_top_lse_lty INTO l_lse_id;
      IF c_top_lse_lty%NOTFOUND THEN
        CLOSE c_top_lse_lty;
        RETURN;
      ELSE
        IF NVL(p_old_jtot_code,'!!') = NVL(get_source(l_lse_id),'!!') THEN
            l_new_lse_count := l_new_lse_count + 1;
            l_new_lse_ids := '('||to_char(l_lse_id);
        END IF;
      END IF;
      LOOP
        FETCH c_top_lse_lty INTO l_lse_id;
        EXIT WHEN c_top_lse_lty%NOTFOUND;
        IF NVL(p_old_jtot_code,'!!') = NVL(get_source(l_lse_id),'!!') THEN
          l_new_lse_count := l_new_lse_count + 1;
          l_new_lse_ids := l_new_lse_ids||','||to_char(l_lse_id);
        END IF;
      END LOOP;
      IF c_top_lse_lty%ISOPEN THEN
        CLOSE c_top_lse_lty;
      END IF;
      l_new_lse_ids := l_new_lse_ids||')';

      x_new_lse_count := l_new_lse_count;
      x_new_lse_ids := l_new_lse_ids;
    ELSE
      OPEN c_sub_lse_lty(l_lty_code);
      FETCH c_sub_lse_lty INTO l_lse_id;
      IF c_sub_lse_lty%NOTFOUND THEN
        CLOSE c_sub_lse_lty;
        RETURN;
      ELSE
        IF NVL(p_old_jtot_code,'!!') = NVL(get_source(l_lse_id),'!!') THEN
            l_new_lse_count := l_new_lse_count + 1;
            l_new_lse_ids := '('||to_char(l_lse_id);
        END IF;
      END IF;
      LOOP
        FETCH c_sub_lse_lty INTO l_lse_id;
        EXIT WHEN c_sub_lse_lty%NOTFOUND;
        IF NVL(p_old_jtot_code,'!!') = NVL(get_source(l_lse_id),'!!') THEN
          l_new_lse_count := l_new_lse_count + 1;
		IF l_new_lse_ids is null THEN
		   l_new_lse_ids := '('||to_char(l_lse_id);
          ELSE
             l_new_lse_ids := l_new_lse_ids||','||to_char(l_lse_id);
          END IF;
        END IF;
      END LOOP;
      IF c_sub_lse_lty%ISOPEN THEN
        CLOSE c_sub_lse_lty;
      END IF;
      l_new_lse_ids := l_new_lse_ids||')';

      x_new_lse_count := l_new_lse_count;
      x_new_lse_ids := l_new_lse_ids;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error

  END derive_line_style;

  ----------------------------------------------------------------------------
  --Procedure spec  to copy time values.
  ----------------------------------------------------------------------------
  PROCEDURE copy_timevalues(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tve_id                  	   IN NUMBER,
    p_to_chr_id                    IN NUMBER ,
    p_to_template_yn               IN VARCHAR2,
    x_tve_id		           OUT NOCOPY NUMBER);

  ----------------------------------------------------------------------------
  --Procedure copy_sections - Makes a copy of the okc_sections and okc_section_contents.
  ----------------------------------------------------------------------------
  PROCEDURE copy_sections(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scc_id                       IN NUMBER,
    p_to_cat_id                    IN NUMBER,
    p_to_chr_id                    IN NUMBER,
    p_scn_id					IN NUMBER) IS

    l_scn_id    	NUMBER;
    l_scn_id_new    NUMBER;
    l_scn_id_out    NUMBER;
    l_scn_count 	NUMBER := 0;

    l_sccv_rec 	sccv_rec_type;
    x_sccv_rec 	sccv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    TYPE sec_rec_type IS RECORD (
      scn_id		NUMBER := OKC_API.G_MISS_NUM);
    TYPE	sec_tbl_type IS TABLE OF sec_rec_type
    INDEX	BY BINARY_INTEGER;
    l_sec	sec_tbl_type;

    CURSOR c_scc IS
    SELECT scn_id
    FROM   okc_section_contents_v
    WHERE  id = p_scc_id;

    CURSOR c_scn(p_scn_id IN NUMBER) IS
    SELECT id,level
    FROM   okc_sections_b
    CONNECT BY PRIOR scn_id = id
    START WITH id = p_scn_id;

    PROCEDURE copy_section(
       p_api_version                  IN NUMBER,
       p_init_msg_list                IN VARCHAR2 ,
       x_return_status                OUT NOCOPY VARCHAR2,
       x_msg_count                    OUT NOCOPY NUMBER,
       x_msg_data                     OUT NOCOPY VARCHAR2,
       p_scn_id                       IN NUMBER,
       p_to_chr_id                    IN NUMBER,
       x_scn_id                       OUT NOCOPY NUMBER) IS


      l_new_scn_id      	NUMBER;
      l_scnv_rec 		scnv_rec_type;
      x_scnv_rec 		scnv_rec_type;
      l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
      x_return_status := l_return_status;
      IF get_new_scn_id(p_scn_id,l_new_scn_id) THEN
        x_scn_id := l_new_scn_id;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_return_status := get_scnv_rec(	p_scn_id 	=> p_scn_id,
							x_scnv_rec 	=> l_scnv_rec);

      l_scnv_rec.chr_id := p_to_chr_id;

      IF get_new_scn_id(l_scnv_rec.scn_id,l_new_scn_id) THEN
        l_scnv_rec.scn_id := l_new_scn_id;
      ELSE
        l_scnv_rec.scn_id := null;
      END IF;

      OKC_SECTIONS_PUB.create_section(
	   	 p_api_version		=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_scnv_rec		=> l_scnv_rec,
           x_scnv_rec		=> x_scnv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	 x_return_status := l_return_status;
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      x_scn_id := x_scnv_rec.id;

      add_sections(p_scn_id,x_scnv_rec.id); --adds the new section id in the global PL/SQL table.

    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END copy_section;

  BEGIN
    x_return_status := l_return_status;
    -- Execute below If statement only if the procedure is called from
    -- copy_articles
    If p_scc_id IS NOT NULL Then
      OPEN c_scc;
    	 FETCH c_scc INTO l_scn_id;
      CLOSE c_scc;

      FOR l_c_scn IN c_scn(l_scn_id) LOOP
        l_sec(l_c_scn.level).scn_id := l_c_scn.id;
        l_scn_count := l_c_scn.level;
      END LOOP;
    End If;

    -- Execute below If statement only if this procedure is called from
    -- copy_other_sections
    If p_scn_id IS NOT NULL Then
	  l_scn_count := 1;
	  l_sec(1).scn_id := p_scn_id;
    End If;

    FOR i IN REVERSE 1 .. l_scn_count LOOP
       copy_section (
	   	 p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_scn_id			=> l_sec(i).scn_id,
           p_to_chr_id		=> p_to_chr_id,
           x_scn_id			=> l_scn_id_out);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
     END LOOP;

    -- Execute below If statement only if called from copy_articles procedure
    If p_scc_id IS NOT NULL Then
      l_return_status := get_sccv_rec(	p_scc_id 	=> p_scc_id,
							x_sccv_rec 	=> l_sccv_rec);

      IF get_new_scn_id(l_scn_id,l_scn_id_new) THEN
        l_sccv_rec.scn_id := l_scn_id_new;
      ELSE
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_sccv_rec.cat_id := p_to_cat_id;

      OKC_SECTIONS_PUB.create_section_content(
	   	 p_api_version		=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_sccv_rec		=> l_sccv_rec,
           x_sccv_rec		=> x_sccv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
   End If;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END copy_sections;

  ----------------------------------------------------------------------------
  -- Proceudre copy_cover_times - Makes a copy of cover times
  ----------------------------------------------------------------------------
  PROCEDURE copy_cover_times(
       p_api_version     IN NUMBER,
       p_init_msg_list   IN VARCHAR2 ,
       x_return_status   OUT NOCOPY VARCHAR2,
       x_msg_count       OUT NOCOPY NUMBER,
       x_msg_data        OUT NOCOPY VARCHAR2,
	  p_to_template_yn  IN VARCHAR2,
       p_from_rul_id     IN NUMBER,
       p_to_rul_id       IN NUMBER,
	  p_chr_id		IN NUMBER,
       p_cle_id         	IN NUMBER,
       p_to_chr_id       IN NUMBER) IS

      Cursor l_ctiv_csr Is
		SELECT tve_id
		FROM okc_cover_times_v
		WHERE RUL_ID = p_from_rul_id;

      l_new_tve_id	NUMBER;
      l_ctiv_rec 	ctiv_rec_type;
      x_ctiv_rec 	ctiv_rec_type;
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -------------------------------------------------------------------------
    -- get all cover times records from okc_cover_times_v
    -- if timevalue not copied, copy time value
    -- copy cover time record
    -------------------------------------------------------------------------

      x_return_status := l_return_status;

	 FOR l_csr IN l_ctiv_csr
	 LOOP
	    -- check if the time value already copied
	    If (get_new_tve_id(l_csr.TVE_ID, l_new_tve_id)) Then
		  l_ctiv_rec.TVE_ID := l_new_tve_id;
         Else
		 -- if time value not copied , copy now
           copy_timevalues (
      	      p_api_version	   => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => l_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_tve_id		   => l_csr.TVE_ID,
                p_to_chr_id	   => p_to_chr_id,
	           p_to_template_yn => p_to_template_yn,
                x_tve_id	        => l_new_tve_id);

             IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
	               x_return_status := l_return_status;
                END IF;
             END IF;
		   add_timevalues(l_ctiv_rec.TVE_ID,l_new_tve_id);
		   l_ctiv_rec.TVE_ID := l_new_tve_id;
         End If;
	    l_ctiv_rec.DNZ_CHR_ID := p_to_chr_id;
	    l_ctiv_rec.RUL_ID := p_to_rul_id;

         OKC_RULE_PUB.create_cover_time(
	         p_api_version	=> p_api_version,
              p_init_msg_list	=> p_init_msg_list,
              x_return_status => l_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_ctiv_rec		=> l_ctiv_rec,
              x_ctiv_rec		=> x_ctiv_rec);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
	           x_return_status := l_return_status;
            END IF;
         END IF;

	 END LOOP;

  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END copy_cover_times;

  ----------------------------------------------------------------------------
  -- Proceudre copy_react_intervals - Makes copy of react_intervals
  ----------------------------------------------------------------------------
  PROCEDURE copy_react_intervals(
       p_api_version     IN NUMBER,
       p_init_msg_list   IN VARCHAR2 ,
       x_return_status   OUT NOCOPY VARCHAR2,
       x_msg_count       OUT NOCOPY NUMBER,
       x_msg_data        OUT NOCOPY VARCHAR2,
	  p_to_template_yn  IN VARCHAR2,
       p_from_rul_id     IN NUMBER,
       p_to_rul_id       IN NUMBER,
	  p_chr_id		IN NUMBER,
       p_cle_id         	IN NUMBER,
       p_to_chr_id       IN NUMBER) IS

      Cursor l_rilv_csr Is
		SELECT tve_id,
			  uom_code,
			  duration
		FROM okc_react_intervals_v
		WHERE RUL_ID = p_from_rul_id;

      l_new_tve_id	NUMBER;
      l_rilv_rec 	rilv_rec_type;
      x_rilv_rec 	rilv_rec_type;
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -------------------------------------------------------------------------
    -- get all react interval records from okc_react_intervals_v
    -- if timevalue not copied, copy time value
    -- copy react interval record
    -------------------------------------------------------------------------

      x_return_status := l_return_status;

	 FOR l_csr IN l_rilv_csr
	 LOOP
	    -- check if the time value already copied
	    If (get_new_tve_id(l_csr.TVE_ID, l_new_tve_id)) Then
		  l_rilv_rec.TVE_ID := l_new_tve_id;
         Else
		 -- if time value not copied , copy now
           copy_timevalues (
      	      p_api_version	   => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => l_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_tve_id		   => l_csr.TVE_ID,
                p_to_chr_id	   => p_to_chr_id,
	           p_to_template_yn => p_to_template_yn,
                x_tve_id	        => l_new_tve_id);

             IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
	               x_return_status := l_return_status;
                END IF;
             END IF;
		   add_timevalues(l_rilv_rec.TVE_ID,l_new_tve_id);
		   l_rilv_rec.TVE_ID := l_new_tve_id;
         End If;
	    l_rilv_rec.DNZ_CHR_ID := p_to_chr_id;
	    l_rilv_rec.RUL_ID := p_to_rul_id;
	    l_rilv_rec.uom_code := l_csr.uom_code;
	    l_rilv_rec.duration := l_csr.duration;

         OKC_RULE_PUB.create_react_interval(
	         p_api_version	=> p_api_version,
              p_init_msg_list	=> p_init_msg_list,
              x_return_status => l_return_status,
              x_msg_count     => x_msg_count,
              x_msg_data      => x_msg_data,
              p_rilv_rec		=> l_rilv_rec,
              x_rilv_rec		=> x_rilv_rec);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
	           x_return_status := l_return_status;
            END IF;
         END IF;

	 END LOOP;

  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END copy_react_intervals;

  --------------------------------------------------------------------------
  --Proceudre copy_accesses - Makes a copy of the okc_k_accesses.
  --------------------------------------------------------------------------
  PROCEDURE copy_accesses(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id                    IN NUMBER) IS

    l_cacv_rec 	cacv_rec_type;
    x_cacv_rec 	cacv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_access IS
    SELECT 	id
    FROM 	okc_k_accesses_v
    WHERE 	chr_id = p_from_chr_id;

  BEGIN
    x_return_status := l_return_status;
    FOR l_c_access IN c_access LOOP
      l_return_status := get_cacv_rec(	p_cac_id 	=> l_c_access.id,
					x_cacv_rec 	=> l_cacv_rec);
      l_cacv_rec.chr_id := p_to_chr_id;

      OKC_CONTRACT_PUB.create_contract_access(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cacv_rec		=> l_cacv_rec,
           x_cacv_rec		=> x_cacv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_accesses;

  ----------------------------------------------------------------------------
  --Proceudre copy_processes - Makes a copy of the okc_k_processes.
  ----------------------------------------------------------------------------
  PROCEDURE copy_processes(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id                    IN NUMBER) IS

    l_cpsv_rec 	cpsv_rec_type;
    x_cpsv_rec 	cpsv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_process IS
    SELECT 	id
    FROM 	okc_k_processes_v
    WHERE 	chr_id = p_from_chr_id;

  BEGIN
    x_return_status := l_return_status;
    FOR l_c_process IN c_process LOOP
      l_return_status := get_cpsv_rec(	p_cps_id 	=> l_c_process.id,
					x_cpsv_rec 	=> l_cpsv_rec);
      l_cpsv_rec.chr_id := p_to_chr_id;
      l_cpsv_rec.process_id := NULL;

      OKC_CONTRACT_PUB.create_contract_process(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cpsv_rec		=> l_cpsv_rec,
           x_cpsv_rec		=> x_cpsv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_processes;

  ----------------------------------------------------------------------------
  --Proceudre copy_grpings - Makes a copy of the okc_k_grpings.
  ----------------------------------------------------------------------------
  PROCEDURE copy_grpings(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id                    IN NUMBER) IS

    l_cgcv_rec 	cgcv_rec_type;
    x_cgcv_rec 	cgcv_rec_type;
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_grpings IS
    SELECT 	cgcv.id
    FROM 	     okc_k_grpings_v cgcv,
               okc_k_groups_b cgpv
    WHERE 	cgcv.included_chr_id = p_from_chr_id
    AND        cgcv.cgp_parent_id = cgpv.id
    AND        (cgpv.public_yn = 'Y' OR cgpv.user_id = fnd_global.user_id);

  BEGIN
    x_return_status := l_return_status;
    FOR l_c_grpings IN c_grpings LOOP
      l_return_status := get_cgcv_rec(	p_cgc_id 	=> l_c_grpings.id,
					x_cgcv_rec 	=> l_cgcv_rec);
      l_cgcv_rec.included_chr_id := p_to_chr_id;

      OKC_CONTRACT_GROUP_PUB.create_contract_grpngs(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cgcv_rec		=> l_cgcv_rec,
           x_cgcv_rec		=> x_cgcv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_grpings;

  /*******************************************************************************
   This used to make a copy of goverances only at the header level
   We have replaced it by code that copies at both header and line level
  --------------------------------------------------------------------------
  --Proceudre copy_governances - Makes a copy of the okc_governances.
  --------------------------------------------------------------------------
  PROCEDURE copy_governances(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id                    IN NUMBER) IS

    l_gvev_rec 	gvev_rec_type;
    x_gvev_rec 	gvev_rec_type;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR 	c_governances IS
    SELECT 	id
    FROM 		okc_governances_v
    WHERE 	dnz_chr_id = p_from_chr_id
    AND		cle_id is null;

  ----------------------------------------------------------------------------
  --Function to populate the contract governance record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION get_gvev_rec(p_gve_id IN NUMBER,
				      x_gvev_rec OUT NOCOPY gvev_rec_type)
    RETURN  VARCHAR2 IS
      l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_gvev_rec IS
      SELECT
	    DNZ_CHR_ID,
	    ISA_AGREEMENT_ID,
	    CHR_ID,
	    CLE_ID,
	    CHR_ID_REFERRED,
	    CLE_ID_REFERRED,
	    COPIED_ONLY_YN
	 FROM    OKC_GOVERNANCES
	 WHERE 	ID = p_gve_id;
    BEGIN
      OPEN c_gvev_rec;
      FETCH c_gvev_rec
      INTO x_gvev_rec.DNZ_CHR_ID,
		x_gvev_rec.ISA_AGREEMENT_ID,
		x_gvev_rec.CHR_ID,
		x_gvev_rec.CLE_ID,
		x_gvev_rec.CHR_ID_REFERRED,
		x_gvev_rec.CLE_ID_REFERRED,
		x_gvev_rec.COPIED_ONLY_YN;

      l_no_data_found := c_gvev_rec%NOTFOUND;
      CLOSE c_gvev_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_gvev_rec;
  BEGIN
    x_return_status := l_return_status;
    FOR l_c_governances IN c_governances LOOP
      l_return_status := get_gvev_rec(	p_gve_id 	 => l_c_governances.id,
					               x_gvev_rec => l_gvev_rec);
      l_gvev_rec.chr_id := p_to_chr_id;
      l_gvev_rec.dnz_chr_id := p_to_chr_id;

      OKC_CONTRACT_PUB.create_governance(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_gvev_rec		=> l_gvev_rec,
           x_gvev_rec		=> x_gvev_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_governances;
  *******************************************************************************/

  ----------------------------------------------------------------------------
  --Procedure copy_articles - Makes a copy of the articles.
  ----------------------------------------------------------------------------
  PROCEDURE copy_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    p_sav_sav_release              IN VARCHAR2 ,
    x_cat_id		               OUT NOCOPY NUMBER) IS

    l_catv_rec 			catv_rec_type;
    x_catv_rec 			catv_rec_type;
    l_atnv_rec 			atnv_rec_type;
    x_atnv_rec 			atnv_rec_type;

    l_return_status	          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			     NUMBER := OKC_API.G_MISS_NUM;
    l_new_rul_id			NUMBER := OKC_API.G_MISS_NUM;

    CURSOR c_dnz_chr_id(p_id IN NUMBER) IS
    SELECT dnz_chr_id
    FROM okc_k_lines_b
    WHERE id = p_id;

    CURSOR c_atn(p_id IN NUMBER) IS
    SELECT id
    FROM   okc_article_trans_v
    WHERE  cat_id = p_id;

    CURSOR c_scc IS
    SELECT id
    FROM   okc_section_contents_v
    WHERE  cat_id = p_cat_id;

  BEGIN
    IF (l_debug = 'Y') THEN
       OKC_DEBUG.Set_Indentation('OKC_COPY_CONTRACT_PVT.Copy_Articles ');
       OKC_DEBUG.log('100 : Entering Copy_Articles ', 2);
       OKC_DEBUG.log('101 : p_cat_id: '||p_cat_id, 2);
       OKC_DEBUG.log('101 : p_cle_id: '||p_cle_id, 2);
       OKC_DEBUG.log('101 : p_chr_id: '||p_chr_id, 2);
       OKC_DEBUG.log('101 : p_sav_sav_release: '||p_sav_sav_release, 2);
    END IF;

    x_return_status := l_return_status;
    l_return_status := get_catv_rec(	p_cat_id 	=> p_cat_id,
					x_catv_rec 	=> l_catv_rec);

    IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('200 : get_catv_rec returns ' || l_return_status, 2);
    END IF;
    If p_sav_sav_release IS NOT NULL Then
       l_catv_rec.sav_sav_release := p_sav_sav_release;
    End If;

    IF p_chr_id IS NULL OR p_chr_id = OKC_API.G_MISS_NUM THEN
      OPEN c_dnz_chr_id(p_cle_id);
      FETCH c_dnz_chr_id INTO l_catv_rec.dnz_chr_id;
      CLOSE c_dnz_chr_id;
    ELSE
      l_catv_rec.dnz_chr_id := p_chr_id;
    END IF;

    l_catv_rec.id := NULL;
    l_catv_rec.chr_id := p_chr_id;
    l_catv_rec.cle_id := p_cle_id;

    IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('300 : calling OKC_K_ARTICLE_PUB.create_k_article ',2);
    END IF;
    OKC_K_ARTICLE_PUB.create_k_article(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_catv_rec		=> l_catv_rec,
           x_catv_rec		=> x_catv_rec);

    IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('400 : create_k_article returns ' || l_return_status, 2);
    END IF;

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
/* 11510 - do not copy translations, sections and section contents
    FOR l_c_atn IN c_atn(l_catv_rec.id)
    LOOP
      l_return_status := get_atnv_rec(	p_atn_id 	=> l_c_atn.id,
					x_atnv_rec 	=> l_atnv_rec);
      IF get_new_rul_id(l_atnv_rec.rul_id,l_new_rul_id) THEN
        l_atnv_rec.rul_id := l_new_rul_id;
        l_atnv_rec.cat_id := x_catv_rec.id;
        l_atnv_rec.dnz_chr_id := x_catv_rec.dnz_chr_id;

        OKC_K_ARTICLE_PUB.create_article_translation(
        	   p_api_version	=> p_api_version,
               p_init_msg_list	=> p_init_msg_list,
               x_return_status 	=> l_return_status,
               x_msg_count     	=> x_msg_count,
               x_msg_data      	=> x_msg_data,
               p_atnv_rec		=> l_atnv_rec,
               x_atnv_rec		=> x_atnv_rec);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
        	     x_return_status := l_return_status;
            END IF;
          END IF;
      END IF;
    END LOOP;

    x_cat_id := x_catv_rec.id; -- passes the new generated id to the caller.

    FOR l_c_scc IN c_scc LOOP
      copy_sections (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_scc_id		=> l_c_scc.id,
           p_to_cat_id		=> x_catv_rec.id,
           p_to_chr_id		=> x_catv_rec.dnz_chr_id,
		 p_scn_id		     => NULL);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END LOOP;
*/
  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('500 : Exiting Procedure Copy_articles ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
	    IF (l_debug = 'Y') THEN
   	    OKC_DEBUG.ReSet_Indentation;
	    END IF;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	    IF (l_debug = 'Y') THEN
   	    OKC_DEBUG.ReSet_Indentation;
	    END IF;

  END copy_articles;

  ----------------------------------------------------------------------------------
  --Procedure copy_latest_articles - Makes a copy of the latest version of articles.
  ----------------------------------------------------------------------------------
  PROCEDURE copy_latest_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    x_cat_id		               OUT NOCOPY NUMBER) IS


    l_return_status	        		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sae_id			  		NUMBER;
    l_sav_release              	VARCHAR2(150);

    CURSOR c_sav_sae_id(p_cat_id IN NUMBER) IS
    SELECT sav_sae_id
    FROM okc_k_articles_b
    WHERE id = p_cat_id;

    CURSOR c_latest_version(p_sae_id IN NUMBER) IS
    SELECT sav_release
    FROM okc_std_art_versions_v
    WHERE sae_id = p_sae_id
       AND creation_date = (SELECT max(creation_date)
                            FROM okc_std_art_versions_v
                            WHERE sae_id = p_sae_id)
       AND date_active <= sysdate;

  BEGIN
--
IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' --- Copy_Latest_Articles ');
   OKC_DEBUG.log('1001 : Entering Copy_Latest_Articles ', 2);
END IF;
--
    x_return_status := l_return_status;
    OPEN c_sav_sae_id(p_cat_id);
    FETCH c_sav_sae_id INTO l_sae_id;
    CLOSE c_sav_sae_id;

    OPEN c_latest_version(l_sae_id);
	    FETCH c_latest_version INTO l_sav_release;
    CLOSE c_latest_version;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1002 : Before OKC_COPY_CONTRACT_PUB.Copy_Articles ', 2);
   OKC_DEBUG.log('1003 : ID='|| to_char(p_cat_id) || ', l_sav_release = ' || l_sav_release, 2);
   OKC_DEBUG.log('1004 : CHR_ID='|| to_char(p_chr_id) , 2);
END IF;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1005 : p_cle_id='|| to_char(p_cle_id) , 2);
END IF;

    OKC_COPY_CONTRACT_PUB.copy_articles(
	  p_api_version		=> p_api_version,
          p_init_msg_list	=> p_init_msg_list,
          x_return_status 	=> l_return_status,
          x_msg_count     	=> x_msg_count,
          x_msg_data      	=> x_msg_data,
          p_cat_id 			=> p_cat_id,
    	  p_cle_id            => p_cle_id,
    	  p_chr_id            => p_chr_id,
	  p_sav_sav_release 	=> l_sav_release,
    	  x_cat_id			=> x_cat_id);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1006 : After OKC_COPY_CONTRACT_PUB.Copy_Articles ' || l_return_status  );
END IF;

     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
     END IF;

  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('1007 : Exiting Procedure Copy_Latest_Articles ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	 IF (l_debug = 'Y') THEN
   	 OKC_DEBUG.ReSet_Indentation;
	 END IF;
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	 IF (l_debug = 'Y') THEN
   	 OKC_DEBUG.ReSet_Indentation;
	 END IF;

  END Copy_Latest_Articles;

  ----------------------------------------------------------------------------
  --Proceudre copy_price_att_values - Makes a copy of the price attribute values.
  ----------------------------------------------------------------------------
  PROCEDURE copy_price_att_values(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pav_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    x_pav_id		           OUT NOCOPY NUMBER) IS

    l_pavv_rec 	pavv_rec_type;
    x_pavv_rec 	pavv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;

  BEGIN
    x_return_status := l_return_status;
    l_return_status := get_pavv_rec(	p_pav_id 	=> p_pav_id,
					x_pavv_rec 	=> l_pavv_rec);

    l_pavv_rec.chr_id := p_chr_id;
    l_pavv_rec.cle_id := p_cle_id;

    OKC_PRICE_ADJUSTMENT_PUB.create_price_att_value(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_pavv_rec		=> l_pavv_rec,
           x_pavv_rec		=> x_pavv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;

    x_pav_id := x_pavv_rec.id; -- passes the new generated id to the caller.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_price_att_values;


-------------------------------------------
--------copy price adjustments
------------------------------------
   PROCEDURE copy_price_adjustments(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pat_id                       IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    x_pat_id                       OUT NOCOPY NUMBER) IS

    l_patv_rec  patv_rec_type;
    x_patv_rec  patv_rec_type;

    l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id                    NUMBER := OKC_API.G_MISS_NUM;

    l_new_pat_id  NUMBER;
  BEGIN
    x_return_status := l_return_status;
    l_return_status := get_patv_rec(    p_pat_id        => p_pat_id,
                                        x_patv_rec      => l_patv_rec);

    l_patv_rec.chr_id := p_chr_id;
    l_patv_rec.cle_id := p_cle_id;
    l_patv_rec.id := NULL;

   IF get_new_pat_id(l_patv_rec.pat_id,l_new_pat_id) THEN
        l_patv_rec.pat_id := l_new_pat_id;
   END IF;
    OKC_PRICE_ADJUSTMENT_PUB.create_price_adjustment(
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_patv_rec           => l_patv_rec,
           x_patv_rec           => x_patv_rec);


           IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;

    x_pat_id := x_patv_rec.id; -- passes the new generated id to the caller.
   add_price_adjustments(p_pat_id,x_patv_rec.id);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_price_adjustments;

---------------------------------------------------------------------------------------------------

    PROCEDURE copy_price_adj_assocs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pac_id                       IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_pat_id                       IN NUMBER ,
    x_pac_id                       OUT NOCOPY NUMBER) IS

    l_pacv_rec  pacv_rec_type;
    x_pacv_rec  pacv_rec_type;

    l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id                    NUMBER := OKC_API.G_MISS_NUM;

    l_new_pat_id                NUMBER := OKC_API.G_MISS_NUM;
    l_new_pat_id_from           NUMBER := OKC_API.G_MISS_NUM; -- Added as per Bug 2554460

  BEGIN
    x_return_status := l_return_status;
    l_return_status := get_pacv_rec(    p_pac_id        => p_pac_id,
                                        x_pacv_rec      => l_pacv_rec);

    l_pacv_rec.cle_id := p_cle_id;

    -- Modified for Bug 2554460/2580522
    IF get_new_pat_id(l_pacv_rec.pat_id_from,l_new_pat_id_from) THEN
        l_pacv_rec.pat_id_from := l_new_pat_id_from;

        IF get_new_pat_id(l_pacv_rec.pat_id,l_new_pat_id) THEN
           l_pacv_rec.pat_id := l_new_pat_id;
        ELSE
           l_pacv_rec.pat_id := NULL;
        END IF;

    END IF;

    /*  Commented for Bug 2554460
    IF get_new_pat_id(l_pacv_rec.pat_id_from,l_new_pat_id) THEN
        l_pacv_rec.pat_id_from := l_new_pat_id;
    ELSE
        l_pacv_rec.pat_id := NULL;
    END IF;
    */

    OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_assoc(
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_pacv_rec           => l_pacv_rec,
           x_pacv_rec           => x_pacv_rec);

           IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;

    x_pac_id := x_pacv_rec.id; -- passes the new generated id to the caller.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_price_adj_assocs;

  ----------------------------------------------------------------
     PROCEDURE copy_price_adj_attribs(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paa_id                       IN NUMBER ,
    p_pat_id                       IN NUMBER
                                      ) IS

    l_paav_rec  paav_rec_type;
    x_paav_rec  paav_rec_type;

     l_new_pat_id   NUMBER := OKC_API.G_MISS_NUM;

    l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


     CURSOR c_paav IS
    SELECT id
    FROM okc_price_adj_attribs_v
    WHERE pat_id = p_pat_id;

  BEGIN
     x_return_status := l_return_status;
----   IF get_new_pat_id(p_pat_id,l_new_pat_id) THEN
   ----     l_new_pat_id := l_new_pat_id;
---        RAISE G_EXCEPTION_HALT_VALIDATION;
--      END IF;
  FOR l_c_paav IN c_paav LOOP
    l_return_status := get_paav_rec(    p_paa_id        => l_c_paav.id,
                                        x_paav_rec      => l_paav_rec);

    IF get_new_pat_id(l_paav_rec.pat_id,l_new_pat_id) THEN
        l_paav_rec.pat_id := l_new_pat_id;
     --- ELSE
     -----    l_paav_rec.pat_id := null;
      END IF;


    OKC_PRICE_ADJUSTMENT_PUB.create_price_adj_attrib(
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_paav_rec           => l_paav_rec,
           x_paav_rec           => x_paav_rec);
           IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;

    END LOOP;
  ----  x_paa_id := x_paav_rec.id; -- passes the new generated id to the caller.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_price_adj_attribs;

--------------------------------------------------------------------------------------------




  ----------------------------------------------------------------------------
  --Function to populate the sales credit record to be copied.
  ----------------------------------------------------------------------------
     FUNCTION get_scrv_rec(p_scrv_id IN NUMBER,
                                x_scrv_rec OUT NOCOPY OKC_SALES_CREDIT_PUB.scrv_rec_type) RETURN  VARCHAR2 IS

      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_scrv_rec IS
      SELECT
              --ID,
              DNZ_CHR_ID,
              PERCENT,
              CHR_ID,
              CLE_ID,
              SALESREP_ID1,
              SALESREP_ID2,
              SALES_CREDIT_TYPE_ID1,
              SALES_CREDIT_TYPE_ID2,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE
        FROM  OKC_K_SALES_CREDITS_V
        WHERE ID = p_scrv_id;
    BEGIN
      OPEN c_scrv_rec;
      FETCH c_scrv_rec
      INTO
            --- x_scrv_rec.ID,

              x_scrv_rec.DNZ_CHR_ID,
              x_scrv_rec.PERCENT,
              x_scrv_rec.CHR_ID,
              x_scrv_rec.CLE_ID,
              x_scrv_rec.SALESREP_ID1,
              x_scrv_rec.SALESREP_ID2,
              x_scrv_rec.SALES_CREDIT_TYPE_ID1,
              x_scrv_rec.SALES_CREDIT_TYPE_ID2,
              x_scrv_rec.OBJECT_VERSION_NUMBER,
              x_scrv_rec.CREATED_BY,
              x_scrv_rec.CREATION_DATE,
              x_scrv_rec.LAST_UPDATED_BY,
              x_scrv_rec.LAST_UPDATE_DATE;

               l_no_data_found := c_scrv_rec%NOTFOUND;
      CLOSE c_scrv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_scrv_rec;




  ----------------------------------------------------------------------------
  --Procedure copy_sales_credits - Makes a copy of sales credits
  ----------------------------------------------------------------------------
  PROCEDURE copy_sales_credits (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_scrv_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    x_scrv_id		           OUT NOCOPY NUMBER) IS

    l_scrv_rec 	OKC_SALES_credit_PUB.scrv_rec_type;
    x_scrv_rec 	OKC_SALES_credit_PUB.scrv_rec_type;


    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;

  BEGIN
    x_return_status := l_return_status;


    l_return_status := get_scrv_rec(p_scrv_id 	=> p_scrv_id,
				    x_scrv_rec 	=> l_scrv_rec);

    l_scrv_rec.chr_id := p_chr_id;
    l_scrv_rec.dnz_chr_id := p_chr_id;
    l_scrv_rec.cle_id := p_cle_id;

    OKC_SALES_credit_PUB.insert_Sales_credit(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_scrv_rec		=> l_scrv_rec,
           x_scrv_rec		=> x_scrv_rec);


      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;

    x_scrv_id := x_scrv_rec.id; -- passes the new generated id to the caller.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_sales_credits ;





    ----------------------------------------------------------------------------
  --Function to populate the price hold line breaks record to be copied.

  ----------------------------------------------------------------------------
     FUNCTION get_okc_ph_line_breaks_v_rec(p_okc_ph_line_breaks_v_id IN NUMBER,
                                x_okc_ph_line_breaks_v_rec OUT NOCOPY OKC_PH_LINE_BREAKS_PUB.okc_ph_line_breaks_v_rec_type)
                        RETURN  VARCHAR2 IS

      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_okc_ph_line_breaks_v_rec IS
      SELECT
              --ID
              CLE_ID,
              VALUE_FROM,
              VALUE_TO,
              PRICING_TYPE,
              VALUE,
              START_DATE,
              END_DATE,
              INTEGRATED_WITH_QP,
              QP_REFERENCE_ID,
              SHIP_TO_ORGANIZATION_ID,
              SHIP_TO_LOCATION_ID,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE

        FROM  OKC_PH_LINE_BREAKS_V
        WHERE ID = p_okc_ph_line_breaks_v_id;
    BEGIN
      OPEN c_okc_ph_line_breaks_v_rec;
      FETCH c_okc_ph_line_breaks_v_rec
      INTO
              -----x_okc_ph_line_breaks_v_rec.CLE_ID,

              x_okc_ph_line_breaks_v_rec.CLE_ID,
              x_okc_ph_line_breaks_v_rec.VALUE_FROM,
              x_okc_ph_line_breaks_v_rec.VALUE_TO,
              x_okc_ph_line_breaks_v_rec.PRICING_TYPE,
              x_okc_ph_line_breaks_v_rec.VALUE,
              x_okc_ph_line_breaks_v_rec.START_DATE,
              x_okc_ph_line_breaks_v_rec.END_DATE,
              x_okc_ph_line_breaks_v_rec.INTEGRATED_WITH_QP,
              x_okc_ph_line_breaks_v_rec.QP_REFERENCE_ID,
              x_okc_ph_line_breaks_v_rec.SHIP_TO_ORGANIZATION_ID,
              x_okc_ph_line_breaks_v_rec.SHIP_TO_LOCATION_ID,
              x_okc_ph_line_breaks_v_rec.OBJECT_VERSION_NUMBER,
              x_okc_ph_line_breaks_v_rec.CREATED_BY,
              x_okc_ph_line_breaks_v_rec.CREATION_DATE,
              x_okc_ph_line_breaks_v_rec.LAST_UPDATED_BY,
              x_okc_ph_line_breaks_v_rec.LAST_UPDATE_DATE;


              l_no_data_found := c_okc_ph_line_breaks_v_rec%NOTFOUND;
      CLOSE c_okc_ph_line_breaks_v_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_okc_ph_line_breaks_v_rec;



/********Commented for bug 3033281 *******************************
-- Price Hold is bosoleted and this procedure is nolonger required.
  ----------------------------------------------------------------------------
  --Procedure copy_price_hold_line_breaks - Makes a copy of price hold line breaks
  ----------------------------------------------------------------------------
  PROCEDURE copy_price_hold_line_breaks (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec_id  IN NUMBER,
    p_cle_id                       IN NUMBER ,
    ----p_chr_id                       IN NUMBER ,
    x_okc_ph_line_breaks_v_rec_id  OUT NOCOPY NUMBER) IS

    l_okc_ph_line_breaks_v_rec   OKC_PH_LINE_BREAKS_PUB.okc_ph_line_breaks_v_rec_type;
    x_okc_ph_line_breaks_v_rec   OKC_PH_LINE_BREAKS_PUB.okc_ph_line_breaks_v_rec_type;


    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;

  BEGIN
    x_return_status := l_return_status;

    l_return_status := get_okc_ph_line_breaks_v_rec(p_okc_ph_line_breaks_v_id => p_okc_ph_line_breaks_v_rec_id,
                                                    x_okc_ph_line_breaks_v_rec => l_okc_ph_line_breaks_v_rec);

    ------l_scrv_rec.chr_id := p_chr_id;
    ------l_scrv_rec.dnz_chr_id := p_chr_id;
    l_okc_ph_line_breaks_v_rec.cle_id := p_cle_id;
    l_okc_ph_line_breaks_v_rec.qp_reference_id := null;
    l_okc_ph_line_breaks_v_rec.integrated_with_qp := 'N';


    OKC_PH_LINE_BREAKS_PUB.create_Price_Hold_Line_Breaks(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_okc_ph_line_breaks_v_rec => l_okc_ph_line_breaks_v_rec,
           x_okc_ph_line_breaks_v_rec => x_okc_ph_line_breaks_v_rec);



      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;

    x_okc_ph_line_breaks_v_rec_id := x_okc_ph_line_breaks_v_rec.id; -- passes the new generated id to the caller.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_price_hold_line_breaks ;

-- Price Hold is bosoleted and this procedure is nolonger required.
********Commented for bug 3033281 *******************************************/
  ----------------------------------------------------------------------------
  --Function to populate the contract governance record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION get_gvev_rec(p_gve_id IN NUMBER,
				      x_gvev_rec OUT NOCOPY gvev_rec_type)
    RETURN  VARCHAR2 IS
      l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_gvev_rec IS
      SELECT
	    DNZ_CHR_ID,
	    ISA_AGREEMENT_ID,
	    CHR_ID,
	    CLE_ID,
	    CHR_ID_REFERRED,
	    CLE_ID_REFERRED,
	    COPIED_ONLY_YN
	 FROM    OKC_GOVERNANCES
	 WHERE 	ID = p_gve_id;
    BEGIN
      OPEN c_gvev_rec;
      FETCH c_gvev_rec
      INTO x_gvev_rec.DNZ_CHR_ID,
		x_gvev_rec.ISA_AGREEMENT_ID,
		x_gvev_rec.CHR_ID,
		x_gvev_rec.CLE_ID,
		x_gvev_rec.CHR_ID_REFERRED,
		x_gvev_rec.CLE_ID_REFERRED,
		x_gvev_rec.COPIED_ONLY_YN;

      l_no_data_found := c_gvev_rec%NOTFOUND;
      CLOSE c_gvev_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_gvev_rec;


  --------------------------------------------------------------------------
  --Procedure copy_governances - Makes a copy of the okc_governances
  --------------------------------------------------------------------------
  PROCEDURE copy_governances(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    x_gvev_id		           OUT NOCOPY NUMBER) IS


    l_gvev_rec 	gvev_rec_type;
    x_gvev_rec 	gvev_rec_type;

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := l_return_status;

    l_return_status := get_gvev_rec(p_gve_id   => p_gvev_id,
			            x_gvev_rec => l_gvev_rec);

    IF p_cle_id IS NOT NULL AND p_cle_id <> OKC_API.G_MISS_NUM THEN
       --we are copying at line level so chr_id should be null
       l_gvev_rec.chr_id        :=   NULL;
    ELSE
       --we are copying at header level
       l_gvev_rec.chr_id        :=   p_chr_id;
    END IF;

    l_gvev_rec.dnz_chr_id    :=   p_chr_id;
    l_gvev_rec.cle_id        :=   p_cle_id;   --p_cle_id will be passed here as null if we are copying at header level


    OKC_CONTRACT_PUB.create_governance(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_gvev_rec		=> l_gvev_rec,
           x_gvev_rec		=> x_gvev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	    x_return_status := l_return_status;
        END IF;
    END IF;

    x_gvev_id := x_gvev_rec.id; -- passes the new generated id to the caller.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_governances;




  ----------------------------------------------------------------------------
  --Proceudre copy_party_roles - Makes a copy of the party_roles.
  ----------------------------------------------------------------------------
  PROCEDURE copy_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    P_rle_code                     IN VARCHAR2,
    x_cpl_id		           OUT NOCOPY NUMBER) IS

    l_cplv_rec 	cplv_rec_type;
    x_cplv_rec 	cplv_rec_type;
    l_ctcv_rec 	ctcv_rec_type;
    x_ctcv_rec 	ctcv_rec_type;

    l_party_name                VARCHAR2(200);
    l_party_desc                VARCHAR2(2000);
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;

    CURSOR c_dnz_chr_id(p_id IN NUMBER) IS
    SELECT dnz_chr_id
    FROM okc_k_lines_b
    WHERE id = p_id;

    CURSOR c_ctcv IS
    SELECT id
    FROM okc_contacts_v
    WHERE cpl_id = p_cpl_id;

  BEGIN
    x_return_status := l_return_status;
    l_return_status := get_cplv_rec(	p_cpl_id 	=> p_cpl_id,
					x_cplv_rec 	=> l_cplv_rec);

    IF p_chr_id IS NULL OR p_chr_id = OKC_API.G_MISS_NUM THEN
      OPEN c_dnz_chr_id(p_cle_id);
      FETCH c_dnz_chr_id INTO l_cplv_rec.dnz_chr_id;
      CLOSE c_dnz_chr_id;
    ELSE
      l_cplv_rec.dnz_chr_id := p_chr_id;
    END IF;

    l_cplv_rec.chr_id := p_chr_id;
    l_cplv_rec.cle_id := p_cle_id;
    IF p_rle_code IS NOT NULL THEN
      l_cplv_rec.rle_code := p_rle_code;
    END IF;

    OKC_CONTRACT_PARTY_PUB.create_k_party_role(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cplv_rec		=> l_cplv_rec,
           x_cplv_rec		=> x_cplv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    x_cpl_id := x_cplv_rec.id; -- passes the new generated id to the caller.

     --stores the new rul_id in a global pl/sql table.
     add_party(l_cplv_rec.id,x_cplv_rec.id);


    FOR l_c_ctcv IN c_ctcv LOOP
      l_return_status := get_ctcv_rec(	p_ctc_id 	=> l_c_ctcv.id,
					x_ctcv_rec 	=> l_ctcv_rec);

      l_ctcv_rec.dnz_chr_id := l_cplv_rec.dnz_chr_id;
      l_ctcv_rec.cpl_id := x_cplv_rec.id;

      OKC_CONTRACT_PARTY_PUB.create_contact(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_ctcv_rec		=> l_ctcv_rec,
           x_ctcv_rec		=> x_ctcv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	  x_return_status := OKC_API.G_RET_STS_WARNING;
          okc_util.get_name_desc_from_jtfv( p_object_code  => x_cplv_rec.jtot_object1_code,
                                        p_id1          => x_cplv_rec.object1_id1,
                                        p_id2          => x_cplv_rec.object1_id2,
                                        x_name         => l_party_name,
                                        x_description  => l_party_desc);

          OKC_API.set_message(G_APP_NAME,'OKC_CONTACT_NOT_COPIED','PARTY_NAME',l_party_name);
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_party_roles;

  ----------------------------------------------------------------------------
  --Proceudre copy_events - Makes a copy of the condition header and all condition lines under the header.
  ----------------------------------------------------------------------------
  PROCEDURE copy_events(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cnh_id                  	   IN NUMBER,
    p_chr_id                       IN NUMBER ,
    p_to_template_yn               IN VARCHAR2,
    x_cnh_id		           OUT NOCOPY NUMBER) IS

    l_cnhv_rec 	cnhv_rec_type;
    x_cnhv_rec 	cnhv_rec_type;
    l_cnlv_rec 	cnlv_rec_type;
    x_cnlv_rec 	cnlv_rec_type;
    l_ocev_rec 	ocev_rec_type;
    x_ocev_rec 	ocev_rec_type;
    l_oatv_rec 	oatv_rec_type;
    x_oatv_rec 	oatv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;
    l_new_cnh_id 		NUMBER;

    CURSOR 	c_cnlv IS
    SELECT 	id
    FROM 	okc_condition_lines_b
    WHERE 	cnh_id = p_cnh_id;

    CURSOR 	c_ocev IS
    SELECT 	id
    FROM 	okc_outcomes_b
    WHERE 	cnh_id = p_cnh_id;

    CURSOR 	c_oatv(p_oce_id IN NUMBER) IS
    SELECT 	id
    FROM 	okc_outcome_arguments_v
    WHERE 	oce_id = p_oce_id;

  BEGIN
    x_return_status := l_return_status;
    IF get_new_cnh_id(p_cnh_id,l_new_cnh_id) THEN --If the events is already copied then return.
      x_cnh_id := l_new_cnh_id;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := get_cnhv_rec(	p_cnh_id 	=> p_cnh_id,
					x_cnhv_rec 	=> l_cnhv_rec);

    l_cnhv_rec.dnz_chr_id := p_chr_id;
    l_cnhv_rec.object_id  := p_chr_id;
    l_cnhv_rec.jtot_object_code  := 'OKC_K_HEADER';
    IF p_to_template_yn = 'Y' THEN
      l_cnhv_rec.template_yn := 'Y';
    ELSIF p_to_template_yn = 'N' THEN
      l_cnhv_rec.template_yn := 'N';
    END IF;
    If (l_cnhv_rec.date_active < g_chrv_rec.start_date OR
	   l_cnhv_rec.date_active > g_chrv_rec.end_date)
    Then
        l_cnhv_rec.date_active := g_chrv_rec.start_date;
    End If;
    If (l_cnhv_rec.date_inactive > g_chrv_rec.end_date OR
	   l_cnhv_rec.date_inactive < g_chrv_rec.start_date)
    Then
        l_cnhv_rec.date_inactive := g_chrv_rec.end_date;
    End If;

    OKC_CONDITIONS_PUB.create_cond_hdrs(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cnhv_rec		=> l_cnhv_rec,
           x_cnhv_rec		=> x_cnhv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := OKC_API.G_RET_STS_WARNING;

          OKC_API.set_message(G_APP_NAME,'OKC_CONDITION_NOT_COPIED','CONDITION',l_cnhv_rec.name);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF;

    x_cnh_id := x_cnhv_rec.id; -- passes the new generated id to the caller.

    FOR l_c_cnlv IN c_cnlv LOOP
      l_return_status := get_cnlv_rec(	p_cnl_id 	=> l_c_cnlv.id,
					x_cnlv_rec 	=> l_cnlv_rec);

      l_cnlv_rec.dnz_chr_id := l_cnhv_rec.dnz_chr_id;
      l_cnlv_rec.cnh_id := x_cnhv_rec.id;

      OKC_CONDITIONS_PUB.create_cond_lines(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cnlv_rec		=> l_cnlv_rec,
           x_cnlv_rec		=> x_cnlv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    FOR l_c_ocev IN c_ocev LOOP
      l_return_status := get_ocev_rec(	p_oce_id 	=> l_c_ocev.id,
					x_ocev_rec 	=> l_ocev_rec);

      l_ocev_rec.dnz_chr_id := l_cnhv_rec.dnz_chr_id;
      l_ocev_rec.cnh_id := x_cnhv_rec.id;

      OKC_OUTCOME_PUB.create_outcome(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_ocev_rec		=> l_ocev_rec,
           x_ocev_rec		=> x_ocev_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;

      FOR l_c_oatv IN c_oatv(l_ocev_rec.id) LOOP
        l_return_status := get_oatv_rec(	p_oat_id 	=> l_c_oatv.id,
					x_oatv_rec 	=> l_oatv_rec);

        l_oatv_rec.dnz_chr_id := l_cnhv_rec.dnz_chr_id;
        l_oatv_rec.oce_id := x_ocev_rec.id;

        OKC_OUTCOME_PUB.create_out_arg(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_oatv_rec		=> l_oatv_rec,
           x_oatv_rec		=> x_oatv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
	     x_return_status := l_return_status;
          END IF;
        END IF;
      END LOOP;

    END LOOP;

    add_events(p_cnh_id,x_cnhv_rec.id); --adds the new event id in the global PL/SQL table.

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_events;

  ----------------------------------------------------------------------------
  --Proceudre copy_rules - Makes a copy of the rule group and all the rules under the group.
  ----------------------------------------------------------------------------
  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    p_to_template_yn			   IN VARCHAR2,
    x_rgp_id		           OUT NOCOPY NUMBER) IS

    l_rgpv_rec 	rgpv_rec_type;
    x_rgpv_rec 	rgpv_rec_type;
    l_rulv_rec 	rulv_rec_type;
    x_rulv_rec 	rulv_rec_type;
    l_rmpv_rec 	rmpv_rec_type;
    x_rmpv_rec 	rmpv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			   NUMBER := OKC_API.G_MISS_NUM;
    l_tve_id                NUMBER;
    l_tve_id_out            NUMBER;
    l_col_vals              okc_time_util_pub.t_col_vals;
    l_col_vals_temp         okc_time_util_pub.t_col_vals;
    l_no_of_cols            NUMBER;
    l_string                VARCHAR2(2000);
    l_time_value_copied     VARCHAR2(1):= 'Y';
    i                       NUMBER := 0;
    tmp_rulv_rec            rulv_rec_type;

    l_found                 BOOLEAN;
    l_cpl_id                NUMBER;
    l_new_cpl_id            NUMBER;
    l_result                VARCHAR2(1):='?';

    CURSOR c_dnz_chr_id(p_id IN NUMBER) IS
    SELECT dnz_chr_id
    FROM okc_k_lines_b
    WHERE id = p_id;
--->NO Union

    --Bug:3626930 cursor modified to check whether the rule
    --to be copied is also available in the rules setup i.e
    --in okc_rg_def_rules table
    CURSOR c_rulv(p_rgp_id IN NUMBER) IS
    SELECT rul.id,rule_information_category
    FROM okc_rules_b rul, okc_rule_groups_b rgp ,okc_rg_def_rules rgdef
    WHERE rul.rgp_id = p_rgp_id
    and rul.rgp_id=rgp.id
    and rgp.rgd_code=rgdef.rgd_code
    and rul.rule_information_category=rgdef.rdf_code;
--->No union

    CURSOR c_rmpv(p_rgp_id IN NUMBER) IS
    SELECT rrd_id,cpl_id
    FROM okc_rg_party_roles_v
    WHERE rgp_id = p_rgp_id;
--->Union Yes

    CURSOR c_rrdv(p_rgp_id IN NUMBER) IS
    SELECT cpl_id
    FROM okc_rg_party_roles_v rgp, okc_rg_role_defs rrd
    WHERE rrd.id = rgp.rrd_id
    and rgp.dnz_chr_id = (select dnz_chr_id
                          from okc_rule_groups_b
                          where id = p_rgp_id)
    and rgp.rgp_id = p_rgp_id
    and rrd.subject_object_flag = 'O';
---No Union REQD

--Bug 3948599
    CURSOR c_rgdv_csr(p_rgp_id IN NUMBER,p_dnz_chr_id IN NUMBER) IS
        SELECT 'x'
        FROM   FND_LOOKUP_VALUES rgdv,
               okc_rule_groups_b rgp,
               OKC_SUBCLASS_RG_DEFS srdv,
               OKC_K_HEADERS_B chrv
        WHERE rgp.id           = p_rgp_id
          AND rgdv.LOOKUP_CODE = rgp.rgd_code
          AND rgdv.lookup_type = 'OKC_RULE_GROUP_DEF'
          AND srdv.RGD_CODE = rgp.rgd_code
          AND srdv.SCS_CODE = chrv.SCS_CODE
          AND chrv.ID       = p_dnz_chr_id;

  BEGIN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' Copy_Rules ');
   OKC_DEBUG.log('2001 : Entering Copy_Rules ', 2);
END IF;

    x_return_status := l_return_status;
    l_return_status := get_rgpv_rec(	p_rgp_id 	=> p_rgp_id,
					x_rgpv_rec 	=> l_rgpv_rec);

    IF p_chr_id IS NULL OR p_chr_id = OKC_API.G_MISS_NUM THEN
      OPEN c_dnz_chr_id(p_cle_id);
      FETCH c_dnz_chr_id INTO l_rgpv_rec.dnz_chr_id;
      CLOSE c_dnz_chr_id;
    ELSE
      l_rgpv_rec.dnz_chr_id := p_chr_id;
    END IF;

    --
    -- Do not copy the rule group and rules under it
    -- if the rule group has a object(party)
    -- which is not in the target contract
    --

    -- check whether object (party) exists for this rule group
    OPEN c_rrdv(p_rgp_id);
    FETCH c_rrdv INTO l_cpl_id;
    l_found := c_rrdv%FOUND;
    CLOSE c_rrdv;

    --
    -- If there is a object (party) in the source contract
    -- and found in target contract, continue copy
    -- else do not copy this rule group
    --
    If (l_found) Then
       If (get_new_cpl_id(l_cpl_id,l_new_cpl_id)) Then
          null;
       Else
		IF (l_debug = 'Y') THEN
   		OKC_DEBUG.ReSet_Indentation;
		END IF;
          return;
       End If;
    End If;

--Bug 3948599 Added cursor c_rgdv_csr to check if subclass rulegroup definition is present for the scs_code of that contract
    l_result := '?';
    OPEN  c_rgdv_csr(p_rgp_id,l_rgpv_rec.dnz_chr_id);
    FETCH c_rgdv_csr INTO l_result;
    CLOSE c_rgdv_csr;

    IF l_result <> 'x' THEN
    -- Cannot be copied. Skip this rule group.
      IF (l_debug = 'Y') THEN
   		OKC_DEBUG.ReSet_Indentation;
	  END IF;
      return;
    END IF;


    l_return_status := get_chrv_rec(l_rgpv_rec.dnz_chr_id,g_chrv_rec); --this is to populate global

    -- preserve the actuval history flag
    l_old_history_yn := G_COPY_HISTORY_YN;
    G_COPY_HISTORY_YN := 'N';
    l_return_status := get_chrv_rec(l_rgpv_rec.dnz_chr_id,g_chrv_rec); --this is to populate global
    -- reset G_COPY_HISTORY_YN;
    G_COPY_HISTORY_YN := l_old_history_yn;

    --header rec when copy is called while copying rules from Standard article library.
    l_rgpv_rec.chr_id := p_chr_id;
    l_rgpv_rec.cle_id := p_cle_id;
    l_rgpv_rec.rgp_type := 'KRG';
    l_rgpv_rec.sat_code := null;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('2001 : Before Procedure  Create_Rule_Group : ' );
END IF;
    OKC_RULE_PUB.create_rule_group(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_rgpv_rec		=> l_rgpv_rec,
           x_rgpv_rec		=> x_rgpv_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_rgp_id := x_rgpv_rec.id; -- passes the new generated id to the caller.

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('2001 : After Procedure Create_Rule_Group : ');
END IF;
    FOR l_c_rmpv IN c_rmpv(p_rgp_id) LOOP
      l_old_return_status := x_return_status;
      l_rmpv_rec.dnz_chr_id := l_rgpv_rec.dnz_chr_id;
      l_rmpv_rec.rgp_id := x_rgpv_rec.id;
      l_rmpv_rec.rrd_id := l_c_rmpv.rrd_id;

      IF get_new_cpl_id(l_c_rmpv.cpl_id,l_rmpv_rec.cpl_id) THEN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('2001 : Before Procedure Create_Rg_Mode_Pty_Role : '  );
END IF;
        OKC_RULE_PUB.create_rg_mode_pty_role(
 	   p_api_version	=> p_api_version,
            p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> l_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_rmpv_rec		=> l_rmpv_rec,
            x_rmpv_rec		=> x_rmpv_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR then
              x_return_status := OKC_API.G_RET_STS_WARNING;
            END IF;
          END IF;
        END IF;
      END IF;

    END LOOP;

    FOR l_c_rulv IN c_rulv(p_rgp_id) LOOP
      l_return_status := get_rulv_rec(	p_rul_id 	=> l_c_rulv.id,
					x_rulv_rec 	=> l_rulv_rec);

      l_rulv_rec.dnz_chr_id := l_rgpv_rec.dnz_chr_id;
      l_rulv_rec.rgp_id := x_rgpv_rec.id;

	 --For Bug#3095455
	 -- by passing rules validation in okc_rul_pvt,when value is 'N' for NCR.
	 l_rulv_rec.VALIDATE_YN  := 'N';
	 --For Bug#3095455

      IF p_to_template_yn = 'Y' THEN
	   l_rulv_rec.std_template_yn := 'Y';
      ELSE
	   l_rulv_rec.std_template_yn := 'N';
      END IF;

      -- logic to copy the timevalue associated with the rule begins

     g_rulv_rec := l_rulv_rec;
     l_col_vals := l_col_vals_temp; -- initialising the table with null

-- /striping/
p_appl_id  := okc_rld_pvt.get_appl_id(l_c_rulv.rule_information_category);
p_dff_name := okc_rld_pvt.get_dff_name(l_c_rulv.rule_information_category);

--     okc_time_util_pub.get_dff_column_values( p_app_id => 510,     -- /striping/
     okc_time_util_pub.get_dff_column_values( p_app_id => p_appl_id,
--               p_dff_name => 'OKC Rule Developer DF',              -- /striping/
               p_dff_name => p_dff_name,
               p_rdf_code => l_c_rulv.rule_information_category,
               p_fvs_name => 'OKC_TIMEVALUES',
               p_rule_id  => l_c_rulv.id,
               p_col_vals => l_col_vals,
               p_no_of_cols => l_no_of_cols );
     IF l_col_vals.COUNT > 0 THEN
       i := l_col_vals.FIRST;
       LOOP
	    l_tve_id := to_number(l_col_vals(i).col_value);
	    IF l_tve_id IS NOT NULL THEN
           copy_timevalues (
      	   p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_tve_id		=> l_tve_id,
             p_to_chr_id		=> l_rgpv_rec.dnz_chr_id,-- the rule group dnz_chr_id is passed
	        p_to_template_yn => p_to_template_yn,
             x_tve_id	     => l_tve_id_out);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              l_time_value_copied := 'N';
              x_return_status := l_return_status;
/*
              l_string := 'BEGIN OKC_COPY_CONTRACT_PVT.g_rulv_rec.' ||l_col_vals(i).col_name||' := null; END;';
              EXECUTE IMMEDIATE l_string;
*/

-- skekkar
-- Bug 2934909  Changed dynamic sql to static
--

              IF l_col_vals(i).col_name = 'RULE_INFORMATION1' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION1 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION2' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION2 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION3' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION3 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION4' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION4 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION5' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION5 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION6' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION6 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION7' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION7 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION8' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION8 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION9' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION9 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION10' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION10 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION11' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION11 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION12' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION12 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION13' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION13 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION14' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION14 := NULL;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION15' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION15 := NULL;
              END IF;


              EXIT;
            END IF;
          ELSE
		 add_timevalues(l_tve_id,l_tve_id_out);

/*
        l_string := 'BEGIN OKC_COPY_CONTRACT_PVT.g_rulv_rec.' ||l_col_vals(i).col_name||' := :l_tve_id_out; END;';
             -- bug#2256693 ||to_char(l_tve_id_out)||'; END;';
        EXECUTE IMMEDIATE l_string USING IN l_tve_id_out;
*/

-- skekkar
-- Bug 2934909  Changed dynamic sql to static
--

              IF l_col_vals(i).col_name = 'RULE_INFORMATION1' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION1 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION2' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION2 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION3' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION3 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION4' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION4 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION5' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION5 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION6' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION6 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION7' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION7 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION8' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION8 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION9' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION9 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION10' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION10 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION11' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION11 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION12' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION12 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION13' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION13 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION14' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION14 := l_tve_id_out;
              ELSIF l_col_vals(i).col_name = 'RULE_INFORMATION15' THEN
                 OKC_COPY_CONTRACT_PVT.g_rulv_rec.RULE_INFORMATION15 := l_tve_id_out;
              END IF;


             EXIT WHEN (i = l_col_vals.LAST);
             i := l_col_vals.NEXT(i);
          END IF;
        ELSE
           EXIT WHEN (i = l_col_vals.LAST); --if tve_id is null and there are no more time_values .
        END IF;
       END LOOP;
     END IF;

      -- logic to copy the timevalue associated with the rule ends
--     IF l_time_value_copied = 'Y' THEN

/* Euro Conersion - Override the pricelist based on Euro for contract header level based on the default profile- Bug 2155930 */

       IF g_rulv_rec.rule_information_category = 'PRE' THEN
          IF p_chr_id IS NOT NULL and p_cle_id IS NULL THEN
             IF g_pricelist is NOT NULL THEN
               g_rulv_rec.object1_id1 := g_pricelist;
               g_pricelist := NULL;
             END IF;
          END IF;
       END IF;


       OKC_RULE_PUB.create_rule(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_rulv_rec		=> g_rulv_rec,
           x_rulv_rec		=> x_rulv_rec);

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;
	  --stores the new rul_id in a global pl/sql table.
	  add_ruls(g_rulv_rec.id,x_rulv_rec.id);

      -----------------------------------------------------------------------
      -- Copy cover times if rule information category is 'CVR'
      -----------------------------------------------------------------------

       If (x_rulv_rec.rule_information_category = 'CVR') Then

          copy_cover_times(
	        p_api_version    => p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
	        p_to_template_yn => p_to_template_yn,
		   p_from_rul_id	=> g_rulv_rec.id,
             p_to_rul_id   	=> x_rulv_rec.id,
             p_chr_id         => p_chr_id,
             p_cle_id         => p_cle_id,
             p_to_chr_id      => l_rgpv_rec.dnz_chr_id);

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;

	  End If; -- if rule - 'CVR'

      -----------------------------------------------------------------------
      -- Copy react intervals if rule information category is 'RCN'
      -- Copy react intervals if rule information category is 'RSN' - Bug 2601345
      -----------------------------------------------------------------------
       --If (x_rulv_rec.rule_information_category = 'RCN') Then
       If (x_rulv_rec.rule_information_category in ('RSN','RCN')) Then

          copy_react_intervals(
	        p_api_version    => p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
	        p_to_template_yn => p_to_template_yn,
		   p_from_rul_id	=> g_rulv_rec.id,
             p_to_rul_id   	=> x_rulv_rec.id,
             p_chr_id         => p_chr_id,
             p_cle_id         => p_cle_id,
             p_to_chr_id      => l_rgpv_rec.dnz_chr_id);

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
           x_return_status := l_return_status;
         END IF;
       END IF;

	  End If; -- if rule - 'RCN'

 --    ELSE
 --      l_time_value_copied := 'Y';
 --    END IF;
     -- Clear previously populated values because the next rule will use the same global variable
     g_rulv_rec := tmp_rulv_rec;
    END LOOP;

  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('1001 : Exiting Procedure Copy_Rules ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    IF (l_debug = 'Y') THEN
   	    OKC_DEBUG.ReSet_Indentation;
	    END IF;
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         OKC_DEBUG.ReSet_Indentation;
      END IF;

  END copy_rules;

  ----------------------------------------------------------------------------
  --Proceudre copy_items
  ----------------------------------------------------------------------------
  PROCEDURE copy_items(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_copy_reference               IN VARCHAR2 ,
    p_to_cle_id                    IN NUMBER ) IS

    l_cimv_rec 	cimv_rec_type;
    x_cimv_rec 	cimv_rec_type;

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dnz_chr_id		NUMBER := OKC_API.G_MISS_NUM;
    l_price_level_ind   VARCHAR2(20);
    l_item_name         VARCHAR2(2000);
    l_item_desc         VARCHAR2(2000);


    l_a                 NUMBER;  -- Added for Bug 2387094/2292697
    l_b                 NUMBER;  -- Added for Bug 2387094/2292697
    l_c                 NUMBER;  -- Added for Bug 2387094/2292697

    CURSOR c_dnz_chr_id IS
    SELECT dnz_chr_id,price_level_ind
    FROM okc_k_lines_b
    WHERE id = p_to_cle_id;

    CURSOR c_cimv IS
    SELECT id
    FROM okc_k_items_v
    WHERE cle_id = p_from_cle_id;

  BEGIN
    x_return_status := l_return_status;

    OPEN c_dnz_chr_id;
    FETCH c_dnz_chr_id INTO l_dnz_chr_id,l_price_level_ind;
    CLOSE c_dnz_chr_id;

    FOR l_c_cimv IN c_cimv LOOP
      l_return_status := get_cimv_rec(	p_cim_id 	=> l_c_cimv.id,
					x_cimv_rec 	=> l_cimv_rec);

      l_cimv_rec.cle_id := p_to_cle_id;
      l_cimv_rec.dnz_chr_id := l_dnz_chr_id;

      -- skekkar bug 2621279
      IF l_cimv_rec.chr_id IS NOT NULL THEN
         l_cimv_rec.chr_id := l_dnz_chr_id;
      END IF;
      -- skekkar bug 2621279

	 IF p_copy_reference = 'REFERENCE' THEN
	   l_cimv_rec.cle_id_for := p_from_cle_id;
	   l_cimv_rec.chr_id := null;
	 ELSE
	   l_cimv_rec.cle_id_for := NULL;
	 END IF;

	 IF l_price_level_ind = 'N' THEN
            l_cimv_rec.priced_item_yn := 'N';
	 END IF;

-- Modified Below for Bug 2387094/2292697 - Begin
      OKC_CONTRACT_ITEM_PUB.create_contract_item(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           x_return_status    => l_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data,
           p_cimv_rec         => l_cimv_rec,
           x_cimv_rec         => x_cimv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
--bug 2667634 start , changes commented for bug 2774888
-- IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) OR (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
--bug 2667634 end
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
           -- Getting the original line id from where this new line is copied
           SELECT nvl(orig_system_id1,-001) into l_a FROM okc_k_lines_b
           WHERE  id = l_cimv_rec.cle_id;

           -- Getting the object1_id1 for original line id from where new line is copied
           SELECT nvl(object1_id1,-002) into l_b FROM okc_k_items
           WHERE  cle_id = l_a;

           -- Getting the new line id
           SELECT nvl(id,-003) into l_c FROM okc_k_lines_b
           WHERE orig_system_id1 = l_b
           AND   dnz_chr_id      = l_cimv_rec.dnz_chr_id;

            IF l_c <> -003 THEN   --if for l_c
               -- Need to set the org as per new contract id
               okc_context.set_okc_org_context(p_chr_id => l_cimv_rec.dnz_chr_id);

               l_cimv_rec.object1_id1 := l_c;

               OKC_CONTRACT_ITEM_PUB.create_contract_item(
                    p_api_version       => p_api_version,
                    p_init_msg_list     => p_init_msg_list,
                    x_return_status     => l_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    p_cimv_rec          => l_cimv_rec,
                    x_cimv_rec          => x_cimv_rec);

                IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    x_return_status := l_return_status;
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                  ELSE
                    okc_util.get_name_desc_from_jtfv( p_object_code  => l_cimv_rec.jtot_object1_code,
                                                  p_id1          => l_cimv_rec.object1_id1,
                                                  p_id2          => l_cimv_rec.object1_id2,
                                                  x_name         => l_item_name,
                                                  x_description  => l_item_desc);

                      OKC_API.set_message(G_APP_NAME,'OKC_ITEM_NOT_COPIED','ITEM_NAME',l_item_name);

                      -- Begin Added for Bug 2207226

                      DELETE FROM okc_k_lines_b
                      WHERE  id =  l_cimv_rec.cle_id;

                      DELETE FROM okc_k_lines_tl
                      WHERE  id =  l_cimv_rec.cle_id;

                      -- End Added for Bug 2207226

                      x_return_status := l_return_status;
                   END IF;
                 END IF;
            ELSE  -- else for l_c
                    okc_util.get_name_desc_from_jtfv( p_object_code  => l_cimv_rec.jtot_object1_code,
                                                  p_id1          => l_cimv_rec.object1_id1,
                                                  p_id2          => l_cimv_rec.object1_id2,
                                                  x_name         => l_item_name,
                                                  x_description  => l_item_desc);

                      OKC_API.set_message(G_APP_NAME,'OKC_ITEM_NOT_COPIED','ITEM_NAME',l_item_name);

                      -- Begin Added for Bug 2207226

                      DELETE FROM okc_k_lines_b
                      WHERE  id =  l_cimv_rec.cle_id;

                      DELETE FROM okc_k_lines_tl
                      WHERE  id =  l_cimv_rec.cle_id;

                      -- End Added for Bug 2207226

                      x_return_status := l_return_status;
            END IF;  -- endif for l_c
        END IF;
      END IF;
-- Modified Above for Bug 2387094/2292697 - End

/*  Begin  Commented for Bug 2387094/2292697
      OKC_CONTRACT_ITEM_PUB.create_contract_item(
	      p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cimv_rec		=> l_cimv_rec,
           x_cimv_rec		=> x_cimv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          okc_util.get_name_desc_from_jtfv( p_object_code  => l_cimv_rec.jtot_object1_code,
                                        p_id1          => l_cimv_rec.object1_id1,
                                        p_id2          => l_cimv_rec.object1_id2,
                                        x_name         => l_item_name,
                                        x_description  => l_item_desc);

          OKC_API.set_message(G_APP_NAME,'OKC_ITEM_NOT_COPIED','ITEM_NAME',l_item_name);

          -- Begin Added for Bug 2207226

          DELETE FROM okc_k_lines_b
          WHERE  id =  l_cimv_rec.cle_id;

          DELETE FROM okc_k_lines_tl
          WHERE  id =  l_cimv_rec.cle_id;

          -- End Added for Bug 2207226

          x_return_status := l_return_status;
        END IF;
      END IF;
         End  Commented for Bug 2387094/2292697 */
    END LOOP;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_items;

  --
  -- Procedure to set attachement session variables if they are null
  -- Currently set only set for OKCAUDET and OKSAUDET
  --
  -- If want to get rid of this hard coding, COPY should add
  -- parameters and user should pass attachement_funtion_name
  -- and attachment_funtion_type
  --
  PROCEDURE Set_Attach_Session_Vars(p_chr_id NUMBER) IS
    l_app_id NUMBER;
    Cursor l_chr_csr Is
	      SELECT application_id
	      FROM okc_k_headers_b
	      WHERE id = p_chr_id;
  BEGIN
    If (p_chr_id IS NOT NULL AND
	   FND_ATTACHMENT_UTIL_PKG.function_name IS NULL
	  )
    Then
      open l_chr_csr;
      fetch l_chr_csr into l_app_id;
      close l_chr_csr;

       -- Added for Bug 2384423
      If (l_app_id = 515) Then
	    FND_ATTACHMENT_UTIL_PKG.function_name := 'OKSAUDET';
	    FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
      Else
	    FND_ATTACHMENT_UTIL_PKG.function_name := 'OKCAUDET';
	    FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
      End If;

      /*  Commented for Bug 2384423
      If (l_app_id = 510) Then
	    FND_ATTACHMENT_UTIL_PKG.function_name := 'OKCAUDET';
	    FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
      Elsif (l_app_id = 515) Then
	    FND_ATTACHMENT_UTIL_PKG.function_name := 'OKSAUDET';
	    FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
      End If;
      */
    End If;
  END;

  ----------------------------------------------------------------------------
  -- Function to return the major version of the contract
  -- Major version is required to while copying attachments for
  -- header and line
  ----------------------------------------------------------------------------
  FUNCTION Get_Major_Version(p_chr_id NUMBER) RETURN VARCHAR2 IS

    CURSOR l_cvm_csr IS
    SELECT to_char(major_version)
    FROM okc_k_vers_numbers
    WHERE chr_id = p_chr_id;

    x_from_version  FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE := NULL;

  BEGIN
    open l_cvm_csr;
    fetch l_cvm_csr into x_from_version;
    close l_cvm_csr;

    return x_from_version;
  EXCEPTION
    WHEN OTHERS THEN
	    return OKC_API.G_RET_STS_UNEXP_ERROR;

  END Get_Major_Version;

  ----------------------------------------------------------------------------
  --Proceudre copy_contract_line
  ----------------------------------------------------------------------------
  PROCEDURE copy_contract_line(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_from_chr_id                  IN NUMBER,
    p_to_cle_id                    IN NUMBER ,
    p_to_chr_id                    IN NUMBER ,
    p_lse_id                       IN NUMBER,
    p_to_template_yn               IN VARCHAR2,
    p_copy_reference               IN VARCHAR2 ,
    p_copy_line_party_yn           IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_generate_line_number         IN VARCHAR2 ,
    x_cle_id		           OUT NOCOPY NUMBER,
    p_change_status		          IN VARCHAR2 ) -- LLC Added additional flag parameter to the call
    									    -- to not allow change of status of sublines of the
									    -- topline during update service

    IS

    l_clev_rec 	clev_rec_type;
    x_clev_rec 	clev_rec_type;
    xx_clev_rec     clev_rec_type; ---for Bug#3155217.

    l_sts_code              VARCHAR2(30);
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;
    l_rgp_id			NUMBER;
    l_cat_id			NUMBER;
    l_pav_id			NUMBER;
    l_pat_id                   NUMBER;
    l_pac_id                   NUMBER;
    l_paa_id                   NUMBER;
    l_cpl_id			NUMBER;
    l_start_date      DATE;
    l_end_date        DATE;
    l_old_lse_id		NUMBER;
    l_from_version  FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE;
    l_to_version    FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE;

    l_euro_currency          varchar2(15) := NULL; /* For Euro Conversion - Bug 2155930 */
    l_converted_amount       number := NULL; /* For Euro Conversion - Bug 2155930 */

    l_scrv_id                  NUMBER;

    l_okc_ph_line_breaks_v_id  NUMBER;

    l_gvev_id       NUMBER;
    l_category          VARCHAR2(200); --added for bug 3764231

 --LLC
    l_date_cancelled        DATE := NULL;
    l_trn_code              varchar2(30) := NULL;
    l_term_cancel_source    varchar2(30) := NULL;
    l_cancelled_amount      NUMBER       := NULL;

-- LLC NEW CURSOR

    Cursor get_line_status_csr(p_from_cle_id in number) IS
    select sts_code, date_cancelled, trn_code, term_cancel_source, cancelled_amount
    from okc_k_lines_b
    where id= p_from_cle_id;

-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 1917514
    CURSOR c_pdf IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'COPY'
    AND   cls_code = 'SERVICE';

    l_pdf_id  NUMBER;
     l_cle_id1  NUMBER;
    l_chr_id  NUMBER;
    l_cnt  NUMBER;
    l_string VARCHAR2(32000);
    proc_string VARCHAR2(32000);
-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 1917514

    -- Added for Bug 3764231
    -- cursor to get the contract category

    CURSOR l_Service_Contract_csr IS
    SELECT osb.cls_code
    FROM  okc_subclasses_b osb,okc_k_headers_b okb
    WHERE okb.id = p_from_chr_id
    AND   okb.scs_code = osb.code ;

    -- Added for Bug 3764231

    CURSOR c_dnz_chr_id IS
    SELECT dnz_chr_id
    FROM okc_k_lines_b
    WHERE id = p_to_cle_id;

    CURSOR c_rgpv IS
    SELECT id
    FROM okc_rule_groups_b
    WHERE cle_id = p_from_cle_id;

    CURSOR c_catv IS
    SELECT id
    FROM okc_k_articles_b
    WHERE cle_id = p_from_cle_id;

    CURSOR c_pavv IS
    SELECT id
    FROM okc_price_att_values_v
    WHERE cle_id = p_from_cle_id;

    CURSOR c_patv IS
    SELECT id
    FROM okc_price_adjustments_v
    WHERE cle_id = p_from_cle_id;
    -- Commented 'chr_id IS NOT NULL' as per Bug 2143018
    --AND  chr_id IS NOT NULL;
    -- Added 'chr_id IS NOT NULL ' for Bug 2027165

    CURSOR c_pacv IS
    SELECT id
    FROM okc_price_adj_assocs_v
    WHERE cle_id = p_from_cle_id;

   /* CURSOR c_paav IS
    SELECT id
    FROM okc_price_adj_attribs_v
    WHERE cle_id = p_from_cle_id;
    */

    -- cursor for sales credits
    CURSOR c_scrv IS
    SELECT id
    FROM okc_k_sales_credits_v
    WHERE cle_id = p_from_cle_id
    AND  G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT id
    FROM okc_k_sales_credits_hv
    WHERE cle_id = p_from_cle_id
    AND  major_version = G_FROM_VERSION_NUMBER
    AND  G_COPY_HISTORY_YN = 'Y';

/**********-Bug#3052910 -*********************************
---Removed for Bug#3052910--
---Copy governance for lines is added as a part of PRICE HOLD change,
-- Price hold is obsoleted hence this change is not required*

    -- cursor for governances
    CURSOR  c_governances IS
    SELECT  id
    FROM    okc_governances_v
    WHERE   cle_id = p_from_cle_id
    AND     G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT  id
    FROM    okc_governances_hv
    WHERE   cle_id = p_from_cle_id
    AND     major_version = G_FROM_VERSION_NUMBER
    AND     G_COPY_HISTORY_YN = 'Y';

---Removed for Bug#3052910
-- Bug# 3052910--Price hold is obsoleted hence this change is not required*

    -- cursor for price hold line breaks
    CURSOR c_okc_ph_line_breaks_v IS
    SELECT id
    FROM okc_ph_line_breaks_v
    WHERE cle_id = p_from_cle_id
    AND  G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT id
    FROM okc_ph_line_breaks_hv
    WHERE cle_id = p_from_cle_id
    AND  major_version = G_FROM_VERSION_NUMBER
    AND  G_COPY_HISTORY_YN = 'Y';

******* Bug# 3052910 ********************************/

    -- Pkoganti 08/31, Bug 1392336
    -- Added rle_code <> 'LICENCEE_ACCT'
    -- When the user chooses to copy only the lines, the LICENCEE_ACCT
    -- party role should not be copied, because the target contract
    -- may not have the constraining party information.  This is a temp
    -- fix for GSR.
    --
    CURSOR c_cplv IS
    SELECT id
    FROM okc_k_party_roles_b
    WHERE cle_id = p_from_cle_id
    AND   rle_code <> 'LICENCEE_ACCT'
    and   dnz_chr_id = p_from_chr_id;

    PROCEDURE get_priced_line_rec(p_clev_rec  IN clev_rec_type,
                              x_clev_rec  OUT NOCOPY clev_rec_type) IS
      l_priced_yn VARCHAR2(3);
      l_cim_id    NUMBER;
      l_lty_code  VARCHAR2(90);
      l_clev_rec  clev_rec_type := p_clev_rec;
      l_cimv_rec 	cimv_rec_type;

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

      CURSOR c_lse(p_id IN NUMBER) IS
      SELECT lty_code,
             priced_yn
      FROM   okc_line_styles_b
      WHERE  id = p_id;

      CURSOR c_cim(p_cle_id IN NUMBER) IS
      SELECT id
      FROM   okc_k_items_v
      WHERE  cle_id = p_cle_id
      AND    priced_item_yn = 'Y';

    BEGIN
      OPEN c_lse(l_clev_rec.lse_id);
      FETCH c_lse INTO l_lty_code,l_priced_yn;
      CLOSE c_lse;

      IF l_clev_rec.price_level_ind = 'N' THEN
        IF l_priced_yn = 'N' THEN
          l_clev_rec.price_negotiated := NULL;
        ELSE
          l_clev_rec.price_negotiated := NULL;
          IF l_lty_code <> 'FREE_FORM' THEN
            l_clev_rec.name := NULL;
          END IF;
        END IF;
      ELSE
        IF l_priced_yn = 'N' THEN
          l_clev_rec.price_negotiated := NULL;
          l_clev_rec.PRICE_UNIT := NULL;
          IF l_lty_code <> 'FREE_FORM' THEN
            l_clev_rec.name := NULL;
          END IF;
        ELSE
          OPEN c_cim(l_clev_rec.id);
          FETCH c_cim INTO l_cim_id;
          CLOSE c_cim;

          IF l_cim_id IS NOT NULL THEN
            l_return_status := get_cimv_rec(	p_cim_id 	=> l_cim_id,
    					x_cimv_rec 	=> l_cimv_rec);
            OKC_CONTRACT_ITEM_PUB.validate_contract_item(
      	          p_api_version	=> p_api_version,
                 p_init_msg_list	=> p_init_msg_list,
                 x_return_status 	=> l_return_status,
                 x_msg_count     	=> x_msg_count,
                 x_msg_data      	=> x_msg_data,
                 p_cimv_rec		=> l_cimv_rec);

             IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               l_clev_rec.price_negotiated := NULL;
               l_clev_rec.PRICE_UNIT := NULL;
               l_clev_rec.name := NULL;
             END IF;
           END IF;
         END IF;
      END IF;
      x_clev_rec := l_clev_rec;
    exception when others then
      x_clev_rec := l_clev_rec;
    END get_priced_line_rec;

    PROCEDURE instantiate_counters_events (
         p_api_version    IN NUMBER,
         p_init_msg_list  IN VARCHAR2 ,
         x_return_status  OUT NOCOPY VARCHAR2,
         x_msg_count      OUT NOCOPY NUMBER,
         x_msg_data       OUT NOCOPY VARCHAR2,
         p_old_cle_id     IN  NUMBER,
         p_old_lse_id     IN  NUMBER,
         p_start_date     IN  DATE,
         p_end_date       IN  DATE,
         p_new_cle_id     IN  NUMBER) IS

      l_item_id             VARCHAR2(40);
      l_counter_grp_id	   NUMBER;
      l_found               BOOLEAN;
      l_return_status	   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ctr_grp_id_template NUMBER;
      l_ctr_grp_id_instance NUMBER;
      l_instcnd_inp_rec     OKC_INST_CND_PUB.instcnd_inp_rec;
      l_ac_rec OKS_COVERAGES_PUB.ac_rec_type;
      l_actual_coverage_id NUMBER;

      CURSOR c_item IS
      SELECT object1_id1
      FROM   okc_k_items_v
      WHERE  cle_id = p_old_cle_id;

      Cursor l_ctr_csr (p_id Number) Is
	 Select Counter_Group_id
	 From   OKX_CTR_ASSOCIATIONS_V
	 Where  Source_Object_Id = p_id;

      CURSOR c_cov_temp(p_item_id IN NUMBER) IS
      SELECT coverage_template_id
      FROM   okx_system_items_v
      WHERE  id1 = p_item_id;

    BEGIN
      x_return_status := l_return_status;
      OPEN c_item;
      FETCH c_item INTO l_item_id;
      CLOSE c_item;

      IF l_item_id IS NOT NULL AND Is_Number(l_item_id) THEN

	    -- Check whether counters are attached to the item
	    OPEN l_ctr_csr(l_item_id);
	    FETCH l_ctr_csr INTO l_counter_grp_id;
         l_found := l_ctr_csr%FOUND;
	    CLOSE l_ctr_csr;

        If (l_found) Then
		   CS_COUNTERS_PUB.AUTOINSTANTIATE_COUNTERS(
			 p_api_version               => p_api_version,
			 p_init_msg_list             => p_init_msg_list,
			 x_return_status             => l_return_status,
			 x_msg_count                 => x_msg_count,
			 x_msg_data             	    => x_msg_data,
			 p_commit                    => 'F',
			 p_source_object_id_template => l_item_id,
			 p_source_object_id_instance => p_new_cle_id,
			 x_ctr_grp_id_template       => l_ctr_grp_id_template,
			 x_ctr_grp_id_instance       => l_ctr_grp_id_instance);

		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		   END IF;

		   l_instcnd_inp_rec.ins_ctr_grp_id   := l_ctr_grp_id_instance;
		   l_instcnd_inp_rec.tmp_ctr_grp_id   := l_ctr_grp_id_template;
		   l_instcnd_inp_rec.jtot_object_code := 'OKC_K_LINE';
		   l_instcnd_inp_rec.cle_id           := p_new_cle_id;

		   OKC_INST_CND_PUB.INST_CONDITION(
			 p_api_version               => p_api_version,
			 p_init_msg_list             => p_init_msg_list,
			 x_return_status             => l_return_status,
			 x_msg_count                 => x_msg_count,
			 x_msg_data             	    => x_msg_data,
			 p_instcnd_inp_rec           => l_instcnd_inp_rec);

		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			x_return_status := l_return_status;
			RAISE G_EXCEPTION_HALT_VALIDATION;
		   END IF;
          End If;
      END IF;

      IF p_old_lse_id <> 1 THEN --the service line is copied from different line style id.
        -- Instantiate the coverage.
        l_ac_rec.svc_cle_id := p_new_cle_id;
        l_ac_rec.start_date := p_start_date;
        l_ac_rec.end_date   := p_end_date;

        OPEN c_cov_temp(to_number(l_item_id));
        FETCH c_cov_temp INTO l_ac_rec.tmp_cle_id;
        CLOSE c_cov_temp;

        IF l_ac_rec.tmp_cle_id IS NOT NULL THEN
          OKS_COVERAGES_PUB.CREATE_ACTUAL_COVERAGE(
             p_api_version               => p_api_version,
             p_init_msg_list             => p_init_msg_list,
             x_return_status             => l_return_status,
             x_msg_count                 => x_msg_count,
             x_msg_data             	    => x_msg_data,
             p_ac_rec_in            	    => l_ac_rec,
             x_actual_coverage_id   	    => l_actual_coverage_id);
        END IF;

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      END IF;
    EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END instantiate_counters_events;

    FUNCTION get_parent_date(p_from_start_date IN DATE,
                             p_from_end_date   IN DATE,
                             p_to_cle_id       IN NUMBER,
                             p_to_chr_id       IN NUMBER,
                             x_start_date      OUT NOCOPY DATE,
                             x_end_date        OUT NOCOPY DATE) RETURN BOOLEAN IS

      l_parent_start_date      DATE;
      l_parent_end_date        DATE;

	 CURSOR  c_cle IS
      SELECT  start_date,end_date
      FROM    okc_k_lines_b
      WHERE   id = p_to_cle_id;

	 CURSOR  c_chr IS
      SELECT  start_date,end_date
      FROM    okc_k_headers_b
      WHERE   id = p_to_chr_id;

    BEGIN
      IF (p_to_chr_id IS NULL OR p_to_chr_id = OKC_API.G_MISS_NUM) THEN
        OPEN c_cle;
        FETCH c_cle INTO l_parent_start_date,l_parent_end_date;
        CLOSE c_cle;
        IF (NVL(p_from_start_date,sysdate)
           BETWEEN NVL(l_parent_start_date,sysdate) AND NVL(l_parent_end_date,sysdate)) AND
           (NVL(p_from_end_date,sysdate)
           BETWEEN NVL(l_parent_start_date,sysdate) AND NVL(l_parent_end_date,sysdate)) THEN
           RETURN(TRUE);
        ELSE
           x_start_date := l_parent_start_date;
           x_end_date := l_parent_end_date;
           RETURN(FALSE);
        END IF;
      ELSE
        OPEN c_chr;
        FETCH c_chr INTO l_parent_start_date,l_parent_end_date;
        CLOSE c_chr;
        IF (NVL(p_from_start_date,sysdate)
           BETWEEN NVL(l_parent_start_date,sysdate) AND NVL(l_parent_end_date,sysdate)) AND
           (NVL(p_from_end_date,sysdate)
           BETWEEN NVL(l_parent_start_date,sysdate) AND NVL(l_parent_end_date,sysdate)) THEN
           RETURN(TRUE);
        ELSE
           x_start_date := l_parent_start_date;
           x_end_date := l_parent_end_date;
           RETURN(FALSE);
       END IF;
     END IF;
     RETURN(TRUE);
    END get_parent_date;

  ----------------------------------------------------------------------------
  -- Proceduere to create operation operation lines for contract lines
  -- in case of RENEW
  -- Parameters: p_from_cle_id - object_cle_id
  --             p_to_cle_id   - subject_cle_id
  ----------------------------------------------------------------------------
  PROCEDURE Create_Renewal_Line_Link (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_to_chr_id                    IN NUMBER,
    p_to_cle_id                    IN NUMBER)
  IS

    -- Cursor to get operation instance id
    Cursor oie_csr Is
		 SELECT id
		 FROM okc_operation_instances
		 WHERE target_chr_id = p_to_chr_id;

    l_oie_id        NUMBER;
    l_olev_rec      OKC_OPER_INST_PUB.olev_rec_type;
    lx_olev_rec     OKC_OPER_INST_PUB.olev_rec_type;
    i NUMBER := 0;
    l_count  NUMBER;

    ----------------------------------------------------------------------------
    -- Function to find whether the line is a top line or not
    -- Returns header id if the line is a top line, else return parent line id
    ----------------------------------------------------------------------------
    FUNCTION get_parent_id(p_cle_id IN NUMBER) RETURN NUMBER IS
	 Cursor cle_csr Is
		   SELECT nvl(chr_id , cle_id)
		   FROM   okc_k_lines_b
		   WHERE  id = p_cle_id;
    l_parent_id NUMBER := -1;
    BEGIN
	 open cle_csr;
	 fetch cle_csr into l_parent_id;
	 close cle_csr;

	 return l_parent_id;
    END get_parent_id;

    ----------------------------------------------------------------------------
    -- Function to find parent ole id from g_op_lines PL/SQL table
    ----------------------------------------------------------------------------
    FUNCTION get_parent_ole_id(p_id IN NUMBER) RETURN NUMBER IS
      i NUMBER := 0;
    BEGIN
      IF g_op_lines.COUNT > 0 THEN
        i := g_op_lines.FIRST;
        LOOP
          IF g_op_lines(i).id = p_id THEN
            return(g_op_lines(i).ole_id);
          END IF;
          EXIT WHEN (i = g_op_lines.LAST);
          i := g_op_lines.NEXT(i);
        END LOOP;
      END IF;
      return(-1);
    EXCEPTION
      WHEN OTHERS THEN
        return(-1);
    END get_parent_ole_id;

  BEGIN

    -- get class operation id
    open oie_csr;
    fetch oie_csr into l_oie_id;
    close oie_csr;

    l_olev_rec.SELECT_YN      := NULL;
    l_olev_rec.ACTIVE_YN      := 'Y';
    l_olev_rec.PROCESS_FLAG   := 'P';
    l_olev_rec.OIE_ID         := l_oie_id;
    l_olev_rec.SUBJECT_CHR_ID := p_to_chr_id;
    l_olev_rec.OBJECT_CHR_ID  := p_from_chr_id;
    l_olev_rec.SUBJECT_CLE_ID := p_to_cle_id;
    l_olev_rec.OBJECT_CLE_ID  := p_from_cle_id;
    l_olev_rec.PARENT_OLE_ID  := get_parent_ole_id(get_parent_id(p_from_cle_id));

    OKC_OPER_INST_PUB.Create_Operation_Line (
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_olev_rec		=> l_olev_rec,
            x_olev_rec		=> lx_olev_rec);

    -- set g_op_lines table
    l_count := g_op_lines.COUNT + 1;
    g_op_lines(l_count).id     := p_from_cle_id;
    g_op_lines(l_count).ole_id := lx_olev_rec.ID;

  EXCEPTION
    when NO_DATA_FOUND then
	  -- store SQL error message on message stack
	  x_return_status := OKC_API.G_RET_STS_ERROR;
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> 'OKC_NOT_FOUND',
					  p_token1		=> 'VALUE1',
					  p_token1_value	=> 'Status Code',
					  p_token2		=> 'VALUE2',
					  p_token2_value	=> 'OKC_CLASS_OPERATIONS_V');
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Create_Renewal_Line_Link;

  BEGIN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' copy_contract_line ');
   OKC_DEBUG.log('100 : Entering  copy_contract_line  ', 2);
   OKC_DEBUG.log('100 : p_from_cle_id : '||p_from_cle_id);
   OKC_DEBUG.log('100 : p_from_chr_id : '||p_from_chr_id);
   OKC_DEBUG.log('100 : p_to_cle_id : '||p_to_cle_id);
   OKC_DEBUG.log('100 : p_to_chr_id : '||p_to_chr_id);
   OKC_DEBUG.log('100 : p_lse_id : '||p_lse_id);
   OKC_DEBUG.log('100 : p_to_template_yn : '||p_to_template_yn);
   OKC_DEBUG.log('100 : p_copy_reference : '||p_copy_reference);
   OKC_DEBUG.log('100 : p_copy_line_party_yn : '||p_copy_line_party_yn);
   OKC_DEBUG.log('100 : p_renew_ref_yn : '||p_renew_ref_yn);
   OKC_DEBUG.log('100 : p_generate_line_number : '||p_generate_line_number);
   OKC_DEBUG.log('100 : *************************************************** ');
END IF;

    IF g_price_adjustments.COUNT > 0 THEN
       g_price_adjustments.DELETE;
    END IF;

    x_return_status := l_return_status;
    l_return_status := get_clev_rec(p_cle_id 	=> p_from_cle_id,
                                    p_renew_ref_yn  => p_renew_ref_yn, -- Added for bugfix 2307197
					x_clev_rec 	=> l_clev_rec);
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('110 : After get_clev_rec ',2);
   OKC_DEBUG.log('110 : l_return_status : '||l_return_status);
   OKC_DEBUG.log('110 : l_clev_rec.id : '||l_clev_rec.id);
   OKC_DEBUG.log('110 : l_clev_rec.chr_id : '||l_clev_rec.chr_id);
   OKC_DEBUG.log('110 : l_clev_rec.dnz_chr_id : '||l_clev_rec.dnz_chr_id);
END IF;

-- Bug 2489856
 -- If it is not a case of Renew and line numbers are required to be generated, then reset line_number to Null
    if p_renew_ref_yn <> 'Y' then
       if p_generate_line_number = 'Y' then
           l_clev_rec.line_number := NULL;
       end if;
    end if;
-- End Bug 2489856

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('200 : In copy_contract_line ',2);
   OKC_DEBUG.log('200 : p_renew_ref_yn : '||p_renew_ref_yn);
END IF;
    --
    -- If copy called for renewal, do not copy renewed lines
    --
    IF p_renew_ref_yn = 'Y' AND l_clev_rec.date_renewed is not null THEN
	  return;
    END IF;
    --
    -- If copy called for renewal, do not copy terminated lines (Bug 2157087)
    --
    IF p_renew_ref_yn = 'Y' AND l_clev_rec.date_terminated is not null THEN
	  return;
    END IF;

    /* Fixing Renewal for Euro Conversion - at Line Level -  Bug 2155930 */

    if (p_renew_ref_yn = 'Y') then

       l_euro_currency := OKC_CURRENCY_API.GET_EURO_CURRENCY_CODE(l_clev_rec.currency_code);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('300 : l_euro_currency : '||l_euro_currency);
END IF;

        if (l_euro_currency <> l_clev_rec.currency_code) then

           OKC_CURRENCY_API.CONVERT_AMOUNT
                         (p_FROM_CURRENCY => l_clev_rec.currency_code,
                          p_TO_CURRENCY => l_euro_currency,
                          p_CONVERSION_DATE => g_conversion_date,
                          p_CONVERSION_TYPE => g_conversion_type,
                          p_AMOUNT => l_clev_rec.price_negotiated,
                          x_CONVERSION_RATE => g_conversion_rate,
                          x_CONVERTED_AMOUNT => l_converted_amount
                         );
           l_clev_rec.price_negotiated := l_converted_amount;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('350 : l_converted_amount : '||l_converted_amount);
END IF;

           OKC_CURRENCY_API.CONVERT_AMOUNT
                         (p_FROM_CURRENCY => l_clev_rec.currency_code,
                          p_TO_CURRENCY => l_euro_currency,
                          p_CONVERSION_DATE => g_conversion_date,
                          p_CONVERSION_TYPE => g_conversion_type,
                          p_AMOUNT => l_clev_rec.price_unit,
                          x_CONVERSION_RATE => g_conversion_rate,
                          x_CONVERTED_AMOUNT => l_converted_amount
                         );
           l_clev_rec.price_unit := l_converted_amount;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('400 : l_converted_amount : '||l_converted_amount);
END IF;


/* Commented out nocopy as line_list_price is in 11.5.6 and not available here
           OKC_CURRENCY_API.CONVERT_AMOUNT
                         (p_FROM_CURRENCY => l_clev_rec.currency_code,
                          p_TO_CURRENCY => l_euro_currency,
                          p_CONVERSION_DATE => g_conversion_date,
                          p_CONVERSION_TYPE => g_conversion_type,
                          p_AMOUNT => l_clev_rec.line_list_price,
                          x_CONVERSION_RATE => g_conversion_rate,
                          x_CONVERTED_AMOUNT => l_converted_amount
                         );
           l_clev_rec.line_list_price := l_converted_amount;
*/
           l_clev_rec.currency_code := l_euro_currency;

--/rules migration/
-- update price list at line level instead of rules
		If g_pricelist is not null  AND
             g_application_id not in (510,871) Then
	      	l_clev_rec.price_list_id:= g_pricelist;
	     End if;


IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('450 : l_euro_currency : '||l_euro_currency);
END IF;

       end if;
    end if;

    IF p_to_chr_id IS NULL OR p_to_chr_id = OKC_API.G_MISS_NUM THEN
      OPEN c_dnz_chr_id;
      FETCH c_dnz_chr_id INTO l_clev_rec.dnz_chr_id;
      CLOSE c_dnz_chr_id;
    ELSE
      l_clev_rec.dnz_chr_id := p_to_chr_id;
    END IF;


    l_clev_rec.cle_id := p_to_cle_id;
    l_clev_rec.chr_id := p_to_chr_id;
    l_clev_rec.trn_code    := NULL;
    l_clev_rec.date_terminated    := NULL;

--LLC

   l_clev_rec.date_cancelled := NULL;
   l_clev_rec.term_cancel_source := NULL;
   l_clev_rec.cancelled_amount :=NULL;

     IF (p_change_status ='N') THEN  --status of sublines to retained after update service

        Open    get_line_status_csr (p_from_cle_id);
        Fetch   get_line_status_csr Into l_sts_code, l_date_cancelled, l_trn_code, l_term_cancel_source, l_cancelled_amount;
        Close   get_line_status_csr;

	   l_clev_rec.date_cancelled := l_date_cancelled;
	   l_clev_rec.trn_code := l_trn_code;
        l_clev_rec.term_cancel_source := l_term_cancel_source;
        l_clev_rec.cancelled_amount := l_cancelled_amount;

    ELSE  --status of subline of the defaulted to ENTERED status

 	okc_assent_pub.get_default_status( x_return_status => l_return_status,
							    p_status_type  => 'ENTERED',
							    x_status_code  => l_sts_code);

    END IF; --p_change_status ='N'

--LLC

    l_clev_rec.sts_code := l_sts_code;


IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('500 : x_return_status : '||l_return_status);
   OKC_DEBUG.log('500 : l_sts_code : '||l_sts_code);
END IF;

    IF NOT get_parent_date(p_from_start_date => l_clev_rec.start_date,
                       p_from_end_date   => l_clev_rec.end_date,
                       p_to_cle_id       => p_to_cle_id,
                       p_to_chr_id       => p_to_chr_id,
                       x_start_date      => l_start_date,
                       x_end_date        => l_end_date) THEN
      -- If the line dates are not in between its parents date default to parent date.
      l_clev_rec.start_date := l_start_date;
      l_clev_rec.end_date := l_end_date;
    END IF;

    l_old_lse_id := l_clev_rec.lse_id;

    IF p_renew_ref_yn = 'Y' THEN
	  l_clev_rec.PRICE_NEGOTIATED_RENEWED := l_clev_rec.PRICE_NEGOTIATED;
	  l_clev_rec.CURRENCY_CODE_RENEWED := l_clev_rec.CURRENCY_CODE;
    END IF;

    IF p_lse_id IS NOT NULL THEN
       l_clev_rec.lse_id := p_lse_id;
    END IF;
    -- Modified for Bug 2480813
    -- No need to call get_priced_line_rec in case of RENEW
    IF p_renew_ref_yn = 'N' THEN
       ---get_priced_line_rec(l_clev_rec,l_clev_rec);
	  get_priced_line_rec(l_clev_rec,xx_clev_rec);  --- For Bug#3155217.
          --xx_clev_rec holds the value of output.
          l_clev_rec :=  xx_clev_rec ; --- For Bug#3155217.
    END IF;

    --get_priced_line_rec(l_clev_rec,l_clev_rec);  -- commented for Bug 2480813

    l_clev_rec.orig_system_source_code  := 'OKC_LINE';
    l_clev_rec.orig_system_id1 		:= p_from_cle_id;
    l_clev_rec.orig_system_reference1   := NULL;
    -- Bug 1975070 - Date Renewed, Date Terminated should be Null after Copy
    l_clev_rec.date_renewed    		:= NULL;
    l_clev_rec.date_terminated 		:= NULL;
    -- Bug 1975070


    -- new price hold column
    l_clev_rec.ph_qp_reference_id       := NULL;
    l_clev_rec.ph_integrated_with_qp    := 'N';

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('550 : Calling OKC_CONTRACT_PUB.create_contract_line ');
   OKC_DEBUG.log('550 : l_clev_rec.id : '||l_clev_rec.id);
   OKC_DEBUG.log('550 : l_clev_rec.chr_id : '||l_clev_rec.chr_id);
   OKC_DEBUG.log('550 : l_clev_rec.dnz_chr_id : '||l_clev_rec.dnz_chr_id);
END IF;

    OKC_CONTRACT_PUB.create_contract_line(
           p_api_version      => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_clev_rec		=> l_clev_rec,
           x_clev_rec		=> x_clev_rec);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('555 : After OKC_CONTRACT_PUB.create_contract_line ');
   OKC_DEBUG.log('555 : x_return_status : '||l_return_status);
   OKC_DEBUG.log('555 : x_msg_count : '||x_msg_count);
   OKC_DEBUG.log('555 : x_msg_data : '||x_msg_data);
END IF;

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    x_cle_id := x_clev_rec.id; -- passes the new generated id to the caller.

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('650 : After OKC_CONTRACT_PUB.create_contract_line ');
   OKC_DEBUG.log('650 : x_return_status : '||l_return_status);
   OKC_DEBUG.log('650 : x_cle_id : '||x_cle_id);
END IF;

    IF p_renew_ref_yn = 'Y' THEN
       --if the copy is for RENEW, create operation line
       Create_Renewal_Line_Link(
	      p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
		 p_to_chr_id        => l_clev_rec.dnz_chr_id,
		 p_to_cle_id        => x_cle_id);

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;

    -- copy associated attachments
    l_from_version := Get_Major_Version(p_from_chr_id);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('750 : l_from_version : '||l_from_version);
END IF;

    IF (l_from_version = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- set attachement session variables
    -- before calling fnd_attachment_util_pkg.get_atchmt_exists
    Set_Attach_Session_Vars(x_clev_rec.dnz_chr_id);

    If (fnd_attachment_util_pkg.get_atchmt_exists (
			  l_entity_name => 'OKC_K_LINES_B',
			  l_pkey1 => p_from_cle_id,
			  l_pkey2 => l_from_version) = 'Y')

			  -- The following line to be added to the code once
			  -- bug 1553916 completes
			  -- ,l_pkey2 => l_from_version) = 'Y')
			  -- also below remove the comments
			  -- in fnd_attached_documents2_pkg.copy_attachments call
    Then
	   l_to_version := Get_Major_Version(x_clev_rec.dnz_chr_id);

        fnd_attached_documents2_pkg.copy_attachments(
                          x_from_entity_name => 'OKC_K_LINES_B',
                          x_from_pk1_value   => p_from_cle_id,
                          x_from_pk2_value   => l_from_version,
                          x_to_entity_name => 'OKC_K_LINES_B',
                          x_to_pk1_value   => x_clev_rec.id,
                          x_to_pk2_value   => l_to_version
					 );
    End if;

    IF l_clev_rec.lse_id = 1 THEN
      instantiate_counters_events(
           p_api_version               => p_api_version,
           p_init_msg_list             => p_init_msg_list,
           x_return_status             => l_return_status,
           x_msg_count                 => x_msg_count,
           x_msg_data             	    => x_msg_data,
           p_old_cle_id           	    => l_clev_rec.id,
           p_old_lse_id           	    => l_old_lse_id,
           p_start_date           	    => x_clev_rec.start_date,
           p_end_date           	    => x_clev_rec.end_date,
           p_new_cle_id           	    => x_clev_rec.id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('850 : ');
END IF;

    --
    -- Bug 3611000
    -- Rules may exist for pre-11.5.10 contracts - they should not be tried to copy in 11.5.10 onwards for service contracts
    --
    IF G_APPLICATION_ID <> 515 THEN

    FOR l_c_rgpv IN c_rgpv LOOP
      l_old_return_status := l_return_status;
      copy_rules (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_rgp_id		     => l_c_rgpv.id,
           p_cle_id		     => x_clev_rec.id,
           p_chr_id		     => NULL,
		 p_to_template_yn   => p_to_template_yn,
           x_rgp_id		     => l_rgp_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
            x_return_status := l_return_status;
          END IF;
        END IF;
      END IF;
    END LOOP;

    l_old_return_status := l_return_status;

    END IF; -- G_APPLICATION_ID <> 515

    FOR l_c_catv IN c_catv LOOP
      copy_articles (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cat_id		=> l_c_catv.id,
           p_cle_id		=> x_clev_rec.id,
           p_chr_id		=> NULL,
           x_cat_id		=> l_cat_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    l_old_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('950 : ');
END IF;

    FOR l_c_pavv IN c_pavv LOOP
      copy_price_att_values (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_pav_id		=> l_c_pavv.id,
           p_cle_id		=> x_clev_rec.id,
           p_chr_id		=> NULL,
           x_pav_id		=> l_pav_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    l_old_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1100 : ');
END IF;

     FOR l_c_patv IN c_patv LOOP
      copy_price_adjustments (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_pat_id             => l_c_patv.id,
           p_cle_id             => x_clev_rec.id,
           p_chr_id             => x_clev_rec.dnz_chr_id,
         --p_chr_id             => NULL,  Modified for Bug 2027165
           x_pat_id             => l_pat_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1200 : ');
END IF;

    copy_price_adj_attribs (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
            p_paa_id             => NULL,
           p_pat_id             => l_c_patv.id
           );

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    l_old_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1300 : ');
END IF;

         FOR l_c_pacv IN c_pacv LOOP
      copy_price_adj_assocs (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_pac_id             => l_c_pacv.id,
           p_cle_id             => x_clev_rec.id,
           p_pat_id             => NULL,
           x_pac_id             => l_pac_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    l_old_return_status := l_return_status;

   /*   FOR l_c_paav IN c_paav LOOP
      copy_price_adj_attribs (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_paa_id             => l_c_paav.id,
           p_pat_id             => NULL,
           x_paa_id             => l_paa_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    l_old_return_status := l_return_status;
 */

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1400 : ');
END IF;

    FOR l_c_scrv IN c_scrv LOOP
      copy_sales_credits (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_scrv_id            => l_c_scrv.id,
           p_cle_id		=> x_clev_rec.id,
           p_chr_id		=> g_chrv_rec.id, --NULL,  --must always have a value in sales credits table
           x_scrv_id		=> l_scrv_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1500 : ');
END IF;

/******* commented For Bug# 3052910 ***************************
-- Copy_governance for lines is added for Price_hold. Bug#2399377 .
-- and Price Hold is obsoleted hence the code is commented.

    FOR l_c_governances IN c_governances LOOP

      copy_governances (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_gvev_id            => l_c_governances.id,
           p_cle_id		=> x_clev_rec.id,
           p_chr_id		=> g_chrv_rec.id,

           x_gvev_id		=> l_gvev_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
	     x_return_status := l_return_status;
         END IF;
      END IF;
    END LOOP;
*************commented For Bug# 3052910 *******************/

/*****Commented For Bug# 3052910 **********************************
-- price hold is  added for Bug#2399377 and it is obsoleted ,
-- hence the following code is commented.

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1600 : ');
END IF;

    FOR l_c_okc_ph_line_breaks_v IN c_okc_ph_line_breaks_v LOOP

       copy_price_hold_line_breaks (
	   p_api_version                  => p_api_version,
           p_init_msg_list	          => p_init_msg_list,
           x_return_status 	          => l_return_status,
           x_msg_count     	          => x_msg_count,
           x_msg_data      	          => x_msg_data,
           p_okc_ph_line_breaks_v_rec_id  => l_c_okc_ph_line_breaks_v.id,
           p_cle_id		          => x_clev_rec.id,
           x_okc_ph_line_breaks_v_rec_id  => l_okc_ph_line_breaks_v_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

*****Commented For Bug# 3052910 ************************************/

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1700 : ');
END IF;


    IF p_copy_line_party_yn = 'Y' THEN
      FOR l_c_cplv IN c_cplv LOOP
        l_old_return_status := l_return_status;
        copy_party_roles (
             p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_cpl_id		=> l_c_cplv.id,
             p_cle_id		=> x_clev_rec.id,
             p_chr_id		=> NULL,
             p_rle_code         => NULL,
             x_cpl_id		=> l_cpl_id);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
      END LOOP;
    END IF;

    l_old_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1800 : ');
END IF;

    copy_items (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_cle_id	=> p_from_cle_id,
           p_copy_reference     => p_copy_reference,
           p_to_cle_id		=> x_clev_rec.id);


    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
-- bug 2667634 start  , changes commented for bug 2774888
-- IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) OR (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
-- bug 2667634 end
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
          x_return_status := OKC_API.G_RET_STS_WARNING;
        END IF;
      END IF;
    END IF;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('2000 : ');
END IF;


      --Changes done for Bug 3764231 to execute the dynamic SQL only for service contracts
      OPEN l_Service_Contract_csr;
      FETCH l_Service_Contract_csr into l_category;
      CLOSE l_Service_Contract_csr;
      --Changes done for Bug 3764231 to execute the dynamic SQL only for service contracts

      -- Begin - Changes done for Bug 1917514

      -- Need to check if this procedure is already called from Copy Header or not
      -- If it is already called then l_oks_copy is alreadt set to N then donot
      -- need to execute this logic otherwise need to execute
  IF l_category = 'SERVICE' then   --Bug 3764231
   IF l_oks_copy = 'Y' THEN -- Begin -Copy is called from Line
      l_chr_id := l_clev_rec.dnz_chr_id ;
      l_cle_id1 := x_clev_rec.id;
   OPEN c_pdf;
   FETCH c_pdf INTO l_pdf_id;
      okc_create_plsql (p_pdf_id => l_pdf_id,
                    x_string => l_string) ;
   CLOSE c_pdf;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('2100 : l_string : '||l_string);
END IF;
    IF l_string is NOT NULL THEN   -- Begin L_STRING IF
       proc_string := 'begin '||l_string || ' (:b1,:b2,:b3); end ;';
       EXECUTE IMMEDIATE proc_string using l_chr_id,l_cle_id1, out l_return_status; -- Bugfix 2151523(1917514) - changed l_cle_id to l_cle_id1.

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
            x_return_status := l_return_status;
         END IF;
    END IF;  -- End L_STRING IF

   END IF;  -- End - Copy is called from Line
 END IF; -- End l_category ='SERVICE'
  -- End - Changes done for Bug 1917514

  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('10000 : Exiting Procedure copy_contract_line ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('20000 : Exiting Procedure copy_contract_line ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('30000 : SQLCODE : '||SQLCODE);
     OKC_DEBUG.log('30000 : SQLERRM : '||SQLERRM);
     OKC_DEBUG.log('30000 : Exiting Procedure copy_contract_line ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_contract_line;

  ----------------------------------------------------------------------------
  --Proceudre copy_contract_lines.
  --This procedure copies the given line and its children
  --(eg sub lines, rules etc.)
  ----------------------------------------------------------------------------
  PROCEDURE copy_contract_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_to_cle_id                    IN NUMBER,
    p_to_chr_id                    IN NUMBER,
    p_to_template_yn               IN VARCHAR2,
    p_copy_reference               IN VARCHAR2,
    p_copy_line_party_yn           IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_generate_line_number         IN VARCHAR2 ,
    x_cle_id	                   OUT NOCOPY NUMBER,
    p_change_status		          IN VARCHAR2) -- LLC Added an additional flag parameter, p_change_status,
    									   -- to decide whether to allow change of status of sublines
									   -- of the topline during update service

    IS

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id			NUMBER := OKC_API.G_MISS_NUM;
    l_cle_id_out		NUMBER := OKC_API.G_MISS_NUM;
    i 				NUMBER := 0;
    l_lse_id            NUMBER := OKC_API.G_MISS_NUM;

    TYPE lines_rec_type IS RECORD (
      level                        NUMBER := OKC_API.G_MISS_NUM,
      line_id                      NUMBER := OKC_API.G_MISS_NUM,
      new_line_id                  NUMBER := OKC_API.G_MISS_NUM,
      cle_id                       NUMBER := OKC_API.G_MISS_NUM,
      new_cle_id                   NUMBER := OKC_API.G_MISS_NUM,
	 ole_id                       NUMBER := OKC_API.G_MISS_NUM);

    TYPE lines_tbl_type IS TABLE OF lines_rec_type
      INDEX BY BINARY_INTEGER;

    l_lines_rec 	lines_rec_type;
    l_lines_tbl 	lines_tbl_type;

    CURSOR	c_lines IS
    SELECT 	level,
		id,
		chr_id,
		cle_id,
		dnz_chr_id,
                lse_id
    FROM 	okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_from_cle_id;

    CURSOR	c_application_id IS
    SELECT 	chr.application_id
    FROM 	okc_k_headers_b chr,
                okc_k_lines_b cle
    WHERE       chr.id = cle.dnz_chr_id
    AND         cle.id = p_from_cle_id;
  ----------------------------------------------------------------------------
  -- Function to find the new cle_id.
  ----------------------------------------------------------------------------
    FUNCTION    get_new_cle_id(p_line_id IN NUMBER,
				p_cle_id IN NUMBER,
				p_new_cle_id OUT NOCOPY NUMBER)
    				RETURN VARCHAR2 IS
      l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      i 			  NUMBER := 0;
    BEGIN

      IF l_lines_tbl.COUNT > 0 THEN
        i := l_lines_tbl.FIRST;
        LOOP
          IF l_lines_tbl(i).line_id = p_cle_id THEN
            p_new_cle_id := l_lines_tbl(i).new_line_id;
            return(l_return_status);
          END IF;
          EXIT WHEN (i = l_lines_tbl.LAST);
          i := l_lines_tbl.NEXT(i);
        END LOOP;
      END IF;
      l_return_status := OKC_API.G_RET_STS_ERROR;
      return(l_return_status);
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_new_cle_id;

  ----------------------------------------------------------------------------
  --Proceudre body copy_contract_lines begins
  ----------------------------------------------------------------------------
  BEGIN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' copy_contract_lines ');
   OKC_DEBUG.log('100 : Entering  copy_contract_lines  ', 2);
END IF;

x_return_status := l_return_status;

--Initialized g_application_id for bug 3948599
    OPEN c_application_id;
    FETCH c_application_id INTO g_application_id;
    CLOSE c_application_id;

    FOR l_c_lines IN c_lines
    LOOP
      i := i+1;
      l_lines_tbl(i).level := l_c_lines.level;
      l_lines_tbl(i).line_id := l_c_lines.id;
      l_lines_tbl(i).cle_id := l_c_lines.cle_id;
      l_lse_id := l_c_lines.lse_id;
      IF l_c_lines.level = 1 THEN
        --Bug:3668722 As line with lse=20 is already copied by call to copy_contract_line
        --from copy_components,In the if part just preserve the cle_id for copying lines
        --with lse(21,22,23)
        IF l_lse_id = 20 then
          l_cle_id_out := p_to_cle_id;
        Else
        copy_contract_line(
	   p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_cle_id		=> l_c_lines.id,
           p_from_chr_id		=> l_c_lines.dnz_chr_id,
	   p_to_cle_id 		=> P_to_cle_id,
	   p_to_chr_id		=> p_to_chr_id,
	   p_lse_id           => NULL,
	   p_to_template_yn     => p_to_template_yn,
           p_copy_reference     => 'COPY',
           p_copy_line_party_yn => 'Y',
	   p_renew_ref_yn     => p_renew_ref_yn,
           p_generate_line_number  => p_generate_line_number, --Bug 2489856
           x_cle_id		=> l_cle_id_out,
	   p_change_status      => p_change_status); -- LLC Added an additional flag parameter, p_change_status,
	   									-- to decide whether to allow change of status of sublines
										-- of the topline during update service

           x_cle_id := l_cle_id_out; -- only the 1st level line id generated is passed out.
        END IF;--IF l_lse_id = 20 then
      ELSE
        l_return_status := get_new_cle_id(p_line_id 	=> l_c_lines.id,
					p_cle_id 	=> l_c_lines.cle_id,
					p_new_cle_id    => l_cle_id);

        copy_contract_line (
	   p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_cle_id	     => l_c_lines.id,
           p_from_chr_id		=> l_c_lines.dnz_chr_id,
	   p_to_cle_id 		=> l_cle_id, -- the new generated parent line id.
	   p_to_chr_id		=> NULL,
	   p_lse_id           => NULL,
	   p_to_template_yn   => p_to_template_yn,
           p_copy_reference     => 'COPY',
           p_copy_line_party_yn => 'Y',
	   p_renew_ref_yn     => p_renew_ref_yn,
           p_generate_line_number  => p_generate_line_number, --Bug 2489856
           x_cle_id		     => l_cle_id_out,
	   p_change_status      => p_change_status); -- LLC Added an additional flag parameter, p_change_status,
	   								     -- to decide whether to allow change of status of sublines
										-- of the topline during update service

      END IF;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('500 :  copy_contract_line - x_return_status : '||l_return_status);
END IF;

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;

		-- Continue line copy in case of warning
		If (l_return_status <> OKC_API.G_RET_STS_WARNING) Then
             RAISE G_EXCEPTION_HALT_VALIDATION;
		End If;
      END IF;

      l_lines_tbl(i).new_line_id := l_cle_id_out; -- the new generated line id is stored in PL/SQL Table.

    END LOOP;
    i := 0;

    If (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) Then
	   If (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
		  x_return_status := l_return_status;
        Elsif (x_return_status <> OKC_API.G_RET_STS_ERROR) Then
		 If (l_return_status = OKC_API.G_RET_STS_ERROR) Then
		    x_return_status := l_return_status;
           Elsif (x_return_status <> OKC_API.G_RET_STS_WARNING) Then
	            x_return_status := l_return_status;
           End If;
	   End If;
    End If;

  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('10000 : Exiting Procedure copy_contract_lines ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('20000 : Exiting Procedure copy_contract_lines ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('30000 : SQLCODE : '||SQLCODE);
     OKC_DEBUG.log('30000 : SQLERRM : '||SQLERRM);
     OKC_DEBUG.log('30000 : Exiting Procedure copy_contract_lines ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_contract_lines;

  ----------------------------------------------------------------------------
  -- Proceduere to create operation instance and operation lines for
  -- contract header in case of RENEW
  -- Parameters: p_chrv_rec    - in header record for object_chr_id and scs_code
  --             p_to_chr_id   - subject_chr_id
  ----------------------------------------------------------------------------
  PROCEDURE Create_Renewal_Header_Link (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chrv_rec                     IN OKC_CONTRACT_PUB.chrv_rec_type,
    p_to_chr_id                    IN NUMBER)
  IS
    -- Cursor to get class operation id
    Cursor cop_csr Is
		 SELECT id
		 FROM okc_class_operations
		 WHERE cls_code = ( SELECT cls_code
						FROM okc_subclasses_b
						WHERE code = p_chrv_rec.scs_code )
           AND opn_code = 'RENEWAL';

    l_cop_id        NUMBER;
    l_oiev_rec      OKC_OPER_INST_PUB.oiev_rec_type;
    lx_oiev_rec     OKC_OPER_INST_PUB.oiev_rec_type;
    l_olev_rec      OKC_OPER_INST_PUB.olev_rec_type;
    lx_olev_rec     OKC_OPER_INST_PUB.olev_rec_type;
    l_count         NUMBER := 0;
  BEGIN
    -- get class operation id
    open cop_csr;
    fetch cop_csr into l_cop_id;
    close cop_csr;

    l_oiev_rec.cop_id := l_cop_id;
    l_oiev_rec.target_chr_id := p_to_chr_id;
    --l_oiev_rec.status_code := 'ENTERED';
    l_oiev_rec.status_code := 'PROCESSED';

    OKC_OPER_INST_PUB.Create_Operation_Instance (
	 p_api_version		=> p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
      x_return_status 	=> x_return_status,
      x_msg_count     	=> x_msg_count,
      x_msg_data      	=> x_msg_data,
      p_oiev_rec		=> l_oiev_rec,
      x_oiev_rec		=> lx_oiev_rec);

   If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
       l_olev_rec.SELECT_YN      := NULL;
       l_olev_rec.ACTIVE_YN      := 'Y';
       l_olev_rec.PROCESS_FLAG   := 'P';
	  l_olev_rec.OIE_ID         := lx_oiev_rec.id;
	  l_olev_rec.SUBJECT_CHR_ID := p_to_chr_id;
	  l_olev_rec.OBJECT_CHR_ID  := p_chrv_rec.id;

       OKC_OPER_INST_PUB.Create_Operation_Line (
	       p_api_version	=> p_api_version,
	       p_init_msg_list	=> p_init_msg_list,
            x_return_status 	=> x_return_status,
            x_msg_count     	=> x_msg_count,
            x_msg_data      	=> x_msg_data,
            p_olev_rec		=> l_olev_rec,
            x_olev_rec		=> lx_olev_rec);
	  If (x_return_status = OKC_API.G_RET_STS_SUCCESS) Then
           -- set g_op_lines table
           l_count := g_op_lines.COUNT + 1;
           g_op_lines(l_count).id     := p_chrv_rec.ID;
           g_op_lines(l_count).ole_id := lx_olev_rec.ID;
       End if;
   End If;

  EXCEPTION
    when NO_DATA_FOUND then
	  -- store SQL error message on message stack
	  x_return_status := OKC_API.G_RET_STS_ERROR;
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> 'OKC_NOT_FOUND',
					  p_token1		=> 'VALUE1',
					  p_token1_value	=> 'Status Code',
					  p_token2		=> 'VALUE2',
					  p_token2_value	=> 'OKC_CLASS_OPERATIONS_V');
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Create_Renewal_Header_Link;

  ----------------------------------------------------------------------------
  --Proceudre copy_contract_header
  ----------------------------------------------------------------------------
  PROCEDURE copy_contract_header(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_contract_number		   IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_called_from                  IN VARCHAR2,
    p_to_template_yn     	   IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    p_override_org                 IN VARCHAR2 ,
    p_calling_mode                 IN VARCHAR2 ,
    x_chr_id		           OUT NOCOPY NUMBER) IS

    l_chrv_rec 	chrv_rec_type;
    x_chrv_rec 	chrv_rec_type;

    l_pat_id        NUMBER;
    l_pav_id        NUMBER;
    l_pac_id        NUMBER;
    l_paa_id        NUMBER;
    l_sts_code      VARCHAR2(30);
    l_status_type   VARCHAR2(30) := 'ENTERED';
    l_orig_system_source_code   VARCHAR2(30) := 'OKC_HDR';
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_from_version  FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE;

    l_euro_currency          varchar2(15) := NULL; /* For Euro Conversion - Bug 2155930 */
    l_converted_amount       number := NULL; /* For Euro Conversion - Bug 2155930 */

    l_scrv_id       NUMBER;
    l_history_id    NUMBER;

    l_gvev_id       NUMBER;
    l_entity_name     VARCHAR2(30);
    l_from_entity_name VARCHAR2(30);
    l_to_entity_name   VARCHAR2(30);

--- Following Cursors are modified for Bug 1846967
    CURSOR c_pavv IS
    SELECT id
    FROM okc_price_att_values_V
    WHERE chr_id = p_from_chr_id
    AND  G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT id
    FROM okc_price_att_values_HV
    WHERE chr_id = p_from_chr_id
    AND  major_version = G_FROM_VERSION_NUMBER
    AND  G_COPY_HISTORY_YN = 'Y';
-----------------------------------
    CURSOR c_patv IS
    SELECT id
    FROM okc_price_adjustments_V
    WHERE chr_id = p_from_chr_id
    AND  cle_id IS NULL -- Added for Bug 2027165
    AND  G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT id
    FROM okc_price_adjustments_HV
    WHERE chr_id = p_from_chr_id
    AND  cle_id IS NULL -- Added for Bug 2027165
    AND  major_version = G_FROM_VERSION_NUMBER
    AND  G_COPY_HISTORY_YN = 'Y';
-----------------------------------
    CURSOR c_pacv IS
    SELECT id
    FROM okc_price_adj_assocs_v
    WHERE
      pat_id_from IN
        ( SELECT id
          FROM OKC_PRICE_ADJUSTMENTS
           WHERE chr_id = p_from_chr_id)
    AND  G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT id
    FROM okc_price_adj_assocs_HV
    WHERE
      pat_id_from IN
        ( SELECT id
          FROM OKC_PRICE_ADJUSTMENTS
           WHERE chr_id = p_from_chr_id)
    AND   major_version = G_FROM_VERSION_NUMBER
    AND   G_COPY_HISTORY_YN = 'Y';
-------------------------------------------
  /* CURSOR c_paav IS
    SELECT id
    FROM okc_price_adj_attribs_v
    WHERE
         pat_id IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
           WHERE
         chr_id = p_from_chr_id);
   */

    -- cursor for sales credits
    CURSOR c_scrv IS
    SELECT id
    FROM okc_k_sales_credits_v
    WHERE dnz_chr_id = p_from_chr_id
    AND   cle_id IS NULL
    AND  G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT id
    FROM okc_k_sales_credits_hv
    WHERE dnz_chr_id = p_from_chr_id
    AND   cle_id IS NULL
    AND  major_version = G_FROM_VERSION_NUMBER
    AND  G_COPY_HISTORY_YN = 'Y';

--
    -- cursor for goverances
    CURSOR  c_governances IS
    SELECT  id
    FROM    okc_governances_v
    WHERE   dnz_chr_id = p_from_chr_id
    AND	    cle_id is null
    AND     G_COPY_HISTORY_YN = 'N'
UNION ALL
    SELECT  id
    FROM    okc_governances_hv
    WHERE   dnz_chr_id = p_from_chr_id
    AND	    cle_id is null
    AND     major_version = G_FROM_VERSION_NUMBER
    AND     G_COPY_HISTORY_YN = 'Y';


-- Cursor for status change history
   CURSOR history_csr(p_chr_id NUMBER) IS
   SELECT id
   FROM okc_k_history_b
   WHERE TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH:MI:SS') =
       (SELECT MAX(TO_CHAR(CREATION_DATE, 'DD-MON-YYYY HH:MI:SS'))
        FROM OKC_K_HISTORY_B
        WHERE CHR_ID = p_chr_id)
   AND CHR_ID = p_chr_id;


  BEGIN

    x_return_status := l_return_status;
    l_return_status := get_chrv_rec(	p_chr_id 	=> p_from_chr_id,
					x_chrv_rec 	=> l_chrv_rec);

/* The following logic of setting the context has been moved here from below becasue of the requirement of Euro Conversion - Bug 2155930 */
    -- Sets the context.
    IF p_override_org = 'N' THEN
      okc_context.set_okc_org_context;
    ELSE
      okc_context.set_okc_org_context(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);
    END IF;

    IF l_chrv_rec.authoring_org_id <> okc_context.get_okc_org_id OR
       l_chrv_rec.inv_organization_id <> okc_context.get_okc_organization_id THEN
      OKC_API.SET_MESSAGE('OKC','OKC_INCOMPATIBLE_ORG');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

   --moving the initialization of g_application_id up for Bug 3693912
     g_application_id := l_chrv_rec.application_id;

    /* Fixing Renewal for Euro Conversion - at Header Level - Bug 2155930 */
    if (p_renew_ref_yn = 'Y') then

       l_euro_currency := OKC_CURRENCY_API.GET_EURO_CURRENCY_CODE(l_chrv_rec.currency_code);

       if (l_euro_currency <> l_chrv_rec.currency_code) then
         If l_chrv_rec.application_id in (510,871) Then
           select CONVERSION_TYPE, CONVERSION_RATE, CONVERSION_DATE
           into   g_conversion_type, g_conversion_rate, g_conversion_date
           from   okc_conversion_attribs_v
           where  DNZ_CHR_ID = l_chrv_rec.id
           and    chr_id = l_chrv_rec.id;
         Else
            -- /Rules migration/
            --FOr other contracts classes, conversion data is now stored at the header level
             select CONVERSION_TYPE, CONVERSION_RATE, CONVERSION_rate_DATE
             into   g_conversion_type, g_conversion_rate, g_conversion_date
             from okc_k_headers_b
             where id = l_chrv_rec.id;
         End If;


           fnd_profile.get('OKC_EURO_DEFAULT_PRICELIST', g_pricelist);

           if (g_pricelist is NULL) then
              fnd_message.set_name('OKC','OKC_PROFILE_CHECK');
              fnd_message.set_token('PROFILE','OKC_EURO_DEFAULT_PRICELIST');
              FND_MSG_PUB.add;
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
           end if;

   --/Rule Migration/
   --Update price list on the header instead of price rule
          --moving the initialization of g_application_id up for Bug 3693912
          -- g_application_id := l_chrv_rec.application_id;
           If l_chrv_rec.application_id not in (510,871) Then
              l_chrv_rec.price_list_id := g_pricelist;
           End If;
     --


           OKC_CURRENCY_API.CONVERT_AMOUNT
                         (p_FROM_CURRENCY => l_chrv_rec.currency_code,
                          p_TO_CURRENCY => l_euro_currency,
                          p_CONVERSION_DATE => g_conversion_date,
                          p_CONVERSION_TYPE => g_conversion_type,
                          p_AMOUNT => l_chrv_rec.estimated_amount,
                          x_CONVERSION_RATE => g_conversion_rate,
                          x_CONVERTED_AMOUNT => l_converted_amount
                         );
           l_chrv_rec.estimated_amount := l_converted_amount;

/* Commented out nocopy as total_line_list_price is in 11.5.6 and not available here
           OKC_CURRENCY_API.CONVERT_AMOUNT
                         (p_FROM_CURRENCY => l_chrv_rec.currency_code,
                          p_TO_CURRENCY => l_euro_currency,
                          p_CONVERSION_DATE => g_conversion_date,
                          p_CONVERSION_TYPE => g_conversion_type,
                          p_AMOUNT => l_chrv_rec.total_line_list_price,
                          x_CONVERSION_RATE => g_conversion_rate,
                          x_CONVERTED_AMOUNT => l_converted_amount
                         );
           l_chrv_rec.total_line_list_price := l_converted_amount;
*/
/*
   Commented out nocopy as user_estimated_amount is in 11.5.6 and not available here

           OKC_CURRENCY_API.CONVERT_AMOUNT
                         (p_FROM_CURRENCY => l_chrv_rec.currency_code,
                          p_TO_CURRENCY => l_euro_currency,
                          p_CONVERSION_DATE => g_conversion_date,
                          p_CONVERSION_TYPE => g_conversion_type,
                          p_AMOUNT => l_chrv_rec.user_estimated_amount,
                          x_CONVERSION_RATE => g_conversion_rate,
                          x_CONVERTED_AMOUNT => l_converted_amount
                         );
           l_chrv_rec.user_estimated_amount := l_converted_amount;
*/

           l_chrv_rec.currency_code := l_euro_currency;

       end if;
    end if;

    IF p_called_from = 'C' THEN -- for subcontracting only
      l_chrv_rec.buy_or_sell      := p_intent;
      l_chrv_rec.issue_or_receive := p_prospect;
      l_chrv_rec.scs_code         := p_scs_code;
    END IF;
    l_chrv_rec.chr_id_response    		:= NULL;
    l_chrv_rec.chr_id_award       		:= NULL;
    l_chrv_rec.archived_yn        		:= 'N';
    l_chrv_rec.deleted_yn         		:= 'N';
    -- Bug#2310764. If the copy is called from contracts online then
    -- let the status of the new contract be the same as old contract.
    -- orig_system_sorce_code will be 'KSSA_HDR' if copy is done from
    -- contracts online so that the contract can be updated from KOL.
    IF UPPER(NVL(p_calling_mode,'OKC')) = 'KOL_IMPORT' THEN
       l_status_type := l_chrv_rec.sts_code;
       l_orig_system_source_code:= 'KSSA_HDR' ;
    ELSIF UPPER(NVL(p_calling_mode,'OKC')) = 'KOL_COPY' THEN
       l_orig_system_source_code:= 'KSSA_HDR' ;
    END IF;
    okc_assent_pub.get_default_status( x_return_status => l_return_status,
							    p_status_type  => l_status_type,
							    x_status_code  => l_sts_code);
    l_chrv_rec.sts_code                         := l_sts_code;
    l_chrv_rec.date_approved    		:= NULL;
    l_chrv_rec.datetime_cancelled    		:= NULL;
    l_chrv_rec.date_issued	    		:= NULL;
    l_chrv_rec.datetime_responded    		:= NULL;
    l_chrv_rec.non_response_reason    		:= NULL;
    l_chrv_rec.non_response_explain    		:= NULL;
    l_chrv_rec.rfp_type		    		:= NULL;
    l_chrv_rec.set_aside_reason    		:= NULL;
    l_chrv_rec.set_aside_percent    		:= NULL;
    l_chrv_rec.response_copies_req    		:= NULL;
    l_chrv_rec.date_close_projected    		:= NULL;
    l_chrv_rec.datetime_proposed    		:= NULL;
    l_chrv_rec.date_signed	    		:= NULL;
    l_chrv_rec.date_terminated    		:= NULL;
    -- Bug 1975070 - Date Approved should be Null after Copy
    l_chrv_rec.date_approved    		:= NULL;
    -- Bug 1975070
    l_chrv_rec.date_renewed	    		:= NULL;
    l_chrv_rec.trn_code    			:= NULL;
    l_chrv_rec.orig_system_source_code          := l_orig_system_source_code;
    l_chrv_rec.orig_system_id1 			:= p_from_chr_id;
    l_chrv_rec.orig_system_reference1           := NULL;

     IF g_price_adjustments.COUNT > 0 THEN
       g_price_adjustments.DELETE;
    END IF;

    IF p_to_template_yn = 'Y' THEN
      IF l_chrv_rec.template_yn = 'N' THEN
        l_chrv_rec.template_yn := 'Y';
        l_chrv_rec.template_used := NULL;
      END IF;
    ELSIF p_to_template_yn = 'N' THEN
      IF l_chrv_rec.template_yn = 'Y' THEN
        l_chrv_rec.template_yn := 'N';
        l_chrv_rec.template_used := l_chrv_rec.contract_number;
      END IF;
    END IF;

    -- this needs to be assigned after the template used is assigned from the old contract number
    l_chrv_rec.contract_number			:= p_contract_number;
    l_chrv_rec.contract_number_modifier		:= p_contract_number_modifier;

    IF p_renew_ref_yn = 'Y' THEN
	  l_chrv_rec.ESTIMATED_AMOUNT_RENEWED := l_chrv_rec.ESTIMATED_AMOUNT;
	  l_chrv_rec.CURRENCY_CODE_RENEWED    := l_chrv_rec.CURRENCY_CODE;
    END IF;
    --l_chrv_rec.estimated_amount		:= NULL;
    -- Bug 2069569 When Copy called from renew donot nullify estimated amount
    --             Otherwise nullify estimated amount
-- Bug 2836000 start  commented out as copy api should copy header amoutn as well in all the cases
/*
    IF p_renew_ref_yn <> 'Y'  THEN
       l_chrv_rec.estimated_amount		:= NULL;
    END IF;
*/
-- Bug 2836000 end  commented out as copy api should copy header amoutn as well in all the cases
    -- Bug 2027165 - Added user_estimated amount as this is new column
    l_chrv_rec.user_estimated_amount	:= NULL;

/*  The following logic of setting the context has been moved in the top for the requirement of Euro Conversion- Bug 2155930 */
/*
    -- Sets the context.
    IF p_override_org = 'N' THEN
      okc_context.set_okc_org_context;
    ELSE
      okc_context.set_okc_org_context(l_chrv_rec.authoring_org_id,l_chrv_rec.inv_organization_id);
    END IF;

    IF l_chrv_rec.authoring_org_id <> okc_context.get_okc_org_id OR
       l_chrv_rec.inv_organization_id <> okc_context.get_okc_organization_id THEN
      OKC_API.SET_MESSAGE('OKC','OKC_INCOMPATIBLE_ORG');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/

    OKC_CONTRACT_PUB.create_contract_header(
	   p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_chrv_rec		=> l_chrv_rec,
           x_chrv_rec		=> x_chrv_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    g_chrv_rec := x_chrv_rec;
    x_chr_id := x_chrv_rec.id; -- passes the new generated id to the caller.

  -- skekkar  bug 2794905 (base bug 2774888) set the context here for the new contract
     OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_chr_id => x_chrv_rec.id);
  -- skekkar

    IF p_renew_ref_yn = 'Y' THEN
       --if the copy is for RENEW, create operation instance and operation lines
       Create_Renewal_Header_Link(
	      p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_chrv_rec		=> l_chrv_rec,
           p_to_chr_id		=> x_chr_id);

       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

       OPEN history_csr(x_chr_id);
       FETCH history_csr INTO l_history_id;
       CLOSE history_csr;

       If l_history_id IS NOT NULL Then
          UPDATE okc_k_history_b
          SET reason_code = 'RENEW'
          WHERE id = l_history_id;
       End If;

    END IF;

    -- copy associated attachments
    l_from_version := Get_Major_Version(p_from_chr_id);

    IF (l_from_version = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- set attachement session variables
    -- before calling fnd_attachment_util_pkg.get_atchmt_exists
    Set_Attach_Session_Vars(p_from_chr_id);

    --Bug 3326337 Removed the hard coding for entity names
    /* Commentedout for 11510 GSI Issue on copying attachments
    If(FND_ATTACHMENT_UTIL_PKG.function_name = 'OKSAUDET') THEN
     l_entity_name := 'OKC_K_HEADERS_V';
     l_from_entity_name := 'OKC_K_HEADERS_V';
     l_to_entity_name := 'OKC_K_HEADERS_V';
    ELSE */
     l_entity_name := 'OKC_K_HEADERS_B';
     l_from_entity_name := 'OKC_K_HEADERS_B';
     l_to_entity_name := 'OKC_K_HEADERS_B';
    --End If;

    If (fnd_attachment_util_pkg.get_atchmt_exists (
			  l_entity_name => l_entity_name,
			  l_pkey1 => p_from_chr_id,
			  l_pkey2 => l_from_version) = 'Y')

			  -- The following line to be added to the code once
			  -- bug 1553916 completes
			  -- ,l_pkey2 => l_from_version) = 'Y')
			  -- also below remove the comments
			  -- in fnd_attached_documents2_pkg.copy_attachments call
    Then
        fnd_attached_documents2_pkg.copy_attachments(
                          x_from_entity_name => l_from_entity_name,
                          x_from_pk1_value   => p_from_chr_id,
                          x_from_pk2_value   => l_from_version,
                          x_to_entity_name => l_to_entity_name,
                          x_to_pk1_value   => x_chr_id,
                          x_to_pk2_value   => '0'
					 );
    End if;

    copy_accesses(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_chr_id	=> p_from_chr_id,
	   p_to_chr_id 		=> x_chrv_rec.id);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    copy_processes(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_chr_id	=> p_from_chr_id,
	   p_to_chr_id 		=> x_chrv_rec.id);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    copy_grpings(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_chr_id	=> p_from_chr_id,
	   p_to_chr_id 		=> x_chrv_rec.id);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    /*************************************
        This used to make a copy of goverances only at the header level
        We have replaced it by code that copies at both header and line level

        also, we no longer do it conditionally for renewal contracts


    IF (p_renew_ref_yn = 'Y') THEN
    copy_governances(
            p_api_version        => p_api_version,
	    p_init_msg_list      => p_init_msg_list,
	    x_return_status      => l_return_status,
	    x_msg_count          => x_msg_count,
	    x_msg_data           => x_msg_data,
	    p_from_chr_id        => p_from_chr_id,
	    p_to_chr_id          => x_chrv_rec.id);



    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    END IF;
    ****************************************/

/****** For Bug#3052910 ***********************************************************
--Following condn is added .IF (p_renew_ref_yn = 'Y') THEN before the loop.
--The condition " IF (p_renew_ref_yn = 'Y') THEN " is removed for price hold change
--Price hold changes are obsoleted hence reverting the changes.
******* For Bug#3052910 ***********************************************************/

   IF (p_renew_ref_yn = 'Y') THEN --Added for Bug#3052910

    FOR l_c_governances IN c_governances LOOP

      copy_governances (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_gvev_id            => l_c_governances.id,
           p_cle_id		=> NULL,
           p_chr_id		=> x_chrv_rec.id,
           x_gvev_id		=> l_gvev_id);


      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := l_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
	     x_return_status := l_return_status;
         END IF;
      END IF;
    END LOOP;

  END IF; -- IF (p_renew_ref_yn = 'Y') THEN


    FOR l_c_pavv IN c_pavv LOOP
      copy_price_att_values (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_pav_id		=> l_c_pavv.id,
           p_cle_id		=> NULL,
           p_chr_id		=> x_chrv_rec.id,
           x_pav_id		=> l_pav_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

    FOR l_c_patv IN c_patv LOOP
      copy_price_adjustments (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_pat_id             => l_c_patv.id,
           p_cle_id             => NULL,
           p_chr_id             => x_chrv_rec.id,
           x_pat_id             => l_pat_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;
     copy_price_adj_attribs (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_paa_id             => NULL,
           p_pat_id             => l_c_patv.id);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;

  END LOOP;


    FOR l_c_pacv IN c_pacv LOOP
      copy_price_adj_assocs (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_pac_id             => l_c_pacv.id,
           p_cle_id             => NULL,
           p_pat_id             => l_pat_id,
           x_pac_id             => l_pac_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;

  /* FOR l_c_paav IN c_paav LOOP
      copy_price_adj_attribs (
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => l_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_paa_id             => l_c_paav.id,
           p_pat_id             => x_patv_rec.id,
      );

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
             x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;
   */

    FOR l_c_scrv IN c_scrv LOOP

      copy_sales_credits (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_scrv_id            => l_c_scrv.id,
           p_cle_id		=> NULL,
           p_chr_id		=> x_chrv_rec.id,
           x_scrv_id		=> l_scrv_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
	     x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;




  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_contract_header;

----------------------------------------------------------------------------
-- This procedure is used to copy the sections to which no articles are
-- attached. In other words this is used to copy all the sections which
-- were not copied in copy_sections procedure
----------------------------------------------------------------------------
  PROCEDURE copy_other_sections(p_chr_id IN NUMBER, l_to_chr_id IN NUMBER) IS

    l_return_status	  	  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_section_id	  	  NUMBER;
    l_scn_id			  NUMBER;
    l_level		  	  NUMBER;
    l_api_version          CONSTANT  NUMBER    := 1.0;
    l_init_msg_list   	  CONSTANT  VARCHAR2(1) := 'T';
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);

-- Cursor to get all the top sections
    CURSOR get_main_sections(p_chr_id IN NUMBER) IS
    select id
    from okc_sections_b
    where chr_id = p_chr_id
	 and scn_id IS NULL;
-- Cursor to get all the sub sections in order
    CURSOR get_all_sections(p_id IN NUMBER) IS
    select id, level
    from okc_sections_b
    CONNECT BY PRIOR id = scn_id
    START WITH id = p_id;
  Begin
    OPEN get_main_sections(p_chr_id);
    LOOP
      FETCH get_main_sections INTO l_section_id;
      EXIT when get_main_sections%NOTFOUND;

	 OPEN get_all_sections(l_section_id);
        LOOP
	    FETCH get_all_sections INTO l_scn_id, l_level;
	    EXIT when get_all_sections%NOTFOUND;
         copy_sections (
	      p_api_version		=> l_api_version,
           p_init_msg_list	=> l_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> l_msg_count,
           x_msg_data      	=> l_msg_data,
           p_scc_id		     => NULL,
           p_to_cat_id		=> NULL,
           p_to_chr_id		=> l_to_chr_id,
           p_scn_id			=> l_scn_id);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	      --x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
        END LOOP;
        CLOSE get_all_sections;
     END LOOP;
     CLOSE get_main_sections;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      --x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END copy_other_sections;

  ----------------------------------------------------------------------------
  --Proceudre copy_contract. Copies the contract header and all its components.
  ----------------------------------------------------------------------------
  PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit			          IN VARCHAR2 ,
    p_chr_id                  	   IN NUMBER,
    p_contract_number		   IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2,
    P_renew_ref_yn                 IN VARCHAR2,
    p_copy_lines_yn                IN VARCHAR2,
    p_override_org                 IN VARCHAR2 ,
    p_copy_from_history_yn              IN VARCHAR2 ,
    p_from_version_number          IN NUMBER ,
    p_copy_latest_articles         IN VARCHAR2 ,
    p_calling_mode                 IN VARCHAR2 ,
    x_chr_id                       OUT NOCOPY NUMBER) IS

    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_chr_id			NUMBER;
    l_cle_id_out		NUMBER;
    l_rgp_id			NUMBER;
    l_cat_id			NUMBER;
    l_cpl_id			NUMBER;
    l_cnh_id			NUMBER;
    l_result			BOOLEAN;
    l_category          VARCHAR2(200); --added for bug 3672759

-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 2151523(1917514)
    CURSOR c_pdf IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'COPY'
    AND   cls_code = 'SERVICE';

    l_pdf_id  NUMBER;
    l_cle_id  NUMBER := OKC_API.G_MISS_NUM;
    --l_chr_id  NUMBER;
    l_string VARCHAR2(32000);
    proc_string VARCHAR2(32000);
-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 2151523(1917514)

-- Added for Bug 3672759
-- cursor to get the contract category

    CURSOR l_Service_Contract_csr IS
    SELECT osb.cls_code
    FROM  okc_subclasses_b osb,okc_k_headers_b okb
    WHERE okb.id = p_chr_id
    AND   okb.scs_code = osb.code ;

    CURSOR c_lines IS
    SELECT cle.id,lse.lty_code
    FROM   okc_k_lines_b cle,
	   okc_line_styles_b lse
    WHERE chr_id = p_chr_id
        AND   cle.lse_id= lse.id
        AND   g_copy_history_yn = 'N'
    UNION ALL
    SELECT cle.id,lse.lty_code
    FROM   okc_k_lines_bh cle,
	   okc_line_styles_b lse
    WHERE chr_id = p_chr_id
        AND  cle.lse_id= lse.id
        AND  major_version = G_FROM_VERSION_NUMBER
        AND  G_COPY_HISTORY_YN = 'Y';
--------------------------------------------------
    CURSOR c_rgpv IS
    SELECT id
    FROM okc_rule_groups_b
    WHERE dnz_chr_id = p_chr_id
        AND  cle_id is null
        AND  g_copy_history_yn = 'N'
    UNION ALL
    SELECT id
    FROM okc_rule_groups_bH
    WHERE dnz_chr_id = p_chr_id and cle_id is null
       AND   major_version = G_FROM_VERSION_NUMBER
       AND   G_COPY_HISTORY_YN = 'Y';
---------------------------------------------------
/* 11510
    CURSOR c_catv IS
    SELECT id
    FROM okc_k_articles_b
    WHERE dnz_chr_id = p_chr_id
       AND cle_id is null
       AND g_copy_history_yn = 'N'
    UNION ALL
    SELECT id
    FROM okc_k_articles_bH
    WHERE dnz_chr_id = p_chr_id and cle_id is null
       AND   major_version = G_FROM_VERSION_NUMBER
       AND   G_COPY_HISTORY_YN = 'Y';
*/

    --11510
    l_source_doc_type VARCHAR2(60);
    l_source_doc_ID   NUMBER;
    l_target_doc_type VARCHAR2(60);
    l_target_doc_id   NUMBER;
    l_keep_version VARCHAR2(1);
    l_eff_date DATE;


    -- 11510 get chr start date for effective date for copy_doc
    CURSOR c_art_eff_date (p_doc_type VARCHAR2,p_doc_id NUMBER) IS
    SELECT article_effective_date
     FROM okc_template_usages_v
     WHERE document_type=p_doc_type AND document_id=p_doc_id;
---------------------------------------------------
    CURSOR c_cplv IS
    SELECT id
    FROM okc_k_party_roles_b
    WHERE dnz_chr_id = p_chr_id
          and cle_id is NULL
          AND  g_copy_history_yn = 'N'
    UNION ALL
    SELECT id
    FROM okc_k_party_roles_bH
    WHERE dnz_chr_id = p_chr_id and cle_id is NULL
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
---------------------------------------------------
    CURSOR c_cnhv IS
    SELECT id
    FROM okc_condition_headers_b
    WHERE dnz_chr_id = p_chr_id
    AND   g_copy_history_yn = 'N'
    UNION ALL
    SELECT id
    FROM okc_condition_headers_bH
    WHERE dnz_chr_id = p_chr_id
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
---------------------------------------------------
  BEGIN
    IF (l_debug = 'Y') THEN
     OKC_DEBUG.Set_Indentation('Copy_contract');
     OKC_DEBUG.log('1000 : Entering Copy_contract', 2);
    END IF;
    G_COPY_HISTORY_YN      := NVL(upper(p_copy_from_history_yn),'N');
    IF G_COPY_HISTORY_YN = 'Y'  THEN
       IF  p_from_version_number    IS NOT NULL then
           IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('1010 : G_COPY_HISTORY_YN = Y', 2);
           END IF;
           G_FROM_VERSION_NUMBER  := p_from_version_number;
       ELSE

           IF (l_debug = 'Y') THEN
              OKC_DEBUG.log('1020 : G_COPY_HISTORY_YN = N', 2);
           END IF;
      	   OKC_API.SET_MESSAGE(G_APP_NAME,'OKC_VERSION_NUMBER_MISSING');
           X_return_status := OKC_API.G_RET_STS_ERROR;
	         raise G_EXCEPTION_HALT_VALIDATION;
       END IF;
     ELSE
       G_FROM_VERSION_NUMBER  := NULL;
    END IF;

----------------------------------------------------
    l_result := OKC_COPY_CONTRACT_PUB.IS_COPY_ALLOWED(p_chr_id, NULL);
    IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('1301 : After OKC_COPY_CONTRACT_PUB ' || X_return_status );
    END IF;
    If NOT l_result Then

         IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('1040 : Inside If NOT l_result Then', 2);
         END IF;
	 -- notify caller of an UNEXPECTED error
	 x_return_status := OKC_API.G_RET_STS_ERROR;
	 raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Intitialize globals.
    IF g_events.COUNT > 0 THEN
       g_events.DELETE;
    END IF;

    IF g_ruls.COUNT > 0 THEN
       g_ruls.DELETE;
    END IF;

    IF g_sections.COUNT > 0 THEN
       g_sections.DELETE;
    END IF;

   IF g_price_adjustments.COUNT > 0 THEN
       g_price_adjustments.DELETE;
    END IF;

    IF g_timevalues.COUNT > 0 THEN
       g_timevalues.DELETE;
    END IF;

    IF g_party.COUNT > 0 THEN
       g_party.DELETE;
    END IF;

    IF g_op_lines.COUNT > 0 THEN
	  g_op_lines.DELETE;
    END IF;

    x_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1050 : Before Procedure : copy_contract_header ' ,1);
END IF;
    copy_contract_header(
	      p_api_version		     => p_api_version,
           p_init_msg_list		=> p_init_msg_list,
           x_return_status 		=> l_return_status,
           x_msg_count     		=> x_msg_count,
           x_msg_data      		=> x_msg_data,
           p_from_chr_id	        => p_chr_id,
           p_contract_number		=> p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
           p_scs_code              => NULL,
           p_intent                => NULL,
           p_prospect              => NULL,
           p_called_from           => 'M', -- called from main copy contract.
	   p_to_template_yn        => p_to_template_yn,
	   p_renew_ref_yn          => p_renew_ref_yn,
	   p_override_org          => p_override_org,
	   p_calling_mode          => p_calling_mode,
           x_chr_id	           => l_chr_id);

               l_oks_copy := 'N';      -- Bugfix 2151523(1917514)
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1003 : After Procedure : Copy_contract_header ', 1);
END IF;
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_chr_id := l_chr_id; --the new contract header id is passed out.

    FOR l_c_cnhv IN c_cnhv LOOP -- events procedure needs to be called before rules.
      l_old_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('Before Procedure : copy_events ' || l_return_status);
END IF;
      copy_events(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cnh_id		=> l_c_cnhv.id,
           p_chr_id		=> l_chr_id, -- the new generated contract header id
           p_to_template_yn   => p_to_template_yn,
           x_cnh_id		=> l_cnh_id);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : copy_events ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
    END LOOP;

    FOR l_c_cplv IN c_cplv LOOP
      l_old_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' Before Procedure : copy_party_roles ' || l_return_status);
END IF;
      copy_party_roles (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cpl_id		=> l_c_cplv.id,
           p_cle_id		=> NULL,
           p_chr_id		=> l_chr_id, -- the new generated contract header id
           p_rle_code           => NULL,
           x_cpl_id		=> l_cpl_id);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : copy_party_roles ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;

      END LOOP;

    --
    -- Bug 3611000
    -- Rules may exist for pre-11.5.10 contracts - they should not be tried to copy in 11.5.10 onwards for service contracts
    --
    IF G_APPLICATION_ID <> 515 THEN

		  FOR l_c_rgpv IN c_rgpv LOOP
		    l_old_return_status := l_return_status;

	       IF (l_debug = 'Y') THEN
		     OKC_DEBUG.log(' Before Procedure : copy_rules ' || l_return_status);
	       END IF;

		    copy_rules (
			 p_api_version	=> p_api_version,
			    p_init_msg_list	=> p_init_msg_list,
			    x_return_status 	=> l_return_status,
			    x_msg_count     	=> x_msg_count,
			    x_msg_data      	=> x_msg_data,
			    p_rgp_id	      	=> l_c_rgpv.id,
			    p_cle_id		=> NULL,
			    p_chr_id	        => l_chr_id, -- the new generated contract header id
			 p_to_template_yn     => p_to_template_yn,
			    x_rgp_id		=> l_rgp_id);

		    IF (l_debug = 'Y') THEN
			  OKC_DEBUG.log(' After Procedure : copy_rules ' || l_return_status);
		    END IF;
			 IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			   IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
				x_return_status := l_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			   ELSE
				IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
				  x_return_status := l_return_status;
				END IF;
			   END IF;
			 END IF;
		  END LOOP;

    END IF; -- G_APPLICATION_ID <> 515

    /* 11510
-----Bug.No-1754245
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('p_renew_ref_yn='||p_renew_ref_yn||' p_copy_latest_articles='||p_copy_latest_articles,2);
END IF;

     IF     p_renew_ref_yn = 'Y'  OR
             p_copy_latest_articles = 'N' THEN
        FOR l_c_catv IN c_catv LOOP
---Current(may be an old verssion) release of article is copied here.

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' Before Procedure : copy_articles ' || l_return_status);
END IF;

             copy_articles (
	     p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_cat_id		=> l_c_catv.id,
             p_cle_id		=> NULL,
             p_chr_id		=> l_chr_id, -- the new generated contract header id
             x_cat_id		=> l_cat_id);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : copy_articles ' || l_return_status);
END IF;
             IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 x_return_status := l_return_status;
                 RAISE G_EXCEPTION_HALT_VALIDATION;
               ELSE
                 x_return_status := l_return_status;
               END IF;
             END IF;
        END LOOP;
     ELSE  ---> Copy Latest release of article.---
        FOR l_c_catv IN c_catv LOOP
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('Before Procedure : copy_latest_articles : ' || l_return_status);
END IF;

           copy_latest_articles(
             p_api_version                  => p_api_version,
             p_init_msg_list                => p_init_msg_list,
             x_return_status                => l_return_status,
             x_msg_count                    => x_msg_count,
             x_msg_data                     => x_msg_data,
             p_cat_id                       => l_c_catv.id,
             p_cle_id                       => NULL,
             p_chr_id                       => l_chr_id,
             x_cat_id  		            => l_cat_id);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : copy_latest_articles : ' || l_return_status);
END IF;
             IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                   x_return_status := l_return_status;
                   RAISE G_EXCEPTION_HALT_VALIDATION;
                ELSE
                   x_return_status := l_return_status;
                END IF;
             END IF;
         END LOOP;
     END IF;
*/
-----Bug.No-1754245
/********************************************
    FOR l_c_catv IN c_catv LOOP
      copy_articles (
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cat_id		=> l_c_catv.id,
           p_cle_id		=> NULL,
           p_chr_id		=> l_chr_id, -- the new generated contract header id
           x_cat_id		=> l_cat_id);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
          x_return_status := l_return_status;
        END IF;
      END IF;
    END LOOP;
**************************************/
    -- Call to the procedure to copy all other remaining sections
/* 11510    copy_other_sections(p_chr_id, l_chr_id);
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : copy_other_sections ' || l_return_status);
END IF;
*/

    -- new 11510 code
    IF p_renew_ref_yn = 'Y' OR p_copy_latest_articles = 'N' THEN
      l_keep_version := 'Y';
     ELSE
      l_keep_version := 'N';
    END IF;
     OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_ID(
        p_api_version   => p_api_version,
        x_return_status => l_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_chr_id        => p_chr_id,
        x_doc_id        => l_source_doc_id,
        x_doc_type      => l_source_doc_type
    );

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : Get_Contract_Document_Type for source chr_id ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
     OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_ID(
        p_api_version   => p_api_version,
        x_return_status => l_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_chr_id        => x_chr_id,
        x_doc_id        => l_target_doc_id,
        x_doc_type      => l_target_doc_type);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : Get_Contract_Document_Type for target chr_id ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
    OPEN c_art_eff_date(l_source_doc_type, l_source_doc_id);
    FETCH c_art_eff_date INTO l_eff_date;
    CLOSE c_art_eff_date;


    IF G_COPY_HISTORY_YN = 'Y' THEN
      OKC_TERMS_COPY_GRP.copy_archived_doc(
        p_api_version	     => p_api_version,
        x_return_status 	     => l_return_status,
        x_msg_count     	     => x_msg_count,
        x_msg_data      	     => x_msg_data,

        p_source_doc_type      => l_source_doc_type,
        p_source_doc_id        => l_source_doc_id,
        p_source_version_number=> G_FROM_VERSION_NUMBER,
        p_target_doc_type      => l_target_doc_type,
        p_target_doc_id        => l_target_doc_id,
--        p_keep_version         => l_keep_version,
--        p_article_effective_date => Nvl(l_eff_date,Sysdate),
        p_document_number      => p_contract_number,
        p_allow_duplicate_terms=>'Y'
      );
     ELSE
      OKC_TERMS_COPY_GRP.copy_doc(
        p_api_version	     => p_api_version,
        x_return_status 	     => l_return_status,
        x_msg_count     	     => x_msg_count,
        x_msg_data      	     => x_msg_data,

        p_source_doc_type      => l_source_doc_type,
        p_source_doc_id        => l_source_doc_id,
        p_target_doc_type      => l_target_doc_type,
        p_target_doc_id        => l_target_doc_id,
        p_keep_version         => l_keep_version,
        p_article_effective_date => Nvl(l_eff_date,Sysdate),
        p_document_number      => p_contract_number,
        p_allow_duplicate_terms=>'Y'
      );
    END IF;
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : OKC_TERMS_COPY_GRP.copy_doc ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;

    IF p_copy_lines_yn = 'Y' then
      -- the cursor below identifies the 1st level of lines and call the copy_contract_lines procedure
      -- which copies all the components of the identified lines (like articles,rules,sublines etc.

      FOR l_c_lines IN c_lines LOOP
        IF l_c_lines.lty_code <> 'WARRANTY' THEN -- AND l_c_lines.lty_code <> 'EXT_WARRANTY'  THEN

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' Before Procedure : copy_contract_lines ' || l_return_status);
END IF;
          copy_contract_lines(
               p_api_version	     => p_api_version,
               p_init_msg_list	     => p_init_msg_list,
               x_return_status 	     => l_return_status,
               x_msg_count     	     => x_msg_count,
               x_msg_data      	     => x_msg_data,
               p_from_cle_id	     => l_c_lines.id,
     	       p_to_chr_id 		=> l_chr_id, --the new generated contract header id
               p_to_cle_id 		=> NULL, -- used only when a line is copied under a line.
       	       p_to_template_yn      => p_to_template_yn,
               p_copy_reference      =>'COPY',
               p_copy_line_party_yn  => 'Y',
               p_renew_ref_yn        => p_renew_ref_yn,
               p_generate_line_number => 'N', -- Bug 2489856
               x_cle_id		     => l_cle_id_out);
	   -- DND    p_change_status       => 'Y');  --LLC

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : copy_contract_lines ' || l_return_status);
END IF;

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
-- bug 2667634 start  , changes commented for bug 2774888
-- IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) OR (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
-- bug 2667634 end
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
      END LOOP;

    END IF;
  -- Changes done for Bug 2054090
  -- PURPOSE  : Creates new configuration header and revision while
  --            copying a contract. The newly copied contract will point
  --            to the newly created config header and revisions.
  --            This procedure will handle all configured models in a contract.
  --             It updates contract lines for this config with new pointers
  --             for the columns config_top_model_line_id,
  --             config_header_id, config_revision_number.

  -- ---------------------------------------------------------------------------

     OKC_CFG_PUB.COPY_CONFIG(p_dnz_chr_id    => l_chr_id,
                             x_return_status => l_return_status);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
               x_return_status := l_return_status;
           END IF;
         END IF;
  -- Changes done for Bug 2054090

  --Changes done for Bug 3672759 to execute the dynamic SQL only for service contracts
      OPEN l_Service_Contract_csr;
      FETCH l_Service_Contract_csr into l_category;
      CLOSE l_Service_Contract_csr;

  IF l_category = 'SERVICE' then
  -- Begin - Changes done for Bug 2151523(1917514)
      OPEN c_pdf;
      FETCH c_pdf INTO l_pdf_id;
      okc_create_plsql (p_pdf_id => l_pdf_id,
                    x_string => l_string) ;
      CLOSE c_pdf;

    IF l_string is NOT NULL THEN
       proc_string := 'begin '||l_string || ' (:b1,:b2,:b3); end ;';
       EXECUTE IMMEDIATE proc_string using l_chr_id,l_cle_id, out l_return_status;
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
           x_return_status := l_return_status;
           l_oks_copy := 'N';
           -- Setting l_oks_copy to 'N' so that this procedure should not be called from
           -- Copy Line if it is already called from Copy Header
       END IF;
    END IF;
  END IF;
  -- End - Changes done for Bug 2151523(1917514)


/*    IF p_commit = 'T' THEN
       commit;
    END IF;
*/

  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('10000 : Exiting Copy_contract ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    IF (l_debug = 'Y') THEN
   	    OKC_DEBUG.ReSet_Indentation;
	    END IF;
      NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      ---Initialisation is not to create contract from History Tables
      G_COPY_HISTORY_YN := 'N';
      IF (l_debug = 'Y') THEN
         OKC_DEBUG.ReSet_Indentation;
      END IF;

  END COPY_CONTRACT;

  ----------------------------------------------------------------------------
  --Function to populate the articles translation record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_atnv_rec(p_atn_id IN NUMBER,
				x_atnv_rec OUT NOCOPY atnv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_atnv_rec IS
      SELECT	ID,
		CAT_ID,
		CLE_ID,
		RUL_ID,
		DNZ_CHR_ID
	FROM    OKC_ARTICLE_TRANS_V
	WHERE 	ID = p_atn_id
          AND   g_copy_history_yn = 'N'
    UNION ALL
      SELECT	ID,
		CAT_ID,
		CLE_ID,
		RUL_ID,
		DNZ_CHR_ID
	FROM    OKC_ARTICLE_TRANS_HV
	WHERE 	ID = p_atn_id
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_atnv_rec;
      FETCH c_atnv_rec
      INTO	x_atnv_rec.ID,
		x_atnv_rec.CAT_ID,
		x_atnv_rec.CLE_ID,
		x_atnv_rec.RUL_ID,
		x_atnv_rec.DNZ_CHR_ID;

      l_no_data_found := c_atnv_rec%NOTFOUND;
      CLOSE c_atnv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_atnv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the articles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION get_catv_rec(p_cat_id IN NUMBER,
				x_catv_rec OUT NOCOPY catv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;
    BEGIN
      x_catv_rec := OKC_K_ARTICLE_PUB.Get_Rec(
         p_id => p_cat_id,
         p_major_version => G_FROM_VERSION_NUMBER,
         x_no_data_found => l_no_data_found
      );
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_catv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the contract items record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cimv_rec(p_cim_id IN NUMBER,
				x_cimv_rec OUT NOCOPY cimv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cimv_rec IS
      SELECT	ID,
		CLE_ID,
		CHR_ID,
		CLE_ID_FOR,
		DNZ_CHR_ID,
		OBJECT1_ID1,
		OBJECT1_ID2,
		JTOT_OBJECT1_CODE,
		UOM_CODE,
		EXCEPTION_YN,
		NUMBER_OF_ITEMS,
                PRICED_ITEM_YN
	FROM    OKC_K_ITEMS_V
	WHERE 	ID = p_cim_id;
    BEGIN
      OPEN c_cimv_rec;
      FETCH c_cimv_rec
      INTO	x_cimv_rec.ID,
		x_cimv_rec.CLE_ID,
		x_cimv_rec.CHR_ID,
		x_cimv_rec.CLE_ID_FOR,
		x_cimv_rec.DNZ_CHR_ID,
		x_cimv_rec.OBJECT1_ID1,
		x_cimv_rec.OBJECT1_ID2,
		x_cimv_rec.JTOT_OBJECT1_CODE,
		x_cimv_rec.UOM_CODE,
		x_cimv_rec.EXCEPTION_YN,
		x_cimv_rec.NUMBER_OF_ITEMS,
		x_cimv_rec.PRICED_ITEM_YN;


      l_no_data_found := c_cimv_rec%NOTFOUND;
      CLOSE c_cimv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cimv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract access record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cacv_rec(p_cac_id IN NUMBER,
				x_cacv_rec OUT NOCOPY cacv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cacv_rec IS
      SELECT	ID,
		GROUP_ID,
		CHR_ID,
		RESOURCE_ID,
		ACCESS_LEVEL
	FROM    OKC_K_ACCESSES_V
	WHERE 	ID = p_cac_id;

    BEGIN
      OPEN c_cacv_rec;
      FETCH c_cacv_rec
      INTO	x_cacv_rec.ID,
		x_cacv_rec.GROUP_ID,
		x_cacv_rec.CHR_ID,
		x_cacv_rec.RESOURCE_ID,
		x_cacv_rec.ACCESS_LEVEL;

      l_no_data_found := c_cacv_rec%NOTFOUND;
      CLOSE c_cacv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cacv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract party roles record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cplv_rec(p_cpl_id IN NUMBER,
				x_cplv_rec OUT NOCOPY cplv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cplv_rec IS
      SELECT	ID,
		SFWT_FLAG,
		CHR_ID,
		CLE_ID,
		RLE_CODE,
		DNZ_CHR_ID,
		OBJECT1_ID1,
		OBJECT1_ID2,
		JTOT_OBJECT1_CODE,
		COGNOMEN,
		CODE,
		FACILITY,
		MINORITY_GROUP_LOOKUP_CODE,
		SMALL_BUSINESS_FLAG,
		WOMEN_OWNED_FLAG,
		ALIAS,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
          PRIMARY_YN,    -- Bug 2374325
           --- new columns to replace rules
          CUST_ACCT_ID,
          BILL_TO_SITE_USE_ID

	FROM    OKC_K_PARTY_ROLES_V
	WHERE 	ID = p_cpl_id
          AND   G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT	ID,
		SFWT_FLAG,
		CHR_ID,
		CLE_ID,
		RLE_CODE,
		DNZ_CHR_ID,
		OBJECT1_ID1,
		OBJECT1_ID2,
		JTOT_OBJECT1_CODE,
		COGNOMEN,
		CODE,
		FACILITY,
		MINORITY_GROUP_LOOKUP_CODE,
		SMALL_BUSINESS_FLAG,
		WOMEN_OWNED_FLAG,
		ALIAS,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
          PRIMARY_YN,    -- Bug 2374325
           --- new columns to replace rules
          CUST_ACCT_ID,
          BILL_TO_SITE_USE_ID

	FROM    OKC_K_PARTY_ROLES_HV
	WHERE 	ID = p_cpl_id
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_cplv_rec;
      FETCH c_cplv_rec
      INTO	x_cplv_rec.ID,
		x_cplv_rec.SFWT_FLAG,
		x_cplv_rec.CHR_ID,
		x_cplv_rec.CLE_ID,
		x_cplv_rec.RLE_CODE,
		x_cplv_rec.DNZ_CHR_ID,
		x_cplv_rec.OBJECT1_ID1,
		x_cplv_rec.OBJECT1_ID2,
		x_cplv_rec.JTOT_OBJECT1_CODE,
		x_cplv_rec.COGNOMEN,
		x_cplv_rec.CODE,
		x_cplv_rec.FACILITY,
		x_cplv_rec.MINORITY_GROUP_LOOKUP_CODE,
		x_cplv_rec.SMALL_BUSINESS_FLAG,
		x_cplv_rec.WOMEN_OWNED_FLAG,
		x_cplv_rec.ALIAS,
		x_cplv_rec.ATTRIBUTE_CATEGORY,
		x_cplv_rec.ATTRIBUTE1,
		x_cplv_rec.ATTRIBUTE2,
		x_cplv_rec.ATTRIBUTE3,
		x_cplv_rec.ATTRIBUTE4,
		x_cplv_rec.ATTRIBUTE5,
		x_cplv_rec.ATTRIBUTE6,
		x_cplv_rec.ATTRIBUTE7,
		x_cplv_rec.ATTRIBUTE8,
		x_cplv_rec.ATTRIBUTE9,
		x_cplv_rec.ATTRIBUTE10,
		x_cplv_rec.ATTRIBUTE11,
		x_cplv_rec.ATTRIBUTE12,
		x_cplv_rec.ATTRIBUTE13,
		x_cplv_rec.ATTRIBUTE14,
		x_cplv_rec.ATTRIBUTE15,
          x_cplv_rec.PRIMARY_YN,
          --new columns to replace rules
          x_cplv_rec.CUST_ACCT_ID,
          x_cplv_rec.BILL_TO_SITE_USE_ID;

      l_no_data_found := c_cplv_rec%NOTFOUND;
      CLOSE c_cplv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cplv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract process record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cpsv_rec(p_cps_id IN NUMBER,
				x_cpsv_rec OUT NOCOPY cpsv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cpsv_rec IS
      SELECT	ID,
		PDF_ID,
		CHR_ID,
		USER_ID,
		CRT_ID,
		PROCESS_ID,
		IN_PROCESS_YN,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	FROM    OKC_K_PROCESSES_V
	WHERE 	ID = p_cps_id;
    BEGIN
      OPEN c_cpsv_rec;
      FETCH c_cpsv_rec
      INTO	x_cpsv_rec.ID,
		x_cpsv_rec.PDF_ID,
		x_cpsv_rec.CHR_ID,
		x_cpsv_rec.USER_ID,
		x_cpsv_rec.CRT_ID,
		x_cpsv_rec.PROCESS_ID,
		x_cpsv_rec.IN_PROCESS_YN,
		x_cpsv_rec.ATTRIBUTE_CATEGORY,
		x_cpsv_rec.ATTRIBUTE1,
		x_cpsv_rec.ATTRIBUTE2,
		x_cpsv_rec.ATTRIBUTE3,
		x_cpsv_rec.ATTRIBUTE4,
		x_cpsv_rec.ATTRIBUTE5,
		x_cpsv_rec.ATTRIBUTE6,
		x_cpsv_rec.ATTRIBUTE7,
		x_cpsv_rec.ATTRIBUTE8,
		x_cpsv_rec.ATTRIBUTE9,
		x_cpsv_rec.ATTRIBUTE10,
		x_cpsv_rec.ATTRIBUTE11,
		x_cpsv_rec.ATTRIBUTE12,
		x_cpsv_rec.ATTRIBUTE13,
		x_cpsv_rec.ATTRIBUTE14,
		x_cpsv_rec.ATTRIBUTE15;

      l_no_data_found := c_cpsv_rec%NOTFOUND;
      CLOSE c_cpsv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cpsv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contract group record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cgcv_rec(p_cgc_id IN NUMBER,
				x_cgcv_rec OUT NOCOPY cgcv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cgcv_rec IS
      SELECT	ID,
		CGP_PARENT_ID,
		INCLUDED_CHR_ID,
		INCLUDED_CGP_ID
	FROM    OKC_K_GRPINGS_V
	WHERE 	ID = p_cgc_id;

    BEGIN
      OPEN c_cgcv_rec;
      FETCH c_cgcv_rec
      INTO	x_cgcv_rec.ID,
		x_cgcv_rec.CGP_PARENT_ID,
		x_cgcv_rec.INCLUDED_CHR_ID,
		x_cgcv_rec.INCLUDED_CGP_ID;
      l_no_data_found := c_cgcv_rec%NOTFOUND;
      CLOSE c_cgcv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cgcv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the condition headers record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cnhv_rec(p_cnh_id IN NUMBER,
				x_cnhv_rec OUT NOCOPY cnhv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cnhv_rec IS
      SELECT	ID,
		SFWT_FLAG,
		ACN_ID,
		COUNTER_GROUP_ID,
		DESCRIPTION,
		SHORT_DESCRIPTION,
		COMMENTS,
		ONE_TIME_YN,
		NAME,
		CONDITION_VALID_YN,
		BEFORE_AFTER,
		TRACKED_YN,
		CNH_VARIANCE,
		DNZ_CHR_ID,
		TEMPLATE_YN,
		DATE_ACTIVE,
		OBJECT_ID,
		DATE_INACTIVE,
		JTOT_OBJECT_CODE,
		TASK_OWNER_ID,
		CNH_TYPE,
	        ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	FROM    OKC_CONDITION_HEADERS_V
	WHERE 	ID = p_cnh_id
          AND   G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT	ID,
		SFWT_FLAG,
		ACN_ID,
		COUNTER_GROUP_ID,
		DESCRIPTION,
		SHORT_DESCRIPTION,
		COMMENTS,
		ONE_TIME_YN,
		NAME,
		CONDITION_VALID_YN,
		BEFORE_AFTER,
		TRACKED_YN,
		CNH_VARIANCE,
		DNZ_CHR_ID,
		TEMPLATE_YN,
		DATE_ACTIVE,
		OBJECT_ID,
		DATE_INACTIVE,
		JTOT_OBJECT_CODE,
		TASK_OWNER_ID,
		CNH_TYPE,
	        ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	FROM    OKC_CONDITION_HEADERS_HV
	WHERE 	ID = p_cnh_id
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_cnhv_rec;
      FETCH c_cnhv_rec
      INTO	x_cnhv_rec.ID,
		x_cnhv_rec.SFWT_FLAG,
		x_cnhv_rec.ACN_ID,
		x_cnhv_rec.COUNTER_GROUP_ID,
		x_cnhv_rec.DESCRIPTION,
		x_cnhv_rec.SHORT_DESCRIPTION,
		x_cnhv_rec.COMMENTS,
		x_cnhv_rec.ONE_TIME_YN,
		x_cnhv_rec.NAME,
		x_cnhv_rec.CONDITION_VALID_YN,
		x_cnhv_rec.BEFORE_AFTER,
		x_cnhv_rec.TRACKED_YN,
		x_cnhv_rec.CNH_VARIANCE,
		x_cnhv_rec.DNZ_CHR_ID,
		x_cnhv_rec.TEMPLATE_YN,
		x_cnhv_rec.DATE_ACTIVE,
		x_cnhv_rec.OBJECT_ID,
		x_cnhv_rec.DATE_INACTIVE,
		x_cnhv_rec.JTOT_OBJECT_CODE,
		x_cnhv_rec.TASK_OWNER_ID,
		x_cnhv_rec.CNH_TYPE,
		x_cnhv_rec.ATTRIBUTE_CATEGORY,
		x_cnhv_rec.ATTRIBUTE1,
		x_cnhv_rec.ATTRIBUTE2,
		x_cnhv_rec.ATTRIBUTE3,
		x_cnhv_rec.ATTRIBUTE4,
		x_cnhv_rec.ATTRIBUTE5,
		x_cnhv_rec.ATTRIBUTE6,
		x_cnhv_rec.ATTRIBUTE7,
		x_cnhv_rec.ATTRIBUTE8,
		x_cnhv_rec.ATTRIBUTE9,
		x_cnhv_rec.ATTRIBUTE10,
		x_cnhv_rec.ATTRIBUTE11,
		x_cnhv_rec.ATTRIBUTE12,
		x_cnhv_rec.ATTRIBUTE13,
		x_cnhv_rec.ATTRIBUTE14,
		x_cnhv_rec.ATTRIBUTE15;

      l_no_data_found := c_cnhv_rec%NOTFOUND;
      CLOSE c_cnhv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cnhv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the condition lines record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_cnlv_rec(p_cnl_id IN NUMBER,
				x_cnlv_rec OUT NOCOPY cnlv_rec_type) RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_cnlv_rec IS
      SELECT	ID,
		SFWT_FLAG,
		START_AT,
		CNH_ID,
		PDF_ID,
		AAE_ID,
		LEFT_CTR_MASTER_ID,
		RIGHT_CTR_MASTER_ID,
		LEFT_COUNTER_ID,
		RIGHT_COUNTER_ID,
		DNZ_CHR_ID,
		SORTSEQ,
		CNL_TYPE,
		DESCRIPTION,
		LEFT_PARENTHESIS,
		RELATIONAL_OPERATOR,
		RIGHT_PARENTHESIS,
		LOGICAL_OPERATOR,
		TOLERANCE,
		RIGHT_OPERAND,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	FROM    OKC_CONDITION_LINES_V
	WHERE 	ID = p_cnl_id
          AND   G_COPY_HISTORY_YN = 'N'
   UNION ALL
      SELECT	ID,
		SFWT_FLAG,
		START_AT,
		CNH_ID,
		PDF_ID,
		AAE_ID,
		LEFT_CTR_MASTER_ID,
		RIGHT_CTR_MASTER_ID,
		LEFT_COUNTER_ID,
		RIGHT_COUNTER_ID,
		DNZ_CHR_ID,
		SORTSEQ,
		CNL_TYPE,
		DESCRIPTION,
		LEFT_PARENTHESIS,
		RELATIONAL_OPERATOR,
		RIGHT_PARENTHESIS,
		LOGICAL_OPERATOR,
		TOLERANCE,
		RIGHT_OPERAND,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
	FROM    OKC_CONDITION_LINES_HV
	WHERE 	ID = p_cnl_id
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_cnlv_rec;
      FETCH c_cnlv_rec
      INTO	x_cnlv_rec.ID,
		x_cnlv_rec.SFWT_FLAG,
		x_cnlv_rec.START_AT,
		x_cnlv_rec.CNH_ID,
		x_cnlv_rec.PDF_ID,
		x_cnlv_rec.AAE_ID,
		x_cnlv_rec.LEFT_CTR_MASTER_ID,
		x_cnlv_rec.RIGHT_CTR_MASTER_ID,
		x_cnlv_rec.LEFT_COUNTER_ID,
		x_cnlv_rec.RIGHT_COUNTER_ID,
		x_cnlv_rec.DNZ_CHR_ID,
		x_cnlv_rec.SORTSEQ,
		x_cnlv_rec.CNL_TYPE,
		x_cnlv_rec.DESCRIPTION,
		x_cnlv_rec.LEFT_PARENTHESIS,
		x_cnlv_rec.RELATIONAL_OPERATOR,
		x_cnlv_rec.RIGHT_PARENTHESIS,
		x_cnlv_rec.LOGICAL_OPERATOR,
		x_cnlv_rec.TOLERANCE,
		x_cnlv_rec.RIGHT_OPERAND,
		x_cnlv_rec.ATTRIBUTE_CATEGORY,
		x_cnlv_rec.ATTRIBUTE1,
		x_cnlv_rec.ATTRIBUTE2,
		x_cnlv_rec.ATTRIBUTE3,
		x_cnlv_rec.ATTRIBUTE4,
		x_cnlv_rec.ATTRIBUTE5,
		x_cnlv_rec.ATTRIBUTE6,
		x_cnlv_rec.ATTRIBUTE7,
		x_cnlv_rec.ATTRIBUTE8,
		x_cnlv_rec.ATTRIBUTE9,
		x_cnlv_rec.ATTRIBUTE10,
		x_cnlv_rec.ATTRIBUTE11,
		x_cnlv_rec.ATTRIBUTE12,
		x_cnlv_rec.ATTRIBUTE13,
		x_cnlv_rec.ATTRIBUTE14,
		x_cnlv_rec.ATTRIBUTE15;

      l_no_data_found := c_cnlv_rec%NOTFOUND;
      CLOSE c_cnlv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_cnlv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the contacts record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_ctcv_rec(p_ctc_id IN NUMBER,
				x_ctcv_rec OUT NOCOPY ctcv_rec_type) RETURN  VARCHAR2 IS

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_ctcv_rec IS
      SELECT	ID,
                CPL_ID,
                CRO_CODE,
                DNZ_CHR_ID,
                CONTACT_SEQUENCE,
                OBJECT1_ID1,
                OBJECT1_ID2,
                JTOT_OBJECT1_CODE,
			 RESOURCE_CLASS,--Bug#3038104
			 SALES_GROUP_ID, --Bug#2882737
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                START_DATE,
                END_DATE,
                PRIMARY_YN  -- Bug 2374325

	FROM    OKC_CONTACTS_V
	WHERE 	ID = p_ctc_id
          AND   G_COPY_HISTORY_YN = 'N'
UNION ALL
      SELECT	ID,
                CPL_ID,
                CRO_CODE,
                DNZ_CHR_ID,
                CONTACT_SEQUENCE,
                OBJECT1_ID1,
                OBJECT1_ID2,
                JTOT_OBJECT1_CODE,
			 RESOURCE_CLASS,--Bug#3038104
			 SALES_GROUP_ID, --Bug#2882737
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15,
                START_DATE,
                END_DATE,
                PRIMARY_YN  -- Bug 2374325
	FROM    OKC_CONTACTS_HV
	WHERE 	ID = p_ctc_id
          AND   major_version = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_ctcv_rec;
      FETCH c_ctcv_rec
      INTO	x_ctcv_rec.ID,
                x_ctcv_rec.CPL_ID,
                x_ctcv_rec.CRO_CODE,
                x_ctcv_rec.DNZ_CHR_ID,
                x_ctcv_rec.CONTACT_SEQUENCE,
                x_ctcv_rec.OBJECT1_ID1,
                x_ctcv_rec.OBJECT1_ID2,
                x_ctcv_rec.JTOT_OBJECT1_CODE,
			 x_ctcv_rec.resource_class,--Bug#3038104
			 x_ctcv_rec.SALES_GROUP_ID, --Bug#2882737
                x_ctcv_rec.ATTRIBUTE_CATEGORY,
                x_ctcv_rec.ATTRIBUTE1,
                x_ctcv_rec.ATTRIBUTE2,
                x_ctcv_rec.ATTRIBUTE3,
                x_ctcv_rec.ATTRIBUTE4,
                x_ctcv_rec.ATTRIBUTE5,
                x_ctcv_rec.ATTRIBUTE6,
                x_ctcv_rec.ATTRIBUTE7,
                x_ctcv_rec.ATTRIBUTE8,
                x_ctcv_rec.ATTRIBUTE9,
                x_ctcv_rec.ATTRIBUTE10,
                x_ctcv_rec.ATTRIBUTE11,
                x_ctcv_rec.ATTRIBUTE12,
                x_ctcv_rec.ATTRIBUTE13,
                x_ctcv_rec.ATTRIBUTE14,
                x_ctcv_rec.ATTRIBUTE15,
                x_ctcv_rec.START_DATE,
                x_ctcv_rec.END_DATE,
                x_ctcv_rec.PRIMARY_YN;
      l_no_data_found := c_ctcv_rec%NOTFOUND;
      CLOSE c_ctcv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_ctcv_rec;
  ----------------------------------------------------------------------------
  --Function to populate the rule groups record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_rgpv_rec(p_rgp_id IN NUMBER,
				x_rgpv_rec OUT NOCOPY rgpv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_rgpv_rec IS
      SELECT	ID,
		SFWT_FLAG,
		RGP_TYPE,
		RGD_CODE,
		CLE_ID,
		CHR_ID,
		DNZ_CHR_ID,
		PARENT_RGP_ID,
		SAT_CODE,
		COMMENTS,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
      FROM 	OKC_RULE_GROUPS_V
      WHERE	ID = p_rgp_id
       AND      G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT	ID,
		SFWT_FLAG,
		RGP_TYPE,
		RGD_CODE,
		CLE_ID,
		CHR_ID,
		DNZ_CHR_ID,
		PARENT_RGP_ID,
		SAT_CODE,
		COMMENTS,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15
      FROM 	OKC_RULE_GROUPS_HV
      WHERE	ID = p_rgp_id
       AND      G_COPY_HISTORY_YN = 'Y'
       AND      major_version = G_FROM_VERSION_NUMBER;
   BEGIN
      OPEN c_rgpv_rec;
      FETCH c_rgpv_rec
      INTO	x_rgpv_rec.ID,
		x_rgpv_rec.SFWT_FLAG,
		x_rgpv_rec.RGP_TYPE,
		x_rgpv_rec.RGD_CODE,
		x_rgpv_rec.CLE_ID,
		x_rgpv_rec.CHR_ID,
		x_rgpv_rec.DNZ_CHR_ID,
		x_rgpv_rec.PARENT_RGP_ID,
		x_rgpv_rec.SAT_CODE,
		x_rgpv_rec.COMMENTS,
		x_rgpv_rec.ATTRIBUTE_CATEGORY,
		x_rgpv_rec.ATTRIBUTE1,
		x_rgpv_rec.ATTRIBUTE2,
		x_rgpv_rec.ATTRIBUTE3,
		x_rgpv_rec.ATTRIBUTE4,
		x_rgpv_rec.ATTRIBUTE5,
		x_rgpv_rec.ATTRIBUTE6,
		x_rgpv_rec.ATTRIBUTE7,
		x_rgpv_rec.ATTRIBUTE8,
		x_rgpv_rec.ATTRIBUTE9,
		x_rgpv_rec.ATTRIBUTE10,
		x_rgpv_rec.ATTRIBUTE11,
		x_rgpv_rec.ATTRIBUTE12,
		x_rgpv_rec.ATTRIBUTE13,
		x_rgpv_rec.ATTRIBUTE14,
		x_rgpv_rec.ATTRIBUTE15;

      l_no_data_found := c_rgpv_rec%NOTFOUND;
      CLOSE c_rgpv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_rgpv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the timevalues to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_tvev_rec(p_tve_id IN NUMBER,
				x_tvev_rec OUT NOCOPY tvev_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_tvev_rec IS
      SELECT	ID,
		SFWT_FLAG,
		SPN_ID,
		TVE_ID_OFFSET,
		UOM_CODE,
		TVE_ID_GENERATED_BY,
		TVE_ID_STARTED,
		TVE_ID_ENDED,
		TVE_ID_LIMITED,
		CNH_ID,
		DNZ_CHR_ID,
		TZE_ID,
		DESCRIPTION,
		SHORT_DESCRIPTION,
		COMMENTS,
		DURATION,
		OPERATOR,
		BEFORE_AFTER,
		DATETIME,
		MONTH,
		DAY,
		DAY_OF_WEEK,
		HOUR,
		MINUTE,
		SECOND,
		NAME,
		INTERVAL_YN,
		NTH,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		TVE_TYPE
      FROM 	OKC_TIMEVALUES_V
      WHERE	ID = p_tve_id;
    BEGIN
      OPEN c_tvev_rec;
      FETCH c_tvev_rec
      INTO	x_tvev_rec.ID,
		x_tvev_rec.SFWT_FLAG,
		x_tvev_rec.SPN_ID,
		x_tvev_rec.TVE_ID_OFFSET,
		x_tvev_rec.UOM_CODE,
		x_tvev_rec.TVE_ID_GENERATED_BY,
		x_tvev_rec.TVE_ID_STARTED,
		x_tvev_rec.TVE_ID_ENDED,
		x_tvev_rec.TVE_ID_LIMITED,
		x_tvev_rec.CNH_ID,
		x_tvev_rec.DNZ_CHR_ID,
		x_tvev_rec.TZE_ID,
		x_tvev_rec.DESCRIPTION,
		x_tvev_rec.SHORT_DESCRIPTION,
		x_tvev_rec.COMMENTS,
		x_tvev_rec.DURATION,
		x_tvev_rec.OPERATOR,
		x_tvev_rec.BEFORE_AFTER,
		x_tvev_rec.DATETIME,
		x_tvev_rec.MONTH,
		x_tvev_rec.DAY,
		x_tvev_rec.DAY_OF_WEEK,
		x_tvev_rec.HOUR,
		x_tvev_rec.MINUTE,
		x_tvev_rec.SECOND,
		x_tvev_rec.NAME,
		x_tvev_rec.INTERVAL_YN,
		x_tvev_rec.NTH,
		x_tvev_rec.ATTRIBUTE_CATEGORY,
		x_tvev_rec.ATTRIBUTE1,
		x_tvev_rec.ATTRIBUTE2,
		x_tvev_rec.ATTRIBUTE3,
		x_tvev_rec.ATTRIBUTE4,
		x_tvev_rec.ATTRIBUTE5,
		x_tvev_rec.ATTRIBUTE6,
		x_tvev_rec.ATTRIBUTE7,
		x_tvev_rec.ATTRIBUTE8,
		x_tvev_rec.ATTRIBUTE9,
		x_tvev_rec.ATTRIBUTE10,
		x_tvev_rec.ATTRIBUTE11,
		x_tvev_rec.ATTRIBUTE12,
		x_tvev_rec.ATTRIBUTE13,
		x_tvev_rec.ATTRIBUTE14,
		x_tvev_rec.ATTRIBUTE15,
		x_tvev_rec.TVE_TYPE;

      l_no_data_found := c_tvev_rec%NOTFOUND;
      CLOSE c_tvev_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_tvev_rec;


  ----------------------------------------------------------------------------
  --Function to populate the rules record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_rulv_rec(p_rul_id IN NUMBER,
				x_rulv_rec OUT NOCOPY rulv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_rulv_rec IS
      SELECT	ID,
--Bug 3055393		SFWT_FLAG,
		OBJECT1_ID1,
		OBJECT2_ID1,
		OBJECT3_ID1,
		OBJECT1_ID2,
		OBJECT2_ID2,
		OBJECT3_ID2,
		JTOT_OBJECT1_CODE,
		JTOT_OBJECT2_CODE,
		JTOT_OBJECT3_CODE,
		DNZ_CHR_ID,
		RGP_ID,
		PRIORITY,
		STD_TEMPLATE_YN,
		COMMENTS,
		WARN_YN,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
--Bug 3055393		TEXT,
		RULE_INFORMATION_CATEGORY,
		RULE_INFORMATION1,
		RULE_INFORMATION2,
		RULE_INFORMATION3,
		RULE_INFORMATION4,
		RULE_INFORMATION5,
		RULE_INFORMATION6,
		RULE_INFORMATION7,
		RULE_INFORMATION8,
		RULE_INFORMATION9,
		RULE_INFORMATION10,
		RULE_INFORMATION11,
		RULE_INFORMATION12,
		RULE_INFORMATION13,
		RULE_INFORMATION14,
		RULE_INFORMATION15
      FROM 	OKC_RULES_V
      WHERE	ID = p_rul_id
        AND     G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT	ID,
-- Bug 3055393		SFWT_FLAG,
		OBJECT1_ID1,
		OBJECT2_ID1,
		OBJECT3_ID1,
		OBJECT1_ID2,
		OBJECT2_ID2,
		OBJECT3_ID2,
		JTOT_OBJECT1_CODE,
		JTOT_OBJECT2_CODE,
		JTOT_OBJECT3_CODE,
		DNZ_CHR_ID,
		RGP_ID,
		PRIORITY,
		STD_TEMPLATE_YN,
		COMMENTS,
		WARN_YN,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
--Bug 3055393		TEXT,
		RULE_INFORMATION_CATEGORY,
		RULE_INFORMATION1,
		RULE_INFORMATION2,
		RULE_INFORMATION3,
		RULE_INFORMATION4,
		RULE_INFORMATION5,
		RULE_INFORMATION6,
		RULE_INFORMATION7,
		RULE_INFORMATION8,
		RULE_INFORMATION9,
		RULE_INFORMATION10,
		RULE_INFORMATION11,
		RULE_INFORMATION12,
		RULE_INFORMATION13,
		RULE_INFORMATION14,
		RULE_INFORMATION15
      FROM 	OKC_RULES_HV
      WHERE	ID = p_rul_id
        AND major_version = G_FROM_VERSION_NUMBER
        AND G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_rulv_rec;
      FETCH c_rulv_rec
      INTO	x_rulv_rec.ID,
--Bug 3055393		x_rulv_rec.SFWT_FLAG,
		x_rulv_rec.OBJECT1_ID1,
		x_rulv_rec.OBJECT2_ID1,
		x_rulv_rec.OBJECT3_ID1,
		x_rulv_rec.OBJECT1_ID2,
		x_rulv_rec.OBJECT2_ID2,
		x_rulv_rec.OBJECT3_ID2,
		x_rulv_rec.JTOT_OBJECT1_CODE,
		x_rulv_rec.JTOT_OBJECT2_CODE,
		x_rulv_rec.JTOT_OBJECT3_CODE,
		x_rulv_rec.DNZ_CHR_ID,
		x_rulv_rec.RGP_ID,
		x_rulv_rec.PRIORITY,
		x_rulv_rec.STD_TEMPLATE_YN,
		x_rulv_rec.COMMENTS,
		x_rulv_rec.WARN_YN,
		x_rulv_rec.ATTRIBUTE_CATEGORY,
		x_rulv_rec.ATTRIBUTE1,
		x_rulv_rec.ATTRIBUTE2,
		x_rulv_rec.ATTRIBUTE3,
		x_rulv_rec.ATTRIBUTE4,
		x_rulv_rec.ATTRIBUTE5,
		x_rulv_rec.ATTRIBUTE6,
		x_rulv_rec.ATTRIBUTE7,
		x_rulv_rec.ATTRIBUTE8,
		x_rulv_rec.ATTRIBUTE9,
		x_rulv_rec.ATTRIBUTE10,
		x_rulv_rec.ATTRIBUTE11,
		x_rulv_rec.ATTRIBUTE12,
		x_rulv_rec.ATTRIBUTE13,
		x_rulv_rec.ATTRIBUTE14,
		x_rulv_rec.ATTRIBUTE15,
--Bug 3055393	     x_rulv_rec.TEXT,
		x_rulv_rec.RULE_INFORMATION_CATEGORY,
		x_rulv_rec.RULE_INFORMATION1,
		x_rulv_rec.RULE_INFORMATION2,
		x_rulv_rec.RULE_INFORMATION3,
		x_rulv_rec.RULE_INFORMATION4,
		x_rulv_rec.RULE_INFORMATION5,
		x_rulv_rec.RULE_INFORMATION6,
		x_rulv_rec.RULE_INFORMATION7,
		x_rulv_rec.RULE_INFORMATION8,
		x_rulv_rec.RULE_INFORMATION9,
		x_rulv_rec.RULE_INFORMATION10,
		x_rulv_rec.RULE_INFORMATION11,
		x_rulv_rec.RULE_INFORMATION12,
		x_rulv_rec.RULE_INFORMATION13,
		x_rulv_rec.RULE_INFORMATION14,
		x_rulv_rec.RULE_INFORMATION15;
      l_no_data_found := c_rulv_rec%NOTFOUND;
      CLOSE c_rulv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_rulv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the lines record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_clev_rec(p_cle_id IN NUMBER,
                             p_renew_ref_yn IN VARCHAR2, -- Added for bugfix 2307197
				x_clev_rec OUT NOCOPY clev_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_clev_rec IS
      SELECT 	ID,
		SFWT_FLAG,
		CHR_ID,
		CLE_ID,
                decode(p_renew_ref_yn, 'Y', LINE_NUMBER,''),       -- Modified for bugfix 2307197
                LSE_ID,
		STS_CODE,
		DISPLAY_SEQUENCE,
		TRN_CODE,
		COMMENTS,
		ITEM_DESCRIPTION,
		OKE_BOE_DESCRIPTION,
		COGNOMEN,
		HIDDEN_IND,
                PRICE_UNIT,
                PRICE_UNIT_PERCENT,
		PRICE_NEGOTIATED,
		PRICE_LEVEL_IND,
		INVOICE_LINE_LEVEL_IND,
		DPAS_RATING,
		BLOCK23TEXT,
		EXCEPTION_YN,
		TEMPLATE_USED,
		DATE_TERMINATED,
		NAME,
		START_DATE,
		END_DATE,
		DATE_RENEWED,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_ID,
                PROGRAM_UPDATE_DATE,
                PRICE_LIST_ID,
                PRICING_DATE,
                PRICE_LIST_LINE_ID,
                LINE_LIST_PRICE,
                ITEM_TO_PRICE_YN,
                PRICE_BASIS_YN,
                CONFIG_HEADER_ID,
                CONFIG_REVISION_NUMBER,
                CONFIG_COMPLETE_YN,
                CONFIG_VALID_YN,
                CONFIG_TOP_MODEL_LINE_ID,
                CONFIG_ITEM_TYPE,
             ---Bug.No.-1942374
                CONFIG_ITEM_ID,
             ---Bug.No.-1942374
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		PRICE_TYPE,
		CURRENCY_CODE,
          SERVICE_ITEM_YN,
                       -- new columns for price hold
          PH_PRICING_TYPE,
          PH_ADJUSTMENT,
          PH_PRICE_BREAK_BASIS,
          PH_MIN_QTY,
          PH_MIN_AMT,
          PH_QP_REFERENCE_ID,
          PH_VALUE,
          PH_ENFORCE_PRICE_LIST_YN,
          PH_INTEGRATED_WITH_QP,
                -- new colums to replace rules
          CUST_ACCT_ID,
          BILL_TO_SITE_USE_ID,
          INV_RULE_ID,
          LINE_RENEWAL_TYPE_CODE,
          SHIP_TO_SITE_USE_ID,
          PAYMENT_TERM_ID,
		ANNUALIZED_FACTOR,       --Bug 4722452: Added these two column to support Update_Service
		PAYMENT_INSTRUCTION_TYPE --in R12

      FROM	OKC_K_LINES_V
      WHERE	id = p_cle_id;
    BEGIN
IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' get_clev_rec ');
   OKC_DEBUG.log('100 : Entering  get_clev_rec  ', 2);
   OKC_DEBUG.log('100 : p_cle_id : '||p_cle_id);
END IF;
      OPEN c_clev_rec;
      FETCH c_clev_rec
      INTO	x_clev_rec.ID,
		x_clev_rec.SFWT_FLAG,
		x_clev_rec.CHR_ID,
		x_clev_rec.CLE_ID,
                x_clev_rec.LINE_NUMBER,
		x_clev_rec.LSE_ID,
		x_clev_rec.STS_CODE,
		x_clev_rec.DISPLAY_SEQUENCE,
		x_clev_rec.TRN_CODE,
		x_clev_rec.COMMENTS,
		x_clev_rec.ITEM_DESCRIPTION,
		x_clev_rec.OKE_BOE_DESCRIPTION,
		x_clev_rec.COGNOMEN,
		x_clev_rec.HIDDEN_IND,
                x_clev_rec.PRICE_UNIT,
                x_clev_rec.PRICE_UNIT_PERCENT,
		x_clev_rec.PRICE_NEGOTIATED,
		x_clev_rec.PRICE_LEVEL_IND,
		x_clev_rec.INVOICE_LINE_LEVEL_IND,
		x_clev_rec.DPAS_RATING,
		x_clev_rec.BLOCK23TEXT,
		x_clev_rec.EXCEPTION_YN,
		x_clev_rec.TEMPLATE_USED,
		x_clev_rec.DATE_TERMINATED,
		x_clev_rec.NAME,
		x_clev_rec.START_DATE,
		x_clev_rec.END_DATE,
		x_clev_rec.DATE_RENEWED,
                x_clev_rec.REQUEST_ID,
                x_clev_rec.PROGRAM_APPLICATION_ID,
                x_clev_rec.PROGRAM_ID,
                x_clev_rec.PROGRAM_UPDATE_DATE,
                x_clev_rec.PRICE_LIST_ID,
                x_clev_rec.PRICING_DATE,
                x_clev_rec.PRICE_LIST_LINE_ID,
                x_clev_rec.LINE_LIST_PRICE,
                x_clev_rec.ITEM_TO_PRICE_YN,
                x_clev_rec.PRICE_BASIS_YN,
                x_clev_rec.CONFIG_HEADER_ID,
                x_clev_rec.CONFIG_REVISION_NUMBER,
                x_clev_rec.CONFIG_COMPLETE_YN,
                x_clev_rec.CONFIG_VALID_YN,
                x_clev_rec.CONFIG_TOP_MODEL_LINE_ID,
                x_clev_rec.CONFIG_ITEM_TYPE,
             ---Bug.No.-1942374
                x_clev_rec.CONFIG_ITEM_ID,
             ---Bug.No.-1942374
		x_clev_rec.ATTRIBUTE_CATEGORY,
		x_clev_rec.ATTRIBUTE1,
		x_clev_rec.ATTRIBUTE2,
		x_clev_rec.ATTRIBUTE3,
		x_clev_rec.ATTRIBUTE4,
		x_clev_rec.ATTRIBUTE5,
		x_clev_rec.ATTRIBUTE6,
		x_clev_rec.ATTRIBUTE7,
		x_clev_rec.ATTRIBUTE8,
		x_clev_rec.ATTRIBUTE9,
		x_clev_rec.ATTRIBUTE10,
		x_clev_rec.ATTRIBUTE11,
		x_clev_rec.ATTRIBUTE12,
		x_clev_rec.ATTRIBUTE13,
		x_clev_rec.ATTRIBUTE14,
		x_clev_rec.ATTRIBUTE15,
		x_clev_rec.PRICE_TYPE,
		x_clev_rec.CURRENCY_CODE,
		x_clev_rec.SERVICE_ITEM_YN,
                        --new columns for price hold
          x_clev_rec.PH_PRICING_TYPE,
          x_clev_rec.PH_ADJUSTMENT,
          x_clev_rec.PH_PRICE_BREAK_BASIS,
          x_clev_rec.PH_MIN_QTY,
          x_clev_rec.PH_MIN_AMT,
          x_clev_rec.PH_QP_REFERENCE_ID,
          x_clev_rec.PH_VALUE,
          x_clev_rec.PH_ENFORCE_PRICE_LIST_YN,
          x_clev_rec.PH_INTEGRATED_WITH_QP,
            -- new colums to replace rules
          x_clev_rec.CUST_ACCT_ID,
          x_clev_rec.BILL_TO_SITE_USE_ID,
          x_clev_rec.INV_RULE_ID,
          x_clev_rec.LINE_RENEWAL_TYPE_CODE,
          x_clev_rec.SHIP_TO_SITE_USE_ID,
          x_clev_rec.PAYMENT_TERM_ID,
		x_clev_rec.ANNUALIZED_FACTOR,         --Fix for bug 4722452
		x_clev_rec.PAYMENT_INSTRUCTION_TYPE;  --

      l_no_data_found := c_clev_rec%NOTFOUND;
      CLOSE c_clev_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
         IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('10000 : Exiting Procedure get_clev_rec ', 2);
            OKC_DEBUG.ReSet_Indentation;
         END IF;
        return(l_return_status);
      ELSE
         IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('30000 : Exiting Procedure get_clev_rec ', 2);
            OKC_DEBUG.ReSet_Indentation;
         END IF;
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
         IF (l_debug = 'Y') THEN
            OKC_DEBUG.log('40000 : Exiting Procedure get_clev_rec ', 2);
            OKC_DEBUG.ReSet_Indentation;
         END IF;
        return(l_return_status);
    END get_clev_rec;

  ----------------------------------------------------------------------------
  --Function to populate the Header record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_chrv_rec(p_chr_id IN NUMBER,
				x_chrv_rec OUT NOCOPY chrv_rec_type)
    				RETURN  VARCHAR2 IS
      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

-- Bug 1922121: Compilation errors on ktst115. Problem occurred
-- because application_id is defined as varchar2(240) in
-- okc_k_headers_bh/hv and as NUMBER in okc_k_headers_b/v. This gives
-- problems in the UNION ALL because it tries to combine datatypes
-- Fix: Put a to_char() around application_id in the first cursor

      CURSOR c_chrv_rec IS
      SELECT 	ID,
		SFWT_FLAG,
		CHR_ID_RESPONSE,
		CHR_ID_AWARD,
		INV_ORGANIZATION_ID,
		to_char(APPLICATION_ID),
		STS_CODE,
		QCL_ID,
		SCS_CODE,
		CONTRACT_NUMBER,
		CURRENCY_CODE,
		CONTRACT_NUMBER_MODIFIER,
		ARCHIVED_YN,
		DELETED_YN,
		CUST_PO_NUMBER_REQ_YN,
		PRE_PAY_REQ_YN,
		CUST_PO_NUMBER,
		SHORT_DESCRIPTION,
		COMMENTS,
		DESCRIPTION,
		DPAS_RATING,
		COGNOMEN,
		TEMPLATE_YN,
		TEMPLATE_USED,
		DATE_APPROVED,
		DATETIME_CANCELLED,
		AUTO_RENEW_DAYS,
		DATE_ISSUED,
		DATETIME_RESPONDED,
		NON_RESPONSE_REASON,
		NON_RESPONSE_EXPLAIN,
		RFP_TYPE,
		CHR_TYPE,
		KEEP_ON_MAIL_LIST,
		SET_ASIDE_REASON,
		SET_ASIDE_PERCENT,
		RESPONSE_COPIES_REQ,
		DATE_CLOSE_PROJECTED,
		DATETIME_PROPOSED,
		DATE_SIGNED,
		DATE_TERMINATED,
		DATE_RENEWED,
		TRN_CODE,
		START_DATE,
		END_DATE,
		AUTHORING_ORG_ID,
		BUY_OR_SELL,
		ISSUE_OR_RECEIVE,
		ESTIMATED_AMOUNT,
		PROGRAM_ID,
                REQUEST_ID,
                PRICE_LIST_ID,
                PRICING_DATE,
                SIGN_BY_DATE,
                PROGRAM_UPDATE_DATE,
                TOTAL_LINE_LIST_PRICE,
                PROGRAM_APPLICATION_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
          GOVERNING_CONTRACT_YN,
       -- new colums to replace rules
          CONVERSION_TYPE,
          CONVERSION_RATE,
          CONVERSION_RATE_DATE,
          CONVERSION_EURO_RATE,
          CUST_ACCT_ID,
          BILL_TO_SITE_USE_ID,
          INV_RULE_ID,
          RENEWAL_TYPE_CODE,
          RENEWAL_NOTIFY_TO,
          RENEWAL_END_DATE,
          SHIP_TO_SITE_USE_ID,
          PAYMENT_TERM_ID

      FROM	OKC_K_HEADERS_V
      WHERE	id = p_chr_id
        AND     G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT 	ID,
		SFWT_FLAG,
		CHR_ID_RESPONSE,
		CHR_ID_AWARD,
		INV_ORGANIZATION_ID,
		APPLICATION_ID,
		STS_CODE,
		QCL_ID,
		SCS_CODE,
		CONTRACT_NUMBER,
		CURRENCY_CODE,
		CONTRACT_NUMBER_MODIFIER,
		ARCHIVED_YN,
		DELETED_YN,
		CUST_PO_NUMBER_REQ_YN,
		PRE_PAY_REQ_YN,
		CUST_PO_NUMBER,
		SHORT_DESCRIPTION,
		COMMENTS,
		DESCRIPTION,
		DPAS_RATING,
		COGNOMEN,
		TEMPLATE_YN,
		TEMPLATE_USED,
		DATE_APPROVED,
		DATETIME_CANCELLED,
		AUTO_RENEW_DAYS,
		DATE_ISSUED,
		DATETIME_RESPONDED,
		NON_RESPONSE_REASON,
		NON_RESPONSE_EXPLAIN,
		RFP_TYPE,
		CHR_TYPE,
		KEEP_ON_MAIL_LIST,
		SET_ASIDE_REASON,
		SET_ASIDE_PERCENT,
		RESPONSE_COPIES_REQ,
		DATE_CLOSE_PROJECTED,
		DATETIME_PROPOSED,
		DATE_SIGNED,
		DATE_TERMINATED,
		DATE_RENEWED,
		TRN_CODE,
		START_DATE,
		END_DATE,
		AUTHORING_ORG_ID,
		BUY_OR_SELL,
		ISSUE_OR_RECEIVE,
		ESTIMATED_AMOUNT,
		PROGRAM_ID,
                REQUEST_ID,
                PRICE_LIST_ID,
                PRICING_DATE,
                SIGN_BY_DATE,
                PROGRAM_UPDATE_DATE,
                TOTAL_LINE_LIST_PRICE,
                PROGRAM_APPLICATION_ID,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
          GOVERNING_CONTRACT_YN,
                      -- new colums to replace rules
          CONVERSION_TYPE,
          CONVERSION_RATE,
          CONVERSION_RATE_DATE,
          CONVERSION_EURO_RATE,
          CUST_ACCT_ID,
          BILL_TO_SITE_USE_ID,
          INV_RULE_ID,
          RENEWAL_TYPE_CODE,
          RENEWAL_NOTIFY_TO,
          RENEWAL_END_DATE,
          SHIP_TO_SITE_USE_ID,
          PAYMENT_TERM_ID

      FROM	OKC_K_HEADERS_HV
      WHERE	id = p_chr_id
        AND     major_version     = G_FROM_VERSION_NUMBER
        AND     G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_chrv_rec;
      FETCH c_chrv_rec
      INTO	x_chrv_rec.ID,
		x_chrv_rec.SFWT_FLAG,
		x_chrv_rec.CHR_ID_RESPONSE,
		x_chrv_rec.CHR_ID_AWARD,
		x_chrv_rec.INV_ORGANIZATION_ID,
		x_chrv_rec.APPLICATION_ID,
		x_chrv_rec.STS_CODE,
		x_chrv_rec.QCL_ID,
		x_chrv_rec.SCS_CODE,
		x_chrv_rec.CONTRACT_NUMBER,
		x_chrv_rec.CURRENCY_CODE,
		x_chrv_rec.CONTRACT_NUMBER_MODIFIER,
		x_chrv_rec.ARCHIVED_YN,
		x_chrv_rec.DELETED_YN,
		x_chrv_rec.CUST_PO_NUMBER_REQ_YN,
		x_chrv_rec.PRE_PAY_REQ_YN,
		x_chrv_rec.CUST_PO_NUMBER,
		x_chrv_rec.SHORT_DESCRIPTION,
		x_chrv_rec.COMMENTS,
		x_chrv_rec.DESCRIPTION,
		x_chrv_rec.DPAS_RATING,
		x_chrv_rec.COGNOMEN,
		x_chrv_rec.TEMPLATE_YN,
		x_chrv_rec.TEMPLATE_USED,
		x_chrv_rec.DATE_APPROVED,
		x_chrv_rec.DATETIME_CANCELLED,
		x_chrv_rec.AUTO_RENEW_DAYS,
		x_chrv_rec.DATE_ISSUED,
		x_chrv_rec.DATETIME_RESPONDED,
		x_chrv_rec.NON_RESPONSE_REASON,
		x_chrv_rec.NON_RESPONSE_EXPLAIN,
		x_chrv_rec.RFP_TYPE,
		x_chrv_rec.CHR_TYPE,
		x_chrv_rec.KEEP_ON_MAIL_LIST,
		x_chrv_rec.SET_ASIDE_REASON,
		x_chrv_rec.SET_ASIDE_PERCENT,
		x_chrv_rec.RESPONSE_COPIES_REQ,
		x_chrv_rec.DATE_CLOSE_PROJECTED,
		x_chrv_rec.DATETIME_PROPOSED,
		x_chrv_rec.DATE_SIGNED,
		x_chrv_rec.DATE_TERMINATED,
		x_chrv_rec.DATE_RENEWED,
		x_chrv_rec.TRN_CODE,
		x_chrv_rec.START_DATE,
		x_chrv_rec.END_DATE,
		x_chrv_rec.AUTHORING_ORG_ID,
		x_chrv_rec.BUY_OR_SELL,
		x_chrv_rec.ISSUE_OR_RECEIVE,
		x_chrv_rec.ESTIMATED_AMOUNT,
		x_chrv_rec.PROGRAM_ID,
                x_chrv_rec.REQUEST_ID,
                x_chrv_rec.PRICE_LIST_ID,
                x_chrv_rec.PRICING_DATE,
                x_chrv_rec.SIGN_BY_DATE,
                x_chrv_rec.PROGRAM_UPDATE_DATE,
                x_chrv_rec.TOTAL_LINE_LIST_PRICE,
                x_chrv_rec.PROGRAM_APPLICATION_ID,
		x_chrv_rec.ATTRIBUTE_CATEGORY,
		x_chrv_rec.ATTRIBUTE1,
		x_chrv_rec.ATTRIBUTE2,
		x_chrv_rec.ATTRIBUTE3,
		x_chrv_rec.ATTRIBUTE4,
		x_chrv_rec.ATTRIBUTE5,
		x_chrv_rec.ATTRIBUTE6,
		x_chrv_rec.ATTRIBUTE7,
		x_chrv_rec.ATTRIBUTE8,
		x_chrv_rec.ATTRIBUTE9,
		x_chrv_rec.ATTRIBUTE10,
		x_chrv_rec.ATTRIBUTE11,
		x_chrv_rec.ATTRIBUTE12,
		x_chrv_rec.ATTRIBUTE13,
		x_chrv_rec.ATTRIBUTE14,
		x_chrv_rec.ATTRIBUTE15,
          x_chrv_rec.GOVERNING_CONTRACT_YN,
               -- new colums to replace rules
          x_chrv_rec.CONVERSION_TYPE,
          x_chrv_rec.CONVERSION_RATE,
          x_chrv_rec.CONVERSION_RATE_DATE,
          x_chrv_rec.CONVERSION_EURO_RATE,
          x_chrv_rec.CUST_ACCT_ID,
          x_chrv_rec.BILL_TO_SITE_USE_ID,
          x_chrv_rec.INV_RULE_ID,
          x_chrv_rec.RENEWAL_TYPE_CODE,
          x_chrv_rec.RENEWAL_NOTIFY_TO,
          x_chrv_rec.RENEWAL_END_DATE,
          x_chrv_rec.SHIP_TO_SITE_USE_ID,
          x_chrv_rec.PAYMENT_TERM_ID;

      l_no_data_found := c_chrv_rec%NOTFOUND;
      CLOSE c_chrv_rec;
      IF l_no_data_found THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
         return(l_return_status);
      ELSE
         return(l_return_status);
      END IF;
     EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_chrv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the outcome record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_ocev_rec(p_oce_id IN NUMBER,
				x_ocev_rec OUT NOCOPY ocev_rec_type) RETURN  VARCHAR2 IS

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_ocev_rec IS
      SELECT	ID,
                SFWT_FLAG,
                PDF_ID,
                CNH_ID,
                DNZ_CHR_ID,
                ENABLED_YN,
                COMMENTS,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
	FROM    OKC_OUTCOMES_V
	WHERE 	ID = p_oce_id
         AND    G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT	ID,
                SFWT_FLAG,
                PDF_ID,
                CNH_ID,
                DNZ_CHR_ID,
                ENABLED_YN,
                COMMENTS,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
	FROM    OKC_OUTCOMES_HV
	WHERE 	ID = p_oce_id
          AND   major_version     = G_FROM_VERSION_NUMBER
          AND   G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_ocev_rec;
      FETCH c_ocev_rec
      INTO	x_ocev_rec.ID,
                x_ocev_rec.SFWT_FLAG,
                x_ocev_rec.PDF_ID,
                x_ocev_rec.CNH_ID,
                x_ocev_rec.DNZ_CHR_ID,
                x_ocev_rec.ENABLED_YN,
                x_ocev_rec.COMMENTS,
                x_ocev_rec.ATTRIBUTE_CATEGORY,
                x_ocev_rec.ATTRIBUTE1,
                x_ocev_rec.ATTRIBUTE2,
                x_ocev_rec.ATTRIBUTE3,
                x_ocev_rec.ATTRIBUTE4,
                x_ocev_rec.ATTRIBUTE5,
                x_ocev_rec.ATTRIBUTE6,
                x_ocev_rec.ATTRIBUTE7,
                x_ocev_rec.ATTRIBUTE8,
                x_ocev_rec.ATTRIBUTE9,
                x_ocev_rec.ATTRIBUTE10,
                x_ocev_rec.ATTRIBUTE11,
                x_ocev_rec.ATTRIBUTE12,
                x_ocev_rec.ATTRIBUTE13,
                x_ocev_rec.ATTRIBUTE14,
                x_ocev_rec.ATTRIBUTE15;

      l_no_data_found := c_ocev_rec%NOTFOUND;
      CLOSE c_ocev_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);
    END get_ocev_rec;

  ----------------------------------------------------------------------------
  --Function to populate the outcome arguments record to be copied.
  ----------------------------------------------------------------------------
    FUNCTION    get_oatv_rec(p_oat_id IN NUMBER,
				x_oatv_rec OUT NOCOPY oatv_rec_type) RETURN  VARCHAR2 IS

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_oatv_rec IS
      SELECT	ID,
                PDP_ID,
                OCE_ID,
                AAE_ID,
                DNZ_CHR_ID,
                VALUE
	FROM    OKC_OUTCOME_ARGUMENTS_V
	WHERE 	ID = p_oat_id
        AND     G_COPY_HISTORY_YN = 'N'
  UNION ALL
      SELECT	ID,
                PDP_ID,
                OCE_ID,
                AAE_ID,
                DNZ_CHR_ID,
                VALUE
	FROM    OKC_OUTCOME_ARGUMENTS_HV
	WHERE 	ID = p_oat_id
        AND     major_version     = G_FROM_VERSION_NUMBER
        AND     G_COPY_HISTORY_YN = 'Y';
    BEGIN
      OPEN c_oatv_rec;
      FETCH c_oatv_rec
      INTO	x_oatv_rec.ID,
                x_oatv_rec.PDP_ID,
                x_oatv_rec.OCE_ID,
                x_oatv_rec.AAE_ID,
                x_oatv_rec.DNZ_CHR_ID,
                x_oatv_rec.VALUE;

      l_no_data_found := c_oatv_rec%NOTFOUND;
      CLOSE c_oatv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_oatv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the sections record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_scnv_rec(p_scn_id IN NUMBER,
				x_scnv_rec OUT NOCOPY scnv_rec_type) RETURN  VARCHAR2 IS

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_scnv_rec IS
      SELECT	 ID,
                SCN_TYPE,
                CHR_ID,
                SAT_CODE,
                SECTION_SEQUENCE,
                LABEL,
                HEADING,
                SCN_ID,
                SFWT_FLAG,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
	FROM    OKC_SECTIONS_V
	WHERE 	ID = p_scn_id;
    BEGIN
      OPEN c_scnv_rec;
      FETCH c_scnv_rec
      INTO	 x_scnv_rec.ID,
                x_scnv_rec.SCN_TYPE,
                x_scnv_rec.CHR_ID,
                x_scnv_rec.SAT_CODE,
                x_scnv_rec.SECTION_SEQUENCE,
                x_scnv_rec.LABEL,
                x_scnv_rec.HEADING,
                x_scnv_rec.SCN_ID,
                x_scnv_rec.SFWT_FLAG,
                x_scnv_rec.ATTRIBUTE_CATEGORY,
                x_scnv_rec.ATTRIBUTE1,
                x_scnv_rec.ATTRIBUTE2,
                x_scnv_rec.ATTRIBUTE3,
                x_scnv_rec.ATTRIBUTE4,
                x_scnv_rec.ATTRIBUTE5,
                x_scnv_rec.ATTRIBUTE6,
                x_scnv_rec.ATTRIBUTE7,
                x_scnv_rec.ATTRIBUTE8,
                x_scnv_rec.ATTRIBUTE9,
                x_scnv_rec.ATTRIBUTE10,
                x_scnv_rec.ATTRIBUTE11,
                x_scnv_rec.ATTRIBUTE12,
                x_scnv_rec.ATTRIBUTE13,
                x_scnv_rec.ATTRIBUTE14,
                x_scnv_rec.ATTRIBUTE15;

      l_no_data_found := c_scnv_rec%NOTFOUND;
      CLOSE c_scnv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_scnv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the section contents record to be copied.
  ----------------------------------------------------------------------------

    FUNCTION    get_sccv_rec(p_scc_id IN NUMBER,
				x_sccv_rec OUT NOCOPY sccv_rec_type) RETURN  VARCHAR2 IS

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_sccv_rec IS
      SELECT	 ID,
                SCN_ID,
                LABEL,
                CAT_ID,
                CLE_ID,
                SAE_ID,
                CONTENT_SEQUENCE,
                ATTRIBUTE_CATEGORY,
                ATTRIBUTE1,
                ATTRIBUTE2,
                ATTRIBUTE3,
                ATTRIBUTE4,
                ATTRIBUTE5,
                ATTRIBUTE6,
                ATTRIBUTE7,
                ATTRIBUTE8,
                ATTRIBUTE9,
                ATTRIBUTE10,
                ATTRIBUTE11,
                ATTRIBUTE12,
                ATTRIBUTE13,
                ATTRIBUTE14,
                ATTRIBUTE15
	FROM    OKC_SECTION_CONTENTS_V
	WHERE 	ID = p_scc_id;
    BEGIN
      OPEN c_sccv_rec;
      FETCH c_sccv_rec
      INTO	 x_sccv_rec.ID,
                x_sccv_rec.SCN_ID,
                x_sccv_rec.LABEL,
                x_sccv_rec.CAT_ID,
                x_sccv_rec.CLE_ID,
                x_sccv_rec.SAE_ID,
                x_sccv_rec.CONTENT_SEQUENCE,
                x_sccv_rec.ATTRIBUTE_CATEGORY,
                x_sccv_rec.ATTRIBUTE1,
                x_sccv_rec.ATTRIBUTE2,
                x_sccv_rec.ATTRIBUTE3,
                x_sccv_rec.ATTRIBUTE4,
                x_sccv_rec.ATTRIBUTE5,
                x_sccv_rec.ATTRIBUTE6,
                x_sccv_rec.ATTRIBUTE7,
                x_sccv_rec.ATTRIBUTE8,
                x_sccv_rec.ATTRIBUTE9,
                x_sccv_rec.ATTRIBUTE10,
                x_sccv_rec.ATTRIBUTE11,
                x_sccv_rec.ATTRIBUTE12,
                x_sccv_rec.ATTRIBUTE13,
                x_sccv_rec.ATTRIBUTE14,
                x_sccv_rec.ATTRIBUTE15;

      l_no_data_found := c_sccv_rec%NOTFOUND;
      CLOSE c_sccv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_sccv_rec;

  ----------------------------------------------------------------------------
  --Function to populate the price_attributes record to be copied.
  ----------------------------------------------------------------------------
     FUNCTION    get_patv_rec(p_pat_id IN NUMBER,
                                x_patv_rec OUT NOCOPY patv_rec_type) RETURN  VARCHAR2 IS

      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_patv_rec IS
      SELECT
              --ID,
            PAT_ID,
            CHR_ID,
            CLE_ID,
            BSL_ID,
            BCL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            MODIFIED_FROM,
            MODIFIED_TO,
            MODIFIER_MECHANISM_TYPE_CODE,
            OPERAND,
            ARITHMETIC_OPERATOR,
            AUTOMATIC_FLAG,
            UPDATE_ALLOWED,
            UPDATED_FLAG,
            APPLIED_FLAG,
            ON_INVOICE_FLAG,
            PRICING_PHASE_ID,
           CONTEXT,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            LIST_HEADER_ID,
            LIST_LINE_ID,
            LIST_LINE_TYPE_CODE,
            CHANGE_REASON_CODE,
            CHANGE_REASON_TEXT,
            ESTIMATED_FLAG,
            ADJUSTED_AMOUNT,
           CHARGE_TYPE_CODE,
           CHARGE_SUBTYPE_CODE,
           RANGE_BREAK_QUANTITY,
           ACCRUAL_CONVERSION_RATE,
           PRICING_GROUP_SEQUENCE,
           ACCRUAL_FLAG,
           LIST_LINE_NO,
           SOURCE_SYSTEM_CODE,
           BENEFIT_QTY,
           BENEFIT_UOM_CODE,
           EXPIRATION_DATE,
           MODIFIER_LEVEL_CODE,
           PRICE_BREAK_TYPE_CODE,
           SUBSTITUTION_ATTRIBUTE,
           PRORATION_TYPE_CODE,
           INCLUDE_ON_RETURNS_FLAG,
           OBJECT_VERSION_NUMBER,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            LAST_UPDATE_LOGIN,
            REBATE_TRANSACTION_TYPE_CODE
             FROM    OKC_PRICE_ADJUSTMENTS_V
        WHERE   ID = p_pat_id;
    BEGIN
      OPEN c_patv_rec;
      FETCH c_patv_rec
      INTO
            --- x_patv_rec.ID,
              x_patv_rec.PAT_ID,
              x_patv_rec.CHR_ID,
              x_patv_rec.CLE_ID,
              x_patv_rec.BSL_ID,
              x_patv_rec.BCL_ID,
              x_patv_rec.CREATED_BY,
              x_patv_rec.CREATION_DATE,
              x_patv_rec.LAST_UPDATED_BY,
              x_patv_rec.LAST_UPDATE_DATE,
              x_patv_rec.MODIFIED_FROM,
              x_patv_rec.MODIFIED_TO,
              x_patv_rec.MODIFIER_MECHANISM_TYPE_CODE,
              x_patv_rec.OPERAND,
              x_patv_rec.ARITHMETIC_OPERATOR,
              x_patv_rec.AUTOMATIC_FLAG,
              x_patv_rec.UPDATE_ALLOWED,
              x_patv_rec.UPDATED_FLAG,
              x_patv_rec.APPLIED_FLAG,
              x_patv_rec.ON_INVOICE_FLAG,
              x_patv_rec.PRICING_PHASE_ID,
              x_patv_rec.CONTEXT,
           x_patv_rec.PROGRAM_APPLICATION_ID,
           x_patv_rec.PROGRAM_ID,
           x_patv_rec.PROGRAM_UPDATE_DATE,
           x_patv_rec.REQUEST_ID,
            x_patv_rec.LIST_HEADER_ID,
            x_patv_rec.LIST_LINE_ID,
           x_patv_rec.LIST_LINE_TYPE_CODE,
            x_patv_rec.CHANGE_REASON_CODE,
            x_patv_rec.CHANGE_REASON_TEXT,
            x_patv_rec.ESTIMATED_FLAG,
            x_patv_rec.ADJUSTED_AMOUNT,
           x_patv_rec.CHARGE_TYPE_CODE,
           x_patv_rec.CHARGE_SUBTYPE_CODE,
           x_patv_rec.RANGE_BREAK_QUANTITY,
           x_patv_rec.ACCRUAL_CONVERSION_RATE,
           x_patv_rec.PRICING_GROUP_SEQUENCE,
           x_patv_rec.ACCRUAL_FLAG,
            x_patv_rec.LIST_LINE_NO,
           x_patv_rec.SOURCE_SYSTEM_CODE,
           x_patv_rec.BENEFIT_QTY,
           x_patv_rec.BENEFIT_UOM_CODE,
           x_patv_rec.EXPIRATION_DATE,
           x_patv_rec.MODIFIER_LEVEL_CODE,
           x_patv_rec.PRICE_BREAK_TYPE_CODE,
           x_patv_rec.SUBSTITUTION_ATTRIBUTE,
           x_patv_rec.PRORATION_TYPE_CODE,
           x_patv_rec.INCLUDE_ON_RETURNS_FLAG,
           x_patv_rec.OBJECT_VERSION_NUMBER,
              x_patv_rec.ATTRIBUTE1,
              x_patv_rec.ATTRIBUTE2,
              x_patv_rec.ATTRIBUTE3,
              x_patv_rec.ATTRIBUTE4,
              x_patv_rec.ATTRIBUTE5,
              x_patv_rec.ATTRIBUTE6,
              x_patv_rec.ATTRIBUTE7,
              x_patv_rec.ATTRIBUTE8,
              x_patv_rec.ATTRIBUTE9,
              x_patv_rec.ATTRIBUTE10,
              x_patv_rec.ATTRIBUTE11,
              x_patv_rec.ATTRIBUTE12,
              x_patv_rec.ATTRIBUTE13,
              x_patv_rec.ATTRIBUTE14,
              x_patv_rec.ATTRIBUTE15,
              x_patv_rec.LAST_UPDATE_LOGIN,
              x_patv_rec.REBATE_TRANSACTION_TYPE_CODE;

               l_no_data_found := c_patv_rec%NOTFOUND;
      CLOSE c_patv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_patv_rec;
--------------------------------------------------------------------------------------------------

    FUNCTION    get_pacv_rec(p_pac_id IN NUMBER,
                                x_pacv_rec OUT NOCOPY pacv_rec_type) RETURN  VARCHAR2 IS

      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_pacv_rec IS
      SELECT
           ID,
            PAT_ID,
            PAT_ID_FROM,
            BSL_ID,
            CLE_ID,
            BCL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            OBJECT_VERSION_NUMBER
        FROM    OKC_PRICE_ADJ_ASSOCS_V
        WHERE   ID = p_pac_id;
    BEGIN
      OPEN c_pacv_rec;
      FETCH c_pacv_rec
      INTO
              x_pacv_rec.ID,
              x_pacv_rec.PAT_ID,
              x_pacv_rec.PAT_ID_FROM,
              x_pacv_rec.BSL_ID,
              x_pacv_rec.CLE_ID,
              x_pacv_rec.BCL_ID,
              x_pacv_rec.CREATED_BY,
              x_pacv_rec.CREATION_DATE,
              x_pacv_rec.LAST_UPDATED_BY,
              x_pacv_rec.LAST_UPDATE_DATE,
              x_pacv_rec.LAST_UPDATE_LOGIN,
              x_pacv_rec.PROGRAM_APPLICATION_ID,
              x_pacv_rec.PROGRAM_ID,
              x_pacv_rec.PROGRAM_UPDATE_DATE,
              x_pacv_rec.REQUEST_ID,
              x_pacv_rec.OBJECT_VERSION_NUMBER;
              l_no_data_found := c_pacv_rec%NOTFOUND;
      CLOSE c_pacv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_pacv_rec;
----------------------------------------------------------------------------------------------
        FUNCTION    get_paav_rec(p_paa_id IN NUMBER,
                                x_paav_rec OUT NOCOPY paav_rec_type) RETURN  VARCHAR2 IS

      l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_paav_rec IS
      SELECT
           ID,
            PAT_ID,
            FLEX_TITLE,
            PRICING_CONTEXT,
            PRICING_ATTRIBUTE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PRICING_ATTR_VALUE_FROM,
            PRICING_ATTR_VALUE_TO,
            COMPARISON_OPERATOR,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
           OBJECT_VERSION_NUMBER
             FROM    OKC_PRICE_ADJ_ATTRIBS_V
        WHERE   ID = p_paa_id;
    BEGIN
      OPEN c_paav_rec;
      FETCH c_paav_rec
      INTO
         x_paav_rec.ID,
              x_paav_rec.PAT_ID,
              x_paav_rec.FLEX_TITLE,
              x_paav_rec.PRICING_CONTEXT,
              x_paav_rec.PRICING_ATTRIBUTE,
              x_paav_rec.CREATED_BY,
              x_paav_rec.CREATION_DATE,
              x_paav_rec.LAST_UPDATED_BY,
              x_paav_rec.LAST_UPDATE_DATE,
              x_paav_rec.PRICING_ATTR_VALUE_FROM,
              x_paav_rec.PRICING_ATTR_VALUE_TO,
              x_paav_rec.COMPARISON_OPERATOR,
              x_paav_rec.LAST_UPDATE_LOGIN,
              x_paav_rec.PROGRAM_APPLICATION_ID,
              x_paav_rec.PROGRAM_ID,
              x_paav_rec.PROGRAM_UPDATE_DATE,
              x_paav_rec.REQUEST_ID,
              x_paav_rec.OBJECT_VERSION_NUMBER;
                 l_no_data_found := c_paav_rec%NOTFOUND;
      CLOSE c_paav_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_paav_rec;


-----------------------------------------------------------------------------------------------
    FUNCTION    get_pavv_rec(p_pav_id IN NUMBER,
				x_pavv_rec OUT NOCOPY pavv_rec_type) RETURN  VARCHAR2 IS

      l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_no_data_found BOOLEAN := TRUE;

      CURSOR c_pavv_rec IS
      SELECT	ID,
                CHR_ID,
                CLE_ID,
                FLEX_TITLE,
                PRICING_CONTEXT,
                PRICING_ATTRIBUTE1,
                PRICING_ATTRIBUTE2,
                PRICING_ATTRIBUTE3,
                PRICING_ATTRIBUTE4,
                PRICING_ATTRIBUTE5,
                PRICING_ATTRIBUTE6,
                PRICING_ATTRIBUTE7,
                PRICING_ATTRIBUTE8,
                PRICING_ATTRIBUTE9,
                PRICING_ATTRIBUTE10,
                PRICING_ATTRIBUTE11,
                PRICING_ATTRIBUTE12,
                PRICING_ATTRIBUTE13,
                PRICING_ATTRIBUTE14,
                PRICING_ATTRIBUTE15,
                PRICING_ATTRIBUTE16,
                PRICING_ATTRIBUTE17,
                PRICING_ATTRIBUTE18,
                PRICING_ATTRIBUTE19,
                PRICING_ATTRIBUTE20,
                PRICING_ATTRIBUTE21,
                PRICING_ATTRIBUTE22,
                PRICING_ATTRIBUTE23,
                PRICING_ATTRIBUTE24,
                PRICING_ATTRIBUTE25,
                PRICING_ATTRIBUTE26,
                PRICING_ATTRIBUTE27,
                PRICING_ATTRIBUTE28,
                PRICING_ATTRIBUTE29,
                PRICING_ATTRIBUTE30,
                PRICING_ATTRIBUTE31,
                PRICING_ATTRIBUTE32,
                PRICING_ATTRIBUTE33,
                PRICING_ATTRIBUTE34,
                PRICING_ATTRIBUTE35,
                PRICING_ATTRIBUTE36,
                PRICING_ATTRIBUTE37,
                PRICING_ATTRIBUTE38,
                PRICING_ATTRIBUTE39,
                PRICING_ATTRIBUTE40,
                PRICING_ATTRIBUTE41,
                PRICING_ATTRIBUTE42,
                PRICING_ATTRIBUTE43,
                PRICING_ATTRIBUTE44,
                PRICING_ATTRIBUTE45,
                PRICING_ATTRIBUTE46,
                PRICING_ATTRIBUTE47,
                PRICING_ATTRIBUTE48,
                PRICING_ATTRIBUTE49,
                PRICING_ATTRIBUTE50,
                PRICING_ATTRIBUTE51,
                PRICING_ATTRIBUTE52,
                PRICING_ATTRIBUTE53,
                PRICING_ATTRIBUTE54,
                PRICING_ATTRIBUTE55,
                PRICING_ATTRIBUTE56,
                PRICING_ATTRIBUTE57,
                PRICING_ATTRIBUTE58,
                PRICING_ATTRIBUTE59,
                PRICING_ATTRIBUTE60,
                PRICING_ATTRIBUTE61,
                PRICING_ATTRIBUTE62,
                PRICING_ATTRIBUTE63,
                PRICING_ATTRIBUTE64,
                PRICING_ATTRIBUTE65,
                PRICING_ATTRIBUTE66,
                PRICING_ATTRIBUTE67,
                PRICING_ATTRIBUTE68,
                PRICING_ATTRIBUTE69,
                PRICING_ATTRIBUTE70,
                PRICING_ATTRIBUTE71,
                PRICING_ATTRIBUTE72,
                PRICING_ATTRIBUTE73,
                PRICING_ATTRIBUTE74,
                PRICING_ATTRIBUTE75,
                PRICING_ATTRIBUTE76,
                PRICING_ATTRIBUTE77,
                PRICING_ATTRIBUTE78,
                PRICING_ATTRIBUTE79,
                PRICING_ATTRIBUTE80,
                PRICING_ATTRIBUTE81,
                PRICING_ATTRIBUTE82,
                PRICING_ATTRIBUTE83,
                PRICING_ATTRIBUTE84,
                PRICING_ATTRIBUTE85,
                PRICING_ATTRIBUTE86,
                PRICING_ATTRIBUTE87,
                PRICING_ATTRIBUTE88,
                PRICING_ATTRIBUTE89,
                PRICING_ATTRIBUTE90,
                PRICING_ATTRIBUTE91,
                PRICING_ATTRIBUTE92,
                PRICING_ATTRIBUTE93,
                PRICING_ATTRIBUTE94,
                PRICING_ATTRIBUTE95,
                PRICING_ATTRIBUTE96,
                PRICING_ATTRIBUTE97,
                PRICING_ATTRIBUTE98,
                PRICING_ATTRIBUTE99,
                PRICING_ATTRIBUTE100,
                QUALIFIER_CONTEXT,
                QUALIFIER_ATTRIBUTE1,
                QUALIFIER_ATTRIBUTE2,
                QUALIFIER_ATTRIBUTE3,
                QUALIFIER_ATTRIBUTE4,
                QUALIFIER_ATTRIBUTE5,
                QUALIFIER_ATTRIBUTE6,
                QUALIFIER_ATTRIBUTE7,
                QUALIFIER_ATTRIBUTE8,
                QUALIFIER_ATTRIBUTE9,
                QUALIFIER_ATTRIBUTE10,
                QUALIFIER_ATTRIBUTE11,
                QUALIFIER_ATTRIBUTE12,
                QUALIFIER_ATTRIBUTE13,
                QUALIFIER_ATTRIBUTE14,
                QUALIFIER_ATTRIBUTE15,
                QUALIFIER_ATTRIBUTE16,
                QUALIFIER_ATTRIBUTE17,
                QUALIFIER_ATTRIBUTE18,
                QUALIFIER_ATTRIBUTE19,
                QUALIFIER_ATTRIBUTE20,
                QUALIFIER_ATTRIBUTE21,
                QUALIFIER_ATTRIBUTE22,
                QUALIFIER_ATTRIBUTE23,
                QUALIFIER_ATTRIBUTE24,
                QUALIFIER_ATTRIBUTE25,
                QUALIFIER_ATTRIBUTE26,
                QUALIFIER_ATTRIBUTE27,
                QUALIFIER_ATTRIBUTE28,
                QUALIFIER_ATTRIBUTE29,
                QUALIFIER_ATTRIBUTE30,
                QUALIFIER_ATTRIBUTE31,
                QUALIFIER_ATTRIBUTE32,
                QUALIFIER_ATTRIBUTE33,
                QUALIFIER_ATTRIBUTE34,
                QUALIFIER_ATTRIBUTE35,
                QUALIFIER_ATTRIBUTE36,
                QUALIFIER_ATTRIBUTE37,
                QUALIFIER_ATTRIBUTE38,
                QUALIFIER_ATTRIBUTE39,
                QUALIFIER_ATTRIBUTE40,
                QUALIFIER_ATTRIBUTE41,
                QUALIFIER_ATTRIBUTE42,
                QUALIFIER_ATTRIBUTE43,
                QUALIFIER_ATTRIBUTE44,
                QUALIFIER_ATTRIBUTE45,
                QUALIFIER_ATTRIBUTE46,
                QUALIFIER_ATTRIBUTE47,
                QUALIFIER_ATTRIBUTE48,
                QUALIFIER_ATTRIBUTE49,
                QUALIFIER_ATTRIBUTE50,
                QUALIFIER_ATTRIBUTE51,
                QUALIFIER_ATTRIBUTE52,
                QUALIFIER_ATTRIBUTE53,
                QUALIFIER_ATTRIBUTE54,
                QUALIFIER_ATTRIBUTE55,
                QUALIFIER_ATTRIBUTE56,
                QUALIFIER_ATTRIBUTE57,
                QUALIFIER_ATTRIBUTE58,
                QUALIFIER_ATTRIBUTE59,
                QUALIFIER_ATTRIBUTE60,
                QUALIFIER_ATTRIBUTE61,
                QUALIFIER_ATTRIBUTE62,
                QUALIFIER_ATTRIBUTE63,
                QUALIFIER_ATTRIBUTE64,
                QUALIFIER_ATTRIBUTE65,
                QUALIFIER_ATTRIBUTE66,
                QUALIFIER_ATTRIBUTE67,
                QUALIFIER_ATTRIBUTE68,
                QUALIFIER_ATTRIBUTE69,
                QUALIFIER_ATTRIBUTE70,
                QUALIFIER_ATTRIBUTE71,
                QUALIFIER_ATTRIBUTE72,
                QUALIFIER_ATTRIBUTE73,
                QUALIFIER_ATTRIBUTE74,
                QUALIFIER_ATTRIBUTE75,
                QUALIFIER_ATTRIBUTE76,
                QUALIFIER_ATTRIBUTE77,
                QUALIFIER_ATTRIBUTE78,
                QUALIFIER_ATTRIBUTE79,
                QUALIFIER_ATTRIBUTE80,
                QUALIFIER_ATTRIBUTE81,
                QUALIFIER_ATTRIBUTE82,
                QUALIFIER_ATTRIBUTE83,
                QUALIFIER_ATTRIBUTE84,
                QUALIFIER_ATTRIBUTE85,
                QUALIFIER_ATTRIBUTE86,
                QUALIFIER_ATTRIBUTE87,
                QUALIFIER_ATTRIBUTE88,
                QUALIFIER_ATTRIBUTE89,
                QUALIFIER_ATTRIBUTE90,
                QUALIFIER_ATTRIBUTE91,
                QUALIFIER_ATTRIBUTE92,
                QUALIFIER_ATTRIBUTE93,
                QUALIFIER_ATTRIBUTE94,
                QUALIFIER_ATTRIBUTE95,
                QUALIFIER_ATTRIBUTE96,
                QUALIFIER_ATTRIBUTE97,
                QUALIFIER_ATTRIBUTE98,
                QUALIFIER_ATTRIBUTE99,
                QUALIFIER_ATTRIBUTE100
	FROM    OKC_PRICE_ATT_VALUES_V
       	WHERE   ID = p_pav_id;
    BEGIN
      OPEN c_pavv_rec;
      FETCH c_pavv_rec
      INTO	x_pavv_rec.ID,
                x_pavv_rec.CHR_ID,
                x_pavv_rec.CLE_ID,
                x_pavv_rec.FLEX_TITLE,
                x_pavv_rec.PRICING_CONTEXT,
                x_pavv_rec.PRICING_ATTRIBUTE1,
                x_pavv_rec.PRICING_ATTRIBUTE2,
                x_pavv_rec.PRICING_ATTRIBUTE3,
                x_pavv_rec.PRICING_ATTRIBUTE4,
                x_pavv_rec.PRICING_ATTRIBUTE5,
                x_pavv_rec.PRICING_ATTRIBUTE6,
                x_pavv_rec.PRICING_ATTRIBUTE7,
                x_pavv_rec.PRICING_ATTRIBUTE8,
                x_pavv_rec.PRICING_ATTRIBUTE9,
                x_pavv_rec.PRICING_ATTRIBUTE10,
                x_pavv_rec.PRICING_ATTRIBUTE11,
                x_pavv_rec.PRICING_ATTRIBUTE12,
                x_pavv_rec.PRICING_ATTRIBUTE13,
                x_pavv_rec.PRICING_ATTRIBUTE14,
                x_pavv_rec.PRICING_ATTRIBUTE15,
                x_pavv_rec.PRICING_ATTRIBUTE16,
                x_pavv_rec.PRICING_ATTRIBUTE17,
                x_pavv_rec.PRICING_ATTRIBUTE18,
                x_pavv_rec.PRICING_ATTRIBUTE19,
                x_pavv_rec.PRICING_ATTRIBUTE20,
                x_pavv_rec.PRICING_ATTRIBUTE21,
                x_pavv_rec.PRICING_ATTRIBUTE22,
                x_pavv_rec.PRICING_ATTRIBUTE23,
                x_pavv_rec.PRICING_ATTRIBUTE24,
                x_pavv_rec.PRICING_ATTRIBUTE25,
                x_pavv_rec.PRICING_ATTRIBUTE26,
                x_pavv_rec.PRICING_ATTRIBUTE27,
                x_pavv_rec.PRICING_ATTRIBUTE28,
                x_pavv_rec.PRICING_ATTRIBUTE29,
                x_pavv_rec.PRICING_ATTRIBUTE30,
                x_pavv_rec.PRICING_ATTRIBUTE31,
                x_pavv_rec.PRICING_ATTRIBUTE32,
                x_pavv_rec.PRICING_ATTRIBUTE33,
                x_pavv_rec.PRICING_ATTRIBUTE34,
                x_pavv_rec.PRICING_ATTRIBUTE35,
                x_pavv_rec.PRICING_ATTRIBUTE36,
                x_pavv_rec.PRICING_ATTRIBUTE37,
                x_pavv_rec.PRICING_ATTRIBUTE38,
                x_pavv_rec.PRICING_ATTRIBUTE39,
                x_pavv_rec.PRICING_ATTRIBUTE40,
                x_pavv_rec.PRICING_ATTRIBUTE41,
                x_pavv_rec.PRICING_ATTRIBUTE42,
                x_pavv_rec.PRICING_ATTRIBUTE43,
                x_pavv_rec.PRICING_ATTRIBUTE44,
                x_pavv_rec.PRICING_ATTRIBUTE45,
                x_pavv_rec.PRICING_ATTRIBUTE46,
                x_pavv_rec.PRICING_ATTRIBUTE47,
                x_pavv_rec.PRICING_ATTRIBUTE48,
                x_pavv_rec.PRICING_ATTRIBUTE49,
                x_pavv_rec.PRICING_ATTRIBUTE50,
                x_pavv_rec.PRICING_ATTRIBUTE51,
                x_pavv_rec.PRICING_ATTRIBUTE52,
                x_pavv_rec.PRICING_ATTRIBUTE53,
                x_pavv_rec.PRICING_ATTRIBUTE54,
                x_pavv_rec.PRICING_ATTRIBUTE55,
                x_pavv_rec.PRICING_ATTRIBUTE56,
                x_pavv_rec.PRICING_ATTRIBUTE57,
                x_pavv_rec.PRICING_ATTRIBUTE58,
                x_pavv_rec.PRICING_ATTRIBUTE59,
                x_pavv_rec.PRICING_ATTRIBUTE60,
                x_pavv_rec.PRICING_ATTRIBUTE61,
                x_pavv_rec.PRICING_ATTRIBUTE62,
                x_pavv_rec.PRICING_ATTRIBUTE63,
                x_pavv_rec.PRICING_ATTRIBUTE64,
                x_pavv_rec.PRICING_ATTRIBUTE65,
                x_pavv_rec.PRICING_ATTRIBUTE66,
                x_pavv_rec.PRICING_ATTRIBUTE67,
                x_pavv_rec.PRICING_ATTRIBUTE68,
                x_pavv_rec.PRICING_ATTRIBUTE69,
                x_pavv_rec.PRICING_ATTRIBUTE70,
                x_pavv_rec.PRICING_ATTRIBUTE71,
                x_pavv_rec.PRICING_ATTRIBUTE72,
                x_pavv_rec.PRICING_ATTRIBUTE73,
                x_pavv_rec.PRICING_ATTRIBUTE74,
                x_pavv_rec.PRICING_ATTRIBUTE75,
                x_pavv_rec.PRICING_ATTRIBUTE76,
                x_pavv_rec.PRICING_ATTRIBUTE77,
                x_pavv_rec.PRICING_ATTRIBUTE78,
                x_pavv_rec.PRICING_ATTRIBUTE79,
                x_pavv_rec.PRICING_ATTRIBUTE80,
                x_pavv_rec.PRICING_ATTRIBUTE81,
                x_pavv_rec.PRICING_ATTRIBUTE82,
                x_pavv_rec.PRICING_ATTRIBUTE83,
                x_pavv_rec.PRICING_ATTRIBUTE84,
                x_pavv_rec.PRICING_ATTRIBUTE85,
                x_pavv_rec.PRICING_ATTRIBUTE86,
                x_pavv_rec.PRICING_ATTRIBUTE87,
                x_pavv_rec.PRICING_ATTRIBUTE88,
                x_pavv_rec.PRICING_ATTRIBUTE89,
                x_pavv_rec.PRICING_ATTRIBUTE90,
                x_pavv_rec.PRICING_ATTRIBUTE91,
                x_pavv_rec.PRICING_ATTRIBUTE92,
                x_pavv_rec.PRICING_ATTRIBUTE93,
                x_pavv_rec.PRICING_ATTRIBUTE94,
                x_pavv_rec.PRICING_ATTRIBUTE95,
                x_pavv_rec.PRICING_ATTRIBUTE96,
                x_pavv_rec.PRICING_ATTRIBUTE97,
                x_pavv_rec.PRICING_ATTRIBUTE98,
                x_pavv_rec.PRICING_ATTRIBUTE99,
                x_pavv_rec.PRICING_ATTRIBUTE100,
                x_pavv_rec.QUALIFIER_CONTEXT,
                x_pavv_rec.QUALIFIER_ATTRIBUTE1,
                x_pavv_rec.QUALIFIER_ATTRIBUTE2,
                x_pavv_rec.QUALIFIER_ATTRIBUTE3,
                x_pavv_rec.QUALIFIER_ATTRIBUTE4,
                x_pavv_rec.QUALIFIER_ATTRIBUTE5,
                x_pavv_rec.QUALIFIER_ATTRIBUTE6,
                x_pavv_rec.QUALIFIER_ATTRIBUTE7,
                x_pavv_rec.QUALIFIER_ATTRIBUTE8,
                x_pavv_rec.QUALIFIER_ATTRIBUTE9,
                x_pavv_rec.QUALIFIER_ATTRIBUTE10,
                x_pavv_rec.QUALIFIER_ATTRIBUTE11,
                x_pavv_rec.QUALIFIER_ATTRIBUTE12,
                x_pavv_rec.QUALIFIER_ATTRIBUTE13,
                x_pavv_rec.QUALIFIER_ATTRIBUTE14,
                x_pavv_rec.QUALIFIER_ATTRIBUTE15,
                x_pavv_rec.QUALIFIER_ATTRIBUTE16,
                x_pavv_rec.QUALIFIER_ATTRIBUTE17,
                x_pavv_rec.QUALIFIER_ATTRIBUTE18,
                x_pavv_rec.QUALIFIER_ATTRIBUTE19,
                x_pavv_rec.QUALIFIER_ATTRIBUTE20,
                x_pavv_rec.QUALIFIER_ATTRIBUTE21,
                x_pavv_rec.QUALIFIER_ATTRIBUTE22,
                x_pavv_rec.QUALIFIER_ATTRIBUTE23,
                x_pavv_rec.QUALIFIER_ATTRIBUTE24,
                x_pavv_rec.QUALIFIER_ATTRIBUTE25,
                x_pavv_rec.QUALIFIER_ATTRIBUTE26,
                x_pavv_rec.QUALIFIER_ATTRIBUTE27,
                x_pavv_rec.QUALIFIER_ATTRIBUTE28,
                x_pavv_rec.QUALIFIER_ATTRIBUTE29,
                x_pavv_rec.QUALIFIER_ATTRIBUTE30,
                x_pavv_rec.QUALIFIER_ATTRIBUTE31,
                x_pavv_rec.QUALIFIER_ATTRIBUTE32,
                x_pavv_rec.QUALIFIER_ATTRIBUTE33,
                x_pavv_rec.QUALIFIER_ATTRIBUTE34,
                x_pavv_rec.QUALIFIER_ATTRIBUTE35,
                x_pavv_rec.QUALIFIER_ATTRIBUTE36,
                x_pavv_rec.QUALIFIER_ATTRIBUTE37,
                x_pavv_rec.QUALIFIER_ATTRIBUTE38,
                x_pavv_rec.QUALIFIER_ATTRIBUTE39,
                x_pavv_rec.QUALIFIER_ATTRIBUTE40,
                x_pavv_rec.QUALIFIER_ATTRIBUTE41,
                x_pavv_rec.QUALIFIER_ATTRIBUTE42,
                x_pavv_rec.QUALIFIER_ATTRIBUTE43,
                x_pavv_rec.QUALIFIER_ATTRIBUTE44,
                x_pavv_rec.QUALIFIER_ATTRIBUTE45,
                x_pavv_rec.QUALIFIER_ATTRIBUTE46,
                x_pavv_rec.QUALIFIER_ATTRIBUTE47,
                x_pavv_rec.QUALIFIER_ATTRIBUTE48,
                x_pavv_rec.QUALIFIER_ATTRIBUTE49,
                x_pavv_rec.QUALIFIER_ATTRIBUTE50,
                x_pavv_rec.QUALIFIER_ATTRIBUTE51,
                x_pavv_rec.QUALIFIER_ATTRIBUTE52,
                x_pavv_rec.QUALIFIER_ATTRIBUTE53,
                x_pavv_rec.QUALIFIER_ATTRIBUTE54,
                x_pavv_rec.QUALIFIER_ATTRIBUTE55,
                x_pavv_rec.QUALIFIER_ATTRIBUTE56,
                x_pavv_rec.QUALIFIER_ATTRIBUTE57,
                x_pavv_rec.QUALIFIER_ATTRIBUTE58,
                x_pavv_rec.QUALIFIER_ATTRIBUTE59,
                x_pavv_rec.QUALIFIER_ATTRIBUTE60,
                x_pavv_rec.QUALIFIER_ATTRIBUTE61,
                x_pavv_rec.QUALIFIER_ATTRIBUTE62,
                x_pavv_rec.QUALIFIER_ATTRIBUTE63,
                x_pavv_rec.QUALIFIER_ATTRIBUTE64,
                x_pavv_rec.QUALIFIER_ATTRIBUTE65,
                x_pavv_rec.QUALIFIER_ATTRIBUTE66,
                x_pavv_rec.QUALIFIER_ATTRIBUTE67,
                x_pavv_rec.QUALIFIER_ATTRIBUTE68,
                x_pavv_rec.QUALIFIER_ATTRIBUTE69,
                x_pavv_rec.QUALIFIER_ATTRIBUTE70,
                x_pavv_rec.QUALIFIER_ATTRIBUTE71,
                x_pavv_rec.QUALIFIER_ATTRIBUTE72,
                x_pavv_rec.QUALIFIER_ATTRIBUTE73,
                x_pavv_rec.QUALIFIER_ATTRIBUTE74,
                x_pavv_rec.QUALIFIER_ATTRIBUTE75,
                x_pavv_rec.QUALIFIER_ATTRIBUTE76,
                x_pavv_rec.QUALIFIER_ATTRIBUTE77,
                x_pavv_rec.QUALIFIER_ATTRIBUTE78,
                x_pavv_rec.QUALIFIER_ATTRIBUTE79,
                x_pavv_rec.QUALIFIER_ATTRIBUTE80,
                x_pavv_rec.QUALIFIER_ATTRIBUTE81,
                x_pavv_rec.QUALIFIER_ATTRIBUTE82,
                x_pavv_rec.QUALIFIER_ATTRIBUTE83,
                x_pavv_rec.QUALIFIER_ATTRIBUTE84,
                x_pavv_rec.QUALIFIER_ATTRIBUTE85,
                x_pavv_rec.QUALIFIER_ATTRIBUTE86,
                x_pavv_rec.QUALIFIER_ATTRIBUTE87,
                x_pavv_rec.QUALIFIER_ATTRIBUTE88,
                x_pavv_rec.QUALIFIER_ATTRIBUTE89,
                x_pavv_rec.QUALIFIER_ATTRIBUTE90,
                x_pavv_rec.QUALIFIER_ATTRIBUTE91,
                x_pavv_rec.QUALIFIER_ATTRIBUTE92,
                x_pavv_rec.QUALIFIER_ATTRIBUTE93,
                x_pavv_rec.QUALIFIER_ATTRIBUTE94,
                x_pavv_rec.QUALIFIER_ATTRIBUTE95,
                x_pavv_rec.QUALIFIER_ATTRIBUTE96,
                x_pavv_rec.QUALIFIER_ATTRIBUTE97,
                x_pavv_rec.QUALIFIER_ATTRIBUTE98,
                x_pavv_rec.QUALIFIER_ATTRIBUTE99,
                x_pavv_rec.QUALIFIER_ATTRIBUTE100;

      l_no_data_found := c_pavv_rec%NOTFOUND;
      CLOSE c_pavv_rec;
      IF l_no_data_found THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        return(l_return_status);
      ELSE
        return(l_return_status);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        return(l_return_status);

    END get_pavv_rec;

  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  --Proceudres for migrating different type of time values view record type. Begins.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Proceudres for migrating to tavv_rec_type
  ----------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from      IN tvev_rec_type,
    p_to        IN OUT NOCOPY tavv_rec_type
  ) IS
  BEGIN
    p_to.id 			:= p_from.id;
    p_to.spn_id 		:= p_from.spn_id;
    p_to.tve_id_generated_by 	:= p_from.tve_id_generated_by;
    p_to.tve_id_limited 	:= p_from.tve_id_limited;
    p_to.dnz_chr_id 		:= p_from.dnz_chr_id;
    p_to.tze_id 		:= p_from.tze_id;
    p_to.object_version_number 	:= p_from.object_version_number;
    p_to.created_by 		:= p_from.created_by;
    p_to.creation_date 		:= p_from.creation_date;
    p_to.last_updated_by 	:= p_from.last_updated_by;
    p_to.last_update_date 	:= p_from.last_update_date;
    p_to.datetime 		:= p_from.datetime;
    p_to.last_update_login 	:= p_from.last_update_login;
    p_to.attribute_category 	:= p_from.attribute_category;
    p_to.attribute1 		:= p_from.attribute1;
    p_to.attribute2 		:= p_from.attribute2;
    p_to.attribute3 		:= p_from.attribute3;
    p_to.attribute4 		:= p_from.attribute4;
    p_to.attribute5 		:= p_from.attribute5;
    p_to.attribute6 		:= p_from.attribute6;
    p_to.attribute7 		:= p_from.attribute7;
    p_to.attribute8 		:= p_from.attribute8;
    p_to.attribute9 		:= p_from.attribute9;
    p_to.attribute10 		:= p_from.attribute10;
    p_to.attribute11 		:= p_from.attribute11;
    p_to.attribute12 		:= p_from.attribute12;
    p_to.attribute13 		:= p_from.attribute13;
    p_to.attribute14 		:= p_from.attribute14;
    p_to.attribute15 		:= p_from.attribute15;
    p_to.sfwt_flag 		:= p_from.sfwt_flag;
    p_to.description 		:= p_from.description;
    p_to.short_description 	:= p_from.short_description;
    p_to.comments 		:= p_from.comments;
  END migrate;

  ----------------------------------------------------------------------------
  --Proceudres for migrating to tavv_rec_type
  ----------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from      IN tvev_rec_type,
    p_to        IN OUT NOCOPY talv_evt_rec_type
  ) IS
  BEGIN
    p_to.id 			:= p_from.id;
    p_to.spn_id 		:= p_from.spn_id;
    p_to.tve_id_offset 		:= p_from.tve_id_offset;
    p_to.dnz_chr_id 		:= p_from.dnz_chr_id;
    p_to.tze_id 		:= p_from.tze_id;
    p_to.tve_id_limited 	:= p_from.tve_id_limited;
    p_to.UOM_CODE 		:= p_from.UOM_CODE;
    p_to.object_version_number 	:= p_from.object_version_number;
    p_to.created_by 		:= p_from.created_by;
    p_to.creation_date 		:= p_from.creation_date;
    p_to.last_updated_by 	:= p_from.last_updated_by;
    p_to.last_update_date 	:= p_from.last_update_date;
    p_to.duration 		:= p_from.duration;
    p_to.operator 		:= p_from.operator;
    p_to.before_after 		:= p_from.before_after;
    p_to.last_update_login 	:= p_from.last_update_login;
    p_to.attribute_category 	:= p_from.attribute_category;
    p_to.attribute1 		:= p_from.attribute1;
    p_to.attribute2 		:= p_from.attribute2;
    p_to.attribute3 		:= p_from.attribute3;
    p_to.attribute4 		:= p_from.attribute4;
    p_to.attribute5 		:= p_from.attribute5;
    p_to.attribute6 		:= p_from.attribute6;
    p_to.attribute7 		:= p_from.attribute7;
    p_to.attribute8 		:= p_from.attribute8;
    p_to.attribute9 		:= p_from.attribute9;
    p_to.attribute10 		:= p_from.attribute10;
    p_to.attribute11 		:= p_from.attribute11;
    p_to.attribute12 		:= p_from.attribute12;
    p_to.attribute13 		:= p_from.attribute13;
    p_to.attribute14 		:= p_from.attribute14;
    p_to.attribute15 		:= p_from.attribute15;
    p_to.sfwt_flag 		:= p_from.sfwt_flag;
    p_to.description 		:= p_from.description;
    p_to.short_description 	:= p_from.short_description;
    p_to.comments 		:= p_from.comments;
  END migrate;
  ----------------------------------------------------------------------------
  --Proceudres for migrating to tgdv_rec_type
  ----------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from      IN tvev_rec_type,
    p_to        IN OUT NOCOPY tgdv_ext_rec_type
  ) IS
    CURSOR 	c_start_end(p_id IN NUMBER) IS
    SELECT 	start_date,end_date
    FROM 	okc_time_ia_startend_val_v
    WHERE 	id = p_id;
  BEGIN
    p_to.id 			:= p_from.id;
    p_to.tve_id_limited 	:= p_from.tve_id_limited;
    p_to.tze_id 		:= p_from.tze_id;
    p_to.dnz_chr_id 		:= p_from.dnz_chr_id;
    p_to.object_version_number 	:= p_from.object_version_number;
    p_to.created_by 		:= p_from.created_by;
    p_to.creation_date 		:= p_from.creation_date;
    p_to.last_updated_by 	:= p_from.last_updated_by;
    p_to.last_update_date 	:= p_from.last_update_date;
    p_to.month 			:= p_from.month;
    p_to.day 			:= p_from.day;
    p_to.hour 			:= p_from.hour;
    p_to.minute 		:= p_from.minute;
    p_to.second 		:= p_from.second;
    p_to.nth 			:= p_from.nth;
    p_to.day_of_week 		:= p_from.day_of_week;
    p_to.last_update_login 	:= p_from.last_update_login;
    p_to.attribute_category 	:= p_from.attribute_category;
    p_to.attribute1 		:= p_from.attribute1;
    p_to.attribute2 		:= p_from.attribute2;
    p_to.attribute3 		:= p_from.attribute3;
    p_to.attribute4 		:= p_from.attribute4;
    p_to.attribute5 		:= p_from.attribute5;
    p_to.attribute6 		:= p_from.attribute6;
    p_to.attribute7 		:= p_from.attribute7;
    p_to.attribute8 		:= p_from.attribute8;
    p_to.attribute9 		:= p_from.attribute9;
    p_to.attribute10 		:= p_from.attribute10;
    p_to.attribute11 		:= p_from.attribute11;
    p_to.attribute12 		:= p_from.attribute12;
    p_to.attribute13 		:= p_from.attribute13;
    p_to.attribute14 		:= p_from.attribute14;
    p_to.attribute15 		:= p_from.attribute15;
    p_to.sfwt_flag 		:= p_from.sfwt_flag;
    p_to.description 		:= p_from.description;
    p_to.short_description 	:= p_from.short_description;
    p_to.comments 		:= p_from.comments;
    IF p_from.tve_id_limited IS NULL OR p_from.tve_id_limited = OKC_API.G_MISS_NUM THEN
      p_to.limited_start_date := NULL;
      p_to.limited_end_date := NULL;
    ELSE
      OPEN c_start_end(p_from.tve_id_limited);
      FETCH c_start_end INTO p_to.limited_start_date,p_to.limited_end_date;
      CLOSE c_start_end;
    END IF;
  END migrate;

  ----------------------------------------------------------------------------
  --Proceudres for migrating to tgnv_rec_type
  ----------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from      IN tvev_rec_type,
    p_to        IN OUT NOCOPY tgnv_rec_type
  ) IS
  BEGIN
    p_to.id 			:= p_from.id;
    p_to.dnz_chr_id 		:= p_from.dnz_chr_id;
    p_to.tze_id 		:= p_from.tze_id;
    p_to.tve_id_limited 	:= p_from.tve_id_limited;
    p_to.object_version_number 	:= p_from.object_version_number;
    p_to.created_by 		:= p_from.created_by;
    p_to.creation_date 		:= p_from.creation_date;
    p_to.last_updated_by 	:= p_from.last_updated_by;
    p_to.last_update_date 	:= p_from.last_update_date;
    p_to.last_update_login 	:= p_from.last_update_login;
    p_to.attribute_category 	:= p_from.attribute_category;
    p_to.attribute1 		:= p_from.attribute1;
    p_to.attribute2 		:= p_from.attribute2;
    p_to.attribute3 		:= p_from.attribute3;
    p_to.attribute4 		:= p_from.attribute4;
    p_to.attribute5 		:= p_from.attribute5;
    p_to.attribute6 		:= p_from.attribute6;
    p_to.attribute7 		:= p_from.attribute7;
    p_to.attribute8 		:= p_from.attribute8;
    p_to.attribute9 		:= p_from.attribute9;
    p_to.attribute10 		:= p_from.attribute10;
    p_to.attribute11 		:= p_from.attribute11;
    p_to.attribute12 		:= p_from.attribute12;
    p_to.attribute13 		:= p_from.attribute13;
    p_to.attribute14 		:= p_from.attribute14;
    p_to.attribute15 		:= p_from.attribute15;
    p_to.sfwt_flag 		:= p_from.sfwt_flag;
    p_to.description 		:= p_from.description;
    p_to.short_description 	:= p_from.short_description;
    p_to.comments 		:= p_from.comments;
  END migrate;
  ----------------------------------------------------------------------------
  --Proceudres for migrating to igsv_rec_type
  ----------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from      IN tvev_rec_type,
    p_to        IN OUT NOCOPY igsv_ext_rec_type
  ) IS
    CURSOR 	c_igs(p_id IN NUMBER) IS
    SELECT 	START_MONTH,
		START_NTH,
		START_DAY_OF_WEEK,
		START_DAY,
		START_HOUR,
		START_MINUTE,
		START_SECOND,
		END_MONTH,
		END_NTH,
		END_DAY_OF_WEEK,
		END_DAY,
		END_HOUR,
		END_MINUTE,
		END_SECOND
    FROM 	okc_time_ig_startend_val_v
    WHERE 	id = p_id;

  BEGIN
    p_to.id 			:= p_from.id;
    p_to.tve_id_started 	:= p_from.tve_id_started;
    p_to.tve_id_ended 		:= p_from.tve_id_ended;
    p_to.tve_id_limited 	:= p_from.tve_id_limited;
    p_to.dnz_chr_id 		:= p_from.dnz_chr_id;
    p_to.tze_id 		:= p_from.tze_id;
    p_to.object_version_number 	:= p_from.object_version_number;
    p_to.created_by 		:= p_from.created_by;
    p_to.creation_date 		:= p_from.creation_date;
    p_to.last_updated_by 	:= p_from.last_updated_by;
    p_to.last_update_date 	:= p_from.last_update_date;
    p_to.last_update_login 	:= p_from.last_update_login;
    p_to.attribute_category 	:= p_from.attribute_category;
    p_to.attribute1 		:= p_from.attribute1;
    p_to.attribute2 		:= p_from.attribute2;
    p_to.attribute3 		:= p_from.attribute3;
    p_to.attribute4 		:= p_from.attribute4;
    p_to.attribute5 		:= p_from.attribute5;
    p_to.attribute6 		:= p_from.attribute6;
    p_to.attribute7 		:= p_from.attribute7;
    p_to.attribute8 		:= p_from.attribute8;
    p_to.attribute9 		:= p_from.attribute9;
    p_to.attribute10 		:= p_from.attribute10;
    p_to.attribute11 		:= p_from.attribute11;
    p_to.attribute12 		:= p_from.attribute12;
    p_to.attribute13 		:= p_from.attribute13;
    p_to.attribute14 		:= p_from.attribute14;
    p_to.attribute15 		:= p_from.attribute15;
    p_to.sfwt_flag 		:= p_from.sfwt_flag;
    p_to.description 		:= p_from.description;
    p_to.short_description 	:= p_from.short_description;
    p_to.comments 		:= p_from.comments;

    OPEN 	c_igs(p_from.id);
    FETCH 	c_igs
    INTO	p_to.START_MONTH,
		p_to.START_NTH,
		p_to.START_DAY_OF_WEEK,
		p_to.START_DAY,
		p_to.START_HOUR,
		p_to.START_MINUTE,
		p_to.START_SECOND,
		p_to.END_MONTH,
		p_to.END_NTH,
		p_to.END_DAY_OF_WEEK,
		p_to.END_DAY,
		p_to.END_HOUR,
		p_to.END_MINUTE,
		p_to.END_SECOND;
    CLOSE 	c_igs;
  END migrate;
  ----------------------------------------------------------------------------
  --Proceudres for migrating to cylv_rec_type
  ----------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from      IN tvev_rec_type,
    p_to        IN OUT NOCOPY cylv_ext_rec_type
  ) IS

    CURSOR 	c_start_end(p_id IN NUMBER) IS
    SELECT 	start_date,end_date
    FROM 	okc_time_ia_startend_val_v
    WHERE 	id = p_id;

    CURSOR 	c_cyl(p_id IN NUMBER) IS
    SELECT 	uom_code,duration,active_yn
    FROM 	okc_time_cycle_span_v
    WHERE 	id = p_id;


  BEGIN
    p_to.id 			:= p_from.id;
    p_to.spn_id 		:= p_from.spn_id;
    p_to.tve_id_limited 	:= p_from.tve_id_limited;
    p_to.dnz_chr_id 		:= p_from.dnz_chr_id;
    p_to.tze_id 		:= p_from.tze_id;
    p_to.object_version_number 	:= p_from.object_version_number;
    p_to.created_by 		:= p_from.created_by;
    p_to.creation_date 		:= p_from.creation_date;
    p_to.last_updated_by 	:= p_from.last_updated_by;
    p_to.last_update_date 	:= p_from.last_update_date;
    p_to.interval_yn 		:= p_from.interval_yn;
    p_to.last_update_login 	:= p_from.last_update_login;
    p_to.attribute_category 	:= p_from.attribute_category;
    p_to.attribute1 		:= p_from.attribute1;
    p_to.attribute2 		:= p_from.attribute2;
    p_to.attribute3 		:= p_from.attribute3;
    p_to.attribute4 		:= p_from.attribute4;
    p_to.attribute5 		:= p_from.attribute5;
    p_to.attribute6 		:= p_from.attribute6;
    p_to.attribute7 		:= p_from.attribute7;
    p_to.attribute8 		:= p_from.attribute8;
    p_to.attribute9 		:= p_from.attribute9;
    p_to.attribute10 		:= p_from.attribute10;
    p_to.attribute11 		:= p_from.attribute11;
    p_to.attribute12 		:= p_from.attribute12;
    p_to.attribute13 		:= p_from.attribute13;
    p_to.attribute14 		:= p_from.attribute14;
    p_to.attribute15 		:= p_from.attribute15;
    p_to.sfwt_flag 		:= p_from.sfwt_flag;
    p_to.description 		:= p_from.description;
    p_to.short_description 	:= p_from.short_description;
    p_to.comments 		:= p_from.comments;
    p_to.name 			:= p_from.name;

    OPEN c_cyl(p_from.id);
    FETCH c_cyl INTO p_to.uom_code,p_to.duration,p_to.active_yn;
    CLOSE c_cyl;

    IF p_from.tve_id_limited IS NULL OR p_from.tve_id_limited = OKC_API.G_MISS_NUM THEN
      p_to.limited_start_date := NULL;
      p_to.limited_end_date := NULL;
    ELSE
      OPEN c_start_end(p_from.tve_id_limited);
      FETCH c_start_end INTO p_to.limited_start_date,p_to.limited_end_date;
      CLOSE c_start_end;
    END IF;
  END migrate;

  ----------------------------------------------------------------------------
  --Proceudres for migrating different type of time values view record type. Ends.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  --Proceudre copy_timevalues - Makes a copy of the timevalues.
  ----------------------------------------------------------------------------
  PROCEDURE copy_timevalues(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tve_id                  	   IN NUMBER,
    p_to_chr_id                    IN NUMBER ,
    p_to_template_yn			   IN VARCHAR2,
    x_tve_id		           OUT NOCOPY NUMBER) IS

    l_tvev_rec			tvev_rec_type;
    l_tavv_rec			tavv_rec_type;
    x_tavv_rec			tavv_rec_type;
    l_talv_evt_rec		talv_evt_rec_type;
    x_talv_evt_rec		talv_evt_rec_type;
    l_tgdv_ext_rec		tgdv_ext_rec_type;
    x_tgdv_ext_rec		tgdv_ext_rec_type;
    l_tgnv_rec			tgnv_rec_type;
    x_tgnv_rec			tgnv_rec_type;
    l_igsv_ext_rec		igsv_ext_rec_type;
    x_igsv_ext_rec		igsv_ext_rec_type;
    l_cylv_ext_rec		cylv_ext_rec_type;
    x_cylv_ext_rec		cylv_ext_rec_type;
    l_isev_rel_rec		isev_rel_rec_type;
    x_isev_rel_rec		isev_rel_rec_type;
    l_isev_ext_rec		isev_ext_rec_type;
    x_isev_ext_rec		isev_ext_rec_type;
    l_tve_type 		VARCHAR2(10);
    l_return_status	        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cnh_id_out 		NUMBER;
    l_cnh_id_temp 		NUMBER;
    l_dnz_chr_id         NUMBER;
    l_template_yn        VARCHAR2(3);

    CURSOR 	c_tpa_rel(p_id IN NUMBER) IS
    SELECT 	tve_type,cnh_id
    FROM 	okc_timevalues
    WHERE 	id = p_id;

    CURSOR 	c_cnh(p_id IN NUMBER) IS
    SELECT 	dnz_chr_id,
               template_yn
    FROM 	     okc_condition_headers_b
    WHERE 	id = p_id;

    CURSOR  c_isev_rel(p_id IN NUMBER)  IS
    SELECT  START_PARENT_DATE,
            END_DATE,
            ID,
            TZE_ID,
            START_UOM_CODE,
            START_DURATION,
            START_TVE_ID_OFFSET,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            TVE_ID_STARTED,
            TVE_ID_ENDED,
            TVE_ID_LIMITED,
            DNZ_CHR_ID,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            OPERATOR,
            DURATION,
            UOM_CODE,
            BEFORE_AFTER,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
     FROM   OKC_TIME_IA_STARTEND_REL_V
	WHERE  ID = p_id;

     CURSOR c_isev_ext(p_id IN NUMBER)  IS
     SELECT START_DATE,
            END_DATE,
            ID,
            OBJECT_VERSION_NUMBER,
            TZE_ID,
            SFWT_FLAG,
            TVE_ID_STARTED,
            TVE_ID_ENDED,
            TVE_ID_LIMITED,
            DNZ_CHR_ID,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            COMMENTS,
            OPERATOR,
            DURATION,
            UOM_CODE,
            BEFORE_AFTER,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15
    FROM    OKC_TIME_IA_STARTEND_VAL_V
    WHERE   ID = p_id;

  BEGIN
    l_return_status := get_tvev_rec(	p_tve_id 	=> p_tve_id,
					x_tvev_rec 	=> l_tvev_rec);
    IF l_tvev_rec.tve_type = 'TAV' THEN
      migrate(l_tvev_rec,l_tavv_rec);
      l_tavv_rec.dnz_chr_id := p_to_chr_id;
      OKC_TIME_PUB.create_tpa_value(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_tavv_rec		=> l_tavv_rec,
           x_tavv_rec		=> x_tavv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_tve_id := x_tavv_rec.id;

    ELSIF l_tvev_rec.tve_type = 'TAL' THEN
      OPEN c_tpa_rel(l_tvev_rec.tve_id_offset);
      FETCH c_tpa_rel INTO l_tve_type,l_cnh_id_temp;
      IF c_tpa_rel%FOUND THEN
        IF l_tve_type = 'TGN' THEN

          migrate(l_tvev_rec,l_talv_evt_rec);
          l_talv_evt_rec.dnz_chr_id := p_to_chr_id;

          OPEN c_cnh(l_cnh_id_temp);
		FETCH c_cnh INTO l_dnz_chr_id,l_template_yn;
          CLOSE c_cnh;
          IF (l_dnz_chr_id IS NOT NULL OR l_template_yn = 'Y') THEN
            copy_events (
      	      p_api_version	     => p_api_version,
                p_init_msg_list	=> p_init_msg_list,
                x_return_status 	=> l_return_status,
                x_msg_count     	=> x_msg_count,
                x_msg_data      	=> x_msg_data,
                p_cnh_id		     => l_cnh_id_temp,
                p_chr_id		     => p_to_chr_id,
                p_to_template_yn   => p_to_template_yn,
                x_cnh_id		     => l_cnh_id_out);

               IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 x_return_status := l_return_status;
                 RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;

               l_talv_evt_rec.cnh_id := l_cnh_id_out; -- the new event id generated is assigned to the time value
          ELSE
            l_talv_evt_rec.cnh_id := l_cnh_id_temp;
          END IF;

          OKC_TIME_PUB.create_tpa_reltv(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_talv_evt_rec	=> l_talv_evt_rec,
           x_talv_evt_rec	=> x_talv_evt_rec);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          x_tve_id := x_talv_evt_rec.id;

        END IF;
      END IF;
      CLOSE c_tpa_rel;
    ELSIF l_tvev_rec.tve_type = 'TGD' THEN
      migrate(l_tvev_rec,l_tgdv_ext_rec);
      l_tgdv_ext_rec.dnz_chr_id := p_to_chr_id;
      OKC_TIME_PUB.create_tpg_delimited(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_tgdv_ext_rec	=> l_tgdv_ext_rec,
           x_tgdv_ext_rec	=> x_tgdv_ext_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_tve_id := x_tgdv_ext_rec.id;

    ELSIF l_tvev_rec.tve_type = 'TGN' THEN
      migrate(l_tvev_rec,l_tgnv_rec);
      l_tgnv_rec.dnz_chr_id := p_to_chr_id;

      OPEN c_cnh(l_tvev_rec.cnh_id);
      FETCH c_cnh INTO l_dnz_chr_id,l_template_yn;
      CLOSE c_cnh;
      IF (l_dnz_chr_id IS NOT NULL OR l_template_yn = 'Y')  THEN
        copy_events (
	     p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cnh_id		=> l_tvev_rec.cnh_id,
           p_chr_id		=> p_to_chr_id,
           p_to_template_yn   => p_to_template_yn,
           x_cnh_id		=> l_cnh_id_out);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        l_tgnv_rec.cnh_id := l_cnh_id_out; -- the new event id generated is assigned to the time value
      ELSE
        l_talv_evt_rec.cnh_id := l_tvev_rec.cnh_id;
      END IF;

      OKC_TIME_PUB.create_tpg_named(
	      p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_tgnv_rec		=> l_tgnv_rec,
           x_tgnv_rec		=> x_tgnv_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_tve_id := x_tgnv_rec.id;

    ELSIF l_tvev_rec.tve_type = 'ISE' THEN

      OPEN c_isev_ext(l_tvev_rec.id);
	 FETCH c_isev_ext INTO
            l_isev_ext_rec.START_DATE,
            l_isev_ext_rec.END_DATE,
            l_isev_ext_rec.ID,
            l_isev_ext_rec.OBJECT_VERSION_NUMBER,
            l_isev_ext_rec.TZE_ID,
            l_isev_ext_rec.SFWT_FLAG,
            l_isev_ext_rec.TVE_ID_STARTED,
            l_isev_ext_rec.TVE_ID_ENDED,
            l_isev_ext_rec.TVE_ID_LIMITED,
            l_isev_ext_rec.DNZ_CHR_ID,
            l_isev_ext_rec.DESCRIPTION,
            l_isev_ext_rec.SHORT_DESCRIPTION,
            l_isev_ext_rec.COMMENTS,
            l_isev_ext_rec.OPERATOR,
            l_isev_ext_rec.DURATION,
            l_isev_ext_rec.UOM_CODE,
            l_isev_ext_rec.BEFORE_AFTER,
            l_isev_ext_rec.ATTRIBUTE_CATEGORY,
            l_isev_ext_rec.ATTRIBUTE1,
            l_isev_ext_rec.ATTRIBUTE2,
            l_isev_ext_rec.ATTRIBUTE3,
            l_isev_ext_rec.ATTRIBUTE4,
            l_isev_ext_rec.ATTRIBUTE5,
            l_isev_ext_rec.ATTRIBUTE6,
            l_isev_ext_rec.ATTRIBUTE7,
            l_isev_ext_rec.ATTRIBUTE8,
            l_isev_ext_rec.ATTRIBUTE9,
            l_isev_ext_rec.ATTRIBUTE10,
            l_isev_ext_rec.ATTRIBUTE11,
            l_isev_ext_rec.ATTRIBUTE12,
            l_isev_ext_rec.ATTRIBUTE13,
            l_isev_ext_rec.ATTRIBUTE14,
            l_isev_ext_rec.ATTRIBUTE15;

      l_isev_ext_rec.dnz_chr_id := p_to_chr_id;

      IF NOT c_isev_ext%NOTFOUND THEN

        OKC_TIME_PUB.create_ia_startend(
	      p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_isev_ext_rec	=> l_isev_ext_rec,
           x_isev_ext_rec	=> x_isev_ext_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        x_tve_id := x_isev_ext_rec.id;
      END IF;

      IF c_isev_ext%NOTFOUND THEN
	   OPEN c_isev_rel(l_tvev_rec.id);
	   FETCH c_isev_rel INTO
            l_isev_rel_rec.START_PARENT_DATE,
            l_isev_rel_rec.END_DATE,
            l_isev_rel_rec.ID,
            l_isev_rel_rec.TZE_ID,
            l_isev_rel_rec.START_UOM_CODE,
            l_isev_rel_rec.START_DURATION,
            l_isev_rel_rec.START_TVE_ID_OFFSET,
            l_isev_rel_rec.OBJECT_VERSION_NUMBER,
            l_isev_rel_rec.SFWT_FLAG,
            l_isev_rel_rec.TVE_ID_STARTED,
            l_isev_rel_rec.TVE_ID_ENDED,
            l_isev_rel_rec.TVE_ID_LIMITED,
            l_isev_rel_rec.DNZ_CHR_ID,
            l_isev_rel_rec.DESCRIPTION,
            l_isev_rel_rec.SHORT_DESCRIPTION,
            l_isev_rel_rec.COMMENTS,
            l_isev_rel_rec.OPERATOR,
            l_isev_rel_rec.DURATION,
            l_isev_rel_rec.UOM_CODE,
            l_isev_rel_rec.BEFORE_AFTER,
            l_isev_rel_rec.ATTRIBUTE_CATEGORY,
            l_isev_rel_rec.ATTRIBUTE1,
            l_isev_rel_rec.ATTRIBUTE2,
            l_isev_rel_rec.ATTRIBUTE3,
            l_isev_rel_rec.ATTRIBUTE4,
            l_isev_rel_rec.ATTRIBUTE5,
            l_isev_rel_rec.ATTRIBUTE6,
            l_isev_rel_rec.ATTRIBUTE7,
            l_isev_rel_rec.ATTRIBUTE8,
            l_isev_rel_rec.ATTRIBUTE9,
            l_isev_rel_rec.ATTRIBUTE10,
            l_isev_rel_rec.ATTRIBUTE11,
            l_isev_rel_rec.ATTRIBUTE12,
            l_isev_rel_rec.ATTRIBUTE13,
            l_isev_rel_rec.ATTRIBUTE14,
            l_isev_rel_rec.ATTRIBUTE15;

        l_isev_rel_rec.dnz_chr_id := p_to_chr_id;

        OKC_TIME_PUB.create_ia_startend(
	      p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_isev_rel_rec	=> l_isev_rel_rec,
           x_isev_rel_rec	=> x_isev_rel_rec);

        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        x_tve_id := x_isev_rel_rec.id;

	   CLOSE c_isev_rel;
	 END IF;
	 CLOSE c_isev_ext;
    ELSIF l_tvev_rec.tve_type = 'IGS' THEN
      migrate(l_tvev_rec,l_igsv_ext_rec);
      l_igsv_ext_rec.dnz_chr_id := p_to_chr_id;
      OKC_TIME_PUB.create_ig_startend(
	      p_api_version  	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_igsv_ext_rec	=> l_igsv_ext_rec,
           x_igsv_ext_rec	=> x_igsv_ext_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_tve_id := x_igsv_ext_rec.id;

    ELSIF l_tvev_rec.tve_type = 'CYL' THEN
      migrate(l_tvev_rec,l_cylv_ext_rec);
      l_cylv_ext_rec.dnz_chr_id := p_to_chr_id;
      OKC_TIME_PUB.create_cycle(
	      p_api_version	     => p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> l_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_cylv_ext_rec	=> l_cylv_ext_rec,
           x_cylv_ext_rec	=> x_cylv_ext_rec);

      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      x_tve_id := x_cylv_ext_rec.id;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_timevalues;

 PROCEDURE copy_components(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id                  IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			IN VARCHAR2 ,
    p_copy_reference			IN VARCHAR2 ,
    p_copy_line_party_yn           IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_components_tbl			IN api_components_tbl,
    p_lines_tbl				IN api_lines_tbl,
    x_chr_id                    OUT NOCOPY NUMBER,
    p_concurrent_request           IN VARCHAR2 DEFAULT 'N',
    p_include_cancelled_lines  IN VARCHAR2 DEFAULT 'Y',
    p_include_terminated_lines IN VARCHAR2 DEFAULT 'Y') IS
    --Bug 2950549 added new parameter p_concurrent_request

    l_components_tbl  api_components_tbl := p_components_tbl;
    l_lines_tbl       api_lines_tbl := p_lines_tbl;
    l_published_line_ids_tbl  OKS_COPY_CONTRACT_PVT.published_line_ids_tbl;

    l_return_status	  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_old_return_status	  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cle_id_out      NUMBER;
    l_chr_id          NUMBER;
    l_cnh_id          NUMBER;
    l_rgp_id          NUMBER;
    l_cat_id          NUMBER;
    l_cpl_id          NUMBER;
    l_from_cle_id     NUMBER;
    l_to_cle_id       NUMBER;
    l_to_chr_id       NUMBER;
    i                 NUMBER := 0;
    j                 NUMBER := 0;
    l_old_lse_id      NUMBER;
    l_copy_sublines   VARCHAR2(1) := 'F';
    l_generate_line_number   VARCHAR2(1) := 'Y'; --Bug 2489856
    l_result		  BOOLEAN;
    --Bug:3668722
    l_cle_id_out20    NUMBER := OKC_API.G_MISS_NUM;
    l_cle_id_out21    NUMBER := OKC_API.G_MISS_NUM;
    l_c_lines_id			 NUMBER := OKC_API.G_MISS_NUM;
    l_c_lines_dnz_chr_id		 NUMBER := OKC_API.G_MISS_NUM;


    --11510
    l_source_doc_type VARCHAR2(60);
    l_source_doc_ID   NUMBER;
    l_target_doc_type VARCHAR2(60);
    l_target_doc_ID   NUMBER;
    l_keep_version VARCHAR2(1);
    l_eff_date DATE;
    l_category          VARCHAR2(200); --added for bug 3764231

    -- 11510 get chr start date for effective date for copy_doc
    CURSOR c_art_eff_date (p_doc_type VARCHAR2,p_doc_id NUMBER) IS
    SELECT article_effective_date
     FROM okc_template_usages_v
     WHERE document_type=p_doc_type AND document_id=p_doc_id;

   --cursor to fetch id of line with lseid =20 -Bug:3668722
   CURSOR	c_lines(p NUMBER) IS
    SELECT id,
           dnz_chr_id
    FROM   okc_k_lines_b
    where lse_id=20
    CONNECT BY  PRIOR id = cle_id
    START WITH  id =p;

-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 1917514
    CURSOR c_pdf IS
    SELECT pdf_id
    FROM okc_class_operations
    WHERE opn_code = 'COPY'
    AND   cls_code = 'SERVICE';

    l_pdf_id  NUMBER;
    l_cle_id  NUMBER := OKC_API.G_MISS_NUM; -- Bugfix 2151523(1917514) - Initializing
    --l_chr_id  NUMBER;
    l_string VARCHAR2(32000);
    proc_string VARCHAR2(32000);
-- Cursor created to get the PDF_ID for Class 'SERVICE' - Bug 1917514

    CURSOR c_old_lse_id (p_id IN NUMBER) IS
    SELECT lse_id
    FROM   OKC_K_LINES_b
    WHERE  id = p_id;

    -- Added for Bug 3764231
    -- cursor to get the contract category

    CURSOR l_Service_Contract_csr IS
    SELECT osb.cls_code
    FROM  okc_subclasses_b osb,okc_k_headers_b okb
    WHERE okb.id = p_from_chr_id
    AND   okb.scs_code = osb.code ;

    -- Added for Bug 3764231

    TYPE 	new_cle_id_rec IS RECORD(id             NUMBER,
                                   new_id           NUMBER);
    TYPE	new_cle_id_tbl IS TABLE OF new_cle_id_rec
    INDEX	BY BINARY_INTEGER;

    l_new_cle_id_tbl  new_cle_id_tbl;

    l_module_name VARCHAR2(30) := 'COPY_COMPONENTS';
    PROCEDURE add_new_cle_id(p_id   IN NUMBER,
					  p_new_id IN NUMBER) IS
      i NUMBER := 0;
    BEGIN
	 IF l_new_cle_id_tbl.COUNT > 0 THEN
	   i := l_new_cle_id_tbl.LAST;
	 END IF;
	 l_new_cle_id_tbl(i+1).id := p_id;
      l_new_cle_id_tbl(i+1).new_id := p_new_id;
    END add_new_cle_id;

    PROCEDURE get_new_cle_id(p_id   IN NUMBER,
					  p_new_id OUT NOCOPY NUMBER) IS
      i NUMBER := 0;
    BEGIN
	 IF l_new_cle_id_tbl.COUNT > 0 THEN
	   i := l_new_cle_id_tbl.FIRST;
	   LOOP
		IF l_new_cle_id_tbl(i).id = p_id THEN
		  p_new_id := l_new_cle_id_tbl(i).new_id;
		  EXIT;
		END IF;
		EXIT WHEN i = l_new_cle_id_tbl.LAST;
		i := l_new_cle_id_tbl.NEXT(i);
	   END LOOP;
	 END IF;
    END get_new_cle_id;

  BEGIN
/*********************************************************************************
-- Following code is commented out for Bug#2855853.

IF (l_debug = 'Y') THEN
   OKC_DEBUG.Set_Indentation(' copy_components ');
   OKC_DEBUG.log('100 : Entering  OKC_COPY_CONTRACT_PVT.copy_components  ', 2);
   OKC_DEBUG.log('l_components_tbl.COUNT : '||l_components_tbl.COUNT,2);
   For i IN NVL(l_components_tbl.FIRST,0)..NVL(l_components_tbl.LAST,-1)
   LOOP
      OKC_DEBUG.log('Component : '||i,2);
      OKC_DEBUG.log('l_components_tbl(i).component_type : '||l_components_tbl(i).component_type,2);
      OKC_DEBUG.log('l_components_tbl(i).attribute1 : '||l_components_tbl(i).attribute1,2);
      OKC_DEBUG.log('l_components_tbl(i).id : '||l_components_tbl(i).id,2);
      OKC_DEBUG.log('l_components_tbl(i).to_k : '||l_components_tbl(i).to_k,2);
   END LOOP;
END IF;
********************************************************************************/
--added for bug 2950549
 fnd_msg_pub.initialize;
 IF p_concurrent_request = 'Y' then

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_module_name
                        ,'Before call to Add_Concurrent'
                       ||'p_from_chr_id='||p_from_chr_id
		       ||'p_contract_number='||p_contract_number);
    END IF;

	   add_concurrent(p_components_tbl,
		             p_lines_tbl,
				   p_from_chr_id,
				   p_to_chr_id,
				   p_contract_number,
				   p_contract_number_modifier,
				   p_to_template_yn,
				   p_copy_reference,
				   p_copy_line_party_yn,
				   p_scs_code,
				   p_intent,
				   p_prospect,
				   p_include_cancelled_lines => p_include_cancelled_lines,
				   p_include_terminated_lines => p_include_terminated_lines);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_module_name
                        ,'After call to Add_Concurrent'
                       ||'p_from_chr_id='||p_from_chr_id
                       ||'p_contract_number='||p_contract_number);
    END IF;
 ELSE
-- hkamdar R12 Copy Enhancements
-- Commenting entire else part and including this code into OKS_COPY_CONTRACT_PVT.COPY_COMPONENTS API
/*        ---Initialisation is not to read records from History Tables
        G_COPY_HISTORY_YN := 'N';

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('200 : Calling OKC_COPY_CONTRACT_PUB.IS_COPY_ALLOWED');
END IF;
	l_result := OKC_COPY_CONTRACT_PUB.IS_COPY_ALLOWED(p_from_chr_id, NULL);
	If NOT l_result Then
	  -- notify caller of an UNEXPECTED error
	  x_return_status := OKC_API.G_RET_STS_ERROR;
	  raise G_EXCEPTION_HALT_VALIDATION;
	End If;

    -- Intitialize globals.
    IF g_events.COUNT > 0 THEN
       g_events.DELETE;
    END IF;

    IF g_ruls.COUNT > 0 THEN
       g_ruls.DELETE;
    END IF;

    IF g_sections.COUNT > 0 THEN
       g_sections.DELETE;
    END IF;

    IF g_timevalues.COUNT > 0 THEN
       g_timevalues.DELETE;
    END IF;

    IF g_party.COUNT > 0 THEN
       g_party.DELETE;
    END IF;

    x_return_status := l_return_status;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('250 : x_return_status : '||x_return_status);
   OKC_DEBUG.log('250 : p_to_chr_id : '||p_to_chr_id);
END IF;

    IF p_to_chr_id IS NULL THEN
      copy_contract_header(
	   	 p_api_version				=> p_api_version,
           p_init_msg_list			=> p_init_msg_list,
           x_return_status 			=> l_return_status,
           x_msg_count     			=> x_msg_count,
           x_msg_data      			=> x_msg_data,
           p_from_chr_id				=> p_from_chr_id,
           p_contract_number			=> p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
           p_scs_code                   => p_scs_code,
           p_intent                     => p_intent,
           p_prospect                   => p_prospect,
           p_called_from                => 'C',
	      p_to_template_yn             => p_to_template_yn,
		 p_renew_ref_yn               => 'N',
           x_chr_id					=> l_chr_id);

               l_oks_copy := 'N';      -- Bugfix 1917514
               -- Setting l_oks_copy to 'N' so that this procedure should not be called from
               -- Copy Line if it is already called from Copy Header
      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      l_return_status := get_chrv_rec(p_to_chr_id,g_chrv_rec);
	    l_chr_id := p_to_chr_id;
    END IF;

    x_chr_id := l_chr_id;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('300 : After copy_contract_header  ');
   OKC_DEBUG.log('300 : x_chr_id : '||x_chr_id);
   OKC_DEBUG.log('300 : x_return_status : '||l_return_status);
END IF;

    IF l_components_tbl.COUNT >0 THEN
      i := l_components_tbl.FIRST;
      LOOP
	   -- IF l_components_tbl(i).component_type = 'Events' THEN
           -- skekkar bug 2802203 ( base bug 2794662 )
	   IF l_components_tbl(i).component_type = 'EVENTS' THEN
          l_old_return_status := l_return_status;
          copy_events (
	          p_api_version	     => p_api_version,
               p_init_msg_list	=> p_init_msg_list,
               x_return_status 	=> l_return_status,
               x_msg_count     	=> x_msg_count,
               x_msg_data      	=> x_msg_data,
               p_cnh_id		     => l_components_tbl(i).id,
               p_chr_id		     => l_chr_id,
               p_to_template_yn   => p_to_template_yn,
               x_cnh_id		     => l_cnh_id);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                x_return_status := l_return_status;
              END IF;
            END IF;
          END IF;

        END IF;
        EXIT WHEN i = l_components_tbl.LAST;
        i := l_components_tbl.NEXT(i);
      END LOOP;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('350 : After copy_events  ');
   OKC_DEBUG.log('350 : x_return_status : '||l_return_status);
END IF;

      i := l_components_tbl.FIRST;
      LOOP
        -- IF l_components_tbl(i).component_type = 'Parties' THEN
        -- skekkar bug 2802203 ( base bug 2794662 )
        IF l_components_tbl(i).component_type = 'PARTIES' THEN
          l_old_return_status := l_return_status;
          copy_party_roles (
	       p_api_version	=> p_api_version,
               p_init_msg_list	=> p_init_msg_list,
               x_return_status 	=> l_return_status,
               x_msg_count     	=> x_msg_count,
               x_msg_data      	=> x_msg_data,
               p_cpl_id		=> l_components_tbl(i).id,
               p_cle_id	     	=> NULL,
               p_chr_id	     	=> l_chr_id,
               p_rle_code       => l_components_tbl(i).attribute1,
               x_cpl_id	     	=> l_cpl_id);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                x_return_status := l_return_status;
              END IF;
            END IF;
          END IF;

        END IF;
        EXIT WHEN i = l_components_tbl.LAST;
        i := l_components_tbl.NEXT(i);
      END LOOP;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('400 : After copy_party_roles  ');
   OKC_DEBUG.log('400 : x_return_status : '||l_return_status);
END IF;

    --
    -- Bug 3611000
    -- Rules may exist for pre-11.5.10 contracts - they should not be tried to copy in 11.5.10 onwards for service contracts
    --
    IF G_APPLICATION_ID <> 515 THEN

      i := l_components_tbl.FIRST;
      LOOP
        -- IF l_components_tbl(i).component_type = 'Rules' THEN
        -- skekkar bug 2802203 ( base bug 2794662 )
        IF l_components_tbl(i).component_type = 'RULES' THEN
          l_old_return_status := l_return_status;
          copy_rules (
	          p_api_version	     => p_api_version,
               p_init_msg_list	=> p_init_msg_list,
               x_return_status 	=> l_return_status,
               x_msg_count     	=> x_msg_count,
               x_msg_data      	=> x_msg_data,
               p_rgp_id		     => l_components_tbl(i).id,
               p_cle_id		     => NULL,
               p_chr_id		     => l_chr_id,
		     p_to_template_yn    => p_to_template_yn,
               x_rgp_id		     => l_rgp_id);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
              IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                x_return_status := l_return_status;
              END IF;
            END IF;
          END IF;

	   END IF;
	   EXIT WHEN i = l_components_tbl.LAST;
	   i := l_components_tbl.NEXT(i);
      END LOOP;

      IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('450 : After copy_rules  ');
         OKC_DEBUG.log('450 : x_return_status : '||l_return_status);
      END IF;
    END IF; --G_APPLICATION_ID <> 515
*/
/* 11510
      i := l_components_tbl.FIRST;
      LOOP
        l_old_return_status := l_return_status;
	-- IF l_components_tbl(i).component_type = 'Articles' THEN
        -- skekkar bug 2802203 ( base bug 2794662 )
	IF l_components_tbl(i).component_type = 'ARTICLES' THEN
          copy_articles (
	          p_api_version	     => p_api_version,
               p_init_msg_list	=> p_init_msg_list,
               x_return_status 	=> l_return_status,
               x_msg_count     	=> x_msg_count,
               x_msg_data      	=> x_msg_data,
               p_cat_id		     => l_components_tbl(i).id,
               p_cle_id		     => NULL,
               p_chr_id		     => l_chr_id,
               x_cat_id		     => l_cat_id);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_old_return_status := l_return_status;
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
	         x_return_status := l_return_status;
            END IF;
          END IF;
	   END IF;
	   EXIT WHEN i = l_components_tbl.LAST;
	   i := l_components_tbl.NEXT(i);
      END LOOP;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('500 : After copy_articles  ');
   OKC_DEBUG.log('500 : x_return_status : '||l_return_status);
END IF;
*/
/*
    -- new 11510 code
      i := l_components_tbl.FIRST;
      l_old_return_status := l_return_status;
      LOOP
	IF l_components_tbl(i).component_type = 'ARTICLES' THEN
-- temporary: copy all document articles after one article component to copy found
    l_keep_version := 'Y'; -- keep version as was doing before
     OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_ID(
        p_api_version   => p_api_version,
        x_return_status => l_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_chr_id        => p_from_chr_id,
        x_doc_type      => l_source_doc_type,
        x_doc_id        => l_source_doc_id
    );
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : Get_Contract_Document_Type for source chr_id ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
     OKC_TERMS_UTIL_GRP.Get_Contract_Document_Type_ID(
        p_api_version   => p_api_version,
        x_return_status => l_return_status,
        x_msg_data      => x_msg_data,
        x_msg_count     => x_msg_count,
        p_chr_id        => x_chr_id,
        x_doc_type      => l_target_doc_type,
        x_doc_id        => l_target_doc_id
    );

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : Get_Contract_Document_Type for target chr_id ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;
    OPEN c_art_eff_date(l_source_doc_type, l_source_doc_id);
    FETCH c_art_eff_date INTO l_eff_date;
    CLOSE c_art_eff_date;


    OKC_TERMS_COPY_GRP.copy_doc(
        p_api_version	     => p_api_version,
        x_return_status	     => l_return_status,
        x_msg_count    	     => x_msg_count,
        x_msg_data     	     => x_msg_data,

        p_source_doc_type    => l_source_doc_type,
        p_source_doc_id      => l_source_doc_id,
        p_target_doc_type    => l_target_doc_type,
        p_target_doc_id      => l_target_doc_id,
        p_keep_version       => l_keep_version,
        p_article_effective_date => Nvl(l_eff_date,Sysdate),
        p_document_number    => p_contract_number,
        p_allow_duplicate_terms=>'Y'
    );
IF (l_debug = 'Y') THEN
   OKC_DEBUG.log(' After Procedure : OKC_TERMS_COPY_GRP.copy_doc ' || l_return_status);
END IF;
        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
          ELSE
            IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
              x_return_status := l_return_status;
            END IF;
          END IF;
        END IF;

       EXIT; -- exit after one article component to copy found
      ELSE
       EXIT WHEN i = l_components_tbl.LAST;
  	   i := l_components_tbl.NEXT(i);
	   END IF;
    END LOOP;
-- end of new 11510 code
    END IF;

    -- Call to the procedure to copy all other remaining sections
--11510    copy_other_sections(p_from_chr_id, l_chr_id);


    IF l_lines_tbl.COUNT >0 THEN
	 j := l_lines_tbl.FIRST;
 	 LOOP
	   IF l_lines_tbl(j).to_line IS NULL THEN
          l_from_cle_id := l_lines_tbl(j).id;
          l_to_cle_id   := NULL;
          l_to_chr_id   := l_chr_id;
	     IF l_lines_tbl(j).lse_id = 1 THEN
             -- this logic is to find the service line came from a service line or a core line.
             -- If it came from a service line all sublines need to be identified and copied.
            OPEN c_old_lse_Id(l_lines_tbl(j).id);
            FEtCH c_old_lse_Id INTO l_old_lse_id;
            CLOSE c_old_lse_Id;
            IF l_old_lse_id = 1 THEN
              l_copy_sublines := 'T';
            ELSE
              l_copy_sublines := 'F';
            END IF;
          END IF;
--mmadhavi added following code for bug 3990643
	  IF l_lines_tbl(j).lse_id = 19 THEN
            OPEN c_old_lse_Id(l_lines_tbl(j).id);
            FEtCH c_old_lse_Id INTO l_old_lse_id;
            CLOSE c_old_lse_Id;
            IF l_old_lse_id = 19 then
	      if l_lines_tbl(j).line_exp_yn = 'Y' THEN
		l_copy_sublines := 'T';
	      ELSE
                l_copy_sublines := 'F';
	      End if;
            END IF;
          END IF;
--mmadhavi

-- Bug 2489856
          if p_to_chr_id IS NULL Then -- New Contract Preserve line no during copy
               l_generate_line_number := 'N';
             else
               l_generate_line_number := 'Y';
             end if;
-- End Bug 2489856

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('600 : Before copy_contract_line  ');
   OKC_DEBUG.log('600 : l_copy_sublines : '||l_copy_sublines);
END IF;

          IF l_copy_sublines = 'F' THEN
            copy_contract_line(
               p_api_version	      => p_api_version,
               p_init_msg_list      => p_init_msg_list,
               x_return_status      => l_return_status,
               x_msg_count          => x_msg_count,
               x_msg_data           => x_msg_data,
               p_from_cle_id	      => l_from_cle_id,
               p_from_chr_id		 => p_from_chr_id,
               p_to_cle_id          => l_to_cle_id,
               p_to_chr_id          => l_to_chr_id,
	          p_lse_id             => l_lines_tbl(j).lse_id,
               p_to_template_yn     => p_to_template_yn,
               p_copy_reference     =>p_copy_reference,
               p_copy_line_party_yn => p_copy_line_party_yn,
               p_renew_ref_yn       => 'N',
               p_generate_line_number => l_generate_line_number, --Bug 2489856
               x_cle_id		      => l_cle_id_out);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('650 : After copy_contract_line  ');
   OKC_DEBUG.log('650 : x_return_status : '||l_return_status);
   OKC_DEBUG.log('650 : x_msg_count : '||x_msg_count);
   OKC_DEBUG.log('650 : x_msg_data : '||x_msg_data);
END IF;
            -- If any error happens it exits the loop or if it is a warning it still continues.
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
                IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                  x_return_status := OKC_API.G_RET_STS_WARNING;
                END IF;
              ELSE
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;
            END IF;
            --Bug:3668722 copy coverage line(lse=20) for Ext Warratny line(lse=19)
           IF(l_lines_tbl(j).lse_id=19 ) then
             OPEN c_lines(l_from_cle_id);
                FETCH c_lines INTO l_c_lines_id,l_c_lines_dnz_chr_id;
             CLOSE c_lines;
            IF(l_c_lines_id <> OKC_API.G_MISS_NUM) THEN
              copy_contract_line (
	       p_api_version    => p_api_version,
               p_init_msg_list	=> p_init_msg_list,
               x_return_status 	=> l_return_status,
               x_msg_count     	=> x_msg_count,
               x_msg_data      	=> x_msg_data,
               p_from_cle_id    => l_c_lines_id,
               p_from_chr_id	=> l_c_lines_dnz_chr_id,
	       p_to_cle_id 		=> l_cle_id_out, -- the new generated parent line id.
	       p_to_chr_id		=> NULL,
	       p_lse_id         => 20,
	       p_to_template_yn => p_to_template_yn,
               p_copy_reference     => 'COPY',
               p_copy_line_party_yn => 'Y',
	       p_renew_ref_yn        => 'N',
               p_generate_line_number  => l_generate_line_number, --Bug 2489856
               x_cle_id	        => l_cle_id_out20);
               IF (l_debug = 'Y') THEN
                 OKC_DEBUG.log('660 :after copy_contract_line');
               END IF;
               -- If any error happens it exits the loop or if it is a warning it still continues.
              IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
                  IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                    x_return_status := OKC_API.G_RET_STS_WARNING;
                  END IF;
                ELSE
                  x_return_status := l_return_status;
                  RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
              END IF;
              --Bug:3668722 copy sublines(lse=21,22,23) for coverage line(lse=20)
              copy_contract_lines(
                 p_api_version	     => p_api_version,
                 p_init_msg_list	 => p_init_msg_list,
                 x_return_status 	 => l_return_status,
                 x_msg_count     	 => x_msg_count,
                 x_msg_data      	 => x_msg_data,
                 p_from_cle_id	     => l_c_lines_id,
                 p_to_chr_id 		=> NULL, --the new generated contract header id
                 p_to_cle_id 		=> l_cle_id_out20,
                 p_to_template_yn      => p_to_template_yn,
                 p_copy_reference      =>p_copy_reference,
                 p_copy_line_party_yn  => p_copy_line_party_yn,
                 p_renew_ref_yn        => 'N',
                 p_generate_line_number => l_generate_line_number, --Bug 2489856
                 x_cle_id		     => l_cle_id_out21);
		  -- DND p_change_status        => 'Y');  --LLC

               IF (l_debug = 'Y') THEN
                 OKC_DEBUG.log('670 :after copy_contract_lines');
               END IF;
               -- If any error happens it exits the loop or if it is a warning it still continues.
               IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
                 IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                  x_return_status := OKC_API.G_RET_STS_WARNING;
                 END IF;
                ELSE
                 x_return_status := l_return_status;
                 RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
             END IF;
            END IF;
           END IF;--IF(l_lines_tbl(j).lse_id = 19 ) THEN
          ELSE
            copy_contract_lines(
                 p_api_version	     => p_api_version,
                 p_init_msg_list	     => p_init_msg_list,
                 x_return_status 	     => l_return_status,
                 x_msg_count     	     => x_msg_count,
                 x_msg_data      	     => x_msg_data,
                 p_from_cle_id	     => l_from_cle_id,
                 p_to_chr_id 		=> l_to_chr_id, --the new generated contract header id
                 p_to_cle_id 		=> l_to_cle_id,
                 p_to_template_yn      => p_to_template_yn,
                 p_copy_reference      =>p_copy_reference,
                 p_copy_line_party_yn  => p_copy_line_party_yn,
                 p_renew_ref_yn        => 'N',
                 p_generate_line_number => l_generate_line_number, --Bug 2489856
                 x_cle_id		     => l_cle_id_out);
		 -- DND p_change_status	=> 'Y');  --LLC

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('750 : After copy_contract_line  ');
   OKC_DEBUG.log('750 : x_return_status : '||l_return_status);
END IF;

            l_copy_sublines := 'F';
            -- If any error happens it exits the loop or if it is a warning it still continues.
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
                IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                  x_return_status := OKC_API.G_RET_STS_WARNING;
                END IF;
              ELSE
                x_return_status := l_return_status;
                RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;
            END IF;
          END IF;
		add_new_cle_id(l_lines_tbl(j).id,l_cle_id_out);
          ELSIF l_lines_tbl(j).line_exists_yn = 'Y' THEN
             l_from_cle_id := l_lines_tbl(j).id;
             l_to_cle_id   := l_lines_tbl(j).to_line;
             l_to_chr_id   := NULL;
          copy_contract_line(
	        p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_from_cle_id	=> l_from_cle_id,
             p_from_chr_id    => p_from_chr_id,
	     p_to_cle_id 	=> l_to_cle_id,
	     p_to_chr_id		=> l_to_chr_id,
	     p_lse_id         => l_lines_tbl(j).lse_id,
	     p_to_template_yn => p_to_template_yn,
             p_copy_reference     =>p_copy_reference,
             p_copy_line_party_yn => p_copy_line_party_yn,
	     p_renew_ref_yn     => 'N',
             p_generate_line_number => l_generate_line_number, --Bug 2489856
             x_cle_id		=> l_cle_id_out);

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('850 : After copy_contract_line  ');
   OKC_DEBUG.log('850 : x_return_status : '||l_return_status);
END IF;


          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
              IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                x_return_status := OKC_API.G_RET_STS_WARNING;
              END IF;
            ELSE
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
          END IF;
		add_new_cle_id(l_lines_tbl(j).id,l_cle_id_out);
	   ELSIF l_lines_tbl(j).line_exists_yn = 'N' THEN
		get_new_cle_id(l_lines_tbl(j).to_line,l_to_cle_id);
             l_from_cle_id := l_lines_tbl(j).id;
             l_to_chr_id   := NULL;
          copy_contract_line(
	     p_api_version	=> p_api_version,
             p_init_msg_list	=> p_init_msg_list,
             x_return_status 	=> l_return_status,
             x_msg_count     	=> x_msg_count,
             x_msg_data      	=> x_msg_data,
             p_from_cle_id	=> l_from_cle_id,
             p_from_chr_id    => p_from_chr_id,
	     p_to_cle_id 	=> l_to_cle_id,
	     p_to_chr_id		=> l_to_chr_id,
	     p_lse_id         => l_lines_tbl(j).lse_id,
	     p_to_template_yn => p_to_template_yn,
             p_copy_reference => p_copy_reference,
             p_copy_line_party_yn => p_copy_line_party_yn,
	     p_renew_ref_yn   => 'N',
             p_generate_line_number => l_generate_line_number, --Bug 2489856
             x_cle_id		=> l_cle_id_out);


IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('950 : After copy_contract_line  ');
   OKC_DEBUG.log('950 : x_return_status : '||l_return_status);
END IF;


          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_return_status = OKC_API.G_RET_STS_WARNING) THEN
              IF l_old_return_status <> OKC_API.G_RET_STS_ERROR THEN -- do not overwrite error with warning.
                x_return_status := OKC_API.G_RET_STS_WARNING;
              END IF;
            ELSE
              x_return_status := l_return_status;
              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
          END IF;
		add_new_cle_id(l_lines_tbl(j).id,l_cle_id_out);
	   END IF;
	   EXIT WHEN j = l_lines_tbl.LAST;
	   j := l_lines_tbl.NEXT(j);
	 END LOOP;
    END IF;

  -- Changes done for Bug 2054090
  -- PURPOSE  : Creates new configuration header and revision while
  --            copying a contract. The newly copied contract will point
  --            to the newly created config header and revisions.
  --            This procedure will handle all configured models in a contract.
  --             It updates contract lines for this config with new pointers
  --             for the columns config_top_model_line_id,
  --             config_header_id, config_revision_number.

  -- ---------------------------------------------------------------------------

     OKC_CFG_PUB.COPY_CONFIG(p_dnz_chr_id    => l_chr_id,
                             x_return_status => l_return_status);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
           IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
               x_return_status := l_return_status;
               RAISE G_EXCEPTION_HALT_VALIDATION;
           ELSE
               x_return_status := l_return_status;
           END IF;
         END IF;

IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1000 : After OKC_CFG_PUB.COPY_CONFIG  ');
   OKC_DEBUG.log('1000 : x_return_status : '||l_return_status);
END IF;

  -- Changes done for Bug 2054090

  --Changes done for Bug 3764231 to execute the dynamic SQL only for service contracts
      OPEN l_Service_Contract_csr;
      FETCH l_Service_Contract_csr into l_category;
      CLOSE l_Service_Contract_csr;
  --Changes done for Bug 3764231 to execute the dynamic SQL only for service contracts

   IF l_category = 'SERVICE' then   --Bug 3764231

      -- Begin - Changes done for Bug 1917514

      OPEN c_pdf;
      FETCH c_pdf INTO l_pdf_id;
      okc_create_plsql (p_pdf_id => l_pdf_id,
                    x_string => l_string) ;
      CLOSE c_pdf;


IF (l_debug = 'Y') THEN
   OKC_DEBUG.log('1100 : l_string : '||l_string);
END IF;

    IF l_string is NOT NULL THEN
       proc_string := 'begin '||l_string || ' (:b1,:b2,:b3); end ;';
       EXECUTE IMMEDIATE proc_string using l_chr_id,l_cle_id, out l_return_status;
         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN -- Bugfix 2151523(1917514) - modified IF
             x_return_status := l_return_status;
             RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
		   --for Bug#3101222 -Return status below is not properly initialized.
             --x_return_status := l_return_status; --for Bug#3101222
             l_oks_copy := 'N';
             -- Setting l_oks_copy to 'N' so that this procedure should not be called from
             -- Copy Line if it is already called from Copy Header
         END IF;
    END IF;
  END IF; -- End l_category ='SERVICE'
*/
-- hkamdar R12
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_module_name
                        ,'Before call to OKS_COPY_CONTRACT_PVT.COPY_COMPONENTS'
                       ||'p_from_chr_id='||p_from_chr_id
                       ||'p_contract_number='||p_contract_number);
    END IF;

  OKS_COPY_CONTRACT_PVT.COPY_COMPONENTS(
    p_api_version                  => p_api_version,
    p_init_msg_list                => p_init_msg_list,
    x_return_status                => l_return_status,
    x_msg_count                    => x_msg_count,
    x_msg_data                     => x_msg_data,
    p_from_chr_id                  => p_from_chr_id,
    p_to_chr_id                    => p_to_chr_id,
    p_contract_number              => p_contract_number,
    p_contract_number_modifier     => p_contract_number_modifier,
    p_to_template_yn               => p_to_template_yn,
    p_components_tbl               => p_components_tbl,
    p_lines_tbl                    => p_lines_tbl,
    x_to_chr_id                    => l_to_chr_id,
    p_published_line_ids_tbl => l_published_line_ids_tbl,
    p_include_cancelled_lines => p_include_cancelled_lines,
    p_include_terminated_lines => p_include_terminated_lines);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_module_name
                        ,'After call to OKS_COPY_CONTRACT_PVT.COPY_COMPONENTS'
                       ||'p_from_chr_id='||p_from_chr_id
                       ||'p_contract_number='||p_contract_number
		       ||'Return Status='||l_return_status
		       ||'New Chr Id='||l_to_chr_id);
    END IF;
    x_chr_id := l_to_chr_id;
    x_return_status := l_return_status;

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN -- Bugfix 2151523(1917514) - modified IF
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- End
  -- End - Changes done for Bug 1917514
END IF;
  IF (l_debug = 'Y') THEN
     OKC_DEBUG.log('10000 : Exiting Procedure OKC_COPY_CONTRACT_PVT.copy_components ', 2);
     OKC_DEBUG.ReSet_Indentation;
  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      IF (l_debug = 'Y') THEN
       OKC_DEBUG.log('20000 : Exiting Procedure OKC_COPY_CONTRACT_PVT.copy_components ', 2);
       OKC_DEBUG.ReSet_Indentation;
      END IF;
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      IF (l_debug = 'Y') THEN
         OKC_DEBUG.log('30000 : SQLCODE : '||SQLCODE);
         OKC_DEBUG.log('30000 : SQLERRM : '||SQLERRM);
         OKC_DEBUG.log('30000 : Exiting Procedure OKC_COPY_CONTRACT_PVT.copy_components ', 2);
         OKC_DEBUG.ReSet_Indentation;
      END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_components;

  -- Bug 2950549 - Added procedure add_concurent : This procedure will make a call-- to the concurrent program and insert records in OKC_CONC_requests table.
  PROCEDURE add_concurrent(p_components_tbl   IN api_components_tbl,
	                      p_lines_tbl    IN api_lines_tbl,
					  p_from_chr_id  IN NUMBER,
					  p_to_chr_id    IN NUMBER,
					  p_contract_number IN VARCHAR2,
					  p_contract_number_modifier IN VARCHAR2,
					  p_to_template_yn IN VARCHAR2 DEFAULT 'N',
					  p_copy_reference IN VARCHAR2 DEFAULT 'COPY',
					  p_copy_line_party_yn IN VARCHAR2,
					  p_scs_code     IN VARCHAR2,
					  p_intent       IN VARCHAR2,
					  p_prospect     IN VARCHAR,
					  p_include_cancelled_lines IN VARCHAR2 DEFAULT 'Y',
					  p_include_terminated_lines IN VARCHAR2 DEFAULT 'Y') IS
    l_request_id NUMBER;
    l_id NUMBER;

  BEGIN
  SELECT  okc_conc_requests_s.nextval into l_id from dual;
 IF p_components_tbl.COUNT > 0 THEN
   FOR i IN p_components_tbl.FIRST .. p_components_tbl.LAST LOOP
   INSERT INTO OKC_CONC_REQUESTS(
						   ID,
						   SOURCE_ID,
						   TARGET_CHR_ID,
						   COMPONENT_TYPE,
						   ATTRIBUTE1,
						   PROCESS_NAME,
						   ORG_ID,
						   CREATED_BY,
						   CREATION_DATE,
						   LAST_UPDATED_BY,
						   LAST_UPDATE_LOGIN,
                                       LAST_UPDATE_DATE,
               		  	         PROGRAM_APPLICATION_ID,
						   PROGRAM_ID,
						   PROGRAM_UPDATE_DATE,
						   REQUEST_ID)
     VALUES
				   (l_id,
				    p_components_tbl(i).id,
				    p_components_tbl(i).to_k,
				    p_components_tbl(i).component_type,
				    p_components_tbl(i).attribute1,
    			    'OKCCPCON',
                   FND_PROFILE.VALUE('ORG_ID'),
                   FND_GLOBAL.USER_ID,
			    SYSDATE,
			    FND_GLOBAL.USER_ID,
			    FND_GLOBAL.LOGIN_ID,
			    SYSDATE,
          decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
          decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
		decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
		decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID)
		);
		END LOOP;
END IF;
IF p_lines_tbl.count > 0 THEN
	FOR j  in p_lines_tbl.FIRST .. p_lines_tbl.LAST LOOP
      INSERT INTO OKC_CONC_REQUESTS(ID,
                               SOURCE_ID,
	 	   	             TARGET_CLE_ID,
					 LSE_ID,
	        			 LINE_EXISTS_YN,
					 LINE_EXP_YN,  --bug 3990643
					 PROCESS_NAME,
					 ORG_ID,
					 CREATED_BY,
					 CREATION_DATE,
					 LAST_UPDATED_BY,
					 LAST_UPDATE_LOGIN,
	         			 LAST_UPDATE_DATE,
					 PROGRAM_APPLICATION_ID,
					 PROGRAM_ID,
					 PROGRAM_UPDATE_DATE,
					 REQUEST_ID)
                   VALUES      ( l_id,
					  p_lines_tbl(j).id,
					  p_lines_tbl(j).to_line,
		        		  p_lines_tbl(j).lse_id,
					  p_lines_tbl(j).line_exists_yn,
					  p_lines_tbl(j).line_exp_yn,  --bug 3990643
					  'OKCCPCON',
					  FND_PROFILE.VALUE('ORG_ID'),
		          		   FND_GLOBAL.USER_ID,
					   SYSDATE,
					   FND_GLOBAL.USER_ID,
					   FND_GLOBAL.LOGIN_ID,
					   SYSDATE,
      decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
	decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
	decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
     	decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID)
										);
		END LOOP;
END IF;
          COMMIT;

		select okc_conc_requests_s.currval into l_id from dual;

		l_request_id := FND_REQUEST.SUBMIT_REQUEST(
						 APPLICATION => 'OKC',
						 PROGRAM     => 'OKCCPCON',
						 ARGUMENT1   => l_id,
						 ARGUMENT2   => p_from_chr_id,
						 ARGUMENT3   => p_to_chr_id,
						 ARGUMENT4   => p_contract_number,
						 ARGUMENT5   => p_contract_number_modifier,
						 ARGUMENT6   => p_to_template_yn,
						 ARGUMENT7   => p_copy_reference,
						 ARGUMENT8   => p_copy_line_party_yn,
						 ARGUMENT9   => p_scs_code,
						 ARGUMENT10  => p_intent,
						 ARGUMENT11  => p_prospect,
						 ARGUMENT12  => 'N', /*P_Copy_Entire_K_YN*/
						 ARGUMENT13  => p_include_cancelled_lines,
						 ARGUMENT14  => p_include_terminated_lines);
   IF l_request_id > 0 THEN
       OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                           p_msg_name => 'OKC_COPY_SUBMIT_S',
                           p_token1  => 'TOKEN1',
                           p_token1_value => l_request_id);
  END IF;


  END ADD_CONCURRENT ;



  PROCEDURE copy_concurrent(errbuf out NOCOPY VARCHAR2,
					   retcode out NOCOPY NUMBER,
                            p_id in NUMBER,
					    p_from_chr_id IN NUMBER,
					    p_to_chr_id IN NUMBER,
						p_contract_number IN VARCHAR2,
						 p_contract_number_modifier IN VARCHAR2,
						 p_to_template_yn IN VARCHAR2,
						 p_copy_reference IN VARCHAR2,
						 p_copy_line_party_yn IN VARCHAR2,
						 p_scs_code IN VARCHAR2,
						 p_intent   IN VARCHAR2,
						 p_prospect IN VARCHAR2,
						 p_copy_entire_k_yn IN VARCHAR2, -- hkamdar R12
					    	 p_include_cancelled_lines IN VARCHAR2 DEFAULT 'Y', p_include_terminated_lines IN VARCHAR2 DEFAULT 'Y') IS
    l_comp_tbl         api_components_tbl;
    l_lines_tbl        api_lines_tbl;
    l_published_line_ids_tbl OKS_COPY_CONTRACT_PVT.published_line_ids_tbl;

    l_api_version                 CONSTANT NUMBER := 1;
    x_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_init_msg_list               VARCHAR2(1) := 'T';
    x_msg_count                   NUMBER := OKC_API.G_MISS_NUM;
    x_msg_data                    VARCHAR2(2000) := OKC_API.G_MISS_CHAR;
    l_chr_id                     NUMBER;
    CURSOR cur_select_records IS SELECT
		                    	SOURCE_ID ID,
						TARGET_CHR_ID TO_K,
						COMPONENT_TYPE,
						ATTRIBUTE1,
						TARGET_CLE_ID to_line,
						LSE_ID,
						LINE_EXISTS_YN,
						LINE_EXP_YN --mmadhavi bug 3990643
					      FROM    OKC_CONC_REQUESTS
						WHERE ID = p_id;

      --Bug 4045272
	 --Adding cursor to get Contract Number of Copied Contract for writing to Concurrent Manager log file
	 CURSOR get_k_num_csr(p_chr_id IN NUMBER)
	 IS
	 SELECT
	  contract_number ||' '|| contract_number_modifier
	 FROM okc_k_headers_b
	 WHERE id = p_chr_id;

	 l_token                       VARCHAR2(250);
	 l_msg_stack VARCHAR2(250);

	i NUMBER := 1;
        l_app_name VARCHAR2(30) := 'Copy_Concurrent';
    	l_no_of_cancel_lines NUMBER;
    	l_no_of_termn_lines  NUMBER;
    	l_include_cancelled_lines varchar2(1) := p_include_cancelled_lines;
    	l_include_terminated_lines varchar2(1) := p_include_terminated_lines;

   CURSOR l_lines_csr(p_chr_id in number) IS
     SELECT COUNT(date_cancelled), COUNT(date_terminated)
        FROM okc_k_lines_b okcb, oks_k_lines_b oksb
        WHERE okcb.id = oksb.cle_id
        AND okcb.dnz_chr_id = p_chr_id;
BEGIN
-- hkamdar R12 Copy MOAC changes
OKC_CONTEXT.SET_OKC_ORG_CONTEXT(p_chr_id => p_from_chr_id);
          -- hkamdar R12 Copy Enhancements
   IF p_copy_entire_k_yn = 'Y' THEN -- When Entire contract needs to copied

	IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      			FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_app_name
                        ,'Before call to OKS_COPY_CONTRACT_PVT.COPY_CONTRACT'
                       ||'p_chr_id='||p_from_chr_id
                       ||'p_contract_number='||p_contract_number);
	END IF;

              -- Call OKS Copy Contract
              OKS_COPY_CONTRACT_PVT.COPY_CONTRACT(
   						 p_api_version               => l_api_version,
						 p_init_msg_list             => l_init_msg_list,
    						 x_return_status             => x_return_status,
						 x_msg_count                 => x_msg_count,
						 x_msg_data                  => x_msg_data,
    						 p_chr_id                    => p_from_chr_id,
    						 p_contract_number           => p_contract_number,
   						 p_contract_number_modifier  => p_contract_number_modifier,
						 p_to_template_yn            => p_to_template_yn,
    						 p_renew_ref_yn              => 'N',
					         x_to_chr_id                 => l_chr_id,
						 p_include_cancelled_lines  => p_include_cancelled_lines, p_include_terminated_lines => p_include_terminated_lines);

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_app_name
                        ,'After call to OKS_COPY_CONTRACT_PVT.COPY_CONTRACT'
                       ||'p_chr_id='||p_from_chr_id
                       ||'p_contract_number='||p_contract_number
		       ||'Return Status='||x_return_status
		       ||'New Chr Id='||l_chr_id);
                END IF;

              If x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			  FOR i in 1..fnd_msg_pub.count_msg LOOP
				l_msg_stack := fnd_msg_pub.get(p_msg_index => i
				                             ,p_encoded => 'F');
			     FND_FILE.PUT_LINE (FND_FILE.LOG,l_msg_stack);
			  END LOOP;

                 IF l_chr_id is NULL THEN
                    RETCODE := 2;
                 ELSE
                    RETCODE := 1;
                 END IF;
              ELSE
		      Open get_k_num_csr(l_chr_id);
			 Fetch get_k_num_csr into l_token;
			 Close get_k_num_csr;
		       IF L_INCLUDE_CANCELLED_LINES = 'N' OR L_INCLUDE_TERMINATED_LINES = 'N' THEN

        		OPEN L_LINES_CSR(p_from_chr_id);
        		FETCH L_LINES_CSR INTO l_no_of_cancel_lines, l_no_of_termn_lines;
        		CLOSE L_LINES_CSR;

         		IF l_no_of_cancel_lines <> 0 OR l_no_of_termn_lines <> 0 THEN
			 IF (l_no_of_cancel_lines <> 0 AND l_no_of_termn_lines <> 0) AND (L_INCLUDE_CANCELLED_LINES = 'N' AND L_INCLUDE_TERMINATED_LINES = 'N') THEN

			  fnd_message.set_name('OKC', 'OKC_NO_CANC_TERMN_LINE');
        		  FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);

        		ELSIF l_no_of_cancel_lines <> 0 AND L_INCLUDE_CANCELLED_LINES = 'N' THEN
			  fnd_message.set_name('OKC', 'OKC_NO_CANCEL_LINE');
        		  FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);
        	        ELSIF l_no_of_termn_lines <> 0 AND L_INCLUDE_TERMINATED_LINES = 'N' THEN
			  fnd_message.set_name('OKC', 'OKC_NO_TERMN_LINE');
        		  FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);
			END IF;
			END IF;
                       END IF;

                fnd_message.set_name('OKC', 'OKC_COPY_CONTRACT');
		      fnd_message.set_token(token =>'KNUM', value => l_token);
	           FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);

                RETCODE := 0;
              END IF;

              ERRBUF := x_msg_data;
  ELSE
  -- End hkamdar R12

	   FOR p_cur_select_records IN cur_select_records LOOP
		 l_comp_tbl(i).id := p_cur_select_records.id;
		 l_comp_tbl(i).to_k := p_cur_select_records.to_k;
           IF p_cur_select_records.component_type is not null then
		    l_comp_tbl(i).component_type := p_cur_select_records.component_type;
	         l_comp_tbl(i).attribute1 := p_cur_select_records.attribute1;
		 ELSE
              l_lines_tbl(i).id := p_cur_select_records.id;
		    l_lines_tbl(i).to_line := p_cur_select_records.to_line;
		    l_lines_tbl(i).lse_id := p_cur_select_records.lse_id;
		    l_lines_tbl(i).line_exists_yn := p_cur_select_records.line_exists_yn;
		    l_lines_tbl(i).line_exp_yn := p_cur_select_records.line_exp_yn; --bug 3990643
		 END IF;
           i := i + 1;
	   END LOOP;

-- hkamdar R12 modified call parameters 7/25/2005.

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_app_name
                        ,'Before call to OKS_COPY_CONTRACT_PVT.COPY_COMPONENTS'
                       ||'p_from_chr_id='||p_from_chr_id
		       ||'p_to_chr_id='||p_to_chr_id
                       ||'p_contract_number='||p_contract_number);
                END IF;

        OKS_COPY_CONTRACT_PVT.copy_components(
	              p_api_version         => l_api_version,
			    p_init_msg_list         => l_init_msg_list,
			    x_return_status         => x_return_status,
			    x_msg_count             => x_msg_count,
			    x_msg_data              => x_msg_data,
			    p_from_chr_id           => p_from_chr_id,
			    p_to_chr_id             => p_to_chr_id,
			    p_contract_number       => p_contract_number,
			    p_contract_number_modifier   => p_contract_number_modifier,
			    p_to_template_yn        => p_to_template_yn,
			    p_components_tbl       => l_comp_tbl,
			    p_lines_tbl             => l_lines_tbl,
		 	    x_to_chr_id           => l_chr_id,
			    p_published_line_ids_tbl => l_published_line_ids_tbl,
			    p_include_cancelled_lines => p_include_cancelled_lines,
		 	    p_include_terminated_lines => p_include_terminated_lines);

              IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string(FND_LOG.level_statement
                        ,G_PKG_NAME||'.'||l_app_name
                        ,'After call to OKS_COPY_CONTRACT_PVT.COPY_COMPONENTS'
                       ||'p_from_chr_id='||p_from_chr_id
                       ||'p_to_chr_id='||p_to_chr_id
                       ||'p_contract_number='||p_contract_number
		       ||'Return Status='||x_return_status);
              END IF;

       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	     FOR i in 1..fnd_msg_pub.count_msg LOOP
		    l_msg_stack := fnd_msg_pub.get(p_msg_index => i
		                                 ,p_encoded => 'F');
		    FND_FILE.PUT_LINE (FND_FILE.LOG,l_msg_stack);
		END LOOP;

		 IF l_chr_id is NULL THEN
		    RETCODE := 2;
          ELSE
		    RETCODE := 1;
          END IF;
       ELSE
          Open get_k_num_csr(l_chr_id);
          Fetch get_k_num_csr into l_token;
          Close get_k_num_csr;

		     IF L_INCLUDE_CANCELLED_LINES = 'N' OR L_INCLUDE_TERMINATED_LINES = 'N' THEN

        		OPEN L_LINES_CSR(p_from_chr_id);
        		FETCH L_LINES_CSR INTO l_no_of_cancel_lines, l_no_of_termn_lines;
        		CLOSE L_LINES_CSR;

         		IF l_no_of_cancel_lines <> 0 OR l_no_of_termn_lines <> 0 THEN
			 IF (l_no_of_cancel_lines <> 0 AND l_no_of_termn_lines <> 0) AND (L_INCLUDE_CANCELLED_LINES = 'N' AND L_INCLUDE_TERMINATED_LINES = 'N') THEN
			  fnd_message.set_name('OKC', 'OKC_NO_CANC_TERMN_LINE');
        		  FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);

        		ELSIF l_no_of_cancel_lines <> 0 AND L_INCLUDE_CANCELLED_LINES = 'N' THEN
			  fnd_message.set_name('OKC', 'OKC_NO_CANCEL_LINE');
        		  FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);
        	        ELSIF l_no_of_termn_lines <> 0 AND L_INCLUDE_TERMINATED_LINES = 'N' THEN
			  fnd_message.set_name('OKC', 'OKC_NO_TERMN_LINE');
        		  FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);
			END IF;
			END IF;
                      END IF;

          fnd_message.set_name('OKC', 'OKC_COPY_CONTRACT');
          fnd_message.set_token(token =>'KNUM', value => l_token);
	     FND_FILE.PUT_LINE (FND_FILE.LOG, fnd_message.get);


		RETCODE := 0;
       END IF;
	  ERRBUF := x_msg_data;
     END IF;-- hkamdar R12
 END copy_concurrent;

 -- IKON ER 3819893


 PROCEDURE UPDATE_TEMPLATE_CONTRACT (p_api_version  IN NUMBER,
				    p_chr_id        IN NUMBER,
				    p_start_date    IN DATE,
				    p_end_date      IN DATE,
				    x_msg_count     OUT  NOCOPY  NUMBER,
				    x_msg_data      OUT   NOCOPY VARCHAR2,
                                    x_return_status OUT   NOCOPY VARCHAR2)
IS

     l_msg_count          NUMBER;
     l_msg_data           VARCHAR2(2000);
     l_return_status      VARCHAR2(1) := 'S';
     l_api_version        NUMBER := 1.0;
     l_init_msg_list      CONSTANT VARCHAR2(1) := 'F';
     l_duration           NUMBER := 0;
     l_period             VARCHAR2(20);
     l_hdr_duration       NUMBER := 0;
     l_line_duration      NUMBER := 0;
     l_hdr_line_duration  NUMBER := 0;
     l_hdr_est_duration   NUMBER := 0;
     l_hdr_period         VARCHAR2(20);
     l_start_date         DATE;
     l_end_date           DATE;
     l_hdr_end_date       DATE;
     l_hdr_start_date     DATE;
     l_invoice_rule_id    NUMBER;
     l_hdr_acct_rule      NUMBER;
     l_line_acct_rule     NUMBER;
     l_hdr_timeunit       VARCHAR2(100);
     l_line_timeunit      VARCHAR2(100);
     l_hdr_est_timeunit   VARCHAR2(100);
     l_hdr_line_timeunit  VARCHAR2(100);
     l_timeunit           VARCHAR2(100);
    -- x_return_status VARCHAR2(10);

     -- QP input params
     qp_rec              OKS_QP_PKG.Input_details;
     price_details_rec   OKS_QP_PKG.PRICE_DETAILS;
     modifier_det_tbl    QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
     price_break_det_tbl OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;

     subtype chrv_rec_type is okc_contract_pvt.chrv_rec_type;
     l_chrv_rec    chrv_rec_type;
     x_chrv_rec chrv_rec_type;

     l_billing_type     VARCHAR2(2000);
     l_rec              OKS_BILLING_PROFILES_PUB.Billing_profile_rec;
     l_sll_tbl_out      OKS_BILLING_PROFILES_PUB.Stream_Level_tbl;
     l_slh_rec          OKS_BILL_SCH.StreamHdr_Type;
     l_sll_tbl          OKS_BILL_SCH.StreamLvl_tbl;
     l_bil_sch_out_tbl  OKS_BILL_SCH.ItemBillSch_tbl;
     rru_id             NUMBER;
     ire_id             NUMBER;
     l_klnv_id          NUMBER;
     l_obj_num          NUMBER;
     l_timevalue_id     NUMBER;
     l_arl_exist_flag   VARCHAR2(1) := 'Y';
     l_ire_exist_flag   VARCHAR2(1) := 'Y';
     l_rgp_id           NUMBER;

     -- Estimation Params
     l_khrv_tbl_in    oks_contract_hdr_pub.khrv_tbl_type;
     l_khrv_tbl_out   oks_contract_hdr_pub.khrv_tbl_type;
     l_klnv_tbl_in    oks_contract_line_pub.klnv_tbl_type;
     l_klnv_tbl_out   oks_contract_line_pub.klnv_tbl_type;
     l_est_id         NUMBER;
     l_est_date       DATE;
     l_est_date_s     VARCHAR2(50);
     l_est_obj_num    NUMBER;


     -- To delete security levels
     subtype cacv_rec_type is okc_contract_pvt.cacv_rec_type;
     cacv_rec    cacv_rec_type;

     --Partial Period Uptake changes
     l_SrcContractPPSetupExists_YN VARCHAR2(1);
     l_GCDPPSetupExists_YN VARCHAR2(1) ;


     -- Get Source Contract ID
     CURSOR GetSourceContractID(P_To_Chr_ID IN NUMBER) IS
     select orig_system_id1
     from
     okc_k_headers_b
     where id = P_To_Chr_ID;

     P_From_Chr_ID  NUMBER;

     -- Get current security restrictions
     CURSOR get_access_level (p_chr_id IN NUMBER) IS
            SELECT id
            FROM okc_k_accesses
            WHERE chr_id = p_chr_id;

      -- Select all top lines and sublines
     CURSOR get_contract_lines_csr (p_chr_id IN NUMBER) IS
            SELECT  id,start_date,end_date,lse_id
            FROM    OKC_K_LINES_B
            WHERE   lse_id in (1,7,8,9,10,11,12,13,14,19,18,25,35,46)
            CONNECT BY cle_id = PRIOR id
            START WITH CHR_ID = p_chr_id;


     -- Get Header start date and rules
     CURSOR get_hdr_date_csr(p_chr_id IN NUMBER) IS
            SELECT start_date,end_date
            FROM OKC_K_HEADERS_B
            WHERE id = p_chr_id;

     -- Get all top lines
     CURSOR topline_csr(p_chr_id IN NUMBER) IS
        SELECT id, dnz_chr_id
                , start_date, end_date,lse_id,inv_rule_id
                --npalepu added new column on 18-may-2006 for bug # 5211482
                ,ORIG_SYSTEM_ID1
                --end npalepu
         FROM   OKC_K_LINES_B
         WHERE  dnz_chr_id = p_chr_id
         AND    cle_id IS NULL;


     --npalepu added on 18-may-2006 for bug # 5211482
     CURSOR GetStreamsForSourceLine(P_From_Cle_ID IN NUMBER) IS
        SELECT  SEQUENCE_NO
                ,UOM_CODE
                ,START_DATE
                ,END_DATE
                ,LEVEL_PERIODS
                ,UOM_PER_PERIOD
                ,ADVANCE_PERIODS
                ,LEVEL_AMOUNT
                ,INVOICE_OFFSET_DAYS
                ,INTERFACE_OFFSET_DAYS
                ,COMMENTS
                ,DUE_ARR_YN
                ,AMOUNT
                ,LINES_DETAILED_YN
        FROM    OKS_STREAM_LEVELS_B
        WHERE CLE_ID = P_From_Cle_ID
        AND dnz_chr_id = P_FROM_CHR_ID
        ORDER BY SEQUENCE_NO;

     TYPE l_SrcLnStreams_Tbl_Type IS TABLE OF GetStreamsForSourceLine%ROWTYPE INDEX BY BINARY_INTEGER;
     l_SrcLnStreams_Tbl l_SrcLnStreams_Tbl_Type;
     l_SrcLnStreams_Exists_YN VARCHAR2(1);

     l_LineStreams_tbl OKS_BILL_SCH.StreamLvl_tbl;
     l_LineStreams_tbl_Ctr NUMBER := 0;
     l_duration_match   VARCHAR2(1);
     --end npalepu

     --  Get current Hdr ARL rule.
     CURSOR get_hdr_arl_csr(p_cle_id IN NUMBER) IS
        SELECT acct_rule_id
        FROM   OKS_K_HEADERS_B
        WHERE chr_id = p_chr_id;

     -- Get current billing  type
     CURSOR get_billing_type_csr(p_cle_id IN NUMBER) IS
        SELECT  billing_schedule_type
        FROM    OKS_K_LINES_B
        WHERE cle_id = p_cle_id
	and dnz_chr_id = p_chr_id;


     --  Get current ARL rule.
     CURSOR get_arl_csr(p_cle_id IN NUMBER) IS
        SELECT id,acct_rule_id, object_version_number
	FROM OKS_K_LINES_B
        WHERE cle_id = p_cle_id
	and dnz_chr_id = p_chr_id;

     -- Get Estimation date

         CURSOR get_estimation_date(p_chr_id IN NUMBER) IS
                SELECT id, object_version_number, est_rev_date
                FROM OKS_K_HEADERS_B
                WHERE chr_id = p_chr_id;

     --npalepu added on 27-FEB-2007 for bug # 5671352
     CURSOR toplinetax_cur(p_cle_id IN NUMBER) IS
        SELECT SUM(nvl(tax_amount, 0)) amount
        FROM okc_k_lines_b cle, oks_k_lines_b kln
        WHERE cle.cle_id = p_cle_id
        AND   cle.id = kln.cle_id
        AND   cle.lse_id IN (7, 8, 9, 10, 11, 13, 35, 25)
        AND   cle.date_cancelled IS NULL;

     l_tax_amount       toplinetax_cur%ROWTYPE;
     l_topline_count    NUMBER;

     CURSOR Get_oks_Lines_details(p_cle_id IN NUMBER) IS
        SELECT id, object_version_number, dnz_chr_id
        FROM oks_k_lines_b
        WHERE cle_id = p_cle_id ;

     l_get_oks_details               Get_oks_Lines_details%ROWTYPE;
     l_klnv_tax_tbl_in               oks_contract_line_pub.klnv_tbl_type;
     l_klnv_tax_tbl_out              oks_contract_line_pub.klnv_tbl_type;

     CURSOR hdrtax_cur IS
        SELECT SUM(kln.tax_amount)  amount
        FROM okc_k_lines_b cle, oks_k_lines_b kln
        WHERE cle.dnz_chr_id = p_chr_id
        AND   cle.id = kln.cle_id
        AND   cle.lse_id IN (7, 8, 9, 10, 11, 13, 35, 25, 46)
        AND   cle.date_cancelled IS NULL;

     l_total_tax hdrtax_cur%ROWTYPE;

     CURSOR Get_Header_details IS
        SELECT id, object_version_number
        FROM OKS_K_HEADERS_B
        WHERE chr_id = p_chr_id ;

     l_get_hdr_details   get_header_details%ROWTYPE;
     l_khrv_tax_tbl_in   oks_contract_hdr_pub.khrv_tbl_type;
     l_khrv_tax_tbl_out  oks_contract_hdr_pub.khrv_tbl_type;
     --end bug # 5671352

      -------------------------------------------------------------------------------------
      -- This procedure updates all the line start date and end date based on new start date
      -- p_cle_id     - Line ID
      -- p_start_date - New Line Strat Date
      -- p_end_date   - New Line End Date
      -- p_lse_id     - Line Type
      --------------------------------------------------------------------------------------

     PROCEDURE UPDATE_LINE_DETAILS(p_cle_id        NUMBER,
                                   p_start_date    DATE,
                                   p_end_date      DATE,
                                   p_lse_id        NUMBER,
                                   x_msg_count     OUT  NOCOPY  NUMBER,
                                   x_msg_data      OUT   NOCOPY VARCHAR2,
                                   x_return_status OUT   NOCOPY VARCHAR2) IS

       l_api_version      NUMBER := 1.0;
       l_msg_count        NUMBER;
       l_end_date         DATE;
       l_msg_data         VARCHAR2(2000);
       l_return_status    VARCHAR2(1) := 'S';
       l_hdr_end_date     DATE;
       l_line_end_date    DATE;
       l_quantity         NUMBER;
       l_temp             VARCHAR2(2);
       l_hdr_inv_rule     NUMBER;
       l_line_inv_rule    NUMBER;

       subtype clev_rec_type is okc_contract_pvt.clev_rec_type;
       l_clev_rec  clev_rec_type;
       x_clev_rec  clev_rec_type;
       l_id               NUMBER;


     -- Check PM
     CURSOR check_pm_sch_csr(p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
            SELECT '1'
            FROM  OKS_PM_SCHEDULES
            WHERE dnz_chr_id = p_chr_id
            --npalepu modified on 5/12/2006 for bug # 5211447
            --changing because from R12 onwards the PM schedules will be directly
            --attached to the TOP line but not to the coverage line
            /* AND   cle_id in ( SELECT id
                              FROM  OKC_K_LINES_B
                              WHERE cle_id = p_cle_id); */
           AND   cle_id = p_cle_id;
           --end npalepu

     CURSOR get_hdr_enddate (p_chr_id IN NUMBER) IS
            SELECT end_date,inv_rule_id
            FROM okc_k_headers_b
            WHERE id=  p_chr_id;

     CURSOR get_parent_line_enddate (p_cle_id IN NUMBER) IS
            SELECT end_date,inv_rule_id
            FROM okc_k_lines_b
            WHERE id IN (SELECT b.cle_id
                         FROM OKC_K_LINES_B b
                         WHERE b.id = p_cle_id);

     -- Get the coverage line
       CURSOR line_cov_cur(p_cle_id IN Number) Is
              SELECT id
              FROM   OKC_K_LINES_V
              WHERE  cle_id = p_cle_id
              AND    lse_id in (2,13,15,20);

     BEGIN


            IF (l_debug = 'Y') THEN
               okc_debug.log('1130: Inside Update Lines');
            END IF;
          -- Compare parent and child dates.
           --Bug 4698309: Added lse_id checks for 12 and 46 also
          IF (   ( p_lse_id = 1)
		    OR (p_lse_id = 12)
		    OR (p_lse_id = 14)
		    OR (p_lse_id = 19)
		    OR (p_lse_id = 46)) THEN
             OPEN get_hdr_enddate (p_chr_id);
             FETCH get_hdr_enddate INTO l_hdr_end_date,l_hdr_inv_rule;
             CLOSE get_hdr_enddate;

             IF (p_end_date > l_hdr_end_date) THEN
                 l_end_date := l_hdr_end_date;
             ELSE
                 l_end_date := p_end_date;
             END IF;
          ELSE
                OPEN get_parent_line_enddate(p_cle_id);
                FETCH get_parent_line_enddate INTO l_line_end_date,l_line_inv_rule;
                CLOSE get_parent_line_enddate;
                IF (p_end_date > l_line_end_date) THEN
                   l_end_date := l_line_end_date;
                ELSE
                   l_end_date := p_end_date;
                END IF;
          END IF;

          l_clev_rec.id         := p_cle_id;
          l_clev_rec.start_date := p_start_date;
          l_clev_rec.end_date   := l_end_date;
	  IF l_line_inv_rule IS NULL then
           l_clev_rec.inv_rule_id   := l_hdr_inv_rule;
	 END IF;

          IF (l_debug = 'Y') THEN
               okc_debug.log('1140: Before calling OKC_CONTRACT_PUB.update_contract_line '|| p_cle_id);
               okc_debug.log('1141: Line New Start Date ' || p_start_date);
               okc_debug.log('1142: Line New End Date ' || l_end_date);
          END IF;

          OKC_CONTRACT_PUB.update_contract_line(p_api_version   => l_api_version,
                                                  x_return_status => l_return_status ,
                                                  x_msg_count     => l_msg_count,
                                                  x_msg_data      => l_msg_data,
                                                  p_clev_rec      => l_clev_rec ,
                                                  x_clev_rec      => x_clev_rec);

          IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;

          IF (p_lse_id =1) OR (p_lse_id = 14) OR (p_lse_id = 19)  THEN

	      OPEN  line_cov_cur(p_cle_id);
              FETCH line_cov_cur into l_id;


              IF line_cov_cur%Found THEN


                  IF (l_debug = 'Y') THEN
                     okc_debug.log('1150: Before Update Coverage');
                  END IF;

                  OKS_COVERAGES_PVT.Update_COVERAGE_Effectivity(
                              p_api_version     => l_api_version,
                              p_init_msg_list   => l_init_msg_list,
                              x_return_status   => l_return_status,
                              x_msg_count       => l_msg_count,
                              x_msg_data        => l_msg_data,
                              p_service_Line_Id => p_cle_id,
                              p_New_Start_Date  => p_start_date,
                              p_New_End_Date    => l_end_date  );
              END IF;
              CLOSE line_cov_cur;
              IF (l_debug = 'Y') THEN
                  okc_debug.log('1150: After Update Coverage ' || l_return_status);
              END IF;


              IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;

              -- Update PM Schedules.
              OPEN check_pm_sch_csr(p_chr_id,p_cle_id);
              FETCH check_pm_sch_csr INTO l_temp;
              IF check_pm_sch_csr%FOUND THEN

                 OKS_PM_PROGRAMS_PVT.ADJUST_PM_PROGRAM_SCHEDULE(p_api_version    => l_api_version,
                                                              p_contract_line_id => p_cle_id,
                                                              p_new_start_date   => p_start_date,
                                                              p_new_end_date     => l_end_date,
                                                              x_return_status    => l_return_status,
                                                              x_msg_count        => l_msg_count,
                                                              x_msg_data         => l_msg_data);

                 IF (l_debug = 'Y') THEN
                    okc_debug.log('1160: After Adjust PM Pgm ' || l_return_status);
                 END IF;

              END IF;
              CLOSE check_pm_sch_csr;

            /*  IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF; */
          END IF;



           IF (p_lse_id = 46) THEN

               OKS_SUBSCRIPTION_PUB.RECREATE_SCHEDULE(p_api_version    => l_api_version,
                                                       p_init_msg_list  => OKC_API.G_FALSE,
                                                       x_return_status  => l_return_status,
                                                       x_msg_count      => l_msg_count,
                                                       x_msg_data       => l_msg_data,
                                                       p_cle_id         => p_cle_id,
                                                       p_intent         => null,
                                                       x_quantity       => l_quantity);
               IF (l_debug = 'Y') THEN
                  okc_debug.log('1170: After Sucbscription recreate ' || l_return_status);
               END IF;

               IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;
           END IF;

     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
               IF  check_pm_sch_csr%ISOPEN THEN
                   CLOSE check_pm_sch_csr;
               END IF;
               x_return_status := l_return_status;
       WHEN OTHERS  THEN
            IF check_pm_sch_csr%ISOPEN THEN
               CLOSE check_pm_sch_csr;
            END IF;
            x_return_status := l_return_status;
     END UPDATE_LINE_DETAILS;
/*
    -- This function is to get the timevalue id for Billing
    FUNCTION Create_Timevalue
          (
          l_start_date      IN DATE,
          l_chr_id          IN  NUMBER
          ) RETURN NUMBER Is

      l_p_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
      l_x_tavv_tbl     OKC_TIME_PUB.TAVV_TBL_TYPE;
      l_api_version    NUMBER := 1.0;
      l_init_msg_list  VARCHAR2(1) := 'T';
      l_return_status  VARCHAR2(200);
      l_msg_count      NUMBER;
      l_msg_data       VARCHAR2(2000);
    BEGIN

      IF (l_debug = 'Y') THEN
          okc_debug.log('1175: FUNCTION Create_Timevalue');
      END IF;

      l_p_tavv_tbl(1).id                    := NULL;
      l_p_tavv_tbl(1).object_version_number := NULL;
      l_p_tavv_tbl(1).sfwt_flag             := 'N';
      l_p_tavv_tbl(1).spn_id                := NULL;
      l_p_tavv_tbl(1).tve_id_generated_by   := NULL;
      l_p_tavv_tbl(1).dnz_chr_id            := NULL;
      l_p_tavv_tbl(1).tze_id                := NULL;
      l_p_tavv_tbl(1).tve_id_limited        := NULL;
      l_p_tavv_tbl(1).description           := '';
      l_p_tavv_tbl(1).short_description     := '';
      l_p_tavv_tbl(1).comments              := '';
      l_p_tavv_tbl(1).datetime              := NULL;
      l_p_tavv_tbl(1).attribute_category    := '';
      l_p_tavv_tbl(1).attribute1  := '';
      l_p_tavv_tbl(1).attribute2  := '';
      l_p_tavv_tbl(1).attribute3  := '';
      l_p_tavv_tbl(1).attribute4  := '';
      l_p_tavv_tbl(1).attribute5  := '';
      l_p_tavv_tbl(1).attribute6  := '';
      l_p_tavv_tbl(1).attribute7  := '';
      l_p_tavv_tbl(1).attribute8  := '';
      l_p_tavv_tbl(1).attribute9  := '';
      l_p_tavv_tbl(1).attribute10 := '';
      l_p_tavv_tbl(1).attribute11 := '';
      l_p_tavv_tbl(1).attribute12 := '';
      l_p_tavv_tbl(1).attribute13 := '';
      l_p_tavv_tbl(1).attribute14 := '';
      l_p_tavv_tbl(1).attribute15 := '';
      l_p_tavv_tbl(1).created_by        := NULL;
      l_p_tavv_tbl(1).creation_date     := NULL;
      l_p_tavv_tbl(1).last_updated_by   := NULL;
      l_p_tavv_tbl(1).last_update_date  := NULL;
      l_p_tavv_tbl(1).last_update_login := NULL;
      l_p_tavv_tbl(1).datetime          := l_start_date;
      l_p_tavv_tbl(1).dnz_chr_id        := l_chr_id;

      okc_time_pub.create_tpa_value
         (p_api_version   => l_api_version,
          p_init_msg_list => l_init_msg_list,
          x_return_status => l_return_status,
          x_msg_count     => l_msg_count,
          x_msg_data      => l_msg_data,
          p_tavv_tbl      => l_p_tavv_tbl,
          x_tavv_tbl      => l_x_tavv_tbl) ;

       If l_return_status <> 'S' then
          OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Create TPA Value ');
          Raise G_EXCEPTION_HALT_VALIDATION;
       End If;

       RETURN(l_x_tavv_tbl(1).id);

    End Create_Timevalue;
    */

BEGIN
       --Partial Period Uptake change
       --Get Source Contract ID--
       OPEN GetSourceContractID(P_To_Chr_ID => p_chr_id);
       FETCH GetSourceContractID into P_From_Chr_ID;
       CLOSE GetSourceContractID;

       l_SrcContractPPSetupExists_YN := OKS_COPY_CONTRACT_PVT.ContractPPSetupEXISTS(P_Chr_ID => P_From_Chr_ID);
       IF (OKS_SETUP_UTIL_PUB.G_GCD_PERIOD_START IS NOT NULL and OKS_SETUP_UTIL_PUB.G_GCD_PERIOD_TYPE IS NOT NULL) then
        l_GCDPPSetupExists_YN := 'Y';
       ELSE
        l_GCDPPSetupExists_YN := 'N';
       END IF;

       IF (l_debug = 'Y') THEN
          okc_debug.Set_Indentation('UPDATE_TEMPLATE_CONTRACT ');
          okc_debug.log('1000: Entering Update Template Contract' || to_char(sysdate,'HH:MI:SS'));
       END IF;

       -- Get the current header start date and rule
       OPEN  get_hdr_date_csr(p_chr_id);
       FETCH get_hdr_date_csr INTO l_hdr_start_date,l_hdr_end_date;
       CLOSE get_hdr_date_csr;

       IF p_end_date IS NOT NULL THEN

            IF (l_debug = 'Y') THEN
               okc_debug.log('1010: P_END_DATE is not null');
            END IF;

            l_chrv_rec.id           := p_chr_id;
            l_chrv_rec.start_date   := p_start_date;
            l_chrv_rec.end_date     := p_end_date;


            OKC_CONTRACT_PUB.update_contract_header(p_api_version   => l_api_version,
                                                    x_return_status => l_return_status,
                                                    x_msg_count     => l_msg_count,
                                                    x_msg_data      => l_msg_data,
                                                    p_chrv_rec      => l_chrv_rec,
                                                    x_chrv_rec      => x_chrv_rec);

            IF (l_debug = 'Y') THEN
               okc_debug.log('1020: After OKC_CONTRACT_PUB.update_contract_header call ' || l_return_status);
            END IF;
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	    -- Delete Header billing schedule bug# 4188236
	    DELETE FROM OKS_LEVEL_ELEMENTS
	    WHERE RUL_ID IN
	    (SELECT SLL.ID
	     FROM OKS_STREAM_LEVELS_B SLL
	     WHERE SLL.DNZ_CHR_ID=P_CHR_ID and CLE_ID IS NULL);

            DELETE FROM OKS_STREAM_LEVELS_B
	    WHERE DNZ_CHR_ID = P_CHR_ID and CLE_ID IS NULL;

            -- bug fix 4188236

            -- Check for Revenue estimation date
            OPEN  get_estimation_date(p_chr_id);
            FETCH get_estimation_date INTO l_est_id,l_est_obj_num,l_est_date_s;
            IF (get_estimation_date%FOUND) THEN
                l_khrv_tbl_in(1).id :=l_est_id;
                l_khrv_tbl_in(1).chr_id := p_chr_id;
                l_khrv_tbl_in(1).object_version_number := l_est_obj_num;
                l_khrv_tbl_in(1).est_rev_date := p_start_date;

                OKS_CONTRACT_HDR_PUB.update_header
                           (
                            p_api_version 	=> 1,
                            p_init_msg_list	=> 'F',
                            x_return_status	=> l_return_status,
                            x_msg_count	        => l_msg_count,
                            x_msg_data		=> l_msg_data,
                            p_khrv_tbl		=> l_khrv_tbl_in,
                            x_khrv_tbl		=> l_khrv_tbl_out,
                            p_validate_yn       => 'N');
                l_khrv_tbl_in.delete;
            END IF;
            CLOSE get_estimation_date;

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
            -- Delete all security restriction for this contract.
            FOR l_access_rec IN get_access_level(p_chr_id) LOOP
                cacv_rec.id := l_access_rec.id;
                OKC_CONTRACT_PUB.delete_contract_access(p_api_version    => l_api_version,
                                                        x_return_status  => l_return_status,
                                                        x_msg_count      => l_msg_count,
                                                        x_msg_data       => l_msg_data,
                                                        p_cacv_rec       => cacv_rec);

                IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
            END LOOP;

            IF (l_debug = 'Y') THEN
                okc_debug.log('1030: After Deleting security restriction');
            END IF;
            -- Update all the lines with the same start date and end date.
            FOR l_line_rec IN get_contract_lines_csr(p_chr_id)
            LOOP
                   UPDATE_LINE_DETAILS(p_cle_id       => l_line_rec.id,
                                      p_start_date    => p_start_date,
                                      p_end_date      => p_end_date,
                                      p_lse_id        => l_line_rec.lse_id,
                                      x_msg_count     => l_msg_count,
			              x_msg_data      => l_msg_data,
                                      x_return_status => l_return_status );

            IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            END LOOP;

            IF (l_debug = 'Y') THEN
                okc_debug.log('1040: Completed Line Updates');
            END IF;

       ELSE

             IF (l_debug = 'Y') THEN
                okc_debug.log('1050: End Date is NULL');
             END IF;
             -- Need to derive the end date based on template start date and UI start date

                 OKC_TIME_UTIL_PUB.get_duration(p_start_date    => l_hdr_start_date, -- Template Hdr Start Date
                                                p_end_date      => l_hdr_end_date,
                                                x_duration      => l_hdr_duration,
                                                x_timeunit      => l_hdr_timeunit,
                                                x_return_status => l_return_status);

             IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
               RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;

             IF (l_debug = 'Y') THEN
                okc_debug.log('1060: after OKC_TIME_UTIL_PUB.get_duration Call');
             END IF;
             -- Get the new end date for header
             l_hdr_end_date := OKC_TIME_UTIL_PUB.get_enddate(p_start_date  => p_start_date,
                                                             p_timeunit    => l_hdr_timeunit,
                                                             p_duration    => l_hdr_duration);
             IF (l_debug = 'Y') THEN
                okc_debug.log('1065: after OKC_TIME_UTIL_PUB.get_end date Call'||l_hdr_end_date);
             END IF;


             l_chrv_rec.id           := p_chr_id;
             l_chrv_rec.start_date   := p_start_date;
             l_chrv_rec.end_date     := l_hdr_end_date;

             OKC_CONTRACT_PUB.update_contract_header(p_api_version   => l_api_version,
                                                     x_return_status => l_return_status,
                                                     x_msg_count     => l_msg_count,
                                                     x_msg_data      => l_msg_data,
                                                     p_chrv_rec      => l_chrv_rec,
                                                     x_chrv_rec      => x_chrv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            IF (l_debug = 'Y') THEN
                okc_debug.log('1070: Completed header update ' || l_return_status );
            END IF;

	    -- Delete Header billing schedule bug# 4188236
	    DELETE FROM OKS_LEVEL_ELEMENTS
	    WHERE RUL_ID IN
	    (SELECT SLL.ID
	     FROM OKS_STREAM_LEVELS_B SLL
	     WHERE SLL.DNZ_CHR_ID=P_CHR_ID and CLE_ID IS NULL);

            DELETE FROM OKS_STREAM_LEVELS_B
	    WHERE DNZ_CHR_ID = P_CHR_ID and CLE_ID IS NULL;

            -- bug fix 4188236

             -- Check for Revenue estimation date
            OPEN  get_estimation_date(p_chr_id);
            FETCH get_estimation_date INTO l_est_id,l_est_obj_num, l_est_date_s;
            IF (get_estimation_date%FOUND) THEN
	        l_khrv_tbl_in(1).id := l_est_id;
                l_khrv_tbl_in(1).chr_id := p_chr_id;
                --npalepu modified on 31-jan-2006 for bug # 5621746
                /* l_khrv_tbl_in(1).object_version_number := p_chr_id; */
                l_khrv_tbl_in(1).object_version_number := l_est_obj_num;
                --end npalepu
                IF l_est_date_s IS NOT NULL THEN
                   l_est_date := l_est_date_s;

                   -- Get the duratio b/n header start date and Line start date
                   IF ( TRUNC(l_est_date) <=  TRUNC(l_hdr_start_date) ) THEN
                      l_khrv_tbl_in(1).est_rev_date := p_start_date;
                   ELSE
                       OKC_TIME_UTIL_PUB.get_duration(p_start_date    => l_hdr_start_date,
                                                      p_end_date      => l_est_date -1,
                                                      x_duration      => l_hdr_est_duration,
                                                      x_timeunit      => l_hdr_est_timeunit,
                                                      x_return_status => l_return_status);

                       -- Get the line start date based on new start date
                       l_start_date := OKC_TIME_UTIL_PUB.get_enddate(p_start_date  => p_start_date + 1,
                                                                     p_timeunit    => l_hdr_est_timeunit,
                                                                     p_duration    => l_hdr_est_duration);
                        l_khrv_tbl_in(1).est_rev_date:= l_start_date;
                   END IF;

		   OKS_CONTRACT_HDR_PUB.update_header
                           (
                            p_api_version 	=> 1,
                            p_init_msg_list	=> 'F',
                            x_return_status	=> l_return_status,
                            x_msg_count	        => l_msg_count,
                            x_msg_data		=> l_msg_data,
                            p_khrv_tbl		=> l_khrv_tbl_in,
                            x_khrv_tbl		=> l_khrv_tbl_out,
                            p_validate_yn       => 'N');



                   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                   END IF;
		   l_khrv_tbl_in.delete;

                END IF;
            END IF;
            CLOSE get_estimation_date;



            -- Delete all security restrictions for this contract.
            FOR l_access_rec IN get_access_level(p_chr_id) LOOP
                cacv_rec.id := l_access_rec.id;
                OKC_CONTRACT_PUB.delete_contract_access(p_api_version    => l_api_version,
                                                        x_return_status  => l_return_status,
                                                        x_msg_count      => l_msg_count,
                                                        x_msg_data       => l_msg_data,
                                                        p_cacv_rec       => cacv_rec);

            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

            IF (l_debug = 'Y') THEN
                okc_debug.log('1080: After contract access delete');
            END IF;

            END LOOP;

            -- Update the line details. Get the offset for each line based on template start date and UI start date.

            FOR line_rec IN get_contract_lines_csr(p_chr_id)
            LOOP

               -- Get the line duration
               OKC_TIME_UTIL_PUB.get_duration(p_start_date    => line_rec.start_date,
                                              p_end_date      => line_rec.end_date,
                                              x_duration      => l_line_duration,
                                              x_timeunit      => l_line_timeunit,
                                              x_return_status => l_return_status);

               IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                   RAISE G_EXCEPTION_HALT_VALIDATION;
               END IF;

               IF (l_debug = 'Y') THEN
                   okc_debug.log('1090: After contract access delete');
               END IF;


               IF ( TRUNC(l_hdr_start_date) <> TRUNC(line_rec.start_date)) THEN

                       IF (l_debug = 'Y') THEN
                           okc_debug.log('1100: Line start date and hdr date is different. '|| line_rec.id);
                        END IF;

                       -- Get the duratio b/n header start date and Line start date
                         OKC_TIME_UTIL_PUB.get_duration(p_start_date    => l_hdr_start_date,
                                                        p_end_date      => line_rec.start_date-1,
                                                        x_duration      => l_hdr_line_duration,
                                                        x_timeunit      => l_hdr_line_timeunit,
                                                        x_return_status => l_return_status);

                         -- Get the line start date based on new start date
                       l_start_date := OKC_TIME_UTIL_PUB.get_enddate(p_start_date  => p_start_date + 1,
                                                                     p_timeunit    => l_hdr_line_timeunit,
                                                                     p_duration    => l_hdr_line_duration);

                       l_end_date := OKC_TIME_UTIL_PUB.get_enddate(p_start_date  => l_start_date,
                                                                   p_timeunit    => l_line_timeunit,
                                                                   p_duration    => l_line_duration);

               ELSE
                  IF (l_debug = 'Y') THEN
                           okc_debug.log('1110: Line start date and hdr start date is same. '|| line_rec.id);
                  END IF;
                  l_start_date :=  p_start_date;
                  l_end_date   :=  OKC_TIME_UTIL_PUB.get_enddate(p_start_date  => l_start_date,
                                                                 p_timeunit    => l_line_timeunit,
                                                                 p_duration    => l_line_duration);
               END IF;

               UPDATE_LINE_DETAILS(p_cle_id        => line_rec.id,
                                   p_start_date    => l_start_date,
                                   p_end_date      => l_end_date,
                                   p_lse_id        => line_rec.lse_id,
                                   x_msg_count     => l_msg_count,
			           x_msg_data      => l_msg_data,
                                   x_return_status => l_return_status );

              IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                  RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;

            END LOOP;

            IF (l_debug = 'Y') THEN
               okc_debug.log('1120: Completed Line update');
            END IF;


       END IF;

       -- Call Pricing API to reprice.


       qp_rec.chr_id := p_chr_id;
       qp_rec.intent := 'HP';

       IF (l_debug = 'Y') THEN
          okc_debug.log('1185: Before QP Call: Hdr ID: ' || p_chr_id);
       END IF;
       OKS_QP_INT_PVT.COMPUTE_PRICE( p_api_version          => l_api_version,
                                     p_init_msg_list        => l_init_msg_list,
                                     p_detail_rec           => qp_rec,
                                     x_price_details        => price_details_rec,
                                     x_modifier_details     => modifier_det_tbl,
                                     x_price_break_details  => price_break_det_tbl,
                                     x_return_status        => l_return_status,
                                     x_msg_count            => l_msg_count,
                                     x_msg_data             => l_msg_data);

        IF (l_debug = 'Y') THEN
          okc_debug.log('1190: After QP Call ' || l_return_status);
        END IF;

        IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        --npalepu added on 27-FEB-2007 for bug # 5671352
        --updating top lines tax amounts
        l_topline_count := 0;

        FOR topline_rec IN topline_csr(p_chr_id)
        LOOP
            IF topline_rec.lse_id <> 46 THEN
                l_topline_count := l_topline_count + 1 ;

                OPEN Get_oks_Lines_details(topline_rec.id);
                FETCH Get_oks_Lines_details INTO l_get_oks_details ;
                CLOSE Get_oks_Lines_details;

                OPEN toplinetax_cur(topline_rec.id);
                FETCH toplinetax_cur INTO l_tax_amount;
                CLOSE toplinetax_cur;

                l_klnv_tax_tbl_in(l_topline_count).id := l_get_oks_details.id ;
                l_klnv_tax_tbl_in(l_topline_count).object_version_number := l_get_oks_details.object_version_number;
                l_klnv_tax_tbl_in(l_topline_count).dnz_chr_id := l_get_oks_details.dnz_chr_id;
                l_klnv_tax_tbl_in(l_topline_count).cle_id := topline_rec.id;
                l_klnv_tax_tbl_in(l_topline_count).tax_amount := l_tax_amount.amount;
            END IF;
        END LOOP;

        oks_contract_line_pub.update_line
        (
         p_api_version => l_api_version,
         p_init_msg_list => l_init_msg_list,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data,
         p_klnv_tbl => l_klnv_tax_tbl_in,
         x_klnv_tbl => l_klnv_tax_tbl_out,
         p_validate_yn => 'N'
        );

        x_return_status := l_return_status;
        IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        --updating contract header tax amount
        OPEN get_header_details;
        FETCH get_header_details INTO l_get_hdr_details;
        CLOSE get_header_details;

        OPEN hdrtax_cur;
        FETCH hdrtax_cur INTO l_total_tax;
        CLOSE hdrtax_cur;

        l_khrv_tax_tbl_in(1).id := l_get_hdr_details.id;
        l_khrv_tax_tbl_in(1).chr_id := p_chr_id;
        l_khrv_tax_tbl_in(1).object_version_number := l_get_hdr_details.object_version_number;
        l_khrv_tax_tbl_in(1).tax_amount := l_total_tax.amount;

        oks_contract_hdr_pub.update_header(
                                           p_api_version => l_api_version,
                                           p_init_msg_list => l_init_msg_list,
                                           x_return_status => l_return_status,
                                           x_msg_count => l_msg_count,
                                           x_msg_data => l_msg_data,
                                           p_khrv_tbl => l_khrv_tax_tbl_in,
                                           x_khrv_tbl => l_khrv_tax_tbl_out,
                                           p_validate_yn => 'N');

        x_return_status := l_return_status;
        IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        --end 5671352

       -- Call Billing Schedule API (Should create one time billing).

      /**********  Start Billing *************************************************/
      IF (
	     (l_SrcContractPPSetupExists_YN = 'Y') OR
	     (l_SrcContractPPSetupExists_YN = 'N' and l_GCDPPSetupExists_YN = 'N')
	    ) THEN --Partial Period Uptake check


       FOR topline_rec IN topline_csr(p_chr_id)
       LOOP

       l_invoice_rule_id := topline_rec.inv_rule_id;
       OPEN  get_billing_type_csr(topline_rec.id);
       FETCH get_billing_type_csr INTO l_billing_type;
       CLOSE get_billing_type_csr;


       OPEN  get_arl_csr(topline_rec.id);
       FETCH get_arl_csr INTO l_klnv_id,l_line_acct_rule,l_obj_num;
       CLOSE get_arl_csr;

        -- Get Accounting rule from Hdr
         IF (l_line_acct_rule IS NULL) THEN
             l_arl_exist_flag := 'N';
             OPEN  get_hdr_arl_csr(topline_rec.id);
             FETCH get_hdr_arl_csr INTO l_line_acct_rule;
             CLOSE get_hdr_arl_csr;
         END IF;

         IF (l_debug = 'Y') THEN
             okc_debug.log('1190: Billing Type ' || l_billing_type);
             okc_debug.log('1191: Invoice rule id  ' || l_invoice_rule_id);
         END IF;

         -- Delete SLL and level elements.

         OKS_BILL_SCH.Del_Rul_Elements(p_top_line_id   => topline_rec.id,
                                       x_return_status => l_return_status,
                                       x_msg_count     => l_msg_count,
                                       x_msg_data      => l_msg_data);

         IF (l_debug = 'Y') THEN
             okc_debug.log('1200: After deleting SLL ' || l_return_status);
         END IF;

         IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

         -- l_timevalue_id := Create_Timevalue(topline_rec.start_date,topline_rec.dnz_chr_id);


         --slh
         --npalepu modified the code on 18-may-2006 for bug # 5211482
   /*    l_slh_rec.chr_id                           := topline_rec.dnz_chr_id;
         l_slh_rec.cle_id                           := topline_rec.id;
         l_slh_rec.rule_information1                := l_billing_type;
         l_slh_rec.rule_information_category        := 'SLH';
         l_slh_rec.object1_id1                      := '1';
         l_slh_rec.object1_id2                      := '#';
         l_slh_rec.object2_id1                      := l_timevalue_id;
         l_slh_rec.object2_id2                      := '#';
         l_slh_rec.jtot_object1_code                := 'OKS_STRM_TYPE';
         l_slh_rec.jtot_object2_code                := 'OKS_TIMEVAL';
       --l_slh_rec.rule_information_category        := 'SLH';

    --sll
         OKC_TIME_UTIL_PUB.get_duration(p_start_date  => topline_rec.start_date
                                        , p_end_date  => topline_rec.end_date
                                        , x_duration  => l_duration
                                        , x_timeunit  => l_timeunit
                                        , x_return_status => x_return_status);

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

         l_sll_tbl(1).cle_id                        := topline_rec.id;
         l_sll_tbl(1).dnz_chr_id                    := topline_rec.dnz_chr_id;
         l_sll_tbl(1).sequence_no                   :='1';
         l_sll_tbl(1).start_date                    := topline_rec.start_date;
         l_sll_tbl(1).level_periods                 := '1';
         l_sll_tbl(1).uom_per_period                := l_duration;
         l_sll_tbl(1).level_amount                  := NULL;
         l_sll_tbl(1).invoice_offset_days           := NULL;
         l_sll_tbl(1).interface_offset_days         := NULL;
         l_sll_tbl(1).uom_code                      := l_timeunit;


         IF l_billing_type IS NULL THEN
           IF topline_rec.lse_id = '46'
           THEN
              l_billing_type := 'E';
           ELSE
              l_billing_type := 'T';
           END IF;
         END IF;


         -- Create new billing schedule..
         OKS_BILL_SCH.Create_Bill_Sch_Rules
             (p_billing_type    => l_billing_type,
              p_sll_tbl         => l_sll_tbl,
              p_invoice_rule_id => l_invoice_rule_id,
              x_bil_sch_out_tbl => l_bil_sch_out_tbl,
              x_return_status   => l_return_status
             );

         IF (l_debug = 'Y') THEN
             okc_debug.log('1210: After Creating Billing Schedule ' || l_return_status);
         END IF;

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
             RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;  */

         --check for template duration and new contract duration or matching or not
         oks_copy_contract_pvt.chk_line_effectivity(topline_rec.id,l_duration_match, x_return_status);

         IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

         IF l_duration_match = 'T' THEN
                OPEN GetStreamsForSourceLine(topline_rec.ORIG_SYSTEM_ID1);
                FETCH GetStreamsForSourceLine BULK COLLECT INTO l_SrcLnStreams_Tbl;
                IF l_SrcLnStreams_Tbl.COUNT > 0 then
                        l_SrcLnStreams_Exists_YN := 'Y';
                ELSE
                        l_SrcLnStreams_Exists_YN := 'N';
                END IF;
                CLOSE GetStreamsForSourceLine;

                IF l_SrcLnStreams_Exists_YN = 'Y' THEN
                        --Resetting PLSQL table for populating line streams--
                        l_LineStreams_tbl.DELETE;
                        l_LineStreams_tbl_Ctr := 0;
                        --Generate Schedule for Top Line using Header Streams--
                        BEGIN --Begin of looping through l_TrgHdrStreams_Tbl
                                FOR j IN l_SrcLnStreams_Tbl.FIRST..l_SrcLnStreams_Tbl.LAST LOOP --4)
                                        l_LineStreams_tbl_Ctr := l_LineStreams_tbl_Ctr + 1;


                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).id := FND_API.g_miss_num;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).chr_id := FND_API.g_miss_num;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).cle_id := topline_rec.id;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).dnz_chr_id := P_Chr_ID;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).sequence_no := l_SrcLnStreams_Tbl(j).sequence_no;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).uom_code := l_SrcLnStreams_Tbl(j).uom_code;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).start_date := topline_rec.start_date;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).end_date := topline_rec.end_date;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).level_periods := l_SrcLnStreams_Tbl(j).level_periods;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).uom_per_period := l_SrcLnStreams_Tbl(j).uom_per_period;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).advance_periods := l_SrcLnStreams_Tbl(j).advance_periods;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).level_amount := l_SrcLnStreams_Tbl(j).level_amount;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).invoice_offset_days := l_SrcLnStreams_Tbl(j).invoice_offset_days;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).interface_offset_days := l_SrcLnStreams_Tbl(j).interface_offset_days;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).comments := l_SrcLnStreams_Tbl(j).comments;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).due_arr_yn := l_SrcLnStreams_Tbl(j).due_arr_yn;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).amount := l_SrcLnStreams_Tbl(j).amount;
                                        l_LineStreams_tbl(l_LineStreams_tbl_Ctr).lines_detailed_yn := l_SrcLnStreams_Tbl(j).lines_detailed_yn;
                                END LOOP; --End LOOP for looping through Target header Streams PLSQL table
                        EXCEPTION
                        WHEN OTHERS THEN
                                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                                RAISE;
                        END; --End of looping through l_TrgHdrStreams_Tbl

                END IF; -- check for l_SrcLnStreams_Exists_YN = 'Y'

                --Generate Billing Schedule for Top Line--
                OKS_BILL_SCH.create_bill_sch_rules(p_billing_type => l_billing_type
                                                  ,p_sll_tbl => l_LineStreams_tbl
                                                  ,p_invoice_rule_id => topline_rec.INV_RULE_ID
                                                  ,x_bil_sch_out_tbl => l_bil_sch_out_tbl
                                                  ,x_return_status => x_return_status);
                IF (l_debug = 'Y') THEN
                        okc_debug.log('1210: After Creating Billing Schedule ' || l_return_status);
                END IF;

                IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

          END IF; -- l_duration_match check
         --end npalepu

         IF (l_arl_exist_flag = 'N') THEN

            l_klnv_tbl_in(1).id	                   := l_klnv_id;
            l_klnv_tbl_in(1).object_version_number := l_obj_num;
            l_klnv_tbl_in(1).cle_id	           := topline_rec.id;
            l_klnv_tbl_in(1).acct_rule_id          := l_line_acct_rule;

            oks_contract_line_pub.update_line
              (p_api_version     => l_api_version,
               p_init_msg_list   => l_init_msg_list,
               x_return_status   => l_return_status,
               x_msg_count	 => x_msg_count,
               x_msg_data        => x_msg_data,
               p_klnv_tbl        => l_klnv_tbl_in,
               x_klnv_tbl        => l_klnv_tbl_out,
	       p_validate_yn     => 'N'
               );

            IF (l_debug = 'Y') THEN
                okc_debug.log('1211: After Creating Accounting rule ' || l_return_status);
            END IF;

         END IF;

         IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
             RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

         -- Reset the flags.
         l_arl_exist_flag  := 'Y';
         l_line_acct_rule  := NULL;
         l_hdr_acct_rule   := NULL;

      END LOOP;

      IF (l_debug = 'Y') THEN
             okc_debug.log('1220: Exiting UPDATE_TEMPLATE_CONTRACT' || to_char(sysdate,'HH:MI:SS'));
             okc_debug.Reset_Indentation;
      END IF;

    --Partial Period Uptake changes
    ELSIF (l_SrcContractPPSetupExists_YN = 'N' AND l_GCDPPSetupExists_YN = 'Y') THEN
      --npalepu added on 24-may-2006 for bug # 5211482
       FOR topline_rec IN topline_csr(p_chr_id)
       LOOP
         -- Delete SLL and level elements.
           OKS_BILL_SCH.Del_Rul_Elements(p_top_line_id   => topline_rec.id,
                                       x_return_status => l_return_status,
                                       x_msg_count     => l_msg_count,
                                       x_msg_data      => l_msg_data);

           IF  (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              RAISE G_EXCEPTION_HALT_VALIDATION;
           END IF;
       END LOOP;
      --end npalepu
      OKS_COPY_CONTRACT_PVT.create_bsch_using_PPSetup(P_To_Chr_ID        => p_chr_id
	                                                ,P_From_Chr_ID      => P_From_Chr_ID
                                                     ,P_Partial_Copy_YN  => 'N'
                                                     ,p_init_msg_list    => l_init_msg_list
                             			             ,x_return_status    => l_return_status
                             			             ,x_msg_count        => x_msg_count
                                                     ,x_msg_data         => x_msg_data);

    END IF;
       /**********  End Billing *************************************************/

      x_return_status := l_return_status;


       EXCEPTION

         WHEN G_EXCEPTION_HALT_VALIDATION THEN
                x_return_status := l_return_status;
               IF  get_estimation_date%ISOPEN THEN
                   CLOSE get_estimation_date;
               END IF;
               IF (l_debug = 'Y') THEN
                   okc_debug.log('1230: Exception: Return Status ' || x_return_status);
                   okc_debug.Reset_Indentation;
               END IF;

         WHEN OTHERS THEN
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
              IF  get_estimation_date%ISOPEN THEN
                   CLOSE get_estimation_date;
              END IF;
              IF (l_debug = 'Y') THEN
                   okc_debug.log('1230: Unexpected Error');
                   okc_debug.Reset_Indentation;
              END IF;
              OKC_API.set_message
              (G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);

 END  UPDATE_TEMPLATE_CONTRACT ;

END OKC_COPY_CONTRACT_PVT;

/
