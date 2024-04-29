--------------------------------------------------------
--  DDL for Package Body IGS_OR_INST_IMP_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_INST_IMP_002" AS
/* $Header: IGSOR15B.pls 120.2 2005/09/28 00:21:48 appldev ship $ */
/* Change History
|   who                      when                            what

|    npalanis                15-feb-2002                 Bug ID -2225917 : SWCR008     IGS_OR_GEN_012_PKG.CREATE_ACCOUNT call
|                                                                     is removed .
|    KUMMA                   15-jul-2002                 Bug 2446067: in call to CREATE_ORGANIZATION and UPDATE_ORGANIZATION ,
|                            converted the NEW_INSTITUTION_CD to upper.
|                            In call to IGS_PE_HZ_PARTIES_PKG.INSERT_ROW if the local_ind and os_ind are null
|                            then put the default value of 'N'. In call to IGS_PE_HZ_PARTIES_PKG.UPDATE_ROW if
|                            local_ind and os_ind are null then substitute them with database older values
|                            OI_LOCAL_INSTITUTION_IND and OI_OS_IND
|    pkpatel                 31-JUL-2002                 Bug No: 2461744
|                                                        Removed the UPPER check for INSTITUTION_CD
|    pkpatel                 25-OCT-2002                 Bug No: 2613704
|                                                        Replaced column inst_priority_code_id with inst_priority_cd  in igs_pe_hz_parties_pkg
|    npalanis                27-OCT-2002                 Bug No: 2613704
|                                                        Modified create_alternate_id
|    pkpatel                  2-DEC-2002                 Bug No: 2599109
|                                                        Added column birth_city, birth_country in the call to TBH igs_pe_hz_parties_pkg
|    ssawhney                30-APR-2003                 V2API - OVN implementation , create/update_institution procs modified
|    vrathi                  28-MAY-2003                 Bug No: 2961982 Replaced update_row with add_row
|    ssaleem                 25-SEP-2003                 IGS.L patch the following changes are made
|                                                        1. Logging mechanism introduced, FND_FILE.PUT_LINE replaced with methods
|                                                           in FND_LOG package
|							 2. Cursors that used variables in the SELECT statements were replaced with
|							    cursor parameters. Respective changes have been made in the places where
|							    the cursors are opened
|							 3. In the import process, it is made sure that NULL values does not replace
|							    existing values in the table. NULL check has been added while calling
|                                                           IGS_OR_GEN_012_PKG.UPDATE_ORGANIZATION and igs_pe_hz_parties_pkg.ADD_row
|  mmkumar                   18-Jul-2005                 modified calls to igs_pe_hz_parties insert_row and add row
*/

PROCEDURE create_institution (
    p_inst_rec IN IGS_OR_INST_INT%ROWTYPE,
    p_instcode OUT NOCOPY VARCHAR2,
    p_errind  OUT NOCOPY VARCHAR2,
    p_error_code OUT NOCOPY VARCHAR2,
    p_error_text OUT NOCOPY VARCHAR2)

AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure creates a New Institution
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  SMVK      05-Feb-2002   Added Fund Authorization to
                  IGS_PE_HZ_PARTIES_PKG.INSERT_ROW calls
                  as per enhancement bug no.2191470.
  kumma         14-JUN-2002       Uncommented the call to message IGS_OR_INST_CRT_FAIL,
                  IGS_OR_AUTOGEN_FAIL, 2410165
  kumma         26-JUN-2002       Passed NULL for values INSITUTION_CD AND OU_START_DT
                  Inside call to IGS_PE_HZ_PARTIES_PKG.INSERT_ROW AND UPDATE_ROW, Bug 2425349
  kumma         28-jun-2002   set the error indicator to 'Y' inside exception handling code
  kumma         15-JUL-2002       In call to CREATE_ORGANIZATION converted the NEW_INSTITUTION_CD to upper.
                  In call to IGS_PE_HZ_PARTIES_PKG.INSERT_ROW if the local_ind and os_ind are null
                  then put the default value of 'N'. Bug 2446067
  pkpatel       31-JUL-2002    Bug No: 2461744
                               Removed the UPPER check for INSTITUTION_CD
  pkpatel       25-OCT-2002    Bug No: 2613704
                               Replaced column inst_priority_code_id with inst_priority_cd  in igs_pe_hz_parties_pkg
  ssawhney      30-APR-2003    V2API - OVN implementation.
  skpandey      27-SEP-2005    Bug: 3663505
                               Description: Added ATTRIBUTES 21 TO 24 to store additional information in IGS_OR_GEN_012_PKG call
  ***************************************************************/
   l_return_status VARCHAR2(1);
   l_msg_data VARCHAR2(2000);
   l_msg_dt VARCHAR2(2000);
   l_rowid VARCHAR2(25);
   l_party_id hz_parties.party_id%TYPE;
   l_success VARCHAR2(1);
   l_ovn hz_parties.object_version_number%TYPE;
   l_err_cd igs_or_inst_int.error_code%TYPE;


   CURSOR c_inst_code(cp_party_id NUMBER) IS
     SELECT party_number
     FROM hz_parties
     WHERE party_id = cp_party_id;


