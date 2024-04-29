--------------------------------------------------------
--  DDL for Package Body POS_SUPP_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPP_CONTACT_PKG" AS
/*$Header: POSCONTB.pls 120.22.12010000.10 2013/05/10 09:22:29 ppotnuru ship $ */

g_module CONSTANT VARCHAR2(30) := 'POS_SUPP_CONTACT_PKG';
/*Added one argument p_department for BUG 7938942 */
PROCEDURE create_org_contact_private
  (p_vendor_party_id  IN  NUMBER,
   p_person_party_id  IN  NUMBER,
   p_job_title        IN  VARCHAR2,
   p_inactive_date    IN  DATE DEFAULT NULL,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   x_rel_party_id     OUT nocopy NUMBER,
   p_department       IN  VARCHAR2 DEFAULT NULL
   )
   IS
      l_rel_rec             hz_relationship_v2pub.relationship_rec_type;
      l_rel_party_rec       hz_party_v2pub.party_rec_type;
      l_rel_party_number    hz_parties.party_number%TYPE;
      l_rel_id              NUMBER;
      l_rel_party_id        NUMBER;
      l_org_contact_rec     hz_party_contact_v2pub.org_contact_rec_type;
      l_org_contact_id      NUMBER;
      l_method              VARCHAR2(30);
      l_step                VARCHAR2(100);
BEGIN
   l_method := 'create_org_contact_private';

   l_rel_rec       := NULL;
   l_rel_party_rec := NULL;

   l_rel_rec.object_id         := p_vendor_party_id;
   l_rel_rec.object_type       := 'ORGANIZATION';
   l_rel_rec.object_table_name := 'HZ_PARTIES';
   l_rel_rec.subject_id          := p_person_party_id;
   l_rel_rec.subject_type        := 'PERSON';
   l_rel_rec.subject_table_name  := 'HZ_PARTIES';
   l_rel_rec.relationship_code  := 'CONTACT_OF';
   l_rel_rec.relationship_type  := 'CONTACT';
   l_rel_rec.start_date         := Sysdate;
   l_rel_rec.end_date           := p_inactive_date;
   l_rel_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
   l_rel_rec.application_id     := 177;
   l_rel_rec.party_rec          := l_rel_party_rec;
   l_rel_rec.status             := 'A';

   l_org_contact_rec.created_by_module := 'POS_SUPPLIER_MGMT';
   l_org_contact_rec.application_id    := 177;
   l_org_contact_rec.job_title         := p_job_title;
   l_org_contact_rec.department        := p_department;
   l_org_contact_rec.party_rel_rec     := l_rel_rec;

   l_step := 'call hz_party_contact_v2pub.create_org_contact';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	( fnd_log.level_statement
	  , g_module || '.' || l_method
	  , l_step
	  || ' with subject_id ' || l_rel_rec.subject_id
	  || ' object_id ' || l_rel_rec.object_id
	  || ' job_title ' || l_org_contact_rec.job_title
	  );
   END IF;

   hz_party_contact_v2pub.create_org_contact
     (p_init_msg_list      => fnd_api.g_false,
      p_org_contact_rec    => l_org_contact_rec,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data,
      x_org_contact_id     => l_org_contact_id,
      x_party_rel_id       => l_rel_id,
      x_party_id           => l_rel_party_id,
      x_party_number       => l_rel_party_number
      );

   pos_log.log_call_result
     (p_module        => 'POSCONTB',
      p_prefix        => 'call hz_party_v2pub.create_person',
      p_return_status => x_return_status,
      p_msg_count     => x_msg_count,
      p_msg_data      => x_msg_data
      );

   IF x_return_status = fnd_api.g_ret_sts_success THEN
      x_rel_party_id := l_rel_party_id;
   END IF;

END create_org_contact_private;
/*Added one argument p_department for BUG 7938942
  Added four args for bug 9316284 - Alt Contact Name, Alt. Phone Area Code, Alt. Phone number, URL*/
