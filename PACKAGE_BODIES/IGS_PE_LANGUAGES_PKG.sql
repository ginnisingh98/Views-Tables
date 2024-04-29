--------------------------------------------------------
--  DDL for Package Body IGS_PE_LANGUAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_LANGUAGES_PKG" AS
/* $Header: IGSNI75B.pls 120.2 2005/10/10 04:33:01 appldev ship $ */

PROCEDURE Languages(
p_action 			            IN VARCHAR2 ,
P_LANGUAGE_NAME 		       IN	VARCHAR2,
p_DESCRIPTION			       IN	VARCHAR2,
p_PARTY_ID			       IN	NUMBER,
p_native_language		       IN	VARCHAR2,
p_primary_language_indicator    IN	VARCHAR2,
P_READS_LEVEL                   IN	VARCHAR2,
P_SPEAKS_LEVEL                  IN	VARCHAR2,
P_WRITES_LEVEL                  IN	VARCHAR2,
p_END_DATE                      IN	DATE,
p_status                        IN      VARCHAR2 DEFAULT 'A',
p_understand_level              IN      VARCHAR2 DEFAULT NULL,
p_last_update_date              IN OUT NOCOPY DATE,
p_return_status                 OUT NOCOPY VARCHAR2 ,
p_msg_count                     OUT NOCOPY VARCHAR2 ,
p_msg_data                      OUT NOCOPY VARCHAR2,
P_language_use_reference_id 	IN OUT NOCOPY NUMBER,
p_language_ovn                  IN OUT NOCOPY NUMBER,
p_source                        IN  VARCHAR2 DEFAULT NULL
) AS

  --  CURSOR langcursor is SELECT IGS_PE_HZ_LANGUAGES_S.NEXTVAL S from DUAL;

    lv_init_msg_list VARCHAR2(1) := FND_API.G_FALSE;
    lv_language_use_reference_id1  NUMBER;
    lv_commit VARCHAR2(1)  := FND_API.G_FALSE ;
    lv_language_use_reference_id NUMBER;

    -- V2API uptake

    lv_per_language_rec_type  HZ_PERSON_INFO_V2PUB.person_language_rec_type;

    lv_last_update_date DATE := p_last_update_date;

    lv_object_version_number  hz_person_language.OBJECT_VERSION_NUMBER%TYPE;

     tmp_var   VARCHAR2(2000);
     tmp_var1  VARCHAR2(2000);
    l_action  VARCHAR2(30);

    CURSOR dup_lang_cur (cp_language_name hz_person_language.language_name%TYPE,
	                     cp_status hz_person_language.status%TYPE,
						 cp_party_id hz_person_language.party_id%TYPE) IS
	SELECT language_use_reference_id, object_version_number
	FROM hz_person_language
	WHERE language_name = cp_language_name AND
    status = cp_status AND
	party_id = cp_party_id;

    dup_lang_rec dup_lang_cur%ROWTYPE;
   BEGIN

    lv_language_use_reference_id := p_language_use_reference_id;
    lv_object_version_number := p_language_ovn;
    l_action := p_action;

    IF l_action = 'INSERT' AND p_source = 'SS' THEN

    	    OPEN dup_lang_cur(P_LANGUAGE_NAME,'A',p_party_id);
	    FETCH dup_lang_cur INTO dup_lang_rec;

	    IF (dup_lang_cur%FOUND) THEN
		     CLOSE dup_lang_cur;
		     FND_MESSAGE.SET_NAME('IGS','IGS_PE_DUP_LANG_CODE');
		     IGS_GE_MSG_STACK.ADD;
		     RAISE FND_API.G_EXC_ERROR;
             END IF;
	     CLOSE dup_lang_cur;


	    OPEN dup_lang_cur(P_LANGUAGE_NAME,'I',p_party_id);
	    FETCH dup_lang_cur INTO dup_lang_rec;
	    CLOSE dup_lang_cur;

	    IF dup_lang_rec.language_use_reference_id IS NOT NULL THEN
		  l_action := 'UPDATE';
		  lv_language_use_reference_id := dup_lang_rec.language_use_reference_id;
		  lv_object_version_number := dup_lang_rec.object_version_number;
	    END IF;
    END IF;

   IF l_action='INSERT' THEN

    lv_per_language_rec_type.language_name 		           := p_language_name;
    lv_per_language_rec_type.party_id			           := p_party_id;
    lv_per_language_rec_type.native_language  		           := p_native_language;
    lv_per_language_rec_type.primary_language_indicator            := p_primary_language_indicator;
    lv_per_language_rec_type.reads_level		           := p_reads_level;
    lv_per_language_rec_type.speaks_level  		           := p_speaks_level;
    lv_per_language_rec_type.writes_level  		           := P_writes_level;
    lv_per_language_rec_type.created_by_module                     := 'IGS';
    lv_per_language_rec_type.spoken_comprehension_level            := p_understand_level;
    lv_per_language_rec_type.status                                := p_status;


    HZ_PERSON_INFO_V2PUB.create_person_language(
                p_init_msg_list               => lv_init_msg_list,
                p_person_language_rec         => lv_per_language_rec_type,
                x_language_use_reference_id   => P_language_use_reference_id,
                x_return_status               => p_return_status,
                x_msg_count                   => p_msg_count ,
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

	-- after successful insert, pass OVN out as 1.
	 p_language_ovn :=1;

   ELSIF l_action = 'UPDATE' THEN

    lv_per_language_rec_type.language_name 		         := p_language_name;
    lv_per_language_rec_type.party_id			         := p_party_id;
    lv_per_language_rec_type.native_language  		    := NVL(p_native_language,FND_API.G_MISS_CHAR);
    lv_per_language_rec_type.primary_language_indicator    := NVL(p_primary_language_indicator,FND_API.G_MISS_CHAR);
    lv_per_language_rec_type.reads_level	              := NVL(p_reads_level,FND_API.G_MISS_CHAR);
    lv_per_language_rec_type.speaks_level             	    := NVL(p_speaks_level,FND_API.G_MISS_CHAR);
    lv_per_language_rec_type.writes_level                  := NVL(P_writes_level,FND_API.G_MISS_CHAR);
    lv_per_language_rec_type.language_use_reference_id     := lv_language_use_reference_id;
   -- lv_per_language_rec_type.created_by_module             := 'IGS';
    lv_per_language_rec_type.spoken_comprehension_level            := NVL(p_understand_level,FND_API.G_MISS_CHAR);
    lv_per_language_rec_type.status                                := NVL(p_status,FND_API.G_MISS_CHAR);


        HZ_PERSON_INFO_V2PUB.update_person_language(
              p_init_msg_list                  => lv_init_msg_list,
              p_person_language_rec            => lv_per_language_rec_type,
              p_object_version_number          => lv_object_version_number,
              x_return_status                  => p_return_status ,
              x_msg_count                      => p_msg_count,
              x_msg_data                       => p_msg_data);



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


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     p_msg_data := SQLERRM;
 WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_ERROR;
     p_msg_data := SQLERRM;
     RAISE ;
END Languages;
END IGS_PE_LANGUAGES_PKG;

/
