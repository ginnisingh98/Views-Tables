--------------------------------------------------------
--  DDL for Package Body GMS_AWARDS_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_AWARDS_DIST_PKG" as
-- $Header: gmsadlsb.pls 120.5 2006/07/01 07:26:31 cmishra noship $

   -- -----------------------------------------
   -- get_award_set_id returns the next
   -- award set id in sequence.
   -- -----------------------------------------
   FUNCTION get_award_set_id  return NUMBER is
	 x_award_set_id	NUMBER ;
	 p_err_code		NUMBER ;
	 p_err_buf		varchar2(2000) ;
   BEGIN

	SELECT gms_adls_award_set_id_s.NEXTVAL
      INTO x_award_set_id
	  FROM dual ;
     return nvl(x_award_set_id,0) ;
   EXCEPTION
	 WHEN OTHERS THEN
		 GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG : get_award_set_id ',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
		RAISE ;
   END get_award_set_id ;
   -- ================== END OF get_award_set_id ===================

   -- Bug 5344693 : Added a new parameter p_called_from
   PROCEDURE copy_adls( p_award_set_id      IN  NUMBER ,
                        P_NEW_AWARD_SET_ID  OUT NOCOPY NUMBER,
                        p_doc_type          IN  varchar2,
                        p_dist_id           IN  NUMBER,
                        P_INVOICE_ID        IN  NUMBER DEFAULT NULL,
                        p_dist_line_num     IN  NUMBER DEFAULT NULL,
                        p_raw_cost          IN  NUMBER DEFAULT NULL,
			p_called_from       IN  varchar2 DEFAULT 'NOT_MISC_SYNCH_ADLS')  IS

	 x_adls_rec	 gms_award_distributions%ROWTYPE	;
     g_rec_index 	    Number ;
     x_new_award_set_id     NUMBER ;
     x_line_num_reversed    NUMBER ;
     x_reversed_flag        varchar2(1) ;
     x_adl_line_num         NUMBER ;
     x_amount               NUMBER ;
	 X_billable_flag		varchar2(1) ;
     x_ind_compiled_set_id  NUMBER ;
	 p_err_code				NUMBER ;
	 p_err_buf				varchar2(2000) ;

     CDL_NOT_FOUND          EXCEPTION;
     PRAGMA                 EXCEPTION_INIT(CDL_NOT_FOUND, -20000 ) ;

	 -- ------------------------------------------------------
	 -- CURSOR : C_CDL is declared to fetch values which are
	 -- 		 required to create adls.
	 -- p_dist_line_num	= CDL LINE NUMBER
	 -- p_dist_id		= Expenditure Item ID.
	 -- -------------------------------------------------------
     CURSOR C_CDL IS
            SELECT line_num_reversed,
                   REVERSED_FLAG,
                   IND_COMPILED_SET_ID,
				   BILLABLE_FLAG,
                   AMOUNT
              FROM PA_COST_DISTRIBUTION_LINES_ALL
             WHERE LINE_NUM         = p_dist_line_num
               and expenditure_item_id  = p_dist_id  ;
   BEGIN

         g_rec_index  := 1 ;
         --
	 -- 3478028
	 -- 11.5.10 Patch for grants accounting.
         -- BUG: 3517362 forward port funds check related changes.

         --IF p_doc_type = 'AP' and NVL(PSA_FUNDS_CHECKER_PKG.g_fc_autonomous_flag,'N') = 'Y'then
	 /* Bug 5344693 : The procedure copy_adls is called from the function gms_funds_control_pkg.misc_synch_adls
	                  to create ADLS for the Price Variance record in the scenario when we are trying to funds
			  check for an invoice matched to a PO with price variance. */
         IF ((p_doc_type = 'AP') and (p_called_from <> 'MISC_SYNCH_ADLS')) then
            return ;
         end if ;


	 -- -----------------------------------------------
	 -- Special requirements for expenditure items.
	 -- We need line_num_reversed, REVERSED_FLAG,
	 -- IND_COMPILED_SET_ID, AMOUNT, fetched
	 -- using C_CDL cursor.
	 -- ADL_LINE_NUM should be the max(line_num) + 1.
	 -- -----------------------------------------------
     IF p_doc_type = 'EXP' THEN

        OPEN C_CDL ;

        FETCH C_CDL
         INTO x_line_num_reversed,
              x_reversed_flag ,
              x_ind_compiled_set_id,
			  X_billable_flag,
              x_amount ;

        IF C_CDL%NOTFOUND THEN
		   -- CDL NOT found so we can not create ADL.
		   -- --------------------------------------
		   close C_CDL ;
		   return ;
        ELSE
          update gms_award_distributions
             set reversed_flag  = 'Y'
           where award_set_id   =  p_award_set_id
             and document_type  =  'EXP'
             and adl_status     =  'A'
             and cdl_line_num   =  nvl(x_line_num_reversed, -9 )
             and expenditure_item_id =  p_dist_id ;
        END IF ;
		close C_CDL ;
		-- ---------------------------------
		-- Get the next adl line num.
		-- --------------------------------
        SELECT max(adl_line_num ) + 1
          INTO x_adl_line_num
          FROM gms_award_distributions
         where award_set_id = p_award_set_id ;

         x_new_award_set_id := p_award_set_id ;
	 ELSE
		-- -------------------------
	 	-- Get the award set id .
	 	-- -------------------------
		 x_new_award_set_id := get_award_set_id ;

     END IF ;


	 -- -----------------------------------
	 -- Create new record into ADL.
	 -- -----------------------------------
     INSERT INTO gms_award_distributions (  award_set_id ,
                                            adl_line_num,
                                            funding_pattern_id,
                                            distribution_value ,
											raw_cost,
                                            document_type,
                                            project_id                 ,
                                            task_id                    ,
                                            award_id                   ,
                                            --expenditure_type           ,
                                            expenditure_item_id        ,
                                            cdl_line_num               ,
                                            ind_compiled_set_id        ,
                                            gl_date                    ,
                                            request_id                 ,
                                            line_num_reversed          ,
                                            resource_list_member_id    ,
                                    --output_vat_tax_id          ,--ETax Change:Replace the tax_id with classificationcode
				            output_tax_classification_code,
                                            output_tax_exempt_flag     ,
                                            output_tax_exempt_reason_code  ,
                                            output_tax_exempt_number   ,
                                            adl_status                 ,
                                            fc_status                  ,
                                            line_type                  ,
                                            capitalized_flag           ,
                                            capitalizable_flag         ,
                                            reversed_flag              ,
                                            revenue_distributed_flag   ,
                                            billed_flag                ,
                                            bill_hold_flag             ,
                                            distribution_id            ,
                                            po_distribution_id         ,
                                            invoice_distribution_id    ,
                                            parent_award_set_id        ,
                                            invoice_id                 ,
                                            parent_adl_line_num         ,
                                            distribution_line_number   ,
                                            burdenable_raw_cost        ,
                                            cost_distributed_flag      ,
                                            last_update_date           ,
                                            last_updated_by             ,
                                            created_by                 ,
                                            creation_date              ,
                                            last_update_login          ,
											billable_flag				)
         select
                  x_new_award_set_id ,
                  decode(p_doc_type, 'EXP', x_adl_line_num, adl_line_num ) ,  -- ADL_LINE_NUM
                  funding_pattern_id,
                  distribution_value ,
                  decode(p_doc_type, 'EXP', x_amount, p_raw_cost ) ,--  p_raw_cost
                  p_doc_type,
                  project_id                 ,
                  task_id                    ,
                  award_id                   ,
                  --expenditure_type           ,
                  decode(p_doc_type, 'EXP', p_dist_id, expenditure_item_id ),--  expenditure_item_id
                  decode(p_doc_type, 'EXP', p_dist_line_num, CDL_line_num ) ,--  cdl_line_num
                  decode(p_doc_type, 'EXP', x_ind_compiled_set_id, ind_compiled_set_id ) ,--  ind_compiled_set_id
                  gl_date                    ,
                  request_id                 ,
                  decode(p_doc_type, 'EXP', x_line_num_reversed, line_num_reversed ) ,--  line_num_reversed
                  resource_list_member_id    ,
                  --output_vat_tax_id          , --ETax Changes
		  output_tax_classification_code,
                  output_tax_exempt_flag     ,
                  output_tax_exempt_reason_code  ,
                  output_tax_exempt_number   ,
                  adl_status                 ,
                  'N'                       , -- FC_STATUS
                  line_type                  ,
                  NVL(capitalized_flag,'N')  ,
                  capitalizable_flag		,
                  decode(p_doc_type, 'EXP', x_reversed_flag, reversed_flag ) ,--   reversed_flag
                  'N'                       , --revenue_distributed_flag   ,
                  'N'                       , --billed_flag
                  NULL                       , --bill_hold_flag
                  decode(p_doc_type, 'REQ', p_dist_id, NULL), -- distribution_id            ,
                  decode(p_doc_type, 'PO', p_dist_id, NULL), -- po_distribution_id            ,
                  decode(p_doc_type, 'AP', p_dist_id, NULL), -- invoice_distribution_id            ,
                  parent_award_set_id        ,
                  P_invoice_id               ,
                  parent_adl_line_num        ,
                  decode(p_doc_type, 'AP',p_dist_line_num,NULL)             ,
                  null                       , -- burdenable_raw_cost
                  'N'                      ,  -- cost_distributed_flag      ,
                  sysdate                    , -- last_update_date
                  nvl(fnd_global.user_id,0)  , -- last_updated_by            ,
                  nvl(fnd_global.user_id,0)  , -- created_by                 ,
                  sysdate                    , -- creation_date              ,
                  last_update_login			,
				  nvl( x_billable_flag, NVL(billable_flag,'Y') )
           from   GMS_AWARD_DISTRIBUTIONS
          where   AWARD_SET_ID  = P_AWARD_SET_ID
            AND   ADL_STATUS    = 'A'
			AND   rownum < 2 ;


     -- ----------------------------------------------
     -- Need to update the Distribution line with the
     -- new award_set_id
     -- ----------------------------------------------
      IF p_doc_type = 'PO' THEN
         update po_distributions_all
            set award_id = x_new_award_set_id
          where po_distribution_id = p_dist_id
            and award_id        = p_award_set_id
            and exists ( select 'X'
                          from gms_award_distributions
                         where award_set_id = x_new_award_set_id
                        ) ;
         p_new_award_set_id := x_new_award_set_id ;

      /* Bug 5344693 : The procedure copy_adls is called from the function gms_funds_control_pkg.misc_synch_adls
	               to create ADLS for the Price Variance record in the scenario when we are trying to funds
	               check for an invoice matched to a PO with price variance. After the ADL is created for the
		       IPV distribution the new award_set_id is stamped on the IPV distribution. */
      ELSIF  ((p_doc_type = 'AP') and (p_called_from = 'MISC_SYNCH_ADLS')) THEN
	    -- 3478028 11.5.10 grants accounting patch.
	    -- --------------------------------------------------
	    -- Create a link between ap_invoice_distributions_all
	    -- and ADL.
	    -- --------------------------------------------------
            -- BUG: 3517362 forward port funds check related changes.

            -- In r12, FC mode is always autonomous ...

            -- IF NVL(PSA_FUNDS_CHECKER_PKG.g_fc_autonomous_flag,'N') <> 'Y' THEN

               UPDATE ap_invoice_distributions_all
                  set award_id = x_new_award_set_id
                WHERE invoice_id               = p_invoice_id
                  and invoice_distribution_id  = p_dist_id
                  and exists ( select 'X'
                                 from gms_award_distributions
                                where award_set_id = x_new_award_set_id
                              ) ;

		/* Bug 5344693 : The following update is added to stamp the distribution_line_number correctly
		   on gms_award_distributions. */
		UPDATE gms_award_distributions
		   set distribution_line_number = (select distribution_line_number
		                                    from  ap_invoice_distributions_all
						    where invoice_id = p_invoice_id
						    and   invoice_distribution_id  = p_dist_id
						    and   award_id = x_new_award_set_id )
                   where award_set_id = x_new_award_set_id
		   and   invoice_id = p_invoice_id
		   and   invoice_distribution_id  = p_dist_id;

               p_new_award_set_id := x_new_award_set_id ;
            -- END IF ;


	    NULL ;
      ELSIF p_doc_type = 'REQ' THEN  -- Bug 2155774
	update po_req_distributions
	   set award_id = x_new_award_set_id
	 where distribution_id = p_dist_id
	   and award_id = p_award_set_id
           and exists ( select 'X'
                          from gms_award_distributions
                         where award_set_id = x_new_award_set_id
                        ) ;
         p_new_award_set_id := x_new_award_set_id ;

      END IF ;


   EXCEPTION
        WHEN CDL_NOT_FOUND THEN
            CLOSE C_CDL ;

		    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG :COPY ADLS',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
			RAISE ;

		WHEN OTHERS THEN

		 GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG :Create_adls',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
			RAISE ;
   END copy_adls ;
   -- ================= END OF copy_adls ================================

   -- ----------------------------------------------------------------
   -- CREATE_ADLS
   -- The following function allows to create ADL and shared all across.
   -- -----------------------------------------------------------------
   PROCEDURE create_adls( p_adls_rec	gms_award_distributions%ROWTYPE )  IS
	 x_adls_rec	 gms_award_distributions%ROWTYPE	;
     g_rec_index number ;
	 p_err_code				NUMBER ;
	 p_err_buf				varchar2(2000) ;
   BEGIN
         g_rec_index := 1 ;
	 x_adls_rec	:= p_adls_rec ;

	 IF x_adls_rec.last_update_date is NULL then
		x_adls_rec.last_update_date			:= sysdate ;
	 END IF ;
	 IF x_adls_rec.last_updated_by is NULL THEN
		x_adls_rec.last_updated_by			:= nvl(fnd_global.user_id,0) ;
	 END IF ;
	 IF x_adls_rec.created_by is NULL THEN
		x_adls_rec.created_by				:= nvl(fnd_global.user_id,0) ;
	 END IF ;

	 IF x_adls_rec.creation_date is NULL THEN
		x_adls_rec.creation_date			:= SYSDATE ;
	 END IF ;

	 IF x_adls_rec.last_update_login is NULL THEN
		x_adls_rec.last_update_login			:= 0 ;
	 END IF ;

         /* Bug 4301049, 4610217  starts here */
         -- 22-NOV-2005

         IF  x_adls_rec.distribution_value is NULL THEN
             x_adls_rec.distribution_value:=100;
         END IF;
         /* Bug 4301049, 4610217  ends here */

	 INSERT into gms_award_distributions (  award_set_id ,
                                            adl_line_num,
                                            funding_pattern_id,
                                            distribution_value ,
											raw_cost,
                                            document_type,
                                            project_id                 ,
                                            task_id                    ,
                                            award_id                   ,
                                            --expenditure_type           ,
                                            expenditure_item_id        ,
                                            cdl_line_num               ,
                                            ind_compiled_set_id        ,
                                            gl_date                    ,
                                            request_id                 ,
                                            line_num_reversed          ,
                                            resource_list_member_id    ,
                   --output_vat_tax_id          ,--ETax Changes Replacing the tax id changes with tax_classification code
					    output_tax_classification_code,
                                            output_tax_exempt_flag     ,
                                            output_tax_exempt_reason_code  ,
                                            output_tax_exempt_number   ,
                                            adl_status                 ,
                                            fc_status                  ,
                                            line_type                  ,
                                            capitalized_flag           ,
                                            capitalizable_flag         ,
                                            reversed_flag              ,
                                            revenue_distributed_flag   ,
                                            billed_flag                ,
                                            bill_hold_flag             ,
                                            distribution_id            ,
                                            po_distribution_id         ,
                                            invoice_distribution_id    ,
                                            parent_award_set_id        ,
                                            invoice_id                 ,
                                            parent_adl_line_num         ,
                                            distribution_line_number   ,
                                            burdenable_raw_cost        ,
                                            cost_distributed_flag      ,
                                            last_update_date           ,
                                            last_updated_by             ,
                                            created_by                 ,
                                            creation_date              ,
                                            last_update_login          ,
											billable_flag              )
                                   Values (  x_adls_rec.award_set_id ,
                                            x_adls_rec.adl_line_num,
                                            x_adls_rec.funding_pattern_id,
                                            x_adls_rec.distribution_value ,
											x_adls_rec.raw_cost,
                                            x_adls_rec.document_type,
                                            x_adls_rec.project_id                 ,
                                            x_adls_rec.task_id                    ,
                                            x_adls_rec.award_id                   ,
                                            --x_adls_rec.expenditure_type           ,
                                            x_adls_rec.expenditure_item_id        ,
                                            x_adls_rec.cdl_line_num               ,
                                            x_adls_rec.ind_compiled_set_id        ,
                                            x_adls_rec.gl_date                    ,
                                            x_adls_rec.request_id                 ,
                                            x_adls_rec.line_num_reversed          ,
                                            x_adls_rec.resource_list_member_id    ,
                                            --x_adls_rec.output_vat_tax_id          , --Etax Changes
					    x_adls_rec.output_tax_classification_code,
                                            x_adls_rec.output_tax_exempt_flag     ,
                                            x_adls_rec.output_tax_exempt_reason_code  ,
                                            x_adls_rec.output_tax_exempt_number   ,
                                            x_adls_rec.adl_status                 ,
                                            nvl(x_adls_rec.fc_status,'N')         ,
                                            x_adls_rec.line_type                  ,
                                            NVL(x_adls_rec.capitalized_flag,'N')  ,
                                            x_adls_rec.capitalizable_flag     	,
                                            x_adls_rec.reversed_flag              ,
                                            NVL(x_adls_rec.revenue_distributed_flag,'N') ,
                                            NVL(x_adls_rec.billed_flag,'N')       ,
                                            x_adls_rec.bill_hold_flag             ,
                                            x_adls_rec.distribution_id            ,
                                            x_adls_rec.po_distribution_id         ,
                                            x_adls_rec.invoice_distribution_id    ,
                                            x_adls_rec.parent_award_set_id        ,
                                            x_adls_rec.invoice_id                 ,
                                            x_adls_rec.parent_adl_line_num         ,
                                            x_adls_rec.distribution_line_number   ,
                                            x_adls_rec.burdenable_raw_cost        ,
                                            NVL(x_adls_rec.cost_distributed_flag,'N') ,
                                            x_adls_rec.last_update_date           ,
                                            x_adls_rec.last_updated_by             ,
                                            x_adls_rec.created_by                 ,
                                            x_adls_rec.creation_date              ,
                                            x_adls_rec.last_update_login          ,
											NVL(x_adls_rec.billable_flag, 'Y')    ) ;
   EXCEPTION
		WHEN OTHERS THEN
		    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG :CREATE ADLS',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
			RAISE ;
   END create_adls ;
   -- ================= END OF create_adls ================================


   PROCEDURE update_adls( p_adls_rec	gms_award_distributions%ROWTYPE )  IS
	 x_adls_rec	 gms_award_distributions%ROWTYPE	;
     g_rec_index number ;
	 p_err_code				NUMBER ;
	 p_err_buf				varchar2(2000) ;
   BEGIN
         g_rec_index := 1 ;
	 x_adls_rec	:= p_adls_rec ;

	 IF x_adls_rec.last_update_date is NULL then
		x_adls_rec.last_update_date			:= sysdate ;
	 END IF ;
	 IF x_adls_rec.last_updated_by is NULL THEN
		x_adls_rec.last_updated_by			:= fnd_global.user_id ;
	 END IF ;
	 IF x_adls_rec.created_by is NULL THEN
		x_adls_rec.created_by				:= fnd_global.user_id ;
	 END IF ;
	 IF x_adls_rec.creation_date is NULL THEN
		x_adls_rec.creation_date			:= SYSDATE ;
	 END IF ;

	 UPDATE gms_award_distributions
     SET    funding_pattern_id          =   x_adls_rec.funding_pattern_id,
            distribution_value          =   x_adls_rec.distribution_value,
            document_type               =   x_adls_rec.document_type,
            project_id                  =   x_adls_rec.project_id,
            task_id                     =   x_adls_rec.task_id,
            award_id                    =   x_adls_rec.award_id    ,
            --expenditure_type            =   x_adls_rec.expenditure_type    ,
            expenditure_item_id         =   x_adls_rec.expenditure_item_id    ,
            cdl_line_num                =   x_adls_rec.cdl_line_num    ,
            ind_compiled_set_id         =   x_adls_rec.ind_compiled_set_id    ,
            gl_date                     =   x_adls_rec.gl_date    ,
            request_id                  =   x_adls_rec.request_id    ,
            line_num_reversed           =   x_adls_rec.line_num_reversed   ,
            resource_list_member_id     = x_adls_rec.resource_list_member_id  ,
            --output_vat_tax_id           =   x_adls_rec.output_vat_tax_id    ,
	    output_tax_classification_code = x_adls_rec.output_tax_classification_code,
            output_tax_exempt_flag      = x_adls_rec.output_tax_exempt_flag   ,
            output_tax_exempt_reason_code  = x_adls_rec.output_tax_exempt_reason_code,
            output_tax_exempt_number    =  x_adls_rec.output_tax_exempt_number  ,
            adl_status                  =  x_adls_rec.adl_status  ,
            fc_status                   = x_adls_rec.fc_status  ,
            line_type                   = x_adls_rec.line_type ,
            capitalized_flag            = x_adls_rec.capitalized_flag ,
            capitalizable_flag          = x_adls_rec.capitalizable_flag ,
            reversed_flag               = x_adls_rec.reversed_flag,
            revenue_distributed_flag    = x_adls_rec.revenue_distributed_flag,
            billed_flag                 = x_adls_rec.billed_flag,
            bill_hold_flag              = x_adls_rec.bill_hold_flag,
            distribution_id             = x_adls_rec.distribution_id,
            po_distribution_id          = x_adls_rec.po_distribution_id,
            invoice_distribution_id     = x_adls_rec.invoice_distribution_id,
            parent_award_set_id         = x_adls_rec.parent_award_set_id,
            invoice_id                  = x_adls_rec.invoice_id,
            parent_adl_line_num          = x_adls_rec.parent_adl_line_num,
            distribution_line_number    = x_adls_rec.distribution_line_number,
            burdenable_raw_cost         = x_adls_rec.burdenable_raw_cost,
            cost_distributed_flag       = x_adls_rec.cost_distributed_flag,
            last_update_date            = x_adls_rec.last_update_date,
            last_updated_by              = x_adls_rec.last_updated_by,
            created_by                  = x_adls_rec.created_by,
            creation_date               = x_adls_rec.creation_date,
            last_update_login           = x_adls_rec.last_update_login,
			billable_flag				= X_adls_rec.billable_flag
      WHERE award_set_id = x_adls_rec.award_set_id and
            adl_line_num  = x_adls_rec.adl_line_num ;
   EXCEPTION
		WHEN OTHERS THEN
		    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG :UPDATE ADLS',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
			RAISE ;
   END update_adls ;
   -- ================ END OF update_adls ====================

   -- ----------------------------------------------------------------
   -- DELETE_ADLS
   -- The following function allows to delete ADLS.
   -- -----------------------------------------------------------------
   PROCEDURE delete_adls( p_distribution_set_id	NUMBER ) is
	 p_err_code				NUMBER ;
	 p_err_buf				varchar2(2000) ;
   BEGIN
