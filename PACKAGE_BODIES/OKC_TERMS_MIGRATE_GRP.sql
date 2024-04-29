--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_MIGRATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_MIGRATE_GRP" AS
/* $Header: OKCGTMGB.pls 120.0.12010000.16 2013/05/27 10:08:15 aksgoyal noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP                    CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKC_TERMS_COPY_GRP';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   :=  OKC_API.G_APP_NAME;

  ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_MODULE                     CONSTANT VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKC_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_UNABLE_TO_RESERVE_REC      CONSTANT   VARCHAR2(200) := OKC_API.G_UNABLE_TO_RESERVE_REC;
  G_CURRENT_ORG_ID             NUMBER := -99;
  G_ORG_ID                     NUMBER ;
  G_PO_STATUS_CODE             PO_HEADERS_ALL.STATUS_LOOKUP_CODE%TYPE;
  G_DIR_NAME                   VARCHAR2(2000);

  G_ENABLE_DELIVERABLES        VARCHAR2(1) := 'N';
  G_COPY_DELIVERABLES          VARCHAR2(1) := 'N';
  G_TEMPLATE_MISS_REC          OKC_TERMS_TEMPLATES_PVT.template_rec_type;
  G_DOCUMENT_NUMBER            OKC_TEMPLATE_USAGES.DOCUMENT_NUMBER%TYPE;
  G_TARGET_DOC_TYPE VARCHAR2(240):= NULL;
  G_TARGET_RESP_DOC_TYPE   VARCHAR2(240);

  -- One Time fetch and cache the current Org.
    CURSOR CUR_ORG_CSR IS
          SELECT NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
		       NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
          FROM DUAL;


  TYPE g_doc_type IS RECORD (
    DOCUMENT_TYPE OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE,
    DOCUMENT_TYPE_CLASS OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE_CLASS%TYPE,
    NAME OKC_BUS_DOC_TYPES_TL.NAME%TYPE,
    INTENT OKC_BUS_DOC_TYPES_B.INTENT%TYPE,
    PROVISION_ALLOWED_YN OKC_BUS_DOC_TYPES_B.PROVISION_ALLOWED_YN%TYPE,
    ENABLE_DELIVERABLES_YN OKC_BUS_DOC_TYPES_B.ENABLE_DELIVERABLES_YN%TYPE,
    ENABLE_ATTACHMENTS_YN OKC_BUS_DOC_TYPES_B.ENABLE_ATTACHMENTS_YN%TYPE,
    TARGET_RESPONSE_DOC_TYPE OKC_BUS_DOC_TYPES_B.TARGET_RESPONSE_DOC_TYPE%TYPE);

  G_DOC_TYPE_REC g_doc_type;

 Procedure apply_numbering_scheme
                      ( p_document_type           IN   Varchar2,
				                p_document_id             IN   Number,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number)
 IS
 l_api_name              CONSTANT VARCHAR2(30) := 'Apply_Numbering_Scheme';
 l_numbering_scheme      OKC_TEMPLATE_USAGES.DOC_NUMBERING_SCHEME%TYPE;

 CURSOR l_numbering_scheme_csr IS
 SELECT doc_numbering_scheme
 FROM
   OKC_TEMPLATE_USAGES
 WHERE   document_type = p_document_type
 AND     document_id   = p_document_id;

 BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Entered OKC_TERMS_MIGRATE_GRP.Apply_Numbering_Scheme');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Parameter List ');
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: p_document_type : '||p_document_type);
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: p_document_id : '||p_document_id);
   END IF;

   OPEN l_numbering_scheme_csr;
   FETCH l_numbering_scheme_csr INTO l_numbering_scheme;
   CLOSE l_numbering_scheme_csr;

   IF l_numbering_scheme IS NOT NULL THEN

     OKC_NUMBER_SCHEME_GRP.apply_numbering_scheme(
            p_api_version        => 1,
            p_init_msg_list      => FND_API.G_FALSE,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_validate_commit    => FND_API.G_FALSE,
            p_validation_string  => 'OKC_TEST_UI',
            p_commit             => FND_API.G_FALSE,
            p_doc_type           => p_document_type,
            p_doc_id             => p_document_id,
            p_num_scheme_id      => l_numbering_scheme
          );
   END IF ;

 END apply_numbering_scheme;


 Procedure validate_document
                      ( p_document_type           IN   Varchar2,
				                p_document_id             IN   Number,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number)
 IS
 l_api_name                   CONSTANT VARCHAR2(30) := 'Validate_Document';
 l_po_status_code             PO_HEADERS_ALL.STATUS_LOOKUP_CODE%TYPE;
 l_po_type_code               PO_HEADERS_ALL.TYPE_LOOKUP_CODE%TYPE;



 CURSOR l_doc_type_csr IS
   SELECT DOCUMENT_TYPE,
          DOCUMENT_TYPE_CLASS,
          NAME,
          INTENT,
 	     PROVISION_ALLOWED_YN,
	     ENABLE_DELIVERABLES_YN,
	     ENABLE_ATTACHMENTS_YN,
       TARGET_RESPONSE_DOC_TYPE
   FROM okc_bus_doc_types_vl
   WHERE document_type = p_document_type;

   CURSOR l_po_doc_csr IS
   SELECT TYPE_LOOKUP_CODE,
          STATUS_LOOKUP_CODE,
          ORG_ID,
  	     SEGMENT1
   FROM PO_HEADERS_ALL
   WHERE po_header_id = p_document_id;

   CURSOR l_so_doc_csr IS
   SELECT org_id,
          order_number
   FROM oe_order_headers_all
   WHERE header_id = p_document_id;

   CURSOR l_sa_doc_csr IS
   SELECT org_id,
          order_number
   FROM oe_blanket_headers_all
   WHERE header_id = p_document_id;

   CURSOR l_rep_doc_csr IS
   SELECT org_id,
          contract_number
   FROM okc_rep_contracts_all
   WHERE contract_id = p_document_id;

   CURSOR  l_sourcing_doc_csr
   is
   SELECT org_id, Decode (contract_type, 'BLANKET', 'PA_BLANKET', 'CONTRACT' , 'PA_CONTRACT', 'BLANKET', 'PO_STANDARD',NULL) target_doc_type
   FROM pon_auction_headers_all
   WHERE auction_header_id = p_document_id;


 BEGIN
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Entered OKC_TERMS_MIGRATE_GRP.Validate_Document');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: Parameter List ');
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: p_document_type : '||p_document_type);
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'200: p_document_id : '||p_document_id);
   END IF;

   OPEN l_doc_type_csr;
   FETCH l_doc_type_csr INTO G_DOC_TYPE_REC;
   IF l_doc_type_csr%NOTFOUND THEN
     --Invalid document type
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_DOC_TYPE',
				        p_token1       => 'P_DOCUMENT_TYPE',
				        p_token1_value => p_document_type);

     x_return_status := G_RET_STS_ERROR;
   END IF;
   CLOSE l_doc_type_csr;

   IF p_document_type IN ('PA_BLANKET', 'PA_CONTRACT','PO_STANDARD') THEN

     OPEN l_po_doc_csr;
     FETCH l_po_doc_csr INTO l_po_type_code,l_po_status_code,g_org_id,g_document_number;
      IF l_po_doc_csr%NOTFOUND THEN
        --Invalid document ID
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_DOC_ID',
				        p_token1       => 'P_DOCUMENT_ID',
				        p_token1_value => p_document_id);
        x_return_status := G_RET_STS_ERROR;
      END IF;
     CLOSE l_po_doc_csr;

     IF substr(p_document_type,4,length(p_document_type)-3) <> l_po_type_code THEN
       --Invalid document
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_DOC_TYPE',
				        p_token1       => 'P_DOCUMENT_TYPE',
				        p_token1_value => p_document_type);
       x_return_status := G_RET_STS_ERROR;
     END IF;


     -- Add check for PO_ STATUS and make G_ENABLE_DELIVERABLES = 'Y'
     IF l_po_status_code is NULL and G_DOC_TYPE_REC.ENABLE_DELIVERABLES_YN = 'Y' THEN
        G_COPY_DELIVERABLES := 'Y' ;
     ELSE
        G_COPY_DELIVERABLES := 'N' ;
     END IF;

   ELSIF p_document_type = 'B' THEN

     OPEN l_sa_doc_csr;
     FETCH l_sa_doc_csr INTO g_org_id,g_document_number;
     IF l_sa_doc_csr%NOTFOUND THEN
       --Invalid document ID
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_DOC_ID',
				        p_token1       => 'P_DOCUMENT_ID',
				        p_token1_value => p_document_id);
       x_return_status := G_RET_STS_ERROR;
     END IF;
     CLOSE l_sa_doc_csr;

   ELSIF p_document_type = 'O' THEN
     OPEN l_so_doc_csr;
     FETCH l_so_doc_csr INTO g_org_id,g_document_number;
       IF l_so_doc_csr%NOTFOUND THEN
         --Invalid document ID
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_DOC_ID',
				        p_token1       => 'P_DOCUMENT_ID',
				        p_token1_value => p_document_id);
         x_return_status := G_RET_STS_ERROR;
       END IF;
     CLOSE l_so_doc_csr;

   ELSIF p_document_type LIKE 'REP%' THEN
    OPEN l_rep_doc_csr;
    FETCH l_rep_doc_csr INTO g_org_id, g_document_number;
      IF l_rep_doc_csr%NOTFOUND THEN
         --Invalid document ID
	      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_DOC_ID',
				        p_token1       => 'P_DOCUMENT_ID',
				        p_token1_value => p_document_id);
         x_return_status := G_RET_STS_ERROR;

      END IF;
    CLOSE l_rep_doc_csr;

   ELSIF p_document_type IN ('AUCTION','RFI','RFQ','SOLICITATION')
   THEN
       OPEN l_sourcing_doc_csr;
       FETCH l_sourcing_doc_csr INTO g_org_id, G_TARGET_DOC_TYPE;
       IF l_sourcing_doc_csr%NOTFOUND THEN
        okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                        p_msg_name     => 'OKC_TERMS_INVALID_DOC_ID',
        	  			        p_token1       => 'P_DOCUMENT_ID',
 				                  p_token1_value => p_document_id);
         x_return_status := G_RET_STS_ERROR;

       END IF;
       CLOSE l_sourcing_doc_csr;
   END IF;

 END validate_document;


  FUNCTION get_blob_from_file(p_dir_name in varchar2,
                              p_file_name in varchar2,
                              x_return_status out  nocopy varchar2)
  RETURN blob IS
    pragma autonomous_transaction;
    l_temp_blob blob := NULL;
    l_from_file bfile;
    l_blob_length number;
    l_ddl_string varchar2(2000);
    l_file_exists integer;

  BEGIN
    x_return_status := G_RET_STS_SUCCESS;
    IF (g_dir_name IS NULL OR g_dir_name <> p_dir_name) THEN
      l_ddl_string := 'create or replace directory OKC_LEG_DOC_DIR as '''||p_dir_name||'''';
	 APPS_DDL.APPS_DDL(l_ddl_string);
	 g_dir_name := p_dir_name;
    END IF;

    l_from_file := bfilename('OKC_LEG_DOC_DIR', p_file_name);

      BEGIN
      l_file_exists := dbms_lob.fileexists(l_from_file);
      IF l_file_exists = 0 THEN
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_FILE');
        x_return_status := G_RET_STS_ERROR;
      ELSIF l_file_exists = 1 THEN
        x_return_status := G_RET_STS_SUCCESS;
      ELSE
	   l_file_exists := 0;
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_FILE');
        x_return_status := G_RET_STS_ERROR;
      END IF;
      EXCEPTION
      WHEN DBMS_LOB.NOEXIST_DIRECTORY THEN
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_DIR');
	   l_file_exists := 0;
        x_return_status := G_RET_STS_ERROR;
	 WHEN DBMS_LOB.NOPRIV_DIRECTORY THEN
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_DIR');
	   l_file_exists := 0;
        x_return_status := G_RET_STS_ERROR;
	 WHEN DBMS_LOB.INVALID_DIRECTORY THEN
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_DIR');
	   l_file_exists := 0;
        x_return_status := G_RET_STS_ERROR;
      END ;



    IF l_file_exists = 1 THEn
    -- read file length
    dbms_lob.fileopen(l_from_file, dbms_lob.file_readonly);
    l_blob_length := dbms_lob.getlength(l_from_file);
    dbms_lob.fileclose(l_from_file);
    -- create blob locator
    dbms_lob.createtemporary(l_temp_blob, false, dbms_lob.call);
    -- load the blob
    dbms_lob.open(l_from_file, dbms_lob.lob_readonly);
    dbms_lob.open(l_temp_blob, dbms_lob.lob_readwrite);
    dbms_lob.loadfromfile(l_temp_blob, l_from_file, l_blob_length);
    -- close handles to blob and file
    dbms_lob.close(l_temp_blob);
    dbms_lob.close(l_from_file);
    END IF;
    return l_temp_blob;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_ERROR;
  END get_blob_from_file;

  FUNCTION get_content_type(p_file_name varchar2)
  RETURN varchar2 IS
    l_content_type  FND_LOBS.file_content_type%TYPE := 'text/plain';
    l_file_name varchar2(2000);
  BEGIN
    l_file_name := lower(p_file_name);
    IF l_file_name LIKE '%.avi' THEN
      l_content_type := 'video/avi';
    ELSIF l_file_name LIKE '%.bmp' THEN
      l_content_type := 'image/x-ms-bmpa';
    ELSIF l_file_name LIKE '%.css' THEN
      l_content_type := 'text/css';
    ELSIF l_file_name LIKE '%.doc' THEN
      l_content_type := 'application/vnd.msword';
    ELSIF l_file_name LIKE '%.gif' THEN
      l_content_type := 'image/gif';
    ELSIF l_file_name LIKE '%.gz' THEN
      l_content_type := 'application/x-gzip';
    ELSIF l_file_name LIKE '%.hqx' THEN
      l_content_type := 'application/mac-binhex40';
    ELSIF l_file_name LIKE '%.htm' THEN
      l_content_type := 'text/html';
    ELSIF l_file_name LIKE '%.html' THEN
      l_content_type := 'text/html';
    ELSIF l_file_name LIKE '%.jpeg' THEN
      l_content_type := 'image/jpeg';
    ELSIF l_file_name LIKE '%.jpg' THEN
      l_content_type := 'image/jpeg';
   ELSIF l_file_name LIKE '%.mid' THEN
      l_content_type :='audio/mid';
   ELSIF l_file_name LIKE '%.mov' THEN
      l_content_type :='video/quicktime';
   ELSIF l_file_name LIKE '%.mp2' THEN
      l_content_type :='audio/x-mpeg';
   ELSIF l_file_name LIKE '%.mp3' THEN
      l_content_type :='audio/mpeg';
   ELSIF l_file_name LIKE '%.mpeg' THEN
      l_content_type := 'video/mpeg';
   ELSIF l_file_name LIKE '%.mpg' THEN
      l_content_type := 'video/mpeg';
   ELSIF l_file_name LIKE '%.mpv2' THEN
      l_content_type := 'video/x-mpeg2';
   ELSIF l_file_name LIKE '%.pdf' THEN
      l_content_type := 'application/pdf';
   ELSIF l_file_name LIKE '%.ppt' THEN
      l_content_type := 'application/vnd.ms-powerpoint';
   ELSIF l_file_name LIKE '%.ps' THEN
      l_content_type :='application/postscript';
   ELSIF l_file_name LIKE '%.rtf' THEN
      l_content_type := 'application/rtf';
   ELSIF l_file_name LIKE '%.scd' THEN
      l_content_type := 'application/vnd.ms-schedule';
   ELSIF l_file_name LIKE '%.sgml' THEN
      l_content_type := 'text/sgml';
   ELSIF l_file_name LIKE '%.tar' THEN
      l_content_type := 'application/x-tar';
   ELSIF l_file_name LIKE '%.tif' THEN
      l_content_type := 'image/tiff';
   ELSIF l_file_name LIKE '%.tiff' THEN
      l_content_type := 'image/tiff';
   ELSIF l_file_name LIKE '%.tsv' THEN
      l_content_type := 'text/tab-separated-values';
   ELSIF l_file_name LIKE '%.txt' THEN
      l_content_type := 'text/plain';
   ELSIF l_file_name LIKE '%.vrml' THEN
      l_content_type := 'model/vrml';
   ELSIF l_file_name LIKE '%.wav' THEN
      l_content_type := 'audio/wav';
   ELSIF l_file_name LIKE '%.xbm' THEN
      l_content_type := 'image/x-xbitmap';
   ELSIF l_file_name LIKE '%.xls' THEN
      l_content_type := 'application/vnd.ms-excel';
   ELSIF l_file_name LIKE '%.xml' THEN
      l_content_type := 'text/xml';
   ELSIF l_file_name LIKE '%.Z' THEN
      l_content_type := 'application/x-compress';
   ELSIF l_file_name LIKE '%.zip' THEN
      l_content_type := 'application/x-zip-compressed';
   END IF;
   RETURN l_content_type;
  END get_content_type;


Procedure Create_Contract_Terms
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_contract_source         IN   Varchar2,
				    p_contract_tmpl_id        IN   Number default NULL,
				    p_contract_tmpl_name      IN   Varchar2 default NULL,
				    p_attachment_file_loc     IN   Varchar2 default NULL,
				    p_attachment_file_name    IN   Varchar2 default NULL,
				    p_attachment_file_desc    IN   Varchar2 default NULL
                        )
IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'Create_Contract_Terms';
l_conterms_deliv_upd_date    DATE := NULL;
l_document_type              OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE;
l_document_id                NUMBER;
lc_document_type             OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE%TYPE := p_document_type;
lc_document_id               OKC_TEMPLATE_USAGES.DOCUMENT_ID%TYPE := p_document_id;
l_dummy                      VARCHAR2(1) := NULL;
l_blob                       BLOB := null;
l_fid                        NUMBER;
l_content_type               FND_LOBS.file_content_type%TYPE;
l_attachment_file_name       FND_LOBS.file_name%TYPE;
l_attachment_file_loc        VARCHAR2(2000);
l_attachment_file_desc       FND_DOCUMENTS_TL.description%TYPE;
l_rowid                      VARCHAR2(120);
l_created_by                 OKC_CONTRACT_DOCS.CREATED_BY%TYPE;
l_creation_date              OKC_CONTRACT_DOCS.CREATION_DATE%TYPE;
l_last_updated_by            OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
l_last_update_login          OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
l_last_update_date           OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;
l_seq_num                    FND_ATTACHED_DOCUMENTS.SEQ_NUM%TYPE := 1;
l_business_document_version  NUMBER := -99;
lf_document_id               FND_DOCUMENTS.DOCUMENT_ID%TYPE;

l_new_attachment_id         FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;

lc_business_document_type     OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_TYPE%TYPE;
lc_business_document_id       OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_ID%TYPE;
lc_business_document_version  OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_VERSION%TYPE;
lc_attached_document_id      OKC_CONTRACT_DOCS.ATTACHED_DOCUMENT_ID%TYPE;

l_attached_document_id      OKC_CONTRACT_DOCS.ATTACHED_DOCUMENT_ID%TYPE;
l_media_id                  FND_DOCUMENTS_TL.MEDIA_ID%TYPE;
L_primary_contract_doc_flag VARCHAR2(1) := 'N';
l_category_id               FND_DOCUMENT_CATEGORIES.CATEGORY_ID%TYPE;

l_doc_intent                VARCHAR2(1);

  TYPE l_tmpl_type IS RECORD (
       template_id OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE,
       template_name OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE,
       status_code OKC_TERMS_TEMPLATES_ALL.STATUS_CODE%TYPE,
	  start_date OKC_TERMS_TEMPLATES_ALL.START_DATE%TYPE,
	  end_date OKC_TERMS_TEMPLATES_ALL.END_DATE%TYPE,
	  intent OKC_TERMS_TEMPLATES_ALL.INTENT%TYPE,
	  org_id OKC_TERMS_TEMPLATES_ALL.ORG_ID%TYPE,
	  tmpl_numbering_scheme OKC_TERMS_TEMPLATES_ALL.TMPL_NUMBERING_SCHEME%TYPE);

  l_tmpl_type_rec l_tmpl_type;


CURSOR l_tmpl_id_validate_csr IS
SELECT template_id,
       template_name,
       status_code,
	  start_date,
	  end_date,
	  intent,
	  org_id,
	  tmpl_numbering_scheme
FROM
  OKC_TERMS_TEMPLATES_ALL TMP
WHERE
  TMP.template_id = p_contract_tmpl_id;

CURSOR l_tmpl_name_validate_csr(l_org_id IN NUMBER) IS
SELECT template_id,
       template_name,
       status_code,
	  start_date,
	  end_date,
	  intent,
	  org_id,
	  tmpl_numbering_scheme
FROM
  OKC_TERMS_TEMPLATES_ALL TMP
WHERE TMP.template_name = p_contract_tmpl_name
AND   TMP.org_id = l_org_id;


CURSOR l_tmpl_doc_exist_csr IS
SELECT 1
FROM
  OKC_TEMPLATE_USAGES
WHERE   document_type = p_document_type
AND     document_id   = p_document_id;


CURSOR l_alwd_usgs_csr(l_template_id IN NUMBER) IS
SELECT 1
FROM
  OKC_ALLOWED_TMPL_USAGES
WHERE   document_type = p_document_type
AND     template_id   = l_template_id;

CURSOR l_fnd_lobs_nextval_csr IS
SELECT fnd_lobs_s.nextval
FROM
  DUAL;

CURSOR l_fnd_att_doc_nextval_csr IS
SELECT fnd_attached_documents_s.nextval
FROM
  DUAL;

CURSOR l_cat_id_csr IS
SELECT category_id
FROM
  FND_DOCUMENT_CATEGORIES
WHERE  application_id = 510 AND name = 'OKC_REPO_CONTRACT' ;


CURSOR l_bus_doc_ver_csr IS
SELECT nvl(poh.revision_num,-99)
FROM
  po_headers_archive_all poa,
  po_headers_all poh
WHERE  poh.po_header_id = poa.po_header_id
AND    poh.revision_num = poa.revision_num
AND    poh.po_header_id = p_document_id;

CURSOR c_get_intent_csr IS
  SELECT intent FROM okc_bus_doc_types_b
  WHERE document_type = p_document_type;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.Create_Contract_Terms');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_source : '||p_contract_source);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_tmpl_id : '||p_contract_tmpl_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_tmpl_name : '||p_contract_tmpl_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_attachment_file_loc : '||p_attachment_file_loc);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_attachment_file_name : '||p_attachment_file_name);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT G_CREATE_CONTRACT_TERMS_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;

  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  -- Check that Contract source is Structured or Attached
  IF p_contract_source not in ('STRUCTURED','ATTACHED') THEN
  -- invalid contract source
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_SOURCE',
				        p_token1       => 'P_CONTRACT_SOURCE',
				        p_token1_value => p_contract_source);
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

     l_attachment_file_name := RTRIM(LTRIM(p_attachment_file_name));
     l_attachment_file_loc  := RTRIM(LTRIM(p_attachment_file_loc));
	IF p_attachment_file_desc IS NULL THEN
        l_attachment_file_desc := l_attachment_file_name;
     ELSE
        l_attachment_file_desc := RTRIM(LTRIM(p_attachment_file_desc));
     END IF;

  IF p_contract_source ='STRUCTURED' THEN
     IF p_contract_tmpl_name is NULL AND p_contract_tmpl_id is NULL THEN
	-- no template is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_TMPL_PROVIDED');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
	END IF;

  ELSIF p_contract_source='ATTACHED' THEN
     IF l_attachment_file_loc is NULL OR l_attachment_file_name is NULL THEN
	-- either attachment file location is not provided or file name is not provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_ATTACH_PROVIDED');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
	END IF;

  END IF;

  IF p_contract_source ='STRUCTURED' THEN
  IF p_contract_tmpl_id is not NULL THEN
     OPEN l_tmpl_id_validate_csr;
	FETCH l_tmpl_id_validate_csr INTO l_tmpl_type_rec ;
     IF l_tmpl_id_validate_csr%NOTFOUND THEN
      --Invalid Template ID
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_TMPL_ID',
				        p_token1       => 'P_TMPL_ID',
				        p_token1_value => p_contract_tmpl_id);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_tmpl_id_validate_csr;

  ELSE
     OPEN l_tmpl_name_validate_csr(G_CURRENT_ORG_ID);
	FETCH l_tmpl_name_validate_csr INTO l_tmpl_type_rec ;
     IF l_tmpl_name_validate_csr%NOTFOUND THEN
      --Invalid Template Name
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_TMPL_NAME',
				        p_token1       => 'P_TMPL_NAME',
				        p_token1_value => p_contract_tmpl_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_tmpl_name_validate_csr;

  END IF;

  /*IF p_document_type IN ('PA_BLANKET', 'PA_CONTRACT','PO_STANDARD') AND
      l_tmpl_type_rec.intent = 'S' THEN
      --Template is of Sell Intent
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_TMPL_INTENT',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name,
				        p_token2       => 'P_TEMPLATE_INTENT',
				        p_token2_value => l_tmpl_type_rec.intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => 'BUY');
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_document_type IN ('B', 'O') AND
      l_tmpl_type_rec.intent = 'B' THEN
      --Template is of Buy Intent
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_TMPL_INTENT',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name,
				        p_token2       => 'P_TEMPLATE_INTENT',
				        p_token2_value => l_tmpl_type_rec.intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => 'SELL');
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;    */

  OPEN c_get_intent_csr;
   FETCH c_get_intent_csr INTO l_doc_intent;
   CLOSE c_get_intent_csr;

   IF l_doc_intent <>  l_tmpl_type_rec.intent THEN

    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_TMPL_INTENT',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name,
				        p_token2       => 'P_TEMPLATE_INTENT',
				        p_token2_value => l_tmpl_type_rec.intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => l_doc_intent);

      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;




   IF l_tmpl_type_rec.status_code <> 'APPROVED' THEN
      --Invalid Template Status
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_TMPL_STS',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF SYSDATE NOT BETWEEN l_tmpl_type_rec.start_date AND nvl(l_tmpl_type_rec.end_date,SYSDATE) THEN
      --Template is not Active
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INACTIVE_TMPL',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

  OPEN l_alwd_usgs_csr(l_tmpl_type_rec.template_id);
  FETCH l_alwd_usgs_csr INTO l_dummy ;
  IF l_alwd_usgs_csr%NOTFOUND THEN
   --Template is not assigned to Document
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_TMPL_USG_ASSOC',
					   p_token1       => 'P_CONTRACT_TEMPLATE',
					   p_token1_value => l_tmpl_type_rec.template_id,
				        p_token2       => 'P_DOCUMENT_TYPE',
				        p_token2_value => p_document_type);
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_alwd_usgs_csr;

  END IF; -- IF p_contract_source ='STRUCTURED' THEN

  OPEN l_tmpl_doc_exist_csr;
  FETCH l_tmpl_doc_exist_csr INTO l_dummy ;
  IF l_tmpl_doc_exist_csr%FOUND THEN
   --Document already has Template
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_EXIST');
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_tmpl_doc_exist_csr;

  IF (p_contract_source = 'STRUCTURED') THEN

  -- Instantiate Template
  OKC_TERMS_COPY_PVT.copy_tc(
    p_api_version            => l_api_version,
    p_init_msg_list          => FND_API.G_FALSE,
    p_commit                 => FND_API.G_FALSE,
    p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
    p_source_doc_id          => l_tmpl_type_rec.template_id,
    p_target_doc_type        => lc_document_type, --p_document_type,
    p_target_doc_id          => lc_document_id,   --p_document_id,
    p_document_number        => g_document_number,  -- need to pass the Doc Number
    p_keep_version           => 'N',
    p_article_effective_date => SYSDATE,
    p_target_template_rec    => G_TEMPLATE_MISS_REC,
    p_retain_deliverable     => 'Y',
    --p_allow_duplicates       => 'N',
    --p_keep_orig_ref          => 'N',
    x_return_status          => x_return_status,
    x_msg_data               => x_msg_data,
    x_msg_count              => x_msg_count
    --p_copy_abstract_yn       => NULL,
    --p_copy_for_amendment     => NULL
    );


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TERMS_COPY_PVT.copy_tc, return status'||x_return_status);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    -----------------------------------------------------

	IF G_COPY_DELIVERABLES = 'Y' THEN
       l_conterms_deliv_upd_date := sysdate;

     -- External Party Related fields should be passed otherwsie it may pose some issues
            OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables (
            p_api_version         => 1,
            p_init_msg_list       => FND_API.G_FALSE,
            p_source_doc_type        => OKC_TERMS_UTIL_GRP.G_TMPL_DOC_TYPE,
            p_source_doc_id          => l_tmpl_type_rec.template_id,
            p_target_doc_type        => p_document_type,
            p_target_doc_id          => p_document_id,
            p_target_doc_number      => g_document_number,
            p_internal_party_id      => NULL,
            p_internal_contact_id    => NULL,
            p_external_party_id      => NULL,
            p_external_party_site_id      => NULL,
            p_external_contact_id    => NULL,
            p_target_contractual_doctype    => NULL,
            p_target_response_doctype       => NULL,
            p_copy_del_attachments_yn       => 'Y',
            x_msg_data            => x_msg_data,
            x_msg_count           => x_msg_count,
            x_return_status       => x_return_status );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
     END IF;

