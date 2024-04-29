--------------------------------------------------------
--  DDL for Package Body OKE_VERSION_COMPARISON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_VERSION_COMPARISON_PKG" AS
/* $Header: OKEKVCPB.pls 120.6.12010000.3 2008/11/26 08:53:37 serukull ship $ */

    G_Pkg_Name       VARCHAR2(30) := 'OKE_VERSION_COMPARISON_PKG';
    g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_approval_paths_pkg.';

    l_no_sequence NUMBER :=0;
    l_amt_mask_1    VARCHAR2(80);
    l_prc_mask_1    VARCHAR2(80);
    l_amt_mask_2    VARCHAR2(80);
    l_prc_mask_2    VARCHAR2(80);
    l_object_type   OKE_VERSION_COMPARE_RESULTS.OBJECT_TYPE%TYPE;
    l_object_name   OKE_VERSION_COMPARE_RESULTS.OBJECT_NAME%TYPE;
    l_prompt        OKE_VERSION_COMPARE_RESULTS.PROMPT%TYPE;
    l_data1         OKE_VERSION_COMPARE_RESULTS.V1DATA%TYPE;
    l_data2         OKE_VERSION_COMPARE_RESULTS.V2DATA%TYPE;
    l_current_flag  OKE_VERSION_COMPARE_RESULTS.CURRENT_FLAG%TYPE default 'N';
    l_Object VARCHAR(80);               --lookup code  in fnd_lookup
    L_Attribute_Object_Name VARCHAR(80); --object name in oke_object_attributes_vl

    L_Latest_Version NUMBER :=0;           --The highest version in HV table


 PROCEDURE SET_FORMAT_MASKS( cur1 VARCHAR2, cur2 VARCHAR2 ) IS
   l_precision NUMBER;
   l_ext_precision  NUMBER;
   l_min_acct_unit NUMBER;
  BEGIN
   l_amt_mask_1 := FND_CURRENCY.GET_FORMAT_MASK( NVL(cur1, 'USD') , 38 );
   FND_CURRENCY.GET_INFO( NVL(cur1, 'USD'),l_precision,l_ext_precision,l_min_acct_unit);
   FND_CURRENCY.BUILD_FORMAT_MASK(l_prc_mask_1,38,l_ext_precision,l_min_acct_unit);
   IF Nvl(cur2,'USD')<>Nvl(cur1,'USD') THEN
     l_amt_mask_2 := FND_CURRENCY.GET_FORMAT_MASK( NVL(cur2, 'USD') , 38 );
     FND_CURRENCY.GET_INFO( NVL(cur2, 'USD'),l_precision,l_ext_precision,l_min_acct_unit);
     FND_CURRENCY.BUILD_FORMAT_MASK(l_prc_mask_2,38,l_ext_precision,l_min_acct_unit);
    ELSE
     l_amt_mask_2 := l_amt_mask_1;
     l_prc_mask_2 := l_prc_mask_1;
   END IF;
 END;

 PROCEDURE SET_AMOUNT_DIFF_DATA( data1 NUMBER, data2 NUMBER ) IS
  BEGIN
   l_data1 := Ltrim(Rtrim(TO_CHAR( data1, l_amt_mask_1 )));
   l_data2 := Ltrim(Rtrim(TO_CHAR( data2, l_amt_mask_2 )));
 END;

 PROCEDURE SET_PRICE_DIFF_DATA( data1 NUMBER, data2 NUMBER ) IS
  BEGIN
   l_data1 := Ltrim(Rtrim(TO_CHAR( data1, l_prc_mask_1 )));
   l_data2 := Ltrim(Rtrim(TO_CHAR( data2, l_prc_mask_2 )));
 END;

 FUNCTION get_full_path_linenum(vk_line_id NUMBER,vVersion NUMBER) RETURN VARCHAR2
  IS
    l_linenum varchar2(300):=null;
    cursor c_lines is
     SELECT line_number
      FROM OKC_K_LINES_BH
      WHERE major_version = vVersion
      CONNECT BY PRIOR cle_id=id
      START WITH id= vk_line_id AND major_version = vVersion;

  BEGIN
    FOR c IN c_lines LOOP
      IF l_linenum IS NULL THEN
        l_linenum := c.line_number;
       ELSE
        l_linenum := c.line_number||'-->'||l_linenum;
      END IF;
    END LOOP;
    RETURN l_linenum;

  EXCEPTION
    WHEN OTHERS THEN
        NULL;
 END get_full_path_linenum;

 FUNCTION get_full_path_linenum(vk_line_id NUMBER) RETURN VARCHAR2
  IS
    l_linenum varchar2(300):=null;
    cursor c_lines is
     SELECT line_number
      FROM OKC_K_LINES_B
      CONNECT BY PRIOR cle_id=id
      START WITH id= vk_line_id;

  BEGIN
    FOR c IN c_lines LOOP
      IF l_linenum IS NULL THEN
        l_linenum := c.line_number;
       ELSE
        l_linenum := c.line_number||'-->'||l_linenum;
      END IF;
    END LOOP;
    RETURN l_linenum;

  EXCEPTION
    WHEN OTHERS THEN
        NULL;
 END get_full_path_linenum;

FUNCTION  get_article_subject_name(p_sbt_code IN VARCHAR2)RETURN VARCHAR2
   IS
       l_not_found BOOLEAN;
       l_meaning VARCHAR2(80);

       Cursor c Is
         SELECT MEANING
         FROM FND_LOOKUPS
         WHERE LOOKUP_TYPE ='OKC_SUBJECT'
         AND LOOKUP_CODE = p_sbt_code;

    BEGIN
         open c;
         fetch c into l_meaning;
         l_not_found := c%NOTFOUND;
         close c;

/*
         If (l_not_found) Then
             raise NO_DATA_FOUND;
         End If;
*/
       RETURN l_meaning;

   END get_article_subject_name;


 PROCEDURE get_article_info(p_cat_type      IN   VARCHAR2,
                            p_sav_sae_id    IN   NUMBER,
                            p_sbt_code      IN   VARCHAR2,
                            p_article_name  IN   VARCHAR2,
                            x_sbt_code      OUT  NOCOPY             VARCHAR2,
                            x_article_name  OUT  NOCOPY             VARCHAR2,
                            x_subject_name  OUT  NOCOPY             VARCHAR2)
   IS

      CURSOR C (p_id number)IS
      SELECT Nvl(display_name,article_title) NAME ,ARTICLE_TYPE
         FROM OKC_ARTICLES_V
      WHERE article_id = p_id;

      l_name VARCHAR2(150);
      l_sbt_code VARCHAR2(30);
      l_not_found BOOLEAN;

   BEGIN
      IF p_cat_type = 'STA' THEN
          If (p_sav_sae_id is not null) Then

             OPEN C(p_sav_sae_id);
             FETCH C into l_name,l_sbt_code;

             IF (C%NOTFOUND) THEN
               CLOSE C;
               RAISE NO_DATA_FOUND;
             End If;

             CLOSE C;

             x_article_name := l_name;
             x_sbt_code :=l_sbt_code;
             x_subject_name := get_article_subject_name(x_sbt_code);

          END IF;

      ELSE
          x_article_name :=p_article_name;
          x_sbt_code :=p_sbt_code;
          x_subject_name := get_article_subject_name(p_sbt_code);

      END IF;
   END get_article_info;


PROCEDURE insert_comp_result(vHeader_id IN NUMBER,vVersion1 IN NUMBER, vVersion2 IN NUMBER)
  IS
    CREATED_BY NUMBER;
    CREATION_DATE DATE;
    LAST_UPDATE_DATE DATE;
    LAST_UPDATE_BY NUMBER;
    LAST_UPDATE_LOGIN NUMBER;
    L_PROMPT_MULTI VARCHAR2(80);

    CURSOR C_Prompt_Multi (v_prompt varchar2) IS
    SELECT o.attribute_name
    FROM   oke_object_attributes_vl o
    WHERE  o.attribute_code = l_prompt
    AND    o.database_object_name=L_Attribute_Object_Name;

    BEGIN

        l_no_sequence :=l_no_sequence +1;

        CREATION_DATE := SYSDATE;
        CREATED_BY := FND_GLOBAL.USER_ID;
        LAST_UPDATE_DATE :=SYSDATE;
        LAST_UPDATE_BY :=FND_GLOBAL.USER_ID;
        LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;

        OPEN C_Prompt_Multi (l_prompt );
        FETCH C_Prompt_Multi INTO L_PROMPT_MULTI;
        CLOSE C_Prompt_Multi;

        IF L_PROMPT_MULTI IS NULL THEN
	   L_PROMPT_MULTI :=l_prompt;
        END IF;

        INSERT INTO OKE_VERSION_COMPARE_RESULTS
        (k_header_id,
         version1,
	 version2,
         object_type,
         object_id,
	 object_name,
         sequence,
	 prompt,
	 v1data,
	 v2data,
	 current_flag,
	 creation_date,
	 created_by,
	 last_update_date,
         last_update_by,
	 last_update_login)
        VALUES
         (vHeader_id,
          vVersion1,
          vVersion2,
          l_object_type,
          null,
          l_object_name,
          l_no_sequence,
          L_PROMPT_MULTI,
          l_data1,
          l_data2,
          l_current_flag,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_BY,
          LAST_UPDATE_LOGIN);

         l_data1 :='';
         l_data2 :='';


   EXCEPTION
	WHEN OTHERS THEN
        NULL;

  END insert_comp_result;


  PROCEDURE comp_all_items(p_Header_id IN NUMBER, p_Version_1 IN NUMBER, p_Version_2 IN NUMBER)
  IS
     l_api_name     CONSTANT VARCHAR2(30) := 'comp_all_items';
     nTemp_Version  NUMBER;
     nComparison    NUMBER;

     nCurrent_highest_version number :=0;  --The highest version in ver_comp result table

     vVersion1 NUMBER :=p_version_1;
     vVersion2 NUMBER :=p_version_2;

     cursor c_nLatest_version is
        SELECT MAX(MAJOR_VERSION)
        FROM OKE_K_HEADERS_H
        WHERE K_HEADER_ID=p_header_id;

     cursor c_nCurrent_highest_version is
        SELECT MAX(version1)
        FROM oke_version_compare_results
        WHERE k_header_id=p_header_id;

     BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Begin comparing all items ...');
   END IF;
      IF vVersion1 < vVersion2 THEN
       nTemp_Version := vVersion1;
       vVersion1 := vVersion2;
       vVersion2 := nTemp_Version;
      END IF;

      OPEN c_nLatest_version;
      fetch c_nLatest_version into L_Latest_Version;
      close c_nLatest_version;

      open c_nCurrent_highest_version;
      FETCH c_nCurrent_highest_version INTO nCurrent_highest_version;
      close c_nCurrent_highest_version;

      --clear table data
      DELETE FROM oke_version_compare_results;
      COMMIT;

      comp_headers(p_header_id ,vVersion1, vVersion2);
      comp_header_parties(p_header_id ,vVersion1, vVersion2);
      comp_header_terms(p_header_id,vVersion1, vVersion2);
      comp_header_articles(p_header_id,vVersion1, vVersion2);
      comp_lines(p_header_id, vVersion1, vVersion2);

      COMMIT;

      EXCEPTION
          WHEN NO_DATA_FOUND THEN
          NULL;
          WHEN OTHERS THEN
          NULL;

  END comp_all_items;

  PROCEDURE comp_headers(vHeader_id  IN NUMBER, vVersion1 IN NUMBER, vVersion2 IN NUMBER)
  IS
     TYPE r_header IS RECORD(
        k_type                     OKE_K_HEADERS_SECURE_HV.k_type%TYPE,
        buy_or_sell                OKE_K_HEADERS_SECURE_HV.buy_or_sell%TYPE,
        boa_number                 OKE_K_HEADERS_SECURE_HV.boa_number%TYPE,
        program_number             OKE_K_HEADERS_SECURE_HV.program_number%TYPE,
        product_line               OKE_K_HEADERS_SECURE_HV.product_line%TYPE,
        status                     OKE_K_HEADERS_SECURE_HV.status%TYPE,
        project_name               OKE_K_HEADERS_SECURE_HV.project_name%TYPE,
        line_value_total           OKE_K_HEADERS_SECURE_HV.line_value_total%TYPE,
        undef_line_value_total     OKE_K_HEADERS_SECURE_HV.undef_line_value_total%TYPE,
        k_value                    OKE_K_HEADERS_SECURE_HV.k_value%TYPE,
        k_alias                    OKE_K_HEADERS_SECURE_HV.k_alias%TYPE,
        currency_code              OKE_K_HEADERS_SECURE_HV.currency_code%TYPE,
        priority_rating            OKE_K_HEADERS_SECURE_HV.priority_rating%TYPE,
        major_version              OKE_K_HEADERS_SECURE_HV.major_version%TYPE,
        award_date                 OKE_K_HEADERS_SECURE_HV.award_date%TYPE,
        start_date                 OKE_K_HEADERS_SECURE_HV.start_date%TYPE,
        end_date                   OKE_K_HEADERS_SECURE_HV.end_date%TYPE,
        prime_k_number             OKE_K_HEADERS_SECURE_HV.prime_k_number%TYPE,
        prime_k_alias              OKE_K_HEADERS_SECURE_HV.prime_k_alias%TYPE,
        authoring_org              OKE_K_HEADERS_SECURE_HV.authoring_org%TYPE,
--      item_master_org            OKE_K_HEADERS_SECURE_HV.item_master_org%TYPE,
        owning_organization        OKE_K_HEADERS_SECURE_HV.owning_organization%TYPE,
        short_description          OKE_K_HEADERS_SECURE_HV.short_description%TYPE,
        description                OKE_K_HEADERS_SECURE_HV.description%TYPE,
        authorize_date             OKE_K_HEADERS_SECURE_HV.authorize_date%TYPE,
        date_issued                OKE_K_HEADERS_SECURE_HV.date_issued%TYPE,
        date_received              OKE_K_HEADERS_SECURE_HV.date_received%TYPE,
        award_cancel_date          OKE_K_HEADERS_SECURE_HV.award_cancel_date%TYPE,
        date_negotiated            OKE_K_HEADERS_SECURE_HV.date_negotiated%TYPE,
        date_approved              OKE_K_HEADERS_SECURE_HV.date_approved%TYPE,
        sic_code                   OKE_K_HEADERS_SECURE_HV.sic_code%TYPE,
        date_sign_by_customer      OKE_K_HEADERS_SECURE_HV.date_sign_by_customer%TYPE,
        date_sign_by_contractor    OKE_K_HEADERS_SECURE_HV.date_sign_by_contractor%TYPE,
        faa_approve_date           OKE_K_HEADERS_SECURE_HV.faa_approve_date%TYPE,
        customer_po_number         OKE_K_HEADERS_SECURE_HV.customer_po_number%TYPE,
        no_competition_authorize   OKE_K_HEADERS_SECURE_HV.no_competition_authorize%TYPE,
        export_flag                OKE_K_HEADERS_SECURE_HV.export_flag%TYPE,
        classified_flag            OKE_K_HEADERS_SECURE_HV.classified_flag%TYPE,
        penalty_clause_flag        OKE_K_HEADERS_SECURE_HV.penalty_clause_flag%TYPE,
        reporting_flag             OKE_K_HEADERS_SECURE_HV.reporting_flag%TYPE,
        sb_plan_req_flag           OKE_K_HEADERS_SECURE_HV.sb_plan_req_flag%TYPE,
        sb_report_flag             OKE_K_HEADERS_SECURE_HV.sb_report_flag%TYPE,
        cqa_flag                   OKE_K_HEADERS_SECURE_HV.cqa_flag%TYPE,
        cfe_flag                   OKE_K_HEADERS_SECURE_HV.cfe_flag%TYPE,
        prop_delivery_location     OKE_K_HEADERS_SECURE_HV.prop_delivery_location%TYPE,
        prop_due_date_time         OKE_K_HEADERS_SECURE_HV.prop_due_date_time%TYPE,
        prop_expire_date           OKE_K_HEADERS_SECURE_HV.prop_expire_date%TYPE,
        copies_required            OKE_K_HEADERS_SECURE_HV.copies_required%TYPE,
        --billing_methods                  OKE_K_HEADERS_SECURE_HV.billing_methods%TYPE,
        --billing_methods_button           OKE_K_HEADERS_SECURE_HV.billing_methods_button%TYPE,
        country_of_origin_code     OKE_K_HEADERS_SECURE_HV.country_of_origin_code%TYPE,
        vat_code                   OKE_K_HEADERS_SECURE_HV.vat_code%TYPE,
        cost_of_sale_rate          OKE_K_HEADERS_SECURE_HV.cost_of_sale_rate%TYPE,
        nte_amount                 OKE_K_HEADERS_SECURE_HV.nte_amount%TYPE,
        date_definitized           OKE_K_HEADERS_SECURE_HV.date_definitized%TYPE,
        tech_data_wh_rate          OKE_K_HEADERS_SECURE_HV.tech_data_wh_rate%TYPE,
        financial_ctrl_verified_flag          OKE_K_HEADERS_SECURE_HV.financial_ctrl_verified_flag%TYPE,
        nte_warning_flag           OKE_K_HEADERS_SECURE_HV.nte_warning_flag%TYPE,
        cas_flag                   OKE_K_HEADERS_SECURE_HV.cas_flag%TYPE,
        dcaa_audit_req_flag        OKE_K_HEADERS_SECURE_HV.dcaa_audit_req_flag%TYPE,
        interim_rpt_req_flag       OKE_K_HEADERS_SECURE_HV.interim_rpt_req_flag%TYPE,
        cost_of_money              OKE_K_HEADERS_SECURE_HV.cost_of_money%TYPE,
        oh_rates_final_flag        OKE_K_HEADERS_SECURE_HV.oh_rates_final_flag%TYPE,
        progress_payment_flag      OKE_K_HEADERS_SECURE_HV.progress_payment_flag%TYPE,
        progress_payment_rate      OKE_K_HEADERS_SECURE_HV.progress_payment_rate%TYPE,
        progress_payment_liq_rate  OKE_K_HEADERS_SECURE_HV.progress_payment_liq_rate%TYPE,
        alternate_liquidation_rate OKE_K_HEADERS_SECURE_HV.alternate_liquidation_rate%TYPE,
        cost_share_flag            OKE_K_HEADERS_SECURE_HV.cost_share_flag%TYPE,
        definitized_flag           OKE_K_HEADERS_SECURE_HV.definitized_flag%TYPE,
        bill_without_def_flag      OKE_K_HEADERS_SECURE_HV.bill_without_def_flag%TYPE,
        comments                   OKE_K_HEADERS_SECURE_HV.comments%TYPE
        );


     l_api_name     CONSTANT VARCHAR2(30) := 'comp_headers';
     r_header_1 r_header;
     r_header_2 r_header;

     CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;


  BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Begin comparing header ...');
   END IF;
     L_Attribute_Object_Name :='OKE_K_HEADERS';
     l_Object :='HEADER';

     OPEN c;
     FETCH c INTO l_object_type;
     CLOSE c;

     l_object_name :='';

     --
     --If version1 is the current highest version
     --
     IF L_Latest_Version < vVersion1  THEN
          l_current_flag := 'Y';

          SELECT k_type,
                 buy_or_sell,
		 boa_number,
                 program_number,
                 product_line,
                 status,
                 project_name,
                 line_value_total,
                 undef_line_value_total,
                 k_value,
                 k_alias,
                 currency_code,
                 priority_rating,
                 major_version,
                 award_date,
                 start_date,
                 end_date,
                 prime_k_number,
                 prime_k_alias,
                 authoring_org,
                 --item_master_org,
                 owning_organization,
                 short_description,
                 description,
                 authorize_date,
                 date_issued,
                 date_received,
                 award_cancel_date,
                 date_negotiated,
                 date_approved,
                 sic_code,
                 date_sign_by_customer,
                 date_sign_by_contractor,
                 faa_approve_date,
                 customer_po_number,
                 no_competition_authorize,
                 export_flag,
                 classified_flag,
                 penalty_clause_flag,
                 reporting_flag,
                 sb_plan_req_flag,
                 sb_report_flag,
                 cqa_flag,
                 cfe_flag,
                 prop_delivery_location,
                 prop_due_date_time,
                 prop_expire_date,
                 copies_required,
                 --billing_methods,
                 --billing_methods_button,
                 country_of_origin_code,
                 vat_code,
                 cost_of_sale_rate,
                 nte_amount,
                 date_definitized,
                 tech_data_wh_rate,
                 financial_ctrl_verified_flag,
                 nte_warning_flag,
                 cas_flag,
                 dcaa_audit_req_flag,
                 interim_rpt_req_flag,
                 cost_of_money,
                 oh_rates_final_flag,
                 progress_payment_flag,
                 progress_payment_rate,
                 progress_payment_liq_rate,
                 alternate_liquidation_rate,
                 cost_share_flag,
                 definitized_flag,
                 bill_without_def_flag,
                 comments

                 INTO r_header_1
                 FROM OKE_K_HEADERS_SECURE_V
                 WHERE K_HEADER_ID=vHeader_id;

       ELSE
           SELECT k_type,
                 buy_or_sell,
                 boa_number,
                 program_number,
                 product_line,
                 status,
                 project_name,
                 line_value_total,
                 undef_line_value_total,
                 k_value,
                 k_alias,
                 currency_code,
                 priority_rating,
                 major_version,
                 award_date,
                 start_date,
                 end_date,
                 prime_k_number,
                 prime_k_alias,
                 authoring_org,
                 --item_master_org,
                 owning_organization,
                 short_description,
                 description,
                 authorize_date,
                 date_issued,
                 date_received,
                 award_cancel_date,
                 date_negotiated,
                 date_approved,
                 sic_code,
                 date_sign_by_customer,
                 date_sign_by_contractor,
                 faa_approve_date,
                 customer_po_number,
                 no_competition_authorize,
                 export_flag,
                 classified_flag,
                 penalty_clause_flag,
                 reporting_flag,
                 sb_plan_req_flag,
                 sb_report_flag,
                 cqa_flag,
                 cfe_flag,
                 prop_delivery_location,
                 prop_due_date_time,
                 prop_expire_date,
                 copies_required,
                 --billing_methods,
                 --billing_methods_button,
                 country_of_origin_code,
                 vat_code,
                 cost_of_sale_rate,
                 nte_amount,
                 date_definitized,
                 tech_data_wh_rate,
                 financial_ctrl_verified_flag,
                 nte_warning_flag,
                 cas_flag,
                 dcaa_audit_req_flag,
                 interim_rpt_req_flag,
                 cost_of_money,
                 oh_rates_final_flag,
                 progress_payment_flag,
                 progress_payment_rate,
                 progress_payment_liq_rate,
                 alternate_liquidation_rate,
                 cost_share_flag,
                 definitized_flag,
                 bill_without_def_flag,
                 comments

                 INTO r_header_1
                 FROM OKE_K_HEADERS_SECURE_HV
                 WHERE K_HEADER_ID=vHeader_id
                 AND MAJOR_VERSION=vVersion1;

        END IF;

        SELECT k_type,
                 buy_or_sell,
                 boa_number,
                 program_number,
                 product_line,
                 status,
                 project_name,
                 line_value_total,
                 undef_line_value_total,
                 k_value,
                 k_alias,
                 currency_code,
                 priority_rating,
                 major_version,
                 award_date,
                 start_date,
                 end_date,
                 prime_k_number,
                 prime_k_alias,
                 authoring_org,
    --           item_master_org,
                 owning_organization,
                 short_description,
                 description,
                 authorize_date,
                 date_issued,
                 date_received,
                 award_cancel_date,
                 date_negotiated,
                 date_approved,
                 sic_code,
                 date_sign_by_customer,
                 date_sign_by_contractor,
                 faa_approve_date,
                 customer_po_number,
                 no_competition_authorize,
                 export_flag,
                 classified_flag,
                 penalty_clause_flag,
                 reporting_flag,
                 sb_plan_req_flag,
                 sb_report_flag,
                 cqa_flag,
                 cfe_flag,
                 prop_delivery_location,
                 prop_due_date_time,
                 prop_expire_date,
                 copies_required,
                 --billing_methods,
                 --billing_methods_button,
                 country_of_origin_code,
                 vat_code,
                 cost_of_sale_rate,
                 nte_amount,
                 date_definitized,
                 tech_data_wh_rate,
                 financial_ctrl_verified_flag,
                 nte_warning_flag,
                 cas_flag,
                 dcaa_audit_req_flag,
                 interim_rpt_req_flag,
                 cost_of_money,
                 oh_rates_final_flag,
                 progress_payment_flag,
                 progress_payment_rate,
                 progress_payment_liq_rate,
                 alternate_liquidation_rate,
                 cost_share_flag,
                 definitized_flag,
                 bill_without_def_flag,
                 comments

              INTO r_header_2
              FROM OKE_K_HEADERS_SECURE_HV
              WHERE K_HEADER_ID=vHeader_id
              AND MAJOR_VERSION=vVersion2;

     SET_FORMAT_MASKS( r_header_1.currency_code, r_header_2.currency_code );

     IF r_header_1.K_TYPE <> r_header_2.K_TYPE THEN
        l_prompt := 'K_TYPE';
        l_data1  := r_header_1.K_TYPE;
        l_data2  := r_header_2.K_TYPE;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);

     END IF;

     IF (r_header_1.BUY_OR_SELL <> r_header_2.BUY_OR_SELL)
         OR( NOT((r_header_1.BUY_OR_SELL is null)and(r_header_2.BUY_OR_SELL is null))
             AND ((r_header_1.BUY_OR_SELL is null)or(r_header_2.BUY_OR_SELL is null)))THEN
        l_prompt := 'BUY_OR_SELL';
        l_data1  := r_header_1.BUY_OR_SELL;
        l_data2  := r_header_2.BUY_OR_SELL;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.BOA_NUMBER <> r_header_2.BOA_NUMBER)
        OR( NOT((r_header_1.BOA_NUMBER is null)and(r_header_2.BOA_NUMBER is null))
             AND ((r_header_1.BOA_NUMBER is null)or(r_header_2.BOA_NUMBER is null)))THEN
        l_prompt := 'BOA_NUMBER';
        l_data1  := r_header_1.BOA_NUMBER;
        l_data2  := r_header_2.BOA_NUMBER;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.PROGRAM_NUMBER <> r_header_2.PROGRAM_NUMBER)
         OR( NOT((r_header_1.program_number is null)and(r_header_2.program_number is null))
             AND ((r_header_1.program_number is null)or(r_header_2.program_number is null)))THEN
        l_prompt := 'PROGRAM_NUMBER';
        l_data1  := r_header_1.program_number;
        l_data2  := r_header_2.program_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.product_line <> r_header_2.product_line)
         OR( NOT((r_header_1.product_line is null)and(r_header_2.product_line is null))
             AND ((r_header_1.product_line is null)or(r_header_2.product_line is null))) THEN
        l_prompt := 'PRODUCT_LINE';
        l_data1  := r_header_1.product_line;
        l_data2  := r_header_2.product_line;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF r_header_1.STATUS <> r_header_2.STATUS THEN
        l_prompt := 'STATUS';
        l_data1  := r_header_1.STATUS;
        l_data2  := r_header_2.STATUS;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.PROJECT_NAME <> r_header_2.PROJECT_NAME)
         OR( NOT((r_header_1.project_name is null)and(r_header_2.project_name is null))
             AND ((r_header_1.project_name is null)or(r_header_2.project_name is null)))THEN
        l_prompt := 'PROJECT_NAME';
        l_data1  := r_header_1.PROJECT_NAME;
        l_data2  := r_header_2.PROJECT_NAME;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF (r_header_1.LINE_VALUE_TOTAL <>  r_header_2.LINE_VALUE_TOTAL)
         OR( NOT((r_header_1.line_value_total is null)and(r_header_2.line_value_total is null))
             AND ((r_header_1.line_value_total is null)or(r_header_2.line_value_total is null))) THEN
        l_prompt := 'LINE_VALUE_TOTAL';
        SET_AMOUNT_DIFF_DATA( r_header_1.LINE_VALUE_TOTAL, r_header_2.LINE_VALUE_TOTAL);
        insert_comp_result(vHeader_id,vVersion1,vVersion2);

     END IF;

     IF (r_header_1.UNDEF_LINE_VALUE_TOTAL <>  r_header_2.UNDEF_LINE_VALUE_TOTAL)
         OR( NOT((r_header_1.UNDEF_line_value_total is null)and(r_header_2.UNDEF_line_value_total is null))
             AND ((r_header_1.UNDEF_line_value_total is null)or(r_header_2.UNDEF_line_value_total is null))) THEN
        l_prompt := 'UNDEF_LINE_VALUE_TOTAL';
        SET_AMOUNT_DIFF_DATA( r_header_1.UNDEF_LINE_VALUE_TOTAL, r_header_2.UNDEF_LINE_VALUE_TOTAL);
        insert_comp_result(vHeader_id,vVersion1,vVersion2);

     END IF;

     IF nvl(r_header_1.K_VALUE,0) <> nvl(r_header_2.K_VALUE,0) THEN
        l_prompt := 'K_VALUE';
        SET_AMOUNT_DIFF_DATA( r_header_1.k_value, r_header_2.k_value );
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF nvl(r_header_1.K_ALIAS,' ') <> nvl(r_header_2.K_ALIAS,' ') THEN
        l_prompt := 'K_ALIAS';
        l_data1  := r_header_1.k_alias;
        l_data2  := r_header_2.K_alias;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.currency_code <> r_header_2.currency_code )
         OR( NOT((r_header_1.currency_code is null)and(r_header_2.currency_code is null))
             AND ((r_header_1.currency_code is null)or(r_header_2.currency_code is null)))THEN
        l_prompt := 'CURRENCY_CODE';
        l_data1  := r_header_1.currency_code;
        l_data2  := r_header_2.currency_code;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF( r_header_1.priority_rating <> r_header_2.priority_rating )
         OR( NOT((r_header_1.priority_rating is null)and(r_header_2.priority_rating is null))
             AND ((r_header_1.priority_rating is null)or(r_header_2.priority_rating is null)))THEN
        l_prompt := 'PRIORITY_RATING';
        l_data1  := r_header_1.priority_rating;
        l_data2  := r_header_2.priority_rating;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
/*
     IF r_header_1.MAJOR_VERSION <>  r_header_2.MAJOR_VERSION THEN
        l_prompt := 'OBJECT_VERSION_NUMBER';
        l_data1  := r_header_1.MAJOR_VERSION;
        l_data2  := r_header_2.MAJOR_VERSION;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
*/
     IF (r_header_1.award_date <> r_header_2.award_date )
	 OR( NOT((r_header_1.award_date is null)and(r_header_2.award_date is null))
             AND ((r_header_1.award_date is null)or(r_header_2.award_date is null)))THEN
        l_prompt := 'AWARD_DATE';
        l_data1  := r_header_1.award_date;
        l_data2  := r_header_2.award_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.START_DATE <>  r_header_2.START_DATE )
	 OR( NOT((r_header_1.start_date is null)and(r_header_2.start_date is null))
             AND ((r_header_1.start_date is null)or(r_header_2.start_date is null)))THEN
        l_prompt := 'START_DATE';
        l_data1  := r_header_1.START_DATE;
        l_data2  := r_header_2.START_DATE;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);

     END IF;

     IF (r_header_1.end_date <> r_header_2.end_date)
 	 OR( NOT((r_header_1.end_date is null)and(r_header_2.end_date is null))
             AND ((r_header_1.end_date is null)or(r_header_2.end_date is null))) THEN
        l_prompt := 'END_DATE';
        l_data1  := r_header_1.end_date;
        l_data2  := r_header_2.end_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.prime_k_number <> r_header_2.prime_k_number )
         OR( NOT((r_header_1.prime_k_number is null)and(r_header_2.prime_k_number is null))
             AND ((r_header_1.prime_k_number is null)or(r_header_2.prime_k_number is null)))THEN
        l_prompt := 'PRIME_K_NUMBER';
        l_data1  := r_header_1.prime_k_number;
        l_data2  := r_header_2.prime_k_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.prime_k_alias <> r_header_2.prime_k_alias )
	 OR( NOT((r_header_1.prime_k_alias is null)and(r_header_2.prime_k_alias is null))
             AND ((r_header_1.prime_k_alias is null)or(r_header_2.prime_k_alias is null)))THEN
        l_prompt := 'PRIME_K_ALIAS';
        l_data1  := r_header_1.prime_k_alias;
        l_data2  := r_header_2.prime_k_alias;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.authoring_org <> r_header_2.authoring_org )
	 OR( NOT((r_header_1.authoring_org is null)and(r_header_2.authoring_org is null))
             AND ((r_header_1.authoring_org is null)or(r_header_2.authoring_org is null)))THEN
        l_prompt := 'AUTHORING_ORG';
        l_data1  := r_header_1.authoring_org;
        l_data2  := r_header_2.authoring_org;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
