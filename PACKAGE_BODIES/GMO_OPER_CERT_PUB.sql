--------------------------------------------------------
--  DDL for Package Body GMO_OPER_CERT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_OPER_CERT_PUB" AS
/*  $Header: GMOOPCTB.pls 120.1.12010000.2 2009/08/26 17:30:43 srpuri ship $    */
   g_debug               VARCHAR2 (5)  := NVL(fnd_profile.VALUE ('AFLOG_LEVEL'),-1);
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'GMO_OPER_CERT';



FUNCTION check_certification(
      p_user_id        IN                NUMBER
     ,p_org_id           IN              NUMBER
     ,p_object_id        IN              NUMBER DEFAULT NULL
     ,p_object_type      IN              NUMBER DEFAULT NULL
     ,p_eff_date         IN              DATE
     ,x_return_status    OUT NOCOPY      VARCHAR2) RETURN NUMBER

     IS

     TYPE l_cert_comp_tbl_typ IS TABLE OF gmo_opert_cert_detail%ROWTYPE
        INDEX BY BINARY_INTEGER;

      l_api_name   CONSTANT 	VARCHAR2 (30) := 'check_certification';
      l_return_status       	VARCHAR2 (1);
      l_employ_id           	NUMBER ;
      l_user_id			NUMBER ;
      l_opert_cert_hdr          gmo_opert_cert_header%ROWTYPE;
      l_cert_comp_tbl           l_cert_comp_tbl_typ;
      l_org_id                  NUMBER ;
      l_object_id               NUMBER ;
      l_object_type             NUMBER ;
      l_competence_lines	NUMBER ;
      l_business_group_id       NUMBER ;
      l_cert_count              NUMBER ;
      l_comp_count              NUMBER ;
      l_eff_date                DATE;
      l_oc_profile_value        VARCHAR2(10);
      CURSOR cur_get_employee (v_user_id IN NUMBER) IS
         SELECT employee_id
         FROM fnd_user
         WHERE user_id  = v_user_id ;
      CURSOR cur_get_oper_cert (v_org_id 	IN NUMBER,
                                v_object_id 	IN NUMBER,
                                v_object_type 	IN NUMBER ) IS
         SELECT *
         FROM gmo_opert_cert_header
         WHERE organization_id  = v_org_id
         AND   object_id        = v_object_id
         AND  object_type       = v_object_type;

        CURSOR cur_get_compet_dtl (v_header_id 	IN NUMBER
                                ) IS
         SELECT *
         FROM gmo_opert_cert_detail
         WHERE header_id  = v_header_id ;

      CURSOR cur_get_org (v_org_id number) IS

          SELECT HOU.BUSINESS_GROUP_ID
            -- DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION1), TO_NUMBER(NULL)) SET_OF_BOOKS_ID,
            -- DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION3), TO_NUMBER(NULL)) OPERATING_UNIT,
            -- DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION2), null) LEGAL_ENTITY
      FROM  HR_ORGANIZATION_UNITS HOU, HR_ORGANIZATION_INFORMATION HOI2
      WHERE HOU.organization_id = V_org_id
      AND   HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
      AND   ( HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information';


      invalid_user             	EXCEPTION;
      NO_CERTIFICATE_REQ	EXCEPTION;
      NO_COMPETENCE_DEFINED	EXCEPTION;
      NO_COMPETENCE             EXCEPTION;
      NO_CERTIFICATE            EXCEPTION;
      INVALID_BUSINESS_GROUP_ID	EXCEPTION;
     BEGIN


     IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
     x_return_status := fnd_api.g_ret_sts_success;
      l_user_id        := p_user_id   ;
      l_org_id         := p_org_id    ;
      l_object_id      := p_object_id ;
      l_object_type    := p_object_type;
      l_eff_date       := nvl(p_eff_date, sysdate) ;
      l_oc_profile_value := fnd_profile.value('GMO_OPERATOR_CERTIFICATE');
      if nvl(l_oc_profile_value,'N') = 'N' then
      -- this object don't require any certification
         RETURN 1;
      end if;
      OPEN cur_get_employee (l_user_id);
      FETCH cur_get_employee
      INTO l_employ_id;
      CLOSE cur_get_employee ;
       --dbms_output.put_line('empl '||l_employ_id);
    -- get the buiness_group_id for the org_id.
      OPEN cur_get_org (l_org_id);
      FETCH cur_get_org
      INTO l_business_group_id;
      IF (cur_get_org%NOTFOUND) THEN
         CLOSE cur_get_org;
         RAISE invalid_business_group_id;
      END IF;
      CLOSE cur_get_org;
      --dbms_output.put_line('hr unit '||l_business_group_id);
     -- check for whether certification is required for this object
       OPEN cur_get_oper_cert (l_org_id, l_object_id, l_object_type);
       FETCH cur_get_oper_cert INTO l_opert_cert_hdr ;
       IF (cur_get_oper_cert%NOTFOUND) THEN
         CLOSE cur_get_oper_cert;
          --dbms_output.put_line('no req');
        RETURN  1;

       END IF;
       CLOSE cur_get_oper_cert;
        --dbms_output.put_line('cert req  '||l_opert_cert_hdr.header_id);
       -- check for override allowed or not




      -- now based on the HRMS make a call to the api and chek for competency.
       --dbms_output.put_line('for cert');
       SELECT COUNT(*) into l_cert_count
       FROM  gmo_opert_cert_detail
       WHERE header_id  = l_opert_cert_hdr.header_id
       AND qualification_type = 1  -- 1 is certification
       AND FROM_DATE <= l_eff_date
       AND nvl(TO_DATE, sysdate) >= l_eff_date
       AND qualification_id NOT IN (SELECT certification_id
                                     FROM OTA_CERT_ENROLLMENTS oce
                                     WHERE oce.certification_status_code ='CERTIFIED'
                                     AND   oce.completion_date <= SYSDATE
                                     AND oce.business_group_id = l_business_group_id
                                     AND oce.person_id = l_employ_id );
       IF l_cert_count > 0 THEN
       	 --dbms_output.put_line('no cert found');
          RAISE no_certificate;
       END IF;

        SELECT COUNT(*) into l_comp_count
       FROM  gmo_opert_cert_detail ocd
       WHERE ocd.header_id  = l_opert_cert_hdr.header_id
       AND ocd.qualification_type = 2  -- 2 is competence
       AND FROM_DATE <= l_eff_date
       AND nvl(TO_DATE, sysdate) >= l_eff_date
       AND ocd.qualification_id NOT IN (SELECT competence_id
                                     FROM per_competence_elements pce
       	                             WHERE nvl(pce.effective_date_to, sysdate) >= SYSDATE
			             AND   pce.effective_date_from <= SYSDATE
			             AND pce.PROFICIENCY_LEVEL_ID >= ocd.PROFICIENCY_LEVEL_ID
                                     AND pce.business_group_id = l_business_group_id
                                     AND pce.person_id = l_employ_id );


      IF l_comp_count > 0 THEN

          RAISE no_competence;
      END IF;

     RETURN 1;

     EXCEPTION
      WHEN invalid_user THEN

      	-- message that user is not defined in hrms
         fnd_message.set_name ('INV', 'INV_INT_USRCODE');
         fnd_msg_pub.ADD;
          x_return_status := fnd_api.g_ret_sts_error ;
         RETURN 0;

      WHEN NO_CERTIFICATE_REQ THEN

      	-- this object don't require any certification
         RETURN 1;
      /*WHEN NO_COMPETENCE_DEFINED THEN
      	-- this object has no competence for certification
         RETURN 0;
         x_return_status := fnd_api.g_ret_sts_error ;*/
      WHEN NO_COMPETENCE or no_certificate THEN
         IF l_opert_cert_hdr.override = 1 THEN
             RETURN 0;
         ELSE
            x_return_status := 'O' ;
            RETURN -1;
         END IF;

      WHEN OTHERS THEN
         FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      	 x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         RETURN 0;
     END check_certification;

 PROCEDURE required_certification(
      p_user_id          	IN              NUMBER
     ,p_org_id           	IN              NUMBER
     ,p_header_id        	IN              NUMBER
     ,p_operator_certificate_id IN      	NUMBER
     ,p_eff_date         	IN              DATE
     ,x_return_status    	OUT NOCOPY      VARCHAR2)

IS

     TYPE l_cert_comp_tbl_typ IS TABLE OF gmo_opert_cert_detail%ROWTYPE
        INDEX BY BINARY_INTEGER;

      l_api_name   CONSTANT 	VARCHAR2 (30) := 'required_certification';
      l_return_status       	VARCHAR2 (1);
      l_employ_id           	NUMBER ;
      l_user_id			NUMBER ;
      l_opert_cert_hdr          gmo_opert_cert_header%ROWTYPE;
      l_cert_comp_tbl           l_cert_comp_tbl_typ;
      l_org_id                  NUMBER ;
      l_object_id               NUMBER ;
      l_object_type             NUMBER ;
      l_competence_lines	NUMBER ;
      l_business_group_id       NUMBER ;
      l_header_id               NUMBER ;
      l_operator_certificate_id NUMBER ;
      l_trans_detail_id         NUMBER;
      i                         NUMBER;
      l_eff_date                DATE;

      CURSOR cur_get_employee (v_user_id IN NUMBER) IS
         SELECT employee_id
         FROM fnd_user
         WHERE user_id  = v_user_id ;

      CURSOR cur_get_org (v_org_id number) IS

          SELECT HOU.BUSINESS_GROUP_ID
            -- DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION1), TO_NUMBER(NULL)) SET_OF_BOOKS_ID,
            -- DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION3), TO_NUMBER(NULL)) OPERATING_UNIT,
            -- DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION2), null) LEGAL_ENTITY
      FROM  HR_ORGANIZATION_UNITS HOU, HR_ORGANIZATION_INFORMATION HOI2
      WHERE HOU.organization_id = V_org_id
      AND   HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
      AND   ( HOI2.ORG_INFORMATION_CONTEXT || '') ='Accounting Information';

