--------------------------------------------------------
--  DDL for Package Body IGS_PE_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_RELATIONSHIPS_PKG" AS
 /* $Header: IGSNI41B.pls 120.6 2006/05/30 07:02:26 prbhardw ship $ */

  PROCEDURE copy_address_and_usage(p_subject_id IN NUMBER,
                                   p_object_id  IN NUMBER,
                                   p_validate  OUT NOCOPY BOOLEAN) AS
  ------------------------------------------------------------------
  --Updated by  : smanglm, Oracle India
  --Date created:  27-MAY-2001
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --gmaheswa   18-Nov-2003    Modified c_student_addr cursor to select start_dt,end_dt from
  --                          OSS extension tables,as part of address related changes .
  -------------------------------------------------------------------

     -- store the student age restriction
     l_student_age_bar   NUMBER := TO_NUMBER(NVL(FND_PROFILE.VALUE('IGS_AD_AUTONUM'),0)) ;

     --
     -- cursor to fetch the address of the student
     --
     CURSOR c_student_addr_prim (cp_person_id igs_pe_addr_v.person_id%TYPE,
                                 cp_site_use_type hz_party_site_uses.site_use_type%TYPE) IS
            SELECT
                 ihps.START_DATE START_DT, --hps.START_DATE_ACTIVE START_DT,
                 hps.party_site_id,
                 ihps.END_DATE END_DT, -- hps.END_DATE_ACTIVE END_DT,
                 hl.COUNTRY COUNTRY_CD,
                 hl.ADDRESS_STYLE,
                 hl.ADDRESS1 ADDR_LINE_1,
                 hl.ADDRESS2 ADDR_LINE_2,
                 hl.ADDRESS3 ADDR_LINE_3,
                 hl.ADDRESS4 ADDR_LINE_4,
                 hps.identifying_address_flag CORRESPONDENCE,
                 hl.CITY,
                 hl.STATE,
                 hl.PROVINCE,
                 hl.COUNTY,
                 hl.POSTAL_CODE,
                 hl.address_lines_phonetic,
                 hl.delivery_point_code,
		         hps.status
             FROM
                 HZ_LOCATIONS hl,
                 hz_party_sites hps,
                 hz_party_site_uses hpsu,
        		 igs_pe_hz_pty_sites ihps
             WHERE
                 hl.location_id = hps.location_id AND
                 hps.party_id = cp_person_id AND
                 hps.party_site_id = hpsu.party_site_id AND
                 hpsu.site_use_type = cp_site_use_type AND
         		 hps.party_site_id = ihps.party_site_id(+) AND
		         hps.status= 'A' AND
        		 hpsu.status= 'A' AND
                 hps.identifying_address_flag = 'Y';

     CURSOR c_student_addr (cp_person_id igs_pe_addr_v.person_id%TYPE,
                            cp_site_use_type hz_party_site_uses.site_use_type%TYPE) IS
            SELECT
                 ihps.START_DATE START_DT, --hps.START_DATE_ACTIVE START_DT,
                 hps.party_site_id,
                 ihps.END_DATE END_DT, -- hps.END_DATE_ACTIVE END_DT,
                 hl.COUNTRY COUNTRY_CD,
                 hl.ADDRESS_STYLE,
                 hl.ADDRESS1 ADDR_LINE_1,
                 hl.ADDRESS2 ADDR_LINE_2,
                 hl.ADDRESS3 ADDR_LINE_3,
                 hl.ADDRESS4 ADDR_LINE_4,
                 hps.identifying_address_flag CORRESPONDENCE,
                 hl.CITY,
                 hl.STATE,
                 hl.PROVINCE,
                 hl.COUNTY,
                 hl.POSTAL_CODE,
                 hl.address_lines_phonetic,
                 hl.delivery_point_code,
		         hps.status
             FROM
                 HZ_LOCATIONS hl,
                 hz_party_sites hps,
                 hz_party_site_uses hpsu,
        		 igs_pe_hz_pty_sites ihps
             WHERE
                 hl.location_id = hps.location_id AND
                 hps.party_id = cp_person_id AND
                 hps.party_site_id = hpsu.party_site_id AND
                 hpsu.site_use_type = cp_site_use_type AND
         		 hps.party_site_id = ihps.party_site_id(+) AND
		         hps.status= 'A' AND
        		 hpsu.status= 'A' AND
                 SYSDATE BETWEEN ihps.START_DATE AND NVL(ihps.END_DATE, SYSDATE)
			 ORDER BY ihps.START_DATE DESC;

     rec_student_addr    c_student_addr%ROWTYPE;

     --
     -- cursor to get the age of student
     --
     CURSOR c_student_age (cp_person_id igs_pe_person.person_id%TYPE) IS
            SELECT TO_NUMBER(nvl((SYSDATE-birth_date)/365,0))
            FROM   igs_pe_person_base_v
            WHERE  person_id = cp_person_id;
     l_student_age   NUMBER;

     l_return_status     VARCHAR2(1) := NULL;
     l_msg_count         NUMBER;
     l_msg_data    	 VARCHAR2(2000) := NULL;
     l_contact_person    VARCHAR2(40) := NULL;
     l_loc_id	         NUMBER;
     l_rowid             VARCHAR2(25);
     l_location_id 	 NUMBER(15);
     l_party_site_id     NUMBER;
     l_last_update_date  DATE;

     l_site_last_update_date	  DATE;
     l_profile_last_update_date   DATE;
     l_party_site_use_id          NUMBER;
     l_site_use_id                NUMBER;
     l_object_version_number      NUMBER;
     tmp_var   VARCHAR2(2000);
     tmp_var1  VARCHAR2(2000);
     l_party_site_ovn hz_party_sites.object_version_number%TYPE;
     l_location_ovn hz_locations.object_version_number%TYPE;
	 l_profile_addr_usage VARCHAR2(30);

  BEGIN
       p_validate := TRUE;

		--
        -- check whether the value exist for IGS_AD_ADR_USG or not. If no, give warning
        --
		l_profile_addr_usage := FND_PROFILE.VALUE('IGS_AD_ADR_USG');

        IF l_profile_addr_usage IS NULL THEN
           FND_MESSAGE.SET_NAME ('IGS','IGS_PE_ADR_USG');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;

         --
		 -- copy the address of the person to the member only if the student's age is
		 -- less than the value of profile IGS_AD_AUTONUM
		 --
		 -- get the student age
		 --
		 OPEN c_student_age (p_subject_id);
		 FETCH c_student_age INTO l_student_age;
		 CLOSE c_student_age;

		 IF l_student_age < l_student_age_bar THEN

			--
			--  check whether the address and usage exist for the person or not
			--  First check whether any primary address exists associated with l_profile_addr_usage
			--  if not found check whether any active address (Status = A and Sysdate BETWEEN start_date and NVL(end_date,Sysdate))
			--  associated with l_profile_addr_usage is present.
			--
			OPEN c_student_addr_prim (p_subject_id, l_profile_addr_usage);
			FETCH c_student_addr_prim INTO rec_student_addr;
			IF c_student_addr_prim%NOTFOUND THEN
			  CLOSE c_student_addr_prim;

			  OPEN c_student_addr (p_subject_id, l_profile_addr_usage);
			  FETCH c_student_addr INTO rec_student_addr;
			  IF c_student_addr%NOTFOUND THEN
				 CLOSE c_student_addr;
				 p_validate := FALSE;
			  ELSE
				 CLOSE c_student_addr;
			  END IF;
			ELSE
			  CLOSE c_student_addr_prim;
			END IF;
		    --
		    -- copy the address
		    --

		   IF (p_validate) THEN
				l_party_site_id   := rec_student_addr.party_site_id;

				IGS_PE_PERSON_ADDR_PKG.INSERT_ROW(
				p_action		  =>'INSERT',
				p_rowid 		  => l_rowid,
				p_location_id 		  => l_location_id,
				p_start_dt		  => rec_student_addr.START_DT,
				p_end_dt 		  => rec_student_addr.END_DT,
				p_country		  => rec_student_addr.COUNTRY_CD,
				p_address_style 	  => rec_student_addr.ADDRESS_STYLE,
				p_addr_line_1		  => rec_student_addr.ADDR_LINE_1,
				p_addr_line_2		  => rec_student_addr.ADDR_LINE_2,
				p_addr_line_3		  => rec_student_addr.ADDR_LINE_3,
				p_addr_line_4		  => rec_student_addr.ADDR_LINE_4,
				p_date_last_verified	  => NULL,
				p_correspondence 	  => rec_student_addr.CORRESPONDENCE,
				p_city			  => rec_student_addr.CITY,
				p_state			  => rec_student_addr.STATE,
				p_province		  => rec_student_addr.PROVINCE,
				p_county		  => rec_student_addr.COUNTY,
				p_postal_code		  => rec_student_addr.POSTAL_CODE,
				p_address_lines_phonetic  => rec_student_addr.address_lines_phonetic,
				p_delivery_point_code	  => rec_student_addr.delivery_point_code,
				p_other_details_1	  => NULL,
				p_other_details_2	  => NULL,
				p_other_details_3	  => NULL,
				l_return_status   	  => l_return_status  ,
				l_msg_data                => l_msg_data,
				p_party_id 		  => p_object_id,
				p_party_site_id		  => l_party_site_id,
				p_party_type		  => 'PERSON',
				p_last_update_date        => l_last_update_date	,
				p_party_site_ovn	  => l_party_site_ovn,
				p_location_ovn		  => l_location_ovn,
				p_status		  => rec_student_addr.status
				);

			IF l_return_status IN ('E','U') THEN
			  -- ssawhney bug 2338473
			  IF l_msg_count > 1 THEN
				 FOR i IN 1..l_msg_count  LOOP
				 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
				 tmp_var1 := tmp_var1 || ' '|| tmp_var;
				 END LOOP;
				 l_msg_data := tmp_var1;
			  END IF;
			  RETURN;
			END IF;
		    -- create the usage but before that initialise the variables
		    --
		    l_return_status    := NULL;
		    l_msg_count        := 0;
		    l_msg_data         := NULL;
		    l_last_update_date := NULL;
		    l_rowid            := NULL;
		    l_object_version_number := NULL;

		    IGS_PE_PARTY_SITE_USE_PKG.HZ_PARTY_SITE_USES_AK(
			p_action		      => 'INSERT',
			p_rowid 		      => l_rowid,
			p_party_site_use_id	      => l_party_site_use_id,
			p_party_site_id		      => l_party_site_id,
			p_site_use_type		      => l_profile_addr_usage,
			p_return_status   	      => l_return_status,
			p_msg_data                    => l_msg_data,
			p_last_update_date	      => l_last_update_date,
			p_site_use_last_update_date   => l_site_last_update_date,
			p_profile_last_update_date    => l_profile_last_update_date,
			p_status		      => 'A',
			P_HZ_PARTY_SITE_USE_OVN       => l_object_version_number
		    );

			IF l_return_status IN ('E','U') THEN
			  -- ssawhney bug 2338473
			  IF l_msg_count > 1 THEN
				 FOR i IN 1..l_msg_count  LOOP
				 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
				 tmp_var1 := tmp_var1 || ' '|| tmp_var;
				 END LOOP;
				 l_msg_data := tmp_var1;
			  END IF;
			  RETURN;
			END IF;

		END IF; -- Address Exists p_validate = TRUE

	  END IF;  -- end of  l_student_age < l_student_age_bar

   END copy_address_and_usage;

 /*
   WHO       WHEN          WHAT
   skpandey  31-AUG-2005  Bug: 4582514
                          Description: : Call api (INSERT_ROW/ADD_ROW) only when p_caller is not 'ORGANIZATION'; and pass 'F' for x_directional_flag parameter in ADD_ROW
*/


 PROCEDURE CREATUPDATE_PARTY_RELATIONSHIP(
   p_action IN VARCHAR2 ,
   p_subject_id IN NUMBER ,
   p_object_id IN NUMBER ,
   p_party_relationship_type IN VARCHAR2 ,
   p_relationship_code IN VARCHAR2,
   p_comments IN VARCHAR2 ,
   p_start_date IN DATE,
   p_end_date IN DATE,
   p_last_update_date IN OUT NOCOPY DATE ,
   p_return_status OUT NOCOPY VARCHAR2 ,
   p_msg_count OUT NOCOPY NUMBER ,
   p_msg_data OUT NOCOPY VARCHAR2 ,
   p_party_relationship_id IN OUT NOCOPY VARCHAR2 ,
   p_party_id OUT NOCOPY NUMBER ,
   p_party_number OUT NOCOPY VARCHAR2,
   p_caller IN VARCHAR2 ,
   P_Object_Version_Number IN OUT NOCOPY NUMBER,
   P_Primary IN VARCHAR2 ,
   P_Secondary IN VARCHAR2,
   P_Joint_Salutation IN VARCHAR2,
   P_Next_To_Kin IN VARCHAR2 ,
   P_Rep_Faculty IN VARCHAR2,
   P_Rep_Staff IN VARCHAR2,
   P_Rep_Student IN VARCHAR2,
   P_Rep_Alumni IN VARCHAR2,
   p_directional_flag IN VARCHAR2,
   p_emergency_contact_flag IN VARCHAR2
 ) AS