BEGIN
   -- Call the Autogenerate Logic to check for the Profile Value of Hz_Generate_Party_Number
   autoGenerateLogic(p_inst_rec, l_success,l_err_cd);
   IF l_success = 'Y' THEN
      -- Create Organization
      IGS_OR_GEN_012_PKG.CREATE_ORGANIZATION (
         p_institution_cd     => p_inst_rec.NEW_INSTITUTION_CD,
     p_name               => p_inst_rec.NAME,
     p_status             => 'A',
     p_attribute_category => p_inst_rec.ATTRIBUTE_CATEGORY,
     p_attribute1         => p_inst_rec.ATTRIBUTE1,
     p_attribute2         => p_inst_rec.ATTRIBUTE2,
     p_attribute3         => p_inst_rec.ATTRIBUTE3,
     p_attribute4         => p_inst_rec.ATTRIBUTE4,
     p_attribute5         => p_inst_rec.ATTRIBUTE5,
     p_attribute6         => p_inst_rec.ATTRIBUTE6,
     p_attribute7         => p_inst_rec.ATTRIBUTE7,
     p_attribute8         => p_inst_rec.ATTRIBUTE8,
     p_attribute9         => p_inst_rec.ATTRIBUTE9,
     p_attribute10        => p_inst_rec.ATTRIBUTE10,
     p_attribute11        => p_inst_rec.ATTRIBUTE11,
     p_attribute12        => p_inst_rec.ATTRIBUTE12,
     p_attribute13        => p_inst_rec.ATTRIBUTE13,
     p_attribute14        => p_inst_rec.ATTRIBUTE14,
     p_attribute15        => p_inst_rec.ATTRIBUTE15,
     p_attribute16        => p_inst_rec.ATTRIBUTE16,
     p_attribute17        => p_inst_rec.ATTRIBUTE17,
     p_attribute18        => p_inst_rec.ATTRIBUTE18,
     p_attribute19        => p_inst_rec.ATTRIBUTE19,
     p_attribute20        => p_inst_rec.ATTRIBUTE20,
     p_return_status      => l_return_status,
     p_msg_data           => l_msg_data,
     p_party_id           => l_party_id,
     p_object_version_number => l_ovn,
     p_attribute21        => p_inst_rec.ATTRIBUTE21,
     p_attribute22        => p_inst_rec.ATTRIBUTE22,
     p_attribute23        => p_inst_rec.ATTRIBUTE23,
     p_attribute24        => p_inst_rec.ATTRIBUTE24
        );

      IF l_return_status IN ('E','U') THEN
         --Log a message to the Log File that the Create of Organisation failed

	 IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
           FND_MESSAGE.Set_Name('IGS','IGS_OR_INST_IMP_FAIL');
           FND_MESSAGE.Set_Token('INT_ID',p_inst_rec.interface_id);
           FND_MESSAGE.Set_Token('ERROR_CODE',' ');
	   FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                        'igs.plsql.igs_or_inst_imp_002.create_institution.retstatfail',
	                                FND_MESSAGE.Get || '-' || l_msg_data ,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
         END IF;


         p_error_code:= 'E003';
         p_error_text:= l_msg_data;
         p_errind := 'Y';
         RETURN;
      ELSE
         -- Create Record in the overflow Table
         p_errind := 'N';
         OPEN c_inst_code(l_party_id);
         FETCH c_inst_code INTO p_instcode;
         CLOSE c_inst_code;
            BEGIN
                  IGS_PE_HZ_PARTIES_PKG.INSERT_ROW (
                   x_rowid                    => l_rowid,
                   x_mode                     => 'R',
                   x_party_id                 => l_party_id,
                   x_deceased_ind             => NULL,
                   x_archive_exclusion_ind    => NULL,
                   x_archive_dt               => NULL,
                   x_purge_exclusion_ind      => NULL,
                   x_purge_dt                 => NULL,
                   x_oracle_username          => NULL,
                   x_proof_of_ins             => NULL,
                   x_proof_of_immu            => NULL,
                   x_level_of_qual            => NULL,
                   x_military_service_reg     => NULL,
                   x_veteran              => NULL,
                       x_institution_cd           => NULL,
                       x_oi_local_institution_ind => NVL(p_inst_rec.LOCAL_INSTITUTION_IND,'N'),
                       x_oi_os_ind                => NVL(p_inst_rec.OS_IND,'N'),
                       x_oi_govt_institution_cd   => p_inst_rec.GOVT_INSTITUTION_CD,
                       x_oi_inst_control_type     => p_inst_rec.INST_CONTROL_TYPE,
                       x_oi_institution_type      => p_inst_rec.INSTITUTION_TYPE,
                       x_oi_institution_status    => p_inst_rec.INSTITUTION_STATUS,
                       x_ou_start_dt              => NULL,
                       x_ou_end_dt                => NULL,
                       x_ou_member_type           => NULL,
                       x_ou_org_status            => NULL,
                       x_ou_org_type              => NULL,
                       x_inst_org_ind             => 'I',
                   x_inst_priority_cd    => p_inst_rec.INST_PRIORITY_CD,
                   x_inst_eps_code            => p_inst_rec.EPS_CODE,
                   x_inst_phone_country_code  => p_inst_rec.PHONE_COUNTRY,
                   x_inst_phone_area_code     => p_inst_rec.PHONE_AREA,
                   x_inst_phone_number        => p_inst_rec.PHONE_NUMBER,
                   x_adv_studies_classes      => p_inst_rec.ADV_STUDIES_CLASSES,
                   x_honors_classes           => p_inst_rec.HONORS_CLASSES,
                   x_class_size               => p_inst_rec.CLASS_SIZE,
                   x_sec_school_location_id   => p_inst_rec.SEC_SCHOOL_LOCATION_ID,
                   x_percent_plan_higher_edu  => p_inst_rec.PERCENT_PLAN_HIGHER_EDU,
                   x_fund_authorization       => NULL,
                   x_birth_city               => NULL,
                   x_birth_country            => NULL,
		   x_oss_org_unit_cd	      => p_instcode	--mmkumar, party number change
                   );
               EXCEPTION
                WHEN OTHERS THEN
                     p_error_code:= 'E044';
                     p_error_text:= NULL;
                     p_errind := 'Y';

		     IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
                       FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                                    'igs.plsql.igs_or_inst_imp_002.create_institution.exc1',
		                                    FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
                     END IF;
               END;
      END IF;

   ELSE   -- l_success = N
     --Log a message to the Log File that the Create of Institution failed
     IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
       FND_MESSAGE.Set_Name('IGS','IGS_OR_INST_IMP_FAIL');
       FND_MESSAGE.Set_Token('INT_ID',p_inst_rec.interface_id);
       FND_MESSAGE.Set_Token('ERROR_CODE',' ');
       FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                    'igs.plsql.igs_or_inst_imp_002.create_institution.autogenfail',
                                     FND_MESSAGE.Get || '-' || l_msg_data ,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
     END IF;
     p_error_code:=l_err_cd;
     p_error_text:=NULL;
     p_errind := 'Y';
   END IF;  -- If l_success = Y

