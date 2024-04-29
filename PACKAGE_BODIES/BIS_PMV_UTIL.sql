--------------------------------------------------------
--  DDL for Package Body BIS_PMV_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_UTIL" as
/* $Header: BISPMVUB.pls 120.4.12010000.2 2008/08/12 07:36:02 bijain ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(120.4.12000000.2=120.5):~PROD:~PATH:~FILE
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date     Comments
-- aleung      7/13/01  initial creation
-- amkulkar    7/18/01  Added function to sort attribute codes and values
-- mdamle     11/08/01  Added getReportRegion function
-- mdamle     12/05/01  Added getFormattedDate
-- mdamle     12/12/01  Added getParameterValue
-- mdamle     12/19/01  Added getDefaultResponsibility
-- nbarik     03/09/02  Bug Fix 2503143 Added getICXCurrentDateTime
-- nbarik     01/10/03  Enhancement : 2638594 - Portlet Builder
--                      Added function getRegionApplicationId
-- nbarik     04/07/03  Bug Fix 2871424 - strip the quotes in bind variables
-- nkishore   04/25/03  BugFix 2823330 Get lastrefreshDate
-- ansingh    06/09/03  BugFix 2995675 Staling of RL Portlets based on PlugId
-- nbarik     08/21/03  Bug Fix 3099831 - Add hasFunctionAccess
-- mdamle     06/18/04  Return -1 if region not found - getRegionApplicationId()
-- mdamle     08/04/04  Added getRegionDataSourceType
-- smargand   09/21/04  Bug Fix: 3902169  -- Live Portlet fix
-- ---------   -------  ------------------------------------------
function readFndLobs (pFileId in number) return lob_varchar_pieces is
   loc BLOB;
   amount binary_integer := 0;
   maxamount binary_integer := 8000;
   offset integer := 1;
   output varchar2(32000);
   vIndex  number := 1;
   vLobPieces  lob_varchar_pieces;
begin
  -- get file location
 begin
  select file_data
  into   loc
  from   FND_LOBS
  where  file_id = pFileId;
 exception
  when others then
    htp.p(SQLERRM);
 end;

  amount := DBMS_LOB.getlength(loc);
  -- read html codes from that location
  while amount > maxamount
  loop
    DBMS_LOB.READ(loc, maxamount, offset, output);
    vLobPieces(vIndex) := utl_raw.cast_to_varchar2(output);
    vIndex := vIndex + 1;
    amount := amount - maxamount;
    offset := offset + maxamount;
  end loop;

  if amount > 0 then
    DBMS_LOB.READ(loc, amount, offset, output);
    vLobPieces(vIndex) := utl_raw.cast_to_varchar2(output);
  end if;

  return vLobPieces;

exception
  when others then
    htp.print('In bis_pmv_util.readFndLobs: '||SQLERRM);
end readFndLobs;
--
--ashgarg Bug Fix: 4526317
PROCEDURE RETRIEVE_DATA
(document_id           IN       NUMBER
,document              IN OUT   NOCOPY VARCHAR2
)
IS
    l_Document              VARCHAR2(32000);
    l_html_pieces           BIS_PMV_UTIL.lob_varchar_pieces;
    l_count                 NUMBER;

BEGIN

    select count(*)
    into l_count
    from fnd_lobs
    where file_id = document_id;

    if l_count > 0 then
    	l_html_pieces := BIS_PMV_UTIL.readfndlobs(document_id);
    	FOR l_count IN 1..l_html_pieces.COUNT LOOP
	    	l_document := l_document || l_html_pieces(l_count);
        END LOOP;
		document := l_document;
    end if;

END;
--
procedure sortAttributeCode
(p_attributeCode_tbl    in OUT    NOCOPY BISVIEWER.t_char
,p_attributeValue_tbl   in OUT    NOCOPY BISVIEWER.t_char
,x_return_status        OUT       NOCOPY VARCHAR2
,x_msg_count            OUT       NOCOPY NUMBER
,x_msg_data             OUT       NOCOPY VARCHAR2
)
IS
   l_count                       NUMBER;
   l_length_tbl                  BISVIEWER.t_num;
   l_temp_attr                   VARCHAR2(32000);
   l_temp_value                  VARCHAR2(32000);
   l_temp_length                 NUMBER;

BEGIN
   --First get the lengths of all the attribute codes in an array.
   --This is what we will be sorting in descending order.
   IF (p_attributeCode_tbl.COUNT > 0) THEN
      FOR l_count IN 1..p_attributeCode_tbl.COUNT LOOP
          l_length_tbl(l_count) := length(p_attributeCode_tbl(l_count));
      END LOOP;
   END IF;
   --Now that we have the lengths of all these Attribute Codes let's sort
   --them in descending order
   FOR i IN l_length_tbl.FIRST+1..l_length_Tbl.LAST LOOP
         l_temp_attr := p_attributeCode_tbl(i);
         l_temp_value := p_attributeValue_tbl(i);
         l_temp_length := l_length_tbl(i);
       FOR j IN REVERSE l_length_Tbl.FIRST..(i-1) LOOP
          if l_length_tbl(j) < l_temp_length THEN
             l_length_tbl(j+1) := l_length_tbl(j);
             l_length_tbl(j) := l_temp_length;
             p_attributeCode_tbl(j+1) := p_attributeCode_tbl(j);
             p_attributeCode_tbl(j) := l_temp_attr;
             p_attributeValue_tbl(j+1) := p_attributeValue_tbl(j);
             p_attributeValue_tbl(j) := l_temp_value;
          end if;
       END LOOP;
   END LOOP;
END;

procedure getCurrentDateTime (x_current_date_time out NOCOPY varchar2,
                              x_current_date out NOCOPY varchar2,
                              x_current_hour out NOCOPY varchar2,
                              x_current_minute out NOCOPY varchar2) is
begin

  x_current_date_time := fnd_date.date_to_charDT(SYSDATE);

  x_current_date := fnd_date.date_to_chardate(SYSDATE);

  select to_char(SYSDATE, 'HH24')
  into   x_current_hour
  from   dual;

  select to_char(SYSDATE, 'MI')
  into   x_current_minute
  from   dual;

end getCurrentDateTime;

--Bug Fix 2503143 nbarik 03/sep/2002
PROCEDURE getICXCurrentDateTime( p_icx_date_format IN VARCHAR2,
                                 x_current_date_time OUT NOCOPY VARCHAR2,
                                 x_current_date OUT NOCOPY VARCHAR2,
                                 x_current_hour OUT NOCOPY VARCHAR2,
                                 x_current_minute OUT NOCOPY VARCHAR2) IS
l_date   DATE;
l_default_date_format VARCHAR2(15) := 'DD-MON-RR';
BEGIN
  -- get the date once
  l_date := SYSDATE;
  IF (p_icx_date_format IS NOT NULL) THEN
    x_current_date_time := to_char(l_date, p_icx_date_format || ' HH24:MI:SS');
    x_current_date := to_char(l_date, p_icx_date_format);
  ELSE
    x_current_date_time := to_char(l_date, l_default_date_format || ' HH24:MI:SS');
    x_current_date := to_char(l_date, l_default_date_format);
  END IF;

  x_current_hour := to_char(l_date, 'HH24');

  x_current_minute := to_char(l_date, 'MI');

END getICXCurrentDateTime;


function getAppendTitle(pRegionCode in varchar2) return varchar2 is
  l_append_title varchar2(2000);
  l_function     varchar2(2000);
begin
  select name
  into   l_function
  from   ak_regions_vl
  where  region_code = pRegionCode;

  l_function := substr(l_function, instr(l_function, '[')+1, instr(l_function, ']')-instr(l_function,'[')-1);
  if l_function is not null then
     l_function := 'select '||l_function||' from dual';
     begin
       execute immediate l_function into l_append_title;
     exception
       when others then
         null;
     end;
  end if;
  return l_append_title;
exception
  when others then
    return null;
end getAppendTitle;

procedure getReportTitle
(pFunctionName		IN	VARCHAR2
,pRegionCode		IN	VARCHAR2 default null
,pRegionName		IN	VARCHAR2 default null
,xTitleString		OUT	NOCOPY VARCHAR2
,xBrowserTitle          OUT     NOCOPY VARCHAR2
)
IS
  l_report_Title 	VARCHAR2(32000);
  l_report_currency	VARCHAR2(32000);
BEGIN
  l_Report_Title := BIS_REPORT_UTIL_PVT.get_report_title(pFunctionName)||getAppendTitle(pRegionCode);
  l_report_currency := BIS_REPORT_UTIL_PVT.get_report_currency;
  xBrowserTitle := l_Report_Title;
 --replaced showTitleDateCurrency with showTitleWithoutDateCurrency gsanap 6/19/02
  BIS_REPORT_UTIL_PVT.showTitleWithoutDateCurrency(l_report_title, l_report_currency, xTitleString);
  --BIS_REPORT_UTIL_PVT.showTitleDateCurrency(l_report_title, l_report_currency, xTitleString);
END getReportTitle;

FUNCTION getHierarchyElementId(pElementShortName   in varchar2,
                               pDimensionShortName in varchar2) return varchar2
IS
    vHierSQL                varchar2(2000);
    vElementId              number;
    vLongName               varchar2(2000);

BEGIN
/*
    vHierSQL := ' select distinct ih.elementid, ih.longname'||
                ' from   cmpwbdimension_v d, cmpitemhierarchy_v ih, '||
                ' cmplevelrelationship_v lr1'||
                ' , cmplevel_v l '||
                ' where   ih.name = :1 and d.name = :2 '||
                ' and    ih.elementid = lr1.HIERARCHY '||
                ' and    lr1.CHILDLEVEL = l.ELEMENTID '||
                ' and    d.elementid = ih.owndimension ';
*/
    vHierSQL := ' select distinct hier.hier_id, hier.hier_long_name' ||
                ' from edw_hierarchies_md_v hier, EDW_HIERARCHY_LEVEL_MD_V hierlvl' ||
                ' where hier.hier_id = hierlvl.hier_id' ||
                ' and hier.hier_name = :1 and hier.dim_name = :2';

     EXECUTE IMMEDIATE vHierSQL INTO vElementId, vLongName
             USING pElementShortName, pDimensionShortName ;
     RETURN vElementId;
