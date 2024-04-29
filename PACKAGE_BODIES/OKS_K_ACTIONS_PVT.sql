--------------------------------------------------------
--  DDL for Package Body OKS_K_ACTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_K_ACTIONS_PVT" AS
/* $Header: OKSKACTB.pls 120.19.12010000.4 2009/04/07 06:03:39 sjanakir ship $ */

 ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  G_PKG_NAME                   CONSTANT   VARCHAR2(200) := 'OKS_K_ACTIONS_PVT';
  G_APP_NAME                   CONSTANT   VARCHAR2(3)   := 'OKS';

  G_LEVEL_PROCEDURE            CONSTANT   NUMBER := FND_LOG.LEVEL_PROCEDURE;
  G_MODULE                     CONSTANT   VARCHAR2(250) := 'oks.plsql.'||g_pkg_name||'.';
  G_APPLICATION_ID             CONSTANT   NUMBER :=515; -- OKS Application

  G_FALSE                      CONSTANT   VARCHAR2(1) := FND_API.G_FALSE;
  G_TRUE                       CONSTANT   VARCHAR2(1) := FND_API.G_TRUE;

  G_RET_STS_SUCCESS            CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR              CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT   VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;

  G_UNEXPECTED_ERROR           CONSTANT   VARCHAR2(200) := 'OKS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN              CONSTANT   VARCHAR2(200) := 'ERROR_CODE';
  G_RET_STS_ACTION_NOT_ALWD    CONSTANT   VARCHAR2(1) := 'C';

  ------------------------------------------------------------------------------
  -- EXCEPTIONS
  ------------------------------------------------------------------------------
  ActionNotAllowedException EXCEPTION;


PROCEDURE setRemindersYn
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_chr_id               IN NUMBER,
 p_suppress_Yn		IN VARCHAR2,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) AS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'setRemindersYn';

/* Added for Bug# 7717268*/
 	 l_sql_err                  VARCHAR2(2000);
BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;
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

    -- check if the contract is valid for setting reminders
    IF validateForRenewalAction (p_chr_id,'RMDR') = 'Y' THEN
        update oks_k_headers_b
        set RMNDR_SUPPRESS_FLAG = p_suppress_yn,
        object_version_number = object_version_number+1,
         /* Added  Bug# 7717268 */
 	         last_update_date  = SYSDATE,
 	         last_updated_by   = FND_GLOBAL.USER_ID,
 	         last_update_login = FND_GLOBAL.LOGIN_ID
        where chr_id = p_chr_id;
    /*added for bug 7717268*/
        UPDATE okc_k_headers_all_b okcb
 	            SET last_update_date  = SYSDATE,
 	                last_updated_by   = FND_GLOBAL.USER_ID,
 	                last_update_login = FND_GLOBAL.LOGIN_ID
 	          WHERE okcb.id = p_chr_id;

 	         x_return_status := OKC_CVM_PVT.update_minor_version(p_chr_id => p_chr_id);

 	         IF x_return_status <> G_RET_STS_SUCCESS THEN
 	             l_sql_err := SQLERRM;
 	             fnd_message.set_name('OKS','OKS_K_VERSION_UPD_FAILED');
 	             fnd_message.set_token ('ERROR_MESSAGE', l_sql_err);

 	             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
 	                 fnd_log.STRING (fnd_log.level_statement, g_module ||l_api_name,
 	                         '1111:Reminder Suppress Flag Update Failed - l_sql_err:'||l_sql_err);
 	             END IF;

 	             x_msg_data      := fnd_message.get;
 	             x_return_status := g_ret_sts_error;
 	             x_msg_count     := 1;

 	         END IF;
    ELSE
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Not a valid action for this contract'||G_PKG_NAME ||'.'||l_api_name);
        END IF;
      x_return_status := G_RET_STS_ACTION_NOT_ALWD;
         RAISE ActionNotAllowedException;
    END IF;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
   WHEN ActionNotAllowedException THEN
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
     IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
       'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.ActionNotAllowedException '||
       ' Contract cannot be published since it is not in entered status');
     END IF;
       x_return_status := G_RET_STS_ACTION_NOT_ALWD;
  WHEN FND_API.G_EXC_ERROR THEN
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name||' with ERROR status');
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name||' with Unexpected Error status');
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name ||' with unexpected error');
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END setRemindersYn;

PROCEDURE send_email
(p_chr_id                    IN NUMBER
,p_to_address                IN VARCHAR2
,p_cc_address                IN VARCHAR2
,p_from_address              IN VARCHAR2
,p_reply_to_address          IN VARCHAR2
,p_subject                   IN VARCHAR2
,p_message_template_id       IN NUMBER
,p_attachment_template_id    IN NUMBER
,p_email_text                IN VARCHAR2
,p_contract_status_code      IN VARCHAR2
,x_request_id                OUT NOCOPY NUMBER
,x_return_status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY NUMBER
,x_msg_data                  OUT NOCOPY VARCHAR2
)AS

  l_api_version              CONSTANT NUMBER := 1;
  l_api_name                 CONSTANT VARCHAR2(30) := 'SEND_EMAIL';
  l_request_id               NUMBER;
  l_language                 VARCHAR2(10);
  l_attachment_template_id   NUMBER;
  l_document_type_code       VARCHAR2(30);
  l_attachment_name         VARCHAR2(50) ;
  l_process                  VARCHAR2(10) := 'EMQ';

  l_user_name                VARCHAR2(80);
  l_user_id                  NUMBER;
  l_return_status            VARCHAR2(10);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(240);
  l_add_notification         BOOLEAN;


/*  CURSOR c_attachment
  IS SELECT ort.report_id,ort.template_set_type, nvl(ort.attachment_name, olt.template_name)
     FROM OKS_REPORT_TEMPLATES ort ,OKS_LAYOUT_TEMPLATES_V olt
     WHERE ort.report_id=olt.template_id
     AND ort.id=p_attachment_template_id;*/

  CURSOR c_attachment
  IS SELECT ort.report_id,ort.template_set_type, nvl(ort.attachment_name, xtvl.template_name)
     FROM oks_report_templates ort ,XDO_TEMPLATES_VL XTVL
     WHERE XTVL.APPLICATION_ID = 515 AND
     XTVL.TEMPLATE_TYPE_CODE = 'RTF' AND
     SYSDATE BETWEEN XTVL.START_DATE AND
     NVL(XTVL.END_DATE,SYSDATE) AND NVL(XTVL.DEPENDENCY_FLAG,'P') = 'P' AND
     ort.report_id=xtvl.template_id AND
     ort.id=p_attachment_template_id;



