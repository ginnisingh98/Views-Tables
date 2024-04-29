--------------------------------------------------------
--  DDL for Package PAY_US_INS_ORG_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_INS_ORG_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusiorg.pkh 115.0 99/07/17 06:44:47 porting ship $ */
 FUNCTION  insert_org_information
  ( P_ORGANIZATION_ID                 NUMBER
   ,P_ORG_INFORMATION_CONTEXT         VARCHAR2
   ,P_ORG_INFORMATION1                VARCHAR2
   ,P_ORG_INFORMATION2                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION3                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION4                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION5                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION6                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION7                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION8                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION9                VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION10               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION11               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION12               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION13               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION14               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION15               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION16               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION17               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION18               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION19               VARCHAR2 DEFAULT null
   ,P_ORG_INFORMATION20               VARCHAR2 DEFAULT null
  ) return NUMBER ;
--
end pay_us_ins_org_info_pkg;

 

/
