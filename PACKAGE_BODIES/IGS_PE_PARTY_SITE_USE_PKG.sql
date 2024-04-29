--------------------------------------------------------
--  DDL for Package Body IGS_PE_PARTY_SITE_USE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PARTY_SITE_USE_PKG" AS
/* $Header: IGSNI79B.pls 120.1 2005/09/08 15:32:27 appldev noship $ */

PROCEDURE HZ_PARTY_SITE_USES_AK(
                p_action	       	    IN            VARCHAR2,
 		p_rowid 		    IN OUT NOCOPY VARCHAR2,
   		p_party_site_use_id	    IN OUT NOCOPY NUMBER,
   		p_party_site_id		    IN            NUMBER,
  		p_site_use_type		    IN            VARCHAR2,
		p_status                    IN            VARCHAR2,
   		p_return_status   	    OUT NOCOPY    VARCHAR2,
        	p_msg_data                  OUT NOCOPY    VARCHAR2,
                p_last_update_date	    IN OUT NOCOPY DATE,
 	        p_site_use_last_update_date IN OUT NOCOPY DATE,
 		P_profile_last_update_date  IN OUT NOCOPY DATE,
		p_hz_party_site_use_ovn      IN OUT NOCOPY   NUMBER
) AS
  /*************************************************************
  Created By : kumaravel
  Date Created By : Sep 15 2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
 		p_api_version 		  NUMBER(15)   := 1.0;
 		p_init_msg_list	  VARCHAR2(30) := FND_API.G_FALSE;
 		p_commit 			  VARCHAR2(30) := FND_API.G_FALSE;
         	p_create_site_uses	  VARCHAR2(30) := FND_API.G_TRUE;
         	p_validation_level 	  VARCHAR2(30) := FND_API.G_VALID_LEVEL_FULL;
 		l_msg_count 		  NUMBER(15);
		lv_location	       VARCHAR2(80);
		v_msg_count 		  NUMBER(15);
 		l_contact_point_id    NUMBER;
 		l_loc_id 		       NUMBER(15);
       	lv_rowid 		       VARCHAR2(25);
          l_obj_version         hz_party_site_uses.OBJECT_VERSION_NUMBER%TYPE;
          l_PARTY_SITE_USE_REC  HZ_PARTY_SITE_V2PUB.party_site_use_rec_type;

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);


BEGIN

     IF p_action = 'INSERT' THEN
--	 l_PARTY_SITE_USE_REC.BEGIN_DATE	       := SYSDATE;

               l_PARTY_SITE_USE_REC.PARTY_SITE_USE_ID	 :=  p_party_site_use_id;
               l_PARTY_SITE_USE_REC.PARTY_SITE_ID	 :=  p_party_site_id;
               l_PARTY_SITE_USE_REC.SITE_USE_TYPE	 :=  p_site_use_type;
               l_PARTY_SITE_USE_REC.STATUS	           :=  p_status;
               l_PARTY_SITE_USE_REC.created_by_module  :=  'IGS';

    HZ_PARTY_SITE_V2PUB.create_party_site_use(
         p_init_msg_list            => p_init_msg_list,
         p_party_site_use_rec       => l_PARTY_SITE_USE_REC ,
         x_party_site_use_id        => p_party_site_use_id ,
         x_return_status            => p_return_status,
         x_msg_count                => l_msg_count ,
         x_msg_data                 => p_msg_data  );


	-- check for the v_return_status
     IF p_return_status = 'S' THEN
       p_hz_party_site_use_ovn := 1;
     ELSIF p_return_status <> 'S' THEN
           -- bug 2338473 logic to display more than one error modified.
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
          p_msg_data := tmp_var1;
          END IF;
          RETURN;
     END IF;


     -- V2API uptake


   ELSIF p_action = 'UPDATE' THEN

                l_PARTY_SITE_USE_REC.PARTY_SITE_USE_ID	 :=  p_party_site_use_id;
                l_PARTY_SITE_USE_REC.PARTY_SITE_ID	 :=  p_party_site_id;
                l_PARTY_SITE_USE_REC.SITE_USE_TYPE	 :=  p_site_use_type;
                l_PARTY_SITE_USE_REC.STATUS	           :=  NVL(p_status,FND_API.G_MISS_CHAR);
            --  l_PARTY_SITE_USE_REC.created_by_module  :=  'IGS';


      HZ_PARTY_SITE_V2PUB.update_party_site_use (
                   p_init_msg_list         =>  p_init_msg_list  ,
                   p_party_site_use_rec    =>  l_PARTY_SITE_USE_REC,
                   p_object_version_number =>  p_hz_party_site_use_ovn,
                   x_return_status         =>  p_return_status,
                   x_msg_count             =>  l_msg_count,
                   x_msg_data              =>  p_msg_data  );

       -- check for the v_return_status

       IF p_return_status <> 'S' THEN
           -- bug 2338473 logic to display more than one error modified.
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
          p_msg_data := tmp_var1;
          END IF;
          RETURN;
       END IF;
END IF;

END HZ_PARTY_SITE_USES_AK;

END IGS_PE_PARTY_SITE_USE_PKG;

/
