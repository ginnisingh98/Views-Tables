--------------------------------------------------------
--  DDL for Package Body AST_OFL_EVENT_ATTENDEES_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_EVENT_ATTENDEES_PARAM" AS
 /* $Header: astrtepb.pls 115.12 2002/02/06 13:11:39 pkm ship   $ */

  TYPE day_table
  IS
    TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;
  TYPE year_table
  IS
    TABLE OF VARCHAR2(2000)
    INDEX BY BINARY_INTEGER;
  g_image_prefix VARCHAR2(250) := '/OA_MEDIA/'||icx_sec.getid(icx_sec.pv_language_code)||'/';
  l_user_id      NUMBER;
  v_date_time    VARCHAR2(30);
  l_agent        VARCHAR2(200);
  ctr1           INTEGER := 0;
  ctr2           INTEGER := 0;
  day_data       day_table;
  year_data      year_table;
----------------------------------------------------------------------------------------------------
  PROCEDURE header
  IS
  BEGIN
    SELECT fnd_date.date_to_chardate(SYSDATE)
      INTO v_date_time
      FROM DUAL;
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Event Attendees Information');
    htp.headClose;
    htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
    htp.tableOpen('border="0"  ');
    htp.tableRowOpen(cAlign => 'TOP');
--    htp.tableData(htf.img(cUrl => g_image_prefix || 'oppty.gif'));
    htp.tableData('<FONT size=+1 face="times new roman">' || 'Event Attendees Report', cNoWrap => 'TRUE');
    htp.tableData(htf.bold(v_date_time), cAlign => 'right', cColSpan => '110');
    htp.tableRowClose;
    htp.tableClose;
    htp.tableOpen(cAttributes => 'border=0 cellspacing=0 cellpadding=0 width=561');
    htp.tableRowOpen(cVAlign => 'top');
    htp.tableData(' ', cColSpan => '2', cAttributes => ' height=9');
    htp.tableData('<FONT face="Times New Roman">' || htf.bold('Please specify the criteria and select OK.  ') || '</FONT>', cAlign => 'center', cRowSpan => '2', cColSpan => '110', cAttributes => ' width=346');
    htp.tableData(' ', cColSpan => '6');
    htp.br;
    htp.tableRowClose;
    htp.tableClose;
    htp.bodyClose;
    htp.headClose;
    htp.htmlClose;
  END;
----------------------------------------------------------------------------------------------------
  PROCEDURE event_attendees_paramform
  IS
/* RN 25/9/00
    CURSOR cur_promotion_code
    IS
      SELECT code, name
      FROM as_promotions_all
      WHERE type = 'E'
      ORDER BY 1;
*/
    day_counter  NUMBER := 1;
    year_counter NUMBER := 1990;
  BEGIN
    FOR i IN 1..31 LOOP
      IF day_counter <= 9  THEN
        day_data(i) := '0' || day_counter;
        day_counter := day_counter + 1;
      ELSE
        day_data(i) := TO_CHAR(day_counter);
        day_counter := day_counter + 1;
      END IF;
    END LOOP;
    FOR i IN 1..21 LOOP
      year_data(i) := TO_CHAR(year_counter);
      year_counter := year_counter + 1;
    END LOOP;
    IF (icx_sec.validateSession) THEN
      header;
      l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
