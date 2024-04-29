--------------------------------------------------------
--  DDL for Package Body POS_SEARCH_DUP_PARTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SEARCH_DUP_PARTY_PKG" AS
/* $Header: POSDQMB.pls 120.0.12010000.16 2012/12/14 10:24:06 ppotnuru noship $ */

  g_module VARCHAR2(30) := 'POS_SEARCH_DUP_PARTY_PKG';

  PROCEDURE find_duplicate_parties
       ( p_init_msg_list  IN VARCHAR2 := fnd_api.g_true,
        p_supp_name      IN VARCHAR2,
        p_supp_name_alt  IN VARCHAR2,
        p_tax_payer_id   IN VARCHAR2,
        p_tax_reg_no     IN VARCHAR2,
        p_duns_no        IN VARCHAR2,
        p_sic_code       IN VARCHAR2,
        p_sup_reg_id     IN VARCHAR2,
        x_search_ctx_id  OUT NOCOPY NUMBER,
        x_return_status  OUT NOCOPY VARCHAR2,
        x_msg_count      OUT NOCOPY NUMBER,
        x_msg_data       OUT NOCOPY VARCHAR2)
  IS
    l_party_search_rec    hz_party_search.party_search_rec_type;
    l_search_ctx_id       NUMBER;
    l_num_matches         NUMBER;
    l_party_site_list     hz_party_search.party_site_list;
    l_contact_list        hz_party_search.contact_list;
    l_contact_point_list  hz_party_search.contact_point_list;
    l_supp_name           l_party_search_rec.party_all_names%TYPE := p_supp_name;
    l_restrict_sql        VARCHAR2(20) := NULL;
    l_match_type          VARCHAR2(20) := NULL;
    l_search_merged       VARCHAR2(20) := NULL;
    l_rule_id             NUMBER;
    l_step         VARCHAR2(100);
    l_method       VARCHAR2(100);

    l_contact_name        VARCHAR2(100);
    l_email		  VARCHAR2(100);
    l_contact_phone	  VARCHAR2(100);

    addr_cnt          number := 0;
    cntc_cnt          number := 0;

    CURSOR c_supp_addr_cur IS
    SELECT address_line1, city, state, postal_code, country
    FROM POS_ADDRESS_REQUESTS
    WHERE mapping_id = (select mapping_id
                        from pos_supplier_mappings
                        where supplier_reg_id = p_sup_reg_id);

   CURSOR c_supp_contact_cur IS
    SELECT (first_name || ' ' || last_name) contact_name,
       email_address, phone_number
    FROM pos_contact_requests
    WHERE  do_not_delete = 'Y' and
           mapping_id = (select mapping_id
                        from pos_supplier_mappings
                        where supplier_reg_id = p_sup_reg_id);


  BEGIN

     l_method := 'find_duplicate_parties';
     l_step := 'Before Calling hz_party_search.find_parties';
     x_return_status := fnd_api.g_ret_sts_error;
     x_msg_count := 0;
     x_msg_data := NULL;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , l_step);
      END IF;

   /* Get Match Rule Id from Profile Option */

      l_rule_id := fnd_profile.value('HZ_ORG_DUP_PREV_MATCHRULE');

    l_party_search_rec.party_all_names := l_supp_name;
    l_party_search_rec.organization_type := 'ORGANIZATION';
    l_party_search_rec.jgzz_fiscal_code := p_tax_payer_id;
    l_party_search_rec.tax_reference := p_tax_reg_no;
    l_party_search_rec.duns_number_c := p_duns_no;
