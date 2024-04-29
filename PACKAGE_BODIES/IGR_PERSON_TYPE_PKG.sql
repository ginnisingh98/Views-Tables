--------------------------------------------------------
--  DDL for Package Body IGR_PERSON_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_PERSON_TYPE_PKG" AS
/* $Header: IGSRT06B.pls 120.0 2005/06/01 15:24:58 appldev noship $ */

PROCEDURE update_persontype_funnel(
             p_person_id           IN   NUMBER,
             p_person_type_code    IN   VARCHAR2,
	     p_funnel_status       IN   VARCHAR2,
	     p_return_status       OUT NOCOPY VARCHAR2,
	     p_message_text        OUT NOCOPY VARCHAR2) AS

  cst_prospect CONSTANT varchar2(50)     := 'PROSPECT';
  cst_applicant CONSTANT  varchar2(50)   := 'APPLICANT';
  cst_evaluator CONSTANT  varchar2(50)   := 'EVALUATOR';
  cst_funnel_status CONSTANT varchar2(25):= '100-IDENTIFIED';

  lv_type_instance_id NUMBER(15);
  l_person_type_code igs_pe_person_types.person_type_code%TYPE;
  l_funnel_status    igs_pe_typ_instances_all.funnel_status%TYPE;

  lv_sysdate DATE;
  l_org_id NUMBER(15);
  lv_rowid2 VARCHAR2(30);

  CURSOR c_person_type_code(l_system_type IGS_PE_PERSON_TYPES.system_type%TYPE) IS
  SELECT person_type_code
  FROM   igs_pe_person_types
  WHERE  system_type=l_system_type;

BEGIN
     l_org_id := igs_ge_gen_003.get_org_id;
     lv_sysdate := SYSDATE;

     IF p_person_type_code IS NULL THEN
         OPEN  c_person_type_code('PROSPECT');
         FETCH c_person_type_code INTO l_person_type_code;
         CLOSE c_person_type_code;
     ELSE
         l_person_type_code := p_person_type_code;
     END IF;
     IF p_funnel_status IS NULL THEN
        l_funnel_status := cst_funnel_status ;
     ELSE
        l_funnel_status := p_funnel_status ;
     END IF;

  -- If the person is an evaluator, you should not create the Inquiry

  IF checkactiveXPersontype(p_person_id, cst_evaluator) THEN
     p_return_status := 'E';
     FND_MESSAGE.SET_NAME('IGS','IGS_AD_EVAL_NOT_CRT_INQ');
     p_message_text := FND_MESSAGE.GET;
     RETURN;
  END IF;


  IF NOT checkactiveXPersontype(p_person_id, cst_applicant) THEN  -- Inactive Applicant exists
    IF NOT checkactiveXPersontype(p_person_id, cst_prospect) THEN  -- Inactive Prospect exists
      -- Call igs_pe_type_instance.insert_row
      -- pass the person type as system defined value of 'PROSPECT'
      -- and funnel status as '100-IDENTIFIED'

      -- Other person type will be automatically deleted inside the
      -- igs_pe_typ_instances_pkg if we are creating other than 'OTHER'
      -- person type which is active
      igs_pe_typ_instances_pkg.insert_row
      (
       X_MODE                               => 'R',
       X_RowId                              => lv_rowid2,
       X_TYPE_INSTANCE_ID                   => lv_type_instance_id,
       X_PERSON_TYPE_CODE                   => l_person_type_code,
       X_PERSON_ID                          => p_person_id,
       X_COURSE_CD                          => NULL,
       X_FUNNEL_STATUS                      => l_funnel_status,
       X_ADMISSION_APPL_NUMBER              => NULL,
       X_NOMINATED_COURSE_CD                => NULL,
       X_SEQUENCE_NUMBER                    => NULL,
       X_START_DATE                         => lv_sysdate,
       X_END_DATE                           => NULL,
       X_CREATE_METHOD                      => NULL,
       X_ENDED_BY                           => NULL,
       X_END_METHOD                         => NULL,
       X_CC_VERSION_NUMBER                  => NULL,
       X_NCC_VERSION_NUMBER                 => NULL,
       X_Org_Id                             => l_org_id,
       X_EMPLMNT_CATEGORY_CODE              => NULL
      );
    END IF;
  END IF;
  RETURN;
END ;

FUNCTION checkactiveXPersontype(p_person_id IN NUMBER, p_person_type IN VARCHAR2)
RETURN BOOLEAN AS
  l_exists VARCHAR2(1);
  CURSOR c_persontype_exist (cp_person_id igs_pe_typ_instances.person_id%TYPE)
  IS
    SELECT 'X'
    FROM
      igs_pe_typ_instances_all pti, igs_pe_person_types pt
    WHERE
      pti.person_id = cp_person_id
      AND pti.person_type_code = pt.person_type_code
      AND pt.system_type = p_person_type
      AND (end_date IS NULL OR (TRUNC(end_date) IS NOT NULL AND TRUNC(end_date) > SYSDATE));
BEGIN
  OPEN c_persontype_exist (p_person_id );
  FETCH c_persontype_exist INTO l_exists;
  IF c_persontype_exist%FOUND THEN
    CLOSE c_persontype_exist;
    RETURN TRUE;
  ELSE
    CLOSE c_persontype_exist;
    RETURN FALSE;
  END IF;
END;
END igr_person_type_pkg;

/