/*
      IF r_header_1.item_master_org <> r_header_2.item_master_org THEN
        l_prompt := 'ITEM_MASTER_ORG';
        l_data1  := r_header_1.item_master_org;
        l_data2  := r_header_2.item_master_org;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
*/

     IF (r_header_1.owning_organization <> r_header_2.owning_organization )
         OR( NOT((r_header_1.owning_organization is null)and(r_header_2.owning_organization is null))
             AND ((r_header_1.owning_organization is null)or(r_header_2.owning_organization is null)))THEN
        l_prompt := 'OWNING_ORGANIZATION';
        l_data1  := r_header_1.owning_organization;
        l_data2  := r_header_2.owning_organization;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF nvl(r_header_1.short_description,' ') <> nvl(r_header_2.short_description,' ') THEN
        l_prompt := 'SHORT_DESCRIPTION';
        l_data1  := r_header_1.short_description;
        l_data2  := r_header_2.short_description;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.description <> r_header_2.description )
	 OR( NOT((r_header_1.description is null)and(r_header_2.description is null))
             AND ((r_header_1.description is null)or(r_header_2.description is null)))THEN
        l_prompt := 'DESCRIPTION';
        l_data1  := r_header_1.description;
        l_data2  := r_header_2.description;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.authorize_date <> r_header_2.authorize_date )
	 OR( NOT((r_header_1.authorize_date is null)and(r_header_2.authorize_date is null))
             AND ((r_header_1.authorize_date is null)or(r_header_2.authorize_date is null)))THEN
        l_prompt := 'AUTHORIZE_DATE';
        l_data1  := r_header_1.authorize_date;
        l_data2  := r_header_2.authorize_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF (r_header_1.date_issued <> r_header_2.date_issued )
	 OR( NOT((r_header_1.date_issued is null)and(r_header_2.date_issued is null))
             AND ((r_header_1.date_issued is null)or(r_header_2.date_issued is null)))THEN
        l_prompt := 'DATE_ISSUED';
        l_data1  := r_header_1.date_issued;
        l_data2  := r_header_2.date_issued;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.date_received <> r_header_2.date_received )
	 OR( NOT((r_header_1.date_received is null)and(r_header_2.date_received is null))
             AND ((r_header_1.date_received is null)or(r_header_2.date_received is null)))THEN
        l_prompt := 'DATE_RECEIVED';
        l_data1  := r_header_1.date_received;
        l_data2  := r_header_2.date_received;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.award_cancel_date <> r_header_2.award_cancel_date )
         OR( NOT((r_header_1.award_cancel_date is null)and(r_header_2.award_cancel_date is null))
             AND ((r_header_1.award_cancel_date is null)or(r_header_2.award_cancel_date is null)))THEN
        l_prompt := 'AWARD_CANCEL_DATE';
        l_data1  := r_header_1.award_cancel_date;
        l_data2  := r_header_2.award_cancel_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.date_negotiated <> r_header_2.date_negotiated )
	 OR( NOT((r_header_1.date_negotiated is null)and(r_header_2.date_negotiated is null))
             AND ((r_header_1.date_negotiated is null)or(r_header_2.date_negotiated is null)))THEN
        l_prompt := 'DATE_NEGOTIATED';
        l_data1  := r_header_1.date_negotiated;
        l_data2  := r_header_2.date_negotiated;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

/*
      IF (r_header_1.date_approved <> r_header_2.date_approved )
	 OR( NOT((r_header_1.date_approved is null)and(r_header_2.date_approved is null))
             AND ((r_header_1.date_approved is null)or(r_header_2.date_approved is null)))THEN
        l_prompt := 'DATE_APPROVED';
        l_data1  := r_header_1.date_approved;
        l_data2  := r_header_2.date_approved;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
*/
     IF (r_header_1.sic_code <> r_header_2.sic_code )
	 OR( NOT((r_header_1.sic_code is null)and(r_header_2.sic_code is null))
             AND ((r_header_1.sic_code is null)or(r_header_2.sic_code is null)))THEN
        l_prompt := 'SIC_CODE';
        l_data1  := r_header_1.sic_code;
        l_data2  := r_header_2.sic_code;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.date_sign_by_customer <> r_header_2.date_sign_by_customer )
	 OR( NOT((r_header_1.date_sign_by_customer is null)and(r_header_2.date_sign_by_customer is null))
             AND ((r_header_1.date_sign_by_customer is null)or(r_header_2.date_sign_by_customer is null)))THEN
        l_prompt := 'DATE_SIGN_BY_CUSTOMER';
        l_data1  := r_header_1.date_sign_by_customer;
        l_data2  := r_header_2.date_sign_by_customer;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;


     IF (r_header_1.date_sign_by_contractor <> r_header_2.date_sign_by_contractor )
	 OR( NOT((r_header_1.date_sign_by_contractor is null)and(r_header_2.date_sign_by_contractor is null))
             AND ((r_header_1.date_sign_by_customer is null)or(r_header_2.date_sign_by_contractor is null)))THEN
        l_prompt := 'DATE_SIGN_BY_CONTRACTOR';
        l_data1  := r_header_1.date_sign_by_contractor;
        l_data2  := r_header_2.date_sign_by_contractor;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;


      IF (r_header_1.faa_approve_date <> r_header_2.faa_approve_date )
	 OR( NOT((r_header_1.faa_approve_date is null)and(r_header_2.faa_approve_date is null))
             AND ((r_header_1.faa_approve_date is null)or(r_header_2.faa_approve_date is null)))THEN
        l_prompt := 'FAA_APPROVE_DATE';
        l_data1  := r_header_1.faa_approve_date;
        l_data2  := r_header_2.faa_approve_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.customer_po_number <> r_header_2.customer_po_number )
	 OR( NOT((r_header_1.customer_po_number is null)and(r_header_2.customer_po_number is null))
             AND ((r_header_1.customer_po_number is null)or(r_header_2.customer_po_number is null)))THEN
        l_prompt := 'CUSTOMER_PO_NUMBER';
        l_data1  := r_header_1.customer_po_number;
        l_data2  := r_header_2.customer_po_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.no_competition_authorize <> r_header_2.no_competition_authorize )
	 OR( NOT((r_header_1.no_competition_authorize is null)and(r_header_2.no_competition_authorize is null))
             AND ((r_header_1.no_competition_authorize is null)or(r_header_2.no_competition_authorize is null)))THEN
        l_prompt := 'NO_COMPETITION_AUTHORIZE';
        l_data1  := r_header_1.no_competition_authorize;
        l_data2  := r_header_2.no_competition_authorize;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF  ((r_header_1.export_flag = 'Y') AND (NVL(r_header_2.export_flag,' ')<>'Y'))
       OR((r_header_2.export_flag = 'Y') AND (NVL(r_header_1.export_flag,' ')<>'Y'))THEN
        l_prompt := 'EXPORT_YN';
        l_data1  := r_header_1.export_flag;
        l_data2  := r_header_2.export_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF ((r_header_1.classified_flag = 'Y') AND (NVL(r_header_2.classified_flag, ' ')<>'Y' ))
       OR((r_header_2.classified_flag = 'Y') AND (NVL(r_header_1.classified_flag, ' ')<>'Y' ))THEN
        l_prompt := 'CLASSIFIED_YN';
        l_data1  := r_header_1.classified_flag;
        l_data2  := r_header_2.classified_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.PENALTY_CLAUSE_FLAG = 'Y') AND (NVL(r_header_2.PENALTY_CLAUSE_FLAG, ' ')<>'Y' ))
       OR((r_header_2.PENALTY_CLAUSE_FLAG = 'Y') AND (NVL(r_header_1.PENALTY_CLAUSE_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'PENALTY_CLAUSE_YN';
        l_data1  := r_header_1.penalty_clause_flag;
        l_data2  := r_header_2.penalty_clause_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.REPORTING_FLAG = 'Y') AND (NVL(r_header_2.REPORTING_FLAG, ' ')<>'Y' ))
       OR((r_header_2.REPORTING_FLAG = 'Y') AND (NVL(r_header_1.REPORTING_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'REPORTING_YN';
        l_data1  := r_header_1.reporting_flag;
        l_data2  := r_header_2.reporting_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.SB_PLAN_REQ_FLAG = 'Y') AND (NVL(r_header_2.SB_PLAN_REQ_FLAG, ' ')<>'Y' ))
       OR((r_header_2.SB_PLAN_REQ_FLAG = 'Y') AND (NVL(r_header_1.SB_PLAN_REQ_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'SB_PLAN_REQ_YN';
        l_data1  := r_header_1.sb_plan_req_flag;
        l_data2  := r_header_2.sb_plan_req_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF ((r_header_1.SB_REPORT_FLAG = 'Y') AND (NVL(r_header_2.SB_REPORT_FLAG, ' ')<>'Y' ))
       OR((r_header_2.SB_REPORT_FLAG = 'Y') AND (NVL(r_header_1.SB_REPORT_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'SB_REPORT_YN';
        l_data1  := r_header_1.sb_report_flag;
        l_data2  := r_header_2.sb_report_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.CQA_FLAG = 'Y') AND (NVL(r_header_2.CQA_FLAG, ' ')<>'Y' ))
      OR((r_header_2.CQA_FLAG = 'Y') AND (NVL(r_header_1.CQA_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'CQA_YN';
        l_data1  := r_header_1.cqa_flag;
        l_data2  := r_header_2.cqa_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.CFE_FLAG = 'Y') AND (NVL(r_header_2.CFE_FLAG, ' ')<>'Y' ))
      OR((r_header_2.CFE_FLAG = 'Y') AND (NVL(r_header_1.CFE_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'CFE_YN';
        l_data1  := r_header_1.cfe_flag;
        l_data2  := r_header_2.cfe_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.prop_delivery_location <> r_header_2.prop_delivery_location )
	 OR( NOT((r_header_1.prop_delivery_location is null)and(r_header_2.prop_delivery_location is null))
             AND ((r_header_1.prop_delivery_location is null)or(r_header_2.prop_delivery_location is null)))THEN
        l_prompt := 'PROP_DELIVERY_LOCATION';
        l_data1  := r_header_1.prop_delivery_location;
        l_data2  := r_header_2.prop_delivery_location;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.prop_due_date_time <> r_header_2.prop_due_date_time )
	 OR( NOT((r_header_1.prop_due_date_time is null)and(r_header_2.prop_due_date_time is null))
             AND ((r_header_1.prop_due_date_time is null)or(r_header_2.prop_due_date_time is null)))THEN
        l_prompt := 'PROP_DUE_DATE_TIME';
        l_data1  := r_header_1.prop_due_date_time;
        l_data2  := r_header_2.prop_due_date_time;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.prop_expire_date <> r_header_2.prop_expire_date )
	 OR( NOT((r_header_1.prop_expire_date is null)and(r_header_2.prop_expire_date is null))
             AND ((r_header_1.prop_expire_date is null)or(r_header_2.prop_expire_date is null)))THEN
        l_prompt := 'PROP_EXPIRE_DATE';
        l_data1  := r_header_1.prop_expire_date;
        l_data2  := r_header_2.prop_expire_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.copies_required <> r_header_2.copies_required )
	 OR( NOT((r_header_1.copies_required is null)and(r_header_2.copies_required is null))
             AND ((r_header_1.copies_required is null)or(r_header_2.copies_required is null)))THEN
        l_prompt := 'COPIES_REQUIRED';
        l_data1  := r_header_1.copies_required;
        l_data2  := r_header_2.copies_required;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
/*
     IF (r_header_1.billing_methods <> r_header_2.billing_methods )
	 OR( NOT((r_header_1. is null)and(r_header_2. is null))
             AND ((r_header_1. is null)or(r_header_2. is null)))THEN
        l_prompt := 'Billing Methods';
        l_data1  := r_header_1.billing_methods;
        l_data2  := r_header_2.billing_methods;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF r_header_1.billing_methods_button <> r_header_2.billing_methods_button
	 OR( NOT((r_header_1.billing_methods_button is null)and(r_header_2.billing_methods_button is null))
             AND ((r_header_1.billing_methods_button is null)or(r_header_2.billing_methods_button is null)))THEN
        l_prompt := 'Billing methods button';
        l_data1  := r_header_1.billing_methods_button;
        l_data2  := r_header_2.billing_methods_button;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;
*/
     IF (r_header_1.country_of_origin_code <> r_header_2.country_of_origin_code )
	 OR( NOT((r_header_1.country_of_origin_code is null)and(r_header_2.country_of_origin_code is null))
             AND ((r_header_1.country_of_origin_code is null)or(r_header_2.country_of_origin_code is null)))THEN
        l_prompt := 'COUNTRY_OF_ORIGIN_CODE';
        l_data1  := r_header_1.country_of_origin_code;
        l_data2  := r_header_2.country_of_origin_code;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.vat_code <> r_header_2.vat_code )
	 OR( NOT((r_header_1.vat_code is null)and(r_header_2.vat_code is null))
             AND ((r_header_1.vat_code is null)or(r_header_2.vat_code is null)))THEN
        l_prompt := 'VAT_CODE';
        l_data1  := r_header_1.vat_code;
        l_data2  := r_header_2.Vat_code;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.cost_of_sale_rate <> r_header_2.cost_of_sale_rate )
	 OR( NOT((r_header_1.cost_of_sale_rate is null)and(r_header_2.cost_of_sale_rate is null))
             AND ((r_header_1.cost_of_sale_rate is null)or(r_header_2.cost_of_sale_rate is null)))THEN
        l_prompt := 'COST_OF_SALE_RATE';
        l_data1  := r_header_1.cost_of_sale_rate;
        l_data2  := r_header_2.cost_of_sale_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.nte_amount <> r_header_2.nte_amount)
	OR( NOT((r_header_1.nte_amount is null)and(r_header_2.nte_amount is null))
            AND ((r_header_1.nte_amount is null)or(r_header_2.nte_amount is null)))THEN
        l_prompt := 'NTE_AMOUNT';
        l_data1  := r_header_1.nte_amount;
        l_data2  := r_header_2.nte_amount;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.date_definitized <> r_header_2.date_definitized )
	 OR( NOT((r_header_1.date_definitized is null)and(r_header_2.date_definitized is null))
             AND ((r_header_1.date_definitized is null)or(r_header_2.date_definitized is null)))THEN
        l_prompt := 'DATE_DEFINITIZED';
        l_data1  := r_header_1.date_definitized;
        l_data2  := r_header_2.date_definitized;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF (r_header_1.tech_data_wh_rate <> r_header_2.tech_data_wh_rate )
	 OR( NOT((r_header_1.tech_data_wh_rate is null)and(r_header_2.tech_data_wh_rate is null))
             AND ((r_header_1.tech_data_wh_rate is null)or(r_header_2.tech_data_wh_rate is null)))THEN
        l_prompt := 'TECH_DATA_WH_RATE';
        l_data1  := r_header_1.tech_data_wh_rate;
        l_data2  := r_header_2.tech_data_wh_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.FINANCIAL_CTRL_VERIFIED_FLAG = 'Y') AND (NVL(r_header_2.FINANCIAL_CTRL_VERIFIED_FLAG, ' ')<>'Y' ))
      OR((r_header_2.FINANCIAL_CTRL_VERIFIED_FLAG = 'Y') AND (NVL(r_header_1.FINANCIAL_CTRL_VERIFIED_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'FINANCIAL_CTRL_VERIFIED_YN';
        l_data1  := r_header_1.financial_ctrl_verified_flag;
        l_data2  := r_header_2.financial_ctrl_verified_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.NTE_WARNING_FLAG= 'Y') AND (NVL(r_header_2.NTE_WARNING_FLAG, ' ')<>'Y' ))
      OR((r_header_2.NTE_WARNING_FLAG= 'Y') AND (NVL(r_header_1.NTE_WARNING_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'NTE_WARNING_YN';
        l_data1  := r_header_1.nte_warning_flag;
        l_data2  := r_header_2.nte_warning_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.CAS_FLAG= 'Y') AND (NVL(r_header_2.CAS_FLAG, ' ')<>'Y' ))
      OR((r_header_2.CAS_FLAG= 'Y') AND (NVL(r_header_1.CAS_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'CAS_YN';
        l_data1  := r_header_1.cas_flag;
        l_data2  := r_header_2.cas_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.DCAA_AUDIT_REQ_FLAG= 'Y') AND (NVL(r_header_2.DCAA_AUDIT_REQ_FLAG, ' ')<>'Y' ))
      OR((r_header_2.DCAA_AUDIT_REQ_FLAG= 'Y') AND (NVL(r_header_1.DCAA_AUDIT_REQ_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'DCAA_AUDIT_REQ_YN';
        l_data1  := r_header_1.dcaa_audit_req_flag;
        l_data2  := r_header_2.dcaa_audit_req_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.INTERIM_RPT_REQ_FLAG= 'Y') AND (NVL(r_header_2.INTERIM_RPT_REQ_FLAG, ' ')<>'Y' ))
      OR((r_header_2.INTERIM_RPT_REQ_FLAG= 'Y') AND (NVL(r_header_1.INTERIM_RPT_REQ_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'INTERIM_RPT_REQ_YN';
        l_data1  := r_header_1.interim_rpt_req_flag;
        l_data2  := r_header_2.interim_rpt_req_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.cost_of_money <> r_header_2.cost_of_money )
	 OR( NOT((r_header_1.cost_of_money is null)and(r_header_2.cost_of_money is null))
             AND ((r_header_1.cost_of_money is null)or(r_header_2.cost_of_money is null)))THEN
        l_prompt := 'COST_OF_MONEY';
        l_data1  := r_header_1.cost_of_money;
        l_data2  := r_header_2.cost_of_money;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.OH_RATES_FINAL_FLAG= 'Y') AND (NVL(r_header_2.OH_RATES_FINAL_FLAG, ' ')<>'Y' ))
      OR((r_header_2.OH_RATES_FINAL_FLAG= 'Y') AND (NVL(r_header_1.OH_RATES_FINAL_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'OH_RATES_FINAL_YN';
        l_data1  := r_header_1.oh_rates_final_flag;
        l_data2  := r_header_2.oh_rates_final_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.PROGRESS_PAYMENT_FLAG= 'Y') AND (NVL(r_header_2.PROGRESS_PAYMENT_FLAG, ' ')<>'Y' ))
      OR((r_header_2.PROGRESS_PAYMENT_FLAG= 'Y') AND (NVL(r_header_1.PROGRESS_PAYMENT_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'PROGRESS_PAYMENT_YN';
        l_data1  := r_header_1.progress_payment_flag;
        l_data2  := r_header_2.progress_payment_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.progress_payment_rate <> r_header_2.progress_payment_rate)
	 OR( NOT((r_header_1.progress_payment_rate is null)and(r_header_2.progress_payment_rate is null))
             AND ((r_header_1.progress_payment_rate is null)or(r_header_2.progress_payment_rate is null)))THEN
        l_prompt := 'PROGRESS_PAYMENT_RATE';
        l_data1  := r_header_1.progress_payment_rate;
        l_data2  := r_header_2.progress_payment_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.progress_payment_liq_rate <> r_header_2.progress_payment_liq_rate )
	 OR( NOT((r_header_1.progress_payment_liq_rate is null)and(r_header_2.progress_payment_liq_rate is null))
             AND ((r_header_1.progress_payment_liq_rate is null)or(r_header_2.progress_payment_liq_rate is null)))THEN
        l_prompt := 'PROGRESS_PAYMENT_LIQ_RATE';
        l_data1  := r_header_1.progress_payment_liq_rate;
        l_data2  := r_header_2.progress_payment_liq_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

      IF (r_header_1.alternate_liquidation_rate <> r_header_2.alternate_liquidation_rate )
	 OR( NOT((r_header_1.alternate_liquidation_rate is null)and(r_header_2.alternate_liquidation_rate is null))
             AND ((r_header_1.alternate_liquidation_rate is null)or(r_header_2.alternate_liquidation_rate is null)))THEN
        l_prompt := 'ALTERNATE_LIQUIDATION_RATE';
        l_data1  := r_header_1.alternate_liquidation_rate;
        l_data2  := r_header_2.alternate_liquidation_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.COST_SHARE_FLAG= 'Y') AND (NVL(r_header_2.COST_SHARE_FLAG, ' ')<>'Y' ))
      OR((r_header_2.COST_SHARE_FLAG= 'Y') AND (NVL(r_header_1.COST_SHARE_FLAG, ' ')<>'Y' )) THEN
        l_prompt := 'COST_SHARE_YN';
        l_data1  := r_header_1.cost_share_flag;
        l_data2  := r_header_2.cost_share_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.DEFINITIZED_FLAG= 'Y') AND (NVL(r_header_2.DEFINITIZED_FLAG, ' ')<>'Y' ))
      OR((r_header_2.DEFINITIZED_FLAG= 'Y') AND (NVL(r_header_1.DEFINITIZED_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'DEFINITIZED_YN';
        l_data1  := r_header_1.definitized_flag;
        l_data2  := r_header_2.definitized_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF ((r_header_1.BILL_WITHOUT_DEF_FLAG= 'Y') AND (NVL(r_header_2.BILL_WITHOUT_DEF_FLAG, ' ')<>'Y' ))
      OR((r_header_2.BILL_WITHOUT_DEF_FLAG= 'Y') AND (NVL(r_header_1.BILL_WITHOUT_DEF_FLAG, ' ')<>'Y' ))THEN
        l_prompt := 'BILL_WITHOUT_DEF_YN';
        l_data1  := r_header_1.bill_without_def_flag;
        l_data2  := r_header_2.bill_without_def_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     IF (r_header_1.comments <> r_header_2.comments )
	 OR( NOT((r_header_1.comments is null)and(r_header_2.comments is null))
             AND ((r_header_1.comments is null)or(r_header_2.comments is null)))THEN
        l_prompt := 'COMMENTS';
        l_data1  := r_header_1.comments;
        l_data2  := r_header_2.comments;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
     END IF;

     EXCEPTION
	WHEN NO_DATA_FOUND THEN
	NULL;
        WHEN OTHERS THEN
	NULL;

   END comp_headers;

   /* This procedure compare all the contract lines by an In-order sequence */

   PROCEDURE comp_lines(vHeader_id IN NUMBER, vVersion1 IN NUMBER, vVERSION2 IN NUMBER)
   AS
      TYPE r_line IS RECORD(
           major_version         OKE_K_LINES_SECURE_HV.major_version%TYPE,
           line_number           OKE_K_LINES_SECURE_HV.line_number%TYPE,
           status                OKE_K_LINES_SECURE_HV.status%TYPE,
           line_style            OKE_K_LINES_SECURE_HV.line_style%TYPE,
           project_number        OKE_K_LINES_SECURE_HV.project_number%TYPE,
           task_number           OKE_K_LINES_SECURE_HV.task_number%TYPE,
           start_date            OKE_K_LINES_SECURE_HV.start_date%TYPE,
           end_date              OKE_K_LINES_SECURE_HV.end_date%TYPE,
           delivery_date         OKE_K_LINES_SECURE_HV.delivery_date%TYPE,
           proposal_due_date     OKE_K_LINES_SECURE_HV.proposal_due_date%TYPE,
           item_number           OKE_K_LINES_SECURE_HV.item_number%TYPE,
           --item_description      OKE_K_LINES_SECURE_HV.item_description%TYPE,
           line_description      OKE_K_LINES_SECURE_HV.line_description%TYPE,
           customer_item_number  OKE_K_LINES_SECURE_HV.customer_item_number%TYPE,
           nsn_number            OKE_K_LINES_SECURE_HV.nsn_number%TYPE,
           nsp_flag              OKE_K_LINES_SECURE_HV.nsp_flag%TYPE,
           line_quantity         OKE_K_LINES_SECURE_HV.line_quantity%TYPE,
           uom_code              OKE_K_LINES_SECURE_HV.uom_code%TYPE,
           unit_price            OKE_K_LINES_SECURE_HV.unit_price%TYPE,
           undef_unit_price      OKE_K_LINES_SECURE_HV.undef_unit_price%TYPE,
           line_value            OKE_K_LINES_SECURE_HV.line_value%TYPE,
           undef_line_value      OKE_K_LINES_SECURE_HV.undef_line_value%TYPE,
           line_value_total      OKE_K_LINES_SECURE_HV.line_value_total%TYPE,
           undef_line_value_total    OKE_K_LINES_SECURE_HV.undef_line_value_total%TYPE,
           --line_value_copy       OKE_K_LINES_SECURE_HV.line_value_copy%TYPE,
           billable_flag         OKE_K_LINES_SECURE_HV.billable_flag%TYPE,
           shippable_flag        OKE_K_LINES_SECURE_HV.shippable_flag%TYPE,
           subcontracted_flag    OKE_K_LINES_SECURE_HV.subcontracted_flag%TYPE,
           drop_shipped_flag     OKE_K_LINES_SECURE_HV.drop_shipped_flag%TYPE,
           completed_flag        OKE_K_LINES_SECURE_HV.completed_flag%TYPE,
           comments              OKE_K_LINES_SECURE_HV.comments%TYPE,
           target_date_definitize    OKE_K_LINES_SECURE_HV.target_date_definitize%TYPE,
           discount_for_payment  OKE_K_LINES_SECURE_HV.discount_for_payment%TYPE,
           cost_of_sale_rate     OKE_K_LINES_SECURE_HV.cost_of_sale_rate%TYPE,
           financial_ctrl_flag   OKE_K_LINES_SECURE_HV.financial_ctrl_flag%TYPE,
           definitized_flag      OKE_K_LINES_SECURE_HV.definitized_flag%TYPE,
           bill_undefinitized_flag   OKE_K_LINES_SECURE_HV.bill_undefinitized_flag%TYPE,
           dcaa_audit_req_flag   OKE_K_LINES_SECURE_HV.dcaa_audit_req_flag%TYPE,
           cost_of_money         OKE_K_LINES_SECURE_HV.cost_of_money%TYPE,
           interim_rpt_req_flag  OKE_K_LINES_SECURE_HV.interim_rpt_req_flag%TYPE,
           nte_warning_flag      OKE_K_LINES_SECURE_HV.nte_warning_flag%TYPE,
           c_ssr_flag            OKE_K_LINES_SECURE_HV.c_ssr_flag%TYPE,
           c_scs_flag            OKE_K_LINES_SECURE_HV.c_scs_flag%TYPE,
           prepayment_amount     OKE_K_LINES_SECURE_HV.prepayment_amount%TYPE,
           prepayment_percentage OKE_K_LINES_SECURE_HV.prepayment_percentage%TYPE,
           progress_payment_flag OKE_K_LINES_SECURE_HV.progress_payment_flag%TYPE,
           progress_payment_rate OKE_K_LINES_SECURE_HV.progress_payment_rate%TYPE,
           progress_payment_liq_rate        OKE_K_LINES_SECURE_HV.progress_payment_liq_rate%TYPE,
           line_liquidation_rate OKE_K_LINES_SECURE_HV.line_liquidation_rate%TYPE,
           boe_description       OKE_K_LINES_SECURE_HV.boe_description%TYPE,
           billing_method        OKE_K_LINES_SECURE_HV.billing_method%TYPE,
           total_estimated_cost  OKE_K_LINES_SECURE_HV.total_estimated_cost%TYPE,
           customer_percent_in_order      OKE_K_LINES_SECURE_HV.customer_percent_in_order%TYPE,
           ceiling_cost          OKE_K_LINES_SECURE_HV.ceiling_cost%TYPE,
           level_of_effort_hours OKE_K_LINES_SECURE_HV.level_of_effort_hours%TYPE,
           award_fee             OKE_K_LINES_SECURE_HV.award_fee%TYPE,
           base_fee              OKE_K_LINES_SECURE_HV.base_fee%TYPE,
           minimum_fee           OKE_K_LINES_SECURE_HV.minimum_fee%TYPE,
           maximum_fee           OKE_K_LINES_SECURE_HV.maximum_fee%TYPE,
           award_fee_pool_amount OKE_K_LINES_SECURE_HV.award_fee_pool_amount%TYPE,
           fixed_fee             OKE_K_LINES_SECURE_HV.fixed_fee%TYPE,
           initial_fee           OKE_K_LINES_SECURE_HV.initial_fee%TYPE,
           final_fee             OKE_K_LINES_SECURE_HV.final_fee%TYPE,
           fee_ajt_formula       OKE_K_LINES_SECURE_HV.fee_ajt_formula%TYPE,
           target_cost           OKE_K_LINES_SECURE_HV.target_cost%TYPE,
           target_fee            OKE_K_LINES_SECURE_HV.target_fee%TYPE,
           target_price          OKE_K_LINES_SECURE_HV.target_price%TYPE,
           ceiling_price         OKE_K_LINES_SECURE_HV.ceiling_price%TYPE,
           cost_overrun_share_ratio    OKE_K_LINES_SECURE_HV.cost_overrun_share_ratio%TYPE,
           cost_underrun_share_ratio   OKE_K_LINES_SECURE_HV.cost_underrun_share_ratio%TYPE,
           final_pft_ajt_formula       OKE_K_LINES_SECURE_HV.final_pft_ajt_formula%TYPE,
           fixed_quantity              OKE_K_LINES_SECURE_HV.fixed_quantity%TYPE,
           minimum_quantity            OKE_K_LINES_SECURE_HV.minimum_quantity%TYPE,
           maximum_quantity            OKE_K_LINES_SECURE_HV.maximum_quantity%TYPE,
           estimated_total_quantity    OKE_K_LINES_SECURE_HV.estimated_total_quantity%TYPE,
           number_of_options           OKE_K_LINES_SECURE_HV.number_of_options%TYPE,
           initial_price               OKE_K_LINES_SECURE_HV.initial_price%TYPE,
           revised_price               OKE_K_LINES_SECURE_HV.revised_price%TYPE,
           material_cost_index         OKE_K_LINES_SECURE_HV.material_cost_index%TYPE,
           labor_cost_index            OKE_K_LINES_SECURE_HV.labor_cost_index%TYPE,
           date_of_price_redetermin    OKE_K_LINES_SECURE_HV.date_of_price_redetermin%TYPE,
           country_of_origin_code       OKE_K_LINES_SECURE_HV.country_of_origin_code%TYPE,
           export_flag                 OKE_K_LINES_SECURE_HV.export_flag%TYPE,
           export_license_num          OKE_K_LINES_SECURE_HV.export_license_num%TYPE,
           export_license_res          OKE_K_LINES_SECURE_HV.export_license_res%TYPE,
           cop_required_flag           OKE_K_LINES_SECURE_HV.cop_required_flag%TYPE,
           inspection_req_flag         OKE_K_LINES_SECURE_HV.inspection_req_flag%TYPE,
           subj_a133_flag              OKE_K_LINES_SECURE_HV.subj_a133_flag%TYPE,
           cfe_flag                    OKE_K_LINES_SECURE_HV.cfe_flag%TYPE,
           customer_approval_req_flag  OKE_K_LINES_SECURE_HV.customer_approval_req_flag%TYPE,
           data_item_name              OKE_K_LINES_SECURE_HV.data_item_name%TYPE,
           data_item_subtitle          OKE_K_LINES_SECURE_HV.data_item_subtitle%TYPE,
           cdrl_category               OKE_K_LINES_SECURE_HV.cdrl_category%TYPE,
           requiring_office            OKE_K_LINES_SECURE_HV.requiring_office%TYPE,
           date_of_first_submission     OKE_K_LINES_SECURE_HV.date_of_first_submission%TYPE,
           frequency                   OKE_K_LINES_SECURE_HV.frequency%TYPE,
           copies_required             OKE_K_LINES_SECURE_HV.copies_required%TYPE
           );



     l_api_name     CONSTANT VARCHAR2(30) := 'comp_lines';

       r_line_1 r_line;
       r_line_2 r_line;

       nDeliverables   NUMBER;

       TYPE c_top_nodes  IS REF CURSOR;

       v_top_nodes c_top_nodes;
       c_top_node OKE_K_LINES_SECURE_HV.K_LINE_ID%TYPE;

       nCurrent_line_id number;
       nSublines number;

       CURSOR c_nDifferent_lines_1 IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_BH a
         WHERE DNZ_CHR_ID=vHeader_id
         AND MAJOR_VERSION=vVersion1
         AND CLE_ID IS NULL
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_BH b
         WHERE b.ID=a.ID
         AND CLE_ID IS NULL
         AND MAJOR_VERSION=vVersion2)
         ORDER BY LINE_NUMBER;

        CURSOR c_nDifferent_lines_1_latest IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_B a
         WHERE DNZ_CHR_ID=vHeader_id
         AND CLE_ID IS NULL
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_BH b
         WHERE b.ID=a.ID
         AND CLE_ID IS NULL
         AND MAJOR_VERSION=vVersion2)
         ORDER BY LINE_NUMBER;

       CURSOR c_nDifferent_lines_2 IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_BH a
         WHERE DNZ_CHR_ID=vHeader_id
         AND MAJOR_VERSION=vVersion2
         AND CLE_ID IS NULL
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_BH b
         WHERE b.ID=a.ID
         AND CLE_ID IS NULL
         AND MAJOR_VERSION=vVersion1)
         ORDER BY LINE_NUMBER;

        CURSOR c_nDifferent_lines_2_latest IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_BH a
         WHERE DNZ_CHR_ID=vHeader_id
         AND MAJOR_VERSION=vVersion2
         AND CLE_ID IS NULL
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_B b
         WHERE b.ID=a.ID
         AND CLE_ID IS NULL)
         ORDER BY LINE_NUMBER;

       CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;

   BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Begin comparing lines ...');
   END IF;
     L_Attribute_Object_Name :='OKE_K_LINES';
     l_Object :='LINE';

     OPEN c;
     FETCH c INTO l_object_type;
     CLOSE c;

    --Get lines in version1 which are not in the version2

    IF L_Latest_Version >= vVersion1 THEN

      FOR c_nDifferent_line IN c_nDifferent_lines_1 LOOP
        l_object_name := get_full_path_linenum(c_nDifferent_line.k_line_id,vVersion1);
        l_prompt :='';

        l_Object :='NO_LINE';

        OPEN c;
        FETCH c INTO l_data2;
        CLOSE c;

        l_data1  :='';

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
      END LOOP;

      FOR c_nDifferent_line IN c_nDifferent_lines_2 LOOP
        l_object_name := get_full_path_linenum(c_nDifferent_line.k_line_id,vVersion2);
        l_prompt :='';

        l_Object :='NO_LINE';

        OPEN c;
        FETCH c INTO l_data1;
        CLOSE c;

        l_data2  :='';

        insert_comp_result(vHeader_id,vVersion1,vVersion2);

      END LOOP;

      OPEN v_top_nodes FOR
        SELECT a.ID K_LINE_ID
         FROM  OKC_K_LINES_BH A, OKC_K_LINES_BH B
         WHERE a.DNZ_CHR_ID=vHeader_id
           AND a.MAJOR_VERSION=vVersion1
           AND a.CLE_ID IS NULL
           AND a.ID = b.ID
           AND b.CLE_ID IS NULL
           AND b.MAJOR_VERSION=vVersion2
         ORDER BY a.LINE_NUMBER
      ;

    ELSE

       FOR c_nDifferent_line IN c_nDifferent_lines_1_latest LOOP
         l_object_name := get_full_path_linenum(c_nDifferent_line.k_line_id);
         l_prompt :='';

         l_Object :='NO_LINE';

         OPEN c;
         FETCH c INTO l_data2;
         CLOSE c;

         l_data1  :='';

         insert_comp_result(vHeader_id,vVersion1,vVersion2);
       END LOOP;

       FOR c_nDifferent_line IN c_nDifferent_lines_2_latest LOOP
         l_object_name :=get_full_path_linenum(c_nDifferent_line.k_line_id);
         l_prompt :='';

         l_Object :='NO_LINE';

         OPEN c;
         FETCH c INTO l_data1;
         CLOSE c;

         l_data2  :='';

         insert_comp_result(vHeader_id,vVersion1,vVersion2);

       END LOOP;

       OPEN v_top_nodes FOR
         SELECT a.ID K_LINE_ID
          FROM  OKC_K_LINES_B A, OKC_K_LINES_BH B
          WHERE a.DNZ_CHR_ID=vHeader_id
            AND a.CLE_ID IS NULL
            AND a.ID = b.ID
            AND b.CLE_ID IS NULL
            AND MAJOR_VERSION=vVersion2
          ORDER BY a.LINE_NUMBER
       ;

    END IF;

    LOOP

     IF L_Latest_Version < vVersion1 THEN

        FETCH  v_top_nodes INTO c_top_node;
        EXIT WHEN v_top_nodes%NOTFOUND;



        L_Attribute_Object_Name :='OKE_K_LINES';
        l_Object  :='LINE';

        OPEN c;
        FETCH c INTO l_object_type;
        CLOSE c;

        nCurrent_line_id := c_top_node;
        l_object_name :=get_full_path_linenum(nCurrent_line_id);

           SELECT
               major_version,
               line_number,
               status,
               line_style,
               project_number,
               task_number,
               start_date,
               end_date,
               delivery_date,
               proposal_due_date,
               item_number,
               --item_description,
               line_description,
               customer_item_number,
               nsn_number,
               nsp_flag,
               line_quantity,
               uom_code,
               unit_price,
               undef_unit_price,
               line_value,
               undef_line_value,
               line_value_total,
               undef_line_value_total,
               --line_value_copy,
               billable_flag,
               shippable_flag,
               subcontracted_flag,
               drop_shipped_flag,
               completed_flag,
               comments,
               target_date_definitize,
               discount_for_payment,
               cost_of_sale_rate,
               financial_ctrl_flag,
               definitized_flag,
               bill_undefinitized_flag,
               dcaa_audit_req_flag,
               cost_of_money,
               interim_rpt_req_flag,
               nte_warning_flag,
               c_ssr_flag,
               c_scs_flag,
               prepayment_amount,
               prepayment_percentage,
               progress_payment_flag,
               progress_payment_rate,
		progress_payment_liq_rate,
		line_liquidation_rate,
		boe_description,
		billing_method,
		total_estimated_cost,
		customer_percent_in_order,
		ceiling_cost,
		level_of_effort_hours,
		award_fee,
		base_fee,
		minimum_fee,
		maximum_fee,
		award_fee_pool_amount,
		fixed_fee,
		initial_fee,
		final_fee,
		fee_ajt_formula,
		target_cost,
		target_fee,
		target_price,
		ceiling_price,
		cost_overrun_share_ratio,
		cost_underrun_share_ratio,
		final_pft_ajt_formula,
		fixed_quantity,
		minimum_quantity,
		maximum_quantity,
		estimated_total_quantity,
		number_of_options,
		initial_price,
		revised_price,
		material_cost_index,
		labor_cost_index,
		date_of_price_redetermin,
		country_of_origin_code,
		export_flag,
		export_license_num,
		export_license_res,
		cop_required_flag,
		inspection_req_flag,
		subj_a133_flag,
		cfe_flag,
		customer_approval_req_flag,
		data_item_name,
		data_item_subtitle,
		cdrl_category,
		requiring_office,
		date_of_first_submission,
		frequency,
		copies_required

           INTO r_line_1
           FROM OKE_K_LINES_SECURE_V
           WHERE K_LINE_ID=c_top_node;

--dbms_output.put_line ('LASTEST VERSION top line number'||r_line_1.line_number);

     ELSE


	FETCH  v_top_nodes INTO c_top_node;
        EXIT WHEN v_top_nodes%NOTFOUND;
        nCurrent_line_id := c_top_node;

        L_Attribute_Object_Name :='OKE_K_LINES';
        l_Object  :='LINE';

	OPEN c;
        FETCH c INTO l_object_type;
        CLOSE c;

        l_object_name :=get_full_path_linenum(nCurrent_line_id,vVersion1);


           SELECT

		major_version,
		line_number,
		status,
		line_style,
		project_number,
		task_number,
		start_date,
		end_date,
		delivery_date,
		proposal_due_date,
		item_number,
		--item_description,
		line_description,
		customer_item_number,
		nsn_number,
		nsp_flag,
		line_quantity,
		uom_code,
		unit_price,
		undef_unit_price,
		line_value,
		undef_line_value,
		line_value_total,
		undef_line_value_total,
		--line_value_copy,
		billable_flag,
		shippable_flag,
		subcontracted_flag,
		drop_shipped_flag,
		completed_flag,
		comments,
		target_date_definitize,
		discount_for_payment,
		cost_of_sale_rate,
		financial_ctrl_flag,
		definitized_flag,
		bill_undefinitized_flag,
		dcaa_audit_req_flag,
		cost_of_money,
		interim_rpt_req_flag,
		nte_warning_flag,
		c_ssr_flag,
		c_scs_flag,
		prepayment_amount,
		prepayment_percentage,
		progress_payment_flag,
		progress_payment_rate,
		progress_payment_liq_rate,
		line_liquidation_rate,
		boe_description,
		billing_method,
		total_estimated_cost,
		customer_percent_in_order,
		ceiling_cost,
		level_of_effort_hours,
		award_fee,
		base_fee,
		minimum_fee,
		maximum_fee,
		award_fee_pool_amount,
		fixed_fee,
		initial_fee,
		final_fee,
		fee_ajt_formula,
		target_cost,
		target_fee,
		target_price,
		ceiling_price,
		cost_overrun_share_ratio,
		cost_underrun_share_ratio,
		final_pft_ajt_formula,
		fixed_quantity,
		minimum_quantity,
		maximum_quantity,
		estimated_total_quantity,
		number_of_options,
		initial_price,
		revised_price,
		material_cost_index,
		labor_cost_index,
		date_of_price_redetermin,
		country_of_origin_code,
		export_flag,
		export_license_num,
		export_license_res,
		cop_required_flag,
		inspection_req_flag,
		subj_a133_flag,
		cfe_flag,
		customer_approval_req_flag,
		data_item_name,
		data_item_subtitle,
		cdrl_category,
		requiring_office,
		date_of_first_submission,
		frequency,
		copies_required

        INTO r_line_1
        from oke_k_lineS_SECURE_hv
        where k_line_id=nCurrent_line_id
	and major_version=vVersion1;

--dbms_output.put_line ('HISTORY  top line number'||r_line_1.line_number);

     END IF;


        SELECT

		major_version,
		line_number,
		status,
		line_style,
		project_number,
		task_number,
		start_date,
		end_date,
		delivery_date,
		proposal_due_date,
		item_number,
		--item_description,
		line_description,
		customer_item_number,
		nsn_number,
		nsp_flag,
		line_quantity,
		uom_code,
		unit_price,
		undef_unit_price,
		line_value,
		undef_line_value,
		line_value_total,
		undef_line_value_total,
		--line_value_copy,
		billable_flag,
		shippable_flag,
		subcontracted_flag,
		drop_shipped_flag,
		completed_flag,
		comments,
		target_date_definitize,
		discount_for_payment,
		cost_of_sale_rate,
		financial_ctrl_flag,
		definitized_flag,
		bill_undefinitized_flag,
		dcaa_audit_req_flag,
		cost_of_money,
		interim_rpt_req_flag,
		nte_warning_flag,
		c_ssr_flag,
		c_scs_flag,
		prepayment_amount,
		prepayment_percentage,
		progress_payment_flag,
		progress_payment_rate,
		progress_payment_liq_rate,
		line_liquidation_rate,
		boe_description,
		billing_method,
		total_estimated_cost,
		customer_percent_in_order,
		ceiling_cost,
		level_of_effort_hours,
		award_fee,
		base_fee,
		minimum_fee,
		maximum_fee,
		award_fee_pool_amount,
		fixed_fee,
		initial_fee,
		final_fee,
		fee_ajt_formula,
		target_cost,
		target_fee,
		target_price,
		ceiling_price,
		cost_overrun_share_ratio,
		cost_underrun_share_ratio,
		final_pft_ajt_formula,
		fixed_quantity,
		minimum_quantity,
		maximum_quantity,
		estimated_total_quantity,
		number_of_options,
		initial_price,
		revised_price,
		material_cost_index,
		labor_cost_index,
		date_of_price_redetermin,
		country_of_origin_code,
		export_flag,
		export_license_num,
		export_license_res,
		cop_required_flag,
		inspection_req_flag,
		subj_a133_flag,
		cfe_flag,
		customer_approval_req_flag,
		data_item_name,
		data_item_subtitle,
		cdrl_category,
		requiring_office,
		date_of_first_submission,
		frequency,
		copies_required

        INTO r_line_2
        FROM OKE_K_LINES_SECURE_HV
        WHERE K_LINE_ID=nCurrent_line_id
        AND MAJOR_VERSION= vVersion2;

/*
        IF r_line_1.MAJOR_VERSION <>r_line_2.MAJOR_VERSION THEN
           l_prompt :='OBJECT_VERSION_NUMBER';
           l_data1  :=r_line_1.MAJOR_VERSION;
           l_data2  :=r_line_2.MAJOR_VERSION;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
*/

       IF (r_line_1.line_number <> r_line_2.line_number )
            OR( NOT((r_line_1.line_number is null)and(r_line_2.line_number is null))
             AND ((r_line_1.line_number is null)or(r_line_2.line_number is null)))THEN
           l_prompt :='LINE_NUMBER';
           l_data1  :=r_line_1.line_number;
           l_data2  :=r_line_2.line_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.status  <>r_line_2.status )
	    OR( NOT((r_line_1.status is null)and(r_line_2.status is null))
             AND ((r_line_1.status is null)or(r_line_2.status is null)))THEN
           l_prompt :='STATUS';
           l_data1  :=r_line_1.status;
           l_data2  :=r_line_2.status;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.line_style <>r_line_2.line_style )
	     OR( NOT((r_line_1.line_style is null)and(r_line_2.line_style is null))
             AND ((r_line_1.line_style is null)or(r_line_2.line_style is null)))THEN
           l_prompt :='LINE_STYLE';
           l_data1  :=r_line_1.line_style;
           l_data2  :=r_line_2.line_style;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.project_number <>r_line_2.project_number )
             OR( NOT((r_line_1.project_number is null)and(r_line_2.project_number is null))
             AND ((r_line_1.project_number is null)or(r_line_2.project_number is null)))THEN
           l_prompt :='PROJECT_NUMBER';
           l_data1  :=r_line_1.project_number;
           l_data2  :=r_line_2.project_number;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.task_number <>r_line_2.task_number )
	     OR( NOT((r_line_1.task_number is null)and(r_line_2.task_number is null))
             AND ((r_line_1.task_number is null)or(r_line_2.task_number is null)))THEN
           l_prompt :='TASK_NUMBER';
           l_data1  :=r_line_1.task_number;
           l_data2  :=r_line_2.task_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.start_date <>r_line_2.start_date )
	     OR( NOT((r_line_1.start_date is null)and(r_line_2.start_date is null))
             AND ((r_line_1.start_date is null)or(r_line_2.start_date is null)))THEN
           l_prompt :='START_DATE';
           l_data1  :=r_line_1.start_date;
           l_data2  :=r_line_2.start_date;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.end_date <>r_line_2.end_date )
		 OR( NOT((r_line_1.end_date is null)and(r_line_2.end_date is null))
             AND ((r_line_1.end_date is null)or(r_line_2.end_date is null)))THEN
           l_prompt :='END_DATE';
           l_data1  :=r_line_1.end_date;
           l_data2  :=r_line_2.end_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.delivery_date <>r_line_2.delivery_date )
		 OR( NOT((r_line_1.delivery_date is null)and(r_line_2.delivery_date is null))
             AND ((r_line_1.delivery_date is null)or(r_line_2.delivery_date is null)))THEN
           l_prompt :='DELIVERY_DATE';
           l_data1  :=r_line_1.delivery_date;
           l_data2  :=r_line_2.delivery_date;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.proposal_due_date <>r_line_2.proposal_due_date )
		 OR( NOT((r_line_1.proposal_due_date is null)and(r_line_2.proposal_due_date is null))
             AND ((r_line_1.proposal_due_date is null)or(r_line_2.proposal_due_date is null)))THEN
           l_prompt :='PROPOSAL_DUE_DATE';
           l_data1  :=r_line_1.proposal_due_date;
           l_data2  :=r_line_2.proposal_due_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.item_number <>r_line_2.item_number )
		 OR( NOT((r_line_1.item_number is null)and(r_line_2.item_number is null))
             AND ((r_line_1.item_number is null)or(r_line_2.item_number is null)))THEN
           l_prompt :='ITEM_NUMBER';
           l_data1  :=r_line_1.item_number;
           l_data2  :=r_line_2.item_number;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
