--------------------------------------------------------
--  DDL for Package Body HZ_CUST_ACCT_BO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_CUST_ACCT_BO_PUB" AS
/*$Header: ARHBCABB.pls 120.14 2008/02/06 09:44:55 vsegu ship $ */

  -- PRIVATE PROCEDURE assign_cust_acct_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_obj      Customer account object.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_os       Customer account original system.
  --     p_cust_acct_osr      Customer account original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_rec     Customer Account plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_acct_rec(
    p_cust_acct_obj           IN            HZ_CUST_ACCT_BO,
    p_cust_acct_id            IN            NUMBER,
    p_cust_acct_os            IN            VARCHAR2,
    p_cust_acct_osr           IN            VARCHAR2,
    p_create_or_update        IN            VARCHAR2 := 'C',
    px_cust_acct_rec          IN OUT NOCOPY HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_acct_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_obj      Customer account object.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_os       Customer account original system.
  --     p_cust_acct_osr      Customer account original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_rec     Customer Account plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_acct_rec(
    p_cust_acct_obj           IN            HZ_CUST_ACCT_BO,
    p_cust_acct_id            IN            NUMBER,
    p_cust_acct_os            IN            VARCHAR2,
    p_cust_acct_osr           IN            VARCHAR2,
    p_create_or_update        IN            VARCHAR2 := 'C',
    px_cust_acct_rec          IN OUT NOCOPY HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
  ) IS
  BEGIN
    px_cust_acct_rec.cust_account_id        := p_cust_acct_id;
    px_cust_acct_rec.account_number         := p_cust_acct_obj.account_number;
    IF(p_cust_acct_obj.status in ('A','I')) THEN
      px_cust_acct_rec.status                 := p_cust_acct_obj.status;
    END IF;
    px_cust_acct_rec.customer_type          := p_cust_acct_obj.customer_type;
    px_cust_acct_rec.customer_class_code    := p_cust_acct_obj.customer_class_code;
    px_cust_acct_rec.primary_salesrep_id    := p_cust_acct_obj.primary_salesrep_id;
    px_cust_acct_rec.sales_channel_code     := p_cust_acct_obj.sales_channel_code;
    px_cust_acct_rec.order_type_id          := p_cust_acct_obj.order_type_id;
    px_cust_acct_rec.price_list_id          := p_cust_acct_obj.price_list_id;
    px_cust_acct_rec.tax_code               := p_cust_acct_obj.tax_code;
    px_cust_acct_rec.fob_point              := p_cust_acct_obj.fob_point;
    px_cust_acct_rec.freight_term           := p_cust_acct_obj.freight_term;
    px_cust_acct_rec.ship_partial           := p_cust_acct_obj.ship_partial;
    px_cust_acct_rec.ship_via               := p_cust_acct_obj.ship_via;
    px_cust_acct_rec.warehouse_id           := p_cust_acct_obj.warehouse_id;
    IF(p_cust_acct_obj.tax_header_level_flag in ('Y','N')) THEN
      px_cust_acct_rec.tax_header_level_flag  := p_cust_acct_obj.tax_header_level_flag;
    END IF;
    px_cust_acct_rec.tax_rounding_rule      := p_cust_acct_obj.tax_rounding_rule;
    px_cust_acct_rec.coterminate_day_month  := p_cust_acct_obj.coterminate_day_month;
    px_cust_acct_rec.primary_specialist_id  := p_cust_acct_obj.primary_specialist_id;
    px_cust_acct_rec.secondary_specialist_id := p_cust_acct_obj.secondary_specialist_id;
    IF(p_cust_acct_obj.account_liable_flag in ('Y','N')) THEN
      px_cust_acct_rec.account_liable_flag    := p_cust_acct_obj.account_liable_flag;
    END IF;
    px_cust_acct_rec.current_balance        := p_cust_acct_obj.current_balance;
    px_cust_acct_rec.account_established_date := p_cust_acct_obj.account_established_date;
    px_cust_acct_rec.account_termination_date := p_cust_acct_obj.account_termination_date;
    px_cust_acct_rec.account_activation_date  := p_cust_acct_obj.account_activation_date;
    px_cust_acct_rec.department               := p_cust_acct_obj.department;
    px_cust_acct_rec.held_bill_expiration_date:= p_cust_acct_obj.held_bill_expiration_date;
    IF(p_cust_acct_obj.hold_bill_flag in ('Y','N')) THEN
      px_cust_acct_rec.hold_bill_flag := p_cust_acct_obj.hold_bill_flag;
    END IF;
    px_cust_acct_rec.realtime_rate_flag := p_cust_acct_obj.realtime_rate_flag;
    px_cust_acct_rec.acct_life_cycle_status := p_cust_acct_obj.acct_life_cycle_status;
    px_cust_acct_rec.account_name := p_cust_acct_obj.account_name;
    px_cust_acct_rec.deposit_refund_method := p_cust_acct_obj.deposit_refund_method;
    IF(p_cust_acct_obj.dormant_account_flag in ('Y','N')) THEN
      px_cust_acct_rec.dormant_account_flag := p_cust_acct_obj.dormant_account_flag;
    END IF;
    px_cust_acct_rec.npa_number := p_cust_acct_obj.npa_number;
    px_cust_acct_rec.suspension_date := p_cust_acct_obj.suspension_date;
    px_cust_acct_rec.source_code := p_cust_acct_obj.source_code;
    px_cust_acct_rec.comments := p_cust_acct_obj.comments;
    px_cust_acct_rec.dates_negative_tolerance := p_cust_acct_obj.dates_negative_tolerance;
    px_cust_acct_rec.dates_positive_tolerance := p_cust_acct_obj.dates_positive_tolerance;
    px_cust_acct_rec.date_type_preference := p_cust_acct_obj.date_type_preference;
    px_cust_acct_rec.over_shipment_tolerance := p_cust_acct_obj.over_shipment_tolerance;
    px_cust_acct_rec.under_shipment_tolerance := p_cust_acct_obj.under_shipment_tolerance;
    px_cust_acct_rec.over_return_tolerance := p_cust_acct_obj.over_return_tolerance;
    px_cust_acct_rec.under_return_tolerance := p_cust_acct_obj.under_return_tolerance;
    px_cust_acct_rec.item_cross_ref_pref := p_cust_acct_obj.item_cross_ref_pref;
    IF(p_cust_acct_obj.ship_sets_include_lines_flag in ('Y','N')) THEN
      px_cust_acct_rec.ship_sets_include_lines_flag := p_cust_acct_obj.ship_sets_include_lines_flag;
    END IF;
    IF(p_cust_acct_obj.arrivalsets_incl_lines_flag in ('Y','N')) THEN
      px_cust_acct_rec.arrivalsets_include_lines_flag := p_cust_acct_obj.arrivalsets_incl_lines_flag;
    END IF;
    IF(p_cust_acct_obj.sched_date_push_flag in ('Y','N')) THEN
      px_cust_acct_rec.sched_date_push_flag := p_cust_acct_obj.sched_date_push_flag;
    END IF;
    px_cust_acct_rec.invoice_quantity_rule := p_cust_acct_obj.invoice_quantity_rule;
    px_cust_acct_rec.pricing_event := p_cust_acct_obj.pricing_event;
    px_cust_acct_rec.status_update_date := p_cust_acct_obj.status_update_date;
    IF(p_cust_acct_obj.autopay_flag in ('Y','N')) THEN
      px_cust_acct_rec.autopay_flag := p_cust_acct_obj.autopay_flag;
    END IF;
    IF(p_cust_acct_obj.notify_flag in ('Y','N')) THEN
      px_cust_acct_rec.notify_flag := p_cust_acct_obj.notify_flag;
    END IF;
    px_cust_acct_rec.last_batch_id := p_cust_acct_obj.last_batch_id;
    px_cust_acct_rec.selling_party_id := p_cust_acct_obj.selling_party_id;
    IF(p_create_or_update = 'C') THEN
      px_cust_acct_rec.orig_system            := p_cust_acct_os;
      px_cust_acct_rec.orig_system_reference  := p_cust_acct_osr;
      px_cust_acct_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_cust_acct_rec.attribute_category   := p_cust_acct_obj.attribute_category;
    px_cust_acct_rec.attribute1           := p_cust_acct_obj.attribute1;
    px_cust_acct_rec.attribute2           := p_cust_acct_obj.attribute2;
    px_cust_acct_rec.attribute3           := p_cust_acct_obj.attribute3;
    px_cust_acct_rec.attribute4           := p_cust_acct_obj.attribute4;
    px_cust_acct_rec.attribute5           := p_cust_acct_obj.attribute5;
    px_cust_acct_rec.attribute6           := p_cust_acct_obj.attribute6;
    px_cust_acct_rec.attribute7           := p_cust_acct_obj.attribute7;
    px_cust_acct_rec.attribute8           := p_cust_acct_obj.attribute8;
    px_cust_acct_rec.attribute9           := p_cust_acct_obj.attribute9;
    px_cust_acct_rec.attribute10          := p_cust_acct_obj.attribute10;
    px_cust_acct_rec.attribute11          := p_cust_acct_obj.attribute11;
    px_cust_acct_rec.attribute12          := p_cust_acct_obj.attribute12;
    px_cust_acct_rec.attribute13          := p_cust_acct_obj.attribute13;
    px_cust_acct_rec.attribute14          := p_cust_acct_obj.attribute14;
    px_cust_acct_rec.attribute15          := p_cust_acct_obj.attribute15;
    px_cust_acct_rec.attribute16          := p_cust_acct_obj.attribute16;
    px_cust_acct_rec.attribute17          := p_cust_acct_obj.attribute17;
    px_cust_acct_rec.attribute18          := p_cust_acct_obj.attribute18;
    px_cust_acct_rec.attribute19          := p_cust_acct_obj.attribute19;
    px_cust_acct_rec.attribute20          := p_cust_acct_obj.attribute20;
    px_cust_acct_rec.global_attribute_category   := p_cust_acct_obj.global_attribute_category;
    px_cust_acct_rec.global_attribute1    := p_cust_acct_obj.global_attribute1;
    px_cust_acct_rec.global_attribute2    := p_cust_acct_obj.global_attribute2;
    px_cust_acct_rec.global_attribute3    := p_cust_acct_obj.global_attribute3;
    px_cust_acct_rec.global_attribute4    := p_cust_acct_obj.global_attribute4;
    px_cust_acct_rec.global_attribute5    := p_cust_acct_obj.global_attribute5;
    px_cust_acct_rec.global_attribute6    := p_cust_acct_obj.global_attribute6;
    px_cust_acct_rec.global_attribute7    := p_cust_acct_obj.global_attribute7;
    px_cust_acct_rec.global_attribute8    := p_cust_acct_obj.global_attribute8;
    px_cust_acct_rec.global_attribute9    := p_cust_acct_obj.global_attribute9;
    px_cust_acct_rec.global_attribute10   := p_cust_acct_obj.global_attribute10;
    px_cust_acct_rec.global_attribute11   := p_cust_acct_obj.global_attribute11;
    px_cust_acct_rec.global_attribute12   := p_cust_acct_obj.global_attribute12;
    px_cust_acct_rec.global_attribute13   := p_cust_acct_obj.global_attribute13;
    px_cust_acct_rec.global_attribute14   := p_cust_acct_obj.global_attribute14;
    px_cust_acct_rec.global_attribute15   := p_cust_acct_obj.global_attribute15;
    px_cust_acct_rec.global_attribute16   := p_cust_acct_obj.global_attribute16;
    px_cust_acct_rec.global_attribute17   := p_cust_acct_obj.global_attribute17;
    px_cust_acct_rec.global_attribute18   := p_cust_acct_obj.global_attribute18;
    px_cust_acct_rec.global_attribute19   := p_cust_acct_obj.global_attribute19;
    px_cust_acct_rec.global_attribute20   := p_cust_acct_obj.global_attribute20;
  END assign_cust_acct_rec;

  -- PROCEDURE do_create_cust_acct_bo
  --
  -- DESCRIPTION
  --     Create customer account business object.
  PROCEDURE do_create_cust_acct_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN OUT NOCOPY HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cust_acct_rec           HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
    l_person_rec              HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_organization_rec        HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    l_profile_rec             HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

    l_party_id                NUMBER;
    l_party_number            VARCHAR2(30);
    l_profile_id              NUMBER;
    l_cust_acct_profile_id    NUMBER;
    l_account_number          VARCHAR2(30);
    l_valid_obj               BOOLEAN;
    l_bus_object              HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_cbm                     VARCHAR2(30);

    CURSOR get_cust_acct_profile_id(p_cust_acct_id NUMBER) IS
    SELECT cust_account_profile_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_id = p_cust_acct_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_cust_acct_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'CUST_ACCT',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_ca_bo_comp(
                       p_ca_objs    => HZ_CUST_ACCT_BO_TBL(p_cust_acct_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_id,
      px_parent_os      => px_parent_os,
      px_parent_osr     => px_parent_osr,
      p_parent_obj_type => px_parent_obj_type,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_acct_id := p_cust_acct_obj.cust_acct_id;
    x_cust_acct_os := p_cust_acct_obj.orig_system;
    x_cust_acct_osr := p_cust_acct_obj.orig_system_reference;

    -- check if pass in cust_acct_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_id,
      px_os              => x_cust_acct_os,
      px_osr             => x_cust_acct_osr,
      p_obj_type         => 'HZ_CUST_ACCOUNTS',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    assign_cust_acct_rec(
      p_cust_acct_obj          => p_cust_acct_obj,
      p_cust_acct_id           => x_cust_acct_id,
      p_cust_acct_os           => x_cust_acct_os,
      p_cust_acct_osr          => x_cust_acct_osr,
      px_cust_acct_rec         => l_cust_acct_rec
    );

    IF(p_cust_acct_obj.cust_profile_obj IS NULL) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
      fnd_message.set_token('ENTITY' ,'CUST_PROFILE');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_CUST_ACCT_BO_PVT.assign_cust_profile_rec(
      p_cust_profile_obj            => p_cust_acct_obj.cust_profile_obj,
      p_cust_acct_id                => x_cust_acct_id,
      p_site_use_id                 => NULL,
      px_cust_profile_rec           => l_profile_rec
    );

    -- set party_id to party record
    -- profile amount will be created after creating cust account
    -- therefore set p_create_profile_amt to FND_API.G_FALSE
    IF(px_parent_obj_type = 'ORG') THEN
      l_organization_rec.party_rec.party_id := px_parent_id;
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
        p_cust_account_rec        => l_cust_acct_rec,
        p_organization_rec        => l_organization_rec,
        p_customer_profile_rec    => l_profile_rec,
        p_create_profile_amt      => FND_API.G_FALSE,
        x_cust_account_id         => x_cust_acct_id,
        x_account_number          => l_account_number,
        x_party_id                => l_party_id,
        x_party_number            => l_party_number,
        x_profile_id              => l_profile_id,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );
    ELSE
      l_person_rec.party_rec.party_id := px_parent_id;
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
        p_cust_account_rec        => l_cust_acct_rec,
        p_person_rec              => l_person_rec,
        p_customer_profile_rec    => l_profile_rec,
        p_create_profile_amt      => FND_API.G_FALSE,
        x_cust_account_id         => x_cust_acct_id,
        x_account_number          => l_account_number,
        x_party_id                => l_party_id,
        x_party_number            => l_party_number,
        x_profile_id              => l_profile_id,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_cust_acct_profile_id(x_cust_acct_id);
    FETCH get_cust_acct_profile_id INTO l_cust_acct_profile_id;
    CLOSE get_cust_acct_profile_id;

    -- assign cust_acct_id
    p_cust_acct_obj.cust_acct_id := x_cust_acct_id;
    p_cust_acct_obj.cust_profile_obj.cust_acct_profile_id := l_cust_acct_profile_id;
    -----------------------------
    -- Create cust profile amount
    -----------------------------
    IF((p_cust_acct_obj.cust_profile_obj.cust_profile_amt_objs IS NOT NULL) AND
       (p_cust_acct_obj.cust_profile_obj.cust_profile_amt_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.create_cust_profile_amts(
        p_cpa_objs                => p_cust_acct_obj.cust_profile_obj.cust_profile_amt_objs,
        p_cp_id                   => l_cust_acct_profile_id,
        p_ca_id                   => x_cust_acct_id,
        p_casu_id                 => NULL,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -------------------------------------
    -- Create cust acct relate
    -------------------------------------
    IF((p_cust_acct_obj.acct_relate_objs IS NOT NULL) AND
       (p_cust_acct_obj.acct_relate_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.create_cust_acct_relates(
        p_car_objs                => p_cust_acct_obj.acct_relate_objs,
        p_ca_id                   => x_cust_acct_id,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -------------------------------------
    -- Call cust account contact
    -------------------------------------
    -- Parent of cust account contact is cust account site
    -- so pass x_cust_acct_id, x_cust_acct_os and x_cust_acct_osr
    IF((p_cust_acct_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs           => p_cust_acct_obj.cust_acct_contact_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_cust_acct_id,
        p_parent_os          => x_cust_acct_os,
        p_parent_osr         => x_cust_acct_osr,
        p_parent_obj_type    => 'CUST_ACCT'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------------------
    -- Call cust account site
    -------------------------------------
    -- create cust account site uses will include cust acct site use plus site use profile
    -- need to put customer account id and customer account site id
    IF((p_cust_acct_obj.cust_acct_site_objs IS NOT NULL) AND
       (p_cust_acct_obj.cust_acct_site_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.save_cust_acct_sites(
        p_cas_objs           => p_cust_acct_obj.cust_acct_site_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_acct_id     => x_cust_acct_id,
        p_parent_acct_os     => x_cust_acct_os,
        p_parent_acct_osr    => x_cust_acct_osr
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ------------------------
    -- Call bank account use
    ------------------------
    IF((p_cust_acct_obj.bank_acct_use_objs IS NOT NULL) AND
       (p_cust_acct_obj.bank_acct_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
        p_bank_acct_use_objs => p_cust_acct_obj.bank_acct_use_objs,
        p_party_id           => l_party_id,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
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
    IF(p_cust_acct_obj.payment_method_obj IS NOT NULL) THEN
      HZ_CUST_ACCT_BO_PVT.create_payment_method(
        p_payment_method_obj => p_cust_acct_obj.payment_method_obj,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_cust_acct_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_cust_acct_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_cust_acct_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_cust_acct_bo;

  PROCEDURE create_cust_acct_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  ) IS
    l_ca_obj                   HZ_CUST_ACCT_BO;
  BEGIN
    l_ca_obj := p_cust_acct_obj;
    do_create_cust_acct_bo(
      p_init_msg_list           => p_init_msg_list,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
  END create_cust_acct_bo;

  PROCEDURE create_cust_acct_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN            HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_ca_obj                   HZ_CUST_ACCT_BO;
  BEGIN
    l_ca_obj := p_cust_acct_obj;
    do_create_cust_acct_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ca_obj;
    END IF;
  END create_cust_acct_bo;

  PROCEDURE update_cust_acct_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_obj           IN            HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_ca_obj                  HZ_CUST_ACCT_BO;
  BEGIN
    l_ca_obj := p_cust_acct_obj;
    do_update_cust_acct_bo(
      p_init_msg_list           => p_init_msg_list,
      p_cust_acct_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => null,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      p_parent_os               => NULL
    );
  END update_cust_acct_bo;

  PROCEDURE update_cust_acct_bo(
    p_cust_acct_obj           IN            HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_ca_obj                  HZ_CUST_ACCT_BO;
  BEGIN
    l_ca_obj := p_cust_acct_obj;
    do_update_cust_acct_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_cust_acct_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      p_parent_os               => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ca_obj;
    END IF;
  END update_cust_acct_bo;

  -- PRIVATE PROCEDURE do_update_cust_acct_bo
  --
  -- DESCRIPTION
  --     Update customer account business object.
  PROCEDURE do_update_cust_acct_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN OUT NOCOPY HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_rec            HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
    l_create_update_flag       VARCHAR2(1);
    l_org_contact_bo           HZ_ORG_CONTACT_BO;
    l_ovn                      NUMBER;
    l_party_id                 NUMBER;
    l_cust_acct_profile_id     NUMBER;
    l_cbm                      VARCHAR2(30);

    CURSOR get_ovn(l_ca_id NUMBER) IS
    SELECT a.object_version_number, a.party_id
    FROM HZ_CUST_ACCOUNTS a
    WHERE a.cust_account_id = l_ca_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_cust_acct_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_bo_pub(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -------------------------------
    -- For Update cust accts
    -------------------------------
    x_cust_acct_id := p_cust_acct_obj.cust_acct_id;
    x_cust_acct_os := p_cust_acct_obj.orig_system;
    x_cust_acct_osr := p_cust_acct_obj.orig_system_reference;

    -- validate ssm of cust account site
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_id,
      px_os              => x_cust_acct_os,
      px_osr             => x_cust_acct_osr,
      p_obj_type         => 'HZ_CUST_ACCOUNTS',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object version number of customer acct
    OPEN get_ovn(x_cust_acct_id);
    FETCH get_ovn INTO l_ovn, l_party_id;
    CLOSE get_ovn;

    assign_cust_acct_rec(
      p_cust_acct_obj          => p_cust_acct_obj,
      p_cust_acct_id           => x_cust_acct_id,
      p_cust_acct_os           => x_cust_acct_os,
      p_cust_acct_osr          => x_cust_acct_osr,
      p_create_or_update       => 'U',
      px_cust_acct_rec         => l_cust_acct_rec
    );

    HZ_CUST_ACCOUNT_V2PUB.update_cust_account(
      p_cust_account_rec            => l_cust_acct_rec,
      p_object_version_number       => l_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_id
    p_cust_acct_obj.cust_acct_id := x_cust_acct_id;
    -----------------------------
    -- For Update account profile
    -----------------------------
    IF(p_cust_acct_obj.cust_profile_obj IS NOT NULL) THEN
      HZ_CUST_ACCT_BO_PVT.update_cust_profile(
        p_cp_obj                      => p_cust_acct_obj.cust_profile_obj,
        p_ca_id                       => x_cust_acct_id,
        p_casu_id                     => NULL,
        x_cp_id                       => l_cust_acct_profile_id,
        x_return_status               => x_return_status,
        x_msg_count                   => x_msg_count,
        x_msg_data                    => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign cust_acct_profile_id
      p_cust_acct_obj.cust_profile_obj.cust_acct_profile_id := l_cust_acct_profile_id;
      ---------------------------------
      -- For Update account profile amt
      ---------------------------------
      IF((p_cust_acct_obj.cust_profile_obj.cust_profile_amt_objs IS NOT NULL) AND
         (p_cust_acct_obj.cust_profile_obj.cust_profile_amt_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.save_cust_profile_amts(
          p_cpa_objs                => p_cust_acct_obj.cust_profile_obj.cust_profile_amt_objs,
          p_cp_id                   => l_cust_acct_profile_id,
          p_ca_id                   => x_cust_acct_id,
          p_casu_id                 => NULL,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------------------------
    -- For cust account contact
    -----------------------------------
    IF((p_cust_acct_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs            => p_cust_acct_obj.cust_acct_contact_objs,
        p_create_update_flag  => 'U',
        p_obj_source         => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_parent_id           => x_cust_acct_id,
        p_parent_os           => x_cust_acct_os,
        p_parent_osr          => x_cust_acct_osr,
        p_parent_obj_type     => 'CUST_ACCT'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------------
    -- For Update account acct relate
    -------------------------------
    IF((p_cust_acct_obj.acct_relate_objs IS NOT NULL) AND
       (p_cust_acct_obj.acct_relate_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_cust_acct_relates(
        p_car_objs           => p_cust_acct_obj.acct_relate_objs,
        p_ca_id              => x_cust_acct_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -------------------------------------
    -- Call cust account site
    -------------------------------------
    -- create cust account site uses will include cust acct site use plus site use profile
    -- need to put customer account id and customer account site id
    IF((p_cust_acct_obj.cust_acct_site_objs IS NOT NULL) AND
       (p_cust_acct_obj.cust_acct_site_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.save_cust_acct_sites(
        p_cas_objs           => p_cust_acct_obj.cust_acct_site_objs,
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_acct_id     => x_cust_acct_id,
        p_parent_acct_os     => x_cust_acct_os,
        p_parent_acct_osr    => x_cust_acct_osr
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ------------------------
    -- Call bank account use
    ------------------------
    IF((p_cust_acct_obj.bank_acct_use_objs IS NOT NULL) AND
       (p_cust_acct_obj.bank_acct_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
        p_bank_acct_use_objs => p_cust_acct_obj.bank_acct_use_objs,
        p_party_id           => l_party_id,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
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
    IF(p_cust_acct_obj.payment_method_obj IS NOT NULL) THEN
      HZ_CUST_ACCT_BO_PVT.save_payment_method(
        p_payment_method_obj => p_cust_acct_obj.payment_method_obj,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_cust_acct_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_cust_acct_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_cust_acct_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_cust_acct_bo;

  -- PROCEDURE do_save_cust_acct_bo
  --
  -- DESCRIPTION
  --     Create or update customer account business object.
  PROCEDURE do_save_cust_acct_bo(
    p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag         IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj            IN OUT NOCOPY HZ_CUST_ACCT_BO,
    p_created_by_module        IN            VARCHAR2,
    p_obj_source               IN            VARCHAR2 := null,
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                OUT NOCOPY    NUMBER,
    x_msg_data                 OUT NOCOPY    VARCHAR2,
    x_cust_acct_id             OUT NOCOPY    NUMBER,
    x_cust_acct_os             OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr            OUT NOCOPY    VARCHAR2,
    px_parent_id               IN OUT NOCOPY NUMBER,
    px_parent_os               IN OUT NOCOPY VARCHAR2,
    px_parent_osr              IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type         IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30) := '';
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_cust_acct_id := p_cust_acct_obj.cust_acct_id;
    x_cust_acct_os := p_cust_acct_obj.orig_system;
    x_cust_acct_osr := p_cust_acct_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_cust_acct_id,
                              p_entity_os      => x_cust_acct_os,
                              p_entity_osr     => x_cust_acct_osr,
                              p_entity_type    => 'HZ_CUST_ACCOUNTS',
                              p_parent_id      => px_parent_id,
                              p_parent_obj_type => px_parent_obj_type
                            );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_cust_acct_bo(
        p_validate_bo_flag    => p_validate_bo_flag,
        p_cust_acct_obj       => p_cust_acct_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_cust_acct_id        => x_cust_acct_id,
        x_cust_acct_os        => x_cust_acct_os,
        x_cust_acct_osr       => x_cust_acct_osr,
        px_parent_id          => px_parent_id,
        px_parent_os          => px_parent_os,
        px_parent_osr         => px_parent_osr,
        px_parent_obj_type    => px_parent_obj_type
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_cust_acct_bo(
        p_cust_acct_obj       => p_cust_acct_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_cust_acct_id        => x_cust_acct_id,
        x_cust_acct_os        => x_cust_acct_os,
        x_cust_acct_osr       => x_cust_acct_osr,
        p_parent_os           => px_parent_os
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.SET_NAME('AR', 'HZ_SAVE_API_ERROR');
      FND_MSG_PUB.ADD;
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_cust_acct_bo;

  PROCEDURE save_cust_acct_bo(
    p_init_msg_list        IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag     IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj        IN            HZ_CUST_ACCT_BO,
    p_created_by_module    IN            VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_msg_count            OUT NOCOPY    NUMBER,
    x_msg_data             OUT NOCOPY    VARCHAR2,
    x_cust_acct_id         OUT NOCOPY    NUMBER,
    x_cust_acct_os         OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr        OUT NOCOPY    VARCHAR2,
    px_parent_id           IN OUT NOCOPY NUMBER,
    px_parent_os           IN OUT NOCOPY VARCHAR2,
    px_parent_osr          IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type     IN OUT NOCOPY VARCHAR2
  ) IS
    l_ca_obj               HZ_CUST_ACCT_BO;
  BEGIN
    l_ca_obj := p_cust_acct_obj;
    do_save_cust_acct_bo(
      p_init_msg_list           => p_init_msg_list,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
  END save_cust_acct_bo;

  PROCEDURE save_cust_acct_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_obj           IN            HZ_CUST_ACCT_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_ca_obj                  HZ_CUST_ACCT_BO;
  BEGIN
    l_ca_obj := p_cust_acct_obj;
    do_save_cust_acct_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ca_obj;
    END IF;
  END save_cust_acct_bo;

 --------------------------------------
  --
  -- PROCEDURE get_cust_acct_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_obj         Logical customer account record.
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
  --
  --   8-JUN-2005  AWU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/


 PROCEDURE get_cust_acct_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os		IN	VARCHAR2,
    p_cust_acct_osr		IN	VARCHAR2,
    x_cust_acct_obj          OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_cust_acct_id  number;
  l_cust_acct_os  varchar2(30);
  l_cust_acct_osr varchar2(255);
  l_cust_acct_objs  HZ_CUST_ACCT_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_cust_acct_id := p_cust_acct_id;
    	l_cust_acct_os := p_cust_acct_os;
    	l_cust_acct_osr := p_cust_acct_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_cust_acct_id,
      		px_os              => l_cust_acct_os,
      		px_osr             => l_cust_acct_osr,
      		p_obj_type         => 'HZ_CUST_ACCOUNTS',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_parent_id => NULL,
		 p_cust_acct_id => l_cust_acct_id,
		 p_action_type => NULL,
		  x_cust_acct_objs => l_cust_acct_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_cust_acct_obj := l_cust_acct_objs(1);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

 PROCEDURE get_cust_acct_bo(
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os              IN      VARCHAR2,
    p_cust_acct_osr             IN      VARCHAR2,
    x_cust_acct_obj          OUT NOCOPY    HZ_CUST_ACCT_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_cust_acct_bo(
      p_init_msg_list   => fnd_api.g_true,
      p_cust_acct_id    => p_cust_acct_id,
      p_cust_acct_os    => p_cust_acct_os,
      p_cust_acct_osr   => p_cust_acct_osr,
      x_cust_acct_obj   => x_cust_acct_obj,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_cust_acct_bo;

-- PRIVATE PROCEDURE assign_cust_acct_v2_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_v2_obj      Customer account object.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_os       Customer account original system.
  --     p_cust_acct_osr      Customer account original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_rec     Customer Account plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   1-FEB-2008    vsegu          Created.

  PROCEDURE assign_cust_acct_v2_rec(
    p_cust_acct_v2_obj           IN            HZ_CUST_ACCT_V2_BO,
    p_cust_acct_id            IN            NUMBER,
    p_cust_acct_os            IN            VARCHAR2,
    p_cust_acct_osr           IN            VARCHAR2,
    p_create_or_update        IN            VARCHAR2 := 'C',
    px_cust_acct_rec          IN OUT NOCOPY HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
  );

  -- PRIVATE PROCEDURE assign_cust_acct_v2_rec
  --
  -- DESCRIPTION
  --     Assign attribute value from customer account object to plsql record.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_cust_acct_v2_obj      Customer account object.
  --     p_cust_acct_id       Customer account Id.
  --     p_cust_acct_os       Customer account original system.
  --     p_cust_acct_osr      Customer account original system reference.
  --     p_create_or_update   Create or update flag.
  --   IN/OUT:
  --     px_cust_acct_rec     Customer Account plsql record.
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   14-DEC-2004    Arnold Ng          Created.

  PROCEDURE assign_cust_acct_v2_rec(
    p_cust_acct_v2_obj           IN            HZ_CUST_ACCT_V2_BO,
    p_cust_acct_id            IN            NUMBER,
    p_cust_acct_os            IN            VARCHAR2,
    p_cust_acct_osr           IN            VARCHAR2,
    p_create_or_update        IN            VARCHAR2 := 'C',
    px_cust_acct_rec          IN OUT NOCOPY HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE
  ) IS
  BEGIN
    px_cust_acct_rec.cust_account_id        := p_cust_acct_id;
    px_cust_acct_rec.account_number         := p_cust_acct_v2_obj.account_number;
    IF(p_cust_acct_v2_obj.status in ('A','I')) THEN
      px_cust_acct_rec.status                 := p_cust_acct_v2_obj.status;
    END IF;
    px_cust_acct_rec.customer_type          := p_cust_acct_v2_obj.customer_type;
    px_cust_acct_rec.customer_class_code    := p_cust_acct_v2_obj.customer_class_code;
    px_cust_acct_rec.primary_salesrep_id    := p_cust_acct_v2_obj.primary_salesrep_id;
    px_cust_acct_rec.sales_channel_code     := p_cust_acct_v2_obj.sales_channel_code;
    px_cust_acct_rec.order_type_id          := p_cust_acct_v2_obj.order_type_id;
    px_cust_acct_rec.price_list_id          := p_cust_acct_v2_obj.price_list_id;
    px_cust_acct_rec.tax_code               := p_cust_acct_v2_obj.tax_code;
    px_cust_acct_rec.fob_point              := p_cust_acct_v2_obj.fob_point;
    px_cust_acct_rec.freight_term           := p_cust_acct_v2_obj.freight_term;
    px_cust_acct_rec.ship_partial           := p_cust_acct_v2_obj.ship_partial;
    px_cust_acct_rec.ship_via               := p_cust_acct_v2_obj.ship_via;
    px_cust_acct_rec.warehouse_id           := p_cust_acct_v2_obj.warehouse_id;
    IF(p_cust_acct_v2_obj.tax_header_level_flag in ('Y','N')) THEN
      px_cust_acct_rec.tax_header_level_flag  := p_cust_acct_v2_obj.tax_header_level_flag;
    END IF;
    px_cust_acct_rec.tax_rounding_rule      := p_cust_acct_v2_obj.tax_rounding_rule;
    px_cust_acct_rec.coterminate_day_month  := p_cust_acct_v2_obj.coterminate_day_month;
    px_cust_acct_rec.primary_specialist_id  := p_cust_acct_v2_obj.primary_specialist_id;
    px_cust_acct_rec.secondary_specialist_id := p_cust_acct_v2_obj.secondary_specialist_id;
    IF(p_cust_acct_v2_obj.account_liable_flag in ('Y','N')) THEN
      px_cust_acct_rec.account_liable_flag    := p_cust_acct_v2_obj.account_liable_flag;
    END IF;
    px_cust_acct_rec.current_balance        := p_cust_acct_v2_obj.current_balance;
    px_cust_acct_rec.account_established_date := p_cust_acct_v2_obj.account_established_date;
    px_cust_acct_rec.account_termination_date := p_cust_acct_v2_obj.account_termination_date;
    px_cust_acct_rec.account_activation_date  := p_cust_acct_v2_obj.account_activation_date;
    px_cust_acct_rec.department               := p_cust_acct_v2_obj.department;
    px_cust_acct_rec.held_bill_expiration_date:= p_cust_acct_v2_obj.held_bill_expiration_date;
    IF(p_cust_acct_v2_obj.hold_bill_flag in ('Y','N')) THEN
      px_cust_acct_rec.hold_bill_flag := p_cust_acct_v2_obj.hold_bill_flag;
    END IF;
    px_cust_acct_rec.realtime_rate_flag := p_cust_acct_v2_obj.realtime_rate_flag;
    px_cust_acct_rec.acct_life_cycle_status := p_cust_acct_v2_obj.acct_life_cycle_status;
    px_cust_acct_rec.account_name := p_cust_acct_v2_obj.account_name;
    px_cust_acct_rec.deposit_refund_method := p_cust_acct_v2_obj.deposit_refund_method;
    IF(p_cust_acct_v2_obj.dormant_account_flag in ('Y','N')) THEN
      px_cust_acct_rec.dormant_account_flag := p_cust_acct_v2_obj.dormant_account_flag;
    END IF;
    px_cust_acct_rec.npa_number := p_cust_acct_v2_obj.npa_number;
    px_cust_acct_rec.suspension_date := p_cust_acct_v2_obj.suspension_date;
    px_cust_acct_rec.source_code := p_cust_acct_v2_obj.source_code;
    px_cust_acct_rec.comments := p_cust_acct_v2_obj.comments;
    px_cust_acct_rec.dates_negative_tolerance := p_cust_acct_v2_obj.dates_negative_tolerance;
    px_cust_acct_rec.dates_positive_tolerance := p_cust_acct_v2_obj.dates_positive_tolerance;
    px_cust_acct_rec.date_type_preference := p_cust_acct_v2_obj.date_type_preference;
    px_cust_acct_rec.over_shipment_tolerance := p_cust_acct_v2_obj.over_shipment_tolerance;
    px_cust_acct_rec.under_shipment_tolerance := p_cust_acct_v2_obj.under_shipment_tolerance;
    px_cust_acct_rec.over_return_tolerance := p_cust_acct_v2_obj.over_return_tolerance;
    px_cust_acct_rec.under_return_tolerance := p_cust_acct_v2_obj.under_return_tolerance;
    px_cust_acct_rec.item_cross_ref_pref := p_cust_acct_v2_obj.item_cross_ref_pref;
    IF(p_cust_acct_v2_obj.ship_sets_include_lines_flag in ('Y','N')) THEN
      px_cust_acct_rec.ship_sets_include_lines_flag := p_cust_acct_v2_obj.ship_sets_include_lines_flag;
    END IF;
    IF(p_cust_acct_v2_obj.arrivalsets_incl_lines_flag in ('Y','N')) THEN
      px_cust_acct_rec.arrivalsets_include_lines_flag := p_cust_acct_v2_obj.arrivalsets_incl_lines_flag;
    END IF;
    IF(p_cust_acct_v2_obj.sched_date_push_flag in ('Y','N')) THEN
      px_cust_acct_rec.sched_date_push_flag := p_cust_acct_v2_obj.sched_date_push_flag;
    END IF;
    px_cust_acct_rec.invoice_quantity_rule := p_cust_acct_v2_obj.invoice_quantity_rule;
    px_cust_acct_rec.pricing_event := p_cust_acct_v2_obj.pricing_event;
    px_cust_acct_rec.status_update_date := p_cust_acct_v2_obj.status_update_date;
    IF(p_cust_acct_v2_obj.autopay_flag in ('Y','N')) THEN
      px_cust_acct_rec.autopay_flag := p_cust_acct_v2_obj.autopay_flag;
    END IF;
    IF(p_cust_acct_v2_obj.notify_flag in ('Y','N')) THEN
      px_cust_acct_rec.notify_flag := p_cust_acct_v2_obj.notify_flag;
    END IF;
    px_cust_acct_rec.last_batch_id := p_cust_acct_v2_obj.last_batch_id;
    px_cust_acct_rec.selling_party_id := p_cust_acct_v2_obj.selling_party_id;
    IF(p_create_or_update = 'C') THEN
      px_cust_acct_rec.orig_system            := p_cust_acct_os;
      px_cust_acct_rec.orig_system_reference  := p_cust_acct_osr;
      px_cust_acct_rec.created_by_module := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;
    END IF;
    px_cust_acct_rec.attribute_category   := p_cust_acct_v2_obj.attribute_category;
    px_cust_acct_rec.attribute1           := p_cust_acct_v2_obj.attribute1;
    px_cust_acct_rec.attribute2           := p_cust_acct_v2_obj.attribute2;
    px_cust_acct_rec.attribute3           := p_cust_acct_v2_obj.attribute3;
    px_cust_acct_rec.attribute4           := p_cust_acct_v2_obj.attribute4;
    px_cust_acct_rec.attribute5           := p_cust_acct_v2_obj.attribute5;
    px_cust_acct_rec.attribute6           := p_cust_acct_v2_obj.attribute6;
    px_cust_acct_rec.attribute7           := p_cust_acct_v2_obj.attribute7;
    px_cust_acct_rec.attribute8           := p_cust_acct_v2_obj.attribute8;
    px_cust_acct_rec.attribute9           := p_cust_acct_v2_obj.attribute9;
    px_cust_acct_rec.attribute10          := p_cust_acct_v2_obj.attribute10;
    px_cust_acct_rec.attribute11          := p_cust_acct_v2_obj.attribute11;
    px_cust_acct_rec.attribute12          := p_cust_acct_v2_obj.attribute12;
    px_cust_acct_rec.attribute13          := p_cust_acct_v2_obj.attribute13;
    px_cust_acct_rec.attribute14          := p_cust_acct_v2_obj.attribute14;
    px_cust_acct_rec.attribute15          := p_cust_acct_v2_obj.attribute15;
    px_cust_acct_rec.attribute16          := p_cust_acct_v2_obj.attribute16;
    px_cust_acct_rec.attribute17          := p_cust_acct_v2_obj.attribute17;
    px_cust_acct_rec.attribute18          := p_cust_acct_v2_obj.attribute18;
    px_cust_acct_rec.attribute19          := p_cust_acct_v2_obj.attribute19;
    px_cust_acct_rec.attribute20          := p_cust_acct_v2_obj.attribute20;
    px_cust_acct_rec.global_attribute_category   := p_cust_acct_v2_obj.global_attribute_category;
    px_cust_acct_rec.global_attribute1    := p_cust_acct_v2_obj.global_attribute1;
    px_cust_acct_rec.global_attribute2    := p_cust_acct_v2_obj.global_attribute2;
    px_cust_acct_rec.global_attribute3    := p_cust_acct_v2_obj.global_attribute3;
    px_cust_acct_rec.global_attribute4    := p_cust_acct_v2_obj.global_attribute4;
    px_cust_acct_rec.global_attribute5    := p_cust_acct_v2_obj.global_attribute5;
    px_cust_acct_rec.global_attribute6    := p_cust_acct_v2_obj.global_attribute6;
    px_cust_acct_rec.global_attribute7    := p_cust_acct_v2_obj.global_attribute7;
    px_cust_acct_rec.global_attribute8    := p_cust_acct_v2_obj.global_attribute8;
    px_cust_acct_rec.global_attribute9    := p_cust_acct_v2_obj.global_attribute9;
    px_cust_acct_rec.global_attribute10   := p_cust_acct_v2_obj.global_attribute10;
    px_cust_acct_rec.global_attribute11   := p_cust_acct_v2_obj.global_attribute11;
    px_cust_acct_rec.global_attribute12   := p_cust_acct_v2_obj.global_attribute12;
    px_cust_acct_rec.global_attribute13   := p_cust_acct_v2_obj.global_attribute13;
    px_cust_acct_rec.global_attribute14   := p_cust_acct_v2_obj.global_attribute14;
    px_cust_acct_rec.global_attribute15   := p_cust_acct_v2_obj.global_attribute15;
    px_cust_acct_rec.global_attribute16   := p_cust_acct_v2_obj.global_attribute16;
    px_cust_acct_rec.global_attribute17   := p_cust_acct_v2_obj.global_attribute17;
    px_cust_acct_rec.global_attribute18   := p_cust_acct_v2_obj.global_attribute18;
    px_cust_acct_rec.global_attribute19   := p_cust_acct_v2_obj.global_attribute19;
    px_cust_acct_rec.global_attribute20   := p_cust_acct_v2_obj.global_attribute20;
  END assign_cust_acct_v2_rec;


 -- PROCEDURE do_create_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Create customer account business object.
  PROCEDURE do_create_cust_acct_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN OUT NOCOPY HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_debug_prefix            VARCHAR2(30) := '';
    l_cust_acct_rec           HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
    l_person_rec              HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    l_organization_rec        HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    l_profile_rec             HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;

    l_party_id                NUMBER;
    l_party_number            VARCHAR2(30);
    l_profile_id              NUMBER;
    l_cust_acct_profile_id    NUMBER;
    l_account_number          VARCHAR2(30);
    l_valid_obj               BOOLEAN;
    l_bus_object              HZ_REGISTRY_VALIDATE_BO_PVT.COMPLETENESS_REC_TYPE;
    l_cbm                     VARCHAR2(30);

    CURSOR get_cust_acct_profile_id(p_cust_acct_id NUMBER) IS
    SELECT cust_account_profile_id
    FROM HZ_CUSTOMER_PROFILES
    WHERE cust_account_id = p_cust_acct_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_create_cust_acct_v2_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Base on p_validate_bo_flag, check the completeness of business objects
    IF(p_validate_bo_flag = FND_API.G_TRUE) THEN
      HZ_REGISTRY_VALIDATE_BO_PVT.get_bus_obj_struct(
        p_bus_object_code         => 'CUST_ACCT',
        x_bus_object              => l_bus_object
      );
      l_valid_obj := HZ_REGISTRY_VALIDATE_BO_PVT.is_ca_v2_bo_comp(
                       p_ca_v2_objs    => HZ_CUST_ACCT_V2_BO_TBL(p_cust_acct_v2_obj),
                       p_bus_object => l_bus_object
                     );
      IF NOT(l_valid_obj) THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- check pass in parent_id and parent_os+osr
    hz_registry_validate_bo_pvt.validate_parent_id(
      px_parent_id      => px_parent_id,
      px_parent_os      => px_parent_os,
      px_parent_osr     => px_parent_osr,
      p_parent_obj_type => px_parent_obj_type,
      x_return_status   => x_return_status,
      x_msg_count       => x_msg_count,
      x_msg_data        => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_cust_acct_id := p_cust_acct_v2_obj.cust_acct_id;
    x_cust_acct_os := p_cust_acct_v2_obj.orig_system;
    x_cust_acct_osr := p_cust_acct_v2_obj.orig_system_reference;

    -- check if pass in cust_acct_id and os+osr
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_id,
      px_os              => x_cust_acct_os,
      px_osr             => x_cust_acct_osr,
      p_obj_type         => 'HZ_CUST_ACCOUNTS',
      p_create_or_update => 'C',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    assign_cust_acct_v2_rec(
      p_cust_acct_v2_obj          => p_cust_acct_v2_obj,
      p_cust_acct_id           => x_cust_acct_id,
      p_cust_acct_os           => x_cust_acct_os,
      p_cust_acct_osr          => x_cust_acct_osr,
      px_cust_acct_rec         => l_cust_acct_rec
    );

    IF(p_cust_acct_v2_obj.cust_profile_obj IS NULL) THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_MANDATORY_ENT');
      fnd_message.set_token('ENTITY' ,'CUST_PROFILE');
      fnd_msg_pub.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    HZ_CUST_ACCT_BO_PVT.assign_cust_profile_rec(
      p_cust_profile_obj            => p_cust_acct_v2_obj.cust_profile_obj,
      p_cust_acct_id                => x_cust_acct_id,
      p_site_use_id                 => NULL,
      px_cust_profile_rec           => l_profile_rec
    );

    -- set party_id to party record
    -- profile amount will be created after creating cust account
    -- therefore set p_create_profile_amt to FND_API.G_FALSE
    IF(px_parent_obj_type = 'ORG') THEN
      l_organization_rec.party_rec.party_id := px_parent_id;
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
        p_cust_account_rec        => l_cust_acct_rec,
        p_organization_rec        => l_organization_rec,
        p_customer_profile_rec    => l_profile_rec,
        p_create_profile_amt      => FND_API.G_FALSE,
        x_cust_account_id         => x_cust_acct_id,
        x_account_number          => l_account_number,
        x_party_id                => l_party_id,
        x_party_number            => l_party_number,
        x_profile_id              => l_profile_id,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );
    ELSE
      l_person_rec.party_rec.party_id := px_parent_id;
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account (
        p_cust_account_rec        => l_cust_acct_rec,
        p_person_rec              => l_person_rec,
        p_customer_profile_rec    => l_profile_rec,
        p_create_profile_amt      => FND_API.G_FALSE,
        x_cust_account_id         => x_cust_acct_id,
        x_account_number          => l_account_number,
        x_party_id                => l_party_id,
        x_party_number            => l_party_number,
        x_profile_id              => l_profile_id,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN get_cust_acct_profile_id(x_cust_acct_id);
    FETCH get_cust_acct_profile_id INTO l_cust_acct_profile_id;
    CLOSE get_cust_acct_profile_id;

    -- assign cust_acct_id
    p_cust_acct_v2_obj.cust_acct_id := x_cust_acct_id;
    p_cust_acct_v2_obj.cust_profile_obj.cust_acct_profile_id := l_cust_acct_profile_id;
    -----------------------------
    -- Create cust profile amount
    -----------------------------
    IF((p_cust_acct_v2_obj.cust_profile_obj.cust_profile_amt_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.cust_profile_obj.cust_profile_amt_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.create_cust_profile_amts(
        p_cpa_objs                => p_cust_acct_v2_obj.cust_profile_obj.cust_profile_amt_objs,
        p_cp_id                   => l_cust_acct_profile_id,
        p_ca_id                   => x_cust_acct_id,
        p_casu_id                 => NULL,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -------------------------------------
    -- Create cust acct relate
    -------------------------------------
    IF((p_cust_acct_v2_obj.acct_relate_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.acct_relate_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.create_cust_acct_relates(
        p_car_objs                => p_cust_acct_v2_obj.acct_relate_objs,
        p_ca_id                   => x_cust_acct_id,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -------------------------------------
    -- Call cust account contact
    -------------------------------------
    -- Parent of cust account contact is cust account site
    -- so pass x_cust_acct_id, x_cust_acct_os and x_cust_acct_osr
    IF((p_cust_acct_v2_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs           => p_cust_acct_v2_obj.cust_acct_contact_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_id          => x_cust_acct_id,
        p_parent_os          => x_cust_acct_os,
        p_parent_osr         => x_cust_acct_osr,
        p_parent_obj_type    => 'CUST_ACCT'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------------------
    -- Call cust account site
    -------------------------------------
    -- create cust account site uses will include cust acct site use plus site use profile
    -- need to put customer account id and customer account site id
    IF((p_cust_acct_v2_obj.cust_acct_site_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.cust_acct_site_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.save_cust_acct_v2_sites(
        p_cas_v2_objs           => p_cust_acct_v2_obj.cust_acct_site_objs,
        p_create_update_flag => 'C',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_acct_id     => x_cust_acct_id,
        p_parent_acct_os     => x_cust_acct_os,
        p_parent_acct_osr    => x_cust_acct_osr
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ------------------------
    -- Call bank account use
    ------------------------
    IF((p_cust_acct_v2_obj.bank_acct_use_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.bank_acct_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
        p_bank_acct_use_objs => p_cust_acct_v2_obj.bank_acct_use_objs,
        p_party_id           => l_party_id,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
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
    IF((p_cust_acct_v2_obj.payment_method_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.payment_method_objs.COUNT>0)) THEN
      HZ_CUST_ACCT_BO_PVT.create_payment_methods(
        p_payment_method_objs => p_cust_acct_v2_obj.payment_method_objs,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_create_cust_acct_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_create_cust_acct_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_create_cust_acct_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_create_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_create_cust_acct_v2_bo;

  PROCEDURE create_cust_acct_v2_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN            HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_ca_obj                   HZ_CUST_ACCT_V2_BO;
  BEGIN
    l_ca_obj := p_cust_acct_v2_obj;
    do_create_cust_acct_v2_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_v2_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ca_obj;
    END IF;
  END create_cust_acct_v2_bo;

 PROCEDURE update_cust_acct_v2_bo(
    p_cust_acct_v2_obj           IN            HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2
  )IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_ca_obj                  HZ_CUST_ACCT_V2_BO;
  BEGIN
    l_ca_obj := p_cust_acct_v2_obj;
    do_update_cust_acct_v2_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_cust_acct_v2_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      p_obj_source              => p_obj_source,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      p_parent_os               => NULL
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ca_obj;
    END IF;
  END update_cust_acct_v2_bo;

  -- PRIVATE PROCEDURE do_update_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Update customer account business object.
  PROCEDURE do_update_cust_acct_v2_bo(
    p_init_msg_list           IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN OUT NOCOPY HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_msg_count               OUT NOCOPY    NUMBER,
    x_msg_data                OUT NOCOPY    VARCHAR2,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    p_parent_os               IN            VARCHAR2
  )IS
    l_debug_prefix             VARCHAR2(30) := '';
    l_cust_acct_rec            HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
    l_create_update_flag       VARCHAR2(1);
    l_org_contact_bo           HZ_ORG_CONTACT_BO;
    l_ovn                      NUMBER;
    l_party_id                 NUMBER;
    l_cust_acct_profile_id     NUMBER;
    l_cbm                      VARCHAR2(30);

    CURSOR get_ovn(l_ca_id NUMBER) IS
    SELECT a.object_version_number, a.party_id
    FROM HZ_CUST_ACCOUNTS a
    WHERE a.cust_account_id = l_ca_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT do_update_cust_acct_v2_bo_pub;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := 'BO_API';
    IF(p_created_by_module IS NULL) THEN
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := 'BO_API';
    ELSE
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := p_created_by_module;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_v2_bo_pub(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -------------------------------
    -- For Update cust accts
    -------------------------------
    x_cust_acct_id := p_cust_acct_v2_obj.cust_acct_id;
    x_cust_acct_os := p_cust_acct_v2_obj.orig_system;
    x_cust_acct_osr := p_cust_acct_v2_obj.orig_system_reference;

    -- validate ssm of cust account site
    hz_registry_validate_bo_pvt.validate_ssm_id(
      px_id              => x_cust_acct_id,
      px_os              => x_cust_acct_os,
      px_osr             => x_cust_acct_osr,
      p_obj_type         => 'HZ_CUST_ACCOUNTS',
      p_create_or_update => 'U',
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get object version number of customer acct
    OPEN get_ovn(x_cust_acct_id);
    FETCH get_ovn INTO l_ovn, l_party_id;
    CLOSE get_ovn;

    assign_cust_acct_v2_rec(
      p_cust_acct_v2_obj          => p_cust_acct_v2_obj,
      p_cust_acct_id           => x_cust_acct_id,
      p_cust_acct_os           => x_cust_acct_os,
      p_cust_acct_osr          => x_cust_acct_osr,
      p_create_or_update       => 'U',
      px_cust_acct_rec         => l_cust_acct_rec
    );

    HZ_CUST_ACCOUNT_V2PUB.update_cust_account(
      p_cust_account_rec            => l_cust_acct_rec,
      p_object_version_number       => l_ovn,
      x_return_status               => x_return_status,
      x_msg_count                   => x_msg_count,
      x_msg_data                    => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- assign cust_acct_id
    p_cust_acct_v2_obj.cust_acct_id := x_cust_acct_id;
    -----------------------------
    -- For Update account profile
    -----------------------------
    IF(p_cust_acct_v2_obj.cust_profile_obj IS NOT NULL) THEN
      HZ_CUST_ACCT_BO_PVT.update_cust_profile(
        p_cp_obj                      => p_cust_acct_v2_obj.cust_profile_obj,
        p_ca_id                       => x_cust_acct_id,
        p_casu_id                     => NULL,
        x_cp_id                       => l_cust_acct_profile_id,
        x_return_status               => x_return_status,
        x_msg_count                   => x_msg_count,
        x_msg_data                    => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- assign cust_acct_profile_id
      p_cust_acct_v2_obj.cust_profile_obj.cust_acct_profile_id := l_cust_acct_profile_id;
      ---------------------------------
      -- For Update account profile amt
      ---------------------------------
      IF((p_cust_acct_v2_obj.cust_profile_obj.cust_profile_amt_objs IS NOT NULL) AND
         (p_cust_acct_v2_obj.cust_profile_obj.cust_profile_amt_objs.COUNT > 0)) THEN
        HZ_CUST_ACCT_BO_PVT.save_cust_profile_amts(
          p_cpa_objs                => p_cust_acct_v2_obj.cust_profile_obj.cust_profile_amt_objs,
          p_cp_id                   => l_cust_acct_profile_id,
          p_ca_id                   => x_cust_acct_id,
          p_casu_id                 => NULL,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data
        );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    END IF;

    l_cbm := HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE;

    -----------------------------------
    -- For cust account contact
    -----------------------------------
    IF((p_cust_acct_v2_obj.cust_acct_contact_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.cust_acct_contact_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_CONTACT_BO_PVT.save_cust_acct_contacts(
        p_cac_objs            => p_cust_acct_v2_obj.cust_acct_contact_objs,
        p_create_update_flag  => 'U',
        p_obj_source         => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        p_parent_id           => x_cust_acct_id,
        p_parent_os           => x_cust_acct_os,
        p_parent_osr          => x_cust_acct_osr,
        p_parent_obj_type     => 'CUST_ACCT'
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    -------------------------------
    -- For Update account acct relate
    -------------------------------
    IF((p_cust_acct_v2_obj.acct_relate_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.acct_relate_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_cust_acct_relates(
        p_car_objs           => p_cust_acct_v2_obj.acct_relate_objs,
        p_ca_id              => x_cust_acct_id,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -------------------------------------
    -- Call cust account site
    -------------------------------------
    -- create cust account site uses will include cust acct site use plus site use profile
    -- need to put customer account id and customer account site id
    IF((p_cust_acct_v2_obj.cust_acct_site_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.cust_acct_site_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_SITE_BO_PVT.save_cust_acct_v2_sites(
        p_cas_v2_objs           => p_cust_acct_v2_obj.cust_acct_site_objs,
        p_create_update_flag => 'U',
        p_obj_source         => p_obj_source,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_parent_acct_id     => x_cust_acct_id,
        p_parent_acct_os     => x_cust_acct_os,
        p_parent_acct_osr    => x_cust_acct_osr
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := l_cbm;

    ------------------------
    -- Call bank account use
    ------------------------
    IF((p_cust_acct_v2_obj.bank_acct_use_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.bank_acct_use_objs.COUNT > 0)) THEN
      HZ_CUST_ACCT_BO_PVT.save_bank_acct_uses(
        p_bank_acct_use_objs => p_cust_acct_v2_obj.bank_acct_use_objs,
        p_party_id           => l_party_id,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
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
    IF((p_cust_acct_v2_obj.payment_method_objs IS NOT NULL) AND
       (p_cust_acct_v2_obj.payment_method_objs.COUNT > 0 )) THEN
      HZ_CUST_ACCT_BO_PVT.save_payment_methods(
        p_payment_method_objs => p_cust_acct_v2_obj.payment_method_objs,
        p_ca_id              => x_cust_acct_id,
        p_casu_id            => NULL,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- reset Global variable
    HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
    HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO do_update_cust_acct_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO do_update_cust_acct_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO do_update_cust_acct_v2_bo_pub;

      -- reset Global variable
      HZ_UTILITY_V2PUB.G_CALLING_API := NULL;
      HZ_UTILITY_V2PUB.G_CREATED_BY_MODULE := NULL;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
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
        hz_utility_v2pub.debug(p_message=>'do_update_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_update_cust_acct_v2_bo;

-- PROCEDURE do_save_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Create or update customer account business object.
  PROCEDURE do_save_cust_acct_v2_bo(
    p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false,
    p_validate_bo_flag         IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj            IN OUT NOCOPY HZ_CUST_ACCT_V2_BO,
    p_created_by_module        IN            VARCHAR2,
    p_obj_source               IN            VARCHAR2 := null,
    x_return_status            OUT NOCOPY    VARCHAR2,
    x_msg_count                OUT NOCOPY    NUMBER,
    x_msg_data                 OUT NOCOPY    VARCHAR2,
    x_cust_acct_id             OUT NOCOPY    NUMBER,
    x_cust_acct_os             OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr            OUT NOCOPY    VARCHAR2,
    px_parent_id               IN OUT NOCOPY NUMBER,
    px_parent_os               IN OUT NOCOPY VARCHAR2,
    px_parent_osr              IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type         IN OUT NOCOPY VARCHAR2
  ) IS
    l_return_status            VARCHAR2(30);
    l_msg_count                NUMBER;
    l_msg_data                 VARCHAR2(2000);
    l_create_update_flag       VARCHAR2(1);
    l_debug_prefix             VARCHAR2(30) := '';
  BEGIN
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    x_cust_acct_id := p_cust_acct_v2_obj.cust_acct_id;
    x_cust_acct_os := p_cust_acct_v2_obj.orig_system;
    x_cust_acct_osr := p_cust_acct_v2_obj.orig_system_reference;

    -- check root business object to determine that it should be
    -- create or update, call HZ_REGISTRY_VALIDATE_BO_PVT
    l_create_update_flag := HZ_REGISTRY_VALIDATE_BO_PVT.check_bo_op(
                              p_entity_id      => x_cust_acct_id,
                              p_entity_os      => x_cust_acct_os,
                              p_entity_osr     => x_cust_acct_osr,
                              p_entity_type    => 'HZ_CUST_ACCOUNTS',
                              p_parent_id      => px_parent_id,
                              p_parent_obj_type => px_parent_obj_type
                            );

    IF(l_create_update_flag = 'E') THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_PROPAGATE_OBJECT_ERROR');
      FND_MESSAGE.SET_TOKEN('OBJECT', 'CUST_ACCT');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(l_create_update_flag = 'C') THEN
      do_create_cust_acct_v2_bo(
        p_validate_bo_flag    => p_validate_bo_flag,
        p_cust_acct_v2_obj       => p_cust_acct_v2_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_cust_acct_id        => x_cust_acct_id,
        x_cust_acct_os        => x_cust_acct_os,
        x_cust_acct_osr       => x_cust_acct_osr,
        px_parent_id          => px_parent_id,
        px_parent_os          => px_parent_os,
        px_parent_osr         => px_parent_osr,
        px_parent_obj_type    => px_parent_obj_type
      );
    ELSIF(l_create_update_flag = 'U') THEN
      do_update_cust_acct_v2_bo(
        p_cust_acct_v2_obj       => p_cust_acct_v2_obj,
        p_created_by_module   => p_created_by_module,
        p_obj_source          => p_obj_source,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
        x_cust_acct_id        => x_cust_acct_id,
        x_cust_acct_os        => x_cust_acct_os,
        x_cust_acct_osr       => x_cust_acct_osr,
        p_parent_os           => px_parent_os
      );
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      FND_MESSAGE.SET_NAME('AR', 'HZ_SAVE_API_ERROR');
      FND_MSG_PUB.ADD;
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_v2_bo(-)',
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
        hz_utility_v2pub.debug(p_message=>'do_save_cust_acct_v2_bo(-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
  END do_save_cust_acct_v2_bo;

PROCEDURE save_cust_acct_v2_bo(
    p_validate_bo_flag        IN            VARCHAR2 := fnd_api.g_true,
    p_cust_acct_v2_obj           IN            HZ_CUST_ACCT_V2_BO,
    p_created_by_module       IN            VARCHAR2,
    p_obj_source              IN            VARCHAR2 := null,
    p_return_obj_flag         IN            VARCHAR2 := fnd_api.g_true,
    x_return_status           OUT NOCOPY    VARCHAR2,
    x_messages                OUT NOCOPY    HZ_MESSAGE_OBJ_TBL,
    x_return_obj              OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_cust_acct_id            OUT NOCOPY    NUMBER,
    x_cust_acct_os            OUT NOCOPY    VARCHAR2,
    x_cust_acct_osr           OUT NOCOPY    VARCHAR2,
    px_parent_id              IN OUT NOCOPY NUMBER,
    px_parent_os              IN OUT NOCOPY VARCHAR2,
    px_parent_osr             IN OUT NOCOPY VARCHAR2,
    px_parent_obj_type        IN OUT NOCOPY VARCHAR2
  ) IS
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_ca_obj                  HZ_CUST_ACCT_V2_BO;
  BEGIN
    l_ca_obj := p_cust_acct_v2_obj;
    do_save_cust_acct_v2_bo(
      p_init_msg_list           => fnd_api.g_true,
      p_validate_bo_flag        => p_validate_bo_flag,
      p_cust_acct_v2_obj           => l_ca_obj,
      p_created_by_module       => p_created_by_module,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_cust_acct_id            => x_cust_acct_id,
      x_cust_acct_os            => x_cust_acct_os,
      x_cust_acct_osr           => x_cust_acct_osr,
      px_parent_id              => px_parent_id,
      px_parent_os              => px_parent_os,
      px_parent_osr             => px_parent_osr,
      px_parent_obj_type        => px_parent_obj_type
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
    IF FND_API.to_Boolean(p_return_obj_flag) THEN
      x_return_obj := l_ca_obj;
    END IF;
  END save_cust_acct_v2_bo;

--------------------------------------
  --
  -- PROCEDURE get_cust_acct_v2_bo
  --
  -- DESCRIPTION
  --     Get a logical customer account.
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_init_msg_list      Initialize message stack if it is set to
--       p_cust_acct_id          customer account ID.
  --       p_parent_id	      Parent Id.
  --                          FND_API.G_TRUE. Default is FND_API.G_FALSE.
  --   OUT:
  --     x_cust_acct_v2_obj         Logical customer account record.
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
  --
  --   1-FEB-2008  VSEGU                Created.
  --

/*

The Get customer account API Procedure is a retrieval service that returns full customer account business objects.
The user identifies a particular Organization Contact business object using the TCA identifier and/or the object's
Source System information. Upon proper validation of the object, the full Organization Contact business object is returned.
The object consists of all data included within the Organization Contact business object, at all embedded levels.
This includes the set of all data stored in the TCA tables for each embedded entity.


Embedded BO	    	Mandatory	Multiple Logical API Procedure		Comments
Customer Account Site		N	Y	get_cust_acct_site_v2_bo
Customer Account Contact	N	Y	get_cust_acct_contact_bo
Customer Profile		Y	N	Business Structure. Included entities:
                                                HZ_CUSTOMER_PROFILES, HZ_CUST_PROFILE_AMTS

To retrieve the appropriate embedded entities within the 'Organization Contact' business object, the Get procedure returns all records for the particular contact from these TCA entity tables.

Embedded TCA Entity	Mandatory	Multiple	TCA Table Entities

Customer Account	Y		N	HZ_CUST_ACCOUNTS
Account Relationship	N		Y	HZ_CUST_ACCT_RELATE
Bank Account Use	N		Y	Owned by Payments team
Payment Method		N		N	Owned by AR team

*/


 PROCEDURE get_cust_acct_v2_bo(
    p_init_msg_list       IN            VARCHAR2 := fnd_api.g_false,
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os		IN	VARCHAR2,
    p_cust_acct_osr		IN	VARCHAR2,
    x_cust_acct_v2_obj          OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_msg_count           OUT NOCOPY    NUMBER,
    x_msg_data            OUT NOCOPY    VARCHAR2
  ) is
 l_debug_prefix              VARCHAR2(30) := '';

  l_cust_acct_id  number;
  l_cust_acct_os  varchar2(30);
  l_cust_acct_osr varchar2(255);
  l_cust_acct_v2_objs  HZ_CUST_ACCT_V2_BO_TBL;
BEGIN

	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

    	-- Initialize message list if p_init_msg_list is set to TRUE
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
      		FND_MSG_PUB.initialize;
    	END IF;


	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_v2_bo(+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    	END IF;

    	-- check if pass in contact_point_id and/or os+osr
    	-- extraction validation logic is same as update

    	l_cust_acct_id := p_cust_acct_id;
    	l_cust_acct_os := p_cust_acct_os;
    	l_cust_acct_osr := p_cust_acct_osr;

    	HZ_EXTRACT_BO_UTIL_PVT.validate_ssm_id(
      		px_id              => l_cust_acct_id,
      		px_os              => l_cust_acct_os,
      		px_osr             => l_cust_acct_osr,
      		p_obj_type         => 'HZ_CUST_ACCOUNTS',
      		x_return_status    => x_return_status,
      		x_msg_count        => x_msg_count,
      		x_msg_data         => x_msg_data);

    	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE fnd_api.g_exc_error;
   	 END IF;

	HZ_EXTRACT_CUST_ACCT_BO_PVT.get_cust_acct_v2_bos
		(p_init_msg_list => fnd_api.g_false,
		 p_parent_id => NULL,
		 p_cust_acct_id => l_cust_acct_id,
		 p_action_type => NULL,
		  x_cust_acct_v2_objs => l_cust_acct_v2_objs,
		 x_return_status => x_return_status,
		 x_msg_count => x_msg_count,
		 x_msg_data => x_msg_data);

	x_cust_acct_v2_obj := l_cust_acct_v2_objs(1);

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      		RAISE FND_API.G_EXC_ERROR;
    	END IF;


	-- Debug info.
    	IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         	hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    	END IF;

    	-- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        	hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_v2_bo (-)',
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
        hz_utility_v2pub.debug(p_message=>'hz_cust_acct_bo_pub.get_cust_acct_v2_bo (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

end;

 PROCEDURE get_cust_acct_v2_bo(
    p_cust_acct_id        IN            NUMBER,
    p_cust_acct_os              IN      VARCHAR2,
    p_cust_acct_osr             IN      VARCHAR2,
    x_cust_acct_v2_obj          OUT NOCOPY    HZ_CUST_ACCT_V2_BO,
    x_return_status       OUT NOCOPY    VARCHAR2,
    x_messages            OUT NOCOPY    HZ_MESSAGE_OBJ_TBL
  ) IS
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
  BEGIN
    get_cust_acct_v2_bo(
      p_init_msg_list   => fnd_api.g_true,
      p_cust_acct_id    => p_cust_acct_id,
      p_cust_acct_os    => p_cust_acct_os,
      p_cust_acct_osr   => p_cust_acct_osr,
      x_cust_acct_v2_obj   => x_cust_acct_v2_obj,
      x_return_status   => x_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data
    );
    x_messages := HZ_PARTY_BO_PVT.return_all_messages(
                    x_return_status   => x_return_status,
                    x_msg_count       => l_msg_count,
                    x_msg_data        => l_msg_data);
  END get_cust_acct_v2_bo;

END hz_cust_acct_bo_pub;

/
