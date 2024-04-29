--------------------------------------------------------
--  DDL for Package Body GMS_AP_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AP_API2" AS
/* $Header: gmsapx2b.pls 120.1 2006/01/25 14:01:32 aaggarwa noship $ */

    -- Start of comments
    -- -----------------
    -- API Name         : check_award_funding
    -- Type             : private
    -- Pre Reqs         : None
    -- BUG              : 3077074
    -- Description      : EXECEPTION HANDLING TO GMS_AP_API TO SUPPORT CODE HOOK IN AP APPROVAL.
    --
    -- Function         : check award funding identifies the award funding the project.
    -- Calling API      : verify_create_adl
    -- End of comments
    -- ----------------

PROCEDURE check_award_funding ( p_project_id IN NUMBER,
				p_award_id   IN OUT NOCOPY NUMBER,
			        p_status out NOCOPY NUMBER ) is

    l_award_id  NUMBER ;
    l_status    NUMBER ;

    -- =====================================================
    -- Cursor : c_validate_award
    -- Cursor verifies that award is funded by the
    -- project.
    -- =====================================================
    cursor c_validate_award is
           select ins.award_id
             from gms_installments ins,
                  gms_summary_project_fundings pf
            where ins.installment_id = pf.installment_id
	      and pf.project_id      = p_project_id
	      and ins.award_id       = p_award_id ;

    -- =====================================================
    -- Cursor : c_get_award
    -- Cursor finds out if there is a award funding the
    -- project charged to a transaction.
    -- =====================================================
    cursor c_get_award is
           select ins.award_id
             from gms_installments ins,
                  gms_summary_project_fundings pf
            where ins.installment_id = pf.installment_id
	      and pf.project_id      = p_project_id
	      and NOT EXISTS ( select 1 from gms_installments ins2,
					     gms_summary_project_fundings pf2
				       where ins2.installment_id = pf2.installment_id
					 and pf2.project_id      = pf.project_id
					 and ins2.award_id      <> ins.award_id ) ;
BEGIN
    l_award_id := p_award_id ;
    l_status   := 0 ;

    -- =================================
    -- Validate award.
    -- =================================
    IF p_award_id is not NULL THEN
       open c_validate_award ;
       fetch c_validate_award into l_award_id ;
       close c_validate_award ;
    END IF ;

    -- There is no valid award yet.
    -- checking to see if there

    IF l_award_id is NULL THEN
       open c_get_award ;
       fetch c_get_award into l_award_id ;
       close c_get_award ;
    END IF ;

    IF l_award_id is NULL THEN
       l_status:= -1 ;
    ELSE
       p_award_id := l_award_id ;
    END IF ;

    p_status := l_status ;

END check_award_funding ;
-- End of check_award_funding
-- ----------------------------

    -- Start of comments
    -- -----------------
    -- API Name         : verify_create_adl
    -- Type             : public
    -- Pre Reqs         : None
    -- BUG              : 2789359, 3046767
    -- Description      : RECURRING INVOICES USING AP DISTRIBUTION SETS FAILING
    --                    GL FUNDSCHECK F00
    --                    GMS: ENHANCE GMS LOGIC FOR AWARD DISTRIBUTION LINE VALIDATIONS.
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
    --                    AP_APPROVAL_PKG.APPROVE
    -- End of comments
    -- ----------------

PROCEDURE VERIFY_CREATE_ADLS( p_invoice_id IN NUMBER ,
                              p_calling_sequence IN VARCHAR2 ) is

type gms_ap_type_number is table of number index by binary_integer;
type gms_ap_type_date   is table of date   index by binary_integer;