/* Commenting below as we donot have provision on UI to enter SIC code Type */
--    l_party_search_rec.sic_code := p_sic_code;
    l_party_search_rec.organization_name_phonetic  := p_supp_name_alt;


     FOR address_rec IN c_supp_addr_cur
     loop
      addr_cnt := addr_cnt+1;
      l_party_site_list(addr_cnt).address1    := address_rec.address_line1;
      l_party_site_list(addr_cnt).city        := address_rec.city;
      l_party_site_list(addr_cnt).state       := address_rec.state;
      l_party_site_list(addr_cnt).postal_code := address_rec.postal_code;
      l_party_site_list(addr_cnt).country     := address_rec.country;
     end loop;

     FOR cntc_rec IN c_supp_contact_cur
     loop
      cntc_cnt := cntc_cnt+1;
      l_contact_list(cntc_cnt).contact_name :=  cntc_rec.contact_name;
      if (cntc_rec.email_address is not null) then
        l_contact_point_list(cntc_cnt).contact_point_type := 'EMAIL';
        l_contact_point_list(cntc_cnt).email_address := cntc_rec.email_address;
     elsif ( cntc_rec.phone_number is not null) then
      l_contact_point_list(cntc_cnt).contact_point_type := 'PHONE';
      l_contact_point_list(cntc_cnt).phone_number :=  cntc_rec.phone_number;
     end if;
      end loop;

    hz_party_search.find_parties(
    p_init_msg_list,
    l_rule_id,
    l_party_search_rec,
    l_party_site_list,
    l_contact_list,
    l_contact_point_list,
    l_restrict_sql,
    l_search_merged,
    l_search_ctx_id,
    l_num_matches,
    x_return_status,
    x_msg_count,
    x_msg_data);

    l_step := 'After Calling hz_party_search.find_parties';

    IF (x_return_status = fnd_api.g_ret_sts_error) THEN
      IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method
            , 'Error in hz_party_search.find_parties ' || x_msg_data);
      END IF;
      RETURN;
    ELSIF (x_return_status = fnd_api.g_ret_sts_success) THEN
       x_search_ctx_id := l_search_ctx_id;
    END IF;

    RETURN;

  END find_duplicate_parties;

PROCEDURE pos_create_organization(
    p_supp_name            IN     VARCHAR2,
    p_supp_name_alt        IN     VARCHAR2,
    p_tax_payer_id         IN     VARCHAR2,
    p_tax_reg_no           IN     VARCHAR2,
    p_duns_number          IN     VARCHAR2,
    p_sic_code             IN     VARCHAR2,
    p_url                  IN     VARCHAR2,
    p_org_name_phonetic    IN     VARCHAR2,
    x_return_status        OUT    NOCOPY VARCHAR2,
    x_msg_count            OUT    NOCOPY NUMBER,
    x_msg_data             OUT    NOCOPY VARCHAR2,
    x_org_party_id         OUT    NOCOPY NUMBER,
    x_org_party_number     OUT    NOCOPY VARCHAR2,
    x_org_profile_id       OUT    NOCOPY NUMBER
  )
  AS
    l_org_rec                      HZ_PARTY_V2PUB.organization_rec_type;
    l_party_rec                    HZ_PARTY_V2PUB.party_rec_type;
    l_api_name                     VARCHAR2(30) := null;
    l_context                      VARCHAR2(30) := null;
    l_step                         VARCHAR2(100):= null;
    l_method                       VARCHAR2(100):= null;
    g_module                       VARCHAR2(100):= null;
    l_party_id                     NUMBER       := 0   ;
    l_party_usage_code             VARCHAR2(100):= null;

    l_org_return_status            VARCHAR2(50);
    l_org_msg_count                NUMBER;
    l_org_msg_data                 VARCHAR2(1000);
    l_party_num                    VARCHAR2(1);


    l_url VARCHAR2(100)    :=   p_url;
    l_contact_point_rec         HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
    l_url_rec                   HZ_CONTACT_POINT_V2PUB.web_rec_type;
    l_url_return_status VARCHAR2(50):= FND_API.G_RET_STS_SUCCESS;
    l_url_msg_count             NUMBER;
    l_url_msg_data              VARCHAR2(1000);
    l_url_contact_point_id      NUMBER;


BEGIN

    l_method           := 'create_new_organization';
    l_step             := 'Before Calling hz_party_v2pub.create_organization';
    l_api_name         := 'Create_Organization';


    l_org_rec.organization_name   :=  p_supp_name;
    l_org_rec.known_as            := p_supp_name_alt;
    l_org_rec.organization_name_phonetic   :=  p_org_name_phonetic;
    l_org_rec.created_by_module   := 'POS_SUPPLIER_MGMT';
    l_org_rec.APPLICATION_ID      :=  200;
    l_org_rec.duns_number_c       := p_duns_number;
