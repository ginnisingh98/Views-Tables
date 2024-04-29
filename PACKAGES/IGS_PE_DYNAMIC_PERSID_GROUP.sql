--------------------------------------------------------
--  DDL for Package IGS_PE_DYNAMIC_PERSID_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_DYNAMIC_PERSID_GROUP" AUTHID CURRENT_USER AS
/* $Header: IGSPEDGS.pls 120.1 2006/02/02 06:47:34 skpandey noship $ */

  FUNCTION IGS_GET_DYNAMIC_SQL(p_GroupID IN              igs_pe_persid_group_all.group_id%TYPE,
                                p_Status  OUT NOCOPY      VARCHAR2)
  RETURN  VARCHAR2;

  FUNCTION GET_DYNAMIC_SQL(p_GroupID IN              igs_pe_persid_group_all.group_id%TYPE,
                           p_Status  OUT NOCOPY      VARCHAR2,
			   p_group_type OUT NOCOPY   igs_pe_persid_group_v.group_type%TYPE)
  RETURN  VARCHAR2;

  FUNCTION GET_DYNAMIC_SQL_FROM_FILE(
     p_FileName	IN     		IGS_PE_DYN_SQLSEGS.file_name%TYPE,
     p_Status	OUT NOCOPY 	VARCHAR2) RETURN VARCHAR2;

  FUNCTION DYN_PIG_MEMBER(p_GroupID  IN   NUMBER,
                          p_PersonID IN   NUMBER)
  RETURN NUMBER;

  FUNCTION IGS_Post_Save_Document(p_WorkBookOwner IN VARCHAR2,
                       		  p_WorkBookName  IN VARCHAR2,
                       		  p_WorkSheetName IN VARCHAR2,
                       		  p_Sequence      IN NUMBER,
                       		  p_SQLSegment    IN varchar2)
  RETURN NUMBER;


END IGS_PE_DYNAMIC_PERSID_GROUP;

 

/
