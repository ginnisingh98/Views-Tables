--------------------------------------------------------
--  DDL for Package Body XLE_UTILITIES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_UTILITIES_GRP" AS
/* $Header: xlegfptb.pls 120.57.12010000.5 2009/11/04 06:02:09 abhaktha ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):=' XLE_UTILITIES_GRP';


PROCEDURE Get_Registration_Info(
	x_return_status         OUT 	NOCOPY  VARCHAR2,
  	x_msg_count		OUT	NOCOPY  NUMBER,
	x_msg_data		OUT	NOCOPY  VARCHAR2,
        P_PARTY_ID 		IN XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
        P_ENTITY_ID  		IN XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
        P_ENTITY_TYPE 		IN VARCHAR2,
        P_identifying_flag 	IN VARCHAR2,
        P_LEGISLATIVE_CATEGORY 	IN VARCHAR2,
        X_REGISTRATION_INFO 	OUT NOCOPY Registration_Tbl_Type
    ) AS


	  l_party_ID 		VARCHAR2(100);
	  l_entity_ID 		VARCHAR2(100);
	  l_identifying_flag 	VARCHAR2(1);
	  l_legislative_category VARCHAR2(100);

	  l_index     		NUMBER := 1;
	  rowcount_flag		BOOLEAN := false;


	  /* The following cursor retrieves Legal Entity and registration
	     Information for a given Legal Entity */

    CURSOR LE_Reg_c IS
	   SELECT lep.party_id,
	   	  lep.legal_entity_id ENTITY_ID,
       		  lep.name ENTITY_NAME,
	          'LEGAL_ENTITY' ENTITY_TYPE,
		   reg.registration_number,
		   reg.registered_name,
		   reg.alternate_registered_name,
		   reg.identifying_flag identifying_flag,
		   jur.legislative_cat_code LEGISLATIVE_CATEGORY,
		   (select party_name
		     from hz_parties
		     where party_id = reg.issuing_authority_id) LEGALAUTH_NAME,
		   (select hzl.address1 || ' ' || hzl.address2 || ' '
			 || hzl.city || ',' || hzl.state
		         || ',' || hzl.country || ' ' || hzl.postal_code
		      from hz_locations hzl, hz_party_sites hps
		      where hps.location_id = hzl.location_id
     and   hps.party_site_id = reg.issuing_authority_site_id) LEGALAUTH_ADDRESS,
		   reg.effective_from,
		   reg.effective_to,
		   reg.location_id,
		   hrl.address_line_1,
		   hrl.address_line_2,
		   hrl.address_line_3,
		   hrl.town_or_city,
		   hrl.region_1,
		   hrl.region_2,
		   hrl.region_3,
		   hrl.postal_code,
		   hrl.country
	   FROM XLE_ENTITY_PROFILES lep,
      	        XLE_REGISTRATIONS   reg,
         	HR_LOCATIONS_ALL    hrl,
      	        XLE_JURISDICTIONS_VL jur
   	   WHERE
		lep.legal_entity_id = reg.source_id
	   AND  reg.source_table = 'XLE_ENTITY_PROFILES'
	   AND  hrl.location_id  = reg.location_id
	   AND  jur.jurisdiction_id = reg.jurisdiction_id
	   AND  lep.party_ID like l_party_ID
	   AND  lep.legal_entity_id like l_entity_ID
	   AND  nvl(reg.identifying_flag,'N') like l_identifying_flag
	   AND  jur.legislative_cat_code like l_legislative_category
       ;

       /* The following cursor retrieves Establishment and registration
	  Information for a given Establishment */

	CURSOR ETB_Reg_c IS
	   SELECT etb.party_id,
	 	  etb.establishment_id ENTITY_ID,
       		  etb.name ENTITY_NAME,
	          'ESTABLISHMENT' ENTITY_TYPE,
		   reg.registration_number,
		   reg.registered_name,
		   reg.alternate_registered_name,
		   reg.identifying_flag identifying_flag,
		   jur.legislative_cat_code LEGISLATIVE_CATEGORY,
		   (select party_name
		     from hz_parties
		     where party_id = reg.issuing_authority_id) LEGALAUTH_NAME,
		   (select hzl.address1 || ' ' || hzl.address2 || ' '
			   || hzl.city || ',' || hzl.state
		           || ',' || hzl.country || ' ' || hzl.postal_code
		          from hz_locations hzl, hz_party_sites hps
		          where hps.location_id = hzl.location_id
     and   hps.party_site_id = reg.issuing_authority_site_id) LEGALAUTH_ADDRESS,
	       reg.effective_from,
	       reg.effective_to,
	       reg.location_id,
	       hrl.address_line_1,
	       hrl.address_line_2,
	       hrl.address_line_3,
	       hrl.town_or_city,
	       hrl.region_1,
	       hrl.region_2,
	       hrl.region_3,
	       hrl.postal_code,
	       hrl.country
	   FROM    XLE_ETB_PROFILES etb,
	    	   XLE_REGISTRATIONS   reg,
	           HR_LOCATIONS_ALL    hrl,
      	           XLE_JURISDICTIONS_VL jur
   	   WHERE
		etb.establishment_id = reg.source_id
	   AND  reg.source_table = 'XLE_ETB_PROFILES'
	   AND  hrl.location_id  = reg.location_id
	   AND  jur.jurisdiction_id = reg.jurisdiction_id
	   AND  etb.party_ID like l_party_ID
	   AND  etb.establishment_id like l_entity_ID
	   AND  nvl(reg.identifying_flag,'N') like l_identifying_flag
	   AND  jur.legislative_cat_code like l_legislative_category
       ;



BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /* Entity Type 'LEGAL_ENTITY' or 'ESTABLISHMENT' is mandatory */
  IF p_entity_type IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_data := 'Missing mandatory arguments';
    return;
  END IF;

  /* Entity Type should be 'LEGAL_ENTITY' or 'ESTABLISHMENT' */
  IF p_entity_type NOT IN ('LEGAL_ENTITY','ESTABLISHMENT') then
	x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'Misspelt mandatory arguments';
        return;
  end if;

  /* Party ID or Entity ID is mandatory */
  IF p_party_ID IS null AND p_entity_ID IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    x_msg_data := 'Please pass a value for Party ID or Entity ID.';
    return;
  ELSIF p_party_ID IS null and p_entity_ID is not null THEN
	l_party_id := '%';
	l_entity_ID := p_entity_ID;

  ELSIF p_entity_ID IS NULL and p_party_ID IS NOT null THEN
	l_entity_ID := '%';
	l_party_ID := p_party_ID;
  ELSE
	l_party_ID := p_party_ID;
	l_entity_ID := p_entity_ID;

  END IF;


  IF p_identifying_flag IS NULL THEN
	l_identifying_flag := '%';
  ELSE
	l_identifying_flag := p_identifying_flag;
  END IF;

  IF p_legislative_category IS NULL THEN
	l_legislative_category := '%';
  ELSE
	l_legislative_category := p_legislative_category;
  END IF;



  IF p_entity_type = 'LEGAL_ENTITY' THEN

	 BEGIN

	 /* The following loop assigns Legal Entity, Registration and
	    Legal Address information
	   to the output PL/SQL table x_regitration_info */

          FOR LE_Reg_r in LE_Reg_c LOOP
		rowcount_flag := true;

             x_registration_info(l_index).party_ID := LE_Reg_r.party_ID;
	     x_registration_info(l_index).entity_ID := LE_Reg_r.entity_ID;
             x_registration_info(l_index).entity_type := LE_Reg_r.entity_type;
	     x_registration_info(l_index).registration_number := LE_Reg_r.registration_number;
	     x_registration_info(l_index).registered_name := LE_Reg_r.registered_name;
             x_registration_info(l_index).alternate_registered_name := LE_Reg_r.alternate_registered_name;
	     x_registration_info(l_index).identifying_flag := LE_Reg_r.identifying_flag;
	     x_registration_info(l_index).legislative_category := LE_Reg_r.legislative_category;
	     x_registration_info(l_index).legalauth_name := LE_Reg_r.legalauth_name;
	     x_registration_info(l_index).legalauth_address := LE_Reg_r.legalauth_address;
	     x_registration_info(l_index).effective_from := LE_Reg_r.effective_from;
 	     x_registration_info(l_index).effective_to := LE_Reg_r.effective_to;
             x_registration_info(l_index).location_id := LE_Reg_r.location_id;
        x_registration_info(l_index).address_line_1 := LE_Reg_r.address_line_1;
	x_registration_info(l_index).address_line_2 := LE_Reg_r.address_line_2;
	x_registration_info(l_index).address_line_3 := LE_Reg_r.address_line_3;
	x_registration_info(l_index).town_or_city := LE_Reg_r.town_or_city;
	x_registration_info(l_index).region_1 := LE_Reg_r.region_1;
	x_registration_info(l_index).region_2 := LE_Reg_r.region_2;
	x_registration_info(l_index).region_3 := LE_Reg_r.region_3;
	x_registration_info(l_index).postal_code := LE_Reg_r.postal_code;
	x_registration_info(l_index).country := LE_Reg_r.country;

		l_index := l_index + 1;

	END LOOP;

	IF rowcount_flag <> true THEN
	   x_msg_data := 'No data found for the given parameters.';
	  return;
	END IF;

	EXCEPTION
	WHEN OTHERS THEN
         x_msg_data := 'No data found for the given parameters.';
	END;

  ELSIF p_entity_type = 'ESTABLISHMENT' THEN

  	BEGIN


	/* The following loop assigns Establishment, Registration and
	   Legal Address information
	   to the output PL/SQL table x_regitration_info */

         FOR ETB_Reg_r in ETB_Reg_c LOOP

		rowcount_flag := true;

		x_registration_info(l_index).party_ID := ETB_Reg_r.party_ID;
		x_registration_info(l_index).entity_ID := ETB_Reg_r.entity_ID;
		x_registration_info(l_index).entity_type := ETB_Reg_r.entity_type;
		x_registration_info(l_index).registration_number := ETB_Reg_r.registration_number;
		x_registration_info(l_index).registered_name := ETB_Reg_r.registered_name;
		x_registration_info(l_index).alternate_registered_name := ETB_Reg_r.alternate_registered_name;
		x_registration_info(l_index).identifying_flag := ETB_Reg_r.identifying_flag;
		x_registration_info(l_index).legislative_category := ETB_Reg_r.legislative_category;
		x_registration_info(l_index).legalauth_name := ETB_Reg_r.legalauth_name;
		x_registration_info(l_index).legalauth_address := ETB_Reg_r.legalauth_address;
		x_registration_info(l_index).effective_from := ETB_Reg_r.effective_from;
		x_registration_info(l_index).effective_to := ETB_Reg_r.effective_to;
 		x_registration_info(l_index).location_id := ETB_Reg_r.location_id;
		x_registration_info(l_index).address_line_1 := ETB_Reg_r.address_line_1;
		x_registration_info(l_index).address_line_2 := ETB_Reg_r.address_line_2;
		x_registration_info(l_index).address_line_3 := ETB_Reg_r.address_line_3;
		x_registration_info(l_index).town_or_city := ETB_Reg_r.town_or_city;
		x_registration_info(l_index).region_1 := ETB_Reg_r.region_1;
		x_registration_info(l_index).region_2 := ETB_Reg_r.region_2;
		x_registration_info(l_index).region_3 := ETB_Reg_r.region_3;
		x_registration_info(l_index).postal_code :=	ETB_Reg_r.postal_code;
 		x_registration_info(l_index).country := ETB_Reg_r.country;

		l_index := l_index + 1;


	END LOOP;

	IF rowcount_flag <> true THEN
	   x_msg_data := 'No data found for the given parameters.';
	  return;
	END IF;

      EXCEPTION
	WHEN NO_DATA_FOUND THEN
		x_msg_data := 'No data found for the given parameters.';
      END;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       x_msg_data := 'No data found for the given parameters.';

  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'No data found for the given parameters.';
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'No data found for the given parameters.';
  WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	x_msg_data := 'No data found for the given parameters.';
