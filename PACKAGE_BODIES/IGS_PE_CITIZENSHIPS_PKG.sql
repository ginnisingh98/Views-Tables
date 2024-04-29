--------------------------------------------------------
--  DDL for Package Body IGS_PE_CITIZENSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_CITIZENSHIPS_PKG" AS
/* $Header: IGSNI74B.pls 120.1 2005/09/21 01:07:41 appldev ship $ */

PROCEDURE validate_date(p_start_dt  IN  DATE
	               ,p_end_dt    IN  DATE
		       ,party_id    IN NUMBER
		       ,citznship_id IN NUMBER
		       ,country_cd IN VARCHAR2)
		       AS
  ------------------------------------------------------------------------------------------
  --Created by  : vredkar
  --Date created: 20-Sep-2005
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------

  l_bth_dt IGS_PE_PERSON_BASE_V.birth_date%TYPE;
  l_default_date DATE := TO_DATE('4712/12/31','YYYY/MM/DD');

  CURSOR validate_brth_dt(cp_person_id NUMBER) IS
  SELECT birth_date
  FROM  IGS_PE_PERSON_BASE_V
  WHERE person_id = cp_person_id ;

  CURSOR validate_dt_overlap(cp_party_id NUMBER, cp_start_date DATE, cp_end_date DATE , cp_citzn_id NUMBER , cp_country_cd VARCHAR2) IS
  SELECT 'X'
  FROM hz_citizenship
  WHERE party_id = cp_party_id
  AND cp_country_cd = country_code
  AND (cp_citzn_id <> citizenship_id OR cp_citzn_id IS NULL)
  AND (cp_start_date between date_recognized AND NVL(end_date,l_default_date)
  OR cp_end_date between date_recognized AND NVL(end_date,l_default_date)
  OR (cp_start_date <= date_recognized
       AND NVL(cp_end_date,l_default_date) >= NVL(end_date,l_default_date)) );

  l_Overlap_check VARCHAR2(1);

  BEGIN
	  OPEN validate_brth_dt(party_id);
	  FETCH validate_brth_dt INTO  l_bth_dt;
	  CLOSE validate_brth_dt;

	  IF p_end_dt IS NOT NULL AND p_end_dt <  p_start_dt  THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
	     IGS_GE_MSG_STACK.ADD;
	     APP_EXCEPTION.RAISE_EXCEPTION;

	  ELSIF l_bth_dt IS NOT NULL AND l_bth_dt > p_start_dt  THEN
	     FND_MESSAGE.SET_NAME('IGS','IGS_PE_DREC_GT_BTDT');
	     IGS_GE_MSG_STACK.ADD;
	     APP_EXCEPTION.RAISE_EXCEPTION;
	  END IF;


	  OPEN validate_dt_overlap(party_id, p_start_dt, p_end_dt ,citznship_id,country_cd);
          FETCH validate_dt_overlap INTO l_Overlap_check;
          IF (validate_dt_overlap%FOUND) THEN
             CLOSE validate_dt_overlap;
             FND_MESSAGE.SET_NAME('IGS','IGS_PE_CIT_DATE_OVER');
     	     IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
	 CLOSE validate_dt_overlap;
 END validate_date;