--		DELETE gms_award_distributions
--		WHERE  distribution_set_id = p_distribution_set_id ;
    NULL ;
   EXCEPTION
		WHEN OTHERS THEN
		    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG :DELETE ADLS',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
			RAISE ;
   END delete_adls ;
   -- ================ END OF delete_adls ====================

   -- ---------------------------------------------------------------------
   -- API to delete gms_award_distribution record.
   -- 3733123 - PJ.M:B5: QA:P11:OTH: MANUAL ENC/EXP  FORM CREATING ORPHAN ADLS
   -- ---------------------------------------------------------------------
   PROCEDURE delete_adls( p_doc_header_id       IN NUMBER,
                          p_doc_distribution_id IN NUMBER,
                          p_doc_type            IN VARCHAR2 ) is
   BEGIN

      IF p_doc_header_id is NULL and
         p_doc_distribution_id is NULL THEN

	 return ;
      END IF ;

      IF p_doc_type = 'EXP' THEN
         IF p_doc_distribution_id is NOT NULL THEN

	    -- =====
	    -- Delete award distribution line for a given expenditure item.
	    -- =====
	    delete from gms_award_distributions adls
	     where document_type = 'EXP'
	       and expenditure_item_id in ( select expenditure_item_id
	                                      from pa_expenditure_items_all ei
					     where expenditure_item_id = p_doc_distribution_id )  ;
	 ELSE

	    -- =====
	    -- Delete award distribution line for a given expenditure.
	    -- =====
	    delete from gms_award_distributions adls
	     where document_type = 'EXP'
	       and expenditure_item_id in ( select expenditure_item_id
	                                      from pa_expenditure_items_all ei
					     where expenditure_id = p_doc_header_id )  ;
	 END IF ;

      ELSIF p_doc_type = 'ENC' THEN

         IF p_doc_distribution_id is NOT NULL THEN
	    -- =====
	    -- Delete award distribution line for a given encumbrance item.
	    -- =====
	    delete from gms_award_distributions adls
	     where document_type = 'ENC'
	       and expenditure_item_id in ( select encumbrance_item_id
	                                      from gms_encumbrance_items_all ei
					     where encumbrance_item_id = p_doc_distribution_id )  ;
	 ELSE
	    -- =====
	    -- Delete award distribution line for a given encumbrance.
	    -- =====
	    delete from gms_award_distributions adls
	     where document_type = 'ENC'
	       and expenditure_item_id in ( select encumbrance_item_id
	                                      from gms_encumbrance_items_all ei
					     where encumbrance_id = p_doc_header_id )  ;

	 END IF ;
      END IF ;
   END delete_adls ;
   --
   -- 3733123 - PJ.M:B5: QA:P11:OTH: MANUAL ENC/EXP  FORM CREATING ORPHAN ADLS
   -- End of code change.
   -- ---------------------------------------------------------------------
   PROCEDURE clean_dangling_adls is
	 p_err_code				NUMBER ;
	 p_err_buf				varchar2(2000) ;
   BEGIN
		NULL ;

   EXCEPTION
		WHEN OTHERS THEN
		    GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
									x_token_name1	=>	'PROGRAM_NAME', x_token_val1	=> 'GMS_AWARDS_DIST_PKG : clean_dangling_adls',
									x_token_name2   =>  'OERRNO',		x_token_val2    => SQLCODE,
									x_token_name3	=>  'OERRM',		x_token_val3	=> SQLERRM ,
									x_err_code		=>  p_err_code, 	x_err_buff		=> p_err_buf
								  ) ;
			RAISE ;

   END clean_dangling_adls ;

   -- ------------------------------------------------------------------------------
   -- Supplier Invoice Interface logic of creating ADLS.
   -- LD PA Interface  logic of creating ADLS.
   -- InsSi_items - Creates ADLS for the new expenditure items
   --               created for PA  Interface from payables/LD.
   --               This is called from PA_TRX_IMPORT.NEWexpend.
   -- ------------------------------------------------------------------------------
 /***************************************************************
 * This call is removed because it is called now from GMS_PA_API
 *	gmspax1b.pls
 ****************************************************************
  PROCEDURE  InsSI_Items( X_user              IN NUMBER
                     , X_login             IN NUMBER
                     , X_module            IN VARCHAR2
                     , X_calling_process   IN VARCHAR2
                     , Rows                IN BINARY_INTEGER
                     , X_status            IN OUT NOCOPY NUMBER )
  IS
  END InsSI_Items ;
***************************************************/
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
     	PROCEDURE update_billable_flag  (p_expenditure_item_id in number)
 	IS
	BEGIN
        -- Commenting below code, Bug 1756179
		/* Update	pa_expenditure_items_all
		set	billable_flag = 'Y'
		where	expenditure_item_id = p_expenditure_item_id
		and	nvl(billable_flag ,'N') = 'N';  */
            NULL; -- Added bug 1756179
  	EXCEPTION
  	WHEN OTHERS THEN
     		RAISE;
	END update_billable_flag  ;

   -- --------------------------------------------------------------

   -- Start of comments
    -- -----------------
    -- API Name         : check_award_funding
    -- Type             : private
    -- Pre Reqs         : None
    --
    -- Function         : check award funding identifies the award funding the project.
    -- Calling API      : verify_create_adl
    -- End of comments
    -- ----------------

    PROCEDURE check_award_funding ( p_project_id IN NUMBER,
				        p_award_id   IN OUT NOCOPY NUMBER,
			            p_status out NOCOPY NUMBER ) IS

    l_award_id  NUMBER ;
    l_status    NUMBER ;

    -- =====================================================
    -- Cursor : c_validate_award
    -- Cursor verifies that award is funded by the
    -- project.
    -- =====================================================
    CURSOR C_validate_award IS
           SELECT ins.award_id
             FROM gms_installments ins,
                  gms_summary_project_fundings pf
            WHERE ins.installment_id = pf.installment_id
	      AND pf.project_id      = p_project_id
	      AND ins.award_id       = p_award_id ;

    -- =====================================================
    -- Cursor : c_get_award
    -- Cursor finds out if there is a award funding the
    -- project charged to a transaction.
    -- =====================================================
    CURSOR c_get_award IS
           SELECT ins.award_id
             FROM gms_installments ins,
                  gms_summary_project_fundings pf
            WHERE ins.installment_id = pf.installment_id
	      AND pf.project_id      = p_project_id
	      AND NOT EXISTS ( SELECT 1
				 FROM gms_installments ins2,
				      gms_summary_project_fundings pf2
				WHERE ins2.installment_id = pf2.installment_id
				  AND pf2.project_id      = pf.project_id
				  AND ins2.award_id      <> ins.award_id ) ;
