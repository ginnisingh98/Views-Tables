--------------------------------------------------------
--  DDL for Package Body IGS_PS_SCH_INT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_SCH_INT_API_PUB" AS
/* $Header: IGSPS80B.pls 120.1 2005/06/29 04:06:28 appldev ship $ */

  g_pkg_name          CONSTANT     VARCHAR2(30) := 'IGS_PS_SCH_INT_API_PUB';
  g_n_user_id igs_ps_unit_ver_all.created_by%TYPE := NVL(fnd_global.user_id,-1);          -- Stores the User Id
  g_n_login_id igs_ps_unit_ver_all.last_update_login%TYPE := NVL(fnd_global.login_id,-1); -- Stores the Login Id


  PROCEDURE Insert_schedule(   p_api_version                IN               NUMBER,
                               p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
                               p_commit                     IN               VARCHAR2 := FND_API.G_FALSE ,
                               p_validation_level           IN               NUMBER := FND_API.G_VALID_LEVEL_FULL ,
                               x_return_status              OUT NOCOPY       VARCHAR2,
                               x_msg_count                  OUT NOCOPY       NUMBER,
                               x_msg_data                   OUT NOCOPY       VARCHAR2,
                               p_transaction_type           IN               VARCHAR2,
                               p_cal_type                   IN               VARCHAR2,
                               p_sequence_number            IN               NUMBER,
                               p_cal_start_dt               IN               DATE,
                               p_cal_end_dt                 IN               DATE,
                               p_uoo_id                     IN               NUMBER,
                               p_unit_section_occurrence_id IN               NUMBER,
                               p_start_time                 IN               DATE,
                               p_end_time                   IN               DATE,
                               p_building_id                IN               NUMBER,
                               p_room_id                    IN               NUMBER,
                               p_schedule_status            IN               VARCHAR2,
                               p_error_text                 IN               VARCHAR2,
                               p_org_id                     IN               NUMBER,
                               p_uso_start_date             IN               DATE,
                               p_uso_end_date               IN               DATE,
                               p_sunday                     IN               VARCHAR2,
                               p_monday                     IN               VARCHAR2,
                               p_tuesday                    IN               VARCHAR2,
                               p_wednesday                  IN               VARCHAR2,
                               p_thursday                   IN               VARCHAR2,
                               p_friday                     IN               VARCHAR2,
                               p_saturday                   IN               VARCHAR2
                           ) AS

