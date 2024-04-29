--------------------------------------------------------
--  DDL for Package GMS_AWARDS_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_AWARDS_DIST_PKG" AUTHID CURRENT_USER as
-- $Header: gmsadlss.pls 120.1 2006/07/01 06:59:53 cmishra noship $

	-- -------------------------------------------------------
	-- Declare package variables used in Workflow process
	-- -------------------------------------------------------

   G_doc_type			varchar2(3) ;
   -- ---------------------------------------------------
   -- G_rec_index identifies the document type and
   -- corresponding variables
   -- 1	-	Requisition
   -- 2	-	PO
   -- 3 -	AP Invoice
   -- 4	-	APD distribution Set
   -- 5 -	EXP Expenditure Entry
   -- 6 -	ENC Expenditure Inquiry
   -- ----------------------------------------------------

   -- ---------------------------------------------------
   -- GET_AWARD_SET_ID : get the nextval from the sequence
   -- and returns the award_set_id. This should be called
   -- before create_adls.
   -- ---------------------------------------------------
   FUNCTION get_award_set_id	return NUMBER ;

   -- ----------------------------------------------------------------------------
   -- CREATE_ADLS : Create Adls, Insert a new record into GMS_AWARD_DISTRIBUTIONS
   -- Table.  The input parameter to this is gms_award_distributions%ROWTYPE.
   -- ----------------------------------------------------------------------------
   PROCEDURE create_adls( p_adls_rec	gms_award_distributions%ROWTYPE ) 	;


   -- ----------------------------------------------------------------------------
   -- UPDATE_ADLS : UPDATE_Adls, this is defined to update record into
   -- gms_award_distributions table.
   -- ----------------------------------------------------------------------------
   PROCEDURE update_adls( p_adls_rec	gms_award_distributions%ROWTYPE )  ;


   -- ---------------------------------------------------------------------
   -- API to delete gms_award_distribution record.
   -- ---------------------------------------------------------------------
   PROCEDURE delete_adls( p_distribution_set_id	NUMBER )	;

   -- ---------------------------------------------------------------------
   -- API to delete gms_award_distribution record.
   -- 3733123 - PJ.M:B5: QA:P11:OTH: MANUAL ENC/EXP  FORM CREATING ORPHAN ADLS
   -- ---------------------------------------------------------------------
   PROCEDURE delete_adls( p_doc_header_id       IN NUMBER,
                          p_doc_distribution_id IN NUMBER,
                          p_doc_type            IN VARCHAR2 ) ;

   -- ----------------------------------------------------
   -- When validate award item  always create a new
   -- record into gms_award_distribution table. This may
   -- result into lot of dangling records which are not
   -- connected with anything like EXP, AP, INV, PO and REQ.
   -- ------------------------------------------------------
   PROCEDURE clean_dangling_adls ;


   -- ---------------------------------------------------------------
   -- COPY_ADLS : This is called from funds checker to create adls
   -- for AP reversal prorate credit memo. PO match , Autocreate PO
   -- ---------------------------------------------------------------
   PROCEDURE copy_adls( p_award_set_id      IN  NUMBER ,
                        P_NEW_AWARD_SET_ID  OUT NOCOPY NUMBER,
                        p_doc_type          IN  varchar2,
                        p_dist_id           IN  NUMBER,
                        P_INVOICE_ID        IN  NUMBER DEFAULT NULL,
                        p_dist_line_num     IN  NUMBER DEFAULT NULL,
                        p_raw_cost          IN  NUMBER DEFAULT NULL,
			p_called_from       IN  varchar2 DEFAULT 'NOT_MISC_SYNCH_ADLS') ; -- Bug 5344693 : Added the parameter p_called_from.

   -- --------------------------------------------------------------
   -- InsSi_items - Creates ADLS for the new expenditure items
   --				created for Supplier Invoice Interface from
   --				payables.
   --				This is called from PA_TRX_IMPORT.NEWexpend.
   -- ---------------------------------------------------------------
   /*****************************************************************
   ** This is moved to GMS_PA_API - gmspax1b.pls
   ** ******************************************
   PROCEDURE  InsSI_Items( X_user   IN NUMBER
						, X_login             IN NUMBER
						, X_module            IN VARCHAR2
						, X_calling_process   IN VARCHAR2
						, Rows                IN BINARY_INTEGER
						, X_status            IN OUT NOCOPY NUMBER ) ;
   *****************************************************************/

   -- --------------------------------------------------------------
   --  PROCEDURE update_billable_flag  (p_expenditure_item_id in number)
   --        This procedure will initialize the billable flag
   --        in PA_EXPENDITURE_ITEMS_ALL
   --        Called from trigger GMS_UPDATE_EI_BILLABLE_FLAG
   --        on GMS_AWARD_DISTRIBUTIONS
   --        this Procedure is created as direct update of
   --        other products tables directly from trigger leads to warning in
   --        adpatch
   -- --------------------------------------------------------------
     PROCEDURE update_billable_flag  (p_expenditure_item_id in number);

    -- Start of comments
    -- -----------------
    -- API Name         : verify_create_adl
    -- Type             : public
    -- Pre Reqs         : None
    -- Function         : This is used to create award distribution lines
    --                    using the bulk processing. This provides a
    --                    interface with PO/REQ/REL.
    -- Logic            : Identify the newly created PO/REQ/REL distribution
    --                    lines and create award distribution lines for
    --                    sponsored project.
    -- Parameters       :
    -- IN               : p_header_id    IN     NUMBER
    --                                  The Puchase Order/Requisition id created
    --					and that may have distributions associated with
    --                                  an award.
    --                  : p_doc_type  IN  varchar2
    --                      This will have value as PO/REQ/REL .
    --
    --                  : p_doc_num   IN  varchar2
    --                      This will have  PO/REQ/REL Number.
    -- Calling Place    :  POST-FORMS-COMMIT event in PO/REQ/REL
    --
    -- End of comments
    -- ----------------

    PROCEDURE verify_create_adls( p_header_id  IN NUMBER,
			              p_doc_type   IN VARCHAR2,
	                          p_doc_num    IN VARCHAR2   ) ;

    -- Start of comments
    -- -----------------
    -- API Name         : copy_exp_adls
    -- BUG              : 3684711
    -- Description      : PJ.M:B5:P11:QA:FCE:PAXTREPE: UNABLE TO ENTER A REVERSAL BATCH GMS_AWARD_REQD
    -- Type             : Private
    -- Pre Reqs         : None
    -- Function         : This is used to create award distribution lines for a reversed expenditure item.
    -- Logic            : Copy the award distribution from the original expenditure item.
    -- Parameters       :
    -- IN               : P_exp_item_id    IN     NUMBER
    --                    The original expenditure item.
    --                  : p_backout_item_id  IN  NUMBER
    --                     Reversed expenditure item ID.
    --                    p_adj_activity IN VARCHAR2
    --                      adjustment activity
    --                    P_module, P_user, P_login
    --                     Calling module, user and login details
    --                    X_status out number
    --                     API status
    --                      This will have  PO/REQ/REL Number.
    -- Calling Place    :  PA_ADJUSTMENTS.backout item (PAXTADJB.pls )
    --
    -- End of comments
    -- ----------------

    PROCEDURE  copy_exp_adls( P_exp_item_id         IN NUMBER
			      , p_backout_item_id   IN NUMBER
			      , p_adj_activity      IN VARCHAR2
			      , P_module            IN VARCHAR2
			      , P_user              IN NUMBER
			      , P_login             IN NUMBER
			      , X_status            OUT nocopy NUMBER );

end GMS_AWARDS_DIST_PKG;

 

/
