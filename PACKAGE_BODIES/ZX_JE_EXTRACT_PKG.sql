--------------------------------------------------------
--  DDL for Package Body ZX_JE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_JE_EXTRACT_PKG" AS
/* $Header: zxriextrajeppvtb.pls 120.14.12010000.5 2009/08/10 22:33:48 bibeura ship $ */

-----------------------------------------
--Private Variable Declarations

-----------------------------------------

-----------------------------------------

--Private Methods Declarations
-----------------------------------------

PG_DEBUG varchar2(1) ;
l_err_msg varchar2(120);


-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--
  g_current_runtime_level           NUMBER ;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                  VARCHAR2(100);
-----------------------------------------
--Public Methods Declarations
-----------------------------------------


/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |   POPULATE_JE_AR                                                          |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure calls the API to select the JE specific data from       |
 |    JE receivables tables.                                                 |
 |                                                                           |
 |    Called from ARP_TAX_EXTRACT.POPULATE_MISSING_COLUMNS.                  |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN: P_TRL_GLOBAL_VARIABLES_REC ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE|
 |                                                                           |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |   13-FEB-2006  RJREDDY  Created                                        |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE POPULATE_JE_AR
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

IS


TYPE ATTRIBUTE1_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE2_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE3_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE4_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE5_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE6_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE7_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE8_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE9_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE9%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE11_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE12_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE12%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE13_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE13%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE23_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE23%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE24_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE24%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE25_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE25%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE26_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE26%TYPE INDEX BY BINARY_INTEGER;

l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_tax_status_code_tbl           ZX_EXTRACT_PKG.TAX_STATUS_CODE_TBL;
l_trx_business_category_tbl     ZX_EXTRACT_PKG.TRX_BUSINESS_CATEGORY_TBL;
l_document_sub_type_tbl         ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;
l_tax_rate_id_tbl		ZX_EXTRACT_PKG.tax_rate_id_tbl ;

l_attribute1_tbl		ATTRIBUTE1_TBL;
l_attribute2_tbl		ATTRIBUTE2_TBL;
l_attribute3_tbl		ATTRIBUTE3_TBL;
l_attribute4_tbl		ATTRIBUTE4_TBL;
l_attribute5_tbl		ATTRIBUTE5_TBL;
l_attribute6_tbl		ATTRIBUTE6_TBL;
l_attribute7_tbl		ATTRIBUTE7_TBL;

l_attribute1_tmp_tbl		ATTRIBUTE1_TBL;
l_attribute2_tmp_tbl		ATTRIBUTE2_TBL;
l_attribute3_tmp_tbl		ATTRIBUTE3_TBL;
l_attribute4_tmp_tbl		ATTRIBUTE4_TBL;
l_attribute5_tmp_tbl		ATTRIBUTE5_TBL;
l_attribute6_tmp_tbl		ATTRIBUTE6_TBL;
l_attribute7_tmp_tbl		ATTRIBUTE7_TBL;

l_attribute8_tbl		ATTRIBUTE8_TBL;
l_attribute9_tbl		ATTRIBUTE9_TBL;
l_attribute11_tbl		ATTRIBUTE11_TBL;
l_attribute12_tbl		ATTRIBUTE12_TBL;
l_attribute13_tbl		ATTRIBUTE23_TBL;
l_attribute23_tbl		ATTRIBUTE23_TBL;
l_attribute24_tbl		ATTRIBUTE24_TBL;
l_attribute25_tbl		ATTRIBUTE25_TBL;
l_attribute26_tbl		ATTRIBUTE26_TBL;
C_LINES_PER_COMMIT		Number:=1000;
l_count		NUMBER ;

cursor get_rep_entity_info_cur is
SELECT         detail_tax_line_id,
               itf1.tax_status_code,
               itf1.trx_business_category,
               itf1.document_sub_type,
	             itf1.TAX_RATE_ID,
        	     (SELECT assoc.reporting_code_char_value
                FROM   zx_reporting_types_b rep_type,
                       zx_report_codes_assoc assoc
        	      WHERE rep_type.reporting_type_id = assoc.reporting_type_id
        	        AND  itf1.TAX_RATE_ID = assoc.entity_id
        	        AND assoc.entity_code = 'ZX_RATES'
        	        AND (assoc.EFFECTIVE_TO is null
                       or assoc.EFFECTIVE_TO >= NVL2(P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH,
                                                  itf1.tax_invoice_date,
                                                  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH,
                                                        itf1.trx_date,
                                                        NVL2(P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH,
                                                              itf1.gl_date,
                                                              sysdate
                                                            )
                                                       )
                                                )
                      )
        	        AND rep_type.reporting_type_code IN ('CZ_TAX_ORIGIN','HU_TAX_ORIGIN','PL_TAX_ORIGIN','CH_VAT_REGIME')
        	      ),
               (SELECT assoc.reporting_code_char_value
                FROM   zx_reporting_types_b rep_type,
                      zx_report_codes_assoc assoc
                WHERE rep_type.reporting_type_id = assoc.reporting_type_id
                AND   itf1.TAX_RATE_ID = assoc.entity_id
                AND   assoc.entity_code = 'ZX_RATES'
                AND  (assoc.EFFECTIVE_TO is null
                    or assoc.EFFECTIVE_TO >= NVL2(P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH,
                                                  itf1.tax_invoice_date,
                                                  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH,
                                                        itf1.trx_date,
                                                        NVL2(P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH,
                                                              itf1.gl_date,
                                                              sysdate
                                                            )
                                                       )
                                                )
                    )
               AND rep_type.reporting_type_code= 'EMEA_VAT_REPORTING_TYPE')
  FROM  zx_rep_trx_detail_t itf1
 WHERE itf1.application_id = 222
   AND itf1.entity_code = 'TRANSACTIONS'
   AND itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