CURSOR get_req_competence (v_header_id NUMBER,v_employ_id NUMBER, v_business_id NUMBER, v_date DATE) IS

       SELECT ocd.Qualification_id , ocd.Qualification_type,  ocd.PROFICIENCY_LEVEL_ID
       FROM  gmo_opert_cert_detail ocd
       WHERE header_id  = v_header_id
       AND qualification_type = 1  -- 1 is certification
       AND FROM_DATE <= v_date
       AND nvl(TO_DATE,sysdate) >= v_date
       AND qualification_id NOT IN (SELECT certification_id
                                     FROM OTA_CERT_ENROLLMENTS oce
       	                             WHERE oce.certification_status_code ='CERTIFIED'
                                     AND   oce.completion_date <= SYSDATE
                                     AND oce.business_group_id = l_business_group_id
                                     AND oce.person_id = l_employ_id )


  UNION
       SELECT ocd.Qualification_id , ocd.Qualification_type,  ocd.PROFICIENCY_LEVEL_ID
       FROM  gmo_opert_cert_detail ocd
       WHERE ocd.header_id  = v_header_id
       AND ocd.qualification_type = 2  -- 2 is competence
       AND FROM_DATE <= v_date
       AND nvl(TO_DATE,sysdate) >= v_date
       AND ocd.qualification_id NOT IN (SELECT competence_id
                                     FROM per_competence_elements pce
       	                             WHERE nvl(pce.effective_date_to, sysdate) >= SYSDATE
			             AND   pce.effective_date_from <= SYSDATE
			             AND pce.PROFICIENCY_LEVEL_ID >= ocd.PROFICIENCY_LEVEL_ID
                                     AND pce.business_group_id = v_business_id
                                     AND pce.person_id = l_employ_id );


      invalid_user             	EXCEPTION;
      NO_CERTIFICATE_REQ	EXCEPTION;
      NO_COMPETENCE_DEFINED	EXCEPTION;
      NO_COMPETENCE             EXCEPTION;
      NO_CERTIFICATE            EXCEPTION;
      INVALID_BUSINESS_GROUP_ID	EXCEPTION;

     BEGIN


     IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line ('Entering api ' || g_pkg_name || '.'
                             || l_api_name);
      END IF;
     x_return_status := fnd_api.g_ret_sts_success;

      l_user_id        		:= p_user_id   ;
      l_org_id         		:= p_org_id    ;
      l_header_id      		:= p_header_id ;
      l_operator_certificate_id := p_operator_certificate_id ;
      l_eff_date                := nvl(p_eff_date,sysdate);
      -- get the employee  data for the user_id.
      OPEN cur_get_employee (l_user_id);
      FETCH cur_get_employee
      INTO l_employ_id;

      Close cur_get_employee ;
    -- get the buiness_group_id for the org_id.
      OPEN cur_get_org (l_org_id);
      FETCH cur_get_org
      INTO l_business_group_id;
      IF (cur_get_org%NOTFOUND) THEN
         CLOSE cur_get_org;
         RAISE invalid_business_group_id;
      END IF;
      CLOSE cur_get_org;

    FOR get_rec IN get_req_competence (l_header_id,l_employ_id,l_business_group_id, l_eff_date) LOOP
      i := i+1 ;
      gmo_cert_trans_detail_dbl.insert_row( l_trans_detail_id,l_operator_certificate_id,l_header_id,
                                          get_rec.qualification_id,
                                           get_rec.qualification_type,
                                           get_rec.PROFICIENCY_LEVEL_ID, x_return_status);
      --dbms_output.put_line('l_trans_detail_id '||l_trans_detail_id);
                IF (x_return_status = fnd_api.g_ret_sts_error) THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
    END LOOP;

    EXCEPTION
    WHEN FND_API.g_exc_error  THEN

        x_return_status := fnd_api.g_ret_sts_error;

     WHEN OTHERS THEN
      	 FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      	x_return_status := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);


     END required_certification;


  Procedure Update_erecord(
     p_ERECORD_ID               IN NUMBER
    ,p_Operator_certificate_id  IN NUMBER
    ,p_EVENT_KEY                IN VARCHAR2
    ,p_EVENT_NAME               IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2) IS


    l_Operator_certificate_id   NUMBER ;
    l_EVENT_KEY                VARCHAR2 (30);
    l_EVENT_NAME               VARCHAR2 (240);


