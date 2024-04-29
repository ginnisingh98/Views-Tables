--------------------------------------------------------
--  DDL for Package GR_REG_PRINT_DOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_REG_PRINT_DOC" AUTHID CURRENT_USER AS
/* $Header: GROMPRTS.pls 120.1 2005/07/05 15:26:53 methomas noship $ */



/*===========================================================================
--  PROCEDURE:
--    print_shipping_doc
--
--  DESCRIPTION:
--  This procedure is used to print the documents attached to an object - Regulatory Item,
--  Linked Inventory Item, Sales Order, etc. It is meant to be called from the
--  Order Management Ship Confirm.
--
--  PARAMETERS:
--    p_delivery_id IN  NUMBER       - Delivery ID key to the workflow record
--
--  RETURNS:
--    errbuf        OUT VARCHAR2     - Returns error message only when this procedure is submitted from a concurrent program.
--    retcode       OUT VARCHAR2     - Returns error code only when this procedure is submitted from a concurrent program.
--
--  SYNOPSIS:
--    GR_REG_DOC_PRINT.printing_shipping_doc(p_delivery_id);
--
--  HISTORY
--=========================================================================== */


  PROCEDURE print_shipping_doc  (errbuf          OUT NOCOPY VARCHAR2,
                                  retcode         OUT NOCOPY VARCHAR2,
                                  p_delivery_id    IN NUMBER);


/*===========================================================================
--  PROCEDURE:
--    attach_shipping_document
--
--  DESCRIPTION:
--    This procedure is used to attach a Regulatory document to a Shipment line if the
--    item on the line is a Regulatory item and no other Regulatory documents have been
--    attached to that line.
--
--  PARAMETERS:
--    p_delivery_id          IN         NUMBER       - Delivery ID key of Shipment
--    x_return_status        OUT NOCOPY VARCHAR2     - Status of procedure execution
--    x_msg_data             OUT NOCOPY VARCHAR2     - Error message, if error has occurred
--
--  SYNOPSIS:
--    GR_REG_DOC_PRINT.attach_shipping_document(p_delivery_id, l_return_status, l_msg_data);
--
--  HISTORY
--=========================================================================== */
  PROCEDURE ATTACH_SHIPPING_DOCUMENT(
	  p_delivery_id             IN         NUMBER,
	  x_return_status           OUT NOCOPY VARCHAR2,
	  x_msg_data                OUT NOCOPY VARCHAR2);



/*===========================================================================
--  PROCEDURE:
--    print_reg_docs
--
--  DESCRIPTION:
--    This procedure is used to print the current version of approved documents
--    that fall within the specified ranges.
--
--  PARAMETERS:
--    errbuf                    OUT NOCOPY VARCHAR2     - Error message, when submitted from concurrent program
--    retcode                   OUT NOCOPY VARCHAR2     - Error code, when submitted from concurrent program
--    p_orgn_id                 IN           NUMBER     - Organization_id to search items in
--    p_from_item               IN         VARCHAR2     - First item in range
--    p_to_item                 IN         VARCHAR2     - Last item in range
-     p_from_language           IN         VARCHAR2     - First language in range
--    p_to_language             IN         VARCHAR2     - Last language in range
--    p_document_category       IN         VARCHAR2     - Document category to retrict documents to
--    p_update_dispatch_history IN         VARCHAR2     - Update Dispatch History - 'Y'es or 'N'o
--    p_recipent_site           IN         NUMBER       - ID of site receiving the dispatch
--
--  SYNOPSIS:
--    GR_REG_DOC_PRINT.print_reg_item_docs(errbuf,retcode,p_from_item,p_to_item,p_from_lang,
--                     p_to_lang,p_doc_category,p_upd_disp_hist,p_recipient_site);
--
--  HISTORY
--=========================================================================== */
  PROCEDURE PRINT_REG_DOCS(
         errbuf                    OUT NOCOPY VARCHAR2
	 ,retcode                   OUT NOCOPY VARCHAR2
	 ,p_orgn_id                 IN           NUMBER
	 ,p_from_item               IN         VARCHAR2
	 ,p_to_item                 IN         VARCHAR2
	 ,p_from_language           IN	 VARCHAR2
	 ,p_to_language             IN	 VARCHAR2
	 ,p_document_category       IN         VARCHAR2
	 ,p_update_dispatch_history IN         VARCHAR2
	 ,p_recipient_site          IN         VARCHAR2
	);

END GR_REG_PRINT_DOC;


 

/