BEGIN

  l_language := OKS_RENEW_UTIL_PVT.get_template_lang(p_chr_id);

  OPEN c_attachment;
  FETCH c_attachment INTO l_attachment_template_id,l_document_type_code, l_attachment_name;
  CLOSE c_attachment;

  IF l_document_type_code = 'QUOTE' THEN
     l_process := 'EMQA';
  END IF;

  OKS_RENEW_CONTRACT_PVT.get_user_name(
      p_api_version  => '1'
     ,p_init_msg_list => FND_API.G_FALSE
     ,x_return_status => l_return_status
     ,x_msg_count     => l_msg_count
     ,x_msg_data      => l_msg_data
     ,p_chr_id        => p_chr_id
     ,p_hdesk_user_id => null
     ,x_user_id       => l_user_id
     ,x_user_name     => l_user_name
    );

  l_add_notification :=fnd_submit.add_notification(l_user_name,'N','Y','Y');
  IF l_add_notification THEN
     l_request_id := fnd_request.submit_request(APPLICATION  =>   'OKS'
                                            ,PROGRAM      =>   'OKS_GENQUOTE_CP'
                                            ,DESCRIPTION  =>   NULL
                                            ,START_TIME   =>   SYSDATE
                                            ,SUB_REQUEST  =>   FALSE
                                            ,ARGUMENT1    =>   l_attachment_template_id
                                            ,ARGUMENT2    =>   p_chr_Id
                                            ,ARGUMENT3    =>   'EMQ'
                                            ,ARGUMENT4    =>   p_message_template_id
                                            ,ARGUMENT5    =>   p_email_text
                                            ,ARGUMENT6    =>   p_from_address
                                            ,ARGUMENT7    =>   p_to_address
                                            ,ARGUMENT8    =>   p_cc_address
                                            ,ARGUMENT9    =>   p_reply_to_address
                                            ,ARGUMENT10   =>   p_subject
                                            ,ARGUMENT11   =>   p_contract_status_code
                                            ,ARGUMENT12   =>   null
                                            ,ARGUMENT13   =>   null
                                            ,ARGUMENT14   =>   l_language
                                            ,ARGUMENT15   =>   l_attachment_name
                                            ,ARGUMENT16   =>   l_process);


      x_request_id :=l_request_id;

      if x_request_id >0 then

         Update OKS_K_HEADERS_B
         Set PROCESS_REQUEST_ID = l_request_id
	     Where CHR_ID = p_chr_id;

         x_return_status :=G_RET_STS_SUCCESS;
         x_msg_count :=0;
         x_msg_data :='';
      else
         x_return_status :=G_RET_STS_ERROR;
      end if;

  ELSE
      x_return_status :=G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
  END IF;

  commit work;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END send_email;


PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_id                       IN  NUMBER,
    p_chr_id                       IN  NUMBER,
    p_override_flag                IN  VARCHAR2)
AS
    l_api_name                 CONSTANT VARCHAR2(30) := 'execute_qa_check_list';
    l_return_status            VARCHAR2(1)  := G_RET_STS_SUCCESS;
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_msg_tbl                  OKC_QA_CHECK_PUB.MSG_TBL_TYPE;

 -- bug 5329334
 l_count              BINARY_INTEGER;
 l_msg_ctr            BINARY_INTEGER := 1;