BEGIN
   -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   l_Operator_certificate_id := p_Operator_certificate_id ;
   l_EVENT_KEY               := p_EVENT_KEY  ;
   l_EVENT_NAME              := p_EVENT_NAME ;

   IF l_operator_certificate_id IS NOT NULL THEN

       update GMO_OPERATOR_CERT_TRANS
       set erecord_id = p_erecord_id
       where operator_certificate_id = l_operator_certificate_id
       AND erecord_id IS NULL ;

   END IF;

   EXCEPTION
     WHEN FND_API.g_exc_error  THEN

        x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
      	 FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      	x_return_status := fnd_api.g_ret_sts_unexp_error;


   END Update_erecord;


FUNCTION check_certification(
      p_user_id        IN                NUMBER
     ,p_org_id           IN              NUMBER
     ,p_object_id        IN              NUMBER DEFAULT NULL
     ,p_object_type      IN              NUMBER DEFAULT NULL
     ,p_eff_date         IN              DATE) RETURN NUMBER
     IS
    l_cert_status number;
    l_return_status VARCHAR2(250);
    BEGIN
       l_cert_status := check_certification(p_user_id,p_org_id,p_object_id,p_object_type,p_eff_date,l_return_status);
       RETURN l_cert_status;
  END check_certification;

   procedure update_cert_record(p_Operator_certificate_id  IN NUMBER
    ,p_EVENT_KEY                IN VARCHAR2
    ,p_EVENT_NAME               IN VARCHAR2
    ,p_ERECORD_ID               IN NUMBER
    ,p_user_key_label_token     IN VARCHAR2
    ,p_user_key_value           IN VARCHAR2
    ,p_transaction_id           IN VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2) IS
   CURSOR CUR_GET_CERT_RECORD  IS
        SELECT EVENT_NAME,EVENT_KEY,USER_KEY_LABEL_TOKEN,USER_KEY_VALUE,ERECORD_ID,
               Operator_certificate_id,TRANSACTION_ID
        FROM   GMO_OPERATOR_CERT_TRANS
        WHERE operator_certificate_id  = p_Operator_certificate_id;
  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      FOR get_rec IN CUR_GET_CERT_RECORD  LOOP
      update GMO_OPERATOR_CERT_TRANS
       set EVENT_NAME = nvl(p_EVENT_NAME,get_rec.EVENT_NAME)
       , EVENT_KEY = nvl(p_EVENT_KEY,get_rec.EVENT_KEY)
       , USER_KEY_LABEL_TOKEN = nvl(p_user_key_label_token,get_rec.USER_KEY_LABEL_TOKEN)
       , USER_KEY_VALUE = nvl(p_user_key_value,get_rec.USER_KEY_VALUE)
       , ERECORD_ID = nvl(p_ERECORD_ID,get_rec.ERECORD_ID)
       , TRANSACTION_ID = nvl(p_transaction_id,get_rec.TRANSACTION_ID)
       , STATUS = 'S'
        where operator_certificate_id = get_rec.operator_certificate_id ;

	 END LOOP;
   EXCEPTION
     WHEN FND_API.g_exc_error  THEN
        x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
      	 FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      	x_return_status := fnd_api.g_ret_sts_unexp_error;
  END update_cert_record;


  PROCEDURE cert_details (
   p_operator_CERTIFICATE_ID    IN OUT NOCOPY NUMBER
  ,p_HEADER_ID                 IN            NUMBER
  ,p_TRANSACTION_ID            IN            VARCHAR2
  ,p_USER_ID                   IN            NUMBER
  ,p_comments                   IN            VARCHAR2
  ,p_OVERRIDER_ID               IN            NUMBER
  ,p_User_key_label_product    IN            VARCHAR2
  ,p_User_key_label_token      IN            VARCHAR2
  ,p_User_key_value            IN            VARCHAR2
  ,p_Erecord_id                IN            NUMBER
  ,p_Trans_object_id           IN            NUMBER
  ,p_STATUS                    IN            VARCHAR2
  ,p_event_name                IN            VARCHAR2
  ,p_event_key                 IN            VARCHAR2
  ,p_eff_date                  IN            DATE
  ,p_CREATION_DATE             IN            DATE
  ,p_CREATED_BY                IN            NUMBER
  ,p_LAST_UPDATE_DATE          IN            DATE
  ,p_LAST_UPDATED_BY           IN            NUMBER
  ,p_LAST_UPDATE_LOGIN         IN            NUMBER
  ,x_return_Status            OUT   NOCOPY     VARCHAR2 ) IS


 l_return_status 		VARCHAR2(1) ;
 l_org_id  			NUMBER;
 l_header_id                	NUMBER;
 l_erecord_id                   NUMBER;
 l_operator_certificate_id      NUMBER;
 l_TRANSACTION_ID               VARCHAR2(240);
 l_USER_ID                      NUMBER ;
 l_comments                     VARCHAR2(240);
 l_OVERRIDER_ID                 NUMBER ;
 l_User_key_label_product       VARCHAR2(30);
 l_User_key_label_token         VARCHAR2(240);
 l_User_key_value               VARCHAR2(240);
 l_Trans_object_id              NUMBER;
 l_STATUS                       VARCHAR2(1);
 l_event_name                   VARCHAR2(240);
 l_event_key                    VARCHAR2(30);
 l_eff_date                     DATE;
 l_CREATION_DATE                DATE;
 l_CREATED_BY                   NUMBER;
 l_LAST_UPDATE_DATE             DATE;
 l_LAST_UPDATED_BY              NUMBER;
 l_LAST_UPDATE_LOGIN            NUMBER;

 BEGIN
    -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      l_HEADER_ID                := p_HEADER_ID              ;
      l_TRANSACTION_ID           := p_TRANSACTION_ID         ;
      l_USER_ID                  := p_USER_ID                ;
      l_comments                 := p_comments               ;
      l_OVERRIDER_ID             := p_OVERRIDER_ID           ;
      l_User_key_label_product   := p_User_key_label_product ;
      l_User_key_label_token     := p_User_key_label_token   ;
      l_User_key_value           := p_User_key_value         ;
      l_Trans_object_id          := p_Trans_object_id        ;
      l_STATUS                   := p_STATUS                 ;
      l_event_name               := p_event_name             ;
      l_event_key                := p_event_key              ;
      l_eff_date                 := nvl(p_eff_date,sysdate)  ;
      l_CREATION_DATE            := p_CREATION_DATE          ;
      l_CREATED_BY               := p_CREATED_BY             ;
      l_LAST_UPDATE_DATE         := p_LAST_UPDATE_DATE       ;
      l_LAST_UPDATED_BY          := p_LAST_UPDATED_BY        ;
      l_LAST_UPDATE_LOGIN        := p_LAST_UPDATE_LOGIN      ;





      gmo_oper_cert_trans_dbl.INSERT_ROW( p_operator_certificate_id => l_operator_certificate_id
                                    ,p_header_id => l_header_id
                                    ,p_transaction_id => l_transaction_id
                                    ,p_user_id => l_user_id
                                    ,p_comments => l_comments
                                    ,p_overrider_id => l_overrider_id
                                    ,p_user_key_label_product => l_user_key_label_product
                                    ,p_user_key_label_token => l_user_key_label_token
                                    ,p_user_key_value =>l_user_key_value
                                    ,p_erecord_id => NULL
                                    ,p_trans_object_id => l_trans_object_id
                                    ,p_status => l_status
                                    ,p_event_name => l_event_name
                                    ,p_event_key => l_event_key
                                    ,p_creation_date => l_creation_date
                                    ,p_created_by => l_created_by
                                    ,p_last_update_date => l_last_update_date
                                    ,p_last_updated_by => l_last_updated_by
                                    ,P_LAST_UPDATE_LOGIN => l_LAST_UPDATE_LOGIN
                                    ,x_return_Status => l_return_status);
              -- check for return status
                IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
                -- dbms_output.put_line('l_op_cert_id '||l_operator_certificate_id);
               SELECT organization_id into l_org_id
               FROM gmo_opert_cert_header
               Where header_id = l_header_id ;

             IF l_operator_certificate_id IS NOT NULL  THEN
             	 GMO_OPER_CERT_PUB.required_Certification(p_user_id =>l_user_id
                                 		   ,p_org_id => l_org_id
                                 		   ,p_header_id => l_header_id
                                 		   ,p_operator_certificate_id =>l_operator_certificate_id
                                                   ,p_eff_date => l_eff_date
                                                   ,x_return_status => l_return_status);
                   IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                    RAISE fnd_api.g_exc_error;
                   END IF;
                  gmo_opert_cert_gtmp_dbl.INSERT_ROW (
   			 p_ERECORD_ID               => l_erecord_id
   			,p_operator_certificate_id  => l_operator_certificate_id
   			,p_EVENT_KEY                => l_event_key
   			,p_EVENT_NAME               => l_event_name
   			,x_return_status            => l_return_status ) ;

   	        IF (l_return_status = fnd_api.g_ret_sts_error) THEN
                    RAISE fnd_api.g_exc_error;
                END IF;
             END IF;


             p_operator_certificate_id := l_operator_certificate_id;
   EXCEPTION
     WHEN FND_API.g_exc_error  THEN
          x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
      	 FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
      	x_return_status := fnd_api.g_ret_sts_unexp_error;

 END  cert_details;

END gmo_oper_cert_pub;

/
