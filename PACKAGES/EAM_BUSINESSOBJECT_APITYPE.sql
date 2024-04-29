--------------------------------------------------------
--  DDL for Package EAM_BUSINESSOBJECT_APITYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_BUSINESSOBJECT_APITYPE" AUTHID CURRENT_USER AS
/* $Header: EAMTMPLS.pls 115.4 2002/11/20 22:32:44 aan ship $*/
   -- Start of comments
   -- API name    : APIname
   -- Type     : Public or Group or Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version              IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2    Optional
   --                                                  Default = FND_API.G_FALSE
   --          p_commit          IN VARCHAR2 Optional
   --             Default = FND_API.G_FALSE
   --          p_validation_level      IN NUMBER   Optional
   --             Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status      OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --          previous version   2.0
   --          Changed....
   --          Initial version    1.0
   --
   -- Notes    : Note text
   --
   -- End of comments

   PROCEDURE apiname(
      p_api_version        IN       NUMBER
     ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
     ,p_commit             IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level   IN       NUMBER
            := fnd_api.g_valid_level_full
     ,x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2);

END eam_businessobject_apitype;

 

/