apply_numbering_scheme(
           p_document_type     => p_document_type,
		 p_document_id       => p_document_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
         );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: apply_numbering_scheme, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


  ELSE --(it is ATTACHED) --  IF (p_contract_source = 'STRUCTURED') THEN
    OKC_TEMPLATE_USAGES_GRP.create_template_usages(
           p_api_version        => l_api_version,
           p_init_msg_list      => FND_API.G_FALSE ,
           p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
           p_commit             => FND_API.G_FALSE,

           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count,
           x_msg_data           => x_msg_data,

           p_document_type      => p_document_type ,
           p_document_id        => p_document_id,
           p_template_id        => NULL,
           p_doc_numbering_scheme  => NULL,
           p_document_number    => NULL,
           p_article_effective_date => SYSDATE,
           p_config_header_id    => NULL,
           p_config_revision_number => NULL,
           p_valid_config_yn     => NULL,
           p_orig_system_reference_code => NULL,
           p_orig_system_reference_id1  => NULL,
           p_orig_system_reference_id2  => NULL,

           p_approval_abstract_text => NULL,
           p_contract_source_code   =>'ATTACHED',
           p_authoring_party_code   => NULL,
           p_autogen_deviations_flag => NULL,
           p_source_change_allowed_flag => 'Y',

           x_document_type          => l_document_type,
           x_document_id            => l_document_id
    );
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TEMPLATE_USAGESE_GRP.create_template_usages, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


  END IF; --  IF (p_contract_source = 'STRUCTURED') THEN

  IF (l_attachment_file_loc IS NOT NULL AND l_attachment_file_name IS NOT NULL) THEN

     IF (p_contract_source = 'ATTACHED') THEN
        l_primary_contract_doc_flag := 'Y';
     END IF;

    -- Read the lob from the directory using DBMS_LOBS.
    l_blob := get_blob_from_file(p_dir_name  => l_attachment_file_loc,
                                 p_file_name => l_attachment_file_name,
						   x_return_status => x_return_status);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished get_blob_from_file, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;


    OPEN l_fnd_lobs_nextval_csr;
    FETCH l_fnd_lobs_nextval_csr INTO l_fid ;
    IF l_fnd_lobs_nextval_csr%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_fnd_lobs_nextval_csr;

    l_content_type := get_content_type(p_file_name => l_attachment_file_name);

    BEGIN
    INSERT INTO fnd_lobs (
       file_id,
       file_name,
       file_content_type,
       upload_date,
       expiration_date,
       program_name,
       program_tag,
       file_data,
       language,
       oracle_charset,
       file_format )
     VALUES (
       l_fid,
       l_attachment_file_name,
       l_content_type,
       sysdate,
       null,
       'OKCGTMGB',
       null,
       l_blob,
       userenv('LANG'),
       fnd_gfm.iana_to_oracle(fnd_gfm.get_iso_charset),
       fnd_gfm.set_file_format(l_content_type));
    EXCEPTION
      WHEN OTHERS THEN
	 X_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END;

    OPEN l_fnd_att_doc_nextval_csr;
    FETCH l_fnd_att_doc_nextval_csr INTO l_new_attachment_id ;
    IF l_fnd_att_doc_nextval_csr%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_fnd_att_doc_nextval_csr;


    OPEN l_cat_id_csr;
    FETCH l_cat_id_csr INTO l_category_id;
    IF l_cat_id_csr%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_cat_id_csr;

    IF p_document_type IN ('PA_BLANKET', 'PA_CONTRACT','PO_STANDARD') THEN
    OPEN l_bus_doc_ver_csr;
    FETCH l_bus_doc_ver_csr INTO l_business_document_version;
    IF l_bus_doc_ver_csr%NOTFOUND THEN
	  l_business_document_version := -99;
    END IF;
    CLOSE l_bus_doc_ver_csr;
    END IF;

   l_creation_date := Sysdate;
   l_created_by := Fnd_Global.User_Id;
   l_last_update_date := l_creation_date;
   l_last_updated_by := l_created_by;
   l_last_update_login := Fnd_Global.Login_Id;


        fnd_attached_documents_pkg.insert_row(
              x_rowid                => l_rowid,
              x_attached_document_id => l_new_attachment_id,
              x_document_id          => lf_document_id,
              x_creation_date        => sysdate,
              x_created_by           => fnd_global.user_id,
              x_last_update_date     => sysdate,
              x_last_updated_by      => fnd_global.user_id,
              x_last_update_login    => fnd_global.login_id,
              x_seq_num              => l_seq_num,
              x_entity_name          => 'OKC_CONTRACT_DOCS',
              x_column1              => NULL,
              x_pk1_value            => p_document_type,
              x_pk2_value            => to_char(p_document_id),
              x_pk3_value            => to_char(l_business_document_version),
              x_pk4_value            => NULL,
              x_pk5_value            => NULL,
              x_automatically_added_flag => 'N',
              x_datatype_id          => 6,
              x_category_id          => l_category_id,
              x_security_type        => 4,
              x_publish_flag         => 'N',
              x_usage_type           => NULL,
              x_language             => NULL,
		    x_description          => l_attachment_file_desc,
		    x_file_name            => l_attachment_file_name,
              x_media_id             => l_fid,
              x_doc_attribute_category => NULL,
              x_doc_attribute1       => NULL,
              x_doc_attribute2       => NULL,
              x_doc_attribute3       => NULL,
              x_doc_attribute4       => NULL,
              x_doc_attribute5       => NULL,
              x_doc_attribute6       => NULL,
              x_doc_attribute7       => NULL,
              x_doc_attribute8       => NULL,
              x_doc_attribute9       => NULL,
              x_doc_attribute10      => NULL,
              x_doc_attribute11      => NULL,
              x_doc_attribute12      => NULL,
              x_doc_attribute13      => NULL,
              x_doc_attribute14      => NULL,
              x_doc_attribute15      => NULL,
              X_create_doc           => 'Y'
          );

          l_attached_document_id := l_new_attachment_id;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished FND_ATTACHED_DOCUMENTS_PKG.insert_row ');
       END IF;


        okc_contract_docs_grp.Insert_Contract_Doc(
           p_api_version               => l_api_version,
           p_init_msg_list             => FND_API.G_FALSE ,
           p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
           p_commit                    => FND_API.G_FALSE,

           x_return_status             => x_return_status,
           x_msg_count                 => x_msg_count,
           x_msg_data                  => x_msg_data,

           p_business_document_type    => p_document_type,
		 p_business_document_id      => p_document_id,
		 p_business_document_version => l_business_document_version,
		 p_attached_document_id      => l_attached_document_id,
		 p_external_visibility_flag  => 'Y',
		 p_effective_from_type       => p_document_type,
		 p_effective_from_id         => p_document_id,
		 p_effective_from_version    => l_business_document_version,
		 p_include_for_approval_flag => 'N',
		 p_create_fnd_attach         => 'N',
		 p_program_id                => NULL,
		 p_program_application_id    => NULL,
		 p_request_id                => NULL,
		 p_program_update_date       => NULL,
		 p_parent_attached_doc_id    => NULL,
		 p_generated_flag            => 'N',
		 p_delete_flag               => 'N',

           p_primary_contract_doc_flag => l_primary_contract_doc_flag,
	      p_mergeable_doc_flag        => 'N',
	      p_versioning_flag           => 'N',

           x_business_document_type    => lc_business_document_type,
           x_business_document_id      => lc_business_document_id,
	      x_business_document_version => lc_business_document_version,
           x_attached_document_id      => lc_attached_document_id
    );


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_CONTRACT_DOCS_GRP.insert_contract_doc, return status'||x_return_status);
        END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
       END IF;

  END IF;

/*User will need this if they want to update th ePO terms columns*/
  /*IF G_DOC_TYPE_REC.DOCUMENT_TYPE_CLASS = 'PO' THEN
    PO_CONTERMS_UPGRADE_GRP. apply_template_change
     ( p_api_version => 1,
       p_po_header_id => p_document_id,
       p_conterms_articles_upd_date => sysdate,
       p_conterms_deliv_upd_date => l_conterms_deliv_upd_date,
       x_return_status => x_return_status);

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished PO_CONTERMS_UPGRAD_GRP.apply_template_usages, return status'||x_return_status);
       END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;

  END IF;*/
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving create_contract_terms');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving create_contract_terms: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
         IF l_tmpl_id_validate_csr%ISOPEN THEN
            CLOSE l_tmpl_id_validate_csr;
	    END IF;
         IF l_tmpl_name_validate_csr%ISOPEN THEN
            CLOSE l_tmpl_name_validate_csr;
	    END IF;
         IF l_alwd_usgs_csr%ISOPEN THEN
            CLOSE l_alwd_usgs_csr;
	    END IF;
         IF l_tmpl_doc_exist_csr%ISOPEN THEN
            CLOSE l_tmpl_doc_exist_csr;
	    END IF;

         ROLLBACK TO g_create_contract_terms_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving create_contract_terms: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_create_contract_terms_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving create_contract_terms because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_create_contract_terms_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Create_Contract_Terms;

Procedure Add_Contract_Doc
                      ( p_api_version             IN   Number,
                        p_init_msg_list           IN   Varchar2 default FND_API.G_FALSE,
                        p_commit                  IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status           OUT  NOCOPY Varchar2,
                        x_msg_data                OUT  NOCOPY Varchar2,
                        x_msg_count               OUT  NOCOPY Number,
                        p_document_type           IN   Varchar2,
                        p_document_id             IN   Number,
                        p_contract_category       IN   Varchar2, -- C for Contract and S for Supporting Doc
				    p_contract_doc_type       IN   Varchar2,  -- U for URL and F for File
				    p_url                     IN   Varchar2,
                        p_attachment_file_loc     IN   Varchar2,
                        p_attachment_file_name    IN   Varchar2,
                        p_description             IN   Varchar2
                        )
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'Add_Contract_Doc';
l_attachment_file_name       FND_LOBS.file_name%TYPE;
l_attachment_file_loc        VARCHAR2(2000);
l_description                FND_DOCUMENTS_TL.description%TYPE;
l_content_type               FND_LOBS.file_content_type%TYPE;
l_blob                       BLOB := null;
l_fid                        NUMBER;
l_new_attachment_id          FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
l_business_document_version  NUMBER := -99;
lf_document_id               FND_DOCUMENTS.DOCUMENT_ID%TYPE;
l_datatype_id                FND_DOCUMENTS.DATATYPE_ID%TYPE;
l_seq_num                    FND_ATTACHED_DOCUMENTS.SEQ_NUM%TYPE := 1;

lc_business_document_type    OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_TYPE%TYPE;
lc_business_document_id      OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_ID%TYPE;
lc_business_document_version  OKC_CONTRACT_DOCS.BUSINESS_DOCUMENT_VERSION%TYPE;
lc_attached_document_id      OKC_CONTRACT_DOCS.ATTACHED_DOCUMENT_ID%TYPE;

l_attached_document_id       OKC_CONTRACT_DOCS.ATTACHED_DOCUMENT_ID%TYPE;
l_dummy                      VARCHAR2(1) := NULL;
l_contract_category          VARCHAR2(240);

l_rowid                      VARCHAR2(120);
l_created_by                 OKC_CONTRACT_DOCS.CREATED_BY%TYPE;
l_creation_date              OKC_CONTRACT_DOCS.CREATION_DATE%TYPE;
l_last_updated_by            OKC_CONTRACT_DOCS.LAST_UPDATED_BY%TYPE;
l_last_update_login          OKC_CONTRACT_DOCS.LAST_UPDATE_LOGIN%TYPE;
l_last_update_date           OKC_CONTRACT_DOCS.LAST_UPDATE_DATE%TYPE;

l_media_id                  FND_DOCUMENTS_TL.MEDIA_ID%TYPE;
L_primary_contract_doc_flag VARCHAR2(1) := 'N';
l_category_id               FND_DOCUMENT_CATEGORIES.CATEGORY_ID%TYPE;
l_url FND_DOCUMENTS.URL%TYPE;

CURSOR l_tmpl_doc_exist_csr IS
SELECT 1
FROM
  OKC_TEMPLATE_USAGES
WHERE   document_type = p_document_type
AND     document_id   = p_document_id;

CURSOR l_fnd_lobs_nextval_csr IS
SELECT fnd_lobs_s.nextval
FROM
  DUAL;

CURSOR l_fnd_att_doc_nextval_csr IS
SELECT fnd_attached_documents_s.nextval
FROM
  DUAL;

CURSOR l_cat_id_csr(l_category IN VARCHAR2) IS
SELECT category_id
FROM
  FND_DOCUMENT_CATEGORIES
WHERE  application_id = 510
AND    name = l_category;

CURSOR l_bus_doc_ver_csr IS
SELECT nvl(poh.revision_num,-99)
FROM
  po_headers_archive_all poa,
  po_headers_all poh
WHERE  poh.po_header_id = poa.po_header_id
AND    poh.revision_num = poa.revision_num
AND    poh.po_header_id = p_document_id;

BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.Add_Contract_Doc');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_category : '||p_contract_category);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_attachment_file_loc : '||p_attachment_file_loc);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_attachment_file_name : '||p_attachment_file_name);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT G_ADD_CONTRACT_DOC_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;


  IF G_DOC_TYPE_REC.enable_attachments_yn = 'N' THEN
      --Attachment functionality is not supported
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_ATTACH',
				        p_token1       => 'P_DOC_NAME',
				        p_token1_value => G_DOC_TYPE_REC.name);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

  IF p_document_type NOT  LIKE 'REP%' THEN
  OPEN l_tmpl_doc_exist_csr;
  FETCH l_tmpl_doc_exist_csr INTO l_dummy ;
  IF l_tmpl_doc_exist_csr%NOTFOUND THEN
   --Document does not have Template
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_TERMS_NOT_EXIST',
				        p_token1       => 'P_DOC_NAME',
				        p_token1_value => G_DOC_TYPE_REC.name);
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_tmpl_doc_exist_csr;
   END IF;

    IF p_contract_category NOT IN ('C','S') THEN
       -- Contract Category is not correct
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_INVALID_CON_CAT');
       x_return_status := G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR ;
    ELSE
      IF p_contract_category = 'S' THEN
	    l_contract_category := 'OKC_REPO_SUPPORTING_DOC';
      ELSE
	    l_contract_category := 'OKC_REPO_CONTRACT';
      END IF;
    END IF;

    IF p_contract_doc_type NOT IN ('U','F') THEN
       -- Contract Doc Type is not correct
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_INVALID_CON_DOC_TYPE');
       x_return_status := G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR ;
    ELSE
      IF p_contract_doc_type = 'U' THEN
	    l_datatype_id := 5;
      ELSE
	    l_datatype_id := 6;
      END IF;
    END IF;

     IF l_datatype_id = 5 AND p_url IS NULL THEN
       -- URL is not provided
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_INVALID_URL');
       x_return_status := G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR ;
     END IF;

     IF l_datatype_id = 6 AND
	   (p_attachment_file_name IS NULL OR p_attachment_file_loc IS NULL) THEN
       -- file info is not provided
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKC_INVALID_FILE_INFO');
       x_return_status := G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR ;
    END IF;

     IF l_datatype_id = 6 THEN
        l_attachment_file_name := RTRIM(LTRIM(p_attachment_file_name));
        l_attachment_file_loc  := RTRIM(LTRIM(p_attachment_file_loc));
     IF p_description IS NULL THEN
        l_description := l_attachment_file_name;
     ELSE
        l_description := RTRIM(LTRIM(p_description));
     END IF;
    -- Read the lob from the directory using DBMS_LOBS.
    l_blob := get_blob_from_file(p_dir_name  => l_attachment_file_loc,
                                 p_file_name => l_attachment_file_name,
                                 x_return_status => x_return_status);

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished get_blob_from_file, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
        END IF;

    OPEN l_fnd_lobs_nextval_csr;
    FETCH l_fnd_lobs_nextval_csr INTO l_fid ;
    IF l_fnd_lobs_nextval_csr%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_fnd_lobs_nextval_csr;

    l_content_type := get_content_type(p_file_name => l_attachment_file_name);

    BEGIN
    INSERT INTO fnd_lobs (
       file_id,
       file_name,
       file_content_type,
       upload_date,
       expiration_date,
       program_name,
       program_tag,
       file_data,
       language,
       oracle_charset,
       file_format )
     VALUES (
       l_fid,
       l_attachment_file_name,
       l_content_type,
       sysdate,
       null,
       'OKCGTMGB',
       null,
       l_blob,
       userenv('LANG'),
       fnd_gfm.iana_to_oracle(fnd_gfm.get_iso_charset),
       fnd_gfm.set_file_format(l_content_type));
    EXCEPTION
      WHEN OTHERS THEN
	 X_RETURN_STATUS := G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END;
     END IF ;   --IF l_datatype_id = 6 THEN

     IF l_datatype_id = 5 THEN
	l_fid :=NULL;
	l_attachment_file_name := null;
  l_url :=   p_url;
        IF p_description IS NULL THEN
           l_description := p_url;
        ELSE
           l_description := RTRIM(LTRIM(p_description));
        END IF;
     END IF ;   --IF l_datatype_id = 5 THEN

    OPEN l_fnd_att_doc_nextval_csr;
    FETCH l_fnd_att_doc_nextval_csr INTO l_new_attachment_id ;
    IF l_fnd_att_doc_nextval_csr%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_fnd_att_doc_nextval_csr;


    OPEN l_cat_id_csr(l_contract_category);
    FETCH l_cat_id_csr INTO l_category_id;
    IF l_cat_id_csr%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_cat_id_csr;


    IF p_document_type IN ('PA_BLANKET', 'PA_CONTRACT','PO_STANDARD') THEN
    OPEN l_bus_doc_ver_csr;
    FETCH l_bus_doc_ver_csr INTO l_business_document_version;
    IF l_bus_doc_ver_csr%NOTFOUND THEN
       l_business_document_version := -99;
    END IF;
    CLOSE l_bus_doc_ver_csr;
    END IF;

   l_creation_date := Sysdate;
   l_created_by := Fnd_Global.User_Id;
   l_last_update_date := l_creation_date;
   l_last_updated_by := l_created_by;
   l_last_update_login := Fnd_Global.Login_Id;


        fnd_attached_documents_pkg.insert_row(
              x_rowid                => l_rowid,
              x_attached_document_id => l_new_attachment_id,
              x_document_id          => lf_document_id,
              x_creation_date        => sysdate,
              x_created_by           => fnd_global.user_id,
              x_last_update_date     => sysdate,
              x_last_updated_by      => fnd_global.user_id,
              x_last_update_login    => fnd_global.login_id,
              x_seq_num              => l_seq_num,
              x_entity_name          => 'OKC_CONTRACT_DOCS',
              x_column1              => NULL,
              x_pk1_value            => p_document_type,
              x_pk2_value            => to_char(p_document_id),
              x_pk3_value            => to_char(l_business_document_version),
              x_pk4_value            => NULL,
              x_pk5_value            => NULL,
              x_automatically_added_flag => 'N',
              x_datatype_id          =>  l_datatype_id,
              x_category_id          => l_category_id,
              x_security_type        => 4,
              x_publish_flag         => 'Y',
              x_usage_type           => NULL,
              x_language             => NULL,
              x_description          => l_description,
	         x_file_name            => l_attachment_file_name,
              x_media_id             => l_fid,
              x_doc_attribute_category => NULL,
              x_doc_attribute1       => NULL,
              x_doc_attribute2       => NULL,
              x_doc_attribute3       => NULL,
              x_doc_attribute4       => NULL,
              x_doc_attribute5       => NULL,
              x_doc_attribute6       => NULL,
              x_doc_attribute7       => NULL,
              x_doc_attribute8       => NULL,
              x_doc_attribute9       => NULL,
              x_doc_attribute10      => NULL,
              x_doc_attribute11      => NULL,
              x_doc_attribute12      => NULL,
              x_doc_attribute13      => NULL,
              x_doc_attribute14      => NULL,
              x_doc_attribute15      => NULL,
              X_create_doc           => 'Y',
              x_url => l_url
          );

          l_attached_document_id := l_new_attachment_id;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished FND_ATTACHED_DOCUMENTS_PKG.insert_row ');
       END IF;


        okc_contract_docs_grp.Insert_Contract_Doc(
           p_api_version               => l_api_version,
           p_init_msg_list             => FND_API.G_FALSE ,
           p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
           p_commit                    => FND_API.G_FALSE,

           x_return_status             => x_return_status,
           x_msg_count                 => x_msg_count,
           x_msg_data                  => x_msg_data,

           p_business_document_type    => p_document_type,
	      p_business_document_id      => p_document_id,
	      p_business_document_version => l_business_document_version,
	      p_attached_document_id      => l_attached_document_id,
	      p_external_visibility_flag  => 'N',
	      p_effective_from_type       => p_document_type,
	      p_effective_from_id         => p_document_id,
	      p_effective_from_version    => l_business_document_version,
	      p_include_for_approval_flag => 'N',
	      p_create_fnd_attach         => 'N',
	      p_program_id                => NULL,
	      p_program_application_id    => NULL,
	      p_request_id                => NULL,
	      p_program_update_date       => NULL,
	      p_parent_attached_doc_id    => NULL,
	      p_generated_flag            => 'N',
	      p_delete_flag               => 'N',

           p_primary_contract_doc_flag => l_primary_contract_doc_flag,
           p_mergeable_doc_flag        => 'N',
           p_versioning_flag           => 'N',

           x_business_document_type    => lc_business_document_type,
           x_business_document_id      => lc_business_document_id,
           x_business_document_version => lc_business_document_version,
           x_attached_document_id      => lc_attached_document_id
    );


        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_CONTRACT_DOCS_GRP.insert_contract_doc, return status'||x_return_status);
        END IF;

       IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
       ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
       END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving add_contract_doc');
   END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving add_contract_doc: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
            IF l_tmpl_doc_exist_csr%ISOPEN THEN
               CLOSE l_tmpl_doc_exist_csr;
	    END IF;

         ROLLBACK TO g_add_contract_doc_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving add_contract_doc: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_add_contract_doc_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving add_contract_doc because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_add_contract_doc_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Add_Contract_Doc;

Procedure Add_Standard_Clause
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   NUMBER,
				    p_section_id              IN   NUMBER DEFAULT null,
				    p_section_name            IN   Varchar2 default null,
				    p_clause_version_id       IN   Number default null,
				    p_clause_title            IN   Varchar2 default null,
				    p_clause_version_num      IN   Number default null,
				    p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
				    x_contract_clause_id      OUT  NOCOPY Number,
            p_display_sequence  IN NUMBER DEFAULT NULL,
            p_mode                         IN VARCHAR2 := 'NORMAL' -- Other value 'AMEND'
)
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'Add_Standard_Clause';
l_scn_id                     OKC_SECTIONS_B.ID%TYPE;
l_id                         NUMBER;
l_ref_sequence               NUMBER := 0;
la_ref_sequence              NUMBER := 0;
ls_ref_sequence              NUMBER := 0;
l_doc_intent                 VARCHAR2(1);

TYPE l_cls_type IS RECORD (
       article_id         OKC_ARTICLE_VERSIONS.ARTICLE_ID%TYPE,
       article_title      OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE,
       article_version_id OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE,
       article_version_number OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE,
       article_intent     OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE,
	  provision_yn       OKC_ARTICLE_VERSIONS.PROVISION_YN%TYPE,
	  article_status     OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE,
	  start_date         OKC_ARTICLE_VERSIONS.START_DATE%TYPE,
	  end_date           OKC_ARTICLE_VERSIONS.END_DATE%TYPE);

  l_cls_type_rec l_cls_type;

CURSOR l_sec_id_validate_csr IS
SELECT id
FROM
  OKC_SECTIONS_B SEC
WHERE SEC.ID = p_section_id
AND   DOCUMENT_TYPE = p_document_type
AND   DOCUMENT_ID   = p_document_id;

CURSOR l_sec_name_validate_csr IS
SELECT id
FROM
  OKC_SECTIONS_B SEC
WHERE SEC.heading = p_section_name
AND   DOCUMENT_TYPE = p_document_type
AND   DOCUMENT_ID   = p_document_id;


CURSOR l_cls_id_validate_csr IS
SELECT
       article_id,
	  article_title,
       article_version_id,
	  article_version_number,
       article_intent,
	  provision_yn,
	  article_status,
	  start_date,
	  end_date
FROM
  OKC_ARTICLES_V ART
WHERE ART.article_version_id = p_clause_version_id;

CURSOR l_cls_name_validate_csr(l_org_id IN NUMBER) IS
SELECT
       article_id,
	  article_title,
       article_version_id,
	  article_version_number,
       article_intent,
	  provision_yn,
	  article_status,
	  start_date,
	  end_date
FROM
  okc_articles_local_v ART
WHERE ART.article_title = p_clause_title
AND   ART.org_id = l_org_id
UNION ALL
SELECT
       article_id,
	  article_title,
       article_version_id,
	  article_version_number,
       article_intent,
	  provision_yn,
	  article_status,
	  start_date,
	  end_date
FROM
  okc_articles_global_v ART
WHERE ART.article_title = p_clause_title
AND   ART.org_id = l_org_id;

CURSOR ls_ref_seq_csr(lc_scn_id IN NUMBER) is
SELECT nvl(max(section_sequence),0)
FROM   OKC_SECTIONS_B
WHERE  document_type = p_document_type
AND    document_id   = p_document_id
AND    scn_id=lc_scn_id;

CURSOR la_ref_seq_csr(lc_scn_id IN NUMBER) is
SELECT nvl(max(display_sequence),0)
FROM   OKC_K_ARTICLES_B
WHERE  document_type = p_document_type
AND    document_id   = p_document_id
AND    scn_id=lc_scn_id;

CURSOR c_get_intent_csr IS
  SELECT intent FROM okc_bus_doc_types_b
  WHERE document_type = p_document_type;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.Add_Standard_Clause');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_id : '||p_section_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_name : '||p_section_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_version_id : '||p_clause_version_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_title : '||p_clause_title);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_version_num : '||p_clause_version_num);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_renumber_terms : '||p_renumber_terms);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_add_standard_clause_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;

  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_section_id is NULL and p_section_name is NULL THEN
  -- no section is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_SCN');
    x_return_status := G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_section_id is NOT NULL THEN
     OPEN  l_sec_id_validate_csr;
	   FETCH l_sec_id_validate_csr INTO l_scn_id;
     IF l_sec_id_validate_csr%NOTFOUND THEN
      --Invalid Section
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_SCN_ID',
				        p_token1       => 'P_SCN_ID',
				        p_token1_value => p_section_id);
       x_return_status := G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR ;
     END IF;
	CLOSE l_sec_id_validate_csr;
  ELSE
     OPEN  l_sec_name_validate_csr;
	   FETCH l_sec_name_validate_csr INTO l_scn_id;
     IF l_sec_name_validate_csr%NOTFOUND THEN
      --Invalid Section
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_SCN_NAME',
				        p_token1       => 'P_SCN_NAME',
				        p_token1_value => p_section_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
     END IF;
	CLOSE l_sec_name_validate_csr;
   END IF;

   OPEN  ls_ref_seq_csr(l_scn_id);
   FETCH ls_ref_seq_csr INTO ls_ref_sequence;
   CLOSE ls_ref_seq_csr;

   OPEN  la_ref_seq_csr(l_scn_id);
   FETCH la_ref_seq_csr INTO ls_ref_sequence;
   CLOSE la_ref_seq_csr;

/*If display sequence is passed then insert the clause at that position only.
  Else add it at the end*/
   IF p_display_sequence IS NULL THEN
    IF ls_ref_sequence >= la_ref_sequence THEN
      l_ref_sequence := ls_ref_sequence + 10;
    ELSE
      l_ref_sequence := la_ref_sequence + 10;
    END IF;
   ELSE
      l_ref_sequence := p_display_sequence;
   END IF;

  -- Check that Clause info is provided
  IF p_clause_version_id is NULL and p_clause_title is NULL THEN
  -- no clause is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_clause_version_id is not NULL THEN
     OPEN l_cls_id_validate_csr;
	   FETCH l_cls_id_validate_csr INTO l_cls_type_rec ;
     IF l_cls_id_validate_csr%NOTFOUND THEN
      --Invalid Clause
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_ID',
				        p_token1       => 'P_CLS_VER_ID',
				        p_token1_value => p_clause_version_id);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_cls_id_validate_csr;

  ELSE
     OPEN l_cls_name_validate_csr(G_CURRENT_ORG_ID);
	   FETCH l_cls_name_validate_csr INTO l_cls_type_rec ;
     IF l_cls_name_validate_csr%NOTFOUND THEN
      --Invalid Clause Name
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_NAME',
				        p_token1       => 'P_CLS_TITLE',
				        p_token1_value => p_clause_title);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_cls_name_validate_csr;

  END IF;

   IF l_cls_type_rec.article_status <> 'APPROVED' THEN
      --Invalid Clause Status
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_STS',
				        p_token1       => 'P_CLAUSE_TITLE',
				        p_token1_value => l_cls_type_rec.article_title);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   /*IF p_document_type IN ('PA_BLANKET', 'PA_CONTRACT','PO_STANDARD', 'AUCTION', 'RFI', 'RFQ') AND
      l_cls_type_rec.article_intent = 'S' THEN
      --Clause is of Sell Intent
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_INTENT',
				        p_token1       => 'P_CLAUSE_TITLE',
				        p_token1_value => l_cls_type_rec.article_title,
				        p_token2       => 'P_CLAUSE_INTENT',
				        p_token2_value => l_cls_type_rec.article_intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => 'BUY');
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_document_type IN ('B', 'O', 'QUOTE', 'OKS') AND
      l_cls_type_rec.article_intent = 'B' THEN
      --Clause is of Buy Intent
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_INTENT',
				        p_token1       => 'P_CLAUSE_TITLE',
				        p_token1_value => l_cls_type_rec.article_title,
				        p_token2       => 'P_CLAUSE_INTENT',
				        p_token2_value => l_cls_type_rec.article_intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => 'SELL');
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;    */

   OPEN c_get_intent_csr;
   FETCH c_get_intent_csr INTO l_doc_intent;
   CLOSE c_get_intent_csr;

   IF l_doc_intent <>  l_cls_type_rec.article_intent THEN

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_INTENT',
				        p_token1       => 'P_CLAUSE_TITLE',
				        p_token1_value => l_cls_type_rec.article_title,
				        p_token2       => 'P_CLAUSE_INTENT',
				        p_token2_value => l_cls_type_rec.article_intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => l_doc_intent);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;


   -- if template has provision_yn = 'y' then any clause can be added
   -- otherwise check clause is of not provision = 'y'
   IF G_DOC_TYPE_REC.provision_allowed_yn = 'N'  AND
      l_cls_type_rec.provision_yn = 'Y' THEN
      --Clause is of Provision Type 'Y' not allowed
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_PROV',
				        p_token1       => 'P_CLAUSE_TITLE',
				        p_token1_value => l_cls_type_rec.article_title,
				        p_token2       => 'P_DOCUMENT_TYPE',
				        p_token2_value => p_document_type);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;


   OKC_K_ARTICLES_GRP.create_article(
         p_api_version           => 1,
         p_init_msg_list         => FND_API.G_FALSE,
         p_validation_level      => NULL,
         p_mode                  => 'NORMAL',
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data,
         p_id                    => NULL,
         p_sav_sae_id            => l_cls_type_rec.article_id,
         p_document_type         => p_document_type,
         p_document_id           => p_document_id,
         p_scn_id                => l_scn_id,
         p_article_version_id    => l_cls_type_rec.article_version_id,
         p_display_sequence      => l_ref_sequence,
         p_amendment_description => NULL,
         p_print_text_yn         => NULL,
         p_ref_article_version_id=> NULL,
         p_ref_article_id        => NULL,
         x_id                    => l_id
      );


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_K_ARTICLES_GRP.create_article, return status'||x_return_status);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSE -- in case of success retrun the OUT param
	      x_contract_clause_id := l_id;
    END IF;
    -----------------------------------------------------

IF p_renumber_terms = 'Y' THEN
apply_numbering_scheme(
           p_document_type     => p_document_type,
		 p_document_id       => p_document_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
         );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: apply_numbering_scheme, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving add_standard_clause');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving add_standard_clause: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;

         IF l_sec_id_validate_csr%ISOPEN THEN
            CLOSE l_sec_id_validate_csr;
	    END IF;
         IF l_sec_name_validate_csr%ISOPEN THEN
            CLOSE l_sec_name_validate_csr;
	    END IF;
         IF l_cls_id_validate_csr%ISOPEN THEN
            CLOSE l_cls_id_validate_csr;
	    END IF;
         IF l_cls_name_validate_csr%ISOPEN THEN
            CLOSE l_cls_name_validate_csr;
	    END IF;

         ROLLBACK TO g_add_standard_clause_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving add_standard_clause: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_add_standard_clause_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving add_standard_clause because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_add_standard_clause_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END Add_Standard_Clause;

Procedure Add_Non_Standard_Clause
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_section_id              IN   NUMBER DEFAULT null,
				    p_section_name            IN   Varchar2 default null,
				    p_clause_title            IN   Varchar2,
				    p_clause_text             IN   CLOB DEFAULT NULL,
				    p_clause_type             IN   Varchar2 default 'OTHER',
				    p_clause_disp_name        IN   Varchar2 default null,
				    p_clause_description      IN   Varchar2 default null,
				    p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
            p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	          p_clause_text_in_word       IN BLOB DEFAULT NULL,
				    x_contract_clause_id      OUT  NOCOPY Number,
				    x_clause_version_id       OUT  NOCOPY Number
                        )
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'Add_Non_Standard_Clause';
l_cat_id                     NUMBER;
l_article_version_id         NUMBER;
l_scn_id                     OKC_SECTIONS_B.ID%TYPE;


CURSOR l_sec_id_validate_csr IS
SELECT id
FROM
  OKC_SECTIONS_B SEC
WHERE SEC.ID = p_section_id
AND   DOCUMENT_TYPE = p_document_type
AND   DOCUMENT_ID   = p_document_id;

CURSOR l_sec_name_validate_csr IS
SELECT id
FROM
  OKC_SECTIONS_B SEC
WHERE SEC.heading = p_section_name
AND   DOCUMENT_TYPE = p_document_type
AND   DOCUMENT_ID   = p_document_id;

BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.Add_Non_Standard_Clause');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_id : '||p_section_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_name : '||p_section_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_title : '||p_clause_title);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_text : '||p_clause_text);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_type : '||p_clause_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_disp_name : '||p_clause_disp_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_description : '||p_clause_description);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_renumber_terms : '||p_renumber_terms);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_add_non_standrad_clause_grp;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_section_id is NULL and p_section_name is NULL THEN
     -- no section is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_SCN');
    x_return_status := G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_section_id is NOT NULL THEN
      OPEN  l_sec_id_validate_csr;
  	  FETCH l_sec_id_validate_csr INTO l_scn_id;
      IF l_sec_id_validate_csr%NOTFOUND THEN
       --Invalid Section
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_SCN_ID',
					   p_token1       => 'P_SCN_ID',
					   p_token1_value => p_section_id);
       x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
      END IF;
	 CLOSE l_sec_id_validate_csr;
   ELSE
      OPEN  l_sec_name_validate_csr;
 	    FETCH l_sec_name_validate_csr INTO l_scn_id;
      IF l_sec_name_validate_csr%NOTFOUND THEN
       --Invalid Section
	      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_SCN_NAME',
				        p_token1       => 'P_SCN_NAME',
				        p_token1_value => p_section_name);
       x_return_status := G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR ;
      END IF;
	  CLOSE l_sec_name_validate_csr;
    END IF;

    /*If article_text is null and article_text in word is also null throw error*/

    IF p_clause_text is NULL and p_clause_text_in_word is NULL THEN
    -- no clause text is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_CLS_TEXT');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
    END IF;

    /*If edited in word is 'Y' then clause text is word is mandatory*/
    IF p_edited_in_word = 'Y' AND p_clause_text_in_word IS NULL THEN
       -- no wml clause text is provided
	    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_text');
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
    END IF;


  OKC_K_NON_STD_ART_GRP.create_non_std_article(
    p_api_version                => 1,
    p_init_msg_list              => FND_API.G_FALSE,
    p_validate_commit            => FND_API.G_FALSE,
    p_validation_string          => 'OKC_TEST_UI',
    p_commit                     => FND_API.G_FALSE,
    p_mode                       =>'NORMAL', -- Other value 'AMEND'
    x_return_status              => x_return_status,
    x_msg_count                  => x_msg_count,
    x_msg_data                   => x_msg_data,
    p_article_title              => p_clause_title,
    p_article_type               => p_clause_type,
    p_article_text               => p_clause_text,
    p_provision_yn               => 'N',
    p_std_article_version_id     => NULL,
    p_display_name               => p_clause_disp_name,
    p_article_description        => p_clause_description,
    p_ref_type                   => 'SECTION', -- 'ARTICLE' or 'SECTION'
    p_ref_id                     => l_scn_id ,-- Id of okc_sections_b or okc_articles_b depending upon ref type
    p_doc_type                   => p_document_type,
    p_doc_id                     => p_document_id,
    p_cat_id                     => NULL, -- Should be passed when exsisitng std is modified to make non-std.If it is passed then ref_type and ref_id doesnt need to be passed.
    p_amendment_description      => NULL,
    p_print_text_yn              => NULL,
    x_cat_id                     => l_cat_id,
    x_article_version_id         => l_article_version_id
    );


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_K_NON_STD_ART_GRP.create_non_std_article, return status'||x_return_status);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSE -- in case of success retrun OUT params
	    x_contract_clause_id    := l_cat_id;
	    x_clause_version_id     := l_article_version_id;
    END IF;
    -----------------------------------------------------

IF p_renumber_terms = 'Y' THEN
apply_numbering_scheme(
           p_document_type     => p_document_type,
		 p_document_id       => p_document_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
         );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: apply_numbering_scheme, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving add_non_standard_clause');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving add_non_standard_clause: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
	    IF l_sec_id_validate_csr%ISOPEN THEN
	       CLOSE l_sec_id_validate_csr;
	    END IF;
	    IF l_sec_name_validate_csr%ISOPEN THEN
	       CLOSE l_sec_name_validate_csr;
	    END IF;

         ROLLBACK TO g_add_non_standrad_clause_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving add_non_standard_clause: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_add_non_standrad_clause_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving add_non_standard_clause because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_add_non_standrad_clause_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Add_Non_Standard_Clause;

Procedure Add_Section
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_section_source          IN   Varchar2,
				    p_section_name            IN   Varchar2,
				    p_section_description     IN   Varchar2 default null,
				    p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
				    x_section_id              OUT  NOCOPY Number
                        )
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'add_section';
l_scn_id                     NUMBER;
l_dummy                      VARCHAR2(1) := NULL;
l_section_sequence           OKC_SECTIONS_B.section_sequence%TYPE;
l_scn_code                   OKC_SECTIONS_B.scn_code%TYPE;
l_scn_heading                OKC_SECTIONS_B.heading%TYPE;
l_scn_desc                   OKC_SECTIONS_B.description%TYPE;
l_section_name               OKC_SECTIONS_B.heading%TYPE;
l_section_description        OKC_SECTIONS_B.description%TYPE;


CURSOR l_sec_validate_csr IS
SELECT lookup_code,meaning,description
FROM
  FND_LOOKUPS
WHERE lookup_type = 'OKC_ARTICLE_SECTION'
AND   lookup_code = p_section_name;

CURSOR l_sec_seq_csr IS
SELECT max(section_sequence)
FROM
  OKC_SECTIONS_B
WHERE document_id = p_document_id
AND   document_type = p_document_type
AND   scn_id IS NULL;

CURSOR l_tmpl_doc_exist_csr IS
SELECT 1
FROM
  OKC_TEMPLATE_USAGES
WHERE   document_type = p_document_type
AND     document_id   = p_document_id;


BEGIN
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.add_section');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_source : '||p_section_source);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_name : '||p_section_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_section_description : '||p_section_description);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_renumber_terms : '||p_renumber_terms);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_add_section_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;

  OPEN l_tmpl_doc_exist_csr;
  FETCH l_tmpl_doc_exist_csr INTO l_dummy ;
  IF l_tmpl_doc_exist_csr%NOTFOUND THEN
   --Document already has Template
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_DOES_NOT_EXIST');
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_tmpl_doc_exist_csr;


   IF p_section_source NOT IN ('LIBRARY','NEW') THEN
      --Invalid Source
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_SEC_SRC',
					   p_token1       => 'P_SECTION_SOURCE',
					   p_token1_value => p_section_source);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_section_source = 'LIBRARY' THEN
   OPEN l_sec_validate_csr;
   FETCH l_sec_validate_csr INTO l_scn_code,l_scn_heading,l_scn_desc ;
   IF l_sec_validate_csr%NOTFOUND THEN
       -- Section does not exist in Contract Library
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_LIB_SCN',
				        p_token1       => 'P_SECTION_NAME',
				        p_token1_value => p_section_name);
       x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_sec_validate_csr;
   END IF;

   OPEN l_sec_seq_csr;
   FETCH l_sec_seq_csr INTO l_section_sequence;
   CLOSE l_sec_seq_csr;

    l_section_sequence := l_section_sequence+10;

   IF p_section_source = 'LIBRARY' THEN
      l_section_name := l_scn_heading;
      l_section_description := l_scn_desc;
   ELSIF p_section_source = 'NEW' THEN
      l_section_name := p_section_name;
      l_section_description := p_section_description;
      l_scn_code := NULL;
   END IF;


   OKC_TERMS_SECTIONS_GRP.create_section(
          p_api_version        => l_api_version,
          p_init_msg_list      => FND_API.G_FALSE,
          p_commit             => FND_API.G_FALSE,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data,
          p_id                 => NULL,
          p_section_sequence   => l_section_sequence,
          p_scn_id             => NULL,
          p_heading            => l_section_name,
          p_description        => l_section_description,
          p_document_type      => p_document_type,
          p_document_id        => p_document_id,
          p_scn_code           => l_scn_code,
          p_mode               => 'NORMAL',
          x_id                 => x_section_id
          );

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_TERMS_SECTIONS.create_section, return status'||x_return_status);
         END IF;

         --------------------------------------------
         IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (x_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
         END IF;
         --------------------------------------------

IF p_renumber_terms = 'Y' THEN
         apply_numbering_scheme(
           p_document_type     => p_document_type,
		       p_document_id       => p_document_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
         );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: apply_numbering_scheme, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving add_section');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving add_section: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
	    IF l_sec_validate_csr%ISOPEN THEN
	       CLOSE l_sec_validate_csr;
	    END IF;

         ROLLBACK TO g_add_section_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving add_section: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_add_section_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving add_section because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_add_section_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Add_Section;

/*Delete Doc will delete all the template associated to the document, the sections
and clauses associated, the deliverables and the contract documents.  */
/*
PROCEDURE Delete_Doc (
    p_api_version      IN  NUMBER,
    p_doc_type         IN  VARCHAR2,
    p_doc_id           IN  NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_data         OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER )
    IS

    CURSOR c_tmpl_usgs_exists IS
    SELECT '!' FROM okc_template_usages
    WHERE document_type = p_doc_type
    AND document_id = p_doc_id;

    l_tmpl_exists VARCHAR2(1);

    BEGIN

    OPEN c_tmpl_usgs_exists;
    FETCH c_tmpl_usgs_exists INTO l_tmpl_exists;
      IF c_tmpl_usgs_exists%FOUND THEN
        okc_terms_util_grp.delete_doc(p_api_version    => 1.0,
                                      x_return_status    => x_return_status,
                                      x_msg_data         =>  x_msg_data,
                                      x_msg_count        =>  x_msg_count,
                                      p_doc_type         =>  p_doc_type,
                                      p_doc_id           =>  p_doc_id);

      END IF;

    CLOSE c_tmpl_usgs_exists;

END Delete_Doc;
*/

PROCEDURE Apps_initialize(p_api_version      IN  NUMBER,
                          p_user_name        IN VARCHAR2,
                          p_resp_name  IN VARCHAR2,
                          p_org_id     IN number)
IS


l_user_id       NUMBER;
l_resp_id       NUMBER;
l_resp_appl_id  NUMBER;

BEGIN


-- Apps Initialization
   SELECT    user_id
    INTO l_user_id
   FROM fnd_user
   WHERE user_name =p_user_name;

   SELECT  b.RESPONSIBILITY_ID,b.APPLICATION_ID
      INTO l_resp_id,l_resp_appl_id
    FROM fnd_responsibility_tl tl, fnd_responsibility b
    WHERE tl.responsibility_name = p_resp_name
      AND LANGUAGE = UserEnv('LANG')
      AND tl.RESPONSIBILITY_ID = b.RESPONSIBILITY_ID;

  fnd_global.apps_initialize
    ( user_id => l_user_id
     ,resp_id => l_resp_id
     ,resp_appl_id => l_resp_appl_id
    );

-- MO init
   mo_global.init('OKC');

-- MO Set policy Context
   mo_global.set_policy_context('S', p_org_id);

END Apps_initialize;


FUNCTION get_valueset_id (
    p_value_set_id    IN NUMBER,
    p_var_value       IN VARCHAR2,
    p_validation_type        IN VARCHAR2)

RETURN number IS

-- I already have a value
CURSOR c1 IS
    select value.flex_value_id
    --,value.description
    from fnd_flex_values_vl value
where value.FLEX_VALUE_SET_ID =  p_value_set_id
and value.flex_value = p_var_value;

CURSOR c2 IS

select
val_tab.application_table_name,
val_tab.value_column_name,
val_tab.id_column_name,
val_tab.additional_where_clause,
val_tab.meaning_column_name
from fnd_flex_validation_tables val_tab
where val_tab.FLEX_VALUE_SET_ID =  p_value_set_id ;

l_value_id NUMBER := null;

c2rec c2%rowtype;

l_select_stmt VARCHAR2(2000);

 value_cursor_id INTEGER;
 ret_val INTEGER;
BEGIN

 --if value set type is 'I' independent or 'X' - independent translatable
 --or 'D' dependent or 'Y' dependent translatable

 IF (p_validation_type = 'I' OR p_validation_type = 'X' OR p_validation_type = 'D' OR p_validation_type = 'Y') THEN

    OPEN c1;
    FETCH c1  INTO l_value_id;
    CLOSE c1;
 ELSIF (p_validation_type = 'F')THEN

 --set the sql statement for valueset
    OPEN c2;
    FETCH c2  INTO c2rec;
    CLOSE c2;

    IF c2rec.id_column_name IS NULL THEN
      RETURN null;
    END IF;

    l_select_stmt := ' SELECT ' || NVL(c2rec.id_column_name,null) ||' as  Flex_value_id,'||
                     NVL(c2rec.value_column_name,'null') ||' as  Flex_value,'||
                     NVL(c2rec.meaning_column_name,'null') ||' as  Flex_meaning FROM '||
                     c2rec.application_table_name ;


    If c2rec.additional_where_clause is not null THEN
 -- If no WHERE keyword, add it
      IF (UPPER(substr(ltrim(c2rec.additional_where_clause),1,5)) <> 'WHERE') AND
         (UPPER(substr(ltrim(c2rec.additional_where_clause),1,8)) <> 'ORDER BY') THEN

        l_select_stmt := l_select_stmt||' WHERE';
      END IF;
-- add where clause
      l_select_stmt :=l_select_stmt||' '|| c2rec.additional_where_clause;
   END IF;
--doing this becuase order by may exist in where clause
      l_select_stmt := 'SELECT FLEX_VALUE_ID FROM ('||l_select_stmt||') WHERE FLEX_VALUE = :1';

     EXECUTE IMMEDIATE(l_select_stmt) INTO l_value_id USING p_var_value;

  END IF;
return l_value_id;
EXCEPTION
WHEN OTHERS THEN
  --close cursors
 IF c1%ISOPEN THEN
   CLOSE c1;
 END IF;

 IF c2%ISOPEN THEN
   CLOSE c2;
 END IF;

 RETURN NULL;
END get_valueset_id;


/*This API migrates variable values from external system to Contracts.
1. p_doc_type is the document type in the target system
2. p_doc_id is the document id in the target system.
3. p_k_clause_id or (p_clause_title and p_clause_version) are mandatory.
4. p_k_clause_id should be the id of the clause in the table OKC_K_ARTICLES_B in target system.
   We can pass this value if we are calling this API along with ADD Clause API.
   The clause_id o/p can be provided to this API directly.

*/
PROCEDURE update_variable_values(p_api_version      IN  NUMBER,
                                 p_doc_type         IN  VARCHAR2,
                                 p_doc_id           IN  NUMBER,
                                 p_k_clause_id        IN  NUMBER DEFAULT NULL,
                                 p_clause_title      IN  VARCHAR2 DEFAULT NULL,
                                 p_clause_version   IN  NUMBER DEFAULT NULL,
                                 p_variable_name    IN VARCHAR2,
                                 p_variable_value   IN VARCHAR2,
                                 p_override_global_yn IN VARCHAR2,
                                 p_global_variable_value  IN VARCHAR2 := NULL,
                                 p_init_msg_list		IN   Varchar2 default FND_API.G_FALSE,
                                 p_commit	          IN   Varchar2 default FND_API.G_FALSE,
                                 x_return_status	  OUT  NOCOPY Varchar2,
                                 x_msg_data	        OUT  NOCOPY Varchar2,
                                 x_msg_count	      OUT  NOCOPY Number
                                 )
IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'add_section';
l_variable_value_id          NUMBER;
l_variable_value             VARCHAR2(240);
l_x_cat_id                   NUMBER;
l_x_variable_code            VARCHAR2(240);
l_values_exists              VARCHAR2(2);
l_variable_code VARCHAR2(240);
l_attr_value_set_id NUMBER;
l_variable_type VARCHAR2(1);
l_external_yn VARCHAR2(1);
l_k_art_id NUMBER;
l_article_id NUMBER;
l_article_version_id NUMBER;
l_validation_type VARCHAR2(1);
l_var_intent VARCHAR2(1);
l_var_exists VARCHAR2(1);
l_global_var_value_id NUMBER;

  CURSOR c_get_variable_code(p_var_intent VARCHAR2) IS
   SELECT b.variable_code, b.variable_type, b.external_yn, b.value_set_id
    FROM okc_bus_variables_tl tl, okc_bus_variables_b b
    WHERE tl.variable_name = p_variable_name
    AND b.variable_code = tl.variable_code
    AND b.variable_intent = p_var_intent
    AND LANGUAGE = UserEnv('LANG');

  CURSOR c_get_value_set_id(p_variable_code VARCHAR2) IS
    SELECT value_set_id
    FROM okc_bus_variables_b
    WHERE variable_code = p_variable_code;

  CURSOR c_get_var_value_id(p_attr_value_set_id NUMBER) IS
    SELECT flex_value_id
    FROM fnd_flex_values
    WHERE flex_value = p_variable_value
    AND FLEX_VALUE_SET_ID = p_attr_value_set_id;

  CURSOR c_get_intent_csr IS
    SELECT intent FROM okc_bus_doc_types_b
    WHERE document_type = p_doc_type;

BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.update_variable_values');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_doc_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_doc_id);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_update_variable_values_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;

  validate_document(
    p_document_type => p_doc_type,
    p_document_id => p_doc_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


   --validate intent for a document / variable
    OPEN c_get_intent_csr;
    FETCH c_get_intent_csr INTO l_var_intent;
    CLOSE c_get_intent_csr;

    --Fetch variable_code for the variable_name
    --validate if variable exists in the system
    OPEN c_get_variable_code(l_var_intent);
    FETCH c_get_variable_code INTO l_variable_code, l_variable_type, l_external_yn, l_attr_value_set_id;
    IF c_get_variable_code%NOTFOUND THEN
      -- Variable does not exist in Contract Library
	    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_LIB_VAR',
				        p_token1       => 'P_VARIABLE_NAME',
				        p_token1_value => p_variable_name);
       x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
    END IF;
    CLOSE c_get_variable_code;

    --validate if variable value exists in the system and fetch the id

    SELECT validation_type INTO l_validation_type
    FROM fnd_flex_value_sets WHERE flex_value_set_id = l_attr_value_set_id;

    /* Fetch the variable value Id's of local and global values form variable values*/
    IF p_variable_value IS NOT NULL THEN
      l_variable_value_id := get_valueset_id
                       (p_value_set_id      => l_attr_value_set_id,
                        p_var_value        => p_variable_value,
                        p_validation_type          => l_validation_type
                      );
    END IF;

    IF (p_global_variable_value IS NOT NULL ) THEN
      l_global_var_value_id := get_valueset_id
                     (p_value_set_id      => l_attr_value_set_id,
                       p_var_value        => p_global_variable_value,
                       p_validation_type  => l_validation_type
                      );
     END IF;

    IF p_k_clause_id IS NOT NULL THEN
          l_k_art_id := p_k_clause_id;
    ELSIF p_clause_title IS NOT NULL AND p_clause_version IS NOT NULL THEN

      SELECT kb.id INTO l_k_art_id
      FROM okc_k_articles_b kb, okc_articles_all a , okc_article_versions v
      WHERE a.article_title = p_clause_title AND a.org_id = G_CURRENT_ORG_ID
      AND kb.document_type = p_doc_type AND kb.document_id = p_doc_id
      AND v.article_version_number = p_clause_version AND a.article_id = v.article_id
      AND kb.sav_sae_id = a.article_id AND kb.article_version_id = v.article_version_id;

    ELSE
     -- Clause ID/clause name, version combination is null
	    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                        p_msg_name     => 'OKC_TERMS_NO_CLS_VALUE',
				                  p_token1       => 'P_VARIABLE_NAME',
				                  p_token1_value => p_variable_name,
                          p_token2       => 'P_VAR_VALUE_SET_ID',
				                  p_token2_value => l_attr_value_set_id);
       x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;

    END IF;

    /*There can exist only 1 row for a given id and variable code combination.
    So we will copy it only once and if another time user re-enters throw error'*/

     SELECT 'Y' INTO l_var_exists
     FROM okc_k_art_variables
     WHERE cat_id = l_k_art_id
     AND variable_code = l_variable_code;

     IF l_var_exists <> 'Y' THEN

      OKC_K_ART_VARIABLES_PVT.insert_row(
        x_return_status          => x_return_status,
        p_cat_id                 => l_k_art_id,
        p_variable_code          => l_variable_code,
        p_variable_type          => l_variable_type,
        p_external_yn            => l_external_yn,
        p_variable_value_id      => l_variable_value_id,
        p_variable_value         => p_variable_value,
        p_attribute_value_set_id => l_attr_value_set_id,
        p_override_global_yn     => p_override_global_yn,
        p_global_variable_value  => p_global_variable_value,
        p_global_var_value_id    => l_global_var_value_id,
        x_cat_id                 => l_x_cat_id,
        x_variable_code          => l_x_variable_code);

     ELSE
      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                        p_msg_name     => 'OKC_ARTID_VAR_ALREADY_EXISTS',
				                  p_token1       => 'P_VARIABLE_NAME',
				                  p_token1_value => p_variable_name,
                          p_token2       => 'P_K_ART_ID',
				                  p_token2_value => l_k_art_id);
       x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;

     END IF;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.update_variable_values, return status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving update_variable_values');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving update_variable_values: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
	   -- IF l_sec_validate_csr%ISOPEN THEN
	     --  CLOSE l_sec_validate_csr;
	    --END IF;

         ROLLBACK TO g_update_variable_values_GRP;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving update_variable_values: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_update_variable_values_GRP;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving update_variable_values because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_update_variable_values_GRP;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END update_variable_values;

PROCEDURE Create_template_usages(p_api_version      IN  NUMBER,
                                 p_document_type         IN  VARCHAR2,
                                 p_document_id           IN  NUMBER,
                                 p_contract_source         IN   VARCHAR2,
				                         p_contract_tmpl_id        IN   Number := NULL,
				                         p_contract_tmpl_name      IN   Varchar2 default NULL,
                                 p_authoring_party_code   IN VARCHAR2 := NULL,
                                 p_autogen_deviations_flag IN VARCHAR2 := NULL,
                                 p_lock_terms_flag        IN VARCHAR2 := NULL,
                                 p_enable_reporting_flag  IN VARCHAR2 := NULL,
                                 p_approval_abstract_text IN CLOB := NULL,
                                 p_locked_by_user_name   IN VARCHAR2 DEFAULT NULL,
                                 p_legal_contact_name IN VARCHAR2 DEFAULT NULL,
                                 p_contract_admin_name IN VARCHAR2 DEFAULT NULL,
                                 p_primary_template    IN VARCHAR2 DEFAULT 'Y',
                                 p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                                 p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                                 x_return_status	          OUT  NOCOPY Varchar2,
                                 x_msg_data	               OUT  NOCOPY Varchar2,
                                 x_msg_count	          OUT  NOCOPY NUMBER)
IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'Create_template_usages';
l_doc_intent                 VARCHAR2(2);
l_dummy                      VARCHAR2(1) := NULL;
l_dummy_n NUMBER;

l_contract_admin_id        OKC_TEMPLATE_USAGES.CONTRACT_ADMIN_ID%TYPE;
l_legal_contact_id         OKC_TEMPLATE_USAGES.LEGAL_CONTACT_ID%TYPE;
l_locked_by_user_id        OKC_TEMPLATE_USAGES.LOCKED_BY_USER_ID%TYPE;
l_document_type         VARCHAR2(240);
l_document_id             NUMBER;

TYPE l_tmpl_type IS RECORD (
       template_id OKC_TERMS_TEMPLATES_ALL.TEMPLATE_ID%TYPE,
       template_name OKC_TERMS_TEMPLATES_ALL.TEMPLATE_NAME%TYPE,
       status_code OKC_TERMS_TEMPLATES_ALL.STATUS_CODE%TYPE,
	  start_date OKC_TERMS_TEMPLATES_ALL.START_DATE%TYPE,
	  end_date OKC_TERMS_TEMPLATES_ALL.END_DATE%TYPE,
	  intent OKC_TERMS_TEMPLATES_ALL.INTENT%TYPE,
	  org_id OKC_TERMS_TEMPLATES_ALL.ORG_ID%TYPE,
	  tmpl_numbering_scheme OKC_TERMS_TEMPLATES_ALL.TMPL_NUMBERING_SCHEME%TYPE);

l_tmpl_type_rec l_tmpl_type;

CURSOR l_tmpl_id_validate_csr IS
SELECT template_id,
       template_name,
       status_code,
	  start_date,
	  end_date,
	  intent,
	  org_id,
	  tmpl_numbering_scheme
FROM
  OKC_TERMS_TEMPLATES_ALL TMP
WHERE
  TMP.template_id = p_contract_tmpl_id;

CURSOR l_tmpl_name_validate_csr(l_org_id IN NUMBER) IS
SELECT template_id,
       template_name,
       status_code,
	  start_date,
	  end_date,
	  intent,
	  org_id,
	  tmpl_numbering_scheme
FROM
  OKC_TERMS_TEMPLATES_ALL TMP
WHERE TMP.template_name = p_contract_tmpl_name
AND   TMP.org_id = l_org_id;

CURSOR l_tmpl_doc_exist_csr IS
SELECT 1
FROM
  OKC_TEMPLATE_USAGES
WHERE   document_type = p_document_type
AND     document_id   = p_document_id;

CURSOR l_mlp_tmpl_doc_exist_csr IS
SELECT template_id
FROM
  OKC_TEMPLATE_USAGES
WHERE   document_type = p_document_type
AND     document_id   = p_document_id
UNION ALL
SELECT template_id
FROM
  OKC_MLP_TEMPLATE_USAGES
WHERE   document_type = p_document_type
AND     document_id   = p_document_id;


CURSOR l_alwd_usgs_csr(l_template_id IN NUMBER) IS
SELECT 1
FROM
  OKC_ALLOWED_TMPL_USAGES
WHERE   document_type = p_document_type
AND     template_id   = l_template_id;

CURSOR c_get_intent_csr IS
  SELECT intent FROM okc_bus_doc_types_b
  WHERE document_type = p_document_type;

CURSOR c_get_user_id_csr(p_user_name IN VARCHAR2) IS
  SELECT user_id FROM fnd_user WHERE user_name LIKE p_user_name;

 CURSOR c_get_person_id(p_person_name IN VARCHAR2) IS
  SELECT person_id FROM PER_ALL_PEOPLE_F
  WHERE full_name = p_person_name;