l_invoice_id                    gms_ap_type_number;
l_distribution_line_number	gms_ap_type_number;
l_invoice_distribution_id	gms_ap_type_number;
l_project_id                    gms_ap_type_number;
l_task_id                       gms_ap_type_number;
l_award_id                      gms_ap_type_number;
l_new_award_set_id              gms_ap_type_number;
l_last_update_date              gms_ap_type_date;
l_creation_date                 gms_ap_type_date;
l_last_updated_by               gms_ap_type_number;
l_created_by                    gms_ap_type_number;
l_last_update_login             gms_ap_type_number;
l_dummy_tab                     gms_ap_type_number;

l_award_set_id                  gms_ap_type_number ;
l_award_set_idX                 NUMBER ;
l_count                         NUMBER ;
l_project_idX                   NUMBER ;
l_award_idX                     NUMBER ;
l_status                        NUMBER ;
AWARD_NOT_FOUND                 EXCEPTION ;

l_invoice_num                   ap_invoices_all.invoice_num%TYPE ;

cursor c_ap is
	  SELECT A.invoice_id 			    INVOICE_ID,
		 A.distribution_line_number	    distribution_line_number,
		 A.invoice_distribution_id	    invoice_distribution_id,
		 A.project_id			    PROJECT_ID,
		 A.task_id			    TASK_ID,
                 A.award_id                         award_set_id,
		 A.last_update_date		    LAST_UPDATE_DATE,
		 A.creation_date		    CREATION_DATE,
		 A.last_updated_by		    LAST_UPDATED_BY,
		 A.created_by			    CREATED_BY,
		 NVL(A.last_update_login,0)	    LAST_UPDATE_LOGIN,
                 inv.invoice_num                    invoice_num
	    from ap_invoice_distributions_all  	A,
                 pa_projects_all                p,
                 gms_project_types          gpt,
                 ap_invoices_all                inv
	   where a.invoice_id          = p_invoice_id
             and a.project_id          = p.project_id
	     and p.project_type       = gpt.project_type
             and inv.invoice_id       = a.invoice_id
	     and gpt.sponsored_flag    = 'Y'  ;

cursor c_adl is
       select * from gms_award_distributions where award_set_id = l_award_set_idX
                                               and adl_line_num = 1 ;
l_adl_rec c_adl%ROWTYPE ;

cursor c2 is
	  SELECT 1
	    from ap_invoice_distributions_all  	A,
                 pa_projects_all                p,
                 gms_project_types          gpt
	   where a.invoice_id          = p_invoice_id
             and a.project_id          = p.project_id
	     and p.project_type       = gpt.project_type
	     and gpt.sponsored_flag    = 'Y'
	     and not exists ( select 1 from gms_award_distributions adl
				where adl.invoice_id = p_invoice_id
				  and adl.distribution_line_number = A.distribution_line_number
				  and adl.document_type            = 'AP'
				  and adl.award_set_id             = NVL(a.award_id,0)
				  and adl.adl_line_num             = 1
				  and adl.adl_status               = 'A' ) ;



BEGIN

 -- Start of comment
 -- Verify that grants is enabled.
 -- End of comments.
 --
 IF NOT gms_install.enabled THEN
    return ;
 END IF ;

 -- Load the collection with the AP inv dist data first.
 -- The AP inv dist should have the invoice_id in parameters
 -- value.
 -- The AP inv dist should have award_id column populated.

IF NVL(SUBSTR(p_calling_sequence, 1,15),'X') <> 'AP_APPROVAL_PKG' THEN

	  SELECT A.invoice_id 			INVOICE_ID,
		 A.distribution_line_number	distribution_line_number,
		 A.invoice_distribution_id	invoice_distribution_id,
		 A.project_id			PROJECT_ID,
		 A.task_id			TASK_ID,
         	 ADL.award_id         		AWARD_ID,
		 A.award_id                     award_set_id,
		 A.last_update_date		LAST_UPDATE_DATE,
		 A.creation_date		CREATION_DATE,
		 A.last_updated_by		LAST_UPDATED_BY,
		 A.created_by			CREATED_BY,
		 NVL(A.last_update_login,0)	LAST_UPDATE_LOGIN,
                 gms_awards_dist_pkg.get_award_set_id NEW_AWARD_SET_ID
            BULK COLLECT INTO l_invoice_id,
                              l_distribution_line_number,
                              l_invoice_distribution_id,
                              l_project_id ,
                              l_task_id ,
                              l_award_id,
			      l_award_set_id,
                              l_last_update_date ,
                              l_creation_date ,
                              l_last_updated_by ,
                              l_created_by ,
                              l_last_update_login  ,
			      l_new_award_set_id
	    from ap_invoice_distributions_all  	A,
                 gms_award_distributions       adl
	   where a.invoice_id          = p_invoice_id
             and adl.award_set_id      = a.award_id
             and adl.adl_line_num      = 1
             and a.award_id IS NOT NULL;
