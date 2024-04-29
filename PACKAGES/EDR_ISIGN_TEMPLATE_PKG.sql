--------------------------------------------------------
--  DDL for Package EDR_ISIGN_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_ISIGN_TEMPLATE_PKG" AUTHID CURRENT_USER AS
/*  $Header: EDRITPS.pls 120.0.12000000.1 2007/01/18 05:54:08 appldev ship $ */


-- EDR_ISIGN_TEMPLATE_PKG.GET_XSLFO_TEMPLATE procedure is called from EDRRuleXMLPublisherHandler Class
-- to get the handle of XSLFO Blob. It passes template name and template type as input and get the template
-- blob and other information as output.

-- P_STYLE_SHEET        - Original file name of template
-- P_STYLE_SHEET_VER    - Version label of template
-- X_SS_BLOB            - Blob containing template
-- X_SS_APPROVED        - Is template approved Y or N
-- X_ERROR_CODE         - Error code if XSLFO cannot be found
-- X_ERROR_MSG          - Error message in case of any errors

PROCEDURE GET_XSLFO_TEMPLATE(p_style_sheet VARCHAR2,
                                   p_style_sheet_ver VARCHAR2,
   								   x_ss_blob out nocopy BLOB,
                                   x_ss_approved out nocopy VARCHAR2,
                                   x_ss_type out nocopy VARCHAR2,
								   x_error_code out nocopy VARCHAR2,
                                   x_error_msg OUT NOCOPY VARCHAR2);

-- EDR_ISIGN_TEMPLATE_PKG.GET_TEMPLATE procedure is called from TemplateManager Class
-- to get the handle of RTF Template Blob. It passes unique p_event_key which is equal to file_id
-- in ISIGN edr_files_b table.
--
-- P_EVENT_KEY          - File Id for the ISIGN EDR_FILES_B Table repository
-- X_TEMPALTE_TYPE      - Return template type as string e.g. RTF, XSL, PDF
-- X_TEMPLATE_BLOB      - Return Template contents in BLOB
-- X_TEMPLATE_FILE_NAME - Return Template File Name as String

PROCEDURE GET_TEMPLATE (p_event_key VARCHAR2,
		  			   	x_template_type out nocopy VARCHAR2,
						x_template_blob out nocopy BLOB,
						x_template_file_name OUT NOCOPY VARCHAR2
						);

END EDR_ISIGN_TEMPLATE_PKG;

 

/
