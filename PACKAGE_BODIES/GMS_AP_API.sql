--------------------------------------------------------
--  DDL for Package Body GMS_AP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AP_API" AS
-- $Header: gmsapx1b.pls 120.3 2006/05/22 12:31:49 asubrama noship $

/*  Declare procedure GMS_AP_ER_HEADERS_AUT1
    P_invoice_id Invoice_id for AP_invoice_distributions_all
    p_report_header_id Ap_expense_report_headers ID
    p_reject_code 	   Rejection identifier
*/
-- For Bug 3269365: To check on, whether to print debug messages in log file or not
L_DEBUG varchar2(1) := NVL(FND_PROFILE.value('GMS_ENABLE_DEBUG_MODE'), 'N');
--End of Bug 3269365

PROCEDURE GMS_AP_ER_HEADERS_AUT1 (P_invoice_id         IN	NUMBER,
				   p_report_header_id	IN	NUMBER,
				   P_reject_code	IN	VARCHAR2 ) is

   X_expenditure_item_id   NUMBER ;
   X_cdl_line_num          NUMBER ;
   X_award_set_id          NUMBER ;
   X_ADL_REC               GMS_AWARD_DISTRIBUTIONS%ROWTYPE ;
   X_invoice_id            NUMBER ;
   X_invoice_dist_id       NUMBER ;
   X_report_header_id      NUMBER ;
   X_reject_code	    Varchar2(25) ;

    CURSOR C_ADL is
	select *
	  from gms_award_distributions adl
	 where expenditure_item_id  =   x_expenditure_item_id
	   and cdl_line_num         =   x_cdl_line_num
	   and document_type        =   'EXP'
	   and adl_status           =   'A' ;

    CURSOR C_ER_lines is
	select  erl.reference_1                 expenditure_item_id,
		erl.reference_2                  CDL_LINE_NUM,
		erl.project_id                  PROJECT_ID,
		erl.task_id                     TASK_ID,
		erl.distribution_line_number    distribution_line_number,
		apd.invoice_distribution_id     invoice_distribution_id,
		apd.award_id                    award_set_id
	  from  ap_expense_report_lines_all  erl,
		ap_invoice_distributions_all apd,
		pa_projects_all              p,
		gms_project_types            gpt
	 where  report_header_id            =   X_report_header_id
	   and  erl.distribution_line_number=   apd.distribution_line_number
	   and  apd.invoice_id              =   X_invoice_id
	   and  erl.project_id              =   apd.project_id
	   and  erl.task_id                 =   apd.task_id
	   and  erl.expenditure_type        =   apd.expenditure_type
	   and  erl.project_id              =   p.project_id
	   and  p.project_type              =   gpt.project_type
	   and  NVL(gpt.sponsored_flag,'N') =   'Y'  ;

 BEGIN
	  X_invoice_id      :=  p_invoice_id ;
	  X_report_header_id:=  p_report_header_id ;
	  X_reject_code     :=  p_reject_code ;

	  FOR C_ER_REC IN c_er_lines  LOOP

	      X_expenditure_item_id :=  C_er_rec.expenditure_item_id ;
	      X_cdl_line_num        :=  c_er_rec.cdl_line_num ;

	      open c_adl ;
	      fetch c_adl into X_adl_rec ;

	      IF c_adl%FOUND THEN
		 X_adl_rec.expenditure_item_id      := NULL ;
		 X_adl_rec.cdl_line_num             := NULL ;
		 X_adl_rec.document_type            := 'AP' ;
		 X_adl_rec.invoice_id               := X_invoice_id ;
		 X_adl_rec.distribution_line_number := C_ER_REC.distribution_line_number ;
		 X_adl_rec.invoice_distribution_id  := C_ER_REC.invoice_distribution_id ;
		 X_adl_rec.burdenable_raw_cost      := NULL ;
		 X_adl_rec.cost_distributed_flag    := 'N' ;
		 X_adl_rec.Raw_cost                 := NULL ;
		 X_adl_rec.FC_STATUS                := 'N' ;
		 X_adl_rec.adl_status               := 'A' ;
		 X_adl_rec.adl_line_num             := 1 ;
		 X_adl_rec.award_set_id             :=  gms_awards_dist_pkg.get_award_set_id ;



		 IF  c_er_rec.award_set_id is Not NULL OR
		     NVL(X_reject_code, 'X' ) <> 'X' THEN

		     update gms_award_distributions
			set adl_status = 'I'
		      where award_set_id            = NVL(c_er_rec.award_set_id,0)


			and document_type           = 'AP'
			and adl_status              = 'A'
			and invoice_id		    = X_invoice_id
			and distribution_line_number= C_ER_REC.distribution_line_number
			and invoice_distribution_id = c_er_rec.invoice_distribution_id;

		 END IF ;

		 gms_awards_dist_pkg.create_adls(x_adl_rec) ;

		 update ap_invoice_distributions_all
		    set award_id    = X_adl_rec.award_set_id
		  where invoice_id               = X_invoice_id
		    and distribution_line_number = X_adl_rec.distribution_line_number


		    and invoice_distribution_id  = X_adl_rec.invoice_distribution_id  ;


	      END IF ;

	      CLOSE C_ADL ;

	  END LOOP ;

  EXCEPTION
   WHEN OTHERS THEN
	RAISE ;
 END GMS_AP_ER_HEADERS_AUT1 ;

    -- Start of comments
    -- -----------------
    -- API Name         : V_CHECK_LINE_AWARD_INFO
    -- Type             : public
    -- Pre Reqs         : None
    -- Description      : Validate award related information.
    --
    -- Function         : This function is called from AP_IMPORT_INVOICES_PKG.
    -- Calling API      : ap_import_invoices_pkg.v_check_line_project_info
    --
    -- End of comments
    -- ----------------


