--------------------------------------------------------
--  DDL for Package Body HRFRBSOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRFRBSOC" AS
/* $Header: hrfrbsoc.pkb 115.5 2003/05/19 15:12:41 jheer noship $ */
--
PROCEDURE run_bs (errbuf              OUT NOCOPY VARCHAR2
                 ,retcode             OUT NOCOPY NUMBER
                 ,p_business_group_id IN NUMBER
                 ,p_template_id       IN NUMBER
                 ,p_year              IN NUMBER
                 ,p_company_id        IN NUMBER DEFAULT NULL
                 ,p_establishment_id  IN NUMBER DEFAULT NULL
                 ,p_process_name      IN VARCHAR2
                 ,p_debug             IN VARCHAR2) IS
--
l_prmrec        hr_summary_util.prmTabType;
l_stmt          VARCHAR2(32000);
l_est_string    VARCHAR2(4000):=NULL;
l_select_string VARCHAR2(4000):=NULL;
l_dummy         number;
--
/* Bug 2217457 Changed to use hr_fr_establishments_v */
CURSOR csr_get_est IS
 SELECT organization_id organization_id
 FROM  hr_fr_establishments_v
 WHERE company_org_id = to_char(p_company_id)
 OR    organization_id = p_company_id;
--
BEGIN
--
IF p_establishment_id IS NOT NULL THEN
   l_select_string := '(select '||p_establishment_id||' establishment_id from dual) v';
   l_est_string := '('||p_establishment_id||')';
ELSE
   /* Bug 2217457 - Changed to use views instead of union select from dual */
   l_select_string := '(SELECT organization_id establishment_id FROM  hr_fr_establishments_v  WHERE company_org_id = ';
   l_select_string := l_select_string || to_char(p_company_id) || ' OR    organization_id = ';
   l_select_string := l_select_string || to_char(p_company_id) || ') v ';
   FOR l_rec IN csr_get_est LOOP
       IF csr_get_est%ROWCOUNT=1 THEN
          l_est_string := '('||l_rec.organization_id;
       ELSE
          l_est_string := l_est_string||','||l_rec.organization_id;
       END IF;
   END LOOP;
   IF l_est_string IS NOT NULL THEN
      l_est_string := l_est_string||')';
   END IF;
END IF;
--
l_prmrec(1).name := 'P_BUSINESS_GROUP_ID';
l_prmrec(1).value := p_business_group_id;
--
l_prmrec(2).name := 'P_END_OF_YEAR';
l_prmrec(2).value := 'to_date('''||p_year||'1231'',''YYYYMMDD'')';
--
l_prmrec(3).name := 'P_YEAR';
l_prmrec(3).value := ''''||p_year||'''';
--
l_prmrec(4).name := 'P_ESTABLISHMENT_ID';
l_prmrec(4).value := p_establishment_id;
--
l_prmrec(5).name := 'P_ESTABLISHMENT_TABLE';
l_prmrec(5).value := l_select_string;
--
l_prmrec(6).name := 'P_COMPANY_ID';
l_prmrec(6).value := p_company_id;
--
l_prmrec(7).name := 'P_START_OF_YEAR';
l_prmrec(7).value := 'to_date('''||p_year||'0101'',''YYYYMMDD'')';
--
l_prmrec(8).name := 'P_ESTABLISHMENT_LIST';
l_prmrec(8).value := NVL(l_est_string,'(NULL)');
--
hrsumrep.process_run(p_business_group_id => p_business_group_id
                    ,p_process_type      => 'BILAN SOCIAL'
                    ,p_template_id       => p_template_id
                    ,p_process_name      => p_process_name
                    ,p_parameters        => l_prmrec
                    ,p_store_data        => TRUE
                    ,p_statement         => l_stmt
		    ,p_retcode		 => retcode
                    ,p_debug             => p_debug);
--
EXCEPTION WHEN OTHERS THEN
  retcode := 2; /*critical error*/
  errbuf  := sqlerrm;
END run_bs;
--
PROCEDURE delete_gsp(errbuf              OUT NOCOPY VARCHAR2
                    ,retcode             OUT NOCOPY NUMBER
                    ,p_process_run_id    IN  NUMBER) IS
--
BEGIN
--
 hrsumrep.delete_process_data(p_process_run_id);
--
EXCEPTION WHEN OTHERS THEN
  retcode := 2; /*critical error*/
  errbuf := sqlerrm;
END delete_gsp;
--
END hrfrbsoc;

/
