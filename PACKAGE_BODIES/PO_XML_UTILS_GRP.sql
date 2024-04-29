--------------------------------------------------------
--  DDL for Package Body PO_XML_UTILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_XML_UTILS_GRP" AS
/* $Header: POXMLUTB.pls 120.4.12010000.3 2011/08/26 09:46:50 kcthirum ship $ */
PROCEDURE getAttachmentUrl (p_document_id IN NUMBER, x_attachment_content OUT NOCOPY VARCHAR2) AS
BEGIN
SELECT url INTO x_attachment_content FROM fnd_documents_vl WHERE document_id=p_document_id;
EXCEPTION WHEN OTHERS THEN
NULL;
END getAttachmentUrl;

procedure getAttachment (p_media_id    in NUMBER,
                         p_datatype_id in NUMBER,
                         x_attachment_content out NOCOPY CLOB) as
   file_content       blob;
   l_short_text       varchar2(2000);
   l_long_text        long;
   len                number;

begin
   dbms_lob.createtemporary(x_attachment_content,TRUE,DBMS_LOB.SESSION);

   if (p_datatype_id = 1) then /* short_text */
      select short_text into l_short_text
        from fnd_documents_short_text
       where media_id = p_media_id;
      len := length(l_short_text);
      dbms_lob.write( lob_loc => x_attachment_content,
                       amount => len,
                       offset => 1,
                       buffer => l_short_text);

   elsif (p_datatype_id = 2) then  /* long_text  */
      select long_text into l_long_text
        from fnd_documents_long_text
       where media_id = p_media_id;
      len := length(l_long_text);
      dbms_lob.write( lob_loc => x_attachment_content,
                       amount => len,
                       offset => 1,
                       buffer => l_long_text);

   end if;

   exception when others then
      null; -- We don't want to raise the exception here as it will stop generation of XML

end getAttachment;

procedure getAttachmentFile (p_media_id    in NUMBER,
                             p_pk1_value   in NUMBER,
                             p_pk2_value   IN NUMBER,
                             p_pk3_value   IN NUMBER,
                             p_pk4_value   IN NUMBER,
                             p_pk5_value   IN NUMBER,
                             p_entity_name IN VARCHAR2,
                             x_cid out NOCOPY VARCHAR2) as
   l_lang        varchar2(30);

begin

     select userenv('LANG') into l_lang from dual;


     ECX_ATTACHMENT.register_attachment(p_entity_name, p_pk1_value, p_pk2_value,
                                          p_pk3_value, p_pk4_value, p_pk5_value,
                                           p_media_id, 6, x_cid);

   exception when others then
      null; -- We don't want to raise the exception here as it will stop generation of XML

end getAttachmentFile;

/* split ECX_PARAMETER3 to user_id, responsibility_id and application_id */
procedure splitforids (p_ecx_parameter3    in VARCHAR2,
                       x_user_id        out NOCOPY NUMBER,
                       x_resp_id        out NOCOPY NUMBER,
                       x_appl_id        out NOCOPY NUMBER)
is
   l_resp_appl varchar2(150);

begin
   x_user_id := to_number(substr(p_ecx_parameter3, 1, instr(p_ecx_parameter3,':')-1));
   l_resp_appl := substr(p_ecx_parameter3, instr(p_ecx_parameter3,':')+1);
   x_resp_id := to_number(substr(l_resp_appl, 1, instr(l_resp_appl,':')-1));
   x_appl_id := to_number(substr(l_resp_appl, instr(l_resp_appl,':')+1));

   exception
      when others then
        wf_core.context('PO_XML_UTILS_GRP','splitforids',SQLERRM);
        raise;

end splitforids;


procedure getBlanketPONumber (p_release_id    in NUMBER,
                              p_po_type       in VARCHAR2,
                              p_Blanket_PO_Num	out NOCOPY VARCHAR2
                             )
is