EXCEPTION
WHEN OTHERS THEN
    --Supress the display of the error message if there is no hierarchy
    --bisviewer.displayError(235,SQLCODE,SQLERRM);
    return 0;
END getHierarchyElementId;

FUNCTION getDimensionForAttribute(pAttributecode in varchar2,
                                  pRegionCode    in varchar2) RETURN VARCHAR2
IS
  CURSOR cAttr2 IS
  SELECT attribute2 FROM
  ak_region_items
  WHERE region_code=rtrim(ltrim(pRegionCode)) and
        (ltrim(rtrim(pAttributeCode)) in (attribute_code, attribute_code||'_FROM',
                                          attribute_code||'_TO', attribute_code||'_HIERARCHY'));
  l_attribute2    varchar2(32000);
BEGIN
  OPEN cAttr2;
  FETCH cAttr2 INTO l_attribute2;
  IF cAttr2%NOTFOUND then
     l_attribute2 := pAttributeCode;
  END IF;
  CLOSE cAttr2;
  RETURN l_attribute2;
EXCEPTION
  WHEN OTHERS THEN
    bisviewer.displayError(235,SQLCODE,SQLERRM);
    return null;
END getDimensionForAttribute;

FUNCTION getAttributeForDimension(pDimension  in varchar2,
                                  pRegionCode in varchar2) RETURN VARCHAR2
IS
  CURSOR cAttr2 IS
  SELECT attribute_code FROM
  ak_region_items
  WHERE region_code=rtrim(ltrim(pRegionCode)) and
        attribute2=ltrim(rtrim(pDimension));
  l_attribute_code varchar2(32000);
BEGIN
  OPEN cAttr2;
  FETCH cAttr2 INTO l_attribute_code;
  IF cAttr2%NOTFOUND then
     l_attribute_code := pDimension;
  END IF;
  CLOSE cAttr2;
  RETURN l_attribute_code;
EXCEPTION
  WHEN OTHERS THEN
    bisviewer.displayError(235,SQLCODE,SQLERRM);
    return null;
END getAttributeForDimension;

function encode (p_url     in varchar2,
                 p_charset in varchar2 default null) return varchar2