FUNCTION V_CHECK_LINE_AWARD_INFO (
       p_invoice_line_id            	IN      NUMBER 		DEFAULT NULL,
	p_line_amount			IN	NUMBER 		DEFAULT NULL,
	p_base_line_amount		IN	NUMBER 		DEFAULT NULL,
	p_dist_code_concatenated	IN	VARCHAR2 	DEFAULT NULL,
	p_dist_code_combination_id	IN OUT NOCOPY	NUMBER,
	p_default_po_number		IN	VARCHAR2 	DEFAULT NULL,
	p_po_number			IN	VARCHAR2 	DEFAULT NULL,
	p_po_header_id			IN	NUMBER 		DEFAULT NULL,
	p_distribution_set_id		IN	NUMBER 		DEFAULT NULL,
	p_distribution_set_name		IN	VARCHAR2 	DEFAULT NULL,
	p_set_of_books_id		IN	NUMBER 		DEFAULT NULL,
	p_base_currency_code		IN	VARCHAR2 	DEFAULT NULL,
	p_invoice_currency_code		IN	VARCHAR2 	DEFAULT NULL,
	p_exchange_rate			IN	NUMBER 		DEFAULT NULL,
	p_exchange_rate_type		IN	VARCHAR2 	DEFAULT NULL,
	p_exchange_rate_date		IN	DATE 		DEFAULT NULL,
	p_project_id                    IN	NUMBER 		DEFAULT NULL,
	p_task_id                       IN	NUMBER 		DEFAULT NULL,
	p_expenditure_type              IN	VARCHAR2 	DEFAULT NULL,
	p_expenditure_item_date         IN	DATE 		DEFAULT NULL,
	p_expenditure_organization_id   IN	NUMBER 		DEFAULT NULL,
	p_project_accounting_context    IN	VARCHAR2 	DEFAULT NULL,
	p_pa_addition_flag              IN	VARCHAR2 	DEFAULT NULL,
	p_pa_quantity                   IN	NUMBER 		DEFAULT NULL,
	p_employee_id			IN	NUMBER 		DEFAULT NULL,
	p_vendor_id			IN	NUMBER 		DEFAULT NULL,
	p_chart_of_accounts_id		IN	NUMBER 		DEFAULT NULL,
	p_pa_installed			IN	VARCHAR2 	DEFAULT NULL,
	p_prorate_across_flag		IN	VARCHAR2 DEFAULT NULL,
       p_lines_attribute_category	IN	VARCHAR2 DEFAULT NULL,
       p_lines_attribute1             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute2             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute3             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute4             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute5             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute6             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute7             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute8             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute9             	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute10            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute11            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute12            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute13            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute14            	IN	VARCHAR2 DEFAULT NULL,
	p_lines_attribute15            	IN	VARCHAR2 DEFAULT NULL,
       p_attribute_category		IN	VARCHAR2 DEFAULT NULL,
       p_attribute1             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute2             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute3             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute4             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute5             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute6             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute7             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute8             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute9             	IN	VARCHAR2 DEFAULT NULL,
	p_attribute10            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute11            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute12            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute13            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute14            	IN	VARCHAR2 DEFAULT NULL,
	p_attribute15            	IN	VARCHAR2 DEFAULT NULL,
	p_partial_segments_flag		IN 	VARCHAR2 DEFAULT NULL,
	p_default_last_updated_by	IN	NUMBER   DEFAULT NULL,
	p_default_last_update_login	IN	NUMBER   DEFAULT NULL,
	p_calling_sequence		IN	VARCHAR2 DEFAULT NULL,
	p_award_id    		      IN OUT NOCOPY   NUMBER,
       P_EVENT				IN      varchar2 ) return BOOLEAN