/* Commenting below as we donot have provision on UI to enter SIC code Type */
--    l_org_rec.sic_code            := p_sic_code;
    l_org_rec.JGZZ_FISCAL_CODE    :=  p_tax_payer_id;
    l_org_rec.TAX_REFERENCE       :=  p_tax_reg_no;

    fnd_profile.get('HZ_GENERATE_PARTY_NUMBER', l_party_num);
    IF nvl(l_party_num, 'Y') = 'N' THEN
           SELECT HZ_PARTY_NUMBER_S.Nextval
           INTO l_party_rec.party_number
           FROM DUAL;
    END IF;

    l_org_rec.party_rec := l_party_rec;


    hz_party_v2pub.create_organization(
                p_init_msg_list => FND_API.G_FALSE,
                p_organization_rec => l_org_rec,
                p_party_usage_code => 'SUPPLIER_PROSPECT',
                x_return_status => l_org_return_status,
                x_msg_count => l_org_msg_count,
                x_msg_data => l_org_msg_data,
                x_party_id => x_org_party_id,
                x_party_number => x_org_party_number,
                x_profile_id => x_org_profile_id);

    x_return_status    :=  l_org_return_status ;
    x_msg_count        :=  l_org_msg_count;
    x_msg_data         :=  l_org_msg_data;

    l_step := 'After Calling hz_party_v2pub.create_organization';

    IF  l_org_return_status <> fnd_api.g_ret_sts_success THEN

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method||'.'||l_step
            , 'Error in hz_party_v2pub.create_organization ' || x_msg_data);
        END IF;
        RETURN;
    END IF;

    IF l_url IS NOT NULL THEN

      --populate contact point record
      l_contact_point_rec.owner_table_name  := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id    := x_org_party_id;
      l_contact_point_rec.created_by_module := 'POS_SUPPLIER_MGMT';
      l_contact_point_rec.application_id    := 200;

      --populate url record

      l_contact_point_rec.contact_point_type    := 'WEB';
      l_contact_point_rec.primary_flag          := 'Y';
      l_contact_point_rec.contact_point_purpose := 'HOMEPAGE';
      l_contact_point_rec.primary_by_purpose    := 'Y';
      l_url_rec.web_type := 'HTTP';
      l_url_rec.url      := l_url;

              hz_contact_point_v2pub.create_web_contact_point(
                     p_init_msg_list     => FND_API.G_FALSE,
                     p_contact_point_rec => l_contact_point_rec,
                     p_web_rec           => l_url_rec,
                     x_return_status    => l_url_return_status,
                     x_msg_count        => l_url_msg_count,
                     x_msg_data         => l_url_msg_data,
                     x_contact_point_id => l_url_contact_point_id);

      IF l_url_return_status <> fnd_api.g_ret_sts_success THEN

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_error,
                 g_module || '.' || l_method || '.' || l_step,
                 'hz_contact_point_v2pub.create_web_contact_point ' ||
                  l_url_msg_data);
        END IF;
        RETURN;
      END IF;

    END IF;

RETURN;
END pos_create_organization;

PROCEDURE update_supp_party_id(
        p_supp_reg_id		IN NUMBER,
        p_party_id		IN NUMBER,
        x_return_status		OUT NOCOPY VARCHAR2
)
AS

	l_step			VARCHAR2(100):= null;
	l_method                VARCHAR2(100):= null;

	l_supp_reg_id 		NUMBER                 :=   p_supp_reg_id  ;
	l_party_id		NUMBER                 :=   p_party_id  ;