is
	-- mdamle 11/1/2002 - Removed *
        c_unreserved constant varchar2(72) :=
        '-_.!~*''()ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        l_client_nls_lang  varchar2(200);
        l_client_charset   varchar2(200);
        l_db_charset       varchar2(200);
        l_tmp              varchar2(32767) := '';
        l_onechar     varchar2(4);
        l_str         varchar2(48);
        l_byte_len    integer;
        l_do_convert   boolean := null;
        i             integer;
    begin
        if p_url is NULL then
           return NULL;
        end if;

        l_do_convert := true;
        if p_charset is null
        then
          l_client_charset := g_db_charset;
          l_client_nls_lang := g_db_nls_lang;
        else
          i := instr(p_charset, '.');
          if i <> 0 then
           l_client_charset := substr(p_charset, i+1);
           l_client_nls_lang := p_charset;
          else
           l_client_charset := p_charset;
           l_client_nls_lang := 'AMERICAN_AMERICA.' || p_charset;
          end if;
        end if;

        for i in 1 .. length(p_url) loop
            l_onechar := substr(p_url,i,1);

            if instr(c_unreserved, l_onechar) > 0 then

                /* if this character is excluded from encoding */
                l_tmp := l_tmp || l_onechar;
            elsif l_onechar = ' ' then
                /* spaces are encoded using the plus "%20" sign */
                l_tmp := l_tmp || '%20';
            else
                if (l_do_convert) then


                 /*
                  * This code to be called ONLY in case when client and server
                  * charsets are different. The performance of this code is
                  * significantly slower than "else" portion of this statement.
                  * But in this case it is guarenteed to be working in
                  * any configuration where the byte-length of the charset
                  * is different between client and server (e.g. UTF-8 to SJIS).
                  */

                  /*
                   * utl_raw.convert only takes a qualified NLS_LANG value in
                   * <langauge>_<territory>.<charset> format for target and
                   * source charset parameters. Need to use l_client_nls_lang
                   * and g_db_nls_lang here.
                   */
                    l_str := utl_raw.convert(utl_raw.cast_to_raw(l_onechar),
                        l_client_nls_lang,
                        g_db_nls_lang);
                    l_byte_len := length(l_str);
                    if l_byte_len = 2 then
                        l_tmp := l_tmp
                            || '%' || l_str;
                    elsif l_byte_len = 4 then
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2);
                    elsif l_byte_len = 6 then
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2);
                    elsif l_byte_len = 8 then
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2)
                            || '%' || substr(l_str,7,2);
                    else /* maximum precision exceeded */
                        raise PROGRAM_ERROR;
                    end if;
                else

                 /*
                  * This is the "simple" encoding when no charset translation
                  * is needed, so it is relatively fast.
                  */
                    l_byte_len := lengthb(l_onechar);
                    if l_byte_len = 1 then
                        l_tmp := l_tmp || '%' ||
                            substr(to_char(ascii(l_onechar),'FM0X'),1,2);
                    elsif l_byte_len = 2 then
                        l_str := to_char(ascii(l_onechar),'FM0XXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2);
                    elsif l_byte_len = 3 then
                        l_str := to_char(ascii(l_onechar),'FM0XXXXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2);
                    elsif l_byte_len = 4 then
                        l_str := to_char(ascii(l_onechar),'FM0XXXXXXX');
                        l_tmp := l_tmp
                            || '%' || substr(l_str,1,2)
                            || '%' || substr(l_str,3,2)
                            || '%' || substr(l_str,5,2)
                            || '%' || substr(l_str,7,2);
                    else /* maximum precision exceeded */
                        raise PROGRAM_ERROR;
                    end if;
                end if;
            end if;
        end loop;
        return l_tmp;
 end encode;

 function decode1 (p_url     in varchar2,
                  p_charset in varchar2 default null)
                  return varchar2
    is
        l_client_nls_lang varchar2(200);
        l_raw             raw(32767);
        l_char            varchar2(4);
        l_hex             varchar2(8);
        l_len             integer;
        i                 integer := 1;
    begin
        /*
         * Set a source charset for code conversion.
         * utl_raw.convert() only accepts <lang>_<territory>.<charset> format
         * to specify source and destination charset and need to add a dummy
         * 'AMERICAN_AMERICA' string if a give charset dose not have <lang>_
         * <territory> information.
         */
        if instr(p_charset, '.') = 0 then
            l_client_nls_lang := 'AMERICAN_AMERICA.' || p_charset;
        else
            l_client_nls_lang := p_charset;
        end if;

        l_len := length(p_url);

        while i <= l_len
        loop
            l_char := substr(p_url, i, 1);
            if l_char = '+' then
                /* convert to a hex number of space characters */
                l_hex := '20';
                i := i + 1;
            elsif l_char = '%' then
                /* process hex encoded characters. just remove a % character */
                l_hex := substr(p_url, i+1, 2);
                i := i + 3;
            else
                /* convert to hex numbers for all other characters */
                l_hex := to_char(ascii(l_char), 'FM0X');
                i := i + 1;
            end if;
            /* convert a hex number to a raw datatype */
            l_raw := l_raw || hextoraw(l_hex);
         end loop;

         /*
          * convert a raw data from the source charset to the database charset,
          * then cast it to a varchar2 string.
          */
         return utl_raw.cast_to_varchar2(
                          utl_raw.convert(l_raw, g_db_nls_lang, l_client_nls_lang));
end decode1;

-- mdamle 11/08/2001
function getReportRegion(pFunctionName IN VARCHAR2) return varchar2 IS

l_paramRegionCode	VARCHAR2(30);
l_callRegionCode	VARCHAR2(30);
l_parameters		VARCHAR2(2000);
l_region		VARCHAR2(30);
l_index			NUMBER;
l_type			VARCHAR2(30);
l_web_html_call		VARCHAR2(240);
l_ref_function_name	fnd_form_functions.function_name%TYPE;

cursor c_form_func(cpFunctionName varchar2) is
select web_html_call,parameters,type
  from fnd_form_functions
 where function_name = cpFunctionName;

BEGIN

	-- mdamle 12/27/2001 - Region Code is specified in web_html_call when type = WWW
	--		     - Region Code may be specified in parameters when type = DBPORTLET / WEBPORTLET
        if c_form_func%ISOPEN then
           close c_form_func;
        end if;
        open c_form_func(pFunctionName);
             fetch c_form_func into l_web_html_call, l_parameters, l_type;
        close c_form_func;
/*
	begin
		select 	web_html_call
		        ,parameters
			,type
		into l_web_html_call, l_parameters, l_type
		from fnd_form_functions
		where function_name = pFunctionName;
	exception
		WHEN OTHERS THEN NULL;
	end;
*/
	if l_type = 'WWW' then
		l_region := substr( substr( l_web_html_call, instr(l_web_html_call, '''')+1 ), 1, instr(substr( l_web_html_call, instr(l_web_html_call, '''')+1 ),'''')-1 );
		if l_region is null then
			-- Try parameters
			l_region := getParameterValue(l_parameters, 'pRegionCode');
		end if;
        elsif l_type = 'WEBPORTLET' then
                l_region := getParameterValue(l_parameters, 'pRegionCode');
	else
		-- Type = DBPORTLET
		l_region := getParameterValue(l_parameters, 'pRegionCode');

		-- Check if portlet is pointing to another function
		-- Get region code from that function
		l_ref_function_name := getParameterValue(l_parameters, 'pFunctionName');
		if l_ref_function_name is null then
			l_ref_function_name := getParameterValue(l_parameters, 'FUNCTION_NAME');
		end if;

             if l_ref_function_name is not null and l_ref_function_name <> '' then
                if c_form_func%ISOPEN then
                   close c_form_func;
                end if;
                open c_form_func(l_ref_function_name);
                     fetch c_form_func into l_web_html_call, l_parameters, l_type;
                close c_form_func;
/*
		begin
			select 	web_html_call
		        ,parameters
			,type
			into l_web_html_call, l_parameters, l_type
			from fnd_form_functions
			where function_name = l_ref_function_name;
		exception
			WHEN OTHERS THEN NULL;
		end;
*/
		if l_type = 'WWW' then
			l_region := substr( substr( l_web_html_call, instr(l_web_html_call, '''')+1 ), 1, instr(substr( l_web_html_call, instr(l_web_html_call, '''')+1 ),'''')-1 );
			if l_region is null then
				-- Try parameters
				l_region := getParameterValue(l_parameters, 'pRegionCode');
			end if;
		end if;
             end if; -- l_ref_function_name is not null
	end if;

	return l_region;

END getReportRegion;

-- mdamle 12/05/01
-- This routine is used mainly because formatted date is not returned
-- correctly when called from java sql
function getFormattedDate(pInputDate in date, pFormatMask in varchar2)  return varchar2 is
begin
	return to_char(pInputDate, pFormatMask);
exception
	when others then
	return to_char(pInputDate);
end getFormattedDate;

-- mdamle 12/12/01 - This routine will return the value of a parameter (given the param name) within the parameter string
-- defined in form function
function getParameterValue(pParameters IN VARCHAR2, pParameterKey IN VARCHAR2) return varchar2 is
l_value varchar2(1000);
l_index1 number;

l_value_begin number;
l_value_end number;

begin
	-- mdamle 11/15/2002 - Ignore case
	l_index1 := instr(lower(pParameters), lower(pParameterKey)||'=');

	if  l_index1 > 0 then
		l_value_begin := l_index1 + length(pParameterKey||'=');

		l_value_end := instr(pParameters, '&', l_value_begin);

		if l_value_end > 0 then
			l_value := substr(pParameters, l_value_begin, l_value_end - l_value_begin);
		else
			l_value := substr(pParameters, l_value_begin);
		end if;

	else
		l_value := '';
	end if;

	return l_value;

end getParameterValue;

-- mdamle 12/19/2001
--Rewrote the whole thing for performance improvement.
function getDefaultResponsibility(pUserId 	in varchar2
				, pFunctionName	in varchar2
				, pCheckPMVSpecific in varchar2 default 'N')
return varchar2 IS
  l_resp_id fnd_responsibility.responsibility_id%TYPE;
  l_default_resp_id fnd_responsibility.responsibility_id%TYPE;
  l_appl_id fnd_responsibility.application_id%TYPE;
  l_function_name fnd_form_functions.function_name%TYPE;
  l_menu_id    fnd_responsibility.menu_id%TYPE;
  l_user_id fnd_user.user_id%TYPE;
  CURSOR CM  IS
        SELECT 1
        FROM FND_MENU_ENTRIES MEV, FND_RESP_FUNCTIONS RF, FND_FORM_FUNCTIONS FF
        WHERE MEV.MENU_ID = l_menu_id
        AND RF.RESPONSIBILITY_ID (+) =  l_resp_id
        AND RF.RULE_TYPE(+) = DECODE(MEV.FUNCTION_ID, NULL, 'M', 'F')
        AND RF.ACTION_ID(+) <> DECODE(DECODE(MEV.FUNCTION_ID, NULL, 'M', 'F'), 'F', MEV.FUNCTION_ID,
                                          'M', MEV.SUB_MENU_ID, null)
        AND RF.ACTION_ID IS NULL
        AND MEV.FUNCTION_ID = FF.FUNCTION_ID
        AND FF.function_name = l_function_name
        AND RF.APPLICATION_ID(+) = l_appl_id
        UNION
        SELECT 1
        FROM FND_MENU_ENTRIES MEV, FND_RESP_FUNCTIONS RF, FND_FORM_FUNCTIONS FF
        WHERE MEV.MENU_ID IN(
                                SELECT  SUB_MENU_ID
                                FROM FND_MENU_ENTRIES
                                WHERE SUB_MENU_ID IS NOT NULL
                                CONNECT BY  MENU_ID = PRIOR SUB_MENU_ID START WITH MENU_ID =l_menu_id)
        AND RF.RESPONSIBILITY_ID (+) =  l_resp_id
        AND RF.RULE_TYPE(+) = DECODE(MEV.FUNCTION_ID, NULL, 'M', 'F')
        AND RF.ACTION_ID(+) <> DECODE(DECODE(MEV.FUNCTION_ID, NULL, 'M', 'F'), 'F', MEV.FUNCTION_ID,
                                          'M', MEV.SUB_MENU_ID, null)
        AND RF.ACTION_ID IS NULL
        AND MEV.FUNCTION_ID = FF.FUNCTION_ID
        AND FF.function_name = l_function_name
        AND RF.APPLICATION_ID(+) = l_appl_id;
   CURSOR c_resp IS
        select  a.responsibility_id resp_id , a.menu_id menu_id, a.application_id appl_id
        from fnd_responsibility a,
             fnd_user_resp_groups b
        where b.user_id = l_user_id
        and   a.version = 'W'
        and   b.responsibility_id = a.responsibility_id
        and   b.start_date <= sysdate
        and   (b.end_date is null or b.end_date >= sysdate)
        and    a.start_date <= sysdate
        and   (a.end_date is null or a.end_date >= sysdate)
        and b.responsibility_application_id=a.application_id;
BEGIN
     l_function_name := pFunctionName;
     l_user_id := pUserId;
     for c_rec in c_resp loop
         l_resp_id := c_rec.resp_id;
         l_menu_id := c_rec.menu_id;
         l_Appl_id := c_rec.appl_id;
	 IF (CM%ISOPEN) THEN
            CLOSE CM;
         END IF;
         OPEN cM;
         FETCH CM INTO  l_menu_id;
         IF (CM%FOUND) THEN
            l_default_resp_id := c_rec.resp_id;
            CLOSE CM;
            EXIT;
         END IF;
         CLOSE CM;
     end loop;
     return l_default_resp_id;
end getDefaultResponsibility;

procedure stale_portlet
(puserid   in varchar2
,pfunctionname in varchar2
,pPlugId in varchar2 default null
)
IS
  cursor c_username is
  select user_name
  from fnd_user
  where user_id=puserid;
  l_user_name   varchar2(200);
BEGIN
  /*OPEN c_username;
  FETCH c_username INTO l_user_name;
  CLOSE c_username;
  --Call the ICX provided API to stale this portlet
  icx_portlet.updateCacheByUserFunc(l_user_name, pfunctionname);*/
  --UntIl we get the correct API from ICX we are going to do it ourselves.

  update icx_portlet_customizations
  set caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key,'0'))+1)
  where user_id = puserid and
  plug_id = pPlugId;
EXCEPTION
  WHEN OTHERS THEN
      NULL;
end;

--temporary API . will replace once we get the correct API from Teresa.
PROCEDURE update_portlets_bypage(p_page_id in varchar2) IS
  l_append_title varchar2(2000);
  l_function     varchar2(2000);
BEGIN
   l_function := 'update icx_portlet_customizations set caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key,''0''))+1) where reference_path in  (select name from wwpob_portlet_instance$ where page_id=:1)';

   execute immediate l_function using p_page_id;

EXCEPTION
WHEN OTHERS
THEN
    NULL;
END;
function get_render_type
(p_region_code   in varchar2
,p_user_id       in varchar2
,p_responsibility_id in varchar2)
return varchar2
is
  CURSOR c_akregion IS
  SELECT attribute9
  FROM ak_regions
  WHERE region_code = p_region_code;
  l_render_type    varchar2(2000);
  l_subtotal       varchar2(2000);
BEGIN
  l_render_type := fnd_profile.value_specific('PMV_RENDER_TYPE', p_user_id
                                             ,p_responsibility_id, 191);
  IF (c_akregion%ISOPEN) then
     CLOSE c_akregion;
  END IF;
  open c_akregion;
  FETCH c_akregion INTO l_subtotal;
  CLOSE c_akregion;
  IF (nvl(l_subtotal,'N') = 'Y') then
     l_render_Type := 'HTML';
  END IF;
  RETURN l_render_type;
END;

-- mdamle 10/31/2002 - Bug#2560743 - Use previous page parameters for linked page
function getPortalPageId(pPageName in varchar2) return number IS

lPageId		number;
lSQL		varchar2(2000);
begin
	lSQL := 'select bis_portlet_trends.getPortalPageId(:1) from dual';
        begin
               	execute immediate lSQL into lPageId using pPageName ;
	exception
        	when others then lPageId := null;
        end;

	return lPageId;

end getPortalPageId;

-- nbarik 01/10/03 Portlet Builder
FUNCTION getRegionApplicationId(pRegionCode IN VARCHAR2) RETURN NUMBER IS

CURSOR region_app_id_cursor(cp_region_code VARCHAR2) IS
SELECT region_application_id FROM ak_regions
WHERE region_code = cp_region_code;

l_region_app_id NUMBER;

BEGIN

  IF region_app_id_cursor%ISOPEN THEN
    CLOSE region_app_id_cursor;
  END IF;

  OPEN region_app_id_cursor(pRegionCode);
  FETCH region_app_id_cursor INTO l_region_app_id;
  IF region_app_id_cursor%NOTFOUND THEN
     l_region_app_id := -1;
  END IF;
  CLOSE region_app_id_cursor;

  RETURN l_region_app_id;
EXCEPTION
  WHEN others THEN
    IF region_app_id_cursor%ISOPEN THEN
      CLOSE region_app_id_cursor;
    END IF;

END getRegionApplicationId;

PROCEDURE stale_portlet_by_refPath (
	pReferencePath IN VARCHAR2)
IS
BEGIN
   UPDATE icx_portlet_customizations
   SET caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key,'0'))+1)
   WHERE reference_path = pReferencePath;