BEGIN

   fnd_file.put_line(FND_FILE.LOG,'  ');
   fnd_file.put_line(FND_FILE.LOG,'Entering  OKS_K_ACTIONS_PVT.execute_qa_check_list');
   fnd_file.put_line(FND_FILE.LOG,'  ');

   fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
   fnd_file.put_line(FND_FILE.LOG,'Calling OKC_QA_CHECK_PUB.execute_qa_check_list');
   fnd_file.put_line(FND_FILE.LOG,'Start Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
   fnd_file.put_line(FND_FILE.LOG,'Parameters  ');
   fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
   fnd_file.put_line(FND_FILE.LOG,'p_api_version :  '||p_api_version);
   fnd_file.put_line(FND_FILE.LOG,'p_init_msg_list :  '||p_init_msg_list);
   fnd_file.put_line(FND_FILE.LOG,'p_chr_id :  '||p_chr_id);
   fnd_file.put_line(FND_FILE.LOG,'p_qcl_id :  '||p_qcl_id);
   fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
   fnd_file.put_line(FND_FILE.LOG,'  ');

    OKC_QA_CHECK_PUB.execute_qa_check_list
   (
     p_api_version   => p_api_version,
     p_init_msg_list => p_init_msg_list,
     x_return_status => l_return_status,
     x_msg_count     => l_msg_count,
     x_msg_data      => l_msg_data,
     p_qcl_id        => p_qcl_id,
     p_chr_id        => p_chr_id,
     x_msg_tbl       => l_msg_tbl
   );

   fnd_file.put_line(FND_FILE.LOG,'  ');
   fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
   fnd_file.put_line(FND_FILE.LOG,'AFTER Calling OKC_QA_CHECK_PUB.execute_qa_check_list');
   fnd_file.put_line(FND_FILE.LOG,'End Time : '||to_char(sysdate,'DD-MON-YYYY HH24:MI:SSSS'));
   fnd_file.put_line(FND_FILE.LOG,'OUT Parameters  ');
   fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
   fnd_file.put_line(FND_FILE.LOG,'x_return_status :  '||l_return_status);
   fnd_file.put_line(FND_FILE.LOG,'x_msg_tbl.count :  '||l_msg_tbl.count);
   fnd_file.put_line(FND_FILE.LOG,'---------------------------------------------------------- ');
   fnd_file.put_line(FND_FILE.LOG,'  ');


   -- bug 5329334
   -- should loop thru l_msg_tbl(l_count).error_status to check if there are any qa errors

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      x_return_status :=l_return_status;
      RETURN;
   END IF;

     x_return_status :=l_return_status;
     x_msg_count     :=l_msg_count;
     x_msg_data      :=l_msg_data;

   -- Check if any of the QA checks have failed. If so write to log file
   IF l_msg_tbl.count >0 THEN

     fnd_file.put_line(FND_FILE.LOG,'******** Following QA Errors occured ********  ');
     fnd_file.put_line(FND_FILE.LOG,'  ');

     l_count := l_msg_tbl.first;
     LOOP
       IF l_msg_tbl(l_count).error_status='E' THEN
         -- write to fnd_log file
         fnd_file.put_line(FND_FILE.LOG,l_msg_ctr||' : '||l_msg_tbl(l_count).data);

          -- reset the out parameter to Error
          x_return_status := 'E';

          -- increment the counter
          l_msg_ctr := l_msg_ctr +1;
        END IF;  -- error

       EXIT WHEN l_count =l_msg_tbl.LAST;
       l_count:=l_msg_tbl.next(l_count);
     END LOOP;
   END IF; -- l_msg_tbl.count >0

   fnd_file.put_line(FND_FILE.LOG,'  ');
   fnd_file.put_line(FND_FILE.LOG,'Leaving OKS_K_ACTIONS_PVT.execute_qa_check_list');
   fnd_file.put_line(FND_FILE.LOG,'x_return_status :  '||x_return_status);
   fnd_file.put_line(FND_FILE.LOG,'  ');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END;

FUNCTION get_to_email (p_contract_id IN NUMBER)
RETURN VARCHAR2
AS
 l_to_email_address VARCHAR2(120);
BEGIN
 OKS_AUTO_REMINDER.GET_QTO_EMAIL(
          p_chr_id        => p_contract_id
         ,x_qto_email     =>  l_to_email_address);
 RETURN l_to_email_address;

END;

PROCEDURE launch_qa_report
(
 p_api_version          IN NUMBER,
 p_init_msg_list        IN VARCHAR2,
 p_contract_list        IN VARCHAR2,
 x_cp_request_id        OUT NOCOPY NUMBER,
 x_return_status	OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT NOCOPY VARCHAR2,
 x_msg_count	        OUT NOCOPY NUMBER
) AS

l_api_version              CONSTANT NUMBER := 1;
l_api_name                 CONSTANT VARCHAR2(30) := 'launch_qa_report';

tmp_contract_list VARCHAR2(8000) ;
i NUMBER := 0;
j NUMBER := 0;

TYPE l_chr_id_list       IS TABLE OF OKC_K_HEADERS_ALL_B.ID%TYPE INDEX BY BINARY_INTEGER;
l_chr_id_tbl               l_chr_id_list;

l_request_id               NUMBER := 0;

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: p_contract_list : '||p_contract_list);
  END IF;

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

    -- set context to multi org
    mo_global.init('OKC');

   tmp_contract_list := p_contract_list;
   x_cp_request_id   := 0;

    -- debug log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '110: Converting K list to pl/sql');
    END IF;

  --Convert id list (string) to PL/SQL Array for bulk Update
    LOOP
      i := INSTR(tmp_contract_list,',');

       -- debug log
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                       G_MODULE||l_api_name,
                       '120: i : '||i);
       END IF;

      IF i > 0 THEN
         -- comma found

         l_chr_id_tbl(j) := SUBSTR(tmp_contract_list,1,i-1);

         -- debug log
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                         G_MODULE||l_api_name,
                         '130: j :'||j);
         END IF;

        tmp_contract_list := SUBSTR(tmp_contract_list,i+1, length(tmp_contract_list) - i);

         -- debug log
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                         G_MODULE||l_api_name,
                         '130: tmp_contract_list : '||tmp_contract_list);
         END IF;

        j := j + 1;
      ELSE
        -- no comma found i.e last contract id
        l_chr_id_tbl(j) := tmp_contract_list;
        EXIT;
      END IF;

    END LOOP;

    -- debug log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '200: After Converting K list to pl/sql');
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '200: Count of Ks is : '||l_chr_id_tbl.COUNT);
    END IF;

    -- if the number of contracts exceed 6 then throw an error
    IF NVL(l_chr_id_tbl.COUNT,0) > 6 THEN
        fnd_message.set_name(G_APP_NAME,'OKS_SUBMIT_MAX_QA_ERROR');
        fnd_msg_pub.add;
        x_return_status := G_RET_STS_ERROR ;
        RETURN;
    END IF;


    l_request_id := fnd_request.submit_request
              (
               APPLICATION  =>   'OKS',
               PROGRAM      =>   'OKSRQACK',
               DESCRIPTION  =>   'QA Report',
               START_TIME   =>   NULL,
               SUB_REQUEST  =>   FALSE,
               ARGUMENT1    => p_contract_list
              );

    -- debug log
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '300: Request Id of pgm : '||l_request_id);
    END IF;

    IF l_request_id > 0 THEN
       FORALL i in NVL(l_chr_id_tbl.FIRST,0)..NVL(l_chr_id_tbl.LAST,-1)
          UPDATE OKS_K_HEADERS_B
             SET PROCESS_REQUEST_ID = l_request_id
           WHERE chr_id = l_chr_id_tbl(i);
    ELSE
       FND_MESSAGE.SET_NAME('OKS','OKS_CP_ERROR');
       FND_MESSAGE.SET_TOKEN('SQL_ERROR',SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := G_RET_STS_ERROR ;
    END IF;

    x_cp_request_id := l_request_id;

    commit work;


-- Standard call to get message count and if count is 1, get message info.
FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );
END launch_qa_report;


/*
This function checks if the contract is valid for Renewal Workbench Table Actions. This check is done before doing following Actions
Enable Reminders, Disable Reminders, Submit for Approval and Publish to CustomerParameter: contract id
Returns: Y or N. If the ste_code is ENTERED and the contract is not submitted for approval then returns Y else returns N
*/
FUNCTION validateForRenewalAction (
                         p_chr_id       NUMBER,
                         p_called_from  VARCHAR2 DEFAULT NULL
				  )
     RETURN VARCHAR2