/*
        IF r_line_1.item_description <>r_line_2.item_description THEN
           l_prompt :='Item Description';
           l_data1  :=r_line_1.item_description;
           l_data2  :=r_line_2.item_description;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
*/
        IF (r_line_1.line_description <>r_line_2.line_description )
		 OR( NOT((r_line_1.line_description is null)and(r_line_2.line_description is null))
             AND ((r_line_1.line_description is null)or(r_line_2.line_description is null)))THEN
           l_prompt :='LINE_DESCRIPTION';
           l_data1  :=r_line_1.line_description;
           l_data2  :=r_line_2.line_description;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_line_1.customer_item_number <>r_line_2.customer_item_number )
		 OR( NOT((r_line_1.customer_item_number is null)and(r_line_2.customer_item_number is null))
             AND ((r_line_1.customer_item_number is null)or(r_line_2.customer_item_number is null)))THEN
           l_prompt :='CUSTOMER_ITEM_NUMBER';
           l_data1  :=r_line_1.customer_item_number;
           l_data2  :=r_line_2.customer_item_number;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.nsn_number <>r_line_2.nsn_number )
		 OR( NOT((r_line_1.nsn_number is null)and(r_line_2.nsn_number is null))
             AND ((r_line_1.nsn_number is null)or(r_line_2.nsn_number is null)))THEN
           l_prompt :='NSN_NUMBER';
           l_data1  :=r_line_1.nsn_number;
           l_data2  :=r_line_2.nsn_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.nsp_flag = 'Y') AND (NVL(r_line_2.nsp_flag, ' ')<>'Y'))
	 OR((r_line_2.nsp_flag = 'Y') AND (NVL(r_line_1.nsp_flag, ' ')<>'Y')) THEN
           l_prompt :='NSP_YN';
           l_data1  :=r_line_1.nsp_flag;
           l_data2  :=r_line_2.nsp_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF r_line_1.line_quantity <>r_line_2.line_quantity THEN
           l_prompt :='LINE_QUANTITY';
           l_data1  :=r_line_1.line_quantity;
           l_data2  :=r_line_2.line_quantity;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.uom_code <>r_line_2.uom_code )
		 OR( NOT((r_line_1.uom_code is null)and(r_line_2.uom_code is null))
             AND ((r_line_1.uom_code is null)or(r_line_2.uom_code is null)))THEN
           l_prompt :='UOM_CODE';
           l_data1  :=r_line_1.uom_code;
           l_data2  :=r_line_2.uom_code;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.unit_price <>r_line_2.unit_price)
		 OR( NOT((r_line_1.unit_price is null)and(r_line_2.unit_price is null))
             AND ((r_line_1.unit_price is null)or(r_line_2.unit_price is null)))THEN
          l_prompt :='UNIT_PRICE';
          SET_PRICE_DIFF_DATA( r_line_1.unit_price, r_line_2.unit_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.undef_unit_price <>r_line_2.undef_unit_price )
		 OR( NOT((r_line_1.undef_unit_price is null)and(r_line_2.undef_unit_price is null))
             AND ((r_line_1.undef_unit_price is null)or(r_line_2.undef_unit_price is null)))THEN
          l_prompt :='UNDEF_UNIT_PRICE';
          SET_PRICE_DIFF_DATA( r_line_1.undef_unit_price, r_line_2.undef_unit_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.line_value_total <>r_line_2.line_value_total )
		 OR( NOT((r_line_1.line_value_total is null)and(r_line_2.line_value_total is null))
             AND ((r_line_1.line_value_total is null)or(r_line_2.line_value_total is null)))THEN
          l_prompt :='LINE_VALUE_TOTAL';
          SET_AMOUNT_DIFF_DATA( r_line_1.line_value_total, r_line_2.line_value_total );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.undef_line_value_total <>r_line_2.undef_line_value_total )
		 OR( NOT((r_line_1.undef_line_value_total is null)and(r_line_2.undef_line_value_total is null))
             AND ((r_line_1.undef_line_value_total is null)or(r_line_2.undef_line_value_total is null)))THEN
          l_prompt :='UNDEF_LINE_VALUE_TOTAL';
          SET_AMOUNT_DIFF_DATA( r_line_1.undef_line_value_total, r_line_2.undef_line_value_total );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