begin
  if (upper(p_po_type) = 'RELEASE') then
     /*
     select pha.segment1 into p_blanket_po_num
     from po_headers_all pha, po_releases_all pra
     where pra.po_header_id = pha.po_header_id and
           pra.po_release_id = p_release_id;
      */
      select segment1 into p_blanket_po_num
      from po_headers_all
      where po_header_id = p_release_id;
  end if;

  exception
     when others then
	wf_core.context('PO_XML_UTILS_GRP','splitforids',SQLERRM);
	-- raise;  we don't want to raise exception here as it will lead to failure in XML gen.


end getBlanketPONumber;

--Bug 6692126 Changing the signature of this procedure
procedure getTandC (p_document_id	in NUMBER,
                    p_document_type	in VARCHAR2,
                    x_TandCcontent out NOCOPY CLOB)
is

   l_filedir    varchar2(256);
   l_filename   varchar2(256);
   l_filename_lang  varchar2 (600);
   v_filehandle     UTL_FILE.file_type;
   l_terms        varchar2(32000);
   voffset      integer := 1;
   l_newline varchar2(10); -- bug#4278861: stores new line value

begin

  /*  initialize APPS context  */
  /*Bug 6692126 Call procedure get_preparer_profile instead of getting profile options in preparers context*/
  /* fnd_global.APPS_INITIALIZE (p_user_id, p_resp_id, p_appl_id);
   FND_PROFILE.GET('PO_EMAIL_TERMS_DIR_NAME', l_filedir);
   FND_PROFILE.GET('PO_EMAIL_TERMS_FILE_NAME', l_filename); */

   l_filedir :=    PO_COMMUNICATION_PVT.get_preparer_profile(p_document_id,p_document_type,'PO_EMAIL_TERMS_DIR_NAME');
   l_filename :=   PO_COMMUNICATION_PVT.get_preparer_profile(p_document_id,p_document_type,'PO_EMAIL_TERMS_FILE_NAME');

   --bug#4278861: populate l_newline with new line value from FND_GLOBAL
   select fnd_global.NEWLINE into l_newline from dual;

  if ((l_filedir is not null) and (l_filename is not null)) then

  /* Check for supplier site language tandc file first if that doesn't exist then check for base language tandc file else check for just l_filename */
     l_filename_lang := l_filename || '_' || userenv('LANG');

     BEGIN
	/* open the file */

	v_filehandle := UTL_FILE.FOPEN(l_filedir,l_filename_lang,'r',32000); --bug#4278861: Open the file handle with 32k buffer

     EXCEPTION WHEN OTHERS THEN

	BEGIN
	   l_filename_lang := l_filename || '_' || fnd_global.base_language;
       	   v_filehandle := UTL_FILE.FOPEN(l_filedir,l_filename_lang, 'r',32000); --bug#4278861: Open the file handle with 32k buffer

        EXCEPTION WHEN OTHERS THEN
          begin
	    v_filehandle := UTL_FILE.FOPEN(l_filedir,l_filename, 'r',32000); --bug#4278861: Open the file handle with 32k buffer
          exception when others then
            return;
          end;
	END;
     END;

     dbms_lob.createtemporary(x_TandCcontent,TRUE,DBMS_LOB.SESSION);

     /* Read the file line by line and append it to CLOB */
     if (UTL_FILE.is_open(v_filehandle) = true) then
        loop
          begin
            /* write the contents into the document */
            UTL_FILE.GET_LINE(v_filehandle,l_terms);
            if (l_terms is null) then
               l_terms := ' ';
            end if;
	    l_terms :=  l_terms||l_newline; --bug#4278861: Appended the new line to the line read from file
            dbms_lob.write(x_TandCcontent,length(l_terms),voffset,l_terms);
	    voffset := voffset + length(l_terms);

	    --bug#4278861: Commented the code as it adds extra space to the output dbms_lob
	    --l_terms := ' ';
	    --dbms_lob.write(x_TandCcontent,length(l_terms),voffset,l_terms);
	    --voffset := voffset + length(l_terms);


          exception when no_data_found then
            exit;
          end;
        end loop;
        UTL_FILE.fclose(v_filehandle);
     end if;
  end if;

   exception when others then
      --dbms_output.put_line(SQLERRM);
      null; -- We don't want to raise the exception here as it will stop generation of XML

