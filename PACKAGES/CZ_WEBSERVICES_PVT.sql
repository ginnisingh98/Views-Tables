--------------------------------------------------------
--  DDL for Package CZ_WEBSERVICES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_WEBSERVICES_PVT" AUTHID CURRENT_USER AS
/*      $Header: czwspvts.pls 120.1 2005/06/17 11:48:58 dalee ship $  */
procedure validate(p_init_msg        IN VARCHAR2
                  ,p_url             IN VARCHAR2
                  ,x_config_xml_msg  OUT NOCOPY VARCHAR2
                  ,x_return_status   OUT NOCOPY VARCHAR2
                  ,x_msg_count       OUT NOCOPY NUMBER
                  ,x_msg_data        OUT NOCOPY VARCHAR2
                  );
END;

 

/
