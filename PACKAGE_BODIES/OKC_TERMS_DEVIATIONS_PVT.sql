--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_DEVIATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_DEVIATIONS_PVT" AS
/* $Header: OKCVTDRB.pls 120.4.12000000.3 2007/08/01 11:58:32 ndoddi ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_DEVIATIONS_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(200) := 'okc.plsql.'||G_PKG_NAME||'.';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := OKC_API.G_APP_NAME;
  G_UNASSIGNED_SECTION_CODE    CONSTANT   VARCHAR2(30)  := 'UNASSIGNED';
  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  ------------------------------------------------------------------------------
  -- GLOBAL EXCEPTIONS
  ------------------------------------------------------------------------------
  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

/*
-- PROCEDURE Populate_Template_Articles
-- To be used to delete populate the global temp table with articles on
-- the current version of the template.
*/
PROCEDURE Populate_Template_Articles (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_template_id      IN  NUMBER,
    p_doc_type		   IN VARCHAR2
) is
   l_api_name            CONSTANT VARCHAR2(30) := 'POPULATE_TEMPLATE_ARTICLES';
   l_scn_id              scn_id_tbl;
   l_article_id          article_id_tbl;
   l_display_sequence    display_sequence_tbl;
   l_mandatory_flag      mandatory_flag_tbl;
   l_label               label_tbl;
   l_article_version_id  article_version_id_tbl;
   l_art_seq_id          art_seq_id_tbl;
   l_orig_article_id     orig_article_id_tbl;

   l_provision_allowed   varchar2(1);
Begin

-- check if the document allows provisions, if not then the
-- provisions should not be copied into the table
--
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '100: Entered POPULATE_TEMPLATE_ARTICLES');
  END IF;

  Select nvl(provision_allowed_YN,'N')
    INTO l_provision_allowed
    From okc_bus_doc_types_b
   Where document_type = p_doc_type;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                            '110: Provision Allowed : '||l_provision_allowed);
  END IF;


  If (l_provision_allowed = 'Y') then

    Select SCN_ID,
           SAV_SAE_ID ,
           Display_Sequence,
           Mandatory_YN ,
           Label,
           okc_terms_util_pvt.get_latest_tmpl_art_version_id(sav_sae_id,
						      sysdate),
           id,
           sav_sae_id orig_article_id
    BULK COLLECT INTO
           l_scn_id,
           l_article_id,
           l_display_sequence,
           l_mandatory_flag,
           l_label,
           l_article_version_id,
           l_art_seq_id,
           l_orig_article_id
    From
           okc_k_articles_b
    Where  document_Type = 'TEMPLATE'
      And  document_Id = p_template_id;

  else -- provision_allowed = N

    Select SCN_ID,
           SAV_SAE_ID ,
           Display_Sequence,
           Mandatory_YN ,
           Label,
           okc_terms_util_pvt.get_latest_tmpl_art_version_id(sav_sae_id,
                                    sysdate),
           id,
           sav_sae_id orig_article_id
    BULK COLLECT INTO
           l_scn_id,
           l_article_id,
           l_display_sequence,
           l_mandatory_flag,
           l_label,
           l_article_version_id,
           l_art_seq_id,
           l_orig_article_id
    From
           okc_k_articles_b oab
    Where  document_Type = 'TEMPLATE'
      And  document_Id = p_template_id
      And  Exists (Select 1 From okc_article_versions oav
                    Where oab.sav_sae_id = oav.article_id
				  And oav.provision_yn = 'N');

  end if; -- l_provision_allowed

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                          '120: After DEVIATION CATEGORY Bulk Collect');
   END IF;

 If (l_article_id.count > 0) then

  FORALL i IN l_scn_id.FIRST..l_scn_id.LAST
  INSERT INTO okc_terms_deviations_temp (Scn_id,
	article_id,
	display_sequence,
     mandatory_flag,
	label,
	article_version_id,
	source_flag,
	orig_article_id)
   VALUES
     (l_scn_id(i),
	l_article_id(i),
	l_display_sequence(i),
     l_mandatory_flag(i),
	l_label(i),
	l_article_version_id(i),
	'T',
	l_orig_article_id(i));

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                          '130: Inserted TEMPLATE data in Global Temp Table');
    END IF;
 end if;

  x_return_status := G_RET_STS_SUCCESS;

Exception

  When OTHERS then

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_api_name,
                '140: Leaving Populate_Teamplate_articles because of EXCEPTION: '||sqlerrm);
    END IF;

     x_return_status := G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	END IF;

End Populate_Template_Articles;



/*
-- PROCEDURE Populate_Expert_Articles
-- To be used to delete populate the global temp table with articles on
-- the current version of the Expert.
-- Bug #4044354, removed the reference to l_document_type and
-- l_document_id which were not getting initialized and causing
-- expert BV to fail.
*/
PROCEDURE Populate_Expert_Articles (
    x_return_status    OUT NOCOPY VARCHAR2,
    p_document_type        VARCHAR2,
    p_document_id		   NUMBER,
    p_include_exp      OUT NOCOPY VARCHAR2,
    p_seq_id               NUMBER)
 is
    l_api_name     	      CONSTANT VARCHAR2(30):='POPULATE_EXPERT_ARTICLES';
    l_api_version         NUMBER;
    l_init_msg_list       VARCHAR2(1);
    l_bv_mode             VARCHAR2(3) ;
    l_qa_result_tbl       OKC_TERMS_QA_GRP.qa_result_tbl_type;
    l_expert_articles_tbl OKC_XPRT_UTIL_PVT.expert_articles_tbl_type;
    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);

