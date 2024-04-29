--------------------------------------------------------
--  DDL for Package Body OKL_CURE_RECON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_RECON_PVT" AS
/* $Header: OKLRRCOB.pls 120.16 2008/05/12 10:08:39 akrangan noship $ */

G_MODULE VARCHAR2(255) := 'okl.cure.request.OKL_CURE_RECON_PVT';
G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
G_IS_DEBUG_STATEMENT_ON BOOLEAN;

--private procedure

FUNCTION get_factor_synd(p_khr_id IN NUMBER) RETURN VARCHAR2 IS

    CURSOR c_synd IS
       SELECT scs_code
       FROM   okc_k_headers_b
       WHERE  scs_code = 'SYNDICATION'
         AND  id = p_khr_id;

    CURSOR c_fact IS
       SELECT 1
       FROM   okc_rules_b
       WHERE  dnz_chr_id = p_khr_id
         AND  rule_information_category = 'LAFCTG';

    l_contract_type   VARCHAR2(30);

  BEGIN

    OPEN c_synd;
    FETCH c_synd INTO l_contract_type;
    CLOSE c_synd;

    IF l_contract_type IS NOT NULL THEN
      RETURN  l_contract_type;
    END IF;

    OPEN c_fact;
    FETCH c_fact INTO l_contract_type;
    CLOSE c_fact;

    IF l_contract_type IS NOT NULL THEN
      l_contract_type := 'FACTORING';
      RETURN  l_contract_type;
    END IF;

    RETURN NULL;

  EXCEPTION

    WHEN OTHERS THEN
     OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UNEXPECTED_ERROR,
                           p_token1       => G_SQLCODE_TOKEN,
                           p_token1_value => SQLCODE,
                           p_token2       => G_SQLERRM_TOKEN,
                           p_token2_value => SQLERRM);

  END get_factor_synd;


/**Name   AddMissingArgMsg
  **Appends to a message  the api name, parameter name and parameter Value
 */

PROCEDURE AddMissingArgMsg
  ( p_api_name	    IN	VARCHAR2,
    p_param_name	IN	VARCHAR2 )IS
BEGIN
        fnd_message.set_name('OKL', 'OKL_API_ALL_MISSING_PARAM');
        fnd_message.set_token('API_NAME', p_api_name);
        fnd_message.set_token('MISSING_PARAM', p_param_name);
        fnd_msg_pub.add;

END AddMissingArgMsg;

/**Name   AddFailMsg
  **Appends to a message  the name of the object and
  ** the operation (insert, update ,delete)
*/

PROCEDURE AddfailMsg
  ( p_object	    IN	VARCHAR2,
    p_operation 	IN	VARCHAR2 ) IS

BEGIN
      fnd_message.set_name('OKL', 'OKL_FAILED_OPERATION');
      fnd_message.set_token('UPDATE', p_operation);
      fnd_message.set_token('OBJECT',    p_object);
      fnd_message.set_token('OPERATION', p_operation);
      fnd_msg_pub.add;

END    AddfailMsg;

PROCEDURE Get_Messages (
p_message_count IN  NUMBER,
x_message       OUT NOCOPY VARCHAR2) IS


  l_msg_list        VARCHAR2(32627) := '';
  l_temp_msg        VARCHAR2(32627);
  l_appl_short_name  VARCHAR2(50) ;
  l_message_name    VARCHAR2(50) ;
  l_id              NUMBER;
  l_message_num     NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(32627);

  Cursor Get_Appl_Id (x_short_name VARCHAR2) IS
         SELECT  application_id
         FROM    fnd_application_vl
         WHERE   application_short_name = x_short_name;

  Cursor Get_Message_Num (x_msg VARCHAR2, x_id NUMBER, x_lang_id NUMBER) IS
         SELECT  msg.message_number
         FROM    fnd_new_messages msg, fnd_languages_vl lng
         WHERE   msg.message_name = x_msg
          and   msg.application_id = x_id
          and   lng.LANGUAGE_CODE = msg.language_code
          and   lng.language_id = x_lang_id;

BEGIN
      FOR l_count in 1..p_message_count LOOP

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_true);
          fnd_message.parse_encoded(l_temp_msg, l_appl_short_name, l_message_name);
          OPEN Get_Appl_Id (l_appl_short_name);
          FETCH Get_Appl_Id into l_id;
          CLOSE Get_Appl_Id;

          l_message_num := NULL;
          IF l_id is not NULL
          THEN
              OPEN Get_Message_Num (l_message_name, l_id,
                        to_number(NVL(FND_PROFILE.Value('LANGUAGE'), '0')));
              FETCH Get_Message_Num into l_message_num;
              CLOSE Get_Message_Num;
          END IF;

          l_temp_msg := fnd_msg_pub.get(fnd_msg_pub.g_previous, fnd_api.g_true);

          IF NVL(l_message_num, 0) <> 0
          THEN
            l_temp_msg := 'APP-' || to_char(l_message_num) || ': ';
          ELSE
            l_temp_msg := NULL;
          END IF;

          IF l_count = 1
          THEN
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false);
          ELSE
              l_msg_list := l_msg_list || l_temp_msg ||
                        fnd_msg_pub.get(fnd_msg_pub.g_next, fnd_api.g_false);
          END IF;

          l_msg_list := l_msg_list || '';

      END LOOP;

      x_message := l_msg_list;


END Get_Messages;

PROCEDURE  UPDATE_CRT (  p_report_id     IN NUMBER,
                         p_status        IN VARCHAR2,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'UPDATE_CRT';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;
Cursor c_get_obj_ver (p_report_id IN NUMBER)
is
select object_version_number
from   okl_cure_reports
where  cure_report_id =p_report_id;

lp_crtv_rec OKL_crt_pvt.crtv_rec_type;
xp_crtv_rec OKL_crt_pvt.crtv_rec_type;

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CRT : START ');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  SAVEPOINT UPDATE_CRT;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start update_cure_reports');
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- update Cure reports table set error message,so this will be prefixed before
  -- the actual message, so it makes more sense than displaying an OKL message.
  AddfailMsg(
              p_object    =>  'RECORD IN OKL_CURE_REPORTS ',
              p_operation =>  'UPDATE' );

  lp_crtv_rec.cure_report_id        :=p_report_id;
  lp_crtv_rec.approval_status       :=p_status;
  OPEN  c_get_obj_ver(p_report_id);
  FETCH c_get_obj_ver INTO lp_crtv_rec.object_version_number;
  CLOSE c_get_obj_ver;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CRT : lp_crtv_rec.cure_report_id : '||lp_crtv_rec.cure_report_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CRT : lp_crtv_rec.approval_status : '||lp_crtv_rec.approval_status);

  okl_cure_reports_pub.update_cure_reports(
                    p_api_version                  =>1.0
                   ,p_init_msg_list                =>FND_API.G_FALSE
                   ,x_return_status                =>l_return_status
                   ,x_msg_count                    =>l_msg_count
                   ,x_msg_data                     =>l_msg_data
                   ,p_crtv_rec                     =>lp_crtv_rec
                   ,x_crtv_rec                     =>xp_crtv_rec);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CRT : okl_cure_reports_pub.update_cure_reports : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error is :' ||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  ELSE
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updated cure reports table ');
    END IF;
    FND_MSG_PUB.initialize;
  END IF;

  FND_MSG_PUB.Count_And_Get
        (  p_count          =>   x_msg_count,
           p_data           =>   x_msg_data
        );

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                            , G_MODULE,
                            ' End of Procedure => OKL_PAY_RECON_PVT.UPDATE_CRT');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CRT : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_CRT;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_CRT;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_CRT;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','UPDATE_CRT');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_CRT;

PROCEDURE  UPDATE_CAM (  p_cam_tbl        IN cure_amount_tbl,
                         p_report_id      IN NUMBER,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2)
IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'UPDATE_CAM';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;
Cursor c_get_obj_ver (p_cam_id IN NUMBER) is
select a.object_version_number,a.cure_amount,b.khr_id
from   okl_cure_amounts a, okl_k_headers b
where  cure_amount_id =p_cam_id
and a.chr_id =b.id;

lp_camv_rec OKL_cam_pvt.camv_rec_type;
xp_camv_rec OKL_cam_pvt.camv_rec_type;
l_short_fund_amount okl_cure_amounts.short_fund_amount%TYPE;
l_cure_amount       okl_cure_amounts.cure_amount%TYPE;
l_khr_id            okl_k_headers.khr_id%TYPE;

