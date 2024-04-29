--------------------------------------------------------
--  DDL for Package GMS_AP_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AP_API2" AUTHID CURRENT_USER AS
/* $Header: gmsapx2s.pls 120.0 2005/05/29 11:32:23 appldev noship $ */

    -- Start of comments
    -- -----------------
    -- API Name         : verify_create_adl
    -- Type             : public
    -- Pre Reqs         : None
    -- Function         : This is used to create award distribution lines
    --                    using the bulk processing. This provides a
    --                    interface with ap recurring invoice feature.
    -- Logic            : Identify the newly created invoice distribution
    --                    lines and create award distribution lines for
    --                    sponsored project.
    -- Parameters       :
    -- IN               : p_invoice_id   IN     NUMBER
    --                                  The invoice id created and that may
    --                                  have distributions associated with
    --                                  an award.
    --                  : p_calling_sequence IN  varchar2
    --                      calling sequence of the API for the debugging purpose.
    -- Calling API      : AP_RECURRING_INVOICES_PKG.ap_create_recurring_invoices
    --                    ap_approval_pkg
    -- End of comments
    -- ----------------

PROCEDURE verify_create_adls( p_invoice_id  IN NUMBER,
                              p_calling_sequence IN VARCHAR2 ) ;

    -- Start of comments
    -- -----------------
    -- API Name         : validate_transaction
    -- Type             : public
    -- Pre Reqs         : None
    -- BUG              : 2755183
    -- Description      : INVOICE ENTRY DOES NOT VALIDATE EXP ITEM DATE W/ AWARD COPIED FROM DIST SET.
    --
    -- Function         : This function is called from AP_INVOICE_DISTRIBUTIONS_PKG.
    --			  insert_from_dist_set to validate the award related
    --			  information.
    -- Logic            : Determine the award and call gms standard
    --			  validation routine.
    -- Parameters       :
    -- IN               : x_project_id	IN Number
    --					   Project ID value.
    --                    x_task_id     IN Number
    --					   Task Identifier.
    --			  x_award_id	IN number
    --					   ADL identifier, AWARD_SET_ID reference value.
    --			  x_expenditure_type IN varchar2
    --					   Expenditure type
    --			  x_expenditure_item_date in date
    --			                   Expenditure item date.
    --                    x_calling_sequence      in varchar2
    --				           calling api identifier.
    --			  x_msg_application       in varchar2
    --                                     application identifier = 'GMS'
    --                    x_msg_type              out varchar2,
    --                                     identify the message type.
    --                    X_msg_count             out number
    --                                     count of message
    --                    X_msg_data              out varchar2
    --                                     message label
    -- Calling API      : AP_INVOICE_DISTRIBUTIONS_PKG.insert_from_dist_set
    --
    -- End of comments
    -- ----------------

PROCEDURE validate_transaction( x_project_id	        IN            NUMBER,
				x_task_id               IN            NUMBER,
				x_award_id              IN            NUMBER,
				x_expenditure_type      IN            varchar2,
				x_expenditure_item_date IN            DATE,
				x_calling_sequence      in            VARCHAR2,
				x_msg_application       in out nocopy VARCHAR2,
				x_msg_type              out nocopy    VARCHAR2,
				X_msg_count             OUT nocopy    NUMBER,
				X_msg_data              OUT nocopy    VARCHAR2 ) ;

END GMS_AP_API2;

 

/