END  Get_Registration_Info;


PROCEDURE Get_Establishment_Info(
		x_return_status         OUT NOCOPY VARCHAR2 ,
  		x_msg_count		OUT NOCOPY NUMBER ,
		x_msg_data		OUT NOCOPY VARCHAR2 ,
        	P_PARTY_ID		IN XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
        	p_establishment_id  IN XLE_ETB_PROFILES.ESTABLISHMENT_ID%TYPE,
        	p_legalentity_id    IN XLE_ENTITY_PROFILES.legal_entity_id%TYPE,
	        p_etb_reg               IN VARCHAR2,
        	X_ESTABLISHMENT_INFO 	OUT NOCOPY Establishment_Tbl_Type
)
AS

  /* Declare local variables */

	  party_id 			NUMBER;
	  establishment_id  		NUMBER;

	  l_party_ID 		VARCHAR2(100);
	  l_establishment_ID 	VARCHAR2(100);
	  l_identifying_flag 	VARCHAR2(1);
	  l_legislative_category VARCHAR2(100);

	  l_index     	NUMBER := 1;

	  l_registration_info     XLE_UTILITIES_GRP.Registration_Tbl_Type;
	  l_msg_data		  VARCHAR2(1000);
	  l_msg_count		  number;
	  l_return_status	  varchar2(10);
	  l_establishment_name 	  xle_etb_profiles.name%type;
	  l_legalentity_id	  varchar2(100);
	  legalentity_id	  number;

      	  rowcount_flag		BOOLEAN := false;

      /* The following cursor selects establishment specific legal information
	 from xle_etb_profiles */

    CURSOR ETB_Reg_c IS
	   SELECT etb.party_id,
   		  etb.establishment_id,
       		  etb.name establishment_name,
       		  etb.legal_entity_id,
	          etb.main_establishment_flag,
		  etb.activity_code,
		  etb.sub_activity_code,
		  etb.type_of_company,
		  etb.effective_from etb_effective_from,
		  etb.effective_to etb_effective_to
	   FROM    XLE_ETB_PROFILES etb
   	   WHERE etb.party_ID like l_party_ID
  	   AND   etb.establishment_id like l_establishment_id
  	   AND   etb.legal_entity_id  like l_legalentity_id
       ;



    BEGIN

--	SAVEPOINT	Get_Establishment_Info;

	--  Initialize API return status to success

	/* Mandatory arguments are missing. Either Party ID or Legal Entity ID
	   has to be passed */

    IF p_party_ID IS null AND p_establishment_ID IS NULL AND
       p_legalentity_id IS NULL THEN
  	x_return_status := FND_API.G_RET_STS_ERROR ;
  	x_msg_data := 'Please pass a value for Party ID or Establishment ID or Legal Entity ID.';
  	return;
    END IF;

  IF p_party_ID IS null THEN
    l_party_ID := '%';
  ELSE
    l_party_ID := p_party_ID;

  	SELECT to_number(l_party_ID)
	  INTO party_ID
	  from dual;
  END IF;


  IF p_establishment_ID is null THEN
    l_establishment_ID := '%';
  ELSE
    l_establishment_ID := p_establishment_ID;
	SELECT to_number(l_establishment_ID)
	  INTO establishment_ID
	  from dual;
  END IF;

  IF p_legalentity_id IS NULL THEN
  	l_legalentity_id := '%';
  ELSE
  	l_legalentity_id := p_legalentity_id;
  END IF;


  BEGIN

    /* Establishment information for the given party ID or ETB ID or
       Legal Entity ID is retrieved from the table XLE_ETB_PROFILES in the
       following cursor */

	FOR ETB_Reg_r in ETB_Reg_c LOOP

        BEGIN


       /* Invoke get_registration_info API to get the registration information
	 for the
         current establishment obtained from the cursor record ETB_REG_R */

	   xle_utilities_grp.get_registration_info(
			 x_return_status=> l_return_status,
			 x_msg_count=> l_msg_count,
			 x_msg_data=> l_msg_data,
		         p_party_id => ETB_Reg_r.party_id,
			 p_entity_id => ETB_Reg_r.establishment_ID,
            		 p_entity_type => 'ESTABLISHMENT',
			 p_identifying_flag => 'Y',
			 p_legislative_category => null,
			 x_registration_info=> l_registration_info);


       EXCEPTION
       	WHEN OTHERS THEN
       		x_msg_data := 'No data found for the given parameters.';
       		return;
        END;

	BEGIN

	/* The registration information for the establishment in ETB_REG_R
	   is returned by the previous API call as a PL/SQL table
	   l_registration_info.
	   The following loop retrieves the registration information and
	   assigns the  values to output table records*/

           FOR x IN l_registration_info.FIRST..l_registration_info.LAST LOOP
	            rowcount_flag := true;


	    /* Assign the Establishment information to the output record
	       variables */

      	     x_establishment_info(l_index).establishment_id := ETB_Reg_r.establishment_id;
             x_establishment_info(l_index).establishment_name := ETB_Reg_r.establishment_name;
             x_establishment_info(l_index).party_ID := ETB_Reg_r.party_ID;
             x_establishment_info(l_index).legal_entity_id := ETB_Reg_r.legal_entity_id;
             x_establishment_info(l_index).main_establishment_flag := ETB_Reg_r.main_establishment_flag;
             x_establishment_info(l_index).activity_code := ETB_Reg_r.activity_code;
             x_establishment_info(l_index).sub_activity_code := ETB_Reg_r.sub_activity_code;
             x_establishment_info(l_index).type_of_company := ETB_Reg_r.type_of_company;
             x_establishment_info(l_index).effective_from := ETB_Reg_r.etb_effective_from;
             x_establishment_info(l_index).effective_to := ETB_Reg_r.etb_effective_to;


            /* Assign the Establishment's registration information to the output
	       record variables */

	     x_establishment_info(l_index).registration_number := l_registration_info(x).registration_number;
	     x_establishment_info(l_index).identifying_flag := l_registration_info(x).identifying_flag;
	     x_establishment_info(l_index).legislative_category := l_registration_info(x).legislative_category;
             x_establishment_info(l_index).effective_from := l_registration_info(x).effective_from;
             x_establishment_info(l_index).effective_to := l_registration_info(x).effective_to;
             x_establishment_info(l_index).location_id := l_registration_info(x).location_id;
             x_establishment_info(l_index).address_line_1 := l_registration_info(x).address_line_1;
             x_establishment_info(l_index).address_line_2 := l_registration_info(x).address_line_2;
             x_establishment_info(l_index).address_line_3 := l_registration_info(x).address_line_3;
             x_establishment_info(l_index).town_or_city := l_registration_info(x).town_or_city;
             x_establishment_info(l_index).region_1 := l_registration_info(x).region_1;
             x_establishment_info(l_index).region_2 := l_registration_info(x).region_2;
             x_establishment_info(l_index).region_3 := l_registration_info(x).region_3;
             x_establishment_info(l_index).postal_code := l_registration_info(x).postal_code;
             x_establishment_info(l_index).country := l_registration_info(x).country;


		l_index := l_index + 1;


        END LOOP;

	-- Bug 4185317
    /*If the flag is set to derive all etbs (with and without registrations) */
        IF ( p_etb_reg <> 'Y') then
            IF l_registration_info.count = 0 THEN

               x_establishment_info(l_index).establishment_id := ETB_Reg_r.establishment_id;
               x_establishment_info(l_index).establishment_name := ETB_Reg_r.establishment_name;
              x_establishment_info(l_index).party_ID := ETB_Reg_r.party_ID;
               x_establishment_info(l_index).legal_entity_id := ETB_Reg_r.legal_entity_id;
               x_establishment_info(l_index).main_establishment_flag := ETB_Reg_r.main_establishment_flag;
               x_establishment_info(l_index).activity_code := ETB_Reg_r.activity_code;
              x_establishment_info(l_index).sub_activity_code := ETB_Reg_r.sub_activity_code;
             x_establishment_info(l_index).type_of_company := ETB_Reg_r.type_of_company;
              x_establishment_info(l_index).effective_from := ETB_Reg_r.etb_effective_from;
              x_establishment_info(l_index).effective_to := ETB_Reg_r.etb_effective_to;

               l_index := l_index + 1;
        END IF;
 END IF;

  EXCEPTION
   when others then
	x_msg_data := 'No data found for the given parameters.';
  END;

