--------------------------------------------------------
--  DDL for Package Body XLE_BUSINESSINFO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_BUSINESSINFO_GRP" AS
/* $Header: xlegbuib.pls 120.34.12010000.4 2009/08/12 11:40:05 srampure ship $ */



PROCEDURE Get_BusinessGroup_Info(
	x_return_status         OUT NOCOPY  VARCHAR2,
  	x_msg_count		OUT NOCOPY  NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
        P_LegalEntity_ID  	IN XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE,
        P_party_id		IN XLE_ENTITY_PROFILES.party_id%TYPE,
        p_businessgroup_id	IN hr_operating_units.business_group_id%type,
        x_businessgroup_info	OUT NOCOPY BG_LE_Tbl_Type
    )
    IS


l_index 		number := 1;
l_legal_entity_id 	number;
l_party_id 		number;
l_business_group_id 	number;

l_row_count 		NUMBER := 0;


/* The following cursor selects legal entity information related to a
   business group*/
cursor business_c is
  select xlep.legal_entity_id,
  	 xlep.party_id
    from hr_legal_entities hrle,
         xle_entity_profiles xlep
    where business_group_id = l_business_group_id
      and xlep.legal_entity_id = hrle.organization_id;

BEGIN
  l_legal_entity_id := p_legalentity_id;


  /* Missing mandatory parameters.
     Business Group ID/ (Legal Entity ID or party ID) is mandatory */

     IF p_party_ID is null and
        p_legalentity_ID is null and p_businessgroup_id is null then
		x_msg_data := 'Missing Mandatory Parameters.';
   	    return;
     End if;


  /* Either Business Group information or Legal Entity Information has to be
     passed.  Information about both is not accepted. */

     IF p_businessgroup_id is not null and
       (p_party_ID is not null OR p_legalentity_ID is not null) then
	x_msg_data := 'Enter just one of the listed parameters:
	 Business Group ID, Legal Entity ID or Party ID of the Legal Entity. ';
   	    return;

     End if;

  /* Check for Valid combination of Legal Entity ID and Party ID */

     IF p_party_ID is not null then

	/* If Legal Entity ID is also passed, check if the party ID and the
           Legal Entity ID match.  Else return with error message; */
	 BEGIN
		select legal_entity_id
		  into l_legal_entity_id
		  from xle_entity_profiles
		  where party_id = p_party_id;

	 EXCEPTION
	   	  when no_data_found then
	   	    x_msg_data := 'Invalid Party ID : ' || p_party_id;
	   	    return;
	   END;

	if p_legalEntity_ID is not null then
	   if p_legalEntity_ID <> l_legal_entity_id then
	      x_msg_data := 'Invalid Legal Entity ID and Party ID combination.';
	      return;
	   end if;
	 end if;

    End if;

    If l_legal_entity_id is not null then

	BEGIN
		select party_id
		  into l_party_id
		  from xle_entity_profiles
		  where legal_entity_id = l_legal_entity_id;

	EXCEPTION
	     when no_data_found then
	       x_msg_data := 'Invalid Legal Entity ID : ' || l_legal_entity_id;
	       return;
	END;

	 if p_party_ID is not null then
	    if p_party_ID <> l_party_id then
	  	x_msg_data := 'Legal Entity ID and Party ID do not match.';
	        return;
	    end if;

	end if;

   /* Select business group information into placeholder variables
              for the given Legal Entity information */
   BEGIN
	select business_group_id
	  into l_business_group_id
	  from hr_legal_entities
	  where organization_id = l_legal_entity_id;

   EXCEPTION
     when no_data_found then
     x_msg_data := 'Invalid Legal Entity : Not associated to a Business Group.';
   	    return;
   END;

   /*  Populate the output table with the Business group and Legal Entity
       information */

	x_businessgroup_info(1).legal_entity_id := l_legal_entity_id;
	x_businessgroup_info(1).party_id := l_party_id;
	x_businessgroup_info(1).business_group_id := l_business_group_id;

   else

	/* If business group information is passed, invoke the cursor
           business_c to obtain  Legal Entity information associated with the
	   Business Group */

	l_business_group_id := p_businessgroup_id;

	for business_r in business_c loop

	  /*  Populate the output table with the Business group and Legal
              Entity information */

	  l_row_count := l_row_count + 1;

	  x_businessgroup_info(l_index).legal_entity_id := business_r.legal_entity_id;
	  x_businessgroup_info(l_index).party_id := business_r.party_id;
	  x_businessgroup_info(l_index).business_group_id := l_business_group_id;

		  l_index := l_index + 1;
	end loop;



  if l_row_count = 0 then
	      x_msg_data := 'Invalid legal entity ID.';
          x_return_status :='S';
          else
          x_return_status :='E';
            end if;


    end if;

END Get_BusinessGroup_Info;


PROCEDURE Get_Ledger_Info(
                      x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_data    OUT  NOCOPY VARCHAR2,
                      P_Ledger_ID    IN NUMBER,
                      x_Ledger_info OUT NOCOPY LE_Ledger_Rec_Type
    )
IS

l_party_id number;
l_le_flag boolean := false;
l_le_exists_flag boolean := false;
l_legal_entity_id number;

l_ledger_flag boolean := false;
l_bsv_flag boolean := false;
l_bsv_return_flag boolean := false;


x_allow_all_bsv_flag varchar2(1);

l_index number := 1;

x_bsv_list gl_mc_info.le_bsv_tbl_type := gl_mc_info.le_bsv_tbl_type();
x_le_list gl_mc_info.le_bsv_tbl_type := gl_mc_info.le_bsv_tbl_type();

l_legalentity_info       XLE_UTILITIES_GRP.LegalEntity_Rec;
l_msg_data				  VARCHAR2(1000);
l_msg_count					number;
l_return_status				 varchar2(10);

BEGIN

    /* Ledger ID is mandatory information */

    if P_Ledger_ID is null then
    	x_msg_data := 'Please pass a value for Ledger ID.';
    	x_return_status := 'E';
		return;
    end if;

     l_le_flag := gl_mc_info.get_legal_entities(
			   p_ledger_id,x_le_list);


			  if x_le_list.count > 0 then
   		   		for i in x_le_list.first..x_le_list.last loop

				x_bsv_list := gl_mc_info.le_bsv_tbl_type();
   		   		/* Invoke GL API get_legal_entities to get the legal entities
					  associated with the given ledger. The output legal entities are returned in x_le_list.*/

   		   			l_bsv_flag := gl_mc_info.get_bal_seg_values(
							p_ledger_id,
						    x_le_list(i).legal_entity_id,
						    null,
						    x_allow_all_bsv_flag,
						    x_bsv_list);


				  if x_bsv_list.count > 0 then

				  /* The following loop loops through the balancing segment values associated
				  with the legal entities in x_le_list */
					for j in x_bsv_list.first..x_bsv_list.last loop


						x_Ledger_info(l_index).legal_entity_id := x_le_list(i).legal_entity_id;


						x_ledger_info(l_index).ledger_id := p_ledger_id;
						x_ledger_info(l_index).bal_seg_value := x_bsv_list(j).bal_seg_value;



						xle_utilities_grp.get_legalentity_info(
      							x_return_status => l_return_status,
            						x_msg_count => l_msg_count,
            						x_msg_data => l_msg_data,
            						p_party_id => null,
            						p_legalentity_id => x_le_list(i).legal_entity_id,
            						x_legalentity_info => l_legalentity_info);


						/* Populate the output table with the Ledger, BSV information */

						x_Ledger_info(l_index).party_id := l_legalentity_info.party_id;
						x_Ledger_info(l_index).name := l_legalentity_info.name;
						x_Ledger_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_Ledger_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_Ledger_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_Ledger_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_Ledger_info(l_index).type_of_company := l_legalentity_info.type_of_company;
						x_Ledger_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_Ledger_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_Ledger_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_Ledger_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_Ledger_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_Ledger_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_Ledger_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_Ledger_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_Ledger_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_Ledger_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_Ledger_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
						x_Ledger_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
						x_Ledger_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
						x_Ledger_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_Ledger_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;

			   			   l_index := l_index + 1;

					end loop;

					else


		    			x_Ledger_info(l_index).legal_entity_id := x_le_list(i).legal_entity_id;

		    			/* Invoke XLE API Get_LegalEntity_Info to retrieve legale entity information */

						xle_utilities_grp.get_legalentity_info(
      							x_return_status => l_return_status,
            						x_msg_count => l_msg_count,
            						x_msg_data => l_msg_data,
            						p_party_id => null,
            						p_legalentity_id => x_le_list(i).legal_entity_id,
            						x_legalentity_info => l_legalentity_info);



						x_Ledger_info(l_index).party_id := l_legalentity_info.party_id;
						x_Ledger_info(l_index).name := l_legalentity_info.name;
						x_Ledger_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_Ledger_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_Ledger_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_Ledger_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_Ledger_info(l_index).type_of_company := l_legalentity_info.type_of_company;
						x_Ledger_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_Ledger_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_Ledger_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_Ledger_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_Ledger_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_Ledger_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_Ledger_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_Ledger_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_Ledger_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_Ledger_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_Ledger_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
						x_Ledger_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
						x_Ledger_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
						x_Ledger_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_Ledger_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;


		    				    x_ledger_info(l_index).ledger_id := p_ledger_id;

						    x_msg_data := 'The Legal Entity: ' || x_le_list(i).legal_entity_id || ' is not associated with a BSV.';

		    				l_index := l_index + 1;
		    				return;
					end if;


   		   		end loop;
   		   	else
   		   			x_msg_data := 'Either the Ledger ID is invalid or the Ledger is not associated with any Legal Entities.';

  			end if;


