--------------------------------------------------------
--  DDL for Package CN_USER_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_USER_ACCESS_PKG" AUTHID CURRENT_USER AS
/*$Header: cnturass.pls 115.4 2002/11/21 21:11:17 hlchen ship $*/

PROCEDURE Insert_Row(newrec   IN OUT
                     CN_USER_ACCESS_PVT.USER_ACCESS_REC_TYPE);
PROCEDURE Update_Row(newrec
                     CN_USER_ACCESS_PVT.USER_ACCESS_REC_TYPE);
PROCEDURE Lock_Row  (p_user_access_id        IN NUMBER,
                     p_object_version_number IN NUMBER);
PROCEDURE Delete_Row(p_user_access_id           NUMBER);

END CN_USER_ACCESS_PKG;

 

/