END LOOP;

	if rowcount_flag <> true then
		x_msg_data := 'No data found for the given parameters.';
	end if;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
	x_msg_data := 'No data found for the given parameters.';
	return;

  END;

  x_msg_data := null;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       x_msg_data := 'No data found for the given parameters.';
 --      ROLLBACK TO Get_Establishment_Info;

  WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'No data found for the given parameters.';
  	--ROLLBACK TO Get_Establishment_Info;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'No data found for the given parameters.';
--	ROLLBACK TO Get_Establishment_Info;
  WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	x_msg_data := 'No data found for the given parameters.';
--	ROLLBACK TO Get_Establishment_Info;
END  Get_Establishment_Info;


PROCEDURE Get_LegalEntity_Info(
		x_return_status         OUT NOCOPY  VARCHAR2 ,
  		x_msg_count		OUT NOCOPY  NUMBER  ,
		x_msg_data		OUT NOCOPY  VARCHAR2 ,
        	P_PARTY_ID    		IN XLE_ENTITY_PROFILES.PARTY_ID%TYPE,
        	P_LegalEntity_ID	IN XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
        	X_LEGALENTITY_INFO 	OUT NOCOPY LegalEntity_Rec
)
AS
	  party_id 	  NUMBER;
	  legalentity_id  NUMBER;

	  l_party_ID 	number;
	  l_legal_entity_id 	number;
      	  l_legalentity_name xle_entity_profiles.name%type;
  	  l_legal_identifier xle_entity_profiles.legal_entity_identifier%type;
	  l_transacting_flag xle_entity_profiles.transacting_entity_flag%type;
	  l_activity_code    xle_entity_profiles.activity_code%type;
	  l_type_of_company  xle_entity_profiles.type_of_company%type;
	  l_sub_activity_code xle_entity_profiles.sub_activity_code%type;
	  l_le_effective_from xle_entity_profiles.effective_from%type;
	  l_le_effective_to xle_entity_profiles.effective_to%type;

	  l_index     	NUMBER := 1;

	  l_registration_info       XLE_UTILITIES_GRP.Registration_Tbl_Type;
	  l_msg_data		    VARCHAR2(1000);
	  l_msg_count	            number;
	  l_return_status	    varchar2(10);

      	  rowcount_flag		BOOLEAN := false;

	BEGIN

	-- SAVEPOINT	Get_LegalEntity_Info;

	--  Initialize API return status to success

    	x_return_status := FND_API.G_RET_STS_SUCCESS;


	/* Mandatory arguments are missing. Either Party ID or Legal Entity ID
	    has to be passed */

	  IF p_party_ID IS null AND p_legalentity_id IS NULL THEN
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   x_msg_data := 'Please pass a value for Party ID or Legal Entity ID.';
	   return;
	  ELSIF p_party_ID IS null and p_legalentity_id is not null THEN

	  /* Select legal entity information into local placeholder variables
	     for the given party ID or Legal Entity ID  */

 		SELECT lep.party_id,
	   	  lep.legal_entity_id,
       		  lep.name legalentity_name,
       		  lep.legal_entity_identifier,
       		  lep.transacting_entity_flag,
	          lep.activity_code,
		  lep.sub_activity_code,
		  lep.type_of_company,
		  lep.effective_from,
		  lep.effective_to
 		into 	 l_party_id,
	 	     	 l_legal_entity_id,
		         l_legalentity_name,
		     	 l_legal_identifier,
			 l_transacting_flag,
			 l_activity_code,
			 l_sub_activity_code,
			 l_type_of_company,
			 l_le_effective_from,
			 l_le_effective_to
		   FROM    XLE_ENTITY_PROFILES lep
	   	   WHERE  lep.legal_entity_id = p_legalentity_id;

	  ELSIF p_legalentity_id IS NULL and p_party_ID IS NOT null THEN

			SELECT lep.party_id,
	   		  	lep.legal_entity_id,
       		  		lep.name legalentity_name,
       		  		lep.legal_entity_identifier,
       		  		lep.transacting_entity_flag,
		      		lep.activity_code,
		      		lep.sub_activity_code,
		      		lep.type_of_company,
		      		lep.effective_from,
		      		lep.effective_to
 			into 	 l_party_id,
			     	 l_legal_entity_id,
			     	 l_legalentity_name,
				 l_legal_identifier,
				 l_transacting_flag,
				 l_activity_code,
				 l_sub_activity_code,
				 l_type_of_company,
				 l_le_effective_from,
				 l_le_effective_to
		   FROM    XLE_ENTITY_PROFILES lep
	   	   WHERE lep.party_ID = p_party_id;


 	  ELSE

 	  	SELECT lep.party_id,
	   	  	lep.legal_entity_id,
       		  	lep.name legalentity_name,
       		  	lep.legal_entity_identifier,
       		  	lep.transacting_entity_flag,
		      	lep.activity_code,
		      	lep.sub_activity_code,
		      	lep.type_of_company,
		      	lep.effective_from,
		      	lep.effective_to
 			into	 l_party_id,
			    	 l_legal_entity_id,
			     	 l_legalentity_name,
				 l_legal_identifier,
				 l_transacting_flag,
				 l_activity_code,
				 l_sub_activity_code,
				 l_type_of_company,
				 l_le_effective_from,
				 l_le_effective_to
		   FROM    XLE_ENTITY_PROFILES lep
	   	   WHERE lep.party_ID = p_party_id
			  and lep.legal_entity_id = p_legalentity_id;

	  END IF;


	  BEGIN

	    xle_utilities_grp.get_registration_info(
	 		 x_return_status=> l_return_status,
			 x_msg_count=> l_msg_count,
			 x_msg_data=> l_msg_data,
			 p_party_id => l_party_id,
	                 p_entity_id => l_legal_entity_id,
            		 p_entity_type => 'LEGAL_ENTITY',
			 p_identifying_flag => 'Y',
			 p_legislative_category => null,
			 x_registration_info=> l_registration_info);


	  EXCEPTION
      	    WHEN OTHERS THEN
	   	x_msg_data := 'No data found for the given parameters.';
		return;
	  END;


	  x_legalentity_info.legal_entity_id := l_legal_entity_id;
	  x_legalentity_info.name := l_legalentity_name;
	  x_legalentity_info.party_ID := l_party_ID;
	  x_legalentity_info.legal_entity_identifier := l_legal_identifier;
	  x_legalentity_info.transacting_entity_flag := l_transacting_flag;
	  x_legalentity_info.activity_code := l_activity_code;
	  x_legalentity_info.sub_activity_code := l_sub_activity_code;
	  x_legalentity_info.type_of_company := l_type_of_company;
	  x_legalentity_info.le_effective_from := l_le_effective_from;
	  x_legalentity_info.le_effective_to := l_le_effective_to;
	  x_legalentity_info.registration_number := l_registration_info(1).registration_number;
	  x_legalentity_info.identifying_flag := l_registration_info(1).identifying_flag;
	  x_legalentity_info.legislative_category := l_registration_info(1).legislative_category;
	  x_legalentity_info.effective_from := l_registration_info(1).effective_from;
	  x_legalentity_info.effective_to := l_registration_info(1).effective_to;
	  x_legalentity_info.location_id := l_registration_info(1).location_id;
   	  x_legalentity_info.address_line_1 := l_registration_info(1).address_line_1;
          x_legalentity_info.address_line_2 := l_registration_info(1).address_line_2;
          x_legalentity_info.address_line_3 := l_registration_info(1).address_line_3;
          x_legalentity_info.town_or_city := l_registration_info(1).town_or_city;
          x_legalentity_info.region_1 := l_registration_info(1).region_1;
          x_legalentity_info.region_2 := l_registration_info(1).region_2;
          x_legalentity_info.region_3 := l_registration_info(1).region_3;
          x_legalentity_info.postal_code := l_registration_info(1).postal_code;
          x_legalentity_info.country := l_registration_info(1).country;


	  x_msg_data := null;
  	  x_return_status := FND_API.G_RET_STS_SUCCESS;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
               	x_return_status := FND_API.G_RET_STS_ERROR ;
        	x_msg_data := 'No data found for the given parameters.';
        	-- ROLLBACK TO Get_LegalEntity_Info;

          WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
                x_msg_data := 'No data found for the given parameters.';
  	        --	ROLLBACK TO Get_LegalEntity_Info;
	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        	x_msg_data := 'No data found for the given parameters.';
		--	ROLLBACK TO Get_LegalEntity_Info;
	  WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		x_msg_data := 'No data found for the given parameters.';
		--	ROLLBACK TO Get_LegalEntity_Info;