END Get_Ledger_Info;


PROCEDURE Get_Ledger_Info(
                      x_return_status         OUT NOCOPY VARCHAR2,
                      x_msg_data    OUT NOCOPY VARCHAR2,
                      P_Ledger_ID    IN NUMBER,
                      P_BSV    IN Varchar2,
                      x_Ledger_info OUT NOCOPY LE_Ledger_Rec_Type
    ) IS
l_party_id number;
l_le_flag boolean := false;
l_le_return_flag boolean := false;

l_index number := 1;


l_legalentity_info       XLE_UTILITIES_GRP.LegalEntity_Rec;
l_msg_data				  VARCHAR2(1000);
l_msg_count					number;
l_return_status				 varchar2(10);

x_le_list gl_mc_info.le_bsv_tbl_type := gl_mc_info.le_bsv_tbl_type();
BEGIN


/* Parameters Ledger ID and BSV are mandatory */

	IF p_ledger_id is null OR P_BSV is null then
		x_msg_data := 'Please pass values for Ledger ID and BSV.';
		return;
	end if;



/* Invoke the GL API get_legal_entities to retrieve the legal entities associated with the
Ledger and BSV combination. The legal entity is returned in x_le_list*/

	l_le_flag := gl_mc_info.get_legal_entities(
			   p_ledger_id,P_BSV,null,x_le_list);


		if x_le_list.count > 0 then

		/* The following loop loops through the list of legal entities returned in previous step */
		  for k in x_le_list.first..x_le_list.last loop

			l_le_return_flag := true;




			x_Ledger_info(l_index).legal_entity_id := x_le_list(k).legal_entity_id;
			x_ledger_info(l_index).ledger_id := p_ledger_id;
			x_ledger_info(l_index).bal_seg_value := P_BSV;

/* Invoke XLE API Get_LegalEntity_Info to retrieve legale entity information */
			xle_utilities_grp.get_legalentity_info(
      							x_return_status => l_return_status,
            						x_msg_count => l_msg_count,
            						x_msg_data => l_msg_data,
            						p_party_id => null,
            						p_legalentity_id => x_le_list(k).legal_entity_id,
            						x_legalentity_info => l_legalentity_info);


					/* Assign ledeger and legal entity information to output table */

						x_Ledger_info(l_index).party_id := l_legalentity_info.party_id;
						x_Ledger_info(l_index).name := l_legalentity_info.name;
						x_Ledger_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_Ledger_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_Ledger_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_Ledger_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_Ledger_info(l_index).type_of_company := l_legalentity_info.type_of_company;
						x_Ledger_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_Ledger_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_Ledger_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_Ledger_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_Ledger_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_Ledger_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_Ledger_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_Ledger_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_Ledger_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_Ledger_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_Ledger_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
						x_Ledger_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
						x_Ledger_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
						x_Ledger_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_Ledger_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;



			l_index := l_index + 1;
		  end loop;
		else

		  	x_msg_data := 'The Ledger ID and BSV are not associated with any Legal Entities';
		  	return;
		end if;
END Get_Ledger_Info;



/*
PROCEDURE Get_Ledger_Info(
                      x_return_status         OUT VARCHAR2,
                      x_msg_data    OUT  VARCHAR2,
                      p_party_id    IN NUMBER,
                      p_LegalEntity_ID IN Number,
                      x_Ledger_info OUT LE_Ledger_Rec_Type
    )IS

l_legal_entity_id number;
l_party_id number;

l_ledger_flag boolean := false;
l_ledger_return_flag boolean := false;
l_bsv_flag boolean := false;
l_bsv_return_flag boolean := false;


x_allow_all_bsv_flag varchar2(1) := 'N';

l_index number := 1;

x_ledger_list gl_mc_info.ledger_tbl_type := gl_mc_info.ledger_tbl_type();
x_bsv_list gl_mc_info.le_bsv_tbl_type := gl_mc_info.le_bsv_tbl_type();



BEGIN

		l_legal_entity_id := 		p_LegalEntity_ID;

		if p_legalEntity_ID is not null then


   			begin
		   	select party_id
  	 		  into l_party_id
   			  from xle_entity_profiles
   			  where legal_entity_id = p_LegalEntity_ID;
   		   exception
				when no_data_found then
				  x_msg_data := 'Legal Entity ID is invalid';
				  return;
			end;

			if p_party_ID is not null then
			  if p_party_ID <> l_party_id then
			  	x_msg_data := 'Legal Entity ID and Party ID do not match.';
				  return;
			end if;
		   end if;
   		elsif p_party_ID is not null then

   		  BEGIN
   			select legal_entity_id
   			  into l_legal_entity_id
   			  from xle_entity_profiles
   			  where party_id = p_party_id;

 			 exception
				when no_data_found then
				  x_msg_data := 'Party ID is invalid';
				  return;
			end;

			if p_legalEntity_ID is not null then
			  if p_legalEntity_ID <> l_legal_entity_id then
			  	x_msg_data := 'Legal Entity ID and Party ID do not match.';
				  return;
			  end if;
			end if;
		end if;



		l_ledger_flag := gl_mc_info.get_le_ledgers(
			 		p_LegalEntity_ID,
					'Y',
					'Y',
					null,
					x_ledger_list);



		for i in x_ledger_list.first..x_ledger_list.last loop

			l_ledger_return_flag := true;

		   l_bsv_flag := gl_mc_info.get_bal_seg_values(
		   						x_ledger_list(i).ledger_id,
								p_LegalEntity_ID,
								null,
								x_allow_all_bsv_flag,
								x_bsv_list);



 			for j in x_bsv_list.first..x_bsv_list.last loop
 			   l_bsv_return_flag := true;

			   x_Ledger_info(l_index).legal_entity_id := l_legal_entity_id;

			   x_ledger_info(l_index).ledger_id := x_ledger_list(i).ledger_id;
			   x_ledger_info(l_index).bal_seg_value := x_bsv_list(j).bal_seg_value;


			   xle_utilities_grp.get_legalentity_info(
      							x_return_status => l_return_status,
            						x_msg_count => l_msg_count,
            						x_msg_data => l_msg_data,
            						p_party_id => null,
            						p_legalentity_id => x_le_list(i).legal_entity_id,
            						x_legalentity_info => l_legalentity_info);



						x_Ledger_info(l_index).party_id := l_legalentity_info.party_id;
						x_Ledger_info(l_index).name := l_legalentity_info.name;
						x_Ledger_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_Ledger_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_Ledger_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_Ledger_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_Ledger_info(l_index).type_of_company := l_legalentity_info.type_of_company;
						x_Ledger_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_Ledger_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_Ledger_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_Ledger_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_Ledger_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_Ledger_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_Ledger_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_Ledger_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_Ledger_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_Ledger_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_Ledger_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
						x_Ledger_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
						x_Ledger_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
						x_Ledger_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_Ledger_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;



			   l_index := l_index + 1;

			end loop;

			if l_bsv_return_flag = false then
		    	x_Ledger_info(l_index).legal_entity_id := l_legal_entity_id;
			    x_Ledger_info(l_index).party_id := l_party_id;
			    x_ledger_info(l_index).ledger_id := x_ledger_list(i).ledger_id;

		    	l_index := l_index + 1;
		    	return;
		    end if;



		end loop;

		if l_ledger_return_flag = false then
			x_msg_data := 'Either the Legal Entity ID is invalid or it is not associated with a Ledger.';
			return;
		end if;



END Get_Ledger_Info;
*/


