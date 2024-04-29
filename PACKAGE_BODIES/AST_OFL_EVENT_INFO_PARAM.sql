--------------------------------------------------------
--  DDL for Package Body AST_OFL_EVENT_INFO_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_OFL_EVENT_INFO_PARAM" AS
 /* $Header: astrtipb.pls 115.12 2002/02/06 10:44:44 pkm ship   $ */

/*
	Date			Remarks
	----------	------------------------------------------------
	08/12/2000     Date format is changed to US instead of british.
*/

	TYPE day_table IS
	TABLE OF	VARCHAR2(2000)
	INDEX BY	BINARY_INTEGER;

	TYPE year_table IS
	TABLE OF	VARCHAR2(2000)
	INDEX BY	BINARY_INTEGER;

	g_image_prefix	VARCHAR2(250) := '/OA_MEDIA/' || icx_sec.getid(icx_sec.pv_language_code) || '/';
	l_user_id		NUMBER;


  v_date_time    VARCHAR2(30);
  l_agent        VARCHAR2(200);
  ctr1           INTEGER       := 0;
  ctr2           INTEGER       := 0;
--  g_date_format  VARCHAR2(20)  := as_ofl_util_pkg.get_date_format;  -- Changed for 11i AJScott
  day_data       day_table;
  year_data      year_table;


  display_event_name   VARCHAR2(200);


  PROCEDURE header  -- This procedure is creates the descriptive header in the parameter form
  IS
  BEGIN
--    SELECT TO_CHAR(SYSDATE,       -- Changed for 11i AJScott
--                   g_date_format)
--    INTO   v_date_time
--    FROM   DUAL

    -- Begin Mod. RAAM 07/12/2000
    -- Thanh asked to display date in US format instead of British format.
    --SELECT fnd_date.date_to_chardate(SYSDATE)
    -- End Mod.
    SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY')
    INTO   v_date_time
    FROM   DUAL;
    htp.htmlOpen;
    htp.headOpen;
    htp.title('Event Information');
    htp.headClose;
    htp.bodyOpen(cAttributes => 'bgcolor="#CCCCCC"');
    htp.tableOpen('border="0"  ');
    htp.tableRowOpen(cAlign => 'TOP');

    --htp.tableData(htf.img( cUrl => g_image_prefix || 'oppty.gif'));

    htp.tableData('<FONT size=+1 face="times new roman">' || 'Event Information Report',
                  cNoWrap => 'TRUE');
    htp.tableData(htf.bold(v_date_time),
                  cAlign => 'right',
                  cColSpan => '110');
    htp.tableRowClose;
    htp.tableClose;
    htp.tableOpen(cAttributes => 'border=0 cellspacing=0 cellpadding=0 width=561');

     htp.tableRowOpen( cvalign => 'top' );
     htp.tableData( ' ', ccolspan => '2', cattributes => ' height=9');
     htp.tableData( '<FONT face="Times New Roman">' ||htf.bold( 'Please specify the criteria and select OK.  ') ||
                    '</FONT>', calign => 'center', crowspan => '2', ccolspan => '110', cattributes => ' width=346');
     htp.tableData( ' ', ccolspan => '6');
     htp.Br;
     htp.tableRowClose;
     htp.tableClose;
     htp.bodyClose;
     htp.headClose;
     htp.htmlClose;
   end;
-----------------------------------------------------------------------------------------------
procedure event_information_paramform is

-----------------------------------------------------------------------------------------------
--
--  PROCEDURE: event_reg_detail_paramform
--
--  DESCRIPTION:  This procedure is main body of the parameter form
--
-----------------------------------------------------------------------------------------------

-- RN 25/9/00
--     CURSOR cur_promotion_code is
--     select code, name
--       from as_promotions_all
--      where type = 'E'
--      order by 1;

     day_counter NUMBER := 1;
     year_counter  NUMBER := 1990;



   BEGIN

     FOR i IN 1..31 LOOP
       if day_counter <= 9  then
         day_data(i) := '0'||day_counter;
         day_counter := day_counter +1;
       else
         day_data(i) := to_char(day_counter);
         day_counter := day_counter +1;
       end if;
    END LOOP;

    FOR i IN 1..21 LOOP
         year_data(i) := to_char(year_counter);
         year_counter := year_counter +1;
    END LOOP;


