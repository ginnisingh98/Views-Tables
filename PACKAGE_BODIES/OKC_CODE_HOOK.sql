--------------------------------------------------------
--  DDL for Package Body OKC_CODE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CODE_HOOK" AS
/* $Header: OKCCCHKB.pls 120.0.12010000.18 2013/08/26 08:39:31 serukull noship $ */

   /* Global constants*/
   g_pkg_name              CONSTANT VARCHAR2 (200) := 'OKC_XPRT_CODE_HOOK';
   g_app_name              CONSTANT VARCHAR2 (3)   := okc_api.g_app_name;
   g_module                CONSTANT VARCHAR2 (250)
                                         := 'okc.plsql.' || g_pkg_name || '.';
   g_false                 CONSTANT VARCHAR2 (1)   := fnd_api.g_false;
   g_true                  CONSTANT VARCHAR2 (1)   := fnd_api.g_true;
   g_okc                   CONSTANT VARCHAR2 (3)   := 'OKC';
   g_ret_sts_success       CONSTANT VARCHAR2 (1) := fnd_api.g_ret_sts_success;
   g_ret_sts_error         CONSTANT VARCHAR2 (1)   := fnd_api.g_ret_sts_error;
   g_ret_sts_unexp_error   CONSTANT VARCHAR2 (1)
                                             := fnd_api.g_ret_sts_unexp_error;
   g_unexpected_error      CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'ERROR_CODE';


  G_DBG_LEVEL							  NUMBER 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_PROC_LEVEL							NUMBER		:= FND_LOG.LEVEL_PROCEDURE;
  G_EXCP_LEVEL							NUMBER		:= FND_LOG.LEVEL_EXCEPTION;


/* PROCEDURE
GET_MULTIVAL_UDV_FOR_XPRT    This routine is used to get the multiple values for variables in expert.

INPUT PARAMETERS

p_doc_type   Document Type of Contract(eg: PO_STANDARD)
p_doc_id     Document_id of contract.
p_udf_var_code   Variable Code


RETURN VALUE
   X_RETURN_STATUS:   Standard out variable to return the final API execution status.
   X_MSG_COUNT    :    Standard out variable to return the number of messages.
   X_MSG_DATA     :   Standard out variable to return the message string.
   x_order_by_column         Table which return variable-code and variable value of every variable. If multi values are to be returned for
   x_hook_used                 0   Hook has not been used
                               -1   Error in Hook
                               Any other value Hook is used
    NOTE: Use all OUT and IN OUT parameter with NOCOPY option.

 This procedure 'GET_MULTIVAL_UDV_FOR_XPRT' will be called for every user defined variable with procedure. Variable code is given as i/p for this procedure so that user can write logic if needed.
  Users need to code for fetching the desired values for their variables here. This is required only for variables which have to return multiple values during expert.
 The x_cust_udf_var_mul_val_tbl should have variable_code and variable_value_id as output.

***********************************************************************************************************
 Eg:  x_cust_udf_var_tbl_values(j).variable_code     := 'VARIABLE_CODE';
      x_cust_udf_var_tbl_values(j).variable_value_id := <VARIABLE_VALUE>;
***********************************************************************************************************

x_hook_code needs to be populated to any value other than '0' for every variable. This value is responsible to check from which pl/sql the values need to be fetched.
 */
   PROCEDURE get_multival_udv_for_xprt (
      p_api_version                IN              NUMBER,
      p_init_msg_list              IN              VARCHAR2,
      p_doc_type                   IN              VARCHAR2,
      p_doc_id                     IN              NUMBER,
      p_udf_var_code               IN              VARCHAR2,
      x_return_status              OUT NOCOPY      VARCHAR2,
      x_msg_count                  OUT NOCOPY      NUMBER,
      x_msg_data                   OUT NOCOPY      VARCHAR2,
      x_cust_udf_var_mul_val_tbl   OUT NOCOPY      okc_xprt_xrule_values_pvt.udf_var_value_tbl_type,
      x_hook_used                  OUT NOCOPY      NUMBER
   )
   IS
   BEGIN
      x_hook_used := 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_hook_used := -1;
   END get_multival_udv_for_xprt;

