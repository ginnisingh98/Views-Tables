--------------------------------------------------------
--  DDL for Package Body PON_NEG_STYLES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_NEG_STYLES_TL_PKG" AS
/* $Header: PONSTYLB.pls 120.6.12010000.2 2009/09/28 20:22:49 atjen ship $ */

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
    ,p_description                   IN  pon_negotiation_styles_tl.description%TYPE) IS

BEGIN

  INSERT INTO pon_negotiation_styles
     (style_id
     ,status
     ,system_flag
     ,line_attribute_enabled_flag
     ,line_mas_enabled_flag
     ,price_element_enabled_flag
     ,rfi_line_enabled_flag
     ,lot_enabled_flag
     ,group_enabled_flag
     ,large_neg_enabled_flag
     ,hdr_attribute_enabled_flag
     ,neg_team_enabled_flag
     ,proxy_bidding_enabled_flag
     ,power_bidding_enabled_flag
     ,auto_extend_enabled_flag
     ,team_scoring_enabled_flag
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,qty_price_tiers_enabled_flag
     ---- Supplier Management: Negotiation Styles ----
     ,supp_reg_qual_flag
     ,supp_eval_flag
     ,hide_terms_flag
     ,hide_abstract_forms_flag
     ,hide_attachments_flag
     ,internal_eval_flag
     ,hdr_supp_attr_enabled_flag
     ,intgr_hdr_attr_flag
     ,intgr_hdr_attach_flag
     ,line_supp_attr_enabled_flag
     ,item_supp_attr_enabled_flag
     ,intgr_cat_line_attr_flag
     ,intgr_item_line_attr_flag
     ,intgr_cat_line_asl_flag
     -------------------------------------------------
     )
  VALUES
     (p_style_id
     ,p_status
     ,p_system_flag
     ,p_line_attribute_enabled_flag
     ,p_line_mas_enabled_flag
     ,p_price_element_enabled_flag
     ,p_rfi_line_enabled_flag
     ,p_lot_enabled_flag
     ,p_group_enabled_flag
     ,p_large_neg_enabled_flag
     ,p_hdr_attribute_enabled_flag
     ,p_neg_team_enabled_flag
     ,p_proxy_bidding_enabled_flag
     ,p_power_bidding_enabled_flag
     ,p_auto_extend_enabled_flag
     ,p_team_scoring_enabled_flag
     ,p_creation_date
     ,p_created_by
     ,p_last_update_date
     ,p_last_updated_by
     ,p_last_update_login
     ,p_qty_price_tiers_enabled_flag
     ---- Supplier Management: Negotiation Styles ----
     ,p_supp_reg_qual_flag
     ,p_supp_eval_flag
     ,p_hide_terms_flag
     ,p_hide_abstract_forms_flag
     ,p_hide_attachments_flag
     ,p_internal_eval_flag
     ,p_hdr_supp_attr_enabled_flag
     ,p_intgr_hdr_attr_flag
     ,p_intgr_hdr_attach_flag
     ,p_line_supp_attr_enabled_flag
     ,p_item_supp_attr_enabled_flag
     ,p_intgr_cat_line_attr_flag
     ,p_intgr_item_line_attr_flag
     ,p_intgr_cat_line_asl_flag
     -------------------------------------------------
     );

  INSERT INTO pon_negotiation_styles_tl
      (style_id
      ,style_name
      ,description
      ,language
      ,source_lang
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login)
    SELECT
       p_style_id
      ,p_style_name
      ,p_description
      ,l.language_code
      ,USERENV('LANG')
      ,p_creation_date
      ,p_created_by
      ,p_last_update_date
      ,p_last_updated_by
      ,p_last_update_login
     FROM
       fnd_languages l
     WHERE installed_flag  in ('I', 'B')
       AND NOT EXISTS
         (SELECT NULL
	    FROM pon_negotiation_styles_tl tl
	   WHERE tl.style_id        = p_style_id
	     AND tl.language        = l.language_code);

END insert_row;

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
    ,p_description                   IN  pon_negotiation_styles_tl.description%TYPE) IS