begin

   l_init_msg_list := OKC_API.G_FALSE;
   l_bv_mode := 'DEV';
   l_api_version := 1;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                        '200: Entered POPULATE_EXPERT_ARTICLES');
    END IF;


	OKC_XPRT_UTIL_PVT.contract_expert_bv (
			 l_api_version,
    			 l_init_msg_list,
    			 p_document_id,
    			 p_document_type,
    			 l_bv_mode,
                     p_seq_id,
    			 l_qa_result_tbl,
    			 l_expert_articles_tbl,
    			 l_return_status,
    			 l_msg_count,
    			 l_msg_data );

	if (l_return_status = G_RET_STS_UNEXP_ERROR) then
		p_include_exp := 'N';
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	end if;

	IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                        '210: Return value of CONTRACT EXPRT BV is : '|| l_return_status);
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                        '220: Value of p_include_exp is : '|| p_include_exp);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                        '230: The L_qa_results_tbl count is : '|| l_qa_result_tbl.count);
	   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                        '230: The L_expert_articles_tbl count is : '|| l_expert_articles_tbl.count);

    	END IF;


	if (l_return_status = G_RET_STS_SUCCESS) then
	   p_include_exp := 'Y';

	   if (l_expert_articles_tbl.count > 0) then

		IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                                        '240: Inserting the data in temp table as count > 0');
		END IF;

		FORALL i IN l_expert_articles_tbl.FIRST..l_expert_articles_tbl.LAST
  		INSERT INTO okc_terms_deviations_temp (
		  article_id,
		  article_version_id,
                  source_flag)
                VALUES
                  (l_expert_articles_tbl(i),
			    okc_terms_util_pvt.get_latest_tmpl_art_version_id(
					l_expert_articles_tbl(i),
					sysdate),
                  'R');

	   end if;
      end if;

     x_return_status := l_return_status;

Exception
  WHEN  FND_API.G_EXC_UNEXPECTED_ERROR  then
    x_return_status := G_RET_STS_UNEXP_ERROR;
  When OTHERS then

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, l_api_name,
                  '230: Leaving Populate_Expert_articles because of EXCEPTION: '||sqlerrm);
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
end Populate_Expert_Articles;

/*
-- PROCEDURE Generate_Terms_Deviations:
-- This API will be used to generate deviations
*/
PROCEDURE Generate_Terms_Deviations (
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,

    p_doc_type          IN  VARCHAR2,
    p_doc_id            IN  NUMBER,
    p_template_id       IN  NUMBER,
    p_run_id            OUT NOCOPY NUMBER
) is


/* Bug #4105248
** Made changes in the Cursor 'dev_cat' to fetch deviation
** code priority. Modified a.tag to b.tag.
*/

Cursor dev_cat is
                  SELECT    a.lookup_code deviation_category,
                            b.lookup_code  deviation_code,
                            a.meaning deviation_category_meaning,
                            b.meaning deviation_code_meaning,
                            b.tag deviation_category_priority   	-- Changed a.tag to b.tag
                   FROM     fnd_lookup_values a, fnd_lookup_values b
                   WHERE    a.lookup_code = b.lookup_type
                   AND      a.lookup_type = 'OKC_TERMS_DEVIATION_CATEGORIES'
                   AND      a.enabled_flag = b.enabled_flag
                   AND      a.language = b.language
                   AND      b.language = USERENV('LANG')
                   AND      b.enabled_flag = 'Y'
                   ORDER BY b.tag; 		-- Changed a.tag to b.tag

 l_dev_cat    dev_cat%rowtype;
 l_seq_id     number;
 l_api_name   CONSTANT VARCHAR2(30) := 'GENERATE_TERMS_DEVIATIONS';



 l_dev_category                dev_category_tbl;
 l_dev_code                    dev_code_tbl;
 l_dev_category_meaning        dev_category_meaning_tbl;
 l_dev_code_meaning            dev_code_tbl;
 l_scn_id                      scn_id_tbl;
 l_section_heading             section_heading_tbl;
 l_label                       label_tbl;
 l_doc_article_id              article_id_tbl;
 l_doc_article_version_id      article_version_id_tbl;
 l_ref_article_id              ref_article_id_tbl;
 l_ref_article_version_id      ref_article_version_id_tbl;
 l_article_title               article_title_tbl;
 l_display_sequence            display_sequence_tbl;
 l_mandatory_flag              mandatory_flag_tbl;
 l_orig_article_id             orig_article_id_tbl;
 l_art_seq_id                  art_seq_id_tbl;
 l_contract_source 		      varchar2(30);
 l_compare_flag                varchar2(1) ;
 l_xprt_enabled	       	 varchar2(1);
 x_include_exp                 varchar2(1) ;
 l_init_msg_list 			 varchar2(1);
 l_api_version				 number;


procedure Update_deviation_details(x_return_status OUT NOCOPY VARCHAR2,
			 p_sequence_id IN NUMBER)
is
l_api_name 	CONSTANT Varchar2(60):='UPDATE_DEVIATIONS_DETAILS';
l_max_scn_seq           Number;