--Bug 5636632
CURSOR get_reporting_code_value(
			 p_entity_id zx_report_codes_assoc.entity_id%TYPE ,
			 p_reporting_type zx_reporting_types_b.reporting_type_code%TYPE ) IS
SELECT assoc.reporting_code_char_value
FROM zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
WHERE rep_type.reporting_type_id = assoc.reporting_type_id
AND  assoc.entity_id = p_entity_id
AND assoc.entity_code = 'ZX_RATES'
AND rep_type.reporting_type_code = p_reporting_type ;

BEGIN

   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
                      'je_tax_extract.populate_je_ar(+)');
    END IF;

SELECT  detail_tax_line_id
BULK COLLECT INTO  l_detail_tax_line_id_tbl
FROM  zx_rep_trx_detail_t itf1
WHERE  itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;


IF l_detail_tax_line_id_tbl.count <> 0 THEN

		  INSERT INTO ZX_REP_TRX_JX_EXT_T
		       (detail_tax_line_ext_id,
			detail_tax_line_id,
			attribute9,
			attribute11,
			attribute12,
			attribute13,
			attribute23,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			request_id)
		  SELECT zx_rep_trx_jx_ext_t_s.nextval,
				itf1.detail_tax_line_id,
				decode (ra_cust.global_attribute_category,
					      'JE.ES.ARXTWMAI.MODELO347PR', ra_cust.global_attribute2,
					      'JE.ES.ARXTWMAI.MODELO415_347PR', ra_cust.global_attribute2,
					      NULL),
				decode (ra_cust.global_attribute_category,
                                              'JE.ES.ARXTWMAI.INVOICE_INFO',ra_cust.global_attribute3,
					      'JE.ES.ARXTWMAI.MODELO349', ra_cust.global_attribute3,
					      NULL),
				decode (ra_cust.global_attribute_category,
                                              'JE.ES.ARXTWMAI.INVOICE_INFO',ra_cust.global_attribute4,
					      'JE.ES.ARXTWMAI.MODELO349', ra_cust.global_attribute4,
					      NULL),
				decode (ra_cust.global_attribute_category,
                                              'JE.ES.ARXTWMAI.INVOICE_INFO',ra_cust.global_attribute5,
					      'JE.ES.ARXTWMAI.MODELO349', ra_cust.global_attribute5,
					      NULL),
                               substr(itf1.trx_business_category,(instr(itf1.trx_business_category,'MOD',1,1)+3),
                                  length(itf1.trx_business_category)),
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
				fnd_global.login_id,
				P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
		  FROM ra_customer_trx_all ra_cust,
		       zx_rep_trx_detail_t itf1
		  WHERE itf1.trx_id = ra_cust.customer_trx_id
		  AND itf1.application_id = 222
		  AND itf1.entity_code = 'TRANSACTIONS'
		  AND itf1.ledger_id = ra_cust.set_of_books_id
		  AND itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;


		open get_rep_entity_info_cur ;

		Loop

			Fetch get_rep_entity_info_cur
			bulk collect into
				L_DETAIL_TAX_LINE_ID_TBL,
				L_TAX_STATUS_CODE_TBL,
				L_TRX_BUSINESS_CATEGORY_TBL,
				L_DOCUMENT_SUB_TYPE_TBL,
				L_TAX_RATE_ID_TBL ,
				L_ATTRIBUTE25_TBL , --Bug 5510822
				L_ATTRIBUTE26_TBL   --EMEA Changes
			LIMIT C_LINES_PER_COMMIT;



	l_count := nvl(L_DETAIL_TAX_LINE_ID_TBL.COUNT,0);

	IF (g_level_unexpected >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_unexpected,
		     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
		      'l_count : '||l_count);
	END IF;

	FOR i IN 1..l_count
	LOOP
		IF L_ATTRIBUTE1_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE1_TBL(i) := L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_LOCATION');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE1_TBL(i) := L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE2_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE2_TBL(i) := L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_PRD_TAXABLE_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE2_TBL(i) := L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE3_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE3_TBL(i) := L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_PRD_REC_TAX_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE3_TBL(i) := L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE4_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE4_TBL(i) := L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_TTL_TAXABLE_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE4_TBL(i) := L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE5_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE5_TBL(i) := L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_REC_TAXABLE');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE5_TBL(i) := L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE6_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE6_TBL(i) := L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_NON_REC_TAXABLE');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE6_TBL(i) := L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE7_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE7_TBL(i) := L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_REC_TAX_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE7_TBL(i) := L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF (g_level_unexpected >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'Displaying the Vlaues for attributes : i :'||i);
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_DETAIL_TAX_LINE_ID_TBL(i)'||L_DETAIL_TAX_LINE_ID_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE1_TBL(i) :'||L_ATTRIBUTE1_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE2_TBL(i) :'||L_ATTRIBUTE2_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE3_TBL(i) :'||L_ATTRIBUTE3_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE4_TBL(i) :'||L_ATTRIBUTE4_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE5_TBL(i) :'||L_ATTRIBUTE5_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE6_TBL(i) :'||L_ATTRIBUTE6_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
				      'L_ATTRIBUTE7_TBL(i) :'||L_ATTRIBUTE7_TBL(i));
		END IF;

	END LOOP ;

	IF (g_level_unexpected >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_unexpected,
		     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
		      'Before Updating ZX_REP_TRX_JX_EXT_T with attribute columns obtained ' );
	END IF;

	IF ( l_count > 0 ) THEN

			FORALL i IN 1 .. L_DETAIL_TAX_LINE_ID_TBL.count
				UPDATE ZX_REP_TRX_JX_EXT_T
				SET
						TAX_STATUS_MNG	=	L_TAX_STATUS_CODE_TBL(i),
						TRX_BUSINESS_CATEGORY_MNG	=	L_TRX_BUSINESS_CATEGORY_TBL(i),
						DOCUMENT_SUB_TYPE_MNG	=	L_DOCUMENT_SUB_TYPE_TBL(i),
						ATTRIBUTE1	=	L_ATTRIBUTE1_TBL(i),
						ATTRIBUTE2	=	L_ATTRIBUTE2_TBL(i),
						ATTRIBUTE3	=	L_ATTRIBUTE3_TBL(i),
						ATTRIBUTE4	=	L_ATTRIBUTE4_TBL(i),
						ATTRIBUTE5	=	L_ATTRIBUTE5_TBL(i),
						ATTRIBUTE6	=	L_ATTRIBUTE6_TBL(i),
						ATTRIBUTE7	=	L_ATTRIBUTE7_TBL(i),
						attribute25     =	L_ATTRIBUTE25_TBL(i), --Bug 5510822
						attribute26     =	L_ATTRIBUTE26_TBL(i) --EMEA Changes
				WHERE 	        detail_tax_line_id = L_DETAIL_TAX_LINE_ID_TBL(i) and
						request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

	IF (g_level_unexpected >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_unexpected,
		     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.BEGIN',
		      'After Updating ZX_REP_TRX_JX_EXT_T with attribute columns obtained ' );
	END IF;