--Returns login user Id
      htp.formOpen(owa_util.Get_Owa_Service_Path || 'ast_ofl_event_attendees_report.report_wrapper', cAttributes => ' NAME="param"');
      htp.htmlOpen;
      htp.headOpen;
      htp.title('Event Attendees Report');
      htp.p('<SCRIPT language="JavaScript">');
      htp.p('window.name = "bigwindow";');
      htp.p('function btn_press()');
      htp.p('{');
      htp.p('winpbook=window.open(''ast_ofl_event_attendees_param.popup_window'',''pbook'', ''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,left=0,top=0,width=650,height=410'');');
      htp.p('winpbook.focus();');
      htp.p('}');
      htp.p('window.name = "bigwindow";');
      htp.p('function btn_press_high()');
      htp.p('{');
      htp.p('winpbook=window.open(''ast_ofl_event_attendees_param.high_popup_window'',''pbook'', ''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,left=0,top=0,width=650,height=410'');');
      htp.p('winpbook.focus();');
      htp.p('}');
      htp.p('  function validateForm(objform) {');
      htp.p('    var s_day = objform.p_sd_date.selectedIndex;');
      htp.p('    var s_month = objform.p_sm_date.selectedIndex;');
      htp.p('    var s_year = objform.p_sy_date.selectedIndex;');
      htp.p('    var e_day = objform.p_ed_date.selectedIndex;');
      htp.p('    var e_month = objform.p_em_date.selectedIndex;');
      htp.p('    var e_year = objform.p_ey_date.selectedIndex;');
      htp.p('    var p_valid = true;');
      htp.p('       if ((s_month == "3"&&s_day== "30")||(s_month == "5"&&s_day== "30")');
      htp.p('          ||(s_month == "8"&&s_day== "30")||(s_month == "10"&&s_day== "30")){');
      htp.p('          alert(''Start Date Must be a Valid Date'');');
      htp.p('          p_valid = false;}');
      htp.p('       if ((e_month == "3"&&e_day== "30")||(e_month == "5"&&e_day== "30")');
      htp.p('          ||(e_month == "8"&&e_day== "30")||(e_month == "10"&&e_day== "30")){');
      htp.p('          alert(''End Date Must be a Valid Date'');');
      htp.p('          p_valid = false;}');
      htp.p('       if (s_month == "1"){');
      htp.p('          if ((s_year == "2"||s_year == "6"||s_year == "10"||s_year == "14"||s_year == "18")');
      htp.p('          && (s_day == "29"||s_day == "30")){');
      htp.p('          alert(''Start Date Must be a Valid Date'');');
      htp.p('          p_valid = false;}');
      htp.p('                           }');
      htp.p('       if (s_month == "1"){');
      htp.p('          if ((s_year != "2" != "6" != "10" != "14" != "18")');
      htp.p('          && (s_day == "28"||s_day == "29"||s_day == "30")){');
      htp.p('          alert(''Start Date Must be a Valid Date'');');
      htp.p('          p_valid = false;}');
      htp.p('                           }');
      htp.p('       if (e_month == "1"){');
      htp.p('          if ((e_year == "2"||e_year == "6"||e_year == "10"||e_year == "14"||e_year == "18")');
      htp.p('          && (e_day == "29"||e_day == "30")){');
      htp.p('          alert(''End Date Must be a Valid Date'');');
      htp.p('          p_valid = false;}');
      htp.p('                           }');
      htp.p('       if (e_month == "1"){');
      htp.p('          if ((e_year != "2" != "6" != "10" != "14" != "18")');
      htp.p('          && (e_day == "28"||e_day == "29"||e_day == "30")){');
      htp.p('          alert(''End Date Must be a Valid Date'');');
      htp.p('          p_valid = false;}');
      htp.p('                           }');
      htp.p('       if (s_year > e_year){');
      htp.p('          alert(''Start Date must be less than End Date'');');
      htp.p('          p_valid = false;}');
      htp.p('       if (s_year == e_year){');
      htp.p('          if (s_month > e_month){');
      htp.p('            alert(''Start Date must be less than End Date'');');
      htp.p('            p_valid = false;}');
      htp.p('          if (s_month == e_month){');
      htp.p('            if (s_day > e_day){');
      htp.p('              alert(''Start Date must be less than End Date'');');
      htp.p('              p_valid = false;}');
      htp.p('                                 }');
      htp.p('                             }');
      htp.p('       if (p_valid){');
      htp.p('          objform.submit();}');
      htp.p('}');
      htp.p('</script>');
      htp.headClose;
      htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
      htp.tableOpen;
      htp.tableRowOpen(cVAlign => 'top');
      htp.tableData(' ', cAttributes => ' height=9');
      htp.tableData('<FONT size=2 face="Times New Roman">' || '</FONT>', cAlign => 'right', cRowSpan => '2', cColSpan => '3', cAttributes => ' width=154');
      htp.tableData(' ');
      htp.tableRowClose;
      htp.tableClose;
      htp.tableOpen(cAttributes => 'width="600" ');
--htp.tableRowOpen();
--htp.p('<td align="RIGHT" width="32%" valign="top">Start Date</td>');
--htp.p('<td>');
--htp.p('<INPUT TYPE= "TEXT", NAME="p_start_date", VALUE="", SIZE="11">');
--htp.p('</td>');
--htp.tableRowClose;
      htp.tableRowClose;
      htp.tableRowOpen();
      htp.p('<td align="RIGHT" width="32%" valign="top">Start Date</td>');
      htp.p('<td>');

