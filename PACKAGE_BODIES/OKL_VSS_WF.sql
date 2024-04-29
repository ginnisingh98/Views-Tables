--------------------------------------------------------
--  DDL for Package Body OKL_VSS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VSS_WF" AS
/* $Header: OKLRVSWB.pls 120.4 2007/08/14 11:45:20 zrehman ship $ */


PROCEDURE raise_business_event (
                     p_khr_id   IN VARCHAR2,
                     p_kle_id   IN VARCHAR2,
                     p_qte_id   IN VARCHAR2,
                     p_requestor_id IN VARCHAR2)  IS


    l_parameter_list        WF_PARAMETER_LIST_T;
    l_key                   WF_ITEMS.item_key%TYPE;
    l_event_name            WF_EVENTS.NAME%TYPE := 'oracle.apps.okl.vss.requestrepquote';
    l_seq                   NUMBER;

    -- Cursor to get the value of the sequence
  	CURSOR okl_key_csr IS
  	SELECT okl_wf_item_s.nextval
  	FROM   DUAL;

  BEGIN

   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.raise_business_event.',
                        'Begin(+)');
   END IF;

    SAVEPOINT raise_business_event_sv;

  	OPEN  okl_key_csr;
  	FETCH okl_key_csr INTO l_seq;
  	CLOSE okl_key_csr;

    l_key := l_event_name ||l_seq ;

    -- *******
    -- Set the parameter list
    -- *******

    WF_EVENT.AddParameterToList('SSCKHRID',
                                p_khr_id,
                                l_parameter_list);

    WF_EVENT.AddParameterToList('SSCKLEID',
                                p_kle_id,
                                l_parameter_list);
     WF_EVENT.AddParameterToList('SSCQTEID',
                                p_qte_id,
                                l_parameter_list);
     WF_EVENT.AddParameterToList('REQUESTOR_ID',
                                p_requestor_id,
                                l_parameter_list);


    -- Raise Business Event
    WF_EVENT.raise(
                 p_event_name  => l_event_name,
                 p_event_key   => l_key,
                 p_parameters  => l_parameter_list);

    l_parameter_list.DELETE;

   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.raise_business_event.',
                        'End(-)');
   END IF;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      IF okl_key_csr%ISOPEN THEN
         CLOSE okl_key_csr;
      END IF;
      ROLLBACK TO raise_business_event_sv;
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.raise_business_event.',
                             'EXP - OTHERS');
    END IF;

END  raise_business_event;


-----------Create Repurchase Quote--

procedure createRepurchaseQuote(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2,
                            p_khr_id                         IN  NUMBER,
                            p_kle_id                         IN  NUMBER,
                            p_art_id                         IN  NUMBER,
                            p_qtp_code                       IN  VARCHAR2,
                            p_requestor_id                   IN  VARCHAR2,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2) IS

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    SUBTYPE qtev_rec_type IS OKL_AM_REPURCHASE_ASSET_PVT.qtev_rec_type;
    SUBTYPE tqlv_tbl_type IS OKL_AM_REPURCHASE_ASSET_PVT.tqlv_tbl_type;

    l_qtev_rec                  qtev_rec_type;
    x_qtev_rec                  qtev_rec_type;
    l_tqlv_tbl                  tqlv_tbl_type;
    x_tqlv_tbl                  tqlv_tbl_type;
    i                           NUMBER :=0;

    BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.createRepurchaseQuote.',
                        'Begin(+)');
       END IF;

    l_qtev_rec.khr_id           := p_khr_id;
    l_qtev_rec.art_id           := p_art_id;
    l_qtev_rec.qtp_code         := p_qtp_code;
    l_tqlv_tbl(1).kle_id        := p_kle_id;

  OKL_AM_REPURCHASE_ASSET_PUB.create_repurchase_quote(
    p_api_version,
    p_init_msg_list,
    l_return_status,
    l_msg_count,
    l_msg_data,
    l_qtev_rec,
    l_tqlv_tbl,
    x_qtev_rec,
    x_tqlv_tbl);

    x_return_status := l_return_status;
    x_msg_count := l_msg_count;
    x_msg_data := l_msg_data;

      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.createRepurchaseQuote.',
                        'End(-)');
       END IF;
      -- Raise Event

      raise_business_event(  p_khr_id    ,
                     p_kle_id     ,
                     x_qtev_rec.id    ,
                     p_requestor_id);

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

     IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.createRepurchaseQuote.',
                             'EXP - G_EXCEPTION_ERROR');
           END IF;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);
      IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.createRepurchaseQuote.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
           END IF;

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SSC_ASST_LOC_SERNUM_PUB','update_counter');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);
         IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.createRepurchaseQuote.',
                             'EXP - OTHERS');
           END IF;