BEGIN
    l_award_id := p_award_id ;
    l_status   := 0 ;

    -- =================================
    -- Validate award.
    -- =================================
    IF p_award_id is not NULL THEN
       OPEN c_validate_award ;
       FETCH c_validate_award into l_award_id ;
       CLOSE c_validate_award ;
    END IF ;

    -- There is no valid award yet.
    -- checking to see if there

    IF l_award_id is NULL THEN
       OPEN c_get_award ;
       FETCH c_get_award into l_award_id ;
       CLOSE c_get_award ;
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
    -- Function         : This is used to create award distribution lines
    --                    using the bulk processing.
    -- Logic            : Identify the newly created PO/REQ/REL distribution
    --                    lines and create award distribution lines for
    --                    sponsored project.
    -- Parameters       :
    -- IN               : p_header_id   IN     NUMBER
    --                                  The PO/REQ/REL id created and that may
    --                                  have distributions associated with
    --                                  an award.
    --                  : p_doc_type   IN  varchar2
    --                       It should be PO/REQ/REL.
    --
    --                  : p_doc_num   IN  varchar2
    --                      This will have  PO/REQ/REL Number.
    --
    -- Calling place       : POST-FORMS-COMMIT event in PO/REQ/REL
    --
    -- End of comments
    -- ----------------