BEGIN

   UPDATE pon_negotiation_styles
      SET status                       = p_status
          ,system_flag                 = p_system_flag
          ,line_attribute_enabled_flag = p_line_attribute_enabled_flag
          ,line_mas_enabled_flag       = p_line_mas_enabled_flag
          ,price_element_enabled_flag  = p_price_element_enabled_flag
          ,rfi_line_enabled_flag       = p_rfi_line_enabled_flag
          ,lot_enabled_flag            = p_lot_enabled_flag
          ,group_enabled_flag          = p_group_enabled_flag
          ,large_neg_enabled_flag      = p_large_neg_enabled_flag
          ,hdr_attribute_enabled_flag  = p_hdr_attribute_enabled_flag
          ,neg_team_enabled_flag       = p_neg_team_enabled_flag
          ,proxy_bidding_enabled_flag  = p_proxy_bidding_enabled_flag
          ,power_bidding_enabled_flag  = p_power_bidding_enabled_flag
          ,auto_extend_enabled_flag    = p_auto_extend_enabled_flag
          ,team_scoring_enabled_flag   = p_team_scoring_enabled_flag
          ,last_update_date            = p_last_update_date
          ,last_updated_by             = p_last_updated_by
          ,last_update_login           = p_last_update_login
          ,qty_price_tiers_enabled_flag = p_qty_price_tiers_enabled_flag
          ---------- Supplier Management: Negotiation Styles -----------
          ,supp_reg_qual_flag          = p_supp_reg_qual_flag
          ,supp_eval_flag              = p_supp_eval_flag
          ,hide_terms_flag             = p_hide_terms_flag
          ,hide_abstract_forms_flag    = p_hide_abstract_forms_flag
          ,hide_attachments_flag       = p_hide_attachments_flag
          ,internal_eval_flag          = p_internal_eval_flag
          ,hdr_supp_attr_enabled_flag  = p_hdr_supp_attr_enabled_flag
          ,intgr_hdr_attr_flag         = p_intgr_hdr_attr_flag
          ,intgr_hdr_attach_flag       = p_intgr_hdr_attach_flag
          ,line_supp_attr_enabled_flag = p_line_supp_attr_enabled_flag
          ,item_supp_attr_enabled_flag = p_item_supp_attr_enabled_flag
          ,intgr_cat_line_attr_flag    = p_intgr_cat_line_attr_flag
          ,intgr_item_line_attr_flag   = p_intgr_item_line_attr_flag
          ,intgr_cat_line_asl_flag     = p_intgr_cat_line_asl_flag
          --------------------------------------------------------------
     WHERE style_id = p_style_id;

    IF SQL%NOTFOUND
    THEN
       RAISE NO_DATA_FOUND;
    END IF;


   UPDATE pon_negotiation_styles_tl
      SET  style_name                  = p_style_name
           ,description                = p_description
           ,last_update_date           = p_last_update_date
           ,last_updated_by            = p_last_updated_by
           ,last_update_login          = p_last_update_login
           ,source_lang                = userenv('LANG')
    WHERE style_id = p_style_id
    AND USERENV('LANG') IN (language, source_lang);

   IF SQL%NOTFOUND
   THEN
       RAISE NO_DATA_FOUND;
   END IF;

END update_row;

-- Translate_row is called during NLS translation during FNDLOAD

PROCEDURE translate_row (
     p_style_id                     IN  pon_negotiation_styles.style_id%TYPE,
     p_style_name                   IN  pon_negotiation_styles_tl.style_name%TYPE,
     p_description                  IN  pon_negotiation_styles_tl.description%TYPE,
     p_owner                        IN  VARCHAR2,
     p_custom_mode                  IN  VARCHAR2,
     p_last_update_date             IN  VARCHAR2) IS

   f_luby    number;  -- entity owner in file
   f_ludate  date;    -- entity update date in file
   db_luby   number;  -- entity owner in db
   db_ludate date;    -- entity update date in db

BEGIN


   f_luby := fnd_load_util.owner_id(p_owner);

   -- Translate char last_update_date to date
   f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

   select LAST_UPDATED_BY, LAST_UPDATE_DATE
   into db_luby, db_ludate
   from pon_negotiation_styles_tl
   where style_id = p_style_id
   and userenv('LANG') = LANGUAGE;


     UPDATE pon_negotiation_styles_tl
        SET style_name              = p_style_name
            ,description            = p_description
            ,last_update_date       = f_ludate
            ,last_updated_by        = f_luby
            ,last_update_login      = 0
            ,source_lang            = userenv('LANG')
      WHERE style_id = p_style_id
        AND USERENV('LANG') IN (language, source_lang);

   IF SQL%NOTFOUND
   THEN
       RAISE NO_DATA_FOUND;
   END IF;

