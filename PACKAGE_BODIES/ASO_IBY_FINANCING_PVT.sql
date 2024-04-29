--------------------------------------------------------
--  DDL for Package Body ASO_IBY_FINANCING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_IBY_FINANCING_PVT" AS
/* $Header: asovibyb.pls 120.1 2005/06/29 12:41:51 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_IBY_FINANCING_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

  g_pkg_name           CONSTANT VARCHAR2 (30) := 'ASO_IBY_FINANCE_PVT';
  g_file_name          CONSTANT VARCHAR2 (12) := 'asovibyb.pls';
  g_login_id                    NUMBER        := fnd_global.conc_login_id;
  g_financing_rejected CONSTANT VARCHAR2 (30) := 'REJECTED';
  g_financing_canceled CONSTANT VARCHAR2 (30) := 'CANCELED';
  g_financing_approved CONSTANT VARCHAR2 (30) := 'APPROVED';
  g_financing_pending  CONSTANT VARCHAR2 (30) := 'PENDING';

  PROCEDURE update_status (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN       NUMBER   := fnd_api.g_miss_num,
    p_tangible_id               IN       NUMBER,
    p_credit_app_id             IN       NUMBER,
    p_new_status_category       IN       VARCHAR2,
    p_new_status                IN       VARCHAR2,
    p_last_update_date          IN       DATE     := fnd_api.g_miss_date,
    x_return_status             OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */        NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */        VARCHAR2
  ) IS
    l_api_version                 NUMBER          := 1.0;
    l_api_name                    VARCHAR2 (50)   := 'Update_Status';
    l_related_obj_rec             aso_quote_pub.related_obj_rec_type;
    l_related_obj_id              NUMBER;
    l_control_rec                 aso_quote_pub.control_rec_type;
    l_first_time_pending          BOOLEAN         := FALSE;
    l_current_status_code         VARCHAR2 (30);
    l_quote_status_id             NUMBER;
    l_quote_header_id             NUMBER          := p_tangible_id;
    l_credit_app_id               NUMBER;
    l_qte_source_code             VARCHAR2 (240);
    l_qte_resource_id             NUMBER;
    l_qte_header_rec              aso_quote_pub.qte_header_rec_type
                                         := aso_quote_pub.g_miss_qte_header_rec;
    lx_qte_header_rec             aso_quote_pub.qte_header_rec_type;
    lx_qte_line_tbl               aso_quote_pub.qte_line_tbl_type;
    lx_qte_line_dtl_tbl           aso_quote_pub.qte_line_dtl_tbl_type;
    lx_hd_price_attr_tbl          aso_quote_pub.price_attributes_tbl_type;
    lx_hd_payment_tbl             aso_quote_pub.payment_tbl_type;
    lx_hd_shipment_rec            aso_quote_pub.shipment_rec_type;
    lx_hd_shipment_tbl            aso_quote_pub.shipment_tbl_type;
    lx_hd_freight_charge_tbl      aso_quote_pub.freight_charge_tbl_type;
    lx_hd_tax_detail_tbl          aso_quote_pub.tax_detail_tbl_type;
    lx_line_attr_ext_tbl          aso_quote_pub.line_attribs_ext_tbl_type;
    lx_line_rltship_tbl           aso_quote_pub.line_rltship_tbl_type;
    lx_price_adjustment_tbl       aso_quote_pub.price_adj_tbl_type;
    lx_price_adj_attr_tbl         aso_quote_pub.price_adj_attr_tbl_type;
    lx_price_adj_rltship_tbl      aso_quote_pub.price_adj_rltship_tbl_type;
    lx_ln_price_attr_tbl          aso_quote_pub.price_attributes_tbl_type;
    lx_ln_payment_tbl             aso_quote_pub.payment_tbl_type;
    lx_ln_shipment_tbl            aso_quote_pub.shipment_tbl_type;
    lx_ln_freight_charge_tbl      aso_quote_pub.freight_charge_tbl_type;
    lx_ln_tax_detail_tbl          aso_quote_pub.tax_detail_tbl_type;

    CURSOR c_financing_id (
      lc_qte_header_id                     NUMBER
    ) IS
      SELECT object_id, last_update_date, related_object_id
      FROM aso_quote_related_objects
      WHERE relationship_type_code = 'THIRDPARTY_FINANCING'
            AND object_type_code = 'CREDIT_APPLICATION'
            AND quote_object_id = lc_qte_header_id;

    CURSOR c_quote (
      lc_quote_id                          NUMBER
    ) IS
      SELECT qh.quote_source_code, qh.last_update_date, qh.resource_id,
             qh.quote_status_id, qs.status_code
      FROM aso_quote_headers_all qh, aso_quote_statuses_b qs
      WHERE qh.quote_header_id = lc_quote_id
            AND qh.quote_status_id = qs.quote_status_id;

    CURSOR c_qte_status_id (
      lc_status_code                       VARCHAR2
    ) IS
      SELECT quote_status_id
      FROM aso_quote_statuses_b
      WHERE status_code = lc_status_code;
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT update_status_pvt;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status  := fnd_api.g_ret_sts_success;

    --
    -- API body
    --