--			exit when get_rep_entity_info_cur%NOTFOUND;
	ELSE
		EXIT ;
	END IF ;

		end loop;

		close get_rep_entity_info_cur ;

END IF;
   --commit; Bug 8262631
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ar.END',
                      'je_tax_extract.populate_je_ar(-)');
    END IF;


EXCEPTION
WHEN OTHERS THEN

      l_err_msg := substrb(SQLERRM,1,120);
      arp_standard.debug('EXCEPTION raised in ' ||'POPULATE_JE_AR: ' ||SQLCODE ||':'||l_err_msg);

END populate_je_ar;


/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |   POPULATE_JE_AP                                                          |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure calls the API to select the JE specific data from       |
 |    JE payables tables. Currently only JE_LOOKUP_INFO plug-in is called    |
 |    inside.                                                                |
 |                                                                           |
 |    Called from ARP_TAX_EXTRACT.POPULATE_MISSING_COLUMNS.                  |
 |                                                                           |
 |   Parameters :                                                            |
 |                                                                           |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |     13-FEB-2006  RJREDDY  Created                                      |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/


PROCEDURE POPULATE_JE_AP
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

IS
TYPE ATTRIBUTE1_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE2_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE3_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE4_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE5_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE6_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE7_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER;
TYPE REPORTING_TYPE_ID_TBL is TABLE OF
      ZX_REPORTING_TYPES_B.REPORTING_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE8_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE8%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE10_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE10%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE11_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE11%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE12_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE12%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE13_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE13%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE14_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE14%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE15_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE15%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE16_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE16%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE17_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE17%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE18_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE18%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE19_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE19%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE20_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE20%TYPE INDEX BY BINARY_INTEGER;
TYPE DETAIL_TAX_LINE_ID_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.DETAIL_TAX_LINE_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE21_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE21%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE22_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE22%TYPE INDEX BY BINARY_INTEGER;
TYPE ATTRIBUTE23_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE23%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE24_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE24%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE25_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE25%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE26_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE26%TYPE INDEX BY BINARY_INTEGER;

l_detail_tax_line_id_tbl    DETAIL_TAX_LINE_ID_TBL;
l_tax_line_id_tbl			ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_id_tbl				ZX_EXTRACT_PKG.TRX_ID_TBL;
l_tax_rate_id_tbl		ZX_EXTRACT_PKG.tax_rate_id_tbl ;

l_tax_status_code_tbl			ZX_EXTRACT_PKG.TAX_STATUS_CODE_TBL;
l_trx_business_category_tbl		ZX_EXTRACT_PKG.TRX_BUSINESS_CATEGORY_TBL;
l_document_sub_type_tbl			ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;

l_attribute1_tbl			ATTRIBUTE1_TBL;
l_attribute2_tbl			ATTRIBUTE2_TBL;
l_attribute3_tbl			ATTRIBUTE3_TBL;
l_attribute4_tbl			ATTRIBUTE4_TBL;
l_attribute5_tbl			ATTRIBUTE5_TBL;
l_attribute6_tbl			ATTRIBUTE6_TBL;
l_attribute7_tbl			ATTRIBUTE7_TBL;

L_ATTRIBUTE1_TMP_TBL		ATTRIBUTE1_TBL;
L_ATTRIBUTE2_TMP_TBL		ATTRIBUTE2_TBL;
L_ATTRIBUTE3_TMP_TBL		ATTRIBUTE3_TBL;
L_ATTRIBUTE4_TMP_TBL		ATTRIBUTE4_TBL;
L_ATTRIBUTE5_TMP_TBL		ATTRIBUTE5_TBL;
L_ATTRIBUTE6_TMP_TBL		ATTRIBUTE6_TBL;
L_ATTRIBUTE7_TMP_TBL		ATTRIBUTE7_TBL;

