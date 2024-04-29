--------------------------------------------------------
--  DDL for Package Body IGI_CIS_IGIPMTHP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_CIS_IGIPMTHP_PKG" AS
-- $Header: igipmthpb.pls 120.1.12010000.5 2012/09/18 20:32:52 sasukuma ship $
-- $Header: igipmthpb.pls 120.1.12010000.5 2012/09/18 20:32:52 sasukuma ship $

  --==========================================================================
  ----Logging Declarations
  --==========================================================================
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER     :=  FND_LOG.LEVEL_PROCEDURE;
  C_EVENT_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EVENT;
  C_EXCEP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_EXCEPTION;
  C_ERROR_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_ERROR;
  C_UNEXP_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_UNEXPECTED;
  g_log_level   CONSTANT NUMBER      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_path_name   CONSTANT VARCHAR2(100)  := 'igi.plsql.igipmthpb.igi_cis_igipmthp_pkg';

  PROCEDURE log
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS

  BEGIN
    IF (p_level >= g_log_level ) THEN
      FND_LOG.STRING(p_level, p_procedure_name, p_debug_info);
    END IF;
  END log;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    log(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    log(C_STATE_LEVEL, l_procedure_name, '$Header: igipmthpb.pls 120.1.12010000.5 2012/09/18 20:32:52 sasukuma ship $');
  END;

  FUNCTION BeforeReport RETURN BOOLEAN IS
     l_procedure_name         VARCHAR2(100):='.BeforeReport';
     SINGLE_QUOTE constant varchar2(3) := '''';
     TWO_SINGLE_QUOTE constant varchar2(6) := '''''';
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    log(C_STATE_LEVEL, l_procedure_name, 'p_supplier_from='||p_supplier_from);
    log(C_STATE_LEVEL, l_procedure_name, 'p_supplier_to='||p_supplier_to);
    log(C_STATE_LEVEL, l_procedure_name, 'p_period='||p_period);
    log(C_STATE_LEVEL, l_procedure_name, 'p_mode='||p_mode);
    log(C_STATE_LEVEL, l_procedure_name, 'p_sort_by='||p_sort_by);
    log(C_STATE_LEVEL, l_procedure_name, 'p_report_lev='||p_report_lev);
    log(C_STATE_LEVEL, l_procedure_name, 'p_amt_type='||p_amt_type);
      pwhereclause := ' ';
      tableclause := ' ';

      --bug 6124461 AP_SUPPLIERS table has been included in the query
      IF (p_supplier_from IS NOT NULL) THEN
         tableclause := 'AP_SUPPLIERS po_ven,';
         pwhereclause  := pwhereclause || ' and lines.vendor_id = po_ven.vendor_id and po_ven.vendor_name >=  ''' || replace(p_supplier_from, SINGLE_QUOTE, TWO_SINGLE_QUOTE) || '''';
      END IF;

      IF (p_supplier_to IS NOT NULL) THEN
         IF (p_supplier_from IS NOT NULL) THEN
            pwhereclause  := pwhereclause || ' and po_ven.vendor_name <= ''' || replace(p_supplier_to, SINGLE_QUOTE, TWO_SINGLE_QUOTE) || '''';
          ELSE
            tableclause := 'AP_SUPPLIERS po_ven,';
            pwhereclause  := pwhereclause || ' and lines.vendor_id = po_ven.vendor_id and po_ven.vendor_name <= ''' || replace(p_supplier_to, SINGLE_QUOTE, TWO_SINGLE_QUOTE) || '''';
          END IF;
      END IF;
      --end bug 6124461
      --Bug 5933093 start
      IF (p_period IS NOT NULL ) THEN
         pwhereclause := pwhereclause || ' AND hdr.period_name = ''' || p_period || '''';
         IF p_mode = 'P' THEN
            pwhereclause := pwhereclause || ' AND hdr.header_id = (select max(header_id) from IGI_CIS_MTH_RET_HDR_T where period_name = ''' || p_period || '''';
            pwhereclause := pwhereclause || ' AND request_status_code = ''P'')';
         ELSE
            pwhereclause := pwhereclause || ' AND hdr.header_id = (select max(header_id) from IGI_CIS_MTH_RET_HDR_H where period_name = ''' || p_period || '''';
            pwhereclause := pwhereclause || ' AND request_status_code = ''C'')';
         END IF;
      END IF ;
      --Bug 5933093 end

      IF p_mode = 'P' THEN
         pwhereclause := pwhereclause || ' AND request_status_code = ''P''';
         tableclause  := tableclause||' IGI_CIS_MTH_RET_HDR_T hdr, IGI_CIS_MTH_RET_LINES_T lines, IGI_CIS_MTH_RET_PAY_T pay ';
      ELSE
         pwhereclause := pwhereclause || ' AND request_status_code = ''C''';
         tableclause  := tableclause||' IGI_CIS_MTH_RET_HDR_H hdr, IGI_CIS_MTH_RET_LINES_H lines, IGI_CIS_MTH_RET_PAY_H pay ';
      END IF ;

      IF (p_sort_by IS NOT NULL ) THEN
         IF p_sort_by = 'VENDOR_NAME' Then
            orderbyclause := ' ORDER BY ' || p_sort_by;
         ELSE
            orderbyclause := ' ORDER BY ' || p_sort_by || ', lines.vendor_name';
         END IF;
      ELSE
         orderbyclause := ' ORDER BY lines.vendor_name';
      END IF;
      IF p_report_lev = 'S' then
        partselect := ' '''' invoice_num, ';
        partgroupby := ' ';
      Elsif p_report_lev ='D' then
        partselect := 'nvl((select invoice_num from ap_invoices where pay.invoice_id = invoice_id),'''') invoice_num, ';
        partgroupby := ',pay.invoice_id ';
      End if;

      --ER6137652 Start
      IF nvl(p_amt_type,'P') = 'P' THEN
         pwhereclause := pwhereclause ||' and ((nvl(lines.total_payments,0) + nvl(lines.total_deductions,0)) >=0 and
                           nvl(lines.material_cost,0) >= 0 and
                           nvl(lines.labour_cost,0) >= 0 and
                           nvl(lines.total_deductions,0) >= 0) ';
      ELSIF nvl(p_amt_type,'P') = 'N' THEN
         pwhereclause := pwhereclause || ' and ((nvl(lines.total_payments,0) + nvl(lines.total_deductions,0)) < 0 or
                           nvl(lines.material_cost,0) < 0 or
                           nvl(lines.labour_cost,0) < 0 or
                           nvl(lines.total_deductions,0) < 0) ';
      END IF;
      --ER6137652 End

      -- for debugging
      FND_FILE.PUT_LINE(FND_FILE.LOG,'p_mode to trigger: ' || p_mode);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'where clause:' || pwhereclause);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'orderby clause:' || orderbyclause);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'partselect :' || partselect);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'partgroupby:' || partgroupby);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'amount type:' || p_amt_type);

    log(C_STATE_LEVEL, l_procedure_name, 'pwhereclause='||pwhereclause);
    log(C_STATE_LEVEL, l_procedure_name, 'orderbyclause='||orderbyclause);
    log(C_STATE_LEVEL, l_procedure_name, 'partselect='||partselect);
    log(C_STATE_LEVEL, l_procedure_name, 'partgroupby='||partgroupby);
    log(C_STATE_LEVEL, l_procedure_name, 'END');
      RETURN(TRUE);
  END BeforeReport;

  FUNCTION AfterReport RETURN BOOLEAN IS
    l_procedure_name         VARCHAR2(100):='.AfterReport';
    l_header_id number := 0;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    log(C_STATE_LEVEL, l_procedure_name, 'p_mode='||p_mode);
    log(C_STATE_LEVEL, l_procedure_name, 'p_del_preview='||p_del_preview);
    IF p_mode = 'P' and p_del_preview = 'Y' THEN
      Select max(header_id) --Bug 5933093
      into l_header_id
      from igi_cis_mth_ret_hdr_t
      where period_name = p_period
      and request_status_code = 'P';
      log(C_STATE_LEVEL, l_procedure_name, 'l_header_id='||l_header_id);
      delete from igi_cis_mth_ret_hdr_t where header_id = l_header_id;
      log(C_STATE_LEVEL, l_procedure_name, 'Deleted '||SQL%ROWCOUNT||' rows from igi_cis_mth_ret_hdr_t');
      delete from igi_cis_mth_ret_lines_t where header_id = l_header_id;
      log(C_STATE_LEVEL, l_procedure_name, 'Deleted '||SQL%ROWCOUNT||' rows from igi_cis_mth_ret_lines_t');
      delete from igi_cis_mth_ret_pay_t where header_id = l_header_id;
      log(C_STATE_LEVEL, l_procedure_name, 'Deleted '||SQL%ROWCOUNT||' rows from igi_cis_mth_ret_pay_t');
      commit;
    END IF;
    log(C_STATE_LEVEL, l_procedure_name, 'END');
    RETURN(TRUE);
  END AfterReport;

  FUNCTION get_p_supplier_from RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_p_supplier_from';
  BEGIN
        RETURN (p_supplier_from);
  END get_p_supplier_from;


  FUNCTION get_p_supplier_to RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_p_supplier_to';
  BEGIN
        RETURN (p_supplier_to);
  END get_p_supplier_to;

  FUNCTION get_p_rep_mode RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_p_rep_mode';
  BEGIN
        RETURN(p_report_lev);
  END get_p_rep_mode;

  FUNCTION get_period_start_date RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_period_start_date';
      l_period_type ap_other_periods.period_type%TYPE;
      l_start_date    ap_other_periods.start_date%TYPE;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
     l_period_type := fnd_profile.value('IGI_CIS2007_CALENDAR');

     SELECT start_date
       INTO l_start_date
       FROM ap_other_periods
      WHERE period_type = l_period_type
        AND period_name = p_period;

    log(C_STATE_LEVEL, l_procedure_name, 'END');
     RETURN(l_start_date);
  EXCEPTION
      WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
        RETURN(NULL);
  END get_period_start_date;


  FUNCTION get_period_end_date RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_period_end_date';
            l_period_type ap_other_periods.period_type%TYPE;
            l_end_date    ap_other_periods.start_date%TYPE;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
     l_period_type := fnd_profile.value('IGI_CIS2007_CALENDAR');

     SELECT end_date
       INTO l_end_date
       FROM ap_other_periods
      WHERE period_type = l_period_type
        AND period_name = p_period;

    log(C_STATE_LEVEL, l_procedure_name, 'END');
      RETURN (l_end_date);
  EXCEPTION
     WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
       RETURN(NULL);
  END get_period_end_date;


  FUNCTION get_print_type RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_print_type';
          l_print_type igi_lookups.meaning%TYPE := null;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
     SELECT meaning
       INTO l_print_type
       FROM igi_lookups
      WHERE lookup_type = 'IGI_CIS2007_PRINT_TYPES'
        AND lookup_code = p_print_type;

    log(C_STATE_LEVEL, l_procedure_name, 'END');
     RETURN (l_print_type);
  EXCEPTION
     WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
        RETURN(NULL);
  END get_print_type;


  FUNCTION get_org_name RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_org_name';
      l_org_id  hr_operating_units.organization_id%TYPE   := NULL ;
      l_org_name hr_operating_units.name%TYPE := NULL ;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
  --   l_org_id := fnd_profile.value('ORG_ID');

     l_org_id:=  mo_global.get_current_org_id;
     if(l_org_id is null) then
      l_org_id := fnd_profile.value('ORG_ID');
     end if;

     SELECT name
       INTO l_org_name
       FROM hr_operating_units
      WHERE organization_id = l_org_id;

    log(C_STATE_LEVEL, l_procedure_name, 'END');
     RETURN(l_org_name);
  EXCEPTION
     WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
        RETURN(NULL);
  END get_org_name;

  FUNCTION get_p_sort_by RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_p_sort_by';
      l_sort_by igi_lookups.meaning%TYPE := NULL ;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');

     SELECT meaning
       INTO l_sort_by
       FROM igi_lookups
      WHERE lookup_type='IGI_CIS2007_MTHR_SORT_COLS'
        AND lookup_code=p_sort_by;

    log(C_STATE_LEVEL, l_procedure_name, 'END');
     RETURN(l_sort_by);
  EXCEPTION
     WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
        RETURN(NULL);
  END get_p_sort_by;


  FUNCTION get_p_report_title RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_p_report_title';
      l_report_title igi_lookups.meaning%TYPE := NULL;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
      SELECT meaning
        INTO l_report_title
        FROM igi_lookups
       WHERE lookup_type = 'IGI_CIS2007_NEW_REPORTS'
         AND lookup_code = decode(p_mode||p_report_lev,'PS','IGIPMTPS',
                                                     'PD','IGIPMTPD',
                                                     'FD','IGIPMTRD',
                                                     'FS','IGIPMTRS');
    log(C_STATE_LEVEL, l_procedure_name, 'END');
     RETURN(l_report_title);
  EXCEPTION
      WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
         RETURN(NULL);
  END get_p_report_title;

  FUNCTION get_tax_status(p_awt_group_code IN VARCHAR2) RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_tax_status';
      l_net_group VARCHAR2(10) := NULL;
      l_unmatch_group VARCHAR2(10) := NULL;
      l_gross_group VARCHAR2(10) := NULL;
      l_tax_status VARCHAR2(10) := NULL;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
    l_net_group := fnd_profile.VALUE('IGI_CIS2007_NET_WTH_GROUP');
    l_unmatch_group := fnd_profile.VALUE('IGI_CIS2007_UNMATCHED_WTH_GROUP');
    l_gross_group  := fnd_profile.VALUE('IGI_CIS2007_GROSS_WTH_GROUP');

    SELECT meaning
       INTO l_tax_status
       FROM igi_lookups
       WHERE lookup_type = 'IGI_CIS2007_TAX_STATUS'
       AND lookup_code = decode(nvl(p_awt_group_code,' '),l_gross_group,'G',
                                                 l_net_group,'N',
                                                 l_unmatch_group,'U');
    /*if p_awt_group_code = l_gross_group then
 *       l_tax_status := 'Gross';
 *           Elsif p_awt_group_code = l_net_group then
 *                 l_tax_status := 'Net';
 *                     Elsif p_awt_group_code = l_unmatch_group then
 *                           l_tax_status := 'Unmatched';
 *                               End if; */
    log(C_STATE_LEVEL, l_procedure_name, 'END');
    RETURN(l_tax_status);
  EXCEPTION
    WHEN OTHERS THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
      RETURN(NULL);
  END get_tax_status;

  --Function Added for ER6137652
  FUNCTION get_p_amt_type RETURN VARCHAR2 IS
    l_procedure_name         VARCHAR2(100):='.get_p_amt_type';
      l_amt_type igi_lookups.meaning%TYPE := NULL;
  BEGIN
    l_procedure_name := g_path_name || l_procedure_name;
    log(C_STATE_LEVEL, l_procedure_name, 'BEGIN');
      SELECT meaning
        INTO l_amt_type
        FROM igi_lookups
       WHERE lookup_type = 'IGI_CIS2007_MTH_RET_AMT_TYPE'
         AND lookup_code = nvl(p_amt_type,'P');
    log(C_STATE_LEVEL, l_procedure_name, 'END');
     RETURN(l_amt_type);
  EXCEPTION
      WHEN no_data_found THEN
    log(C_STATE_LEVEL, l_procedure_name, 'EXCEPTION:'||SQLERRM);
         RETURN(NULL);
  END get_p_amt_type;
BEGIN
init;
END igi_cis_igipmthp_pkg ;

/