begin

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        '700: Entered UPDATE_DEVIATION_DETAILS');
 END IF;
 /*
   Update okc_terms_deviations_t odt set
        (odt.scn_label, odt.scn_sequence) = (select label, section_sequence from
                         okc_sections_b where id = odt.scn_id)
   where sequence_id = p_sequence_id;
 */

 /* bug #4057194
 ** The following is the logic for updating the section label and section
 ** sequence
 ** update the scn_sequence for the section/clause which is currently
 ** on document i.e, deviations for the clauses existing on document.
 ** update the scn_sequence for the section/clause which is missing
 ** on document but is from template.
 ** update the scn_sequence for section/clause which is present on the
 ** template but is not existing on document.
 ** There is additional logic to handle sections within section, the
 ** order is achieved by the following:
 ** Ex:    seq      section
 **        10        S1
 **        20        |->S2 (child section)
 **        20        S3    (here the parent section will be based
 **                         on prev parent)
 **        30        S4
 ** In order to get the correct section sequence the child section
 ** sequence generated as parent scn seq + child scn seq * 0.0001
 ** so in the case the final section sequence will be
 ** Ex:    seq      section
 **        10        S1
 **        10.002    |->S2 (child section)
 **        20        S3    (here the parent section will be based
 **                         on prev parent)
 **        30        S4
 */

 -- updates the scn_sequence for the caluses which are exisiting on document

     Update okc_terms_deviations_t odt set
        (odt.scn_label, odt.scn_sequence) =
		 (select osb1.label, decode(osb1.section_sequence,
		 			osb2.section_sequence,osb1.section_sequence,
					osb2.section_sequence+(1/10000)*osb1.section_sequence) -- Bug#4615605 replaced .0001 with 1/10000
    from okc_sections_b osb1, okc_sections_b osb2
    where nvl(osb1.scn_id,osb1.id) = osb2.id
    and osb1.document_type = odt.document_type
    and osb1.document_id = odt.document_id
    and osb1.id = odt.scn_id)
   where sequence_id = p_sequence_id;


 -- updates the scn_sequence for sections which are copied from template, but
 -- the clauses are missing on the document.

    update okc_terms_deviations_t odt set
          (odt.scn_label, odt.scn_sequence) = (select osb1.label,
		  			decode(osb1.section_sequence,
		 			osb2.section_sequence,osb1.section_sequence,
					osb2.section_sequence+(1/10000)*osb1.section_sequence)
    from okc_sections_b osb1, okc_sections_b osb2, okc_sections_b osb3
   where nvl(osb1.scn_id,osb1.id) = osb2.id
     and osb1.document_type = odt.document_type
     and osb1.document_id = odt.document_id
     and osb3.id = odt.scn_id
     and osb3.id = to_number(osb1.orig_system_reference_id1))
   where sequence_id = p_sequence_id
     and scn_sequence is null;

 -- Now get the max scn_sequence which can be used to update the template
 -- scn_sequence

    SELECT  nvl(max(scn_sequence),0) INTO l_max_scn_seq
      FROM  okc_terms_deviations_t
     WHERE  sequence_id = p_sequence_id;

 -- updates the scn_sequence for the clauses which are on template but
 -- not on the document
   Update okc_terms_deviations_t odt set
        (odt.scn_label, odt.scn_sequence) =
		 (select osb1.label, to_number(decode(osb1.section_sequence,
		 			osb2.section_sequence,osb1.section_sequence,
					osb2.section_sequence+(1/10000)*osb1.section_sequence))
								   + l_max_scn_seq
   from okc_sections_b osb1, okc_sections_b osb2
  where nvl(osb1.scn_id,osb1.id) = osb2.id
    and osb1.document_type = 'TEMPLATE'
    and osb1.id = odt.scn_id)
  where sequence_id = p_sequence_id
    and scn_sequence is null;

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        '710: Updated Section Label');
 END IF;

   Update okc_terms_deviations_t odt set
	lock_text_mod_flag = (select lock_text from
                        okc_article_versions
                        where article_version_id = odt.ref_article_version_id)
   where sequence_id = p_sequence_id
     and deviation_code = 'MODIFIED_STD';

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        '720: Updated lock_text flag');
 END IF;


/*
** Bug #4105040 Modified the update statement
** Added an extra condition on doc_article_version_id
*/

   Update okc_terms_deviations_t odt set
	compare_text_flag = 'Y'
   where  ref_article_version_id is NOT NULL
     and  doc_article_version_id <> ref_article_version_id
     and  deviation_code = 'ARTICLE_EXPIRED'
     and  sequence_id = p_sequence_id;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '710: Updated compare text flag for Expired Clauses');
  END IF;

  x_return_status := G_RET_STS_SUCCESS;

EXCEPTION
When OTHERS then

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'730: Leaving Update_Deviation_details : FND_API.G_EXC_UNEXPECTED_ERROR');
  END IF;
  x_return_status := G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;
end;

/*
** Bug #4087224
** If the same clause is existing multiple times
** in same or different sections and having same deviation, then this was
** getting reported multiple times, this was because the clauses are
** fetched based on deviations. Removing the duplicate deviations in
** this procedure.
*/

procedure remove_duplicate_deviations (x_return_status OUT NOCOPY VARCHAR2,
                p_sequence_id IN NUMBER)
is
l_api_name     CONSTANT Varchar2(60):='REMOVE_DUPLICATE_DEVIATIONS';