PROCEDURE create_supplier_contact
  (p_vendor_party_id  IN  NUMBER,
   p_first_name       IN  VARCHAR2,
   p_last_name        IN  VARCHAR2,
   p_middle_name      IN  VARCHAR2 DEFAULT NULL,
   p_contact_title    IN  VARCHAR2 DEFAULT NULL,
   p_job_title        IN  VARCHAR2 DEFAULT NULL,
   p_phone_area_code  IN  VARCHAR2 DEFAULT NULL,
   p_phone_number     IN  VARCHAR2 DEFAULT NULL,
   p_phone_extension  IN  VARCHAR2 DEFAULT NULL,
   p_fax_area_code    IN  VARCHAR2 DEFAULT NULL,
   p_fax_number       IN  VARCHAR2 DEFAULT NULL,
   p_email_address    IN  VARCHAR2 DEFAULT NULL,
   p_inactive_date    IN  DATE DEFAULT NULL,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   x_person_party_id  OUT nocopy NUMBER,
   p_department       IN  VARCHAR2 DEFAULT NULL,
   p_alt_contact_name IN VARCHAR2 DEFAULT NULL,
   p_alt_area_code    IN VARCHAR2 DEFAULT NULL,
   p_alt_phone_number IN VARCHAR2 DEFAULT NULL,
   p_url              IN VARCHAR2 DEFAULT NULL
   )
  IS
     l_person_party_rec    hz_party_v2pub.party_rec_type;
     l_person_party_number hz_parties.party_number%TYPE;
     l_person_rec          hz_party_v2pub.person_rec_type;
     l_person_profile_id   NUMBER;
     l_method              VARCHAR2(30);
     l_step                VARCHAR2(100);
     l_rel_party_id        NUMBER;

/* Added for bug 7366321 */
   l_hzprofile_value   varchar2(20);
   l_hzprofile_changed varchar2(1) := 'N';
/* End */


BEGIN
   SAVEPOINT create_supplier_contact_sp;

   l_method := 'create_supplier_contact';

/* Added for bug 7366321 */
    l_hzprofile_value := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
    if nvl(l_hzprofile_value, 'Y') = 'N' then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
      l_hzprofile_changed := 'Y';
    end if;
/* End */

/*  commented for bug 7366321
   fnd_profile.put('HZ_GENERATE_PARTY_NUMBER','Y');
*/

   -- create contact party
   l_person_party_rec := NULL;
   l_person_rec       := NULL;

   l_person_rec.person_first_name  := p_first_name;
   l_person_rec.person_middle_name := p_middle_name;
   l_person_rec.person_last_name   := p_last_name;
   l_person_rec.person_title       := p_job_title;
   l_person_rec.created_by_module  := 'POS_SUPPLIER_MGMT';
   l_person_rec.application_id     := 177;
   l_person_rec.party_rec          := l_person_party_rec;
   l_person_rec.person_pre_name_adjunct := p_contact_title;
   l_person_rec.known_as           := p_alt_contact_name;

   l_step := 'create contact party';

   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	( fnd_log.level_statement
	  , g_module || '.' || l_method
	  , l_step
	  || ' with person_first_name ' || l_person_rec.person_first_name
	  || ' person_middle_name ' || l_person_rec.person_middle_name
	  || ' person_last_name ' || l_person_rec.person_last_name
	  || ' person_title ' || l_person_rec.person_title
	  || ' person_pre_name_adjunct ' || l_person_rec.person_pre_name_adjunct
	  );
   END IF;

   hz_party_v2pub.create_person
     (p_init_msg_list  => fnd_api.g_false,
      p_person_rec     => l_person_rec,
      p_party_usage_code => 'SUPPLIER_CONTACT',
      x_return_status  => x_return_status,
      x_msg_count      => x_msg_count,
      x_msg_data       => x_msg_data,
      x_party_id       => x_person_party_id,
      x_party_number   => l_person_party_number,
      x_profile_id     => l_person_profile_id
      );

/* Added for bug 7366321 */
    if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
     end if;