END  Get_LegalEntity_Info;




PROCEDURE Get_History_Info(
	x_return_status         OUT 	NOCOPY  VARCHAR2 ,
  	x_msg_count		OUT	NOCOPY  NUMBER	,
	x_msg_data		OUT	NOCOPY  VARCHAR2 ,
        P_ENTITY_ID  		IN XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
        P_ENTITY_TYPE 		IN VARCHAR2,
        P_EFFECTIVE_DATE	IN VARCHAR2,
        X_HISTORY_INFO 		OUT NOCOPY History_Tbl_Type
    )
    IS

l_history_rec History_Rec;

l_source_table varchar2(100);
l_source_id    number;
l_source_column_name varchar2(100);
l_entity_id number;

l_effective_date date;

cursor history_dated_c is
	SELECT  xlh1.source_table,
    		   xlh1.source_id,
    		   xlh1.source_column_name,
    		   xlh1.source_column_value,
    		   xlh1.effective_from,
    		   xlh1.effective_to,
    		   xlh1.comments
    	FROM XLE_HISTORIES xlh1
        where trunc(to_date(l_effective_date,'DD-MM-YYYY'))
         between (trunc(to_date(effective_from,'DD-MM-YYYY'))) and
	          trunc(nvl(to_date(effective_to,'DD-MM-YYYY'),sysdate))
	AND xlh1.source_table = l_source_table
	AND xlh1.source_id = l_entity_id;


cursor history_c is
	SELECT  xlh1.source_table,
    		   xlh1.source_id,
    		   xlh1.source_column_name,
    		   xlh1.source_column_value,
    		   xlh1.effective_from,
    		   xlh1.effective_to,
    		   xlh1.comments
    	  FROM XLE_HISTORIES xlh1
    	  WHERE xlh1.source_table = l_source_table
	    AND xlh1.source_id = l_entity_id;

l_index  number := 1;
rowcount_flag boolean := false;

BEGIN
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF P_ENTITY_ID IS null OR P_ENTITY_TYPE IS NULL THEN
 	   x_msg_data := 'Missing Mandatory Arguments.';
	   return;
        END IF;

    IF P_ENTITY_TYPE = 'LEGAL_ENTITY' THEN
      l_source_table := 'XLE_ENTITY_PROFILES';
    ELSIF P_ENTITY_TYPE = 'ESTABLISHMENT' THEN
      l_source_table := 'XLE_ETB_PROFILES';
    ELSIF P_ENTITY_TYPE = 'REGISTRATIONS' THEN
      l_source_table := 'XLE_REGISTRATIONS';
    END IF;

	IF P_EFFECTIVE_DATE is not null THEN

	  BEGIN
    		l_entity_id := p_entity_id;

    		select to_date(p_effective_date,'DD-MM-YYYY')
    		 into l_effective_date
    		 from dual;

		begin

    		for history_dated_r in history_dated_c loop
    			rowcount_flag := true;


    		   X_HISTORY_INFO(l_index).source_table := history_dated_r.source_table;
    		   X_HISTORY_INFO(l_index).source_id := history_dated_r.source_id;
    		   X_HISTORY_INFO(l_index).source_column_name := history_dated_r.source_column_name;
    		   X_HISTORY_INFO(l_index).source_column_value := history_dated_r.source_column_value;
    		   X_HISTORY_INFO(l_index).effective_from := history_dated_r.effective_from;
    		   X_HISTORY_INFO(l_index).effective_to := history_dated_r.effective_to;
    		   X_HISTORY_INFO(l_index).comments := history_dated_r.comments;


			   l_index := l_index + 1;
			   end loop;
		exception
		   when others then
			null;
		end;

    		if rowcount_flag <> true then
			x_msg_data := 'No data found for the given parameters.';
		end if;

	  EXCEPTION
	  	 WHEN NO_DATA_FOUND THEN
	  	   x_msg_data := 'No data found for the given parameters.';
	  	   return;
	  END;

    ELSE

		l_entity_id := p_entity_id;


		for history_r in history_c loop
		   rowcount_flag := true;

    		   X_HISTORY_INFO(l_index).source_table := history_r.source_table;
    		   X_HISTORY_INFO(l_index).source_id := history_r.source_id;
    		   X_HISTORY_INFO(l_index).source_column_name := history_r.source_column_name;
    		   X_HISTORY_INFO(l_index).source_column_value := history_r.source_column_value;
    		   X_HISTORY_INFO(l_index).effective_from := history_r.effective_from;
    		   X_HISTORY_INFO(l_index).effective_to := history_r.effective_to;
    		   X_HISTORY_INFO(l_index).comments := history_r.comments;

			   l_index := l_index + 1;
		end loop;

		if rowcount_flag <> true then
			x_msg_data := 'No data found for the given parameters.';
		end if;

    END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'No data found for the given parameters.';

      WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'No data found for the given parameters.';
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_data := 'No data found for the given parameters.';
      WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	x_msg_data := 'No data found for the given parameters.';

END Get_History_Info;



PROCEDURE Get_LegalEntityID_OU
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list	    	IN	VARCHAR2,
  	p_commit	        IN	VARCHAR2,
  	x_return_status         OUT 	NOCOPY  VARCHAR2 ,
  	x_msg_count	       	OUT	NOCOPY NUMBER	,
	x_msg_data	        OUT	NOCOPY VARCHAR2 ,
	p_operating_unit        IN  	NUMBER ,
	x_LegalEntity_tbl       OUT 	NOCOPY LegalEntity_tbl_type

)
AS

l_api_name	    CONSTANT VARCHAR2(30):= 'Get_LegalEntityID_OU';
l_api_version       CONSTANT NUMBER:= 1.0;
l_ledger_id         HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE;
l_le_list           GL_MC_INFO.LE_BSV_TBL_TYPE := gl_mc_info.le_bsv_tbl_type();
l_legal_entity_id   XLE_ENTITY_PROFILES.legal_entity_id%TYPE;
l_index             NUMBER := 0;
l_ledger_flag       BOOLEAN;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
BEGIN
        SELECT O3.ORG_INFORMATION3
	  INTO l_ledger_id
	  FROM HR_ALL_ORGANIZATION_UNITS O, HR_ORGANIZATION_INFORMATION O2, HR_ORGANIZATION_INFORMATION O3
	  WHERE O.ORGANIZATION_ID = O2.ORGANIZATION_ID
	    AND O2.ORGANIZATION_ID = O3.ORGANIZATION_ID
	    AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
	    AND O2.ORG_INFORMATION_CONTEXT||'' = 'CLASS'
	    AND O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
	    AND O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
	    AND O2.ORG_INFORMATION2 = 'Y'
	    AND o.organization_id = p_operating_unit;

    --  l_le_list := gl_mc_info.le_bsv_tbl_type();

      l_ledger_flag := GL_MC_INFO.get_legal_entities(
                       l_ledger_id,
                       l_le_list
                     );


      FOR x IN l_le_list.FIRST..l_le_list.LAST LOOP

        l_legal_entity_id := l_le_list(x).legal_entity_id;
        x_LegalEntity_tbl(l_index) := l_legal_entity_id;
        l_index :=l_index + 1;

      END LOOP;


END Get_LegalEntityID_OU;


PROCEDURE Get_LegalEntityName_PID(
	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2,
  	p_commit		IN	VARCHAR2,
  	x_return_status         OUT NOCOPY VARCHAR2,
  	x_msg_count	        OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
    p_party_id              	IN  NUMBER,
    x_legal_entity_name     	OUT NOCOPY VARCHAR2
 )
IS
l_api_name	    CONSTANT VARCHAR2(30) := 'Get_LegalEntityName_PID';
l_api_version       CONSTANT NUMBER:= 1.0;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);

BEGIN

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;

    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    -- Waiting for Ledger API.

      SELECT lep.name
        INTO x_legal_entity_name
        FROM XLE_ENTITY_PROFILES lep
        WHERE lep.party_id=p_party_id;

	-- End of API body.
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'The Party ' || p_party_id ||
	              ' does not have a Legal Entity associated with it.';

    WHEN TOO_MANY_ROWS THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'The Party ' || p_party_id ||
		      ' is associated with more than one Legal Entity.';

    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count ,
        		p_data          	=>      x_msg_data
    		);
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count ,
        	        p_data          	=>      x_msg_data
    		);
      WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF 	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
       		FND_MSG_PUB.Add_Exc_Msg
        		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
	END IF;
	FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count   ,
        		p_data          	=>      x_msg_data
    		);
END  Get_LegalEntityName_PID;

PROCEDURE Get_FP_CountryCode_LID(
       p_api_version            IN	NUMBER	,
  	p_init_msg_list		IN	VARCHAR2,
  	p_commit		IN	VARCHAR2,
  	x_return_status         OUT     NOCOPY  VARCHAR2 ,
  	x_msg_count		OUT	NOCOPY NUMBER    ,
	x_msg_data		OUT	NOCOPY VARCHAR2  ,
        p_ledger_id             IN      NUMBER,
        x_register_country_tbl     OUT NOCOPY CountryCode_tbl_type
  )
