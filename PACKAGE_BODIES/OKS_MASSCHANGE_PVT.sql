--------------------------------------------------------
--  DDL for Package Body OKS_MASSCHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_MASSCHANGE_PVT" AS
/* $Header: OKSRMASB.pls 120.31 2007/12/14 10:44:09 mkarra ship $ */

 l_conc_program Varchar2(1);


 PROCEDURE get_eligible_contracts
		 (p_api_version           IN  Number
		 ,p_init_msg_list         IN  Varchar2
		 ,p_ctr_rec               IN  criteria_rec_type
                 ,p_query_type            IN  Varchar2 DEFAULT 'FETCH'
                 ,p_upg_orig_system_ref   IN  Varchar2
		 ,x_return_status         OUT NOCOPY Varchar2
		 ,x_msg_count             OUT NOCOPY Number
		 ,x_msg_data              OUT NOCOPY Varchar2
		 ,x_eligible_contracts    OUT NOCOPY eligible_contracts_tbl)

      IS

	   TYPE t_contracts IS REF CURSOR;

	   v_CurContract           t_contracts;
	   l_stmt                  Varchar2(10000);
           l_stmt_all              Varchar2(10000);
	   l_select                Varchar2(2000);
	   l_from                  Varchar2(2000);
	   l_where                 Varchar2(20000);
           l_org_where             Varchar2(2000);
           l_org_id                OKC_K_HEADERS_B.org_id%type;
       l_eligible_contracts    eligible_contracts_tbl;

        i               Number := 0;
        j               Number := 0;
        k               Number := 0;
        v_present         Varchar2(1);
        l_old_value	Varchar2(500);

  BEGIN

    x_return_status := G_RET_STS_SUCCESS;

    IF p_query_type = 'FETCH' THEN

 	           l_select :='SELECT distinct okh.id,
                                  okh.contract_number,
                                  okh.contract_number_modifier,
                                  okh.start_date,
                                  okh.end_date,
                                  okh.short_description,
                                  okh.sts_code,
                                  oxp.name party
                                  ,org.name
				   ,okh.billed_at_source';

              l_from :=' FROM  okc_k_headers_v okh,okc_k_party_roles_b okp,okx_parties_v oxp, hr_operating_units org,okc_assents_v oas
                        , okc_k_lines_b ocl';

       If p_ctr_rec.attribute in ('CONTRACT_START_DATE','CONTRACT_END_DATE') Then
          IF p_ctr_rec.oie_id IS NOT NULL THEN

      	      l_where:=' WHERE okh.scs_code in (''SERVICE'',''SUBSCRIPTION'',''WARRANTY'')
		         AND okh.datetime_cancelled IS NULL  -- Added as part of LLC
    			 AND okh.date_terminated is NULL
	       		 AND okh.id not in(
                                 SELECT ole.subject_chr_id
                                 FROM  okc_operation_instances_v oie,
                                       okc_operation_lines_v ole,
                                       okc_class_operations_v oco
                                 WHERE oie.id = ole.oie_id
                                 AND   oie.id = :p_ctr_rec_oie_id
                                 AND   oie.cop_id = oco.id AND   opn_code = ''MASS_CHANGE'')
		                AND oas.sts_code = okh.sts_code
	                        AND oas.opn_code = ''UPDATE''
		          	AND oas.scs_code = okh.scs_code
				AND  ocl.chr_id = okh.id
				AND  nvl(ocl.upg_orig_system_ref,''X'') <> ''MIG_NOBILL''
		        AND okh.id = okp.chr_id
			AND okp.rle_code in ( ''CUSTOMER'',''SUBSCRIBER'')
    	                AND okp.object1_id1 = oxp.id1
	                And  org.organization_id = okh.authoring_org_id
	                AND oxp.id2 = ''#'''  ;
          ELSE -- oie_id null
     	       l_where:=' WHERE okh.scs_code in (''SERVICE'',''SUBSCRIPTION'',''WARRANTY'')
                     AND okh.datetime_cancelled IS NULL  -- Added as part of LLC
	             AND okh.date_terminated is NULL
                                 AND oas.sts_code = okh.sts_code
                                 AND oas.opn_code = ''UPDATE''
                                 AND oas.scs_code = okh.scs_code
                                  AND  ocl.chr_id = okh.id
                                  AND  nvl(ocl.upg_orig_system_ref,''X'') <> ''MIG_NOBILL''
                   AND okh.id = okp.chr_id
                   AND okp.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                   AND okp.object1_id1 = oxp.id1
                   And  org.organization_id = okh.authoring_org_id
                   AND oxp.id2 = ''#''';
         END IF;

      Else  -- Attribute is stat_date or end_date

         IF p_ctr_rec.oie_id IS NOT NULL THEN

      	    l_where:=' WHERE okh.scs_code in (''SERVICE'',''SUBSCRIPTION'',''WARRANTY'')
                     AND okh.datetime_cancelled IS NULL  -- Added as part of LLC
	             AND okh.date_terminated is NULL
                     AND  okh.id not in ( SELECT ole.subject_chr_id
                                 FROM  okc_operation_instances_v oie,
                                       okc_operation_lines_v ole,
                                       okc_class_operations_v oco
                                 WHERE oie.id = ole.oie_id
                                 AND   oie.id = :p_ctr_rec_oie_id
                                 AND   oie.cop_id = oco.id AND   opn_code = ''MASS_CHANGE'')
	                         AND oas.sts_code = okh.sts_code
                                AND oas.opn_code = ''UPDATE''
		                AND oas.scs_code = okh.scs_code
                                  AND  ocl.chr_id = okh.id
                                  AND  ocl.lse_id <> 14
                                  AND   nvl(ocl.upg_orig_system_ref,''X'') <> ''MIG_NOBILL''
                    AND okh.id = okp.chr_id
                    AND okp.rle_code in ( ''CUSTOMER'',''SUBSCRIBER'')
                    AND okp.object1_id1 = oxp.id1
                    And  org.organization_id = okh.authoring_org_id
                    AND oxp.id2 = ''#'''  ;
          ELSE -- oie_id is null
     	      l_where:=' WHERE okh.scs_code in (''SERVICE'',''SUBSCRIPTION'',''WARRANTY'')
                     AND okh.datetime_cancelled IS NULL  -- Added as part of LLC
                     AND okh.date_terminated is NULL
                                 AND   oas.sts_code = okh.sts_code
                                 AND   oas.opn_code = ''UPDATE''
                                 AND   oas.scs_code = okh.scs_code
                                 AND   ocl.chr_id = okh.id
                                 AND   ocl.lse_id <> 14
                                 AND   nvl(ocl.upg_orig_system_ref,''X'') <> ''MIG_NOBILL''
                   AND okh.id = okp.chr_id
                   AND okp.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                   AND okp.object1_id1 = oxp.id1
                   And org.organization_id = okh.authoring_org_id
                   AND oxp.id2 = ''#''';
         END IF;

      End If ; -- attribute is stat_date or end_date

    ELSIF (p_query_type = 'PROCESS' AND p_ctr_rec.oie_id IS NOT NULL) THEN

	     l_select :='SELECT okh.id,
                            okh.contract_number,
                            okh.contract_number_modifier,
                            okh.start_date,
                            okh.end_date,
                            okh.short_description,
                            okh.sts_code,
                            okh.qcl_id ,
                            okh.object_version_number,
                            ole.id ole_id,
                            okh.org_id,
                            mod.qa_check_yn,
                            org.name ,
			    okh.billed_at_source';

        l_from :=' FROM  okc_k_headers_v okh,okc_operation_lines_v ole ,oks_mschg_operations_dtls mod, hr_operating_units org';
      	l_where:=' WHERE ole.select_yn = ''Y''
	           AND   ole.process_flag IN (''A'',''E'')
                   AND   okh.id = ole.subject_chr_id
                   AND   ole.oie_id = :p_ctr_rec_oie_id
                   AND   mod.ole_id = ole.id
                   And  org.organization_id = okh.authoring_org_id ';

      END IF;

 --dbms_output.put_line('Update_level:'||p_ctr_rec.update_level);
 --dbms_output.put_line('Update_level_value:'||p_ctr_rec.update_level_value);
 --dbms_output.put_line('Attribute:'||p_ctr_rec.attribute);
 --dbms_output.put_line('Old value:'||p_ctr_rec.old_value);

 --------------------------------
 --  Update Level : Contract
 --------------------------------
 IF p_ctr_rec.update_level = 'OKS_K_HEADER' THEN

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Revenue Account(REV_ACCT)
 --------------------------------------------------------
      IF p_ctr_rec.attribute = 'REV_ACCT' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id is NULL)
                        AND okh.id = to_number(:update_level_value)' ; --||to_number(p_ctr_rec.update_level_value);

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id)
                        AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id = to_number(:p_ctr_rec_old_value))
                        AND okh.id = to_number(:update_level_value)';

          END IF;
  --------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Payment Term(PAYMENT_TERM)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PAYMENT_TERM' THEN

       -- Old Value: NULL (-9999)
	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                       ' AND  okh.PAYMENT_TERM_ID is NULL
                         AND  okh.id = to_number(:p_ctr_rec_old_value) ';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                               'AND okh.id = to_number(:update_level_value)';
 -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.PAYMENT_TERM_ID = to_number(:p_ctr_rec_old_value)
                         AND  okh.id = to_number(:p_ctr_rec_old_value) ';

          END IF;

 --------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Contract Renewal Type(CON_RENEWAL_TYPE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CON_RENEWAL_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                       ' AND  okh.renewal_type_code is NULL
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id = to_number(:p_ctr_rec_old_value) ';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_old_value := p_ctr_rec.old_value;
                       l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||l_where||
                                ' AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                                AND okh.id = to_number(:update_level_value)';
 -- Old Value: ERN

          ELSIF p_ctr_rec.old_value = 'ERN' then
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||', oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND   (okh.renewal_type_code = ''NSR''
                                 AND ''ERN'' = :p_ctr_rec_old_value
                                 AND oksh.ELECTRONIC_RENEWAL_FLAG =''Y'')
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                        AND  okh.id = to_number(:p_ctr_rec_old_value) ';

 -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||', oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = :p_ctr_rec_old_value
                        AND  nvl(oksh.ELECTRONIC_RENEWAL_FLAG,''N'') <>''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                        AND  okh.id = to_number(:p_ctr_rec_old_value) ';
          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Business Process Price List (BP_PRICE_LIST)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'BP_PRICE_LIST' THEN

     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||
                        l_where|| 'AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21)
                                            AND cln.price_list_id is NULL)
                                   AND  okh.id = to_number(:update_level_value)';

     -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21))
                                   AND  okh.id = to_number(:update_level_value)';

     -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                      Where cln.dnz_chr_id = okh.id
                                      AND cln.lse_id in(3,16,21)
                                      AND cln.price_list_id = to_number(:p_ctr_rec_old_value))
                                  AND  okh.id = to_number(:update_level_value)';

          END IF;


 ---------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Accounting Rule(ACCT_RULE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'ACCT_RULE' THEN

     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where|| 'AND oksh.chr_id = okh.id
                                   AND oksh.acct_rule_id IS NULL
                                   AND  okh.id = to_number(:update_level_value)';
     -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND  okh.id = to_number(:update_level_value)';
     -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND oksh.acct_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND  okh.id = to_number(:update_level_value)';

          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Invoice Rule(INV_RULE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'INV_RULE' THEN

       -- Old Value: NULL (-9999)
         IF  p_ctr_rec.old_value = '-9999' THEN

             l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                             ' AND  okh.inv_rule_id IS NULL
                               AND  okh.id = to_number(:update_level_value) ';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                    l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                              l_from||l_where||
                                    ' AND  okh.id = to_number(:update_level_value) ';

       -- Old Value: Other than NULL or ALL

          ELSE

                l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                          l_from||l_where||
                                ' AND  okh.inv_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND  okh.id = to_number(:update_level_value) ';

          END IF;

 ---------------------------------------------------------------------------
 -- Update Level : Contract , Attribute: Coverage Type(COV_TYPE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V okl, oks_k_lines_v oksl
                                             WHERE okl.dnz_chr_id = okh.id
                                             AND oksl.cle_id = okl.id
                                             AND oksl.coverage_type is NULL )
                        AND  okh.id = to_number(:update_level_value)' ;

        -- Old Value: Other than NULL or ALL

          ELSIF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                          l_from||
                          l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                    WHERE okl.dnz_chr_id = okh.id
                                    AND oksl.cle_id = okl.id )
                        AND  okh.id = to_number(:update_level_value)' ;
          ELSE
                 l_old_value := p_ctr_rec.old_value;
                 l_stmt := l_select||' , :l_old_value old_value'||
                           l_from||
                           l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                     WHERE okl.dnz_chr_id = okh.id
                                     AND oksl.cle_id = okl.id
                                     AND oksl.coverage_type = :p_ctr_rec_old_value )
                        AND  okh.id = to_number(:update_level_value)' ;

          END IF;

 ---------------------------------------------------------------------------
 -- Update Level : Contract , Attribute: Coverage Type(COV_TIMEZONE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TIMEZONE' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                      WHERE ctz.dnz_chr_id = okh.id
                                      AND   ctz.timezone_id IS NULL )
                         AND   okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND   ctz.timezone_id IS NOT NULL )
                                             AND   okh.id = to_number(:update_level_value)';
        -- Old Value: Other than NULL or ALL
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND  ctz.timezone_id = to_number(:p_ctr_rec_old_value))
                                             AND  okh.id = to_number(:update_level_value)';

          END IF;
 ---------------------------------------------------------------------------
 -- Update Level : Contract , Attribute: Coverage Type(PREF_ENGG)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PREF_ENGG' THEN

          IF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE'')
                                             AND  okh.id = to_number(:update_level_value)';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND  okh.id = to_number(:update_level_value)';
          END IF;
 ---------------------------------------------------------------------------
 -- Update Level : Contract , Attribute: Coverage Type(RES_GROUP)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RES_GROUP' THEN


          IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP'')
                                             AND  okh.id = to_number(:update_level_value)';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND   okh.id = to_number(:update_level_value)';
          END IF;

 ---------------------------------------------------------------------------
 -- Update Level : Contract , Attribute: Coverage Type(AGREEMENT_NAME)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'AGREEMENT_NAME' THEN

 -- Old Value: Other than NULL or ALL

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from okc_governances_v ogv
                                             WHERE ogv.dnz_chr_id = okh.id
                                             AND   ogv.isa_agreement_id = :p_ctr_rec_old_value)
                                             AND  okh.id = to_number(:update_level_value)';
 ------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Product Alias (PRODUCT_ALIAS)
 ------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRODUCT_ALIAS' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen is NULL)
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35))
                        AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE
            --nerrorout_n('Here**********');
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                         WHERE cle.dnz_chr_id = okh.id
                         AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                         AND   cle.cognomen = :p_ctr_rec_old_value)
                        AND okh.id = to_number(:update_level_value)';
                        --errorout_n('Here**********' ||l_stmt);

          END IF;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Contract Line Ref(CONTRACT_LINE_REF)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_LINE_REF' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen is NULL)
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19))
                                     AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                        AND okh.id = to_number(:update_level_value)';

          END IF;

   --------------------------------------------------------
 --  Update Level : Contract , Attribute: Header Ship-to Address (HDR_SHIP_TO_ADDRESS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_SHIP_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                ' AND  okh.ship_to_site_use_id is NULL
                                  AND  okh.id = to_number(:p_ctr_rec_old_value) ';

        -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.ship_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.ship_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND  okh.id = to_number(:p_ctr_rec_old_value) ';
         END IF;

  --------------------------------------------------------
 --  Update Level : Contract , Attribute: Header Bill-to Address(HDR_BILL_TO_ADDRESS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_BILL_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id is NULL
                                     AND  okh.id = to_number(:p_ctr_rec_old_value) ';
       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.bill_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND  okh.id = to_number(:p_ctr_rec_old_value) ';
         END IF;


 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Sales Rep (SALES_REP)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SALES_REP' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND (EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                        OR EXISTS (Select ''x'' from oks_k_sales_credits_v osc
                                   Where osc.chr_id = okh.id
                                   and osc.ctc_id is NULL))
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,oc.object1_id1 old_value '||
                       l_from||', okc_contacts oc '||
                       l_where||' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SALESPERSON''
                          and   oc.jtot_object1_code = ''OKX_SALEPERS''
                       AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND (EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                        OR EXISTS (Select ''x'' from oks_k_sales_credits_v osc
                                   Where osc.chr_id = okh.id
                                   and osc.ctc_id = to_number(:p_ctr_rec_old_value)))
                         AND  okh.id = to_number(:update_level_value)';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Party Shipping Contact (PARTY_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_SHIPPING_CONTACT' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                       AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = to_number(:update_level_value)';

          END IF;

 --------------------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Party Billing Contact (PARTY_BILLING_CONTACT)
 --------------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_BILLING_CONTACT' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''BILLING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                       AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = to_number(:update_level_value)';
          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Party Shipping Contact (LINE_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_SHIPPING_CONTACT' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                       AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND  okh.id = to_number(:update_level_value)';

          END IF;

 --------------------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Party Billing Contact (LINE_BILLING_CONTACT)
 --------------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_BILLING_CONTACT' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                        AND okh.id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_BILLING''
                          and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                       AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1 = :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND  okh.id = to_number(:update_level_value)';
          END IF;


 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Coverage Time (COVERAGE_START_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_START_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.start_hour is null
                                         and   oct.start_minute is null)
                        AND okh.id = to_number(:update_level_value)';

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.id = to_number(:update_level_value)';
          END IF;

--------------------------------------------------------
 --  Update Level : Contract , Attribute: Coverage Time (COVERAGE_END_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_END_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.end_hour is null
                                         and   oct.end_minute is null)
                        AND okh.id = to_number(:update_level_value)';

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.end_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.id = to_number(:update_level_value)';
          END IF;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Resolution Time (RESOLUTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RESOLUTION_TIME'   THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '|| l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                 OR mon_duration IS NULL
                                 OR tue_duration IS NULL
                                 OR wed_duration IS NULL
                                 OR thu_duration IS NULL
                                 OR fri_duration IS NULL
                                 OR sat_duration IS NULL)
                        AND okh.id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL
          ELSE

            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND okh.id = to_number(:update_level_value)';
          END IF;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Reaction Time (REACTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'REACTION_TIME' THEN

   -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
                       l_stmt := l_select||', NULL old_value'||
                         l_from||', okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
                          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                               OR mon_duration IS NULL
                                               OR tue_duration IS NULL
                                               OR wed_duration IS NULL
                                               OR thu_duration IS NULL
                                               OR fri_duration IS NULL
                                               OR sat_duration IS NULL)
                        AND  okh.id = to_number(:update_level_value)';
 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                      l_from||', okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
                          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND  okh.id = to_number(:update_level_value)';

          END IF;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Price List(PRICE_LIST)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRICE_LIST' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value'||
                        l_from||l_where||
                         ' AND  okh.price_list_id is NULL
                           AND  okh.id = to_number(:update_level_value) ';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                         l_from||l_where||
                         ' AND  okh.id = to_number(:update_level_value) ';


          ELSE

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.price_list_id = to_number(:p_ctr_rec_old_value)
                         AND  okh.id = to_number(:update_level_value) ';

          END IF;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Known As(CONTRACT_ALIAS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_ALIAS' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND okh.cognomen is null
                        AND okh.id = :update_level_value ' ;

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,okh.cognomen old_value'||
                       l_from||l_where||
                       ' AND okh.id = :update_level_value ' ;

 -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||', okh.cognomen old_value'||
                       l_from||l_where||
                       '  AND okh.cognomen = :p_ctr_rec_old_value
                        AND okh.id = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: PO NUMBER(PO_NUMBER_BILL)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PO_NUMBER_BILL' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND okh.cust_po_number is null
                         AND ( okh.payment_instruction_type  Is Null Or okh.payment_instruction_type = ''PON'')
                        AND okh.id = :update_level_value ' ;

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
            If p_ctr_rec.new_value is Null Then
             l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||l_where||
                       ' AND okh.payment_instruction_type = ''PON''
                         AND okh.id = :update_level_value And okh.cust_po_number_req_yn <> ''Y''' ;
            Else

	                 l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||l_where||
                       ' AND okh.payment_instruction_type = ''PON''
                         AND okh.id = :update_level_value ' ;
            End If;
 -- Old Value: Other than NULL or ALL

          ELSE
	     If p_ctr_rec.new_value is Null Then


             l_stmt := l_select||', okh.cust_po_number old_value'||
                       l_from||l_where||
                       '  AND okh.cust_po_number = :p_ctr_rec_old_value
                          AND okh.payment_instruction_type = ''PON''
                        AND okh.id = :update_level_value And okh.cust_po_number_req_yn <>
			''Y''';

	   Else
	   l_stmt := l_select||', okh.cust_po_number old_value'||
                       l_from||l_where||
                       '  AND okh.cust_po_number = :p_ctr_rec_old_value
                          AND okh.payment_instruction_type = ''PON''
                        AND okh.id = :update_level_value';
	   End If;

          END IF;

 -----------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: PO NUMBER Required(PO_REQUIRED_REN)
 -----------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PO_REQUIRED_REN' THEN


           IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       'AND okh.id = :update_level_value';

     -- Old Value: Other than NULL or ALL
           ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.renewal_po_required,''N'') = :p_ctr_rec_old_value
                                   AND okh.id = to_number(:update_level_value)';
           END IF ;

 --------------------------------------------------------
 --  Update Level : Contract , Attribute: Summary Print(SUMMARY_PRINT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SUMMARY_PRINT' THEN

       -- Old Value: All (-1111)

        IF p_ctr_rec.old_value = '-1111' THEN
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                      l_from||' ,oks_k_headers_v oksh '||
                      l_where||' AND oksh.chr_id = okh.id
                                 AND okh.id = :update_level_value';

      -- Old Value: Other than NULL or ALL
        ELSE
              l_old_value := p_ctr_rec.old_value;
              l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.inv_print_profile,''N'') = :p_ctr_rec_old_value
                                   AND okh.id = to_number(:update_level_value)';

        END IF ;

 -------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Contract Group (CONTRACT_GROUP)
 --------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_GROUP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id is NULL
     					          AND okh.id = to_number(:update_level_value)';
--/*
--             l_stmt := l_select||' ,NULL old_value'||
--                       l_from||l_where||
--                       'AND EXISTS (SELECT id from okc_k_headers_v a
--                                    WHERE a.id = okh.id
--                                    MINUS
--                                    SELECT okg.included_chr_id
--                                    FROM okc_k_groups_grpings_v okg
--									WHERE okg.included_chr_id = okh.id)
--                       AND okh.id = '||to_number(p_ctr_rec.update_level_value);
--*/

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
                       AND okh.id = to_number(:update_level_value)';

          ELSE
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id = to_number(:p_ctr_rec_old_value)
     					          AND okh.id = to_number(:update_level_value)';

          END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Contract Start date (CONTRACT_START_DATE)
 ------------------------------------------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'CONTRACT_START_DATE' Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract Start date as NULL
             l_stmt := l_select||',to_char(okh.start_date) old_value'||
                       l_from||
                       l_where||' AND okh.start_date is NULL
     					          AND okh.id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract Start date not NULL
             l_stmt := l_select||',to_char(okh.start_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.start_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
     					          AND okh.id = to_number(:update_level_value)';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Contract , Attribute: Contract End date (CONTRACT_END_DATE)
 ------------------------------------------------------------------------------------------

      ELSIF UPPER(p_ctr_rec.attribute) = UPPER('CONTRACT_END_DATE') Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract End date as NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND okh.end_date is NULL
     					          AND okh.id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract End date not NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.end_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
     					          AND okh.id = to_number(:update_level_value)';
          END IF;

      END IF;

-----------------------------------
 --  Update Level : ORGANIZATION
 -----------------------------------

 ELSIF p_ctr_rec.update_level = 'OKX_OPERUNIT' THEN --'ORGANIZATION' THEN


 ---------------------------------------------------------
 --  Update Level : Organization , Attribute: Revenue Account (REV_ACCT)
 --------------------------------------------------------
      IF p_ctr_rec.attribute = 'REV_ACCT' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id is NULL)
                        AND okh.org_id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id)
                        AND okh.org_id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id  = to_number(:p_ctr_rec_old_value))
                        AND okh.org_id = to_number(:update_level_value)';

          END IF;

 ---------------------------------------------------------
 --  Update Level : Organization, Attribute: Payment Term (PAYMENT_TERM)
 --------------------------------------------------------

       ELSIF p_ctr_rec.attribute = 'PAYMENT_TERM' THEN

       -- Old Value: NULL (-9999)

   	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                       ' AND  okh.PAYMENT_TERM_ID is NULL
                         AND okh.org_id = to_number(:update_level_value)';
       -- Old Value: ALL (-1111)
         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                               'AND okh.org_id = to_number(:update_level_value)';
       -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.payment_term_id = to_number(:p_ctr_rec_old_value)
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;

-------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Contract Renewal Type(CON_RENEWAL_TYPE)
------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CON_RENEWAL_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||
                       l_where||
                       ' AND  okh.renewal_type_code is NULL
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND okh.org_id = to_number(:update_level_value)';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_old_value := p_ctr_rec.old_value;
                       l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where||
                             ' AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                                AND okh.org_id = to_number(:update_level_value)';

 -- Old Value: ERN

          ELSIF p_ctr_rec.old_value = 'ERN' then

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = ''NSR''
                        AND ''ERN'' = :p_ctr_rec_old_value
                        AND oksh.ELECTRONIC_RENEWAL_FLAG =''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND okh.org_id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = :p_ctr_rec_old_value
                        AND   nvl(oksh.ELECTRONIC_RENEWAL_FLAG,''N'') <> ''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND okh.org_id = to_number(:update_level_value)';
          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Business Process Price List (BP_PRICE_LIST)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'BP_PRICE_LIST' THEN

     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||
                        l_where|| 'AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21)
                                            AND cln.price_list_id is NULL)
                                   AND okh.org_id = to_number(:update_level_value)';

     -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21))
                                   AND okh.org_id = to_number(:update_level_value)';

     -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                      Where cln.dnz_chr_id = okh.id
                                      AND cln.lse_id in(3,16,21)
                                      AND cln.price_list_id = to_number(:p_ctr_rec_old_value))
                                  AND okh.org_id = to_number(:update_level_value)';

          END IF;


 ---------------------------------------------------------
 --  Update Level : Organization, Attribute: Accounting Rule (ACCT_RULE)
 --------------------------------------------------------

       ELSIF p_ctr_rec.attribute = 'ACCT_RULE' THEN

      -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where|| 'AND oksh.chr_id = okh.id
                                   AND oksh.acct_rule_id IS NULL
                                   AND okh.org_id = to_number(:update_level_value)';
     -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND okh.org_id = to_number(:update_level_value)';
     -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND oksh.acct_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND okh.org_id = to_number(:update_level_value)';
          END IF;

 ---------------------------------------------------------
 --  Update Level : Organization, Attribute: Invoice Rule (INV_RULE)
 --------------------------------------------------------

       ELSIF p_ctr_rec.attribute = 'INV_RULE' THEN

       -- Old Value: NULL (-9999)
         IF  p_ctr_rec.old_value = '-9999' THEN

             l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                             ' AND  okh.inv_rule_id IS NULL
                               AND  okh.org_id = to_number(:update_level_value)';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                       l_from||l_where||
                             ' AND  okh.org_id = to_number(:update_level_value)';

       -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                       l_from||l_where||
                             ' AND  okh.inv_rule_id = to_number(:p_ctr_rec_old_value)
                               AND  okh.org_id = to_number(:update_level_value)';

          END IF;
---------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage Type(COV_TYPE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TYPE' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V okl, oks_k_lines_v oksl
                                             WHERE okl.dnz_chr_id = okh.id
                                             AND oksl.cle_id = okl.id
                                             AND oksl.coverage_type is NULL )
                        AND  okh.org_id = to_number(:update_level_value)';

        -- Old Value: ALL

          ELSIF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                          l_from||
                          l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                    WHERE okl.dnz_chr_id = okh.id
                                    AND oksl.cle_id = okl.id )
                        AND  okh.org_id = to_number(:update_level_value)';
         -- Old Value: Other than NULL or ALL
          ELSE
                 l_old_value := p_ctr_rec.old_value;
                 l_stmt := l_select||' , :l_old_value old_value'||
                           l_from||
                           l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                     WHERE okl.dnz_chr_id = okh.id
                                     AND oksl.cle_id = okl.id
                                     AND oksl.coverage_type = :p_ctr_rec_old_value )
                         AND  okh.org_id = to_number(:update_level_value)';

          END IF;


 ---------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage Type(COV_TIMEZONE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TIMEZONE' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                      WHERE ctz.dnz_chr_id = okh.id
                                      AND   ctz.timezone_id IS NULL )
                         AND  okh.org_id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND   ctz.timezone_id IS NOT NULL )
                                             AND  okh.org_id = to_number(:update_level_value)';
        -- Old Value: Other than NULL or ALL
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND  ctz.timezone_id = to_number(:p_ctr_rec_old_value))
                                             AND  okh.org_id = to_number(:update_level_value)';

          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage Type(PREF_ENGG)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PREF_ENGG' THEN


          IF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE'')
                                             AND   okh.org_id = to_number(:update_level_value)';
                                 --            AND   oco.object1_id1  = '''||p_ctr_rec.old_value||''')
                                 --            AND  okh.id = '||to_number(p_ctr_rec.update_level_value) ;

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND   okh.org_id = to_number(:update_level_value)';
--                                             AND  okh.id = '||to_number(p_ctr_rec.update_level_value) ;
          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage Type(RES_GROUP)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RES_GROUP' THEN

         IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP'')
                                             AND   okh.org_id = to_number(:update_level_value)';
                                 --            AND   oco.object1_id1  = '''||p_ctr_rec.old_value||''')
                                 --            AND  okh.id = '||to_number(p_ctr_rec.update_level_value) ;

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND   okh.org_id = to_number(:update_level_value)';
                                            -- AND   okh.id = '||to_number(p_ctr_rec.update_level_value) ;
          END IF;



 ---------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage Type(AGREEMENT_NAME)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'AGREEMENT_NAME' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from okc_governances_v ogv
                                             WHERE ogv.dnz_chr_id = okh.id
                                             AND   ogv.isa_agreement_id = :p_ctr_rec_old_value)
                                             AND   okh.org_id = to_number(:update_level_value)';

 ---------------------------------------------------------
 --  Update Level : Organization , Attribute: Product Alias (PRODUCT_ALIAS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRODUCT_ALIAS' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen is NULL)
                        AND okh.org_id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35))
                        AND okh.org_id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                        AND okh.org_id = to_number(:update_level_value)';

          END IF;

 ---------------------------------------------------------
 --  Update Level : Organization , Attribute: Contract Line Ref(CONTRACT_LINE_REF)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_LINE_REF' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen is NULL)
                        AND okh.org_id = to_number(:update_level_value)';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19))
                        AND okh.org_id = to_number(:update_level_value)';

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                        AND okh.org_id = to_number(:update_level_value)';

          END IF;

 ---------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Header Ship-to Address(HDR_SHIP_TO_ADDRESS)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_SHIP_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                ' AND  okh.ship_to_site_use_id is NULL
                                  AND okh.org_id = to_number(:update_level_value)';

       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.ship_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.ship_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND okh.org_id = to_number(:update_level_value)';
         END IF;

  ----------------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Header Bill-to Address(HDR_BILL_TO_ADDRESS)
 -----------------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_BILL_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id is NULL
                                     AND okh.org_id = to_number(:update_level_value)';
       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.bill_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND okh.org_id = to_number(:update_level_value)';
         END IF;

-------------------------------------------------------
 --  Update Level : Organization , Attribute: Sales Rep (SALES_REP)
--------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SALES_REP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                        AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,oc.object1_id1 old_value '||
                       l_from||', okc_contacts oc '||
                       l_where||' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SALESPERSON''
                          and   oc.jtot_object1_code = ''OKX_SALEPERS''
                       AND okh.org_id = to_number(:update_level_value)';
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND (EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                        OR EXISTS (Select ''x'' from oks_k_sales_credits_v osc
                                   Where osc.chr_id = okh.id
                                   and osc.ctc_id = to_number(:p_ctr_rec_old_value)))
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Organization, Attribute: Party Shipping Contact (PARTY_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                        AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                       AND okh.org_id = to_number(:update_level_value)';

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Party Billing Contact (PARTY_BILLING_CONTACT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                        AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''BILLING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                       AND okh.org_id = to_number(:update_level_value)';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Organization, Attribute: Party Shipping Contact (LINE_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                        AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                       AND okh.org_id = to_number(:update_level_value)';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Party Billing Contact (LINE_BILLING_CONTACT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                        AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_BILLING''
                          and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                       AND okh.org_id = to_number(:update_level_value)';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;


 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage Start Time (COVERAGE_START_TIME)
 --------------------------------------------------------
         ELSIF p_ctr_rec.attribute = 'COVERAGE_START_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.start_hour is null
                                         and   oct.start_minute is null)
                        AND okh.org_id = to_number(:update_level_value)';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND okh.org_id = to_number(:update_level_value)';
          END IF;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Coverage End Time (COVERAGE_END_TIME)
 --------------------------------------------------------
         ELSIF p_ctr_rec.attribute = 'COVERAGE_END_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.end_hour is null
                                         and   oct.end_minute is null)
                        AND okh.org_id = to_number(:update_level_value)';

         ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.end_minute = mod(to_number(:p_ctr_rec_old_value),60))
                        AND okh.org_id = to_number(:update_level_value)';
         END IF;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Resolution Time (RESOLUTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RESOLUTION_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '|| l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                 OR mon_duration IS NULL
                                 OR tue_duration IS NULL
                                 OR wed_duration IS NULL
                                 OR thu_duration IS NULL
                                 OR fri_duration IS NULL
                                 OR sat_duration IS NULL)
                        AND okh.authoring_org_id = to_number(:update_level_value)';


       -- Old Value: Other than NULL or ALL

          ELSE
              -- dbms_output.put_line('Inside else 111111');
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND okh.authoring_org_id = to_number(:update_level_value)';
          END IF;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Reaction Time (REACTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'REACTION_TIME' THEN

   -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
                       l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                               OR mon_duration IS NULL
                                               OR tue_duration IS NULL
                                               OR wed_duration IS NULL
                                               OR thu_duration IS NULL
                                               OR fri_duration IS NULL
                                               OR sat_duration IS NULL)
                        AND okh.authoring_org_id = to_number(:update_level_value)';
 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND okh.authoring_org_id = to_number(:update_level_value)';

          END IF;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Price List(PRICE_LIST)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRICE_LIST' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value'||
                        l_from||l_where||
                         ' AND  okh.price_list_id is NULL
                           AND okh.org_id = to_number(:update_level_value)';
       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                         l_from||l_where||
                         ' AND okh.org_id = to_number(:update_level_value)';

        -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.price_list_id = to_number(:p_ctr_rec_old_value)
                         AND okh.org_id = to_number(:update_level_value)';

          END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Known As (CONTRACT_ALIAS)
 ------------------------------------------------------------------------------------------
	   ELSIF p_ctr_rec.attribute = 'CONTRACT_ALIAS' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value '||
                       l_from||l_where||
                       'AND okh.cognomen IS NULL
     					AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL
             l_stmt := l_select||' ,okh.cognomen old_value'||
                       l_from||
                       l_where||' AND okh.org_id = to_number(:update_level_value)';

          ELSE
             l_stmt := l_select||', okh.cognomen old_value'||
                       l_from||
                       l_where||' AND okh.cognomen = :p_ctr_rec_old_value
     			        AND okh.org_id = to_number(:update_level_value)';
          END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Purchase Order Number (PO_NUMBER_BILL)
 ------------------------------------------------------------------------------------------
	   ELSIF p_ctr_rec.attribute = 'PO_NUMBER_BILL' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value '||
                       l_from||l_where||
                       'AND okh.cust_po_number IS NULL
                        AND ( okh.payment_instruction_type  Is Null Or okh.payment_instruction_type = ''PON'')
     					AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL
	     If p_ctr_rec.new_value is Null Then
                       l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.org_id = to_number(:update_level_value) AND okh.payment_instruction_type = ''PON''
                                 and okh.cust_po_number_req_yn <> ''Y''';

             Else
	              l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.payment_instruction_type = ''PON'' AND okh.org_id = to_number(:update_level_value)';
	    End If;
          ELSE
	    If p_ctr_rec.new_value is Null Then
             l_stmt := l_select||', okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
     					          AND okh.payment_instruction_type = ''PON'' AND okh.org_id = to_number(:update_level_value) and okh.cust_po_number_req_yn <> ''Y''';
	    Else
             l_stmt := l_select||', okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
     					         AND okh.payment_instruction_type = ''PON''  AND okh.org_id = to_number(:update_level_value)';



	    End If;


          END IF;


 -----------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: PO NUMBER Required(PO_REQUIRED_REN)
 -----------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PO_REQUIRED_REN' THEN


           IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       'AND okh.org_id = to_number(:update_level_value)';

     -- Old Value: Other than NULL or ALL
           ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.renewal_po_required,''N'') = :p_ctr_rec_old_value
                          AND okh.org_id = to_number(:update_level_value)';
           END IF ;

 --------------------------------------------------------
 --  Update Level : Organization , Attribute: Summary Print(SUMMARY_PRINT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SUMMARY_PRINT' THEN

       -- Old Value: ALL (-1111)

        IF p_ctr_rec.old_value = '-1111' THEN
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||'  , :l_old_value old_value'||
                      l_from||' ,oks_k_headers_v oksh '||
                      l_where||' AND oksh.chr_id = okh.id
                                 AND okh.org_id = to_number(:update_level_value)';


      -- Old Value: Other than NULL or ALL

        ELSE
              l_old_value := p_ctr_rec.old_value;
              l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.inv_print_profile,''N'') = :p_ctr_rec_old_value
                                   AND okh.org_id = to_number(:update_level_value)';

        END IF ;


 ------------------------------------------------------------------------------------------
  --  Update Level : Organization , Attribute: Contract Group (CONTRACT_GROUP)
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_GROUP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id is NULL
     					          AND okh.org_id = to_number(:update_level_value)';

         ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL

             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okh.org_id = to_number(:update_level_value)';

         ELSE
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id = to_number(:p_ctr_rec_old_value)
     					          AND okh.org_id = to_number(:update_level_value)';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Contract Start date(CONTRACT_START_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF p_ctr_rec.attribute = 'CONTRACT_START_DATE' Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract Start date as NULL
             l_stmt:= l_select||',to_char(okh.start_date) old_value '||
                      l_from||
                      l_where||' AND okh.start_date is NULL
                                 AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract Start date not NULL
             l_stmt:= l_select||',to_char(okh.start_date) old_value '||
                      l_from||
                      l_where||' AND trunc(okh.start_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
                                 AND okh.org_id = to_number(:update_level_value)';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Organization , Attribute: Contract Start date(CONTRACT_END_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF UPPER(p_ctr_rec.attribute) = UPPER('CONTRACT_END_DATE') Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract End date as NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND okh.end_date is NULL
						          AND okh.org_id = to_number(:update_level_value)';

          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract End date not NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.end_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
						          AND okh.org_id = to_number(:update_level_value)';
          END IF;
        END IF;

-----------------------------------
 --  Update Level : PARTY
 -----------------------------------

 ELSIF p_ctr_rec.update_level = 'OKX_PARTY' THEN

 --------------------------------------------------------
 --  Update Level : Party , Attribute: Revenue Account(REV_ACCT)
 --------------------------------------------------------
      IF p_ctr_rec.attribute = 'REV_ACCT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id is NULL)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in ( ''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in ( ''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';


          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where||' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id = to_number(:p_ctr_rec_old_value))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;

 ---------------------------------------------------------
 --  Update Level :  Party , Attribute: Payment Term (PAYMENT_TERM)
 --------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'PAYMENT_TERM' THEN


         IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from|| ' ,okc_k_party_roles_b okp1 '||
                       l_where||' AND  okh.PAYMENT_TERM_ID is NULL
                                  AND  okh.id = okp1.chr_id
                                  AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND  okp1.object1_id1 = :update_level_value ' ;

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where||'AND  okh.id = okp1.chr_id
                                 AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                 AND  okp1.object1_id1 = :update_level_value ' ;
 -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where|| ' AND  okh.payment_term_id = to_number(:p_ctr_rec_old_value)
                                   AND  okh.id = okp1.chr_id
                                   AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                   AND  okp1.object1_id1 = :update_level_value ' ;

          END IF;

-------------------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Contract Renewal Type(CON_RENEWAL_TYPE)
------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CON_RENEWAL_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where||
                       ' AND  okh.renewal_type_code is NULL
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value ' ;

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_old_value := p_ctr_rec.old_value;
                       l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where|| 'AND  okh.id = okp1.chr_id
                                  AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                                  AND  okp1.object1_id1 = :update_level_value ' ;

 -- Old Value: ERN
          ELSIF p_ctr_rec.old_value = 'ERN' then

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh ,okc_k_party_roles_b okp1'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = ''NSR''
                        AND ''ERN'' = :p_ctr_rec_old_value
                        AND oksh.ELECTRONIC_RENEWAL_FLAG =''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value ' ;

 -- Old Value: Other than NULL or ALL
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh ,okc_k_party_roles_b okp1'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = :p_ctr_rec_old_value
                        AND nvl(oksh.ELECTRONIC_RENEWAL_FLAG,''N'') <> ''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value ' ;

          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Business Process Price List (BP_PRICE_LIST)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'BP_PRICE_LIST' THEN

     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||' ,okc_k_party_roles_b okp1  '||
                        l_where|| 'AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21)
                                            AND cln.price_list_id is NULL)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value ';

     -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1  '||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value ';

     -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                      Where cln.dnz_chr_id = okh.id
                                      AND cln.lse_id in(3,16,21)
                                      AND cln.price_list_id = to_number(:p_ctr_rec_old_value))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value ';

          END IF;

 ---------------------------------------------------------
 --  Update Level :  Party , Attribute: Accounting Rule (ACCT_RULE)
 --------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'ACCT_RULE' THEN

      -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value' ||
                       l_from||' ,oks_k_headers_v oksh ,okc_k_party_roles_b okp1 '||
                        l_where|| 'AND oksh.chr_id = okh.id
                                   AND oksh.acct_rule_id IS NULL
                                   AND  okh.id = okp1.chr_id
                                   AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                   AND  okp1.object1_id1 = :update_level_value';
     -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh ,okc_k_party_roles_b okp1 '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND  okh.id = okp1.chr_id
                                  AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND  okp1.object1_id1 = :update_level_value';
     -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh ,okc_k_party_roles_b okp1 '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND oksh.acct_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND  okh.id = okp1.chr_id
                                  AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND  okp1.object1_id1 = :update_level_value';
          END IF;

 ---------------------------------------------------------
 --  Update Level :  Party , Attribute: Invoice Rule (INV_RULE)
 --------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'INV_RULE' THEN

       -- Old Value: NULL (-9999)
         IF  p_ctr_rec.old_value = '-9999' THEN

             l_stmt := l_select||' ,NULL old_value' ||
                       l_from||',okc_k_party_roles_b okp1 '||
                       l_where||
                             ' AND  okh.inv_rule_id IS NULL
                               AND  okh.id = okp1.chr_id
                               AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                               AND  okp1.object1_id1 = :update_level_value';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1 '||
                       l_where||
                             ' AND  okh.id = okp1.chr_id
                               AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                               AND  okp1.object1_id1 = :update_level_value';

       -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                       l_from||',okc_k_party_roles_b okp1 '||
                       l_where||
                             ' AND  okh.inv_rule_id = to_number(:p_ctr_rec_old_value)
                               AND  okh.id = okp1.chr_id
                               AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                               AND  okp1.object1_id1 = :update_level_value';

          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Coverage Type(COV_TYPE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V okl, oks_k_lines_v oksl
                                             WHERE okl.dnz_chr_id = okh.id
                                             AND oksl.cle_id = okl.id
                                             AND oksl.coverage_type is NULL )
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

        -- Old Value: ALL

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                 WHERE okl.dnz_chr_id = okh.id
                                 AND oksl.cle_id      = okl.id )
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

        -- Old Value: Other than NULL or ALL
          ELSE
              l_old_value := p_ctr_rec.old_value;
              l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||',okc_k_party_roles_v okp1'||
                        l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                  WHERE okl.dnz_chr_id   = okh.id
                                  AND oksl.cle_id        = okl.id
                                  AND oksl.coverage_type = :p_ctr_rec_old_value )
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;


 ---------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Coverage Type(COV_TIMEZONE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TIMEZONE' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||
                       ' AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                      WHERE ctz.dnz_chr_id = okh.id
                                      AND   ctz.timezone_id IS NULL )
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND   ctz.timezone_id IS NOT NULL )
                          AND  okh.id = okp1.chr_id
                          AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                          AND  okp1.object1_id1 = :update_level_value';
        -- Old Value: Other than NULL or ALL
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND  ctz.timezone_id = to_number(:p_ctr_rec_old_value))
                          AND  okh.id = okp1.chr_id
                          AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                          AND  okp1.object1_id1 = :update_level_value';

          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Coverage Type(PREF_ENGG)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PREF_ENGG' THEN

         IF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE'')
                                             AND  okh.id = okp1.chr_id
                                             AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                             AND  okp1.object1_id1 = :update_level_value';
                                 --            AND   okh.org_id = '||to_number(p_ctr_rec.update_level_value);
                                 --            AND   oco.object1_id1  = '''||p_ctr_rec.old_value||''')
                                 --            AND  okh.id = '||to_number(p_ctr_rec.update_level_value) ;

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND  okh.id = okp1.chr_id
                                             AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                             AND  okp1.object1_id1 = :update_level_value';
--                                             AND   okh.org_id = '||to_number(p_ctr_rec.update_level_value);
--                                             AND  okh.id = '||to_number(p_ctr_rec.update_level_value) ;
          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Coverage Type(RES_GROUP)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RES_GROUP' THEN

	     IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP'')
                                             AND   okh.id = okp1.chr_id
                                             AND   okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                             AND   okp1.object1_id1 = :update_level_value';
                                 --            AND   okh.org_id = '||to_number(p_ctr_rec.update_level_value);
                                 --            AND   oco.object1_id1  = '''||p_ctr_rec.old_value||''')
                                 --            AND  okh.id = '||to_number(p_ctr_rec.update_level_value) ;

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP''
                                             AND   oco.object1_id1  =  :p_ctr_rec_old_value)
                                             AND   okh.id = okp1.chr_id
                                             AND   okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                             AND   okp1.object1_id1 = :update_level_value';
                                            -- AND   okh.org_id = '||to_number(p_ctr_rec.update_level_value);
                                            -- AND   okh.id = '||to_number(p_ctr_rec.update_level_value) ;
          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Party, Attribute: Coverage Type(AGREEMENT_NAME)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'AGREEMENT_NAME' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_v okp1'||
                       l_where||'AND EXISTS (SELECT ''x'' from okc_governances_v ogv
                                             WHERE ogv.dnz_chr_id = okh.id
                                             AND   ogv.isa_agreement_id = :p_ctr_rec_old_value)
                                             AND   okh.id = okp1.chr_id
                                             AND   okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                             AND   okp1.object1_id1 = :update_level_value';

 ------------------------------------------------------------------------------------------
 --  Update Level :  Party , Attribute: Product Alias (PRODUCT_ALIAS)
 ------------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRODUCT_ALIAS' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id in (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen is NULL)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id in (7,8,9,10,11,18,25,35))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id in (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level :  Party , Attribute: Contract Line Ref(CONTRACT_LINE_REF)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_LINE_REF' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id in (1,12,14,19)
                                     AND   cle.cognomen is NULL)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id in (1,12,14,19))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||' ,okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id in (1,12,14,19)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;

 -----------------------------------------------------------------------
 --  Update Level :  Party, Attribute: Header Ship-to Address(HDR_SHIP_TO_ADDRESS)
 ------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_SHIP_TO_ADDRESS' THEN

      -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||',okc_k_party_roles_b okp1'||
                           l_where||' AND  okh.ship_to_site_use_id is NULL
                                  AND  okh.id = okp1.chr_id
                                  AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND  okp1.object1_id1 = :update_level_value';

       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.ship_to_site_use_id old_value' ||
                           l_from||',okc_k_party_roles_b okp1'||
                           l_where||' AND  okh.ship_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND  okh.id = okp1.chr_id
                                     AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                     AND  okp1.object1_id1 = :update_level_value';
         END IF;



 --------------------------------------------------------
 --  Update Level :  Party, Attribute: Header Bill-to Address(HDR_BILL_TO_ADDRESS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_BILL_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||',okc_k_party_roles_b okp1'||
                           l_where||
                                   ' AND  okh.bill_to_site_use_id is NULL
                                     AND  okh.id = okp1.chr_id
                                     AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                     AND  okp1.object1_id1 = :update_level_value';
       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.bill_to_site_use_id old_value' ||
                           l_from||',okc_k_party_roles_b okp1'||
                           l_where||
                                   ' AND  okh.bill_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND  okh.id = okp1.chr_id
                                     AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                     AND  okp1.object1_id1 = :update_level_value';
         END IF;


 --------------------------------------------------------
 --  Update Level :  Party, Attribute: Sales Rep (SALES_REP)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SALES_REP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||',okc_k_party_roles_b okp1, okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SALESPERSON''
                          and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND (EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                        OR EXISTS (Select ''x'' from oks_k_sales_credits_v osc
                                   Where osc.chr_id = okh.id
                                   and osc.ctc_id = to_number(:p_ctr_rec_old_value)))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';
          END IF;
 ----------------------------------------------------------------------------------------
 --  Update Level :  Party , Attribute: Party Shipping Contact (PARTY_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||',okc_k_party_roles_b okp1, okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';
          END IF;

 --------------------------------------------------------
 --  Update Level :  Party , Attribute: Party Billing Contact (PARTY_BILLING_CONTACT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||',okc_k_party_roles_b okp1, okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''BILLING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level :  Party , Attribute: Line Shipping Contact (LINE_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||',okc_k_party_roles_b okp1, okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';
          END IF;

 --------------------------------------------------------
 --  Update Level :  Party , Attribute: Line Billing Contact (LINE_BILLING_CONTACT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||',okc_k_party_roles_b okp1, okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_BILLING''
                          and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;



--------------------------------------------------------
 --  Update Level : Party , Attribute: Coverage Start Time (COVERAGE_START_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_START_TIME' THEN

    /*   -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                         where igs.dnz_chr_id = okh.id
                                         and   igs.start_hour is null
                                         and   igs.start_minute is null)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code = ''CUSTOMER''
                         AND  okp1.object1_id1 = :update_level_value';


          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                      where igs.dnz_chr_id = okh.id
                                      and   igs.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                      AND   igs.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in = ''CUSTOMER''
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;
          */

                 -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||
                       l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.start_hour is null
                                         and   oct.start_minute is null)
                        AND okh.org_id = to_number(:update_level_value)';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||
                       l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';
          END IF;



--------------------------------------------------------
 --  Update Level : Party , Attribute: Coverage Time (COVERAGE_END_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_END_TIME' THEN

  /*     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                         where igs.dnz_chr_id = okh.id
                                         and     igs.end_hour is null
                                         and   igs.end_minute is null)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code = ''CUSTOMER''
                         AND  okp1.object1_id1 = :update_level_value';


          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                      where igs.dnz_chr_id = okh.id
                                      and  igs.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                      AND   igs.end_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code = ''CUSTOMER''
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;
          */
        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||
                       l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.end_hour is null
                                         and   oct.end_minute is null)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

         ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_party_roles_b okp1 '||
                       l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.end_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';
         END IF;

 --------------------------------------------------------
 --  Update Level : Party , Attribute: Resolution Time (RESOLUTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RESOLUTION_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat,okc_k_party_roles_b okp1 '|| l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                 OR mon_duration IS NULL
                                 OR tue_duration IS NULL
                                 OR wed_duration IS NULL
                                 OR thu_duration IS NULL
                                 OR fri_duration IS NULL
                                 OR sat_duration IS NULL)
                         AND  okp1.dnz_chr_id = okh.id  And okp1.cle_id Is Null
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

 -- Old Value: Other than NULL or ALL

          ELSE
              -- dbms_output.put_line('Inside else 111111');
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat,okc_k_party_roles_b okp1 '||l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                         AND  okp1.dnz_chr_id = okh.id  And okp1.cle_id Is Null
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';
          END IF;

 --------------------------------------------------------
 --  Update Level : Party , Attribute: Reaction Time (REACTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'REACTION_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
                       l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat,okc_k_party_roles_b okp1 '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                               OR mon_duration IS NULL
                                               OR tue_duration IS NULL
                                               OR wed_duration IS NULL
                                               OR thu_duration IS NULL
                                               OR fri_duration IS NULL
                                               OR sat_duration IS NULL)
                        AND  okp1.dnz_chr_id = okh.id  And okp1.cle_id Is Null
                        AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                        AND  okp1.object1_id1 = :update_level_value';
         -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat,okc_k_party_roles_b okp1 '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND  okp1.dnz_chr_id = okh.id  And okp1.cle_id Is Null
                        AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                        AND  okp1.object1_id1 = :update_level_value';

          END IF;


 --------------------------------------------------------
 --  Update Level : Party , Attribute: Price List(PRICE_LIST)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRICE_LIST' THEN
       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value'||
                        l_from||' ,okc_k_party_roles_b okp1'||
                        l_where||
                         ' AND  okh.price_list_id is NULL
                           AND  okh.id = okp1.chr_id
                           AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                           AND  okp1.object1_id1 = :update_level_value';

       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1'||
                       l_where||
                         ' AND  okh.id = okp1.chr_id
                           AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                           AND  okp1.object1_id1 = :update_level_value';


        -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                       l_from||' ,okc_k_party_roles_b okp1'||
                       l_where||
                       ' AND  okh.price_list_id = to_number(:p_ctr_rec_old_value)
                         AND  okh.id = okp1.chr_id
                         AND  okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                         AND  okp1.object1_id1 = :update_level_value';

          END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Known As( CONTRACT_ALIAS )
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_ALIAS' THEN
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value '||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||'AND okh.cognomen IS NULL
                                 AND okh.id = okp1.chr_id
                                 AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                 AND okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL

             l_stmt := l_select||' ,okh.cognomen old_value'||
                       l_from||', okc_k_party_roles_b okp1 '||
                       l_where||' AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';

          ELSE
             l_stmt := l_select||', okh.cognomen  old_value'||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||' AND okh.cognomen = :p_ctr_rec_old_value
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
          END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Purchase Order Number (PO_NUMBER_BILL)
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'PO_NUMBER_BILL' THEN
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value '||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||'AND okh.cust_po_number IS NULL
                                 AND okh.id = okp1.chr_id
                                 AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                 AND ( okh.payment_instruction_type  Is Null Or okh.payment_instruction_type = ''PON'')
                                 AND okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL
             If p_ctr_rec.new_value Is Null Then
                l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||', okc_k_party_roles_b okp1 '||
                       l_where||' AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okh.payment_instruction_type = ''PON''
                                  AND okp1.object1_id1 = :update_level_value and okh.cust_po_number_req_yn <> ''Y''';
	     Else
                l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||', okc_k_party_roles_b okp1 '||
                       l_where||' AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okh.payment_instruction_type = ''PON''
                                  AND okp1.object1_id1 = :update_level_value';




	     End If;

          ELSE

	     If p_ctr_rec.new_value Is Null Then

                l_stmt := l_select||', okh.cust_po_number old_value'||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okh.payment_instruction_type = ''PON''
                                  AND okp1.object1_id1 = :update_level_value and okh.cust_po_number_req_yn <> ''Y''';
	     Else

                l_stmt := l_select||', okh.cust_po_number old_value'||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okh.payment_instruction_type = ''PON''
                                  AND okp1.object1_id1 = :update_level_value';



	     End If;

          END IF;

 -----------------------------------------------------------------------------
 --  Update Level : Party , Attribute: PO NUMBER Required(PO_REQUIRED_REN)
 -----------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PO_REQUIRED_REN' THEN


           IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||'AND okh.id = okp1.chr_id
                                AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                AND okp1.object1_id1 = :update_level_value';

     -- Old Value: Other than NULL or ALL
           ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||', okc_k_party_roles_b okp1 ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.renewal_po_required,''N'') = :p_ctr_rec_old_value
                                   AND okh.id = okp1.chr_id
                                   AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                   AND okp1.object1_id1 = :update_level_value';
           END IF ;

 --------------------------------------------------------
 --  Update Level : Party , Attribute: Summary Print(SUMMARY_PRINT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SUMMARY_PRINT' THEN

       -- Old Value:ALL (-1111)

        IF p_ctr_rec.old_value = '-1111' THEN
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                      l_from||', okc_k_party_roles_b okp1 ,oks_k_headers_v oksh '||
                      l_where||' AND oksh.chr_id = okh.id
                                 AND okh.id = okp1.chr_id
                                 AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                 AND okp1.object1_id1 = :update_level_value';


      -- Old Value: Other than NULL or ALL

        ELSE
              l_old_value := p_ctr_rec.old_value;
              l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||', okc_k_party_roles_b okp1 ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.inv_print_profile,''N'') = :p_ctr_rec_old_value
                                   AND okh.id = okp1.chr_id
                                   AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                   AND okp1.object1_id1 = :update_level_value';

        END IF ;

 ------------------------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Contract Group (CONTRACT_GROUP)
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_GROUP' THEN
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg, okc_k_party_roles_b okp1'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id is NULL
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
/*
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||',okc_k_party_roles_b okp1'||
                       l_where||' AND EXISTS (SELECT id from okc_k_headers_v a
                                    WHERE a.id = okh.id
                                    MINUS
                                    SELECT okg.included_chr_id
                                    FROM okc_k_groups_grpings_v okg
									WHERE okg.included_chr_id = okh.id)
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code = ''CUSTOMER''
                                  AND okp1.object1_id1 = :update_level_value';
*/

          ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL
             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg, okc_k_party_roles_b okp1'||
                       l_where||' AND okg.included_chr_id = okh.id
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
          ELSE

             l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg, okc_k_party_roles_b okp1'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id = to_number(:p_ctr_rec_old_value)
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Contract Start date (CONTRACT_START_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF p_ctr_rec.attribute = 'CONTRACT_START_DATE' Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract Start date as NULL
             l_stmt:= l_select||',to_char(okh.start_date) old_value '||
                      l_from||', okc_k_party_roles_b okp1'||
                      l_where||' AND okh.start_date is NULL
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract Start date not NULL
             l_stmt:= l_select||',to_char(okh.start_date) old_value '||
                      l_from||', okc_k_party_roles_b okp1'||
                      l_where||'  AND trunc(okh.start_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Party , Attribute: Contract End date (CONTRACT_END_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF p_ctr_rec.attribute = 'CONTRACT_END_DATE' Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract End date as NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||' AND okh.end_date is NULL
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';

          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract End date not NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||', okc_k_party_roles_b okp1'||
                       l_where||' AND trunc(okh.end_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
                                  AND okh.id = okp1.chr_id
                                  AND okp1.rle_code in (''CUSTOMER'',''SUBSCRIBER'')
                                  AND okp1.object1_id1 = :update_level_value';
           END IF;
        END IF;

 ----------------------------------
 --  Update Level : Category
 ----------------------------------

 ELSIF p_ctr_rec.update_level = 'OKS_K_CATEGORY' THEN


---------------------------------------------------------------------
 --  Update Level : Category , Attribute: Revenue Account(REV_ACCT)
 ---------------------------------------------------------------------
      IF p_ctr_rec.attribute = 'REV_ACCT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id is NULL)
                        AND  okh.scs_code = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id)
                        AND  okh.scs_code = :update_level_value';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id = to_number(:p_ctr_rec_old_value))
                        AND  okh.scs_code = :update_level_value';
          END IF;

 --------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Payment Term (PAYMENT_TERM)
 --------------------------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'PAYMENT_TERM' THEN

         IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                       ' AND  okh.PAYMENT_TERM_ID is NULL
                         AND  okh.scs_code = :update_level_value';

        -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                               'AND  okh.scs_code = :update_level_value';
       -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.payment_term_id = to_number(:p_ctr_rec_old_value)
                         AND  okh.scs_code = :update_level_value';

          END IF;

-------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Contract Renewal Type(CON_RENEWAL_TYPE)
------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CON_RENEWAL_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||
                       l_where||
                       ' AND  okh.renewal_type_code is NULL
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.scs_code = :update_level_value';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_old_value := p_ctr_rec.old_value;
                       l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where||
                              ' AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                                AND  okh.scs_code = :update_level_value';

 -- Old Value: ERN

          ELSIF p_ctr_rec.old_value = 'ERN' then
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                         AND okh.renewal_type_code = ''NSR''
                         AND ''ERN'' = :p_ctr_rec_old_value
                         AND oksh.ELECTRONIC_RENEWAL_FLAG = ''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.scs_code = :update_level_value';

 -- Old Value: Other than NULL or ALL

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                         AND okh.renewal_type_code = :p_ctr_rec_old_value
                         AND nvl(oksh.ELECTRONIC_RENEWAL_FLAG,''N'') <> ''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.scs_code = :update_level_value';
          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Business Process Price List (BP_PRICE_LIST)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'BP_PRICE_LIST' THEN

     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||
                        l_where|| 'AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21)
                                            AND cln.price_list_id is NULL)
                                   AND okh.scs_code = :update_level_value';

     -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21))
                                   AND  okh.scs_code = :update_level_value';

     -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                      Where cln.dnz_chr_id = okh.id
                                      AND cln.lse_id in(3,16,21)
                                      AND cln.price_list_id = to_number(:p_ctr_rec_old_value))
                                  AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Accounting Rule (ACCT_RULE)
 --------------------------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'ACCT_RULE' THEN

     -- Old Value: ALL (-9999)
 	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where|| 'AND oksh.chr_id = okh.id
                                   AND oksh.acct_rule_id IS NULL
                                   AND okh.scs_code = :update_level_value';
     -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND okh.scs_code = :update_level_value';
     -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND oksh.acct_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND okh.scs_code = :update_level_value';
          END IF;

--------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Invoice Rule (INV_RULE)
--------------------------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'INV_RULE' THEN


       -- Old Value: NULL (-9999)
         IF  p_ctr_rec.old_value = '-9999' THEN

             l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                             ' AND  okh.inv_rule_id IS NULL
                               AND  okh.scs_code = :update_level_value';

       -- Old Value: ALL (-1111)
         ELSIF p_ctr_rec.old_value = '-1111' THEN
                    l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                              l_from||l_where||
                                    ' AND  okh.scs_code = :update_level_value';

       -- Old Value: Other than NULL or ALL

          ELSE
                --errorout_n('in here'||l_select||l_from||l_where);

                l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                          l_from||l_where||
                                ' AND  okh.inv_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND  okh.scs_code = :update_level_value';
--errorout_n('in here'||l_stmt);
          END IF;

---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Type(COV_TYPE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TYPE' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V okl, oks_k_lines_v oksl
                                             WHERE okl.dnz_chr_id = okh.id
                                             AND oksl.cle_id = okl.id
                                             AND oksl.coverage_type is NULL )
                                             AND  okh.scs_code = :update_level_value';

        -- Old Value: ALL

          ELSIF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                          l_from||
                          l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                    WHERE okl.dnz_chr_id = okh.id
                                    AND oksl.cle_id = okl.id )
                                    AND  okh.scs_code = :update_level_value';
         -- Old Value: Other than NULL or ALL
          ELSE
                 l_old_value := p_ctr_rec.old_value;
                 l_stmt := l_select||' , :l_old_value old_value'||
                           l_from||
                           l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                     WHERE okl.dnz_chr_id = okh.id
                                     AND oksl.cle_id = okl.id
                                     AND oksl.coverage_type = :p_ctr_rec_old_value )
                                     AND  okh.scs_code = :update_level_value';

          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Time zone(COV_TIMEZONE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TIMEZONE' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                      WHERE ctz.dnz_chr_id = okh.id
                                      AND   ctz.timezone_id IS NULL )
                         AND  okh.scs_code = :update_level_value' ;

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND   ctz.timezone_id IS NOT NULL )
                                             AND  okh.scs_code = :update_level_value' ;
        -- Old Value: Other than NULL or ALL
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND  ctz.timezone_id = to_number(:p_ctr_rec_old_value))
                                             AND  okh.scs_code = :update_level_value' ;

          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Prferred Engineer (PREF_ENGG)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PREF_ENGG' THEN

	     IF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE'')
                                 AND  okh.scs_code = :update_level_value';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                 AND   okh.scs_code = :update_level_value';
          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Preferred Resource group(RES_GROUP)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RES_GROUP' THEN

	     IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP'')
                                             AND  okh.scs_code = :update_level_value';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND  okh.scs_code = :update_level_value';
          END IF;


 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Type(AGREEMENT_NAME)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'AGREEMENT_NAME' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from okc_governances_v ogv
                                             WHERE ogv.dnz_chr_id = okh.id
                                             AND   ogv.isa_agreement_id = :p_ctr_rec_old_value)
                                             AND   okh.scs_code=:update_level_value';

 ---------------------------------------------------------------------
 --  Update Level : Category , Attribute: Product Alias(PRODUCT_ALIAS)
 ---------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRODUCT_ALIAS' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen is NULL)
                        AND  okh.scs_code = :update_level_value';
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35))
                        AND  okh.scs_code = :update_level_value';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                        AND  okh.scs_code = :update_level_value';

          END IF;

 ---------------------------------------------------------
 --  Update Level : Category , Attribute: Contract Line Ref(CONTRACT_LINE_REF)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_LINE_REF' THEN

         IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen is NULL)
                        AND  okh.scs_code = :update_level_value';

         ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19))
                        AND  okh.scs_code = :update_level_value';
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                        AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Header Ship-to Address(HDR_SHIP_TO_ADDRESS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_SHIP_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                ' AND  okh.ship_to_site_use_id is NULL
                                  AND  okh.scs_code = :update_level_value';

       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.ship_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.ship_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND  okh.scs_code = :update_level_value';
         END IF;


 --------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Header Bill-to Address(HDR_BILL_TO_ADDRESS)
 --------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_BILL_TO_ADDRESS' THEN

        -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id is NULL
                                     AND  okh.scs_code = :update_level_value';
       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.bill_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND  okh.scs_code = :update_level_value';
         END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Sales Rep (SALES_REP)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SALES_REP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                        AND  okh.scs_code = :update_level_value';
          ELSIF p_ctr_rec.old_value = '-1111' THEN
              -- dbms_output.put_line('Inside else ALL SALES_REP');
             l_stmt := l_select||' ,oc.object1_id1 old_value '||
                       l_from||', okc_contacts oc '||
                       l_where||' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SALESPERSON''
                          and   oc.jtot_object1_code = ''OKX_SALEPERS''
                       AND  okh.scs_code = :update_level_value';
          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND (EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                         OR EXISTS (Select ''x'' from oks_k_sales_credits_v osc
                                   Where osc.chr_id = okh.id
                                   and osc.ctc_id = to_number(:p_ctr_rec_old_value)))
                         AND  okh.scs_code = :update_level_value';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Party Shipping Contact (PARTY_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                        AND  okh.scs_code = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                       AND  okh.scs_code = :update_level_value';


          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Party Billing Contact (PARTY_BILLING_CONTACT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                        AND  okh.scs_code = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''BILLING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                       AND  okh.scs_code = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND  okh.scs_code = :update_level_value';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Line Shipping Contact (LINE_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                        AND  okh.scs_code = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                       AND  okh.scs_code = :update_level_value';


          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Line Billing Contact (LINE_BILLING_CONTACT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                        AND  okh.scs_code= = :update_level_value';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_BILLING''
                          and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                       AND  okh.scs_code = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside billing else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1= :p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Time (COVERAGE_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                         where igs.dnz_chr_id = okh.id
                                         and   ((igs.start_hour is null
                                         and   igs.start_minute is null)
                                         OR
                                         (     igs.end_hour is null
                                         and   igs.end_minute is null))
                        AND  okh.scs_code = :update_level_value';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                      where igs.dnz_chr_id = okh.id
                                      and  (( igs.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                      AND   igs.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                                      OR
                                      ( igs.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                      AND   igs.end_minute = mod(to_number(:p_ctr_rec_old_value),60)))
                         AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Start Time (COVERAGE_START_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_START_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.start_hour is null
                                         and   oct.start_minute is null)
                        AND  okh.scs_code = :update_level_value';

          ELSE
       -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND  okh.scs_code = :update_level_value';
          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage End Time (COVERAGE_END_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_END_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.end_hour is null
                                         and   oct.end_minute is null)
                        AND  okh.scs_code = :update_level_value';

         ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.end_minute = mod(to_number(:p_ctr_rec_old_value),60))
                        AND  okh.scs_code = :update_level_value';
         END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Resolution Time (RESOLUTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RESOLUTION_TIME' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '|| l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                 OR mon_duration IS NULL
                                 OR tue_duration IS NULL
                                 OR wed_duration IS NULL
                                 OR thu_duration IS NULL
                                 OR fri_duration IS NULL
                                 OR sat_duration IS NULL)

                        AND  okh.scs_code = :update_level_value';
       -- Old Value: Other than NULL or ALL

          ELSE
              -- dbms_output.put_line('Inside else 111111');
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND  okh.scs_code = :update_level_value';
          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Reaction Time (REACTION_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'REACTION_TIME' THEN

   -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
                       l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                               OR mon_duration IS NULL
                                               OR tue_duration IS NULL
                                               OR wed_duration IS NULL
                                               OR thu_duration IS NULL
                                               OR fri_duration IS NULL
                                               OR sat_duration IS NULL)
                        AND  okh.scs_code = :update_level_value';
    -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND  okh.scs_code = :update_level_value';

          END IF;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Price List(PRICE_LIST)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRICE_LIST' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value'||
                        l_from||l_where||
                         ' AND  okh.price_list_id is NULL
                           AND okh.scs_code = :update_level_value';
       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                         l_from||l_where||
                         ' AND okh.scs_code = :update_level_value';
        -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.price_list_id = to_number(:p_ctr_rec_old_value)
                         AND okh.scs_code = :update_level_value';

          END IF;


 ------------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute:Known As (CONTRACT_ALIAS)
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_ALIAS' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value '||
                       l_from||
                       l_where||'AND okh.cognomen IS NULL
                                 AND okh.scs_code = :update_level_value';

         ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL

             l_stmt := l_select||' ,okh.cognomen old_value'||
                       l_from||
                       l_where||' AND okh.scs_code = :update_level_value';

         ELSE
             l_stmt := l_select||' ,okh.cognomen old_value'||
                       l_from||
                       l_where||' AND okh.cognomen = :p_ctr_rec_old_value
                                  AND okh.scs_code = :update_level_value';
         END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Purchase Order Number (PO_NUMBER_BILL)
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'PO_NUMBER_BILL' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value '||
                       l_from||
                       l_where||'AND okh.cust_po_number IS NULL
                                 AND ( okh.payment_instruction_type  Is Null Or okh.payment_instruction_type = ''PON'')
                                 AND okh.scs_code = :update_level_value';

         ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL
           If p_ctr_rec.new_value is Null Then
             l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.payment_instruction_type = ''PON'' AND okh.scs_code = :update_level_value and okh.cust_po_number_req_yn <> ''Y''';

           Else
	                l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||'AND okh.payment_instruction_type = ''PON'' AND okh.scs_code = :update_level_value ';

	   End If;
         ELSE
           If p_ctr_rec.new_value is Null Then

             l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
                                  AND okh.payment_instruction_type = ''PON''
                                  AND okh.scs_code = :update_level_value and okh.cust_po_number_req_yn <> ''Y''';

	   Else
             l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value AND okh.payment_instruction_type = ''PON''
                                 AND okh.scs_code = :update_level_value ';
	 End If;
         END IF;

 -----------------------------------------------------------------------------
 --  Update Level : Category , Attribute: PO NUMBER Required(PO_REQUIRED_REN)
 -----------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PO_REQUIRED_REN' THEN


           IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||
                       'AND okh.scs_code = :update_level_value';

     -- Old Value: Other than NULL or ALL
           ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.renewal_po_required,''N'') = :p_ctr_rec_old_value
                                   AND okh.scs_code = :update_level_value';
           END IF ;

 --------------------------------------------------------
 --  Update Level : Category , Attribute: Summary Print(SUMMARY_PRINT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SUMMARY_PRINT' THEN

       -- Old Value: ALL (-1111)
        IF p_ctr_rec.old_value = '-1111' THEN
            l_stmt := l_select||' , :l_old_value old_value'||
                      l_from||' ,oks_k_headers_v oksh '||
                      l_where||' AND oksh.chr_id = okh.id
                                 AND okh.scs_code = :update_level_value';


      -- Old Value: Other than NULL or ALL
        ELSE
              l_old_value := p_ctr_rec.old_value;
              l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.inv_print_profile,''N'') = :p_ctr_rec_old_value
                                   AND okh.scs_code = :update_level_value';

        END IF ;


 ------------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Contract Group (CONTRACT_GROUP)
 ------------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_GROUP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
              l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id is NULL
     					          AND okh.scs_code = :update_level_value';

 /*             l_stmt := l_select||' ,NULL old_value'||
                       l_from||
                       l_where||' AND EXISTS (SELECT id from okc_k_headers_v a
                                    WHERE a.id = okh.id
                                    MINUS
                                    SELECT okg.included_chr_id
                                    FROM okc_k_groups_grpings_v okg
									WHERE okg.included_chr_id = okh.id)
     					          AND okh.scs_code='''||p_ctr_rec.update_level_value||'''';
*/

          ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL
              l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okh.scs_code = :update_level_value';
          ELSE

              l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id = to_number(:p_ctr_rec_old_value)
     					          AND okh.scs_code = :update_level_value';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Contract Start date (CONTRACT_START_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF UPPER(p_ctr_rec.attribute) = UPPER('CONTRACT_START_DATE') Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract Start date as NULL
             l_stmt := l_select||',to_char(okh.start_date) old_value'||
                       l_from||
                       l_where||' AND okh.start_date is NULL
						          AND okh.scs_code = :update_level_value';
          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract Start date not NULL
             l_stmt := l_select||',to_char(okh.start_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.start_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
						          AND okh.scs_code = :update_level_value';
          END IF;

 ------------------------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Contract End date (CONTRACT_END_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF UPPER(p_ctr_rec.attribute) = UPPER('CONTRACT_END_DATE') Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract End date as NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND okh.end_date is NULL
						          AND okh.scs_code = :update_level_value';
          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract End date not NULL
             l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.end_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
						          AND okh.scs_code = :update_level_value';
          END IF;
        END IF;

 ----------------------------------------------------------------------------
 --  Update Level : Contract Group
 ----------------------------------------------------------------------------
 ELSIF p_ctr_rec.update_level = 'OKS_K_GROUP' THEN

 --------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Revenue Account(REV_ACCT)
 --------------------------------------------------------
      IF p_ctr_rec.attribute = 'REV_ACCT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id is NULL)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';


          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKS_REV_DISTRIBUTIONS_V rev
                                     WHERE rev.chr_id = okh.id
                                     AND   rev.code_combination_id  = to_number(:p_ctr_rec_old_value))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;


 ---------------------------------------------------------
 --  Update Level : Contract Group, Attribute: Payment Term (PAYMENT_TERM)
 --------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'PAYMENT_TERM' THEN


          IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                       ' AND  okh.PAYMENT_TERM_ID is NULL
                         AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;

        -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                               'AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;
       -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.payment_term_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.payment_term_id = to_number(:p_ctr_rec_old_value)
                         AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;

          END IF;

-------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Contract Renewal Type(CON_RENEWAL_TYPE)
------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CON_RENEWAL_TYPE' THEN

       -- Old Value: NULL (-9999)
	     IF    p_ctr_rec.old_value = '-9999' THEN

                       l_stmt := l_select||' ,NULL old_value' ||
                       l_from||
                       l_where||
                       ' AND  okh.renewal_type_code is NULL
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                       l_old_value := p_ctr_rec.old_value;
                       l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where||
                               ' AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                                 AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;
 -- Old Value: Other than NULL or ALL

          ELSIF p_ctr_rec.old_value = 'ERN' then

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = ''NSR''
                        AND ''ERN'' = :p_ctr_rec_old_value
                        AND oksh.ELECTRONIC_RENEWAL_FLAG =''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;

 -- Old Value: Other than NULL or ALL

          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||' ,oks_k_headers_b oksh'||
                       l_where||
                       ' AND oksh.chr_id = okh.id
                        AND  okh.renewal_type_code = :p_ctr_rec_old_value
                         AND nvl(oksh.ELECTRONIC_RENEWAL_FLAG,''N'') <>''Y''
                         AND not exists(
                                        select ol.object_chr_id
                                        from okc_operation_lines ol
                                            ,okc_operation_instances oi
                                            ,okc_class_operations co
                                        WHERE ol.object_chr_id = okh.id
                                          AND ol.process_flag = ''P''
                                          AND ol.ACTIVE_YN    = ''Y''
                                          AND oi.id = ol.oie_id
                                          AND oi.cop_id = co.id
                                          AND co.opn_code in (''RENEWAL'',''REN_CON'')
                                          AND co.CLS_CODE = ''SERVICE'')
                         AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)' ;

          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Business Process Price List (BP_PRICE_LIST)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'BP_PRICE_LIST' THEN

     -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||
                        l_where|| 'AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21)
                                            AND cln.price_list_id is NULL)
                                   AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

     -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                          Where cln.dnz_chr_id = okh.id
                                            AND cln.lse_id in(3,16,21))
                                   AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

     -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value' ||
                       l_from||
                       l_where|| ' AND exists ( Select dnz_chr_id from okc_k_lines_b cln
                                      Where cln.dnz_chr_id = okh.id
                                      AND cln.lse_id in(3,16,21)
                                      AND cln.price_list_id = to_number(:p_ctr_rec_old_value))
                                  AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

 ---------------------------------------------------------
 --  Update Level : Contract Group, Attribute: Accounting Rule (ACCT_RULE)
 --------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'ACCT_RULE' THEN

     -- Old Value: ALL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value' ||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where|| 'AND oksh.chr_id = okh.id
                                   AND oksh.acct_rule_id IS NULL
                                   AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                        WHERE okg1.included_chr_id is not null
                                        START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                        CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
     -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                        WHERE okg1.included_chr_id is not null
                                        START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                        CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
     -- Old Value: Other than NULL or ALL

          ELSE
             l_stmt := l_select||' ,oksh.acct_rule_id old_value' ||
                       l_from||' ,oks_k_headers_v oksh '||
                       l_where|| 'AND oksh.chr_id = okh.id
                                  AND oksh.acct_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                        WHERE okg1.included_chr_id is not null
                                        START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                        CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          END IF;


 ---------------------------------------------------------------------------
 --  Update Level : Contract Group, Attribute: Invoice Rule (INV_RULE)
 ---------------------------------------------------------------------------

      ELSIF p_ctr_rec.attribute = 'INV_RULE' THEN


        -- Old Value: NULL (-9999)
         IF  p_ctr_rec.old_value = '-9999' THEN

             l_stmt := l_select||' ,NULL old_value' ||
                       l_from||l_where||
                             ' AND  okh.inv_rule_id IS NULL
                               AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

         ELSIF p_ctr_rec.old_value = '-1111' THEN
                    l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                              l_from||l_where||
                                    ' AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

       -- Old Value: Other than NULL or ALL

          ELSE
                l_stmt := l_select||' ,okh.inv_rule_id old_value' ||
                          l_from||l_where||
                                ' AND  okh.inv_rule_id = to_number(:p_ctr_rec_old_value)
                                  AND  okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                   WHERE okg1.included_chr_id is not null
                                                   START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                   CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

---------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Coverage Type(COV_TYPE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TYPE' THEN

       -- Old Value: NULL (-9999)

        IF p_ctr_rec.old_value = '-9999' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V okl, oks_k_lines_v oksl
                                             WHERE okl.dnz_chr_id = okh.id
                                             AND oksl.cle_id      = okl.id
                                             AND oksl.coverage_type is NULL )
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

        -- Old Value: ALL

          ELSIF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                          l_from||
                          l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                    WHERE okl.dnz_chr_id = okh.id
                                    AND oksl.cle_id      = okl.id )
                                    AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

         -- Old Value: Other than NULL or ALL
          ELSE
                 l_old_value := p_ctr_rec.old_value;
                 l_stmt := l_select||' , :l_old_value old_value'||
                           l_from||
                           l_where||'AND EXISTS (SELECT ''x'' from okc_k_lines_v okl, oks_k_lines_v oksl
                                     WHERE okl.dnz_chr_id   = okh.id
                                     AND oksl.cle_id        = okl.id
                                     AND oksl.coverage_type = :p_ctr_rec_old_value )
                                     AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';


          END IF;

 ---------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Coverage Type(COV_TIMEZONE)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COV_TIMEZONE' THEN


        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                      WHERE ctz.dnz_chr_id = okh.id
                                      AND   ctz.timezone_id IS NULL )
                                      AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                      WHERE okg1.included_chr_id is not null
                                                      START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                      CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

       -- Old Value: ALL (-1111)
          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND   ctz.timezone_id IS NOT NULL )
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
        -- Old Value: Other than NULL or ALL
          ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from  oks_coverage_timezones_v ctz
                                             WHERE ctz.dnz_chr_id = okh.id
                                             AND  ctz.timezone_id = to_number(:p_ctr_rec_old_value))
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Type(PREF_ENGG)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PREF_ENGG' THEN

	     IF p_ctr_rec.old_value = '-1111' THEN

                l_old_value := p_ctr_rec.old_value;
                l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE'')
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''ENGINEER''
                                             AND   oco.jtot_object1_code = ''OKX_RESOURCE''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          END IF;
 ---------------------------------------------------------------------------
 --  Update Level : Category , Attribute: Coverage Type(RES_GROUP)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RES_GROUP' THEN

	     IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP'')
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from
                                             okc_contacts oco
                                             WHERE oco.dnz_chr_id = okh.id
                                             AND   oco.cro_code = ''RSC_GROUP''
                                             AND   oco.jtot_object1_code = ''OKS_RSCGROUP''
                                             AND   oco.object1_id1  = :p_ctr_rec_old_value)
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          END IF;



 ---------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Coverage Type(AGREEMENT_NAME)
 ---------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'AGREEMENT_NAME' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||'AND EXISTS (SELECT ''x'' from okc_governances_v ogv
                                             WHERE ogv.dnz_chr_id = okh.id
                                             AND   ogv.isa_agreement_id = :p_ctr_rec_old_value)
                                             AND okh.id in(  SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                             WHERE okg1.included_chr_id is not null
                                                             START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                             CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';



 --------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Product Alias(PRODUCT_ALIAS)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRODUCT_ALIAS' THEN

 	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen is NULL)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.dnz_chr_id = okh.id
                                     AND   cle.lse_id IN (7,8,9,10,11,18,25,35)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;
 --------------------------------------------------------
 --  Update Level :Contract Group , Attribute: Contract Line Ref(CONTRACT_LINE_REF)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'CONTRACT_LINE_REF' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen is NULL)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (SELECT ''x'' from OKC_K_LINES_V cle
                                     WHERE cle.chr_id = okh.id
                                     AND   cle.lse_id IN (1,12,14,19)
                                     AND   cle.cognomen = :p_ctr_rec_old_value)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

   -----------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Header Ship-to Address(HDR_SHIP_TO_ADDRESS)
 -------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_SHIP_TO_ADDRESS' THEN
       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                ' AND  okh.ship_to_site_use_id is NULL
                                  AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                 WHERE okg1.included_chr_id is not null
                                                 START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                 CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.ship_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.ship_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                 WHERE okg1.included_chr_id is not null
                                                 START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                 CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         END IF;

  ------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Header Bill-to Address(HDR_BILL_TO_ADDRESS)
 -------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'HDR_BILL_TO_ADDRESS' THEN

       -- Old Value: NULL (-9999)
	     IF  p_ctr_rec.old_value = '-9999' THEN
                 l_stmt := l_select||' ,NULL old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id is NULL
                                     AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                 WHERE okg1.included_chr_id is not null
                                                 START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                 CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
       -- Old Value: Other than NULL or ALL

         ELSE
                 l_stmt := l_select||' ,okh.bill_to_site_use_id old_value' ||
                           l_from||l_where||
                                   ' AND  okh.bill_to_site_use_id = to_number(:p_ctr_rec_old_value)
                                     AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                 WHERE okg1.included_chr_id is not null
                                                 START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                 CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         END IF;

 --------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Sales Rep(SALES_REP)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SALES_REP' THEN

         IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

           ELSIF p_ctr_rec.old_value = '-1111' THEN
              -- dbms_output.put_line('Inside else ALL SALES_REP');
             l_stmt := l_select||' ,oc.object1_id1 old_value '||
                       l_from||', okc_contacts oc '||
                       l_where||' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SALESPERSON''
                          and   oc.jtot_object1_code = ''OKX_SALEPERS''
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND (EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SALESPERSON''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_SALEPERS'')
                         OR EXISTS (Select ''x'' from oks_k_sales_credits_v osc
                                   Where osc.chr_id = okh.id
                                   and osc.ctc_id = to_number(:p_ctr_rec_old_value)))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

 ----------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Party Shipping Contact (PARTY_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''SHIPPING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

 ------------------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Party Billing Contact (PARTY_BILLING_CONTACT)
 ------------------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PARTY_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''BILLING''
                          and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''BILLING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_PCONTACT'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;
 ----------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Line Shipping Contact (LINE_SHIPPING_CONTACT)
 ----------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_SHIPPING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_SHIPPING''
                          and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_SHIPPING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTSHIP'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

 ------------------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Line Billing Contact (LINE_BILLING_CONTACT)
 ------------------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'LINE_BILLING_CONTACT' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1 is null
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             l_stmt := l_select||' ,oc.object1_id1 old_value'||
                       l_from||', okc_contacts oc '||
                       l_where||
                        ' and oc.dnz_chr_id = okh.id
                          and   oc.cro_code = ''CUST_BILLING''
                          and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_contacts oc
                                         where oc.dnz_chr_id = okh.id
                                         and   oc.cro_code = ''CUST_BILLING''
                                         and   oc.object1_id1=:p_ctr_rec_old_value
                                         and   oc.jtot_object1_code = ''OKX_CONTBILL'')
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

 ---------------------------------------------------------------------------------
 --  Update Level :Contract Group , Attribute: Coverage Time (COVERAGE_TIME)
 ---------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                         where igs.dnz_chr_id = okh.id
                                         and   ((igs.start_hour is null
                                         and   igs.start_minute is null)
                                         OR
                                         (     igs.end_hour is null
                                         and   igs.end_minute is null))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';


          ELSE
              -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from okc_time_ig_startend_val_v igs
                                      where igs.dnz_chr_id = okh.id
                                      and  (( igs.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                      AND   igs.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                                      OR
                                      ( igs.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                      AND   igs.end_minute = mod(to_number(:p_ctr_rec_old_value),60)))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;



   --------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Coverage Start Time (COVERAGE_START_TIME)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_START_TIME' THEN


       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.start_hour is null
                                         and   oct.start_minute is null)
                        AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';


          ELSE
       -- dbms_output.put_line('Inside else');
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.start_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.start_minute = mod(to_number(:p_ctr_rec_old_value),60))
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;

 ------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Coverage End Time (COVERAGE_END_TIME)
 --------------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'COVERAGE_END_TIME' THEN

       -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,NULL old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                         where oct.dnz_chr_id = okh.id
                                         and   oct.end_hour is null
                                         and   oct.end_minute is null)
                        AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

         ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||l_where||
                       ' AND EXISTS (Select ''x'' from oks_coverage_times_v oct
                                     where oct.dnz_chr_id = okh.id
                                     and   oct.end_hour = trunc(to_number(:p_ctr_rec_old_value)/60)
                                     and   oct.end_minute = mod(to_number(:p_ctr_rec_old_value),60))
                        AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         END IF;

-----------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Resolution Time (RESOLUTION_TIME)
-----------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'RESOLUTION_TIME' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '|| l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                 OR mon_duration IS NULL
                                 OR tue_duration IS NULL
                                 OR wed_duration IS NULL
                                 OR thu_duration IS NULL
                                 OR fri_duration IS NULL
                                 OR sat_duration IS NULL)

                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

       -- Old Value: Other than NULL or ALL

          ELSE
              -- dbms_output.put_line('Inside else 111111');
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RSN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                         AND okh.id in (SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          END IF;

 -------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Reaction Time (REACTION_TIME)
 -------------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'REACTION_TIME' THEN

   -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
                       l_stmt := l_select||', NULL old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       '  AND kl.dnz_chr_id = okh.id
		          AND kl.id = att.cle_id
                          And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration IS NULL
                                               OR mon_duration IS NULL
                                               OR tue_duration IS NULL
                                               OR wed_duration IS NULL
                                               OR thu_duration IS NULL
                                               OR fri_duration IS NULL
                                               OR sat_duration IS NULL)
                        AND okh.id in(SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
    -- Old Value: Other than NULL or ALL
          ELSE
             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||',okc_k_lines_b kl, oks_action_time_types_v att , oks_action_times_v oat '||l_where||
                       ' AND kl.dnz_chr_id = okh.id
		         AND kl.id = att.cle_id
                         And kl.lse_id in (4,17,22)
                         AND   att.action_type_code = ''RCN''
                         AND   att.id = oat.cov_action_type_id
                         AND   ( sun_duration = :p_ctr_rec_old_value
                                               OR mon_duration = :p_ctr_rec_old_value
                                               OR tue_duration = :p_ctr_rec_old_value
                                               OR wed_duration = :p_ctr_rec_old_value
                                               OR thu_duration = :p_ctr_rec_old_value
                                               OR fri_duration = :p_ctr_rec_old_value
                                               OR sat_duration = :p_ctr_rec_old_value)
                        AND okh.id in(SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                       WHERE okg1.included_chr_id is not null
                                       START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                       CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;
 -------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Price List(PRICE_LIST)
 -------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PRICE_LIST' THEN

        -- Old Value: NULL (-9999)
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL

              l_stmt := l_select||' ,NULL old_value'||
                        l_from||l_where||
                         ' AND  okh.price_list_id is NULL
                           AND okh.id in( SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                        WHERE okg1.included_chr_id is not null
                                        START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                        CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
       -- Old Value: ALL (-1111)

          ELSIF p_ctr_rec.old_value = '-1111' THEN

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                         l_from||l_where||
                         ' AND okh.id in( SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                        WHERE okg1.included_chr_id is not null
                                        START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                        CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
        -- Old Value: Other than NULL or ALL

          ELSE

             l_stmt := l_select||' ,okh.price_list_id old_value' ||
                       l_from||l_where||
                       ' AND  okh.price_list_id = to_number(:p_ctr_rec_old_value)
                         AND okh.id in( SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                        WHERE okg1.included_chr_id is not null
                                        START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                        CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

          END IF;
----------------------------------------------------------------------------
--  Update Level : Contract Group , Attribute: Known As (CONTRACT_ALIAS)
----------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_ALIAS' THEN
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,  NULL old_value'||
                       l_from||
                       l_where||' AND okh.cognomen IS NULL
                                  AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL

             l_stmt := l_select||' ,okh.cognomen old_value'||
                       l_from||
                       l_where||' AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         ELSE
             l_stmt := l_select||', okh.cognomen old_value'||
                       l_from||
                       l_where||' AND okh.cognomen = :p_ctr_rec_old_value
                                  AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

         END IF;

-------------------------------------------------------------------------------------
--  Update Level : Contract Group , Attribute: Purchase Order Number (PO_NUMBER_BILL)
-------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'PO_NUMBER_BILL' THEN
	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
             l_stmt := l_select||' ,  NULL old_value'||
                       l_from||
                       l_where||' AND okh.cust_po_number IS NULL
                                  AND ( okh.payment_instruction_type  Is Null Or okh.payment_instruction_type = ''PON'')
                                  AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         ELSIF p_ctr_rec.old_value = '-1111' THEN -- For old Value as ALL

	     If p_ctr_rec.new_value is null Then


                  l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||'   AND okh.payment_instruction_type = ''PON'' AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.inclued_cgp_id)
				  AND okh.cust_po_number_req_yn <> ''Y''';
		Else

		   l_stmt := l_select||' ,okh.cust_po_number old_value'||
                       l_from||
                       l_where||'  AND okh.payment_instruction_type = ''PON'' AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.inclued_cgp_id)';



		 End If;

         ELSE
	    If p_ctr_rec.new_value is null Then

                       l_stmt := l_select||' ,okh.cust_po_number old_value'||
                                 l_from||
                                 l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
                                            AND okh.payment_instruction_type = ''PON''
                                            AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)
					    And okh.cust_po_number_req_yn <> ''Y''';
	      Else

	                 l_stmt := l_select||' ,okh.cust_po_number old_value'||
                                 l_from||
                                 l_where||' AND okh.cust_po_number = :p_ctr_rec_old_value
                                            AND okh.payment_instruction_type = ''PON''
                                            AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
              End If;
         END IF;


 -----------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: PO NUMBER Required(PO_REQUIRED_REN)
 -----------------------------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'PO_REQUIRED_REN' THEN


           IF p_ctr_rec.old_value = '-1111' THEN

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                       l_from||
                       l_where||
                       'AND okh.id in(
                                               SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

     -- Old Value: Other than NULL or ALL
           ELSE

             l_old_value := p_ctr_rec.old_value;
             l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.renewal_po_required,''N'') = :p_ctr_rec_old_value
                                   AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
           END IF ;

 --------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Summary Print(SUMMARY_PRINT)
 --------------------------------------------------------
      ELSIF p_ctr_rec.attribute = 'SUMMARY_PRINT' THEN

       -- Old Value: All (-1111)

        IF p_ctr_rec.old_value = '-1111' THEN
            l_old_value := p_ctr_rec.old_value;
            l_stmt := l_select||' , :l_old_value old_value'||
                      l_from||' ,oks_k_headers_v oksh '||
                      l_where||' AND oksh.chr_id = okh.id
                                 AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';


      -- Old Value: Other than NULL or ALL

        ELSE
              l_old_value := p_ctr_rec.old_value;
              l_stmt := l_select||' , :l_old_value old_value'||
                        l_from||' ,oks_k_headers_v oksh '||
                        l_where||' AND oksh.chr_id = okh.id
                                   AND nvl(oksh.inv_print_profile,''N'') = :p_ctr_rec_old_value
                                   AND okh.id in(
                                                SELECT distinct okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';

        END IF ;


 ------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Contract Group(CONTRACT_GROUP)
 ------------------------------------------------------------------------------------

	   ELSIF p_ctr_rec.attribute = 'CONTRACT_GROUP' THEN

	     IF p_ctr_rec.old_value = '-9999' THEN   -- For old Value as NULL
        l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                  l_from||',okc_k_groups_grpings_v okg'||
                  l_where||' AND okg.included_chr_id = okh.id
     	                     AND okg.cgp_parent_id is NULL
                             AND okh.id in(
                                               SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
/*
              l_stmt := l_select||' ,NULL old_value'||
                       l_from||
                       l_where||' AND EXISTS (SELECT id from okc_k_headers_v a
                                    WHERE a.id = okh.id
                                    MINUS
                                    SELECT okg.included_chr_id
                                    FROM okc_k_groups_grpings_v okg
			       	    WHERE okg.included_chr_id = okh.id)
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = '||to_number(p_ctr_rec.update_level_value)||'
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
*/

          ELSIF p_ctr_rec.old_value = '-1111' THEN
             IF p_query_type = 'PROCESS' then
              l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
                                  AND (okg.cgp_parent_id in(
                                                SELECT okg1.included_cgp_id from  okc_k_grpings okg1
                                                WHERE okg1.included_cgp_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id))
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
             ELSIF p_query_type = 'FETCH' then
              l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
                                  AND (okg.cgp_parent_id = to_number(:update_level_value)
                                       OR okg.cgp_parent_id in(
                                                SELECT okg1.included_cgp_id from  okc_k_grpings okg1
                                                WHERE okg1.included_cgp_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id))
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
            END IF;
          ELSE
              l_stmt := l_select||' ,okg.cgp_parent_id old_value'||
                       l_from||',okc_k_groups_grpings_v okg'||
                       l_where||' AND okg.included_chr_id = okh.id
     					          AND okg.cgp_parent_id = to_number(:p_ctr_rec_old_value)
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
         END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Contract Start date(CONTRACT_START_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF UPPER(p_ctr_rec.attribute) = UPPER('CONTRACT_START_DATE') Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract Start date as NULL
              l_stmt := l_select||',to_char(okh.start_date) old_value'||
                       l_from||
                       l_where||' AND okh.start_date is NULL
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract Start date not NULL
              l_stmt := l_select||',to_char(okh.start_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.start_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          END IF;
 ------------------------------------------------------------------------------------------
 --  Update Level : Contract Group , Attribute: Contract End date (CONTRACT_END_DATE)
 ------------------------------------------------------------------------------------------

        ELSIF UPPER(p_ctr_rec.attribute) = UPPER('CONTRACT_END_DATE') Then

          IF p_ctr_rec.old_value is NULL THEN   -- For Contract End date as NULL
              l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND okh.end_date is NULL
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
          ELSIF p_ctr_rec.old_value is not NULL THEN   -- For Contract End date not NULL
              l_stmt := l_select||',to_char(okh.end_date) old_value'||
                       l_from||
                       l_where||' AND trunc(okh.end_date) = trunc(to_date(:p_ctr_rec_old_value,''YYYY/MM/DD HH24:MI:SS''))
                                  AND okh.id in(
                                                SELECT okg1.included_chr_id from  okc_k_grpings okg1
                                                WHERE okg1.included_chr_id is not null
                                                START WITH okg1.cgp_parent_id = to_number(:update_level_value)
                                                CONNECT BY okg1.cgp_parent_id = PRIOR okg1.included_cgp_id)';
           END IF;
        END IF;

 END IF;

--   dbms_output.put_line(' Starts') ;
  IF p_query_type = 'FETCH' THEN

     /*If fnd_profile.value('OKC_VIEW_K_BY_ORG') = 'Y' THEN
            l_org_id    := FND_PROFILE.VALUE('ORG_ID');
            l_org_where := ' AND okh.org_id  = :org_id' ;
            l_stmt      := l_stmt||l_org_where||' order by okh.contract_number' ;

--   dbms_output.put_line('Inside l_org_id:'||to_char(l_org_id)) ;

            IF p_ctr_rec.oie_id IS NOT NULL then
                  IF p_ctr_rec.old_value IN ('-1111', '-9999') THEN

	    	   IF p_ctr_rec.old_value = '-1111'
                       AND p_ctr_rec.attribute IN ('PO_REQUIRED_REN','SUMMARY_PRINT'
                             ,'CON_RENEWAL_TYPE','BP_PRICE_LIST','COV_TYPE','COV_TIMEZONE'
                             ,'PREF_ENGG','RES_GROUP' ) Then

	    	 	OPEN v_CurContract FOR l_stmt
	    	 	using l_old_value, p_ctr_rec.oie_id
	    	 	     , p_ctr_rec.update_level_value,l_org_id;
	    	   Else
	    	 	OPEN v_CurContract FOR l_stmt
	    	 	using p_ctr_rec.oie_id , p_ctr_rec.update_level_value,l_org_id;
	    	   End If;
                  ELSE
                        IF p_ctr_rec.attribute  IN ( 'COVERAGE_START_TIME'
                        ,'COVERAGE_END_TIME','SALES_REP') then
                               OPEN v_CurContract FOR l_stmt
                               using l_old_value, p_ctr_rec.oie_id ,
                                    p_ctr_rec.old_value, p_ctr_rec.old_value
                                    , p_ctr_rec.update_level_value ,l_org_id;
                        ELSIF p_ctr_rec.attribute IN( 'REACTION_TIME' , 'RESOLUTION_TIME') then
                           OPEN v_CurContract FOR l_stmt
                           using l_old_value, p_ctr_rec.oie_id , p_ctr_rec.old_value,
                               p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value
                               ,p_ctr_rec.old_value, p_ctr_rec.old_value,p_ctr_rec.old_value
                               ,p_ctr_rec.update_level_value,l_org_id;

                        ELSIF p_ctr_rec.attribute IN ('REV_ACCT','AGREEMENT_NAME','PRODUCT_ALIAS'
                              ,'CONTRACT_LINE_REF','PARTY_SHIPPING_CONTACT'
                              ,'PARTY_BILLING_CONTACT','LINE_SHIPPING_CONTACT','LINE_BILLING_CONTACT'
                              ,'PO_REQUIRED_REN','SUMMARY_PRINT','CON_RENEWAL_TYPE','BP_PRICE_LIST'
                              ,'COV_TYPE','COV_TIMEZONE', 'PREF_ENGG','RES_GROUP' ) Then
                             OPEN v_CurContract FOR l_stmt
                             using l_old_value, p_ctr_rec.oie_id ,
                                    p_ctr_rec.old_value, p_ctr_rec.update_level_value,l_org_id;

                        ELSE
                            OPEN v_CurContract FOR l_stmt using p_ctr_rec.oie_id ,
                             p_ctr_rec.old_value, p_ctr_rec.update_level_value,l_org_id;
                        END IF ;
                  END IF;
            ELSE -- *** p_ctr_rec.oie_id IS NULL ***
            --   dbms_output.put_line('Inside l_org_id else:') ;
                 IF p_ctr_rec.old_value IN ('-1111', '-9999') THEN

	    	      IF p_ctr_rec.old_value = '-1111'
                          AND p_ctr_rec.attribute IN ('PO_REQUIRED_REN','SUMMARY_PRINT'
                                ,'CON_RENEWAL_TYPE','BP_PRICE_LIST','COV_TYPE','COV_TIMEZONE'
                                ,'PREF_ENGG','RES_GROUP' ) Then
                             OPEN v_CurContract FOR l_stmt
                             using l_old_value, p_ctr_rec.update_level_value,l_org_id;
	    	      Else
                             OPEN v_CurContract FOR l_stmt
                             using p_ctr_rec.update_level_value,l_org_id;
	    	      End If;
                 ELSE
                       IF p_ctr_rec.attribute IN ( 'COVERAGE_START_TIME',
                          'COVERAGE_END_TIME','SALES_REP') then
                             OPEN v_CurContract FOR l_stmt
                             using l_old_value, p_ctr_rec.old_value,
                                   p_ctr_rec.old_value , p_ctr_rec.update_level_value,l_org_id;
                       ELSIF p_ctr_rec.attribute IN ( 'REACTION_TIME' , 'RESOLUTION_TIME') then
                               OPEN v_CurContract FOR l_stmt
                               using l_old_value, p_ctr_rec.old_value,
                                    p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                                    p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                                    p_ctr_rec.update_level_value,l_org_id;
                       ELSIF p_ctr_rec.attribute IN ('REV_ACCT','AGREEMENT_NAME','PRODUCT_ALIAS'
                                ,'CONTRACT_LINE_REF','PARTY_SHIPPING_CONTACT'
                                ,'PARTY_BILLING_CONTACT','LINE_SHIPPING_CONTACT','LINE_BILLING_CONTACT'
                                ,'PO_REQUIRED_REN','SUMMARY_PRINT','CON_RENEWAL_TYPE','BP_PRICE_LIST'
                                ,'COV_TYPE','COV_TIMEZONE', 'PREF_ENGG','RES_GROUP' ) Then
                            OPEN v_CurContract FOR l_stmt
                            using l_old_value, p_ctr_rec.old_value,
                                 p_ctr_rec.update_level_value,l_org_id;
                       ELSE
                            OPEN v_CurContract FOR l_stmt using p_ctr_rec.old_value,
                                 p_ctr_rec.update_level_value,l_org_id;
                       END IF ;
                 END IF;
            END IF;

     Else -- *** Org not enabled ***
     */
	  If p_ctr_rec.attribute  IN ('SALES_REP', 'REV_ACCT') Then
                l_org_id    := p_ctr_rec.ORG_ID ;
                l_org_where := ' AND okh.org_id  = :org_id' ;
                l_stmt      := l_stmt||l_org_where||' order by okh.contract_number' ;
          Else
                l_stmt      := l_stmt||' order by okh.contract_number' ;
          End If;

          IF p_ctr_rec.oie_id IS NOT NULL then

                 IF p_ctr_rec.old_value IN ('-1111', '-9999') THEN
	  	       IF p_ctr_rec.old_value = '-1111'
	  	          AND p_ctr_rec.attribute IN ('PO_REQUIRED_REN','SUMMARY_PRINT'
	  	              ,'CON_RENEWAL_TYPE','BP_PRICE_LIST','COV_TYPE','COV_TIMEZONE'
	  	              ,'PREF_ENGG','RES_GROUP' ) Then
                              OPEN v_CurContract FOR l_stmt
                              using l_old_value, p_ctr_rec.oie_id , p_ctr_rec.update_level_value;
	  	       Else
	  	              OPEN v_CurContract FOR l_stmt
	  	              using p_ctr_rec.oie_id , p_ctr_rec.update_level_value;
	  	       End If;
                 ELSE
                      IF p_ctr_rec.attribute IN ( 'COVERAGE_START_TIME','COVERAGE_END_TIME') then
                            OPEN v_CurContract FOR l_stmt
                            using l_old_value, p_ctr_rec.oie_id ,
                                  p_ctr_rec.old_value, p_ctr_rec.old_value
	                          , p_ctr_rec.update_level_value;
                      ELSIF p_ctr_rec.attribute = 'SALES_REP' then
                            OPEN v_CurContract FOR l_stmt
                            using l_old_value, p_ctr_rec.oie_id ,
                                  p_ctr_rec.old_value, p_ctr_rec.old_value
	                          , p_ctr_rec.update_level_value, l_org_id;
                      ELSIF p_ctr_rec.attribute = 'REV_ACCT' then
                           OPEN v_CurContract FOR l_stmt
                           using l_old_value, p_ctr_rec.oie_id ,
                           p_ctr_rec.old_value, p_ctr_rec.update_level_value, l_org_id;
                      ELSIF p_ctr_rec.attribute IN ( 'REACTION_TIME' , 'RESOLUTION_TIME') then
                          OPEN v_CurContract FOR l_stmt
	  	 	    using l_old_value, p_ctr_rec.oie_id , p_ctr_rec.old_value,
	  	 	    p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
	  	 	    p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.update_level_value;
                      ELSIF p_ctr_rec.attribute IN ( 'AGREEMENT_NAME','PRODUCT_ALIAS'
	  	 	    ,'CONTRACT_LINE_REF','PARTY_SHIPPING_CONTACT'
	  	 	    ,'PARTY_BILLING_CONTACT','LINE_SHIPPING_CONTACT','LINE_BILLING_CONTACT'
	  	 	    ,'PO_REQUIRED_REN','SUMMARY_PRINT','CON_RENEWAL_TYPE','BP_PRICE_LIST'
	  	 	    ,'COV_TYPE','COV_TIMEZONE', 'PREF_ENGG','RES_GROUP' ) Then
                           OPEN v_CurContract FOR l_stmt
                           using l_old_value, p_ctr_rec.oie_id ,
                           p_ctr_rec.old_value, p_ctr_rec.update_level_value;
                      ELSE
                           OPEN v_CurContract FOR l_stmt using p_ctr_rec.oie_id ,
                            p_ctr_rec.old_value, p_ctr_rec.update_level_value;
                      END IF ;
                 END IF;

          ELSE  -- *** p_ctr_rec.oie_id IS NULL ***

	       IF p_ctr_rec.old_value IN ('-1111', '-9999') THEN
	  	      IF p_ctr_rec.old_value = '-1111'
	  	      AND p_ctr_rec.attribute IN ('PO_REQUIRED_REN','SUMMARY_PRINT'
	  	          ,'CON_RENEWAL_TYPE','BP_PRICE_LIST','COV_TYPE','COV_TIMEZONE'
	  	          ,'PREF_ENGG','RES_GROUP' ) Then
	  	          OPEN v_CurContract FOR l_stmt
	  	          using l_old_value, p_ctr_rec.update_level_value;
	  	      Else
	  	          OPEN v_CurContract FOR l_stmt using p_ctr_rec.update_level_value;
	  	      End If;
               ELSE
                     IF p_ctr_rec.attribute IN ('COVERAGE_START_TIME','COVERAGE_END_TIME') then
	  	  	OPEN v_CurContract FOR l_stmt
	  	  	USING l_old_value, p_ctr_rec.old_value,
                                p_ctr_rec.old_value , p_ctr_rec.update_level_value;
                      ELSIF p_ctr_rec.attribute = 'SALES_REP' then
	  	  	OPEN v_CurContract FOR l_stmt
	  	  	USING l_old_value, p_ctr_rec.old_value,
                                p_ctr_rec.old_value , p_ctr_rec.update_level_value, l_org_id;
                      ELSIF p_ctr_rec.attribute = 'REV_ACCT' then
	  	  	OPEN v_CurContract FOR l_stmt
	  	  	USING l_old_value, p_ctr_rec.old_value,
	  	  	     p_ctr_rec.update_level_value, l_org_id;
                     ELSIF  p_ctr_rec.attribute  IN ( 'REACTION_TIME' , 'RESOLUTION_TIME' ) then
                         OPEN v_CurContract FOR l_stmt
	  	  	 using l_old_value, p_ctr_rec.old_value,
                                  p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                                  p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                                  p_ctr_rec.update_level_value;
                     ELSIF p_ctr_rec.attribute IN ('AGREEMENT_NAME','PRODUCT_ALIAS'
	  	  	,'CONTRACT_LINE_REF','PARTY_SHIPPING_CONTACT'
	  	  	,'PARTY_BILLING_CONTACT','LINE_SHIPPING_CONTACT','LINE_BILLING_CONTACT'
	  	  	,'PO_REQUIRED_REN','SUMMARY_PRINT','CON_RENEWAL_TYPE','BP_PRICE_LIST'
	  	  	,'COV_TYPE','COV_TIMEZONE', 'PREF_ENGG','RES_GROUP' ) Then
	  	  	OPEN v_CurContract FOR l_stmt
	  	  	USING l_old_value, p_ctr_rec.old_value,
	  	  	     p_ctr_rec.update_level_value;
                     ELSE
                          OPEN v_CurContract FOR l_stmt using p_ctr_rec.old_value,
                               p_ctr_rec.update_level_value;
                     END IF ;
               END IF;
          END IF; -- *** p_ctr_rec.oie_id IS NULL ?? ***
--   dbms_output.put_line(' Before End If ') ;
  --  End If; -- Org Enabled
	 i := 0;
	 LOOP
	    i := i +1;
	    FETCH v_CurContract INTO
		  x_eligible_contracts(i).CONTRACT_ID ,
                  x_eligible_contracts(i).CONTRACT_NUMBER ,
		  x_eligible_contracts(i).CONTRACT_NUMBER_MODIFIER,
		  x_eligible_contracts(i).START_DATE,
		  x_eligible_contracts(i).END_DATE,
		  x_eligible_contracts(i).SHORT_DESCRIPTION,
		  x_eligible_contracts(i).CONTRACT_STATUS,
		  x_eligible_contracts(i).PARTY ,
		  x_eligible_contracts(i).operating_unit,
		  x_eligible_contracts(i).billed_at_source,
                  x_eligible_contracts(i).OLD_VALUE  ;


	   EXIT WHEN v_CurContract%NOTFOUND;

           END LOOP;

         CLOSE v_CurContract;
         --errorout_n(x_eligible_contracts.count);
   ELSIF p_query_type = 'PROCESS' THEN

      /*If fnd_profile.value('OKC_VIEW_K_BY_ORG') = 'Y' THEN
          l_org_id    := FND_PROFILE.VALUE('ORG_ID');
          l_org_where := ' AND okh.org_id  = :org_id' ;
          l_stmt      := l_stmt||l_org_where ;

           IF p_ctr_rec.old_value IN ('-1111', '-9999') THEN
		IF p_ctr_rec.old_value = '-1111'
		AND p_ctr_rec.attribute IN ('PO_REQUIRED_REN','SUMMARY_PRINT'
		    ,'CON_RENEWAL_TYPE','BP_PRICE_LIST','COV_TYPE','COV_TIMEZONE'
		    ,'PREF_ENGG','RES_GROUP' ) Then

		    OPEN v_CurContract FOR l_stmt
		    using l_old_value, p_ctr_rec.oie_id ,
                          p_ctr_rec.update_level_value,l_org_id;
		Else
		    OPEN v_CurContract FOR l_stmt using p_ctr_rec.oie_id ,
                         p_ctr_rec.update_level_value,l_org_id;
		End If;
           ELSE
              IF p_ctr_rec.attribute  IN ('COVERAGE_START_TIME'
		 ,'COVERAGE_END_TIME', 'SALES_REP') then
                  OPEN v_CurContract FOR l_stmt
		  USING l_old_value, p_ctr_rec.oie_id ,p_ctr_rec.old_value,
                       p_ctr_rec.old_value , p_ctr_rec.update_level_value,l_org_id;
              ELSIF p_ctr_rec.attribute  IN ( 'REACTION_TIME' ,'RESOLUTION_TIME') then
                    OPEN v_CurContract FOR l_stmt
		    USING l_old_value, p_ctr_rec.oie_id, p_ctr_rec.old_value,
                         p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                         p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                         p_ctr_rec.update_level_value,l_org_id;
	      ELSIF p_ctr_rec.attribute IN ('REV_ACCT','AGREEMENT_NAME','PRODUCT_ALIAS'
			,'CONTRACT_LINE_REF','PARTY_SHIPPING_CONTACT'
			,'PARTY_BILLING_CONTACT','LINE_SHIPPING_CONTACT','LINE_BILLING_CONTACT'
			,'PO_REQUIRED_REN','SUMMARY_PRINT','CON_RENEWAL_TYPE','BP_PRICE_LIST'
			,'COV_TYPE','COV_TIMEZONE', 'PREF_ENGG','RES_GROUP' ) Then
                   OPEN v_CurContract FOR l_stmt
		   using l_old_value, p_ctr_rec.oie_id ,
                        p_ctr_rec.old_value,p_ctr_rec.update_level_value,l_org_id;
              ELSE
                   OPEN v_CurContract FOR l_stmt using p_ctr_rec.oie_id ,
                        p_ctr_rec.old_value,p_ctr_rec.update_level_value,l_org_id;
              END IF ;
           END IF;*/
      --Else  -- *** Org Not Enabled ***
	  If p_ctr_rec.attribute  IN ('SALES_REP', 'REV_ACCT') Then
                l_org_id    := p_ctr_rec.ORG_ID ;
                l_org_where := ' AND okh.org_id  = :org_id' ;
                l_stmt      := l_stmt||l_org_where ;
          End If;

           IF p_ctr_rec.old_value IN ('-1111', '-9999') THEN
		IF p_ctr_rec.old_value = '-1111'
		AND p_ctr_rec.attribute IN ('PO_REQUIRED_REN','SUMMARY_PRINT'
		    ,'CON_RENEWAL_TYPE','BP_PRICE_LIST','COV_TYPE','COV_TIMEZONE'
		    ,'PREF_ENGG','RES_GROUP' ) Then
		    OPEN v_CurContract FOR l_stmt using l_old_value, p_ctr_rec.oie_id ,
	                p_ctr_rec.update_level_value;
		Else
		    OPEN v_CurContract FOR l_stmt using p_ctr_rec.oie_id ,
	                p_ctr_rec.update_level_value;
		End If;
           ELSE
              IF p_ctr_rec.attribute  IN ('COVERAGE_START_TIME' , 'COVERAGE_END_TIME') then
                  OPEN v_CurContract FOR l_stmt
		  using l_old_value, p_ctr_rec.oie_id ,p_ctr_rec.old_value,
                       p_ctr_rec.old_value , p_ctr_rec.update_level_value;
              ELSIF p_ctr_rec.attribute  = 'SALES_REP' then
                  OPEN v_CurContract FOR l_stmt
		  using l_old_value, p_ctr_rec.oie_id ,p_ctr_rec.old_value,
                       p_ctr_rec.old_value , p_ctr_rec.update_level_value, l_org_id;
              ELSIF p_ctr_rec.attribute  = 'REV_ACCT' then
                   OPEN v_CurContract FOR l_stmt
		   USING l_old_value, p_ctr_rec.oie_id ,
                        p_ctr_rec.old_value, p_ctr_rec.update_level_value,l_org_id;
              ELSIF p_ctr_rec.attribute IN ('REACTION_TIME' , 'RESOLUTION_TIME') then
                    OPEN v_CurContract FOR l_stmt
		    using l_old_value, p_ctr_rec.oie_id, p_ctr_rec.old_value,
                         p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                         p_ctr_rec.old_value,p_ctr_rec.old_value,p_ctr_rec.old_value,
                         p_ctr_rec.update_level_value;
	      ELSIF p_ctr_rec.attribute IN ('AGREEMENT_NAME','PRODUCT_ALIAS'
			,'CONTRACT_LINE_REF','PARTY_SHIPPING_CONTACT'
			,'PARTY_BILLING_CONTACT','LINE_SHIPPING_CONTACT','LINE_BILLING_CONTACT'
			,'PO_REQUIRED_REN','SUMMARY_PRINT','CON_RENEWAL_TYPE','BP_PRICE_LIST'
			,'COV_TYPE','COV_TIMEZONE', 'PREF_ENGG','RES_GROUP' ) Then
                   OPEN v_CurContract FOR l_stmt
		   USING l_old_value, p_ctr_rec.oie_id ,
                        p_ctr_rec.old_value,p_ctr_rec.update_level_value;
              ELSE
                   OPEN v_CurContract FOR l_stmt using p_ctr_rec.oie_id ,
                        p_ctr_rec.old_value,p_ctr_rec.update_level_value;
              END IF ;
           END IF;
      --End If; -- Org Enabled
		 i := 0;
		 LOOP
		    i := i +1;
		    FETCH v_CurContract INTO
			  x_eligible_contracts(i).CONTRACT_ID,
			  x_eligible_contracts(i).CONTRACT_NUMBER ,
			  x_eligible_contracts(i).CONTRACT_NUMBER_MODIFIER,
			  x_eligible_contracts(i).START_DATE,
			  x_eligible_contracts(i).END_DATE,
			  x_eligible_contracts(i).SHORT_DESCRIPTION,
			  x_eligible_contracts(i).CONTRACT_STATUS,
                          x_eligible_contracts(i).qcl_id,
                          x_eligible_contracts(i).object_version_number,
                          x_eligible_contracts(i).ole_id,
                          x_eligible_contracts(i).org_id,
                          x_eligible_contracts(i).qa_check_yn,
                          x_eligible_contracts(i).operating_unit,
			  x_eligible_contracts(i).billed_at_source,
                          x_eligible_contracts(i).old_value;

		   EXIT WHEN v_CurContract%NOTFOUND;
         -- dbms_output.put_line('contract_id:'||to_number(x_eligible_contracts(i).CONTRACT_ID));
           END LOOP;
        CLOSE v_CurContract;
        --------------------------------
      END IF;
      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
	    NULL;
	 WHEN OTHERS THEN

	    OKC_API.SET_MESSAGE( p_app_name	=> G_APP_NAME_OKC
	    			         ,p_msg_name	=> G_UNEXPECTED_ERROR
				         ,p_token1		=> G_SQLCODE_TOKEN
				         ,p_token1_value	=> SQLcode
				         ,p_token2		=> G_SQLERRM_TOKEN
				         ,p_token2_value	=> SQLerrm);

--	  x_return_status := G_UNEXPECTED_ERROR;
      x_return_status :=  G_RET_STS_UNEXP_ERROR ;

  END get_eligible_contracts;

-----------------------------------------------------------------------------------------
--CALL THIS FUNCTION IF U WANT TO SUBMIT CONC REQ FROM THE FORM
-----------------------------------------------------------------------------------------

  FUNCTION SUBMIT_CONC_FORM(p_oie_id              IN NUMBER,
                            p_process_type        IN VARCHAR2,
                            p_schedule_time       IN VARCHAR2,
                            p_check_yn            IN VARCHAR2
                            ) RETURN NUMBER IS
  req_id NUMBER;
  l_mode BOOLEAN;
  e_msg Varchar2(2000);

  BEGIN
  l_mode := FND_REQUEST.SET_MODE(TRUE);

  -- Modified the follwing code the fix the translation issue.
  -- Removed the program description which was passed to FND API
  -- Original code is commented below. Bug#3347626

  IF p_schedule_time = 'ASAP' then
      req_id := FND_REQUEST.SUbmit_request('OKS'
                                           ,'OKSMSCHG'
                                           ,Null
                                           ,SYSDATE
                                           ,FALSE
                                           ,p_oie_id
                                           ,p_process_type
                                           ,p_check_yn);
  ELSIF (p_schedule_time IS not NULL) and (p_schedule_time <> 'ASAP' ) then
     req_id := FND_REQUEST.submit_request('OKS'
                                         ,'OKSMSCHG'
                                         ,Null
                                         ,p_schedule_time
                                         ,FALSE
                                         ,p_oie_id
                                         ,p_process_type
                                         ,p_check_yn);
  END IF;

--  IF p_schedule_time = 'ASAP' then
--      req_id := FND_REQUEST.submit_request('OKS'
--                                           ,'OKSMSCHG'
--                                           ,'Service Contracts Mass Change'
--                                           ,SYSDATE
--                                           ,FALSE
--                                           ,p_oie_id
--                                           ,p_process_type
--                                           ,p_check_yn);
--  ELSIF (p_schedule_time IS not NULL) and (p_schedule_time <> 'ASAP' ) then
--     req_id := FND_REQUEST.submit_request('OKS'
--                                         ,'OKSMSCHG'
--                                         ,'Service Contracts Mass Change'
--                                         ,p_schedule_time
--                                         ,FALSE
--                                         ,p_oie_id
--                                         ,p_process_type
--                                         ,p_check_yn);
--  END IF;


--      IF req_id <> 0 THEN
--            IF p_process_type = 'SUBMIT' THEN
--
--               UPDATE OKC_OPERATION_INSTANCES
--               SET request_id = req_id,
--                   status_code = 'UNDER_PROCESS'
--               WHERE id = p_oie_id;
--            ELSIF p_process_type = 'SUBMIT' THEN
--
--               UPDATE OKC_OPERATION_INSTANCES
--               SET request_id = req_id,
--                   status_code = 'UNDER_PREVIEW'
--               WHERE id = p_oie_id;
--            END IF;
--         COMMIT;
--     END IF;

    RETURN(req_id);

    EXCEPTION
           WHEN OTHERS THEN
           -- Add code for exception;
              NULL;

  END SUBMIT_CONC_FORM;

 PROCEDURE Notify_completion(p_process_type    IN Varchar2,
                             p_req_id          IN Number,
                             p_masschange_name IN Varchar2)IS
 BEGIN

       OKC_API.SET_MESSAGE(p_app_name	=> 'OKS',
			p_msg_name	=> 'OKS_MSCHG_NOTIFY_S',
			p_token1	=> 'PROCESS_TYPE',
			p_token1_value	=>  p_process_type,
			p_token2	=> 'REQUEST_ID',
			p_token2_value	=>  p_req_id,
			p_token3	=> 'MASSCHANGE_NAME',
			p_token3_value	=>  p_masschange_name);

    EXCEPTION
           WHEN OTHERS THEN
           -- Add code for exception;
              NULL;
 END Notify_completion;

 PROCEDURE SUBMIT_CONC(ERRBUF                         OUT NOCOPY VARCHAR2,
                       RETCODE                        OUT NOCOPY NUMBER,
                       p_oie_id                       IN NUMBER,
                       p_process_type                 IN VARCHAR2,
                       p_check_yn                     IN VARCHAR2 ) IS

  CURSOR get_oie_name IS
         SELECT name, usr.user_name
         FROM okc_operation_instances_v oie,
              fnd_user usr
         WHERE id = p_oie_id
         AND   oie.last_updated_by = usr.user_id;
  l_errbuf VARCHAR2(200);
  l_retcode NUMBER;
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) ;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;
  l_msg_index		NUMBER;

  l_cle_id          NUMBER;
  l_proc            VARCHAR(1000);
  l_oie_name        VARCHAR2(150);
  l_req_id          NUMBER;
  l_user_name       VARCHAR2(50);

 BEGIN

   l_init_msg_list :=  'T';

   IF p_process_type in ('SUBMIT','PREVIEW') THEN

        OKS_MASSCHANGE_PVT.SUBMIT
                           (   errbuf            => l_errbuf,
                               retcode           => l_retcode,
                               p_api_version	 => l_api_version,
    	                       p_init_msg_list	 => l_init_msg_list,
    	                       x_return_status 	 => l_return_status,
    	                       x_msg_count       => l_msg_count,
    	                       x_msg_data	 => l_msg_data,
                               p_conc_program    => 'Y',
                               p_process_type    => p_process_type,
                               p_oie_id          => p_oie_id,
                               p_check_yn        => p_check_yn );
   ELSE
          LOG_MESSAGES('Not a Valid Mass Change Process Type. Valid values are SUBMIT and PREVIEW');
   END IF;

       OPEN  get_oie_name;
       FETCH get_oie_name INTO l_oie_name, l_user_name;
       CLOSE get_oie_name;

        l_req_id := FND_GLOBAL.CONC_REQUEST_ID;

          LOG_MESSAGES('Name:'||l_oie_name||', request id#'||l_req_id);

          l_proc := 'BEGIN OKS_MASSCHANGE_PVT.Notify_completion('||
                 'p_process_type     =>'||''''||p_process_type||''''||
                 ',p_req_id          =>'||l_req_id||
                 ',p_masschange_name  =>'||''''||l_oie_name||''''||'); END ;';

--           l_proc := 'Begin
--                      OKS_MASSCHANGE_PVT.Notify_completion('''||p_process_type||''','||l_req_id||
--                  ','''||l_oie_name||''');
--                      End;';

          OKC_ASYNC_PUB.loop_call(
			        p_api_version       => l_api_version,
                 	        p_init_msg_list	    => l_init_msg_list,
    	                        x_return_status	    => l_return_status,
    	                        x_msg_count	    => l_msg_count,
    	                        x_msg_data          => l_msg_data,
        		   	p_proc	            => l_proc,
		        	p_s_recipient       => l_user_name );

        LOG_MESSAGES('OKC_ASYNC_PUB.loop_call status: '||l_return_status);
        fnd_msg_pub.get (p_msg_index     => -1,
                         p_encoded       => 'F',
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index_out);
          LOG_MESSAGES('Message:'||l_msg_data);

 END  SUBMIT_CONC;


 PROCEDURE SUBMIT_MASSCHANGE(ERRBUF                         OUT NOCOPY VARCHAR2,
                             RETCODE                        OUT NOCOPY NUMBER,
                             p_oie_id                       IN NUMBER,
                             p_check_yn                     IN  Varchar2 ) IS
  l_errbuf VARCHAR2(200);
  l_retcode NUMBER;
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;
  l_msg_index		NUMBER;

  l_cle_id NUMBER;

 BEGIN

       OKS_MASSCHANGE_PVT.SUBMIT_CONC(errbuf                  => l_errbuf,
                                      retcode                 => l_retcode,
                                      p_process_type          => 'SUBMIT',
                                      p_oie_id                => p_oie_id,
                                      p_check_yn              => p_check_yn ) ;

 END  SUBMIT_MASSCHANGE;

 PROCEDURE PREVIEW_MASSCHANGE(ERRBUF                         OUT NOCOPY VARCHAR2,
                              RETCODE                        OUT NOCOPY NUMBER,
                              p_oie_id                       IN NUMBER,
                              p_check_yn                     IN  Varchar2 ) IS
  l_errbuf VARCHAR2(200);
  l_retcode NUMBER;
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;
  l_msg_index		NUMBER;

  l_cle_id NUMBER;

 BEGIN

       OKS_MASSCHANGE_PVT.SUBMIT_CONC(errbuf                  => l_errbuf,
                                      retcode                 => l_retcode,
                                      p_process_type          => 'PREVIEW',
                                      p_oie_id                => p_oie_id,
                                      p_check_yn              => p_check_yn ) ;
 END  PREVIEW_MASSCHANGE;

-----------------------------------------------------------------------------------------
--SUBMIT
-----------------------------------------------------------------------------------------
 PROCEDURE SUBMIT(ERRBUF                         OUT NOCOPY VARCHAR2,
                  RETCODE                        OUT NOCOPY NUMBER,
                  p_api_version                  IN  NUMBER,
                  p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                  x_return_status                OUT NOCOPY VARCHAR2,
                  x_msg_count                    OUT NOCOPY NUMBER,
                  x_msg_data                     OUT NOCOPY VARCHAR2,
                  p_conc_program                 IN  VARCHAR2,
         	        p_process_type                 IN  Varchar2,
                  p_oie_id                       IN  NUMBER,
                  p_check_yn                     IN VARCHAR2)
     IS

     CURSOR get_criteria_cur IS
            SELECT oie.name,
                   oie.jtot_object1_code update_level,
                   oie.object1_id1 update_level_value,
                   omr.ATTRIBUTE_NAME attribute,
                   omr.OLD_VALUE old_value,
                   omr.NEW_VALUE new_value
            FROM   okc_operation_instances_v oie,
                   okc_masschange_req_dtls omr
            WHERE  oie.id = omr.oie_id
            AND    oie.id = p_oie_id;

   CURSOR Get_cgrp_id(p_chr_id IN Number, p_cgp_id IN Number) IS
            SELECT id
            FROM okc_k_grpings_v
            WHERE included_chr_id = p_chr_id
            AND   cgp_parent_id = p_cgp_id;

    CURSOR Get_cvr_start(p_chr_id IN Number, p_hour IN Number, p_minute IN Number ) IS
           SELECT oct.id,oct.OBJECT_VERSION_NUMBER,
                  oct.start_hour,oct.start_minute,oct.end_hour,oct.end_minute
           FROM oks_coverage_timezones_v ctz ,
                oks_coverage_times_v oct
           WHERE  oct.cov_tze_line_id = ctz.id
           AND    oct.dnz_chr_id = p_chr_id
           AND    oct.start_hour = p_hour
           AND    oct.start_minute = p_minute ;

    CURSOR Get_cvr_end(p_chr_id IN Number, p_hour IN Number, p_minute IN Number) IS
           SELECT oct.id ,oct.OBJECT_VERSION_NUMBER,
                  oct.start_hour,oct.start_minute,oct.end_hour,oct.end_minute
           FROM oks_coverage_timezones_v ctz ,
                oks_coverage_times_v oct
           WHERE  oct.cov_tze_line_id = ctz.id
           AND    oct.dnz_chr_id = p_chr_id
           AND    oct.end_hour = p_hour
           AND    oct.end_minute = p_minute ;

    -- The following cusrsor is for checking the coverage time overlap
    CURSOR Get_cvr_timezone(p_chr_id IN Number) IS
           SELECT oct.id id
           FROM   oks_coverage_timezones_V oct
           WHERE  oct.dnz_chr_id  = p_chr_id;

    CURSOR Get_timezone(p_chr_id IN Number , p_old_value IN Varchar2) IS
           SELECT oct.id id,oct.OBJECT_VERSION_NUMBER,oct.cle_id cle_id
           FROM   oks_coverage_timezones_V oct
           WHERE  oct.dnz_chr_id  = p_chr_id
           AND    oct.timezone_id = p_old_value ;

    CURSOR Get_Acct_Rule(p_chr_id IN Number, p_old_value IN Varchar2) IS
           SELECT oksh.id , oksh.object_version_number
           FROM   oks_k_headers_b oksh
           WHERE  oksh.chr_id = p_chr_id
           AND    oksh.acct_rule_id = p_old_value ;

    CURSOR Get_Summary_Print(p_chr_id IN Number, p_old_value IN Varchar2) IS
           SELECT oksh.id , oksh.object_version_number
           FROM   oks_k_headers_b oksh
           WHERE  oksh.chr_id = p_chr_id
           AND    nvl(oksh.inv_print_profile,'N') = p_old_value ;

    CURSOR Get_Electronic_Ren_YN(p_chr_id IN Number) IS
           SELECT oksh.id , oksh.object_version_number
           FROM   oks_k_headers_b oksh
           WHERE  oksh.chr_id = p_chr_id;

    CURSOR Get_po_required_ren(p_chr_id IN Number, p_old_value IN Varchar2) IS
           SELECT oksh.id , oksh.object_version_number
           FROM   oks_k_headers_v oksh
           WHERE  oksh.chr_id = p_chr_id
           AND    nvl(oksh.renewal_po_required,'N') = p_old_value ;

     CURSOR Get_agreement_name(p_chr_id IN Number, p_old_value IN Varchar2) IS
           SELECT ogv.id, ogv.object_version_number
           FROM   okc_governances_v ogv
           WHERE  ogv.dnz_chr_id = p_chr_id
           AND    ogv.isa_agreement_id = p_old_value ;

     CURSOR Get_contact(p_chr_id IN Number,p_cro_code IN Varchar2,
                        p_object_code IN Varchar2, p_old_value IN Varchar2) IS
           SELECT oc.id, oc.object_version_number, kh.start_date start_date
           FROM   okc_contacts oc , okc_k_headers_b kh
           WHERE  oc.dnz_chr_id = p_chr_id
           AND    oc.cro_code = p_cro_code
           AND    oc.object1_id1 = p_old_value
           AND    oc.jtot_object1_code = p_object_code
           And    Kh.id = oc.dnz_chr_id;

     CURSOR Get_revenue(p_chr_id IN Number, p_old_value IN Number) IS
           SELECT rev.id, rev.object_version_number
           FROM   oks_rev_distributions_v rev
           WHERE  rev.chr_id = p_chr_id
           AND    rev.code_combination_id = p_old_value;

     CURSOR Get_Salesrep(p_chr_id IN Number, p_old_value IN Varchar2) IS
           SELECT srv.id, srv.object_version_number, kh.start_date
           FROM   OKS_K_SALES_CREDITS_V srv
                 , Okc_k_headers_b Kh
           WHERE  srv.cle_id Is Null
           And    kh.id = p_chr_id
           And    kh.id = srv.chr_id
           AND    srv.ctc_id = to_number(p_old_value);


     CURSOR Get_LineSalesrep(p_chr_id IN Number, p_old_value IN Varchar2) IS
           SELECT srv.id, srv.object_version_number, kl.start_date
           FROM   OKS_K_SALES_CREDITS_V srv
                , Okc_k_lines_b Kl
           WHERE  srv.chr_id = p_chr_id
           And    srv.Cle_id Is nOt null
           And    Kl.id = srv.cle_id
           AND    srv.ctc_id = to_number(p_old_value);


     CURSOR Get_Inelligibles(p_oie_id IN Number) IS
	        SELECT okh.id,
                   okh.contract_number,
                   okh.contract_number_modifier,
                   okh.short_description,
                   okh.sts_code,
                   ole.id ole_id,
                   mrd.old_value,
		   okh.billed_at_source

            FROM  okc_k_headers_v okh,
                  okc_operation_lines_v ole,
                  okc_masschange_req_dtls_v mrd
      	    WHERE ole.select_yn = 'Y'
			AND   ole.process_flag is NULL
            AND   okh.id = ole.subject_chr_id
            AND   ole.id = mrd.ole_id
            AND   ole.oie_id = p_oie_id;

    /*
    ** Modified the cursor by adding date_cancelled
    ** condition as part of Line Level Cancelation project
    */
    CURSOR Get_lines_csr(p_chr_id IN NUMBER) IS
           SELECT okl.id id
           FROM   okc_k_lines_b okl
                 ,Oks_k_lines_b oks
           WHERE  okl.dnz_chr_id = p_chr_id
	     AND    okl.date_cancelled is NULL
           And    okl.id = oks.cle_id
           AND   ( okl.lse_id in (1,14,19,46)
           or   (okl.lse_id = 12 and oks.usage_type in ('FRT','NPR'))) ;

    CURSOR Get_cle_id (p_chr_id IN NUMBER) IS
           SELECT okl.id id
           FROM   okc_k_lines_b okl
           WHERE  okl.dnz_chr_id = p_chr_id
	     AND    okl.date_cancelled is NULL
           AND    okl.lse_id in (1,12,14,19,46) ;

    CURSOR Get_cle_id_PM ( p_cle_id IN NUMBER ) IS
           SELECT count(*) FROM oks_pm_schedules_v
           WHERE cle_id = p_cle_id;

    CURSOR Get_act_time ( p_chr_id IN NUMBER , p_action_type_code VARCHAR2
                 , p_old_value IN Varchar2) IS
           SELECT oat.id id ,oat.sun_duration ,oat.mon_duration ,oat.tue_duration ,oat.wed_duration,
                  oat.thu_duration ,oat.fri_duration, oat.sat_duration, oat.object_version_number
           FROM   OKC_K_LINES_V okl, oks_action_times oat , oks_action_time_types att
           WHERE  okl.dnz_chr_id     = p_chr_id
           AND    att.cle_id         = okl.id
           AND    att.action_type_code = p_action_type_code
           AND    oat.cov_action_type_id = att.id
           AND    (oat.sun_duration = p_old_value
                OR oat.mon_duration = p_old_value
                OR oat.tue_duration = p_old_value
                OR oat.wed_duration = p_old_value
                OR oat.thu_duration = p_old_value
                OR oat.fri_duration = p_old_value
                OR oat.sat_duration = p_old_value ) ;

     CURSOR Get_cov_type ( p_chr_id IN NUMBER , p_old_value IN Varchar2) IS
          SELECT osl.id , osl.object_version_number
          FROM   okc_k_lines_v okl, oks_k_lines_v osl
          WHERE  okl.id = osl.cle_id
          AND   okl.dnz_chr_id = p_chr_id
          AND   okl.lse_id in( 2,15,20)
          AND   osl.coverage_type = p_old_value  ;

     CURSOR get_bp_lines (p_chr_id IN Number,p_old_value in Varchar2) IS
           SELECT cln.id , cln.object_version_number
           FROM  okc_k_lines_b cln
           Where  cln.dnz_chr_id = p_chr_id
            AND cln.lse_id in(3,16,21)
            AND cln.price_list_id = p_old_value ;

     CURSOR get_bp_lines_all (p_chr_id IN Number) IS
           SELECT cln.id , cln.object_version_number
           FROM  okc_k_lines_b cln
           Where  cln.dnz_chr_id = p_chr_id
            AND cln.lse_id in(3,16,21);

     CURSOR get_bp_lines_null (p_chr_id IN Number) IS
           SELECT cln.id , cln.object_version_number
           FROM  okc_k_lines_b cln
           Where  cln.dnz_chr_id = p_chr_id
            AND cln.lse_id in(3,16,21)
            AND cln.price_list_id is null ;

     CURSOR get_contract_dtls (p_id IN Number) IS
	    Select okch.currency_code
	    From okc_k_headers_b okch
	    Where okch.id = p_id ;

   ---------------------
   -- Local variables --
   ---------------------
   -- Record types and Table types --
   ----------------------------------

    l_criteria_rec                criteria_rec_type;
    l_eligible_contracts_tbl      eligible_contracts_tbl;

    l_chrv_tbl_in                 okc_contract_pub.chrv_tbl_type;
    l_chrv_tbl_out                okc_contract_pub.chrv_tbl_type;

    l_chrv_rec_in                 okc_contract_pub.chrv_rec_type;
    l_chrv_rec_out                okc_contract_pub.chrv_rec_type;
    l_chrv_rec_null               okc_contract_pub.chrv_rec_type := Null;

    l_clev_tbl_in                 okc_contract_pub.clev_tbl_type;
    l_clev_tbl_out                okc_contract_pub.clev_tbl_type;

    l_khrv_rec_type_in            oks_contract_hdr_pub.khrv_rec_type ;
    l_khrv_rec_type_out           oks_contract_hdr_pub.khrv_rec_type ;

    l_cgcv_rec_in                 okc_contract_group_pub.cgcv_rec_type;
    l_cgcv_rec_out                okc_contract_group_pub.cgcv_rec_type;

    l_gvev_tbl_in                 okc_gve_pvt.gvev_tbl_type;
    l_gvev_tbl_out                okc_gve_pvt.gvev_tbl_type;

    l_rilv_tbl_in                 okc_ril_pvt.rilv_tbl_type;
    l_rilv_tbl_out                okc_ril_pvt.rilv_tbl_type;

    l_olev_rec_in                 okc_oper_inst_pub.olev_rec_type;
    l_olev_rec_out                okc_oper_inst_pub.olev_rec_type;

    l_oiev_rec_in                 okc_oper_inst_pub.oiev_rec_type;
    l_oiev_rec_out                okc_oper_inst_pub.oiev_rec_type;

    l_rulv_rec_in                 okc_rule_pub.rulv_rec_type;
    l_rulv_rec_out                okc_rule_pub.rulv_rec_type;

    l_rulv_tbl_in                 okc_rule_pub.rulv_tbl_type;
    l_rulv_tbl_out                okc_rule_pub.rulv_tbl_type;

    l_ctz_recType_in              oks_ctz_pvt.OksCoverageTimezonesVRecType ;
    l_ctz_recType_out             oks_ctz_pvt.OksCoverageTimezonesVRecType ;

    l_ctz_tblType_in              oks_ctz_pvt.OksCoverageTimezonesVTblType ;
    l_ctz_tblType_out             oks_ctz_pvt.OksCoverageTimezonesVTblType ;

    l_act_rec_in                  oks_acm_pvt.oks_action_times_v_rec_type ;
    l_act_rec_out                 oks_acm_pvt.oks_action_times_v_rec_type ;

    l_act_tbl_in                  oks_acm_pvt.oks_action_times_v_tbl_type ;
    l_act_tbl_out                 oks_acm_pvt.oks_action_times_v_tbl_type ;

    l_klnv_tbl_type_in            oks_contract_line_pub.klnv_tbl_type ;
    l_klnv_tbl_type_out           oks_contract_line_pub.klnv_tbl_type ;

    l_ctcv_rec_in                 okc_ctc_pvt.ctcv_rec_type;
    l_ctcv_rec_out                okc_ctc_pvt.ctcv_rec_type;

    l_ctcv_tbl_in                 okc_ctc_pvt.ctcv_tbl_type;
    l_ctcv_tbl_out                okc_ctc_pvt.ctcv_tbl_type;

    l_rdsv_rec_in                 oks_rev_distr_pub.rdsv_rec_type;
    l_rdsv_rec_out                oks_rev_distr_pub.rdsv_rec_type;

    -- This table type is not used in the API.
    -- l_igsv_ext_tbl_in          okc_time_pub.igsv_ext_tbl_type;
    -- l_igsv_ext_tbl_out         okc_time_pub.igsv_ext_tbl_type;

    l_cvt_tbl_in                  oks_cvt_pvt.oks_coverage_times_v_tbl_type ;
    l_cvt_tbl_out                 oks_cvt_pvt.oks_coverage_times_v_tbl_type ;

    l_scrv_tbl_in                 oks_sales_credit_pub.scrv_tbl_type;
    l_scrv_tbl_out                oks_sales_credit_pub.scrv_tbl_type;

    l_msg_tbl                     OKC_QA_CHECK_PUB.msg_tbl_type;

    l_overlap_type                oks_coverages_pvt.billrate_day_overlap_type;


    l_count_pm_schedule           NUMBER  ;
    l_api_version	          CONSTANT	NUMBER	:= 1.0;
    l_init_msg_list	          VARCHAR2(2000) ;
    l_return_status	          VARCHAR2(1);
    l_msg_count		          NUMBER;
    l_msg_data		          VARCHAR2(4000);
    l_restricted_update	          VARCHAR2(100)  ;
    l_msg_index_out	          NUMBER;
    l_can_update_yn               VARCHAR2(1);
    l_can_submit_yn               VARCHAR2(1);
    l_notelligible_exception      Exception ;

    l_timezone_exists_yn          Varchar2(3);
    l_time_zone_id                Number ;

    l_cov_time_wrong              NUMBER ;
    l_cov_time_right              NUMBER ;

    cvr_cnt                       Number ;
    srv_cnt                       Number ;
    rcn_cnt                       Number ;
    cnt                           Number ;
    l_masschange_name             VARCHAR2(150);
    l_update_level_code           VARCHAR2(300);
    l_update_level_value_id       VARCHAR2(300);
    l_update_level                VARCHAR2(360);
    l_update_level_value          VARCHAR2(360);
    l_attribute_code              VARCHAR2(50);
    l_old_value_id                VARCHAR2(240);
    l_new_value_id                VARCHAR2(240);
    l_old_value_id_tmp            VARCHAR2(240); -- Created for Sales Person/Revenue Account
    l_org_id		          Number;
    l_start_date                  Date;

    l_hour                        Number;
    l_minute                      Number;

    l_attribute                   VARCHAR2(100);
    l_old_value                   VARCHAR2(300);
    l_new_value                   VARCHAR2(300);

    l_old_name                    VARCHAR2(300);
    l_new_name                    VARCHAR2(300);

    l_old_k_amount                Number;
    l_new_k_amount                Number;
    l_amt_message                 VARCHAR2(500);


    l_process_flag                VARCHAR2(30);
    l_cgrp_id                     NUMBER;
    l_status                      VARCHAR2(30) ;
    l_opn_status                  VARCHAR2(10) ;
    l_success_cnt                 Number ;
    l_error_cnt                   Number ;
    l_message                     VARCHAR2(4000) ;
    l_test                        varchar2(100);
    x_test_chr_id                 NUMBER ;

    l_warranty_flag               Varchar2(3);
    l_sts_code                    OKC_STATUSES_B.CODE%Type;

    l_empty_string1               Varchar2(500);
    l_dash_string1                Varchar2(500);
    l_process_type_msg_seed       Varchar2(100);

    l_currency_code               Varchar2(100);
    l_pricelist_valid             Varchar2(100);

    l_billed_at_source_msg	  Varchar2(100);


    TYPE l_outfile_succ_rec IS RECORD (ID         NUMBER,
                                  String1    Varchar2(4000),
                                  String2    Varchar2(4000),
                                  String3    Varchar2(4000)
                                  );
    TYPE l_outfile_succ_tbl IS TABLE OF l_outfile_succ_rec INDEX BY BINARY_INTEGER;

    l_outfiles_succ l_outfile_succ_tbl;
    l_outfile_success_id          NUMBER  ;
    l_succ_count                  NUMBER  ;

    TYPE l_outfile_fail_rec IS RECORD (ID         NUMBER,
                                  String1    Varchar2(4000),
                                  String2    Varchar2(4000),
                                  String3    Varchar2(4000)
                                  );
    TYPE l_outfile_fail_tbl IS TABLE OF l_outfile_fail_rec INDEX BY BINARY_INTEGER;

    l_outfiles_fail l_outfile_fail_tbl;
    l_outfile_fail_id             NUMBER  ;
    l_fail_count                  NUMBER  ;

    TYPE l_outfile_inel_rec IS RECORD (ID         NUMBER,
                                  String1    Varchar2(4000),
                                  String2    Varchar2(4000),
                                  String3    Varchar2(4000)
                                  );
    TYPE l_outfile_inel_tbl IS TABLE OF l_outfile_inel_rec INDEX BY BINARY_INTEGER;

    l_outfiles_inel l_outfile_inel_tbl;
    l_outfile_inel_id             NUMBER  ;
    l_inel_count                  NUMBER  ;
    l_total_rec_count             NUMBER  ;

 -----------------------------------
 -- Local Procedure and Functions --
 -----------------------------------

   PROCEDURE Get_contract_lines(p_chr_id IN Number,
                                p_attr   IN Varchar2,
                                p_old_value IN Varchar2,
                                p_new_value IN Varchar2,
                                x_return_status OUT NOCOPY Varchar2,
                                x_clev_tbl  OUT NOCOPY okc_contract_pub.clev_tbl_type)
   AS
	   TYPE t_cont_lines IS REF CURSOR;

	   v_CurContLine            t_cont_lines;
        l_cle_id                 Number;
        l_lse_id                 Number;
        l_object_version_number  Number;
	   l_stmt                   Varchar2(10000);
        i                        NUMBER  ;
   BEGIN

          i := 1;
          x_return_status := G_RET_STS_SUCCESS;

	  /*
	  ** Modified the sql by adding date_cancelled condition
	  ** to take care of Line Level Cancelation project
	  */

          l_stmt:= 'SELECT cle.id,object_version_number,lse_id FROM  okc_k_lines_v cle
                    WHERE  cle.date_cancelled is NULL
		      AND  cle.dnz_chr_id = :p_chr_id';

        IF p_attr = 'CONTRACT_START_DATE' then

           IF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                   to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(cle.start_date) < trunc(to_date(:p_new_value,''YYYY/MM/DD HH24:MI:SS''))';
           ELSIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                  to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(cle.start_date) = trunc(to_date(:p_old_value,''YYYY/MM/DD HH24:MI:SS''))';
           END IF;
-- Added Order by clause to fix Bug#3522891.
-- Parent line should be processed before the child line
             l_stmt := l_stmt||' Order by cle.lse_id' ;

        ELSIF p_attr = 'CONTRACT_END_DATE' then
           IF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                  to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(cle.end_date) > trunc(to_date(:p_new_value,''YYYY/MM/DD HH24:MI:SS''))';
           ELSIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                 to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(cle.end_date) = trunc(to_date(:p_old_value,''YYYY/MM/DD HH24:MI:SS''))';
           END IF;
-- Added Order by clause to fix Bug#3522891.
-- Parent line should be processed before the child line
             l_stmt := l_stmt||' Order by cle.lse_id' ;

        ELSIF p_attr = 'CONTRACT_LINE_REF' then
           -- IF p_old_value is NULL then
            IF p_old_value ='-9999' then
            l_stmt := l_stmt||' AND cle.cognomen is NULL
                                AND cle.lse_id in (1,12,14,19)';
            ELSIF p_old_value ='-1111' then
            l_stmt := l_stmt||' AND cle.lse_id in (1,12,14,19)';
            ELSE
            l_stmt := l_stmt||' AND cle.cognomen = :p_old_value
                                AND cle.lse_id  in (1,12,14,19)';
            END IF;
        ELSIF p_attr = 'PRODUCT_ALIAS' then
             -- IF p_old_value is NULL then
            IF p_old_value ='-9999' then
            l_stmt := l_stmt||' AND cle.cognomen is NULL
                                AND cle.lse_id in (9,18,25)';
            ELSIF p_old_value = '-1111' then
            l_stmt := l_stmt||' AND cle.lse_id in (9,18,25)';
            ELSE
            l_stmt := l_stmt||' AND cle.cognomen = :p_old_value
                                AND cle.lse_id in (9,18,25)';
            END IF;
        END IF;
        		    i := 0;
                 LOG_MESSAGES('l_stmt: '||l_stmt);

              If p_attr in ('CONTRACT_LINE_REF', 'PRODUCT_ALIAS') Then
                /* Fixed byug 5247361 */
                 If p_old_value in ('-1111','-9999') Then
                      OPEN v_CurContLine FOR l_stmt using p_chr_id;
                  Else

                      OPEN v_CurContLine FOR l_stmt using p_chr_id,p_old_value;
                  End If;
	        Elsif p_attr = ('CONTRACT_END_DATE') Then
                       If to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                       to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') Then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_new_value;
                       ElsIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                       to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_old_value;
                       End If;

              ElsIf p_attr = ('CONTRACT_START_DATE') Then
                       If to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                       to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') Then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_old_value;
                      ElsIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                      to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_new_value;
                      End If;

                End If;
	           	LOOP
        		    i := i +1;
                            l_cle_id := NULL;
		            FETCH v_CurContLine INTO l_cle_id, l_object_version_number, l_lse_id;
                      IF l_cle_id is NOT NULL THEN
	       		    x_clev_tbl(i).ID                    := l_cle_id;
	       		    x_clev_tbl(i).object_version_number := l_object_version_number;
	       		    x_clev_tbl(i).lse_id                := l_lse_id;

                      END IF;
        		  EXIT WHEN v_CurContLine%NOTFOUND;
                          LOG_MESSAGES('x_clev_tbl(i).ID:'||x_clev_tbl(i).ID);
                END LOOP;
                CLOSE v_CurContLine;

                LOG_MESSAGES('Get_contract_lines return_status:'||x_return_status);
        EXCEPTION WHEN OTHERS
        then
           x_return_status := G_RET_STS_UNEXP_ERROR;
           LOG_MESSAGES('ERROR In Get_contract_lines for chr_id '||p_chr_id||' : '||SQLERRM);
                 LOG_MESSAGES('l_stmt: '||l_stmt);

  END Get_contract_lines;


-- Added Vigandhi
-- Fix bug 5075961
-- To get the oks top lines and covered lines to update the invoice text

   PROCEDURE Get_oks_contract_lines(
                                p_chr_id IN Number,
                                p_attr   IN Varchar2,
                                p_old_value IN Varchar2,
                                p_new_value IN Varchar2,
                                x_return_status OUT NOCOPY Varchar2,
                                x_clev_tbl  OUT NOCOPY oks_contract_line_pub.klnv_tbl_type)
   AS
	   TYPE t_cont_lines IS REF CURSOR;

	   v_CurContLine            t_cont_lines;
        l_cle_id                 Number;
        l_object_version_number  Number;
	   l_stmt                   Varchar2(10000);
        i                        NUMBER  ;
        l_invoice_text          VARCHAR2(2000);
	l_old_value             varchar2(15);

   BEGIN

          i := 1;
          x_return_status := G_RET_STS_SUCCESS;

          l_stmt:= 'SELECT ksl.id,ksl.object_version_number,ksl.invoice_text
                    FROM   oks_k_lines_v ksl, okc_k_lines_b kcl
                    WHERE  kcl.date_cancelled is NULL
                    AND    kcl.dnz_chr_id = :p_chr_id
                    AND    kcl.id = ksl.cle_id
                    AND    kcl.lse_id IN (7,8,9,10,11,18,25,35,1,12,14,19)';

        IF p_attr = 'CONTRACT_START_DATE' then

           IF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                   to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(kcl.start_date) < trunc(to_date(:p_new_value,''YYYY/MM/DD HH24:MI:SS''))';
           ELSIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                  to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(kcl.start_date) = trunc(to_date(:p_old_value,''YYYY/MM/DD HH24:MI:SS''))';
           END IF;
             l_stmt := l_stmt||' Order by kcl.lse_id' ;

        ELSIF p_attr = 'CONTRACT_END_DATE' then
           IF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                  to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(kcl.end_date) > trunc(to_date(:p_new_value,''YYYY/MM/DD HH24:MI:SS''))';
           ELSIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                 to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
             l_stmt:= l_stmt||'  AND trunc(kcl.end_date) = trunc(to_date(:p_old_value,''YYYY/MM/DD HH24:MI:SS''))';
           END IF;
             l_stmt := l_stmt||' Order by kcl.lse_id' ;

        END IF;
        		    i := 0;
                 LOG_MESSAGES('l_stmt: '||l_stmt);

              If p_attr = ('CONTRACT_END_DATE') Then
                       If to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                       to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') Then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_new_value;
                       ElsIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                       to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_old_value;
                       End If;

              ElsIf p_attr = ('CONTRACT_START_DATE') Then
                      If to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') >
                       to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') Then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_old_value;
                      ElsIF to_date(p_old_value,'YYYY/MM/DD HH24:MI:SS') <
                      to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS') then
                           OPEN v_CurContLine FOR l_stmt using p_chr_id,p_new_value;
                      End If;

               End If;
	           	LOOP
                            i := i +1;
                            l_cle_id := NULL;
		            FETCH v_CurContLine INTO l_cle_id,
                                             l_object_version_number,
                                             l_invoice_text;
                      IF l_cle_id is NOT NULL THEN
        	       		    x_clev_tbl(i).ID                    := l_cle_id;
	            		    x_clev_tbl(i).object_version_number := l_object_version_number;

                        	    IF p_attr = 'CONTRACT_START_DATE'
                        	    THEN
                        	    l_old_value := SUBSTR (l_invoice_text,-23,11);
                        	    ELSE
                        	    l_old_value := SUBSTR (l_invoice_text, -11,11);
                        	    END IF;

        	        	    x_clev_tbl(i).invoice_text := REPLACE (l_invoice_text,
				    l_old_value,
				    to_char(trunc(to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS')), 'DD-MON-YYYY')	);

				    LOG_MESSAGES('l_old_value         : '|| l_old_value);
				    LOG_MESSAGES('p_new_value         : '|| to_char(trunc(to_date(p_new_value,'YYYY/MM/DD HH24:MI:SS')), 'DD-MON-YYYY'));
				    LOG_MESSAGES('Invoice Text before : '|| l_invoice_text);
				    LOG_MESSAGES('Invoice Text after  : '||x_clev_tbl(i).invoice_text);

                      END IF;
        		  EXIT WHEN v_CurContLine%NOTFOUND;
                          LOG_MESSAGES('x_clev_tbl(i).ID:'||x_clev_tbl(i).ID);
                END LOOP;
                CLOSE v_CurContLine;

                LOG_MESSAGES('Get_contract_lines return_status:'||x_return_status);
        EXCEPTION WHEN OTHERS
        then
           x_return_status := G_RET_STS_UNEXP_ERROR;
           LOG_MESSAGES('ERROR In Get_oks_contract_lines for chr_id '||p_chr_id||' : '||SQLERRM);
                 LOG_MESSAGES('l_stmt: '||l_stmt);

  END Get_oks_contract_lines;

-- Fix bug 5075961


   -- Procedure to seperate the org_id and sales person ID/ Revenue Accoutn ID
   -- from the concatenated string with a delimiter '#'

   PROCEDURE parse_org_id ( p_old_value 	IN Varchar2
	       		  ,x_old_value 	OUT NOCOPY Varchar2
	       		  ,x_org_id	OUT NOCOPY Number) IS
	 l_old_value         Varchar2(240);
	 l_org_id	    Number;
   BEGIN
        	If p_old_value is Not Null then
	 	If instr(p_old_value,'#') > 0 Then
              	    l_old_value	 := substr(p_old_value,1,instr(p_old_value,'#')-1) ;
              	    l_org_id 	 := substr(p_old_value,instr(p_old_value,'#')+1,length(p_old_value));
              	Else
              	    l_old_value  := p_old_value;
              	    l_org_id     := Null;
              	End If;

              	x_old_value      := l_old_value ;
              	x_org_id	 := l_org_id;
	       End If;
   END parse_org_id;

  FUNCTION Get_lookup_value(p_lookup_code IN Varchar2)
  RETURN Varchar2 IS
    CURSOR Cur_lookup IS
           SELECT meaning FROM fnd_lookups
           WHERE lookup_type like 'OKS_MSCHG_LEVEL%'
           AND   lookup_code = p_lookup_code
           AND   rownum =1;
    l_meaning   Varchar2(100);
  BEGIN
        OPEN  Cur_lookup;
        FETCH Cur_lookup INTO l_meaning;
        CLOSE Cur_lookup;

        RETURN l_meaning;

  END Get_lookup_value;


  FUNCTION Get_contract_amount(p_chr_id IN Number)
  RETURN Number IS
  l_cont_amt  Number;
  CURSOR Get_amt IS
         SELECT estimated_amount FROM okc_k_headers_v WHERE id = p_chr_id;
  BEGIN
       OPEN  Get_amt;
       FETCH Get_amt INTO l_cont_amt;
       CLOSE Get_amt;
       RETURN l_cont_amt;
  EXCEPTION WHEN OTHERS THEN
      LOG_MESSAGES('ERROR in Get_contract_amount:'||SQLERRM);
      RAISE G_EXCEPTION_HALT_VALIDATION;
  END Get_contract_amount;

  FUNCTION Get_ste_code(p_sts_code IN Varchar2)
  RETURN Varchar2 IS
  l_ste_code  Varchar2(50):= NULL;
  CURSOR Get_ste_code(sts_code IN Varchar2) IS
         SELECT ste_code FROM okc_statuses_v WHERE code = sts_code;
  BEGIN
       OPEN  Get_ste_code(p_sts_code);
       FETCH Get_ste_code INTO l_ste_code;
       CLOSE Get_ste_code;
       RETURN l_ste_code;
  EXCEPTION WHEN OTHERS THEN
      LOG_MESSAGES('ERROR in Get_ste_code:'||SQLERRM);
      RAISE G_EXCEPTION_HALT_VALIDATION;
  END Get_ste_code;

-- This fuctions pads the text with a pading character specified as in parameter
-- Used for generating the mass change report
  Function Pad(
     p_text    in varchar2
    ,p_width   in number
    ,p_side    in varchar2 default 'R'
    ,p_char    in char default ' ')
                         return varchar2 is
    l_text varchar2(2000);
  BEGIN
    l_text := p_text;
    IF p_side = 'L' THEN
      for i in 1..p_width loop
         l_text := ' '||l_text;
      End Loop;
      return(l_text);
    ELSIF p_side = 'R' THEN
      return(rpad(l_text, p_width,p_char));
    END IF;
  END Pad;

  -- Function to check the Contract is a Warranty or not
  FUNCTION Check_warranty(p_chr_id IN Number)
  RETURN Varchar2 IS
    CURSOR Warranty_lookup IS
           SELECT id FROM okc_k_headers_b okh
           WHERE
           Exists (select 'x' from OKC_K_LINES_B cle
                 where cle.dnz_chr_id = okh.id
                   and cle.lse_id = 14 )
           AND okh.id = p_chr_id ;
    l_chr_id    Number;
    l_warranty_yn  Varchar2(1);
  BEGIN
        OPEN  Warranty_lookup;
        FETCH Warranty_lookup INTO l_chr_id;
        If Warranty_lookup%found then
           l_warranty_yn := 'Y';
        Else
           l_warranty_yn := 'N';
        End If;
        CLOSE Warranty_lookup;

        RETURN l_warranty_yn;


      EXCEPTION WHEN OTHERS THEN
      LOG_MESSAGES('ERROR in Check_warranty:'||SQLERRM);
      RAISE G_EXCEPTION_HALT_VALIDATION;
  End Check_warranty ;

  -- Function to get the default status code for a status type

  FUNCTION Get_Status_Code(p_ste_code IN Varchar2)
  RETURN Varchar2 IS
     Cursor get_sts_code (p_ste_code in Varchar2) IS
     Select code
      From  OKC_STATUSES_B
      Where ste_code = p_ste_code
        And default_yn = 'Y';

     l_sts_code OKC_STATUSES_B.CODE%type;

  Begin
     Open get_sts_code(p_ste_code );
     Fetch get_sts_code into l_sts_code;
     Close get_sts_code;

     Return l_sts_code;

      EXCEPTION WHEN OTHERS THEN
      LOG_MESSAGES('ERROR in getting default status code (PgmUnit:- Get_Status_Code): '||SQLERRM);
      RAISE G_EXCEPTION_HALT_VALIDATION;
  End Get_Status_Code;

  -- The following function finds the new status for the contract atfer the effectivity date change.
  -- Pass the new value to p_start_date when the start_date for the contract is changed.
  -- Pass the new value to p_end_date when the end_date for the contract is changed.

  FUNCTION Find_Contract_Status(p_start_date     IN Date  -- pass new start date
                               ,p_end_date       IN Date  -- pass new end date
                               ,p_sts_code       IN Varchar2)
  RETURN Varchar2 IS
      l_status_code  Varchar2(40);
  BEGIN
      If trunc(sysdate) < trunc(p_start_date) Then
          l_status_code := get_status_code('SIGNED') ;
      Elsif trunc(sysdate) > trunc(p_end_date) Then
          l_status_code := get_status_code('EXPIRED') ;
      Elsif trunc(sysdate) >= trunc(p_start_date) and trunc(sysdate) <= trunc(p_end_date) Then
          l_status_code := get_status_code('ACTIVE') ;
      Else
          l_status_code := p_sts_code;
      End If;

      Return l_status_code;

      Exception When Others Then
           LOG_MESSAGES('ERROR in Find_Contract_Status:'||SQLERRM);
           Raise G_EXCEPTION_HALT_VALIDATION;
  END Find_Contract_Status;

 ------------------------------
 -- Submit procedure starts  --
 ------------------------------
 BEGIN
      x_return_status  := G_RET_STS_SUCCESS;
      l_conc_program   := 'Y';
      l_message        := NULL;

      l_status               := 'SUCCESS';
      l_opn_status           := 'PROCESSED';
      l_init_msg_list	     := 'T';
      l_restricted_update    := 'F' ;
      l_message              := 'Successfully completed';

      l_count_pm_schedule    := 0 ;

      l_cov_time_wrong       := 0 ;
      l_cov_time_right       := 0 ;
      cvr_cnt                := 0 ;
      srv_cnt                := 0 ;
      rcn_cnt                := 0 ;
      cnt                    := 0 ;

      l_success_cnt          := 0 ;
      l_error_cnt            := 0 ;
      l_outfile_success_id   := 0 ;
      l_succ_count           := 0 ;

      l_outfile_fail_id      := 0 ;
      l_fail_count           := 0 ;

      l_outfile_inel_id      := 0 ;
      l_inel_count           := 0 ;
      l_total_rec_count      := 0 ;

      l_billed_at_source_msg := '';




      LOG_MESSAGES('starts processing ....');

      DBMS_TRANSACTION.SAVEPOINT('BEFORE_MASSCHANGE_START');

      LOG_MESSAGES('Before get_criteria_cur');

	OPEN  get_criteria_cur;
	FETCH get_criteria_cur INTO
	     l_masschange_name
	     ,l_update_level_code
	     ,l_update_level_value_id
	     ,l_attribute_code
	     ,l_old_value_id_tmp
	     ,l_new_value_id;
	CLOSE get_criteria_cur;

	-- Call the procedure to parse the ORG_ID
	If l_attribute_code in ('SALES_REP','REV_ACCT') then
	   Parse_Org_Id(p_old_value	=> l_old_value_id_tmp
			,x_old_value	=> l_old_value_id
			,x_org_id	=> l_org_id );

	Else
	    l_old_value_id    := l_old_value_id_tmp;
	End If;

	LOG_MESSAGES('After get_criteria_cur');

	l_criteria_rec.oie_id             := p_oie_id;
	l_criteria_rec.update_level       := l_update_level_code;
	l_criteria_rec.update_level_value := l_update_level_value_id;
	l_criteria_rec.attribute          := l_attribute_code;
	l_criteria_rec.old_value          := l_old_value_id;
	l_criteria_rec.ORG_ID             := l_org_id;
	l_criteria_rec.new_value           := l_new_value_id;

        l_update_level := Get_lookup_value(p_lookup_code => l_update_level_code);

        l_update_level_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code =>l_update_level_code,
                                                            p_id1 => l_update_level_value_id,
                                                            p_id2 => '#');

        get_attribute_value(p_attr_code  => l_attribute_code,
                            p_attr_id    => l_old_value_id,
                            p_org_id     => l_org_id,
                            x_attr_value => l_old_value,
                            x_attr_name  => l_attribute);

        -- LOG_MESSAGES('l_old_value:'||l_old_value);

        get_attribute_value(p_attr_code  => l_attribute_code,
                            p_attr_id    => l_new_value_id,
                            p_org_id     => l_org_id,
                            x_attr_value => l_new_value,
                            x_attr_name  => l_attribute);

	LOG_MESSAGES('Oie_id                           :'||l_criteria_rec.oie_id);
	LOG_MESSAGES('Update_level (Stored Code)       :'||l_criteria_rec.update_level);
        LOG_MESSAGES('Update_level_value (Stored Code) :'||l_criteria_rec.update_level_value);
        LOG_MESSAGES('Attribute (Stored Code)          :'||l_criteria_rec.attribute);
        LOG_MESSAGES('Old Vlaue (Stored Code)          :'||l_criteria_rec.old_value);

        LOG_MESSAGES('MASS CHANGE '||p_process_type||' Starts');
        LOG_MESSAGES('Mass change Name   :  '||l_masschange_name);
        LOG_MESSAGES('Update Level       :  '||l_update_level);
        LOG_MESSAGES('Update Level value :  '||l_update_level_value);
        LOG_MESSAGES('Attribute          :  '||l_attribute);
        LOG_MESSAGES('Old value          :  '||l_old_value);
        LOG_MESSAGES('New value          :  '||l_new_value);

        -- The following code for report is moved towards the end of the procedure.
        -- Reason: Report printing code was scattered. Mar 2004

        --  fnd_file.put_line(FND_FILE.OUTPUT, '          MASS CHANGE '||p_process_type||' REPORT');
        --  fnd_file.put_line(FND_FILE.OUTPUT, '          **************************');
        --  fnd_file.new_line(FND_FILE.OUTPUT, 2);
        --  fnd_file.put_line(FND_FILE.OUTPUT, 'Mass change Name               :  '||l_masschange_name);
        --  fnd_file.new_line(FND_FILE.OUTPUT, 1);
        --  fnd_file.put_line(FND_FILE.OUTPUT, 'Mass change Scope              ');
        --  fnd_file.put_line(FND_FILE.OUTPUT, '            Update Level       :  '||l_update_level);
        --  fnd_file.put_line(FND_FILE.OUTPUT, '            Update Level value :  '||l_update_level_value);
        --  fnd_file.new_line(FND_FILE.OUTPUT, 1);
        --  fnd_file.put_line(FND_FILE.OUTPUT, 'Mass change Criteria           ');
        --  fnd_file.put_line(FND_FILE.OUTPUT, '            Attribute          :  '||l_attribute);
        --  fnd_file.put_line(FND_FILE.OUTPUT, '            Old value          :  '||l_old_value);
        --  fnd_file.put_line(FND_FILE.OUTPUT, '            New value          :  '||l_new_value);
        --  fnd_file.put_line(FND_FILE.OUTPUT, '*********************************************************************************************************************');
        --  fnd_file.new_line(FND_FILE.OUTPUT, 1);
        -- fnd_file.put_line(FND_FILE.OUTPUT, 'List of Contracts for Mass Change:');
        -- fnd_file.put_line(FND_FILE.OUTPUT, '----------------------------------------------------------------------------------------------------------------------');
        -- fnd_file.put_line(FND_FILE.OUTPUT, 'Contract Number      Modifier    Description                 Old Value            Process Status      Remark');
        -- fnd_file.put_line(FND_FILE.OUTPUT, '----------------------------------------------------------------------------------------------------------------------');

        LOG_MESSAGES('Fetching list of eligible contracts ...');

   OKS_MASSCHANGE_PVT.get_eligible_contracts
		 (p_api_version         => l_api_version
		 ,p_init_msg_list       => l_init_msg_list
		 ,p_ctr_rec             => l_criteria_rec
                 ,p_query_type          => 'PROCESS'
                 ,p_upg_orig_system_ref => 'N'
		 ,x_return_status       => l_return_status
		 ,x_msg_count           => l_msg_count
		 ,x_msg_data            => l_msg_data
		 ,x_eligible_contracts  => l_eligible_contracts_tbl);

      LOG_MESSAGES('Updating all selected (A,E) operation lines STATUS to NULL   ...'||l_eligible_contracts_tbl.COUNT);

      UPDATE_LINE_STATUS(p_oie_id    => l_criteria_rec.oie_id);

      fnd_file.new_line(FND_FILE.OUTPUT, 1);

  FOR i IN 1 .. l_eligible_contracts_tbl.COUNT
  LOOP
  BEGIN

    /* added by mkarra as part of Implementing Service Contracts Imports -
         This checks if the contract is imported and fully billed at source and if "Yes" it
          appends a text in the remarks as " Billing program would not process this fully billed contract"
    */
    LOG_MESSAGES('Checking billed_at_source for eligible contracts ...'|| l_eligible_contracts_tbl(i).billed_at_source);
    if (l_eligible_contracts_tbl(i).billed_at_source is not null and l_eligible_contracts_tbl(i).billed_at_source ='Y') then
	l_billed_at_source_msg := l_billed_at_source_msg || fnd_message.get_string('OKS','OKS_HEADER_CASCADE_DATES_WARN') || ';' ;
    else
      l_billed_at_source_msg := '';
    end if;

  --IF l_eligible_contracts_tbl(i).old_value1=1 then

       FND_MSG_PUB.Initialize;
       l_status    := 'SUCCESS';
       l_message   := null; --'Successfully completed';
       DBMS_TRANSACTION.SAVEPOINT('BEFORE_MASSCHANGE');

        --UPDATE_LINE_STATUS(p_ole_id              => l_eligible_contracts_tbl(i).ole_id);
        --Update the attribute
        LOG_MESSAGES('Processing Contract contract number :'||l_eligible_contracts_tbl(i).contract_number);
        LOG_MESSAGES('Old Value:'||l_eligible_contracts_tbl(i).old_value);

        -- This procedure has been stub out. Hence commenting out the call and validation.
        --  OKS_RENEW_UTIL_PUB.Can_Update_Contract(
        --                              p_api_version     => l_api_version ,
        --                              p_init_msg_list   => l_init_msg_list,
        --                              p_chr_id          => l_eligible_contracts_tbl(i).contract_id,
        --                              x_can_update_yn   => l_can_update_yn,
        --                              x_can_submit_yn   => l_can_submit_yn,
        --                              x_msg_count       => l_msg_count,
        --                              x_msg_data        => l_msg_data,
        --                              x_return_status   => l_return_status ) ;
        -- LOG_MESSAGES('Can_Update_Contract :'||l_return_status);
        --    IF l_can_update_yn = 'N' then
        --       l_status    := 'ERROR';
        --       l_message := FND_MESSAGE.get_string('OKS','OKS_MSCHG_UND_REN');
        --       l_message := 'Can not update. The contract is under electronic renewal process.';
        --       RAISE G_EXCEPTION_HALT_VALIDATION;
        --    END IF;

        -- Modified the following since "ALL" cause translation issues.
        -- 10-MAR-04
        --   IF l_old_value = 'ALL' then
        IF l_old_value_id = '-1111' then
             get_attribute_value(p_attr_code  => l_attribute_code,
                                 p_attr_id    => l_eligible_contracts_tbl(i).old_value,
                                 p_org_id     => l_org_id ,
                                 x_attr_value => l_old_value,
                                 x_attr_name  => l_attribute);
        END IF;

      -- Check if the contract is a Warranty .
      --  Enable start date and end date to be modified. Also update the Status for these
      --  contracts

     l_warranty_flag := Check_warranty(l_eligible_contracts_tbl(i).contract_id);
     LOG_MESSAGES('Check warranty flag '||l_warranty_flag);
     If l_warranty_flag = 'Y' then
        If l_criteria_rec.attribute not in ('CONTRACT_START_DATE','CONTRACT_END_DATE') then

            l_message  := FND_MESSAGE.get_string('OKS','OKS_MSCHG_WARR_CON') ;
            -- l_message  := 'Warranty Contract. You can only update Start Date and End Date' ;
            RAISE  l_notelligible_exception ;
        Else
            If l_criteria_rec.attribute = 'CONTRACT_START_DATE' then

               l_chrv_tbl_in.DELETE;

               -- Check Start Date > End Date
               If trunc(l_eligible_contracts_tbl(i).end_date) <
                           trunc(to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS')) then
                  l_message := FND_MESSAGE.get_string('OKS','OKS_MSCHG_WRONG_DT') ;
--                  l_message := 'Contract End Date less than new Start Date' ;
                  RAISE  l_notelligible_exception ;
               End If;

               -- find the new status for the contract

               l_sts_code := Find_Contract_Status(
                                       p_start_date => to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS')
                                       ,p_end_date  => l_eligible_contracts_tbl(i).end_date
                                       ,p_sts_code  => l_eligible_contracts_tbl(i).CONTRACT_STATUS);

               LOG_MESSAGES('New status for the contract '||l_sts_code);

               l_chrv_tbl_in(1).id		         := l_eligible_contracts_tbl(i).contract_id;
               l_chrv_tbl_in(1).object_version_number    := l_eligible_contracts_tbl(i).object_version_number;

               OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count             => l_msg_count,
                         	x_msg_data              => l_msg_data,
                           	p_chrv_tbl              => l_chrv_tbl_in);

               IF l_return_status = G_RET_STS_SUCCESS THEN

                  LOG_MESSAGES('Fetching contract lines for update');
                  l_clev_tbl_in.DELETE;
                  Get_contract_lines(p_chr_id          => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_clev_tbl_in);

                  IF l_return_status = G_RET_STS_SUCCESS THEN


                       LOG_MESSAGES('Locking contract lines for update, lines count:'||l_clev_tbl_in.COUNT);
                       OKC_CONTRACT_PUB.lock_contract_line(
                            	                  p_api_version	    => l_api_version,
                              	                  p_init_msg_list   => l_init_msg_list,
                            	                  x_return_status   => l_return_status,
                            	                  x_msg_count       => l_msg_count,
                             	                  x_msg_data        => l_msg_data,
                                                  p_clev_tbl        => l_clev_tbl_in);

                      LOG_MESSAGES('lock status:'||l_return_status);
                      IF l_return_status = G_RET_STS_SUCCESS THEN -- lines locked

                      --- vigandhi added
		      -- Bug Fix 5075961

                      l_klnv_tbl_type_in.DELETE;
                      Get_oks_contract_lines(p_chr_id      => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_klnv_tbl_type_in);

		     IF l_return_status = G_RET_STS_SUCCESS THEN

		       LOG_MESSAGES('Locking oks contract lines for update, lines count:'||l_klnv_tbl_type_in.COUNT);
                                    OKS_CONTRACT_LINE_PUB.lock_line(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_klnv_tbl            => l_klnv_tbl_type_in);


                    IF l_return_status = G_RET_STS_SUCCESS THEN
                    -- Bug fix 5075961

                          l_chrv_rec_in.id          := l_eligible_contracts_tbl(i).contract_id;
                          l_chrv_rec_in.start_date  := to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
                          l_chrv_rec_in.sts_code    := l_sts_code;

                          LOG_MESSAGES('updating contract header with new value:'||l_new_value);
                          OKC_CONTRACT_PUB.update_contract_header (
                        	       p_api_version		=> l_api_version,
                          	       p_init_msg_list		=> l_init_msg_list,
                        	       x_return_status		=> l_return_status,
                        	       x_msg_count     	        => l_msg_count,
                         	       x_msg_data               => l_msg_data,
                        	       p_chrv_rec               => l_chrv_rec_in,
    	                               x_chrv_rec               => l_chrv_rec_out );

                           IF l_return_status = G_RET_STS_SUCCESS THEN -- contract update
                               LOG_MESSAGES('CONTRACT_HEADER(Start_Date) update status: '||l_return_status);
                               IF l_clev_tbl_in.COUNT > 0 THEN
                                    FOR j in 1 .. l_clev_tbl_in.COUNT
                                    LOOP
                                        l_clev_tbl_in(j).start_date := to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
                                        l_clev_tbl_in(j).sts_code   := l_sts_code;
                                    END LOOP;
                                    LOG_MESSAGES('updating contract lines with new value:'||l_new_value);
                                    OKC_CONTRACT_PUB.update_contract_line(
                            	                  p_api_version	    => l_api_version,
                              	                  p_init_msg_list   => l_init_msg_list,
                            	                  x_return_status   => l_return_status,
                            	                  x_msg_count	    => l_msg_count,
                             	                  x_msg_data	    => l_msg_data,
                                                  p_clev_tbl        => l_clev_tbl_in,
                                                  x_clev_tbl        => l_clev_tbl_out);
                                END IF; -- line_table.COUNT > 0

                                IF l_return_status = G_RET_STS_SUCCESS THEN
                                    LOG_MESSAGES('CONTRACT_HEADER_LINES(Start_Date) update status: '||l_return_status);

                                    -- Vigandhi
				    -- Bug Fix 5075961

                                    IF l_klnv_tbl_type_in.COUNT > 0 THEN
				        LOG_MESSAGES('updating contract lines with new invoice text');
                                        oks_contract_line_pub.update_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_klnv_tbl           => l_klnv_tbl_type_in,
                                           x_klnv_tbl           => l_klnv_tbl_type_out,
                                           p_validate_yn        => 'N'
                                          );
					  LOG_MESSAGES('CONTRACT_HEADER_OKS_LINES(Start_Date) update status: '||l_return_status);
					  IF l_return_status <> G_RET_STS_SUCCESS THEN
					     IF l_msg_count > 0 Then
                                                FOR i in 1..l_msg_count
                                                LOOP
                                                  fnd_msg_pub.get (p_msg_index     => -1,
                                                                   p_encoded       => 'F',
                                                                   p_data          => l_msg_data,
                                                                   p_msg_index_out => l_msg_index_out);
                                                  l_message := l_message||' ; '||l_msg_data;
                                                END LOOP;
                                              END IF;
					      LOG_MESSAGES('CONTRACT_OKS_LINES(Contract_Start_Date) update status: '||l_return_status);
                                              LOG_MESSAGES('Contract oks Lines(Contract_Start_Date) Update failed;'||l_message);
                                              l_status := 'ERROR';
                                              RAISE G_EXCEPTION_HALT_VALIDATION;
 					   END IF;
				    END IF;
				    -- Bug Fix 5075961

                                ELSE
                                   IF l_msg_count > 0 Then
                                      FOR i in 1..l_msg_count
                                      LOOP
                                         fnd_msg_pub.get (p_msg_index     => -1,
                                         p_encoded       => 'F',
                                         p_data          => l_msg_data,
                                         p_msg_index_out => l_msg_index_out);
                                         l_message := l_message||' ; '||l_msg_data;
                                      END LOOP;
                                   END IF;
                                   LOG_MESSAGES('CONTRACT_LINES(Contract_Start_Date) update status: '||l_return_status);
                                   LOG_MESSAGES('Contract Lines(Contract_Start_Date) Update failed;'||l_message);
                                   l_status := 'ERROR';
                                   RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF; -- contract line update status
                           ELSE
                              IF l_msg_count > 0 Then
                              FOR i in 1..l_msg_count
                              LOOP
                                  fnd_msg_pub.get (p_msg_index     => -1,
                                                   p_encoded       => 'F',
                                                   p_data          => l_msg_data,
                                                   p_msg_index_out => l_msg_index_out);
                                       l_message := l_message||' ; '||l_msg_data;
                               END LOOP;
                               END IF;
                               LOG_MESSAGES('CONTRACT_HEADERS(Contract_Start_Date) update status: '||l_return_status);
                               LOG_MESSAGES('Contract Header(Contract_Start_Date) Update failed;'||l_message);
                               l_status := 'ERROR';
                               RAISE G_EXCEPTION_HALT_VALIDATION;
                           END IF; -- Contract update

                	  -- Vigandhi
			  -- Bug Fix 5075961

                	  ELSE  -- oks line lock

                               LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT_OKS_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                               IF l_msg_count > 0 then
                        	   FOR i in 1..l_msg_count
                        	   LOOP
                        	   fnd_msg_pub.get (p_msg_index     => -1,
                                                    p_encoded       => 'F',
                                                    p_data          => l_msg_data,
                                                    p_msg_index_out => l_msg_index_out);
                                       l_message := l_message||' ; '||l_msg_data;
                                    END LOOP;
                               END IF;
                               LOG_MESSAGES('Contract Oks Lines Lock(CONTRACT_START_DATE) failed;'||l_message);
                               l_status := 'ERROR';
                               RAISE G_EXCEPTION_HALT_VALIDATION;

                	  END IF; -- oks line lock

			ELSE  -- Get oks contract Lines
                	   LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                	   LOG_MESSAGES('Get_Contract_lines failed');
                	   l_status := 'ERROR';
                	   RAISE G_EXCEPTION_HALT_VALIDATION;
                	END IF;  -- Get oks Contracts Lines

                       -- Bug Fix 5075961


                       ELSE -- line lock
                           LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                           IF l_msg_count > 0 then
                               FOR i in 1..l_msg_count
                               LOOP
                               fnd_msg_pub.get (p_msg_index     => -1,
                                                p_encoded       => 'F',
                                                p_data          => l_msg_data,
                                                p_msg_index_out => l_msg_index_out);
                                   l_message := l_message||' ; '||l_msg_data;
                                END LOOP;
                           END IF;
                           LOG_MESSAGES('Contract Lines Lock(CONTRACT_START_DATE) failed;'||l_message);
                           l_status := 'ERROR';
                           RAISE G_EXCEPTION_HALT_VALIDATION;
                       END IF; -- line lock


                  ELSE -- get contract line
                       LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                       LOG_MESSAGES('Get_Contract_lines failed');
                       l_status := 'ERROR';
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF; -- get contract lines
              ELSE -- lock contract
                     IF l_msg_count > 0 Then
                        FOR i in 1..l_msg_count
                        LOOP
                          fnd_msg_pub.get (p_msg_index     => -1,
                                           p_encoded       => 'F',
                                           p_data          => l_msg_data,
                                           p_msg_index_out => l_msg_index_out);
                               l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                     END IF;
                     LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT status: '||l_return_status);
                     LOG_MESSAGES('Contract Lock(CONTRACT_START_DATE) failed;'||l_message);
                     l_status := 'ERROR';
                     RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF; -- lock contract

            Elsif l_criteria_rec.attribute = 'CONTRACT_END_DATE' then

               l_chrv_tbl_in.DELETE;

               -- Check Start Date > End Date
               If trunc(l_eligible_contracts_tbl(i).Start_date) >
                           trunc(to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS')) then
                  l_message := FND_MESSAGE.get_string('OKS','OKS_MSCHG_WRONG_DT') ;
--                  l_message := 'Contract Start Date greater than new End Date' ;
                  RAISE  l_notelligible_exception ;
               End If;

               -- Find the new status for the contract
               l_sts_code := Find_Contract_Status(
                                       p_start_date => l_eligible_contracts_tbl(i).start_date
                                       ,p_end_date  => to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS')
                                       ,p_sts_code  => l_eligible_contracts_tbl(i).CONTRACT_STATUS);

               LOG_MESSAGES('New status for the contract '||l_sts_code);

               l_chrv_tbl_in(1).id		         := l_eligible_contracts_tbl(i).contract_id;
               l_chrv_tbl_in(1).object_version_number    := l_eligible_contracts_tbl(i).object_version_number;

               OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count             => l_msg_count,
                         	x_msg_data              => l_msg_data,
                           	p_chrv_tbl              => l_chrv_tbl_in);

               IF l_return_status = G_RET_STS_SUCCESS THEN

                  LOG_MESSAGES('Fetching contract lines for update');
                  l_clev_tbl_in.DELETE;
                  Get_contract_lines(p_chr_id          => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_clev_tbl_in);

                  IF l_return_status = G_RET_STS_SUCCESS THEN
                       LOG_MESSAGES('Locking contract lines for update, lines count:'||l_clev_tbl_in.COUNT);
                       OKC_CONTRACT_PUB.lock_contract_line(
                            	                  p_api_version	    => l_api_version,
                              	                  p_init_msg_list   => l_init_msg_list,
                            	                  x_return_status   => l_return_status,
                            	                  x_msg_count       => l_msg_count,
                             	                  x_msg_data        => l_msg_data,
                                                  p_clev_tbl        => l_clev_tbl_in);

                      LOG_MESSAGES('lock status:'||l_return_status);
                      IF l_return_status = G_RET_STS_SUCCESS THEN -- lines locked

                      --- vigandhi added
		      -- Bug Fix 5075961

                      l_klnv_tbl_type_in.DELETE;
                      Get_oks_contract_lines(p_chr_id      => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_klnv_tbl_type_in);

		     IF l_return_status = G_RET_STS_SUCCESS THEN

		       LOG_MESSAGES('Locking oks contract lines for update, lines count:'||l_klnv_tbl_type_in.COUNT);
                                    OKS_CONTRACT_LINE_PUB.lock_line(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_klnv_tbl            => l_klnv_tbl_type_in);


                    IF l_return_status = G_RET_STS_SUCCESS THEN
                    -- Bug fix 5075961

                          l_chrv_rec_in.id          := l_eligible_contracts_tbl(i).contract_id;
                          l_chrv_rec_in.end_date  := to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
                          l_chrv_rec_in.sts_code    := l_sts_code;

                          LOG_MESSAGES('updating contract header with new value:'||l_new_value);
                          OKC_CONTRACT_PUB.update_contract_header (
                        	       p_api_version		=> l_api_version,
                          	       p_init_msg_list		=> l_init_msg_list,
                        	       x_return_status		=> l_return_status,
                        	       x_msg_count     	        => l_msg_count,
                         	       x_msg_data               => l_msg_data,
                        	       p_chrv_rec               => l_chrv_rec_in,
    	                               x_chrv_rec               => l_chrv_rec_out );

                           IF l_return_status = G_RET_STS_SUCCESS THEN -- contract update
                               LOG_MESSAGES('CONTRACT_HEADER(End_Date) update status: '||l_return_status);
                               IF l_clev_tbl_in.COUNT > 0 THEN
                                    FOR j in 1 .. l_clev_tbl_in.COUNT
                                    LOOP
                                        l_clev_tbl_in(j).end_date := to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
                                        l_clev_tbl_in(j).sts_code   := l_sts_code;
                                    END LOOP;
                                    LOG_MESSAGES('updating contract lines with new value:'||l_new_value);
                                    OKC_CONTRACT_PUB.update_contract_line(
                            	                  p_api_version	    => l_api_version,
                              	                  p_init_msg_list   => l_init_msg_list,
                            	                  x_return_status   => l_return_status,
                            	                  x_msg_count	    => l_msg_count,
                             	                  x_msg_data	    => l_msg_data,
                                                  p_clev_tbl        => l_clev_tbl_in,
                                                  x_clev_tbl        => l_clev_tbl_out);
                                END IF; -- line_table.COUNT > 0

                                IF l_return_status = G_RET_STS_SUCCESS THEN
                                    LOG_MESSAGES('CONTRACT_HEADER_LINES(End_Date) update status: '||l_return_status);


                                    -- Vigandhi
				    -- Bug Fix 5075961

                                    IF l_klnv_tbl_type_in.COUNT > 0 THEN
				        LOG_MESSAGES('updating contract lines with new invoice text');
                                        oks_contract_line_pub.update_line
                                          (p_api_version        => l_api_version,
                                           p_init_msg_list      => l_init_msg_list,
                                           x_return_status      => l_return_status,
                                           x_msg_count          => l_msg_count,
                                           x_msg_data           => l_msg_data,
                                           p_klnv_tbl           => l_klnv_tbl_type_in,
                                           x_klnv_tbl           => l_klnv_tbl_type_out,
                                           p_validate_yn        => 'N'
                                          );
					  LOG_MESSAGES('CONTRACT_HEADER_OKS_LINES(Start_Date) update status: '||l_return_status);
					  IF l_return_status <> G_RET_STS_SUCCESS THEN
					     IF l_msg_count > 0 Then
                                                FOR i in 1..l_msg_count
                                                LOOP
                                                  fnd_msg_pub.get (p_msg_index     => -1,
                                                                   p_encoded       => 'F',
                                                                   p_data          => l_msg_data,
                                                                   p_msg_index_out => l_msg_index_out);
                                                  l_message := l_message||' ; '||l_msg_data;
                                                END LOOP;
                                              END IF;
					      LOG_MESSAGES('CONTRACT_OKS_LINES(Contract_Start_Date) update status: '||l_return_status);
                                              LOG_MESSAGES('Contract oks Lines(Contract_Start_Date) Update failed;'||l_message);
                                              l_status := 'ERROR';
                                              RAISE G_EXCEPTION_HALT_VALIDATION;
 					   END IF;
				    END IF;
				    -- Bug Fix 5075961

                                ELSE
                                   IF l_msg_count > 0 Then
                                      FOR i in 1..l_msg_count
                                      LOOP
                                         fnd_msg_pub.get (p_msg_index     => -1,
                                                          p_encoded       => 'F',
                                                          p_data          => l_msg_data,
                                                          p_msg_index_out => l_msg_index_out);
                                              l_message := l_message||' ; '||l_msg_data;
                                      END LOOP;
                                   END IF;
                                   LOG_MESSAGES('CONTRACT_LINES(Contract_End_Date) update status: '||l_return_status);
                                   LOG_MESSAGES('Contract Lines(Contract_End_Date) Update failed;'||l_message);
                                   l_status := 'ERROR';
                                   RAISE G_EXCEPTION_HALT_VALIDATION;
                                END IF; -- contract line update status
                           ELSE
                              IF l_msg_count > 0 Then
                              FOR i in 1..l_msg_count
                              LOOP
                                  fnd_msg_pub.get (p_msg_index     => -1,
                                                   p_encoded       => 'F',
                                                   p_data          => l_msg_data,
                                                   p_msg_index_out => l_msg_index_out);
                                       l_message := l_message||' ; '||l_msg_data;
                               END LOOP;
                               END IF;
                               LOG_MESSAGES('CONTRACT_HEADERS(Contract_End_Date) update status: '||l_return_status);
                               LOG_MESSAGES('Contract Header(Contract_End_Date) Update failed;'||l_message);
                               l_status := 'ERROR';
                               RAISE G_EXCEPTION_HALT_VALIDATION;
                           END IF; -- Contract update

                	  -- Vigandhi
			  -- Bug Fix 5075961

                	  ELSE  -- oks line lock

                               LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT_OKS_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                               IF l_msg_count > 0 then
                        	   FOR i in 1..l_msg_count
                        	   LOOP
                        	   fnd_msg_pub.get (p_msg_index     => -1,
                                                    p_encoded       => 'F',
                                                    p_data          => l_msg_data,
                                                    p_msg_index_out => l_msg_index_out);
                                       l_message := l_message||' ; '||l_msg_data;
                                    END LOOP;
                               END IF;
                               LOG_MESSAGES('Contract Oks Lines Lock(CONTRACT_START_DATE) failed;'||l_message);
                               l_status := 'ERROR';
                               RAISE G_EXCEPTION_HALT_VALIDATION;

                	  END IF; -- oks line lock

			ELSE  -- Get oks contract Lines
                	   LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                	   LOG_MESSAGES('Get_Contract_lines failed');
                	   l_status := 'ERROR';
                	   RAISE G_EXCEPTION_HALT_VALIDATION;
                	END IF;  -- Get oks Contracts Lines

                       -- Bug Fix 5075961

		       ELSE -- line lock
                           LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                           IF l_msg_count > 0 then
                               FOR i in 1..l_msg_count
                               LOOP
                               fnd_msg_pub.get (p_msg_index     => -1,
                                                p_encoded       => 'F',
                                                p_data          => l_msg_data,
                                                p_msg_index_out => l_msg_index_out);
                                   l_message := l_message||' ; '||l_msg_data;
                                END LOOP;
                           END IF;
                           LOG_MESSAGES('Contract Lines Lock(CONTRACT_END_DATE) failed;'||l_message);
                           l_status := 'ERROR';
                           RAISE G_EXCEPTION_HALT_VALIDATION;
                       END IF; -- line lock

                  ELSE -- get contract line
                       LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                       LOG_MESSAGES('Get_Contract_lines failed');
                       l_status := 'ERROR';
                       RAISE G_EXCEPTION_HALT_VALIDATION;
                  END IF; -- get contract lines
              ELSE -- lock contract
                     IF l_msg_count > 0 Then
                        FOR i in 1..l_msg_count
                        LOOP
                          fnd_msg_pub.get (p_msg_index     => -1,
                                           p_encoded       => 'F',
                                           p_data          => l_msg_data,
                                           p_msg_index_out => l_msg_index_out);
                               l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                     END IF;
                     LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT status: '||l_return_status);
                     LOG_MESSAGES('Contract Lock(CONTRACT_END_DATE) failed;'||l_message);
                     l_status := 'ERROR';
                     RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF; -- lock contract

            End If; -- start_date/end_date

         End If; -- update attribute type( l_criteria_rec.attribute )

--    End if; -- dummy for if l_warrranty = 'y'


  Else  -- Not warranty - Service, Ext. warranty, Subscription

       IF l_criteria_rec.attribute = 'SALES_REP' then
           log_messages('l_eligible_contracts_tbl(i).org_id:'||l_eligible_contracts_tbl(i).org_id);
           OKC_CONTEXT.SET_OKC_ORG_CONTEXT(l_eligible_contracts_tbl(i).org_id,NULL);
           --log_messages('sys_context '||sys_context('OKC_CONTEXT','ORG_ID'));
           FOR contact_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'SALESPERSON','OKX_SALEPERS',l_eligible_contracts_tbl(i).old_value)
           LOOP
              l_ctcv_rec_in.id		             := nvl(contact_rec.id,NULL);
              l_ctcv_rec_in.object_version_number      := contact_rec.object_version_number;
              l_start_date                       := contact_rec.start_date;
           END LOOP;

         IF l_ctcv_rec_in.id is NOT NULL
	 AND l_ctcv_rec_in.id <> OKC_API.G_MISS_NUM then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_rec            => l_ctcv_rec_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_ctcv_rec_in.object1_id1  := l_new_value_id;
         l_ctcv_rec_in.sales_group_id  := jtf_rs_integration_pub.get_default_sales_group
                                      (p_salesrep_id    => l_new_value_id,
                                       p_org_id         => Okc_context.get_okc_org_id,
                                       p_date           => l_start_date);

                OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_rec            => l_ctcv_rec_in,
                                        x_ctcv_rec            => l_ctcv_rec_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('SALES_PERSON in OKC_CONTACTS update status: '||l_return_status);
                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('SALESPERSON in OKC_CONTACTS update status: '||l_return_status);
                        LOG_MESSAGES('SALES Person in OKC_CONTACTS  Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F',
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('SALESPERSON in OKC_CONTACTS lock status: '||l_return_status);
                LOG_MESSAGES('SALESPERSON in OKC_CONTACTS lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
          END IF;

                        srv_cnt := 1;
                        l_scrv_tbl_in.DELETE;
                        FOR srv_rec IN Get_Salesrep(l_eligible_contracts_tbl(i).contract_id,l_eligible_contracts_tbl(i).old_value)
                        LOOP
                            l_scrv_tbl_in(srv_cnt).id		               := srv_rec.id;
                            l_scrv_tbl_in(srv_cnt).object_version_number   := srv_rec.object_version_number;
                            l_scrv_tbl_in(srv_cnt).ctc_id		         := l_new_value_id;
                            l_scrv_tbl_in(srv_cnt).sales_group_id          := jtf_rs_integration_pub.get_default_sales_group
                                                                               (p_salesrep_id    => l_new_value_id,
                                                                                p_org_id         => Okc_context.get_okc_org_id,
                                                                                p_date           => srv_rec.start_date);

                        srv_cnt :=  srv_cnt+1;
                        END LOOP;
                        FOR srv_rec IN Get_LineSalesrep(l_eligible_contracts_tbl(i).contract_id,l_eligible_contracts_tbl(i).old_value)
                        LOOP
                            l_scrv_tbl_in(srv_cnt).id		               := srv_rec.id;
                            l_scrv_tbl_in(srv_cnt).object_version_number   := srv_rec.object_version_number;
                            l_scrv_tbl_in(srv_cnt).ctc_id		         := l_new_value_id;
                            l_scrv_tbl_in(srv_cnt).sales_group_id          := jtf_rs_integration_pub.get_default_sales_group
                                                                               (p_salesrep_id    => l_new_value_id,
                                                                                p_org_id         => Okc_context.get_okc_org_id,
                                                                                p_date           => srv_rec.start_date);

                        srv_cnt :=  srv_cnt+1;
                        END LOOP;
            IF l_scrv_tbl_in.COUNT > 0 then
                            OKS_SALES_CREDIT_PUB.Lock_Sales_credit(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       => l_init_msg_list,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_scrv_tbl            => l_scrv_tbl_in);

                               LOG_MESSAGES('OKS_SALES_CREDIT_PUB.Lock_Sales_credit: '||l_return_status);
                        IF l_return_status = G_RET_STS_SUCCESS THEN
                                LOG_MESSAGES('SALES_PERSON in OKS_SALES_CREDIT Lock status: '||l_return_status);

                               OKS_SALES_CREDIT_PUB.update_Sales_credit(
                                                p_api_version         => l_api_version,
                                                p_init_msg_list       => l_init_msg_list,
                                                x_return_status       => l_return_status,
                                                x_msg_count           => l_msg_count,
                                                x_msg_data            => l_msg_data,
                                                p_scrv_tbl            => l_scrv_tbl_in,
                                                x_scrv_tbl            => l_scrv_tbl_out);

                        IF l_return_status = G_RET_STS_SUCCESS THEN
                                LOG_MESSAGES('SALES_PERSON in OKS_SALES_CREDIT update status: '||l_return_status);
                        ELSE
                            IF l_msg_count > 0
                            THEN
                            FOR i in 1..l_msg_count
                            LOOP
                                    fnd_msg_pub.get (p_msg_index     => -1,
                                                     p_encoded       => 'F',
                                                     p_data          => l_msg_data,
                                                     p_msg_index_out => l_msg_index_out);

                                    l_message := l_message||' ; '||l_msg_data;

                            END LOOP;
                            END IF;
                                LOG_MESSAGES('SALES_PERSON in OKS_SALES_CREDIT update status: '||l_return_status);
                                LOG_MESSAGES('SALES_PERSON in OKS_SALES_CREDIT Update failed;'||l_message);
                                l_status := 'ERROR';
                                RAISE G_EXCEPTION_HALT_VALIDATION;
                            END IF;
                    ELSE
                        IF l_msg_count > 0
                        THEN
                        FOR i in 1..l_msg_count
                        LOOP
                                 fnd_msg_pub.get (p_msg_index     => -1,
                                                  p_encoded       => 'F',
                                                  p_data          => l_msg_data,
                                                  p_msg_index_out => l_msg_index_out);

                                    l_message := l_message||' ; '||l_msg_data;

                        END LOOP;
                        END IF;
                              LOG_MESSAGES('SALES_PERSON in OKS_SALES_CREDIT Lock status: '||l_return_status);
                              LOG_MESSAGES('SALES_PERSON in OKS_SALES_CREDIT Lock failed;'||l_message);
                              l_status := 'ERROR';
                              RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                  END IF;
       ELSIF l_criteria_rec.attribute = 'REV_ACCT' then

       FOR revenue_rec IN  Get_revenue(l_eligible_contracts_tbl(i).contract_id,l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_rdsv_rec_in.id		                 := revenue_rec.id;
            l_rdsv_rec_in.object_version_number      := revenue_rec.object_version_number;
       END LOOP;
	If l_rdsv_rec_in.id Is Not Null Then
                   OKS_REV_DISTR_PUB.lock_Revenue_Distr(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_rdsv_rec            => l_rdsv_rec_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_rdsv_rec_in.code_combination_id  := l_new_value_id;

                OKS_REV_DISTR_PUB.update_Revenue_Distr(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_rdsv_rec            => l_rdsv_rec_in,
                                        x_rdsv_rec            => l_rdsv_rec_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('REVENUE_ACCOUNT update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('REVENUE_ACCOUNT update status: '||l_return_status);
                        LOG_MESSAGES('REVENUE_ACCOUNT Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('REVENUE_ACCOUNT lock status: '||l_return_status);
                LOG_MESSAGES('REVENUE_ACCOUNT lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	End If;
       ELSIF l_criteria_rec.attribute = 'PARTY_SHIPPING_CONTACT' then

       FOR contact_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'SHIPPING','OKX_PCONTACT',l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_ctcv_rec_in.id		                 := contact_rec.id;
            l_ctcv_rec_in.object_version_number      := contact_rec.object_version_number;
       END LOOP;
	If l_ctcv_rec_in.id Is Not null Then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_rec            => l_ctcv_rec_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_ctcv_rec_in.object1_id1  := l_new_value_id;

                OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_rec            => l_ctcv_rec_in,
                                        x_ctcv_rec            => l_ctcv_rec_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('PARTY_SHIPPING_CONTACT update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('PARTY_SHIPPING_CONTACT update status: '||l_return_status);
                        LOG_MESSAGES('Party Shipping Contact Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('PARTY_SHIPPING_CONTACT rule lock status: '||l_return_status);
                LOG_MESSAGES('PARTY_SHIPPING_CONTACT rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	End If;
       ELSIF l_criteria_rec.attribute = 'PARTY_BILLING_CONTACT' then

       FOR contact_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'BILLING','OKX_PCONTACT',l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_ctcv_rec_in.id		                 := contact_rec.id;
            l_ctcv_rec_in.object_version_number      := contact_rec.object_version_number;
        LOG_MESSAGES('Inside PARTY_BILLING_CONTACT:'||l_ctcv_rec_in.id);
       END LOOP;
	 If l_ctcv_rec_in.id is not null Then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_rec            => l_ctcv_rec_in);

        LOG_MESSAGES('After OKC_CTC_PVT.lock_row, status:'||l_return_status);
         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_ctcv_rec_in.object1_id1  := l_new_value_id;
         l_return_status := NULL;
                OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_rec            => l_ctcv_rec_in,
                                        x_ctcv_rec            => l_ctcv_rec_out);
        LOG_MESSAGES('After OKC_CTC_PVT.update_row, status:'||l_return_status);
                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('PARTY_BILLING_CONTACT update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('PARTY_BILLING_CONTACT update status: '||l_return_status);
                        LOG_MESSAGES('Party Billing Contact Update failed;'||l_message);
                        l_status := 'ERROR';
        LOG_MESSAGES('1');
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('PARTY_BILLING_CONTACT rule lock status: '||l_return_status);
                LOG_MESSAGES('PARTY_BILLING_CONTACT rule lock failed;'||l_message);
                l_status := 'ERROR';
        LOG_MESSAGES('2');
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	End If;
       ELSIF l_criteria_rec.attribute = 'LINE_SHIPPING_CONTACT' then

            l_ctcv_tbl_in.DELETE;
            l_ctcv_tbl_out.DELETE;
            cnt := 1;

       FOR contact_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'CUST_SHIPPING','OKX_CONTSHIP',l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_ctcv_tbl_in(cnt).id		                  := contact_rec.id;
            l_ctcv_tbl_in(cnt).object_version_number      := contact_rec.object_version_number;
            l_ctcv_tbl_in(cnt).object1_id1                := l_new_value_id ;
            cnt := cnt + 1 ;
       END LOOP;
	If l_ctcv_tbl_in.count > 0 Then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

--         l_ctcv_rec_in.object1_id1  := l_new_value_id;

                OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in,
                                        x_ctcv_tbl            => l_ctcv_tbl_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('LINE_SHIPPING_CONTACT update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('LINE_SHIPPING_CONTACT update status: '||l_return_status);
                        LOG_MESSAGES('Line Shipping Contact Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('LINE_SHIPPING_CONTACT rule lock status: '||l_return_status);
                LOG_MESSAGES('LINE_SHIPPING_CONTACT rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	End If;
       ELSIF l_criteria_rec.attribute = 'LINE_BILLING_CONTACT' then

            l_ctcv_tbl_in.DELETE;
            l_ctcv_tbl_out.DELETE;
            cnt := 1;

       FOR contact_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'CUST_BILLING','OKX_CONTBILL',l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_ctcv_tbl_in(cnt).id		                 := contact_rec.id;
            l_ctcv_tbl_in(cnt).object_version_number      := contact_rec.object_version_number;
            l_ctcv_tbl_in(cnt).object1_id1                := l_new_value_id;
            cnt := cnt + 1 ;
       END LOOP;
	If l_ctcv_tbl_in.count > 0 Then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in);

            IF l_return_status = G_RET_STS_SUCCESS THEN

--         l_ctcv_rec_in.object1_id1  := l_new_value_id;
--         l_return_status := NULL;
                OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in,
                                        x_ctcv_tbl            => l_ctcv_tbl_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('LINE_BILLING_CONTACT update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('LINE_BILLING_CONTACT update status: '||l_return_status);
                        LOG_MESSAGES('Line Billing Contact Update failed;'||l_message);
                        l_status := 'ERROR';

                        RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('LINE_BILLING_CONTACT rule lock status: '||l_return_status);
                LOG_MESSAGES('LINE_BILLING_CONTACT rule lock failed;'||l_message);
                l_status := 'ERROR';

                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	End If;
      ELSIF l_criteria_rec.attribute = 'HDR_SHIP_TO_ADDRESS' then

            l_chrv_rec_in.id		             := l_eligible_contracts_tbl(i).contract_id ;
            l_chrv_rec_in.object_version_number  := l_eligible_contracts_tbl(i).object_version_number;


            OKC_CONTRACT_PUB.lock_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_chrv_rec            => l_chrv_rec_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_chrv_rec_in.ship_to_site_use_id  := l_new_value_id;

              OKC_CONTRACT_PUB.update_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_restricted_update   => 'F' ,
                                        p_chrv_rec            => l_chrv_rec_in,
                                        x_chrv_rec            => l_chrv_rec_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('SHIP_TO_ADDRESS update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('SHIP_TO_ADDRESS update status: '||l_return_status);
                        LOG_MESSAGES('Ship-To Address Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('SHIP_TO_ADDRESS rule lock status: '||l_return_status);
                LOG_MESSAGES('SHIP_TO_ADDRESS rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

      ELSIF l_criteria_rec.attribute = 'PAYMENT_TERM' then

            l_chrv_rec_in.id		             := l_eligible_contracts_tbl(i).contract_id ;
            l_chrv_rec_in.object_version_number  := l_eligible_contracts_tbl(i).object_version_number;

                OKC_CONTRACT_PUB.lock_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_chrv_rec            => l_chrv_rec_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_chrv_rec_in.payment_term_id  := l_new_value_id;

              OKC_CONTRACT_PUB.update_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_restricted_update   => 'F' ,
                                        p_chrv_rec            => l_chrv_rec_in,
                                        x_chrv_rec            => l_chrv_rec_out);


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('PAYMENT_TERM update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('PAYMENT_TERM update status: '||l_return_status);
                        LOG_MESSAGES('PAYMENT_TERM Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('PAYMENT_TERM rule lock status: '||l_return_status);
                LOG_MESSAGES('PAYMENT_TERM rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

      ELSIF l_criteria_rec.attribute = 'CON_RENEWAL_TYPE' then

       If l_new_value_id = '-9999' then
          l_new_value_id := Null;
       End If;
            l_chrv_rec_in.id		         := l_eligible_contracts_tbl(i).contract_id ;
            l_chrv_rec_in.object_version_number  := l_eligible_contracts_tbl(i).object_version_number;

                OKC_CONTRACT_PUB.lock_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_chrv_rec            => l_chrv_rec_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN
         If l_new_value_id = 'ERN' then
              l_chrv_rec_in.renewal_type_code  := 'NSR';
         Else
              l_chrv_rec_in.renewal_type_code  := l_new_value_id;
         End If;

              OKC_CONTRACT_PUB.update_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_restricted_update   => 'F' ,
                                        p_chrv_rec            => l_chrv_rec_in,
                                        x_chrv_rec            => l_chrv_rec_out);


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('CON_RENEWAL_TYPE update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('CON_RENEWAL_TYPE update status: '||l_return_status);
                        LOG_MESSAGES('CON_RENEWAL_TYPE Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('CON_RENEWAL_TYPE  lock status: '||l_return_status);
                LOG_MESSAGES('CON_RENEWAL_TYPE  lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

     -- Electronic renewal flag update

       FOR rec IN Get_Electronic_Ren_YN(l_eligible_contracts_tbl(i).contract_id )
       LOOP
            l_khrv_rec_type_in.id	   	     := rec.id;
            l_khrv_rec_type_in.object_version_number := rec.object_version_number;

       END LOOP;

                OKS_CONTRACT_HDR_PUB.lock_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in );


           IF l_return_status = G_RET_STS_SUCCESS THEN

           If l_new_value_id = 'ERN' then
              l_khrv_rec_type_in.ELECTRONIC_RENEWAL_FLAG  := 'Y';
           Else
              l_khrv_rec_type_in.ELECTRONIC_RENEWAL_FLAG  := Null;
           End If;

                OKS_CONTRACT_HDR_PUB.update_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in,
                                        x_khrv_rec            => l_khrv_rec_type_out,
                                        p_validate_yn         => 'Y');


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('CON_RENEWAL_TYPE  update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('CON_RENEWAL_TYPE update status: '||l_return_status);
                        LOG_MESSAGES('CON_RENEWAL_TYPE Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F',
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('CON_RENEWAL_TYPE  lock status: '||l_return_status);
                LOG_MESSAGES('CON_RENEWAL_TYPE  lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;


       ELSIF l_criteria_rec.attribute = 'ACCT_RULE' then

       FOR rec IN Get_Acct_Rule(l_eligible_contracts_tbl(i).contract_id , l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_khrv_rec_type_in.id	   	                  := rec.id;
            l_khrv_rec_type_in.object_version_number      := rec.object_version_number;

       END LOOP;
	If l_khrv_rec_type_in.id Is Not Null Then
                OKS_CONTRACT_HDR_PUB.lock_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in );


           IF l_return_status = G_RET_STS_SUCCESS THEN

           l_khrv_rec_type_in.acct_rule_id  := l_new_value_id;

                OKS_CONTRACT_HDR_PUB.update_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in,
                                        x_khrv_rec            => l_khrv_rec_type_out,
                                        p_validate_yn         => 'Y');


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('ACCT_RULE update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('ACCT_RULE update status: '||l_return_status);
                        LOG_MESSAGES('ACCT_RULE Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('ACCT_RULE rule lock status: '||l_return_status);
                LOG_MESSAGES('ACCT_RULE rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	End If;
   ELSIF l_criteria_rec.attribute = 'SUMMARY_PRINT' then

       FOR rec IN Get_Summary_Print(l_eligible_contracts_tbl(i).contract_id , l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_khrv_rec_type_in.id	   	     := rec.id;
            l_khrv_rec_type_in.object_version_number := rec.object_version_number;

       END LOOP;
	If l_khrv_rec_type_in.id Is Not Null Then
                OKS_CONTRACT_HDR_PUB.lock_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in );


           IF l_return_status = G_RET_STS_SUCCESS THEN

           l_khrv_rec_type_in.inv_print_profile  := l_new_value_id;

                OKS_CONTRACT_HDR_PUB.update_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in,
                                        x_khrv_rec            => l_khrv_rec_type_out,
                                        p_validate_yn         => 'Y');


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('SUMMARY_PRINT update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('SUMMARY_PRINT update status: '||l_return_status);
                        LOG_MESSAGES('SUMMARY_PRINT Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('SUMMARY_PRINT  lock status: '||l_return_status);
                LOG_MESSAGES('SUMMARY_PRINT  lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	End If;
   ELSIF l_criteria_rec.attribute = 'PO_REQUIRED_REN' then

       FOR rec IN Get_po_required_ren(l_eligible_contracts_tbl(i).contract_id ,
                                       l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_khrv_rec_type_in.id  	                  := rec.id;
            l_khrv_rec_type_in.object_version_number      := rec.object_version_number;

       END LOOP;
	 If l_khrv_rec_type_in.id Is Not Null Then
                OKS_CONTRACT_HDR_PUB.lock_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in );

           IF l_return_status = G_RET_STS_SUCCESS THEN

           l_khrv_rec_type_in.renewal_po_required  := l_new_value_id;

                OKS_CONTRACT_HDR_PUB.update_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_khrv_rec            => l_khrv_rec_type_in,
                                        x_khrv_rec            => l_khrv_rec_type_out,
                                        p_validate_yn         => 'Y');


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('PO Required update status: '||l_return_status);
                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('PO Required update status: '||l_return_status);
                        LOG_MESSAGES('PO Required Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('PO Required  lock status: '||l_return_status);
                LOG_MESSAGES('PO Required  lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	END IF;
       ELSIF l_criteria_rec.attribute = 'INV_RULE' then

            l_chrv_rec_in.id		             := l_eligible_contracts_tbl(i).contract_id ;
            l_chrv_rec_in.object_version_number  := l_eligible_contracts_tbl(i).object_version_number;

                OKC_CONTRACT_PUB.lock_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_chrv_rec            => l_chrv_rec_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN
            l_chrv_rec_in.inv_rule_id  := l_new_value_id;

            OKC_CONTRACT_PUB.update_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_restricted_update   => 'F' ,
                                        p_chrv_rec            => l_chrv_rec_in,
                                        x_chrv_rec            => l_chrv_rec_out);

              IF l_return_status = G_RET_STS_SUCCESS THEN
                 LOG_MESSAGES('INV_RULE update status: '||l_return_status);

                 FOR rec_line_id in Get_lines_csr (l_eligible_contracts_tbl(i).contract_id) LOOP

                       Update Okc_k_lines_b set inv_rule_id = l_new_value_id
                       Where id = rec_line_id.id;

                        oks_bill_sch.update_bs_interface_date(
                                   p_top_line_id      => rec_line_id.id,
                                   p_invoice_rule_id  => l_new_value_id,
                                   x_return_status    => l_return_status,
                                   x_msg_count        => l_msg_count,
                                   x_msg_data         => l_msg_data);





                 END LOOP ;

                        IF l_return_status = G_RET_STS_SUCCESS THEN
                           LOG_MESSAGES('INV_RULE update_bs_interface_date: '||l_return_status);

                        ELSE
                           IF l_msg_count > 0 THEN
                              FOR i in 1..l_msg_count
                              LOOP
                              fnd_msg_pub.get (p_msg_index     => -1,
                                               p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                               p_data          => l_msg_data,
                                               p_msg_index_out => l_msg_index_out);

                              l_message := l_message||' ; '||l_msg_data;

                              END LOOP;
                           END IF;

                            LOG_MESSAGES('INV_RULE update_bs_interface_date: '||l_return_status);
                            LOG_MESSAGES('INV_RULE update_bs_interface_date Update failed;'||l_message);
                            l_status := 'ERROR';
                            RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('INV_RULE update status: '||l_return_status);
                        LOG_MESSAGES('INV_RULE Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('INV_RULE rule lock status: '||l_return_status);
                LOG_MESSAGES('INV_RULE rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;



   ELSIF l_criteria_rec.attribute = 'COV_TYPE' then
    l_klnv_tbl_type_in.DELETE;
       cnt := 1;

       FOR rec IN Get_cov_type(l_eligible_contracts_tbl(i).contract_id,l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_klnv_tbl_type_in(cnt).id	   	                  := rec.id;
            l_klnv_tbl_type_in(cnt).object_version_number      := rec.object_version_number;
            l_klnv_tbl_type_in(cnt).coverage_type              := l_new_value_id;
            cnt := cnt + 1 ;
       END LOOP;
	If l_klnv_tbl_type_in.count > 0 Then
                OKS_CONTRACT_LINE_PUB.lock_line(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_klnv_tbl            => l_klnv_tbl_type_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

                OKS_CONTRACT_LINE_PUB.update_line(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_klnv_tbl            => l_klnv_tbl_type_in,
                                        x_klnv_tbl            => l_klnv_tbl_type_out,
                                        p_validate_yn         => 'Y');

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('COV_TYPE update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('COV_TYPE update status: '||l_return_status);
                        LOG_MESSAGES('COV_TYPE Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;


                LOG_MESSAGES('COV_TYPE rule lock status: '||l_return_status);
                LOG_MESSAGES('COV_TYPE rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	End If;
   ELSIF l_criteria_rec.attribute = 'BP_PRICE_LIST' then
       l_clev_tbl_in.DELETE;
       l_clev_tbl_out.DELETE;
       cnt := 1;

       If l_new_value_id = '-9999' then
          l_new_value_id := Null;
       End If;

       If l_criteria_rec.old_value  = '-9999' then
           FOR rec IN get_bp_lines_null (l_eligible_contracts_tbl(i).contract_id)
           LOOP
               l_clev_tbl_in(cnt).id	   	          := rec.id;
               l_clev_tbl_in(cnt).object_version_number      := rec.object_version_number;
               l_clev_tbl_in(cnt).price_list_id              := l_new_value_id;
               cnt := cnt + 1 ;
           END LOOP;
       Elsif l_criteria_rec.old_value = '-1111' then
           FOR rec IN get_bp_lines_all (l_eligible_contracts_tbl(i).contract_id)
           LOOP
               l_clev_tbl_in(cnt).id	   	          := rec.id;
               l_clev_tbl_in(cnt).object_version_number      := rec.object_version_number;
               l_clev_tbl_in(cnt).price_list_id              := l_new_value_id;
               cnt := cnt + 1 ;
           END LOOP;
       Else
           FOR rec IN get_bp_lines (l_eligible_contracts_tbl(i).contract_id
                                   ,l_eligible_contracts_tbl(i).old_value)
           LOOP
               l_clev_tbl_in(cnt).id           	          := rec.id;
               l_clev_tbl_in(cnt).object_version_number      := rec.object_version_number;
               l_clev_tbl_in(cnt).price_list_id              := l_new_value_id;
               cnt := cnt + 1 ;
           END LOOP;
       End If;

	If l_clev_tbl_in.count > 0 Then
                OKC_CONTRACT_PUB.lock_contract_line(
                                p_api_version      => l_api_version,
                                p_init_msg_list    => l_init_msg_list,
                                x_return_status    => l_return_status,
                                x_msg_count        => l_msg_count,
                                x_msg_data         => l_msg_data,
                                p_clev_tbl         => l_clev_tbl_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

                 OKC_CONTRACT_PUB.update_contract_line(
                            	p_api_version		=> l_api_version,
                              	p_init_msg_list		=> l_init_msg_list,
                            	x_return_status		=> l_return_status,
                            	x_msg_count		=> l_msg_count,
                             	x_msg_data		=> l_msg_data,
                                p_clev_tbl              => l_clev_tbl_in,
                                x_clev_tbl              => l_clev_tbl_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('BP Price List update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('BP Price List update status: '||l_return_status);
                        LOG_MESSAGES('BP Price List Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;


                LOG_MESSAGES('BP Price List lock status: '||l_return_status);
                LOG_MESSAGES('BP Price List lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	End If;
      ELSIF l_criteria_rec.attribute = 'COV_TIMEZONE' then
         l_ctz_tblType_in.delete;
         l_ctz_tblType_out.delete;
         cnt := 1;
         FOR rec IN Get_timezone(l_eligible_contracts_tbl(i).contract_id , l_eligible_contracts_tbl(i).old_value)
         LOOP
            l_ctz_tblType_in(cnt).id		          := rec.id ;
            l_ctz_tblType_in(cnt).OBJECT_VERSION_NUMBER   := rec.OBJECT_VERSION_NUMBER;
            l_ctz_tblType_in(cnt).cle_id                  := rec.cle_id;
            l_ctz_tblType_in(cnt).timezone_id             := l_new_value_id;

            OKS_COVERAGES_PVT.CHECK_TimeZone_Exists
                               ( p_api_version            => l_api_version
                                 ,p_init_msg_list         => l_init_msg_list
                                 ,x_return_status         => l_return_status
                                 ,x_msg_count             => l_msg_count
                                 ,x_msg_data              => l_msg_data
                                 ,P_BP_Line_ID            => l_ctz_tblType_in(cnt).cle_id
                                 ,P_TimeZone_Id           => l_new_value_id
                                 ,x_TimeZone_Exists       => l_timezone_exists_YN );

            LOG_MESSAGES('Coverage Timezone Duplicate Check status: '||l_return_status);
            If l_return_status <> G_RET_STS_SUCCESS then
                IF l_msg_count > 0 then
                    FOR i in 1..l_msg_count
                    LOOP
                        fnd_msg_pub.get (p_msg_index     => -1,
                                         p_encoded       => 'F',
                                         p_data          => l_msg_data,
                                         p_msg_index_out => l_msg_index_out);
                        l_message := l_message||' ; '||l_msg_data;
                    END LOOP;
                END IF;
                LOG_MESSAGES('Coverage Timezone Duplicate Check : '||l_return_status);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            Else
                If l_timezone_exists_YN = 'N' then
                   cnt := cnt + 1;
                Else
                   LOG_MESSAGES('Contract Number : '||l_eligible_contracts_tbl(i).contract_number);
                   LOG_MESSAGES('Timezone Exists for BP: '||to_char(l_ctz_tblType_in(cnt).cle_id));
                   l_message := l_message||' ; '||'Timezone already exists for the Contract Business Process';
                   l_status := 'ERROR';
                   RAISE G_EXCEPTION_HALT_VALIDATION;
                End If;
            End If;

         END LOOP;

         If (l_ctz_tblType_in.count > 0) then
             OKS_CTZ_PVT.lock_row(
                               p_api_version                   => l_api_version,
                               p_init_msg_list                 => l_init_msg_list,
                               x_return_status                 => l_return_status,
                               x_msg_count                     => l_msg_count,
                               x_msg_data                      => l_msg_data,
                               p_oks_coverage_timezones_v_tbl  => l_ctz_tblType_in);

             IF l_return_status = G_RET_STS_SUCCESS THEN

              OKS_CTZ_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_oks_coverage_timezones_v_tbl            => l_ctz_tblType_in,
                                        x_oks_coverage_timezones_v_tbl            => l_ctz_tblType_out);


                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('Coverage Timezone update status: '||l_return_status);
                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;
                        LOG_MESSAGES('Coverage Timezone update status: '||l_return_status);
                        LOG_MESSAGES('Coverage Timezone Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

             ELSE
                 IF l_msg_count > 0
                 THEN
                 FOR i in 1..l_msg_count
                 LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F',
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                 END LOOP;
                 END IF;
                  LOG_MESSAGES('Coverage Timezone lock status: '||l_return_status);
                  LOG_MESSAGES('Coverage Timezone lock failed;'||l_message);
                  l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
        End If;

      ELSIF l_criteria_rec.attribute = 'PREF_ENGG' then
            l_ctcv_tbl_in.DELETE;
            l_ctcv_tbl_out.DELETE;
            cnt := 1;

            FOR pref_engg_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'ENGINEER','OKX_RESOURCE',l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_ctcv_tbl_in(cnt).id		                 := pref_engg_rec.id;
            l_ctcv_tbl_in(cnt).object_version_number      := pref_engg_rec.object_version_number;
            l_ctcv_tbl_in(cnt).object1_id1                := l_new_value_id;
            cnt := cnt + 1 ;
       END LOOP;
	If l_ctcv_tbl_in.count > 0 Then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

--         l_ctcv_rec_in.object1_id1  := l_new_value_id;
  --       l_return_status := NULL;

                 OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in,
                                        x_ctcv_tbl            => l_ctcv_tbl_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('PREF_ENGG update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('PREF_ENGG update status: '||l_return_status);
                        LOG_MESSAGES('PREF_ENGG Update failed;'||l_message);
                        l_status := 'ERROR';

                        RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('PREF_ENGG rule lock status: '||l_return_status);
                LOG_MESSAGES('PREF_ENGG rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	END IF;
      ELSIF l_criteria_rec.attribute = 'RES_GROUP' then
            l_ctcv_tbl_in.DELETE;
            l_ctcv_tbl_out.DELETE;
            cnt := 1;


            FOR res_group_rec IN  Get_contact(l_eligible_contracts_tbl(i).contract_id,'RSC_GROUP','OKS_RSCGROUP',l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_ctcv_tbl_in(cnt).id		                 := res_group_rec.id;
            l_ctcv_tbl_in(cnt).object_version_number      := res_group_rec.object_version_number;
            l_ctcv_tbl_in(cnt).object1_id1                := l_new_value_id;
            cnt := cnt + 1 ;
       END LOOP;
	If l_ctcv_tbl_in.count > 0 Then
                   OKC_CTC_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

                 OKC_CTC_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_ctcv_tbl            => l_ctcv_tbl_in,
                                        x_ctcv_tbl            => l_ctcv_tbl_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('RES_GROUP update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('RES_GROUP update status: '||l_return_status);
                        LOG_MESSAGES('RES_GROUP Update failed;'||l_message);
                        l_status := 'ERROR';

                        RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('RES_GROUP rule lock status: '||l_return_status);
                LOG_MESSAGES('RES_GROUP rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	End If;
      ELSIF l_criteria_rec.attribute = 'AGREEMENT_NAME' then
       l_gvev_tbl_in.DELETE;
       l_gvev_tbl_out.DELETE;
       cnt := 1;

       FOR rule_rec IN Get_agreement_name(l_eligible_contracts_tbl(i).contract_id,l_eligible_contracts_tbl(i).old_value)
       LOOP
            l_gvev_tbl_in(cnt).id	   	                  := rule_rec.id;
            l_gvev_tbl_in(cnt).object_version_number      := rule_rec.object_version_number;
            l_gvev_tbl_in(cnt).isa_agreement_id           := l_new_value_id;
            cnt := cnt + 1 ;
       END LOOP;
	If l_gvev_tbl_in.count > 0 Then
                OKC_GVE_PVT.lock_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_gvev_tbl            => l_gvev_tbl_in);

         IF l_return_status = G_RET_STS_SUCCESS THEN

                OKC_GVE_PVT.update_row(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_gvev_tbl            => l_gvev_tbl_in,
                                        x_gvev_tbl            => l_gvev_tbl_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('AGREEMENT_NAME update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('AGREEMENT_NAME update status: '||l_return_status);
                        LOG_MESSAGES('AGREEMENT_NAME Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;


                LOG_MESSAGES('AGREEMENT_NAME rule lock status: '||l_return_status);
                LOG_MESSAGES('AGREEMENT_NAME lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	END IF;


      ELSIF l_criteria_rec.attribute = 'HDR_BILL_TO_ADDRESS' then

            l_chrv_rec_in.id		             := l_eligible_contracts_tbl(i).contract_id ;
            l_chrv_rec_in.object_version_number  := l_eligible_contracts_tbl(i).object_version_number;

            OKC_CONTRACT_PUB.lock_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_chrv_rec            => l_chrv_rec_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_chrv_rec_in.bill_to_site_use_id  := l_new_value_id;

              OKC_CONTRACT_PUB.update_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_restricted_update   => 'F' ,
                                        p_chrv_rec            => l_chrv_rec_in,
                                        x_chrv_rec            => l_chrv_rec_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('BILL_TO_ADDRESS update status: '||l_return_status);

                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                      END LOOP;
                      END IF;

                        LOG_MESSAGES('BILL_TO_ADDRESS update status: '||l_return_status);
                        LOG_MESSAGES('Bill-To Address Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('BILL_TO_ADDRESS rule lock status: '||l_return_status);
                LOG_MESSAGES('BILL_TO_ADDRESS rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;


      ELSIF l_criteria_rec.attribute = 'PRICE_LIST' then

	       l_currency_code      := NULL;
	       l_pricelist_valid    := NULL ;

            l_chrv_rec_in.id                     := l_eligible_contracts_tbl(i).contract_id ;
            l_chrv_rec_in.object_version_number  := l_eligible_contracts_tbl(i).object_version_number;

            Open get_contract_dtls (l_eligible_contracts_tbl(i).contract_id);
		      Fetch get_contract_dtls  into l_currency_code ;
            Close get_contract_dtls;

            LOG_MESSAGES('Price List ID:  '||l_new_value_id);
            LOG_MESSAGES('Currency Code:  '||l_currency_code);
            QP_UTIL_PUB.Validate_Price_list_Curr_code
                                  ( l_price_list_id           => to_number(l_new_value_id)
                                   ,l_currency_code           => l_currency_code
	                              ,l_pricing_effective_date  => sysdate
		                         ,l_validate_result         => l_pricelist_valid );

            LOG_MESSAGES('Is PL Valid?:  '||l_pricelist_valid);

            If nvl(l_pricelist_valid,'N') <> 'Y' then
                 LOG_MESSAGES('After pricelist validity check; Price List is invalid ');
                 l_status   := 'ERROR';
	         l_message  := FND_MESSAGE.get_string('OKS','OKS_INVALID_PRICE_LIST') ;
                 RAISE G_EXCEPTION_HALT_VALIDATION;
            End If;

            OKC_CONTRACT_PUB.lock_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_chrv_rec            => l_chrv_rec_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

--         l_chrv_rec_in.bill_to_site_use_id  := l_new_value_id;
         l_chrv_rec_in.price_list_id  := to_number(l_new_value_id);

              OKC_CONTRACT_PUB.update_contract_header(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_restricted_update   => 'F' ,
                                        p_chrv_rec            => l_chrv_rec_in,
                                        x_chrv_rec            => l_chrv_rec_out);

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('PRICE_LIST update status: '||l_return_status);
                        l_old_k_amount := Get_contract_amount(l_eligible_contracts_tbl(i).contract_id);
                                          LOG_MESSAGES('After Get_contract_amount');
                        OKS_REPRICE_PVT.Call_Pricing_Api(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        P_id        		  => l_eligible_contracts_tbl(i).contract_id,
				                    P_Id_Type		      => 'CHR',
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data);

              IF  l_return_status = G_RET_STS_SUCCESS THEN
                LOG_MESSAGES('PRICE_LIST Repricing status for lines: '||l_return_status);
                FOR rec IN Get_cle_id(l_eligible_contracts_tbl(i).contract_id)
                LOOP
                    LOG_MESSAGES('Inside Loop for PRICE_LIST');
                    OKS_BILL_SCH.Cascade_Dates_SLL (rec.id,l_return_status,l_msg_count,l_msg_data) ;
                    IF l_return_status = G_RET_STS_SUCCESS THEN
                       LOG_MESSAGES('CONTRACT_HEADER(Price List) Billing Schedule status for lines: '||l_return_status);
                    ELSE
                        IF l_msg_count > 0
                        THEN
                        FOR i in 1..l_msg_count
                        LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                            l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                        END IF;

                    LOG_MESSAGES('Price List Billing Schedule status: '||l_return_status);
                    LOG_MESSAGES('Price List Billing Schedule failed;'||l_message);
                    l_status := 'ERROR';
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
                END LOOP ;
              END IF ;

                l_new_k_amount := Get_contract_amount(l_eligible_contracts_tbl(i).contract_id);
                l_amt_message := rpad(' ',30,' ')||'Old Contract Amount: '||rpad(l_old_k_amount,20,' ')||'New Contract Amount: '||rpad(l_new_k_amount,20,' ');
                    IF l_return_status = G_RET_STS_SUCCESS THEN
                         LOG_MESSAGES('PRICE_LIST Repricing status: '||l_return_status);
                    ELSE
                        IF l_msg_count > 0
                        THEN
                        FOR i in 1..l_msg_count
                        LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                            l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                        END IF;

                        LOG_MESSAGES('PRICE_LIST Repricing status: '||l_return_status);
                        LOG_MESSAGES('PRICE_LIST Repricing  failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;
                 ELSE
                      IF l_msg_count > 0
                      THEN
                      FOR i in 1..l_msg_count
                      LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);

                            l_message := l_message||' ; '||l_msg_data;

                       END LOOP;
                       END IF;

                        LOG_MESSAGES('PRICE_LIST update status: '||l_return_status);
                        LOG_MESSAGES('Price List Update failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

          ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F',
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('PRICE_LIST rule lock status: '||l_return_status);
                LOG_MESSAGES('PRICE _LIST rule lock failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

      ELSIF l_criteria_rec.attribute = 'COVERAGE_START_TIME' then

            l_cvt_tbl_in.DELETE;
            l_cvt_tbl_out.DELETE;
            cvr_cnt := 1;

            l_hour   := trunc(to_number(l_eligible_contracts_tbl(i).old_value)/60);
            l_minute := mod(to_number(l_eligible_contracts_tbl(i).old_value),60);
       FOR cvr_rec IN Get_cvr_start(l_eligible_contracts_tbl(i).contract_id,l_hour, l_minute)
       LOOP

           IF trunc(to_number(l_new_value_id)/60) > cvr_rec.end_hour THEN
              l_cov_time_wrong := l_cov_time_wrong + 1;

           ELSIF trunc(to_number(l_new_value_id)/60) = cvr_rec.end_hour AND
                 mod(to_number(l_new_value_id),60) >= cvr_rec.end_minute THEN
                 l_cov_time_wrong := l_cov_time_wrong + 1;

           ELSE
               l_cov_time_right := l_cov_time_right + 1 ;
               l_cvt_tbl_in(cnt).id     := cvr_rec.ID;
               l_cvt_tbl_in(cnt).OBJECT_VERSION_NUMBER     := cvr_rec.OBJECT_VERSION_NUMBER;
               l_cvt_tbl_in(cnt).start_hour   := trunc(to_number(l_new_value_id)/60);
               l_cvt_tbl_in(cnt).start_minute := mod(to_number(l_new_value_id),60);
               cnt := cnt + 1;
           END IF ;
       END LOOP;
	 If l_cvt_tbl_in.count > 0 Then
              OKS_CVT_PVT.lock_row(     p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_oks_coverage_times_v_tbl	      => l_cvt_tbl_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

            OKS_CVT_PVT.update_row(     p_api_version                  => l_api_version,
                                        p_init_msg_list                => l_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => l_msg_count,
                                        x_msg_data                     => l_msg_data,
                                        p_oks_coverage_times_v_tbl     => l_cvt_tbl_in,
                                        x_oks_coverage_times_v_tbl     => l_cvt_tbl_out);


                IF  l_return_status = G_RET_STS_SUCCESS THEN

                    LOG_MESSAGES('COVERAGE_START_TIME update status: '||l_return_status);

                    -- Check for coverage time over lap
                    l_overlap_type := Null;
                    For tz_rec IN  Get_cvr_timezone(l_eligible_contracts_tbl(i).contract_id)
                    Loop
                        l_time_zone_id := tz_rec.ID;
                        OKS_COVERAGES_PVT.VALIDATE_COVERTIME(
                                    p_tze_line_id      => l_time_zone_id,
                                    x_days_overlap     => l_overlap_type,
                                    x_return_status    => l_return_status);
                        If l_return_status = G_RET_STS_SUCCESS Then
                             If (l_overlap_type.monday_overlap      = 'Y' OR
                                 l_overlap_type.tuesday_overlap     = 'Y' OR
                                 l_overlap_type.wednesday_overlap   = 'Y' OR
                                 l_overlap_type.thursday_overlap    = 'Y' OR
                                 l_overlap_type.friday_overlap      = 'Y' OR
                                 l_overlap_type.saturday_overlap    = 'Y' OR
                                 l_overlap_type.sunday_overlap      = 'Y'  ) Then

                                     l_status  := 'ERROR';
                                     l_message := l_message|| ' Covered time overlaps ';
                                     LOG_MESSAGES('COVERAGE_START_TIME Overlaps ');
                                     RAISE G_EXCEPTION_HALT_VALIDATION;
                             End If;
                        Else
                            If l_msg_count > 0 Then
                               FOR i in 1..l_msg_count
                               LOOP
                                  fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                                             l_message := l_message||' ; '||l_msg_data;
                                END LOOP;
                             End If; -- message count

                             LOG_MESSAGES('Coverage Start Time Update failed;'||l_message);
                             l_status := 'ERROR';
                             RAISE G_EXCEPTION_HALT_VALIDATION;
                        End If; -- validate cover time retunr status
                    End Loop ;
                ELSE
                    IF l_msg_count > 0
                    THEN
                    FOR i in 1..l_msg_count
                    LOOP
                        fnd_msg_pub.get (p_msg_index     => -1,
                                         p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                         p_data          => l_msg_data,
                                         p_msg_index_out => l_msg_index_out);
                        l_message := l_message||' ; '||l_msg_data;
                    END LOOP;
                    END IF;
                    LOG_MESSAGES('COVERAGE_START_TIME update status: '||l_return_status);
                    LOG_MESSAGES('Coverage Start Time Update failed;'||l_message);
                    l_status := 'ERROR';
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

            ELSE
                     IF l_msg_count > 0
                     THEN
                        FOR i in 1..l_msg_count
                        LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                            l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                      END IF;

                        LOG_MESSAGES('COVERAGE_START_TIME status: '||l_return_status);
                        LOG_MESSAGES('COVERAGE_START_TIME failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

	End If;

   ELSIF l_criteria_rec.attribute = 'COVERAGE_END_TIME' then
          cnt := 1;
          l_cvt_tbl_in.DELETE;
          l_cvt_tbl_out.DELETE;

          l_hour   := trunc(to_number(l_eligible_contracts_tbl(i).old_value)/60);
          l_minute := mod(to_number(l_eligible_contracts_tbl(i).old_value),60);
       FOR cvr_rec IN Get_cvr_end(l_eligible_contracts_tbl(i).contract_id,l_hour, l_minute)
       LOOP
           IF    trunc(to_number(l_new_value_id)/60) < cvr_rec.start_hour THEN
                 l_cov_time_wrong := l_cov_time_wrong + 1;

           ELSIF trunc(to_number(l_new_value_id)/60) = cvr_rec.start_hour AND
                 mod(to_number(l_new_value_id),60) <= cvr_rec.start_minute THEN
                 l_cov_time_wrong := l_cov_time_wrong + 1;
           ELSE
                 l_cov_time_right := l_cov_time_right + 1 ;
                 l_cvt_tbl_in(cnt).id     := cvr_rec.ID;
                 l_cvt_tbl_in(cnt).OBJECT_VERSION_NUMBER     := cvr_rec.OBJECT_VERSION_NUMBER;
                 l_cvt_tbl_in(cnt).end_hour   := trunc(to_number(l_new_value_id)/60);
                 l_cvt_tbl_in(cnt).end_minute := mod(to_number(l_new_value_id),60);
                 cnt := cnt + 1;
           END IF ;
       END LOOP;
	If l_cvt_tbl_in.count > 0 Then

              OKS_CVT_PVT.lock_row(     p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_oks_coverage_times_v_tbl	      => l_cvt_tbl_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

            OKS_CVT_PVT.update_row(     p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_oks_coverage_times_v_tbl	      => l_cvt_tbl_in,
                                        x_oks_coverage_times_v_tbl        => l_cvt_tbl_out);


                IF  l_return_status = G_RET_STS_SUCCESS THEN
                    LOG_MESSAGES('COVERAGE_END_TIME update status: '||l_return_status);
                    -- Check for coverage time overlap
                    l_overlap_type := Null;
                    For tz_rec IN  Get_cvr_timezone(l_eligible_contracts_tbl(i).contract_id)
                    Loop
                        l_time_zone_id := tz_rec.ID;
                        OKS_COVERAGES_PVT.VALIDATE_COVERTIME(
                                    p_tze_line_id      => l_time_zone_id,
                                    x_days_overlap     => l_overlap_type,
                                    x_return_status    => l_return_status);
                        If l_return_status = G_RET_STS_SUCCESS Then
                             If (l_overlap_type.monday_overlap      = 'Y' OR
                                 l_overlap_type.tuesday_overlap     = 'Y' OR
                                 l_overlap_type.wednesday_overlap   = 'Y' OR
                                 l_overlap_type.thursday_overlap    = 'Y' OR
                                 l_overlap_type.friday_overlap      = 'Y' OR
                                 l_overlap_type.saturday_overlap    = 'Y' OR
                                 l_overlap_type.sunday_overlap      = 'Y'  ) Then

                                     l_status  := 'ERROR';
                                     l_message := l_message|| ' Covered time overlaps ';
                                     LOG_MESSAGES('COVERAGE End Time Overlaps ');
                                     RAISE G_EXCEPTION_HALT_VALIDATION;
                             End If;
                        Else
                            If l_msg_count > 0 Then
                               FOR i in 1..l_msg_count
                               LOOP
                                  fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F',
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                                             l_message := l_message||' ; '||l_msg_data;
                                END LOOP;
                             End If; -- message count

                             LOG_MESSAGES('Coverage End Time Update failed;'||l_message);
                             l_status := 'ERROR';
                             RAISE G_EXCEPTION_HALT_VALIDATION;
                        End If; -- validate cover time retunr status
                    End Loop ;
                ELSE
                    IF l_msg_count > 0
                    THEN
                    FOR i in 1..l_msg_count
                    LOOP
                        fnd_msg_pub.get (p_msg_index     => -1,
                                         p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                         p_data          => l_msg_data,
                                         p_msg_index_out => l_msg_index_out);
                        l_message := l_message||' ; '||l_msg_data;
                    END LOOP;
                    END IF;
                    LOG_MESSAGES('COVERAGE_END_TIME update status: '||l_return_status);
                    LOG_MESSAGES('Coverage End Time Update failed;'||l_message);
                    l_status := 'ERROR';
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                 END IF;

            ELSE
                     IF l_msg_count > 0
                     THEN
                        FOR i in 1..l_msg_count
                        LOOP
                            fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                            l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                      END IF;

                        LOG_MESSAGES('COVERAGE_END_TIME status: '||l_return_status);
                        LOG_MESSAGES('COVERAGE_END_TIME failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;
	END IF;
     ELSIF l_criteria_rec.attribute = 'REACTION_TIME' then


      LOG_MESSAGES('Inside Reaction time '||l_return_status);

        l_act_tbl_in.delete;
        l_act_tbl_out.delete;
        cnt := 1;
        FOR rec IN Get_act_time(l_eligible_contracts_tbl(i).contract_id,'RCN',l_old_value_id )
        LOOP
            l_act_tbl_in(cnt).id                        := rec.id;
            l_act_tbl_in(cnt).object_version_number     := rec.object_version_number;

            If    rec.sun_duration = l_old_value_id then
                  l_act_tbl_in(cnt).sun_duration              := l_new_value_id ;
            End If;
            If rec.mon_duration = l_old_value_id then
                  l_act_tbl_in(cnt).mon_duration              := l_new_value_id;
            End If;
            If rec.tue_duration = l_old_value_id then
                  l_act_tbl_in(cnt).tue_duration              := l_new_value_id;
            End If;
            If rec.wed_duration = l_old_value_id then
                  l_act_tbl_in(cnt).wed_duration              := l_new_value_id;
            End If;
            If rec.thu_duration = l_old_value_id then
                  l_act_tbl_in(cnt).thu_duration              := l_new_value_id;
            End If;
            If rec.fri_duration = l_old_value_id then
                  l_act_tbl_in(cnt).fri_duration              := l_new_value_id;
            End If;
            If rec.sat_duration = l_old_value_id then
                  l_act_tbl_in(cnt).sat_duration              := l_new_value_id;
            End If;

            cnt := cnt + 1;

        END LOOP;
	If l_act_tbl_in.count > 0 Then
        LOG_MESSAGES('Out side loop  Reaction time '||l_return_status);

         OKS_ACM_PVT.lock_row (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                           	p_oks_action_times_v_tbl			=> l_act_tbl_in);




         IF l_return_status = G_RET_STS_SUCCESS THEN

            OKS_ACM_PVT.update_row (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                        	p_oks_action_times_v_tbl		    => l_act_tbl_in,
    	                    x_oks_action_times_v_tbl		    => l_act_tbl_out );


           IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('Reaction update status: '||l_return_status);
           ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('Reaction Time update status: '||l_return_status);
                LOG_MESSAGES('Reaction Time Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;
         ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('Reaction Time status: '||l_return_status);
                LOG_MESSAGES('Reaction Time((Cognomen)) failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

	END IF;
      ELSIF l_criteria_rec.attribute = 'RESOLUTION_TIME' then

        l_act_tbl_in.delete;
        l_act_tbl_out.delete;
        cnt := 1;
        FOR rec IN Get_act_time(l_eligible_contracts_tbl(i).contract_id,'RSN',l_old_value_id )
        LOOP
              l_act_tbl_in(cnt).id                        := rec.id;
              l_act_tbl_in(cnt).object_version_number     := rec.object_version_number;


              If    rec.sun_duration = l_old_value_id then
                    l_act_tbl_in(cnt).sun_duration              := l_new_value_id ;
              End If;
              If rec.mon_duration = l_old_value_id then
                    l_act_tbl_in(cnt).mon_duration              := l_new_value_id;
              End If;
              If rec.tue_duration = l_old_value_id then
                    l_act_tbl_in(cnt).tue_duration              := l_new_value_id;
              End If;
              If rec.wed_duration = l_old_value_id then
                    l_act_tbl_in(cnt).wed_duration              := l_new_value_id;
              End If;
              If rec.thu_duration = l_old_value_id then
                    l_act_tbl_in(cnt).thu_duration              := l_new_value_id;
              End If;
              If rec.fri_duration = l_old_value_id then
                    l_act_tbl_in(cnt).fri_duration              := l_new_value_id;
              End If;
              If rec.sat_duration = l_old_value_id then
                    l_act_tbl_in(cnt).sat_duration              := l_new_value_id;
              End If ;

              cnt := cnt + 1;
        END LOOP;
	If l_act_tbl_in.count > 0 Then
         OKS_ACM_PVT.lock_row (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                           	p_oks_action_times_v_tbl			=> l_act_tbl_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

            OKS_ACM_PVT.update_row (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                        	p_oks_action_times_v_tbl		    => l_act_tbl_in,
    	                    x_oks_action_times_v_tbl		    => l_act_tbl_out );

           IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('Resolution update status: '||l_return_status);
           ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('Resolution Time update status: '||l_return_status);
                LOG_MESSAGES('Resolution Time Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;
         ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('Resolution Time status: '||l_return_status);
                LOG_MESSAGES('Resolution Time((Cognomen)) failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
	End If;
      ELSIF l_criteria_rec.attribute = 'CONTRACT_ALIAS' then

            l_chrv_tbl_in(1).id		                  := l_eligible_contracts_tbl(i).contract_id;
            l_chrv_tbl_in(1).object_version_number       := l_eligible_contracts_tbl(i).object_version_number;

         OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                           	p_chrv_tbl			=> l_chrv_tbl_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

         l_chrv_rec_in.id  := l_eligible_contracts_tbl(i).contract_id;
         l_chrv_rec_in.cognomen  := l_new_value_id;

          OKC_CONTRACT_PUB.update_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                        	p_chrv_rec		    => l_chrv_rec_in,
    	                    x_chrv_rec		    => l_chrv_rec_out );
                IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('CONTRACT_HEADER(Cognomen) update status: '||l_return_status);
                ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('CONTRACT_HEADER(Cognomen) update status: '||l_return_status);
                LOG_MESSAGES('Contract Header(Cognomen) Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
         ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('LOCK_CONTRACT(Cognomen) status: '||l_return_status);
                LOG_MESSAGES('Contract Lock((Cognomen)) failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

      ELSIF l_criteria_rec.attribute = 'PO_NUMBER_BILL' then


                     l_chrv_tbl_in(1).id		                     := l_eligible_contracts_tbl(i).contract_id;
                     l_chrv_tbl_in(1).object_version_number       := l_eligible_contracts_tbl(i).object_version_number;

                     OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                           	p_chrv_tbl			=> l_chrv_tbl_in);


                    IF l_return_status = G_RET_STS_SUCCESS THEN

                       l_chrv_rec_in.id  := l_eligible_contracts_tbl(i).contract_id;
                       l_chrv_rec_in.cust_po_number  := l_new_value_id;
                       l_chrv_rec_in.payment_instruction_type  := 'PON';

                       OKC_CONTRACT_PUB.update_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                        	p_chrv_rec		    => l_chrv_rec_in,
    	                    x_chrv_rec		    => l_chrv_rec_out );
                IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('CONTRACT_HEADER(Cust PO Number) update status: '||l_return_status);
                ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('CONTRACT_HEADER(Cust PO Number) update status: '||l_return_status);
                LOG_MESSAGES('Contract Header(Cust PO Number) Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
         ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('LOCK_CONTRACT(Cust PO Number) status: '||l_return_status);
                LOG_MESSAGES('Contract Lock((Cust PO Number)) failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

    ELSIF l_criteria_rec.attribute = 'PRODUCT_ALIAS' then
                  l_clev_tbl_in.delete;
                  LOG_MESSAGES('Fetching contract lines for update');
                  Get_contract_lines(p_chr_id    => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr      => l_criteria_rec.attribute,
                                      p_old_value => l_criteria_rec.old_value, --l_old_value_id,
                                      p_new_value => l_new_value_id,
                                      x_return_status => l_return_status,
                                      x_clev_tbl  => l_clev_tbl_in);

              IF l_return_status = G_RET_STS_SUCCESS AND l_clev_tbl_in.COUNT>0 THEN
                  LOG_MESSAGES('Locking contract lines for update');
                 OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                           	p_chrv_tbl			=> l_chrv_tbl_in);

             END IF;
         IF l_return_status = G_RET_STS_SUCCESS THEN

            FOR j in 1 .. l_clev_tbl_in.COUNT LOOP
                l_clev_tbl_in(j).cognomen := l_new_value_id;
            END LOOP;

                 OKC_CONTRACT_PUB.update_contract_line(
                            	p_api_version		=> l_api_version,
                              	p_init_msg_list		=> l_init_msg_list,
                            	x_return_status		=> l_return_status,
                            	x_msg_count		    => l_msg_count,
                             	x_msg_data		    => l_msg_data,
                                p_clev_tbl          => l_clev_tbl_in,
                                x_clev_tbl          => l_clev_tbl_out);

                IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('PRODUCT_ALIAS update status: '||l_return_status);
                ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('PRODUCT_ALIAS update status: '||l_return_status);
                LOG_MESSAGES('PRODUCT_ALIAS Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
         ELSE
              IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
              END LOOP;
              END IF;

                LOG_MESSAGES('LOCK_CONTRACT_LINE(Product Alias) status: '||l_return_status);
                LOG_MESSAGES('LOCK_CONTRACT_LINE(Product Alias) failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;

      ELSIF l_criteria_rec.attribute = 'CONTRACT_LINE_REF' then
                  l_clev_tbl_in.delete;
                  LOG_MESSAGES('Fetching contract lines for update');
                  Get_contract_lines(p_chr_id    => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr      => l_criteria_rec.attribute,
                                      p_old_value => l_criteria_rec.old_value, --l_old_value_id,
                                      p_new_value => l_new_value_id,
                                      x_return_status => l_return_status,
                                      x_clev_tbl  => l_clev_tbl_in);

            IF l_return_status = G_RET_STS_SUCCESS AND l_clev_tbl_in.COUNT >0 THEN
                  LOG_MESSAGES('Locking contract lines for update');

                  OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count			=> l_msg_count,
                         	x_msg_data			=> l_msg_data,
                           	p_chrv_tbl			=> l_chrv_tbl_in);


         IF l_return_status = G_RET_STS_SUCCESS THEN

            FOR j in 1 .. l_clev_tbl_in.COUNT LOOP
                l_clev_tbl_in(j).cognomen := l_new_value_id;
            END LOOP;

                 OKC_CONTRACT_PUB.update_contract_line(
                            	p_api_version		=> l_api_version,
                              	p_init_msg_list		=> l_init_msg_list,
                            	x_return_status		=> l_return_status,
                            	x_msg_count		    => l_msg_count,
                             	x_msg_data		    => l_msg_data,
                                p_clev_tbl          => l_clev_tbl_in,
                                x_clev_tbl          => l_clev_tbl_out);

                IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('CONTRACT_LINE_REF update status: '||l_return_status);
                ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('CONTRACT_LINE_REF(Cognomen) update status: '||l_return_status);
                LOG_MESSAGES('CONTRACT_LINE_REF(Cognomen) Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
         ELSE
                  IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('CONTRACT_LINE_REF(Cognomen) update status: '||l_return_status);
                LOG_MESSAGES('CONTRACT_LINE_REF(Cognomen) Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
         END IF;
       ELSE
                LOG_MESSAGES('Get_contract_lines status: '||l_return_status);
                LOG_MESSAGES('Get_contract_lines failed');
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;
      ELSIF l_criteria_rec.attribute = 'CONTRACT_GROUP' then

         OPEN   Get_cgrp_id(l_eligible_contracts_tbl(i).contract_id,l_eligible_contracts_tbl(i).old_value);
         FETCH  Get_cgrp_id INTO l_cgrp_id;
         CLOSE  Get_cgrp_id;

        l_cgcv_rec_in.id                := l_cgrp_id;
        l_cgcv_rec_in.included_chr_id   := l_eligible_contracts_tbl(i).contract_id;
        l_cgcv_rec_in.cgp_parent_id     := l_new_value_id;

        OKC_CONTRACT_GROUP_PUB.update_contract_grpngs(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_cgcv_rec            => l_cgcv_rec_in,
                                        x_cgcv_rec            => l_cgcv_rec_out);

                IF l_return_status = G_RET_STS_SUCCESS THEN
                     LOG_MESSAGES('CONTRACT_GROUP update status: '||l_return_status);
                ELSE
                  IF l_msg_count > 0
                  THEN
                  LOG_MESSAGES('l_msg_count: '||l_msg_count);
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                     l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                  END IF;

                LOG_MESSAGES('CONTRACT_GROUP update status: '||l_return_status);
                LOG_MESSAGES('Contract Group Update failed;'||l_message);
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;

      ELSIF l_criteria_rec.attribute = 'CONTRACT_START_DATE' then
            l_chrv_tbl_in.DELETE;
            l_chrv_tbl_in(1).id		              := l_eligible_contracts_tbl(i).contract_id;
            l_chrv_tbl_in(1).object_version_number    := l_eligible_contracts_tbl(i).object_version_number;

       IF   OKS_EXTWAR_UTIL_PVT.Check_Already_Billed(l_chrv_tbl_in(1).id,NULL,1,NULL)  then  --to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS')) then

            l_message := FND_MESSAGE.get_string('OKS','OKS_MSCHG_BILL_CON') ;
--            l_message := 'It is already billed. Can not update. ' ;
            RAISE  l_notelligible_exception ;

       Else

            OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count		=> l_msg_count,
                         	x_msg_data		=> l_msg_data,
                           	p_chrv_tbl		=> l_chrv_tbl_in);

            IF l_return_status <> G_RET_STS_SUCCESS THEN


                   IF l_msg_count > 0
                   THEN
                        FOR i in 1..l_msg_count
                        LOOP
                                  fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                                 l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                   END IF;

                   LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT status: '||l_return_status);
                   LOG_MESSAGES('Contract Lock(CONTRACT_START_DATE) failed;'||l_message);
                   l_status := 'ERROR';
                   RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;

             LOG_MESSAGES('Fetching contract lines for update');
             l_clev_tbl_in.DELETE;
             Get_contract_lines(p_chr_id          => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_clev_tbl_in);

             IF l_return_status = G_RET_STS_SUCCESS THEN
                LOG_MESSAGES('Locking contract lines for update, lines count:'||l_clev_tbl_in.COUNT);

                OKC_CONTRACT_PUB.lock_contract_line(
                                          p_api_version     => l_api_version,
                                          p_init_msg_list   => l_init_msg_list,
                                          x_return_status   => l_return_status,
                                          x_msg_count       => l_msg_count,
                                          x_msg_data        => l_msg_data,
                                          p_clev_tbl        => l_clev_tbl_in);

                LOG_MESSAGES(' Contract lines lock status:'||l_return_status);

                IF l_return_status <> G_RET_STS_SUCCESS THEN
                   LOG_MESSAGES('Contract lines lock failed');
                   l_status := 'ERROR';
                   RAISE G_EXCEPTION_HALT_VALIDATION;
                End If;

             ELSE
                LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                LOG_MESSAGES('Get_Contract_lines failed');
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;
             LOG_MESSAGES('lock status:'||l_return_status);
             LOG_MESSAGES('l_new_value:'||l_new_value||' , length:'||length(l_new_value));
             --- vigandhi added
		 -- Bug Fix 5075961

             l_klnv_tbl_type_in.DELETE;
             Get_oks_contract_lines(p_chr_id      => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_klnv_tbl_type_in);


              LOG_MESSAGES(' Get OKS Contract lines status:'||l_return_status);

	        IF l_return_status = G_RET_STS_SUCCESS THEN
	                LOG_MESSAGES('Locking oks contract lines for update, lines count:'||l_klnv_tbl_type_in.COUNT);
	        ELSE  -- Get oks contract Lines
                      LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                      LOG_MESSAGES('Get_Contract_lines failed');
                	    l_status := 'ERROR';
                	    RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;  -- Get oks Contracts Lines



              OKS_CONTRACT_LINE_PUB.lock_line(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_klnv_tbl            => l_klnv_tbl_type_in);

              IF l_return_status <> G_RET_STS_SUCCESS THEN



                       LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT_OKS_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                       IF l_msg_count > 0 then
                       	   FOR i in 1..l_msg_count
                       	   LOOP
                        	   fnd_msg_pub.get (p_msg_index     => -1,
                                                    p_encoded       => 'F',
                                                    p_data          => l_msg_data,
                                                    p_msg_index_out => l_msg_index_out);
                                  l_message := l_message||' ; '||l_msg_data;
                            END LOOP;
                        END IF;
                        LOG_MESSAGES('Contract Oks Lines Lock(CONTRACT_START_DATE) failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;

               END IF;
               -- Bug fix 5075961

               l_chrv_rec_in.id  := l_eligible_contracts_tbl(i).contract_id;
               l_chrv_rec_in.start_date  := to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
               LOG_MESSAGES('updating contract header with new value:'||l_chrv_rec_in.start_date);

               OKC_CONTRACT_PUB.update_contract_header (
                        	p_api_version	  => l_api_version,
                          	p_init_msg_list	  => l_init_msg_list,
                        	x_return_status	  => l_return_status,
                        	x_msg_count	  => l_msg_count,
                         	x_msg_data	  => l_msg_data,
                        	p_chrv_rec        => l_chrv_rec_in,
    	                        x_chrv_rec        => l_chrv_rec_out );

               IF l_return_status = G_RET_STS_SUCCESS THEN
                          LOG_MESSAGES('CONTRACT_HEADER(Start_Date) update status: '||l_return_status);

               ELSE
                          IF l_msg_count > 0
                          THEN
                               FOR i in 1..l_msg_count
                               LOOP
                                     fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                                     l_message := l_message||' ; '||l_msg_data;
                               END LOOP;
                           END IF;
                           LOG_MESSAGES('CONTRACT_HEADERS(Contract_Start_Date) update status: '||l_return_status);
                           LOG_MESSAGES('Contract Header(Contract_Start_Date) Update failed;'||l_message);
                           l_status := 'ERROR';
                           RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
                IF l_clev_tbl_in.COUNT > 0 THEN
                     FOR j in 1 .. l_clev_tbl_in.COUNT
                     LOOP
                               l_clev_tbl_in(j).start_date :=
                                     to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
                     END LOOP;
                     LOG_MESSAGES('updating contract lines with new value:'||l_new_value);

                     OKC_CONTRACT_PUB.update_contract_line(
                        	   p_api_version	=> l_api_version,
                             	   p_init_msg_list	=> l_init_msg_list,
                            	   x_return_status	=> l_return_status,
                            	   x_msg_count	        => l_msg_count,
                             	   x_msg_data	        => l_msg_data,
                                 p_clev_tbl           => l_clev_tbl_in,
                                 x_clev_tbl           => l_clev_tbl_out);
                 END IF;

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                          LOG_MESSAGES('CONTRACT_HEADER_LINES(Start_Date) update status: '||l_return_status);

                          -- Vigandhi
		              -- Bug Fix 5075961

                          IF l_klnv_tbl_type_in.COUNT > 0 THEN
			              LOG_MESSAGES('updating contract lines with new invoice text');
                                oks_contract_line_pub.update_line
                                (p_api_version        => l_api_version,
                                 p_init_msg_list      => l_init_msg_list,
                                 x_return_status      => l_return_status,
                                 x_msg_count          => l_msg_count,
                                 x_msg_data           => l_msg_data,
                                 p_klnv_tbl           => l_klnv_tbl_type_in,
                                 x_klnv_tbl           => l_klnv_tbl_type_out,
                                 p_validate_yn        => 'N'
                                 );
				         LOG_MESSAGES('CONTRACT_HEADER_OKS_LINES(Start_Date) update status: '||l_return_status);
				         IF l_return_status <> G_RET_STS_SUCCESS THEN
				                 IF l_msg_count > 0 Then
                                                FOR i in 1..l_msg_count
                                                LOOP
                                                  fnd_msg_pub.get (p_msg_index     => -1,
                                                                   p_encoded       => 'F',
                                                                   p_data          => l_msg_data,
                                                                   p_msg_index_out => l_msg_index_out);
                                                  l_message := l_message||' ; '||l_msg_data;
                                                END LOOP;
                                          END IF;
				                  LOG_MESSAGES('CONTRACT_OKS_LINES(Contract_Start_Date) update status: '||l_return_status);
                                          LOG_MESSAGES('Contract oks Lines(Contract_Start_Date) Update failed;'||l_message);
                                          l_status := 'ERROR';
                                          RAISE G_EXCEPTION_HALT_VALIDATION;
 					     END IF;
				     END IF;
				     -- Bug Fix 5075961


                             l_old_k_amount := Get_contract_amount(l_chrv_rec_in.id);
                             LOG_MESSAGES('Old Contract Amount:'||l_old_k_amount);

                             OKS_REPRICE_PVT.Call_Pricing_Api(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        P_id        		  => l_chrv_rec_in.id,
				                        P_Id_Type		      => 'CHR',
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data);

                              IF  l_return_status = G_RET_STS_SUCCESS THEN
                                        LOG_MESSAGES('CONTRACT_HEADER(Start_date) Repricing status for lines: '||l_return_status);



                                        l_new_k_amount := Get_contract_amount(l_chrv_rec_in.id);
                                        LOG_MESSAGES('New Contract Amount:'||l_new_k_amount);
                                        l_amt_message := rpad(' ',60,' ')||'Old Contract Amount: '||rpad(to_char(l_old_k_amount),10,' ')||'New Contract Amount: '||rpad(to_char(l_new_k_amount),10,' ');
                                        LOG_MESSAGES('CONTRACT_HEADER(Start_date) Repricing status: '||l_return_status);

                              ELSE
                                       IF l_msg_count > 0
                                       THEN
                                            FOR i in 1..l_msg_count
                                             LOOP
                                             fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                                              l_message := l_message||' ; '||l_msg_data;
                                           END LOOP;
                                       END IF;

                                         LOG_MESSAGES('CONTRACT_HEADER(Contract_Start_Date) Repricing status: '||l_return_status);
                                        LOG_MESSAGES('Contract Header(Contract_Start_Date) Repricing  failed;'||l_message);
                                       l_status := 'ERROR';
                                       RAISE G_EXCEPTION_HALT_VALIDATION;
                               END IF;






                   ELSE
                           LOG_MESSAGES('CONTRACT_START_DATE Update_CONTRACT_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                           IF l_msg_count > 0
                           THEN
                               FOR i in 1..l_msg_count
                               LOOP
                               fnd_msg_pub.get (p_msg_index     => -1,
                                                p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                                p_data          => l_msg_data,
                                                p_msg_index_out => l_msg_index_out);

                                l_message := l_message||' ; '||l_msg_data;
                               END LOOP;
                             END IF;
                             LOG_MESSAGES('Contract Lines Update(CONTRACT_START_DATE) failed;'||l_message);
                             l_status := 'ERROR';
                             RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                   IF l_clev_tbl_in.COUNT > 0 THEN
                        FOR j in 1 .. l_clev_tbl_in.COUNT
                        LOOP
                        If l_clev_tbl_in(j).lse_id in (1,12,19,46) Then
                        OKS_BILL_SCH.Cascade_Dates_SLL (l_clev_tbl_in(j).id,l_return_status,l_msg_count,l_msg_data) ;

                        IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('CONTRACT_HEADER(Start_date) Billing Schedule status for lines: '||l_return_status);

                            OPEN  Get_cle_id_PM(l_clev_tbl_in(j).id) ;
                            FETCH Get_cle_id_PM INTO l_count_pm_schedule ;
                            CLOSE Get_cle_id_PM ;

                            IF l_count_pm_schedule > 0 THEN
                                   OKS_PM_PROGRAMS_PVT.ADJUST_PM_PROGRAM_SCHEDULE(
                                        p_api_version          => l_api_version,
                                        p_init_msg_list        => l_init_msg_list,
                                        p_contract_line_id     => l_clev_tbl_in(j).id,
                                        p_new_start_date       => to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS'),
                                        p_new_end_date         => NULL,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data);

                                        LOG_MESSAGES('CONTRACT_HEADER(Start_date) PM Schedule status for lines: '||l_return_status);

                                    IF l_return_status  in (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN

                                         IF l_msg_count > 0 THEN
                                         FOR i in 1..l_msg_count
                                         LOOP
                                             fnd_msg_pub.get (p_msg_index     => -1,
                                                              p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                                              p_data          => l_msg_data,
                                                              p_msg_index_out => l_msg_index_out);
                                             l_message := l_message||' ; '||l_msg_data;
                                         END LOOP;
                                         END IF;

                                         LOG_MESSAGES('Contract_Header(Contract_Start_Date) PM Schedule status: '||l_return_status);
                                         LOG_MESSAGES('Contract Header(Contract_Start_Date) PM Schedule failed;'||l_message);
                                         l_status := 'ERROR';
                                         RAISE G_EXCEPTION_HALT_VALIDATION;
                                    END IF;
                              END IF ;

                        ELSE
                                       IF l_msg_count > 0
                                       THEN
                                       FOR i in 1..l_msg_count
                                       LOOP
                                           fnd_msg_pub.get (p_msg_index     => -1,
                                                            p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                                            p_data          => l_msg_data,
                                                            p_msg_index_out => l_msg_index_out);
                                           l_message := l_message||' ; '||l_msg_data;
                                       END LOOP;
                                       END IF;

                                   LOG_MESSAGES('CONTRACT_HEADER(Contract_Start_Date) Billing Schedule status: '||l_return_status);
                                   LOG_MESSAGES('Contract Header(Contract_Start_Date) Billing Schedule failed;'||l_message);
                                   l_status := 'ERROR';
                                   RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                   End If;
                END LOOP ;
              END IF ;

     End If;

ELSIF l_criteria_rec.attribute = 'CONTRACT_END_DATE' then
         l_chrv_tbl_in.DELETE;
         l_chrv_tbl_in(1).id	                   := l_eligible_contracts_tbl(i).contract_id;
         l_chrv_tbl_in(1).object_version_number    := l_eligible_contracts_tbl(i).object_version_number;


     IF  OKS_EXTWAR_UTIL_PVT.Check_Already_Billed(l_chrv_tbl_in(1).id,NULL,1,to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS')) then

--          l_message := 'It is already billed. Can not update. ' ;
            l_message := FND_MESSAGE.get_string('OKS','OKS_MSCHG_BILL_CON') ;
            RAISE  l_notelligible_exception ;

     ELSE

            OKC_CONTRACT_PUB.lock_contract_header (
                        	p_api_version		=> l_api_version,
                          	p_init_msg_list		=> l_init_msg_list,
                        	x_return_status		=> l_return_status,
                        	x_msg_count		=> l_msg_count,
                         	x_msg_data		=> l_msg_data,
                           	p_chrv_tbl		=> l_chrv_tbl_in);

            IF l_return_status <> G_RET_STS_SUCCESS THEN


                   IF l_msg_count > 0
                   THEN
                        FOR i in 1..l_msg_count
                        LOOP
                                  fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                                 l_message := l_message||' ; '||l_msg_data;
                        END LOOP;
                   END IF;

                   LOG_MESSAGES('CONTRACT_START_DATE LOCK_CONTRACT status: '||l_return_status);
                   LOG_MESSAGES('Contract Lock(CONTRACT_START_DATE) failed;'||l_message);
                   l_status := 'ERROR';
                   RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;

             LOG_MESSAGES('Fetching contract lines for update');
             l_clev_tbl_in.DELETE;
             Get_contract_lines(p_chr_id          => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_clev_tbl_in);

             IF l_return_status = G_RET_STS_SUCCESS THEN
                LOG_MESSAGES('Locking contract lines for update, lines count:'||l_clev_tbl_in.COUNT);

                OKC_CONTRACT_PUB.lock_contract_line(
                                          p_api_version     => l_api_version,
                                          p_init_msg_list   => l_init_msg_list,
                                          x_return_status   => l_return_status,
                                          x_msg_count       => l_msg_count,
                                          x_msg_data        => l_msg_data,
                                          p_clev_tbl        => l_clev_tbl_in);

                LOG_MESSAGES(' Contract lines lock status:'||l_return_status);

                IF l_return_status <> G_RET_STS_SUCCESS THEN
                   LOG_MESSAGES('Contract lines lock failed');
                   l_status := 'ERROR';
                   RAISE G_EXCEPTION_HALT_VALIDATION;
                End If;

             ELSE
                LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                LOG_MESSAGES('Get_Contract_lines failed');
                l_status := 'ERROR';
                RAISE G_EXCEPTION_HALT_VALIDATION;
             END IF;
             LOG_MESSAGES('lock status:'||l_return_status);
             LOG_MESSAGES('l_new_value:'||l_new_value||' , length:'||length(l_new_value));
             --- vigandhi added
		 -- Bug Fix 5075961

             l_klnv_tbl_type_in.DELETE;
             Get_oks_contract_lines(p_chr_id      => l_eligible_contracts_tbl(i).contract_id,
                                      p_attr           => l_criteria_rec.attribute,
                                      p_old_value      => l_old_value,
                                      p_new_value      => l_new_value,
                                      x_return_status  => l_return_status,
                                      x_clev_tbl       => l_klnv_tbl_type_in);


              LOG_MESSAGES(' Get OKS Contract lines status:'||l_return_status);

	        IF l_return_status = G_RET_STS_SUCCESS THEN
	                LOG_MESSAGES('Locking oks contract lines for update, lines count:'||l_klnv_tbl_type_in.COUNT);
	        ELSE  -- Get oks contract Lines
                      LOG_MESSAGES('Get_Contract_lines status: '||l_return_status);
                      LOG_MESSAGES('Get_Contract_lines failed');
                	    l_status := 'ERROR';
                	    RAISE G_EXCEPTION_HALT_VALIDATION;
              END IF;  -- Get oks Contracts Lines



              OKS_CONTRACT_LINE_PUB.lock_line(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_klnv_tbl            => l_klnv_tbl_type_in);

              IF l_return_status <> G_RET_STS_SUCCESS THEN



                       LOG_MESSAGES('CONTRACT_End_DATE LOCK_CONTRACT_OKS_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                       IF l_msg_count > 0 then
                       	   FOR i in 1..l_msg_count
                       	   LOOP
                        	   fnd_msg_pub.get (p_msg_index     => -1,
                                                    p_encoded       => 'F',
                                                    p_data          => l_msg_data,
                                                    p_msg_index_out => l_msg_index_out);
                                  l_message := l_message||' ; '||l_msg_data;
                            END LOOP;
                        END IF;
                        LOG_MESSAGES('Contract Oks Lines Lock(CONTRACT_End_DATE) failed;'||l_message);
                        l_status := 'ERROR';
                        RAISE G_EXCEPTION_HALT_VALIDATION;

               END IF;
               -- Bug fix 5075961

               l_chrv_rec_in.id  := l_eligible_contracts_tbl(i).contract_id;
               l_chrv_rec_in.End_date  := to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
               LOG_MESSAGES('updating contract header with new value:'||l_chrv_rec_in.End_date);

               OKC_CONTRACT_PUB.update_contract_header (
                        	p_api_version	  => l_api_version,
                          	p_init_msg_list	  => l_init_msg_list,
                        	x_return_status	  => l_return_status,
                        	x_msg_count	  => l_msg_count,
                         	x_msg_data	  => l_msg_data,
                        	p_chrv_rec        => l_chrv_rec_in,
    	                        x_chrv_rec        => l_chrv_rec_out );

               IF l_return_status = G_RET_STS_SUCCESS THEN
                          LOG_MESSAGES('CONTRACT_HEADER(End_Date) update status: '||l_return_status);

               ELSE
                          IF l_msg_count > 0
                          THEN
                               FOR i in 1..l_msg_count
                               LOOP
                                     fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                                     l_message := l_message||' ; '||l_msg_data;
                               END LOOP;
                           END IF;
                           LOG_MESSAGES('CONTRACT_HEADERS(Contract_End_Date) update status: '||l_return_status);
                           LOG_MESSAGES('Contract Header(Contract_End_Date) Update failed;'||l_message);
                           l_status := 'ERROR';
                           RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
                IF l_clev_tbl_in.COUNT > 0 THEN
                     FOR j in 1 .. l_clev_tbl_in.COUNT
                     LOOP
                               l_clev_tbl_in(j).End_date :=
                                     to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS');
                     END LOOP;
                     LOG_MESSAGES('updating contract lines with new value:'||l_new_value);

                     OKC_CONTRACT_PUB.update_contract_line(
                        	   p_api_version	=> l_api_version,
                             	   p_init_msg_list	=> l_init_msg_list,
                            	   x_return_status	=> l_return_status,
                            	   x_msg_count	        => l_msg_count,
                             	   x_msg_data	        => l_msg_data,
                                 p_clev_tbl           => l_clev_tbl_in,
                                 x_clev_tbl           => l_clev_tbl_out);
                 END IF;

                 IF l_return_status = G_RET_STS_SUCCESS THEN
                          LOG_MESSAGES('CONTRACT_HEADER_LINES(End_Date) update status: '||l_return_status);

                          -- Vigandhi
		              -- Bug Fix 5075961

                          IF l_klnv_tbl_type_in.COUNT > 0 THEN
			              LOG_MESSAGES('updating contract lines with new invoice text');
                                oks_contract_line_pub.update_line
                                (p_api_version        => l_api_version,
                                 p_init_msg_list      => l_init_msg_list,
                                 x_return_status      => l_return_status,
                                 x_msg_count          => l_msg_count,
                                 x_msg_data           => l_msg_data,
                                 p_klnv_tbl           => l_klnv_tbl_type_in,
                                 x_klnv_tbl           => l_klnv_tbl_type_out,
                                 p_validate_yn        => 'N'
                                 );
				         LOG_MESSAGES('CONTRACT_HEADER_OKS_LINES(End_Date) update status: '||l_return_status);
				         IF l_return_status <> G_RET_STS_SUCCESS THEN
				                 IF l_msg_count > 0 Then
                                                FOR i in 1..l_msg_count
                                                LOOP
                                                  fnd_msg_pub.get (p_msg_index     => -1,
                                                                   p_encoded       => 'F',
                                                                   p_data          => l_msg_data,
                                                                   p_msg_index_out => l_msg_index_out);
                                                  l_message := l_message||' ; '||l_msg_data;
                                                END LOOP;
                                          END IF;
				                  LOG_MESSAGES('CONTRACT_OKS_LINES(Contract_End_Date) update status: '||l_return_status);
                                          LOG_MESSAGES('Contract oks Lines(Contract_End_Date) Update failed;'||l_message);
                                          l_status := 'ERROR';
                                          RAISE G_EXCEPTION_HALT_VALIDATION;
 					     END IF;
				     END IF;
				     -- Bug Fix 5075961


                             l_old_k_amount := Get_contract_amount(l_chrv_rec_in.id);
                             LOG_MESSAGES('Old Contract Amount:'||l_old_k_amount);

                             OKS_REPRICE_PVT.Call_Pricing_Api(
                                        p_api_version         => l_api_version,
                                        p_init_msg_list       => l_init_msg_list,
                                        P_id        		  => l_chrv_rec_in.id,
				                P_Id_Type		      => 'CHR',
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data);

                              IF  l_return_status = G_RET_STS_SUCCESS THEN
                                        LOG_MESSAGES('CONTRACT_HEADER(End_date) Repricing status for lines: '||l_return_status);



                                        l_new_k_amount := Get_contract_amount(l_chrv_rec_in.id);
                                        LOG_MESSAGES('New Contract Amount:'||l_new_k_amount);
                                        l_amt_message := rpad(' ',60,' ')||'Old Contract Amount: '||rpad(to_char(l_old_k_amount),10,' ')||'New Contract Amount: '||rpad(to_char(l_new_k_amount),10,' ');
                                        LOG_MESSAGES('CONTRACT_HEADER(End_date) Repricing status: '||l_return_status);

                              ELSE
                                       IF l_msg_count > 0
                                       THEN
                                            FOR i in 1..l_msg_count
                                             LOOP
                                             fnd_msg_pub.get (p_msg_index     => -1,
                                             p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                             p_data          => l_msg_data,
                                             p_msg_index_out => l_msg_index_out);
                                              l_message := l_message||' ; '||l_msg_data;
                                           END LOOP;
                                       END IF;

                                         LOG_MESSAGES('CONTRACT_HEADER(Contract_End_Date) Repricing status: '||l_return_status);
                                        LOG_MESSAGES('Contract Header(Contract_End_Date) Repricing  failed;'||l_message);
                                       l_status := 'ERROR';
                                       RAISE G_EXCEPTION_HALT_VALIDATION;
                               END IF;






                   ELSE
                           LOG_MESSAGES('CONTRACT_End_DATE Update_CONTRACT_LINES status: '||l_return_status||',msg_count:'||l_msg_count);
                           IF l_msg_count > 0
                           THEN
                               FOR i in 1..l_msg_count
                               LOOP
                               fnd_msg_pub.get (p_msg_index     => -1,
                                                p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                                p_data          => l_msg_data,
                                                p_msg_index_out => l_msg_index_out);

                                l_message := l_message||' ; '||l_msg_data;
                               END LOOP;
                             END IF;
                             LOG_MESSAGES('Contract Lines Update(CONTRACT_End_DATE) failed;'||l_message);
                             l_status := 'ERROR';
                             RAISE G_EXCEPTION_HALT_VALIDATION;
                    END IF;

                   IF l_clev_tbl_in.COUNT > 0 THEN
                        FOR j in 1 .. l_clev_tbl_in.COUNT
                        LOOP
                        If l_clev_tbl_in(j).lse_id in (1,12,19,46) Then

                        OKS_BILL_SCH.Cascade_Dates_SLL (l_clev_tbl_in(j).id,l_return_status,l_msg_count,l_msg_data) ;

                        IF l_return_status = G_RET_STS_SUCCESS THEN
                        LOG_MESSAGES('CONTRACT_HEADER(End_date) Billing Schedule status for lines: '||l_return_status);

                            OPEN  Get_cle_id_PM(l_clev_tbl_in(j).id) ;
                            FETCH Get_cle_id_PM INTO l_count_pm_schedule ;
                            CLOSE Get_cle_id_PM ;

                            IF l_count_pm_schedule > 0 THEN
                                   OKS_PM_PROGRAMS_PVT.ADJUST_PM_PROGRAM_SCHEDULE(
                                        p_api_version          => l_api_version,
                                        p_init_msg_list        => l_init_msg_list,
                                        p_contract_line_id     => l_clev_tbl_in(j).id,
                                        p_new_start_date       => NULL,
                                        p_new_end_date         => to_date(l_new_value,'YYYY/MM/DD HH24:MI:SS'),
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data);
                                        LOG_MESSAGES('CONTRACT_HEADER(End_date) PM Schedule status for lines: '||l_return_status);
                                    IF l_return_status  in (G_RET_STS_ERROR,G_RET_STS_UNEXP_ERROR) THEN


                                         IF l_msg_count > 0 THEN
                                         FOR i in 1..l_msg_count
                                         LOOP
                                             fnd_msg_pub.get (p_msg_index     => -1,
                                                              p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                                              p_data          => l_msg_data,
                                                              p_msg_index_out => l_msg_index_out);
                                             l_message := l_message||' ; '||l_msg_data;
                                         END LOOP;
                                         END IF;

                                         LOG_MESSAGES('Contract_Header(Contract_End_Date) PM Schedule status: '||l_return_status);
                                         LOG_MESSAGES('Contract Header(Contract_End_Date) PM Schedule failed;'||l_message);
                                         l_status := 'ERROR';
                                         RAISE G_EXCEPTION_HALT_VALIDATION;
                                    END IF;
                              END IF ;

                        ELSE
                                       IF l_msg_count > 0
                                       THEN
                                       FOR i in 1..l_msg_count
                                       LOOP
                                           fnd_msg_pub.get (p_msg_index     => -1,
                                                            p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                                            p_data          => l_msg_data,
                                                            p_msg_index_out => l_msg_index_out);
                                           l_message := l_message||' ; '||l_msg_data;
                                       END LOOP;
                                       END IF;

                                   LOG_MESSAGES('CONTRACT_HEADER(Contract_End_Date) Billing Schedule status: '||l_return_status);
                                   LOG_MESSAGES('Contract Header(Contract_End_Date) Billing Schedule failed;'||l_message);
                                   l_status := 'ERROR';
                                   RAISE G_EXCEPTION_HALT_VALIDATION;
                        END IF;
                   End if;
                END LOOP ;
              END IF ;

     End If;

  END IF;


   -- Run QA Check
    --  IF l_eligible_contracts_tbl(i).contract_status <> 'ENTERED'
     -- IF get_ste_code(l_eligible_contracts_tbl(i).contract_status) <> 'ENTERED'
     --  AND l_eligible_contracts_tbl(i).qcl_id IS NOT NULL
       IF l_eligible_contracts_tbl(i).qa_check_yn = 'Y' then
             l_msg_tbl.DELETE;
             LOG_MESSAGES('Starting QA Check ....');

             OKC_QA_CHECK_PUB.execute_qa_check_list(
                                      p_api_version     => l_api_version,
                                      p_init_msg_list   => l_init_msg_list,
                                      x_return_status   => l_return_status,
                                      x_msg_count       => l_msg_count,
                                      x_msg_data        => l_msg_data,
                                      p_qcl_id          => l_eligible_contracts_tbl(i).qcl_id,
                                      p_chr_id          => l_eligible_contracts_tbl(i).contract_id,
                                      x_msg_tbl         => l_msg_tbl);

                    LOG_MESSAGES('QA Check completed with status :'||l_return_status);
             IF l_return_status <>'S' then
                IF l_msg_count > 0
                THEN
                  l_message := 'Error while running QA check: ';
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F',
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                    l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                    LOG_MESSAGES(l_message);
                    RAISE G_EXCEPTION_HALT_VALIDATION;
                END IF;
             ELSE
                l_status := 'SUCCESS';
                FOR j in l_msg_tbl.FIRST .. l_msg_tbl.LAST
                LOOP
                   IF l_msg_tbl(j).error_status = 'E' then
                      l_status := 'ERROR';
                      l_message := 'QA Check failed; ';
                      LOG_MESSAGES(l_message||l_msg_tbl(j).data);
                   END IF;
                END LOOP;
                   If l_status = 'ERROR' then -- Rollback if QA fails
                      RAISE G_EXCEPTION_HALT_VALIDATION;
                   End If;
             END IF; --QA Return Status
     END IF; -- QA Check Yes

End IF; -- Warranty contract yes/no -- currently, we are not runnig QA for warranty contracts

    IF l_status <> 'ERROR' then

       IF  l_criteria_rec.attribute = 'COVERAGE_START_TIME' Then
           IF l_cov_time_wrong > 0 and l_cov_time_right = 0 Then
              l_message := 'The new Coverage Start time is greater than the coverage end time ';
              l_status := 'ERROR' ;
              l_cov_time_right := 0 ;
              l_cov_time_wrong := 0 ;
           ELSE
              l_message := 'Successfully Completed';
              l_cov_time_right := 0 ;
              l_cov_time_wrong := 0 ;

           END IF ;
       ELSIF l_criteria_rec.attribute = 'COVERAGE_END_TIME' Then
           IF l_cov_time_wrong > 0 and l_cov_time_right = 0 Then
             -- LOG_MESSAGES('l_cov_time_wrong in If'||l_cov_time_wrong);
              l_message := 'The new Coverage End Time is less than the Coverage Start Time ';
              l_status := 'ERROR' ;
              l_cov_time_right := 0 ;
              l_cov_time_wrong := 0 ;
           ELSE
               LOG_MESSAGES('l_cov_time_wrong in Else:'||l_cov_time_wrong||'l_cov_time_right:'||l_cov_time_right);
               l_message := 'Successfully Completed';
               l_cov_time_right := 0 ;
               l_cov_time_wrong := 0 ;

           END IF ;
       END IF ;
      IF p_process_type = 'SUBMIT' then

         l_olev_rec_in.id           := l_eligible_contracts_tbl(i).ole_id;
         l_olev_rec_in.process_flag := 'P';

         OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);

         --commit;
      ELSIF p_process_type = 'PREVIEW' then
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MASSCHANGE');

       l_olev_rec_in.id           := l_eligible_contracts_tbl(i).ole_id;
       l_olev_rec_in.process_flag := 'A';

         OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);
        --commit;
      END IF;
    ELSE
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MASSCHANGE');
         l_olev_rec_in.id           := l_eligible_contracts_tbl(i).ole_id;
         l_olev_rec_in.process_flag := 'E';

         OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);

    END IF;

  -- Insert into success tbl

  l_outfile_success_id := l_outfile_success_id + 1 ;

  l_outfiles_succ(l_outfile_success_id).ID := l_outfile_success_id  ;
  l_outfiles_succ(l_outfile_success_id).String1 :=
          rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number,' '),1,28),28,' ')||'  '||
          rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number_modifier,' '),1,16),18,' ') ;
  l_outfiles_succ(l_outfile_success_id).String2 :=
          rpad(substr(nvl(l_eligible_contracts_tbl(i).short_description,' '),1,32),32,' ')||'  '||
          rpad(substr(nvl(l_old_value,' '),1,25),25,' ') ;
  l_outfiles_succ(l_outfile_success_id).String3 := pad( FND_MESSAGE.get_string('OKS','OKS_SUCCESS'),22)
                                                   ||'  '||l_message  || l_billed_at_source_msg ;

    l_amt_message := NULL;
    l_success_cnt := l_success_cnt + 1;
 EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
        l_error_cnt := l_error_cnt + 1;
        l_status    := FND_MESSAGE.get_string('OKS','OKS_MSCHG_ERROR');
--        l_status    := 'ERROR';
        DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MASSCHANGE');
        LOG_MESSAGES('G_EXCEPTION_HALT_VALIDATION in inner LOOP');
        --Update operation lines with ERROR  (revisit)
        l_olev_rec_in.id           := l_eligible_contracts_tbl(i).ole_id;
        l_olev_rec_in.process_flag := 'E';

         OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);
     -- Insert into failed tbl

        l_outfile_fail_id := l_outfile_fail_id + 1 ;
        l_outfiles_fail(l_outfile_fail_id).ID := l_outfile_fail_id  ;
        l_outfiles_fail(l_outfile_fail_id).String1 :=
                rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number,' '),1,28),28,' ')||'  '||
                rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number_modifier,' '),1,16),18,' ') ;
        l_outfiles_fail(l_outfile_fail_id).String2 :=
                rpad(substr(nvl(l_eligible_contracts_tbl(i).short_description,' '),1,32),32,' ')||'  '||
                rpad(substr(nvl(l_old_value,' '),1,25),25,' ') ;
        l_outfiles_fail(l_outfile_fail_id).String3 := pad(l_status,22)||'  '||l_message ;

   WHEN l_notelligible_exception THEN
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MASSCHANGE');
       LOG_MESSAGES('l_notelligible_exception in inner LOOP');

       l_olev_rec_in.id           := l_eligible_contracts_tbl(i).ole_id;
       l_olev_rec_in.process_flag := NULL ;

       OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);
    l_status  := FND_MESSAGE.get_string('OKS','OKS_MSCHG_NOT_ELIG') ;
--    l_status  := 'NOT ELIGIBLE';
    l_message := nvl(l_message,
                    FND_MESSAGE.get_string('OKS','OKS_MSCHG_MSG_GEN') );
--    l_message := nvl(l_message,'This Contract does not qualify for mass update');
    -- insert into inelligible tbl

      l_outfile_inel_id := l_outfile_inel_id + 1 ;
      l_outfiles_inel(l_outfile_inel_id).ID := l_outfile_inel_id  ;
      l_outfiles_inel(l_outfile_inel_id).String1 :=
           rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number,' '),1,28),28,' ')||'  '||
           rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number_modifier,' '),1,16),18,' ') ;
      l_outfiles_inel(l_outfile_inel_id).String2 :=
           rpad(substr(nvl(l_eligible_contracts_tbl(i).short_description,' '),1,32),32,' ')||'  '||
           rpad(substr(nvl(l_old_value,' '),1,25),25,' ') ;
      l_outfiles_inel(l_outfile_inel_id).String3 := pad(l_status,22)||'  '||l_message ;


     WHEN OTHERS THEN

       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MASSCHANGE');
       LOG_MESSAGES('For oie_id:'||p_oie_id||', Others EXCEPTION:'||SQLERRM);
       l_error_cnt := l_error_cnt + 1;
       l_status    := FND_MESSAGE.get_string('OKS','OKS_MSCHG_ERROR');
 --      l_status    := 'ERROR';
       l_message   := SQLERRM;

       l_olev_rec_in.id           := l_eligible_contracts_tbl(i).ole_id;
       l_olev_rec_in.process_flag := 'E';

       OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);
        -- insert into error tbl
          l_outfile_fail_id := l_outfile_fail_id + 1 ;
          l_outfiles_fail(l_outfile_fail_id).ID := l_outfile_fail_id  ;
          l_outfiles_fail(l_outfile_fail_id).String1 :=
              rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number,' '),1,28),28,' ')||'  '||
              rpad(substr(nvl(l_eligible_contracts_tbl(i).contract_number_modifier,' '),1,16),18,' ') ;
          l_outfiles_fail(l_outfile_fail_id).String2 :=
              rpad(substr(nvl(l_eligible_contracts_tbl(i).short_description,' '),1,32),32,' ')||'  '||
              rpad(substr(nvl(l_old_value,' '),1,25),25,' ') ;
          l_outfiles_fail(l_outfile_fail_id).String3 := pad(l_status,22)||'  '||l_message ;

     END;
   END LOOP;

          l_oiev_rec_in.id  := p_oie_id;

    IF p_process_type = 'SUBMIT' then
       IF l_error_cnt > 0 and l_success_cnt>0 then
        l_oiev_rec_in.status_code := 'PARTIALLY_PROCESSED';
       ELSIF (l_eligible_contracts_tbl.COUNT > 0 and l_error_cnt = 0) then
        l_oiev_rec_in.status_code := 'PROCESSED';
       ELSIF l_eligible_contracts_tbl.COUNT = 0  then
        l_oiev_rec_in.status_code := 'PROCESSED';
        LOG_MESSAGES('No Contracts Elligible for Processing ');
        --fnd_file.put_line(FND_FILE.OUTPUT,'No Contracts Eligible for Processing ');
       ELSIF l_error_cnt > 0 and l_success_cnt=0 then
        l_oiev_rec_in.status_code := 'ERROR';
       END IF;
    ELSIF p_process_type = 'PREVIEW' then
       --IF l_err_cnt > 0 then
       --       l_oiev_rec_in.status_code := 'PARTIALLY_PREVIEWED';    -- Check with PM
       --       ELSE
       l_oiev_rec_in.status_code := 'PREVIEWED';
       --       END IF;
       IF l_eligible_contracts_tbl.COUNT = 0  then
       LOG_MESSAGES('No Contracts Elligible for Processing ');
       --fnd_file.put_line(FND_FILE.OUTPUT,'No Contracts Eligible for Processing ');
       END IF;
    END IF;

-- Printing Inelligible Contracts
    FOR inelligible_rec in Get_inelligibles(l_criteria_rec.oie_id)
    LOOP
    LOG_MESSAGES('inelligible_rec get_attribute_value call ');
        get_attribute_value(p_attr_code  => l_attribute_code,
                            p_attr_id    => inelligible_rec.old_value,
                            p_org_id     => l_org_id,
                            x_attr_value => l_old_value,
                            x_attr_name  => l_attribute);

-- The following portion  commented on 12/16/2003.
-- This code has been moved to place where Inelligible exception is handled.
--  Reason: value for the l_message is only available in exception part.

--     l_status  := 'NOT ELIGIBLE';
--     l_message := 'This Contract does not qualify for mass update';
--     insert into inelligible tbl
--
--      l_outfile_inel_id := l_outfile_inel_id + 1 ;
--      l_outfiles_inel(l_outfile_inel_id).ID := l_outfile_inel_id  ;
--      l_outfiles_inel(l_outfile_inel_id).String1 := rpad(substr(nvl(inelligible_rec.contract_number,' ')
--       ,1,19),19,' ')||'  '||rpad(substr(nvl(inelligible_rec.contract_number_modifier,' '),1,10),10,' ') ;
--      l_outfiles_inel(l_outfile_inel_id).String2 := rpad(substr(nvl(inelligible_rec.short_description,' ')
--       ,1,26),26,' ')||'  '||rpad(substr(nvl(l_old_value,' '),1,19),19,' ') ;
--      l_outfiles_inel(l_outfile_inel_id).String3 := l_status||'  '||l_message ;


      l_olev_rec_in.id           := inelligible_rec.ole_id;
      l_olev_rec_in.process_flag := 'N';

      OKC_OPER_INST_PUB.Update_Operation_Line (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_olev_rec                     => l_olev_rec_in,
                                            x_olev_rec                     => l_olev_rec_out);

       LOG_MESSAGES(' OKC_OPER_INST_PUB.Update_Operation_Line:  '||l_return_status);

            IF  l_return_status <> 'S' then
               IF l_msg_count > 0
              THEN
              FOR i in 1..l_msg_count
              LOOP
                 fnd_msg_pub.get (p_msg_index     => -1,
                                  p_encoded       => 'F',
                                  p_data          => l_msg_data,
                                  p_msg_index_out => l_msg_index_out);
                LOG_MESSAGES('inel Update_Operation_Line: '||l_msg_data);
              END LOOP;
              END IF;
           END IF;

    END LOOP;

    IF l_oiev_rec_in.status_code is NOT NULL then

     OKC_OPER_INST_PUB.Update_Operation_Instance (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_oiev_rec                     => l_oiev_rec_in,
                                            x_oiev_rec                     => l_oiev_rec_out);
    END IF;

-- Code for printing Mass Change Report Starts here.
-- This code was modified to make the report headings translatable in Mar 2004.
-- Bug#3337646

        get_attribute_value(p_attr_code  => l_attribute_code,
                            p_attr_id    => l_criteria_rec.old_value,
                            p_org_id     => l_org_id ,
                            x_attr_value => l_old_value,
                            x_attr_name  => l_attribute);

        If p_process_type = 'PREVIEW' then
           l_process_type_msg_seed := 'OKS_MSCHG_PREVIEW';
        Else
           l_process_type_msg_seed := 'OKS_MSCHG_SUBMIT';
        End If;

  l_empty_string1 :='     ';
  l_dash_string1  :='------------------------------';

  fnd_file.new_line(FND_FILE.OUTPUT, 1);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_MSCHG')||
                                     ' '||FND_MESSAGE.get_string('OKS',l_process_type_msg_seed)||' '||
                                     FND_MESSAGE.get_string('OKS','OKS_MSCHG_RPT'),45,'L') );
  fnd_file.put_line(FND_FILE.OUTPUT, pad(pad('****',
                                     length(FND_MESSAGE.get_string('OKS','OKS_MSCHG_MSCHG')||
                                           FND_MESSAGE.get_string('OKS',l_process_type_msg_seed)||
                                           FND_MESSAGE.get_string('OKS','OKS_MSCHG_RPT')
                                            )+2,'R','*'),45,'L') );
  fnd_file.new_line(FND_FILE.OUTPUT, 2);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_NAME'),35)
                                     ||':  '||l_masschange_name);
  fnd_file.new_line(FND_FILE.OUTPUT, 1);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_SCOPE'),35) );
  fnd_file.put_line(FND_FILE.OUTPUT, pad(l_empty_string1
                                     ||FND_MESSAGE.get_string('OKS','OKS_MSCHG_UPD_LVL'),35)
                                     ||':  '||l_update_level);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(l_empty_string1
                                     ||FND_MESSAGE.get_string('OKS','OKS_MSCHG_UPD_LVL_VAL'),35)
                                     ||':  '|| l_update_level_value);
  fnd_file.new_line(FND_FILE.OUTPUT, 1);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_CRIT'),40) );
  fnd_file.put_line(FND_FILE.OUTPUT, pad(l_empty_string1
                                     ||FND_MESSAGE.get_string('OKS','OKS_MSCHG_ATTR'),35)
                                     ||':  '||l_attribute);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(l_empty_string1
                                     ||FND_MESSAGE.get_string('OKS','OKS_MSCHG_OLD_VAL'),35)
                                     ||':  '||l_old_value);
  fnd_file.put_line(FND_FILE.OUTPUT, pad(l_empty_string1
                                     ||FND_MESSAGE.get_string('OKS','OKS_MSCHG_NEW_VAL'),35)
                                     ||':  '||l_new_value);

--  fnd_file.put_line(FND_FILE.OUTPUT, l_star_string1||l_star_string1||l_star_string1||
--                                     l_star_string1||l_star_string1 );

  fnd_file.new_line(FND_FILE.OUTPUT, 1);
  fnd_file.new_line(FND_FILE.OUTPUT, 1);


        l_succ_count  := l_outfiles_succ.count  ;
        l_fail_count  := l_outfiles_fail.count  ;
        l_inel_count  := l_outfiles_inel.count  ;
        l_total_rec_count := nvl(l_succ_count,0) + nvl(l_fail_count,0) + nvl(l_inel_count,0) ;

    fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_MSCHG_SUMM') ) ;
    fnd_file.put_line(FND_FILE.OUTPUT,'****************') ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.put_line(FND_FILE.OUTPUT,pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_SUCC_CON'),50)
                                         ||': '||l_outfiles_succ.count) ;
    fnd_file.put_line(FND_FILE.OUTPUT,pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_FAIL_CON'),50)
                                         ||': '||l_outfiles_fail.count) ;
    fnd_file.put_line(FND_FILE.OUTPUT,pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_INELG_CON'),50)
                                         ||': '||l_outfiles_inel.count) ;
    fnd_file.put_line(FND_FILE.OUTPUT,pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_TOT_PROC'),50)
                                         ||': '||l_total_rec_count ) ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get_string('OKS','OKS_MSCHG_DET')) ;
    fnd_file.put_line(FND_FILE.OUTPUT,'****************') ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.put_line(FND_FILE.OUTPUT, FND_MESSAGE.get_string('OKS','OKS_MSCHG_LIST_SUCC') ) ;
    fnd_file.put_line(FND_FILE.OUTPUT, l_dash_string1||l_dash_string1||
                                       l_dash_string1||l_dash_string1||l_dash_string1);
    fnd_file.put_line(FND_FILE.OUTPUT,
                     pad(FND_MESSAGE.get_string('OKS','OKS_VAL_CONTRACT_NO'),30) ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_VAL_MODIFIER'),18)    ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_CON_DECS'),34)  ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_OLD_VAL'),25)   ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_PROC_STAT'),24) ||
                     FND_MESSAGE.get_string('OKS','OKS_MSCHG_PROC_REM') );
    fnd_file.put_line(FND_FILE.OUTPUT, l_dash_string1||l_dash_string1||
                                       l_dash_string1||l_dash_string1||l_dash_string1);

    IF NVL(l_outfiles_succ.count,0) > 0 then
        For i in 1..l_outfiles_succ.count LOOP
            fnd_file.put_line(FND_FILE.OUTPUT,l_outfiles_succ(i).String1||
                                   l_outfiles_succ(i).String2||
                                   l_outfiles_succ(i).String3) ;
        END LOOP ;
    END IF ;

    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_MSCHG_LIST_FAIL') ) ;
    fnd_file.put_line(FND_FILE.OUTPUT, l_dash_string1||l_dash_string1||
                                       l_dash_string1||l_dash_string1||l_dash_string1);

    fnd_file.put_line(FND_FILE.OUTPUT,
                     pad(FND_MESSAGE.get_string('OKS','OKS_VAL_CONTRACT_NO'),30) ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_VAL_MODIFIER'),18)    ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_CON_DECS'),34)  ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_OLD_VAL'),25)   ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_PROC_STAT'),24) ||
                     FND_MESSAGE.get_string('OKS','OKS_MSCHG_PROC_REM') );

    fnd_file.put_line(FND_FILE.OUTPUT, l_dash_string1||l_dash_string1||
                                       l_dash_string1||l_dash_string1||l_dash_string1);
    For j in 1..l_outfiles_fail.count LOOP
        fnd_file.put_line(FND_FILE.OUTPUT,l_outfiles_fail(j).String1||
                                          l_outfiles_fail(j).String2||
                                          l_outfiles_fail(j).String3) ;
    END LOOP ;

    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.put_line(FND_FILE.OUTPUT,FND_MESSAGE.get_string('OKS','OKS_MSCHG_LIST_INELG') ) ;
    fnd_file.put_line(FND_FILE.OUTPUT, l_dash_string1||l_dash_string1||
                                       l_dash_string1||l_dash_string1||l_dash_string1);

    fnd_file.put_line(FND_FILE.OUTPUT,
                     pad(FND_MESSAGE.get_string('OKS','OKS_VAL_CONTRACT_NO'),30) ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_VAL_MODIFIER'),18)    ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_CON_DECS'),34)  ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_OLD_VAL'),25)   ||
                     pad(FND_MESSAGE.get_string('OKS','OKS_MSCHG_PROC_STAT'),24) ||
                     FND_MESSAGE.get_string('OKS','OKS_MSCHG_PROC_REM') );

    fnd_file.put_line(FND_FILE.OUTPUT, l_dash_string1||l_dash_string1||
                                       l_dash_string1||l_dash_string1||l_dash_string1);
    For k in 1..l_outfiles_inel.count LOOP
        fnd_file.put_line(FND_FILE.OUTPUT,l_outfiles_inel(k).String1||
                                          l_outfiles_inel(k).String2||
                                          l_outfiles_inel(k).String3) ;
    END LOOP ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.new_line(FND_FILE.OUTPUT,1) ;
    fnd_file.put_line(FND_FILE.OUTPUT, pad('********* '
                                     ||FND_MESSAGE.get_string('OKS','OKS_MSCHG_RPT_END')
                                     ||' *********',45,'L') );

 EXCEPTION
     WHEN OTHERS THEN
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT('BEFORE_MASSCHANGE_START');
         LOG_MESSAGES('For oie_id:'||p_oie_id||', Others EXCEPTION in outer:'||SQLERRM);
         l_oiev_rec_in.id  := p_oie_id;
         l_oiev_rec_in.status_code := 'ERROR';
         OKC_OPER_INST_PUB.Update_Operation_Instance (
                                            p_api_version                  => l_api_version,
                                            p_init_msg_list                => l_init_msg_list,
                                            x_return_status                => l_return_status,
                                            x_msg_count                    => l_msg_count,
                                            x_msg_data                     => l_msg_data,
                                            p_oiev_rec                     => l_oiev_rec_in,
                                            x_oiev_rec                     => l_oiev_rec_out);
         LOG_MESSAGES('Update_Operation_instance status:'||l_return_status);
         commit;
 END Submit;

 PROCEDURE LOCK_CONTRACT_HEADER(p_header_id IN NUMBER,
                                p_object_version_number IN NUMBER,
                                x_return_status OUT NOCOPY Varchar2) IS

 l_api_version		CONSTANT	NUMBER	:= 1.0;
 l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
 l_return_status	VARCHAR2(1);
 l_msg_count		NUMBER;
 l_msg_data	       VARCHAR2(2000);
 l_msg_index_out	NUMBER;
 l_chrv_tbl_in      okc_contract_pub.chrv_tbl_type;
 l_chrv_tbl_out     okc_contract_pub.chrv_tbl_type;

 BEGIN
 l_chrv_tbl_in(1).id		                  := p_header_id;
 l_chrv_tbl_in(1).object_version_number       := p_object_version_number;
 okc_contract_pub.lock_contract_header (
    	p_api_version			=> l_api_version,
    	p_init_msg_list			=> l_init_msg_list,
    	x_return_status			=> l_return_status,
    	x_msg_count			=> l_msg_count,
    	x_msg_data			=> l_msg_data,
    	p_chrv_tbl			=> l_chrv_tbl_in
    );
 LOG_MESSAGES('LOCK_CONTRACT_HEADER l_return_status = ' || l_return_status);
 IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
 END IF;
      x_return_status := l_return_status;
 END LOCK_CONTRACT_HEADER;

 PROCEDURE UPDATE_CONTRACT(p_chrv_rec       IN  okc_contract_pub.chrv_rec_type,
                           x_return_status  OUT NOCOPY VARCHAR2) IS
 l_api_version		CONSTANT	NUMBER	:= 1.0;
 l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
 l_return_status	VARCHAR2(1);
 l_msg_count		NUMBER;
 l_msg_data		VARCHAR2(2000);
 l_msg_index_out	NUMBER;

 l_chrv_rec_out            okc_contract_pub.chrv_rec_type;

 BEGIN

 LOG_MESSAGES(' UPDATEing Contract, header_id = ' ||p_chrv_rec.id);
 x_return_status := OKC_API.G_RET_STS_SUCCESS;

 IF p_chrv_rec.id IS NOT NULL THEN
 okc_contract_pub.update_contract_header (
    	p_api_version		=> l_api_version,
    	p_init_msg_list		=> l_init_msg_list,
    	x_return_status		=> l_return_status,
    	x_msg_count		=> l_msg_count,
    	x_msg_data		=> l_msg_data,
    	p_chrv_rec		=> p_chrv_rec,
    	x_chrv_rec		=> l_chrv_rec_out );

     LOG_MESSAGES('okc_contract_pub.update_contract_header l_return_status = ' || l_return_status);
    x_return_status := l_return_status;
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      LOG_MESSAGES('okc_contract_pub.update_contract_header l_msg_data = ' || l_msg_data);
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      LOG_MESSAGES('okc_contract_pub.update_contract_header l_msg_data = ' || l_msg_data);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
 END IF;
 END UPDATE_CONTRACT;

 PROCEDURE LOG_MESSAGES(p_mesg IN VARCHAR2) IS
 BEGIN
     IF nvl(l_conc_program,'N') = 'N' THEN
          --dbms_output.put_line(p_mesg);
          NULL;
     ELSE
         fnd_file.put_line(FND_FILE.LOG, p_mesg);
     END IF;
 END LOG_MESSAGES;

PROCEDURE CREATE_OPERATION_INSTANCES (p_oie_rec  IN opr_instance_rec_type,
                                      p_mrd_rec  IN masschange_request_rec_type,
                                      x_oie_id   OUT NOCOPY NUMBER) is
------------------------------------------------------------------
---TAPI variables
------------------------------------------------------------------
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;

  l_oiev_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE
  l_oiev_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE

  l_omrv_rec_in         OKC_OPER_INST_PUB.mrdv_rec_type;
  l_omrv_rec_out        OKC_OPER_INST_PUB.mrdv_rec_type;

  l_omrv_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type;
  l_omrv_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type;

  l_mod_rec_in          OKS_MOD_PVT.OksMschgOperationsDtlsVRecType;
  l_mod_rec_out         OKS_MOD_PVT.OksMschgOperationsDtlsVRecType;

  x_mrd_id              NUMBER ;
--------------------------------------------------------------------
---Program Variables
--------------------------------------------------------------------
  p_class_operation_id NUMBER := 0;
-------------------------------------------------------------------------
---Find the Class Operation ID to be used
--------------------------------------------------------------------------
  CURSOR class_operations is
  SELECT ID from OKC_CLASS_OPERATIONS_V
  WHERE OPN_CODE = 'MASS_CHANGE' and CLS_CODE = 'SERVICE';

BEGIN
       --dbms_output.put_line('Inside ..');
   FOR cur_class_operations in class_operations
   LOOP
    p_class_operation_id := cur_class_operations.id;
    EXIT;
   END LOOP;

    l_oiev_tbl_in(1).name                            := p_oie_rec.NAME;
    l_oiev_tbl_in(1).cop_id                          := p_class_operation_id;
--    l_oiev_tbl_in(1).status_code :=  G_OI_STATUS_CODE;
    if (p_oie_rec.status_code  is NULL) then  --OR ( p_oie_rec.status_code  = OKC_API.G_MISS_CHAR)) then
       l_oiev_tbl_in(1).status_code :=  G_OI_STATUS_CODE;
    else
       l_oiev_tbl_in(1).status_code := p_oie_rec.status_code; --G_OI_STATUS_CODE;
    end if;
    l_oiev_tbl_in(1).target_chr_id                   := NULL ; --OKC_API.G_MISS_NUM;
    l_oiev_tbl_in(1).object1_id1                     := p_oie_rec.update_level_value;
    l_oiev_tbl_in(1).object1_id2                     := '#';
    l_oiev_tbl_in(1).jtot_object1_code               := p_oie_rec.update_level;
    l_oiev_tbl_in(1).object_version_number           := NULL ; --OKC_API.G_MISS_NUM;
    l_oiev_tbl_in(1).created_by                      := NULL ; --OKC_API.G_MISS_NUM;
    l_oiev_tbl_in(1).creation_date                   := SYSDATE;
    l_oiev_tbl_in(1).last_updated_by                 := NULL ; --OKC_API.G_MISS_NUM;
    l_oiev_tbl_in(1).last_update_date                := SYSDATE;
    l_oiev_tbl_in(1).last_update_login               := NULL ; --OKC_API.G_MISS_NUM;

        OKC_OPER_INST_PUB.Create_Operation_Instance(
    	p_api_version					=> l_api_version,
    	p_init_msg_list					=> l_init_msg_list,
    	x_return_status					=> l_return_status,
    	x_msg_count					    => l_msg_count,
    	x_msg_data					    => l_msg_data,
    	p_oiev_tbl					    => l_oiev_tbl_in,
    	x_oiev_tbl					    => l_oiev_tbl_out);


    x_oie_id := l_oiev_tbl_out(1).id;


    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
/*      IF l_msg_count > 0
      THEN
       FOR i in 1..l_msg_count
       LOOP
        fnd_msg_pub.get (p_msg_index     => -1,
                         p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index_out);
       END LOOP;
     END IF;
        --dbms_output.put_line('Value of l_return_status:'||l_return_status||'l_msg_data='||l_msg_data);
        */
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
/*      IF l_msg_count > 0
      THEN
       FOR i in 1..l_msg_count
       LOOP
        fnd_msg_pub.get (p_msg_index     => -1,
                         p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                         p_data          => l_msg_data,
                         p_msg_index_out => l_msg_index_out);
       END LOOP;
     END IF;
        --dbms_output.put_line('Value of l_return_status:'||l_return_status||'l_msg_data='||l_msg_data); */
    ELSIF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

  IF p_mrd_rec.attribute_name is not null then
    l_omrv_rec_in.id                              := null;
    l_omrv_rec_in.oie_id                          := x_oie_id;
    l_omrv_rec_in.ole_id                          := null;
    l_omrv_rec_in.attribute_name                  := p_mrd_rec.attribute_name;
    l_omrv_rec_in.old_value                       := p_mrd_rec.old_value;
    l_omrv_rec_in.new_value                       := p_mrd_rec.new_value;
    l_omrv_rec_in.object_version_number           := NULL ; --OKC_API.G_MISS_NUM;
    l_omrv_rec_in.created_by                      := NULL ; --OKC_API.G_MISS_NUM;
    l_omrv_rec_in.creation_date                   := SYSDATE;
 --   l_omrv_rec_in.last_updated_by                 := OKC_API.G_MISS_NUM;
    l_omrv_rec_in.last_update_date                := SYSDATE;
    l_omrv_rec_in.last_update_login               := NULL ; --OKC_API.G_MISS_NUM;


     OKC_OPER_INST_PUB.Create_Masschange_Dtls(
                            	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_mrdv_rec                      => l_omrv_rec_in,
                                x_mrdv_rec                      => l_omrv_rec_out);

        --dbms_output.put_line('Omr status:'||l_return_status);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

--    x_mrd_id := l_omrv_rec_out.id;

    l_mod_rec_in.id                              := null;
    l_mod_rec_in.mrd_id                          := l_omrv_rec_out.id ;
    l_mod_rec_in.oie_id                          := x_oie_id;
    l_mod_rec_in.ole_id                          := null;
    l_mod_rec_in.mschg_type                      := null;
    l_mod_rec_in.attribute_level                 := null;
    l_mod_rec_in.qa_check_yn                     := null; --p_mrd_rec.qa_check_yn;
    l_mod_rec_in.object_version_number           := NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.created_by                      := NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.creation_date                   := SYSDATE;
    l_mod_rec_in.last_updated_by                 := NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.last_update_date                := SYSDATE;
   -- l_mod_rec_in.last_update_login               := NULL ; --OKC_API.G_MISS_NUM;
   -- l_mod_rec_in.security_group_id               := NULL ;
   -- l_mod_rec_in.attribute1                      := NULL ;
   -- l_mod_rec_in.attribute2                      := NULL ;
   -- l_mod_rec_in.attribute3                      := NULL ;
   -- l_mod_rec_in.attribute4                      := NULL ;
   -- l_mod_rec_in.attribute5                      := NULL ;
   -- l_mod_rec_in.attribute6                      := NULL ;
   -- l_mod_rec_in.attribute7                      := NULL ;
   -- l_mod_rec_in.attribute8                      := NULL ;
   -- l_mod_rec_in.attribute9                      := NULL ;
   -- l_mod_rec_in.attribute10                     := NULL ;
   -- l_mod_rec_in.attribute11                     := NULL ;
   -- l_mod_rec_in.attribute12                     := NULL ;
   -- l_mod_rec_in.attribute13                     := NULL ;
   -- l_mod_rec_in.attribute14                     := NULL ;
   -- l_mod_rec_in.attribute15                     := NULL ;

      OKS_MOD_PVT.insert_row(  	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_OksMschgOperationsDtlsVRec    => l_mod_rec_in,
                                XOksMschgOperationsDtlsVRec     => l_mod_rec_out);




        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

    end if;
   END IF;

END CREATE_OPERATION_INSTANCES;

PROCEDURE UPDATE_OPERATION_INSTANCES (p_oie_rec  IN opr_instance_rec_type,
                                      p_mrd_rec  IN masschange_request_rec_type,
                                      x_return_status OUT NOCOPY Varchar2) is
------------------------------------------------------------------
---TAPI variables
------------------------------------------------------------------
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;

  l_oiev_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE
  l_oiev_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE

  l_omrv_rec_in         OKC_OPER_INST_PUB.mrdv_rec_type;
  l_omrv_rec_out        OKC_OPER_INST_PUB.mrdv_rec_type;

  l_omrv_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type;
  l_omrv_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type;

  CURSOR Get_line_req(p_oie_id IN Number) IS
         SELECT id from okc_masschange_req_dtls_v
         WHERE  oie_id = p_oie_id;
BEGIN
       --dbms_output.put_line('Inside ..');

    l_oiev_tbl_in(1).id                              := p_oie_rec.oie_id; --OKC_API.G_MISS_CHAR;
    l_oiev_tbl_in(1).name                            := p_oie_rec.NAME; --OKC_API.G_MISS_CHAR;
    l_oiev_tbl_in(1).object1_id1                     := p_oie_rec.update_level_value;
    l_oiev_tbl_in(1).jtot_object1_code               := p_oie_rec.update_level;


/*
       OKC_OPER_INST_PUB.UPdate_Operation_Instance(
    	p_api_version					=> l_api_version,
    	p_init_msg_list					=> l_init_msg_list,
    	x_return_status					=> l_return_status,
    	x_msg_count					    => l_msg_count,
    	x_msg_data					    => l_msg_data,
    	p_oiev_rec					    => l_oiev_tbl_in(1),
    	x_oiev_rec					    => l_oiev_tbl_out(1));

        --dbms_output.put_line('Value of upd_opn_inst l_return_status='||l_return_status);


       --dbms_output.put_line('oie_id:'||l_oiev_tbl_out(1).id||',status:'||l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
        --dbms_output.put_line('Value of l_return_status:'||l_return_status||'l_msg_data='||l_msg_data);
    ELSIF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
*/
        --dbms_output.put_line('Assigning ..');

        OPEN Get_line_req(p_mrd_rec.oie_id);
        FETCH Get_line_req INTO l_omrv_rec_in.id;
        CLOSE Get_line_req;
        --dbms_output.put_line('l_omrv_rec_in.id:'||l_omrv_rec_in.id);
--    l_omrv_rec_in.id                              := p_mrd_rec.id;
    --l_omrv_rec_in.ole_id                          := NULL;
    l_omrv_rec_in.oie_id                          := p_mrd_rec.oie_id;
    l_omrv_rec_in.attribute_name                  := p_mrd_rec.attribute_name;
    l_omrv_rec_in.old_value                       := p_mrd_rec.old_value;
    l_omrv_rec_in.new_value                       := p_mrd_rec.new_value;


        --dbms_output.put_line('Calling ..');

     OKC_OPER_INST_PUB.Update_Masschange_Dtls(
                            	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_mrdv_rec                      => l_omrv_rec_in,
                                x_mrdv_rec                      => l_omrv_rec_out);

        --dbms_output.put_line('Omr status:'||l_return_status);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
       OKC_OPER_INST_PUB.UPdate_Operation_Instance(
    	p_api_version					=> l_api_version,
    	p_init_msg_list					=> l_init_msg_list,
    	x_return_status					=> l_return_status,
    	x_msg_count					    => l_msg_count,
    	x_msg_data					    => l_msg_data,
    	p_oiev_rec					    => l_oiev_tbl_in(1),
    	x_oiev_rec					    => l_oiev_tbl_out(1));

        --dbms_output.put_line('Value of upd_opn_inst l_return_status='||l_return_status);

--   END IF;
   x_return_status := l_return_status;
EXCEPTION WHEN OTHERS THEN
        log_messages('EXCEPTION:'||SQLERRM);
        --dbms_output.put_line('EXCEPTION:'||SQLERRM);
END UPDATE_OPERATION_INSTANCES;

PROCEDURE DELETE_OPERATION_INSTANCES (p_oie_rec  IN opr_instance_rec_type,
                                      x_return_status OUT NOCOPY Varchar2) is
------------------------------------------------------------------
---TAPI variables
------------------------------------------------------------------
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;

  l_oiev_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE
  l_oiev_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type; --OPERATION INSTANCE

--/*
--  l_omrv_rec_in         OKC_OPER_INST_PUB.mrdv_rec_type;
--  l_omrv_rec_out        OKC_OPER_INST_PUB.mrdv_rec_type;

--  l_omrv_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type;
--  l_omrv_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type;

-- CURSOR omrv_id is
--  SELECT ID from OKC_MASSCHANGE_REQ_DTLS_V
--  WHERE oie_id = p_oie_rec.oie_id;
-- */

BEGIN
       --dbms_output.put_line('Inside ..');
/*
       OPEN omrv_id;
       BEGIN
        FETCH omrv_id into l_omrv_rec_in.id;
       EXCEPTION
        WHEN OTHERS THEN
              RAISE G_EXCEPTION_HALT_VALIDATION ;
       END;
       CLOSE omrv_id;

    l_omrv_rec_in.oie_id                          := p_oie_rec.oie_id;

        --dbms_output.put_line('Calling ..');

     OKC_OPER_INST_PUB.Delete_Masschange_Dtls(
                            	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_mrdv_rec                      => l_omrv_rec_in);

        --dbms_output.put_line('Omr status:'||l_return_status);

        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
   */

       l_oiev_tbl_in(1).id                              := p_oie_rec.oie_id; --OKC_API.G_MISS_CHAR;

       OKC_OPER_INST_PUB.Delete_Operation_Instance(
    	p_api_version					=> l_api_version,
    	p_init_msg_list					=> l_init_msg_list,
    	x_return_status					=> l_return_status,
    	x_msg_count					    => l_msg_count,
    	x_msg_data					    => l_msg_data,
    	p_oiev_rec					    => l_oiev_tbl_in(1));

--dbms_output.put_line(' OKC_OPER_INST_PUB.Delete_Operation_Instance Value of l_return_status='||l_return_status);
        --dbms_output.put_line('oie_id:'||l_oiev_tbl_out(1).id||',status:'||l_return_status);
            IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

       -- END IF;
                     x_return_status := l_return_status;
END DELETE_OPERATION_INSTANCES;


PROCEDURE CREATE_MASSCHANGE_LINE_DTLS(p_omr_rec  IN masschange_request_rec_type,
                                     x_omr_id   OUT NOCOPY NUMBER) is
------------------------------------------------------------------
---TAPI variables
------------------------------------------------------------------
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out	NUMBER;

  l_omrv_rec_in         OKC_OPER_INST_PUB.mrdv_rec_type;
  l_omrv_rec_out        OKC_OPER_INST_PUB.mrdv_rec_type;

  l_omrv_tbl_in         OKC_OPER_INST_PUB.oiev_tbl_type;
  l_oiev_tbl_out        OKC_OPER_INST_PUB.oiev_tbl_type;

  l_mod_rec_in          OKS_MOD_PVT.OksMschgOperationsDtlsVRecType;
  l_mod_rec_out         OKS_MOD_PVT.OksMschgOperationsDtlsVRecType;
--------------------------------------------------------------------
---Program Variables
--------------------------------------------------------------------
  l_max_id NUMBER := 0;
-------------------------------------------------------------------------
---Find the Class Operation ID to be used
-------------------------------------------------------------------------

BEGIN

    --dbms_output.put_line('Inside masschange_line_dtls');

    l_omrv_rec_in.oie_id                         := NULL;
    l_omrv_rec_in.ole_id                         := p_omr_rec.ole_id;
    l_omrv_rec_in.attribute_name                 := p_omr_rec.attribute_name;
    l_omrv_rec_in.old_value                      := p_omr_rec.old_value;
    l_omrv_rec_in.new_value                      := p_omr_rec.new_value;
    l_omrv_rec_in.id                              := null;
    l_omrv_rec_in.object_version_number           := NULL ; --OKC_API.G_MISS_NUM;
    l_omrv_rec_in.created_by                      := NULL ; --OKC_API.G_MISS_NUM;
    l_omrv_rec_in.creation_date                   := SYSDATE;
 --   l_omrv_rec_in.last_updated_by                 := OKC_API.G_MISS_NUM;
    l_omrv_rec_in.last_update_date                := SYSDATE;
    l_omrv_rec_in.last_update_login               := NULL ; --OKC_API.G_MISS_NUM;

     OKC_OPER_INST_PUB.Create_Masschange_Dtls (
                            	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_mrdv_rec                      => l_omrv_rec_in,
                                x_mrdv_rec                      => l_omrv_rec_out);

     --dbms_output.put_line('After masschange_line_dtls: status:'||l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        x_omr_id := l_omrv_rec_out.id;
    END IF;


    l_mod_rec_in.id                              := null;
    l_mod_rec_in.mrd_id                          := l_omrv_rec_out.id ;
    l_mod_rec_in.oie_id                          := null;
    l_mod_rec_in.ole_id                          := p_omr_rec.ole_id ; --null;
    l_mod_rec_in.mschg_type                      := null;
    l_mod_rec_in.attribute_level                 := null;
    l_mod_rec_in.qa_check_yn                     := p_omr_rec.qa_check_yn;
    l_mod_rec_in.object_version_number           := NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.created_by                      := NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.creation_date                   := SYSDATE;
    l_mod_rec_in.last_updated_by                 := NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.last_update_date                := SYSDATE;
   -- l_mod_rec_in.last_update_login               := NULL ; --OKC_API.G_MISS_NUM;
   -- l_mod_rec_in.security_group_id               := NULL ;
   -- l_mod_rec_in.attribute1                      := NULL ;
   -- l_mod_rec_in.attribute2                      := NULL ;
   -- l_mod_rec_in.attribute3                      := NULL ;
   -- l_mod_rec_in.attribute4                      := NULL ;
   -- l_mod_rec_in.attribute5                      := NULL ;
   -- l_mod_rec_in.attribute6                      := NULL ;
   -- l_mod_rec_in.attribute7                      := NULL ;
   -- l_mod_rec_in.attribute8                      := NULL ;
   -- l_mod_rec_in.attribute9                      := NULL ;
   -- l_mod_rec_in.attribute10                     := NULL ;
   -- l_mod_rec_in.attribute11                     := NULL ;
   -- l_mod_rec_in.attribute12                     := NULL ;
   -- l_mod_rec_in.attribute13                     := NULL ;
   -- l_mod_rec_in.attribute14                     := NULL ;
   -- l_mod_rec_in.attribute15                     := NULL ;

      OKS_MOD_PVT.insert_row(  	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_OksMschgOperationsDtlsVRec    => l_mod_rec_in,
                                XOksMschgOperationsDtlsVRec     => l_mod_rec_out);


        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

       EXCEPTION
           WHEN OTHERS THEN
           x_omr_id := NULL;
           RAISE;

END CREATE_MASSCHANGE_LINE_DTLS;

----------------------------------------------------------------------------
---Create  OKC_OPERATIONS_LINES
----------------------------------------------------------------------------

PROCEDURE CREATE_OPERATION_LINES (p_ole_tbl IN ole_tbl_type, --olev_tbl_type,
                                  x_ole_tbl OUT NOCOPY OKC_OPER_INST_PUB.olev_tbl_type) IS

----------------------------------------------------------------------------
---TAPI variables
----------------------------------------------------------------------------
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out						NUMBER;

  l_olev_tbl_in          OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES
  l_olev_tbl_out         OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES


------------------------------------------------------------------
---PROGRAM variables
------------------------------------------------------------------
 i NUMBER := 1;
 j NUMBER := 1;
------------------------------------------------------------------------
---PROGRAM BEGINS HERE
------------------------------------------------------------------------
 BEGIN
  WHILE p_ole_tbl.exists(j) LOOP
    l_olev_tbl_in(i).select_yn                       := p_ole_tbl(j).select_yn;
    l_olev_tbl_in(i).active_yn                       := NULL ; --OKC_API.G_MISS_CHAR;
    l_olev_tbl_in(i).process_flag                    := p_ole_tbl(j).process_flag;
    l_olev_tbl_in(i).oie_id                          := p_ole_tbl(j).oie_id;
    l_olev_tbl_in(i).subject_chr_id                  := p_ole_tbl(j).chr_id;
    l_olev_tbl_in(i).object_chr_id                   := NULL;
    l_olev_tbl_in(i).subject_cle_id                  := NULL;
    l_olev_tbl_in(i).parent_ole_id                   := NULL;
    l_olev_tbl_in(i).object_cle_id                   := NULL;
    l_olev_tbl_in(i).object_version_number           := NULL ; --OKC_API.G_MISS_NUM;
    l_olev_tbl_in(i).created_by                      := NULL ; --OKC_API.G_MISS_NUM;
    l_olev_tbl_in(i).creation_date                   := SYSDATE;
    l_olev_tbl_in(i).last_updated_by                 := NULL ; --OKC_API.G_MISS_NUM;
    l_olev_tbl_in(i).last_update_date                := SYSDATE;
    l_olev_tbl_in(i).last_update_login               := NULL ; --OKC_API.G_MISS_NUM;
    l_olev_tbl_in(i).request_id                      := FND_GLOBAL.CONC_REQUEST_ID;
    l_olev_tbl_in(i).program_application_id          := FND_GLOBAL.PROG_APPL_ID;
    l_olev_tbl_in(i).program_id                      := FND_GLOBAL.CONC_PROGRAM_ID;
    l_olev_tbl_in(i).program_update_date             := NULL ; --OKC_API.G_MISS_DATE;
    l_olev_tbl_in(i).message_code                    := NULL ; --OKC_API.G_MISS_CHAR;
--dbms_output.put_line('Value of l_olev_tbl_in(i).oie_id='||TO_CHAR(l_olev_tbl_in(i).oie_id));
    i:=i+1;
    j:=j+1;
 END LOOP;

     OKC_OPER_INST_PUB.Create_Operation_Line(
    	p_api_version					=> l_api_version,
    	p_init_msg_list					=> l_init_msg_list,
    	x_return_status					=> l_return_status,
    	x_msg_count					=> l_msg_count,
    	x_msg_data					=> l_msg_data,
    	p_olev_tbl					=> l_olev_tbl_in,
    	x_olev_tbl					=> x_ole_tbl);
--dbms_output.put_line('Value of l_return_status='||l_return_status);
--dbms_output.put_line('l_olev_tbl_out(1).id:'||to_char(x_ole_tbl(1).id));

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
 --COMMIT;
 --dbms_output.put_line('eND OF oPERATION _LINES');
END CREATE_OPERATION_LINES;

PROCEDURE DELETE_OPERATION_LINES (p_oie_id IN Number,
                                  x_return_status OUT NOCOPY Varchar2) IS

----------------------------------------------------------------------------
---TAPI variables
----------------------------------------------------------------------------
  l_api_version		CONSTANT	NUMBER	:= 1.0;
  l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);

  l_msg_index_out						NUMBER;

  l_olev_tbl_in          OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES
  l_olev_tbl_out         OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES

  l_omrv_tbl_in          OKC_OPER_INST_PUB.mrdv_tbl_type; --OPERATION LINES

  CURSOR Get_opn_lines IS
         SELECT ole.id ole_id,omr.id omr_id
         from OKC_OPERATION_LINES_V ole, OKC_MASSCHANGE_REQ_DTLS_V omr
         where ole.id = omr.ole_id
         AND   omr.oie_id IS NULL
         AND   ole.oie_id = p_oie_id;
------------------------------------------------------------------
---PROGRAM variables
------------------------------------------------------------------
 i NUMBER := 1;
 j NUMBER := 1;
------------------------------------------------------------------------
---PROGRAM BEGINS HERE
------------------------------------------------------------------------
 BEGIN
--  WHILE p_ole_tbl.exists(j)
FOR ole_rec IN Get_opn_lines
LOOP
    l_olev_tbl_in(i).id                          := ole_rec.ole_id;
    l_olev_tbl_in(i).oie_id                      := p_oie_id;

    l_omrv_tbl_in(i).id                          := ole_rec.omr_id;
    l_omrv_tbl_in(i).ole_id                      := p_oie_id;

--dbms_output.put_line('Value of l_olev_tbl_in(i).oie_id='||TO_CHAR(l_olev_tbl_in(i).oie_id));
    i:=i+1;
 END LOOP;

     OKC_OPER_INST_PUB.Delete_Masschange_Dtls (
    	p_api_version				=> l_api_version,
    	p_init_msg_list				=> l_init_msg_list,
    	x_return_status				=> l_return_status,
    	x_msg_count					=> l_msg_count,
    	x_msg_data					=> l_msg_data,
        p_mrdv_tbl                  => l_omrv_tbl_in);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN

     OKC_OPER_INST_PUB.Delete_Operation_Line(
    	p_api_version				=> l_api_version,
    	p_init_msg_list				=> l_init_msg_list,
    	x_return_status				=> l_return_status,
    	x_msg_count					=> l_msg_count,
    	x_msg_data					=> l_msg_data,
    	p_olev_tbl					=> l_olev_tbl_in);
     END IF;
--dbms_output.put_line('Value of l_return_status='||l_return_status);


    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   x_return_status := l_return_status;
 --dbms_output.put_line('END OF OPERATION _LINES');
END DELETE_OPERATION_LINES;

PROCEDURE UPDATE_OPERATION_LINES(p_ole_id IN NUMBER,
                                 p_select_yn IN VARCHAR2,
                                 p_qa_check_yn IN VARCHAR2 ) IS

        l_api_version		CONSTANT	NUMBER	:= 1.0;
        l_init_msg_list	    VARCHAR2(2000) := OKC_API.G_FALSE;
        l_return_status	    VARCHAR2(1);
        l_msg_count		    NUMBER;
        l_msg_data		    VARCHAR2(2000);
        l_msg_index_out	    NUMBER;
        l_olev_tbl_in       OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES
        l_olev_tbl_out      OKC_OPER_INST_PUB.olev_tbl_type; --OPERATION LINES

        l_mod_tbl_in      OKS_MOD_PVT.OksMschgOperationsDtlsVRecType ;
        l_mod_tbl_out     OKS_MOD_PVT.OksMschgOperationsDtlsVRecType ;
        p_mod_id          NUMBER ;
        p_mod_mrd_id      NUMBER ;
        l_message         Varchar2(3000) ;

 BEGIN

     l_olev_tbl_in(1).id        := p_ole_id ;
     l_olev_tbl_in(1).select_yn := p_select_yn ;

     OKC_OPER_INST_PUB.Update_Operation_Line(
        	p_api_version			 => l_api_version,
    	    p_init_msg_list			 => l_init_msg_list,
    	    x_return_status			 => l_return_status,
    	    x_msg_count			     => l_msg_count,
    	    x_msg_data			     => l_msg_data,
    	    p_olev_tbl			     => l_olev_tbl_in,
    	    x_olev_tbl		         => l_olev_tbl_out   );

     LOG_MESSAGES('OKC_OPER_INST_PUB.Update_Operation_Line l_return_status = ' || l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        LOG_MESSAGES('OKC_OPER_INST_PUB.Update_Operation_Line l_msg_data = ' || l_msg_data);
        Rollback;
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        LOG_MESSAGES('OKC_OPER_INST_PUB.Update_Operation_Line l_msg_data = ' || l_msg_data);
        Rollback;
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

        Select mcd.id , mcd.mrd_id into  p_mod_id ,p_mod_mrd_id
        from oks_mschg_operations_dtls mcd
        where mcd.ole_id = p_ole_id ;

        l_mod_tbl_in.id            := p_mod_id;
        l_mod_tbl_in.qa_check_yn   := p_qa_check_yn  ; --:OKSOIE_LINES.qa_check_yn;

        OKS_MOD_PVT.Update_row(
           p_api_version                   => l_api_version,
           p_init_msg_list                 => l_init_msg_list,
           x_return_status                 => l_return_status,
           x_msg_count                     => l_msg_count,
           x_msg_data                      => l_msg_data,
           p_OksMschgOperationsDtlsVRec    => l_mod_tbl_in,
           XOksMschgOperationsDtlsVRec     => l_mod_tbl_out );


     		IF l_msg_count > 0
                  THEN
                  FOR i in 1..l_msg_count
                  LOOP
                    fnd_msg_pub.get (p_msg_index     => -1,
                                     p_encoded       => 'F', -- OKC$APPLICATION.GET_FALSE,
                                     p_data          => l_msg_data,
                                     p_msg_index_out => l_msg_index_out);
                    l_message := l_message||' ; '||l_msg_data;
                  END LOOP;
                END IF;
 Exception
    When others then
    LOG_MESSAGES('Error Message' || SQLERRM);
 END UPDATE_OPERATION_LINES;




  PROCEDURE get_attribute_value(p_attr_code IN Varchar2,
                                 p_attr_id IN Varchar2,
                                 p_org_id   IN Number,
                                 x_attr_value OUT NOCOPY Varchar2,
                                 x_attr_name  OUT NOCOPY Varchar2)
   IS
       CURSOR get_k_group(p_id IN NUmber) IS
             SELECT name
             FROM   okc_k_groups_v
             WHERE  id = p_id;
       CURSOR get_contact(p_id IN NUmber) IS
             SELECT name
             FROM   okc_k_groups_v
             WHERE  id = p_id;

--       CURSOR get_ccid(p_ccid IN Number) IS
--             SELECT concatenated_segments
--             FROM   gl_code_combinations_kfv
--             WHERE  code_combination_id = p_ccid;

      CURSOR get_ccid (p_ccid IN NUmber, p_organization_id Number) IS

	      SELECT  gcck.concatenated_segments
	      From gl_code_combinations_kfv  gcck
	        ,  HR_ALL_ORGANIZATION_UNITS HOU
	        ,  HR_ORGANIZATION_INFORMATION HOI2
	        ,  GL_LEDGERS GSOB
	      WHERE HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
	      AND ( HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
	      AND HOI2.ORG_INFORMATION1 = TO_CHAR(GSOB.LEDGER_ID)
	      AND gcck.code_combination_id = p_ccid
	      and GSOB.chart_of_accounts_id = gcck.chart_of_accounts_id
	      and HOU.organization_id  = p_organization_id
	      and GSOB.object_type_code = 'L'
	      AND nvl(GSOB.complete_flag, 'Y') = 'Y' ;


       CURSOR Cur_salesrep(p_id1 IN Number, p_org_id Number) IS
              Select rep.name
              From okx_salesreps_v rep
              Where rep.id1     = p_id1
              and rep.org_id    = p_org_id ;

       CURSOR get_cov_type(p_attr_code IN Varchar2) IS
              SELECT meaning
              FROM   oks_cov_types_v
              WHERE  code = p_attr_code ;
       CURSOR get_timezone(p_attr_code IN Varchar2) IS
              SELECT name
              FROM   okx_timezones_v
              WHERE  timezone_id = p_attr_code ;

-- Select statemet for the following cursor was changed to address performance issue. Bug#3231915
       CURSOR get_pref_engg(p_attr_code IN Varchar2) IS
             SELECT EMP.FULL_NAME NAME
             FROM JTF_RS_RESOURCE_EXTNS RSC
                 ,FND_USER U
                 ,OKX_PER_ALL_PEOPLE_V EMP
             WHERE RSC.RESOURCE_ID  = p_attr_code
             AND RSC.CATEGORY = 'EMPLOYEE'
             AND EMP.PERSON_ID = RSC.SOURCE_ID
             AND U.USER_ID = RSC.USER_ID  ;
--            SELECT name
--              FROM   okx_resources_v
--             WHERE  id1 = p_attr_code ;
       CURSOR get_res_group(p_attr_code IN Varchar2) IS

              SELECT name
              FROM   oks_resource_groups_v
              WHERE  id1 = p_attr_code ;

       CURSOR get_billing_profile(p_attr_code IN Varchar2) IS
              SELECT description
              FROM   oks_billing_profiles_v
              WHERE  id = p_attr_code ;
       CURSOR get_agreement_name(p_attr_code IN Varchar2) IS
              SELECT name
              FROM   okx_agreements_v
              WHERE  agreement_id = p_attr_code ;

       CURSOR get_line_contact(p_attr_code IN Varchar2) IS
               SELECT SUBSTRB(P.PERSON_LAST_NAME,1,50) || ', ' ||
                      SUBSTRB(P.PERSON_FIRST_NAME,1,40) NAME
               FROM HZ_CUST_ACCOUNT_ROLES CAR,
                    HZ_PARTIES P,
		    --NPALEPU
                    --29-JUN-2005
                    --TCA Project
                    --Replaced hz_party_relationships table with hz_relationships table
                    /* HZ_PARTY_RELATIONSHIPS PR, */
                    HZ_RELATIONSHIPS PR,
                    --END NPALEPU
                    HZ_ORG_CONTACTS OC
               WHERE CAR.ROLE_TYPE = 'CONTACT'
               AND PR.PARTY_ID = CAR.PARTY_ID
               AND PR.CONTENT_SOURCE_TYPE = 'USER_ENTERED'
               --NPALEPU
               --29-JUN-2005
               --TCA Project
               --Replaced pr.party_relationship_id column with pr.relationship_id column and added new conditions
               /* AND OC.PARTY_RELATIONSHIP_ID = PR.PARTY_RELATIONSHIP_ID */
               AND OC.PARTY_RELATIONSHIP_ID = PR.RELATIONSHIP_ID
               AND PR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND PR.OBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND PR.DIRECTIONAL_FLAG = 'F'
               --END NPALEPU
               AND P.PARTY_ID = PR.SUBJECT_ID
               --NPALEPU
               --29-JUN-2005
               --TCA Project
               --Replaced dates check with status check as the 'Begin_date' and 'End_date' columns of hz_cust_account_roles table are migrated to 'Status' column
               /* AND DECODE(SIGN(TRUNC(sysdate) -
                   TRUNC(NVL(car.begin_date,sysdate))),-1,'I', DECODE(SIGN(TRUNC(sysdate) -
                   TRUNC(NVL(car.end_date,sysdate))),1,'I','A')) = 'A' */
               AND car.status = 'A'
               --END NPALEPU
               AND EXISTS
                   (SELECT 'X'
                    FROM hz_cust_acct_sites_all cas
                    WHERE cas.cust_account_id = car.cust_account_id)
                    AND CAR.CUST_ACCOUNT_ROLE_ID = p_attr_code ;

--- Cursor for new ATTRIBUTES

       CURSOR get_YN_meaning(p_attr_id IN Varchar2) IS
     	      Select meaning
              From fnd_lookups
              Where lookup_code = p_attr_id
              And lookup_type   = 'OKS_SC_YES_NO' ;

       CURSOR get_Renewal_type(p_attr_id IN Varchar2) IS
     	      Select meaning
              From fnd_lookups
              Where lookup_code = p_attr_id
              And lookup_type   in( 'OKC_RENEWAL_TYPE','OKS_RENEWAL_TYPE') ;

       CURSOR get_price_list(p_attr_id IN Varchar2) IS
     	      Select name
              From okx_list_headers_v
              Where id1 = p_attr_id
              And list_type_code = 'PRL';


       l_attr_value     Varchar2(100);
       l_min            varchar2(5);

       FUNCTION Get_attribute(p_lookup_code IN Varchar2)
       RETURN  Varchar2 IS

       CURSOR Cur_lookup IS
             SELECT meaning FROM fnd_lookups
             WHERE lookup_type = 'OKS_MASS_CHANGE_ATTRIBUTE'
             AND   lookup_code = p_lookup_code;
       l_meaning  Varchar2(100);

       BEGIN
              OPEN Cur_lookup;
              FETCH Cur_lookup INTO l_meaning;
              CLOSE Cur_lookup;

              RETURN(l_meaning);
       EXCEPTION WHEN OTHERS THEN
           RETURN(NULL);
          RAISE;
       END Get_attribute;

     FUNCTION GET_LOOKUP_MEANING(p_type IN VARCHAR2, p_code IN VARCHAR2) RETURN VARCHAR2 IS
         l_meaning VARCHAR2(90);

         Cursor l_lookup_csr is
         SELECT MEANING
         FROM FND_LOOKUPS
         WHERE  LOOKUP_TYPE = p_type
           AND  LOOKUP_CODE = p_code ;

     BEGIN
           OPEN l_lookup_csr;
              fetch l_lookup_csr into l_meaning;
           CLOSE l_lookup_csr;

          Return l_meaning;

        EXCEPTION
          When OTHERS then
            Return p_code;
     END GET_LOOKUP_MEANING;

     FUNCTION Get_addr(p_attr_code IN Varchar2, p_attr_id IN Varchar2)
     RETURN Varchar2 IS
       l_site_code  Varchar2(10);
       l_addr  Varchar2(500);

       CURSOR Cur_addr(p_site_code IN Varchar2) IS
             SELECT name FROM OKX_CUST_SITE_USES_V
             WHERE id1 = p_attr_id
             AND site_use_code = p_site_code
             AND  id2 = '#';
     BEGIN
            IF p_attr_code = 'HDR_BILL_TO_ADDRESS' THEN
               l_site_code := 'BILL_TO';

               OPEN Cur_addr(l_site_code);
               FETCH Cur_addr INTO l_addr;
               CLOSE Cur_addr;
             ELSIF p_attr_code = 'HDR_SHIP_TO_ADDRESS' THEN
               l_site_code := 'SHIP_TO';

               OPEN Cur_addr(l_site_code);
               FETCH Cur_addr INTO l_addr;
               CLOSE Cur_addr;
             END IF;
          RETURN(nvl(l_addr,NULL));
     END Get_addr;

   BEGIN
      IF p_attr_code = 'CONTRACT_GROUP'
      AND p_attr_id IS not NULL
      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04 GET_STATUS_MEANING
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_k_group(to_number(p_attr_id));
           FETCH get_k_group INTO l_attr_value;
           CLOSE get_k_group;
         END IF;
        --x_attr_name := Get_attribute(p_attr_code);

      ELSIF p_attr_code in ('HDR_BILL_TO_ADDRESS')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04 GET_STATUS_MEANING
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE

            l_attr_value := Get_addr(p_attr_code,p_attr_id);
         END IF;
      --x_attr_name := Get_attribute(p_attr_code);
      ELSIF p_attr_code in ('HDR_SHIP_TO_ADDRESS')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04 GET_STATUS_MEANING
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE

            l_attr_value := Get_addr(p_attr_code,p_attr_id);
         END IF;
      --x_attr_name := Get_attribute(p_attr_code);

      ELSIF p_attr_code in ('PAYMENT_TERM')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
          l_attr_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => 'OKX_RPAYTERM',
                                                           p_id1 => p_attr_id,
                                                           p_id2 => '#');

         END IF;

      ELSIF p_attr_code in ('ACCT_RULE')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
          l_attr_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => 'OKX_ACCTRULE',
                                                           p_id1 => p_attr_id,
                                                           p_id2 => '#');

         END IF;

      ELSIF p_attr_code in ('INV_RULE')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
          l_attr_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => 'OKX_INVRULE',
                                                           p_id1 => p_attr_id,
                                                           p_id2 => '#');

         END IF;
      ELSIF p_attr_code = 'COV_TYPE'
      AND p_attr_id IS not NULL       THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_cov_type(p_attr_id);
           FETCH get_cov_type INTO l_attr_value;
           CLOSE get_cov_type;
         END IF;

      ELSIF p_attr_code = 'COV_TIMEZONE'
      AND p_attr_id IS not NULL
      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_timezone(p_attr_id);
           FETCH get_timezone INTO l_attr_value;
           CLOSE get_timezone;
         END IF;

      ELSIF p_attr_code = 'PREF_ENGG'
      AND p_attr_id IS not NULL
      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_pref_engg(p_attr_id);
           FETCH get_pref_engg INTO l_attr_value;
           CLOSE get_pref_engg;
         END IF;

      ELSIF p_attr_code = 'RES_GROUP'
      AND p_attr_id IS not NULL
      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_res_group(p_attr_id);
           FETCH get_res_group INTO l_attr_value;
           CLOSE get_res_group;
         END IF;

      ELSIF p_attr_code = 'BILLING_PROFILE'
      AND p_attr_id IS not NULL       THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_billing_profile(p_attr_id);
           FETCH get_billing_profile INTO l_attr_value;
           CLOSE get_billing_profile;
         END IF;

      ELSIF p_attr_code = 'AGREEMENT_NAME'
      AND p_attr_id IS not NULL       THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_agreement_name(p_attr_id);
           FETCH get_agreement_name INTO l_attr_value;
           CLOSE get_agreement_name;
         END IF;


      ELSIF p_attr_code in ('PARTY_BILLING_CONTACT','PARTY_SHIPPING_CONTACT')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
          l_attr_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => 'OKX_PCONTACT',
                                                           p_id1 => p_attr_id,
                                                           p_id2 => '#');
         END IF ;

      ELSIF p_attr_code in ('LINE_BILLING_CONTACT','LINE_SHIPPING_CONTACT')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           OPEN  get_line_contact(p_attr_id);
           FETCH get_line_contact INTO l_attr_value;
           CLOSE get_line_contact;

         END IF ;

      --x_attr_name := Get_attribute(p_attr_code);
      ELSIF p_attr_code in ('SALES_REP')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--         l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
          --l_attr_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => 'OKX_SALEPERS',
          --                                                 p_id1 => p_attr_id,
          --                                                 p_id2 => '#');
            Open Cur_salesrep(to_number(p_attr_id),p_org_id);
            Fetch Cur_salesrep into l_attr_value;
            Close Cur_salesrep;
         END IF;
      --x_attr_name := Get_attribute(p_attr_code);
      ELSIF p_attr_code in ('PRICE_LIST')
      AND p_attr_id IS not NULL      THEN
         IF p_attr_id = '-1111'
         THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSIF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
          l_attr_value := OKC_UTIL.GET_NAME_FROM_JTFV(p_object_code => 'OKX_PRICE',
                                                           p_id1 => p_attr_id,
                                                           p_id2 => '#');
         END IF;
      --x_attr_name := Get_attribute(p_attr_code);
      ELSIF p_attr_code in ('REACTION_TIME','RESOLUTION_TIME','COVERAGE_START_TIME','COVERAGE_END_TIME')
         AND p_attr_id IS not NULL THEN
         IF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSE
           l_min := mod(to_number(p_attr_id),60);
           IF length(l_min) <2 then
              l_min := l_min||'0';
           END IF;
           l_attr_value := trunc(to_number(p_attr_id)/60)||':'||l_min;
         END IF;
     -- x_attr_name := Get_attribute(p_attr_code);

      ELSIF (p_attr_code in ('CONTRACT_START_DATE',
                             'CONTRACT_END_DATE',
                             'CONTRACT_ALIAS',
                             'PRODUCT_ALIAS',
                             'CONTRACT_LINE_REF'))
           AND p_attr_id IS not NULL then
         IF p_attr_id = '-9999'
         THEN
           l_attr_value := NULL;
         ELSIF p_attr_id = '-1111'
              THEN
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
           l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
         ELSE
           l_attr_value := p_attr_id;
         END IF;

      ELSIF (p_attr_code in ('REV_ACCT'))
            AND p_attr_id IS not NULL then

            IF p_attr_id = '-1111'
              THEN
              -- Modified the following since "ALL" cause translation issues.
              -- 10-MAR-04
              --  l_attr_value := 'ALL';
               l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
            ELSIF p_attr_id = '-9999'
            THEN
               l_attr_value := NULL;
            ELSE
             OPEN  get_ccid(to_number(p_attr_id),p_org_id);
             FETCH get_ccid INTO l_attr_value;
             CLOSE get_ccid;
            END IF;

 -- Coding for new attributes
      ELSIF p_attr_code in ('PO_REQUIRED_REN','SUMMARY_PRINT') AND p_attr_id IS not NULL THEN
           If p_attr_id = '-9999' Then
              l_attr_value := NULL;
           Elsif p_attr_id = '-1111' Then
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
               l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
           Else
             If p_attr_id = 'Y' then
                Open get_YN_meaning('YES');
                Fetch get_YN_meaning into l_attr_value;
                Close get_YN_meaning;
             Elsif p_attr_id = 'N' then
                Open get_YN_meaning('NO');
                Fetch get_YN_meaning into l_attr_value;
                Close get_YN_meaning;
             End If;
           End If;

      ELSIF p_attr_code in ('CON_RENEWAL_TYPE') AND p_attr_id IS not NULL THEN
           If p_attr_id = '-9999' Then
              l_attr_value := NULL;
           Elsif p_attr_id = '-1111' Then
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
               l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
           Else
             Open get_renewal_type(p_attr_id);
             Fetch get_renewal_type into l_attr_value;
             Close get_renewal_type;
           End If;
      ELSIF p_attr_code in ('BP_PRICE_LIST') AND p_attr_id IS not NULL THEN
           If p_attr_id = '-9999' Then
              l_attr_value := NULL;
           Elsif p_attr_id = '-1111' Then
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
               l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
           Else
             Open get_price_list(p_attr_id);
             Fetch get_price_list into l_attr_value;
             Close get_price_list;
           End If;
      Elsif p_attr_code in ('PO_NUMBER_BILL') AND p_attr_id IS not NULL Then
           If p_attr_id = '-9999' Then
              l_attr_value := NULL;
           Elsif p_attr_id = '-1111' Then
-- Modified the following since "ALL" cause translation issues.
-- 10-MAR-04
--           l_attr_value := 'ALL';
               l_attr_value := GET_LOOKUP_MEANING('OKS_MSCHG_MISC','-1111');
           Else
               l_attr_value := p_attr_id;
           End If;

      END IF;
       x_attr_value := rtrim(l_attr_value);
       x_attr_name := Get_attribute(p_attr_code);
      EXCEPTION
      WHEN OTHERS Then
      RAISE ;

   END Get_attribute_value;

PROCEDURE Create_Mschg_Class_Operation
IS
  CURSOR Check_class_opn IS
         SELECT count(*) cnt FROM okc_class_operations_v
         WHERE opn_code = 'MASS_CHANGE'
         AND   cls_code = 'SERVICE';
  CURSOR Get_max_id IS
         SELECT nvl(max(id),0) + 1 from okc_class_operations_v;

 l_opn_id  Number;
 l_count   Number := 0;
BEGIN

   FOR opn_rec IN Check_class_opn
   LOOP
        l_count := opn_rec.cnt;
   END LOOP;

   IF l_count = 0 THEN

      OPEN Get_max_id;
      FETCH Get_max_id INTO l_opn_id;
      CLOSE Get_max_id;

   INSERT INTO okc_class_operations(
     ID
    ,OPN_CODE
    ,CLS_CODE
    ,SEARCH_FUNCTION_ID
    ,DETAIL_FUNCTION_ID
    ,OBJECT_VERSION_NUMBER
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    --,SECURITY_GROUP_ID
    ,PDF_ID)
    values
    (l_opn_id
    ,'MASS_CHANGE'
    ,'SERVICE'
    ,NULL
    ,NULL
    ,10000
    ,1
    ,SYSDATE
    ,1
    ,SYSDATE
    ,0
    --,NULL
    ,NULL);

    commit;
    END IF;
    EXCEPTION WHEN OTHERS THEN
    RAISE;
END Create_Mschg_Class_Operation;

PROCEDURE UPDATE_LINE_STATUS(p_oie_id IN Number) IS
 PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

 UPDATE okc_operation_lines
 SET    process_flag = NULL
 WHERE  oie_id = p_oie_id
 AND    select_yn = 'Y'
 AND    process_flag in ('A','E');

 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN
        LOG_MESSAGES('UPDATE_LINE_STATUS: '||SQLERRM);
 END UPDATE_LINE_STATUS;

 PROCEDURE UPDATE_QA_CHECK_YN_COL IS

 Cursor get_rec IS SELECT
                   mrd.id
                  ,mrd.oie_id
                  ,mrd.ole_id
                  ,mrd.attribute_name
                  ,mrd.old_value
                  ,mrd.new_value
                  ,mrd.object_version_number
                  ,mrd.created_by
                  ,mrd.creation_date
                  ,mrd.last_updated_by
                  ,mrd.last_update_date
                  ,mrd.last_update_login
                  ,mrd.security_group_id
                  ,okh.sts_code status_code
             FROM okc_masschange_req_dtls mrd,
                  okc_operation_lines opn,
                  okc_k_headers_b okh
             WHERE mrd.ole_id = opn.id(+)
             AND opn.subject_chr_id = okh.id(+) ;

    l_api_version		CONSTANT	NUMBER	:= 1.0;
    l_init_msg_list	VARCHAR2(2000) := OKC_API.G_FALSE;
    l_return_status	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
    l_msg_index_out	NUMBER;
    l_mod_rec_in          OKS_MOD_PVT.OksMschgOperationsDtlsVRecType;
    l_mod_rec_out         OKS_MOD_PVT.OksMschgOperationsDtlsVRecType;

 BEGIN

  FOR r1 in  get_rec LOOP

    l_mod_rec_in.id                              := null;
    l_mod_rec_in.mrd_id                          := r1.id ; --l_omrv_rec_out.id ;
    l_mod_rec_in.oie_id                          := r1.oie_id ; --x_oie_id;
    l_mod_rec_in.ole_id                          := r1.ole_id ; --null;
    l_mod_rec_in.mschg_type                      := null;
    l_mod_rec_in.attribute_level                 := null;
    --l_mod_rec_in.qa_check_yn                     := r1.qa_check_yn ; --null; --p_mrd_rec.qa_check_yn;
    l_mod_rec_in.object_version_number           := r1.object_version_number ; --NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.created_by                      := r1.created_by ; --NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.creation_date                   := r1.creation_date ; --SYSDATE;
    l_mod_rec_in.last_updated_by                 := r1.last_updated_by ; --NULL ; --OKC_API.G_MISS_NUM;
    l_mod_rec_in.last_update_date                := r1.last_update_date ; --SYSDATE;
   -- l_mod_rec_in.last_update_login               := NULL ; --OKC_API.G_MISS_NUM;
   -- l_mod_rec_in.security_group_id               := NULL ;

    IF r1.status_code  IS NOT NULL and  r1.status_code = 'ACTIVE' then
       l_mod_rec_in.qa_check_yn := 'Y'  ;
    ELSIF
       r1.status_code  IS NOT NULL and  r1.status_code <> 'ACTIVE' then
       l_mod_rec_in.qa_check_yn := 'N'  ;
    ELSIF
       r1.status_code  IS NULL then
       l_mod_rec_in.qa_check_yn := NULL  ;
    END IF ;

      OKS_MOD_PVT.insert_row(  	p_api_version					=> l_api_version,
    	                        p_init_msg_list					=> l_init_msg_list,
    	                        x_return_status					=> l_return_status,
    	                        x_msg_count					    => l_msg_count,
    	                        x_msg_data					    => l_msg_data,
                                p_OksMschgOperationsDtlsVRec    => l_mod_rec_in,
                                XOksMschgOperationsDtlsVRec     => l_mod_rec_out);


    END LOOP ;
 END UPDATE_QA_CHECK_YN_COL ;

END OKS_MASSCHANGE_PVT;


/
