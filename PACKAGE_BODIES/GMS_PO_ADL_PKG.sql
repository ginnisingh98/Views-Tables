--------------------------------------------------------
--  DDL for Package Body GMS_PO_ADL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_PO_ADL_PKG" AS
/* $Header: gmspoxab.pls 120.0 2005/05/29 11:59:47 appldev noship $ */


/*  Declare procedure update_adls.
	REQ_LINE_ID	IN	NUMBER ;
	ERR_CODE	IN OUT NOCOPY	varchar2,
	ERR_MSG		IN OUT NOCOPY	varchar2
*/
PROCEDURE UPDATE_ADLS(	p_req_line_id	IN 	NUMBER,
		        err_code	IN OUT NOCOPY	VARCHAR2,
		        err_msg		IN OUT NOCOPY	VARCHAR2 ) is

		-------------------------------------------------------------------------------
                -- 3042946
		-- and rd_old.award_id IS NOT NULL was added.
		-- -------------------------------------------
		--CURSOR C_REQ_REC is
		--	SELECT rd_new.distribution_id		new_distribution_id,
		--		   rd_old.distribution_id	old_distribution_id,
		--		   rd_old.award_id		award_set_id
		--	  FROM po_requisition_lines		porl_new,
		--		   po_requisition_lines		porl_old,
		--		   po_req_distributions		rd_new,
		--		   po_req_distributions		rd_old
		--	 WHERE porl_new.requisition_line_id		= 	nvl(p_req_line_id, -1 )
		--	   AND porl_old.line_location_id		=   (-1) * porl_new.line_location_id
		--	   AND rd_old.requisition_line_id		= 	porl_old.requisition_line_id
		--	   AND rd_new.requisition_line_id		= 	porl_new.requisition_line_id
		--	   and rd_old.award_id                          IS NOT NULL
		--	   AND rd_new.source_req_distribution_id=   rd_old.distribution_id ;
		-------------------------------------------------------------------------------------
                -- 3042946
		-- and rd_old.award_id IS NOT NULL was added.
		-- -------------------------------------------
		/* Bug#2909181 : The following SQL two req distributions
		   for each of the newly created req line in the case of two requisition
                   lines autocreated to a same PO shipment, (partially received and then
                   cancelled) as the where clause will pick up both the old req lines for
                   each of the newly created req lines(because the join condition is based
                   on line location id, this will pick up both the old req line for each of
                   the new req lines).  Hence,instead on the line location join, will use
                   the following join between PORL_OLD AND PORL_NEW: PORL_NEW.PARENT_REQ_LINE_ID
		   = PORL_OLD.REQUISITION_LINE_ID */

		/* Bug 3315086: Modified the join condition to -1 * parent_req_line_id, as a fix
   		    for the conflict between bug fix 2909181 and req. split/modify */
		/************************************************************************
		CURSOR c_req_rec is
		select distinct rd_new.distribution_id	new_distribution_id,
		     	        rd_old.distribution_id	old_distribution_id,
		                rd_old.award_id		award_set_id
         	from  po_req_distributions_all rd_old,
		      po_req_distributions_all rd_new,
                      po_requisition_lines_all porl_old,
                      po_requisition_lines_all porl_new,
                      po_distributions 	       pod,
		      po_headers_all           blanket
          	where porl_new.requisition_line_id  = nvl(p_req_line_id, -1 )
          	and   rd_new.requisition_line_id    = porl_new.requisition_line_id
          	and   rd_new.award_id	            is null
          	and   porl_old.requisition_line_id  = (-1) * porl_new.parent_req_line_id
          	and   rd_old.requisition_line_id    = porl_old.requisition_line_id
          	and   rd_old.award_id		    is not null
          	and   pod.req_distribution_id       = rd_old.distribution_id
          	and   nvl(pod.quantity_cancelled,0) > 0
          	and   porl_new.blanket_po_header_id = blanket.po_header_id(+) ;
		**********************************************************************/
		CURSOR c_req_rec is
		select distinct rd_new.distribution_id	new_distribution_id,
		     	        rd_old.distribution_id	old_distribution_id,
		                rd_old.award_id		award_set_id
         	from  po_req_distributions_all rd_old,
		      po_req_distributions_all rd_new,
                      po_requisition_lines_all porl_new
          	where porl_new.requisition_line_id  = nvl(p_req_line_id, -1 )
          	and   rd_new.requisition_line_id    = porl_new.requisition_line_id
          	and   rd_new.award_id	            is null
          	and   rd_old.award_id		    is not null
	        and   rd_new.source_req_distribution_id=   rd_old.distribution_id
                and   rd_old.award_id is not NULL ;

		x_award_set_id		NUMBER ;