PROCEDURE Get_OperatingUnit_Info(
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_msg_data    	  OUT NOCOPY VARCHAR2,
                      p_operating_unit    IN NUMBER,
                      p_legal_entity_id   IN NUMBER,
                      p_party_id	  IN NUMBER,
                      x_ou_le_info        OUT NOCOPY OU_LE_Tbl_Type
    )
IS

l_le_rowcount_flag 	boolean := false;
l_ou_rowcount_flag 	boolean := false;
l_ledger_flag 		boolean;
l_le_flag 		boolean;
l_ledger_id 		gl_ledgers.ledger_id%type;
l_str_ledger_id 	varchar2(150);
l_return_status 	varchar2(1);
l_msg_data 		varchar2(1000);

x_ledger_info 	XLE_BUSINESSINFO_GRP.LE_Ledger_Rec_Type;
x_ledger_list 	GL_MC_INFO.ledger_tbl_type := GL_MC_INFO.ledger_tbl_type();
x_le_list 	gl_mc_info.le_bsv_tbl_type := gl_mc_info.le_bsv_tbl_type();

l_index 		number:= 1;
l_legal_entity_id 	number;
l_legalentity_info      XLE_UTILITIES_GRP.LegalEntity_Rec;
l_msg_count		number;


/* The following cursor selects operating unit information associated
   with a Ledger */

cursor OperUnit_c is
 SELECT o.organization_id operating_unit_id
   FROM hr_all_organization_units o,
        hr_organization_information o2,
        hr_organization_information o3
  WHERE o.organization_id = o2.organization_id
    AND o.organization_id = o3.organization_id
    AND o2.org_information_context || '' = 'CLASS'
    AND o3.org_information_context = 'Operating Unit Information'
    AND o2.org_information1 = 'OPERATING_UNIT'
    AND o2.org_information2 = 'Y'
    AND o3.org_information3 = l_str_ledger_id;

BEGIN
  l_legal_entity_id := p_legal_entity_id;

  IF p_operating_unit is null and p_legal_entity_id is null and
     p_party_id is null then
	x_msg_data := 'Missing Mandatory Parameters.';
        return;
  End if;

  IF p_operating_unit is not null and
    (p_party_ID is not null OR p_legal_entity_id is not null) then
	x_msg_data := 'Enter just one of the listed parameters: Operating Unit
                       ID, Legal Entity ID or Party ID of the Legal Entity.';
	return;
  End if;


/* If operating unit information is passed then the following if statement
   retrieves the legal entity information associated with the Operating unit
   through its ledger */

  IF p_operating_unit is not null then

  /* Select ledger associated with the Operating unit*/

    SELECT   DISTINCT o3.org_information3
      INTO   l_ledger_id
 FROM hr_all_organization_units o,
      hr_organization_information o2,
      hr_organization_information o3
WHERE o.organization_id = o2.organization_id
 AND o.organization_id = o3.organization_id
 AND o3.organization_id = o2.organization_id
 AND o2.org_information_context || '' = 'CLASS'
 AND o3.org_information_context = 'Operating Unit Information'
 AND o2.org_information1 = 'OPERATING_UNIT'
 AND o2.org_information2 = 'Y'
 AND o.organization_id = p_operating_unit;

  /* The following API call retrieves legal entities associated with the ledger
     identified in previous step */
	l_le_flag := gl_mc_info.get_legal_entities(
			   l_ledger_id,x_le_list);

  /* The following statement loops through the legal entities and
     populates the output table */
        if x_le_list.count > 0 then
	for i in  x_le_list.first..x_le_list.last loop
		l_ou_rowcount_flag := true;

		x_ou_le_info(l_index).Operating_Unit_ID := p_operating_unit;
		x_ou_le_info(l_index).LEGAL_ENTITY_ID := x_le_list(i).legal_entity_id;

		/* Invoke XLE API Get_LegalEntity_Info to retrieve legal entity
                   information */

		xle_utilities_grp.get_legalentity_info(
      			x_return_status => l_return_status,
            		x_msg_count => l_msg_count,
            		x_msg_data => l_msg_data,
            		p_party_id => null,
            		p_legalentity_id => x_le_list(i).legal_entity_id,
            		x_legalentity_info => l_legalentity_info);


	x_ou_le_info(l_index).party_id := l_legalentity_info.party_id;
	x_ou_le_info(l_index).name := l_legalentity_info.name;
	x_ou_le_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
	x_ou_le_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
	x_ou_le_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
	x_ou_le_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
	x_ou_le_info(l_index).type_of_company := l_legalentity_info.type_of_company;
	x_ou_le_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
	x_ou_le_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
	x_ou_le_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
	x_ou_le_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
	x_ou_le_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
	x_ou_le_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
	x_ou_le_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
	x_ou_le_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
        x_ou_le_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
	x_ou_le_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
	x_ou_le_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
	x_ou_le_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
	x_ou_le_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
	x_ou_le_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
	x_ou_le_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;
	l_index := l_index + 1; -- bug: 7633921
	end loop;
        end if;

	if l_ou_rowcount_flag = false then
		x_msg_data := 'The Operating Unit is not associated with any
                               Legal Entities.';
		return;
	end if;

  end if;


/* If the legal entity information is passed, the following if statement
retrieves the Operating unit information associated with the LE */

  if p_legal_entity_id is not null or p_party_id is not null then
	l_legal_entity_id := p_legal_entity_id;

	IF p_party_ID is not null then

	 BEGIN
		select legal_entity_id
		  into l_legal_entity_id
		  from xle_entity_profiles
		  where party_id = p_party_id;

	 EXCEPTION
	   	  when no_data_found then
	   	    x_msg_data := 'Invalid Party ID : ' || p_party_id;
	   	    return;
	 END;

	if p_legal_Entity_ID is not null then
	  if p_legal_Entity_ID <> l_legal_entity_id then
	     x_msg_data := 'Invalid Legal Entity ID and Party ID combination.';
	     return;
	  end if;
	end if;

	End if;

	if p_legal_entity_id is null then
	   select legal_entity_id
	     into l_legal_entity_id
	     from xle_entity_profiles
	     where party_id = p_party_id;
        else
    	     l_legal_entity_id := p_legal_entity_id;
	end if;

  	/* Invoke API get_le_ledgers to retrieve ledger associated with
           the LE */
	  l_ledger_flag := gl_mc_info.get_le_ledgers(
			 		l_legal_entity_id,
					'Y',
					'Y',
					null,
					x_ledger_list);

       /* The following statement loops through the ledger retrieved in the
          previous step */
	if x_ledger_list.count > 0 then
	for j in x_ledger_list.first..x_ledger_list.last loop
		l_le_rowcount_flag := true;
		l_ledger_id := x_ledger_list(j).ledger_id;

		select to_char(l_ledger_id)
		  into l_str_ledger_id
		  from dual;

		x_ou_le_info(j).LEGAL_ENTITY_ID := l_legal_entity_id;


		/* Invoke XLE API Get_LegalEntity_Info to retrieve legal entity
                   information */
		xle_utilities_grp.get_legalentity_info(
      			x_return_status => l_return_status,
            		x_msg_count => l_msg_count,
            		x_msg_data => l_msg_data,
            		p_party_id => null,
            		p_legalentity_id => l_legal_entity_id,
            		x_legalentity_info => l_legalentity_info);


       for OperUnit_r in OperUnit_c loop
  	x_ou_le_info(l_index).LEGAL_ENTITY_ID := l_legal_entity_id;
	x_ou_le_info(l_index).operating_unit_id := OperUnit_r.operating_unit_id;
        x_ou_le_info(l_index).party_id := l_legalentity_info.party_id;
	x_ou_le_info(l_index).name := l_legalentity_info.name;
	x_ou_le_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
	x_ou_le_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
	x_ou_le_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
	x_ou_le_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
	x_ou_le_info(l_index).type_of_company := l_legalentity_info.type_of_company;
	x_ou_le_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
	x_ou_le_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
	x_ou_le_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
	x_ou_le_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
	x_ou_le_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
	x_ou_le_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
	x_ou_le_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
	x_ou_le_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      	x_ou_le_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
	x_ou_le_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
	x_ou_le_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
	x_ou_le_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
	x_ou_le_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
	x_ou_le_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
	x_ou_le_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;

	l_index := l_index + 1;
      end loop;
    end loop;
  end if;

  if l_le_rowcount_flag = false then
     x_msg_data := 'The Legal Entity is not associated with an Operating Unit';
     return;
  end if;

 end if; /* End if for legal entity and party id information is passed */