IS

    l_return_val  VARCHAR2(1) := 'N';

    CURSOR reminder_cur IS
       SELECT 'X'
       FROM okc_k_headers_all_b okck,
            okc_statuses_b sts
       WHERE okck.sts_code = sts.code
       AND sts.ste_code = 'ENTERED'
       AND okck.id = p_chr_id;

    reminder_rec reminder_cur%ROWTYPE;

    CURSOR chr_cur IS
       SELECT 'X'
       FROM okc_k_headers_all_b okck,
            okc_statuses_b sts
       WHERE okck.sts_code = sts.code
       AND sts.ste_code = 'ENTERED'
       AND okck.id = p_chr_id
       AND NOT EXISTS
          (SELECT 1
           FROM   WF_ITEMS WF,
                  OKC_PROCESS_DEFS_B KPDF
           WHERE WF.item_key = okck.contract_number || okck.contract_number_modifier
           AND   WF.end_date IS NULL
           AND   WF.item_type = KPDF.wf_name
           AND   KPDF.pdf_type = 'WPS');

    chr_rec chr_cur%ROWTYPE;
    l_api_name                 CONSTANT VARCHAR2(30) := 'validateForRenewalAction';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
     '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

  -- we don't want to restrict enabling / disabling reminders when contract is in
  -- approval process. Two reasons 1. Autoreminders will not send any reminders when
  -- OKCAUKAP wf is active. 2. When a regular contract is submitted for approval the
  -- negotiation status is pending internal approval but OKCAUKAP  wf is not yet
  -- launched, this case we are allowing enable/disable reminders so in order to keep
  -- the consistency, we don't want to restrict these actions
  IF p_called_from = 'RMDR' THEN
     OPEN reminder_cur;
     Fetch reminder_cur INTO reminder_rec;
     IF reminder_cur%FOUND THEN
       l_return_val := 'Y';
     END IF;
     CLOSE reminder_cur;
  ELSE
     OPEN chr_cur;
     Fetch chr_cur INTO chr_rec;
     IF chr_cur%FOUND THEN
       l_return_val := 'Y';
     END IF;
     CLOSE chr_cur;
  END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name || ' with return value: '||l_return_val);
  END IF;
  return(l_return_val);

EXCEPTION
    WHEN others THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                        '2000: Leaving with error '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      l_return_val := 'N';
      return(l_return_val);
END validateForRenewalAction;



/*
This method will insert the email details
into OKS_EMAIL_DETAILS table and
will return email_id as the output parameter value.-Bug#4911901
*/

PROCEDURE STORE_EMAIL_DTLS
(
 p_from_address             IN  VARCHAR2,
 p_to_address               IN  VARCHAR2,
 p_cc_address               IN  VARCHAR2,
 p_reply_to_address         IN  VARCHAR2,
 p_message_template_id      IN  NUMBER,
 p_attachment_template_id   IN  NUMBER,
 p_email_subject            IN  VARCHAR2,
 p_email_body               IN  VARCHAR2,
 p_email_contract_status    IN  VARCHAR2,
 x_email_id                 OUT NOCOPY NUMBER,
 x_return_status	          OUT NOCOPY VARCHAR2,
 x_msg_data	                OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
)AS

l_api_name                 CONSTANT VARCHAR2(30) := 'STORE_EMAIL_DTLS';
l_email_id                 NUMBER := 0;

BEGIN

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- set context to multi org
    mo_global.init('OKC');


  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '102:  p_from_address : '||p_from_address);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '103:  p_to_address : '||p_to_address);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '104:  p_cc_address : '||p_cc_address);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '106:  p_reply_to_address : '||p_reply_to_address);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '107:  p_message_template_id : '||p_message_template_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '108:  p_attachment_template_id : '||p_attachment_template_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '109:  p_email_subject : '||p_email_subject);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '111:  p_email_contract_status : '||p_email_contract_status);
  END IF;

    BEGIN

    INSERT INTO oks_email_details
                           (
                             email_id,
                             from_address,
                             to_address,
                             cc_address,
                             reply_to_address,
                             message_template_id,
                             attachment_template_id,
                             email_subject,
                             email_body,
                             email_contract_status,
                             CREATED_BY,
                             LAST_UPDATED_BY,
                             CREATION_DATE,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN
                           )
                    VALUES
                          (
                             oks_email_details_s1.nextval,
                             p_from_address,
                             p_to_address,
                             p_cc_address,
                             p_reply_to_address,
                             p_message_template_id,
                             p_attachment_template_id,
                             p_email_subject,
                             TO_CLOB(p_email_body),
                             p_email_contract_status,
                             FND_GLOBAL.USER_ID, -- CREATED_BY
                             FND_GLOBAL.USER_ID, -- LAST_UPDATED_BY
                             SYSDATE, -- CREATION_DATE
                             SYSDATE, -- LAST_UPDATE_DATE
                             FND_GLOBAL.LOGIN_ID  --LAST_UPDATE_LOGIN
                          )
                   RETURNING email_id
                   INTO      l_email_id;


                    EXCEPTION
                      WHEN OTHERS THEN
                             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                                 G_MODULE||l_api_name,
                                 '4657: Leaving '||G_PKG_NAME ||'.'||l_api_name||'.'||SQLERRM);
                             END IF;

                    END;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '200: After inserting into table:');
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '201:  email id generated from store_email_dtls : '||l_email_id);
    END IF;

    x_email_id := l_email_id;

    commit work;


  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name||'.'||SQLERRM);
      END IF;

END STORE_EMAIL_DTLS;


/*
This API will retrieve email details from OKS_EMAIL_DETAILS table.-Bug#4911901
*/

PROCEDURE GET_EMAIL_DTLS
(
 p_email_id                 IN  NUMBER,
 x_email_body               OUT NOCOPY VARCHAR2,
 x_return_status	    OUT NOCOPY VARCHAR2,
 x_msg_data	            OUT NOCOPY VARCHAR2,
 x_msg_count	            OUT NOCOPY NUMBER
)AS

l_api_name                 CONSTANT VARCHAR2(30) := 'GET_EMAIL_DTLS';

