--------------------------------------------------------
--  DDL for Package Body OKC_REP_CONTRACT_TEXT_IDX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_REP_CONTRACT_TEXT_IDX_PVT" AS
/* $Header: OKCVREPSRMDB.pls 120.1.12010000.3 2011/03/10 18:14:55 harchand ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ---------------------------------------------------------------------------
  G_PARTY_TYPE_INTERNAL   CONSTANT   VARCHAR2(12) := 'INTERNAL_ORG';
  G_PARTY_TYPE_CUSTOMER   CONSTANT   VARCHAR2(12) := 'CUSTOMER_ORG';
  G_PARTY_TYPE_SUPPLIER   CONSTANT   VARCHAR2(12) := 'SUPPLIER_ORG';
  G_PARTY_TYPE_PARTNER    CONSTANT   VARCHAR2(11) := 'PARTNER_ORG';

  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKC';
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_REP_CONTRACT_TEXT_IDX_PVT';
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'okc.plsql.'||G_PKG_NAME||'.';

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';

-- Start of comments
--API name      : okc_rep_ver_md
--Type          : Private.
--Function      : Procedure to collect metadata for Repository contract
--Pre-reqs      : None.
--Parameters    :
--IN            : r_id         IN ROWID           Required
--              : md_lob       IN OUT NOCOPY CLOB Required
--Note          :
-- End of comments
PROCEDURE okc_rep_con_md(
  r_id IN ROWID,
  md_lob IN OUT NOCOPY CLOB)
IS
  l_api_name VARCHAR2(32);

  TYPE CurTyp IS REF CURSOR;  -- define weak REF CURSOR type
  con_cur   CurTyp;  -- declare cursor variable

  sql_stmt VARCHAR2(10000);

  TYPE OrgNameList      IS TABLE OF VARCHAR(200);
  TYPE ConNumList       IS TABLE OF VARCHAR(200);
  TYPE ConNameList      IS TABLE OF VARCHAR(450);
  TYPE ConDescList      IS TABLE OF VARCHAR(2000);
  TYPE KeywordList      IS TABLE OF VARCHAR(2000);
  TYPE CommentList      IS TABLE OF VARCHAR(2000);
  TYPE PartyNameList    IS TABLE OF VARCHAR(200);
  TYPE ContactnameList  IS TABLE OF VARCHAR(200);

  org_name          OrgNameList;
  contract_number   ConNumList;
  contract_name     ConNameList;
  description       ConDescList;
  keywords          KeywordList;
  version_comments  CommentList;
  party_name        PartyNameList;
  contact_name      ContactnameList;

BEGIN
  --initialize local variables
  l_api_name := 'okc_rep_con_md';

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Entering APPS.OKC_REP_CONTRACT_TEXT_IDX_PVT.okc_rep_ver_md');
  END IF;

-----------------------------------------
-- Add contract metadata
-----------------------------------------

  sql_stmt :=
    'SELECT '||
    '    NVL(o.name,'' '') as org_name '||
    '    ,NVL(c.contract_number,'' '') as contract_number '||
    '    ,NVL(c.contract_name,'' '') as contract_name '||
    '    ,NVL(c.contract_desc,'' '') as description '||
    '    ,NVL(c.keywords,'' '') as keywords '||
    '    ,NVL(c.version_comments,'' '') as version_comments '||
    'FROM '||
	    'okc_rep_contracts_all c, '||
	    'hr_all_organization_units_vl o '||
    'WHERE  c.org_id = o.organization_id '||
    'AND	 c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO org_name, contract_number, contract_name, description, keywords, version_comments;

   IF org_name.COUNT <> 0 THEN
     FOR i IN org_name.FIRST..org_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(org_name(i))+1, org_name(i) || ' ' );
       DBMS_LOB.WRITEAPPEND( md_lob, length(contract_number(i))+1, contract_number(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(contract_name(i))+1, contract_name(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(description(i))+1, description(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(keywords(i))+1, keywords(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(version_comments(i))+1, version_comments(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added contract metadata');
  END IF;

-----------------------------------------
-- Add party metadata
-----------------------------------------

  sql_stmt :=
    'SELECT '||
  	'     NVL(o.name,'' '') as party_name '||
  	'FROM '||
  	  'okc_rep_contracts_all c, '||
  	  'okc_rep_contract_parties p, '||
  	  'hr_all_organization_units_vl o '||
  	'WHERE c.contract_id = p.contract_id '||
  	'AND   p.party_id = o.organization_id '||
  	'AND   p.party_role_code = '''|| G_PARTY_TYPE_INTERNAL || ''' ' ||
  	'AND   c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO party_name;

   IF party_name.COUNT <> 0 THEN
     FOR i IN party_name.FIRST..party_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(party_name(i))+1, party_name(i) || ' ' );
     END LOOP;
   END IF;

  CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added internal party metadata');
  END IF;


  sql_stmt :=
  	'SELECT '||
  	'     NVL(v.vendor_name,'' '') as party_name '||
  	'FROM '||
  	  'okc_rep_contracts_all c, '||
  	  'okc_rep_contract_parties p, '||
  	  'po_vendors v '||
  	'WHERE   c.contract_id = p.contract_id '||
  	'AND     p.party_id = v.vendor_id '||
  	'AND		p.party_role_code = '''|| G_PARTY_TYPE_SUPPLIER || ''' ' ||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO party_name;

   IF party_name.COUNT <> 0 THEN
     FOR i IN party_name.FIRST..party_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(party_name(i))+1, party_name(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added supplier party metadata');
  END IF;

  sql_stmt :=
  	'SELECT '||
  	'     NVL(hz.party_name,'' '') as party_name '||
  	'FROM '||
  	  'okc_rep_contracts_all c, '||
  	  'okc_rep_contract_parties p, '||
  	  'hz_parties hz '||
  	'WHERE   c.contract_id = p.contract_id '||
  	'AND     p.party_id = hz.party_id '||
  	'AND		p.party_role_code IN (''' || G_PARTY_TYPE_CUSTOMER ||''', '''|| G_PARTY_TYPE_PARTNER || ''') '||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO party_name;

   IF party_name.COUNT <> 0 THEN
     FOR i IN party_name.FIRST..party_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(party_name(i))+1, party_name(i) || ' ' );
     END LOOP;
   END IF;


   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added partner party metadata');
  END IF;

-----------------------------------------
-- Add contact metadata
-----------------------------------------

  sql_stmt :=
  	'SELECT '||
  	'     NVL(per.full_name,'' '') as contact_name '||
  	'FROM '||
  	  'okc_rep_contracts_all c, '||
  	  'okc_rep_party_contacts ct, '||
  	  'per_all_people_f per '||
  	'WHERE   c.contract_id = ct.contract_id '||
  	'AND		ct.party_role_code = ''' || G_PARTY_TYPE_INTERNAL || ''' ' ||
  	'AND		ct.contact_id = per.person_id '||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO contact_name;

   IF contact_name.COUNT <> 0 THEN
     FOR i IN contact_name.FIRST..contact_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(contact_name(i))+1, contact_name(i) || ' ');
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added internal party contact metadata');
  END IF;

  sql_stmt :=
  	'SELECT '||
  	'     NVL2(v.last_name, v.last_name||'' ''||v.first_name, '' '') as contact_name '||
  	'FROM '||
  	  'okc_rep_contracts_all c, '||
  	  'okc_rep_party_contacts ct, '||
  	  'po_vendor_contacts v '||
  	'WHERE   c.contract_id = ct.contract_id '||
  	'AND     ct.contact_id = v.vendor_contact_id '||
  	'AND		ct.PARTY_ROLE_CODE = '''|| G_PARTY_TYPE_SUPPLIER || ''' ' ||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO contact_name;

   IF contact_name.COUNT <> 0 THEN
     FOR i IN contact_name.FIRST..contact_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(contact_name(i))+1, contact_name(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added supplier party contact metadata');
  END IF;

  sql_stmt :=
  	'SELECT '||
  	'     hz.party_name AS contact_name '||
  	'FROM '||
  	  'okc_rep_contracts_all c, '||
  	  'okc_rep_party_contacts ct, '||
  	  'hz_parties hz '||
  	'WHERE		c.contract_id = ct.contract_id '||
  	'AND		ct.party_role_code IN ( '''||G_PARTY_TYPE_CUSTOMER ||''', '''|| G_PARTY_TYPE_PARTNER || ''') '||
  	'AND		ct.contact_id = hz.party_id '||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO contact_name;

   IF contact_name.COUNT <> 0 THEN
     FOR i IN contact_name.FIRST..contact_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(contact_name(i))+1, contact_name(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added customer and partner party contact metadata');
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Leaving APPS.OKC_REP_CONTRACT_TEXT_IDX_PVT.okc_rep_ver_md');
  END IF;
END;

-- Start of comments
--API name      : okc_rep_ver_md
--Type          : Private.
--Function      : Procedure to collect metadata for Repository contract versions
--Pre-reqs      : None.
--Parameters    :
--IN            : r_id         IN ROWID           Required
--              : md_lob       IN OUT NOCOPY CLOB Required
--Note          :
-- End of comments
PROCEDURE okc_rep_ver_md(
  r_id IN ROWID,
  md_lob IN OUT NOCOPY CLOB)
IS
  l_api_name VARCHAR2(32);

  TYPE CurTyp IS REF CURSOR;  -- define weak REF CURSOR type
  con_cur   CurTyp;  -- declare cursor variable

  sql_stmt VARCHAR2(10000);

  TYPE OrgNameList      IS TABLE OF VARCHAR(200);
  TYPE ConNumList       IS TABLE OF VARCHAR(200);
  TYPE ConNameList      IS TABLE OF VARCHAR(450);
  TYPE ConDescList      IS TABLE OF VARCHAR(2000);
  TYPE KeywordList      IS TABLE OF VARCHAR(2000);
  TYPE CommentList      IS TABLE OF VARCHAR(2000);
  TYPE PartyNameList    IS TABLE OF VARCHAR(200);
  TYPE ContactnameList  IS TABLE OF VARCHAR(200);

  org_name          OrgNameList;
  contract_number   ConNumList;
  contract_name     ConNameList;
  description       ConDescList;
  keywords          KeywordList;
  version_comments  CommentList;
  party_name        PartyNameList;
  contact_name      ContactnameList;

BEGIN
  --initialize local variables
  l_api_name := 'okc_rep_ver_md';

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Entering APPS.OKC_REP_CONTRACT_TEXT_IDX_PVT.okc_rep_ver_md');
  END IF;

-----------------------------------------
-- Add contract metadata
-----------------------------------------

  sql_stmt :=
    'SELECT '||
    '    NVL(o.name,'' '') as org_name '||
    '    ,NVL(c.contract_number,'' '') as contract_number '||
    '    ,NVL(c.contract_name,'' '') as contract_name '||
    '    ,NVL(c.contract_desc,'' '') as description '||
    '    ,NVL(c.keywords,'' '') as keywords '||
    '    ,NVL(c.version_comments,'' '') as version_comments '||
    'FROM '||
	    'okc_rep_contract_vers c, '||
	    'hr_all_organization_units_vl o '||
    'WHERE  c.org_id = o.organization_id '||
    'AND	 c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO org_name, contract_number, contract_name, description, keywords, version_comments;

   IF org_name.COUNT <> 0 THEN
     FOR i IN org_name.FIRST..org_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(org_name(i))+1, org_name(i) || ' ' );
       DBMS_LOB.WRITEAPPEND( md_lob, length(contract_number(i))+1, contract_number(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(contract_name(i))+1, contract_name(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(description(i))+1, description(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(keywords(i))+1, keywords(i) || ' ' );
    	 DBMS_LOB.WRITEAPPEND( md_lob, length(version_comments(i))+1, version_comments(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added contract metadata');
  END IF;

-----------------------------------------
-- Add party metadata
-----------------------------------------

  sql_stmt :=
    'SELECT '||
  	'     NVL(o.name,'' '') as party_name '||
  	'FROM '||
  	  'okc_rep_contract_vers c, '||
  	  'okc_rep_contract_parties p, '||
  	  'hr_all_organization_units_vl o '||
  	'WHERE c.contract_id = p.contract_id '||
  	'AND   p.party_id = o.organization_id '||
  	'AND   p.party_role_code = '''|| G_PARTY_TYPE_INTERNAL || ''' ' ||
  	'AND   c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO party_name;

   IF party_name.COUNT <> 0 THEN
     FOR i IN party_name.FIRST..party_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(party_name(i))+1, party_name(i) || ' ' );
     END LOOP;
   END IF;

  CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added internal party metadata');
  END IF;


  sql_stmt :=
  	'SELECT '||
  	'     NVL(v.vendor_name,'' '') as party_name '||
  	'FROM '||
  	  'okc_rep_contract_vers c, '||
  	  'okc_rep_contract_parties p, '||
  	  'po_vendors v '||
  	'WHERE   c.contract_id = p.contract_id '||
  	'AND     p.party_id = v.vendor_id '||
  	'AND		p.party_role_code = '''|| G_PARTY_TYPE_SUPPLIER || ''' ' ||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO party_name;

   IF party_name.COUNT <> 0 THEN
     FOR i IN party_name.FIRST..party_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(party_name(i))+1, party_name(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added supplier party metadata');
  END IF;

  sql_stmt :=
  	'SELECT '||
  	'     NVL(hz.party_name,'' '') as party_name '||
  	'FROM '||
  	  'okc_rep_contract_vers c, '||
  	  'okc_rep_contract_parties p, '||
  	  'hz_parties hz '||
  	'WHERE   c.contract_id = p.contract_id '||
  	'AND     p.party_id = hz.party_id '||
  	'AND		p.party_role_code IN (''' || G_PARTY_TYPE_CUSTOMER ||''', '''|| G_PARTY_TYPE_PARTNER || ''') '||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO party_name;

   IF party_name.COUNT <> 0 THEN
     FOR i IN party_name.FIRST..party_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(party_name(i))+1, party_name(i) || ' ' );
     END LOOP;
   END IF;


   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added partner party metadata');
  END IF;

-----------------------------------------
-- Add contact metadata
-----------------------------------------

  sql_stmt :=
  	'SELECT '||
  	'     NVL(per.full_name,'' '') as contact_name '||
  	'FROM '||
  	  'okc_rep_contract_vers c, '||
  	  'okc_rep_party_contacts ct, '||
  	  'per_all_people_f per '||
  	'WHERE   c.contract_id = ct.contract_id '||
  	'AND		ct.party_role_code = ''' || G_PARTY_TYPE_INTERNAL || ''' ' ||
  	'AND		ct.contact_id = per.person_id '||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO contact_name;

   IF contact_name.COUNT <> 0 THEN
     FOR i IN contact_name.FIRST..contact_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(contact_name(i))+1, contact_name(i) || ' ');
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added internal party contact metadata');
  END IF;

  sql_stmt :=
  	'SELECT '||
  	'     NVL2(v.last_name, v.last_name||'' ''||v.first_name, '' '') as contact_name '||
  	'FROM '||
  	  'okc_rep_contract_vers c, '||
  	  'okc_rep_party_contacts ct, '||
  	  'po_vendor_contacts v '||
  	'WHERE   c.contract_id = ct.contract_id '||
  	'AND     ct.contact_id = v.vendor_contact_id '||
  	'AND		ct.PARTY_ROLE_CODE = '''|| G_PARTY_TYPE_SUPPLIER || ''' ' ||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO contact_name;

   IF contact_name.COUNT <> 0 THEN
     FOR i IN contact_name.FIRST..contact_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(contact_name(i))+1, contact_name(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added supplier party contact metadata');
  END IF;

  sql_stmt :=
  	'SELECT '||
  	'     hz.party_name AS contact_name '||
  	'FROM '||
  	  'okc_rep_contract_vers c, '||
  	  'okc_rep_party_contacts ct, '||
  	  'hz_parties hz '||
  	'WHERE		c.contract_id = ct.contract_id '||
  	'AND		ct.party_role_code IN ( '''||G_PARTY_TYPE_CUSTOMER ||''', '''|| G_PARTY_TYPE_PARTNER || ''') '||
  	'AND		ct.contact_id = hz.party_id '||
  	'AND		c.rowid = :1 ';

   OPEN con_cur FOR sql_stmt USING r_id;
   FETCH con_cur BULK COLLECT INTO contact_name;

   IF contact_name.COUNT <> 0 THEN
     FOR i IN contact_name.FIRST..contact_name.LAST LOOP
       DBMS_LOB.WRITEAPPEND( md_lob, length(contact_name(i))+1, contact_name(i) || ' ' );
     END LOOP;
   END IF;

   CLOSE con_cur;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Added customer and partner party contact metadata');
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(
      FND_LOG.LEVEL_PROCEDURE,
      G_MODULE||l_api_name,
      'Leaving APPS.OKC_REP_CONTRACT_TEXT_IDX_PVT.okc_rep_ver_md');
  END IF;
END;

END;

/

  GRANT EXECUTE ON "APPS"."OKC_REP_CONTRACT_TEXT_IDX_PVT" TO "CTXSYS";
