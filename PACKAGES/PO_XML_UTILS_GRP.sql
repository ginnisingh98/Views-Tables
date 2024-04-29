--------------------------------------------------------
--  DDL for Package PO_XML_UTILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_XML_UTILS_GRP" AUTHID CURRENT_USER AS
/* $Header: POXMLUTS.pls 120.2.12010000.3 2011/08/26 09:44:09 kcthirum ship $ */

-- Start of comments
-- API name	: getAttachment
-- Type		: public
-- Pre-reqs	: none
-- Function	: get text attachment, short text and long text
-- Parameters	:
-- IN		: 	p_media_id	in number	required
--			p_datatype_id	in number	required
-- OUT		:	x_attachment_content	out 	clob
-- Version	: initial version
-- End of comments
procedure getAttachment (p_media_id    in NUMBER,
                         p_datatype_id in NUMBER,
                         x_attachment_content out NOCOPY CLOB);

-- Start of comments
-- API name     : getAttachmentFile
-- Type         : public
-- Pre-reqs     : none
-- Function     : get file attachment
-- Parameters   :
-- IN           :       p_media_id      in  NUMBER    required
-- IN           :       p_pk1_value     in  NUMBER    required
-- IN           :       p_pk2_value     in  NUMBER    required
-- IN           :       p_pk3_value     in  NUMBER    required
-- IN           :       p_pk4_value     in  NUMBER    required
-- IN           :       p_pk5_value     in  NUMBER    required
-- IN           :       p_entity_name   in  VARCHAR2  required
-- OUT          :       x_cid           out VARCHAR2
-- Version      : initial version
-- End of comments
procedure getAttachmentFile (p_media_id    in NUMBER,
                             p_pk1_value   in NUMBER,
                             p_pk2_value   IN NUMBER,
                             p_pk3_value   IN NUMBER,
                             p_pk4_value   IN NUMBER,
                             p_pk5_value   IN NUMBER,
                             p_entity_name IN VARCHAR2,
                             x_cid out NOCOPY VARCHAR2);
-- Start of comments
-- API name     : getAttachmentUrl
-- Type         : public
-- Pre-reqs     : none
-- Function     : get url attached
-- Parameters   :
-- IN           :       p_document_id number required
-- OUT          :       x_attachment_content varchar2
-- Version      : initial version
-- End of comments
PROCEDURE getAttachmentUrl (p_document_id IN NUMBER,
                            x_attachment_content OUT NOCOPY VARCHAR2);

-- Start of comments
-- API name     : splitforids
-- Type         : public
-- Pre-reqs     : none
-- Function     : split ECX_PARAMETER3 to user_id, responsibility_id and application_id
-- Parameters   :
-- IN           : p_ecx_parameter3	ECX_PARAMETER3
-- OUT          : x_user_id		user_id
--              : x_resp_id		responsibility_id
--              : x_appl_id		application_id
-- Version      : initial version
-- End of comments
procedure splitforids (p_ecx_parameter3    in VARCHAR2,
                       x_user_id	out NOCOPY NUMBER,
                       x_resp_id 	out NOCOPY NUMBER,
                       x_appl_id	out NOCOPY NUMBER);

-- Start of comments
-- API name     : getBlanketPONumber
-- Type         : public
-- Pre-reqs     : none
-- Function     : Given a po_release_id returns the segment1 of the blanket; Otherwise null.
-- Parameters   :
-- IN           : p_release_id	        Release Id
--              : p_po_type             PO Type - RELEASE or REGULAR
-- OUT          : p_Blanket_PO_Num	Blanket PO#
-- Version      : initial version
-- End of comments
procedure getBlanketPONumber (p_release_id    in NUMBER,
                              p_po_type       in VARCHAR2,
                              p_Blanket_PO_Num	out NOCOPY VARCHAR2
                             );



-- Start of comments
-- API name     : getTandC
-- Type         : public
-- Pre-reqs     : none
-- Function     : get terms and conditions
-- Parameters   :
-- IN           :       p_user_id	in number       required
--                      p_resp_id   	in number       required
--		:	p_appl_id	in number	required
-- OUT          :       x_TandCcontent	out	clob
-- Version      : initial version
-- End of comments