END stale_portlet_by_refPath;


--BugFix 2995675: Stale the portlet by updating the caching key
--ansingh
PROCEDURE STALE_PORTLET_BY_PLUGID (pPlugId IN VARCHAR2)
IS
BEGIN

   UPDATE icx_portlet_customizations
   SET caching_key = TO_CHAR(TO_NUMBER(NVL(caching_key,'0'))+1)
   WHERE plug_id = pPlugId;


   -- P1 BUG 3902169
   COMMIT ;

   EXCEPTION
	WHEN OTHERS THEN
	 null ;

END STALE_PORTLET_BY_PLUGID;


PROCEDURE SETUP_BIND_VARIABLES
(p_bind_variables in varchar2,
 x_bind_var_tbl  out NOCOPY BISVIEWER.t_char)
is
  l_startIndex        NUMBER;
  l_endIndex          NUMBER;
  l_bind_var          VARCHAR2(32000);
  l_tab_index       NUMBER := 1;
  l_bind_col          VARCHAR2(2000);
Begin
      l_startIndex := 2;
      loop
         if (instr(p_bind_variables, '~', l_startIndex , 1) > 0) then
             l_endIndex := instr(p_bind_variables,'~', l_startIndex, 1);
         else
             l_endIndex := length(p_bind_variables)+1;
         end if;
         l_bind_var := substr(p_bind_variables, l_startIndex, l_endIndex-l_startIndex);
         -- nbarik - 04/07/03 - Bug Fix 2871424 - some of the bind values have single quotes - so strip the quotes
         IF INSTR(l_bind_var, '''', 1)=1 AND INSTR(l_bind_var, '''', -1)=LENGTH(l_bind_var) THEN
           l_bind_var := SUBSTR(l_bind_var, 2, LENGTH(l_bind_var)-2);
         END IF;
         x_bind_var_tbl(l_tab_index) := l_bind_var;
         l_tab_index := l_tab_index +1;
         l_startIndex := l_endIndex+1;
         if (l_startIndex > length(p_bind_variables) or
             l_endIndex <= 1 )  then
            exit;
         end if;
         --Extra Precaution
         if (l_tab_index > 1500) then
            exit;
         end if;
      end loop;
      if (substr(p_bind_variables,length(p_bind_variables),1) = '~' and
          length(p_bind_variables) > 1)
      then
          --l_tab_index := l_tab_index+1;
          x_bind_var_tbl(l_tab_index) := null;
      end if;
END SETUP_BIND_VARIABLES;

--The api has been deprecated. But to be on the safer side has not been deleted.
FUNCTION GET_LAST_REFRESH_DATE(pObjectType varchar2, pFunctionName in varchar2) return varchar2 is
BEGIN
return GET_LAST_REFRESH_DATE(pObjectType, pFunctionName,'');
END GET_LAST_REFRESH_DATE;

--BugFix 2823330 Get Formatted Last Refresh Date
FUNCTION GET_LAST_REFRESH_DATE(pObjectType varchar2, pFunctionName in varchar2,pRFUrl in varchar2) return varchar2 is
  l_last_refresh_date DATE;
  l_last_date varchar2(200);
BEGIN
  -- ashgarg Bug Fix: 4227468
  --l_last_refresh_date := BIS_SUBMIT_REQUESTSET.get_last_refreshdate(pObjectType, null, pFunctionName);
  --l_last_date := to_char(l_last_refresh_date, fnd_profile.value_specific('ICX_DATE_FORMAT_MASK'));
  l_last_date := BIS_SUBMIT_REQUESTSET.get_last_refreshdate_url(pObjectType,null,pFunctionName,'N',pRFUrl);
  return l_last_date;

 exception
  when others then
         null;
END GET_LAST_REFRESH_DATE;

FUNCTION GET_LAST_REFRESH_DATE_URL(pObjectType in varchar2, pFunctionName in varchar2) return varchar2 IS
BEGIN
return GET_LAST_REFRESH_DATE_URL(pObjectType, pFunctionName,'');
END GET_LAST_REFRESH_DATE_URL;

FUNCTION GET_LAST_REFRESH_DATE_URL(pObjectType in varchar2, pFunctionName in varchar2,pRFUrl in varchar2)
return varchar2
IS
  l_last_refresh_string varchar2(32000);
BEGIN
   -- ashgarg Bug Fix: 4227468
   --l_last_refresh_string := BIS_SUBMIT_REQUESTSET.get_last_refreshdate_url(pObjectType,null,pFunctionName);
   l_last_refresh_string := BIS_SUBMIT_REQUESTSET.get_last_refreshdate_url(pObjectType,null,pFunctionName,'Y',pRFUrl);
   return l_last_refresh_string;
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
FUNCTION hasFunctionAccess(pUserId IN VARCHAR2, pFunctionName IN VARCHAR2, pPMVSpecific IN VARCHAR2) RETURN VARCHAR2
IS
  l_flag varchar2(1) := 'N';
BEGIN
  IF BIS_GRAPH_REGION_HTML_FORMS.hasFunctionAccess(pUserId, pFunctionName, pPMVSpecific) THEN
     l_flag := 'Y';
  END IF;
  RETURN l_flag;
END hasFunctionAccess;

--bug 3122867 - 09/05
PROCEDURE bis_run_function(
               pApplication_id IN VARCHAR2,
               pResponsibility_id IN VARCHAR2,
               pSecurity_group_id IN VARCHAR2,
               pFunction_id IN VARCHAR2,
               pParameters IN VARCHAR2 DEFAULT NULL
) IS
 lUrl VARCHAR2(2000);
BEGIN

 lUrl := icx_portlet.createExecLink(
                         p_application_id         => pApplication_id,
                         p_responsibility_id      => pResponsibility_id,
                          p_security_group_id      => pSecurity_group_id,
                          p_function_id            => pFunction_id,
                          p_parameters             => pParameters,
                          p_target                 => NULL,
                          p_link_name              => NULL,
                          p_url_only               => 'Y'
 );

 owa_util.redirect_url(lUrl) ;

END bis_run_function;

-- nbarik 03/01/2004
-- udua 07/25/2005 - Changed API name and behavior.
FUNCTION getParamPortletFuncName(pPageFunctionName IN VARCHAR2)
RETURN VARCHAR2
IS
CURSOR c_form_function IS
  SELECT web_html_call, parameters, type
  FROM fnd_form_functions
  WHERE function_name = pPageFunctionName;

CURSOR c_paramPortlet_funcName(p_menu_name VARCHAR2) IS
  SELECT FF.FUNCTION_NAME
  FROM FND_MENU_ENTRIES_VL MEV, FND_FORM_FUNCTIONS FF
  WHERE MEV.MENU_ID IN (
	SELECT  SUB_MENU_ID
	FROM FND_MENU_ENTRIES
	WHERE SUB_MENU_ID IS NOT NULL
	CONNECT BY  MENU_ID = PRIOR SUB_MENU_ID START WITH MENU_ID = (SELECT MENU_ID FROM FND_MENUS
    WHERE MENU_NAME=p_menu_name)
        )
	AND MEV.FUNCTION_ID = FF.FUNCTION_ID
    AND BIS_PMV_UTIL.getParameterValue(FF.PARAMETERS, 'pRequestType') = 'P';

CURSOR c_mds_paramPortlet_funcName(p_doc_id NUMBER) IS
select att_value
from jdr_attributes a, (select att_comp_docid, att_comp_seq from jdr_attributes
    where att_comp_docId in (select comp_docid from JDR_COMPONENTS
     where comp_element like 'oa:pageLayout'
and comp_id = 'BisPage')
and att_name = 'user:akAttribute3'
and att_value = 'PARAMETER_PORTLET') b
where a.att_comp_docId = b.att_comp_docid
and a.att_comp_seq = b.att_comp_seq
and a.att_name = 'user:akAttribute1'
and a.att_value is not null
and a.att_comp_docId=p_doc_id;

l_parameters		VARCHAR2(2000);
-- udua - 09.27.05 - R12 Mandatory Project - 4480009 [PMV Data-model Change].
l_region		    VARCHAR2(480);
l_index			    NUMBER;
l_type			    VARCHAR2(30);
l_web_html_call		VARCHAR2(240);
l_menu_type         VARCHAR2(30);
l_menu_name         VARCHAR2(2000);
l_doc_id            NUMBER;

BEGIN
  IF c_form_function%ISOPEN THEN
    CLOSE c_form_function;
  END IF;
  OPEN c_form_function;
  FETCH c_form_function INTO l_web_html_call, l_parameters, l_type;
  CLOSE c_form_function;
  IF (l_type = 'JSP' AND l_web_html_call LIKE 'OA.jsp?akRegionCode=BIS_COMPONENT_PAGE%') THEN
    l_menu_type := getParameterValue(l_parameters, 'sourceType');
    l_menu_name := getParameterValue(l_parameters, 'pageName');
    IF (l_menu_type = 'FND_MENU') THEN
      IF c_paramPortlet_funcName%ISOPEN THEN
        CLOSE c_paramPortlet_funcName;
      END IF;
      OPEN  c_paramPortlet_funcName(l_menu_name);
      FETCH c_paramPortlet_funcName INTO l_region;
      CLOSE c_paramPortlet_funcName;
    ELSIF (l_menu_type = 'MDS') THEN
      l_doc_id := getDocumentID(l_menu_name);
      IF c_mds_paramPortlet_funcName%ISOPEN THEN
        CLOSE c_mds_paramPortlet_funcName;
      END IF;
      OPEN  c_mds_paramPortlet_funcName(l_doc_id);
      FETCH c_mds_paramPortlet_funcName INTO l_region;
      CLOSE c_mds_paramPortlet_funcName;
    END IF;
  END IF;
  RETURN l_region;
END getParamPortletFuncName;

  --
  -- Retrieves the document id for the specified fully qualified path name.
  -- The pathname must begin with a '/' and should look something like:
  --   /oracle/apps/bis/mydocument
  --
  -- Parameters:
  --   fullPathName  - the fully qualified name of the document
  --
  -- Returns:
  --   Returns the ID of the path or -1 if no such path exists
  --
  FUNCTION getDocumentID(
    pFullPathName VARCHAR2) RETURN NUMBER
  IS
  l_full_path  VARCHAR2(512);
  l_name       VARCHAR2(60);
  --l_type       VARCHAR2(30);
  l_owner_id   NUMBER := 0;
  l_doc_id     NUMBER := -1;
  l_end_index  NUMBER;
  l_finished   BOOLEAN := FALSE;
  BEGIN
      -- remove the first forward slash
      l_full_path := substr(pFullPathName, instr(pFullPathName, '/') + 1);
      LOOP
        -- Retrieve the first portion of the path name. For example, if the
        -- fullPath is /oracle/apps/bis/mydocument, then l_name will
        -- be 'oracle'.
        l_end_index := instr(l_full_path, '/');
        IF l_end_index = 0 THEN
           l_end_index   := length(l_full_path);
           l_name        := substr(l_full_path, 1, l_end_index);
           l_finished    := TRUE;
        ELSE
           l_name    := substr(l_full_path, 1, l_end_index - 1);
           l_full_path := substr(l_full_path, l_end_index + 1);
        END IF;
        SELECT path_docid --, path_type
        INTO l_doc_id --, l_type
        FROM jdr_paths
        WHERE path_name = l_name AND path_owner_docid = l_owner_id;
        IF (l_finished) THEN
            return l_doc_id;
        END IF;
        l_owner_id := l_doc_id;
      END LOOP;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         return -1;
  END;

-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
FUNCTION getRoleIds(pPrivileges IN VARCHAR2) RETURN BISVIEWER.t_char IS
l_sql     VARCHAR2(3000);
l_privileges VARCHAR2(2000);
l_bind_values BISVIEWER.t_char;
l_roleIds VARCHAR2(2000);
l_cursor INTEGER;
ignore INTEGER;
l_bind_col varchar2(200);
l_menu_id NUMBER;
l_menu_id_tbl BISVIEWER.t_char;
l_count NUMBER := 1;
BEGIN
  l_sql := 'SELECT DISTINCT menu_id FROM fnd_menu_entries where function_id in (';
  l_privileges := replace(pPrivileges, ',', '~');
  SETUP_BIND_VARIABLES(
    p_bind_variables => l_privileges,
    x_bind_var_tbl => l_bind_values
  );
  IF (l_bind_values IS NOT NULL AND l_bind_values.COUNT > 0) THEN
    FOR i IN l_bind_values.FIRST..l_bind_values.LAST LOOP
      l_sql := l_sql || ':' || i;
      IF (i <> l_bind_values.COUNT) THEN
        l_sql := l_sql || ',';
      END IF;
    END LOOP;
    l_sql := l_sql || ')';
  END IF;
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, l_sql, DBMS_SQL.native);
  IF (l_bind_values.COUNT > 0) THEN
    FOR i IN l_bind_values.FIRST..l_bind_values.LAST LOOP
       l_bind_col := ':'|| i;
       dbms_sql.bind_variable(l_cursor, l_bind_col, l_bind_values(i));
    END LOOP;
  END IF;
  dbms_sql.define_column(l_cursor, 1, l_menu_id);
  ignore := DBMS_SQL.EXECUTE(l_cursor);
  LOOP
    IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
      -- get column values of the row
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_menu_id);
      l_menu_id_tbl(l_count) := l_menu_id;
      l_count := l_count + 1;
    ELSE
      -- No more rows
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(l_cursor);
  RETURN l_menu_id_tbl;
