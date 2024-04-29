--------------------------------------------------------
--  DDL for Package Body IGW_GR_PERSONNEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_GR_PERSONNEL" as
/* $Header: igwgrpersonnelb.pls 120.3 2005/09/30 00:55:31 ashkumar ship $ */

-------------------------------------------- PERSONNEL GENERAL --------------------------------------

FUNCTION MIN_PERSONNEL_START_DATE (P_PROPOSAL_ID 	IN 	NUMBER,
				   P_PERSON_PARTY_ID	IN	NUMBER) RETURN DATE is

l_status		varchar2(1);
l_min_start_date 	date;
BEGIN

   	return l_min_start_date;
EXCEPTION
      when others then
      return null;

END MIN_PERSONNEL_START_DATE;

--------------------------------------------------------------------------------------------------------------------------------
FUNCTION MAX_PERSONNEL_END_DATE (P_PROPOSAL_ID 		IN 	NUMBER,
				 P_PERSON_PARTY_ID	IN	NUMBER) RETURN DATE is
l_status		varchar2(1);
l_max_end_date 	date;
BEGIN
   	return l_max_end_date;
EXCEPTION
      when others then
      return null;

END MAX_PERSONNEL_END_DATE;

-------------------------------------------------------------------------------------------------------
FUNCTION GET_SPONSOR_NAME(p_sponsor_id	in 	number) return varchar2 is
o_sponsor_name varchar2(360);
BEGIN
   return  o_sponsor_name;

EXCEPTION
   when others then
        o_sponsor_name := null;
        return o_sponsor_name;
END GET_SPONSOR_NAME;

---------------------------------------------------------------------------------------
FUNCTION GET_PERSON_NAME(p_person_party_id	in number) return varchar2 is
o_person_name varchar2(360);
BEGIN
   return  o_person_name;

EXCEPTION
   when others then
        o_person_name := null;
        return o_person_name;

END GET_PERSON_NAME;

---------------------------------------------------------------------------------------------------------
FUNCTION GET_MAJOR_GOALS (p_proposal_id   NUMBER) RETURN VARCHAR2 is
  o_major_goals      varchar2(250);
  Begin
  RETURN o_major_goals;
  EXCEPTION
     when no_data_found then
         o_major_goals := NULL;
         RETURN o_major_goals;
  END GET_MAJOR_GOALS;

-------------------------------------------------------------------------------------------------------------------
-- the following code transfers the degrees pertaining to the appropriate proposal and person from the
-- igw_person_degrees table to the igw_prop_person_degrees table and from igw_person_biosketch table to
-- the igw_prop_person_biosketch_table

PROCEDURE POPULATE_BIO_TABLES (p_init_msg_list     in    varchar2,
 			       p_commit            in    varchar2,
 			       p_validate_only     in    varchar2,
			       p_proposal_id       in    number,
			       p_party_id          in    number,
			       x_return_status	   out NOCOPY   varchar2,
			       x_msg_count         out NOCOPY   number,
 			       x_msg_data          out NOCOPY   varchar2) is


BEGIN

   null;

END POPULATE_BIO_TABLES;

------------------------------------------------------------
FUNCTION GET_FORMATTED_ADDRESS (P_PARTY_ID      NUMBER) RETURN VARCHAR2 is
l_address1	hz_parties.address1%TYPE;
l_address2	hz_parties.address2%TYPE;
l_address3	hz_parties.address3%TYPE;
l_address4	hz_parties.address4%TYPE;
l_city	            hz_parties.city%TYPE;
l_state	            hz_parties.state%TYPE;
l_postal_code	hz_parties.postal_code%TYPE;
l_address          varchar2(1000) := null;

BEGIN

   	return l_address;
EXCEPTION
      when others then
      return null;

END GET_FORMATTED_ADDRESS;

PROCEDURE add_other_support_commitments (
      p_init_msg_list                IN VARCHAR2,
      p_validate_only                IN VARCHAR2,
      p_commit                       IN VARCHAR2,
      p_prop_person_support_id       IN NUMBER,
      p_proposal_id                  IN NUMBER,
      p_person_party_id              IN NUMBER,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2) IS


      G_PKG_NAME VARCHAR2(100);
      l_api_name VARCHAR2(100);

BEGIN
null;

END add_other_support_commitments;

PROCEDURE delete_personnel_related_data(
      p_init_msg_list                IN VARCHAR2,
      p_commit                       IN VARCHAR2,
      p_proposal_id                  IN NUMBER,
      p_person_party_id              IN NUMBER,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2) IS


      G_PKG_NAME VARCHAR2(100);
      l_api_name VARCHAR2(100);

      l_success  VARCHAR2(100);
      l_errcode  VARCHAR2(100);

BEGIN
null;

END delete_personnel_related_data;

END IGW_GR_PERSONNEL;

/