IS
l_api_name	    CONSTANT VARCHAR2(30):= 'Get_FP_CountryCode_LID';
l_api_version       CONSTANT NUMBER:= 1.0;
l_ledger_id         HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE;
l_le_list           GL_MC_INFO.LE_BSV_TBL_TYPE := gl_mc_info.le_bsv_tbl_type();
l_legal_entity_id   XLE_ENTITY_PROFILES.legal_entity_id%TYPE;
l_index             NUMBER;
l_ledger_flag       BOOLEAN;
l_country_code      HZ_GEOGRAPHIES.COUNTRY_CODE%TYPE;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);

l_exists            BOOLEAN;
BEGIN
l_exists := FALSE;
	l_index             := 0;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
      l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success

       x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

      l_ledger_id := p_ledger_id;

      l_ledger_flag := GL_MC_INFO.get_legal_entities(
                       p_ledger_id  => l_ledger_id,
                       x_le_list    => l_le_list
                     );


      FOR x IN l_le_list.FIRST..l_le_list.LAST LOOP

        l_legal_entity_id := l_le_list(x).legal_entity_id;

        SELECT DISTINCT hrl.country
          INTO l_country_code
          FROM XLE_ENTITY_PROFILES lep,
               HR_LOCATIONS_ALL hrl,
               XLE_REGISTRATIONS reg
          WHERE lep.legal_entity_id = l_legal_entity_id
            AND reg.source_id = lep.legal_entity_id
            AND reg.source_table = 'XLE_ENTITY_PROFILES'
            AND reg.location_id = hrl.location_id;


		FOR i IN 1..l_index loop
          IF x_register_country_tbl(i).country_code = l_country_code THEN
            l_exists := true;
            EXIT;
          ELSE
	    l_exists := false;
          END IF;
        END LOOP;

        IF l_exists = false THEN
             x_register_country_tbl(l_index).country_code := l_country_code;
             l_index :=l_index + 1;
        END IF;


      END LOOP;

	-- End of API body.
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'Could not find an associated Country Code for Ledger ID : ' || p_ledger_id;

   WHEN TOO_MANY_ROWS THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'Ledger ID : '|| p_ledger_id || ' has more than one Country Code associated with it.';
           RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
    WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count ,
        		p_data          	=>      x_msg_data
    		);
END  Get_FP_CountryCode_LID;


PROCEDURE Get_FP_CountryCode_OU(
        p_api_version              IN	NUMBER,
  	p_init_msg_list	   IN	VARCHAR2,
  	p_commit		   IN	VARCHAR2,
     	x_return_status            OUT  NOCOPY  VARCHAR2 ,
     	x_msg_count		   OUT	NOCOPY NUMBER	,
	x_msg_data		   OUT	NOCOPY VARCHAR2                        ,
        p_operating_unit           IN NUMBER,
        x_country_code       OUT NOCOPY VARCHAR2
  )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Get_FP_CountryCode_OU';
l_api_version           	CONSTANT NUMBER:= 1.0;
l_ledger_id         HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE;
l_le_list           GL_MC_INFO.LE_BSV_TBL_TYPE;
l_legal_entity_id   XLE_ENTITY_PROFILES.legal_entity_id%TYPE;
l_index             NUMBER;
l_ledger_flag       BOOLEAN;
l_country_code      HZ_GEOGRAPHIES.COUNTRY_CODE%TYPE;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
BEGIN

    l_index           := 0;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- API body


    BEGIN

      l_legal_entity_id := GET_DefaultLegalContext_OU(p_operating_unit);

      IF l_legal_entity_id IS NOT NULL THEN
        SELECT hrl.country
          INTO x_country_code
          FROM XLE_ENTITY_PROFILES xlep,
               XLE_REGISTRATIONS reg,
               HR_LOCATIONS_ALL hrl
          WHERE xlep.legal_entity_id = reg.source_id
            AND reg.source_table = 'XLE_ENTITY_PROFILES'
            AND reg.identifying_flag = 'Y'
            AND nvl(reg.effective_from,sysdate) <= sysdate
            AND nvl(reg.effective_to, sysdate) >= sysdate
            AND reg.location_id = hrl.location_id
            AND xlep.legal_entity_id = l_legal_entity_id;
      ELSE
        x_country_code := null;
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'The Operating Unit is not associated with a Legal Entity.';
      END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'Could not find an associated Country Code for the Legal Entity : ' || l_legal_entity_id;
           RAISE FND_API.G_EXC_ERROR;

         WHEN TOO_MANY_ROWS THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'The Legal Entity : ' || l_legal_entity_id || ' is associated with more than one Country';
           RAISE FND_API.G_EXC_ERROR;

       END;

	-- End of API body.
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  Get_FP_CountryCode_OU;


PROCEDURE IsEstablishment_PID(
        p_api_version           IN	NUMBER,
  	p_init_msg_list	        IN	VARCHAR2,
  	p_commit	        IN	VARCHAR2,
      	x_return_status         OUT     NOCOPY  VARCHAR2,
      	x_msg_count	        OUT	NOCOPY NUMBER,
    	x_msg_data	        OUT	NOCOPY VARCHAR2,
        p_party_id              IN  NUMBER,
        x_establishment         OUT NOCOPY VARCHAR2

  )
IS
l_api_name	    CONSTANT VARCHAR2(30):= 'IsEstablishment_PID';
l_api_version       CONSTANT NUMBER:= 1.0;
l_establishment_flag varchar2(1);

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
BEGIN

	-- Standard Start of API savepoint


    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
      l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.

    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
           	       	    	 		l_api_name,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

        l_establishment_flag := 'N';

      BEGIN
        SELECT 'Y'
          INTO l_establishment_flag
          FROM XLE_ETB_PROFILES
         WHERE party_id = p_party_id
           AND ( effective_to >= sysdate OR effective_to is null);

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_establishment_flag := 'N';

     END;

        IF l_establishment_flag  = 'Y' THEN
           x_establishment := FND_API.G_TRUE;
        ELSE
           x_establishment := FND_API.G_FALSE;
        END IF;


	-- End of API body.

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  IsEstablishment_PID;

PROCEDURE IsTransEntity_PID (
    p_api_version           IN	NUMBER				,
  	p_init_msg_list		    IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
  	x_return_status         OUT     NOCOPY  VARCHAR2                ,
  	x_msg_count		OUT	NOCOPY NUMBER				,
	x_msg_data		OUT	NOCOPY VARCHAR2                        ,
        p_party_id              IN      NUMBER                          ,
        x_TransEntity           OUT     NOCOPY  VARCHAR2
  )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'IsTransEntity_PID';
l_api_version           	CONSTANT NUMBER:= 1.0;
l_TransEntity                   VARCHAR2(1);

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
BEGIN

	-- Standard Start of API savepoint


	l_TransEntity       := null;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
     BEGIN
        SELECT transacting_entity_flag
          INTO l_TransEntity
          FROM xle_entity_profiles
         WHERE party_id = p_party_id;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_TransEntity := 'N';

     END;

        IF l_TransEntity  = 'Y' THEN
           x_TransEntity := FND_API.G_TRUE;
        ELSE
           x_TransEntity := FND_API.G_FALSE;
        END IF;

	-- End of API body.
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'The Party ID ' || p_party_id || ' is not associated with a Legal Entity.' ;

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  IsTransEntity_PID;


PROCEDURE Get_PartyID_OU(
    p_api_version           IN	NUMBER				,
  	p_init_msg_list		    IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
  	x_return_status         OUT NOCOPY  VARCHAR2                ,
  	x_msg_count	         	OUT	NOCOPY NUMBER				,
	x_msg_data		        OUT	NOCOPY VARCHAR2,
    p_operating_unit        IN  NUMBER,
    x_party_tbl             OUT NOCOPY PartyID_tbl_type
  )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Get_PartyID_OU';
l_api_version       CONSTANT NUMBER:= 1.0;
l_ledger_id         HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE;
l_le_list           GL_MC_INFO.LE_BSV_TBL_TYPE;
l_legal_entity_id   XLE_ENTITY_PROFILES.legal_entity_id%TYPE;
l_index             NUMBER;
l_party_id          HR_ALL_ORGANIZATION_UNITS.PARTY_ID%TYPE;
l_ledger_flag       BOOLEAN;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
BEGIN
	-- Standard Start of API savepoint

	l_index  := 0;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

    BEGIN
        SELECT O3.ORG_INFORMATION3
	  INTO l_ledger_id
	  FROM HR_ALL_ORGANIZATION_UNITS O, HR_ORGANIZATION_INFORMATION O2, HR_ORGANIZATION_INFORMATION O3
	  WHERE O.ORGANIZATION_ID = O2.ORGANIZATION_ID
	    AND O2.ORGANIZATION_ID = O3.ORGANIZATION_ID
	    AND O.ORGANIZATION_ID = O3.ORGANIZATION_ID
	    AND O2.ORG_INFORMATION_CONTEXT||'' = 'CLASS'
	    AND O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
	    AND O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
	    AND O2.ORG_INFORMATION2 = 'Y'
	    AND o.organization_id = p_operating_unit;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'The Operating Unit : ' || p_operating_unit || ' is not associated with a Ledger ID.';
           RAISE FND_API.G_EXC_ERROR;

         WHEN TOO_MANY_ROWS THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'The Operating Unit : ' || p_operating_unit || ' is associated with more than one Ledger ID.';
           RAISE FND_API.G_EXC_ERROR;
     END;


      l_ledger_flag := GL_MC_INFO.get_legal_entities(
                       p_ledger_id  => l_ledger_id,
                       x_le_list    => l_le_list
                     );

     BEGIN
      FOR x IN l_le_list.FIRST..l_le_list.LAST LOOP
        l_legal_entity_id := l_le_list(x).legal_entity_id;

        SELECT party_id
          INTO l_party_id
          FROM XLE_ENTITY_PROFILES
          WHERE legal_entity_id = l_legal_entity_id;

        x_party_tbl(l_index) := l_party_id;
        l_index :=l_index + 1;

      END LOOP;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'The Legal Entity : ' || l_legal_entity_id || ' does not have an associated Party ID.';
           RAISE FND_API.G_EXC_ERROR;

         WHEN TOO_MANY_ROWS THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'The Legal Entity : ' || l_legal_entity_id || ' is associated with more than one Party ID.';
           RAISE FND_API.G_EXC_ERROR;
     END;
     -- End of API body.

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>    x_msg_count     	,
        		p_data          	=>    x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  Get_PartyID_OU;