IS
	lb_return	BOOLEAN ;
	l_output	varchar2(2000) ;
	l_award_set_id	NUMBER ;
	l_adl_rec	gms_award_distributions%ROWTYPE ;
BEGIN
	lb_return := TRUE ;
--	IF NOT gms_install.enabled THEN -- Bug 3002305.
	IF NOT gms_pa_api.vert_install THEN
		RETURN lb_return ;
	END IF ;

	IF P_EVENT = 'AWARD_SET_ID_REQUEST' THEN
 		GMS_TRANSACTIONS_PUB.VALIDATE_TRANSACTION( P_project_id ,
							   P_task_id ,
							   P_award_id ,
							   P_expenditure_type ,
							   P_expenditure_item_date ,
							   p_calling_sequence ,
							   l_output        ) ;
		IF l_output is not NULL THEN
--For bug 3269365 :ATG project common logging . Introduced gms_debug
		  IF L_DEBUG = 'Y' THEN
			gms_error_pkg.set_debug_context ;
			gms_error_pkg.gms_debug( 'GMS:'||l_output||' Invoice line ID :'||p_invoice_line_id, 'C') ;
			--fnd_file.put_line(FND_FILE.LOG, 'GMS:'||l_output||' Invoice line ID :'||p_invoice_line_id) ;
		  END IF;
--End of bug 3269365
			lb_return := FALSE ;
		ELSE
                  /* AP Lines change: Create adls when p_award_id is not null.*/
                  IF p_award_id IS NULL then
                      Return lb_return;
                  END IF ;
		  /*  Create ADL for Account generator . */

		  l_award_set_id := gms_awards_dist_pkg.get_award_set_id ;
		  l_adl_rec.award_set_id	:= l_award_set_id ;
		  l_adl_rec.adl_line_num	:= 1 ;
                 l_adl_rec.document_type	:= 'OPI' ;
		  l_adl_rec.distribution_value	:= 100 ;
                 l_adl_rec.project_id          := p_project_id ;
                 l_adl_rec.task_id             := p_task_id ;
                 l_adl_rec.award_id            := p_award_id ;
                 l_adl_rec.request_id          := FND_GLOBAL.CONC_REQUEST_ID ;
            	  l_adl_rec.adl_status          := 'A' ;
           	  l_adl_rec.line_type           := 'R' ;
            l_adl_rec.invoice_distribution_id  := p_invoice_line_id ;
	         gms_awards_dist_pkg.create_adls( l_adl_rec ) ;
	                             p_award_id := l_award_set_id ;
	END IF ;

	ELSIF P_EVENT = 'AWARD_SET_ID_REMOVE' THEN
		delete from gms_award_distributions
		 where award_set_id = p_award_id
		   and adl_line_num = 1
		   and document_type = 'OPI'  ;
	END IF ;
	return lb_return ;
 EXCEPTION
	WHEN others then
		lb_return := FALSE ;
		RAISE ;
END  V_CHECK_LINE_AWARD_INFO;

    -- Start of comments
    -- -----------------
    -- API Name         : CREATE_AWARD_DISTRIBUTIONS
    -- Type             : public
    -- Pre Reqs         : None
    -- Description      : Create award distribution lines for the parameter
    --                    passed.
    -- Calling API      : ap_import_invoices_pkg
    --
    -- End of comments
    -- ----------------

