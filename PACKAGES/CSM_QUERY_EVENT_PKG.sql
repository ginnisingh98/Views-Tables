--------------------------------------------------------
--  DDL for Package CSM_QUERY_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_QUERY_EVENT_PKG" 
/* $Header: csmeqrys.pls 120.1.12010000.1 2009/08/03 06:23:20 appldev noship $*/
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

PROCEDURE REFRESH_ACC(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2);

PROCEDURE REFRESH_USER(p_user_id NUMBER);

END; -- Package spec

/