BEGIN
	l_method	:= 'update_supp_party_id';
	l_step		:= 'update pos_supplier_registrations with partyid';


	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	 fnd_log.string
	   (fnd_log.level_statement
	    , g_module || '.' || l_method
	    , l_step);
	END IF;

     Begin
	UPDATE pos_supplier_registrations
	SET vendor_party_id = l_party_id,
	    last_updated_by = fnd_global.user_id,
	    last_update_date = Sysdate,
	    last_update_login = fnd_global.login_id
	WHERE supplier_reg_id = l_supp_reg_id;

	x_return_status := fnd_api.g_ret_sts_success;
     Exception
       When no_data_found then
        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method||'.'||l_step
            , 'Error updating party id ');
        END IF;
        x_return_status :=  fnd_api.g_ret_sts_error;
       When others then
          x_return_status :=  fnd_api.g_ret_sts_error;
     end;

RETURN;
END update_supp_party_id;


PROCEDURE pos_update_organization(
    p_supp_name                 IN     VARCHAR2,
    p_supp_name_alt             IN     VARCHAR2,
    p_tax_payer_id              IN     VARCHAR2,
    p_tax_reg_no                IN     VARCHAR2,
    p_duns_number               IN     VARCHAR2,
    p_sic_code                  IN     VARCHAR2,
    p_party_id                  IN     NUMBER,
--    p_party_obj_version_no	IN     NUMBER,
    x_profile_id		OUT    NOCOPY NUMBER,
    x_return_status             OUT    NOCOPY VARCHAR2,
    x_msg_count                 OUT    NOCOPY NUMBER,
    x_msg_data                  OUT    NOCOPY VARCHAR2
  )
  AS
    l_org_rec                      HZ_PARTY_V2PUB.organization_rec_type;
    l_party_rec                    HZ_PARTY_V2PUB.party_rec_type;
    l_api_name                     VARCHAR2(30) := null;
    l_context                      VARCHAR2(30) := null;
    l_step                         VARCHAR2(100):= null;
    l_method                       VARCHAR2(100):= null;
    g_module                       VARCHAR2(100):= null;
    l_profile_id                   NUMBER;
    l_org_return_status            VARCHAR2(50);
    l_org_msg_count                NUMBER;
    l_party_obj_version            NUMBER := 0;
    l_org_msg_data                 VARCHAR2(1000);
    l_party_num                    VARCHAR2(1);

BEGIN

    l_method           := 'update_organization';
    l_step             := 'Before Calling hz_party_v2pub.update_organization';
    l_api_name         := 'Update_Organization';


     select object_version_number
     into l_party_obj_version
     from hz_parties
     where party_id = p_party_id;

    l_org_rec.organization_name   :=  p_supp_name;
    l_org_rec.organization_name_phonetic   :=  p_supp_name_alt;
/* Commenting below as we cannor update application Id while updating Party Rec */
    --l_org_rec.APPLICATION_ID      :=  200;
    l_org_rec.duns_number_c       := p_duns_number;
/* Commenting below as we donot have provision on UI to enter SIC code Type */
--    l_org_rec.sic_code            := p_sic_code;
    l_org_rec.JGZZ_FISCAL_CODE    :=  p_tax_payer_id;
    l_org_rec.TAX_REFERENCE       :=  p_tax_reg_no;

    l_party_rec.party_id  := p_party_id;

    l_org_rec.party_rec := l_party_rec;


    hz_party_v2pub.update_organization(
                p_init_msg_list => FND_API.G_FALSE,
                p_organization_rec => l_org_rec,
                p_party_object_version_number => l_party_obj_version,
                x_profile_id => l_profile_id,
                x_return_status => l_org_return_status,
                x_msg_count => l_org_msg_count,
                x_msg_data => l_org_msg_data
                );

    x_return_status    :=  l_org_return_status ;
    x_msg_count        :=  l_org_msg_count;
    x_msg_data         :=  l_org_msg_data;

    l_step := 'After Calling hz_party_v2pub.update_Organization';

    IF  l_org_return_status <> fnd_api.g_ret_sts_success THEN

        IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
         fnd_log.string
           (fnd_log.level_error
            , g_module || '.' || l_method||'.'||l_step
            , 'Error in hz_party_v2pub.update_organization ' || x_msg_data);
        END IF;
        RETURN;
    END IF;

RETURN;
END pos_update_organization;


