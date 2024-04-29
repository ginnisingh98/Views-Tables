--------------------------------------------------------
--  DDL for Package HR_DU_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DU_MASTER" AUTHID CURRENT_USER AS
/* $Header: perdumas.pkh 115.5 2002/11/28 16:23:38 apholt noship $ */


--
-- Declare records
--

TYPE r_upload_rec IS RECORD (upload_id NUMBER,
                             filename VARCHAR2(50));


--
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_filename IN VARCHAR2,
	       p_login	VARCHAR2 DEFAULT 'Y');
--


end hr_du_master;

 

/
