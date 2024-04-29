--------------------------------------------------------
--  DDL for Package OKC_TERMS_COPY_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_COPY_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGDCPS.pls 120.2.12010000.3 2011/12/09 13:30:20 serukull ship $ */

/*
--To be used when copying/transitioning a document

--p_keep_version should be passed as 'Y' in case of document transition.
--p_keep_version should be passed as 'N' in case of document copy where target
--document is expected to have same version of article as source document .
--p_copy_for_amendment  and p_copy_deliverable should be passed as 'Y' when making amendment in sourcing.All other systems should pass p_copy_for_amendment as 'N'.
--p_copy_deliverable should be passed as 'Y' when deliverable also needs to be
--copied.
 */

Procedure copy_doc     (
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_commit	          IN	Varchar2 default fnd_api.g_false,
                        p_source_doc_type	  IN	Varchar2,
                        p_source_doc_id	          IN	Number,
                        p_target_doc_type	  IN OUT NOCOPY Varchar2,
                        p_target_doc_id	          IN OUT NOCOPY Number,
                        p_keep_version	          IN	Varchar2 default 'N',
                        p_article_effective_date  IN	Date,
                        p_initialize_status_yn	  IN	Varchar2 default 'Y',
                        p_reset_Fixed_Date_yn       IN    Varchar2 default 'Y',
                        p_internal_party_id	  IN	Number default Null,
                        p_internal_contact_id	  IN	Number default Null,
                        p_target_contractual_doctype  IN	Varchar2 default NULL,
                        p_copy_del_attachments_yn      IN   Varchar2 default 'Y',
                        p_external_party_id	  IN	Number default Null,
                        p_external_contact_id	  IN	Number default Null,
                        p_copy_deliverables	  IN	Varchar2 default 'Y',
                        p_document_number	  IN	Varchar2 default  Null,
                        p_copy_for_amendment	  IN	Varchar2 default 'N',
                        p_copy_doc_attachments    IN    Varchar2 default 'N',
                        p_allow_duplicate_terms   IN    Varchar2 default 'N',
                        p_copy_attachments_by_ref IN    Varchar2 default 'N',
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number,
                        p_external_party_site_id	  IN	Number default Null,
                        p_copy_abstract_yn    IN    Varchar2 default 'N',
				    p_contract_admin_id   IN NUMBER := NULL,
				    p_legal_contact_id    IN NUMBER := NULL
             -- Conc Mod Changes Start
            ,p_retain_lock_terms_yn        IN VARCHAR2 := 'N'
            ,p_retain_lock_xprt_yn         IN VARCHAR2 := 'N'
            ,p_add_only_amend_deliverables IN VARCHAR2 := 'N'
            ,p_rebuild_locks  IN VARCHAR2 := 'N'
            -- Conc Mod Changes End
       );

/*
--To be used when copying a terms template to make a new template
*/
Procedure copy_terms_template   (
                        p_api_version       IN       Number,
                        p_init_msg_list     IN       Varchar2 default FND_API.G_FALSE,
                        p_commit            IN       Varchar2 default FND_API.G_FALSE,
                        p_template_id       IN       Number,
                        p_tmpl_name         IN       Varchar2,
                        p_intent            IN       Varchar2,
                        p_start_date        IN       Date     default sysdate,
                        p_end_date          IN       Date     default Null,
                        p_instruction_text  IN       Varchar2 default Null,
                        p_description       IN       Varchar2 default Null,
                        p_print_Template_Id IN       Number   default Null,
                        p_global_flag       IN       Varchar2 default 'N',
                        p_contract_expert_enabled IN Varchar2 default 'N',
				    p_xprt_clause_mandatory_flag IN VARCHAR2 := NULL,
				    p_xprt_scn_code      IN      VARCHAR2 := NULL,
                        p_attribute_category IN      Varchar2 default Null,
                        p_attribute1         IN      Varchar2 default Null,
                        p_attribute2         IN      Varchar2 default Null,
                        p_attribute3         IN      Varchar2 default Null,
                        p_attribute4         IN      Varchar2 default Null,
                        p_attribute5         IN      Varchar2 default Null,
                        p_attribute6         IN      Varchar2 default Null,
                        p_attribute7         IN      Varchar2 default Null,
                        p_attribute8         IN      Varchar2 default Null,
                        p_attribute9         IN      Varchar2 default Null,
                        p_attribute10        IN      Varchar2 default Null,
                        p_attribute11        IN      Varchar2 default Null,
                        p_attribute12        IN      Varchar2 default Null,
                        p_attribute13        IN      Varchar2 default Null,
                        p_attribute14        IN      Varchar2 default Null,
                        p_attribute15        IN      Varchar2 default Null,
                        p_copy_deliverables  IN      Varchar2 default 'Y',
			p_translated_from_tmpl_id IN       Number   default Null,
                        p_language 		  IN       Varchar2 default Null,
			x_template_id        OUT      NOCOPY Number,
                        x_return_status      OUT        NOCOPY Varchar2,
                        x_msg_data           OUT        NOCOPY Varchar2,
                        x_msg_count          OUT        NOCOPY Number);