-- ******************************************************************
-- Validate Environment
-- ******************************************************************
    IF fnd_global.user_id IS NULL
    THEN
      IF fnd_msg_pub.check_msg_level (
           fnd_msg_pub.g_msg_lvl_error
         )
      THEN
        fnd_message.set_name (
          ' + appShortName +',
          'UT_CANNOT_GET_PROFILE_VALUE'
        );
        fnd_message.set_token (
          'PROFILE',
          'USER_ID',
          FALSE
        );
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Update_Status Begin',
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: P_API_VERSION '|| p_api_version,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: P_INIT_MSG_LIST '|| p_init_msg_list,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: P_COMMIT '|| p_commit,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: p_validation_level '|| p_validation_level,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: p_tangible_id '|| p_tangible_id,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: p_credit_app_id '|| p_credit_app_id,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: p_new_status_category '|| p_new_status_category,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: p_new_status '|| p_new_status,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: p_last_update_date '
        || TO_CHAR (
             p_last_update_date,
             'DD-MON-YY HH24:MI:SS'
           ),
        1,
        'Y'
      );
    END IF;
    OPEN c_financing_id (
      l_quote_header_id
    );
    FETCH c_financing_id INTO l_credit_app_id,
                              l_related_obj_rec.last_update_date,
                              l_related_obj_id;

    IF c_financing_id%NOTFOUND
    THEN
      CLOSE c_financing_id;

      IF p_new_status_category = g_financing_pending
      THEN