PROCEDURE VERIFY_CREATE_ADLS( p_header_id IN NUMBER ,
                              p_doc_type  IN VARCHAR2,
                              p_doc_num   IN VARCHAR2
                              ) IS


type gms_po_req_type_number is table of number index by binary_integer;
type gms_po_req_type_date   is table of date   index by binary_integer;

l_distribution_num		gms_po_req_type_number;
l_distribution_id		gms_po_req_type_number;
l_project_id                    gms_po_req_type_number;
l_task_id                       gms_po_req_type_number;
l_award_id                      gms_po_req_type_number;
l_new_award_set_id              gms_po_req_type_number;
l_last_update_date              gms_po_req_type_date;
l_creation_date                 gms_po_req_type_date;
l_last_updated_by               gms_po_req_type_number;
l_created_by                    gms_po_req_type_number;
l_last_update_login             gms_po_req_type_number;
l_dummy_tab                     gms_po_req_type_number;

l_award_set_id                  gms_po_req_type_number ;
l_award_set_idX                 NUMBER ;
l_count                         NUMBER ;
l_project_idX                   NUMBER ;
l_award_idX                     NUMBER ;
l_status                        NUMBER ;
AWARD_NOT_FOUND                 EXCEPTION ;

CURSOR c_adl IS
       SELECT *
         FROM gms_award_distributions
        WHERE award_set_id = l_award_set_idX
          AND adl_line_num = 1 ;
