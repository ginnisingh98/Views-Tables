--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_INT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_INT_GRP" AS
/* $Header: OKCVXIBEEXPB.pls 120.18 2006/06/22 09:23:45 asingam noship $ */

------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_XPRT_INT_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  G_LEVEL_PROCEDURE            CONSTANT   NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.' || g_pkg_name || '.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=510; -- OKC Application

  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;

  --For Bug 4685428

  G_OKC_XPRT_SALESREP_ASSIST   CONSTANT   VARCHAR2(30)  := 'OKC_XPRT_SALESREP_ASSIST';

 -------------------------------------------------------------------
 --  Procedure: This procedure is to delete the empty sections
 --             and re-number the terms if one or more empty
 --             section is deleted.
 -------------------------------------------------------------------
 PROCEDURE delete_empty_sections (
         p_api_version               IN            NUMBER,
         p_init_msg_list             IN            VARCHAR2,
         p_document_type             IN            VARCHAR2,
         p_document_id               IN            NUMBER,
         p_template_id               IN            NUMBER,
         p_document_number           IN            VARCHAR2,
         x_return_status             OUT  NOCOPY   VARCHAR2,
         x_msg_count                 OUT  NOCOPY   NUMBER,
         x_msg_data                  OUT  NOCOPY   VARCHAR2
  ) IS

  l_api_name          	VARCHAR2(30) := 'delete_empty_sections';
  l_module            	VARCHAR2(250) := G_MODULE || l_api_name;
  l_section_deleted		VARCHAR2(1) := 'N';
  l_num_scheme_id		NUMBER:=0;

  Cursor c_doc_sections Is
    SELECT id,scn_id,level,object_version_number, 0
    FROM okc_sections_b
    CONNECT BY prior id = scn_id
    START WITH DOCUMENT_ID = p_document_id and document_type = p_document_type
    ORDER BY level DESC;

  Cursor c_art_sections Is
    select distinct scn_id
    from okc_k_articles_b
    where DOCUMENT_TYPE = p_document_type and DOCUMENT_ID = p_document_id;

  Cursor c_clauses(p_scn_id NUMBER) Is
    select count(*)
    from okc_k_articles_b
    where scn_id = p_scn_id;

  CURSOR l_get_num_scheme_id(p_doc_type VARCHAR2, p_doc_id NUMBER) IS
    SELECT doc_numbering_scheme
    FROM okc_template_usages
    WHERE document_type = p_document_type
      AND document_id = p_document_id;

  TYPE IdList IS TABLE OF okc_sections_b.id%TYPE INDEX BY BINARY_INTEGER;

  -- define table list for the above cursor with a processed flag (deletable or not)
  -- if a section cannot be deleted, that section along with all its parent will be marked
  -- as not deletable
  Id_tbl IdList;
  Scn_Id_tbl IdList;
  Level_tbl IdList;
  OVN_Tbl IdList;
  Delete_Flag_tbl IdList; -- 0 = can delete; 1 = cannot delete

  i NUMBER;
  l_clause_count number;
  l_level number;
  l_parent_scn_id number;
  l_grand_parent_id number;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                       G_MODULE || l_api_name,
                       '100: Entered ' || G_PKG_NAME  || '.' || l_api_name);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	                    'Parameters : ');
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_document_id : ' || p_document_id);
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_document_type : ' || p_document_type);
	   FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_document_number : ' || p_document_number);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
                       'p_template_id : ' || p_template_id);
  END IF;

  --
  -- read all sections from the document
  --
  Open c_doc_sections;
  Fetch c_doc_sections bulk collect into Id_tbl,Scn_Id_tbl,Level_tbl,OVN_tbl,Delete_Flag_tbl;
  Close c_doc_sections;

  --
  -- get all sections that have clauses from articles table and set the delete flag not to be deleted
  -- delete_flag is set to 1 if the section has clauses
  -- if a section cannot be deletable, all its parents and grand parents also no deletable
  --
  For clause_sec IN c_art_sections
  Loop
      For l_sec_index In 1..Id_tbl.count
      Loop
          if Id_tbl(l_sec_index) = clause_sec.scn_id then
             Delete_Flag_tbl(l_sec_index) := 1;
             l_parent_scn_id := Scn_Id_tbl(l_sec_index);
		   if nvl(l_level,1) <= 1 then
		      l_level := Level_tbl(l_sec_index);
			 l_parent_scn_id := Scn_Id_tbl(l_sec_index);
		   end if;
          end if;
      End Loop;

		  -- mark all parents of this section as not deletable
		  while l_level > 1
		  Loop
               For i In 1..Id_tbl.count
			Loop
			    if (Id_tbl(i) = l_parent_scn_id and Delete_Flag_tbl(i) <> 1) then
			       Delete_Flag_tbl(i) := 1; -- do not delete parent section
				  l_grand_parent_id := Scn_Id_tbl(i);
                   end if;
			End Loop;
               l_level := l_level - 1;
			l_parent_scn_id := l_grand_parent_id;
		  End Loop;
  End Loop;

  --
  -- now check the sections for which the delete flags are not set to 1
  -- if these sections has clauses, set the flag to 1
  -- if a section is no deletable, all its parents and grand parents are also not deletable
  --
  For l_sec_index In 1..Id_tbl.count
  Loop
      if Delete_Flag_tbl(l_sec_index) = 0  then
         Open c_clauses(Id_tbl(l_sec_index));
         Fetch c_clauses into l_clause_count;
	    Close c_clauses;
	    if l_clause_count > 0 then
		  For i In 1..Id_tbl.count
		  Loop
			 if Id_tbl(i) = Id_tbl(l_sec_index) then
                   Delete_Flag_tbl(i) := 1; -- do not delete this section
		      end if;
		  End Loop;
		  -- mark all parents of this section as not deletable
		  l_level := Level_tbl(l_sec_index);
		  l_parent_scn_id := Scn_Id_tbl(l_sec_index);
		  while l_level > 1
		  Loop
               For i In 1..Id_tbl.count
			Loop
			    if (Id_tbl(i) = l_parent_scn_id and Delete_Flag_tbl(i) <> 1) then
			       Delete_Flag_tbl(i) := 1; -- do not delete parent section
				  l_grand_parent_id := Scn_Id_tbl(i);
                   end if;
			End Loop;
               l_level := l_level - 1;
			l_parent_scn_id := l_grand_parent_id;
		  End Loop;
	    end if;
	 end if;
  End Loop;

  --
  -- remove duplicate sections that to be deleted
  -- if not removed, the delete API will throw error since the section is already deleted in some cases
  --
  For l_sec_index In 1..Id_tbl.count
  Loop
      if (Delete_Flag_tbl(l_sec_index) = 0) then
         For i In l_sec_index+1..Id_tbl.count
	    Loop
	        if Id_tbl(i) = Id_tbl(l_sec_index) then
		      Delete_Flag_tbl(i) := 1;
             end if;
	    End Loop;
	 end if;
  End Loop;

  --
  -- now the rest of the sections with delete flag is still set to zero are empty sections
  -- delete all empty sections now
  --

  For l_sec_index In 1..Id_tbl.count
  Loop

       If (Delete_Flag_tbl(l_sec_index) = 0) then
             OKC_TERMS_SECTIONS_GRP.delete_section(
                                   p_api_version       => p_api_version,
                                   p_init_msg_list     => p_init_msg_list,
                                   p_commit            => FND_API.G_FALSE,
                                   x_return_status     => x_return_status,
                                   x_msg_count         => x_msg_count,
                                   x_msg_data          => x_msg_data,
                                   p_mode              => 'NORMAL',
                                   p_id                => id_tbl(l_sec_index),
                                   p_amendment_description => NULL,
                                   p_object_version_number => OVN_tbl(l_sec_index)
                                   );

              IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
              ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR ;
              END IF;
		    l_section_deleted := 'Y';

	  End If;
  End Loop;

   --
   -- if at least one section got deleted, renumber the document
   --
   IF l_section_deleted = 'Y' THEN
      OPEN l_get_num_scheme_id(p_doc_type => p_document_type, p_doc_id => p_document_id) ;
      FETCH l_get_num_scheme_id INTO l_num_scheme_id;
      CLOSE l_get_num_scheme_id;

      IF NVL(l_num_scheme_id,0) <> 0 THEN

         OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
           p_api_version        => p_api_version,
           p_init_msg_list      => p_init_msg_list,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,
           p_validate_commit    => FND_API.G_FALSE,
           p_validation_string  => NULL,
           p_commit             => FND_API.G_FALSE,
           p_doc_type           => p_document_type,
           p_doc_id             => p_document_id,
           p_num_scheme_id      => l_num_scheme_id
         );

         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
                  RAISE FND_API.G_EXC_ERROR ;
         END IF;
      END IF; --l_num_scheme_id is not zero
   END IF;

   -- end debug log
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE || l_api_name,
                      '1000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
   END IF;

  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE || l_api_name,
                             '2000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
           END IF;

         		x_return_status := FND_API.G_RET_STS_ERROR ;
         		FND_MSG_PUB.Count_And_Get(
         		        p_count => x_msg_count,
                 		p_data => x_msg_data
         		);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE || l_api_name,
                             '3000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
           END IF;

         		x_return_status := FND_API.G_RET_STS_ERROR ;
         		FND_MSG_PUB.Count_And_Get(
         		        p_count => x_msg_count,
                 		p_data => x_msg_data
         		);

     WHEN OTHERS THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE || l_api_name,
                             '4000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
           END IF;

         		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           		IF FND_MSG_PUB.Check_Msg_Level
         		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         		THEN
             	    	FND_MSG_PUB.Add_Exc_Msg(
             	    	     G_PKG_NAME  	    ,
             	    	     l_api_name
         	    	      );
         		END IF;

         		FND_MSG_PUB.Count_And_Get(
         		     p_count => x_msg_count,
                 	     p_data => x_msg_data);