/*
	 htp.p('<SELECT name="p_sm_date">');
      FOR i IN 1..12 LOOP
        IF i = 1 THEN
          htp.formSelectOption(LPAD(TO_CHAR(i), 2, '0'), cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'), cSelected => 'TRUE');
        ELSE
          htp.formSelectOption(LPAD(TO_CHAR(i), 2, '0'), cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'));
        END IF;
      END LOOP;
      htp.formSelectClose;
      htp.p('-');
*/
      htp.p('<SELECT name="p_sd_date">');
      FOR i IN 1..day_data.count LOOP
        htp.formSelectOption(day_data(i), cAttributes => ' value= ' || day_data(i), cSelected => 'TRUE');
      END LOOP;
      htp.FormSelectClose;
      htp.p('-');

	 htp.p('<SELECT name="p_sm_date">');
      htp.FormSelectOption('JAN',cselected => 'TRUE');
	 htp.FormSelectOption('FEB');
	 htp.FormSelectOption('MAR');
	 htp.FormSelectOption('APR');
	 htp.FormSelectOption('MAY');
	 htp.FormSelectOption('JUN');
	 htp.FormSelectOption('JUL');
	 htp.FormSelectOption('AUG');
	 htp.FormSelectOption('SEP');
	 htp.FormSelectOption('OCT');
	 htp.FormSelectOption('NOV');
	 htp.FormSelectOption('DEC');
      htp.formSelectClose;
      htp.p('-');

      htp.p('<SELECT name="p_sy_date">');
      FOR i IN 1..year_data.count LOOP
        htp.formSelectOption(year_data(i), cAttributes => ' value= ' || year_data(i));
      END LOOP;
      htp.formSelectClose;
      htp.p('</td>');
      htp.tableRowClose;
      htp.tableRowOpen();
      htp.p('<td align="RIGHT" width="32%" valign="top">End Date</td>');
      htp.p('<td>');
      htp.p('<SELECT name="p_ed_date">');
      FOR i IN 1..day_data.count LOOP
        htp.formSelectOption(day_data(i), cAttributes => ' value= '||day_data(i), cSelected => 'TRUE');
      END LOOP;
      htp.formSelectClose;
      htp.p('-');

/*
      htp.p('<SELECT name="p_em_date">');
      FOR i IN 1..12 LOOP
        IF i = 1 THEN
          htp.formSelectOption(LPAD(TO_CHAR(i), 2, '0'), cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'), cSelected => 'TRUE');
        ELSE
          htp.formSelectOption(LPAD(TO_CHAR(i), 2, '0'), cAttributes => ' value=' || LPAD(TO_CHAR(i), 2, '0'));
        END IF;
      END LOOP;
      htp.formSelectClose;
      htp.p('-');
*/
	 htp.p('<SELECT name="p_em_date">');
      htp.FormSelectOption('JAN',cselected => 'TRUE');
	 htp.FormSelectOption('FEB');
	 htp.FormSelectOption('MAR');
	 htp.FormSelectOption('APR');
	 htp.FormSelectOption('MAY');
	 htp.FormSelectOption('JUN');
	 htp.FormSelectOption('JUL');
	 htp.FormSelectOption('AUG');
	 htp.FormSelectOption('SEP');
	 htp.FormSelectOption('OCT');
	 htp.FormSelectOption('NOV');
	 htp.FormSelectOption('DEC');
      htp.formSelectClose;
      htp.p('-');

      htp.p('<SELECT name="p_ey_date">');
-- htp.formSelectOption('   ');
      FOR i IN 1..year_data.count LOOP
        htp.formSelectOption(year_data(i), cAttributes => ' value= ' || year_data(i), cSelected => 'TRUE');
      END LOOP;
      htp.formSelectClose;
      htp.p('</td>');
      htp.tableRowClose;
      htp.tableRowOpen;
      htp.p('<td align="LEFT" colspan="2"><b>Range of Event Codes:</b></td>');
      htp.tableRowClose;
      htp.tableRowOpen();
      htp.p('<td align="RIGHT" width="32%" valign="top">From Event Code</td>');
      htp.p('<td>');
      htp.formHidden('p_promotion_code_low', NULL, NULL);
      htp.formText('p_low_description', 50, NULL);
      htp.p('<td><A HREF="javascript:btn_press()">LOV</A></td>');
