--------------------------------------------------------
--  DDL for Package Body GMS_POR_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_POR_API2" as
--$Header: gmspor2b.pls 120.0 2005/05/29 11:39:42 appldev noship $


        --=============================================================
        -- Bug-2557041
        -- The purpose of this API is to prepare for award distributions
        -- and kicks off award distribution engine
        --=============================================================
        PROCEDURE   distribute_award(p_doc_header_id               IN NUMBER,
                                     p_distribution_id             IN NUMBER,
                                     p_document_source             IN VARCHAR2,
                                     p_gl_encumbered_date          IN DATE,
                                     p_project_id                  IN NUMBER,
                                     p_task_id                     IN NUMBER,
                                     p_dummy_award_id              IN NUMBER,
                                     p_expenditure_type            IN VARCHAR2,
                                     p_expenditure_organization_id IN NUMBER,
                                     p_expenditure_item_date       IN DATE,
                                     p_quantity                    IN NUMBER,
                                     p_unit_price                  IN NUMBER,
                                     p_func_amount                 IN NUMBER,
                                     p_vendor_id                   IN NUMBER,
                                     p_source_type_code            IN VARCHAR2,
                                     p_award_qty_obj               OUT NOCOPY gms_obj_award2,
                                     p_status                      OUT NOCOPY VARCHAR2,
                                     p_error_msg_label             OUT NOCOPY VARCHAR2 )
         AS
         l_doc_header_id    NUMBER;
         l_distribution_id  NUMBER;
         l_document_source  VARCHAR2(4);
         l_index            INTEGER;
	 l_project_id       NUMBER ;

         l_award_qty_obj    gms_obj_award2;
         l_dist_status      VARCHAR2(5);
         l_status           VARCHAR2(1);
         l_msg_label        VARCHAR2(2000);
         l_recs_processed   NUMBER;
         l_recs_rejected    NUMBER;
         l_spon_flag        gms_project_types.sponsored_flag%TYPE ;
         l_source_type_code po_requisition_lines_all.source_type_code%type;

         cursor C_spon_project is
	        select pt.sponsored_flag
		  from pa_projects_all b,
		       gms_project_types pt
		 where b.project_id 	= l_project_id
		   and b.project_type	= pt.project_type
		   and pt.sponsored_flag = 'Y' ;
	 CURSOR c_next_header_id IS
              SELECT gms_packet_header_id_s.NEXTVAL
              FROM   DUAL;

	 CURSOR c_next_dist_id IS
                SELECT gms_packet_dist_id_s.NEXTVAL
                FROM   DUAL;

         CURSOR c_awd_dist_status IS
            SELECT awd.dist_status
            FROM   gms_distributions awd
            WHERE  awd.document_distribution_id  = l_distribution_id
            AND    awd.document_header_id        = l_doc_header_id
            AND    awd.document_type             = l_document_source
            AND    awd.dist_status               <>'FABA';
         BEGIN
          -- Initilaize the Object
         --l_award_qty_obj :=GMS_OBJ_AWARD2(GMS_TYPE_VARCHAR20(),GMS_TYPE_NUMBER(),
         --                                 GMS_TYPE_NUMBER(), GMS_TYPE_NUMBER());
         l_award_qty_obj :=GMS_OBJ_AWARD2.init_gms_obj_award2();

         l_doc_header_id	:=p_doc_header_id ;
	 l_distribution_id	:=p_distribution_id ;
         l_document_source	:=p_document_source ;
         l_status		:='S';
         p_status		:='S' ;
         l_source_type_code     := p_source_type_code;


         IF not gms_install.enabled then
		return ;
	 END IF ;

         IF NVL(p_dummy_award_id,0) >= 0 THEN
		p_status	:='S';
		Return ;
   	 END IF ;

         --==============================================================
         -- Do not proceed if grants is  enabled and Requisition type is
         -- Internal
         --==============================================================
         l_project_id   := p_project_id ;
	 open  C_spon_project ;
	 fetch C_spon_project into l_spon_flag ;
	 close C_spon_project ;


         --IF gms_por_api.is_sponsored_project (p_project_id) THEN
	 IF NVL(l_spon_flag, 'N') = 'Y' THEN
            IF  nvl(l_source_type_code,'INVENTORY') = 'INVENTORY' THEN
               p_error_msg_label := 'GMS_IP_INVALID_REQ_TYPE';
               p_status :=  'E';
               return;
            END IF;
         ELSE
	  -- 2. Nonsponsored project having award should fail.
               p_error_msg_label := 'GMS_AWARD_NOT_ALLOWED';
               p_status :=  'E';
               return;
         END IF;


        GMS_POR_API.validate_dist_award(P_project_id,
         			P_task_id,
	          		P_dummy_award_id,
			        P_expenditure_type,
			        l_status,
		                l_msg_label ) ;

        IF l_status <> 'S' THEN
          p_error_msg_label:= l_msg_label ;
          p_status	  := l_status ;
          return ;
        END IF ;

	IF l_doc_header_id is NULL THEN
              OPEN  c_next_header_id;
              FETCH c_next_header_id
              INTO  l_doc_header_id;
              CLOSE c_next_header_id;
	END IF ;

	IF l_distribution_id is NULL THEN
              OPEN  c_next_dist_id;
              FETCH c_next_dist_id
              INTO  l_distribution_id;
              CLOSE c_next_dist_id;
	END IF ;

	IF l_Document_source = 'IREQ' THEN
		l_document_source:= 'REQ' ;
	END IF ;

         --===========================================
         -- Insert Records into gms_distribution table
         --===========================================
         INSERT INTO gms_distributions
                       ( document_header_id ,
                         document_distribution_id,
                         document_type,
                         gl_date,
                         project_id,
                         task_id,
                         expenditure_type,
                         expenditure_organization_id,
                         expenditure_item_date,
                         quantity,
                         unit_price,
                         amount,
                         dist_status,
                         creation_date)
            VALUES     ( l_doc_header_id,
                         l_distribution_id,
                         l_document_source,
                         p_gl_encumbered_date,
                         p_project_id,
                         p_task_id,
                         p_expenditure_type,
                         p_expenditure_organization_id,
                         p_expenditure_item_date,
                         p_quantity,
                         p_unit_price,
                         p_func_amount,
                         NULL,
                         SYSDATE );

       GMS_AWARD_DIST_ENG.PROC_DISTRIBUTE_RECORDS(l_doc_header_id, 'REQ',l_recs_processed,l_recs_rejected);
        --process the results of PROC_DISTRIBUTE_RECORDS

        IF NVL(l_recs_processed,0) > 0 THEN
            --populate the return variables.
           SELECT            a.award_number ,
                             awdd.award_id ,
                             awdd.quantity_distributed,
                             awdd.amount_distributed
           BULK COLLECT INTO l_award_qty_obj.award_num,
                             l_award_qty_obj.award_id,
                             l_award_qty_obj.quantity,
                             l_award_qty_obj.amount
           FROM              gms_distribution_details awdd,
                             gms_distributions        awd,
                             gms_awards_all           a
           WHERE             awd.document_distribution_id  = awdd.document_distribution_id
           AND               awd.document_header_id        = awdd.document_header_id
           AND               awd.document_distribution_id  = l_distribution_id
           AND               awd.document_header_id        = l_doc_header_id
           AND               awd.document_type             = l_document_source
           AND               awd. dist_status              = 'FABA'
           AND               awdd.award_id                 = a.Award_id;
        END IF;

         IF NVL(l_recs_rejected,0) > 0 THEN

            l_status :='E';--failed status
            OPEN   c_awd_dist_status;
            FETCH  c_awd_dist_status INTO l_dist_status;
            CLOSE  c_awd_dist_status;

           IF l_dist_status ='ERR01' THEN
              l_msg_label := 'GMS_FP_VALIDATION_FAILED';
              --Unable to distribute because funding pattern didn't pass validations
           ELSIF  l_dist_status ='ERR02' THEN
              l_msg_label := 'GMS_FP_NOT_FOUND';
              --Unable to distribute because funding pattern not found
           ELSIF  l_dist_status ='ERR03' THEN
              l_msg_label := 'GMS_FP_CHECK_FUNDS_FAILED';
              -- Unable to distribute because funding pattern doesn't have enough funds

           END IF;

         END IF;

         p_status        := l_status;
         p_award_qty_obj := l_award_qty_obj;

         IF l_msg_label IS NOT  NULL THEN
            P_error_msg_label :=l_msg_label;
         END IF;


         EXCEPTION
           WHEN OTHERS THEN
              p_status :='U';
              p_error_msg_label :='GMS_UNDEFINED_EXCEPTION';
         END distribute_award;

END GMS_POR_API2;

/