BEGIN

	-- --------------------------------------
	-- Just a dummy package body.
	-- Created to be used by grants to implement
	-- award related details.
	-- ------------------------------------------
	FOR C_REC IN C_REQ_REC LOOP

		x_award_set_id := gms_awards_dist_pkg.get_award_set_id ;

		insert into gms_award_distributions
					(        AWARD_SET_ID                    ,
						 ADL_LINE_NUM                    ,
						 FUNDING_PATTERN_ID              ,
						 DISTRIBUTION_VALUE              ,
						 RAW_COST                        ,
						 DOCUMENT_TYPE                   ,
						 PROJECT_ID                      ,
						 TASK_ID                         ,
						 AWARD_ID                        ,
						 EXPENDITURE_ITEM_ID             ,
						 CDL_LINE_NUM                    ,
						 IND_COMPILED_SET_ID             ,
						 GL_DATE                         ,
						 REQUEST_ID                      ,
						 LINE_NUM_REVERSED               ,
						 RESOURCE_LIST_MEMBER_ID         ,
						 OUTPUT_VAT_TAX_ID               ,
						 OUTPUT_TAX_EXEMPT_FLAG          ,
						 OUTPUT_TAX_EXEMPT_REASON_CODE   ,
						 OUTPUT_TAX_EXEMPT_NUMBER        ,
						 ADL_STATUS                      ,
						 FC_STATUS                       ,
						 LINE_TYPE                       ,
						 CAPITALIZED_FLAG                ,
						 CAPITALIZABLE_FLAG              ,
						 REVERSED_FLAG                   ,
						 REVENUE_DISTRIBUTED_FLAG        ,
						 BILLED_FLAG                     ,
						 BILL_HOLD_FLAG                  ,
						 DISTRIBUTION_ID                 ,
						 PO_DISTRIBUTION_ID              ,
						 INVOICE_DISTRIBUTION_ID         ,
						 PARENT_AWARD_SET_ID             ,
						 INVOICE_ID                      ,
						 PARENT_ADL_LINE_NUM             ,
						 DISTRIBUTION_LINE_NUMBER        ,
						 BURDENABLE_RAW_COST             ,
						 COST_DISTRIBUTED_FLAG           ,
						 LAST_UPDATE_DATE                ,
						 LAST_UPDATED_BY                 ,
						 CREATED_BY                      ,
						 CREATION_DATE                   ,
						 LAST_UPDATE_LOGIN               ,
						 BUD_TASK_ID                     )
		select 		                 X_AWARD_SET_ID                  ,
						 ADL_LINE_NUM                    ,
						 FUNDING_PATTERN_ID              ,
						 DISTRIBUTION_VALUE              ,
						 RAW_COST                        ,
						 DOCUMENT_TYPE                   ,
						 PROJECT_ID                      ,
						 TASK_ID                         ,
						 AWARD_ID                        ,
						 EXPENDITURE_ITEM_ID             ,
						 CDL_LINE_NUM                    ,
						 IND_COMPILED_SET_ID             ,
						 GL_DATE                         ,
						 REQUEST_ID                      ,
						 LINE_NUM_REVERSED               ,
						 RESOURCE_LIST_MEMBER_ID         ,
						 OUTPUT_VAT_TAX_ID               ,
						 OUTPUT_TAX_EXEMPT_FLAG          ,
						 OUTPUT_TAX_EXEMPT_REASON_CODE   ,
						 OUTPUT_TAX_EXEMPT_NUMBER        ,
						 ADL_STATUS                      ,
						 FC_STATUS                       ,
						 LINE_TYPE                       ,
						 CAPITALIZED_FLAG                ,
						 CAPITALIZABLE_FLAG              ,
						 REVERSED_FLAG                   ,
						 REVENUE_DISTRIBUTED_FLAG        ,
						 BILLED_FLAG                     ,
						 BILL_HOLD_FLAG                  ,
						 c_rec.new_distribution_id       ,
						 PO_DISTRIBUTION_ID              ,
						 INVOICE_DISTRIBUTION_ID         ,
						 PARENT_AWARD_SET_ID             ,
						 INVOICE_ID                      ,
						 PARENT_ADL_LINE_NUM             ,
						 DISTRIBUTION_LINE_NUMBER        ,
						 0             ,
						 COST_DISTRIBUTED_FLAG           ,
						 SYSDATE               		 ,
						 NVL(fnd_global.user_id,0)       ,
						 NVL(fnd_global.user_id,0)       ,
						 SYSDATE 	                 ,
						 LAST_UPDATE_LOGIN               ,
						 BUD_TASK_ID
		  from gms_award_distributions  adl
		 where adl.award_set_id 		= c_rec.award_set_id
		   and adl.adl_status			= 'A'
		   and adl.document_type		= 'REQ'
		   and adl.distribution_id		= c_rec.old_distribution_id
		   and NOT EXISTS ( select 'X'
					   from gms_award_distributions adl2
					  where adl2.distribution_id	= c_rec.new_distribution_id
					   and adl2.adl_status		= 'A'
					   and adl2.document_type	= 'REQ'
					) ;

		UPDATE po_req_distributions rd_new
		   SET award_id 		= x_award_set_id
		 WHERE distribution_id  = c_rec.new_distribution_id
		   AND award_id	IS NULL
		   and EXISTS    (      select 'X'
						  from gms_award_distributions adl2
						 where adl2.distribution_id	= c_rec.new_distribution_id
						   and adl2.adl_status		= 'A'
						   and award_set_id		=  x_award_set_id
						   and adl2.document_type	= 'REQ'
				     ) ;

		IF SQL%NOTFOUND THEN
			raise no_data_found ;
		END IF ;

	END LOOP ;

	err_code := 'S' ;
EXCEPTION
  WHEN OTHERS THEN
	err_code := 'F' ;
	err_msg := substr(SQLERRM,1,200) ;
END UPDATE_ADLS;

END gms_po_adl_pkg ;

/