--htp.p('<SELECT name="p_promotion_code_low">');
--htp.formSelectOption('0', cSelected => 'TRUE');
--FOR rec_promotion_code IN cur_promotion_code LOOP
--htp.formSelectOption(rec_promotion_code.code || '   ' || rec_promotion_code.name, cAttributes => ' value= ' || rec_promotion_code.code);
--END LOOP;
--htp.formSelectClose;
      htp.p('</td>');
      htp.tableRowClose;
      htp.tableRowOpen();
      htp.p('<td align="RIGHT" width="32%" valign="top">To Event Code</td>');
      htp.p('<td>');
      htp.formHidden('p_promotion_code_high', NULL, NULL);
      htp.formText('p_high_description', 50, NULL);
      htp.p('<td><A HREF="javascript:btn_press_high()">LOV</A></td>');
--htp.p('<SELECT name="p_promotion_code_High">');
--htp.formSelectOption('9999999', cSelected => 'TRUE');
--FOR rec_promotion_code IN cur_promotion_code LOOP
--htp.formSelectOption(rec_promotion_code.code || '   ' || rec_promotion_code.name ,cAttributes => ' value= ' || rec_promotion_code.code);
--END LOOP;
--htp.formSelectClose;
      htp.p('</td>');
      htp.tableRowClose;
      htp.tableClose;
      htp.br;
      htp.br;
      htp.br;
      footer;
      htp.formClose;
      htp.bodyClose;
      htp.htmlClose;
    ELSE
      htp.p('Invalid session');
    END IF;
  EXCEPTION
    WHEN others THEN
      htp.p(SQLERRM);
  END event_attendees_paramform;
----------------------------------------------------------------------------------------------------
  PROCEDURE popup_window
           (p_event_code          IN VARCHAR2 DEFAULT NULL,
            p_submit              IN VARCHAR2 DEFAULT NULL,
            p_selected_event_code IN VARCHAR2 DEFAULT NULL)
  IS
    CURSOR cur_promotion_code(p_e_c varchar2)
    IS
-- RN 25/9/00
	SELECT event_offer_id code, event_offer_name name
	FROM ams_event_offers_vl
	WHERE event_offer_id LIKE p_e_c
	OR UPPER(event_offer_name) LIKE p_e_c
--      SELECT code, name
--      FROM as_promotions_all
--      WHERE type = 'E'
--      AND (UPPER(CODE) LIKE NVL(UPPER(p_event_code), '%') || '%'
--      OR UPPER(name) LIKE NVL(UPPER(p_event_code), '%') || '%')
	ORDER BY 1;
  BEGIN
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Event Attendees Report - Event Codes');
    htp.p('<SCRIPT language="JavaScript">');
    htp.p('function PassBack(p_low_description,p_promotion_code_low) {');
    htp.p('opener.document.forms[0].p_low_description.value = p_low_description;');
    htp.p('opener.document.forms[0].p_promotion_code_low.value = p_promotion_code_low;');
    htp.p('opener.document.forms[0].p_low_description.focus();');
    htp.p('close();');
    htp.p('}');
    htp.p('</SCRIPT>');
    htp.headClose;
    htp.p('<BODY bgcolor="#CCCCCC">');
    htp.p('<CENTER>');
    htp.bold('<font size="+1">Search Events</font>');
    htp.formOpen('ast_ofl_event_attendees_param.popup_window', 'POST');
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData('Event Code: ');
--    htp.tableData(htf.formText('p_event_code', NULL, NULL, NVL(p_event_code, '%')));
    htp.tableData(htf.formText('p_event_code', NULL, NULL, p_event_code));
    htp.tableRowClose;
    htp.tableClose;
    htp.nl;
    htp.formSubmit('p_submit', 'Search Events');
    htp.formClose;
    htp.tableOpen;
    if p_event_code is NULL then
	 htp.tableRowOpen;
	 --htp.p('<td><i>Enter ''%'' to search for all events.</i></td>');
	 htp.p('<td><i>Enter the first few characters of the Event Code or Event Name</i></td>');
	 htp.tableRowClose;
	 htp.tableRowOpen;
	 htp.p('<td><i>to search by (wildcards such as _ and % are supported)</i></td>');
	 htp.tableRowClose;
    else
