--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_IUHK" AS
  /* $Header: csnsrb.pls 120.1 2006/02/13 15:21:44 talex noship $ */




  /* Internal Procedure for pre processing in case of
	create service request */


 PROCEDURE Create_ServiceRequest_Pre
   (x_return_status        OUT NOCOPY VARCHAR2)
 IS
 BEGIN
   CS_ServiceRequest_UTIL.call_internal_hook('CS_ServiceRequest_PVT',
							          'Create_ServiceRequest',
									'B',
									x_return_status);
 END ;


  /* Internal Procedure for post processing in case of
	create service request */

  PROCEDURE  Create_ServiceRequest_Post
   (x_return_status        OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   CS_ServiceRequest_UTIL.call_internal_hook('CS_ServiceRequest_PVT',
							          'Create_ServiceRequest',
									'A',
									x_return_status);
  END ;


  /* Internal Procedure for pre processing in case of
	update service request */

  PROCEDURE  Update_ServiceRequest_Pre
   (x_return_status        OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   CS_ServiceRequest_UTIL.call_internal_hook('CS_ServiceRequest_PVT',
							          'Update_ServiceRequest',
									'B',
									x_return_status);
  END ;







  /* Internal Procedure for post processing in case of
	update service request */

  PROCEDURE  Update_ServiceRequest_Post
   (x_return_status        OUT NOCOPY VARCHAR2)
  IS
  BEGIN
   CS_ServiceRequest_UTIL.call_internal_hook('CS_ServiceRequest_PVT',
							          'Update_ServiceRequest',
									'A',
									x_return_status);
  END ;





END cs_servicerequest_iuhk;

/
