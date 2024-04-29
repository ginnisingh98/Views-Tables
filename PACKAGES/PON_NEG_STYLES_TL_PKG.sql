--------------------------------------------------------
--  DDL for Package PON_NEG_STYLES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEG_STYLES_TL_PKG" AUTHID CURRENT_USER AS
/* $Header: PONSTYLS.pls 120.3.12010000.2 2009/09/28 20:22:03 atjen ship $ */



PROCEDURE insert_row (
     p_style_id                      IN  pon_negotiation_styles.style_id%TYPE
    ,p_status                        IN  pon_negotiation_styles.status%TYPE
    ,p_system_flag                   IN  pon_negotiation_styles.system_flag%TYPE
    ,p_line_attribute_enabled_flag   IN  pon_negotiation_styles.line_attribute_enabled_flag%TYPE
    ,p_line_mas_enabled_flag         IN  pon_negotiation_styles.line_mas_enabled_flag%TYPE
    ,p_price_element_enabled_flag    IN  pon_negotiation_styles.price_element_enabled_flag%TYPE
    ,p_rfi_line_enabled_flag         IN  pon_negotiation_styles.rfi_line_enabled_flag%TYPE
    ,p_lot_enabled_flag              IN  pon_negotiation_styles.lot_enabled_flag%TYPE
    ,p_group_enabled_flag            IN  pon_negotiation_styles.group_enabled_flag%TYPE
    ,p_large_neg_enabled_flag        IN  pon_negotiation_styles.large_neg_enabled_flag%TYPE
    ,p_hdr_attribute_enabled_flag    IN  pon_negotiation_styles.hdr_attribute_enabled_flag%TYPE
    ,p_neg_team_enabled_flag         IN  pon_negotiation_styles.neg_team_enabled_flag%TYPE
    ,p_proxy_bidding_enabled_flag    IN  pon_negotiation_styles.proxy_bidding_enabled_flag%TYPE
    ,p_power_bidding_enabled_flag    IN  pon_negotiation_styles.power_bidding_enabled_flag%TYPE
    ,p_auto_extend_enabled_flag      IN  pon_negotiation_styles.auto_extend_enabled_flag%TYPE
    ,p_team_scoring_enabled_flag     IN  pon_negotiation_styles.team_scoring_enabled_flag%TYPE
    ,p_creation_date                 IN  pon_negotiation_styles.creation_date%TYPE
    ,p_created_by                    IN  pon_negotiation_styles.created_by%TYPE
    ,p_last_update_date              IN  pon_negotiation_styles.last_update_date%TYPE
    ,p_last_updated_by               IN  pon_negotiation_styles.last_updated_by%TYPE
    ,p_last_update_login             IN  pon_negotiation_styles.last_update_login%TYPE
    ,p_qty_price_tiers_enabled_flag  IN  pon_negotiation_styles.qty_price_tiers_enabled_flag%TYPE
    -------------------------- Supplier Management: Negotiation Styles --------------------------
    ,p_supp_reg_qual_flag            IN  pon_negotiation_styles.supp_reg_qual_flag%TYPE
    ,p_supp_eval_flag                IN  pon_negotiation_styles.supp_eval_flag%TYPE
    ,p_hide_terms_flag               IN  pon_negotiation_styles.hide_terms_flag%TYPE
    ,p_hide_abstract_forms_flag      IN  pon_negotiation_styles.hide_abstract_forms_flag%TYPE
    ,p_hide_attachments_flag         IN  pon_negotiation_styles.hide_attachments_flag%TYPE
    ,p_internal_eval_flag            IN  pon_negotiation_styles.internal_eval_flag%TYPE
    ,p_hdr_supp_attr_enabled_flag    IN  pon_negotiation_styles.hdr_supp_attr_enabled_flag%TYPE
    ,p_intgr_hdr_attr_flag           IN  pon_negotiation_styles.intgr_hdr_attr_flag%TYPE
    ,p_intgr_hdr_attach_flag         IN  pon_negotiation_styles.intgr_hdr_attach_flag%TYPE
    ,p_line_supp_attr_enabled_flag   IN  pon_negotiation_styles.line_supp_attr_enabled_flag%TYPE
    ,p_item_supp_attr_enabled_flag   IN  pon_negotiation_styles.item_supp_attr_enabled_flag%TYPE
    ,p_intgr_cat_line_attr_flag      IN  pon_negotiation_styles.intgr_cat_line_attr_flag%TYPE
    ,p_intgr_item_line_attr_flag     IN  pon_negotiation_styles.intgr_item_line_attr_flag%TYPE
    ,p_intgr_cat_line_asl_flag       IN  pon_negotiation_styles.intgr_cat_line_asl_flag%TYPE
    ---------------------------------------------------------------------------------------------
    ,p_style_name                    IN  pon_negotiation_styles_tl.style_name%TYPE
    ,p_description                   IN  pon_negotiation_styles_tl.description%TYPE);