PROCEDURE search_duplicate_parties(
                                  p_init_msg_list IN VARCHAR2 := fnd_api.g_true,
                                   p_party_name    IN VARCHAR2,
                                   p_party_number  IN VARCHAR2,
                                   p_status        IN VARCHAR2,
                                   p_sic_code      IN VARCHAR2,
                                   p_address       IN VARCHAR2,
                                   p_city          IN VARCHAR2,
                                   p_state         IN VARCHAR2,
                                   p_country       IN VARCHAR2,
                                   x_search_ctx_id OUT NOCOPY NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2,
                                   x_msg_count     OUT NOCOPY NUMBER,
                                   x_msg_data      OUT NOCOPY VARCHAR2)
IS
  l_party_search_rec   hz_party_search.party_search_rec_type;
  l_search_ctx_id      NUMBER;
  l_num_matches        NUMBER;
  l_party_site_list    hz_party_search.party_site_list;
  l_contact_list       hz_party_search.contact_list;
  l_contact_point_list hz_party_search.contact_point_list;
  l_party_name         l_party_search_rec.party_all_names%TYPE  := p_party_name;
  l_restrict_sql       VARCHAR2(20) := NULL;
  l_match_type         VARCHAR2(20) := NULL;
  l_search_merged      VARCHAR2(20) := NULL;
  l_rule_id            NUMBER;
  l_step               VARCHAR2(100);
  l_method             VARCHAR2(100);

BEGIN

  l_method        := 'search_duplicate_parties';
  l_step          := 'Before Calling hz_party_search.search_duplicate_parties';
  x_return_status := fnd_api.g_ret_sts_error;
  x_msg_count     := 0;
  x_msg_data      := NULL;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,
                   g_module || '.' || l_method,
                   l_step);
  END IF;

  /* Get Match Rule Id from Profile Option */

  l_rule_id := fnd_profile.value('HZ_DL_IDENTIFY_DUP_RULE');

  l_party_search_rec.party_all_names   := l_party_name;
  l_party_search_rec.organization_type := 'ORGANIZATION';
  l_party_search_rec.party_number      := p_party_number;
  l_party_search_rec.sic_code          := p_sic_code;
  l_party_search_rec.status            := p_status;

  l_party_site_list(1).address1 := p_address;
  l_party_site_list(1).city := p_city;
  l_party_site_list(1).state := p_state;
  l_party_site_list(1).country := p_country;

  hz_party_search.find_parties(p_init_msg_list,
                               l_rule_id,
                               l_party_search_rec,
                               l_party_site_list,
                               l_contact_list,
                               l_contact_point_list,
                               l_restrict_sql,
                               l_search_merged,
                               l_search_ctx_id,
                               l_num_matches,
                               x_return_status,
                               x_msg_count,
                               x_msg_data);

  l_step := 'After Calling hz_party_search.search_duplicate_parties';

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_error,
                     g_module || '.' || l_method,
                     'Error in hz_party_search.search_duplicate_parties ' ||
                     x_msg_data);
    END IF;
    RETURN;
  ELSIF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_search_ctx_id := l_search_ctx_id;
  END IF;

  RETURN;

END search_duplicate_parties;

PROCEDURE enable_party_as_supplier(p_party_id       IN NUMBER,
                                   p_vendor_num     IN VARCHAR2,
                                   x_vendor_id      OUT NOCOPY NUMBER,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2)
IS
  l_msg_count                      NUMBER;
  l_msg_data                       VARCHAR2(100);
  l_step                           VARCHAR2(100);
  l_method                         VARCHAR2(100);


  l_vendor_rec                     ap_vendor_pub_pkg.r_vendor_rec_type;
  l_vendor_id                      NUMBER;
  l_party_id                       NUMBER         := p_party_id;
  l_vendor_num                     l_vendor_rec.segment1%TYPE := p_vendor_num;

  l_vendor_name                    l_vendor_rec.vendor_name%TYPE;
  l_taxpayer_id                    l_vendor_rec.jgzz_fiscal_code%TYPE;
  l_taxreg_num                     l_vendor_rec.tax_reference%TYPE;

