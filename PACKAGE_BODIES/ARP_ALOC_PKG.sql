--------------------------------------------------------
--  DDL for Package Body ARP_ALOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ALOC_PKG" as
/* $Header: AROALOCB.pls 115.0 99/07/17 00:00:37 porting ship $ */
--
-- FUNCTION
--		user_value
--     PUBLIC
--
-- DESCRIPTION
--		This function returns the location_segment_user_value for a location_segemt_value.
--		Given any mixed case string this function will return the correct user_value
--		for it.
--
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:  p_segment_qualifier
--		     p_segment_value
--
--              OUT:
--
--
-- RETURNS    : NONE
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
function user_value ( 	p_segment_qualifier 	in varchar2,
			p_segment_value 	in varchar2 ) return varchar2 is
--
cursor c_user_value(p_segment_qualifier in varchar2,
		    p_segment_value 	 in varchar2  )  is
--
select 	distinct location_segment_user_value
from	ar_location_values
where	location_segment_qualifier = p_segment_qualifier
and	location_segment_value	   = upper(p_segment_value);
--
l_segment_user_value varchar2(60);
begin
	open c_user_value( p_segment_qualifier,p_segment_value);
	--
	fetch c_user_value into l_segment_user_value;
	--
	close c_user_value;
	--
	return(l_segment_user_value);
end user_value;
--
-- FUNCTION
--		user_value_matches_id
--     PUBLIC
--
-- DESCRIPTION
--		This function returns checks to see if the location_segment_user_value and a
--		location_segement_id matche
--		for it.
--
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:  p_segment_user_value
--		     p_segment_is
--
--              OUT:
--
--
-- RETURNS    : TRUE  if location_segment_user_value and location_segement_id are compatible
--            : FALSE if location_segment_user_value and location_segement_id are NOT compatible
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
function user_value_matches_id ( p_segment_user_value 	in varchar2,
				 p_segment_id	 	in number  ) return boolean is
--
dummy number;
--
begin
	select 1
	into   dummy
	from 	ar_location_values
	where	location_segment_id 		= p_segment_id
	and	location_segment_user_value	= p_segment_user_value;
	--
	return(TRUE);
exception
	when NO_DATA_FOUND then
		return(FALSE);

end user_value_matches_id;
--
-- FUNCTION
--		unique_postal_code
--
--     PUBLIC
--
-- DESCRIPTION
--		This function returns a postal_code if it is the only postal_code for a segment_value
--
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:  -  p_location_segment_id
--
--              OUT:
--
--
-- RETURNS    : postal_code
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--


function unique_postal_code ( p_segment_id in number ) return varchar2 is
--
l_to_postal_code varchar2(60);
l_from_postal_code varchar2(60);
--
begin
	--
	select 	from_postal_code,
		to_postal_code
	into	l_from_postal_code,
		l_to_postal_code
	from	ar_postal_code_ranges_v
	where	location_segment_id	= p_segment_id;

	if l_from_postal_code	= substr(l_to_postal_code,1,length(l_from_postal_code)) then
		return(l_from_postal_code);
	else
		return(null);
	end if;

exception
	when NO_DATA_FOUND or TOO_MANY_ROWS then
		return(null);

end unique_postal_code;
--
-- FUNCTION
--		user_value_matches_id
--     PUBLIC
--
-- DESCRIPTION
--		This function returns a the parent segmenr_id and user_value for a child segment_id
--
-- SCOPE -
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:  -  p_child_segment_id
--
--              OUT:    p_parent_segment_id
--			p_parent_segment_user_value
--
--
-- RETURNS    :
--
-- NOTES
--
-- MODIFICATION HISTORY - Created by Kevin Hudson
--
--
procedure parent_value_and_id ( p_child_segment_id 	 in number,
				p_parent_segment_id	 out number,
				p_parent_segment_user_val   out varchar2 ) is
--
begin
	--
	select 	parent_id,
		parent_user_value
	into 	p_parent_segment_id,
		p_parent_segment_user_val
	from 	ar_loc_two_level_v
	where	child_id	= p_child_segment_id;
	--
end parent_value_and_id;

end arp_aloc_pkg;

/