/* PROCEDURE
GET_XPRT_CLAUSE_ORDER    This routine is used to get the column on which the clauses have to be ordered after the Contract Expert is run

INPUT PARAMETERS

None


RETURN VALUE
   X_RETURN_STATUS:   Standard out variable to return the final API execution status.
   X_MSG_COUNT    :   Standard out variable to return the number of messages.
   X_MSG_DATA     :   Standard out variable to return the message string.
   x_order_by_column         Column on which the clauses have to be ordered
   x_hook_used                 0   Hook has not been used
                               1   Hook is used
    NOTE: Use all OUT and IN OUT parameter with NOCOPY option.

 This procedure 'GET_XPRT_CLAUSE_ORDER' will be called from OKC_TERMS_MULTIGRP_REC.sync_doc_with_expert when the contract expert is run.
 Currently ordering based on Clause Number is only supported. x_order_by_column is assigned to 'CLAUSE_NUMBER'.
 x_hook_used needs to be populated to 1 if the ordering based on Clause Number is required.
 */
   PROCEDURE get_xprt_clause_order (
      x_return_status     IN OUT NOCOPY   VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_order_by_column   OUT NOCOPY      VARCHAR2,
      x_hook_used         OUT NOCOPY      NUMBER
   )
   IS
   BEGIN
      x_hook_used := 0;
      x_order_by_column := 'CLAUSE_NUMBER';
   EXCEPTION
      WHEN OTHERS
      THEN
         x_hook_used := -1;
   END get_xprt_clause_order;

/* FUNCTION
 IS_NOT_PROVISIONAL_SECTION    This routine is used to find out if a section is a provisional section or not
If it returns true, then it is not a provisional section.
Or else, it is a provisional section
INPUT PARAMETERS

None


RETURN VALUE
   p_section_heading            IN  VARCHAR2,            Section that has to be checked if it is a provisional section or not
*/
   FUNCTION is_not_provisional_section (
   p_section_heading   IN VARCHAR2
  ,p_source_doc_type   IN  VARCHAR2 default null
  ,p_source_doc_id     IN NUMBER default null)
  RETURN VARCHAR2
   IS
      x_hook_used   NUMBER;
   BEGIN
      x_hook_used := 1;

      IF x_hook_used = 1
      THEN
--Copy the following if block with the section names within the quotes.
--One IF block is required for each section name
--Note that the section name is case-sensitive
         IF p_section_heading = ' '
         THEN
            RETURN fnd_api.g_false;
         END IF;
      END IF;

      RETURN fnd_api.g_true;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_hook_used := -1;
   END is_not_provisional_section;