PROCEDURE Is_Intercompany_LEID(
        p_api_version           IN	NUMBER,
        p_init_msg_list		    IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
      	x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count	         	OUT	NOCOPY NUMBER,
        x_msg_data		        OUT	NOCOPY VARCHAR2,
        p_legal_entity_id1      IN  VARCHAR2,
        p_legal_entity_id2      IN  VARCHAR2,
        x_Intercompany          OUT NOCOPY VARCHAR2
  )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Is_Intercompany_LEID';
l_api_version       CONSTANT NUMBER:= 1.0;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
l_count             NUMBER := 0;

BEGIN

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 			        l_api_name,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- It is assumed that all LEs can interact with all LEs unless
   -- an exception has been explicitly defined
   -- Bug 4724057, Related LE functionality will now be used
   -- to store intercompany exceptions
   SELECT COUNT(*)
   INTO   l_count
   FROM   xle_associations ass,
          xle_association_types typ
   WHERE  typ.association_type_id = ass.association_type_id
   AND    typ.context             = 'RELATED_LEGAL_ENTITIES'
   AND    Nvl(ass.effective_to,SYSDATE) >= SYSDATE
   AND    ((ass.object_id         = p_legal_entity_id1
   AND    ass.subject_id          = p_legal_entity_id2)
   OR     (ass.object_id          = p_legal_entity_id2
   AND    ass.subject_id          = p_legal_entity_id1));

   IF l_count > 0
   THEN
       x_intercompany := 'N';
   ELSE
       x_intercompany := 'Y';
   END IF;

   FND_MSG_PUB.Count_And_Get
       (p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get
          (p_count         	=>      x_msg_count,
       	   p_data          	=>      x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
           (p_count         	=>      x_msg_count,
            p_data          	=>      x_msg_data);
   WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
                (G_PKG_NAME  	    ,
                 l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get (p_count     	=>      x_msg_count ,
                                    p_data     	=>      x_msg_data);
END  Is_Intercompany_LEID;




PROCEDURE Get_ME_PARTYID_LEID(
        p_api_version           IN	NUMBER,
      	p_init_msg_list		    IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
      	x_return_status         OUT NOCOPY VARCHAR2,
  	    x_msg_count	         	OUT	NOCOPY NUMBER,
	    x_msg_data		        OUT	NOCOPY VARCHAR2,
        p_legal_entity_id      IN  VARCHAR2,
        x_me_party_id          OUT NOCOPY VARCHAR2
  )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Get_ME_PARTYID_LEID';
l_api_version       CONSTANT NUMBER:= 1.0;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);

BEGIN

	-- Standard Start of API savepoint


    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 			        l_api_name,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body.

      BEGIN

       SELECT etbp.party_id
         INTO x_me_party_id
	 FROM XLE_ETB_PROFILES etbp
	 WHERE etbp.main_establishment_flag = 'Y'
	   AND etbp.legal_entity_id = p_legal_entity_id
	   AND TRUNC(sysdate) BETWEEN TRUNC(NVL(main_effective_from,sysdate))
                                  AND TRUNC(NVL(main_effective_to,sysdate));

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR ;
           x_msg_data := 'There exists no legal entity with ID ' || p_legal_entity_id;
           RAISE FND_API.G_EXC_ERROR;

      END;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- End of API body.

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  Get_ME_PARTYID_LEID;





PROCEDURE Get_RegisterNumber_PID(
        p_api_version           IN	NUMBER,
  	    p_init_msg_list		    IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
      	x_return_status         OUT NOCOPY  VARCHAR2,
      	x_msg_count	         	OUT	NOCOPY NUMBER,
    	x_msg_data		        OUT	NOCOPY VARCHAR2,
        p_party_id              IN  NUMBER,
        x_regnum_tbl            OUT NOCOPY RegNum_tbl_type
   )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Get_RegisterNumber_PID';
l_api_version       CONSTANT NUMBER:= 1.0;
l_index             NUMBER;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);
CURSOR regnum_c IS
SELECT reg.registration_number,jur.legislative_cat_code
FROM XLE_ETB_PROFILES etbp,
     XLE_REGISTRATIONS reg,
     XLE_JURISDICTIONS_VL jur
WHERE  etbp.establishment_id = reg.source_id
AND    trunc(reg.source_table) = 'XLE_ETB_PROFILES'
AND    reg.jurisdiction_id = jur.jurisdiction_id
AND    etbp.party_id = p_party_id;

BEGIN

	-- Standard Start of API savepoint

	l_index := 0;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
           	       	    	 			l_api_name,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR regnum_r IN regnum_c LOOP

       x_regnum_tbl(l_index).registration_number  := regnum_r.registration_number;
       x_regnum_tbl(l_index).legislative_cat_code := regnum_r.legislative_cat_code;
       l_index :=l_index+1;

   END LOOP;

	-- End of API body.

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION

    WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       -- x_msg_data := 'Party ID : ' || p_party_id || ' is not associated with an Establishment.';
       -- For bug 4185317
       x_msg_data :=  'No data found for the given set of parameters.';
       RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  Get_RegisterNumber_PID;

PROCEDURE Get_PartyClassification_PID(
        p_api_version           IN	NUMBER,
  	    p_init_msg_list		    IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
      	x_return_status         OUT NOCOPY  VARCHAR2,
      	x_msg_count	         	OUT	NOCOPY NUMBER,
    	x_msg_data		        OUT	NOCOPY VARCHAR2,
        p_party_id              IN  NUMBER,
        x_partyclass_tbl        OUT NOCOPY PartyClass_tbl_type
   )
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Get_PartyClassification_PID';
l_api_version       CONSTANT NUMBER:= 1.0;
l_index             NUMBER;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);

CURSOR parties_c IS
  SELECT etbp.etb_information1 activity_code,
       fndlookup.lookup_type class_category,
       fndlookup.lookup_code class_code,
       fndlookup.meaning     meaning
  FROM XLE_ETB_PROFILES etbp,
       XLE_LOOKUPS fndlookup
  WHERE etbp.party_id = p_party_id
  AND   fndlookup.lookup_code = etbp.etb_information1
  AND NVL(fndlookup.START_DATE_ACTIVE, SYSDATE) <= SYSDATE
  AND NVL(fndlookup.END_DATE_ACTIVE, SYSDATE)  >= SYSDATE
  AND fndlookup.ENABLED_FLAG = 'Y'
  AND fndlookup.LOOKUP_TYPE IN
  (select class_category
     from hz_class_categories)
UNION
  SELECT etbp.etb_information2 sub_activity_code,
       fndlookup.lookup_type class_category,
       fndlookup.lookup_code class_code,
       fndlookup.meaning     meaning
  FROM XLE_ETB_PROFILES etbp,
       XLE_LOOKUPS fndlookup
  WHERE etbp.party_id = p_party_id
  AND   fndlookup.lookup_code = etbp.etb_information2
  AND NVL(fndlookup.START_DATE_ACTIVE, SYSDATE) <= SYSDATE
  AND NVL(fndlookup.END_DATE_ACTIVE, SYSDATE)  >= SYSDATE
  AND fndlookup.ENABLED_FLAG = 'Y'
  AND fndlookup.LOOKUP_TYPE IN
  (select class_category
     from hz_class_categories)
  ;


BEGIN
	-- Standard Start of API savepoint


	l_index := 0;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
        	    	    	    	 	p_api_version,
           	       	    	 			l_api_name,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR parties_r IN parties_c LOOP

       x_partyclass_tbl(l_index).class_category := parties_r.class_category;
       x_partyclass_tbl(l_index).class_code := parties_r.class_code;
       x_partyclass_tbl(l_index).meaning := parties_r.meaning;
       l_index :=l_index + 1;

   END LOOP;

	-- End of API body.

	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       x_msg_data := 'Party ID :' || p_party_id || ' is not associated with a Legal Entity.';
       RAISE FND_API.G_EXC_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  Get_PartyClassification_PID;



PROCEDURE Get_LegalEntity_LGER_BSV
( 	p_api_version           IN	NUMBER				,
  	p_init_msg_list		IN	VARCHAR2,
  	p_commit		IN	VARCHAR2,
  	x_return_status         OUT     NOCOPY  VARCHAR2                ,
  	x_msg_count		OUT	NOCOPY NUMBER				,
	x_msg_data		OUT	NOCOPY VARCHAR2                        ,
	p_ledger_id       IN      NUMBER                          ,
	p_bsv			  IN      VARCHAR2,
	x_legal_entity_id        OUT  NOCOPY   NUMBER,
	x_legal_entity_name      OUT   NOCOPY  VARCHAR2

)
IS
l_api_name			CONSTANT VARCHAR2(30):= 'Get_LegalEntity_LGER_BSV';
l_api_version       CONSTANT NUMBER := 1.0;
l_ledger_id         HR_OPERATING_UNITS.SET_OF_BOOKS_ID%TYPE;
l_le_list           GL_MC_INFO.LE_BSV_TBL_TYPE;
l_legal_entity_id   XLE_ENTITY_PROFILES.legal_entity_id%TYPE;
l_index             NUMBER;
l_ledger_flag       BOOLEAN;
l_country_code      HZ_GEOGRAPHIES.COUNTRY_CODE%TYPE;

