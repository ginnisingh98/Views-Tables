--------------------------------------------------------
--  DDL for Package CSM_CONCURRENT_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_CONCURRENT_JOBS_PKG" AUTHID CURRENT_USER AS
/* $Header: csmconcs.pls 120.1 2005/07/22 04:17:52 trajasek noship $ */

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

PROCEDURE refresh_all_acc( x_retcode OUT NOCOPY number,
                           x_return_status OUT NOCOPY VARCHAR2);

END csm_concurrent_jobs_pkg; -- Package spec

 

/