END Get_OperatingUnit_Info;

PROCEDURE Get_InvOrg_Info(
                      x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_data       OUT  NOCOPY VARCHAR2,
                      P_InvOrg_ID     IN NUMBER,
		      P_Le_ID          IN NUMBER,
		      P_Party_ID       IN NUMBER,
                      x_Inv_Le_info OUT NOCOPY inv_org_Rec_Type
    )
IS

l_party_id number;
l_le_id number;
l_row_count NUMBER := 0;
l_inv_org_id number;
l_legal_entity_id number;

l_index number := 1;

/* The following cursor selects organization information related to a legal entity*/
cursor le_c is
  select organization_id
    from org_organization_definitions
    where legal_entity=l_Le_ID;

/* The following cursor selects legal entity information related to a organization*/
cursor org_c is
SELECT DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION2), null) LEGAL_ENTITY
FROM HR_ORGANIZATION_UNITS HoU,
HR_ORGANIZATION_INFORMATION HOI1,
HR_ORGANIZATION_INFORMATION HOI2
WHERE HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
AND HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
AND HOI1.ORG_INFORMATION1 = 'INV'
AND HOI1.ORG_INFORMATION2 = 'Y'
AND ( HOI1.ORG_INFORMATION_CONTEXT || '') = 'CLASS'
AND (HOI2.org_information_context || '') = 'Accounting Information'
AND (hou.organization_id)= p_InvOrg_ID;



l_legalentity_info       XLE_UTILITIES_GRP.LegalEntity_Rec;
l_msg_data				  VARCHAR2(1000);
l_msg_count					number;
l_return_status				 varchar2(10);

BEGIN

      l_le_id:=p_le_id;

    /* Check for mandatory information */
         IF p_party_ID is null and p_le_ID is null and p_invorg_id is null then
		x_msg_data := 'Missing Mandatory Parameters.';
	   	    return;
	end if;

   /* Either inv org information or Legal Entity Information has to be passed.
      Information about both is not accepted. */

	IF p_invorg_id is not null and (p_party_ID is not null OR p_le_ID is not null) then
		x_msg_data := 'Enter just one of the listed parameters: Inventory org ID, Legal Entity ID or Party ID of the Legal Entity. ';
	   	    return;

	end if;


        IF p_party_ID is not null then

	      /*If Legal Entity ID is also passed, check if the party ID and the Legal Entity ID match.
	        Else return with error message;	*/
	   BEGIN
		select legal_entity_id
		  into l_le_id
		  from xle_entity_profiles
		  where party_id = p_party_id;

	   EXCEPTION
	   	  when no_data_found then
	   	    x_msg_data := 'Invalid Party ID : ' || p_party_id;
	   	    return;
	   END;

           If p_le_ID is not null then
			  if p_le_ID <> l_le_id then
			  	x_msg_data := 'Invalid Legal Entity ID and Party ID combination.';
				  return;
			  end if;

	   end if;

	 end if;

	 If l_le_id is not null then

	        BEGIN
			select party_id
			  into l_party_id
			  from xle_entity_profiles
			  where legal_entity_id = l_le_id;


		EXCEPTION
	   	  when no_data_found then
	   	    x_msg_data := 'Invalid Legal Entity ID : ' || l_le_id;
	   	    return;
	        END;

	   	If p_party_ID is not null then
			  if p_party_ID <> l_party_id then
			  	x_msg_data := 'Legal Entity ID and Party ID do not match.';
				  return;
			  end if;

		end if;


               for le_r in le_c loop
                  l_row_count := l_row_count + 1;

		  x_Inv_Le_info(l_index).legal_entity_id := l_le_id;
	          x_Inv_Le_info(l_index).inv_org_id := le_r.organization_id;

                  xle_utilities_grp.get_legalentity_info(
                                        	x_return_status => l_return_status,
            				        x_msg_count => l_msg_count,
            					x_msg_data => l_msg_data,
            					p_party_id => null,
            					p_legalentity_id => x_Inv_Le_info(l_index).legal_entity_id,
            					x_legalentity_info => l_legalentity_info);


						/* Populate the output table with the Legal entity and inventory org information */

						x_Inv_Le_info(l_index).party_id := l_legalentity_info.party_id;
						x_Inv_Le_info(l_index).name := l_legalentity_info.name;
						x_Inv_Le_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_Inv_Le_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_Inv_Le_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_Inv_Le_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_Inv_Le_info(l_index).type_of_company := l_legalentity_info.type_of_company;
						x_Inv_Le_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_Inv_Le_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_Inv_Le_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_Inv_Le_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_Inv_Le_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_Inv_Le_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_Inv_Le_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_Inv_Le_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_Inv_Le_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_Inv_Le_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_Inv_Le_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
						x_Inv_Le_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
						x_Inv_Le_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
						x_Inv_Le_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_Inv_Le_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;


		  l_index := l_index + 1;
	end loop;

            if l_row_count = 0 then

	      x_msg_data := 'Invalid legal entity ID.';
              x_return_status :='E';

            else

            x_return_status :='S';

             end if;
    END IF;


    IF P_InvOrg_ID is not null then
         l_inv_org_id:=p_invorg_id;
       for org_rec in org_c loop
              l_row_count := l_row_count + 1;

		  x_Inv_Le_info(l_index).legal_entity_id := org_rec.legal_entity;
		  x_Inv_Le_info(l_index).inv_org_id := l_inv_org_id;

                  xle_utilities_grp.get_legalentity_info(
                                        	x_return_status => l_return_status,
            				        x_msg_count => l_msg_count,
            					x_msg_data => l_msg_data,
            					p_party_id => null,
            					p_legalentity_id => x_Inv_Le_info(l_index).legal_entity_id,
            					x_legalentity_info => l_legalentity_info);


						/* Populate the output table with the Legal entity and inventory org information */

						x_Inv_Le_info(l_index).party_id := l_legalentity_info.party_id;
						x_Inv_Le_info(l_index).name := l_legalentity_info.name;
						x_Inv_Le_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_Inv_Le_info(l_index).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_Inv_Le_info(l_index).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_Inv_Le_info(l_index).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_Inv_Le_info(l_index).type_of_company := l_legalentity_info.type_of_company;
						x_Inv_Le_info(l_index).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_Inv_Le_info(l_index).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_Inv_Le_info(l_index).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_Inv_Le_info(l_index).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_Inv_Le_info(l_index).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_Inv_Le_info(l_index).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_Inv_Le_info(l_index).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_Inv_Le_info(l_index).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_Inv_Le_info(l_index).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_Inv_Le_info(l_index).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_Inv_Le_info(l_index).REGION_1 := l_legalentity_info.REGION_1;
						x_Inv_Le_info(l_index).REGION_2 := l_legalentity_info.REGION_2;
						x_Inv_Le_info(l_index).REGION_3 := l_legalentity_info.REGION_3;
						x_Inv_Le_info(l_index).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_Inv_Le_info(l_index).COUNTRY := l_legalentity_info.COUNTRY;


		  l_index := l_index + 1;
	end loop;
            if l_row_count = 0 then
	      x_msg_data := 'Invalid Inventory org ID.';
              x_return_status :='E';
           else
            x_return_status :='S';

            end if;
    end if;
exception
 when others then
  -- null;
  raise;

END Get_invorg_Info;


