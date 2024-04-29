--------------------------------------------------------
--  DDL for Package CS_SERVICEREQUEST_IUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICEREQUEST_IUHK" AUTHID CURRENT_USER AS
  /* $Header: csnsrs.pls 120.1 2006/02/13 15:21:19 talex noship $ */






  /* Internal Procedure for pre processing in case of
	create service request*/

  PROCEDURE Create_ServiceRequest_Pre
   (x_return_status        OUT NOCOPY VARCHAR2
	);



  /* Internal Procedure for post processing in case of
	create service request */

  PROCEDURE  Create_ServiceRequest_Post
   (x_return_status        OUT NOCOPY VARCHAR2
	   );




  /* Internal Procedure for pre processing in case of
	update service request */

  PROCEDURE  Update_ServiceRequest_Pre
   (x_return_status        OUT NOCOPY VARCHAR2
		 );




  /* Internal Procedure for post processing in case of
	update service request */

  PROCEDURE  Update_ServiceRequest_Post
   (x_return_status        OUT NOCOPY VARCHAR2
		    );

END cs_servicerequest_iuhk;

 

/