BEGIN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.Create_Contract_Terms');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_source : '||p_contract_source);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_tmpl_id : '||p_contract_tmpl_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_contract_tmpl_name : '||p_contract_tmpl_name);

  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT G_CREATE_CONTRACT_TERMS_GRP;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;

  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

  -- Check that Contract source is Structured or Attached
  IF p_contract_source not in ('STRUCTURED','ATTACHED') THEN
  -- invalid contract source
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_SOURCE',
				        p_token1       => 'P_CONTRACT_SOURCE',
				        p_token1_value => p_contract_source);
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_contract_source ='STRUCTURED' THEN
     IF p_contract_tmpl_name is NULL AND p_contract_tmpl_id is NULL THEN
	-- no template is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_NO_TMPL_PROVIDED');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
	END IF;

  END IF;

  IF p_contract_source ='STRUCTURED' THEN
  IF p_contract_tmpl_id is not NULL THEN
     OPEN l_tmpl_id_validate_csr;
	   FETCH l_tmpl_id_validate_csr INTO l_tmpl_type_rec ;
     IF l_tmpl_id_validate_csr%NOTFOUND THEN
      --Invalid Template ID
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_TMPL_ID',
				        p_token1       => 'P_TMPL_ID',
				        p_token1_value => p_contract_tmpl_id);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_tmpl_id_validate_csr;

  ELSE
     OPEN l_tmpl_name_validate_csr(G_CURRENT_ORG_ID);
	   FETCH l_tmpl_name_validate_csr INTO l_tmpl_type_rec ;
     IF l_tmpl_name_validate_csr%NOTFOUND THEN
      --Invalid Template Name
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INVALID_TMPL_NAME',
				        p_token1       => 'P_TMPL_NAME',
				        p_token1_value => p_contract_tmpl_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_tmpl_name_validate_csr;

  END IF;


  OPEN c_get_intent_csr;
   FETCH c_get_intent_csr INTO l_doc_intent;
   CLOSE c_get_intent_csr;

   IF l_doc_intent <>  l_tmpl_type_rec.intent THEN

    Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_TMPL_INTENT',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name,
				        p_token2       => 'P_TEMPLATE_INTENT',
				        p_token2_value => l_tmpl_type_rec.intent,
				        p_token3       => 'P_DOC_INTENT',
				        p_token3_value => l_doc_intent);

      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF l_tmpl_type_rec.status_code <> 'APPROVED' THEN
      --Invalid Template Status
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_TMPL_STS',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF SYSDATE NOT BETWEEN l_tmpl_type_rec.start_date AND nvl(l_tmpl_type_rec.end_date,SYSDATE) THEN
      --Template is not Active
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INACTIVE_TMPL',
				        p_token1       => 'P_TEMPLATE_NAME',
				        p_token1_value => l_tmpl_type_rec.template_name);
      x_return_status := G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

  OPEN l_alwd_usgs_csr(l_tmpl_type_rec.template_id);
  FETCH l_alwd_usgs_csr INTO l_dummy ;
  IF l_alwd_usgs_csr%NOTFOUND THEN
   --Template is not assigned to Document
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_TMPL_USG_ASSOC',
					   p_token1       => 'P_CONTRACT_TEMPLATE',
					   p_token1_value => l_tmpl_type_rec.template_id,
				        p_token2       => 'P_DOCUMENT_TYPE',
				        p_token2_value => p_document_type);
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_alwd_usgs_csr;

  END IF; -- IF p_contract_source ='STRUCTURED' THEN

  OPEN l_tmpl_doc_exist_csr;
  FETCH l_tmpl_doc_exist_csr INTO l_dummy ;
  IF l_tmpl_doc_exist_csr%FOUND AND p_primary_template = 'Y' THEN
   --Document already has a primary Template
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_EXIST');
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_tmpl_doc_exist_csr;

   OPEN l_mlp_tmpl_doc_exist_csr;
   FETCH l_mlp_tmpl_doc_exist_csr INTO l_dummy_n;
   IF l_mlp_tmpl_doc_exist_csr%FOUND AND l_dummy = l_tmpl_type_rec.template_id THEN
   --Document already has this Template applied
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_EXIST');
   x_return_status := G_RET_STS_ERROR;
   RAISE FND_API.G_EXC_ERROR ;
   END IF;
   CLOSE l_mlp_tmpl_doc_exist_csr;


   --Fetch legal contact id from legal contact name
  IF p_legal_contact_name IS NOT NULL THEN
    OPEN c_get_user_id_csr(p_legal_contact_name);
    FETCH c_get_user_id_csr INTO l_legal_contact_id;
    CLOSE c_get_user_id_csr;
  END IF;

   --Fetch contract_admin_id from p_contract_admin_name
  IF p_contract_admin_name IS NOT NULL THEN
   OPEN c_get_user_id_csr(p_contract_admin_name);
   FETCH c_get_user_id_csr INTO l_contract_admin_id;
   CLOSE c_get_user_id_csr;
  END IF;

   --Fetch locked_by_user_id from p_locked_by_user_name
   IF p_locked_by_user_name IS NOT NULL THEN
    OPEN c_get_user_id_csr(p_locked_by_user_name);
    FETCH c_get_user_id_csr INTO l_locked_by_user_id;
    CLOSE c_get_user_id_csr;
   END IF;

   IF p_primary_template = 'Y' THEN

      OKC_TEMPLATE_USAGES_GRP.create_template_usages(
                                   p_api_version            => 1,
                                   p_init_msg_list          => p_init_msg_list,
                                   p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                                   p_commit                 => p_commit,
                                   x_return_status           => x_return_status,
                                   x_msg_data                => x_msg_data,
                                   x_msg_count               => x_msg_count,
                                   p_document_type          => p_document_type,
                                   p_document_id            => p_document_id,
                                   p_template_id            => l_tmpl_type_rec.template_id,
                                   p_doc_numbering_scheme   => l_tmpl_type_rec.tmpl_numbering_scheme,
                                   p_document_number        => g_document_number,
                                   p_article_effective_date => SYSDATE,
                                   p_config_header_id        => Null,
                                 p_config_revision_number  => Null,
                                 p_valid_config_yn         => Null,
                                   p_approval_abstract_text => p_approval_abstract_text,
                                   p_contract_source_code   => p_contract_source,
                                   p_authoring_party_code   => p_authoring_party_code,
							                     p_autogen_deviations_flag => p_autogen_deviations_flag,
                                   p_source_change_allowed_flag => 'Y',
                                   x_document_type          => l_document_type,
                                   x_document_id            => l_document_id,
							                     p_lock_terms_flag         => p_lock_terms_flag,
							                     p_enable_reporting_flag   => p_enable_reporting_flag,
							                     p_contract_admin_id       => l_contract_admin_id,
							                     p_legal_contact_id        => l_legal_contact_id,
                                   p_locked_by_user_id       => l_locked_by_user_id
                                                    );

   ELSE

        okc_clm_pkg.insert_usages_row(p_document_type           => p_document_type,
                                      p_document_id             => p_document_id,
                                      p_template_id             => l_tmpl_type_rec.template_id,
                                      p_doc_numbering_scheme    => l_tmpl_type_rec.tmpl_numbering_scheme,
                                      p_document_number         => g_document_number,
                                      p_article_effective_date  => SYSDATE,
                                      p_config_header_id        => Null,
                                      p_config_revision_number  => Null,
                                      p_valid_config_yn         => Null,
                                      x_return_status           => x_return_status,
                                      x_msg_count               => x_msg_count,
                                      x_msg_data                => x_msg_data);


   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving create_template_usages: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
         IF l_tmpl_id_validate_csr%ISOPEN THEN
            CLOSE l_tmpl_id_validate_csr;
	    END IF;
         IF l_tmpl_name_validate_csr%ISOPEN THEN
            CLOSE l_tmpl_name_validate_csr;
	    END IF;
         IF l_alwd_usgs_csr%ISOPEN THEN
            CLOSE l_alwd_usgs_csr;
	    END IF;
         IF l_tmpl_doc_exist_csr%ISOPEN THEN
            CLOSE l_tmpl_doc_exist_csr;
	    END IF;

         ROLLBACK TO g_create_contract_terms_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving create_template_usages: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_create_contract_terms_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving create_template_usages because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_create_contract_terms_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END Create_template_usages;


 PROCEDURE get_event_details (
      p_event_id       IN              NUMBER,
      x_before_after   OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      SELECT before_after
        INTO x_before_after
        FROM okc_bus_doc_events_b
       WHERE bus_doc_event_id = p_event_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END get_event_details;

 FUNCTION getprintduedatemsgname (
      p_recurring_flag            IN   VARCHAR2,
      p_start_fixed_flag          IN   VARCHAR2,
      p_end_fixed_flag            IN   VARCHAR2,
      p_repeating_frequency_uom   IN   VARCHAR2,
      p_relative_st_date_uom      IN   VARCHAR2,
      p_relative_end_date_uom     IN   VARCHAR2,
      p_start_evt_before_after    IN   VARCHAR2,
      p_end_evt_before_after      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_print_due_dt_msg_name
      IS
         SELECT message_name
           FROM okc_del_messages
          WHERE 1 = 1
            AND recurring_flag = p_recurring_flag
            AND start_fixed_flag = p_start_fixed_flag
            AND end_fixed_flag = p_end_fixed_flag
            AND Nvl(repeating_frequency_uom,'a') = Nvl(p_repeating_frequency_uom, 'a')
            AND Nvl(relative_st_date_uom,'a') = Nvl(p_relative_st_date_uom ,'a')
            AND Nvl(relative_end_date_uom,'a') = Nvl(p_relative_end_date_uom,'a')
            AND Nvl(start_evt_before_after,'a') = Nvl(p_start_evt_before_after,'a')
            AND Nvl(end_evt_before_after,'a') = Nvl(p_end_evt_before_after,'a');

      l_msg_name   VARCHAR2 (60);
   BEGIN
      OPEN cur_print_due_dt_msg_name;

      FETCH cur_print_due_dt_msg_name
       INTO l_msg_name;

      CLOSE cur_print_due_dt_msg_name;

      RETURN l_msg_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END getprintduedatemsgname;

   -- Deliverable Helper procedures/functions
   FUNCTION getuomvalue (p_duration IN NUMBER, p_uom IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_duration IS NOT NULL AND p_duration > 1 AND 'MTH' = p_uom
      THEN
         RETURN 'MTHS';
      ELSE
         IF p_duration IS NOT NULL AND p_duration <= 1 AND 'MTH' = p_uom
         THEN
            RETURN 'MTH';
         END IF;
      END IF;

      IF p_duration IS NOT NULL AND p_duration > 1 AND 'WK' = p_uom
      THEN
         RETURN 'WKS';
      ELSE
         IF p_duration IS NOT NULL AND p_duration <= 1 AND 'WK' = p_uom
         THEN
            RETURN 'WK';
         END IF;
      END IF;

      IF p_duration IS NOT NULL AND p_duration > 1 AND 'DAY' = p_uom
      THEN
         RETURN 'DAYS';
      ELSE
         IF p_duration IS NOT NULL AND p_duration <= 1 AND 'DAY' = p_uom
         THEN
            RETURN 'DAY';
         END IF;
      END IF;

      RETURN p_uom;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END getuomvalue;

FUNCTION getdeldisplaysequence (p_deliverable_id IN NUMBER)
      RETURN NUMBER
   IS
      l_disp_sequence   NUMBER;
   BEGIN
      l_disp_sequence := REMAINDER (p_deliverable_id, 1000);

      IF l_disp_sequence < 0
      THEN
         RETURN l_disp_sequence + 1000;
      ELSE
         RETURN l_disp_sequence;
      END IF;
   END getdeldisplaysequence;

    FUNCTION isvalidcontact (p_contact_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR cur_val_contact
      IS
         SELECT 'Y'
           FROM per_all_people_f e
          WHERE e.current_employee_flag = 'Y'
            AND TRUNC (SYSDATE) BETWEEN NVL (e.effective_start_date,
                                             SYSDATE - 1
                                            )
                                    AND NVL (e.effective_end_date,
                                             SYSDATE + 1)
            AND person_id = p_contact_id;

      -- CWK contract worket
      CURSOR cur_val_contact2
      IS
         SELECT 'Y'
           FROM per_all_people_f e
          WHERE e.current_npw_flag = 'Y'
            AND TRUNC (SYSDATE) BETWEEN NVL (e.effective_start_date,
                                             SYSDATE - 1
                                            )
                                    AND NVL (e.effective_end_date,
                                             SYSDATE + 1)
            AND person_id = p_contact_id;

      l_valid_contact   VARCHAR2 (1) := 'N';
   BEGIN

      OPEN cur_val_contact;
      FETCH cur_val_contact
       INTO l_valid_contact;
        IF  cur_val_contact%FOUND THEN
            CLOSE cur_val_contact;
            RETURN 'Y';
        END IF;
        CLOSE  cur_val_contact;


         IF NVL (fnd_profile.VALUE ('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'
         THEN



            OPEN cur_val_contact;
            FETCH cur_val_contact
             INTO l_valid_contact;

            IF cur_val_contact%FOUND THEN
              CLOSE cur_val_contact;
              RETURN 'Y';
            END IF;

            CLOSE cur_val_contact;

         END IF;


      RETURN 'N';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidcontact;


   FUNCTION isvalidstendeventsmatch (
      p_st_event_id    IN   NUMBER,
      p_end_event_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_val_event
      IS
         SELECT 'Y'
           FROM okc_bus_doc_events_b start_event,
                okc_bus_doc_events_b end_event
          WHERE start_event.bus_doc_event_id = p_st_event_id  --start event id
            AND end_event.bus_doc_event_id = p_end_event_id     --end event id
            AND start_event.bus_doc_type = end_event.bus_doc_type
         UNION
         SELECT 'Y'
           FROM okc_bus_doc_events_b start_event,
                okc_bus_doc_events_b end_event,
                okc_bus_doc_types_b end_type
          WHERE start_event.bus_doc_event_id = p_st_event_id  --start event id
            AND end_event.bus_doc_event_id = p_end_event_id     --end event id
            AND end_type.document_type = end_event.bus_doc_type
            AND start_event.bus_doc_type = end_type.target_response_doc_type
         UNION
         SELECT 'Y'
           FROM okc_bus_doc_events_b start_event,
                okc_bus_doc_events_b end_event,
                okc_bus_doc_types_b start_type
          WHERE start_event.bus_doc_event_id = p_st_event_id  --start event id
            AND end_event.bus_doc_event_id = p_end_event_id     --end event id
            AND start_type.document_type = start_event.bus_doc_type
            AND end_event.bus_doc_type = start_type.target_response_doc_type;

      l_val_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_event;

      FETCH cur_val_event
       INTO l_val_flag;

      CLOSE cur_val_event;

      RETURN NVL (l_val_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidstendeventsmatch;

    FUNCTION isvalidlookup (p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_flag   VARCHAR2 (1);

      CURSOR cur_val_lookup (p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
   IS
      SELECT 'Y'
        FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND enabled_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, SYSDATE - 1)
                                 AND NVL (TRUNC (end_date_active),
                                          TRUNC (SYSDATE)
                                         );

   CURSOR cur_lookup_meaning (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
   IS
      SELECT 'Y', meaning
        FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND enabled_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, SYSDATE - 1)
                                 AND NVL (TRUNC (end_date_active),
                                          TRUNC (SYSDATE)
                                         );
   BEGIN
      OPEN cur_val_lookup (p_lookup_type, p_lookup_code);

      FETCH cur_val_lookup
       INTO l_flag;

      CLOSE cur_val_lookup;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidlookup;

   FUNCTION isvalidlookup (
      p_lookup_type   IN              VARCHAR2,
      p_lookup_code   IN              VARCHAR2,
      x_meaning       OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
      is

       CURSOR cur_val_lookup (p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
   IS
      SELECT 'Y'
        FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND enabled_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, SYSDATE - 1)
                                 AND NVL (TRUNC (end_date_active),
                                          TRUNC (SYSDATE)
                                         );

   CURSOR cur_lookup_meaning (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
   IS
      SELECT 'Y', meaning
        FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND enabled_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, SYSDATE - 1)
                                 AND NVL (TRUNC (end_date_active),
                                          TRUNC (SYSDATE)
                                         );

      l_flag   VARCHAR2 (1);
   --l_lookup_meaning VARCHAR2(80);
   BEGIN
      OPEN cur_lookup_meaning (p_lookup_type, p_lookup_code);

      FETCH cur_lookup_meaning
       INTO l_flag, x_meaning;

      CLOSE cur_lookup_meaning;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidlookup;

   FUNCTION isvalidstartbusdocevent (
      p_document_type      IN   VARCHAR2,
      p_deliverable_type   IN   VARCHAR2,
      p_bus_doc_event_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_val_event
      IS
         SELECT 'Y'
           FROM okc_bus_doc_events_v evts,
                okc_bus_doc_types_b doctypes,
                okc_del_bus_doc_combxns delcomb,
                okc_deliverable_types_b deltypes
          WHERE evts.bus_doc_event_id = p_bus_doc_event_id
            AND deltypes.deliverable_type_code = p_deliverable_type
            AND doctypes.document_type_class = delcomb.document_type_class
            AND deltypes.deliverable_type_code = delcomb.deliverable_type_code
            AND docTypes.document_type = p_document_type
            AND doctypes.document_type = evts.bus_doc_type
            AND (   evts.start_end_qualifier = 'BOTH'
                 OR evts.start_end_qualifier = 'START'
                )
            UNION
            SELECT 'Y'
           FROM okc_bus_doc_events_v evts,
                okc_bus_doc_types_b doctypes,
                okc_del_bus_doc_combxns delcomb,
                okc_deliverable_types_b deltypes
          WHERE evts.bus_doc_event_id = p_bus_doc_event_id
            AND deltypes.deliverable_type_code = p_deliverable_type
            AND doctypes.document_type_class = delcomb.document_type_class
            AND deltypes.deliverable_type_code = delcomb.deliverable_type_code
            AND docTypes.document_type = G_DOC_TYPE_REC.TARGET_RESPONSE_DOC_TYPE
            AND doctypes.document_type = evts.bus_doc_type
            AND (   evts.start_end_qualifier = 'BOTH'
                 OR evts.start_end_qualifier = 'START'
                )
            UNION
             SELECT 'Y'
           FROM okc_bus_doc_events_v evts,
                okc_bus_doc_types_b doctypes,
                okc_del_bus_doc_combxns delcomb,
                okc_deliverable_types_b deltypes
          WHERE 1=1
            AND evts.bus_doc_event_id = p_bus_doc_event_id
            AND deltypes.deliverable_type_code = p_deliverable_type
            AND doctypes.document_type_class = delcomb.document_type_class
            AND deltypes.deliverable_type_code = delcomb.deliverable_type_code
            AND doctypes.document_type = G_TARGET_DOC_TYPE
            AND doctypes.document_type = evts.bus_doc_type
            AND (   evts.start_end_qualifier = 'BOTH'
                 OR evts.start_end_qualifier = 'START')

               ;

      l_valid_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_event;

      FETCH cur_val_event
       INTO l_valid_flag;

      CLOSE cur_val_event;

      RETURN NVL (l_valid_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidstartbusdocevent;

   FUNCTION isvalidendbusdocevent (
      p_document_type      IN   VARCHAR2,
      p_deliverable_type   IN   VARCHAR2,
      p_bus_doc_event_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS

      -- Validation should be similar to DeliverableEndEventListExpVO.xml
      -- Mimicking the UI Validation

      CURSOR cur_val_event
      IS
select 'Y'
from okc_bus_doc_events_v evts, okc_bus_doc_types_b docTypes,
okc_del_bus_doc_combxns delComb,
okc_deliverable_types_b delTypes
WHERE evts.bus_doc_event_id = p_bus_doc_event_id
AND delTypes.deliverable_type_code = p_deliverable_type
AND   docTypes.document_type_class = delComb.document_type_class
AND   delTypes.deliverable_type_code = delComb.deliverable_type_code
AND   docTypes.document_type = p_document_type
AND   docTypes.document_type = evts.bus_doc_type
AND   (evts.start_end_qualifier = 'BOTH' or evts.start_end_qualifier = 'END')

UNION

select 'Y'
from okc_bus_doc_events_v evts, okc_bus_doc_types_b docTypes,
okc_del_bus_doc_combxns delComb,
okc_deliverable_types_b delTypes
WHERE evts.bus_doc_event_id = p_bus_doc_event_id
AND delTypes.deliverable_type_code = p_deliverable_type --- :selectedDeliverableType
AND   docTypes.document_type_class = delComb.document_type_class
AND   delTypes.deliverable_type_code = delComb.deliverable_type_code
AND   docTypes.document_type = G_TARGET_DOC_TYPE  --- :targetDocumentType
AND   docTypes.document_type = evts.bus_doc_type
AND   (evts.start_end_qualifier = 'BOTH' or evts.start_end_qualifier = 'END')

UNION

select 'Y'
from okc_bus_doc_events_v evts, okc_bus_doc_types_b docTypes,
okc_del_bus_doc_combxns delComb,
okc_deliverable_types_b delTypes
WHERE evts.bus_doc_event_id = p_bus_doc_event_id
AND delTypes.deliverable_type_code = p_deliverable_type --- :selectedDeliverableType
AND   docTypes.document_type_class = delComb.document_type_class
AND   delTypes.deliverable_type_code = delComb.deliverable_type_code
AND   docTypes.document_type = G_DOC_TYPE_REC.TARGET_RESPONSE_DOC_TYPE --- :targetResponseDocumentType
AND   docTypes.document_type = evts.bus_doc_type
AND   (evts.start_end_qualifier = 'BOTH' or evts.start_end_qualifier = 'END')

UNION

select 'Y'
from okc_bus_doc_events_v evts,
okc_bus_doc_types_b doc_types,
okc_del_bus_doc_combxns delComb,
okc_deliverable_types_b del_types

WHERE
evts.bus_doc_event_id =  p_bus_doc_event_id   --:start event id
and start_end_qualifier = 'START'
and doc_types.document_type = evts.bus_doc_type
and del_types.deliverable_type_code = p_deliverable_type --:deliverable type
AND   doc_types.document_type_class = delComb.document_type_class
AND   del_types.deliverable_type_code = delComb.deliverable_type_code

UNION

select 'Y'
FROM  okc_bus_doc_events_v evts, okc_bus_doc_types_b docTypes,
okc_del_bus_doc_combxns delComb,
okc_deliverable_types_b delTypes
WHERE evts.bus_doc_event_id = p_bus_doc_event_id
AND delTypes.deliverable_type_code = p_deliverable_type --- :selectedDeliverableType
AND   docTypes.document_type_class = delComb.document_type_class
AND   delTypes.deliverable_type_code = delComb.deliverable_type_code
AND   docTypes.TARGET_RESPONSE_doc_type = p_document_type --- :currentDocumentType
AND   docTypes.document_type = evts.bus_doc_type
AND   (evts.start_end_qualifier = 'BOTH' or evts.start_end_qualifier = 'END')

               ;

      l_valid_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_event;

      FETCH cur_val_event
       INTO l_valid_flag;

      CLOSE cur_val_event;

      RETURN NVL (l_valid_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidendbusdocevent;

PROCEDURE validate_deliverables(p_deliverable_rec   IN OUT NOCOPY   deliverable_rec_type
)
   IS

         l_fixedstartdateyn   VARCHAR2 (30);
         l_starteventcode     VARCHAR2 (240);
         l_startba            VARCHAR2 (240);
         l_endeventcode       VARCHAR2 (240);
         l_endba              VARCHAR2 (240);
         l_continue           VARCHAR2 (1);
         l_startduration      NUMBER;
         l_endduration        NUMBER;
         l_uom                VARCHAR2 (120);
         l_column_name        VARCHAR2 (240);

         l_intent VARCHAR2(1);
         l_bus_doc_class VARCHAR2(240);

         CURSOR cur_val_bus_doc (p_doc_type VARCHAR2)
         IS
         SELECT   DOCUMENT_TYPE_CLASS, intent
         FROM OKC_BUS_DOC_TYPES_B
         WHERE  document_type = p_doc_type;

         CURSOR cur_val_del_type (p_del_type VARCHAR2)
         IS
         SELECT 'Y' FROM okc_deliverable_types_b
         WHERE deliverable_type_code =  p_del_type;

         CURSOR cur_val_resp_party (p_intent VARCHAR2,p_bus_doc_class VARCHAR2)
         IS
         SELECT 'Y'
           FROM  okc_resp_parties_b
           WHERE intent =  p_intent
           AND document_type_class = p_bus_doc_class;

         CURSOR cur_val_internal_party (p_party_id NUMBER)
         IS
         SELECT 'Y' FROM
         hr_all_organization_units
         WHERE  organization_id = p_party_id;

         CURSOR  cur_val_ext_party_contact_id (p_party_contact_id number)
         IS
         SELECT 'Y' FROM hz_parties WHERE party_id = p_party_contact_id;

         l_val_flag VARCHAR2(1);

         l_party_name VARCHAR2(240);

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

   BEGIN

       -- Validate business document type.
       OPEN  cur_val_bus_doc (p_deliverable_rec.BUSINESS_DOCUMENT_TYPE);
       FETCH cur_val_bus_doc INTO l_bus_doc_class,l_intent;
       IF  cur_val_bus_doc%NOTFOUND THEN
       CLOSE cur_val_bus_doc;
          okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'BUSINESS_DOCUMENT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
       END IF;
       CLOSE cur_val_bus_doc;

       -- Validate Deliverable Type
       -- As of now validating the deliverable type
       -- Not validating the deliverable type and document type combination.
       -- In future we should add this check also.
       OPEN  cur_val_del_type (p_deliverable_rec.DELIVERABLE_TYPE);
       FETCH cur_val_del_type INTO l_val_flag;
       IF  cur_val_del_type%NOTFOUND THEN
       CLOSE cur_val_del_type;
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DELIVERABLE_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
       END IF;
       CLOSE cur_val_del_type;

       -- Validate the responsible_party type
       OPEN cur_val_resp_party(l_intent,l_bus_doc_class);
       FETCH cur_val_resp_party INTO l_val_flag;
        IF cur_val_resp_party%NOTFOUND THEN
              CLOSE cur_val_resp_party;
              okc_api.set_message (p_app_name        => g_app_name,
                                   p_msg_name          => 'OKC_I_INVALID_VALUE',
                                   p_token1            => 'FIELD',
                                   p_token1_value      => 'RESPONSIBLE_PARTY'
                                  );
               RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE cur_val_resp_party;


         /*IF (   (    p_deliverable_rec.deliverable_type = 'CONTRACTUAL'
                     AND p_deliverable_rec.responsible_party NOT IN
                                                ('SUPPLIER_ORG', 'BUYER_ORG', 'INTERNAL_ORG')
                )
             OR (    p_deliverable_rec.deliverable_type IN
                                          ('INTERNAL_PURCHASING', 'SOURCING')
                 AND p_deliverable_rec.responsible_party <> 'BUYER_ORG'
                )
             OR (p_deliverable_rec.deliverable_type = 'INTERNAL'
                AND p_deliverable_rec.responsible_party <> 'INTERNAL_ORG'
                )

            )
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'RESPONSIBLE_PARTY'
                                );
            RAISE fnd_api.g_exc_error;
         END IF; */

         -- Validate Internal Party ID
         IF p_deliverable_rec.internal_party_id IS NULL THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'INTERNAL_PARTY_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Validate Internal Party ID
         OPEN  cur_val_internal_party(p_deliverable_rec.internal_party_id);
         FETCH cur_val_internal_party INTO l_val_flag;
         IF  cur_val_internal_party%NOTFOUND THEN
         CLOSE cur_val_internal_party;
          okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'INTERNAL_PARTY_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
         CLOSE cur_val_internal_party;


         IF p_deliverable_rec.INTERNAL_PARTY_CONTACT_ID IS NULL THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'INTERNAL_PARTY_CONTACT_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;


         IF     p_deliverable_rec.internal_party_contact_id IS NOT NULL
            AND isvalidcontact (p_deliverable_rec.internal_party_contact_id) <>
                                                                           'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'INTERNAL_PARTY_CONTACT_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;



          IF     p_deliverable_rec.external_party_contact_id IS NOT NULL
         THEN
                  OPEN  cur_val_ext_party_contact_id(p_deliverable_rec.external_party_contact_id);
                  FETCH cur_val_ext_party_contact_id INTO l_val_flag;

                  IF  cur_val_ext_party_contact_id%NOTFOUND THEN
                      CLOSE cur_val_ext_party_contact_id;
                          okc_api.set_message (p_app_name          => g_app_name,
                                           p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'EXTERNAL_PARTY_CONTACT_ID'
                                );
                        RAISE fnd_api.g_exc_error;
                  END IF;
                  CLOSE cur_val_ext_party_contact_id;
         END IF;


         IF     p_deliverable_rec.requester_id IS NOT NULL
            AND isvalidcontact (p_deliverable_rec.requester_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'REQUESTER_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_deliverable_rec.deliverable_name IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DELIVERABLE_NAME'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- This is required for 11i to R12 Data migration.
         -- Refer bug 4228090
         IF p_deliverable_rec.external_party_id IS NOT NULL
         AND p_deliverable_rec.external_party_role IS NULL
         AND ((G_DOC_TYPE_REC.DOCUMENT_TYPE_CLASS = 'PO')
            OR (G_DOC_TYPE_REC.DOCUMENT_TYPE_CLASS = 'SOURCING' and G_DOC_TYPE_REC.target_response_doc_type is NULL) )
         THEN
              p_deliverable_rec.external_party_role := 'SUPPLIER_ORG';
         END IF;

            -- Validate the party role id:
            IF       p_deliverable_rec.external_party_id IS NOT NULL
                AND  p_deliverable_rec.external_party_role IS NOT NULL
                AND  okc_deliverable_process_pvt.get_party_name(p_deliverable_rec.external_party_id,p_deliverable_rec.external_party_role) IS NULL
             THEN

                    okc_api.set_message (p_app_name  => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'EXTERNAL_PARTY_ID'
                                );
                       RAISE fnd_api.g_exc_error;

            END IF;

       IF p_deliverable_rec.NOTIFY_ESCALATION_YN = 'Y'
         THEN
         BEGIN
          SELECT col_name INTO l_column_name from
            (SELECT  'NOTIFY_ESCALATION_VALUE' col_name FROM dual WHERE p_deliverable_rec.NOTIFY_ESCALATION_VALUE IS NULL
             UNION
            SELECT  'NOTIFY_ESCALATION_UOM' col_name FROM dual WHERE   p_deliverable_rec.NOTIFY_ESCALATION_UOM IS NULL
            UNION
            SELECT   'ESCALATION_ASSIGNEE'  col_name FROM dual WHERE   p_deliverable_rec.ESCALATION_ASSIGNEE IS NULL);
              okc_api.set_message (p_app_name  => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => l_column_name
                                );
                       RAISE fnd_api.g_exc_error;

          EXCEPTION
           WHEN No_Data_Found THEN
            NULL;
          END;
       END IF;

       IF p_deliverable_rec.NOTIFY_PRIOR_DUE_DATE_YN = 'Y'
         THEN
         BEGIN
          SELECT col_name INTO l_column_name from
            (SELECT  'NOTIFY_PRIOR_DUE_DATE_UOM' col_name FROM dual WHERE p_deliverable_rec.NOTIFY_PRIOR_DUE_DATE_UOM IS NULL
               UNION
             SELECT  'NOTIFY_PRIOR_DUE_DATE_VALUE' col_name FROM dual WHERE   p_deliverable_rec.NOTIFY_PRIOR_DUE_DATE_VALUE IS NULL
             );
              okc_api.set_message (p_app_name  => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => l_column_name
                                );
                       RAISE fnd_api.g_exc_error;

          EXCEPTION
           WHEN No_Data_Found THEN
            NULL;
          END;
       END IF;


         IF p_deliverable_rec.escalation_assignee IS NOT NULL
         THEN
            IF isvalidcontact (p_deliverable_rec.escalation_assignee) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_VALUE',
                                    p_token1            => 'FIELD',
                                    p_token1_value      => 'ESCALATION_ASSIGNEE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;


          /* Need to add validation for UOM
         */
         IF     p_deliverable_rec.notify_prior_due_date_uom IS NOT NULL
            AND p_deliverable_rec.notify_prior_due_date_uom NOT IN
                                                         ('MTH', 'DAY', 'WK')
         THEN
            okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'NOTIFY_PRIOR_DUE_DATE_UOM'
                               );
         END IF;

         IF     p_deliverable_rec.notify_escalation_uom IS NOT NULL
            AND p_deliverable_rec.notify_escalation_uom NOT IN
                                                         ('MTH', 'DAY', 'WK')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'NOTIFY_ESCALATION_UOM'
                                );
         END IF;

         IF     p_deliverable_rec.relative_st_date_uom IS NOT NULL
            AND p_deliverable_rec.relative_st_date_uom NOT IN
                                                         ('MTH', 'DAY', 'WK')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'RELATIVE_ST_DATE_UOM'
                                );
         END IF;

         IF     p_deliverable_rec.relative_end_date_uom IS NOT NULL
            AND p_deliverable_rec.relative_end_date_uom NOT IN
                                                         ('MTH', 'DAY', 'WK')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'RELATIVE_END_DATE_UOM'
                                );
         END IF;

         IF     p_deliverable_rec.repeating_frequency_uom IS NOT NULL
            AND isvalidlookup ('OKC_DEL_REPEAT_FREQ',
                               p_deliverable_rec.repeating_frequency_uom
                              ) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'REPEATING_FREQUENCY_UOM'
                                );
         END IF;

         IF     p_deliverable_rec.pay_hold_prior_due_date_uom IS NOT NULL
            AND p_deliverable_rec.pay_hold_prior_due_date_uom NOT IN
                                                         ('MTH', 'DAY', 'WK')
         THEN
            okc_api.set_message
                             (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'PAY_HOLD_PRIOR_DUE_DATE_UOM'
                             );
         END IF;

         -- CASE : 1 One Time deliverable and Fixed Due date, then fixed_due_date _yn will be 'Y'.
         IF  p_deliverable_rec.fixed_due_date_yn = 'Y' THEN
             --  PRINT_DUE_DATE_MSG_NAME is null in this case
             p_deliverable_rec.PRINT_DUE_DATE_MSG_NAME := NULL;

              -- Fixed start date is required for this kind of deliverable.
              IF p_deliverable_rec.fixed_start_date IS NULL THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'FIXED_START_DATE'
                               );
                   RAISE fnd_api.g_exc_error;
             END IF;



             BEGIN

              SELECT column_name
              INTO l_column_name
              FROM (SELECT 'RECURRING_YN' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.recurring_yn = 'Y'
                    UNION
                    SELECT 'RELATIVE_ST_DATE_DURATION' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_st_date_duration IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_ST_DATE_UOM' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_st_date_uom IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_ST_DATE_EVENT_ID' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_st_date_event_id IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_END_DATE_DURATION' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_end_date_duration IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_END_DATE_UOM' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_end_date_uom IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_END_DATE_EVENT_ID' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_end_date_event_id IS NOT NULL
                    UNION
                    SELECT 'REPEATING_DAY_OF_MONTH' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_day_of_month IS NOT NULL
                    UNION
                    SELECT 'REPEATING_DAY_OF_WEEK' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_day_of_week IS NOT NULL
                    UNION
                    SELECT 'REPEATING_FREQUENCY_UOM' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_frequency_uom IS NOT NULL
                    UNION
                    SELECT 'REPEATING_DURATION' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_duration IS NOT NULL
                    UNION
                    SELECT 'FIXED_END_DATE' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.fixed_end_date IS NOT NULL)
          WHERE ROWNUM = 1;

                okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => l_column_name
                               );

                okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );



                RAISE fnd_api.g_exc_error;


             EXCEPTION
             WHEN No_Data_Found THEN
              NULL;
             END;
         END IF;

         -- CASE : 2 : One time deliverable but it is event based (Relative)
         -- In this case  fixed_due_date_yn and RECURRING_YN both will be 'N'.
         IF p_deliverable_rec.fixed_due_date_yn = 'N'
         AND p_deliverable_rec.RECURRING_YN  = 'N'
         THEN
            IF p_deliverable_rec.relative_st_date_event_id IS NULL
            THEN
               okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_EVENT_ID'
                               );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_deliverable_rec.relative_st_date_duration IS NULL
            THEN
               okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_DURATION'
                               );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_deliverable_rec.relative_st_date_uom IS NULL
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_NOT_NULL',
                                    p_token1            => 'FIELD',
                                    p_token1_value      => 'RELATIVE_ST_DATE_UOM'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;



               IF isvalidstartbusdocevent
                     (p_document_type         => p_deliverable_rec.business_document_type,
                      p_deliverable_type      => p_deliverable_rec.deliverable_type,
                      p_bus_doc_event_id      => p_deliverable_rec.relative_st_date_event_id
                     ) <> 'Y'
               THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_EVENT_ID'
                               );
                  RAISE fnd_api.g_exc_error;
               END IF;


           BEGIN
            SELECT column_name
            INTO l_column_name
  FROM (SELECT 'RELATIVE_END_DATE_DURATION' column_name
          FROM DUAL
         WHERE p_deliverable_rec.relative_end_date_duration IS NOT NULL
        UNION
        SELECT 'RELATIVE_END_DATE_UOM'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.relative_end_date_uom IS NOT NULL
        UNION
        SELECT 'RELATIVE_END_DATE_EVENT_ID' column_name
          FROM DUAL
         WHERE p_deliverable_rec.relative_end_date_event_id IS NOT NULL
        UNION
        SELECT 'REPEATING_DAY_OF_MONTH'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_day_of_month IS NOT NULL
        UNION
        SELECT 'REPEATING_DAY_OF_WEEK'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_day_of_week IS NOT NULL
        UNION
        SELECT 'REPEATING_FREQUENCY_UOM' column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_frequency_uom IS NOT NULL
        UNION
        SELECT 'REPEATING_DURATION'     column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_duration IS NOT NULL
        UNION
        SELECT 'FIXED_END_DATE'   column_name
          FROM DUAL
         WHERE p_deliverable_rec.fixed_end_date IS NOT NULL
        UNION
        SELECT 'FIXED_START_DATE'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.fixed_start_date IS NOT NULL)
       WHERE ROWNUM = 1;

                okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );

                okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => l_column_name
                               );

                RAISE fnd_api.g_exc_error;
         EXCEPTION
          WHEN No_Data_Found THEN
           NULL;
          END;
         END IF;  -- IF p_deliverable_rec.fixed_due_date_yn = 'N' AND p_deliverable_rec.RECURRING_YN  = 'N'


         -- CASE 3 : Repeating deliverable and non-event based deliverable.
                    -- Here the following four sub-cases can exist:
                        -- 3.a Both Start and end dates are fixed.
                        -- 3.b Start date is fixed but end date is event based/relative
                        -- 3.c Start date is event based(Relative) and end date is fixed.
                        -- 3.d Both Start date and end dates are event based(Relative).

         IF p_deliverable_rec.RECURRING_YN = 'Y'
         THEN
            -- In all 3.a..3.d cases Repeating information can not be null.
            BEGIN
            select column_name  INTO l_column_name from
                (
                select 'REPEATING_DURATION' column_name   from dual where p_deliverable_rec.REPEATING_DURATION is null
                union
                select 'REPEATING_FREQUENCY_UOM' column_name  from dual where p_deliverable_rec.REPEATING_FREQUENCY_UOM is null
                union
                select 'REPEATING_DAY_OF_WEEK' column_name  from dual where p_deliverable_rec.REPEATING_FREQUENCY_UOM  = 'WK' and  p_deliverable_rec.REPEATING_DAY_OF_WEEK is null
                union
                select 'REPEATING_DAY_OF_MONTH' column_name  from dual where p_deliverable_rec.REPEATING_FREQUENCY_UOM  = 'MTH' and  p_deliverable_rec.REPEATING_DAY_OF_MONTH is null
                )
              where rownum =1;

                     okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => l_column_name
                               );
                     okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );


                   RAISE fnd_api.g_exc_error;
            EXCEPTION
            WHEN No_Data_Found THEN NULL;
            END;


            -- If we check for following thnings then we will cover all of 3.a to 3.d cases
            -- Either Fixed Start date must exist or Start Event info must exist.
            -- Either Fixed end date must exist or End Event info must exist.
            IF  p_deliverable_rec.fixed_start_date IS NULL
            AND p_deliverable_rec.relative_st_date_event_id IS NULL
            THEN
                    okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );
                     okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'FIXED_START_DATE'
                               );
                   RAISE fnd_api.g_exc_error;
            END IF;

            IF  p_deliverable_rec.fixed_end_date IS NULL
            AND p_deliverable_rec.relative_end_date_event_id IS NULL
            THEN
                    okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );
                     okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'FIXED_END_DATE'
                               );
                   RAISE fnd_api.g_exc_error;
            END IF;

           -- When Fixed Start date is entered, then Relative St event information must not be entered.
           IF p_deliverable_rec.fixed_start_date IS NOT NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_ST_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_DURATION IS NOT NULL
                  union
                  select  'RELATIVE_ST_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_UOM is not null
                  union
                  select 'RELATIVE_ST_DATE_EVENT_ID'  column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_EVENT_ID is not null
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_INVALID_VALUE',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;
           END IF;

           -- When Relative st event is entered, then verify if the min info required for this is entered.
           IF p_deliverable_rec.RELATIVE_ST_DATE_EVENT_ID is not NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_ST_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_DURATION IS  NULL
                  union
                  select  'RELATIVE_ST_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_UOM is NULL
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_NOT_NULL',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;

           END IF;

           -- When Fixed end date is entered, then Relative End event information must not be entered.
           IF p_deliverable_rec.fixed_end_date IS NOT NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_END_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_DURATION IS NOT NULL
                  union
                  select  'RELATIVE_END_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_UOM is not null
                  union
                  select 'RELATIVE_END_DATE_EVENT_ID'  column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_EVENT_ID is not null
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_INVALID_VALUE',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;
           END IF;

           -- When Relative End event is entered, then verify if the min info required for this is entered.
           IF p_deliverable_rec.RELATIVE_END_DATE_EVENT_ID is not NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_END_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_DURATION IS  NULL
                  union
                  select  'RELATIVE_END_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_UOM is NULL
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_NOT_NULL',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;

           END IF;

            IF ( p_deliverable_rec.relative_st_date_duration < 0
                 OR (InStr
                        (
                         To_Char(p_deliverable_rec.relative_st_date_duration)
                         ,'.'
                        )
                         <>0
                     )
               )
            THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NEG_REL_ST_DUR_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );

               RAISE fnd_api.g_exc_error;
            END IF;


            IF p_deliverable_rec.relative_st_date_event_id IS NOT NULL
            THEN
               IF isvalidstartbusdocevent
                     (p_document_type         => p_deliverable_rec.business_document_type,
                      p_deliverable_type      => p_deliverable_rec.deliverable_type,
                      p_bus_doc_event_id      => p_deliverable_rec.relative_st_date_event_id
                     ) <> 'Y'
               THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_EVENT_ID'
                               );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

           IF p_deliverable_rec.relative_end_date_event_id IS NOT NULL
            THEN
               IF isvalidendbusdocevent
                     (p_document_type         => p_deliverable_rec.business_document_type,
                      p_deliverable_type      => p_deliverable_rec.deliverable_type,
                      p_bus_doc_event_id      => p_deliverable_rec.relative_end_date_event_id
                     ) <> 'Y'
               THEN
                  okc_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKC_I_INVALID_VALUE',
                               p_token1            => 'FIELD',
                               p_token1_value      => 'RELATIVE_END_DATE_EVENT_ID'
                              );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

           IF p_deliverable_rec.relative_st_date_event_id IS NOT NULL AND
              p_deliverable_rec.relative_end_date_event_id IS NOT NULL
              AND  isvalidstendeventsmatch
                                (p_deliverable_rec.relative_st_date_event_id,
                                 p_deliverable_rec.relative_end_date_event_id
                                ) <> 'Y'
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_INVLD_EVENT_DOCTYPE_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);
             /*  okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INVLD_EVENT_DOCTYPE_UI'
                              );*/
               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );

               RAISE fnd_api.g_exc_error;
            END IF;

           IF (p_deliverable_rec.fixed_start_date IS NOT NULL AND
            p_deliverable_rec.fixed_end_date IS NOT NULL AND
            (p_deliverable_rec.fixed_start_date >
                                                p_deliverable_rec.fixed_end_date))
            THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);

              /* okc_api.set_message
                             (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'OKC_DEL_END_BEFORE_START_UI'
                             );*/
               okc_api.set_message
                             (p_app_name          => g_app_name,
                              p_msg_name          => l_resolved_msg_name
                             );

               RAISE fnd_api.g_exc_error;
            END IF;

             IF ( p_deliverable_rec.repeating_duration < 0
                OR  (InStr(To_Char(p_deliverable_rec.repeating_duration),'.')<>0)
               )
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NEG_REPEAT_WEEK_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );


               RAISE fnd_api.g_exc_error;
             END IF;
          IF  p_deliverable_rec.repeating_frequency_uom = 'WK'
         THEN



            IF isvalidlookup
                  (p_lookup_type      => 'DAY_OF_WEEK',
                   p_lookup_code      => TO_CHAR
                                            (p_deliverable_rec.repeating_day_of_week
                                            )
                  ) <> 'Y'
            THEN
               okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_INVALID_DAY_OF_WEEK'
                                 );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF     p_deliverable_rec.recurring_yn = 'Y'
            AND p_deliverable_rec.repeating_frequency_uom = 'MTH'
         THEN
            IF isvalidlookup
                  (p_lookup_type      => 'OKC_DAY_OF_MONTH',
                   p_lookup_code      => TO_CHAR
                                            (p_deliverable_rec.repeating_day_of_month
                                            )
                  ) <> 'Y'
            THEN
               okc_api.set_message
                                (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_DEL_INVALID_DAY_OF_MONTH'
                                );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;



         -- ALL 3 CASES Basic check is completed.
