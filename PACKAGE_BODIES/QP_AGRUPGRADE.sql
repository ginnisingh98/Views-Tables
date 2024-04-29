--------------------------------------------------------
--  DDL for Package Body QP_AGRUPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_AGRUPGRADE" AS
/* $Header: QPXUPAGB.pls 120.0 2005/06/02 01:29:23 appldev noship $ */


--PROCEDURE Create_Parallel_Slabs(l_workers IN NUMBER := 5) IS  --2422176
PROCEDURE Create_Parallel_Slabs(l_workers IN NUMBER) IS
      v_type              	 CONSTANT VARCHAR2(3) := 'AGR';
      l_total_lines            NUMBER;
      l_min_line               NUMBER;
      l_max_line               NUMBER;
      l_counter                NUMBER;
      l_gap                    NUMBER;
      l_worker_count           NUMBER;
      l_worker_start           NUMBER;
      l_worker_end             NUMBER;
      l_price_list_line_id     NUMBER;
      l_start_flag             NUMBER;
      l_total_workers          NUMBER;

   BEGIN

      delete qp_upg_lines_distribution
	 where line_type = v_type;
      commit;

      BEGIN
                SELECT
                     NVL(MIN(AGREEMENT_ID),0),
                     NVL(MAX(AGREEMENT_ID),0)
                INTO
                     l_min_line,
                     l_max_line
                FROM
		           SO_AGREEMENTS_B;

      EXCEPTION
         when others then
         null;
      END;


      FOR i in 1..l_workers LOOP

          l_worker_start := l_min_line + trunc( (i-1) * (l_max_line-l_min_line)/l_workers);

          l_worker_end := l_min_line + trunc(i*(l_max_line - l_min_line)/l_workers);

          IF (i <> l_workers) then
             l_worker_end := l_worker_end - 1;
          END IF;

                QP_Modifier_Upgrade_Util_PVT.insert_line_distribution
                ( l_worker      => i,
                  l_start_line  => l_worker_start,
                  l_end_line    => l_worker_end,
                  l_type_var    => v_type);

       END LOOP;

       commit;

  END Create_Parallel_Slabs;


PROCEDURE Copy_Agreement(l_worker IN NUMBER := 1) AS

l_new_agreement_id NUMBER;
l_price_list_name VARCHAR2(240);
l_current_price_list_id NUMBER;
l_previous_price_list_id NUMBER;
l_price_list_id NUMBER;
l_list_header_id NUMBER;

errmsg VARCHAR2(2000);
lerrbuf   VARCHAR2(100) := NULL;
lretcode  NUMBER := 0;

G_COMPARATOR_CODE    CONSTANT VARCHAR2(1) := '=';
v_context VARCHAR2(30) := 'CUSTOMER';
v_attribute_name VARCHAR2(240) := 'QUALIFIER_ATTRIBUTE7';

x_error_code NUMBER;
x_qualifier_precedence    NUMBER;
x_qualifier_datatype      VARCHAR2(30);
x_qualifier_grouping_no NUMBER;

v_min_line NUMBER;
v_max_line NUMBER;

CURSOR so_agreements_cur(p_min_line NUMBER,
					p_max_line NUMBER) IS
 SELECT
  AGREEMENT_ID,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  AGREEMENT_TYPE_CODE,
  PRICE_LIST_ID,
  TERM_ID,
  OVERRIDE_IRULE_FLAG,
  OVERRIDE_ARULE_FLAG,
  SIGNATURE_DATE,
  AGREEMENT_NUM,
  INVOICING_RULE_ID,
  ACCOUNTING_RULE_ID,
  CUSTOMER_ID,
  PURCHASE_ORDER_NUM,
  INVOICE_CONTACT_ID,
  AGREEMENT_CONTACT_ID,
  INVOICE_TO_SITE_USE_ID,
  SALESREP_ID,
  START_DATE_ACTIVE,
  END_DATE_ACTIVE,
  CONTEXT,
  --NAME,
  ATTRIBUTE1,
  ATTRIBUTE2,
  ATTRIBUTE3,
  ATTRIBUTE4,
  ATTRIBUTE5,
  ATTRIBUTE6,
  ATTRIBUTE7,
  ATTRIBUTE8,
  ATTRIBUTE9,
  ATTRIBUTE10,
  ATTRIBUTE11,
  ATTRIBUTE12,
  ATTRIBUTE13,
  ATTRIBUTE14,
  ATTRIBUTE15
 from  so_agreements_b a
 where NOT EXISTS (select 'x'
  from oe_agreements_b
  where agreement_id = a.agreement_id)
  AND a.agreement_id BETWEEN p_min_line AND p_max_line;