PROCEDURE update_row (
    p_style_id                       IN  pon_negotiation_styles.style_id%TYPE
    ,p_status                        IN  pon_negotiation_styles.status%TYPE
    ,p_system_flag                   IN  pon_negotiation_styles.system_flag%TYPE
    ,p_line_attribute_enabled_flag   IN  pon_negotiation_styles.line_attribute_enabled_flag%TYPE
    ,p_line_mas_enabled_flag         IN  pon_negotiation_styles.line_mas_enabled_flag%TYPE
    ,p_price_element_enabled_flag    IN  pon_negotiation_styles.price_element_enabled_flag%TYPE
    ,p_rfi_line_enabled_flag         IN  pon_negotiation_styles.rfi_line_enabled_flag%TYPE
    ,p_lot_enabled_flag              IN  pon_negotiation_styles.lot_enabled_flag%TYPE
    ,p_group_enabled_flag            IN  pon_negotiation_styles.group_enabled_flag%TYPE
    ,p_large_neg_enabled_flag        IN  pon_negotiation_styles.large_neg_enabled_flag%TYPE
    ,p_hdr_attribute_enabled_flag    IN  pon_negotiation_styles.hdr_attribute_enabled_flag%TYPE
    ,p_neg_team_enabled_flag         IN  pon_negotiation_styles.neg_team_enabled_flag%TYPE
    ,p_proxy_bidding_enabled_flag    IN  pon_negotiation_styles.proxy_bidding_enabled_flag%TYPE
    ,p_power_bidding_enabled_flag    IN  pon_negotiation_styles.power_bidding_enabled_flag%TYPE
    ,p_auto_extend_enabled_flag      IN  pon_negotiation_styles.auto_extend_enabled_flag%TYPE
    ,p_team_scoring_enabled_flag     IN  pon_negotiation_styles.team_scoring_enabled_flag%TYPE
    ,p_last_update_date              IN  pon_negotiation_styles.last_update_date%TYPE
    ,p_last_updated_by               IN  pon_negotiation_styles.last_updated_by%TYPE
    ,p_last_update_login             IN  pon_negotiation_styles.last_update_login%TYPE
    ,p_qty_price_tiers_enabled_flag  IN  pon_negotiation_styles.qty_price_tiers_enabled_flag%TYPE
    -------------------------- Supplier Management: Negotiation Styles --------------------------
    ,p_supp_reg_qual_flag            IN  pon_negotiation_styles.supp_reg_qual_flag%TYPE
    ,p_supp_eval_flag                IN  pon_negotiation_styles.supp_eval_flag%TYPE
    ,p_hide_terms_flag               IN  pon_negotiation_styles.hide_terms_flag%TYPE
    ,p_hide_abstract_forms_flag      IN  pon_negotiation_styles.hide_abstract_forms_flag%TYPE
    ,p_hide_attachments_flag         IN  pon_negotiation_styles.hide_attachments_flag%TYPE
    ,p_internal_eval_flag            IN  pon_negotiation_styles.internal_eval_flag%TYPE
    ,p_hdr_supp_attr_enabled_flag    IN  pon_negotiation_styles.hdr_supp_attr_enabled_flag%TYPE
    ,p_intgr_hdr_attr_flag           IN  pon_negotiation_styles.intgr_hdr_attr_flag%TYPE
    ,p_intgr_hdr_attach_flag         IN  pon_negotiation_styles.intgr_hdr_attach_flag%TYPE
    ,p_line_supp_attr_enabled_flag   IN  pon_negotiation_styles.line_supp_attr_enabled_flag%TYPE
    ,p_item_supp_attr_enabled_flag   IN  pon_negotiation_styles.item_supp_attr_enabled_flag%TYPE
    ,p_intgr_cat_line_attr_flag      IN  pon_negotiation_styles.intgr_cat_line_attr_flag%TYPE
    ,p_intgr_item_line_attr_flag     IN  pon_negotiation_styles.intgr_item_line_attr_flag%TYPE
    ,p_intgr_cat_line_asl_flag       IN  pon_negotiation_styles.intgr_cat_line_asl_flag%TYPE
    ---------------------------------------------------------------------------------------------
    ,p_style_name                    IN  pon_negotiation_styles_tl.style_name%TYPE
    ,p_description                   IN  pon_negotiation_styles_tl.description%TYPE);