PROCEDURE CREATE_AWARD_DISTRIBUTIONS( p_invoice_id	         IN NUMBER,
				      p_distribution_line_number IN NUMBER,
				      p_invoice_distribution_id  IN NUMBER,
				      p_award_id		 IN NUMBER,
				      p_mode		 	 IN VARCHAR2 default 'AP',
				      p_dist_set_id		 IN NUMBER   default NULL,
				      p_dist_set_line_number     IN NUMBER   default NULL
				    )  is
	CURSOR C_ADL_REC is
		SELECT *
		  from gms_award_distributions ADL
		 where award_set_id = p_award_id
		   and adl_status   = 'A'
               and adl_line_num = 1  -- AP Lines uptake
		   and document_type= 'APD' ;
	cursor c_ap_rec is
	  SELECT A.invoice_id 		INVOICE_ID,
		 A.distribution_line_number	distribution_line_number,
		 A.invoice_distribution_id	invoice_distribution_id,
		 A.project_id			PROJECT_ID,
		 A.task_id			TASK_ID,
		 A.last_update_date		LAST_UPDATE_DATE,
		 A.creation_date		CREATION_DATE,
		 A.last_updated_by		LAST_UPDATED_BY,
		 A.created_by			CREATED_BY,
		 A.last_update_login		LAST_UPDATE_LOGIN
	    from ap_invoice_distributions_all  	A,
		 pa_projects_all		B,
		 gms_project_types		C
	   where invoice_id 		  = p_invoice_id
	     and distribution_line_number = p_distribution_line_number
	     and invoice_distribution_id  = p_invoice_distribution_id
	     and a.project_id		  = b.project_id
	     and b.project_type		  = c.project_type
	     and c.sponsored_flag		  = 'Y' ;
	l_ap_rec    c_ap_rec%ROWTYPE ;
	l_adl_rec	gms_award_distributions%ROWTYPE ;
BEGIN
--	IF NOT gms_install.enabled THEN  -- Bug 3002305
	IF NOT gms_pa_api.vert_install THEN
		return ;
	END IF ;
	IF p_mode = 'AP' THEN
		FOR LOOP_AP_REC IN C_AP_REC LOOP
		    l_adl_rec.award_set_id :=  gms_awards_dist_pkg.get_award_set_id ;
		    l_adl_rec.invoice_id   :=  p_invoice_id ;
		    l_adl_rec.distribution_line_number := p_distribution_line_number ;
		    l_adl_rec.invoice_distribution_id  := p_invoice_distribution_id ;
		    l_adl_rec.document_type	       := 'AP' ;
		    l_adl_rec.project_id	       := loop_ap_rec.project_id ;
		    l_adl_rec.task_id	       	       := loop_ap_rec.task_id ;
		    l_adl_rec.award_id	       	       := p_award_id ;
	   	    l_adl_rec.adl_line_num  		:= 1 ;
		    l_adl_rec.distribution_value	:= 100 ;
		    l_adl_rec.adl_status  		:= 'A' ;
		    l_adl_rec.line_type   		:= 'R' ;
		    l_adl_rec.last_update_date 		:= loop_ap_rec.last_update_date ;
		    l_adl_rec.creation_date 		:= loop_ap_rec.creation_date ;
		    l_adl_rec.last_updated_by   	:= loop_ap_rec.last_updated_by ;
		    l_adl_rec.created_by   		:= loop_ap_rec.created_by ;
		    l_adl_rec.last_update_login 	:= loop_ap_rec.last_update_login ;
		    gms_awards_dist_pkg.create_adls( l_adl_rec ) ;
		    update ap_invoice_distributions_all
		       set award_id = l_adl_rec.award_set_id
	   	     where invoice_id 			= loop_ap_rec.invoice_id
	               and distribution_line_number 	= loop_ap_rec.distribution_line_number
                       and invoice_distribution_id  	= loop_ap_rec.invoice_distribution_id  ;

		END LOOP ;
	ELSIF p_mode = 'APD' THEN
		OPEN C_ADL_REC ;
		FETCH C_ADL_REC INTO l_ADL_REC ;
		IF C_ADL_REC%FOUND THEN
		    l_adl_rec.award_set_id :=  gms_awards_dist_pkg.get_award_set_id ;
		    l_adl_rec.invoice_id   	       :=  p_invoice_id ;
		    l_adl_rec.distribution_line_number := p_distribution_line_number ;
		    l_adl_rec.invoice_distribution_id  := p_invoice_distribution_id ;
		    l_adl_rec.document_type	       := 'AP' ;
		    l_adl_rec.line_type   		:= 'R' ;
		    gms_awards_dist_pkg.create_adls( l_adl_rec ) ;
		    update ap_invoice_distributions_all
		       set award_id = l_adl_rec.award_set_id
	   	     where invoice_id 			= p_invoice_id
	               and distribution_line_number 	= p_distribution_line_number


	               and invoice_distribution_id  	= p_invoice_distribution_id  ;


		END IF ;
		CLOSE C_ADL_REC ;
	END IF ;
	return ;


 EXCEPTION


	WHEN OTHERS THEN


		RAISE ;
 END CREATE_AWARD_DISTRIBUTIONS ;


    -- Start of comments
    -- -----------------
    -- API Name         : GET_DISTRIBUTION_AWARD
    -- Type             : public
    -- Pre Reqs         : None
    -- Description      : Get award_id attached to adls associated with the
    --                    ap invoice distribution lines.
    -- Calling API      : ap_import_invoices_pkg
    --
    -- End of comments
    -- ----------------