END translate_row;

-- Load_row is called during normal insertion/updates during FNDLOAD
-- It UPDATEs the row if available, else INSERTs

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
    ,p_description                   IN  pon_negotiation_styles_tl.description%TYPE) IS
 -- Last update information from the file being uploaded
    l_f_last_updated_by               pon_negotiation_styles.last_updated_by%TYPE;
    l_f_last_update_date              pon_negotiation_styles.last_update_date%TYPE;

 -- Last updated information for the row currently in the database
    l_db_last_updated_by              pon_negotiation_styles.last_updated_by%TYPE;
    l_db_last_update_date             pon_negotiation_styles.last_update_date%TYPE;

    l_style_id                        pon_negotiation_styles.style_id%TYPE;

BEGIN

-- Translate owner to file_last_updated_by
    l_f_last_updated_by := fnd_load_util.OWNER_ID(p_owner);

-- Translate char last_update_date to date
    l_f_last_update_date := NVL(TO_DATE(p_last_update_date, 'YYYY/MM/DD'), SYSDATE);

    SELECT last_updated_by,
           last_update_date
      INTO l_db_last_updated_by,
           l_db_last_update_date
      FROM pon_negotiation_styles
     WHERE style_id = p_style_id;


   update_row (
    p_style_id                       => p_style_id
    ,p_status                        => p_status
    ,p_system_flag                   => p_system_flag
    ,p_line_attribute_enabled_flag   => p_line_attribute_enabled_flag
    ,p_line_mas_enabled_flag         => p_line_mas_enabled_flag
    ,p_price_element_enabled_flag    => p_price_element_enabled_flag
    ,p_rfi_line_enabled_flag         => p_rfi_line_enabled_flag
    ,p_lot_enabled_flag              => p_lot_enabled_flag
    ,p_group_enabled_flag            => p_group_enabled_flag
    ,p_large_neg_enabled_flag        => p_large_neg_enabled_flag
    ,p_hdr_attribute_enabled_flag    => p_hdr_attribute_enabled_flag
    ,p_neg_team_enabled_flag         => p_neg_team_enabled_flag
    ,p_proxy_bidding_enabled_flag    => p_proxy_bidding_enabled_flag
    ,p_power_bidding_enabled_flag    => p_power_bidding_enabled_flag
    ,p_auto_extend_enabled_flag      => p_auto_extend_enabled_flag
    ,p_team_scoring_enabled_flag     => p_team_scoring_enabled_flag
    ,p_last_update_date              => l_f_last_update_date
    ,p_last_updated_by               => l_f_last_updated_by
    ,p_last_update_login             => 0
    ,p_qty_price_tiers_enabled_flag  => p_qty_price_tiers_enabled_flag
    ------------ Supplier Management: Negotiation Styles -------------
    ,p_supp_reg_qual_flag            => p_supp_reg_qual_flag
    ,p_supp_eval_flag                => p_supp_eval_flag
    ,p_hide_terms_flag               => p_hide_terms_flag
    ,p_hide_abstract_forms_flag      => p_hide_abstract_forms_flag
    ,p_hide_attachments_flag         => p_hide_attachments_flag
    ,p_internal_eval_flag            => p_internal_eval_flag
    ,p_hdr_supp_attr_enabled_flag    => p_hdr_supp_attr_enabled_flag
    ,p_intgr_hdr_attr_flag           => p_intgr_hdr_attr_flag
    ,p_intgr_hdr_attach_flag         => p_intgr_hdr_attach_flag
    ,p_line_supp_attr_enabled_flag   => p_line_supp_attr_enabled_flag
    ,p_item_supp_attr_enabled_flag   => p_item_supp_attr_enabled_flag
    ,p_intgr_cat_line_attr_flag      => p_intgr_cat_line_attr_flag
    ,p_intgr_item_line_attr_flag     => p_intgr_item_line_attr_flag
    ,p_intgr_cat_line_asl_flag       => p_intgr_cat_line_asl_flag
    ------------------------------------------------------------------
    ,p_style_name                    => p_style_name
    ,p_description                   => p_description);


