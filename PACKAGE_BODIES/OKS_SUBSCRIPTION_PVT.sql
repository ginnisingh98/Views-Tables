--------------------------------------------------------
--  DDL for Package Body OKS_SUBSCRIPTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_SUBSCRIPTION_PVT" As
/* $Header: OKSRSUBB.pls 120.4 2006/03/31 13:24:44 skekkar noship $*/

  Procedure create_default_schedule
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER,
                 p_intent        IN  VARCHAR2
               ) IS
    Cursor kl_cur Is
      Select KL.dnz_chr_id, KL.start_date, NVL(KL.date_terminated - 1,KL.end_date) end_date,
             KI.number_of_items, KI.uom_code,
             NVL(MTL.contract_item_type_code,'NON-SUB'), MTL.coverage_schedule_id, MTL.comms_nl_trackable_flag
      From okc_k_lines_b KL,
           okc_k_items KI,
           mtl_system_items MTL
      Where KL.id = p_cle_id
        and KI.cle_id = p_cle_id
        and MTL.inventory_item_id = TO_NUMBER(KI.object1_id1)
        and MTL.organization_id   = TO_NUMBER(KI.object1_id2);

    Cursor osh_cur(p_template_id In Number) Is
      Select name,
             description,
             cle_id,
             dnz_chr_id,
             subscription_type,
             media_type,
             frequency,
             fulfillment_channel,
             comments,
             status,
             item_type
      From oks_subscr_header_v
      Where id = p_template_id;

    l_hdr_tbl_in    OKS_SUBSCR_HDR_PVT.schv_tbl_type;
    l_hdr_tbl_out   OKS_SUBSCR_HDR_PVT.schv_tbl_type;
    l_ptrns_tbl_in  OKS_SUBSCR_PTRNS_PVT.scpv_tbl_type;
    l_ptrns_tbl_out OKS_SUBSCR_PTRNS_PVT.scpv_tbl_type;
    l_elems_tbl_in  OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;
    l_elems_tbl_out OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;
    l_pattern_tbl   OKS_SUBSCRIPTION_SCH_PVT.pattern_tbl;
    l_delivery_tbl  OKS_SUBSCRIPTION_SCH_PVT.del_tbl;
    -- Pricing Parameters
    l_price_details_in  OKS_QP_PKG.INPUT_DETAILS;
    x_price_details_out OKS_QP_PKG.PRICE_DETAILS;
    x_mo_details        QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    x_pb_details        OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
    -- Pricing Parameters
    g_chr_id        Number;
    l_start_date    Date;
    l_end_date      Date;
    l_qty           Number;
    l_uom           Varchar2(10);
    l_template_id   Number;
    l_instance_id   Number := NULL;
    l_status        Varchar2(10);
    l_itype         Varchar2(30);
    l_tangible      Varchar2(1);
    l_return_status Varchar2(20);
    l_msg_count     Number;
    l_msg_data      Varchar2(2000);
    i               Number;
    idx             Number;
    tot_qty         Number;
    gen_exit        EXCEPTION;
  Begin
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE ,G_MODULE_CURRENT||'.create_default_schedule.begin'
                                      ,'p_cle_id = '||p_cle_id||' ,p_intent = '||p_intent);
    END IF;
    x_return_status := 'S';
    OKC_API.init_msg_list(p_init_msg_list);
    l_status := 'I';
    Open kl_cur;
    Fetch kl_cur Into g_chr_id, l_start_date, l_end_date, l_qty, l_uom, l_itype, l_template_id, l_tangible;
    IF kl_cur%NotFound THEN
      Close kl_cur;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKS_SUB_INVAL_LINE',
                p_token1       => 'LINEID',
                p_token1_value => p_cle_id
              );
      IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.create_default_schedule.ERROR','Invalid Line');
      END IF;
      Raise gen_exit;
    END IF;
    Close kl_cur;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.line_details',
                     'Header Id = '||g_chr_id||' ,Start Date = '||to_char(l_start_date,'DD-MON-YYYY')
                     ||' ,End Date = '||to_char(l_end_date,'DD-MON-YYYY')||' ,Quantity = '||l_qty
                     ||' ,UOM = '||l_uom||', Item Type Code = '||l_itype||' , Template Id = '||l_template_id
                     ||' ,NL Trackable(For Non-Subscription Items) = '||l_tangible
                    );
    END IF;
    IF l_itype = 'SUBSCRIPTION' Or l_tangible = 'Y' THEN
      -- For Subscription Items, get the subscription header details from the template
      If l_itype = 'SUBSCRIPTION' Then -- Tangible or Intangible Subscription Item
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.subs','it is a subscription item');
        END IF;
        if l_template_id is null then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message
                ( p_app_name => 'OKS',
                  p_msg_name => 'OKS_SUB_NO_TMPL'
                );
          IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.create_default_schedule.ERROR','No Template');
          END IF;
          Raise gen_exit;
        end if;
        For osh_rec In osh_cur(l_template_id) Loop
          l_hdr_tbl_in(1).name                  := osh_rec.name;
          l_hdr_tbl_in(1).description           := osh_rec.description;
          l_hdr_tbl_in(1).cle_id                := p_cle_id;
          l_hdr_tbl_in(1).dnz_chr_id            := g_chr_id;
          l_hdr_tbl_in(1).subscription_type     := osh_rec.subscription_type;
          l_hdr_tbl_in(1).media_type            := osh_rec.media_type;
          l_hdr_tbl_in(1).frequency             := osh_rec.frequency;
          l_hdr_tbl_in(1).fulfillment_channel   := osh_rec.fulfillment_channel;
          l_hdr_tbl_in(1).comments              := osh_rec.comments;
          l_hdr_tbl_in(1).item_type             := osh_rec.item_type;
          l_status                              := osh_rec.status;
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.template_details',
                           'Name = '||osh_rec.name||', Description = '||osh_rec.description
                           ||', Subs. Type = '||osh_rec.subscription_type||', Media Type = '||osh_rec.media_type
                           ||', Frequency = '||osh_rec.frequency||', Fulfill. Channel = '||osh_rec.fulfillment_channel
                           ||', Item Type = '||osh_rec.item_type||', Status = '||osh_rec.status
                           ||', Comments = '||osh_rec.comments);
          END IF;
          Exit;
        End Loop;
        if NVL(l_status, 'A') <> 'A' then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message
                ( p_app_name     => 'OKS',
                  p_msg_name     => 'OKS_SUB_INACT_TMPL',
                  p_token1       => 'TMPL',
                  p_token1_value => l_hdr_tbl_in(1).name
                );
          IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.create_default_schedule.ERROR','Inactive Template');
          END IF;
          Raise gen_exit;
        end if;
        -- Create Item Instance in the Installed Base --
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.before',
                                      'oks_auth_util_pub.create_cii_for_subscription(p_cle_id = '||p_cle_id||')');
        END IF;
        OKS_AUTH_UTIL_PUB.CREATE_CII_FOR_SUBSCRIPTION
                (
                  p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_cle_id        => p_cle_id,
                  x_instance_id   => l_instance_id
                );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.after',
                         'oks_auth_util_pub.create_cii_for_subscription(x_return_status = '||x_return_status
                         ||', x_instance_id = '||l_instance_id||')');
        END IF;
        If NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
          Raise gen_exit;
        End If;
        l_hdr_tbl_in(1).instance_id  := l_instance_id;
      Else -- Tangible Non-Subscription Item
      -- Create dummy subscription header for Tangible Non-Subscription Items
        l_hdr_tbl_in(1).name                  := 'Non-Sub Item';  -- Dummy Hard Coded Value, change this
        l_hdr_tbl_in(1).description           := 'Non-Subscription Item (Tangible)';  -- Dummy Hard Coded Value, change this
        l_hdr_tbl_in(1).cle_id                := p_cle_id;
        l_hdr_tbl_in(1).dnz_chr_id            := g_chr_id;
        l_hdr_tbl_in(1).subscription_type     := 'JRNL';              -- Dummy Hard Coded Value, make this a nullable column
        l_hdr_tbl_in(1).frequency             := 'D';
        l_hdr_tbl_in(1).fulfillment_channel   := 'OM';
        l_hdr_tbl_in(1).item_type             := 'NT';
      End If;
      l_hdr_tbl_in(1).status   := 'A';
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.before',
                                    'oks_subscr_hdr_pub.insert_row');
      END IF;
      OKS_SUBSCR_HDR_PUB.insert_row
              (
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_schv_tbl      => l_hdr_tbl_in,
                x_schv_tbl      => l_hdr_tbl_out
              );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.after',
                                    'oks_subscr_hdr_pub.insert_row(x_return_status = '||x_return_status||')');
      END IF;
      If NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
        Raise gen_exit;
      End If;

      -- FOR TANGIBLE ITEMS(SUBSCRIPTION OR NON-SUB), CREATE DEFAULT PATTERN --
      If l_hdr_tbl_out(1).fulfillment_channel <> 'NONE' then
        -- CREATE DEFAULT SCHEDULE PATTERN --
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.tangible','it is a tangible item');
        END IF;
        l_ptrns_tbl_in(1).osh_id                := l_hdr_tbl_out(1).id;
        l_ptrns_tbl_in(1).dnz_chr_id            := g_chr_id;
        l_ptrns_tbl_in(1).dnz_cle_id            := p_cle_id;
        l_ptrns_tbl_in(1).seq_no                := 1;
        if l_itype     = 'SUBSCRIPTION' then
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.tansub',
                           'it is a tangible subscription item. creating default pattern');
          END IF;
          l_ptrns_tbl_in(1).year                  := '*';
          if l_hdr_tbl_out(1).frequency = 'M' then
            l_ptrns_tbl_in(1).month                 := '*';
          elsif l_hdr_tbl_out(1).frequency = 'W' then
            l_ptrns_tbl_in(1).month                 := '*';
            l_ptrns_tbl_in(1).week                  := '*';
          elsif l_hdr_tbl_out(1).frequency = 'D' then
            l_ptrns_tbl_in(1).month                 := '*';
            l_ptrns_tbl_in(1).day                   := '*';
          end if;
        else -- non-subscription item, it will be shippable
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.tannonsub',
                          'it is a tangible non-subscription item. creating one-time schedule pattern');
          END IF;
          -- CREATE PATTERN FOR ONE-TIME SCHEDULE IF SHIPPABLE NON-SUBSCRIPTION ITEM
          l_ptrns_tbl_in(1).year                  := to_char(l_start_date,'YYYY');
          l_ptrns_tbl_in(1).month                 := to_char(l_start_date,'MM');
          l_ptrns_tbl_in(1).day                   := to_char(l_start_date,'DD');
        end if;
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.before',
                                      'oks_subscr_ptrns_pub.insert_row');
        END IF;
        OKS_SUBSCR_PTRNS_PUB.insert_row
                (
                  p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_scpv_tbl      => l_ptrns_tbl_in,
                  x_scpv_tbl      => l_ptrns_tbl_out
                );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.after',
                                      'oks_subscr_ptrns_pub.insert_row(x_return_status = '||x_return_status||')');
        END IF;
        if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
          Raise gen_exit;
        end if;

        -- CALCULATE DEFAULT DELIVERY SCHEDULE --
        l_pattern_tbl(1).yr_pattern   := l_ptrns_tbl_out(1).year;
        l_pattern_tbl(1).mth_pattern  := l_ptrns_tbl_out(1).month;
        l_pattern_tbl(1).week_pattern := l_ptrns_tbl_out(1).week;
        l_pattern_tbl(1).wday_pattern := l_ptrns_tbl_out(1).week_day;
        l_pattern_tbl(1).day_pattern  := l_ptrns_tbl_out(1).day;
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.before',
                                      'oks_subscription_sch_pvt.calc_delivery_date');
        END IF;
        OKS_SUBSCRIPTION_SCH_PVT.calc_delivery_date
                (
                  p_start_dt      => l_start_date,
                  p_end_dt        => l_end_date,
                  p_offset_dy     => NULL,
                  p_freq          => l_hdr_tbl_out(1).frequency,
                  p_pattern_tbl   => l_pattern_tbl,
                  x_delivery_tbl  => l_delivery_tbl,
                  x_return_status => x_return_status
                );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.after',
                                      'oks_subscription_sch_pvt.calc_delivery_date(x_return_status = '||x_return_status||')');
        END IF;
        if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
          Raise gen_exit;
        end if;

        -- CREATE SCHEDULE ELEMENTS --
        if l_delivery_tbl.COUNT > 0 then
          idx := l_delivery_tbl.FIRST;
          i   := 1;
          LOOP
            l_elems_tbl_in(i).osh_id                := l_hdr_tbl_out(1).id;
            l_elems_tbl_in(i).dnz_chr_id            := g_chr_id;
            l_elems_tbl_in(i).dnz_cle_id            := p_cle_id;
            l_elems_tbl_in(i).seq_no                := 1;
            l_elems_tbl_in(i).om_interface_date     := l_delivery_tbl(idx).delivery_date;
            l_elems_tbl_in(i).start_date            := l_delivery_tbl(idx).start_date;
            l_elems_tbl_in(i).end_date              := l_delivery_tbl(idx).end_date;
            l_elems_tbl_in(i).quantity              := l_qty;
            l_elems_tbl_in(i).uom_code              := l_uom;
            Exit When idx = l_delivery_tbl.LAST;
            idx := l_delivery_tbl.NEXT(idx);
            i := i + 1;
          END LOOP;
          tot_qty := i * l_qty;
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.before',
                                        'oks_subscr_elems_pub.insert_row');
          END IF;
          OKS_SUBSCR_ELEMS_PUB.insert_row
                  (
                    p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    p_scev_tbl      => l_elems_tbl_in,
                    x_scev_tbl      => l_elems_tbl_out
                  );
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.after',
                                        'oks_subscr_elems_pub.insert_row(x_return_status = '||x_return_status||')');
          END IF;
          if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
            Raise gen_exit;
          end if;
        else
          Null;  -- No Schedule for this line. Handle exception here if needed
        end if;  -- l_delivery_tbl.COUNT
      Else
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.intansub',
                         'it is an intangible subscription item. only header is created');
        END IF;
      End If;
    ELSE
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.create_default_schedule.intannonsub',
                       'it is an intangible non-subscription item. nothing created (only pricing will be called)');
      END IF;
    END IF;
    -- PRICE THE TOP LINE
    l_price_details_in.line_id := p_cle_id;
    l_price_details_in.intent  := NVL(p_intent,'SB_P');
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.before',
                                  'oks_qp_int_pvt.compute_price(p_detail_rec.line_id = '||l_price_details_in.line_id||
                                  ', p_detail_rec.intent = '||l_price_details_in.intent||')');
    END IF;
    OKS_QP_INT_PVT.compute_price
            (
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_detail_rec          => l_price_details_in,
              x_price_details       => x_price_details_out,
              x_modifier_details    => x_mo_details,
              x_price_break_details => x_pb_details
            );
    IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.create_default_schedule.external_call.after',
                                  'oks_qp_int_pvt.compute_price(x_return_status = '||x_return_status||')');
    END IF;
    IF NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      Raise gen_exit;
    END IF;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.create_default_schedule.end',' ');
    END IF;
  Exception
    When gen_exit Then
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE_CURRENT||'.create_default_schedule.EXCEPTION','gen_exit');
      END IF;
    When OTHERS Then
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.create_default_schedule.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => 'ERROR_CODE',
                p_token1_value => sqlcode,
                p_token2       => 'ERROR_MESSAGE',
                p_token2_value => sqlerrm
              );
  End create_default_schedule;

  Procedure recreate_schedule
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER,
                 p_intent        IN  VARCHAR2,
                 x_quantity      OUT NOCOPY NUMBER
               ) IS
    Type tel_rec_type Is Record
                  ( id         Number,
                    start_date Date,
                    end_date   Date,
                    del_date   Date,
                    qty        Number,
                    uom        Varchar2(10),
                    order_id   Number,
                    o_v_num    Number
                  );
    Type tel_tbl_type is Table Of tel_rec_type Index By Binary_Integer;
    Cursor kl_cur Is
      Select KL.dnz_chr_id, KL.start_date, NVL(KL.date_terminated - 1,KL.end_date) end_date,
             KL.price_negotiated, KI.number_of_items, KI.uom_code,
             NVL(MTL.contract_item_type_code,'NON-SUB')
      From okc_k_lines_b KL,
           okc_k_items KI,
           mtl_system_items MTL
      Where KL.id = p_cle_id
        and KI.cle_id = p_cle_id
        and MTL.inventory_item_id = TO_NUMBER(KI.object1_id1)
        and MTL.organization_id   = TO_NUMBER(KI.object1_id2);

    Cursor osh_cur Is
      Select id,
             instance_id,
             frequency,
             fulfillment_channel,
             offset
      From oks_subscr_header_b
      Where cle_id  = p_cle_id;

    Cursor unitprice_cur Is
      Select NVL(amount,0)/quantity unitprice, uom_code
	 From oks_subscr_elements
	 Where dnz_cle_id = p_cle_id
	   And rownum < 2;

    Cursor ptrn_cur Is
      Select id, object_version_number, year, month, week, week_day, day
      From oks_subscr_patterns
      Where dnz_cle_id = p_cle_id;

    Cursor elem_cur Is
      Select id, start_date, end_date, quantity, uom_code,
             om_interface_date, order_header_id, object_version_number
      From oks_subscr_elements
      Where dnz_cle_id = p_cle_id;

    Cursor tot_qty_cur Is
      Select Sum(NVL(quantity,0))
      From oks_subscr_elements
      Where dnz_cle_id = p_cle_id;

    l_ptrns_tbl_in     OKS_SUBSCR_PTRNS_PVT.scpv_tbl_type;
    l_ptrns_tbl_out    OKS_SUBSCR_PTRNS_PVT.scpv_tbl_type;
    l_elems_tbl_ins_in OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;
    l_elems_tbl_upd_in OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;
    l_elems_tbl_del_in OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;
    l_elems_tbl_out    OKS_SUBSCR_ELEMS_PVT.scev_tbl_type;
    l_pattern_tbl      OKS_SUBSCRIPTION_SCH_PVT.pattern_tbl;
    l_delivery_tbl     OKS_SUBSCRIPTION_SCH_PVT.del_tbl;
    l_hdr_tbl_in       OKS_SUBSCR_HDR_PVT.schv_tbl_type;
    l_hdr_tbl_out      OKS_SUBSCR_HDR_PVT.schv_tbl_type;
    tmp_elem_tbl    tel_tbl_type;
    -- Pricing Parameters
    l_price_details_in  OKS_QP_PKG.INPUT_DETAILS;
    x_price_details_out OKS_QP_PKG.PRICE_DETAILS;
    x_mo_details        QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    x_pb_details        OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
    -- Pricing Parameters
    g_chr_id        Number;
    l_start_date    Date;
    l_end_date      Date;
    l_price_nego    Number;
    l_qty           Number;
    l_uom           Varchar2(10);
    l_itype         Varchar2(30);
    l_uom1          Varchar2(10);
    l_unitprice     Number;
    l_elem_amount   Number;
    l_osh_id        Number;
    l_offset        Number;
    l_frequency     Varchar2(10);
    l_fulfill_chnl  Varchar2(20);
    l_ptrn_id       Number;
    l_ptrn_ovn      Number;
    i               Number;
    idx             Number;
    ins_idx         Number := 0;
    upd_idx         Number := 0;
    del_idx         Number := 0;
    l               Number;
    l_sch_found     Boolean;
    gen_exit        EXCEPTION;

    procedure create_insert_rec Is
    begin
      ins_idx := ins_idx + 1;
      l_elems_tbl_ins_in(ins_idx).osh_id                := l_osh_id;
      l_elems_tbl_ins_in(ins_idx).dnz_chr_id            := g_chr_id;
      l_elems_tbl_ins_in(ins_idx).dnz_cle_id            := p_cle_id;
      l_elems_tbl_ins_in(ins_idx).seq_no                := 1;
      l_elems_tbl_ins_in(ins_idx).om_interface_date     := l_delivery_tbl(i).delivery_date;
      l_elems_tbl_ins_in(ins_idx).start_date            := l_delivery_tbl(i).start_date;
      l_elems_tbl_ins_in(ins_idx).end_date              := l_delivery_tbl(i).end_date;
      l_elems_tbl_ins_in(ins_idx).quantity              := l_qty;
      l_elems_tbl_ins_in(ins_idx).uom_code              := l_uom;
	 If p_intent Is Null Then
        l_elems_tbl_ins_in(ins_idx).amount                := l_elem_amount;
	 End If;
    end create_insert_rec;

    procedure create_update_rec Is
    begin
      upd_idx := upd_idx + 1;
      l_elems_tbl_upd_in(upd_idx).id                    := tmp_elem_tbl(idx).id;
      l_elems_tbl_upd_in(upd_idx).osh_id                := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).dnz_chr_id            := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).dnz_cle_id            := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).seq_no                := 1;
      l_elems_tbl_upd_in(upd_idx).om_interface_date     := l_delivery_tbl(i).delivery_date;
      l_elems_tbl_upd_in(upd_idx).start_date            := l_delivery_tbl(i).start_date;
      l_elems_tbl_upd_in(upd_idx).end_date              := l_delivery_tbl(i).end_date;
      l_elems_tbl_upd_in(upd_idx).quantity              := l_qty;
      l_elems_tbl_upd_in(upd_idx).uom_code              := l_uom;
      l_elems_tbl_upd_in(upd_idx).order_header_id       := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).order_line_id         := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).object_version_number := tmp_elem_tbl(idx).o_v_num;
      l_elems_tbl_upd_in(upd_idx).created_by            := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).creation_date         := OKC_API.G_MISS_DATE;
      l_elems_tbl_upd_in(upd_idx).last_updated_by       := OKC_API.G_MISS_NUM;
      l_elems_tbl_upd_in(upd_idx).last_update_date      := OKC_API.G_MISS_DATE;
      l_elems_tbl_upd_in(upd_idx).last_update_login     := OKC_API.G_MISS_NUM;
      If p_intent Is Null Then
        l_elems_tbl_upd_in(ins_idx).amount                := l_elem_amount;
      End If;
    end create_update_rec;

    procedure create_delete_rec Is
    begin
      del_idx := del_idx + 1;
      l_elems_tbl_del_in(del_idx).id                    := tmp_elem_tbl(i).id;
    end create_delete_rec;

  Begin
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.recreate_schedule.begin','p_cle_id = '||p_cle_id||
                                                         ' ,p_intent = '||p_intent);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    Open kl_cur;
    Fetch kl_cur Into g_chr_id, l_start_date, l_end_date, l_price_nego, l_qty, l_uom, l_itype;
    IF kl_cur%NotFound THEN
      Close kl_cur;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKS_SUB_INVAL_LINE',
                p_token1       => 'LINEID',
                p_token1_value => p_cle_id
              );
      IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.recreate_schedule.ERROR','Invalid Subscription Line');
      END IF;
      Raise gen_exit;
    END IF;
    Close kl_cur;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.line_details',
                     'Header Id = '||g_chr_id||' ,Start Date = '||to_char(l_start_date,'DD-MON-YYYY')
                     ||' ,End Date = '||to_char(l_end_date,'DD-MON-YYYY')||' ,Quantity = '||l_qty
                     ||' ,UOM = '||l_uom||', Item Type Code = '||l_itype
                    );
    END IF;
    -- If it is an intangible non-subscription item, then the cursor will not contain any records
    -- and the value of l_fulfill_chnl will remain NULL
    For osh_rec In osh_cur Loop
      l_osh_id       := osh_rec.id;
      l_frequency    := osh_rec.frequency;
      l_fulfill_chnl := osh_rec.fulfillment_channel;
      l_offset       := osh_rec.offset;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.subs_header_details',
                       'Id = '||osh_rec.id||', Fulfill. Channel = '||osh_rec.fulfillment_channel
                       ||', Frequency = '||osh_rec.frequency||', Offset = '||osh_rec.offset);
      END IF;
      Exit;
    End Loop;

    -- RECREATE DELIVERY SCHEDULE ONLY FOR TANGIBLE ITEMS(SUBSCRIPTION OR NON-SUB) --
    IF l_fulfill_chnl <> 'NONE' THEN
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.tan',
                       'it is an tangible item');
      END IF;
    -- Need the unit price for populating the elements table if pricing is not called
    -- (The procedure is called with p_intent=NULL while copying subscription, to skip pricing call)
      If p_intent Is Null Then
        Open unitprice_cur;
        Fetch unitprice_cur Into l_unitprice, l_uom1;
	   l_sch_found := unitprice_cur%FOUND;
        Close unitprice_cur;
	   If l_sch_found Then
          l_elem_amount := l_unitprice * l_qty;
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.unitprice',
                           'Unit Price = '||l_unitprice||' ,UOM Code = '||l_uom1||
                           ' ,Elem. Amount = '||l_elem_amount
                          );
          END IF;
	   End If;
	 End If;
    -- CALCULATE NEW DELIVERY SCHEDULE --
      idx := 1;
      For ptrn_rec in ptrn_cur Loop
        l_pattern_tbl(idx).yr_pattern   := ptrn_rec.year;
        l_pattern_tbl(idx).mth_pattern  := ptrn_rec.month;
        l_pattern_tbl(idx).week_pattern := ptrn_rec.week;
        l_pattern_tbl(idx).wday_pattern := ptrn_rec.week_day;
        l_pattern_tbl(idx).day_pattern  := ptrn_rec.day;
        If l_itype <> 'SUBSCRIPTION' Then
          l_ptrn_id                       := ptrn_rec.id;
          l_ptrn_ovn                      := ptrn_rec.object_version_number;
          Exit; -- Only one pattern record for Non-Sub lines
        End If;
        idx := idx + 1;
      End Loop;
      If l_itype <> 'SUBSCRIPTION' Then
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.tannonsub',
                         'it is a tangible non-subscription item');
        END IF;
        if NVL(l_pattern_tbl(1).yr_pattern,'!')  <> to_char(l_start_date,'YYYY') or
           NVL(l_pattern_tbl(1).mth_pattern,'!') <> to_char(l_start_date,'MM') or
           NVL(l_pattern_tbl(1).day_pattern,'!') <> to_char(l_start_date,'DD') then
          IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.updptrn',
                           'start date changed. the single record pattern will be updated');
          END IF;
          l_ptrns_tbl_in(1).id                    := l_ptrn_id;
          l_ptrns_tbl_in(1).object_version_number := l_ptrn_ovn;
          l_ptrns_tbl_in(1).osh_id                := l_osh_id;
          l_ptrns_tbl_in(1).dnz_chr_id            := g_chr_id;
          l_ptrns_tbl_in(1).dnz_cle_id            := p_cle_id;
          l_ptrns_tbl_in(1).seq_no                := 1;
          l_ptrns_tbl_in(1).year                  := to_char(l_start_date,'YYYY');
          l_ptrns_tbl_in(1).month                 := to_char(l_start_date,'MM');
          l_ptrns_tbl_in(1).day                   := to_char(l_start_date,'DD');
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.before',
                                        'oks_subscr_ptrns_pub.update_row(p_scpv_tbl(1).id = '||l_ptrns_tbl_in(1).id||')');
          END IF;
          OKS_SUBSCR_PTRNS_PUB.update_row
                  (
                    p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    p_scpv_tbl      => l_ptrns_tbl_in,
                    x_scpv_tbl      => l_ptrns_tbl_out
                  );
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.after',
                                        'oks_subscr_ptrns_pub.update_row(x_return_status = '||x_return_status||')');
          END IF;
          if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
            Raise gen_exit;
          end if;
          l_pattern_tbl(1).yr_pattern  := to_char(l_start_date,'YYYY');
          l_pattern_tbl(1).mth_pattern := to_char(l_start_date,'MM');
          l_pattern_tbl(1).day_pattern := to_char(l_start_date,'DD');
        end if;
      End If;
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.before',
                                    'oks_subscription_sch_pvt.calc_delivery_date');
      END IF;
      OKS_SUBSCRIPTION_SCH_PVT.calc_delivery_date
              (
                p_start_dt      => l_start_date,
                p_end_dt        => l_end_date,
                p_offset_dy     => l_offset,
                p_freq          => l_frequency,
                p_pattern_tbl   => l_pattern_tbl,
                x_delivery_tbl  => l_delivery_tbl,
                x_return_status => x_return_status
              );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.after',
                                    'oks_subscription_sch_pvt.calc_delivery_date(x_return_status = '||x_return_status||')');
      END IF;
      If nvl(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
        Raise gen_exit;
      End If;
	 If l_delivery_tbl.COUNT <> 0 And p_intent Is Null And l_sch_found = FALSE Then
        l_elem_amount := l_price_nego / l_delivery_tbl.COUNT;
	 End If;
       -- GET THE EXISTING SCHEDULE --
      For elem_rec in elem_cur Loop
        idx := to_char(elem_rec.start_date,'YYYYMMDD');
        tmp_elem_tbl(idx).id         := elem_rec.id;
        tmp_elem_tbl(idx).start_date := elem_rec.start_date;
        tmp_elem_tbl(idx).end_date   := elem_rec.end_date;
        tmp_elem_tbl(idx).del_date   := elem_rec.om_interface_date;
        tmp_elem_tbl(idx).qty        := elem_rec.quantity;
        tmp_elem_tbl(idx).uom        := elem_rec.uom_code;
        tmp_elem_tbl(idx).order_id   := elem_rec.order_header_id;
        tmp_elem_tbl(idx).o_v_num    := elem_rec.object_version_number;
      End Loop;
      If l_delivery_tbl.COUNT <> 0 Then
        i := l_delivery_tbl.FIRST;
        LOOP
          idx := to_char(l_delivery_tbl(i).start_date,'YYYYMMDD');
          if tmp_elem_tbl.EXISTS(idx) then
            if tmp_elem_tbl(idx).order_id Is Null then
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.updelem',
                               'marking element for update: period start date - '
                               ||to_char(l_delivery_tbl(i).start_date,'DD-MON-YYYY')
                              );
              END IF;
              create_update_rec;
              tmp_elem_tbl.DELETE(idx);
            else
              IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.noupdelem',
                               'not marking element for update since shipped: period start date - '
                               ||to_char(l_delivery_tbl(i).start_date,'DD-MON-YYYY')
                              );
              END IF;
            end if;
          else
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.inselem',
                             'marking element for insert: period start date - '
                             ||to_char(l_delivery_tbl(i).start_date,'DD-MON-YYYY')
                            );
            END IF;
            create_insert_rec;
          end if;
          Exit When i = l_delivery_tbl.LAST;
          i := l_delivery_tbl.NEXT(i);
        END LOOP;
      End If;
      If tmp_elem_tbl.COUNT <> 0 Then
        i := tmp_elem_tbl.FIRST;
        LOOP
          if tmp_elem_tbl(i).order_id Is Null then
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.delelem',
                             'marking element for delete: period start date - '
                             ||to_char(tmp_elem_tbl(i).start_date,'DD-MON-YYYY')
                            );
            END IF;
            create_delete_rec;
          else
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_schedule.nodelelem',
                             'not marking element for delete since shipped: period start date - '
                             ||to_char(tmp_elem_tbl(i).start_date,'DD-MON-YYYY')
                            );
            END IF;
          end if;
          Exit When i = tmp_elem_tbl.LAST;
          i := tmp_elem_tbl.NEXT(i);
        END LOOP;
      End If;

      -- DELETE UNWANTED SCHEDULE ELEMENTS --
      If l_elems_tbl_del_in.COUNT <> 0 Then
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.before',
                                      'oks_subscr_elems_pub.delete_row');
        END IF;
        OKS_SUBSCR_ELEMS_PUB.delete_row
              (
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_scev_tbl      => l_elems_tbl_del_in
              );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.after',
                                      'oks_subscr_elems_pub.delete_row(x_return_status = '||x_return_status||')');
        END IF;
        if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
          Raise gen_exit;
        end if;
      End If;

      -- UPDATE CHANGED SCHEDULE ELEMENTS --
      If l_elems_tbl_upd_in.COUNT <> 0 Then
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.before',
                                      'oks_subscr_elems_pub.update_row');
        END IF;
        OKS_SUBSCR_ELEMS_PUB.update_row
              (
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_scev_tbl      => l_elems_tbl_upd_in,
                x_scev_tbl      => l_elems_tbl_out
              );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.after',
                                      'oks_subscr_elems_pub.update_row(x_return_status = '||x_return_status||')');
        END IF;
        if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
          Raise gen_exit;
        end if;
      End If;

      -- INSERT NEW SCHEDULE ELEMENTS --
      If l_elems_tbl_ins_in.COUNT <> 0 Then
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.before',
                                      'oks_subscr_elems_pub.insert_row');
        END IF;
        OKS_SUBSCR_ELEMS_PUB.insert_row
              (
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_scev_tbl      => l_elems_tbl_ins_in,
                x_scev_tbl      => l_elems_tbl_out
              );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.after',
                                      'oks_subscr_elems_pub.insert_row(x_return_status = '||x_return_status||')');
        END IF;
        if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
          Raise gen_exit;
        end if;
      End If;
      Open tot_qty_cur;
      Fetch tot_qty_cur into x_quantity;
      Close tot_qty_cur;
    ELSE  -- Intangible Item (Subscription or Non-Subscription)
      x_quantity := l_qty;
    END IF;
    -- Reprice the line if intention is good
    IF p_intent Is Not NULL THEN
      l_price_details_in.line_id := p_cle_id;
      l_price_details_in.intent  := p_intent;
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.before',
                                    'oks_qp_int_pvt.compute_price(p_detail_rec.line_id = '||l_price_details_in.line_id||
                                    ', p_detail_rec.intent = '||l_price_details_in.intent||')');
      END IF;
      OKS_QP_INT_PVT.compute_price
            (
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_detail_rec          => l_price_details_in,
              x_price_details       => x_price_details_out,
              x_modifier_details    => x_mo_details,
              x_price_break_details => x_pb_details
            );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_schedule.external_call.after',
                                    'oks_qp_int_pvt.compute_price(x_return_status = '||x_return_status||')');
      END IF;
      If NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
        Raise gen_exit;
      End If;
    END IF;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.recreate_schedule.end','x_quantity = '||x_quantity);
    END IF;
  Exception
    When gen_exit Then
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE_CURRENT||'.recreate_schedule.EXCEPTION','gen_exit');
      END IF;
    When OTHERS Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.recreate_schedule.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => 'ERROR_CODE',
                p_token1_value => sqlcode,
                p_token2       => 'ERROR_MESSAGE',
                p_token2_value => sqlerrm
              );
  End recreate_schedule;

  Procedure recreate_instance
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER,
                 p_custacct_id   IN  NUMBER
               ) IS
    l_osh_id Number;
    l_instance_id Number;
    l_item_type Varchar2(10);
    CURSOR osh_cur IS
      SELECT id,item_type
      FROM oks_subscr_header_b
      WHERE cle_id = p_cle_id;
    gen_exit EXCEPTION;
  Begin
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.recreate_instance.begin','p_cle_id = '||p_cle_id||
                                                         ' ,p_custacct_id = '||p_custacct_id);
    END IF;
    OPEN osh_cur;
    FETCH osh_cur INTO l_osh_id,l_item_type;
    IF osh_cur%NOTFOUND THEN
      CLOSE osh_cur;
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      RAISE gen_exit;
    END IF;
    CLOSE osh_cur;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_instance.osh_details',
                     'Osh Id = '||l_osh_id||' ,Item Type = '||l_item_type);
    END IF;
    IF l_item_type IN ('ST','SI') THEN
      -- Create Item Instance in the Installed Base --
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_instance.external_call.before',
                                     'oks_auth_util_pub.create_cii_for_subscription(p_cle_id = '||p_cle_id||')');
      END IF;
      OKS_AUTH_UTIL_PUB.CREATE_CII_FOR_SUBSCRIPTION
              (
                p_api_version   => p_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_cle_id        => p_cle_id,
                x_instance_id   => l_instance_id
              );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.recreate_instance.external_call.after',
                       'oks_auth_util_pub.create_cii_for_subscription(x_return_status = '||x_return_status
                       ||', x_instance_id = '||l_instance_id||')');
      END IF;
      If NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
        Raise gen_exit;
      End If;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_instance.updhdr.before',
                                     'oks_subscr_header_b(id = '||l_osh_id||', instance_id = '||l_instance_id||')');
      END IF;
      UPDATE oks_subscr_header_b
        SET instance_id = l_instance_id
        WHERE id = l_osh_id;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.recreate_instance.updhdr.after',' ');
      END IF;
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.recreate_instance.end',' ');
    END IF;
  EXCEPTION
    When gen_exit Then
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE_CURRENT||'.recreate_instance.EXCEPTION','gen_exit');
      END IF;
    When OTHERS Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.recreate_instance.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => 'ERROR_CODE',
                p_token1_value => sqlcode,
                p_token2       => 'ERROR_MESSAGE',
                p_token2_value => sqlerrm
              );
  End recreate_instance;

  Procedure copy_subscription
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY NUMBER,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_source_cle_id IN  NUMBER,
                 p_target_cle_id IN  NUMBER,
                 p_intent        IN  VARCHAR2
              ) IS
    Cursor tgt_chr_cur Is
     Select dnz_chr_id
     From okc_k_lines_b
     Where id = p_target_cle_id
       And lse_id = 46;
    Cursor src_line_cur Is
     Select id
     From okc_k_lines_b
     Where id = p_source_cle_id
       And lse_id = 46;
    -- Pricing Parameters
    l_price_details_in  OKS_QP_PKG.INPUT_DETAILS;
    x_price_details_out OKS_QP_PKG.PRICE_DETAILS;
    x_mo_details        QP_PREQ_GRP.LINE_DETAIL_TBL_TYPE;
    x_pb_details        OKS_QP_PKG.G_PRICE_BREAK_TBL_TYPE;
    -- Pricing Parameters
    g_chr_id      Number;
    g_osh_id      Number;
    l_instance_id Number;
    l_dummy       Number;
    l_intent      Varchar2(20);
    gen_exit  EXCEPTION;
    Procedure copy_osh Is
      l_schv_tbl_in  OKS_SUBSCR_HDR_PUB.schv_tbl_type;
      l_schv_tbl_out OKS_SUBSCR_HDR_PUB.schv_tbl_type;
      Cursor src_osh_cur Is
        select name, description, instance_id, subscription_type, media_type, frequency,
               fulfillment_channel, offset, comments, item_type
        from oks_subscr_header_v
        where cle_id = p_source_cle_id;
    Begin
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.copy_subscription.copy_osh.begin',' ');
      END IF;
      For src_osh_rec In src_osh_cur
      Loop
        l_schv_tbl_in(1).name                := src_osh_rec.name;
        l_schv_tbl_in(1).description         := src_osh_rec.description;
        l_schv_tbl_in(1).cle_id              := p_target_cle_id;
        l_schv_tbl_in(1).dnz_chr_id          := g_chr_id;
        l_schv_tbl_in(1).instance_id         := src_osh_rec.instance_id; -- If not renewing this will be overwritten later
        l_schv_tbl_in(1).subscription_type   := src_osh_rec.subscription_type;
        l_schv_tbl_in(1).media_type          := src_osh_rec.media_type;
        l_schv_tbl_in(1).frequency           := src_osh_rec.frequency;
        l_schv_tbl_in(1).fulfillment_channel := src_osh_rec.fulfillment_channel;
        l_schv_tbl_in(1).offset              := src_osh_rec.offset;
        l_schv_tbl_in(1).comments            := src_osh_rec.comments;
        l_schv_tbl_in(1).status              := 'A';
        l_schv_tbl_in(1).item_type           := src_osh_rec.item_type;
        IF p_intent = 'COPY' THEN
          -- Create Item Instance in the Installed Base if called from subscription is getting copied
          If src_osh_rec.item_type  In ('ST','SI') Then
            IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.copy_osh.external_call.before',
                                          'oks_auth_util_pub.create_cii_for_subscription(p_cle_id = '||p_target_cle_id||')');
            END IF;
            OKS_AUTH_UTIL_PUB.CREATE_CII_FOR_SUBSCRIPTION
                    (
                      p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_cle_id        => p_target_cle_id,
                      x_instance_id   => l_instance_id
                    );
            IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.copy_osh.external_call.after',
                             'oks_auth_util_pub.create_cii_for_subscription(x_return_status = '||x_return_status
                             ||', x_instance_id = '||l_instance_id||')');
            END IF;
            if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
              Raise gen_exit;
            end if;
            l_schv_tbl_in(1).instance_id       := l_instance_id;
          End If;
        END IF;
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.copy_osh.external_call.before',
                                      'oks_subscr_hdr_pub.insert_row');
        END IF;
        OKS_SUBSCR_HDR_PUB.insert_row
                ( p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_schv_tbl       => l_schv_tbl_in,
                  x_schv_tbl       => l_schv_tbl_out);
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.copy_osh.external_call.after',
                                      'oks_subscr_hdr_pub.insert_row(x_return_status = '||x_return_status||')');
        END IF;
        If x_return_status = OKC_API.G_RET_STS_SUCCESS Then
          g_osh_id := l_schv_tbl_out(1).id;
        End If;
      End Loop;
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.copy_subscription.copy_osh.end',' ');
      END IF;
    End copy_osh;

    Procedure copy_osp Is
      l_scpv_tbl_in  OKS_SUBSCR_PTRNS_PUB.scpv_tbl_type;
      l_scpv_tbl_out OKS_SUBSCR_PTRNS_PUB.scpv_tbl_type;
      Cursor src_osp_cur Is
        select year, month, week, week_day, day
        from oks_subscr_patterns
        where dnz_cle_id = p_source_cle_id;
      i Number := 0;
    Begin
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.copy_subscription.copy_osp.begin',' ');
      END IF;
      For src_osp_rec In src_osp_cur
      Loop
        i := i + 1;
        l_scpv_tbl_in(i).osh_id     := g_osh_id;
        l_scpv_tbl_in(i).dnz_cle_id := p_target_cle_id;
        l_scpv_tbl_in(i).dnz_chr_id := g_chr_id;
        l_scpv_tbl_in(i).seq_no     := 1;
        l_scpv_tbl_in(i).year       := src_osp_rec.year;
        l_scpv_tbl_in(i).month      := src_osp_rec.month;
        l_scpv_tbl_in(i).week       := src_osp_rec.week;
        l_scpv_tbl_in(i).week_day   := src_osp_rec.week_day;
        l_scpv_tbl_in(i).day        := src_osp_rec.day;
      End Loop;
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.copy_osp.external_call.before',
                                    'oks_subscr_ptrns_pub.insert_row');
      END IF;
      OKS_SUBSCR_PTRNS_PUB.insert_row
              ( p_api_version    => p_api_version,
                p_init_msg_list  => p_init_msg_list,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data,
                p_scpv_tbl       => l_scpv_tbl_in,
                x_scpv_tbl       => l_scpv_tbl_out
              );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.copy_osp.external_call.after',
                                    'oks_subscr_ptrns_pub.insert_row(x_return_status = '||x_return_status||')');
      END IF;
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.copy_subscription.copy_osh.end',' ');
      END IF;
    End copy_osp;
  Begin
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.copy_subscription.begin','p_source_cle_id = '||p_source_cle_id||
                     ', p_target_cle_id = '||p_target_cle_id||' ,p_intent = '||p_intent);
    END IF;
    Open tgt_chr_cur;
    Fetch tgt_chr_cur Into g_chr_id;
    If tgt_chr_cur%NOTFOUND Then
      Close tgt_chr_cur;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKS_SUB_INVAL_TGT',
                p_token1       => 'TARGET',
                p_token1_value => p_target_cle_id
              );
      IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.copy_subscription.ERROR','Invalid Target Line');
      END IF;
      Raise gen_exit;
    End If;
    Close tgt_chr_cur;
    Open src_line_cur;
    Fetch src_line_cur Into l_dummy;
    If src_line_cur%NOTFOUND Then
      Close src_line_cur;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKS_SUB_INVAL_SRC',
                p_token1       => 'SOURCE',
                p_token1_value => p_source_cle_id
              );
      IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.copy_subscription.ERROR','Invalid Source Line');
      END IF;
      Raise gen_exit;
    End If;
    Close src_line_cur;
    copy_osh;
    If p_intent in ('COPY','RENEW') Then
      l_intent := Null;
    Else
      l_intent := p_intent;
    End If;
    If g_osh_id Is Not Null Then
      copy_osp;
      recreate_schedule
               ( p_api_version   => p_api_version,
                 p_init_msg_list => p_init_msg_list,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_cle_id        => p_target_cle_id,
                 p_intent        => l_intent,
                 x_quantity      => l_dummy
               );
    Else -- No OSH Id => The item must be Non-Subscription Intangible
      -- PRICE THE NEW SUBSCRIPTION LINE
      If l_intent is Not Null Then
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.copy_subscription.intannonsubprice',
                                      'intangible non-subscription item with pricing intent');
        END IF;
        l_price_details_in.line_id := p_target_cle_id;
        l_price_details_in.intent  := l_intent;
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.external_call.before',
                                      'oks_qp_int_pvt.compute_price(p_detail_rec.line_id = '||l_price_details_in.line_id||
                                      ', p_detail_rec.intent = '||l_price_details_in.intent||')');
        END IF;
        OKS_QP_INT_PVT.compute_price
                (
                  p_api_version         => p_api_version,
                  p_init_msg_list       => p_init_msg_list,
                  x_return_status       => x_return_status,
                  x_msg_count           => x_msg_count,
                  x_msg_data            => x_msg_data,
                  p_detail_rec          => l_price_details_in,
                  x_price_details       => x_price_details_out,
                  x_modifier_details    => x_mo_details,
                  x_price_break_details => x_pb_details
                );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.copy_subscription.external_call.after',
                                      'oks_qp_int_pvt.compute_price(x_return_status = '||x_return_status||')');
        END IF;
        if NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS then
          Raise gen_exit;
        end if;
      End If;
    End If;

  Exception
    When gen_exit Then
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE_CURRENT||'.copy_subscription.EXCEPTION','gen_exit');
      END IF;
    When OTHERS Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_UNEXPECTED,G_MODULE_CURRENT||'.create_default_schedule.UNEXPECTED',
                                'sqlcode = '||sqlcode||', sqlerrm = '||sqlerrm);
      END IF;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => 'ERROR_CODE',
                p_token1_value => sqlcode,
                p_token2       => 'ERROR_MESSAGE',
                p_token2_value => sqlerrm
              );
  End copy_subscription;

  Procedure undo_subscription
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_cle_id        IN  NUMBER
              ) IS

    l_osh_id Number;
    l_ff_chan Varchar2(30);

    Procedure delete_cii Is
      Cursor schv_cur Is
        Select id, instance_id, fulfillment_channel
        From oks_subscr_header_b
        Where cle_id = p_cle_id;
      /* No Item instance deletion for release 11.5.9 and 11.5.10
      l_instance_id Number;
      Cursor other_osh_inst Is
        Select Null
        From oks_subscr_header_b
        Where instance_id = l_instance_id
          And cle_id <> p_cle_id;
      l_dummy Number;
      */
    Begin
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      For schv_rec in schv_cur
      Loop
        l_osh_id      := schv_rec.id;
        l_ff_chan     := schv_rec.fulfillment_channel;
      --l_instance_id := schv_rec.instance_id;
        Exit;  -- There will always be only one record, if at all
      End Loop;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.undo_subscription.delete_cii.osh_details',
                       'Osh Id = '||l_osh_id||' ,Fulfillment Channel = '||l_ff_chan);
      END IF;
      /* No Item instance deletion for release 11.5.9
      -- Uncomment when the procedure OKS_AUTH_UTIL_PUB.delete_cii_for_subscription is ready
      IF l_instance_id is Not Null THEN
        Open other_osh_inst;
        Fetch other_osh_inst Into l_dummy;
        -- If more subscription lines are referring to the same item instance,
        -- then don't delete the item instance;
        If other_osh_inst%Found Then
          Close other_osh_inst;
          Return;
        End If;
        Close other_osh_inst;
        -- Delete the item instance;
        OKS_AUTH_UTIL_PUB.delete_cii_for_subscription
             ( p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_cle_id        => p_cle_id
             );
      END IF;
      */
    End delete_cii;

    Procedure delete_osh Is
      l_schv_tbl OKS_SUBSCR_HDR_PUB.schv_tbl_type;
    Begin
      l_schv_tbl(1).id := l_osh_id;
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.undo_subscription.delete_osh.external_call.before',
                                    'oks_subscr_hdr_pub.delete_row(p_schv_tbl(1).id = '||l_schv_tbl(1).id||')');
      END IF;
      OKS_SUBSCR_HDR_PUB.delete_row
             ( p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_schv_tbl      => l_schv_tbl
             );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.undo_subscription.delete_osh.external_call.after',
                                    'oks_subscr_hdr_pub.delete_row(x_return_status = '||x_return_status||')');
      END IF;
    End delete_osh;

    Procedure delete_osp Is
      Cursor scpv_cur Is
        Select id
        From oks_subscr_patterns
        Where dnz_cle_id = p_cle_id;
      l_scpv_tbl OKS_SUBSCR_PTRNS_PUB.scpv_tbl_type;
      i Number := 0;
    Begin
      For scpv_rec In scpv_cur
      Loop
        i := i + 1;
        l_scpv_tbl(i).id := scpv_rec.id;
      End Loop;
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.undo_subscription.delete_osp.external_call.before',
                                    'oks_subscr_ptrns_pub.delete_row(p_scpv_tbl.COUNT = '||i||')');
      END IF;
      OKS_SUBSCR_PTRNS_PUB.delete_row
             ( p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_scpv_tbl      => l_scpv_tbl
             );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.undo_subscription.delete_osp.external_call.after',
                                    'oks_subscr_ptrns_pub.delete_row(x_return_status = '||x_return_status||')');
      END IF;
    End delete_osp;

    Procedure delete_ose Is
      Cursor scev_cur Is
        Select id
        From oks_subscr_elements
        Where dnz_cle_id = p_cle_id;
      l_scev_tbl OKS_SUBSCR_ELEMS_PUB.scev_tbl_type;
      i Number := 0;
    Begin
      For scev_rec In scev_cur
      Loop
        i := i + 1;
        l_scev_tbl(i).id := scev_rec.id;
      End Loop;
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.undo_subscription.delete_ose.external_call.before',
                                    'oks_subscr_elems_pub.delete_row(p_scev_tbl.COUNT = '||i||')');
      END IF;
      OKS_SUBSCR_ELEMS_PUB.delete_row
             ( p_api_version   => p_api_version,
               p_init_msg_list => p_init_msg_list,
               x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data,
               p_scev_tbl      => l_scev_tbl
             );
      IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.undo_subscription.delete_ose.external_call.after',
                                    'oks_subscr_elems_pub.delete_row(x_return_status = '||x_return_status||')');
      END IF;
    End delete_ose;
  Begin
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.undo_subscription.begin','p_cle_id = '||p_cle_id);
    END IF;
    delete_cii; -- (Delete the item instance if one exists and) Get the OSH.id and fulfillment channel
    IF l_osh_id Is Null Or NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS THEN
      return;
    END IF;
    IF l_ff_chan <> 'NONE' THEN -- If the item is tangible then ...
      delete_ose;               -- delete the subscription elements
      If NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
        return;
      End If;
      delete_osp;               -- delete the subscription patterns
      If NVL(x_return_status,'!') <> OKC_API.G_RET_STS_SUCCESS Then
        return;
      End If;
    END IF;
    delete_osh;                 -- delete the subscription header (tangible or intangible)
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.undo_subscription.end',' ');
    END IF;
  Exception
    When OTHERS Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => 'ERROR_CODE',
                p_token1_value => sqlcode,
                p_token2       => 'ERROR_MESSAGE',
                p_token2_value => sqlerrm
              );
  End undo_subscription;

  Procedure validate_pattern
               ( p_api_version   IN  NUMBER,
                 p_init_msg_list IN  VARCHAR2,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_msg_count     OUT NOCOPY Number,
                 x_msg_data      OUT NOCOPY VARCHAR2,
                 p_instring      IN  VARCHAR2,
                 p_lowval        IN  NUMBER,
                 p_highval       IN  NUMBER,
                 x_outstring     OUT NOCOPY VARCHAR2,
                 x_outtab        OUT NOCOPY rangetab) IS
    l_tab      rangetab;
    i          NUMBER;
    len        NUMBER;
    l_index    NUMBER;
    commaloc   NUMBER;
    hyphenloc  NUMBER;
    lowval     NUMBER;
    highval    NUMBER;
    l_string   VARCHAR2(2000);
    l_modifstr VARCHAR2(2000);
    range1     VARCHAR2(2000);
    gen_exit   EXCEPTION;
    Procedure MERGER IS
      i NUMBER;
      j NUMBER;
      rlow NUMBER;
      rhigh NUMBER;
    Begin
      i := l_tab.FIRST;
      Loop
        Exit When i=l_tab.LAST;
        rlow := l_tab(i).low;
        rhigh:= l_tab(i).high;
        j := l_tab.NEXT(i);
        loop
          If l_tab(j).high <= rhigh Then
            l_tab.delete(j);
          Elsif l_tab(j).low <= rhigh+1 Then
            l_tab(i).high := l_tab(j).high;
            rhigh := l_tab(j).high;
            l_tab.delete(j);
          End If;
          Exit When j >= l_tab.LAST;
          j := l_tab.NEXT(j);
        end loop;
        Exit When i = l_tab.LAST;
        i := l_tab.NEXT(i);
      End Loop;
      i := l_tab.FIRST;
      l_modifstr := NULL;
      Loop
        If l_modifstr IS NOT NULL Then
          l_modifstr := l_modifstr||',';
        End If;
        If l_tab(i).low = l_tab(i).high Then
          l_modifstr := l_modifstr||l_tab(i).low;
        Else
          l_modifstr := l_modifstr||l_tab(i).low||'-'||l_tab(i).high;
        End If;
        Exit When i = l_tab.LAST;
        i := l_tab.NEXT(i);
      End Loop;
      If l_modifstr = p_lowval||'-'||p_highval Then
        l_modifstr := '*';
      End If;
    End MERGER;
  Begin
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OKC_API.init_msg_list(p_init_msg_list);
    l_string := p_instring;
    l_string := translate(l_string,'0 ','0');
    IF l_string = '*' THEN
      x_outtab(1).low  := p_lowval;
      x_outtab(1).high := p_highval;
      l_modifstr       := '*';
    ELSIF l_string IS NOT NULL THEN
      If translate(l_string,' 0123456789,-',' ') IS NOT NULL Then
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message
                ( p_app_name     => 'OKS',
                  p_msg_name     => 'OKS_SUB_INVAL_CHRS',
                  p_token1       => 'CHRS',
                  p_token1_value => translate(l_string,' 0123456789,-',' ')
                );
        Raise gen_exit;
      End If;
      If instr(l_string,',,') <> 0 or
         instr(l_string,'--') <> 0 or
         instr(l_string,',-') <> 0 or
         instr(l_string,'-,') <> 0 Then
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message
                ( p_app_name => 'OKS',
                  p_msg_name => 'OKS_SUB_CONT_DELIM'
                );
        Raise gen_exit;
      End If;
      If substr(l_string,1,1) in (',','-') or
         substr(l_string,length(l_string),1) in (',','-') then
        x_return_status := OKC_API.G_RET_STS_ERROR;
        OKC_API.set_message
                ( p_app_name => 'OKS',
                  p_msg_name => 'OKS_SUB_SE_DELIM'
                );
        Raise gen_exit;
      End If;
      LOOP
        EXIT When l_string IS NULL;
        commaloc := instr(l_string,',');
        If commaloc = 0 Then
          range1 := l_string;
          l_string := NULL;
        Else
          range1 := substr(l_string,1,commaloc-1);
          l_string := substr(l_string,commaloc+1);
        End If;
        If instr(range1,'-',1,2) <> 0 Then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message
                  ( p_app_name     => 'OKS',
                    p_msg_name     => 'OKS_SUB_INVAL_RANGE',
                    p_token1       => 'RANGE',
                    p_token1_value => range1
                  );
          Raise gen_exit;
        End If;
        hyphenloc := instr(range1,'-');
        If hyphenloc = 0 Then
          lowval  := range1;
          highval := range1;
        Else
          lowval  := substr(range1,1,hyphenloc-1);
          highval := substr(range1,hyphenloc+1);
        End If;
        If lowval < p_lowval  or highval < p_lowval  or
           lowval > p_highval or highval > p_highval Then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message
                  ( p_app_name     => 'OKS',
                    p_msg_name     => 'OKS_SUB_RANGE',
                    p_token1       => 'LOW',
                    p_token1_value => p_lowval,
                    p_token2       => 'HIGH',
                    p_token2_value => p_highval
                  );
          Raise gen_exit;
        End If;
        If lowval > highval Then
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message
                  ( p_app_name     => 'OKS',
                    p_msg_name     => 'OKS_SUB_INVAL_RANGE',
                    p_token1       => 'RANGE',
                    p_token1_value => range1
                  );
          Raise gen_exit;
        End If;
        If NOT l_tab.EXISTS(lowval) Then
          l_tab(lowval).low := lowval;
          l_tab(lowval).high:= highval;
        Elsif l_tab(lowval).high < highval Then
          l_tab(lowval).high := highval;
        End If;
      END LOOP;
      MERGER;
      i := 1;
      l_index := l_tab.FIRST;
      LOOP
        x_outtab(i) := l_tab(l_index);
        EXIT WHEN l_index=l_tab.LAST;
        l_index := l_tab.NEXT(l_index);
        i := i+1;
      END LOOP;
    END IF;
    x_outstring := l_modifstr;
  Exception
    When gen_exit Then
      Null;
    When OTHERS Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKC_API.set_message
              ( p_app_name     => 'OKS',
                p_msg_name     => 'OKC_CONTRACTS_UNEXP_ERROR',
                p_token1       => 'ERROR_CODE',
                p_token1_value => sqlcode,
                p_token2       => 'ERROR_MESSAGE',
                p_token2_value => sqlerrm
              );
  End validate_pattern;

  Procedure get_subs_qty
               ( p_cle_id        IN  NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2,
                 x_quantity      OUT NOCOPY NUMBER,
                 x_uom_code      OUT NOCOPY VARCHAR2
               ) IS
    Cursor k_item_cur Is
      Select number_of_items, uom_code
      From okc_k_items
      Where cle_id = p_cle_id;
    Cursor subs_hdr Is
      Select item_type, frequency
      From oks_subscr_header_b
      Where cle_id = p_cle_id;
    Cursor subs_qty Is
      Select sum(quantity)
      From oks_subscr_elements
      Where dnz_cle_id = p_cle_id;
    Cursor k_line_cur Is
      Select start_date, end_date
      From okc_k_lines_b
      Where id = p_cle_id;
    CURSOR l_get_hdrid_csr IS
      SELECT dnz_chr_id
      FROM   okc_k_lines_b
      WHERE  id = p_cle_id;
    l_quantity   Number;
    l_uom_code   Varchar2(10);
    l_cal_uom    Varchar2(10);
    l_frequency  Varchar2(3);
    l_item_type  Varchar2(10);
    l_act_start  Date;
    l_act_end    Date;
    l_start_date Date;
    l_end_date   Date;
    l_multiplier Number;
    l_pricing_method Varchar2(30);
    --New variables for partial periods
    l_period_type            VARCHAR2(30);
    l_period_start           VARCHAR2(30);
    l_price_uom              VARCHAR2(30);
    l_chr_id                 NUMBER;
    INVALID_HDR_ID_EXCEPTION EXCEPTION;
    EXC_ERROR                EXCEPTION;
  Begin
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.get_subs_qty.begin','p_cle_id = '||p_cle_id);
    END IF;
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_pricing_method:=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
    Open k_item_cur;
    Fetch k_item_cur Into l_quantity, l_uom_code;
    Close k_item_cur;
    Open subs_hdr;
    Fetch subs_hdr Into l_item_type, l_frequency;
    Close subs_hdr;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.get_subs_qty.line_details',
                     'Qty per period = '||l_quantity||' ,UOM = '||l_uom_code
                     ||', Item Type = '||l_item_type||', Frequency = '||l_frequency
                     ||', Intangible Pricing Method = '||l_pricing_method);
    END IF;
    If l_item_type In ('ST','NT') Then
      Open subs_qty;
      Fetch subs_qty Into l_quantity;
      Close subs_qty;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.get_subs_qty.tanqty','Tangible Qty = '||l_quantity);
      END IF;
    Elsif l_item_type = 'SI' Then
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.get_subs_qty.intan','intangible item');
      END IF;
      Open k_line_cur;
      Fetch k_line_cur Into l_act_start, l_act_end;
      Close k_line_cur;
      if l_pricing_method = 'EFFECTIVITY' then
        l_start_date := l_act_start;
        l_end_date   := l_act_end;
      else
        stretch_effectivity
          (l_act_start, l_act_end, l_frequency, l_start_date, l_end_date);
      end if;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.get_subs_qty.stretch_eff',
                       'New Start Date = '||to_char(l_start_date,'DD-MON-YYYY')
                       ||', New End Date = '||to_char(l_end_date,'DD-MON-YYYY'));
      END IF;
      l_cal_uom := map_freq_uom(l_frequency);
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.get_subs_qty.freq_uom','Frequency UOM = '||l_cal_uom);
      END IF;
      if l_cal_uom is Null then
        x_return_status := OKC_API.G_RET_STS_ERROR;
        IF FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_ERROR,G_MODULE_CURRENT||'.get_subs_qty.ERROR','Invalid UOM Code');
        END IF;
      OKC_API.SET_MESSAGE(p_app_name    => 'OKS',
                         p_msg_name     => 'OKS_INVD_UOM_CODE',
                         p_token1       => 'OKS_API_NAME',
                         p_token1_value => 'OKS_SUBSCRIPTION_PVT.get_subs_qty',
                         p_token2       => 'UOM_CODE',
                         p_token2_value => p_cle_id);
      else
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.get_subs_qty.external_call.before',
                                       'oks_time_measures_pub.get_quantity');
        END IF;
      -- Begin new logic for Partial periods
        OPEN  l_get_hdrid_csr;
        FETCH l_get_hdrid_csr INTO l_chr_id;
        CLOSE l_get_hdrid_csr;
        IF l_chr_id IS NOT NULL
        THEN
            OKS_RENEW_UTIL_PUB.get_period_defaults(p_hdr_id        => l_chr_id,
                                                    p_org_id        => NULL,
                                                    x_period_type   => l_period_type,
                                                    x_period_start  => l_period_start,
                                                    x_price_uom     => l_price_uom,
                                                    x_return_status => x_return_status);
             IF x_return_status <> 'S'
             THEN
                RAISE EXC_ERROR;
             END IF;
        ELSE
             RAISE INVALID_HDR_ID_EXCEPTION;
        END IF;
        IF l_pricing_method = 'EFFECTIVITY'
           -- Only effectivity based, then only partial period logic
        THEN
	    --added by mchoudha for bug#4729856
	    IF l_period_start is not null then
              l_period_start := 'SERVICE';
	    END IF;
            l_multiplier := OKS_TIME_MEASURES_PUB.get_quantity
                            (p_start_date   => l_start_date,
                             p_end_date     => l_end_date,
                             p_source_uom   => l_cal_uom,
                             p_period_type  => l_period_type, --new param
                             p_period_start => l_period_start); --new param

        ELSE
             l_multiplier := OKS_TIME_MEASURES_PUB.get_quantity
                            (p_start_date => l_start_date,
                             p_end_date   => l_end_date,
                             p_source_uom => l_cal_uom);
        END IF;
	--End new logic for partial periods
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE_CURRENT||'.get_subs_qty.external_call.after',
                                       'oks_time_measures_pub.get_quantity(return = '||l_multiplier||')');
        END IF;
        l_quantity := l_quantity * l_multiplier;
      end if;
    End If;
    x_quantity := l_quantity;
    x_uom_code := l_uom_code;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.get_subs_qty.end',
                     'x_quantity = '||x_quantity||' ,x_uom_code = '||x_uom_code);
    END IF;
  Exception
    WHEN EXC_ERROR THEN
        NULL;
    WHEN INVALID_HDR_ID_EXCEPTION THEN
        OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => G_INVALID_VALUE,
         p_token1       => G_COL_NAME_TOKEN,
         p_token1_value => 'Header ID');
    When Others Then
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End get_subs_qty;

  Procedure stretch_effectivity
               ( p_start_date    IN  DATE,
                 p_end_date      IN  DATE,
                 p_frequency     IN  VARCHAR2, -- 'Y','M','W','D' Only
                 x_new_start_dt  OUT NOCOPY DATE,
                 x_new_end_dt    OUT NOCOPY DATE
               ) IS
  Begin
    IF p_frequency = 'Y' THEN
      x_new_start_dt := to_date(to_char(p_start_date,'YYYY')||'0101','YYYYMMDD');
      x_new_end_dt   := to_date(to_char(p_end_date,'YYYY')||'1231','YYYYMMDD');
    ELSIF p_frequency = 'M' THEN
      x_new_start_dt := to_date(to_char(p_start_date,'YYYYMM')||'01','YYYYMMDD');
      x_new_end_dt   := add_months(to_date(to_char(p_end_date,'YYYYMM')||'01','YYYYMMDD'),1) - 1;
    ELSIF p_frequency = 'W' THEN
      x_new_start_dt := p_start_date - to_number(to_char(p_start_date,'D')) + 1;
      x_new_end_dt   := p_end_date - to_number(to_char(p_end_date,'D')) + 7;
    ELSE
      x_new_start_dt := p_start_date;
      x_new_end_dt   := p_end_date;
    END IF;
  End stretch_effectivity;

  Function subs_termn_amount
               ( p_cle_id        IN  NUMBER,
                 p_termn_date    IN  DATE
               ) Return NUMBER IS
    Cursor k_line_cur Is
      Select start_date, end_date, price_negotiated
      From okc_k_lines_b
      Where id = p_cle_id
        And lse_id = 46;
    Cursor osh_cur Is
      Select item_type, frequency
      From oks_subscr_header_b
      Where cle_id = p_cle_id;
    Cursor trmn_amt_cur Is
      Select sum(amount)
      From oks_subscr_elements
      Where dnz_cle_id = p_cle_id
        And (start_date < p_termn_date Or order_header_id Is Not Null);
    CURSOR l_get_hdrid_csr IS
      SELECT dnz_chr_id
      FROM   okc_k_lines_b
      WHERE  id = p_cle_id;
    l_act_start   Date;
    l_act_end     Date;
    l_start_date  Date;
    l_end_date    Date;
    l_tmn_date    Date;
    l_orig_price  Number;
    l_divisor     Number;
    l_multiplier  Number;
    l_item_type   Varchar2(10);
    l_frequency   Varchar2(10);
    l_uom         Varchar2(10);
    l_trmn_amount Number;
    l_pricing_method Varchar2(30);
   --New variables for partial periods
    l_period_type            OKS_K_HEADERS_B.PERIOD_TYPE%TYPE;
    l_period_start           OKS_K_HEADERS_B.PERIOD_START%TYPE;
    l_price_uom              OKS_K_HEADERS_B.PRICE_UOM%TYPE;
    l_chr_id                 NUMBER;
    l_return_status          VARCHAR2(1);
    INVALID_HDR_ID_EXCEPTION EXCEPTION;
    EXC_ERROR                EXCEPTION;
  Begin


    -------------------------------------------------------------------------
    -- Begin partial period computation logic
    -- Developer Mani Choudhary
    -- Date 06-JUN-2005
    -- Fetch the period start and period type stored at the contract level.
    -------------------------------------------------------------------------
    OPEN  l_get_hdrid_csr;
    FETCH l_get_hdrid_csr INTO l_chr_id;
    CLOSE l_get_hdrid_csr;
    IF l_chr_id IS NOT NULL
    THEN
      OKS_RENEW_UTIL_PUB.get_period_defaults(p_hdr_id        => l_chr_id,
                                             p_org_id        => NULL,
                                             x_period_type   => l_period_type,
                                             x_period_start  => l_period_start,
                                             x_price_uom     => l_price_uom,
                                             x_return_status => l_return_status);
      IF l_return_status <> 'S' THEN
        RAISE EXC_ERROR;
      END IF;
    ELSE
      RAISE INVALID_HDR_ID_EXCEPTION;
    END IF;
    -------------------------------------------------------------------------
    -- End partial period computation logic
    -------------------------------------------------------------------------


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.subs_termn_amount.begin',
                     'p_cle_id = '||p_cle_id||' ,p_termn_date = '||to_char(p_termn_date,'DD-MON-YYYY')
                     ||', Intangible Pricing Method = '||l_pricing_method);
    END IF;
    l_pricing_method :=FND_PROFILE.value('OKS_SUBS_PRICING_METHOD');
    Open k_line_cur;
    Fetch k_line_cur Into l_act_start, l_act_end, l_orig_price;
    If k_line_cur%NotFound Then
      Close k_line_cur;
      Return Null;
    End If;
    If p_termn_date = l_act_start Then
      Close k_line_cur;
      Return 0;
    End If;
    Close k_line_cur;
    Open osh_cur;
    Fetch osh_cur Into l_item_type, l_frequency;
    If osh_cur%NotFound Then
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.subs_termn_amount.NI',
                       'intangible non-subscription, no refund');
      END IF;
      l_trmn_amount := l_orig_price;
    End If;
    Close osh_cur;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.subs_termn_amount.details',
                     'Start Date = '||to_char(l_act_start,'DD-MON-YYYY')
                     ||', End Date = '||to_char(l_act_end,'DD-MON-YYYY')
                     ||', Orig. Price = '||l_orig_price
                     ||', Item Type = '||l_item_type||', Frequency = '||l_frequency);
    END IF;
    If l_item_type = 'SI' Then
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.subs_termn_amount.SI','intangible subscription');
      END IF;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.subs_termn_amount.calcvals',
                       'Divisor = '||l_divisor||', Multiplier = '||l_multiplier);
      END IF;
      if l_pricing_method = 'EFFECTIVITY' then
        l_start_date := l_act_start;
        l_end_date   := l_act_end;
        l_tmn_date   := p_termn_date - 1;
      else
        stretch_effectivity(l_act_start, l_act_end, l_frequency, l_start_date, l_end_date);
        stretch_effectivity(l_act_start, p_termn_date - 1, l_frequency, l_start_date, l_tmn_date);
      end if;
      if l_end_date = l_tmn_date then
        l_trmn_amount := l_orig_price;
      else

        -------------------------------------------------------------------------
        -- Begin partial period computation logic
        -- Developer Mani Choudhary
        -- Date 06-JUN-2005
        -- if the profile OKS: Intangible Subscription Pricing Method  is set to
        -- 'EFFECTIVITY' then follow the partial period method
        -------------------------------------------------------------------------
        IF l_pricing_method = 'EFFECTIVITY' AND  l_period_start is NOT NULL THEN
          -- Only effectivity based, then only partial period logic

            l_period_start := 'SERVICE';

          l_uom := map_freq_uom(l_frequency);

 	  --mchoudha Fix for bug#4729993
	  --Calculate the price from term date to end date
          l_divisor := OKS_TIME_MEASURES_PUB.get_quantity
                            (p_start_date   => l_start_date,
                             p_end_date     => l_end_date,
                             p_source_uom   => l_uom,
                             p_period_type  => l_period_type, --new param
                             p_period_start => l_period_start); --new param

          l_multiplier := OKS_TIME_MEASURES_PUB.get_quantity
                            (p_start_date   => l_tmn_date+1,
                             p_end_date     => l_end_date,
                             p_source_uom   => l_uom,
                             p_period_type  => l_period_type, --new param
                             p_period_start => l_period_start); --new param

           l_trmn_amount := l_orig_price - (l_orig_price * l_multiplier / l_divisor);

	ELSE
	  --existing logic
          l_uom := map_freq_uom(l_frequency);
          l_divisor := OKS_TIME_MEASURES_PUB.get_quantity
                            (p_start_date => l_start_date,
                             p_end_date   => l_end_date,
                             p_source_uom => l_uom);

          l_multiplier := OKS_TIME_MEASURES_PUB.get_quantity
                            (p_start_date => l_start_date,
                             p_end_date   => l_tmn_date ,
                             p_source_uom => l_uom);


        l_trmn_amount := l_orig_price * l_multiplier / l_divisor;



        END IF;
        -------------------------------------------------------------------------
        -- End partial period computation logic
        -------------------------------------------------------------------------

        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.subs_termn_amount.calcvals',
                         'Divisor = '||l_divisor||', Multiplier = '||l_multiplier);
        END IF;

      end if;
    Else
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_STATEMENT,G_MODULE_CURRENT||'.subs_termn_amount.tang',
                       'tangible item, fetch amount from elements');
      END IF;
      Open trmn_amt_cur;
      Fetch trmn_amt_cur Into l_trmn_amount;
      If trmn_amt_cur%Found Then
        l_trmn_amount := NVL(l_trmn_amount,0);
      End If;
      Close trmn_amt_cur;
    End If;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,G_MODULE_CURRENT||'.recreate_schedule.end','return = '||l_trmn_amount);
    END IF;
    Return l_trmn_amount;
  Exception
    WHEN EXC_ERROR THEN
        Return NULL;
    WHEN INVALID_HDR_ID_EXCEPTION THEN
        OKC_API.set_message(
         p_app_name     => G_APP_NAME,
         p_msg_name     => G_INVALID_VALUE,
         p_token1       => G_COL_NAME_TOKEN,
         p_token1_value => 'Header ID');
	Return NULL;
    When Others Then
        Return Null;
  End subs_termn_amount;

  Function is_subs_tangible
               ( p_cle_id        IN  NUMBER
               ) Return BOOLEAN IS
    Cursor subs_hdr Is
    Select item_type From oks_subscr_header_b Where cle_id = p_cle_id;
    l_type     Varchar2(240);
    l_tangible Boolean := FALSE;
  Begin
    Open subs_hdr;
    Fetch subs_hdr into l_type;
    IF l_type like '%T' THEN
      l_tangible := TRUE;
    END IF;
    Close subs_hdr;
    Return l_tangible;
  Exception
    When others then
      Return l_tangible;
  End is_subs_tangible;

  Function map_freq_uom
               ( p_frequency     IN  VARCHAR2
               ) Return VARCHAR2 IS
    Cursor uom_cur(p_tce In Varchar2, p_qty Number) Is
      Select uom_code
      From okc_time_code_units_v
      Where tce_code = p_tce
        And quantity = p_qty
        And active_flag = 'Y';
    l_tce_code Varchar2(10);
    l_quantity Number;
    l_uom_code Varchar2(10);
  Begin
    l_quantity := 1;
    IF p_frequency = 'Y' THEN
      l_tce_code := 'YEAR';
    ELSIF p_frequency = 'M' THEN
      l_tce_code := 'MONTH';
    ELSIF p_frequency = 'W' THEN
      l_tce_code := 'DAY';
      l_quantity := 7;
    ELSIF p_frequency = 'D' THEN
      l_tce_code := 'DAY';
    END IF;
    Open uom_cur(l_tce_code,l_quantity);
    Fetch uom_cur Into l_uom_code;
    Close uom_cur;
    Return l_uom_code;
  Exception
    When Others Then
      Return Null;
  End map_freq_uom;

  Procedure db_commit Is
  Begin
    Commit;
  End db_commit;

END OKS_SUBSCRIPTION_PVT;


/
