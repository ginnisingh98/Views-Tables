--------------------------------------------------------
--  DDL for Package Body AR_CMGT_HZ_COVER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_HZ_COVER_API" AS
/* $Header: ARCMHZCB.pls 120.5.12010000.2 2009/06/11 14:28:18 mraymond ship $  */

pg_wf_debug VARCHAR2(1) := ar_cmgt_util.get_wf_debug_flag;

PROCEDURE debug (
        p_message_name          IN      VARCHAR2 ) IS
BEGIN
    ar_cmgt_util.wf_debug ('AR_CMGT_HZ_COVER_API',p_message_name );
END;

--This is a local procedure used for debugging purpose and will be removed
--when the code is ready to be source controlled.
PROCEDURE dump_api_output_data(p_return_status   VARCHAR2,
                            p_msg_count       NUMBER,
                            p_msg_data        VARCHAR2) IS
l_count NUMBER;
l_msg_data  VARCHAR2(2000);
l_return_status  VArCHAR2(1);
l_msg_count  NUMBER;
BEGIN
l_return_status := p_return_status;
l_msg_count := p_msg_count;
l_msg_data  := p_msg_data;



             IF nvl(l_msg_count,0)  > 1 Then
                 LOOP

                  IF nvl(l_count,0) < l_msg_count THEN

                   l_count := nvl(l_count,0) +1 ;
                   l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
                   debug(l_msg_data);
                  ELSE
                   EXIT;
                  END IF;

                 END LOOP;
             ELSE
                debug(l_msg_data);
             END IF;

END dump_api_output_data;

/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

/*=======================================================================+
 |  Declare PUBLIC Exceptions
 +=======================================================================*/


/*========================================================================
 | PUBLIC PROCEDURE
 |      update_organization()
 | DESCRIPTION
 |
 | PSEUDO CODE/LOGIC
 |
 | PARAMETERS
 |      p_resource_id    IN      resource_id
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 |
 *=======================================================================*/
PROCEDURE update_organization(p_party_id           NUMBER,  --15
                              p_year_established   NUMBER,
                              p_employees_total    NUMBER,
                              p_url                VARCHAR2,
                              p_sic_code_type      VARCHAR2,
                              p_sic_code           VARCHAR2,
                              p_tax_reference      VARCHAR2, --50
                              p_duns_number_c      VARCHAR2
                             )
IS
l_party_rec                HZ_PARTY_V2PUB.party_rec_type;
l_organization_rec   HZ_PARTY_V2PUB.organization_rec_type;
l_party_object_version_number NUMBER;
l_profile_id     NUMBER;
l_return_status  VARCHAR2(1);
l_msg_count        NUMBER;
l_msg_data       VARCHAR2(2000);
l_count          NUMBER;
BEGIN

    --Initialize the party record structure
    l_party_rec.party_id               := p_party_id;
/*
    l_party_rec.party_number           := FND_API.G_MISS_CHAR;
    l_party_rec.validated_flag         := FND_API.G_MISS_CHAR;
    l_party_rec.orig_system_reference  := FND_API.G_MISS_CHAR;
    l_party_rec.status                 := FND_API.G_MISS_CHAR;
    l_party_rec.category_code          := FND_API.G_MISS_CHAR;
    l_party_rec.salutation             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute_category     := FND_API.G_MISS_CHAR;
    l_party_rec.attribute1             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute2             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute3             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute4             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute5             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute6             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute7             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute8             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute9             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute1             := FND_API.G_MISS_CHAR;
    l_party_rec.attribute11            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute12            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute13            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute14            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute15            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute16            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute17            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute18            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute19            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute20            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute21            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute22            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute23            := FND_API.G_MISS_CHAR;
    l_party_rec.attribute24            := FND_API.G_MISS_CHAR;
*/

    --Initialize the organization record structure
--    l_organization_rec.organization_name := FND_API.G_MISS_CHAR;
    l_organization_rec.duns_number_c     := p_duns_number_c;