----------------------------------
        /*
           //if deliverable is recurring and the start event and the end event are the same
          //we should do the following checks:
          //(1) If both the dates are before the event then
          //Validation: Start duration > End duration
          //(e.g. 10 days should be greater than 1 week)
          //
          //(2) If Start date is before the event and End date is after the event then
          //Validation: No problem
          //
          //(3) If Start date is after the event and End date is before the event then
          //Validation: Error Start date should be before the End date
          //
          //(4) If both the dates are after the event then
          //Validation: Start duration < End duration
         */
         IF
             p_deliverable_rec.relative_st_date_event_id IS NOT NULL
            AND p_deliverable_rec.relative_end_date_event_id IS NOT NULL
            AND p_deliverable_rec.relative_st_date_duration IS NOT NULL
            AND p_deliverable_rec.relative_end_date_duration IS NOT NULL
            AND p_deliverable_rec.relative_st_date_uom IS NOT NULL
            AND p_deliverable_rec.relative_end_date_uom IS NOT NULL
         THEN
            BEGIN
               SELECT business_event_code, before_after, 'Y'
                 INTO l_starteventcode, l_startba, l_continue
                 FROM okc_bus_doc_events_b
                WHERE bus_doc_event_id =
                                   p_deliverable_rec.relative_st_date_event_id;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_continue := 'N';
            END;

            IF l_continue = 'Y'
            THEN
               BEGIN
                  SELECT business_event_code, before_after, 'Y'
                    INTO l_endeventcode, l_endba, l_continue
                    FROM okc_bus_doc_events_b
                   WHERE bus_doc_event_id =
                                  p_deliverable_rec.relative_end_date_event_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     l_continue := 'N';
               END;

               IF l_continue = 'Y'
               THEN
                  IF     l_starteventcode IS NOT NULL
                     AND l_starteventcode = l_endeventcode
                  THEN
                     /*
                      //if the getDays method cannot find a match, it will return -1
                     //so if startDuration or endDuration is less than 0, we know that we didn't find a match
                     //in this case we won't compare, because we can't
                     */
                     l_uom := p_deliverable_rec.relative_st_date_uom;
                     l_startduration :=
                          TO_NUMBER
                                 (p_deliverable_rec.relative_st_date_duration)
                        * (CASE l_uom
                              WHEN 'DAY'
                                 THEN 1
                              WHEN 'WK'
                                 THEN 7
                              WHEN 'MTH'
                                 THEN 30
                              ELSE -1
                           END
                          );
                     l_endduration :=
                          TO_NUMBER
                                 (p_deliverable_rec.relative_end_date_duration)
                        * (CASE p_deliverable_rec.relative_end_date_uom
                              WHEN 'DAY'
                                 THEN 1
                              WHEN 'WK'
                                 THEN 7
                              WHEN 'MTH'
                                 THEN 30
                              ELSE -1
                           END
                          );

                     IF l_startduration >= 0 AND l_endduration >= 0
                     THEN
                        -- Scenario 1
                        IF (    'B' = l_startba
                            AND 'B' = 'l_endBA'
                            AND (l_startduration < l_endduration)
                           )
                        THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

                  /*         okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_END_BEFORE_START_UI'
                                 );*/
                           okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => l_resolved_msg_name,
                                  p_token1        => 'DEL_TOKEN',
                                  p_token1_value  => l_resolved_token
                                 );

                           RAISE fnd_api.g_exc_error;
                        END IF;

                        -- Scenario 2 is always valid no need to check

                        -- Scenario 3
                        IF ('A' = l_startba AND 'B' = l_endba)
                        THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

                  /*         okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_END_BEFORE_START_UI'
                                 );*/
                           okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => l_resolved_msg_name,
                                  p_token1        => 'DEL_TOKEN',
                                  p_token1_value  => l_resolved_token
                                 );


                           RAISE fnd_api.g_exc_error;
                        END IF;

                        IF (    'A' = l_startba
                            AND 'A' = l_endba
                            AND l_startduration > l_endduration
                           )
                        THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

                  /*         okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_END_BEFORE_START_UI'
                                 );*/
                           okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => l_resolved_msg_name,
                                  p_token1        => 'DEL_TOKEN',
                                  p_token1_value  => l_resolved_token
                                 );


                           RAISE fnd_api.g_exc_error;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
  END IF; --IF p_deliverable_rec.RECURRING_YN = 'Y'







   END validate_deliverables;



PROCEDURE create_deliverables(p_api_version      IN  NUMBER,
                                 p_document_type         IN  VARCHAR2,
                                 p_document_id           IN  NUMBER,
                                 p_deliverable_rec       IN  deliverable_rec_type,
                                 p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                                 p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                                 x_return_status	          OUT  NOCOPY Varchar2,
                                 x_msg_data	               OUT  NOCOPY Varchar2,
                                 x_msg_count	          OUT  NOCOPY Number
                                 )
IS
l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'create_deliverables';

      l_start_date_fixed          VARCHAR2 (1);
      l_end_date_fixed            VARCHAR2 (1);
      l_start_evt_before_after    VARCHAR2 (1);
      l_end_evt_before_after      VARCHAR2 (1);
      l_repeating_frequency_uom   VARCHAR2 (30);
      l_relative_st_date_uom      VARCHAR2 (30);
      l_relative_end_date_uom     VARCHAR2 (30);

 CURSOR C_delTypeExists is
    SELECT 'X'
    FROM
    okc_bus_doc_types_b doctyp,
    okc_del_bus_doc_combxns deltypcomb
    WHERE
    doctyp.document_type_class = deltypcomb.document_type_class
    AND doctyp.document_type = p_document_type
    AND deltypcomb.deliverable_type_code = p_deliverable_rec.deliverable_type;

  C_delTypeExists_rec  C_delTypeExists%ROWTYPE;

  delRecTab  deliverable_rec_type;

   PROCEDURE default_row (
         p_deliverable_rec   IN OUT NOCOPY   deliverable_rec_type
      )
      IS
      BEGIN
         IF p_deliverable_rec.deliverable_id = okc_api.g_miss_num
         THEN
            SELECT okc_deliverable_id_s.NEXTVAL
              INTO p_deliverable_rec.deliverable_id
              FROM DUAL;
         END IF;

         IF p_deliverable_rec.business_document_type = okc_api.g_miss_char
         THEN
            p_deliverable_rec.business_document_type := 'TEMPLATE';
         END IF;

         IF p_deliverable_rec.business_document_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.business_document_id := NULL;
         END IF;

         IF p_deliverable_rec.business_document_number = okc_api.g_miss_char
         THEN
            p_deliverable_rec.business_document_number := NULL;
         END IF;

         IF p_deliverable_rec.deliverable_type = okc_api.g_miss_char
         THEN
            p_deliverable_rec.deliverable_type := NULL;
         END IF;

         IF p_deliverable_rec.responsible_party = okc_api.g_miss_char
         THEN
            p_deliverable_rec.responsible_party := NULL;
         END IF;

         -- Pre-11iCU2 -- Bug 4228090
         IF p_deliverable_rec.responsible_party = 'BUYER_ORG' THEN
              p_deliverable_rec.responsible_party  := 'INTERNAL_ORG';
         END IF;

         IF p_deliverable_rec.internal_party_contact_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.internal_party_contact_id := NULL;
         END IF;

         IF p_deliverable_rec.external_party_contact_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.external_party_contact_id := NULL;
         END IF;

         IF p_deliverable_rec.deliverable_name = okc_api.g_miss_char
         THEN
            p_deliverable_rec.deliverable_name := NULL;
         END IF;

         IF p_deliverable_rec.description = okc_api.g_miss_char
         THEN
            p_deliverable_rec.description := NULL;
         END IF;

         IF p_deliverable_rec.comments = okc_api.g_miss_char
         THEN
            p_deliverable_rec.comments := NULL;
         END IF;

         IF p_deliverable_rec.display_sequence = okc_api.g_miss_num
         THEN
            p_deliverable_rec.display_sequence :=
                     getdeldisplaysequence (p_deliverable_rec.deliverable_id);
         END IF;

         IF p_deliverable_rec.fixed_due_date_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.fixed_due_date_yn := 'Y';
         END IF;

         IF p_deliverable_rec.actual_due_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.actual_due_date := NULL;
         END IF;

         IF p_deliverable_rec.print_due_date_msg_name = okc_api.g_miss_char
         THEN
            p_deliverable_rec.print_due_date_msg_name := NULL;
         END IF;

         IF p_deliverable_rec.recurring_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.recurring_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_prior_due_date_value = okc_api.g_miss_num
         THEN
            p_deliverable_rec.notify_prior_due_date_value := NULL;
         END IF;

         IF p_deliverable_rec.notify_prior_due_date_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_prior_due_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.notify_prior_due_date_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_prior_due_date_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_completed_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_completed_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_overdue_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_overdue_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_escalation_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_escalation_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_escalation_value = okc_api.g_miss_num
         THEN
            p_deliverable_rec.notify_escalation_value := NULL;
         END IF;

         IF p_deliverable_rec.notify_escalation_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_escalation_uom := NULL;
         END IF;

         IF p_deliverable_rec.escalation_assignee = okc_api.g_miss_num
         THEN
            p_deliverable_rec.escalation_assignee := NULL;
         END IF;

         IF p_deliverable_rec.amendment_operation = okc_api.g_miss_char
         THEN
            p_deliverable_rec.amendment_operation := NULL;
         END IF;

         IF p_deliverable_rec.prior_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.prior_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.amendment_notes = okc_api.g_miss_char
         THEN
            p_deliverable_rec.amendment_notes := NULL;
         END IF;

         IF p_deliverable_rec.completed_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.completed_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.overdue_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.overdue_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.escalation_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.escalation_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.LANGUAGE = okc_api.g_miss_char
         THEN
            p_deliverable_rec.LANGUAGE := USERENV ('Lang');
         END IF;

         IF p_deliverable_rec.original_deliverable_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.original_deliverable_id :=
                                             p_deliverable_rec.deliverable_id;
         END IF;

         IF p_deliverable_rec.requester_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.requester_id := NULL;
         END IF;

         IF p_deliverable_rec.external_party_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.external_party_id := NULL;
         END IF;

         IF p_deliverable_rec.recurring_del_parent_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.recurring_del_parent_id := NULL;
         END IF;

         --IF p_deliverable_rec.business_document_version = okc_api.g_miss_num
         --THEN
            p_deliverable_rec.business_document_version := -99;
         --END IF;

         IF p_deliverable_rec.relative_st_date_duration = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_st_date_duration := NULL;
         END IF;

         IF p_deliverable_rec.relative_st_date_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.relative_st_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.relative_st_date_event_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_st_date_event_id := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_duration = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_end_date_duration := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.relative_end_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_event_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_end_date_event_id := NULL;
         END IF;

         IF p_deliverable_rec.repeating_day_of_month = okc_api.g_miss_char
         THEN
            p_deliverable_rec.repeating_day_of_month := NULL;
         END IF;

         IF p_deliverable_rec.repeating_day_of_week = okc_api.g_miss_char
         THEN
            p_deliverable_rec.repeating_day_of_week := NULL;
         END IF;

         IF p_deliverable_rec.repeating_frequency_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.repeating_frequency_uom := NULL;
         END IF;

         IF p_deliverable_rec.repeating_duration = okc_api.g_miss_num
         THEN
            p_deliverable_rec.repeating_duration := NULL;
         END IF;

         IF p_deliverable_rec.fixed_start_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.fixed_start_date := NULL;
         END IF;

         IF p_deliverable_rec.fixed_end_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.fixed_end_date := NULL;
         END IF;

         IF p_deliverable_rec.manage_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.manage_yn := 'N';
         END IF;

         IF p_deliverable_rec.internal_party_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.internal_party_id := NULL;
         END IF;

         --IF p_deliverable_rec.deliverable_status = okc_api.g_miss_char
         --THEN
            p_deliverable_rec.deliverable_status := 'INACTIVE';
         --END IF;

         IF p_deliverable_rec.status_change_notes = okc_api.g_miss_char
         THEN
            p_deliverable_rec.status_change_notes := NULL;
         END IF;

         --IF p_deliverable_rec.created_by = okc_api.g_miss_num
         --THEN
            p_deliverable_rec.created_by := fnd_global.user_id;
        -- END IF;

         --IF p_deliverable_rec.creation_date = okc_api.g_miss_date
         --THEN
            p_deliverable_rec.creation_date := SYSDATE;
         --END IF;

         --IF p_deliverable_rec.last_updated_by = okc_api.g_miss_num
         --THEN
            p_deliverable_rec.last_updated_by := fnd_global.user_id;
         --END IF;

         --IF p_deliverable_rec.last_update_date = okc_api.g_miss_date
         --THEN
            p_deliverable_rec.last_update_date := SYSDATE;
         --END IF;

         --IF p_deliverable_rec.last_update_login = okc_api.g_miss_num
         --THEN
            p_deliverable_rec.last_update_login := fnd_global.login_id;
         --END IF;

         --IF p_deliverable_rec.object_version_number = okc_api.g_miss_num
         --THEN
            p_deliverable_rec.object_version_number := 1;
         --END IF;

         IF p_deliverable_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute_category := NULL;
         END IF;

         IF p_deliverable_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute1 := NULL;
         END IF;

         IF p_deliverable_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute2 := NULL;
         END IF;

         IF p_deliverable_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute3 := NULL;
         END IF;

         IF p_deliverable_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute4 := NULL;
         END IF;

         IF p_deliverable_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute5 := NULL;
         END IF;

         IF p_deliverable_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute6 := NULL;
         END IF;

         IF p_deliverable_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute7 := NULL;
         END IF;

         IF p_deliverable_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute8 := NULL;
         END IF;

         IF p_deliverable_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute9 := NULL;
         END IF;

         IF p_deliverable_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute10 := NULL;
         END IF;

         IF p_deliverable_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute11 := NULL;
         END IF;

         IF p_deliverable_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute12 := NULL;
         END IF;

         IF p_deliverable_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute13 := NULL;
         END IF;

         IF p_deliverable_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute14 := NULL;
         END IF;

         IF p_deliverable_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute15 := NULL;
         END IF;

         IF p_deliverable_rec.disable_notifications_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.disable_notifications_yn := 'N';
         END IF;

         IF p_deliverable_rec.last_amendment_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.last_amendment_date := NULL;
         END IF;

         IF p_deliverable_rec.business_document_line_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.business_document_line_id := NULL;
         END IF;

         IF p_deliverable_rec.external_party_site_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.external_party_site_id := NULL;
         END IF;

         IF p_deliverable_rec.start_event_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.start_event_date := NULL;
         END IF;

         IF p_deliverable_rec.end_event_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.end_event_date := NULL;
         END IF;

         IF p_deliverable_rec.summary_amend_operation_code =
                                                           okc_api.g_miss_char
         THEN
            p_deliverable_rec.summary_amend_operation_code := NULL;
         END IF;

         IF p_deliverable_rec.external_party_role = okc_api.g_miss_char
         THEN
            p_deliverable_rec.external_party_role := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_prior_due_date_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.pay_hold_prior_due_date_yn := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_prior_due_date_value =
                                                            okc_api.g_miss_num
         THEN
            p_deliverable_rec.pay_hold_prior_due_date_value := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_prior_due_date_uom =
                                                           okc_api.g_miss_char
         THEN
            p_deliverable_rec.pay_hold_prior_due_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_overdue_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.pay_hold_overdue_yn := NULL;
         END IF;
      END default_row;