l_attribute8_tbl			ATTRIBUTE8_TBL;
l_attribute10_tbl			ATTRIBUTE10_TBL;
l_attribute11_tbl			ATTRIBUTE11_TBL;
l_attribute12_tbl			ATTRIBUTE12_TBL;
l_attribute13_tbl			ATTRIBUTE13_TBL;
l_attribute14_tbl			ATTRIBUTE14_TBL;
l_attribute15_tbl			ATTRIBUTE15_TBL;
l_attribute16_tbl			ATTRIBUTE16_TBL;
l_attribute17_tbl			ATTRIBUTE17_TBL;
l_attribute18_tbl			ATTRIBUTE18_TBL;
l_attribute19_tbl			ATTRIBUTE19_TBL;
l_attribute20_tbl			ATTRIBUTE20_TBL;
l_attribute21_tbl                       ATTRIBUTE21_TBL;
l_attribute22_tbl                       ATTRIBUTE22_TBL;
l_attribute23_tbl                       ATTRIBUTE23_TBL;
l_attribute24_tbl                       ATTRIBUTE24_TBL;
l_attribute25_tbl                       ATTRIBUTE25_TBL;
l_attribute26_tbl                       ATTRIBUTE26_TBL;
C_LINES_PER_COMMIT			Number:=1000;
l_count NUMBER ;


cursor get_rep_entity_info_cur is
SELECT
		detail_tax_line_id,
		fsp.vat_country_code,
		tax_rate_id ,
		decode ( hr_loc.global_attribute_category,
			    'JE.ES.PERWSLOC.PRL_NO', hr_loc.global_attribute1,
			    NULL ),
		decode ( hr_loc.global_attribute_category,
			    'JE.ES.PERWSLOC.PRL_YES', hr_loc.global_attribute1,
			    NULL ),
		decode ( hr_loc.global_attribute_category,
			    'JE.ES.PERWSLOC.PRL_YES', hr_loc.global_attribute2,
			    NULL ),
		decode ( hr_loc.global_attribute_category,
			    'JE.ES.PERWSLOC.PRL_YES', hr_loc.global_attribute3,
			    NULL ),
		decode ( hr_loc.global_attribute_category,
			    'JE.ES.PERWSLOC.PRL_YES', hr_loc.global_attribute4,
			    NULL ),
		decode ( hr_loc.global_attribute_category,
			    'JE.ES.PERWSLOC.PRL_YES', hr_loc.global_attribute5,
			    NULL ),
		      (SELECT assoc.reporting_code_char_value FROM
			      zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
			      WHERE rep_type.reporting_type_id = assoc.reporting_type_id
			      AND  itf1.TAX_RATE_ID = assoc.entity_id
			      AND assoc.entity_code = 'ZX_RATES'
			      AND (assoc.EFFECTIVE_TO is null
                 or assoc.EFFECTIVE_TO >=  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH,
                                                  itf1.tax_invoice_date,
                                                  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH,
                                                        itf1.trx_date,
                                                        NVL2(P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH,
                                                              itf1.gl_date,
                                                              sysdate
                                                            )
                                                       )
                                                )
                )
			      AND rep_type.reporting_type_code IN ('CZ_TAX_ORIGIN','HU_TAX_ORIGIN','PL_TAX_ORIGIN','CH_VAT_REGIME')
			      ),
              (SELECT assoc.reporting_code_char_value FROM
              zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
              WHERE rep_type.reporting_type_id = assoc.reporting_type_id
              AND  itf1.TAX_RATE_ID = assoc.entity_id
              AND assoc.entity_code = 'ZX_RATES'
	            AND (assoc.EFFECTIVE_TO is null
                   or assoc.EFFECTIVE_TO >= NVL2(P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH,
                                                  itf1.tax_invoice_date,
                                                  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH,
                                                        itf1.trx_date,
                                                        NVL2(P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH,
                                                              itf1.gl_date,
                                                              sysdate
                                                            )
                                                       )
                                                )
                  )
              AND rep_type.reporting_type_code= 'EMEA_VAT_REPORTING_TYPE')
FROM   financials_system_params_all fsp,
       hr_locations_all hr_loc,
       zx_rep_trx_detail_t itf1
 WHERE
itf1.application_id = 200
 AND itf1.entity_code = 'AP_INVOICES'
 AND itf1.ledger_id = fsp.set_of_books_id
 AND itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
 AND itf1.ship_to_location_id = hr_loc.ship_to_location_id(+) ;

--Bug 5636632
CURSOR get_reporting_code_value(
			 p_entity_id zx_report_codes_assoc.entity_id%TYPE ,
			 p_reporting_type zx_reporting_types_b.reporting_type_code%TYPE ) IS
SELECT assoc.reporting_code_char_value
FROM zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
WHERE rep_type.reporting_type_id = assoc.reporting_type_id
AND  assoc.entity_id = p_entity_id
AND assoc.entity_code = 'ZX_RATES'
AND rep_type.reporting_type_code = p_reporting_type ;

BEGIN
   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.populate_je_ap.BEGIN',
                      'je_tax_extract.populate_je_ap(+)');
    END IF;


SELECT  detail_tax_line_id
BULK COLLECT INTO  l_tax_line_id_tbl
FROM  zx_rep_trx_detail_t itf1
WHERE  itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;


