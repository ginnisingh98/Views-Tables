--------------------------------------------------------
--  DDL for Package ITG_BOAPI_WRAPPERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_BOAPI_WRAPPERS" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgwraps.pls 120.2 2006/01/23 03:49:03 bsaratna noship $
 * CVS:  itgwraps.pls,v 1.31 2003/05/30 00:49:39 klai Exp
 */

  g_active NUMBER;

  PROCEDURE Begin_Wrapper(
    p_refid      IN  VARCHAR2,
    p_org        IN  NUMBER,
    p_xmlg_xtype IN  VARCHAR2,
    p_xmlg_xstyp IN  VARCHAR2,
    p_xmlg_docid IN  VARCHAR2,
    p_doctyp     IN  VARCHAR2,
    p_clntyp     IN  VARCHAR2,
    p_doc        IN  VARCHAR2,
    p_rel        IN  VARCHAR2,
    p_cdate      IN  DATE
  );

  PROCEDURE End_Wrapper(
    p_refid          IN  VARCHAR2 := NULL,
    p_doc            IN  VARCHAR2 := NULL,
    p_cdate          IN  DATE := SYSDATE,
    x_cln_id         OUT NOCOPY NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_return_message OUT NOCOPY VARCHAR2
  );

  PROCEDURE Reap_Messages(
    p_refid    IN  VARCHAR2 := NULL,
    p_doc      IN  VARCHAR2 := NULL,
    p_cdate    IN  DATE := SYSDATE
  );

  /* Wrap ITG_SyncCOAInbound_PVT from itgvsci?.pls */
  PROCEDURE Sync_FlexValue(
    p_syncind          IN  VARCHAR2,
    p_flex_value       IN  VARCHAR2,
    p_vset_id          IN  NUMBER,
    p_flex_desc        IN  VARCHAR2,
    p_action_date      IN  DATE,
    p_effective_date   IN  DATE,
    p_expiration_date  IN  DATE,
    p_acct_type        IN  VARCHAR2,
    p_enabled_flag     IN  VARCHAR2
  );

  /* Wrap ITG_SyncExchInbound_PVT from itgvsei?.pls */
  PROCEDURE Process_ExchangeRate(
    p_syncind          IN  VARCHAR2,
    p_quantity         IN  NUMBER,
    p_currency_from    IN  VARCHAR2,
    p_currency_to      IN  VARCHAR2,
    p_factor           IN  VARCHAR2,
    p_sob              IN  VARCHAR2,
    p_ratetype         IN  VARCHAR2,
    p_creation_date    IN  DATE,
    p_effective_date   IN  DATE
  );

  PROCEDURE Update_PoLine(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2,
    p_commit           IN         VARCHAR2,
    p_validation_level IN         NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_po_code          IN         VARCHAR2,
    p_org_id           IN         VARCHAR2,
    p_release_id       IN         VARCHAR2,
    p_line_num         IN         NUMBER,
    p_doc_type         IN         VARCHAR2,
    p_quantity         IN         NUMBER,
    p_amount           IN         NUMBER
  );

  /* Wrap ITG_SyncSupplierInbound_PVT from itgvssi?.pls (3 procs) */
  PROCEDURE Sync_Vendor(
    p_syncind          IN  VARCHAR2,
    p_name             IN  VARCHAR2,
    p_onetime          IN  VARCHAR2,
    p_partnerid        IN  VARCHAR2,
    p_active           IN  NUMBER,
    p_currency         IN  VARCHAR2,
    p_dunsnumber       IN  VARCHAR2,
    p_parentid         IN  NUMBER,
    p_paymethod        IN  VARCHAR2,
    p_taxid            IN  VARCHAR2,
    p_termid           IN  VARCHAR2,
    p_us_flag          IN  VARCHAR2,
    p_date             IN  DATE,
    p_org              IN  VARCHAR2 -- MOAC
  );

  PROCEDURE Sync_VendorSite(
    p_addrline1        IN  VARCHAR2,
    p_addrline2        IN  VARCHAR2,
    p_addrline3        IN  VARCHAR2,
    p_addrline4        IN  VARCHAR2,
    p_city             IN  VARCHAR2,
    p_country          IN  VARCHAR2,
    p_county           IN  VARCHAR2,
    p_site_code        IN  VARCHAR2,
    p_fax              IN  VARCHAR2,
    p_zip              IN  VARCHAR2,
    p_state            IN  VARCHAR2,
    p_phone            IN  VARCHAR2,
    p_org              IN  VARCHAR2,
    p_purch_site       IN  VARCHAR2,
    p_pay_site         IN  VARCHAR2,
    p_rfq_site         IN  VARCHAR2,
    p_pc_site          IN  VARCHAR2,
    p_vat_code         IN  VARCHAR2
  );

  PROCEDURE Sync_VendorContact(
    p_title            IN  VARCHAR2,
    p_first_name       IN  VARCHAR2,
    p_middle_name      IN  VARCHAR2,
    p_last_name        IN  VARCHAR2,
    p_phone            IN  VARCHAR2,
    p_site_code        IN  VARCHAR2
  );

  /* Wrap ITG_SyncItemInbound_PVT from itgvsii?.pls */
  PROCEDURE Sync_Item(
    p_syncind          IN  VARCHAR2,
    p_org_id           IN  NUMBER,
    p_hazrdmatl        IN  VARCHAR2,
    p_create_date      IN  DATE,
    p_item             IN  VARCHAR2,
    p_uom              IN  VARCHAR2,
    p_itemdesc         IN  VARCHAR2,
    p_itemstatus       IN  VARCHAR2,
    p_itemtype         IN  VARCHAR2,
    p_rctrout          IN  VARCHAR2,
    p_commodity1       IN  VARCHAR2,
    p_commodity2       IN  VARCHAR2
  );

  PROCEDURE Process_PoNumber(
    p_reqid            IN  NUMBER,
    p_reqlinenum       IN  NUMBER,
    p_poid             IN  NUMBER,
    p_org              IN  NUMBER
  );

  /* Wrap ITG_SyncUOMInbound_PVT from itgvsui?.pls */
  PROCEDURE Sync_UOM_ALL(
    p_task             IN  VARCHAR2,
    p_syncind          IN  VARCHAR2,
    p_uom              IN  VARCHAR2,
    p_uomcode          IN  VARCHAR2,
    p_uomclass         IN  VARCHAR2,
    p_buomflag         IN  VARCHAR2,
    p_description      IN  VARCHAR2,
    p_defconflg        IN  VARCHAR2,
    p_fromcode         IN  VARCHAR2,
    p_touomcode        IN  VARCHAR2,
    p_itemid           IN  NUMBER,
    p_fromfactor       IN  VARCHAR2,
    p_tofactor         IN  VARCHAR2,
    p_dt_creation      IN  DATE,
    p_dt_expiration    IN  DATE
  );


END ITG_BOAPI_Wrappers;

 

/