FUNCTION Get_Le_Id_Mfg(p_operating_unit   IN NUMBER,
                       p_transaction_type IN NUMBER,
                       p_customer_account IN NUMBER)
RETURN NUMBER IS
BEGIN
  RETURN NULL;
END Get_Le_Id_Mfg;


PROCEDURE Get_CCID_Info(
                      x_return_status         OUT NOCOPY VARCHAR2,
                      x_msg_data    OUT NOCOPY VARCHAR2,
                      P_operating_unit_ID    IN NUMBER,
                      P_code_combination_id    IN Number,
                      x_ccid_le_info OUT NOCOPY XLE_BUSINESSINFO_GRP.ccid_le_Rec_Type
    ) IS
l_party_id number;
l_le_flag boolean := false;
l_le_return_flag boolean := false;

l_index number := 1;


l_ledger_info       XLE_BUSINESSINFO_GRP.LE_Ledger_Rec_Type;
l_msg_data				  VARCHAR2(1000);
l_msg_count					number;
l_return_status				 varchar2(10);
l_segment                                VARCHAR2(500);
l_sel_column                             varchar2(10);
l_ledger_id                              Number;
l_le_id                                  Number;
l_legalentity_info       XLE_UTILITIES_GRP.LegalEntity_Rec;

x_le_list gl_mc_info.le_bsv_tbl_type := gl_mc_info.le_bsv_tbl_type();
BEGIN


   /* Check for mandatory information */
         IF P_operating_unit_ID is null and P_code_combination_id is null then
		x_msg_data := 'Missing Mandatory Parameters.';
	   	    return;
	end if;


/* Parameters code combination ID and operating unit id are mandatory */

	IF ( P_operating_unit_ID is not null and P_code_combination_id is null)
	or ( P_operating_unit_ID is null and P_code_combination_id is not null) then
		x_msg_data := 'Please pass values for operating unit ID and code combination id';
		return;
	end if;
  IF P_operating_unit_ID is not null and P_code_combination_id is not null then
   begin

        SELECT   o3.org_information3
          INTO   l_ledger_id
 FROM hr_all_organization_units o,
      hr_organization_information o2,
      hr_organization_information o3
WHERE o.organization_id = o2.organization_id
 AND o.organization_id = o3.organization_id
 AND o3.organization_id = o2.organization_id
 AND o2.org_information_context || '' = 'CLASS'
 AND o3.org_information_context = 'Operating Unit Information'
 AND o2.org_information1 = 'OPERATING_UNIT'
 AND o2.org_information2 = 'Y'
 AND o.organization_id = p_operating_unit_id;

   Exception
    When no_data_found then
          return;
    When others then
          Return;

   End;
  End if;

  IF ( l_ledger_id is not null) and P_code_combination_id is not null then

   Begin

	SELECT application_column_name
	    INTO   l_segment
	    FROM   fnd_segment_attribute_values ,
	                   gl_ledgers sob
	    WHERE  id_flex_code                    = 'GL#'
  	    AND    attribute_value                 = 'Y'
	    AND    segment_attribute_type          = 'GL_BALANCING'
	    AND    application_id                  = 101
	    AND    sob.chart_of_accounts_id        = id_flex_num
	    AND    sob.ledger_id            = l_ledger_id ;


	EXECUTE IMMEDIATE ' SELECT '|| l_segment ||' FROM gl_code_combinations
        WHERE code_combination_id ='|| P_code_combination_id    INTO l_sel_column;

   Exception

      When no_data_found then
          return;
      When others then
          Return;

   End;

  End if;



/* Invoke XLE API Get_ledger_Info to retrieve ledger info information */
			XLE_BUSINESSINFO_GRP.get_ledger_info(
      							x_return_status => l_return_status,
            						x_msg_data => l_msg_data,
            						p_ledger_id => l_ledger_id,
                                                        p_bsv=>l_sel_column,
            						x_ledger_info => l_ledger_info);


          if l_ledger_info.count > 0 then

		/* The following loop loops through the list of ledgers returned in previous step */
		  for k in l_ledger_info.first..l_ledger_info.last loop


					/* Assign ledeger and legal entity information to output table */

                                                x_ccid_le_info(l_index).ledger_id := l_ledger_id;
						x_ccid_le_info(l_index).ccid := p_code_combination_id;
                                                x_ccid_le_info(l_index).legal_entity_id := l_ledger_info(l_index).legal_entity_id;
						x_ccid_le_info(l_index).name := l_ledger_info(l_index).name;
						x_ccid_le_info(l_index).party_id := l_ledger_info(l_index).party_id;
						x_ccid_le_info(l_index).LEGAL_ENTITY_IDENTIFIER := l_ledger_info(l_index).LEGAL_ENTITY_IDENTIFIER;
						x_ccid_le_info(l_index).TRANSACTING_ENTITY_FLAG := l_ledger_info(l_index).TRANSACTING_ENTITY_FLAG;
						x_ccid_le_info(l_index).ACTIVITY_CODE := l_ledger_info(l_index).ACTIVITY_CODE;
						x_ccid_le_info(l_index).sub_activity_code := l_ledger_info(l_index).sub_activity_code;
						x_ccid_le_info(l_index).type_of_company := l_ledger_info(l_index).type_of_company;
						x_ccid_le_info(l_index).LE_EFFECTIVE_FROM := l_ledger_info(l_index).LE_EFFECTIVE_FROM;
						x_ccid_le_info(l_index).LE_EFFECTIVE_TO := l_ledger_info(l_index).LE_EFFECTIVE_TO;
						x_ccid_le_info(l_index).REGISTRATION_NUMBER := l_ledger_info(l_index).REGISTRATION_NUMBER;
						x_ccid_le_info(l_index).LEGISLATIVE_CATEGORY := l_ledger_info(l_index).LEGISLATIVE_CATEGORY;
						x_ccid_le_info(l_index).EFFECTIVE_FROM := l_ledger_info(l_index).EFFECTIVE_FROM;
						x_ccid_le_info(l_index).EFFECTIVE_TO := l_ledger_info(l_index).EFFECTIVE_TO;
						x_ccid_le_info(l_index).ADDRESS_LINE_1 := l_ledger_info(l_index).ADDRESS_LINE_1;
						x_ccid_le_info(l_index).ADDRESS_LINE_2 := l_ledger_info(l_index).ADDRESS_LINE_2;
      						x_ccid_le_info(l_index).ADDRESS_LINE_3 := l_ledger_info(l_index).ADDRESS_LINE_3;
						x_ccid_le_info(l_index).TOWN_OR_CITY := l_ledger_info(l_index).TOWN_OR_CITY;
						x_ccid_le_info(l_index).REGION_1 := l_ledger_info(l_index).REGION_1;
						x_ccid_le_info(l_index).REGION_2 := l_ledger_info(l_index).REGION_2;
						x_ccid_le_info(l_index).REGION_3 := l_ledger_info(l_index).REGION_3;
						x_ccid_le_info(l_index).POSTAL_CODE := l_ledger_info(l_index).POSTAL_CODE;
						x_ccid_le_info(l_index).COUNTRY := l_ledger_info(l_index).COUNTRY;



			end loop;
		 else
                           l_le_id := xle_utilities_grp.GET_DefaultLegalContext_OU(p_operating_unit_id);
                            xle_utilities_grp.get_legalentity_info(
      							x_return_status => l_return_status,
            						x_msg_count => l_msg_count,
            						x_msg_data => l_msg_data,
            						p_party_id => null,
            						p_legalentity_id => l_le_id,
            						x_legalentity_info => l_legalentity_info);



					/* Assign ledeger and legal entity information to output table */

                                                x_ccid_le_info(1).ledger_id := l_ledger_id;
						x_ccid_le_info(1).ccid := p_code_combination_id;
                                                x_ccid_le_info(1).legal_entity_id := l_legalentity_info.legal_entity_id;
						x_ccid_le_info(1).name := l_legalentity_info.name;
						x_ccid_le_info(1).party_id := l_legalentity_info.party_id;
						x_ccid_le_info(1).LEGAL_ENTITY_IDENTIFIER := l_legalentity_info.LEGAL_ENTITY_IDENTIFIER;
						x_ccid_le_info(1).TRANSACTING_ENTITY_FLAG := l_legalentity_info.TRANSACTING_ENTITY_FLAG;
						x_ccid_le_info(1).ACTIVITY_CODE := l_legalentity_info.ACTIVITY_CODE;
						x_ccid_le_info(1).sub_activity_code := l_legalentity_info.sub_activity_code;
						x_ccid_le_info(1).type_of_company := l_legalentity_info.type_of_company;
						x_ccid_le_info(1).LE_EFFECTIVE_FROM := l_legalentity_info.LE_EFFECTIVE_FROM;
						x_ccid_le_info(1).LE_EFFECTIVE_TO := l_legalentity_info.LE_EFFECTIVE_TO;
						x_ccid_le_info(1).REGISTRATION_NUMBER := l_legalentity_info.REGISTRATION_NUMBER;
						x_ccid_le_info(1).LEGISLATIVE_CATEGORY := l_legalentity_info.LEGISLATIVE_CATEGORY;
						x_ccid_le_info(1).EFFECTIVE_FROM := l_legalentity_info.EFFECTIVE_FROM;
						x_ccid_le_info(1).EFFECTIVE_TO := l_legalentity_info.EFFECTIVE_TO;
						x_ccid_le_info(1).ADDRESS_LINE_1 := l_legalentity_info.ADDRESS_LINE_1;
						x_ccid_le_info(1).ADDRESS_LINE_2 := l_legalentity_info.ADDRESS_LINE_2;
      						x_ccid_le_info(1).ADDRESS_LINE_3 := l_legalentity_info.ADDRESS_LINE_3;
						x_ccid_le_info(1).TOWN_OR_CITY := l_legalentity_info.TOWN_OR_CITY;
						x_ccid_le_info(1).REGION_1 := l_legalentity_info.REGION_1;
						x_ccid_le_info(1).REGION_2 := l_legalentity_info.REGION_2;
						x_ccid_le_info(1).REGION_3 := l_legalentity_info.REGION_3;
						x_ccid_le_info(1).POSTAL_CODE := l_legalentity_info.POSTAL_CODE;
						x_ccid_le_info(1).COUNTRY := l_legalentity_info.COUNTRY;




		end if;