BEGIN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.create_deliverables');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_create_deliverables_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;



  validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);

    delRecTab := p_deliverable_rec;

    default_row(delRecTab);

    OPEN C_delTypeExists ;
    FETCH C_delTypeExists into C_delTypeExists_rec;

       IF C_delTypeExists%NOTFOUND THEN
        --Incorrect Deliverable type for the DOcument
	      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                          p_msg_name     => 'OKC_DEL_TYPE_MISMATCH',
					                  p_token1       => 'p_deliverable_type',
					                  p_token1_value => delRecTab.deliverable_type,
				                    p_token2       => 'P_DOCUMENT_TYPE',
				                    p_token2_value => p_document_type);
        x_return_status := G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;

       END IF;
     CLOSE C_delTypeExists;

     /*Other validations for Deliverable*/
    validate_deliverables(p_deliverable_rec => delRecTab);

    -- Get the print msg info
    IF delRecTab.print_due_date_msg_name IS NULL OR delRecTab.print_due_date_msg_name = OKC_API.G_MISS_CHAR
    THEN

         IF delRecTab.relative_st_date_event_id IS NOT NULL
         THEN
            l_start_date_fixed := 'N';
            get_event_details (delRecTab.relative_st_date_event_id,
                               l_start_evt_before_after
                              );
         ELSE
            l_start_date_fixed := 'Y';
         END IF;

         IF  delRecTab.recurring_yn = 'Y' THEN
           IF delRecTab.relative_end_date_event_id IS NULL THEN
            l_end_date_fixed := 'Y';
           ELSE
           l_end_date_fixed := 'N';
           get_event_details (delRecTab.relative_end_date_event_id,
                               l_end_evt_before_after
                              );
           END IF;
         ELSE
          l_end_date_fixed := 'N';
          get_event_details (delRecTab.relative_end_date_event_id,
                               l_end_evt_before_after
                              );
         END IF;



        IF delRecTab.repeating_duration IS NOT NULL
        AND delRecTab.repeating_frequency_uom IS NOT NULL THEN

         l_repeating_frequency_uom :=
            getuomvalue (p_duration      => delRecTab.repeating_duration,
                         p_uom           => delRecTab.repeating_frequency_uom
                        );
        ELSE
            l_repeating_frequency_uom := NULL;
        END IF;

        IF delRecTab.relative_st_date_duration IS not NULL AND
            delRecTab.relative_st_date_uom IS NOT NULL
           THEN
         l_relative_st_date_uom :=
            getuomvalue
                   (p_duration      => delRecTab.relative_st_date_duration,
                    p_uom           => delRecTab.relative_st_date_uom
                   );
         ELSE
         l_relative_st_date_uom := NULL;
         END IF;

         IF delRecTab.relative_end_date_duration IS NOT NULL AND
            delRecTab.relative_end_date_uom IS NOT NULL THEN

         l_relative_end_date_uom :=
            getuomvalue
                  (p_duration      => delRecTab.relative_end_date_duration,
                   p_uom           => delRecTab.relative_end_date_uom
                  );
          ELSE
            l_relative_end_date_uom := NULL;
          END IF;

         delRecTab.print_due_date_msg_name :=
            getprintduedatemsgname
                      (p_recurring_flag               => delRecTab.recurring_yn,
                       p_start_fixed_flag             => l_start_date_fixed,
                       p_end_fixed_flag               => l_end_date_fixed,
                       p_repeating_frequency_uom      => l_repeating_frequency_uom,
                       p_relative_st_date_uom         => l_relative_st_date_uom,
                       p_relative_end_date_uom        => l_relative_end_date_uom,
                       p_start_evt_before_after       => l_start_evt_before_after,
                       p_end_evt_before_after         => l_end_evt_before_after
                      );

    END IF;

    IF delRecTab.deliverable_id IS NULL OR delRecTab.deliverable_id = OKC_API.g_MISS_NUM THEN
      select okc_deliverable_id_s.nextval INTO delRecTab.deliverable_id from dual;
      delRecTab.original_deliverable_id := delRecTab.deliverable_id;
     END IF;

        INSERT INTO okc_deliverables
                  (deliverable_id,
                   business_document_type,
                   business_document_id,
                   business_document_number,
                   deliverable_type,
                   responsible_party,
                   internal_party_contact_id,
                   external_party_contact_id,
                   deliverable_name,
                   description, comments,
                   display_sequence,
                   fixed_due_date_yn,
                   actual_due_date,
                   print_due_date_msg_name,
                   recurring_yn,
                   notify_prior_due_date_value,
                   notify_prior_due_date_uom,
                   notify_prior_due_date_yn,
                   notify_completed_yn,
                   notify_overdue_yn,
                   notify_escalation_yn,
                   notify_escalation_value,
                   notify_escalation_uom,
                   escalation_assignee,
                   amendment_operation,
                   prior_notification_id,
                   amendment_notes,
                   completed_notification_id,
                   overdue_notification_id,
                   escalation_notification_id,
                   LANGUAGE,
                   original_deliverable_id,
                   requester_id,
                   external_party_id,
                   recurring_del_parent_id,
                   business_document_version,
                   relative_st_date_duration,
                   relative_st_date_uom,
                   relative_st_date_event_id,
                   relative_end_date_duration,
                   relative_end_date_uom,
                   relative_end_date_event_id,
                   repeating_day_of_month,
                   repeating_day_of_week,
                   repeating_frequency_uom,
                   repeating_duration,
                   fixed_start_date,
                   fixed_end_date,
                   manage_yn,
                   internal_party_id,
                   deliverable_status,
                   status_change_notes,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   object_version_number,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   disable_notifications_yn,
                   last_amendment_date,
                   business_document_line_id,
                   external_party_site_id,
                   start_event_date,
                   end_event_date,
                   summary_amend_operation_code,
                   external_party_role,
                   pay_hold_prior_due_date_yn,
                   pay_hold_prior_due_date_value,
                   pay_hold_prior_due_date_uom,
                   pay_hold_overdue_yn
                  )
           VALUES (delRecTab.deliverable_id,
                   delRecTab.business_document_type,
                   delRecTab.business_document_id,
                   g_document_number,
                   delRecTab.deliverable_type,
                   delRecTab.responsible_party,
                   delRecTab.internal_party_contact_id,
                   delRecTab.external_party_contact_id,
                   delRecTab.deliverable_name,
                   delRecTab.description, p_deliverable_rec.comments,
                   delRecTab.display_sequence,
                   delRecTab.fixed_due_date_yn,
                   delRecTab.actual_due_date,
                   delRecTab.print_due_date_msg_name,
                   delRecTab.recurring_yn,
                   delRecTab.notify_prior_due_date_value,
                   delRecTab.notify_prior_due_date_uom,
                   delRecTab.notify_prior_due_date_yn,
                   delRecTab.notify_completed_yn,
                   delRecTab.notify_overdue_yn,
                   delRecTab.notify_escalation_yn,
                   delRecTab.notify_escalation_value,
                   delRecTab.notify_escalation_uom,
                   delRecTab.escalation_assignee,
                   delRecTab.amendment_operation,
                   delRecTab.prior_notification_id,
                   delRecTab.amendment_notes,
                   delRecTab.completed_notification_id,
                   delRecTab.overdue_notification_id,
                   delRecTab.escalation_notification_id,
                   delRecTab.LANGUAGE,
                   delRecTab.original_deliverable_id,
                   delRecTab.requester_id,
                   delRecTab.external_party_id,
                   delRecTab.recurring_del_parent_id,
                   delRecTab.business_document_version,
                   delRecTab.relative_st_date_duration,
                   delRecTab.relative_st_date_uom,
                   delRecTab.relative_st_date_event_id,
                   delRecTab.relative_end_date_duration,
                   delRecTab.relative_end_date_uom,
                   delRecTab.relative_end_date_event_id,
                   delRecTab.repeating_day_of_month,
                   delRecTab.repeating_day_of_week,
                   delRecTab.repeating_frequency_uom,
                   delRecTab.repeating_duration,
                   delRecTab.fixed_start_date,
                   delRecTab.fixed_end_date,
                   delRecTab.manage_yn,
                   delRecTab.internal_party_id,
                   delRecTab.deliverable_status,
                   delRecTab.status_change_notes,
                   delRecTab.created_by,
                   delRecTab.creation_date,
                   delRecTab.last_updated_by,
                   delRecTab.last_update_date,
                   delRecTab.last_update_login,
                   delRecTab.object_version_number,
                   delRecTab.attribute_category,
                   delRecTab.attribute1,
                   delRecTab.attribute2,
                   delRecTab.attribute3,
                   delRecTab.attribute4,
                   delRecTab.attribute5,
                   delRecTab.attribute6,
                   delRecTab.attribute7,
                   delRecTab.attribute8,
                   delRecTab.attribute9,
                   delRecTab.attribute10,
                   delRecTab.attribute11,
                   delRecTab.attribute12,
                   delRecTab.attribute13,
                   delRecTab.attribute14,
                   delRecTab.attribute15,
                   delRecTab.disable_notifications_yn,
                   delRecTab.last_amendment_date,
                   delRecTab.business_document_line_id,
                   delRecTab.external_party_site_id,
                   delRecTab.start_event_date,
                   delRecTab.end_event_date,
                   delRecTab.summary_amend_operation_code,
                   delRecTab.external_party_role,
                   delRecTab.pay_hold_prior_due_date_yn,
                   delRecTab.pay_hold_prior_due_date_value,
                   delRecTab.pay_hold_prior_due_date_uom,
                   delRecTab.pay_hold_overdue_yn
                  );

      delRecTab.status := g_ret_sts_success;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;



   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.create_deliverables, return status'||x_return_status);
   END IF;

   IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   ELSIF (x_return_status = G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR ;
   END IF;


 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving create_deliverables');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving create_deliverables: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;
	  IF C_delTypeExists%ISOPEN THEN
     CLOSE C_delTypeExists;
    END IF;

         ROLLBACK TO g_create_deliverables_GRP;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving create_deliverables: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

      IF C_delTypeExists%ISOPEN THEN
     CLOSE C_delTypeExists;
      END IF;

	    ROLLBACK TO g_create_deliverables_GRP;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving create_deliverables because of EXCEPTION: '||sqlerrm);
      END IF;

      IF C_delTypeExists%ISOPEN THEN
      CLOSE C_delTypeExists;
      END IF;

	  ROLLBACK TO g_create_deliverables_GRP;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END create_deliverables;


PROCEDURE remove_std_clause_from_doc(p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        p_mode                 IN VARCHAR2 default'NORMAL',
            				    p_document_type           IN   Varchar2,
             				    p_document_id             IN   Number,
                        p_clause_version_id       IN   Number default null,
				                p_clause_title            IN   Varchar2 default null,
				                p_clause_version_num      IN   Number default null,
				                p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number)
IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'remove_std_art_from_doc';



TYPE l_cls_type IS RECORD (
       article_id         OKC_ARTICLE_VERSIONS.ARTICLE_ID%TYPE,
       article_title      OKC_ARTICLES_ALL.ARTICLE_TITLE%TYPE,
       article_version_id OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_ID%TYPE,
       article_version_number OKC_ARTICLE_VERSIONS.ARTICLE_VERSION_NUMBER%TYPE,
       article_intent     OKC_ARTICLES_ALL.ARTICLE_INTENT%TYPE,
	  provision_yn       OKC_ARTICLE_VERSIONS.PROVISION_YN%TYPE,
	  article_status     OKC_ARTICLE_VERSIONS.ARTICLE_STATUS%TYPE,
	  start_date         OKC_ARTICLE_VERSIONS.START_DATE%TYPE,
	  end_date           OKC_ARTICLE_VERSIONS.END_DATE%TYPE);

  l_cls_type_rec l_cls_type;

CURSOR l_cls_id_validate_csr IS
SELECT
       article_id,
	  article_title,
       article_version_id,
	  article_version_number,
       article_intent,
	  provision_yn,
	  article_status,
	  start_date,
	  end_date
FROM
  OKC_ARTICLES_V ART
WHERE ART.article_version_id = p_clause_version_id;


CURSOR l_cls_name_validate_csr(l_org_id IN NUMBER) IS
SELECT
       article_id,
	  article_title,
       article_version_id,
	  article_version_number,
       article_intent,
	  provision_yn,
	  article_status,
	  start_date,
	  end_date
FROM
  okc_articles_local_v ART
WHERE ART.article_title = p_clause_title
AND   ART.org_id = l_org_id
UNION ALL
SELECT
       article_id,
	  article_title,
       article_version_id,
	  article_version_number,
       article_intent,
	  provision_yn,
	  article_status,
	  start_date,
	  end_date
FROM
  okc_articles_global_v ART
WHERE ART.article_title = p_clause_title
AND   ART.org_id = l_org_id;

CURSOR c_get_doc_art_id_csr(p_article_id NUMBER) IS
  SELECT id, object_version_number
    FROM okc_k_articles_b
    WHERE p_document_type = p_document_type
    AND document_id = p_document_id
    AND sav_sae_id =  p_article_id;

BEGIN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.remove_std_art_from_doc');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_version_id : '||p_clause_version_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_title : '||p_clause_title);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_version_num : '||p_clause_version_num);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_renumber_terms : '||p_renumber_terms);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_remove_std_clause_grp;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;

    validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

 -- Check that Clause info is provided
  IF p_clause_version_id is NULL and p_clause_title is NULL THEN
  -- no clause is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_clause_version_id is not NULL THEN
     OPEN l_cls_id_validate_csr;
	   FETCH l_cls_id_validate_csr INTO l_cls_type_rec ;
     IF l_cls_id_validate_csr%NOTFOUND THEN
      --Invalid Clause
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_ID',
				        p_token1       => 'P_CLS_VER_ID',
				        p_token1_value => p_clause_version_id);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_cls_id_validate_csr;

  ELSE
     OPEN l_cls_name_validate_csr(G_CURRENT_ORG_ID);
	   FETCH l_cls_name_validate_csr INTO l_cls_type_rec ;
     IF l_cls_name_validate_csr%NOTFOUND THEN
      --Invalid Clause Name
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_NAME',
				        p_token1       => 'P_CLS_TITLE',
				        p_token1_value => p_clause_title);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE l_cls_name_validate_csr;

  END IF;

  /*Make  x_return_status as null. So if any clauses get deleted it will change to 'S' and if any errors it will change to 'E' or 'U'.
  If its null then no clauses got updated.*/

  FOR c_get_doc_art_id_csr_rec IN c_get_doc_art_id_csr(l_cls_type_rec.article_id) LOOP

    remove_clause_id_from_doc(
                                 p_api_version           => 1.0,
                                 p_init_msg_list         => FND_API.G_FALSE,
                                 p_commit       => FND_API.G_FALSE,
                                 p_mode                  => p_mode,
            				             p_document_type       => p_document_type,
             				             p_document_id         => p_document_id,
                                 p_clause_id           => c_get_doc_art_id_csr_rec.id,
                                 x_return_status         => x_return_status,
                                 x_msg_count             => x_msg_count,
                                 x_msg_data              => x_msg_data);
  END LOOP;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_K_ARTICLES_GRP.create_article, return status'||x_return_status);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    -----------------------------------------------------

    IF p_renumber_terms = 'Y' THEN
      apply_numbering_scheme(
           p_document_type     => p_document_type,
		       p_document_id       => p_document_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
         );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: apply_numbering_scheme, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving add_standard_clause');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving add_standard_clause: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;

         IF c_get_doc_art_id_csr%ISOPEN THEN
            CLOSE c_get_doc_art_id_csr;
	    END IF;
         IF l_cls_id_validate_csr%ISOPEN THEN
            CLOSE l_cls_id_validate_csr;
	    END IF;
         IF l_cls_name_validate_csr%ISOPEN THEN
            CLOSE l_cls_name_validate_csr;
	    END IF;

         ROLLBACK TO g_remove_std_clause_grp;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving add_standard_clause: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_remove_std_clause_grp;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving add_standard_clause because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_remove_std_clause_grp;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END remove_std_clause_from_doc;

PROCEDURE remove_clause_id_from_doc(p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        p_mode                 IN VARCHAR2 default'NORMAL',
            				    p_document_type           IN   Varchar2,
             				    p_document_id             IN   Number,
                        p_clause_id       IN   Number default null,
				                p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY NUMBER
                        ,p_locking_enabled_yn IN VARCHAR2 DEFAULT 'N'
)
IS

l_api_version                CONSTANT NUMBER := 1;
l_api_name                   CONSTANT VARCHAR2(30) := 'remove_clause_from_doc';
l_object_version_number NUMBER;

CURSOR c_get_doc_art_id_csr IS
  SELECT object_version_number
    FROM okc_k_articles_b
    WHERE p_document_type = p_document_type
    AND document_id = p_document_id
    AND id  =  p_clause_id;

BEGIN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered OKC_TERMS_MIGRATE_GRP.remove_std_art_from_doc');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Parameter List ');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_api_version : '||p_api_version);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_init_msg_list : '||p_init_msg_list);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_commit : '||p_commit);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_type : '||p_document_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_document_id : '||p_document_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_clause_version_id : '||p_clause_id);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: p_renumber_terms : '||p_renumber_terms);
  END IF;

    -- Standard Start of API savepoint
    SAVEPOINT g_remove_clause_from_doc_GRP;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN cur_org_csr;
  FETCH cur_org_csr INTO G_CURRENT_ORG_ID;
  CLOSE cur_org_csr;

    validate_document(
    p_document_type => p_document_type,
    p_document_id => p_document_id,
    x_return_status => x_return_status,
    x_msg_data => x_msg_data,
    x_msg_count => x_msg_count);


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'300: Finished OKC_TERMS_MIGRATE_GRP.validate_document, return status'||x_return_status);
  END IF;

  IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  ELSIF (x_return_status = G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR ;
  END IF;

 -- Check that Clause info is provided
  IF p_clause_id is NULL THEN
  -- no clause is provided
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS');
     x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
  END IF;

  IF p_clause_id is not NULL THEN
     OPEN c_get_doc_art_id_csr;
     FETCH c_get_doc_art_id_csr INTO l_object_version_number;
     IF c_get_doc_art_id_csr%NOTFOUND THEN
      --Invalid Clause
	   Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
	                       p_msg_name     => 'OKC_TERMS_INV_CLS_ID',
				        p_token1       => 'P_CLS_ID',
				        p_token1_value => p_clause_id);
      x_return_status := G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR ;
     END IF;
     CLOSE c_get_doc_art_id_csr;

  END IF;

    OKC_K_ARTICLES_GRP.delete_article(
                                 p_api_version           => 1.0,
                                 p_init_msg_list         => FND_API.G_FALSE,
                                 p_validate_commit       => FND_API.G_FALSE,
                                 p_validation_string     => Null,
                                 p_commit                => FND_API.G_FALSE,
                                 p_mode                  => p_mode,
                                 p_id                    => p_clause_id,
                                 p_object_version_number => l_object_version_number,
						                     p_mandatory_clause_delete => 'Y',
                                 p_super_user_yn           => 'N',
                                 x_return_status         => x_return_status,
                                 x_msg_count             => x_msg_count,
                                 x_msg_data              => x_msg_data
                                 ,p_lock_terms_yn        => p_locking_enabled_yn
                                     );

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: Finished OKC_K_ARTICLES_GRP.create_article, return status'||x_return_status);
    END IF;

    IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSIF (x_return_status = G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    END IF;
    -----------------------------------------------------

    IF p_renumber_terms = 'Y' THEN
      apply_numbering_scheme(
           p_document_type     => p_document_type,
		       p_document_id       => p_document_id,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data
         );

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'600: apply_numbering_scheme, return status'||x_return_status);
        END IF;

        IF (x_return_status = G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        ELSIF (x_return_status = G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
END IF;


   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'1000: Leaving add_standard_clause');
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

	    IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'800: Leaving add_standard_clause: OKC_API.G_EXCEPTION_ERROR Exception');
	    END IF;

         IF c_get_doc_art_id_csr%ISOPEN THEN
            CLOSE c_get_doc_art_id_csr;
	    END IF;

         ROLLBACK TO g_remove_clause_from_doc_GRP;
         x_return_status := G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'900: Leaving add_standard_clause: OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception');
	    END IF;

	    ROLLBACK TO g_remove_clause_from_doc_GRP;
	    x_return_status := G_RET_STS_UNEXP_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

   WHEN OTHERS THEN
	    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	       FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving add_standard_clause because of EXCEPTION: '||sqlerrm);
         END IF;

	  ROLLBACK TO g_remove_clause_from_doc_GRP;
	  x_return_status := G_RET_STS_UNEXP_ERROR ;
	  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
	       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

END remove_clause_id_from_doc;

END OKC_TERMS_MIGRATE_GRP;

/