l_adl_rec c_adl%ROWTYPE ;


PROCEDURE VERIFY_REQUISITIONS IS

CURSOR c_req IS
	  SELECT rl.requisition_header_id 	    header_id,
		 rd.distribution_num    	    distribution_num,
		 rd.distribution_id		    distribution_id,
		 rd.project_id			    project_id,
		 rd.task_id			    task_id,
                 rd.award_id                        award_set_id,
		 rd.last_update_date		    last_update_date,
		 rd.creation_date		    creation_date,
		 rd.last_updated_by		    last_updated_by,
		 rd.created_by			    created_by,
		 nvl(rd.last_update_login,0)	    last_update_login
	    FROM  po_req_distributions_all  	rd,
	          po_requisition_lines_all      rl,
                  pa_projects_all               pp,
                  gms_project_types             gpt
      	   WHERE  rl.requisition_header_id = p_header_id
	     AND  rd.requisition_line_id   = rl.requisition_line_id
	     AND  rd.project_id            = pp.project_id
	     AND  pp.project_type          = gpt.project_type
             AND  gpt.sponsored_flag       = 'Y'
	     --
	     -- BUG : 3603758
	     -- Award Distribution is failing in PO and Req.
	     -- We need to skip records associated with the dummy award fo adls
	     -- creation.
             AND  NVL(rd.award_id,0)       >= 0 ;