l_rule_name     VARCHAR2(200);
l_rule_value    VARCHAR2(2000);
l_id1           VARCHAR2(40);
l_id2           VARCHAR2(200);

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : START ');

  IF (G_DEBUG_ENABLED = 'Y')
  THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  SAVEPOINT UPDATE_CAM;

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start update_cure amounts');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- update Cure amounts table set error message,so this will be prefixed before
  -- the actual message, so it makes more sense than displaying an OKL message.
  AddfailMsg(
             p_object    =>  'RECORD IN OKL_CURE_AMOUNTS ',
             p_operation =>  'UPDATE' );

  FOR i in p_cam_tbl.FIRST..p_cam_tbl.LAST
  LOOP
    OPEN  c_get_obj_ver(p_cam_tbl(i).cam_id);
    FETCH c_get_obj_ver
    INTO lp_camv_rec.object_version_number,
         l_cure_amount,
         l_khr_id;
    CLOSE c_get_obj_ver;

    --calculate short fund amount if rule value is set
    l_return_status := okl_contract_info.get_rule_value(
                              p_contract_id     => l_khr_id
                             ,p_rule_group_code => 'COCURP'
                             ,p_rule_code	=> 'COCURE'
                             ,p_segment_number	=> 8
                             ,x_id1             => l_id1
                             ,x_id2             => l_id2
                             ,x_value           => l_rule_value);

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : okl_contract_info.get_rule_value : '||l_return_status);

    IF l_return_status =FND_Api.G_RET_STS_SUCCESS
    THEN
      IF (l_rule_value = 'Yes')
      THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                                  , G_MODULE
                                  ,' Short fund rule is applicable');
        END IF;
        lp_camv_rec.short_fund_amount := nvl(l_cure_amount,0)
                                         - nvl(p_cam_tbl(i).negotiated_amount,0);
      END IF;
    END IF;

    IF lp_camv_rec.short_fund_amount = OKL_API.G_MISS_NUM
    THEN
      lp_camv_rec.short_fund_amount :=NULL;
    END IF;

    lp_camv_rec.cure_amount_id        :=p_cam_tbl(i).cam_id;
    lp_camv_rec.negotiated_amount     :=p_cam_tbl(i).negotiated_amount;
    lp_camv_rec.crt_id                :=p_report_id;

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : lp_camv_rec.cure_amount_id : '||lp_camv_rec.cure_amount_id);
    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : lp_camv_rec.negotiated_amount : '||lp_camv_rec.negotiated_amount);
    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : lp_camv_rec.crt_id : '||lp_camv_rec.crt_id);

    --jsanju 09/24/03
    -- new column in cure amounts table ,indicating what action has been done.
    -- possible values are 'CURE','REPURCHASE' & 'DONOTPROCESS'

    --jsanju 11/26/03
    IF p_cam_tbl(i).process IN ('REPURCHASE', 'DONOTPROCESS') THEN
      lp_camv_rec.process   :=p_cam_tbl(i).process;
    ELSE
      lp_camv_rec.process := 'CURE';
    END IF;

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : lp_camv_rec.process : '||lp_camv_rec.process);

    okl_cure_amounts_pub.update_cure_amounts(
                    p_api_version     =>1.0
                   ,p_init_msg_list   =>FND_API.G_FALSE
                   ,x_return_status   =>l_return_status
                   ,x_msg_count       =>l_msg_count
                   ,x_msg_data        =>l_msg_data
                   ,p_camv_rec        =>lp_camv_rec
                   ,x_camv_rec        =>xp_camv_rec);

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : okl_cure_amounts_pub.update_cure_amounts : '||l_return_status);

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      Get_Messages (l_msg_count,l_message);
      IF (G_IS_DEBUG_STATEMENT_ON = true)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error is :' ||l_message);
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSE
      IF (G_IS_DEBUG_STATEMENT_ON = true)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updated cure amounts table ');
      END IF;
    END IF;

  END LOOP;
  FND_MSG_PUB.initialize;

  FND_MSG_PUB.Count_And_Get
        (  p_count          =>   x_msg_count,
           p_data           =>   x_msg_data
        );

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                            , G_MODULE
                            ,' End of Procedure => OKL_PAY_RECON_PVT.UPDATE_CAM');

  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CAM : END ');

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_CAM;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_CAM;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_CAM;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','UPDATE_CAM');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_CAM;

PROCEDURE  UPDATE_INVOICE_HDR_LINES
                          (p_negotiated_amount IN NUMBER,
                           p_tai_id            IN NUMBER,
                           p_trx_status        IN VARCHAR2,
                           p_invoice_date      IN DATE,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2) IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count       NUMBER ;
l_msg_data        VARCHAR2(32627);
l_message         VARCHAR2(32627);
l_api_name        CONSTANT VARCHAR2(50) := 'UPDATE_INVOICE_HDR_LINES';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;

CURSOR c_get_obj_ver ( p_tai_id IN NUMBER)
IS
SELECT object_version_number
FROM   okl_trx_ar_invoices_b
WHERE  id = p_tai_id;

CURSOR c_get_til_obj_ver ( p_tai_id IN NUMBER)
IS
SELECT object_version_number,id
FROM   okl_txl_ar_inv_lns_b
WHERE  tai_id = p_tai_id;

CURSOR c_get_txd_obj_ver ( p_til_id_details IN NUMBER)
IS
SELECT object_version_number,id
FROM   OKL_TXD_AR_LN_DTLS_b
WHERE  til_id_details = p_til_id_details;

lp_taiv_rec          okl_tai_pvt.taiv_rec_type;
xp_taiv_rec          okl_tai_pvt.taiv_rec_type;
lp_tilv_rec          okl_til_pvt.tilv_rec_type;
xp_tilv_rec          okl_til_pvt.tilv_rec_type;
lp_tldv_rec          okl_tld_pvt.tldv_rec_type;
xp_tldv_rec          okl_tld_pvt.tldv_rec_type;

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : START ');
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : p_tai_id : '||p_tai_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : p_trx_status : '||p_trx_status);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : p_invoice_date : '||p_invoice_date);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : p_negotiated_amount : '||p_negotiated_amount);

  SAVEPOINT UPDATE_INVOICE_HDR_LINES;

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                            , G_MODULE
                            , 'start UPDATE_INVOICE_HDR_LINES');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- update okl_trx__ar_invoices_b set error message,so this will be prefixed before
  -- the actual message, so it makes more sense than displaying an OKL message.
  AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES ',
                  p_operation =>  'UPDATE' );


  OPEN  c_get_obj_ver(p_tai_id);
  FETCH c_get_obj_ver INTO lp_taiv_rec.object_version_number;
  CLOSE c_get_obj_ver;

  lp_taiv_rec.id              := p_tai_id;
  lp_taiv_rec.date_entered    := SYSDATE;
  lp_taiv_rec.date_invoiced   := p_invoice_date;
  lp_taiv_rec.amount          := p_negotiated_amount;
  lp_taiv_rec.trx_status_code := p_trx_status;

  -- Following is new as per Ashim's instructions
  lp_taiv_rec.okl_source_billing_trx := 'CURE';
  lp_taiv_rec.set_of_books_id        := okl_accounting_util.get_set_of_books_id;
  lp_taiv_rec.tax_exempt_flag := 'S';
  lp_taiv_rec.tax_exempt_reason_code := NULL;


  okl_trx_ar_invoices_pub.update_trx_ar_invoices
                     (p_api_version     => 1.0,
                      p_init_msg_list   => 'F',
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_taiv_rec        => lp_taiv_rec,
                      x_taiv_rec        => xp_taiv_rec);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : okl_trx_ar_invoices_pub.update_trx_ar_invoices : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'Error in updating okl_trx_ar_invoices_b '||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  ELSE
    FND_MSG_PUB.initialize;
    -- update okl_txl_ar_inv_lns set error message,so this will be prefixed before
    -- the actual message, so it makes more sense than displaying an OKL message.

    AddfailMsg(
                  p_object    =>  'RECORD IN  OKL_TXL_AR_INV_LNS ',
                  p_operation =>  'UPDATE' );

    OPEN  c_get_til_obj_ver(p_tai_id);
    FETCH c_get_til_obj_ver
    INTO lp_tilv_rec.object_version_number,
         lp_tilv_rec.id;
    CLOSE c_get_til_obj_ver;

    lp_tilv_rec.amount         :=p_negotiated_amount;

    okl_txl_ar_inv_lns_pub.update_txl_ar_inv_lns
                     (p_api_version     => 1.0,
                      p_init_msg_list   => 'F',
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_tilv_rec        => lp_tilv_rec,
                      x_tilv_rec        => xp_tilv_rec);

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : okl_txl_ar_inv_lns_pub.update_txl_ar_inv_lns : '||l_return_status);

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      Get_Messages (l_msg_count,l_message);
      IF (G_IS_DEBUG_STATEMENT_ON = true)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                                , G_MODULE
                                ,'Error in updating okl_txl_ar_inv_lns '||l_message);
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSE
      FND_MSG_PUB.initialize;
        -- R12 CHANGE- START
      AddfailMsg(
                  p_object    =>  'RECORD IN  OKL_TXL_AR_LN_DTLS ',
                  p_operation =>  'UPDATE' );

      OPEN  c_get_txd_obj_ver(lp_tilv_rec.id);
      FETCH c_get_txd_obj_ver
      INTO  lp_tldv_rec.object_version_number,
            lp_tldv_rec.id;
      CLOSE c_get_txd_obj_ver;

      lp_tldv_rec.amount         :=p_negotiated_amount;

      okl_tld_pvt.update_row(
               p_api_version          =>  1.0,
               p_init_msg_list        =>  'F',
               x_return_status        =>  l_return_status,
               x_msg_count            =>  x_msg_count,
               x_msg_data             =>  x_msg_data,
               p_tldv_rec             =>  lp_tldv_rec,
               x_tldv_rec             =>  xp_tldv_rec);

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : okl_tld_pvt.update_row : '||l_return_status);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS)
      THEN
        IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR)
        THEN
          x_return_status := l_return_status;
        END IF;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      ELSE
        FND_MSG_PUB.initialize;
      END IF; -- for okl_tld_pvt

      -- R12 CHANGE- END

    END IF; -- for okl_txl_ar_inv_lns

  END IF; -- for okl_trx_ar_invoices

  FND_MSG_PUB.Count_And_Get
         (  p_count          =>   x_msg_count,
           p_data            =>   x_msg_data
         );

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                            , G_MODULE
                            ,' End of Procedure => OKL_PAY_RECON_PVT.UPDATE_INVOICE_HDR_LINES');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICE_HDR_LINES : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR
  THEN
    ROLLBACK TO UPDATE_INVOICE_HDR_LINES;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO UPDATE_INVOICE_HDR_LINES;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS
  THEN
    ROLLBACK TO UPDATE_INVOICE_HDR_LINES;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','UPDATE_INVOICE_HDR_LINES');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END update_invoice_hdr_lines;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : additional_tld_attr
-- Description     : Internal procedure to add additional columns for
--                   OKL_TXD_AR_LN_DTLS_B
-- Important Note  : This procedure taken from BPD package on Ashim's advise
-- Business Rules  :
-- Parameters      :
--
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
PROCEDURE additional_tld_attr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_tldv_rec                     IN okl_tld_pvt.tldv_rec_type
   ,x_tldv_rec                     OUT NOCOPY okl_tld_pvt.tldv_rec_type )