BEGIN
  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '300: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '301:  p_email_id : '||p_email_id);
  END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- set context to multi org
    mo_global.init('OKC');


                     SELECT     email_body
                     INTO     x_email_body
                     FROM    OKS_EMAIL_DETAILS
                     WHERE   email_id = p_email_id;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;


END GET_EMAIL_DTLS;


/*
This API will delete email details from OKS_EMAIL_DETAILS table.-Bug#4911901
*/
PROCEDURE DEL_EMAIL_DTLS
(
 p_email_id                 IN  NUMBER,
 x_return_status	    OUT NOCOPY VARCHAR2,
 x_msg_data	            OUT NOCOPY VARCHAR2,
 x_msg_count	            OUT NOCOPY NUMBER
)AS

  l_api_name                 CONSTANT VARCHAR2(30) := 'DEL_EMAIL_DTLS';

BEGIN

  -- start debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '100: Entered '||G_PKG_NAME ||'.'||l_api_name);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '400: Parameters ');
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '401:  p_email_id : '||p_email_id);
  END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- set context to multi org
    mo_global.init('OKC');

   DELETE FROM OKS_EMAIL_DETAILS WHERE email_id = p_email_id;

   IF SQL%ROWCOUNT = 0  THEN

             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                          G_MODULE||l_api_name,
                          '402: Rows are deleted successfully from OKS_EMAIL_DETAILS table');
              END IF;

   END IF;

  -- end debug log
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                    G_MODULE||l_api_name,
                    '1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;


END DEL_EMAIL_DTLS;

/* Overloaded send_email API that has been already defined.- Bug#4911901*/
PROCEDURE send_email
(p_chr_id                    IN NUMBER
,p_email_Id                  IN NUMBER
,p_to_address                IN VARCHAR2
,p_cc_address                IN VARCHAR2
,p_from_address              IN VARCHAR2
,p_reply_to_address          IN VARCHAR2
,p_subject                   IN VARCHAR2
,p_message_template_id       IN NUMBER
,p_attachment_template_id    IN NUMBER
,p_contract_status_code      IN VARCHAR2
,x_request_id                OUT NOCOPY NUMBER
,x_return_status             OUT NOCOPY VARCHAR2
,x_msg_count                 OUT NOCOPY NUMBER
,x_msg_data                  OUT NOCOPY VARCHAR2
)AS

  l_api_version              CONSTANT NUMBER := 1;
  l_api_name                 CONSTANT VARCHAR2(30) := 'SEND_EMAIL';
  l_request_id               NUMBER;
  l_language                 VARCHAR2(10);
  l_attachment_template_id   NUMBER;
  l_document_type_code       VARCHAR2(30);
  l_attachment_name         VARCHAR2(50) ;
  l_process                  VARCHAR2(10) := 'EMQ';

  l_user_name                VARCHAR2(80);
  l_user_id                  NUMBER;
  l_return_status            VARCHAR2(10);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(240);
  l_add_notification         BOOLEAN;


 /* CURSOR c_attachment
  IS SELECT ort.report_id,ort.template_set_type, nvl(ort.attachment_name, olt.template_name)
     FROM OKS_REPORT_TEMPLATES ort ,OKS_LAYOUT_TEMPLATES_V olt
     WHERE ort.report_id=olt.template_id
     AND ort.id=p_attachment_template_id;*/

  CURSOR c_attachment
  IS SELECT ort.report_id,ort.template_set_type, nvl(ort.attachment_name, xtvl.template_name)
     FROM oks_report_templates ort ,XDO_TEMPLATES_VL XTVL
     WHERE XTVL.APPLICATION_ID = 515 AND
     XTVL.TEMPLATE_TYPE_CODE = 'RTF' AND
     SYSDATE BETWEEN XTVL.START_DATE AND
     NVL(XTVL.END_DATE,SYSDATE) AND NVL(XTVL.DEPENDENCY_FLAG,'P') = 'P' AND
     ort.report_id=xtvl.template_id AND
     ort.id=p_attachment_template_id;

BEGIN

  l_language := OKS_RENEW_UTIL_PVT.get_template_lang(p_chr_id);

  OPEN c_attachment;
  FETCH c_attachment INTO l_attachment_template_id,l_document_type_code, l_attachment_name;
  CLOSE c_attachment;

  IF l_document_type_code = 'QUOTE' THEN
     l_process := 'EMQA';
  END IF;

  OKS_RENEW_CONTRACT_PVT.get_user_name(
      p_api_version  => '1'
     ,p_init_msg_list => FND_API.G_FALSE
     ,x_return_status => l_return_status
     ,x_msg_count     => l_msg_count
     ,x_msg_data      => l_msg_data
     ,p_chr_id        => p_chr_id
     ,p_hdesk_user_id => null
     ,x_user_id       => l_user_id
     ,x_user_name     => l_user_name
    );

  l_add_notification :=fnd_submit.add_notification(l_user_name,'N','Y','Y');
  IF l_add_notification THEN
     l_request_id := fnd_request.submit_request(APPLICATION  =>   'OKS'
                                            ,PROGRAM      =>   'OKS_GENQUOTE_CP'
                                            ,DESCRIPTION  =>   NULL
                                            ,START_TIME   =>   SYSDATE
                                            ,SUB_REQUEST  =>   FALSE
                                            ,ARGUMENT1    =>   l_attachment_template_id
                                            ,ARGUMENT2    =>   p_chr_Id
                                            ,ARGUMENT3    =>   'EMQ'
                                            ,ARGUMENT4    =>   p_message_template_id
                                            ,ARGUMENT5    =>   null
                                            ,ARGUMENT6    =>   p_from_address
                                            ,ARGUMENT7    =>   p_to_address
                                            ,ARGUMENT8    =>   p_cc_address
                                            ,ARGUMENT9    =>   p_reply_to_address
                                            ,ARGUMENT10   =>   p_subject
                                            ,ARGUMENT11   =>   p_contract_status_code
                                            ,ARGUMENT12   =>   null
                                            ,ARGUMENT13   =>   null
                                            ,ARGUMENT14   =>   l_language
                                            ,ARGUMENT15   =>   l_attachment_name
                                            ,ARGUMENT16   =>   l_process
                                            ,ARGUMENT17   =>   p_email_Id);


      x_request_id :=l_request_id;

      if x_request_id >0 then

         Update OKS_K_HEADERS_B
         Set PROCESS_REQUEST_ID = l_request_id
	     Where CHR_ID = p_chr_id;

         x_return_status :=G_RET_STS_SUCCESS;
         x_msg_count :=0;
         x_msg_data :='';
      else
         x_return_status :=G_RET_STS_ERROR;
      end if;

  ELSE
      x_return_status :=G_RET_STS_ERROR;
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
  END IF;

  commit work;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '2000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '3000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );

  WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE ,
                        G_MODULE||l_api_name,
                        '4000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => x_msg_count, p_data => x_msg_data );


