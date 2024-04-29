--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_SITE_BO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_SITE_BO_PVT" AS
/*$Header: ARHBCSVB.pls 120.11.12010000.2 2008/10/16 22:29:17 awu ship $ */

  -- PRIVATE PROCEDURE assign_cust_site_use_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_site_use_obj  Customer account site use object.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_site_use_id   Customer account site use Id.
  --     p_cust_site_use_os   Customer account site use original system.
  --     p_cust_site_use_osr  Customer account site use original system reference.
  --   IN/OUT:
  --     px_cust_site_use_rec  Customer account site use plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_site_use_rec(
    p_cust_site_use_obj          IN            HZ_CUST_SITE_USE_BO,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_site_use_id           IN            NUMBER,
    p_cust_site_use_os           IN            VARCHAR2,
    p_cust_site_use_osr          IN            VARCHAR2,
    px_cust_site_use_rec         IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_site_use_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_site_use_obj  Customer account site use object.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_site_use_id   Customer account site use Id.
  --     p_cust_site_use_os   Customer account site use original system.
  --     p_cust_site_use_osr  Customer account site use original system reference.
  --   IN/OUT:
  --     px_cust_site_use_rec  Customer account site use plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_site_use_rec(
    p_cust_site_use_obj          IN            HZ_CUST_SITE_USE_BO,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_site_use_id           IN            NUMBER,
    p_cust_site_use_os           IN            VARCHAR2,
    p_cust_site_use_osr          IN            VARCHAR2,
    px_cust_site_use_rec         IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
  ) IS
  BEGIN
    px_cust_site_use_rec.site_use_id           := p_cust_site_use_id;
    px_cust_site_use_rec.cust_acct_site_id     := p_cust_acct_site_id;
    px_cust_site_use_rec.site_use_code         := p_cust_site_use_obj.site_use_code;
    IF(p_cust_site_use_obj.primary_flag in ('Y','N')) THEN
      px_cust_site_use_rec.primary_flag          := p_cust_site_use_obj.primary_flag;
    END IF;
    IF(p_cust_site_use_obj.status in ('A','I')) THEN
      px_cust_site_use_rec.status                := p_cust_site_use_obj.status;
    END IF;
    px_cust_site_use_rec.location              := p_cust_site_use_obj.location;
    px_cust_site_use_rec.bill_to_site_use_id   := p_cust_site_use_obj.bill_to_site_use_id;
    px_cust_site_use_rec.sic_code              := p_cust_site_use_obj.sic_code;
    px_cust_site_use_rec.payment_term_id       := p_cust_site_use_obj.payment_term_id;
    IF(p_cust_site_use_obj.gsa_indicator in ('Y','N')) THEN
      px_cust_site_use_rec.gsa_indicator         := p_cust_site_use_obj.gsa_indicator;
    END IF;
    px_cust_site_use_rec.ship_partial          := p_cust_site_use_obj.ship_partial;
    px_cust_site_use_rec.ship_via              := p_cust_site_use_obj.ship_via;
    px_cust_site_use_rec.fob_point             := p_cust_site_use_obj.fob_point;
    px_cust_site_use_rec.order_type_id         := p_cust_site_use_obj.order_type_id;
    px_cust_site_use_rec.price_list_id         := p_cust_site_use_obj.price_list_id;
    px_cust_site_use_rec.freight_term          := p_cust_site_use_obj.freight_term;
    px_cust_site_use_rec.warehouse_id          := p_cust_site_use_obj.warehouse_id;
    px_cust_site_use_rec.territory_id          := p_cust_site_use_obj.territory_id;
    px_cust_site_use_rec.attribute_category    := p_cust_site_use_obj.attribute_category;
    px_cust_site_use_rec.attribute1            := p_cust_site_use_obj.attribute1;
    px_cust_site_use_rec.attribute2            := p_cust_site_use_obj.attribute2;
    px_cust_site_use_rec.attribute3            := p_cust_site_use_obj.attribute3;
    px_cust_site_use_rec.attribute4            := p_cust_site_use_obj.attribute4;
    px_cust_site_use_rec.attribute5            := p_cust_site_use_obj.attribute5;
    px_cust_site_use_rec.attribute6            := p_cust_site_use_obj.attribute6;
    px_cust_site_use_rec.attribute7            := p_cust_site_use_obj.attribute7;
    px_cust_site_use_rec.attribute8            := p_cust_site_use_obj.attribute8;
    px_cust_site_use_rec.attribute9            := p_cust_site_use_obj.attribute9;
    px_cust_site_use_rec.attribute10           := p_cust_site_use_obj.attribute10;
    px_cust_site_use_rec.attribute11           := p_cust_site_use_obj.attribute11;
    px_cust_site_use_rec.attribute12           := p_cust_site_use_obj.attribute12;
    px_cust_site_use_rec.attribute13           := p_cust_site_use_obj.attribute13;
    px_cust_site_use_rec.attribute14           := p_cust_site_use_obj.attribute14;
    px_cust_site_use_rec.attribute15           := p_cust_site_use_obj.attribute15;
    px_cust_site_use_rec.attribute16           := p_cust_site_use_obj.attribute16;
    px_cust_site_use_rec.attribute17           := p_cust_site_use_obj.attribute17;
    px_cust_site_use_rec.attribute18           := p_cust_site_use_obj.attribute18;
    px_cust_site_use_rec.attribute19           := p_cust_site_use_obj.attribute19;
    px_cust_site_use_rec.attribute20           := p_cust_site_use_obj.attribute20;
    px_cust_site_use_rec.attribute21           := p_cust_site_use_obj.attribute21;
    px_cust_site_use_rec.attribute22           := p_cust_site_use_obj.attribute22;
    px_cust_site_use_rec.attribute23           := p_cust_site_use_obj.attribute23;
    px_cust_site_use_rec.attribute24           := p_cust_site_use_obj.attribute24;
    px_cust_site_use_rec.attribute25           := p_cust_site_use_obj.attribute25;
    px_cust_site_use_rec.tax_reference         := p_cust_site_use_obj.tax_reference;
    px_cust_site_use_rec.sort_priority         := p_cust_site_use_obj.sort_priority;
    px_cust_site_use_rec.tax_code              := p_cust_site_use_obj.tax_code;
    px_cust_site_use_rec.demand_class_code     := p_cust_site_use_obj.demand_class_code;
    px_cust_site_use_rec.tax_header_level_flag := p_cust_site_use_obj.tax_header_level_flag;
    px_cust_site_use_rec.tax_rounding_rule     := p_cust_site_use_obj.tax_rounding_rule;
    px_cust_site_use_rec.global_attribute_category    := p_cust_site_use_obj.global_attribute_category;
    px_cust_site_use_rec.global_attribute1     := p_cust_site_use_obj.global_attribute1;
    px_cust_site_use_rec.global_attribute2     := p_cust_site_use_obj.global_attribute2;
    px_cust_site_use_rec.global_attribute3     := p_cust_site_use_obj.global_attribute3;
    px_cust_site_use_rec.global_attribute4     := p_cust_site_use_obj.global_attribute4;
    px_cust_site_use_rec.global_attribute5     := p_cust_site_use_obj.global_attribute5;
    px_cust_site_use_rec.global_attribute6     := p_cust_site_use_obj.global_attribute6;
    px_cust_site_use_rec.global_attribute7     := p_cust_site_use_obj.global_attribute7;
    px_cust_site_use_rec.global_attribute8     := p_cust_site_use_obj.global_attribute8;
    px_cust_site_use_rec.global_attribute9     := p_cust_site_use_obj.global_attribute9;
    px_cust_site_use_rec.global_attribute10    := p_cust_site_use_obj.global_attribute10;
    px_cust_site_use_rec.global_attribute11    := p_cust_site_use_obj.global_attribute11;
    px_cust_site_use_rec.global_attribute12    := p_cust_site_use_obj.global_attribute12;
    px_cust_site_use_rec.global_attribute13    := p_cust_site_use_obj.global_attribute13;
    px_cust_site_use_rec.global_attribute14    := p_cust_site_use_obj.global_attribute14;
    px_cust_site_use_rec.global_attribute15    := p_cust_site_use_obj.global_attribute15;
    px_cust_site_use_rec.global_attribute16    := p_cust_site_use_obj.global_attribute16;
    px_cust_site_use_rec.global_attribute17    := p_cust_site_use_obj.global_attribute17;
    px_cust_site_use_rec.global_attribute18    := p_cust_site_use_obj.global_attribute18;
    px_cust_site_use_rec.global_attribute19    := p_cust_site_use_obj.global_attribute19;
    px_cust_site_use_rec.global_attribute20    := p_cust_site_use_obj.global_attribute20;
    px_cust_site_use_rec.primary_salesrep_id   := p_cust_site_use_obj.primary_salesrep_id;
    px_cust_site_use_rec.finchrg_receivables_trx_id   := p_cust_site_use_obj.finchrg_receivables_trx_id;
    px_cust_site_use_rec.dates_negative_tolerance  := p_cust_site_use_obj.dates_negative_tolerance;
    px_cust_site_use_rec.dates_positive_tolerance  := p_cust_site_use_obj.dates_positive_tolerance;
    px_cust_site_use_rec.date_type_preference      := p_cust_site_use_obj.date_type_preference;
    px_cust_site_use_rec.over_shipment_tolerance   := p_cust_site_use_obj.over_shipment_tolerance;
    px_cust_site_use_rec.under_shipment_tolerance  := p_cust_site_use_obj.under_shipment_tolerance;
    px_cust_site_use_rec.item_cross_ref_pref   := p_cust_site_use_obj.item_cross_ref_pref;
    px_cust_site_use_rec.over_return_tolerance := p_cust_site_use_obj.over_return_tolerance;
    px_cust_site_use_rec.under_return_tolerance:= p_cust_site_use_obj.under_return_tolerance;
    IF(p_cust_site_use_obj.ship_sets_include_lines_flag in ('Y','N')) THEN
      px_cust_site_use_rec.ship_sets_include_lines_flag := p_cust_site_use_obj.ship_sets_include_lines_flag;
    END IF;
    IF(p_cust_site_use_obj.arrivalsets_incl_lines_flag in ('Y','N')) THEN
      px_cust_site_use_rec.arrivalsets_include_lines_flag := p_cust_site_use_obj.arrivalsets_incl_lines_flag;
    END IF;
    IF(p_cust_site_use_obj.sched_date_push_flag in ('Y','N')) THEN
      px_cust_site_use_rec.sched_date_push_flag  := p_cust_site_use_obj.sched_date_push_flag;
    END IF;
    px_cust_site_use_rec.invoice_quantity_rule := p_cust_site_use_obj.invoice_quantity_rule;
    px_cust_site_use_rec.pricing_event         := p_cust_site_use_obj.pricing_event;
    px_cust_site_use_rec.gl_id_rec             := p_cust_site_use_obj.gl_id_rec;
    px_cust_site_use_rec.gl_id_rev             := p_cust_site_use_obj.gl_id_rev;
    px_cust_site_use_rec.gl_id_tax             := p_cust_site_use_obj.gl_id_tax;
    px_cust_site_use_rec.gl_id_freight         := p_cust_site_use_obj.gl_id_freight;
    px_cust_site_use_rec.gl_id_clearing        := p_cust_site_use_obj.gl_id_clearing;
    px_cust_site_use_rec.gl_id_unbilled        := p_cust_site_use_obj.gl_id_unbilled;
    px_cust_site_use_rec.gl_id_unearned        := p_cust_site_use_obj.gl_id_unearned;
    px_cust_site_use_rec.gl_id_unpaid_rec      := p_cust_site_use_obj.gl_id_unpaid_rec;
    px_cust_site_use_rec.gl_id_remittance      := p_cust_site_use_obj.gl_id_remittance;
    px_cust_site_use_rec.gl_id_factor          := p_cust_site_use_obj.gl_id_factor;
    px_cust_site_use_rec.tax_classification    := p_cust_site_use_obj.tax_classification;
    px_cust_site_use_rec.orig_system           := p_cust_site_use_os;
    px_cust_site_use_rec.orig_system_reference := p_cust_site_use_osr;
    px_cust_site_use_rec.created_by_module     := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    px_cust_site_use_rec.org_id                := p_cust_site_use_obj.org_id;
  END assign_cust_site_use_rec;

  -- PROCEDURE create_cust_site_uses
  --
  -- DESCRIPTION
  --     Create customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE create_cust_site_uses(
    p_casu_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_casu_id                 NUMBER;
    l_casu_os                 VARCHAR2(30);
    l_casu_osr                VARCHAR2(255);
    l_casu_rec                HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
    l_cap_id                  NUMBER;
    l_cap_os                  VARCHAR2(30);
    l_cap_osr                 VARCHAR2(255);
    l_cap_rec                 HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_profile_id              NUMBER;
    l_party_id                NUMBER;

    CURSOR get_party_id(l_ca_id NUMBER) IS
    SELECT party_id
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_ca_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_casu_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create cust site use with site use profile
    -- HZ_CUST_ACCONT_SITE_V2PUB will create cust site use and then
    -- create site use profile
    FOR i IN 1..p_casu_objs.COUNT LOOP
      -- no need to check parent cust_acct_site_id because this id is
      -- passed from BO API, it guarantees the correctness of it
      l_casu_id := p_casu_objs(i).site_use_id;
      l_casu_os := p_casu_objs(i).orig_system;
      l_casu_osr := p_casu_objs(i).orig_system_reference;

      -- check if pass in site_use_id and os+osr
      hz_registry_validate_bo_pvt.validate_ssm_id(
        px_id              => l_casu_id,
        px_os              => l_casu_os,
        px_osr             => l_casu_osr,
        p_org_id           => p_casu_objs(i).org_id,
        p_obj_type         => 'HZ_CUST_SITE_USES_ALL',
        p_create_or_update => 'C',
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      assign_cust_site_use_rec(
        p_cust_site_use_obj         => p_casu_objs(i),
        p_cust_acct_site_id         => p_cas_id,
        p_cust_site_use_id          => l_casu_id,
        p_cust_site_use_os          => l_casu_os,
        p_cust_site_use_osr         => l_casu_osr,
        px_cust_site_use_rec        => l_casu_rec
      );

      HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
        p_cust_site_use_rec         => l_casu_rec,
        p_customer_profile_rec      => NULL,
        p_create_profile            => FND_API.G_FALSE,
        p_create_profile_amt        => FND_API.G_FALSE,
        x_site_use_id               => l_casu_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.create_cust_site_uses, acct_site_id: '||p_cas_id||' , cust_acct_site_os: '||l_casu_os||' , cust_acct_site_osr: '||l_casu_osr,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign site_use_id
      p_casu_objs(i).site_use_id := l_casu_id;

      IF(p_casu_objs(i).site_use_code in ('BILL_TO', 'DUN', 'STMTS') AND
         p_casu_objs(i).site_use_profile_obj IS NOT NULL) THEN
        -- check if BILL_TO, DUN or STMTS to create with profile
        -- no need to pass cust account id since in v2api, the cust account
        -- id will be obtained from cust site id
        HZ_CUST_ACCT_BO_PVT.create_cust_profile(
          p_cp_obj                    => p_casu_objs(i).site_use_profile_obj,
          p_ca_id                     => p_ca_id,
          p_casu_id                   => l_casu_id,
          x_cp_id                     => l_profile_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        HZ_CUST_ACCT_BO_PVT.create_cust_profile_amts(
          p_cpa_objs                => p_casu_objs(i).site_use_profile_obj.cust_profile_amt_objs,
          p_cp_id                   => l_profile_id,
          p_ca_id                   => p_ca_id,
          p_casu_id                 => l_casu_id,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      ------------------------
      -- Call bank account use
      ------------------------
      OPEN get_party_id(p_ca_id);
      FETCH get_party_id INTO l_party_id;
      CLOSE get_party_id;

      IF((p_casu_objs(i).bank_acct_use_objs IS NOT NULL) AND
         (p_casu_objs(i).bank_acct_use_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
          p_bank_acct_use_objs => p_casu_objs(i).bank_acct_use_objs,
          p_party_id           => l_party_id,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      ------------------------
      -- Call payment method
      ------------------------
      IF(p_casu_objs(i).payment_method_obj IS NOT NULL) THEN
        HZ_CUST_ACCT_BO_PVT.create_payment_method(
          p_payment_method_obj => p_casu_objs(i).payment_method_obj,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_casu_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_casu_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_casu_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_cust_site_uses;

  -- PROCEDURE save_cust_site_uses
  --
  -- DESCRIPTION
  --     Create or update customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE save_cust_site_uses(
    p_casu_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_casu_id                  NUMBER;
    l_casu_os                  VARCHAR2(30);
    l_casu_osr                 VARCHAR2(255);
    l_casu_rec                 HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
    l_cap_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_ovn                      NUMBER;
    l_cap_ovn                  NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_profile_id               NUMBER;
    l_party_id                 NUMBER;
    l_site_use_code            VARCHAR2(30);
    l_parent_id                NUMBER;
    l_parent_obj_type          VARCHAR2(30);

    CURSOR get_cap_id(l_ca_id NUMBER, l_casu_id NUMBER, l_profile_class_id NUMBER) IS
    SELECT cust_account_profile_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_id = l_ca_id
    AND site_use_id = l_casu_id
    AND profile_class_id = l_profile_class_id
    AND status IN ('A','I');

    CURSOR get_ovn(l_casu_id NUMBER) IS
    SELECT site_use_code, object_version_number
    FROM HZ_CUST_SITE_USES
    WHERE site_use_id = l_casu_id
    AND status in ('A','I');

    CURSOR get_party_id(l_ca_id NUMBER) IS
    SELECT party_id
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_ca_id;

    CURSOR get_casu_id(l_cas_id NUMBER, l_su_code VARCHAR2, l_org_id NUMBER) IS
    SELECT site_use_id
    FROM HZ_CUST_SITE_USES_ALL
    WHERE cust_acct_site_id = l_cas_id
    AND site_use_code = l_su_code
    AND status = 'A'
    AND org_id = l_org_id
    AND rownum = 1;

  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_casu_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update cust site uses
    FOR i IN 1..p_casu_objs.COUNT LOOP
      l_casu_id := p_casu_objs(i).site_use_id;
      l_casu_os := p_casu_objs(i).orig_system;
      l_casu_osr := p_casu_objs(i).orig_system_reference;

      IF(p_cas_id IS NOT NULL) THEN
        l_parent_id := p_cas_id;
        l_parent_obj_type := 'CUST_ACCT_SITE';
	if p_casu_objs(i).site_use_id is null and l_casu_os = 'ORACLE_AIA' -- AIA enh 7209179
        then
    		open get_casu_id(p_cas_id,p_casu_objs(i).site_use_code,p_casu_objs(i).org_id);
        	fetch get_casu_id into l_casu_id;
		close get_casu_id;
		if  l_casu_id is not null
		then
			l_casu_os := null;
      			l_casu_osr := null;
			l_casu_rec.site_use_id := l_casu_id;
	        	l_casu_rec.orig_system := null;
			l_casu_rec.orig_system_reference := null;
		end if;
    	end if;
      ELSE
        l_parent_id := p_ca_id;
        l_parent_obj_type := 'CUST_ACCT';
      END IF;

      -- check root business object to determine that it should be
      -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
      l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                                p_entity_id      => l_casu_id,
                                p_entity_os      => l_casu_os,
                                p_entity_osr     => l_casu_osr,
                                p_entity_type    => 'HZ_CUST_SITE_USES_ALL',
                                p_parent_id      => l_parent_id,
                                p_parent_obj_type=> l_parent_obj_type
                              );

      IF(l_create_update_flag = 'E') THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- check if the cust site use record is create or update
      -- since cust site use has os+osr, use os+osr to check if record exist or not
      IF(l_create_update_flag = 'C') THEN
        assign_cust_site_use_rec(
          p_cust_site_use_obj           => p_casu_objs(i),
          p_cust_acct_site_id           => p_cas_id,
          p_cust_site_use_id            => l_casu_id,
          p_cust_site_use_os            => l_casu_os,
          p_cust_site_use_osr           => l_casu_osr,
          px_cust_site_use_rec          => l_casu_rec
        );

        HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
          p_cust_site_use_rec         => l_casu_rec,
          p_customer_profile_rec      => NULL,
          p_create_profile            => FND_API.G_FALSE,
          p_create_profile_amt        => FND_API.G_FALSE,
          x_site_use_id               => l_casu_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_site_uses, acct_site_id: '||p_cas_id||' , cust_acct_site_os: '||l_casu_os||' , cust_acct_site_osr: '||l_casu_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- assign site_use_id
        p_casu_objs(i).site_use_id := l_casu_id;

        IF(p_casu_objs(i).site_use_code in ('BILL_TO', 'DUN', 'STMTS') AND
           p_casu_objs(i).site_use_profile_obj IS NOT NULL) THEN
          -- check if BILL_TO, DUN and STMTS to create with profile
          HZ_CUST_ACCT_BO_PVT.create_cust_profile(
            p_cp_obj                    => p_casu_objs(i).site_use_profile_obj,
            p_ca_id                     => p_ca_id,
            p_casu_id                   => l_casu_id,
            x_cp_id                     => l_profile_id,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_CUST_ACCT_BO_PVT.create_cust_profile_amts(
            p_cpa_objs                => p_casu_objs(i).site_use_profile_obj.cust_profile_amt_objs,
            p_cp_id                   => l_profile_id,
            p_ca_id                   => p_ca_id,
            p_casu_id                 => l_casu_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;

      ELSE
        hz_registry_validate_bo_pvt.validate_ssm_id(
          px_id                       => l_casu_id,
          px_os                       => l_casu_os,
          px_osr                      => l_casu_osr,
          p_org_id                    => p_casu_objs(i).org_id,
          p_obj_type                  => 'HZ_CUST_SITE_USES_ALL',
          p_create_or_update          => 'U',
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN get_ovn(l_casu_id);
        FETCH get_ovn INTO l_site_use_code, l_ovn;
        CLOSE get_ovn;

        assign_cust_site_use_rec(
          p_cust_site_use_obj         => p_casu_objs(i),
          p_cust_acct_site_id         => p_cas_id,
          p_cust_site_use_id          => l_casu_id,
          p_cust_site_use_os          => l_casu_os,
          p_cust_site_use_osr         => l_casu_osr,
          px_cust_site_use_rec        => l_casu_rec
        );

        -- clean up created_by_module, os and osr for update
        l_casu_rec.created_by_module := NULL;
        l_casu_rec.orig_system := NULL;
        l_casu_rec.orig_system_reference := NULL;
        HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_site_use (
          p_cust_site_use_rec         => l_casu_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_site_uses, acct_site_id: '||p_cas_id||' , cust_acct_site_os: '||l_casu_os||' , cust_acct_site_osr: '||l_casu_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- assign site_use_id
        p_casu_objs(i).site_use_id := l_casu_id;

        IF(l_site_use_code in ('BILL_TO', 'DUN', 'STMTS') AND
           p_casu_objs(i).site_use_profile_obj IS NOT NULL) THEN
          -- need to update customer profile
          HZ_CUST_ACCT_BO_PVT.update_cust_profile(
            p_cp_obj                  => p_casu_objs(i).site_use_profile_obj,
            p_ca_id                   => p_ca_id,
            p_casu_id                 => l_casu_id,
            x_cp_id                   => l_profile_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_CUST_ACCT_BO_PVT.save_cust_profile_amts(
            p_cpa_objs                => p_casu_objs(i).site_use_profile_obj.cust_profile_amt_objs,
            p_cp_id                   => l_profile_id,
            p_ca_id                   => p_ca_id,
            p_casu_id                 => l_casu_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );
        END IF;
      END IF;

      ------------------------
      -- Call bank account use
      ------------------------
      OPEN get_party_id(p_ca_id);
      FETCH get_party_id INTO l_party_id;
      CLOSE get_party_id;

      IF((p_casu_objs(i).bank_acct_use_objs IS NOT NULL) AND
         (p_casu_objs(i).bank_acct_use_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
          p_bank_acct_use_objs => p_casu_objs(i).bank_acct_use_objs,
          p_party_id           => l_party_id,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      ------------------------
      -- Call payment method
      ------------------------
      IF(p_casu_objs(i).payment_method_obj IS NOT NULL) THEN
        HZ_CUST_ACCT_BO_PVT.save_payment_method(
          p_payment_method_obj => p_casu_objs(i).payment_method_obj,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_casu_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_casu_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_casu_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_site_uses;

  -- PROCEDURE save_cust_acct_sites
  --
  -- DESCRIPTION
  --     Create or update customer account sites.
  PROCEDURE save_cust_acct_sites(
    p_cas_objs                IN OUT NOCOPY HZ_CUST_ACCT_SITE_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_acct_id          IN            NUMBER,
    p_parent_acct_os          IN            VARCHAR2,
    p_parent_acct_osr         IN            VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cas_id                  NUMBER;
    l_cas_os                  VARCHAR2(30);
    l_cas_osr                 VARCHAR2(255);
    l_parent_acct_id          NUMBER;
    l_parent_acct_os          VARCHAR2(30);
    l_parent_acct_osr         VARCHAR2(255);
    l_cbm                     VARCHAR2(30);
  BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_sites(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_acct_id := p_parent_acct_id;
    l_parent_acct_os := p_parent_acct_os;
    l_parent_acct_osr := p_parent_acct_osr;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -- Create cust account sites
      FOR i IN 1..p_cas_objs.COUNT LOOP
        HZ_CUST_ACCT_SITE_BO_PUB.do_create_cust_acct_site_bo(
          p_init_msg_list           => fnd_api.g_false,
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_site_obj      => p_cas_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_site_id       => l_cas_id,
          x_cust_acct_site_os       => l_cas_os,
          x_cust_acct_site_osr      => l_cas_osr,
          px_parent_acct_id         => l_parent_acct_id,
          px_parent_acct_os         => l_parent_acct_os,
          px_parent_acct_osr        => l_parent_acct_osr
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_acct_sites, parent id: '||l_parent_acct_id||' '||l_parent_acct_os||'-'||l_parent_acct_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      -- Create/update cust account site
      FOR i IN 1..p_cas_objs.COUNT LOOP
        HZ_CUST_ACCT_SITE_BO_PUB.do_save_cust_acct_site_bo(
          p_init_msg_list           => fnd_api.g_false,
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_site_obj      => p_cas_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_site_id       => l_cas_id,
          x_cust_acct_site_os       => l_cas_os,
          x_cust_acct_site_osr      => l_cas_osr,
          px_parent_acct_id         => l_parent_acct_id,
          px_parent_acct_os         => l_parent_acct_os,
          px_parent_acct_osr        => l_parent_acct_osr
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_acct_sites, parent id: '||l_parent_acct_id||' '||l_parent_acct_os||'-'||l_parent_acct_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_acct_sites;

-- PRIVATE PROCEDURE assign_cust_site_use_v2_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_site_use_v2_obj  Customer account site use object.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_site_use_id   Customer account site use Id.
  --     p_cust_site_use_os   Customer account site use original system.
  --     p_cust_site_use_osr  Customer account site use original system reference.
  --   IN/OUT:
  --     px_cust_site_use_rec  Customer account site use plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.

  PROCEDURE assign_cust_site_use_v2_rec(
    p_cust_site_use_v2_obj          IN            HZ_CUST_SITE_USE_V2_BO,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_site_use_id           IN            NUMBER,
    p_cust_site_use_os           IN            VARCHAR2,
    p_cust_site_use_osr          IN            VARCHAR2,
    px_cust_site_use_rec         IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_site_use_v2_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account site use object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_site_use_v2_obj  Customer account site use object.
  --     p_cust_acct_site_id  Customer account site Id.
  --     p_cust_site_use_id   Customer account site use Id.
  --     p_cust_site_use_os   Customer account site use original system.
  --     p_cust_site_use_osr  Customer account site use original system reference.
  --   IN/OUT:
  --     px_cust_site_use_rec  Customer account site use plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.

  PROCEDURE assign_cust_site_use_v2_rec(
    p_cust_site_use_v2_obj          IN            HZ_CUST_SITE_USE_V2_BO,
    p_cust_acct_site_id          IN            NUMBER,
    p_cust_site_use_id           IN            NUMBER,
    p_cust_site_use_os           IN            VARCHAR2,
    p_cust_site_use_osr          IN            VARCHAR2,
    px_cust_site_use_rec         IN OUT NOCOPY HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE
  ) IS
  BEGIN
    px_cust_site_use_rec.site_use_id           := p_cust_site_use_id;
    px_cust_site_use_rec.cust_acct_site_id     := p_cust_acct_site_id;
    px_cust_site_use_rec.site_use_code         := p_cust_site_use_v2_obj.site_use_code;
    IF(p_cust_site_use_v2_obj.primary_flag in ('Y','N')) THEN
      px_cust_site_use_rec.primary_flag          := p_cust_site_use_v2_obj.primary_flag;
    END IF;
    IF(p_cust_site_use_v2_obj.status in ('A','I')) THEN
      px_cust_site_use_rec.status                := p_cust_site_use_v2_obj.status;
    END IF;
    px_cust_site_use_rec.location              := p_cust_site_use_v2_obj.location;
    px_cust_site_use_rec.bill_to_site_use_id   := p_cust_site_use_v2_obj.bill_to_site_use_id;
    px_cust_site_use_rec.sic_code              := p_cust_site_use_v2_obj.sic_code;
    px_cust_site_use_rec.payment_term_id       := p_cust_site_use_v2_obj.payment_term_id;
    IF(p_cust_site_use_v2_obj.gsa_indicator in ('Y','N')) THEN
      px_cust_site_use_rec.gsa_indicator         := p_cust_site_use_v2_obj.gsa_indicator;
    END IF;
    px_cust_site_use_rec.ship_partial          := p_cust_site_use_v2_obj.ship_partial;
    px_cust_site_use_rec.ship_via              := p_cust_site_use_v2_obj.ship_via;
    px_cust_site_use_rec.fob_point             := p_cust_site_use_v2_obj.fob_point;
    px_cust_site_use_rec.order_type_id         := p_cust_site_use_v2_obj.order_type_id;
    px_cust_site_use_rec.price_list_id         := p_cust_site_use_v2_obj.price_list_id;
    px_cust_site_use_rec.freight_term          := p_cust_site_use_v2_obj.freight_term;
    px_cust_site_use_rec.warehouse_id          := p_cust_site_use_v2_obj.warehouse_id;
    px_cust_site_use_rec.territory_id          := p_cust_site_use_v2_obj.territory_id;
    px_cust_site_use_rec.attribute_category    := p_cust_site_use_v2_obj.attribute_category;
    px_cust_site_use_rec.attribute1            := p_cust_site_use_v2_obj.attribute1;
    px_cust_site_use_rec.attribute2            := p_cust_site_use_v2_obj.attribute2;
    px_cust_site_use_rec.attribute3            := p_cust_site_use_v2_obj.attribute3;
    px_cust_site_use_rec.attribute4            := p_cust_site_use_v2_obj.attribute4;
    px_cust_site_use_rec.attribute5            := p_cust_site_use_v2_obj.attribute5;
    px_cust_site_use_rec.attribute6            := p_cust_site_use_v2_obj.attribute6;
    px_cust_site_use_rec.attribute7            := p_cust_site_use_v2_obj.attribute7;
    px_cust_site_use_rec.attribute8            := p_cust_site_use_v2_obj.attribute8;
    px_cust_site_use_rec.attribute9            := p_cust_site_use_v2_obj.attribute9;
    px_cust_site_use_rec.attribute10           := p_cust_site_use_v2_obj.attribute10;
    px_cust_site_use_rec.attribute11           := p_cust_site_use_v2_obj.attribute11;
    px_cust_site_use_rec.attribute12           := p_cust_site_use_v2_obj.attribute12;
    px_cust_site_use_rec.attribute13           := p_cust_site_use_v2_obj.attribute13;
    px_cust_site_use_rec.attribute14           := p_cust_site_use_v2_obj.attribute14;
    px_cust_site_use_rec.attribute15           := p_cust_site_use_v2_obj.attribute15;
    px_cust_site_use_rec.attribute16           := p_cust_site_use_v2_obj.attribute16;
    px_cust_site_use_rec.attribute17           := p_cust_site_use_v2_obj.attribute17;
    px_cust_site_use_rec.attribute18           := p_cust_site_use_v2_obj.attribute18;
    px_cust_site_use_rec.attribute19           := p_cust_site_use_v2_obj.attribute19;
    px_cust_site_use_rec.attribute20           := p_cust_site_use_v2_obj.attribute20;
    px_cust_site_use_rec.attribute21           := p_cust_site_use_v2_obj.attribute21;
    px_cust_site_use_rec.attribute22           := p_cust_site_use_v2_obj.attribute22;
    px_cust_site_use_rec.attribute23           := p_cust_site_use_v2_obj.attribute23;
    px_cust_site_use_rec.attribute24           := p_cust_site_use_v2_obj.attribute24;
    px_cust_site_use_rec.attribute25           := p_cust_site_use_v2_obj.attribute25;
    px_cust_site_use_rec.tax_reference         := p_cust_site_use_v2_obj.tax_reference;
    px_cust_site_use_rec.sort_priority         := p_cust_site_use_v2_obj.sort_priority;
    px_cust_site_use_rec.tax_code              := p_cust_site_use_v2_obj.tax_code;
    px_cust_site_use_rec.demand_class_code     := p_cust_site_use_v2_obj.demand_class_code;
    px_cust_site_use_rec.tax_header_level_flag := p_cust_site_use_v2_obj.tax_header_level_flag;
    px_cust_site_use_rec.tax_rounding_rule     := p_cust_site_use_v2_obj.tax_rounding_rule;
    px_cust_site_use_rec.global_attribute_category    := p_cust_site_use_v2_obj.global_attribute_category;
    px_cust_site_use_rec.global_attribute1     := p_cust_site_use_v2_obj.global_attribute1;
    px_cust_site_use_rec.global_attribute2     := p_cust_site_use_v2_obj.global_attribute2;
    px_cust_site_use_rec.global_attribute3     := p_cust_site_use_v2_obj.global_attribute3;
    px_cust_site_use_rec.global_attribute4     := p_cust_site_use_v2_obj.global_attribute4;
    px_cust_site_use_rec.global_attribute5     := p_cust_site_use_v2_obj.global_attribute5;
    px_cust_site_use_rec.global_attribute6     := p_cust_site_use_v2_obj.global_attribute6;
    px_cust_site_use_rec.global_attribute7     := p_cust_site_use_v2_obj.global_attribute7;
    px_cust_site_use_rec.global_attribute8     := p_cust_site_use_v2_obj.global_attribute8;
    px_cust_site_use_rec.global_attribute9     := p_cust_site_use_v2_obj.global_attribute9;
    px_cust_site_use_rec.global_attribute10    := p_cust_site_use_v2_obj.global_attribute10;
    px_cust_site_use_rec.global_attribute11    := p_cust_site_use_v2_obj.global_attribute11;
    px_cust_site_use_rec.global_attribute12    := p_cust_site_use_v2_obj.global_attribute12;
    px_cust_site_use_rec.global_attribute13    := p_cust_site_use_v2_obj.global_attribute13;
    px_cust_site_use_rec.global_attribute14    := p_cust_site_use_v2_obj.global_attribute14;
    px_cust_site_use_rec.global_attribute15    := p_cust_site_use_v2_obj.global_attribute15;
    px_cust_site_use_rec.global_attribute16    := p_cust_site_use_v2_obj.global_attribute16;
    px_cust_site_use_rec.global_attribute17    := p_cust_site_use_v2_obj.global_attribute17;
    px_cust_site_use_rec.global_attribute18    := p_cust_site_use_v2_obj.global_attribute18;
    px_cust_site_use_rec.global_attribute19    := p_cust_site_use_v2_obj.global_attribute19;
    px_cust_site_use_rec.global_attribute20    := p_cust_site_use_v2_obj.global_attribute20;
    px_cust_site_use_rec.primary_salesrep_id   := p_cust_site_use_v2_obj.primary_salesrep_id;
    px_cust_site_use_rec.finchrg_receivables_trx_id   := p_cust_site_use_v2_obj.finchrg_receivables_trx_id;
    px_cust_site_use_rec.dates_negative_tolerance  := p_cust_site_use_v2_obj.dates_negative_tolerance;
    px_cust_site_use_rec.dates_positive_tolerance  := p_cust_site_use_v2_obj.dates_positive_tolerance;
    px_cust_site_use_rec.date_type_preference      := p_cust_site_use_v2_obj.date_type_preference;
    px_cust_site_use_rec.over_shipment_tolerance   := p_cust_site_use_v2_obj.over_shipment_tolerance;
    px_cust_site_use_rec.under_shipment_tolerance  := p_cust_site_use_v2_obj.under_shipment_tolerance;
    px_cust_site_use_rec.item_cross_ref_pref   := p_cust_site_use_v2_obj.item_cross_ref_pref;
    px_cust_site_use_rec.over_return_tolerance := p_cust_site_use_v2_obj.over_return_tolerance;
    px_cust_site_use_rec.under_return_tolerance:= p_cust_site_use_v2_obj.under_return_tolerance;
    IF(p_cust_site_use_v2_obj.ship_sets_include_lines_flag in ('Y','N')) THEN
      px_cust_site_use_rec.ship_sets_include_lines_flag := p_cust_site_use_v2_obj.ship_sets_include_lines_flag;
    END IF;
    IF(p_cust_site_use_v2_obj.arrivalsets_incl_lines_flag in ('Y','N')) THEN
      px_cust_site_use_rec.arrivalsets_include_lines_flag := p_cust_site_use_v2_obj.arrivalsets_incl_lines_flag;
    END IF;
    IF(p_cust_site_use_v2_obj.sched_date_push_flag in ('Y','N')) THEN
      px_cust_site_use_rec.sched_date_push_flag  := p_cust_site_use_v2_obj.sched_date_push_flag;
    END IF;
    px_cust_site_use_rec.invoice_quantity_rule := p_cust_site_use_v2_obj.invoice_quantity_rule;
    px_cust_site_use_rec.pricing_event         := p_cust_site_use_v2_obj.pricing_event;
    px_cust_site_use_rec.gl_id_rec             := p_cust_site_use_v2_obj.gl_id_rec;
    px_cust_site_use_rec.gl_id_rev             := p_cust_site_use_v2_obj.gl_id_rev;
    px_cust_site_use_rec.gl_id_tax             := p_cust_site_use_v2_obj.gl_id_tax;
    px_cust_site_use_rec.gl_id_freight         := p_cust_site_use_v2_obj.gl_id_freight;
    px_cust_site_use_rec.gl_id_clearing        := p_cust_site_use_v2_obj.gl_id_clearing;
    px_cust_site_use_rec.gl_id_unbilled        := p_cust_site_use_v2_obj.gl_id_unbilled;
    px_cust_site_use_rec.gl_id_unearned        := p_cust_site_use_v2_obj.gl_id_unearned;
    px_cust_site_use_rec.gl_id_unpaid_rec      := p_cust_site_use_v2_obj.gl_id_unpaid_rec;
    px_cust_site_use_rec.gl_id_remittance      := p_cust_site_use_v2_obj.gl_id_remittance;
    px_cust_site_use_rec.gl_id_factor          := p_cust_site_use_v2_obj.gl_id_factor;
    px_cust_site_use_rec.tax_classification    := p_cust_site_use_v2_obj.tax_classification;
    px_cust_site_use_rec.orig_system           := p_cust_site_use_os;
    px_cust_site_use_rec.orig_system_reference := p_cust_site_use_osr;
    px_cust_site_use_rec.created_by_module     := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    px_cust_site_use_rec.org_id                := p_cust_site_use_v2_obj.org_id;
  END assign_cust_site_use_v2_rec;

-- PROCEDURE create_cust_site_v2_uses
  --
  -- DESCRIPTION
  --     Create customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_v2_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.

  PROCEDURE create_cust_site_v2_uses(
    p_casu_v2_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_V2_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_casu_id                 NUMBER;
    l_casu_os                 VARCHAR2(30);
    l_casu_osr                VARCHAR2(255);
    l_casu_rec                HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
    l_cap_id                  NUMBER;
    l_cap_os                  VARCHAR2(30);
    l_cap_osr                 VARCHAR2(255);
    l_cap_rec                 HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_profile_id              NUMBER;
    l_party_id                NUMBER;

    CURSOR get_party_id(l_ca_id NUMBER) IS
    SELECT party_id
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_ca_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT create_casu_v2_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_v2_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create cust site use with site use profile
    -- HZ_CUST_ACCONT_SITE_V2PUB will create cust site use and then
    -- create site use profile
    FOR i IN 1..p_casu_v2_objs.COUNT LOOP
      -- no need to check parent cust_acct_site_id because this id is
      -- passed from BO API, it guarantees the correctness of it
      l_casu_id := p_casu_v2_objs(i).site_use_id;
      l_casu_os := p_casu_v2_objs(i).orig_system;
      l_casu_osr := p_casu_v2_objs(i).orig_system_reference;

      -- check if pass in site_use_id and os+osr
      hz_registry_validate_bo_pvt.validate_ssm_id(
        px_id              => l_casu_id,
        px_os              => l_casu_os,
        px_osr             => l_casu_osr,
        p_org_id           => p_casu_v2_objs(i).org_id,
        p_obj_type         => 'HZ_CUST_SITE_USES_ALL',
        p_create_or_update => 'C',
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      assign_cust_site_use_v2_rec(
        p_cust_site_use_v2_obj         => p_casu_v2_objs(i),
        p_cust_acct_site_id         => p_cas_id,
        p_cust_site_use_id          => l_casu_id,
        p_cust_site_use_os          => l_casu_os,
        p_cust_site_use_osr         => l_casu_osr,
        px_cust_site_use_rec        => l_casu_rec
      );

      HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
        p_cust_site_use_rec         => l_casu_rec,
        p_customer_profile_rec      => NULL,
        p_create_profile            => FND_API.G_FALSE,
        p_create_profile_amt        => FND_API.G_FALSE,
        x_site_use_id               => l_casu_id,
        x_return_status             => x_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.create_cust_site_v2_uses, acct_site_id: '||p_cas_id||' , cust_acct_site_os: '||l_casu_os||' , cust_acct_site_osr: '||l_casu_osr,
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign site_use_id
      p_casu_v2_objs(i).site_use_id := l_casu_id;

      IF(p_casu_v2_objs(i).site_use_code in ('BILL_TO', 'DUN', 'STMTS') AND
         p_casu_v2_objs(i).site_use_profile_obj IS NOT NULL) THEN
        -- check if BILL_TO, DUN or STMTS to create with profile
        -- no need to pass cust account id since in v2api, the cust account
        -- id will be obtained from cust site id
        HZ_CUST_ACCT_BO_PVT.create_cust_profile(
          p_cp_obj                    => p_casu_v2_objs(i).site_use_profile_obj,
          p_ca_id                     => p_ca_id,
          p_casu_id                   => l_casu_id,
          x_cp_id                     => l_profile_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        HZ_CUST_ACCT_BO_PVT.create_cust_profile_amts(
          p_cpa_objs                => p_casu_v2_objs(i).site_use_profile_obj.cust_profile_amt_objs,
          p_cp_id                   => l_profile_id,
          p_ca_id                   => p_ca_id,
          p_casu_id                 => l_casu_id,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      ------------------------
      -- Call bank account use
      ------------------------
      OPEN get_party_id(p_ca_id);
      FETCH get_party_id INTO l_party_id;
      CLOSE get_party_id;

      IF((p_casu_v2_objs(i).bank_acct_use_objs IS NOT NULL) AND
         (p_casu_v2_objs(i).bank_acct_use_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
          p_bank_acct_use_objs => p_casu_v2_objs(i).bank_acct_use_objs,
          p_party_id           => l_party_id,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      ------------------------
      -- Call payment method
      ------------------------
      IF((p_casu_v2_objs(i).payment_method_objs IS NOT NULL) AND
          (p_casu_v2_objs(i).payment_method_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.create_payment_methods(
          p_payment_method_objs => p_casu_v2_objs(i).payment_method_objs,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_casu_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_casu_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_casu_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END create_cust_site_v2_uses;

-- PROCEDURE save_cust_site_v2_uses
  --
  -- DESCRIPTION
  --     Create or update customer account site uses.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_casu_v2_objs          List of customer account site use objects.
  --     p_ca_id              Customer account Id.
  --     p_cas_id             Customer account site Id.
  --     p_parent_os          Parent original system.
  --   OUT:
  --     x_return_status      Return status after the call. The status can
  --                          be fnd_api.g_ret_sts_success (success),
  --                          fnd_api.g_ret_sts_error (error),
  --                          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --     x_msg_count          Number of messages in message stack.
  --     x_msg_data           Message text if x_msg_count is 1.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   31-JAN-2008    vsegu          Created.

  PROCEDURE save_cust_site_v2_uses(
    p_casu_v2_objs               IN OUT NOCOPY HZ_CUST_SITE_USE_V2_BO_TBL,
    p_ca_id                   IN            NUMBER,
    p_cas_id                  IN            NUMBER,
    p_parent_os               IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_casu_id                  NUMBER;
    l_casu_os                  VARCHAR2(30);
    l_casu_osr                 VARCHAR2(255);
    l_casu_rec                 HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
    l_cap_rec                  HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    l_ovn                      NUMBER;
    l_cap_ovn                  NUMBER;
    l_create_update_flag       VARCHAR2(1);
    l_profile_id               NUMBER;
    l_party_id                 NUMBER;
    l_site_use_code            VARCHAR2(30);
    l_parent_id                NUMBER;
    l_parent_obj_type          VARCHAR2(30);

    CURSOR get_cap_id(l_ca_id NUMBER, l_casu_id NUMBER, l_profile_class_id NUMBER) IS
    SELECT cust_account_profile_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_id = l_ca_id
    AND site_use_id = l_casu_id
    AND profile_class_id = l_profile_class_id
    AND status IN ('A','I');

    CURSOR get_ovn(l_casu_id NUMBER) IS
    SELECT site_use_code, object_version_number
    FROM HZ_CUST_SITE_USES
    WHERE site_use_id = l_casu_id
    AND status in ('A','I');

    CURSOR get_party_id(l_ca_id NUMBER) IS
    SELECT party_id
    FROM HZ_CUST_ACCOUNTS
    WHERE cust_account_id = l_ca_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT save_casu_v2_pvt;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_v2_uses(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Create/Update cust site uses
    FOR i IN 1..p_casu_v2_objs.COUNT LOOP
      l_casu_id := p_casu_v2_objs(i).site_use_id;
      l_casu_os := p_casu_v2_objs(i).orig_system;
      l_casu_osr := p_casu_v2_objs(i).orig_system_reference;

      IF(p_cas_id IS NOT NULL) THEN
        l_parent_id := p_cas_id;
        l_parent_obj_type := 'CUST_ACCT_SITE';
      ELSE
        l_parent_id := p_ca_id;
        l_parent_obj_type := 'CUST_ACCT';
      END IF;

      -- check root business object to determine that it should be
      -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
      l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                                p_entity_id      => l_casu_id,
                                p_entity_os      => l_casu_os,
                                p_entity_osr     => l_casu_osr,
                                p_entity_type    => 'HZ_CUST_SITE_USES_ALL',
                                p_parent_id      => l_parent_id,
                                p_parent_obj_type=> l_parent_obj_type
                              );

      IF(l_create_update_flag = 'E') THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
        FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- check if the cust site use record is create or update
      -- since cust site use has os+osr, use os+osr to check if record exist or not
      IF(l_create_update_flag = 'C') THEN
        assign_cust_site_use_v2_rec(
          p_cust_site_use_v2_obj           => p_casu_v2_objs(i),
          p_cust_acct_site_id           => p_cas_id,
          p_cust_site_use_id            => l_casu_id,
          p_cust_site_use_os            => l_casu_os,
          p_cust_site_use_osr           => l_casu_osr,
          px_cust_site_use_rec          => l_casu_rec
        );

        HZ_CUST_ACCOUNT_SITE_V2PUB.create_cust_site_use (
          p_cust_site_use_rec         => l_casu_rec,
          p_customer_profile_rec      => NULL,
          p_create_profile            => FND_API.G_FALSE,
          p_create_profile_amt        => FND_API.G_FALSE,
          x_site_use_id               => l_casu_id,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_site_v2_uses, acct_site_id: '||p_cas_id||' , cust_acct_site_os: '||l_casu_os||' , cust_acct_site_osr: '||l_casu_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- assign site_use_id
        p_casu_v2_objs(i).site_use_id := l_casu_id;

        IF(p_casu_v2_objs(i).site_use_code in ('BILL_TO', 'DUN', 'STMTS') AND
           p_casu_v2_objs(i).site_use_profile_obj IS NOT NULL) THEN
          -- check if BILL_TO, DUN and STMTS to create with profile
          HZ_CUST_ACCT_BO_PVT.create_cust_profile(
            p_cp_obj                    => p_casu_v2_objs(i).site_use_profile_obj,
            p_ca_id                     => p_ca_id,
            p_casu_id                   => l_casu_id,
            x_cp_id                     => l_profile_id,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_CUST_ACCT_BO_PVT.create_cust_profile_amts(
            p_cpa_objs                => p_casu_v2_objs(i).site_use_profile_obj.cust_profile_amt_objs,
            p_cp_id                   => l_profile_id,
            p_ca_id                   => p_ca_id,
            p_casu_id                 => l_casu_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END IF;

      ELSE
        hz_registry_validate_bo_pvt.validate_ssm_id(
          px_id                       => l_casu_id,
          px_os                       => l_casu_os,
          px_osr                      => l_casu_osr,
          p_org_id                    => p_casu_v2_objs(i).org_id,
          p_obj_type                  => 'HZ_CUST_SITE_USES_ALL',
          p_create_or_update          => 'U',
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        OPEN get_ovn(l_casu_id);
        FETCH get_ovn INTO l_site_use_code, l_ovn;
        CLOSE get_ovn;

        assign_cust_site_use_v2_rec(
          p_cust_site_use_v2_obj         => p_casu_v2_objs(i),
          p_cust_acct_site_id         => p_cas_id,
          p_cust_site_use_id          => l_casu_id,
          p_cust_site_use_os          => l_casu_os,
          p_cust_site_use_osr         => l_casu_osr,
          px_cust_site_use_rec        => l_casu_rec
        );

        -- clean up created_by_module, os and osr for update
        l_casu_rec.created_by_module := NULL;
        l_casu_rec.orig_system := NULL;
        l_casu_rec.orig_system_reference := NULL;
        HZ_CUST_ACCOUNT_SITE_V2PUB.update_cust_site_use (
          p_cust_site_use_rec         => l_casu_rec,
          p_object_version_number     => l_ovn,
          x_return_status             => x_return_status,
          x_msg_count                 => x_msg_count,
          x_msg_data                  => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_site_v2_uses, acct_site_id: '||p_cas_id||' , cust_acct_site_os: '||l_casu_os||' , cust_acct_site_osr: '||l_casu_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        -- assign site_use_id
        p_casu_v2_objs(i).site_use_id := l_casu_id;

        IF(l_site_use_code in ('BILL_TO', 'DUN', 'STMTS') AND
           p_casu_v2_objs(i).site_use_profile_obj IS NOT NULL) THEN
          -- need to update customer profile
          HZ_CUST_ACCT_BO_PVT.update_cust_profile(
            p_cp_obj                  => p_casu_v2_objs(i).site_use_profile_obj,
            p_ca_id                   => p_ca_id,
            p_casu_id                 => l_casu_id,
            x_cp_id                   => l_profile_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          HZ_CUST_ACCT_BO_PVT.save_cust_profile_amts(
            p_cpa_objs                => p_casu_v2_objs(i).site_use_profile_obj.cust_profile_amt_objs,
            p_cp_id                   => l_profile_id,
            p_ca_id                   => p_ca_id,
            p_casu_id                 => l_casu_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );
        END IF;
      END IF;

      ------------------------
      -- Call bank account use
      ------------------------
      OPEN get_party_id(p_ca_id);
      FETCH get_party_id INTO l_party_id;
      CLOSE get_party_id;

      IF((p_casu_v2_objs(i).bank_acct_use_objs IS NOT NULL) AND
         (p_casu_v2_objs(i).bank_acct_use_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
          p_bank_acct_use_objs => p_casu_v2_objs(i).bank_acct_use_objs,
          p_party_id           => l_party_id,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      ------------------------
      -- Call payment method
      ------------------------
      IF((p_casu_v2_objs(i).payment_method_objs IS NOT NULL) AND
          (p_casu_v2_objs(i).payment_method_objs.COUNT > 0 )) THEN
        HZ_CUST_ACCT_BO_PVT.save_payment_methods(
          p_payment_method_objs => p_casu_v2_objs(i).payment_method_objs,
          p_ca_id              => p_ca_id,
          p_casu_id            => l_casu_id,
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

    END LOOP;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO save_casu_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO save_casu_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO save_casu_v2_pvt;
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_STRUCT_ERROR');
      FND_MESSAGE.SET_TOKEN('STRUCTURE', 'CUST_ACCT_SITE_USE');
      FND_MSG_PUB.ADD;

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_site_v2_uses(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_site_v2_uses;

  -- PROCEDURE save_cust_acct_v2_sites
  --
  -- DESCRIPTION
  --     Create or update customer account sites.
  PROCEDURE save_cust_acct_v2_sites(
    p_cas_v2_objs                IN OUT NOCOPY HZ_CUST_ACCT_SITE_V2_BO_TBL,
    p_create_update_flag      IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    p_parent_acct_id          IN            NUMBER,
    p_parent_acct_os          IN            VARCHAR2,
    p_parent_acct_osr         IN            VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cas_id                  NUMBER;
    l_cas_os                  VARCHAR2(30);
    l_cas_osr                 VARCHAR2(255);
    l_parent_acct_id          NUMBER;
    l_parent_acct_os          VARCHAR2(30);
    l_parent_acct_osr         VARCHAR2(255);
    l_cbm                     VARCHAR2(30);
  BEGIN
    -- initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_v2_sites(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    l_parent_acct_id := p_parent_acct_id;
    l_parent_acct_os := p_parent_acct_os;
    l_parent_acct_osr := p_parent_acct_osr;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    IF(p_create_update_flag = 'C') THEN
      -- Create cust account sites
      FOR i IN 1..p_cas_v2_objs.COUNT LOOP
        HZ_CUST_ACCT_SITE_BO_PUB.do_create_cust_acct_site_v2_bo(
          p_init_msg_list           => fnd_api.g_false,
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_site_v2_obj      => p_cas_v2_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_site_id       => l_cas_id,
          x_cust_acct_site_os       => l_cas_os,
          x_cust_acct_site_osr      => l_cas_osr,
          px_parent_acct_id         => l_parent_acct_id,
          px_parent_acct_os         => l_parent_acct_os,
          px_parent_acct_osr        => l_parent_acct_osr
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_acct_v2_sites, parent id: '||l_parent_acct_id||' '||l_parent_acct_os||'-'||l_parent_acct_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    ELSE
      -- Create/update cust account site
      FOR i IN 1..p_cas_v2_objs.COUNT LOOP
        HZ_CUST_ACCT_SITE_BO_PUB.do_save_cust_acct_site_v2_bo(
          p_init_msg_list           => fnd_api.g_false,
          p_validate_bo_flag        => fnd_api.g_false,
          p_cust_acct_site_v2_obj      => p_cas_v2_objs(i),
          p_created_by_module       => HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE,
          p_obj_source              => p_obj_source,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_cust_acct_site_id       => l_cas_id,
          x_cust_acct_site_os       => l_cas_os,
          x_cust_acct_site_osr      => l_cas_osr,
          px_parent_acct_id         => l_parent_acct_id,
          px_parent_acct_os         => l_parent_acct_os,
          px_parent_acct_osr        => l_parent_acct_osr
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'Error occurred at hz_cust_acct_site_bo_pvt.save_cust_acct_v2_sites, parent id: '||l_parent_acct_id||' '||l_parent_acct_os||'-'||l_parent_acct_osr,
                                   p_prefix=>l_debug_prefix,
                                   p_msg_level=>fnd_log.level_procedure);
          END IF;
          RAISE fnd_api.g_exc_error;
        END IF;

        HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;
      END LOOP;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_v2_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_v2_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_v2_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'save_cust_acct_v2_sites(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END save_cust_acct_v2_sites;

END hz_cust_acct_site_bo_pvt;

/