-- ===================================================================================
-- BUG : 2972963
-- APXIIMPT IMPORT ERRORS WITH REP-1419 AND ORA-01400 WHEN PRORATING NON_ITEM_LINE
-- Analysis - There is a error in cursors select C_ADL_REC.
-- Invalid join award_set_id = p_award_id causing no data found.
-- Resolution -
-- Join condition was corrected as follows :
-- award_set_id = p_award_set_id
-- ==================================================================================

Procedure GET_DISTRIBUTION_AWARD ( p_invoice_id 	       IN NUMBER,
				   p_distribution_line_number IN NUMBER,
				   p_invoice_distribution_id  IN NUMBER,
				   p_award_set_id             IN NUMBER,
				   p_award_id               IN OUT NOCOPY  NUMBER   ) IS
	l_award_id	NUMBER ;

	CURSOR C_ADL_REC is
		select award_id
		  from gms_award_distributions ADL
		 where award_set_id = p_award_set_id
                   and adl_line_num = 1 ;

		   --and document_type = 'AP'
		   --and adl_status    = 'A'
		   --and invoice_id    = p_invoice_id
		   --and distribution_line_number = p_distribution_line_number ;
		   --where award_set_id = p_award_id  ( 2972963 Fix )
BEGIN
        -- =======================================================================
	-- Code Review feedback.
	-- We don't need to check for gms_install.enabled here. we should check for
	-- p_award_set_id is not null. Currently test case failed for non spon
	-- project.
	-- =======================================================================

	IF p_award_set_id is NULL THEN
	   return ;
        END IF ;

	--IF NOT gms_install.enabled THEN
	-- return ;
	--END IF ;


	OPEN C_ADL_REC ;


	fetch C_ADL_REC into l_award_id ;


	IF C_ADL_REC%FOUND THEN


		p_award_id := l_award_id ;
	ELSE


		raise no_data_found ;
	END IF ;


	CLOSE C_ADL_REC ;


 EXCEPTION


	WHEN no_data_found then


		IF C_ADL_REC%ISOPEN THEN
		   CLOSE C_ADL_REC ;
		END IF ;
		RAISE ;
	WHEN OTHERS THEN


		RAISE ;
 END GET_DISTRIBUTION_AWARD ;


FUNCTION GMS_DEBUG_SWITCH( p_debug_flag varchar2 ) return boolean is
BEGIN
	IF p_debug_flag in ( 'y', 'Y' ) then
		return TRUE ;
	ELSE
		return FALSE ;
	END IF ;

EXCEPTION
       WHEN OTHERS  THEN
		raise ;
END GMS_DEBUG_SWITCH ;

 /* AP Lines change: Added additional parameter p_invoice_distribution_id */
 PROCEDURE     create_prepay_adl( p_prepay_dist_id   IN NUMBER,
                                  p_invoice_id       IN NUMBER,
		                  p_next_dist_line_num IN NUMBER,
                                p_invoice_distribution_id IN NUMBER
                                  ) is
    X_award_set_id      NUMBER ;
    x_adl_rec           gms_award_distributions%ROWTYPE ;
    x_ap_rec            ap_invoice_distributions_all%ROWTYPE ;

    x_inv_dist_id       NUMBER ;
    X_amount            NUMBER ;
    Cursor C_get_adl_id is
         select award_id
         from  ap_invoice_distributions_all
         where  Invoice_distribution_id =  p_prepay_dist_id ;
    Cursor C_adl is
       select *
       from  gms_award_distributions
       where  award_set_id =   X_award_set_id
       and  adl_line_num = 1  ;
    Cursor c_new_dist_line is
       select *
       from ap_invoice_distributions_all
       where invoice_id               = p_invoice_id
       and distribution_line_number =  p_next_dist_line_num
       and invoice_distribution_id = p_invoice_distribution_id; -- AP Line change: added additional join
  BEGIN
