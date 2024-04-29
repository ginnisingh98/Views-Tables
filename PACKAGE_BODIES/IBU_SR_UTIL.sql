--------------------------------------------------------
--  DDL for Package Body IBU_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_SR_UTIL" AS
/* $Header: ibusrusb.pls 120.11.12010000.2 2009/04/08 07:27:35 mkundali ship $ */
/*============================================================================+
 |                Copyright (c) 1999 Oracle Corporation                       |
 |                   Redwood Shores, California, USA                          |
 |                        All rights reserved.                                |
 +============================================================================+
 | History                                                                    |
 |  May-30-2002  klou, Initial                                                |
 |               This package contains all utility functions for SR           |
 |               module.                                                      |
 |  115.2   03-DEC-2002 WZLI changed OUT and IN OUT calls to use NOCOPY hint  |
 |                           to enable pass by reference.                     |
 |  120.14  13-FEB-2009 mkundali added for 12.1.2 enhancement bug8245975      |
 +============================================================================*/


  g_file_name VARCHAR2(32) := 'ibusrusb.pls';

  /*
    * Procedure: check_nlslength
    * This procedure takes an array of string, and an array of the max byte that
    * is corresponding to the array of string. It checks the max byte with length().
    *
   */
   PROCEDURE check_nlslength
     ( p_string                 IN JTF_VARCHAR2_TABLE_2000   := NULL,
       p_max_byte               IN JTF_NUMBER_TABLE          := NULL,
       x_out_array              OUT NOCOPY JTF_VARCHAR2_TABLE_100,
       x_return_status          OUT NOCOPY VARCHAR2
       )
   IS
     l_length    NUMBER := 0;
     l_out_array G_VARCHAR_100_TYPE;

   BEGIN

    For i in p_string.FIRST..p_string.LAST Loop
        l_out_array(i) := 'S';
        l_length       := 0;
        If p_string(i) Is Not Null Then
            select lengthb(p_string(i)) into l_length from dual;

            If l_length >  p_max_byte(i) Then
                l_out_array(i) := 'F';
            End If;
        End If;
    End Loop;
    copy_out_array(l_out_array, x_out_array);
    x_return_status := 'S';
   EXCEPTION
       WHEN OTHERS THEN
      -- x_return_status := sqlerrm;
        x_return_status := 'F';
   END check_nlslength;