END Get_ccid_Info;

PROCEDURE Get_PurchasetoPay_Info(
                      x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_data    OUT NOCOPY VARCHAR2,
                      P_registration_code IN VARCHAR2 DEFAULT NULL,
		      P_registration_number IN VARCHAR2 DEFAULT NULL,
                      P_location_id IN NUMBER DEFAULT NULL,
                      P_code_combination_id    IN NUMBER DEFAULT NULL,
                      P_operating_unit_id IN NUMBER,
                      x_ptop_le_info OUT NOCOPY XLE_BUSINESSINFO_GRP.ptop_le_rec)
IS

l_ou_le_info XLE_BUSINESSINFO_GRP.OU_LE_Tbl_Type;
l_api_version CONSTANT NUMBER := 1.0;
l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(1000);
l_msg_count NUMBER(5);
x_le_flag BOOLEAN :=FALSE;
l_le_id NUMBER(15);
l_registration_code VARCHAR2(10);
l_le_info XLE_UTILITIES_GRP.LegalEntity_Rec;
TYPE l_le_tbl_type IS TABLE OF XLE_ENTITY_PROFILES.LEGAL_ENTITY_ID%TYPE INDEX BY BINARY_INTEGER;
l_le_tbl l_le_tbl_type;

l_ccid_le_info XLE_BUSINESSINFO_GRP.ccid_le_Rec_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   /* Check for mandatory information */

   if (P_operating_unit_ID is null) then
        x_msg_data := 'Please provide the Operating Unit Id';
        x_return_status := FND_API.G_RET_STS_ERROR;
        return;
   end if;

   if (P_REGISTRATION_NUMBER is null AND P_REGISTRATION_CODE is null
    AND P_LOCATION_ID is null AND P_CODE_COMBINATION_ID is null) then
      x_msg_data := 'Please provide either Registration Code and Number or Location id or Code combination id';
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   end if;

/* Check if Both Registration Code  and  Registration Number are provided  */

   if (P_REGISTRATION_CODE IS NOT NULL AND P_REGISTRATION_NUMBER IS NULL) OR
    (P_REGISTRATION_NUMBER IS NOT NULL AND P_REGISTRATION_CODE IS NULL) then

    x_msg_data := 'Registration Code and Registration Number need to be provided';
    x_return_status := FND_API.G_RET_STS_ERROR;
    return;
   End if;

/* Derive LE from Le-Ledger-OU relationship if the Accounting Environment is Exclusive */

	if P_OPERATING_UNIT_ID is NOT NULL then
            xle_businessinfo_grp.Get_OperatingUnit_Info(
                      x_return_status => l_return_status,
                      x_msg_data =>   l_msg_data,
                      p_operating_unit => p_operating_unit_id,
                      p_legal_entity_id => NULL,
                      p_party_id => NULL,
                      x_ou_le_info => l_ou_le_info);

             if l_ou_le_info.count = 1  then
                l_le_id := l_ou_le_info(1).legal_entity_id;
		x_le_flag := TRUE;
             end if;
     end if; /* End if Operating Unit Id */

         --Derive LE From Registration Information

        if (P_REGISTRATION_CODE IS NOT NULL AND
             P_REGISTRATION_NUMBER IS NOT NULL) AND (NOT x_le_flag)  then

        	--Derive LE from the Registration Information at the LE level

              if P_REGISTRATION_CODE = 'ANY' then
                l_registration_code := NULL;
              else
                l_registration_code := P_REGISTRATION_CODE;
              end if;
              BEGIN

                  select ent.legal_entity_id
                  into l_le_id
                  from XLE_ENTITY_PROFILES ent,
                       XLE_REGISTRATIONS reg,
                       XLE_JURISDICTIONS_B jur
                  where reg.REGISTRATION_NUMBER = P_REGISTRATION_NUMBER
                  and REG.jurisdiction_id = jur.jurisdiction_id
                  and REG.SOURCE_ID = ent.LEGAL_ENTITY_ID
 	          and JUR.REGISTRATION_CODE_LE = nvl(l_registration_code,jur.registration_code_le);

                   x_le_flag := TRUE;

               EXCEPTION

               WHEN OTHERS THEN

               x_le_flag :=FALSE;


               END;
      	--Derive LE from the Registration Information at the Estb Level

            IF  (NOT x_le_flag)  THEN

                BEGIN
  		        select etb.legal_entity_id
                        BULK COLLECT into l_le_tbl
                    from XLE_ETB_PROFILES etb,
                         XLE_REGISTRATIONS reg,
                         XLE_JURISDICTIONS_B jur
                    where reg.REGISTRATION_NUMBER = P_REGISTRATION_NUMBER
                    and REG.SOURCE_ID = etb.ESTABLISHMENT_ID
                   and REG.jurisdiction_id = jur.jurisdiction_id
                   and JUR.REGISTRATION_CODE_ETB = nvl(l_registration_code,jur.registration_code_etb)
                   group by etb.legal_entity_id;
                    if SQL%ROWCOUNT = 0 then
                         x_le_flag := FALSE;
                    end if;

                    if l_le_tbl.count = 1 then
                        l_le_id := l_le_tbl(1);
                        x_le_flag := TRUE;
                     elsif l_le_tbl.count > 1 then
                        x_le_flag := FALSE;

                    end if;
               EXCEPTION

               WHEN OTHERS THEN
                  x_le_flag := FALSE;
               END;

             IF (NOT x_le_flag)  then
                  --  Derive LE from the E-tax Registration  Call Ebtax API
                  l_le_id := ZX_API_PUB.get_le_from_tax_registration(
                              p_api_version     => l_api_version,
                              p_init_msg_list   => null,
                              p_commit  => 'FALSE',
                              p_validation_level  => null ,
                              x_return_status => l_return_status,
                              x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data ,
                              p_registration_num  => p_registration_number,
                              p_effective_date => sysdate,
                              p_country => null) ;

	                  if l_le_id IS NOT NULL and nvl(l_return_status,'x') = 'S' then
                              x_le_flag := TRUE;
                          else
                             x_le_flag := FALSE;
                         end if;

		end if;
	      end if;
      end if;

