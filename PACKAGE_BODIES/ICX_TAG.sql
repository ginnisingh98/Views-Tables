--------------------------------------------------------
--  DDL for Package Body ICX_TAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_TAG" as
/* $Header: ICXTAGB.pls 115.3 99/07/17 03:29:32 porting ship $ */

-----------------------------------------------------------
 PROCEDURE TAG_MAINT is
-----------------------------------------------------------
v_help_url VARCHAR2(2000) := NULL;
v_language_code VARCHAR2(30) :=NULL;
v_title varchar2(45) ;
v_prompts icx_util.g_prompts_table;
v_line_table       icx_util.char240_table;
v_tag_val varchar2(40);
v_new_proc varchar2(100);
v_new_prompt varchar2(100);
v_order_by varchar2(100);


BEGIN

IF icx_sec.validateSession THEN
    v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    v_help_url := '/OA_DOC/' || v_language_code ||'/awc' ||  '/icxstim.htm';

   htp.htmlOpen;
   htp.title('HTML Template Tags');
   htp.headOpen;
   js.scriptOpen;

/****** Assigns the help page and paints the toolbar *******/

   icx_admin_sig.help_win_script('/OA_DOC/'||v_language_code||'/awc/FILL_IN_LATER.htm');
   js.scriptClose;
   icx_admin_sig.toolbar(language_code => v_language_code);


/***** Gets the title of the page *******/

   icx_util.getprompts(601,'ICX_TEMPL_TAG_HDR_R',v_title,v_prompts);
   htp.p('<b><h2>'||v_title||'</b></h2>');
   htp.p('<TD WIDTH=2000 bgcolor=#0033FF><IMG SRC=/OA_MEDIA/'|| v_language_code || '/FNDIBLBR.gif WIDTH=890 HEIGHT=2></TD>');


   htp.headClose;
   js.scriptClose;

   v_order_by := 'TAG_NAME';
/*****Prints the tags ******/

  ak_query_pkg.exec_query( P_PARENT_REGION_APPL_ID => 601,
      P_PARENT_REGION_CODE		           => 'ICX_TEMPL_TAG_HDR_R',
      P_ORDER_BY_CLAUSE         		   => v_order_by,
      P_RESPONSIBILITY_ID			   => icx_sec.getID( icx_sec.PV_RESPONSIBILITY_ID ),
      P_USER_ID					   => icx_sec.getID( icx_sec.PV_WEB_USER_ID ),
      P_RETURN_PARENTS 				   => 'T');

  if ak_query_pkg.g_results_table.COUNT > 0 then


     for i in ak_query_pkg.g_results_table.first .. ak_query_pkg.g_results_table.last loop

         icx_util.transfer_row_to_column(ak_query_pkg.g_results_table(i),v_line_table);

          for k in ak_query_pkg.g_items_table.first..ak_query_pkg.g_items_table.last loop

          if ak_query_pkg.g_items_table(k).secured_column = 'F' and
            ak_query_pkg.g_items_table(k).node_display_flag = 'Y'  and
            ak_query_pkg.g_items_table(k).value_id is not NULL  then
            v_tag_val := (v_line_table(ak_query_pkg.g_items_table(k).value_id));
            htp.p('<A HREF ="icx_tag.tag_det?p_tag='||v_tag_val||'">'||v_tag_val||'</A>');
            htp.p('<BR>');

          end if;
     end loop;
 end loop ;

/***********Paint New Button*********/
v_new_proc := 'icx_tag.tag_det';
v_new_prompt := 'ADD NEW TAG';

htp.p('<br> <br>');
icx_util.DynamicButton(P_ButtonText => v_new_prompt,
                       P_ImageFileName      => 'FNDBNEW',
                       P_OnMouseOverText    => v_new_prompt,
                       P_HyperTextCall      => v_new_proc,
                       P_LanguageCode       => v_language_code,
                       P_JavaScriptFlag     => FALSE);

  else

     htp.bodyOpen('','BGCOLOR="#CCFFCC"');
     fnd_message.set_name('ICX','ICX_NO_RECORDS_FOUND');
     htp.p('<H3>'||fnd_message.get||'</H3>');
     htp.bodyClose;

  end if;


END IF;
end tag_maint;


----------------------------------------------------------------------
PROCEDURE TAG_DET (p_tag IN varchar2 default NULL,
                   p_copy varchar2 default NULL) IS
----------------------------------------------------------------------


CURSOR c_application
 is
 select application_id, application_name from fnd_application_vl;
 v_replacement_text_temp varchar2(4000) default null;