BEGIN

  BEGIN
    SELECT start_line_id, end_line_id
	 INTO v_min_line, v_max_line
	 FROM qp_upg_lines_distribution
     WHERE worker = l_worker
	  AND line_type = G_LIST_TYPE_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 v_min_line := 0;
	 v_max_line := 0;
	 COMMIT;
	 RETURN;
  END;

     FOR agreement_rec IN so_agreements_cur(v_min_line, v_max_line) LOOP
--dbms_output.put_line('processing agr = '||agreement_rec.agreement_id);

	     BEGIN
		  INSERT INTO OE_AGREEMENTS_B (
 						 AGREEMENT_ID
 						,CREATION_DATE
 						,CREATED_BY
 						,LAST_UPDATE_DATE
 						,LAST_UPDATED_BY
 						,LAST_UPDATE_LOGIN
 						,AGREEMENT_TYPE_CODE
 						,PRICE_LIST_ID
 						,TERM_ID
 						,OVERRIDE_IRULE_FLAG
 						,OVERRIDE_ARULE_FLAG
 						,SIGNATURE_DATE
 						,AGREEMENT_NUM
 						,REVISION
 						,REVISION_DATE
 						,REVISION_REASON_CODE
 						,FREIGHT_TERMS_CODE
 						,SHIP_METHOD_CODE
 						,INVOICING_RULE_ID
 						,ACCOUNTING_RULE_ID
 						,PURCHASE_ORDER_NUM
 						,INVOICE_CONTACT_ID
 						,AGREEMENT_CONTACT_ID
 						,SALESREP_ID
 						,START_DATE_ACTIVE
 						,END_DATE_ACTIVE
 						,COMMENTS
 						,CONTEXT
 						,ATTRIBUTE1
 						,ATTRIBUTE2
 						,ATTRIBUTE3
 						,ATTRIBUTE4
 						,ATTRIBUTE5
 						,ATTRIBUTE6
 						,ATTRIBUTE7
 						,ATTRIBUTE8
 						,ATTRIBUTE9
 						,ATTRIBUTE10
 						,ATTRIBUTE11
 						,ATTRIBUTE12
 						,ATTRIBUTE13
 						,ATTRIBUTE14
 						,ATTRIBUTE15
 						,TP_ATTRIBUTE1
 						,TP_ATTRIBUTE2
 						,TP_ATTRIBUTE3
 						,TP_ATTRIBUTE4
 						,TP_ATTRIBUTE5
 						,TP_ATTRIBUTE6
 						,TP_ATTRIBUTE7
 						,TP_ATTRIBUTE8
 						,TP_ATTRIBUTE9
 						,TP_ATTRIBUTE10
 						,TP_ATTRIBUTE11
 						,TP_ATTRIBUTE12
 						,TP_ATTRIBUTE13
 						,TP_ATTRIBUTE14
 						,TP_ATTRIBUTE15
 						,TP_ATTRIBUTE_CATEGORY
 						,INVOICE_TO_ORG_ID
 						,SOLD_TO_ORG_ID
 					)
					values( agreement_rec.agreement_id
						, sysdate
						, agreement_rec.created_by
						, sysdate
						, agreement_rec.last_updated_by
						, agreement_rec.last_update_login
						, agreement_rec.agreement_type_code
						, agreement_rec.price_list_id
						, agreement_rec.term_id
						, agreement_rec.override_irule_flag
						, agreement_rec.override_arule_flag
						, sysdate
						, agreement_rec.agreement_num
						, 1 -- revision
						, sysdate
						, null
						, null
						, null
						, agreement_rec.invoicing_rule_id
						, agreement_rec.accounting_rule_id
						, agreement_rec.purchase_order_num
						, agreement_rec.invoice_contact_id
						, agreement_rec.agreement_contact_id
						, agreement_rec.salesrep_id
						, nvl(agreement_rec.start_date_active,NULL)
						, nvl(agreement_rec.end_date_active, NULL )
						, null
						, agreement_rec.context
						, agreement_rec.attribute1
						, agreement_rec.attribute2
						, agreement_rec.attribute3
						, agreement_rec.attribute4
						, agreement_rec.attribute5
						, agreement_rec.attribute6
						, agreement_rec.attribute7
						, agreement_rec.attribute8
						, agreement_rec.attribute9
						, agreement_rec.attribute10
						, agreement_rec.attribute11
						, agreement_rec.attribute12
						, agreement_rec.attribute13
						, agreement_rec.attribute14
						, agreement_rec.attribute15
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, NULL
						, agreement_rec.invoice_to_site_use_id
						, agreement_rec.customer_id
					);