/* Use the Legal Associations view to find the associations between establishments and
  the given location id. If there is more than one establishment associated
to a location check if all establishments belong to the same Legal Entity */

 if ((P_LOCATION_ID is not null) AND (NOT x_le_flag)) then

         BEGIN
            if (l_le_tbl.EXISTS(1)) then
                l_le_tbl.DELETE;
           end if;

            SELECT legal_parent_id BULK COLLECT INTO l_le_tbl
            FROM xle_tax_associations
            WHERE ENTITY_ID =P_LOCATION_ID
          --  AND context = 'TAX_CALCULATION'
            AND ENTITY_TYPE ='BILL_TO_LOCATION'
            AND LEGAL_CONSTRUCT = 'ESTABLISHMENT'
            GROUP BY legal_parent_id;

	    if l_le_tbl.count = 1 then
                 l_le_id := l_le_tbl(1);
                 x_le_flag := TRUE;
            else
                 x_le_flag := FALSE;
	    end if;

         EXCEPTION
            WHEN OTHERS THEN
            x_le_flag := FALSE;
         END;

 end if; --End if P_location_id


--Derive LE from the Code combination ID. Derive BSV of the Code combination ID
--and derive Ledger from the Operating Unit - If No LE is assigned , the DLC is used.
-- Use the LE CCId API to derive the LE

	if (p_code_combination_id is not null and p_operating_unit_id is not null) AND (NOT x_le_flag) then

	   xle_businessinfo_grp.get_ccid_info(
          x_return_status => l_return_status,
          x_msg_data => l_msg_data,
          p_operating_unit_id => p_operating_unit_id,
          p_code_combination_id => p_code_combination_id,
          x_ccid_le_info => l_ccid_le_info);


        if l_ccid_le_info.count = 1 then
             l_le_id := l_ccid_le_info(1).legal_entity_id;
              x_le_flag := TRUE;
         else
   	      x_le_flag := FALSE;
        end if;
    end if;

   /* Use the Default Legal Context */
   if (p_operating_unit_id IS NOT NULL) AND (NOT x_le_flag) then

       l_le_id := XLE_UTILITIES_GRP.get_defaultlegalcontext_ou(p_operating_unit => p_operating_unit_id);


       if l_le_id is NOT NULL then
         x_le_flag := TRUE;
       end if;
   end if;

  if (x_le_flag) then
   Xle_utilities_grp.get_legalentity_info (
     				x_return_status => l_return_status,
           			x_msg_count => l_msg_count,
           			x_msg_data => l_msg_data,
           			p_party_id => null,
           			p_legalentity_id => l_le_id,
           			x_legalentity_info => l_le_info);

     if l_le_info.legal_entity_id IS NOT NULL then
        x_ptop_le_info.legal_entity_id := l_le_info.legal_entity_id;
        x_ptop_le_info.name := l_le_info.name;
        x_ptop_le_info.party_ID := l_le_info.party_ID;
        x_ptop_le_info.legal_entity_identifier :=  l_le_info.legal_entity_identifier;
        x_ptop_le_info.transacting_entity_flag :=  l_le_info.transacting_entity_flag;
        x_ptop_le_info.activity_code := l_le_info.activity_code ;
        x_ptop_le_info.sub_activity_code :=   l_le_info.sub_activity_code ;
        x_ptop_le_info.type_of_company :=  l_le_info.type_of_company ;
        x_ptop_le_info.le_effective_from :=  l_le_info.le_effective_from ;
        x_ptop_le_info.le_effective_to :=  l_le_info.le_effective_to ;
        x_ptop_le_info.registration_number := l_le_info.registration_number ;
        x_ptop_le_info.legislative_category := l_le_info.legislative_category ;
        x_ptop_le_info.effective_from := l_le_info.effective_from ;
        x_ptop_le_info.effective_to := l_le_info.effective_to;
        x_ptop_le_info.address_line_1 := l_le_info.address_line_1 ;
        x_ptop_le_info.address_line_2 :=  l_le_info.address_line_2 ;
        x_ptop_le_info.address_line_3 :=  l_le_info.address_line_3 ;
        x_ptop_le_info.town_or_city := l_le_info.town_or_city ;
        x_ptop_le_info.region_1 := l_le_info.region_1 ;
        x_ptop_le_info.region_2 := l_le_info.region_2 ;
        x_ptop_le_info.region_3 := l_le_info.region_3 ;
        x_ptop_le_info.postal_code :=  l_le_info.postal_code  ;
        x_ptop_le_info.country :=  l_le_info.country ;
     else
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_data := 'No Legal Entity Found';
            l_le_id := null;
     end if;
 end if;
EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR ;
raise;
-- null;

END Get_PurchasetoPay_Info;

/*============================================+
 | PROCEDURE  Get_OrdertoCash_Info
 |
 | DESCRIPTION
 |  Public Procedure which returns the otoc_Le_info record
 |
 |      IN parameters:
 |               P_customer_type       VARCHAR optional   'SOLD_TO' or 'BILL_TO'
 |               P_customer_id         NUMBER  optional
 |               P_transaction_type_id NUMBER  optional
 |               P_batch_source_id     NUMBER  optional
 |               P_operating_unit_id   NUMBER  mandatory
 |
 |      OUT parameters:
 |               x_otoc_Le_info     otoc_le_rec
 |               x_return_status     VARCHAR       'E' for error,'S' for sucess
 |               x_msg_data            VARCHAR        error message
 |
 |   If the returned otoc_Le_info record contains a legal entity id value of -1,
 |   then the legal entity could not be found. An error is raised with error msg
 |
 |
 |   DEV NOTE:  This procedure calls the AR API get_default_le and if the LE id
 |   cannot be found from this then the GET_DefaultLegalContext_OU is called,
 |   which tries to find the LE ID using the operating unit parameter.
 |
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |    21-Jun-2005     N Foley  Created
 |
 *===========================================================================*/

PROCEDURE Get_OrdertoCash_Info(
                      x_return_status       OUT NOCOPY VARCHAR2 ,
                      x_msg_data            OUT NOCOPY VARCHAR2 ,
                      P_customer_type       IN VARCHAR2 DEFAULT NULL,
                      P_customer_id         IN NUMBER DEFAULT NULL,
                      P_transaction_type_id IN NUMBER DEFAULT NULL,
                      P_batch_source_id     IN NUMBER DEFAULT NULL,
                      P_operating_unit_id   IN NUMBER,
                      x_otoc_Le_info OUT NOCOPY XLE_BUSINESSINFO_GRP.otoc_le_rec)
IS
l_le_id NUMBER;
l_return_status varchar2(1);
l_msg_data varchar2(1000);
BEGIN

/* Parameter Operating Unit Id is mandatory */
	IF P_operating_unit_id IS null then
		x_msg_data := 'Please pass a value for Operating Unit ID.';
		x_return_status := FND_API.G_RET_STS_ERROR;
		x_otoc_Le_info.legal_entity_id := -1;
		return;
	end if;

/* Parameter Customer Type must be 'SOLD_TO' or 'BILL_TO'*/
    IF P_customer_type IS NOT NULL then
    	IF P_customer_type = 'SOLD_TO' or P_customer_type = 'BILL_TO' then
	   IF P_customer_id IS NULL then
	       x_msg_data := 'Please pass a value for Customer Id as
		              Customer Type has been specified.';
	       x_return_status := FND_API.G_RET_STS_ERROR;
               x_otoc_Le_info.legal_entity_id := -1;
               return;
	    End if;
	 else
	  x_msg_data := 'Please pass value SOLD_TO or BILL_TO for Customer Type.';
	    x_return_status := FND_API.G_RET_STS_ERROR;
    	    x_otoc_Le_info.legal_entity_id := -1;
            return;
        end if;
    End if;
    --Bug:8547524
    /* Call the AR API to get the Legal Entity Id*/
    l_le_id := arp_legal_entity_util.get_default_le (
   		    p_sold_to_cust_id => P_CUSTOMER_ID,
                    p_bill_to_cust_id => P_CUSTOMER_ID,
                    p_trx_type_id     => P_TRANSACTION_TYPE_ID ,
                    p_batch_source_id => P_batch_source_id,
		    p_org_id => P_operating_unit_id);

    /* If no Legal Entity Id found then returns -1*/
    if l_le_id = -1 then
            /*  Next try to get LE id from Default Legal Context */
            l_le_id := xle_utilities_grp.GET_DefaultLegalContext_OU(
                                           	P_operating_unit_id);
            if l_le_id = -1 then
              x_return_status := FND_API.G_RET_STS_ERROR ;
              x_msg_data := 'No Legal Entity Found';
              x_otoc_Le_info.legal_entity_id := -1;
              return;
            end if;
    end if;

    x_otoc_Le_info.legal_entity_id := l_le_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR ;