-- if it is the first called to change to financing pending, a relationship
-- between quote header and credit app is created and quote status is changed.
        l_first_time_pending  := TRUE;
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Update_Status: The first time that it is called to change quote to financing pending',
            1,
            'Y'
          );
        END IF;
      ELSE
        IF fnd_msg_pub.check_msg_level (
             fnd_msg_pub.g_msg_lvl_error
           )
        THEN
          fnd_message.set_name (
            'ASO',
            'ASO_API_FINANCING_NOT_ATTACHED'
          );
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE
      CLOSE c_financing_id;
    END IF;

    OPEN c_quote (
      l_quote_header_id
    );
    FETCH c_quote INTO l_qte_source_code,
                       l_qte_header_rec.last_update_date,
                       l_qte_resource_id,
                       l_quote_status_id,
                       l_current_status_code;
    CLOSE c_quote;
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Update_Status: getting information for quote '|| l_quote_header_id,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: quote current status '|| l_current_status_code,
        1,
        'Y'
      );
      aso_debug_pub.ADD (
        'Update_Status: quote last update date '
        || TO_CHAR (
             l_qte_header_rec.last_update_date,
             'DD-MON-YY HH24:MI:SS'
           ),
        1,
        'Y'
      );
    END IF;

    /*  if it asks quote status change to financing pending from any other valid statuses,
     *  p_last_update_date must be passed in as the same value in quote header record.
     */
    IF  p_new_status_category = g_financing_pending
        AND l_current_status_code <> 'FINANCING PENDING'
    THEN
      IF p_last_update_date = fnd_api.g_miss_date
         OR p_last_update_date IS NULL
      THEN
        IF fnd_msg_pub.check_msg_level (
             fnd_msg_pub.g_msg_lvl_error
           )
        THEN
          fnd_message.set_name (
            'ASO',
            'API_INVALID_ID'
          );
          fnd_message.set_token (
            'COLUMN',
            'LAST_UPDATE_DATE',
            FALSE
          );
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      ELSIF p_last_update_date <> l_qte_header_rec.last_update_date
      THEN
        IF fnd_msg_pub.check_msg_level (
             fnd_msg_pub.g_msg_lvl_error
           )
        THEN
          fnd_message.set_name (
            'ASO',
            'ASO_API_RECORD_CHANGED'
          );
          fnd_message.set_token (
            'INFO',
            'quote',
            FALSE
          );
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF p_new_status_category = g_financing_approved
    THEN
      OPEN c_qte_status_id (
        'FINANCING APPROVED'
      );
      FETCH c_qte_status_id INTO l_qte_header_rec.quote_status_id;
      CLOSE c_qte_status_id;
    ELSIF p_new_status_category = g_financing_canceled
    THEN
      OPEN c_qte_status_id (
        'FINANCING CANCELED'
      );
      FETCH c_qte_status_id INTO l_qte_header_rec.quote_status_id;
      CLOSE c_qte_status_id;
    ELSIF p_new_status_category = g_financing_rejected
    THEN
      OPEN c_qte_status_id (
        'FINANCING REJECTED'
      );
      FETCH c_qte_status_id INTO l_qte_header_rec.quote_status_id;
      CLOSE c_qte_status_id;
    ELSIF p_new_status_category = g_financing_pending
    THEN
      -- creating related object if it is the first time, otherwise updating it.

      l_related_obj_rec.quote_object_type_code  := 'HEADER';
      l_related_obj_rec.quote_object_id         := l_quote_header_id;
      l_related_obj_rec.object_type_code        := 'CREDIT_APPLICATION';
      l_related_obj_rec.object_id               := p_credit_app_id;
      l_related_obj_rec.relationship_type_code  := 'THIRDPARTY_FINANCING';
      l_related_obj_rec.reciprocal_flag         := 'N';

      IF l_first_time_pending
      THEN
        aso_related_obj_pvt.create_related_obj (
          p_api_version_number         => 1.0,
          p_init_msg_list              => p_init_msg_list,
          p_commit                     => p_commit,
          p_validation_level           => fnd_api.g_valid_level_none,
          p_related_obj_rec            => l_related_obj_rec,
          x_related_object_id          => l_related_obj_id,
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data
        );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Update_Status: after Create_related_obj return_status: '
            || x_return_status,
            1,
            'Y'
          );
        END IF;

        IF x_return_status <> fnd_api.g_ret_sts_success
        THEN
          IF fnd_msg_pub.check_msg_level (
               fnd_msg_pub.g_msg_lvl_error
             )
          THEN
            fnd_message.set_name (
              'ASO',
              'ASO_API_ERROR_IN_CREATE_RLTN'
            );
            fnd_message.set_token (
              'COLUMN',
              l_related_obj_rec.relationship_type_code,
              FALSE
            );
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_credit_app_id <> p_credit_app_id
      THEN
        l_related_obj_rec.related_object_id  := l_related_obj_id;
        aso_related_obj_pvt.update_related_obj (
          p_api_version_number         => 1.0,
          p_init_msg_list              => p_init_msg_list,
          p_commit                     => p_commit,
          p_validation_level           => fnd_api.g_valid_level_none,
          p_related_obj_rec            => l_related_obj_rec,
          x_return_status              => x_return_status,
          x_msg_count                  => x_msg_count,
          x_msg_data                   => x_msg_data
        );
        IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
          aso_debug_pub.ADD (
            'Update_Status: after Update_related_obj return_status: '
            || x_return_status,
            1,
            'Y'
          );
        END IF;

        IF x_return_status <> fnd_api.g_ret_sts_success
        THEN
          IF fnd_msg_pub.check_msg_level (
               fnd_msg_pub.g_msg_lvl_error
             )
          THEN
            fnd_message.set_name (
              'ASO',
              'ASO_API_ERROR_IN_UPDATE_RLTN'
            );
            fnd_message.set_token (
              'COLUMN',
              l_related_obj_rec.relationship_type_code,
              FALSE
            );
            fnd_msg_pub.ADD;
          END IF;

          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      OPEN c_qte_status_id (
        'FINANCING PENDING'
      );
      FETCH c_qte_status_id INTO l_qte_header_rec.quote_status_id;
      CLOSE c_qte_status_id;
    ELSE
      IF fnd_msg_pub.check_msg_level (
           fnd_msg_pub.g_msg_lvl_error
         )
      THEN
        fnd_message.set_name (
          'ASO',
          'API_INVALID_ID'
        );
        fnd_message.set_token (
          'COLUMN',
          'NEW STATUS CATEGORY',
          FALSE
        );
        fnd_msg_pub.ADD;
      END IF;

      RAISE fnd_api.g_exc_error;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Update_Status: Updating quote status to '
        || l_qte_header_rec.quote_status_id,
        1,
        'Y'
      );
    END IF;