/* End */

   pos_log.log_call_result
     (p_module        => 'POSCONTB',
      p_prefix        => 'call hz_party_v2pub.create_person',
      p_return_status => x_return_status,
      p_msg_count     => x_msg_count,
      p_msg_data      => x_msg_data
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
    /* Added for bug 7366321 */
     if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
     end if;
    /* End */

      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;
/*Passing one more argument department */
   create_org_contact_private
     (p_vendor_party_id  => p_vendor_party_id,
      p_person_party_id  => x_person_party_id,
      p_job_title        => p_job_title,
      p_inactive_date    => p_inactive_date,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      x_rel_party_id     => l_rel_party_id,
      p_department       => p_department
      );

   IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;

   l_step := 'store phone for supplier contact';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	(fnd_log.level_statement
	 , g_module || '.' || l_method
	 , l_step
	 );
   END IF;

   pos_hz_contact_point_pkg.update_party_phone
     (
      p_party_id          => l_rel_party_id,
      p_country_code      => NULL,
      p_area_code         => p_phone_area_code ,
      p_number            => p_phone_number,
      p_extension         => p_phone_extension,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;

   l_step := 'store fax for supplier contact';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	(fnd_log.level_statement
	 , g_module || '.' || l_method
	 , l_step
	 );
   END IF;

   pos_hz_contact_point_pkg.update_party_fax
     (
      p_party_id          => l_rel_party_id,
      p_country_code      =>  NULL,
      p_area_code         => p_fax_area_code ,
      p_number            => p_fax_number,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;

   l_step := 'store email for supplier contact';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	(fnd_log.level_statement
	 , g_module || '.' || l_method
	 , l_step
	 );
   END IF;

   pos_hz_contact_point_pkg.update_party_email
     (
      p_party_id          => l_rel_party_id,
      p_email             => p_email_address,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;

   l_step := 'store alt phone for supplier contact';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	(fnd_log.level_statement
	 , g_module || '.' || l_method
	 , l_step
	 );
   END IF;

   pos_hz_contact_point_pkg.update_party_alt_phone
     (
      p_party_id          => l_rel_party_id,
      p_country_code      => NULL,
      p_area_code         => p_alt_area_code,
      p_number            => p_alt_phone_number,
      p_extension         => NULL,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;

   l_step := 'store URL for supplier contact';
   IF  (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
	(fnd_log.level_statement
	 , g_module || '.' || l_method
	 , l_step
	 );
   END IF;

   pos_hz_contact_point_pkg.update_party_url
     (
      p_party_id          => l_rel_party_id,
      p_url               => p_url,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
    );

   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO create_supplier_contact_sp;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
  /* Added for bug 7366321 */
      if nvl(l_hzprofile_changed,'N') = 'Y' then
       fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', l_hzprofile_value);
       l_hzprofile_changed := 'N';
      end if;
    /* End */
      ROLLBACK TO create_supplier_contact_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;
      pos_log.log_sqlerrm('POSCONTB', 'in create_supplier_contact');

END create_supplier_contact;

/**
 Name : update_supplier_contact
 Description : This procedure is used to update the contact details
               like name,email,phone number,fax etc.
 Parameters  :

    IN :
       p_contact_party_id - holds party id of the 'PERSON' party record in hz_parties.
       p_vendor_party_id  - holds party id of the 'ORGANIZATION' party record in hz_parties.
       p_first_name       - first name of the contact
       p_last_name        - last name of the contact
       p_middle_name      - middle name of the contact
       p_contact_title    - contact title of the contact
       p_job_title        - job title of the contact
       p_phone_number     - phone number of the contact
       p_fax_number       - fax number of the contact
       p_email_address    - email address of the contact
       p_inactive_date    - inactive date of the contact
       p_party_object_version_number - object version number of the relationship record in hz_parties
       p_email_object_version_number - object version number of the email contact in hz_contact_points
       p_phone_object_version_number - object version number of the phone contact in hz_contact_points
       p_fax_object_version_number   - object version number of the fax contact in hz_contact_points
       p_rel_object_version_number   - object version number of the relationship record in hz_relationships
       p_cont_object_version_number  - object version number of the hz_org_contacts record
       p_person_party_obversion_num  - object version number of the 'PERSON' party record in hz_parties

    OUT :
      x_return_status - returns either success/failure
      x_msg_count     - returns the number of error messages
      x_msg_data      - returns error messages
**/
/*Added one argument p_department for BUG 7938942 */
PROCEDURE update_supplier_contact
  (p_contact_party_id IN  NUMBER,
   p_vendor_party_id  IN  NUMBER,
   p_first_name       IN  VARCHAR2 DEFAULT NULL,
   p_last_name        IN  VARCHAR2 DEFAULT NULL,
   p_middle_name      IN  VARCHAR2 DEFAULT NULL,
   p_contact_title    IN  VARCHAR2 DEFAULT NULL,
   p_job_title        IN  VARCHAR2 DEFAULT NULL,
   p_phone_area_code  IN  VARCHAR2 DEFAULT NULL,
   p_phone_number     IN  VARCHAR2 DEFAULT NULL,
   p_phone_extension  IN  VARCHAR2 DEFAULT NULL,
   p_fax_area_code    IN  VARCHAR2 DEFAULT NULL,
   p_fax_number       IN  VARCHAR2 DEFAULT NULL,
   p_email_address    IN  VARCHAR2 DEFAULT NULL,
   p_inactive_date    IN  DATE DEFAULT NULL,
--Start Bug 6620664 - Handling Concurrent Updates on ContactDirectory, BusinessClassifications ans Accounting pages
   p_party_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_email_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_phone_object_version_number  IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_fax_object_version_number    IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_rel_object_version_number    IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_cont_object_version_number   IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
--End Bug 6620664 - Handling Concurrent Updates on ContactDirectory, BusinessClassifications ans Accounting pages
   p_person_party_obversion_num   IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   x_return_status    OUT nocopy VARCHAR2,
   x_msg_count        OUT nocopy NUMBER,
   x_msg_data         OUT nocopy VARCHAR2,
   p_department       IN  VARCHAR2 DEFAULT NULL,
   p_alt_contact_name IN VARCHAR2 DEFAULT NULL,
   p_alt_area_code    IN VARCHAR2 DEFAULT NULL,
   p_alt_phone_number IN VARCHAR2 DEFAULT NULL,
   p_url              IN VARCHAR2 DEFAULT NULL,
   p_url_object_version_number IN NUMBER DEFAULT fnd_api.G_NULL_NUM,
   p_altphone_obj_version_num  IN NUMBER DEFAULT fnd_api.G_NULL_NUM
   )
  IS
     CURSOR l_contact_party_cur IS
	SELECT person_first_name,
	       person_last_name,
	       person_middle_name,
	       person_pre_name_adjunct,
	       person_title,
	       object_version_number,
		   known_as
	  FROM hz_parties
         WHERE party_id = p_contact_party_id;

     l_contact_party_rec  l_contact_party_cur%ROWTYPE;
     l_person_rec         hz_party_v2pub.person_rec_type;
     l_party_rec          hz_party_v2pub.party_rec_type;
     l_profile_id         NUMBER;
 /*For BUG 7938942 as part of l_cur2 adding department field also*/
     CURSOR l_cur2 IS
	SELECT hoc.org_contact_id,
	       hoc.job_title,
                                 hoc.department,
	       hoc.object_version_number cont_object_version_number,
	       hzr.object_version_number rel_object_version_number,
	       hzr.party_id,
	       hzr.relationship_id,
	       hp.object_version_number rel_party_obj_ver_num
	  FROM hz_org_contacts hoc, hz_relationships hzr, hz_parties hp
	 WHERE hoc.party_relationship_id = hzr.relationship_id
	   AND hzr.object_table_name = 'HZ_PARTIES'
	   AND hzr.object_id = p_vendor_party_id
	   AND hzr.subject_table_name = 'HZ_PARTIES'
	   AND hzr.subject_id = p_contact_party_id
	   AND hzr.relationship_type = 'CONTACT'
	   AND hzr.relationship_code = 'CONTACT_OF'
           AND hzr.party_id = hp.party_id;

     l_rec2 l_cur2%ROWTYPE;

     l_org_contact_rec   hz_party_contact_v2pub.org_contact_rec_type;
     l_rel_rec           hz_relationship_v2pub.relationship_rec_type;
     l_rel_party_id      NUMBER;
     l_found_org_contact BOOLEAN;
     l_enddate_changed   BOOLEAN;

    /* Start for Bug 6620664 */
     l_party_object_version_number    NUMBER;
     l_phone_object_version_number    NUMBER;
     l_fax_object_version_number      NUMBER;
     l_email_object_version_number    NUMBER;
     l_rel_object_version_number      NUMBER;
     l_cont_object_version_number     NUMBER;
	 l_url_object_version_number      NUMBER;
     l_altphone_obj_version_num       NUMBER;
    /* End for Bug 6620664 */

     /* Bug 7027825 Start */
     l_person_party_obversion_num NUMBER;
     /* Bug 7027825 End  */


     cursor l_user_cur is
     select user_name
     from fnd_user
     WHERE person_party_id = p_contact_party_id;
     l_user_rec l_user_cur%ROWTYPE;

BEGIN
   SAVEPOINT update_supplier_contact_sp;

 /* Start for Bug 6620664 */
     l_phone_object_version_number := p_phone_object_version_number;
     l_fax_object_version_number := p_fax_object_version_number;
     l_email_object_version_number := p_email_object_version_number;
	 l_url_object_version_number := p_url_object_version_number;
     l_altphone_obj_version_num := p_altphone_obj_version_num;
/* End for Bug 6620664 */

   OPEN l_contact_party_cur;

   FETCH l_contact_party_cur INTO l_contact_party_rec;

   IF l_contact_party_cur%notfound THEN
     CLOSE l_contact_party_cur;
     x_return_status := fnd_api.g_ret_sts_error;
     x_msg_count := 1;
     x_msg_data := 'invalid contact party_id ' || p_contact_party_id;
     RETURN;
   END IF;
   /* Bug 7027825 Start */
   IF(p_person_party_obversion_num=fnd_api.G_NULL_NUM) THEN
     l_person_party_obversion_num := l_contact_party_rec.object_version_number;
   ELSE
     l_person_party_obversion_num := p_person_party_obversion_num;
   END IF ;
   /* Bug 7027825 End   */
   CLOSE l_contact_party_cur;

   OPEN l_cur2;
   FETCH l_cur2 INTO l_rec2;
   l_found_org_contact := l_cur2%found;
   CLOSE l_cur2;

   IF l_found_org_contact THEN
     -- retrieve the relation record
     HZ_RELATIONSHIP_V2PUB.get_relationship_rec (
        p_relationship_id                  => l_rec2.relationship_id,
        p_directional_flag                 => 'F',
        x_rel_rec                          => l_rel_rec,
        x_return_status                    => x_return_status,
        x_msg_count                        => x_msg_count,
        x_msg_data                         => x_msg_data
     );
     IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
       ROLLBACK TO update_supplier_contact_sp;
       RETURN;
     END IF;

     if ((l_rel_rec.end_date is null and p_inactive_date is null) or
        (l_rel_rec.end_date is not null and l_rel_rec.end_date = p_inactive_date)) then
         l_enddate_changed := false;
     else
         l_enddate_changed := true;
         l_rel_rec.end_date := p_inactive_date;
     end if;

    /* Start Bug 6620664 */
    IF(p_party_object_version_number = fnd_api.G_NULL_NUM) THEN
      l_party_object_version_number := l_rec2.rel_party_obj_ver_num;
    ELSE
      l_party_object_version_number := p_party_object_version_number;
    END IF;

    IF(p_rel_object_version_number = fnd_api.G_NULL_NUM) THEN
      l_rel_object_version_number := l_rec2.rel_object_version_number;
    ELSE
      l_rel_object_version_number := p_rel_object_version_number;
    END IF;

    IF(p_cont_object_version_number = fnd_api.G_NULL_NUM) THEN
      l_cont_object_version_number := l_rec2.cont_object_version_number;
    ELSE
      l_cont_object_version_number := p_cont_object_version_number;
    END IF;
    /* End Bug 6620664 */

    -- update org contact if needed
   /*BUG 7938942: Added code to update department field along with job title if need to update*/
   IF ((l_rec2.job_title IS NULL AND p_job_title IS NULL) OR
        (l_rec2.job_title IS NOT NULL AND l_rec2.job_title = p_job_title))
         AND ((l_rec2.department IS NULL AND p_department IS NULL) OR
                   (l_rec2.department IS NOT NULL AND l_rec2.department = p_department))

         AND (not l_enddate_changed)

         THEN
	   NULL;
   ELSE
     IF ((l_rec2.job_title IS NULL AND p_job_title IS NULL) OR
           (l_rec2.job_title IS NOT NULL AND l_rec2.job_title = p_job_title))
          THEN
            NULL;
     ELSE
      l_org_contact_rec.job_title := p_job_title;
      /* Bug 9850943 Start */
      IF p_job_title IS NULL THEN
            l_org_contact_rec.job_title:=FND_API.G_MISS_CHAR;
      END IF;
     /* Bug 9850943 End */
     END IF;
     IF ((l_rec2.department IS NULL AND p_department IS NULL) OR
           (l_rec2.department IS NOT NULL AND l_rec2.department = p_department))
       THEN
           NULL;
     ELSE
       l_org_contact_rec.department := p_department;
       /* Bug 9850943 Start */
      IF p_department IS NULL THEN
            l_org_contact_rec.department:=FND_API.G_MISS_CHAR;
      END IF;
       /* Bug 9850943 End */
     END IF;
       l_org_contact_rec.party_rel_rec := l_rel_rec;
       l_org_contact_rec.org_contact_id := l_rec2.org_contact_id;

       hz_party_contact_v2pub.update_org_contact
	 (p_init_msg_list      	  => fnd_api.g_true,
	  p_org_contact_rec    	  => l_org_contact_rec,
        --Start Bug 6620664
          p_cont_object_version_number  => l_cont_object_version_number, --l_rec2.cont_object_version_number,
          p_rel_object_version_number   => l_rel_object_version_number, --l_rec2.rel_object_version_number,
          p_party_object_version_number => l_party_object_version_number, --l_rec2.rel_party_obj_ver_num,
        --End Bug 6620664
	  x_return_status               => x_return_status,
	  x_msg_count                   => x_msg_count,
	  x_msg_data                    => x_msg_data
	  );
	IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
	   ROLLBACK TO update_supplier_contact_sp;
	   RETURN;
        END IF;
      END IF;
   ELSE
     -- create org contact record as we did not find it
     create_org_contact_private
       (p_vendor_party_id  => p_vendor_party_id,
	p_person_party_id  => p_contact_party_id,
	p_job_title        => p_job_title,
        p_inactive_date    => p_inactive_date,
	x_return_status    => x_return_status,
	x_msg_count        => x_msg_count,
	x_msg_data         => x_msg_data,
	x_rel_party_id     => l_rel_party_id,
                          p_department     => p_department
	);

      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 --ROLLBACK TO create_supplier_contact_sp;
	 ROLLBACK TO update_supplier_contact_sp;
	 RETURN;
      END IF;
    END IF;

   -- update party if needed
   IF (p_first_name IS NULL     AND l_contact_party_rec.person_first_name IS NULL OR
       p_first_name IS NOT NULL AND l_contact_party_rec.person_first_name IS NOT NULL AND
       p_first_name = l_contact_party_rec.person_first_name
       ) AND
      (p_last_name IS NULL     AND l_contact_party_rec.person_last_name IS NULL OR
       p_last_name IS NOT NULL AND l_contact_party_rec.person_last_name IS NOT NULL AND
       p_last_name = l_contact_party_rec.person_last_name
       ) AND
      (p_middle_name IS NULL     AND l_contact_party_rec.person_middle_name IS NULL OR
       p_middle_name IS NOT NULL AND l_contact_party_rec.person_middle_name IS NOT NULL AND
       p_middle_name = l_contact_party_rec.person_middle_name
       ) AND
      (p_contact_title IS NULL     AND l_contact_party_rec.person_pre_name_adjunct IS NULL OR
       p_contact_title IS NOT NULL AND l_contact_party_rec.person_pre_name_adjunct IS NOT NULL AND
       p_contact_title = l_contact_party_rec.person_pre_name_adjunct
	   ) AND
      (p_alt_contact_name IS NULL     AND l_contact_party_rec.known_as IS NULL OR
       p_alt_contact_name IS NOT NULL AND l_contact_party_rec.known_as IS NOT NULL AND
       p_alt_contact_name = l_contact_party_rec.known_as
       ) AND
      (p_job_title IS NULL     AND l_contact_party_rec.person_title IS NULL OR
       p_job_title IS NOT NULL AND l_contact_party_rec.person_title IS NOT NULL AND
       p_job_title = l_contact_party_rec.person_title
       ) THEN

      NULL; -- no change for party

    ELSE
      l_person_rec.person_first_name  	   := nvl(p_first_name, fnd_api.g_miss_char);
      l_person_rec.person_last_name   	   := p_last_name;
      l_person_rec.person_middle_name 	   := nvl(p_middle_name, fnd_api.g_miss_char);
      l_person_rec.person_pre_name_adjunct := nvl(p_contact_title, fnd_api.g_miss_char);
      l_party_rec.party_id                 := p_contact_party_id;
      l_person_rec.party_rec               := l_party_rec;
      l_person_rec.known_as                := nvl(p_alt_contact_name, fnd_api.g_miss_char);
      l_person_rec.person_title            := nvl(p_job_title,fnd_api.g_miss_char);

      /* Bug 7027825 , For Updating A Person Party Type We need to pass the object version number of the
         PERSON record ,So changed the below object version number parameter to l_person_party_obversion_num */

      hz_party_v2pub.update_person
	(p_init_msg_list  	       => fnd_api.g_true,
	 p_person_rec     	       => l_person_rec,
         p_party_object_version_number => l_person_party_obversion_num,
	 x_profile_id                  => l_profile_id,
	 x_return_status               => x_return_status,
	 x_msg_count                   => x_msg_count,
	 x_msg_data                    => x_msg_data
	 );

      IF x_return_status IS NULL OR x_return_status <> fnd_api.g_ret_sts_success THEN
	 ROLLBACK TO update_supplier_contact_sp;
	 RETURN;
      END IF;
    END IF;

    pos_hz_contact_point_pkg.update_party_phone
     (
      p_party_id          => l_rec2.party_id,
      p_country_code      => NULL,
      p_area_code         => p_phone_area_code ,
      p_number            => p_phone_number,
      p_extension         => p_phone_extension,
     --Start Bug 6620664
      p_phone_object_version_number => l_phone_object_version_number,
     --End Bug 6620664
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

   IF x_return_status IS NULL OR
      x_return_status <> fnd_api.g_ret_sts_success THEN
      --ROLLBACK TO create_supplier_contact_sp;
      ROLLBACK TO update_supplier_contact_sp;
      RETURN;
   END IF;

   pos_hz_contact_point_pkg.update_party_fax
     (
      p_party_id          => l_rec2.party_id,
      p_country_code      =>  NULL,
      p_area_code         => p_fax_area_code ,
      p_number            => p_fax_number,
      p_extension         => NULL,
     --Start Bug 6620664
      p_fax_object_version_number => l_fax_object_version_number,
     --End Bug 6620664
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

    IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
     --ROLLBACK TO create_supplier_contact_sp;
     ROLLBACK TO update_supplier_contact_sp;
     RETURN;
    END IF;

    pos_hz_contact_point_pkg.update_party_email
     (
      p_party_id          => l_rec2.party_id,
      p_email             => p_email_address,
     --Start Bug 6620664
      p_email_object_version_number => l_email_object_version_number,
     --End Bug 6620664
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

    pos_hz_contact_point_pkg.update_party_alt_phone
     (
      p_party_id          => l_rec2.party_id,
      p_country_code      => NULL,
      p_area_code         => p_alt_area_code ,
      p_number            => p_alt_phone_number,
      p_extension         => NULL,
      p_phone_object_version_number => l_altphone_obj_version_num,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

    IF x_return_status IS NULL OR
      x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_contact_sp;
      RETURN;
    END IF;

    pos_hz_contact_point_pkg.update_party_url
     (
      p_party_id          => l_rec2.party_id,
      p_url               => p_url,
	    p_url_object_version_number => l_url_object_version_number,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data
      );

    IF x_return_status IS NULL OR
      x_return_status <> fnd_api.g_ret_sts_success THEN
      ROLLBACK TO update_supplier_contact_sp;
      RETURN;
    END IF;

     for l_user_rec in l_user_cur loop

      fnd_user_pkg.updateuser
        (
         x_user_name 		  => l_user_rec.user_name,
         x_email_address              => p_email_address,
         x_owner => NULL,
         x_end_date => p_inactive_date
         );

     END LOOP;

     /* Bug 9576302 Start
        We need to update status flag of HZ_RELATIONSHIPS table for this person party to 'A' irrespective
	of whether contact is active or not as in R12 we are making use of end_date to check whether contact
	is active or not.

	We need to update the status flag in HZ_ORG_CONTACTS also to 'A' for the relationship_id
     */

     UPDATE HZ_RELATIONSHIPS
     SET
     STATUS='A'
     WHERE
     RELATIONSHIP_ID=(SELECT RELATIONSHIP_ID FROM HZ_RELATIONSHIPS WHERE
				SUBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				SUBJECT_ID=p_contact_party_id
				AND
				SUBJECT_TYPE='PERSON'
				AND
				OBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				OBJECT_ID=p_vendor_party_id
				AND
				OBJECT_TYPE='ORGANIZATION'
				AND
				RELATIONSHIP_TYPE='CONTACT'
				AND
				RELATIONSHIP_CODE='CONTACT_OF'
				);

     UPDATE HZ_RELATIONSHIPS
     SET
     STATUS='A'
     WHERE
     RELATIONSHIP_ID=(SELECT RELATIONSHIP_ID FROM HZ_RELATIONSHIPS WHERE
				OBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				OBJECT_ID=p_contact_party_id
				AND
				OBJECT_TYPE='PERSON'
				AND
				SUBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				SUBJECT_ID=p_vendor_party_id
				AND
				SUBJECT_TYPE='ORGANIZATION'
				AND
				RELATIONSHIP_TYPE='CONTACT'
				AND
				RELATIONSHIP_CODE='CONTACT'
				);

    UPDATE HZ_ORG_CONTACTS
    SET
    STATUS='A'
    WHERE
    PARTY_RELATIONSHIP_ID=(SELECT RELATIONSHIP_ID FROM HZ_RELATIONSHIPS WHERE
				SUBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				SUBJECT_ID=p_contact_party_id
				AND
				SUBJECT_TYPE='PERSON'
				AND
				OBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				OBJECT_ID=p_vendor_party_id
				AND
				OBJECT_TYPE='ORGANIZATION'
				AND
				RELATIONSHIP_TYPE='CONTACT'
				AND
				RELATIONSHIP_CODE='CONTACT_OF');

   UPDATE HZ_ORG_CONTACTS
   SET
   STATUS='A'
   WHERE
   PARTY_RELATIONSHIP_ID=(SELECT RELATIONSHIP_ID FROM HZ_RELATIONSHIPS WHERE
				OBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				OBJECT_ID=p_contact_party_id
				AND
				OBJECT_TYPE='PERSON'
				AND
				SUBJECT_TABLE_NAME='HZ_PARTIES'
				AND
				SUBJECT_ID=p_vendor_party_id
				AND
				SUBJECT_TYPE='ORGANIZATION'
				AND
				RELATIONSHIP_TYPE='CONTACT'
				AND
				RELATIONSHIP_CODE='CONTACT'
				);


     /* Bug 9576302 End */
   IF x_return_status IS NULL OR
     x_return_status <> fnd_api.g_ret_sts_success THEN
      --ROLLBACK TO create_supplier_contact_sp;
      ROLLBACK TO update_supplier_contact_sp;
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO update_supplier_contact_sp;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_count := 1;
      x_msg_data := Sqlerrm;
      pos_log.log_sqlerrm('POSCONTB', 'in update_supplier_contact');

END update_supplier_contact;

END POS_SUPP_CONTACT_PKG ;

/