END send_email;

  PROCEDURE update_single_contracts (
			p_chr_id         IN OKC_K_HEADERS_ALL_B.ID%TYPE,
			p_status_code    IN OKC_K_HEADERS_ALL_B.STS_CODE%TYPE,
			p_reason_code    IN OKC_K_HEADERS_ALL_B.TRN_CODE%TYPE,
			p_comments       IN VARCHAR2,
			p_due_date       IN OKS_K_HEADERS_B.FOLLOW_UP_DATE%TYPE,
			p_action         IN OKS_K_HEADERS_B.FOLLOW_UP_ACTION%TYPE,
			p_est_percent    IN OKS_K_HEADERS_B.EST_REV_PERCENT%TYPE,
			p_est_date       IN OKS_K_HEADERS_B.EST_REV_DATE%TYPE,
			p_contract_notes IN JTF_NOTES_TL.NOTES%TYPE,
			p_renewal_notes  IN   OKS_K_HEADERS_B.RENEWAL_COMMENT%TYPE,
                        x_succ_err_contract  OUT NOCOPY VARCHAR2,
    			x_return_status  OUT NOCOPY VARCHAR2,
    			x_msg_data       OUT NOCOPY VARCHAR2,
    			x_msg_count      OUT NOCOPY NUMBER)
  AS

 	l_api_version      CONSTANT NUMBER := 1;
 	l_api_name         CONSTANT VARCHAR2(30) := 'update_single_contracts';

        l_old_status_code  VARCHAR2(100);
        l_contract_number  VARCHAR2(100);
        l_init_msg_list    VARCHAR2(1) := 'T';
        l_jtf_note_id      JTF_NOTES_TL.JTF_NOTE_ID%TYPE;

        l_minor_version_updated    VARCHAR2(1) := 'F';
	l_sql_err   	   VARCHAR2(2000);

        CURSOR csr_k_old_status(c_chr_id in number) IS
        Select  sts_code,
	contract_number||decode(contract_number_modifier, NULL,'','-'||contract_number_modifier) contract_number
        from    okc_k_headers_all_b
        Where   id = c_chr_id;

-- bug 5934875, update page should be able to change values for follow-up and forecast to null
CURSOR csr_k_old_forecast IS
SELECT  follow_up_date,
        follow_up_action,
        est_rev_percent,
        est_rev_date
  FROM oks_k_headers_b
WHERE chr_id = p_chr_id;