END IF ;

-- 3046767 GMS: ENHANCE GMS LOGIC FOR AWARD DISTRIBUTION LINE VALIDATIONS. STARTS
IF NVL(SUBSTR(p_calling_sequence, 1,15),'X') = 'AP_APPROVAL_PKG' THEN
    l_count := 0 ;

    -- 2308005 ( CLEARING INVOICE DIST. LINE AFTER CHANGING AWARD MAKES ADL STATUS 'I' )

     -- ==============================================================================================
     -- BUG	       : 4953772
     -- Description    : R12.PJ:XB2:DEV:GMS: APPSPERF:  PACKAGE:GMSAPX2B.PLS
     -- Resolution     : Sql statement to update award id NULL on ap distribution was changed to bulk
     --                 Processing. This has resolved the Share Memory Size 1,282,674
     --                  SQL ID : 14724997 	Share Memory Size 1,282,722
     --                  SQL ID : 14724976     Share Memory Size 452,386
     --                  SQL ID : 14724956     Share Memory Size 444,106
     -- ==============================================================================================

    l_dummy_tab.delete ;

    select adl2.award_set_id
     bulk collect into l_dummy_tab
     from gms_award_distributions      adl2,
          ap_invoice_distributions_all apd
    where apd.invoice_id         = p_invoice_id
      and apd.award_id 		is not null
      and adl2.award_set_id     = apd.award_id
      and adl2.invoice_id       = apd.invoice_id
      and adl2.document_type	= 'AP'
      and adl2.distribution_line_number	= apd.distribution_line_number
      and adl2.invoice_distribution_id  = apd.invoice_distribution_id
      and adl2.adl_status	= 'I'  ;

    IF l_dummy_tab.count > 0 THEN

      FORALL i in l_dummy_tab.FIRST..l_dummy_tab.LAST
       UPDATE gms_award_distributions
          SET adl_status = 'A'
        where  award_set_id = l_dummy_tab(i) ;

    END IF ;

    l_dummy_tab.delete ;

    -- Inactivate ADLS that belongs to the AP distribution line but
    -- not tied up with award_id in ap_distribution line.
    -- Inactivate dangling active adls.
    -- ----

     -- ==============================================================================================
     -- BUG	       : 4953772
     -- Description    : R12.PJ:XB2:DEV:GMS: APPSPERF:  PACKAGE:GMSAPX2B.PLS
     -- Resolution     : Sql statement to update award id NULL on ap distribution was changed to bulk
     --                 Processing. This has resolved the Share Memory Size 1,282,674
     --                  SQL ID : 14724997 	Share Memory Size 1,282,722
     --                  SQL ID : 14724976     Share Memory Size 452,386
     --                  SQL ID : 14724956     Share Memory Size 444,106
     -- ==============================================================================================
    select adl2.award_set_id
     bulk collect into l_dummy_tab
     from gms_award_distributions      adl2,
          ap_invoice_distributions_all apd
    where apd.invoice_id        = p_invoice_id
      and apd.award_id 		is not null
      and adl2.award_set_id     <> apd.award_id
      and adl2.invoice_id	= apd.invoice_id
      and adl2.document_type    = 'AP'
      and adl2.distribution_line_number = apd.distribution_line_number
      and adl2.invoice_distribution_id  = apd.invoice_distribution_id
      and adl2.adl_status	= 'A'   ;


    IF l_dummy_tab.count > 0 THEN

      FORALL i in l_dummy_tab.FIRST..l_dummy_tab.LAST
       UPDATE gms_award_distributions
          SET adl_status = 'I'
        where  award_set_id = l_dummy_tab(i) ;

    END IF ;

    l_dummy_tab.delete ;

     -- ==================================================
     -- Update award_id to NULL for non sponsored
     -- projects.
     -- =================================================
     -- Bug : 4953772
     -- R12.PJ:XB2:DEV:GMS: APPSPERF:  PACKAGE:GMSAPX2B.PLS
     --
     -- ==============================================================================================
     -- BUG	       : 4953772
     -- Description    : R12.PJ:XB2:DEV:GMS: APPSPERF:  PACKAGE:GMSAPX2B.PLS
     -- Resolution     : Sql statement to update award id NULL on ap distribution was changed to bulk
     --                 Processing. This has resolved the Share Memory Size 1,282,674
     --                  SQL ID : 14724997 	Share Memory Size 1,282,722
     --                  SQL ID : 14724976     Share Memory Size 452,386
     --                  SQL ID : 14724956     Share Memory Size 444,106
     -- ==============================================================================================
    /* 25-jan-2006
    ** Update statement was changed to bulk statement to resolve the share memory performance issue.
    */
    select a.invoice_distribution_id
     bulk collect into l_dummy_tab
     from ap_invoice_distributions_all  	A,
          pa_projects_all                p,
          gms_project_types          gpt
    where a.invoice_id          = p_invoice_id
      and a.project_id          = p.project_id
      and a.award_id            is not NULL
      and p.project_type        = gpt.project_type
      and gpt.sponsored_flag    = 'N'  ;

    IF l_dummy_tab.count > 0 THEN

      FORALL i in l_dummy_tab.FIRST..l_dummy_tab.LAST
       UPDATE ap_invoice_distributions_all apd
          SET award_id = NULL
        where apd.invoice_id = p_invoice_id
	  and apd.invoice_distribution_id = l_dummy_tab(i) ;

    END IF ;

    l_dummy_tab.delete ;

    FOR ap_rec in c_ap LOOP

	l_award_set_idX := NVL(ap_rec.award_set_id,0) ;
        l_invoice_num   := ap_rec.invoice_num ;

	l_adl_rec := NULL ;

	open c_adl ;
	fetch c_adl into l_adl_rec ;
	close c_adl ;

	IF NOT (( NVL(l_adl_rec.adl_status,'I')  = 'A' ) and
               ( NVL(l_adl_rec.document_type,'X') = 'AP' ) and
               ( NVL(l_adl_rec.invoice_id,0)   = NVL( ap_rec.invoice_id,0) ) AND
               ( NVL(l_adl_rec.distribution_line_number,0) = NVL(ap_rec.distribution_line_number,0) ) AND
               ( NVL(l_adl_rec.invoice_distribution_id,0)  = NVL( ap_rec.invoice_distribution_id,0) )) THEN

                l_count := l_count + 1 ;
                l_invoice_id(l_count)               := ap_rec.invoice_id ;
                l_distribution_line_number(l_count) := ap_rec.distribution_line_number;
                l_invoice_distribution_id(l_count)  := ap_rec.invoice_distribution_id;
                l_project_id(l_count)               := ap_rec.project_id;
                l_task_id(l_count)                  := ap_rec.task_id;
		l_project_idX                       := ap_rec.project_id;
		l_award_idX                         := l_adl_rec.award_id ;

		check_award_funding( l_project_idX, l_award_idX, l_status ) ;

		IF l_status = -1 THEN
		   raise AWARD_NOT_FOUND ;
                ELSE
		   l_award_id(l_count) := l_award_idX ;
		END IF ;

                l_last_update_date(l_count)         := ap_rec.last_update_date;
                l_creation_date(l_count)            := ap_rec.creation_date;
                l_last_updated_by(l_count)          := ap_rec.last_updated_by;
                l_created_by(l_count)               := NVL(ap_rec.created_by,0);
                l_last_update_login(l_count)        := ap_rec.last_update_login;
		l_new_award_set_id(l_count)         := gms_awards_dist_pkg.get_award_set_id ;

	END IF ;

    END LOOP ;

