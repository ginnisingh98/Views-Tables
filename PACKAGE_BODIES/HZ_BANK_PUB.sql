--------------------------------------------------------
--  DDL for Package Body HZ_BANK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BANK_PUB" AS
/*$Header: ARHBKASB.pls 120.24.12010000.3 2010/01/12 10:20:15 rgokavar ship $ */

  --
  -- declaration of private global variables
  --
  g_debug_count         NUMBER := 0;
  --g_debug               BOOLEAN := FALSE;
  g_insert              CONSTANT VARCHAR2(1) := 'I';
  g_update              CONSTANT VARCHAR2(1) := 'U';

  --
  -- declaration of private cursors
  --
  CURSOR c_codeassign (p_party_id IN NUMBER) IS
    SELECT hca.class_code
    FROM   hz_code_assignments hca
    WHERE  hca.owner_table_id = p_party_id
           AND hca.owner_table_name = 'HZ_PARTIES'
           AND hca.class_category = 'BANK_INSTITUTION_TYPE'
           AND hca.primary_flag = 'Y'
           AND hca.status = 'A';

  CURSOR c_reldir (
    p_relationship_type  IN     VARCHAR2,
    p_relationship_code  IN     VARCHAR2
  ) IS
    SELECT hrt.direction_code
    FROM   hz_relationship_types hrt
    WHERE  hrt.relationship_type = p_relationship_type
           AND hrt.forward_rel_code = p_relationship_code;

  -- declaration of private procedures

  /*=======================================================================+
   | PRIVATE PROCEDURE enable_debug                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Turn on debug mode.                                                 |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.enable_debug                                       |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   15-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;
    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
         hz_utility_v2pub.enable_debug;
         g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;
  */


  /*=======================================================================+
   | PRIVATE PROCEDURE disable_debug                                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Turn off debug mode.                                                |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.disable_debug                                      |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   15-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/

  /*PROCEDURE disable_debug IS
  BEGIN
    IF g_debug THEN
      g_debug_count := g_debug_count - 1;
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
      END IF;
    END IF;
  END disable_debug;
  */

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_parent_bank                                |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validations specific to the parent bank of a given bank branch.     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   |   08-MAY-2002    J. del Callar      Bank number is now stored in the  |
   |                                     bank_code field on HZ_PARTIES,    |
   |                                     while branch number is stored in  |
   |                                     branch_code.                      |
   |   29-MAY-2002    J. del Callar      Modified uniqueness check to      |
   |                                     ignore the current bank branch    |
   |                                     during update by ignoring any     |
   |                                     party with the given party ID     |
   |   23-JAN-2004    Rajesh Jose        A Clearing House Branch can only  |
   |                                     have a Clearing House as a parent.|
   +=======================================================================*/
  PROCEDURE validate_parent_bank (
    p_bank_rec           IN     bank_rec_type,
    p_bank_id            IN     NUMBER,
    p_mode               IN     VARCHAR2,
    x_return_status      IN OUT NOCOPY VARCHAR2
  ) IS
    CURSOR c_parentinfo IS
      SELECT hop.bank_or_branch_number,
             hop.organization_name,
             hop.home_country
      FROM   hz_organization_profiles hop,
             hz_parties hp
      WHERE  hop.party_id = p_bank_id
        AND  SYSDATE BETWEEN TRUNC(hop.effective_start_date)
                     AND NVL(hop.effective_end_date, SYSDATE+1)
        AND  hp.party_id = hop.party_id
        AND  hp.status='A';

    CURSOR c_parentinfo2 IS
      SELECT hop.party_id,
             hop.bank_or_branch_number,
             hop.organization_name,
             hop.home_country
      FROM   hz_organization_profiles hop,
             hz_parties hp,
             hz_relationships hr
      WHERE  hr.object_id = p_bank_rec.organization_rec.party_rec.party_id
        AND  hr.relationship_type = 'BANK_AND_BRANCH'
        AND  hr.relationship_code = 'HAS_BRANCH'
        AND  hr.object_type = 'ORGANIZATION'
        AND  hr.object_table_name = 'HZ_PARTIES'
        AND  hr.subject_type = 'ORGANIZATION'
        AND  hr.subject_table_name = 'HZ_PARTIES'
        AND  SYSDATE BETWEEN hr.start_date AND NVL(hr.end_date, SYSDATE + 1)
        AND  hr.status = 'A'
        AND  hop.party_id = hr.subject_id
        AND  SYSDATE BETWEEN TRUNC(hop.effective_start_date)
                     AND NVL(hop.effective_end_date, SYSDATE+1)
        AND  hp.party_id = hop.party_id
        AND  hp.status = 'A';

    CURSOR c_uniquenumberck (
      p_parent_id     NUMBER
    )  IS
      SELECT 1
      FROM   hz_relationships hr,
             hz_organization_profiles hopbb
      WHERE  hr.subject_id = p_parent_id
        AND  hr.relationship_type = 'BANK_AND_BRANCH'
        AND  hr.relationship_code = 'HAS_BRANCH'
        AND  hr.subject_type = 'ORGANIZATION'
        AND  hr.subject_table_name = 'HZ_PARTIES'
        AND  hr.object_type = 'ORGANIZATION'
        AND  hr.object_table_name = 'HZ_PARTIES'
        AND  hopbb.party_id = hr.object_id
        AND  hopbb.party_id <>
                   NVL(p_bank_rec.organization_rec.party_rec.party_id,
                       -1)
        AND  SYSDATE BETWEEN TRUNC(hopbb.effective_start_date)
                     AND NVL(hopbb.effective_end_date, SYSDATE+1)
        AND  hopbb.bank_or_branch_number = p_bank_rec.bank_or_branch_number;

    -- Bug 4942662. Tuned the SQL.
    CURSOR c_uniquenameck (
      p_parent_id     NUMBER
    ) IS
      SELECT 1
      FROM   hz_relationships hr,
             hz_parties hpbb
      WHERE  hr.subject_id = p_parent_id
        AND  hr.relationship_type = 'BANK_AND_BRANCH'
        AND  hr.relationship_code = 'HAS_BRANCH'
        AND  hr.subject_type = 'ORGANIZATION'
        AND  hr.subject_table_name = 'HZ_PARTIES'
        AND  hr.object_type = 'ORGANIZATION'
        AND  hr.object_table_name = 'HZ_PARTIES'
        AND  hpbb.party_id = hr.object_id
        AND  hpbb.party_id <>
                   NVL(p_bank_rec.organization_rec.party_rec.party_id,
                       -1)
        AND  hpbb.party_name = p_bank_rec.organization_rec.organization_name;

    l_parent_class_code         VARCHAR2(30);
    l_parent_number             VARCHAR2(30);
    l_parent_name               VARCHAR2(360);
    l_parent_id                 NUMBER(15);
    l_parent_country            VARCHAR2(30) := NULL;
    l_dummy                     NUMBER;
    l_debug_prefix                     VARCHAR2(30) := '';

  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_parent_bank (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --
    -- The parent bank checks should only be performed if a parent bank was
    -- specified or if we are in insert mode.
    --
    IF p_mode = g_insert OR p_bank_id IS NOT NULL THEN
      --
      -- Parent must be classified as a BANK or CLEARINGHOUSE
      -- Bug 2835472
      -- If the branch is a ClearingHouse_Branch then parent must be a
      -- Clearing House. Added the last OR condition below.
      --
      OPEN c_codeassign (p_bank_id);
      FETCH c_codeassign INTO l_parent_class_code;
      IF c_codeassign%NOTFOUND
         OR l_parent_class_code NOT IN ('BANK', 'CLEARINGHOUSE')
         OR (p_bank_rec.institution_type = 'CLEARINGHOUSE_BRANCH' AND
                l_parent_class_code <> 'CLEARINGHOUSE')
      THEN
        CLOSE c_codeassign;
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_PARENT');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

        -- parent is not a bank: no point in going any further.
        RETURN;
      ELSE
        CLOSE c_codeassign;
      END IF;

      --
      -- Get parent bank information.
      --
      OPEN c_parentinfo;
      FETCH c_parentinfo INTO l_parent_number, l_parent_name, l_parent_country;
      IF c_parentinfo%NOTFOUND THEN
        CLOSE c_parentinfo;
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_PARENT');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

        -- parent is not a bank: no point in going any further.
        RETURN;
      ELSE
        CLOSE c_parentinfo;
      END IF;

      -- save parent id for later use
      l_parent_id := p_bank_id;

    ELSE
      --
      -- Use a different cursor to get parent bank information because the
      -- parent was not specified.
      --
      OPEN c_parentinfo2;
      FETCH c_parentinfo2
      INTO  l_parent_id,
            l_parent_number,
            l_parent_name,
            l_parent_country;
      IF c_parentinfo2%NOTFOUND THEN
        CLOSE c_parentinfo2;
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_PARENT');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

        -- parent is not a bank: no point in going any further.
        RETURN;
      ELSE
        CLOSE c_parentinfo2;
      END IF;

    END IF;

    --
    -- Validate the country.  The bank branch's country must be the same as
    -- the country of the parent bank.  Only do validation, though if the
    -- country is specified in the bank record or we are in insert mode.
    --
    IF (p_mode = g_insert
        OR p_bank_rec.organization_rec.home_country IS NOT NULL)
       AND NVL(l_parent_country, fnd_api.g_miss_char) <> p_bank_rec.organization_rec.home_country
    THEN
      fnd_message.set_name('AR', 'HZ_BANK_INVALID_COUNTRY');
      fnd_message.set_token('INVCOUNTRY', p_bank_rec.organization_rec.home_country);
      fnd_message.set_token('VLDCOUNTRY', l_parent_country);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'l_parent_id = '||l_parent_id,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_statement);
    END IF;

    --
    -- The combination of Bank Number (from the Bank to which the Branch
    -- belongs), Branch Number, and Country Code must be unique.
    --
    OPEN c_uniquenumberck(l_parent_id);
    FETCH c_uniquenumberck INTO l_dummy;
    IF c_uniquenumberck%FOUND THEN
      fnd_message.set_name('AR', 'HZ_BANK_NONUNIQUE_NUMBER');
      fnd_message.set_token('BANK', l_parent_number);
      fnd_message.set_token('BRANCH', p_bank_rec.bank_or_branch_number);
      fnd_message.set_token('COUNTRY', l_parent_country);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_uniquenumberck;

    --
    -- The combination of Bank Name (Organization Name from the Bank record)
    -- and Branch Name (Organization Name from the branch) must be unique.
    --
    OPEN c_uniquenameck(l_parent_id);
    FETCH c_uniquenameck INTO l_dummy;
    IF c_uniquenameck%FOUND THEN
      fnd_message.set_name('AR', 'HZ_BANK_NONUNIQUE_NAME');
      fnd_message.set_token('BANK', l_parent_name);
      fnd_message.set_token('BRANCH',
                            p_bank_rec.organization_rec.organization_name);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_uniquenameck;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_parent_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_parent_bank;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_bank_org                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank- or bank branch-specific validations.                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   |   06-MAY-2002    J. del Callar      Modified to get the temporary ID  |
   |                                     for the organization temp record  |
   |                                     and pass the value along to the   |
   |                                     dynamic validation routine.       |
   |   21-JAN-2004    Rajesh Jose        Modified to allow Clearing House  |
   |                                     Branches to be created.           |
   |   23-JAN-2004    Rajesh Jose        Modified so that updation will    |
   |                                     insert the party_id of the        |
   |                                     concerned bank or branch into the |
   |                                     temp table hz_bank_val_gt.        |
   +=======================================================================*/
  PROCEDURE validate_bank_org (
    p_bank_rec                  IN      bank_rec_type,
    p_intended_type             IN      VARCHAR2,
    p_mode                      IN      VARCHAR2,
    x_return_status             IN OUT NOCOPY  VARCHAR2
  ) IS
    CURSOR orgidcur IS
      SELECT hz_parties_s.NEXTVAL  -- Bug 3397488
      FROM   DUAL;

    l_validation_procedure      VARCHAR2(60);
    l_temp_id                   NUMBER(15);
    l_debug_prefix              VARCHAR2(30) := '';
    -- Bug 3814832
    l_country                   VARCHAR2(2);
BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_bank_org (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --
    -- static validations
    --

    -- Bug 2465471. Bank Number and Bank Branch Number are not required.
    -- So commented out the following validation. - Isen
    -- IF p_mode = g_insert
    --    AND p_bank_rec.bank_code IS NULL
    --    AND p_bank_rec.branch_code IS NULL
    -- THEN
    --   fnd_message.set_name('AR', 'HZ_API_MAND_DEP_FIELDS');
    --   fnd_message.set_token('COLUMN1', 'bank or branch number');
    --   fnd_message.set_token('VALUE1', 'NULL');
    --   fnd_message.set_token('COLUMN2', 'bank or branch number');
    --   fnd_msg_pub.add;
    --   x_return_status := fnd_api.g_ret_sts_error;
    -- END IF;

    IF p_intended_type = 'BANK' THEN
      -- branch code must be null
      IF p_bank_rec.branch_code IS NOT NULL THEN
        fnd_message.set_name('AR', 'HZ_BANK_BRANCH_SPECIFIED');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- bank institution type must be either CLEARINGHOUSE OR BANK
      IF p_bank_rec.institution_type NOT IN ('BANK', 'CLEARINGHOUSE') THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB', 'CLEARINGHOUSE, BANK');
        fnd_message.set_token('INVALIDSUB', p_bank_rec.institution_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- set the validation procedure to be run.
      l_validation_procedure := 'HZ_BANK_VALIDATION_PROCEDURE';
    ELSIF p_intended_type = 'BRANCH' THEN
      -- Bug 2835472 Added Clearinghouse_branch as valid institution type.
      -- bank institution type must be BANK BRANCH or CLEARINGHOUSE_BRANCH
      IF p_bank_rec.institution_type
      NOT IN ('BANK_BRANCH', 'CLEARINGHOUSE_BRANCH') THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB', 'BANK_BRANCH, CLEARINGHOUSE_BRANCH');
        fnd_message.set_token('INVALIDSUB', p_bank_rec.institution_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      -- set the validation procedure to be run.
      l_validation_procedure := 'HZ_BANK_BRANCH_VALIDATION_PROCEDURE';
    ELSE
      -- this procedure should not have been called.
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- get the temporary ID to identify the bank record - use the same ID
    -- as what will be used to identify the organization record.
    --
    -- Bug 2805045. Temporary ID needs to be determined only in the case
    -- of an Insert.
    IF (p_mode = g_insert) THEN
       OPEN orgidcur;
       FETCH orgidcur INTO l_temp_id;
       IF orgidcur%NOTFOUND THEN
          -- Close the cursor and raise an error if the group ID could not be
          -- selected from the sequence.
          CLOSE orgidcur;

          fnd_message.set_name('AR', 'HZ_DV_ID_NOT_FOUND');
          fnd_message.set_token('SEQUENCE', 'hz_parties_s'); -- Bug 3397488
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
       END IF;
       CLOSE orgidcur;
    -- Bug 3814832
    l_country:=p_bank_rec.organization_rec.home_country;
    END IF;

    -- In case of an update use the party_id that is present in the bank record
    IF (p_mode = g_update) THEN
       l_temp_id := p_bank_rec.organization_rec.party_rec.party_id;
    -- Bug 3814832
       if p_bank_rec.organization_rec.home_country is null
       then
          select home_country into l_country
          from   hz_organization_profiles
          where  party_id=l_temp_id
          and    sysdate between trunc(effective_start_date)
                    and nvl(effective_end_date, sysdate+1);
       else l_country:=p_bank_rec.organization_rec.home_country;
       end if;
    END IF;

    -- There should be no pre-existing temporary bank records.
    DELETE FROM hz_bank_val_gt;
    -- create the temporary bank record

    INSERT INTO hz_bank_val_gt (
      temp_id,
      bank_or_branch_number,
      bank_code,
      branch_code,
      institution_type,
      branch_type,
      rfc_code,
      country
    ) VALUES (
      l_temp_id,
      p_bank_rec.bank_or_branch_number,
      p_bank_rec.bank_code,
      p_bank_rec.branch_code,
      p_bank_rec.institution_type,
      p_bank_rec.branch_type,
      p_bank_rec.rfc_code,
    -- Bug 3814832
      l_country
    );

    --
    -- dynamic validation routine call - pass on the organization ID selected
    -- previously.
    --

    BEGIN
      hz_dyn_validation.validate_organization(p_bank_rec.organization_rec,
                                              l_validation_procedure,
                                              l_temp_id);
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile:'||l_validation_procedure,
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;

      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_bank_org (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_bank_org;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_edi_contact_point                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank EDI contact point-specific validations.                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar      Bug 2238144: Created.             |
   +=======================================================================*/
  PROCEDURE validate_edi_contact_point (
    p_contact_point_rec IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec           IN     hz_contact_point_v2pub.edi_rec_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
  ) IS
    -- cursor used to determine uniqueness of the EDI contact point across
    -- bank parties.
    CURSOR c_uniqueptyedi IS
      SELECT 1
      FROM   hz_contact_points hcp,
             hz_code_assignments hca
      WHERE  hcp.edi_id_number = p_edi_rec.edi_id_number
             AND NVL(hcp.edi_ece_tp_location_code,
                     p_edi_rec.edi_ece_tp_location_code) =
                   p_edi_rec.edi_ece_tp_location_code
             AND hcp.contact_point_id <> p_contact_point_rec.contact_point_id
             AND hcp.contact_point_type = 'EDI'
             AND hcp.status = 'A'
             AND hcp.owner_table_name = 'HZ_PARTIES'
             AND hcp.owner_table_id = hca.owner_table_id
             AND hca.owner_table_name = 'HZ_PARTIES'
             AND hca.class_category = 'BANK_INSTITUTION_TYPE';

    -- cursor used to determine uniqueness of the EDI contact point across
    -- bank party sites.
    CURSOR c_uniquepsedi IS
      SELECT 1
      FROM   hz_contact_points hcp,
             hz_party_sites hps,
             hz_code_assignments hca
      WHERE  hcp.edi_id_number = p_edi_rec.edi_id_number
             AND NVL(hcp.edi_ece_tp_location_code,
                     p_edi_rec.edi_ece_tp_location_code) =
                   p_edi_rec.edi_ece_tp_location_code
             AND hcp.contact_point_id <> p_contact_point_rec.contact_point_id
             AND hcp.contact_point_type = 'EDI'
             AND hcp.status = 'A'
             AND hcp.owner_table_name = 'HZ_PARTY_SITES'
             AND hcp.owner_table_id = hps.party_site_id
             AND hps.party_id = hca.owner_table_id
             AND hca.owner_table_name = 'HZ_PARTIES'
             AND hca.class_category = 'BANK_INSTITUTION_TYPE';

    l_dummy NUMBER;
    l_debug_prefix      VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_edi_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Validate uniqueness of EDI record.
    -- first check across party contacts.
    OPEN c_uniqueptyedi;
    FETCH c_uniqueptyedi INTO l_dummy;
    IF c_uniqueptyedi%FOUND THEN
      fnd_message.set_name('AR', 'HZ_EDI_UNIQUE');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    ELSE
      -- party contacts passed, check across party site contacts.
      OPEN c_uniquepsedi;
      FETCH c_uniquepsedi INTO l_dummy;
      IF c_uniquepsedi%FOUND THEN
        fnd_message.set_name('AR', 'HZ_EDI_UNIQUE');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_uniquepsedi;
    END IF;
    CLOSE c_uniqueptyedi;

    BEGIN
      hz_dyn_validation.validate_contact_point(
        x_contact_point      => p_contact_point_rec,
        x_edi_contact        => p_edi_rec,
        x_eft_contact        => hz_contact_point_v2pub.g_miss_eft_rec,
        x_email_contact      => hz_contact_point_v2pub.g_miss_email_rec,
        x_phone_contact      => hz_contact_point_v2pub.g_miss_phone_rec,
        x_telex_contact      => hz_contact_point_v2pub.g_miss_telex_rec,
        x_web_contact        => hz_contact_point_v2pub.g_miss_web_rec,
        x_validation_profile => 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_edi_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_edi_contact_point;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_eft_contact_point                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank EFT contact point-specific validations.                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar      Bug 2238144: Created.             |
   +=======================================================================*/
  PROCEDURE validate_eft_contact_point (
    p_contact_point_rec IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec           IN     hz_contact_point_v2pub.eft_rec_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_eft_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    BEGIN
      hz_dyn_validation.validate_contact_point(
        x_contact_point      => p_contact_point_rec,
        x_edi_contact        => hz_contact_point_v2pub.g_miss_edi_rec,
        x_eft_contact        => p_eft_rec,
        x_email_contact      => hz_contact_point_v2pub.g_miss_email_rec,
        x_phone_contact      => hz_contact_point_v2pub.g_miss_phone_rec,
        x_telex_contact      => hz_contact_point_v2pub.g_miss_telex_rec,
        x_web_contact        => hz_contact_point_v2pub.g_miss_web_rec,
        x_validation_profile => 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_eft_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_eft_contact_point;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_web_contact_point                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank Web contact point-specific validations.                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar      Bug 2238144: Created.             |
   +=======================================================================*/
  PROCEDURE validate_web_contact_point (
    p_contact_point_rec IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec           IN     hz_contact_point_v2pub.web_rec_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_web_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    BEGIN
      hz_dyn_validation.validate_contact_point(
        x_contact_point      => p_contact_point_rec,
        x_edi_contact        => hz_contact_point_v2pub.g_miss_edi_rec,
        x_eft_contact        => hz_contact_point_v2pub.g_miss_eft_rec,
        x_email_contact      => hz_contact_point_v2pub.g_miss_email_rec,
        x_phone_contact      => hz_contact_point_v2pub.g_miss_phone_rec,
        x_telex_contact      => hz_contact_point_v2pub.g_miss_telex_rec,
        x_web_contact        => p_web_rec,
        x_validation_profile => 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;

      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_web_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_web_contact_point;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_phone_contact_point                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank Phone contact point-specific validations.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar      Bug 2238144: Created.             |
   +=======================================================================*/
  PROCEDURE validate_phone_contact_point (
    p_contact_point_rec IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec         IN     hz_contact_point_v2pub.phone_rec_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_phone_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    BEGIN
      hz_dyn_validation.validate_contact_point(
        x_contact_point      => p_contact_point_rec,
        x_edi_contact        => hz_contact_point_v2pub.g_miss_edi_rec,
        x_eft_contact        => hz_contact_point_v2pub.g_miss_eft_rec,
        x_email_contact      => hz_contact_point_v2pub.g_miss_email_rec,
        x_phone_contact      => p_phone_rec,
        x_telex_contact      => hz_contact_point_v2pub.g_miss_telex_rec,
        x_web_contact        => hz_contact_point_v2pub.g_miss_web_rec,
        x_validation_profile => 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;

      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_phone_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_phone_contact_point;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_email_contact_point                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank Email contact point-specific validations.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar      Bug 2238144: Created.             |
   +=======================================================================*/
  PROCEDURE validate_email_contact_point (
    p_contact_point_rec IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec         IN     hz_contact_point_v2pub.email_rec_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_email_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    BEGIN
      hz_dyn_validation.validate_contact_point(
        x_contact_point      => p_contact_point_rec,
        x_edi_contact        => hz_contact_point_v2pub.g_miss_edi_rec,
        x_eft_contact        => hz_contact_point_v2pub.g_miss_eft_rec,
        x_phone_contact      => hz_contact_point_v2pub.g_miss_phone_rec,
        x_email_contact      => p_email_rec,
        x_telex_contact      => hz_contact_point_v2pub.g_miss_telex_rec,
        x_web_contact        => hz_contact_point_v2pub.g_miss_web_rec,
        x_validation_profile => 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_email_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_email_contact_point;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_telex_contact_point                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank Telex contact point-specific validations.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar      Bug 2238144: Created.             |
   +=======================================================================*/
  PROCEDURE validate_telex_contact_point (
    p_contact_point_rec IN     hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec         IN     hz_contact_point_v2pub.telex_rec_type,
    x_return_status     IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_telex_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    BEGIN
      hz_dyn_validation.validate_contact_point(
        x_contact_point      => p_contact_point_rec,
        x_edi_contact        => hz_contact_point_v2pub.g_miss_edi_rec,
        x_eft_contact        => hz_contact_point_v2pub.g_miss_eft_rec,
        x_phone_contact      => hz_contact_point_v2pub.g_miss_phone_rec,
        x_email_contact      => hz_contact_point_v2pub.g_miss_email_rec,
        x_telex_contact      => p_telex_rec,
        x_web_contact        => hz_contact_point_v2pub.g_miss_web_rec,
        x_validation_profile => 'HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANK_CONTACT_POINT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_telex_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_telex_contact_point;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_banking_group                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Banking group-specific validations.                                 |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE validate_banking_group (
    p_group_rec     IN     hz_party_v2pub.group_rec_type,
    x_return_status IN OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_banking_group (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Only one group type is currently supported.
    IF p_group_rec.group_type <> 'BANKING_GROUP' THEN
      fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
      fnd_message.set_token('VALIDSUB', 'BANKING_GROUP');
      fnd_message.set_token('INVALIDSUB', p_group_rec.group_type);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    BEGIN
      hz_dyn_validation.validate_group(
        p_group_rec,
        'HZ_BANKING_GROUP_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANKING_GROUP_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_banking_group (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_banking_group;

  /*=======================================================================+
   | PRIVATE FUNCTION get_group_type                                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get the group type of a particular party.                           |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  FUNCTION get_group_type (
    p_party_id           IN     NUMBER,
    x_return_status      IN OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR c_group IS
      SELECT hp.group_type
      FROM   hz_parties hp
      WHERE  hp.party_id = p_party_id
             AND hp.status = 'A';
    l_group_type        VARCHAR2(30);
  BEGIN
    OPEN c_group;
    FETCH c_group INTO l_group_type;
    IF c_group%NOTFOUND THEN
      fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
      fnd_message.set_token('RECORD', 'party');
      fnd_message.set_token('VALUE', TO_CHAR(p_party_id));
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_group;

    RETURN NVL(l_group_type, 'NULL');
  END get_group_type;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_bank_group_member                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Banking group membership-specific validations.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE validate_bank_group_member (
    p_relationship_rec     IN     hz_relationship_v2pub.relationship_rec_type,
    p_mode                 IN     VARCHAR2,
    x_return_status        IN OUT NOCOPY VARCHAR2
  ) IS
    l_group_type        VARCHAR2(30);
    l_class_code        VARCHAR2(30);
    l_parent            VARCHAR2(30);
    l_direction         VARCHAR2(30);
    l_bank_id           NUMBER;
    l_debug_prefix      VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_bank_group_member (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Only one group membership relationship type is currently supported.
    -- Only check if we are in insert mode or the relationship_type was
    -- specified.
    IF (p_mode = g_insert OR p_relationship_rec.relationship_type IS NOT NULL)
       AND NVL(p_relationship_rec.relationship_type, 'NULL') <> 'BANKING_GROUP'
    THEN
      fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
      fnd_message.set_token('VALIDSUB', 'BANKING_GROUP');
      fnd_message.set_token('INVALIDSUB',
                            p_relationship_rec.relationship_type);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    --
    -- Only check this information if we are in insert
    -- mode.  The V2API call will ignore all updates to the parent and the
    -- child fields.
    --
    IF p_mode = g_insert THEN
      --
      -- The banking group party specified by either
      -- p_relationship_rec.subject_id or p_relationship_rec.object_id must be
      -- a valid Banking Group.
      --

      -- first check if the group is in the subject node of the relationship.
      l_group_type := get_group_type(p_relationship_rec.subject_id,
                                     x_return_status);

      -- check the type of the subject node.
      IF l_group_type = 'BANKING_GROUP' THEN
        -- the parent group is the subject.
        l_parent := 'SUBJECT';
      ELSE
        -- the subject is not a banking group, check the object node.
        l_group_type := get_group_type(p_relationship_rec.object_id,
                                       x_return_status);

        IF l_group_type = 'BANKING_GROUP' THEN
          -- the parent group is the object.
          l_parent := 'OBJECT';
        ELSE
          -- if the object is also not the right type, then this is not valid.
          fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
          fnd_message.set_token('VALIDSUB', 'BANKING_GROUP');
          fnd_message.set_token('INVALIDSUB', l_group_type);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;

          -- return, the rest of the validations do not make sense if neither
          -- subject nor object is a valid banking group.
          RETURN;
        END IF;
      END IF;

      --
      -- Validate the direction specified in the relationship.
      --
      OPEN c_reldir('BANKING_GROUP', p_relationship_rec.relationship_code);
      FETCH c_reldir INTO l_direction;
      IF c_reldir%FOUND THEN
        -- If the subject is the parent node, then a parent direction code must
        -- be specified for the relationship type.  Alternatively, if the
        -- object is the parent node, then a child direction code must be
        -- specified.
        IF ((l_parent = 'SUBJECT' AND l_direction <> 'P')
            OR (l_parent = 'OBJECT' AND l_direction <> 'C'))
        THEN
          fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
          IF l_parent = 'SUBJECT' THEN
            fnd_message.set_token('VALIDSUB', 'P');
          ELSE
            fnd_message.set_token('VALIDSUB', 'C');
          END IF;
          fnd_message.set_token('INVALIDSUB', l_direction);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      ELSE
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'banking group relationship type');
        fnd_message.set_token('VALUE', p_relationship_rec.relationship_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_reldir;

      --
      -- The bank party specified by p_relationship_rec.object_id must be a
      -- valid Bank or Clearinghouse.
      --
      IF l_parent = 'SUBJECT' THEN
        -- the parent group is the subject, so the object must be a bank.
        l_bank_id := p_relationship_rec.object_id;
      ELSE
        -- the parent group is the object, so the subject must be a bank.
        l_bank_id := p_relationship_rec.subject_id;
      END IF;

      OPEN c_codeassign(l_bank_id);
      FETCH c_codeassign INTO l_class_code;
      IF c_codeassign%NOTFOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'bank classification code assignment');
        fnd_message.set_token('VALUE', TO_CHAR(l_bank_id));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;

      IF l_class_code IS NOT NULL
         AND l_class_code NOT IN ('BANK', 'CLEARINGHOUSE')
      THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB', 'BANK, CLEARINGHOUSE');
        fnd_message.set_token('INVALIDSUB', l_class_code);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_codeassign;
    END IF;

    --
    -- Execute the dynamic validations.
    --

    BEGIN
      hz_dyn_validation.validate_relationship(
        p_relationship_rec,
        'HZ_BANKING_GROUP_MEMBER_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_BANKING_GROUP_MEMBER_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_bank_group_member (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_bank_group_member;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_clearinghouse_assign                       |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Banking group membership-specific validations.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE validate_clearinghouse_assign (
    p_relationship_rec     IN     hz_relationship_v2pub.relationship_rec_type,
    p_mode                 IN     VARCHAR2,
    x_return_status        IN OUT NOCOPY VARCHAR2
  ) IS
    l_object_class          VARCHAR2(30) := NULL;
    l_subject_class         VARCHAR2(30) := NULL;
    l_direction            VARCHAR2(30);
    l_debug_prefix         VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_clearinghouse_assign (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Only one group membership relationship type is currently supported.
    IF (p_mode = g_insert OR p_relationship_rec.relationship_type IS NOT NULL)
       AND NVL(p_relationship_rec.relationship_type, 'NULL') <>
         'CLEARINGHOUSE_BANK'
    THEN
      fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
      fnd_message.set_token('VALIDSUB', 'CLEARINGHOUSE_BANK');
      fnd_message.set_token('INVALIDSUB',
                            p_relationship_rec.relationship_type);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;

    --
    -- Only check this information if we are in insert mode.  The V2 API call
    -- will ignore all updates to the parent and the child fields.
    --

    IF p_mode = g_insert THEN
      --
      -- The bank party specified by p_relationship_rec.subject_id must be a
      -- valid Clearinghouse or Bank.
      --

      OPEN c_codeassign(p_relationship_rec.subject_id);
      FETCH c_codeassign INTO l_subject_class;
      IF c_codeassign%NOTFOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD',
                              'bank/clearinghouse code assignment (subject)');
        fnd_message.set_token('VALUE', TO_CHAR(p_relationship_rec.subject_id));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      ELSIF l_subject_class NOT IN ('CLEARINGHOUSE', 'BANK', 'BANK_BRANCH')
      THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB', 'CLEARINGHOUSE, BANK');
        fnd_message.set_token('INVALIDSUB', l_subject_class);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_codeassign;

      --
      -- The bank party specified by p_relationship_rec.subject_id must be a
      -- valid Bank or Clearinghouse, but opposite from parent.
      --

      OPEN c_codeassign(p_relationship_rec.object_id);
      FETCH c_codeassign INTO l_object_class;
      IF c_codeassign%NOTFOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD',
                              'bank/clearinghouse code assignment (object)');
        fnd_message.set_token('VALUE', TO_CHAR(p_relationship_rec.object_id));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      ELSIF l_object_class NOT IN ('CLEARINGHOUSE', 'BANK', 'BANK_BRANCH') THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB', 'BANK, CLEARINGHOUSE');
        fnd_message.set_token('INVALIDSUB', l_object_class);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      ELSIF l_subject_class = l_object_class THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB', 'different');
        fnd_message.set_token('INVALIDSUB', l_object_class);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_codeassign;

      --
      -- validate the direction of the relationship
      --
      OPEN c_reldir('CLEARINGHOUSE_BANK',
                    p_relationship_rec.relationship_code);
      FETCH c_reldir INTO l_direction;
      IF c_reldir%FOUND THEN
        -- If the subject is a CLEARINGHOUSE, then a parent direction code must
        -- be specified for the relationship type.  Alternatively, if the
        -- object is the CLEARINGHOUSE, then a child direction code must be
        -- specified.
        IF ((l_subject_class = 'CLEARINGHOUSE' AND l_direction <> 'P')
            OR (l_object_class = 'CLEARINGHOUSE' AND l_direction <> 'C'))
        THEN
          fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
          IF l_subject_class = 'CLEARINGHOUSE' THEN
            fnd_message.set_token('VALIDSUB', 'P');
          ELSE
            fnd_message.set_token('VALIDSUB', 'C');
          END IF;
          fnd_message.set_token('INVALIDSUB', l_direction);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      ELSE
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD',
                              'clearinghouse assignment relationship type');
        fnd_message.set_token('VALUE', p_relationship_rec.relationship_type);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_reldir;
    END IF;

    BEGIN
      hz_dyn_validation.validate_relationship(
        p_relationship_rec,
        'HZ_CLEARINGHOUSE_ASSIGNMENT_VALIDATION_PROCEDURE'
      );
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: HZ_CLEARINGHOUSE_ASSIGNMENT_VALIDATION_PROCEDURE',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_clearinghouse_assign;

  /*=======================================================================+
   | PRIVATE PROCEDURE validate_bank_site                                  |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Bank site-specific validations.                                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE validate_bank_site (
    p_party_site_rec       IN     hz_party_site_v2pub.party_site_rec_type,
    p_mode                 IN     VARCHAR2,
    x_return_status        IN OUT NOCOPY VARCHAR2
  ) IS
    CURSOR c_parentcountry (p_party_id IN NUMBER) IS
      SELECT hop.home_country
      FROM   hz_organization_profiles hop, hz_parties hp
      WHERE  hop.party_id = p_party_id
      AND hp.party_id = hop.party_id
      AND hp.status = 'A'
      AND    sysdate between trunc(hop.effective_start_date)
                 and nvl(hop.effective_end_date, sysdate+1);

    CURSOR c_sitecountry (p_location_id IN NUMBER) IS
      SELECT hl.country
      FROM   hz_locations hl
      WHERE  hl.location_id = p_location_id;

    CURSOR c_site IS
      SELECT hps.party_id,
             hps.location_id
      FROM   hz_party_sites hps
      WHERE  hps.party_site_id = p_party_site_rec.party_site_id;

    l_parent_country       VARCHAR2(60);
    l_site_country         VARCHAR2(60);
    l_class_code           VARCHAR2(30) := NULL;
    l_validation_procedure VARCHAR2(80);
    l_party_id             NUMBER;
    l_location_id          NUMBER;
    l_temp_party_id        NUMBER;
    l_temp_location_id     NUMBER;
    l_debug_prefix         VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_bank_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    --
    -- Validate the country.  The location's country must be the same as the
    -- country of the parent bank or bank branch.  Do this validation only
    -- if we are in insert mode or if the location or the party was specified.
    --
    IF p_mode = g_insert
       OR p_party_site_rec.party_id IS NOT NULL
       OR p_party_site_rec.location_id IS NOT NULL
    THEN
      --
      -- set the party and location IDs for validation.
      --
      l_party_id := p_party_site_rec.party_id;
      l_location_id := p_party_site_rec.location_id;

      IF l_party_id IS NULL OR l_location_id IS NULL THEN
        -- incomplete information given for the insert.
        IF p_mode = g_insert THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'party or location');
          fnd_message.set_token('COLUMN', 'PARTY_ID or LOCATION_ID');
          fnd_message.set_token('TABLE', 'HZ_PARTY_SITES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          -- no point doing further validations.  We're missing some data.
          RETURN;
        END IF;

        -- get the missing information.
        OPEN c_site;
        FETCH c_site INTO l_temp_party_id, l_temp_location_id;
        IF c_site%NOTFOUND THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'party or location');
          fnd_message.set_token('COLUMN', 'PARTY_ID or LOCATION_ID');
          fnd_message.set_token('TABLE', 'HZ_PARTY_SITES');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          -- no point doing further validations.  We're missing some data.
          RETURN;
        END IF;

        IF l_party_id IS NULL THEN
          l_party_id := l_temp_party_id;
        END IF;

        IF l_location_id IS NULL THEN
          l_location_id := l_temp_location_id;
        END IF;
      END IF;

      OPEN c_parentcountry(l_party_id);
      FETCH c_parentcountry INTO l_parent_country;
      IF c_parentcountry%NOTFOUND THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'active party');
        fnd_message.set_token('COLUMN', 'PARTY_ID');
        fnd_message.set_token('TABLE', 'HZ_PARTIES');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_parentcountry;

      OPEN c_sitecountry(l_location_id);
      FETCH c_sitecountry INTO l_site_country;
      IF c_sitecountry%NOTFOUND THEN
        fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
        fnd_message.set_token('FK', 'active location');
        fnd_message.set_token('COLUMN', 'LOCATION_ID');
        fnd_message.set_token('TABLE', 'HZ_LOCATIONS');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_sitecountry;

      IF l_parent_country <> l_site_country THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_COUNTRY');
        fnd_message.set_token('INVCOUNTRY', l_site_country);
        fnd_message.set_token('VLDCOUNTRY', l_parent_country);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    END IF;

    --
    -- check the classification of the record, only if we are in insert mode
    -- or the party_id was specified.
    --
    IF p_party_site_rec.party_id IS NOT NULL
       OR p_mode = g_insert
    THEN
      OPEN c_codeassign(p_party_site_rec.party_id);
      FETCH c_codeassign INTO l_class_code;
      IF c_codeassign%NOTFOUND THEN
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'bank-related code assignment');
        fnd_message.set_token('VALUE', TO_CHAR(p_party_site_rec.party_id));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      ELSIF l_class_code NOT IN ('CLEARINGHOUSE', 'BANK', 'BANK_BRANCH') THEN
        fnd_message.set_name('AR', 'HZ_BANK_INVALID_TYPE');
        fnd_message.set_token('VALIDSUB',
                              'BANK, CLEARINGHOUSE, BANK_BRANCH');
        fnd_message.set_token('INVALIDSUB', l_class_code);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
      CLOSE c_codeassign;
    END IF;

    IF l_class_code = 'BANK_BRANCH' THEN
      l_validation_procedure := 'HZ_BANK_BRANCH_SITE_VALIDATION_PROCEDURE';
    ELSE
      l_validation_procedure := 'HZ_BANK_SITE_VALIDATION_PROCEDURE';
    END IF;

    BEGIN
      hz_dyn_validation.validate_party_site(p_party_site_rec,
                                            l_validation_procedure);
    EXCEPTION
      WHEN hz_dyn_validation.null_profile_value THEN
        -- this error indicates that the profile value has not been set.
        -- ignore this error
        IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'undefined profile: '|| l_validation_procedure,
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
           hz_utility_v2pub.debug(p_message=>'error ignored',
                               p_prefix=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
        END IF;
      WHEN OTHERS THEN
        -- set the error status, don't need to set the error stack because
        -- the dynamic validation procedure already does so.
        x_return_status := fnd_api.g_ret_sts_error;
    END;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'validate_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END validate_bank_site;

  /*=======================================================================+
   | PRIVATE PROCEDURE update_bank_organization                            |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates the organization profile record's bank organization and     |
   |   party-specific attributes.                                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_organization_profiles_pkg.update_row                             |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   |   25-APR-2002    J. del Callar      Bug 2272311: Changed rowid cursor |
   |                                     to fail if no BANK classifications|
   |                                     are found for the org profile.    |
   +=======================================================================*/
  PROCEDURE update_bank_organization (
    p_profile_id                IN      NUMBER,
    p_bank_or_branch_number     IN      VARCHAR2,
    p_bank_code                 IN      VARCHAR2,
    p_branch_code               IN      VARCHAR2
  ) IS
    CURSOR c_orgprof IS
      SELECT hop.ROWID
      FROM   hz_organization_profiles hop
      WHERE  hop.organization_profile_id = p_profile_id;

    l_orowid                     VARCHAR2(60);
    l_debug_prefix               VARCHAR2(30);
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_organization (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'bank/branch number='||p_bank_or_branch_number,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
           hz_utility_v2pub.debug(p_message=>'bank code='||p_bank_code,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
           hz_utility_v2pub.debug(p_message=>'branch code='||p_branch_code,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    OPEN c_orgprof;
    FETCH c_orgprof INTO l_orowid;
    IF c_orgprof%NOTFOUND THEN
      CLOSE c_orgprof;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_orgprof;

    -- Debug info.
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'org rowid='||l_orowid,
                                  p_prefix =>l_debug_prefix,
                                  p_msg_level=>fnd_log.level_statement);
    END IF;

    hz_organization_profiles_pkg.update_row(
      x_rowid                           => l_orowid,
      x_organization_profile_id         => NULL,
      x_party_id                        => NULL,
      x_organization_name               => NULL,
      x_attribute_category              => NULL,
      x_attribute1                      => NULL,
      x_attribute2                      => NULL,
      x_attribute3                      => NULL,
      x_attribute4                      => NULL,
      x_attribute5                      => NULL,
      x_attribute6                      => NULL,
      x_attribute7                      => NULL,
      x_attribute8                      => NULL,
      x_attribute9                      => NULL,
      x_attribute10                     => NULL,
      x_attribute11                     => NULL,
      x_attribute12                     => NULL,
      x_attribute13                     => NULL,
      x_attribute14                     => NULL,
      x_attribute15                     => NULL,
      x_attribute16                     => NULL,
      x_attribute17                     => NULL,
      x_attribute18                     => NULL,
      x_attribute19                     => NULL,
      x_attribute20                     => NULL,
      x_enquiry_duns                    => NULL,
      x_ceo_name                        => NULL,
      x_ceo_title                       => NULL,
      x_principal_name                  => NULL,
      x_principal_title                 => NULL,
      x_legal_status                    => NULL,
      x_control_yr                      => NULL,
      x_employees_total                 => NULL,
      x_hq_branch_ind                   => NULL,
      x_branch_flag                     => NULL,
      x_oob_ind                         => NULL,
      x_line_of_business                => NULL,
      x_cong_dist_code                  => NULL,
      x_sic_code                        => NULL,
      x_import_ind                      => NULL,
      x_export_ind                      => NULL,
      x_labor_surplus_ind               => NULL,
      x_debarment_ind                   => NULL,
      x_minority_owned_ind              => NULL,
      x_minority_owned_type             => NULL,
      x_woman_owned_ind                 => NULL,
      x_disadv_8a_ind                   => NULL,
      x_small_bus_ind                   => NULL,
      x_rent_own_ind                    => NULL,
      x_debarments_count                => NULL,
      x_debarments_date                 => NULL,
      x_failure_score                   => NULL,
      x_failure_score_override_code     => NULL,
      x_failure_score_commentary        => NULL,
      x_global_failure_score            => NULL,
      x_db_rating                       => NULL,
      x_credit_score                    => NULL,
      x_credit_score_commentary         => NULL,
      x_paydex_score                    => NULL,
      x_paydex_three_months_ago         => NULL,
      x_paydex_norm                     => NULL,
      x_best_time_contact_begin         => NULL,
      x_best_time_contact_end           => NULL,
      x_organization_name_phonetic      => NULL,
      x_tax_reference                   => NULL,
      x_gsa_indicator_flag              => NULL,
      x_jgzz_fiscal_code                => NULL,
      x_analysis_fy                     => NULL,
      x_fiscal_yearend_month            => NULL,
      x_curr_fy_potential_revenue       => NULL,
      x_next_fy_potential_revenue       => NULL,
      x_year_established                => NULL,
      x_mission_statement               => NULL,
      x_organization_type               => NULL,
      x_business_scope                  => NULL,
      x_corporation_class               => NULL,
      x_known_as                        => NULL,
      x_local_bus_iden_type             => NULL,
      x_local_bus_identifier            => NULL,
      x_pref_functional_currency        => NULL,
      x_registration_type               => NULL,
      x_total_employees_text            => NULL,
      x_total_employees_ind             => NULL,
      x_total_emp_est_ind               => NULL,
      x_total_emp_min_ind               => NULL,
      x_parent_sub_ind                  => NULL,
      x_incorp_year                     => NULL,
      x_content_source_type             => NULL,
      x_content_source_number           => NULL,
      x_effective_start_date            => NULL,
      x_effective_end_date              => NULL,
      x_sic_code_type                   => NULL,
      x_public_private_ownership        => NULL,
      x_local_activity_code_type        => NULL,
      x_local_activity_code             => NULL,
      x_emp_at_primary_adr              => NULL,
      x_emp_at_primary_adr_text         => NULL,
      x_emp_at_primary_adr_est_ind      => NULL,
      x_emp_at_primary_adr_min_ind      => NULL,
      x_internal_flag                   => NULL,
      x_high_credit                     => NULL,
      x_avg_high_credit                 => NULL,
      x_total_payments                  => NULL,
      x_known_as2                       => NULL,
      x_known_as3                       => NULL,
      x_known_as4                       => NULL,
      x_known_as5                       => NULL,
      x_credit_score_class              => NULL,
      x_credit_score_natl_percentile    => NULL,
      x_credit_score_incd_default       => NULL,
      x_credit_score_age                => NULL,
      x_credit_score_date               => NULL,
      x_failure_score_class             => NULL,
      x_failure_score_incd_default      => NULL,
      x_failure_score_age               => NULL,
      x_failure_score_date              => NULL,
      x_failure_score_commentary2       => NULL,
      x_failure_score_commentary3       => NULL,
      x_failure_score_commentary4       => NULL,
      x_failure_score_commentary5       => NULL,
      x_failure_score_commentary6       => NULL,
      x_failure_score_commentary7       => NULL,
      x_failure_score_commentary8       => NULL,
      x_failure_score_commentary9       => NULL,
      x_failure_score_commentary10      => NULL,
      x_credit_score_commentary2        => NULL,
      x_credit_score_commentary3        => NULL,
      x_credit_score_commentary4        => NULL,
      x_credit_score_commentary5        => NULL,
      x_credit_score_commentary6        => NULL,
      x_credit_score_commentary7        => NULL,
      x_credit_score_commentary8        => NULL,
      x_credit_score_commentary9        => NULL,
      x_credit_score_commentary10       => NULL,
      x_maximum_credit_recomm           => NULL,
      x_maximum_credit_currency_code    => NULL,
      x_displayed_duns_party_id         => NULL,
      x_failure_score_natnl_perc        => NULL,
      x_duns_number_c                   => NULL,
      x_bank_or_branch_number           => p_bank_or_branch_number,
      x_bank_code                       => p_bank_code,
      x_branch_code                     => p_branch_code,
      x_object_version_number           => NULL,
      x_created_by_module               => NULL,
      x_application_id                  => NULL,
      x_version_number                  => NULL,
      x_home_country                    => NULL
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_organization (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END update_bank_organization;

  /*=======================================================================+
   | PRIVATE PROCEDURE create_relationship                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a relationship between a bank branch and its parent bank.    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_relationship_v2pub.create_relationship                           |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE create_relationship (
    p_subject_id                IN      NUMBER,
    p_subject_type              IN      VARCHAR2,
    p_subject_table_name        IN      VARCHAR2,
    p_object_id                 IN      NUMBER,
    p_object_type               IN      VARCHAR2,
    p_object_table_name         IN      VARCHAR2,
    p_relationship_code         IN      VARCHAR2,
    p_relationship_type         IN      VARCHAR2,
    p_created_by_module         IN      VARCHAR2,
    p_application_id            IN      NUMBER,
    x_relationship_id           OUT NOCOPY     NUMBER,
    x_rel_party_id              OUT NOCOPY     NUMBER,
    x_rel_party_number          OUT NOCOPY     NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
    l_relationship_rec          hz_relationship_v2pub.relationship_rec_type;
    l_debug_prefix              VARCHAR2(30) := '';
  BEGIN
    l_relationship_rec.relationship_id := NULL;
    l_relationship_rec.subject_id := p_subject_id;
    l_relationship_rec.subject_type := p_subject_type;
    l_relationship_rec.subject_table_name := p_subject_table_name;
    l_relationship_rec.object_id := p_object_id;
    l_relationship_rec.object_type := p_object_type;
    l_relationship_rec.object_table_name := p_object_table_name;
    l_relationship_rec.relationship_code := p_relationship_code;
    l_relationship_rec.relationship_type := p_relationship_type;
    l_relationship_rec.start_date := SYSDATE;
    l_relationship_rec.end_date := NULL;
    l_relationship_rec.status := 'A';
    l_relationship_rec.comments := 'N/A';
    l_relationship_rec.content_source_type := 'USER_ENTERED';
    l_relationship_rec.attribute_category := NULL;
    l_relationship_rec.attribute1 := NULL;
    l_relationship_rec.attribute2 := NULL;
    l_relationship_rec.attribute3 := NULL;
    l_relationship_rec.attribute4 := NULL;
    l_relationship_rec.attribute5 := NULL;
    l_relationship_rec.attribute6 := NULL;
    l_relationship_rec.attribute7 := NULL;
    l_relationship_rec.attribute8 := NULL;
    l_relationship_rec.attribute9 := NULL;
    l_relationship_rec.attribute10 := NULL;
    l_relationship_rec.attribute11 := NULL;
    l_relationship_rec.attribute12 := NULL;
    l_relationship_rec.attribute13 := NULL;
    l_relationship_rec.attribute14 := NULL;
    l_relationship_rec.attribute15 := NULL;
    l_relationship_rec.attribute16 := NULL;
    l_relationship_rec.attribute17 := NULL;
    l_relationship_rec.attribute18 := NULL;
    l_relationship_rec.attribute19 := NULL;
    l_relationship_rec.attribute20 := NULL;
    l_relationship_rec.created_by_module := p_created_by_module;
    l_relationship_rec.application_id := p_application_id;

    hz_relationship_v2pub.create_relationship(
      p_relationship_rec        => l_relationship_rec,
      x_relationship_id         => x_relationship_id,
      x_party_id                => x_rel_party_id,
      x_party_number            => x_rel_party_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );
  END create_relationship;

  /*=======================================================================+
   | PRIVATE PROCEDURE update_relationship                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a relationship between a bank branch and its parent bank.    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_relationship_v2pub.update_relationship                           |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   +=======================================================================*/
  PROCEDURE update_relationship (
    p_relationship_id           IN OUT NOCOPY  NUMBER,
    p_subject_id                IN      NUMBER,
    p_subject_type              IN      VARCHAR2,
    p_subject_table_name        IN      VARCHAR2,
    p_object_id                 IN      NUMBER,
    p_object_type               IN      VARCHAR2,
    p_object_table_name         IN      VARCHAR2,
    p_relationship_code         IN      VARCHAR2,
    p_relationship_type         IN      VARCHAR2,
    p_created_by_module         IN      VARCHAR2,
    p_application_id            IN      NUMBER,
    x_rel_party_id              OUT NOCOPY     NUMBER,
    x_rel_party_number          OUT NOCOPY     NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
    CURSOR c_rel IS
      SELECT NVL(p_subject_id, hr.subject_id),
             NVL(p_object_id, hr.object_id),
             hr.object_version_number
      FROM   hz_relationships hr
      WHERE  hr.relationship_id = p_relationship_id
             AND SYSDATE BETWEEN TRUNC(hr.start_date)
                                   AND NVL(hr.end_date, SYSDATE+1)
             AND hr.relationship_type = p_relationship_type
      ORDER BY 3 DESC;

    l_subject_id                NUMBER(15);
    l_object_id                 NUMBER(15);
    l_status                    VARCHAR2(1);
    l_relationship_rec          hz_relationship_v2pub.relationship_rec_type;
    l_robject_version_number    NUMBER;
    l_rel_party_version_number  NUMBER;
    l_debug_prefix              VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_relationship (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- If either the subject or object is null, then this record is being
    -- deactivated.  Get the appropriate subject and/or object and set the
    -- activation status.
    IF p_subject_id IS NOT NULL
       OR p_object_id IS NOT NULL
    THEN
      OPEN c_rel;
      FETCH c_rel INTO l_subject_id, l_object_id, l_robject_version_number;
      IF c_rel%NOTFOUND THEN
        CLOSE c_rel;
        fnd_message.set_name('AR', 'HZ_API_NO_RECORD');
        fnd_message.set_token('RECORD', 'relationship');
        fnd_message.set_token('VALUE', TO_CHAR(p_relationship_id));
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;

        -- Debug info.
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug(p_message=>'update_bank_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- no point going any further, this is an invalid record
        RETURN;
      END IF;
      CLOSE c_rel;
      l_status := 'I';
    ELSE
      l_subject_id := p_subject_id;
      l_object_id  := p_object_id;
      l_status     := 'A';
    END IF;

    --
    -- Invalidate the old relationship.
    --
    l_relationship_rec.relationship_id := p_relationship_id;
    l_relationship_rec.subject_id := NULL;
    l_relationship_rec.subject_type := NULL;
    l_relationship_rec.subject_table_name := NULL;
    l_relationship_rec.object_id := NULL;
    l_relationship_rec.object_type := NULL;
    l_relationship_rec.object_table_name := NULL;
    l_relationship_rec.relationship_code := NULL;
    l_relationship_rec.relationship_type := NULL;
    l_relationship_rec.start_date := NULL;
    l_relationship_rec.end_date := SYSDATE;
    l_relationship_rec.status := l_status;
    l_relationship_rec.comments := NULL;
    l_relationship_rec.content_source_type := 'USER_ENTERED';
    l_relationship_rec.attribute_category := NULL;
    l_relationship_rec.attribute1 := NULL;
    l_relationship_rec.attribute2 := NULL;
    l_relationship_rec.attribute3 := NULL;
    l_relationship_rec.attribute4 := NULL;
    l_relationship_rec.attribute5 := NULL;
    l_relationship_rec.attribute6 := NULL;
    l_relationship_rec.attribute7 := NULL;
    l_relationship_rec.attribute8 := NULL;
    l_relationship_rec.attribute9 := NULL;
    l_relationship_rec.attribute10 := NULL;
    l_relationship_rec.attribute11 := NULL;
    l_relationship_rec.attribute12 := NULL;
    l_relationship_rec.attribute13 := NULL;
    l_relationship_rec.attribute14 := NULL;
    l_relationship_rec.attribute15 := NULL;
    l_relationship_rec.attribute16 := NULL;
    l_relationship_rec.attribute17 := NULL;
    l_relationship_rec.attribute18 := NULL;
    l_relationship_rec.attribute19 := NULL;
    l_relationship_rec.attribute20 := NULL;
    l_relationship_rec.created_by_module := p_created_by_module;
    l_relationship_rec.application_id := p_application_id;

    hz_relationship_v2pub.update_relationship(
      p_relationship_rec                => l_relationship_rec,
      p_object_version_number           => l_robject_version_number,
      p_party_object_version_number     => l_rel_party_version_number,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- finish execution if the relationship creation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
      RETURN;
    END IF;

    --
    -- create the new relationship.
    --
    l_relationship_rec.relationship_id := NULL;
    l_relationship_rec.subject_id := l_subject_id;
    l_relationship_rec.subject_type := p_subject_type;
    l_relationship_rec.subject_table_name := p_subject_table_name;
    l_relationship_rec.object_id := l_object_id;
    l_relationship_rec.object_type := p_object_type;
    l_relationship_rec.object_table_name := p_object_table_name;
    l_relationship_rec.relationship_code := p_relationship_code;
    l_relationship_rec.relationship_type := p_relationship_type;
    l_relationship_rec.start_date := SYSDATE;
    l_relationship_rec.end_date := NULL;
    p_relationship_id := NULL;

    hz_relationship_v2pub.create_relationship(
      p_relationship_rec                => l_relationship_rec,
      x_relationship_id                 => p_relationship_id,
      x_party_id                        => x_rel_party_id,
      x_party_number                    => x_rel_party_number,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_relationship (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END update_relationship;

  /*=======================================================================+
   | PRIVATE PROCEDURE create_code_assignment                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a code assignment for the bank organization.                 |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_classification_v2pub.create_code_assignment                      |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   |   23-JAN-2004    Rajesh Jose        Added parameter for Bug 3397488   |
   +=======================================================================*/
  PROCEDURE create_code_assignment (
    p_party_id                  IN      NUMBER,
    p_bank_organization_type    IN      VARCHAR2,
    p_class_category            IN      VARCHAR2,
    p_created_by_module         IN      VARCHAR2,
    p_application_id            IN      NUMBER,
    p_end_date_active           IN      DATE,
    x_code_assignment_id        OUT NOCOPY     NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
    l_code_assignment_rec   hz_classification_v2pub.code_assignment_rec_type;
    l_code_assignment_id    NUMBER(15);
    l_debug_prefix          VARCHAR2(30) := '';
  BEGIN
    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_code_assignment (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- set up the code assignment record.
    l_code_assignment_rec.code_assignment_id := NULL;
    l_code_assignment_rec.owner_table_name   := 'HZ_PARTIES';
    l_code_assignment_rec.owner_table_id     := p_party_id;
    l_code_assignment_rec.class_category     := p_class_category;
    l_code_assignment_rec.class_code         := p_bank_organization_type;
    l_code_assignment_rec.primary_flag       := 'Y';
    l_code_assignment_rec.start_date_active  := SYSDATE;
    l_code_assignment_rec.status             := 'A';
    l_code_assignment_rec.created_by_module  := p_created_by_module;
    l_code_assignment_rec.application_id     := p_application_id;
    l_code_assignment_rec.end_date_active    := p_end_date_active;

    hz_classification_v2pub.create_code_assignment(
      p_init_msg_list           => fnd_api.g_false,
      p_code_assignment_rec     => l_code_assignment_rec,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_code_assignment_id      => x_code_assignment_id
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_code_assignment (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END create_code_assignment;

  /*=======================================================================+
   | PRIVATE PROCEDURE update_code_assignment                              |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a code assignment for the bank organization.                 |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_classification_v2pub.update_code_assignment                      |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar      Created.                          |
   |   23-JAN-2004    Rajesh Jose        Added parameter for Bug 3397488   |
   |   11-OCT-2004    V.Ravichandran     Bug 3937348. Modified code        |
   |                                     such that the inactive_date       |
   |                                     could be updated in               |
   |                                     update_bank and update_bank_branch|
   |                                     APIs.                             |
   +=======================================================================*/
  PROCEDURE update_code_assignment (
    p_party_id                  IN      NUMBER,
    p_bank_organization_type    IN      VARCHAR2,
    p_class_category            IN      VARCHAR2,
    p_created_by_module         IN      VARCHAR2,
    p_application_id            IN      NUMBER,
    p_end_date_active           IN      DATE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
    l_code_assignment_rec   hz_classification_v2pub.code_assignment_rec_type;
    l_code_assignment_id    NUMBER(15);
    l_debug_prefix          VARCHAR2(30) := '';
    l_class_code            l_code_assignment_rec.class_code%type;
    l_end_date              date;

    CURSOR c_assignid IS
      SELECT hca.code_assignment_id,
             hca.object_version_number
      FROM   hz_code_assignments hca
      WHERE  hca.class_category = p_class_category
        AND  hca.owner_table_name = 'HZ_PARTIES'
        AND  hca.owner_table_id = p_party_id
        AND  hca.primary_flag='Y'
        AND  sysdate between start_date_active and nvl(end_date_active,sysdate+1)
        AND  hca.status = 'A';

    CURSOR c_assignid1 IS
      SELECT hca.code_assignment_id,
             hca.object_version_number
      FROM   hz_code_assignments hca
      WHERE  hca.class_category = p_class_category
        AND  hca.owner_table_name = 'HZ_PARTIES'
        AND  hca.owner_table_id = p_party_id
        AND  hca.class_code = p_bank_organization_type;

    CURSOR c_assignid2 IS
      SELECT hca.code_assignment_id,
             hca.object_version_number
      FROM   hz_code_assignments hca
      WHERE  hca.class_category = p_class_category
        AND  hca.owner_table_name = 'HZ_PARTIES'
        AND  hca.owner_table_id = p_party_id
        AND  hca.primary_flag='Y'
        AND  (p_bank_organization_type is null or
              p_bank_organization_type = hca.class_code);

  BEGIN

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_code_assignment (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- update existing assignment
    OPEN c_assignid2;
    FETCH c_assignid2 INTO
      l_code_assignment_id, p_object_version_number;

    IF c_assignid2%FOUND THEN
      l_code_assignment_rec.code_assignment_id := l_code_assignment_id;
      l_code_assignment_rec.end_date_active := p_end_date_active;

      hz_classification_v2pub.update_code_assignment(
        p_init_msg_list           => fnd_api.g_false,
        p_code_assignment_rec     => l_code_assignment_rec,
        p_object_version_number   => p_object_version_number,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

    ELSIF p_bank_organization_type IS NOT NULL AND
          p_bank_organization_type <> fnd_api.g_miss_char
    THEN
      -- inactivate the existing active assignment
      IF p_end_date_active IS NOT NULL AND
         p_end_date_active > SYSDATE OR
         p_end_date_active IS NULL OR
         p_end_date_active = fnd_api.g_miss_date
      THEN
        OPEN c_assignid;
        FETCH c_assignid INTO
          l_code_assignment_id, p_object_version_number;

        IF c_assignid%FOUND THEN
          l_code_assignment_rec := null;
          l_code_assignment_rec.code_assignment_id := l_code_assignment_id;
          l_code_assignment_rec.end_date_active := sysdate-10/(24*60*60);
          l_code_assignment_rec.primary_flag := 'N';

          hz_classification_v2pub.update_code_assignment(
            p_init_msg_list           => fnd_api.g_false,
            p_code_assignment_rec     => l_code_assignment_rec,
            p_object_version_number   => p_object_version_number,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data
          );

        END IF;
        CLOSE c_assignid;
      END IF;

      -- create new assignment if there is no existing one
      OPEN c_assignid1;
      FETCH c_assignid1 INTO
        l_code_assignment_id, p_object_version_number;

      IF c_assignid1%NOTFOUND THEN
        l_code_assignment_rec := null;
        l_code_assignment_rec.owner_table_name   := 'HZ_PARTIES';
        l_code_assignment_rec.owner_table_id     := p_party_id;
        l_code_assignment_rec.class_category     := p_class_category;
        l_code_assignment_rec.class_code         := p_bank_organization_type;
        l_code_assignment_rec.primary_flag       := 'Y';
        l_code_assignment_rec.created_by_module  := nvl(p_created_by_module,'TCA_V2_API');
        l_code_assignment_rec.application_id     := p_application_id;
        l_code_assignment_rec.end_date_active    := p_end_date_active;

        hz_classification_v2pub.create_code_assignment(
          p_init_msg_list           => fnd_api.g_false,
          p_code_assignment_rec     => l_code_assignment_rec,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data,
          x_code_assignment_id      => l_code_assignment_id
        );

      ELSE
        l_code_assignment_rec := null;
        l_code_assignment_rec.code_assignment_id := l_code_assignment_id;
        l_code_assignment_rec.end_date_active := p_end_date_active;
        l_code_assignment_rec.primary_flag       := 'Y';

        hz_classification_v2pub.update_code_assignment(
          p_init_msg_list           => fnd_api.g_false,
          p_code_assignment_rec     => l_code_assignment_rec,
          p_object_version_number   => p_object_version_number,
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data
        );

      END IF;
    END IF;
    CLOSE c_assignid2;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_code_assignment (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;
  END update_code_assignment;


  /*=======================================================================+
   | PRIVATE PROCEDURE assign_party_usage                                  |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a usage assignment.                                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   +=======================================================================*/

  PROCEDURE assign_party_usage (
    p_party_id                  IN     NUMBER,
    p_institution_type          IN     VARCHAR2,
    p_end_date_active           IN     DATE,
    x_return_status             IN OUT NOCOPY VARCHAR2
  ) IS

    l_party_usg_assignment_rec  HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

  BEGIN

      l_party_usg_assignment_rec.party_id := p_party_id;
      l_party_usg_assignment_rec.party_usage_code := p_institution_type;
      l_party_usg_assignment_rec.created_by_module := 'TCA_V2_API';
      l_party_usg_assignment_rec.effective_end_date := p_end_date_active;

      IF p_end_date_active IS NOT NULL AND
         trunc(p_end_date_active) < trunc(sysdate) AND
         p_end_date_active <> FND_API.G_MISS_DATE
      THEN
        l_party_usg_assignment_rec.effective_start_date := p_end_date_active;
      END IF;

      HZ_PARTY_USG_ASSIGNMENT_PVT.assign_party_usage (
        p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE,
        p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
        x_return_status             => x_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data
      );

  END assign_party_usage;


  /*=======================================================================+
   | PRIVATE PROCEDURE update_usage_assignment                                  |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a usage assignment.                                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   +=======================================================================*/

  PROCEDURE update_usage_assignment (
    p_party_id                  IN     NUMBER,
    p_end_date_active           IN     DATE,
    x_return_status             IN OUT NOCOPY VARCHAR2
  ) IS

    l_party_usg_assignment_rec  HZ_PARTY_USG_ASSIGNMENT_PVT.party_usg_assignment_rec_type;
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_class_code                VARCHAR2(30);
    l_end_date_active           DATE;
    l_assignment_id             NUMBER;

    CURSOR c_party_usage_code IS
    SELECT hca.class_code
    FROM   hz_code_assignments hca
    WHERE  hca.class_category = 'BANK_INSTITUTION_TYPE'
    AND    hca.owner_table_name = 'HZ_PARTIES'
    AND    hca.owner_table_id = p_party_id
    AND    hca.status = 'A';

    CURSOR c_party_usage_date (
      p_party_usage_code          VARCHAR2
    ) IS
    SELECT party_usg_assignment_id,
           effective_end_date
    FROM   hz_party_usg_assignments
    WHERE  party_id = p_party_id
    AND    party_usage_code = p_party_usage_code;

  BEGIN

    -- per email exchanges with Amrita in CE.
    -- institution type can never be updated through ui.

    OPEN c_party_usage_code;
    FETCH c_party_usage_code INTO l_class_code;
    CLOSE c_party_usage_code;

    IF l_class_code IN ('BANK','CLEARINGHOUSE','BANK_BRANCH','CLEARINGHOUSE_BRANCH')
    THEN
      OPEN c_party_usage_date(l_class_code);
      FETCH c_party_usage_date INTO l_assignment_id, l_end_date_active;
      CLOSE c_party_usage_date;

      IF p_end_date_active <> fnd_api.g_miss_date AND
         l_end_date_active = TO_DATE('4712/12/31','YYYY/MM/DD') OR
         p_end_date_active = fnd_api.g_miss_date AND
         l_end_date_active <> TO_DATE('4712/12/31','YYYY/MM/DD') OR
         trunc(p_end_date_active) <> l_end_date_active
      THEN
        l_party_usg_assignment_rec.party_id := p_party_id;
        l_party_usg_assignment_rec.party_usage_code := l_class_code;
        l_party_usg_assignment_rec.effective_end_date := trunc(p_end_date_active);

        HZ_PARTY_USG_ASSIGNMENT_PVT.update_usg_assignment (
          p_validation_level          => HZ_PARTY_USG_ASSIGNMENT_PVT.G_VALID_LEVEL_NONE,
          p_party_usg_assignment_id   => l_assignment_id,
          p_party_usg_assignment_rec  => l_party_usg_assignment_rec,
          x_return_status             => x_return_status,
          x_msg_count                 => l_msg_count,
          x_msg_data                  => l_msg_data
        );
      END IF;
    END IF;

  END update_usage_assignment;


  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank organization and its type via a code assignment.      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_organization                                  |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_bank_rec           Bank record.                                 |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_id           Party ID for the bank.                       |
   |     x_party_number       Party number for the bank.                   |
   |     x_profile_id         Organization profile ID for the bank.        |
   |     x_code_assignment_id The code assignment ID for the bank          |
   |                          classification.                              |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   |   23-JAN-2004    Rajesh Jose       Modified for Bug 3397488           |
   +=======================================================================*/
  PROCEDURE create_bank (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    x_party_id                  OUT NOCOPY     NUMBER,
    x_party_number              OUT NOCOPY     VARCHAR2,
    x_profile_id                OUT NOCOPY     NUMBER,
    x_code_assignment_id        OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                        VARCHAR2(30) := '';
  l_bank_rec                            bank_rec_type;
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_bank;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    l_bank_rec := p_bank_rec;
    l_bank_rec.organization_rec.home_country := l_bank_rec.country;

    validate_bank_org(l_bank_rec, 'BANK', g_insert, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Retrieving the party_id that we are using to create the bank record.
    select temp_id into l_bank_rec.organization_rec.party_rec.party_id
    from hz_bank_val_gt;

    -- create the organization profile.
    hz_party_v2pub.create_organization(
      p_organization_rec        => l_bank_rec.organization_rec,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_party_id                => x_party_id,
      x_party_number            => x_party_number,
      x_profile_id              => x_profile_id
    );

    -- raise an exception if the organization profile creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the bank-specific organization attributes
    update_bank_organization(x_profile_id,
                             l_bank_rec.bank_or_branch_number,
                             l_bank_rec.bank_code,
                             l_bank_rec.branch_code);

    -- create the code assignment for the bank's institution type
    create_code_assignment(x_party_id,
                           l_bank_rec.institution_type,
                           'BANK_INSTITUTION_TYPE',
                           l_bank_rec.organization_rec.created_by_module,
                           l_bank_rec.organization_rec.application_id,
                           l_bank_rec.inactive_date,
                           x_code_assignment_id,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);

    -- raise an exception if the code assignment creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- added for R12 party usage project.
    --
    IF l_bank_rec.institution_type IN ('BANK', 'CLEARINGHOUSE') THEN
      assign_party_usage (
        p_party_id                  => x_party_id,
        p_institution_type          => l_bank_rec.institution_type,
        p_end_date_active           => l_bank_rec.inactive_date,
        x_return_status             => x_return_status
      );

      -- raise an exception if the usage assignment creation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug(p_message=>'create_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;


      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_bank;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank organization and update its type if the type was      |
   |   specified.                                                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_organization                                  |
   |   hz_organization_profiles_pkg.update_row                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list                Initialize message stack if it is  |
   |                                    set to FND_API.G_TRUE. Default is  |
   |                                    fnd_api.g_false.                   |
   |     p_bank_rec                     Bank record.                       |
   |   IN/OUT:                                                             |
   |     x_pobject_version_number       New version number for the bank.   |
   |     x_bitobject_version_number     New version number for the code    |
   |                                    assignment for the bank type.      |
   |   OUT:                                                                |
   |     x_profile_id                   New organization profile ID for    |
   |                                    the updated bank.                  |
   |     x_return_status                Return status after the call. The  |
   |                                    status can be                      |
   |                                    FND_API.G_RET_STS_SUCCESS          |
   |                                    (success), fnd_api.g_ret_sts_error |
   |                                    (error),                           |
   |                                    fnd_api.g_ret_sts_unexp_error      |
   |                                    (unexpected error).                |
   |     x_msg_count                    Number of messages in message      |
   |                                    stack.                             |
   |     x_msg_data                     Message text if x_msg_count is 1.  |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   |   23-JAN-2004    Rajesh Jose       Modified for Bug 3397488           |
   |   11-OCT-2004    V.Ravichandran     Bug 3937348. Modified code        |
   |                                     such that the inactive_date       |
   |                                     could be updated in               |
   |                                     update_bank and update_bank_branch|
   |                                     APIs.                             |
   +=======================================================================*/
  PROCEDURE update_bank (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    p_pobject_version_number    IN OUT NOCOPY  NUMBER,
    p_bitobject_version_number  IN OUT NOCOPY  NUMBER,
    x_profile_id                OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
    l_party_id  NUMBER(15) := p_bank_rec.organization_rec.party_rec.party_id;
    l_debug_prefix                     VARCHAR2(30) := '';
    l_bank_rec                  bank_rec_type;

  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_bank;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    l_bank_rec := p_bank_rec;
    l_bank_rec.organization_rec.home_country := l_bank_rec.country;

    --
    -- execute business logic
    --

    validate_bank_org(l_bank_rec, 'BANK', g_update, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the organization profile.
    hz_party_v2pub.update_organization(
      p_organization_rec                => l_bank_rec.organization_rec,
      p_party_object_version_number     => p_pobject_version_number,
      x_profile_id                      => x_profile_id,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- raise an exception if the organization profile creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the bank-specific organization attributes
    update_bank_organization(x_profile_id,
                             l_bank_rec.bank_or_branch_number,
                             l_bank_rec.bank_code,
                             l_bank_rec.branch_code);

    -- update the code assignment for the bank's institution type IF
    -- the institution_type is specified.
    --IF p_bank_rec.institution_type IS NOT NULL THEN /* Bug 3937348 */
      update_code_assignment(l_party_id,
                             l_bank_rec.institution_type,
                             'BANK_INSTITUTION_TYPE',
                             l_bank_rec.organization_rec.created_by_module,
                             l_bank_rec.organization_rec.application_id,
                             l_bank_rec.inactive_date,
                             p_bitobject_version_number,
                             x_return_status,
                             x_msg_count,
                             x_msg_data);

      -- raise an exception if the code assignment creation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    --END IF;

    --
    -- added for R12 party usage project.
    --
    IF l_bank_rec.inactive_date IS NOT NULL THEN
      update_usage_assignment (
        p_party_id                => l_party_id,
        p_end_date_active         => l_bank_rec.inactive_date,
        x_return_status           => x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_bank (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_bank;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank branch organization.                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_organization                                  |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_bank_rec           Bank record.                                 |
   |     p_bank_party_id      Party ID of the parent bank.  NULL if the    |
   |                          parent bank is not going to be reassigned.   |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_id           Party ID for the bank branch.                |
   |     x_party_number       Party number for the bank branch.            |
   |     x_profile_id         Organization profile ID for the bank branch. |
   |     x_relationship_id    ID for the relationship between the branch   |
   |                          and its parent bank.                         |
   |     x_rel_party_id       ID for party relationship created.           |
   |     x_rel_party_number   Number for the party relationship created.   |
   |     x_bitcode_assignment_id The code assignment ID for the bank org   |
   |                          classification as a BRANCH.                  |
   |     x_bbtcode_assignment_id The code assignment ID for the type of    |
   |                          bank branch.                                 |
   |     x_rfccode_assignment_id The code assignment ID for the Regional   |
   |                          Finance Center used by the bank branch.      |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   |   06-MAY-2002    J. del Callar     Added support for RFCs.            |
   |   23-JAN-2004    Rajesh Jose       Modified for Bug 3397488           |
   +=======================================================================*/
  PROCEDURE create_bank_branch (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    p_bank_party_id             IN      NUMBER,
    x_party_id                  OUT NOCOPY     NUMBER,
    x_party_number              OUT NOCOPY     VARCHAR2,
    x_profile_id                OUT NOCOPY     NUMBER,
    x_relationship_id           OUT NOCOPY     NUMBER,
    x_rel_party_id              OUT NOCOPY     NUMBER,
    x_rel_party_number          OUT NOCOPY     NUMBER,
    x_bitcode_assignment_id     OUT NOCOPY     NUMBER,
    x_bbtcode_assignment_id     OUT NOCOPY     NUMBER,
    x_rfccode_assignment_id     OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                        VARCHAR2(30) := '';
  l_bank_rec                            bank_rec_type;
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_bank_branch;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank_branch (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    l_bank_rec := p_bank_rec;
    l_bank_rec.organization_rec.home_country := l_bank_rec.country;

    -- ensure that the parent is a valid bank or clearinghouse.
    validate_parent_bank(l_bank_rec,
                         p_bank_party_id,
                         g_insert,
                         x_return_status);

    -- validate the bank branch and its type.
    validate_bank_org(l_bank_rec, 'BRANCH', g_insert, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Retrieving the party_id that we are using to create the bank record.

    select temp_id into l_bank_rec.organization_rec.party_rec.party_id
    from hz_bank_val_gt;

    -- create the organization profile.
    hz_party_v2pub.create_organization(
      p_organization_rec        => l_bank_rec.organization_rec,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data,
      x_party_id                => x_party_id,
      x_party_number            => x_party_number,
      x_profile_id              => x_profile_id
    );

    -- raise an exception if the organization profile creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the bank-specific organization attributes
    update_bank_organization(x_profile_id,
                             l_bank_rec.bank_or_branch_number,
                             l_bank_rec.bank_code,
                             l_bank_rec.branch_code);

    -- create the code assignment for the bank branch's institution type
    create_code_assignment(x_party_id,
                           l_bank_rec.institution_type,
                           'BANK_INSTITUTION_TYPE',
                           l_bank_rec.organization_rec.created_by_module,
                           l_bank_rec.organization_rec.application_id,
                           l_bank_rec.inactive_date,
                           x_bitcode_assignment_id,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);

    --Bug9226202 Instead of Parameter's Inactive Date G_MISS_DATE will be provided
    -- create the code assignment for the bank branch's branch type
     IF l_bank_rec.branch_type IS NOT NULL
        AND l_bank_rec.branch_type <> fnd_api.g_miss_char
     THEN
      create_code_assignment(x_party_id,
                           l_bank_rec.branch_type,
                           'BANK_BRANCH_TYPE',
                           l_bank_rec.organization_rec.created_by_module,
                           l_bank_rec.organization_rec.application_id,
--                           l_bank_rec.inactive_date,
                           FND_API.G_MISS_DATE,
                           x_bbtcode_assignment_id,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);
     END IF;

    --Bug9226202 Instead of Parameter's Inactive Date G_MISS_DATE will be provided
    IF l_bank_rec.rfc_code IS NOT NULL THEN
      -- create the code assignment for the bank branch's RFC
      create_code_assignment(x_party_id,
                             l_bank_rec.rfc_code,
                             'RFC_IDENTIFIER',
                             l_bank_rec.organization_rec.created_by_module,
                             l_bank_rec.organization_rec.application_id,
--                             l_bank_rec.inactive_date,
                             FND_API.G_MISS_DATE,
                             x_rfccode_assignment_id,
                             x_return_status,
                             x_msg_count,
                             x_msg_data);
    END IF;

    -- raise an exception if the code assignment creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create a relationship between the bank branch and its parent bank
    create_relationship(
      p_subject_id          => p_bank_party_id,
      p_subject_type        => 'ORGANIZATION',
      p_subject_table_name  => 'HZ_PARTIES',
      p_object_id           => x_party_id,
      p_object_type         => 'ORGANIZATION',
      p_object_table_name   => 'HZ_PARTIES',
      p_relationship_code   => 'HAS_BRANCH',
      p_relationship_type   => 'BANK_AND_BRANCH',
      p_created_by_module   => l_bank_rec.organization_rec.created_by_module,
      p_application_id      => l_bank_rec.organization_rec.application_id,
      x_relationship_id     => x_relationship_id,
      x_rel_party_id        => x_rel_party_id,
      x_rel_party_number    => x_rel_party_number,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data
    );

    -- raise an exception if the relationship creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- added for R12 party usage project.
    --
    IF l_bank_rec.institution_type IN ('BANK_BRANCH', 'CLEARINGHOUSE_BRANCH') THEN
      assign_party_usage (
        p_party_id                  => x_party_id,
        p_institution_type          => l_bank_rec.institution_type,
        p_end_date_active           => l_bank_rec.inactive_date,
        x_return_status             => x_return_status
      );

      -- raise an exception if the usage assignment creation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_branch;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
          hz_utility_v2pub.debug(p_message=>'create_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug(p_message=>'create_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_bank_branch;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank branch organization.                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_organization                                  |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_bank_rec           Bank record.                                 |
   |     p_relationship_id    ID for relationship between bank branch and  |
   |                          its parent bank.  NULL if the parent bank is |
   |                          not going to be reassigned.                  |
   |     p_bank_party_id      Party ID of the parent bank.  NULL if the    |
   |                          parent bank is not going to be reassigned.   |
   |   IN/OUT:                                                             |
   |     p_pobject_version_number       New version number for the bank    |
   |                                    branch party.                      |
   |     p_bbtobject_version_number     New version number for the bank    |
   |                                    branch type code assignment.       |
   |     p_rfcobject_version_number     New version number for the Regional|
   |                                    Finance Center code assignment.    |
   |   OUT:                                                                |
   |     x_profile_id         Organization profile ID for the bank branch. |
   |     x_rel_party_id       ID for party relationship created.           |
   |     x_rel_party_number   Number for the party relationship created.   |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   |   06-MAY-2002    J. del Callar     Added support for RFCs.            |
   |   11-OCT-2004    V.Ravichandran     Bug 3937348. Modified code        |
   |                                     such that the inactive_date       |
   |                                     could be updated in               |
   |                                     update_bank and update_bank_branch|
   |                                     APIs.                             |
   +=======================================================================*/
  PROCEDURE update_bank_branch (
    p_init_msg_list             IN      VARCHAR2        := fnd_api.g_false,
    p_bank_rec                  IN      bank_rec_type,
    p_bank_party_id             IN      NUMBER          := NULL,
    p_relationship_id           IN OUT NOCOPY  NUMBER,
    p_pobject_version_number    IN OUT NOCOPY  NUMBER,
    p_bbtobject_version_number  IN OUT NOCOPY  NUMBER,
    p_rfcobject_version_number  IN OUT NOCOPY  NUMBER,
    x_profile_id                OUT NOCOPY     NUMBER,
    x_rel_party_id              OUT NOCOPY     NUMBER,
    x_rel_party_number          OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS

  l_debug_prefix                       VARCHAR2(30) := '';
    l_bank_rec                         bank_rec_type;

  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_bank_branch;
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_branch (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    l_bank_rec := p_bank_rec;
    l_bank_rec.organization_rec.home_country := l_bank_rec.country;

    --
    -- execute business logic
    --

    -- ensure that the parent is a valid bank or clearinghouse.
    validate_parent_bank(l_bank_rec,
                         p_bank_party_id,
                         g_update,
                         x_return_status);

    -- validate the bank branch and its type.
    validate_bank_org(l_bank_rec, 'BRANCH', g_update, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the organization profile.
    hz_party_v2pub.update_organization(
      p_organization_rec                => l_bank_rec.organization_rec,
      p_party_object_version_number     => p_pobject_version_number,
      x_profile_id                      => x_profile_id,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- raise an exception if the organization profile update is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the bank-specific organization attributes
    update_bank_organization(x_profile_id,
                             l_bank_rec.bank_or_branch_number,
                             l_bank_rec.bank_code,
                             l_bank_rec.branch_code);

      -- Bug 5147118. Updated the code assignment for Bank Institutio type.
      update_code_assignment(l_bank_rec.organization_rec.party_rec.party_id,
                             l_bank_rec.institution_type,
                             'BANK_INSTITUTION_TYPE',
                             l_bank_rec.organization_rec.created_by_module,
                             l_bank_rec.organization_rec.application_id,
                             l_bank_rec.inactive_date,
                             p_pobject_version_number,
                             x_return_status,
                             x_msg_count,
                             x_msg_data);

      -- raise an exception if the code assignment updation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;


   -- update the code assignment for the bank branch's branch type if a bank
    -- branch type was specified.
    --IF p_bank_rec.branch_type IS NOT NULL THEN /* Bug 3937348 */
    --Bug9226202 Instead of Parameter's Inactive Date G_MISS_DATE will be provided
      update_code_assignment(l_bank_rec.organization_rec.party_rec.party_id,
                             l_bank_rec.branch_type,
                             'BANK_BRANCH_TYPE',
                             l_bank_rec.organization_rec.created_by_module,
                             l_bank_rec.organization_rec.application_id,
--                             l_bank_rec.inactive_date,
                             FND_API.G_MISS_DATE,
                             p_bbtobject_version_number,
                             x_return_status,
                             x_msg_count,
                             x_msg_data);
    --END IF;

      -- raise an exception if the code assignment updation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    -- update the code assignment for the bank branch's Regional Finance Center
    -- if an RFC was specified.
    --IF p_bank_rec.rfc_code IS NOT NULL THEN /* Bug 3937348 */
    --Bug9226202 Instead of Parameter's Inactive Date G_MISS_DATE will be provided
      update_code_assignment(l_bank_rec.organization_rec.party_rec.party_id,
                             l_bank_rec.rfc_code,
                             'RFC_IDENTIFIER',
                             l_bank_rec.organization_rec.created_by_module,
                             l_bank_rec.organization_rec.application_id,
--                             l_bank_rec.inactive_date,
                             FND_API.G_MISS_DATE,
                             p_rfcobject_version_number,
                             x_return_status,
                             x_msg_count,
                             x_msg_data);
    --END IF;

    -- raise an exception if the code assignment creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the relationship between the bank branch and its parent bank
    -- if the parent bank was specified.
    IF p_bank_party_id IS NOT NULL
       AND p_relationship_id IS NOT NULL
    THEN
      update_relationship(
        p_relationship_id             => p_relationship_id,
        p_subject_id                  => p_bank_party_id,
        p_subject_type                => 'ORGANIZATION',
        p_subject_table_name          => 'HZ_PARTIES',
        p_object_id                   =>
          l_bank_rec.organization_rec.party_rec.party_id,
        p_object_type                 => 'ORGANIZATION',
        p_object_table_name           => 'HZ_PARTIES',
        p_relationship_code           => 'HAS_BRANCH',
        p_relationship_type           => 'BANK_AND_BRANCH',
        p_created_by_module           =>
          l_bank_rec.organization_rec.created_by_module,
        p_application_id              =>
          l_bank_rec.organization_rec.application_id,
        x_rel_party_id                => x_rel_party_id,
        x_rel_party_number            => x_rel_party_number,
        x_return_status               => x_return_status,
        x_msg_count                   => x_msg_count,
        x_msg_data                    => x_msg_data
      );
    END IF;

    -- raise an exception if the relationship creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- added for R12 party usage project.
    --
    IF l_bank_rec.inactive_date IS NOT NULL THEN
      update_usage_assignment (
        p_party_id                => l_bank_rec.organization_rec.party_rec.party_id,
        p_end_date_active         => l_bank_rec.inactive_date,
        x_return_status           => x_return_status
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
         hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'WARNING',
                               p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_branch;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank_branch (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_bank_branch;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_banking_group                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a banking group.                                             |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_group_rec          Group record for the banking group.          |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_id           Party ID for the banking group created.      |
   |     x_party_number       Party number for banking group created.      |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_banking_group (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_group_rec                 IN      hz_party_v2pub.group_rec_type,
    x_party_id                  OUT NOCOPY     NUMBER,
    x_party_number              OUT NOCOPY     VARCHAR2,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_banking_group;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_banking_group (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group
    validate_banking_group(p_group_rec, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the banking group
    hz_party_v2pub.create_group(
      p_group_rec               => p_group_rec,
      x_party_id                => x_party_id,
      x_party_number            => x_party_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_banking_group;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_banking_group;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_banking_group;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_banking_group;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_banking_group                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a banking group.                                             |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_group_rec          Group record for the banking group.          |
   |   IN/OUT:                                                             |
   |     p_pobject_version_number Version number for the banking group     |
   |                          party that was created.                      |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE update_banking_group (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_group_rec                 IN      hz_party_v2pub.group_rec_type,
    p_pobject_version_number    IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_banking_group;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_banking_group (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group
    validate_banking_group(p_group_rec, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the banking group
    hz_party_v2pub.update_group(
      p_group_rec                       => p_group_rec,
      p_party_object_version_number     => p_pobject_version_number,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- raise an exception if the banking group update is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_banking_group;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_banking_group;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_banking_group;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_banking_group (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_banking_group;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_group_member                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a member relationship for a bank organization to a banking   |
   |   group.                                                              |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the banking group    |
   |                          membership.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_relationship_id    ID for the relationship record created.      |
   |     x_party_id           ID for the party created for the             |
   |                          relationship.                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_bank_group_member (
    p_init_msg_list     IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec  IN      hz_relationship_v2pub.relationship_rec_type,
    x_relationship_id   OUT NOCOPY     NUMBER,
    x_party_id          OUT NOCOPY     NUMBER,
    x_party_number      OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_bank_group_member;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank_group_member (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_bank_group_member(p_relationship_rec, g_insert, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the banking group membership
    hz_relationship_v2pub.create_relationship(
      p_relationship_rec        => p_relationship_rec,
      x_relationship_id         => x_relationship_id,
      x_party_id                => x_party_id,
      x_party_number            => x_party_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_group_member;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_group_member;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank_group_member;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_bank_group_member;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_group_member                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a member relationship for a bank organization to a banking   |
   |   group.                                                              |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the banking group    |
   |                          membership.                                  |
   |   IN/OUT:                                                             |
   |     p_robject_version_number       New version number for the banking |
   |                                    group membership relationship.     |
   |     p_pobject_version_number       New version number for the banking |
   |                                    group membership rel party.        |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Updated.                           |
   +=======================================================================*/
  PROCEDURE update_bank_group_member (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec          IN hz_relationship_v2pub.relationship_rec_type,
    p_robject_version_number    IN OUT NOCOPY  NUMBER,
    p_pobject_version_number    IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_bank_group_member;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_group_member (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_bank_group_member(p_relationship_rec, g_update, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the banking group membership
    hz_relationship_v2pub.update_relationship(
      p_relationship_rec                => p_relationship_rec,
      p_object_version_number           => p_robject_version_number,
      p_party_object_version_number     => p_pobject_version_number,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_group_member;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_group_member;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_bank_group_member;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank_group_member (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_bank_group_member;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_clearinghouse_assign                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Assign a bank to a clearinghouse by creating a relationship.        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the clearinghouse    |
   |                          assignment.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_relationship_id    ID for the relationship record created.      |
   |     x_party_id           ID for the party created for the             |
   |                          relationship.                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_clearinghouse_assign (
    p_init_msg_list     IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec  IN      hz_relationship_v2pub.relationship_rec_type,
    x_relationship_id   OUT NOCOPY     NUMBER,
    x_party_id          OUT NOCOPY     NUMBER,
    x_party_number      OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_clearinghouse_assign;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_clearinghouse_assign (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_clearinghouse_assign(p_relationship_rec,
                                  g_insert,
                                  x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the banking group membership
    hz_relationship_v2pub.create_relationship(
      p_relationship_rec        => p_relationship_rec,
      x_relationship_id         => x_relationship_id,
      x_party_id                => x_party_id,
      x_party_number            => x_party_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_clearinghouse_assign;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_clearinghouse_assign;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_clearinghouse_assign;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_clearinghouse_assign;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_clearinghouse_assign                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a relationship that assigns a bank to a clearinghouse.       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_relationship_rec   Relationship record for the clearinghouse    |
   |                          assignment.                                  |
   |   IN/OUT:                                                             |
   |     p_robject_version_number       New version number for the banking |
   |                                    group membership relationship.     |
   |     p_pobject_version_number       New version number for the banking |
   |                                    group membership rel party.        |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Updated.                           |
   +=======================================================================*/
  PROCEDURE update_clearinghouse_assign (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_relationship_rec          IN hz_relationship_v2pub.relationship_rec_type,
    p_robject_version_number    IN OUT NOCOPY  NUMBER,
    p_pobject_version_number    IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_clearinghouse_assign;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_clearinghouse_assign (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_clearinghouse_assign(p_relationship_rec,
                                  g_update,
                                  x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the banking group membership
    hz_relationship_v2pub.update_relationship(
      p_relationship_rec                => p_relationship_rec,
      p_object_version_number           => p_robject_version_number,
      p_party_object_version_number     => p_pobject_version_number,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_clearinghouse_assign;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_clearinghouse_assign;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_clearinghouse_assign;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_clearinghouse_assign (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_clearinghouse_assign;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_site                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a party site for a bank-type organization.                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_party_site_rec     Party site record for the bank organization. |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_party_site_id      ID for the party site created.               |
   |     x_party_site_number  Party site number for the bank site          |
   |                          created.                                     |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Created.                           |
   +=======================================================================*/
  PROCEDURE create_bank_site (
    p_init_msg_list     IN      VARCHAR2:= fnd_api.g_false,
    p_party_site_rec    IN      hz_party_site_v2pub.party_site_rec_type,
    x_party_site_id     OUT NOCOPY     NUMBER,
    x_party_site_number OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_bank_site;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_bank_site(p_party_site_rec, g_insert, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the banking group membership
    hz_party_site_v2pub.create_party_site(
      p_party_site_rec          => p_party_site_rec,
      x_party_site_id           => x_party_site_id,
      x_party_site_number       => x_party_site_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_site;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_site;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank_site;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_bank_site;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_site                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a party site for a bank-type organization.                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_group                                         |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false.  |
   |     p_party_site_rec     Party site record for the bank organization. |
   |   IN/OUT:                                                             |
   |     x_psobject_version_number  Party site version number for the      |
   |                          updated bank site.                           |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-NOV-2001    J. del Callar     Updated.                           |
   +=======================================================================*/
  PROCEDURE update_bank_site (
    p_init_msg_list             IN      VARCHAR2:= fnd_api.g_false,
    p_party_site_rec            IN hz_party_site_v2pub.party_site_rec_type,
    p_psobject_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_bank_site;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_site (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_bank_site(p_party_site_rec, g_update, x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the banking group membership
    hz_party_site_v2pub.update_party_site(
      p_party_site_rec          => p_party_site_rec,
      p_object_version_number   => p_psobject_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_site;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_site;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_bank_site;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_bank_site (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_bank_site;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_edi_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates an EDI contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_edi_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_edi_rec            EDI record.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_edi_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec           IN      hz_contact_point_v2pub.edi_rec_type
                                  := hz_contact_point_v2pub.g_miss_edi_rec,
    x_contact_point_id  OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_edi_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_edi_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_edi_contact_point(p_contact_point_rec,
                               p_edi_rec,
                               x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the EDI contact point
    hz_contact_point_v2pub.create_edi_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_edi_rec                 => p_edi_rec,
      x_contact_point_id        => x_contact_point_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_edi_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_edi_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_edi_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_edi_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_edi_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates an EDI contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_edi_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_edi_rec            EDI record.                                  |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_edi_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_edi_rec               IN  hz_contact_point_v2pub.edi_rec_type
                                  := hz_contact_point_v2pub.g_miss_edi_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_edi_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_edi_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_edi_contact_point(p_contact_point_rec,
                               p_edi_rec,
                               x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the EDI contact point
    hz_contact_point_v2pub.update_edi_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_edi_rec                 => p_edi_rec,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_edi_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_edi_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_edi_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_edi_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_edi_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_eft_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates an EFT contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_eft_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_eft_rec            EFT record.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_eft_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec           IN      hz_contact_point_v2pub.eft_rec_type
                                  := hz_contact_point_v2pub.g_miss_eft_rec,
    x_contact_point_id  OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_eft_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_eft_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_eft_contact_point(p_contact_point_rec,
                               p_eft_rec,
                               x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the EFT contact point
    hz_contact_point_v2pub.create_eft_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_eft_rec                 => p_eft_rec,
      x_contact_point_id        => x_contact_point_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_eft_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_eft_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_eft_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_eft_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_eft_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates an EFT contact point.                                       |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_eft_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_eft_rec            EFT record.                                  |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_eft_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_eft_rec               IN  hz_contact_point_v2pub.eft_rec_type
                                  := hz_contact_point_v2pub.g_miss_eft_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_eft_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_eft_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_eft_contact_point(p_contact_point_rec,
                               p_eft_rec,
                               x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the EFT contact point
    hz_contact_point_v2pub.update_eft_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_eft_rec                 => p_eft_rec,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_eft_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_eft_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_eft_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_eft_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_eft_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_web_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates a Web contact point.                                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_web_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_web_rec            WEB record.                                  |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_web_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec           IN      hz_contact_point_v2pub.web_rec_type
                                  := hz_contact_point_v2pub.g_miss_web_rec,
    x_contact_point_id  OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_web_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_web_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_web_contact_point(p_contact_point_rec,
                               p_web_rec,
                               x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the WEB contact point
    hz_contact_point_v2pub.create_web_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_web_rec                 => p_web_rec,
      x_contact_point_id        => x_contact_point_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_web_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_web_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_web_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_web_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_web_contact_point                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates a Web contact point.                                        |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_web_contact_point                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_web_rec            WEB record.                                  |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_web_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_web_rec               IN  hz_contact_point_v2pub.web_rec_type
                                  := hz_contact_point_v2pub.g_miss_web_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_web_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_web_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_web_contact_point(p_contact_point_rec,
                               p_web_rec,
                               x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the WEB contact point
    hz_contact_point_v2pub.update_web_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_web_rec                 => p_web_rec,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_web_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_web_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_web_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_web_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_web_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_phone_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates a Phone contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_phone_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_phone_rec          PHONE record.                                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_phone_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec         IN      hz_contact_point_v2pub.phone_rec_type
                                  := hz_contact_point_v2pub.g_miss_phone_rec,
    x_contact_point_id  OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_phone_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_phone_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_phone_contact_point(p_contact_point_rec,
                                 p_phone_rec,
                                 x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the Phone contact point
    hz_contact_point_v2pub.create_phone_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_phone_rec               => p_phone_rec,
      x_contact_point_id        => x_contact_point_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_phone_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_phone_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_phone_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_phone_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_phone_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates a Phone contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_phone_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_phone_rec          PHONE record.                                |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_phone_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_phone_rec             IN  hz_contact_point_v2pub.phone_rec_type
                                  := hz_contact_point_v2pub.g_miss_phone_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_phone_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_phone_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_phone_contact_point(p_contact_point_rec,
                                 p_phone_rec,
                                 x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the Phone contact point
    hz_contact_point_v2pub.update_phone_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_phone_rec               => p_phone_rec,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_phone_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_phone_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_phone_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_phone_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_phone_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_email_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates an Email contact point.                                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_email_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_email_rec          EMAIL record.                                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_email_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec         IN      hz_contact_point_v2pub.email_rec_type
                                  := hz_contact_point_v2pub.g_miss_email_rec,
    x_contact_point_id  OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_email_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_email_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_email_contact_point(p_contact_point_rec,
                                 p_email_rec,
                                 x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the Email contact point
    hz_contact_point_v2pub.create_email_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_email_rec               => p_email_rec,
      x_contact_point_id        => x_contact_point_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_email_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_email_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_email_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_email_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_email_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates an EMAIL contact point.                                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_email_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_email_rec          EMAIL record.                                |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_email_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_email_rec             IN  hz_contact_point_v2pub.email_rec_type
                                  := hz_contact_point_v2pub.g_miss_email_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_email_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_email_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_email_contact_point(p_contact_point_rec,
                                 p_email_rec,
                                 x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the Email contact point
    hz_contact_point_v2pub.update_email_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_email_rec               => p_email_rec,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_email_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_email_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_email_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_email_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_email_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE create_telex_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Creates a Telex contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.create_telex_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_telex_rec          TELEX record.                                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_contact_point_id   ID of the contact point created.             |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE create_telex_contact_point (
    p_init_msg_list     IN      VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec IN      hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec         IN      hz_contact_point_v2pub.telex_rec_type
                                  := hz_contact_point_v2pub.g_miss_telex_rec,
    x_contact_point_id  OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2,
    x_msg_count         OUT NOCOPY     NUMBER,
    x_msg_data          OUT NOCOPY     VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_telex_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_telex_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_telex_contact_point(p_contact_point_rec,
                                 p_telex_rec,
                                 x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- create the Telex contact point
    hz_contact_point_v2pub.create_telex_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_telex_rec               => p_telex_rec,
      x_contact_point_id        => x_contact_point_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'create_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_telex_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'create_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_telex_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO create_telex_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'create_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END create_telex_contact_point;

  /*=======================================================================+
   | PUBLIC PROCEDURE update_telex_contact_point                           |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Updates a Telex contact point.                                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_utility_v2pub.debug                                              |
   |   hz_party_v2pub.update_telex_contact_point                           |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_contact_point_rec  Contact point record.                        |
   |     p_telex_rec          TELEX record.                                |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Used to lock the record being updated.   |
   |   OUT:                                                                |
   |     x_party_number       Party number for the party created for the   |
   |                          relationship.                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   27-APR-2002    J. del Callar     Bug 2238144: Created.              |
   +=======================================================================*/
  PROCEDURE update_telex_contact_point (
    p_init_msg_list         IN  VARCHAR2 := fnd_api.g_false,
    p_contact_point_rec     IN  hz_contact_point_v2pub.contact_point_rec_type,
    p_telex_rec             IN  hz_contact_point_v2pub.telex_rec_type
                                  := hz_contact_point_v2pub.g_miss_telex_rec,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
  ) IS
  l_debug_prefix                       VARCHAR2(30) := '';
  BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_telex_contact_point;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_telex_contact_point (+)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    --
    -- execute business logic
    --

    -- validate the banking group membership
    validate_telex_contact_point(p_contact_point_rec,
                                 p_telex_rec,
                                 x_return_status);

    -- raise an exception if the validation routine is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the Telex contact point
    hz_contact_point_v2pub.update_telex_contact_point(
      p_init_msg_list           => fnd_api.g_false,
      p_contact_point_rec       => p_contact_point_rec,
      p_telex_rec               => p_telex_rec,
      p_object_version_number   => p_object_version_number,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    -- raise an exception if the banking group creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'update_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- disable the debug procedure before exiting.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_telex_contact_point;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
                 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug(p_message=>'update_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_telex_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'UNEXPECTED ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      ROLLBACK TO update_telex_contact_point;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
                               p_msg_data=>x_msg_data,
                               p_msg_type=>'SQL ERROR',
                               p_msg_level=>fnd_log.level_error);
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
           hz_utility_v2pub.debug(p_message=>'update_telex_contact_point (-)',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;
  END update_telex_contact_point;


  /*=======================================================================+
   | PUBLIC PROCEDURE validate_bank                                        |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate bank record                                                |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_bank_rec           bank record                                  |
   |     p_mode               'I' for insert mode.                         |
   |                          'U' for update mode.                         |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   14-FEB-2006    Jianying      o Bug 4728668: Created.                |
   +=======================================================================*/

  PROCEDURE validate_bank (
    p_init_msg_list         IN     VARCHAR2 DEFAULT NULL,
    p_bank_rec              IN     bank_rec_type,
    p_mode                  IN     VARCHAR2,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
  ) IS

    l_debug_prefix          VARCHAR2(30) := '';
    c_api_name              CONSTANT VARCHAR2(30) := 'validate_bank';
    l_bank_rec              bank_rec_type;

  BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       fnd_api.To_Boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- validate input
    IF (p_mode IS NULL OR
        p_mode <> 'I' AND
        p_mode <> 'U')
    THEN
      fnd_message.set_name('AR', 'HZ_INVALID_BATCH_PARAM');
      fnd_message.set_token('PARAMTER', 'p_mode');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
    END IF;

    l_bank_rec := p_bank_rec;
    l_bank_rec.organization_rec.home_country := l_bank_rec.country;

    validate_bank_org (
      p_bank_rec            => p_bank_rec,
      p_intended_type       => 'BANK',
      p_mode                => p_mode,
      x_return_status       => x_return_status
    );

    -- raise an exception if validation failed
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get (
      p_encoded                   => fnd_api.G_FALSE,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages (
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'WARNING',
        p_msg_level               => fnd_log.level_exception
      );
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      x_return_status := fnd_api.G_RET_STS_ERROR;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'UNEXPECTED ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'SQL ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

  END validate_bank;

  /*=======================================================================+
   | PUBLIC PROCEDURE validate_bank_branch                                 |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Validate bank branch record                                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is FND_API.G_FALSE.  |
   |     p_bank_party_id      bank party id.                               |
   |     p_bank_branch_rec    bank branch record                           |
   |     p_mode               'I' for insert mode.                         |
   |                          'U' for update mode.                         |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   14-FEB-2006    Jianying      o Bug 4728668: Created.                |
   +=======================================================================*/

  PROCEDURE validate_bank_branch (
    p_init_msg_list         IN     VARCHAR2 DEFAULT NULL,
    p_bank_party_id         IN     NUMBER,
    p_bank_branch_rec       IN     bank_rec_type,
    p_mode                  IN     VARCHAR2,
    x_return_status         OUT    NOCOPY VARCHAR2,
    x_msg_count             OUT    NOCOPY NUMBER,
    x_msg_data              OUT    NOCOPY VARCHAR2
  ) IS

    l_debug_prefix          VARCHAR2(30) := '';
    c_api_name              CONSTANT VARCHAR2(30) := 'validate_bank_branch';
    l_bank_branch_rec       bank_rec_type;

  BEGIN

    l_debug_prefix := '';

    -- Debug info.
    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (+)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF p_init_msg_list IS NOT NULL AND
       fnd_api.To_Boolean(p_init_msg_list)
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.G_RET_STS_SUCCESS;

    -- validate input
    IF (p_mode IS NULL OR
        p_mode <> 'I' AND
        p_mode <> 'U')
    THEN
      fnd_message.set_name('AR', 'HZ_INVALID_BATCH_PARAM');
      fnd_message.set_token('PARAMTER', 'p_mode');
      fnd_msg_pub.add;
      raise fnd_api.g_exc_error;
    END IF;

    l_bank_branch_rec := p_bank_branch_rec;
    l_bank_branch_rec.organization_rec.home_country := l_bank_branch_rec.country;

    validate_parent_bank (
      p_bank_rec            => p_bank_branch_rec,
      p_bank_id             => p_bank_party_id,
      p_mode                => p_mode,
      x_return_status       => x_return_status
    );

    -- raise an exception if validation failed
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    validate_bank_org (
      p_bank_rec            => p_bank_branch_rec,
      p_intended_type       => 'BRANCH',
      p_mode                => p_mode,
      x_return_status       => x_return_status
    );

    -- raise an exception if validation failed
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      raise fnd_api.g_exc_error;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get (
      p_encoded                   => fnd_api.G_FALSE,
      p_count                     => x_msg_count,
      p_data                      => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug_return_messages (
        p_msg_count               => x_msg_count,
        p_msg_data                => x_msg_data,
        p_msg_type                => 'WARNING',
        p_msg_level               => fnd_log.level_exception
      );
    END IF;

    IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
      hz_utility_v2pub.debug (
        p_message                 => c_api_name||' (-)',
        p_prefix                  => l_debug_prefix,
        p_msg_level               => fnd_log.level_procedure
      );
    END IF;

  EXCEPTION
    WHEN fnd_api.G_EXC_ERROR THEN
      x_return_status := fnd_api.G_RET_STS_ERROR;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'UNEXPECTED ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

    WHEN OTHERS THEN
      x_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.Count_And_Get (
        p_encoded                 => fnd_api.G_FALSE,
        p_count                   => x_msg_count,
        p_data                    => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug_return_messages (
          p_msg_count             => x_msg_count,
          p_msg_data              => x_msg_data,
          p_msg_type              => 'SQL ERROR',
          p_msg_level             => fnd_log.level_error
        );
      END IF;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug (
          p_message               => c_api_name||' (-)',
          p_prefix                => l_debug_prefix,
          p_msg_level             => fnd_log.level_procedure
        );
      END IF;

  END validate_bank_branch;


END hz_bank_pub;

/