/*

					FROM   so_agreements_b b ,
						  so_agreements_vl t
					WHERE  b.agreement_id = agreement_rec.agreement_id
					and    t.agreement_id = agreement_rec.agreement_id ;
					*/

		EXCEPTION
		when OTHERS THEN
		    errmsg := SQLERRM;
		    rollback;
		    qp_util.Log_Error(
				   p_id1 => agreement_rec.agreement_id,
				   p_error_type => 'DATA',
				   p_error_desc => errmsg,
				   p_error_module	=> 'QP_AGRUPGRADE'
				);

		   RAISE;


	    END;



		/* Inserting into Translation agreements Table */


	    BEGIN
				INSERT INTO OE_AGREEMENTS_TL (
						  AGREEMENT_ID
						, LANGUAGE
 						, SOURCE_LANG
 						, NAME
 						, LAST_UPDATE_DATE
 						, LAST_UPDATED_BY
 						, CREATION_DATE
 						, CREATED_BY
 						, LAST_UPDATE_LOGIN
 						)

  				SELECT
					agreement_rec.agreement_id,
   				 	l.language_code,
					userenv('LANG'),
					t.name,
   					sysdate,
					agreement_rec.last_updated_by,
					sysdate,
					agreement_rec.created_by,
					agreement_rec.last_update_login
  			     FROM fnd_languages l
				,    so_agreements_tl t
  				WHERE l.installed_flag IN ('I', 'B')
				and t.agreement_id = agreement_rec.agreement_id
				and t.language = l.language_code
  				AND   NOT EXISTS (
					 SELECT NULL
  			     	 FROM   oe_agreements_tl r
			           WHERE  r.agreement_id = agreement_rec.agreement_id
			           AND    r.language  = l.language_code);



		EXCEPTION
		when OTHERS THEN
		    errmsg := SQLERRM;
		    rollback;
		    qp_util.Log_Error(
				   p_id1 => agreement_rec.agreement_id,
				   p_error_type => 'DATA',
				   p_error_desc => errmsg,
				   p_error_module	=> 'QP_AGRUPGRADE '
				);
		   RAISE;


	    END;

	 -- Commit every 500 rows
	 IF(mod(so_agreements_cur%ROWCOUNT,500) = 0) THEN
       COMMIT;
      END IF;

	END LOOP;

EXCEPTION
    WHEN OTHERS THEN
	  errmsg := SQLERRM;
	  rollback;
		    qp_util.Log_Error(
				   p_id1 => 123456,
				   p_error_type => 'DATA',
				   p_error_desc => errmsg,
				   p_error_module	=> 'QP_AGRUPGRADE '
				);

	RAISE;


END Copy_Agreement;


END QP_AgrUpgrade;

/