end getTandC;

/*Added for bug#6912518*/
procedure getTandCforXML (p_po_header_id in NUMBER,
 	                  p_po_release_id in NUMBER,
 	                  x_TandCcontent out NOCOPY CLOB)
is
begin

if p_po_release_id is null then
getTandC (p_po_header_id, 'STANDARD', x_TandCcontent);
else
getTandC (p_po_release_id, 'RELEASE', x_TandCcontent);
end if;

exception when others then
--dbms_output.put_line(SQLERRM);
null; -- don't raise exception as it will stop generation of XML
end getTandCforXML;

procedure regenandsend(p_po_header_id in NUMBER,
                       p_po_type         in VARCHAR2,
                       p_po_revision  in NUMBER,
                       p_user_id in  NUMBER,
                       p_responsibility_id in NUMBER,
                       p_application_id NUMBER,
                       p_preparer_user_name VARCHAR2)
IS

x_progress VARCHAR2(100) := '000';
l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
l_event_key varchar2(100);
l_event_key2 varchar2(100);
l_wf_item_seq number;
l_wf_item_seq2 number;
l_event_name varchar2(100) := 'oracle.apps.po.event.setxml';
l_org_id   number;
l_po_number   varchar2(100);
INVALID_TXN_TYPE EXCEPTION;
BEGIN


wf_core.context('PO_ECX_UTIL_PKG','regenandsend',x_progress);

-- Create EVENT_KEY and EVENT_NAME
select PO_WF_ITEMKEY_S.nextval into l_wf_item_seq from dual;
l_event_key := to_char(p_po_header_id) || '-' || to_char(l_wf_item_seq);

x_progress := '001';
wf_core.context('POM_ECX_UTIL_PKG','regenandsend',x_progress);

if (upper(p_po_type) = 'RELEASE') then
  select pha.segment1, pha.org_id
  into l_po_number, l_org_id
  from po_releases_all pra, po_headers_all pha
  where pra.po_release_id = p_po_header_id
  and pra.po_header_id = pha.po_header_id;


elsif (upper(p_po_type) = 'STANDARD') then
  select pha.segment1, pha.org_id
  into l_po_number, l_org_id
  from po_headers_all pha
  where pha.po_header_id = p_po_header_id;
/*
else  ideally we should raise an exception.
*/


end if;
x_progress := '002';
wf_core.context('POM_ECX_UTIL_PKG','regenandsend',x_progress);

-- Add Parameters
wf_event.AddParameterToList(p_name =>'DOCUMENT_ID',
			    p_value => p_po_header_id,
			    p_parameterlist => l_parameter_list);

wf_event.AddParameterToList(p_name =>'DOCUMENT_TYPE',
			    p_value => p_po_type,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'PO_REVISION_NUM',
			    p_value => p_po_revision,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'USER_ID',
			    p_value => p_user_id,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'RESPONSIBILITY_ID',
			    p_value => p_responsibility_id,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'APPLICATION_ID',
			    p_value => p_application_id,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'PREPARER_USER_NAME',
			    p_value => p_preparer_user_name,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'ORG_ID',
			    p_value => l_org_id,
			    p_parameterlist => l_parameter_list);
wf_event.AddParameterToList(p_name =>'PO_NUMBER',
			    p_value => l_po_number,
			    p_parameterlist => l_parameter_list);






-- dbms_output.put_line (l_event_key);

x_progress := '002';
wf_core.context('PO_ECX_UTIL_PKG','regenandsend',x_progress);
wf_event.raise(	p_event_name => l_event_name,
			p_event_key => l_event_key,
			p_parameters => l_parameter_list);
x_progress := '002';




l_parameter_list.DELETE;
commit;
EXCEPTION
  when others then
    x_progress := x_progress || SQLERRM;
    wf_core.context('PO_ECX_UTIL_PKG','regenandsend',x_progress);

--dbms_output.put_line (SQLERRM);
   raise;


END regenandsend;

