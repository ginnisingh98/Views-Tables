--------------------------------------------------------
--  DDL for Package CSM_PROBCODE_MAPPING_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PROBCODE_MAPPING_EVENT_PKG" 
/* $Header: csmepbcs.pls 120.2 2005/11/14 09:02:23 trajasek noship $*/
AUTHID CURRENT_USER AS
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below

PROCEDURE Refresh_probcode_mapping_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);

END; -- Package spec

 

/