CURSOR get_party_rel_type_cur(cp_relationship_type hz_relationship_types.relationship_type%type) IS
SELECT 'X'
FROM hz_relationship_types
WHERE RELATIONSHIP_TYPE = cp_relationship_type AND
SUBJECT_TYPE= 'PERSON' AND
OBJECT_TYPE='PERSON';

 l_party_rel_type VARCHAR2(1);
 -- lv_party_relationship_id NUMBER ;
 prel_rec hz_relationship_v2pub.relationship_rec_type;

 -- we dont want the party of the relation to be updated.

 p_party_rec hz_party_v2pub.party_rec_type;
 tmp_var   VARCHAR2(2000);
 tmp_var1  VARCHAR2(2000);

   l_rowid VARCHAR2(25);

x_party_object_version_number NUMBER := NULL;
l_result BOOLEAN := TRUE;

 PROCEDURE  Validate_Dml(p_start_date IN DATE,p_end_date IN DATE , p_subject_id IN NUMBER,p_Dml VARCHAR2)
 AS
 /*
   WHO       WHEN          WHAT
   pkpatel   11-JUN-2003  Bug 3002425
                          Modified the cursor for Date overlap. Passed the p_subject_id and removed the join with directional flag
   asbala    25-JUN-2003  Bug 3021520
                          Removed p_Dml = 'AFTER' condition from Validate_Dml
*/
 BEGIN
  IF p_DML = 'BEFORE' THEN
   DECLARE
      CURSOR per_birth_dt IS
      SELECT birth_date
      FROM   IGS_PE_PERSON_BASE_V
      WHERE  person_id  = p_subject_id;

     l_birth_date IGS_PE_PERSON_BASE_V.BIRTH_DATE%TYPE;
   BEGIN
     IF p_start_date > sysdate THEN
        fnd_message.set_name ('IGS', 'IGS_AD_ST_DT_LT_SYS_DT');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;
     IF p_end_date IS NOT NULL THEN
       IF p_start_date > p_end_date THEN
        fnd_message.set_name ('IGS', 'IGS_FI_ST_DT_LE_END_DT');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
       END IF ;
     END IF;
     OPEN per_birth_dt;
     FETCH per_birth_dt INTO l_birth_date;
     CLOSE per_birth_dt;
     IF l_birth_date IS NOT NULL AND p_start_date < l_birth_date THEN
       fnd_message.set_name ('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;
  END;
 END IF;

END Validate_Dml;

 BEGIN
   IF p_start_date IS  NOT NULL THEN
     prel_rec.start_date := p_start_date ;
   ELSE
     prel_rec.start_date := sysdate;
   END IF;

   prel_rec.comments :=  p_comments ;
   prel_rec.end_date := p_end_date ;

    Validate_Dml(
                 p_start_date => prel_rec.start_Date,
                 p_end_date   => prel_rec.end_date,
                 p_subject_id => p_subject_id,
                 p_Dml        => 'BEFORE' );

   IF p_action = 'INSERT' THEN
     prel_rec.subject_id := p_subject_id;
     prel_rec.object_id := p_object_id ;
     prel_rec.relationship_type :=  p_party_relationship_type ;
     prel_rec.relationship_code := p_relationship_code;

     -- Relationships can be created between PERSON and PERSON as well as
     -- PERSON and ORGANIZATION. SWS105 Person Rel Enhancement Bug 2613718

     prel_rec.subject_type := 'PERSON';

     select party_type into prel_rec.object_type from hz_parties where party_id = p_object_id;

     prel_rec.subject_table_name := 'HZ_PARTIES';
     prel_rec.object_table_name := 'HZ_PARTIES';
     prel_rec.content_source_type := 'USER_ENTERED';
     prel_rec.created_by_module := 'IGS';

     -- Generating And Passing the party number if the profile value is set to 'No' for generating the party number
     IF FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
       SELECT hz_party_number_s.nextval INTO   p_party_rec.party_number FROM   dual;
       prel_rec.party_rec := p_party_rec;
     END IF;



     HZ_RELATIONSHIP_V2PUB.create_relationship (
       p_relationship_rec            => prel_rec,
       x_relationship_id             => p_party_relationship_id,
       x_party_id                    => p_party_id,
       x_party_number                => p_party_number,
       x_return_status	             => p_return_status,
       x_msg_count                   => p_msg_count,
       x_msg_data                    => p_msg_data
     );

     IF p_return_status IN ('E','U') THEN
       -- ssawhney bug 2338473
       IF p_msg_count > 1 THEN
	 FOR i IN 1..p_msg_count  LOOP
	   tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
	   tmp_var1 := tmp_var1 || ' '|| tmp_var;
	 END LOOP;
	 p_msg_data := tmp_var1;
       END IF;
       RETURN;
     END IF;

     -- After successful creation of hz relationship record putting 1 in object version number
     p_object_version_number := 1;
      OPEN get_party_rel_type_cur(p_party_relationship_type);
      FETCH get_party_rel_type_cur INTO l_party_rel_type;
      CLOSE get_party_rel_type_cur;
      IF l_party_rel_type = 'X' THEN
      -- fix for bug 5254202
      l_result := Igs_Pe_Person_PKG.Get_PK_For_Validation(p_object_id);

      IGS_PE_HZ_REL_PKG.INSERT_ROW(
         x_rowid                  =>l_rowid ,
         x_relationship_id        =>p_party_relationship_id,
         x_directional_flag       =>'F',
         x_primary                =>p_primary,
         x_secondary              =>p_secondary,
         x_joint_salutation       =>p_joint_salutation,
         x_next_to_kin            =>p_next_to_kin,
         x_rep_faculty            =>p_rep_faculty,
         x_rep_staff              =>p_rep_staff,
         x_rep_student            =>p_rep_student,
         x_rep_alumni             =>p_rep_alumni,
         x_emergency_contact_flag =>p_emergency_contact_flag);
       END IF;

     -- get the out NOCOPY parameter for the last updated date.
     -- this cursor may return 2 records with the V2 APIs structure and HZpatchset C
     -- hence fetch only one record, both the records will have the same last update date and
     -- object version number


   ELSIF p_action = 'UPDATE'  THEN
     -- get the object_version_number , new methodology for locking in V2 apis
     -- this cursor may return 2 records with the V2 APIs structure and HZpatchset C
     -- hence fetch only one record, both the records will have the same last update date and
     -- object version number

     -- kumma. V2 API logic has been modified, and if a field which had data is made NULL
     -- then we have to explicitly pass it as G_MISS_CHAR.
     -- cross checked with API coding standards also. bug number 2314209

     IF p_comments IS NULL THEN
       prel_rec.comments := FND_API.G_MISS_CHAR;
     END IF;
    -- skpandey. If end date field which had data is made NULL
    -- then we have to explicitly pass it as G_MISS_DATE.
     IF p_end_date IS NULL THEN
       prel_rec.end_date := FND_API.G_MISS_DATE;
     END IF;

     prel_rec.relationship_id :=  p_party_relationship_id ;

     HZ_RELATIONSHIP_V2PUB.update_relationship (
       p_init_msg_list  => null,
       p_relationship_rec            => prel_rec,
       p_object_version_number       => p_object_version_number,
       p_party_object_version_number => x_party_object_version_number ,
       x_return_status	       => p_return_status,
       x_msg_count                   => p_msg_count,
       x_msg_data                    => p_msg_data );

       IF p_return_status IN ('E','U') THEN

	 -- ssawhney bug 2338473
	 IF p_msg_count > 1 THEN
	   FOR i IN 1..p_msg_count  LOOP
	     tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
	     tmp_var1 := tmp_var1 || ' '|| tmp_var;
	   END LOOP;
	   p_msg_data := tmp_var1;
	 END IF;
         RETURN;
       END IF;
     -- Added a condition that if p_caller is not ORGANIZATION. Bug#4582514
      OPEN get_party_rel_type_cur(p_party_relationship_type);
      FETCH get_party_rel_type_cur INTO l_party_rel_type;
      CLOSE get_party_rel_type_cur;
      IF l_party_rel_type = 'X' THEN
      IGS_PE_HZ_REL_PKG.ADD_ROW(
         x_rowid                  =>l_rowid ,
         x_relationship_id        =>p_party_relationship_id,
         x_directional_flag       =>'F',
         x_primary                =>p_primary,
         x_secondary              =>p_secondary,
         x_joint_salutation       =>p_joint_salutation,
         x_next_to_kin            =>p_next_to_kin,
         x_rep_faculty            =>p_rep_faculty,
         x_rep_staff              =>p_rep_staff,
         x_rep_student            =>p_rep_student,
         x_rep_alumni             =>p_rep_alumni,
	 x_emergency_contact_flag =>p_emergency_contact_flag);
       END IF;
     END IF;


 END creatupdate_party_relationship ;

END igs_pe_relationships_pkg;

/