-- we should do nothing if the passing status is the same as current status.
-- If we pass in same quote status, the update_quote will not throw exception.
-- However, it may pop up the quote version.

    IF l_qte_header_rec.quote_status_id <> l_quote_status_id
    THEN
      l_qte_header_rec.quote_header_id  := l_quote_header_id;
      l_control_rec                     := aso_quote_pub.g_miss_control_rec;
      l_control_rec.auto_version_flag   := fnd_api.g_true;
      aso_quote_pub.update_quote (
        p_api_version_number         => 1.0,
        p_init_msg_list              => fnd_api.g_false,
        p_commit                     => fnd_api.g_false,
        p_qte_header_rec             => l_qte_header_rec,
        x_qte_header_rec             => lx_qte_header_rec,
        x_qte_line_tbl               => lx_qte_line_tbl,
        x_qte_line_dtl_tbl           => lx_qte_line_dtl_tbl,
        x_hd_price_attributes_tbl    => lx_hd_price_attr_tbl,
        x_hd_payment_tbl             => lx_hd_payment_tbl,
        x_hd_shipment_tbl            => lx_hd_shipment_tbl,
        x_hd_freight_charge_tbl      => lx_hd_freight_charge_tbl,
        x_hd_tax_detail_tbl          => lx_hd_tax_detail_tbl,
        x_line_attr_ext_tbl          => lx_line_attr_ext_tbl,
        x_line_rltship_tbl           => lx_line_rltship_tbl,
        x_price_adjustment_tbl       => lx_price_adjustment_tbl,
        x_price_adj_attr_tbl         => lx_price_adj_attr_tbl,
        x_price_adj_rltship_tbl      => lx_price_adj_rltship_tbl,
        x_ln_price_attributes_tbl    => lx_ln_price_attr_tbl,
        x_ln_payment_tbl             => lx_ln_payment_tbl,
        x_ln_shipment_tbl            => lx_ln_shipment_tbl,
        x_ln_freight_charge_tbl      => lx_ln_freight_charge_tbl,
        x_ln_tax_detail_tbl          => lx_ln_tax_detail_tbl,
        x_return_status              => x_return_status,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data
      );
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.ADD (
          'Update_Status: after Update_Quote return_status: '|| x_return_status,
          1,
          'Y'
        );
      END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success
      THEN
        IF fnd_msg_pub.check_msg_level (
             fnd_msg_pub.g_msg_lvl_error
           )
        THEN
          fnd_message.set_name (
            'ASO',
            'ASO_API_ERROR_IN_UPDATE_QUOTE'
          );
          fnd_msg_pub.ADD;
        END IF;

        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Update_Status End',
        1,
        'Y'
      );
    END IF;

    --
    -- End of API body.
    --

    -- Standard check for p_commit
    IF fnd_api.to_boolean (
         p_commit
       )
    THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    aso_utility_pvt.debug_message (
      fnd_msg_pub.g_msg_lvl_debug_low,
      'Public API: ' || l_api_name || 'end'
    );
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_pvt,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_pvt,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_pvt,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END update_status;
END aso_iby_financing_pvt;

/