l_init_msg_list     VARCHAR2(100);
l_commit            VARCHAR2(100);

l_legal_entity_name XLE_ENTITY_PROFILES.NAME%TYPE;
l_return_var        VARCHAR2(1000);
BEGIN
	-- Standard Start of API savepoint

    l_index := 0;

    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

		SELECT	legal_entity_id,
				legal_entity_name
		  INTO	l_legal_entity_id,
		  		l_legal_entity_name
		  FROM	GL_LEDGER_LE_BSV_SPECIFIC_V
		  WHERE ledger_id = p_ledger_id
		    AND segment_value = p_bsv;


		IF l_legal_entity_id IS NULL OR l_legal_entity_name IS NULL THEN
		   l_return_var := GL_MC_INFO.INIT_LEDGER_LE_BSV_GT(p_ledger_id);

		   SELECT	legal_entity_id,
			  		legal_entity_name
		 	 INTO	l_legal_entity_id,
		  			l_legal_entity_name
 		 	  FROM	GL_LEDGER_LE_BSV_GT
			 WHERE  ledger_id = p_ledger_id
		  	   AND  bal_seg_value = p_bsv;

		  	IF l_legal_entity_id IS NULL OR l_legal_entity_name IS NULL THEN
			    x_legal_entity_id := null;
	     	    x_legal_entity_name := null;
	     	    return;

			ELSE
		 		x_legal_entity_id := l_legal_entity_id;
				x_legal_entity_name := l_legal_entity_name;
			END IF;

		ELSE
		  x_legal_entity_id := l_legal_entity_id;
		  x_legal_entity_name := l_legal_entity_name;
		END IF;



	-- End of API body.
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        	        p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);
END  Get_LegalEntity_LGER_BSV;

PROCEDURE Get_LE_Interface(
		   x_return_status		OUT NOCOPY  VARCHAR2,
		   x_msg_count			OUT NOCOPY NUMBER,
		   x_msg_data			OUT NOCOPY VARCHAR2,
		   P_INTERFACE_ATTRIBUTE    	IN  VARCHAR2,
		   P_INTERFACE_VALUE		IN  VARCHAR2,
		   X_LEGAL_ENTITY_ID   OUT NOCOPY XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE
) IS


/* Local Variable */

l_api_name	CONSTANT VARCHAR2(30) := 'Get_LE_Interface';
l_api_version   CONSTANT NUMBER:= 1.0;

l_cnt NUMBER := 0;
l_return_status VARCHAR2(50);
l_msg_data VARCHAR2(50);
l_ou_le_info XLE_BUSINESSINFO_GRP.OU_LE_Tbl_Type;
l_Ledger_info XLE_BUSINESSINFO_GRP.LE_Ledger_Rec_Type;
l_Inv_Le_info XLE_BUSINESSINFO_GRP.Inv_Org_Rec_Type;


BEGIN

/* If Company Name is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'COMPANY_NAME' THEN
    select count(legal_entity_id) into l_cnt from xle_entity_profiles
    where name = P_INTERFACE_VALUE;

    IF l_cnt = 0 THEN
       select count(legal_entity_id) into l_cnt
       from XLE_ETB_PROFILES
       where name = P_INTERFACE_VALUE;

	IF l_cnt = 0 THEN
  	   select etb.legal_entity_id into x_legal_entity_id
	   from XLE_ETB_PROFILES etb, HZ_PARTIES parties
	   where parties.party_name = P_INTERFACE_VALUE
	   and parties.party_id = etb.party_id;
        ELSE
           select legal_entity_id into x_legal_entity_id
           from XLE_ETB_PROFILES
	   where name = P_INTERFACE_VALUE;
        END IF;

    ELSE
        select legal_entity_id into x_legal_entity_id
        from XLE_ENTITY_PROFILES
        where name = P_INTERFACE_VALUE;
    END IF;

END IF;

/* If Legislative Category Code is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'LEGISLATIVE_CAT' THEN

    select ent.LEGAL_ENTITY_ID into x_legal_entity_id
    from XLE_ENTITY_PROFILES  ent, XLE_JURISDICTIONS_B jur, XLE_REGISTRATIONS reg
    where jur.LEGISLATIVE_CAT_CODE = P_INTERFACE_VALUE
    and jur.JURISDICTION_ID = reg.JURISDICTION_ID
    and reg.SOURCE_ID = ent.LEGAL_ENTITY_ID;

END IF;


/* If Registration Number is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'REGISTRATION_NUM' THEN

/* Check if the Registration Number belongs to Legal Entity or an Establishment */

    select count(ent.legal_entity_id) into l_cnt from
    XLE_ENTITY_PROFILES ent, XLE_REGISTRATIONS reg
    where reg.REGISTRATION_NUMBER = P_INTERFACE_VALUE
    and reg.SOURCE_ID = ent.LEGAL_ENTITY_ID;

    IF l_cnt = 0 THEN
       select etb.legal_entity_id into x_legal_entity_id
       from XLE_ETB_PROFILES etb, XLE_REGISTRATIONS reg
       where reg.REGISTRATION_NUMBER = P_INTERFACE_VALUE
       and reg.SOURCE_ID = etb.ESTABLISHMENT_ID;
    ELSE
       select ent.legal_entity_id into x_legal_entity_id from
       XLE_ENTITY_PROFILES ent,XLE_REGISTRATIONS reg
       where reg.REGISTRATION_NUMBER = P_INTERFACE_VALUE
       and reg.SOURCE_ID = ent.LEGAL_ENTITY_ID;
    END IF;

END IF;

/* If Geography ID is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'GEOGRAPHY_ID' THEN

    select ent.LEGAL_ENTITY_ID into x_legal_entity_id
    from XLE_ENTITY_PROFILES  ent, XLE_JURISDICTIONS_B jur, XLE_REGISTRATIONS reg
    where jur.GEOGRAPHY_ID = TO_NUMBER(P_INTERFACE_VALUE)
    and jur.JURISDICTION_ID = reg.JURISDICTION_ID
    and reg.SOURCE_ID = ent.LEGAL_ENTITY_ID;

END IF;

/* If Location ID is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'LOCATION_ID' THEN

/* Check if the Registration Number belongs to Legal Entity or an Establishment */
    select count(ent.legal_entity_id) into l_cnt
    from XLE_ENTITY_PROFILES ent, XLE_REGISTRATIONS reg
    where reg.LOCATION_ID = TO_NUMBER(P_INTERFACE_VALUE)
    and reg.SOURCE_ID = ent.LEGAL_ENTITY_ID;

    IF l_cnt = 0 THEN
       select etb.legal_entity_id into x_legal_entity_id
       from XLE_ETB_PROFILES etb, XLE_REGISTRATIONS reg
       where reg.LOCATION_ID = TO_NUMBER(P_INTERFACE_VALUE)
       and reg.SOURCE_ID = etb.ESTABLISHMENT_ID;
    ELSE
       select ent.legal_entity_id into x_legal_entity_id from
       XLE_ENTITY_PROFILES ent, XLE_REGISTRATIONS reg
       where reg.LOCATION_ID = TO_NUMBER(P_INTERFACE_VALUE)
       and reg.SOURCE_ID = ent.LEGAL_ENTITY_ID;
    END IF;
END IF;

/* If OPERATING UNIT ID is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'OPERATING_UNIT_ID' THEN
   XLE_BUSINESSINFO_GRP.Get_OperatingUnit_Info(
                                               x_return_status => l_return_status,
					       x_msg_data => l_msg_data,
					       p_operating_unit => TO_NUMBER(P_INTERFACE_VALUE),
					       p_legal_entity_id => NULL,
					       p_party_id => NULL,
					       x_ou_le_info => l_ou_le_info);

   x_legal_entity_id := l_ou_le_info(1).legal_entity_id;

END IF;

/* If LEDGER ID is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'LEDGER_ID' THEN
    XLE_BUSINESSINFO_GRP.Get_Ledger_Info(
                                         x_return_status => l_return_status,
					 x_msg_data => l_msg_data,
					 P_Ledger_ID => TO_NUMBER(P_INTERFACE_VALUE),
					 x_Ledger_info => l_Ledger_info);

   x_legal_entity_id := l_ledger_info(1).legal_entity_id;

END IF;

/* If INVENTORY ORG ID is passed by the interface */

IF P_INTERFACE_ATTRIBUTE = 'INVENTORY_ORG_ID' THEN
   XLE_BUSINESSINFO_GRP.Get_InvOrg_Info(
                                        x_return_status => l_return_status,
  				        x_msg_data => l_msg_data,
					P_InvOrg_ID => TO_NUMBER(P_INTERFACE_VALUE),
                                        P_Le_ID => NULL,
					P_Party_ID => NULL,
					x_Inv_Le_info => l_Inv_Le_info);

    x_legal_entity_id := l_Inv_Le_info(1).legal_entity_id;

END IF;


EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        x_msg_data := 'No data found for the given parameters.';

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 x_msg_data := 'No data found for the given parameters';

END Get_LE_Interface;