IF l_tax_line_id_tbl.count <> 0 THEN
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.populate_je_ap',
                      'POPULATE_JE_AP - Rows extracted : '||to_char(l_tax_line_id_tbl.count));
    END IF;
		INSERT INTO ZX_REP_TRX_JX_EXT_T
		       (detail_tax_line_ext_id,
			detail_tax_line_id,
			tax_status_mng,
			trx_business_category_mng,
			document_sub_type_mng,
			attribute8,
			attribute11,
			attribute12,
		--	attribute3,
		--	attribute13,
			attribute20,
		        attribute21,
			attribute22,
			attribute23,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			request_id)
		 SELECT  zx_rep_trx_jx_ext_t_s.nextval,
			       itf1.detail_tax_line_id,
			       itf1.tax_status_code,
			       itf1.trx_business_category,
			       itf1.document_sub_type,
			       decode ( ap_inv.global_attribute_category,
					'JE.SK.APXINWKB.INVOICE_INFO', ap_inv.global_attribute2,
					'JE.HU.APXINWKB.TAX_DATE', ap_inv.global_attribute2,
					NULL ),
			       decode ( ap_inv.global_attribute_category,
					'JE.ES.APXINWKB.INVOICE_INFO', ap_inv.global_attribute2,
					'JE.ES.APXINWKB.MODELO349', ap_inv.global_attribute2,
					NULL ),
			       decode ( ap_inv.global_attribute_category,
					'JE.ES.APXINWKB.INVOICE_INFO', ap_inv.global_attribute3,
					'JE.ES.APXINWKB.MODELO349', ap_inv.global_attribute3,
					NULL ),
		--		decode ( ap_inv.global_attribute_category,
	--				'JE.CZ.APXINWKB.INVOICE_INFO', ap_inv.global_attribute3,
	--				NULL ),
	--		       decode ( ap_inv.global_attribute_category,
	--				'JE.CZ.APXINWKB.INVOICE_INFO', ap_inv.global_attribute4,
	--				NULL ),
			       ap_inv.source,
  			       decode ( ap_inv.global_attribute_category,
                                        'JE.CZ.APXINWKB.INVOICE_INFO', ap_inv.GLOBAL_ATTRIBUTE3,
                                        'JE.IL.APXINWKB.INVOICE_INFO', ap_inv.GLOBAL_ATTRIBUTE3,
                                        NULL ),
                               decode ( ap_inv.global_attribute_category,
                                        'JE.CZ.APXINWKB.INVOICE_INFO', ap_inv.GLOBAL_ATTRIBUTE4,
                                        'JE.IL.APXINWKB.INVOICE_INFO', ap_inv.GLOBAL_ATTRIBUTE4,
                                        NULL ),
                               substr(itf1.trx_business_category,(instr(itf1.trx_business_category,'MOD',1,1)+3),
                                  length(itf1.trx_business_category)),
			       fnd_global.user_id,
			       sysdate,
			       fnd_global.user_id,
			       sysdate,
			       fnd_global.login_id,
			       P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
		 FROM ap_invoices_all ap_inv,
		      zx_rep_trx_detail_t itf1
		 WHERE itf1.trx_id = ap_inv.invoice_id
		 and itf1.application_id = 200
		 and itf1.entity_code = 'AP_INVOICES'
		 and itf1.ledger_id = ap_inv.set_of_books_id
		 and itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

	IF ( g_level_unexpected>= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JE_AP',
				      'No. of rows inserted into ZX_REP_TRX_JX_EXT_T : '||to_char(SQL%ROWCOUNT) );
	END IF;

			open get_rep_entity_info_cur ;

			Loop

				Fetch get_rep_entity_info_cur
				BULK COLLECT INTO
					L_DETAIL_TAX_LINE_ID_TBL,
					L_ATTRIBUTE10_TBL,
					L_TAX_RATE_ID_TBL ,
					L_ATTRIBUTE14_TBL,
					L_ATTRIBUTE15_TBL,
					L_ATTRIBUTE16_TBL,
					L_ATTRIBUTE17_TBL,
					L_ATTRIBUTE18_TBL,
					L_ATTRIBUTE19_TBL,
					l_attribute25_tbl, --Bug 5510822
					l_attribute26_tbl --Emea changes
				LIMIT C_LINES_PER_COMMIT;

	l_count := nvl(L_DETAIL_TAX_LINE_ID_TBL.COUNT,0);

	IF (g_level_unexpected >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_unexpected,
		     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
		      'l_count : '||l_count);
	END IF;

	FOR i IN 1..l_count
	LOOP
		IF L_ATTRIBUTE1_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE1_TBL(i) := L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_LOCATION');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE1_TBL(i) := L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE2_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE2_TBL(i) := L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_PRD_TAXABLE_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE2_TBL(i) := L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE3_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE3_TBL(i) := L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_PRD_REC_TAX_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE3_TBL(i) := L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE4_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE4_TBL(i) := L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_TTL_TAXABLE_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE4_TBL(i) := L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE5_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE5_TBL(i) := L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_REC_TAXABLE');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE5_TBL(i) := L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE6_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE6_TBL(i) := L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_NON_REC_TAXABLE');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE6_TBL(i) := L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF L_ATTRIBUTE7_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
			L_ATTRIBUTE7_TBL(i) := L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		ELSE
			OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_REC_TAX_BOX');
			FETCH get_reporting_code_value INTO L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
			IF ( get_reporting_code_value%NOTFOUND ) THEN
				L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
			END IF ;
			CLOSE get_reporting_code_value;
			L_ATTRIBUTE7_TBL(i) := L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
		END IF ;

		IF (g_level_unexpected >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'Displaying the Vlaues for attributes : i :'||i);
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_DETAIL_TAX_LINE_ID_TBL(i)'||L_DETAIL_TAX_LINE_ID_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE1_TBL(i) :'||L_ATTRIBUTE1_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE2_TBL(i) :'||L_ATTRIBUTE2_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE3_TBL(i) :'||L_ATTRIBUTE3_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE4_TBL(i) :'||L_ATTRIBUTE4_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE5_TBL(i) :'||L_ATTRIBUTE5_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE6_TBL(i) :'||L_ATTRIBUTE6_TBL(i));
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
				      'L_ATTRIBUTE7_TBL(i) :'||L_ATTRIBUTE7_TBL(i));
		END IF;

	END LOOP ;

	IF (g_level_unexpected >= g_current_runtime_level ) THEN
	FND_LOG.STRING(g_level_unexpected,
		     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_ap.BEGIN',
		      'Before Updating ZX_REP_TRX_JX_EXT_T with attribute columns obtained ' );
	END IF;

	IF ( l_count > 0 ) THEN

		IF ( g_level_statement>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_statement, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JE_AP',
					      'Before Updating ZX_REP_TRX_JX_EXT_T' );
		END IF;
				FORALL i IN 1 .. L_DETAIL_TAX_LINE_ID_TBL.count
					UPDATE ZX_REP_TRX_JX_EXT_T
					SET 		ATTRIBUTE10     =      	L_ATTRIBUTE10_TBL(i),
							ATTRIBUTE1	=	L_ATTRIBUTE1_TBL(i),
							ATTRIBUTE2	=	L_ATTRIBUTE2_TBL(i),
							ATTRIBUTE3	=	L_ATTRIBUTE3_TBL(i),
							ATTRIBUTE4	=	L_ATTRIBUTE4_TBL(i),
							ATTRIBUTE5	=	L_ATTRIBUTE5_TBL(i),
							ATTRIBUTE6	=	L_ATTRIBUTE6_TBL(i),
							ATTRIBUTE7	=	L_ATTRIBUTE7_TBL(i),
							ATTRIBUTE14     =      	L_ATTRIBUTE14_TBL(i),
							ATTRIBUTE15	=	L_ATTRIBUTE15_TBL(i),
							ATTRIBUTE16	=	L_ATTRIBUTE16_TBL(i),
							ATTRIBUTE17	=	L_ATTRIBUTE17_TBL(i),
							ATTRIBUTE18	=	L_ATTRIBUTE18_TBL(i),
							ATTRIBUTE19	=	L_ATTRIBUTE19_TBL(i),
							attribute25     =       l_attribute25_tbl(i), --Bug 5510822
							attribute26     =       l_attribute26_tbl(i)--Emea Changes
					WHERE 	        detail_tax_line_id =    L_DETAIL_TAX_LINE_ID_TBL(i)
							and request_id =        P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

				--exit when get_rep_entity_info_cur%NOTFOUND;

		IF ( g_level_unexpected>= g_current_runtime_level ) THEN
		FND_LOG.STRING(g_level_unexpected, 'ZX.TRL.ZX_JA_EXTRACT_PKG.POPULATE_JE_AP',
					      'After Updating ZX_REP_TRX_JX_EXT_T' );
		END IF;
	   ELSE
		EXIT ;
	   END IF ;

			end loop;

			close get_rep_entity_info_cur ;


