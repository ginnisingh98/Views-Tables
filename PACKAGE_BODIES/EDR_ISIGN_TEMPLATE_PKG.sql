--------------------------------------------------------
--  DDL for Package Body EDR_ISIGN_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_ISIGN_TEMPLATE_PKG" AS
/* $Header: EDRITPB.pls 120.0.12000000.1 2007/01/18 05:54:05 appldev ship $ */

-- EDR_ISIGN_TEMPLATE_PKG.GET_XSLFO_TEMPLATE procedure is called from EDRRuleXMLPublisherHandler Class
-- to get the handle of XSLFO Blob. It passes template name and template type as input and get the template
-- blob and other information as output.

-- P_STYLE_SHEET        - Original file name of template
-- P_STYLE_SHEET_VER    - Version label of template
-- X_SS_BLOB            - Blob containing template
-- X_SS_APPROVED        - Is template approved Y or N
-- X_ERROR_CODE         - Error code if XSLFO cannot be found
-- X_ERROR_MSG          - Error message in case of any errors

PROCEDURE GET_XSLFO_TEMPLATE(      p_style_sheet VARCHAR2,
                                   p_style_sheet_ver VARCHAR2,
				   x_ss_blob out nocopy BLOB,
                                   x_ss_approved out nocopy VARCHAR2,
                                   x_ss_type out nocopy VARCHAR2,
				   x_error_code out nocopy VARCHAR2,
                                   x_error_msg OUT NOCOPY VARCHAR2)
AS

l_status VARCHAR2(1) ;
l_fnd_document_id NUMBER ;
l_file_id_template  NUMBER;
l_position number ;

BEGIN
      --Bug 4074173 : start
           l_status  := 'F';
           l_fnd_document_id  := null;
           l_file_id_template := null;
      --Bug 4074173 : end

    BEGIN
           -- Bug 3461469 - Start - changed query criteria to file_name
     	   SELECT
   		status , fnd_document_id, file_id
	   INTO
   		l_status , l_fnd_document_id, l_file_id_template
       	   FROM
   		edr_files_b
	   WHERE
   		file_name = p_style_sheet
	   AND
   	    version_label = p_style_sheet_ver
	   AND
             attribute_category = 'EDR_EREC_TEMPLATE';
          -- Bug 3461469 - End

    EXCEPTION
          WHEN   NO_DATA_FOUND THEN
         	   x_error_msg := 'Required Template is not found';
       	           x_error_code := '100';
       		   RETURN;
     END;

     IF (l_status = 'A') THEN
           x_ss_approved := 'Y';
     ELSE
           x_ss_approved := 'N';
     END IF;


     SELECT fnl.FILE_DATA into x_ss_blob
     FROM
	 	  fnd_lobs fnl,
		  fnd_attached_documents fnddoc,
  		  fnd_documents_vl fndt
	 WHERE fnddoc.ENTITY_NAME = 'EDR_XSLFO_TEMPLATE'
 	 AND   fnddoc.pk1_value = to_Char(l_file_id_template)
	 AND	  fnddoc.document_id = fndt.document_id
	 AND   fndt.media_id = fnl.file_id
	 AND   fnddoc.document_id =(select max(document_id)
	 						   from
							     fnd_attached_documents
	 						   where	 									 						     pk1_value = to_char(l_file_id_template)
							   and	entity_name = 'EDR_XSLFO_TEMPLATE');

 	 l_position := instr(p_style_sheet, '.xsl',1);

     if(l_position > 0) then
           x_ss_type := 'XSL';
     else if (instr(p_style_sheet, '.rtf',1) > 0) then
           x_ss_type := 'RTF';
	 else if (instr(p_style_sheet, '.pdf',1) >0 ) then
          	 x_ss_type := 'PDF';
    	 end if;
       end if;
     end if;

END GET_XSLFO_TEMPLATE;

-- EDR_ISIGN_TEMPLATE_PKG.GET_TEMPLATE procedure is called from TemplateManager Class
-- to get the handle of RTF Template Blob. It passes unique p_event_key which is equal
-- to file_id in ISIGN edr_files_b table.
--
-- P_EVENT_KEY          - File Id for the ISIGN EDR_FILES_B Table repository
-- X_TEMPALTE_TYPE      - Return template type as string e.g. RTF, XSL, PDF
-- X_TEMPLATE_BLOB      - Return Template contents in BLOB
-- X_TEMPLATE_FILE_NAME - Return Template File Name as String

PROCEDURE GET_TEMPLATE (p_event_key VARCHAR2,
		  	x_template_type OUT NOCOPY VARCHAR2,
			x_template_blob OUT NOCOPY BLOB,
			x_template_file_name OUT NOCOPY VARCHAR2
		       )
AS
  	l_file_name	 varchar2(256);
	l_position number;
	l_extension varchar2(10);
	l_file_data BLOB;
	l_display_name varchar2(256);
BEGIN
        --Bug : 3499311 : Start -  Specified number format in call TO_NUMBER
        select fl.file_data, isign_files.ORIGINAL_FILE_NAME, isign_files.FILE_NAME
		into l_file_data, l_file_name, l_display_name
	from
		fnd_lobs fl, fnd_documents_vl fdt, edr_files_b isign_files
 	where
		 isign_files.file_id = to_number(p_event_key,'999999999999.999999')
	and fdt.document_id = isign_files.fnd_document_id
	and fl.file_id = fdt.media_id;
        --Bug : 3499311 : End

	l_position := instr(l_file_name,'.',1);
        l_extension := substr(l_file_name, l_position+1,3);

	x_template_type := UPPER(l_extension);
	x_template_blob := l_file_data;
	x_template_file_name := l_display_name;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	BEGIN
		 x_template_type := 'NOTFOUND';
		 x_template_blob := null;
		 x_template_file_name := 'NOTFOUND';
	END;

END GET_TEMPLATE;

END EDR_ISIGN_TEMPLATE_PKG;

/