l_application_id number;
l_application_name varchar2(50) := null;
v_application_name varchar2(50) :=null;
v_help_url VARCHAR2(2000) := NULL;
v_language_code VARCHAR2(30) :=NULL;
v_title varchar2(45) ;
v_prompts icx_util.g_prompts_table;
v_where_clause  varchar2(1000);
v_tag_name varchar2(200) default NULL;
v_application_id number default NULL;
v_tag_description varchar2(4000) default NULL;
v_replacement_text varchar2(4000) default NULL;
v_protected varchar2(1) default NULL;
p_copy_temp varchar2(1);

BEGIN

IF icx_sec.validateSession THEN
    v_language_code := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    v_help_url := '/OA_DOC/' || v_language_code ||'/awc' ||  '/icxstim.htm';

   htp.htmlOpen;
   htp.title('HTML Template Tags');
   htp.headOpen;
   js.scriptOpen;


     htp.p('function submit_request() {
	var name_msg = "Please enter values for all the fields"
	if (document.enter_tag.p_tag_name.value == "")
		{  alert(name_msg);}
	else if (document.enter_tag.p_tag_description.value =="")
		{ alert (name_msg); }
	else if (document.enter_tag.p_replacement_text.value =="")
		{alert (name_msg);}
	else
	 {document.enter_tag.submit()  	}
	     }
  ');


    htp.p('function revert() {
      document.enter_tag.reset() }');


/****** Assigns the help page and paints the toolbar *******/

   icx_admin_sig.help_win_script('/OA_DOC/'||v_language_code||'/awc/FILL_IN_LATER.htm');
   js.scriptClose;
   icx_admin_sig.toolbar(language_code => v_language_code);

/***** Gets the title of the page *******/

   icx_util.getprompts(601,'ICX_TEMPL_TAG_DTLS_R',v_title,v_prompts);
   htp.p('<b><h2>'||v_title||'</b></h2>');
   htp.p('<TD WIDTH=2000 bgcolor=#0033FF><IMG SRC=/OA_MEDIA/'|| v_language_code || '/FNDIBLBR.gif WIDTH=890 HEIGHT=2></TD>');


   htp.headClose;
   js.scriptClose;


 htp.formOpen('icx_tag.update_tag_det','POST','','','NAME="enter_tag"');

 /************Prints the page for a new or unprotected tag*******************/

 IF p_tag IS NOT NULL THEN
  select
  	tag_name,
        application_id,
        tag_description,
        replacement_text,
        protected
  into
        v_tag_name,
        v_application_id,
        v_tag_description,
        v_replacement_text,
        v_protected
  from
        icx_template_tags
   where
        tag_name = p_tag;
 END IF;


IF v_protected = 'N'  OR p_tag is null OR p_copy = 'Y' THEN

     htp.tableOpen;
	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(1)||'</B></TD>');

/**********Leave the name field blank if it is being copied **************/
IF p_copy ='Y' then
	htp.tableData(cvalue => htf.formText(cname => 'p_tag_name', csize => '40'));
ELSE
	htp.tableData(cvalue => htf.formText(cname => 'p_tag_name', csize => '40', cvalue => v_tag_name));
END IF;
	htp.tableRowClose;

	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(2)||'</B></TD>');
        htp.p('<TD>');
        htp.formSelectOpen ('p_application_id');
        open c_application;
        loop
        fetch c_application into l_application_id, l_application_name;
        IF c_application%notfound then exit;
        END IF;
        IF v_application_id = l_application_id THEN
          htp.p('<option value = '||l_application_id||' SELECTED>'||l_application_name||'');
        ELSIF
          l_application_id = 178 THEN
                        htp.p('<option value = '||l_application_id||' SELECTED>'||l_application_name||'');
	ELSE
          htp.p('<option value = '||l_application_id||' >'||l_application_name||'');
        END IF;
        end loop;
        htp.p('</select');
        htp.p('</TD');
        htp.tableRowClose;

	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(3)||'</B></TD>');
	htp.p('<td>');
	htp.p('<TEXTAREA NAME ="p_tag_description" COLS ="60" ROWS ="5">'||v_tag_description||'</TEXTAREA>');
	htp.p('</td>');
	htp.tableRowClose;


	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(4)||'</B></TD>');
	htp.p('<td>');
	v_replacement_text_temp := (''||v_replacement_text||'');
	htp.p('<TEXTAREA NAME ="p_replacement_text" COLS ="60" ROWS ="5">'||v_replacement_text_temp||'</TEXTAREA>');
	htp.p('</td>');
	htp.tableRowClose;
	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(5)||'</B></TD>');

	htp.p('<td>');
	htp.p('<SELECT NAME= "p_protected">');
	htp.p('<option value="Y" >Yes');
	htp.p('<option value="N" selected>No');
	htp.p('</select>');
	htp.p('</td>');
    htp.tableClose;
    htp.p('<BR><BR>');
    /**********Paints the Save Button************/
 icx_util.DynamicButton(P_ButtonText => 'SAVE',
			       P_ImageFileName => 'FNDBSAVE',
			       P_OnMouseOverText => 'SAVE',
                               P_HyperTextCall => 'javascript:submit_request()',
                               P_LanguageCode => v_language_code,
                               P_JavaScriptFlag => FALSE);