END IF;
    --commit; Bug 8262631
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.populate_je_ap.END',
                      'je_tax_extract.populate_je_ap(-)');
    END IF;

EXCEPTION
WHEN OTHERS THEN

      l_err_msg := substrb(SQLERRM,1,120);
      arp_standard.debug('EXCEPTION raised in ' ||'POPULATE_JE_AP: ' ||SQLCODE ||':'||l_err_msg);

END populate_je_ap;

/*===========================================================================+
 | PUBLIC PROCEDURE                                                          |
 |   POPULATE_JE_GL                                                          |
 |   Type       : Public                                                     |
 |   Pre-req    : None                                                       |
 |   Function   :                                                            |
 |    This procedure calls the API to select the JE specific data from       |
 |    JE GL tables.                                                          |
 |                                                                           |
 |    Called from                                                            |
 |                                                                           |
 |   Parameters :                                                            |
 |   IN: P_TRL_GLOBAL_VARIABLES_REC ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE|
 |                                                                           |
 |                                                                           |
 |   MODIFICATION HISTORY                                                    |
 |   22-MAY-2006  VSDOSHI  Created                                        |
 |                                                                           |
 |                                                                           |
 +===========================================================================*/

PROCEDURE POPULATE_JE_GL
(
 P_TRL_GLOBAL_VARIABLES_REC	IN	ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE
)

IS

--Bug 5636632
TYPE ATTRIBUTE1_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE1%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE2_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE2%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE3_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE3%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE4_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE4%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE5_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE5%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE6_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE6%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE7_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE7%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE25_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE25%TYPE INDEX BY BINARY_INTEGER;

TYPE ATTRIBUTE26_TBL is TABLE OF
      ZX_REP_TRX_JX_EXT_T.ATTRIBUTE26%TYPE INDEX BY BINARY_INTEGER;

l_attribute1_tbl		ATTRIBUTE1_TBL;
l_attribute2_tbl		ATTRIBUTE2_TBL;
l_attribute3_tbl		ATTRIBUTE3_TBL;
l_attribute4_tbl		ATTRIBUTE4_TBL;
l_attribute5_tbl		ATTRIBUTE5_TBL;
l_attribute6_tbl		ATTRIBUTE6_TBL;
l_attribute7_tbl		ATTRIBUTE7_TBL;
l_attribute25_tbl		ATTRIBUTE25_TBL;
l_attribute26_tbl		ATTRIBUTE26_TBL;

l_attribute1_tmp_tbl		ATTRIBUTE1_TBL;
l_attribute2_tmp_tbl		ATTRIBUTE2_TBL;
l_attribute3_tmp_tbl		ATTRIBUTE3_TBL;
l_attribute4_tmp_tbl		ATTRIBUTE4_TBL;
l_attribute5_tmp_tbl		ATTRIBUTE5_TBL;
l_attribute6_tmp_tbl		ATTRIBUTE6_TBL;
l_attribute7_tmp_tbl		ATTRIBUTE7_TBL;