BEGIN

  l_method := 'enable_party_as_supplier';
  l_step := 'Before Calling pos_vendor_pub_pkg.create_vendor';
  x_return_status := fnd_api.g_ret_sts_error;
  x_msg_count := 0;
  x_msg_data := NULL;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement,
                   g_module || '.' || l_method,
                   l_step);
  END IF;

  /* Get other data from hz_parties */
  SELECT party_name, jgzz_fiscal_code, tax_reference
  INTO   l_vendor_name, l_taxpayer_id, l_taxreg_num
  FROM hz_parties
  WHERE party_id = l_party_id;

  l_vendor_rec.party_id          := l_party_id;
  l_vendor_rec.segment1          := l_vendor_num;
  l_vendor_rec.vendor_name       := l_vendor_name;
  l_vendor_rec.jgzz_fiscal_code  := l_taxpayer_id;
  l_vendor_rec.tax_reference     := l_taxreg_num;
  l_vendor_rec.start_date_active := Sysdate;

  l_step := 'call pos_vendor_pub_pkg.create_vendor';

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string
      (fnd_log.level_statement
       , g_module || '.' || l_method
       , l_step);
  END IF;

  pos_vendor_pub_pkg.create_vendor(
                l_vendor_rec,
                x_return_status,
                x_msg_count,
                x_msg_data,
                l_vendor_id,
                l_party_id);

   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
        (fnd_log.level_statement
         , g_module || '.' || l_method
         , 'create_vendor call result: x_return_status ' || x_return_status
         || ' x_msg_count ' || x_msg_count
         || ' x_msg_data ' || x_msg_data
         );
   END IF;
    l_step := 'After Calling pos_vendor_pub_pkg.create_vendor';

  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_error,
                     g_module || '.' || l_method,
                     'Error in pos_vendor_pub_pkg.create_vendor' ||
                     x_msg_data);
    END IF;
    RETURN;
  ELSIF (x_return_status = fnd_api.g_ret_sts_success) THEN
    x_vendor_id := l_vendor_id;
  END IF;

  RETURN;
END enable_party_as_supplier;

PROCEDURE assign_party_usage( p_contact_party_id  IN NUMBER,
                              x_return_status     OUT nocopy VARCHAR2,
                              x_msg_count     	  OUT nocopy NUMBER,
                              x_msg_data      	  OUT nocopy VARCHAR2
                             )
IS
  l_party_usg_rec   HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
  l_party_usg_validation_level NUMBER;
  l_step                       VARCHAR2(100);
  l_method                     VARCHAR2(100);
BEGIN
  l_method := 'assign_party_usage';
  l_step := 'Before Calling HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage';
  x_return_status := fnd_api.g_ret_sts_error;
  x_msg_count := 0;
  x_msg_data := NULL;

  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string
      (fnd_log.level_statement
       , g_module || '.' || l_method
       , l_step);
  END IF;

  l_party_usg_validation_level := HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE;
  l_party_usg_rec.party_id := p_contact_party_id;
  l_party_usg_rec.party_usage_code := 'SUPPLIER_CONTACT';
  l_party_usg_rec.created_by_module := 'POS_SUPPLIER_MGMT';

  HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
  p_validation_level          => l_party_usg_validation_level,
  p_party_usg_assignment_rec  => l_party_usg_rec,
  x_return_status             => x_return_status,
  x_msg_count                 => x_msg_count,
  x_msg_data                  => x_msg_data);

  l_step := 'After Calling HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage';
  IF (x_return_status = fnd_api.g_ret_sts_error) THEN
    IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_error,
                     g_module || '.' || l_method,
                   'Error in HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage' ||
                     x_msg_data);
    END IF;
    RETURN;
  END IF;

RETURN;

EXCEPTION
   WHEN OTHERS THEN
     x_return_status :='E';
     IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string(fnd_log.level_statement, g_module || '.' || 'Error while assigning usage ' , x_msg_data);
     END IF;

END assign_party_usage;


END POS_SEARCH_DUP_PARTY_PKG;

/