PROCEDURE translate_row (
     p_style_id                      IN  pon_negotiation_styles.style_id%TYPE
     ,p_style_name                   IN  pon_negotiation_styles_tl.style_name%TYPE
     ,p_description                  IN  pon_negotiation_styles_tl.description%TYPE
     ,p_owner                        IN  VARCHAR2
     ,p_custom_mode                  IN  VARCHAR2
     ,p_last_update_date             IN  VARCHAR2);

PROCEDURE load_row (
    p_style_id                       IN  pon_negotiation_styles.style_id%TYPE
    ,p_owner                         IN  VARCHAR2
    ,p_last_update_date              IN  VARCHAR2
    ,p_custom_mode                   IN  VARCHAR2
    ,p_status                        IN  pon_negotiation_styles.status%TYPE
    ,p_system_flag                   IN  pon_negotiation_styles.system_flag%TYPE
    ,p_line_attribute_enabled_flag   IN  pon_negotiation_styles.line_attribute_enabled_flag%TYPE
    ,p_line_mas_enabled_flag         IN  pon_negotiation_styles.line_mas_enabled_flag%TYPE
    ,p_price_element_enabled_flag    IN  pon_negotiation_styles.price_element_enabled_flag%TYPE
    ,p_rfi_line_enabled_flag         IN  pon_negotiation_styles.rfi_line_enabled_flag%TYPE
    ,p_lot_enabled_flag              IN  pon_negotiation_styles.lot_enabled_flag%TYPE
    ,p_group_enabled_flag            IN  pon_negotiation_styles.group_enabled_flag%TYPE
    ,p_large_neg_enabled_flag        IN  pon_negotiation_styles.large_neg_enabled_flag%TYPE
    ,p_hdr_attribute_enabled_flag    IN  pon_negotiation_styles.hdr_attribute_enabled_flag%TYPE
    ,p_neg_team_enabled_flag         IN  pon_negotiation_styles.neg_team_enabled_flag%TYPE
    ,p_proxy_bidding_enabled_flag    IN  pon_negotiation_styles.proxy_bidding_enabled_flag%TYPE
    ,p_power_bidding_enabled_flag    IN  pon_negotiation_styles.power_bidding_enabled_flag%TYPE
    ,p_auto_extend_enabled_flag      IN  pon_negotiation_styles.auto_extend_enabled_flag%TYPE
    ,p_team_scoring_enabled_flag     IN  pon_negotiation_styles.team_scoring_enabled_flag%TYPE
    ,p_qty_price_tiers_enabled_flag  IN  pon_negotiation_styles.qty_price_tiers_enabled_flag%TYPE
    -------------------------- Supplier Management: Negotiation Styles --------------------------
    ,p_supp_reg_qual_flag            IN  pon_negotiation_styles.supp_reg_qual_flag%TYPE
    ,p_supp_eval_flag                IN  pon_negotiation_styles.supp_eval_flag%TYPE
    ,p_hide_terms_flag               IN  pon_negotiation_styles.hide_terms_flag%TYPE
    ,p_hide_abstract_forms_flag      IN  pon_negotiation_styles.hide_abstract_forms_flag%TYPE
    ,p_hide_attachments_flag         IN  pon_negotiation_styles.hide_attachments_flag%TYPE
    ,p_internal_eval_flag            IN  pon_negotiation_styles.internal_eval_flag%TYPE
    ,p_hdr_supp_attr_enabled_flag    IN  pon_negotiation_styles.hdr_supp_attr_enabled_flag%TYPE
    ,p_intgr_hdr_attr_flag           IN  pon_negotiation_styles.intgr_hdr_attr_flag%TYPE
    ,p_intgr_hdr_attach_flag         IN  pon_negotiation_styles.intgr_hdr_attach_flag%TYPE
    ,p_line_supp_attr_enabled_flag   IN  pon_negotiation_styles.line_supp_attr_enabled_flag%TYPE
    ,p_item_supp_attr_enabled_flag   IN  pon_negotiation_styles.item_supp_attr_enabled_flag%TYPE
    ,p_intgr_cat_line_attr_flag      IN  pon_negotiation_styles.intgr_cat_line_attr_flag%TYPE
    ,p_intgr_item_line_attr_flag     IN  pon_negotiation_styles.intgr_item_line_attr_flag%TYPE
    ,p_intgr_cat_line_asl_flag       IN  pon_negotiation_styles.intgr_cat_line_asl_flag%TYPE
    ---------------------------------------------------------------------------------------------
    ,p_style_name                    IN  pon_negotiation_styles_tl.style_name%TYPE
    ,p_description                   IN  pon_negotiation_styles_tl.description%TYPE);

PROCEDURE delete_row (
    p_style_id                       IN  pon_negotiation_styles.style_id%TYPE
);

PROCEDURE add_language;

END pon_neg_styles_tl_pkg;

/