/**********Paints the Revert Button*******/
 icx_util.DynamicButton(P_ButtonText => 'REVERT',
			 P_ImageFileName => 'FNDBCLR',
			 P_OnMouseOverText =>'REVERT',
			 P_HyperTextCall => 'javascript:revert()',
			 P_LanguageCode => v_language_code,
			 P_JavaScriptFlag => FALSE);

/**********Paints the Copy Button for existing tags*******/
	IF p_copy IS NULL and p_tag IS NOT NULL THEN
	p_copy_temp := 'Y';
	  icx_util.DynamicButton(P_ButtonText => 'COPY',
			 P_ImageFileName => 'FNDBNEW',
			 P_OnMouseOverText =>'COPY TAG',
			 P_HyperTextCall => 'icx_tag.tag_det?p_tag='||v_tag_name||'&p_copy='||p_copy_temp,
			 P_LanguageCode => v_language_code,
			 P_JavaScriptFlag => FALSE);
	END IF;


  ELSE
/********Prints the data as text for tags which are protected*********/
   htp.tableOpen;

	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(1)||'</B></TD>');
	htp.p('<td>');
	htp.p (v_tag_name);
	htp.p('</td>');
	htp.tableRowClose;

	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(2)||'</B></TD>');
	open c_application;
        loop
        fetch c_application into l_application_id, l_application_name;
        IF c_application%notfound then
        	exit;
        END IF;
	IF l_application_id = v_application_id THEN
	 	v_application_name := l_application_name;
	END IF;
	end loop;
	htp.p('<td>');
	htp.p (v_application_name);
	htp.p('</td>');
	htp.tableRowClose;


	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT  ><B>'||v_prompts(3)||'</B></TD>');
	htp.p('<td>');
	htp.p (v_tag_description);
	htp.p('</td>');
	htp.tableRowClose;


	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT ><B>'||v_prompts(4)||'</B></TD>');
	htp.p('<TD ALIGN = BOTTOM>');
	htp.p('<xmp>');
	htp.p (v_replacement_text);
	htp.P('</xmp>');
	htp.p('</TD>');
	htp.tableRowClose;

	htp.tableRowOpen;
	htp.p('<TD ALIGN = RIGHT><B>'||v_prompts(5)||'</B></TD>');
	htp.p('<td>');
	htp.p ('YES');
	htp.p('</td>');
	htp.tableRowClose;
   htp.tableClose;
   htp.p('<BR> <BR>');

   /**********Paints the Copy Button *******/
	   p_copy_temp := 'Y';
	   icx_util.DynamicButton(P_ButtonText => 'COPY',
			 P_ImageFileName => 'FNDBCLR',
			 P_OnMouseOverText =>'COPY TAG',
			 P_HyperTextCall => 'icx_tag.tag_det?p_tag='||v_tag_name||'&p_copy='||p_copy_temp,
			 P_LanguageCode => v_language_code,
			 P_JavaScriptFlag => FALSE);

 END IF;
htp.formClose;

htp.htmlClose;


END IF;

END   tag_det;

 -------------------------------------------------------------------
 PROCEDURE update_tag_det (p_tag_name varchar2 ,
			  p_application_id number := null,
			  p_tag_description varchar2 := null,
			  p_replacement_text varchar2 :=null,
			  p_protected varchar2 := null) AS
-------------------------------------------------------------------
v_tag_name_exists number;

BEGIN
select count(*) into v_tag_name_exists from
	icx_template_tags
	where tag_name = p_tag_name;
IF v_tag_name_exists =1 THEN
   UPDATE ICX_TEMPLATE_TAGS SET application_id = p_application_id,
                                tag_description = p_tag_description,
                                replacement_text = p_replacement_text,
                                protected = upper(p_protected),
                                last_updated_by = -1,
                                last_update_date = sysdate
   WHERE    tag_name = p_tag_name     ;

ELSE
   insert into icx_template_tags(
   				tag_name,
   				application_id,
   				tag_description,
   				replacement_text,
   				protected,
   				last_updated_by,
   				last_update_date,
   				creation_date,
   				created_by )
   			values
   				(p_tag_name,
   				p_application_id,
   				p_tag_description,
   				p_replacement_text,
   				p_protected,
   				-1,
   				sysdate,
   				sysdate,
   				-1);
END IF;
icx_tag.tag_maint;
exception
when others then
 htp.p(sqlerrm);


END update_tag_det;


end icx_tag;


/