BEGIN

    l_count    :=0;
    -- Activate ADLS that belongs to the REQ distribution line

    l_dummy_tab.DELETE ;
    --
    -- BUG : 4953765
    --     : R12.PJ:XB2:DEV:GMS:APPSPERF: PERFORMANCE ISSUE IN GMSADLSB.PLS 1 SQL
    --     : Update statements were changed to bulk updates.
    --

    SELECT adl2.award_set_id
      bulk collect into l_dummy_tab
      FROM  po_req_distributions_all  	rd,
	    po_requisition_lines_all    rl,
	    gms_award_distributions     adl2
     WHERE  rl.requisition_header_id = p_header_id
       AND  rd.requisition_line_id   = rl.requisition_line_id
       AND  adl2.distribution_id     = rd.distribution_id
       AND  adl2.document_type       = 'REQ'
       AND  adl2.award_set_id	     = rd.award_id
       AND  adl2.adl_status	     = 'I'  ;


    IF l_dummy_tab.count > 0 THEN

      FORALL i in l_dummy_tab.FIRST..l_dummy_tab.LAST

       UPDATE gms_award_distributions
	  set adl_status = 'A'
        where award_set_id = l_dummy_tab(i) ;

    END IF ;

    l_dummy_tab.DELETE ;

    -- Inactivate ADLS that belongs to the REQ distribution line but
    -- not tied up with award_id in distribution line.
    -- Inactivate dangling active adls.
    -- ----
    --
    -- BUG : 4953765
    --     : R12.PJ:XB2:DEV:GMS:APPSPERF: PERFORMANCE ISSUE IN GMSADLSB.PLS 1 SQL
    --     : Update statements were changed to bulk updates.
    --
    SELECT adl2.award_set_id
      bulk collect into l_dummy_tab
      FROM  po_req_distributions_all  	rd,
	    po_requisition_lines_all    rl,
	    gms_award_distributions     adl2
     WHERE  rl.requisition_header_id = p_header_id
       AND  rd.requisition_line_id   = rl.requisition_line_id
       AND  adl2.distribution_id     = rd.distribution_id
       AND  adl2.document_type       = 'REQ'
       AND  adl2.award_set_id	     <> rd.award_id
       AND  adl2.adl_status	     = 'A'  ;


    IF l_dummy_tab.count > 0 THEN

      FORALL i in l_dummy_tab.FIRST..l_dummy_tab.LAST

       UPDATE gms_award_distributions
	  set adl_status = 'I'
        where award_set_id = l_dummy_tab(i) ;

    END IF ;

    l_dummy_tab.DELETE ;

     -- ==================================================
     -- Update award_id to NULL for non sponsored
     -- projects.
     -- =================================================
    --
    -- BUG : 4953765
    --     : R12.PJ:XB2:DEV:GMS:APPSPERF: PERFORMANCE ISSUE IN GMSADLSB.PLS 1 SQL
    --     : Update statements were changed to bulk updates.
    --

     SELECT  rd2.distribution_id
       bulk collect into l_dummy_tab
       FROM  po_req_distributions_all  	rd2,
             po_requisition_lines_all      rl,
	     pa_projects_all               pp,
             gms_project_types             gpt
      WHERE  rl.requisition_header_id = p_header_id
        AND  rd2.requisition_line_id  = rl.requisition_line_id
        AND  rd2.project_id           = pp.project_id
	and  rd2.award_id             is NOT NULL
        AND  pp.project_type          = gpt.project_type
        AND  gpt.sponsored_flag       = 'N' ;

    IF l_dummy_tab.count > 0 THEN

      FORALL i in l_dummy_tab.FIRST..l_dummy_tab.LAST
             UPDATE po_req_distributions_all rd
                SET award_id = NULL
              WHERE rd.distribution_id = l_dummy_tab(i) ;

    END IF ;

    l_dummy_tab.DELETE ;

    l_count :=0;

    FOR req_rec in c_req LOOP

	l_award_set_idX := NVL(req_rec.award_set_id,0) ;
      	l_adl_rec := NULL ;

	OPEN c_adl ;
	FETCH c_adl into l_adl_rec ;
	CLOSE c_adl ;

	IF NOT (( NVL(l_adl_rec.adl_status,'I')  = 'A' ) AND
                ( NVL(l_adl_rec.document_type,'X') = 'REQ' ) AND
                ( NVL(l_adl_rec.distribution_id,0)  = NVL( req_rec.distribution_id,0) )) THEN

                l_count := l_count + 1 ;
                l_distribution_id(l_count)          := req_rec.distribution_id;
		l_distribution_num(l_count)	    := req_rec.distribution_num;
                l_project_id(l_count)               := req_rec.project_id;
                l_task_id(l_count)                  := req_rec.task_id;
		l_project_idX                       := req_rec.project_id;
		l_award_idX                         := l_adl_rec.award_id ;

		check_award_funding( l_project_idX, l_award_idX, l_status ) ;

		IF l_status = -1 THEN
		   raise AWARD_NOT_FOUND ;
                ELSE
		   l_award_id(l_count) := l_award_idX ;
		END IF ;


                l_last_update_date(l_count)         := req_rec.last_update_date;
                l_creation_date(l_count)            := req_rec.creation_date;
                l_last_updated_by(l_count)          := req_rec.last_updated_by;
                l_created_by(l_count)               := NVL(req_rec.created_by,0);
                l_last_update_login(l_count)        := req_rec.last_update_login;
		l_new_award_set_id(l_count)         := gms_awards_dist_pkg.get_award_set_id ;

	END IF ;

    END LOOP ;

     -- Start of comments
     -- Check if need to proceed.
     -- End of comment.

     IF l_distribution_id.count = 0 then
        return ;
     END IF ;


     -- Start of comment.
     -- Loop through all the collection and insert into the ADL table.
     -- Update the ap inv dist record with the newly created ADLs award set id.
     -- End of comment


      FORALL i in l_distribution_id.FIRST..l_distribution_id.LAST
      INSERT INTO gms_award_distributions ( award_set_id              ,
                                            adl_line_num              ,
                                            document_type             ,
                                            distribution_value        ,
                                            project_id                 ,
                                            task_id                    ,
                                            award_id                   ,
                                            adl_status                 ,
                                            fc_status                  ,
                                            line_type                  ,
                                            capitalized_flag           ,
                                            revenue_distributed_flag   ,
                                            billed_flag                ,
                                            distribution_id            ,
                                            burdenable_raw_cost        ,
                                            cost_distributed_flag      ,
                                            last_update_date           ,
                                            last_updated_by            ,
                                            created_by                 ,
                                            creation_date              ,
                                            last_update_login          ,
                    			    billable_flag              )
                                    VALUES ( l_new_award_set_id(i)     ,
                                              1, --adl_line_num        ,
                                            'REQ' , --document_type    ,
                                            100                        ,
                                            l_project_id(i)             ,
                                            l_task_id(i)                ,
                                            l_award_id(i)               ,
                                            'A', --adl_status           ,
                                            'N', --fc_status            ,
                                            'R', --line_type           ,
                                            'N'           ,
                                            'N'         ,
                                            'N'             ,
                                            l_distribution_id(i),
                                            NULL, --burdenable_raw_cost        ,
                                            'N'      ,
                                            l_last_update_date(i)           ,
                                            l_last_updated_by(i)             ,
                                            l_created_by(i)                 ,
                                            l_creation_date(i)              ,
                                            l_last_update_login(i)          ,
			         	    'Y') ;

      -- Start of comment.
      -- Update REQ distribution with the award set id.
      -- End of comment.

      FORALL k in  l_distribution_id.FIRST..l_distribution_id.LAST
       	    UPDATE po_req_distributions_all
               SET award_id = l_new_award_set_id(k)
             WHERE distribution_id 	= l_distribution_id(k);