/*
    l_organization_rec.enquiry_duns      := FND_API.G_MISS_CHAR;
    l_organization_rec.ceo_name          := FND_API.G_MISS_CHAR;
    l_organization_rec.ceo_title         := FND_API.G_MISS_CHAR;
    l_organization_rec.principal_name    := FND_API.G_MISS_CHAR;
    l_organization_rec.principal_title   := FND_API.G_MISS_CHAR;
    l_organization_rec.legal_status      := FND_API.G_MISS_CHAR;
    l_organization_rec.control_yr        := FND_API.G_MISS_NUM;
*/
    l_organization_rec.employees_total   := p_employees_total;
/*
    l_organization_rec.hq_branch_ind     := FND_API.G_MISS_CHAR;
    l_organization_rec.branch_flag       := FND_API.G_MISS_CHAR;
    l_organization_rec.oob_ind           := FND_API.G_MISS_CHAR;
    l_organization_rec.line_of_business  := FND_API.G_MISS_CHAR;
    l_organization_rec.cong_dist_code    := FND_API.G_MISS_CHAR;
*/
    l_organization_rec.sic_code          := p_sic_code;
/*
    l_organization_rec.import_ind        := FND_API.G_MISS_CHAR;
    l_organization_rec.export_ind        := FND_API.G_MISS_CHAR;
    l_organization_rec.labor_surplus_ind   := FND_API.G_MISS_CHAR;
    l_organization_rec.debarment_ind       := FND_API.G_MISS_CHAR;
    l_organization_rec.minority_owned_ind  := FND_API.G_MISS_CHAR;
    l_organization_rec.minority_owned_type := FND_API.G_MISS_CHAR;
    l_organization_rec.woman_owned_ind     := FND_API.G_MISS_CHAR;
    l_organization_rec.disadv_8a_ind       := FND_API.G_MISS_CHAR;
    l_organization_rec.small_bus_ind       := FND_API.G_MISS_CHAR;
    l_organization_rec.rent_own_ind        := FND_API.G_MISS_CHAR;
    l_organization_rec.debarments_count    := FND_API.G_MISS_NUM;
    l_organization_rec.debarments_date     := FND_API.G_MISS_DATE;
    l_organization_rec.failure_score                   := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_natnl_percentile  := FND_API.G_MISS_NUM;
    l_organization_rec.failure_score_override_code     := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary        := FND_API.G_MISS_CHAR;
    l_organization_rec.global_failure_score            := FND_API.G_MISS_CHAR;
    l_organization_rec.db_rating                       := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score                    := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary         := FND_API.G_MISS_CHAR;
    l_organization_rec.paydex_score                    := FND_API.G_MISS_CHAR;
    l_organization_rec.paydex_three_months_ago         := FND_API.G_MISS_CHAR;
    l_organization_rec.paydex_norm                     := FND_API.G_MISS_CHAR;
    l_organization_rec.best_time_contact_begin         := FND_API.G_MISS_DATE;
    l_organization_rec.best_time_contact_end           := FND_API.G_MISS_DATE;
    l_organization_rec.organization_name_phonetic      := FND_API.G_MISS_CHAR;
*/
    l_organization_rec.tax_reference                   := p_tax_reference;
/*
    l_organization_rec.gsa_indicator_flag              := FND_API.G_MISS_CHAR;
    l_organization_rec.jgzz_fiscal_code                := FND_API.G_MISS_CHAR;
    l_organization_rec.analysis_fy                     := FND_API.G_MISS_CHAR;
    l_organization_rec.fiscal_yearend_month            := FND_API.G_MISS_CHAR;
    l_organization_rec.curr_fy_potential_revenue       := FND_API.G_MISS_NUM;
    l_organization_rec.next_fy_potential_revenue       := FND_API.G_MISS_NUM;
*/
    l_organization_rec.year_established                := p_year_established;