IS
l_api_name         CONSTANT VARCHAR2(30) := 'additional_tld_attr';
l_api_version      CONSTANT NUMBER       := 1.0;
l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

-- Get currency attributes
CURSOR l_curr_csr(p_khr_id number) IS
SELECT c.minimum_accountable_unit,
       c.PRECISION
FROM   fnd_currencies c,
       okl_trx_ar_invoices_b b
WHERE  c.currency_code = b.currency_code
AND    b.khr_id = p_khr_id;

l_min_acct_unit fnd_currencies.minimum_accountable_unit%TYPE;
l_precision fnd_currencies.PRECISION %TYPE;
l_rounded_amount OKL_TXD_AR_LN_DTLS_B.amount%TYPE;

-- to get inventory_org_id  bug 4890024 begin
CURSOR inv_org_id_csr(p_contract_id NUMBER) IS
SELECT NVL(inv_organization_id,   -99)
FROM okc_k_headers_b
WHERE id = p_contract_id;

BEGIN
  -- Set API savepoint
  SAVEPOINT additional_tld_attr;
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  --Print Input Variables
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_tldv_rec.id :'||p_tldv_rec.id);
  END IF;
  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list))
  THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


  /*** Begin API body ****************************************************/
  -- assign all passed in attributes from IN to OUT record
  x_tldv_rec := p_tldv_rec;
  /* For R12, okl_arfetch_pub is absolete, so the following logic won't work
  since the receivable_invoice_id is null
      --For Credit Memo Processing
      IF p_tldv_rec.tld_id_reverses IS NOT NULL THEN
        -- Null out variables
        l_recv_inv_id := NULL;

        OPEN reverse_csr1(p_tldv_rec.tld_id_reverses);
        FETCH reverse_csr1
        INTO l_recv_inv_id;
        CLOSE reverse_csr1;
        x_tldv_rec.reference_line_id := l_recv_inv_id;
      ELSE
        x_tldv_rec.reference_line_id := NULL;
      END IF;

      x_tldv_rec.receivables_invoice_id := NULL;
      -- Populated later by fetch
*/

  IF(p_tldv_rec.inventory_org_id IS NULL)
  THEN
    OPEN  inv_org_id_csr(p_tldv_rec.khr_id);
    FETCH inv_org_id_csr
    INTO  x_tldv_rec.inventory_org_id;
    CLOSE inv_org_id_csr;
  ELSE
    x_tldv_rec.inventory_org_id := p_tldv_rec.inventory_org_id;
  END IF;

  -- Bug 4890024 end
  -------- Rounded Amount --------------
  l_rounded_amount := NULL;
  l_min_acct_unit := NULL;
  l_precision := NULL;

  OPEN  l_curr_csr(p_tldv_rec.khr_id);
  FETCH l_curr_csr
  INTO  l_min_acct_unit,
        l_precision;
  CLOSE l_curr_csr;

  IF(NVL(l_min_acct_unit,   0) <> 0)
  THEN
    -- Round the amount to the nearest Min Accountable Unit
    l_rounded_amount := ROUND(p_tldv_rec.amount / l_min_acct_unit) * l_min_acct_unit;
  ELSE
    -- Round the amount to the nearest precision
    l_rounded_amount := ROUND(p_tldv_rec.amount,   l_precision);
  END IF;

  -------- Rounded Amount --------------
  x_tldv_rec.amount := l_rounded_amount;
  --TIL
  /*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO additional_tld_attr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO additional_tld_attr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO additional_tld_attr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end additional_tld_attr;

PROCEDURE  INSERT_INVOICE_HDR_LINES
                          (p_negotiated_amount IN NUMBER,
                           p_cam_id            IN NUMBER,
                           p_trx_status        IN VARCHAR2,
                           p_invoice_date      IN DATE,
                           x_return_status     OUT NOCOPY VARCHAR2,
                           x_msg_count         OUT NOCOPY NUMBER,
                           x_msg_data          OUT NOCOPY VARCHAR2) IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'INSERT_INVOICE_HDR_LINES';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;

lp_taiv_rec          okl_tai_pvt.taiv_rec_type;
xp_taiv_rec          okl_tai_pvt.taiv_rec_type;
lp_tilv_rec          okl_til_pvt.tilv_rec_type;
xp_tilv_rec          okl_til_pvt.tilv_rec_type;
lp_tldv_rec          okl_tld_pvt.tldv_rec_type;
xp_tldv_rec          okl_tld_pvt.tldv_rec_type;

-- R12 Change - START
-- added contract header table to extract additional parameters to
-- populate invoice headers table. Otherwise it is not transferring to AR.
-- vdamerla Fix issue where the cure streams are not being processed by
--  BPD Billing programs
-- vdamerla added additional column chr.authoring_org_id

CURSOR c_get_khr_id ( p_cam_id IN NUMBER )
IS
SELECT  cam.chr_id               chr_id
       ,chr.currency_code        currency_code
       ,chr.conversion_type      conversion_type
       ,chr.conversion_rate      conversion_rate
       ,chr.conversion_rate_date conversion_rate_date
       ,chr.authoring_org_id     org_id
FROM    okl_cure_amounts         cam
       ,okc_k_headers_b          chr
WHERE   chr.id                 = cam.chr_id
AND     cam.cure_amount_id     = p_cam_id;

-- vdamerla Fix issue where the cure streams are not being processed by
--  BPD Billing programs
-- vdamerla added cursor to get the cust_trx_type_id
CURSOR ra_cust_csr
  IS
  SELECT cust_trx_type_id l_cust_trx_type_id
  FROM   ra_cust_trx_types
  WHERE  name = 'Invoice-OKL';

-- R12 Change - END

CURSOR get_trx_id IS
SELECT  id FROM okl_trx_types_tl
WHERE   name = 'Billing' AND   language = 'US';

l_khr_id NUMBER;
x_primary_sty_id number;

CURSOR	l_rcpt_mthd_csr (cp_cust_rct_mthd IN NUMBER) IS
		SELECT	c.receipt_method_id
		FROM	ra_cust_receipt_methods  c
		WHERE	c.cust_receipt_method_id = cp_cust_rct_mthd;

CURSOR	l_site_use_csr (
			cp_site_use_id		IN NUMBER,
			cp_site_use_code	IN VARCHAR2) IS
SELECT	a.cust_account_id	cust_account_id,
			a.cust_acct_site_id	cust_acct_site_id,
			a.payment_term_id	payment_term_id
FROM    okx_cust_site_uses_v	a,
		okx_customer_accounts_v	c
WHERE	a.id1			= cp_site_use_id
		AND	a.site_use_code		= cp_site_use_code
		AND	c.id1			= a.cust_account_id;

l_site_use_rec	 l_site_use_csr%ROWTYPE;

CURSOR	l_std_terms_csr (
		cp_cust_id		IN NUMBER,
		cp_site_use_id		IN NUMBER) IS
SELECT	c.standard_terms	standard_terms
FROM	hz_customer_profiles	c
WHERE	c.cust_account_id	= cp_cust_id
        AND	c.site_use_id		= cp_site_use_id
		UNION
		SELECT	c1.standard_terms	standard_terms
		FROM	hz_customer_profiles	c1
		WHERE	c1.cust_account_id	= cp_cust_id
		AND	c1.site_use_id		IS NULL
		AND	NOT EXISTS (
			SELECT	'1'
			FROM	hz_customer_profiles	c2
			WHERE	c2.cust_account_id	= cp_cust_id
			AND	c2.site_use_id		= cp_site_use_id);



  -- Code segment for Customer Account/bill to address
  -- as mentioned in OKC Rules Migration HLD
  -- Start

  CURSOR bill_to_csr (p_program_id IN NUMBER) IS
   select BILL_TO_SITE_USE_ID
   from okc_k_party_roles_v
   where dnz_chr_id = p_program_id
   and RLE_CODE ='OKL_VENDOR';

  -- Code segment for Customer Account/bill to address
  -- as mentioned in OKC Rules Migration HLD
  -- End


cursor c_program_id (p_contract_id IN NUMBER ) IS
select khr_id from okl_k_headers where id= p_contract_id;


l_program_id okl_k_headers.khr_id%TYPE;

l_id1           VARCHAR2(40)  :=NULL;
l_id2           VARCHAR2(200) :=NULL;
l_rule_value    VARCHAR2(2000):=NULL;


l_btc_id        NUMBER;
l_bill_to_address_id NUMBER;

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : START ');
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : p_cam_id : '||p_cam_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : p_trx_status : '||p_trx_status);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : p_invoice_date : '||p_invoice_date);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : p_negotiated_amount : '||p_negotiated_amount);

  SAVEPOINT INSERT_INVOICE_HDR_LINES;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                            , G_MODULE
                            , 'start INSERT_INVOICE_HDR_LINES');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --INSERT okl_trx_ar_invoices_b set error message,so this will be prefixed before
  --the actual message, so it makes more sense than displaying an OKL message.
  AddfailMsg(
                  p_object    =>  'RECORD IN OKL_TRX_AR_INVOICES ',
                  p_operation =>  'INSERT' );
  OPEN  c_get_khr_id(p_cam_id);

-- vdamerla Fix issue where the cure streams are not being processed by
--  BPD Billing programs
-- vdamerla modifed the FETCH to store the org_id
  FETCH c_get_khr_id INTO   lp_taiv_rec.khr_id
                           ,lp_taiv_rec.currency_code
                           ,lp_taiv_rec.currency_conversion_type
                           ,lp_taiv_rec.currency_conversion_rate
                           ,lp_taiv_rec.currency_conversion_date
                           ,lp_taiv_rec.org_id;
  CLOSE c_get_khr_id;

  -- vdamerla Fix issue where the cure streams are not being processed by
  --  BPD Billing programs
  -- vdamerla   begin: added the code to get the currency conversion details

  --Check for currency code

  IF(lp_taiv_rec.currency_conversion_type = 'User') THEN

    IF(lp_taiv_rec.currency_code = Okl_Accounting_Util.get_func_curr_code) THEN
       lp_taiv_rec.currency_conversion_rate := 1;
    END IF;

  ELSE
    lp_taiv_rec.currency_conversion_rate := NULL;
  END IF;


  IF(lp_taiv_rec.currency_conversion_type IS NULL OR lp_taiv_rec.currency_conversion_date = OKL_API.G_MISS_DATE) THEN
     lp_taiv_rec.currency_conversion_type := 'User';
     lp_taiv_rec.currency_conversion_rate := 1;
     lp_taiv_rec.currency_conversion_date := SYSDATE;
  END IF;

  -- vdamerla   end: added the code to get the currency conversion details

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.khr_id : '||lp_taiv_rec.khr_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.currency_code : '||lp_taiv_rec.currency_code);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.currency_conversion_type : '||lp_taiv_rec.currency_conversion_type);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.currency_conversion_rate : '||lp_taiv_rec.currency_conversion_rate);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.currency_conversion_date : '||lp_taiv_rec.currency_conversion_date);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.org_id : '||lp_taiv_rec.org_id);

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'khrid '||lp_taiv_rec.khr_id);
  END IF;

  IF lp_taiv_rec.khr_id IS NULL
  THEN
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> G_REQUIRED_VALUE,
                         p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Contract Id');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN get_trx_id;
  FETCH get_trx_id INTO lp_taiv_rec.try_id;
  CLOSE get_trx_id;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.try_id : '||lp_taiv_rec.try_id);

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'trxid '||lp_taiv_rec.try_id);
  END IF;

  IF lp_taiv_rec.try_id IS NULL
  THEN
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> G_REQUIRED_VALUE,
			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Transaction Type');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_khr_id := lp_taiv_rec.khr_id;

  OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id => l_khr_id,
    			p_primary_sty_purpose => 'CURE',
    			x_return_status => x_return_status,
    			x_primary_sty_id => x_primary_sty_id);

  lp_tilv_rec.sty_id  := x_primary_sty_id;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_tilv_rec.sty_id : '||lp_tilv_rec.sty_id);

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'sty_id '||lp_tilv_rec.sty_id);
  END IF;

  IF lp_tilv_rec.sty_id IS NULL
  THEN
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> G_REQUIRED_VALUE,
			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Sty Id');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- need to  populate 4 fields. so that cure invoice gets generated for vendor
  -- and not for the customer ibt_id,ixx_id,irm_id,irt_id get cust_account from
  -- rule vendor billing set up

  OPEN  c_program_id(lp_taiv_rec.khr_id);
  FETCH c_program_id INTO l_program_id;
  CLOSE c_program_id;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : l_program_id : '||l_program_id);

  IF l_program_id IS NULL
  THEN
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> G_REQUIRED_VALUE,
			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Vendor Program');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'program Id' ||l_program_id);
  END IF;

  -- New code for bill to address START
  OPEN bill_to_csr (l_program_id);
  FETCH bill_to_csr INTO l_bill_to_address_id;
  CLOSE bill_to_csr;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : l_bill_to_address_id : '||l_bill_to_address_id);

  IF trunc(l_bill_to_address_id) IS NULL
  THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Retrieval of Bill To Address Id failed');
    END IF;
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> 'OKL_REQUIRED_VALUE',
			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Bill To Address Id');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_btc_id :=l_bill_to_address_id;

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Bill to address id from rule is  ' || l_btc_id);
  END IF;

  -- *****************************************************
  -- Extract Customer, Bill To and Payment Term from rules
  -- *****************************************************

  OPEN	l_site_use_csr (l_btc_id, 'BILL_TO');
  FETCH	l_site_use_csr INTO l_site_use_rec;
  CLOSE	l_site_use_csr;

  lp_taiv_rec.ibt_id	:= l_site_use_rec.cust_acct_site_id;
  lp_taiv_rec.ixx_id	:= l_site_use_rec.cust_account_id;
  lp_taiv_rec.irt_id	:= l_site_use_rec.payment_term_id;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.ibt_id : '||lp_taiv_rec.ibt_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.ixx_id : '||lp_taiv_rec.ixx_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.irt_id : '||lp_taiv_rec.irt_id);

  IF lp_taiv_rec.irt_id IS NULL OR lp_taiv_rec.irt_id = FND_API.G_MISS_NUM
  THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'value of irt' ||lp_taiv_rec.irt_id);
    END IF;
    OPEN  l_std_terms_csr ( l_site_use_rec.cust_account_id,
			   l_btc_id);
    FETCH l_std_terms_csr
    INTO lp_taiv_rec.irt_id;
    CLOSE	l_std_terms_csr;
  END IF;

  IF lp_taiv_rec.ixx_id IS NULL	OR lp_taiv_rec.ixx_id = FND_API.G_MISS_NUM
  THEN
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> G_REQUIRED_VALUE,
                         p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Customer Account Id');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF lp_taiv_rec.ibt_id IS NULL OR lp_taiv_rec.ibt_id = FND_API.G_MISS_NUM
  THEN
    OKL_API.SET_MESSAGE (p_app_name	   => 'OKL',
			 p_msg_name	   => G_REQUIRED_VALUE,
			 p_token1	   => 'COL_NAME',
			 p_token1_value => 'Bill To Address Id');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'value of irt--->' ||lp_taiv_rec.irt_id);
  END IF;

  IF lp_taiv_rec.irt_id IS NULL OR lp_taiv_rec.irt_id = FND_API.G_MISS_NUM
  THEN
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> G_REQUIRED_VALUE,
 			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Payment Term Id');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_rule_value := NULL;
  l_id1        := NULL;
  l_id2        := NULL;

  l_return_status := okl_contract_info.get_rule_value(
                            p_contract_id      => l_program_id
                            ,p_rule_group_code => 'LAVENB'
                            ,p_rule_code	     => 'LAPMTH'
                            ,p_segment_number  => 16
                            ,x_id1             => l_id1
                            ,x_id2             => l_id2
                            ,x_value           => l_rule_value);

  IF l_return_status =FND_Api.G_RET_STS_SUCCESS AND l_id1 IS NOT NULL
  THEN
    lp_taiv_rec.irm_id :=l_id1;
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Payment method from rule is  ' || l_id1);
    END IF;
  ELSE
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Retrieval of Payment Method Id failed');
    END IF;
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
                         p_msg_name	=> 'OKL_REQUIRED_VALUE',
			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'Payment Method ');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN	l_rcpt_mthd_csr (l_id1);
  FETCH	l_rcpt_mthd_csr INTO lp_taiv_rec.irm_id;
  CLOSE	l_rcpt_mthd_csr;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.irm_id : '||lp_taiv_rec.irm_id);

  IF lp_taiv_rec.irm_id IS NULL OR lp_taiv_rec.irm_id = FND_API.G_MISS_NUM
  THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'receipt method id is not found');
    END IF;
    OKL_API.SET_MESSAGE (p_app_name	=> 'OKL',
			 p_msg_name	=> 'OKL_REQUIRED_VALUE',
			 p_token1	=> 'COL_NAME',
			 p_token1_value	=> 'receipt method id ');
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  lp_taiv_rec.object_version_number :=1;
  lp_taiv_rec.date_entered    :=SYSDATE;
  lp_taiv_rec.date_invoiced   :=p_invoice_date;
  lp_taiv_rec.amount          :=p_negotiated_amount;
  lp_taiv_rec.description     := 'Cure Invoice';
  lp_taiv_rec.trx_status_code :=p_trx_status;
  lp_taiv_rec.cpy_id          :=p_cam_id;
  lp_taiv_rec.legal_entity_id :=OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_khr_id => lp_taiv_rec.khr_id);

  -- R12 Changes - START
  -- Following is new as per Ashim's instructions
  lp_taiv_rec.okl_source_billing_trx := 'CURE';
  lp_taiv_rec.set_of_books_id        := okl_accounting_util.get_set_of_books_id;

  lp_taiv_rec.tax_exempt_flag := 'S';
  lp_taiv_rec.tax_exempt_reason_code := NULL;

  open ra_cust_csr;
  fetch ra_cust_csr into lp_taiv_rec.cust_trx_type_id;
  close ra_cust_csr;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : lp_taiv_rec.cust_trx_type_id : '||lp_taiv_rec.cust_trx_type_id);
  -- R12 Changes - END

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            'taiv_rec.cpy_id' ||lp_taiv_rec.cpy_id ||
                            ' taiv_rec.try_id' ||lp_taiv_rec.try_id||
                            ' taiv_rec.khr_id' ||lp_taiv_rec.khr_id||
                            ' taiv_rec.irm_id'||lp_taiv_rec.irm_id||
                            ' taiv_rec.ibt_id'||lp_taiv_rec.ibt_id||
                            ' taiv_rec.ixx_id '||lp_taiv_rec.ixx_id||
                            ' taiv_rec.legal_entity_id '||lp_taiv_rec.legal_entity_id||
                            ' taiv_rec.irt_id'||lp_taiv_rec.irt_id);
  END IF;

  okl_trx_ar_invoices_pub.INSERT_trx_ar_invoices
                     (p_api_version     => 1.0,
                      p_init_msg_list   => 'F',
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_taiv_rec        => lp_taiv_rec,
                      x_taiv_rec        => xp_taiv_rec);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : okl_trx_ar_invoices_pub.INSERT_trx_ar_invoices : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in updating okl_trx_ar_invoices_b '||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  ELSE
    FND_MSG_PUB.initialize;

    --INSERT okl_txl_ar_inv_lns set error message,so this will be prefixed before
    --the actual message, so it makes more sense than displaying an OKL message.

    AddfailMsg(   p_object    =>  'RECORD IN  OKL_TXL_AR_INV_LNS ',
                  p_operation =>  'INSERT' );
    lp_tilv_rec.amount                :=p_negotiated_amount;
    lp_tilv_rec.object_version_number :=1;
    lp_tilv_rec.tai_id                :=xp_taiv_rec.id;
    lp_tilv_rec.description           :='Cure Invoice';
    lp_tilv_rec.inv_receiv_line_code  :='LINE';
    lp_tilv_rec.line_number           :=1; -- TXL_AR_LINE_NUMBER

    -- R12 Change - START
    -- Following is new as per Ashim's instructions
    lp_tilv_rec.txl_ar_line_number    :=1;
    -- R12 Change - END

    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'tilv_rec.tai_id' ||lp_tilv_rec.tai_id||
                              'tilv_rec.amount' ||lp_tilv_rec.amount||
                               'tilv_rec.sty_id' ||lp_tilv_rec.sty_id);
    END IF;
    okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns
                     (p_api_version     => 1.0,
                      p_init_msg_list   => 'F',
                      x_return_status   => l_return_status,
                      x_msg_count       => l_msg_count,
                      x_msg_data        => l_msg_data,
                      p_tilv_rec        => lp_tilv_rec,
                      x_tilv_rec        => xp_tilv_rec);

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : okl_txl_ar_inv_lns_pub.insert_txl_ar_inv_lns : '||l_return_status);

    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      Get_Messages (l_msg_count,l_message);
      IF (G_IS_DEBUG_STATEMENT_ON = true)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'Error in updating okl_txl_ar_inv_lns '||l_message);
      END IF;
      raise FND_API.G_EXC_ERROR;
    ELSE
      FND_MSG_PUB.initialize;

      -- R12 Change - START
      -- Ashim's instructions for TXD table
      -- populate sty_id, kle_id(NULL), khr_id, amount, til_id_details, txl_ar_line_number
      AddfailMsg( p_object    =>  'RECORD IN  OKL_TXD_AR_LN_DTLS ',
                  p_operation =>  'INSERT' );

      lp_tldv_rec.TIL_ID_DETAILS     := xp_tilv_rec.id;
      lp_tldv_rec.STY_ID             := xp_tilv_rec.STY_ID;
      lp_tldv_rec.AMOUNT             := xp_tilv_rec.AMOUNT;
      lp_tldv_rec.ORG_ID             := xp_tilv_rec.ORG_ID;
      lp_tldv_rec.INVENTORY_ORG_ID   := xp_tilv_rec.INVENTORY_ORG_ID;
      lp_tldv_rec.INVENTORY_ITEM_ID  := xp_tilv_rec.INVENTORY_ITEM_ID;
      lp_tldv_rec.LINE_DETAIL_NUMBER := 1;
      lp_tldv_rec.KHR_ID             := lp_taiv_rec.KHR_ID;
      lp_tldv_rec.txl_ar_line_number :=1;

      okl_internal_billing_pvt.Get_Invoice_format(
             p_api_version                  => 1.0
            ,p_init_msg_list                => OKL_API.G_FALSE
            ,x_return_status                => l_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data
            ,p_inf_id                       => lp_taiv_rec.inf_id
            ,p_sty_id                       => lp_tldv_rec.STY_ID
            ,x_invoice_format_type          => lp_tldv_rec.invoice_format_type
            ,x_invoice_format_line_type     => lp_tldv_rec.invoice_format_line_type);

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : okl_internal_billing_pvt.Get_Invoice_format : '||l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      additional_tld_attr(
            p_api_version         => 1.0,
            p_init_msg_list       => OKL_API.G_FALSE,
            x_return_status       => l_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_tldv_rec            => lp_tldv_rec,
            x_tldv_rec            => xp_tldv_rec);

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : additional_tld_attr : '||l_return_status);

      lp_tldv_rec := xp_tldv_rec;

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS)
      THEN
        IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR)
        THEN
          x_return_status := l_return_status;
        END IF;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      okl_tld_pvt.insert_row(
            p_api_version          =>  1.0,
            p_init_msg_list        =>  OKL_API.G_FALSE,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  x_msg_count,
            x_msg_data             =>  x_msg_data,
            p_tldv_rec             =>  lp_tldv_rec,
            x_tldv_rec             =>  xp_tldv_rec);

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : okl_tld_pvt.insert_row : '||l_return_status);

      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS)
      THEN
        IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR)
        THEN
          x_return_status := l_return_status;
        END IF;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      ELSE
        FND_MSG_PUB.initialize;
      END IF; -- for okl_tld_pvt
      -- R12 Change - END

    END IF; -- for okl_txl_ar_inv_lns

  END IF; -- for okl_trx_ar_invoices

  FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                               p_data           =>   x_msg_data );

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                            , G_MODULE
                            ,' End of Procedure => OKL_PAY_RECON_PVT.INSERT_INVOICE_HDR_LINES');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : INSERT_INVOICE_HDR_LINES : END ');

EXCEPTION

   WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO INSERT_INVOICE_HDR_LINES;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INSERT_INVOICE_HDR_LINES;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO INSERT_INVOICE_HDR_LINES;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','INSERT_INVOICE_HDR_LINES');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END insert_invoice_hdr_lines;

PROCEDURE  TERMINATE_QUOTE
                           (
                             p_cam_id         IN NUMBER,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2) IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'TERMINATE_QUOTE';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;

cursor c_get_qte_id ( p_cam_id IN NUMBER ) is
select cam.qte_id,qte.date_effective_to
from okl_cure_amounts cam, okl_trx_quotes_b qte
where cam.cure_amount_id =p_cam_id
      and qte.id =cam.qte_id;

lp_term_rec OKL_AM_TERMNT_QUOTE_PUB.term_rec_type;
lx_term_rec OKL_AM_TERMNT_QUOTE_PUB.term_rec_type;
l_err_msg  VARCHAR2(2000);

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : TERMINATE_QUOTE : START ');

  SAVEPOINT TERMINATE_QUOTE;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start TERMINATE_QUOTE');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --set error message,so this will be prefixed before the actual message, so it
  --makes more sense than displaying an OKL message.
  AddfailMsg(     p_object    =>  'RECORD IN OKL_TRX_QUOTE_B ',
                  p_operation =>  'UPDATE' );

  OPEN  c_get_qte_id(p_cam_id);
  FETCH c_get_qte_id INTO lp_term_rec.id, lp_term_rec.date_effective_to;
  CLOSE c_get_qte_id;

  lp_term_rec.accepted_yn := 'Y';

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : TERMINATE_QUOTE : lp_term_rec.id : '||lp_term_rec.id);

  OKL_AM_TERMNT_QUOTE_PUB.TERMINATE_QUOTE(
                                  p_api_version    => 1.0
                                 ,p_init_msg_list  => 'T'
                                 ,x_return_status  => l_return_status
                                 ,x_msg_count      => l_msg_count
                                 ,x_msg_data       => l_msg_data
                                 ,p_term_rec       => lp_term_rec
                                 ,x_term_rec       => lx_term_rec
                                 ,x_err_msg        => l_err_msg);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : TERMINATE_QUOTE : OKL_AM_TERMNT_QUOTE_PUB.TERMINATE_QUOTE : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in updating okl_trx_ar_invoices_b '||l_message);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error from the API : ' ||l_err_msg);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                               p_data            =>   x_msg_data  );
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            ' End of Procedure =>OKL_PAY_RECON_PVT.TERMINATE_QUOTE');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : TERMINATE_QUOTE : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO TERMINATE_QUOTE;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO TERMINATE_QUOTE;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO TERMINATE_QUOTE;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','TERMINATE_QUOTE');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END TERMINATE_QUOTE;

PROCEDURE  UPDATE_TAI_TIL (p_cam_tbl        IN cure_amount_tbl,
                           p_invoice_date   IN DATE,
                           p_trx_status     IN VARCHAR2,
                           x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count      OUT NOCOPY NUMBER,
                           x_msg_data       OUT NOCOPY VARCHAR2) IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'UPDATE_TAI_TIL';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;

Cursor c_get_tai_id ( p_cam_id IN NUMBER) is
select id
from okl_trx_ar_invoices_b where
cpy_id =p_cam_id;

l_tai_id        	okl_trx_ar_invoices_b.id%TYPE;
l_process OKL_CURE_AMOUNTS.process%TYPE;
BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_TAI_TIL : START ');

  IF (G_DEBUG_ENABLED = 'Y')
  THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  SAVEPOINT UPDATE_TAI_TIL;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start UPDATE_TAI_TIL');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if cpy_id is populated then we will update the TAI  tables
  -- else do an insert in tai
  --09/24/03 -- Do the above only if the process ='CURE'
  -- else call Terminate Quote.

  FOR i in p_cam_tbl.FIRST..p_cam_tbl.LAST
  LOOP

    --11/26/03 if process is cure, the html screen does not
    -- have a drop down field
    --jsanju 11/26/03
    IF p_cam_tbl(i).process = 'REPURCHASE'
    THEN
      l_process :='REPURCHASE' ;
    ELSIF p_cam_tbl(i).process = 'DONOTPROCESS'
    THEN
      l_process :='DONOTPROCESS' ;
    ELSE
      l_process :='CURE';
    END IF;

    IF l_process ='CURE'
    THEN
      l_tai_id :=NULL;
      OPEN  c_get_tai_id(p_cam_tbl(i).cam_id);
      FETCH c_get_tai_id INTO l_tai_id;
      CLOSE c_get_tai_id;

      -- ASHIM CHANGE - START

      IF l_tai_id IS NOT NULL
      THEN
        update_invoice_hdr_lines (
                   p_negotiated_amount =>p_cam_tbl(i).negotiated_amount,
                   p_tai_id            =>l_tai_id,
                   p_trx_status        =>p_trx_status,
                   p_invoice_date      =>p_invoice_date,
                   x_return_status     =>l_return_status,
                   x_msg_count         =>l_msg_count,
                   x_msg_data          =>l_msg_data);
      ELSE
        insert_invoice_hdr_lines (
                   p_negotiated_amount =>p_cam_tbl(i).negotiated_amount,
                   p_cam_id            =>p_cam_tbl(i).cam_id,
                   p_trx_status        =>p_trx_status,
                   p_invoice_date      =>p_invoice_date,
                   x_return_status     =>l_return_status,
                   x_msg_count         =>l_msg_count,
                   x_msg_data          =>l_msg_data);

      END IF;

      -- ASHIM CHANGE - END

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        Get_Messages (l_msg_count,l_message);
        IF (G_IS_DEBUG_STATEMENT_ON = true)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'Error in update tai_til :' ||l_message);
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

      --if process is 'REPURCHASE
      --and if p_trx_status ='SUBMITTED' that means the action from the UI
      --is 'SUBMIT' , we do not call terminate quote if action is update
    ELSIF  l_process ='REPURCHASE'  AND p_trx_status ='SUBMITTED'
    THEN
      Terminate_quote (
                   p_cam_id            =>p_cam_tbl(i).cam_id,
                   x_return_status     =>l_return_status,
                   x_msg_count         =>l_msg_count,
                   x_msg_data          =>l_msg_data);

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        Get_Messages (l_msg_count,l_message);
        IF (G_IS_DEBUG_STATEMENT_ON = true)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'Error in Termination of Quote :' ||l_message);
        END IF;
        raise FND_API.G_EXC_ERROR;
      END IF;

    END IF; --if process is CURE

  END LOOP;

  FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                               p_data            =>   x_msg_data);

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            ' End of Procedure =>OKL_PAY_RECON_PVT.UPDATE_TAI_TIL');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_TAI_TIL : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_TAI_TIL;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_TAI_TIL;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_TAI_TIL;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','UPDATE_TAI_TIL');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_TAI_TIL;

PROCEDURE UPDATE_INVOICES (p_cam_tbl IN cure_amount_tbl,
                           p_report_id    IN NUMBER,
                           p_invoice_date IN DATE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2) IS
l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'UPDATE_INVOICES';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICES : START ');
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICES : p_report_id : '||p_report_id);
  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICES : p_invoice_date : '||p_invoice_date);

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  -- step 1 create TAI ab
  -- step 2 update CAM
  -- step 3 update CRT

  --09/24 --check the process type, if
  --1)CURE         -create TAI,updateCAM,updateCRT
  --2)REPURCHASE   -create quote,UpdateCAM,updateCRT
  --3)DONOTPROCESS - UpdateCAM,UpdateCRT

  SAVEPOINT UPDATE_INVOICES;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start UPDATE_INVOICES');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE_TAI_TIL(p_cam_tbl       =>p_cam_tbl,
                 p_invoice_date  =>p_invoice_date,
                 p_trx_status    =>'WORKING',
                 x_return_status =>l_return_status,
                 x_msg_count     =>l_msg_count,
                 x_msg_data      =>l_msg_data);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in updating cure amounts:'||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  UPDATE_CAM (p_cam_tbl       =>p_cam_tbl,
              p_report_id     =>p_report_id,
              x_return_status =>l_return_status,
              x_msg_count     =>l_msg_count,
              x_msg_data      =>l_msg_data);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in updating cure amounts:'||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  UPDATE_CRT (p_report_id     =>p_report_id,
              p_status        =>'ACCEPTANCE_IN_PROGRESS',
              x_return_status =>l_return_status,
              x_msg_count     =>l_msg_count,
              x_msg_data      =>l_msg_data);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error is :' ||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  ELSE
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updated cure reports table ');
    END IF;
  END IF;

  FND_MSG_PUB.Count_And_Get(  p_count          =>   x_msg_count,
                              p_data           =>   x_msg_data  );

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            ' End of Procedure =>OKL_PAY_RECON_PVT.update_invoices');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_INVOICES : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_INVOICES;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_INVOICES;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_INVOICES;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','UPDATE_INVOICES');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_INVOICES;

PROCEDURE CREATE_ACCOUNTING(p_cam_tbl      IN cure_amount_tbl,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2)
IS

    -- Cursors plucked from OKL_LA_JE_PVT for a/c - START
  CURSOR fnd_pro_csr
  IS
  SELECT mo_global.get_current_org_id() l_fnd_profile
  FROM   dual;

  fnd_pro_rec fnd_pro_csr%ROWTYPE;

  CURSOR ra_cust_csr
  IS
  SELECT cust_trx_type_id l_cust_trx_type_id
  FROM   ra_cust_trx_types
  WHERE  name = 'Invoice-OKL';

  ra_cust_rec ra_cust_csr%ROWTYPE;

  CURSOR salesP_csr (p_contract_id IN NUMBER)
  IS
  SELECT  ct.object1_id1           id
         ,chr.scs_code             scs_code
  FROM   okc_contacts              ct,
         okc_contact_sources       csrc,
         okc_k_party_roles_b       pty,
         okc_k_headers_b           chr
  WHERE  ct.cpl_id               = pty.id
  AND    ct.cro_code             = csrc.cro_code
  AND    ct.jtot_object1_code    = csrc.jtot_object_code
  AND    ct.dnz_chr_id           = chr.id
  AND    pty.rle_code            = csrc.rle_code
  AND    csrc.cro_code           = 'SALESPERSON'
  AND    csrc.rle_code           = 'LESSOR'
  AND    csrc.buy_or_sell        = chr.buy_or_sell
  AND    pty.dnz_chr_id          = chr.id
  AND    pty.chr_id              = chr.id
  AND    chr.id                  = p_contract_id;

  l_salesP_rec salesP_csr%ROWTYPE;

  CURSOR custBillTo_csr (p_contract_id IN NUMBER)
  IS
  SELECT bill_to_site_use_id cust_acct_site_id
  FROM   okc_k_headers_b
  WHERE  id = p_contract_id;

  l_custBillTo_rec custBillTo_csr%ROWTYPE;

  -- Cursors plucked from OKL_LA_JE_PVT for a/c - END


cursor c_get_contract_currency (l_khr_id IN NUMBER)
IS
select currency_code
from   OKC_K_HEADERS_b
where  id =l_khr_id;

CURSOR curr_csr (l_khr_id NUMBER)
IS
SELECT currency_conversion_type,
       currency_conversion_rate,
	 currency_conversion_date
FROM 	 okl_k_headers
WHERE  id = l_khr_id;

l_functional_currency         okl_trx_contracts.currency_code%TYPE;
l_currency_conversion_type	okl_k_headers.currency_conversion_type%TYPE;
l_currency_conversion_rate	okl_k_headers.currency_conversion_rate%TYPE;
l_currency_conversion_date	okl_k_headers.currency_conversion_date%TYPE;
l_contract_currency           OKC_K_HEADERS_b.currency_code%TYPE;

next_row                      integer;

CURSOR c_get_accounting(p_cam_id IN NUMBER)
IS
SELECT tai.id
       ,tai.try_id
       ,til.sty_id
       ,tld.id
       ,tai.khr_id
       ,tai.date_invoiced
       ,tai.amount
FROM   okl_trx_ar_invoices_b tai
       ,okl_txl_ar_inv_lns_b til
       ,okl_txd_ar_ln_dtls_b tld
WHERE  tai.cpy_id         = p_cam_id
AND    tai.id             = til.tai_id
AND    tld.til_id_details = til.id;

l_tai_id          okl_trx_ar_invoices_b.id%TYPE;
l_sty_id          okl_txl_ar_inv_lns_b.sty_id%TYPE;
l_try_id          okl_trx_ar_invoices_b.try_id%TYPE;
l_line_id         okl_txd_ar_ln_dtls_b.id%TYPE;
l_khr_id          okc_k_headers_b.id%TYPE;
l_date_invoiced   okl_trx_ar_invoices_b.date_invoiced%TYPE;
l_amount          okl_trx_ar_invoices_b.amount%TYPE;

CURSOR get_product_id(p_cam_id IN NUMBER)
IS
SELECT   okl.pdt_id
        ,okl.id
        ,okc.scs_code  -- Bug# 4622198
FROM    okl_k_headers    okl,
        okl_cure_amounts cam,
        okc_k_headers_b  okc -- Bug# 4622198
WHERE   okc.id = okl.id     -- Bug# 4622198
and     okl.id = cam.chr_id
and     cam.cure_amount_id =p_cam_id;

/* -- OKL.H Code commented out
l_tmpl_identify_rec          Okl_Account_Dist_Pvt.TMPL_IDENTIFY_REC_TYPE;
l_dist_info_rec              Okl_Account_Dist_Pvt.dist_info_REC_TYPE;
l_ctxt_val_tbl               okl_execute_formula_pvt.ctxt_val_tbl_type;
l_acc_gen_primary_key_tbl    Okl_Account_Generator_Pvt.primary_key_tbl;
l_template_tbl         	     Okl_Account_Dist_Pub.AVLV_TBL_TYPE;
l_amount_tbl         	     Okl_Account_Dist_Pub.AMOUNT_TBL_TYPE;
*/

