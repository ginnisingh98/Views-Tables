--------------------------------------------------------
--  DDL for Package CSL_JTF_RESOURCE_EXTNS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_JTF_RESOURCE_EXTNS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslreacs.pls 120.0 2005/05/24 17:41:25 appldev noship $ */

FUNCTION Replicate_Record
  ( p_resource_extn_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if user should be replicated. Returns TRUE if it should ***/

PROCEDURE Insert_Resource_Extns
  ( p_resource_extn_id    IN NUMBER
   ,p_resource_id         IN NUMBER
  );
/***
  Public procedure that gets called when a resource extns needs to be inserted into ACC table.
***/

PROCEDURE Update_Resource_Extns
  ( p_resource_extn_id    IN NUMBER
   ,p_resource_id         IN NUMBER
  );
/***
  Public procedure that gets called when a resource extns needs to be updated into ACC table.
***/

PROCEDURE Delete_Resource_Extns
  ( p_resource_extn_id    IN NUMBER
   ,p_resource_id         IN NUMBER
  );
/***
  Public procedure that gets called when a resource extns needs to be deleted from ACC table.
***/

END CSL_JTF_RESOURCE_EXTNS_ACC_PKG;

 

/