begin

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
				'800: Entered REMOVE_DUPLICATE_DEVIATIONS');
  END IF;

  delete from okc_terms_deviations_t odt
   where odt.scn_sequence+ ((1/10000) * odt.display_sequence) >
       (select min(odt1.scn_sequence+ ((1/10000) * odt1.display_sequence))
         from okc_terms_deviations_t odt1
	   where odt.deviation_category_priority=odt1.deviation_category_priority
          and odt.doc_article_id = odt1.doc_article_id
		and odt.sequence_id = odt1.sequence_id)
          and odt.sequence_id = p_sequence_id;

  x_return_status := G_RET_STS_SUCCESS;

EXCEPTION
When OTHERS then

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'810: Leaving remove_duplicate_deviations : FND_API.G_EXC_UNEXPECTED_ERROR');
  END IF;
  x_return_status := G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
  END IF;

end;



Begin

    l_compare_flag := 'N';
    l_xprt_enabled := 'N';
    x_include_exp := 'N';
    l_init_msg_list := FND_API.G_FALSE;
    l_api_version := 1;

    FND_MSG_PUB.initialize;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
		                            '300: Entered GENERATE_DEVIATIONS');
							       END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                        '305: Calling populate template articles');
    END IF;

   populate_template_articles(x_return_status, p_template_id, p_doc_type);

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '310: return status for populate_template_articles is : '|| x_return_status);
   END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
		'312: Checking If expert is enabled on document');
  END IF;

  /*
  ** Bug #4115488, Added code to check if the document is CE enabled
  ** using the same logic used for displaying the 'Use Contract Expert'
  ** button on the document. This will take care of the scenarios where
  ** the template is enabled/disabled on revisions.
  */

      OKC_XPRT_UTIL_PVT.enable_expert_button
     (
      l_api_version,
      l_init_msg_list,
      p_template_id,
      p_doc_id,
      p_doc_type,
      l_xprt_enabled, -- FND_API.G_FALSE or G_TRUE
      x_return_status,
      x_msg_count,
      x_msg_data
     );

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '314: XPRT Enabled on Template: '||l_xprt_enabled);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
  END IF;

  SELECT OKC_TERMS_DEVIATIONS_S1.nextval INTO l_seq_id from DUAL;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '316: Generated Sequence Number is l_seq_id: '|| l_seq_id);
  END IF;

  -- Bug #4115488

  if (l_xprt_enabled = FND_API.G_TRUE) then

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '318: Calling populate_expert_articles');
    END IF;

    Populate_Expert_Articles( x_return_status,
    			      p_doc_type,
    			      p_doc_id,
    			      x_include_exp,
                      l_seq_id); --Policy Deviations Change:Passing sequence Id

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '320: return status for populate_expert_articles is : '|| x_return_status);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '320: value of x_include_exp is: '|| x_include_exp);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;

  end if;   -- end of xprt_enabled

  open dev_cat;
  loop
     Fetch dev_cat into l_dev_cat;
       exit when dev_cat%NOTFOUND;

        If l_dev_cat.deviation_code = 'ADDED_NON_STD' then
      /*
         ** considers all the non-std clauses currently
         ** existing on the document but no originated
         ** from either Template or Expert
	    ** Bug 4044354 Replaced ref_article_id with orig_article_id
         */
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  '330: Generating deviations for Added Non Std Clause');
      END IF;

        SELECT
            oab.id,
            oab.SCN_ID,
            okc_terms_util_pvt.get_section_label(scn_id),
            oab.label,
            oab.sav_sae_id,
            oab.article_version_id,
            oab.ref_article_id ,
            oab.ref_article_version_id,
            okc_terms_util_pvt.get_article_name(sav_sae_id, article_version_id),
            oab.display_sequence,
            oab.mandatory_YN,
            oab.orig_article_id
         BULK COLLECT INTO
                l_art_seq_id,
          	l_scn_id,
                l_section_heading,
                l_label,
                l_doc_article_id,
                l_doc_article_version_id,
                l_ref_article_id,
                l_ref_article_version_id,
                l_article_title,
                l_display_sequence,
                l_mandatory_flag,
                l_orig_article_id
     FROM  okc_k_articles_b oab
     WHERE document_type = p_doc_type
       AND document_id = p_doc_id
	  AND NVL(summary_amend_operation_code,'NULL') <> 'DELETED'
       AND   EXISTS (SELECT 1 FROM okc_articles_all oka
                             WHERE oka.article_id = oab.sav_sae_id
                             AND   standard_YN = 'N')
       AND  NOT EXISTS (SELECT 1 from okc_terms_deviations_temp odt
	  		     WHERE odt.article_id = oab.orig_article_id);



     l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'MODIFIED_STD' then
        /*
        ** considers clauses which are modified to non-std
        ** and originated from Tempalte or Expert (i.e,
        ** source_flag is NOT NULL
	   ** Bug 4044354 Replaced ref_article_id with orig_article_id
        */
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                  '340: Generating Deviations deviations for Modified Std Clause ');
      END IF;

      SELECT
         oab.id,
         oab.SCN_ID,
         okc_terms_util_pvt.get_section_label(scn_id),
         oab.label,
         oab.sav_sae_id,
         oab.article_version_id,
         oab.ref_article_id ,
         okc_terms_util_pvt.get_latest_tmpl_art_version_id(oab.ref_article_id, sysdate),
         okc_terms_util_pvt.get_article_name(sav_sae_id, article_version_id),
         oab.display_sequence,
         oab.mandatory_YN,
         oab.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
         FROM   okc_k_articles_b oab
         WHERE  ref_article_id is not null
          AND   ref_article_version_id is not null
          AND   document_id = p_doc_id
          AND   document_type = p_doc_type
		AND   nvl(summary_amend_operation_code,'NULL') <> 'DELETED'
          AND   Exists ( Select 1 from okc_terms_deviations_temp odt where
                                  oab.orig_article_id = odt.article_id ) ;
         l_compare_flag := 'Y';

        elsif l_dev_cat.deviation_code = 'MISSING_EXPERT_ARTICLE' then
        /*
        ** will consider the clauses suggested by expert but are
        ** missing on the document. Also, considers the clauses
        ** suggested by new rules, if any.
	   ** Bug #4044354 Replaced ref_article_id with orig_article_id
        */
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '350: Generating Deviations for Missing Exp Clause ');
      END IF;

      SELECT
         otd.art_seq_id,
         otd.SCN_ID,
         okc_terms_util_pvt.get_section_name(otd.article_version_id, p_template_id),
         otd.label,
         otd.article_id,
         otd.article_version_id,
         otd.ref_article_id ,
         otd.ref_article_version_id,
         okc_terms_util_pvt.get_article_name(otd.article_id, otd.article_version_id),
         otd.display_sequence,
         otd.mandatory_flag,
         otd.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
     FROM  okc_terms_deviations_temp otd
     WHERE  otd.source_flag = 'R'
       AND  x_include_exp = 'Y'
       AND  NOT EXISTS ( Select 1 from okc_k_articles_b oab
                              Where  oab.document_type = p_doc_type
                                        And  oab.document_id = p_doc_id
                                        And  (oab.orig_article_id = otd.article_id
									 OR oab.sav_sae_id = otd.article_id)
								And  nvl(summary_amend_operation_code,'NULL') <> 'DELETED' );

         l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'MISSING_MANDATORY' then

     /*
        ** will consider only std. mandatory clauses missing from
        ** the document(which are NOTmodfied)
        ** Also, considers any new mandatory clause added to the
        ** template in the latest version
        */
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '360: Generating Deviations for Missing Mandatory Clause ');
      END IF;


         SELECT
         otd.art_seq_id,
         otd.SCN_ID,
         okc_terms_util_pvt.get_section_label(otd.scn_id),
         otd.label,
         otd.article_id,
         otd.article_version_id,
         otd.ref_article_id ,
         otd.ref_article_version_id,
         okc_terms_util_pvt.get_article_name(otd.article_id, otd.article_version_id),
         otd.display_sequence,
         otd.mandatory_flag,
         otd.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
     FROM  okc_terms_deviations_temp otd
        WHERE otd.source_flag = 'T'
     AND   otd.mandatory_flag = 'Y'
     --Bug 4070733 Added condition to check for ammendement operation code
     AND   (NOT EXISTS ( Select 1 from okc_k_articles_b oab
                                 Where  oab.document_type = p_doc_type
                                        And   oab.document_id = p_doc_id
                                        And   (oab.orig_article_id = otd.article_id
					       --Bug 4077070
					                      OR oab.sav_sae_id = otd.article_id )
                                        And  nvl(oab.summary_amend_operation_code,'NULL') <> 'DELETED'));

        l_compare_flag := 'N';

     elsif l_dev_cat.deviation_code = 'MISSING_OPTIONAL_ARTICLE' then
         /*
         ** considers the standard clauses which were removed
         ** from the document but are existing on the template
         ** Also, considers any new clauses added to the template
         ** after it has been instantiated on the document (i.e,
         ** in the latest version of the template
         */
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '370: Generating Deviations for Missing Optional Clause ');
      END IF;

      SELECT
         otd.art_seq_id,
         otd.SCN_ID,
         okc_terms_util_pvt.get_section_label(otd.scn_id),
         otd.label,
         otd.article_id,
         otd.article_version_id,
         otd.ref_article_id ,
         otd.ref_article_version_id,
         okc_terms_util_pvt.get_article_name(otd.article_id, otd.article_version_id),
         otd.display_sequence,
         otd.mandatory_flag,
         otd.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
      FROM  okc_terms_deviations_temp otd
      WHERE otd.source_flag = 'T'
      AND   otd.mandatory_flag = 'N'
      --Bug 4070733 Added condition to check for ammendement operation code
      AND   (NOT EXISTS ( Select 1 from okc_k_articles_b oab
                          Where  oab.document_type = p_doc_type
                            And  oab.document_id = p_doc_id
                            And  (oab.orig_article_id = otd.article_id
			          --Bug 4077070
			          OR oab.sav_sae_id = otd.article_id )
					AND nvl(oab.summary_amend_operation_code,'NULL') <> 'DELETED'));

      l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'ARTICLE_EXPIRED' then

     /*
        ** This will be irrespecitve of Source (Template, Expert or
     ** directly added to the document), if the article is present
     ** on the document and is Expired, it will be reported
     ** This check is made against all the clauses on the document
	** Get_latest_version)id will return either a latest version or
	** null
     */

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '380: Generating Deviations for Clause Expired ');
      END IF;
        SELECT
         oab.id,
         oab.SCN_ID,
         okc_terms_util_pvt.get_section_label(scn_id),
         oab.label,
         oab.sav_sae_id,
         oab.article_version_id,
         oab.sav_sae_id,  -- in case of expired clause,ref_art_id=art_id
         okc_terms_util_pvt.get_latest_art_version_id(oab.sav_sae_id,p_doc_type,p_doc_id), --- Bug #4312185 [ Passing p_doc_type and p_doc_id, instead of 'TEMPLATE' and p_template_id ]
         okc_terms_util_pvt.get_article_name(sav_sae_id, article_version_id),
         oab.display_sequence,
         oab.mandatory_YN,
         oab.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
      FROM  okc_k_articles_b oab
      WHERE document_id = p_doc_id
       AND  document_type = p_doc_type
	  AND  nvl(summary_amend_operation_code,'NULL') <> 'DELETED'
          AND  EXISTS (Select 1 from okc_article_versions oav
                                Where  oav.article_id = oab.sav_sae_id
                                  And  oav.article_version_id = oab.article_version_id
                                  And  trunc(nvl(end_date, sysdate)) < trunc(sysdate));
          l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'ARTICLE_ON_HOLD' then

     /*
        ** This will be irrespecitve of Source (Template, Expert or
     ** directly added to the document), if the article is present
     ** on the document and is on-hold, it will be reported.
     ** This check is made against all the clauses on the document
     */
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '390: Generating Deviations for Clause on hold ');
      END IF;

     SELECT
        oab.id,
         oab.SCN_ID,
         okc_terms_util_pvt.get_section_label(scn_id),
         oab.label,
         oab.sav_sae_id,
         oab.article_version_id,
         oab.ref_article_id ,
         oab.ref_article_version_id,
         okc_terms_util_pvt.get_article_name(sav_sae_id, article_version_id),
         oab.display_sequence,
         oab.mandatory_YN,
         oab.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
      FROM  okc_k_articles_b oab
      WHERE document_id = p_doc_id
       AND  document_type = p_doc_type
	  and  nvl(summary_amend_operation_code,'NULL') <> 'DELETED'
       AND  EXISTS (Select 1 from okc_article_versions oav
                    Where  oav.article_id = oab.sav_sae_id
                      And  oav.article_version_id = oab.article_version_id
                      And  oav.article_status = 'ON_HOLD')
	  AND NOT EXISTS (Select 1 from okc_terms_deviations_t odt
	  			Where odt.doc_article_id = oab.sav_sae_id
				  And sequence_id = l_seq_id);

      l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'EXPERT_ARTICLE_NOT_REQUIRED' then
         /*
         ** will consider the clauses that were previously suggested
         ** by Expert but are not in the current run
	    ** Bug #4044354 Replaced ref_article_id with orig_article_id
         */
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '400: Generating Deviations for Exp recommending to remove ');
      END IF;

      SELECT
         oab.id,
         oab.SCN_ID,
         okc_terms_util_pvt.get_section_label(scn_id),
         oab.label,
         oab.sav_sae_id,
         oab.article_version_id,
         oab.ref_article_id ,
         oab.ref_article_version_id,
         okc_terms_util_pvt.get_article_name(sav_sae_id, article_version_id),
         oab.display_sequence,
         oab.mandatory_YN,
         oab.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
         FROM   okc_k_articles_b oab
         WHERE  oab.source_flag = 'R'
          AND   document_id = p_doc_id
          AND   document_type = p_doc_type
		AND   nvl(summary_amend_operation_code,'NULL') <> 'DELETED'
          AND   x_include_exp = 'Y'
          AND   NOT Exists ( Select 1 from okc_terms_deviations_temp odt
                             Where  oab.orig_article_id = odt.article_id
                             And   odt.source_flag = 'R')
          AND NOT EXISTS (Select 1 from okc_terms_deviations_t odt
                       Where odt.doc_article_id = oab.sav_sae_id
                         And sequence_id = l_seq_id);
      l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'ADDED_STD_ARTICLE' then

     /*
        ** will consider clauses with source_flag as null and the clause
        ** is std. OR the clause is missing on the template.
        ** will not consider Expert related clauses
     */

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '410: Generating Deviation for Added Std Clause ');
      END IF;

     SELECT
        oab.id,
         oab.SCN_ID,
         okc_terms_util_pvt.get_section_label(scn_id),
         oab.label,
         oab.sav_sae_id,
         oab.article_version_id,
         oab.ref_article_id ,
         oab.ref_article_version_id,
         okc_terms_util_pvt.get_article_name(sav_sae_id, article_version_id),
         oab.display_sequence,
         oab.mandatory_YN,
         oab.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
      FROM  okc_k_articles_b oab
      WHERE document_id = p_doc_id
       AND  document_type = p_doc_type
	  AND  nvl(summary_amend_operation_code,'NULL') <> 'DELETED'
       AND  EXISTS (Select 1 from okc_articles_all oaa
                    Where  oaa.article_id = oab.sav_sae_id
                      And  oaa.standard_yn = 'Y')
         AND  NOT EXISTS (Select 1 from okc_terms_deviations_temp
                                    Where article_id = nvl(oab.orig_article_id,
							   				    oab.sav_sae_id))
