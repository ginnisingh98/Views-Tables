--------------------------------------------------------
--  DDL for Package JAI_RGM_THHOLD_PROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RGM_THHOLD_PROC_PKG" AUTHID CURRENT_USER AS
/*$Header: jai_rgm_thld_prc.pls 120.1.12000000.1 2007/07/24 06:56:12 rallamse noship $*/
  /**


  /* ----------------------------------------------------------------------------

   CHANGE HISTORY:
	 -------------------------------------------------------------------------------
	 S.No      Date         Author and Details
	 -------------------------------------------------------------------------------
	  1.       01/02/2007    Created by Bgowrava for forward porting bug#5631784. Version#120.0.
	                        This was Directly created from 11i version 115.2


    ----------------------------------------------------------------------------
     get_threshold_slab_id - returns identifier for current threshold slab as out parameter
     IN
          p_regime_id         - A valid regime_id from jai_rgm_thresholds.
          p_org_tan_no       - Organiztion TAN as defined in the regime setup
          p_organization_id   - Inventory organization defined in the regime setup
          p_party_type        - Party type.  Can be either CUSTOMER or VENDOR.  Currently only CUSTOMER is valid.
          p_party_id          - Party identifier.
          p_fin_year          - Financial year
          p_org_id            - Optional parameter.  If fin_year is not given, operating unit is used to derive the fin_year
          p_source_trx_date   - Optional parameter.  If fin_year is not given, transaction date is used to derive the fin_year
          p_called_from       - This will always be null if the call is external.  For all the external call the API will simply
                                look return value of column JAI_RGM_THRESHOLD.THRESHOLD_SLAB_ID for the given parameters.
                                Only when the call is internal it will look into the setup to derrive the threshold_slab_id
      OUT
          p_threshold_slab_id - Current threshold slab identifier
          p_process_flag      - Flag indicates the process status, can be either
                                   Successful        (SS)
                                   Expected Error    (EE)
                                   Unexpected Error  (UE)
          p_process_message   - Message to be passed to caller of the api.  It can be null in case of p_process_flag = 'SS'
  */

  procedure get_threshold_slab_id
            (
              p_regime_id               in            jai_rgm_thresholds.regime_id%type
            , p_org_tan_no              in            JAI_RGM_REGISTRATIONS.attribute_value%type default null
            , p_organization_id         in            hr_organization_units.organization_id%type default null
            , p_party_type              in            jai_rgm_thresholds.party_type%type
            , p_party_id                in            jai_rgm_thresholds.party_id%type
            , p_fin_year                in            jai_rgm_thresholds.fin_year%type default null
            , p_org_id                  in            jai_ap_tds_thhold_taxes.operating_unit_id%type default null
            , p_source_trx_date         in            date    default null
            , p_called_from             in            varchar2 default null
            , p_threshold_slab_id  		  out  nocopy   jai_rgm_thresholds.threshold_slab_id%type
            , p_process_flag            out  nocopy   varchar2
            , p_process_message         out  nocopy   varchar2
            );
  /*
      get_threshold_tax_cat_id    - returns tax category defined in the threshold setup as out parameter
      IN
          p_threshold_slab_id     - Threshold slab identifier
          p_org_id                - Operating unit
      OUT
          p_threshold_tax_cat_id  - Tax category identifier
          p_process_flag          - Flag indicates the process status, can be either
                                      Successful        (SS)
                                      Expected Error    (EE)
                                      Unexpected Error  (UE)
          p_process_message       - Message to be passed to caller of the api.  It can be null in case of p_process_flag = 'SS'
  */

  procedure get_threshold_tax_cat_id
            (
               p_threshold_slab_id       in           jai_rgm_thresholds.threshold_slab_id%type
            ,  p_org_id                  in           jai_ap_tds_thhold_taxes.operating_unit_id%type
            ,  p_threshold_tax_cat_id 	 out  nocopy  jai_ap_tds_thhold_taxes.tax_category_id%type
            ,  p_process_flag            out  nocopy  varchar2
            ,  p_process_message         out  nocopy  varchar2
            );
  /*
      default_thhold_taxes       - defaults threshold taxes defined by the tax category
      IN
          p_source_trx_id        -   transaction identifier
          p_source_trx_line_id   -   transaction line identifier
          p_source_event         -   Event for which taxes to be defaulted. Currently only 'DELIVERY'
          p_action               -   Action on which taxes are defaulted.  Currently only 'DEFAULT_TAXES'
          p_threshold_tax_cat_id -   Tax category identifier for taxes to be defaulted
          p_tax_base_line_number -   Line number to be used as base line when calculating taxes.  Default is 0
          p_last_line_number     -   Line number after which threshold taxes to be defaulted

      OUT
          p_process_flag         -   Flag indicates the process status, can be either
                                       Successful        (SS)
                                       Expected Error    (EE)
                                       Unexpected Error  (UE)
          p_process_message      -   Message to be passed to caller of the api.  It can be null in case of p_process_flag = 'SS'
  */

  procedure default_thhold_taxes
            (
              p_source_trx_id             in            number
            , p_source_trx_line_id        in            number
            , p_source_event              in            varchar2
            , p_action                    in            varchar2
            , p_threshold_tax_cat_id      in            jai_ap_tds_thhold_taxes.tax_category_id%type
            , p_tax_base_line_number      in            number   default 0
            , p_last_line_number          in            number   default 0
            , p_currency_code             in            varchar2 default null
            , p_currency_conv_rate        in            number   default null
            , p_quantity                  in            number   default null
            , p_base_tax_amt              in            number   default null
            , p_assessable_value          in            number   default null
            , p_inventory_item_id         in            number   default null
            , p_uom_code                  in            varchar2 default null
            , p_vat_assessable_value      in            number   default null
            , p_process_flag              out  nocopy   varchar2
            , p_process_message           out  nocopy   varchar2
            );

  procedure maintain_threshold
            ( p_transaction_id    in            jai_rgm_refs_all.transaction_id%type
            , p_last_line_flag    in            varchar2 default jai_constants.yes
            , p_process_flag      out nocopy    varchar2
            , p_process_message   out nocopy    varchar2
            );

  procedure insert_threshold_dtl
            ( p_record              in          jai_rgm_threshold_dtls%rowtype
            , p_threshold_dtl_id    out nocopy  jai_rgm_threshold_dtls.threshold_dtl_id%type
            , p_row_id              out nocopy  rowid
            ) ;

  procedure insert_threshold_hdr
            ( p_record          in            jai_rgm_thresholds%rowtype
            , p_threshold_id    out nocopy    jai_rgm_thresholds.threshold_id%type
            , p_row_id          out nocopy    rowid
            );

  procedure sync_threshold_header
              ( p_threshold_id            in            jai_rgm_thresholds.threshold_id%type
              , p_source_trx_date         in            date
              , p_thhold_slab_change_flag out nocopy    varchar2
              , p_new_thhold_slab_id      out nocopy    jai_rgm_thresholds.threshold_slab_id%type
              , p_process_flag            out nocopy    varchar2
              , p_process_message         out nocopy    varchar2
              ) ;





end jai_rgm_thhold_proc_pkg;
 

/