--	 IF NOT gms_install.enabled THEN -- Bug 3002305
	 IF NOT gms_pa_api.vert_install THEN
	    return ;
	 END IF ;

         OPEN  C_get_adl_id ;
         FETCH C_get_adl_id into X_award_set_id ;
         CLOSE C_get_adl_id ;
         IF NVL(X_award_set_id,0) = 0 THEN
            RETURN ;
         END IF ;
         OPEN C_ADL ;
         FETCH C_ADL into X_ADL_REC ;
         IF C_ADL%NOTFOUND THEN
          close c_adl ;
            return ;
         END IF ;
         CLOSE C_adl ;
         open c_new_dist_line ;
        FETCH c_new_dist_line into x_ap_rec ;
        CLOSE c_new_dist_line ;
        x_amount         := x_ap_rec.amount ;
        x_inv_dist_id    := x_ap_rec.invoice_distribution_id ;
        x_adl_rec.award_set_id            := gms_awards_dist_pkg.get_award_set_id ;

   	 x_adl_rec.invoice_id               := p_invoice_id;
	 x_adl_rec.invoice_distribution_id  := x_inv_dist_id ;
	 x_adl_rec.distribution_line_number := p_next_dist_line_num ;
	 x_adl_rec.document_type            := 'AP' ;
	 x_adl_rec.adl_status		    := 'A' ;
        x_adl_rec.expenditure_item_id      := NULL;
         -- =====================================================
         -- We know that funds check doesnt happen in this case.
         -- Verify in testing ....
         -- =====================================================
	 x_adl_rec.fc_status		    := 'N' ;
	 x_adl_rec.burdenable_raw_cost      := 0 ;
         gms_awardS_dist_pkg.create_adls( X_adl_rec) ;
         UPDATE GMS_AWARD_DISTRIBUTIONS
            SET BUD_TASK_ID = x_adl_rec.BUD_TASK_ID
         WHERE AWARD_SET_ID = x_adl_rec.award_set_id
         AND ADL_STATUS   = 'A' ;
         Update ap_invoice_distributions_all
         Set award_id = x_adl_rec.award_set_id
         Where invoice_distribution_id =  x_inv_dist_id ;

         gms_cost_plus_extn.CALC_prepayment_burden( X_AP_REC, x_adl_rec) ;

 EXCEPTION
 when others then
 raise;
 END  create_prepay_adl  ;

--============================================================================
-- BUG: 2676134 ( APXIIMPT distribution set with invalid award not validated.
--============================================================================
 PROCEDURE get_dist_set_award (  p_distribution_set_id		IN NUMBER,
				p_distribution_set_line_number	IN NUMBER,
				p_award_set_id			IN NUMBER,
				p_award_id		   IN OUT  NOCOPY  NUMBER ) is
	cursor c_get_award is
		select adl.award_id
	          from ap_distribution_set_lines apd,
		       gms_award_distributions       adl
		 where apd.distribution_set_id  = p_distribution_set_id
		   and apd.distribution_set_line_number = p_distribution_set_line_number
                   and adl.award_set_id         = p_award_set_id
		   and apd.award_id		= adl.award_set_id
		   and adl.adl_line_num 	= 1 ;

	l_award_id	NUMBER ;
BEGIN
	IF p_award_set_id is not NULL THEN
		open  c_get_award ;
		fetch c_get_award   into l_award_id ;
		close c_get_award ;

		p_award_id	:= l_award_id ;
	END IF ;

END get_dist_set_award ;


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
                          and adl.invoice_distribution_id = A.invoice_distribution_id  -- AP Lines uptake
				  and adl.document_type            = 'AP'
				  and adl.award_set_id             = NVL(a.award_id,0)
				  and adl.adl_line_num             = 1
				  and adl.adl_status               = 'A' ) ;



BEGIN

 -- Start of comment
 -- Verify that grants is enabled.
 -- End of comments.
 --
