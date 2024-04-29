--------------------------------------------------------
--  DDL for Package ITG_SYNCSUPPLIERINBOUND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SYNCSUPPLIERINBOUND_PVT" AUTHID CURRENT_USER AS
/* ARCS: $Header: itgvssis.pls 120.6 2006/08/25 06:40:28 pvaddana noship $
 * CVS:  itgvssis.pls,v 1.12 2002/12/23 21:20:30 ecoe Exp
 */

  TYPE vinfo_rec_type IS RECORD(
    syncind    VARCHAR2(1),
    vendor_id  NUMBER,
    currency   VARCHAR2(15),
    paymethod  VARCHAR2(25),
    terms_id   NUMBER,
    terms_name varchar2(50),
    vat_num    VARCHAR2(20),
    ctl_date   DATE,
    addr_style VARCHAR2(30)
  );

  G_MISS_VINFO_REC vinfo_rec_type;

  PROCEDURE Sync_Vendor(
    x_return_status    OUT NOCOPY VARCHAR2,          /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,          /* VARCHAR2(2000) */

    p_syncind          IN         VARCHAR2,          /* 'A', 'C', 'D' */
    p_name             IN         VARCHAR2,          /* name1 */
    p_onetime          IN         VARCHAR2 := NULL,  /* onetime */
    p_partnerid        IN         VARCHAR2 := NULL,  /* partnrid */
    p_active           IN         NUMBER   := NULL,  /* active */
    p_currency         IN         VARCHAR2 := NULL,  /* currency */
    p_dunsnumber       IN         VARCHAR2 := NULL,  /* dunsnumber */
    p_parentid         IN         NUMBER   := NULL,  /* parentid */
    p_paymethod        IN         VARCHAR2 := NULL,  /* paymethod */
    p_taxid            IN         VARCHAR2 := NULL,  /* taxid */
    p_termid           IN         VARCHAR2 := NULL,  /* termid */
    p_us_flag          IN         VARCHAR2 := 'Y',   /* userarea.ref_usflag */
    p_date             IN         DATE     := NULL,  /* controlarea.datetime */
    p_org              IN         VARCHAR2,           /* MOAC */
    x_vinfo_rec        OUT NOCOPY vinfo_rec_type
  );


  PROCEDURE Sync_VendorSite(

    x_return_status    OUT NOCOPY VARCHAR2,          /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,          /* VARCHAR2(2000) */

    /* TAG: address */
    p_addrline1        IN         VARCHAR2 := NULL,  /* addrline index=1 */
    p_addrline2        IN         VARCHAR2 := NULL,  /* addrline index=2 */
    p_addrline3        IN         VARCHAR2 := NULL,  /* addrline index=3 */
    p_addrline4        IN         VARCHAR2 := NULL,  /* addrline index=4 */
    p_city             IN         VARCHAR2 := NULL,  /* city */
    p_country          IN         VARCHAR2 := NULL,  /* country */
    p_county           IN         VARCHAR2 := NULL,  /* county */
    p_site_code        IN         VARCHAR2,          /* descriptn (key) */
    p_fax              IN         VARCHAR2 := NULL,  /* fax index=1 */
    p_zip              IN         VARCHAR2 := NULL,  /* postalcode */
    p_state            IN         VARCHAR2 := NULL,  /* stateprovn */
    p_phone            IN         VARCHAR2 := NULL,  /* telephone index=1 */
    p_org              IN         VARCHAR2 := NULL,
    p_purch_site       IN         VARCHAR2 := NULL,  /* userarea.ref_pursite */
    p_pay_site         IN         VARCHAR2 := NULL,  /* userarea.ref_paysite */
    p_rfq_site         IN         VARCHAR2 := NULL,  /* userarea.ref_rfqsite */
    p_pc_site          IN         VARCHAR2 := NULL,  /* userarea.ref_pcsite */
    p_vat_code         IN         VARCHAR2 := NULL,  /* userarea.ref_vatcode */

    p_vinfo_rec        IN         vinfo_rec_type
  );


  PROCEDURE Sync_VendorContact(
    x_return_status    OUT NOCOPY VARCHAR2,         /* VARCHAR2(1) */
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,         /* VARCHAR2(2000) */

    /* TAG: contact */
    p_title            IN         VARCHAR2 := NULL, /* contcttype */
    p_first_name       IN         VARCHAR2 := NULL, /* name index=1 */
    p_middle_name      IN         VARCHAR2 := NULL, /* name index=2 */
    p_last_name        IN         VARCHAR2 := NULL, /* name index=3 */
    p_phone            IN         VARCHAR2 := NULL, /* telephone index=1 */
    p_site_code        IN         VARCHAR2,         /* userarea.ref_sitecode */
    p_vinfo_rec        IN         vinfo_rec_type
  );
END ITG_SyncSupplierInbound_PVT;

 

/