END VERIFY_REQUISITIONS;


PROCEDURE VERIFY_PO IS
CURSOR c_po is
            SELECT pod.po_header_id                   header_id,
                 pod.distribution_num                 distribution_num,
                 pod.po_distribution_id               distribution_id,
                 pod.project_id                       project_id,
                 pod.task_id                          task_id,
                 pod.award_id                         award_set_id,
                 pod.last_update_date                 last_update_date,
                 pod.creation_date                    creation_date,
                 pod.last_updated_by                  last_updated_by,
                 pod.created_by                       created_by,
                 nvl(pod.last_update_login,0)         last_update_login
            FROM po_distributions_all   pod,
                 pa_projects_all        p,
                 gms_project_types      gpt
           WHERE pod.po_header_id        = p_header_id
             AND pod.project_id          = p.project_id
             AND p.project_type          = gpt.project_type
             AND gpt.sponsored_flag      = 'Y'
	     --
	     -- BUG : 3603758
	     -- Award Distribution is failing in PO and Req.
	     -- We need to skip records associated with the dummy award fo adls
	     -- creation.
	     AND NVL(pod.award_id,0)     >= 0 ;
BEGIN
       -- Activate ADLS that belongs to the po distribution line but
    UPDATE gms_award_distributions  adl
	   set adl.adl_status = 'A'
     WHERE adl.document_type = 'PO'
       AND adl.adl_status    = 'I'
       AND adl.award_set_id in (   SELECT adl2.award_set_id
				     FROM gms_award_distributions adl2,
				          po_distributions_all pod
				    WHERE pod.po_header_Id           = p_header_id
				      AND pod.award_id               is not null
				      AND adl2.award_set_id          = pod.award_id
				      AND adl2.po_distribution_id    =pod.po_distribution_id
				      AND adl2.document_type	     = 'PO'
				      AND adl2.adl_status            = 'I'  ) ;

    -- Inactivate ADLS that belongs to the po distribution line but
    -- not tied up with award_id in distribution line.
    -- Inactivate dangling active adls.
    -- ----
    UPDATE gms_award_distributions  adl
	   set adl.adl_status = 'I'
     WHERE adl.document_type = 'PO'
       AND adl.adl_status    = 'A'
       AND adl.award_set_id in (SELECT adl2.award_set_id
				     FROM gms_award_distributions adl2,
				          po_distributions_all pod
				    WHERE pod.po_header_id        = p_header_id
				      AND pod.award_id 		  is not null
				      AND adl2.award_set_id      <> pod.award_id
				      AND adl2.po_distribution_id =pod.po_distribution_id
				      AND adl2.document_type	  = 'PO'
				      AND adl2.adl_status	  = 'A'  ) ;


     -- ==================================================
     -- Update award_id to NULL for non sponsored
     -- projects.
     -- =================================================
     UPDATE po_distributions_all pod
        SET award_id = NULL
      WHERE pod.po_header_id = p_header_id
        AND pod.award_id is not NULL
        AND pod.po_distribution_id in ( SELECT pod2.po_distribution_id
						 FROM po_distributions_all  	pod2,
                 				      pa_projects_all           p,
                 				      gms_project_types         gpt
						WHERE pod2.po_header_id     = p_header_id
						  AND pod2.project_id       = p.project_id
						  AND p.project_type        = gpt.project_type
						  AND gpt.sponsored_flag    = 'N'  ) ;

    l_count :=0;
    FOR po_rec in c_po LOOP

	l_award_set_idX := NVL(po_rec.award_set_id,0) ;
      	l_adl_rec := NULL ;

	OPEN c_adl ;
	FETCH c_adl into l_adl_rec ;
	CLOSE c_adl ;

	IF NOT (( NVL(l_adl_rec.adl_status,'I')  = 'A' ) and
               ( NVL(l_adl_rec.document_type,'X') = 'PO' ) and
               ( NVL(l_adl_rec.po_distribution_id,0)  = NVL( po_rec.distribution_id,0) )) THEN

                l_count := l_count + 1 ;
                l_distribution_id(l_count)          := po_rec.distribution_id;
		l_distribution_num(l_count)	    := po_rec.distribution_num;
                l_project_id(l_count)               := po_rec.project_id;
                l_task_id(l_count)                  := po_rec.task_id;
		l_project_idX                       := po_rec.project_id;
		l_award_idX                         := l_adl_rec.award_id ;

		check_award_funding( l_project_idX, l_award_idX, l_status ) ;

		IF l_status = -1 THEN
		   raise AWARD_NOT_FOUND ;
                ELSE
		   l_award_id(l_count) := l_award_idX ;
		END IF ;

                l_last_update_date(l_count)         := po_rec.last_update_date;
                l_creation_date(l_count)            := po_rec.creation_date;
                l_last_updated_by(l_count)          := po_rec.last_updated_by;
                l_created_by(l_count)               := NVL(po_rec.created_by,0);
                l_last_update_login(l_count)        := po_rec.last_update_login;
		l_new_award_set_id(l_count)         := gms_awards_dist_pkg.get_award_set_id ;

	END IF ;

    END LOOP ;



     -- Start of comments
     -- Check if need to proceed.
     -- End of comment.

     IF l_distribution_id.count = 0 then
        return ;
     END IF ;

     -- Start of comment.
     -- Loop through all the collection and insert into the ADL table.
     -- Update the ap inv dist record with the newly created ADLs award set id.
     -- End of comment


      FORALL i in l_distribution_id.FIRST..l_distribution_id.LAST
      INSERT INTO gms_award_distributions ( award_set_id ,
                                            adl_line_num,
                                            document_type,
                                            distribution_value,
                                            project_id                 ,
                                            task_id                    ,
                                            award_id                   ,
                                            adl_status                 ,
                                            fc_status                  ,
                                            line_type                  ,
                                            capitalized_flag           ,
                                            revenue_distributed_flag   ,
                                            billed_flag                ,
                                            po_distribution_id    ,
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
                                            'PO' , --document_type,
                                            100,
                                            l_project_id(i)      ,
                                            l_task_id(i)                    ,
                                            l_award_id(i)                   ,
                                            'A', --adl_status                 ,
                                            'N', --fc_status                  ,
                                            'R', --line_type                  ,
                                            'N'           ,
                                            'N'         ,
                                            'N'             ,
                                            l_distribution_id(i),
                                            NULL, --burdenable_raw_cost        ,
                                            'N'      ,
                                            l_last_update_date(i)           ,
                                            l_last_updated_by(i)             ,
                                            l_created_by(i)                 ,
                                            l_creation_date(i)              ,
                                            l_last_update_login(i)          ,
			         	    'Y') ;

      -- Start of comment.
      -- Update po distribution with the award set id.
      -- End of comment.

      FORALL k in  l_distribution_id.FIRST..l_distribution_id.LAST
       	    UPDATE po_distributions_all
               SET award_id = l_new_award_set_id(k)
             WHERE po_header_id 	= p_header_id
               AND po_distribution_id   = l_distribution_id(k)  ;


