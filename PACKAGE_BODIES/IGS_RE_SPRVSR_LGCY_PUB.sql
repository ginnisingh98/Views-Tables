--------------------------------------------------------
--  DDL for Package Body IGS_RE_SPRVSR_LGCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RE_SPRVSR_LGCY_PUB" AS
/* $Header: IGSRE19B.pls 120.4 2006/02/15 01:45:32 bdeviset noship $ */

/*------------------------------------------------------------------------------+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA       |
 |                            All rights reserved.                              |
 +==============================================================================+
 |                                                                              |
 | DESCRIPTION                                                                  |
 |      PL/SQL body for package: igs_re_sprvsr_lgcy_pub                         |
 |                                                                              |
 | NOTES : Research Supervisor Legacy API. This API imports supervisor          |
 |         information against the specified program attempt / candidature.     |
 |         Created as part of Enrollment Legacy build. Bug# 2661533             |
 |                                                                              |
 | HISTORY                                                                      |
 | Who      When           What                                                 |
 |                                                                              |
 +==============================================================================+
 |Nalin Kumar   28-Jan-2003  Modified create_sprvsr.c_repl_person_dtls cursor to fetch sequence_number by comparing person_id; |
 |                           Previously it was fetching replaced_sequence_number by comparing replaced_person_id;              |
 |                           This is to fix bug# 2725852.                                                                      |
 *==============================================================================*/

  g_pkg_name  CONSTANT VARCHAR2(30) := 'IGS_RE_SPRVSR_LGCY_PUB';

  FUNCTION validate_parameters
  (
    p_sprvsr_dtls_rec IN sprvsr_dtls_rec_type
  ) RETURN VARCHAR2 AS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 14-Nov-02
  Purpose         :  This function is used to validate the input parameters.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/
   l_msg_count      NUMBER;
   l_msg_data       VARCHAR2(2000);
   l_sprvsr_status  VARCHAR2(10) := 'VALID';

 BEGIN

    -- Check whether the passed person number is null or not.
    IF p_sprvsr_dtls_rec.ca_person_number IS NULL OR p_sprvsr_dtls_rec.person_number IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_EN_PER_NUM_NULL');
      FND_MSG_PUB.Add;
      l_sprvsr_status := 'INVALID';
    END IF;

    -- Check whether the user has passed program code or not.
    IF p_sprvsr_dtls_rec.program_cd IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_EN_PRGM_CD_NULL');
       FND_MSG_PUB.Add;
       l_sprvsr_status := 'INVALID';
    END IF;

    -- Check whether the start date is null or not.
    IF p_sprvsr_dtls_rec.start_dt IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_PS_STARDT_NOT_NULL');
       FND_MSG_PUB.Add;
       l_sprvsr_status := 'INVALID';
    END IF;

    -- Check whether the research supervisor type is null or not
    IF p_sprvsr_dtls_rec.research_supervisor_type IS NULL THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_RE_SPRVSR_TYP_NULL');
       FND_MSG_PUB.Add;
       l_sprvsr_status := 'INVALID';
    ELSE
      BEGIN

        -- If research supervisor is specified then validate it by calling the check constraints. Incase if there is
        -- any error it will log an error message "IGS_GE_INVALID_VALUE", which doesn't give much info. to the user.
        -- So we delete that message and add a meaningful message to the stack.

        igs_re_sprvsr_pkg.check_constraints ('RESEARCH_SUPERVISOR_TYPE', p_sprvsr_dtls_rec.research_supervisor_type);

      EXCEPTION
         WHEN OTHERS THEN
           FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                      p_data           => l_msg_data);

           -- Delete the message 'IGS_GE_INVALID_VALUE'
           FND_MSG_PUB.DELETE_MSG (l_msg_count);

           -- set the customized message
           FND_MESSAGE.Set_Name('IGS','IGS_RE_SPRVSR_TYPE_VAL');
           FND_MSG_PUB.Add;
           l_sprvsr_status := 'INVALID';
       END;
    END IF;


    IF p_sprvsr_dtls_rec.supervision_percentage IS NOT NULL THEN
      BEGIN
        igs_re_sprvsr_pkg.check_constraints ('SUPERVISION_PERCENTAGE', p_sprvsr_dtls_rec.supervision_percentage);
      EXCEPTION
        WHEN OTHERS THEN
          FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                     p_data           => l_msg_data);

          FND_MSG_PUB.DELETE_MSG (l_msg_count);
          FND_MESSAGE.Set_Name('IGS','IGS_RE_SPRVSN_PERC_INVALID_VAL');
          FND_MSG_PUB.Add;
          l_sprvsr_status := 'INVALID';
      END;
    END IF;


    IF p_sprvsr_dtls_rec.funding_percentage IS NOT NULL THEN
      BEGIN
         igs_re_sprvsr_pkg.check_constraints ('FUNDING_PERCENTAGE', p_sprvsr_dtls_rec.funding_percentage);
      EXCEPTION
         WHEN OTHERS THEN
           FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                      p_data           => l_msg_data);

           FND_MSG_PUB.DELETE_MSG (l_msg_count);
           FND_MESSAGE.Set_Name('IGS','IGS_RE_FUND_PERC_INVALID_VAL');
           FND_MSG_PUB.Add;
           l_sprvsr_status := 'INVALID';
      END;
    END IF;


    IF p_sprvsr_dtls_rec.org_unit_cd IS NOT NULL THEN
      BEGIN
         igs_re_sprvsr_pkg.check_constraints ('ORG_UNIT_CD', p_sprvsr_dtls_rec.org_unit_cd);
      EXCEPTION
         WHEN OTHERS THEN
           FND_MSG_PUB.COUNT_AND_GET( p_count          => l_msg_count,
                                      p_data           => l_msg_data);
           FND_MSG_PUB.DELETE_MSG (l_msg_count);
           FND_MESSAGE.Set_Name('IGS','IGS_FI_INVALID_ORG_UNIT_CD');
           FND_MESSAGE.SET_TOKEN('ORG_CD',p_sprvsr_dtls_rec.org_unit_cd);
           FND_MSG_PUB.Add;
           l_sprvsr_status := 'INVALID';
      END;
    END IF;

    RETURN l_sprvsr_status;

 END validate_parameters;


 FUNCTION validate_sprvsr
 (
   p_person_id          IN  igs_re_sprvsr.person_id%TYPE,
   p_sprvsr_dtls_rec    IN  sprvsr_dtls_rec_type,
   p_ca_person_id       IN  igs_re_sprvsr.ca_person_id%TYPE,
   p_ca_sequence_number IN  igs_re_sprvsr.ca_sequence_number%TYPE,
   p_ou_start_dt        IN  igs_re_sprvsr.ou_start_dt%TYPE
 ) RETURN VARCHAR2 AS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 14-Nov-02
  Purpose         :  This function is used to validate the business logic.
  Known limitations,enhancements,remarks:
  Change History
  Who         When          What
  bdeviset    27-Jan-2006   Modified cursor c_date_ovrlp.Used the call igs_en_gen_003.get_staff_ind
                            and removed cursor c_staff_ind for bug# 4995230
  bdeviset    13-Feb-2006   REplaced cursor c_meaning with fnd_message.set and get and using the cursor c_org_unit_exists
                            instead of literal when no where clause exists.Bug# 5034696
 ***********************************************************************************************/



  -- Cursor to get the sequence number of the person
  CURSOR c_person_dtls ( l_person_id igs_re_sprvsr.person_id%TYPE, l_ca_person_id igs_re_sprvsr.ca_person_id%TYPE,
                         l_ca_sequence_number igs_re_sprvsr.ca_sequence_number%TYPE ) IS
    SELECT sequence_number
    FROM   igs_re_sprvsr
    WHERE  person_id = l_person_id
    AND    ca_person_id = l_ca_person_id
    AND    ca_sequence_number = l_ca_sequence_number;

  -- Cursor to get the replaced sequence number of the person
  CURSOR c_repl_person_dtls ( l_repl_person_id igs_re_sprvsr.replaced_person_id%TYPE ) IS
    SELECT  replaced_sequence_number
    FROM    igs_re_sprvsr
    WHERE   replaced_person_id = l_repl_person_id;

  CURSOR c_date_ovrlp (l_sequence_number IN NUMBER ) IS
    SELECT 'x'
    FROM igs_re_sprvsr rsup, igs_pe_person_base_v pdv
    WHERE rsup.ca_person_id = p_ca_person_id
    AND rsup.ca_sequence_number = p_ca_sequence_number
    AND rsup.person_id = p_person_id
    AND rsup.sequence_number = l_sequence_number
    AND (rsup.end_dt IS NULL OR rsup.end_dt > p_sprvsr_dtls_rec.start_dt)
    AND rsup.person_id = pdv.person_id;

  CURSOR c_org_unit_exists (cp_org_unit_cd igs_or_unit.org_unit_cd%TYPE) IS
    SELECT 'X'
    FROM igs_or_unit
    WHERE org_unit_cd = cp_org_unit_cd;

  TYPE c_ref_cur IS REF CURSOR;

 l_staff_member_ind   igs_pe_person.staff_member_ind%TYPE;
 l_message_name       VARCHAR2(30) DEFAULT NULL;
 l_result             BOOLEAN;
 l_where_clause       VARCHAR2(450);
 c_org_cur            c_ref_cur ;
 curr_stat            VARCHAR2(500);
 l_rec_found          varchar2(1);
 l_ca_person_id       igs_re_sprvsr.ca_person_id%TYPE;
 l_legacy             VARCHAR2(1)  DEFAULT 'Y';
 l_sprvsr_status      VARCHAR2(10) DEFAULT 'VALID';
 l_sequence_number     igs_re_sprvsr.sequence_number%TYPE;
 l_replaced_person_id  igs_re_sprvsr.replaced_person_id%TYPE;
 l_replaced_sequence_number igs_re_sprvsr.replaced_sequence_number%TYPE;
 l_date_ovrlp         c_date_ovrlp%ROWTYPE;
 l_message_text       fnd_new_messages.message_text%TYPE;

 BEGIN

  l_staff_member_ind := igs_en_gen_003.get_staff_ind(p_person_id) ;

   -- Call to check all funding related validations.
   l_result :=  igs_re_val_rsup.resp_val_rsup_fund (
                     p_person_id ,
                     p_sprvsr_dtls_rec.org_unit_cd ,
                     p_ou_start_dt ,
                     p_sprvsr_dtls_rec.funding_percentage ,
                     l_staff_member_ind,
                     l_legacy,
                     l_message_name
                   );

   IF l_message_name IS NOT NULL THEN
      l_sprvsr_status := 'INVALID';
      l_message_name := NULL;
   END IF;

   -- Check for Oraganisation Unit Code when the person is a staff member.
   IF l_staff_member_ind = 'Y' THEN
      l_result := igs_re_val_rsup.resp_val_rsup_ou (
                    p_person_id ,
                    p_sprvsr_dtls_rec.org_unit_cd ,
                    p_ou_start_dt,
                    l_staff_member_ind ,
                    l_legacy,
                    l_message_name
                  );

      IF l_message_name IS NOT NULL THEN
         l_sprvsr_status := 'INVALID';
         l_message_name := NULL;
      END IF;

   END IF;

   IF p_sprvsr_dtls_rec.end_dt IS NOT NULL THEN
      OPEN c_person_dtls(p_person_id, p_ca_person_id, p_ca_sequence_number);
      FETCH c_person_dtls INTO l_sequence_number;
      CLOSE c_person_dtls;

      -- Check whether Supervision end date must be earlier than the start date of replacement supervisor.
      l_result := igs_re_val_rsup.resp_val_rsup_end_dt (
                     p_ca_person_id ,
                     p_ca_sequence_number ,
                     p_person_id ,
                     l_sequence_number  ,
                     p_sprvsr_dtls_rec.start_dt,
                     p_sprvsr_dtls_rec.end_dt ,
                     l_legacy,
                     l_message_name
                   );

      IF l_message_name IS NOT NULL THEN
         l_sprvsr_status := 'INVALID';
         l_message_name := NULL;
      END IF;

      -- Check whether there is any overlap of date.
      OPEN c_date_ovrlp(l_sequence_number);
      FETCH c_date_ovrlp INTO l_date_ovrlp;
      IF c_date_ovrlp%FOUND THEN
         FND_MESSAGE.SET_NAME('IGS', 'IGS_RE_END_DT_CANT_GE_ST_DT');
         FND_MSG_PUB.Add;
      END IF;
      CLOSE c_date_ovrlp;

   END IF;


    IF p_sprvsr_dtls_rec.replaced_person_number IS NOT NULL THEN

       l_replaced_person_id := Igs_Ge_Gen_003.Get_Person_id (p_sprvsr_dtls_rec.replaced_person_number);

       OPEN c_repl_person_dtls(l_replaced_person_id);
       FETCH c_repl_person_dtls INTO l_replaced_sequence_number;
       CLOSE c_repl_person_dtls;

       -- The call to the function resp_val_rsup_repl does the following validations
       -- A supervisor cannot replace themselves.
       -- A supervisor can only replace the latest instance of another supervisor
       -- A replaced supervisor must have been ended.
       -- A replacement supervisor cannot overlap the replaced supervisor

        l_result := igs_re_val_rsup.resp_val_rsup_repl(
                     p_ca_person_id ,
                     p_ca_sequence_number ,
                     p_person_id ,
                     p_sprvsr_dtls_rec.start_dt,
                     l_replaced_person_id ,
                     l_replaced_sequence_number ,
                     l_legacy,
                     l_message_name
                   );

       IF l_message_name IS NOT NULL THEN
          l_sprvsr_status := 'INVALID';
          l_message_name := NULL;
       END IF;

    END IF;

   -- Organisation unit filter integration validation. Call to find the filter condition
   -- modified the code for bug 5028599
   IF p_sprvsr_dtls_rec.org_unit_cd IS NOT NULL THEN

      l_rec_found := NULL;
      igs_or_gen_012_pkg.get_where_clause_api('RES_SPRVSR_LGCY', l_where_clause);
      IF l_where_clause IS NOT NULL THEN
         l_where_clause := CONCAT(' AND ',l_where_clause);

         curr_stat := 'SELECT ''x'' FROM igs_or_unit WHERE org_unit_cd = :1 '||l_where_clause;
         OPEN c_org_cur FOR curr_stat USING p_sprvsr_dtls_rec.org_unit_cd,'RES_SPRVSR_LGCY';
         FETCH c_org_cur INTO l_rec_found;
         CLOSE c_org_cur;

      ELSE

        OPEN c_org_unit_exists (p_sprvsr_dtls_rec.org_unit_cd);
        FETCH c_org_unit_exists INTO l_rec_found;
        CLOSE c_org_unit_exists;

      END IF;



      IF l_rec_found IS NULL THEN

         FND_MESSAGE.SET_NAME('IGS','IGS_RE_ORG_UNIT_CD');
         l_message_text := FND_MESSAGE.GET();

         FND_MESSAGE.SET_NAME('IGS','IGS_EN_INV');
         FND_MESSAGE.SET_TOKEN('PARAM',l_message_text);
         FND_MSG_PUB.Add;
         l_sprvsr_status := 'INVALID';
      END IF;

   END IF;

   -- Check whether research student is the same as the supervisor
   IF NOT igs_re_val_rsup.resp_val_rsup_person( p_ca_person_id, p_person_id, l_legacy , l_message_name ) THEN
      IF l_message_name IS NOT NULL THEN
         FND_MESSAGE.SET_NAME('IGS',l_message_name);
         FND_MSG_PUB.Add;
         l_sprvsr_status := 'INVALID';
	 l_message_name := NULL;
      END IF;
   END IF;

  -- Validate research supervisor overlaps.
   IF igs_re_val_rsup.resp_val_rsup_ovrlp( p_ca_person_id, p_ca_sequence_number, p_person_id, l_sequence_number,
                                           p_sprvsr_dtls_rec.start_dt, p_sprvsr_dtls_rec.end_dt, l_legacy, l_message_name ) THEN
     IF l_message_name IS NOT NULL THEN
        l_sprvsr_status := 'INVALID';
     END IF;
   END IF;


   RETURN l_sprvsr_status;

 END validate_sprvsr;



 FUNCTION validate_sprvsr_db_cons
 (
   p_person_id          IN   igs_re_sprvsr.person_id%TYPE,
   p_sprvsr_dtls_rec    IN   sprvsr_dtls_rec_type,
   p_ca_person_id       IN   igs_re_sprvsr.ca_person_id%TYPE,
   p_ca_sequence_number IN   igs_re_sprvsr.ca_sequence_number%TYPE,
   p_sprvsr_status      OUT  NOCOPY VARCHAR2
 ) RETURN VARCHAR2 AS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 14-Nov-02
  Purpose         :  This function is used to validate the database constraints.
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What
 ***********************************************************************************************/

  CURSOR c_person_dtls ( l_person_id igs_re_sprvsr.person_id%TYPE, l_ca_person_id igs_re_sprvsr.ca_person_id%TYPE,
                         l_ca_sequence_number igs_re_sprvsr.ca_sequence_number%TYPE ) IS
    SELECT sequence_number, start_dt
    FROM   igs_re_sprvsr
    WHERE  person_id = l_person_id
    AND    ca_person_id = l_ca_person_id
    AND    ca_sequence_number = l_ca_sequence_number;

  l_person_dtls         c_person_dtls%ROWTYPE;
  l_ret_value           VARCHAR2(1) := 'S';
  l_ca_person_id        igs_re_sprvsr.ca_person_id%TYPE;
  l_ca_sequence_number  igs_re_sprvsr.ca_sequence_number%TYPE;
  l_result              BOOLEAN;

 BEGIN

   p_sprvsr_status := 'VALID';

   OPEN c_person_dtls(p_person_id, p_ca_person_id, p_ca_sequence_number);
   FETCH c_person_dtls INTO l_person_dtls;
   CLOSE c_person_dtls;

   -- Check for Unique Key validation. If validation fails, stop the processing and return back
   -- to the calling procedure.

  IF igs_re_sprvsr_pkg.get_uk1_for_validation ( p_ca_person_id, p_ca_sequence_number,
                                                 p_person_id, p_sprvsr_dtls_rec.start_dt ) THEN
      FND_MESSAGE.Set_Name('IGS','IGS_RE_SPRVSR_EXTS');
      FND_MSG_PUB.Add;
      p_sprvsr_status := 'INVALID';
      l_ret_value := 'W';
      RETURN l_ret_value;
   END IF;

   IF NOT igs_re_candidature_pkg.get_pk_for_validation (  p_ca_person_id, p_ca_sequence_number ) THEN
      FND_MESSAGE.Set_Name('IGS','IGS_RE_CAND_NOT_EXTS');
      FND_MSG_PUB.Add;
      p_sprvsr_status := 'INVALID';
      l_ret_value := 'E';
   END IF;

   IF  NOT igs_re_sprvsr_type_pkg.get_pk_for_validation (p_sprvsr_dtls_rec.research_supervisor_type) THEN
      FND_MESSAGE.Set_Name('IGS','IGS_RE_SPRVSR_TYP_NT_EXTS');
      fnd_message.set_token('TYPE',p_sprvsr_dtls_rec.research_supervisor_type);
      FND_MSG_PUB.Add;
      p_sprvsr_status := 'INVALID';
      l_ret_value := 'E';
   END IF;

   RETURN l_ret_value;

 END validate_sprvsr_db_cons;


 PROCEDURE create_sprvsr
 (
    p_api_version             IN           NUMBER,
    p_init_msg_list           IN           VARCHAR2,
    p_commit                  IN           VARCHAR2,
    p_validation_level        IN           NUMBER,
    p_sprvsr_dtls_rec         IN           sprvsr_dtls_rec_type ,
    x_return_status           OUT  NOCOPY  VARCHAR2,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2
 ) AS

 /**********************************************************************************************
  Created By      : pradhakr
  Date Created By : 14-Nov-02
  Purpose         : This procedure imports the legacy data inot OSS tables. Before inserting it
                    validates the input parameters, checks for Data Integrity Constraints and
                    business validations.
  Known limitations,enhancements,remarks:
  Change History
  Who           When         What
  Nalin Kumar   28-Jan-2003  Modified create_sprvsr.c_repl_person_dtls cursor to fetch sequence_number by comparing person_id;
                             Previously it was fetching replaced_sequence_number by comparing replaced_person_id;
                             This is to fix bug# 2725852.
 ***********************************************************************************************/

  CURSOR c_next_val IS
    SELECT igs_re_sprvsr_seq_num_s.nextval
    FROM dual;

  CURSOR c_repl_person_dtls (l_repl_person_id igs_re_sprvsr.replaced_person_id%TYPE) IS
    SELECT sequence_number
    FROM igs_re_sprvsr
    WHERE person_id = l_repl_person_id;


  l_ca_sequence_number          igs_re_sprvsr.ca_sequence_number%TYPE;
  l_ca_person_id                igs_re_sprvsr.ca_person_id%TYPE;
  l_person_id                   igs_re_sprvsr.person_id%TYPE;
  l_replaced_person_id          igs_re_sprvsr.replaced_person_id%TYPE;
  l_ou_start_dt                 DATE;
  l_result                      BOOLEAN;
  l_api_name                    CONSTANT    VARCHAR2(30) := 'Create_Sprvsr';
  l_api_version                 CONSTANT    NUMBER       := 1.0;
  p_sprvsr_status               VARCHAR2(10) DEFAULT 'VALID';
  l_sequence_number             NUMBER;
  l_replaced_sequence_number    igs_re_sprvsr.replaced_sequence_number%TYPE;

  l_creation_date               DATE;
  l_last_update_date            DATE;
  l_created_by                  NUMBER;
  l_last_updated_by             NUMBER;
  l_last_update_login           NUMBER;
  l_ret_val                     VARCHAR2(1) DEFAULT 'S';

 BEGIN

    -- Create a savepoint.
    SAVEPOINT    create_re_sprvsr_pub;

    -- Check for the Compatible API call
    IF NOT FND_API.Compatible_Api_Call(  l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         g_pkg_name) THEN

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- If the calling program has passed the parameter for initializing the message list
    IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
    END IF;

    -- Set the return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Validate input paramaters
    p_sprvsr_status := validate_parameters(p_sprvsr_dtls_rec);

    IF p_sprvsr_status = 'INVALID' THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF p_sprvsr_status = 'VALID' THEN
       -- Check whether ca_person_number is valid or not.
       l_ca_person_id := Igs_Ge_Gen_003.Get_Person_id (p_sprvsr_dtls_rec.ca_person_number);

       IF l_ca_person_id IS NULL THEN
          -- Add exception to stack
          FND_MESSAGE.Set_Name('IGS','IGS_GE_INVALID_PERSON_NUMBER');
          FND_MSG_PUB.Add;
          p_sprvsr_status := 'INVALID';
       END IF;

       -- Check whether ca_person_number is valid or not.
       l_person_id := Igs_Ge_Gen_003.Get_Person_id (p_sprvsr_dtls_rec.person_number);

       IF l_person_id IS NULL THEN
          FND_MESSAGE.Set_Name('IGS','IGS_GE_INVALID_PERSON_NUMBER');
          FND_MSG_PUB.Add;
          p_sprvsr_status := 'INVALID';
       END IF;

       --  Check whether candidacy details exists, if it exists then get the ca_sequence_number
       l_result := igs_re_val_the.get_candidacy_dtls (
                     l_ca_person_id,
                     p_sprvsr_dtls_rec.program_cd,
                     l_ca_sequence_number
                   );

  	IF NOT l_result THEN
           FND_MESSAGE.Set_Name('IGS','IGS_RE_CAND_NOT_EXTS');
           FND_MSG_PUB.Add;
           p_sprvsr_status := 'INVALID';
        END IF;

        -- Get the start date of the organisation
        l_result :=  igs_re_val_rsup.get_org_unit_dtls (
                       p_sprvsr_dtls_rec.org_unit_cd ,
                       l_ou_start_dt
                     );

        IF p_sprvsr_status = 'INVALID' THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;


    IF p_sprvsr_status = 'VALID' THEN
       -- Validate all db constraints
       l_ret_val := validate_sprvsr_db_cons ( l_person_id, p_sprvsr_dtls_rec, l_ca_person_id, l_ca_sequence_number, p_sprvsr_status );

       IF l_ret_val = 'E' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       ELSIF l_ret_val = 'W' THEN
          x_return_status := 'W';
       ELSIF l_ret_val = 'S' THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
    END IF;


    IF p_sprvsr_status = 'VALID' THEN

       IF p_sprvsr_dtls_rec.replaced_person_number IS NOT NULL THEN
          l_replaced_person_id := Igs_Ge_Gen_003.Get_Person_id (p_sprvsr_dtls_rec.replaced_person_number);
          OPEN c_repl_person_dtls(l_replaced_person_id);
          FETCH c_repl_person_dtls INTO l_replaced_sequence_number;
          CLOSE c_repl_person_dtls;
       END IF;

       -- Validate the business rules
       p_sprvsr_status := validate_sprvsr ( l_person_id, p_sprvsr_dtls_rec, l_ca_person_id, l_ca_sequence_number , l_ou_start_dt);

       IF p_sprvsr_status = 'INVALID' THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;

    END IF;



    IF p_sprvsr_status = 'VALID' THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       l_creation_date := SYSDATE;
       l_created_by := FND_GLOBAL.USER_ID;
       l_last_update_date := SYSDATE;
       l_last_updated_by := FND_GLOBAL.USER_ID;
       l_last_update_login :=FND_GLOBAL.LOGIN_ID;

       IF l_created_by IS NULL THEN
          l_created_by := -1;
       END IF;

       IF l_last_updated_by IS NULL THEN
          l_last_updated_by := -1;
       END IF;

       IF l_last_update_login IS NULL THEN
          l_last_update_login := -1;
       END IF;

       BEGIN

         OPEN c_next_val;
         FETCH c_next_val INTO l_sequence_number;
         CLOSE c_next_val;

         -- Insert the record in IGS_RE_SPRVSR table
         INSERT INTO igs_re_sprvsr (
            ca_person_id,
            ca_sequence_number,
            person_id,
            sequence_number,
            start_dt,
            end_dt,
            research_supervisor_type,
            supervisor_profession,
            supervision_percentage,
            funding_percentage,
            org_unit_cd,
            ou_start_dt,
            replaced_person_id,
            replaced_sequence_number,
            comments,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login )
         VALUES (
            l_ca_person_id,
            l_ca_sequence_number,
            l_person_id,
            l_sequence_number,
            p_sprvsr_dtls_rec.start_dt,
            p_sprvsr_dtls_rec.end_dt,
            p_sprvsr_dtls_rec.research_supervisor_type,
            p_sprvsr_dtls_rec.supervisor_profession,
            p_sprvsr_dtls_rec.supervision_percentage,
            p_sprvsr_dtls_rec.funding_percentage,
            p_sprvsr_dtls_rec.org_unit_cd,
            l_ou_start_dt,
            l_replaced_person_id,
            l_replaced_sequence_number,
            p_sprvsr_dtls_rec.comments,
            l_created_by,
            l_creation_date,
            l_last_updated_by,
            l_last_update_date,
            l_last_update_login
          );

       EXCEPTION
          WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_ERROR;
             p_sprvsr_status := 'INVALID';
             ROLLBACK TO create_re_sprvsr_pub;
       END;

       -- Commit the record which is inserted in the table.
       IF (FND_API.To_Boolean(p_commit) and p_sprvsr_status = 'VALID') THEN
          COMMIT WORK;
       END IF;

    END IF;

    FND_MSG_PUB.COUNT_AND_GET( p_count   => x_msg_count,
                               p_data    => x_msg_data);

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_re_sprvsr_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                p_data           => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_re_sprvsr_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO create_re_sprvsr_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,
                                 l_api_name);
      END IF;
      FND_MSG_PUB.COUNT_AND_GET( p_count          => x_msg_count,
                                 p_data           => x_msg_data);

  END create_sprvsr;

END igs_re_sprvsr_lgcy_pub;

/