-- R12 Change - START
l_tmpl_identify_tbl         okl_account_dist_pvt.tmpl_identify_tbl_type;
l_dist_info_tbl             okl_account_dist_pvt.dist_info_tbl_type;
l_template_tbl              okl_account_dist_pvt.avlv_out_tbl_type;
l_amount_tbl                okl_account_dist_pvt.amount_out_tbl_type;
l_ctxt_val_tbl              okl_account_dist_pvt.ctxt_tbl_type;
--l_acc_gen_primary_key_tbl   okl_account_dist_pvt.acc_gen_tbl_type;
l_acc_gen_primary_key_tbl   okl_account_dist_pvt.acc_gen_primary_key;
l_acc_gen_tbl               okl_account_dist_pvt.ACC_GEN_TBL_TYPE;
-- R12 Change - END

l_factoring_synd    VARCHAR2(30);
l_syndication_code  VARCHAR2(30) DEFAULT NULL;
l_factoring_code    VARCHAR2(30) DEFAULT NULL;
l_return_status	  VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count         NUMBER ;
l_msg_data          VARCHAR2(32627);
l_message           VARCHAR2(32627);
l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_ACCOUNTING';
l_api_name_full	  CONSTANT VARCHAR2(150):= g_pkg_name || '.'
                                                    || l_api_name;