END IF ;
-- 3046767 GMS: ENHANCE GMS LOGIC FOR AWARD DISTRIBUTION LINE VALIDATIONS. END

     -- Start of comments
     -- Check if need to proceed.
     -- End of comment.

     IF l_invoice_id.count = 0 then
        -- bug 3772472 PJ.M:B5: QA:P11:OTH: DELETION OF ADLS  WHEN REQ,PO OR AP LINES
        -- ARE DELETED.
        -- delete orphan adls for a given invoice id.
        -- scenarions : POETA ap distribution line was changed to gl related.
        --              Distribution line is deleted but all other distributions
        --              has correct adls.
        --              ADLS are in sych so we can delete orphan adls now.
        delete from gms_award_distributions
         where invoice_id = p_invoice_id
           and document_type = 'AP'
           and award_set_id not in ( select award_id from ap_invoice_distributions_all
                                      where invoice_id = p_invoice_id
                                        and award_id is not NULL ) ;

        return ;
     end if ;

     -- Start of comment.
     -- Loop through all the collection and insert into the ADL table.
     -- Update the ap inv dist record with the newly created ADLs award set id.
     -- End of comment


      FORALL i in l_invoice_distribution_id.FIRST..l_invoice_distribution_id.LAST
      INSERT into gms_award_distributions ( award_set_id ,
                                            adl_line_num,
                                            document_type,
                                            distribution_value,
                                            project_id                 ,
                                            task_id                    ,
                                            award_id                   ,
                                            request_id                 ,
                                            adl_status                 ,
                                            fc_status                  ,
                                            line_type                  ,
                                            capitalized_flag           ,
                                            capitalizable_flag         ,
                                            revenue_distributed_flag   ,
                                            billed_flag                ,
                                            bill_hold_flag             ,
                                            invoice_distribution_id    ,
                                            invoice_id                 ,
                                            distribution_line_number   ,
                                            burdenable_raw_cost        ,
                                            cost_distributed_flag      ,
                                            last_update_date           ,
                                            last_updated_by            ,
                                            created_by                 ,
                                            creation_date              ,
                                            last_update_login          ,
                    			    billable_flag              )
                                    VALUES ( l_new_award_set_id(i)  ,
                                              1, --adl_line_num,
                                            'AP' , --document_type,
                                            100,
                                            l_project_id(i)      ,
                                            l_task_id(i)                    ,
                                            l_award_id(i)                   ,
                                            l_distribution_line_number(i)                 ,
                                            'A', --adl_status                 ,
                                            'N', --fc_status                  ,
                                            'R', --line_type                  ,
                                            'N'           ,
                                            'N'         ,
                                            'N'   ,
                                            'N'                ,
                                            'N'             ,
                                            l_invoice_distribution_id(i), --invoice_distribution_id    ,
                                            l_invoice_id(i), --invoice_id                 ,
                                            l_distribution_line_number(i), --distribution_line_number   ,
                                            NULL, --burdenable_raw_cost        ,
                                            'N'      ,
                                            l_last_update_date(i)           ,
                                            l_last_updated_by(i)             ,
                                            l_created_by(i)                 ,
                                            l_creation_date(i)              ,
                                            l_last_update_login(i)          ,
			         	    'N') ;

      -- Start of comment.
      -- Update AP distribution with the award set id.
      -- End of comment.

      FORALL k in  l_invoice_distribution_id.FIRST..l_invoice_distribution_id.LAST
       	    update ap_invoice_distributions_all
               set award_id = l_new_award_set_id(k)
             where invoice_id 	= l_invoice_id(k)
               and distribution_line_number 	=   l_distribution_line_number(k)
               and invoice_distribution_id      = l_invoice_distribution_id(k)  ;

      -- bug 3772472 PJ.M:B5: QA:P11:OTH: DELETION OF ADLS  WHEN AP LINES
      -- ARE DELETED.
      -- delete orphan adls for a given invoice id.
      -- ADLS are in sych so we can delete orphan adls now.
      --
      delete from gms_award_distributions
       where invoice_id = p_invoice_id
         and document_type = 'AP'
         and award_set_id not in ( select award_id from ap_invoice_distributions_all
                                    where invoice_id = p_invoice_id
                                      and award_id is not NULL ) ;