procedure getGlobalAgreementInfo (p_po_line_id  in NUMBER,
                                  x_GLOBALCONTRACT OUT NOCOPY VARCHAR2,
                                  x_GLOBALCONTRACTLIN  OUT NOCOPY VARCHAR2) is
begin

	select glblH.segment1
	into  x_GLOBALCONTRACT
	from po_headers_all glblH, po_lines_all glblSPO
	where glblSPO.po_line_id = p_po_line_id and
	glblSPO.from_header_id = glblH.po_header_id and
	glblH.global_agreement_flag = 'Y';

	select to_char(glblL.line_Num)
	into x_GLOBALCONTRACTLIN
	from po_lines_all glblL, po_lines_all glblSPO
	where glblSPO.po_line_id = p_po_line_id and
	glblSPO.from_line_id = glblL.po_line_id;

  EXCEPTION
    when others then
      null;  --We don't want to raise here as this would break the XML generation.

end;

procedure getTaxDetails (p_po_line_loc_id   IN NUMBER,
                         x_TAX_RATE  OUT NOCOPY varchar2,
                         x_IS_VAT_RECOVERABLE OUT NOCOPY varchar2,
                         x_TAX_TYPE  OUT NOCOPY varchar2,
                         x_TAX_NAME  OUT NOCOPY varchar2,
                         x_ESTIMATED_TAX_AMOUNT OUT NOCOPY number,
                         x_TAX_DESCRIPTION OUT NOCOPY varchar2
                         ) is
l_isTaxable  varchar2(1);
l_po_line_id number;
l_type_1099  varchar2(10);
l_tax_id     number;
l_TAX_RECOVERY_RATE number;


begin

  select po_line_id, TAXABLE_FLAG, ESTIMATED_TAX_AMOUNT
  into   l_po_line_id, l_isTaxable, x_ESTIMATED_TAX_AMOUNT
  from   po_line_locations_archive_all
  where line_location_id = p_po_line_loc_id;

  if (l_isTaxable = 'Y') then
    select TAX_NAME, TYPE_1099, TAX_CODE_ID
    into  x_TAX_NAME, l_type_1099, l_tax_id
    from PO_LINES_ARCHIVE_ALL
    where PO_LINE_ID = l_po_line_id and taxable_flag = 'Y';
  else
    /*  bottom two are mandatory fields in cXML.  So always populate these.  */
    x_ESTIMATED_TAX_AMOUNT := 0;
    x_TAX_TYPE := 'Non-Taxable';

  end if;

  if (l_tax_id is not null) then
    select NAME, TAX_TYPE, DESCRIPTION, TAX_RATE, TAX_RECOVERY_RATE
    into   x_TAX_NAME, x_TAX_TYPE, x_TAX_DESCRIPTION, x_TAX_RATE, l_TAX_RECOVERY_RATE
    from AP_TAX_CODES_ALL
    where tax_id = l_tax_id;

    if (x_TAX_TYPE = 'VAT' and l_tax_recovery_rate = 100) then
      x_IS_VAT_RECOVERABLE := 'yes';
    else
      x_IS_VAT_RECOVERABLE := '';
    end if;

  end if;

  exception when others then
    null;  --We don't want to raise the exception here as it will stop generation of XML.

end;

procedure getTaxInfo (p_po_line_loc_id   IN NUMBER,
                      X_TAXABLE OUT NOCOPY varchar2) is

begin

  select TAXABLE_FLAG
  into   X_TAXABLE
  from   po_line_locations_archive_all
  where  line_location_id = p_po_line_loc_id;

  if (X_TAXABLE = 'Y') then
    X_TAXABLE := 'Taxable';
  elsif (X_TAXABLE = 'N') then
    X_TAXABLE := 'Nontaxable';
  end if;

  exception when others then
    null;  --We don't want to raise exception here to stop generation of XML.
end getTaxInfo;

procedure getUserEnvLang (x_lang  OUT NOCOPY varchar2) is

begin

  select userenv('lang') into x_lang from dual;
  exception when others then
  x_lang := 'US';  --We don't want to error out here.  Instead let default be : 'US'.
end;

END PO_XML_UTILS_GRP;



/