/*
        IF r_line_1.line_value_copy <>r_line_2.line_value_copy THEN
           l_prompt :='Line value copy';
           l_data1  :=r_line_1.line_value_copy;
           l_data2  :=r_line_2.line_value_copy;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
*/
        IF ((r_line_1.BILLABLE_FLAG = 'Y') AND (NVL(r_line_2.BILLABLE_FLAG, ' ')<>'Y'))
	 OR((r_line_2.BILLABLE_FLAG = 'Y') AND (NVL(r_line_1.BILLABLE_FLAG, ' ')<>'Y'))THEN
           l_prompt :='BILLABLE_YN';
           l_data1  :=r_line_1.billable_flag;
           l_data2  :=r_line_2.billable_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.SHIPPABLE_FLAG = 'Y') AND (NVL(r_line_2.SHIPPABLE_FLAG, ' ')<>'Y'))
	 OR((r_line_2.SHIPPABLE_FLAG = 'Y') AND (NVL(r_line_1.SHIPPABLE_FLAG, ' ')<>'Y'))THEN
           l_prompt :='SHIPPABLE_YN';
           l_data1  :=r_line_1.SHIPPABLE_FLAG;
           l_data2  :=r_line_2.SHIPPABLE_FLAG;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.SUBCONTRACTED_FLAG = 'Y') AND (NVL(r_line_2.SUBCONTRACTED_FLAG, ' ')<>'Y'))
	 OR((r_line_2.SUBCONTRACTED_FLAG = 'Y') AND (NVL(r_line_1.SUBCONTRACTED_FLAG, ' ')<>'Y'))THEN
           l_prompt :='SUBCONTRACTED_YN';
           l_data1  :=r_line_1.subcontracted_flag;
           l_data2  :=r_line_2.subcontracted_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.DROP_SHIPPED_FLAG = 'Y') AND (NVL(r_line_2.DROP_SHIPPED_FLAG, ' ')<>'Y'))
	 OR((r_line_2.DROP_SHIPPED_FLAG = 'Y') AND (NVL(r_line_1.DROP_SHIPPED_FLAG, ' ')<>'Y'))THEN
           l_prompt :='DROP_SHIPPED_YN';
           l_data1  :=r_line_1.drop_shipped_flag;
           l_data2  :=r_line_2.drop_shipped_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.COMPLETED_FLAG = 'Y') AND (NVL(r_line_2.COMPLETED_FLAG, ' ')<>'Y'))
	 OR((r_line_2.COMPLETED_FLAG = 'Y') AND (NVL(r_line_1.COMPLETED_FLAG, ' ')<>'Y'))  THEN
           l_prompt :='COMPLETED_YN';
           l_data1  :=r_line_1.completed_flag;
           l_data2  :=r_line_2.completed_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.comments <>r_line_2.comments )
		OR( NOT((r_line_1.comments is null)and(r_line_2.comments is null))
             AND ((r_line_1.comments is null)or(r_line_2.comments is null)))THEN
           l_prompt :='COMMENTS';
           l_data1  :=r_line_1.comments;
           l_data2  :=r_line_2.comments;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_line_1.target_date_definitize <>r_line_2.target_date_definitize )
		 OR( NOT((r_line_1.target_date_definitize is null)and(r_line_2.target_date_definitize is null))
             AND ((r_line_1.target_date_definitize is null)or(r_line_2.target_date_definitize is null)))THEN
           l_prompt :='TARGET_DATE_DEFINITIZE';
           l_data1  :=r_line_1.target_date_definitize;
           l_data2  :=r_line_2.target_date_definitize;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.discount_for_payment <>r_line_2.discount_for_payment )
		 OR( NOT((r_line_1.discount_for_payment is null)and(r_line_2.discount_for_payment is null))
             AND ((r_line_1.discount_for_payment is null)or(r_line_2.discount_for_payment is null)))THEN
           l_prompt :='DISCOUNT_FOR_PAYMENT';
           l_data1  :=r_line_1.discount_for_payment;
           l_data2  :=r_line_2.discount_for_payment;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.cost_of_sale_rate <>r_line_2.cost_of_sale_rate)
		 OR( NOT((r_line_1.cost_of_sale_rate is null)and(r_line_2.cost_of_sale_rate is null))
             AND ((r_line_1.cost_of_sale_rate is null)or(r_line_2.cost_of_sale_rate is null)))THEN
           l_prompt :='COST_OF_SALE_RATE';
           l_data1  :=r_line_1.cost_of_sale_rate;
           l_data2  :=r_line_2.cost_of_sale_rate;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.FINANCIAL_CTRL_FLAG = 'Y') AND (NVL(r_line_2.FINANCIAL_CTRL_FLAG, ' ')<>'Y'))
	 OR((r_line_2.FINANCIAL_CTRL_FLAG = 'Y') AND (NVL(r_line_1.FINANCIAL_CTRL_FLAG, ' ')<>'Y'))  THEN
           l_prompt :='FINANCIAL_CTRL_YN';
           l_data1  :=r_line_1.financial_ctrl_flag;
           l_data2  :=r_line_2.financial_ctrl_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.DEFINITIZED_FLAG = 'Y') AND (NVL(r_line_2.DEFINITIZED_FLAG, ' ')<>'Y'))
	 OR((r_line_2.DEFINITIZED_FLAG = 'Y') AND (NVL(r_line_1.DEFINITIZED_FLAG, ' ')<>'Y')) THEN

           l_prompt :='DEFINITIZED_YN';
           l_data1  :=r_line_1.definitized_flag;
           l_data2  :=r_line_2.definitized_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.BILL_UNDEFINITIZED_FLAG = 'Y') AND (NVL(r_line_2.BILL_UNDEFINITIZED_FLAG, ' ')<>'Y'))
	 OR((r_line_2.BILL_UNDEFINITIZED_FLAG = 'Y') AND (NVL(r_line_1.BILL_UNDEFINITIZED_FLAG, ' ')<>'Y')) THEN

           l_prompt :='BILL_UNDEFINITIZED_YN';
           l_data1  :=r_line_1.bill_undefinitized_flag;
           l_data2  :=r_line_2.bill_undefinitized_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.DCAA_AUDIT_REQ_FLAG = 'Y') AND (NVL(r_line_2.DCAA_AUDIT_REQ_FLAG, ' ')<>'Y'))
	 OR((r_line_2.DCAA_AUDIT_REQ_FLAG = 'Y') AND (NVL(r_line_1.DCAA_AUDIT_REQ_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='DCAA_AUDIT_REQ_YN';
           l_data1  :=r_line_1.dcaa_audit_req_flag;
           l_data2  :=r_line_2.dcaa_audit_req_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.cost_of_money <>r_line_2.cost_of_money )
		 OR( NOT((r_line_1.cost_of_money is null)and(r_line_2.cost_of_money is null))
             AND ((r_line_1.cost_of_money is null)or(r_line_2.cost_of_money is null)))THEN
           l_prompt :='COST_OF_MONEY_YN';
           l_data1  :=r_line_1.cost_of_money;
           l_data2  :=r_line_2.cost_of_money;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.INTERIM_RPT_REQ_FLAG = 'Y') AND (NVL(r_line_2.INTERIM_RPT_REQ_FLAG, ' ')<>'Y'))
	 OR((r_line_2.INTERIM_RPT_REQ_FLAG = 'Y') AND (NVL(r_line_1.INTERIM_RPT_REQ_FLAG, ' ')<>'Y')) THEN

           l_prompt :='INTERIM_RPT_REQ_YN';
           l_data1  :=r_line_1.interim_rpt_req_flag;
           l_data2  :=r_line_2.interim_rpt_req_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.NTE_WARNING_FLAG = 'Y') AND (NVL(r_line_2.NTE_WARNING_FLAG, ' ')<>'Y'))
	 OR((r_line_2.NTE_WARNING_FLAG = 'Y') AND (NVL(r_line_1.NTE_WARNING_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='NTE_WARNING_YN';
           l_data1  :=r_line_1.nte_warning_flag;
           l_data2  :=r_line_2.nte_warning_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.C_SSR_FLAG = 'Y') AND (NVL(r_line_2.C_SSR_FLAG, ' ')<>'Y'))
	 OR((r_line_2.C_SSR_FLAG = 'Y') AND (NVL(r_line_1.C_SSR_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='C_SSR_YN';
           l_data1  :=r_line_1.c_ssr_flag;
           l_data2  :=r_line_2.c_ssr_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.C_SCS_FLAG = 'Y') AND (NVL(r_line_2.C_SCS_FLAG, ' ')<>'Y'))
	 OR((r_line_2.C_SCS_FLAG = 'Y') AND (NVL(r_line_1.C_SCS_FLAG, ' ')<>'Y')) THEN

           l_prompt :='C_SCS_YN';
           l_data1  :=r_line_1.c_scs_flag;
           l_data2  :=r_line_2.c_scs_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.prepayment_amount <>r_line_2.prepayment_amount )
		 OR( NOT((r_line_1.prepayment_amount is null)and(r_line_2.prepayment_amount is null))
             AND ((r_line_1.prepayment_amount is null)or(r_line_2.prepayment_amount is null)))THEN
           l_prompt :='PREPAYMENT_AMOUNT';
           SET_AMOUNT_DIFF_DATA( r_line_1.prepayment_amount, r_line_2.prepayment_amount );
           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.prepayment_percentage <>r_line_2.prepayment_percentage )
		 OR( NOT((r_line_1.prepayment_percentage is null)and(r_line_2.prepayment_percentage is null))
             AND ((r_line_1.prepayment_percentage is null)or(r_line_2.prepayment_percentage is null)))THEN
           l_prompt :='PREPAYMENT_PERCENTAGE';
           l_data1  :=r_line_1.prepayment_percentage;
           l_data2  :=r_line_2.prepayment_percentage;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.PROGRESS_PAYMENT_FLAG = 'Y') AND (NVL(r_line_2.PROGRESS_PAYMENT_FLAG, ' ')<>'Y'))
	 OR((r_line_2.PROGRESS_PAYMENT_FLAG = 'Y') AND (NVL(r_line_1.PROGRESS_PAYMENT_FLAG, ' ')<>'Y'))THEN

           l_prompt :='PROGRESS_PAYMENT_YN';
           l_data1  :=r_line_1.progress_payment_flag;
           l_data2  :=r_line_2.progress_payment_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.progress_payment_rate <>r_line_2.progress_payment_rate )
		 OR( NOT((r_line_1.progress_payment_rate is null)and(r_line_2.progress_payment_rate is null))
             AND ((r_line_1.progress_payment_rate is null)or(r_line_2.progress_payment_rate is null)))THEN
           l_prompt :='PROGRESS_PAYMENT_RATE';
           l_data1  :=r_line_1.progress_payment_rate;
           l_data2  :=r_line_2.progress_payment_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_line_1.progress_payment_liq_rate <>r_line_2.progress_payment_liq_rate )
		 OR( NOT((r_line_1.progress_payment_liq_rate is null)and(r_line_2.progress_payment_liq_rate is null))
             AND ((r_line_1.progress_payment_liq_rate is null)or(r_line_2.progress_payment_liq_rate is null)))THEN
           l_prompt :='PROGRESS_PAYMENT_LIQ_RATE';
           l_data1  :=r_line_1.progress_payment_liq_rate;
           l_data2  :=r_line_2.progress_payment_liq_rate;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.line_liquidation_rate <>r_line_2.line_liquidation_rate )
		 OR( NOT((r_line_1.line_liquidation_rate is null)and(r_line_2.line_liquidation_rate is null))
             AND ((r_line_1.line_liquidation_rate is null)or(r_line_2.line_liquidation_rate is null)))THEN
           l_prompt :='LINE_LIQUIDATION_RATE';
           l_data1  :=r_line_1.line_liquidation_rate;
           l_data2  :=r_line_2.line_liquidation_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.boe_description <>r_line_2.boe_description )
		 OR( NOT((r_line_1.boe_description is null)and(r_line_2.boe_description is null))
             AND ((r_line_1.boe_description is null)or(r_line_2.boe_description is null)))THEN
           l_prompt :='BOE_DESCRIPTION';
           l_data1  :=r_line_1.boe_description;
           l_data2  :=r_line_2.boe_description;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.billing_method <>r_line_2.billing_method )
		 OR( NOT((r_line_1.billing_method is null)and(r_line_2.billing_method is null))
             AND ((r_line_1.billing_method is null)or(r_line_2.billing_method is null)))THEN
           l_prompt :='BILLING_METHOD';
           l_data1  :=r_line_1.billing_method;
           l_data2  :=r_line_2.billing_method;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.total_estimated_cost <>r_line_2.total_estimated_cost )
		 OR( NOT((r_line_1.total_estimated_cost is null)and(r_line_2.total_estimated_cost is null))
             AND ((r_line_1.total_estimated_cost is null)or(r_line_2.total_estimated_cost is null)))THEN
           l_prompt :='TOTAL_ESTIMATED_COST';
           l_data1  :=r_line_1.total_estimated_cost;
           l_data2  :=r_line_2.total_estimated_cost;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.customer_percent_in_order <>r_line_2.customer_percent_in_order )
		 OR( NOT((r_line_1.customer_percent_in_order is null)and(r_line_2.customer_percent_in_order is null))
             AND ((r_line_1.customer_percent_in_order is null)or(r_line_2.customer_percent_in_order is null)))THEN
           l_prompt :='CUSTOMER_PERCENT_IN_ORDER';
           l_data1  :=r_line_1.customer_percent_in_order;
           l_data2  :=r_line_2.customer_percent_in_order;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.ceiling_cost <>r_line_2.ceiling_cost )
		 OR( NOT((r_line_1.ceiling_cost is null)and(r_line_2.ceiling_cost is null))
             AND ((r_line_1.ceiling_cost is null)or(r_line_2.ceiling_cost is null)))THEN
           l_prompt :='CEILING_COST';
           l_data1  :=r_line_1.ceiling_cost;
           l_data2  :=r_line_2.ceiling_cost;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.level_of_effort_hours <>r_line_2.level_of_effort_hours )
		 OR( NOT((r_line_1.level_of_effort_hours is null)and(r_line_2.level_of_effort_hours is null))
             AND ((r_line_1.level_of_effort_hours is null)or(r_line_2.level_of_effort_hours is null)))THEN
           l_prompt :='LEVEL_OF_EFFORT_HOURS';
           l_data1  :=r_line_1.level_of_effort_hours;
           l_data2  :=r_line_2.level_of_effort_hours;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_line_1.award_fee <>r_line_2.award_fee )
		 OR( NOT((r_line_1.award_fee is null)and(r_line_2.award_fee is null))
             AND ((r_line_1.award_fee is null)or(r_line_2.award_fee is null)))THEN
           l_prompt :='AWARD_FEE';
           l_data1  :=r_line_1.award_fee;
           l_data2  :=r_line_2.award_fee;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.base_fee <>r_line_2.base_fee )
		 OR( NOT((r_line_1.base_fee is null)and(r_line_2.base_fee is null))
             AND ((r_line_1.base_fee is null)or(r_line_2.base_fee is null)))THEN
           l_prompt :='BASE_FEE';
           l_data1  :=r_line_1.base_fee;
           l_data2  :=r_line_2.base_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.minimum_fee <>r_line_2.minimum_fee  )
		 OR( NOT((r_line_1.minimum_fee is null)and(r_line_2.minimum_fee is null))
             AND ((r_line_1.minimum_fee is null)or(r_line_2.minimum_fee is null)))THEN
           l_prompt :='MINIMUM_FEE';
           l_data1  :=r_line_1.minimum_fee;
           l_data2  :=r_line_2.minimum_fee;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.maximum_fee <>r_line_2.maximum_fee )
		 OR( NOT((r_line_1.maximum_fee is null)and(r_line_2.maximum_fee is null))
             AND ((r_line_1.maximum_fee is null)or(r_line_2.maximum_fee is null)))THEN
           l_prompt :='MAXIMUM_FEE';
           l_data1  :=r_line_1.maximum_fee;
           l_data2  :=r_line_2.maximum_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.award_fee_pool_amount <>r_line_2.award_fee_pool_amount )
		 OR( NOT((r_line_1.award_fee_pool_amount is null)and(r_line_2.award_fee_pool_amount is null))
             AND ((r_line_1.award_fee_pool_amount is null)or(r_line_2.award_fee_pool_amount is null)))THEN
           l_prompt :='AWARD_FEE_POOL_AMOUNT';
           l_data1  :=r_line_1.award_fee_pool_amount;
           l_data2  :=r_line_2.award_fee_pool_amount;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.fixed_fee <>r_line_2.fixed_fee )
		 OR( NOT((r_line_1.fixed_fee is null)and(r_line_2.fixed_fee is null))
             AND ((r_line_1.fixed_fee is null)or(r_line_2.fixed_fee is null)))THEN
           l_prompt :='FIXED_FEE';
           l_data1  :=r_line_1.fixed_fee;
           l_data2  :=r_line_2.fixed_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.initial_fee <>r_line_2.initial_fee )
		 OR( NOT((r_line_1.initial_fee is null)and(r_line_2.initial_fee is null))
             AND ((r_line_1.initial_fee is null)or(r_line_2.initial_fee is null)))THEN
           l_prompt :='INITIAL_FEE';
           l_data1  :=r_line_1.initial_fee;
           l_data2  :=r_line_2.initial_fee;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.final_fee <>r_line_2.final_fee)
		   OR( NOT((r_line_1.final_fee is null)and(r_line_2.final_fee is null))
             AND ((r_line_1.final_fee is null)or(r_line_2.final_fee is null)))THEN
           l_prompt :='FINAL_FEE';
           l_data1  :=r_line_1.final_fee;
           l_data2  :=r_line_2.final_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.fee_ajt_formula <>r_line_2.fee_ajt_formula)
		 OR( NOT((r_line_1.fee_ajt_formula is null)and(r_line_2.fee_ajt_formula is null))
             AND ((r_line_1.fee_ajt_formula is null)or(r_line_2.fee_ajt_formula is null)))THEN
           l_prompt :='FEE_AJT_FORMULA';
           l_data1  :=r_line_1.fee_ajt_formula;
           l_data2  :=r_line_2.fee_ajt_formula;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.target_cost <>r_line_2.target_cost )
		 OR( NOT((r_line_1.target_cost is null)and(r_line_2.target_cost is null))
             AND ((r_line_1.target_cost is null)or(r_line_2.target_cost is null)))THEN
           l_prompt :='TARGET_COST';
           l_data1  :=r_line_1.target_cost;
           l_data2  :=r_line_2.target_cost;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.target_fee <>r_line_2.target_fee)
		 OR( NOT((r_line_1.target_fee is null)and(r_line_2.target_fee is null))
             AND ((r_line_1.target_fee is null)or(r_line_2.target_fee is null)))THEN
           l_prompt :='TARGET_FEE';
           l_data1  :=r_line_1.target_fee;
           l_data2  :=r_line_2.target_fee;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.ceiling_price <>r_line_2.ceiling_price )
		 OR( NOT((r_line_1.ceiling_price is null)and(r_line_2.ceiling_price is null))
             AND ((r_line_1.ceiling_price is null)or(r_line_2.ceiling_price is null)))THEN
          l_prompt :='CEILING_PRICE';
          SET_PRICE_DIFF_DATA( r_line_1.ceiling_price, r_line_2.ceiling_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.target_price <>r_line_2.target_price)
		 OR( NOT((r_line_1.target_price is null)and(r_line_2.target_price is null))
             AND ((r_line_1.target_price is null)or(r_line_2.target_price is null)))THEN
          l_prompt :='TARGET_PRICE';
          SET_PRICE_DIFF_DATA( r_line_1.target_price, r_line_2.target_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.cost_overrun_share_ratio <>r_line_2.cost_overrun_share_ratio )
		 OR( NOT((r_line_1.cost_overrun_share_ratio is null)and(r_line_2.cost_overrun_share_ratio is null))
             AND ((r_line_1.cost_overrun_share_ratio is null)or(r_line_2.cost_overrun_share_ratio is null)))THEN
           l_prompt :='COST_OVERRUN_SHARE_RATIO';
           l_data1  :=r_line_1.cost_overrun_share_ratio;
           l_data2  :=r_line_2.cost_overrun_share_ratio;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.cost_underrun_share_ratio <>r_line_2.cost_underrun_share_ratio )
		 OR( NOT((r_line_1.cost_underrun_share_ratio is null)and(r_line_2.cost_underrun_share_ratio is null))
             AND ((r_line_1.cost_underrun_share_ratio is null)or(r_line_2.cost_underrun_share_ratio is null)))THEN
           l_prompt :='COST_UNDERRUN_SHARE_RATIO';
           l_data1  :=r_line_1.cost_underrun_share_ratio;
           l_data2  :=r_line_2.cost_underrun_share_ratio;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.final_pft_ajt_formula <>r_line_2.final_pft_ajt_formula )
		 OR( NOT((r_line_1.final_pft_ajt_formula is null)and(r_line_2.final_pft_ajt_formula is null))
             AND ((r_line_1.final_pft_ajt_formula is null)or(r_line_2.final_pft_ajt_formula is null)))THEN
           l_prompt :='FINAL_PFT_AJT_FORMULA';
           l_data1  :=r_line_1.final_pft_ajt_formula;
           l_data2  :=r_line_2.final_pft_ajt_formula;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.fixed_quantity <>r_line_2.fixed_quantity )
		 OR( NOT((r_line_1.fixed_quantity is null)and(r_line_2.fixed_quantity is null))
             AND ((r_line_1.fixed_quantity is null)or(r_line_2.fixed_quantity is null)))THEN
           l_prompt :='FIXED_QUANTITY';
           l_data1  :=r_line_1.fixed_quantity;
           l_data2  :=r_line_2.fixed_quantity;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_line_1.minimum_quantity <>r_line_2.minimum_quantity )
		 OR( NOT((r_line_1.minimum_quantity is null)and(r_line_2.minimum_quantity is null))
             AND ((r_line_1.minimum_quantity is null)or(r_line_2.minimum_quantity is null)))THEN
           l_prompt :='MINIMUM_QUANTITY';
           l_data1  :=r_line_1.minimum_quantity;
           l_data2  :=r_line_2.minimum_quantity;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.maximum_quantity <>r_line_2.maximum_quantity )
		 OR( NOT((r_line_1.maximum_quantity is null)and(r_line_2.maximum_quantity is null))
             AND ((r_line_1.maximum_quantity is null)or(r_line_2.maximum_quantity is null)))THEN
           l_prompt :='MAXIMUM_QUANTITY';
           l_data1  :=r_line_1.maximum_quantity;
           l_data2  :=r_line_2.maximum_quantity;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.estimated_total_quantity <>r_line_2.estimated_total_quantity )
		 OR( NOT((r_line_1.estimated_total_quantity is null)and(r_line_2.estimated_total_quantity is null))
             AND ((r_line_1.estimated_total_quantity is null)or(r_line_2.estimated_total_quantity is null)))THEN
           l_prompt :='ESTIMATED_TOTAL_QUANTITY';
           l_data1  :=r_line_1.estimated_total_quantity;
           l_data2  :=r_line_2.estimated_total_quantity;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.number_of_options <>r_line_2.number_of_options )
		 OR( NOT((r_line_1.number_of_options is null)and(r_line_2.number_of_options is null))
             AND ((r_line_1.number_of_options is null)or(r_line_2.number_of_options is null)))THEN
           l_prompt :='NUMBER_OF_OPTIONS';
           l_data1  :=r_line_1.number_of_options;
           l_data2  :=r_line_2.number_of_options;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.initial_price <>r_line_2.initial_price )
		 OR( NOT((r_line_1.initial_price is null)and(r_line_2.initial_price is null))
             AND ((r_line_1.initial_price is null)or(r_line_2.initial_price is null)))THEN
           l_prompt :='INITIAL_PRICE';
           SET_PRICE_DIFF_DATA( r_line_1.initial_price, r_line_2.initial_price );
           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.revised_price <>r_line_2.revised_price )
		 OR( NOT((r_line_1.revised_price is null)and(r_line_2.revised_price is null))
             AND ((r_line_1.revised_price is null)or(r_line_2.revised_price is null)))THEN
          l_prompt :='REVISED_PRICE';
          SET_PRICE_DIFF_DATA( r_line_1.revised_price, r_line_2.revised_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.material_cost_index <>r_line_2.material_cost_index )
		 OR( NOT((r_line_1.material_cost_index is null)and(r_line_2.material_cost_index is null))
             AND ((r_line_1.material_cost_index is null)or(r_line_2.material_cost_index is null)))THEN
           l_prompt :='MATERIAL_COST_INDEX';
           l_data1  :=r_line_1.material_cost_index;
           l_data2  :=r_line_2.material_cost_index;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.labor_cost_index <>r_line_2.labor_cost_index )
		 OR( NOT((r_line_1.labor_cost_index is null)and(r_line_2.labor_cost_index is null))
             AND ((r_line_1.labor_cost_index is null)or(r_line_2.labor_cost_index is null)))THEN
           l_prompt :='LABOR_COST_INDEX';
           l_data1  :=r_line_1.labor_cost_index;
           l_data2  :=r_line_2.labor_cost_index;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.date_of_price_redetermin <>r_line_2.date_of_price_redetermin )
		 OR( NOT((r_line_1.date_of_price_redetermin is null)and(r_line_2.date_of_price_redetermin is null))
             AND ((r_line_1.date_of_price_redetermin is null)or(r_line_2.date_of_price_redetermin is null)))THEN
           l_prompt :='DATE_OF_PRICE_REDETERMIN';
           l_data1  :=r_line_1.date_of_price_redetermin;
           l_data2  :=r_line_2.date_of_price_redetermin;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.country_of_origin_code <>r_line_2.country_of_origin_code)
		 OR( NOT((r_line_1.country_of_origin_code is null)and(r_line_2.country_of_origin_code is null))
             AND ((r_line_1.country_of_origin_code is null)or(r_line_2.country_of_origin_code is null)))THEN
           l_prompt :='COUNTRY_OF_ORIGIN_CODE';
           l_data1  :=r_line_1.country_of_origin_code;
           l_data2  :=r_line_2.country_of_origin_code;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.EXPORT_FLAG = 'Y') AND (NVL(r_line_2.EXPORT_FLAG, ' ')<>'Y'))
	 OR((r_line_2.EXPORT_FLAG = 'Y') AND (NVL(r_line_1.EXPORT_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='EXPORT_YN';
           l_data1  :=r_line_1.export_flag;
           l_data2  :=r_line_2.export_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.export_license_num <>r_line_2.export_license_num )
		 OR( NOT((r_line_1.export_license_num is null)and(r_line_2.export_license_num is null))
             AND ((r_line_1.export_license_num is null)or(r_line_2.export_license_num is null)))THEN
           l_prompt :='EXPORT_LICENSE_NUM';
           l_data1  :=r_line_1.export_license_num;
           l_data2  :=r_line_2.export_license_num;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.export_license_res <>r_line_2.export_license_res )
		 OR( NOT((r_line_1.export_license_res is null)and(r_line_2.export_license_res is null))
             AND ((r_line_1.export_license_res is null)or(r_line_2.export_license_res is null)))THEN
           l_prompt :='EXPORT_LICENSE_RES';
           l_data1  :=r_line_1.export_license_res;
           l_data2  :=r_line_2.export_license_res;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.COP_REQUIRED_FLAG = 'Y') AND (NVL(r_line_2.COP_REQUIRED_FLAG, ' ')<>'Y'))
	 OR((r_line_2.COP_REQUIRED_FLAG = 'Y') AND (NVL(r_line_1.COP_REQUIRED_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='COP_REQUIRED_YN';
           l_data1  :=r_line_1.cop_required_flag;
           l_data2  :=r_line_2.cop_required_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.INSPECTION_REQ_FLAG = 'Y') AND (NVL(r_line_2.INSPECTION_REQ_FLAG, ' ')<>'Y'))
	 OR((r_line_2.INSPECTION_REQ_FLAG = 'Y') AND (NVL(r_line_1.INSPECTION_REQ_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='INSPECTION_REQ_YN';
           l_data1  :=r_line_1.inspection_req_flag;
           l_data2  :=r_line_2.inspection_req_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.SUBJ_A133_FLAG = 'Y') AND (NVL(r_line_2.SUBJ_A133_FLAG, ' ')<>'Y'))
	 OR((r_line_2.SUBJ_A133_FLAG = 'Y') AND (NVL(r_line_1.SUBJ_A133_FLAG, ' ')<>'Y')) THEN

           l_prompt :='SUBJ_A133_YN';
           l_data1  :=r_line_1.subj_a133_flag;
           l_data2  :=r_line_2.subj_a133_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF ((r_line_1.CFE_FLAG = 'Y') AND (NVL(r_line_2.CFE_FLAG, ' ')<>'Y'))
	 OR((r_line_2.CFE_FLAG = 'Y') AND (NVL(r_line_1.CFE_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='CFE_YN';
           l_data1  :=r_line_1.cfe_flag;
           l_data2  :=r_line_2.cfe_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_line_1.CUSTOMER_APPROVAL_REQ_FLAG = 'Y') AND (NVL(r_line_2.CUSTOMER_APPROVAL_REQ_FLAG, ' ')<>'Y'))
	 OR((r_line_2.CUSTOMER_APPROVAL_REQ_FLAG = 'Y') AND (NVL(r_line_1.CUSTOMER_APPROVAL_REQ_FLAG, ' ')<>'Y'))  THEN

           l_prompt :='CUSTOMER_APPROVAL_REQ_YN';
           l_data1  :=r_line_1.customer_approval_req_flag;
           l_data2  :=r_line_2.customer_approval_req_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.data_item_name <>r_line_2.data_item_name )
		 OR( NOT((r_line_1.data_item_name is null)and(r_line_2.data_item_name is null))
             AND ((r_line_1.data_item_name is null)or(r_line_2.data_item_name is null)))THEN
           l_prompt :='DATA_ITEM_NAME';
           l_data1  :=r_line_1.data_item_name;
           l_data2  :=r_line_2.data_item_name;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.data_item_subtitle <>r_line_2.data_item_subtitle )
		 OR( NOT((r_line_1.data_item_subtitle is null)and(r_line_2.data_item_subtitle is null))
             AND ((r_line_1.data_item_subtitle is null)or(r_line_2.data_item_subtitle is null)))THEN
           l_prompt :='DATA_ITEM_SUBTITLE';
           l_data1  :=r_line_1.data_item_subtitle;
           l_data2  :=r_line_2.data_item_subtitle;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.cdrl_category <>r_line_2.cdrl_category )
		 OR( NOT((r_line_1.cdrl_category is null)and(r_line_2.cdrl_category is null))
             AND ((r_line_1.cdrl_category is null)or(r_line_2.cdrl_category is null)))THEN
           l_prompt :='CDRL_CATEGORY';
           l_data1  :=r_line_1.cdrl_category;
           l_data2  :=r_line_2.cdrl_category;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.requiring_office <>r_line_2.requiring_office )
		 OR( NOT((r_line_1.requiring_office is null)and(r_line_2.requiring_office is null))
             AND ((r_line_1.requiring_office is null)or(r_line_2.requiring_office is null)))THEN
           l_prompt :='REQUIRING_OFFICE';
           l_data1  :=r_line_1.requiring_office;
           l_data2  :=r_line_2.requiring_office;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.date_of_first_submission <>r_line_2.date_of_first_submission )
		 OR( NOT((r_line_1.date_of_first_submission is null)and(r_line_2.date_of_first_submission is null))
             AND ((r_line_1.date_of_first_submission is null)or(r_line_2.date_of_first_submission is null)))THEN
           l_prompt :='DATE_OF_FIRST_SUBMISSION';
           l_data1  :=r_line_1.date_of_first_submission;
           l_data2  :=r_line_2.date_of_first_submission;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.frequency <>r_line_2.frequency )
		 OR( NOT((r_line_1.frequency is null)and(r_line_2.frequency is null))
             AND ((r_line_1.frequency is null)or(r_line_2.frequency is null)))THEN
           l_prompt :='FREQUENCY';
           l_data1  :=r_line_1.frequency;
           l_data2  :=r_line_2.frequency;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_line_1.copies_required <>r_line_2.copies_required )
		 OR( NOT((r_line_1.copies_required is null)and(r_line_2.copies_required is null))
             AND ((r_line_1.copies_required is null)or(r_line_2.copies_required is null)))THEN
           l_prompt :='COPIES_REQUIRED';
           l_data1  :=r_line_1.copies_required;
           l_data2  :=r_line_2.copies_required;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        comp_line_parties(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

        comp_line_terms(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

        comp_line_articles(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

	If L_Latest_Version >= vVersion1 THEN
           SELECT count(*)
           INTO nDeliverables
      	   from oke_k_deliverables_bh
     	   where k_header_id=vHeader_id
      	   and k_line_id=nCurrent_line_id
      	   and major_version=vVersion1;

           SELECT count(*)
           INTO nSublines
           FROM okc_k_lines_bh
           WHERE CLE_ID=nCurrent_line_id
           AND MAJOR_VERSION= vVersion1;

        ELSE
           SELECT count(*)
           INTO nDeliverables
      	   from oke_k_deliverables_b
     	   where k_header_id=vHeader_id
      	   and k_line_id=nCurrent_line_id;

           SELECT  count(*)
           INTO nSublines
           FROM okc_k_lines_b
           WHERE CLE_ID=nCurrent_line_id;
        END IF;

        IF nDeliverables>0 THEN
--DBMS_OUTPUT.PUT_LINE('Top Line has  '||nDeliverables|| ' deliverables, to  compare.');
	   comp_line_deliverables(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);
        END IF;

        IF nSublines>0  THEN

           comp_subline(vHeader_id, vVersion1, vVersion2, nCurrent_line_id);

        END IF;

      END LOOP;
      CLOSE v_top_nodes;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN
            NULL;
            WHEN OTHERS THEN
	    NULL;

  END comp_lines;

  PROCEDURE comp_subline(vHeader_id IN NUMBER, vVersion1 IN NUMBER, vVersion2 IN NUMBER, vParentLineId IN NUMBER)
  AS
     TYPE r_current_Line IS RECORD(
		major_version         OKE_K_LINES_SECURE_HV.major_version%TYPE,
		line_number           OKE_K_LINES_SECURE_HV.line_number%TYPE,
		status                OKE_K_LINES_SECURE_HV.status%TYPE,
		line_style            OKE_K_LINES_SECURE_HV.line_style%TYPE,
		project_number        OKE_K_LINES_SECURE_HV.project_number%TYPE,
		task_number           OKE_K_LINES_SECURE_HV.task_number%TYPE,
		start_date            OKE_K_LINES_SECURE_HV.start_date%TYPE,
		end_date              OKE_K_LINES_SECURE_HV.end_date%TYPE,
		delivery_date         OKE_K_LINES_SECURE_HV.delivery_date%TYPE,
		proposal_due_date     OKE_K_LINES_SECURE_HV.proposal_due_date%TYPE,
		item_number           OKE_K_LINES_SECURE_HV.item_number%TYPE,
              --item_description      OKE_K_LINES_SECURE_HV.item_description%TYPE,
		line_description      OKE_K_LINES_SECURE_HV.line_description%TYPE,
		customer_item_number  OKE_K_LINES_SECURE_HV.customer_item_number%TYPE,
		nsn_number            OKE_K_LINES_SECURE_HV.nsn_number%TYPE,
		nsp_flag              OKE_K_LINES_SECURE_HV.nsp_flag%TYPE,
		line_quantity         OKE_K_LINES_SECURE_HV.line_quantity%TYPE,
		uom_code              OKE_K_LINES_SECURE_HV.uom_code%TYPE,
		unit_price            OKE_K_LINES_SECURE_HV.unit_price%TYPE,
		undef_unit_price      OKE_K_LINES_SECURE_HV.undef_unit_price%TYPE,
		line_value            OKE_K_LINES_SECURE_HV.line_value%TYPE,
		undef_line_value      OKE_K_LINES_SECURE_HV.undef_line_value%TYPE,
		line_value_total      OKE_K_LINES_SECURE_HV.line_value_total%TYPE,
		undef_line_value_total    OKE_K_LINES_SECURE_HV.undef_line_value_total%TYPE,
		--line_value_copy       OKE_K_LINES_SECURE_HV.line_value_copy%TYPE,
		billable_flag         OKE_K_LINES_SECURE_HV.billable_flag%TYPE,
		shippable_flag        OKE_K_LINES_SECURE_HV.shippable_flag%TYPE,
		subcontracted_flag    OKE_K_LINES_SECURE_HV.subcontracted_flag%TYPE,
		drop_shipped_flag     OKE_K_LINES_SECURE_HV.drop_shipped_flag%TYPE,
		completed_flag        OKE_K_LINES_SECURE_HV.completed_flag%TYPE,
		comments              OKE_K_LINES_SECURE_HV.comments%TYPE,
		target_date_definitize    OKE_K_LINES_SECURE_HV.target_date_definitize%TYPE,
		discount_for_payment  OKE_K_LINES_SECURE_HV.discount_for_payment%TYPE,
		cost_of_sale_rate     OKE_K_LINES_SECURE_HV.cost_of_sale_rate%TYPE,
		financial_ctrl_flag   OKE_K_LINES_SECURE_HV.financial_ctrl_flag%TYPE,
		definitized_flag      OKE_K_LINES_SECURE_HV.definitized_flag%TYPE,
		bill_undefinitized_flag   OKE_K_LINES_SECURE_HV.bill_undefinitized_flag%TYPE,
		dcaa_audit_req_flag   OKE_K_LINES_SECURE_HV.dcaa_audit_req_flag%TYPE,
		cost_of_money         OKE_K_LINES_SECURE_HV.cost_of_money%TYPE,
		interim_rpt_req_flag  OKE_K_LINES_SECURE_HV.interim_rpt_req_flag%TYPE,
		nte_warning_flag      OKE_K_LINES_SECURE_HV.nte_warning_flag%TYPE,
		c_ssr_flag            OKE_K_LINES_SECURE_HV.c_ssr_flag%TYPE,
		c_scs_flag            OKE_K_LINES_SECURE_HV.c_scs_flag%TYPE,
		prepayment_amount     OKE_K_LINES_SECURE_HV.prepayment_amount%TYPE,
		prepayment_percentage OKE_K_LINES_SECURE_HV.prepayment_percentage%TYPE,
		progress_payment_flag OKE_K_LINES_SECURE_HV.progress_payment_flag%TYPE,
		progress_payment_rate OKE_K_LINES_SECURE_HV.progress_payment_rate%TYPE,
		progress_payment_liq_rate        OKE_K_LINES_SECURE_HV.progress_payment_liq_rate%TYPE,
		line_liquidation_rate OKE_K_LINES_SECURE_HV.line_liquidation_rate%TYPE,
		boe_description       OKE_K_LINES_SECURE_HV.boe_description%TYPE,
		billing_method        OKE_K_LINES_SECURE_HV.billing_method%TYPE,
		total_estimated_cost  OKE_K_LINES_SECURE_HV.total_estimated_cost%TYPE,
		customer_percent_in_order      OKE_K_LINES_SECURE_HV.customer_percent_in_order%TYPE,
		ceiling_cost          OKE_K_LINES_SECURE_HV.ceiling_cost%TYPE,
		level_of_effort_hours OKE_K_LINES_SECURE_HV.level_of_effort_hours%TYPE,
		award_fee             OKE_K_LINES_SECURE_HV.award_fee%TYPE,
		base_fee              OKE_K_LINES_SECURE_HV.base_fee%TYPE,
		minimum_fee           OKE_K_LINES_SECURE_HV.minimum_fee%TYPE,
		maximum_fee           OKE_K_LINES_SECURE_HV.maximum_fee%TYPE,
		award_fee_pool_amount OKE_K_LINES_SECURE_HV.award_fee_pool_amount%TYPE,
		fixed_fee             OKE_K_LINES_SECURE_HV.fixed_fee%TYPE,
		initial_fee           OKE_K_LINES_SECURE_HV.initial_fee%TYPE,
		final_fee             OKE_K_LINES_SECURE_HV.final_fee%TYPE,
		fee_ajt_formula       OKE_K_LINES_SECURE_HV.fee_ajt_formula%TYPE,
		target_cost           OKE_K_LINES_SECURE_HV.target_cost%TYPE,
		target_fee            OKE_K_LINES_SECURE_HV.target_fee%TYPE,
		target_price          OKE_K_LINES_SECURE_HV.target_price%TYPE,
		ceiling_price         OKE_K_LINES_SECURE_HV.ceiling_price%TYPE,
		cost_overrun_share_ratio    OKE_K_LINES_SECURE_HV.cost_overrun_share_ratio%TYPE,
		cost_underrun_share_ratio   OKE_K_LINES_SECURE_HV.cost_underrun_share_ratio%TYPE,
		final_pft_ajt_formula       OKE_K_LINES_SECURE_HV.final_pft_ajt_formula%TYPE,
		fixed_quantity              OKE_K_LINES_SECURE_HV.fixed_quantity%TYPE,
		minimum_quantity            OKE_K_LINES_SECURE_HV.minimum_quantity%TYPE,
		maximum_quantity            OKE_K_LINES_SECURE_HV.maximum_quantity%TYPE,
		estimated_total_quantity    OKE_K_LINES_SECURE_HV.estimated_total_quantity%TYPE,
		number_of_options           OKE_K_LINES_SECURE_HV.number_of_options%TYPE,
		initial_price               OKE_K_LINES_SECURE_HV.initial_price%TYPE,
		revised_price               OKE_K_LINES_SECURE_HV.revised_price%TYPE,
		material_cost_index         OKE_K_LINES_SECURE_HV.material_cost_index%TYPE,
		labor_cost_index            OKE_K_LINES_SECURE_HV.labor_cost_index%TYPE,
		date_of_price_redetermin    OKE_K_LINES_SECURE_HV.date_of_price_redetermin%TYPE,
		country_of_origin_code       OKE_K_LINES_SECURE_HV.country_of_origin_code%TYPE,
		export_flag                 OKE_K_LINES_SECURE_HV.export_flag%TYPE,
		export_license_num          OKE_K_LINES_SECURE_HV.export_license_num%TYPE,
		export_license_res          OKE_K_LINES_SECURE_HV.export_license_res%TYPE,
		cop_required_flag           OKE_K_LINES_SECURE_HV.cop_required_flag%TYPE,
		inspection_req_flag         OKE_K_LINES_SECURE_HV.inspection_req_flag%TYPE,
		subj_a133_flag              OKE_K_LINES_SECURE_HV.subj_a133_flag%TYPE,
		cfe_flag                    OKE_K_LINES_SECURE_HV.cfe_flag%TYPE,
		customer_approval_req_flag  OKE_K_LINES_SECURE_HV.customer_approval_req_flag%TYPE,
		data_item_name              OKE_K_LINES_SECURE_HV.data_item_name%TYPE,
		data_item_subtitle          OKE_K_LINES_SECURE_HV.data_item_subtitle%TYPE,
		cdrl_category               OKE_K_LINES_SECURE_HV.cdrl_category%TYPE,
		requiring_office            OKE_K_LINES_SECURE_HV.requiring_office%TYPE,
		date_of_first_submission     OKE_K_LINES_SECURE_HV.date_of_first_submission%TYPE,
		frequency                   OKE_K_LINES_SECURE_HV.frequency%TYPE,
		copies_required             OKE_K_LINES_SECURE_HV.copies_required%TYPE

		);

       r_current_line_1 r_current_line;
       r_current_line_2 r_current_line;

       l_numOfSublines NUMBER;
       nDeliverables   NUMBER;
       full_line_path varchar2(300);

       nCurrent_line_id NUMBER;

       TYPE c_sub_nodes IS REF CURSOR;
       v_sub_nodes c_sub_nodes;
       c_sub_node OKE_K_LINES_SECURE_HV.parent_line_id%TYPE;

       CURSOR c_nDifferent_lines_1 IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_BH a
         WHERE DNZ_CHR_ID=vHeader_id
         AND CLE_ID=vParentLineId
         AND MAJOR_VERSION=vVersion1
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_BH b
         WHERE b.ID=a.ID
         AND CLE_ID=vParentLineId
         AND MAJOR_VERSION=vVersion2)
         ORDER BY LINE_NUMBER;

       CURSOR c_nDifferent_lines_1_latest IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_B a
         WHERE DNZ_CHR_ID=vHeader_id
         AND CLE_ID=vParentLineId
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_BH b
         WHERE b.ID=a.ID
         AND CLE_ID=vParentLineId
         AND MAJOR_VERSION=vVersion2)
         ORDER BY LINE_NUMBER;

       CURSOR c_nDifferent_lines_2 IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_BH a
         WHERE DNZ_CHR_ID=vHeader_id
         AND CLE_ID=vParentLineId
         AND MAJOR_VERSION=vVersion2
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_BH b
         WHERE b.ID=a.ID
         AND CLE_ID=vParentLineId
         AND MAJOR_VERSION=vVersion1)
         ORDER BY LINE_NUMBER;

        CURSOR c_nDifferent_lines_2_latest IS
         SELECT ID K_LINE_ID
         FROM OKC_K_LINES_BH a
         WHERE DNZ_CHR_ID=vHeader_id
         AND CLE_ID=vParentLineId
         AND MAJOR_VERSION=vVersion2
         AND NOT EXISTS
       ( SELECT 'x'
         FROM OKC_K_LINES_B b
         WHERE b.ID=a.ID
         AND CLE_ID=vParentLineId)
         ORDER BY LINE_NUMBER;

      CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;

     l_api_name     CONSTANT VARCHAR2(30) := 'comp_sublines';

     BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Begin comparing sub-lines ...');
    END IF;

        L_Attribute_Object_Name :='OKE_K_LINES';
        l_Object  :='LINE';

        OPEN c;
        FETCH c INTO l_object_type;
        CLOSE c;

	IF L_Latest_Version >=vVersion1 THEN

            FOR c_nDifferent_line IN c_nDifferent_lines_1 LOOP


              l_object_name:=get_full_path_linenum(c_nDifferent_line.k_line_id,vVersion1);
              l_prompt :='';
              l_Object  :='NO_LINE';

              OPEN c;
              FETCH c INTO l_data2;
              CLOSE c;

              l_data1  :='';

              insert_comp_result(vHeader_id,vVersion1,vVersion2);

            END LOOP;

            FOR c_nDifferent_line IN c_nDifferent_lines_2 LOOP

              l_object_name :=get_full_path_linenum(c_nDifferent_line.k_line_id,vVersion2);
              l_prompt :='';

	      l_Object  :='NO_LINE';

              OPEN c;
              FETCH c INTO l_data1;
              CLOSE c;

              l_data2  :='';

              insert_comp_result(vHeader_id,vVersion1,vVersion2);

            END LOOP;

            OPEN v_sub_nodes FOR
              SELECT a.ID K_LINE_ID
               FROM  OKC_K_LINES_BH A, OKC_K_LINES_BH B
               WHERE a.DNZ_CHR_ID=vHeader_id
                 AND a.MAJOR_VERSION=vVersion1
                 AND a.CLE_ID=vParentLineId
                 AND a.ID = b.ID
                 AND b.CLE_ID=vParentLineId
                 AND b.MAJOR_VERSION=vVersion2
               ORDER BY a.LINE_NUMBER
            ;


        ELSE
             FOR c_nDifferent_line IN c_nDifferent_lines_1_latest LOOP
              l_object_name:=get_full_path_linenum(c_nDifferent_line.k_line_id);
              l_prompt :='';

              l_Object  :='NO_LINE';

              OPEN c;
              FETCH c INTO l_data2;
              CLOSE c;

              l_data1  :='';

              insert_comp_result(vHeader_id,vVersion1,vVersion2);

            END LOOP;

            FOR c_nDifferent_line IN c_nDifferent_lines_2_latest LOOP
              l_object_name :=get_full_path_linenum(c_nDifferent_line.k_line_id);
              l_prompt :='';

              l_Object  :='NO_LINE';

              OPEN c;
              FETCH c INTO l_data1;
              CLOSE c;

              l_data2  :='';

              insert_comp_result(vHeader_id,vVersion1,vVersion2);

            END LOOP;

             OPEN v_sub_nodes FOR
               SELECT a.ID K_LINE_ID
                FROM  OKC_K_LINES_B A, OKC_K_LINES_BH B
                WHERE a.DNZ_CHR_ID=vHeader_id
                  AND a.CLE_ID=vParentLineId
                  AND a.ID = b.ID
                  AND b.CLE_ID=vParentLineId
                  AND MAJOR_VERSION=vVersion2
                ORDER BY a.LINE_NUMBER
             ;

        End IF;

        LOOP

          L_Attribute_Object_Name :='OKE_K_LINES';
          l_Object  :='LINE';

          OPEN c;
          FETCH c INTO l_object_type;
          CLOSE c;

          IF L_Latest_Version >=vVersion1 THEN
		 FETCH v_sub_nodes INTO c_sub_node;
                 EXIT WHEN v_sub_nodes%NOTFOUND;

         	 nCurrent_line_id := c_sub_node;


 	         l_object_name :=get_full_path_linenum(nCurrent_line_id,vVersion1);

                 SELECT
			major_version,
			line_number,
			status,
			line_style,
			project_number,
			task_number,
			start_date,
			end_date,
			delivery_date,
			proposal_due_date,
			item_number,
			--item_description,
			line_description,
			customer_item_number,
			nsn_number,
			nsp_flag,
			line_quantity,
			uom_code,
			unit_price,
			undef_unit_price,
			line_value,
			undef_line_value,
			line_value_total,
			undef_line_value_total,
                        --line_value_copy,
			billable_flag,
			shippable_flag,
			subcontracted_flag,
			drop_shipped_flag,
			completed_flag,
			comments,
			target_date_definitize,
			discount_for_payment,
			cost_of_sale_rate,
			financial_ctrl_flag,
			definitized_flag,
			bill_undefinitized_flag,
			dcaa_audit_req_flag,
			cost_of_money,
			interim_rpt_req_flag,
			nte_warning_flag,
			c_ssr_flag,
			c_scs_flag,
			prepayment_amount,
			prepayment_percentage,
			progress_payment_flag,
			progress_payment_rate,
			progress_payment_liq_rate,
			line_liquidation_rate,
			boe_description,
			billing_method,
			total_estimated_cost,
			customer_percent_in_order,
			ceiling_cost,
			level_of_effort_hours,
			award_fee,
			base_fee,
			minimum_fee,
			maximum_fee,
			award_fee_pool_amount,
			fixed_fee,
			initial_fee,
			final_fee,
			fee_ajt_formula,
			target_cost,
			target_fee,
			target_price,
			ceiling_price,
			cost_overrun_share_ratio,
			cost_underrun_share_ratio,
			final_pft_ajt_formula,
			fixed_quantity,
			minimum_quantity,
			maximum_quantity,
			estimated_total_quantity,
			number_of_options,
			initial_price,
			revised_price,
			material_cost_index,
			labor_cost_index,
			date_of_price_redetermin,
			country_of_origin_code,
			export_flag,
			export_license_num,
			export_license_res,
			cop_required_flag,
			inspection_req_flag,
			subj_a133_flag,
			cfe_flag,
			customer_approval_req_flag,
			data_item_name,
			data_item_subtitle,
			cdrl_category,
			requiring_office,
			date_of_first_submission,
			frequency,
			copies_required


        INTO r_current_line_1
        FROM OKE_K_LINES_SECURE_HV
        WHERE K_LINE_ID=c_sub_node
        AND MAJOR_VERSION= vVersion1;