--Bug 6692126 Changing the in parameters
 	 --  p_document_id in number
 	 -- p_document_type in varchar2

/*procedure getTandC(p_user_id     in NUMBER,
                   p_resp_id     in NUMBER,
                   p_appl_id      in NUMBER,
                   x_TandCcontent  out NOCOPY CLOB); */

procedure  getTandC (p_document_id    in NUMBER,
		     p_document_type  in VARCHAR2,
		     x_TandCcontent   out NOCOPY CLOB);

/*Added for bug#6912518*/
procedure getTandCforXML (p_po_header_id in NUMBER,
			  p_po_release_id in NUMBER,
			  x_TandCcontent out NOCOPY CLOB);

-- Start of comments
-- API name     : regenandsend
-- Type         : Group
-- Pre-reqs     : None
-- Function     : Given a po_header_id and other related information it
--                will generate and send the PROCESS_PO xml document.
-- Parameters   :
-- IN           :  p_po_header_id   po_header_id or po_release_id of the PO
--                 p_po_type        STANDARD or RELEASE depending on the PO type
--                 p_po_revision
--                 p_user_id
--                 p_responsibility_id
--                 p_application_id
--                 p_preparer_user_name
-- OUT          :
-- Version      :
-- End of Comments

procedure regenandsend(p_po_header_id in NUMBER,
                       p_po_type         in VARCHAR2,
                       p_po_revision  in NUMBER,
                       p_user_id in  NUMBER,
                       p_responsibility_id in NUMBER,
                       p_application_id NUMBER,
                       p_preparer_user_name VARCHAR2 default null);

-- Start of comments
-- API Name     :  getGlobalAgreementInfo
-- Type         :  private
-- Pre-Reqs     :  FPI code line
-- Function     :  Given a line_id it will provide the associated Global Contract information.
-- Parameters   :
-- IN           :  p_po_line_id         line_id you are interested
-- OUT          :  x_GLOBALCONTRACT     The Global Contract PO num, if exists.
--              :  x_GLOBALCONTRACTLIN  The line num of the Glbl Cntrct PO
-- Version      :  Initial version for FPI.
-- End Of Comments

procedure getGlobalAgreementInfo (p_po_line_id  in NUMBER,
                                  x_GLOBALCONTRACT OUT NOCOPY VARCHAR2,
                                  x_GLOBALCONTRACTLIN  OUT NOCOPY VARCHAR2);

-- Start of comments
-- API Name      :  getTaxDetails
-- Type          :  group
-- Pre-Reqs     :  FPI code line
-- Function      : Given a line_loc_id it will get the tax details information.
-- Version       : Initial version for FPI.
-- End Of Comments
procedure getTaxDetails (p_po_line_loc_id   IN NUMBER,
                         x_TAX_RATE  OUT NOCOPY varchar2,
                         x_IS_VAT_RECOVERABLE OUT NOCOPY varchar2,
                         x_TAX_TYPE  OUT NOCOPY varchar2,
                         x_TAX_NAME  OUT NOCOPY varchar2,
                         x_ESTIMATED_TAX_AMOUNT OUT NOCOPY number,
                         x_TAX_DESCRIPTION OUT NOCOPY varchar2
                         );

-- Start of Comments
-- In R12, we only need to present the taxable_flag information
-- other tax information are migrated to ebTax.
-- End of Comments
procedure getTaxInfo (p_po_line_loc_id   IN NUMBER,
                      X_TAXABLE OUT NOCOPY varchar2);


-- Start of Comments
-- API Name      :   getUserEnvLang
-- Type          :   group
-- Pre-Reqs      :   FPH codeline
-- Function      :   Gets the session language.
-- Version       :   Initial version of FPH.
-- End of Comments

procedure getUserEnvLang (x_lang  OUT NOCOPY varchar2);

END PO_XML_UTILS_GRP;



/