EXCEPTION
    WHEN OTHERS THEN
       IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
         FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.create_institution');
         FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                      'igs.plsql.igs_or_inst_imp_002.create_institution.exc2',
	                              FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
       END IF;

       p_error_code:= 'E003';
       p_error_text:= NULL;
       p_errind := 'Y';

END create_institution;

PROCEDURE create_crosswalk_master (
    p_inst_code IN VARCHAR2,
    p_inst_name IN VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2,
    p_crswalk_id OUT NOCOPY NUMBER )

AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure creates a New Record in the Crosswalk
        master table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kumma           16-JUL-2002     Converted the p_inst_code to upper,2446067
  pkpatel         31-JUL-2002     Bug No: 2461744
                                  Removed the UPPER check for INSTITUTION_CD
  ***************************************************************/

    l_rowid VARCHAR2(25);
    l_crswalk_id igs_or_cwlk.crosswalk_id%TYPE;

BEGIN

    IGS_OR_CWLK_PKG.INSERT_ROW (
      x_rowid => l_rowid,
      x_crosswalk_id => l_crswalk_id,
      x_institution_code => p_inst_code,
      x_institution_name => p_inst_name
    );
    p_crswalk_id := l_crswalk_id;
    p_errind := 'N';
EXCEPTION
    WHEN OTHERS THEN
      IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
         FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.create_crosswalk_master');
         FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                      'igs.plsql.igs_or_inst_imp_002.create_crosswalk_master.others',
	                              FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
      END IF;
      p_errind := 'Y';