--dbms_output.put_line('In HISTORY subline id '||r_current_line_1.line_number);

	ELSE
		FETCH v_sub_nodes INTO c_sub_node;
                EXIT WHEN v_sub_nodes%NOTFOUND;
		nCurrent_line_id :=c_sub_node;

    	 l_object_name :=get_full_path_linenum(nCurrent_line_id);

	 	 SELECT
			major_version,
			line_number,
			status,
			line_style,
			project_number,
			task_number,
			start_date,
			end_date,
			delivery_date,
			proposal_due_date,
			item_number,
			--item_description,
			line_description,
			customer_item_number,
			nsn_number,
			nsp_flag,
			line_quantity,
			uom_code,
			unit_price,
			undef_unit_price,
			line_value,
			undef_line_value,
			line_value_total,
			undef_line_value_total,
			--line_value_copy,
			billable_flag,
			shippable_flag,
			subcontracted_flag,
			drop_shipped_flag,
			completed_flag,
			comments,
			target_date_definitize,
			discount_for_payment,
			cost_of_sale_rate,
			financial_ctrl_flag,
			definitized_flag,
			bill_undefinitized_flag,
			dcaa_audit_req_flag,
			cost_of_money,
			interim_rpt_req_flag,
			nte_warning_flag,
			c_ssr_flag,
			c_scs_flag,
			prepayment_amount,
			prepayment_percentage,
			progress_payment_flag,
			progress_payment_rate,
			progress_payment_liq_rate,
			line_liquidation_rate,
			boe_description,
			billing_method,
			total_estimated_cost,
			customer_percent_in_order,
			ceiling_cost,
			level_of_effort_hours,
			award_fee,
			base_fee,
			minimum_fee,
			maximum_fee,
			award_fee_pool_amount,
			fixed_fee,
			initial_fee,
			final_fee,
			fee_ajt_formula,
			target_cost,
			target_fee,
			target_price,
			ceiling_price,
			cost_overrun_share_ratio,
			cost_underrun_share_ratio,
			final_pft_ajt_formula,
			fixed_quantity,
			minimum_quantity,
			maximum_quantity,
			estimated_total_quantity,
			number_of_options,
			initial_price,
			revised_price,
			material_cost_index,
			labor_cost_index,
			date_of_price_redetermin,
			country_of_origin_code,
			export_flag,
			export_license_num,
			export_license_res,
			cop_required_flag,
			inspection_req_flag,
			subj_a133_flag,
			cfe_flag,
			customer_approval_req_flag,
			data_item_name,
			data_item_subtitle,
			cdrl_category,
			requiring_office,
			date_of_first_submission,
			frequency,
			copies_required


        INTO r_current_line_1
        FROM OKE_K_LINES_SECURE_V
        WHERE K_LINE_ID=c_sub_node;

        --dbms_output.put_line('In LATEST  subline id '||r_current_line_1.line_number);

	END IF;


        SELECT
			major_version,
			line_number,
			status,
			line_style,
			project_number,
			task_number,
			start_date,
			end_date,
			delivery_date,
			proposal_due_date,
			item_number,
			--item_description,
			line_description,
			customer_item_number,
			nsn_number,
			nsp_flag,
			line_quantity,
			uom_code,
			unit_price,
			undef_unit_price,
			line_value,
			undef_line_value,
			line_value_total,
			undef_line_value_total,
			--line_value_copy,
			billable_flag,
			shippable_flag,
			subcontracted_flag,
			drop_shipped_flag,
			completed_flag,
			comments,
			target_date_definitize,
			discount_for_payment,
			cost_of_sale_rate,
			financial_ctrl_flag,
			definitized_flag,
			bill_undefinitized_flag,
			dcaa_audit_req_flag,
			cost_of_money,
			interim_rpt_req_flag,
			nte_warning_flag,
			c_ssr_flag,
			c_scs_flag,
			prepayment_amount,
			prepayment_percentage,
			progress_payment_flag,
			progress_payment_rate,
			progress_payment_liq_rate,
			line_liquidation_rate,
			boe_description,
			billing_method,
			total_estimated_cost,
			customer_percent_in_order,
			ceiling_cost,
			level_of_effort_hours,
			award_fee,
			base_fee,
			minimum_fee,
			maximum_fee,
			award_fee_pool_amount,
			fixed_fee,
			initial_fee,
			final_fee,
			fee_ajt_formula,
			target_cost,
			target_fee,
			target_price,
			ceiling_price,
			cost_overrun_share_ratio,
			cost_underrun_share_ratio,
			final_pft_ajt_formula,
			fixed_quantity,
			minimum_quantity,
			maximum_quantity,
			estimated_total_quantity,
			number_of_options,
			initial_price,
			revised_price,
			material_cost_index,
			labor_cost_index,
			date_of_price_redetermin,
			country_of_origin_code,
			export_flag,
			export_license_num,
			export_license_res,
			cop_required_flag,
			inspection_req_flag,
			subj_a133_flag,
			cfe_flag,
			customer_approval_req_flag,
			data_item_name,
			data_item_subtitle,
			cdrl_category,
			requiring_office,
			date_of_first_submission,
			frequency,
			copies_required

        INTO r_current_line_2
        FROM OKE_K_LINES_SECURE_HV
        WHERE K_LINE_ID=c_sub_node
        AND MAJOR_VERSION= vVersion2;

        IF (r_current_line_1.line_number <> r_current_line_2.line_number )
            OR( NOT((r_current_line_1.line_number is null)and(r_current_line_2.line_number is null))
             AND ((r_current_line_1.line_number is null)or(r_current_line_2.line_number is null)))THEN
           l_prompt :='LINE_NUMBER';
           l_data1  :=r_current_line_1.line_number;
           l_data2  :=r_current_line_2.line_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.status  <>r_current_line_2.status )
	    OR( NOT((r_current_line_1.status is null)and(r_current_line_2.status is null))
             AND ((r_current_line_1.status is null)or(r_current_line_2.status is null)))THEN
           l_prompt :='STATUS';
           l_data1  :=r_current_line_1.status;
           l_data2  :=r_current_line_2.status;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.line_style <>r_current_line_2.line_style )
	     OR( NOT((r_current_line_1.line_style is null)and(r_current_line_2.line_style is null))
             AND ((r_current_line_1.line_style is null)or(r_current_line_2.line_style is null)))THEN
           l_prompt :='LINE_STYLE';
           l_data1  :=r_current_line_1.line_style;
           l_data2  :=r_current_line_2.line_style;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.project_number <>r_current_line_2.project_number )
             OR( NOT((r_current_line_1.project_number is null)and(r_current_line_2.project_number is null))
             AND ((r_current_line_1.project_number is null)or(r_current_line_2.project_number is null)))THEN
           l_prompt :='PROJECT_NUMBER';
           l_data1  :=r_current_line_1.project_number;
           l_data2  :=r_current_line_2.project_number;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.task_number <>r_current_line_2.task_number )
	     OR( NOT((r_current_line_1.task_number is null)and(r_current_line_2.task_number is null))
             AND ((r_current_line_1.task_number is null)or(r_current_line_2.task_number is null)))THEN
           l_prompt :='TASK_NUMBER';
           l_data1  :=r_current_line_1.task_number;
           l_data2  :=r_current_line_2.task_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.start_date <>r_current_line_2.start_date )
	     OR( NOT((r_current_line_1.start_date is null)and(r_current_line_2.start_date is null))
             AND ((r_current_line_1.start_date is null)or(r_current_line_2.start_date is null)))THEN
           l_prompt :='START_DATE';
           l_data1  :=r_current_line_1.start_date;
           l_data2  :=r_current_line_2.start_date;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.end_date <>r_current_line_2.end_date )
		 OR( NOT((r_current_line_1.end_date is null)and(r_current_line_2.end_date is null))
             AND ((r_current_line_1.end_date is null)or(r_current_line_2.end_date is null)))THEN
           l_prompt :='END_DATE';
           l_data1  :=r_current_line_1.end_date;
           l_data2  :=r_current_line_2.end_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.delivery_date <>r_current_line_2.delivery_date )
		 OR( NOT((r_current_line_1.delivery_date is null)and(r_current_line_2.delivery_date is null))
             AND ((r_current_line_1.delivery_date is null)or(r_current_line_2.delivery_date is null)))THEN
           l_prompt :='DELIVERY_DATE';
           l_data1  :=r_current_line_1.delivery_date;
           l_data2  :=r_current_line_2.delivery_date;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.proposal_due_date <>r_current_line_2.proposal_due_date )
		 OR( NOT((r_current_line_1.proposal_due_date is null)and(r_current_line_2.proposal_due_date is null))
             AND ((r_current_line_1.proposal_due_date is null)or(r_current_line_2.proposal_due_date is null)))THEN
           l_prompt :='PROPOSAL_DUE_DATE';
           l_data1  :=r_current_line_1.proposal_due_date;
           l_data2  :=r_current_line_2.proposal_due_date;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.item_number <>r_current_line_2.item_number )
		 OR( NOT((r_current_line_1.item_number is null)and(r_current_line_2.item_number is null))
             AND ((r_current_line_1.item_number is null)or(r_current_line_2.item_number is null)))THEN
           l_prompt :='ITEM_NUMBER';
           l_data1  :=r_current_line_1.item_number;
           l_data2  :=r_current_line_2.item_number;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
/*
        IF r_current_line_1.item_description <>r_current_line_2.item_description THEN
           l_prompt :='item_description';
           l_data1  :=r_current_line_1.item_description;
           l_data2  :=r_current_line_2.item_description;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
*/

        IF (r_current_line_1.line_description <>r_current_line_2.line_description )
		 OR( NOT((r_current_line_1.line_description is null)and(r_current_line_2.line_description is null))
             AND ((r_current_line_1.line_description is null)or(r_current_line_2.line_description is null)))THEN
           l_prompt :='LINE_DESCRIPTION';
           l_data1  :=r_current_line_1.line_description;
           l_data2  :=r_current_line_2.line_description;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_current_line_1.customer_item_number <>r_current_line_2.customer_item_number )
		 OR( NOT((r_current_line_1.customer_item_number is null)and(r_current_line_2.customer_item_number is null))
             AND ((r_current_line_1.customer_item_number is null)or(r_current_line_2.customer_item_number is null)))THEN
           l_prompt :='CUSTOMER_ITEM_NUMBER';
           l_data1  :=r_current_line_1.customer_item_number;
           l_data2  :=r_current_line_2.customer_item_number;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.nsn_number <>r_current_line_2.nsn_number )
		 OR( NOT((r_current_line_1.nsn_number is null)and(r_current_line_2.nsn_number is null))
             AND ((r_current_line_1.nsn_number is null)or(r_current_line_2.nsn_number is null)))THEN
           l_prompt :='NSN_NUMBER';
           l_data1  :=r_current_line_1.nsn_number;
           l_data2  :=r_current_line_2.nsn_number;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.nsp_flag = 'Y') AND (NVL(r_current_line_2.nsp_flag,' ')<>'Y'))
	 OR((r_current_line_2.nsp_flag = 'Y') AND (NVL(r_current_line_1.nsp_flag,' ')<>'Y'))THEN
           l_prompt :='NSP_YN';
           l_data1  :=r_current_line_1.nsp_flag;
           l_data2  :=r_current_line_2.nsp_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.line_quantity <>r_current_line_2.line_quantity )
		 OR( NOT((r_current_line_1.line_quantity is null)and(r_current_line_2.line_quantity is null))
             AND ((r_current_line_1.line_quantity is null)or(r_current_line_2.line_quantity is null)))THEN
           l_prompt :='LINE_QUANTITY';
           l_data1  :=r_current_line_1.line_quantity;
           l_data2  :=r_current_line_2.line_quantity;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.uom_code <>r_current_line_2.uom_code )
		 OR( NOT((r_current_line_1.uom_code is null)and(r_current_line_2.uom_code is null))
             AND ((r_current_line_1.uom_code is null)or(r_current_line_2.uom_code is null)))THEN
           l_prompt :='UOM_CODE';
           l_data1  :=r_current_line_1.uom_code;
           l_data2  :=r_current_line_2.uom_code;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.unit_price <>r_current_line_2.unit_price)
		 OR( NOT((r_current_line_1.unit_price is null)and(r_current_line_2.unit_price is null))
             AND ((r_current_line_1.unit_price is null)or(r_current_line_2.unit_price is null)))THEN
          l_prompt :='UNIT_PRICE';
          SET_PRICE_DIFF_DATA( r_current_line_1.unit_price, r_current_line_2.unit_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.undef_unit_price <>r_current_line_2.undef_unit_price )
		 OR( NOT((r_current_line_1.undef_unit_price is null)and(r_current_line_2.undef_unit_price is null))
             AND ((r_current_line_1.undef_unit_price is null)or(r_current_line_2.undef_unit_price is null)))THEN
          l_prompt :='UNDEF_UNIT_PRICE';
          SET_PRICE_DIFF_DATA( r_current_line_1.undef_unit_price, r_current_line_2.undef_unit_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.line_value_total <>r_current_line_2.line_value_total )
		 OR( NOT((r_current_line_1.line_value_total is null)and(r_current_line_2.line_value_total is null))
             AND ((r_current_line_1.line_value_total is null)or(r_current_line_2.line_value_total is null)))THEN
          l_prompt :='LINE_VALUE_TOTAL';
          SET_AMOUNT_DIFF_DATA( r_current_line_1.line_value_total, r_current_line_2.line_value_total );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.undef_line_value_total <>r_current_line_2.undef_line_value_total )
		 OR( NOT((r_current_line_1.undef_line_value_total is null)and(r_current_line_2.undef_line_value_total is null))
             AND ((r_current_line_1.undef_line_value_total is null)or(r_current_line_2.undef_line_value_total is null)))THEN
           l_prompt :='UNDEF_LINE_VALUE_TOTAL';
           SET_AMOUNT_DIFF_DATA( r_current_line_1.undef_line_value_total, r_current_line_2.undef_line_value_total );
           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
/*
        IF r_current_line_1.line_value_copy <>r_current_line_2.line_value_copy THEN
           l_prompt :='LINE_VALUE_COPY';
           l_data1  :=r_current_line_1.line_value_copy;
           l_data2  :=r_current_line_2.line_value_copy;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;
*/
        IF ((r_current_line_1.BILLABLE_FLAG = 'Y') AND (NVL(r_current_line_2.BILLABLE_FLAG,' ')<>'Y'))
	 OR((r_current_line_2.BILLABLE_FLAG = 'Y') AND (NVL(r_current_line_1.BILLABLE_FLAG,' ')<>'Y'))  THEN
           l_prompt :='BILLABLE_YN';
           l_data1  :=r_current_line_1.billable_flag;
           l_data2  :=r_current_line_2.billable_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.SHIPPABLE_FLAG = 'Y') AND (NVL(r_current_line_2.SHIPPABLE_FLAG,' ')<>'Y'))
	 OR((r_current_line_2.SHIPPABLE_FLAG = 'Y') AND (NVL(r_current_line_1.SHIPPABLE_FLAG,' ')<>'Y'))  THEN
           l_prompt :='SHIPPABLE_YN';
           l_data1  :=r_current_line_1.SHIPPABLE_FLAG;
           l_data2  :=r_current_line_2.SHIPPABLE_FLAG;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.subcontracted_flag = 'Y') AND (NVL(r_current_line_2.subcontracted_flag,' ')<>'Y'))
	 OR((r_current_line_2.subcontracted_flag = 'Y') AND (NVL(r_current_line_1.subcontracted_flag,' ')<>'Y'))THEN
           l_prompt :='SUBCONTRACTED_YN';
           l_data1  :=r_current_line_1.subcontracted_flag;
           l_data2  :=r_current_line_2.subcontracted_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.drop_shipped_flag = 'Y') AND (NVL(r_current_line_2.drop_shipped_flag,' ')<>'Y'))
	 OR((r_current_line_2.drop_shipped_flag = 'Y') AND (NVL(r_current_line_1.drop_shipped_flag,' ')<>'Y'))THEN
           l_prompt :='DROP_SHIPPED_YN';
           l_data1  :=r_current_line_1.drop_shipped_flag;
           l_data2  :=r_current_line_2.drop_shipped_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.COMPLETED_FLAG = 'Y') AND (NVL(r_current_line_2.COMPLETED_FLAG,' ')<>'Y'))
	 OR((r_current_line_2.COMPLETED_FLAG = 'Y') AND (NVL(r_current_line_1.COMPLETED_FLAG,' ')<>'Y')) THEN
           l_prompt :='COMPLETED_YN';
           l_data1  :=r_current_line_1.completed_flag;
           l_data2  :=r_current_line_2.completed_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.comments <>r_current_line_2.comments )
		OR( NOT((r_current_line_1.comments is null)and(r_current_line_2.comments is null))
             AND ((r_current_line_1.comments is null)or(r_current_line_2.comments is null)))THEN
           l_prompt :='COMMENTS';
           l_data1  :=r_current_line_1.comments;
           l_data2  :=r_current_line_2.comments;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_current_line_1.target_date_definitize <>r_current_line_2.target_date_definitize )
		 OR( NOT((r_current_line_1.target_date_definitize is null)and(r_current_line_2.target_date_definitize is null))
             AND ((r_current_line_1.target_date_definitize is null)or(r_current_line_2.target_date_definitize is null)))THEN
           l_prompt :='TARGET_DATE_DEFINITIZE';
           l_data1  :=r_current_line_1.target_date_definitize;
           l_data2  :=r_current_line_2.target_date_definitize;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.discount_for_payment <>r_current_line_2.discount_for_payment )
		 OR( NOT((r_current_line_1.discount_for_payment is null)and(r_current_line_2.discount_for_payment is null))
             AND ((r_current_line_1.discount_for_payment is null)or(r_current_line_2.discount_for_payment is null)))THEN
          l_prompt :='DISCOUNT_FOR_PAYMENT';
          l_data1  :=r_current_line_1.discount_for_payment;
          l_data2  :=r_current_line_2.discount_for_payment;
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.cost_of_sale_rate <>r_current_line_2.cost_of_sale_rate)
		 OR( NOT((r_current_line_1.cost_of_sale_rate is null)and(r_current_line_2.cost_of_sale_rate is null))
             AND ((r_current_line_1.cost_of_sale_rate is null)or(r_current_line_2.cost_of_sale_rate is null)))THEN
           l_prompt :='COST_OF_SALE_RATE';
           l_data1  :=r_current_line_1.cost_of_sale_rate;
           l_data2  :=r_current_line_2.cost_of_sale_rate;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.financial_ctrl_flag = 'Y') AND (NVL(r_current_line_2.financial_ctrl_flag,' ')<>'Y'))
	 OR((r_current_line_2.financial_ctrl_flag = 'Y') AND (NVL(r_current_line_1.financial_ctrl_flag,' ')<>'Y')) THEN
           l_prompt :='FINANCIAL_CTRL_YN';
           l_data1  :=r_current_line_1.financial_ctrl_flag;
           l_data2  :=r_current_line_2.financial_ctrl_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.definitized_flag = 'Y') AND (NVL(r_current_line_2.definitized_flag,' ')<>'Y'))
	 OR((r_current_line_2.definitized_flag = 'Y') AND (NVL(r_current_line_1.definitized_flag,' ')<>'Y')) THEN

           l_prompt :='DEFINITIZED_YN';
           l_data1  :=r_current_line_1.definitized_flag;
           l_data2  :=r_current_line_2.definitized_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.BILL_UNDEFINITIZED_FLAG = 'Y') AND (NVL(r_current_line_2.BILL_UNDEFINITIZED_FLAG,' ')<>'Y'))
	 OR((r_current_line_2.BILL_UNDEFINITIZED_FLAG = 'Y') AND (NVL(r_current_line_1.BILL_UNDEFINITIZED_FLAG,' ')<>'Y'))THEN

           l_prompt :='BILL_UNDEFINITIZED_YN';
           l_data1  :=r_current_line_1.bill_undefinitized_flag;
           l_data2  :=r_current_line_2.bill_undefinitized_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.DCAA_AUDIT_REQ_FLAG = 'Y') AND (NVL(r_current_line_2.DCAA_AUDIT_REQ_FLAG,' ')<>'Y'))
	 OR((r_current_line_2.DCAA_AUDIT_REQ_FLAG = 'Y') AND (NVL(r_current_line_1.DCAA_AUDIT_REQ_FLAG,' ')<>'Y'))THEN

           l_prompt :='DCAA_AUDIT_REQ_YN';
           l_data1  :=r_current_line_1.dcaa_audit_req_flag;
           l_data2  :=r_current_line_2.dcaa_audit_req_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.cost_of_money <>r_current_line_2.cost_of_money )
		 OR( NOT((r_current_line_1.cost_of_money is null)and(r_current_line_2.cost_of_money is null))
             AND ((r_current_line_1.cost_of_money is null)or(r_current_line_2.cost_of_money is null)))THEN
           l_prompt :='COST_OF_MONEY_YN';
           l_data1  :=r_current_line_1.cost_of_money;
           l_data2  :=r_current_line_2.cost_of_money;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.interim_rpt_req_flag = 'Y') AND (NVL(r_current_line_2.interim_rpt_req_flag,' ')<>'Y'))
	 OR((r_current_line_2.interim_rpt_req_flag = 'Y') AND (NVL(r_current_line_1.interim_rpt_req_flag,' ')<>'Y'))THEN

           l_prompt :='INTERIM_RPT_REQ_YN';
           l_data1  :=r_current_line_1.interim_rpt_req_flag;
           l_data2  :=r_current_line_2.interim_rpt_req_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.nte_warning_flag = 'Y') AND (NVL(r_current_line_2.nte_warning_flag,' ')<>'Y'))
	 OR((r_current_line_2.nte_warning_flag = 'Y') AND (NVL(r_current_line_1.nte_warning_flag,' ')<>'Y'))THEN

           l_prompt :='NTE_WARNING_YN';
           l_data1  :=r_current_line_1.nte_warning_flag;
           l_data2  :=r_current_line_2.nte_warning_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.c_ssr_flag = 'Y') AND (NVL(r_current_line_2.c_ssr_flag,' ')<>'Y'))
	 OR((r_current_line_2.c_ssr_flag = 'Y') AND (NVL(r_current_line_1.c_ssr_flag,' ')<>'Y')) THEN

           l_prompt :='C_SSR_YN';
           l_data1  :=r_current_line_1.c_ssr_flag;
           l_data2  :=r_current_line_2.c_ssr_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.c_scs_flag = 'Y') AND (NVL(r_current_line_2.c_scs_flag,' ')<>'Y'))
	 OR((r_current_line_2.c_scs_flag = 'Y') AND (NVL(r_current_line_1.c_scs_flag,' ')<>'Y'))THEN

           l_prompt :='C_SCS_YN';
           l_data1  :=r_current_line_1.c_scs_flag;
           l_data2  :=r_current_line_2.c_scs_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.prepayment_amount <>r_current_line_2.prepayment_amount )
		 OR( NOT((r_current_line_1.prepayment_amount is null)and(r_current_line_2.prepayment_amount is null))
             AND ((r_current_line_1.prepayment_amount is null)or(r_current_line_2.prepayment_amount is null)))THEN
           l_prompt :='PREPAYMENT_AMOUNT';
           SET_AMOUNT_DIFF_DATA( r_current_line_1.prepayment_amount, r_current_line_2.prepayment_amount );
           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.prepayment_percentage <>r_current_line_2.prepayment_percentage )
		 OR( NOT((r_current_line_1.prepayment_percentage is null)and(r_current_line_2.prepayment_percentage is null))
             AND ((r_current_line_1.prepayment_percentage is null)or(r_current_line_2.prepayment_percentage is null)))THEN
           l_prompt :='PREPAYMENT_PERCENTAGE';
           l_data1  :=r_current_line_1.prepayment_percentage;
           l_data2  :=r_current_line_2.prepayment_percentage;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.progress_payment_flag = 'Y') AND (NVL(r_current_line_2.progress_payment_flag,' ')<>'Y'))
	 OR((r_current_line_2.progress_payment_flag = 'Y') AND (NVL(r_current_line_1.progress_payment_flag,' ')<>'Y'))THEN

           l_prompt :='PROGRESS_PAYMENT_YN';
           l_data1  :=r_current_line_1.progress_payment_flag;
           l_data2  :=r_current_line_2.progress_payment_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.progress_payment_rate <>r_current_line_2.progress_payment_rate )
		 OR( NOT((r_current_line_1.progress_payment_rate is null)and(r_current_line_2.progress_payment_rate is null))
             AND ((r_current_line_1.progress_payment_rate is null)or(r_current_line_2.progress_payment_rate is null)))THEN
           l_prompt :='PROGRESS_PAYMENT_RATE';
           l_data1  :=r_current_line_1.progress_payment_rate;
           l_data2  :=r_current_line_2.progress_payment_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_current_line_1.progress_payment_liq_rate <>r_current_line_2.progress_payment_liq_rate )
		 OR( NOT((r_current_line_1.progress_payment_liq_rate is null)and(r_current_line_2.progress_payment_liq_rate is null))
             AND ((r_current_line_1.progress_payment_liq_rate is null)or(r_current_line_2.progress_payment_liq_rate is null)))THEN
           l_prompt :='PROGRESS_PAYMENT_LIQ_RATE';
           l_data1  :=r_current_line_1.progress_payment_liq_rate;
           l_data2  :=r_current_line_2.progress_payment_liq_rate;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.line_liquidation_rate <>r_current_line_2.line_liquidation_rate )
		 OR( NOT((r_current_line_1.line_liquidation_rate is null)and(r_current_line_1.line_liquidation_rate is null))
             AND ((r_current_line_1.line_liquidation_rate is null)or(r_current_line_1.line_liquidation_rate is null)))THEN
           l_prompt :='LINE_LIQUIDATION_RATE';
           l_data1  :=r_current_line_1.line_liquidation_rate;
           l_data2  :=r_current_line_2.line_liquidation_rate;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.boe_description <>r_current_line_2.boe_description )
		 OR( NOT((r_current_line_1.boe_description is null)and(r_current_line_2.boe_description is null))
             AND ((r_current_line_1.boe_description is null)or(r_current_line_2.boe_description is null)))THEN
           l_prompt :='BOE_DESCRIPTION';
           l_data1  :=r_current_line_1.boe_description;
           l_data2  :=r_current_line_2.boe_description;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.billing_method <>r_current_line_2.billing_method )
		 OR( NOT((r_current_line_1.billing_method is null)and(r_current_line_2.billing_method is null))
             AND ((r_current_line_1.billing_method is null)or(r_current_line_2.billing_method is null)))THEN
           l_prompt :='BILLING_METHOD';
           l_data1  :=r_current_line_1.billing_method;
           l_data2  :=r_current_line_2.billing_method;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