-- Bug 3077074
--     EXECEPTION HANDLING TO GMS_AP_API TO SUPPORT CODE HOOK IN AP APPROVAL.
--     Added exception handling routine.
EXCEPTION
    WHEN AWARD_NOT_FOUND THEN
       fnd_message.set_name('GMS','GMS_INVALID_AWARD_FOUND');
       --
       -- Message : Incorrect award is associated with the invoice id : ??? and
       --	    distribution line number : ??????. Please change award information
       --	    on the distribution line.

       fnd_message.set_token('INVNUM',l_invoice_num);
       fnd_message.set_token('DISTLNO', l_distribution_line_number(l_count));
       app_exception.raise_exception;

    WHEN OTHERS THEN
       fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
       fnd_message.set_token('PROGRAM_NAME',NVL(p_calling_sequence,' ')||'->gms_ap_api.verify_create_adls');
       fnd_message.set_token('OERRNO',to_char(sqlcode));
       fnd_message.set_token('OERRM',sqlerrm);
       app_exception.raise_exception;

       -- EXECEPTION HANDLING TO GMS_AP_API TO SUPPORT CODE HOOK IN AP APPROVAL.
       -- Bug 3077074 End here

 END VERIFY_CREATE_ADLS ;


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
				X_msg_data              OUT nocopy    VARCHAR2 ) is
   cursor c1 is
          select award_id
            from gms_award_distributions
           where award_set_id = x_award_id
             and adl_line_num = 1 ;

   l_award_id  number ;
   l_outcome  varchar2(2000) ;

