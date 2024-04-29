--------------------------------------------------------
--  DDL for Package OKL_LLA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LLA_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRLAUS.pls 120.12.12010000.4 2009/08/05 12:52:55 rpillay ship $ */
  /* *************************************** */

  g_canonical_mask    VARCHAR2(15) := FND_DATE.canonical_mask;
  G_DISPLAY_MASK      VARCHAR2(15) := fnd_profile.value('ICX_DATE_FORMAT_MASK');
  l_temp              VARCHAR2(15) := 'YYYY/MM/DD';

  -- MVASUDEV, 8/26/2004
  -- Added the following constants for Business Events Enabling
  G_KHR_PROCESS_NEW              CONSTANT VARCHAR2(3)  := 'NEW';
  G_KHR_PROCESS_MASS_REBOOK      CONSTANT VARCHAR2(11) := 'MASS_REBOOK';
  G_KHR_PROCESS_REBOOK           CONSTANT VARCHAR2(6)  := 'REBOOK';
  G_KHR_PROCESS_RELEASE_CONTRACT CONSTANT VARCHAR2(16) := 'RELEASE_CONTRACT';
  G_KHR_PROCESS_RELEASE_ASSETS   CONSTANT VARCHAR2(14) := 'RELEASE_ASSETS';
  G_KHR_PROCESS_SPLIT_CONTRACT   CONSTANT VARCHAR2(14) := 'SPLIT_CONTRACT';

  PROCEDURE format_round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2);

  PROCEDURE format_round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            p_org_id              IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2);


  PROCEDURE round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2);


PROCEDURE round_amount(
            p_api_version             IN NUMBER,
            p_init_msg_list       IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            p_amount              IN  VARCHAR2,
            p_currency_code       IN  VARCHAR2,
            p_org_id              IN  VARCHAR2,
            x_amount              OUT NOCOPY VARCHAR2);

FUNCTION    get_number
            (p_amount_in IN VARCHAR2)
            RETURN VARCHAR2;

  FUNCTION  get_canonical_date(
            p_date_char IN VARCHAR2)
            RETURN VARCHAR2;

  FUNCTION  get_canonical_date(
            p_date_char IN VARCHAR2,
            p_date_mask IN VARCHAR2)
            RETURN VARCHAR2;

  FUNCTION  validate_get_canonical_date(
            p_date_char IN VARCHAR2)
            RETURN VARCHAR2;


  FUNCTION  get_display_date(
            p_date_char IN VARCHAR2)
           RETURN VARCHAR2;

FUNCTION  get_display_date(
            p_date_char IN VARCHAR2,
            p_date_mask IN VARCHAR2)
           RETURN VARCHAR2;

  FUNCTION  convert_date(
            p_date_in_char IN VARCHAR2,
            p_date_in_mask IN VARCHAR2,
            p_date_out_mask IN VARCHAR2)
            RETURN VARCHAR2;

  /*
  -- mvasudev, 08/17/2004
  Added the following functions for Business Events Enabling
  */

  FUNCTION  check_mass_rebook_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2;

  FUNCTION  check_rebook_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2;

  FUNCTION  check_release_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2;

  FUNCTION  check_release_assets(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2;

  FUNCTION  check_new_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2;

  FUNCTION  check_split_contract(
            p_chr_id IN NUMBER)
            RETURN VARCHAR2;

  FUNCTION get_contract_process(
           p_chr_id IN NUMBER)
           RETURN VARCHAR2;

  FUNCTION is_lease_contract(
           p_chr_id okc_k_headers_b.id%TYPE)
           RETURN VARCHAR2;
  /* -- end, mvasudev, 08/17/2004 */

  -- start: cklee/mvasudev -- Fixed 11.5.9 Bug#4392051/okl.h 4437938
  FUNCTION calculate_end_date(
            p_start_date              IN  DATE,
            p_months         IN  NUMBER,
            p_start_day IN NUMBER DEFAULT NULL,
            p_contract_end_date IN DATE DEFAULT NULL --Bug#5441811
	)
  RETURN DATE;
  -- end: cklee/mvasudev -- Fixed 11.5.9 Bug#4392051/okl.h 4437938

  FUNCTION get_lookup_meaning(
            p_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE,
            p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE)
  RETURN VARCHAR2;

  --Bug# 4903011
  PROCEDURE check_line_update_allowed(p_api_version   IN  NUMBER,
                                      p_init_msg_list IN  VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count     OUT NOCOPY NUMBER,
                                      x_msg_data      OUT NOCOPY VARCHAR2,
                                      p_cle_id        IN  NUMBER);

--asawanka added
  FUNCTION  get_asset_location(
            p_kle_id IN NUMBER,
            p_khr_id IN NUMBER)
           RETURN VARCHAR2;
 FUNCTION  get_ast_install_loc_id(
            p_kle_id IN NUMBER,
            p_khr_id IN NUMBER) RETURN NUMBER;
FUNCTION  get_booked_asset_number(
            p_kle_id IN NUMBER,
            p_khr_id IN NUMBER)
           RETURN VARCHAR2;

-- Added procedure as part of Bug#6651871 to create Pay Site for Supplier start
PROCEDURE create_pay_site(
            party_id                  IN NUMBER,
	    party_site_id             IN NUMBER := NULL, -- added to create pay site
	    p_org_id                  IN NUMBER, -- added to create pay site
	    p_api_version             IN NUMBER,
	    p_init_msg_list           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2
	    );
-- Added procedure as part of Bug#6651871 to create Pay Site for Supplier end

-- Added procedure as part of Bug#6636587 to Create Vendor for a Party in TCA start

PROCEDURE create_related_vendor(
            party_id                  IN NUMBER,
	    party_site_id             IN NUMBER := NULL,
	    p_org_id                  IN NUMBER ,
	    p_api_version             IN NUMBER,
	    p_init_msg_list           IN VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2
	    ) ;
-- Added procedure as part of Bug#6636587 to Create Vendor for a Party in TCA end

--Bug# 8370699
FUNCTION  get_last_activation_date(
          p_chr_id IN NUMBER)
          RETURN DATE;


PROCEDURE update_external_id (p_chr_id in number,
                              x_return_status OUT NOCOPY VARCHAR2);

--Bug# 8756653
PROCEDURE check_rebook_upgrade(p_api_version   IN  NUMBER,
                               p_init_msg_list IN  VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               p_chr_id        IN  NUMBER,
                               p_rbk_chr_id    IN  NUMBER DEFAULT NULL);

END Okl_Lla_Util_Pvt;

/