if (icx_sec.validateSession) then
       header;

       l_user_id := icx_sec.getID(icx_sec.PV_USER_ID);
       -------------------- Returns login user Id--------------------------
       htp.FormOpen(owa_util.Get_Owa_Service_Path||'AST_OFL_EVENT_INFO_REPORT.report_wrapper', cattributes => ' NAME="param"');
       htp.htmlopen;
       htp.headOpen;
       htp.title('Event Information Report');
       htp.p('<SCRIPT language="JavaScript">');

       htp.p('window.name = "bigwindow";');
       htp.p('function btn_press()');
       htp.p('{');
       htp.p('winpbook=window.open(''ast_ofl_event_info_param.popup_window'',''pbook'', ''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,left=0,top=0,width=650,height=410'');');
       htp.p('winpbook.focus();');
       htp.p('}');

       htp.p('window.name = "bigwindow";');
       htp.p('function btn_press_high()');
       htp.p('{');
       htp.p('winpbook=window.open(''ast_ofl_event_info_param.high_popup_window'',''pbook'', ''toolbar=no,location=no,directories=no,status=no,menubar=no,scrollbars=yes,resizable=yes,left=0,top=0,width=650,height=410'');');
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
       htp.bodyopen(cattributes=>'bgcolor="#CCCCCC"');
       htp.tableopen;
       htp.tableRowOpen( cvalign => 'top' );
       htp.tableData( ' ', cattributes => ' height=9');
       htp.tableData( '<FONT size=2 face="Times New Roman">' || '</FONT>', calign => 'right', crowspan => '2', ccolspan => '3', cattributes => ' width=154');
       htp.tableData( ' ');
       htp.tableRowClose;
       htp.tableClose;
       htp.tableOpen(cattributes=>'width="600" ');
     htp.tableRowClose;

       htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="32%" valign="top">Start Date</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_sd_date">');
         FOR i IN 1..day_data.count  LOOP
	           htp.FormSelectOption(day_data(i),
			cattributes => ' value= '||day_data(i),
			cselected => 'TRUE' );
         END LOOP;
       htp.FormSelectClose;
       htp.p('-');

     htp.p ('<SELECT name="p_sm_date">');
         FOR i IN 1..12 LOOP
           if i=1 then
             htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
               cattributes => ' value='||lpad(to_char(i),2,'0'),
               cselected => 'TRUE' );
           else
             htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
               cattributes => ' value='||lpad(to_char(i),2,'0'));
           end if;
         END LOOP;
     htp.FormSelectClose;
     htp.p('-');

     htp.p ('<SELECT name="p_sy_date">');
         FOR i IN 1..year_data.count  LOOP
         IF year_data(i) = TO_CHAR(SYSDATE, 'YYYY') THEN
	           htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i),
			cselected => 'TRUE' );
         ELSE
	      htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i));
	    END IF;
         END LOOP;
       htp.FormSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

     htp.tableRowOpen();
       htp.p('<td align="RIGHT" width="32%" valign="top">End Date</td>');
       htp.p('<td>');
       htp.p ('<SELECT name="p_ed_date">');
         FOR i IN 1..day_data.count  LOOP
	           htp.FormSelectOption(day_data(i),
			cattributes => ' value= '||day_data(i),
			cselected => 'TRUE' );
         END LOOP;
       htp.FormSelectClose;
       htp.p('-');

     htp.p ('<SELECT name="p_em_date">');
         FOR i IN 1..12 LOOP
           if i=1 then
             htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
               cattributes => ' value='||lpad(to_char(i),2,'0'),
               cselected => 'TRUE' );
           else
             htp.FormSelectOption(TO_CHAR(TO_DATE(i, 'MM'), 'MON'),
               cattributes => ' value='||lpad(to_char(i),2,'0'));
           end if;
         END LOOP;
     htp.FormSelectClose;
     htp.p('-');

     htp.p ('<SELECT name="p_ey_date">');
         FOR i IN 1..year_data.count  LOOP
         IF year_data(i) = TO_CHAR(SYSDATE, 'YYYY') THEN
	           htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i),
			cselected => 'TRUE' );
         ELSE
	      htp.FormSelectOption(year_data(i),
			cattributes => ' value= '||year_data(i));
	    END IF;
         END LOOP;
       htp.FormSelectClose;
     htp.p('</td>');
     htp.tableRowClose;

     htp.tableRowOpen;
     htp.p('<td align="LEFT" colspan="2"><b>Range of Event Codes:</b></td>');
     htp.tableRowClose;

     htp.tableRowOpen();
     htp.p('<td align="RIGHT" width="32%" valign="top">From Event Code</td>');
     htp.p('<td>');

     htp.formHidden('p_promotion_code_low',null,null);
     htp.formText('p_low_description',50,null);
     htp.p('<td><A HREF="javascript:btn_press()">LOV</A></td>');
     htp.p('</td>');
     htp.tableRowClose;

     htp.tableRowOpen();
     htp.p('<td align="RIGHT" width="32%" valign="top">To Event Code</td>');
     htp.p('<td>');

     htp.formHidden('p_promotion_code_high',null,null);
     htp.formText('p_high_description',50,null);
     htp.p('<td><A HREF="javascript:btn_press_high()">LOV</A></td>');
     htp.p('</td>');
     htp.tableRowClose;

     htp.tableClose;
       htp.Br;
       htp.Br;
       htp.Br;
       footer;
       htp.FormClose;
       htp.bodyclose;
       htp.htmlclose;
 else
  htp.p('Invalid session');
     end if;
     exception
        when others then
                htp.p(SQLERRM);
   END event_information_paramform;

   procedure popup_window (p_event_code in varchar2 default null,
                           p_submit in varchar2 default null,
                           p_selected_event_code in varchar2 default null) is

   CURSOR cur_promotion_code(Event_Code VARCHAR2) is