------
        IF (r_current_line_1.total_estimated_cost <>r_current_line_2.total_estimated_cost )
		 OR( NOT((r_current_line_1.total_estimated_cost is null)and(r_current_line_2.total_estimated_cost is null))
             AND ((r_current_line_1.total_estimated_cost is null)or(r_current_line_2.total_estimated_cost is null)))THEN
           l_prompt :='TOTAL_ESTIMATED_COST';
           l_data1  :=r_current_line_1.total_estimated_cost;
           l_data2  :=r_current_line_2.total_estimated_cost;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.customer_percent_in_order <>r_current_line_2.customer_percent_in_order )
		 OR( NOT((r_current_line_1.customer_percent_in_order is null)and(r_current_line_2.customer_percent_in_order is null))
             AND ((r_current_line_1.customer_percent_in_order is null)or(r_current_line_2.customer_percent_in_order is null)))THEN
           l_prompt :='CUSTOMER_PERCENT_IN_ORDER';
           l_data1  :=r_current_line_1.customer_percent_in_order;
           l_data2  :=r_current_line_2.customer_percent_in_order;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.ceiling_cost <>r_current_line_2.ceiling_cost )
		 OR( NOT((r_current_line_1.ceiling_cost is null)and(r_current_line_2.ceiling_cost is null))
             AND ((r_current_line_1.ceiling_cost is null)or(r_current_line_2.ceiling_cost is null)))THEN
           l_prompt :='CEILING_COST';
           l_data1  :=r_current_line_1.ceiling_cost;
           l_data2  :=r_current_line_2.ceiling_cost;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.level_of_effort_hours <>r_current_line_2.level_of_effort_hours )
		 OR( NOT((r_current_line_1.level_of_effort_hours is null)and(r_current_line_2.level_of_effort_hours is null))
             AND ((r_current_line_1.level_of_effort_hours is null)or(r_current_line_2.level_of_effort_hours is null)))THEN
           l_prompt :='LEVEL_OF_EFFORT_HOURS';
           l_data1  :=r_current_line_1.level_of_effort_hours;
           l_data2  :=r_current_line_2.level_of_effort_hours;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_current_line_1.award_fee <>r_current_line_2.award_fee )
		 OR( NOT((r_current_line_1.award_fee is null)and(r_current_line_2.award_fee is null))
             AND ((r_current_line_1.award_fee is null)or(r_current_line_2.award_fee is null)))THEN
           l_prompt :='AWARD_FEE';
           l_data1  :=r_current_line_1.award_fee;
           l_data2  :=r_current_line_2.award_fee;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.base_fee <>r_current_line_2.base_fee )
		 OR( NOT((r_current_line_1.base_fee is null)and(r_current_line_2.base_fee is null))
             AND ((r_current_line_1.base_fee is null)or(r_current_line_2.base_fee is null)))THEN
           l_prompt :='BASE_FEE';
           l_data1  :=r_current_line_1.base_fee;
           l_data2  :=r_current_line_2.base_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.minimum_fee <>r_current_line_2.minimum_fee  )
		 OR( NOT((r_current_line_1.minimum_fee is null)and(r_current_line_2.minimum_fee is null))
             AND ((r_current_line_1.minimum_fee is null)or(r_current_line_2.minimum_fee is null)))THEN
           l_prompt :='MINIMUM_FEE';
           l_data1  :=r_current_line_1.minimum_fee;
           l_data2  :=r_current_line_2.minimum_fee;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.maximum_fee <>r_current_line_2.maximum_fee )
		 OR( NOT((r_current_line_1.maximum_fee is null)and(r_current_line_2.maximum_fee is null))
             AND ((r_current_line_1.maximum_fee is null)or(r_current_line_2.maximum_fee is null)))THEN
           l_prompt :='MAXIMUM_FEE';
           l_data1  :=r_current_line_1.maximum_fee;
           l_data2  :=r_current_line_2.maximum_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.award_fee_pool_amount <>r_current_line_2.award_fee_pool_amount )
		 OR( NOT((r_current_line_1.award_fee_pool_amount is null)and(r_current_line_2.award_fee_pool_amount is null))
             AND ((r_current_line_1.award_fee_pool_amount is null)or(r_current_line_2.award_fee_pool_amount is null)))THEN
           l_prompt :='AWARD_FEE_POOL_AMOUNT';
           l_data1  :=r_current_line_1.award_fee_pool_amount;
           l_data2  :=r_current_line_2.award_fee_pool_amount;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.fixed_fee <>r_current_line_2.fixed_fee )
		 OR( NOT((r_current_line_1.fixed_fee is null)and(r_current_line_2.fixed_fee is null))
             AND ((r_current_line_1.fixed_fee is null)or(r_current_line_2.fixed_fee is null)))THEN
           l_prompt :='FIXED_FEE';
           l_data1  :=r_current_line_1.fixed_fee;
           l_data2  :=r_current_line_2.fixed_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.initial_fee <>r_current_line_2.initial_fee )
		 OR( NOT((r_current_line_1.initial_fee is null)and(r_current_line_2.initial_fee is null))
             AND ((r_current_line_1.initial_fee is null)or(r_current_line_2.initial_fee is null)))THEN
           l_prompt :='INITIAL_FEE';
           l_data1  :=r_current_line_1.initial_fee;
           l_data2  :=r_current_line_2.initial_fee;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.final_fee <>r_current_line_2.final_fee)
		   OR( NOT((r_current_line_1.final_fee is null)and(r_current_line_2.final_fee is null))
             AND ((r_current_line_1.final_fee is null)or(r_current_line_2.final_fee is null)))THEN
           l_prompt :='FINAL_FEE';
           l_data1  :=r_current_line_1.final_fee;
           l_data2  :=r_current_line_2.final_fee;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.fee_ajt_formula <>r_current_line_2.fee_ajt_formula)
		 OR( NOT((r_current_line_1.fee_ajt_formula is null)and(r_current_line_2.fee_ajt_formula is null))
             AND ((r_current_line_1.fee_ajt_formula is null)or(r_current_line_2.fee_ajt_formula is null)))THEN
           l_prompt :='FEE_AJT_FORMULA';
           l_data1  :=r_current_line_1.fee_ajt_formula;
           l_data2  :=r_current_line_2.fee_ajt_formula;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.target_cost <>r_current_line_2.target_cost )
		 OR( NOT((r_current_line_1.target_cost is null)and(r_current_line_2.target_cost is null))
             AND ((r_current_line_1.target_cost is null)or(r_current_line_2.target_cost is null)))THEN
           l_prompt :='TARGET_COST';
           l_data1  :=r_current_line_1.target_cost;
           l_data2  :=r_current_line_2.target_cost;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.target_fee <>r_current_line_2.target_fee)
		 OR( NOT((r_current_line_1.target_fee is null)and(r_current_line_2.target_fee is null))
             AND ((r_current_line_1.target_fee is null)or(r_current_line_2.target_fee is null)))THEN
           l_prompt :='TARGET_FEE';
           l_data1  :=r_current_line_1.target_fee;
           l_data2  :=r_current_line_2.target_fee;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.ceiling_price <>r_current_line_2.ceiling_price )
		 OR( NOT((r_current_line_1.ceiling_price is null)and(r_current_line_2.ceiling_price is null))
             AND ((r_current_line_1.ceiling_price is null)or(r_current_line_2.ceiling_price is null)))THEN
          l_prompt :='CEILING_PRICE';
          SET_PRICE_DIFF_DATA( r_current_line_1.ceiling_price, r_current_line_2.ceiling_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.target_price <>r_current_line_2.target_price)
		 OR( NOT((r_current_line_1.target_price is null)and(r_current_line_2.target_price is null))
             AND ((r_current_line_1.target_price is null)or(r_current_line_2.target_price is null)))THEN
          l_prompt :='TARGET_PRICE';
          SET_PRICE_DIFF_DATA( r_current_line_1.target_price, r_current_line_2.target_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.cost_overrun_share_ratio <>r_current_line_2.cost_overrun_share_ratio )
		 OR( NOT((r_current_line_1.cost_overrun_share_ratio is null)and(r_current_line_2.cost_overrun_share_ratio is null))
             AND ((r_current_line_1.cost_overrun_share_ratio is null)or(r_current_line_2.cost_overrun_share_ratio is null)))THEN
           l_prompt :='COST_OVERRUN_SHARE_RATIO';
           l_data1  :=r_current_line_1.cost_overrun_share_ratio;
           l_data2  :=r_current_line_2.cost_overrun_share_ratio;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.cost_underrun_share_ratio <>r_current_line_2.cost_underrun_share_ratio )
		 OR( NOT((r_current_line_1.cost_underrun_share_ratio is null)and(r_current_line_2.cost_underrun_share_ratio is null))
             AND ((r_current_line_1.cost_underrun_share_ratio is null)or(r_current_line_2.cost_underrun_share_ratio is null)))THEN
           l_prompt :='COST_UNDERRUN_SHARE_RATIO';
           l_data1  :=r_current_line_1.cost_underrun_share_ratio;
           l_data2  :=r_current_line_2.cost_underrun_share_ratio;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.final_pft_ajt_formula <>r_current_line_2.final_pft_ajt_formula )
		 OR( NOT((r_current_line_1.final_pft_ajt_formula is null)and(r_current_line_2.final_pft_ajt_formula is null))
             AND ((r_current_line_1.final_pft_ajt_formula is null)or(r_current_line_2.final_pft_ajt_formula is null)))THEN
           l_prompt :='FINAL_PFT_AJT_FORMULA';
           l_data1  :=r_current_line_1.final_pft_ajt_formula;
           l_data2  :=r_current_line_2.final_pft_ajt_formula;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.fixed_quantity <>r_current_line_2.fixed_quantity )
		 OR( NOT((r_current_line_1.fixed_quantity is null)and(r_current_line_2.fixed_quantity is null))
             AND ((r_current_line_1.fixed_quantity is null)or(r_current_line_2.fixed_quantity is null)))THEN
           l_prompt :='FIXED_QUANTITY';
           l_data1  :=r_current_line_1.fixed_quantity;
           l_data2  :=r_current_line_2.fixed_quantity;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF (r_current_line_1.minimum_quantity <>r_current_line_2.minimum_quantity )
		 OR( NOT((r_current_line_1.minimum_quantity is null)and(r_current_line_2.minimum_quantity is null))
             AND ((r_current_line_1.minimum_quantity is null)or(r_current_line_2.minimum_quantity is null)))THEN
           l_prompt :='MUNIMUM_QUANTITY';
           l_data1  :=r_current_line_1.minimum_quantity;
           l_data2  :=r_current_line_2.minimum_quantity;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.maximum_quantity <>r_current_line_2.maximum_quantity )
		 OR( NOT((r_current_line_1.maximum_quantity is null)and(r_current_line_2.maximum_quantity is null))
             AND ((r_current_line_1.maximum_quantity is null)or(r_current_line_2.maximum_quantity is null)))THEN
           l_prompt :='MAXIMUM_QUANTITY';
           l_data1  :=r_current_line_1.maximum_quantity;
           l_data2  :=r_current_line_2.maximum_quantity;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.estimated_total_quantity <>r_current_line_2.estimated_total_quantity )
		 OR( NOT((r_current_line_1.estimated_total_quantity is null)and(r_current_line_2.estimated_total_quantity is null))
             AND ((r_current_line_1.estimated_total_quantity is null)or(r_current_line_2.estimated_total_quantity is null)))THEN
           l_prompt :='ESTIMATED_TOTAL_QUANTITY';
           l_data1  :=r_current_line_1.estimated_total_quantity;
           l_data2  :=r_current_line_2.estimated_total_quantity;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.number_of_options <>r_current_line_2.number_of_options )
		 OR( NOT((r_current_line_1.number_of_options is null)and(r_current_line_2.number_of_options is null))
             AND ((r_current_line_1.number_of_options is null)or(r_current_line_2.number_of_options is null)))THEN
           l_prompt :='NUMBER_OF_OPTIONS';
           l_data1  :=r_current_line_1.number_of_options;
           l_data2  :=r_current_line_2.number_of_options;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.initial_price <>r_current_line_2.initial_price )
		 OR( NOT((r_current_line_1.initial_price is null)and(r_current_line_2.initial_price is null))
             AND ((r_current_line_1.initial_price is null)or(r_current_line_2.initial_price is null)))THEN
          l_prompt :='INITIAL_PRICE';
          SET_PRICE_DIFF_DATA( r_current_line_1.initial_price, r_current_line_2.initial_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.revised_price <>r_current_line_2.revised_price )
		 OR( NOT((r_current_line_1.revised_price is null)and(r_current_line_2.revised_price is null))
             AND ((r_current_line_1.revised_price is null)or(r_current_line_2.revised_price is null)))THEN
          l_prompt :='REVISED_PRICE';
          SET_PRICE_DIFF_DATA( r_current_line_1.revised_price, r_current_line_2.revised_price );
          insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.material_cost_index <>r_current_line_2.material_cost_index )
		 OR( NOT((r_current_line_1.material_cost_index is null)and(r_current_line_2.material_cost_index is null))
             AND ((r_current_line_1.material_cost_index is null)or(r_current_line_2.material_cost_index is null)))THEN
           l_prompt :='MATERIAL_COST_INDEX';
           l_data1  :=r_current_line_1.material_cost_index;
           l_data2  :=r_current_line_2.material_cost_index;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.labor_cost_index <>r_current_line_2.labor_cost_index )
		 OR( NOT((r_current_line_1.labor_cost_index is null)and(r_current_line_2.labor_cost_index is null))
             AND ((r_current_line_1.labor_cost_index is null)or(r_current_line_2.labor_cost_index is null)))THEN
           l_prompt :='LABOR_COST_INDEX';
           l_data1  :=r_current_line_1.labor_cost_index;
           l_data2  :=r_current_line_2.labor_cost_index;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.date_of_price_redetermin <>r_current_line_2.date_of_price_redetermin )
		 OR( NOT((r_current_line_1.date_of_price_redetermin is null)and(r_current_line_2.date_of_price_redetermin is null))
             AND ((r_current_line_1.date_of_price_redetermin is null)or(r_current_line_2.date_of_price_redetermin is null)))THEN
           l_prompt :='DATE_OF_PRICE_REDTERMIN';
           l_data1  :=r_current_line_1.date_of_price_redetermin;
           l_data2  :=r_current_line_2.date_of_price_redetermin;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.country_of_origin_code <>r_current_line_2.country_of_origin_code)
		 OR( NOT((r_current_line_1.country_of_origin_code is null)and(r_current_line_2.country_of_origin_code is null))
             AND ((r_current_line_1.country_of_origin_code is null)or(r_current_line_2.country_of_origin_code is null)))THEN
           l_prompt :='COUNTRY_OF_ORIGIN_CODE';
           l_data1  :=r_current_line_1.country_of_origin_code;
           l_data2  :=r_current_line_2.country_of_origin_code;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.export_flag = 'Y') AND (NVL(r_current_line_2.export_flag,' ')<>'Y'))
	 OR((r_current_line_2.export_flag = 'Y') AND (NVL(r_current_line_1.export_flag,' ')<>'Y'))THEN

           l_prompt :='EXPORT_YN';
           l_data1  :=r_current_line_1.export_flag;
           l_data2  :=r_current_line_2.export_flag;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.export_license_num <>r_current_line_2.export_license_num )
		 OR( NOT((r_current_line_1.export_license_num is null)and(r_current_line_2.export_license_num is null))
             AND ((r_current_line_1.export_license_num is null)or(r_current_line_2.export_license_num is null)))THEN
           l_prompt :='EXPORT_LICENSE_NUM';
           l_data1  :=r_current_line_1.export_license_num;
           l_data2  :=r_current_line_2.export_license_num;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.export_license_res <>r_current_line_2.export_license_res )
		 OR( NOT((r_current_line_1.export_license_res is null)and(r_current_line_2.export_license_res is null))
             AND ((r_current_line_1.export_license_res is null)or(r_current_line_2.export_license_res is null)))THEN
           l_prompt :='EXPORT_LICENSE_RES';
           l_data1  :=r_current_line_1.export_license_res;
           l_data2  :=r_current_line_2.export_license_res;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.cop_required_flag = 'Y') AND (NVL(r_current_line_2.cop_required_flag,' ')<>'Y'))
	 OR((r_current_line_2.cop_required_flag = 'Y') AND (NVL(r_current_line_1.cop_required_flag,' ')<>'Y'))THEN

           l_prompt :='COP_REQUIRED_YN';
           l_data1  :=r_current_line_1.cop_required_flag;
           l_data2  :=r_current_line_2.cop_required_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.inspection_req_flag = 'Y') AND (NVL(r_current_line_2.inspection_req_flag,' ')<>'Y'))
	 OR((r_current_line_2.inspection_req_flag = 'Y') AND (NVL(r_current_line_1.inspection_req_flag,' ')<>'Y'))THEN

           l_prompt :='INSPECTION_REQ_YN';
           l_data1  :=r_current_line_1.inspection_req_flag;
           l_data2  :=r_current_line_2.inspection_req_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.subj_a133_flag = 'Y') AND (NVL(r_current_line_2.subj_a133_flag,' ')<>'Y'))
	 OR((r_current_line_2.subj_a133_flag = 'Y') AND (NVL(r_current_line_1.subj_a133_flag,' ')<>'Y'))THEN
           l_prompt :='SUBJ_AL33_YN';
           l_data1  :=r_current_line_1.subj_a133_flag;
           l_data2  :=r_current_line_2.subj_a133_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;


        IF ((r_current_line_1.cfe_flag = 'Y') AND (NVL(r_current_line_2.cfe_flag,' ')<>'Y'))
	 OR((r_current_line_2.cfe_flag = 'Y') AND (NVL(r_current_line_1.cfe_flag,' ')<>'Y'))THEN

           l_prompt :='CFE_YN';
           l_data1  :=r_current_line_1.cfe_flag;
           l_data2  :=r_current_line_2.cfe_flag;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF ((r_current_line_1.customer_approval_req_flag = 'Y') AND (NVL(r_current_line_2.customer_approval_req_flag,' ')<>'Y'))
	 OR((r_current_line_2.customer_approval_req_flag = 'Y') AND (NVL(r_current_line_1.customer_approval_req_flag,' ')<>'Y'))THEN

           l_prompt :='CUSTOMER_APPROVAL_REQ_YN';
           l_data1  :=r_current_line_1.customer_approval_req_flag;
           l_data2  :=r_current_line_2.customer_approval_req_flag;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.data_item_name <>r_current_line_2.data_item_name )
		 OR( NOT((r_current_line_1.data_item_name is null)and(r_current_line_2.data_item_name is null))
             AND ((r_current_line_1.data_item_name is null)or(r_current_line_2.data_item_name is null)))THEN
           l_prompt :='DATA_ITEM_NAME';
           l_data1  :=r_current_line_1.data_item_name;
           l_data2  :=r_current_line_2.data_item_name;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.data_item_subtitle <>r_current_line_2.data_item_subtitle )
		 OR( NOT((r_current_line_1.data_item_subtitle is null)and(r_current_line_2.data_item_subtitle is null))
             AND ((r_current_line_1.data_item_subtitle is null)or(r_current_line_2.data_item_subtitle is null)))THEN
           l_prompt :='DATA_ITEM_SUBTITLE';
           l_data1  :=r_current_line_1.data_item_subtitle;
           l_data2  :=r_current_line_2.data_item_subtitle;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.cdrl_category <>r_current_line_2.cdrl_category )
		 OR( NOT((r_current_line_1.cdrl_category is null)and(r_current_line_2.cdrl_category is null))
             AND ((r_current_line_1.cdrl_category is null)or(r_current_line_2.cdrl_category is null)))THEN
           l_prompt :='CDRL_CATEGORY';
           l_data1  :=r_current_line_1.cdrl_category;
           l_data2  :=r_current_line_2.cdrl_category;

           insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.requiring_office <>r_current_line_2.requiring_office )
		 OR( NOT((r_current_line_1.requiring_office is null)and(r_current_line_2.requiring_office is null))
             AND ((r_current_line_1.requiring_office is null)or(r_current_line_2.requiring_office is null)))THEN
           l_prompt :='REQUIRING_OFFICE';
           l_data1  :=r_current_line_1.requiring_office;
           l_data2  :=r_current_line_2.requiring_office;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.date_of_first_submission <>r_current_line_2.date_of_first_submission )
		 OR( NOT((r_current_line_1.date_of_first_submission is null)and(r_current_line_2.date_of_first_submission is null))
             AND ((r_current_line_1.date_of_first_submission is null)or(r_current_line_2.date_of_first_submission is null)))THEN
           l_prompt :='DATE_OF_FIRST_SUBMISSION';
           l_data1  :=r_current_line_1.date_of_first_submission;
           l_data2  :=r_current_line_2.date_of_first_submission;
        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.frequency <>r_current_line_2.frequency )
		 OR( NOT((r_current_line_1.frequency is null)and(r_current_line_2.frequency is null))
             AND ((r_current_line_1.frequency is null)or(r_current_line_2.frequency is null)))THEN
           l_prompt :='FREQUENCY';
           l_data1  :=r_current_line_1.frequency;
           l_data2  :=r_current_line_2.frequency;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        IF (r_current_line_1.copies_required <>r_current_line_2.copies_required )
		 OR( NOT((r_current_line_1.copies_required is null)and(r_current_line_2.copies_required is null))
             AND ((r_current_line_1.copies_required is null)or(r_current_line_2.copies_required is null)))THEN
           l_prompt :='COPIES_REQUIRED';
           l_data1  :=r_current_line_1.copies_required;
           l_data2  :=r_current_line_2.copies_required;

        insert_comp_result(vHeader_id,vVersion1,vVersion2);
        END IF;

        comp_line_parties(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

        comp_line_terms(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

        comp_line_articles(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

        IF L_Latest_Version >= vVersion1 THEN
           SELECT count(*)
           INTO nDeliverables
      	   from oke_k_deliverables_bh
     	   where k_header_id=vHeader_id
      	   and k_line_id=nCurrent_line_id
           AND MAJOR_VERSION=vVersion1;

          SELECT count(*)
          INTO l_numOfSublines
          FROM OKC_K_LINES_BH
          WHERE DNZ_CHR_ID=vHeader_id
          AND CLE_ID=nCurrent_line_id
          AND MAJOR_VERSION=vVersion1;

        ELSE
           SELECT count(*)
           INTO nDeliverables
      	   from oke_k_deliverables_b
     	   where k_header_id=vHeader_id
      	   and k_line_id=nCurrent_line_id;

	  SELECT count(*)
          INTO l_numOfSublines
          FROM OKC_K_LINES_B
          WHERE DNZ_CHR_ID=vHeader_id
          AND CLE_ID=nCurrent_line_id;
        END IF;

        IF nDeliverables>0 THEN
	   comp_line_deliverables(vHeader_id,vVersion1, vVersion2,nCurrent_line_id);

        END IF;

        IF l_numOfSublines >0 THEN
           comp_subline(vHeader_id,vVersion1, vVersion2, nCurrent_line_id);
        END IF;

      END LOOP;

      CLOSE v_sub_nodes;

      EXCEPTION
            WHEN NO_DATA_FOUND THEN
            NULL;
	    WHEN OTHERS THEN
            NULL;

     END comp_subline;


     PROCEDURE comp_header_terms(vHeader_id IN NUMBER,vVersion_1 IN NUMBER,vVersion_2 IN NUMBER)
     IS

           CURSOR c_header_terms_1 IS
             SELECT
             major_version,
             term_code,
             term_value_pk1,
             term_value_pk2,
             term_name,
             term_value
             from oke_k_all_terms_hv
             where k_header_id=vHeader_id
             and k_line_id is null
             and major_version=vVersion_1;

           CURSOR c_header_terms_1_latest IS
             SELECT
             major_version,
             term_code,
             term_value_pk1,
             term_value_pk2,
             term_name,
             term_value
             from oke_k_all_terms_v
             where k_header_id=vHeader_id
             and k_line_id is null;

           CURSOR c_header_terms_2 IS
             SELECT
             major_version,
             term_code,
             term_value_pk1,
             term_value_pk2,
             term_name,
             term_value
             from oke_k_all_terms_hv
             where k_header_id=vHeader_id
             and k_line_id is null
             and major_version=vVersion_2;

           CURSOR c IS
     	     SELECT meaning
       	     FROM   fnd_lookup_values_vl
             WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
             AND    lookup_code = l_Object
             AND    view_application_id=777;

           vTermDifference NUMBER;
         BEGIN

              l_object_name :='';
              l_Object  :='TERM';

              OPEN c;
              FETCH c INTO l_object_type;
              CLOSE c;

	    IF L_Latest_Version >= vVersion_1 THEN
              FOR c_header_term_1 IN c_header_terms_1 LOOP
                  vTermDifference :=0;
                  FOR c_header_term_2 IN c_header_terms_2 LOOP
                      IF c_header_term_1.term_code = c_header_term_2.term_code
                         AND c_header_term_1.term_value_pk1 = c_header_term_2.term_value_pk1
                         AND c_header_term_1.term_value_pk2 =c_header_term_2.term_value_pk2
                      THEN vTermDifference := vTermDifference+1;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_header_term_1.term_name||'--'||c_header_term_1.term_value;
		     l_Object  :='NO_TERM';

                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_header_term_2 IN c_header_terms_2 LOOP
                  vTermDifference :=0;
                  FOR c_header_term_1 IN c_header_terms_1 LOOP
                      IF c_header_term_2.term_code = c_header_term_1.term_code
                         AND c_header_term_2.term_value_pk1 = c_header_term_1.term_value_pk1
                         AND c_header_term_2.term_value_pk2 =c_header_term_1.term_value_pk2
                      THEN vTermDifference :=vTermDifference+1 ;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_header_term_2.term_name||'--'||c_header_term_2.term_value;
		     l_Object  :='NO_TERM';

                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';

                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

             ELSE



	       FOR c_header_term_1 IN c_header_terms_1_latest LOOP
                  vTermDifference :=0;
                  FOR c_header_term_2 IN c_header_terms_2 LOOP

                      IF c_header_term_1.term_code = c_header_term_2.term_code
                         AND c_header_term_1.term_value_pk1 = c_header_term_2.term_value_pk1
                         AND c_header_term_1.term_value_pk2 = c_header_term_2.term_value_pk2
                      THEN



                      vTermDifference :=vTermDifference+1 ;
                      END IF;
                  END LOOP;


                  IF vTermDifference =0 THEN
                     l_prompt := c_header_term_1.term_name||'--'||c_header_term_1.term_value;
                     l_Object  :='NO_TERM';

                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';

                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_header_term_2 IN c_header_terms_2 LOOP
                  vTermDifference :=0;
                  FOR c_header_term_1 IN c_header_terms_1_latest LOOP
                      IF c_header_term_2.term_code = c_header_term_1.term_code
                         AND c_header_term_2.term_value_pk1 = c_header_term_1.term_value_pk1
                         AND c_header_term_2.term_value_pk2 =c_header_term_1.term_value_pk2
                      THEN vTermDifference := vTermDifference+1;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_header_term_2.term_name||'--'||c_header_term_2.term_value;
	             l_Object  :='NO_TERM';

                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';

                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

	     END IF;


	     EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                NULL;
		WHEN OTHERS THEN
		NULL;
     END comp_header_terms;


     PROCEDURE comp_line_terms(vHeader_id IN NUMBER,vVersion_1 IN NUMBER,vVersion_2 IN NUMBER,vLine_id IN NUMBER)
        IS

           CURSOR c_line_terms_1 IS
             SELECT
             major_version,
             term_code,
             term_value_pk1,
             term_value_pk2,
             term_name,
             term_value
             from oke_k_all_terms_hv
             where k_header_id=vHeader_id
             and k_line_id = vLine_id
             and major_version=vVersion_1;

           CURSOR c_line_terms_1_latest IS
             SELECT
             major_version,
             term_code,
             term_value_pk1,
             term_value_pk2,
             term_name,
             term_value
             from oke_k_all_terms_v
             where k_header_id=vHeader_id
             and k_line_id = vLine_id;

           CURSOR c_line_terms_2 IS
             SELECT
             major_version,
             term_code,
             term_value_pk1,
             term_value_pk2,
             term_name,
             term_value
             from oke_k_all_terms_hv
             where k_header_id=vHeader_id
             and k_line_id = vLine_id
             and major_version=vVersion_2;

           CURSOR c IS
     	     SELECT meaning
       	     FROM   fnd_lookup_values_vl
             WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
             AND    lookup_code = l_Object
             AND    view_application_id=777;

           vTermDifference NUMBER;
         BEGIN

              l_object_name :='';
              l_Object  :='TERM';

              OPEN c;
              FETCH c INTO l_object_type;
              CLOSE c;

	    IF L_Latest_Version >= vVersion_1 THEN
              FOR c_line_term_1 IN c_line_terms_1 LOOP
                  vTermDifference :=0;
                  FOR c_line_term_2 IN c_line_terms_2 LOOP
                      IF c_line_term_1.term_code = c_line_term_2.term_code
                         AND c_line_term_1.term_value_pk1 = c_line_term_2.term_value_pk1
                         AND c_line_term_1.term_value_pk2 =c_line_term_2.term_value_pk2
                      THEN vTermDifference := vTermDifference+1;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_line_term_1.term_name||'--'||c_line_term_1.term_value;
		     l_Object  :='NO_TERM';

                     l_object_name :=get_full_path_linenum(vLine_id,vVersion_1);

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_line_term_2 IN c_line_terms_2 LOOP
                  vTermDifference :=0;
                  FOR c_line_term_1 IN c_line_terms_1 LOOP
                      IF c_line_term_2.term_code = c_line_term_1.term_code
                         AND c_line_term_2.term_value_pk1 = c_line_term_1.term_value_pk1
                         AND c_line_term_2.term_value_pk2 =c_line_term_1.term_value_pk2
                      THEN vTermDifference :=vTermDifference+1 ;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_line_term_2.term_name||'--'||c_line_term_2.term_value;
		     l_Object  :='NO_TERM';

                     l_object_name :=get_full_path_linenum(vLine_id,vVersion_2);

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';

                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

             ELSE
	       FOR c_line_term_1 IN c_line_terms_1_latest LOOP
                  vTermDifference :=0;
                  FOR c_line_term_2 IN c_line_terms_2 LOOP
                      IF c_line_term_1.term_code = c_line_term_2.term_code
                         AND c_line_term_1.term_value_pk1 = c_line_term_2.term_value_pk1
                         AND c_line_term_1.term_value_pk2 = c_line_term_2.term_value_pk2
                      THEN vTermDifference :=vTermDifference+1 ;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_line_term_1.term_name||'--'||c_line_term_1.term_value;
                     l_Object  :='NO_TERM';

                     l_object_name :=get_full_path_linenum(vLine_id);

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';

                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_line_term_2 IN c_line_terms_2 LOOP
                  vTermDifference :=0;
                  FOR c_line_term_1 IN c_line_terms_1_latest LOOP
                      IF c_line_term_2.term_code = c_line_term_1.term_code
                         AND c_line_term_2.term_value_pk1 = c_line_term_1.term_value_pk1
                         AND c_line_term_2.term_value_pk2 =c_line_term_1.term_value_pk2
                      THEN vTermDifference := vTermDifference+1;
                      END IF;
                  END LOOP;
                  IF vTermDifference =0 THEN
                     l_prompt := c_line_term_2.term_name||'--'||c_line_term_2.term_value;
	             l_Object  :='NO_TERM';

                     l_object_name :=nvl(get_full_path_linenum(vLine_id,vVersion_2),'');

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';

                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

	     END IF;


	     EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                NULL;
		WHEN OTHERS THEN
		NULL;
     END comp_line_terms;




  PROCEDURE comp_header_parties(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER)
  IS

    CURSOR c_parties_1 IS
     SELECT
        role,
        cognomen,
        alias,
        object1_id1,
        object1_id2,
        jtot_object1_code
     FROM  okc_k_party_roles_hv
     WHERE chr_id=vHeader_id
     AND   dnz_chr_id=vHeader_id
     AND major_version=vVersion_1;


   CURSOR c_parties_2 IS
     SELECT
        role,
        cognomen,
        alias,
        object1_id1,
        object1_id2,
        jtot_object1_code
     FROM  okc_k_party_roles_hv
     WHERE chr_id=vHeader_id
     AND   dnz_chr_id=vHeader_id
     AND major_version=vVersion_2;


    /* Parties in the latest version  */

    CURSOR c_parties_latest IS
     SELECT
        role,
        cognomen,
        alias,
        object1_id1,
        object1_id2,
        jtot_object1_code
     FROM  okc_k_party_roles_v
     WHERE chr_id=vHeader_id
     AND   dnz_chr_id=vHeader_id;

    CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;

    l_PartyDifference NUMBER;
    l_name varchar(80);

    BEGIN



       l_object_name :='';
       l_object      :='PARTY';

       OPEN c;
       FETCH c INTO l_object_type;
       CLOSE c;

       IF L_Latest_Version >= vVersion_1 THEN
              FOR c_party_1 IN c_parties_1 LOOP
                  l_PartyDifference :=0;
                  FOR c_party_2 IN c_parties_2 LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1,' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_1.jtot_object1_code,c_party_1.object1_id1,c_party_1.object1_id2);

                     If (l_name is not null) Then
                         l_prompt := c_party_1.role||'--'||l_name;
                     ELSE
                         l_prompt := c_party_1.role;
                     End if;

                     l_Object  :='NO_PARTY';
                     l_object_name :='';


                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_party_2 IN c_parties_2 LOOP
                  l_PartyDifference :=0;
                  FOR c_party_1 IN c_parties_1 LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1,' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_2.jtot_object1_code,c_party_2.object1_id1,c_party_2.object1_id2);

                     IF(l_name IS NOT NULL) THEN
                         l_prompt := c_party_2.role||'--'||l_name;
                     ELSE
                         l_prompt := c_party_2.role;

                     END IF;

                     l_Object  :='NO_PARTY';
                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;


             ELSE
	      FOR c_party_1 IN c_parties_latest LOOP
                  l_PartyDifference :=0;
                  FOR c_party_2 IN c_parties_2 LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1, ' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_1.jtot_object1_code,c_party_1.object1_id1,c_party_1.object1_id2);
                     IF(l_name is not null) THEN
                        l_prompt := c_party_1.role||'--'||l_name;
                     ELSE
                        l_prompt := c_party_1.role;
                     END IF;

		     l_Object  :='NO_PARTY';

                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_party_2 IN c_parties_2 LOOP
                  l_PartyDifference :=0;
                  FOR c_party_1 IN c_parties_latest LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1, ' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_2.jtot_object1_code,c_party_2.object1_id1,c_party_2.object1_id2);
                     IF(l_name is not null) THEN
                          l_prompt := c_party_2.role||'--'||l_name;
                     ELSE
                          l_prompt := c_party_2.role;
                     END IF;

		     l_Object  :='NO_PARTY';
                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

	     END IF;

	     EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                NULL;
		WHEN OTHERS THEN
		NULL;

  END comp_header_parties;


  PROCEDURE comp_line_parties(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER,vLine_id NUMBER)
  IS

    CURSOR c_parties_1 IS
     SELECT
        role,
        cognomen,
        alias,
        object1_id1,
        object1_id2,
        jtot_object1_code
     FROM  okc_k_party_roles_hv
     WHERE dnz_chr_id=vHeader_id
     AND cle_id = vLine_id
     AND major_version=vVersion_1;


   CURSOR c_parties_2 IS
     SELECT
        role,
        cognomen,
        alias,
        object1_id1,
        object1_id2,
        jtot_object1_code
     FROM  okc_k_party_roles_hv
     WHERE dnz_chr_id=vHeader_id
     AND cle_id = vLine_id
     AND major_version=vVersion_2;


    /* Parties in the latest version  */

    CURSOR c_parties_latest IS
     SELECT
        role,
        cognomen,
        alias,
        object1_id1,
        object1_id2,
        jtot_object1_code
     FROM  okc_k_party_roles_v
     WHERE dnz_chr_id=vHeader_id
     AND cle_id = vLine_id;

    CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;

    l_PartyDifference NUMBER;
    l_name varchar(80);

    BEGIN

       l_object_name :='';
       l_object      :='PARTY';

       OPEN c;
       FETCH c INTO l_object_type;
       CLOSE c;

       IF L_Latest_Version >= vVersion_1 THEN
              FOR c_party_1 IN c_parties_1 LOOP
                  l_PartyDifference :=0;
                  FOR c_party_2 IN c_parties_2 LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1,' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_1.jtot_object1_code,c_party_1.object1_id1,c_party_1.object1_id2);
                     IF(l_name is not null) THEN
                        l_prompt := c_party_1.role||'--'||l_name;
                     ELSE
                        l_prompt := c_party_1.role;
                     END IF;

		     l_Object  :='NO_PARTY';

                     l_object_name :=nvl(get_full_path_linenum(vLine_id,vVersion_1),'');

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_party_2 IN c_parties_2 LOOP
                  l_PartyDifference :=0;
                  FOR c_party_1 IN c_parties_1 LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1,' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_2.jtot_object1_code,c_party_2.object1_id1,c_party_2.object1_id2);
                     IF(l_name is not null)THEN
                        l_prompt := c_party_2.role||'--'||l_name;
                     ELSE
                        l_prompt := c_party_2.role;
                     END IF;

		     l_Object  :='NO_PARTY';

                     l_object_name :=nvl(get_full_path_linenum(vLine_id,vVersion_2),'');

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

             ELSE

               FOR c_party_1 IN c_parties_latest LOOP
                  l_PartyDifference :=0;
                  FOR c_party_2 IN c_parties_2 LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1,' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_1.jtot_object1_code,c_party_1.object1_id1,c_party_1.object1_id2);

                     if(l_name is not null)then
                        l_prompt := c_party_1.role||'--'||l_name;
                     else
                        l_prompt := c_party_1.role;
                     end if;

		     l_Object  :='NO_PARTY';


                     l_object_name :=nvl(get_full_path_linenum(vLine_id),'');

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

              FOR c_party_2 IN c_parties_2 LOOP
                  l_PartyDifference :=0;
                  FOR c_party_1 IN c_parties_latest LOOP
                      IF c_party_1.role = c_party_2.role
                         AND nvl(c_party_1.object1_id1,' ') = nvl(c_party_2.object1_id1,' ')
                      THEN l_PartyDifference := l_PartyDifference+1;
                      END IF;
                  END LOOP;
                  IF l_PartyDifference =0 THEN

                     l_name := OKC_UTIL.get_name_from_jtfv(c_party_2.jtot_object1_code,c_party_2.object1_id1,c_party_2.object1_id2);
                     if(l_name is not null)then
                         l_prompt := c_party_2.role||'--'||l_name;
                     else
                         l_prompt := c_party_2.role;
                     end if;

		     l_Object  :='NO_PARTY';

                     l_object_name :=nvl(get_full_path_linenum(vLine_id),'');

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;
              END LOOP;

	     END IF;

	     EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                NULL;
		WHEN OTHERS THEN
		NULL;

  END comp_line_parties;



  PROCEDURE comp_line_deliverables(vHeader_id IN NUMBER,vVersion1 IN NUMBER, vVersion2 IN NUMBER,vCurrentLineId IN NUMBER)
  IS
    TYPE r_deliverable IS RECORD(
 	deliverable_num                 oke_k_deliverables_vlh.deliverable_num%TYPE,
        item_id                         oke_k_deliverables_vlh.item_id%TYPE,
        description                     oke_k_deliverables_vlh.description%TYPE,
        project_number                  oke_k_deliverables_vlh.project_number%TYPE,
	project_name                    oke_k_deliverables_vlh.project_name%TYPE,
	task_number                     oke_k_deliverables_vlh.task_number%TYPE,
        --task_name                     oke_k_deliverables_vlh.task_name%TYPE,
	delivery_date                   oke_k_deliverables_vlh.delivery_date%TYPE,
	status_code                     oke_k_deliverables_vlh.status_code%TYPE,
	parent_deliverable_id           oke_k_deliverables_vlh.parent_deliverable_id%TYPE,
	direction                       oke_k_deliverables_vlh.direction%TYPE,
	ship_to_org_id                	oke_k_deliverables_vlh.ship_to_org_id %TYPE,
	ship_to_location_id  		oke_k_deliverables_vlh.ship_to_location_id%TYPE,
	ship_from_org_id 		oke_k_deliverables_vlh.ship_from_org_id%TYPE,
	ship_from_location_id  		oke_k_deliverables_vlh.ship_from_location_id%TYPE,
	start_date                      oke_k_deliverables_vlh.start_date%TYPE,
	end_date                        oke_k_deliverables_vlh.end_date%TYPE,
	need_by_date 			oke_k_deliverables_vlh.need_by_date%TYPE,
	priority_code                   oke_k_deliverables_vlh.priority_code%TYPE,
	currency_code   		oke_k_deliverables_vlh.currency_code%TYPE,
	unit_price   			oke_k_deliverables_vlh.unit_price%TYPE,
	uom_code  			oke_k_deliverables_vlh.uom_code%TYPE,
	quantity  			oke_k_deliverables_vlh.quantity%TYPE,
	country_of_origin_code   	oke_k_deliverables_vlh.country_of_origin_code%TYPE,
	subcontracted_flag   		oke_k_deliverables_vlh.subcontracted_flag%TYPE,
	dependency_flag    		oke_k_deliverables_vlh.dependency_flag%TYPE,
	billable_flag      		oke_k_deliverables_vlh.billable_flag%TYPE,
	billing_event_id                oke_k_deliverables_vlh.billing_event_id%TYPE,
	drop_shipped_flag               oke_k_deliverables_vlh.drop_shipped_flag%TYPE,
	completed_flag                  oke_k_deliverables_vlh.completed_flag%TYPE,
	available_for_ship_flag    	oke_k_deliverables_vlh.available_for_ship_flag%TYPE,
	create_demand    		oke_k_deliverables_vlh.create_demand%TYPE,
	ready_to_bill    		oke_k_deliverables_vlh.ready_to_bill%TYPE,
	ready_to_procure    		oke_k_deliverables_vlh.ready_to_procure%TYPE,
	mps_transaction_id              oke_k_deliverables_vlh.mps_transaction_id%TYPE,
	shipping_request_id             oke_k_deliverables_vlh.shipping_request_id%TYPE,
	unit_number 			oke_k_deliverables_vlh.unit_number%TYPE,
	ndb_schedule_designator    	oke_k_deliverables_vlh.ndb_schedule_designator%TYPE,
	shippable_flag    		oke_k_deliverables_vlh.shippable_flag%TYPE,
	cfe_req_flag			oke_k_deliverables_vlh.cfe_req_flag%TYPE,
	inspection_req_flag		oke_k_deliverables_vlh.inspection_req_flag%TYPE,
	interim_rpt_req_flag		oke_k_deliverables_vlh.interim_rpt_req_flag%TYPE,
	lot_applies_flag		oke_k_deliverables_vlh.lot_applies_flag%TYPE,
	customer_approval_req_flag	oke_k_deliverables_vlh.customer_approval_req_flag%TYPE,
	date_of_first_submission	oke_k_deliverables_vlh.date_of_first_submission%TYPE,
	frequency			oke_k_deliverables_vlh.frequency%TYPE,
	acq_doc_number			oke_k_deliverables_vlh.acq_doc_number%TYPE,
	submission_flag 		oke_k_deliverables_vlh.submission_flag%TYPE,
	data_item_subtitle		oke_k_deliverables_vlh.data_item_subtitle%TYPE,
	total_num_of_copies		oke_k_deliverables_vlh.total_num_of_copies%TYPE,
	cdrl_category			oke_k_deliverables_vlh.cdrl_category%TYPE,
	data_item_name			oke_k_deliverables_vlh.data_item_name%TYPE,
	export_flag			oke_k_deliverables_vlh.export_flag%TYPE,
	export_license_num		oke_k_deliverables_vlh.export_license_num%TYPE,
	export_license_res		oke_k_deliverables_vlh.export_license_res%TYPE,
	comments			oke_k_deliverables_vlh.comments%TYPE,
	sfwt_flag			oke_k_deliverables_vlh.sfwt_flag%TYPE,
	status				oke_k_deliverables_vlh.status%TYPE,
	volume				oke_k_deliverables_vlh.volume%TYPE,
	volume_uom_code		        oke_k_deliverables_vlh.volume_uom_code%TYPE,
	weight				oke_k_deliverables_vlh.weight%TYPE,
	weight_uom_code			oke_k_deliverables_vlh.weight_uom_code%TYPE,
	expenditure_type		oke_k_deliverables_vlh.expenditure_type%TYPE,
	expenditure_organization_id	oke_k_deliverables_vlh.expenditure_organization_id%TYPE,
	expenditure_item_date		oke_k_deliverables_vlh.expenditure_item_date%TYPE,
	destination_type_code		oke_k_deliverables_vlh.destination_type_code%TYPE,
	rate_type			oke_k_deliverables_vlh.rate_type%TYPE,
	rate_date			oke_k_deliverables_vlh.rate_date%TYPE,
	exchange_rate			oke_k_deliverables_vlh.exchange_rate%TYPE,
	expected_shipment_date    	oke_k_deliverables_vlh.expected_shipment_date%TYPE,
	initiate_shipment_date   	oke_k_deliverables_vlh.initiate_shipment_date%TYPE,
	promised_shipment_date   	oke_k_deliverables_vlh.promised_shipment_date%TYPE

	);

    	r_deliverable_1 r_deliverable;
    	r_deliverable_2 r_deliverable;

        type c_deliverables_1 is ref cursor;

        v_deliverables_1 c_deliverables_1;
	current_deliverable_1 oke_k_deliverables_vlh.deliverable_id%TYPE;
        current_deliverable_num oke_k_deliverables_vlh.deliverable_num%TYPE;

        CURSOR c_deliverables_2 IS
         SELECT deliverable_id
         from oke_k_deliverables_bh
         where k_header_id=vHeader_id
         and k_line_id=vCurrentLineId
         and major_version=vVersion2
         ORDER BY deliverable_num;

        --current_deliverable_2 oke_k_deliverable_vlh.deliverable_id%TYPE;

        vDifference NUMBER;
        l_buy_or_sell varchar2(10);


        CURSOR c IS
            SELECT meaning
            FROM   fnd_lookup_values_vl
            WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
            AND    lookup_code = l_Object
            AND    view_application_id=777;

        CURSOR c_item(v_item_id number) IS
	    SELECT name
            FROM OKE_SYSTEM_ITEMS_V
            WHERE id1=v_item_id;

        CURSOR c_buy_or_sell(v_header_id NUMBER)IS
            SELECT buy_or_sell
            FROM OKE_K_HEADERS_V
            WHERE k_header_id = v_header_id;

        cursor c1(p_id number) is
  	select name from hr_organization_units
  	where organization_id = p_id;

  	cursor c2 (p_id number) is
  	select name from okx_vendors_v
  	where id1 = p_id;

  	cursor c3(p_id number) is
  	select name from okx_customer_accounts_v
  	where id1 = p_id;

  	cursor c4(p_id number) is
  	select name from okx_vendors_v
 	where id1 = p_id;

  	cursor c5(p_id number) is
  	select name from okx_organization_defs_v
  	where id1 = p_id;

  	cursor c6(p_id number) is
  	select name from okx_customer_accounts_v
  	where id1 = p_id;

        --inbound ship to
        CURSOR c_ship_to_location_in(v_ship_to_location_id number)IS
            SELECT name
            from OKX_LOCATIONS_V
            where id1 = v_ship_to_location_id;

        --outbound ship to
        CURSOR c_ship_to_location_out(v_ship_to_location_id number)IS
            SELECT name
            from OKE_CUST_SITE_USES_V
            where id1 = v_ship_to_location_id
            and site_use_code = 'SHIP_TO';

        --outbound ship from
        CURSOR c_ship_from_location_out(v_ship_from_location_id number)IS
            SELECT name
            from okx_locations_v
            where id1 = v_ship_from_location_id;

        --sell/inbound ship from
        CURSOR c_ship_from_location_si(v_ship_from_location_id number)IS
            SELECT name
            from OKE_CUST_SITE_USES_V
            where id1 = v_ship_from_location_id
            and site_use_code = 'SHIP_TO';

        --buy/inbound ship from
        CURSOR c_ship_from_location_bi(v_ship_from_location_id number)IS
            SELECT name
            from OKE_VENDOR_SITES_V
            where id1 = v_ship_from_location_id;

        CURSOR c_expenditure_org(v_org_id number) IS
            SELECT name
            FROM pa_organizations_expend_v
            WHERE organization_id=v_org_id;
     l_api_name     CONSTANT VARCHAR2(30) := 'comp_line_deliverables';
  BEGIN

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Begin comparing line deliverables ...');
   END IF;

     L_Attribute_Object_Name :='OKE_K_DELIVERABLES';

    --v_object_name :=get_full_path_linenum(vCurrentLineId,vVersion1);

     l_Object  :='DELIVERABLE';

     OPEN c;
     FETCH c INTO l_object_type;
     CLOSE c;

    IF L_Latest_Version >= vVersion1 THEN
     OPEN v_deliverables_1 FOR
      	 SELECT deliverable_id
      	 from oke_k_deliverables_bh
     	 where k_header_id=vHeader_id
      	 and k_line_id=vCurrentLineId
         and major_version=vVersion1
         ORDER BY deliverable_num;
    ELSE
     OPEN v_deliverables_1 FOR
      	 SELECT deliverable_id
      	 from oke_k_deliverables_b
     	 where k_header_id=vHeader_id
      	 and k_line_id=vCurrentLineId
         ORDER BY deliverable_num;
    END IF;

    LOOP
      FETCH v_deliverables_1 INTO current_deliverable_1;
      EXIT WHEN v_deliverables_1%NOTFOUND;


        vDifference :=0;
        FOR c_deliverable_2 IN c_deliverables_2 LOOP

            IF current_deliverable_1 = c_deliverable_2.deliverable_id 	THEN
               vDifference :=vDifference +1;
            END IF;

        END LOOP;


        IF L_Latest_Version >= vVersion1 THEN

           SELECT deliverable_num
           INTO current_deliverable_num
           from oke_k_deliverables_bh
           where k_header_id=vHeader_id
           and k_line_id=vCurrentLineId
           and major_version=vVersion1
           and deliverable_id=current_deliverable_1;

           l_object_name :=get_full_path_linenum(vCurrentLineId,vVersion1) ||'*'||current_deliverable_num;
        ELSE

	   SELECT deliverable_num
           INTO current_deliverable_num
           from oke_k_deliverables_b
           where k_header_id=vHeader_id
           and k_line_id=vCurrentLineId
           and deliverable_id=current_deliverable_1;

           l_object_name :=get_full_path_linenum(vCurrentLineId) ||'*'||current_deliverable_num;
        END IF;



        IF vDifference = 0 THEN
           l_prompt := '';

	   l_Object  :='NO_DELIVERABLE';

           OPEN c;
           FETCH c INTO l_data2;
           CLOSE c;


           l_data1  := '';

           insert_comp_result(vHeader_id,vVersion1,vVersion2);


        ELSE


           IF L_Latest_Version >= vVersion1 THEN

              l_object_name :=get_full_path_linenum(vCurrentLineId,vVersion1)||'*'||current_deliverable_num;
              SELECT
		deliverable_num,
		item_id,
                description,
		project_number,
		project_name,
		task_number,
		delivery_date,
		status_code,
		parent_deliverable_id,
		direction,
		ship_to_org_id,
		ship_to_location_id,
		ship_from_org_id,
		ship_from_location_id,
		start_date,
		end_date,
		need_by_date,
		priority_code,
		currency_code,
		unit_price,
		uom_code,
		quantity,
		country_of_origin_code,
		subcontracted_flag,
		dependency_flag,
		billable_flag,
		billing_event_id,
		drop_shipped_flag,
		completed_flag,
		available_for_ship_flag,
		create_demand,
		ready_to_bill,
		ready_to_procure,
		mps_transaction_id,
		shipping_request_id,
		unit_number,
		ndb_schedule_designator,
		shippable_flag,
		cfe_req_flag,
		inspection_req_flag,
		interim_rpt_req_flag,
		lot_applies_flag,
		customer_approval_req_flag,
		date_of_first_submission,
		frequency,
		acq_doc_number,
		submission_flag,
		data_item_subtitle,
		total_num_of_copies,
		cdrl_category,
		data_item_name,
		export_flag,
		export_license_num,
		export_license_res,
		comments,
		sfwt_flag,
		status,
		volume,
		volume_uom_code,
		weight,
		weight_uom_code,
		expenditure_type,
		expenditure_organization_id,
		expenditure_item_date,
		destination_type_code,
		rate_type,
		rate_date,
		exchange_rate,
		expected_shipment_date,
		initiate_shipment_date,
		promised_shipment_date


           INTO r_deliverable_1
           FROM oke_k_deliverables_vlh
           WHERE deliverable_id=current_deliverable_1
           AND major_version=vVersion1;


        ELSE
	   l_object_name :=get_full_path_linenum(vCurrentLineId)||'*'||current_deliverable_num;

           SELECT
		deliverable_num,
		item_id,
                description,
                project_number,
		project_name,
		task_number,
		delivery_date,
		status_code,
		parent_deliverable_id,
		direction,
		ship_to_org_id,
		ship_to_location_id,
		ship_from_org_id,
		ship_from_location_id,
		start_date,
		end_date,
		need_by_date,
		priority_code,
		currency_code,
		unit_price,
		uom_code,
		quantity,
		country_of_origin_code,
		subcontracted_flag,
		dependency_flag,
		billable_flag,
		billing_event_id,
		drop_shipped_flag,
		completed_flag,
		available_for_ship_flag,
		create_demand,
		ready_to_bill,
		ready_to_procure,
		mps_transaction_id,
		shipping_request_id,
		unit_number,
		ndb_schedule_designator,
		shippable_flag,
		cfe_req_flag,
		inspection_req_flag,
		interim_rpt_req_flag,
		lot_applies_flag,
		customer_approval_req_flag,
		date_of_first_submission,
		frequency,
		acq_doc_number,
		submission_flag,
		data_item_subtitle,
		total_num_of_copies,
		cdrl_category,
		data_item_name,
		export_flag,
		export_license_num,
		export_license_res,
		comments,
		sfwt_flag,
		status,
		volume,
		volume_uom_code,
		weight,
		weight_uom_code,
		expenditure_type,
		expenditure_organization_id,
		expenditure_item_date,
		destination_type_code,
		rate_type,
		rate_date,
		exchange_rate,
		expected_shipment_date,
		initiate_shipment_date,
		promised_shipment_date

           INTO r_deliverable_1
           FROM oke_k_deliverables_vl
           WHERE deliverable_id=current_deliverable_1
           AND major_version=vVersion1;


        END IF;

           SELECT
		deliverable_num,
		item_id,
                description,
                project_number,
		project_name,
		task_number,
		delivery_date,
		status_code,
		parent_deliverable_id,
		direction,
		ship_to_org_id,
		ship_to_location_id,
		ship_from_org_id,
		ship_from_location_id,
		start_date,
		end_date,
		need_by_date,
		priority_code,
		currency_code,
		unit_price,
		uom_code,
		quantity,
		country_of_origin_code,
		subcontracted_flag,
		dependency_flag,
		billable_flag,
		billing_event_id,
		drop_shipped_flag,
		completed_flag,
		available_for_ship_flag,
		create_demand,
		ready_to_bill,
		ready_to_procure,
		mps_transaction_id,
		shipping_request_id,
		unit_number,
		ndb_schedule_designator,
		shippable_flag,
		cfe_req_flag,
		inspection_req_flag,
		interim_rpt_req_flag,
		lot_applies_flag,
		customer_approval_req_flag,
		date_of_first_submission,
		frequency,
		acq_doc_number,
		submission_flag,
		data_item_subtitle,
		total_num_of_copies,
		cdrl_category,
		data_item_name,
		export_flag,
		export_license_num,
		export_license_res,
		comments,
		sfwt_flag,
		status,
		volume,
		volume_uom_code,
		weight,
		weight_uom_code,
		expenditure_type,
		expenditure_organization_id,
		expenditure_item_date,
		destination_type_code,
		rate_type,
		rate_date,
		exchange_rate,
		expected_shipment_date,
		initiate_shipment_date,
		promised_shipment_date


           INTO r_deliverable_2
           FROM oke_k_deliverables_vlh
           WHERE deliverable_id=current_deliverable_1
           AND major_version=vVersion2;

	   IF (r_deliverable_1.deliverable_num <> r_deliverable_2.deliverable_num)
		 OR( NOT((  r_deliverable_1.deliverable_num is null)and(r_deliverable_2.deliverable_num is null))
             AND (( r_deliverable_1.deliverable_num is null)or(r_deliverable_2.deliverable_num is null)))THEN
              l_prompt :='DELIVERABLE_NUM';
              l_data1  :=r_deliverable_1.deliverable_num;
              l_data2  :=r_deliverable_2.deliverable_num;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	   IF nvl(r_deliverable_1.item_id,0) <> nvl(r_deliverable_2.item_id,0) THEN
		-- OR( NOT((  r_deliverable_1.item_id is null)and(r_deliverable_2.item_id is null))
             --AND (( r_deliverable_1.item_id is null)or(r_deliverable_2.item_id is null)))THEN
              l_prompt :='ITEM';

              OPEN c_item(r_deliverable_1.item_id);
              FETCH c_item INTO l_data1;
              CLOSE c_item;

              OPEN c_item(r_deliverable_2.item_id);
              FETCH c_item INTO l_data2;
              CLOSE c_item;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

           IF nvl(r_deliverable_1.description,' ') <> nvl(r_deliverable_2.description, ' ')THEN
              l_prompt :='DESCRIPTION';
              l_data1  :=r_deliverable_1.description;
              l_data2  :=r_deliverable_2.description;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
           END IF;

           IF (r_deliverable_1.project_number <> r_deliverable_2.project_number)
		 OR( NOT((  r_deliverable_1.project_number is null)and(r_deliverable_2.project_number is null))
             AND (( r_deliverable_1.project_number is null)or(r_deliverable_2.project_number is null)))THEN
              l_prompt :='PROJECT_NUMBER';
              l_data1  :=r_deliverable_1.project_number;
              l_data2  :=r_deliverable_2.project_number;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

           IF (r_deliverable_1.delivery_date <>r_deliverable_2.delivery_date)
		 OR( NOT((  r_deliverable_1.delivery_date is null)and(r_deliverable_2.delivery_date is null))
             AND (( r_deliverable_1.delivery_date is null)or(r_deliverable_2.delivery_date is null)))THEN
              l_prompt :='DELIVERY_DATE';
              l_data1  :=r_deliverable_1.delivery_date;
              l_data2  :=r_deliverable_2.delivery_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;
/*
	    IF (r_deliverable_1.status_code <> r_deliverable_2.status_code)
		 OR( NOT((  r_deliverable_1.status_code is null)and(r_deliverable_2.status_code is null))
             AND (( r_deliverable_1.status_code is null)or(r_deliverable_2.status_code is null)))THEN
              l_prompt :='STATUS_CODE';
              l_data1  :=r_deliverable_1.status_code;
              l_data2  :=r_deliverable_2.status_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;
*/

            IF (r_deliverable_1.parent_deliverable_id <> r_deliverable_2.parent_deliverable_id)
		 OR( NOT((  r_deliverable_1.parent_deliverable_id is null)and(r_deliverable_2.parent_deliverable_id is null))
             AND (( r_deliverable_1.parent_deliverable_id is null)or(r_deliverable_2.parent_deliverable_id is null)))THEN
              l_prompt :='PARENT_DELIVERABLE_ID';
              l_data1  :=r_deliverable_1.parent_deliverable_id;
              l_data2  :=r_deliverable_2.parent_deliverable_id;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.direction <> r_deliverable_2.direction)
		 OR( NOT((  r_deliverable_1.direction is null)and(r_deliverable_2.direction is null))
             AND (( r_deliverable_1.direction is null)or(r_deliverable_2.direction is null)))THEN
              l_prompt :='DIRECTION';
              l_data1  :=r_deliverable_1.direction;
              l_data2  :=r_deliverable_2.direction;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.task_number <>r_deliverable_2.task_number)
		 OR( NOT((  r_deliverable_1.task_number is null)and(r_deliverable_2.task_number is null))
             AND (( r_deliverable_1.task_number is null)or(r_deliverable_2.task_number is null)))THEN
              l_prompt :='TASK_NUMBER';
              l_data1  :=r_deliverable_1.task_number;
              l_data2  :=r_deliverable_2.task_number;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF nvl(r_deliverable_1.ship_to_org_id,0) <>nvl(r_deliverable_2.ship_to_org_id,0)  THEN
              l_prompt :='SHIP_TO_ORG';

               IF (nvl(r_deliverable_1.direction,' ')= 'IN') THEN

                 OPEN c5(r_deliverable_1.ship_to_org_id);
                 FETCH c5 INTO  l_data1;
                 CLOSE c5;

                 OPEN c5(r_deliverable_2.ship_to_org_id);
                 FETCH c5 INTO  l_data2;
                 CLOSE c5;

               ELSE

                 OPEN  c6(r_deliverable_1.ship_to_org_id);
                 FETCH c6 INTO  l_data1;
                 CLOSE c6;

                 OPEN c6(r_deliverable_2.ship_to_org_id);
                 FETCH c6 INTO  l_data2;
                 CLOSE c6;
            END IF;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF nvl(r_deliverable_1.ship_to_location_id,0) <> nvl(r_deliverable_2.ship_to_location_id,0) THEN

              l_prompt :='SHIP_TO_LOCATION';

              IF (nvl(r_deliverable_1.direction,' ')= 'OUT') THEN
                    OPEN c_ship_to_location_out(r_deliverable_1.ship_to_location_id);
                    FETCH c_ship_to_location_out INTO  l_data1;
                    CLOSE c_ship_to_location_out;

                    OPEN c_ship_to_location_out(r_deliverable_2.ship_to_location_id);
                    FETCH c_ship_to_location_out INTO  l_data2;
                    CLOSE c_ship_to_location_out;


              ELSE
                     OPEN c_ship_to_location_in(r_deliverable_1.ship_to_location_id);
                     FETCH c_ship_to_location_in INTO  l_data1;
                     CLOSE c_ship_to_location_in;

                     OPEN c_ship_to_location_in(r_deliverable_2.ship_to_location_id);
                     FETCH c_ship_to_location_in INTO  l_data2;
                     CLOSE c_ship_to_location_in;


              END IF;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

           IF nvl(r_deliverable_1.ship_from_org_id,0) <> nvl(r_deliverable_2.ship_from_org_id,0 ) THEN
              l_prompt :='SHIP_FROM_ORG';

              OPEN c_buy_or_sell(vHeader_id);
              FETCH c_buy_or_sell INTO l_buy_or_sell;
              CLOSE c_buy_or_sell;

              IF (nvl(r_deliverable_1.direction,' ')= 'IN') THEN
                 IF  l_buy_or_sell = 'B' then
                     OPEN c4(r_deliverable_1.ship_from_org_id);
                     FETCH c4 INTO  l_data1;
                     CLOSE c4;

                     OPEN c4(r_deliverable_2.ship_from_org_id);
                     FETCH c4 INTO  l_data2;
                     CLOSE c4;

                 ELSE
                     OPEN c6(r_deliverable_1.ship_from_org_id);
                     FETCH c6 INTO  l_data1;
                     CLOSE c6;

                     OPEN c6(r_deliverable_2.ship_from_org_id);
                     FETCH c6 INTO  l_data2;
                     CLOSE c6;

                 END IF;
               ELSE
                     OPEN c5(r_deliverable_1.ship_from_org_id);
                     FETCH c5 INTO  l_data1;
                     CLOSE c5;

                     OPEN c5(r_deliverable_2.ship_from_org_id);
                     FETCH c5 INTO  l_data2;
                     CLOSE c5;
               END IF;

               insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF NVL(r_deliverable_1.ship_from_location_id,0) <> NVL(r_deliverable_2.ship_from_location_id,0 )THEN
              l_prompt :='SHIP_FROM_LOCATION';

              OPEN c_buy_or_sell(vHeader_id);
              FETCH c_buy_or_sell INTO l_buy_or_sell;
              CLOSE c_buy_or_sell;

              IF (nvl(r_deliverable_1.direction,' ')= 'OUT')THEN
                    OPEN c_ship_from_location_out(r_deliverable_1.ship_from_location_id);
                    FETCH c_ship_from_location_out INTO  l_data1;
                    CLOSE c_ship_from_location_out;

                    OPEN c_ship_from_location_out(r_deliverable_2.ship_from_location_id);
                    FETCH c_ship_from_location_out INTO  l_data2;
                    CLOSE c_ship_from_location_out;

              ELSE
                    IF  (l_buy_or_sell='S')  THEN
                        OPEN c_ship_from_location_si(r_deliverable_1.ship_from_location_id);
                        FETCH c_ship_from_location_si INTO  l_data1;
                        CLOSE c_ship_from_location_si;

                        OPEN c_ship_from_location_si(r_deliverable_2.ship_from_location_id);
                        FETCH c_ship_from_location_si INTO  l_data2;
                        CLOSE c_ship_from_location_si;

                    ELSE
                        OPEN c_ship_from_location_bi(r_deliverable_1.ship_from_location_id);
                        FETCH c_ship_from_location_bi INTO  l_data1;
                        CLOSE c_ship_from_location_bi;

                        OPEN c_ship_from_location_bi(r_deliverable_2.ship_from_location_id);
                        FETCH c_ship_from_location_bi INTO  l_data2;
                        CLOSE c_ship_from_location_bi;
                    END IF;
               END IF;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.need_by_date <>r_deliverable_2.need_by_date)
 		 OR( NOT((  r_deliverable_1.need_by_date is null)and(r_deliverable_2.need_by_date is null))
             AND (( r_deliverable_1.need_by_date is null)or(r_deliverable_2.need_by_date is null)))THEN
              l_prompt :='NEED_BY_DATE';
              l_data1  :=r_deliverable_1.need_by_date;
              l_data2  :=r_deliverable_2.need_by_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;



           IF (r_deliverable_1.currency_code <>r_deliverable_2.currency_code)
		 OR( NOT((  r_deliverable_1.delivery_date is null)and(r_deliverable_2.delivery_date is null))
             AND (( r_deliverable_1.delivery_date is null)or(r_deliverable_2.delivery_date is null)))THEN
              l_prompt :='CURRENCY_CODE';
              l_data1  :=r_deliverable_1.currency_code;
              l_data2  :=r_deliverable_2.currency_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.unit_price <>r_deliverable_2.unit_price)
		 OR( NOT((  r_deliverable_1.unit_price is null)and(r_deliverable_2.unit_price is null))
             AND (( r_deliverable_1.unit_price is null)or(r_deliverable_2.unit_price is null)))THEN
              l_prompt :='UNIT_PRICE';
              l_data1  :=r_deliverable_1.unit_price;
              l_data2  :=r_deliverable_2.unit_price;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.uom_code <>r_deliverable_2.uom_code)
		 OR( NOT((  r_deliverable_1.uom_code is null)and(r_deliverable_2.uom_code is null))
             AND (( r_deliverable_1.uom_code is null)or(r_deliverable_2.uom_code is null)))THEN
              l_prompt :='UOM_CODE';
              l_data1  :=r_deliverable_1.uom_code;
              l_data2  :=r_deliverable_2.uom_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;


            IF nvl(r_deliverable_1.quantity,0) <>nvl(r_deliverable_2.quantity,0) THEN
              l_prompt :='QUANTITY';
              l_data1  :=r_deliverable_1.quantity;
              l_data2  :=r_deliverable_2.quantity;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.country_of_origin_code <>r_deliverable_2.country_of_origin_code)
		 OR( NOT((  r_deliverable_1.country_of_origin_code is null)and(r_deliverable_2.country_of_origin_code is null))
             AND (( r_deliverable_1.country_of_origin_code is null)or(r_deliverable_2.country_of_origin_code is null)))THEN
              l_prompt :='COUNTRY_OF_ORIGIN_CODE';
              l_data1  :=r_deliverable_1.country_of_origin_code;
              l_data2  :=r_deliverable_2.country_of_origin_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF ((r_deliverable_1.subcontracted_flag = 'Y') AND (NVL(r_deliverable_2.subcontracted_flag ,' ')<>'Y'))
             OR((r_deliverable_2.subcontracted_flag = 'Y') AND (NVL(r_deliverable_1.subcontracted_flag ,' ')<>'Y'))THEN
              l_prompt :='SUBCONTRACTED_FLAG';
              l_data1  :=r_deliverable_1.subcontracted_flag;
              l_data2  :=r_deliverable_2.subcontracted_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF ((r_deliverable_1.dependency_flag = 'Y') AND (NVL(r_deliverable_2.dependency_flag ,' ')<>'Y'))
             OR((r_deliverable_2.dependency_flag = 'Y') AND (NVL(r_deliverable_1.dependency_flag ,' ')<>'Y')) THEN
              l_prompt :='DEPENDENCY_FLAG';
              l_data1  :=r_deliverable_1.dependency_flag;
              l_data2  :=r_deliverable_2.dependency_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF ((r_deliverable_1.billable_flag = 'Y') AND (NVL(r_deliverable_2.billable_flag,' ')<>'Y'))
             OR((r_deliverable_2.billable_flag = 'Y') AND (NVL(r_deliverable_1.billable_flag,' ')<>'Y')) THEN
              l_prompt :='BILLABLE_FLAG';
              l_data1  :=r_deliverable_1.billable_flag;
              l_data2  :=r_deliverable_2.billable_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF ((r_deliverable_1.shippable_flag = 'Y') AND (NVL(r_deliverable_2.shippable_flag,' ')<>'Y'))
             OR((r_deliverable_2.shippable_flag = 'Y') AND (NVL(r_deliverable_1.shippable_flag,' ')<>'Y')) THEN
              l_prompt :='SHIPPABLE_FLAG';
              l_data1  :=r_deliverable_1.shippable_flag;
              l_data2  :=r_deliverable_2.shippable_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.start_date <> r_deliverable_2.start_date)
		 OR( NOT((  r_deliverable_1.start_date is null)and(r_deliverable_2.start_date is null))
             AND (( r_deliverable_1.start_date is null)or(r_deliverable_2.start_date is null)))THEN
              l_prompt :='START_DATE';
              l_data1  :=r_deliverable_1.start_date;
              l_data2  :=r_deliverable_2.start_date;
              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.end_date <> r_deliverable_2.end_date)
		 OR( NOT((  r_deliverable_1.end_date is null)and(r_deliverable_2.end_date is null))
             AND (( r_deliverable_1.end_date is null)or(r_deliverable_2.end_date is null)))THEN
              l_prompt :='END_DATE';
              l_data1  :=r_deliverable_1.end_date;
              l_data2  :=r_deliverable_2.end_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.priority_code <> r_deliverable_2.priority_code)
		 OR( NOT((  r_deliverable_1.priority_code is null)and(r_deliverable_2.priority_code is null))
             AND (( r_deliverable_1.priority_code is null)or(r_deliverable_2.priority_code is null)))THEN
              l_prompt :='PRIORITY_CODE';
              l_data1  :=r_deliverable_1.priority_code;
              l_data2  :=r_deliverable_2.priority_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF ((r_deliverable_1.available_for_ship_flag = 'Y') AND (NVL(r_deliverable_2.available_for_ship_flag ,' ')<>'Y'))
             OR((r_deliverable_2.available_for_ship_flag = 'Y') AND (NVL(r_deliverable_1.available_for_ship_flag ,' ')<>'Y'))THEN
              l_prompt :='AVAILABLE_FOR_SHIP_FLAG';
              l_data1  :=r_deliverable_1.available_for_ship_flag;
              l_data2  :=r_deliverable_2.available_for_ship_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.create_demand <>r_deliverable_2.create_demand)
		 OR( NOT((  r_deliverable_1.create_demand is null)and(r_deliverable_2.create_demand is null))
             AND (( r_deliverable_1.create_demand is null)or(r_deliverable_2.create_demand is null)))THEN
              l_prompt :='CREATE_DEMAND';
              l_data1  :=r_deliverable_1.create_demand;
              l_data2  :=r_deliverable_2.create_demand;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

             IF (r_deliverable_1.ready_to_bill <>r_deliverable_2.ready_to_bill )
		 OR( NOT((  r_deliverable_1.ready_to_bill is null)and(r_deliverable_2.ready_to_bill is null))
             AND (( r_deliverable_1.ready_to_bill is null)or(r_deliverable_2.ready_to_bill is null)))THEN
              l_prompt :='READY_TO_BILL';
              l_data1  :=r_deliverable_1.ready_to_bill;
              l_data2  :=r_deliverable_2.ready_to_bill;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.ready_to_procure <>r_deliverable_2.ready_to_procure )
		 OR( NOT((  r_deliverable_1.ready_to_procure is null)and(r_deliverable_2.ready_to_procure is null))
             AND (( r_deliverable_1.ready_to_procure is null)or(r_deliverable_2.ready_to_procure is null)))THEN
              l_prompt :='READY_TO_PROCURE';
              l_data1  :=r_deliverable_1.ready_to_procure;
              l_data2  :=r_deliverable_2.ready_to_procure;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF ((r_deliverable_1.drop_shipped_flag = 'Y') AND (NVL(r_deliverable_2.drop_shipped_flag ,' ')<>'Y'))
             OR((r_deliverable_2.drop_shipped_flag = 'Y') AND (NVL(r_deliverable_1.drop_shipped_flag ,' ')<>'Y'))THEN
              l_prompt :='DROP_SHIPPED_FLAG';
              l_data1  :=r_deliverable_1.drop_shipped_flag;
              l_data2  :=r_deliverable_2.drop_shipped_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.billing_event_id <> r_deliverable_2.billing_event_id)
		 OR( NOT((  r_deliverable_1.billing_event_id is null)and(r_deliverable_2.billing_event_id is null))
             AND (( r_deliverable_1.billing_event_id is null)or(r_deliverable_2.billing_event_id is null)))THEN
              l_prompt :='BILLING_EVENT_ID';
              l_data1  :=r_deliverable_1.billing_event_id;
              l_data2  :=r_deliverable_2.billing_event_id;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.ndb_schedule_designator <>r_deliverable_2.ndb_schedule_designator)
		 OR( NOT((  r_deliverable_1.ndb_schedule_designator is null)and(r_deliverable_2.ndb_schedule_designator is null))
             AND (( r_deliverable_1.ndb_schedule_designator is null)or(r_deliverable_2.ndb_schedule_designator is null)))THEN
              l_prompt :='NDB_SCHEDULE_DESIGNATOR';
              l_data1  :=r_deliverable_1.ndb_schedule_designator;
              l_data2  :=r_deliverable_2.ndb_schedule_designator;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.expected_shipment_date <>r_deliverable_2.expected_shipment_date)
		 OR( NOT((  r_deliverable_1.expected_shipment_date is null)and(r_deliverable_2.expected_shipment_date is null))
             AND (( r_deliverable_1.expected_shipment_date is null)or(r_deliverable_2.expected_shipment_date is null)))THEN
              l_prompt :='EXPECTED_SHIPMENT_DATE';
              l_data1  :=r_deliverable_1.expected_shipment_date;
              l_data2  :=r_deliverable_2.expected_shipment_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