END Get_OrdertoCash_Info ;

/*============================================+
 | FUNCTION Get_OrdertoCash_Info
 |
 | DESCRIPTION
 |    Public Procedure which returns the legal entity id as a NUMBER
 |
 |      IN parameters:
 |                P_customer_type       VARCHAR optional 'SOLD_TO' or 'BILL_TO'
 |                P_customer_id         NUMBER  optional
 |                P_transaction_type_id NUMBER  optional
 |                P_batch_source_id     NUMBER  optional
 |                P_operating_unit_id   NUMBER  mandatory
 |
 |      OUT parameters:
 |                P_legal_entity_id     NUMBER        -1 if not found
 |
 |   If returned legal entity id is -1, then the legal entity could not be
 |   found. An error is raised, with an error message in this case describing
 |   the problem. Please see other version of this method for more details.
 |
 |  DEV NOTE:  This Procedure is in fact a wrapper for the other
 |   Get_OrdertoCash_Info which returns a otoc_le_info record.
 |
 |   This procedures takes the otoc_le_info  record and extracts the legal
 |   entity Id from it and returns it.
 |
 |   This was a request from another product team as they required only the
 |   legal entity id and not the whole record.
 |
 |   This function signature-without out parameters can be used in sql statement.
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |    21-Jun-2005     N Foley  Created
 |    23-Jun-2005     N Foley  Changed to function
 |    27-Sep-2005     R Basker Bug 4635044: PL/SQL functions referenced by SQL
 |                             statements must not contain the OUT parameter.
 *===========================================================================*/
FUNCTION Get_OrdertoCash_Info(
                      P_customer_type       IN VARCHAR2 DEFAULT NULL,
                      P_customer_id         IN NUMBER DEFAULT NULL,
                      P_transaction_type_id IN NUMBER DEFAULT NULL,
                      P_batch_source_id     IN NUMBER DEFAULT NULL,
                      P_operating_unit_id   IN NUMBER
                      )
RETURN NUMBER IS

  l_le_id 		NUMBER;
  l_return_status 	varchar2(1);
  l_msg_data 		varchar2(1000);
  l_legal_entity_id 	number;
  l_customer_type 	varchar2(30);
  l_customer_id 	number;
  l_transaction_type_id number;
  l_batch_source_id 	number;
  l_operating_unit_id 	number;
  l_otoc_le_info       	XLE_BUSINESSINFO_GRP.otoc_le_rec;

BEGIN

  l_customer_type := P_customer_type;
  l_customer_id := P_customer_id;
  l_transaction_type_id := P_transaction_type_id;
  l_batch_source_id := P_batch_source_id;
  l_operating_unit_id := P_operating_unit_id;

  /* Call the main Get_OrdertoCash_Info method that returns the
     otoc_Le_info record*/

  XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info (
			x_return_status	 	=> l_return_status,
           	  	x_msg_data 		=> l_msg_data,
                        P_customer_type  	=> l_customer_type,
                        P_customer_id   	=> l_customer_id,
                        P_transaction_type_id 	=>  l_transaction_type_id,
                        P_batch_source_id   	=> l_batch_source_id,
                        P_operating_unit_id 	=> l_operating_unit_id,
                        x_otoc_Le_info 		=> l_otoc_le_info);

    -- if any error occurs propagate as unexpected error

    -- Commenting for bug 5159735
/*
  IF l_return_status = FND_API.G_RET_STS_ERROR OR
         l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF ;

*/
      /* If the otoc_Le_info is returned just get the Legal Entity Id*/
       if l_otoc_le_info.legal_entity_id IS NOT NULL then
          return l_otoc_le_info.legal_entity_id;
       else
          return -1;
       end if;

END Get_OrdertoCash_Info ;

/*============================================+
 | FUNCTION Get_OrdertoCash_Info
 |
 | DESCRIPTION
 |    Public Procedure which returns the legal entity id as a NUMBER
 |
 |      IN parameters:
 |                     P_customer_type       VARCHAR optional   'SOLD_TO' or 'BILL_TO'
 |                     P_customer_id         NUMBER  optional
 |                     P_transaction_type_id NUMBER  optional
 |                     P_batch_source_id     NUMBER  optional
 |                     P_operating_unit_id   NUMBER  mandatory
 |
 |      OUT parameters:
 |                     P_legal_entity_id     NUMBER        -1 if not found
 |                     x_return_status       VARCHAR       'E' for error,'S' for sucess
 |                     x_msg_data            VARCHAR        error message
 |
 |   If returned legal entity id is -1, then the legal entity could not be
 |   found. An error is raised, with an error message in this case describing the
 |   problem.
 |   Please see other version of this method for more details.
 |
 |  DEV NOTE:  This Procedure is in fact a wrapper for the other Get_OrdertoCash_Info
 |   which returns a otoc_le_info record. This procedures takes the otoc_le_info
 |   record and extracts the legal entity Id from it and returns it. This was
 |   a request from another product team as they required only the legal entity id
 |   and not the whole record.
 |   This function signature-with out parameters can be used in any where except in
 |   sql statement.
 |
 |  MODIFICATION HISTORY
 |    DATE          Author              Description of Changes
 |    21-Oct-2005   spasupun      Bgu :	4690944 Added the function overloaded with OUT
 |                                      parameters.
 *===========================================================================*/
FUNCTION Get_OrdertoCash_Info(
                      x_return_status       OUT NOCOPY VARCHAR2 ,
                      x_msg_data            OUT NOCOPY VARCHAR2 ,
                      P_customer_type       IN VARCHAR2 DEFAULT NULL,
                      P_customer_id         IN NUMBER DEFAULT NULL,
                      P_transaction_type_id IN NUMBER DEFAULT NULL,
                      P_batch_source_id     IN NUMBER DEFAULT NULL,
                      P_operating_unit_id   IN NUMBER
                      )
RETURN NUMBER IS
  l_le_id NUMBER;
  l_return_status varchar2(1);
  l_msg_data varchar2(1000);
  l_legal_entity_id number;
  l_customer_type varchar2(30);
  l_customer_id number;
  l_transaction_type_id number;
  l_batch_source_id number;
  l_operating_unit_id number;
  l_otoc_le_info       XLE_BUSINESSINFO_GRP.otoc_le_rec;

BEGIN
  l_customer_type := P_customer_type;
  l_customer_id := P_customer_id;
  l_transaction_type_id := P_transaction_type_id;
  l_batch_source_id := P_batch_source_id;
  l_operating_unit_id := P_operating_unit_id;

  /* Call the main Get_OrdertoCash_Info method that returns the otoc_Le_info record*/
  XLE_BUSINESSINFO_GRP.Get_OrdertoCash_Info (
	                x_return_status => l_return_status,
           	        x_msg_data => l_msg_data,
                        P_customer_type  => l_customer_type,
                        P_customer_id   => l_customer_id,
                        P_transaction_type_id =>  l_transaction_type_id,
                        P_batch_source_id   => l_batch_source_id,
                        P_operating_unit_id => l_operating_unit_id,
                        x_otoc_Le_info => l_otoc_le_info);

     if l_return_status = FND_API.G_RET_STS_ERROR then
            x_return_status := l_return_status ;
            x_msg_data := l_msg_data;
            RETURN -1;
   end if;


      /* If the otoc_Le_info is returned just get the Legal Entity Id*/
       if l_otoc_le_info.legal_entity_id IS NOT NULL then
              return l_otoc_le_info.legal_entity_id;

       else
              x_return_status := FND_API.G_RET_STS_ERROR ;
              x_msg_data := 'No Legal Entity Found';
              l_le_id := -1;
              return -1;
       end if;

EXCEPTION
WHEN OTHERS THEN
x_return_status := FND_API.G_RET_STS_ERROR ;

END Get_OrdertoCash_Info ;

END  XLE_BUSINESSINFO_GRP;

/