begin
	open c1 ;
        fetch c1 into l_award_id ;
        IF c1%notfound then
           raise no_data_found ;
        end if ;
        close c1 ;


	-- ===========================================================================
	-- inavlida parameter was passed to p_award_id argument. The correct value
	-- should have l_award_id. The previously x_award_id which holds award_set_id
	-- was passed.
	-- ===========================================================================

	gms_transactions_pub.validate_transaction( p_project_id		=> x_project_id,
						  p_task_id		=> x_task_id,
						  p_award_id		=> l_award_id,
						  p_expenditure_type	=> x_expenditure_type,
						  P_expenditure_item_date=> x_expenditure_item_date,
						  P_calling_module	=> 'TXNVALID',
						  p_outcome		=> l_outcome ) ;


	IF l_outcome is not null then
	   x_msg_type        := 'E' ;
	   X_msg_count       := 1 ;
	   X_msg_data        := l_outcome ;
	   x_msg_application := 'GMS' ;
	end if ;

EXCEPTION
    WHEN no_data_found then
	 IF c1%isopen  then
	    close c1 ;
         end if ;

	 x_msg_type	   := 'E' ;
	 X_msg_count	   := 1 ;
	 X_msg_data	   := 'GMS_AWARD_REQUIRED' ;
	 x_msg_application := 'GMS' ;

end validate_transaction ;

END GMS_AP_API2;

/