l_old_follow_up_date       oks_k_headers_b.follow_up_date%TYPE;
l_old_follow_up_action     oks_k_headers_b.follow_up_action%TYPE;
l_old_est_rev_percent      oks_k_headers_b.est_rev_percent%TYPE;
l_old_est_rev_date         oks_k_headers_b.est_rev_date%TYPE;

  BEGIN
      -- start debug log
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      -- set context to multi org
       mo_global.init ('OKC');

    --  Initialize API return status to success
    x_return_status            := fnd_api.g_ret_sts_success;

    DBMS_TRANSACTION.SAVEPOINT(l_api_name);

      -- Printing input paramter values
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '101:p_chr_id = ' ||p_chr_id
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '102:p_status_code = ' ||p_status_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '103:p_reason_code = ' ||p_reason_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '104:p_comments = ' ||p_comments
                        );
	fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '105:p_due_date = ' ||p_due_date
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '106:p_action = ' ||p_action
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '107:p_est_percent = ' ||p_est_percent
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '108:p_est_date = ' ||p_est_date
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '109:p_contract_notes = ' ||p_contract_notes
                        );
      END IF;

	--fetching old contract status for the given contract id
        open csr_k_old_status(p_chr_id);
        fetch csr_k_old_status into l_old_status_code,l_contract_number;
        close csr_k_old_status;

 	x_succ_err_contract:= l_contract_number;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '210:l_old_status_code = ' ||l_old_status_code
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '210a:l_contract_number = ' ||l_contract_number
                        );
      END IF;


    -- bug 5934875, update page should be able to change values for follow-up and forecast to null
       OPEN csr_k_old_forecast;
          FETCH csr_k_old_forecast INTO l_old_follow_up_date,
                                        l_old_follow_up_action,
                                        l_old_est_rev_percent,
                                        l_old_est_rev_date;
       CLOSE csr_k_old_forecast;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '211:l_old_follow_up_date = ' ||l_old_follow_up_date
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '211:l_old_follow_up_action = ' ||l_old_follow_up_action
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '211:l_old_est_rev_percent = ' ||l_old_est_rev_percent
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '211:l_old_est_rev_date = ' ||l_old_est_rev_date
                        );
      END IF;



    IF (p_status_code IS NOT NULL) THEN
      	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      	THEN
         	fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '211:Calling OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS API'
                        );
      	END IF;
       --Updating Contract Status
          OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS(
                              x_return_status       => x_return_status,
                              x_msg_data            => x_msg_data,
                              x_msg_count           => x_msg_count,
		 	      p_init_msg_list	    => FND_API.G_TRUE,
                              p_id                  => p_chr_id,
                              p_new_sts_code        => p_status_code,
                              p_canc_reason_code    => p_reason_code,
                              p_old_sts_code        => l_old_status_code,
                              p_comments            => p_comments,
                              p_term_cancel_source  => 'MANUAL',
                              p_date_cancelled      => sysdate,
                              p_validate_status     => 'Y');

    	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      		THEN
         	fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '212:x_return_status after calling OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS: ' ||p_chr_id||': '||x_return_status);
         	fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '213:x_msg_data after calling OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS for ' ||p_chr_id||': '||x_msg_data);
         	fnd_log.STRING (fnd_log.level_statement,
                         g_module ||
                         l_api_name,
                         '214:x_msg_count after calling OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS for ' ||p_chr_id||': '||x_msg_count);
      	END IF;

    --- If any errors happen abort API
    IF (NVL(x_return_status,'U') = g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
			--OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS API already updated minor version
		        l_minor_version_updated := 'T';

   END IF;--end Update Contract Status




		--if contract status got updated then update the jtf notes otherwise return error status
		if(p_contract_notes IS NOT NULL) then
      					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      					THEN
         					fnd_log.STRING (fnd_log.level_statement,
                         			g_module ||
                         			l_api_name,
                         			'215:Calling JTF_NOTES_PUB.CREATE_NOTE API');
      					END IF;
		       --Updating jtf Notes
			JTF_NOTES_PUB.CREATE_NOTE(
                                p_api_version           => l_api_version,
                                p_init_msg_list         =>  l_init_msg_list,
                                p_commit                => 'F',
                                p_validation_level      => 100,
                                x_return_status         => x_return_status,
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data ,
                                p_org_id                =>  NULL,
                                p_source_object_id      => p_chr_id,
                                p_source_object_code    => 'OKS_HDR_NOTE',
                                p_notes                 => p_contract_notes,
                                p_note_status           =>  'I',    --public status
                                p_entered_by            =>  FND_GLOBAL.USER_ID,
                                p_entered_date          => SYSDATE ,
                                x_jtf_note_id           => l_jtf_note_id,
                                p_last_update_date      => sysdate,
                                p_last_updated_by       => FND_GLOBAL.USER_ID,
                                p_creation_date         => SYSDATE,
                                p_created_by            => FND_GLOBAL.USER_ID,
                                p_last_update_login     => FND_GLOBAL.LOGIN_ID,
                                p_note_type             => 'OKS_ADMIN');

      			IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      			THEN
         			fnd_log.STRING (fnd_log.level_statement,
                         	g_module ||
                         	l_api_name,
                         	'216:l_jtf_note_id after calling JTF_NOTES_PUB.CREATE_NOTE: ' ||p_chr_id||': '||l_jtf_note_id);
         			fnd_log.STRING (fnd_log.level_statement,
                         	g_module ||
                         	l_api_name,
                         	'217:x_return_status after calling JTF_NOTES_PUB.CREATE_NOTE: ' ||p_chr_id||': '||x_return_status);
         			fnd_log.STRING (fnd_log.level_statement,
                         	g_module ||
                         	l_api_name,
                         	'218:x_msg_data after calling JTF_NOTES_PUB.CREATE_NOTE for ' ||p_chr_id||': '||x_msg_data);
         			fnd_log.STRING (fnd_log.level_statement,
                         	g_module ||
                         	l_api_name,
                         	'219:x_msg_count after calling JTF_NOTES_PUB.CREATE_NOTE for ' ||p_chr_id||': '||x_msg_count);
      			END IF;

    		--- If any errors happen abort API
    		IF (NVL(x_return_status,'U') = g_ret_sts_unexp_error) THEN
    			fnd_message.set_name('OKS','OKS_JTF_NOTES_FAILED');
			x_msg_data := fnd_message.get;
			x_msg_count := 1;
      			RAISE fnd_api.g_exc_unexpected_error;
    		ELSIF (x_return_status = g_ret_sts_error) THEN
    			fnd_message.set_name('OKS','OKS_JTF_NOTES_FAILED');
			x_msg_data := fnd_message.get;
			x_msg_count := 1;
      			RAISE fnd_api.g_exc_error;
    		END IF;

           END IF;--end Update jtf Notes

 /* Added by sjanakir FP for Bug# 7147899 */
 IF  (p_est_percent IS NOT NULL AND p_est_date IS NULL AND l_old_est_rev_date IS NULL) OR
     (p_est_date    IS NOT NULL AND p_est_percent IS NULL AND l_old_est_rev_percent IS NULL)
 THEN
	 fnd_message.set_name('OKS','OKS_FORECAST_UPDATE_FAILED');
	 x_msg_data:= fnd_message.get;
	 x_return_status := g_ret_sts_error;
	 x_msg_count := 1;

 ELSE
-- bug 5934875,
IF  ( NVL(p_est_percent,999) <> NVL(l_old_est_rev_percent,999) )  OR
    ( NVL(p_est_date,SYSDATE) <> NVL(l_old_est_rev_date,SYSDATE) )  OR
    ( NVL(p_action,'XYZ') <> NVL(l_old_follow_up_action,'XYZ') )  OR
    ( NVL(p_due_date,SYSDATE) <> NVL(l_old_follow_up_date,SYSDATE) )  THEN

--Update Follow Up Action and Date, Forecast Percent and Date
-- if ((p_est_percent IS NOT NULL) OR (p_action IS NOT NULL) ) then

      	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      	THEN
         fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '220:Now Updating Follow Up Action and Date, Forecast Percent and Date in oks_k_headers_b');
      	END IF;
		/*modified for bug7034006*/
                --Updating Follow Up
		Update oks_k_headers_b
                   set follow_up_date = p_due_date,
		       follow_up_action =  p_action,
		       est_rev_percent = p_est_percent,
		       est_rev_date = p_est_date,
			last_update_date = SYSDATE,
			last_updated_by = FND_GLOBAL.USER_ID,
			last_update_login = FND_GLOBAL.LOGIN_ID
		where chr_id = p_chr_id;
