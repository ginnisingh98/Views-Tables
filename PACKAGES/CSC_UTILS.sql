--------------------------------------------------------
--  DDL for Package CSC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_UTILS" AUTHID CURRENT_USER AS
/* $Header: cscutils.pls 120.4.12010000.2 2009/04/07 16:27:16 mpathani ship $ */

TYPE Party_Ref_Cur_Type IS REF CURSOR;

TYPE Prof_Rec_Type IS RECORD(
	Group_Id               NUMBER
);

TYPE Dashboard_Rec_Type IS RECORD (
         Group_Id               NUMBER,
	 Cust_Party_Id		NUMBER,
	 Cust_Party_Type	VARCHAR2(2000),
	 Cust_Party_Number	NUMBER,
	 Cust_Account_Number    VARCHAR2(30), -- added for 7679121 by mpathani
 	 Cust_Account_Id        NUMBER,
	 Cust_Phn_Country_Code  VARCHAR2(100),
	 Cust_Phn_Area_Code     VARCHAR2(100),
	 Cust_Phone_Number      VARCHAR2(40),
	 Cust_Email             VARCHAR2(1000),
	 Cust_URL               VARCHAR2(2000),
	 Cust_Address_1         VARCHAR2(2000),
	 Cust_City              VARCHAR2(60),
	 Cust_State             VARCHAR2(60),
	 Cust_Postal_Code       VARCHAR2(60),
	 Cust_Country_Code      VARCHAR2(100),
	 Cust_Province          VARCHAR2(60),
	 Cust_County            VARCHAR2(60),
	 Cust_Location_Id       NUMBER,
	 Cust_class_code        VARCHAR2(80),
	 Cust_tax_ident         VARCHAR2(60),
	 Cust_DOB               DATE,
	 Cust_person_iden_type  VARCHAR2(80),
	 Cust_pers_identifier   VARCHAR2(60),
	 Cont_Party_Id          NUMBER,
	 Cont_Party_Type        VARCHAR2(2000),
	 Cont_Party_Number      NUMBER,
	 Cont_Relationship_Code VARCHAR2(2000),
	 Cont_Phn_Country_Code  VARCHAR2(100),
	 Cont_Phn_Area_Code     VARCHAR2(100),
	 Cont_Phn_Number	VARCHAR2(40),
	 Cont_Email		VARCHAR2(1000),
	 Cont_Address_1		VARCHAR2(2000),
	 Cont_City		VARCHAR2(60),
	 Cont_State		VARCHAR2(60),
	 Cont_Postal_Code	VARCHAR2(60),
	 Cont_Country_Code	VARCHAR2(100),
	 Cont_Province		VARCHAR2(60),
	 Cont_County            VARCHAR2(60),
	 Cont_Location_Id       NUMBER,
         Skey_Name              VARCHAR2(2000),  /* VERIFY */
	 Skey_Value             NUMBER,
	 --Cust_Attribute0        VARCHAR2(150),
         Cust_Attribute1        VARCHAR2(150),
	 Cust_Attribute2        VARCHAR2(150),
	 Cust_Attribute3	VARCHAR2(150),
	 Cust_Attribute4	VARCHAR2(150),
	 Cust_Attribute5	VARCHAR2(150),
	 Cust_Attribute6	VARCHAR2(150),
	 Cust_Attribute7	VARCHAR2(150),
	 Cust_Attribute8	VARCHAR2(150),
	 Cust_Attribute9	VARCHAR2(150),
	 Cust_Attribute10	VARCHAR2(150),
	 Cust_Attribute11	VARCHAR2(150),
	 Cust_Attribute12	VARCHAR2(150),
	 Cust_Attribute13	VARCHAR2(150),
	 Cust_Attribute14	VARCHAR2(150),
	 Cust_Attribute15	VARCHAR2(150),
	 Cust_Attribute16	VARCHAR2(150),
	 Cust_Attribute17	VARCHAR2(150),
	 Cust_Attribute18	VARCHAR2(150),
	 Cust_Attribute19	VARCHAR2(150),
	 Cust_Attribute20	VARCHAR2(150),
	 Cust_Attribute21	VARCHAR2(150),
	 Cust_Attribute22	VARCHAR2(150),
	 Cust_Attribute23	VARCHAR2(150),
	 Cust_Attribute_Category VARCHAR2(150),
	 --Cont_Attribute0        VARCHAR2(150),
         Cont_Attribute1        VARCHAR2(150),
	 Cont_Attribute2        VARCHAR2(150),
	 Cont_Attribute3	VARCHAR2(150),
	 Cont_Attribute4	VARCHAR2(150),
	 Cont_Attribute5	VARCHAR2(150),
	 Cont_Attribute6	VARCHAR2(150),
	 Cont_Attribute7	VARCHAR2(150),
	 Cont_Attribute8	VARCHAR2(150),
	 Cont_Attribute9	VARCHAR2(150),
	 Cont_Attribute10	VARCHAR2(150),
	 Cont_Attribute11	VARCHAR2(150),
	 Cont_Attribute12	VARCHAR2(150),
	 Cont_Attribute13	VARCHAR2(150),
	 Cont_Attribute14	VARCHAR2(150),
	 Cont_Attribute15	VARCHAR2(150),
	 Cont_Attribute16	VARCHAR2(150),
	 Cont_Attribute17	VARCHAR2(150),
	 Cont_Attribute18	VARCHAR2(150),
	 Cont_Attribute19	VARCHAR2(150),
	 Cont_Attribute20	VARCHAR2(150),
	 Cont_Attribute21	VARCHAR2(150),
	 Cont_Attribute22	VARCHAR2(150),
	 Cont_Attribute23	VARCHAR2(150),
	 Cont_Attribute_Category VARCHAR2(150)
	 );

/*  FUNCTION
--              Isvalid_dashboard_group_id
--  PURPOSE
--              This function checks if a given group_id is
--              a dashborad group.  If it is a dashboard group
--              then the function returns 'Y'.  If not, then the
--              function returns 'N'.
*/
function Isvalid_dashboard_group_id(p_group_id in csc_prof_groups_b.group_id%TYPE) return boolean;

END CSC_UTILS;

/