-- RN 25/9/00
	SELECT event_offer_id code, event_offer_name name
	FROM ams_event_offers_vl
	WHERE event_offer_id LIKE NVL(UPPER(Event_Code), '%') || '%'
	OR UPPER(event_offer_name) LIKE NVL(UPPER(Event_Code), '%') || '%'
--     select code, name
--       from as_promotions_all
--      where type = 'E'
--      and (upper(code) like nvl(upper(p_event_code),'%')||'%' or upper(name) like nvl(upper(p_event_code),'%')||'%')
      order by 1;

   BEGIN
      htp.htmlOpen;
      htp.headOpen;
         htp.title('Event Information Report - Event Codes');
         htp.p('<SCRIPT language="JavaScript">');
         htp.p('function PassBack(p_low_description,p_promotion_code_low) {

         	var f_len = p_low_description.length
      		for (var i = 0; i < f_len; i++)
      		{
        	 if (p_low_description.substring(i, (i+2)) == ''?$'')
        	  {
		   p_low_description=p_low_description.substring(0,(i))+"''"+p_low_description.substring((i+2),(f_len))
        	   }
        	f_len = p_low_description.length
        	}

         	opener.document.forms[0].p_low_description.value = p_low_description;
         	opener.document.forms[0].p_promotion_code_low.value = p_promotion_code_low;
         	opener.document.forms[0].p_low_description.focus();
         	close();

         }');

         htp.p('</SCRIPT>');
      htp.headClose;
      htp.p('<BODY bgcolor="#CCCCCC">');
         htp.p('<CENTER>');
         htp.bold('<font size="+1">Search Events</font>');
         htp.formOpen('AST_OFL_EVENT_INFO_PARAM.popup_window','POST');
            htp.tableOpen;
            htp.tableRowOpen;
               htp.tableData('Event Code: ');
               htp.tableData(htf.formText('p_event_code',null,null,nvl(p_event_code,'%')));
            htp.tableRowClose;
            htp.tableClose;
            htp.nl;
            htp.formSubmit('p_submit','Search Events');
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
           for c_rec in cur_promotion_code(p_event_code) loop
             htp.tableRowOpen;
                display_event_name := c_rec.name;
                -- check for any special characters ..... BJANI (12/03/2001)
                if instr(c_rec.name,'''') > 0 then
                -- adding an escape character .... BJANI
           	c_rec.name := REPLACE(c_rec.name,'''','?$');
           	end if;
           	-- BJANI end
             htp.p('<td><A HREF="javascript:PassBack('''||c_rec.code||' '||c_rec.name||''','''||c_rec.code||''')">'||c_rec.code||'   '||display_event_name||'</A></td>');
            htp.tableRowClose;
          end loop;
        end if;
         htp.tableClose;
         htp.p('</CENTER>');
      htp.bodyClose;
      htp.htmlClose;
   END popup_window;

   procedure high_popup_window (p_event_code in varchar2 default null,
                           p_submit in varchar2 default null,
                           p_selected_event_code in varchar2 default null) is

   CURSOR cur_promotion_code(Event_Code VARCHAR2) is
-- RN 25/9/00
	SELECT event_offer_id code, event_offer_name name
	FROM ams_event_offers_vl
	WHERE event_offer_id LIKE NVL(UPPER(Event_Code), '%') || '%'
	OR UPPER(event_offer_name) LIKE NVL(UPPER(Event_Code), '%') || '%'
--     select code, name
--       from as_promotions_all
--      where type = 'E'
--      and (upper(code) like nvl(upper(Event_Code),'%')||'%' or upper(name) like nvl(upper(Event_Code),'%')||'%')
      order by 1;

   BEGIN
      htp.htmlOpen;
      htp.headOpen;
         htp.title('Event Information Report - Event Codes');
         htp.p('<SCRIPT language="JavaScript">');

         htp.p('function PassBack(p_high_description,p_promotion_code_high) {

         	var f_len = p_high_description.length
      		for (var i = 0; i < f_len; i++)
      		{
        	 if (p_high_description.substring(i, (i+2)) == ''?$'')
        	  {
		   p_high_description=p_high_description.substring(0,(i))+"''"+p_high_description.substring((i+2),(f_len))
        	   }
        	f_len = p_high_description.length
        	}

         	opener.document.forms[0].p_high_description.value = p_high_description;
         	opener.document.forms[0].p_promotion_code_high.value = p_promotion_code_high;
         	opener.document.forms[0].p_high_description.focus();
         	close();

         }');

         htp.p('</SCRIPT>');

      htp.headClose;
      htp.p('<BODY bgcolor="#CCCCCC">');
         htp.p('<CENTER>');
         htp.bold('<font size="+1">Search Events</font>');
         htp.formOpen('AST_OFL_EVENT_INFO_PARAM.high_popup_window','POST');
            htp.tableOpen;
            htp.tableRowOpen;
               htp.tableData('Event Code: ');
               htp.tableData(htf.formText('p_event_code',null,null,nvl(p_event_code,'%')));
            htp.tableRowClose;
            htp.tableClose;
            htp.nl;
            htp.formSubmit('p_submit','Search Events');
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
           for c_rec in cur_promotion_code(p_event_code) loop
              htp.tableRowOpen;
                display_event_name := c_rec.name;
              	-- check for any special characters ..... BJANI (12/03/2001)
                if instr(c_rec.name,'''') > 0 then
                -- adding an escape character .... BJANI
           	c_rec.name := REPLACE(c_rec.name,'''','?$');
           	end if;
           	-- BJANI end
              htp.p('<td><A HREF="javascript:PassBack('''||c_rec.code||' '||c_rec.name||''','''||c_rec.code||''')">'||c_rec.code||'   '||display_event_name||'</A></td>');
              htp.tableRowClose;
           end loop;
         end if;
         htp.tableClose;
         htp.p('</CENTER>');
      htp.bodyClose;
      htp.htmlClose;
   END high_popup_window;

   procedure footer is
   BEGIN
      l_agent := owa_util.get_cgi_env('SCRIPT_NAME');
      htp.htmlopen;
      htp.tableRowOpen;
      htp.tableData( htf.hr, crowspan => '1', ccolspan => '190', cnowrap => 'TRUE');
      htp.tableRowClose;
      htp.tableOpen( calign => 'center', cattributes => ' border=0 cellspacing=2 cellpadding=2' );
      htp.tableRowOpen;
      htp.formOpen( curl => l_agent||'/AST_OFL_EVENT_INFO_REPORT.report_wrapper', cmethod => 'post', cattributes => ' NAME="MyForm" TARGET="_top"');
      --htp.tableData( htf.formSubmit( cvalue => 'OK', cattributes => ' onMouseOver="window.status=''OK'';return true"'));
      htp.p('<td>');
      htp.p('<INPUT TYPE="BUTTON" VALUE="OK" onClick="validateForm(document.param)">');
      htp.p('</td>');
      --htp.tableData( '<INPUT type=button value="Cancel" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableData( '<INPUT type=button value="Reset" onClick="history.back()" onMouseOver="window.status="Cancel";return true">');
      htp.tableData( '<INPUT type=button value="Cancel" onClick="window.close()" onMouseOver="window.status="Close";return true">');
      htp.tableRowClose;
      htp.tableClose;
      htp.htmlClose;
   END footer;
END;

/
