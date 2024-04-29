--------------------------------------------------------
--  DDL for Package IGS_PR_GET_CLASS_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GET_CLASS_STD" AUTHID CURRENT_USER AS
/* $Header: IGSPR28S.pls 115.3 2003/10/27 07:27:16 ddey ship $ */
/* Function to get the Class Standing of the student */

 -- ddey     27-Oct-2003       Changes are done, so that the message stack is not initilized.(Bug # 3163305)
 --                            In the function Get_Class_Standing an extra parameter 'p_init_msg_list' is added.

 FUNCTION  Get_Class_Standing(
 P_Person_id IN NUMBER,
 P_Course_cd IN VARCHAR2,
 P_Predictive_ind  IN VARCHAR2 DEFAULT 'N',
 P_Effective_dt IN DATE,
 P_Load_Cal_type IN VARCHAR2,
 P_Load_Ci_Sequence_Number IN NUMBER ,
 p_init_msg_list  IN VARCHAR2 DEFAULT FND_API.G_FALSE )
 RETURN VARCHAR2;

END IGS_PR_GET_CLASS_STD;

 

/