l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
l_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
l_tax_status_code_tbl           ZX_EXTRACT_PKG.TAX_STATUS_CODE_TBL;
l_trx_business_category_tbl     ZX_EXTRACT_PKG.TRX_BUSINESS_CATEGORY_TBL;
l_document_sub_type_tbl         ZX_EXTRACT_PKG.DOCUMENT_SUB_TYPE_TBL;
l_tax_rate_id_tbl		ZX_EXTRACT_PKG.tax_rate_id_tbl ;
L_COUNT				NUMBER ;
C_LINES_PER_COMMIT		Number:=1000;

CURSOR get_reporting_code_value(
			 p_entity_id zx_report_codes_assoc.entity_id%TYPE ,
			 p_reporting_type zx_reporting_types_b.reporting_type_code%TYPE ) IS
SELECT assoc.reporting_code_char_value
FROM zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
WHERE rep_type.reporting_type_id = assoc.reporting_type_id
AND  assoc.entity_id = p_entity_id
AND assoc.entity_code = 'ZX_RATES'
AND rep_type.reporting_type_code = p_reporting_type ;

cursor get_rep_entity_info_cur is
SELECT         detail_tax_line_id,
               itf1.tax_status_code,
               itf1.trx_business_category,
               itf1.document_sub_type,
	             itf1.TAX_RATE_ID,
      	     (SELECT assoc.reporting_code_char_value FROM
      	      zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
      	      WHERE rep_type.reporting_type_id = assoc.reporting_type_id
      	      AND  itf1.TAX_RATE_ID = assoc.entity_id
      	      AND assoc.entity_code = 'ZX_RATES'
      	      AND (assoc.EFFECTIVE_TO is null
                   or assoc.EFFECTIVE_TO >= NVL2(P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH,
                                                        itf1.tax_invoice_date,
                                                        NVL2(P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH,
                                                              itf1.trx_date,
                                                              NVL2(P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH,
                                                                    itf1.gl_date,
                                                                    sysdate
                                                                  )
                                                             )
                                                )
                  )
      	      AND rep_type.reporting_type_code IN ('CZ_TAX_ORIGIN','HU_TAX_ORIGIN','PL_TAX_ORIGIN','CH_VAT_REGIME')
      	      ) ,
              (SELECT assoc.reporting_code_char_value FROM
              zx_reporting_types_b rep_type,zx_report_codes_assoc assoc
              WHERE rep_type.reporting_type_id = assoc.reporting_type_id
              AND  itf1.TAX_RATE_ID = assoc.entity_id
              AND assoc.entity_code = 'ZX_RATES'
	            AND (assoc.EFFECTIVE_TO is null
                   or assoc.EFFECTIVE_TO >=  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TAX_INVOICE_DATE_HIGH,
                                                  itf1.tax_invoice_date,
                                                  NVL2(P_TRL_GLOBAL_VARIABLES_REC.TRX_DATE_HIGH,
                                                        itf1.trx_date,
                                                        NVL2(P_TRL_GLOBAL_VARIABLES_REC.GL_DATE_HIGH,
                                                              itf1.gl_date,
                                                              sysdate
                                                            )
                                                       )
                                                )
                  )
              AND rep_type.reporting_type_code= 'EMEA_VAT_REPORTING_TYPE')
  FROM  zx_rep_trx_detail_t itf1
 WHERE itf1.application_id = 101
 AND itf1.entity_code = 'GL_JE_LINES'
 AND itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

BEGIN

   g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
                      'je_tax_extract.populate_je_gl(+)');

      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
                      'Before insertion into ZX_REP_TRX_JX_EXT_T - 1');
    END IF;

SELECT  detail_tax_line_id
BULK COLLECT INTO  l_detail_tax_line_id_tbl
FROM  zx_rep_trx_detail_t itf1
WHERE  itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

IF (g_level_unexpected >= g_current_runtime_level ) THEN
FND_LOG.STRING(g_level_unexpected,
	     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
	      'Count Before insertion - 1'||to_char(l_detail_tax_line_id_tbl.count));
END IF;