/* FUNCTION
 IS_NEW_KFF_ITEM_SEG_ENABLED    This routine is used to decide on whether the new Item KFF segment setup should be considered during Contract Expert rule execution.
INPUT PARAMETERS
None

RETURN VALUE
BOOLEAN : TRUE if the new item seg setup is enabled, FALSE otherwise
*/
   FUNCTION is_new_kff_item_seg_enabled
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN FALSE;
   -- RETURN TRUE;
   END;




  /*
   * Enable this procedure when you are using Mandatory and RWA columns on Rule Outcomes
   * and you want these flags to be synced with the document.
   *
   * Added by serukull
   *
   */


   PROCEDURE sync_rwa_with_document (
      p_api_version     IN              NUMBER,
      p_init_msg_list   IN              VARCHAR2,
      p_doc_type        IN              VARCHAR2,
      p_doc_id          IN              NUMBER,
      p_article_id_tbl  IN              okc_terms_multirec_grp.article_id_tbl_type,
      x_return_status   IN OUT NOCOPY   VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER,
      x_msg_data        OUT NOCOPY      VARCHAR2
   )
   IS
      l_template_id   NUMBER;
      l_intent        VARCHAR2 (1);
      l_org_id        NUMBER;


      l_tmp_lvl_mandatory_flag varchar2(1);

      TYPE outcome_rec_type IS RECORD (clause_id NUMBER,mandatory_yn OKC_XPRT_RULE_OUTCOMES.mandatory_yn%TYPE
                  , mandatory_rwa OKC_XPRT_RULE_OUTCOMES.mandatory_rwa%type);

      TYPE outcome_tbl_type IS TABLE OF outcome_rec_type INDEX BY PLS_INTEGER;

      TYPE clause_id_tbl_type IS TABLE OF NUMBER INDEX BY PLS_INTEGER;

      l_outcome_tbl   outcome_tbl_type;
      l_clause_id_tbl  clause_id_tbl_type;
   BEGIN

    /* -- Comment Start  -- Comment this line if you want sync RWA

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
		      G_PKG_NAME, '100: sync_rwa_with_document Start');
      END IF;

      -- Get the template id from document usages
      SELECT template_id
        INTO l_template_id
        FROM okc_template_usages
       WHERE document_type = p_doc_type AND document_id = p_doc_id;

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
		      G_PKG_NAME, '110: sync_rwa_with_document : After getting Template_id '|| l_template_id);
      END IF;

      --  Get the intent and org_id from the template
      SELECT  intent, org_id,   xprt_clause_mandatory_flag

       INTO  l_intent, l_org_id, l_tmp_lvl_mandatory_flag
      FROM   okc.okc_terms_templates_all

      WHERE  template_id = l_template_id;

      IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
          FND_LOG.STRING(G_PROC_LEVEL,
		      G_PKG_NAME, '120: sync_rwa_with_document : After getting Intent as '|| l_intent ||' and Org id as' ||l_org_id );
      END IF;


      -- Get the clause outcomes of rules attached to the template
      SELECT  outcome.object_value_id,outcome.mandatory_yn, outcome.mandatory_rwa
        bulk COLLECT INTO  l_outcome_tbl
        FROM (SELECT rule.rule_id rule_id
                FROM okc_xprt_rule_hdrs rule,
                     okc_xprt_template_rules trule,
                     fnd_lookups lkup,
                     fnd_lookups ruletypelkup
               WHERE rule.rule_id = trule.rule_id
                 AND trule.template_id = l_template_id
                 AND rule.status_code = lkup.lookup_code
                 AND lkup.lookup_type = 'OKC_XPRT_RULE_STATUS'
                 AND rule.status_code  =  'ACTIVE'
                 AND ruletypelkup.lookup_type = 'OKC_XPRT_RULE_TYPE'
                 AND rule.rule_type = ruletypelkup.lookup_code
              UNION ALL
              -- Get the org wide rules
              SELECT rule.rule_id rule_id
                FROM okc_xprt_rule_hdrs rule,
                     fnd_lookups lkup,
                     fnd_lookups ruletypelkup
               WHERE rule.status_code = lkup.lookup_code
                 AND lkup.lookup_type = 'OKC_XPRT_RULE_STATUS'
                 AND rule.status_code = 'ACTIVE'
                 AND ruletypelkup.lookup_type = 'OKC_XPRT_RULE_TYPE'
                 AND rule.rule_type = ruletypelkup.lookup_code
                 AND org_id = l_org_id
                 AND intent = l_intent
                 AND org_wide_flag = 'Y') rule,
                 okc_xprt_rule_outcomes outcome
           WHERE outcome.rule_id     = rule.rule_id
             AND outcome.object_type = 'CLAUSE';

          IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
           FND_LOG.STRING(G_PROC_LEVEL,
		      G_PKG_NAME, '130: sync_rwa_with_document : Outcome clauses '|| l_outcome_tbl.count);
          END IF;

          -- Create structure similar to Hasmap from the input articles.
          IF p_article_id_tbl.COUNT > 0 THEN
           FOR i IN p_article_id_tbl.first..p_article_id_tbl.last LOOP
                l_clause_id_tbl(p_article_id_tbl(i)) := 1;
           END LOOP;

            IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_PROC_LEVEL,
		           G_PKG_NAME, '140: sync_rwa_with_document : Created Hash');
            END IF;

          END IF;

          -- Delete the outcome record from the table structure, if it does not exists in the hasmap
          FOR i IN 1.. l_outcome_tbl.Count
           LOOP
             IF  l_clause_id_tbl.EXISTS(l_outcome_tbl(i).clause_id) = FALSE THEN
                 l_outcome_tbl.DELETE(i);
             END IF;
           END LOOP;

           IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_PROC_LEVEL,
		           G_PKG_NAME, '140: sync_rwa_with_document : After setting Outcome table');
           END IF;

          -- Execute the update statement
          -- Oracle Database 10g Release 1 (10.1.0.2)
          FORALL i IN indices OF l_outcome_tbl
                 UPDATE okc_k_articles_b
                    SET   mandatory_yn  = Nvl(l_outcome_tbl(i).mandatory_yn,l_tmp_lvl_mandatory_flag)
                         ,mandatory_rwa = l_outcome_tbl(i).mandatory_rwa
                 WHERE  document_type = p_doc_type
                  AND   document_id   = p_doc_id
                  AND   sav_sae_id    = l_outcome_tbl(i).clause_id ;

         IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
               FND_LOG.STRING(G_PROC_LEVEL,
		           G_PKG_NAME, '140: sync_rwa_with_document : After updating okc_k_articles_b table');
         END IF;

		  IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
           FND_LOG.STRING(G_PROC_LEVEL,
		        G_PKG_NAME, '100: sync_rwa_with_document End');
          END IF;

		  */  -- Comment End  -- Comment this line if you want sync RWA

          x_return_status := g_ret_sts_success;


   EXCEPTION
      WHEN OTHERS
      THEN
          IF ( G_PROC_LEVEL >= G_DBG_LEVEL ) THEN
              FND_LOG.STRING(G_PROC_LEVEL,
		          G_PKG_NAME, '100: sync_rwa_with_document Exception');
          END IF;

         RAISE;
   END sync_rwa_with_document;


 /*
  * Enable this procedure if custom QA checks has to be added for the Contract Expert Rules Activation
  * Parameters  : INPUT : p_rule_id - Rule corresponding to which the QA check will be run
  *                       p_sequence_id - for future use. No significant need of using this parameter as of now
  *               OUTPUT: x_hook_used - 0 - not used
  *                                     1 - used
  *                       x_qa_errors_tbl - This table should be populated with the QA check message details.
  *                       More than one QA check can be written in this package and in this case, one row has to be entered in this table for each QA check message.
  */



  PROCEDURE rules_qa_check
       (
        p_rule_id		     IN NUMBER,
        p_sequence_id	   IN NUMBER,
		    x_hook_used      OUT NOCOPY NUMBER,
		    x_qa_errors_tbl  OUT NOCOPY l_qa_errors_table,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2
       )
          IS

     l_rule_id   NUMBER :=0;

   BEGIN

      x_return_status := 'S';
      x_hook_used := 0;               -- Assign 1 to this if the code in this procedure should be considered by the standard flow

      EXCEPTION
      WHEN OTHERS THEN
         x_hook_used := -1;
         x_return_status := 'E';
      END rules_qa_check;


	PROCEDURE sort_clauses(
		p_doc_type                     IN  VARCHAR2,
		p_doc_id                       IN  NUMBER,
		x_return_status                OUT NOCOPY VARCHAR2,
		x_msg_count                    OUT NOCOPY NUMBER,
		x_msg_data                     OUT NOCOPY VARCHAR2,
		x_cont_art_tbl                 OUT NOCOPY cont_art_sort_tbl
		) IS

		 l_api_version                 CONSTANT NUMBER := 1;
		 l_api_name                    CONSTANT VARCHAR2(30) := 'sort_clauses';

		cursor c_sort_articles is
		SELECT id, scn_id from
		(SELECT id,scn_id,article_number,
		Decode(InStr(article_number,'.'),0,Decode(InStr(article_number,' '),0,Decode(regexp_instr(article_number,'[a-zA-Z]'),0,article_number,NULL),SubStr(article_number,1, InStr(article_number,' ')-1)),
		SubStr(article_number,1, InStr(article_number,'.')-1)) col1,
		Decode(InStr(article_number,'-'),0,Decode(InStr(article_number,' '),0,Decode(InStr(article_number,'.'),0,0,SubStr(article_number,InStr(article_number,'.')+1)),decode(instr(article_number,'.'),0,0,
		SubStr(article_number,InStr(article_number,'.')+1,InStr(article_number,' ')-InStr(article_number,'.')))),SubStr(article_number,InStr(article_number,'.')+1, InStr(article_number,'-')-InStr(article_number,'.')-1)) col2,
		Decode(InStr(article_number,' '),0,Decode(InStr(article_number,'-'),0,0,SubStr(article_number,InStr(article_number,'-')+1)),
		Decode(InStr(article_number,'-'),0,0,SubStr(article_number,InStr(article_number,'-')+1, InStr(article_number,' ')-InStr(article_number,'-')-1))) col3,
		Decode(InStr(article_number,' '),0,' ',SubStr(article_number,InStr(article_number,' ')+1)) col4
		FROM okc_k_articles_b,okc_articles_all
		WHERE document_type=p_doc_type AND
		document_id=p_doc_id AND
		sav_sae_id=article_id
		ORDER BY scn_id,To_Number(col1),To_Number(col2),To_Number(col3),col4);


		cursor c_sort_aplhanumeric is
		SELECT id,scn_id
		FROM okc_k_articles_b,okc_articles_all
		WHERE document_type=p_doc_type AND
		document_id=p_doc_id AND
		sav_sae_id=article_id
		ORDER BY scn_id,article_number;

		BEGIN
			begin
				OPEN c_sort_articles;
				FETCH c_sort_articles BULK COLLECT INTO x_cont_art_tbl;
				CLOSE c_sort_articles;
				exception
				when others then
				if c_sort_articles%ISOPEN then
					close c_sort_articles;
				end if;
				OPEN c_sort_aplhanumeric;
				FETCH c_sort_aplhanumeric BULK COLLECT INTO x_cont_art_tbl;
				CLOSE c_sort_aplhanumeric;
			end;
			EXCEPTION
			WHEN OTHERS THEN
			x_return_status := 'E';
	END sort_clauses;

END okc_code_hook;

/