END VERIFY_PO;
BEGIN

 -- Start of comment
 -- Verify that grants is enabled.
 -- End of comments.
 --
 IF NOT gms_install.enabled THEN
    return ;
 END IF ;

 IF p_doc_type ='REQ' THEN
      VERIFY_REQUISITIONS;
 ELSIF  p_doc_type IN ('PO','REL')  THEN
      VERIFY_PO;
 END IF;
EXCEPTION
    WHEN AWARD_NOT_FOUND THEN


       --
       -- Message : Incorrect award is associated with the PO/REQ/REL : ??? and
       --	    distribution line number : ??????. Please change award information
       --	    on the distribution line.

     IF p_doc_type ='REQ' THEN
       fnd_message.set_name('GMS','GMS_INVALID_REQ_AWARD_FOUND');
       fnd_message.set_token('REQNUM',p_doc_num );
       fnd_message.set_token('DISTLNO', l_distribution_num(l_count));

     ELSIF  p_doc_type ='PO' THEN
       fnd_message.set_name('GMS','GMS_INVALID_PO_AWARD_FOUND');
       fnd_message.set_token('PONUM',p_doc_num );
       fnd_message.set_token('DISTLNO', l_distribution_num(l_count));

     ELSIF  p_doc_type ='REL' THEN
        fnd_message.set_name('GMS','GMS_INVALID_REL_AWARD_FOUND');
        fnd_message.set_token('RELNUM',p_doc_num );
        fnd_message.set_token('DISTLNO', l_distribution_num(l_count));
     END IF;
     app_exception.raise_exception;
    WHEN OTHERS THEN
       fnd_message.set_name('GMS','GMS_UNEXPECTED_ERROR');
       fnd_message.set_token('PROGRAM_NAME','gms_awards_dist_pkg.verify_create_adls');
       fnd_message.set_token('OERRNO',to_char(sqlcode));
       fnd_message.set_token('OERRM',sqlerrm);
       app_exception.raise_exception;
END VERIFY_CREATE_ADLS;

    -- Start of comments
    -- -----------------
    -- API Name         : copy_exp_adls
    -- Bug              : 3684711
    -- Type             : Private
    -- Pre Reqs         : None
    -- Function         : This is used to create award distribution lines for a reversed expenditure item.
    -- Logic            : Copy the award distribution from the original expenditure item.
    --                    This is required to support entry of automatically reversal exp item.
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
			      , X_status            OUT nocopy NUMBER ) is
    l_err_code				NUMBER ;
    l_err_buf				varchar2(2000) ;
    BEGIN
         INSERT INTO gms_award_distributions
	     (  award_set_id ,
	        adl_line_num,
	        funding_pattern_id,
	        distribution_value ,
	  	raw_cost,
	        document_type,
	        project_id                 ,
	        task_id                    ,
	        award_id                   ,
	        expenditure_item_id        ,
	        cdl_line_num               ,
	        ind_compiled_set_id        ,
	        gl_date                    ,
	        request_id                 ,
	        line_num_reversed          ,
	        resource_list_member_id    ,
	        --output_vat_tax_id          , --ETax Changes
		output_tax_classification_code,
	        output_tax_exempt_flag     ,
	        output_tax_exempt_reason_code  ,
	        output_tax_exempt_number   ,
	        adl_status                 ,
	        fc_status                  ,
	        line_type                  ,
	        capitalized_flag           ,
	        capitalizable_flag         ,
	        reversed_flag              ,
	        revenue_distributed_flag   ,
	        billed_flag                ,
	        bill_hold_flag             ,
	        distribution_id            ,
	        po_distribution_id         ,
	        invoice_distribution_id    ,
	        parent_award_set_id        ,
	        invoice_id                 ,
	        parent_adl_line_num         ,
	        distribution_line_number   ,
	        burdenable_raw_cost        ,
	        cost_distributed_flag      ,
	        last_update_date           ,
	        last_updated_by             ,
	        created_by                 ,
	        creation_date              ,
	        last_update_login          ,
		billable_flag		)
	       select     get_award_set_id ,
	                  1,
	                  funding_pattern_id,
	                  distribution_value ,
	                  raw_cost* -1 ,
	                  'EXP',
	                  project_id                 ,
	                  task_id                    ,
	                  award_id                   ,
	                  p_backout_item_id,
	                  cdl_line_num,
	                  ind_compiled_set_id        ,--        ind_compiled_set_id
	                  NULL                    ,
	                  request_id                 ,
	                  NULL,
	                  resource_list_member_id    ,
	                  --output_vat_tax_id          ,--ETax Changes
			  output_tax_classification_code,
	                  output_tax_exempt_flag     ,
	                  output_tax_exempt_reason_code  ,
	                  output_tax_exempt_number   ,
	                  adl_status                 ,
	                  'N'                       , -- FC_STATUS
	                  line_type                  ,
	                  NVL(capitalized_flag,'N')  ,
	                  capitalizable_flag		,
	                  NULL,
	                  revenue_distributed_flag   ,
	                  billed_flag,
	                  bill_hold_flag,
	                  NULL, -- distribution_id            ,
	                  NULL, -- po_distribution_id            ,
	                  NULL, -- invoice_distribution_id            ,
	                  parent_award_set_id        ,
	                  NULL             ,
	                  parent_adl_line_num        ,
	                  NULL             ,
	                  null                       , --  burdenable_raw_cost,
	                  'N'                      ,  -- cost_distributed_flag      ,
	                  sysdate                    , -- SYSDATE
	                  p_user  , -- last_updated_by            ,
	                  P_user  , -- created_by                 ,
	                  sysdate  , -- creation_date              ,
	                  p_login			,
			  billable_flag
	           from   GMS_AWARD_DISTRIBUTIONS
	          where   expenditure_item_id = p_exp_item_id
	            and   document_type       = 'EXP'
	            and   adl_status          = 'A'
	            and   adl_line_num        = 1 ;
    EXCEPTION
     WHEN OTHERS THEN
        -- The following procedure call is added for Bug 4290147
        GMS_ERROR_PKG.gms_message( x_err_name => 'GMS_UNEXPECTED_ERROR',
                                                         x_token_name1 => 'PROGRAM_NAME', x_token_val1 => 'GMS_AWARDS_DIST_PKG :copy_exp_adls :Exp Item Id :'||p_backout_item_id,
                                                         x_token_name2 =>  'OERRNO',      x_token_val2        =>  SQLCODE,
                                                         x_token_name3 =>  'OERRM',       x_token_val3 =>  SQLERRM ,
                                                         x_err_code =>  l_err_code,               x_err_buff =>  l_err_buf  ) ;
         x_status := SQLCODE ;
    END copy_exp_adls ;

end GMS_AWARDS_DIST_PKG;  -- ================== END OF GMS_AWARDS_DIST_PKG ======================

/