IF l_detail_tax_line_id_tbl.count <> 0 THEN

  		  INSERT INTO ZX_REP_TRX_JX_EXT_T
		       (detail_tax_line_ext_id,
			detail_tax_line_id,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			attribute24,
			request_id)
		  SELECT zx_rep_trx_jx_ext_t_s.nextval,
				itf1.detail_tax_line_id,
				fnd_global.user_id,
				sysdate,
				fnd_global.user_id,
				sysdate,
				fnd_global.login_id,
				gjl.tax_type_code,
				P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
		  FROM gl_je_lines gjl ,
		       zx_rep_trx_detail_t itf1
		  WHERE itf1.application_id = 101
		  AND itf1.request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID
		  AND itf1.trx_id = gjl.je_header_id
		  AND itf1.trx_line_id = gjl.je_line_num;

		    IF (g_level_unexpected >= g_current_runtime_level ) THEN
		      FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
				      'No. of rows inserted into ZX_REP_TRX_JX_EXT_T - 1'||to_char(sql%ROWCOUNT));
		    END IF;

		open get_rep_entity_info_cur ;

		Loop

			Fetch get_rep_entity_info_cur
			bulk collect into
				L_DETAIL_TAX_LINE_ID_TBL,
				L_TAX_STATUS_CODE_TBL,
				L_TRX_BUSINESS_CATEGORY_TBL,
				L_DOCUMENT_SUB_TYPE_TBL,
				L_TAX_RATE_ID_TBL ,
				L_ATTRIBUTE25_TBL,
				L_ATTRIBUTE26_TBL
			LIMIT C_LINES_PER_COMMIT;

			l_count := nvl(L_DETAIL_TAX_LINE_ID_TBL.COUNT,0);

			IF (g_level_unexpected >= g_current_runtime_level ) THEN
			FND_LOG.STRING(g_level_unexpected,
				     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
				      'l_count : '||l_count);
			END IF;

			FOR i IN 1..l_count
			LOOP
				IF L_ATTRIBUTE1_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE1_TBL(i) := L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_LOCATION');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE1_TBL(i) := L_ATTRIBUTE1_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;

				IF L_ATTRIBUTE2_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE2_TBL(i) := L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_PRD_TAXABLE_BOX');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE2_TBL(i) := L_ATTRIBUTE2_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;

				IF L_ATTRIBUTE3_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE3_TBL(i) := L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_PRD_REC_TAX_BOX');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE3_TBL(i) := L_ATTRIBUTE3_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;

				IF L_ATTRIBUTE4_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE4_TBL(i) := L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_TTL_TAXABLE_BOX');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE4_TBL(i) := L_ATTRIBUTE4_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;

				IF L_ATTRIBUTE5_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE5_TBL(i) := L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_REC_TAXABLE');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE5_TBL(i) := L_ATTRIBUTE5_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;

				IF L_ATTRIBUTE6_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE6_TBL(i) := L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_NON_REC_TAXABLE');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE6_TBL(i) := L_ATTRIBUTE6_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;

				IF L_ATTRIBUTE7_TMP_TBL.EXISTS(L_TAX_RATE_ID_TBL(i)) THEN
					L_ATTRIBUTE7_TBL(i) := L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				ELSE
					OPEN get_reporting_code_value(L_TAX_RATE_ID_TBL(i),'PT_ANL_REC_TAX_BOX');
					FETCH get_reporting_code_value INTO L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
					IF ( get_reporting_code_value%NOTFOUND ) THEN
						L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i)) := NULL ;
					END IF ;
					CLOSE get_reporting_code_value;
					L_ATTRIBUTE7_TBL(i) := L_ATTRIBUTE7_TMP_TBL(L_TAX_RATE_ID_TBL(i));
				END IF ;


				IF (g_level_unexpected >= g_current_runtime_level ) THEN
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'Displaying the Vlaues for attributes : i :'||i);
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_DETAIL_TAX_LINE_ID_TBL(i)'||L_DETAIL_TAX_LINE_ID_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE1_TBL(i) :'||L_ATTRIBUTE1_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE2_TBL(i) :'||L_ATTRIBUTE2_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE3_TBL(i) :'||L_ATTRIBUTE3_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE4_TBL(i) :'||L_ATTRIBUTE4_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE5_TBL(i) :'||L_ATTRIBUTE5_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE6_TBL(i) :'||L_ATTRIBUTE6_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_ATTRIBUTE7_TBL(i) :'||L_ATTRIBUTE7_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_TAX_STATUS_CODE_TBL(i) :'||L_TAX_STATUS_CODE_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_TRX_BUSINESS_CATEGORY_TBL(i) :'||L_TRX_BUSINESS_CATEGORY_TBL(i));
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'L_DOCUMENT_SUB_TYPE_TBL(i) :'||L_DOCUMENT_SUB_TYPE_TBL(i));
				END IF;

			END LOOP ;

			IF ( l_count > 0 ) THEN

				IF (g_level_unexpected >= g_current_runtime_level ) THEN
				FND_LOG.STRING(g_level_unexpected,
					     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
					      'Before Updating ZX_REP_TRX_JX_EXT_T with attribute columns obtained -GL ' );
				END IF;

					FORALL i IN 1 .. l_count
						UPDATE ZX_REP_TRX_JX_EXT_T
						SET
								TAX_STATUS_MNG	=	L_TAX_STATUS_CODE_TBL(i),
								TRX_BUSINESS_CATEGORY_MNG	=	L_TRX_BUSINESS_CATEGORY_TBL(i),
								DOCUMENT_SUB_TYPE_MNG	=	L_DOCUMENT_SUB_TYPE_TBL(i),
								ATTRIBUTE1	=	L_ATTRIBUTE1_TBL(i),
								ATTRIBUTE2	=	L_ATTRIBUTE2_TBL(i),
								ATTRIBUTE3	=	L_ATTRIBUTE3_TBL(i),
								ATTRIBUTE4	=	L_ATTRIBUTE4_TBL(i),
								ATTRIBUTE5	=	L_ATTRIBUTE5_TBL(i),
								ATTRIBUTE6	=	L_ATTRIBUTE6_TBL(i),
								ATTRIBUTE7	=	L_ATTRIBUTE7_TBL(i),
								attribute25     =	L_ATTRIBUTE25_TBL(i),
								attribute26     =	L_ATTRIBUTE26_TBL(i)
						WHERE 	        detail_tax_line_id = L_DETAIL_TAX_LINE_ID_TBL(i) and
								request_id = P_TRL_GLOBAL_VARIABLES_REC.REQUEST_ID;

					IF (g_level_unexpected >= g_current_runtime_level ) THEN
					FND_LOG.STRING(g_level_unexpected,
						     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.BEGIN',
						      'After Updating ZX_REP_TRX_JX_EXT_T with attribute columns obtained ' );
					END IF;
		--			exit when get_rep_entity_info_cur%NOTFOUND;
			ELSE
				EXIT ;
			END IF ;

		end loop;

		close get_rep_entity_info_cur ;

END IF ;

  --commit; Bug 8262631
    IF (g_level_unexpected >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_unexpected,
                     'ZX.TRL.je_tax_extract.je_tax_extract.populate_je_gl.END',
                      'je_tax_extract.populate_je_gl(-)');
    END IF;


EXCEPTION
WHEN OTHERS THEN

      l_err_msg := substrb(SQLERRM,1,120);
      arp_standard.debug('EXCEPTION raised in ' ||'POPULATE_JE_GL: ' ||SQLCODE ||':'||l_err_msg);

END populate_je_gl;

END ZX_JE_EXTRACT_PKG;

/