END create_crosswalk_master;

PROCEDURE create_crosswalk_detail (
    p_crwlkid IN NUMBER,
    p_datasrc IN VARCHAR2,
    p_dataval IN VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure creates a New Record in the Crosswalk
        Detail table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel         30-DEC-2002     Bug No: 2729628
                                  Modified the cursor chk_dup to remove the COUNT
  ***************************************************************/

    CURSOR chk_dup(cp_data_src VARCHAR2,cp_data_val VARCHAR2) IS
    SELECT 'Y'
    FROM IGS_OR_CWLK_DTL
    WHERE ALT_ID_TYPE = cp_data_src AND
          ALT_ID_VALUE = cp_data_val;

    l_rowid VARCHAR2(25);
    l_exists VARCHAR2(1);
    l_crswalkdtl_id igs_or_cwlk_dtl.crosswalk_dtl_id%TYPE;

BEGIN

    OPEN chk_dup(p_datasrc,p_dataval);
    FETCH chk_dup INTO l_exists;
    CLOSE chk_dup;

    IF l_exists IS NULL THEN
      IGS_OR_CWLK_DTL_PKG.INSERT_ROW (
         x_rowid => l_rowid,
         x_crosswalk_dtl_id => l_crswalkdtl_id,
         x_crosswalk_id => p_crwlkid,
         x_alt_id_type => p_datasrc,
         x_alt_id_value => p_dataval,
         x_mode => 'R');
    END IF;
    p_errind := 'N';
EXCEPTION
    WHEN OTHERS THEN
      IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
        FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.create_crosswalk_detail');
        FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                     'igs.plsql.igs_or_inst_imp_002.create_crosswalk_detail.others',
                                     FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
      END IF;
      p_errind := 'Y';
END create_crosswalk_detail;

PROCEDURE create_alternate_id (
    p_instcd IN VARCHAR2,
    p_altidtype IN VARCHAR2,
    p_altidval IN VARCHAR2,
    p_error_code OUT NOCOPY VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure creates a New Record in the IGS_OR_ORG_ALT_IDS table
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ssawhney      30-APR-2003    V2API - OVN implementation
  pkpatel         6-JAN-2003      Bug No: 2528605
                                  Modified the logic to insert the alternate id. It will create a new alternate ID
								  if there is no ACTIVE alternate id present.
  kumma           16-jul-2002     changed the cursor c_partyid to put upper on cp_instcd,2446067
  pkpatel         31-JUL-2002     Bug No: 2461744
                                  Removed the UPPER check for INSTITUTION_CD
  npalanis        27-OCT-2002     Bug No: 2613704
                                  Added the parameter p_error_code and added the check for overlap of alternate ID
  ***************************************************************/

  CURSOR c_exists (cp_alt_id_type igs_or_org_alt_ids.org_alternate_id_type%TYPE,
                   cp_alt_id_val VARCHAR2,
		   cp_instcd igs_or_org_alt_ids.org_structure_id%TYPE,
		   cp_structure_type igs_or_org_alt_ids.org_structure_type%TYPE,
		   cp_end_date VARCHAR2) IS
    SELECT org_alternate_id
    FROM igs_or_org_alt_ids
    WHERE org_alternate_id_type = cp_alt_id_type
    AND   org_structure_id   =  cp_instcd
    AND   org_structure_type =  cp_structure_type
	AND   ( SYSDATE BETWEEN start_date AND NVL(end_date,TO_DATE(cp_end_date,'YYYY/MM/DD')) );

  --mmkumar, party number impact, changed the following cursor to resolve the foreign key via igs_pe_hz_parties
  CURSOR c_partyid (cp_instcd VARCHAR2) IS
    SELECT hp.party_id
    FROM HZ_PARTIES hp, igs_pe_hz_parties ihp
    WHERE ihp.oss_org_unit_cd = cp_instcd and
          ihp.party_id = hp.party_id;

  l_rowid VARCHAR2(25);
  l_partyid hz_parties.party_id%TYPE;
  l_org_alternate_id igs_or_org_alt_ids.org_alternate_id%TYPE;

BEGIN
    p_error_code := NULL;
    OPEN c_exists (p_altidtype,p_altidval,p_instcd,'INSTITUTE','4712/12/31');
    FETCH c_exists INTO l_org_alternate_id;
    CLOSE c_exists;

	IF l_org_alternate_id IS NULL THEN

		  OPEN c_partyid(p_instcd);
          FETCH c_partyid INTO l_partyid;
          CLOSE c_partyid;

          IGS_OR_ORG_ALT_IDS_PKG.INSERT_ROW(
            x_rowid => l_rowid,
            x_org_structure_id => p_instcd,
            x_org_structure_type => 'INSTITUTE',
            x_org_alternate_id_type => p_altidtype,
            x_org_alternate_id => p_altidval,
            x_start_date => SYSDATE,
            x_end_date => NULL,
            x_mode => 'R');
          p_errind := 'N';
    ELSE

	   -- If there is already active alternate ID present for this ID type and the import process
	   -- is trying to import for different alternate ID then throw an error.

	   IF l_org_alternate_id <> p_altidval THEN
	      p_error_code := 'E053';
          p_errind := 'Y';
	   END IF;
    END IF;
EXCEPTION
   WHEN OTHERS THEN
      p_error_code := 'E005';
      p_errind := 'Y';
      IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
         FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
         FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.create_alternate_id');
         FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                      'igs.plsql.igs_or_inst_imp_002.create_alternate_id.others',
	                              FND_MESSAGE.Get ||'-' || p_instcd || '-' || p_altidtype || '-' || p_altidval || SQLERRM,
				      NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
      END IF;

END create_alternate_id;

PROCEDURE update_institution(
    p_instcd IN VARCHAR2,
    p_instrec IN IGS_OR_INST_INT%ROWTYPE,
    p_errind OUT NOCOPY VARCHAR2,
    p_error_code OUT NOCOPY VARCHAR2,
    p_error_text OUT NOCOPY VARCHAR2 )
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure Updates an Institution Record
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  SMVK      05-Feb-2002   Added Fund Authorization to
                  IGS_PE_HZ_PARTIES_PKG.UPDATE_ROW calls
                  as per enhancement bug no.2191470.
  kumma         14-JUN-2002       Uncommented the call to message IGS_OR_INST_UPD_FAIL, 2410165
  kumma         15-JUL-2002       In call to UPDATE_ORGANIZATION ,
                  converted the INSTITUTION_CD to upper.
                  In call to IGS_PE_HZ_PARTIES_PKG.UPDATE_ROW if the local_ind and os_ind are null
                  then substituted them witholder values of database. Bug 2446067
  pkpatel         31-JUL-2002     Bug No: 2461744
                                  Removed the UPPER check for INSTITUTION_CD
  pkpatel       25-OCT-2002    Bug No: 2613704
                               Replaced column inst_priority_code_id with inst_priority_cd  in igs_pe_hz_parties_pkg
  ssawhney      30-APR-2003    V2API - OVN implementation.
  vrathi        28-MAY-2003    Bug No: 2961982 Replaced update_row with add_row
  ssaleem       26-SEP-2003    NULL check has been added while calling
                               IGS_OR_GEN_012_PKG.UPDATE_ORGANIZATION and igs_pe_hz_parties_pkg.ADD_row,
			       it is made sure that NULL values does not replace
 			       existing values in the table.
  skpandey      27-SEP-2005    Bug: 3663505
                               Description: Added ATTRIBUTES 21 TO 24 to store additional information in IGS_OR_GEN_012_PKG call
  ***************************************************************/
    CURSOR c_partyid (cp_instcd VARCHAR2) IS
      SELECT hp.*
      FROM HZ_PARTIES HP, igs_pe_hz_parties ihp
      WHERE ihp.oss_org_unit_cd  = cp_instcd and
            hp.party_id = ihp.party_id;

    CURSOR c_getrow (cp_partyid NUMBER) IS
      SELECT rowid ,PP.*
      FROM IGS_PE_HZ_PARTIES PP
      WHERE party_id = cp_partyid;


    l_msg_data VARCHAR2(2000);
    l_return_status VARCHAR2(1);
    l_rowid VARCHAR2(25);
    l_ovn hz_parties.object_version_number%TYPE;
    l_party_rec c_partyid%ROWTYPE;
    l_getrow_rec c_getrow%ROWTYPE;

BEGIN

    OPEN c_partyid(p_instcd);
    FETCH c_partyid INTO l_party_rec;
    CLOSE c_partyid;

    l_ovn := l_party_rec.object_version_number;

    IGS_OR_GEN_012_PKG.UPDATE_ORGANIZATION (
        p_party_id             => l_party_rec.party_id,
        p_institution_cd       => p_instcd,
        p_name                 => NVL(p_instrec.NAME,l_party_rec.party_name),
        p_status               => l_party_rec.status,
        p_last_update          => l_party_rec.last_update_date,
        p_attribute_category   => NVL(p_instrec.ATTRIBUTE_CATEGORY, l_party_rec.attribute_category),
        p_attribute1           => NVL(p_instrec.ATTRIBUTE1,l_party_rec.attribute1),
        p_attribute2           => NVL(p_instrec.ATTRIBUTE2,l_party_rec.attribute2),
        p_attribute3           => NVL(p_instrec.ATTRIBUTE3,l_party_rec.attribute3),
        p_attribute4           => NVL(p_instrec.ATTRIBUTE4,l_party_rec.attribute4),
        p_attribute5           => NVL(p_instrec.ATTRIBUTE5,l_party_rec.attribute5),
        p_attribute6           => NVL(p_instrec.ATTRIBUTE6,l_party_rec.attribute6),
        p_attribute7           => NVL(p_instrec.ATTRIBUTE7,l_party_rec.attribute7),
        p_attribute8           => NVL(p_instrec.ATTRIBUTE8,l_party_rec.attribute8),
        p_attribute9           => NVL(p_instrec.ATTRIBUTE9,l_party_rec.attribute9),
        p_attribute10          => NVL(p_instrec.ATTRIBUTE10,l_party_rec.attribute10),
        p_attribute11          => NVL(p_instrec.ATTRIBUTE11,l_party_rec.attribute11),
        p_attribute12          => NVL(p_instrec.ATTRIBUTE12,l_party_rec.attribute12),
        p_attribute13          => NVL(p_instrec.ATTRIBUTE13,l_party_rec.attribute13),
        p_attribute14          => NVL(p_instrec.ATTRIBUTE14,l_party_rec.attribute14),
        p_attribute15          => NVL(p_instrec.ATTRIBUTE15,l_party_rec.attribute15),
        p_attribute16          => NVL(p_instrec.ATTRIBUTE16,l_party_rec.attribute16),
        p_attribute17          => NVL(p_instrec.ATTRIBUTE17,l_party_rec.attribute17),
        p_attribute18          => NVL(p_instrec.ATTRIBUTE18,l_party_rec.attribute18),
        p_attribute19          => NVL(p_instrec.ATTRIBUTE19,l_party_rec.attribute19),
        p_attribute20          => NVL(p_instrec.ATTRIBUTE20,l_party_rec.attribute20),
        p_return_status        => l_return_status,
        p_msg_data             => l_msg_data,
	p_object_version_number => l_ovn,
        p_attribute21          => NVL(p_instrec.ATTRIBUTE21,l_party_rec.attribute21),
        p_attribute22          => NVL(p_instrec.ATTRIBUTE22,l_party_rec.attribute22),
        p_attribute23          => NVL(p_instrec.ATTRIBUTE23,l_party_rec.attribute23),
        p_attribute24          => NVL(p_instrec.ATTRIBUTE24,l_party_rec.attribute24)
    );

    IF l_return_status IN ('E','U') THEN
	  IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
             FND_MESSAGE.Set_Name('IGS','IGS_OR_INST_IMP_FAIL');
             FND_MESSAGE.Set_Token('INT_ID',p_instrec.interface_id);
             FND_MESSAGE.Set_Token('ERROR_CODE',' ');
             FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                          'igs.plsql.igs_or_inst_imp_002.update_institution.updatefail',
		                          FND_MESSAGE.Get || '-' || l_msg_data ,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
	  END IF;

          p_error_code:= 'E002';
          p_error_text:= l_msg_data;
          p_errind := 'Y';
          return;
    ELSE
          p_errind := 'N';
      -- Call the Update of Igs_Pe_Hz_Parties Table
          OPEN c_getrow(l_party_rec.party_id);
          FETCH c_getrow INTO l_getrow_rec;
          CLOSE c_getrow;
        BEGIN

		igs_pe_hz_parties_pkg.ADD_row (
			   x_mode                  => 'R',
			   x_rowid                 => l_rowid,
		           x_party_id              => l_party_rec.party_id,
                           x_deceased_ind          => l_getrow_rec.DECEASED_IND,
                           x_archive_exclusion_ind => l_getrow_rec.ARCHIVE_EXCLUSION_IND,
                           x_archive_dt            => l_getrow_rec.ARCHIVE_DT,
                           x_purge_exclusion_ind   => l_getrow_rec.PURGE_EXCLUSION_IND,
                           x_purge_dt              => l_getrow_rec.PURGE_DT,
                           x_oracle_username       => l_getrow_rec.ORACLE_USERNAME,
                           x_proof_of_ins          => l_getrow_rec.PROOF_OF_INS,
                           x_proof_of_immu         => l_getrow_rec.PROOF_OF_IMMU,
                           x_level_of_qual         => l_getrow_rec.LEVEL_OF_QUAL,
                           x_military_service_reg  => l_getrow_rec.MILITARY_SERVICE_REG,
			   x_veteran               => l_getrow_rec.VETERAN,
                           x_institution_cd        => NULL,
                           x_oi_local_institution_ind => NVL(l_getrow_rec.OI_LOCAL_INSTITUTION_IND,'N'),
                           x_oi_os_ind                =>  NVL(p_instrec.OS_IND, l_getrow_rec.OI_os_ind),
                           x_oi_govt_institution_cd  => NVL(p_instrec.GOVT_INSTITUTION_CD,l_getrow_rec.OI_GOVT_INSTITUTION_CD),
                           x_oi_inst_control_type    => p_instrec.INST_CONTROL_TYPE,
                           x_oi_institution_type     => p_instrec.INSTITUTION_TYPE,
                           x_oi_institution_status   => NVL(p_instrec.INSTITUTION_STATUS,l_getrow_rec.OI_INSTITUTION_STATUS),
                           x_ou_start_dt             => NULL,
                           x_ou_end_dt               => l_getrow_rec.OU_END_DT,
                           x_ou_member_type          => l_getrow_rec.OU_MEMBER_TYPE,
                           x_ou_org_status           => l_getrow_rec.OU_ORG_STATUS,
                           x_ou_org_type             => l_getrow_rec.OU_ORG_TYPE,
			   x_inst_org_ind           => 'I' ,
                           x_inst_priority_cd        => NVL(p_instrec.INST_PRIORITY_CD,l_getrow_rec.INST_PRIORITY_CD),
                           x_inst_eps_code           => NVL(p_instrec.EPS_CODE,l_getrow_rec.INST_EPS_CODE),
                           x_inst_phone_country_code => NVL(p_instrec.PHONE_COUNTRY,l_getrow_rec.INST_PHONE_COUNTRY_CODE),
                           x_inst_phone_area_code    => NVL(p_instrec.PHONE_AREA,l_getrow_rec.INST_PHONE_AREA_CODE),
                           x_inst_phone_number       => NVL(p_instrec.PHONE_NUMBER,l_getrow_rec.INST_PHONE_NUMBER),
			   x_adv_studies_classes     => NVL(p_instrec.ADV_STUDIES_CLASSES,l_getrow_rec.ADV_STUDIES_CLASSES),
                           x_honors_classes          => NVL(p_instrec.HONORS_CLASSES,l_getrow_rec.HONORS_CLASSES),
                           x_class_size              => NVL(p_instrec.CLASS_SIZE,l_getrow_rec.CLASS_SIZE),
                           x_sec_school_location_id  => NVL(p_instrec.SEC_SCHOOL_LOCATION_ID,l_getrow_rec.SEC_SCHOOL_LOCATION_ID),
                           x_percent_plan_higher_edu => NVL(p_instrec.PERCENT_PLAN_HIGHER_EDU,l_getrow_rec.PERCENT_PLAN_HIGHER_EDU),
			   x_fund_authorization      => l_getrow_rec.fund_authorization,
			   x_pe_info_verify_time     => l_getrow_rec.pe_info_verify_time,
			   x_birth_city              => l_getrow_rec.birth_city,
			   x_birth_country           => l_getrow_rec.birth_country,
			   x_oss_org_unit_cd         => l_getrow_rec.oss_org_unit_cd --mmkumar, party number impact
			  );
        EXCEPTION
        WHEN OTHERS THEN
             p_error_code:= 'E045';
             p_error_text:= NULL;
             p_errind := 'Y';
        END;
    END IF;
EXCEPTION
      WHEN OTHERS THEN
	  IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
            FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.Update Institution');
            FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_002.update_institution.addrowfail',
  	                                 FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
          END IF;

          p_error_code:= 'E002';
          p_error_text:= NULL;
          p_errind := 'Y';

END update_institution;

PROCEDURE update_crosswalk_master (
    p_cwlkid IN NUMBER,
    p_instcd IN VARCHAR2,
    p_errind OUT NOCOPY VARCHAR2)
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure Updates a record in the Crosswalk Master
    with the Institution Code
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kumma           16-JUL-2002     changed the institution_cd to upper,2446067
  pkpatel         31-JUL-2002     Bug No: 2461744
                                  Removed the UPPER check for INSTITUTION_CD
  ***************************************************************/
    CURSOR c_getrow (cp_cwlkid NUMBER) IS
      SELECT rowid ,ORC.*
      FROM IGS_OR_CWLK ORC
      WHERE crosswalk_id = cp_cwlkid;

    l_rowid VARCHAR2(25);
    l_getrow_rec c_getrow%ROWTYPE;

BEGIN
    OPEN c_getrow(p_cwlkid);
    FETCH c_getrow INTO l_getrow_rec;
    CLOSE c_getrow;
    IGS_OR_CWLK_PKG.update_row (
      x_rowid      => l_getrow_rec.rowid,
      x_crosswalk_id  => p_cwlkid,
      x_institution_code => p_instcd,
      x_institution_name  => l_getrow_rec.institution_name,
      x_mode        => 'R' );
    p_errind := 'N';

 EXCEPTION
      WHEN OTHERS THEN
          IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
            FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
            FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.Update Crosswalk Master');
  	    FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                         'igs.plsql.igs_or_inst_imp_002.update_crosswalk_master.others',
	                                 FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
          END IF;
          p_errind := 'Y';
END update_crosswalk_master;

PROCEDURE autoGenerateLogic(
   p_inst_rec IN IGS_OR_INST_INT%ROWTYPE,
   p_success  OUT NOCOPY VARCHAR2,
   p_err_cd OUT NOCOPY VARCHAR2)
AS
 /*************************************************************
  Created By :samaresh
  Date Created By : 17-JUL-2001
  Purpose : This Procedure checks the Profile Value
        of hz_generate_party_number
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ***************************************************************/
   l_generate_party_number VARCHAR2(1);

BEGIN
   l_generate_party_number := FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER');
   IF l_generate_party_number = 'Y' AND p_inst_rec.new_institution_cd IS NOT NULL THEN
     p_err_cd:='E008';
     p_success := 'N';
   ELSIF l_generate_party_number = 'N' AND p_inst_rec.new_institution_cd IS NULL THEN
     p_err_cd:='E009';
     p_success := 'N';
   ELSE
     p_success := 'Y';
   END IF;
EXCEPTION
  WHEN OTHERS THEN

    IF IGS_OR_INST_IMP_001.gb_write_exception_log2 THEN
      FND_MESSAGE.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.Set_Token('NAME','IMP_OR_INSTITUTION.Auto Generate Logic');
      FND_LOG.STRING_WITH_CONTEXT (FND_LOG.LEVEL_EXCEPTION,
                                   'igs.plsql.igs_or_inst_imp_002.autoGenerateLogic.others',
                                    FND_MESSAGE.Get||'-'||SQLERRM,NULL,NULL,NULL,NULL,NULL,IGS_OR_INST_IMP_001.g_request_id);
    END IF;
    p_success := 'N';

END autoGenerateLogic;

END IGS_OR_INST_IMP_002;

/