PROCEDURE copy_out_array(
    t    IN  G_VARCHAR_100_TYPE,
    a0   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as

    ddindx binary_integer;
    indx binary_integer;
BEGIN
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then

        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx then
            exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;

END copy_out_array;

-- added the below procedures for isupport porject----------------------------------
PROCEDURE call_create_org_contact( p_user_id  IN NUMBER,
                                   p_Subject_Id IN NUMBER,
                                   p_Object_Id  IN SYSTEM.ibu_num_tbl_type,
				   p_Subject_Table_name IN VARCHAR2,
				   p_Object_Table_name IN VARCHAR2,
				   p_Subject_Type IN VARCHAR2,
				   p_Object_Type IN VARCHAR2,
				   p_Relationship_Code IN VARCHAR2,
				   p_Relationship_Type IN VARCHAR2,
				   p_Start_Date IN DATE,
				   p_End_Date  IN DATE,
				   p_Status IN VARCHAR2,
				   p_created_by_module IN VARCHAR2,
				   p_application_id IN NUMBER,
				   x_return_status OUT NOCOPY VARCHAR2,
				   x_msg_count OUT NOCOPY NUMBER,
				   x_msg_data OUT NOCOPY VARCHAR2
				   )
AS

l_org_contact_rec_v2            HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type  := CSC_RESPONSE_CENTER_PKG_V2.GET_ORG_CONTACT_REC_TYPE;
l_party_rel_rec_v2              HZ_RELATIONSHIP_V2PUB.relationship_rec_type  := CSC_RESPONSE_CENTER_PKG_V2.GET_RELATIONSHIP_REC_TYPE;
l_party_rec_v2                  HZ_PARTY_V2PUB.PARTY_REC_TYPE                := CSC_RESPONSE_CENTER_PKG_V2.GET_PARTY_REC_TYPE;
l_true                      VARCHAR2(5)  := CSC_CORE_UTILS_PVT.G_TRUE;
l_org_contact_id        NUMBER;
l_party_id            NUMBER;
l_party_id2           NUMBER;
l_party_number             VARCHAR2(30);
l_Party_Relationship_Id         NUMBER;
l_return_status               VARCHAR2(10)  ;
x_status                       VARCHAR2(10) ;
x_status1                       VARCHAR2(10) ;
x_party_id                   NUMBER;
x_party_id1                   NUMBER;
l_msg_count             NUMBER;
l_msg_data            VARCHAR2(2000);
x_insert_status       VARCHAR2(10) ;
i                   NUMBER;
l_user_id_type    SYSTEM.IBU_NUM_TBL_TYPE := SYSTEM.IBU_NUM_TBL_TYPE();
l_party_id_type  SYSTEM.IBU_NUM_TBL_TYPE := SYSTEM.IBU_NUM_TBL_TYPE();
l_flag_type   SYSTEM.IBU_VAR_3_TBL_TYPE := SYSTEM.IBU_VAR_3_TBL_TYPE();
l_operation_type  SYSTEM.IBU_VAR_3_TBL_TYPE := SYSTEM.IBU_VAR_3_TBL_TYPE();
--x_email_status   VARCHAR2(10);
BEGIN

FOR i IN p_Object_Id.FIRST .. p_Object_Id.LAST LOOP
l_user_id_type.EXTEND;
l_party_id_type.EXTEND;
l_flag_type.EXTEND;
l_operation_type.EXTEND;

check_relationship(p_Subject_Id,
                   p_Object_Id(i),
		   x_party_id1,
		   x_status);

IF x_status = 'E' THEN

l_Party_Rel_Rec_v2.Subject_Id           := p_Subject_Id;
l_Party_Rel_Rec_v2.Object_Id            := p_Object_Id(i);
l_Party_Rel_Rec_v2.Subject_Table_name   := p_Subject_Table_name;
l_Party_Rel_Rec_v2.Object_Table_name    := p_Object_Table_name;
l_Party_Rel_Rec_v2.Subject_Type         := p_Subject_Type;
l_Party_Rel_Rec_v2.Object_Type          := p_Object_Type;
l_Party_Rel_Rec_v2.Relationship_Code    := p_Relationship_Code;
l_Party_Rel_Rec_v2.Relationship_Type    := p_Relationship_Type;
l_Party_Rel_Rec_v2.Start_Date           := p_Start_Date;
l_Party_Rel_Rec_v2.End_Date             := p_End_Date;
l_Party_Rel_Rec_v2.Status               := p_Status;
l_Party_Rel_Rec_v2.created_by_module    := p_created_by_module;
l_Party_Rel_Rec_v2.application_id       := p_application_id;
l_org_contact_rec_v2.party_rel_rec      := l_party_rel_rec_v2;
l_org_contact_rec_v2.created_by_module  := p_created_by_module;
l_org_contact_rec_v2.application_id     := p_application_id;

HZ_PARTY_CONTACT_V2PUB.create_org_contact(
                p_init_msg_list         => l_true,
                p_org_contact_rec       => l_org_contact_rec_V2,
                x_org_contact_id        => l_org_contact_id,
                x_party_rel_id          => l_party_relationship_id,
                x_party_id              => l_party_id,
                x_party_number          => l_party_number,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data
                );

 x_return_status := l_return_status;
 x_msg_count := l_msg_count;
 x_msg_data := l_msg_data;
IF  x_return_status = 'S' THEN

 l_user_id_type(i) := p_user_id;
 l_party_id_type(i) := x_party_id1;
-- l_flag_type(i) := 'Y';
 l_operation_type(i) := 'A';

  create_ibu_multi_parties (p_user_id,
                             l_party_id,
			     'Y',
			     'N',
			      NULL,
			     p_user_id,
			     SYSDATE,
			     p_user_id,
			     SYSDATE,
			     p_user_id,
		             x_insert_status
			     );

END IF;

ELSE
 x_return_status := 'S';
 l_user_id_type(i) := p_user_id;
 l_party_id_type(i) := x_party_id1;
 l_flag_type(i) := 'Y';
 l_operation_type(i) := 'A';

create_ibu_multi_parties (p_user_id ,
                          x_party_id1 ,
			  'Y',
			  'N',
			   NULL,
			   p_user_id,
			   SYSDATE,
			   p_user_id,
			   SYSDATE,
			   p_user_id,
		           x_insert_status
			   );



END IF;

END LOOP;
IBU_MULTIPARTY_PUB.send_email_notification(l_user_id_type,
                                           l_party_id_type,
					   l_operation_type
					   );

 EXCEPTION
 WHEN OTHERS THEN

 x_return_status:= 'E';
 x_insert_status := 'E';

END call_create_org_contact;

PROCEDURE check_relationship(p_Subject_Id IN NUMBER,
                             p_Object_Id  IN NUMBER,
			     x_party_id  OUT NOCOPY NUMBER,
			     x_status OUT NOCOPY VARCHAR2
			     )

AS

BEGIN
SELECT /*+ index(HZ_RELATIONSHIPS_N2) */ party_id
INTO x_party_id
FROM hz_relationships
WHERE object_id = p_Object_Id
AND object_type='ORGANIZATION'
AND subject_id  = p_Subject_Id
AND subject_type ='PERSON'
AND relationship_code ='CONTACT_OF';

x_status  := 'S';

EXCEPTION
WHEN NO_DATA_FOUND THEN
  x_status  := 'E';
  x_party_id := 0;
WHEN OTHERS THEN
   raise;
END check_relationship;



PROCEDURE create_ibu_multi_parties(p_user_id IN NUMBER,
                                   p_party_id IN NUMBER,
			           p_enable_flag IN VARCHAR2,
			           p_current_party IN VARCHAR2,
			           p_end_date IN DATE,
			           p_created_by IN NUMBER,
			           p_creation_date IN DATE,
			           p_last_updated_by IN NUMBER,
			           p_last_update_date IN DATE,
			           p_last_update_login IN NUMBER,
			           x_insert_status OUT NOCOPY VARCHAR2
			          )

AS

BEGIN

INSERT INTO ibu_multi_parties(USER_ID,
                              PARTY_ID,
			      ENABLE_FLAG,
			      CURRENT_PARTY,
			      END_DATE,
			      CREATED_BY,
			      CREATION_DATE,
                              LAST_UPDATED_BY,
			      LAST_UPDATE_DATE,
			      LAST_UPDATE_LOGIN)
                       VALUES (p_user_id,
		               p_party_id,
			       p_enable_flag,
			       p_current_party,
			       p_end_date,
			       p_created_by,
			       p_creation_date,
                               p_last_updated_by,
			       p_last_update_date,
			       p_last_update_login);

x_insert_status := 'S';

EXCEPTION
WHEN others THEN
x_insert_status := 'E';
END create_ibu_multi_parties;


PROCEDURE update_ibu_multi_parties(p_user_id IN NUMBER,
				   p_loggedin_user_id IN NUMBER,
                                   p_party_id IN SYSTEM.IBU_NUM_TBL_TYPE,
				   p_enable_flag  IN SYSTEM.IBU_VAR_3_TBL_TYPE,
				   x_update_status OUT NOCOPY VARCHAR2
				   )
AS
i NUMBER;
j NUMBER;
l_party_id1 NUMBER;
l_flag VARCHAR2(1);
l_temp VARCHAR2(1);
BEGIN
FOR i IN p_party_id.FIRST .. p_party_id.LAST LOOP
select ENABLE_FLAG into l_temp from ibu_multi_parties where party_id=p_party_id(i) and user_id=p_user_id;
l_party_id1 := p_party_id(i);
l_flag := p_enable_flag(i);
IF l_temp <> l_flag THEN
UPDATE ibu_multi_parties
SET ENABLE_FLAG = l_flag,last_update_date = SYSDATE,last_updated_by = p_loggedin_user_id,last_update_login = p_loggedin_user_id
WHERE USER_ID = p_user_id
AND PARTY_ID = l_party_id1;
END IF;
END LOOP;
x_update_status := 'S';
EXCEPTION
WHEN OTHERS THEN
x_update_status := 'E';

END update_ibu_multi_parties;

/*added for 12.1.2 enhancement bug8245975*/
function return_primary(party_site_id IN NUMBER) return varchar2 is
l_phone varchar2(100);
CURSOR C1 IS SELECT phone_number FROM hz_contact_points where owner_table_id = party_site_id and owner_table_name = 'HZ_PARTY_SITES' and contact_point_type = 'PHONE' order by primary_flag desc,creation_date asc;
BEGIN
FOR R IN C1
  LOOP
	l_phone:= R.phone_number;
	if (l_phone is NOT NULL ) THEN
	return(l_phone);
	end if;
END LOOP;
return(l_phone);
end;




-----------------------------------------------------------------------------------
END IBU_SR_UTIL; -- Package Specification IBU_SR_UTIL

/