EXCEPTION
 WHEN OTHERS THEN
   IF DBMS_SQL.IS_OPEN(l_cursor) THEN
     DBMS_SQL.CLOSE_CURSOR(l_cursor);
   END IF;
END getRoleIds;

-- nbarik - 04/20/04 - Enhancement 3378782 - Parameter Validation
PROCEDURE getDelegations(
    pRoleIdsTbl IN BISVIEWER.t_char
  , pParamName  IN VARCHAR2
  , pParameterView IN VARCHAR2
  , pAsOfDate   IN DATE
  , xDelegatorIdTbl OUT NOCOPY BISVIEWER.t_char
  , xDelegatorValueTbl OUT NOCOPY BISVIEWER.t_char
) IS
l_sql     VARCHAR2(5000);
l_cursor INTEGER;
ignore INTEGER;
l_bind_col varchar2(200);
l_count NUMBER := 1;
l_delegation_id VARCHAR2(256);
l_delegation_value VARCHAR2(2000);
l_employeeId NUMBER;
l_delegation_param VARCHAR2(150);
l_index NUMBER;
l_error_message VARCHAR2(3000);
BEGIN
  l_sql := 'SELECT distinct delegations.instance_pk1_value, parameter_view.value FROM fnd_grants delegations, fnd_objects parameter_object, '
           || pParameterView || ' parameter_view WHERE delegations.GRANTEE_KEY = :1 and parameter_object.obj_name = :2 '
           || 'and trunc(:3) between trunc(delegations.start_date) and trunc(delegations.end_date) and delegations.instance_pk1_value = to_char(parameter_view.id)'
           || 'and delegations.object_id = parameter_object.object_id and delegations.menu_id in ( ';
  IF (pRoleIdsTbl IS NOT NULL AND pRoleIdsTbl.COUNT > 0) THEN
    FOR i IN pRoleIdsTbl.FIRST..pRoleIdsTbl.LAST LOOP
      l_sql := l_sql || ':' || (i+3);
      IF (i <> pRoleIdsTbl.COUNT) THEN
        l_sql := l_sql || ',';
      END IF;
    END LOOP;
    l_sql := l_sql || ')';
  END IF;
  l_employeeId := FND_GLOBAL.EMPLOYEE_ID;
  l_index := INSTR(pParamName, '+');
  l_delegation_param := substr(pParamName, 1, l_index-1);
  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, l_sql, DBMS_SQL.native);
  dbms_sql.bind_variable(l_cursor, ':1', l_employeeId || '');
  dbms_sql.bind_variable(l_cursor, ':2', l_delegation_param);
  dbms_sql.bind_variable(l_cursor, ':3', pAsOfDate);
  IF (pRoleIdsTbl.COUNT > 0) THEN
    FOR i IN pRoleIdsTbl.FIRST..pRoleIdsTbl.LAST LOOP
       l_bind_col := ':'|| (i+3);
       dbms_sql.bind_variable(l_cursor, l_bind_col, pRoleIdsTbl(i));
    END LOOP;
  END IF;
  dbms_sql.define_column(l_cursor, 1, l_delegation_id, 256);
  dbms_sql.define_column(l_cursor, 2, l_delegation_value, 2000);
  ignore := DBMS_SQL.EXECUTE(l_cursor);
  LOOP
    IF DBMS_SQL.FETCH_ROWS(l_cursor)>0 THEN
      -- get column values of the row
      DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_delegation_id);
      DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_delegation_value);
      xDelegatorIdTbl(l_count) := l_delegation_id;
      xDelegatorValueTbl(l_count) := l_delegation_value;
      l_count := l_count + 1;
    ELSE
      -- No more rows
      EXIT;
    END IF;
  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(l_cursor);