END createRepurchaseQuote;






----------------------------UPDATE COUNTERS------------------------------------------------------

procedure  getCountersMessage  (itemtype in varchar2,
                                 itemkey in varchar2,
                                 actid in number,
                                 funcmode in varchar2,
                                 resultout out nocopy varchar2 )

IS

CURSOR user_info(p_id NUMBER) IS
SELECT user_name from fnd_user
WHERE user_id = p_id;

CURSOR approver_cur(respKey varchar2) IS
SELECT responsibility_id
FROM fnd_responsibility
WHERE responsibility_key = respKey
AND application_id = 540;

requestor_info_rec user_info%rowtype;

p_requestor_id NUMBER;
p_resp_key varchar2(30);

l_requestor_name varchar2(100);
l_approver_name  varchar2(100);
l_respString VARCHAR2(15) := 'FND_RESP540:';
l_approver_id varchar2(20);

l_doc_attr  varchar2(20) := 'SSCUPASNDOC';


BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.getCountersMessage.',
                        'Begin(+)');
       END IF;

if ( funcmode = 'RUN' ) then

p_requestor_id:=to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID'));

open user_info(p_requestor_id);
fetch user_info into requestor_info_rec;
l_requestor_name := requestor_info_rec.user_name;
close user_info;



WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCREQUESTOR', l_requestor_name);

p_resp_key := WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCAPPROVERRESPONSIBILITYKEY');

open approver_cur(p_resp_key);
fetch approver_cur into l_approver_id;
close approver_cur;
l_approver_name := l_respString||l_approver_id;

WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCAPPROVER', l_approver_name);


wf_engine.SetItemAttrText (itemtype   => itemtype,
                                   itemkey    => itemkey,
                                   aname      => l_doc_attr,
                                   avalue     => 'PLSQLCLOB:OKL_SSC_WF.getCountersDocument/'||
                                                 itemtype ||':'||itemkey||':&#NID');

resultout := 'COMPLETE';

return;
end if;


if ( funcmode = 'CANCEL' ) then

resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;


    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.getCountersMessage.',
                        'End(-)');
       END IF;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'getCountersMessage', itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';

 IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.getCountersMessage.',
                             'EXP - OTHERS');
END IF;
raise;
end getCountersMessage;

Procedure  getCountersDocument
            (      document_id    in      varchar2,
                   display_type   in      varchar2,
                   document       in out nocopy  clob,
                   document_type  in out nocopy  varchar2
                 )

IS



CURSOR counter_nums(p_counter_id NUMBER) IS
SELECT  CN.COUNTER_ID COUNTER_NUMBER,  CN.NAME COUNTER_NAME,
        KHR.CONTRACT_NUMBER CONTRACT_NUMBER,  ASSET.NAME ASSET_NUMBER
FROM
  OKC_K_LINES_TL ASSET,
  OKC_K_LINES_B USAGE,
  OKC_K_ITEMS UITEM,
  OKC_K_LINES_B OKS,
  OKC_K_LINES_B OKSU,
  OKC_K_ITEMS OKSITEM,
  CSI_COUNTERS_VL CN,
  OKC_K_ITEMS ASSET_ITEM,
  OKC_K_REL_OBJS REL,
  OKC_K_HEADERS_B KHR,
  OKC_K_LINES_B USUB_LINE