-- Fix for bug# 4709359.
         AND  NOT EXISTS (Select 1 from okc_terms_deviations_temp
                                    Where article_id = oab.sav_sae_id)
-- End of Fix for bug# 4709359.
         AND NOT EXISTS (Select 1 from okc_terms_deviations_t odt
                       Where odt.doc_article_id = oab.sav_sae_id
                         And sequence_id = l_seq_id);

         l_compare_flag := 'N';

        elsif l_dev_cat.deviation_code = 'REPLACED_ALT' then

        /*
        ** considers the clauses suggested by template or expert
        ** and have replaced with available alternate clauses.
        */
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'420: Generating Deviations for Replace Clause with Alternate ');
      END IF;

         SELECT
         oab.id,
         oab.SCN_ID,
         okc_terms_util_pvt.get_section_label(oab.scn_id),
         oab.label,
         oab.sav_sae_id,
         oab.article_version_id,
         odt.article_id ,
	    odt.article_version_id,
         okc_terms_util_pvt.get_article_name(oab.sav_sae_id, oab.article_version_id),
         oab.display_sequence,
         oab.mandatory_YN,
         oab.orig_article_id
      BULK COLLECT INTO
          l_art_seq_id,
          l_scn_id,
          l_section_heading,
          l_label,
          l_doc_article_id,
          l_doc_article_version_id,
          l_ref_article_id,
          l_ref_article_version_id,
          l_article_title,
          l_display_sequence,
          l_mandatory_flag,
          l_orig_article_id
      FROM  okc_k_articles_b oab, okc_terms_deviations_temp odt
      WHERE oab.document_id = p_doc_id
       AND  oab.document_type = p_doc_type
       AND  oab.source_flag = odt.source_flag
	  AND  nvl(oab.summary_amend_operation_code,'NULL') <> 'DELETED'
       AND  oab.ref_article_id is null
       AND  oab.ref_article_version_id is null
	  AND  oab.orig_article_id = odt.article_id
       AND  EXISTS (select 1
                from OKC_ARTICLE_RELATNS_ALL oar
                where oar.source_article_id = odt.article_id -- currently on template
                and oar.target_article_id = oab.sav_sae_id -- currently on document
                and oar.relationship_type = 'ALTERNATE')
       AND NOT EXISTS (Select 1 from okc_terms_deviations_t odt
                       Where odt.doc_article_id = oab.sav_sae_id
                         And sequence_id = l_seq_id);

		l_compare_flag := 'Y';
        end if;

    -- The deviations data has been collected into respective PL/SQL
    -- tables and then inserted into okc_terms_deviations_t table.
    -- Insert_deviatiosn procedure is called for this.

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'430: Inserting Deviations in okc_terms_deviations_t ');
    END IF;

    Insert_deviations(
        x_return_status,
        x_msg_data,
        x_msg_count,

        l_seq_id,
        l_dev_cat.deviation_category,
        l_dev_cat.deviation_code,
        l_dev_cat.deviation_category_meaning,
        l_dev_cat.deviation_code_meaning,
        l_dev_cat.deviation_category_priority,
        l_scn_id,
        l_section_heading,
        l_label,
        l_doc_article_id,
        l_doc_article_version_id,
        l_ref_article_id,
        l_ref_article_version_id,
        l_article_title,
        l_display_sequence,
        l_mandatory_flag,
        l_orig_article_id,
        l_art_seq_id,
        l_compare_flag,
	   p_doc_type,
	   p_doc_id);

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;

   end loop;

   close dev_cat;

  /* Update the Section Details and Protected flag */
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'440: Calling Update Deviation Details ');
   END IF;

   Update_deviation_details(x_return_status, l_seq_id);
   If (x_return_status = G_RET_STS_UNEXP_ERROR) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End if;

  Remove_duplicate_deviations(x_return_status, l_seq_id);
  If (x_return_status = G_RET_STS_UNEXP_ERROR) then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  End if;

   p_run_id := l_seq_id;

   x_return_status := G_RET_STS_SUCCESS;
   commit;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      IF (dev_cat%ISOPEN) THEN
        CLOSE dev_cat;
      END IF;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'100: Leaving Generate_deviations :FND_API.G_EXC_ERROR');
      END IF;
      x_return_status := G_RET_STS_ERROR ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (dev_cat%ISOPEN) THEN
        CLOSE dev_cat;
      END IF;

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'200: Leaving Generate_Deviations : FND_API.G_EXC_UNEXPECTED_ERROR');
      END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'300: Leaving Generate_Deviations because of EXCEPTION: '||sqlerrm);
      END IF;

      IF (dev_cat%ISOPEN) THEN
        CLOSE dev_cat;
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
      END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