EXCEPTION
 WHEN OTHERS THEN
   IF DBMS_SQL.IS_OPEN(l_cursor) THEN
     DBMS_SQL.CLOSE_CURSOR(l_cursor);
   END IF;
END getDelegations;

--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getPortletType(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN VARCHAR2 IS
    l_request_type CHAR;
BEGIN
/*
  IF (upper(pType) = 'JSP' OR upper(pType) = 'WWW') THEN
    RETURN fnd_message.get_string('BIS', 'BIS_REPORT_TITLE');
  ELSE
    IF (upper(pType) = 'WEBPORTLET') THEN
        l_request_type := getParameterValue(pParameters, 'pRequestType');
        CASE l_request_type
           WHEN 'T' THEN RETURN fnd_message.get_string('BIS', 'BIS_TREND_TABLE');
           WHEN 'G' THEN RETURN fnd_message.get_string('BIS', 'BIS_TREND_GRAPH');
           WHEN 'P' THEN RETURN fnd_message.get_string('BIS', 'BIS_PARAMETERS');
           ELSE RETURN NULL;
        END CASE;
    ELSE
        RETURN NULL;
    END IF;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
*/
  RETURN null;

END getPortletType;

--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getPortletTypeCode(pType IN VARCHAR2, pParameters IN VARCHAR2) RETURN CHAR IS
    l_request_type CHAR;
BEGIN
  IF (upper(pType) = 'JSP' OR upper(pType) = 'WWW') THEN
    RETURN 'R';
  ELSE
    IF (upper(pType) = 'WEBPORTLET') THEN
        RETURN getParameterValue(pParameters, 'pRequestType');
    ELSE
        RETURN NULL;
    END IF;
  END IF;
EXCEPTION
 WHEN OTHERS THEN
  RETURN null;

END getPortletTypeCode;

--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getRegionCode(pType IN VARCHAR2, pParameters IN VARCHAR2, webHtmlCall IN VARCHAR2, functionName IN VARCHAR2) RETURN CHAR IS
    l_request_type CHAR;
BEGIN
/*
  CASE pType
    WHEN 'JSP' THEN RETURN getParameterValue(webHtmlCall, 'regionCode');
    WHEN 'WWW' THEN RETURN nvl(trim(getParameterValue(pParameters, 'pRegionCode')), getReportRegion(functionName));
    WHEN 'WEBPORTLET' THEN RETURN getParameterValue(pParameters, 'pRegionCode');
    ELSE RETURN NULL;
  END CASE;
EXCEPTION
 WHEN OTHERS THEN
*/
  RETURN null;

END getRegionCode;
--=============================================================================
-- gbhaloti 05/25/04 Generic Report Designer
FUNCTION getRegionApplicationName(pRegionCode IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR region_app_name_cursor(cp_region_code VARCHAR2) IS
SELECT application_name FROM ak_regions R, fnd_application_vl A
WHERE R.region_code = cp_region_code AND R.region_application_id = A.application_id;

l_code VARCHAR2(3);

  CURSOR app_name_from_table is
  SELECT application_name
  FROM fnd_application_vl app
  WHERE app.application_short_name = l_code;

l_region_app_name VARCHAR2(2000);

BEGIN

  IF region_app_name_cursor%ISOPEN THEN
    CLOSE region_app_name_cursor;
  END IF;

  OPEN region_app_name_cursor(pRegionCode);
  FETCH region_app_name_cursor INTO l_region_app_name;
  IF region_app_name_cursor%NOTFOUND THEN
    IF app_name_from_table%ISOPEN THEN
        CLOSE app_name_from_table;
    END IF;

    l_code := 'FND';
    OPEN app_name_from_table;
    FETCH app_name_from_table INTO l_region_app_name;
    CLOSE app_name_from_table;
  END IF;
  CLOSE region_app_name_cursor;

  RETURN l_region_app_name;
EXCEPTION
  WHEN others THEN
    IF region_app_name_cursor%ISOPEN THEN
      CLOSE region_app_name_cursor;
    END IF;

END getRegionApplicationName;
--==============================================================================

FUNCTION getRegionDataSourceType(pRegionCode IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR source_type_cursor(cp_region_code VARCHAR2) IS
SELECT attribute10 FROM ak_regions
WHERE region_code = cp_region_code;

l_source_type	VARCHAR2(150);

BEGIN

  IF source_type_cursor%ISOPEN THEN
    CLOSE source_type_cursor;
  END IF;

  OPEN source_type_cursor(pRegionCode);
  FETCH source_type_cursor INTO l_source_type;
  IF source_type_cursor%NOTFOUND THEN
     l_source_type := NULL;
  END IF;
  CLOSE source_type_cursor;

  RETURN l_source_type;
EXCEPTION
  WHEN others THEN
    IF source_type_cursor%ISOPEN THEN
      CLOSE source_type_cursor;
    END IF;

END getRegionDataSourceType;

-- msaran 08/31/2005 eliminate mod_plsql
PROCEDURE readBinaryFile (p_file_id IN VARCHAR2, content_type OUT NOCOPY VARCHAR2, data OUT NOCOPY BLOB) IS
 l_file_id VARCHAR2(100);
BEGIN
  l_file_id := icx_call.decrypt(p_file_id);
  select file_content_type, file_data
  into   content_type, data
  from   fnd_lobs
  where  file_id = l_file_id;
END readBinaryFile;


END BIS_PMV_UTIL;

/
