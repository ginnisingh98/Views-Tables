--------------------------------------------------------
--  DDL for Package Body IEM_GETCUST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_GETCUST_PVT" as
/* $Header: iemgcstb.pls 120.4 2006/03/22 15:19:19 rtripath noship $*/
-- Include checking for do not use email address 10/30/03 RT
G_PKG_NAME varchar2(255) :='IEM_GETCUST_PVT';

PROCEDURE GetCustomerInfo(
 P_Api_Version_Number 	IN NUMBER,
 P_Init_Msg_List  		IN VARCHAR2     ,
 P_Commit    			IN VARCHAR2     ,
 p_email		   		IN  VARCHAR2,
 p_party_id   		 OUT NOCOPY  NUMBER,
 p_customer_name   	 OUT NOCOPY  VARCHAR2,
 p_first_name   	 OUT NOCOPY  VARCHAR2,
 p_last_name   	 OUT NOCOPY  VARCHAR2,
 x_msg_count   	 OUT NOCOPY  NUMBER,
 x_return_status  	 OUT NOCOPY  VARCHAR2,
 x_msg_data   		 OUT NOCOPY VARCHAR2)

IS
BEGIN
	null;	-- This api is no longer in use hence stub it
			-- 08/06/2002 rtripath
END GetCustomerInfo;

PROCEDURE GetCustomerId(
 P_Api_Version_Number     IN   NUMBER,
 p_email		   		 IN  VARCHAR2,
 p_party_id               OUT NOCOPY  NUMBER,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data   			 OUT NOCOPY VARCHAR2)

 IS

 l_api_name          VARCHAR2(255):='GetCustomerId';
 l_ptype			 VARCHAR2(30);
BEGIN
   x_return_status := 'S';
    select owner_table_id into p_party_id
    from hz_contact_points
    where owner_table_name='HZ_PARTIES'
    and contact_point_type='EMAIL'
    and status='A'
    and upper(email_address)=upper(p_email)
    and contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
    where contact_level_table='HZ_CONTACT_POINTS' and status='A');
EXCEPTION
   WHEN NO_DATA_FOUND THEN
   	p_party_id:=-1;
	when too_many_rows then
		p_party_id:=0;
	when others then
      x_return_status := 'F';
END GetCustomerId;

PROCEDURE CustomerSearch(
 P_Api_Version_Number     IN   NUMBER,
 p_email	   			 IN  VARCHAR2,
 x_party_id               OUT NOCOPY  NUMBER,
 x_msg_count   		 OUT NOCOPY  NUMBER,
 x_return_status  		 OUT NOCOPY  VARCHAR2,
 x_msg_data   			 OUT NOCOPY VARCHAR2)

 IS

 l_api_name          VARCHAR2(255):='CustomerSearch';
 l_ptype			 VARCHAR2(30);
l_address			 varchar2(100);
l_email			 varchar2(100);
l_v1count			number;
l_v2count			number;
l_party_id			number;
l_party_type		varchar2(30);
 l_contactcount	 NUMBER:=0;
 l_api_version_number  NUMBER:=1.0;
 l_party_status	number:=0;
 l_rec_tbl		IEM_GETCUST_PVT.cust_rec_tbl;
 l_rec_tbl1		IEM_GETCUST_PVT.cust_rec_tbl;
 l_rec_tbl2		IEM_GETCUST_PVT.cust_rec_tbl;
 l_counter		number:=1;
 l_counter1		number:=1;
 l_counter2		number:=1;
   cursor c1 is
	select a.owner_table_id,b.party_type,a.email_address
	from hz_contact_points a,hz_parties b
	where a.owner_table_name='HZ_PARTIES'
	and upper(a.email_address)=upper(p_email)
	and  a.contact_point_type='EMAIL'
	and a.status='A'
	and b.party_id=a.owner_table_id
     and a.contact_point_id not in  (select contact_level_table_id from HZ_CONTACT_PREFERENCES
    where contact_level_table='HZ_CONTACT_POINTS' and status='A')
	order by 2,1 DESC;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_rec_tbl.delete;
   l_rec_tbl1.delete;
   l_rec_tbl2.delete;
   for v1 in c1 LOOP
   IF v1.party_type='ORGANIZATION' THEN
	l_rec_tbl(l_counter).owner_table_id:=v1.owner_table_id;
	l_counter:=l_counter+1;
   ELSIF v1.party_type='PARTY_RELATIONSHIP' THEN
	l_rec_tbl2(l_counter2).owner_table_id:=v1.owner_table_id;
	l_counter2:=l_counter2+1;
   ELSIF v1.party_type='PERSON' THEN
	l_rec_tbl1(l_counter1).owner_table_id:=v1.owner_table_id;
	l_counter1:=l_counter1+1;
   END IF;
   END LOOP;
 IF l_rec_tbl.count>0 THEN
	l_party_id:=l_rec_tbl(1).owner_table_id;
 ELSIF l_rec_tbl1.count>0 THEN
	l_party_id:=l_rec_tbl1(1).owner_table_id;
 ELSIF l_rec_tbl2.count>0 THEN
  FOR j in l_rec_tbl2.FIRST..l_rec_tbl2.LAST LOOP

    select count(hzr.party_id) into l_v1count
    from HZ_PARTIES hzp, HZ_RELATIONSHIPS hzr
    where hzp.party_type='PARTY_RELATIONSHIP'
    and hzr.party_id=hzp.party_id
    and hzr.party_id=l_rec_tbl2(j).owner_table_id
    and hzr.status in('A','I')
and (hzr.relationship_code='CONTACT_OF' or hzr.relationship_code='EMPLOYEE_OF');
  IF l_v1count>0 THEN
	l_party_id:=l_rec_tbl2(j).owner_table_id;
	EXIT;
  END IF;
  EXIT when l_party_id is not null;
  END LOOP;
 END IF;
 IF l_party_id is not null THEN
	x_party_id:=l_party_id;
 ELSE
    x_party_id:=FND_PROFILE.VALUE_SPECIFIC('IEM_DEFAULT_CUSTOMER_ID');
 END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
END CustomerSearch;
End IEM_GETCUST_PVT;

/