/*
--To be used when instantiating a term on a document.
*/
Procedure copy_terms   (
                        p_api_version               IN	Number,
                        p_init_msg_list		        IN	Varchar2 default FND_API.G_FALSE,
                        p_commit	                IN	Varchar2 default fnd_api.g_false,
                        p_template_id	            IN	Number,
                        p_target_doc_type	        IN	Varchar2,
                        p_target_doc_id	            IN	Number,
                        p_article_effective_date    IN	Date,
                        p_retain_deliverable	    IN	Varchar2 default 'N',
                        p_target_contractual_doctype  IN Varchar2 default NULL,
                        p_target_response_doctype   IN Varchar2 default NULL,
                        p_internal_party_id	        IN	Number default Null,
                        p_internal_contact_id	    IN	Number default Null,
                        p_external_party_id	        IN	Number default Null,
                        p_external_party_site_id	IN	Number default Null,
                        p_external_contact_id	    IN	Number default Null,

                        p_validate_commit	  IN	Varchar2 default FND_API.G_FALSE,
                        p_validation_string   IN    Varchar2,
                        p_document_number	  IN	Varchar2 default  Null,
                        x_return_status	      OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number,
                        p_retain_clauses	    IN	Varchar2 default 'N',         --kkolukul: Clm Changes
                        p_contract_admin_id   IN NUMBER := NULL,
			p_legal_contact_id    IN NUMBER := NULL
                        );

/* To be used to create Revision of a Template */

Procedure create_template_revision  (
                        p_api_version       IN       Number,
                        p_init_msg_list     IN       Varchar2 default FND_API.G_FALSE,
                        p_commit            IN       Varchar2 default FND_API.G_FALSE,
                        p_template_id       IN       Number,
                        p_copy_deliverables IN       Varchar2 default 'Y',
                        x_template_id       OUT      NOCOPY Number,
                        x_return_status     OUT      NOCOPY Varchar2,
                        x_msg_data          OUT      NOCOPY Varchar2,
                        x_msg_count         OUT      NOCOPY Number);
/*
-- To be used while copying a document from archive to make a new document.
-- This functionality is only supported in OM.
*/

Procedure copy_archived_doc   (
                        p_api_version             IN	Number,
                        p_init_msg_list		  IN	Varchar2 default FND_API.G_FALSE,
                        p_commit	          IN	Varchar2 default fnd_api.g_false,
                        p_source_doc_type	  IN	Varchar2,
                        p_source_doc_id	          IN	Number,
                        p_source_version_number   IN	Number,
                        p_target_doc_type	  IN	Varchar2,
                        p_target_doc_id	          IN	Number,
                        p_document_number	  IN	Varchar2 default  Null,
                        p_allow_duplicate_terms   IN    Varchar2 default 'N',
                        x_return_status	          OUT	NOCOPY Varchar2,
                        x_msg_data	          OUT	NOCOPY Varchar2,
                        x_msg_count	          OUT	NOCOPY Number
                        );


/*************************************************************
07-APR-2004 pnayani: bug#3524864 added copy_response_doc API              |
This API is used for copying terms, deliverables and document attachments from
one response doc to another. Initially coded to support proxy bidding process in sourcing.
p_source_doc_type           - source document type,
p_source_doc_id             - source document id,
p_target_doc_type           - target document type,
p_target_doc_id             - target document id,
p_target_doc_number         - target document number,
p_keep_version              - passed as 'Y' in case of document transition.
                            - passed as 'N' in case of document copy where target
                            - doc is expected to have same version of article as source doc.
p_article_effective_date    - article effective date,
p_copy_doc_attachments      - flag indicates if doc attachments should be copied, valid values Y/N,
p_allow_duplicate_terms     - flag with valid values Y/N,
p_copy_attachments_by_ref   - flag indicates if document attachments should be
                            - physically copied or referenced, valid values Y/N,
*************************************************************/

Procedure copy_response_doc     (
                        p_api_version               IN	Number,
                        p_init_msg_list		        IN	Varchar2 default FND_API.G_FALSE,
                        p_commit	                IN	Varchar2 default fnd_api.g_false,
                        p_source_doc_type	        IN	Varchar2,
                        p_source_doc_id	            IN	Number,
                        p_target_doc_type	        IN OUT NOCOPY Varchar2,
                        p_target_doc_id	            IN OUT NOCOPY Number,
                        p_target_doc_number	        IN	Varchar2 default  Null,
                        p_keep_version	            IN	Varchar2 default 'N',
                        p_article_effective_date    IN	Date,
                        p_copy_doc_attachments      IN    Varchar2 default 'N',
                        p_allow_duplicate_terms     IN    Varchar2 default 'N',
                        p_copy_attachments_by_ref   IN    Varchar2 default 'N',
                        x_return_status	            OUT	NOCOPY Varchar2,
                        x_msg_data	                OUT	NOCOPY Varchar2,
                        x_msg_count	                OUT	NOCOPY Number
                        );



END OKC_TERMS_COPY_GRP;

/