WHERE
  CN.COUNTER_ID = p_counter_id AND
  USAGE.DNZ_CHR_ID = KHR.ID AND
  KHR.ID = USAGE.CHR_ID AND
  USAGE.ID = UITEM.CLE_ID AND
  to_char(OKS.ID) = UITEM.OBJECT1_ID1 AND
  to_char(OKS.DNZ_CHR_ID) = REL.OBJECT1_ID1 AND
  OKS.ID = OKSU.CLE_ID AND
  OKS.DNZ_CHR_ID = OKSU.DNZ_CHR_ID AND
  OKSU.ID = OKSITEM.CLE_ID AND
  OKSITEM.OBJECT1_ID1 = to_char(CN.COUNTER_ID) AND
  OKSITEM.JTOT_OBJECT1_CODE = 'OKX_COUNTER' AND
  USUB_LINE.DNZ_CHR_ID = USAGE.CHR_ID AND
  USAGE.ID = USUB_LINE.CLE_ID AND
  USUB_LINE.ID = ASSET_ITEM.CLE_ID AND
  OKSU.dnz_chr_id = REL.OBJECT1_ID1 AND
  ASSET_ITEM.OBJECT1_ID1 = ASSET.ID AND
  ASSET.language = userenv ( 'LANG' ) AND
  REL.RTY_CODE = 'OKLUBB' AND
  REL.JTOT_OBJECT1_CODE = 'OKL_SERVICE' AND
  REL.CHR_ID = USAGE.DNZ_CHR_ID;

first_index             number;
second_index              number;
third_index             number;

l_counter_id              number;
--l_tal_type              varchar2(100);
l_itemtype              varchar2(100);
l_itemkey             varchar2(100);

l_document                        varchar2(32000);
NL                                VARCHAR2(1) := fnd_global.newline;

    BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.getCountersDocument.',
                        'Begin(+)');
       END IF;

    --the document_id is in the form of
    --'PLSQLCLOB:OKL_SSC_WF.getAssetReturnDocument/itemtyp:itemkey:&#NID'
    --we need to get itemtype and itemkey

    first_index := instr(document_id, '/', 1, 1);  --index of the slash '/'
    second_index := instr(document_id, ':', 1,1);  --index of first colon ':'
    third_index := instr(document_id, ':', 1, 2);  --index of the second colon ':'

    l_itemtype := substr(document_id, first_index+1, second_index-first_index-1);
    l_itemkey := substr(document_id, second_index+1, third_index-second_index-1);

    l_counter_id := to_number(WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTASID'));
--    l_tal_type := WF_ENGINE.GetItemAttrText(l_itemtype,l_itemkey,'SSCTALTYPE');


        IF (display_type = 'text/html') THEN

            --first generate the header
            l_document :=   '<BR>' || NL;
            l_document :=   l_document ||
                            '<table cellpadding="3" cellspacing="3" border="3" summary="">' || NL;
      l_document :=   l_document ||
                  '<tr><th>Asset Number</th><th>Serial Number</th></tr>' || NL;
            --loop through the record, and generate line by line


            FOR serial_nums_rec in counter_nums(l_counter_id)
            LOOP
                    l_document  :=   l_document ||
                  '<tr><td>' ||serial_nums_rec.COUNTER_NUMBER || '</td>';

              l_document :=   l_document ||
                  '<td>' ||serial_nums_rec.COUNTER_NAME || '</td></tr>' || NL;

              l_document :=   l_document ||
                  '<td>' ||serial_nums_rec.ASSET_NUMBER || '</td></tr>' || NL;

              l_document :=   l_document ||
                  '<td>' ||serial_nums_rec.CONTRACT_NUMBER || '</td></tr>' || NL;

            END LOOP;

      l_document :=   l_document || '</table>';
        END IF;-- end to 'text/html' display type

        wf_notification.WriteToClob( document, l_document);

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.getCountersDocument.',
                        'End(-)');
       END IF;

  EXCEPTION

  when others then
  WF_CORE.CONTEXT ('OKL_SSC_WF', 'getCountersDocument', l_itemtype, l_itemkey);

   IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.getCountersDocument.',
                             'EXP - OTHERS');
    END IF;
  raise;