PROCEDURE Citizenship(
p_action 		IN 	VARCHAR2 ,
P_birth_or_selected  	IN 	VARCHAR2,
P_country_code 		IN	Varchar2,
p_date_disowned		IN	Date,
p_date_recognized	IN	DATE,
p_DOCUMENT_REFERENCE	IN	VARCHAR2,
p_DOCUMENT_TYPE		IN	VARCHAR2,
p_PARTY_ID		IN	NUMBER,
p_END_DATE		IN	DATE,
p_TERRITORY_SHORT_NAME	IN	VARCHAR2,
p_last_update_date	IN OUT NOCOPY	DATE,
P_citizenship_id	IN OUT NOCOPY	NUMBER,
p_return_status 	OUT NOCOPY 	VARCHAR2 ,
p_msg_count 		OUT NOCOPY 	VARCHAR2 ,
p_msg_data 		OUT NOCOPY 	VARCHAR2,
p_object_version_number IN OUT NOCOPY NUMBER,
p_Calling_From		IN	VARCHAR2
) AS

    lv_init_msg_list VARCHAR2(1) := FND_API.G_FALSE;
    lv_commit VARCHAR2(1)  := FND_API.G_FALSE ;
    lv_citizenship_id	NUMBER;
    lv_object_version_number NUMBER;
    lv_citizenship_rec_type HZ_PERSON_INFO_V2PUB.citizenship_rec_type;
    lv_last_update_date DATE := p_last_update_date;

    tmp_var   VARCHAR2(2000);
    tmp_var1  VARCHAR2(2000);

  BEGIN


    IF p_action='INSERT' THEN
       lv_citizenship_rec_type.birth_or_selected 	:= p_birth_or_selected;
       lv_citizenship_rec_type.country_code  	        := p_country_code;
       lv_citizenship_rec_type.date_disowned	        := p_date_disowned;
       lv_citizenship_rec_type.date_recognized	        := p_date_recognized;
       lv_citizenship_rec_type.document_reference       := p_document_reference;
       lv_citizenship_rec_type.party_id		        := p_party_id;
       lv_citizenship_rec_type.end_date		        := p_end_date;
       lv_citizenship_rec_type.document_type            := p_document_type;
       lv_citizenship_rec_type.created_by_module        := 'IGS';
       lv_citizenship_rec_type.application_id           := 8405;

       IF p_Calling_From='SS' THEN
	     validate_date(p_date_recognized ,p_end_date ,p_party_id , p_citizenship_id, p_country_code );
       END IF;

       --gmaheswa: HZ_API ia changed to HZ_PERSON_INFOR_V2PUB from HZ_PER_INFO_PUB.
       HZ_PERSON_INFO_V2PUB.create_citizenship(
           p_init_msg_list  		=> lv_init_msg_list,
           p_citizenship_rec		=> lv_citizenship_rec_type,
	   x_return_status		=> p_return_status,
           x_msg_count			=> p_msg_count,
	   x_msg_data			=> p_msg_Data,
	   x_citizenship_id		=> p_citizenship_id
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
       ELSE
          p_object_version_number := 1;
       END IF;
    ELSIF p_action = 'UPDATE' THEN

	  lv_citizenship_rec_type.birth_or_selected 	:= NVL(p_birth_or_selected,FND_API.G_MISS_CHAR);
          lv_citizenship_rec_type.country_code  	:= p_country_code;
          lv_citizenship_rec_type.date_disowned	        := NVL(p_date_disowned,FND_API.G_MISS_DATE);
          lv_citizenship_rec_type.date_recognized	:= NVL(p_date_recognized,FND_API.G_MISS_DATE);
          lv_citizenship_rec_type.document_reference    := NVL(p_document_reference,FND_API.G_MISS_CHAR);
          lv_citizenship_rec_type.party_id		:= p_party_id;
          lv_citizenship_rec_type.end_date		:= NVL(p_end_date,FND_API.G_MISS_DATE);
          lv_citizenship_rec_type.citizenship_id        := p_citizenship_id;
          lv_citizenship_rec_type.document_type         := NVL(p_document_type,FND_API.G_MISS_CHAR);

	  IF p_Calling_From='SS' THEN
	      validate_date(p_date_recognized ,p_end_date ,p_party_id , p_citizenship_id , p_country_code );
          END IF;

      	--gmaheswa: HZ_API ia changed to HZ_PERSON_INFOR_V2PUB from HZ_PER_INFO_PUB.
	HZ_PERSON_INFO_V2PUB.update_citizenship(
            				    	p_init_msg_list => lv_init_msg_list,
						p_citizenship_rec => lv_citizenship_rec_type,
						x_return_status => p_return_status,
						x_msg_count => p_msg_count,
						x_msg_data  => p_msg_data,
						p_object_version_number => p_object_version_number
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

    END IF;
END Citizenship;



END IGS_PE_CITIZENSHIPS_PKG;

/
