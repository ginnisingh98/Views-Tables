--------------------------------------------------------
--  DDL for Package IBU_SR_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_SR_UTIL" AUTHID CURRENT_USER as
/* $Header: ibusruss.pls 120.8.12010000.2 2009/04/08 07:29:30 mkundali ship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- version  Date        Person    Comments
----------  ---------   ------  ------------------------------------------
--  115.3   03-DEC-2002 WZLI     changed OUT and IN OUT calls to use NOCOPY hint
--                               to enable pass by reference.
-- Enter package declarations as shown below

  g_file_name VARCHAR2(32) := 'ibusruss.pls';
  Type  G_VARCHAR_100_TYPE Is Table of VARCHAR2(100) Index By Binary_Integer;

   PROCEDURE check_nlslength
     ( p_string                 IN JTF_VARCHAR2_TABLE_2000 :=null,
       p_max_byte               IN JTF_NUMBER_TABLE :=null,
       x_out_array              OUT NOCOPY JTF_VARCHAR2_TABLE_100,
       x_return_status          OUT NOCOPY VARCHAR2
       );


  PROCEDURE copy_out_array(
    t    IN  G_VARCHAR_100_TYPE,
    a0   OUT NOCOPY JTF_VARCHAR2_TABLE_100
    );
------- added the below procedures for isupport porject----------------------------------
 PROCEDURE call_create_org_contact(p_user_id  IN NUMBER,
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
				   );

procedure check_relationship(p_Subject_Id IN NUMBER,
                             p_Object_Id  IN NUMBER,
			     x_party_id  OUT NOCOPY NUMBER,
			     x_status OUT NOCOPY VARCHAR2
			     );

Procedure create_ibu_multi_parties(p_user_id IN NUMBER,
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
			          );

Procedure update_ibu_multi_parties(p_user_id IN NUMBER,
				   p_loggedin_user_id IN NUMBER,
                                   p_party_id IN SYSTEM.IBU_NUM_TBL_TYPE,
				   p_enable_flag  IN system.IBU_VAR_3_TBL_TYPE,
				   x_update_status OUT NOCOPY VARCHAR2
				   );

/*added for 12.1.2 enhancement bug8245975*/
function return_primary(party_site_id IN NUMBER) return varchar2;
------------------------------------------------------------------------------------------------
END IBU_SR_UTIL; -- Package Specification IBU_SR_UTIL

/