-- IF NOT gms_install.enabled THEN -- Bug 3002305
 IF NOT gms_pa_api.vert_install THEN
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
    update gms_award_distributions  adl
	   set adl.adl_status = 'A'
     where adl.document_type = 'AP'
	 and adl.adl_status    = 'I'
	 and adl.award_set_id in ( select adl2.award_set_id
				     from gms_award_distributions adl2,
				          ap_invoice_distributions_all apd
				    where apd.invoice_id    = p_invoice_id
				      and apd.award_id 		is not null
				      and adl2.award_set_id = apd.award_id
				      and adl2.invoice_id	= apd.invoice_id
				      and adl2.document_type	= 'AP'
				      and adl2.distribution_line_number	= apd.distribution_line_number
                              and adl2.invoice_distribution_id = apd.invoice_distribution_id  -- added join for AP Lines uptake
				      and adl2.adl_status	= 'I'  ) ;

    -- Inactivate ADLS that belongs to the AP distribution line but
    -- not tied up with award_id in ap_distribution line.
    -- Inactivate dangling active adls.
    -- ----
    update gms_award_distributions  adl
	   set adl.adl_status = 'I'
     where adl.document_type = 'AP'
	 and adl.adl_status    = 'A'
	 and adl.award_set_id in ( select adl2.award_set_id
				     from gms_award_distributions adl2,
				          ap_invoice_distributions_all apd
				    where apd.invoice_id    = p_invoice_id
				      and apd.award_id 		is not null
				      and adl2.award_set_id <> apd.award_id
				      and adl2.invoice_id	= apd.invoice_id
				      and adl2.document_type= 'AP'
				      and adl2.distribution_line_number = apd.distribution_line_number
                              and adl2.invoice_distribution_id = apd.invoice_distribution_id  -- added join for AP Lines uptake
				      and adl2.adl_status	= 'A'  ) ;


     -- ==================================================
     -- Update award_id to NULL for non sponsored
     -- projects.
     -- =================================================
     -- Bug : 4956860
     -- R12.PJ:XB2:DEV:GMS: APPSPERF:  PACKAGE:GMSAPX1B.PLS
     --
     -- UPDATE ap_invoice_distributions_all apd
     --    SET award_id = NULL
     --  where apd.invoice_id = p_invoice_id
     --    and apd.award_id is not NULL
     --    and apd.invoice_distribution_id in ( select a.invoice_distribution_id
     -- 					 from ap_invoice_distributions_all  	A,
     --                				      pa_projects_all                p,
     --                				      gms_project_types          gpt
     -- 					where a.invoice_id          = p_invoice_id
     -- 					  and a.project_id          = p.project_id
     -- 					  and p.project_type        = gpt.project_type
     -- 					  and gpt.sponsored_flag    = 'N'  ) ;

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
      -- ===========================================================================
      -- AP Lines uptake: Calling sequence of 'AWARD_ID' indicates that x_award_id
      -- holds the value of award_id and we don't need to fetch award_id from cursor
      -- ===========================================================================
      IF x_calling_sequence = 'AWARD_ID' THEN
         l_award_id := x_award_id;
      ELSE
	   open c1 ;
         fetch c1 into l_award_id ;
         IF c1%notfound then
            raise no_data_found ;
         end if ;
         close c1 ;
      END IF;


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


/* AP Lines uptake: Overloaded API ( with GET_DISTRIBUTION_AWARD) with
 * prgma settings so that it can be called in the sqls.*/
FUNCTION GET_DISTRIBUTION_AWARD
      (p_award_set_id   IN NUMBER) return NUMBER IS

      l_award_id	NUMBER ;
      CURSOR C_ADL_REC is
         select award_id
         from gms_award_distributions ADL
         where award_set_id = p_award_set_id
           and adl_line_num = 1 ;

BEGIN
   IF p_award_set_id is NULL THEN
      return to_number(NULL);
   END IF ;
      OPEN C_ADL_REC ;
      fetch C_ADL_REC into l_award_id ;
      IF C_ADL_REC%NOTFOUND THEN
         raise no_data_found ;
      END IF ;
      CLOSE C_ADL_REC ;
      Return l_award_id ;
EXCEPTION
   WHEN no_data_found then
      IF C_ADL_REC%ISOPEN THEN
         CLOSE C_ADL_REC ;
      END IF ;
      RAISE ;
   WHEN OTHERS THEN
      RAISE ;
END GET_DISTRIBUTION_AWARD ;

/* Added for Bug 5194359 */
FUNCTION vert_install RETURN BOOLEAN IS
BEGIN
    RETURN gms_pa_api.vert_install;
END vert_install;

END GMS_AP_API;

/