/*
    l_organization_rec.mission_statement               := FND_API.G_MISS_CHAR;
    l_organization_rec.organization_type               := FND_API.G_MISS_CHAR;
    l_organization_rec.business_scope                  := FND_API.G_MISS_CHAR;
    l_organization_rec.corporation_class               := FND_API.G_MISS_CHAR;
    l_organization_rec.known_as                        := FND_API.G_MISS_CHAR;
    l_organization_rec.known_as2                       := FND_API.G_MISS_CHAR;
    l_organization_rec.known_as3                       := FND_API.G_MISS_CHAR;
    l_organization_rec.known_as4                       := FND_API.G_MISS_CHAR;
    l_organization_rec.known_as5                       := FND_API.G_MISS_CHAR;
    l_organization_rec.local_bus_iden_type             := FND_API.G_MISS_CHAR;
    l_organization_rec.local_bus_identifier            := FND_API.G_MISS_CHAR;
    l_organization_rec.pref_functional_currency        := FND_API.G_MISS_CHAR;
    l_organization_rec.registration_type               := FND_API.G_MISS_CHAR;
    l_organization_rec.total_employees_text            := FND_API.G_MISS_CHAR;
    l_organization_rec.total_employees_ind             := FND_API.G_MISS_CHAR;
    l_organization_rec.total_emp_est_ind               := FND_API.G_MISS_CHAR;
    l_organization_rec.total_emp_min_ind               := FND_API.G_MISS_CHAR;
    l_organization_rec.parent_sub_ind                  := FND_API.G_MISS_CHAR;
    l_organization_rec.incorp_year                     := FND_API.G_MISS_NUM;
*/
    l_organization_rec.sic_code_type                   := p_sic_code_type;
/*
    l_organization_rec.public_private_ownership_flag   := FND_API.G_MISS_CHAR;
    l_organization_rec.internal_flag                   := FND_API.G_MISS_CHAR;
    l_organization_rec.local_activity_code_type        := FND_API.G_MISS_CHAR;
    l_organization_rec.local_activity_code             := FND_API.G_MISS_CHAR;
    l_organization_rec.emp_at_primary_adr              := FND_API.G_MISS_CHAR;
    l_organization_rec.emp_at_primary_adr_text         := FND_API.G_MISS_CHAR;
    l_organization_rec.emp_at_primary_adr_est_ind      := FND_API.G_MISS_CHAR;
    l_organization_rec.emp_at_primary_adr_min_ind      := FND_API.G_MISS_CHAR;
    l_organization_rec.high_credit                     := FND_API.G_MISS_NUM;
    l_organization_rec.avg_high_credit                 := FND_API.G_MISS_NUM;
    l_organization_rec.total_payments                  := FND_API.G_MISS_NUM;
    l_organization_rec.credit_score_class              := FND_API.G_MISS_NUM;
    l_organization_rec.credit_score_natl_percentile    := FND_API.G_MISS_NUM;
    l_organization_rec.credit_score_incd_default       := FND_API.G_MISS_NUM;
    l_organization_rec.credit_score_age                := FND_API.G_MISS_NUM;
    l_organization_rec.credit_score_date               := FND_API.G_MISS_DATE;
    l_organization_rec.credit_score_commentary2        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary3        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary4        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary5        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary6        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary7        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary8        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary9        := FND_API.G_MISS_CHAR;
    l_organization_rec.credit_score_commentary10       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_class             := FND_API.G_MISS_NUM;
    l_organization_rec.failure_score_incd_default      := FND_API.G_MISS_NUM;
    l_organization_rec.failure_score_age               := FND_API.G_MISS_NUM;
    l_organization_rec.failure_score_date              := FND_API.G_MISS_DATE;
    l_organization_rec.failure_score_commentary2       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary3       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary4       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary5       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary6       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary7       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary8       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary9       := FND_API.G_MISS_CHAR;
    l_organization_rec.failure_score_commentary10      := FND_API.G_MISS_CHAR;
    l_organization_rec.maximum_credit_recommendation   := FND_API.G_MISS_NUM;
    l_organization_rec.maximum_credit_currency_code    := FND_API.G_MISS_CHAR;
    l_organization_rec.displayed_duns_party_id         := FND_API.G_MISS_NUM;
    l_organization_rec.content_source_type             := FND_API.G_MISS_CHAR;
    l_organization_rec.content_source_number           := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute_category              := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute1                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute2                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute3                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute4                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute5                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute6                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute7                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute8                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute9                      := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute10                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute11                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute12                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute13                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute14                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute15                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute16                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute17                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute18                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute19                     := FND_API.G_MISS_CHAR;
    l_organization_rec.attribute20                     := FND_API.G_MISS_CHAR;
    l_organization_rec.created_by_module               := FND_API.G_MISS_CHAR;
    l_organization_rec.application_id                  := FND_API.G_MISS_NUM;
    l_organization_rec.do_not_confuse_with             := FND_API.G_MISS_CHAR;
    l_organization_rec.actual_content_source           := FND_API.G_MISS_CHAR;
*/
    l_organization_rec.party_rec                       := l_party_rec;

    hz_party_v2pub.update_organization(
                 p_organization_rec => l_organization_rec,
                 p_party_object_version_number => l_party_object_version_number,
                 x_profile_id => l_profile_id,
                 x_return_status => l_return_status,
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data);

         dump_api_output_data( l_return_status,
                               l_msg_count,
                               l_msg_data);