EXCEPTION

   WHEN NO_DATA_FOUND
   THEN

   insert_row (
     p_style_id                      =>  p_style_id
    ,p_status                        =>  p_status
    ,p_system_flag                   =>  p_system_flag
    ,p_line_attribute_enabled_flag   =>  p_line_attribute_enabled_flag
    ,p_line_mas_enabled_flag         =>  p_line_mas_enabled_flag
    ,p_price_element_enabled_flag    =>  p_price_element_enabled_flag
    ,p_rfi_line_enabled_flag         =>  p_rfi_line_enabled_flag
    ,p_lot_enabled_flag              =>  p_lot_enabled_flag
    ,p_group_enabled_flag            =>  p_group_enabled_flag
    ,p_large_neg_enabled_flag        =>  p_large_neg_enabled_flag
    ,p_hdr_attribute_enabled_flag    =>  p_hdr_attribute_enabled_flag
    ,p_neg_team_enabled_flag         =>  p_neg_team_enabled_flag
    ,p_proxy_bidding_enabled_flag    =>  p_proxy_bidding_enabled_flag
    ,p_power_bidding_enabled_flag    =>  p_power_bidding_enabled_flag
    ,p_auto_extend_enabled_flag      =>  p_auto_extend_enabled_flag
    ,p_team_scoring_enabled_flag     =>  p_team_scoring_enabled_flag
    ,p_creation_date                 =>  l_f_last_update_date
    ,p_created_by                    =>  l_f_last_updated_by
    ,p_last_update_date              =>  l_f_last_update_date
    ,p_last_updated_by               =>  l_f_last_updated_by
    ,p_last_update_login             =>  0
    ,p_qty_price_tiers_enabled_flag  =>  p_qty_price_tiers_enabled_flag
    ------------ Supplier Management: Negotiation Styles -------------
    ,p_supp_reg_qual_flag            =>  p_supp_reg_qual_flag
    ,p_supp_eval_flag                =>  p_supp_eval_flag
    ,p_hide_terms_flag               =>  p_hide_terms_flag
    ,p_hide_abstract_forms_flag      =>  p_hide_abstract_forms_flag
    ,p_hide_attachments_flag         =>  p_hide_attachments_flag
    ,p_internal_eval_flag            =>  p_internal_eval_flag
    ,p_hdr_supp_attr_enabled_flag    =>  p_hdr_supp_attr_enabled_flag
    ,p_intgr_hdr_attr_flag           =>  p_intgr_hdr_attr_flag
    ,p_intgr_hdr_attach_flag         =>  p_intgr_hdr_attach_flag
    ,p_line_supp_attr_enabled_flag   =>  p_line_supp_attr_enabled_flag
    ,p_item_supp_attr_enabled_flag   =>  p_item_supp_attr_enabled_flag
    ,p_intgr_cat_line_attr_flag      =>  p_intgr_cat_line_attr_flag
    ,p_intgr_item_line_attr_flag     =>  p_intgr_item_line_attr_flag
    ,p_intgr_cat_line_asl_flag       =>  p_intgr_cat_line_asl_flag
    ------------------------------------------------------------------
    ,p_style_name                    =>  p_style_name
    ,p_description                   =>  p_description);

END load_row;

PROCEDURE delete_row (
    p_style_id                 IN  pon_negotiation_styles.style_id%TYPE
) IS

BEGIN

   DELETE FROM pon_negotiation_styles
         WHERE style_id = p_style_id;

   IF SQL%NOTFOUND
   THEN
      RAISE NO_DATA_FOUND;
   END IF;

   DELETE FROM pon_negotiation_styles_tl
         WHERE style_id = p_style_id;

END delete_row;


PROCEDURE add_language IS

BEGIN

    INSERT INTO pon_negotiation_styles_TL (
      style_id,
      style_name,
      description,
      language,
      source_lang,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    )
    SELECT
      style_id,
      style_name,
      description,
      lang.language_code,
      source_lang,
      tl.creation_date,
      tl.created_by,
      tl.last_update_date,
      tl.last_updated_by,
      tl.last_update_login
    FROM pon_negotiation_styles_tl tl,
         fnd_languages lang
    WHERE language = USERENV('LANG')
    AND lang.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS (SELECT NULL
                      FROM pon_negotiation_styles_TL tl2
                     WHERE tl2.style_id = tl.style_id
                       AND tl2.language = lang.language_code);

END add_language;

END pon_neg_styles_tl_pkg;

/
