--------------------------------------------------------
--  DDL for Package PO_INTERFACE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTERFACE_S" AUTHID CURRENT_USER AS
/* $Header: POXBWP1S.pls 120.0.12010000.5 2013/10/03 08:50:40 inagdeo ship $*/


--Public Variables
--Used by create_documents procedure to set the return status
--when duplicate document number error is returned
G_RET_STS_DUP_DOC_NUM CONSTANT VARCHAR2(1) := 'D'; --<Shared Proc FPJ>

/****************************************************************************
  --<SOURCING TO PO FPH>
  Name: CREATE_DOCUMENTS_WRAPPER
  DESC: This procedure is modified to add two new parameters.
  ARGS: x_document_number  OUT    varchar2 returns the PO/Blanket number
					   when for sourcing, null for
					   existing autocreate.
        x_errorcode	   OUT    number   1 success
					   2 manual document number notunique
					   3 any other error.
   --<CONTERMS FPJ START>
        p_sourcing_k_doc_type   IN   VARCHAR2 - The document type that Sourcing
                             has seeded in Contracts.
                             Deafault null
        p_conterms_exist_flag   IN    VARCHAR2 - Whether the sourcing document
                              has contract template attached.
                              Deafult - N
   --<CONTERMS FPJ END>
   --<DBI FPJ>
	p_document_creation_method  IN  VARCHAR2 - Stores the method by which
				    the document has been created.
 *****************************************************************************/
 procedure create_documents(x_batch_id 		IN     number,
			    x_document_id 	IN OUT NOCOPY number,
			    x_number_lines 	IN OUT NOCOPY number,
			    x_document_number 	IN OUT NOCOPY varchar2,
			    x_errorcode		OUT NOCOPY    number
               ,p_sourcing_k_doc_type  IN VARCHAR2 DEFAULT NULL--<CONTERMS FPJ>
               ,p_conterms_exist_flag  IN VARCHAR2 DEFAULT 'N' --<CONTERMS FPJ>
	       ,p_document_creation_method IN VARCHAR2 DEFAULT NULL --<DBI FPJ>
                  ,p_orig_org_id         IN   NUMBER DEFAULT NULL    -- <R12 MOAC>
                  ,p_group_shipments     IN   VARCHAR2  DEFAULT NULL --<Bug 14608120, Autocreate GE ER>
               );
 /****************************************************************************/

/****************************************************************************
  --<SOURCING TO PO FPH>
  Name: CREATE_DOCUMENTS
  DESC: This procedure is a wrapper with the original signature.
  ARGS: x_batch_id 	   IN     number   unique identifier for the all
					   the documents to be created.
					   It will be the same as
					   interface_header_id as we always
					   create 1 doc at a time.
        x_document_id 	   IN OUT number   IN  document id to ADD to N/A for
					       sourcing.
					   OUT returns the id of the document
					       created.
        x_number_lines 	   IN OUT number   IN  N/A
					   OUT returns the number of interface
					       records processed.
   --<DBI FPJ>
        p_document_creation_method  IN  VARCHAR2 - Stores the method by which
                                    the document has been created.
 *****************************************************************************/
 procedure create_documents(x_batch_id 		IN     number,
			    x_document_id 	IN OUT NOCOPY number,
			    x_number_lines 	IN OUT NOCOPY number,
	                    p_document_creation_method IN VARCHAR2 DEFAULT NULL   --<DBI FPJ>
                           ,p_orig_org_id         IN   NUMBER DEFAULT NULL    -- <R12 MOAC>
	                   ,p_group_shipments     IN   VARCHAR2  DEFAULT NULL --<Bug 14608120, Autocreate GE ER>
			    );
 /****************************************************************************/



-- Bug 2082757 :
FUNCTION source_blanket_line(x_po_header_id IN NUMBER,
                             x_requisition_line_id IN NUMBER,
                             x_interface_line_num IN NUMBER,
                             -- Bug 2707576 whether to allow the BPA to have
                             -- a different UOM from the requisition
                             x_allow_different_uoms IN VARCHAR2 DEFAULT 'Y',
                             p_purchasing_ou_id IN NUMBER --<Shared Proc FPJ>
                            ) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES (source_blanket_line, WNDS, RNPS);

--<Shared Proc FPJ Start>
PROCEDURE create_documents (
    p_api_version                IN               NUMBER,
    x_return_status              OUT    NOCOPY    VARCHAR2,
    x_msg_count                  OUT    NOCOPY    NUMBER,
    x_msg_data                   OUT    NOCOPY    VARCHAR2,
    p_batch_id                   IN               NUMBER,
    p_req_operating_unit_id      IN               NUMBER,
    p_purch_operating_unit_id    IN               NUMBER,
    x_document_id                IN OUT NOCOPY    NUMBER,
    x_number_lines               OUT    NOCOPY    NUMBER,
    x_document_number            OUT    NOCOPY    VARCHAR2
   ,p_sourcing_k_doc_type        IN               VARCHAR2 DEFAULT NULL--<CONTERMS FPJ>
   ,p_conterms_exist_flag        IN               VARCHAR2 DEFAULT 'N' --<CONTERMS FPJ>
   ,p_document_creation_method   IN		  VARCHAR2 DEFAULT NULL --<DBI FPJ>
   ,p_orig_org_id                IN               NUMBER DEFAULT NULL    -- <R12 MOAC>
   ,p_group_shipments            IN               VARCHAR2  DEFAULT NULL --<Bug 14608120 Autocreate GE ER>
);
--<Shared Proc FPJ End>

--<PDOI Enhancement Bug#17063664>
-- Creating overloaded procedure as extra parmeter x_online_report_id is required
-- for displying error messages in Autocreate.
PROCEDURE create_documents (
      p_api_version                IN               NUMBER
    , x_return_status              OUT    NOCOPY    VARCHAR2
    , x_msg_count                  OUT    NOCOPY    NUMBER
    , x_msg_data                   OUT    NOCOPY    VARCHAR2
    , p_batch_id                   IN               NUMBER
    , p_req_operating_unit_id      IN               NUMBER
    , p_purch_operating_unit_id    IN               NUMBER
    , x_document_id                IN OUT NOCOPY    NUMBER
    , x_number_lines               OUT    NOCOPY    NUMBER
    , x_document_number            OUT    NOCOPY    VARCHAR2
    , p_sourcing_k_doc_type        IN               VARCHAR2 DEFAULT NULL--<CONTERMS FPJ>
    , p_conterms_exist_flag        IN               VARCHAR2 DEFAULT 'N' --<CONTERMS FPJ>
    , p_document_creation_method   IN		  VARCHAR2 DEFAULT NULL --<DBI FPJ>
    , p_orig_org_id                IN               NUMBER DEFAULT NULL    -- <R12 MOAC>
    , p_group_shipments            IN               VARCHAR2  DEFAULT NULL --<Bug 14608120 Autocreate GE ER>
    , x_online_report_id           OUT    NOCOPY    NUMBER
);


END po_interface_s;

/