--    FOR c_rec IN cur_promotion_code(nvl(p_event_code,'') || '%') LOOP
    FOR c_rec IN cur_promotion_code(upper(p_event_code) || '%') LOOP
      htp.tableRowOpen;
      htp.p('<td><A HREF="javascript:PassBack(''' || c_rec.code || ' ' || c_rec.name || ''',''' || c_rec.code || ''')">' || c_rec.code || '   ' || c_rec.name || '</A></td>');
      htp.tableRowClose;
    END LOOP;
    end if;
    htp.tableClose;
    htp.p('</CENTER>');
    htp.bodyClose;
    htp.htmlClose;
  END popup_window;
----------------------------------------------------------------------------------------------------
  PROCEDURE high_popup_window
           (p_event_code          IN VARCHAR2 DEFAULT NULL,
            p_submit              IN VARCHAR2 DEFAULT NULL,
            p_selected_event_code IN VARCHAR2 DEFAULT NULL)
  IS
    CURSOR cur_promotion_code(p_e_c varchar2)
    IS
-- RN 25/9/00
	SELECT event_offer_id code, event_offer_name name
	FROM ams_event_offers_vl
	WHERE event_offer_id LIKE p_e_c
	OR UPPER(event_offer_name) LIKE p_e_c
--      SELECT code, name
--      FROM as_promotions_all
--      WHERE type = 'E'
--      AND (UPPER(code) LIKE NVL(UPPER(p_event_code), '%') || '%'
--      OR UPPER(name) LIKE NVL(UPPER(p_event_code), '%') || '%')
	ORDER BY 1;
  BEGIN
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Event Attendees Report - Event Codes');
    htp.p('<SCRIPT language="JavaScript">');
    htp.p('function PassBack(p_high_description,p_promotion_code_high) {');
    htp.p('opener.document.forms[0].p_high_description.value = p_high_description;');
    htp.p('opener.document.forms[0].p_promotion_code_high.value = p_promotion_code_high;');
    htp.p('opener.document.forms[0].p_high_description.focus();');
    htp.p('close();');
    htp.p('}');
    htp.p('</SCRIPT>');
    htp.headClose;
    htp.p('<BODY bgcolor="#CCCCCC">');
    htp.p('<CENTER>');
    htp.bold('<font size="+1">Search Events</font>');
    htp.formOpen('ast_ofl_event_attendees_param.high_popup_window', 'POST');
    htp.tableOpen;
    htp.tableRowOpen;
    htp.tableData('Event Code: ');
    htp.tableData(htf.formText('p_event_code', NULL, NULL, p_event_code));
    htp.tableRowClose;
    htp.tableClose;
    htp.nl;
    htp.formSubmit('p_submit', 'Search Events');
    htp.formClose;
    htp.tableOpen;
    if p_event_code is NULL then
	 htp.tableRowOpen;
	 --htp.p('<td><i>Enter ''%'' to search for all events.</i></td>');
	 htp.p('<td><i>Enter the first few characters of the Event Code or Event Name</i></td>');
	 htp.tableRowClose;
	 htp.tableRowOpen;
	 htp.p('<td><i>to search by (wildcards such as _ and % are supported)</i></td>');
	 htp.tableRowClose;
    else
    FOR c_rec IN cur_promotion_code(upper(p_event_code) || '%') LOOP
      htp.tableRowOpen;
      htp.p('<td><A HREF="javascript:PassBack(''' || c_rec.code || ' ' || c_rec.name || ''',''' || c_rec.code || ''')">' || c_rec.code || '   ' || c_rec.name || '</A></td>');
      htp.tableRowClose;
    END LOOP;
    end if;
    htp.tableClose;
    htp.p('</CENTER>');
    htp.bodyClose;
    htp.htmlClose;
  END high_popup_window;
----------------------------------------------------------------------------------------------------
  PROCEDURE footer
  IS
  BEGIN
    l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
    htp.htmlOpen;
    htp.tableRowOpen;
    htp.tableData(htf.hr, cRowSpan => '1', cColSpan => '190', cNoWrap => 'TRUE');
    htp.tableRowClose;
    htp.tableOpen(cAlign => 'center', cAttributes => ' border=0 cellspacing=2 cellpadding=2');
    htp.tableRowOpen;
    htp.formOpen(cUrl => l_agent || 'ast_ofl_event_attendees_report.report_wrapper', cMethod => 'post', cAttributes => ' NAME="MyForm" TARGET="_top"');
--htp.tableData(htf.formSubmit(cValue => 'OK', cAttributes => ' onMouseOver="window.status=''OK'';return true"'));
    htp.p('<td>');
    htp.p('<INPUT TYPE="BUTTON" VALUE="OK" onClick="validateForm(document.param)">');
    htp.p('</td>');
    --htp.tableData('<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
    htp.tableData( '<INPUT type=button value="Reset" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
    htp.tableData( '<INPUT type=button value="Cancel" onClick="window.close()" onMouseOver="window.status="Close";return true">');
    htp.tableRowClose;
    htp.tableClose;
    htp.htmlClose;
  END footer;
END;

/