end  Generate_Terms_Deviations;

-- this procedure will insert data into
-- okc_terms_deviations_t table

Procedure Insert_deviations(
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,

    p_seq_id                        Number,
    p_dev_category              Varchar2,
    p_dev_code                  Varchar2,
    p_dev_category_meaning      Varchar2,
    p_dev_code_meaning          Varchar2,
    p_dev_category_priority     Number,
    p_scn_id                    scn_id_tbl,
    p_section_heading           section_heading_tbl,
    p_label                     label_tbl,
    p_doc_article_id            article_id_tbl,
    p_doc_article_version_id    article_version_id_tbl,
    p_ref_article_id            ref_article_id_tbl,
    p_ref_article_version_id    ref_article_version_id_tbl,
    p_article_title             article_title_tbl,
    p_display_sequence          display_sequence_tbl,
    p_mandatory_flag            mandatory_flag_tbl,
    p_orig_article_id           orig_article_id_tbl,
    p_art_seq_id                art_seq_id_tbl,
    p_compare_flag              Varchar2,
    p_doc_type			       Varchar2,
    p_doc_id				  Number)
is
    l_api_name          CONSTANT VARCHAR2(30) := 'INSERT_DEVIATIONS' ;
begin

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '500: Inserting Deviations in okc_terms_deviations_t ');
    END IF;

 if p_doc_article_id.count > 0 then

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '510: Inserting Deviations in okc_terms_deviations_t ');
    END IF;

   FORALL i in p_doc_article_id.FIRST.. p_doc_article_id.LAST
     INSERT INTO okc_terms_deviations_t (
          sequence_id,
          deviation_category,
          deviation_code,
          deviation_category_meaning,
          deviation_code_meaning,
          deviation_category_priority,
          scn_id,
          section_heading,
          label,
          doc_article_id,
          doc_article_version_id,
          ref_article_id,
          ref_article_version_id,
          article_title,
          display_sequence,
          mandatory_flag,
          compare_text_flag,
          orig_article_id,
          art_seq_id,
          document_type,
	  document_id,
	  creation_date,
          deviation_type)
       VALUES (
          p_seq_id,
          p_dev_category,
          p_dev_code,
          p_dev_category_meaning,
          p_dev_code_meaning,
          p_dev_category_priority,
          p_scn_id(i),
          p_section_heading(i),
          p_label(i),
          p_doc_article_id(i),
          p_doc_article_version_id(i),
          p_ref_article_id(i),
          p_ref_article_version_id(i),
          p_article_title(i),
          p_display_sequence(i),
          p_mandatory_flag(i),
          p_compare_flag,
          p_orig_article_id(i),
          p_art_seq_id(i),
	  p_doc_type,
	  p_doc_id,
	  sysdate,
          'C'
          );
   end if;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,
                '520: Inserted Deviations in okc_terms_deviations_t ');
    END IF;

 x_return_status := G_RET_STS_SUCCESS;