l_process           OKL_CURE_AMOUNTS.process%TYPE;

--Bug# 4622198 :For special accounting treatment - START

l_fact_synd_code    FND_LOOKUPS.Lookup_code%TYPE;
l_inv_acct_code     OKC_RULES_B.Rule_Information1%TYPE;
l_scs_code          okc_k_headers_b.SCS_CODE%TYPE;

--Bug# 4622198 :For special accounting treatment - END

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : START ');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  SAVEPOINT CREATE_ACCOUNTING;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start submit_cure_invoices');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i in p_cam_tbl.FIRST..p_cam_tbl.LAST
  LOOP
    --11/26/03 if process is cure, the html screen does not
    -- have a drop down field
    --jsanju 11/26/03
    IF p_cam_tbl(i).process = 'REPURCHASE'
    THEN
      l_process :='REPURCHASE' ;
    ELSIF p_cam_tbl(i).process = 'DONOTPROCESS'
    THEN
      l_process :='DONOTPROCESS' ;
    ELSE
      l_process :='CURE';
    END IF;

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_process : '||l_process);

    IF l_process ='CURE'
    THEN
      OPEN  get_product_id(p_cam_tbl(i).cam_id);
      FETCH get_product_id
      INTO  l_tmpl_identify_tbl(1).product_id
            ,l_khr_id
            ,l_scs_code;
      CLOSE get_product_id;

      IF l_tmpl_identify_tbl(1).product_id IS NULL
      THEN
        OKL_API.SET_MESSAGE (p_app_name => 'OKL',
                             p_msg_name => 'OKL_NO_PRODUCT_FOUND');
        raise FND_API.G_EXC_ERROR;
      END IF;

      l_factoring_synd := get_factor_synd(l_khr_id);
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_factoring_synd : '||l_factoring_synd);

      OPEN  c_get_Accounting(p_cam_tbl(i).cam_id);
      FETCH c_get_Accounting
      INTO  l_tai_id
            ,l_try_id
            ,l_sty_id
            ,l_line_id
            ,l_khr_id
            ,l_date_invoiced
            ,l_amount;
      CLOSE c_get_Accounting;

      l_tmpl_identify_tbl(1).transaction_type_id  := l_try_id;
      l_tmpl_identify_tbl(1).stream_type_id       := l_sty_id;
      l_tmpl_identify_tbl(1).ADVANCE_ARREARS      := NULL;
      l_tmpl_identify_tbl(1).FACTORING_SYND_FLAG  := NULL;
      l_tmpl_identify_tbl(1).SYNDICATION_CODE     := NULL;
      l_tmpl_identify_tbl(1).FACTORING_CODE       := NULL;
      l_tmpl_identify_tbl(1).MEMO_YN              := 'N';
      l_tmpl_identify_tbl(1).PRIOR_YEAR_YN        := 'N';
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_tmpl_identify_tbl(1).transaction_type_id : '||l_tmpl_identify_tbl(1).transaction_type_id);
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_tmpl_identify_tbl(1).stream_type_id : '||l_tmpl_identify_tbl(1).stream_type_id);

      l_dist_info_tbl(1).source_id	          := l_line_id;
      l_dist_info_tbl(1).source_table	          := 'OKL_TXD_AR_LN_DTLS_B';
      l_dist_info_tbl(1).accounting_date	    := l_date_invoiced;
      l_dist_info_tbl(1).gl_reversal_flag	    :='N';
      l_dist_info_tbl(1).post_to_gl		    :='N';
      l_dist_info_tbl(1).contract_id		    :=l_khr_id;
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_dist_info_tbl(1).source_id : '||l_dist_info_tbl(1).source_id);
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_dist_info_tbl(1).source_table : '||l_dist_info_tbl(1).source_table);
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_dist_info_tbl(1).accounting_date : '||l_dist_info_tbl(1).accounting_date);
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_dist_info_tbl(1).contract_id : '||l_dist_info_tbl(1).contract_id);

      -- New Accounting call Start set accounting call required values
      -- Fetch the functional currency

      l_functional_currency := OKL_ACCOUNTING_UTIL.GET_FUNC_CURR_CODE;

      -- Fetch the currency conversion factors if functional currency is not equal
      -- to the transaction currency

      OPEN   c_get_contract_currency (l_khr_id);
      FETCH  c_get_contract_currency INTO l_contract_currency;
      CLOSE  c_get_contract_currency;

      l_dist_info_tbl(1).currency_code := l_contract_currency;

      IF l_functional_currency <> l_contract_currency
      THEN
        -- Fetch the currency conversion factors from Contracts
        FOR curr_rec IN curr_csr(l_khr_id)
        LOOP
          l_currency_conversion_type := curr_rec.currency_conversion_type;
          l_currency_conversion_rate := curr_rec.currency_conversion_rate;
          l_currency_conversion_date := curr_rec.currency_conversion_date;
        END LOOP;

        -- Fetch the currency conversion factors from GL_DAILY_RATES if the
        -- conversion type is not 'USER'.

        IF UPPER(l_currency_conversion_type) <> 'USER'
        THEN
          l_currency_conversion_date := SYSDATE;
          l_currency_conversion_rate := okl_accounting_util.get_curr_con_rate
                                         (p_from_curr_code => l_contract_currency,
       		                          p_to_curr_code => l_functional_currency,
             		                  p_con_date => l_currency_conversion_date,
  	                                  p_con_type => l_currency_conversion_type);

        END IF; -- End IF for (UPPER(l_currency_conversion_type) <> 'USER')

      END IF;  -- End IF for (l_functional_currency <> l_contract_currency)

      -- Populate the currency conversion factors
      l_dist_info_tbl(1).currency_conversion_type := l_currency_conversion_type;
      l_dist_info_tbl(1).currency_conversion_rate := l_currency_conversion_rate;
      l_dist_info_tbl(1).currency_conversion_date := l_currency_conversion_date;

      -- Round the transaction amount
      l_dist_info_tbl(1).amount:= okl_accounting_util.cross_currency_round_amount
   			(p_amount        => l_amount,
			 p_currency_code => l_contract_currency);

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_dist_info_tbl(1).amount : '||l_dist_info_tbl(1).amount);

      --set error message,so this will be prefixed before the
      --actual message, so it makes more sense than displaying an
      -- OKL message.
      -- R12 CHANGE- START
      /*
      --Do not know what this segment does. Hence commented out,
      --will enable if required during test run
      AddfailMsg( p_object    =>  'Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen ',
                  p_operation =>  'CREATE' );

      Okl_Acc_Call_Pvt.Okl_Populate_Acc_Gen (
           p_contract_id       => l_khr_id,
           p_contract_line_id  => NULL,
           x_acc_gen_tbl       => l_acc_gen_primary_key_tbl,
           x_return_status     => l_return_status   );

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        raise FND_API.G_EXC_ERROR;
      ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'l_acc_gen_primary_key_tbl'
                                   --||l_acc_gen_primary_key_tbl(1).count
                                   ||l_acc_gen_primary_key_tbl(1).primary_key_column
                                   ||l_acc_gen_primary_key_tbl(1).source_table );
        END IF;
        FND_MSG_PUB.initialize;
      END IF;
      */

      l_acc_gen_primary_key_tbl(1).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
      OPEN  fnd_pro_csr;
      FETCH fnd_pro_csr INTO fnd_pro_rec;
      IF ( fnd_pro_csr%NOTFOUND )
      THEN
        l_acc_gen_primary_key_tbl(1).primary_key_column := '';
      ELSE
        l_acc_gen_primary_key_tbl(1).primary_key_column := fnd_pro_rec.l_fnd_profile;
      End IF;
      CLOSE fnd_pro_csr;

      l_acc_gen_primary_key_tbl(2).source_table := 'AR_SITE_USES_V';
      OPEN  custBillTo_csr(l_khr_id);
      FETCH custBillTo_csr INTO l_custBillTo_rec;
      CLOSE custBillTo_csr;
      l_acc_gen_primary_key_tbl(2).primary_key_column := l_custBillTo_rec.cust_acct_site_id;

      l_acc_gen_primary_key_tbl(3).source_table := 'RA_CUST_TRX_TYPES';
      OPEN  ra_cust_csr;
      FETCH ra_cust_csr INTO ra_cust_rec;
      IF ( ra_cust_csr%NOTFOUND ) THEN
        l_acc_gen_primary_key_tbl(3).primary_key_column := '';
      ELSE
        l_acc_gen_primary_key_tbl(3).primary_key_column := TO_CHAR(ra_cust_rec.l_cust_trx_type_id);
      END IF;
      CLOSE ra_cust_csr;

      l_acc_gen_primary_key_tbl(4).source_table := 'JTF_RS_SALESREPS_MO_V';
      OPEN  salesP_csr(l_khr_id);
      FETCH salesP_csr INTO l_salesP_rec;
      CLOSE salesP_csr;
      l_acc_gen_primary_key_tbl(4).primary_key_column := l_salesP_rec.id;

      l_acc_gen_tbl(1).acc_gen_key_tbl            := l_acc_gen_primary_key_tbl;
      l_acc_gen_tbl(1).source_id                  := l_line_id;

      -- R12 CHANGE- END

      --set error message,so this will be prefixed before the
      --actual message, so it makes more sense than displaying an
      -- OKL message.
      AddfailMsg( p_object    =>  'OKL_SECURITIZATION_PVT.Check_Khr_ia_associated ',
                  p_operation =>  'CREATE' );

      --Bug# 4622198 :For special accounting treatment - START
      OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => OKL_API.G_FALSE,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_khr_id                  => l_khr_id,
                                  --p_scs_code                => l_scs_code,
                                  p_scs_code                => l_salesP_rec.scs_code,
                                  p_trx_date                => l_date_invoiced,
                                  x_fact_synd_code          => l_fact_synd_code,
                                  x_inv_acct_code           => l_inv_acct_code
                                  );

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : OKL_SECURITIZATION_PVT.Check_Khr_ia_associated : '||x_return_status);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)
      THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      l_tmpl_identify_tbl(1).factoring_synd_flag := l_fact_synd_code;
      l_tmpl_identify_tbl(1).investor_code       := l_inv_acct_code;
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_tmpl_identify_tbl(1).factoring_synd_flag : '||l_tmpl_identify_tbl(1).factoring_synd_flag);
      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : l_tmpl_identify_tbl(1).investor_code : '||l_tmpl_identify_tbl(1).investor_code);


      --Bug# 4622198 :For special accounting treatment - END

      --set error message,so this will be prefixed before the
      --actual message, so it makes more sense than displaying an
      -- OKL message.
      AddfailMsg( p_object    =>  'Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST ',
                  p_operation =>  'CREATE' );

      /* OKL.H code commented out
      Okl_Account_Dist_Pvt.CREATE_ACCOUNTING_DIST(
  	     p_api_version           => 1.0
           ,p_init_msg_list  	     => 'F'
           ,x_return_status  	     => l_return_status
           ,x_msg_count      	     => l_msg_count
           ,x_msg_data       	     => l_msg_data
           ,p_tmpl_identify_rec 	  => l_tmpl_identify_rec
           ,p_dist_info_rec           => l_dist_info_rec
           ,p_ctxt_val_tbl            => l_ctxt_val_tbl
           ,p_acc_gen_primary_key_tbl => l_acc_gen_primary_key_tbl
           ,x_template_tbl            => l_template_tbl
           ,x_amount_tbl              => l_amount_tbl);
      */

      -- R12 CHANGE - START
      okl_account_dist_pvt.create_accounting_dist(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => OKL_API.G_FALSE,
                                  x_return_status           => l_return_status,
                                  x_msg_count               => l_msg_count,
                                  x_msg_data                => l_msg_data,
                                  p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                  p_dist_info_tbl           => l_dist_info_tbl,
                                  p_ctxt_val_tbl            => l_ctxt_val_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl            => l_template_tbl,
                                  x_amount_tbl              => l_amount_tbl,
                                  p_trx_header_id           => l_tai_id,
                                  p_trx_header_table        => 'OKL_TRX_AR_INVOICES_B');

      okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : okl_account_dist_pvt.create_accounting_dist : '||l_return_status);

      -- R12 CHANGE - END

      IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        Get_Messages (l_msg_count,l_message);
        IF (G_IS_DEBUG_STATEMENT_ON = true)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error' ||l_message);
        END IF;
        raise FND_API.G_EXC_ERROR;
      ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'count of l_template_tbl'||l_template_tbl.count);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'count of l_amount_tbl'||l_amount_tbl.count);
        END IF;
        FND_MSG_PUB.initialize;
      END IF;
    END IF ;--  IF p.cam.tbl(i).Process ='CURE'
  END LOOP;

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            'after accounting dist '||l_return_status);
  END IF;

  FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                               p_data           =>   x_msg_data  );
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            ' End of Procedure =>OKL_PAY_RECON_PVT.CREATE_ACCOUNTING');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : CREATE_ACCOUNTING : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO CREATE_ACCOUNTING;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CREATE_ACCOUNTING;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO CREATE_ACCOUNTING;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','CREATE_ACCOUNTING');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END  CREATE_ACCOUNTING;