END getCountersDocument;

 PROCEDURE update_counter(
                            p_api_version                    IN  NUMBER,
                            p_init_msg_list                  IN  VARCHAR2,
                            p_trx_id                         IN  NUMBER,
                            x_return_status                  OUT NOCOPY VARCHAR2,
                            x_msg_count                      OUT NOCOPY NUMBER,
                            x_msg_data                       OUT NOCOPY VARCHAR2)
  AS


    l_counter_id                   NUMBER;
    l_trx_id                   NUMBER;
    l_object_version_number    NUMBER;

    l_api_version        NUMBER          := 1.0;
    l_init_msg_list      VARCHAR2(1)     := Okc_Api.g_false;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);

    SUBTYPE cntr_bill_rec_type IS OKL_CNTR_GRP_BILLING_PVT.cntr_bill_rec_type;
    SUBTYPE cntr_bill_tbl_type IS OKL_CNTR_GRP_BILLING_PVT.cntr_bill_tbl_type;

    l_cntr_bill_rec                  cntr_bill_rec_type;
    x_cntr_bill_rec                  cntr_bill_rec_type;
    l_cntr_bill_tbl                  cntr_bill_tbl_type;
    x_cntr_bill_tbl                  cntr_bill_tbl_type;
    i                           NUMBER :=0;


/*
    CURSOR c_counter_rec(c_trx_id   NUMBER)IS
    select counter_id, counter_reading, reading_date, amount, clg_id
    from    dual;
*/
--    where   trx_id = c_trx_id;


  BEGIN

      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.update_counter.',
                        'Begin(+)');
       END IF;

/*
    FOR r_counter_rec in c_counter_rec(l_trx_id)
    loop

        l_cntr_bill_rec.clg_id              :=  r_counter_rec.clg_id;
        l_cntr_bill_rec.counter_group       :=  null;
        l_cntr_bill_rec.counter_number      :=  r_counter_rec.counter_id;
        l_cntr_bill_rec.counter_name        :=  null;
        l_cntr_bill_rec.contract_number     :=  null;
        l_cntr_bill_rec.asset_number        :=  null;
        l_cntr_bill_rec.asset_serial_number :=  null;
        l_cntr_bill_rec.asset_description   :=  null;
        l_cntr_bill_rec.effective_date_from :=  null;
        l_cntr_bill_rec.effective_date_to   :=  null;
        l_cntr_bill_rec.Reading_date        :=  r_counter_rec.reading_date;
        l_cntr_bill_rec.Meter_reading       :=  r_counter_rec.counter_reading;
        l_cntr_bill_rec.Bill_amount         :=  r_counter_rec.amount;


        l_cntr_bill_tbl(i) := l_cntr_bill_rec;

        i := i + 1;

    end loop;
*/
     OKL_CNTR_GRP_BILLING_PUB.insert_cntr_grp_bill(
     p_api_version      => l_api_version,
     p_init_msg_list    => l_init_msg_list,
     x_return_status    => l_return_status,
     x_msg_count        => l_msg_count,
     x_msg_data         => l_msg_data,
	 p_cntr_bill_tbl    => l_cntr_bill_tbl,
     x_cntr_bill_tbl    => x_cntr_bill_tbl
    );

      IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.update_counter.',
                        'End(-)');
       END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.update_counter.',
                             'EXP - G_EXCEPTION_ERROR');
    END IF;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);
    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.update_counter.',
                             'EXP - G_EXCEPTION_UNEXPECTED_ERROR');
    END IF;

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SSC_ASST_LOC_SERNUM_PUB','update_counter');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.update_counter.',
                             'EXP - OTHERS');
    END IF;

  END update_counter;

procedure update_counter_fnc (itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             funcmode in varchar2,
                             resultout out nocopy varchar2 ) is

x_return_status varchar2(1);
x_msg_count number;
l_msg_data varchar2(2000);
l_trx_id number;