EXCEPTION
   WHEN OTHERS Then

      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,
                '530: Leaving Insert_Deviations because of EXCEPTION: '||sqlerrm);
      END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
	 IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	 END IF;
end Insert_deviations;


Procedure Purge_Deviations_Data(
        errbuf              OUT NOCOPY VARCHAR2,
        retcode             OUT NOCOPY VARCHAR2,
        p_num_days          IN  NUMBER )

is
        l_api_name              CONSTANT VARCHAR2(30) := 'Purge_deviations_Data';
        l_return_status varchar2(1);
	   i		NUMBER;

        cursor del_csr is Select rowid from okc_terms_deviations_t
                                   Where  trunc(Creation_date) <= trunc(sysdate) - p_num_days
                                   for update of doc_article_id nowait;
begin
    SAVEPOINT purge_deviations_data;
    l_return_status := G_RET_STS_SUCCESS;
    FND_MSG_PUB.initialize;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_num_days: '||p_num_days);
    FND_FILE.PUT_LINE( FND_FILE.LOG,'Entered into Purge Deviations');

        -- for each of the records selected in the above cursor
        -- issue a delete to purge the data
        For i in del_csr loop
                delete from okc_terms_deviations_t
                where  current of del_csr;
        end loop;
    FND_FILE.PUT_LINE( FND_FILE.LOG,'Delete Records: '|| i);

    retcode := 0;

    FND_FILE.PUT_LINE( FND_FILE.LOG,'Return Code of the Program: '|| retcode);