END update_organization;

PROCEDURE create_party_profile(p_party_id  IN              NUMBER,
                               p_return_status OUT NOCOPY  VARCHAR2)
IS
 l_profile_rec       HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
 l_cust_profile_id   NUMBER;
 l_return_status     VARCHAR2(1);
 l_msg_count         NUMBER;
 l_msg_data          VARCHAR2(2000);
 /* 7233461 - fetch cust_acct level first, and only consider
      active sites/profiles */
 CURSOR find_profile_class(p_party_id IN NUMBER)
 IS
   select cp.profile_class_id
   from	 hz_cust_accounts ca,
  	 hz_customer_profiles cp
   where ca.party_id = p_party_id
   and	 ca.cust_account_id = cp.cust_account_id
   and	 ca.status = 'A'
   and	 cp.status = 'A'
   order by cp.site_use_id desc;


 l_profile_class_id  NUMBER;
BEGIN
    IF pg_wf_debug = 'Y'
    THEN
       debug('ar_cmgt_hz_cover_api.create_party_profile()+');
       debug('   p_party_id = ' || p_party_id);
    END IF;

  /* Check if an account exists for the given party and if that
     particular account has a profile record.
   */
  OPEN find_profile_class(p_party_id);

  FETCH find_profile_class INTO l_profile_class_id;

  CLOSE find_profile_class;


 /*If we have not been able to derive the profile class from the accounts beneath
   the party then we will create the party profile record with the 'DEFAULT'
   profile class.
 */
  IF l_profile_class_id IS NULL THEN
     l_profile_class_id := 0; --0 is the DEFAULT profile class id
     IF pg_wf_debug = 'Y'
     THEN
       debug('   no cust_profile records found.  profile_class_id set to zero');
     END IF;
  END IF;

  l_profile_rec.party_id          := p_party_id;
  l_profile_rec.profile_class_id  := l_profile_class_id;
  l_profile_rec.created_by_module := 'OCM';
  l_profile_rec.application_id    := 222;
  l_profile_rec.credit_checking   := 'Y';
  HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile (
                            p_init_msg_list           => FND_API.G_FALSE,
                            p_customer_profile_rec    => l_profile_rec,
                            p_create_profile_amt      => FND_API.G_TRUE,
                            x_cust_account_profile_id => l_cust_profile_id,
                            x_return_status           => l_return_status,
                            x_msg_count               => l_msg_count,
                            x_msg_data                => l_msg_data );

  /* 7272415 - Raise WF error here if API fails */
  p_return_status := l_return_status;
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
     IF pg_wf_debug = 'Y'
     THEN
        debug('Error in HZ_CUSTOMER_PROFILE_V2PUB.create_customer_profile');
        dump_api_output_data(l_return_status,
                             l_msg_count,
                             l_msg_data);
     END IF;
  END IF;

    IF pg_wf_debug = 'Y'
    THEN
       debug('   assigned profile_id = ' || l_cust_profile_id);
       debug('   assigned profile_class_id = ' || l_profile_class_id);
       debug('ar_cmgt_hz_cover_api.create_party_profile()-');
    END IF;
END create_party_profile;

END AR_CMGT_HZ_COVER_API;

/