l_admin   VARCHAR2(120)  := 'SYSADMIN';

error_updating_counters EXCEPTION;

begin

IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.update_counter_fnc.',
                        'Begin(+)');
END IF;
-- assign variable to attribute
WF_ENGINE.SetItemAttrText(itemtype,itemkey,'WF_ADMINISTRATOR',l_admin);


if ( funcmode = 'RUN' ) then


l_trx_id :=  to_number(WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCTASID'));

update_counter(p_api_version    => 1.0,
                     p_init_msg_list     => OKC_API.G_FALSE,
                     p_trx_id           => l_trx_id,
                     x_return_status    => x_return_status,
                     x_msg_count        => x_msg_count,
                     x_msg_data         => l_msg_data);

--check the update result
IF x_return_status <> 'S' THEN
	RAISE error_updating_counters;
ELSE
	resultout := 'COMPLETE';
	return;
END IF;


end if;


if ( funcmode = 'CANCEL' ) then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'RESPOND') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'FORWARD') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TRANSFER') then
resultout := 'COMPLETE';
return;
end if;
if ( funcmode = 'TIMEOUT' ) then
resultout := 'COMPLETE';
else
resultout := wf_engine.eng_timedout;
return;
end if;
IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.update_counter_fnc.',
                        'End(-)');
END IF;

exception
when others then
WF_CORE.CONTEXT ('okl_ssc_wf', 'update_counter_fnc:'||l_msg_data, itemtype, itemkey,actid,funcmode);
resultout := 'ERROR';
IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.update_counter_fnc.',
                             'EXP - OTHERS');
END IF;
raise;

end update_counter_fnc;



PROCEDURE populate_req_repqte_attr_wf
           (itemtype             IN VARCHAR2,
            itemkey              IN VARCHAR2,
            actid                IN number,
            funcmode             IN VARCHAR2,
            resultout            OUT NOCOPY VARCHAR2
            ) IS

   CURSOR contract_info_cur( p_khr_id IN NUMBER) IS
   SELECT contract_number
   FROM   okc_k_headers_b
   WHERE id = p_khr_id;

   CURSOR asset_info_cur(p_kle_id IN NUMBER) IS
   SELECT name
   FROM okc_k_lines_v
   WHERE  id = p_kle_id;


  CURSOR quote_info_cur(p_qte_id IN NUMBER) IS
   SELECT quote_number
   FROM okl_trx_quotes_v
   WHERE  id = p_qte_id;

   CURSOR requestor_info_cur(p_requestor_id IN NUMBER) IS
   SELECT user_name FROM fnd_user
   WHERE user_id = p_requestor_id;


   l_khr_id             VARCHAR2(40);
   l_kle_id             VARCHAR2(40);
   l_qte_id             VARCHAR2(40);
   l_quote_number       VARCHAR2(80);
   l_requestor_id       VARCHAR2(40);
   l_lease_agent_id     VARCHAR2(120) := 'LEASE';
   l_contract_number    VARCHAR2(120);
   l_asset_number       VARCHAR2(80);
   l_user_name          VARCHAR2(100);
   l_resp_id            VARCHAR2(15);
   l_resp_key           VARCHAR2(30);
   l_performer          VARCHAR2(27);
   l_respString         VARCHAR2(12):='FND_RESP540:';

   api_exception  EXCEPTION;

BEGIN

   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.populate_req_repqte_attr_wf.',
                        'Begin(+)');
   END IF;

   IF ( funcmode = 'RUN' ) THEN

        --Read attributes from WorkFlow
      --  l_khr_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCQUOTEID');
        l_khr_id:=WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	             itemkey	=> itemkey,
							                 aname  	=> 'SSCKHRID');
        l_kle_id:=WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	             itemkey	=> itemkey,
							                 aname  	=> 'SSCKLEID');
        l_qte_id:=WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	             itemkey	=> itemkey,
							                 aname  	=> 'SSCQTEID');
        l_requestor_id:=WF_ENGINE.GetItemAttrText( itemtype => itemtype,
						      	             itemkey	=> itemkey,
							                 aname  	=> 'REQUESTOR_ID');
      --  l_requestor_id:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCREQUESTORID');
       -- l_resp_key:=WF_ENGINE.GetItemAttrText(itemtype,itemkey,'SSCRESPONSIBILITYKEY');