/***********************************************************************************************
Created By:         schodava
Date Created By:    12-06-2001
Purpose:            This procedure is used to insert records in the Scheduling interface tables.
Known limitations,enhancements,remarks:
Change History
Who     When          What
jbegum  22-APR-2003   Enh bug#2833850
                      Added following parameters
                      p_uso_start_date,p_uso_end_date,p_sunday,p_monday,p_tuesday,p_wednesday,p_thursday,p_friday,p_saturday
smvk    10-Feb-2003   Bug # 2803385. Modified the variable buiding_code and room_code as building_id and
                      room_id respectively.
********************************************************************************************** */

    l_api_name       CONSTANT VARCHAR2(30) := 'Insert_sch';
    l_api_version    CONSTANT NUMBER       := 1.0;

  -- Cursor added as part of Enh bug#2833850
  CURSOR cur_usec(cp_n_usec_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
    SELECT *
    FROM igs_ps_usec_occurs_all
    WHERE unit_section_occurrence_id = cp_n_usec_id;

  -- Cursor added as part of Enh bug#2833850
  CURSOR c_cal(cp_c_cal_type igs_ca_inst.cal_type%TYPE,
               cp_n_sequence_number igs_ca_inst.sequence_number%TYPE) IS
    SELECT start_dt ,end_dt
    FROM   igs_ca_inst
    WHERE  cal_type = cp_c_cal_type AND
           sequence_number = cp_n_sequence_number;

  -- Cursor added as part of Enh bug#2833850
  CURSOR c_bld(cp_n_building_id igs_ad_building_all.building_id%TYPE) IS
    SELECT 'x'
    FROM   igs_ad_building_all
    WHERE  building_id = cp_n_building_id;

  -- Cursor added as part of Enh bug#2833850
  CURSOR c_room(cp_n_room_id igs_ad_room_all.room_id%TYPE) IS
    SELECT 'x'
    FROM   igs_ad_room_all
    WHERE  room_id = cp_n_room_id;

  -- Cursor added as part of Enh bug#2833850
  CURSOR c_bld_room(cp_n_room_id igs_ad_room_all.room_id%TYPE,
                    cp_n_building_id igs_ad_building_all.building_id%TYPE) IS

    SELECT 'x'
    FROM   igs_ad_room_all
    WHERE  room_id = cp_n_room_id AND
           building_id = cp_n_building_id;

  -- Local variables added as part of Enh bug#2833850
  rec_bld  c_bld%ROWTYPE;
  rec_room c_room%ROWTYPE;
  rec_bld_room c_bld_room%ROWTYPE;
  rec_cal c_cal%ROWTYPE;

  BEGIN

  -- Savepoint
  SAVEPOINT Insert_schedule_pub;

  -- Check if the API call is compatible
  IF NOT FND_API.Compatible_API_Call( l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name) THEN

      -- If the call is incompatible, then raise the unexpected error
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  -- If the p_init_msg_list is T, i.e. the calling program wants to initialise
  -- the message list, then the message list is initialised using the API call
  IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
  END IF;

  -- Set the return status as success for the api
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Enh bug#2833850
  -- Deriving teaching period start date and end date from the parameters p_cal_type , p_sequence_number

  OPEN c_cal(p_cal_type,p_sequence_number);
  FETCH c_cal INTO rec_cal;
  CLOSE c_cal;

  -- Enh bug#2833850
  -- Following validations have been added to validate the parameter values passed to insert scheduling api by third party software.
  -- These validations will ensure that the interface records inserted by the third party software thru insert scheduling api will
  -- get sucessfully imported to the production table of OSS


  FOR cur_usec_rec IN cur_usec(p_unit_section_occurrence_id) LOOP

     -- Validation 0
     -- Transaction type should have a valid value
     IF p_transaction_type IS NULL OR
        p_transaction_type NOT IN ('REQUEST','UPDATE','CANCEL') THEN
         FND_MESSAGE.Set_Name('IGS','IGS_FI_INVALID_TXN_TYPE');
         FND_MESSAGE.Set_Token('TXN_TYPE',p_transaction_type);
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 1
     -- Error text is mandatory for unit section occurrence scheduled as Error.

     IF p_schedule_status = 'ERROR' AND p_error_text IS NULL THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_SCH_ERR_TEXT_NULL');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 2
     -- Building  identifier are mandatory for successfully scheduled unit section occurrence

     IF p_schedule_status = 'OK' AND
        (p_building_id IS NULL) AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_SCH_BD_OR_RM_NULL');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 3
     -- Building and room identifier should be null for successfully cancelled unit section occurrence

     IF p_schedule_status = 'OK' AND
        (p_building_id IS NOT NULL OR p_room_id IS NOT NULL) AND
        p_transaction_type = 'CANCEL' THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_SCH_BD_OR_RM_NOT_NULL');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;


     -- Validation 4
     -- Checking if the scheduling done through third party software is conflicting with the existing schedule

     IF cur_usec_rec.schedule_status IN ('PROCESSING','USER_UPDATE','USER_CANCEL') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_CONFLICT_SCHD');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;


     -- Validation 5
     -- Unit Section Occurrence start date must be lesser than or equal to Unit Section Occurrence end date

     IF p_schedule_status = 'OK' AND
        p_uso_start_date IS NOT NULL AND
        p_uso_end_date IS NOT NULL AND
        p_uso_start_date > p_uso_end_date AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PE_EDT_LT_SDT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 6
     -- Unit Section Occurrence Start Date should be greater than or equal to Unit Section Start Date

     IF p_schedule_status = 'OK' AND
        p_uso_start_date IS NOT NULL AND
        p_uso_start_date < p_cal_start_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_STDT_GE_US_STDT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 7
     -- Unit Section Occurrence Start Date should be greater than or equal to Teaching Period Start Date

     IF p_schedule_status = 'OK' AND
        p_uso_start_date IS NOT NULL AND
        p_cal_start_dt IS NULL AND
        p_uso_start_date < rec_cal.start_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_STDT_GE_TP_STDT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 8
     -- Unit Section Occurrence Start Date must be less than or equal to Unit Section End Date

     IF p_schedule_status = 'OK' AND
        p_uso_start_date IS NOT NULL AND
        p_uso_start_date > p_cal_end_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_ST_DT_UOO_END_DT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 9
     -- Unit Section Occurrence Start Date must be less than or equal to Teaching Period End Date

     IF p_schedule_status = 'OK' AND
        p_uso_start_date IS NOT NULL AND
        p_cal_end_dt IS NULL AND
        p_uso_start_date > rec_cal.end_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_ST_DT_TP_END_DT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 10
     -- Unit Section Occurrence End Date should be greater than or equal to Unit Section Start Date

     IF p_schedule_status = 'OK' AND
        p_uso_end_date IS NOT NULL AND
        p_uso_end_date < p_cal_start_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_END_DT_UOO_ST_DT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 11
     -- Unit Section Occurrence End Date should be greater than or equal to Teaching Period Start Date

     IF p_schedule_status = 'OK' AND
        p_uso_end_date IS NOT NULL AND
        p_cal_start_dt IS NULL AND
        p_uso_end_date < rec_cal.start_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_END_DT_TP_ST_DT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 12
     -- Unit Section Occurrence End Date must be less than or equal to Unit Section End Date

     IF p_schedule_status = 'OK' AND
        p_uso_end_date IS NOT NULL AND
        p_uso_end_date > p_cal_end_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_ENDT_LE_US_ENDT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 13
     -- Unit Section Occurrence end Date must be less than or equal to Teaching Period End Date

     IF p_schedule_status = 'OK' AND
        p_uso_end_date IS NOT NULL AND
        p_cal_end_dt IS NULL AND
        p_uso_end_date > rec_cal.end_dt AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_ENDT_LE_TP_ENDT');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Validation 14
     -- Invalid Scheduled Building Identifier

     IF p_schedule_status = 'OK' AND
        p_building_id IS NOT NULL AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        OPEN c_bld(p_building_id);
        FETCH c_bld INTO rec_bld;
        IF c_bld%NOTFOUND THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_BUILDING_ID_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE c_bld;
     END IF;

     -- Validation 15
     -- Invalid Scheduled Room Identifier

     IF p_schedule_status = 'OK' AND
        p_room_id IS NOT NULL AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        OPEN c_room(p_room_id);
        FETCH c_room INTO rec_room;
        IF c_room%NOTFOUND THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_ROOM_ID_INVALID');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE c_room;
     END IF;

     -- Validation 16
     -- Scheduled room does not belong to scheduled building

     IF p_schedule_status = 'OK' AND
        p_building_id IS NOT NULL AND
        p_room_id IS NOT NULL AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        OPEN c_bld_room(p_room_id,p_building_id);
        FETCH c_bld_room INTO rec_bld_room;
        IF c_bld_room%NOTFOUND THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_ROOM_INV_FOR_BLD');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        CLOSE c_bld_room;

     END IF;

     -- Validation 17
     -- At least one day of the week should be checked

     IF p_schedule_status = 'OK' AND
        NVL(p_sunday,'N') = 'N'  AND
        NVL(p_monday,'N') = 'N'  AND
        NVL(p_tuesday,'N') = 'N' AND
        NVL(p_wednesday,'N') = 'N' AND
        NVL(p_thursday,'N') = 'N' AND
        NVL(p_friday,'N') = 'N' AND
        NVL(p_saturday,'N') = 'N' AND
        cur_usec_rec.to_be_announced = 'Y' AND
        (p_transaction_type = 'UPDATE' OR p_transaction_type = 'REQUEST') THEN
        FND_MESSAGE.Set_Name('IGS','IGS_PS_ATLEAST_ONE_DAY_CHECK');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     -- Raising an exception if any any of the above validations fail

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Records have to be inserted into the Schedule Interface Tables.

     DECLARE
          l_trans_id                igs_ps_sch_hdr_int.transaction_id%TYPE;
	  l_int_pat_id              NUMBER;
          l_int_usec_id             igs_ps_sch_usec_int_all.int_usec_id%TYPE ;
     BEGIN
          -- create a header record for the process.
          BEGIN
             INSERT INTO igs_ps_sch_hdr_int (
                transaction_id                     ,
                originator                         ,
                request_date                       ,
                org_id
                )
		VALUES (
		IGS_PS_SCH_HDR_INT_S.NEXTVAL,
		'EXTERNAL',
		SYSDATE,
		p_org_id ) RETURNING transaction_id INTO l_trans_id;
          END;

          DECLARE
	    CURSOR cur_cal(cp_cal_type IN VARCHAR2,
			   cp_sequence_number IN NUMBER) IS
	    SELECT *
	    FROM igs_ca_inst_all
	    WHERE cal_type=cp_cal_type
	    AND   sequence_number=cp_sequence_number;
	    l_cur_cal cur_cal%ROWTYPE;

	    CURSOR cur_pat(cp_uoo_id IN NUMBER) IS
	    SELECT unit_cd,version_number
	    FROM igs_ps_unit_ofr_opt_all
	    WHERE uoo_id=cp_uoo_id;
	    l_cur_pat cur_pat%ROWTYPE;

	  BEGIN

	    OPEN cur_cal(p_cal_type,p_sequence_number);
	    FETCH cur_cal INTO l_cur_cal;
	    CLOSE cur_cal;

	    OPEN cur_pat(cur_usec_rec.uoo_id);
	    FETCH cur_pat INTO l_cur_pat;
	    CLOSE cur_pat;

	    --Insert into pattern interface table
	    INSERT INTO IGS_PS_SCH_PAT_INT
	    (int_pat_id ,
	    transaction_id                 ,
	    calendar_type                  ,
	    sequence_number                ,
	    teaching_cal_alternate_code    ,
	    start_date                     ,
	    end_date                       ,
	    unit_cd                        ,
	    version_number                 ,
	    enrollment_expected            ,
	    enrollment_maximum             ,
	    override_enrollment_maximum    ,
	    unit_status                    ,
	    abort_flag                     ,
	    import_done_flag               ,
	    created_by                     ,
	    creation_date                  ,
	    last_updated_by                ,
	    last_update_date               ,
	    last_update_login)
	    VALUES(
	    IGS_PS_SCH_PAT_INT_S.NEXTVAL,
	    l_trans_id,
	    p_cal_type,
	    p_sequence_number,
	    l_cur_cal.alternate_code,
	    l_cur_cal.start_dt,
	    l_cur_cal.end_dt,
	    l_cur_pat.unit_cd,
	    l_cur_pat.version_number,
	    NULL,
	    NULL,
	    NULL,
	    NULL,
	    'N',
	    'N',
	    g_n_user_id,
	    SYSDATE,
	    g_n_user_id,
	    SYSDATE,
	    g_n_login_id
	    ) RETURNING int_pat_id INTO l_int_pat_id;
          END ;



          -- Insert Unit Section Interface Records  (IGS_PS_SCH_USEC_INT_ALL)
          BEGIN
             INSERT INTO igs_ps_sch_usec_int_all (
                int_usec_id           ,
                calendar_type          ,
                sequence_number         ,
                unit_cd                  ,
                version_number            ,
                unit_title                 ,
                owner_org_unit_cd           ,
                unit_class                   ,
                unit_section_start_date       ,
                unit_section_end_date          ,
                unit_section_status             ,
                enrollment_maximum               ,
                enrollment_actual                 ,
                enrollment_expected                ,
                override_enrollment_max            ,
                location_cd                        ,
                cal_start_dt                       ,
                cal_end_dt                         ,
                uoo_id                             ,
                transaction_id                     ,
                org_id                             ,
		ABORT_FLAG                         ,
		IMPORT_DONE_FLAG                   ,
		CALL_NUMBER                        ,
		SUBTITLE                           ,
		ORG_UNIT_DESCRIPTION               ,
		TEACHING_CAL_ALTERNATE_CODE        ,
		INT_PAT_ID                         ,
		created_by                         ,
		creation_date                      ,
		last_updated_by                    ,
		last_update_date                   ,
		last_update_login
               )
	       VALUES (
		IGS_PS_SCH_USEC_INT_S.NEXTVAL,
		p_cal_type,
		p_sequence_number,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NVL(p_cal_start_dt,rec_cal.start_dt),
		NVL(p_cal_end_dt,rec_cal.end_dt),
		p_uoo_id,
		l_trans_id,
		p_org_id,
		'N',
		'N',
		NULL,
		NULL,
		NULL,
		NULL,
		l_int_pat_id,
		g_n_user_id,
		SYSDATE,
		g_n_user_id,
		SYSDATE,
		g_n_login_id
		) RETURNING int_usec_id INTO l_int_usec_id;
          END;


          BEGIN
             -- Insert records in the Igs_ps_sch_int_all table

             -- Enh bug#2833850
             -- Passing the values stored in the input parameters to the columns monday,tuesday,wednesday,thursday,friday,saturday
             -- uso_start_date,uso_end_date in the call to igs_ps_sch_int_pkg.insert_row.
             -- Added the column preferred_region_code in the call to igs_ps_sch_int_pkg.insert_row
             INSERT INTO igs_ps_sch_int_all (
                CALENDAR_TYPE               ,
                SEQUENCE_NUMBER             ,
                TRANSACTION_TYPE            ,
                UNIT_SECTION_OCCURRENCE_ID  ,
                UNIT_CD                     ,
                VERSION_NUMBER              ,
                UNIT_TITLE                  ,
                OWNER_ORG_UNIT_CD           ,
                UNIT_CLASS                  ,
                MONDAY                      ,
                TUESDAY                     ,
                WEDNESDAY                   ,
                THURSDAY                    ,
                FRIDAY                      ,
                SATURDAY                    ,
                SUNDAY                      ,
                UNIT_SECTION_START_DATE     ,
                UNIT_SECTION_END_DATE       ,
                START_TIME                  ,
                END_TIME                    ,
                ENROLLMENT_MAXIMUM          ,
                ENROLLMENT_ACTUAL           ,
                INSTRUCTOR_ID               ,
                SURNAME                     ,
                BUILDING_ID                 ,
                ROOM_ID                     ,
                LOCATION_CD                 ,
                UNIT_SEC_CROSS_UNIT_SEC_ID  ,
                UOO_ID                      ,
                SCHEDULE_STATUS             ,
                ERROR_TEXT                  ,
                TRANSACTION_ID              ,
                INT_OCCURS_ID               ,
                INT_USEC_ID                 ,
                GIVEN_NAMES                 ,
                MIDDLE_NAME                 ,
                ORG_ID                      ,
                DEDICATED_BUILDING_ID       ,
                DEDICATED_ROOM_ID           ,
                PREFERRED_BUILDING_ID       ,
                PREFERRED_ROOM_ID           ,
                PREFERRED_REGION_CODE       ,
                TBA_STATUS                  ,
                USO_START_DATE              ,
                USO_END_DATE                ,
		abort_flag                  ,
		import_done_flag            ,
                occurrence_identifier       ,
		created_by                  ,
		creation_date               ,
		last_updated_by             ,
		last_update_date            ,
		last_update_login
                )
		VALUES (
		NULL,
		NULL,
		p_transaction_type,
		p_unit_section_occurrence_id,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		p_monday,
		p_tuesday,
		p_wednesday,
		p_thursday,
		p_friday,
		p_saturday,
		p_sunday,
		NULL,
		NULL,
		p_start_time,
		p_end_time,
		NULL,
		NULL,
		NULL,
		NULL,
		p_building_id,
		p_room_id,
		NULL,
		NULL,
		NULL,
		p_schedule_status,
		p_error_text,
		NULL,
		IGS_PS_SCH_INT_S.NEXTVAL,
		l_int_usec_id,
		NULL,
		NULL,
		p_org_id,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		p_uso_start_date,
		p_uso_end_date,
		'N',
		'N',
		cur_usec_rec.occurrence_identifier,
  		g_n_user_id,
		SYSDATE,
		g_n_user_id,
		SYSDATE,
		g_n_login_id
	       ) ;
           END;

     END;

  END LOOP;

  -- If the p_commit parameter is set to True and no errors have been raised by the
  -- then commit

  IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get(p_count      => x_msg_count,
                            p_data       => x_msg_data);


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Insert_schedule_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Insert_schedule_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO Insert_schedule_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,
                                l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

  END insert_schedule;


  PROCEDURE update_schedule(   p_api_version            IN               NUMBER,
                               p_init_msg_list          IN               VARCHAR2 := FND_API.G_FALSE,
                               p_commit                 IN               VARCHAR2 := FND_API.G_FALSE ,
                               p_validation_level       IN               NUMBER := FND_API.G_VALID_LEVEL_FULL ,
                               x_return_status          OUT NOCOPY       VARCHAR2,
                               x_msg_count              OUT NOCOPY       NUMBER,
                               x_msg_data               OUT NOCOPY       VARCHAR2,
                               p_int_occurs_id          IN               NUMBER,
                               p_start_time             IN               DATE ,
                               p_end_time               IN               DATE ,
                               p_building_id            IN               NUMBER ,
                               p_room_id                IN               NUMBER ,
                               p_schedule_status        IN               VARCHAR2,
                               p_error_text             IN               VARCHAR2,
                               p_org_id                 IN               NUMBER,
                               p_uso_start_date         IN               DATE,
                               p_uso_end_date           IN               DATE,
                               p_sunday                 IN               VARCHAR2,
                               p_monday                 IN               VARCHAR2,
                               p_tuesday                IN               VARCHAR2,
                               p_wednesday              IN               VARCHAR2,
                               p_thursday               IN               VARCHAR2,
                               p_friday                 IN               VARCHAR2,
                               p_saturday               IN               VARCHAR2
                               ) AS

  /***********************************************************************************************
  Created By:         schodava
  Date Created By:    12-06-2001
  Purpose:            This procedure is used to update records in the Scheduling interface tables.
  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  jbegum     18-APR-2003   Enh bug#2833850
                           Added following parameters
                           p_uso_start_date,p_uso_end_date,p_sunday,p_monday,p_tuesday,p_wednesday,p_thursday,p_friday,p_saturday
  smvk       10-Feb-2003   Bug # 2803385. Modified the variable buiding_code and room_code as building_id and
                           room_id respectively.
  *************************************************************************************************/

    l_api_name       CONSTANT VARCHAR2(30) := 'Update_sch';
    l_api_version    CONSTANT NUMBER       := 1.0;

  BEGIN

    -- Savepoint
    SAVEPOINT Update_Schedule_pub;

    -- Check if the API call is compatible
    IF NOT FND_API.Compatible_API_Call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN

        -- If the call is incompatible, then raise the unexpected error
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    -- If the p_init_msg_list is T, i.e. the calling program wants to initialise
    -- the message list, then the message list is initialised using the API call
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Set the return status as success for the api
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Schedule Interface Tables have to be updated with the Scheduled fields.
    -- Cursor for selecting the Unit Section Occurrence data from the Schedule Interface Table

    DECLARE

      l_int_occurs_id  NUMBER ;
      l_building_id    igs_ps_sch_int_all.building_id%TYPE;
      l_room_id        igs_ps_sch_int_all.room_id%TYPE;
      l_start_time     igs_ps_sch_int_all.start_time%TYPE;
      l_end_time       igs_ps_sch_int_all.end_time%TYPE;
      l_uso_start_date igs_ps_sch_int_all.uso_start_date%TYPE;
      l_uso_end_date   igs_ps_sch_int_all.uso_end_date%TYPE;
      l_sunday         igs_ps_sch_int_all.sunday%TYPE;
      l_monday         igs_ps_sch_int_all.monday%TYPE;
      l_tuesday        igs_ps_sch_int_all.tuesday%TYPE;
      l_wednesday      igs_ps_sch_int_all.wednesday%TYPE;
      l_thursday       igs_ps_sch_int_all.thursday%TYPE;
      l_friday         igs_ps_sch_int_all.friday%TYPE;
      l_saturday       igs_ps_sch_int_all.saturday%TYPE;

      CURSOR cur_usec(cp_int_occurs_id IN NUMBER) IS
      SELECT psi.rowid,
             psi.*,
             ps.unit_section_start_date us_start_date,
             ps.unit_section_end_date us_end_date
      FROM   IGS_PS_SCH_INT_ALL psi,
             IGS_PS_SCH_USEC_INT ps
      WHERE  psi.int_occurs_id = cp_int_occurs_id AND
             psi.int_usec_id = ps.int_usec_id;

      -- Cursor added as part of Enh bug#2833850
      CURSOR c_bld(cp_n_building_id igs_ad_building_all.building_id%TYPE) IS
      SELECT 'x'
      FROM   igs_ad_building_all
      WHERE  building_id = cp_n_building_id;

      -- Cursor added as part of Enh bug#2833850
      CURSOR c_room(cp_n_room_id igs_ad_room_all.room_id%TYPE) IS
      SELECT 'x'
      FROM   igs_ad_room_all
      WHERE  room_id = cp_n_room_id;

      -- Cursor added as part of Enh bug#2833850
      CURSOR c_bld_room(cp_n_room_id igs_ad_room_all.room_id%TYPE,
                        cp_n_building_id igs_ad_building_all.building_id%TYPE) IS
      SELECT 'x'
      FROM   igs_ad_room_all
      WHERE  room_id = cp_n_room_id AND
             building_id = cp_n_building_id;

      -- Local variables added as part of Enh bug#2833850
      rec_bld  c_bld%ROWTYPE;
      rec_room c_room%ROWTYPE;
      rec_bld_room c_bld_room%ROWTYPE;

    BEGIN

      FOR cur_usec_rec IN cur_usec(p_int_occurs_id) LOOP

        -- Enh bug#2833850
        -- Following validations have been added to validate the parameter values passed to update scheduling api by third party software.
        -- These validations will ensure that the interface records updated by the third party software thru update scheduling api will
        -- get sucessfully imported to the production table of OSS

        -- Validation 1
        -- Error text is mandatory for unit section occurrence scheduled as Error.

        IF p_schedule_status = 'ERROR' AND p_error_text IS NULL THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_SCH_ERR_TEXT_NULL');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 2
        -- Building  identifier are mandatory for successfully scheduled unit section occurrence

        IF p_schedule_status = 'OK' AND
           (p_building_id IS NULL) AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_SCH_BD_OR_RM_NULL');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 3
        -- Building and room identifier should be null for successfully cancelled unit section occurrence

        IF p_schedule_status = 'OK' AND
           (p_building_id IS NOT NULL OR p_room_id IS NOT NULL) AND
           cur_usec_rec.transaction_type = 'CANCEL' THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_SCH_BD_OR_RM_NOT_NULL');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 4
        -- Unit Section Occurrence start date must be lesser than or equal to Unit Section Occurrence end date

        IF p_schedule_status = 'OK' AND
           p_uso_start_date IS NOT NULL AND
           p_uso_end_date IS NOT NULL AND
           p_uso_start_date > p_uso_end_date AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') AND
           cur_usec_rec.tba_status = 'Y' AND
           cur_usec_rec.uso_start_date IS NULL AND cur_usec_rec.uso_end_date IS NULL THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PE_EDT_LT_SDT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 5
        -- Unit Section Occurrence Start Date should be greater than or equal to Unit Section Start Date

        IF p_schedule_status = 'OK' AND
           p_uso_start_date IS NOT NULL AND
           p_uso_start_date < cur_usec_rec.us_start_date AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') AND
           cur_usec_rec.tba_status = 'Y' AND
           cur_usec_rec.uso_start_date IS NULL THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_STDT_GE_US_STDT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 6
        -- Unit Section Occurrence Start Date must be less than or equal to Unit Section End Date

        IF p_schedule_status = 'OK' AND
           p_uso_start_date IS NOT NULL AND
           p_uso_start_date > cur_usec_rec.us_end_date AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') AND
           cur_usec_rec.tba_status = 'Y' AND
           cur_usec_rec.uso_start_date IS NULL THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_ST_DT_UOO_END_DT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 7
        -- Unit Section Occurrence End Date must be greater than or equal to Unit Section Start Date

        IF p_schedule_status = 'OK' AND
           p_uso_end_date IS NOT NULL AND
           p_uso_end_date < cur_usec_rec.us_start_date AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') AND
           cur_usec_rec.tba_status = 'Y' AND
           cur_usec_rec.uso_end_date IS NULL THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_END_DT_UOO_ST_DT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 8
        -- Unit Section Occurrence End Date must be lesser than or equal to Unit Section End Date

        IF p_schedule_status = 'OK' AND
           p_uso_end_date IS NOT NULL AND
           p_uso_end_date > cur_usec_rec.us_end_date AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') AND
           cur_usec_rec.tba_status = 'Y' AND
           cur_usec_rec.uso_end_date IS NULL THEN
           FND_MESSAGE.Set_Name('IGS','IGS_PS_USO_ENDT_LE_US_ENDT');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Validation 9
        -- Invalid Scheduled Building Identifier

        IF p_schedule_status = 'OK' AND
           p_building_id IS NOT NULL AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') THEN

           OPEN c_bld(p_building_id);
           FETCH c_bld INTO rec_bld;
           IF c_bld%NOTFOUND THEN
              FND_MESSAGE.Set_Name('IGS','IGS_PS_BUILDING_ID_INVALID');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE c_bld;

        END IF;

        -- Validation 10
        -- Invalid Scheduled Room Identifier

        IF p_schedule_status = 'OK' AND
           p_room_id IS NOT NULL AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') THEN

           OPEN c_room(p_room_id);
           FETCH c_room INTO rec_room;
           IF c_room%NOTFOUND THEN
              FND_MESSAGE.Set_Name('IGS','IGS_PS_ROOM_ID_INVALID');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE c_room;

        END IF;

        -- Validation 11
        -- Scheduled room does not belong to scheduled building

        IF p_schedule_status = 'OK' AND
           p_building_id IS NOT NULL AND
           p_room_id IS NOT NULL AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') THEN

           OPEN c_bld_room(p_room_id,p_building_id);
           FETCH c_bld_room INTO rec_bld_room;
           IF c_bld_room%NOTFOUND THEN
              FND_MESSAGE.Set_Name('IGS','IGS_PS_ROOM_INV_FOR_BLD');
              FND_MSG_PUB.Add;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE c_bld_room;

        END IF;

        -- Validation 12
        -- At least one day of the week should be checked

        IF p_schedule_status = 'OK' AND
           NVL(p_sunday,'N') = 'N'  AND
           NVL(p_monday,'N') = 'N'  AND
           NVL(p_tuesday,'N') = 'N' AND
           NVL(p_wednesday,'N') = 'N' AND
           NVL(p_thursday,'N') = 'N' AND
           NVL(p_friday,'N') = 'N' AND
           NVL(p_saturday,'N') = 'N' AND
           cur_usec_rec.tba_status = 'Y' AND
           (cur_usec_rec.transaction_type = 'UPDATE' OR cur_usec_rec.transaction_type = 'REQUEST') THEN

           FND_MESSAGE.Set_Name('IGS','IGS_PS_ATLEAST_ONE_DAY_CHECK');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        -- Raising an exception if any any of the above validations fail

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_int_occurs_id  := cur_usec_rec.int_occurs_id;

        IF p_building_id IS NULL THEN
           l_building_id := cur_usec_rec.building_id;
        ELSE
           l_building_id := p_building_id;
        END IF;

        IF p_room_id IS NULL THEN
           l_room_id := cur_usec_rec.room_id;
        ELSE
           l_room_id := p_room_id;
        END IF;

        IF p_start_time IS NULL THEN
           l_start_time := cur_usec_rec.start_time;
        ELSE
           l_start_time := p_start_time;
        END IF;

        IF p_end_time IS NULL THEN
           l_end_time := cur_usec_rec.end_time;
        ELSE
           l_end_time := p_end_time;
        END IF;

        -- Enh bug#2833850
        -- Added following Null check for the newly added parameters.

        IF p_uso_start_date IS NOT NULL AND cur_usec_rec.uso_start_date IS NULL THEN
           l_uso_start_date := p_uso_start_date;
        ELSE
           l_uso_start_date := cur_usec_rec.uso_start_date;
        END IF;

        IF p_uso_end_date IS NOT NULL AND cur_usec_rec.uso_end_date IS NULL THEN
           l_uso_end_date := p_uso_end_date;
        ELSE
           l_uso_end_date := cur_usec_rec.uso_end_date;
        END IF;

        IF p_sunday IS NULL THEN
           l_sunday := cur_usec_rec.sunday;
        ELSE
           l_sunday := p_sunday;
        END IF;

        IF p_monday IS NULL THEN
           l_monday := cur_usec_rec.monday;
        ELSE
           l_monday := p_monday;
        END IF;

        IF p_tuesday IS NULL THEN
           l_tuesday := cur_usec_rec.tuesday;
        ELSE
           l_tuesday := p_tuesday;
        END IF;

        IF p_wednesday IS NULL THEN
           l_wednesday := cur_usec_rec.wednesday;
        ELSE
           l_wednesday := p_wednesday;
        END IF;

        IF p_thursday IS NULL THEN
           l_thursday := cur_usec_rec.thursday;
        ELSE
           l_thursday := p_thursday;
        END IF;

        IF p_friday IS NULL THEN
           l_friday := cur_usec_rec.friday;
        ELSE
           l_friday := p_friday;
        END IF;

        IF p_saturday IS NULL THEN
           l_saturday := cur_usec_rec.saturday;
        ELSE
           l_saturday := p_saturday;
        END IF;

        -- Enh bug#2833850
        -- Passing the values stored in the local variables to the columns monday,tuesday,wednesday,thursday,friday,saturday
        -- uso_start_date,uso_end_date in the call to igs_ps_sch_int_pkg.update_row.
        -- Added the column preferred_region_code in the call to igs_ps_sch_int_pkg.update_row

        UPDATE igs_ps_sch_int_all SET
          TRANSACTION_TYPE            = cur_usec_rec.transaction_type,
          UNIT_SECTION_OCCURRENCE_ID  = cur_usec_rec.unit_section_occurrence_id,
          MONDAY                      = l_monday,
          TUESDAY                     = l_tuesday,
          WEDNESDAY                   = l_wednesday,
          THURSDAY                    = l_thursday,
          FRIDAY                      = l_friday,
          SATURDAY                    = l_saturday,
          SUNDAY                      = l_sunday,
          START_TIME                  = l_start_time,
          END_TIME                    = l_end_time,
          INSTRUCTOR_ID               = cur_usec_rec.instructor_id,
          SURNAME                     = cur_usec_rec.surname,
          BUILDING_ID                 = l_building_id,
          ROOM_ID                     = l_room_id,
          SCHEDULE_STATUS             = p_schedule_status,
          ERROR_TEXT                  = p_error_text,
          INT_OCCURS_ID               = l_int_occurs_id,
          INT_USEC_ID                 = cur_usec_rec.int_usec_id,
          GIVEN_NAMES                 = cur_usec_rec.given_names,
          MIDDLE_NAME                 = cur_usec_rec.middle_name,
          DEDICATED_BUILDING_id       = cur_usec_rec.dedicated_building_id,
          DEDICATED_ROOM_id           = cur_usec_rec.dedicated_room_id,
          PREFERRED_BUILDING_id       = cur_usec_rec.preferred_building_id,
          PREFERRED_ROOM_id           = cur_usec_rec.preferred_room_id,
          TBA_STATUS                  = cur_usec_rec.tba_status,
          USO_START_DATE              = l_uso_start_date,
          USO_END_DATE                = l_uso_end_date,
          PREFERRED_REGION_CODE       = cur_usec_rec.preferred_region_code,
	  last_updated_by             = g_n_user_id,
	  last_update_date            = SYSDATE,
	  last_update_login           = g_n_login_id
          WHERE INT_OCCURS_ID= l_int_occurs_id;

      END LOOP;

    END;

    -- If the p_commit parameter is set to True and no errors have been raised
    -- then commit
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get(p_count      => x_msg_count,
                              p_data       => x_msg_data);


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Update_Schedule_pub;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Update_Schedule_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO Update_Schedule_pub;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         FND_MSG_PUB.Add_Exc_Msg(g_pkg_name,
                                 l_api_name);

      END IF;
      FND_MSG_PUB.Count_And_Get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

  END update_schedule;

END  IGS_PS_SCH_INT_API_PUB;

/