/*
            IF (r_deliverable_1.initiate_shipment_date <> r_deliverable_2.initiate_shipment_date)
		 OR( NOT((  r_deliverable_1.initiate_shipment_date is null)and(r_deliverable_2.initiate_shipment_date is null))
             AND (( r_deliverable_1.initiate_shipment_date is null)or(r_deliverable_2.initiate_shipment_date is null)))THEN
              l_prompt :='INITIATE_SHIPMENT_DATE';
              l_data1  :=r_deliverable_1.initiate_shipment_date;
              l_data2  :=r_deliverable_2.initiate_shipment_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;
*/
            IF (r_deliverable_1.promised_shipment_date <>r_deliverable_2.promised_shipment_date)
		 OR( NOT((  r_deliverable_1.promised_shipment_date is null)and(r_deliverable_2.promised_shipment_date is null))
             AND (( r_deliverable_1.promised_shipment_date is null)or(r_deliverable_2.promised_shipment_date is null)))THEN
              l_prompt :='PROMISED_SHIPMENT_DATE';
              l_data1  :=r_deliverable_1.promised_shipment_date;
              l_data2  :=r_deliverable_2.promised_shipment_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.comments <>r_deliverable_2.comments )
		 OR( NOT((  r_deliverable_1.comments is null)and(r_deliverable_2.comments is null))
             AND (( r_deliverable_1.comments is null)or(r_deliverable_2.comments is null)))THEN
              l_prompt :='COMMENTS';
              l_data1  :=r_deliverable_1.comments;
              l_data2  :=r_deliverable_2.comments;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	   IF ((r_deliverable_1.completed_flag = 'Y') AND (NVL(r_deliverable_2.completed_flag ,' ')<>'Y'))
            OR((r_deliverable_2.completed_flag = 'Y') AND (NVL(r_deliverable_1.completed_flag ,' ')<>'Y')) THEN
              l_prompt :='COMPLETED_FLAG';
              l_data1  :=r_deliverable_1.completed_flag;
              l_data2  :=r_deliverable_2.completed_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.mps_transaction_id <>r_deliverable_2.mps_transaction_id )
		 OR( NOT((  r_deliverable_1.mps_transaction_id is null)and(r_deliverable_2.mps_transaction_id is null))
             AND (( r_deliverable_1.mps_transaction_id is null)or(r_deliverable_2.mps_transaction_id is null)))THEN
              l_prompt :='MPS_TRANSACTION_ID';
              l_data1  :=r_deliverable_1.mps_transaction_id;
              l_data2  :=r_deliverable_2.mps_transaction_id;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.shipping_request_id <>r_deliverable_2.shipping_request_id )
		 OR( NOT((  r_deliverable_1.shipping_request_id is null)and(r_deliverable_2.shipping_request_id is null))
             AND (( r_deliverable_1.shipping_request_id is null)or(r_deliverable_2.shipping_request_id is null)))THEN
              l_prompt :='SHIPPING_REQUEST_ID';
              l_data1  :=r_deliverable_1.shipping_request_id;
              l_data2  :=r_deliverable_2.shipping_request_id;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF ((r_deliverable_1.inspection_req_flag = 'Y') AND (NVL(r_deliverable_2.inspection_req_flag ,' ')<>'Y'))
             OR((r_deliverable_2.inspection_req_flag = 'Y') AND (NVL(r_deliverable_1.inspection_req_flag ,' ')<>'Y')) THEN
              l_prompt :='INSPECTION_REQ_FLAG';
              l_data1  :=r_deliverable_1.inspection_req_flag;
              l_data2  :=r_deliverable_2.inspection_req_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF ((r_deliverable_1.interim_rpt_req_flag = 'Y') AND (NVL(r_deliverable_2.interim_rpt_req_flag ,' ')<>'Y'))
             OR((r_deliverable_2.interim_rpt_req_flag = 'Y') AND (NVL(r_deliverable_1.interim_rpt_req_flag ,' ')<>'Y')) THEN
              l_prompt :='INTERIM_RPT_REQ_FLAG';
              l_data1  :=r_deliverable_1.interim_rpt_req_flag;
              l_data2  :=r_deliverable_2.interim_rpt_req_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF ((r_deliverable_1.customer_approval_req_flag = 'Y') AND (NVL(r_deliverable_2.customer_approval_req_flag ,' ')<>'Y'))
             OR((r_deliverable_2.customer_approval_req_flag = 'Y') AND (NVL(r_deliverable_1.customer_approval_req_flag ,' ')<>'Y'))THEN
              l_prompt :='CUSTOMER_APPROVAL_REQ_FLAG';
              l_data1  :=r_deliverable_1.customer_approval_req_flag;
              l_data2  :=r_deliverable_2.customer_approval_req_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.date_of_first_submission <>r_deliverable_2.date_of_first_submission )
		 OR( NOT((  r_deliverable_1.date_of_first_submission is null)and(r_deliverable_2.date_of_first_submission is null))
             AND (( r_deliverable_1.date_of_first_submission is null)or(r_deliverable_2.date_of_first_submission is null)))THEN
              l_prompt :='DATE_OF_FIRST_SUBMISSION';
              l_data1  :=r_deliverable_1.date_of_first_submission;
              l_data2  :=r_deliverable_2.date_of_first_submission;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.frequency <>r_deliverable_2.frequency )
		 OR( NOT((  r_deliverable_1.frequency is null)and(r_deliverable_2.frequency is null))
             AND (( r_deliverable_1.frequency is null)or(r_deliverable_2.frequency is null)))THEN
              l_prompt :='FREQUENCY';
              l_data1  :=r_deliverable_1.frequency;
              l_data2  :=r_deliverable_2.frequency;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF ((r_deliverable_1.submission_flag = 'Y') AND (NVL(r_deliverable_2.submission_flag ,' ')<>'Y'))
             OR((r_deliverable_2.submission_flag = 'Y') AND (NVL(r_deliverable_1.submission_flag ,' ')<>'Y'))THEN
              l_prompt :='SUBMISSION_FLAG';
              l_data1  :=r_deliverable_1.submission_flag;
              l_data2  :=r_deliverable_2.submission_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.data_item_subtitle <>r_deliverable_2.data_item_subtitle )
		 OR( NOT((  r_deliverable_1.data_item_subtitle is null)and(r_deliverable_2.data_item_subtitle is null))
             AND (( r_deliverable_1.data_item_subtitle is null)or(r_deliverable_2.data_item_subtitle is null)))THEN
              l_prompt :='DATA_ITEM_SUBTITLE';
              l_data1  :=r_deliverable_1.data_item_subtitle;
              l_data2  :=r_deliverable_2.data_item_subtitle;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.total_num_of_copies <>r_deliverable_2.total_num_of_copies )
		 OR( NOT((  r_deliverable_1.total_num_of_copies is null)and(r_deliverable_2.total_num_of_copies is null))
             AND (( r_deliverable_1.total_num_of_copies is null)or(r_deliverable_2.total_num_of_copies is null)))THEN
              l_prompt :='TOTAL_NUM_OF_COPIES';
              l_data1  :=r_deliverable_1.total_num_of_copies;
              l_data2  :=r_deliverable_2.total_num_of_copies;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.cdrl_category <>r_deliverable_2.cdrl_category )
		 OR( NOT((  r_deliverable_1.cdrl_category is null)and(r_deliverable_2.cdrl_category is null))
             AND (( r_deliverable_1.cdrl_category is null)or(r_deliverable_2.cdrl_category is null)))THEN
              l_prompt :='CDRL_CATEGORY';
              l_data1  :=r_deliverable_1.cdrl_category;
              l_data2  :=r_deliverable_2.cdrl_category;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.data_item_name <>r_deliverable_2.data_item_name )
		 OR( NOT((  r_deliverable_1.data_item_name is null)and(r_deliverable_2.data_item_name is null))
             AND (( r_deliverable_1.data_item_name is null)or(r_deliverable_2.data_item_name is null)))THEN
              l_prompt :='DATA_ITEM_NAME';
              l_data1  :=r_deliverable_1.data_item_name;
              l_data2  :=r_deliverable_2.data_item_name;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF ((r_deliverable_1.export_flag = 'Y') AND (NVL(r_deliverable_2.export_flag ,' ')<>'Y'))
             OR((r_deliverable_2.export_flag = 'Y') AND (NVL(r_deliverable_1.export_flag ,' ')<>'Y'))THEN
              l_prompt :='EXPORT_FLAG';
              l_data1  :=r_deliverable_1.export_flag;
              l_data2  :=r_deliverable_2.export_flag;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.export_license_num <>r_deliverable_2.export_license_num )
		 OR( NOT((  r_deliverable_1.export_license_num is null)and(r_deliverable_2.export_license_num is null))
             AND (( r_deliverable_1.export_license_num is null)or(r_deliverable_2.export_license_num is null)))THEN
              l_prompt :='EXPORT_LICENSE_NUM';
              l_data1  :=r_deliverable_1.export_license_num;
              l_data2  :=r_deliverable_2.export_license_num;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.export_license_res <>r_deliverable_2.export_license_res )
		 OR( NOT((  r_deliverable_1.export_license_res is null)and(r_deliverable_2.export_license_res is null))
             AND (( r_deliverable_1.export_license_res is null)or(r_deliverable_2.export_license_res is null)))THEN
              l_prompt :='EXPORT_LICENSE_RES';
              l_data1  :=r_deliverable_1.export_license_res;
              l_data2  :=r_deliverable_2.export_license_res;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.status <>r_deliverable_2.status )
		 OR( NOT((  r_deliverable_1.status is null)and(r_deliverable_2.status is null))
             AND (( r_deliverable_1.status is null)or(r_deliverable_2.status is null)))THEN
              l_prompt :='STATUS';
              l_data1  :=r_deliverable_1.status;
              l_data2  :=r_deliverable_2.status;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.volume <>r_deliverable_2.volume )
		 OR( NOT((  r_deliverable_1.volume is null)and(r_deliverable_2.volume is null))
             AND (( r_deliverable_1.volume is null)or(r_deliverable_2.volume is null)))THEN
              l_prompt :='VOLUME ';
              l_data1  :=r_deliverable_1.volume;
              l_data2  :=r_deliverable_2.volume;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	   IF (r_deliverable_1.volume_uom_code <>r_deliverable_2.volume_uom_code )
		 OR( NOT((  r_deliverable_1.volume_uom_code is null)and(r_deliverable_2.volume_uom_code is null))
             AND (( r_deliverable_1.volume_uom_code is null)or(r_deliverable_2.volume_uom_code is null)))THEN
              l_prompt :='VOLUME_UOM_CODE';
              l_data1  :=r_deliverable_1.volume_uom_code;
              l_data2  :=r_deliverable_2.volume_uom_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.weight <>r_deliverable_2.weight )
		 OR( NOT((  r_deliverable_1.weight is null)and(r_deliverable_2.weight is null))
             AND (( r_deliverable_1.weight is null)or(r_deliverable_2.weight is null)))THEN
              l_prompt :='WEIGHT';
              l_data1  :=r_deliverable_1.weight;
              l_data2  :=r_deliverable_2.weight;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

	    IF (r_deliverable_1.weight_uom_code <>r_deliverable_2.weight_uom_code )
		 OR( NOT((  r_deliverable_1.weight_uom_code is null)and(r_deliverable_2.weight_uom_code is null))
             AND (( r_deliverable_1.weight_uom_code is null)or(r_deliverable_2.weight_uom_code is null)))THEN
              l_prompt :='WEIGHT_UOM_CODE';
              l_data1  :=r_deliverable_1.weight_uom_code;
              l_data2  :=r_deliverable_2.weight_uom_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.expenditure_type <>r_deliverable_2.expenditure_type )
		 OR( NOT((  r_deliverable_1.expenditure_type is null)and(r_deliverable_2.expenditure_type is null))
             AND (( r_deliverable_1.expenditure_type is null)or(r_deliverable_2.expenditure_type is null)))THEN
              l_prompt :='EXPENDITURE_TYPE';
              l_data1  :=r_deliverable_1.expenditure_type;
              l_data2  :=r_deliverable_2.expenditure_type;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.expenditure_organization_id <>r_deliverable_2. expenditure_organization_id)
		 OR( NOT((  r_deliverable_1.expenditure_organization_id is null)and(r_deliverable_2.expenditure_organization_id is null))
             AND (( r_deliverable_1.expenditure_organization_id is null)or(r_deliverable_2.expenditure_organization_id is null)))THEN
              l_prompt :='EXPENDITURE_ORGANIZATION';

              OPEN c_expenditure_org(r_deliverable_1.expenditure_organization_id);
              FETCH c_expenditure_org INTO l_data1;
              CLOSE c_expenditure_org;

              OPEN c_expenditure_org(r_deliverable_2.expenditure_organization_id);
              FETCH c_expenditure_org INTO l_data2;
              CLOSE c_expenditure_org;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.expenditure_item_date <>r_deliverable_2.expenditure_item_date  )
		 OR( NOT((  r_deliverable_1.expenditure_item_date is null)and(r_deliverable_2.expenditure_item_date is null))
             AND (( r_deliverable_1.expenditure_item_date is null)or(r_deliverable_2.expenditure_item_date is null)))THEN
              l_prompt :='EXPENDITURE_ITEM_DATE';
              l_data1  :=r_deliverable_1.expenditure_item_date;
              l_data2  :=r_deliverable_2.expenditure_item_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.destination_type_code <>r_deliverable_2.destination_type_code )
		 OR( NOT((  r_deliverable_1.destination_type_code is null)and(r_deliverable_2.destination_type_code is null))
             AND (( r_deliverable_1.destination_type_code is null)or(r_deliverable_2.destination_type_code is null)))THEN
              l_prompt :='DESTINATION_TYPE_CODE';
              l_data1  :=r_deliverable_1.destination_type_code;
              l_data2  :=r_deliverable_2.destination_type_code;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.rate_type <>r_deliverable_2.rate_type )
		 OR( NOT((  r_deliverable_1.rate_type is null)and(r_deliverable_2.rate_type is null))
             AND (( r_deliverable_1.rate_type is null)or(r_deliverable_2.rate_type is null)))THEN
              l_prompt :='BILL_RATE_TYPE';
              l_data1  :=r_deliverable_1.rate_type;
              l_data2  :=r_deliverable_2.rate_type;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

            IF (r_deliverable_1.rate_date <>r_deliverable_2.rate_date )
		 OR( NOT((  r_deliverable_1.rate_date is null)and(r_deliverable_2.rate_date is null))
             AND (( r_deliverable_1.rate_date is null)or(r_deliverable_2.rate_date is null)))THEN
              l_prompt :='BILL_RATE_DATE';
              l_data1  :=r_deliverable_1.rate_date;
              l_data2  :=r_deliverable_2.rate_date;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;


            IF (r_deliverable_1.exchange_rate <>r_deliverable_2.exchange_rate )
		 OR( NOT((  r_deliverable_1.exchange_rate is null)and(r_deliverable_2.exchange_rate is null))
             AND (( r_deliverable_1.exchange_rate is null)or(r_deliverable_2.exchange_rate is null)))THEN
              l_prompt :='BILL_EXCHANGE_RATE';
              l_data1  :=r_deliverable_1.exchange_rate;
              l_data2  :=r_deliverable_2.exchange_rate;

              insert_comp_result(vHeader_id,vVersion1,vVersion2);
            END IF;

        END IF;

     END LOOP;

     CLOSE  v_deliverables_1;

     FOR c_deliverable_2 IN c_deliverables_2 LOOP
        vDifference :=0;

	LOOP
            FETCH v_deliverables_1 INTO current_deliverable_1;
            EXIT WHEN v_deliverables_1%NOTFOUND;

            IF c_deliverable_2.deliverable_id = current_deliverable_1 	THEN
               vDifference :=vDifference +1;
            END IF;

        END LOOP;

        IF vDifference = 0 THEN
           l_prompt := '';

           l_Object  :='NO_DELIVERABLE';

           OPEN c;
           FETCH c INTO l_data1;
           CLOSE c;

           l_data2  := '';

           SELECT deliverable_num
           INTO current_deliverable_num
           from oke_k_deliverables_bh
           where k_header_id=vHeader_id
           and k_line_id=vCurrentLineId
           and major_version=vVersion2
           and deliverable_id=c_deliverable_2.deliverable_id;

           l_object_name := get_full_path_linenum(vCurrentLineId,vVersion2)||'*'||current_deliverable_num;


           insert_comp_result(vHeader_id,vVersion1,vVersion2);

        END IF;

     END LOOP;

        EXCEPTION
            WHEN OTHERS THEN
            NULL;

  END comp_line_deliverables;

  PROCEDURE comp_header_articles(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER)
  IS
     CURSOR c_articles_1 IS
     SELECT
        CHR_ID,
        CLE_ID,
        CAT_ID,
        CAT_TYPE,
        SFWT_FLAG,
        --SAV_SAE_ID,
       (SELECT sav_sae_id FROM okc_k_articles_bh WHERE id=h.id AND major_version=h.major_version) SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        COMMENTS,
        NAME,
        TEXT
     FROM  okc_k_articles_hv h
     WHERE dnz_chr_id=vHeader_id
     AND cle_id is null
     AND major_version=vVersion_1;


   CURSOR c_articles_2 IS
     SELECT
        CHR_ID,
        CLE_ID,
        CAT_ID,
        CAT_TYPE,
        SFWT_FLAG,
