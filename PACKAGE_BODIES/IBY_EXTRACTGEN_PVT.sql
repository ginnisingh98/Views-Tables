--------------------------------------------------------
--  DDL for Package Body IBY_EXTRACTGEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EXTRACTGEN_PVT" AS
/* $Header: ibyxgenb.pls 120.33.12010000.17 2009/12/09 13:20:20 vkarlapu ship $ */

  -- Global variables
 G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBY_EXTRACTGEN_PVT';

  TYPE l_attribute_cat_rec_type IS RECORD(
  l_hzp_attr_cat  VARCHAR2(150)
   );

  TYPE l_att_cat_tbl_type IS TABLE OF l_attribute_cat_rec_type INDEX BY BINARY_INTEGER;

  l_att_cat_tbl  l_att_cat_tbl_type;

  PROCEDURE print_debuginfo (
               p_module     IN VARCHAR2
             , p_debug_text IN VARCHAR2)
  IS
  BEGIN
      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	     iby_debug_pub.add(p_debug_text,iby_debug_pub.G_LEVEL_INFO,p_module);
	     FND_FILE.PUT_LINE(FND_FILE.LOG, p_module || ': ' || p_debug_text);
      END IF;

  END;
 FUNCTION stripped_string (
     expression_in    IN   VARCHAR2
    ,characters_in    IN   VARCHAR2
    ,placeholder_in   IN   VARCHAR2 DEFAULT '#'
  )
     RETURN VARCHAR2
  IS
    result_string VARCHAR2(3000);
  BEGIN

     result_string := TRANSLATE(SUBSTR(expression_in,   1,   1),  placeholder_in || characters_in,   placeholder_in) ||   --stripping first apos
		      SUBSTR(expression_in,   2,   LENGTH(expression_in) -2) ||                                                      --fetching unstripped
                      TRANSLATE(SUBSTR(expression_in,   -1,   1),  placeholder_in || characters_in,   placeholder_in);    --stripping last apos

     IF ( upper(result_string) = 'NULL' ) THEN
	result_string := NULL;
     END IF;
     RETURN result_string;
  END stripped_string;

  PROCEDURE Create_Extract
  (
  p_extract_code     IN     iby_extracts_vl.extract_code%TYPE,
  p_extract_version  IN     iby_extracts_vl.extract_version%TYPE,
  p_params           IN OUT NOCOPY JTF_VARCHAR2_TABLE_200,
  x_extract_doc      OUT NOCOPY CLOB
  )
  IS

    l_module_name      CONSTANT VARCHAR2(200) := G_PKG_NAME || '.Create_Extract';

    l_code_pkg iby_extracts_b.gen_code_package%TYPE;
    l_code_entry iby_extracts_b.gen_code_entry_point%TYPE;
    l_call VARCHAR2(3000);
    l_param_1 VARCHAR2(3000);
    l_param_2 VARCHAR2(3000);
    l_param_3 VARCHAR2(3000);
    l_param_4 VARCHAR2(3000);
    l_param_5 VARCHAR2(3000);
    l_param_6 VARCHAR2(3000);
    l_param_7 VARCHAR2(3000);
    l_param_8 VARCHAR2(3000);

    l_x_not_found BOOLEAN;
    l_numeric_char_mask  V$NLS_PARAMETERS.value%TYPE;
    l_default_num_mask   VARCHAR2(10) := '.,';


    x_return_status  VARCHAR2(200);

    CURSOR c_x_info(ci_extract_code IN iby_extracts_b.extract_code%TYPE,
                    ci_extract_version IN  iby_extracts_b.extract_version%TYPE)
    IS
      SELECT gen_code_package,gen_code_entry_point
      FROM iby_extracts_vl
      WHERE (extract_code=ci_extract_code)
        AND (extract_version=ci_extract_version)
        AND (gen_code_language='PLSQL');
  BEGIN

    -- Get NLS numeric character before calling extract.
    -- bug 5604582
    BEGIN
      SELECT value
        INTO l_numeric_char_mask
        FROM V$NLS_PARAMETERS
       WHERE parameter='NLS_NUMERIC_CHARACTERS';
    EXCEPTION
      WHEN others THEN NULL;
    END;

    IF (c_x_info%ISOPEN) THEN
      CLOSE c_x_info;
    END IF;

    OPEN c_x_info(p_extract_code,p_extract_version);
    FETCH c_x_info INTO l_code_pkg,l_code_entry;
    l_x_not_found := c_x_info%NOTFOUND;
    CLOSE c_x_info;

    IF (l_x_not_found) THEN
      raise_application_error(-20000,
        'IBY_20590#TABLE=IBY_EXTRACTS_VL' || '#ID=' || p_extract_code,
        FALSE);
    END IF;
   -- test_debug('l_code_pkg: '|| l_code_pkg);

   -- alter session so that the numeric characters are set to decimal separatori(.)
    -- if different
    -- bug 5604582
    IF l_numeric_char_mask <> l_default_num_mask THEN
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_default_num_mask||'"';
    END IF;

   /*  Bug 6016869
*/
    IF (   upper(l_code_pkg)   = 'IBY_FNDCPT_EXTRACT_GEN_PVT'
       AND upper(l_code_entry) = 'CREATE_EXTRACT_1_0'
       AND p_params.COUNT IN (4,5)     -- Bug 6673696
       AND p_extract_version = 1) THEN

      IF ( p_params.COUNT = 4 OR p_params(5) = 'NULL') THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name
	             , 'Calling CREATE_EXTRACT_1_0 with 4 params:'
	             );
		  --Do not log the following value
		  --p_params(4) = sys_key
	          print_debuginfo(l_module_name
	             , '4 params:'
	               || p_params(1) || ':'
	               || p_params(2) || ':'
	               || p_params(3) || ':'
	              -- || p_params(4) || ':'
	               );
          END IF;
	     --  test_debug('p_params(1): '||p_params(1));
	     --  test_debug('p_params(4): '||p_params(4));
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          l_param_3 := stripped_string (p_params(3), '''');
          l_param_4 := stripped_string (p_params(4), '''');

          IF ( l_param_4 = 'NULL' ) THEN
                l_param_4 := NULL;
          END IF;

         -- Bug 8544380
         -- Changing NLS Charset to US Default as anyother format is
	 -- not accepted by BI Publisher.
	 IF l_numeric_char_mask <> l_default_num_mask THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_default_num_mask||'"';
         END IF;

         IBY_FNDCPT_EXTRACT_GEN_PVT.CREATE_EXTRACT_1_0 (
             p_instr_type       => l_param_1,
             p_req_type         => l_param_2,
             p_txn_id           => to_number(l_param_3),
             p_sys_key          => HEXTORAW(l_param_4),
             x_extract_doc      => x_extract_doc
             );

	      --  test_debug('after create extract... ');
	 -- Bug 8544380
	 -- Changing NLS Charset back to customer setting from US Default so
	 -- the customer is not affected by alter sessions.
         IF l_numeric_char_mask <> l_default_num_mask THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_numeric_char_mask||'"';
         END IF;

       ELSE
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name
	             , 'Calling CREATE_EXTRACT_1_0 with 5 params:'
	             );

          --Do not log these values
	  --p_params(4) = sys_key
	  --p_params(5) = cvv2
	          print_debuginfo(l_module_name
	             , '5 params:'
	               || p_params(1) || ':'
	               || p_params(2) || ':'
	               || p_params(3) || ':'
	    --           || p_params(4) || ':'
	    --           || p_params(5) || ':'
	             );

          END IF;
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          l_param_3 := stripped_string (p_params(3), '''');
          l_param_4 := stripped_string (p_params(4), '''');
          l_param_5 := stripped_string (p_params(5), '''');

          IF ( l_param_4 = 'NULL' ) THEN
                l_param_4 := NULL;
          END IF;

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'l_param_5 = ' || l_param_5 || ':');

          END IF;
         -- Bug 8544380
         -- Changing NLS Charset to US Default as anyother format is
	 -- not accepted by BI Publisher.
	 IF l_numeric_char_mask <> l_default_num_mask THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_default_num_mask||'"';
          END IF;


          IBY_FNDCPT_EXTRACT_GEN_PVT.CREATE_EXTRACT_1_0 (
                p_instr_type       => l_param_1,
                p_req_type         => l_param_2,
                p_txn_id           => to_number(l_param_3),
                p_sys_key          => HEXTORAW(l_param_4),
                p_sec_val          => l_param_5,
                x_extract_doc      => x_extract_doc
               );
         -- Bug 8544380
	 -- Changing NLS Charset back to customer setting from US Default so
	 -- the customer is not affected by alter sessions.
         IF l_numeric_char_mask <> l_default_num_mask THEN
            EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_numeric_char_mask||'"';
         END IF;


       END IF;

   ELSIF (   upper(l_code_pkg)   ='IBY_FD_EXTRACT_GEN_PVT'
       AND upper(l_code_entry) = 'CREATE_EXTRACT_1_0'
       AND p_params.COUNT IN (5,8)     -- Bug 6673696
       AND p_extract_version = 1) THEN
     BEGIN

     IF l_numeric_char_mask <> l_default_num_mask THEN
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='||'"'||l_default_num_mask||'"';
     END IF;

       IF ( p_params.COUNT = 5) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name
	             , 'Calling CREATE_EXTRACT_1_0 with 5 params:'
	             );
		  --Do not log p_param(5) as it contains sensitive data
	          print_debuginfo(l_module_name
	             , '5 params:'
	               || p_params(1) || ':'
	               || p_params(2) || ':'
	               || p_params(3) || ':'
	               || p_params(4) || ':'
	             --  || p_params(5) || ':'
	             );
          END IF;
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          l_param_3 := stripped_string (p_params(3), '''');
          l_param_4 := stripped_string (p_params(4), '''');
          l_param_5 := stripped_string (p_params(5), '''');

          IF ( l_param_5 = 'NULL' ) THEN
                l_param_5 := NULL;
          END IF;

          IBY_FD_EXTRACT_GEN_PVT.CREATE_EXTRACT_1_0 (
             p_payment_instruction_id => to_number(l_param_1),
             p_save_extract_flag      => l_param_2,
             p_format_type            => l_param_3,
             p_is_reprint_flag        => l_param_4,
             p_sys_key                => HEXTORAW(l_param_5),
             x_extract_doc            => x_extract_doc
             );
       ELSE
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name
	             , 'Calling CREATE_EXTRACT_1_0 with 8 params:'
	             );
 		  --Do not log p_param(8) as it contains sensitive data
	          print_debuginfo(l_module_name
	             , '6 params:'
	               || p_params(1) || ':'
	               || p_params(2) || ':'
	               || p_params(3) || ':'
	               || p_params(4) || ':'
	               || p_params(5) || ':'
	               || p_params(6) || ':'
	               || p_params(7) || ':'
	              -- || p_params(8) || ':'
	             );
          END IF;
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          l_param_3 := stripped_string (p_params(3), '''');
          l_param_4 := stripped_string (p_params(4), '''');
          l_param_5 := stripped_string (p_params(5), '''');
          l_param_6 := stripped_string (p_params(6), '''');
          l_param_7 := stripped_string (p_params(7), '''');
          l_param_8 := stripped_string (p_params(8), '''');
          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name, 'l_param_8 = ' || l_param_8 || ':');
          END IF;
          IF ( l_param_6 = 'NULL' ) THEN
                l_param_6 := NULL;
          END IF;
          IF ( l_param_7 = 'NULL' ) THEN
                l_param_7 := NULL;
          END IF;
          IF ( l_param_8 = 'NULL' ) THEN
                l_param_8 := NULL;
          END IF;

           IBY_FD_EXTRACT_GEN_PVT.CREATE_EXTRACT_1_0 (
                p_payment_instruction_id =>to_number(l_param_1),
                p_save_extract_flag      => l_param_2,
                p_format_type            => l_param_3,
                p_delivery_method        => l_param_4,
                p_sys_key                => HEXTORAW(l_param_8),
                p_payment_id             => to_number(l_param_5),
                x_extract_doc            => x_extract_doc,
		p_from_pmt_ref           => to_number(l_param_6),
		p_to_pmt_ref             => to_number(l_param_7)
                );
       END IF;

	    IF l_numeric_char_mask <> l_default_num_mask THEN
	      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '||
				 '"'||l_numeric_char_mask|| '"';
	    END IF;
       EXCEPTION

        WHEN OTHERS THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name, 'An exception has occured when creating extract..');
         END IF;
      	/* Bug 9061437: commenting following code
	 -- when exception occurs, the payment_instruction must be unlocked from the request

	IBY_DISBURSE_UI_API_PUB_PKG.unlock_pmt_entity(
	p_object_id      => to_number(l_param_1),
	p_object_type    => 'PAYMENT_INSTRUCTION',
	x_return_status  => x_return_status
	);*/

        RAISE;
       END;
     ELSIF (   upper(l_code_pkg)   = 'IBY_FD_EXTRACT_GEN_PVT'
         AND upper(l_code_entry) = ' CREATE_PPR_EXTRACT_1_0'
         AND p_params.COUNT = 2          -- Bug 6673696
         AND p_extract_version = 1) THEN
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo(l_module_name
	             , 'Calling CREATE_EXTRACT_1_0 with 2 params:'
	             );
 		  --Do not log p_param(2) as it contains sensitive data
	          print_debuginfo(l_module_name
	             , '2 params:'
	               || p_params(1) || ':'
	          --     || p_params(2) || ':'
	              );
          END IF;
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          IF ( l_param_2 = 'NULL' ) THEN
                l_param_2 := NULL;
          END IF;

          IBY_FD_EXTRACT_GEN_PVT.CREATE_PPR_EXTRACT_1_0 (
             p_payment_service_request_id  => to_number(l_param_1),
             p_sys_key          => HEXTORAW(l_param_2),
             x_extract_doc      => x_extract_doc
             );
       ELSIF (   upper(l_code_pkg)   = 'IBY_FD_EXTRACT_GEN_PVT'
          AND upper(l_code_entry) = 'CREATE_POS_PAY_EXTRACT_1_0'
          AND p_params.COUNT IN (5,8)          -- Bug 6673696
          AND p_extract_version = 1) THEN

       IF ( p_params.COUNT = 5) THEN

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name
	             , 'Calling CREATE_POS_PAY_EXTRACT_1_0 with 5 params:'
	             );
 		  --Do not log p_param(5) as it contains sensitive data
	          print_debuginfo(l_module_name
	             , '5 params:'
	               || p_params(1) || ':'
	               || p_params(2) || ':'
	               || p_params(3) || ':'
	               || p_params(4) || ':'
	            --   || p_params(5) || ':'
	             );
          END IF;
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          l_param_3 := stripped_string (p_params(3), '''');
          l_param_4 := stripped_string (p_params(4), '''');
          l_param_5 := stripped_string (p_params(5), '''');

          IF ( l_param_5 = 'NULL' ) THEN
                l_param_5 := NULL;
          END IF;

          IBY_FD_EXTRACT_GEN_PVT.CREATE_POS_PAY_EXTRACT_1_0 (
             p_payment_instruction_id  =>to_number(l_param_1),
             p_payment_profile_id      =>to_number(l_param_2),
             p_from_date               => l_param_3,
             p_to_date                 => l_param_4,
             p_sys_key                 => HEXTORAW(l_param_5),
             x_extract_doc             => x_extract_doc
             );
	ELSE

          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	          print_debuginfo(l_module_name
	             , 'Calling CREATE_POS_PAY_EXTRACT_2_0 with 8 params:'
	             );

 		  --Do not log p_param(8) as it contains sensitive data
	          print_debuginfo(l_module_name
	             , '8 params:'
	               || p_params(1) || ':'
	               || p_params(2) || ':'
	               || p_params(3) || ':'
	               || p_params(4) || ':'
	               || p_params(5) || ':'
	               || p_params(6) || ':'
	               || p_params(7) || ':'
	          --     || p_params(8) || ':'
	             );
          END IF;
          l_param_1 := stripped_string (p_params(1), '''');
          l_param_2 := stripped_string (p_params(2), '''');
          l_param_3 := stripped_string (p_params(3), '''');
          l_param_4 := stripped_string (p_params(4), '''');
          l_param_5 := stripped_string (p_params(5), '''');
          l_param_6 := stripped_string (p_params(6), '''');
          l_param_7 := stripped_string (p_params(7), '''');
          l_param_8 := stripped_string (p_params(8), '''');

          IF ( upper(l_param_8) = 'NULL' ) THEN
                l_param_8 := NULL;
          END IF;

          IBY_FD_EXTRACT_GEN_PVT.CREATE_POS_PAY_EXTRACT_2_0 (
                p_payment_instruction_id =>to_number(l_param_1),
                p_format_name      => l_param_2,
                p_internal_bank_account_name            => l_param_3,
                p_from_date        => l_param_4,
                p_to_date        => l_param_5,
                p_payment_status        => l_param_6,
                p_reselect        => l_param_7,
                p_sys_key                => HEXTORAW(l_param_8),
                x_extract_doc            => x_extract_doc
             );

       END IF;
   ELSE
   /* End of Bug 6016869 */
    -- provide the extract document OUT parameter
    p_params.extend(1);
    p_params(p_params.LAST) := null;

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo(l_module_name, 'Calling Extract Dynamically');
	      print_debuginfo(l_module_name, 'p_params.COUNT' || p_params.COUNT );
	      print_debuginfo(l_module_name, 'l_code_entry: ' || l_code_entry);
	      print_debuginfo(l_module_name, 'l_code_pkg: ' || l_code_pkg);

      END IF;

    l_call := iby_utility_pvt.get_call_exec(l_code_pkg,l_code_entry,p_params);
--dbms_output.put_line('call:=<' || l_call || '>');

    EXECUTE IMMEDIATE l_call USING OUT x_extract_doc;

  END IF;

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       print_debuginfo(l_module_name, 'Appending XML Character Encoding Header');
  END IF;
  x_extract_doc := IBY_EXTRACTGEN_PVT.Get_XML_Char_Encoding_Header || x_extract_doc;

  IF l_numeric_char_mask <> l_default_num_mask THEN
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '||
                         '"'||l_numeric_char_mask|| '"';
  END IF;

  END create_extract;


  FUNCTION Get_Dffs(p_entity_table IN VARCHAR2, p_entity_id IN NUMBER, p_entity_code IN VARCHAR2)
  RETURN XMLTYPE
  IS
    l_dffs XMLTYPE;
    l_queryString VARCHAR2(4000); -- Bug 6827266
    l_num_of_attributes NUMBER;
    l_from_clause VARCHAR2(512);
    l_where_clause VARCHAR2(2000); -- Bug 6827266
    l_ap_attr_cat  VARCHAR2(150);
    l_hzp_attr_cat  VARCHAR2(150);
    l_attribute_category VARCHAR2(150);
    l_conc_invalid_chars VARCHAR2(50);
    l_conc_replacement_chars VARCHAR2(50);

/* Removed the cursor l_ap_doc_attr_cat_csr for the bug Bug 6763515*/


    CURSOR l_hzp_attr_cat_csr (p_party_id IN NUMBER) IS
    SELECT attribute_category
      FROM hz_parties
     WHERE party_id = p_party_id;

    l_Debug_Module   VARCHAR2(255) := G_DEBUG_MODULE || '.Get_Dffs';
  BEGIN
      /* Preparing the concatinated strings of invalid characters
      and corresponding replacement characters.  */
      FOR i in 1..32 LOOP
        l_conc_invalid_chars :=l_conc_invalid_chars||fnd_global.local_chr(i-1);
        l_conc_replacement_chars :=l_conc_replacement_chars||' ';
      END LOOP;

    IF p_entity_id IS NULL AND p_entity_code IS NULL THEN
      RETURN NULL;
    END IF;

    print_debuginfo (l_debug_module, 'p_entity_table : '||p_entity_table);
    print_debuginfo (l_debug_module, 'p_entity_id : '||p_entity_id);
    print_debuginfo (l_debug_module, 'p_entity_code : '||p_entity_code);

    IF p_entity_table = G_DFF_FD_PAYMENT_METHOD THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where payment_method_code = :p_entity_code ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_PAYMENT_METHODS_B
      WHERE payment_method_code = p_entity_code;

    ELSIF p_entity_table = G_DFF_FD_PAYMENT_PROFILE THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where system_profile_code = :p_entity_code ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_SYS_PMT_PROFILES_B
      WHERE system_profile_code = p_entity_code;

    ELSIF p_entity_table = G_DFF_FD_PAY_INSTRUCTION THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where payment_instruction_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_PAY_INSTRUCTIONS_ALL
      WHERE payment_instruction_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_FD_PAYMENT THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where payment_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_PAYMENTS_ALL
      WHERE payment_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_FD_DOC_PAYABLE THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where document_payable_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_DOCS_PAYABLE_ALL
      WHERE document_payable_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_FORMAT THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where format_code = :p_entity_code ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_FORMATS_B
      WHERE format_code = p_entity_code;

    ELSIF p_entity_table = G_DFF_BEP_ACCOUNT THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where bep_account_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_BEPKEYS
      WHERE bep_account_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_LEGAL_ENTITY THEN
      l_num_of_attributes := 20;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where legal_entity_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM XLE_FIRSTPARTY_INFORMATION_V
      WHERE legal_entity_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_PARTY THEN

       IF (NOT(l_att_cat_tbl.EXISTS(p_entity_id))) THEN
	      OPEN l_hzp_attr_cat_csr (p_entity_id);
	      FETCH l_hzp_attr_cat_csr INTO l_att_cat_tbl(p_entity_id).l_hzp_attr_cat;
	      CLOSE l_hzp_attr_cat_csr;
       END IF;

      IF l_att_cat_tbl(p_entity_id).l_hzp_attr_cat IS NULL THEN
        RETURN NULL;
      END IF;

      l_num_of_attributes := 24;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where party_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM HZ_PARTIES
      WHERE party_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_INT_BANK_ACCOUNT THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where bank_account_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM CE_BANK_ACCOUNTS
      WHERE bank_account_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_EXT_BANK_ACCOUNT THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where ext_bank_account_id = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM IBY_EXT_BANK_ACCOUNTS
      WHERE ext_bank_account_id = p_entity_id;

    ELSIF p_entity_table = G_DFF_PO_VENDORS THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where VENDOR_ID = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM PO_VENDORS
      WHERE VENDOR_ID = p_entity_id;

    ELSIF p_entity_table = G_DFF_PO_VENDOR_SITES THEN
      l_num_of_attributes := 15;
      l_from_clause := ' From ' || p_entity_table;
      l_where_clause := ' Where VENDOR_SITE_ID = :p_entity_id ';
      SELECT attribute_category
      INTO l_attribute_category
      FROM PO_VENDOR_SITES_ALL
      WHERE VENDOR_SITE_ID = p_entity_id;

    ELSIF p_entity_table = G_DFF_AP_DOC THEN

/* Bug 6763515*/
      print_debuginfo (l_debug_module, 'Before Execution the query for the table:'||G_DFF_AP_DOC);

      SELECT attribute_category
      INTO l_attribute_category
      FROM iby_docs_payable_all idp
	    WHERE idp.document_payable_id = p_entity_id;

    IF(l_attribute_category IS NULL) THEN
	  Select XMLConcat(XMLElement("AttributeCategory", attribute_category),
		 XMLElement("Attribute1", attribute1), XMLElement("Attribute2", attribute2),
		 XMLElement("Attribute3", attribute3), XMLElement("Attribute4", attribute4),
		 XMLElement("Attribute5", attribute5), XMLElement("Attribute6", attribute6),
		 XMLElement("Attribute7", attribute7), XMLElement("Attribute8", attribute8),
		 XMLElement("Attribute9", attribute9), XMLElement("Attribute10", attribute10),
		 XMLElement("Attribute11", attribute11), XMLElement("Attribute12", attribute12),
		 XMLElement("Attribute13", attribute13), XMLElement("Attribute14", attribute14),
		 XMLElement("Attribute15", attribute15))
	 INTO l_dffs
	 From iby_docs_payable_all idp
	 WHERE idp.document_payable_id = p_entity_id;

    ELSE
	  Select XMLConcat(XMLElement("AttributeCategory", attribute_category),
		 XMLElement("Attribute1", TRANSLATE(attribute1,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute2", TRANSLATE(attribute2,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute3", TRANSLATE(attribute3,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute4", TRANSLATE(attribute4,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute5", TRANSLATE(attribute5,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute6", TRANSLATE(attribute6,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute7", TRANSLATE(attribute7,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute8", TRANSLATE(attribute8,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute9", TRANSLATE(attribute9,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute10", TRANSLATE(attribute10,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute11", TRANSLATE(attribute11,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute12", TRANSLATE(attribute12,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute13", TRANSLATE(attribute13,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute14", TRANSLATE(attribute14,l_conc_invalid_chars,l_conc_replacement_chars)),
		 XMLElement("Attribute15", TRANSLATE(attribute15,l_conc_invalid_chars,l_conc_replacement_chars)))
	 INTO l_dffs
	 From iby_docs_payable_all idp
	 WHERE idp.document_payable_id = p_entity_id;
   END IF;
    print_debuginfo (l_debug_module, 'After Execution the query for the table: '||G_DFF_AP_DOC);

 /* Bug 6763515*/
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_entity_table <> G_DFF_AP_DOC)  THEN
    l_queryString := 'Select XMLConcat(XMLElement("AttributeCategory", attribute_category), ';


    FOR i in 1..l_num_of_attributes LOOP
      --Fix for bug# 6141186
      --Appended i with "Attribute"
      IF(l_attribute_category IS NULL) THEN
      l_queryString := l_queryString || 'XMLElement("Attribute'||i||'", attribute' || i ||')';
       ELSE
      l_queryString := l_queryString || 'XMLElement("Attribute'||i||'", TRANSLATE(attribute' || i ||','''||l_conc_invalid_chars||''','''||l_conc_replacement_chars||'''))';
       END IF;

      IF i < l_num_of_attributes THEN
        l_queryString := l_queryString || ', ';
      ELSE
        l_queryString := l_queryString || ') ';
      END IF;

    END LOOP;

    l_queryString := l_queryString || l_from_clause || l_where_clause;

    print_debuginfo (l_debug_module, 'B4 Execution l_queryString : '||l_queryString);

     IF p_entity_table = G_DFF_FD_PAYMENT_METHOD
        or p_entity_table = G_DFF_FD_PAYMENT_PROFILE
        or p_entity_table = G_DFF_FORMAT THEN
           EXECUTE IMMEDIATE l_queryString INTO l_dffs using p_entity_code;
     ELSIF p_entity_table = G_DFF_FD_PAY_INSTRUCTION
        or p_entity_table = G_DFF_FD_PAYMENT
        or p_entity_table = G_DFF_FD_DOC_PAYABLE
        or p_entity_table = G_DFF_BEP_ACCOUNT
        or p_entity_table = G_DFF_LEGAL_ENTITY
        or p_entity_table = G_DFF_PARTY
        or p_entity_table = G_DFF_INT_BANK_ACCOUNT
        or p_entity_table = G_DFF_EXT_BANK_ACCOUNT
        or p_entity_table = G_DFF_PO_VENDORS
        or p_entity_table = G_DFF_PO_VENDOR_SITES THEN
           EXECUTE IMMEDIATE l_queryString INTO l_dffs using p_entity_id;
     END IF;
    END IF;
    RETURN l_dffs;

  EXCEPTION WHEN OTHERS THEN
    print_debuginfo (l_debug_module, 'Error in fetching Get_Dffs: '||sqlerrm);
    print_debuginfo (l_debug_module, 'l_queryString : '||l_queryString);
    RAISE;
  END Get_Dffs;

  -- This function is general for the formatting of files
  -- It allows passing parameters to the XDO template generator
  -- Args: p_template_code.  XDO template code
  --       p_parameters_code.  The code for the parameters we want to use in the
  --                           template during formatting
  --       p_parameters_value. Value of the parameters
  -- The 2 arrays should be defined with the same number of elements
  PROCEDURE get_template_parameters
  (
    p_template_code         IN    iby_formats_b.format_template_code%TYPE,
    p_pay_instruction       IN    VARCHAR2,
    p_parameters_code       OUT NOCOPY JTF_VARCHAR2_TABLE_200,
    p_parameters_value      OUT NOCOPY JTF_VARCHAR2_TABLE_200
  ) IS

    l_module_name      CONSTANT VARCHAR2(200) := G_PKG_NAME || '.get_template_parameters';
    l_filename         fnd_concurrent_requests.outfile_name%TYPE;

  BEGIN

    -- initialize output parameters
    p_parameters_code := JTF_VARCHAR2_TABLE_200();
    p_parameters_value := JTF_VARCHAR2_TABLE_200();

    IF (p_template_code = 'IBYAL_PT') THEN
      -- get the filename and return in to be set as a template parameter

      BEGIN
        SELECT x.filename
          INTO l_filename
          FROM (SELECT SUBSTR(fcr.outfile_name,INSTR(fcr.outfile_name,'/',-1)+1) filename,
                       rank() over(partition by pi.payment_instruction_id order by pcc.request_id desc) c_rank
                  FROM iby_process_conc_requests pcc,
                       fnd_concurrent_requests fcr,
                       iby_pay_instructions_all pi,
                       iby_acct_pmt_profiles_b ap,
                       iby_sys_pmt_profiles_b sp,
                       iby_formats_b f
                 WHERE pcc.object_type = 'PAYMENT_INSTRUCTION'
                   AND pcc.request_id = fcr.request_id
                   AND pcc.object_id = pi.payment_instruction_id
                   AND ap.payment_profile_id = pi.payment_profile_id
                   AND ap.system_profile_code = sp.system_profile_code
                   AND f.format_code = sp.payment_format_code
                   AND f.format_template_code = p_template_code
                   AND pi.payment_instruction_id = TO_NUMBER(p_pay_instruction)) x
         WHERE x.c_rank=1;

      EXCEPTION
        WHEN others THEN NULL;
      END;

      IF (l_filename IS NOT NULL) THEN
        p_parameters_code.extend(1);
        p_parameters_code(p_parameters_code.LAST) := 'P_FILENAME';

        p_parameters_value.extend(1);
        p_parameters_value(p_parameters_value.LAST) := l_filename;
      END IF;

    END IF;


  END ;

  FUNCTION Get_XML_Char_Encoding_Header
  RETURN VARCHAR2
  IS
            l_encoding             VARCHAR2(50);
            l_xml_header           VARCHAR2(1000);
            l_module_name      CONSTANT VARCHAR2(200) := G_PKG_NAME || '.Get_XML_Char_Encoding_Header';

 BEGIN

    -- Bugs 8910544 and 8922250
    l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name,'l_encoding : ' || l_encoding);
     END IF;

     IF((l_encoding IS NOT NULL) AND (LENGTH(l_encoding)>0)) THEN
     l_xml_header     := '<?xml version="'||'1.0'||'" encoding="'||l_encoding||'"?>';
     ELSE
       l_xml_header     := '<?xml version="'||'1.0'||'" encoding="'||'UTF-8'||'"?>';
     END IF;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          print_debuginfo(l_module_name,'l_xml_header : ' || l_xml_header);
     END IF;
            RETURN l_xml_header;
 END Get_XML_Char_Encoding_Header;


END IBY_EXTRACTGEN_PVT;

/