--l_resp_key:='OKLCSMGR';


--Read from table
        OPEN contract_info_cur(l_khr_id);
        FETCH contract_info_cur INTO l_contract_number;
        CLOSE contract_info_cur;

        OPEN asset_info_cur(l_kle_id);
        FETCH asset_info_cur INTO l_asset_number;
        CLOSE asset_info_cur;

        OPEN quote_info_cur(l_qte_id);
        FETCH quote_info_cur INTO l_quote_number;
        CLOSE quote_info_cur;

        OPEN requestor_info_cur(l_requestor_id);
        FETCH requestor_info_cur INTO l_user_name;
        CLOSE requestor_info_cur;

/*
        SELECT responsibility_id INTO   l_resp_id
        FROM   fnd_responsibility
        WHERE  responsibility_key = l_resp_key
        AND    application_id = 540;   */

        WF_ENGINE.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'SSCASSET',
         	                    avalue  => l_asset_number);

        WF_ENGINE.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'SSCCONTRACT',
         	                    avalue  => l_contract_number);

        WF_ENGINE.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'LEASE_AGENT_ID',
         	                    avalue  => 'LEASE');


        WF_ENGINE.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'SSCQTENUM',
         	                    avalue  => l_quote_number);

        WF_ENGINE.SetItemAttrText ( itemtype=> itemtype,
				                itemkey => itemkey,
				                aname   => 'REQUESTOR_NAME',
         	                    avalue  => l_user_name);

      --  WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPERFORMER', l_respString||l_resp_id);
    --    WF_ENGINE.SetItemAttrText(itemtype,itemkey,'SSCPERFORMER', 'LEASE');


        resultout := 'COMPLETE';

        RETURN;
    END IF;


    IF ( funcmode = 'CANCEL' ) THEN
        resultout := 'COMPLETE';
        RETURN;
    END IF;

    IF ( funcmode = 'RESPOND') THEN
        resultout := 'COMPLETE';
        RETURN;
    END IF;

    IF ( funcmode = 'FORWARD') THEN
        resultout := 'COMPLETE';
        RETURN;
    END IF;

    IF ( funcmode = 'TRANSFER') THEN
        resultout := 'COMPLETE';
        RETURN;
    END IF;

    IF ( funcmode = 'TIMEOUT' ) THEN
        resultout := 'COMPLETE';
    ELSE
        resultout := wf_engine.eng_timedout;
        RETURN;
    END IF;

   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.populate_req_repqte_attr_wf.',
                        'End(-)');
   END IF;

    EXCEPTION
        WHEN OTHERS THEN
             WF_CORE.CONTEXT (G_PKG_NAME, 'populate_req_repqte_attr_wf', itemtype, itemkey);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.populate_req_repqte_attr_wf.',
                             'EXP - OTHERS');
             END IF;
             RAISE;

END populate_req_repqte_attr_wf;

PROCEDURE approve_quote_status( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
			                 	 actid		IN NUMBER,
			                  	 funcmode	IN VARCHAR2,
				                 resultout OUT NOCOPY VARCHAR2	) AS


    l_id            VARCHAR2(100);
    l_approved      VARCHAR2(1);
    x_return_status VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);
    p_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    x_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    p_api_version   NUMBER       := 1;
    p_init_msg_list VARCHAR2(1)  := FND_API.G_TRUE;

    API_ERROR       EXCEPTION;

    l_notify_response VARCHAR2(30);
  BEGIN

   IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.approve_quote_status.',
                        'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'SSCQTEID');