EXCEPTION

WHEN E_RESOURCE_BUSY then
        l_return_status := G_RET_STS_ERROR;
        retcode := 1;
	   ROLLBACK TO purge_deviations_data;
        FND_FILE.PUT_LINE( FND_FILE.LOG,'Return Code of the Program: '|| retcode);
	   FND_FILE.PUT_LINE(FND_FILE.LOG,'Resource busy exception');
	   RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;

WHEN OTHERS Then
        l_return_status := G_RET_STS_UNEXP_ERROR;
        errbuf := substr(sqlerrm,1,200);
        retcode := 2;
	   FND_FILE.PUT_LINE( FND_FILE.LOG,'Return Code of the Program: '|| retcode);
	   ROLLBACK TO purge_deviations_data;

	   IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_api_name,'660: Other exception');
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Exception Others: '|| sqlerrm);
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;


end purge_deviations_data;

-- Returns 'Y' if deviations report document has been generated and attached
-- to the business document. 'N' if not.

FUNCTION has_deviation_report(
    p_document_type         IN  VARCHAR2,
    p_document_id           IN  NUMBER
 ) RETURN VARCHAR2 IS
 l_api_name         CONSTANT VARCHAR2(30) := 'has_deviation_report';
 CURSOR doc_details_csr IS
  select  'Y' from okc_contract_docs_details_vl
   where  business_document_id = p_document_id
    and   business_document_type = p_document_type
    and   category_code = 'OKC_REPO_APPROVAL_ABSTRACT'
    and   business_document_version = -99;

  l_result     VARCHAR2(1);

BEGIN
    l_result := '?';

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'1800: Entering has_deviation_report ');
    END IF;

    OPEN  doc_details_csr ;
    FETCH doc_details_csr  into  l_result;
    CLOSE doc_details_csr ;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE, G_MODULE||l_api_name,'2000: Result has_deviation_report : ['||l_result||']');
    END IF;

    IF l_result = 'Y' THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
 WHEN OTHERS THEN
   IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_EXCEPTION, G_MODULE||l_api_name,'2000: Leaving has_deviation_report of EXCEPTION: '||sqlerrm);
   END IF;
 RETURN 'E';
END has_deviation_report;

end OKC_TERMS_DEVIATIONS_PVT; -- package

/