--        SAV_SAE_ID,
        (SELECT sav_sae_id FROM okc_k_articles_bh WHERE id=h.id AND major_version=h.major_version) SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        COMMENTS,
        NAME,
        TEXT
     FROM  okc_k_articles_hv h
     WHERE dnz_chr_id=vHeader_id
     AND cle_id is null
     AND major_version=vVersion_2;

    /* Articles in the latest version  */

   CURSOR c_articles_latest IS
     SELECT
        CHR_ID,
        CLE_ID,
        CAT_ID,
        CAT_TYPE,
        SFWT_FLAG,
--        SAV_SAE_ID,
        (SELECT sav_sae_id FROM okc_k_articles_b WHERE id=k.id) SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        COMMENTS,
        NAME,
        TEXT
     FROM  okc_k_articles_v k
     WHERE dnz_chr_id=vHeader_id
     AND cle_id is null;

    CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;

    l_ArticleDifference NUMBER;
    l_name varchar(80);

    l_sbt_code_1     varchar(30);
    l_sbt_code_2     varchar(30);
    l_article_name_1 varchar(150);
    l_article_name_2 varchar(150);
    l_subject_name_1 varchar(80);
    l_subject_name_2 varchar(80);
    l_release        varchar(150);

    BEGIN
       l_object_name :='';
       l_object      :='ARTICLE';

       OPEN c;
       FETCH c INTO l_object_type;
       CLOSE c;

       IF L_Latest_Version >= vVersion_1 THEN

              FOR c_article_1 IN c_articles_1 LOOP
                  l_ArticleDifference :=0;

                  get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                       p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                       p_sbt_code      =>   c_article_1.sbt_code,
                                       p_article_name  =>   c_article_1.name,
                                       x_sbt_code      =>   l_sbt_code_1,
                                       x_article_name  =>   l_article_name_1,
                                       x_subject_name  =>   l_subject_name_1);

                  FOR c_article_2 IN c_articles_2 LOOP

                      get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                       p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                       p_sbt_code      =>   c_article_2.sbt_code,
                                       p_article_name  =>   c_article_2.name,
                                       x_sbt_code      =>   l_sbt_code_2,
                                       x_article_name  =>   l_article_name_2,
                                       x_subject_name  =>   l_subject_name_2);

                      IF l_article_name_1 = l_article_name_2
                         and nvl(c_article_1.sav_sav_release,' ') = nvl(c_article_2.sav_sav_release,' ')
                      THEN l_ArticleDifference := l_ArticleDifference+1;
                      END IF;
                  END LOOP;

                  l_release := c_article_1.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt :=l_article_name_1||'('||l_release||')';
                     l_Object  :='NO_ARTICLE';
                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);

                  END IF;
              END LOOP;

              FOR c_article_2 IN c_articles_2 LOOP
                  l_ArticleDifference :=0;

                   get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                       p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                       p_sbt_code      =>   c_article_2.sbt_code,
                                       p_article_name  =>   c_article_2.name,
                                       x_sbt_code      =>   l_sbt_code_2,
                                       x_article_name  =>   l_article_name_2,
                                       x_subject_name  =>   l_subject_name_2);

                  FOR c_article_1 IN c_articles_1 LOOP
                      get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                       p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                       p_sbt_code      =>   c_article_1.sbt_code,
                                       p_article_name  =>   c_article_1.name,
                                       x_sbt_code      =>   l_sbt_code_1,
                                       x_article_name  =>   l_article_name_1,
                                       x_subject_name  =>   l_subject_name_1);

                      IF l_article_name_1 = l_article_name_2
                         AND nvl(c_article_1.sav_sav_release,' ') = nvl(c_article_2.sav_sav_release,' ')
                      THEN l_ArticleDifference := l_ArticleDifference+1;
                      END IF;

                  END LOOP;

                  l_release := c_article_2.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt :=l_article_name_2||'('||l_release||')';
                     l_Object  :='NO_ARTICLE';
                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);

                  END IF;
              END LOOP;

             ELSE

	      FOR c_article_1 IN c_articles_latest LOOP
                  l_ArticleDifference :=0;
                 get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                      p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                       p_sbt_code      =>   c_article_1.sbt_code,
                                       p_article_name  =>   c_article_1.name,
                                       x_sbt_code      =>   l_sbt_code_1,
                                       x_article_name  =>   l_article_name_1,
                                       x_subject_name  =>   l_subject_name_1);

                  FOR c_article_2 IN c_articles_2 LOOP
                      get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                       p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                       p_sbt_code      =>   c_article_2.sbt_code,
                                       p_article_name  =>   c_article_2.name,
                                       x_sbt_code      =>   l_sbt_code_2,
                                       x_article_name  =>   l_article_name_2,
                                       x_subject_name  =>   l_subject_name_2);

                      IF l_article_name_1 = l_article_name_2
                         AND nvl(c_article_1.sav_sav_release, ' ') = nvl(c_article_2.sav_sav_release,' ')
                      THEN l_ArticleDifference := l_ArticleDifference+1;
                      END IF;

                  END LOOP;

                  l_release := c_article_1.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt := l_article_name_1||'('||l_release||')';
		     l_Object  :='NO_ARTICLE';
                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;

              END LOOP;

              FOR c_article_2 IN c_articles_2 LOOP

                  l_ArticleDifference :=0;
                  get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                     p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                     p_sbt_code      =>   c_article_2.sbt_code,
                                     p_article_name  =>   c_article_2.name,
                                     x_sbt_code      =>   l_sbt_code_2,
                                     x_article_name  =>   l_article_name_2,
                                     x_subject_name  =>   l_subject_name_2);

                  FOR c_article_1 IN c_articles_latest LOOP
                    get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                     p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                     p_sbt_code      =>   c_article_1.sbt_code,
                                     p_article_name  =>   c_article_1.name,
                                     x_sbt_code      =>   l_sbt_code_1,
                                     x_article_name  =>   l_article_name_1,
                                     x_subject_name  =>   l_subject_name_1);

                    IF l_article_name_1 = l_article_name_2
                       AND nvl(c_article_1.sav_sav_release, ' ') = nvl(c_article_2.sav_sav_release,' ')
                    THEN l_ArticleDifference := l_ArticleDifference+1;
                    END IF;

                  END LOOP;

                  l_release := c_article_2.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt :=  l_article_name_2||'('||l_release||')';
		     l_Object  :='NO_ARTICLE';
                     l_object_name :='';

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);

                  END IF;
              END LOOP;

	     END IF;

	     EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                NULL;
		WHEN OTHERS THEN
		NULL;

  END comp_header_articles;


  PROCEDURE comp_line_articles(vHeader_id IN NUMBER, vVersion_1 IN NUMBER, vVersion_2 IN NUMBER,vLine_id IN NUMBER)
  IS CURSOR c_articles_1 IS
     SELECT
        CHR_ID,
        CLE_ID,
        CAT_ID,
        CAT_TYPE,
        SFWT_FLAG,
        -- SAV_SAE_ID,
        (SELECT sav_sae_id FROM okc_k_articles_bh WHERE id=h.id AND major_version=h.major_version) SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        COMMENTS,
        NAME,
        TEXT
     FROM  okc_k_articles_hv h
     WHERE dnz_chr_id=vHeader_id
     AND cle_id =vLine_id
     AND major_version=vVersion_1;


   CURSOR c_articles_2 IS
     SELECT
        CHR_ID,
        CLE_ID,
        CAT_ID,
        CAT_TYPE,
        SFWT_FLAG,
        -- SAV_SAE_ID,
        (SELECT sav_sae_id FROM okc_k_articles_bh WHERE id=h.id AND major_version=h.major_version) SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        COMMENTS,
        NAME,
        TEXT
     FROM  okc_k_articles_hv h
     WHERE dnz_chr_id=vHeader_id
     AND cle_id = vLine_id
     AND major_version=vVersion_2;

    /* Articles in the latest version  */

   CURSOR c_articles_latest IS
     SELECT
        CHR_ID,
        CLE_ID,
        CAT_ID,
        CAT_TYPE,
        SFWT_FLAG,
        -- SAV_SAE_ID,
        (SELECT sav_sae_id FROM okc_k_articles_b WHERE id=k.id) SAV_SAE_ID,
        SAV_SAV_RELEASE,
        SBT_CODE,
        COMMENTS,
        NAME,
        TEXT
     FROM  okc_k_articles_v k
     WHERE dnz_chr_id=vHeader_id
     AND cle_id =vLine_id;

    CURSOR c IS
       SELECT meaning
       FROM   fnd_lookup_values_vl
       WHERE  lookup_type = 'VER_COMP_OBJECT_TYPE'
       AND    lookup_code = l_Object
       AND    view_application_id=777;

    l_ArticleDifference NUMBER;
    l_name varchar(80);

    l_sbt_code_1     varchar(30);
    l_sbt_code_2     varchar(30);
    l_article_name_1 varchar(150);
    l_article_name_2 varchar(150);
    l_subject_name_1 varchar(80);
    l_subject_name_2 varchar(80);
    l_release        varchar(150);

    BEGIN
       l_object_name :='';
       l_object      :='ARTICLE';

       OPEN c;
       FETCH c INTO l_object_type;
       CLOSE c;

       IF L_Latest_Version >= vVersion_1 THEN

              FOR c_article_1 IN c_articles_1 LOOP
                  l_ArticleDifference :=0;
                get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                       p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                       p_sbt_code      =>   c_article_1.sbt_code,
                                       p_article_name  =>   c_article_1.name,
                                       x_sbt_code      =>   l_sbt_code_1,
                                       x_article_name  =>   l_article_name_1,
                                       x_subject_name  =>   l_subject_name_1);

                 FOR c_article_2 IN c_articles_2 LOOP
                       get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                       p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                       p_sbt_code      =>   c_article_2.sbt_code,
                                       p_article_name  =>   c_article_2.name,
                                       x_sbt_code      =>   l_sbt_code_2,
                                       x_article_name  =>   l_article_name_2,
                                       x_subject_name  =>   l_subject_name_2);

                      IF l_article_name_1 = l_article_name_2
                         and nvl(c_article_1.sav_sav_release,' ') = nvl(c_article_2.sav_sav_release,' ')
                      THEN l_ArticleDifference := l_ArticleDifference+1;
                      END IF;
                  END LOOP;

                  l_release := c_article_1.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt := l_article_name_1||'('||l_release||')';
                     l_Object  :='NO_ARTICLE';
                     l_object_name :=  get_full_path_linenum(vLine_id,vVersion_1);

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);

                  END IF;
              END LOOP;

              FOR c_article_2 IN c_articles_2 LOOP
                  l_ArticleDifference :=0;
                  get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                       p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                       p_sbt_code      =>   c_article_2.sbt_code,
                                       p_article_name  =>   c_article_2.name,
                                       x_sbt_code      =>   l_sbt_code_2,
                                       x_article_name  =>   l_article_name_2,
                                       x_subject_name  =>   l_subject_name_2);

                  FOR c_article_1 IN c_articles_1 LOOP
                      get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                       p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                       p_sbt_code      =>   c_article_1.sbt_code,
                                       p_article_name  =>   c_article_1.name,
                                       x_sbt_code      =>   l_sbt_code_1,
                                       x_article_name  =>   l_article_name_1,
                                       x_subject_name  =>   l_subject_name_1);

                      IF l_article_name_1 = l_article_name_2
                         AND nvl(c_article_1.sav_sav_release,' ') = nvl(c_article_2.sav_sav_release,' ')
                      THEN l_ArticleDifference := l_ArticleDifference+1;
                      END IF;

                  END LOOP;

                  l_release := c_article_2.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt := l_article_name_2||'('||l_release||')';
                     l_Object  :='NO_ARTICLE';
                     l_object_name :=get_full_path_linenum(vLine_id,vVersion_2);

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);

                  END IF;
              END LOOP;


             ELSE

	      FOR c_article_1 IN c_articles_latest LOOP

                      get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                       p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                       p_sbt_code      =>   c_article_1.sbt_code,
                                       p_article_name  =>   c_article_1.name,
                                       x_sbt_code      =>   l_sbt_code_1,
                                       x_article_name  =>   l_article_name_1,
                                       x_subject_name  =>   l_subject_name_1);

                  l_ArticleDifference :=0;
                  FOR c_article_2 IN c_articles_2 LOOP
                      get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                       p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                       p_sbt_code      =>   c_article_2.sbt_code,
                                       p_article_name  =>   c_article_2.name,
                                       x_sbt_code      =>   l_sbt_code_2,
                                       x_article_name  =>   l_article_name_2,
                                       x_subject_name  =>   l_subject_name_2);

                      IF l_article_name_1 = l_article_name_2
                         AND nvl(c_article_1.sav_sav_release, ' ') = nvl(c_article_2.sav_sav_release,' ')
                      THEN l_ArticleDifference := l_ArticleDifference+1;
                      END IF;

                  END LOOP;

                  l_release := c_article_1.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt :=l_article_name_1||'('||l_release||')';
		     l_Object  :='NO_ARTICLE';
                     l_object_name :=get_full_path_linenum(vLine_id);

                     OPEN c;
                     FETCH c INTO l_data2;
                     CLOSE c;

                     l_data1  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);
                  END IF;

              END LOOP;

              FOR c_article_2 IN c_articles_2 LOOP
                  get_article_info(p_cat_type      =>   c_article_2.cat_type,
                                     p_sav_sae_id    =>   c_article_2.sav_sae_id,
                                     p_sbt_code      =>   c_article_2.sbt_code,
                                     p_article_name  =>   c_article_2.name,
                                     x_sbt_code      =>   l_sbt_code_2,
                                     x_article_name  =>   l_article_name_2,
                                     x_subject_name  =>   l_subject_name_2);
                  l_ArticleDifference :=0;
                  FOR c_article_1 IN c_articles_latest LOOP
                    get_article_info(p_cat_type      =>   c_article_1.cat_type,
                                     p_sav_sae_id    =>   c_article_1.sav_sae_id,
                                     p_sbt_code      =>   c_article_1.sbt_code,
                                     p_article_name  =>   c_article_1.name,
                                     x_sbt_code      =>   l_sbt_code_1,
                                     x_article_name  =>   l_article_name_1,
                                     x_subject_name  =>   l_subject_name_1);

                    IF l_article_name_1 = l_article_name_2
                       AND nvl(c_article_1.sav_sav_release, ' ') = nvl(c_article_2.sav_sav_release,' ')
                    THEN l_ArticleDifference := l_ArticleDifference+1;
                    END IF;

                  END LOOP;

                  l_release := c_article_2.sav_sav_release;

                  IF l_ArticleDifference =0 THEN
                     l_prompt :=l_article_name_2||'('||l_release||')';
		     l_Object  :='NO_ARTICLE';
                     l_object_name :=get_full_path_linenum(vLine_id,vVersion_2);

                     OPEN c;
                     FETCH c INTO l_data1;
                     CLOSE c;

                     l_data2  := '';
                     insert_comp_result(vHeader_id,vVersion_1,vVersion_2);

                  END IF;
              END LOOP;

	     END IF;

	     EXCEPTION
            	WHEN NO_DATA_FOUND THEN
                NULL;
		WHEN OTHERS THEN
		NULL;

  END comp_line_articles;



END OKE_VERSION_COMPARISON_PKG;

/