Procedure Get_FP_VATRegistration_LEID
   (
    p_api_version           IN	NUMBER,
  	p_init_msg_list	     	IN	VARCHAR2,
  	p_commit		        IN	VARCHAR2,
  	p_effective_date        IN  zx_registrations.effective_from%Type,
  	x_return_status         OUT NOCOPY  VARCHAR2,
  	x_msg_count		        OUT	NOCOPY NUMBER,
	x_msg_data		        OUT	NOCOPY VARCHAR2,
	p_legal_entity_id       IN  NUMBER,
	x_registration_number   OUT NOCOPY  VARCHAR2
   )
   IS

   l_api_name			CONSTANT VARCHAR2(30):= 'Get_FP_VATRegistration_LEID';
   l_api_version        CONSTANT NUMBER := 1.0;
   l_commit             VARCHAR2(100);
   l_init_msg_list     VARCHAR2(100);

   x_me_party_id NUMBER;
   l_me_party_id NUMBER;

   l_vat_registration VARCHAR2(1000);

  BEGIN

    -- Standard Start of API savepoint


    IF p_init_msg_list IS NULL THEN
      l_init_msg_list := FND_API.G_FALSE;
    ELSE
	  l_init_msg_list := p_init_msg_list;
    END IF;


    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.

	IF FND_API.to_Boolean( l_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

	   Get_ME_PARTYID_LEID(
                               1.0,
			       'F',
                               'F',
      	                       x_return_status,
  	                           x_msg_count,
	                           x_msg_data,
                               p_legal_entity_id,
                               x_me_party_id
                          );

	   l_me_party_id := x_me_party_id;

	   /*  x_registration_number := ZX_TCM_CONTROL_PKG.Get_Default_Tax_Reg (
			   							l_me_party_id,
 								        'LEGAL_ESTABLISHMENT',
									    p_effective_date,
                                        p_init_msg_list,
								    	x_return_status,
							            x_msg_count,
									    x_msg_data
       ); */

   x_registration_number := ZX_API_PUB.get_default_tax_reg
                                (
                            p_api_version  => 1.0 ,
                            p_init_msg_list => NULL,
                            p_commit=> NULL,
                            p_validation_level => NULL,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data  => x_msg_data,
                            p_party_id => l_me_party_id,
                            p_party_type => 'LEGAL_ESTABLISHMENT',
                            p_effective_date =>p_effective_date );

	-- End of API body.
	-- Standard call to get message count and if count is 1, get message info.
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    	);


EXCEPTION
	WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	    x_msg_data := SQLERRM;
END;


function Get_DefaultLegalContext_OU(
   	p_operating_unit        IN  NUMBER  )
RETURN NUMBER IS
DLC_VAL             NUMBER;
BEGIN

    -- For Bug 4616389
    -- SAVEPOINT	Get_DefaultLegalContext_OU;

    SELECT NVL(O3.ORG_INFORMATION2,-1)
      INTO DLC_VAL
      FROM HR_ALL_ORGANIZATION_UNITS O
         , HR_ORGANIZATION_INFORMATION O2
         , HR_ORGANIZATION_INFORMATION O3
      WHERE O.ORGANIZATION_ID = O2.ORGANIZATION_ID
      AND   O.ORGANIZATION_ID = O3.ORGANIZATION_ID
      AND   O2.ORG_INFORMATION_CONTEXT||'' = 'CLASS'
      AND   O3.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
      AND   O2.ORG_INFORMATION1 = 'OPERATING_UNIT'
      AND   O2.ORG_INFORMATION2 = 'Y'
      AND   O.ORGANIZATION_ID = P_OPERATING_UNIT;



    RETURN DLC_VAL;

EXCEPTION

        WHEN TOO_MANY_ROWS THEN
	  -- For Bug 4616389
          -- ROLLBACK TO Get_DefaultLegalContext_OU;
            return -1;

        WHEN FND_API.G_EXC_ERROR THEN
	  --  ROLLBACK TO Get_DefaultLegalContext_OU;
            return -1;

    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          -- ROLLBACK TO Get_DefaultLegalContext_OU;
    		return -1;
    	WHEN OTHERS THEN
    	  -- ROLLBACK TO Get_DefaultLegalContext_OU;
            return -1;
END Get_DefaultLegalContext_OU;


function Get_DLC_LE_OU RETURN VARCHAR2 IS
l_legal_entity_id               NUMBER;
l_legal_entity_name             VARCHAR2(1000);
l_le_count                      NUMBER := 0;
BEGIN


    SELECT COUNT(*)
      INTO l_le_count
      FROM XLE_FP_OU_LEDGER_V
      where OPERATING_UNIT_ID  = nvl(fnd_profile.value_wnps('ORG_ID'),-99);

    IF (l_le_count = 1) THEN
      SELECT legal_entity_name
        INTO l_legal_entity_name
        FROM XLE_FP_OU_LEDGER_V
        WHERE OPERATING_UNIT_ID  = nvl(fnd_profile.value_wnps('ORG_ID'),-99);
    ELSE
      BEGIN
          SELECT NAME
            INTO l_legal_entity_name
            FROM XLE_FIRSTPARTY_INFORMATION_V
            WHERE LEGAL_ENTITY_ID = Get_DefaultLegalContext_OU(fnd_profile.value_wnps('ORG_ID'));
      EXCEPTION
        WHEN OTHERS THEN
         RETURN NULL;
      END;
    END IF;

    RETURN l_legal_entity_name;

EXCEPTION

        WHEN TOO_MANY_ROWS THEN
             return null;

        WHEN FND_API.G_EXC_ERROR THEN
	              return null;

    	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       		return null;
    	WHEN OTHERS THEN
               return null;
END Get_DLC_LE_OU;

PROCEDURE IsLegalEntity_LEID(
      	x_return_status     OUT NOCOPY  VARCHAR2,
    	x_msg_data	    OUT	NOCOPY VARCHAR2,
        p_legal_entity_id   IN  NUMBER,
        x_legal_entity      OUT NOCOPY VARCHAR2

  )
IS
l_le_flag varchar2(1);

BEGIN


	--  Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API body

    if p_legal_entity_id IS NULL then

       x_msg_data := 'Missing Mandatory parameters. Please provide Legal Entity Id';
       x_return_status := FND_API.G_RET_STS_ERROR;
        return;
    end if;

        l_le_flag := 'N';

      BEGIN
        SELECT 'Y'
          INTO l_le_flag
          FROM XLE_ENTITY_PROFILES
         WHERE legal_entity_id = p_legal_entity_id
           AND ( effective_to >= sysdate OR effective_to is null);
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_le_flag := 'N';
     END;

        IF l_le_flag  = 'Y' THEN
           x_legal_entity := FND_API.G_TRUE;
        ELSE
           x_legal_entity := FND_API.G_FALSE;
        END IF;


	-- End of API body.


EXCEPTION


    WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := FND_API.G_RET_STS_ERROR ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END  IsLegalEntity_LEID;


PROCEDURE Check_IC_Invoice_required(
        x_return_status     OUT NOCOPY  VARCHAR2,
        x_msg_data          OUT NOCOPY VARCHAR2,
        p_legal_entity_id   IN  NUMBER,
        p_party_id          IN  NUMBER,
        x_intercompany_inv  OUT NOCOPY VARCHAR2)
IS
l_ic_inv varchar2(1);
l_count number;

BEGIN


    --  Initialize API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- API body

    if (p_legal_entity_id IS NULL AND p_party_id IS NULL) then

       x_msg_data := 'Missing Mandatory parameters. Please provide either the Legal Entity Id or Party Id';
       x_return_status := FND_API.G_RET_STS_ERROR;
        return;
    end if;

    l_ic_inv := 'N';

    if p_legal_entity_id IS NOT NULL then
       BEGIN

        SELECT
             count(reg_func.function_code)
         INTO l_count
         FROM
            xle_reg_functions reg_func,
            xle_registrations reg,
            xle_lookups lkp
        WHERE
            lkp.lookup_type = 'XLE_LE_FUNCTION'
        AND lkp.lookup_code = reg_func.function_code
        AND lkp.lookup_code = 'ICINV'
        AND reg.source_id = p_legal_entity_id
        AND reg.source_table = 'XLE_ENTITY_PROFILES'
        AND reg.registration_id = reg_func.registration_id;

        if l_count >= 1 then
            l_ic_inv := 'Y';
        end if;


      EXCEPTION
       WHEN OTHERS THEN
         l_ic_inv := 'N';
       END;
     end if;

    if (p_party_id IS NOT NULL AND l_ic_inv = 'N') then
      BEGIN
           SELECT
                 count(reg_func.function_code)
             INTO l_count
             FROM
                xle_reg_functions reg_func,
                xle_registrations reg,
                xle_lookups lkp ,
                xle_entity_profiles ent_prof
            WHERE
                lkp.lookup_type = 'XLE_LE_FUNCTION'
            AND lkp.lookup_code = reg_func.function_code
            AND lkp.lookup_code = 'ICINV'
            AND reg.registration_id = reg_func.registration_id
            AND reg.source_id = ent_prof.legal_entity_id
            AND reg.source_table = 'XLE_ENTITY_PROFILES'
            AND ent_prof.party_id = p_party_id;

            if l_count >= 1 then
              l_ic_inv := 'Y';
            end if;

     EXCEPTION
        WHEN OTHERS THEN
          l_ic_inv := 'N';

      END;
    end if;

        if l_ic_inv  = 'Y' THEN
           x_intercompany_inv := FND_API.G_TRUE;
        else
           x_intercompany_inv := FND_API.G_FALSE;
        end if;
   -- End of API body.


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Check_IC_Invoice_required;
END  XLE_UTILITIES_GRP;

/
