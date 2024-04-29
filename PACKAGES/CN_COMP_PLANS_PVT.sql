--------------------------------------------------------
--  DDL for Package CN_COMP_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLANS_PVT" AUTHID CURRENT_USER as
/* $Header: cnxvcmps.pls 115.1 2001/10/29 17:32:03 pkm ship    $ */

PROCEDURE create_comp_plan_client
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2,
   p_commit	        IN    VARCHAR2,
   p_validation_level   IN    NUMBER,
   x_return_status      OUT   VARCHAR2,
   x_msg_count	        OUT   NUMBER,
   x_msg_data	        OUT   VARCHAR2,
   p_comp_plan_name     IN    VARCHAR2,
   p_description        IN    VARCHAR2,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_status             IN    VARCHAR2,
   p_rc_overlap         IN    VARCHAR2,
   p_attribute1         IN    VARCHAR2,
   p_attribute2         IN    VARCHAR2,
   p_attribute3         IN    VARCHAR2,
   p_attribute4         IN    VARCHAR2,
   p_attribute5         IN    VARCHAR2,
   p_attribute6         IN    VARCHAR2,
   p_attribute7         IN    VARCHAR2,
   p_attribute8         IN    VARCHAR2,
   p_attribute9         IN    VARCHAR2,
   p_attribute10        IN    VARCHAR2,
   p_attribute11        IN    VARCHAR2,
   p_attribute12        IN    VARCHAR2,
   p_attribute13        IN    VARCHAR2,
   p_attribute14        IN    VARCHAR2,
   p_attribute15        IN    VARCHAR2,
   p_plan_element_name  IN    VARCHAR2,
   x_comp_plan_id       OUT   NUMBER,
   x_loading_status     OUT   VARCHAR2
   );

END CN_COMP_PLANS_PVT;

 

/