/*
        l_approved := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'APPROVED_YN'); */

        -- Set the quote status to REJECTED if the approval is declined
        -- else set to 'APPROVED'
   /*     IF nvl(l_approved, 'Y') = 'N' THEN
            p_qtev_rec.QST_CODE := 'REJECTED';
        ELSE */
            p_qtev_rec.QST_CODE := 'APPROVED';
            p_qtev_rec.DATE_APPROVED := SYSDATE;
     --   END IF;

        p_qtev_rec.ID := to_number(l_id);

        p_qtev_rec.APPROVED_YN :=  'Y';

        okl_qte_pvt.update_row( p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_qtev_rec        => p_qtev_rec,
                                x_qtev_rec        => x_qtev_rec);

		IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            IF nvl(l_approved, 'Y') = 'Y' THEN
			    resultout := 'COMPLETE:SUCCESS';
            END IF;
		ELSE
			RAISE API_ERROR;
		END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.approve_quote_status.',
                        'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        wf_core.context('OKL_VSS_WF' , 'approve_quote_status', itemtype, itemkey, actid, funcmode);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.approve_quote_status.',
                             'EXP - API_ERROR');
             END IF;
        RAISE;

     WHEN OTHERS THEN

        wf_core.context('OKL_VSS_WF' , 'approve_quote_status', itemtype, itemkey, actid, funcmode);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.approve_quote_status.',
                             'EXP - OTHERS');
             END IF;

        RAISE;

  END approve_quote_status;

PROCEDURE reject_quote_status( itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
			                 	 actid		IN NUMBER,
			                  	 funcmode	IN VARCHAR2,
				                 resultout OUT NOCOPY VARCHAR2	) AS


    l_id            VARCHAR2(100);
    l_approved      VARCHAR2(1);
    x_return_status VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    x_msg_count     NUMBER;
    x_msg_data      VARCHAR2(2000);
    p_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    x_qtev_rec      OKL_QTE_PVT.qtev_rec_type;
    p_api_version   NUMBER       := 1;
    p_init_msg_list VARCHAR2(1)  := FND_API.G_TRUE;

    API_ERROR       EXCEPTION;

    l_notify_response VARCHAR2(30);
  BEGIN

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.reject_quote_status.',
                        'Begin(+)');
   END IF;

    IF (funcmode = 'RUN') THEN
        l_id := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'SSCQTEID');

/*
        l_approved := wf_engine.GetItemAttrText( itemtype => itemtype,
						      	           itemkey	=> itemkey,
							               aname  	=> 'APPROVED_YN'); */

        -- Set the quote status to REJECTED if the approval is declined


        p_qtev_rec.QST_CODE := 'REJECTED';


        p_qtev_rec.ID := to_number(l_id);

        p_qtev_rec.APPROVED_YN :=  'N';

        okl_qte_pvt.update_row( p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_qtev_rec        => p_qtev_rec,
                                x_qtev_rec        => x_qtev_rec);

		IF x_return_status = OKC_API.G_RET_STS_SUCCESS THEN
            IF nvl(l_approved, 'N') = 'N' THEN
			    resultout := 'COMPLETE:ERROR';
            END IF;
		ELSE
			RAISE API_ERROR;
		END IF;

        RETURN ;
    END IF;

    --
    -- CANCEL mode
    --
    IF (funcmode = 'CANCEL') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    --
    -- TIMEOUT mode
    --
    IF (funcmode = 'TIMEOUT') THEN
      --
      resultout := 'COMPLETE:';
      RETURN;
      --
    END IF;

    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                        'OKL_VSS_WF.reject_quote_status.',
                        'End(-)');
   END IF;

  EXCEPTION

     WHEN API_ERROR THEN

        wf_core.context('OKL_VSS_WF' , 'reject_quote_status', itemtype, itemkey, actid, funcmode);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.reject_quote_status.',
                             'EXP - API_ERROR');
             END IF;
        RAISE;

     WHEN OTHERS THEN

        wf_core.context('OKL_VSS_WF' , 'reject_quote_status', itemtype, itemkey, actid, funcmode);

             IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                             'OKL_VSS_WF.reject_quote_status.',
                             'EXP - OTHERS');
             END IF;

        RAISE;

  END reject_quote_status;

END OKL_VSS_WF;

/
