--------------------------------------------------------
--  DDL for Package PER_PL_AEI_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_AEI_INFO" AUTHID CURRENT_USER AS
/* $Header: peplaeip.pkh 120.1 2005/11/24 01:37 mseshadr noship $ */

 procedure CREATE_PL_ASSGT_EXTRA_INFO(
 P_ASSIGNMENT_ID            in  NUMBER  ,
 P_INFORMATION_TYPE         in  varchar2 ,
 P_AEI_INFORMATION_CATEGORY in  varchar2 ,
 P_AEI_INFORMATION1         in  varchar2 ,
 P_AEI_INFORMATION2         in  varchar2 ,
 P_AEI_INFORMATION3         in  varchar2 ,
 P_AEI_INFORMATION4         in  varchar2 ,
 P_AEI_INFORMATION5         in  varchar2 ,
 P_AEI_INFORMATION6         in  varchar2 ,
 P_AEI_INFORMATION7         in  varchar2
 ) ;

procedure UPDATE_PL_ASSGT_EXTRA_INFO(
 P_ASSIGNMENT_EXTRA_INFO_ID in  NUMBER   ,
 P_AEI_INFORMATION_CATEGORY in  VARCHAR2 ,
 P_AEI_INFORMATION1         in  varchar2 ,
 P_AEI_INFORMATION2         in  varchar2 ,
 P_AEI_INFORMATION3         in  varchar2 ,
 P_AEI_INFORMATION4         in  varchar2 ,
 P_AEI_INFORMATION5         in  varchar2 ,
 P_AEI_INFORMATION6         in	varchar2 ,
 P_AEI_INFORMATION7         in	varchar2
 ) ;

END PER_PL_AEI_INFO;


/