PROCEDURE SUBMIT_INVOICES (p_cam_tbl      IN cure_amount_tbl,
                           p_report_id    IN NUMBER,
                           p_invoice_date IN DATE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_msg_count     OUT NOCOPY NUMBER,
                           x_msg_data      OUT NOCOPY VARCHAR2)
IS

l_return_status	VARCHAR2(1)	:= FND_API.G_RET_STS_SUCCESS;
l_msg_count     NUMBER ;
l_msg_data      VARCHAR2(32627);
l_message       VARCHAR2(32627);
l_api_name      CONSTANT VARCHAR2(50) := 'SUBMIT_INVOICES';
l_api_name_full	CONSTANT VARCHAR2(150):= g_pkg_name || '.'|| l_api_name;

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : SUBMIT_INVOICES : START ');

  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  SAVEPOINT SUBMIT_INVOICES;
  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'start submit_cure_invoices');
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE_TAI_TIL(p_cam_tbl       =>p_cam_tbl,
                 p_invoice_date  =>p_invoice_date,
                 p_trx_status    =>'SUBMITTED',
                 x_return_status =>l_return_status,
                 x_msg_count     =>l_msg_count,
                 x_msg_data      =>l_msg_data);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : SUBMIT_INVOICES : UPDATE_TAI_TIL : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in updating cure amounts:'||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  CREATE_ACCOUNTING(p_cam_tbl       =>p_cam_tbl,
                    x_return_status =>l_return_status,
                    x_msg_count     =>l_msg_count,
                    x_msg_data      =>l_msg_data);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : SUBMIT_INVOICES : CREATE_ACCOUNTING : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in Creating distributions'||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  UPDATE_CAM (p_cam_tbl       =>p_cam_tbl,
              p_report_id     =>p_report_id,
              x_return_status =>l_return_status,
              x_msg_count     =>l_msg_count,
              x_msg_data      =>l_msg_data);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : SUBMIT_INVOICES : UPDATE_CAM : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                              G_MODULE,
                              'Error in updating cure amounts:'||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  END IF;

  UPDATE_CRT (p_report_id     =>p_report_id,
              p_status        =>'ACCEPTANCE_COMPLETED',
              x_return_status =>l_return_status,
              x_msg_count     =>l_msg_count,
              x_msg_data      =>l_msg_data);

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : SUBMIT_INVOICES : UPDATE_CRT : '||l_return_status);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error is :' ||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  ELSE
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Updated cure reports table ');
    END IF;
  END IF;

  FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                               p_data           =>   x_msg_data    );

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                          G_MODULE,
                          ' End of Procedure => OKL_PAY_RECON_PVT.submit_Cure_invoices');

  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : SUBMIT_INVOICES : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO SUBMIT_INVOICES;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO SUBMIT_INVOICES;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO SUBMIT_INVOICES;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_RECON_PVT','SUBMIT_INVOICES');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END SUBMIT_INVOICES;