END delete_empty_sections;
-------------------------------------------------------------------
--  Procedure: This procedure will be called from the following two
--             places:
--             1. From preview t's and  c's in iStore
--             2. From iStore backend order creation
-------------------------------------------------------------------
  PROCEDURE get_contract_terms (
        p_api_version               IN            NUMBER,
        p_init_msg_list             IN            VARCHAR2,
        p_document_type             IN            VARCHAR2,
        p_document_id               IN            NUMBER,
        p_template_id               IN            NUMBER,
        p_called_from_ui            IN            VARCHAR2,
        p_document_number           IN            VARCHAR2,
	   p_run_xprt_flag             IN            VARCHAR2,
        x_return_status             OUT  NOCOPY   VARCHAR2,
        x_msg_count                 OUT  NOCOPY   NUMBER,
        x_msg_data                  OUT  NOCOPY   VARCHAR2
  ) IS

   l_api_name          VARCHAR2(30) := 'get_contract_terms';
   l_module            VARCHAR2(250) := G_MODULE || l_api_name;
   l_expert_enabled    VARCHAR2(1);
   l_template_applied_yn VARCHAR2(1);

   l_expert_enabled_yn VARCHAR2(1);
   l_ce_profile_option_enabled VARCHAR2(1);

   l_config_header_id  NUMBER;
   l_config_rev_nbr    NUMBER;

   l_cz_xml_init_msg   VARCHAR2(2000);
   l_xml_terminate_msg LONG;

   l_valid_config      VARCHAR2(10);
   l_complete_config   VARCHAR2(10);
   l_new_config_header_id NUMBER;
   l_new_config_rev_nbr   NUMBER;

   l_count_articles_dropped NUMBER;
   l_tmpl_id_on_doc NUMBER;

   --Added for Bug 4929199
   l_tmpl_lang_on_doc VARCHAR2(4);
   l_tmpl_lang_passed VARCHAR2(4);
   l_quote_status    NUMBER;

   --Added for Bug 5344832
   l_tmpl_id_for_bv NUMBER;

   CURSOR csr_expert_enabled IS
   SELECT (nvl(contract_expert_enabled, 'N'))
     FROM   okc_terms_templates_all
     WHERE  template_id = p_template_id;

   --cursor added for Bug#5012622
   CURSOR csr_tmpl_id_on_doc IS
   SELECT template_id
     FROM okc_template_usages
     WHERE document_type = p_document_type
     AND document_id = p_document_id;

   --cursor added for Bug#4929199
   CURSOR csr_tmpl_lang (p_template_id NUMBER) IS
   SELECT language
     FROM okc_terms_templates_all
     WHERE template_id = p_template_id;

   --cursor added for Bug#4929199
   CURSOR csr_quote_status IS
   SELECT quote_status_id
    FROM  aso_quote_headers
    WHERE quote_header_id = p_document_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                       G_MODULE || l_api_name,
                       '100: Entered ' || G_PKG_NAME  || '.' || l_api_name);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	                    'Parameters : ');
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_document_id : ' || p_document_id);
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_document_type : ' || p_document_type);
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_called_from_ui : ' || p_called_from_ui);
	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	               'p_document_number : ' || p_document_number);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
                       'p_template_id : ' || p_template_id);
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
	               G_MODULE || l_api_name,
	                  'p_run_xprt_flag : ' || p_run_xprt_flag);
  END IF;

  -- Expert has to be run only when p_run_xprt_flag is Yes
  IF p_run_xprt_flag = 'Y' THEN

  -- Is Contract Expert profile option enabled?
  FND_PROFILE.GET(name=> 'OKC_K_EXPERT_ENABLED', val => l_ce_profile_option_enabled );

   -- Is Template enabled for Expert?
   OPEN csr_expert_enabled;
   FETCH csr_expert_enabled INTO l_expert_enabled;
   CLOSE csr_expert_enabled;

   --get template id on doc.
   --l_tmpl_id_on_doc will not be null if already terms are instantiated on the doc
   OPEN csr_tmpl_id_on_doc ;
   FETCH csr_tmpl_id_on_doc INTO l_tmpl_id_on_doc;
   CLOSE csr_tmpl_id_on_doc ;

   --Added for Bug 4929199
   OPEN csr_tmpl_lang (p_template_id) ;
   FETCH csr_tmpl_lang INTO l_tmpl_lang_passed;
   CLOSE csr_tmpl_lang ;

   --Added for Bug 4929199
   OPEN csr_tmpl_lang (l_tmpl_id_on_doc) ;
   FETCH csr_tmpl_lang INTO l_tmpl_lang_on_doc;
   CLOSE csr_tmpl_lang ;

   --cursor added for Bug#4929199
   OPEN csr_quote_status;
   FETCH csr_quote_status INTO l_quote_status;
   CLOSE csr_quote_status;

   --Logging local variables
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: Is expert enabled : ' ||l_expert_enabled );
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: template id on doc : ' ||l_tmpl_id_on_doc );
		    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: template id passed: ' ||p_template_id);
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: l_tmpl_lang_on_doc : ' ||l_tmpl_lang_on_doc );
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: l_tmpl_lang_passed : ' ||l_tmpl_lang_passed );
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: document status : ' ||l_quote_status );
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '100: l_ce_profile_option_enabled : ' ||l_ce_profile_option_enabled);
    END IF;

    --Bug 5292348 whether template is expert enabled or not,if template id on doc is null
    --then copy_terms should be called.
    --Bug#5012622 Added new OR condition at below stmt
    --Added additional check for Bug 4929199
    IF ((l_tmpl_id_on_doc is null) or
        (l_tmpl_id_on_doc <> p_template_id and
         l_tmpl_lang_on_doc <> l_tmpl_lang_passed and
         l_quote_status = 28       -- 28 means quote status =  'STORE DRAFT'
        )
       ) THEN
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '120: Calling copy_terms' );
            END IF;
            OKC_TERMS_COPY_GRP.copy_terms(
              p_api_version   		=> p_api_version,
              x_return_status 		=> x_return_status,
              x_msg_data      		=> x_msg_data,
              x_msg_count     		=> x_msg_count,
              p_commit        		=> FND_API.G_TRUE,
              p_template_id             => p_template_id,
              p_target_doc_type         => p_document_type,
              p_target_doc_id           => p_document_id,
              p_article_effective_date  => sysdate,
              p_validation_string       => NULL
            );


            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
	       ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	         RAISE FND_API.G_EXC_ERROR ;
            END IF;
    -- Begin: Added for bug 5344832
          l_tmpl_id_for_bv := p_template_id;
    ELSE
          l_tmpl_id_for_bv := l_tmpl_id_on_doc;
    -- End: Added for bug 5344832
    END IF;


  -- Begin Fix for bug 4919069. Added if Condition before running expert
  -- if the template is expert enabled and Expert profile option is 'Y'
  IF (upper(l_ce_profile_option_enabled) = 'Y') THEN

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '130: Before calling get_current_config_dtls ' );
		    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '130: l_tmpl_id_for_bv '||l_tmpl_id_for_bv  );

    END IF;

    OKC_XPRT_UTIL_PVT.get_current_config_dtls (
       p_api_version               => p_api_version,
       p_init_msg_list             => p_init_msg_list,
       p_document_type             => p_document_type,
       p_document_id               => p_document_id,
       p_template_id               => l_tmpl_id_for_bv, -- Changed from p_template_id for bug 5344832
       x_expert_enabled_yn         => l_expert_enabled_yn,
       x_config_header_id          => l_config_header_id,
       x_config_rev_nbr            => l_config_rev_nbr,
       x_return_status             => x_return_status,
       x_msg_count                 => x_msg_count,
       x_msg_data                  => x_msg_data
      );

    IF( upper(l_expert_enabled) = 'Y' OR
       (upper(l_expert_enabled) = 'N' and    -- Bug 5348970 run expert if already it is ran on doc
        l_config_header_id IS NOT NULL and
        l_config_rev_nbr IS NOT NULL
       )
      ) THEN

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '140: Before running CE' );
		    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '140: l_config_header_id '||l_config_header_id );
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '140: l_config_rev_nbr '||l_config_rev_nbr );
     END IF;

     OKC_XPRT_UTIL_PVT.build_cz_xml_init_msg(
                       p_api_version      => p_api_version,
                       p_init_msg_list    => p_init_msg_list,
                       p_document_id      => p_document_id,
                       p_document_type    => p_document_type,
                       p_config_header_id => l_config_header_id,
                       p_config_rev_nbr   => l_config_rev_nbr,
                       p_template_id      => l_tmpl_id_for_bv, -- Changed from p_template_id for bug 5344832
                       x_cz_xml_init_msg  => l_cz_xml_init_msg,
                       x_return_status    => x_return_status,
                       x_msg_data         => x_msg_data,
                       x_msg_count        => x_msg_count);


     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_cz_xml_init_msg IS NULL)
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '150: before calling batch_validate' );
     END IF;
     OKC_XPRT_CZ_INT_PVT.batch_validate(
                       p_api_version          => p_api_version,
                       p_init_msg_list        => p_init_msg_list,
                       p_cz_xml_init_msg      => l_cz_xml_init_msg,
                       x_cz_xml_terminate_msg => l_xml_terminate_msg, -- this has been converted
                                                                      -- internally from
                                                                      -- HTML_PIECES to LONG.
                       x_return_status        => x_return_status,
                       x_msg_data             => x_msg_data,
                       x_msg_count            => x_msg_count);


     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS OR l_xml_terminate_msg IS NULL)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- To parse x_cz_xml_terminate_msg and check if the CZ batch validate
     -- was successful. If batch validate was successful, it would return
     -- the new config_header_id and config_revision_number
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '160: before calling parse_cz_xml_terminate_msg');
     END IF;

     OKC_XPRT_UTIL_PVT.parse_cz_xml_terminate_msg(
                       p_api_version          => p_api_version,
                       p_init_msg_list        => p_init_msg_list,
                       p_cz_xml_terminate_msg => l_xml_terminate_msg,
                       x_valid_config         => l_valid_config,
                       x_complete_config      => l_complete_config,
                       x_config_header_id     => l_new_config_header_id,
                       x_config_rev_nbr       => l_new_config_rev_nbr,
                       x_return_status        => x_return_status,
                       x_msg_data             => x_msg_data,
                       x_msg_count            => x_msg_count);

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '170: before calling update_ce_config');
     END IF;

     OKC_XPRT_UTIL_PVT.update_ce_config
       (
        p_api_version                  => p_api_version,
        p_init_msg_list                => p_init_msg_list,
        p_document_id                  => p_document_id,
        p_document_type                => p_document_type,
        p_config_header_id             => l_new_config_header_id,
        p_config_rev_nbr               => l_new_config_rev_nbr,
        p_doc_update_mode              => 'NORMAL',
        x_count_articles_dropped       => l_count_articles_dropped,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data
       );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

    END IF; -- if l_expert_enabled is Yes

   END IF; -- if l_ce_profile_option_enabled = 'Y'

  END IF; -- if p_run_exprt_flag

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                            G_MODULE || l_api_name,
                            '200: deleting empty sections' );
  END IF;

  delete_empty_sections (
	          p_api_version    	=> p_api_version,
	          p_init_msg_list       => p_init_msg_list,
	          p_document_type       => p_document_type,
	          p_document_id         => p_document_id,
	          p_template_id         => l_tmpl_id_for_bv, -- Changed from p_template_id for bug 5344832
	          p_document_number     => p_document_number,
	          x_return_status       => x_return_status,
	          x_msg_count           => x_msg_data,
	          x_msg_data            => x_msg_data
      );

   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	      RAISE FND_API.G_EXC_ERROR ;
   END IF;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                      G_MODULE || l_api_name,
                      '1000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
  END IF;

  COMMIT WORK;

  EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE || l_api_name,
                             '2000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
           END IF;

         		x_return_status := FND_API.G_RET_STS_ERROR ;
         		FND_MSG_PUB.Count_And_Get(
         		        p_count => x_msg_count,
                 		p_data => x_msg_data
         		);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE || l_api_name,
                             '3000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
           END IF;

         		x_return_status := FND_API.G_RET_STS_ERROR ;
         		FND_MSG_PUB.Count_And_Get(
         		        p_count => x_msg_count,
                 		p_data => x_msg_data
         		);

     WHEN OTHERS THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                             G_MODULE || l_api_name,
                             '4000: Leaving ' || G_PKG_NAME  || '.' || l_api_name);
           END IF;

         		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

           		IF FND_MSG_PUB.Check_Msg_Level
         		   (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         		THEN
             	    	FND_MSG_PUB.Add_Exc_Msg(
             	    	     G_PKG_NAME  	    ,
             	    	     l_api_name
         	    	      );
         		END IF;

         		FND_MSG_PUB.Count_And_Get(
         		     p_count => x_msg_count,
                 	     p_data => x_msg_data);



 END get_contract_terms;

END OKC_XPRT_INT_GRP ;

/