/*added for bug7034006*/
		Update okc_k_headers_all_b okcb
		   set last_update_date = SYSDATE,
		       last_updated_by = FND_GLOBAL.USER_ID,
		       last_update_login = FND_GLOBAL.LOGIN_ID
		where okcb.id = p_chr_id;

					    	if(SQL%ROWCOUNT =1) then
							x_return_status := fnd_api.g_ret_sts_success;
					    	else
							l_sql_err := SQLERRM;
							fnd_message.set_name('OKS','OKS_FOREACST_FOLLOWUP_ERROR');
							fnd_message.set_token ('ERROR_MESSAGE', l_sql_err);

      							IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      							THEN
         							fnd_log.STRING (fnd_log.level_statement,
                         					g_module ||
                         					l_api_name,
                         					'221a:Forecast and Follow Up update failed - l_sql_err:'||l_sql_err);
							END IF;

							x_msg_data:= fnd_message.get;
							x_return_status := g_ret_sts_error;
							x_msg_count := 1;
					    	end if;
      					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      					THEN
         					fnd_log.STRING (fnd_log.level_statement,
                         			g_module ||
                         			l_api_name,
                         			'221:Inside Update Follow Up and Forecast part - x_return_status:'||x_return_status);
					END IF;

    		--- If any errors happen abort API
    		IF (NVL(x_return_status,'U') = g_ret_sts_unexp_error) THEN
      			RAISE fnd_api.g_exc_unexpected_error;
    		ELSIF (x_return_status = g_ret_sts_error) THEN
      			RAISE fnd_api.g_exc_error;
    		END IF;

                                 end if;--end Update Follow Up Action and Date


 ---Update Renewal Notes - kkolukul

 	      IF(p_renewal_notes IS NOT NULL) THEN

 	         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
 	          fnd_log.STRING (fnd_log.level_statement,
 	                         g_module ||
 	                         l_api_name,
 	                         '222:Now Updating Renewal Comment in oks_k_headers_b');
 	         END IF;

 	                 UPDATE oks_k_headers_b
 	                   SET renewal_comment = p_renewal_notes,
 	                       last_update_date = SYSDATE,
 	                       last_updated_by = FND_GLOBAL.USER_ID,
 	                       last_update_login = FND_GLOBAL.LOGIN_ID
 	                 WHERE chr_id = p_chr_id;

 	                UPDATE okc_k_headers_all_b okcb
 	                   SET last_update_date = SYSDATE,
 	                        last_updated_by = FND_GLOBAL.USER_ID,
 	                        last_update_login = FND_GLOBAL.LOGIN_ID
 	                 WHERE okcb.id = p_chr_id;


 	           --- If any errors happen abort API
 	                 IF (NVL(x_return_status,'U') = g_ret_sts_unexp_error) THEN
 	                         RAISE fnd_api.g_exc_unexpected_error;
 	                 ELSIF (x_return_status = g_ret_sts_error) THEN
 	                         RAISE fnd_api.g_exc_error;
 	                 END IF;

 	       END IF;      --End: Update Renewal Notes - kkolukul

		--Update minor version
                                if (l_minor_version_updated = 'F') THEN
      					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      					THEN
         					fnd_log.STRING (fnd_log.level_statement,
                         			g_module ||
                         			l_api_name,
                         			'224:Now Updating minor_version in okc_k_vers_numbers');
      					END IF;

					--Updating minor_version
/*commented and modified for bug7034006*/
/*					Update okc_k_vers_numbers
					Set minor_version = minor_version + 1
					Where chr_id = p_chr_id;

					    	if(SQL%ROWCOUNT =1) then
							x_return_status := fnd_api.g_ret_sts_success;
					    	else
							l_sql_err := SQLERRM;
							fnd_message.set_name('OKS','OKS_K_VERSION_UPD_FAILED');
							fnd_message.set_token ('ERROR_MESSAGE', l_sql_err);

      							IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      							THEN
         							fnd_log.STRING (fnd_log.level_statement,
                         					g_module ||
                         					l_api_name,
                         					'225a:Follow Up update failed - l_sql_err:'||l_sql_err);
							END IF;

							x_msg_data:= fnd_message.get;
							x_return_status := g_ret_sts_error;
							x_msg_count := 1;
					    	end if;
*/
	x_return_status := OKC_CVM_PVT.update_minor_version(p_chr_id => p_chr_id);
	  IF x_return_status <> G_RET_STS_SUCCESS THEN
	        l_sql_err := SQLERRM;
		fnd_message.set_name('OKS','OKS_K_VERSION_UPD_FAILED');
		fnd_message.set_token ('ERROR_MESSAGE', l_sql_err);

      	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
         	fnd_log.STRING (fnd_log.level_statement, g_module ||l_api_name,
 				'225a:Follow Up update failed - l_sql_err:'||l_sql_err);
	     END IF;

		x_msg_data:= fnd_message.get;
		x_return_status := g_ret_sts_error;
		x_msg_count := 1;
	  END IF;


      					IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      					THEN
         					fnd_log.STRING (fnd_log.level_statement,
                         			g_module ||
                         			l_api_name,
                         			'225:Inside Update minor version part - x_return_status:'||x_return_status);
					END IF;

    					--- If any errors happen abort API
    					IF (NVL(x_return_status,'U') = g_ret_sts_unexp_error) THEN
      						RAISE fnd_api.g_exc_unexpected_error;
    					ELSIF (x_return_status = g_ret_sts_error) THEN
      						RAISE fnd_api.g_exc_error;
    					END IF;
                                  end if;--end update minor version

		commit work;

      				IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      				THEN
         				fnd_log.STRING (fnd_log.level_statement,
                         		g_module ||
                         		l_api_name,
                         		'226:Changes commited');
         				fnd_log.STRING (fnd_log.level_statement,
                         		g_module ||
                         		l_api_name,
                         		'227:Final x_return_status:'||x_return_status);
      				END IF;

/* Added by sjanakir FP for Bug# 7147899 */
END IF;

   EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '2000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_error;

      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );
    WHEN fnd_api.g_exc_unexpected_error THEN
      DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_statement,
                        g_module ||
                        l_api_name,
                        '3000: Leaving ' ||
                        g_pkg_name ||
                        '.' ||
                        l_api_name
                       );
      END IF;

      x_return_status            := g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get (p_encoded                         => 'F',
                                 p_count                           => x_msg_count,
                                 p_data                            => x_msg_data
                                );

      WHEN OTHERS THEN
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from OTHERS sqlcode = ' ||
                            SQLCODE ||
                            ', sqlerrm = ' ||
                            SQLERRM
                           );
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name,
                                     SUBSTR (SQLERRM,
                                             1,
                                             240
                                            )
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );
         x_return_status            := g_ret_sts_unexp_error;

    END update_single_contracts;


END OKS_K_ACTIONS_PVT;


/