PROCEDURE UPDATE_CURE_INVOICE (
                               p_api_version   IN NUMBER,
                               p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.G_FALSE,
                               p_commit        IN VARCHAR2 DEFAULT fnd_api.G_FALSE,
                               p_report_id     IN NUMBER,
                               p_invoice_date  IN DATE,
                               p_cam_tbl       IN cure_amount_tbl,
                               p_operation     IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2) IS

  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count          NUMBER;
  l_msg_data VARCHAR2(32627);
  l_message  VARCHAR2(32627);

BEGIN

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CURE_INVOICE : START ');

  IF (G_DEBUG_ENABLED = 'Y')
  THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

  SAVEPOINT UPDATE_CURE_INVOICE_PVT;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_operation ='UPDATE'
  THEN
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Operation is Update');
    END IF;
    Update_invoices (p_cam_tbl       =>p_cam_tbl,
                     p_report_id     =>p_report_id,
                     p_invoice_date  =>p_invoice_date,
                     x_return_status =>l_return_status,
                     x_msg_count     =>l_msg_count,
                     x_msg_data      =>l_msg_data);

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CURE_INVOICE : Update_invoices : '||l_return_status);

  ELSE
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Operation is Submit');
    END IF;
    submit_invoices(p_cam_tbl       =>p_cam_tbl,
                    p_report_id     =>p_report_id,
                    --p_invoice_date  =>SYSDATE,
                    p_invoice_date  =>p_invoice_date,
                    x_return_status =>l_return_status,
                    x_msg_count     =>l_msg_count,
                    x_msg_data      =>l_msg_data);

    okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CURE_INVOICE : submit_invoices : '||l_return_status);
  END IF;

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
    Get_Messages (l_msg_count,l_message);
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error is :' ||l_message);
    END IF;
    raise FND_API.G_EXC_ERROR;
  ELSE
    IF (G_IS_DEBUG_STATEMENT_ON = true)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoices updated');
    END IF;
  END IF;

  FND_MSG_PUB.Count_And_Get (  p_count          =>   x_msg_count,
                               p_data           =>   x_msg_data);

  IF (G_IS_DEBUG_STATEMENT_ON = true)
  THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                            G_MODULE,
                            ' End of Procedure => OKL_PAY_RECON_PVT.update_Cure_invoices');
  END IF;

  okl_debug_pub.logmessage('OKL_CURE_RECON_PVT : UPDATE_CURE_INVOICE : END ');

EXCEPTION
  WHEN Fnd_Api.G_EXC_ERROR THEN
    ROLLBACK TO UPDATE_CURE_INVOICE_PVT;
    x_return_status := Fnd_Api.G_RET_STS_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UPDATE_CURE_INVOICE_PVT;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO UPDATE_CURE_INVOICE_PVT;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_RECON_PVT','UPDATE_CURE_INVOICE');
    Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END UPDATE_CURE_INVOICE;

END OKL_CURE_RECON_PVT;

/
